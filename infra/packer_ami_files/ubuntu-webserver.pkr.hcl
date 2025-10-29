packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  region           = var.aws_region
  instance_type    = "t3.micro"
  ami_name         = "onwuachi-webserver-{{timestamp}}"
  ssh_username     = "ubuntu"

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

build {
  name    = "onwuachi-webserver"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source      = "haproxy.cfg"
    destination = "/tmp/haproxy.cfg"
  }

  provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo add-apt-repository universe -y",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y software-properties-common apt-transport-https ca-certificates curl unzip gnupg lsb-release haproxy nginx docker.io net-tools gdb",
      "sudo systemctl enable haproxy nginx docker",
      "sudo systemctl start haproxy nginx docker",
      "sudo usermod -aG docker ubuntu",
      "echo '<h1>Welcome to Onwuachi.com</h1><p>DevOps KB & Links Coming Soon.</p>' | sudo tee /var/www/html/index.html",
      "sudo mv /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo mv /tmp/nginx.conf /etc/nginx/sites-available/default",
      "sudo systemctl reload nginx",
      "sudo sed -i 's/^enabled=.*/enabled=0/' /etc/default/apport || echo 'enabled=0' | sudo tee -a /etc/default/apport",
      "echo 'kernel.core_pattern=/var/crash/core.%e.%p.%h.%t' | sudo tee -a /etc/sysctl.conf",
      "sudo sysctl -p"
    ]
  }
}