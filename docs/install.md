# KEDA 설치 (Helm)

Helm을 사용해 KEDA를 Kubernetes 클러스터에 설치합니다.

---

## 1. Helm 레포지토리 추가

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

---

## 2. 네임스페이스 생성

```bash
kubectl create namespace keda
```

---

## 3. 설치

```bash
helm install keda kedacore/keda \
  --namespace keda \
  --version 2.16.1
```

설치 가능한 버전 목록 확인:

```bash
helm search repo kedacore/keda --versions
```

---

## 4. 설치 확인

```bash
kubectl get pods -n keda
```

```
NAME                                               READY   STATUS    RESTARTS   AGE
keda-admission-webhooks-xxxxxxxxx-xxxxx            1/1     Running   0          1m
keda-operator-xxxxxxxxx-xxxxx                      1/1     Running   0          1m
keda-operator-metrics-apiserver-xxxxxxxxx-xxxxx    1/1     Running   0          1m
```

CRD 등록 확인:

```bash
kubectl get crd | grep keda
```

```
clustertriggerauthentications.keda.sh
scaledjobs.keda.sh
scaledobjects.keda.sh
triggerauthentications.keda.sh
```

---

## 5. 업그레이드

```bash
helm repo update
helm upgrade keda kedacore/keda --namespace keda
```

---

## 6. 제거

```bash
helm uninstall keda --namespace keda
kubectl delete namespace keda
```

> CRD는 `helm uninstall` 시 자동으로 삭제되지 않습니다. 완전히 제거하려면 아래 명령을 추가로 실행합니다.

```bash
kubectl delete crd \
  scaledobjects.keda.sh \
  scaledjobs.keda.sh \
  triggerauthentications.keda.sh \
  clustertriggerauthentications.keda.sh
```

---

## 참고

- [KEDA Helm Chart](https://github.com/kedacore/charts)
- [KEDA 공식 설치 문서](https://keda.sh/docs/latest/deploy/)
- [KEDA 업그레이드](./install/upgrade/)
