# provider.tf to define the Terraform Provider
terraform {
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
    }
  }
}
# Configure the FlexibleEngine Provider with AK/SK
# provider "flexibleengine" {
#  domain_name = var.domain_name
#  region      = var.region
#  tenant_name = var.tenant_name
#  access_key  = var.ak
#  secret_key  = var.sk
#}
