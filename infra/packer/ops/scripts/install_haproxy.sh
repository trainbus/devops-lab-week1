#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "=== Installing HAProxy (AMI-safe) ==="

apt-get update
apt-get install -y haproxy certbot python3

mkdir -p /etc/haproxy
mkdir -p /etc/haproxy/certs

cat <<'EOF' >/etc/haproxy/haproxy.cfg
global
  daemon
  maxconn 2048
  log /dev/log local0

defaults
  mode http
  log global
  option httplog
  timeout connect 5s
  timeout client  50s
  timeout server  50s

frontend http_in
  bind *:80
  http-request redirect scheme https code 301

frontend https_in
  bind *:443 ssl crt /etc/haproxy/certs/onwuachi.com.pem
  default_backend dummy_backend

backend dummy_backend
  http-request return status 503 content-type text/plain lf-string "Service warming up... Platform engineering takes time."
EOF

# Enable only (runtime start)
systemctl enable haproxy
systemctl stop haproxy || true

echo "=== HAProxy AMI provisioning complete ==="

