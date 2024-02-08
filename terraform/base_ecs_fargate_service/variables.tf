variable "resource_prefix" {
  type = string
}

variable "env_tag" {
  type = string
}

variable "container_port" {
  type        = number
  description = "The port on which the container is listening and the load balancer will route traffic to"
  default     = 8080
}

variable "ecs_desired_count" {
    type        = number
    description = "The number of tasks to run"
    default     = 1
}
variable "ecs_minimum_healthy_percent" {
    type        = number
    description = "The minimum percentage of tasks that must be healthy at any time"
    default     = 100
}

variable "ecs_maximum_percent" {
    type        = number
    description = "The maximum percentage of tasks that can be running during a deployment"
    default     = 200
}

variable "subnets" {
  type        = list(string)
  description = "The subnets to launch the service with"
}

variable "security_group_id" {}

variable "service_name" {
}

variable "lb_target_group_arn" {
  description = "The ARN of the target group to which to register the ECS service with to route traffic"
}

variable "task_iam_policy_arns" {
  type    = map(string)
  default = {}
}

variable "task_def" {
  type = object({
    cpu    = number
    memory = number
    image  = string

    ephemeralStorage = number

    ports = list(number)

    mounts      = list(map(string))
    efs_volumes = list(object({
      name                = string
      efs_file_system_id  = string
      efs_access_point_id = string
      efs_root_directory  = string
    }))

    environment = map(string)
  })

  default = {
    image  = ""
    cpu    = 0.25
    memory = 0.5
    ephemeralStorage = 20
    ports  = []

    mounts      = []
    efs_volumes = []

    environment = {}
  }
}