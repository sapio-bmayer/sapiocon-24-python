resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.resource_prefix}${var.service_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    env = var.env_tag
  }
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_role_attachment" {
  for_each   = var.task_iam_policy_arns
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = each.value
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.resource_prefix}${var.service_name}_ecs_service_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json


  tags = {
    env = var.env_tag
  }
}

locals {
  repository_name = regex("^(.*)\\/(.*):.*$", var.task_def.image)[1]
}

data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress"
    ]
    resources = ["*"]
  }

  # Allow for registering with the load balancer
  # Fargate doesn't need this
  #  statement {
  #    actions = [
  #      "elasticloadbalancing:Describe*",
  #      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
  #      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
  #    ]
  #    resources = ["*"]
  #  }

  # Allow for getting an Auth token, but doesn't control access to repos
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Add permission to download just the image layers that are used in the task definition
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeImages"
    ]

    resources = ["arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:repository/${local.repository_name}"]
  }

  # Add permissions for CloudWatch Logs
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/${replace(var.resource_prefix, "-", "/")}${var.service_name}*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.resource_prefix}_${var.service_name}_ecs_service_role_policy"
  policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}