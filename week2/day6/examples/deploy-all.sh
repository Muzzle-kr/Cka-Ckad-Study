#!/bin/bash

# E-Commerce 마이크로서비스 전체 배포 스크립트
# Week 2 Day 6: 실전 통합 연습

set -e

echo "🚀 E-Commerce 마이크로서비스 배포 시작"
echo "========================================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_step() {
    echo -e "${BLUE}📋 Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

wait_for_pods() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    
    echo "⏳ Pod 준비 대기 중: $label (최대 ${timeout}초)"
    kubectl wait --for=condition=ready pod -l "$label" -n "$namespace" --timeout="${timeout}s" || {
        print_error "Pod 준비 실패: $label"
        kubectl get pods -l "$label" -n "$namespace"
        return 1
    }
}

check_prerequisites() {
    print_step "1" "전제 조건 확인"
    
    # kubectl 설치 확인
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl이 설치되지 않았습니다"
        exit 1
    fi
    
    # 클러스터 연결 확인
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Kubernetes 클러스터에 연결할 수 없습니다"
        echo "먼저 클러스터를 시작하세요: minikube start"
        exit 1
    fi
    
    print_success "전제 조건 확인 완료"
}

deploy_namespace() {
    print_step "2" "네임스페이스 및 기본 리소스 생성"
    
    kubectl apply -f 00-namespace.yaml
    kubectl config set-context --current --namespace=ecommerce
    
    print_success "네임스페이스 'ecommerce' 생성 완료"
}

deploy_configmaps() {
    print_step "3" "ConfigMap 배포"
    
    kubectl apply -f configmaps/
    
    # ConfigMap 확인
    echo "📊 ConfigMap 목록:"
    kubectl get configmaps -o custom-columns=NAME:.metadata.name,DATA:.data
    
    print_success "ConfigMap 배포 완료"
}

deploy_secrets() {
    print_step "4" "Secret 배포"
    
    kubectl apply -f secrets/
    
    # Secret 확인
    echo "🔐 Secret 목록:"
    kubectl get secrets -o custom-columns=NAME:.metadata.name,TYPE:.type,DATA:.data
    
    print_success "Secret 배포 완료"
}

deploy_rbac() {
    print_step "5" "RBAC 구성"
    
    kubectl apply -f rbac/
    
    # ServiceAccount 확인
    echo "👤 ServiceAccount 목록:"
    kubectl get serviceaccounts
    
    # Role 확인
    echo "🔑 Role 목록:"
    kubectl get roles
    
    print_success "RBAC 구성 완료"
}

deploy_databases() {
    print_step "6" "데이터베이스 서비스 배포"
    
    kubectl apply -f deployments/database.yaml
    
    # 데이터베이스 Pod 준비 대기
    wait_for_pods "ecommerce" "tier=database" 180
    wait_for_pods "ecommerce" "tier=cache" 120
    
    print_success "데이터베이스 서비스 배포 완료"
}

deploy_backend() {
    print_step "7" "백엔드 마이크로서비스 배포"
    
    kubectl apply -f deployments/backend-services.yaml
    
    # 백엔드 서비스 Pod 준비 대기
    wait_for_pods "ecommerce" "tier=backend" 180
    
    print_success "백엔드 마이크로서비스 배포 완료"
}

deploy_frontend() {
    print_step "8" "프론트엔드 및 게이트웨이 배포"
    
    kubectl apply -f deployments/frontend-gateway.yaml
    
    # 프론트엔드 서비스 Pod 준비 대기
    wait_for_pods "ecommerce" "tier=frontend" 120
    wait_for_pods "ecommerce" "tier=gateway" 120
    
    print_success "프론트엔드 및 게이트웨이 배포 완료"
}

deploy_advanced() {
    print_step "9" "고급 보안 서비스 배포 (선택사항)"
    
    # 노드 레이블 확인
    if kubectl get nodes --show-labels | grep -q "workload=payment"; then
        kubectl apply -f advanced/secure-deployment.yaml
        print_success "보안 강화 결제 서비스 배포 완료"
    else
        print_warning "전용 노드가 설정되지 않아 보안 강화 서비스는 건너뜁니다"
        echo "전용 노드 설정: kubectl label nodes <node-name> workload=payment"
    fi
}

