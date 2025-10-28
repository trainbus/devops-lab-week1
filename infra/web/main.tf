data "aws_security_group" "ops_sg" {
  filter {
    name   = "group-name"
    values = ["ops-sg"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-0eb5fc6c2f99e5267"]
  }
}

data "aws_iam_instance_profile" "app_profile" {
  name = "devopslab-instance-profile"
}

resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ops_sg_id]
  iam_instance_profile   = var.ssm_profile_name

  user_data = templatefile("${path.module}/../cloud-init/web.yaml.tpl", {
  domain       = "onwuachi.com"
  email        = "admin@onwuachi.com"
  haproxy_cfg  = file("${path.module}/../cloud-init/haproxy.cfg")
  nginx_cfg    = file("${path.module}/../cloud-init/nginx.conf")
  html_content = "<h1>Welcome to Onwuachi.com</h1><p>DevOps KB & Links Coming Soon.</p>"
})

  tags = {
    Name = var.ec2_name_oweb
  }
}