#!/bin/bash

echo "======================================"
echo "2주차 4일차: Kubernetes Probe 실습"
echo "======================================"
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_step() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_command() {
    echo -e "${YELLOW}$ $1${NC}"
}

wait_for_input() {
    echo -e "${GREEN}Press Enter to continue...${NC}"
    read
}

# 네임스페이스 생성
print_step "네임스페이스 생성"
print_command "kubectl create namespace probe-demo"
kubectl create namespace probe-demo
echo ""

# 실습 1: Liveness Probe
print_step "실습 1: Liveness Probe 테스트"
echo "HTTP GET Liveness Probe를 가진 Pod 배포"
wait_for_input

print_command "kubectl apply -f webapp-with-liveness.yaml -n probe-demo"
kubectl apply -f webapp-with-liveness.yaml -n probe-demo

echo ""
echo "Pod 상태 확인:"
print_command "kubectl get pods -n probe-demo -w"
echo "몇 초간 Pod 상태를 관찰한 후 Ctrl+C로 중단하세요"
kubectl get pods -n probe-demo -w &
sleep 15
kill $!

echo ""
echo "Pod 상세 정보 및 Probe 설정 확인:"
print_command "kubectl describe pod webapp-liveness -n probe-demo"
kubectl describe pod webapp-liveness -n probe-demo

echo ""
echo "의도적으로 실패 상황 생성:"
print_command "kubectl exec -it webapp-liveness -n probe-demo -- rm /tmp/healthy"
kubectl exec -it webapp-liveness -n probe-demo -- rm /tmp/healthy

echo ""
echo "Liveness Probe 실패 후 재시작 확인:"
print_command "kubectl get events --sort-by=.metadata.creationTimestamp -n probe-demo"
kubectl get events --sort-by=.metadata.creationTimestamp -n probe-demo

wait_for_input

# 실습 2: Readiness Probe
print_step "실습 2: Readiness Probe와 Service 연동"
echo "Readiness Probe를 가진 Pod와 Service 배포"

print_command "kubectl apply -f webapp-with-readiness.yaml -n probe-demo"
kubectl apply -f webapp-with-readiness.yaml -n probe-demo

print_command "kubectl apply -f webapp-service.yaml -n probe-demo"
kubectl apply -f webapp-service.yaml -n probe-demo

echo ""
echo "서비스 엔드포인트 확인:"
print_command "kubectl get endpoints webapp-service -n probe-demo"
kubectl get endpoints webapp-service -n probe-demo

echo ""
echo "Readiness 실패 시나리오 시뮬레이션:"
print_command "kubectl exec -it webapp-readiness -n probe-demo -- rm /usr/share/nginx/html/ready"
kubectl exec -it webapp-readiness -n probe-demo -- rm /usr/share/nginx/html/ready

echo ""
echo "엔드포인트에서 제거 확인:"
sleep 10
print_command "kubectl get endpoints webapp-service -n probe-demo"
kubectl get endpoints webapp-service -n probe-demo

echo ""
echo "Readiness 복구:"
print_command "kubectl exec -it webapp-readiness -n probe-demo -- sh -c 'echo \"Ready again\" > /usr/share/nginx/html/ready'"
kubectl exec -it webapp-readiness -n probe-demo -- sh -c 'echo "Ready again" > /usr/share/nginx/html/ready'

sleep 10
print_command "kubectl get endpoints webapp-service -n probe-demo"
kubectl get endpoints webapp-service -n probe-demo

wait_for_input

# 실습 3: 복합 Probe
print_step "실습 3: 복합 Probe (Startup + Liveness + Readiness)"
echo "모든 Probe 타입을 사용하는 복잡한 애플리케이션 배포"

print_command "kubectl apply -f complex-probe-app.yaml -n probe-demo"
kubectl apply -f complex-probe-app.yaml -n probe-demo

echo ""
echo "Pod 시작 과정 관찰:"
print_command "kubectl get pods complex-app -n probe-demo -w"
echo "Startup Probe가 성공할 때까지 기다린 후 Ctrl+C로 중단하세요"
kubectl get pods complex-app -n probe-demo -w &
sleep 60
kill $!

echo ""
echo "Pod 상세 정보 확인:"
print_command "kubectl describe pod complex-app -n probe-demo"
kubectl describe pod complex-app -n probe-demo

wait_for_input

# 실습 4: TCP Socket Probe
print_step "실습 4: TCP Socket Probe"
echo "Redis를 사용한 TCP Socket Probe 테스트"

