# keda-practice — 프로젝트 가이드

## 프로젝트 설정
- 환경: EKS
- KEDA 버전: 2.16.1
- KEDA 네임스페이스: keda
- application 네임스페이스: default
- Kubernetes 최소 버전: v1.27

---

## 디렉토리 구조

```
keda-practice/
├── CLAUDE.md                  # 이 파일 (자동 로드)
├── .claude/
│   ├── settings.json
│   └── commands/              # /new-doc, /new-runbook, /review-doc, /add-troubleshooting, /search-kb
├── agents/                    # doc-writer, scaler-designer, troubleshooter, performance-advisor
├── templates/                 # service-doc, runbook, incident-report
├── rules/                     # doc-writing, keda-conventions, security-checklist, monitoring
├── manifests/                 # ScaledObject/ScaledJob YAML 예시
└── docs/                      # 주제별 가이드 문서
```

---

## 커스텀 슬래시 명령어

| 명령어 | 설명 | 사용 예시 |
|--------|------|---------|
| `/new-doc` | 새 가이드 문서 생성 | `/new-doc sqs-scaler` |
| `/new-runbook` | 새 런북 생성 | `/new-runbook ScaledObject 비활성화` |
| `/review-doc` | 문서/YAML 검토 | `/review-doc prometheus-scaler.md` |
| `/add-troubleshooting` | 트러블슈팅 케이스 추가 | `/add-troubleshooting 스케일 업 미동작` |
| `/search-kb` | 지식베이스 검색 | `/search-kb Prometheus 메트릭 스케일링` |

---

## 가이드 문서 목록

| 문서 | 주제 |
|------|------|
| `docs/install.md` | KEDA 설치 (Helm) |
| `docs/hands-on.md` | 기본 실습 |
| `docs/scaledobject-guide.md` | ScaledObject 개념 및 설정 |
| `docs/scaledjob-guide.md` | ScaledJob 개념 및 설정 |
| `docs/triggerauth-guide.md` | TriggerAuthentication 보안 설정 |
| `docs/prometheus-scaler.md` | Prometheus 메트릭 기반 스케일링 |
| `docs/kafka-scaler.md` | Kafka 컨슈머 랙 기반 스케일링 |
| `docs/redis-scaler.md` | Redis 리스트 길이 기반 스케일링 |
| `docs/cron-scaler.md` | Cron 스케줄 기반 스케일링 |
| `docs/cloudwatch-scaler.md` | AWS CloudWatch 메트릭 기반 스케일링 (EKS IRSA) |

---

## 핵심 확인 명령어

```bash
# ScaledObject 상태
kubectl get scaledobject -A
kubectl describe scaledobject <name> -n <namespace>

# 생성된 HPA 확인
kubectl get hpa -n <namespace>

# KEDA operator 로그
kubectl logs -n keda -l app=keda-operator --tail=100

# 스케일링 일시 정지
kubectl annotate scaledobject <name> autoscaling.keda.sh/paused=true
```
