terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "eks_ssh_key" {
  key_name   = "eks-terraform-key"
  public_key = var.public_key
}
