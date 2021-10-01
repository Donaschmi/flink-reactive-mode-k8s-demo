#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

kubectl create namespace reactive
kubectl config set-context --current --namespace=reactive

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
kubectl patch deployment metrics-server -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp", "--secure-port=4443", "--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP"]}]}}}}'

kubectl apply -f $SCRIPT_DIR/../zookeeper
kubectl apply -f $SCRIPT_DIR/../kafka
kubectl apply -f $SCRIPT_DIR/../flink

echo "Waiting for everything to be ready"

  kubectl wait --timeout=5m --for=condition=available deployments --all
  kubectl wait --timeout=5m --for=condition=ready pods --all
   
$SCRIPT_DIR/setup_metrics.sh

if [ $1 ]; then
  if [ "$1" = "inject" ]; then
    kubectl apply -f $SCRIPT_DIR/../injector
  fi
fi
