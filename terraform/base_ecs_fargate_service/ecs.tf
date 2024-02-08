/* ecs chem cache service cluster */
resource "aws_ecs_cluster" "task" {
  name = "${var.resource_prefix}${var.service_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    env = var.env_tag
  }
}

resource "aws_ecs_service" "task" {
  count = 1
  name = "${var.resource_prefix}${var.service_name}"
  cluster = aws_ecs_cluster.task.id
  launch_type = "FARGATE"
  platform_version = "1.4.0"

  enable_execute_command = true

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name = "${var.resource_prefix}${var.service_name}"
    container_port = var.container_port
  }

  deployment_minimum_healthy_percent = var.ecs_minimum_healthy_percent
  deployment_maximum_percent = var.ecs_maximum_percent
  desired_count = var.ecs_desired_count
#  scheduling_strategy = "DAEMON"
  task_definition = aws_ecs_task_definition.task_def.arn
#  iam_role = aws_iam_role.ecs_assume_role.arn


  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.security_group_id]
    # Eventually we should use a NAT gateway or some VPC peering with NAT gateway
    assign_public_ip = true
  }


  tags = {
    env = var.env_tag
  }

  depends_on      = [aws_iam_role_policy.ecs_service_role_policy]
}

resource "aws_cloudwatch_log_group" "task" {
  name = "${var.resource_prefix}${var.service_name}"

  tags = {
    env = var.env_tag
  }
}

locals {
  ecs_mounts = concat(
    var.task_def.mounts
  )
}

resource "aws_ecs_task_definition" "task_def" {
  family = "${var.resource_prefix}${var.service_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_service_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  #  lifecycle {
  #    ignore_changes = [
  #      requires_compatibilities,
  #      cpu,
  #      memory,
  #      execution_role_arn,
  #      container_definitions,
  #    ]
  #  }


  cpu       = var.task_def.cpu*1024
  memory    = var.task_def.memory*1024

  runtime_platform {
    operating_system_family = "LINUX"
  }

  // Define all efs volumes required
  dynamic "volume" {
    for_each = var.task_def.efs_volumes
    content {
      name = volume.value["name"]
      efs_volume_configuration {
        file_system_id = volume.value["efs_file_system_id"]
        root_directory = volume.value["efs_root_directory"]
        transit_encryption = "ENABLED"
        authorization_config {
            access_point_id = volume.value["efs_access_point_id"]
            iam = "ENABLED"
        }
      }
    }
  }
  dynamic "ephemeral_storage" {
    for_each = var.task_def.ephemeralStorage > 20 ? [1] : []
    content {
      size_in_gib = var.task_def.ephemeralStorage
    }
  }

  container_definitions = jsonencode([
    {
      name      = "${var.resource_prefix}${var.service_name}"
      image     = var.task_def.image
      cpu       = var.task_def.cpu*1024
      memory    = var.task_def.memory*1024
      essential = true
      portMappings = [
        # Map var.task_def.ports to json array
        for port in var.task_def.ports : {
          containerPort = port
          hostPort      = port
          protocol      = "tcp"
        }
      ]

      mountPoints = local.ecs_mounts
      environment = [
        for name, value in var.task_def.environment : {
          name  = name
          value = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group: "/aws/ecs/${replace(var.resource_prefix, "-", "/")}${var.service_name}"
          awslogs-region: data.aws_region.this.name
          awslogs-stream-prefix: "ecs"
          #          awslogs-multiline-pattern = "^\\s*\\[?\\d+-\\d+-\\d+\\s+\\d+:\\d+:\\d+]?\\s*",
        }
      },
    }
  ])
  tags = {
    env = var.env_tag
  }
}
