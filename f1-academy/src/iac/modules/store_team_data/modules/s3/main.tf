# Bucket folders
resource "aws_s3_object" "season_folder" {
  bucket       = var.bucket_id
  key          = "2024/"
  content_type = "application/x-directory"
}
resource "aws_s3_object" "data_folder" {
  bucket       = var.bucket_id
  key          = "/2024/data/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.season_folder]
}
resource "aws_s3_object" "assets_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.season_folder]
}
resource "aws_s3_object" "teams_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/teams/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.assets_folder]
}
resource "aws_s3_object" "teams_logos_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/teams/logos/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.teams_folder]
}
resource "aws_s3_object" "teams_images_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/teams/images/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.teams_folder]
}
resource "aws_s3_object" "teams_flags_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/teams/flags/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.teams_folder]
}
resource "aws_s3_object" "drivers_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/drivers/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.assets_folder]
}
resource "aws_s3_object" "drivers_images_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/drivers/images/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.drivers_folder]
}
resource "aws_s3_object" "drivers_flags_folder" {
  bucket       = var.bucket_id
  key          = "/2024/assets/drivers/flags/"
  content_type = "application/x-directory"

  depends_on = [aws_s3_object.drivers_folder]
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowLambdaTriggerFromS3"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_id}"
}

resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = var.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "2024/data/"
  }

  depends_on = [aws_lambda_permission.s3_lambda_permission]
}