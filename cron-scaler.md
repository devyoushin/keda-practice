# Cron Scaler

Cron scaler는 지정한 시간 범위에 맞춰 파드 수를 조절합니다.
외부 이벤트 소스 없이 시간 기반으로만 스케일링이 필요할 때 사용합니다.

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
        timezone: Asia/Seoul     # 타임존
        start: "0 9 * * 1-5"    # 평일 오전 9시 스케일 아웃
        end: "0 18 * * 1-5"     # 평일 오후 6시 스케일 인
        desiredReplicas: "5"    # 활성 시간대 파드 수
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

> 여러 trigger가 겹칠 경우 가장 높은 `desiredReplicas` 값이 적용됩니다.

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
| `*/30 * * * *` | 30분마다 |

---

## 5. 상태 확인

```bash
kubectl describe scaledobject cron-scaledobject -n default
```

```bash
kubectl get pods -n default -w
```

---

## 참고

- [Cron Scaler 공식 문서](https://keda.sh/docs/latest/scalers/cron/)
- [IANA 타임존 목록](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
