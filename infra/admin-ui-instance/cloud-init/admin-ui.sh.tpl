#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Admin UI EC2 bootstrapping..."

# Ensure nginx is running (packer already installed it)
systemctl restart nginx

# Install SSM Agent (Amazon Linux 2 ships with it; Ubuntu needs install)
/usr/bin/apt-get update -y
/usr/bin/apt-get install -y amazon-ssm-agent || true
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo "Admin UI instance is ready."

