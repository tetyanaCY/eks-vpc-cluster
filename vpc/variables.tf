variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "Optional AWS named profile"
}

variable "vpc_name" {
  type    = string
  default = "ml-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  default     = 3
  description = "How many AZs to use"
}
