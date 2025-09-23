# 2주차 4일차: Kubernetes Probe 설정

## 🎯 학습 목표
- Liveness, Readiness, Startup Probe의 개념과 차이점 이해
- 다양한 Probe 타입(HTTP, TCP, Command) 설정 방법 학습
- Probe 설정 최적화를 통한 애플리케이션 가용성 향상
- 실제 시나리오에서 Probe 문제 해결 능력 습득

## 📚 이론 학습

### Kubernetes Probe란?
Kubernetes는 Pod 내 컨테이너의 상태를 모니터링하기 위해 3가지 유형의 Probe를 제공합니다.

### 1. Liveness Probe (생존성 프로브)
- **목적**: 컨테이너가 정상적으로 실행 중인지 확인
- **실패 시 동작**: 컨테이너를 재시작
- **사용 케이스**: 데드락, 무한 루프 등으로 응답하지 않는 상황 감지

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

### 2. Readiness Probe (준비성 프로브)
- **목적**: 컨테이너가 트래픽을 받을 준비가 되었는지 확인
- **실패 시 동작**: 서비스 엔드포인트에서 제거 (재시작하지 않음)
- **사용 케이스**: 초기화 중이거나 임시적으로 요청을 처리할 수 없는 상황

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  successThreshold: 1
  failureThreshold: 3
```

### 3. Startup Probe (시작 프로브)
- **목적**: 컨테이너가 시작되었는지 확인
- **실패 시 동작**: 컨테이너를 재시작
- **사용 케이스**: 시작 시간이 오래 걸리는 애플리케이션
- **특징**: 성공 시까지 다른 Probe들이 비활성화됨

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 30  # 5분 (10초 * 30회)
```

### Probe 타입별 설정 방법

#### 1. HTTP GET Probe
가장 일반적으로 사용되는 방식으로, HTTP 요청으로 상태를 확인합니다.

```yaml
httpGet:
  path: /health
  port: 8080
  host: 192.168.1.1    # 선택사항, 기본값은 Pod IP
  scheme: HTTP         # HTTP 또는 HTTPS
  httpHeaders:         # 선택사항
  - name: Custom-Header
    value: Awesome
```

#### 2. TCP Socket Probe
특정 포트에 TCP 연결이 가능한지 확인합니다.

```yaml
tcpSocket:
  port: 8080
  host: 192.168.1.1    # 선택사항
```

#### 3. Exec Command Probe
컨테이너 내에서 명령어를 실행하고 종료 코드로 판단합니다.

```yaml
exec:
  command:
  - cat
  - /tmp/healthy
```

### Probe 설정 매개변수

| 매개변수 | 설명 | 기본값 |
|---------|------|--------|
| `initialDelaySeconds` | 첫 번째 프로브 시작 전 대기 시간 | 0초 |
| `periodSeconds` | 프로브 실행 간격 | 10초 |
| `timeoutSeconds` | 프로브 타임아웃 | 1초 |
| `successThreshold` | 성공으로 간주할 연속 성공 횟수 | 1회 |
| `failureThreshold` | 실패로 간주할 연속 실패 횟수 | 3회 |

## 🛠️ 실습

### 실습 1: HTTP Liveness Probe 설정

1. **웹 애플리케이션 배포**
```bash
kubectl apply -f examples/webapp-with-liveness.yaml
```

2. **Probe 상태 확인**
```bash
kubectl describe pod webapp-liveness
kubectl get events --sort-by=.metadata.creationTimestamp
```

3. **의도적으로 실패 상황 만들기**
```bash
kubectl exec -it webapp-liveness -- rm /tmp/healthy
```

### 실습 2: Readiness Probe와 Service 연동

1. **Readiness Probe가 있는 애플리케이션 배포**
```bash
kubectl apply -f examples/webapp-with-readiness.yaml
kubectl apply -f examples/webapp-service.yaml
```

2. **서비스 엔드포인트 확인**
```bash
kubectl get endpoints webapp-service
```

3. **Readiness 상태 변경 테스트**
```bash
kubectl exec -it webapp-readiness -- touch /tmp/not-ready
kubectl get endpoints webapp-service  # 엔드포인트에서 제거됨
```

### 실습 3: 복합 Probe 설정

