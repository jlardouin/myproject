# provider.tf to define the Terraform Provider
terraform {
  backend "remote" {
    organization = "flexibleengine-sme"
    workspaces {
      name = "myproject"
    }
   }
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
    }
  }
}
# Configure the FlexibleEngine Provider with AK/SK
 provider "flexibleengine" {
  domain_name = var.domain_name
  region      = var.region
  tenant_name = var.tenant_name
  access_key  = var.access_key
  secret_key  = var.secret_key
}
