1. Create the infra
``` shell
./scripts/create-infra.sh
```

2. Build and push docker images
``` shell
./scripts/push-to-ACR.sh
```

*Notes: To view sample Dockerfile go to https://github.com/spring-petclinic/spring-petclinic-microservices/blob/main/docker/Dockerfile and https://github.com/dockersamples/spring-petclinic-docker/blob/main/Dockerfile.multi*

3. Deploy nginx ingress controller
``` shell
helm install nginx-ingress oci://registry-1.docker.io/bitnamicharts/nginx-ingress-controller
```

4. Update DNS
Get the IP address of the ingress controller:
``` shell
kubectl get svc nginx-ingress-nginx-ingress-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```
Go to https://dashboard.godaddy.com/venture?domainName=anhalan.nl
Update the A record to the IP address of the LB created by nginx ingress controller

5. Deploy app to k8s
``` shell
cd helm/sampleapp
acr_url=$(az acr list --query "[].loginServer" -o tsv)
helm install sampleapp --set image.repository="$acr_url/sampleapp"
```