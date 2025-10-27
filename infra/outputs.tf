output "ec2_public_ip" {
  description = "Public IP of the app EC2 instance"
  value       = aws_instance.app.public_ip
}

output "web_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = module.web.web_public_ip
}

output "wordpress_ip" { value = module.wordpress.wordpress_public_ip }
output "ops_ip" { value = module.ops.ops_public_ip }