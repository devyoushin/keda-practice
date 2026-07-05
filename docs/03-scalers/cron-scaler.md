# Cron Scaler

Cron scaler는 지정한 시간 범위에 맞춰 파드 수를 조절합니다.
외부 이벤트 소스 없이 시간 기반으로만 스케일링이 필요하거나,
이벤트 기반 스케일러와 조합해 업무 시간 최소 파드를 보장할 때 사용합니다.

---

## 1. 동작 방식

```
현재 시각이 start 시각 도달
 │
 ▼
desiredReplicas 수만큼 스케일 아웃
 │
 ▼
end 시각 도달
 │
 ▼
minReplicaCount로 스케일 인
```

> 여러 trigger가 활성화된 시간대가 겹치면 **가장 높은 `desiredReplicas`** 값이 적용됩니다.

---

## 2. 기본 설정

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: cron-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: my-deployment
  minReplicaCount: 1             # 비활성 시간대 파드 수
  maxReplicaCount: 10
  triggers:
    - type: cron
      metadata:
        timezone: Asia/Seoul     # IANA 타임존 (필수)
        start: "0 9 * * 1-5"    # 평일 오전 9시 스케일 아웃
        end: "0 18 * * 1-5"     # 평일 오후 6시 스케일 인
        desiredReplicas: "5"    # 활성 시간대 목표 파드 수
```

---

## 3. 여러 시간대 설정

trigger를 여러 개 지정하면 각 시간대마다 다른 파드 수를 설정할 수 있습니다.

```yaml
triggers:
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "0 9 * * 1-5"      # 평일 오전 — 일반 트래픽
      end: "0 12 * * 1-5"
      desiredReplicas: "3"
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "0 12 * * 1-5"     # 평일 점심 — 트래픽 피크
      end: "0 13 * * 1-5"
      desiredReplicas: "8"
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "0 9 * * 6"        # 토요일 — 최소 운영
      end: "0 18 * * 6"
      desiredReplicas: "2"
```

---

## 4. 주요 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `timezone` | O | IANA 타임존 (예: `Asia/Seoul`, `UTC`) |
| `start` | O | 스케일 아웃 시작 시각 (cron 표현식) |
| `end` | O | 스케일 인 시작 시각 (cron 표현식) |
| `desiredReplicas` | O | 활성 시간대 목표 파드 수 |

cron 표현식 형식: `분 시 일 월 요일`

| 표현식 | 의미 |
|--------|------|
| `0 9 * * 1-5` | 평일 오전 9시 |
| `0 18 * * *` | 매일 오후 6시 |
| `30 8 * * 1-5` | 평일 오전 8시 30분 |
| `0 0 * * 0` | 일요일 자정 |

---

## 5. 이벤트 스케일러와 조합 (권장 패턴)

Cron 단독 사용보다 이벤트 기반 스케일러와 조합하면 더 유연한 운영이 가능합니다.
두 trigger 중 **높은 값이 적용**되므로, Cron은 "최소 보장" 역할을 합니다.

### 패턴 1 — CloudWatch (SQS) + Cron

```yaml
triggers:
  # 이벤트 기반: SQS 큐가 차면 스케일 아웃
  - type: aws-cloudwatch
    metadata:
      namespace: AWS/SQS
      metricName: ApproximateNumberOfMessagesVisible
      dimensionName: QueueName
      dimensionValue: my-task-queue
      targetMetricValue: "10"
      minMetricValue: "0"
      metricStat: Maximum
      metricStatPeriod: "60"
      metricCollectionTime: "120"
      region: ap-northeast-2
    authenticationRef:
      name: cloudwatch-trigger-auth
  # 시간 기반: 업무 시간에는 최소 3개 보장
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "0 9 * * 1-5"
      end: "0 18 * * 1-5"
      desiredReplicas: "3"
