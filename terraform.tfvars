# AWS
aws_region  = "eu-central-1"
aws_profile = "default"

# VPC
vpc_name = "ml-vpc"
vpc_cidr = "10.0.0.0/16"
az_count = 3

# EKS
cluster_name    = "ml-eks-tf" # use a new name to avoid existing CloudWatch log group collision
cluster_version = "1.30"

# Node groups
cpu_instance_types = ["t3.medium"]
cpu_desired_size   = 2
cpu_min_size       = 1
cpu_max_size       = 4

gpu_instance_types = ["g4dn.xlarge"]
gpu_desired_size   = 1
gpu_min_size       = 0
gpu_max_size       = 2

# Encryption
kms_key_arn = "arn:aws:kms:eu-central-1:762416913134:key/b9fd1504-32bd-45cb-a5d1-d773eb30854d"

# Tags
tags = {
  Project = "ml-platform"
  Stack   = "infra"
}
