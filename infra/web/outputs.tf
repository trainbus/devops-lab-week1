output "web_public_ip" {
  description = "Public IP of Onwuachi Web Server"
  value       = aws_instance.web.public_ip
}
