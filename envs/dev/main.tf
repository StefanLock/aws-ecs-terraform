## Terraform script for ECS Cluster

## Provider configuration

provider "aws" {
	version = "~> 2.63"
	region  = "eu-west-2"
}

## VPC/Network configuration
module "network" {
  source = "../../modules/network"
}

## ECS configuration
module "ecs" {
  source = "../../modules/ecs"
	pub_sub_1 = module.network.pub_sub_1
	pub_sub_2 = module.network.pub_sub_2
}
