# Default VPC for Region
data "aws_vpc" "default" {
  default = true
}

# Subnet IDs in VPC
data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default.id
}