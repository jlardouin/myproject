output "bastion_public_IP" {
  value = flexibleengine_vpc_eip_v1.eip_bastion.publicip.0.ip_address
  description = "Bastion Public IP Address"    
}

output "bastion_private_IP" {
  value = flexibleengine_compute_instance_v2.bastion.access_ip_v4
  description = "Bastion Private IP Address"  
}

output "elb_id" {
  description = "ID of the created vpc"
  value       = flexibleengine_lb_loadbalancer_v2.elb.id
}

output "docker_private_IP" {
  value = flexibleengine_compute_instance_v2.docker.access_ip_v4
  description = "Docker Private IP Address"  
}

output "keypair_name" {
  value = flexibleengine_compute_keypair_v2.keypair.name
}

output "keypair" {
  value = tls_private_key.key.private_key_pem
  sensitive = true
}

output "ssh_port" {
  value = flexibleengine_networking_secgroup_rule_v2.ssh_rule_ingress4.port_range_min
}

output "vpc_id" {
  description = "ID of the created vpc"
  value       = flexibleengine_vpc_v1.vpc.id
}

output "frontend_cidr" {
  value = flexibleengine_networking_subnet_v2.front_subnet.cidr
}

output "backend_cidr" {
  value = flexibleengine_networking_subnet_v2.back_subnet.cidr
}

output "random_id" {
  value = random_string.id.result
  description = "random string value"
}
