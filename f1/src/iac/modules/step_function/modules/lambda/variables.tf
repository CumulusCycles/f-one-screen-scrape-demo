variable "resource_name_prefix" {
  description = "Resource Name Prefix"
  type        = string
}

variable "step_funct_lambda_iam_role_arn" {
  description = ""
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