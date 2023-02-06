terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  }
}

provider "docker" {
  host    = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}
resource "docker_container" "core_node" {
  image = "${docker_image.ubuntu.latest}"
  must_run = false
  name = "core_node"
  rm = false
  command = ["bash","-c" ,"apt-get update && apt-get install git -y && git clone https://github.com/epiccurious/bitcoin-core-node-builder.git && cd bitcoin-core-node-builder/ && ./nodebuilder.sh.sh"]

}