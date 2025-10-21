#!/bin/bash
set -e

EC2_PUBLIC_IP=$1
if [ -z "$EC2_PUBLIC_IP" ]; then
  echo "Usage: $0 <EC2_PUBLIC_IP>"
  exit 1
fi

echo "Stopping HAProxy and Nginx on Onwuachi web server ($EC2_PUBLIC_IP)..."
ssh -i ~/.ssh/onwua_key.pem ubuntu@${EC2_PUBLIC_IP} "sudo systemctl stop haproxy nginx"
echo "🛑 Web services stopped successfully."
