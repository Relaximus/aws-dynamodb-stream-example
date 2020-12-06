variable "aws_region" {
  type = string
  description = "Used AWS Region"
  default = "eu-central-1"
}

variable "aws_profile" {
  type = string
  description = "Used AWS Profile for accessing services"
  default = "relaximus"
}