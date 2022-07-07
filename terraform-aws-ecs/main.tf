terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.21.0"
    }
    docker = {
      source = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }
}

provider "docker" {
}
# Pulls the image from docker hub
resource "docker_image" "autograder" {
    name = "mahshaban95/autograder:2.0"
}

provider "aws" {
  region = var.region
}