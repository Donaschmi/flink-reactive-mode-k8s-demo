#!/bin/bash

start_forwarding() {
  export UI_POD_NAME=$(kubectl get pods --namespace reactive -l "app=flink,component=jobmanager" -o jsonpath="{.items[0].metadata.name}")
  export PROM_POD_NAME=$(kubectl get pods --namespace reactive -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
  export GRAFANA_POD_NAME=$(kubectl get pods --namespace reactive -l "app.kubernetes.io/instance=grafana,app.kubernetes.io/name=grafana" -o jsonpath="{.items[0].metadata.name}")
  export KAFKA_POD_NAME=$(kubectl get pods --namespace reactive -l "app=kafka" -o jsonpath="{.items[0].metadata.name}")

  kubectl port-forward $UI_POD_NAME 8081:8081 &> /dev/null &
  kubectl port-forward $KAFKA_POD_NAME 9092:9092 &> /dev/null &
  kubectl port-forward $PROM_POD_NAME 9090:9090 &> /dev/null &
  kubectl port-forward $GRAFANA_POD_NAME 3000:3000 &> /dev/null &
}

stop_forwarding() {
  ps -ef | grep 'port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill -9
}

if [ $1 ]; then
  if [ "$1" = "stop" ]; then
    stop_forwarding
  fi
else
  start_forwarding
fi
