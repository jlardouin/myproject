# provider.tf to define the Terraform Provider
terraform {
  required_providers {
    flexibleengine = {
      source = "FlexibleEngineCloud/flexibleengine"
    }
  }
}
# Configure the FlexibleEngine Provider with AK/SK
 provider "flexibleengine" {
  domain_name = "OCB0001661"
  region      = "eu-west-0"
  tenant_name = "eu-wes-0_jla"
#  access_key  = var.ak
#  secret_key  = var.sk
}
