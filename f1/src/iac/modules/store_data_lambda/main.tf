module "raceDataDB" {
  source  = "./modules/results_data_db"
  db_name = var.db_name
}

module "lambdaIAM" {
  source                 = "./modules/iam"
  bucket_name            = var.bucket_name
  lambda_iam_policy_name = var.lambda_iam_policy_name
  lambda_iam_role_name   = var.lambda_iam_role_name
  lambda_iam_role_path   = var.lambda_iam_role_path
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
  lambda_layer_arns   = var.lambda_layer_arns

  depends_on = [module.lambdaIAM]
}

module "eventBridge" {
  source            = "./modules/event_bridge"
  asset_bucket_id   = var.asset_bucket_id
  asset_bucket_path = var.asset_bucket_path
  data_file_name    = var.data_file_name
  lambda_arn        = module.lambdaFunction.lambda_arn
  lambda_name       = var.function_name

  depends_on = [module.lambdaFunction]
}