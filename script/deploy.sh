#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

kubectl create namespace reactive
kubectl config set-context --current --namespace=reactive

kubectl apply -f $SCRIPT_DIR/zookeeper
kubectl apply -f $SCRIPT_DIR/kafka
kubectl apply -f $SCRIPT_DIR/flink

echo "Waiting for everything to be ready"

  kubectl wait --timeout=5m --for=condition=available deployments --all
  kubectl wait --timeout=5m --for=condition=ready pods --all
   
kubectl autoscale deployment flink-taskmanager --min=1 --max=15 --cpu-percent=35
