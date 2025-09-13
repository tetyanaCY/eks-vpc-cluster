terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}
# NOTE: no provider block and no backend here (root controls both)
