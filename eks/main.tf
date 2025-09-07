provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = var.vpc_state_bucket
    key            = var.vpc_state_key
    region         = var.vpc_state_region
    dynamodb_table = "tf-state-locks"
  }
}

locals {
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    cpu = {
      instance_types = var.cpu_instance_types
      desired_size   = var.cpu_desired_size
      min_size       = var.cpu_min_size
      max_size       = var.cpu_max_size
      labels         = { workload = "cpu" }
    }

    gpu = {
      instance_types = var.gpu_instance_types
      desired_size   = var.gpu_desired_size
      min_size       = var.gpu_min_size
      max_size       = var.gpu_max_size

      # важливо для GPU-нод:
      ami_type = "AL2_x86_64_GPU"

      labels = {
        workload    = "gpu"
        accelerator = "nvidia"
      }

      taints = [{
        key    = "nvidia.com/gpu"
        value  = "present"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  tags = {
    Project = "ml-platform"
    Stack   = "eks"
  }
}
