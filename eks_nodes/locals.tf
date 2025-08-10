locals {
  private_subnets = [
    for s in aws_subnet.eks_subnet : s.id
    if s.map_public_ip_on_launch == false
  ]

  public_subnets = [
    for s in aws_subnet.eks_subnet : s.id
    if s.map_public_ip_on_launch == true
  ]
}
