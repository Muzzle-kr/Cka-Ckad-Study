# Day 6: 실전 통합 연습 - Advanced Pod Configuration

## 🎯 학습 목표
- 2주차 모든 개념을 통합한 실전 애플리케이션 배포
- ConfigMap, Secret, ServiceAccount, RBAC, Probe, Resource 관리를 모두 활용
- 마이크로서비스 아키텍처 구현 및 운영
- 실제 프로덕션 환경과 유사한 완전한 배포 시나리오 경험

---

## 📚 통합 개념 복습

### 2주차 학습 내용 요약

#### Day 1: ConfigMap 기초
- 설정 데이터를 애플리케이션에서 분리
- 환경변수, 볼륨 마운트를 통한 활용
- 동적 설정 업데이트

#### Day 2: Secret 관리
- 민감한 정보의 안전한 저장
- TLS 인증서, 데이터베이스 패스워드 관리
- Base64 인코딩과 보안 고려사항

#### Day 3: ServiceAccount & RBAC
- Pod의 신원 관리
- 세밀한 권한 제어
- 최소 권한 원칙 적용

#### Day 4: Probe 설정
- 애플리케이션 건강성 모니터링
- Liveness, Readiness, Startup Probe
- 장애 자동 복구

#### Day 5: Resource Management & QoS
- CPU/Memory 리소스 최적화
- QoS Classes와 우선순위
- Pod 스케줄링 제어

---

## 🏗️ 실전 프로젝트: E-Commerce 마이크로서비스

### 프로젝트 아키텍처

```
┌─────────────────────────────────────────────┐
│               Load Balancer                 │
└─────────────────┬───────────────────────────┘
                  │
    ┌─────────────┴─────────────┐
    │                           │
┌───▼────┐  ┌──────────┐  ┌────▼────┐
│Frontend│  │   API     │  │ Admin   │
│  Web   │  │ Gateway   │  │ Panel   │
└───┬────┘  └─────┬────┘  └────┬────┘
    │             │            │
    └─────────────┼────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼────┐  ┌────▼────┐  ┌─────▼──┐
│Product │  │ User    │  │Payment │
│Service │  │ Service │  │Service │
└───┬────┘  └────┬────┘  └─────┬──┘
    │             │             │
    └─────────────┼─────────────┘
                  │
        ┌─────────▼─────────┐
        │                   │
    ┌───▼────┐        ┌────▼────┐
    │ Redis  │        │ MongoDB │
    │ Cache  │        │Database │
    └────────┘        └─────────┘
```

### 서비스별 요구사항

#### 1. Frontend Web Service
- **기능**: 사용자 인터페이스
- **설정**: nginx 기반, 정적 파일 서빙
- **보안**: 읽기 전용 권한
- **리소스**: 낮은 CPU, 적당한 메모리

#### 2. API Gateway
- **기능**: 라우팅, 인증, 로드밸런싱
- **설정**: 환경별 라우팅 규칙
- **보안**: 중간 수준 권한, TLS 인증서
- **리소스**: 중간 CPU, 높은 메모리

#### 3. Product Service
- **기능**: 상품 카탈로그 관리
- **설정**: 데이터베이스 연결 정보
- **보안**: 데이터베이스 접근 권한
- **리소스**: 높은 CPU, 중간 메모리

#### 4. User Service
- **기능**: 사용자 관리, 인증
- **설정**: JWT 비밀키, 이메일 설정
- **보안**: 높은 보안 권한
- **리소스**: 중간 CPU, 높은 메모리

#### 5. Payment Service
- **기능**: 결제 처리
- **설정**: 결제 게이트웨이 설정
- **보안**: 최고 보안 권한, 전용 노드
- **리소스**: 보장된 리소스 (Guaranteed QoS)

---

## 🔧 단계별 구현 가이드

### Phase 1: 기반 인프라 구성

#### Step 1: Namespace 및 기본 설정
```bash
# 전용 네임스페이스 생성
kubectl create namespace ecommerce

# 기본 네임스페이스 설정
kubectl config set-context --current --namespace=ecommerce
```

