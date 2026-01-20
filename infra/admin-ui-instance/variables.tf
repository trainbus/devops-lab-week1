variable "subnet_id" {
  description = "Subnet to place the admin-ui EC2 instance"
  type        = string
}

variable "sg_id" {
  description = "Security group ID for admin-ui"
  type        = string
}

variable "key_name" {
  description = "SSH keypair name"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM profile for EC2 (SSM recommended)"
  type        = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_name" {
  description = "EC2 instance Name tag"
  type        = string
  default     = "admin-ui"
}

variable "environment" {
  type    = string
  default = "dev"
}

