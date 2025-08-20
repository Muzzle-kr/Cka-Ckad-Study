# Day 3: ServiceAccount & RBAC (Role-Based Access Control)

## 🎯 학습 목표 (35분)
- ServiceAccount의 개념과 생성 방법 이해
- Role과 RoleBinding 설정을 통한 권한 관리
- ClusterRole과 ClusterRoleBinding 활용
- RBAC를 통한 보안 강화 전략 학습

---

## 📋 학습 내용

### 1. ServiceAccount 기본 개념

**ServiceAccount란?**
- Pod가 Kubernetes API에 접근할 때 사용하는 계정
- 기본적으로 각 네임스페이스마다 `default` ServiceAccount가 생성됨
- 애플리케이션별로 별도의 ServiceAccount를 생성하여 권한을 세밀하게 관리

```bash
# ServiceAccount 조회
kubectl get serviceaccounts
kubectl get sa  # 축약형

# 특정 ServiceAccount 상세 정보
kubectl describe sa default
```

### 2. ServiceAccount 생성 및 관리

```bash
# ServiceAccount 생성
kubectl create serviceaccount my-service-account

# YAML로 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: webapp-sa
  namespace: default
automountServiceAccountToken: true  # 기본값: true
EOF

# ServiceAccount 삭제
kubectl delete serviceaccount my-service-account
```

**자동 토큰 마운트 제어:**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: secure-sa
automountServiceAccountToken: false  # 토큰 자동 마운트 비활성화
```

### 3. Role과 RoleBinding

**Role**: 특정 네임스페이스 내에서의 권한을 정의
**RoleBinding**: Role을 ServiceAccount, User, Group에 연결

```bash
# Role 생성 - Pod 조회 권한
kubectl create role pod-reader \
  --verb=get,list,watch \
  --resource=pods

# RoleBinding 생성 - ServiceAccount에 Role 할당
kubectl create rolebinding pod-reader-binding \
  --role=pod-reader \
  --serviceaccount=default:webapp-sa
```

### 4. ClusterRole과 ClusterRoleBinding

**ClusterRole**: 클러스터 전체에 대한 권한을 정의
**ClusterRoleBinding**: ClusterRole을 전역적으로 연결

```bash
# ClusterRole 생성 - 모든 네임스페이스의 Pod 조회
kubectl create clusterrole cluster-pod-reader \
  --verb=get,list,watch \
  --resource=pods

# ClusterRoleBinding 생성
kubectl create clusterrolebinding cluster-pod-reader-binding \
  --clusterrole=cluster-pod-reader \
  --serviceaccount=default:webapp-sa
```

### 5. 실습 시나리오

#### 시나리오 1: 읽기 전용 ServiceAccount 생성
```bash
# 1. ServiceAccount 생성
kubectl create serviceaccount readonly-sa

# 2. 읽기 전용 Role 생성
kubectl create role readonly-role \
  --verb=get,list,watch \
  --resource=pods,services,deployments

# 3. RoleBinding으로 연결
kubectl create rolebinding readonly-binding \
  --role=readonly-role \
  --serviceaccount=default:readonly-sa
```

#### 시나리오 2: 네임스페이스별 관리자 권한
```bash
# 1. 관리자 ServiceAccount 생성
kubectl create serviceaccount admin-sa

# 2. 네임스페이스 관리 Role 생성
kubectl create role namespace-admin \
  --verb=* \
  --resource=*

# 3. RoleBinding 생성
kubectl create rolebinding admin-binding \
  --role=namespace-admin \
  --serviceaccount=default:admin-sa
```

### 6. Pod에서 ServiceAccount 사용

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-pod
spec:
  serviceAccountName: webapp-sa  # 사용할 ServiceAccount 지정
  containers:
  - name: webapp
    image: nginx:1.20
    env:
    - name: KUBERNETES_SERVICE_HOST
      value: "kubernetes.default.svc.cluster.local"
```

