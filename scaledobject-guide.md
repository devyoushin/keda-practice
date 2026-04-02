# ScaledObject

ScaledObject는 Deployment, StatefulSet 등의 워크로드를 외부 이벤트 소스 기반으로 자동 스케일링하는 KEDA의 핵심 리소스입니다.
내부적으로 HPA를 자동 생성하여 관리하며, minReplicaCount를 0으로 설정하면 Scale to Zero가 가능합니다.

---

## 1. 기본 구조

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: my-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: my-deployment          # 스케일링 대상 Deployment 이름
  minReplicaCount: 0             # 최소 파드 수 (0 = Scale to Zero)
  maxReplicaCount: 10            # 최대 파드 수
  pollingInterval: 30            # 이벤트 소스 폴링 주기 (초, 기본값: 30)
  cooldownPeriod: 300            # Scale to Zero 전 대기 시간 (초, 기본값: 300)
  triggers:
    - type: kafka                # 사용할 scaler 종류
      metadata:
        bootstrapServers: kafka:9092
        consumerGroup: my-group
        topic: my-topic
        lagThreshold: "10"
```

---

## 2. 주요 필드

| 필드 | 기본값 | 설명 |
|------|--------|------|
| `minReplicaCount` | 0 | 최소 파드 수. 0이면 Scale to Zero 활성화 |
| `maxReplicaCount` | 100 | 최대 파드 수 |
| `pollingInterval` | 30 | 이벤트 소스를 확인하는 주기 (초) |
| `cooldownPeriod` | 300 | 마지막 이벤트 이후 Scale to Zero까지 대기하는 시간 (초) |
| `idleReplicaCount` | - | 이벤트가 없을 때 유지할 파드 수 (0 대신 1을 유지하고 싶을 때) |

---

## 3. scaleTargetRef — 다양한 대상 지정

Deployment 외 다른 리소스도 대상으로 지정할 수 있습니다.

```yaml
spec:
  scaleTargetRef:
    apiVersion: apps/v1          # 기본값, 생략 가능
    kind: Deployment             # Deployment / StatefulSet / 커스텀 리소스
    name: my-deployment
```

---

## 4. 여러 Trigger 사용

trigger를 여러 개 지정하면 OR 조건으로 동작합니다. 하나라도 이벤트가 감지되면 스케일 아웃합니다.

```yaml
spec:
  triggers:
    - type: kafka
      metadata:
        bootstrapServers: kafka:9092
        consumerGroup: my-group
        topic: my-topic
        lagThreshold: "10"
    - type: prometheus
      metadata:
        serverAddress: http://prometheus:9090
        metricName: http_requests_total
        threshold: "100"
        query: sum(rate(http_requests_total[2m]))
```

---

## 5. 상태 확인

```bash
# ScaledObject 목록 조회
kubectl get scaledobject -n default

# 상세 조회 (스케일링 이유, 현재 메트릭 포함)
kubectl describe scaledobject my-scaledobject -n default

# KEDA가 자동 생성한 HPA 확인
kubectl get hpa -n default
```

```
NAME               REFERENCE                    TARGETS     MINPODS   MAXPODS   REPLICAS
keda-hpa-my-app   Deployment/my-deployment     0/10 (lag)  1         10        0
```

> KEDA가 생성한 HPA는 직접 수정하지 않습니다. ScaledObject를 수정하면 HPA가 자동으로 업데이트됩니다.

---

## 참고

- [ScaledObject 공식 문서](https://keda.sh/docs/latest/concepts/scaling-deployments/)
- [Scaler 목록](https://keda.sh/docs/latest/scalers/)
