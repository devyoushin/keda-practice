# Hands-on: Kafka Scaler로 Scale to Zero 체험

Kafka Consumer Group의 lag을 발생시켜 파드가 자동으로 스케일 아웃/인 되는 것을 직접 확인합니다.

- **전제 조건**: KEDA 설치 완료 ([install.md](../install/install.md) 참고)
- **네임스페이스**: default

---

## Step 1: Kafka 배포

테스트용 Kafka를 클러스터 내에 배포합니다.

```bash
kubectl apply -f ops/manifests/kafka/kafka.yaml
kubectl rollout status deployment/kafka -n default
```

Kafka 파드 진입 후 토픽 생성:

```bash
kubectl exec -it deploy/kafka -- kafka-topics.sh \
  --create \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --partitions 10 \
  --replication-factor 1
```

---

## Step 2: Consumer Deployment 배포

lag을 소비할 consumer 애플리케이션을 배포합니다.

```bash
kubectl apply -f ops/manifests/kafka/deployment.yaml
```

```yaml
# ops/manifests/kafka/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka-consumer
  namespace: default
spec:
  replicas: 0                    # 초기 0개 — Scale to Zero 상태로 시작
  selector:
    matchLabels:
      app: kafka-consumer
  template:
    metadata:
      labels:
        app: kafka-consumer
    spec:
      containers:
        - name: consumer
          image: confluentinc/cp-kafka:7.5.0
          command:
            - kafka-console-consumer.sh
            - --bootstrap-server
            - kafka:9092
            - --topic
            - my-topic
            - --group
            - my-consumer-group
```

---

## Step 3: ScaledObject 배포

```bash
kubectl apply -f ops/manifests/kafka/scaledobject.yaml
```

```yaml
# ops/manifests/kafka/scaledobject.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: kafka-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: kafka-consumer
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
    - type: kafka
      metadata:
        bootstrapServers: kafka:9092
        consumerGroup: my-consumer-group
        topic: my-topic
        lagThreshold: "5"          # 파드 1개당 5개의 lag 처리
        offsetResetPolicy: latest
```

ScaledObject 상태 확인:

```bash
kubectl get scaledobject -n default
```

```
NAME                  SCALETARGETKIND      SCALETARGETNAME   MIN   MAX   TRIGGERS   READY   ACTIVE   FALLBACK   AGE
kafka-scaledobject    apps/v1.Deployment   kafka-consumer    0     10    kafka      True    False    False      30s
```

---

## Step 4: 메시지 발행 — 스케일 아웃 확인

Producer로 메시지를 대량 발행합니다.

```bash
kubectl exec -it deploy/kafka -- bash -c \
  "seq 100 | kafka-console-producer.sh \
    --broker-list localhost:9092 \
    --topic my-topic"
```

파드 수 변화 관찰:

```bash
kubectl get pods -n default -w
```

```
kafka-consumer-xxxxxxxxx-xxxxx   0/1   ContainerCreating   0   2s
kafka-consumer-xxxxxxxxx-yyyyy   0/1   ContainerCreating   0   2s
kafka-consumer-xxxxxxxxx-zzzzz   0/1   ContainerCreating   0   3s
kafka-consumer-xxxxxxxxx-xxxxx   1/1   Running             0   5s
...
```

lag 확인:

```bash
kubectl exec -it deploy/kafka -- kafka-consumer-groups.sh \
  --bootstrap-server localhost:9092 \
  --describe \
  --group my-consumer-group
```

---

## Step 5: 메시지 소비 완료 — Scale to Zero 확인

lag이 0이 되면 `cooldownPeriod`(기본 300초) 이후 파드가 0개로 줄어듭니다.

```bash
kubectl get pods -n default -w
```

```
kafka-consumer-xxxxxxxxx-xxxxx   1/1   Terminating   0   6m
kafka-consumer-xxxxxxxxx-yyyyy   1/1   Terminating   0   6m
# 모든 파드 종료 후 Running 파드 없음
```

HPA 확인:

```bash
kubectl get hpa -n default
```

```
NAME                       REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS
keda-hpa-kafka-consumer   Deployment/kafka-consumer     0/5       1         10        0
```

---

## 트러블슈팅

| 증상 | 원인 | 해결 방법 |
|------|------|-----------|
| ScaledObject READY가 False | Kafka 브로커 접근 불가 | `bootstrapServers` 주소 및 포트 확인 |
| 파드가 스케일 아웃되지 않음 | Consumer Group이 토픽을 한 번도 구독하지 않음 | consumer를 한 번 실행하여 Group 등록 후 재시도 |
| Scale to Zero가 되지 않음 | `cooldownPeriod` 대기 중 | 기본 300초 대기. `cooldownPeriod` 값 확인 |
| lag이 있는데 파드가 늘지 않음 | `activationLagThreshold` 미충족 | 설정값과 실제 lag 비교 |

---

## 정리

```bash
kubectl delete -f ops/manifests/kafka/scaledobject.yaml
kubectl delete -f ops/manifests/kafka/deployment.yaml
kubectl delete -f ops/manifests/kafka/kafka.yaml
```
