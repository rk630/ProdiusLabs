resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
}
resource "aws_s3_bucket_acl" "pl-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.bucket.id
  acl ="private"
}