module "shared" {
  source         = "./shared"
  key_name       = var.key_name
  aws_account_id = var.aws_account_id
  admin_ip       = var.admin_ip
}

module "security" {
  source   = "./security"
  vpc_id   = module.shared.vpc_id
  admin_ip = var.admin_ip
}

module "web" {
  source               = "./web"
  vpc_id               = module.shared.vpc_id
  subnet_id            = element(module.shared.public_subnets, 0)
  iam_instance_profile = module.shared.iam_instance_profile
  key_name             = var.key_name
  aws_account_id       = var.aws_account_id
  aws_region           = var.aws_region
  ec2_name_oweb        = var.ec2_name_oweb
  ecr_repo_node        = var.ecr_repo
  ecr_repo_go          = "hello-docker-go"
  ecr_repo_wordpress   = "wordpress"
  mongo_uri            = var.mongo_uri # ✅ This will get updated when aws secrets is enabled for now save $$$
  web_sg_id            = module.security.web_sg_id
}

module "ops" {
  source               = "./ops"
  vpc_id               = module.shared.vpc_id
  subnet_id            = element(module.shared.public_subnets, 1)
  iam_instance_profile = module.shared.iam_instance_profile
  key_name             = var.key_name
  ec2_name             = "ops-01"
  admin_ip             = var.admin_ip
  ops_sg_id            = module.security.ops_sg_id # if you expose it
}

module "api" {
  source               = "./api"
  vpc_id               = module.shared.vpc_id
  subnet_id            = element(module.shared.public_subnets, 0)
  iam_instance_profile = module.shared.iam_instance_profile
  mongo_uri            = var.mongo_uri
  key_name             = var.key_name
  ec2_name             = "api-01"
  admin_ip             = var.admin_ip
  ops_sg_id            = module.security.ops_sg_id
}

module "wordpress" {
  source           = "./wordpress"
  vpc_id           = module.shared.vpc_id
  subnet_id        = element(module.shared.public_subnets, 0)
  key_name         = var.key_name
  ssm_profile_name = module.shared.iam_instance_profile
  ec2_name         = "wordpress-01"
  admin_ip         = var.admin_ip
  wordpress_sg_id  = module.security.wordpress_sg_id # if you expose it revert #aws_security_group.wordpress_sg.id
}

module "app" {
  source               = "./app"
  vpc_id               = module.shared.vpc_id
  subnet_id            = element(module.shared.public_subnets, 0)
  key_name             = var.key_name
  aws_account_id       = var.aws_account_id
  iam_instance_profile = module.shared.iam_instance_profile
  aws_region           = var.aws_region
  ec2_name             = "Node-app-01"
  ecr_repo             = var.ecr_repo
  admin_ip             = var.admin_ip
  mongo_uri            = var.mongo_uri
  ops_sg_id            = module.security.ops_sg_id
  enable_ssm           = true
}

