#!/bin/bash
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/../"

kubectl delete --wait=true -f $SCRIPT_DIR/zookeeper
kubectl delete --wait=true -f $SCRIPT_DIR/kafka
kubectl delete --wait=true -f $SCRIPT_DIR/flink

helm uninstall grafana
helm uninstall prometheus

kubectl delete --wait=true job data-injector

kubectl delete --wait=true deploy metrics-server -n kube-system
