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

  user_data = <<-EOF
#!/bin/bash
set -euo pipefail

LOG=/var/log/ops-user-data.log
exec > >(tee -a "$LOG") 2>&1

echo "=== OPS bootstrap start ==="

################################
# Wait for IAM
################################
for i in {1..24}; do
  aws sts get-caller-identity --region us-east-1 >/dev/null 2>&1 && break
  sleep 5
done

################################
# Start HAProxy (already safe)
################################
systemctl enable haproxy
systemctl start haproxy

################################
# One-time cert issuance
################################
if [ ! -f /etc/letsencrypt/live/onwuachi.com/fullchain.pem ]; then
  certbot certonly \
    --non-interactive \
    --agree-tos \
    --email admin@onwuachi.com \
    --webroot \
    -w /var/www/certbot \
    -d onwuachi.com \
    -d www.onwuachi.com
fi

################################
# Install deploy hook
################################
cat >/etc/letsencrypt/renewal-hooks/deploy/haproxy <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="onwuachi.com"
LIVE="/etc/letsencrypt/live/$DOMAIN"
DEST="/etc/haproxy/certs/$DOMAIN.pem"

cat "$LIVE/fullchain.pem" "$LIVE/privkey.pem" > "$DEST"
chmod 600 "$DEST"
systemctl reload haproxy
EOF

chmod 755 /etc/letsencrypt/renewal-hooks/deploy/haproxy

################################
# Enable certbot.timer
################################
systemctl enable certbot.timer
systemctl start certbot.timer

echo "=== OPS bootstrap complete ==="

EOF

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