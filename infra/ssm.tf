############################################
# SSM PARAMETERS FOR OPS LOAD BALANCER (root)
# This file must live at infra/ssm.tf (root)
# It depends on module.app / module.admin_ui / module.web outputs
############################################

resource "aws_ssm_parameter" "node_api_ip" {
  name        = "/ops/node_api_ip"
  description = "Private IP for Node API (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value = module.app.app_private_ip
  overwrite   = true

  tags = {
    Component = "ops"
    Service   = "node-api"
  }
}


resource "aws_ssm_parameter" "admin_ui_url" {
  name        = "/ops/admin_ui"
  description = "Private IP:port for Admin UI (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value = "${module.admin_ui.admin_ui_private_ip}:80"

  tags = {
    Component = "ops"
    Service   = "admin-ui"
  }
}

resource "aws_ssm_parameter" "hugo_url" {
  name        = "/ops/hugo"
  description = "Private IP:port for Hugo site (used by OPS HAProxy)"
  type        = "SecureString"
  key_id      = "alias/aws/ssm"

  value = "${module.web.web_private_ip}:80"

  tags = {
    Component = "ops"
    Service   = "hugo"
  }
}

output "ssm_ops_parameters" {
  description = "SSM parameter names for ops HAProxy"
  value = {
    #node_api = aws_ssm_parameter.node_api_url.name
    admin_ui = aws_ssm_parameter.admin_ui_url.name
    hugo     = aws_ssm_parameter.hugo_url.name
  }
}
