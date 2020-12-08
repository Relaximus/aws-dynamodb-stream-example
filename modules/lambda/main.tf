locals {
  lambda_func_name = "processDynamoDbStream"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "dyanmo_stream_lambda_policy" {
  role = aws_iam_role.dyanmo_stream_lambda_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${local.lambda_func_name}*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Resource": "${var.stream_arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "es:ESHttpGet",
                "es:ESHttpPost",
                "es:ESHttpPut"
            ],
            "Resource": "${var.domain_arn}"
        }
    ]
  }
  EOF
}

resource "aws_iam_role" "dyanmo_stream_lambda_role" {
  name = "dyanmo_stream_lambda_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_lambda_function" "process_dynamo_stream_function" {
  function_name = local.lambda_func_name
  handler = "index.handler"
  role = aws_iam_role.dyanmo_stream_lambda_role.arn
  runtime = "nodejs12.x"
  environment {
    variables = {
      ES_HOST = var.es_host
      ES_REGION = var.aws_region
    }
  }

  filename      = "./lambda_function_payload.zip"
  source_code_hash = filebase64sha256("./lambda_function_payload.zip")
}

resource "aws_lambda_event_source_mapping" "stream_function_event_trigger" {
  event_source_arn  = var.stream_arn
  function_name     = aws_lambda_function.process_dynamo_stream_function.arn
  starting_position = "LATEST"
}