#!/bin/bash
set -eux

# Runtime wiring only
hostnamectl set-hostname ops-node || true

# Start backend services explicitly
systemctl start hugo.service
systemctl start haproxy.service || true
