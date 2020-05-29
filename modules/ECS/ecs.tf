## Terraform ecs resource creation

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
  network_mode = aws_vpc
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
  launch_type = FARGATE
  network_configuration = {
    subnets = [var.pub_sub_1, var.pub_sub_2]
    security_groups = []
    assign_public_ip = false
  }

  # Track the latest ACTIVE revision
  task_definition = aws_ecs_task_definition.nginx.id
}
