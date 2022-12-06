variable "region" {
  default = "eu-west-0"
  description = "Region endoint to be refered"
}
variable "domain_name" {
  default = "OCB0001661"
  description = "domain name to be refered"
}
variable "tenant_name" {
  default = "eu-west-0_jla"
  description = "tenant name of the domain to be refered"
}
variable "project" {
  default = "demo"
  description = "Short descriptive, readable label of the project you are working on. Is utilized as a part of resource names."
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
  description = "VPC CIDR."
}

variable "front_subnet_cidr" {
  default = "192.168.1.0/24"
  description = "Subnet CIDR."
}

variable "back_subnet_cidr" {
  default = "192.168.2.0/24"
  description = "Subnet CIDR."
}

variable "front_gateway_ip" {
  default = "192.168.1.1"
  description = "Subnet gateway IP."
}

variable "back_gateway_ip" {
  default = "192.168.2.1"
  description = "Subnet gateway IP."
}

# ID String for resources
resource "random_string" "id" {
  length  = 4
  special = false
  upper   = false
}
