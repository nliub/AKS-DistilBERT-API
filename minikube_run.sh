#!/bin/bash

if [[ ${MINIKUBE_TUNNEL_PID:-"unset"} != "unset" ]]; then
    echo "Potentially existing Minikube Tunnel at PID: ${MINIKUBE_TUNNEL_PID}"
    kill ${MINIKUBE_TUNNEL_PID}
fi

minikube delete
minikube start --kubernetes-version=v1.27.3

eval $(minikube docker-env)

docker build -t pythonapi:latest .

kubectl apply -f .k8s/base/namespace.yaml
kubectl kustomize .k8s/base
kubectl apply -k .k8s/base
kubectl wait --for=condition=available --timeout=300s deployment/project -n nicoleliu
kubectl wait --for=condition=available --timeout=300s deployment/redis -n nicoleliu

kubectl get deployments -n nicoleliu
kubectl get pods -n nicoleliu

minikube tunnel &
export MINIKUBE_TUNNEL_PID=$!

finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://localhost:8000/health")
    if [ "$health_status" == "200" ]; then
        finished=true
        echo "API is ready"
    else
        echo "API not responding yet"
        sleep 5
    fi
done

echo "Testing /health endpoint:"
curl -X GET "http://localhost:8000/health"

echo "Testing /project-predict endpoint:"
curl -X POST "http://localhost:8000/project-predict" -H "Content-Type: application/json" -d '{"text": ["I love you!", "I hate you!", "I am a Kubernetes Cluster!"]}'

kill ${MINIKUBE_TUNNEL_PID}
kubectl delete all --all -n nicoleliu
minikube stop

eval $(minikube docker-env -u)
