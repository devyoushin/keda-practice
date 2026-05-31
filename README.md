# keda-practice

EKS 환경에서 KEDA를 학습하기 위한 실습 저장소입니다.

- **환경**: EKS / KEDA 2.16.1
- **네임스페이스**: KEDA `keda`, 앱 `default`

---

## 어디서 시작할까

- 문서 지도: `docs/README.md`
- 첫 문서: `docs/install.md`
- 운영 보조 자료: `ops/README.md`
- AI 작업 지침: `CLAUDE.md`

## 구조

| 경로 | 내용 |
|------|------|
| `docs/` | 설치, ScaledObject, ScaledJob, TriggerAuthentication, scaler 문서 |
| `ops/` | scaler별 Deployment, ScaledObject, TriggerAuthentication YAML |
| `CLAUDE.md` | 이 레포에서 Claude가 참고할 작업 지침 |

---

## Learning Path

```
1. Installation  → docs/install.md
2. Core Concepts → docs/scaledobject-guide.md, docs/scaledjob-guide.md, docs/triggerauth-guide.md
3. Scalers
   ├── docs/kafka-scaler.md
   ├── docs/cron-scaler.md
   ├── docs/redis-scaler.md
   ├── docs/prometheus-scaler.md
   └── docs/cloudwatch-scaler.md
4. Hands-on      → docs/hands-on.md
```

---

## Documents

### Installation
| File | Description |
|------|-------------|
| [docs/install.md](./docs/install.md) | KEDA Helm 설치, 설치 확인, 업그레이드/제거 |

### Core Concepts
| File | Description |
|------|-------------|
| [docs/scaledobject-guide.md](./docs/scaledobject-guide.md) | ScaledObject — Deployment/StatefulSet 이벤트 기반 스케일링 |
| [docs/scaledjob-guide.md](./docs/scaledjob-guide.md) | ScaledJob — Job 워크로드 이벤트 기반 실행 |
| [docs/triggerauth-guide.md](./docs/triggerauth-guide.md) | TriggerAuthentication — 외부 시스템 인증 정보 관리 |

### Scalers
| File | Description |
|------|-------------|
| [docs/kafka-scaler.md](./docs/kafka-scaler.md) | Kafka 토픽 consumer lag 기반 스케일링 |
| [docs/cron-scaler.md](./docs/cron-scaler.md) | Cron 스케줄 기반 스케일링 |
| [docs/redis-scaler.md](./docs/redis-scaler.md) | Redis List 길이 기반 스케일링 |
| [docs/prometheus-scaler.md](./docs/prometheus-scaler.md) | Prometheus 커스텀 메트릭 기반 스케일링 |
| [docs/cloudwatch-scaler.md](./docs/cloudwatch-scaler.md) | AWS CloudWatch 메트릭 기반 스케일링 (EKS IRSA) |

### Hands-on
| File | Description |
|------|-------------|
| [docs/hands-on.md](./docs/hands-on.md) | Kafka scaler 실습 — Scale to Zero 확인 |

---

## 상세 구조

```
docs/
├── install.md
├── scaledobject-guide.md
├── scaledjob-guide.md
├── triggerauth-guide.md
├── kafka-scaler.md
├── cron-scaler.md
├── redis-scaler.md
├── prometheus-scaler.md
├── cloudwatch-scaler.md
└── hands-on.md

ops/manifests/
├── kafka/
│   ├── deployment.yaml        # Consumer Deployment (replicas: 0)
│   ├── scaledobject.yaml      # ScaledObject — lag 기반 스케일링
│   ├── trigger-auth.yaml      # TriggerAuthentication — SASL 인증
│   └── secret.yaml            # Kafka 인증 정보
├── cron/
│   ├── deployment.yaml        # 대상 Deployment
│   └── scaledobject.yaml      # ScaledObject — 시간대별 다중 cron trigger
├── redis/
│   ├── deployment.yaml        # Worker Deployment (replicas: 0)
│   ├── scaledobject.yaml      # ScaledObject — List 길이 기반 스케일링
│   ├── trigger-auth.yaml      # TriggerAuthentication — 비밀번호 인증
│   └── secret.yaml            # Redis 인증 정보
├── prometheus/
│   ├── deployment.yaml        # 대상 Deployment
│   └── scaledobject.yaml      # ScaledObject — PromQL 기반 스케일링
└── cloudwatch/
    ├── deployment.yaml        # SQS Consumer Deployment (replicas: 0)
    ├── trigger-auth.yaml      # TriggerAuthentication — IRSA (aws-eks provider)
    └── scaledobject.yaml      # ScaledObject — SQS 큐 깊이 / Cron+CloudWatch 조합
```

---

## Key Concept Summary

**ScaledObject + Scaler** 가 KEDA의 핵심입니다.

```
External Event Source (Kafka, Redis, SQS ...)
 │
 ▼
[KEDA Operator] → 이벤트 메트릭 수집
 │
 ▼
[HPA] → 자동 생성 및 관리
 │
 ▼
Deployment (minReplicas: 0 ↔ maxReplicas: N)
```

> Scale to Zero: 이벤트가 없으면 파드를 0으로 줄이고, 이벤트 발생 시 다시 기동합니다.
