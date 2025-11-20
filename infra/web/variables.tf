# AWS Environment Configuration
variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {}

# Networking
variable "vpc_id" {}
variable "subnet_id" {}

# EC2 Configuration
variable "iam_instance_profile" {}
variable "key_name" {}
variable "ec2_name" {
  default = "onwuachi_web_01"
}

variable "web_sg_id" {
  description = "Security group ID for the web EC2 instance"
  type        = string
}

# ECR Repositories
variable "ecr_repo_node" {
  default = "hello-docker-node"
}

variable "ecr_repo_go" {
  default = "hello-docker-go"
}

variable "ecr_repo_wordpress" {
  default = "wordpress"
}

# MongoDB Configuration
variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
}

# Optional: Uncomment if using secrets from AWS Secrets Manager
# variable "mongodb_secret_arn" {
#   description = "ARN of MongoDB secret from shared module"
#   type        = string
# }