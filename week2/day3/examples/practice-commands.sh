#!/bin/bash

# Week2 Day3: ServiceAccount & RBAC 실습 명령어 모음
# CKA/CKAD 준비를 위한 실전 명령어들

echo "=== ServiceAccount & RBAC 실습 명령어 ==="

# 1. 기본 ServiceAccount 관리
echo -e "\n📋 1. ServiceAccount 기본 관리"

echo "# ServiceAccount 생성"
echo "kubectl create serviceaccount webapp-sa"

echo "# ServiceAccount 조회"
echo "kubectl get serviceaccounts"
echo "kubectl get sa"
echo "kubectl describe sa webapp-sa"

echo "# ServiceAccount 삭제"
echo "kubectl delete serviceaccount webapp-sa"

# 2. Role 및 RoleBinding 관리
echo -e "\n🔐 2. Role & RoleBinding 관리"

echo "# Role 생성 (Pod 읽기 권한)"
echo "kubectl create role pod-reader --verb=get,list,watch --resource=pods"

echo "# Role 생성 (더 복잡한 권한)"
echo "kubectl create role deployment-manager --verb=get,list,watch,create,update,patch --resource=deployments"

echo "# RoleBinding 생성"
echo "kubectl create rolebinding pod-reader-binding --role=pod-reader --serviceaccount=default:webapp-sa"

echo "# Role과 RoleBinding 조회"
echo "kubectl get roles"
echo "kubectl get rolebindings"
echo "kubectl describe role pod-reader"
echo "kubectl describe rolebinding pod-reader-binding"

# 3. ClusterRole 및 ClusterRoleBinding
echo -e "\n🌐 3. ClusterRole & ClusterRoleBinding 관리"

echo "# ClusterRole 생성"
echo "kubectl create clusterrole cluster-pod-reader --verb=get,list,watch --resource=pods"

echo "# ClusterRoleBinding 생성"
echo "kubectl create clusterrolebinding cluster-pod-reader-binding --clusterrole=cluster-pod-reader --serviceaccount=default:webapp-sa"

echo "# ClusterRole과 ClusterRoleBinding 조회"
echo "kubectl get clusterroles"
echo "kubectl get clusterrolebindings"

# 4. 권한 테스트 및 검증
echo -e "\n✅ 4. 권한 테스트 및 검증"

echo "# 특정 ServiceAccount로 권한 테스트"
echo "kubectl auth can-i get pods --as=system:serviceaccount:default:webapp-sa"
echo "kubectl auth can-i create deployments --as=system:serviceaccount:default:webapp-sa"
echo "kubectl auth can-i delete secrets --as=system:serviceaccount:default:webapp-sa"

echo "# 현재 사용자 권한 확인"
echo "kubectl auth can-i get pods"
echo "kubectl auth can-i create secrets"
echo "kubectl auth can-i '*' '*' --all-namespaces"

echo "# 모든 권한 나열"
echo "kubectl auth can-i --list"
echo "kubectl auth can-i --list --as=system:serviceaccount:default:webapp-sa"

# 5. 실전 시나리오 명령어
echo -e "\n🎯 5. 실전 시나리오"

echo "# 시나리오 1: 읽기 전용 사용자 생성"
echo "kubectl create serviceaccount readonly-sa"
echo "kubectl create role readonly-role --verb=get,list,watch --resource=pods,services,deployments"
echo "kubectl create rolebinding readonly-binding --role=readonly-role --serviceaccount=default:readonly-sa"

echo -e "\n# 시나리오 2: 네임스페이스 관리자 생성"
echo "kubectl create serviceaccount admin-sa"
echo "kubectl create role namespace-admin --verb='*' --resource='*'"
echo "kubectl create rolebinding admin-binding --role=namespace-admin --serviceaccount=default:admin-sa"

echo -e "\n# 시나리오 3: 모니터링 전용 계정 생성"
echo "kubectl create serviceaccount monitoring-sa"
echo "kubectl create clusterrole monitoring-reader --verb=get,list,watch --resource=pods,services,nodes"
echo "kubectl create clusterrolebinding monitoring-binding --clusterrole=monitoring-reader --serviceaccount=default:monitoring-sa"

