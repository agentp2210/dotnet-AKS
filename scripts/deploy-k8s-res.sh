#!/bin/bash
cd "$(dirname "$0")"

cd ../k8s

# Create nginx ingress controller
helm install nginx-ingress oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller

# Create k8s resources
acr_url=$(az acr list --query "[].loginServer" -o tsv)

sed -e "s/k8sexamplesacr.azurecr.io/$acr_url/g" "deployment.yaml" | kubectl apply -f -
kubectl apply -f service.yaml
