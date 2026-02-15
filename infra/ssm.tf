############################################
# SSM PARAMETERS FOR OPS LOAD BALANCER (root)
# This file must live at infra/ssm.tf (root)
# It depends on module.app / module.admin_ui / module.web outputs
############################################

resource "aws_ssm_parameter" "node_api_ip" {
  count       = var.enable_node_api ? 1 : 0
  name        = "/ops/node_api_ip"
  description = "Private IP for Node API (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value     = module.app[0].app_private_ip
  overwrite = true

  tags = {
    Component = "ops"
    Service   = "node-api"
  }
}


resource "aws_ssm_parameter" "admin_ui_url" {
  count       = var.enable_admin_ui ? 1 : 0
  name        = "/ops/admin_ui"
  description = "Private IP:port for Admin UI (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value = "${module.admin_ui[0].admin_ui_private_ip}:80"

  tags = {
    Component = "ops"
    Service   = "admin-ui"
  }
}

resource "aws_ssm_parameter" "hugo_url" {
  count       = var.enable_web ? 1 : 0
  name        = "/ops/hugo"
  description = "Private IP:port for Hugo site (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value = "${module.web[0].web_private_ip}:80"

  tags = {
    Component = "ops"
    Service   = "hugo"
  }
}

output "ssm_ops_parameters" {
  description = "SSM parameter names for ops HAProxy"
  value = {
    #node_api = aws_ssm_parameter.node_api_url.name
    #admin_ui = aws_ssm_parameter.admin_ui_url.name
    #hugo     = aws_ssm_parameter.hugo_url.name
    node_api = var.enable_node_api ? aws_ssm_parameter.node_api_ip[0].name : null
    admin_ui = var.enable_admin_ui ? aws_ssm_parameter.admin_ui_url[0].name : null
    hugo     = var.enable_web ? aws_ssm_parameter.hugo_url[0].name : null
  }
}
