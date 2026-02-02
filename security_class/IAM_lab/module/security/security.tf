# EC2 SG
resource "aws_security_group" "instance_sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "instance_http" {
  security_group_id = aws_security_group.instance_sg.id

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
  #referenced_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "instance_ssh" {
  security_group_id = aws_security_group.instance_sg.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "instance_egress" {
  security_group_id = aws_security_group.instance_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

