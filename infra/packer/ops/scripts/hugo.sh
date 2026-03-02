#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "==> Preparing Hugo directory"
rm -rf /opt/hugo
mkdir -p /opt/hugo/site

echo "==> Creating minimal Hugo config"
cat <<EOF > /opt/hugo/site/hugo.toml
baseURL = "https://onwuachi.com/"
languageCode = "en-us"
title = "Onwuachi Platform"
EOF

echo "==> Creating minimal layout"
mkdir -p /opt/hugo/site/layouts/_default

cat <<EOF > /opt/hugo/site/layouts/index.html
<!DOCTYPE html>
<html>
<head>
  <title>onwuachi.com</title>
</head>
<body>
  <h1>Hugo is working</h1>
</body>
</html>
EOF

echo "==> Building Hugo site"
docker run --rm \
  -v /opt/hugo/site:/site \
  -w /site \
  klakegg/hugo:ext \
  --destination /site/public \
  --minify

echo "==> Hugo build complete"
