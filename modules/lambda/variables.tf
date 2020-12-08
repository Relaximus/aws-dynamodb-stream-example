variable "aws_region" {
  type = string
  description = "Used AWS Region"
}

variable "stream_arn" {
  type = string
  description = "The dynamo db stream arn"
}

variable "domain_arn" {
  type = string
  description = "The ElasticSearch Domain to populate with the data"
}

variable "es_host" {
  type = string
  description = "the host for submiting index, search requests"
}