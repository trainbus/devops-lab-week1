variable "vpc_id" {
  type        = string
  description = "VPC ID for the API instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the API instance"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
}

variable "key_name" {
  type        = string
  description = "SSH key name"
}

variable "ec2_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "admin_ip" {
  type        = string
  description = "Admin IP for SSH access"
}

variable "ops_sg_id" {
  type        = string
  description = "Security group ID for the API instance"
}

#variable "mongodb_secret_arn" {
#  type        = string
#  description = "ARN of the MongoDB secret"
#}

variable "mongo_uri" {
  type        = string
  description = "MongoDB connection string"
}