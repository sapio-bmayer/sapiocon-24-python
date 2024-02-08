variable "aws_profile" {
  description = "AWS profile to use"
  default     = "default"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC to use for all of the tasks"
  default     = "172.18.0.0/20"
}

variable "log_bucket_id" {
  type        = string
  description = "The id of the s3 bucket to use for storing logs. Must allow for ECS to write to it"
  default     = ""
}

variable "dns_domain" {
  type        = string
  description = "The domain to use for the DNS zone. Example value: example.com"
  default     = "sapioexamples.com"
}


variable "resource_prefix" {
  type    = string
  default = "usea1-dev-"
}

variable "env_tag" {
  type    = string
  default = "dev-example"
}