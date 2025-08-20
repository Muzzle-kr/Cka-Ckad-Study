# RBAC 트러블슈팅 가이드

## 🚨 자주 발생하는 RBAC 문제들과 해결 방법

### 1. "Forbidden" 에러 해결

#### 증상
```bash
Error from server (Forbidden): pods is forbidden: 
User "system:serviceaccount:default:webapp-sa" cannot get resource "pods" in API group "" in the namespace "default"
```

#### 원인 분석
```bash
# 1. ServiceAccount 권한 확인
kubectl auth can-i get pods --as=system:serviceaccount:default:webapp-sa

# 2. 현재 바인딩 상태 확인
kubectl get rolebindings -o wide | grep webapp-sa
kubectl get clusterrolebindings -o wide | grep webapp-sa

# 3. Role 내용 확인
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>
```

#### 해결 방법
```bash
# 필요한 권한을 가진 Role 생성
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# RoleBinding으로 연결
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=default:webapp-sa
```

### 2. ServiceAccount 토큰이 마운트되지 않는 문제

#### 증상
Pod에서 Kubernetes API 접근 시 토큰을 찾을 수 없음

#### 확인 방법
```bash
# Pod 설정 확인
kubectl get pod <pod-name> -o yaml | grep -A5 -B5 serviceAccount

# ServiceAccount 토큰 자동 마운트 설정 확인
kubectl get sa <sa-name> -o yaml | grep automount
```

#### 해결 방법
```bash
# ServiceAccount에서 자동 마운트 활성화
kubectl patch serviceaccount <sa-name> \
  -p '{"automountServiceAccountToken": true}'

# 또는 Pod 레벨에서 설정
kubectl patch pod <pod-name> \
  -p '{"spec":{"automountServiceAccountToken": true}}'
```

### 3. 네임스페이스 간 권한 문제

#### 증상
다른 네임스페이스의 리소스에 접근할 수 없음

#### 확인 방법
```bash
# 네임스페이스별 권한 확인
kubectl auth can-i get pods --namespace=production \
  --as=system:serviceaccount:default:webapp-sa

# ClusterRole vs Role 확인
kubectl get roles -A | grep <role-name>
kubectl get clusterroles | grep <role-name>
```

#### 해결 방법
```bash
# 여러 네임스페이스 접근이 필요한 경우 ClusterRole 사용
kubectl create clusterrole multi-namespace-reader \
  --verb=get,list,watch --resource=pods

kubectl create clusterrolebinding multi-namespace-binding \
  --clusterrole=multi-namespace-reader \
  --serviceaccount=default:webapp-sa
```

### 4. 과도한 권한 부여 문제

#### 보안 위험 사항
```bash
# 위험한 권한 설정 예시 (절대 사용 금지!)
kubectl create clusterrole dangerous-role --verb='*' --resource='*'
kubectl create role admin-all --verb='*' --resource='*'
```

#### 최소 권한 원칙 적용
```bash
# 좋은 예: 필요한 권한만 부여
kubectl create role specific-reader \
  --verb=get,list \
  --resource=pods,services \
  --resource-name=specific-pod,specific-service

# 나쁜 예: 모든 권한 부여
kubectl create role bad-admin --verb='*' --resource='*'
```

### 5. RoleBinding vs ClusterRoleBinding 혼동

#### 차이점 이해
```bash
# Role + RoleBinding: 특정 네임스페이스에서만 유효
kubectl create role ns-reader --verb=get --resource=pods
kubectl create rolebinding ns-reader-binding \
  --role=ns-reader --serviceaccount=default:sa

# ClusterRole + ClusterRoleBinding: 전체 클러스터에서 유효
kubectl create clusterrole cluster-reader --verb=get --resource=pods
kubectl create clusterrolebinding cluster-reader-binding \
  --clusterrole=cluster-reader --serviceaccount=default:sa

# ClusterRole + RoleBinding: 특정 네임스페이스에서만 ClusterRole 사용
kubectl create rolebinding cluster-role-in-ns \
  --clusterrole=cluster-reader --serviceaccount=default:sa
```

## 🔍 디버깅 명령어 체크리스트

### 1. 권한 확인
```bash
# 기본 권한 체크
kubectl auth can-i <verb> <resource>
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<sa-name>

# 모든 권한 나열
kubectl auth can-i --list
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<sa-name>

# 특정 네임스페이스에서 권한 확인
kubectl auth can-i get pods -n production
```

### 2. RBAC 리소스 상태 확인
```bash
# ServiceAccount 확인
kubectl get sa
kubectl describe sa <sa-name>

# Role/ClusterRole 확인
kubectl get roles,clusterroles
kubectl describe role <role-name>
kubectl describe clusterrole <clusterrole-name>

# RoleBinding/ClusterRoleBinding 확인
kubectl get rolebindings,clusterrolebindings
kubectl describe rolebinding <binding-name>
kubectl describe clusterrolebinding <binding-name>
```

### 3. 이벤트 및 로그 확인
```bash
# 권한 관련 이벤트
kubectl get events --field-selector reason=Forbidden
kubectl get events --field-selector type=Warning

# API 서버 로그 (관리자 권한 필요)
kubectl logs -n kube-system kube-apiserver-<node-name>
```

### 4. 토큰 관련 확인
```bash
# ServiceAccount 토큰 시크릿 확인
kubectl get secrets | grep <sa-name>
kubectl describe secret <token-secret-name>

# Pod 내 토큰 마운트 확인
kubectl exec <pod-name> -- ls -la /var/run/secrets/kubernetes.io/serviceaccount/
kubectl exec <pod-name> -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

## 💡 모범 사례

### 1. 최소 권한 원칙
- 필요한 최소한의 권한만 부여
- 정기적인 권한 검토 및 정리
- 사용하지 않는 ServiceAccount 삭제

### 2. 네임스페이스 격리
- 환경별 네임스페이스 분리 (dev, staging, prod)
- 네임스페이스별 전용 ServiceAccount 사용
- 크로스 네임스페이스 접근 최소화

### 3. 모니터링 및 감사
- RBAC 변경 사항 로깅
- 권한 사용 모니터링
- 정기적인 보안 검토

### 4. 문서화
- RBAC 정책 문서화
- 권한 변경 이력 관리
- 트러블슈팅 가이드 유지

## 🚀 실전 팁

### 빠른 권한 테스트
```bash
# 한 줄로 권한 확인
kubectl auth can-i get pods --as=system:serviceaccount:default:webapp-sa && echo "✅ 허용" || echo "❌ 거부"

# 여러 권한을 한 번에 테스트
for verb in get list create update delete; do
  echo -n "$verb: "
  kubectl auth can-i $verb pods --as=system:serviceaccount:default:webapp-sa && echo "✅" || echo "❌"
done
```

### 권한 매트릭스 생성
```bash
# 특정 ServiceAccount의 모든 권한을 표 형태로 출력
kubectl auth can-i --list --as=system:serviceaccount:default:webapp-sa | column -t
```

이 가이드를 통해 RBAC 관련 문제를 빠르게 진단하고 해결할 수 있습니다!