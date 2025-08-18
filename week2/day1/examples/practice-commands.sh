#!/bin/bash

echo "🎯 ConfigMap 실습 명령어 모음"
echo "================================"

echo ""
echo "1️⃣ ConfigMap 생성 실습"
echo "------------------------"

echo "# 리터럴 값으로 ConfigMap 생성"
echo "kubectl create configmap web-config \\"
echo "  --from-literal=app_name=my-web-app \\"
echo "  --from-literal=version=v1.0.0 \\"
echo "  --from-literal=port=8080"
echo ""

echo "# 파일에서 ConfigMap 생성"
echo "kubectl create configmap nginx-config --from-file=nginx.conf"
echo ""

echo "# YAML 매니페스트로 ConfigMap 적용"
echo "kubectl apply -f app-configmap.yaml"
echo ""

echo "2️⃣ ConfigMap 조회 및 관리"
echo "------------------------"

echo "# 모든 ConfigMap 목록 조회"
echo "kubectl get configmaps"
echo "kubectl get cm"  # 축약형
echo ""

echo "# 특정 ConfigMap 상세 정보"
echo "kubectl describe configmap app-config"
echo ""

echo "# ConfigMap 데이터 내용 확인"
echo "kubectl get configmap app-config -o yaml"
echo "kubectl get configmap app-config -o json"
echo ""

echo "# 특정 키의 값만 확인"
echo "kubectl get configmap app-config -o jsonpath='{.data.database_url}'"
echo ""

echo "# ConfigMap 수정"
echo "kubectl edit configmap app-config"
echo ""

echo "# 새로운 키-값 추가"
echo "kubectl patch configmap app-config -p '{\"data\":{\"new_key\":\"new_value\"}}'"
echo ""

echo "3️⃣ Pod에서 ConfigMap 활용"
echo "------------------------"

echo "# 환경변수로 ConfigMap 사용하는 Pod 생성"
echo "kubectl apply -f pod-with-configmap-env.yaml"
echo ""

echo "# 볼륨으로 ConfigMap 사용하는 Pod 생성"
echo "kubectl apply -f pod-with-configmap-volume.yaml"
echo ""

echo "# Pod에서 환경변수 확인"
echo "kubectl exec app-pod -- env | grep -E \"(DATABASE_URL|LOG_LEVEL|APP_NAME)\""
echo ""

echo "# Pod에서 마운트된 파일 확인"
echo "kubectl exec nginx-pod -- cat /etc/nginx/nginx.conf"
echo "kubectl exec nginx-pod -- ls -la /app/config"
echo "kubectl exec nginx-pod -- cat /app/config/application.properties"
echo ""

echo "4️⃣ 실시간 모니터링 및 문제 해결"
echo "------------------------------"

echo "# ConfigMap 변경사항 실시간 모니터링"
echo "kubectl get configmap app-config -w"
echo ""

echo "# Pod 상태 및 이벤트 확인"
echo "kubectl describe pod app-pod"
echo "kubectl describe pod nginx-pod"
echo ""

echo "# Pod 로그 확인"
echo "kubectl logs app-pod"
echo "kubectl logs nginx-pod"
echo ""

echo "# ConfigMap 변경 후 자동 업데이트 확인 (볼륨 마운트)"
echo "kubectl patch configmap app-config -p '{\"data\":{\"test_setting\":\"updated_value\"}}'"
echo "sleep 10  # 약간의 대기 시간"
echo "kubectl exec nginx-pod -- ls -la /app/config"
echo "kubectl exec nginx-pod -- cat /app/config/test_setting"
echo ""

echo "5️⃣ 정리 명령어"
echo "---------------"

echo "# Pod 삭제"
echo "kubectl delete pod app-pod nginx-pod"
echo ""

echo "# ConfigMap 삭제"
echo "kubectl delete configmap web-config nginx-config app-config"
echo ""

echo "6️⃣ 고급 사용법"
echo "---------------"

echo "# ConfigMap을 사용하는 Pod 빠른 생성 (dry-run 활용)"
echo "kubectl create configmap quick-config --from-literal=key1=value1 --dry-run=client -o yaml > quick-configmap.yaml"
echo ""

echo "# 특정 키만 선택해서 환경변수로 사용"
echo "kubectl run test-pod --image=busybox --env=\"VAR1=value1\" --dry-run=client -o yaml > test-pod.yaml"
echo "# 이후 ConfigMap 참조로 수정"
echo ""

echo "# ConfigMap의 특정 키 삭제"
echo "kubectl patch configmap app-config --type=json -p='[{\"op\": \"remove\", \"path\": \"/data/old_key\"}]'"
echo ""

echo "✅ 모든 실습 명령어를 확인했습니다!"
echo "실제 명령어를 실행해보세요! 🚀"