모든 Probe 타입을 함께 사용하는 복잡한 애플리케이션을 구성해보겠습니다.

```bash
kubectl apply -f examples/complex-probe-app.yaml
kubectl describe pod complex-app
```

## 📊 모니터링 및 트러블슈팅

### Probe 실패 원인 분석

1. **이벤트 확인**
```bash
kubectl get events --field-selector reason=Unhealthy
kubectl describe pod <pod-name>
```

2. **로그 분석**
```bash
kubectl logs <pod-name> --previous  # 재시작 전 로그
kubectl logs <pod-name> -f          # 실시간 로그
```

3. **Probe 설정 확인**
```bash
kubectl get pod <pod-name> -o yaml | grep -A 10 -B 2 probe
```

### 일반적인 문제와 해결책

| 문제 | 원인 | 해결책 |
|------|------|--------|
| 너무 빠른 재시작 | `initialDelaySeconds` 너무 짧음 | 시작 시간을 충분히 설정 |
| 간헐적 실패 | `failureThreshold` 너무 낮음 | 임계값 증가 |
| 느린 응답 | `timeoutSeconds` 너무 짧음 | 타임아웃 증가 |
| CPU 과부하 | `periodSeconds` 너무 짧음 | 체크 간격 증가 |

## 🎯 실전 시나리오

### 시나리오 1: 데이터베이스 애플리케이션
데이터베이스 초기화에 2분이 걸리는 애플리케이션의 Probe 설정

```yaml
spec:
  containers:
  - name: database-app
    image: my-db-app:latest
    startupProbe:
      tcpSocket:
        port: 5432
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 12  # 2분 대기
    livenessProbe:
      tcpSocket:
        port: 5432
      periodSeconds: 30
      timeoutSeconds: 5
    readinessProbe:
      exec:
        command:
        - pg_isready
        - -h
        - localhost
        - -U
        - myuser
      initialDelaySeconds: 5
      periodSeconds: 5
```

### 시나리오 2: 마이크로서비스 의존성
다른 서비스에 의존하는 마이크로서비스의 Probe 설정

```yaml
readinessProbe:
  httpGet:
    path: /health/dependencies
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 15
  timeoutSeconds: 10
  failureThreshold: 2
```

## 🔧 모범 사례

### 1. Probe 설정 가이드라인
- **Startup Probe**: 느린 시작을 위해 `failureThreshold * periodSeconds`로 충분한 시간 확보
- **Liveness Probe**: 보수적으로 설정, 불필요한 재시작 방지
- **Readiness Probe**: 민감하게 설정, 빠른 트래픽 차단

### 2. 성능 고려사항
```yaml
# 권장 설정 예시
startupProbe:
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 30
livenessProbe:
  initialDelaySeconds: 60
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
readinessProbe:
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

### 3. 보안 고려사항
- Health check 엔드포인트는 인증 없이 접근 가능하게 설정
- 민감한 정보는 health check 응답에 포함하지 않음
- HTTPS 사용 시 적절한 인증서 설정

## 📝 핵심 명령어 요약

```bash
# Probe 관련 정보 확인
kubectl describe pod <pod-name>
kubectl get events --field-selector reason=Unhealthy
kubectl logs <pod-name> --previous

# Probe 설정 확인
kubectl get pod <pod-name> -o yaml | grep -A 20 probe

# 실시간 모니터링
kubectl get pods -w
kubectl top pods

# 디버깅용 명령어
kubectl exec -it <pod-name> -- curl localhost:8080/health
kubectl port-forward <pod-name> 8080:8080
```

## 🎉 학습 완료 체크리스트

- [X] Liveness, Readiness, Startup Probe의 차이점 이해
- [X] HTTP, TCP, Exec 타입별 Probe 설정 방법 숙지
- [X] Probe 매개변수별 역할과 최적값 설정 능력
- [X] Probe 실패 시 트러블슈팅 방법 습득
- [X] 실제 애플리케이션에 맞는 Probe 전략 수립 능력

## 🔗 다음 학습
- **Day 5**: 고급 Pod 설정 (Resource Requests/Limits, QoS Classes)
- **추가 학습**: Monitoring과 Alerting 시스템 연동

---
**학습 시간**: 약 30분  
**난이도**: ⭐⭐⭐☆☆  
**실습 파일**: `week2/day4/examples/`