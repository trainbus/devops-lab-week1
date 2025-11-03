variable "vpc_id" {}
variable "subnet_id" {}
variable "iam_instance_profile" {}
variable "key_name" {}
variable "aws_region" { default = "us-east-1" }
variable "ec2_name_oweb" { default = "onwuachi_web_01" }

variable "aws_account_id" {}
variable "ecr_repo_node" { default = "hello-docker-node" }
variable "ecr_repo_go"   { default = "hello-docker-go" }
variable "ecr_repo_wordpress" { default = "wordpress" }

#variable "mongodb_secret_arn" {
#  description = "ARN of MongoDB secret from shared module"
#  type        = string
#}

variable "mongo_uri" {
  description = "MongoDB connection string"
  type        = string
}

variable "web_sg_id" {
  description = "Security group ID for the web EC2 instance"
  type        = string
}