# Day 1: ConfigMap 기초

## 🎯 학습 목표 (25분)
ConfigMap의 개념을 이해하고 생성, 조회, 수정하는 방법을 익힙니다. Pod에서 환경변수와 볼륨으로 ConfigMap을 활용하는 실습을 진행합니다.

---

## 1️⃣ ConfigMap이란? (5분)

### 개념
**ConfigMap**은 Kubernetes에서 설정 데이터를 key-value 형태로 저장하는 리소스입니다.
- 애플리케이션 코드와 설정을 분리
- 민감하지 않은 설정 정보 저장 (민감한 정보는 Secret 사용)
- Pod에서 환경변수, 명령줄 인수, 볼륨 마운트로 활용 가능

### 사용 사례
```yaml
# 일반적인 설정 예시
- 데이터베이스 URL (비밀번호 제외)
- 애플리케이션 로그 레벨
- 기능 플래그 (feature flags)
- 설정 파일 내용
```

---

## 2️⃣ ConfigMap 생성 방법 (8분)

### 1. 명령어로 직접 생성
```bash
# 리터럴 값으로 생성
kubectl create configmap app-config \
  --from-literal=database_url=postgresql://db:5432/myapp \
  --from-literal=log_level=debug \
  --from-literal=max_connections=100

# 파일에서 생성
kubectl create configmap nginx-config --from-file=nginx.conf

# 디렉토리에서 생성 (모든 파일)
kubectl create configmap app-settings --from-file=./config/
```

### 2. YAML 매니페스트로 생성
```yaml
# configmap-example.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  # 단순 key-value
  database_url: "postgresql://db:5432/myapp"
  log_level: "debug"
  max_connections: "100"
  
  # 파일 내용 (멀티라인)
  application.properties: |
    server.port=8080
    spring.datasource.url=jdbc:postgresql://db:5432/myapp
    logging.level.root=DEBUG
  
  nginx.conf: |
    server {
        listen 80;
        server_name localhost;
        location / {
            proxy_pass http://backend:8080;
        }
    }
```

### 3. 실습 - ConfigMap 생성
```bash
# 1단계: 리터럴로 생성
kubectl create configmap web-config \
  --from-literal=app_name=my-web-app \
  --from-literal=version=v1.0.0 \
  --from-literal=port=8080

# 2단계: 설정 파일로 생성 (examples 폴더 활용)
kubectl create configmap nginx-config --from-file=examples/nginx.conf

# 3단계: YAML 매니페스트 적용
kubectl apply -f examples/app-configmap.yaml
```

---

## 3️⃣ ConfigMap 조회 및 관리 (5분)

### 조회 명령어
```bash
# 모든 ConfigMap 목록
kubectl get configmaps
kubectl get cm  # 축약형

# 특정 ConfigMap 상세 정보
kubectl describe configmap app-config

# ConfigMap의 데이터 내용 확인
kubectl get configmap app-config -o yaml
kubectl get configmap app-config -o json

# 특정 키의 값만 확인
kubectl get configmap app-config -o jsonpath='{.data.database_url}'
```

### 수정 및 삭제
```bash
# ConfigMap 수정 (대화형 편집기)
kubectl edit configmap app-config

# 새로운 키-값 추가
kubectl patch configmap app-config -p '{"data":{"new_key":"new_value"}}'

# ConfigMap 삭제
kubectl delete configmap app-config

# 특정 키 삭제 (patch 사용)
kubectl patch configmap app-config --type=json -p='[{"op": "remove", "path": "/data/old_key"}]'
```

---

## 4️⃣ Pod에서 ConfigMap 활용 (7분)

### 1. 환경변수로 사용
```yaml
# pod-with-configmap-env.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx:latest
    env:
    # 개별 키를 환경변수로
    - name: DATABASE_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: database_url
    # 모든 키를 환경변수로
    envFrom:
    - configMapRef:
        name: app-config
```

### 2. 볼륨으로 마운트
```yaml
# pod-with-configmap-volume.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf
    - name: app-config-volume
      mountPath: /app/config
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
  - name: app-config-volume
    configMap:
      name: app-config
```

### 3. 실습 - Pod에서 ConfigMap 사용
```bash
# 1단계: ConfigMap이 환경변수로 잘 설정되었는지 확인
kubectl exec app-pod -- env | grep -E "(DATABASE_URL|log_level)"

# 2단계: 볼륨으로 마운트된 파일 확인
kubectl exec nginx-pod -- cat /etc/nginx/nginx.conf
kubectl exec nginx-pod -- ls -la /app/config

# 3단계: ConfigMap 변경 후 Pod 내부 변화 확인 (볼륨 마운트는 자동 업데이트)
kubectl patch configmap app-config -p '{"data":{"new_setting":"updated_value"}}'
kubectl exec nginx-pod -- cat /app/config/new_setting
```

---

## 5️⃣ 실전 시나리오 및 팁

### CKA/CKAD 시험 팁
```bash
# 빠른 ConfigMap 생성 템플릿
kubectl create configmap my-config --from-literal=key1=value1 --dry-run=client -o yaml > configmap.yaml

# ConfigMap을 사용하는 Pod 빠른 생성
kubectl run test-pod --image=busybox --env="VAR1=value1" --dry-run=client -o yaml > pod.yaml
# 이후 ConfigMap 참조로 수정

# ConfigMap 변경사항 실시간 모니터링
kubectl get configmap app-config -w
```

### 주의사항
1. **크기 제한**: ConfigMap은 1MB 이하로 제한
2. **업데이트**: 환경변수는 Pod 재시작 필요, 볼륨 마운트는 자동 업데이트
3. **네임스페이스**: ConfigMap은 네임스페이스별로 관리됨
4. **보안**: 민감한 정보는 Secret 사용 권장

### 문제 해결
```bash
# ConfigMap이 Pod에 제대로 마운트되지 않을 때
kubectl describe pod <pod-name>  # Events 섹션 확인
kubectl logs <pod-name>          # 애플리케이션 로그 확인

# ConfigMap 키 이름 오타 확인
kubectl get configmap <name> -o yaml | grep -A 5 "data:"
```

---

## 📋 학습 정리

### 핵심 명령어
```bash
# ConfigMap 생성
kubectl create configmap <name> --from-literal=key=value
kubectl create configmap <name> --from-file=<file>
kubectl apply -f configmap.yaml

# ConfigMap 조회
kubectl get configmaps
kubectl describe configmap <name>
kubectl get configmap <name> -o yaml

# ConfigMap 수정/삭제
kubectl edit configmap <name>
kubectl delete configmap <name>

# Pod에서 ConfigMap 활용 확인
kubectl exec <pod> -- env | grep <key>
kubectl exec <pod> -- cat <mount-path>
```

### 다음 단계
- **Day 2**: Secret 관리 및 보안 설정
- **실습 포인트**: ConfigMap과 Secret의 차이점, 보안 고려사항

---

## 🔗 참고 자료
- [Kubernetes ConfigMap 공식 문서](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [ConfigMap 사용 패턴](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
