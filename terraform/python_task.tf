
# Host the SapioCon24 service on ECS Fargate
module "sapiocon24" {
  source = "./base_ecs_fargate_service"

  env_tag     = var.env_tag
  lb_target_group_arn = aws_lb_target_group.sapiocon24.arn
  resource_prefix     = var.resource_prefix
  security_group_id   = aws_security_group.ecs_sapiocon24.id
  service_name        = "SapioCon24"
  subnets             = module.sapioexamples_vpc.subnet_ids

  depends_on           = [aws_iam_policy.sapiocon24]
  task_iam_policy_arns = {
    main = aws_iam_policy.sapiocon24.arn
  }


  container_port = 8080

  task_def = {
    image  = "sapiosciences/sapiocon24:20240208.1752"
    cpu    = 1
    memory = 2


    ephemeralStorage = 0

    ports = [8080]

    environment = {
    }

    mounts = []

    efs_volumes = []
  }


  providers = {
    aws       = aws
  }
}

resource "aws_iam_policy" "sapiocon24" {
  name   = "${var.resource_prefix}sapiocon24"
  policy = data.aws_iam_policy_document.sapiocon24.json

  tags = {
    env = var.env_tag
  }
}

data "aws_iam_policy_document" "sapiocon24" {
    statement {
        actions   = ["none:null"]
        resources = ["*"]
    }
}