#### Step 2: ConfigMap 생성
```bash
# 애플리케이션 설정
kubectl apply -f configmaps/app-config.yaml

# 데이터베이스 설정
kubectl apply -f configmaps/db-config.yaml

# nginx 설정
kubectl apply -f configmaps/nginx-config.yaml
```

#### Step 3: Secret 생성
```bash
# 데이터베이스 인증 정보
kubectl apply -f secrets/db-credentials.yaml

# JWT 토큰 비밀키
kubectl apply -f secrets/jwt-secret.yaml

# TLS 인증서
kubectl apply -f secrets/tls-certificates.yaml
```

### Phase 2: RBAC 구성

#### Step 1: ServiceAccount 생성
```bash
# 각 서비스별 ServiceAccount
kubectl apply -f rbac/service-accounts.yaml
```

#### Step 2: Role 및 RoleBinding 설정
```bash
# 서비스별 권한 설정
kubectl apply -f rbac/roles.yaml
kubectl apply -f rbac/role-bindings.yaml
```

### Phase 3: 애플리케이션 배포

#### Step 1: 데이터베이스 서비스
```bash
# MongoDB 배포
kubectl apply -f deployments/mongodb.yaml

# Redis 배포
kubectl apply -f deployments/redis.yaml
```

#### Step 2: 백엔드 서비스들
```bash
# User Service
kubectl apply -f deployments/user-service.yaml

# Product Service
kubectl apply -f deployments/product-service.yaml

# Payment Service
kubectl apply -f deployments/payment-service.yaml
```

#### Step 3: 프론트엔드 및 게이트웨이
```bash
# API Gateway
kubectl apply -f deployments/api-gateway.yaml

# Frontend Web
kubectl apply -f deployments/frontend.yaml
```

### Phase 4: 서비스 연결 및 노출

#### Step 1: 내부 서비스 생성
```bash
kubectl apply -f services/internal-services.yaml
```

#### Step 2: 외부 접근 설정
```bash
kubectl apply -f services/external-services.yaml
```

---

## 🧪 고급 실습 시나리오

### 시나리오 1: 보안 강화 배포

#### 목표
Payment Service를 전용 노드에 격리하고 최고 보안 설정 적용

#### 구현 단계
```bash
# 1. 결제 전용 노드 설정
kubectl label nodes <node-name> workload=payment
kubectl taint nodes <node-name> payment=true:NoSchedule

# 2. Payment Service 배포
kubectl apply -f advanced/secure-payment-service.yaml

# 3. 보안 정책 적용
kubectl apply -f security/network-policies.yaml
```

#### 검증
```bash
# Payment Pod가 전용 노드에 배포되었는지 확인
kubectl get pod -l app=payment-service -o wide

# 네트워크 정책 확인
kubectl describe networkpolicy payment-isolation
```

### 시나리오 2: 고가용성 구성

#### 목표
모든 서비스의 고가용성 확보 및 장애 복구 능력 구현

#### 구현 단계
```bash
# 1. Multi-replica 배포
kubectl apply -f ha/high-availability.yaml

# 2. Pod Disruption Budget 설정
kubectl apply -f ha/pod-disruption-budgets.yaml

# 3. Anti-Affinity 설정으로 분산 배치
kubectl apply -f ha/anti-affinity-deployments.yaml
```

#### 검증
```bash
# 각 서비스의 replica 분산 확인
kubectl get pods -o wide | grep -E "(user|product|payment)"

# PDB 상태 확인
kubectl get pdb
```

### 시나리오 3: 성능 최적화

#### 목표
리소스 사용량 최적화 및 QoS 기반 우선순위 설정

#### 구현 단계
```bash
# 1. 리소스 최적화된 배포
kubectl apply -f optimization/resource-optimized.yaml

# 2. HPA (Horizontal Pod Autoscaler) 설정
kubectl apply -f optimization/hpa-configs.yaml

# 3. 리소스 모니터링 설정
kubectl apply -f monitoring/resource-monitoring.yaml
```

