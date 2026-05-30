# 보안 체크리스트 — keda-practice

## TriggerAuthentication
- [ ] 시크릿 직접 참조 금지 — TriggerAuthentication 분리 필수
- [ ] Vault/External Secrets로 시크릿 외부화
- [ ] 시크릿 최소 권한 (읽기 전용)

## KEDA 권한
- [ ] KEDA operator ServiceAccount 최소 권한
- [ ] ScaledObject namespace 범위 제한 (ClusterScaler 지양)

## 스케일링 안전성
- [ ] `maxReplicaCount` 설정으로 스케일 폭주 방지
- [ ] `fallback.replicas` 설정으로 스케일러 오류 시 안전값 유지
- [ ] prod: `minReplicaCount: 1` 이상 (cold start 방지)

## 모니터링
- [ ] KEDA operator 로그 수집
- [ ] HPA 상태 모니터링
- [ ] 스케일링 이벤트 알람 설정
