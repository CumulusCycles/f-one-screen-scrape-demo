variable "drivers_data_db_name" {
  description = "F One Academy Data DB  Name"
  type        = string
}

variable "lambda_iam_policy_name" {
  description = "Name of Lambda IAM Policy"
  type        = string
}

variable "lambda_iam_policy_path" {
  description = "Path to Lambda IAM Policy JSON File"
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


variable "path_to_requests_layer_source" {
  description = "path_to_requests_layer_source"
  type        = string
}

variable "path_to_requests_layer_artifact" {
  description = "path_to_requests_layer_artifact"
  type        = string
}

variable "path_to_requests_layer_filename" {
  description = "path_to_requests_layer_filename"
  type        = string
}

variable "requests_layer_name" {
  description = "requests_layer_name"
  type        = string
}

variable "compatible_layer_runtimes" {
  description = "compatible_layer_runtimes"
  type        = list(string)
}

variable "compatible_architectures" {
  description = "compatible_architectures"
  type        = list(string)
}

variable "bucket_id" {
  description = "F One Academy S3 Bucket Id"
  type        = string
}

variable "teams_data_db_name" {
  description = "F One Academy Data DB  Name"
  type        = string
}