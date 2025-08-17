# Day 6: 로컬 클러스터 실습 (minikube/kind)

## 📚 학습 목표
- 로컬 Kubernetes 클러스터 설치 및 설정
- minikube와 kind의 차이점과 사용법 이해
- 실제 샘플 애플리케이션 배포 및 관리 실습
- 클러스터 관리 기본 명령어 숙달

---

## 1. 로컬 클러스터 도구 비교 🔍

### minikube vs kind vs Docker Desktop

| 특징 | minikube | kind | Docker Desktop |
|------|----------|------|----------------|
| **설치 복잡도** | 쉬움 | 보통 | 매우 쉬움 |
| **리소스 사용량** | 중간 | 낮음 | 높음 |
| **멀티노드 지원** | 제한적 | 완전 지원 | 단일노드만 |
| **애드온 지원** | 풍부 | 제한적 | 기본적 |
| **CI/CD 적합성** | 좋음 | 매우 좋음 | 보통 |
| **학습 목적** | 최적 | 좋음 | 좋음 |

---

## 2. minikube 설치 및 사용법 🚀

### 2.1 설치

#### macOS
```bash
# Homebrew로 설치
brew install minikube

# 직접 다운로드
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

#### Linux
```bash
# 직접 다운로드
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### Windows
```powershell
# Chocolatey로 설치
choco install minikube

# winget으로 설치
winget install Kubernetes.minikube
```

### 2.2 기본 사용법

#### 클러스터 시작
```bash
# 기본 설정으로 시작
minikube start

# 특정 드라이버로 시작
minikube start --driver=docker
minikube start --driver=virtualbox
minikube start --driver=hyperkit  # macOS

# 리소스 지정하여 시작
minikube start --memory=4096 --cpus=2

# Kubernetes 버전 지정
minikube start --kubernetes-version=v1.25.0
```

#### 클러스터 상태 확인
```bash
# 상태 확인
minikube status

# 클러스터 정보
minikube version
kubectl cluster-info

# 노드 확인
kubectl get nodes
```

#### 클러스터 관리
```bash
# 클러스터 중지
minikube stop

# 클러스터 삭제
minikube delete

# 클러스터 재시작
minikube restart

# SSH 접속
minikube ssh
```

### 2.3 minikube 애드온

#### 애드온 관리
```bash
# 사용 가능한 애드온 목록
minikube addons list

# 애드온 활성화
minikube addons enable dashboard
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable registry

# 애드온 비활성화
minikube addons disable dashboard
```

#### 대시보드 사용
```bash
# 대시보드 시작 (브라우저 자동 열림)
minikube dashboard

# 대시보드 URL만 표시
minikube dashboard --url
```

### 2.4 서비스 노출
```bash
# NodePort 서비스 접속
minikube service <service-name>

# URL 확인
minikube service <service-name> --url

# 터널링 (LoadBalancer 타입 지원)
minikube tunnel
```

---

## 3. kind 설치 및 사용법 🐳

### 3.1 설치

#### macOS/Linux
```bash
# Go로 설치
go install sigs.k8s.io/kind@v0.17.0

# 바이너리 직접 다운로드 (Linux)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# 바이너리 직접 다운로드 (macOS)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.17.0/kind-darwin-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### Windows
```powershell
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.17.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```

### 3.2 기본 사용법

#### 클러스터 생성
```bash
# 기본 클러스터 생성
kind create cluster

# 이름 지정하여 클러스터 생성
kind create cluster --name my-cluster

# 설정 파일로 클러스터 생성
kind create cluster --config kind-config.yaml
```

#### 클러스터 관리
```bash
# 클러스터 목록
kind get clusters

# 클러스터 삭제
kind delete cluster
kind delete cluster --name my-cluster

# kubeconfig 설정
kind get kubeconfig --name my-cluster
```

### 3.3 멀티노드 클러스터 설정

#### kind-config.yaml
```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.25.3
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
- role: worker
  image: kindest/node:v1.25.3
- role: worker
  image: kindest/node:v1.25.3
```

```bash
# 멀티노드 클러스터 생성
kind create cluster --config kind-config.yaml --name multi-node
```

### 3.4 이미지 로드
```bash
# Docker 이미지를 kind 클러스터로 로드
kind load docker-image my-app:latest --name my-cluster

# tar 파일로 이미지 로드
kind load image-archive my-app.tar --name my-cluster
```

---

## 4. 샘플 애플리케이션 배포 실습 🛠️

### 4.1 간단한 웹 애플리케이션 배포

#### nginx 웹서버 배포
```bash
# 1. Deployment 생성
kubectl create deployment nginx-web --image=nginx:1.21 --replicas=3

# 2. Service 생성 (NodePort)
kubectl expose deployment nginx-web --type=NodePort --port=80

# 3. 상태 확인
kubectl get all

# 4. 서비스 접속 (minikube)
minikube service nginx-web

