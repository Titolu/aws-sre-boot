output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.main_sub[0].id
  #[for f in aws_subnet.main_sub : f.id if f.map_public_ip_on_launch]
}

output "private_subnet_id" {
  value = aws_subnet.main_sub[1].id
  #[ for sub, s in aws_aws_subnet.main_sub : s.id if sub >= local.public_count  ]
}
