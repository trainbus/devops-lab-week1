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
  default = "ops-base-ami-{{timestamp}}"
}

source "amazon-ebs" "ops" {
  region                      = var.aws_region
  instance_type               = var.instance_type
  source_ami                  = var.source_ami
  ssh_username                = var.ssh_username
  ami_name                    = var.ami_name
  associate_public_ip_address = true
}

build {
  name    = "ops-image"
  sources = ["source.amazon-ebs.ops"]

  provisioner "shell" {
    script          = "scripts/install_ops.sh"
    execute_command = "sudo -E bash '{{ .Path }}'"
  }

  #post-processor "shell-local" {
  #inline = [
  #  "aws ssm put-parameter --name /devopslab/ami/ops --type String --value {{ .ArtifactId }} --overwrite --region ${var.aws_region}"
  #]
#}
}