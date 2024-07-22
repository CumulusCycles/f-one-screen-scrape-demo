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

variable "function_name" {
  description = ""
  type        = string
}

variable "path_to_source_file" {
  description = ""
  type        = string
}

variable "path_to_artifact" {
  description = ""
  type        = string
}

variable "function_handler" {
  description = ""
  type        = string
}

variable "memory_size" {
  description = ""
  type        = string
}

variable "timeout" {
  description = ""
  type        = string
}

variable "runtime" {
  description = ""
  type        = string
}

variable "aws_batch_job_def_arn" {
  description = ""
  type        = string
}

variable "aws_batch_job_queue_arn" {
  description = ""
  type        = string
}
