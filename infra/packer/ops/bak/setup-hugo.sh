#!/usr/bin/env bash
set -e

mkdir -p /opt/hugo/site
cd /opt/hugo/site

# Copy site source (from packer file provisioner)
# hugo new site already done locally

docker run --rm \
  -v /opt/hugo/site:/site \
  -w /site \
  klakegg/hugo:ext \
  --minify
