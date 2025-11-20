##############################
# AWS Environment Variables #
##############################

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the deployment"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "ops_sg_id" {
  description = "Security group ID for the app instance"
  type        = string
}

#########################
# EC2 Instance Settings #
#########################

variable "ec2_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "Node-app-01"
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
  default     = "47.12.88.38/32"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+$", var.admin_ip))
    error_message = "admin_ip must be a valid CIDR block like 192.168.1.0/24"
  }
}

variable "enable_ssm" {
  description = "Enable SSM agent for remote access"
  type        = bool
  default     = true
}

#########################
# Application Variables #
#########################

variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "latest"
}

#########################
# ECR Repository Names  #
#########################

variable "ecr_repo" {
  description = "Default ECR repository name"
  type        = string
  default     = "hello-docker-node"
}

variable "ecr_repo_node" {
  description = "Node.js API ECR repository name"
  type        = string
  default     = "hello-docker-node"
}

variable "ecr_repo_go" {
  description = "Go ECR repository name"
  type        = string
  default     = "hello-docker-go"
}

variable "ecr_repo_wordpress" {
  description = "WordPress ECR repository name"
  type        = string
  default     = "wordpress"
}
