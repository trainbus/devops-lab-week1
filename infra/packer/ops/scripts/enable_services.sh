#!/usr/bin/env bash
set -e

systemctl enable haproxy
systemctl enable certbot.timer
