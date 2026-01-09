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
export DEBIAN_FRONTEND=noninteractive

LOG=/var/log/ops-user-data.log
exec > >(tee -a "$LOG") 2>&1

echo "=== OPS bootstrap start ==="

################################
# Wait for IAM role (with timeout)
################################
echo "Waiting for IAM role (max 2 minutes)..."

IAM_READY=no
for i in {1..24}; do
  if aws sts get-caller-identity --region us-east-1 >/dev/null 2>&1; then
    IAM_READY=yes
    break
  fi
  sleep 5
done

if [ "$IAM_READY" != "yes" ]; then
  echo "WARNING: IAM role not ready, continuing without SSM fetch"
else
  echo "IAM role ready"
fi

################################
# Docker FIRST
################################
usermod -aG docker ubuntu 2>/dev/null || true
systemctl enable docker || true
systemctl start docker || true

echo "Waiting for Docker..."
until docker info >/dev/null 2>&1; do
  sleep 2
done
echo "Docker ready"

################################
# Start containers
################################
if docker ps -a --format '{{.Names}}' | grep -q '^hugo-nginx$'; then
  docker start hugo-nginx
else
  echo "WARNING: hugo-nginx container not found"
fi

################################
# Fetch Node API IP
################################
NODE_API_IP=""

if [ "$IAM_READY" = "yes" ]; then
  NODE_API_IP=$(aws ssm get-parameter \
    --name "/ops/node_api_ip" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region us-east-1 || true)
fi

echo "Node API IP: $${NODE_API_IP:-not available}"


################################
# Wait for backend ports
################################
echo "Waiting for Hugo nginx (8080)..."
for i in {1..30}; do
  if ss -lnt | grep -q ':8080'; then
    echo "Hugo backend ready"
    READY=yes
    break
  fi
  sleep 2
done

if [ "$${READY:-no}" != "yes" ]; then
  echo "ERROR: Hugo backend never became ready"
  exit 1
fi

################################
# Ensure dummy TLS cert exists
################################
if [ ! -f /etc/haproxy/certs/dummy.pem ]; then
  echo "Creating dummy HAProxy cert"
  mkdir -p /etc/haproxy/certs

  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/haproxy/certs/dummy.key \
    -out /etc/haproxy/certs/dummy.crt \
    -days 365 -subj "/CN=localhost"

  cat /etc/haproxy/certs/dummy.key /etc/haproxy/certs/dummy.crt \
    > /etc/haproxy/certs/dummy.pem

  chmod 600 /etc/haproxy/certs/dummy.pem
fi

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
  ssl-default-bind-ciphersuites TLS_AES_256_GCM-SHA384:TLS_AES_128_GCM_SHA256

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
  bind *:443 ssl crt /etc/haproxy/certs/dummy.pem

  acl is_admin path_beg /admin
  acl is_hugo  path_beg /blog
  acl is_api   path_beg /api

  use_backend admin_backend if is_admin
  use_backend hugo_backend  if is_hugo
  use_backend api_backend   if is_api
  default_backend hugo_backend

backend admin_backend
  default-server init-addr last,libc,none
  server admin 127.0.0.1:8080 check

backend api_backend
  default-server init-addr last,libc,none
  server api $${NODE_API_IP}:3000 check disabled

backend hugo_backend
  option httpchk GET /
  default-server init-addr last,libc,none
  server hugo 127.0.0.1:8080 check
HAPROXY

########################################
# systemd ordering: HAProxy after Docker
########################################
mkdir -p /etc/systemd/system/haproxy.service.d

cat >/etc/systemd/system/haproxy.service.d/override.conf <<'HAPROXY_OVERRIDE'
[Unit]
After=docker.service
Requires=docker.service
HAPROXY_OVERRIDE

systemctl daemon-reexec
systemctl daemon-reload

################################
# Start HAProxy LAST
################################
systemctl enable haproxy || true
haproxy -c -f /etc/haproxy/haproxy.cfg && systemctl restart haproxy

################################
# TLS bootstrap (idempotent)
################################
if [ ! -f /etc/haproxy/certs/onwuachi.com.pem ]; then
  echo "Running TLS bootstrap"
  /usr/local/bin/bootstrap-tls.sh

  echo "Reloading HAProxy to pick up real TLS cert"
  systemctl reload haproxy && echo "HAProxy reloaded successfully"
else
  echo "TLS cert already exists, reloading HAProxy"
  systemctl reload haproxy && echo "HAProxy reloaded successfully"
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