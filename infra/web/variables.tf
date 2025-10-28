variable "aws_region" {
  description = "AWS region to deploy to"
  default     = "us-east-1"
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = "onwua_key"
}

variable "ec2_name_oweb" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "OnwuachiWebServer"
}

variable "ec2_name" {
  type        = string
  description = "Name tag for the ops EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the ops EC2 instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ops EC2 instance"
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
}

variable "ops_sg_id" {
  description = "Security group ID for the Ops EC2 instance"
  type        = string
}

variable "ssm_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}