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

3. Deploy nginx ingress controller and Argo CD
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

5. Deploy Argo CD resources (repo, repo-creds, apps)
``` shell
./scripts/argocd.sh
```

6. Log in to Argo CD and verify if the app is created
``` shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
