#Notuseing this cus it's now EIP not Public or ephemeral   
#output "ops_public_ip" {
#  value = aws_instance.ops.public_ip
#}


#################
output "ops_public_ip" {
  value = aws_eip.ops.public_ip
}


