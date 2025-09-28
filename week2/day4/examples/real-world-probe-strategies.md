# 실제 운영에서의 Probe 전략

## 🏢 기업 환경에서의 Probe 설정 패턴

### 1. 마이크로서비스 아키텍처에서의 Probe 전략

#### API Gateway 서비스
```yaml
# Kong/Nginx Ingress Controller
apiVersion: v1
kind: Pod
metadata:
  name: api-gateway
spec:
  containers:
  - name: kong
    image: kong:3.0
    ports:
    - containerPort: 8000  # Proxy
    - containerPort: 8001  # Admin API
    - containerPort: 8444  # SSL Proxy
    
    startupProbe:
      httpGet:
        path: /status
        port: 8001
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 30  # Kong 초기화는 시간이 오래 걸림
    
    readinessProbe:
      httpGet:
        path: /status/ready
        port: 8001
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3
    
    livenessProbe:
      httpGet:
        path: /status
        port: 8001
      initialDelaySeconds: 60
      periodSeconds: 30
      failureThreshold: 3
```

#### 백엔드 API 서비스
```yaml
# Spring Boot 애플리케이션
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-api
        image: user-service:v1.2.3
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "production"
        
        # Spring Boot Actuator 엔드포인트 활용
        startupProbe:
          httpGet:
            path: /actuator/health/startup
            port: 8080
          initialDelaySeconds: 45  # Spring 초기화 시간
          periodSeconds: 10
          failureThreshold: 30
        
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8080
            httpHeaders:
            - name: Accept
              value: application/json
          initialDelaySeconds: 20
          periodSeconds: 15
          timeoutSeconds: 10
          failureThreshold: 3
        
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 60
          timeoutSeconds: 15
          failureThreshold: 3
        
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

#### 데이터베이스 서비스
```yaml
# PostgreSQL with custom health checks
apiVersion: v1
kind: Pod
metadata:
  name: postgres-primary
