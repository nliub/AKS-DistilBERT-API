#!/bin/bash

TAG=$(git rev-parse --short HEAD)

az aks get-credentials --name w255-aks --resource-group w255 --overwrite-existing
kubectl config use-context w255-aks
az acr login --name w255mids

docker build --platform linux/amd64 -t w255mids.azurecr.io/nicoleliu/project:$TAG .

docker push w255mids.azurecr.io/nicoleliu/project:$TAG

sed "s/\[TAG\]/${TAG}/g" .k8s/overlays/prod/patch-deployment-project_copy.yaml > .k8s/overlays/prod/patch-deployment-project.yaml

# deploy
kubectl apply -k .k8s/overlays/prod

# wait for the /health endpoint to return a 200 and then move on
finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "http://nicoleliu.mids255.com/health" -L)
    if [ $health_status == "200" ]; then
        finished=true
        echo "API is ready"
    else
        echo "API not responding yet"
        sleep 5
    fi
done

kubectl get pods -n nicoleliu
# output and tail the logs for the api deployment
# kubectl logs -n ${NAMESPACE} -l app=${APP_NAME}
# kubectl delete all --all -n nicoleliu
