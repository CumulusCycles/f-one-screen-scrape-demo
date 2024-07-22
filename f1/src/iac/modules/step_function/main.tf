module "stepFunctIAM" {
  source               = "./modules/iam"
  bucket_name          = var.bucket_name
  resource_name_prefix = var.resource_name_prefix

  lambda_iam_role_path = var.lambda_iam_role_path

  step_funct_iam_policy_path = var.step_funct_iam_policy_path
  step_funct_iam_role_path   = var.step_funct_iam_role_path
}

module "lambdaFunction" {
  source               = "./modules/lambda"
  resource_name_prefix = var.resource_name_prefix

  step_funct_lambda_iam_role_arn = module.stepFunctIAM.step_funct_lambda_iam_role_arn

  path_to_source_file = var.path_to_source_file
  path_to_artifact    = var.path_to_artifact
  function_name       = var.function_name
  function_handler    = var.function_handler
  memory_size         = var.memory_size
  timeout             = var.timeout
  runtime             = var.runtime

  depends_on = [module.stepFunctIAM]
}

module "stepFunct" {
  source               = "./modules/step_funct"
  resource_name_prefix = var.resource_name_prefix

  step_funct_step_funct_iam_role_arn = module.stepFunctIAM.step_funct_step_funct_iam_role_arn
  lambda_arn                         = module.lambdaFunction.lambda_arn

  aws_batch_job_def_arn   = var.aws_batch_job_def_arn
  aws_batch_job_queue_arn = var.aws_batch_job_queue_arn

  depends_on = [module.lambdaFunction]
}