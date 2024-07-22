provider "aws" {
  region = "us-east-1"
}

provider "docker" {
  host = "unix:///Users/rob/.docker/run/docker.sock"

  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}