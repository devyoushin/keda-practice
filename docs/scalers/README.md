# Scaler 문서

KEDA가 외부 이벤트 소스를 읽어 HPA 메트릭으로 변환하는 scaler별 설정을 정리한 폴더입니다.

## 문서 목록

| 문서 | 용도 |
|------|------|
| [kafka-scaler.md](kafka-scaler.md) | Kafka consumer lag 기반 스케일링 |
| [cron-scaler.md](cron-scaler.md) | 시간대 기반 replica 제어와 pre-warming |
| [redis-scaler.md](redis-scaler.md) | Redis List 길이 기반 스케일링 |
| [prometheus-scaler.md](prometheus-scaler.md) | PromQL 결과 기반 스케일링 |
| [cloudwatch-scaler.md](cloudwatch-scaler.md) | AWS CloudWatch 메트릭 기반 스케일링 |

## 선택 기준

| 이벤트 소스 | 먼저 볼 문서 |
|------|------|
| Kafka topic lag | [kafka-scaler.md](kafka-scaler.md) |
| 정해진 시간대 | [cron-scaler.md](cron-scaler.md) |
| Redis queue/list | [redis-scaler.md](redis-scaler.md) |
| 애플리케이션 또는 인프라 메트릭 | [prometheus-scaler.md](prometheus-scaler.md) |
| AWS SQS, ALB, 커스텀 CloudWatch 메트릭 | [cloudwatch-scaler.md](cloudwatch-scaler.md) |

## 관련 문서

- [../concepts/scaledobject-guide.md](../concepts/scaledobject-guide.md)
- [../concepts/triggerauth-guide.md](../concepts/triggerauth-guide.md)
- [../tutorials/hands-on.md](../tutorials/hands-on.md)
