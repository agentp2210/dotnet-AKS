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
cd ../code

existing_image=$(docker images | grep petclinic | awk '{print $1}')

if [ -z "$existing_image" ]; then
    docker build -t petclinic . -f Dockerfile.multi
fi

# Push to ACR
docker tag petclinic:latest $acr_url/petclinic:latest
docker push $acr_url/petclinic:latest
