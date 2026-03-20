output "websserver_instance_id" {
    value = aws_instance.my_webserver.id
  
}
output "webserver_public_ip" {
    value = aws_eip.my_static_ip.public_ip
}

output "name" {
   value = aws_instance.my_webserver.tags["Name"]
}

output "webserver_sg_id" {
    value = aws_security_group.my_webserver_sg.id
}
output "webserver_sg_arn" {
    value = aws_security_group.my_webserver_sg.arn
    description = "This is SG ARN (only for me here)"
}