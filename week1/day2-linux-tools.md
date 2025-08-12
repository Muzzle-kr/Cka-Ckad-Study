# Day 2: Linux 필수 도구 (grep, awk, sed, find, tar, systemctl, journalctl)

## 🎯 학습 목표 (20분)
CKA/CKAD 시험에서 자주 사용되는 Linux 도구들의 핵심 기능과 옵션을 익힙니다.

---

## 1️⃣ grep - 텍스트 검색 (5분)

### 기본 문법
```bash
grep [옵션] "패턴" 파일명
```

### 주요 옵션
```bash
# 기본 검색
grep "error" /var/log/syslog

# 대소문자 구분 없이 검색
grep -i "ERROR" /var/log/syslog

# 줄 번호 표시
grep -n "failed" /var/log/syslog

# 재귀적 검색 (디렉토리 내 모든 파일)
grep -r "kubectl" /etc/

# 역방향 검색 (패턴이 없는 줄)
grep -v "success" /var/log/app.log

# 여러 패턴 검색
grep -E "error|failed|warning" /var/log/syslog
```

### K8s에서 활용 예시
```bash
# Pod 로그에서 에러 찾기
kubectl logs my-pod | grep -i error

# 특정 네임스페이스의 리소스 찾기
kubectl get pods -A | grep kube-system
```

---

## 2️⃣ awk - 텍스트 처리 (5분)

### 기본 문법
```bash
awk '패턴 { 액션 }' 파일명
```

### 핵심 사용법
```bash
# 특정 컬럼 출력 (공백 기준)
awk '{print $1, $3}' file.txt

# 첫 번째 컬럼이 특정 값인 행만 출력
awk '$1 == "Running" {print $0}' pods.txt

# 조건부 출력
awk 'NR > 1 {print $1}' file.txt  # 첫 줄 제외하고 첫 컬럼 출력

# 구분자 지정
awk -F: '{print $1}' /etc/passwd  # : 기준으로 분할

# 계산
awk '{sum += $3} END {print sum}' numbers.txt
```

### K8s에서 활용 예시
```bash
# Pod 이름만 추출
kubectl get pods | awk 'NR>1 {print $1}'

# Running 상태인 Pod만 출력
kubectl get pods | awk '$3=="Running" {print $1}'
```

---

## 3️⃣ sed - 스트림 편집기 (5분)

### 기본 문법
```bash
sed '명령어' 파일명
```

### 주요 명령어
```bash
# 문자열 치환 (첫 번째 매치만)
sed 's/old/new/' file.txt

# 문자열 치환 (모든 매치)
sed 's/old/new/g' file.txt

# 특정 줄 삭제
sed '2d' file.txt          # 2번째 줄 삭제
sed '/pattern/d' file.txt  # 패턴 매치하는 줄 삭제

# 특정 줄만 출력
sed -n '1,5p' file.txt     # 1-5줄만 출력

# 파일 직접 수정
sed -i 's/old/new/g' file.txt
```

### K8s에서 활용 예시
```bash
# YAML에서 이미지 태그 변경
sed 's/image:.*nginx.*/image: nginx:1.20/' deployment.yaml

# 네임스페이스 변경
sed 's/namespace:.*/namespace: production/' resource.yaml
```

---

## 4️⃣ find - 파일 검색 (3분)

### 기본 문법
```bash
find [경로] [조건]
```

### 주요 사용법
```bash
# 이름으로 검색
find /etc -name "*.conf"

# 타입으로 검색
find /var/log -type f -name "*.log"

# 시간 기준 검색
find /tmp -mtime +7        # 7일 이전 수정된 파일
find /var/log -mtime -1    # 1일 이내 수정된 파일

# 크기 기준 검색
find /var -size +100M      # 100MB 이상 파일

# 실행 권한이 있는 파일
find /usr/bin -perm +x
```

---

## 5️⃣ tar - 압축/아카이브 (2분)

### 주요 옵션
```bash
# 압축하기
tar -czf archive.tar.gz directory/    # gzip 압축
tar -cjf archive.tar.bz2 directory/   # bzip2 압축

# 압축 풀기
tar -xzf archive.tar.gz
tar -xjf archive.tar.bz2

# 내용 확인
tar -tzf archive.tar.gz    # 파일 목록 보기
tar -xzf archive.tar.gz -C /target/   # 특정 디렉토리에 압축 풀기
```

---

## 6️⃣ systemctl & journalctl - 시스템 관리 (5분)

### systemctl - 서비스 관리
```bash
# 서비스 상태 확인
systemctl status kubelet
systemctl status docker

# 서비스 시작/중지/재시작
systemctl start kubelet
systemctl stop kubelet
systemctl restart kubelet

# 부팅시 자동 실행 설정
systemctl enable kubelet
systemctl disable kubelet

# 모든 서비스 목록
systemctl list-units --type=service
```

### journalctl - 로그 확인
```bash
# 특정 서비스 로그 확인
journalctl -u kubelet
journalctl -u docker

# 최근 로그 확인
journalctl -f              # 실시간 로그
journalctl --since "1 hour ago"
journalctl --since "2023-01-01"

# 로그 레벨 필터
journalctl -p err          # 에러 레벨 이상만
journalctl -p warning      # 경고 레벨 이상만
```

---

## 💡 CKA/CKAD 시험 팁

1. **grep + kubectl 조합**: 로그에서 에러 찾을 때 필수
2. **awk로 컬럼 추출**: kubectl 출력에서 원하는 정보만 뽑기
3. **sed로 YAML 수정**: 빠른 설정 변경
4. **journalctl로 문제 진단**: 시스템/서비스 문제 해결
5. **find로 설정 파일 찾기**: kubeconfig, 인증서 등 위치 확인

---

## 🔍 실습 명령어

### 예시 파일 활용
실습용 파일들이 `examples/` 폴더에 준비되어 있습니다:
- `sample-log.txt`: 애플리케이션 로그 샘플
- `pod-status.txt`: kubectl get pods 출력 예시
- `users.txt`: 콜론 구분자 텍스트 파일
- `deployment.yaml`: K8s 매니페스트 파일

### 실습 명령어
```bash
# 1. 로그 파일에서 ERROR 찾기
grep -i error examples/sample-log.txt

# 2. Pod 상태에서 이름만 추출
awk 'NR>1 {print $1}' examples/pod-status.txt

# 3. Running 상태인 Pod만 출력
awk '$3=="Running" {print $1, $3}' examples/pod-status.txt

# 4. 사용자 파일에서 developer만 추출
awk -F: '$2=="developer" {print $1}' examples/users.txt

# 5. YAML에서 이미지 태그 변경
sed 's/nginx:latest/nginx:1.20/g' examples/deployment.yaml

# 6. 로그에서 WARNING과 ERROR만 찾기
grep -E "WARNING|ERROR" examples/sample-log.txt

# 7. 첫 5줄만 출력
sed -n '1,5p' examples/sample-log.txt

# 8. kubelet 서비스 상태 확인 (실제 시스템)
systemctl status kubelet

# 9. kubelet 로그 확인 (실제 시스템)
journalctl -u kubelet --since "10 minutes ago"
```

학습 완료! 이제 퀴즈를 풀어보세요 🎯