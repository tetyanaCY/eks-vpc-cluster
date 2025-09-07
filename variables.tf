variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_profile" {
  type        = string
  description = "Optional named profile from your AWS credentials"
  default     = null
}

variable "use_root_orchestration" {
  type        = bool
  description = "If true, root will call both local modules"
  default     = false
}
