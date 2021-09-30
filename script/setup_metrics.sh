#!/bin/bash

HELM=${HELM:-helm}
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


helm_install() {
  local name chart namespace

  name="$1"; shift
  chart="$1"; shift
  namespace="$1"; shift

  $HELM \
    --namespace "$namespace" \
    upgrade --install "$name" "$chart" \
    "$@"
}

export VVP_NAMESPACE="reactive"

install_prometheus() {
  helm_install prometheus prometheus "$VVP_NAMESPACE" \
    --repo https://prometheus-community.github.io/helm-charts \
    --values $SCRIPT_DIR/values-prometheus.yaml
}

install_grafana() {
  helm_install grafana grafana "$VVP_NAMESPACE" \
    --repo https://grafana.github.io/helm-charts \
    --values $SCRIPT_DIR/values-grafana.yaml \
    --set-file dashboards.default.flink-dashboard.json=$SCRIPT_DIR/grafana-dashboard.json
}

install_prometheus

helm uninstall grafana
install_grafana

