variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.50.0.0/16"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

#variable "admin_ip" {
#  description = "Admin IP allowed for SSH"
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

variable "project_name" {
  description = "Base name for resources"
  type        = string
  default     = "devopslab"
}


