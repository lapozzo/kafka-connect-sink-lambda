provider "aws" {
#  access_key                  = "test"
  region                      = "us-east-1"
#  s3_force_path_style         = true
#  secret_key                  = "test"
#  skip_credentials_validation = true
#  skip_metadata_api_check     = true
#  skip_requesting_account_id  = true

#  uncomment if you want use localstack
#  endpoints {
#    apigateway     = "http://localhost:4566"
#    cloudformation = "http://localhost:4566"
#    cloudwatch     = "http://localhost:4566"
#    dynamodb       = "http://localhost:4566"
#    es             = "http://localhost:4566"
#    firehose       = "http://localhost:4566"
#    iam            = "http://localhost:4566"
#    kinesis        = "http://localhost:4566"
#    lambda         = "http://localhost:4566"
#    route53        = "http://localhost:4566"
#    redshift       = "http://localhost:4566"
#    s3             = "http://localhost:4566"
#    secretsmanager = "http://localhost:4566"
#    ses            = "http://localhost:4566"
#    sns            = "http://localhost:4566"
#    sqs            = "http://localhost:4566"
#    ssm            = "http://localhost:4566"
#    stepfunctions  = "http://localhost:4566"
#    sts            = "http://localhost:4566"
#  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
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

resource "aws_lambda_function" "kafka_sink_lambda" {
  function_name    = "kafka_sink_lambda"
  filename         = "../app.zip"
  handler          = "app.lambda_handler"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("../app.zip")
  runtime          = "python3.8"
  timeout          = 5
  memory_size      = 128

  tags = {
    Environment = "${var.environment_name}"
  }
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/kafka_sink_lambda"
  retention_in_days = 1
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}