variable "ami_ssm_parameter" {
  type    = string
  default = "/devops/ami/hugo"
}

variable "subnet_id" {}
variable "key_name" {}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_name" {
  type    = string
  default = "hugo-01"
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}