#!/bin/bash
set -euo pipefail

DOMAIN="onwuachi.com"
LIVE="/etc/letsencrypt/live/${DOMAIN}"
TARGET="/etc/haproxy/certs/${DOMAIN}.pem"

cat \
  "${LIVE}/privkey.pem" \
  "${LIVE}/fullchain.pem" \
  > "${TARGET}.new"

chmod 600 "${TARGET}.new"
mv "${TARGET}.new" "${TARGET}"

systemctl reload haproxy
