provider "flexibleengine" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = var.auth_url
  region      = var.region
}

//resource "flexibleengine_compute_instance_v2" "myecs" {
//  name            = "myecs"
//  flavor_id       = "t2.small"
//  key_pair        = var.key
//  security_groups = ["sg-www","sg-ssh-intranet"]
//
//  block_device {
//    uuid                  = "0249222b-c9be-419b-a953-f47e91c3fc81"
//    source_type           = "image"
//    volume_size           = 50
//    boot_index            = 0
//    destination_type      = "volume"
//    delete_on_termination = true
//    volume_type           = "SATA"
//  }
//
//  network {
//    uuid = "5dea92aa-0d97-443c-8e03-a2f566bc6cc6"
//  }
//}

module "ecs_cluster" {
  source = "FlexibleEngineCloud/ecs/flexibleengine"

  instance_name  = "my-ecs-cluster"
  instance_count = 2
  availability_zone = "eu-west-0a"

  flavor_name        = "t2.small"
  key_name           = var.key
  security_groups    = ["710676b3-47fa-4ab9-a827-f432a83ba13e","957a4aa8-9c49-472a-836f-7737823e72c2"]
  subnet_id          = "55fa66d3-893f-4ee9-92ac-6a15cf293c79"
  network_id         = "5dea92aa-0d97-443c-8e03-a2f566bc6cc6"

  new_eip = false

  block_devices = [
    {
      uuid = "0249222b-c9be-419b-a953-f47e91c3fc81"
      source_type = "image"
      destination_type = "volume"
      volume_size = 50
      boot_index = 0
      delete_on_termination = true
      volume_type = "SATA" #SATA/SSD
    }
  ]

  metadata = {
    Terraform = "true"
    Environment = "dev"
  }
}
