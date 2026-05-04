새 KEDA 가이드 문서를 생성합니다.

**사용법**: `/new-doc <주제명>`

**예시**: `/new-doc sqs-scaler`

다음 단계를 수행하세요:

1. `templates/service-doc.md`를 읽어 템플릿 구조를 확인하세요.
2. 주제를 분류하세요:
   - 스케일러: prometheus, kafka, redis, cron, sqs, custom
   - 오브젝트: scaledobject, scaledjob, triggerauth
   - 운영: install, hands-on
3. `docs/<주제명>-guide.md` 또는 `docs/<주제명>-scaler.md`를 생성하세요:
   - CLAUDE.md 환경 설정 반영 (EKS, KEDA 버전)
   - ScaledObject/ScaledJob YAML 예시
   - TriggerAuthentication 설정 (해당 시)
   - kubectl 확인 명령어
   - 트러블슈팅 섹션
