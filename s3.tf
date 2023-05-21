resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_path
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}