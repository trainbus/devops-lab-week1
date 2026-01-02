#!/bin/bash
set -e

# Install HAProxy
apt-get update
apt-get install -y haproxy

# Ensure cert directory exists (runtime TLS bootstrap will populate it)
mkdir -p /etc/haproxy/certs

# Write a SAFE placeholder config for AMI build
# This config MUST NOT reference real backend IPs
cat <<EOF > /etc/haproxy/haproxy.cfg
global
  daemon
  maxconn 2048
  log /dev/log local0

  ssl-default-bind-options no-sslv3 no-tlsv10 no-tlsv11
  ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
  ssl-default-bind-ciphersuites TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256

defaults
  mode http
  log global
  option httplog
  timeout connect 5s
  timeout client  50s
  timeout server  50s

frontend http_in
  bind *:80
  redirect scheme https code 301 if !{ ssl_fc }

frontend https_in
  bind *:443 ssl crt /etc/haproxy/certs/

  acl is_admin path_beg /admin
  acl is_hugo  path_beg /blog
  acl is_api   path_beg /api

  use_backend admin_backend if is_admin
  use_backend hugo_backend  if is_hugo
  use_backend api_backend   if is_api
  default_backend hugo_backend

backend admin_backend
  # Dummy backend for AMI build
  server admin 127.0.0.1:9 check disabled

backend api_backend
  # Dummy backend for AMI build
  server api 127.0.0.1:9 check disabled

backend hugo_backend
  option httpchk GET /
  # Dummy backend for AMI build
  server hugo_nginx 127.0.0.1:9 check disabled
EOF

# Validate config only — DO NOT START haproxy during AMI build
haproxy -c -f /etc/haproxy/haproxy.cfg || true

# Enable service for runtime, but keep it stopped in AMI
systemctl enable haproxy
systemctl stop haproxy || true