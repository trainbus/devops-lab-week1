#!/usr/bin/env bash
set -e

systemctl enable haproxy
#systemctl enable acme-http.service
systemctl enable certbot.timer
