variable "vpc_id" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "key_name" {}
variable "aws_region" { default = "us-east-1" }
variable "ec2_name" { default = "Node-app-01" }
variable "aws_account_id" {}
variable "ecr_repo" { default = "hello-docker-node" }
variable "ecr_repo_node" { default = "hello-docker-node" }
variable "ecr_repo_go"   { default = "hello-docker-go" }
variable "ecr_repo_wordpress" { default = "wordpress" }

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "latest"
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

variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
}

variable "ops_sg_id" {
  description = "Security group ID for the app instance"
  type        = string
}

variable "enable_ssm" {
  description = "Enable SSM agent for remote access"
  type        = bool
  default     = true
}

