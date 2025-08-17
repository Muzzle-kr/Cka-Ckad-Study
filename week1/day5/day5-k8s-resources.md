# Day 5: K8s 리소스 기초 (Pod, Deployment, Service)

## 📚 학습 목표
- Kubernetes의 핵심 리소스인 Pod, Deployment, Service의 개념과 차이점 이해
- 각 리소스의 역할과 사용 시나리오 파악
- 실제 YAML 매니페스트 작성 및 적용 실습

---

## 1. Pod (파드) 💡

### Pod이란?
Pod는 Kubernetes에서 배포할 수 있는 **가장 작은 단위**입니다.

**핵심 특징:**
- 하나 이상의 컨테이너를 그룹화
- 동일한 네트워크 네임스페이스 공유 (같은 IP)
- 스토리지 볼륨 공유
- 함께 스케줄링되고 함께 종료됨

### Pod 생성 방법

#### 1) 명령어로 생성
```bash
# 기본 Pod 생성
kubectl run nginx-pod --image=nginx

# 포트 지정하여 생성
kubectl run nginx-pod --image=nginx --port=80

# 환경변수와 함께 생성
kubectl run nginx-pod --image=nginx --env="ENV=production"
```

#### 2) YAML 매니페스트로 생성
```yaml
# nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    ports:
    - containerPort: 80
    env:
    - name: ENV
      value: "production"
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Pod 관리 명령어
```bash
# Pod 조회
kubectl get pods
kubectl get pods -o wide  # 더 자세한 정보

# Pod 상세 정보
kubectl describe pod nginx-pod

# Pod 로그 확인
kubectl logs nginx-pod
kubectl logs nginx-pod -f  # 실시간 로그

# Pod 내부 접속
kubectl exec -it nginx-pod -- bash

# Pod 삭제
kubectl delete pod nginx-pod
```

---

## 2. Deployment (디플로이먼트) 🚀

### Deployment란?
Deployment는 Pod의 **상위 관리자** 역할을 하는 리소스입니다.

**주요 기능:**
- **Pod 복제본 관리**: 원하는 수만큼 Pod 유지
- **롤링 업데이트**: 무중단 업데이트
- **롤백**: 이전 버전으로 되돌리기
- **자동 복구**: 실패한 Pod 자동 재생성

### Deployment 생성 방법

#### 1) 명령어로 생성
```bash
# 기본 Deployment 생성
kubectl create deployment nginx-deployment --image=nginx

# 복제본 개수 지정
kubectl create deployment nginx-deployment --image=nginx --replicas=3

# 스케일링
kubectl scale deployment nginx-deployment --replicas=5
```

#### 2) YAML 매니페스트로 생성
```yaml
# nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

### Deployment 관리 명령어
```bash
# Deployment 조회
kubectl get deployments
kubectl get deploy  # 축약형

# 상세 정보
kubectl describe deployment nginx-deployment

# 롤링 업데이트
kubectl set image deployment/nginx-deployment nginx=nginx:1.22

# 롤아웃 상태 확인
kubectl rollout status deployment/nginx-deployment

# 롤아웃 히스토리
kubectl rollout history deployment/nginx-deployment

# 롤백
kubectl rollout undo deployment/nginx-deployment
```

---

## 3. Service (서비스) 🌐

### Service란?
Service는 Pod에 **안정적인 네트워크 엔드포인트**를 제공하는 리소스입니다.

**필요한 이유:**
- Pod IP는 재시작 시 변경됨
- 여러 Pod 간 로드 밸런싱 필요
- 외부에서 Pod 그룹에 접근할 방법 필요

### Service 타입

#### 1) ClusterIP (기본값)
```yaml
# nginx-service-clusterip.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

#### 2) NodePort
```yaml
# nginx-service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080  # 30000-32767 범위
```

#### 3) LoadBalancer
```yaml
# nginx-service-lb.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-lb
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

### Service 생성 및 관리
```bash
# 명령어로 Service 생성
kubectl expose deployment nginx-deployment --type=ClusterIP --port=80

# Service 조회
kubectl get services
kubectl get svc  # 축약형

# Service 상세 정보
kubectl describe service nginx-service

# 엔드포인트 확인
kubectl get endpoints nginx-service
```

