variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "kms_key_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# node groups
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
