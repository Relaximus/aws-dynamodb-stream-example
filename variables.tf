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

variable "use_kinesis" {
  type = bool
  description = "Whether using kinesis to stream data to ES or plain Lambda"
}