#!/bin/bash
set -e

apt-get update
apt-get install -y \
  ca-certificates \
  curl \
  unzip \
  gnupg \
  lsb-release
