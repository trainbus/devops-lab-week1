data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "ops" {
  
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.ops_sg_id]
  iam_instance_profile   = var.iam_instance_profile

  user_data_replace_on_change = true
  
  user_data = templatefile("${path.module}/cloud-init/ops.sh.tpl", {
    admin_ui_ip  = var.admin_ui_ip
    wordpress_ip = var.wordpress_ip
    node_app_ip  = var.node_app_ip
  })

  tags = {
    Name        = var.ec2_name
    Environment = "dev"
    Owner       = "derrick"
    Role        = "ops"
  }
}
