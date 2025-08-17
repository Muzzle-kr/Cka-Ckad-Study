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

## 📚 2주차 상세 학습 계획

| 일차 | 주제 | 학습 내용 | 진행 여부 |
|------|------|-----------|-----------|
| 1 | ConfigMap 기초 | ConfigMap 생성, 조회, 수정, Pod에서 환경변수/볼륨으로 사용 | ⏸️ |
| 2 | Secret 관리 | Secret 타입별 생성, 암호화, Pod에서 활용, TLS 인증서 관리 | ⏸️ |
| 3 | ServiceAccount & RBAC | ServiceAccount 생성, Token 관리, Role/RoleBinding, ClusterRole/ClusterRoleBinding | ⏸️ |
| 4 | Probe 설정 | Liveness/Readiness/Startup Probe 구성, 헬스체크 전략 | ⏸️ |
| 5 | 고급 Pod 설정 | Resource Requests/Limits, QoS Classes, Node Selector, Affinity | ⏸️ |
| 6 | 실전 통합 연습 | 전체 리소스를 활용한 완전한 애플리케이션 배포 및 보안 설정 | ⏸️ |

---

## 📊 진행도 트래킹

### 전체 진행률
- **1주차**: 🟡 진행 중 (6/6 완료)
- **2주차**: ⏸️ 대기 중 (0/6 완료)
- **전체**: 🟡 진행 중 (6/112 완료, 5.4%)

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

#### 1주차 키워드
```
"linux-basic" → 리눅스 기본 명령어 학습
"linux-tools" → 리눅스 도구 (grep, awk, sed) 학습
"docker" → Docker 복습
"kubectl" → kubectl 기본 명령어 학습
"k8s-resources" → K8s 리소스 기초 학습
"minikube" → 로컬 클러스터 실습
```

#### 2주차 키워드
```
"configmap" → ConfigMap 생성 및 활용 학습
"secret" → Secret 관리 및 보안 설정 학습
"rbac" → ServiceAccount, Role, RoleBinding 학습
"probes" → Liveness/Readiness Probe 설정 학습
"resources" → Resource Requests/Limits, QoS 학습
"advanced-pod" → 고급 Pod 설정 및 통합 연습
```

### 파일 구조
```
week1/                        # 1주차: 리눅스 & K8s 기본기
├── day1/ ~ day6/            # 각 일차별 학습 자료
│   ├── dayN-topic.md        # 학습 자료
│   ├── dayN-quiz.html       # 인터랙티브 퀴즈
│   └── examples/            # 실습용 예시 파일들
├── examples/                # 공통 예시 파일
│   ├── sample-log.txt       # 실습용 로그 파일
│   ├── kubectl-output.txt   # kubectl 출력 예시
│   ├── users.txt           # 텍스트 처리 연습용
│   ├── nginx-pod.yaml      # Pod 매니페스트 예시
│   ├── nginx-deployment.yaml # Deployment 매니페스트 예시
│   └── nginx-service.yaml  # Service 매니페스트 예시

week2/                        # 2주차: K8s 핵심 리소스
├── day1/                    # ConfigMap 기초
│   ├── day1-configmap.md
│   ├── day1-quiz.html
│   └── examples/
├── day2/                    # Secret 관리
│   ├── day2-secret.md
│   ├── day2-quiz.html
│   └── examples/
├── day3/                    # ServiceAccount & RBAC
│   ├── day3-rbac.md
│   ├── day3-quiz.html
│   └── examples/
├── day4/                    # Probe 설정
│   ├── day4-probes.md
│   ├── day4-quiz.html
│   └── examples/
├── day5/                    # 고급 Pod 설정
│   ├── day5-resources.md
│   ├── day5-quiz.html
│   └── examples/
├── day6/                    # 실전 통합 연습
│   ├── day6-advanced-pod.md
│   ├── day6-quiz.html
│   └── examples/
└── examples/                # 2주차 공통 예시 파일

참고: 매주 완성되는 학습 자료는 일관된 구조로 제공됩니다.
```

### 예시 파일 활용
- 각 주차 `examples/` 폴더에 실습용 파일들이 준비됩니다
- 학습 내용과 연계된 실제 파일로 명령어를 직접 실행해볼 수 있습니다
- 퀴즈 문제도 예시 파일을 기반으로 출제됩니다

### 퀴즈 시스템
모든 학습 주제마다 **HTML 인터랙티브 퀴즈**만 제공됩니다:

#### 퀴즈 특징 (개선된 버전)
- 🎯 **한 문제씩 집중**: 문제별로 순차 진행하는 집중형 학습
- ✅ **실시간 피드백**: 정답 확인 시 즉시 정답/오답 및 해설 제공
- 🔄 **재시도 가능**: 틀렸을 때 다시 시도할 수 있어 학습 효과 극대화
- 📊 **정확한 진행도**: 현재 문제 기준으로 진행바 표시 (1/10, 2/10 방식)
- 🎉 **동기부여 시스템**: 정답 시 격려 메시지, 성취도별 메달 시스템
- 💡 **힌트 시스템**: 각 문제마다 힌트 버튼으로 학습 도움
- 🏆 **점수별 성취도**: 8-10개(🥇), 6-7개(🥈), 4-5개(🥉), 3개 이하(📚)
- ⌨️ **편의 기능**: Enter 키 정답 확인, 이전/다음 네비게이션, 모든 정답 보기
- 🚫 **자동 넘어가기 없음**: 정답/오답 후 사용자가 직접 다음 문제로 이동