```

### 패턴 2 — Prometheus + Cron

```yaml
triggers:
  # 이벤트 기반: HTTP 트래픽에 따라 스케일 아웃
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-server.monitoring:9090
      query: sum(rate(http_requests_total{service="my-api"}[2m]))
      threshold: "100"
  # 시간 기반: 영업 시간 최소 파드 사전 확보 (트래픽 급증 대비 pre-warming)
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "50 8 * * 1-5"     # 오전 8시 50분에 미리 확보
      end: "0 19 * * 1-5"
      desiredReplicas: "5"
```

---

## 6. Pre-warming 패턴

배포 타임아웃, JVM Warm-up 등으로 파드 기동 시간이 길 경우,
트래픽이 몰리기 **전에** 미리 파드를 확보하는 패턴입니다.

```yaml
triggers:
  # 오전 8시 50분에 미리 5개 확보 → 9시 트래픽 급증에 대비
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "50 8 * * 1-5"
      end: "0 9 * * 1-5"
      desiredReplicas: "5"
  # 실제 업무 시간 운영
  - type: cron
    metadata:
      timezone: Asia/Seoul
      start: "0 9 * * 1-5"
      end: "0 18 * * 1-5"
      desiredReplicas: "10"
```

---

## 7. Scale to Zero 활용

비용 최적화가 중요한 경우, 비업무 시간에는 파드를 0으로 줄일 수 있습니다.

```yaml
spec:
  minReplicaCount: 0            # 비활성 시간대에 Scale to Zero
  maxReplicaCount: 10
  triggers:
    - type: cron
      metadata:
        timezone: Asia/Seoul
        start: "0 9 * * 1-5"
        end: "0 18 * * 1-5"
        desiredReplicas: "5"
```

> **주의**: `minReplicaCount: 0`으로 설정하면 비활성 시간대에 파드가 완전히 내려갑니다.
> 서비스 가용성이 필요한 경우 `minReplicaCount: 1` 이상으로 유지하세요.

---

## 8. 운영 고려사항

### cooldownPeriod 설정

Cron scaler는 `cooldownPeriod`를 0으로 설정하는 것이 일반적입니다.
스케줄이 명확하므로 KEDA가 즉시 스케일 인해야 합니다.

```yaml
spec:
  cooldownPeriod: 0    # Cron trigger는 end 시각에 즉시 스케일 인
```

### timezone 확인

```bash
# 현재 KEDA Operator의 시각 확인 (UTC 기준으로 실행됨)
kubectl exec -n keda -l app=keda-operator -- date

# Asia/Seoul 기준 현재 시각
TZ=Asia/Seoul date
```

### 일시 정지

예기치 못한 상황(배포, 긴급 조치 등)에서 스케일링을 멈출 수 있습니다.

```bash
# 스케일링 일시 정지
kubectl annotate scaledobject cron-scaledobject \
  autoscaling.keda.sh/paused=true -n default

# 일시 정지 해제
kubectl annotate scaledobject cron-scaledobject \
  autoscaling.keda.sh/paused- -n default
```

---

## 9. 상태 확인

```bash
# ScaledObject 상태 확인
kubectl describe scaledobject cron-scaledobject -n default

# 현재 HPA 상태 및 Replicas 확인
kubectl get hpa -n default

# 파드 수 변화 실시간 모니터링
kubectl get pods -n default -w
```

---

## 10. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 스케일 아웃이 예상 시각에 되지 않음 | timezone 오설정 | IANA 타임존 이름 확인 (`Asia/Seoul`, `UTC` 등) |
| `start`/`end` 시각이 뒤바뀐 것처럼 동작 | UTC 기준으로 오해 | timezone 필드를 명시적으로 `Asia/Seoul`로 설정 |
| 여러 trigger 중 낮은 값이 적용됨 | KEDA 버그 또는 ScaledObject 설정 오류 | trigger 간 시간대 겹침 여부 재확인 |
| minReplicaCount로 돌아오지 않음 | 다른 trigger가 여전히 활성 | 다른 이벤트 기반 trigger 메트릭 확인 |
| Scale to Zero가 되지 않음 | `minReplicaCount: 0` 미설정 | spec.minReplicaCount를 0으로 변경 |

---

## 참고

- [Cron Scaler 공식 문서](https://keda.sh/docs/latest/scalers/cron/)
- [IANA 타임존 목록](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
