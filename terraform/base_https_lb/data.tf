data "aws_route53_zone" "public" {
  name         = "${var.dns_root_domain}."
  private_zone = false
}