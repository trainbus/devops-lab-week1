#cloud-config
package_update: true
package_upgrade: true
packages:
  - docker.io
  - docker-compose-plugin
  - awscli
  - certbot
  - python3-certbot-nginx

bootcmd:
  - apt-get update -y

write_files:
  - path: /home/ubuntu/compose/docker-compose.yml
    permissions: '0644'
    owner: ubuntu:ubuntu
    content: |
      ${docker_compose_content}

  - path: /var/www/html/index.html
    permissions: '0644'
    owner: www-data:www-data
    content: |
      <h1>Welcome to Onwuachi.com</h1>
      <p>The CloudNinja that gives you DevOps KB & Links Coming Soon. Top list for recipes, anime, wikis and more.</p>

runcmd:
  - apt-get update -y || true
  - apt-get install -y docker.io docker-compose-plugin awscli certbot python3-certbot-nginx || true
  - usermod -aG docker ubuntu || true
  - systemctl enable docker || true
  - systemctl start docker || true
  - mkdir -p /home/ubuntu/compose
  - cd /home/ubuntu/compose
  - /usr/bin/aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
  - docker compose -f /home/ubuntu/compose/docker-compose.yml pull
  - docker compose -f /home/ubuntu/compose/docker-compose.yml up -d
  - certbot certonly --nginx -d onwuachi.com -d www.onwuachi.com --agree-tos -m admin@onwuachi.com --non-interactive || true
  - systemctl reload nginx || true
  - echo "=== Provisioning complete ==="