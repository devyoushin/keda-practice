# keda-practice

EKS 환경에서 KEDA를 사용해 이벤트 기반 오토스케일링을 학습하는 실습 저장소입니다. KEDA 설치, ScaledObject/ScaledJob, TriggerAuthentication, scaler별 예제, 운영 진단 문서를 함께 관리합니다.

## 먼저 볼 문서

| 목적 | 문서 |
|------|------|
| 전체 문서 목차 보기 | [docs/README.md](docs/README.md) |
| KEDA 설치하기 | [docs/01-installation/install.md](docs/01-installation/install.md) |
| 핵심 리소스 이해하기 | [docs/02-concepts/scaledobject-guide.md](docs/02-concepts/scaledobject-guide.md), [docs/02-concepts/scaledjob-guide.md](docs/02-concepts/scaledjob-guide.md), [docs/02-concepts/triggerauth-guide.md](docs/02-concepts/triggerauth-guide.md) |
| Kafka scaler 실습하기 | [docs/04-tutorials/hands-on.md](docs/04-tutorials/hands-on.md) |
| 운영 YAML 확인하기 | [ops/README.md](ops/README.md) |
| AI 작업 지침 보기 | [CLAUDE.md](CLAUDE.md) |

## 추천 학습 순서

1. [KEDA 설치](docs/01-installation/install.md)
2. [ScaledObject](docs/02-concepts/scaledobject-guide.md)
3. [TriggerAuthentication](docs/02-concepts/triggerauth-guide.md)
4. [Kafka scaler](docs/03-scalers/kafka-scaler.md)
5. [Hands-on 실습](docs/04-tutorials/hands-on.md)
6. [Redis](docs/03-scalers/redis-scaler.md), [Prometheus](docs/03-scalers/prometheus-scaler.md), [CloudWatch](docs/03-scalers/cloudwatch-scaler.md), [Cron](docs/03-scalers/cron-scaler.md) scaler
7. [ScaledJob](docs/02-concepts/scaledjob-guide.md)
8. [업그레이드](docs/01-installation/upgrade/README.md)

## 디렉터리 구조

```text
keda-practice/
├── README.md
├── CLAUDE.md          # AI 작업 지침
├── docs/
│   ├── README.md     # 문서 전체 목차
│   ├── install/      # 설치와 업그레이드
│   ├── concepts/     # ScaledObject, ScaledJob, TriggerAuthentication
│   ├── scalers/      # Kafka, Cron, Redis, Prometheus, CloudWatch scaler
│   ├── tutorials/    # hands-on 실습
│   ├── agents/       # AI 역할별 작업 지침
│   ├── rules/        # 문서/운영 규칙
│   └── templates/    # 서비스 문서, 런북, 장애 보고서 템플릿
└── ops/
    ├── README.md     # 운영 자산 설명
    ├── install/      # Helm 설치 스크립트와 values
    ├── upgrade/      # 업그레이드 스크립트
    └── manifests/    # scaler별 Kubernetes 매니페스트
```

## 문서 분류

| 분류 | 내용 |
|------|------|
| 설치 | KEDA Helm 설치, 업그레이드, 제거 |
| 핵심 개념 | ScaledObject, ScaledJob, TriggerAuthentication |
| Scaler | Kafka, Cron, Redis, Prometheus, CloudWatch |
| 실습/운영 | Hands-on, 운영 매니페스트, 확인 명령어 |
| 문서 운영 | 작성 규칙, 템플릿, AI 작업 지침 |

## 환경

| 항목 | 값 |
|------|-----|
| Platform | EKS |
| KEDA | 2.16.1 |
| Kubernetes | v1.27 이상 |
| KEDA Namespace | `keda` |
| App Namespace | `default` |

## 핵심 개념

KEDA는 외부 이벤트 소스의 메트릭을 읽고 Kubernetes HPA를 관리해 워크로드를 자동으로 조정합니다.

```text
External Event Source
  -> KEDA Operator
  -> External Metrics API / HPA
  -> Deployment, StatefulSet, Job
```

Scale to Zero를 사용하면 이벤트가 없을 때 파드를 `0`개까지 줄이고, 이벤트가 다시 생기면 워크로드를 기동할 수 있습니다.
