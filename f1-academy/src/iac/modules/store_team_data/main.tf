module "teamsDataDB" {
  source             = "./modules/teams_db"
  teams_data_db_name = var.teams_data_db_name
}

module "driverssDataDB" {
  source               = "./modules/drivers_db"
  drivers_data_db_name = var.drivers_data_db_name
}

module "lambdaIAM" {
  source                 = "./modules/iam"
  lambda_iam_policy_name = var.lambda_iam_policy_name
  lambda_iam_policy_path = var.lambda_iam_policy_path
  lambda_iam_role_name   = var.lambda_iam_role_name
  lambda_iam_role_path   = var.lambda_iam_role_path
}

module "requestsLayer" {
  source                          = "./modules/requests_layer"
  path_to_requests_layer_source   = var.path_to_requests_layer_source
  path_to_requests_layer_artifact = var.path_to_requests_layer_artifact
  path_to_requests_layer_filename = var.path_to_requests_layer_filename
  requests_layer_name             = var.requests_layer_name
  compatible_layer_runtimes       = var.compatible_layer_runtimes
  compatible_architectures        = var.compatible_architectures
}

module "lambdaFunction" {
  source              = "./modules/lambda"
  lambda_iam_role_arn = module.lambdaIAM.lambda_iam_role_arn
  path_to_source_file = var.path_to_source_file
  path_to_artifact    = var.path_to_artifact
  function_name       = var.function_name
  function_handler    = var.function_handler
  memory_size         = var.memory_size
  timeout             = var.timeout
  runtime             = var.runtime
  lambda_layer_arns   = [module.requestsLayer.requests_layer_arn]
}

module "assetBucketFolders" {
  source     = "./modules/s3"
  bucket_id  = var.bucket_id
  lambda_arn = module.lambdaFunction.lambda_arn

  depends_on = [module.lambdaFunction]
}