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
# AK/SK variablecommented to enable Terraform deployment through Github Actions
# Uncomment AK/SK for local Terraform Deployment (value are definied in credentials.tf)
provider "flexibleengine" {
  domain_name = var.domain_name
  region      = var.region
  tenant_name = var.tenant_name
# access_key  = var.access_key
# secret_key  = var.secret_key
}