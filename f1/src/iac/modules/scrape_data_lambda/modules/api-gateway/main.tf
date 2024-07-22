resource "aws_api_gateway_rest_api" "cc-f-one-scrape-api" {
  name        = "cc-f-one-scrape-api"
  description = "Serverless Application using Terraform"
}

resource "aws_lambda_permission" "api-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.cc-f-one-scrape-api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "api-resource" {
  rest_api_id = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  parent_id   = aws_api_gateway_rest_api.cc-f-one-scrape-api.root_resource_id
  path_part   = "scrape"
}

resource "aws_api_gateway_method" "api-proxy-method" {
  rest_api_id   = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  resource_id   = aws_api_gateway_resource.api-resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api-lambda-integration" {
  rest_api_id             = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  resource_id             = aws_api_gateway_method.api-proxy-method.resource_id
  http_method             = aws_api_gateway_method.api-proxy-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}

resource "aws_api_gateway_method" "api-proxy-root-method" {
  rest_api_id   = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  resource_id   = aws_api_gateway_rest_api.cc-f-one-scrape-api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api-lambda-root-integration" {
  rest_api_id             = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  resource_id             = aws_api_gateway_method.api-proxy-root-method.resource_id
  http_method             = aws_api_gateway_method.api-proxy-root-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}

resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    aws_api_gateway_integration.api-lambda-integration,
    aws_api_gateway_integration.api-lambda-root-integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.cc-f-one-scrape-api.id
  stage_name  = "dev"
}