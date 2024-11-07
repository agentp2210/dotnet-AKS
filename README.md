# Prerequisites

- az cli
- docker
- Terraform
- kubectl
- Helm
- ArgoCD CLI

# Steps:

1. Log in to Azure and run the first-steps.sh script.
It will create the infra, build and push docker image to ACR, deploy nginx ingress
``` shell
az login -u '' -p ''
./scripts/first-steps.sh
```

2. Update DNS
Get the IP address of the ingress controller:
``` shell
kubectl get svc nginx-ingress-nginx-ingress-controller -n nginx-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
Go to https://dcc.godaddy.com/control/portfolio/anhalan.nl/settings?tab=dns&itc=mya_vh_buildwebsite_domain
Update the A record to the IP address of the LB created by nginx ingress controller

3. Run the below script to deploy ArgoCD and its resources, Prometheus, Grafana, Loki
``` shell
./scripts/k8s-addons-steps.sh
```

4. Log in to Argo CD and verify if the app is created
``` shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d ; echo
```

5. Log in to Grafana and verify if the data source of Prometheus, Loki are added
``` shell
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

6. Import the Grafana dashboard Cluster-Overview.json in helm/grafana/dashboards/ and view it
