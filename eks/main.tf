module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  enable_irsa     = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Avoid previous 'log group already exists' error by using a new cluster_name,
  # or set this to false if you insist on reusing a name that already has a log group.
  create_cloudwatch_log_group = true
  cluster_enabled_log_types   = ["api", "audit", "authenticator"]

  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.kms_key_arn
  }

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

      ami_type = "AL2_x86_64_GPU"
      labels   = { workload = "gpu", accelerator = "nvidia" }
      taints   = [{ key = "nvidia.com/gpu", value = "present", effect = "NO_SCHEDULE" }]
    }
  }

  tags = var.tags
}
