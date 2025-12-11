#!/bin/bash
set -e

echo ">>> Freeing apt locks..."
sudo systemctl stop apt-daily.service apt-daily-upgrade.service || true
sudo systemctl kill --kill-who=all apt-daily.service || true
sudo systemctl kill --kill-who=all apt-daily-upgrade.service || true
sudo rm -f /var/lib/apt/lists/lock
sudo rm -f /var/lib/dpkg/lock*
sudo rm -f /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a || true

echo ">>> Updating system..."
apt-get update -y

echo ">>> Installing required packages..."
apt-get install -y haproxy nginx certbot python3-certbot-nginx jq unzip curl

echo ">>> Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo ">>> Disabling nginx so HAProxy owns ports 80/443..."
systemctl disable nginx || true
systemctl stop nginx || true

echo ">>> Done"
