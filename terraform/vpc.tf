module "sapioexamples_vpc" {
  source   = "./base_vpc"
  env_tag  = var.env_tag
  name     = "${var.resource_prefix}Sapio Examples ${data.aws_region.this.id} Shared VPC"
  vpc_cidr = var.vpc_cidr

  // Exclude 1e because it doesn't support many things in the SaaS env
  az_exclude = ["us-east-1e"]

  providers = {
    aws = aws
  }
}