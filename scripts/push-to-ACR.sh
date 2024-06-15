#!/bin/bash
cd $(dirname "$0")

acr_url=$(az acr list --query "[].loginServer" -o tsv)
az acr login --name $acr_url

# Remove image if exist
existing_image=$(docker images | grep azurecr | awk '{print $1}')
if [[ ! -z "$existing_image" ]]
then
    docker rmi $existing_image
fi

# Build images if not exist
cd ../code

existing_images=$(docker images | grep springcommunity | awk '{print $1}')

if [ -z "$existing_images" ]; then
    ./mvnw clean install -P buildDocker
fi

# Push to ACR
cd ../code

docker tag springcommunity/spring-petclinic-api-gateway:latest $acr_url/springcommunity/spring-petclinic-api-gateway:latest
docker push $acr_url/springcommunity/spring-petclinic-api-gateway:latest

docker tag springcommunity/spring-petclinic-discovery-server:latest $acr_url/springcommunity/spring-petclinic-discovery-server:latest
docker push $acr_url/springcommunity/spring-petclinic-discovery-server:latest

docker tag springcommunity/spring-petclinic-config-server:latest $acr_url/springcommunity/spring-petclinic-config-server:latest
docker push $acr_url/springcommunity/spring-petclinic-config-server:latest

docker tag springcommunity/spring-petclinic-visits-service:latest $acr_url/springcommunity/spring-petclinic-visits-service:latest
docker push $acr_url/springcommunity/spring-petclinic-visits-service:latest

docker tag springcommunity/spring-petclinic-vets-service:latest $acr_url/springcommunity/spring-petclinic-vets-service:latest
docker push $acr_url/springcommunity/spring-petclinic-vets-service:latest

docker tag springcommunity/spring-petclinic-customers-service:latest $acr_url/springcommunity/spring-petclinic-customers-service:latest
docker push $acr_url/springcommunity/spring-petclinic-customers-service:latest

docker tag springcommunity/spring-petclinic-admin-server:latest $acr_url/springcommunity/spring-petclinic-admin-server:latest
docker push $acr_url/springcommunity/spring-petclinic-admin-server:latest
