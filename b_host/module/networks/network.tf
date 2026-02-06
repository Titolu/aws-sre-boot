resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

data "aws_availability_zones" "sub_az" {
  state = "available"
}

resource "aws_subnet" "main_sub" {
  count                   = local.total_subnet
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.subnet_ip[count.index].subnet_cidr                       #"10.0.${count.index + 1}.0/27"
  availability_zone       = element(data.aws_availability_zones.sub_az.names, count.index) # iterates the list of subnets and assign each to different AZ available within the REGION
  map_public_ip_on_launch = count.index < local.public_count                               # ensures 2 subnet is assigned public IP while others will be False.

  tags = {
    Name = count.index < local.public_count ? "public-subnet-${count.index}" : "private-subnet-${count.index - local.public_count}"
  }
}

resource "aws_internet_gateway" "main_ig" {
  vpc_id = aws_vpc.main_vpc.id

  tags = { Name = "igw-${aws_vpc.main_vpc.id}" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main_nat" {
  subnet_id     = aws_subnet.main_sub[0].id
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [aws_internet_gateway.main_ig]
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_ig.id
  }

  tags = { Name = "public-rt" }
}


resource "aws_route_table_association" "main_rta" {
  count          = local.public_count # ensures one association per PublicSubnet.
  subnet_id      = aws_subnet.main_sub[count.index].id
  route_table_id = aws_route_table.main_rt.id
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = { Name = "private-rt" }
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main_nat.id
}

resource "aws_route_table_association" "nat_rt" {
  subnet_id      = aws_subnet.main_sub[1].id
  route_table_id = aws_route_table.private_rt.id
}
