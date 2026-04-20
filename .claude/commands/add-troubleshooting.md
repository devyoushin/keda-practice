KEDA 트러블슈팅 케이스를 추가합니다.

**사용법**: `/add-troubleshooting <증상 설명>`

**예시**: `/add-troubleshooting ScaledObject가 스케일 업을 트리거하지 않음`

다음 형식으로 케이스를 작성하고 관련 문서에 추가하세요:

```markdown
### <증상>

**원인**: <근본 원인>

**확인 방법**:
\`\`\`bash
kubectl describe scaledobject <name> -n <namespace>
kubectl get hpa -n <namespace>
kubectl logs -n keda -l app=keda-operator
\`\`\`

**해결**: <해결 방법>
**예방**: <재발 방지>
```
