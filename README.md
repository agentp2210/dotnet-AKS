1. Create the infra
``` shell
./scripts/create-infra.sh
```

2. Build and push docker images
``` shell
./scripts/push-to-ACR.sh
```

3. Deploy nginx ingress controller
``` shell
helm install nginx-ingress -n nginx-ingress --create-namespace oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller
```

4. Update DNS
Get the IP address of the ingress controller:
``` shell
kubectl get svc nginx-ingress-nginx-ingress-controller -n nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
Go to https://dcc.godaddy.com/control/portfolio/anhalan.nl/settings?tab=dns&itc=mya_vh_buildwebsite_domain
Update the A record to the IP address of the LB created by nginx ingress controller

5. Deploy app to k8s
``` shell
cd helm/sampleapp
acr_url=$(az acr list --query "[].loginServer" -o tsv)
helm install sampleapp -n sampleapp --create-namespace --set image.repository="$acr_url/sampleapp" .
```

6. Deploy Argo CD
``` shell
helm upgrade --install -n argocd --create-namespace --set server.ingress.enabled="true" \
--set server.ingress.ingressClassName="nginx" --set global.domain="argocd.anhalan.nl" \
--set configs.params."server\.insecure"=true argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd
```

7. Log in to Argo CD
``` shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

8. Create ArgoCD app
``` shell
argocd login argocd.anhalan.nl --insecure --username admin --password "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
argocd app create sampleapp --repo git@github.com:agentp2210/dotnet-AKS.git --path "helm/sampleapp" --dest-namespace sampleapp --dest-server https://kubernetes.default.svc --helm-set image.repository="$acr_url/sampleapp"
```