spec:
  containers:
  - name: postgres
    image: postgres:14
    env:
    - name: POSTGRES_DB
      value: production_db
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
          name: postgres-secret
          key: username
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgres-secret
          key: password
    
    startupProbe:
      exec:
        command:
        - /bin/sh
        - -c
        - |
          # PostgreSQL이 시작되고 연결을 수락하는지 확인
          pg_isready -h localhost -p 5432 -U $POSTGRES_USER &&
          # 기본 테이블이 생성되었는지 확인
          psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 20
      failureThreshold: 30
    
    readinessProbe:
      exec:
        command:
        - /bin/sh
        - -c
        - |
          # 연결 가능 여부 확인
          pg_isready -h localhost -p 5432 -U $POSTGRES_USER &&
          # 활성 연결 수 확인 (최대 연결의 80% 미만)
          [ $(psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';" 2>/dev/null | xargs) -lt 80 ] &&
          # 복제 지연 확인 (슬레이브가 있는 경우)
          [ $(psql -h localhost -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()));" 2>/dev/null | xargs | cut -d. -f1) -lt 60 ]
      initialDelaySeconds: 45
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 3
    
    livenessProbe:
      exec:
        command:
        - pg_isready
        - -h
        - localhost
        - -p
        - "5432"
        - -U
        - postgres
      initialDelaySeconds: 60
      periodSeconds: 60
      timeoutSeconds: 10
      failureThreshold: 3
```

### 2. 환경별 Probe 설정 차별화

#### 개발 환경 (빠른 피드백)
```yaml
# development/kustomization.yaml
patchesStrategicMerge:
- probe-dev-patch.yaml

---
# probe-dev-patch.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    startupProbe:
      initialDelaySeconds: 10
      periodSeconds: 5
      failureThreshold: 10  # 빠른 실패
    
    readinessProbe:
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 2
    
    livenessProbe:
      initialDelaySeconds: 30
      periodSeconds: 15
      timeoutSeconds: 5
      failureThreshold: 2
```

#### 운영 환경 (안정성 중심)
```yaml
# production/kustomization.yaml
patchesStrategicMerge:
- probe-prod-patch.yaml

---
# probe-prod-patch.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    startupProbe:
      initialDelaySeconds: 60
      periodSeconds: 10
      failureThreshold: 60  # 충분한 시간 확보
    
    readinessProbe:
      initialDelaySeconds: 30
      periodSeconds: 15
      timeoutSeconds: 10
      failureThreshold: 5   # 여유있는 설정
    
    livenessProbe:
      initialDelaySeconds: 120
      periodSeconds: 60     # 부하 최소화
      timeoutSeconds: 15
      failureThreshold: 5
```

### 3. 부하 테스트를 고려한 Probe 설정

#### 고부하 상황 대응
```yaml
# 트래픽이 많은 서비스
apiVersion: v1
kind: Pod
metadata:
  name: high-traffic-service
spec:
  containers:
  - name: api
    image: high-traffic-api:latest
    
    # 부하 중에도 안정적인 Probe
    readinessProbe:
      httpGet:
        path: /health/ready
        port: 8080
        httpHeaders:
        - name: X-Health-Check
          value: "k8s-readiness"
      initialDelaySeconds: 30
      periodSeconds: 20      # 부하를 줄이기 위해 긴 주기
      timeoutSeconds: 15     # 부하 중 응답 지연 고려
      successThreshold: 1
      failureThreshold: 5    # 일시적 부하 스파이크 허용
    
    livenessProbe:
      httpGet:
        path: /health/live
        port: 8080
      initialDelaySeconds: 60
      periodSeconds: 120     # 매우 긴 주기로 부하 최소화
      timeoutSeconds: 20
      failureThreshold: 3
    
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
```

### 4. 외부 의존성을 고려한 Probe 전략

#### 외부 API 의존성이 있는 서비스
```yaml
# 외부 서비스에 의존하는 애플리케이션
apiVersion: v1
kind: Pod
metadata:
  name: payment-service
spec:
  containers:
  - name: payment-api
    image: payment-service:v2.1.0
    
    # Startup: 필수 의존성만 확인
    startupProbe:
      httpGet:
        path: /health/startup  # DB 연결만 확인
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      failureThreshold: 30
    
    # Readiness: 외부 의존성 포함하여 확인
    readinessProbe:
      httpGet:
        path: /health/ready    # 외부 API, 큐 시스템 등 모두 확인
        port: 8080
      initialDelaySeconds: 20
      periodSeconds: 30        # 외부 API 호출로 인한 지연 고려
      timeoutSeconds: 25       # 외부 API 응답 시간 고려
      failureThreshold: 3
    
    # Liveness: 외부 의존성 제외하고 확인
    livenessProbe:
      httpGet:
        path: /health/live     # 내부 상태만 확인 (외부 API 제외)
        port: 8080
      initialDelaySeconds: 60
      periodSeconds: 60
      timeoutSeconds: 10
      failureThreshold: 3
```

### 5. 모니터링 및 알림 연동

#### Prometheus 메트릭 연동
```yaml
# 모니터링 메트릭을 노출하는 서비스
apiVersion: v1
kind: Pod
metadata:
  name: monitored-service
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9090"
    prometheus.io/path: "/metrics"
spec:
  containers:
  - name: app
    image: monitored-app:latest
    ports:
    - containerPort: 8080  # 애플리케이션 포트
    - containerPort: 9090  # 메트릭 포트
    
    # 메트릭 엔드포인트를 활용한 Probe
    readinessProbe:
      httpGet:
        path: /health/ready
        port: 8080
      initialDelaySeconds: 20
      periodSeconds: 15
      failureThreshold: 3
    
    livenessProbe:
      httpGet:
        path: /health/live
        port: 8080
      initialDelaySeconds: 60
      periodSeconds: 60
      failureThreshold: 3
  
  # 사이드카 패턴으로 메트릭 수집
  - name: metrics-exporter
    image: prometheus/node-exporter:latest
    ports:
    - containerPort: 9100
```

### 6. 실무 Probe 헬스체크 엔드포인트 구현 예시

#### Spring Boot Actuator 커스터마이징
```java
// CustomHealthIndicator.java
@Component
public class CustomHealthIndicator implements HealthIndicator {
    
    @Autowired
    private DatabaseService databaseService;
    
    @Autowired
    private ExternalApiService externalApiService;
    
    @Override
    public Health health() {
        // Liveness 체크 (기본)
        if (isBasicHealthy()) {
            return Health.up()
                .withDetail("status", "Application is running")
                .build();
        }
        return Health.down()
            .withDetail("status", "Application has critical issues")
            .build();
    }
    
    // 별도의 readiness 엔드포인트
    @GetMapping("/health/ready")
    public ResponseEntity<Map<String, Object>> readinessCheck() {
        Map<String, Object> status = new HashMap<>();
        
        // 데이터베이스 연결 확인
        boolean dbHealthy = databaseService.isHealthy();
        status.put("database", dbHealthy ? "UP" : "DOWN");
        
        // 외부 API 연결 확인
        boolean apiHealthy = externalApiService.isHealthy();
        status.put("external_api", apiHealthy ? "UP" : "DOWN");
        
        // 캐시 상태 확인
        boolean cacheHealthy = checkCacheHealth();
        status.put("cache", cacheHealthy ? "UP" : "DOWN");
        
        boolean overall = dbHealthy && apiHealthy && cacheHealthy;
        status.put("overall", overall ? "READY" : "NOT_READY");
        
        return ResponseEntity.status(overall ? 200 : 503).body(status);
    }
    
    // Startup 전용 엔드포인트
    @GetMapping("/health/startup")
    public ResponseEntity<Map<String, Object>> startupCheck() {
        Map<String, Object> status = new HashMap<>();
        
        // 필수 초기화만 확인
        boolean dbInitialized = databaseService.isInitialized();
        boolean configLoaded = isConfigurationLoaded();
        
        status.put("database_initialized", dbInitialized);
        status.put("configuration_loaded", configLoaded);
        
        boolean ready = dbInitialized && configLoaded;
        status.put("startup_complete", ready);
        
        return ResponseEntity.status(ready ? 200 : 503).body(status);
    }
}
```

#### Node.js Express 구현
```javascript
// health.js
const express = require('express');
const router = express.Router();

// Liveness probe - 기본 생존 확인
router.get('/live', (req, res) => {
  // 간단한 생존 확인
  const memoryUsage = process.memoryUsage();
  const uptime = process.uptime();
  
  if (memoryUsage.heapUsed / memoryUsage.heapTotal > 0.95) {
    return res.status(503).json({
      status: 'DOWN',
      reason: 'High memory usage',
      memory: memoryUsage
    });
  }
  
  res.json({
    status: 'UP',
    uptime: uptime,
    memory: memoryUsage
  });
});

// Readiness probe - 서비스 준비 상태
router.get('/ready', async (req, res) => {
  try {
    // 데이터베이스 연결 확인
    await checkDatabase();
    
    // 외부 서비스 확인
    await checkExternalServices();
    
    // 큐 시스템 확인
    await checkMessageQueue();
    
    res.json({
      status: 'READY',
      checks: {
        database: 'UP',
        external_services: 'UP',
        message_queue: 'UP'
      }
    });
  } catch (error) {
    res.status(503).json({
      status: 'NOT_READY',
      error: error.message
    });
  }
});

// Startup probe - 초기화 완료 확인
router.get('/startup', async (req, res) => {
  try {
    // 기본 초기화만 확인
    await checkBasicInitialization();
    
    res.json({
      status: 'STARTED',
      initialized_at: global.initializationTime
    });
  } catch (error) {
    res.status(503).json({
      status: 'STARTING',
      error: error.message
    });
  }
});

module.exports = router;
```

### 7. CI/CD 파이프라인에서의 Probe 테스트

#### GitLab CI 예시
```yaml
# .gitlab-ci.yml
test-probes:
  stage: test
  script:
    # 컨테이너 시작
    - docker run -d --name test-app -p 8080:8080 $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - sleep 30  # Startup 대기
    
    # Startup probe 테스트
    - |
      for i in {1..30}; do
        if curl -f http://localhost:8080/health/startup; then
          echo "Startup probe passed"
          break
        fi
        sleep 5
      done
    
    # Readiness probe 테스트
    - curl -f http://localhost:8080/health/ready
    
    # Liveness probe 테스트
    - curl -f http://localhost:8080/health/live
    
    # 부하 테스트 중 probe 안정성 확인
    - ab -n 1000 -c 10 http://localhost:8080/api/test &
    - sleep 5
    - curl -f http://localhost:8080/health/live  # 부하 중에도 정상 응답 확인
    
  after_script:
    - docker stop test-app
    - docker rm test-app
```

### 8. 트러블슈팅 자동화

#### Probe 실패 자동 복구 스크립트
```bash
#!/bin/bash
# probe-recovery.sh

NAMESPACE=${1:-default}
POD_NAME=${2}

if [ -z "$POD_NAME" ]; then
    echo "Usage: $0 [namespace] <pod-name>"
    exit 1
fi

echo "=== Probe 상태 자동 진단 ==="

# 1. Pod 상태 확인
echo "1. Pod 현재 상태:"
kubectl get pod $POD_NAME -n $NAMESPACE -o wide

# 2. Probe 이벤트 확인
echo "2. Probe 관련 이벤트:"
kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$POD_NAME | grep -i probe

# 3. 자동 복구 시도
echo "3. 자동 복구 시도..."

# Readiness probe 실패 시 - 수동 헬스체크
if kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q "False"; then
    echo "Readiness probe 실패 감지. 수동 헬스체크 실행..."
    kubectl exec $POD_NAME -n $NAMESPACE -- curl -f http://localhost:8080/health/ready || echo "수동 헬스체크도 실패"
fi

# Liveness probe로 인한 재시작이 많은 경우
RESTART_COUNT=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.containerStatuses[0].restartCount}')
if [ "$RESTART_COUNT" -gt 5 ]; then
    echo "과도한 재시작 감지 ($RESTART_COUNT 회). Liveness probe 설정 확인 필요."
    kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[0].livenessProbe}' | jq
fi

echo "=== 진단 완료 ==="
```

이러한 실무 패턴들을 통해 안정적이고 효율적인 Kubernetes Probe 전략을 구축할 수 있습니다.


