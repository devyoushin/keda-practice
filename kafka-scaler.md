# Kafka Scaler

Kafka scaler는 Consumer Group의 lag(미처리 메시지 수)을 기반으로 파드를 스케일링합니다.
lag이 `lagThreshold`를 초과하면 파드를 추가하고, lag이 0이 되면 Scale to Zero합니다.

---

## 1. 동작 방식

```
Kafka Topic (lag 발생)
 │
 ▼
[KEDA Operator] → Consumer Group lag 수집
 │
 ▼
 lag / lagThreshold = 목표 파드 수
 │
 ▼
Deployment 스케일 아웃
```

예시: lag = 50, lagThreshold = 10 → 목표 파드 수 = 5

---

## 2. 인증 없는 기본 설정

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: kafka-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: kafka-consumer           # 대상 Deployment 이름
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
    - type: kafka
      metadata:
        bootstrapServers: kafka-broker:9092   # Kafka 브로커 주소
        consumerGroup: my-consumer-group      # Consumer Group 이름
        topic: my-topic                       # 감시할 토픽 이름
        lagThreshold: "10"                    # 파드 1개당 처리할 lag 수
        offsetResetPolicy: latest             # latest / earliest
```

---

## 3. SASL 인증 설정

Secret 생성:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kafka-secret
  namespace: default
type: Opaque
stringData:
  username: my-user
  password: my-password
```

TriggerAuthentication:

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: kafka-trigger-auth
  namespace: default
spec:
  secretTargetRef:
    - parameter: username
      name: kafka-secret
      key: username
    - parameter: password
      name: kafka-secret
      key: password
```

ScaledObject에 인증 추가:

```yaml
triggers:
  - type: kafka
    metadata:
      bootstrapServers: kafka-broker:9092
      consumerGroup: my-consumer-group
      topic: my-topic
      lagThreshold: "10"
      sasl: PLAIN                  # PLAIN / OAUTHBEARER / SCRAM-SHA-256 / SCRAM-SHA-512
      tls: enable                  # TLS 사용 시
    authenticationRef:
      name: kafka-trigger-auth
```

---

## 4. 주요 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `bootstrapServers` | O | Kafka 브로커 주소 (콤마로 여러 개 지정 가능) |
| `consumerGroup` | O | 모니터링할 Consumer Group 이름 |
| `topic` | X | 특정 토픽만 감시. 생략 시 Consumer Group 전체 토픽 |
| `lagThreshold` | X | 파드 1개당 허용 lag (기본값: 10) |
| `activationLagThreshold` | X | Scale from Zero를 시작할 최소 lag (기본값: 0) |
| `offsetResetPolicy` | X | `latest` / `earliest` (기본값: latest) |
| `sasl` | X | SASL 인증 방식 |
| `tls` | X | TLS 활성화 여부 (`enable` / `disable`) |

---

## 5. 상태 확인

```bash
# ScaledObject 상태 및 현재 lag 확인
kubectl describe scaledobject kafka-scaledobject -n default

# KEDA가 생성한 HPA 확인
kubectl get hpa -n default

# Consumer Group lag 직접 확인 (kafka-cli)
kafka-consumer-groups.sh \
  --bootstrap-server kafka-broker:9092 \
  --describe \
  --group my-consumer-group
```

---

## 참고

- [Kafka Scaler 공식 문서](https://keda.sh/docs/latest/scalers/apache-kafka/)