#### 퀴즈 타입
- **객관식**: 4지 선다형 (A, B, C, D 라벨)
- **주관식**: 명령어 직접 입력 (유연한 답안 체크)
- **코드 빈칸**: 템플릿 코드에서 빈칸 채우기

#### 예시 화면 구성 및 동작
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
│ [정답입니다!] [💡 힌트]                 │
│                                         │
│ 🎉 정답입니다!                          │
│ 정답: kubectl exec -it nginx-pod ...   │
│ 설명: kubectl exec -it는 실행 중인...   │
└─────────────────────────────────────────┘
[이전] ────────────────────────── [다음]
```

#### 퀴즈 동작 방식
1. **정답인 경우**: 
   - 버튼이 "정답입니다!"로 변경되고 초록색으로 표시
   - 옵션 선택이 비활성화되어 더 이상 변경 불가
   - 사용자가 직접 "다음" 버튼을 눌러 다음 문제로 이동

2. **오답인 경우**:
   - 버튼이 "다시 시도하기"로 변경
   - 1초 후 선택된 옵션이 초기화되어 다시 선택 가능
   - 정답을 맞출 때까지 계속 시도 가능

3. **진행도 표시**:
   - 현재 문제 번호 기준으로 정확한 진행률 계산
   - 예: 5번째 문제 = 50% 진행 (5/10)

---

## 📊 2주차 Google Sheets 계획표

### 복사용 데이터 (Google Sheets 적용)

#### 주간 개요
| 항목 | 내용 |
|------|------|
| 주차 | 2주차 |
| 목표 | K8s 핵심 리소스 |
| 기간 | 6일 |
| 총 학습 시간 | 195분 (약 3.25시간) |
| 총 퀴즈 문제 | 69개 |
| 완료 조건 | 모든 퀴즈 80% 이상 정답 |

#### 일별 상세 계획
| 일차 | 주제 | 학습목표 | 예상시간 | 퀴즈수 | 핵심명령어 | 상태 |
|------|------|----------|----------|--------|------------|------|
| 1 | ConfigMap 기초 | ConfigMap 생성, 조회, 수정, Pod 연동 | 25분 | 10개 | kubectl create configmap | ⏸️ |
| 2 | Secret 관리 | Secret 타입별 생성, 암호화, Pod 활용 | 30분 | 10개 | kubectl create secret | ⏸️ |
| 3 | ServiceAccount & RBAC | SA 생성, 권한 관리, Role/RoleBinding | 35분 | 12개 | kubectl create serviceaccount | ⏸️ |
| 4 | Probe 설정 | Liveness/Readiness/Startup Probe | 30분 | 10개 | kubectl describe pod | ⏸️ |
| 5 | 고급 Pod 설정 | Resource Requests/Limits, QoS, Affinity | 35분 | 12개 | kubectl top | ⏸️ |
| 6 | 실전 통합 연습 | 전체 리소스 활용 완전 배포 | 40분 | 15개 | kubectl apply -f | ⏸️ |

#### Google Sheets 템플릿 구조
**Sheet 1: 주간 개요**
```
| A | B | C | D | E | F |
|---|---|---|---|---|---|
| 주차 | 목표 | 총 일수 | 총 시간 | 총 퀴즈 | 진행률 |
| 2주차 | K8s 핵심 리소스 | 6일 | 195분 | 69문제 | 0% |
```

**Sheet 2: 일별 상세**
```
| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| 일차 | 주제 | 학습목표 | 예상시간 | 퀴즈수 | 핵심명령어 | 상태 | 완료일 |
```

**Sheet 3: 진행 상황**
```
| A | B | C | D | E |
|---|---|---|---|---|
| 날짜 | 완료한 일차 | 소요시간 | 퀴즈점수 | 메모 |
```

#### 주요 학습 성과 목표
- ✅ ConfigMap/Secret을 활용한 설정 관리
- ✅ RBAC를 통한 보안 권한 관리  
- ✅ Probe를 통한 헬스체크 구현
- ✅ 리소스 관리를 통한 성능 최적화
- ✅ 통합 환경에서의 실전 배포 경험

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

마지막 업데이트: 2025-08-17

**현재 상황**: 1주차 완료 (6/6), 2주차 시작 준비 완료

### 완료된 작업
- ✅ 1주차 학습 자료 완성 (Day 1-6)
- ✅ 인터랙티브 퀴즈 시스템 구축 및 개선
- ✅ 실습 환경 구성 (Docker, minikube/kind)
- ✅ 2주차 학습 계획 수립

### 다음 단계
- 🎯 2주차 Day 1: ConfigMap 기초 학습 자료 제작
- 📋 ConfigMap 생성, 조회, Pod 연동 실습

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