############################################
# Root: modules wiring & provider
############################################

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source     = "./vpc"
  name       = var.vpc_name
  cidr_block = var.vpc_cidr
  az_count   = var.az_count
  tags       = var.tags
}

module "eks" {
  source = "./eks"

  # cluster
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # wire VPC from module outputs
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # encryption & tags
  kms_key_arn = var.kms_key_arn
  tags        = var.tags

  # node groups
  cpu_instance_types = var.cpu_instance_types
  cpu_desired_size   = var.cpu_desired_size
  cpu_min_size       = var.cpu_min_size
  cpu_max_size       = var.cpu_max_size

  gpu_instance_types = var.gpu_instance_types
  gpu_desired_size   = var.gpu_desired_size
  gpu_min_size       = var.gpu_min_size
  gpu_max_size       = var.gpu_max_size
}
