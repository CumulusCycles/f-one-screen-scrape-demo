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

variable "lambda_arn" {
  description = "Lambda Funct ARN"
  type        = string
}

variable "lambda_name" {
  description = "Lambda Funct Name"
  type        = string
}