KEDA 가이드 문서 또는 YAML을 검토합니다.

**사용법**: `/review-doc <파일 경로>`

**예시**: `/review-doc docs/prometheus-scaler.md`

다음 기준으로 검토하세요:

**ScaledObject YAML**
- [ ] `minReplicaCount`/`maxReplicaCount` 설정 여부
- [ ] `cooldownPeriod`, `pollingInterval` 적절성
- [ ] `fallback` 설정 (스케일러 오류 시 기본값)
- [ ] TriggerAuthentication 분리 여부 (시크릿 직접 참조 금지)
- [ ] `advanced.restoreToOriginalReplicaCount` 설정

**ScaledJob YAML**
- [ ] `maxReplicaCount`, `successfulJobsHistoryLimit` 설정
- [ ] `scalingStrategy` 적절성 (default/custom/accurate)

**문서 품질**
- [ ] YAML 예시 동작 가능 여부
- [ ] 메트릭 쿼리 설명 포함 여부
- [ ] 트러블슈팅 포함 여부
