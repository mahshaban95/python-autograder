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

# Create AWS ECS Cluster
resource "aws_ecs_cluster" "autograder" {
  name = "autograder-cluster"
}

# Create and configure ECS task definition
resource "aws_ecs_task_definition" "autograder" {
  family = "autograder"
  container_definitions = <<TASK_DEFINITION
  [
    {
      "name": "autograder",
      "image": "mahshaban95/autograder:2.0",
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  TASK_DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  memory = 512
  cpu = 256
}