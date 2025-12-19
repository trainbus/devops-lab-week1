#!/bin/bash
set -eux

echo ">>> Installing dependencies..."
apt-get update -y
apt-get install -y \
  haproxy \
  certbot \
  python3-certbot-nginx \
  awscli \
  jq \
  docker.io \
  docker-compose-plugin

echo ">>> Enable Docker..."
systemctl enable --now docker

echo ">>> Adding ubuntu to docker group..."
usermod -aG docker ubuntu || true

echo ">>> Fetching service endpoints from SSM..."

NODE_API_URL=$(aws ssm get-parameter \
  --name "/ops/node_api" \
  --query "Parameter.Value" \
  --output text \
  --region ${AWS_REGION})

ADMIN_UI_URL=$(aws ssm get-parameter \
  --name "/ops/admin_ui" \
  --query "Parameter.Value" \
  --output text \
  --region ${AWS_REGION})

HUGO_URL=$(aws ssm get-parameter \
  --name "/ops/hugo" \
  --query "Parameter.Value" \
  --output text \
  --region ${AWS_REGION})

echo ">>> Writing HAProxy config..."
cat >/etc/haproxy/haproxy.cfg <<EOF
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
  server adminui ${ADMIN_UI_URL}:8080 check

backend be_hugo
  server hugo ${HUGO_URL}:1313 check

backend be_node
  server node ${NODE_API_URL}:3000 check
EOF

echo ">>> Restarting HAProxy..."
systemctl restart haproxy
systemctl enable haproxy

echo ">>> Requesting SSL certificate..."
certbot certonly \
  --standalone \
  -d ${domain} \
  --agree-tos \
  --email admin@${domain} \
  --non-interactive || true

echo ">>> Reloading HAProxy..."
systemctl restart haproxy

echo ">>> Creating docker-compose stack..."
mkdir -p /home/ubuntu/compose
chown ubuntu:ubuntu /home/ubuntu/compose

cat >/home/ubuntu/compose/docker-compose.yml <<EOF
version: "3.8"
services:
  admin_ui:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-lab-admin-ui:latest
    restart: unless-stopped
    ports:
      - "8080:80"

  hugo:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-lab-hugo:latest
    restart: unless-stopped
    ports:
      - "1313:80"
EOF

echo ">>> Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} \
  | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo ">>> Pulling and starting containers..."
docker compose -f /home/ubuntu/compose/docker-compose.yml pull
docker compose -f /home/ubuntu/compose/docker-compose.yml up -d

echo ">>> OPS HOST READY."




# cloud-init runcmd (example)
runcmd:
  - apt-get update -y || true
  - apt-get install -y docker.io docker-compose-plugin awscli jq || true
  - usermod -aG docker ubuntu || true
  - systemctl enable --now docker || true
  - mkdir -p /home/ubuntu/compose
  - chown ubuntu:ubuntu /home/ubuntu/compose

  # create docker-compose file using ECR paths (replace variables in your template)
  - cat > /home/ubuntu/compose/docker-compose.yml <<'EOF'
version: "3.8"
services:
  admin:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-lab-admin-ui:latest
    container_name: admin
    restart: unless-stopped
    ports:
      - "8080:80"

  hugo:
    image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/devops-lab-hugo:latest
    container_name: hugo
    restart: unless-stopped
    ports:
      - "1313:1313"
EOF

  - /usr/bin/aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
  - docker compose -f /home/ubuntu/compose/docker-compose.yml pull
  - docker compose -f /home/ubuntu/compose/docker-compose.yml up -d