### 7. 권한 테스트 및 검증

```bash
# ServiceAccount로 권한 테스트
kubectl auth can-i get pods --as=system:serviceaccount:default:webapp-sa
kubectl auth can-i create deployments --as=system:serviceaccount:default:webapp-sa

# 현재 사용자의 권한 확인
kubectl auth can-i get pods
kubectl auth can-i create secrets
kubectl auth can-i '*' '*' --all-namespaces
```

### 8. 보안 모범 사례

#### 최소 권한 원칙 (Principle of Least Privilege)
```bash
# 필요한 리소스와 동작만 허용
kubectl create role specific-role \
  --verb=get,list \
  --resource=pods \
  --resource-name=specific-pod
```

#### 네임스페이스 격리
```bash
# 개발 네임스페이스용 ServiceAccount
kubectl create namespace development
kubectl create serviceaccount dev-sa -n development

# 프로덕션 네임스페이스용 ServiceAccount  
kubectl create namespace production
kubectl create serviceaccount prod-sa -n production
```

#### 토큰 보안
```bash
# ServiceAccount 토큰 확인
kubectl get secrets
kubectl describe secret <service-account-token-name>

# 토큰으로 API 접근 테스트
TOKEN=$(kubectl get secret <token-name> -o jsonpath='{.data.token}' | base64 -d)
curl -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/json" \
     https://kubernetes.default.svc.cluster.local:443/api/v1/pods
```

---

## 🔧 실습 명령어 모음

### 기본 ServiceAccount 관리
```bash
# ServiceAccount 생성
kubectl create serviceaccount <sa-name>

# ServiceAccount 조회
kubectl get serviceaccounts
kubectl describe sa <sa-name>

# ServiceAccount 삭제
kubectl delete serviceaccount <sa-name>
```

### RBAC 권한 설정
```bash
# Role 생성
kubectl create role <role-name> --verb=<verbs> --resource=<resources>

# RoleBinding 생성
kubectl create rolebinding <binding-name> \
  --role=<role-name> \
  --serviceaccount=<namespace>:<sa-name>

# ClusterRole 생성
kubectl create clusterrole <clusterrole-name> --verb=<verbs> --resource=<resources>

# ClusterRoleBinding 생성
kubectl create clusterrolebinding <binding-name> \
  --clusterrole=<clusterrole-name> \
  --serviceaccount=<namespace>:<sa-name>
```

### 권한 확인
```bash
# 권한 테스트
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<sa-name>

# 현재 사용자 권한 확인
kubectl auth can-i <verb> <resource>

# 모든 권한 나열
kubectl auth can-i --list
```

---

## 🚨 주의사항

1. **기본 ServiceAccount 사용 금지**
   - 프로덕션에서는 항상 전용 ServiceAccount 생성
   - `default` ServiceAccount는 최소 권한으로 제한

2. **ClusterRole 사용 주의**
   - 클러스터 전체 권한이므로 신중하게 사용
   - 가능하면 네임스페이스 수준의 Role 사용

3. **토큰 보안 관리**
   - ServiceAccount 토큰은 민감한 정보
   - 필요시에만 자동 마운트 활성화

4. **정기적인 권한 검토**
   - RBAC 설정을 정기적으로 검토하고 정리
   - 불필요한 권한은 즉시 제거

---

## 📚 참고 자료

- [Kubernetes RBAC 공식 문서](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [ServiceAccount 공식 문서](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
- [보안 모범 사례](https://kubernetes.io/docs/concepts/security/)

---

## 🎯 다음 단계

Day 3 학습을 완료했다면:
- ✅ ServiceAccount 생성 및 관리 방법 이해
- ✅ Role/RoleBinding을 통한 권한 설정 숙달
- ✅ RBAC 보안 모범 사례 학습
- ✅ 권한 테스트 및 검증 방법 습득

**다음 학습**: `Day 4 - Probe 설정` (Liveness/Readiness/Startup Probe)