output "batch_iam_role_arn" {
  value = aws_iam_role.aws_batch_service_role.arn
}
output "ecs_iam_role_arn" {
  value = aws_iam_role.aws_ecs_task_execution_role.arn
}