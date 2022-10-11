# main.tf is the main source code

# Create an Elastic Cloud Server resource
resource "flexibleengine_compute_instance_v2" "test-server" {
  name        = "githubactions-server"
  image_name  = "OBS Ubuntu 20.04"
  flavor_name = "s6.small.1"
  key_pair    = "key-jla"
  security_groups = ["default"]
  network {
    uuid = "5dea92aa-0d97-443c-8e03-a2f566bc6cc6"
  }
}
