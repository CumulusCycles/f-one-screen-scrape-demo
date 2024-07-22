variable "lambda_iam_role_arn" {
  description = "Lambda IAM Role ARN"
  type        = string
}

variable "image_uri" {
  description = "URI to Image in ECR"
  type        = string
}

variable "package_type" {
  description = "Package type"
  type        = string
}

variable "function_name" {
  description = "Name of Lambda Function"
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

# variable "runtime" {
#   description = "Lambda Runtime"
#   type        = string
# }
