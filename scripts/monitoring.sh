#!/bin/bash
cd "$(dirname "$0")"

grafana_host=grafana.anhalan.nl

# Deploy kube-state-metrics
helm install kube-state-metrics -n monitoring --create-namespace oci://registry-1.docker.io/bitnamicharts/kube-state-metrics

# Deploy prometheus and grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus -n monitoring --create-namespace prometheus-community/prometheus
helm upgrade --install grafana -n monitoring --create-namespace -f grafana/values.yaml --set ingress.enabled="true" \
--set ingress.annotations."kubernetes\.io/ingress\.class"="nginx" --set ingress.hosts={$grafana_host} grafana/grafana

grafana_pw=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
echo "Password to login: $grafana_pw"