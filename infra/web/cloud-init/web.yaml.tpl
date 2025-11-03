#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io
  - docker-compose-plugin
  - awscli
  - certbot
  - python3-certbot-nginx
runcmd:
  - systemctl enable nginx docker
  - systemctl start nginx docker
  - usermod -aG docker ubuntu
  - echo "<h1>Welcome to Onwuachi.com</h1><p>The CloudNinja that gives you DevOps KB & Links Coming Soon., top list for recipes, anime, wiki's and more</p>" > /var/www/html/index.html
  - certbot certonly --nginx -d onwuachi.com -d www.onwuachi.com --agree-tos -m admin@onwuachi.com --non-interactive || true
  - systemctl reload nginx
  - docker run -d -p 8080:8080 ghcr.io/hello-world

#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io
  - docker-compose-plugin
  - awscli
  - certbot
  - python3-certbot-nginx

runcmd:
  - echo "=== Starting multi-app provisioning ==="
  - apt-get update -y
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ubuntu

  # Inject MongoDB URI from Terraform
  - echo "Injecting Mongo URI..."
  - MONGO_URI="${mongo_uri}"

  # Create directories
  - mkdir -p /home/ubuntu/compose
  - cd /home/ubuntu/compose

  # Write Docker Compose template
  - |
    cat <<'EOF' > docker-compose.yml
    ${docker_compose_content}
    EOF

  - echo "Pulling images..."
  - /usr/local/bin/aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
  - docker-compose pull
  - docker-compose up -d

  - echo "<h1>Welcome to Onwuachi.com</h1><p>The CloudNinja that gives you DevOps KB & Links Coming Soon., top list for recipes, anime, wiki's and more</p>" > /var/www/html/index.html
  - certbot certonly --nginx -d onwuachi.com -d www.onwuachi.com --agree-tos -m admin@onwuachi.com --non-interactive || true
  - echo "=== Provisioning complete ==="
