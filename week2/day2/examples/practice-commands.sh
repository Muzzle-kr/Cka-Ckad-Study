#!/bin/bash

echo "🔐 Secret 관리 실습 명령어 모음"
echo "================================"

echo ""
echo "1️⃣ Secret 생성 실습"
echo "-------------------"

echo "# Generic Secret 생성 (리터럴 값)"
echo "kubectl create secret generic db-secret \\"
echo "  --from-literal=username=admin \\"
echo "  --from-literal=password=super-secret-password \\"
echo "  --from-literal=api-key=abc123xyz789"
echo ""

echo "# 파일에서 Secret 생성"
echo "echo -n 'admin' > username.txt"
echo "echo -n 'super-secret-password' > password.txt"
echo "kubectl create secret generic file-secret --from-file=username.txt --from-file=password.txt"
echo ""

echo "# Docker Registry Secret 생성"
echo "kubectl create secret docker-registry my-registry-secret \\"
echo "  --docker-server=docker.io \\"
echo "  --docker-username=myusername \\"
echo "  --docker-password=mypassword \\"
echo "  --docker-email=my.email@example.com"
echo ""

echo "# YAML 매니페스트로 Secret 적용"
echo "kubectl apply -f app-secret.yaml"
echo ""

echo "2️⃣ TLS Secret 생성 실습"
echo "----------------------"

echo "# 개인키 생성"
echo "openssl genrsa -out server.key 2048"
echo ""

echo "# 인증서 서명 요청(CSR) 생성"
echo "openssl req -new -key server.key -out server.csr \\"
echo "  -subj \"/CN=my-app.example.com/O=MyOrg/C=US\""
echo ""

echo "# 자체 서명 인증서 생성"
echo "openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365"
echo ""

echo "# TLS Secret 생성"
echo "kubectl create secret tls my-tls-secret --cert=server.crt --key=server.key"
echo ""

echo "3️⃣ Secret 조회 및 관리"
echo "--------------------"

echo "# 모든 Secret 목록 조회"
echo "kubectl get secrets"
echo "kubectl get secret"  # 축약형
echo ""

echo "# 특정 Secret 상세 정보"
echo "kubectl describe secret db-secret"
echo ""

echo "# Secret 데이터 내용 확인 (Base64 인코딩된 상태)"
echo "kubectl get secret db-secret -o yaml"
echo "kubectl get secret db-secret -o json"
echo ""

echo "# 특정 키의 값 디코딩해서 확인"
echo "kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""

echo "# 모든 키-값 디코딩 (go-template 사용)"
echo "kubectl get secret db-secret -o go-template='{{range \$k,\$v := .data}}{{printf \"%s: \" \$k}}{{if not \$v}}{{\$v}}{{else}}{{\$v | base64decode}}{{end}}{{\"\\n\"}}{{end}}'"
echo ""

echo "# Secret 수정"
echo "kubectl edit secret db-secret"
echo ""

echo "# 새로운 키-값 추가 (stringData 사용)"
echo "kubectl patch secret db-secret -p '{\"stringData\":{\"new-key\":\"new-value\"}}'"
echo ""

echo "4️⃣ Pod에서 Secret 활용"
echo "---------------------"

echo "# 환경변수로 Secret 사용하는 Pod 생성"
echo "kubectl apply -f pod-with-secret-env.yaml"
echo ""

echo "# 볼륨으로 Secret 사용하는 Pod 생성"
echo "kubectl apply -f pod-with-secret-volume.yaml"
echo ""

echo "# Private 이미지 사용하는 Pod 생성"
echo "kubectl apply -f pod-with-private-image.yaml"
echo ""

echo "# TLS Secret을 사용하는 Ingress 생성"
echo "kubectl apply -f ingress-with-tls.yaml"
echo ""

echo "5️⃣ Secret 값 확인 및 검증"
echo "------------------------"

echo "# Pod에서 환경변수 확인"
echo "kubectl exec app-pod-with-secret -- env | grep -E \"(DB_USERNAME|DB_PASSWORD|API_KEY)\""
echo ""

echo "# Pod에서 마운트된 Secret 파일 확인"
echo "kubectl exec nginx-pod-with-secret -- ls -la /etc/secrets"
echo "kubectl exec nginx-pod-with-secret -- cat /etc/secrets/username"
echo "kubectl exec nginx-pod-with-secret -- cat /etc/api/key"
echo ""

echo "# TLS 인증서 파일 확인"
echo "kubectl exec nginx-pod-with-secret -- openssl x509 -in /etc/ssl/certs/server.crt -text -noout"
echo ""

echo "6️⃣ Base64 인코딩/디코딩 실습"
echo "---------------------------"

echo "# Base64 인코딩"
echo "echo -n 'my-secret-value' | base64"
echo ""

echo "# Base64 디코딩"
echo "echo 'bXktc2VjcmV0LXZhbHVl' | base64 -d"
echo ""

echo "# Secret 생성 시 자동 인코딩 확인"
echo "kubectl create secret generic test-secret --from-literal=password=mysecret --dry-run=client -o yaml"
echo ""

echo "7️⃣ 보안 검증 및 문제 해결"
echo "------------------------"

echo "# Secret 접근 권한 확인"
echo "kubectl auth can-i get secrets"
echo "kubectl auth can-i get secrets --as=system:serviceaccount:default:default"
echo ""

echo "# Pod 상태 및 이벤트 확인"
echo "kubectl describe pod app-pod-with-secret"
echo "kubectl describe pod nginx-pod-with-secret"
echo ""

echo "# Pod 로그 확인"
echo "kubectl logs app-pod-with-secret"
echo "kubectl logs nginx-pod-with-secret"
echo ""

echo "# Secret 마운트 실패 시 확인사항"
echo "kubectl get events --sort-by=.metadata.creationTimestamp"
echo ""

echo "8️⃣ 정리 명령어"
echo "---------------"

echo "# 생성된 파일 정리"
echo "rm -f username.txt password.txt server.key server.csr server.crt"
echo ""

echo "# Pod 삭제"
echo "kubectl delete pod app-pod-with-secret nginx-pod-with-secret private-image-pod"
echo ""

echo "# Secret 삭제"
echo "kubectl delete secret db-secret file-secret my-registry-secret my-tls-secret app-secret app-secret-v2 docker-registry-secret"
echo ""

echo "# Ingress 및 Service 삭제"
echo "kubectl delete ingress my-app-ingress"
echo "kubectl delete service my-app-service my-app-api-service my-app-admin-service"
echo ""

echo "9️⃣ 고급 사용법"
echo "---------------"

echo "# Secret을 사용하는 Pod 빠른 생성 (dry-run 활용)"
echo "kubectl create secret generic quick-secret --from-literal=key1=value1 --dry-run=client -o yaml > quick-secret.yaml"
echo ""

echo "# 기존 Secret을 다른 네임스페이스로 복사"
echo "kubectl get secret db-secret -o yaml | sed 's/namespace: default/namespace: production/' | kubectl apply -f -"
echo ""

echo "# Secret 값 검증 스크립트"
echo "for secret in \$(kubectl get secrets -o name); do"
echo "  echo \"Checking \$secret:\""
echo "  kubectl get \$secret -o jsonpath='{.data}' | base64 -d 2>/dev/null || echo \"Invalid base64\""
echo "done"
echo ""

echo "✅ 모든 Secret 관리 명령어를 확인했습니다!"
echo "실제 명령어를 실행해보세요! 🔐"
