data "aws_region" "this" {
}


data "aws_caller_identity" "current" {}

data "aws_lb_target_group" "service" {
  arn = var.lb_target_group_arn
}

data "aws_availability_zones" "available" {
  state         = "available"
  exclude_names = ["us-east-1e"]
}

data "aws_availability_zones" "all" {
}