# 6. 디버깅 및 트러블슈팅
echo -e "\n🔍 6. 디버깅 & 트러블슈팅"

echo "# ServiceAccount 토큰 확인"
echo "kubectl get secrets"
echo "kubectl describe secret \$(kubectl get sa webapp-sa -o jsonpath='{.secrets[0].name}')"

echo "# Pod가 사용하는 ServiceAccount 확인"
echo "kubectl get pod webapp-pod -o jsonpath='{.spec.serviceAccountName}'"

echo "# RBAC 관련 이벤트 확인"
echo "kubectl get events --field-selector reason=Forbidden"

echo "# 특정 리소스에 대한 누가 접근 가능한지 확인"
echo "kubectl auth can-i --list --as=system:serviceaccount:default:webapp-sa"

# 7. 정리 명령어
echo -e "\n🧹 7. 정리"

echo "# 생성한 리소스 정리"
echo "kubectl delete serviceaccount webapp-sa readonly-sa admin-sa monitoring-sa"
echo "kubectl delete role pod-reader readonly-role namespace-admin deployment-manager"
echo "kubectl delete rolebinding pod-reader-binding readonly-binding admin-binding"
echo "kubectl delete clusterrole cluster-pod-reader monitoring-reader"
echo "kubectl delete clusterrolebinding cluster-pod-reader-binding monitoring-binding"

# 8. 유용한 단축 명령어
echo -e "\n⚡ 8. 유용한 단축 명령어"

echo "# kubectl 별칭 설정"
echo "alias k=kubectl"
echo "alias kgs='kubectl get serviceaccounts'"
echo "alias kgr='kubectl get roles'"
echo "alias kgrb='kubectl get rolebindings'"
echo "alias kcani='kubectl auth can-i'"

echo -e "\n# RBAC 관련 자주 사용하는 명령어"
echo "# 모든 ServiceAccount 조회 (모든 네임스페이스)"
echo "kubectl get sa -A"

echo "# 모든 Role과 RoleBinding 조회"
echo "kubectl get roles,rolebindings -A"

echo "# 특정 사용자의 모든 권한 확인"
echo "kubectl auth can-i --list --as=system:serviceaccount:kube-system:default"

echo -e "\n✅ 실습 완료! 이제 RBAC를 활용한 Kubernetes 보안 관리를 마스터했습니다."

# 실습용 데이터 생성 함수
create_demo_resources() {
    echo "=== 데모 리소스 생성 중... ==="
    
    # ServiceAccount 생성
    kubectl create serviceaccount webapp-sa 2>/dev/null || true
    kubectl create serviceaccount readonly-sa 2>/dev/null || true
    
    # Role 생성
    kubectl create role pod-reader --verb=get,list,watch --resource=pods 2>/dev/null || true
    kubectl create role deployment-manager --verb=get,list,watch,create,update,patch --resource=deployments 2>/dev/null || true
    
    # RoleBinding 생성
    kubectl create rolebinding pod-reader-binding --role=pod-reader --serviceaccount=default:webapp-sa 2>/dev/null || true
    kubectl create rolebinding deployment-manager-binding --role=deployment-manager --serviceaccount=default:webapp-sa 2>/dev/null || true
    
    echo "✅ 데모 리소스 생성 완료!"
    echo "📋 생성된 리소스 확인: kubectl get sa,roles,rolebindings"
}

# 데모 리소스 정리 함수
cleanup_demo_resources() {
    echo "=== 데모 리소스 정리 중... ==="
    
    kubectl delete serviceaccount webapp-sa readonly-sa 2>/dev/null || true
    kubectl delete role pod-reader deployment-manager 2>/dev/null || true
    kubectl delete rolebinding pod-reader-binding deployment-manager-binding 2>/dev/null || true
    
    echo "✅ 데모 리소스 정리 완료!"
}

# 스크립트 실행 시 옵션 처리
case "$1" in
    "demo")
        create_demo_resources
        ;;
    "cleanup")
        cleanup_demo_resources
        ;;
    *)
        echo "사용법: $0 [demo|cleanup]"
        echo "  demo    - 실습용 리소스 생성"
        echo "  cleanup - 실습용 리소스 정리"
        ;;
esac