resource "aws_lambda_function" "f_one_academy_scrape_lambda" {
  function_name = var.function_name
  role          = var.lambda_iam_role_arn

  image_uri    = var.image_uri
  package_type = var.package_type

  memory_size = var.memory_size
  timeout     = var.timeout
}
