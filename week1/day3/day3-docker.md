# Day 3: Docker 복습 (이미지 빌드, run, exec, logs, volume, network)

## 🎯 학습 목표 (25분)
CKA/CKAD 시험에서 필요한 Docker의 핵심 기능들을 복습하고, Kubernetes 환경에서 컨테이너가 어떻게 동작하는지 이해합니다.

---

## 1️⃣ Docker 기본 개념 복습 (3분)

### Docker vs Kubernetes
```bash
# Docker: 단일 호스트에서 컨테이너 관리
docker run nginx

# Kubernetes: 클러스터에서 컨테이너 오케스트레이션
kubectl run nginx --image=nginx
```

### 중요한 이유
- K8s Pod는 하나 이상의 컨테이너로 구성
- 컨테이너 문제 해결 시 Docker 명령어 필요
- 이미지 빌드와 관리는 CI/CD 파이프라인의 기본

---

## 2️⃣ 이미지 빌드 (5분)

### Dockerfile 작성
```dockerfile
# examples/Dockerfile
FROM alpine:3.18
LABEL maintainer="cka-student"
RUN apk add --no-cache curl
WORKDIR /app
COPY app.sh /app/
RUN chmod +x /app/app.sh
EXPOSE 8080
CMD ["./app.sh"]
```

### 이미지 빌드
```bash
# 기본 빌드
docker build -t myapp:v1.0 .

# 태그 지정하여 빌드
docker build -t myapp:latest -t myapp:v1.0 .

# 빌드 컨텍스트 지정
docker build -f custom.Dockerfile -t myapp:custom ./context-dir

# 빌드 인수 사용
docker build --build-arg VERSION=1.0 -t myapp:v1.0 .
```

### 이미지 관리
```bash
# 이미지 목록 확인
docker images
docker image ls

# 이미지 삭제
docker rmi myapp:v1.0

# 사용하지 않는 이미지 정리
docker image prune
docker image prune -a  # 모든 dangling 이미지 삭제
```

---

## 3️⃣ 컨테이너 실행 (5분)

### docker run 옵션
```bash
# 기본 실행
docker run nginx

# 백그라운드 실행 (-d, --detach)
docker run -d nginx

# 포트 매핑 (-p, --publish)
docker run -d -p 8080:80 nginx

# 이름 지정 (--name)
docker run -d --name my-nginx -p 8080:80 nginx

# 환경 변수 설정 (-e, --env)
docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

# 자동 삭제 (--rm)
docker run --rm ubuntu echo "Hello World"

# 인터랙티브 모드 (-it)
docker run -it ubuntu bash

# 메모리/CPU 제한
docker run -d --memory=512m --cpus=0.5 nginx
```

### 컨테이너 관리
```bash
# 실행 중인 컨테이너 목록
docker ps

# 모든 컨테이너 목록 (중지된 것 포함)
docker ps -a

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 시작
docker start my-nginx

# 컨테이너 재시작
docker restart my-nginx

# 컨테이너 삭제
docker rm my-nginx

# 강제 삭제 (실행 중인 컨테이너도)
docker rm -f my-nginx
```

---

## 4️⃣ 컨테이너 조작 (4분)

### docker exec - 실행 중인 컨테이너에 명령 실행
```bash
# 쉘 접속
docker exec -it my-nginx bash
docker exec -it my-nginx sh

# 단일 명령 실행
docker exec my-nginx ls -la
docker exec my-nginx ps aux

# 루트 권한으로 실행
docker exec -u root my-nginx cat /etc/passwd

# 작업 디렉토리 지정
docker exec -w /tmp my-nginx pwd
```

### docker logs - 로그 확인
```bash
# 로그 확인
docker logs my-nginx

# 실시간 로그 따라가기 (-f, --follow)
docker logs -f my-nginx

# 최근 줄 수 제한 (--tail)
docker logs --tail 50 my-nginx

# 타임스탬프 표시 (-t, --timestamps)
docker logs -t my-nginx

# 특정 시간 이후 로그
docker logs --since "2024-01-01T00:00:00" my-nginx
docker logs --since "1h" my-nginx
```

---

## 5️⃣ 볼륨 (Volume) (4분)

### 볼륨 타입
```bash
# 1. 익명 볼륨 (Anonymous Volume)
docker run -d -v /var/lib/mysql mysql:8.0

# 2. 명명된 볼륨 (Named Volume)
docker volume create mydata
docker run -d -v mydata:/var/lib/mysql mysql:8.0

# 3. 바인드 마운트 (Bind Mount)
docker run -d -v /host/path:/container/path nginx
docker run -d -v $(pwd)/html:/usr/share/nginx/html nginx

# 4. 읽기 전용 마운트
docker run -d -v $(pwd)/config:/etc/config:ro nginx
```

### 볼륨 관리
```bash
# 볼륨 생성
docker volume create app-data

# 볼륨 목록 확인
docker volume ls

# 볼륨 상세 정보
docker volume inspect app-data

# 볼륨 삭제
docker volume rm app-data

# 사용하지 않는 볼륨 정리
docker volume prune
```

### 실용적인 볼륨 사용 예시
```bash
# 웹 서버 파일 공유
docker run -d --name web -v $(pwd)/website:/usr/share/nginx/html:ro -p 8080:80 nginx

# 데이터베이스 데이터 영구 저장
docker run -d --name mysql -v mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

# 로그 파일 호스트에서 확인
docker run -d --name app -v /var/log/myapp:/app/logs myapp:latest
```

---

## 6️⃣ 네트워킹 (4분)

