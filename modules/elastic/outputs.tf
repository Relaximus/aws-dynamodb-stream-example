output "domain_arn" {
  value = aws_elasticsearch_domain.dynamo_indexing_es.arn
}

output "domain_id" {
  value = aws_elasticsearch_domain.dynamo_indexing_es.domain_id
}

output "domain_host" {
  value = aws_elasticsearch_domain.dynamo_indexing_es.endpoint
}