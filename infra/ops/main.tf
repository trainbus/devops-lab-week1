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

resource "aws_instance" "ops" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ops_sg_id]
  iam_instance_profile   = var.iam_instance_profile

  user_data = <<-EOF
    #!/bin/bash
    set -xe
    apt-get update -y
    apt-get install -y haproxy snapd
    snap install --classic certbot || true
    ln -s /snap/bin/certbot /usr/bin/certbot || true
    snap install amazon-ssm-agent --classic || true
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service || true
    mkdir -p /etc/haproxy
    cat > /etc/haproxy/haproxy.cfg <<'HCFG'
    global
      log /dev/log local0
      maxconn 2000
      daemon
    defaults
      log global
      mode http
      timeout connect 5000
      timeout client 50000
      timeout server 50000
    frontend http_in
      bind *:80
      redirect scheme https code 301 if !{ ssl_fc }
    backend web_backend
      server local 127.0.0.1:8080 check
    HCFG
    systemctl enable --now haproxy
  EOF

  tags = {
    Name = var.ec2_name
  }
}