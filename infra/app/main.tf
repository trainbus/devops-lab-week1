data "aws_ssm_parameter" "node_api_ami" {
  name = "/devopslab/ami/node-api"
}

resource "aws_instance" "node_api" {
  ami                    = data.aws_ssm_parameter.node_api_ami.value
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [var.ops_sg_id]

  user_data = templatefile("${path.module}/cloud-init/node-api.sh.tpl", {
    aws_region     = var.aws_region
    aws_account_id = var.aws_account_id
    ecr_repo_node  = var.ecr_repo_node
    image_tag      = var.image_tag
    mongo_uri      = var.mongo_uri
  })

  tags = {
    Name        = var.ec2_name
    Environment = "dev"
    Owner       = "derrick"
  }
}