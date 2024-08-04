terraform {
  required_version = "~> 1.3"

  # Uncomment after provisioning tf-state Module for Remote State Locking
  # backend "s3" {
  #   bucket         = "cc-f-one-tf-state-08-04-24v010"
  #   key            = "tf-infra/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "cc-f-one-tf-state-08-04-24v010"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

# Provision tf-state Module first (then add Remote State Locking)
module "tf-state" {
  source      = "./modules/tf-state"
  bucket_name = local.tf_state_resource_name
  table_name  = local.tf_state_resource_name
}

# Provision Bucket to hold Races/Drivers/Teams data (JSON files)
# module "assetBucket" {
#   source      = "./modules/s3"
#   bucket_name = local.asset_bucket_name
# }

# Provision ECR Repo for Scrape App Image
# module "ecrRepo" {
#   source        = "./modules/ecr_repo"
#   ecr_repo_name = local.ecr_repo_name
# }


# ##############################################################################
# Resources for using Python src for Image for Scrape Lambda Function 
# (set local.provision_with_aws_batch == false)
# ##############################################################################
# module "dockerImagePython" {
#   count = local.provision_with_aws_batch != true ? 1: 0

#   source      = "./modules/docker_image"
#   ecr_repo    = module.ecrRepo.repository_url
#   image_name  = local.common_docker_image_params.image_name
#   platform    = local.common_docker_image_params.platform
#   path_to_src = local.docker_image_params_python.path_to_src

#   depends_on = [module.ecrRepo]
# }

# module "scrapeFunction" {
#   source      = "./modules/scrape_data_lambda"
#   bucket_name = local.asset_bucket_name

#   lambda_iam_policy_name = local.scrape_lambda_params.lambda_iam_policy_name
#   lambda_iam_role_name   = local.scrape_lambda_params.lambda_iam_role_name
#   lambda_iam_role_path   = local.scrape_lambda_params.lambda_iam_role_path

#   function_name = local.scrape_lambda_params.function_name
#   package_type  = local.scrape_lambda_params.package_type
#   memory_size   = local.common_lambda_params.lambda_memory_size
#   timeout       = local.common_lambda_params.lambda_timeout
#   image_uri     = module.ecrRepo.repository_url

#   depends_on = [module.assetBucket, module.dockerImagePython]
# }
# ##############################################################################


# ##############################################################################
# Resources for using StepFunction and NodeJS src for Image for AWS Batch / ECS Scrape App
# (set local.provision_with_aws_batch == true)
# ##############################################################################
# module "dockerImageNode" {
#   count = local.provision_with_aws_batch ? 1 : 0

#   source      = "./modules/docker_image"
#   ecr_repo    = module.ecrRepo.repository_url
#   image_name  = local.common_docker_image_params.image_name
#   platform    = local.common_docker_image_params.platform
#   path_to_src = local.docker_image_params_node.path_to_src

#   depends_on = [module.ecrRepo]
# }

# module "awsBatch" {
#   source               = "./modules/aws_batch"
#   bucket_name          = local.asset_bucket_name
#   resource_name_prefix = local.resource_name_prefix
#   image_uri            = module.ecrRepo.repository_url
#   port                 = local.aws_batch_params.port

#   batch_iam_role_path = local.aws_batch_params.batch_iam_role_path
#   ecs_iam_role_path = local.aws_batch_params.ecs_iam_role_path

#   depends_on = [module.assetBucket, module.dockerImageNode]
# }

# module "stepFunction" {
#   source               = "./modules/step_function"
#   bucket_name          = local.asset_bucket_name
#   resource_name_prefix = local.resource_name_prefix

#   lambda_iam_role_path       = local.step_function_params.lambda_iam_role_path
#   step_funct_iam_policy_path = local.step_function_params.step_funct_iam_policy_path
#   step_funct_iam_role_path   = local.step_function_params.step_funct_iam_role_path

#   memory_size = local.common_lambda_params.lambda_memory_size
#   timeout     = local.common_lambda_params.lambda_timeout
#   runtime     = local.common_lambda_params.runtime

#   function_name       = local.step_function_params.function_name
#   path_to_source_file = local.step_function_params.path_to_source_file
#   path_to_artifact    = local.step_function_params.path_to_artifact
#   function_handler    = local.step_function_params.function_handler

#   aws_batch_job_def_arn   = module.awsBatch.aws_batch_job_def_arn
#   aws_batch_job_queue_arn = module.awsBatch.aws_batch_job_queue_arn

#   depends_on = [module.awsBatch]
# }
# ##############################################################################


# ##############################################################################
# Resources for Store Data Lambda Layer / Functions
# ##############################################################################
# module "lambdaLayer" {
#   source = "./modules/lambda_requests_layer"

#   path_to_requests_layer_source   = local.lambda_layer_params.path_to_requests_layer_source
#   path_to_requests_layer_artifact = local.lambda_layer_params.path_to_requests_layer_artifact
#   path_to_requests_layer_filename = local.lambda_layer_params.path_to_requests_layer_filename
#   requests_layer_name             = local.lambda_layer_params.requests_layer_name
#   compatible_layer_runtimes       = local.lambda_layer_params.compatible_layer_runtimes
#   compatible_architectures        = local.lambda_layer_params.compatible_architectures
# }

# module "storeFunction" {
#   source = "./modules/store_data_lambda"
#   count  = length(local.store_lambda_params.function_names)

#   bucket_name      = local.asset_bucket_name
#   function_name    = local.store_lambda_params.function_names[count.index]
#   function_handler = local.store_lambda_params.function_handler
#   memory_size      = local.common_lambda_params.lambda_memory_size
#   timeout          = local.common_lambda_params.lambda_timeout
#   runtime          = local.common_lambda_params.runtime

#   asset_bucket_id   = module.assetBucket.bucket_id
#   asset_bucket_path = local.asset_bucket_paths[count.index]
#   data_file_name    = local.data_file_names[count.index]
#   db_name           = local.store_lambda_params.db_names[count.index]

#   lambda_iam_policy_name = "${local.store_lambda_params.function_names[count.index]}_lambda_iam_policy"
#   lambda_iam_role_name   = "${local.store_lambda_params.function_names[count.index]}_lambda_iam_role"
#   lambda_iam_role_path   = local.store_lambda_params.lambda_iam_role_path

#   path_to_source_file = local.store_lambda_params.path_to_source_files[count.index]
#   path_to_artifact    = local.store_lambda_params.path_to_artifacts[count.index]

#   lambda_layer_arns = [module.lambdaLayer.requests_layer_arn]

#   # Uncomment if using Python Image for Scrape Lambda Function
#   # depends_on = [module.scrapeFunction, module.lambdaLayer]

#   # Uncomment if using StepFunction and NodeJS Image for AWS Batch / ECS Scrape App
#   depends_on = [module.stepFunction, module.lambdaLayer]
# }
# ##############################################################################