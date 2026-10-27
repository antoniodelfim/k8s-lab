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

# O manifest oficial não fixa nodeSelector, apenas tolera o taint do control-plane.
# Forçamos o agendamento no node com o label ingress-ready=true, que é onde o
# cluster-config.yaml mapeia as portas 8080/8443 do host.
kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' \
  -p '[{"op":"add","path":"/spec/template/spec/nodeSelector/ingress-ready","value":"true"}]'

kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=120s
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "Cluster pronto."
