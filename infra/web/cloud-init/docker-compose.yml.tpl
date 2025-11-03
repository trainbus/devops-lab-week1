version: '3.8'
services:
  node_app:
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo_node}:latest
    container_name: node_app
    restart: always
    ports:
      - "3000:3000"
    environment:
      - MONGO_URI=${MONGO_URI}

  go_api:
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo_go}:latest
    container_name: go_api
    restart: always
    ports:
      - "4000:4000"

  wordpress:
    image: ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo_wordpress}:latest
    container_name: wordpress
    restart: always
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}

  haproxy:
    image: haproxy:latest
    container_name: haproxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
