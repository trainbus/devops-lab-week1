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
  default = "node-api-ami-{{timestamp}}"
}

source "amazon-ebs" "node_api" {
  region                      = var.aws_region
  instance_type               = var.instance_type
  source_ami                  = var.source_ami
  ssh_username                = var.ssh_username
  ami_name                    = var.ami_name
  associate_public_ip_address = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

build {
  name    = "node-api-image"
  sources = ["source.amazon-ebs.node_api"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io jq curl",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker $${USER:-ubuntu} || true",
      "sudo apt-get clean"
    ]
  }

  provisioner "file" {
    source      = "provision/node-api"
    destination = "/home/ubuntu/node-api"
  }

  provisioner "shell" {
    inline = [
      "cd /home/ubuntu/node-api || exit 1",
      "sudo docker build -t node-api:latest . || true"
    ]
  }

  provisioner "shell" {
    inline = [
      "if ! command -v amazon-ssm-agent >/dev/null 2>&1; then",
      "  sudo snap install amazon-ssm-agent --classic || true",
      "  sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true",
      "fi"
    ]
  }
}