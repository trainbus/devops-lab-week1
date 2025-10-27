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