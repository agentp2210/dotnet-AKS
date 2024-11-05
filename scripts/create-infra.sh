#!/bin/bash
cd "$(dirname "$0")"

# Exit script immediately if any command exits with a non-zero exit code
# set -e

read -p "Service principal ID: " sp_id
read -p "Service principal secret: " sp_secret

rg_name=$(az group list --query "[].name" -o tsv)
rg_id=$(az group list --query "[].id" -o tsv)
location=$(az group list --query "[].location" -o tsv)
sa_name=tfstate$RANDOM$(date +'%m%d%y')
container_name="tfstate"

# Create backend for terraform
existing_sa=$(az storage account list --query "[].name" -o tsv | grep tfstate)
if [ -z $existing_sa ]; then
    echo "Creating terraform remote backend"
    az storage account create --name $sa_name --resource-group $rg_name 1>/dev/null
    echo "Created storage account $(az storage account list --query "[].name" -o tsv)"
else
    echo "tfstate storage account already exist with name $existing_sa"
    sa_name=$existing_sa
fi

existing_container=$(az storage container list --account-name $sa_name -o tsv) 
if [ -z $existing_container ]; then
    az storage container create --name $container_name --account-name $sa_name
    echo "Created storage container $(az storage container list --account-name $sa_name --auth-mode login --query "[].name" -o tsv)"
fi

# Init with remote backend
cd ../terraform
rm -r .terraform

terraform init \
    -backend-config="resource_group_name=$rg_name" \
    -backend-config="key=terraform.tfstate" \
    -backend-config="container_name=$container_name" \
    -backend-config="storage_account_name=$sa_name"

# Create the infra
terraform apply -var="resource_group_name=$rg_name" -var="rg_id=$rg_id" -var="location=$location" \
-var="client_id=$sp_id" -var="client_secret=$sp_secret" \
-var-file="./vars/dev.tfvars" --auto-approve

cluster_name=$(az aks list --query "[].name" -o tsv)
az aks get-credentials --name $cluster_name --resource-group $rg_name --overwrite-existing

kubectl get node

# Assign permission to the system-managed identity of the AKS node pool to access the keyvault
# This only works when AKS uses managed identity
# echo "assigning permission for AKS nodepool to access the key vault"
# IDENTITY_OBJECT_ID=$(az aks show --resource-group $rg_name --name $cluster_name --query addonProfiles.azureKeyvaultSecretsProvider.identity.objectId -o tsv)
# keyvault_name=$(az keyvault list --query "[].name" -o tsv)

# az keyvault set-policy --name $keyvault_name --key-permissions get --object-id $IDENTITY_OBJECT_ID
