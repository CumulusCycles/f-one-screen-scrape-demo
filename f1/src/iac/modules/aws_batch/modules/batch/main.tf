resource "aws_security_group" "aws_batch_sg" {
  name        = "${var.resource_name_prefix}-batch-sg"
  vpc_id      = data.aws_vpc.default.id
  description = "AWS Batch SG"

  ingress {
    from_port = var.port
    to_port   = var.port
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_batch_compute_environment" "aws_batch_comp_env" {
  compute_environment_name = "${var.resource_name_prefix}-compute-env"

  compute_resources {
    max_vcpus = 256
    security_group_ids = [
      aws_security_group.aws_batch_sg.id,
    ]
    subnets = data.aws_subnet_ids.default_subnets.ids
    type    = "FARGATE"
  }
  service_role = var.batch_iam_role_arn
  type         = "MANAGED"
}

resource "aws_batch_job_definition" "aws_batch_job_def" {
  name = "${var.resource_name_prefix}job-def"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  container_properties = jsonencode({
    image = var.image_uri

    fargatePlatformConfiguration = {
      platformVersion = "LATEST"
    }

    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }

    resourceRequirements = [
      {
        type  = "VCPU"
        value = "0.25"
      },
      {
        type  = "MEMORY"
        value = "512"
      }
    ]

    executionRoleArn = var.ecs_iam_role_arn
  })
}

resource "aws_batch_job_queue" "aws_batch_job_queue" {
  name     = "${var.resource_name_prefix}-job-queue"
  state    = "ENABLED"
  priority = "0"
  compute_environments = [
    aws_batch_compute_environment.aws_batch_comp_env.arn,
  ]
}
