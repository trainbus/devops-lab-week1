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
set -u

LOG=/var/log/ops-user-data.log
exec > >(tee -a $LOG) 2>&1

echo "=== OPS bootstrap start ==="

# Wait for IAM role
until aws sts get-caller-identity --region us-east-1 >/dev/null 2>&1; do
  echo "Waiting for IAM role..."
  sleep 5
done

echo "IAM role ready"

# Ensure services
usermod -aG docker ubuntu
systemctl enable docker || true
systemctl start docker || true
systemctl enable haproxy || true

# Fetch Node API IP (IP ONLY)
NODE_API_IP=$(aws ssm get-parameter \
  --name "/ops/node_api_ip" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

echo "Node API IP: $NODE_API_IP"

################################
# Write HAProxy config (runtime)
################################
cat >/etc/haproxy/haproxy.cfg <<HAPROXY
global
  daemon
  maxconn 2048
  log /dev/log local0

  ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11
  ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
  ssl-default-bind-ciphersuites TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256

defaults
  mode http
  log global
  option httplog
  timeout connect 5s
  timeout client  50s
  timeout server  50s

frontend http_in
  bind *:80
  redirect scheme https code 301 if !{ ssl_fc }

frontend https_in
  bind *:443 ssl crt /etc/haproxy/certs/

  acl is_admin path_beg /admin
  acl is_hugo  path_beg /blog
  acl is_api   path_beg /api

  use_backend admin_backend if is_admin
  use_backend hugo_backend  if is_hugo
  use_backend api_backend   if is_api
  default_backend hugo_backend

backend admin_backend
  server admin 127.0.0.1:8080 check

backend api_backend
  server api $${NODE_API_IP}:3000 check

backend hugo_backend
  option httpchk GET /
  server hugo 127.0.0.1:1313 check

HAPROXY
systemctl restart haproxy

echo "HAProxy started"

# TLS bootstrap (idempotent)
if [ ! -f /etc/haproxy/certs/onwuachi.com.pem ]; then
  echo "Running TLS bootstrap"
  /usr/local/bin/bootstrap-tls.sh
else
  echo "TLS cert already exists, skipping"
fi

echo "=== OPS bootstrap complete ==="
EOF

user_data_replace_on_change = true

tags = {
  Name        = var.ec2_name
  Environment = "dev"
  Owner       = "derrick"
  Role        = "ops"
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


# Obtain TLS cert on first boot
#/usr/local/bin/bootstrap-tls.sh
#  install -m 755 scripts/bootstrap-tls.sh /usr/local/bin/bootstrap-tls.sh

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


