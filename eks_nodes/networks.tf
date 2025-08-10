resource "aws_vpc" "eks_network" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "EKS-VPC"
  }
}

resource "aws_subnet" "eks_subnet" {
  count                   = 4
  vpc_id                  = aws_vpc.eks_network.id
  cidr_block              = "10.0.${count.index + 5}.0/24"
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = count.index < 2 ? true : false # Enable for the first subnet (index 0)

  // map_public_ip_on_launch = count.index == 0 ? true : false checks if the current subnet's index is 0. 
  // If it is (the first subnet), map_public_ip_on_launch is set to true. Otherwise, it's set to false.

  tags = {
    Name                                            = "eks-public-${count.index + 1}"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

}

# resource "aws_subnet" "eks_subnet_private" {
#   count             = 2
#   vpc_id            = aws_vpc.eks_network.id
#   cidr_block        = "10.0.${count.index + 10}.0/24"
#   availability_zone = element(var.availability_zone, count.index)

#   tags = {
#     Name                                            = "eks-private-${count.index + 1}"
#     "kubernetes.io/role/elb"                        = "1"
#     "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
#   }
# }

resource "aws_internet_gateway" "eks_ig" {
  vpc_id = aws_vpc.eks_network.id
}


resource "aws_route_table" "eks_rt" {
  vpc_id = aws_vpc.eks_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_ig.id
  }
}

resource "aws_route_table_association" "eks_rt_association" {
  count          = length(local.public_subnets)
  subnet_id      = local.public_subnets[count.index]
  route_table_id = aws_route_table.eks_rt.id
}

resource "aws_eip" "eks_private_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "eks_ng_private_nat" {
  subnet_id         = local.public_subnets[0]
  allocation_id     = aws_eip.eks_private_ip.id
  connectivity_type = "public"
}

resource "aws_route_table" "eks_private_rt" {
  vpc_id = aws_vpc.eks_network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_ng_private_nat.id
  }
}

resource "aws_route_table_association" "eks_private_rt_association" {
  count          = length(local.private_subnets)
  subnet_id      = local.private_subnets[count.index]
  route_table_id = aws_route_table.eks_private_rt.id
}



resource "aws_security_group" "eks_vpc_sg" {
  name   = "eks_vpc_security_group"
  vpc_id = aws_vpc.eks_network.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_vpc_ingress" {
  security_group_id = aws_security_group.eks_vpc_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "eks_vpc_https_ingress" {
  security_group_id = aws_security_group.eks_vpc_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "eks_vpc_ssh" {
  security_group_id = aws_security_group.eks_vpc_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "eks_vpc_egress" {
  security_group_id = aws_security_group.eks_vpc_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

