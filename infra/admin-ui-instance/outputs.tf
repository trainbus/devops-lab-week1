output "admin_ui_public_ip" {
  value = aws_instance.admin_ui.public_ip
}

output "admin_ui_public_dns" {
  value = aws_instance.admin_ui.public_dns
}

output "admin_ui_instance_id" {
  value = aws_instance.admin_ui.id
}

output "admin_ui_private_ip" {
  value = aws_instance.admin_ui.private_ip
}
