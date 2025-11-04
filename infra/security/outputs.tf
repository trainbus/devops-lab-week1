output "wordpress_sg_id" {
  value = aws_security_group.wordpress_sg.id
}

output "ops_sg_id" {
  value = aws_security_group.ops_sg.id
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}