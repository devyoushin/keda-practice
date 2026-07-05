# AI 작업 지침

KEDA 문서를 AI와 함께 작성하거나 점검할 때 쓰는 역할별 지침입니다. 일반 학습 문서가 아니라, 문서 작성/스케일러 설계/진단/성능 튜닝 작업의 기준으로 사용합니다.

## 문서 목록

| 문서 | 용도 |
|------|------|
| [doc-writer.md](doc-writer.md) | 새 가이드, README, 운영 문서를 작성할 때의 기준 |
| [scaler-designer.md](scaler-designer.md) | 이벤트 소스에 맞는 scaler와 fallback 설정을 설계하는 기준 |
| [troubleshooter.md](troubleshooter.md) | ScaledObject, HPA, TriggerAuthentication 문제를 진단하는 기준 |
| [performance-advisor.md](performance-advisor.md) | pollingInterval, cooldownPeriod, HPA 설정을 튜닝하는 기준 |

## 사용 기준

| 작업 | 먼저 볼 문서 |
|------|------|
| 새 문서 작성 | [doc-writer.md](doc-writer.md) |
| scaler 선택 또는 YAML 설계 | [scaler-designer.md](scaler-designer.md) |
| 스케일링 미동작 진단 | [troubleshooter.md](troubleshooter.md) |
| 과도한 scale out/in 또는 지연 개선 | [performance-advisor.md](performance-advisor.md) |

## 관련 문서

- [../README.md](../README.md)
- [../90-standards/README.md](../90-standards/README.md)
- [../91-templates/README.md](../91-templates/README.md)
- [../../CLAUDE.md](../../CLAUDE.md)
