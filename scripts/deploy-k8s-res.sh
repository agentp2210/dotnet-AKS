#!/bin/bash
cd "$(dirname "$0")"

cd ../k8s

# Create db
kubectl apply -f mysql-config-persistentvolumeclaim.yaml
kubectl apply -f mysql-data-persistentvolumeclaim.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml

# Create petclinic
acr_url=$(az acr list --query "[].loginServer" -o tsv)

sed -e "s/111122223333.azurecr.io/$acr_url/g" "petclinic-deployment.yaml" | kubectl apply -f -
kubectl apply -f petclinic-service.yaml
