# Day 2: Secret 관리

## 🎯 학습 목표 (30분)
Secret의 개념을 이해하고 다양한 타입의 Secret을 생성, 관리하는 방법을 익힙니다. Pod에서 Secret을 안전하게 활용하는 방법과 TLS 인증서 관리를 실습합니다.

---

## 1️⃣ Secret이란? (5분)

### 개념
**Secret**은 Kubernetes에서 민감한 정보를 안전하게 저장하고 관리하는 리소스입니다.
- 비밀번호, API 키, 인증서 등 민감한 데이터 저장
- Base64로 인코딩되어 저장 (암호화 아님)
- etcd에서 추가 암호화 설정 가능
- ConfigMap과 유사한 사용법, 보안 강화

### ConfigMap vs Secret 비교
```yaml
# 사용 구분
ConfigMap: 비민감한 설정 데이터
- 데이터베이스 URL (비밀번호 제외)
- 애플리케이션 설정값
- 로그 레벨, 포트 번호 등

Secret: 민감한 보안 데이터  
- 데이터베이스 비밀번호
- API 키, 토큰
- TLS 인증서 및 개인키
- Docker 레지스트리 인증 정보
```

---

## 2️⃣ Secret 타입 및 생성 방법 (10분)

### 1. Generic Secret (범용)
```bash
# 리터럴 값으로 생성
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=super-secret-password \
  --from-literal=api-key=abc123xyz789

# 파일에서 생성
echo -n 'admin' > username.txt
echo -n 'super-secret-password' > password.txt
kubectl create secret generic db-secret --from-file=username.txt --from-file=password.txt

# 환경 파일에서 생성
kubectl create secret generic app-secret --from-env-file=.env
```

### 2. Docker Registry Secret
```bash
# Docker Hub 인증 정보
kubectl create secret docker-registry my-registry-secret \
  --docker-server=docker.io \
  --docker-username=myusername \
  --docker-password=mypassword \
  --docker-email=my.email@example.com

# Private Registry 인증 정보
kubectl create secret docker-registry private-registry \
  --docker-server=my-registry.com \
  --docker-username=admin \
  --docker-password=admin123
```

### 3. TLS Secret
```bash
# TLS 인증서와 개인키로 생성
kubectl create secret tls my-tls-secret \
  --cert=server.crt \
  --key=server.key

# Let's Encrypt 등에서 발급받은 인증서 사용
kubectl create secret tls letsencrypt-secret \
  --cert=fullchain.pem \
  --key=privkey.pem
```

### 4. YAML 매니페스트로 생성
```yaml
# secret-example.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
  namespace: default
type: Opaque
data:
  # Base64로 인코딩된 값
  username: YWRtaW4=        # admin
  password: cGFzc3dvcmQ=    # password
  api-key: YWJjMTIzeHl6Nzg5  # abc123xyz789

---
# stringData 사용 (자동 Base64 인코딩)
apiVersion: v1
kind: Secret
metadata:
  name: app-secret-v2
type: Opaque
stringData:
  username: admin
  password: password
  api-key: abc123xyz789
```

---

## 3️⃣ Secret 조회 및 관리 (5분)

### 조회 명령어
```bash
# 모든 Secret 목록
kubectl get secrets
kubectl get secret  # 축약형

# 특정 Secret 상세 정보 (데이터는 숨김)
kubectl describe secret app-secret

# Secret 데이터 확인 (Base64 인코딩된 상태)
kubectl get secret app-secret -o yaml
kubectl get secret app-secret -o json

# 특정 키의 값 디코딩해서 확인
kubectl get secret app-secret -o jsonpath='{.data.password}' | base64 -d

# 모든 키-값 디코딩
kubectl get secret app-secret -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
```

### 수정 및 삭제
```bash
# Secret 수정 (대화형 편집기)
kubectl edit secret app-secret

# 새로운 키-값 추가 (Base64 인코딩 필요)
kubectl patch secret app-secret -p '{"data":{"new-key":"bmV3LXZhbHVl"}}'  # new-value

# stringData로 추가 (자동 인코딩)
kubectl patch secret app-secret -p '{"stringData":{"new-key":"new-value"}}'

# Secret 삭제
kubectl delete secret app-secret
```

---

## 4️⃣ Pod에서 Secret 활용 (7분)

### 1. 환경변수로 사용
```yaml
# pod-with-secret-env.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: nginx:latest
    env:
    # 개별 키를 환경변수로
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: password
    # 모든 키를 환경변수로
    envFrom:
    - secretRef:
        name: db-secret
        optional: false
```

