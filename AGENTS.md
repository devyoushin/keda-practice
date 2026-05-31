# AGENTS.md — keda-practice Codex 작업 지침

이 저장소는 KEDA 이벤트 기반 스케일링 학습/운영 지식 베이스입니다. Codex 작업 시 `CLAUDE.md`와 `docs/rules/`의 규칙을 동일하게 따릅니다.

## 공통 원칙

- 설명 문서는 `docs/`에 둡니다.
- ScaledObject, TriggerAuthentication, 설치/업그레이드 스크립트는 `ops/`에 둡니다.
- scaler 예시는 metric source, 인증 방식, fallback, cooldown, min/max replica를 함께 설명합니다.
- 운영 문서에는 HPA/KEDA 충돌 가능성과 모니터링 지표를 포함합니다.

## Claude와의 싱크

- Claude용 상세 지침은 `CLAUDE.md`를 참고합니다.
- Codex도 공통 규칙은 `docs/rules/`를 따릅니다.
- 규칙 변경 시 두 에이전트 파일의 참조가 같은지 확인합니다.

## 작업 체크리스트

- `git status --short`로 기존 변경 확인
- YAML 문법 검사
- shell script는 `bash -n` 검사
- 마크다운 상대 링크 검사
- `git diff --check` 수행
