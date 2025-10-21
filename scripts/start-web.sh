#!/bin/bash
set -e
EC2_PUBLIC_IP=$1
echo "Starting HAProxy and Nginx on Onwuachi web server..."
ssh -i ~/.ssh/onwua_key.pem ubuntu@${EC2_PUBLIC_IP} "sudo systemctl start haproxy nginx"
echo "Web services started successfully."


