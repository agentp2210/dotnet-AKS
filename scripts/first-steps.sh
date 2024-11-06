#!/bin/bash
cd "$(dirname "$0")"
set -e

./create-infra.sh
./push-to-ACR.sh
./deploy-k8s-res.sh