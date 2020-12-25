output "streamArn" {
  value = aws_dynamodb_table.users-transactions-table.stream_arn
}

output "table_name" {
  value = aws_dynamodb_table.users-transactions-table.name
}