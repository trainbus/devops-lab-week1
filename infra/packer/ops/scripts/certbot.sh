#!/usr/bin/env bash
set -eux
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y snapd
snap install core
snap install --classic certbot
ln -sf /snap/bin/certbot /usr/bin/certbot
