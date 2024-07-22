variable "resource_name_prefix" {
  description = "Resource Name Prefix"
  type        = string
}

variable "bucket_name" {
  description = "Resource Name Prefix"
  type        = string
}

variable "image_uri" {
  description = "URI for Image in ECR Repo"
  type        = string
}

variable "port" {
  description = "Ingress / Egress Port"
  type        = number
}

variable "batch_iam_role_path" {
  description = "Path to Batch IAM Role JSON"
  type        = string
}

variable "ecs_iam_role_path" {
  description = "Path to ECS Role JSON"
  type        = string
}
