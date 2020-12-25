resource "aws_elasticsearch_domain" "dynamo_indexing_es" {
  domain_name = "dynamostream"
  elasticsearch_version = "7.9"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

resource "aws_elasticsearch_domain_policy" "dynamo_indexing_es_policy" {
  depends_on = [var.writer_role_arn]
  domain_name = aws_elasticsearch_domain.dynamo_indexing_es.domain_name
  access_policies = <<POLICIES
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": "*"
              },
              "Action": "es:*",
              "Resource": "${aws_elasticsearch_domain.dynamo_indexing_es.arn}/*"
          },
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": "${var.writer_role_arn}"
              },
              "Action": "es:*",
              "Resource": "${aws_elasticsearch_domain.dynamo_indexing_es.arn}/*"
          }
      ]
  }
POLICIES
}