# Prerequisites

- az cli
- docker
- Terraform
- kubectl
- Helm
- ArgoCD CLI

# Steps:

1. Log in to Azure and create the infra
``` shell
az login -u '' -p ''
./scripts/create-infra.sh
```

2. Build and push docker images
``` shell
./scripts/push-to-ACR.sh
```

3. Deploy nginx ingress controller and the app
``` shell
./scripts/deploy-k8s-res.sh
```

4. Update DNS
Get the IP address of the ingress controller:
``` shell
kubectl get svc nginx-ingress-nginx-ingress-controller -n nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
Go to https://dcc.godaddy.com/control/portfolio/anhalan.nl/settings?tab=dns&itc=mya_vh_buildwebsite_domain
Update the A record to the IP address of the LB created by nginx ingress controller

5. Deploy Argo CD and add the repo
``` shell
./scripts/argocd.sh
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