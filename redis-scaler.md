# Redis Scaler

Redis scaler는 Redis List의 길이를 기반으로 파드를 스케일링합니다.
List에 쌓인 항목 수가 `listLength`를 초과하면 파드를 추가하고, List가 비면 Scale to Zero합니다.

---

## 1. 동작 방식

```
Redis List에 항목 추가 (LPUSH / RPUSH)
 │
 ▼
[KEDA Operator] → LLEN 명령으로 List 길이 수집
 │
 ▼
 List 길이 / listLength = 목표 파드 수
 │
 ▼
Deployment 스케일 아웃
```

예시: List 길이 = 30, listLength = 10 → 목표 파드 수 = 3

---

## 2. 인증 없는 기본 설정

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: redis-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: redis-worker
  minReplicaCount: 0
  maxReplicaCount: 10
  triggers:
    - type: redis
      metadata:
        address: redis-service:6379    # Redis 주소
        listName: my-task-queue        # 감시할 List 키 이름
        listLength: "10"               # 파드 1개당 처리할 항목 수
        databaseIndex: "0"             # Redis DB 인덱스 (기본값: 0)
```

---

## 3. 비밀번호 인증 설정

Secret 생성:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
  namespace: default
type: Opaque
stringData:
  password: my-redis-password
```

TriggerAuthentication:

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: redis-trigger-auth
  namespace: default
spec:
  secretTargetRef:
    - parameter: password
      name: redis-secret
      key: password
```

ScaledObject에 인증 추가:

```yaml
triggers:
  - type: redis
    metadata:
      address: redis-service:6379
      listName: my-task-queue
      listLength: "10"
    authenticationRef:
      name: redis-trigger-auth
```

---

## 4. Redis Sentinel / Cluster 설정

Redis Sentinel 사용 시:

```yaml
triggers:
  - type: redis-sentinel
    metadata:
      addresses: redis-sentinel-0:26379,redis-sentinel-1:26379
      sentinelMaster: mymaster
      listName: my-task-queue
      listLength: "10"
```

Redis Cluster 사용 시:

```yaml
triggers:
  - type: redis-cluster
    metadata:
      addresses: redis-node-0:6379,redis-node-1:6379,redis-node-2:6379
      listName: my-task-queue
      listLength: "10"
```

---

## 5. 주요 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `address` | O | Redis 주소 (`host:port`) |
| `listName` | O | 감시할 List 키 이름 |
| `listLength` | X | 파드 1개당 허용 항목 수 (기본값: 5) |
| `activationListLength` | X | Scale from Zero를 시작할 최소 항목 수 (기본값: 0) |
| `databaseIndex` | X | Redis DB 인덱스 (기본값: 0) |
| `enableTLS` | X | TLS 사용 여부 (`true` / `false`) |

---

## 6. 상태 확인

```bash
# ScaledObject 상태 확인
kubectl describe scaledobject redis-scaledobject -n default

# Redis List 길이 직접 확인
redis-cli -h redis-service LLEN my-task-queue
```

---

## 참고

- [Redis Scaler 공식 문서](https://keda.sh/docs/latest/scalers/redis-lists/)
