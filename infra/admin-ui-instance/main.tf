data "aws_ssm_parameter" "admin_ui_ami" {
  name = "/devopslab/ami/admin-ui"
}

resource "aws_instance" "admin_ui" {
  ami                    = data.aws_ssm_parameter.admin_ui_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [var.sg_id]

  user_data = templatefile("${path.module}/cloud-init/admin-ui.sh.tpl", {
    aws_region = var.aws_region
  })

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
    Owner       = "derrick"
  }
}

