# Lambda Role
resource "aws_iam_role_policy" "step_funct_lambda_iam_policy" {
  name = "${var.resource_name_prefix}-step-funct-lambda-role-policy"
  role = aws_iam_role.step_funct_lambda_iam_role.id
  # TBD pass Resource ARN in as param
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "s3:ListBucket",
          "s3:ListObject",
          "s3:GetObject"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "step_funct_lambda_iam_role" {
  name               = "${var.resource_name_prefix}-step-funct-lambda-role"
  assume_role_policy = file(var.lambda_iam_role_path)
}

# State Machine Role
resource "aws_iam_role_policy" "step_funct_step_funct_iam_policy" {
  name   = "${var.resource_name_prefix}-step-funct-step-funct-role-policy"
  role   = aws_iam_role.step_funct_step_funct_iam_role.id
  policy = file(var.step_funct_iam_policy_path)
}

resource "aws_iam_role" "step_funct_step_funct_iam_role" {
  name               = "${var.resource_name_prefix}-step-funct-step-funct-role"
  assume_role_policy = file(var.step_funct_iam_role_path)
}