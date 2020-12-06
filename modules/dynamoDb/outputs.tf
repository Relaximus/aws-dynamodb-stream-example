output "streamArn" {
  value = aws_dynamodb_table.users-transactions-table.stream_arn
}