#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  unzip \
  gnupg \
  lsb-release


if ! id acme >/dev/null 2>&1; then
  useradd \
    --system \
    --no-create-home \
    --shell /usr/sbin/nologin \
    acme
fi

mkdir -p /var/www/certbot
chown -R acme:acme /var/www/certbot
chmod 755 /var/www/certbot
