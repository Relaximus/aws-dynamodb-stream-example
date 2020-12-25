resource "aws_kinesis_stream" "dynamodb_data_stream" {
  name = "dynamodb_data_stream"
  shard_count = 1
}

resource "aws_iam_role" "firehose_processing_role" {
  name = "firehose_processing_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dyanmo-stream-firehose-policy" {
  role = aws_iam_role.firehose_processing_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "es:*"
          ],
          "Resource": [
            "${var.domain_arn}",
            "${var.domain_arn}/*"
          ]
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "kinesis:SubscribeToShard",
            "kinesis:DescribeStreamSummary",
            "kinesis:DescribeStreamConsumer",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords",
            "kinesis:DescribeStream",
            "kinesis:ListTagsForStream"
        ],
        "Resource": "${aws_kinesis_stream.dynamodb_data_stream.arn}"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "kinesis:ListStreams",
            "kinesis:ListShards",
            "kinesis:DescribeLimits",
            "kinesis:ListStreamConsumers"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_s3_bucket" "bucket" {
  bucket = "tf-stream-bucket"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_to_es" {
  depends_on = [aws_iam_role_policy.dyanmo-stream-firehose-policy]
  name = "data-from-dynamoDb-to-es"
  destination = "elasticsearch"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.dynamodb_data_stream.arn
    role_arn = aws_iam_role.firehose_processing_role.arn
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_processing_role.arn
    bucket_arn         = aws_s3_bucket.bucket.arn
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  elasticsearch_configuration {
    domain_arn = var.domain_arn
    role_arn   = aws_iam_role.firehose_processing_role.arn
    index_name = "transactions"
    index_rotation_period = "NoRotation"
  }
}