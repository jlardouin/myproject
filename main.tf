# main.tf is the main source code

# Creation of a Key Pair
resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "flexibleengine_compute_keypair_v2" "keypair" {
  name       = "${var.project}-KeyPair-${random_string.id.result}"
  public_key = tls_private_key.key.public_key_openssh
  provisioner "local-exec" {    # Generate "TF-Keypair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.key.private_key_pem}' > ./'${var.project}-KeyPair-${random_string.id.result}'.pem
      chmod 400 ./'${var.project}-KeyPair-${random_string.id.result}'.pem
    EOT
  }
}

# Create Virtual Private Cloud
resource "flexibleengine_vpc_v1" "vpc" {
  name = "${var.project}-vpc-${random_string.id.result}"
  cidr = "${var.vpc_cidr}"
}

# Create Frontend network inside the VPC
resource "flexibleengine_networking_network_v2" "front_net" {
  name           = "${var.project}-front_net-${random_string.id.result}"
  admin_state_up = "true"
}

# Create Backend network inside the VPC
resource "flexibleengine_networking_network_v2" "back_net" {
  name           = "${var.project}-back_net-${random_string.id.result}"
  admin_state_up = "true"
}

# Create Frontend subnet inside the network
resource "flexibleengine_networking_subnet_v2" "front_subnet" {
  name            = "${var.project}-front_subnet-${random_string.id.result}"
  cidr            = "${var.front_subnet_cidr}"
  network_id      = flexibleengine_networking_network_v2.front_net.id
  gateway_ip      = "${var.front_gateway_ip}"
  dns_nameservers = ["100.125.0.41", "100.126.0.41"]
}

# Create Backend subnet inside the network
resource "flexibleengine_networking_subnet_v2" "back_subnet" {
  name            = "${var.project}-back_subnet-${random_string.id.result}"
  cidr            = "${var.back_subnet_cidr}"
  network_id      = flexibleengine_networking_network_v2.back_net.id
  gateway_ip      = "${var.back_gateway_ip}"
  dns_nameservers = ["100.125.0.41", "100.126.0.41"]
}

# Create Router interface for Frontend Network
resource "flexibleengine_networking_router_interface_v2" "front_router_interface" {
  router_id = flexibleengine_vpc_v1.vpc.id
  subnet_id = flexibleengine_networking_subnet_v2.front_subnet.id
}

# Create Router interface for Backend Network
resource "flexibleengine_networking_router_interface_v2" "back_router_interface" {
  router_id = flexibleengine_vpc_v1.vpc.id
  subnet_id = flexibleengine_networking_subnet_v2.back_subnet.id
}

#Create an Elastic IP for Bastion VM
resource "flexibleengine_vpc_eip_v1" "eip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project}-Bastion-EIP-${random_string.id.result}"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# Create security group
resource "flexibleengine_networking_secgroup_v2" "secgroup" {
  name = "${var.project}-secgroup-${random_string.id.result}"
}

# Add rules to the security group
resource "flexibleengine_networking_secgroup_rule_v2" "ssh_rule_ingress4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${var.ssh_port}"
  port_range_max    = "${var.ssh_port}"
  remote_ip_prefix  = "${var.remote_ip}"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

# Add rules to access MySQL
resource "flexibleengine_networking_secgroup_rule_v2" "mysql_rule_ingress4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${var.mysql_port}"
  port_range_max    = "${var.mysql_port}"
  remote_ip_prefix  = "${var.back_subnet_cidr}"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

# security group rule to access Bastion
resource "flexibleengine_networking_secgroup_rule_v2" "bastion_rule_ingress4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${var.guacamole_port}"
  port_range_max    = "${var.guacamole_port}"
  remote_ip_prefix  = "${var.any_ip}"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

resource "flexibleengine_networking_secgroup_rule_v2" "secgroup_rule_ingress6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

resource "time_sleep" "wait_for_vpc" {
  create_duration = "30s"
  depends_on = [flexibleengine_vpc_v1.vpc]
}

#Create an Elastic IP for NATGW
resource "flexibleengine_vpc_eip_v1" "eip_natgw" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project}-NATGW-EIP-${random_string.id.result}"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

#Create NAT GW
resource "flexibleengine_nat_gateway_v2" "nat_1" {
  depends_on = [time_sleep.wait_for_vpc]
  name        = "${var.project}-NATGW-${random_string.id.result}"
  description = "demo NATGW for terraform"
  spec        = "1"
  vpc_id      = flexibleengine_vpc_v1.vpc.id
  subnet_id   = flexibleengine_networking_network_v2.front_net.id
}

#Add SNAT rule for Frontend subnet
resource "flexibleengine_nat_snat_rule_v2" "snat_1" {
  depends_on = [time_sleep.wait_for_vpc]  
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_1.id
  floating_ip_id = flexibleengine_vpc_eip_v1.eip_natgw.id
  subnet_id      = flexibleengine_networking_network_v2.front_net.id
}

#Add SNAT rule for Backend subnet
resource "flexibleengine_nat_snat_rule_v2" "snat_2" {
  depends_on = [time_sleep.wait_for_vpc]  
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_1.id
  floating_ip_id = flexibleengine_vpc_eip_v1.eip_natgw.id
  subnet_id      = flexibleengine_networking_network_v2.back_net.id
}

# Create VM
resource "flexibleengine_compute_instance_v2" "instance" {
  depends_on = [time_sleep.wait_for_vpc]
  name              = "${var.project}-bastion-${random_string.id.result}"
  flavor_id         = "s6.large.2"
  key_pair          = flexibleengine_compute_keypair_v2.keypair.name
  security_groups   = [flexibleengine_networking_secgroup_v2.secgroup.name]
  user_data = data.template_cloudinit_config.config.rendered
  availability_zone = "eu-west-0a"
  network {
    uuid = flexibleengine_networking_network_v2.front_net.id
  }
  block_device { # Boots from volume
    uuid                  = "c2280a5f-159f-4489-a107-7cf0c7efdb21"
    source_type           = "image"
    volume_size           = "40"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    #volume_type           = "SSD"
  }
}

resource "flexibleengine_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = flexibleengine_vpc_eip_v1.eip.publicip.0.ip_address
  instance_id = flexibleengine_compute_instance_v2.instance.id
}

# Create an Elastic Cloud Server resource
# Create an Elastic Cloud Server resource
# resource "flexibleengine_compute_instance_v2" "test-server" {
#   name        = "githubactions-server"
#   image_name  = "OBS Ubuntu 20.04"
#   flavor_name = "s6.small.1"
#   key_pair    = "key-jla"
#   security_groups = ["default"]
#   network {
#     uuid = "5dea92aa-0d97-443c-8e03-a2f566bc6cc6"
#   }
# }
