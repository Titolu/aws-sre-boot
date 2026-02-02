output "public_subnet" {
  value = aws_instance.security_instance.public_ip
}
