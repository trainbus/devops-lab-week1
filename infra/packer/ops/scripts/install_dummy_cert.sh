#!/usr/bin/env bash
set -e

mkdir -p /etc/haproxy/certs

openssl req -x509 -nodes -days 3650 \
  -newkey rsa:2048 \
  -subj "/CN=localhost" \
  -keyout /etc/haproxy/certs/dummy.key \
  -out /etc/haproxy/certs/dummy.crt

cat /etc/haproxy/certs/dummy.crt \
    /etc/haproxy/certs/dummy.key \
    > /etc/haproxy/certs/dummy.pem

chmod 600 /etc/haproxy/certs/dummy.pem
