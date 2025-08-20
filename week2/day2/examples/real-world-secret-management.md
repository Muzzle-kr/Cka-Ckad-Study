# 실제 운영에서의 Secret 관리 방법

## 🏢 기업 환경에서의 Secret 관리

### 1. 개발 환경
```bash
# 개발자 로컬 환경
kubectl create secret generic db-secret \
  --from-literal=password=dev-password \
  --namespace=development

# 또는 .env 파일 사용 (로컬에만)
echo "DB_PASSWORD=dev-password" > .env
kubectl create secret generic db-secret --from-env-file=.env
```

### 2. 스테이징 환경
```yaml
# CI/CD 파이프라인에서 자동 생성
apiVersion: batch/v1
kind: Job
metadata:
  name: create-secrets
spec:
  template:
    spec:
      containers:
      - name: secret-creator
        image: bitnami/kubectl:latest
        command:
        - /bin/bash
        - -c
        - |
          kubectl create secret generic db-secret \
            --from-literal=password="${STAGING_DB_PASSWORD}" \
            --namespace=staging
        env:
        - name: STAGING_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ci-secrets
              key: staging-db-password
```

### 3. 프로덕션 환경
```yaml
# ArgoCD + Vault 연동
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  source:
    repoURL: https://github.com/company/k8s-configs
    path: apps/my-app
    helm:
      valueFiles:
      - values-prod.yaml
  destination:
    server: https://prod-cluster.example.com
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 🔒 보안 계층 구조

```
┌─────────────────────────────────────┐
│ 1. GitHub Repository (Public)       │
│ ├── 애플리케이션 코드               │
│ ├── Kubernetes 매니페스트           │
│ └── ❌ Secret 값은 절대 저장 안 함   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 2. CI/CD Pipeline (Protected)       │
│ ├── GitHub Secrets                  │
│ ├── Vault Token                     │
│ └── 런타임에 Secret 생성/주입        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ 3. Kubernetes Cluster (Secured)     │
│ ├── etcd 암호화                     │
│ ├── RBAC 권한 제어                  │
│ └── Secret은 런타임에만 존재         │
└─────────────────────────────────────┘
```

## 📋 Secret 관리 모범 사례 체크리스트

### ✅ 해야 할 것
- [ ] External Secret Store 사용 (Vault, AWS Secrets Manager)
- [ ] CI/CD에서 런타임 Secret 생성
- [ ] 환경별 Secret 분리 (dev/staging/prod)
- [ ] Secret 로테이션 자동화
- [ ] RBAC로 접근 제어
- [ ] 감사 로그 모니터링
- [ ] .gitignore에 secret 파일 추가

### ❌ 하지 말아야 할 것
- [ ] GitHub에 평문 Secret 저장
- [ ] 동일한 Secret을 모든 환경에서 사용
- [ ] 개발자 개인 계정으로 Secret 생성
- [ ] Secret을 로그에 출력
- [ ] 장기간 동일한 Secret 사용
- [ ] 모든 사람에게 Secret 접근 권한 부여

## 🛠️ 도구별 비교

| 도구 | 장점 | 단점 | 적합한 환경 |
|------|------|------|-------------|
| **Vault** | 강력한 보안, 동적 Secret | 복잡한 설정 | 대기업, 높은 보안 |
| **Sealed Secrets** | 간단함, GitOps 친화적 | 키 관리 필요 | 중소기업, GitOps |
| **External Secrets** | 클라우드 통합 | 클라우드 종속 | 클라우드 네이티브 |
| **CI/CD 주입** | 단순함, 기존 도구 활용 | 수동 관리 | 스타트업, 빠른 개발 |
