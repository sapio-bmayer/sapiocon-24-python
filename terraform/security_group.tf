resource "aws_security_group" "ecs_sapiocon24" {
  vpc_id = module.sapioexamples_vpc.vpc_id
  name   = "${var.resource_prefix}ecsSapioCon24ExampleWebhook"
  ingress {
    description      = "ping"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "http"
    # Should match your python port
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.sapioexamples_vpc.ipv4_cidr_block]
    ipv6_cidr_blocks = [module.sapioexamples_vpc.ipv6_cidr_block]
  }
  egress {
    description      = "internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}