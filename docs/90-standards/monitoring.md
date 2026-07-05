# 모니터링 지침 — keda-practice

## 핵심 확인 명령어

```bash
# ScaledObject 상태
kubectl get scaledobject -A
kubectl describe scaledobject <name> -n <namespace>

# 생성된 HPA 상태
kubectl get hpa -n <namespace>

# KEDA operator 로그
kubectl logs -n keda -l app=keda-operator --tail=100

# 현재 replica 수 모니터링
watch kubectl get deployment <name> -n <namespace>
```

## Prometheus 메트릭

| 메트릭 | 설명 |
|--------|------|
| `keda_scaler_active` | 스케일러 활성 여부 |
| `keda_scaler_metrics_value` | 현재 메트릭 값 |
| `keda_scaled_object_paused` | 일시 정지 여부 |

## ScaledObject 일시 정지 (긴급 시)

```bash
# 스케일링 일시 정지
kubectl annotate scaledobject <name> autoscaling.keda.sh/paused=true

# 재개
kubectl annotate scaledobject <name> autoscaling.keda.sh/paused-
```
