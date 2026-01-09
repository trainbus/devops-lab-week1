#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker
