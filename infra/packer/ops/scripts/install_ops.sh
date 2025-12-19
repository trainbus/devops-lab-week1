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
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  haproxy \
  nginx \
  certbot \
  python3-certbot-nginx \
  jq \
  unzip \
  curl \
  docker.io \
  docker-compose-plugin

echo ">>> Enable docker & haproxy..."
systemctl enable docker
systemctl enable haproxy

# AWS CLI v2 - attempt apt first, fall back to installer
if ! command -v aws >/dev/null 2>&1; then
  if apt-cache show awscli >/dev/null 2>&1; then
    apt-get install -y awscli
  else
    curl -sS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install --update || true
    rm -rf /tmp/aws /tmp/awscliv2.zip
  fi
fi

# Create compose dir and a placeholder compose file (cloud-init will overwrite on boot)
mkdir -p /home/ubuntu/compose
chown ubuntu:ubuntu /home/ubuntu/compose

echo ">>> install_ops finished"
