data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.path_to_source_file
  output_path = var.path_to_artifact
}

resource "aws_lambda_function" "f_one_step_funct_lambda" {
  # filename      = var.path_to_artifact
  filename      = data.archive_file.lambda.output_path
  function_name = var.function_name
  role          = var.step_funct_lambda_iam_role_arn
  handler       = var.function_handler

  memory_size = var.memory_size
  timeout     = var.timeout

  # source_code_hash = filebase64sha256(var.path_to_artifact)
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = var.runtime
}
