# Prometheus Scaler

Prometheus scaler는 Prometheus의 PromQL 쿼리 결과값을 기반으로 파드를 스케일링합니다.
애플리케이션이 노출하는 커스텀 메트릭이나 인프라 메트릭 등 Prometheus에 수집된 모든 메트릭을 활용할 수 있습니다.

---

## 1. 동작 방식

```
Application → Prometheus (메트릭 수집)
                │
                ▼
[KEDA Operator] → PromQL 쿼리 실행
                │
                ▼
 쿼리 결과값 / threshold = 목표 파드 수
                │
                ▼
Deployment 스케일 아웃
```

예시: 쿼리 결과 = 500 (RPS), threshold = 100 → 목표 파드 수 = 5

---

## 2. 기본 설정

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: my-app
  minReplicaCount: 1
  maxReplicaCount: 20
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus-server.monitoring:9090   # Prometheus 주소
        metricName: http_requests_per_second                      # 메트릭 이름 (임의 지정)
        query: sum(rate(http_requests_total{job="my-app"}[2m]))   # PromQL 쿼리
        threshold: "100"                                          # 파드 1개당 처리할 값
```

---

## 3. activationThreshold 활용

`activationThreshold`를 설정하면 메트릭이 해당 값을 초과할 때만 Scale from Zero합니다.
minReplicaCount가 0일 때 불필요한 스케일 아웃을 방지합니다.

```yaml
triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-server.monitoring:9090
      metricName: http_requests_per_second
      query: sum(rate(http_requests_total{job="my-app"}[2m]))
      threshold: "100"
      activationThreshold: "10"    # 이 값 이하일 때는 Scale from Zero 하지 않음
```

---

## 4. 인증이 필요한 Prometheus 설정

Bearer Token 방식:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: prometheus-secret
  namespace: default
type: Opaque
stringData:
  bearerToken: "eyJhbGciOi..."
```

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: prometheus-trigger-auth
  namespace: default
spec:
  secretTargetRef:
    - parameter: bearerToken
      name: prometheus-secret
      key: bearerToken
```

```yaml
triggers:
  - type: prometheus
    metadata:
      serverAddress: https://prometheus.example.com
      metricName: my_metric
      query: my_metric_query
      threshold: "100"
      authModes: "bearer"
    authenticationRef:
      name: prometheus-trigger-auth
```

---

## 5. 유용한 PromQL 예시

| 목적 | PromQL |
|------|--------|
| HTTP RPS | `sum(rate(http_requests_total[2m]))` |
| 특정 서비스 RPS | `sum(rate(http_requests_total{service="my-app"}[2m]))` |
| 평균 응답 시간 | `avg(http_request_duration_seconds{quantile="0.95"})` |
| 큐 대기 수 | `rabbitmq_queue_messages{queue="my-queue"}` |
| CPU 사용률 | `avg(rate(container_cpu_usage_seconds_total{pod=~"my-app-.*"}[2m]))` |

---

## 6. 주요 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `serverAddress` | O | Prometheus 서버 주소 |
| `query` | O | PromQL 쿼리 |
| `threshold` | O | 파드 1개당 허용 메트릭 값 |
| `metricName` | X | 메트릭 식별 이름 (HPA에 표시됨) |
| `activationThreshold` | X | Scale from Zero 시작 기준값 |
| `authModes` | X | 인증 방식 (`bearer` / `basic` / `tls`) |
| `namespace` | X | Thanos 등 사용 시 네임스페이스 지정 |

---

## 7. 상태 확인

```bash
# ScaledObject 상태 및 현재 메트릭 값 확인
kubectl describe scaledobject prometheus-scaledobject -n default

# HPA 메트릭 확인
kubectl get hpa -n default
kubectl describe hpa keda-hpa-my-app -n default
```

---

## 참고

- [Prometheus Scaler 공식 문서](https://keda.sh/docs/latest/scalers/prometheus/)
- [PromQL 공식 문서](https://prometheus.io/docs/prometheus/latest/querying/basics/)
