# CloudWatch Scaler

CloudWatch scaler는 AWS CloudWatch 메트릭을 기반으로 파드를 스케일링합니다.
EKS 환경에서 SQS 큐 깊이, ALB 요청 수, 커스텀 메트릭 등 AWS 인프라 메트릭을 활용해 이벤트 기반 스케일링을 구현할 때 사용합니다.

---

## 1. 동작 방식

```
AWS CloudWatch (SQS / ALB / Custom Metrics ...)
        │
        ▼
[KEDA Operator] → GetMetricData API 호출 (pollingInterval 주기)
        │
        ▼
 메트릭 값 / targetMetricValue = 목표 파드 수
        │
        ▼
Deployment 스케일 아웃
```

예시: SQS 큐 메시지 수 = 50, targetMetricValue = 10 → 목표 파드 수 = 5

---

## 2. IAM 권한 설정 (IRSA)

EKS에서는 IRSA(IAM Roles for Service Accounts)를 사용해 KEDA Operator에 CloudWatch 조회 권한을 부여합니다.

### IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics"
      ],
      "Resource": "*"
    }
  ]
}
```

### IRSA 연결

```bash
# OIDC Provider 확인
aws eks describe-cluster --name <cluster-name> --query "cluster.identity.oidc.issuer"

# IAM Role 생성 및 ServiceAccount 연결
eksctl create iamserviceaccount \
  --name keda-operator \
  --namespace keda \
  --cluster <cluster-name> \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/KEDACloudWatchPolicy \
  --approve \
  --override-existing-serviceaccounts
```

### IRSA 적용 확인

```bash
kubectl get serviceaccount keda-operator -n keda -o yaml | grep eks.amazonaws.com
# eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<role-name> 이 있어야 함
```

---

## 3. TriggerAuthentication 설정

IRSA 방식은 Secret 없이 Pod Identity만으로 인증합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: cloudwatch-trigger-auth
  namespace: default
spec:
  podIdentity:
    provider: aws-eks    # IRSA 사용 선언
```

> IRSA 외에도 AWS 자격증명을 Secret으로 직접 주입하는 방식도 지원하지만, EKS 환경에서는 IRSA를 권장합니다.

---

## 4. 사용 예시

### 4-1. SQS 큐 깊이 기반 스케일링

가장 일반적인 패턴으로, SQS 큐에 쌓인 메시지 수에 따라 컨슈머 파드를 스케일링합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: sqs-consumer-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: sqs-consumer
  minReplicaCount: 0          # 큐가 비었을 때 Scale to Zero
  maxReplicaCount: 20
  pollingInterval: 30
  cooldownPeriod: 60
  triggers:
    - type: aws-cloudwatch
      metadata:
        namespace: AWS/SQS
        metricName: ApproximateNumberOfMessagesVisible
        dimensionName: QueueName
        dimensionValue: my-task-queue
        targetMetricValue: "10"        # 파드 1개당 처리할 메시지 수
        minMetricValue: "0"
        metricStat: Maximum
        metricStatPeriod: "60"         # 60초 기준 집계
        metricCollectionTime: "120"    # 최근 120초 데이터 수집
        region: ap-northeast-2
      authenticationRef:
        name: cloudwatch-trigger-auth
```

### 4-2. ALB 요청 수 기반 스케일링

ALB Target Group의 요청 수를 기반으로 API 서버를 스케일링합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: api-server-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: api-server
  minReplicaCount: 2
  maxReplicaCount: 50
  pollingInterval: 30
  cooldownPeriod: 300
  triggers:
    - type: aws-cloudwatch
      metadata:
        namespace: AWS/ApplicationELB
        metricName: RequestCountPerTarget
        dimensionName: TargetGroup
        dimensionValue: targetgroup/my-api-tg/abc123def456
        targetMetricValue: "100"       # 파드 1개당 처리할 RPS
        minMetricValue: "0"
        metricStat: Sum
        metricStatPeriod: "60"
        metricCollectionTime: "120"
        region: ap-northeast-2
      authenticationRef:
        name: cloudwatch-trigger-auth
```

### 4-3. 커스텀 메트릭 기반 스케일링

애플리케이션이 CloudWatch에 직접 발행하는 커스텀 메트릭을 활용합니다.

```yaml
triggers:
  - type: aws-cloudwatch
    metadata:
      namespace: MyApp/Metrics          # 커스텀 네임스페이스
      metricName: PendingJobCount
      dimensionName: Service            # 여러 차원은 쉼표로 구분
      dimensionValue: order-processor
      targetMetricValue: "5"
      minMetricValue: "0"
      metricStat: Average
      metricStatPeriod: "60"
      metricCollectionTime: "120"
      region: ap-northeast-2
    authenticationRef:
      name: cloudwatch-trigger-auth
```

