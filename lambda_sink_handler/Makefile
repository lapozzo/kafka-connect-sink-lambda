ls-start:
	localstack start

tf-plan:
	terraform -chdir=infra init
	terraform -chdir=infra plan

tf-apply:
	terraform -chdir=infra apply

lmd-logs:
	aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/kafka_sink_lambda --follow

lmd-invoke:
	aws --endpoint-url=http://localhost:4566 lambda invoke --function-name kafka_sink_lambda out.log

lmd-build:
	sh build-lambda.sh
