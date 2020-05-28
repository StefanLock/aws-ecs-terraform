## Terraform network resource creation

## Get available zones.
data "aws_availability_zones" "available" {
  state = "available"
}

## VPC creation
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

# Create IGW for NAT GWs
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

##Create EIPs for NAT GWs
resource "aws_eip" "pgw_1" {
  vpc      = true
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}
resource "aws_eip" "pgw_2" {
  vpc      = true
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## Subnet creation 2 public.
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

# NAT GW Create
resource "aws_nat_gateway" "pgw_1" {
  allocation_id = aws_eip.pgw_1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "pgw_2" {
  allocation_id = aws_eip.pgw_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
  depends_on = [aws_internet_gateway.igw]
}

# Private subnet creation
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## Create Routes

resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pgw_1.id
  }

  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

resource "aws_route_table" "cust_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}

## Create Load Balancer
resource "aws_lb" "ecs_frontend_alb" {
  name               = "myALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}
resource "aws_lb_target_group" "ecs_cluster_tg" {
  name     = "ecs-cluster-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
  tags = {
    Environment = var.target_env
    Name = var.stack_name
  }
}
resource "aws_lb_listener" "ecs_cluster_front_end" {
  load_balancer_arn = aws_lb.ecs_frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_cluster_tg.arn
  }
}
resource "aws_lb_target_group_attachment" "ecs_cluster_attach_gw1" {
  target_group_arn = aws_lb_target_group.ecs_cluster_tg.arn
  target_id        = aws_nat_gateway.pgw_1.public_ip
  port             = 80
}
resource "aws_lb_target_group_attachment" "ecs_cluster_attach_gw2" {
  target_group_arn = aws_lb_target_group.ecs_cluster_tg.arn
  target_id        = aws_nat_gateway.pgw_2.public_ip
  port             = 80
}
