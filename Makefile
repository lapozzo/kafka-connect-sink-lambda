start-kafka:
	cd ./confluent-kafka && \
	docker-compose up

create-topic:
	docker exec broker1 kafka-topics --create --zookeeper zookeeper:2181 --replication-factor 3 --partitions 3 --topic my-topic

msg-producer:
	docker exec broker1 kafka-console-producer --broker-list broker1:9092 --topic my-topic

