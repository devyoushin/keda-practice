# KEDA Docs

KEDA를 처음 보는 사람이 설치, 핵심 리소스, scaler별 설정, hands-on 실습, 운영 보조 자료까지 순서대로 따라갈 수 있도록 정리한 문서 디렉터리입니다.

## 빠른 길잡이

| 지금 하고 싶은 일 | 열 문서 |
|------|------|
| KEDA를 설치하기 | [install.md](install.md) |
| ScaledObject 구조 이해하기 | [scaledobject-guide.md](scaledobject-guide.md) |
| Job 기반 스케일링 이해하기 | [scaledjob-guide.md](scaledjob-guide.md) |
| 인증 정보를 안전하게 분리하기 | [triggerauth-guide.md](triggerauth-guide.md) |
| Kafka consumer lag로 스케일링하기 | [kafka-scaler.md](kafka-scaler.md) |
| 시간대별로 스케일링하기 | [cron-scaler.md](cron-scaler.md) |
| Redis queue 길이로 스케일링하기 | [redis-scaler.md](redis-scaler.md) |
| PromQL 결과로 스케일링하기 | [prometheus-scaler.md](prometheus-scaler.md) |
| AWS CloudWatch 메트릭으로 스케일링하기 | [cloudwatch-scaler.md](cloudwatch-scaler.md) |
| Kafka scaler를 끝까지 실습하기 | [hands-on.md](hands-on.md) |
| 업그레이드 또는 롤백하기 | [install/upgrade/README.md](install/upgrade/README.md) |

## 추천 읽기 순서

| 순서 | 문서 | 핵심 내용 |
|------|------|------|
| 1 | [install.md](install.md) | KEDA Helm 설치, 확인, 제거 |
| 2 | [scaledobject-guide.md](scaledobject-guide.md) | Deployment/StatefulSet 이벤트 기반 스케일링 |
| 3 | [triggerauth-guide.md](triggerauth-guide.md) | Secret, TriggerAuthentication, ClusterTriggerAuthentication |
| 4 | [kafka-scaler.md](kafka-scaler.md) | Kafka consumer lag 기반 스케일링 |
| 5 | [hands-on.md](hands-on.md) | Kafka scaler로 Scale to Zero 확인 |
| 6 | [redis-scaler.md](redis-scaler.md) | Redis List 길이 기반 스케일링 |
| 7 | [prometheus-scaler.md](prometheus-scaler.md) | Prometheus 커스텀 메트릭 기반 스케일링 |
| 8 | [cloudwatch-scaler.md](cloudwatch-scaler.md) | CloudWatch 메트릭과 EKS IRSA |
| 9 | [cron-scaler.md](cron-scaler.md) | 스케줄 기반 스케일링과 pre-warming |
| 10 | [scaledjob-guide.md](scaledjob-guide.md) | 이벤트 기반 Job 실행 |
| 11 | [install/upgrade/README.md](install/upgrade/README.md) | KEDA 업그레이드와 롤백 |

## 전체 문서 목록

| 구분 | 문서 |
|------|------|
| 설치 | [install.md](install.md), [install/upgrade/README.md](install/upgrade/README.md) |
| 핵심 리소스 | [scaledobject-guide.md](scaledobject-guide.md), [scaledjob-guide.md](scaledjob-guide.md), [triggerauth-guide.md](triggerauth-guide.md) |
| Scaler | [kafka-scaler.md](kafka-scaler.md), [cron-scaler.md](cron-scaler.md), [redis-scaler.md](redis-scaler.md), [prometheus-scaler.md](prometheus-scaler.md), [cloudwatch-scaler.md](cloudwatch-scaler.md) |
| 실습/운영 | [hands-on.md](hands-on.md), [../ops/README.md](../ops/README.md) |
| 문서 운영 | [rules/README.md](rules/README.md), [templates/README.md](templates/README.md), [agents/README.md](agents/README.md) |

## Scaler 선택 기준

| 이벤트 소스 | 추천 문서 | 대표 사용 사례 |
|------|------|------|
| Kafka | [kafka-scaler.md](kafka-scaler.md) | Consumer lag 기반 worker scale out |
| Cron | [cron-scaler.md](cron-scaler.md) | 특정 시간대 pre-warming, 업무 시간 replica 유지 |
| Redis | [redis-scaler.md](redis-scaler.md) | Redis List queue 길이 기반 worker scale out |
| Prometheus | [prometheus-scaler.md](prometheus-scaler.md) | 앱/인프라 커스텀 메트릭 기반 스케일링 |
| CloudWatch | [cloudwatch-scaler.md](cloudwatch-scaler.md) | SQS queue depth, ALB request count, AWS 메트릭 기반 스케일링 |

## 폴더 역할

| 폴더 | 역할 |
|------|------|
| [install/](install.md) | KEDA 설치와 업그레이드 |
| [rules/](rules/README.md) | 문서 작성, KEDA 컨벤션, 보안, 모니터링 규칙 |
| [templates/](templates/README.md) | 서비스 문서, 런북, 장애 보고서 템플릿 |
| [agents/](agents/README.md) | AI가 문서를 작성하거나 진단할 때 참고할 역할별 지침 |
| [../ops/](../ops/README.md) | 실제 적용 가능한 설치 스크립트와 Kubernetes 매니페스트 |

## 관리 원칙

- 개념 설명과 절차 문서는 `docs/`에 둡니다.
- 실제 적용 가능한 YAML과 스크립트는 `ops/`에 둡니다.
- 인증 정보는 예시에서도 Secret 또는 TriggerAuthentication으로 분리합니다.
- 새 문서를 추가할 때는 이 README의 전체 문서 목록과 추천 읽기 순서를 함께 갱신합니다.
