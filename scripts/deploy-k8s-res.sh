#!/bin/bash
start=`date +%s`
cd "$(dirname "$0")"

# Create nginx ingress controller
echo "Installing nginx ingress controller"
helm upgrade --install nginx-ingress -n nginx-ingress --create-namespace oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller

# Deploy the app
acr_url=$(az acr list --query "[].loginServer" -o tsv)
acr=$(az acr list --query "[].name" -o tsv)
az acr login --name $acr

cd ../helm/sampleapp
helm upgrade --install sampleapp -n sampleapp --create-namespace --set image.repository="$acr_url/sampleapp" .

sleep 20

echo "IP address of ingress controller: $(kubectl -n nginx-ingress get svc nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "Please update the DNS record accordingly"

end=`date +%s`
runtime=$((end-start))
echo "Runtime: $runtime"