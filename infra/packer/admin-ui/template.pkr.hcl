packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "source_ami" {
  type    = string
  default = "ami-04a81a99f5ec58529"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ami_name" {
  type    = string
  default = "admin-ui-ami-{{timestamp}}"
}

source "amazon-ebs" "admin_ui" {
  region                        = var.aws_region
  instance_type                 = var.instance_type
  source_ami                    = var.source_ami
  ssh_username                  = var.ssh_username
  ami_name                      = var.ami_name
  associate_public_ip_address   = true
}

build {
  name    = "admin-ui-image"
  sources = ["source.amazon-ebs.admin_ui"]

  # Install dependencies (nginx, docker if needed)
  provisioner "shell" {
    script = "scripts/install_deps.sh"
  }

  # Create directory on the instance for admin-ui static files
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /var/www/admin",
      "sudo chown ubuntu:ubuntu /var/www/admin"
    ]
  }

  # Upload the built Vite dist directory
  provisioner "file" {
    source      = "provision/admin-ui/dist/"
    destination = "/var/www/admin"
  }

  # Correct ownership
  provisioner "shell" {
    inline = [
      "sudo chown -R www-data:www-data /var/www/admin"
    ]
  }
}