#### 검증
```bash
# QoS 클래스별 Pod 분류 확인
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass

# HPA 상태 확인
kubectl get hpa

# 리소스 사용량 모니터링
kubectl top pods
kubectl top nodes
```

### 시나리오 4: 설정 동적 업데이트

#### 목표
무중단으로 애플리케이션 설정 업데이트

#### 구현 단계
```bash
# 1. 초기 설정으로 배포
kubectl apply -f dynamic/initial-config.yaml

# 2. 설정 변경 (ConfigMap 업데이트)
kubectl apply -f dynamic/updated-config.yaml

# 3. Rolling Update 수행
kubectl rollout restart deployment/api-gateway
kubectl rollout restart deployment/product-service
```

#### 검증
```bash
# Rolling Update 상태 확인
kubectl rollout status deployment/api-gateway

# 설정 변경 확인
kubectl exec -it <pod-name> -- env | grep CONFIG
```

---

## 📊 종합 모니터링 및 트러블슈팅

### 전체 시스템 상태 확인

#### 1. 네임스페이스 리소스 현황
```bash
# 모든 리소스 요약
kubectl get all -n ecommerce

# ConfigMap 및 Secret 현황
kubectl get configmaps,secrets -n ecommerce

# ServiceAccount 및 RBAC 현황
kubectl get serviceaccounts,roles,rolebindings -n ecommerce
```

#### 2. 애플리케이션 건강성 검사
```bash
# 모든 Pod 상태 확인
kubectl get pods -o wide

# Probe 실패 이벤트 확인
kubectl get events --field-selector type=Warning

# 서비스 연결성 테스트
kubectl exec -it <frontend-pod> -- curl http://api-gateway:8080/health
```

#### 3. 리소스 사용량 분석
```bash
# 네임스페이스별 리소스 사용량
kubectl top pods -n ecommerce

# 노드 리소스 분포
kubectl describe nodes | grep -A 5 "Allocated resources"

# QoS 기반 우선순위 분석
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,NODE:.spec.nodeName
```

### 일반적인 문제 해결

#### 1. Pod 시작 실패
```bash
# Pod 상태 상세 확인
kubectl describe pod <pod-name>

# 로그 확인
kubectl logs <pod-name> --previous

# 이벤트 확인
kubectl get events --sort-by='.lastTimestamp'
```

#### 2. 서비스 연결 문제
```bash
# 서비스 엔드포인트 확인
kubectl get endpoints

# DNS 해결 테스트
kubectl exec -it <pod-name> -- nslookup <service-name>

# 네트워크 연결 테스트
kubectl exec -it <pod-name> -- nc -zv <service-name> <port>
```

#### 3. 리소스 부족 문제
```bash
# 노드 용량 확인
kubectl describe nodes | grep -A 10 "Capacity\|Allocatable"

# 리소스 요청량 확인
kubectl describe quota

# Pending Pod 원인 분석
kubectl describe pod <pending-pod> | grep Events -A 10
```

---

## 🎯 실전 시험 대비

### CKA 관련 문제 유형

#### 1. 복합 리소스 생성
**문제**: ConfigMap, Secret, ServiceAccount를 모두 활용하는 Pod 생성

**해결 과정**:
```bash
# 1. ConfigMap 생성
kubectl create configmap app-config --from-literal=APP_ENV=production

# 2. Secret 생성
kubectl create secret generic db-secret --from-literal=password=secretpassword

# 3. ServiceAccount 생성
kubectl create serviceaccount app-sa

# 4. Pod YAML 작성 및 적용
kubectl apply -f complex-pod.yaml
```

#### 2. 권한 문제 해결
**문제**: Pod에서 특정 API 호출 시 권한 오류 발생

**해결 과정**:
```bash
# 1. 현재 권한 확인
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<sa-name>

# 2. 필요한 Role 생성
kubectl create role pod-reader --verb=get,list --resource=pods

# 3. RoleBinding 생성
kubectl create rolebinding pod-reader-binding --role=pod-reader --serviceaccount=default:app-sa
```

