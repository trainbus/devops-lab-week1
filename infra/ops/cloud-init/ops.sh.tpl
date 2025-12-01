#!/bin/bash
set -xe

ADMIN_IP="${admin_ui_ip}"
WORDPRESS_IP="${wordpress_ip}"
NODE_IP="${node_app_ip}"
DOMAIN="ops.onwuachi.com"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/haproxy.pem"

echo ">>> Updating system..."
apt update -y
apt install -y nginx haproxy certbot

echo ">>> Stopping services to free port 80..."
systemctl stop haproxy || true
systemctl stop nginx || true

# ---------------------------------------------------------
# 1. ONLY REQUEST A CERT IF IT DOESN'T ALREADY EXIST
# ---------------------------------------------------------
if [ ! -f "$CERT_PATH" ]; then
  echo ">>> No certificate found. Requesting new Let's Encrypt certificate..."
  certbot certonly --standalone \
    -d $DOMAIN \
    --non-interactive \
    --agree-tos \
    -m onwuabus@gmail.com

  echo ">>> Creating HAProxy PEM bundle..."
  cat \
    /etc/letsencrypt/live/$DOMAIN/privkey.pem \
    /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
      > $CERT_PATH

  chmod 600 $CERT_PATH
else
  echo ">>> Certificate already exists. Skipping certbot."
fi

# ---------------------------------------------------------
# 2. Write updated HAProxy configuration
# ---------------------------------------------------------
echo ">>> Writing HAProxy config..."
cat <<EOF >/etc/haproxy/haproxy.cfg
global
  log /dev/log local0
  maxconn 2000
  daemon

defaults
  log     global
  mode    http
  option  httplog
  option  dontlognull
  timeout connect 5s
  timeout client  50s
  timeout server  50s

frontend http_in
  bind *:80
  redirect scheme https code 301 if !{ ssl_fc }

frontend https_in
  bind *:443 ssl crt $CERT_PATH
  mode http

  acl is_api    path_beg /api
  acl is_admin  path_beg /admin
  acl is_wp     path_beg /wp
  acl is_app    path_beg /app

  use_backend api_backend      if is_api
  use_backend admin_backend    if is_admin
  use_backend wp_backend       if is_wp
  use_backend app_backend      if is_app

  default_backend local_nginx_backend

backend local_nginx_backend
  server local1 127.0.0.1:8080 check

backend admin_backend
  server admin01 ${ADMIN_IP}:80 check

backend wp_backend
  server wp01 ${WORDPRESS_IP}:80 check

backend api_backend
  server api01 ${NODE_IP}:3000 check

backend app_backend
  server app01 ${NODE_IP}:3000 check

listen stats
  bind *:8404
  stats enable
  stats uri /stats
EOF

# ---------------------------------------------------------
# 3. Start Services
# ---------------------------------------------------------
echo ">>> Starting HAProxy..."
systemctl start haproxy
systemctl enable haproxy

echo ">>> Finished provisioning ops server (cloud-init complete)."
