variable "bucket_name" {
  description = "Resource Name Prefix"
  type        = string
}

variable "asset_bucket_id" {
  description = "Asset Bucket Id"
  type        = string
}

variable "asset_bucket_path" {
  description = "Asset Bucket filter path"
  type        = string
}

variable "data_file_name" {
  description = "Result data file"
  type        = string
}

variable "db_name" {
  description = "DynamoDB  Name"
  type        = string
}

variable "lambda_iam_policy_name" {
  description = "Name of Lambda IAM Policy"
  type        = string
}
variable "lambda_iam_role_name" {
  description = "Name of Lambda IAM Role"
  type        = string
}
variable "lambda_iam_role_path" {
  description = "Path to Lambda IAM Role JSON File"
  type        = string
}

variable "path_to_source_file" {
  description = "Path to Lambda Fucntion Source Code"
  type        = string
}
variable "path_to_artifact" {
  description = "Path to ZIP artifact"
  type        = string
}

variable "function_name" {
  description = "Name of Lambda Function"
  type        = string
}
variable "function_handler" {
  description = "Name of Lambda Function Handler"
  type        = string
}

variable "memory_size" {
  description = "Lambda Memory"
  type        = number
}
variable "timeout" {
  description = "Lambda Timeout"
  type        = number
}
variable "runtime" {
  description = "Lambda Runtime"
  type        = string
}

variable "lambda_layer_arns" {
  description = "Lambda Layer ARN"
  type        = list(string)
}