### 2. 볼륨으로 마운트
```yaml
# pod-with-secret-volume.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    # Secret을 파일로 마운트
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
    # 특정 키만 특정 경로에 마운트
    - name: tls-volume
      mountPath: /etc/ssl/certs/server.crt
      subPath: tls.crt
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secret
      defaultMode: 0400  # 읽기 전용
  - name: tls-volume
    secret:
      secretName: my-tls-secret
      items:
      - key: tls.crt
        path: tls.crt
```

### 3. Docker Registry Secret 사용
```yaml
# pod-with-private-image.yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  containers:
  - name: app
    image: my-registry.com/private/app:latest
  # Private 이미지 Pull을 위한 Secret
  imagePullSecrets:
  - name: my-registry-secret
```

---

## 5️⃣ TLS 인증서 관리 실습 (3분)

### 자체 서명 인증서 생성 및 활용
```bash
# 1단계: 개인키 생성
openssl genrsa -out server.key 2048

# 2단계: 인증서 서명 요청(CSR) 생성
openssl req -new -key server.key -out server.csr -subj "/CN=my-app.example.com"

# 3단계: 자체 서명 인증서 생성
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365

# 4단계: TLS Secret 생성
kubectl create secret tls my-app-tls --cert=server.crt --key=server.key

# 5단계: Ingress에서 TLS Secret 사용
```

### Ingress에서 TLS Secret 활용
```yaml
# ingress-with-tls.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
spec:
  tls:
  - hosts:
    - my-app.example.com
    secretName: my-app-tls
  rules:
  - host: my-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

---

## 6️⃣ 보안 모범 사례 및 주의사항

### 보안 모범 사례
```bash
# 1. Secret 최소 권한 원칙
- 필요한 Pod에만 Secret 접근 허용
- RBAC로 Secret 접근 제어
- 네임스페이스별 Secret 분리

# 2. Secret 로테이션
- 정기적인 비밀번호/키 교체
- 자동화된 Secret 업데이트
- 이전 Secret 안전한 삭제

# 3. 암호화 강화
- etcd 암호화 활성화
- 전송 중 암호화 (TLS)
- 저장 시 암호화 (Encryption at Rest)
```

### 주의사항
```yaml
주의점:
1. Base64는 암호화가 아닌 인코딩 (누구나 디코딩 가능)
2. Secret은 1MB 이하로 제한
3. 환경변수는 Pod 재시작 필요, 볼륨은 자동 업데이트
4. 로그에 Secret 값이 노출되지 않도록 주의
5. Kubernetes API 접근 권한이 있으면 Secret 확인 가능
```

### 문제 해결
```bash
# Secret이 Pod에 제대로 마운트되지 않을 때
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# Secret 값 확인 (디버깅용)
kubectl get secret <name> -o jsonpath='{.data}' | base64 -d

# Secret 권한 문제 확인
kubectl auth can-i get secrets --as=system:serviceaccount:default:default
```

---

## 📋 학습 정리

### 핵심 명령어
```bash
# Secret 생성
kubectl create secret generic <name> --from-literal=key=value
kubectl create secret docker-registry <name> --docker-server=... --docker-username=...
kubectl create secret tls <name> --cert=cert.crt --key=cert.key
kubectl apply -f secret.yaml

# Secret 조회
kubectl get secrets
kubectl describe secret <name>
kubectl get secret <name> -o yaml

# Secret 값 확인 (Base64 디코딩)
kubectl get secret <name> -o jsonpath='{.data.key}' | base64 -d

# Secret 수정/삭제
kubectl edit secret <name>
kubectl patch secret <name> -p '{"stringData":{"key":"value"}}'
kubectl delete secret <name>
```

### Secret vs ConfigMap 사용 기준
| 구분 | ConfigMap | Secret |
|------|-----------|--------|
| 데이터 타입 | 비민감한 설정 | 민감한 보안 정보 |
| 저장 방식 | 평문 | Base64 인코딩 |
| 사용 예시 | DB URL, 포트, 로그레벨 | 비밀번호, API 키, 인증서 |
| 접근 제어 | 일반적 | 엄격한 RBAC 필요 |

### 다음 단계
- **Day 3**: ServiceAccount & RBAC - 권한 기반 접근 제어
- **실습 포인트**: Secret과 RBAC를 결합한 보안 설정

---

## 🔗 참고 자료
- [Kubernetes Secret 공식 문서](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Secret 보안 모범 사례](https://kubernetes.io/docs/concepts/security/secrets-good-practices/)