### 네트워크 타입
```bash
# 1. bridge (기본값)
docker run -d --network bridge nginx

# 2. host - 호스트 네트워크 직접 사용
docker run -d --network host nginx

# 3. none - 네트워크 없음
docker run -d --network none alpine sleep 3600

# 4. 사용자 정의 네트워크
docker network create mynetwork
docker run -d --network mynetwork --name web nginx
```

### 네트워크 관리
```bash
# 네트워크 생성
docker network create --driver bridge myapp-network

# 네트워크 목록 확인
docker network ls

# 네트워크 상세 정보
docker network inspect bridge

# 실행 중인 컨테이너를 네트워크에 연결
docker network connect myapp-network my-container

# 네트워크에서 컨테이너 분리
docker network disconnect myapp-network my-container

# 네트워크 삭제
docker network rm myapp-network
```

### 컨테이너 간 통신
```bash
# 같은 네트워크의 컨테이너들은 서로 통신 가능
docker network create app-net

# 데이터베이스 컨테이너 실행
docker run -d --network app-net --name mysql \
  -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

# 웹 앱 컨테이너 실행 (mysql 컨테이너와 통신)
docker run -d --network app-net --name webapp \
  -e DB_HOST=mysql -p 8080:80 mywebapp:latest
```

---

## 💡 CKA/CKAD 시험 팁

### 1. 컨테이너 문제 해결
```bash
# Pod 내 컨테이너 디버깅
kubectl exec -it pod-name -c container-name -- bash

# 컨테이너 로그 확인
kubectl logs pod-name -c container-name

# 컨테이너 상태 확인
kubectl describe pod pod-name
```

### 2. 이미지 관련 문제
```bash
# 이미지 존재 여부 확인
docker pull image-name:tag

# 이미지 레이어 확인
docker history image-name

# 이미지 정보 확인
docker inspect image-name
```

### 3. 리소스 사용량 확인
```bash
# 컨테이너 리소스 사용량
docker stats

# 특정 컨테이너만 확인
docker stats container-name
```

---

## 🔍 실습 명령어

### 예시 파일 활용
실습용 파일들이 `examples/` 폴더에 준비되어 있습니다:
- `Dockerfile`: 샘플 웹 애플리케이션 이미지 빌드용
- `app.sh`: 간단한 웹 서버 스크립트
- `docker-compose.yml`: 멀티 컨테이너 앱 구성
- `nginx.conf`: Nginx 설정 파일

### 기본 실습
```bash
# 1. 이미지 빌드
cd examples/
docker build -t myapp:v1.0 .

# 2. 컨테이너 실행
docker run -d --name myapp -p 8080:8080 myapp:v1.0

# 3. 로그 확인
docker logs -f myapp

# 4. 컨테이너 내부 접속
docker exec -it myapp sh

# 5. 파일 공유 실습
docker run -d --name nginx-shared \
  -v $(pwd)/html:/usr/share/nginx/html:ro \
  -p 8081:80 nginx

# 6. 네트워크 실습
docker network create test-net
docker run -d --network test-net --name db alpine sleep 3600
docker run -it --network test-net alpine ping db
```

### 고급 실습
```bash
# 7. 멀티 스테이지 빌드 테스트
docker build -f Dockerfile.multi -t optimized-app .
docker images | grep optimized-app

# 8. 헬스체크 실습
docker run -d --name app-with-health \
  --health-cmd="curl -f http://localhost:8080/health || exit 1" \
  --health-interval=30s myapp:v1.0

# 9. 리소스 제한 테스트
docker run -d --name limited-app \
  --memory=128m --cpus=0.5 myapp:v1.0

# 10. 환경 변수와 시크릿 실습
docker run -d --name secure-app \
  -e APP_ENV=production \
  -e DB_PASSWORD_FILE=/run/secrets/db_password \
  -v $(pwd)/secrets:/run/secrets:ro myapp:v1.0
```

### Docker Compose 실습
```bash
# 11. 멀티 컨테이너 앱 실행
docker-compose up -d

# 12. 컨테이너 확인
docker-compose ps

# 13. 로그 확인
docker-compose logs -f web

# 14. 스케일링
docker-compose up -d --scale web=3

# 15. 정리
docker-compose down
```

### 리소스 정리 실습
```bash
# 16. 모든 실습 컨테이너 정리
docker stop $(docker ps -q --filter "name=myapp*")
docker rm $(docker ps -aq --filter "name=myapp*")

# 17. 사용하지 않는 이미지 정리
docker image prune -f

# 18. 사용하지 않는 볼륨 정리
docker volume prune -f

# 19. 사용하지 않는 네트워크 정리
docker network prune -f

# 20. 전체 시스템 정리 (주의: 모든 사용하지 않는 리소스 삭제)
docker system prune -a -f --volumes

# 21. 디스크 사용량 확인
docker system df

# 22. 특정 리소스만 선별적으로 정리
# 중지된 컨테이너만 삭제
docker container prune -f

# 태그가 없는 이미지(dangling)만 삭제
docker image prune -f

# 특정 라벨을 가진 컨테이너만 삭제
docker rm $(docker ps -aq --filter "label=env=test")

# 특정 시간 이전에 생성된 컨테이너 정리
docker container prune --filter "until=24h" -f
```

---

## 🔗 Kubernetes와의 연결점

### Pod 내 컨테이너 이해
```yaml
# Pod는 하나 이상의 컨테이너를 포함
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: web
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: sidecar
    image: busybox
    command: ['sh', '-c', 'echo Hello > /data/index.html && sleep 3600']
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

### 컨테이너 라이프사이클 이해
- **Init Container**: 메인 컨테이너 시작 전 실행
- **Main Container**: 애플리케이션 컨테이너
- **Sidecar Container**: 보조 기능 제공

학습 완료! 이제 퀴즈를 풀어보세요 🎯