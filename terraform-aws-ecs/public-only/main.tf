
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

resource "aws_security_group" "autograder-task" {
  name        = "autograder-task-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_ecs_service" "autograder" {
  name    = "autograder-service"
  cluster = aws_ecs_cluster.autograder.id
  task_definition = aws_ecs_task_definition.autograder.arn
  launch_type = "FARGATE"
  desired_count = var.app_count
  network_configuration {
    security_groups = [aws_security_group.autograder-task.id]
    subnets = aws_subnet.public.*.id
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.autograder.arn
    container_name = "autograder"
    container_port = 5000
  }
  depends_on = [
    aws_lb_listener.autograder
  ]
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}


resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.default.id
  map_public_ip_on_launch = true
}

resource "aws_security_group" "lb" {
  name        = "autograder-alb-security-group"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name            = "autograder-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "autograder" {
  name        = "autograder-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"
}

resource "aws_lb_listener" "autograder" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.autograder.id
    type             = "forward"
  }
}