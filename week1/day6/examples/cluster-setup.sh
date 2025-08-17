#!/bin/bash
# cluster-setup.sh
# 로컬 클러스터 설정 및 관리 스크립트

set -e

echo "=== 로컬 클러스터 설정 및 관리 스크립트 ==="
echo

# 색깔 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
    echo
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

check_dependencies() {
    print_header "의존성 확인"
    
    # Docker 확인
    if command -v docker &> /dev/null; then
        print_success "Docker가 설치되어 있습니다"
    else
        print_error "Docker가 설치되어 있지 않습니다"
        exit 1
    fi
    
    # kubectl 확인
    if command -v kubectl &> /dev/null; then
        print_success "kubectl이 설치되어 있습니다"
    else
        print_warning "kubectl이 설치되어 있지 않습니다"
    fi
    
    echo
}

setup_minikube() {
    print_header "minikube 설정"
    
    if ! command -v minikube &> /dev/null; then
        print_error "minikube가 설치되어 있지 않습니다"
        print_warning "설치 가이드: https://minikube.sigs.k8s.io/docs/start/"
        return 1
    fi
    
    echo "minikube 클러스터를 시작합니다..."
    minikube start --memory=4096 --cpus=2 --driver=docker
    
    print_success "minikube 클러스터가 시작되었습니다"
    
    # 대시보드 애드온 활성화
    echo "대시보드 애드온을 활성화합니다..."
    minikube addons enable dashboard
    minikube addons enable metrics-server
    
    print_success "minikube 설정이 완료되었습니다"
    echo
}

setup_kind() {
    print_header "kind 설정"
    
    if ! command -v kind &> /dev/null; then
        print_error "kind가 설치되어 있지 않습니다"
        print_warning "설치 가이드: https://kind.sigs.k8s.io/docs/user/quick-start/"
        return 1
    fi
    
    # 기존 클러스터 확인
    if kind get clusters | grep -q "^kind$"; then
        print_warning "기존 kind 클러스터가 있습니다. 삭제하고 새로 만드시겠습니까? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            kind delete cluster
        else
            print_warning "기존 클러스터를 사용합니다"
            return 0
        fi
    fi
    
    echo "kind 멀티노드 클러스터를 생성합니다..."
    kind create cluster --config kind-config.yaml
    
    print_success "kind 클러스터가 생성되었습니다"
    echo
}

deploy_sample_apps() {
    print_header "샘플 애플리케이션 배포"
    
    echo "1. 간단한 웹 애플리케이션 배포"
    kubectl apply -f simple-web-app.yaml
    
    echo "2. ConfigMap이 포함된 완전한 웹 애플리케이션 배포"
    kubectl apply -f complete-web-app.yaml
    
    echo "3. 마이크로서비스 애플리케이션 배포"
    kubectl apply -f microservices-app.yaml
    
    print_success "모든 샘플 애플리케이션이 배포되었습니다"
    
    echo "배포 상태를 확인합니다..."
    kubectl get all
    echo
}

check_cluster_status() {
    print_header "클러스터 상태 확인"
    
    echo "📊 클러스터 정보:"
    kubectl cluster-info
    echo
    
    echo "🖥️  노드 상태:"
    kubectl get nodes -o wide
    echo
    
    echo "📦 전체 리소스:"
    kubectl get all --all-namespaces
    echo
    
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        echo "🚀 minikube 상태:"
        minikube status
        echo
    fi
}

show_access_info() {
    print_header "애플리케이션 접속 정보"
    
    echo "🌐 배포된 서비스 접속 방법:"
    echo
    
    # NodePort 서비스 확인
    services=$(kubectl get svc -o jsonpath='{range .items[?(@.spec.type=="NodePort")]}{.metadata.name}{" "}{.spec.ports[0].nodePort}{"\n"}{end}')
    
    if [[ -n "$services" ]]; then
        echo "$services" | while read -r name port; do
            if [[ -n "$name" && -n "$port" ]]; then
                echo "• $name: http://localhost:$port"
                
                # minikube인 경우 minikube service 명령어도 안내
                if command -v minikube &> /dev/null && minikube status &> /dev/null; then
                    echo "  또는: minikube service $name"
                fi
            fi
        done
    else
        print_warning "NodePort 타입의 서비스가 없습니다"
    fi
    
    echo
    echo "📊 대시보드 접속 (minikube만):"
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        echo "• minikube dashboard"
    else
        echo "• minikube가 실행 중이지 않습니다"
    fi
    echo
}

cleanup() {
    print_header "정리"
    
    echo "배포된 애플리케이션을 정리하시겠습니까? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "애플리케이션을 정리합니다..."
        kubectl delete -f simple-web-app.yaml --ignore-not-found=true
        kubectl delete -f complete-web-app.yaml --ignore-not-found=true
        kubectl delete -f microservices-app.yaml --ignore-not-found=true
        kubectl delete -f wordpress-stack.yaml --ignore-not-found=true
        
        print_success "애플리케이션 정리가 완료되었습니다"
    fi
    
    echo "클러스터를 중지하시겠습니까? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if command -v minikube &> /dev/null && minikube status &> /dev/null; then
            minikube stop
            print_success "minikube 클러스터가 중지되었습니다"
        fi
        
        if command -v kind &> /dev/null && kind get clusters | grep -q "kind"; then
            kind delete cluster
            print_success "kind 클러스터가 삭제되었습니다"
        fi
    fi
}

show_menu() {
    echo "=== 로컬 클러스터 관리 메뉴 ==="
    echo "1. 의존성 확인"
    echo "2. minikube 설정"
    echo "3. kind 설정"
    echo "4. 샘플 애플리케이션 배포"
    echo "5. 클러스터 상태 확인"
    echo "6. 접속 정보 표시"
    echo "7. 정리"
    echo "8. 전체 자동 설정 (minikube)"
    echo "9. 전체 자동 설정 (kind)"
    echo "0. 종료"
    echo
    echo -n "선택하세요 (0-9): "
}

auto_setup_minikube() {
    print_header "minikube 전체 자동 설정"
    check_dependencies
    setup_minikube
    deploy_sample_apps
    check_cluster_status
    show_access_info
}

auto_setup_kind() {
    print_header "kind 전체 자동 설정"
    check_dependencies
    setup_kind
    deploy_sample_apps
    check_cluster_status
    show_access_info
}

# 메인 로직
main() {
    if [[ $# -eq 1 ]]; then
        case $1 in
            "auto-minikube")
                auto_setup_minikube
                exit 0
                ;;
            "auto-kind")
                auto_setup_kind
                exit 0
                ;;
            "cleanup")
                cleanup
                exit 0
                ;;
        esac
    fi
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1)
                check_dependencies
                ;;
            2)
                setup_minikube
                ;;
            3)
                setup_kind
                ;;
            4)
                deploy_sample_apps
                ;;
            5)
                check_cluster_status
                ;;
            6)
                show_access_info
                ;;
            7)
                cleanup
                ;;
            8)
                auto_setup_minikube
                ;;
            9)
                auto_setup_kind
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
        echo "계속하려면 Enter를 누르세요..."
        read -r
        clear
    done
}

# 스크립트 실행
main "$@"