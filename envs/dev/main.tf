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
