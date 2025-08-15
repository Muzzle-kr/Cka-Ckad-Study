# 1주차 4일차: kubectl 기본 명령어

**학습 목표**: kubectl의 핵심 명령어를 익히고 K8s 리소스를 조회/관리하는 방법을 습득한다.

**소요 시간**: 20-30분

---

## 📖 kubectl 개요

`kubectl`은 Kubernetes 클러스터와 상호작용하는 공식 명령줄 도구입니다.

### kubectl 구문
```bash
kubectl [command] [TYPE] [NAME] [flags]
```

- **command**: 리소스에 수행할 작업 (get, describe, create, delete 등)
- **TYPE**: 리소스 타입 (pods, services, deployments 등)
- **NAME**: 리소스 이름 (선택사항)
- **flags**: 추가 옵션 (-o wide, --namespace 등)

---

## 🔍 주요 조회 명령어

### 1. kubectl get - 리소스 목록 조회

**기본 사용법**
```bash
# 모든 Pod 조회
kubectl get pods

# 모든 리소스 조회
kubectl get all

# 특정 네임스페이스의 Pod 조회
kubectl get pods -n kube-system

# 상세 정보와 함께 조회
kubectl get pods -o wide

# YAML 형식으로 조회
kubectl get pod nginx-pod -o yaml

# JSON 형식으로 조회
kubectl get pod nginx-pod -o json
```

**출력 형식 옵션**
```bash
-o wide          # IP, 노드 정보 포함
-o yaml          # YAML 형식
-o json          # JSON 형식
-o name          # 이름만 출력
--no-headers     # 헤더 제거
```

### 2. kubectl describe - 상세 정보 조회

```bash
# Pod 상세 정보
kubectl describe pod nginx-pod

# 모든 Pod의 상세 정보
kubectl describe pods

# Service 상세 정보
kubectl describe service nginx-service

# Node 상세 정보
kubectl describe node minikube
```

### 3. kubectl logs - 로그 조회

```bash
# Pod 로그 보기
kubectl logs nginx-pod

# 실시간 로그 스트리밍
kubectl logs -f nginx-pod

# 최근 10줄만 보기
kubectl logs --tail=10 nginx-pod

# 특정 컨테이너 로그 (멀티 컨테이너 Pod)
kubectl logs nginx-pod -c nginx-container

# 이전 컨테이너 로그 (재시작된 경우)
kubectl logs nginx-pod --previous
```

---

## ⚙️ 주요 관리 명령어

### 1. kubectl apply - 리소스 생성/업데이트

```bash
# YAML 파일로 리소스 생성
kubectl apply -f pod.yaml

# 여러 파일 동시 적용
kubectl apply -f .

# URL에서 직접 적용
kubectl apply -f https://example.com/pod.yaml

# 변경사항만 출력 (실제 적용 안함)
kubectl apply -f pod.yaml --dry-run=client
```

### 2. kubectl create - 리소스 생성

```bash
# 명령줄로 Pod 생성
kubectl create deployment nginx --image=nginx

# YAML 파일로 생성
kubectl create -f pod.yaml

# 네임스페이스 생성
kubectl create namespace test

# Service 생성
kubectl create service clusterip nginx --tcp=80:80
```

### 3. kubectl delete - 리소스 삭제

```bash
# 특정 Pod 삭제
kubectl delete pod nginx-pod

# YAML 파일 기반 삭제
kubectl delete -f pod.yaml

# 모든 Pod 삭제
kubectl delete pods --all

# 라벨 기반 삭제
kubectl delete pods -l app=nginx

# 강제 삭제 (즉시 삭제)
kubectl delete pod nginx-pod --force --grace-period=0
```

### 4. kubectl exec - 컨테이너 내부 접속

```bash
# 컨테이너에 명령 실행
kubectl exec nginx-pod -- ls /

# 대화형 셸 실행
kubectl exec -it nginx-pod -- /bin/bash

# 특정 컨테이너에 접속 (멀티 컨테이너)
kubectl exec -it nginx-pod -c nginx-container -- bash
```