# 4. 서비스 접속 (kind)
kubectl get service nginx-web  # NodePort 확인 후 http://localhost:<nodeport>
```

### 4.2 완전한 애플리케이션 스택 배포

#### YAML 매니페스트 작성
```yaml
# complete-web-app.yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        location /health {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config

---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

#### 배포 및 테스트
```bash
# 1. 애플리케이션 배포
kubectl apply -f complete-web-app.yaml

# 2. 배포 상태 확인
kubectl get all
kubectl get configmap

# 3. Pod 로그 확인
kubectl logs -l app=web-app

# 4. 서비스 테스트
curl http://localhost:30080  # kind
minikube service web-app-service  # minikube

# 5. 헬스체크 테스트
curl http://localhost:30080/health
```

### 4.3 데이터베이스 포함 전체 스택

#### WordPress + MySQL 예시
```yaml
# wordpress-stack.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  password: cGFzc3dvcmQxMjM=  # password123 base64 encoded

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        - name: MYSQL_DATABASE
          value: wordpress
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:5.8
        env:
        - name: WORDPRESS_DB_HOST
          value: mysql-service:3306
        - name: WORDPRESS_DB_NAME
          value: wordpress
        - name: WORDPRESS_DB_USER
          value: root
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: password
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30090
```

---

## 5. 클러스터 모니터링 및 디버깅 🔧

### 5.1 리소스 모니터링

#### 기본 모니터링 명령어
```bash
# 전체 리소스 확인
kubectl get all --all-namespaces

# 노드 리소스 사용량
kubectl top nodes

# Pod 리소스 사용량
kubectl top pods

# 네임스페이스별 리소스
kubectl get all -n kube-system
```

#### 상세 정보 확인
```bash
# 클러스터 정보
kubectl cluster-info
kubectl cluster-info dump

# 노드 상세 정보
kubectl describe nodes

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 5.2 로그 수집 및 분석

#### 로그 수집 방법
```bash
# 특정 Pod 로그
kubectl logs <pod-name>

# 이전 Pod 로그 (크래시 후)
kubectl logs <pod-name> --previous

# 실시간 로그 스트리밍
kubectl logs -f <pod-name>

# 라벨 셀렉터로 여러 Pod 로그
kubectl logs -l app=nginx

# 컨테이너 지정 (멀티컨테이너 Pod)
kubectl logs <pod-name> -c <container-name>
```

#### 시스템 로그 확인
```bash
# minikube 시스템 로그
minikube logs

# kind 컨테이너 로그
docker logs <kind-node-name>

# kubelet 로그 (노드 내부)
kubectl get nodes
minikube ssh
sudo journalctl -u kubelet
```

### 5.3 문제 해결 시나리오

#### 시나리오 1: Pod가 시작되지 않음
```bash
# 1. Pod 상태 확인
kubectl get pods

# 2. 상세 정보 확인
kubectl describe pod <pod-name>

# 3. 이벤트 확인
kubectl get events --field-selector involvedObject.name=<pod-name>

# 4. 일반적인 해결 방법
# - 이미지 풀 오류 → 이미지 이름/태그 확인
# - 리소스 부족 → 리소스 요구사항 조정
# - 설정 오류 → YAML 문법 확인
```

#### 시나리오 2: 서비스 연결 안됨
```bash
# 1. 서비스 확인
kubectl get services

# 2. 엔드포인트 확인
kubectl get endpoints <service-name>

# 3. 라벨 셀렉터 확인
kubectl get pods --show-labels
kubectl describe service <service-name>

# 4. 네트워크 테스트
kubectl run test-pod --image=busybox --rm -it -- sh
# 컨테이너 내부에서
nslookup <service-name>
wget -O- <service-name>:<port>
```

---

## 6. 개발 워크플로우 최적화 ⚡

### 6.1 빠른 개발 사이클

#### 이미지 빌드 및 배포 자동화
```bash
#!/bin/bash
# build-and-deploy.sh

# 이미지 빌드
docker build -t my-app:latest .

# kind 클러스터에 이미지 로드
kind load docker-image my-app:latest

# 배포 업데이트
kubectl set image deployment/my-app container=my-app:latest

# 롤아웃 상태 확인
kubectl rollout status deployment/my-app
```

#### 로컬 파일 변경 감지
```bash
# skaffold를 사용한 자동 빌드/배포
skaffold dev

# 또는 watchexec 사용
watchexec -w src/ './build-and-deploy.sh'
```

### 6.2 유용한 별칭 및 스크립트

#### kubectl 별칭
```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply'
alias kdel='kubectl delete'
alias klog='kubectl logs'
alias kexec='kubectl exec -it'
```

#### 유용한 함수
```bash
# Pod에 바로 접속
kshell() {
    kubectl exec -it $1 -- /bin/bash
}

# 네임스페이스 변경
kns() {
    kubectl config set-context --current --namespace=$1
}

