# Helm으로 Keda 설치

### 1. 사전 준비: Helm 저장소 및 네임스페이스
---
#### 레포지토리 추가 및 업데이트
```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

#### 네임스페이스 생성
```bash
kubectl create namespace keda
```

### 2. Kedacore 설치
---
```bash
helm install keda kedacore/keda --namespace keda
```
