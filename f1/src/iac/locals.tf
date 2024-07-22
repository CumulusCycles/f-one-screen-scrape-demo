locals {
  tf_state_resource_name = "cc-f-one-tf-state-07-13-24v01"
  asset_bucket_name      = "cc-f-one-assets-07-13-24v01"
  asset_bucket_paths     = ["races", "drivers", "teams"]
  data_file_names        = ["race_results_data.json", "driver_results_data.json", "team_results_data.json"]
  ecr_repo_name          = "cc-f-one-scrape-repo"
  resource_name_prefix   = "cc-f-one-scrape"

  # Used to provision with AWS Batch / ECS (true) or Lambda (false)
  provision_with_aws_batch = true

  common_docker_image_params = {
    image_name = "cc-f-one-scrape-app"
    platform   = "linux/amd64"
  }

  docker_image_params_python = {
    path_to_src = "/Users/rob/Development/f-one-screen-scrape-demo/f1/src/app/scrape_data_python/"
  }

  docker_image_params_node = {
    path_to_src = "/Users/rob/Development/f-one-screen-scrape-demo/f1/src/app/scrape_data_node/"
  }

  step_function_params = {
    function_name = "cc-f-one-check-for-data"

    lambda_iam_role_path       = "./modules/step_function/modules/iam/lambda-assume-role-policy.json"
    step_funct_iam_policy_path = "./modules/step_function/modules/iam/step-funct-iam-policy.json"
    step_funct_iam_role_path   = "./modules/step_function/modules/iam/step-funct-assume-role-policy.json"

    path_to_source_file = "../app/event_bridge_function/main.py"
    path_to_artifact    = "./modules/artifacts/event_bridge_function.zip"
    function_handler    = "main.lambda_handler"
  }

  aws_batch_params = {
    port = 3000

    batch_iam_role_path = "./modules/aws_batch/modules/iam/batch-assume-role-policy.json"
    ecs_iam_role_path   = "./modules/aws_batch/modules/iam/ecs-assume-role-policy.json"
  }

  common_lambda_params = {
    runtime            = "python3.10"
    lambda_memory_size = 1024
    lambda_timeout     = 900
  }

  scrape_lambda_params = {
    function_name = "cc-f-one-scrape-data"

    lambda_iam_policy_name = "f_one_scrape_lambda_iam_policy"
    lambda_iam_role_name   = "f_one_scrape_lambda_iam_role"
    lambda_iam_role_path   = "./modules/scrape_data_lambda/modules/iam/lambda-assume-role-policy.json"

    package_type = "Image"
  }

  lambda_layer_params = {
    requests_layer_name             = "requests"
    path_to_requests_layer_source   = "./modules/store_data_lambda/requests"
    path_to_requests_layer_artifact = "./artifacts/requests.zip"
    path_to_requests_layer_filename = "./artifacts/requests.zip"
    compatible_layer_runtimes       = ["python3.10"]
    compatible_architectures        = ["x86_64"]
  }

  store_lambda_params = {
    function_names = ["cc-f-one-store-race-data", "cc-f-one-store-driver-data", "cc-f-one-team-store-data"]
    db_names       = ["cc-f-one-race-data-db", "cc-f-one-driver-data-db", "cc-f-one-team-data-db"]

    lambda_iam_role_path = "./modules/store_data_lambda/modules/iam/lambda-assume-role-policy.json"

    path_to_source_files = ["../app/store_race_data/main.py", "../app/store_driver_data/main.py", "../app/store_team_data/main.py"]
    path_to_artifacts    = ["./modules/artifacts/store_race_data.zip", "./modules/artifacts/store_driver_data.zip", "./modules/artifacts/store_team_data.zip"]

    function_handler = "main.lambda_handler"
  }
}