# 로컬 클러스터 트러블슈팅 가이드

## 🔧 일반적인 문제와 해결 방법

### 1. minikube 관련 문제

#### 문제: minikube가 시작되지 않음
```bash
# 상태 확인
minikube status

# 로그 확인
minikube logs

# 일반적인 해결 방법
minikube delete
minikube start --driver=docker
```

#### 문제: Docker 드라이버 문제
```bash
# Docker 상태 확인
docker ps

# Docker 재시작 (macOS)
sudo launchctl stop com.docker.docker
sudo launchctl start com.docker.docker

# minikube 드라이버 변경
minikube start --driver=virtualbox
```

#### 문제: 리소스 부족
```bash
# 더 많은 리소스로 시작
minikube start --memory=4096 --cpus=2 --disk-size=20g

# 현재 설정 확인
minikube config view
```

### 2. kind 관련 문제

#### 문제: kind 클러스터 생성 실패
```bash
# Docker 상태 확인
docker ps

# 기존 클러스터 정리
kind delete cluster
docker system prune -f

# 새 클러스터 생성
kind create cluster
```

#### 문제: 포트 충돌
```bash
# 사용 중인 포트 확인
netstat -an | grep :30080

# kind 설정에서 다른 포트 사용
# kind-config.yaml에서 hostPort 변경
```

### 3. Pod 문제

#### 문제: Pod가 Pending 상태
```bash
# Pod 상세 정보 확인
kubectl describe pod <pod-name>

# 노드 리소스 확인
kubectl describe nodes

# 이벤트 확인
kubectl get events --sort-by=.metadata.creationTimestamp
```

#### 문제: ImagePullBackOff
```bash
# 이미지 이름 확인
kubectl describe pod <pod-name>

# 로컬 이미지 사용 시 (kind)
kind load docker-image <image-name>

# 이미지 정책 변경
# imagePullPolicy: Never 또는 IfNotPresent
```

#### 문제: CrashLoopBackOff
```bash
# 로그 확인
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# 리소스 제한 확인
kubectl describe pod <pod-name>

# 명령어 및 인수 확인
kubectl get pod <pod-name> -o yaml
```

### 4. 서비스 연결 문제

#### 문제: 서비스에 접근할 수 없음
```bash
# 서비스 상태 확인
kubectl get svc

# 엔드포인트 확인
kubectl get endpoints

# 라벨 셀렉터 확인
kubectl get pods --show-labels
kubectl describe svc <service-name>
```

#### 문제: NodePort 접근 불가 (minikube)
```bash
# minikube IP 확인
minikube ip

# 서비스 URL 확인
minikube service <service-name> --url

# 터널링 시작
minikube tunnel
```

#### 문제: NodePort 접근 불가 (kind)
```bash
# 포트 매핑 확인
docker ps

# kind 설정에서 extraPortMappings 확인
# http://localhost:<hostPort>로 접근
```

### 5. 네트워크 문제

#### 문제: Pod 간 통신 불가
```bash
# DNS 확인
kubectl run test-pod --image=busybox --rm -it -- nslookup kubernetes.default

# 서비스 DNS 확인
kubectl run test-pod --image=busybox --rm -it -- nslookup <service-name>

# 네트워크 정책 확인 (있다면)
kubectl get networkpolicies
```

### 6. 리소스 부족 문제

#### 문제: "Insufficient memory" 오류
```bash
# 노드 리소스 확인
kubectl top nodes
kubectl describe nodes

# Pod 리소스 사용량 확인
kubectl top pods

# 리소스 요청/제한 조정
# resources.requests, resources.limits 값 조정
```

### 7. 설정 파일 문제

#### 문제: YAML 문법 오류
```bash
# YAML 문법 검증
kubectl apply --dry-run=client -f <yaml-file>

# 온라인 YAML 검증기 사용
# http://www.yamllint.com/
```

#### 문제: kubeconfig 문제
```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 사용 가능한 컨텍스트 확인
kubectl config get-contexts

# 컨텍스트 변경
kubectl config use-context <context-name>

# kubeconfig 재설정 (kind)
kind get kubeconfig --name <cluster-name>

# kubeconfig 재설정 (minikube)
minikube update-context
```

## 🚨 긴급 복구 명령어

### 전체 재시작
```bash
# minikube 전체 재시작
minikube stop
minikube delete
minikube start

# kind 전체 재시작
kind delete cluster
kind create cluster
```

### 리소스 정리
```bash
# 실패한 Pod 정리
kubectl delete pods --field-selector=status.phase=Failed

# 모든 리소스 정리
kubectl delete all --all

# 네임스페이스 정리
kubectl delete namespace <namespace-name>
```

### 강제 삭제
```bash
# Pod 강제 삭제
kubectl delete pod <pod-name> --force --grace-period=0

# Deployment 강제 삭제
kubectl delete deployment <deployment-name> --force --grace-period=0
```

## 📊 모니터링 명령어

### 실시간 모니터링
```bash
# Pod 상태 실시간 확인
watch kubectl get pods

# 이벤트 실시간 확인
kubectl get events -w

# 로그 실시간 확인
kubectl logs -f <pod-name>
```

### 리소스 사용량 확인
```bash
# 전체 리소스 확인
kubectl get all --all-namespaces

# 리소스 사용량 확인 (metrics-server 필요)
kubectl top nodes
kubectl top pods

# 상세 리소스 정보
kubectl describe nodes
kubectl describe pod <pod-name>
```

## 🔍 디버깅 도구

### 임시 디버깅 Pod
```bash
# busybox 디버깅 Pod
kubectl run debug --image=busybox --rm -it -- sh

# 네트워크 디버깅 Pod
kubectl run netshoot --image=nicolaka/netshoot --rm -it -- bash

# curl 테스트 Pod
kubectl run curl-test --image=curlimages/curl --rm -it -- sh
```

### 기존 Pod에 접속
```bash
# Pod 내부 접속
kubectl exec -it <pod-name> -- bash

# 특정 컨테이너 접속 (멀티컨테이너 Pod)
kubectl exec -it <pod-name> -c <container-name> -- bash
```

## 📝 로그 수집

### 시스템 로그
```bash
# minikube 시스템 로그
minikube logs

# kind 노드 로그
docker logs <kind-node-container>

# kubelet 로그 (노드 내부에서)
journalctl -u kubelet
```

### 애플리케이션 로그
```bash
# Pod 로그
kubectl logs <pod-name>

# 이전 인스턴스 로그
kubectl logs <pod-name> --previous

# 여러 Pod 로그
kubectl logs -l app=<label-value>

# 로그 저장
kubectl logs <pod-name> > pod.log
```

## 🆘 도움 받기

### 공식 문서
- [minikube 문제 해결](https://minikube.sigs.k8s.io/docs/handbook/troubleshooting/)
- [kind 문제 해결](https://kind.sigs.k8s.io/docs/user/known-issues/)
- [kubectl 문제 해결](https://kubernetes.io/docs/tasks/debug-application-cluster/)

### 커뮤니티
- [Kubernetes Slack](https://kubernetes.slack.com/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/kubernetes)
- [GitHub Issues](https://github.com/kubernetes/kubernetes/issues)

### 추가 도구
- [Lens](https://k8slens.dev/) - Kubernetes IDE
- [k9s](https://k9scli.io/) - 터미널 UI
- [Kubectx/Kubens](https://github.com/ahmetb/kubectx) - 컨텍스트/네임스페이스 전환