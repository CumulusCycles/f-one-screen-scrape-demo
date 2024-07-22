variable "resource_name_prefix" {
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

variable "batch_iam_role_arn" {
  description = "Batch IAM Role ARN"
  type        = string
}

variable "ecs_iam_role_arn" {
  description = "ECS IAM Role ARN"
  type        = string
}
