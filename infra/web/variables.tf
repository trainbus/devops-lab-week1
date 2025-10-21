vable "aws_region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

