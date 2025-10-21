#!/bin/bash
set -e
echo "Upgrading Onwuachi web server..."
ssh -i ~/.ssh/onwua_key.pem ubuntu@${EC2_PUBLIC_IP} "
  sudo apt update -y &&
  sudo apt upgrade -y &&
  sudo systemctl restart haproxy nginx
"
echo "Upgrade completed successfully."


