#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${TARGET_VERSION:?set TARGET_VERSION}"
KEDA_NAMESPACE="${KEDA_NAMESPACE:-keda}"

kubectl get scaledobject,scaledjob -A
kubectl get pods -n "${KEDA_NAMESPACE}"

helm repo update kedacore
helm upgrade keda kedacore/keda \
  --namespace "${KEDA_NAMESPACE}" \
  --version "${TARGET_VERSION}" \
  --values "$(dirname "$0")/../install/keda-values.yaml" \
  --wait

kubectl rollout status deployment/keda-operator -n "${KEDA_NAMESPACE}"
kubectl get apiservice v1beta1.external.metrics.k8s.io
