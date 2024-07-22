data "archive_file" "scrape" {
  type        = "zip"
  source_file = var.path_to_source_file
  output_path = var.path_to_artifact
}

resource "aws_lambda_function" "f_one_store_lambda" {
  # filename      = var.path_to_artifact
  filename      = data.archive_file.scrape.output_path
  function_name = var.function_name
  role          = var.lambda_iam_role_arn
  handler       = var.function_handler

  memory_size = var.memory_size
  timeout     = var.timeout

  # source_code_hash = filebase64sha256(var.path_to_artifact)
  source_code_hash = data.archive_file.scrape.output_base64sha256

  runtime = var.runtime

  layers = var.lambda_layer_arns
}
