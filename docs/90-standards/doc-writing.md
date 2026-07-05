# 문서 작성 원칙 — keda-practice

## 언어
- 본문은 한국어, 기술 용어(ScaledObject, TriggerAuthentication)는 영어
- 서술체: `~다.`, `~한다.`

## 문서 구조
1. **개요** — 스케일러 기준 메트릭 설명
2. **TriggerAuthentication** — 시크릿 분리
3. **ScaledObject YAML** — 실제 동작 가능한 예시
4. **확인** — kubectl describe, HPA 상태
5. **트러블슈팅** — KEDA operator 로그

## 코드 블록
- YAML에 한국어 `#` 주석
- `namespace` 항상 명시
- `fallback` 설정 예시 포함

## 주의사항 표시
- 스케일 폭주 위험: `> **스케일 주의**:`
- HPA 충돌 위험: `> **HPA 충돌 주의**:`
