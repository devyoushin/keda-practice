새 KEDA 운영 런북을 생성합니다.

**사용법**: `/new-runbook <작업명>`

**예시**: `/new-runbook ScaledObject 비활성화`

다음 단계를 수행하세요:

1. `templates/runbook.md`를 읽어 템플릿 구조를 확인하세요.
2. 작업 유형을 분류하세요:
   - `스케일링 관리`: ScaledObject 일시 정지/재개
   - `스케일러 변경`: 트리거 소스 변경
   - `긴급 대응`: 스케일링 폭주 차단
   - `업그레이드`: KEDA 버전 업그레이드
3. 런북 포함 내용:
   - 사전 체크리스트 (현재 replica 수, 스케일러 상태)
   - 단계별 kubectl 명령어
   - KEDA operator 로그 확인
   - 롤백 절차 (fallback 설정 활용)
