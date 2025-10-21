#!/bin/bash
set -e
echo "Stopping HAProxy and Nginx on Onwuachi web server..."
ssh -i ~/.ssh/onwua_key.pem ubuntu@${EC2_PUBLIC_IP} "sudo systemctl stop haproxy nginx"
echo "Web services stopped successfully."

