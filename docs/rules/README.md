# 문서와 운영 규칙

KEDA 문서와 운영 절차를 쓸 때 지켜야 할 기준입니다. 새 문서를 추가하거나 기존 문서를 고칠 때 먼저 확인합니다.

## 문서 목록

| 문서 | 용도 |
|------|------|
| [doc-writing.md](doc-writing.md) | 문서 언어, 구조, 코드 블록, 주의사항 표시 기준 |
| [keda-conventions.md](keda-conventions.md) | ScaledObject, TriggerAuthentication, ScaledJob 작성 규칙 |
| [monitoring.md](monitoring.md) | ScaledObject/HPA/KEDA operator 확인 명령어와 모니터링 기준 |
| [security-checklist.md](security-checklist.md) | 인증 정보 분리, 권한, 스케일링 안전성, 보안 점검 기준 |

## 적용 순서

1. 새 문서를 만들 때 [doc-writing.md](doc-writing.md)를 확인합니다.
2. KEDA YAML과 예시는 [keda-conventions.md](keda-conventions.md)를 따릅니다.
3. 운영 확인 명령어와 메트릭은 [monitoring.md](monitoring.md)를 기준으로 맞춥니다.
4. Secret, TriggerAuthentication, 권한 설정은 [security-checklist.md](security-checklist.md)로 점검합니다.

## 관련 문서

- [../README.md](../README.md)
- [../agents/README.md](../agents/README.md)
- [../templates/README.md](../templates/README.md)
