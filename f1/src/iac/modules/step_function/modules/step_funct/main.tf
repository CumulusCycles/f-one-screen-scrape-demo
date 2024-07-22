resource "aws_sfn_state_machine" "step_funct_state_machine" {

  name = "${var.resource_name_prefix}-step-funct"

  role_arn = var.step_funct_step_funct_iam_role_arn

  definition = <<EOF
{
  "Comment": "Step Funct to call Lambda then AWS Batch",
  "StartAt": "CheckForDataInAssetBucket",
  "States": {
    "CheckForDataInAssetBucket": {
      "Type": "Task",
      "Resource": "${var.lambda_arn}",
      "Next": "CheckResponse"
    },
    "CheckResponse": {
        "Type": "Choice",
        "Choices": [
            {
              "Variable": "$.statusCode",
              "StringEquals": "403",
              "Next": "InvokeAwsBatch"
            },
            {
              "Variable": "$.statusCode",
              "StringEquals": "200",
              "Next": "Complete"
            }
        ]
    },
    "InvokeAwsBatch": {
      "Type": "Task",
      "Resource": "arn:aws:states:::batch:submitJob.sync",
      "Parameters": {
        "JobDefinition": "${var.aws_batch_job_def_arn}",
        "JobName": "${var.resource_name_prefix}",
        "JobQueue": "${var.aws_batch_job_queue_arn}"
      },
      "Next": "Complete"
    },
    "Complete": {
      "Type": "Pass",
      "Result": {
          "status": 200,
          "message": "Complete."
      },
      "End": true
    }
  }
}
EOF
}