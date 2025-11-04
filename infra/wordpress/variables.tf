variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the WordPress EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the WordPress security group"
  type        = string
}

variable "ec2_name" {
  description = "Name tag for the WordPress EC2 instance"
  type        = string
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
}

variable "wordpress_sg_id" {
  description = "Security group ID for WordPress EC2"
  type        = string
}

variable "ssm_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}