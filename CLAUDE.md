# CKA/CKAD 자격증 공부 계획 (4개월)

## 전체 목표
- **CKA 시험**: 8주차 응시 예정
- **CKAD 시험**: 16주차 응시 예정
- **학습 기간**: 총 4개월 (16주)

---

## 📅 16주 학습 계획

| 주차 | 목표 | 세부 학습 내용 | 비고 | 진행 여부 |
|------|------|---------------|------|-----------|
| 1 | 리눅스 & K8s 기본기 | 리눅스 명령어(grep, awk, sed 등), Docker 복습, kubectl 기본 명령어, Pod/Deployment/Service | 로컬 클러스터(minikube/kind) | ⏳ |
| 2 | K8s 핵심 리소스 | ConfigMap, Secret, ServiceAccount, Role/RoleBinding, Probe 설정 | 리소스 생성/적용 연습 | ⏸️ |
| 3 | 스토리지 & 네트워크 | PV/PVC, StorageClass, ClusterIP, NodePort, LoadBalancer, NetworkPolicy | Pod 간 통신 제어 실습 | ⏸️ |
| 4 | 운영 관리 | etcd 백업/복원, kubeconfig 관리, 노드 cordon/drain, taint/toleration | 클러스터 구성 이해 | ⏸️ |
| 5 | Helm & Troubleshooting | Helm 기본, 설치/업데이트, Pod/노드 상태 분석, 로그 분석 | K8s 문제 해결 패턴 | ⏸️ |
| 6 | 모의시험 1회차 | CKA 모의고사(Killer.sh/KodeKloud) 풀기, 오답 정리 | 실전 시간 관리 훈련 | ⏸️ |
| 7 | 모의시험 2회차 & 복습 | 모의고사 재도전, 취약 영역 집중 학습 | 시험 환경 단축키 연습 | ⏸️ |
| 8 | **🎯 CKA 시험 응시** | 실제 시험 응시, 응시 후 오답 기록 | 합격 후 CKAD 전환 준비 | ⏸️ |
| 9 | CKAD 개념 전환 | Multi-container Pod 패턴, Resource Requests/Limits, Job/CronJob | 앱 배포 중심 학습 | ⏸️ |
| 10 | 애플리케이션 심화 | Probes, InitContainer, Lifecycle Hooks, 환경변수 주입 | Pod 동작 제어 | ⏸️ |
| 11 | 서비스 & 설정관리 | Service Discovery, ConfigMap/Secret 앱 연계, Ingress | 외부 접근 구성 | ⏸️ |
| 12 | Helm & 템플릿 | Helm Chart 구조, values.yaml 커스터마이징, 앱 배포 자동화 | 실습 위주 | ⏸️ |
| 13 | 모의시험 1회차 | CKAD 모의고사 1회차, 빠른 리소스 생성 명령어 숙달(kubectl run/create) | 속도 향상 | ⏸️ |
| 14 | 모의시험 2회차 & 복습 | 모의고사 재도전, 틀린 문제 재실습 | CKAD 환경 최적화 | ⏸️ |
| 15 | 실전 대비 | 시간 분배 훈련, YAML 작성 속도 향상 | 시험 환경 적응 | ⏸️ |
| 16 | **🎯 CKAD 시험 응시** | 실제 시험 응시, 합격 후 심화 학습 계획 수립 | 완주 | ⏸️ |

---

## 📚 1주차 상세 학습 계획

| 일차 | 주제 | 학습 내용 | 진행 여부 |
|------|------|-----------|-----------|
| 1 | 리눅스 기초 명령어 | cd, ls, pwd, mkdir, rm, mv, cp, touch, chmod, chown 등 파일·디렉토리 조작 | ✅ |
| 2 | 리눅스 필수 도구 | grep, awk, sed, find, tar, systemctl, journalctl | ⏸️ |
| 3 | Docker 복습 | 이미지 빌드, run, exec, logs, volume, network | ⏸️ |
| 4 | kubectl 기본 | kubectl get, describe, logs, exec, apply, delete | ⏸️ |
| 5 | K8s 리소스 기초 | Pod, Deployment, Service 구조와 차이 이해 | ⏸️ |
| 6 | 로컬 클러스터 실습 | minikube 또는 kind 설치 및 샘플 앱 배포 실습 | ⏸️ |

---

## 📊 진행도 트래킹

### 전체 진행률
- **1주차**: 🟡 진행 중 (1/6 완료)
- **전체**: 🔴 시작 (1/112 완료, 0.9%)

### 주요 마일스톤
- [ ] 1-7주차: CKA 준비 완료
- [ ] 8주차: CKA 시험 합격
- [ ] 9-15주차: CKAD 준비 완료  
- [ ] 16주차: CKAD 시험 합격

### 상태 표시
- ✅ 완료
- ⏳ 진행 중
- ⏸️ 대기 중
- ❌ 실패/재시도 필요

---

## 🎯 일일 학습 명령어 시스템

매일 학습할 주제를 특정 키워드로 요청하면, 10-30분 분량의 학습 내용과 정리 자료, 퀴즈를 제공합니다.

### 사용법
```
"linux-basic" → 리눅스 기본 명령어 학습
"linux-tools" → 리눅스 도구 (grep, awk, sed) 학습
"docker" → Docker 복습
"kubectl" → kubectl 기본 명령어 학습
"k8s-resources" → K8s 리소스 기초 학습
"minikube" → 로컬 클러스터 실습
```

