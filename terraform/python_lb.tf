resource "aws_security_group" "sapioexamples_lb_sg" {
  name        = "${var.resource_prefix}SapioExamplesLbSg"
  description = "Sapio Examples Load Balancer Security Group"
  vpc_id      = module.sapioexamples_vpc.vpc_id

  tags = {
    Name = "${var.resource_prefix}SapioExamplesLbSg"
  }

  ingress {
    description      = "Restricted HTTP Access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


module "sapioexamples_lb" {
  source = "./base_https_lb"

  providers = {
    aws = aws
  }

  lb_security_group_id    = aws_security_group.sapioexamples_lb_sg.id
  dns_root_domain         = "sapioexamples.com"
  primary_subdomain       = "${var.resource_prefix}sapiocon24"
  # Can define additional subdomains here. If defining multiple subdomains/rules
  dns_subdomains          = ["${var.resource_prefix}sapiocon24"]
  env_tag                 = var.env_tag
  lb_access_log_s3_bucket = var.log_bucket_id
  lb_name                 = "SapioExamplesSharedLb"
  resource_prefix         = var.resource_prefix
  subnets                 = module.sapioexamples_vpc.subnet_ids
  vpc_id                  = module.sapioexamples_vpc.vpc_id
}


resource "aws_lb_target_group" "sapiocon24" {
  name = "${var.resource_prefix}SapioCon24Tg8080"

  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.sapioexamples_vpc.vpc_id

  deregistration_delay = 30

  health_check {
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    path                = "/"
    port                = 8080
    interval            = 30
    // Allow 404 and 405 as valid responses
    matcher             = "200-405"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    env = var.env_tag
  }
}
resource "aws_lb_listener_rule" "sapiocon_rule" {
  listener_arn = module.sapioexamples_lb.frontend_arn

  condition {
    host_header {
      values = ["${var.resource_prefix}sapiocon24.sapioexamples.com"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sapiocon24.arn
  }
}