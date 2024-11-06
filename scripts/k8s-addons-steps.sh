#!/bin/bash
cd "$(dirname "$0")"
set -e

./argocd.sh
./monitoring.sh