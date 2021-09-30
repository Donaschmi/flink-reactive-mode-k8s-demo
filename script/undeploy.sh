#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

kubectl delete --wait=true -f $SCRIPT_DIR/zookeeper
kubectl delete --wait=true -f $SCRIPT_DIR/kafka
kubectl delete --wait=true -f $SCRIPT_DIR/flink

kubectl delete --wait=true horizontalpodautoscalers flink-taskmanager

kubectl delete --wait=true job data-injector
