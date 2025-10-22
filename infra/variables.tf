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