variable "resource_prefix" {
  type = string
}

variable "lb_name" {
  type        = string
  description = "The name of the load balancer"
}

variable "lb_security_group_id" {
  type        = string
  description = "The security group ID to attach to the load balancer"
}

variable "env_tag" {
  type = string
}

variable "primary_subdomain" {
  type = string
}

variable "dns_subdomains" {
  type        = set(string)
  default     = []
  description = "If more than one subdomain is specified, the load balancer will be created with multiple DNS records and a multi-domain cert"
}

variable "dns_root_domain" {
  type = string
}

variable "lb_access_log_s3_bucket" {
  type        = string
  description = "The S3 bucket to store the load balancer access logs. Needs write access to the bucket at aws-lb/*"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to deploy the load balancer into"
}

variable "subnets" {
  type        = list(string)
  description = "The subnets for load balancer to listen on"
}

variable "lb_port" {
    type        = number
    description = "The port the load balancer will listen on"
    default = 443
}