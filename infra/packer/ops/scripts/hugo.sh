#!/bin/bash
set -e

mkdir -p /opt/hugo/site
cd /opt/hugo

docker run --rm \
  -v /opt/hugo/site:/site \
  -w /site \
  klakegg/hugo:ext \
  new site /site || true

# Add minimal layout
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

docker run --rm \
  -v /opt/hugo/site:/site \
  -w /site \
  klakegg/hugo:ext \
  --minify
