# keda-practice

EKS 환경에서 KEDA를 학습하기 위한 실습 저장소입니다.

- **환경**: EKS / KEDA 2.16.1
- **네임스페이스**: KEDA `keda`, 앱 `default`

---

## Learning Path

```
1. Installation  → install.md
2. Core Concepts → scaledobject-guide.md, scaledjob-guide.md, triggerauth-guide.md
3. Scalers
   ├── kafka-scaler.md
   ├── cron-scaler.md
   ├── redis-scaler.md
   └── prometheus-scaler.md
4. Hands-on      → hands-on.md
```

---

## Documents

### Installation
| File | Description |
|------|-------------|
| [install.md](./install.md) | KEDA Helm 설치, 설치 확인, 업그레이드/제거 |

### Core Concepts
| File | Description |
|------|-------------|
| [scaledobject-guide.md](./scaledobject-guide.md) | ScaledObject — Deployment/StatefulSet 이벤트 기반 스케일링 |
| [scaledjob-guide.md](./scaledjob-guide.md) | ScaledJob — Job 워크로드 이벤트 기반 실행 |
| [triggerauth-guide.md](./triggerauth-guide.md) | TriggerAuthentication — 외부 시스템 인증 정보 관리 |

### Scalers
| File | Description |
|------|-------------|
| [kafka-scaler.md](./kafka-scaler.md) | Kafka 토픽 consumer lag 기반 스케일링 |
| [cron-scaler.md](./cron-scaler.md) | Cron 스케줄 기반 스케일링 |
| [redis-scaler.md](./redis-scaler.md) | Redis List 길이 기반 스케일링 |
| [prometheus-scaler.md](./prometheus-scaler.md) | Prometheus 커스텀 메트릭 기반 스케일링 |

### Hands-on
| File | Description |
|------|-------------|
| [hands-on.md](./hands-on.md) | Kafka scaler 실습 — Scale to Zero 확인 |

---

## Manifest Structure

```
manifests/
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
└── prometheus/
    ├── deployment.yaml        # 대상 Deployment
    └── scaledobject.yaml      # ScaledObject — PromQL 기반 스케일링
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
