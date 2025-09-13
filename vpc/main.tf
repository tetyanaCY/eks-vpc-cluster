data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.21"

  name = var.name
  cidr = var.cidr_block

  # Pick first az_count AZs
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # Simple subnet math (adjust newbits/netnum to your scheme if needed)
  # public:  10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24
  public_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.cidr_block, 8, i)
  ]
  # private: 10.0.16.0/24, 10.0.17.0/24, 10.0.18.0/24
  private_subnets = [
    for i in range(var.az_count) : cidrsubnet(var.cidr_block, 8, i + 16)
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}
