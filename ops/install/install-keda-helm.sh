#!/usr/bin/env bash
set -euo pipefail

KEDA_VERSION="${KEDA_VERSION:-2.16.1}"
KEDA_NAMESPACE="${KEDA_NAMESPACE:-keda}"

helm repo add kedacore https://kedacore.github.io/charts
helm repo update kedacore

kubectl create namespace "${KEDA_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install keda kedacore/keda \
  --namespace "${KEDA_NAMESPACE}" \
  --version "${KEDA_VERSION}" \
  --values "$(dirname "$0")/keda-values.yaml" \
  --wait

kubectl get pods -n "${KEDA_NAMESPACE}"
kubectl get crd | grep keda.sh
