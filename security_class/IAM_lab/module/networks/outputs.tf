output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_ids" {
  value = [for f in aws_subnet.main_sub : f.id if f.map_public_ip_on_launch]
}
