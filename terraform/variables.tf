variable "aws_region" {
  description = "The primary AWS region to deploy resources in."
  type        = string
}

variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "environment_name" {
  description = ""
  type        = string
}

variable "instance_type" {
  description = ""
  type        = string
}
