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
kubectl get svc nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
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
helm install -n argocd --create-namespace --set server.ingress.enabled="true" \
--set server.ingress.ingressClassName="nginx" --set server.ingress.hostname="argocd.anhalan.nl" \
argo-cd oci://ghcr.io/argoproj/argo-helm/argo-cd
```

7. Log in to Argo CD
``` shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```