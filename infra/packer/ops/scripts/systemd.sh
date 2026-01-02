#!/bin/bash
set -e

cat <<EOF > /etc/systemd/system/hugo-nginx.service
[Unit]
Description=Hugo Static Site (nginx)
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker run --name hugo-nginx --rm \
  -p 127.0.0.1:8080:80 \
  -v /opt/hugo/site/public:/usr/share/nginx/html:ro \
  nginx:alpine
ExecStop=/usr/bin/docker stop hugo-nginx
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable hugo-nginx
systemctl enable haproxy
