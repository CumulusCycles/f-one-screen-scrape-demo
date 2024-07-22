# Asset Bucket
resource "aws_s3_bucket" "f_one_academy_asset_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Bucket folders
resource "aws_s3_object" "season_folder" {
  bucket       = aws_s3_bucket.f_one_academy_asset_bucket.id
  key          = "2024/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_bucket.f_one_academy_asset_bucket]
}
resource "aws_s3_object" "data_folder" {
  bucket       = aws_s3_bucket.f_one_academy_asset_bucket.id
  key          = "/2024/data/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.season_folder]
}