---

## 🎯 실용적인 kubectl 팁

### 1. 별칭(Alias) 설정

```bash
# ~/.bashrc 또는 ~/.zshrc에 추가
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kl='kubectl logs'
alias ke='kubectl exec -it'
```

### 2. 자동완성 설정

```bash
# Bash
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Zsh
echo 'source <(kubectl completion zsh)' >>~/.zshrc
```

### 3. 네임스페이스 기본값 설정

```bash
# 현재 컨텍스트의 네임스페이스 변경
kubectl config set-context --current --namespace=kube-system

# 네임스페이스 확인
kubectl config view --minify | grep namespace
```

### 4. 빠른 리소스 생성

```bash
# Pod 빠르게 생성
kubectl run nginx --image=nginx

# Deployment 빠르게 생성
kubectl create deployment nginx --image=nginx

# Service 빠르게 생성
kubectl expose deployment nginx --port=80 --type=ClusterIP
```

---

## 🛠️ 실습 예제

### 예제 1: Nginx Pod 생성 및 관리

```bash
# 1. Nginx Pod 생성
kubectl run nginx --image=nginx

# 2. Pod 상태 확인
kubectl get pods

# 3. Pod 상세 정보 확인
kubectl describe pod nginx

# 4. Pod 로그 확인
kubectl logs nginx

# 5. Pod 내부 접속
kubectl exec -it nginx -- bash

# 6. Pod 삭제
kubectl delete pod nginx
```

### 예제 2: YAML로 리소스 관리

```bash
# 1. YAML 파일로 Pod 생성
kubectl apply -f examples/nginx-pod.yaml

# 2. 생성된 리소스 확인
kubectl get -f examples/nginx-pod.yaml

# 3. 리소스 수정 후 재적용
kubectl apply -f examples/nginx-pod.yaml

# 4. YAML 파일 기반 삭제
kubectl delete -f examples/nginx-pod.yaml
```

---

## 🔧 문제 해결 명령어

### 디버깅 명령어

```bash
# 클러스터 정보 확인
kubectl cluster-info

# 노드 상태 확인
kubectl get nodes

# 이벤트 확인
kubectl get events

# 리소스 사용량 확인 (metrics-server 필요)
kubectl top nodes
kubectl top pods

# API 서버 상태 확인
kubectl get componentstatuses
```

### 정보 수집 명령어

```bash
# 모든 네임스페이스의 Pod 조회
kubectl get pods --all-namespaces

# 특정 라벨의 리소스 조회
kubectl get pods -l app=nginx

# 정렬된 결과 조회
kubectl get pods --sort-by=.metadata.creationTimestamp

# 와이드 출력으로 더 많은 정보 보기
kubectl get pods -o wide --all-namespaces
```

---

## 🎓 학습 정리

### 핵심 개념
- **kubectl**: Kubernetes 클러스터 관리를 위한 공식 CLI 도구
- **리소스 조회**: get, describe로 상태 확인
- **로그 분석**: logs 명령으로 애플리케이션 문제 진단
- **리소스 관리**: apply, create, delete로 생명주기 관리

### 다음 단계
- K8s 핵심 리소스(Pod, Deployment, Service) 구조 이해
- YAML 매니페스트 작성법 학습
- 실제 애플리케이션 배포 실습

### 중요 포인트
1. **kubectl get**: 리소스 목록과 상태 확인의 기본
2. **kubectl describe**: 상세 정보와 이벤트 확인
3. **kubectl logs**: 애플리케이션 디버깅의 핵심
4. **kubectl exec**: 컨테이너 내부 접근과 디버깅
5. **YAML 기반 관리**: 선언적 방식의 리소스 관리

---

**💡 팁**: CKA/CKAD 시험에서는 빠른 명령어 실행이 중요합니다. 별칭과 자동완성을 적극 활용하고, `kubectl run`과 `kubectl create` 명령으로 빠르게 리소스를 생성하는 연습을 하세요!