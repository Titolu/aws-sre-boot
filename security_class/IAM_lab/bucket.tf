# Create S3 bucket

resource "aws_s3_bucket" "security_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Test"
  }
}

resource "aws_s3_object" "object" {
  depends_on = [aws_s3_bucket.security_bucket]
  bucket     = var.bucket_name
  key        = "myCV.pdf"
  source     = "${path.module}/files/myCV.pdf"
}
