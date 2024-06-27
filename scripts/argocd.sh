#!/bin/bash
cd "$(dirname "$0")"

# Deploy Argo CD
echo "Installing Argo CD"
helm upgrade --install -n argocd --create-namespace --set server.ingress.enabled="true" \
--set server.ingress.ingressClassName="nginx" --set global.domain="argocd.anhalan.nl" \
--set configs.params."server\.insecure"=true argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd

# Create ArgoCD apps
argocd login argocd.anhalan.nl --insecure --username admin --password "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
argocd app create sampleapp --repo git@github.com:agentp2210/dotnet-AKS.git --path "helm/sampleapp" --dest-namespace sampleapp --dest-server https://kubernetes.default.svc --helm-set image.repository="$acr_url/sampleapp"
argocd app create argo-cd --helm-chart oci://ghcr.io/argoproj/argo-helm/argo-cd --dest-namespace argocd \
--dest-server https://kubernetes.default.svc --helm-set server.ingress.enabled="true" \
--helm-set server.ingress.ingressClassName="nginx" --helm-set global.domain="argocd.anhalan.nl" \
--helm-set configs.params."server\.insecure"=true

# Output
echo "Argo CD password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"