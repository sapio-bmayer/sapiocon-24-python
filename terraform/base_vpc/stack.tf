
resource "aws_vpc" "base_stack" {
  cidr_block           = var.vpc_cidr

  enable_dns_support = true
  enable_dns_hostnames = true

  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = var.name
    env = var.env_tag
  }
}

resource "aws_internet_gateway" "base_stack" {
  vpc_id = aws_vpc.base_stack.id
  tags = {
    Name = var.name
    env = var.env_tag
  }
}

resource "aws_route" "base_stack" {
  route_table_id         = aws_vpc.base_stack.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.base_stack.id
}

resource "aws_subnet" "base_stack" {
  for_each                        = toset(data.aws_availability_zones.available.names)
  vpc_id                          = aws_vpc.base_stack.id
  cidr_block                      = cidrsubnet(var.vpc_cidr, 4, 0 + index(data.aws_availability_zones.available.names, each.key))
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.base_stack.ipv6_cidr_block, 8, 1 + index(data.aws_availability_zones.available.names, each.key))
  assign_ipv6_address_on_creation = true
  availability_zone               = each.key
  tags                            = {
    Name        = "${var.name} ${each.key}"
    env = var.env_tag
  }
}

resource "aws_default_route_table" "base_stack" {
  default_route_table_id = aws_vpc.base_stack.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.base_stack.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.base_stack.id
  }
}



resource "aws_route_table_association" "base_stack" {
  for_each       = toset(data.aws_availability_zones.available.names)
  subnet_id      = aws_subnet.base_stack[each.key].id
  route_table_id = aws_default_route_table.base_stack.id
}