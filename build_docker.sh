#!/bin/bash

cd reactive-mode-demo-jobs
mvn clean install
cd ..

docker build -t donaschmitz/flink:1.13.0-reactive-demo .
docker push donaschmitz/flink:1.13.0-reactive-demo
