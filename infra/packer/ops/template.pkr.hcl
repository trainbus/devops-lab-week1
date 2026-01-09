packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.3"
    }
  }
}

############################
# Variables
############################
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ami_name" {
  type    = string
  default = "ops-haproxy-static-nginx-hugo"
}

############################
# Source AMI
############################
source "amazon-ebs" "ops" {
  region                      = var.region
  instance_type               = "t3.small"
  ssh_username                = "ubuntu"
  associate_public_ip_address = true

  ami_name = "${var.ami_name}-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }

    owners      = ["099720109477"]
    most_recent = true
  }
}

############################
# Build
############################
build {
  name    = "ops-image"
  sources = ["source.amazon-ebs.ops"]

  ################################
  # Provisioning
  ################################
  provisioner "shell" {
    execute_command = "sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/base.sh",
      "scripts/docker.sh",
      "scripts/haproxy.sh",
      "scripts/hugo.sh",
      "scripts/systemd.sh"
    ]
  }

  ################################
  # TLS Bootstrap Script
  ################################
  provisioner "file" {
    source      = "scripts/bootstrap-tls.sh"
    destination = "/tmp/bootstrap-tls.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/bootstrap-tls.sh /usr/local/bin/bootstrap-tls.sh",
      "sudo chmod 755 /usr/local/bin/bootstrap-tls.sh"
    ]
  }

  ################################
  # Post-processors
  ################################
  post-processors {

    # 1. Write manifest file containing AMI ID
    post-processor "manifest" {
      output = "manifest.json"
    }

    # 2. Extract latest AMI ID and write to SSM
    post-processor "shell-local" {
      inline = [
        "AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d':' -f2)",
        "if [ -z \"$AMI_ID\" ]; then echo 'ERROR: AMI_ID empty' && exit 1; fi",
        "echo DEBUG: AMI_ID=$AMI_ID",
        "aws ssm put-parameter --name /devopslab/ami/ops/latest --type String --value \"$AMI_ID\" --overwrite --region ${var.region} || exit 1"
      ]
    }
  }
}