print_command "kubectl apply -f tcp-probe-app.yaml -n probe-demo"
kubectl apply -f tcp-probe-app.yaml -n probe-demo

echo ""
echo "TCP Probe 상태 확인:"
print_command "kubectl describe pod tcp-probe-app -n probe-demo"
kubectl describe pod tcp-probe-app -n probe-demo

wait_for_input

# 실습 5: Exec Command Probe
print_step "실습 5: Exec Command Probe"
echo "파일 존재 여부를 확인하는 Exec Command Probe 테스트"

print_command "kubectl apply -f exec-probe-app.yaml -n probe-demo"
kubectl apply -f exec-probe-app.yaml -n probe-demo

echo ""
echo "Exec Probe 상태 확인:"
print_command "kubectl describe pod exec-probe-app -n probe-demo"
kubectl describe pod exec-probe-app -n probe-demo

echo ""
echo "의도적으로 헬스체크 파일 제거:"
print_command "kubectl exec -it exec-probe-app -n probe-demo -- rm /tmp/healthy"
kubectl exec -it exec-probe-app -n probe-demo -- rm /tmp/healthy

echo ""
echo "Liveness Probe 실패 확인:"
sleep 20
print_command "kubectl get events --field-selector reason=Unhealthy -n probe-demo"
kubectl get events --field-selector reason=Unhealthy -n probe-demo

wait_for_input

# 실습 6: 데이터베이스 Probe
print_step "실습 6: 데이터베이스 애플리케이션 Probe"
echo "시작 시간이 오래 걸리는 PostgreSQL 데이터베이스 Probe 테스트"

print_command "kubectl apply -f database-probe-app.yaml -n probe-demo"
kubectl apply -f database-probe-app.yaml -n probe-demo

echo ""
echo "데이터베이스 시작 과정 관찰 (Startup Probe 중요성):"
print_command "kubectl get pods database-app -n probe-demo -w"
echo "Startup Probe가 성공할 때까지 기다린 후 Ctrl+C로 중단하세요"
kubectl get pods database-app -n probe-demo -w &
sleep 90
kill $!

echo ""
echo "Probe 설정 확인:"
print_command "kubectl describe pod database-app -n probe-demo"
kubectl describe pod database-app -n probe-demo

wait_for_input

# 모니터링 및 트러블슈팅 명령어
print_step "모니터링 및 트러블슈팅 명령어"

echo "1. Probe 관련 이벤트 확인:"
print_command "kubectl get events --field-selector reason=Unhealthy -n probe-demo"
kubectl get events --field-selector reason=Unhealthy -n probe-demo

echo ""
echo "2. 모든 이벤트 시간순 정렬:"
print_command "kubectl get events --sort-by=.metadata.creationTimestamp -n probe-demo"
kubectl get events --sort-by=.metadata.creationTimestamp -n probe-demo

echo ""
echo "3. Pod의 Probe 설정 YAML 확인:"
print_command "kubectl get pod complex-app -n probe-demo -o yaml | grep -A 20 -B 2 probe"
kubectl get pod complex-app -n probe-demo -o yaml | grep -A 20 -B 2 probe

echo ""
echo "4. 실시간 Pod 상태 모니터링:"
print_command "kubectl get pods -n probe-demo -w"
echo "(실제로는 실행하지 않음 - 데모용)"

echo ""
echo "5. Pod 재시작 횟수 확인:"
print_command "kubectl get pods -n probe-demo"
kubectl get pods -n probe-demo

wait_for_input

# 정리
print_step "실습 환경 정리"
echo "생성한 리소스들을 정리합니다."

print_command "kubectl delete namespace probe-demo"
kubectl delete namespace probe-demo

echo ""
echo -e "${GREEN}======================================"
echo "2주차 4일차 Probe 실습 완료!"
echo "======================================${NC}"
echo ""
echo "학습한 내용:"
echo "✅ Liveness Probe - 컨테이너 재시작"
echo "✅ Readiness Probe - 서비스 엔드포인트 제어"
echo "✅ Startup Probe - 시작 시간 관리"
echo "✅ HTTP GET, TCP Socket, Exec Command Probe 타입"
echo "✅ 데이터베이스 애플리케이션 Probe 전략"
echo "✅ Probe 모니터링 및 트러블슈팅"
echo ""
echo "다음 단계: Day 5 - 고급 Pod 설정 (Resource Requests/Limits, QoS)"