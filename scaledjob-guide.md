# ScaledJob

ScaledJob은 이벤트 하나당 Kubernetes Job을 하나씩 생성하는 방식으로 동작합니다.
Deployment처럼 파드를 유지하는 것이 아니라, 이벤트가 발생할 때마다 새 Job을 띄우고 완료되면 종료합니다.
메시지 큐의 각 메시지를 독립적으로 처리해야 할 때 적합합니다.

---

## 1. ScaledObject vs ScaledJob

| 항목 | ScaledObject | ScaledJob |
|------|-------------|-----------|
| 대상 | Deployment, StatefulSet | Kubernetes Job |
| 동작 방식 | 파드 수를 조절 (HPA) | 이벤트당 Job 생성 |
| 적합한 워크로드 | 상시 실행 서버, 스트림 처리 | 배치 처리, 메시지 단위 처리 |
| Scale to Zero | 지원 | 항상 Zero (이벤트 없으면 Job 없음) |

---

## 2. 기본 구조

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: my-scaledjob
  namespace: default
spec:
  jobTargetRef:
    parallelism: 1               # Job 내 병렬 파드 수
    completions: 1
    template:
      spec:
        restartPolicy: Never
        containers:
          - name: worker
            image: my-worker:latest
            env:
              - name: QUEUE_URL
                value: "https://sqs.ap-northeast-2.amazonaws.com/..."
  pollingInterval: 30            # 이벤트 소스 폴링 주기 (초)
  maxReplicaCount: 10            # 동시에 실행할 최대 Job 수
  triggers:
    - type: aws-sqs-queue
      metadata:
        queueURL: https://sqs.ap-northeast-2.amazonaws.com/123456789/my-queue
        queueLength: "1"         # 메시지 1개당 Job 1개 생성
        awsRegion: ap-northeast-2
```

---

## 3. 주요 필드

| 필드 | 기본값 | 설명 |
|------|--------|------|
| `maxReplicaCount` | 100 | 동시에 실행 가능한 최대 Job 수 |
| `pollingInterval` | 30 | 이벤트 소스 폴링 주기 (초) |
| `successfulJobsHistoryLimit` | 100 | 완료된 Job 보관 수 |
| `failedJobsHistoryLimit` | 100 | 실패한 Job 보관 수 |

---

## 4. Job 완료 전략 (scalingStrategy)

```yaml
spec:
  scalingStrategy:
    strategy: "default"          # default / custom / accurate
```

| 전략 | 설명 |
|------|------|
| `default` | 큐 길이 / queueLength 값을 기준으로 Job 수 결정 |
| `custom` | `customScalingQueueLengthDeduction`, `customScalingRunningJobPercentage` 로 세밀하게 조정 |
| `accurate` | 실행 중인 Job이 처리하는 메시지 수를 차감하여 정확하게 계산 |

---

## 5. 상태 확인

```bash
# ScaledJob 조회
kubectl get scaledjob -n default

# 생성된 Job 목록 확인
kubectl get jobs -n default

# Job 상세 조회
kubectl describe job <job-name> -n default
```

---

## 참고

- [ScaledJob 공식 문서](https://keda.sh/docs/latest/concepts/scaling-jobs/)
