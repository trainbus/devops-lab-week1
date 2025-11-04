variable "vpc_id" {
  description = "VPC ID for the security groups"
  type        = string
}

variable "admin_ip" {
  description = "Admin IP for SSH access"
  type        = string
  default     = "47.12.88.38/32"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+$", var.admin_ip))
    error_message = "admin_ip must be a valid CIDR block like 192.168.1.0/24"
  }
}