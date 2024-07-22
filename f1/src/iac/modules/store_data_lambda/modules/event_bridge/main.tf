resource "aws_cloudwatch_event_rule" "s3_event_rule" {
  name          = "${var.asset_bucket_path}_event_rule"
  description   = "Trigger Lambda from S3 events"
  event_pattern = <<EOF
{
  "detail": {
    "object": {
      "key":[
      {
        "prefix": "${var.asset_bucket_path}/"
      },
      {
        "suffix": "${var.data_file_name}"
      }]
    },
    "bucket": {
      "name": ["${var.asset_bucket_id}"]
    }
  },
  "detail-type": ["Object Created"],
  "source": ["aws.s3"]
}
EOF
}

resource "aws_cloudwatch_event_target" "s3_event_target" {
  rule      = aws_cloudwatch_event_rule.s3_event_rule.name
  target_id = "s3_event_target"
  arn       = var.lambda_arn
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "s3_eventbridge_permission" {
  statement_id  = "AllowS3Event"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_event_rule.arn
}