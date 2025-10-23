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