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

existing_images=$(docker images | grep springcommunity | awk '{print $1}')

if [ -z "$existing_images" ]; then
    docker pull springcommunity/spring-petclinic-discovery-server
    docker pull springcommunity/spring-petclinic-config-server 
    docker pull springcommunity/spring-petclinic-api-gateway
    docker pull springcommunity/spring-petclinic-customers-service
    docker pull springcommunity/spring-petclinic-vets-service
    docker pull springcommunity/spring-petclinic-visits-service
fi

# Push to ACR
docker tag springcommunity/spring-petclinic-discovery-server:latest $acr_url/springcommunity/spring-petclinic-discovery-server:latest
docker push $acr_url/springcommunity/spring-petclinic-discovery-server:latest

docker tag springcommunity/spring-petclinic-config-server:latest $acr_url/spring-petclinic-config-server:latest
docker push $acr_url/springcommunity/spring-petclinic-config-server:latest

docker tag springcommunity/spring-petclinic-api-gateway:latest $acr_url/springcommunity/spring-petclinic-api-gateway:latest
docker push $acr_url/springcommunity/spring-petclinic-api-gateway:latest

docker tag springcommunity/spring-petclinic-customers-service:latest $acr_url/springcommunity/spring-petclinic-customers-service:latest
docker push $acr_url/springcommunity/spring-petclinic-customers-service:latest

docker tag springcommunity/spring-petclinic-vets-service:latest $acr_url/springcommunity/spring-petclinic-vets-service:latest
docker push $acr_url/springcommunity/spring-petclinic-vets-service:latest