variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  type    = string
  default = null
}

variable "cluster_name" {
  type    = string
  default = "ml-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "cpu_desired_size" {
  type    = number
  default = 2
}

variable "cpu_min_size" {
  type    = number
  default = 1
}

variable "cpu_max_size" {
  type    = number
  default = 4
}

variable "cpu_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "gpu_desired_size" {
  type    = number
  default = 1
}

variable "gpu_min_size" {
  type    = number
  default = 0
}

variable "gpu_max_size" {
  type    = number
  default = 2
}

variable "gpu_instance_types" {
  type    = list(string)
  default = ["g4dn.xlarge"]
}

variable "vpc_state_bucket" {
  type        = string
  description = "S3 bucket for VPC terraform state"
}

variable "vpc_state_region" {
  type        = string
  description = "Region of the VPC state bucket"
}

variable "vpc_state_key" {
  type        = string
  description = "Key (path) to the VPC state file, e.g., envs/dev/vpc/terraform.tfstate"
}
