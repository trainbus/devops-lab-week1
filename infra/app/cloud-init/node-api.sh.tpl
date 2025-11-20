#!/bin/bash
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting runtime provisioning..."

IMAGE_URI="${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo_node}:${image_tag}"

echo "Logging into ECR..."
/usr/local/bin/aws ecr get-login-password --region "${aws_region}" \
  | docker login --username AWS --password-stdin "${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com"

echo "Pulling image: $IMAGE_URI"

for attempt in {1..5}; do
  docker pull "$IMAGE_URI" && break
  echo "Pull failed (attempt $attempt). Retrying..."
  sleep 5
done

echo "Tagging image locally as api:latest"
docker tag "$IMAGE_URI" api:latest

echo "Running Node API container..."
docker run -d \
  -p 3000:3000 \
  -e MONGO_URI="${mongo_uri}" \
  api:latest

echo "Runtime provisioning complete."