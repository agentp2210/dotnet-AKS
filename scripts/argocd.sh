#!/bin/bash
cd "$(dirname "$0")"

# This's only required when creating resources using Argocd CLI
# if [ -z $1 ]; then
#     read -p "GitHub Token: " token
# else
#     token=$1
# fi

# Create ArgoCD resources declaratively
kubectl apply -f ../argocd/secrets/private-repo-creds.yaml
kubectl apply -f ../argocd/repos/dotnet-AKS.yaml
kubectl apply -f ../argocd/argocd-apps.yaml

acr_url=$(az acr list --query "[].loginServer" -o tsv)
cd ../argocd/apps
for config in $(ls ./*.yaml)
do
    sed -e "s/k8sexamplesacr.azurecr.io/$acr_url/g" $config | kubectl apply -f -
done

# Create ArgoCD resources using cli
# acr_url=$(az acr list --query "[].loginServer" -o tsv)
# argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# argocd login $argocd_host --insecure --username admin --password $argocd_password --grpc-web
# argocd app create sampleapp --repo git@github.com:agentp2210/dotnet-AKS.git --path "helm/sampleapp" --dest-namespace sampleapp --dest-server https://kubernetes.default.svc --helm-set image.repository="$acr_url/sampleapp"
# argocd app create argo-cd --repo https://argoproj.github.io/argo-helm --helm-chart argo-cd --dest-namespace argocd \
# --dest-server https://kubernetes.default.svc --helm-set server.ingress.enabled="true" \
# --helm-set server.ingress.ingressClassName="nginx" --helm-set global.domain=$argocd_host \
# --helm-set configs.params."server\.insecure"=true

# Output
# echo "Argo CD password: $argocd_password"

# Add repo
# https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/
# argocd repo add https://github.com/agentp2210/dotnet-AKS.git --name dotnet-AKS --username 'agentp2210' --password $token

