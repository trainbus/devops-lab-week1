#!/bin/bash
set -e

cd /home/ubuntu/admin-ui

# Build Docker image
sudo docker build -t admin-ui .

