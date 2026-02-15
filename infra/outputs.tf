output "ec2_public_ip" {
  description = "Public IP of the app EC2 instance"
  value       = var.enable_node_api ? module.app[0].app_public_ip : null
}

output "web_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = var.enable_web ? module.web[0].web_public_ip : null
}

output "wordpress_public_ip" {
  value = var.enable_wordpress ? module.wordpress[0].wordpress_public_ip : null
}

output "ops_ip" {
  value = module.ops.ops_public_ip
}

output "app_instance_id" {
  value = var.enable_node_api ? module.app[0].app_instance_id : null
}

output "app_public_dns" {
  value = var.enable_node_api ? module.app[0].app_public_dns : null
}

output "admin_ui_public_ip" {
  value = var.enable_admin_ui ? module.admin_ui[0].admin_ui_public_ip : null
}

output "admin_ui_instance_id" {
  value = var.enable_admin_ui ? module.admin_ui[0].admin_ui_instance_id : null
}