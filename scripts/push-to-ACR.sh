#!/bin/bash
cd $(dirname "$0")

acr_url=$(az acr list --query "[].loginServer" -o tsv)
az acr login --name $acr_url

# Remove image if exist
existing_images=$(docker images | grep azurecr | awk '{print $1}')
if [[ ! -z "$existing_images" ]]
then
    docker rmi $existing_images
fi

# Build images if not exist

existing_images=$(docker images | grep sampleapp | awk '{print $1}')

if [ -z "$existing_images" ]; then
    docker build -t sampleapp ../app
fi

# Push to ACR
docker tag sampleapp:latest $acr_url/sampleapp:latest
docker push $acr_url/sampleapp:latest
