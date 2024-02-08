output "vpc_id" {
  value = aws_vpc.base_stack.id
}


output "ipv4_cidr_block" {
  value = var.vpc_cidr
}

output "ipv6_cidr_block" {
  value = aws_vpc.base_stack.ipv6_cidr_block
}

output "subnet_ids_list" {
  value = [for s in aws_subnet.base_stack : s.id]
}

output "subnet_ids" {
  value = toset([for s in aws_subnet.base_stack : s.id])
}