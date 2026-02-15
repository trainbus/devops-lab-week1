##############################
# Read AMI from SSM (Packer writes it)
##############################
data "aws_ssm_parameter" "ops_ami" {
  name = "/devopslab/ami/ops/latest"
}

##############################
# EC2 Instance
##############################
resource "aws_instance" "ops" {
  ami                         = data.aws_ssm_parameter.ops_ami.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.ops_sg_id]
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOT
#!/bin/bash
set -euo pipefail

LOG=/var/log/ops-user-data.log
exec > >(tee -a "$LOG") 2>&1

echo "=== OPS bootstrap start ==="

################################
# Stop HAProxy (standalone needs :80)
################################
systemctl stop haproxy || true

################################
# Wait for DNS / network
################################
sleep 10

################################
# One-time cert issuance (standalone)
################################
if [ ! -d /etc/letsencrypt/live/onwuachi.com ]; then
  systemctl stop haproxy || true

  certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email admin@onwuachi.com \
    -d onwuachi.com \
    -d www.onwuachi.com

  systemctl start haproxy
fi


################################
# Build HAProxy PEM (atomic)
################################
cat \
  /etc/letsencrypt/live/onwuachi.com/fullchain.pem \
  /etc/letsencrypt/live/onwuachi.com/privkey.pem \
  > /etc/haproxy/certs/onwuachi.com.pem

chmod 600 /etc/haproxy/certs/onwuachi.com.pem

################################
# Platform API runtime config
################################
mkdir -p /etc/platform

cat >/etc/platform/api.env <<EOF
IMAGE_URI=${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/api:latest
PORT=3000
NODE_ENV=production
EOF

aws ecr get-login-password --region ${var.aws_region} \
 | docker login --username AWS --password-stdin \
   ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

systemctl daemon-reexec
systemctl start ops.target




################################
# Validate & start HAProxy
################################
haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl start haproxy

echo "=== OPS bootstrap complete ==="
EOT

  user_data_replace_on_change = true

  tags = {
    Name        = var.ec2_name
    Environment = "dev"
    Owner       = "derrick"
    Role        = "ops"
    BuiltBy     = "packer"
  }
}

##############################
# Elastic IP
##############################
resource "aws_eip" "ops" {
  tags = { Name = "ops-eip" }
}

resource "aws_eip_association" "ops" {
  instance_id   = aws_instance.ops.id
  allocation_id = aws_eip.ops.id
}

##############################
# Route53 records
##############################
data "aws_route53_zone" "main" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.root_domain
  type    = "A"
  ttl     = 60
  records = [aws_eip.ops.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.root_domain}"
  type    = "A"
  ttl     = 60
  records = [aws_eip.ops.public_ip]
}