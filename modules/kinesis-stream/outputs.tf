output "aws_kinesis_arn" {
  value = aws_kinesis_stream.dynamodb_data_stream.arn
}

output "kinesis_firhorse_role_arn" {
  value = aws_iam_role.firehose_processing_role.arn
}