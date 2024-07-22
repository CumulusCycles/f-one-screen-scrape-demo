variable "resource_name_prefix" {
  description = "Resource Name Prefix"
  type        = string
}

variable "bucket_name" {
  description = "Resource Name Prefix"
  type        = string
}

variable "lambda_iam_role_path" {
  description = "Path to Lambda IAM Role File"
  type        = string
}

variable "step_funct_iam_policy_path" {
  description = "Path to State Machine IAM Policy File"
  type        = string
}

variable "step_funct_iam_role_path" {
  description = "Path to State Machine AM IPolicy File"
  type        = string
}