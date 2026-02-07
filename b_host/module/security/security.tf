# EC2 SG
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion_sg.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = "92.17.239.230/32" # This should be your organisation/workstation IP
}

resource "aws_vpc_security_group_egress_rule" "bastion_eg_ssh" {
  security_group_id = aws_security_group.bastion_sg.id

  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_ipv4   = "10.0.2.0/24"
}


# -------------------- PRIVATE EC2 SG ----------------------------------

resource "aws_security_group" "private_sg" {
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id = aws_security_group.private_sg.id

  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_vpc_security_group_egress_rule" "private_egress" {
  security_group_id = aws_security_group.private_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

