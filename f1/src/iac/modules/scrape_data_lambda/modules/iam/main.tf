resource "aws_iam_role_policy" "lambda_iam_policy" {
  name = var.lambda_iam_policy_name
  role = aws_iam_role.lambda_iam_role.id

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
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_iam_role" {
  name = var.lambda_iam_role_name

  assume_role_policy = file(var.lambda_iam_role_path)
}