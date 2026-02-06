provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./module/networks"
}

module "secure" {
  source = "./module/security"
  vpc_id = module.vpc.vpc_id
}

resource "aws_instance" "bastion_host" {
  ami                    = var.b_ami
  instance_type          = var.b_instance_type
  subnet_id              = module.vpc.public_subnet_id
  vpc_security_group_ids = [module.secure.bastion_sg_id]
  key_name               = aws_key_pair.one_key_fit_all.key_name

  tags = { Name = "Bastion Host" }

  # This is not the best Practice, just testing ==> use SSH agent forwarding instead
  provisioner "file" {
    source      = pathexpand("~/.ssh/my-host")
    destination = "/home/ec2-user/my-host"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand("~/.ssh/my-host"))
      host        = self.public_ip
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/my-host"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand("~/.ssh/my-host"))
      host        = self.public_ip
    }
  }
}

# To ssh into your private instance => ssh -i /home/ec2-user/my-host ec2-user@


resource "aws_key_pair" "one_key_fit_all" {
  key_name   = "Bastion_Security_Key"
  public_key = file(var.bastion_key)
}

# ------------------------ Private Instance -------------------------

resource "aws_instance" "private_host" {
  ami                    = var.p_ami
  instance_type          = var.p_instance_type
  subnet_id              = module.vpc.private_subnet_id
  vpc_security_group_ids = [module.secure.private_sg_id]
  key_name               = aws_key_pair.one_key_fit_all.key_name

  tags = { Name = "Private Host" }
}



