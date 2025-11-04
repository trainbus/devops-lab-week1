variable "key_name" {
  description = "SSH key name"
}

variable "aws_account_id" {
  description = "AWS account ID"
}

variable "ecr_repo" {
  description = "ECR repository name"
}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
  default     = "latest"
}

variable "ec2_name_oweb" {
  description = "Name tag for the OnwuachiWebServer EC2 instance"
  type        = string
}

variable "subnet_web_subnet_id" {
  description = "Subnet ID for the web server"
}

variable "vpc_id" {
  description = "VPC ID for the ops EC2 instance"
  type        = string
}

#variable "admin_ip" {
#  description = "Admin IP for SSH access"
#  type        = string
#}

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
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}