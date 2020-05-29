variable "target_env" {
  description = "The name of env e.g dev, prod etc"
  type        = string
  default	= "dev"
}

variable "stack_name" {
  description = "The name of the stack, normally the solution/app"
  type        = string
  default	= "MyAppStack"
}

variable "pub_sub_1" {
  description = "exported subnet name public 1"
  type        = string
  default	= ""
}

variable "pub_sub_2" {
  description = "exported subnet name public 2"
  type        = string
  default	= ""
}

variable "frontend_sg" {
  description = "exported frontend security group"
  type        = string
  default	= ""
}

variable "vpc_id" {
  description = "exported vpc id"
  type        = string
  default	= ""
}
