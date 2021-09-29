# flink-reactive-mode-k8s-demo


```
# build image
docker build -t donaschmitz/flink:1.13.0-reactive-demo .

# publish image
docker push donaschmitz/flink:1.13.0-reactive-demo



sudo snap install kubectl --classic
sudo snap install helm --classic


# start kind
kind create cluster

# install metrics server (needed for autoscaler)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
kubectl patch deployment metrics-server -n kube-system -p '{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp", "--secure-port=4443", "--kubelet-insecure-tls","--kubelet-preferred-address-types=InternalIP"]}]}}}}'

kubectl create namespace reactive
kubectl config set-context --current --namespace=reactive

# launch
kubectl apply -f flink-configuration-configmap.yaml
kubectl apply -f jobmanager-application.yaml
kubectl apply -f jobmanager-rest-service.yaml
kubectl apply -f jobmanager-service.yaml
kubectl apply -f taskmanager-job-deployment.yaml

# remove
kubectl delete -f flink-configuration-configmap.yaml
kubectl delete -f jobmanager-application.yaml
kubectl delete -f jobmanager-rest-service.yaml
kubectl delete -f jobmanager-service.yaml
kubectl delete -f taskmanager-job-deployment.yaml

# connect (doesn't work?!)
kubectl proxy

# connect to Flink UI
kubectl port-forward flink-jobmanager-rp4zv 8081

# scale manually
kubectl scale --replicas=3 deployments/flink-taskmanager

# probably based on: https://www.magalix.com/blog/kafka-on-kubernetes-and-deploying-best-practice
# start zookeeper
kubectl apply -f zookeeper-service.yaml
kubectl apply -f zookeeper-deployment.yaml

# start kafka
kubectl apply -f kafka-service.yaml
kubectl apply -f kafka-deployment.yaml

# launch a container for running the data generator
kubectl run workbench --image=ubuntu:21.04 -- sleep infinity

# connect to workbench
kubectl exec --stdin --tty workbench -- bash

# prep
apt update
apt install -y maven git htop nano iputils-ping wget net-tools
git clone https://github.com/donaschmi/flink-reactive-mode-k8s-demo.git
mvn clean install

# run data generator
mvn exec:java -Dexec.mainClass="org.apache.flink.DataGen" -Dexec.args="topic 1 kafka-service:9092 [manual|cos]"

# delete workbench
kubectl delete pod workbench

export JOB_POD_NAME=$(kubectl get pods --namespace reactive -l "app=flink,component=jobmanager" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $JOB_POD_NAME 8081:8081

# make kafka available locally:
export KAFKA_POD_NAME=$(kubectl get pods --namespace reactive -l "app=kafka" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $KAFKA_POD_NAME 9092:9092


# scale automatically
kubectl autoscale deployment flink-taskmanager --min=1 --max=15 --cpu-percent=35

# remove autoscaler
kubectl delete horizontalpodautoscalers flink-taskmanager


# prometheus
export PROM_POD_NAME=$(kubectl get pods --namespace reactive -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $PROM_POD_NAME 9090
# grafana
export GRAFANA_POD_NAME=$(kubectl get pods --namespace reactive -l "app.kubernetes.io/instance=grafana,app.kubernetes.io/name=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $GRAFANA_POD_NAME 3000


# scales:
# 1 taskmanager: 20000
# 2 taskamangers: 25000
# 4 taskmanagers: 45000
# 3 taskmanagers: < 50000
# 4 taskmanagers: 55000
# 
# 9 Taskmanagers: 75000
```