deploy_autoscaling() {
    print_step "10" "오토스케일링 설정 (선택사항)"
    
    # metrics-server 확인
    if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
        kubectl apply -f optimization/hpa-configs.yaml
        print_success "HPA 설정 완료"
    else
        print_warning "metrics-server가 없어 HPA 설정을 건너뜁니다"
        echo "metrics-server 활성화: minikube addons enable metrics-server"
    fi
}

verify_deployment() {
    print_step "11" "배포 검증"
    
    echo "🔍 전체 리소스 현황:"
    kubectl get all -o wide
    
    echo ""
    echo "📊 Pod 상태별 분류:"
    kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,QOS:.status.qosClass,NODE:.spec.nodeName
    
    echo ""
    echo "🔍 서비스 엔드포인트:"
    kubectl get services -o custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,EXTERNAL-IP:.status.loadBalancer.ingress[0].ip,PORT:.spec.ports[0].port
    
    echo ""
    echo "💾 ConfigMap & Secret 현황:"
    kubectl get configmaps,secrets --no-headers | wc -l | xargs echo "총 ConfigMap & Secret 수:"
    
    echo ""
    echo "👤 RBAC 현황:"
    kubectl get serviceaccounts,roles,rolebindings --no-headers | wc -l | xargs echo "총 RBAC 리소스 수:"
    
    # Health check
    echo ""
    echo "🏥 서비스 Health Check:"
    
    # API Gateway health check
    if kubectl get service api-gateway &> /dev/null; then
        API_GATEWAY_IP=$(kubectl get service api-gateway -o jsonpath='{.spec.clusterIP}')
        if kubectl exec -it deployment/frontend -- wget -q -O - http://$API_GATEWAY_IP:8080/health 2>/dev/null; then
            print_success "API Gateway: 정상"
        else
            print_warning "API Gateway: 헬스체크 실패"
        fi
    fi
    
    print_success "배포 검증 완료"
}

show_access_info() {
    print_step "12" "접근 정보"
    
    echo "🌐 외부 접근 방법:"
    
    # NodePort 서비스 정보
    if kubectl get service frontend &> /dev/null; then
        NODE_PORT=$(kubectl get service frontend -o jsonpath='{.spec.ports[0].nodePort}')
        if command -v minikube &> /dev/null && minikube status &> /dev/null; then
            MINIKUBE_IP=$(minikube ip)
            echo "  Frontend: http://$MINIKUBE_IP:$NODE_PORT"
        else
            echo "  Frontend NodePort: $NODE_PORT"
        fi
    fi
    
    # LoadBalancer 서비스 정보
    if kubectl get service frontend-lb &> /dev/null; then
        echo "  LoadBalancer: kubectl get service frontend-lb (External IP 확인)"
    fi
    
    echo ""
    echo "🔧 개발/디버깅 명령어:"
    echo "  네임스페이스 설정: kubectl config set-context --current --namespace=ecommerce"
    echo "  Pod 로그 확인: kubectl logs -f deployment/<service-name>"
    echo "  Pod 접속: kubectl exec -it deployment/<service-name> -- sh"
    echo "  서비스 테스트: kubectl port-forward service/<service-name> <local-port>:<service-port>"
    echo ""
    echo "📊 모니터링 명령어:"
    echo "  리소스 사용량: kubectl top pods"
    echo "  이벤트 확인: kubectl get events --sort-by='.lastTimestamp'"
    echo "  상세 정보: kubectl describe pod <pod-name>"
}

cleanup() {
    print_step "정리" "리소스 정리"
    
    read -p "모든 리소스를 삭제하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace ecommerce
        print_success "네임스페이스 'ecommerce' 및 모든 리소스 삭제 완료"
    else
        echo "정리 작업이 취소되었습니다"
    fi
}

# 메인 실행
main() {
    case "${1:-deploy}" in
        "deploy")
            check_prerequisites
            deploy_namespace
            deploy_configmaps
            deploy_secrets
            deploy_rbac
            deploy_databases
            deploy_backend
            deploy_frontend
            deploy_advanced
            deploy_autoscaling
            verify_deployment
            show_access_info
            
            echo ""
            echo "🎉 E-Commerce 마이크로서비스 배포 완료!"
            echo "======================================="
            ;;
        "cleanup")
            cleanup
            ;;
        "verify")
            verify_deployment
            show_access_info
            ;;
        *)
            echo "사용법: $0 [deploy|cleanup|verify]"
            echo "  deploy  : 전체 시스템 배포 (기본값)"
            echo "  cleanup : 모든 리소스 정리"
            echo "  verify  : 배포 상태 검증"
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"