---

## 4. 리소스 간 관계 🔗

```
┌─────────────────┐
│   Service       │  ← 외부 접근 제공
│                 │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Deployment    │  ← Pod 관리 및 복제
│                 │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Pod           │  ← 실제 컨테이너 실행
│                 │
└─────────────────┘
```

### 완전한 애플리케이션 예시
```yaml
# complete-nginx-app.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

---

## 5. 실습 시나리오 🛠️

### 시나리오 1: 웹 애플리케이션 배포
```bash
# 1. Deployment 생성
kubectl create deployment web-app --image=nginx --replicas=2

# 2. Service 노출
kubectl expose deployment web-app --type=NodePort --port=80

# 3. 상태 확인
kubectl get all

# 4. 스케일링
kubectl scale deployment web-app --replicas=4

# 5. 업데이트
kubectl set image deployment/web-app nginx=nginx:1.22
```

### 시나리오 2: 디버깅 실습
```bash
# 1. 문제 있는 Pod 생성
kubectl run debug-pod --image=nginx:invalid-tag

# 2. 상태 확인
kubectl get pods
kubectl describe pod debug-pod

# 3. 로그 확인
kubectl logs debug-pod

# 4. 이미지 수정
kubectl delete pod debug-pod
kubectl run debug-pod --image=nginx:1.21
```

---

## 6. 트러블슈팅 가이드 🔧

### 자주 발생하는 문제들

#### Pod가 Pending 상태
```bash
# 원인 확인
kubectl describe pod <pod-name>

# 일반적 원인:
# - 리소스 부족 (CPU/Memory)
# - 이미지 풀 실패
# - 스케줄링 제약
```

#### Pod가 CrashLoopBackOff
```bash
# 로그 확인
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# 일반적 원인:
# - 애플리케이션 오류
# - 잘못된 설정
# - 리소스 제한 초과
```

#### Service 연결 불가
```bash
# 엔드포인트 확인
kubectl get endpoints <service-name>

# 라벨 확인
kubectl get pods --show-labels
kubectl describe service <service-name>
```

---

## 7. 모범 사례 ✅

### 1. 라벨링 전략
```yaml
metadata:
  labels:
    app: nginx
    version: v1.21
    environment: production
    tier: frontend
```

### 2. 리소스 제한 설정
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

### 3. Health Check 설정
```yaml
containers:
- name: nginx
  image: nginx:1.21
  livenessProbe:
    httpGet:
      path: /
      port: 80
    initialDelaySeconds: 30
    periodSeconds: 10
  readinessProbe:
    httpGet:
      path: /
      port: 80
    initialDelaySeconds: 5
    periodSeconds: 5
```

---

## 8. CKA/CKAD 시험 팁 📝

### 빠른 리소스 생성 명령어
```bash
# Pod
kubectl run nginx --image=nginx --restart=Never

# Deployment
kubectl create deployment nginx --image=nginx --replicas=3

# Service
kubectl expose deployment nginx --port=80 --type=ClusterIP

# 모든 리소스 한 번에 조회
kubectl get all
```

### 매니페스트 생성 팁
```bash
# YAML 템플릿 생성 (실행하지 않음)
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > service.yaml
```

### 시간 절약 별칭
```bash
alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply -f'
```

---

## 📚 학습 정리

### 핵심 개념 복습
1. **Pod**: 가장 작은 배포 단위, 컨테이너 그룹
2. **Deployment**: Pod 관리자, 복제본 관리 및 업데이트
3. **Service**: 네트워크 엔드포인트, 로드 밸런싱

### 다음 학습 계획
- 6일차: 로컬 클러스터 실습 (minikube/kind)
- 2주차: ConfigMap, Secret, ServiceAccount 학습

### 추가 학습 자료
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)
- [Pod 생명주기](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Deployment 가이드](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Service 가이드](https://kubernetes.io/docs/concepts/services-networking/service/)