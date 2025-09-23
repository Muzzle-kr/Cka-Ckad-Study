# Probe 모니터링 및 트러블슈팅 가이드

## 🔍 Probe 상태 확인 명령어

### 1. 기본 상태 확인
```bash
# 모든 Pod 상태 개요
kubectl get pods -o wide

# 특정 네임스페이스의 Pod 상태
kubectl get pods -n <namespace> -o wide

# Pod의 상세 정보 (Probe 포함)
kubectl describe pod <pod-name>

# Pod의 현재 상태 조건들
kubectl get pod <pod-name> -o jsonpath='{.status.conditions[*].type}{"\n"}{.status.conditions[*].status}'
```

### 2. Probe 설정 추출
```bash
# Readiness Probe 설정 확인
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].readinessProbe}' | jq

# Liveness Probe 설정 확인  
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].livenessProbe}' | jq

# Startup Probe 설정 확인
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].startupProbe}' | jq

# 모든 컨테이너의 Probe 설정
kubectl get pod <pod-name> -o jsonpath='{range .spec.containers[*]}{.name}{": "}{.readinessProbe.httpGet.path}{"\n"}{end}'
```

### 3. 이벤트 및 로그 분석
```bash
# Pod 관련 모든 이벤트
kubectl get events --field-selector involvedObject.name=<pod-name> --sort-by='.lastTimestamp'

# Probe 관련 이벤트만 필터링
kubectl get events --all-namespaces | grep -E "(Liveness|Readiness|Startup)"

# Pod 로그 확인
kubectl logs <pod-name> --tail=50 --timestamps

# 이전 컨테이너 로그 (재시작된 경우)
kubectl logs <pod-name> --previous
```

## 🚨 일반적인 Probe 문제 패턴

### 1. Startup Probe 시간 부족
**증상**: Pod가 계속 재시작됨 (CrashLoopBackOff)

```bash
# 문제 확인
kubectl describe pod <pod-name>
# Events 섹션에서 "Startup probe failed" 메시지 확인

# 해결방법
# failureThreshold 증가 또는 periodSeconds 조정
startupProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 30  # 5분 총 대기시간 (30 * 10초)
```

### 2. Readiness Probe 과민 반응
**증상**: Pod가 Ready 상태와 NotReady 상태를 반복

```bash
# 문제 확인
kubectl get pods -w  # 상태 변화 실시간 관찰
kubectl describe pod <pod-name> | grep -A 5 "Readiness"

# 해결방법
# 더 관대한 설정 적용
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 10    # 더 긴 타임아웃
  failureThreshold: 5   # 더 많은 재시도 허용
```

### 3. Liveness Probe 너무 공격적
**증상**: 정상 상황에서도 Pod가 가끔 재시작됨

```bash
# 문제 확인
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[0].restartCount}'
kubectl describe pod <pod-name> | grep -A 10 "Liveness"

# 해결방법
# 더 완화된 설정
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 60   # 충분한 초기 대기
  periodSeconds: 60         # 자주 확인하지 않음
  timeoutSeconds: 15        # 네트워크 지연 고려
  failureThreshold: 5       # 여러 번 실패 허용
```

## 📊 Probe 메트릭 및 모니터링

### 1. Prometheus를 활용한 모니터링
```yaml
# 주요 Probe 관련 메트릭
# Pod 재시작 횟수
kube_pod_container_status_restarts_total

# Pod 준비 상태
kube_pod_status_ready

# Probe 실패 이벤트
increase(kube_pod_container_status_restarts_total[5m]) > 0
```

### 2. 커스텀 대시보드 쿼리
```promql
# 재시작이 많은 Pod 찾기
topk(10, rate(kube_pod_container_status_restarts_total[1h]))

# Ready 상태가 아닌 Pod
kube_pod_status_ready{condition="false"}

# Probe 실패로 인한 재시작 패턴
increase(kube_pod_container_status_restarts_total[15m]) > 2
```

## 🔧 트러블슈팅 시나리오별 대응

