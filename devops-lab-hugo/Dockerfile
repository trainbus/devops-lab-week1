# hugo/Dockerfile
FROM hugomods/hugo:exts-non-root
WORKDIR /src
COPY . .
# When running as a container on ops we will run server; during deploy we can build static if preferred
CMD ["server", "-D", "--bind", "0.0.0.0", "--port", "1313"]
