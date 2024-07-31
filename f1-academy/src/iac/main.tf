terraform {
  required_version = "~> 1.3"

  # Uncomment after provisioning tf-state Module for Remote State Locking
  # backend "s3" {
  #   bucket         = "cc-f-one-academy-tf-state-08-01-24v01"
  #   key            = "tf-infra/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "cc-f-one-academy-tf-state-08-01-24v01"
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
# module "tf-state" {
#   source      = "./modules/tf-state"
#   bucket_name = local.tf_state_resource_name
#   table_name  = local.tf_state_resource_name
# }

# module "ecrRepo" {
#   source        = "./modules/ecr_repo"
#   ecr_repo_name = local.ecr_repo_params.ecr_repo_name
# }

# module "dockerImagePython" {
#   source      = "./modules/docker_image"
#   ecr_repo    = module.ecrRepo.repository_url
#   image_name  = local.docker_image_params.image_name
#   path_to_src = local.docker_image_params.path_to_src
#   platform    = local.docker_image_params.platform

#   depends_on = [module.ecrRepo]
# }

# module "scrapeFunction" {
#   source      = "./modules/scrape_team_data"
#   bucket_name = local.common_params.asset_bucket_name

#   lambda_iam_policy_name = local.scrape_function_params.lambda_iam_policy_name
#   lambda_iam_policy_path = local.scrape_function_params.lambda_iam_policy_path
#   lambda_iam_role_name   = local.scrape_function_params.lambda_iam_role_name
#   lambda_iam_role_path   = local.scrape_function_params.lambda_iam_role_path

#   function_name = local.scrape_function_params.function_name
#   package_type  = local.scrape_function_params.package_type
#   memory_size   = local.common_params.lambda_memory_size
#   timeout       = local.common_params.lambda_timeout
#   image_uri     = "${module.ecrRepo.repository_url}:latest"

#   depends_on = [module.dockerImagePython]
# }

# module "storeFunction" {
#   source               = "./modules/store_team_data"
#   teams_data_db_name   = local.store_function_params.teams_data_db_name
#   drivers_data_db_name = local.store_function_params.drivers_data_db_name

#   lambda_iam_policy_name = local.store_function_params.lambda_iam_policy_name
#   lambda_iam_policy_path = local.store_function_params.lambda_iam_policy_path
#   lambda_iam_role_name   = local.store_function_params.lambda_iam_role_name
#   lambda_iam_role_path   = local.store_function_params.lambda_iam_role_path

#   path_to_requests_layer_source   = local.store_function_params.path_to_requests_layer_source
#   path_to_requests_layer_artifact = local.store_function_params.path_to_requests_layer_artifact
#   path_to_requests_layer_filename = local.store_function_params.path_to_requests_layer_filename
#   requests_layer_name             = local.store_function_params.requests_layer_name
#   compatible_layer_runtimes       = local.common_params.lambda_compatible_layer_runtimes
#   compatible_architectures        = local.common_params.lambda_compatible_architectures

#   path_to_source_file = local.store_function_params.path_to_source_file
#   path_to_artifact    = local.store_function_params.path_to_artifact
#   function_name       = local.store_function_params.function_name
#   function_handler    = local.store_function_params.function_handler
#   memory_size         = local.common_params.lambda_memory_size
#   timeout             = local.common_params.lambda_timeout
#   runtime             = local.store_function_params.runtime
#   bucket_id           = local.common_params.asset_bucket_name

#   depends_on = [module.scrapeFunction]
# }
