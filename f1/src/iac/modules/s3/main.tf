# Asset Bucket
resource "aws_s3_bucket" "f_one_asset_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

# Bucket folders
resource "aws_s3_object" "data_folder" {
  bucket       = aws_s3_bucket.f_one_asset_bucket.id
  key          = "data/"
  content_type = "application/x-directory"
  depends_on   = [aws_s3_bucket.f_one_asset_bucket]
}
resource "aws_s3_object" "races_data_folder" {
  bucket       = aws_s3_bucket.f_one_asset_bucket.id
  key          = "/data/races/"
  content_type = "application/x-directory"
  depends_on   = [aws_s3_object.data_folder]
}
resource "aws_s3_object" "drivers_data_folder" {
  bucket       = aws_s3_bucket.f_one_asset_bucket.id
  key          = "/data/drivers/"
  content_type = "application/x-directory"
  depends_on   = [aws_s3_object.data_folder]
}
resource "aws_s3_object" "teams_data_folder" {
  bucket       = aws_s3_bucket.f_one_asset_bucket.id
  key          = "/data/teams/"
  content_type = "application/x-directory"
  depends_on   = [aws_s3_object.data_folder]
}

resource "aws_s3_bucket_notification" "f_one_asset_bucket_notification" {
  bucket      = aws_s3_bucket.f_one_asset_bucket.id
  eventbridge = true
  depends_on  = [aws_s3_bucket.f_one_asset_bucket]
}