locals {
  cert_alternative_domains = toset([
    for subdomain in var.dns_subdomains : "${subdomain}.${var.dns_root_domain}"
  ])
}


resource "aws_route53_record" domain_record {
  for_each = var.dns_subdomains

  allow_overwrite = true
  name            = "${each.value}.${var.dns_root_domain}."
  records         = [lower(aws_lb.base_lb.dns_name)]
  type            = "CNAME"
  ttl             = 1
  zone_id         = data.aws_route53_zone.public.zone_id
}

#
#Certificate generation in ACM
#
resource "aws_acm_certificate" "load_balancer" {
  domain_name       = "${var.primary_subdomain}.${var.dns_root_domain}"
  validation_method = "DNS"

  tags = {
    env = var.env_tag
  }

  subject_alternative_names = local.cert_alternative_domains

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "sapiocon24_cert_validation_public" {
  for_each = {
    for dvo in aws_acm_certificate.load_balancer.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.public.zone_id
}