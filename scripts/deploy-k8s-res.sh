#!/bin/bash
start=`date +%s`
cd "$(dirname "$0")"

# Create nginx ingress controller
echo "Installing nginx ingress controller"
helm upgrade --install nginx-ingress -n nginx-ingress --create-namespace oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller
sleep 20

echo "IP address of ingress controller: $(kubectl -n nginx-ingress get svc nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "Please update the DNS record accordingly"

# Deploy Argo CD
echo "Installing Argo CD"
argocd_host="argocd.anhalan.nl"
helm upgrade --install -n argocd --create-namespace --set server.ingress.enabled="true" \
--set server.ingress.ingressClassName="nginx" --set global.domain=$argocd_host \
--set configs.params."server\.insecure"=true argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd

sleep 10

# Check if argo cd is ready
status_code=$(curl -I $argocd_host 2>/dev/null | head -n 1 | cut -d$' ' -f2)
if [ $status_code != 200 ]; then
    sleep 30
fi

latest_status_code=$(curl -I $argocd_host 2>/dev/null | head -n 1 | cut -d$' ' -f2)
echo "Argo CD status code: $latest_status_code"

argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Argo CD password: $argocd_password"

end=`date +%s`
runtime=$((end-start))
echo "Runtime: $runtime"

# Deploy kube-state-metrics
helm install kube-state-metrics -n monitoring --create-namespace oci://registry-1.docker.io/bitnamicharts/kube-state-metrics