#### 3. 리소스 최적화
**문제**: 클러스터 리소스 부족으로 Pod 스케줄링 실패

**해결 과정**:
```bash
# 1. 현재 리소스 사용량 확인
kubectl top nodes
kubectl describe nodes

# 2. 비효율적인 Pod 식별
kubectl get pods -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[*].resources.requests.cpu,MEMORY:.spec.containers[*].resources.requests.memory

# 3. 리소스 조정
kubectl patch deployment <deployment-name> -p '{"spec":{"template":{"spec":{"containers":[{"name":"<container-name>","resources":{"requests":{"cpu":"100m","memory":"128Mi"}}}]}}}}'
```

### CKAD 관련 문제 유형

#### 1. 멀티 컨테이너 패턴
**문제**: Sidecar 패턴을 활용한 로그 수집 구현

**해결**: `examples/multi-container-patterns.yaml` 참조

#### 2. 설정 분리
**문제**: 환경별로 다른 설정을 가진 애플리케이션 배포

**해결**: ConfigMap과 환경변수를 활용한 설정 분리

#### 3. 헬스체크 구현
**문제**: 애플리케이션 특성에 맞는 Probe 구성

**해결**: Liveness, Readiness, Startup Probe 조합 활용

---

## 📝 프로젝트 완성 체크리스트

### 필수 구현 항목
- [ ] 전체 마이크로서비스 아키텍처 배포
- [ ] ConfigMap을 활용한 설정 관리
- [ ] Secret을 활용한 민감 정보 관리
- [ ] RBAC를 통한 보안 권한 설정
- [ ] Probe를 통한 헬스체크 구현
- [ ] Resource 관리를 통한 성능 최적화
- [ ] 서비스 간 연결 및 외부 접근 구성

### 고급 구현 항목
- [ ] 전용 노드를 활용한 보안 격리
- [ ] Anti-Affinity를 통한 고가용성 구현
- [ ] HPA를 통한 자동 스케일링
- [ ] 네트워크 정책을 통한 보안 강화
- [ ] 무중단 배포 및 설정 업데이트
- [ ] 종합 모니터링 및 로깅 구성

### 운영 검증 항목
- [ ] 전체 시스템 건강성 확인
- [ ] 장애 시나리오 테스트
- [ ] 성능 및 리소스 사용량 분석
- [ ] 보안 정책 검증
- [ ] 백업 및 복구 절차 확인

---

## 🔗 참고 자료 및 다음 단계

### 공식 문서
- [Kubernetes 애플리케이션 관리](https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/)
- [Production 환경 베스트 프랙티스](https://kubernetes.io/docs/setup/best-practices/)
- [보안 가이드라인](https://kubernetes.io/docs/concepts/security/)

### 추가 학습 방향
- **3주차**: 스토리지 & 네트워크 (PV/PVC, NetworkPolicy)
- **4주차**: 클러스터 운영 관리 (etcd 백업, 노드 관리)
- **5주차**: Helm & 트러블슈팅

### 실무 적용
- CI/CD 파이프라인 통합
- 모니터링 솔루션 (Prometheus, Grafana) 연동
- 로깅 시스템 (ELK Stack) 구축
- 보안 스캐닝 도구 적용

---

## 🎉 2주차 학습 완료

축하합니다! 2주차 K8s 핵심 리소스 학습을 모두 완료하셨습니다.

### 이번 주 성취
- ✅ ConfigMap으로 설정 분리 마스터
- ✅ Secret으로 보안 정보 관리 구현
- ✅ RBAC로 세밀한 권한 제어 적용
- ✅ Probe로 애플리케이션 건강성 모니터링
- ✅ Resource 관리로 성능 최적화
- ✅ 실전 통합 프로젝트 완성

### 다음 목표
**3주차**: 스토리지 & 네트워크로 더욱 견고한 클러스터 구축을 위해 전진!