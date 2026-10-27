#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="k8s-lab"

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster '${CLUSTER_NAME}' já existe."
else
  kind create cluster --config kind/cluster-config.yaml
fi

kubectl cluster-info --context "kind-${CLUSTER_NAME}"

echo "Instalando ingress-nginx..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Cluster pronto."
