variable "name" {
  type = string
}
#variable "enable_nat" {
#  type = bool
#  default = false
#}
variable "env_tag" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "az_regex" {
  type = string
  default = "^\\w+-\\w+-\\d+[a-z]$"
}

variable "az_exclude" {
  type = list(string)
  default = []
}