terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

module "TransactionsTable" {
  source = "./modules/dynamoDb"
}

module "StreamProcessingLambda" {
  source = "./modules/lambda"

  aws_region = var.aws_region
  stream_arn = module.TransactionsTable.streamArn
}

//aws dynamodb put-item \
//--table-name UsersTransactions \
//--item userId={N=1},transactionId={N=1},accountId={N=1},ammount={N=32},shortDescription={S="Testing...1...2...3"}