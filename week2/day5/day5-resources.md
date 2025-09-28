# Day 5: 고급 Pod 설정 - Resource Management & QoS

## 🎯 학습 목표
- Resource Requests와 Limits의 차이점과 설정 방법 이해
- QoS(Quality of Service) Classes와 우선순위 시스템 학습
- Node Selector, Affinity, Anti-Affinity를 통한 Pod 스케줄링 제어
- Taint와 Toleration을 활용한 노드 격리 구현

---

## 📚 핵심 개념

### 1. Resource Management 기초

#### Resource Requests vs Limits
- **Requests**: Pod가 보장받고 싶은 최소 리소스
- **Limits**: Pod가 사용할 수 있는 최대 리소스

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"  
    cpu: "500m"
```

#### CPU 리소스 단위
- **Core 단위**: 1 = 1 CPU 코어
- **Millicores**: 1000m = 1 코어
- **예시**: 250m = 0.25 코어, 500m = 0.5 코어

#### Memory 리소스 단위
- **Bytes**: Ki(1024), Mi(1024²), Gi(1024³)
- **Decimal**: K(1000), M(1000²), G(1000³)
- **예시**: 128Mi = 134,217,728 bytes

### 2. QoS Classes (Quality of Service)

#### Guaranteed
- **조건**: requests = limits (모든 컨테이너)
- **우선순위**: 가장 높음 (마지막에 제거)
- **사용 사례**: 중요한 프로덕션 워크로드

```yaml
resources:
  requests:
    memory: "200Mi"
    cpu: "700m"
  limits:
    memory: "200Mi"
    cpu: "700m"
```

#### Burstable
- **조건**: requests < limits 또는 일부만 설정
- **우선순위**: 중간
- **사용 사례**: 일반적인 애플리케이션

```yaml
resources:
  requests:
    memory: "100Mi"
    cpu: "100m"
  limits:
    memory: "200Mi"
    cpu: "500m"
```

#### BestEffort
- **조건**: requests, limits 모두 설정 안함
- **우선순위**: 가장 낮음 (먼저 제거)
- **사용 사례**: 중요하지 않은 백그라운드 작업

### 3. Pod 스케줄링 제어

#### Node Selector (간단한 노드 선택)
```yaml
spec:
  nodeSelector:
    disktype: ssd
    environment: production
```

#### Node Affinity (고급 노드 선택)
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/arch
            operator: In
            values:
            - amd64
            - arm64
```

#### Pod Affinity (Pod 간 관계 설정)
```yaml
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - database
        topologyKey: kubernetes.io/hostname
```

### 4. Taint와 Toleration

#### Taint (노드에 설정)
```bash
# 노드에 taint 추가
kubectl taint nodes node1 key=value:NoSchedule

# 노드에서 taint 제거
kubectl taint nodes node1 key=value:NoSchedule-
```

#### Toleration (Pod에 설정)
```yaml
spec:
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

---

## 🔧 실습 가이드

### 실습 1: Resource Requests/Limits 설정

#### Step 1: Guaranteed QoS Pod 생성
```bash
# Guaranteed QoS Pod 생성
kubectl apply -f examples/guaranteed-pod.yaml

# QoS 클래스 확인
kubectl describe pod guaranteed-pod | grep -A 5 "QoS Class"
```

#### Step 2: Burstable QoS Pod 생성
```bash
# Burstable QoS Pod 생성
kubectl apply -f examples/burstable-pod.yaml

# 리소스 사용량 모니터링
kubectl top pod burstable-pod
```

#### Step 3: 리소스 부족 상황 시뮬레이션
```bash
# 과도한 리소스 요청 Pod 생성
kubectl apply -f examples/resource-intensive-pod.yaml

# Pod 상태 확인 (Pending 상태일 것)
kubectl get pods
kubectl describe pod resource-intensive-pod
```

### 실습 2: Node Selector와 Affinity

#### Step 1: 노드에 레이블 추가
```bash
# 노드 목록 확인
kubectl get nodes

# 노드에 레이블 추가
kubectl label nodes <node-name> disktype=ssd
kubectl label nodes <node-name> environment=production
```

#### Step 2: Node Selector 테스트
```bash
# Node Selector Pod 생성
kubectl apply -f examples/node-selector-pod.yaml

# Pod가 올바른 노드에 스케줄되었는지 확인
kubectl get pod node-selector-pod -o wide
```

#### Step 3: Node Affinity 테스트
```bash
# Node Affinity Pod 생성
kubectl apply -f examples/node-affinity-pod.yaml

# 스케줄링 결과 확인
kubectl describe pod node-affinity-pod | grep "Node:"
```

### 실습 3: Taint와 Toleration

#### Step 1: 노드에 Taint 설정
```bash
# 노드에 taint 추가
kubectl taint nodes <node-name> special=true:NoSchedule

# taint 확인
kubectl describe node <node-name> | grep Taints
```

#### Step 2: Toleration 없는 Pod 테스트
```bash
# 일반 Pod 생성 (taint된 노드에 스케줄 불가)
kubectl apply -f examples/no-toleration-pod.yaml

# Pod 상태 확인 (Pending일 것)
kubectl get pods
kubectl describe pod no-toleration-pod
```

#### Step 3: Toleration 있는 Pod 테스트
```bash
# Toleration이 있는 Pod 생성
kubectl apply -f examples/toleration-pod.yaml

# 성공적으로 스케줄되었는지 확인
kubectl get pod toleration-pod -o wide
```

---

## 📊 모니터링 및 분석

### 리소스 사용량 확인
```bash
# 클러스터 전체 리소스 사용량
kubectl top nodes

