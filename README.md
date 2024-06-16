1. Create the infra
``` shell
./scripts/create-infra.sh
```

2. Build and push docker images
``` shell
./scripts/push-to-ACR.sh
```

*Notes: To view sample Dockerfile go to https://github.com/spring-petclinic/spring-petclinic-microservices/blob/main/docker/Dockerfile and https://github.com/dockersamples/spring-petclinic-docker/blob/main/Dockerfile.multi*

3. Deploy k8s resources
``` shell
./scripts/deploy-k8s-res.sh
```

4. Update DNS
Go to https://dashboard.godaddy.com/venture?domainName=anhalan.nl