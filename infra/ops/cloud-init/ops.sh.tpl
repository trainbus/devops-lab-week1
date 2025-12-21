set -euxo pipefail

echo ">>> Installing base packages"
apt-get update -y
apt-get install -y \
  haproxy \
  certbot \
  jq \
  docker.io \
  unzip \
  ca-certificates \
  curl

echo ">>> Installing AWS CLI v2"
curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install

echo ">>> Enabling Docker"
systemctl enable --now docker
usermod -aG docker ubuntu || true


echo ">>> Fetching service endpoints from SSM..."

NODE_API_URL=$(aws ssm get-parameter \
  --name "/ops/node_api" \
  --query "Parameter.Value" \
  --output text \
  --region ${aws_region})

export NODE_API_IP

ADMIN_UI_URL=$(aws ssm get-parameter \
  --name "/ops/admin_ui" \
  --query "Parameter.Value" \
  --output text \
  --region ${aws_region})

HUGO_URL=$(aws ssm get-parameter \
  --name "/ops/hugo" \
  --query "Parameter.Value" \
  --output text \
  --region ${aws_region})

echo ">>> Writing HAProxy config..."
cat >/etc/haproxy/haproxy.cfg <<EOF
global
  log /dev/log local0
  maxconn 2048
  user haproxy
  group haproxy
  daemon

defaults
  log global
  mode http
  option httplog
  timeout connect 5000
  timeout client  50000
  timeout server  50000

frontend http_in
  bind *:80
  redirect scheme https code 301 if !{ ssl_fc }

frontend https_in
  bind *:443 ssl crt /etc/letsencrypt/live/onwuachi.com/fullchain.pem
  acl is_admin path_beg /admin
  acl is_hugo  path_beg /blog
  acl is_api   path_beg /api

  use_backend admin_backend if is_admin
  use_backend hugo_backend  if is_hugo
  use_backend api_backend   if is_api
  default_backend hugo_backend

backend admin_backend
  server admin localhost:8080 check

backend hugo_backend
  server hugo  localhost:1313 check

backend api_backend
  server api 10.50.1.78:3000 check
EOF

echo ">>> Restarting HAProxy..."
envsubst < /etc/haproxy/haproxy.cfg.template > /etc/haproxy/haproxy.cfg
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
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/devops-lab-admin-ui:latest
    restart: unless-stopped
    ports:
      - "8080:80"

  hugo:
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/devops-lab-hugo:latest
    restart: unless-stopped
    ports:
      - "1313:80"
EOF

echo ">>> Logging into ECR..."
aws ecr get-login-password --region ${aws_region} \
  | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com

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
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/devops-lab-admin-ui:latest
    container_name: admin
    restart: unless-stopped
    ports:
      - "8080:80"

  hugo:
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/devops-lab-hugo:latest
    container_name: hugo
    restart: unless-stopped
    ports:
      - "1313:1313"
EOF

  - /usr/bin/aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
  - docker compose -f /home/ubuntu/compose/docker-compose.yml pull
  - docker compose -f /home/ubuntu/compose/docker-compose.yml up -d
