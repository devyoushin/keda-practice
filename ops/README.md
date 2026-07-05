# KEDA Ops

KEDA를 실제로 설치하거나 실습할 때 사용하는 스크립트와 Kubernetes 매니페스트를 두는 공간입니다. 개념 설명은 `docs/`에, 적용 가능한 실행 자산은 `ops/`에 둡니다.

## 폴더 구조

| 폴더 | 내용 |
|------|------|
| `01-installation/` | Helm 기반 KEDA 설치 스크립트와 values |
| `upgrade/` | KEDA Helm 업그레이드 스크립트 |
| `manifests/kafka/` | Kafka consumer Deployment, ScaledObject, TriggerAuthentication, Secret |
| `manifests/cron/` | Cron scaler 대상 Deployment와 ScaledObject |
| `manifests/redis/` | Redis worker Deployment, ScaledObject, TriggerAuthentication, Secret |
| `manifests/prometheus/` | Prometheus scaler 대상 Deployment와 ScaledObject |
| `manifests/cloudwatch/` | CloudWatch scaler 대상 Deployment, TriggerAuthentication, ScaledObject |

## 관련 문서

| 작업 | 문서 |
|------|------|
| KEDA 설치 | [../docs/01-installation/install.md](../docs/01-installation/install.md) |
| KEDA 업그레이드 | [../docs/01-installation/upgrade/README.md](../docs/01-installation/upgrade/README.md) |
| ScaledObject 이해 | [../docs/02-concepts/scaledobject-guide.md](../docs/02-concepts/scaledobject-guide.md) |
| TriggerAuthentication 이해 | [../docs/02-concepts/triggerauth-guide.md](../docs/02-concepts/triggerauth-guide.md) |
| Kafka scaler 실습 | [../docs/04-tutorials/hands-on.md](../docs/04-tutorials/hands-on.md) |
| scaler별 설정 | [../docs/03-scalers/kafka-scaler.md](../docs/03-scalers/kafka-scaler.md), [../docs/03-scalers/cron-scaler.md](../docs/03-scalers/cron-scaler.md), [../docs/03-scalers/redis-scaler.md](../docs/03-scalers/redis-scaler.md), [../docs/03-scalers/prometheus-scaler.md](../docs/03-scalers/prometheus-scaler.md), [../docs/03-scalers/cloudwatch-scaler.md](../docs/03-scalers/cloudwatch-scaler.md) |

## 적용 순서

1. `01-installation/install-keda-helm.sh`와 `01-installation/keda-values.yaml`로 KEDA를 설치합니다.
2. 필요한 이벤트 소스에 맞는 `manifests/<scaler>/` 예제를 확인합니다.
3. Secret과 TriggerAuthentication 값을 환경에 맞게 바꿉니다.
4. Deployment, TriggerAuthentication, ScaledObject 순서로 적용합니다.
5. `kubectl get scaledobject`, `kubectl get hpa`, KEDA operator 로그로 동작을 확인합니다.

## 관리 원칙

- 재사용 가능한 YAML과 스크립트는 이 디렉터리에 둡니다.
- 문서 본문에는 핵심 스니펫만 넣고, 전체 적용 파일은 `ops/`를 기준으로 관리합니다.
- 인증 정보는 실제 값으로 커밋하지 않습니다.
- 설정을 바꾸면 관련 문서의 명령어와 파일 경로도 함께 확인합니다.
