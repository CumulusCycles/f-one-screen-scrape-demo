variable "bucket_name" {
  description = "F One Academy S3 Bucket Name"
  type        = string
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.bucket_name))
    error_message = "Bucket Name must not be empty and must follow S3 naming rules."
  }
}

variable "function_name" {
  description = "Lambda Function Name"
  type        = string
}

variable "image_uri" {
  description = "URI for Image in ECR Repo"
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

variable "package_type" {
  description = "Package type"
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
