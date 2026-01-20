#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

AWS_REGION="${aws_region}"
AWS_ACCOUNT="${aws_account_id}"
REPO="${ecr_repo_node}"
IMAGE_TAG="${image_tag:-latest}"

# Ensure docker exists
apt-get update -y || true
apt-get install -y docker.io jq || true
systemctl enable --now docker || true
usermod -aG docker ubuntu || true

# Login to ECR
/usr/bin/aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

IMAGE_URI="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO}:${IMAGE_TAG}"
echo "Pulling ${IMAGE_URI}"
for i in 1 2 3 4 5; do
  docker pull "${IMAGE_URI}" && break
  sleep 5
done

# Example run instructions (customize per-service)
# Admin UI: expose 8080 to host
# Node API: expose 3000 to host
# Hugo: bind 1313 or serve built static on 80

case "${REPO}" in
  devops-lab-admin-ui|admin-ui)
    docker rm -f admin-ui || true
    docker run -d --name admin-ui -p 8080:80 --restart unless-stopped "${IMAGE_URI}"
    ;;
  devops-lab-hugo|hugo)
    docker rm -f hugo || true
    docker run -d --name hugo -p 1313:1313 --restart unless-stopped "${IMAGE_URI}"
    ;;
  hello-docker-node|node-api)
    docker rm -f nodeapi || true
    docker run -d --name nodeapi -p 3000:3000 -e MONGO_URI="${mongo_uri}" --restart unless-stopped "${IMAGE_URI}"
    ;;
  *)
    echo "Unknown REPO ${REPO}, running generic container"
    docker rm -f app || true
    docker run -d --name app -p 8080:80 --restart unless-stopped "${IMAGE_URI}"
    ;;
esac

echo "=== containers started ==="
