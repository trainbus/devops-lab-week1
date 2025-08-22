resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH + Node app"
  vpc_id      = "vpc-0eb5fc6c2f99e5267"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                  = "ami-04a81a99f5ec58529" # Ubuntu 22.04 us-east-1
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.app_sg.name]
  key_name             = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              docker run -d -p 3000:3000 ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo}:latest
              EOF

  tags = {
    Name = "DevOpsLabApp"
  }
}
