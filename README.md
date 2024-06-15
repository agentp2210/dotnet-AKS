1. Create the infra
``` shell
aws configure
./scripts/create-infra.sh
```

2. Build and push docker images
``` shell
./scripts/push-to-ACR.sh
```

3. Deploy k8s resources
``` shell
./scripts/deploy-k8s-res.sh
```