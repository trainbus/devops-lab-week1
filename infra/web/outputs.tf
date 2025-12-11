output "web_public_ip" {
  description = "Public IP of Onwuachi Web Server"
  value       = aws_instance.web.public_ip
}

output "web_private_ip" {
  value = aws_instance.web.private_ip
}
