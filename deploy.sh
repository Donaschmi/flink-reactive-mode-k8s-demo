#!/bin/bash
 
kubectl create namespace reactive
kubectl config set-context --current --namespace=reactive

kubectl apply -f zookeeper-service.yaml
kubectl apply -f zookeeper-deployment.yaml

kubectl apply -f kafka-service.yaml
kubectl apply -f kafka-deployment.yaml

kubectl apply -f flink-configuration-configmap.yaml
kubectl apply -f jobmanager-application.yaml
kubectl apply -f jobmanager-rest-service.yaml
kubectl apply -f jobmanager-service.yaml
kubectl apply -f taskmanager-job-deployment.yaml

echo "Waiting for everything to be ready"

  kubectl wait --timeout=5m --for=condition=available deployments --all
  kubectl wait --timeout=5m --for=condition=ready pods --all
   
kubectl autoscale deployment flink-taskmanager --min=1 --max=15 --cpu-percent=35
