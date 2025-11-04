data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "wordpress" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.wordpress_sg_id]
  iam_instance_profile   = var.ssm_profile_name

  user_data = <<-EOF
    #!/bin/bash
    set -xe
    apt-get update -y
    apt-get install -y apache2 php php-mysql unzip curl
    snap install amazon-ssm-agent --classic || true
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true
    mkdir -p /var/www/html
    echo "<html><body><h1>Welcome — wordpress_01 placeholder</h1></body></html>" > /var/www/html/index.html
    chown -R www-data:www-data /var/www/html
    systemctl enable --now apache2
  EOF

  tags = {
    Name = var.ec2_name
  }
}