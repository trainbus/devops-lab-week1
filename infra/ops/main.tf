####  Why data instead of resource for AMI SSM?  packer ami ID into ssm -> tf reads via data now = no broken CI flow
#resource "aws_ssm_parameter" "ops_ami" {
#  name        = "/devopslab/ami/ops"
#  description = "AMI ID for Ops service"
#  type        = "String"
#  value       = "ami-05dd2db733186be21"   # OPS Packer AMI ID new with internal backend 
#  overwrite   = true
#}

#resource "aws_instance" "ops" {
#  ami                         = aws_ssm_parameter.ops_ami.value

##############################
# Read AMI from SSM (Packer writes it)
##############################
data "aws_ssm_parameter" "ops_ami" {
  name = "/devopslab/ami/ops"
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
set -euxo pipefail

LOG=/var/log/ops-user-data.log
touch $LOG
exec > >(tee -a $LOG) 2>&1

echo "=== OPS bootstrap start ==="

# Wait for IAM role
until aws sts get-caller-identity --region us-east-1 >/dev/null 2>&1; do
  echo "Waiting for IAM role..."
  sleep 3
done

echo "Fetching SSM parameters"
NODE_API_URL=$(aws ssm get-parameter --name "/ops/node_api" --with-decryption --query "Parameter.Value" --output text --region us-east-1)
#ADMIN_UI_URL=$(aws ssm get-parameter --name "/ops/admin_ui" --with-decryption --query "Parameter.Value" --output text --region us-east-1)
#HUGO_URL=$(aws ssm get-parameter --name "/ops/hugo" --with-decryption --query "Parameter.Value" --output text --region us-east-1)

echo "Updating SSL/TLS Cert Default"
mkdir -p /etc/haproxy/certs

if [ ! -f /etc/haproxy/certs/selfsigned.pem ]; then
  openssl req -x509 -newkey rsa:2048 \
    -keyout /etc/haproxy/certs/selfsigned.key \
    -out /etc/haproxy/certs/selfsigned.crt \
    -days 365 -nodes \
    -subj "/CN=$${HOSTNAME}"

  cat /etc/haproxy/certs/selfsigned.crt \
      /etc/haproxy/certs/selfsigned.key \
      > /etc/haproxy/certs/selfsigned.pem
fi

echo "Writing HAProxy config"
cat >/etc/haproxy/haproxy.cfg <<HAPROXY
global
  daemon
  maxconn 2048

defaults
  mode http
  timeout connect 5s
  timeout client 50s
  timeout server 50s

frontend http_in
  bind *:80
  http-request redirect scheme https code 301 if !{ ssl_fc }

frontend https_in
  bind *:443 ssl crt /etc/haproxy/certs/selfsigned.pem
  mode http

  acl is_admin path_beg /admin
  acl is_hugo  path_beg /blog
  acl is_api   path_beg /api

  use_backend admin_backend if is_admin
  use_backend hugo_backend if is_hugo
  use_backend api_backend if is_api
  default_backend hugo_backend


backend admin_backend
  server admin localhost:8080 check

backend hugo_backend
  server hugo localhost:1313 check

backend api_backend
  server api $${NODE_API_URL}:3000 check
HAPROXY

systemctl restart haproxy

echo "Starting containers"
docker compose -f /home/ubuntu/compose/docker-compose.yml pull
docker compose -f /home/ubuntu/compose/docker-compose.yml up -d

echo "=== OPS bootstrap complete ==="
EOF

user_data_replace_on_change = true
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
# Route53 Record
##############################
data "aws_route53_zone" "main" {
  name         = var.root_domain
  private_zone = false
}