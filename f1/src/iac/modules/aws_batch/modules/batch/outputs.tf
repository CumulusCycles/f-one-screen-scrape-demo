output "aws_batch_job_def_arn" {
  value = aws_batch_job_definition.aws_batch_job_def.arn
}

output "aws_batch_job_queue_arn" {
  value = aws_batch_job_queue.aws_batch_job_queue.arn
}