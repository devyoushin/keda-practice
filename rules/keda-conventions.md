# KEDA 코드 표준 관행

## ScaledObject 필수 설정

```yaml
spec:
  minReplicaCount: 1          # 0으로 설정 시 cold start 주의
  maxReplicaCount: 20         # 반드시 상한 설정
  cooldownPeriod: 300         # 스케일다운 대기 시간 (초)
  pollingInterval: 30         # 메트릭 폴링 간격 (초)
  fallback:
    failureThreshold: 3       # 스케일러 오류 허용 횟수
    replicas: 3               # 오류 시 유지할 replica 수
```

## TriggerAuthentication 분리 필수

```yaml
# 시크릿 직접 참조 금지
triggers:
- type: redis
  metadata:
    address: redis:6379
  authenticationRef:
    name: redis-trigger-auth  # TriggerAuthentication 참조
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: redis-trigger-auth
spec:
  secretTargetRef:
  - parameter: password
    name: redis-secret
    key: password
```

## ScaledJob 사용 기준

- 요청당 1회 처리: ScaledJob (Job 생성)
- 지속적 처리: ScaledObject (Deployment 스케일)

## 절대 하지 말 것
- `maxReplicaCount` 없는 ScaledObject 정의
- 시크릿을 ScaledObject에 직접 하드코딩
- prod에서 `minReplicaCount: 0` (cold start 서비스 장애)
