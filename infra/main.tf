data "aws_security_group" "app_sg" {
  filter {
    name   = "group-name"
    values = ["app-sg"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-0eb5fc6c2f99e5267"]
  }
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "devopslab-instance-profile"
  role = "DevOpsLabEC2Role"
}

resource "aws_instance" "app" {
  ami             = "ami-04a81a99f5ec58529" # Ubuntu 22.04 LTS us-east-1
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [data.aws_security_group.app_sg.name]
  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

              echo "Starting EC2 provisioning..."

              apt-get update -y
              apt-get install -y ca-certificates curl gnupg unzip

              # Install Docker from Docker's official repo
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                noble stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

              systemctl start docker
              systemctl enable docker

              # Install AWS CLI v2
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              ./aws/install

              # Login to ECR
              /usr/local/bin/aws ecr get-login-password --region ${var.aws_region} | \
              docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

              # Retry Docker pull
              for i in {1..5}; do
                docker pull ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest && break
                sleep 5
              done

              # Run container
              docker run -d -p 3000:3000 ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest

              echo "Provisioning complete."
  EOF

  tags = {
    Name = "DevOpsLabApp"
  }
}