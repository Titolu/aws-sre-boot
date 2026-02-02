# Create S3 bucket

resource "aws_s3_bucket" "security_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Test"
  }
}

