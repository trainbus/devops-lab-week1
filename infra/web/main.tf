data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


locals {
  docker_compose_content = file("${path.module}/cloud-init/docker-compose.yml.tpl")
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.web_sg_id]
  iam_instance_profile   = var.iam_instance_profile

  user_data = templatefile("${path.module}/cloud-init/web.yaml.tpl", {
    domain                 = "onwuachi.com"
    email                  = "admin@onwuachi.com"
    aws_region             = var.aws_region
    aws_account_id         = var.aws_account_id
    ecr_repo_node          = var.ecr_repo_node
    ecr_repo_go            = var.ecr_repo_go
    ecr_repo_wordpress     = var.ecr_repo_wordpress
    mongo_uri              = var.mongo_uri
    path_module            = path.module
    docker_compose_content = local.docker_compose_content
  })

  tags = {
    Name = var.ec2_name
  }
}