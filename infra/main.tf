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

resource "aws_instance" "app" {
  ami             = "ami-04a81a99f5ec58529" # Ubuntu 22.04 LTS us-east-1
  instance_type   = "t2.micro"
  key_name        = var.key_name
  security_groups = [data.aws_security_group.app_sg.name]

user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io awscli
              systemctl start docker
              systemctl enable docker

              # Login to ECR
              aws ecr get-login-password --region ${var.aws_region} | \
              docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
              

              # Wait for Docker to initialize
              sleep 10


              # Pull & run the container
              docker run -d -p 3000:3000 ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest
EOF

  tags = {
    Name = "DevOpsLabApp"
  }
}

