#!/bin/bash
set -e

cp /tmp/systemd/* /etc/systemd/system/
systemctl daemon-reexec
systemctl daemon-reload

systemctl enable ops.target
systemctl enable certbot.timer

