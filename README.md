# Introduction

Simple Kakfa Connect Sink Lambda example

Flow: 

[Kafka Cli Producer] -> [Kafka Broker/Topic] -> [Kafka Connect] -> [Lambda Handler]

## Requirements
* Docker + Docker Compose

## Start Environment
* Confluent Kafka

```sh
cd confluent-kafka
docker compose up -d
```

### Create the topic

```sh
docker exec broker1 kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 3 --partitions 3 --topic my-topic
```

### Install Lambda Sink Connector

1. Enter in the connect container's bash and install with confluent-hub cli

```sh
docker exec -it connect bash
confluent-hub install confluentinc/kafka-connect-aws-lambda:latest
```

2. Restart Kafka Connect Container

```sh
docker-compose restart connect
```

Source: https://docs.confluent.io/kafka-connect-aws-lambda/current/overview.html#install-the-lambda-connector

### Deploy Lambda in your AWS Account

ps.: You can test the lambda handler locally with the Localstack, but currently it is not possible use the Localstack as target for Kafka Connect

```sh
cd lambda_sink_handler 
make ls-start
make tf-plan
make tf-apply
#test lambda
make lmd-invoke
```

### Deploy Kafka Connect configuration

```json
 {
   "name": "LambdaSinkConnector",
   "config" : {
     "connector.class" : "io.confluent.connect.aws.lambda.AwsLambdaSinkConnector",
     "key.converter": "org.apache.kafka.connect.storage.StringConverter",
     "value.converter": "org.apache.kafka.connect.storage.StringConverter",     
     "tasks.max" : "1",
     "topics" : "my-topic",
     "aws.lambda.function.name" : "YOUR_LAMBDA_NAME",
     "aws.lambda.function.arn" : "YOUR_LAMBDA_ARN",
     "aws.lambda.invocation.type" : "sync",
     "aws.lambda.batch.size" : "50",
     "aws.lambda.region": "us-east-1",
     "aws.access.key.id": "YOUR_AWS_KEY",
     "aws.secret.access.key": "YOUR_AWS_SECRET",
     "behavior.on.error" : "fail",
     "confluent.topic.bootstrap.servers" : "broker1:29092,broker2:26092,broker3:27092",
     "confluent.topic.replication.factor" : "1",
     "reporter.bootstrap.servers": "broker1:29092,broker2:26092,broker3:2709"
   }
 }

```

```sh
curl -s -X POST -H 'Content-Type: application/json' --data @connector.json http://localhost:8083/connectors
```

## Run Example

### Produce messages

```sh
docker exec -it broker1 bash
kafka-console-producer --broker-list broker1:9092 --topic my-topic --property "parse.key=true" --property "key.separator=:"
# create some messagens and press enter. Example:
# key1:value1
# key2:value2
# key3:value3
```

The Kafka Connect should read the messages of the topic and send to Lambda Handler that will print the message content in the logwatch.
