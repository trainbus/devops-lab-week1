output "ec2_public_ip" {
  description = "Public IP of the app EC2 instance"
  value       = module.app.app_public_ip
}

output "web_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = module.web.web_public_ip
}

output "wordpress_public_ip" {
  value = module.wordpress.wordpress_public_ip
}

output "ops_ip" {
  value = module.ops.ops_public_ip
}

output "app_instance_id" {
  value = module.app.app_instance_id
}

output "app_public_dns" {
  value = module.app.app_public_dns
}

output "admin_ui_public_ip" {
  value = module.admin_ui.admin_ui_public_ip
}

output "admin_ui_instance_id" {
  value = module.admin_ui.admin_ui_instance_id
}
