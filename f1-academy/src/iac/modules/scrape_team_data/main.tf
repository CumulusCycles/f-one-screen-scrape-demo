module "assetBucket" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "lambdaIAM" {
  source                 = "./modules/iam"
  lambda_iam_policy_name = var.lambda_iam_policy_name
  lambda_iam_policy_path = var.lambda_iam_policy_path
  lambda_iam_role_name   = var.lambda_iam_role_name
  lambda_iam_role_path   = var.lambda_iam_role_path
}

module "lambdaFunction" {
  source              = "./modules/lambda"
  lambda_iam_role_arn = module.lambdaIAM.lambda_iam_role_arn
  function_name       = var.function_name
  image_uri           = var.image_uri
  package_type        = var.package_type
  memory_size         = var.memory_size
  timeout             = var.timeout

  depends_on = [module.lambdaIAM]
}

module "apiGateway" {
  source        = "./modules/api-gateway"
  function_name = var.function_name
  invoke_arn    = module.lambdaFunction.invoke_arn

  depends_on = [module.lambdaFunction]
}