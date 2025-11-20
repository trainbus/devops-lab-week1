variable "ami_ssm_parameter" { type = string default = "/devops/ami/node-api" }
variable "subnet_id" {}
variable "key_name" {}
variable "instance_type" { default = "t3.micro" }
variable "ec2_name" { default = "app-01" }
variable "iam_instance_profile" { default = "" }
variable "security_group_ids" { type = list(string) default = [] }