### 4-4. CloudWatch Metric Math 표현식 활용

여러 메트릭을 조합하거나 계산이 필요한 경우 `expression`을 사용합니다.

```yaml
triggers:
  - type: aws-cloudwatch
    metadata:
      # expression 사용 시 namespace/metricName/dimensionName 대신 지정
      expression: >-
        SELECT AVG(ApproximateNumberOfMessagesVisible)
        FROM SCHEMA("AWS/SQS", QueueName)
        WHERE QueueName = 'my-queue'
      targetMetricValue: "10"
      minMetricValue: "0"
      metricCollectionTime: "120"
      region: ap-northeast-2
    authenticationRef:
      name: cloudwatch-trigger-auth
```

---

## 5. 주요 파라미터

| 파라미터 | 필수 | 기본값 | 설명 |
|----------|------|--------|------|
| `namespace` | O* | - | CloudWatch 메트릭 네임스페이스 (예: `AWS/SQS`) |
| `metricName` | O* | - | 메트릭 이름 (예: `ApproximateNumberOfMessagesVisible`) |
| `dimensionName` | O* | - | 차원 이름 (복수 시 쉼표 구분) |
| `dimensionValue` | O* | - | 차원 값 (복수 시 쉼표 구분) |
| `expression` | O* | - | Metric Math 표현식 (`namespace` 대신 사용) |
| `targetMetricValue` | O | - | 파드 1개당 허용 메트릭 값 |
| `minMetricValue` | O | - | 스케일링 활성화 최소 메트릭 값 (보통 `"0"`) |
| `metricStat` | X | `Average` | 집계 방식 (`Average` / `Sum` / `Maximum` / `Minimum`) |
| `metricStatPeriod` | X | `300` | 집계 기간 (초, CloudWatch 최소 60초) |
| `metricCollectionTime` | X | `300` | 수집할 과거 데이터 범위 (초) |
| `metricEndTimeOffset` | X | `0` | 데이터 수집 종료 시각 오프셋 (초) |
| `region` | O | - | AWS 리전 (예: `ap-northeast-2`) |

> `*` `namespace`/`metricName`/`dimensionName`/`dimensionValue` 또는 `expression` 중 하나를 선택해야 합니다.

---

## 6. Cron + CloudWatch 조합

업무 시간에는 CloudWatch 이벤트 기반, 비업무 시간에는 Cron으로 최소 파드를 보장하는 패턴입니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: hybrid-scaledobject
  namespace: default
spec:
  scaleTargetRef:
    name: sqs-consumer
  minReplicaCount: 0
  maxReplicaCount: 30
  pollingInterval: 30
  triggers:
    # CloudWatch: SQS 큐 기반 이벤트 스케일링
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
    # Cron: 업무 시간 최소 파드 보장 (둘 중 높은 값 적용)
    - type: cron
      metadata:
        timezone: Asia/Seoul
        start: "0 9 * * 1-5"
        end: "0 18 * * 1-5"
        desiredReplicas: "3"
```

---

## 7. 상태 확인

```bash
# ScaledObject 상태 및 현재 메트릭 값 확인
kubectl describe scaledobject sqs-consumer-scaledobject -n default

# KEDA operator 로그에서 CloudWatch 쿼리 결과 확인
kubectl logs -n keda -l app=keda-operator --tail=100 | grep -i cloudwatch

# HPA 현재 메트릭 확인
kubectl get hpa -n default
kubectl describe hpa keda-hpa-sqs-consumer -n default
```

---

## 8. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `ScaledObject READY=False` | IRSA 권한 부족 또는 미적용 | `kubectl get sa keda-operator -n keda -o yaml`로 role-arn 확인 |
| 메트릭 값이 항상 0 | 잘못된 namespace/metricName/dimensionValue | CloudWatch 콘솔에서 실제 메트릭 경로 확인 |
| 스케일링이 느리게 반응 | `metricStatPeriod` 또는 `metricCollectionTime`이 너무 큼 | 각각 `60`, `120`으로 줄여서 테스트 |
| `AccessDenied` 오류 | IAM Policy 누락 | `cloudwatch:GetMetricData` 권한 확인 |
| 파드가 0으로 떨어지지 않음 | `minMetricValue` 미설정 | `minMetricValue: "0"` 명시 |
| KEDA 재시작 후 메트릭 조회 실패 | IRSA Token 재마운트 필요 | KEDA operator Pod 재시작 (`kubectl rollout restart`) |

---

## 참고

- [AWS CloudWatch Scaler 공식 문서](https://keda.sh/docs/latest/scalers/aws-cloudwatch/)
- [IRSA 설정 가이드 (AWS 공식)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [CloudWatch 메트릭 네임스페이스 목록](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)
