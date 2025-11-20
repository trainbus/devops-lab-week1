variable "key_name" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "ec2_name" {
  type        = string
}

variable "admin_ip" {
  type        = string
}

variable "ops_sg_id" {
  type        = string
}

variable "iam_instance_profile" {
  type        = string
}

# Cross-module inputs
variable "admin_ui_ip" {
  type        = string
}

variable "wordpress_ip" {
  type        = string
}

variable "node_app_ip" {
  type        = string
}
