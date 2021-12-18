output "lambda_arn" {
  description = "The arn of the Lambda"
  value       = "${aws_lambda_function.kafka_sink_lambda.arn}"
}


