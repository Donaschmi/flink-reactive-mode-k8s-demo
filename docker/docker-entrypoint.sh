#!/bin/bash
mvn exec:java -Dexec.mainClass="org.apache.flink.DataGen" -Dexec.args="topic 1 kafka-service:9092 cos"
