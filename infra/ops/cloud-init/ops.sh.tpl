#!/bin/bash
set -eux

echo ">>> Installing dependencies..."
apt-get update -y
apt-get install -y haproxy certbot python3-certbot-nginx awscli jq

echo ">>> Fetching SSM parameters (runtime)..."

NODE_API_URL=$(aws ssm get-parameter \
  --name "/ops/node_api" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

ADMIN_UI_URL=$(aws ssm get-parameter \
  --name "/ops/admin_ui" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

HUGO_URL=$(aws ssm get-parameter \
  --name "/ops/hugo" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

echo ">>> Writing HAProxy config..."
cat <<'EOF' >/etc/haproxy/haproxy.cfg
global
  log /dev/log local0
  user haproxy
  group haproxy
  daemon

defaults
  log global
  mode http
  timeout client 50s
  timeout server 50s
  timeout connect 5s

frontend fe_main
  bind *:80
  bind *:443 ssl crt /etc/letsencrypt/live/${domain}/fullchain.pem key /etc/letsencrypt/live/${domain}/privkey.pem

  acl is_admin_ui path_beg /admin
  acl is_hugo path_beg /blog
  acl is_node path_beg /api

  use_backend be_admin_ui if is_admin_ui
  use_backend be_hugo if is_hugo
  use_backend be_node if is_node

backend be_admin_ui
  server adminui $${ADMIN_UI_URL}:80 check

backend be_hugo
  server hugo $${HUGO_URL}:80 check

backend be_node
  server node $${NODE_API_URL}:3000 check
EOF

echo ">>> Restarting HAProxy..."
systemctl restart haproxy
systemctl enable haproxy

echo ">>> Requesting SSL certificate..."
certbot certonly --standalone -d ${domain} --non-interactive --agree-tos -m admin@${domain}

echo ">>> Final HAProxy restart..."
systemctl restart haproxy