### 파일 구조
```
week1/
├── day1/
│   ├── day1-linux-basic.md
│   └── day1-quiz.html
├── day2/
│   ├── day2-linux-tools.md
│   └── day2-quiz.html
├── day3/
│   ├── day3-docker.md
│   └── day3-quiz.html
├── day4/
│   ├── day4-kubectl.md
│   └── day4-quiz.html
├── examples/
│   ├── sample-log.txt       # 실습용 로그 파일
│   ├── kubectl-output.txt   # kubectl 출력 예시
│   ├── users.txt           # 텍스트 처리 연습용
│   ├── nginx-pod.yaml      # Pod 매니페스트 예시
│   ├── nginx-deployment.yaml # Deployment 매니페스트 예시
│   └── nginx-service.yaml  # Service 매니페스트 예시
└── ...

참고: 앞으로 모든 일일 학습 자료는 각각의 dayN 폴더에 구성됩니다.
```

### 예시 파일 활용
- 각 주차 `examples/` 폴더에 실습용 파일들이 준비됩니다
- 학습 내용과 연계된 실제 파일로 명령어를 직접 실행해볼 수 있습니다
- 퀴즈 문제도 예시 파일을 기반으로 출제됩니다

### 퀴즈 시스템
모든 학습 주제마다 **HTML 인터랙티브 퀴즈**만 제공됩니다:

#### 퀴즈 특징 (day3 스타일)
- 🎯 **한 문제씩 집중**: 문제별로 순차 진행하는 집중형 학습
- ✅ **실시간 피드백**: 정답 확인 시 즉시 정답/오답 및 해설 제공
- 🎉 **동기부여 시스템**: 정답 시 격려 메시지, 성취도별 메달 시스템
- 📊 **진행도 추적**: 상단 진행바로 현재 진행 상황 시각적 표시
- 💡 **힌트 시스템**: 각 문제마다 힌트 버튼으로 학습 도움
- 🏆 **점수별 성취도**: 8-10개(🥇), 6-7개(🥈), 4-5개(🥉), 3개 이하(📚)
- ⌨️ **편의 기능**: Enter 키 정답 확인, 이전/다음 네비게이션, 모든 정답 보기
- 🔄 **복습 지원**: 이전 문제로 돌아가기, 다시 도전하기 기능

#### 퀴즈 타입
- **객관식**: 4지 선다형 (A, B, C, D 라벨)
- **주관식**: 명령어 직접 입력 (유연한 답안 체크)
- **코드 빈칸**: 템플릿 코드에서 빈칸 채우기

#### 예시 화면 구성
```
┌─────────────────────────────────────────┐
│ ⚙️ Day 4: kubectl 기본 명령어 퀴즈        │
│ 총 10문제 | CKA/CKAD 준비              │
│ ▓▓▓▓▓░░░░░ 5/10                      │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│ 문제 5                                  │
│ Pod 내부에서 대화형 셸을 실행하는...      │
│ ┌─────────────────────────────────────┐ │
│ │ kubectl exec -it nginx-pod -- bash │ │
│ └─────────────────────────────────────┘ │
│ [정답 확인] [💡 힌트]                   │
│                                         │
│ 🎉 정답입니다!                          │
│ 정답: kubectl exec -it nginx-pod ...   │
│ 설명: kubectl exec -it는 실행 중인...   │
└─────────────────────────────────────────┘
[이전] ────────────────────────── [다음]
```

---

## 💡 학습 노트 & 팁

### 중요 명령어 모음
```bash
# 자주 사용하는 kubectl 명령어
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash
```

### 실습 환경
- **Docker 컨테이너**: 리눅스 명령어 연습용 컨테이너 제공
- **로컬 클러스터**: minikube 또는 kind 사용
- **온라인 실습**: Killer.sh, KodeKloud

## 🐳 Docker 학습 환경 사용법

### 빠른 시작
```bash
# 학습 환경 설정 및 시작
./practice-setup.sh

# 학습 컨테이너 접속
docker-compose exec linux-practice bash

# 예시 파일로 실습
cd /study/week1/examples
grep -i error sample-log.txt
```

### 컨테이너 구성
- **linux-practice**: 메인 학습 컨테이너 (Ubuntu + kubectl + 학습 도구들)
- **nginx-server**: 네트워크 실습용 웹서버
- **redis-cache**: 서비스 연결 실습용 캐시

### 유용한 명령어
```bash
# 컨테이너 관리
docker compose up -d              # 백그라운드 실행
docker compose exec linux-practice bash  # 컨테이너 접속
docker compose logs -f            # 로그 실시간 확인
docker compose down               # 컨테이너 중지

# 학습 도구
generate-logs.sh &                # 실습용 로그 생성
ll                                # ls -la 별칭
k get pods                        # kubectl 별칭
```

---

## 📝 진행 상황 업데이트

마지막 업데이트: 2025-08-12

**현재 상황**: 1주차 1일차 완료, 2일차 진행 예정

---

## 🏷️ 커밋 컨벤션 (Conventional Commits)

앞으로 모든 커밋은 다음 형식을 따릅니다:

### 커밋 타입
- **initialize**: 프로젝트 초기 설정
- **feat**: 새로운 기능 추가
- **fix**: 버그 수정
- **docs**: 문서만 수정
- **style**: 코드 formatting, 세미콜론 누락 등
- **refactor**: 코드 리팩토링 (기능 변경 없음)
- **test**: 테스트 추가/수정
- **chore**: 빌드 도구, 설정 파일 수정

### 커밋 메시지 형식
```
<type>: <제목>

- <상세 내용 1>
- <상세 내용 2>  
- <상세 내용 3>
```

### 예시
```bash
feat: 2주차 K8s 핵심 리소스 학습 자료 추가

- ConfigMap, Secret 실습 파일 생성
- ServiceAccount, RBAC 예시 추가
- 2주차 퀴즈 10문제 구성
```