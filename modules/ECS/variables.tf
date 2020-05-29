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
