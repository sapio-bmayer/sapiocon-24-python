data "aws_availability_zones" "all" {
}

locals {
  local_names = [for name in data.aws_availability_zones.all.names : name if length(regexall(var.az_regex, name)) > 0]
}

data "aws_availability_zones" "available" {
  state         = "available"
  filter {
    name   = "zone-name"
    values = local.local_names
  }
  exclude_names = var.az_exclude
}
