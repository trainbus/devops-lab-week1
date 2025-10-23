variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "SSH key name"
}

variable "aws_account_id" {}
variable "ecr_repo" {}

variable "image_tag" {
  description = "Tag of the Docker image to deploy"
  type        = string
}

variable "ec2_name_oweb" {
  description = "Name tag for the OnwuachiWebServer EC2 instance"
  type        = string
}