output "ops_public_ip" {
  value = aws_instance.ops.public_ip
}

output "ops_instance_id" {
  value = aws_instance.ops.id
}
