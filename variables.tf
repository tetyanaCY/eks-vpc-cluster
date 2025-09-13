############################################
# Root variables
############################################

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type    = string
  default = null
}

variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type = number
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
  # example: "1.30"
}

variable "kms_key_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# CPU node group
variable "cpu_instance_types" {
  type = list(string)
}
variable "cpu_desired_size" {
  type = number
}
variable "cpu_min_size" {
  type = number
}
variable "cpu_max_size" {
  type = number
}

# GPU node group
variable "gpu_instance_types" {
  type = list(string)
}
variable "gpu_desired_size" {
  type = number
}
variable "gpu_min_size" {
  type = number
}
variable "gpu_max_size" {
  type = number
}
