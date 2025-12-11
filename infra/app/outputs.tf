output "app_public_ip" {
  value = aws_instance.node_api.public_ip
}

output "app_instance_id" {
  value = aws_instance.node_api.id
}

output "app_public_dns" {
  value = aws_instance.node_api.public_dns
}

output "app_private_ip" {
  value = aws_instance.node_api.private_ip
}

