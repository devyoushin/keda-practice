# KEDA 업그레이드 가이드

KEDA 업그레이드는 Helm chart로 Operator, Metrics API Server, Admission Webhook을 갱신하는 절차입니다. 업그레이드 전 `ScaledObject`, `ScaledJob`, 인증 리소스가 정상인지 확인합니다.

## 1. 사전 점검

```bash
export TARGET_VERSION="2.16.2"
export KEDA_NAMESPACE="keda"

kubectl get scaledobject,scaledjob -A
kubectl get triggerauthentication,clustertriggerauthentication -A
kubectl get pods -n ${KEDA_NAMESPACE}
helm get values keda -n ${KEDA_NAMESPACE} > keda-values-before-upgrade.yaml
```

Kafka, Redis, Prometheus, CloudWatch 같은 외부 scaler는 업그레이드 중 일시적으로 metric 수집이 지연될 수 있으므로 HPA 상태를 함께 확인합니다.

## 2. Helm 업그레이드

이 저장소의 실행 스크립트를 사용합니다.

```bash
TARGET_VERSION=${TARGET_VERSION} \
KEDA_NAMESPACE=${KEDA_NAMESPACE} \
./ops/upgrade/upgrade-keda-helm.sh
```

직접 실행하려면 아래 명령을 사용합니다.

```bash
helm repo update kedacore
helm upgrade keda kedacore/keda \
  --namespace ${KEDA_NAMESPACE} \
  --version ${TARGET_VERSION} \
  --values ops/install/keda-values.yaml \
  --wait
```

## 3. 업그레이드 확인

```bash
kubectl rollout status deployment/keda-operator -n ${KEDA_NAMESPACE}
kubectl rollout status deployment/keda-operator-metrics-apiserver -n ${KEDA_NAMESPACE}
kubectl get apiservice v1beta1.external.metrics.k8s.io
kubectl get scaledobject,scaledjob -A
```

스케일링이 동작하는지 확인하려면 기존 실습 워크로드의 metric을 발생시키고 HPA replica 변화와 KEDA operator 로그를 확인합니다.

## 4. 롤백

```bash
helm history keda -n ${KEDA_NAMESPACE}
helm rollback keda <REVISION> -n ${KEDA_NAMESPACE} --wait
kubectl rollout status deployment/keda-operator -n ${KEDA_NAMESPACE}
```

CRD 변경이 포함된 버전에서는 rollback 후에도 리소스 필드 호환성 문제가 남을 수 있습니다. 메이저 버전 변경 전에는 `kubectl get scaledobject,scaledjob -A -o yaml` 결과를 별도 보관합니다.