# Pod별 리소스 사용량
kubectl top pods

# 특정 네임스페이스의 Pod 리소스 사용량
kubectl top pods -n kube-system
```

### QoS 클래스 분석
```bash
# 모든 Pod의 QoS 클래스 확인
kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass

# 특정 Pod의 상세 QoS 정보
kubectl describe pod <pod-name> | grep -A 10 "QoS Class"
```

### 스케줄링 이벤트 확인
```bash
# Pod 스케줄링 이벤트 확인
kubectl describe pod <pod-name> | grep -A 10 Events

# 클러스터 전체 이벤트 확인
kubectl get events --sort-by='.lastTimestamp'
```

---

## ⚠️ 주의사항과 베스트 프랙티스

### Resource 설정 가이드라인

#### 1. Requests 설정 원칙
- **실제 사용량 기준**: 애플리케이션의 평균 리소스 사용량
- **여유분 고려**: 평균 사용량의 110-120% 설정
- **모니터링 필수**: 실제 사용량을 지속적으로 모니터링

#### 2. Limits 설정 원칙
- **안전 마진**: Requests의 150-200% 수준
- **메모리 Limits**: OOMKilled 방지를 위해 충분한 여유
- **CPU Limits**: 너무 낮으면 throttling 발생

#### 3. QoS 선택 기준
```yaml
# Critical 워크로드 → Guaranteed
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "500m"

# 일반 워크로드 → Burstable  
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "1000m"

# 백그라운드 작업 → BestEffort
# (resources 설정 없음)
```

### 스케줄링 전략

#### 1. Node Selector vs Affinity
- **Node Selector**: 간단한 조건 (하나의 레이블)
- **Node Affinity**: 복잡한 조건 (여러 레이블, 연산자)

#### 2. Affinity 타입
- **RequiredDuringScheduling**: 반드시 조건을 만족해야 함
- **PreferredDuringScheduling**: 조건을 만족하면 좋지만 필수는 아님

#### 3. Taint/Toleration 사용 사례
- **전용 노드**: GPU 노드, 고성능 노드
- **유지보수**: 노드 비우기 전 새 Pod 스케줄링 방지
- **문제 노드**: 문제가 있는 노드 격리

---

## 🧪 실전 시나리오

### 시나리오 1: 마이크로서비스 리소스 최적화

#### 상황
- API 서버: 평균 CPU 200m, 메모리 300Mi 사용
- 트래픽 급증 시 CPU 500m, 메모리 500Mi까지 사용
- 가용성이 중요한 서비스

#### 해결책
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: optimized-api-server
spec:
  containers:
  - name: api-server
    image: api-server:latest
    resources:
      requests:
        memory: "350Mi"
        cpu: "250m"
      limits:
        memory: "600Mi"
        cpu: "600m"
```

### 시나리오 2: 데이터베이스 Pod 전용 노드 배치

#### 상황
- 데이터베이스는 SSD 스토리지가 있는 노드에만 배치
- 다른 애플리케이션과 분리 필요
- 고성능 보장 필요

#### 해결책
```bash
# 1. SSD 노드에 레이블 추가
kubectl label nodes ssd-node-1 storage=ssd
kubectl label nodes ssd-node-1 workload=database

# 2. SSD 노드에 taint 추가 (데이터베이스 전용)
kubectl taint nodes ssd-node-1 workload=database:NoSchedule

# 3. 데이터베이스 Pod 설정
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  nodeSelector:
    storage: ssd
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "database"
    effect: "NoSchedule"
  containers:
  - name: database
    image: postgres:13
    resources:
      requests:
        memory: "2Gi"
        cpu: "1000m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
```

### 시나리오 3: 배치 작업 스케줄링

#### 상황
- 야간 배치 작업: 리소스 집약적
- 평상시에는 다른 Pod에 리소스 양보
- 완료되면 자동 정리

#### 해결책
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-processing
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: workload-type
                operator: In
                values:
                - batch
      containers:
      - name: batch-processor
        image: batch-processor:latest
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
      restartPolicy: Never
```

---

## 📝 정리 및 다음 단계

### 오늘 학습한 내용
- ✅ Resource Requests/Limits 설정과 QoS Classes
- ✅ Node Selector와 Affinity를 통한 Pod 배치 제어
- ✅ Taint와 Toleration을 활용한 노드 격리
- ✅ 실제 시나리오별 최적화 전략

### 중요 포인트
1. **리소스 설정**: 모니터링을 기반으로 한 적절한 requests/limits
2. **QoS 이해**: 워크로드 중요도에 따른 QoS 클래스 선택
3. **스케줄링**: 비즈니스 요구사항에 맞는 Pod 배치 전략
4. **노드 관리**: Taint/Toleration을 통한 효율적인 리소스 활용

### 다음 학습 (Day 6)
- 전체 리소스를 활용한 통합 환경 구성
- 실전 애플리케이션 배포 및 운영
- 모니터링과 트러블슈팅 실습

---

## 🔗 참고 자료

### 공식 문서
- [Managing Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

### 모니터링 도구
- `kubectl top`: 기본 리소스 사용량 확인
- `kubectl describe`: 상세 정보 및 이벤트 확인
- Metrics Server: 클러스터 메트릭 수집

### 실무 팁
- Resource 설정은 점진적으로 조정
- 모니터링 데이터를 기반으로 한 의사결정
- 개발/스테이징/프로덕션 환경별 다른 설정