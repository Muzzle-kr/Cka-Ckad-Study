#!/bin/bash
# practice-scenarios.sh
# 로컬 클러스터 실습 시나리오 스크립트

set -e

# 색깔 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
    echo
}

print_step() {
    echo -e "${CYAN}📝 $1${NC}"
}

print_command() {
    echo -e "${YELLOW}💻 Command: ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

wait_for_user() {
    echo
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

scenario_1() {
    print_header "시나리오 1: 기본 웹 애플리케이션 배포"
    
    print_step "1단계: nginx Deployment 생성"
    print_command "kubectl create deployment nginx-web --image=nginx:1.21 --replicas=3"
    kubectl create deployment nginx-web --image=nginx:1.21 --replicas=3
    
    wait_for_user
    
    print_step "2단계: Deployment 상태 확인"
    print_command "kubectl get deployments"
    kubectl get deployments
    
    print_command "kubectl get pods"
    kubectl get pods
    
    wait_for_user
    
    print_step "3단계: Service 생성 (NodePort)"
    print_command "kubectl expose deployment nginx-web --type=NodePort --port=80"
    kubectl expose deployment nginx-web --type=NodePort --port=80
    
    wait_for_user
    
    print_step "4단계: Service 정보 확인"
    print_command "kubectl get services"
    kubectl get services
    
    nodeport=$(kubectl get svc nginx-web -o jsonpath='{.spec.ports[0].nodePort}')
    echo
    print_success "✨ 애플리케이션이 http://localhost:$nodeport 에서 접근 가능합니다"
    
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        echo -e "${GREEN}🚀 minikube service nginx-web 명령어로도 접근 가능합니다${NC}"
    fi
    
    wait_for_user
    
    print_step "5단계: 스케일링 테스트"
    print_command "kubectl scale deployment nginx-web --replicas=5"
    kubectl scale deployment nginx-web --replicas=5
    
    print_command "kubectl get pods"
    kubectl get pods
    
    wait_for_user
    
    print_step "시나리오 1 완료!"
    print_success "기본 웹 애플리케이션 배포 및 스케일링을 성공적으로 완료했습니다."
}

scenario_2() {
    print_header "시나리오 2: ConfigMap을 사용한 설정 관리"
    
    print_step "1단계: ConfigMap 생성"
    print_command "kubectl create configmap app-config --from-literal=environment=production --from-literal=debug=false"
    kubectl create configmap app-config --from-literal=environment=production --from-literal=debug=false
    
    wait_for_user
    
    print_step "2단계: ConfigMap 확인"
    print_command "kubectl get configmaps"
    kubectl get configmaps
    
    print_command "kubectl describe configmap app-config"
    kubectl describe configmap app-config
    
    wait_for_user
    
    print_step "3단계: ConfigMap을 사용하는 Pod 생성"
    cat <<EOF > /tmp/configmap-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-test-pod
spec:
  containers:
  - name: test-container
    image: busybox
    command: ['sh', '-c', 'echo "Environment: \$ENVIRONMENT"; echo "Debug: \$DEBUG"; sleep 3600']
    env:
    - name: ENVIRONMENT
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: environment
    - name: DEBUG
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: debug
EOF
    
    print_command "kubectl apply -f /tmp/configmap-pod.yaml"
    kubectl apply -f /tmp/configmap-pod.yaml
    
    wait_for_user
    
    print_step "4단계: Pod 로그 확인"
    echo "Pod가 시작될 때까지 기다립니다..."
    kubectl wait --for=condition=Ready pod/config-test-pod --timeout=60s
    
    print_command "kubectl logs config-test-pod"
    kubectl logs config-test-pod
    
    wait_for_user
    
    print_step "5단계: ConfigMap 업데이트"
    print_command "kubectl patch configmap app-config --patch '{\"data\":{\"environment\":\"staging\"}}'"
    kubectl patch configmap app-config --patch '{"data":{"environment":"staging"}}'
    
    print_step "시나리오 2 완료!"
    print_success "ConfigMap을 사용한 설정 관리를 성공적으로 완료했습니다."
}

scenario_3() {
    print_header "시나리오 3: 마이크로서비스 통신"
    
    print_step "1단계: Backend 서비스 배포"
    cat <<EOF > /tmp/backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
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
        command: ['sh', '-c', 'npm install express && node -e "const express = require(\"express\"); const app = express(); app.get(\"/\", (req, res) => res.json({message: \"Hello from backend!\", hostname: require(\"os\").hostname()})); app.listen(8080);"']
        ports:
        - containerPort: 8080
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
EOF
    
    print_command "kubectl apply -f /tmp/backend.yaml"
    kubectl apply -f /tmp/backend.yaml
    
    wait_for_user
    
    print_step "2단계: Frontend 서비스 배포"
    cat <<EOF > /tmp/frontend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 1
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
        image: curlimages/curl
        command: ['sh', '-c', 'while true; do echo "Calling backend..."; curl -s http://backend-service:8080; echo; sleep 10; done']
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
EOF
    
    print_command "kubectl apply -f /tmp/frontend.yaml"
    kubectl apply -f /tmp/frontend.yaml
    
    wait_for_user
    
    print_step "3단계: 서비스 간 통신 확인"
    echo "Pod가 시작될 때까지 기다립니다..."
    kubectl wait --for=condition=Ready pod -l app=backend --timeout=60s
    kubectl wait --for=condition=Ready pod -l app=frontend --timeout=60s
    
    print_command "kubectl logs -l app=frontend --tail=10"
    kubectl logs -l app=frontend --tail=10
    
    wait_for_user
    
    print_step "4단계: 직접 통신 테스트"
    print_command "kubectl run test-pod --image=curlimages/curl --rm -it -- curl http://backend-service:8080"
    kubectl run test-pod --image=curlimages/curl --rm -it -- curl http://backend-service:8080
    
    wait_for_user
    
    print_step "시나리오 3 완료!"
    print_success "마이크로서비스 간 통신을 성공적으로 테스트했습니다."
}

scenario_4() {
    print_header "시나리오 4: 트러블슈팅 연습"
    
    print_step "1단계: 문제가 있는 Pod 생성"
    cat <<EOF > /tmp/broken-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
spec:
  containers:
  - name: broken-container
    image: nginx:nonexistent-tag
    ports:
    - containerPort: 80
EOF
    
    print_command "kubectl apply -f /tmp/broken-pod.yaml"
    kubectl apply -f /tmp/broken-pod.yaml
    
    wait_for_user
    
    print_step "2단계: 문제 확인"
    print_command "kubectl get pods"
    kubectl get pods
    
    wait_for_user
    
    print_command "kubectl describe pod broken-pod"
    kubectl describe pod broken-pod
    
    wait_for_user
    
    print_step "3단계: 문제 해결"
    print_command "kubectl delete pod broken-pod"
    kubectl delete pod broken-pod
    
    cat <<EOF > /tmp/fixed-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: fixed-pod
spec:
  containers:
  - name: nginx-container
    image: nginx:1.21
    ports:
    - containerPort: 80
EOF
    
    print_command "kubectl apply -f /tmp/fixed-pod.yaml"
    kubectl apply -f /tmp/fixed-pod.yaml
    
    wait_for_user
    
    print_step "4단계: 수정 확인"
    echo "Pod가 시작될 때까지 기다립니다..."
    kubectl wait --for=condition=Ready pod/fixed-pod --timeout=60s
    
    print_command "kubectl get pods"
    kubectl get pods
    
    wait_for_user
    
    print_step "시나리오 4 완료!"
    print_success "트러블슈팅 연습을 성공적으로 완료했습니다."
}

scenario_5() {
    print_header "시나리오 5: 리소스 모니터링"
    
    print_step "1단계: 리소스 제한이 있는 Pod 생성"
    cat <<EOF > /tmp/resource-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-test-pod
spec:
  containers:
  - name: resource-container
    image: nginx:1.21
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
EOF
    
    print_command "kubectl apply -f /tmp/resource-pod.yaml"
    kubectl apply -f /tmp/resource-pod.yaml
    
    wait_for_user
    
    print_step "2단계: 리소스 사용량 확인 (metrics-server 필요)"
    echo "Pod가 시작될 때까지 기다립니다..."
    kubectl wait --for=condition=Ready pod/resource-test-pod --timeout=60s
    
    if kubectl top nodes &> /dev/null; then
        print_command "kubectl top nodes"
        kubectl top nodes
        
        print_command "kubectl top pods"
        kubectl top pods
    else
        print_error "metrics-server가 설치되어 있지 않습니다."
        echo "minikube인 경우: minikube addons enable metrics-server"
    fi
    
    wait_for_user
    
    print_step "3단계: 리소스 상세 정보 확인"
    print_command "kubectl describe pod resource-test-pod"
    kubectl describe pod resource-test-pod
    
    wait_for_user
    
    print_step "시나리오 5 완료!"
    print_success "리소스 모니터링을 성공적으로 완료했습니다."
}

cleanup_all() {
    print_header "모든 연습 리소스 정리"
    
    echo "연습에서 생성한 모든 리소스를 정리합니다..."
    
    # 시나리오 1 정리
    kubectl delete deployment nginx-web --ignore-not-found=true
    kubectl delete service nginx-web --ignore-not-found=true
    
    # 시나리오 2 정리
    kubectl delete pod config-test-pod --ignore-not-found=true
    kubectl delete configmap app-config --ignore-not-found=true
    
    # 시나리오 3 정리
    kubectl delete deployment backend frontend --ignore-not-found=true
    kubectl delete service backend-service frontend-service --ignore-not-found=true
    
    # 시나리오 4 정리
    kubectl delete pod broken-pod fixed-pod --ignore-not-found=true
    
    # 시나리오 5 정리
    kubectl delete pod resource-test-pod --ignore-not-found=true
    
    # 임시 파일 정리
    rm -f /tmp/configmap-pod.yaml /tmp/backend.yaml /tmp/frontend.yaml
    rm -f /tmp/broken-pod.yaml /tmp/fixed-pod.yaml /tmp/resource-pod.yaml
    
    print_success "모든 리소스가 정리되었습니다."
}

show_menu() {
    echo "=== 로컬 클러스터 실습 시나리오 ==="
    echo "1. 기본 웹 애플리케이션 배포"
    echo "2. ConfigMap을 사용한 설정 관리"
    echo "3. 마이크로서비스 통신"
    echo "4. 트러블슈팅 연습"
    echo "5. 리소스 모니터링"
    echo "6. 모든 시나리오 실행"
    echo "7. 리소스 정리"
    echo "0. 종료"
    echo
    echo -n "선택하세요 (0-7): "
}

run_all_scenarios() {
    print_header "모든 시나리오 자동 실행"
    scenario_1
    echo
    scenario_2
    echo
    scenario_3
    echo
    scenario_4
    echo
    scenario_5
    echo
    print_success "🎉 모든 시나리오를 성공적으로 완료했습니다!"
}

# 메인 로직
main() {
    # 클러스터 연결 확인
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Kubernetes 클러스터에 연결할 수 없습니다."
        echo "minikube start 또는 kind create cluster를 먼저 실행하세요."
        exit 1
    fi
    
    if [[ $# -eq 1 ]]; then
        case $1 in
            "all")
                run_all_scenarios
                exit 0
                ;;
            "cleanup")
                cleanup_all
                exit 0
                ;;
        esac
    fi
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                scenario_1
                ;;
            2)
                scenario_2
                ;;
            3)
                scenario_3
                ;;
            4)
                scenario_4
                ;;
            5)
                scenario_5
                ;;
            6)
                run_all_scenarios
                ;;
            7)
                cleanup_all
                ;;
            0)
                echo "종료합니다."
                exit 0
                ;;
            *)
                print_error "잘못된 선택입니다. 다시 선택해주세요."
                ;;
        esac
        
        echo
        echo -e "${YELLOW}메뉴로 돌아가려면 Enter를 누르세요...${NC}"
        read -r
        clear
    done
}

# 스크립트 실행
main "$@"