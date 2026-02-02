terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aws" {
  region = "eu-west-1"
}


# Create VPC

module "vpc" {
  source = "./module/networks"
}

module "security" {
  source = "./module/security"
  vpc_id = module.vpc.vpc_id
}




# Create IAM role trusted by EC2 (AssumeRole)
resource "aws_iam_role" "ec2_role" {
  name = "testEC2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "EC2_AssumeRole"
  }
}

# Instance Profile required to attach the role to EC2
resource "aws_iam_instance_profile" "test_profile" {
  name = "EC2_S3_Readonly_Profile"
  role = aws_iam_role.ec2_role.name
}


# Create a Custom IAM Policy for S3 Readonly bucket
resource "aws_iam_policy" "s3_readonly_bucket" {
  name = "S3-readonly-${var.bucket_name}"
  # path        = "/" --- in terraform registry this is optional
  description = "My s3-readonly policy ${var.bucket_name} (Can't delete)"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow listing the bucket first. this is required for s3
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },

      # Allow reading the objects in the bucket
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "attach_s3_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_readonly_bucket.arn
}


# Attach your instance profile to EC2
resource "aws_instance" "security_instance" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [module.security.security_group_id]
  subnet_id              = module.vpc.public_subnet_ids[0]
}

resource "aws_key_pair" "deployer" {
  key_name   = "security_key"
  public_key = file(var.p_key)
}
