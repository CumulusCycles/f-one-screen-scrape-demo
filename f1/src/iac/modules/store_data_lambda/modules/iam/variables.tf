variable "lambda_iam_policy_name" {
  description = "Name of Lambda IAM Policy"
  type        = string
}

variable "bucket_name" {
  description = "Resource Name Prefix"
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