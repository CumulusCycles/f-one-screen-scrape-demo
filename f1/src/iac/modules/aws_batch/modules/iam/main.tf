# Batch Service Role
resource "aws_iam_role" "aws_batch_service_role" {
  name               = "${var.resource_name_prefix}-service-role"
  assume_role_policy = file(var.batch_iam_role_path)
}
resource "aws_iam_role_policy_attachment" "aws_batch_service_role_pol_attach" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

# ECS Task Execution Role
resource "aws_iam_role" "aws_ecs_task_execution_role" {
  name               = "${var.resource_name_prefix}-ecs-task-execution-role"
  assume_role_policy = file(var.ecs_iam_role_path)
}
resource "aws_iam_role_policy_attachment" "aws_ecs_task_execution_role_pol_attach" {
  role       = aws_iam_role.aws_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy" "aws_ecs_task_execution_role_policy" {
  name = "${var.resource_name_prefix}-ecs-task-exec-role-pol"
  role = aws_iam_role.aws_ecs_task_execution_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}
