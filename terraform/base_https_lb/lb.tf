resource "aws_security_group" "base_lb_sg" {
  name        = "${var.resource_prefix}${var.lb_name}-sg"
  description = "${var.lb_name} internet access"
  vpc_id      = var.vpc_id

  tags = {
    Name   = "${var.resource_prefix}${var.lb_name}"
    Env    = var.env_tag
  }

  ingress {
    description = "Allow all to access HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all to access HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "Allow all to access HTTPS"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "base_lb" {
  name               = "${var.resource_prefix}${var.lb_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets = var.subnets

  idle_timeout = 4000

  enable_deletion_protection = false


  access_logs {
    bucket  = var.lb_access_log_s3_bucket
    prefix  = "aws-lb/${var.resource_prefix}${var.lb_name}/access-logs"
    enabled = true
  }

  tags = {
    env = var.env_tag
  }
}

resource "aws_lb_listener" "https_front_end" {
  load_balancer_arn = aws_lb.base_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.load_balancer.arn

  // Return with 404 page
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404"
      status_code  = "404"
    }
  }


  tags = {
    env = var.env_tag
  }
}


data "aws_elb_service_account" "main" {}
