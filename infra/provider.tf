variable "aws_region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}