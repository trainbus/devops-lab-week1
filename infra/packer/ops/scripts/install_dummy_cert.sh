#!/bin/bash
set -e

DOMAIN="onwuachi.com"
CERT_DIR="/etc/haproxy/certs"
CERT_FILE="$CERT_DIR/$DOMAIN.pem"

mkdir -p "$CERT_DIR"

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout /tmp/key.pem \
  -out /tmp/cert.pem \
  -days 365 \
  -subj "/CN=$DOMAIN"

cat /tmp/cert.pem /tmp/key.pem > "$CERT_FILE"
chmod 600 "$CERT_FILE"

# NOW validation is safe (haproxy is installed, config exists, cert exists)
haproxy -c -f /etc/haproxy/haproxy.cfg