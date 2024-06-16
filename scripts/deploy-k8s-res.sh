#!/bin/bash
cd "$(dirname "$0")"

cd ../k8s

# Create nginx ingress controller
helm install nginx-ingress -n nginx-ingress --create-namespace oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller

# Create k8s resources
acr_url=$(az acr list --query "[].loginServer" -o tsv)

sed -e "s/k8sexamplesacr.azurecr.io/$acr_url/g" "deployment.yaml" | kubectl apply -f -
kubectl apply -f service.yaml

echo "IP address of ingress controller: $(kubectl get svc nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
