# aws-ecs-terraform 

### Description
This will build an ECS cluster in AWS across 2 azs.

### _Layout_
---
#### __envs__
> This directory has environment specific values that are passed through to the modules.
> There is a main.tf that invokes each module with arguments.

> Example:

```terraform
## Provider configuration
provider "aws" {
	version = "~> 2.63"
	region  = "eu-west-2"
}

## VPC/Network configuration
module "network" {
  source = "../../modules/network"
}
```
---
#### __modules__
> This directory has modules created to build our ECS custer.
> * There is a network module. This handles the base networking for our stack (VPC, Subnets, ALB, security groups etc)
---
