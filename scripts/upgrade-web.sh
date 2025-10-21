#!/bin/bash
set -e

EC2_PUBLIC_IP=$1
if [ -z "$EC2_PUBLIC_IP" ]; then
  echo "Usage: $0 <EC2_PUBLIC_IP>"
  exit 1
fi

echo "Upgrading Onwuachi web server ($EC2_PUBLIC_IP)..."
ssh -i ~/.ssh/onwua_key.pem ubuntu@${EC2_PUBLIC_IP} "
  sudo apt update -y &&
  sudo apt upgrade -y &&
  sudo systemctl restart haproxy nginx
"
echo "🚀 Upgrade completed successfully."