### 시나리오 1: Pod가 시작되지 않음
```bash
# 1단계: 현재 상태 확인
kubectl get pod <pod-name> -o wide
kubectl describe pod <pod-name>

# 2단계: Startup Probe 설정 확인  
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[0].startupProbe}'

# 3단계: 로그 분석
kubectl logs <pod-name>

# 4단계: 수동 헬스체크 테스트
kubectl exec <pod-name> -- curl -f http://localhost:8080/health || echo "Probe would fail"

# 5단계: 임시로 Probe 비활성화하여 디버깅
# (YAML에서 probe 섹션 주석 처리 후 재배포)
```

### 시나리오 2: Service에서 트래픽을 받지 못함
```bash
# 1단계: Service와 Endpoints 확인
kubectl get svc <service-name>
kubectl get endpoints <service-name>

# 2단계: Pod의 Ready 상태 확인
kubectl get pods -l <label-selector> -o wide

# 3단계: Readiness Probe 테스트
kubectl port-forward <pod-name> 8080:8080 &
curl http://localhost:8080/health/ready

# 4단계: 네트워크 연결 테스트
kubectl exec <pod-name> -- nc -zv <service-name> <port>
```

### 시나리오 3: 간헐적 재시작 문제
```bash
# 1단계: 재시작 패턴 분석
kubectl get pod <pod-name> -o jsonpath='{.status.containerStatuses[0].restartCount}'
kubectl get events --field-selector involvedObject.name=<pod-name> | grep -i restart

# 2단계: 리소스 사용량 확인
kubectl top pod <pod-name>
kubectl describe node <node-name>

# 3단계: Liveness Probe 응답시간 측정
kubectl exec <pod-name> -- time curl -f http://localhost:8080/health/live

# 4단계: 부하 테스트 중 Probe 동작 확인
# 부하를 가하면서 Probe 실패 여부 모니터링
```

## 🎯 실무 Probe 설정 패턴

### 마이크로서비스 표준 패턴
```yaml
# 권장하는 3-tier 헬스체크 구조

# 1. Startup: 의존성 초기화 확인
startupProbe:
  httpGet:
    path: /health/startup  # DB 연결, 설정 로드 등
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 30     # 5분 총 시간

# 2. Readiness: 서비스 준비 상태
readinessProbe:
  httpGet:
    path: /health/ready   # 캐시 준비, 외부 API 연결 등
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 15
  timeoutSeconds: 10
  failureThreshold: 3

# 3. Liveness: 기본 생존 확인  
livenessProbe:
  httpGet:
    path: /health/live    # 간단한 응답만
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 60       # 부하 최소화
  timeoutSeconds: 15
  failureThreshold: 3
```

### 데이터베이스용 Probe 패턴
```yaml
# PostgreSQL 예시
startupProbe:
  exec:
    command: ["pg_isready", "-h", "localhost", "-p", "5432"]
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 30

readinessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "pg_isready && psql -c 'SELECT 1' > /dev/null"
  periodSeconds: 20
  timeoutSeconds: 15

livenessProbe:
  tcpSocket:
    port: 5432
  periodSeconds: 60
  timeoutSeconds: 10
```

## 📈 성능 최적화 팁

### 1. Probe 오버헤드 최소화
- Liveness Probe는 가장 긴 주기 (60초+)로 설정
- 간단한 TCP 또는 경량 HTTP 엔드포인트 사용
- 외부 의존성 체크는 Readiness에만 포함

### 2. 효율적인 헬스체크 엔드포인트
```go
// 예시: 경량 헬스체크 엔드포인트 (Go)
func healthHandler(w http.ResponseWriter, r *http.Request) {
    // Liveness: 최소한의 확인만
    if r.URL.Path == "/health/live" {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("OK"))
        return
    }
    
    // Readiness: 상세한 상태 확인
    if r.URL.Path == "/health/ready" {
        // DB 연결, 캐시 상태 등 확인
        if !checkDependencies() {
            w.WriteHeader(http.StatusServiceUnavailable)
            return
        }
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("Ready"))
    }
}
```

### 3. 환경별 Probe 설정 차별화
```yaml
# 개발환경: 빠른 피드백
periodSeconds: 5
timeoutSeconds: 3
failureThreshold: 2

# 운영환경: 안정성 중심  
periodSeconds: 30
timeoutSeconds: 15
failureThreshold: 5
```