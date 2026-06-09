# 문서 템플릿

KEDA 운영 문서를 빠르게 만들기 위한 템플릿입니다. 실제 서비스 문서, 런북, 장애 보고서를 작성할 때 복사해서 사용합니다.

## 문서 목록

| 문서 | 용도 |
|------|------|
| [service-doc.md](service-doc.md) | 서비스별 KEDA 스케일링 설계와 YAML 정리 |
| [runbook.md](runbook.md) | 알림 발생 시 확인/진단/조치 절차 정리 |
| [incident-report.md](incident-report.md) | 장애 타임라인, 영향, 원인, 재발 방지 정리 |

## 사용 기준

| 작업 | 사용할 템플릿 |
|------|------|
| 새 워크로드에 KEDA를 적용한 뒤 문서화 | [service-doc.md](service-doc.md) |
| ScaledObject/HPA 알림 대응 절차 작성 | [runbook.md](runbook.md) |
| 스케일링 장애 회고와 재발 방지 정리 | [incident-report.md](incident-report.md) |

## 관련 문서

- [../README.md](../README.md)
- [../rules/README.md](../rules/README.md)
- [../agents/README.md](../agents/README.md)
