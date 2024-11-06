#!/bin/bash
cd "$(dirname "$0")"

grafana_host=grafana.anhalan.nl

# Deploy kube-state-metrics
# helm install kube-state-metrics -n monitoring --create-namespace oci://registry-1.docker.io/bitnamicharts/kube-state-metrics

# Deploy prometheus and grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus -n monitoring --create-namespace prometheus-community/prometheus
# values.yaml is to define datasource
helm upgrade --install grafana -n monitoring --create-namespace -f ../helm/grafana/values.yaml --set ingress.enabled="true" \
--set ingress.hosts={$grafana_host} grafana/grafana

grafana_pw=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
echo "Password to login: $grafana_pw"

# Import dashboards using command line
# ref: https://github.com/grafana-toolbox/grafana-import

# Deploy grafana Loki
helm upgrade --install loki -n logging --create-namespace grafana/loki-stack
