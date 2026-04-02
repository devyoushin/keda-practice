# TriggerAuthentication

TriggerAuthentication은 외부 이벤트 소스에 접근하기 위한 인증 정보를 ScaledObject/ScaledJob과 분리하여 관리하는 리소스입니다.
Secret, Pod Identity, Vault 등 다양한 방식으로 인증 정보를 제공할 수 있습니다.

---

## 1. TriggerAuthentication vs ClusterTriggerAuthentication

| 항목 | TriggerAuthentication | ClusterTriggerAuthentication |
|------|----------------------|------------------------------|
| 범위 | 특정 네임스페이스 | 클러스터 전체 |
| 사용 대상 | 같은 네임스페이스의 ScaledObject | 모든 네임스페이스의 ScaledObject |

---

## 2. Secret 참조 방식

가장 일반적인 방식입니다. Kubernetes Secret의 값을 scaler 파라미터에 매핑합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: kafka-trigger-auth
  namespace: default
spec:
  secretTargetRef:
    - parameter: sasl             # scaler에서 사용하는 파라미터 이름
      name: kafka-secret          # Secret 이름
      key: sasl-mechanism         # Secret 내 key
    - parameter: username
      name: kafka-secret
      key: username
    - parameter: password
      name: kafka-secret
      key: password
```

Secret 예시:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kafka-secret
  namespace: default
type: Opaque
stringData:
  sasl-mechanism: PLAIN
  username: my-user
  password: my-password
```

---

## 3. ScaledObject에서 참조하는 방법

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: my-scaledobject
spec:
  scaleTargetRef:
    name: my-deployment
  triggers:
    - type: kafka
      metadata:
        bootstrapServers: kafka:9092
        consumerGroup: my-group
        topic: my-topic
        lagThreshold: "10"
        sasl: PLAIN
        tls: enable
      authenticationRef:
        name: kafka-trigger-auth   # TriggerAuthentication 이름
```

---

## 4. ClusterTriggerAuthentication 사용

여러 네임스페이스에서 같은 인증 정보를 공유할 때 사용합니다.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ClusterTriggerAuthentication
metadata:
  name: cluster-kafka-auth        # 네임스페이스 없음
spec:
  secretTargetRef:
    - parameter: username
      name: kafka-secret
      key: username
    - parameter: password
      name: kafka-secret
      key: password
```

ScaledObject에서 참조할 때 `kind`를 명시합니다:

```yaml
authenticationRef:
  name: cluster-kafka-auth
  kind: ClusterTriggerAuthentication
```

> ClusterTriggerAuthentication이 참조하는 Secret은 KEDA가 설치된 네임스페이스(`keda`)에 있어야 합니다.

---

## 5. 상태 확인

```bash
# TriggerAuthentication 조회
kubectl get triggerauthentication -n default

# ClusterTriggerAuthentication 조회
kubectl get clustertriggerauthentication
```

---

## 참고

- [TriggerAuthentication 공식 문서](https://keda.sh/docs/latest/concepts/authentication/)
