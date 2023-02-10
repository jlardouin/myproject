# main.tf is the main Terraform source code to set my project on Flexible Engine
# 



resource "flexibleengine_obs_bucket" "admin_bucket" {
  bucket     = "${var.project}-jla-${random_string.id.result}"
  acl        = "private"
  versioning = true
}

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

# Create an Agency to delegate Cloud Service to access cloud ressources in other Cloud services
resource "flexibleengine_identity_agency_v3" "agency" {
  name                   = "${var.project}-Agency-${random_string.id.result}"
  description            = "Agency for enabling interaction between ECS and HSS/LTS/CES"
  # To enable Cloud Service for ECS, set delegated_service_name to "op_svc_ecs"
  delegated_service_name = "op_svc_ecs"

  project_role {
    project = "${var.tenant_name}"
    roles = [
      "Tenant Administrator",
    ]
  }
}

## Network configuration : config is
# 1. One single VPC with
# 2. Two Network (Frontend & Backend)
# 3. Two Subnet (Frontend & Backend)
# 4. One router routing the Two subnet
# 5. One NatGW with 1 SNAT for each subnet
#
# 1. VPC Layer : Create Virtual Private Cloud
resource "flexibleengine_vpc_v1" "vpc" {
  name = "${var.project}-vpc-${random_string.id.result}"
  cidr = "${var.vpc_cidr}"
}
# 2. Network Layer
# 2.1. Create Frontend network inside the VPC
resource "flexibleengine_networking_network_v2" "front_net" {
  name           = "${var.project}-front_net-${random_string.id.result}"
  admin_state_up = "true"
}
# 2.2. Create Backend network inside the VPC
resource "flexibleengine_networking_network_v2" "back_net" {
  name           = "${var.project}-back_net-${random_string.id.result}"
  admin_state_up = "true"
}
# 3. Subnet Layer
# 3.1. Create Frontend subnet inside the network
resource "flexibleengine_networking_subnet_v2" "front_subnet" {
  name            = "${var.project}-front_subnet-${random_string.id.result}"
  cidr            = "${var.front_subnet_cidr}"
  network_id      = flexibleengine_networking_network_v2.front_net.id
  gateway_ip      = "${var.front_gateway_ip}"
  dns_nameservers = ["100.125.0.41", "100.126.0.41"]
}
# 3.2. Create Backend subnet inside the network
resource "flexibleengine_networking_subnet_v2" "back_subnet" {
  name            = "${var.project}-back_subnet-${random_string.id.result}"
  cidr            = "${var.back_subnet_cidr}"
  network_id      = flexibleengine_networking_network_v2.back_net.id
  gateway_ip      = "${var.back_gateway_ip}"
  dns_nameservers = ["100.125.0.41", "100.126.0.41"]
}
# 4. Router Layer
# 4.1. Create Router interface for Frontend Network
resource "flexibleengine_networking_router_interface_v2" "front_router_interface" {
  router_id = flexibleengine_vpc_v1.vpc.id
  subnet_id = flexibleengine_networking_subnet_v2.front_subnet.id
}
# 4.2. Create Router interface for Backend Network
resource "flexibleengine_networking_router_interface_v2" "back_router_interface" {
  router_id = flexibleengine_vpc_v1.vpc.id
  subnet_id = flexibleengine_networking_subnet_v2.back_subnet.id
}
## Time to sleep
resource "time_sleep" "wait_for_vpc" {
  create_duration = "30s"
  depends_on = [flexibleengine_vpc_v1.vpc]
}

# 5. Create the NATGW
# 5.1 Create an Elastic IP for NATGW
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
# 5.2. Create the NATGW
resource "flexibleengine_nat_gateway_v2" "nat_1" {
  depends_on = [time_sleep.wait_for_vpc]
  name        = "${var.project}-NATGW-${random_string.id.result}"
  description = "demo NATGW for terraform"
  spec        = "1"
  vpc_id      = flexibleengine_vpc_v1.vpc.id
  subnet_id   = flexibleengine_networking_network_v2.front_net.id
}
# 5.3. Add SNAT rule for Frontend subnet
resource "flexibleengine_nat_snat_rule_v2" "snat_1" {
  depends_on = [time_sleep.wait_for_vpc]  
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_1.id
  floating_ip_id = flexibleengine_vpc_eip_v1.eip_natgw.id
  subnet_id      = flexibleengine_networking_network_v2.front_net.id
}
# 5.4. Add SNAT rule for Backend subnet
resource "flexibleengine_nat_snat_rule_v2" "snat_2" {
  depends_on = [time_sleep.wait_for_vpc]  
  nat_gateway_id = flexibleengine_nat_gateway_v2.nat_1.id
  floating_ip_id = flexibleengine_vpc_eip_v1.eip_natgw.id
  subnet_id      = flexibleengine_networking_network_v2.back_net.id
}

# Bastion creation : in the Frontend subnet
# 1. Create an Elastic IP for Bastion VM
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
# 2.1. Create security group
resource "flexibleengine_networking_secgroup_v2" "secgroup" {
  name = "${var.project}-secgroup-${random_string.id.result}"
}
# 2.2. Add rules to the security group
resource "flexibleengine_networking_secgroup_rule_v2" "ssh_rule_ingress4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = "${var.ssh_port}"
  port_range_max    = "${var.ssh_port}"
  remote_ip_prefix  = "${var.remote_ip}"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}
# 2.3. security group rule to access Bastion
resource "flexibleengine_networking_secgroup_rule_v2" "secgroup_rule_ingress6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = flexibleengine_networking_secgroup_v2.secgroup.id
}

# 3.Create ECS for Bastion
resource "flexibleengine_compute_instance_v2" "instance" {
  depends_on = [time_sleep.wait_for_vpc]
  name              = "${var.project}-bastion-${random_string.id.result}"
  flavor_id         = "s6.large.2"
  key_pair          = flexibleengine_compute_keypair_v2.keypair.name
  security_groups   = [flexibleengine_networking_secgroup_v2.secgroup.name]
  user_data = data.template_cloudinit_config.config.rendered
  availability_zone = "eu-west-0a"
  # Seems to be available in HC but not in FE Provider... cf. https://github.com/huaweicloud/terraform-provider-huaweicloud/blob/master/docs/resources/compute_instance.md
  # agency_name = flexibleengine_identity_agency_v3.agency.name
  network {
    uuid = flexibleengine_networking_network_v2.front_net.id
  }
  block_device { # Boots from volume
    # Ubuntu 20.04 OS Image  
    #uuid                  = "c2280a5f-159f-4489-a107-7cf0c7efdb21"
    uuid                  = "${var.bastion_os}"
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
