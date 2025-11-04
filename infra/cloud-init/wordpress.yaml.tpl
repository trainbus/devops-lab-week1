#cloud-config
runcmd:
  - apt-get update -y
  - apt-get install -y docker.io awscli
  - systemctl start docker
  - systemctl enable docker
  - usermod -aG docker ubuntu
  - aws ecr get-login-password --region ${aws_region} | \
    docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com
  - docker pull ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo}:latest
  - docker run -d -p 80:80 ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${ecr_repo}:latest