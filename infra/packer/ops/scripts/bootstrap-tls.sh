#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive


DOMAIN="onwuachi.com"
EMAIL="admin@onwuachi.com"
CERT_DIR="/etc/haproxy/certs"
PEM="${CERT_DIR}/${DOMAIN}.pem"

if [ -f "$PEM" ]; then
  echo "TLS already exists, skipping"
  exit 0
fi

certbot certonly \
  --standalone \
  -d "$DOMAIN" \
  -d "www.$DOMAIN" \
  --agree-tos \
  -m "$EMAIL" \
  --non-interactive

mkdir -p "$CERT_DIR"

cat \
  /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
  /etc/letsencrypt/live/$DOMAIN/privkey.pem \
  > "$PEM"

chmod 600 "$PEM"

systemctl reload haproxy
