output "id" {
  value = aws_lb.base_lb.id
}

output "arn" {
  value = aws_lb.base_lb.arn
}

output "frontend_id" {
  value = aws_lb_listener.https_front_end.id
}

output "frontend_arn" {
  value = aws_lb_listener.https_front_end.arn
}