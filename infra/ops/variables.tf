variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the ops EC2 instance"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ops EC2 instance"
}

variable "ec2_name" {
  type        = string
  description = "Name tag for the ops EC2 instance"
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
}

variable "ops_sg_id" {
  description = "Security group ID for the Ops EC2 instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}