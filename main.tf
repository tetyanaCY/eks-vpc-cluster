provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  count  = var.use_root_orchestration ? 1 : 0
  source = "./vpc"
}

module "eks" {
  count  = var.use_root_orchestration ? 1 : 0
  source = "./eks"
}
