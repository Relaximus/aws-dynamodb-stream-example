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

# if not use_kinesis
module "StreamProcessingLambda" {
  count = var.use_kinesis ? 0 : 1
  source = "./modules/lambda"

  aws_region = var.aws_region
  stream_arn = module.TransactionsTable.streamArn
  domain_arn = module.EsDomain.domain_arn
  es_host = module.EsDomain.domain_host
}

# if use_kinesis
module "StreamProcessingKinesis" {
  count = var.use_kinesis ? 1 : 0
  source = "./modules/kinesis-stream"

  domain_arn = module.EsDomain.domain_arn
}
# dynamodb kinesis stream is not implemented yet in aws provider, so...
resource "null_resource" "assign_kinesis_stream_to_dynamo_db" {
  count = var.use_kinesis ? 1 : 0
  provisioner "local-exec" {
    command = "aws dynamodb enable-kinesis-streaming-destination --table-name ${module.TransactionsTable.table_name} --stream-arn ${module.StreamProcessingKinesis[0].aws_kinesis_arn} --profile ${var.aws_profile}"
  }
  depends_on = [module.TransactionsTable, module.StreamProcessingKinesis]
}

module "EsDomain" {
  source = "./modules/elastic"

  writer_role_arn = var.use_kinesis ? module.StreamProcessingKinesis[0].kinesis_firhorse_role_arn : module.StreamProcessingLambda[0].lambda_role_arn
}