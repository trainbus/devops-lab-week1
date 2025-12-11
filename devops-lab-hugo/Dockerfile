# hugo Dockerfile - serve in server mode for preview or build static files
FROM hugomods/hugo:exts-non-root
WORKDIR /src
COPY . .
# If you want to serve: (bind 0.0.0.0 so HAProxy can reach it)
CMD ["server", "-D", "--bind", "0.0.0.0", "--baseURL", "http://localhost"]
# Alternatively to build static files:
# RUN hugo --minify

