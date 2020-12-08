resource "aws_dynamodb_table" "users-transactions-table" {
  name = "UsersTransactions"
  hash_key = "userId"
  range_key = "transactionId"
  write_capacity = 20
  read_capacity = 20

  attribute {
    name = "userId"
    type = "N"
  }

  attribute {
    name = "transactionId"
    type = "N"
  }

  attribute {
    name = "accountId"
    type = "N"
  }

  attribute {
    name = "amount"
    type = "N"
  }

  attribute {
    name = "shortDescription"
    type = "S"
  }

  local_secondary_index {
    name = "accountIdLI"
    projection_type = "KEYS_ONLY"
    range_key = "accountId"
  }

  local_secondary_index {
    name = "amountLI"
    projection_type = "KEYS_ONLY"
    range_key = "amount"
  }

  local_secondary_index {
    name = "shortDescriptionLI"
    projection_type = "KEYS_ONLY"
    range_key = "shortDescription"
  }

  stream_enabled = true

  stream_view_type = "NEW_IMAGE"
}