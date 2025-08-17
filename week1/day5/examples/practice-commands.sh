#!/bin/bash
# practice-commands.sh
# 5일차 K8s 리소스 실습 명령어 모음

echo "=== Day 5: K8s 리소스 기초 실습 명령어 ==="
echo

echo "1. Pod 관련 명령어:"
echo "# Pod 생성 (명령어)"
echo "kubectl run nginx-pod --image=nginx --port=80"
echo

echo "# Pod 생성 (YAML)"
echo "kubectl apply -f simple-pod.yaml"
echo

echo "# Pod 조회"
echo "kubectl get pods"
echo "kubectl get pods -o wide"
echo

echo "# Pod 상세 정보"
echo "kubectl describe pod nginx-pod"
echo

echo "# Pod 로그 확인"
echo "kubectl logs nginx-pod"
echo "kubectl logs nginx-pod -f  # 실시간"
echo

echo "# Pod 내부 접속"
echo "kubectl exec -it nginx-pod -- bash"
echo

echo "# Pod 삭제"
echo "kubectl delete pod nginx-pod"
echo

echo "2. Deployment 관련 명령어:"
echo "# Deployment 생성"
echo "kubectl create deployment nginx-deploy --image=nginx --replicas=3"
echo

echo "# Deployment 조회"
echo "kubectl get deployments"
echo "kubectl get deploy"
echo

echo "# 스케일링"
echo "kubectl scale deployment nginx-deploy --replicas=5"
echo

echo "# 롤링 업데이트"
echo "kubectl set image deployment/nginx-deploy nginx=nginx:1.22"
echo

echo "# 롤아웃 상태 확인"
echo "kubectl rollout status deployment/nginx-deploy"
echo

echo "# 롤백"
echo "kubectl rollout undo deployment/nginx-deploy"
echo

echo "3. Service 관련 명령어:"
echo "# Service 노출 (ClusterIP)"
echo "kubectl expose deployment nginx-deploy --port=80"
echo

echo "# Service 노출 (NodePort)"
echo "kubectl expose deployment nginx-deploy --type=NodePort --port=80"
echo

echo "# Service 조회"
echo "kubectl get services"
echo "kubectl get svc"
echo

echo "# 엔드포인트 확인"
echo "kubectl get endpoints"
echo

echo "4. 전체 리소스 조회:"
echo "kubectl get all"
echo

echo "5. 빠른 YAML 생성 (dry-run):"
echo "kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml"
echo "kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml"
echo "kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > service.yaml"
echo

echo "6. 정리:"
echo "kubectl delete deployment nginx-deploy"
echo "kubectl delete service nginx-deploy"
echo "kubectl delete pod nginx-pod"