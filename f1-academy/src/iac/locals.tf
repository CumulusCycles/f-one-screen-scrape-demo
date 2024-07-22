locals {
  tf_state_resource_name = "cc-f-one-scrape-tf-state"

  common_params = {
    asset_bucket_name = "cc-f-one-assets"

    lambda_compatible_layer_runtimes = ["python3.10"]
    lambda_compatible_architectures  = ["x86_64"]

    lambda_memory_size = 1024
    lambda_timeout     = 900
  }

  ecr_repo_params = {
    ecr_repo_name = "cc-f-one-scrape-repo"
  }

  docker_image_params = {
    image_name  = "cc-f-one-scrape-app"
    path_to_src = "/Users/rob/Development/f-one-screen-scrape-demo/f1-academy/src/app/scrape_team_data/"
    platform    = "linux/amd64"
  }

  scrape_function_params = {
    lambda_iam_policy_name = "f_one_academy_scrape_lambda_iam_policy"
    lambda_iam_policy_path = "./modules/scrape_team_data/modules/iam/lambda-iam-policy.json"
    lambda_iam_role_name   = "f_one_academy_scrape_lambda_iam_role"
    lambda_iam_role_path   = "./modules/scrape_team_data/modules/iam/lambda-assume-role-policy.json"

    function_name = "scrape"
    package_type  = "Image"
  }

  store_function_params = {
    teams_data_db_name   = "cc-f-one-teams-assets"
    drivers_data_db_name = "cc-f-one-drivers-assets"

    lambda_iam_policy_name = "f_one_academy_store_lambda_iam_policy"
    lambda_iam_policy_path = "./modules/store_team_data/modules/iam/lambda-iam-policy.json"
    lambda_iam_role_name   = "f_one_academy_store_lambda_iam_role"
    lambda_iam_role_path   = "./modules/store_team_data/modules/iam/lambda-assume-role-policy.json"

    requests_layer_name             = "requests"
    path_to_requests_layer_source   = "./modules/store_team_data/requests"
    path_to_requests_layer_artifact = "./artifacts/requests.zip"
    path_to_requests_layer_filename = "./artifacts/requests.zip"

    path_to_source_file = "../app/store_team_data/main.py"
    path_to_artifact    = "./modules/store_artifacts/store.zip"

    function_name    = "store"
    function_handler = "main.lambda_handler"
    runtime          = "python3.10"
  }
}