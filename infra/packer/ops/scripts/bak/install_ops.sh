#!/bin/bash
set -eux

# packer provisioning: use apt-get, free locks and avoid interactive prompts

echo ">>> Freeing apt locks (safe) ..."
systemctl stop apt-daily.service apt-daily-upgrade.service || true
systemctl kill --kill-who=all apt-daily.service || true
systemctl kill --kill-who=all apt-daily-upgrade.service || true
rm -f /var/lib/apt/lists/lock /var/lib/dpkg/lock* /var/lib/dpkg/lock-frontend || true
dpkg --configure -a || true

echo ">>> Updating system and installing packages..."
apt-get update -y

#DEBIAN_FRONTEND=noninteractive apt-get install -y \
#  haproxy nginx certbot python3-certbot-nginx \
#  jq unzip curl docker.io docker-compose

apt-get install -y \
  haproxy \
  docker.io \
  jq \
  unzip \
  curl \
  net-tools \
  certbot

echo ">>> optaining cert from letsencrypt..."
sudo certbot certonly \
  --standalone \
  -d ops.onwuachi.com \
  --agree-tos \
  -m admin@onwuachi.com

  echo ">>> Converting cert to PEM format..."
  sudo mkdir -p /etc/haproxy/certs

sudo cat \
  /etc/letsencrypt/live/ops.example.com/fullchain.pem \
  /etc/letsencrypt/live/ops.example.com/privkey.pem \
  | sudo tee /etc/haproxy/certs/ops.example.com.pem > /dev/null

sudo chmod 600 /etc/haproxy/certs/ops.example.com.pem


echo ">>> Enable docker & haproxy..."
systemctl enable docker
systemctl enable haproxy

echo ">>> Installing AWS CLI v2..."

if ! command -v aws >/dev/null 2>&1; then
  curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install --update
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# Create proxy cert dir
mkdir -p /etc/haproxy/certs
chown -R root:root /etc/haproxy/certs


# Create Hugo site dir
mkdir -p /opt/hugo/site
chown -R ubuntu:ubuntu /opt/hugo

# Create compose dir and a placeholder compose file (cloud-init will overwrite on boot)
mkdir -p /home/ubuntu/compose
chown ubuntu:ubuntu /home/ubuntu/compose

echo ">>> install_ops finished"

echo ">>> Cleaning cloud-init state"
cloud-init clean --logs
rm -rf /var/lib/cloud/*


install -m 755 scripts/bootstrap-tls.sh /usr/local/bin/bootstrap-tls.sh