# 포트 포워딩
kport() {
    kubectl port-forward $1 $2:$3
}
```

---

## 7. 성능 최적화 및 모범 사례 🎯

### 7.1 클러스터 리소스 최적화

#### minikube 최적화
```bash
# 충분한 리소스 할당
minikube start --memory=4096 --cpus=2 --disk-size=20g

# SSD 사용 시 성능 향상
minikube start --driver=hyperkit --disk-size=20g

# 캐시 정리
minikube cache list
minikube cache delete <image>
```

#### kind 최적화
```yaml
# kind-optimized.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraMounts:
  - hostPath: /tmp/kind-data
    containerPath: /data
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
```

### 7.2 보안 고려사항

#### 기본 보안 설정
```bash
# 서비스 어카운트 토큰 자동 마운트 비활성화
automountServiceAccountToken: false

# 보안 컨텍스트 설정
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
```

#### 네트워크 정책 (지원되는 CNI 사용 시)
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

---

## 8. 실습 프로젝트 🚀

### 프로젝트: 마이크로서비스 애플리케이션 배포

#### 1단계: 프론트엔드 서비스
```yaml
# frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: nginx:1.21
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: config
        configMap:
          name: frontend-config

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  default.conf: |
    upstream backend {
        server backend-service:8080;
    }
    server {
        listen 80;
        location /api/ {
            proxy_pass http://backend/;
        }
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30100
```

#### 2단계: 백엔드 서비스
```yaml
# backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: node:16-alpine
        command: ['sh', '-c', 'npm install express && node -e "
          const express = require(\"express\");
          const app = express();
          app.get(\"/\", (req, res) => res.json({message: \"Hello from backend!\", hostname: require(\"os\").hostname()}));
          app.listen(8080, () => console.log(\"Server running on port 8080\"));
        "']
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
```

#### 3단계: 배포 및 테스트
```bash
# 1. 모든 서비스 배포
kubectl apply -f frontend.yaml
kubectl apply -f backend.yaml

# 2. 상태 확인
kubectl get all
kubectl get configmap

# 3. 로그 확인
kubectl logs -l app=frontend
kubectl logs -l app=backend

# 4. 서비스 테스트
curl http://localhost:30100/api/

# 5. 스케일링 테스트
kubectl scale deployment backend --replicas=5
watch kubectl get pods
```

---

## 9. CKA/CKAD 시험 대비 팁 📝

### 9.1 시험 환경 시뮬레이션

#### 시간 제한 연습
```bash
# 10분 안에 전체 애플리케이션 배포 연습
time {
  kubectl create deployment web --image=nginx --replicas=3
  kubectl expose deployment web --port=80 --type=NodePort
  kubectl get all
}
```

#### 빠른 문제 해결 연습
```bash
# 1분 안에 Pod 트러블슈팅
kubectl get pods
kubectl describe pod <failing-pod>
kubectl logs <failing-pod>
kubectl delete pod <failing-pod>
```

### 9.2 필수 명령어 암기

#### YAML 생성 없이 빠른 배포
```bash
# Pod 생성
kubectl run nginx --image=nginx --restart=Never

# Deployment 생성
kubectl create deployment nginx --image=nginx --replicas=3

# Service 노출
kubectl expose deployment nginx --port=80

# Job 생성
kubectl create job hello --image=busybox -- echo "Hello World"

# CronJob 생성
kubectl create cronjob hello --schedule="*/5 * * * *" --image=busybox -- echo "Hello"
```

#### YAML 템플릿 생성
```bash
# 실행하지 않고 YAML만 생성
kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml
```

---

## 📚 학습 정리

### 핵심 개념 복습
1. **로컬 클러스터**: minikube(학습용), kind(개발/CI용), Docker Desktop(간편함)
2. **클러스터 관리**: 시작/중지, 애드온, 모니터링, 디버깅
3. **실제 배포**: 단순 앱부터 마이크로서비스까지

### 실습 체크리스트
- [ ] minikube 설치 및 클러스터 시작
- [ ] Dashboard 접속 및 탐색
- [ ] nginx 웹서버 배포 및 접속
- [ ] ConfigMap을 사용한 설정 관리
- [ ] 멀티컨테이너 애플리케이션 배포
- [ ] 서비스 트러블슈팅 연습
- [ ] 로그 수집 및 분석

### 다음 학습 계획
- 2주차: ConfigMap, Secret, ServiceAccount 학습
- 고급 스토리지 및 네트워킹 개념

### 추가 학습 자료
- [minikube 공식 문서](https://minikube.sigs.k8s.io/)
- [kind 공식 문서](https://kind.sigs.k8s.io/)
- [Kubernetes Patterns](https://kubernetes.io/docs/concepts/cluster-administration/)
- [Local Development 가이드](https://kubernetes.io/docs/tasks/debug-application-cluster/)