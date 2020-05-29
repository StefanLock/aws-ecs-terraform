## Terraform ecs resource creation

resource "aws_security_group" "ecs_allow_http" {
  name        = "ecs_allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from public subnets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [var.frontend_sg]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## ECR creation
resource "aws_ecr_repository" "ECSRepo" {
  name  = "myrepo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## ECS Cluster creation
resource "aws_ecs_cluster" "main" {
  name =  var.stack_name
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## Task definition creation
resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "1024"
  memory = "2048"
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
  container_definitions = <<DEFINITION
[
  {
    "cpu": 128,
    "environment": [{
      "name": "Environment",
      "value": "${var.target_env}"
    }],
    "essential": true,
    "image": "nginx:latest",
    "memory": 128,
    "memoryReservation": 64,
    "name": "nginx"
  }
]
DEFINITION
}

## Service creation

resource "aws_ecs_service" "nginx" {
  name = "nginx"
  cluster  = aws_ecs_cluster.main.id
  desired_count = 2
  launch_type = "FARGATE"
  network_configuration {
    subnets = [var.pub_sub_1, var.pub_sub_2]
    security_groups = [aws_security_group.ecs_allow_http.id]
    assign_public_ip = false
  }

  # Track the latest ACTIVE revision
  task_definition = aws_ecs_task_definition.nginx.id
}
