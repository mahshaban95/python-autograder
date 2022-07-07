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

# Create and configure ECS service
resource "aws_ecs_service" "autograder" {
  name    = "autograder-service"
  cluster = aws_ecs_cluster.autograder.id
  task_definition = aws_ecs_task_definition.autograder.arn
  launch_type = "FARGATE"
  desired_count = 2
  network_configuration {
    subnets = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true
  }
}

resource "aws_default_vpc" "default_vpc" {
}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-west-2a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-west-2b"
}