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
├── day1-linux-basic.md
├── day1-quiz.md
├── day2-linux-tools.md
├── day2-quiz.md
├── examples/
│   ├── sample-log.txt       # 실습용 로그 파일
│   ├── pod-status.txt       # kubectl 출력 예시
│   ├── users.txt           # 텍스트 처리 연습용
│   └── deployment.yaml     # K8s 매니페스트 예시
└── ...
```

### 예시 파일 활용
- 각 주차 `examples/` 폴더에 실습용 파일들이 준비됩니다
- 학습 내용과 연계된 실제 파일로 명령어를 직접 실행해볼 수 있습니다
- 퀴즈 문제도 예시 파일을 기반으로 출제됩니다

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
- **로컬 클러스터**: minikube 또는 kind 사용
- **온라인 실습**: Killer.sh, KodeKloud

---

## 📝 진행 상황 업데이트

마지막 업데이트: 2025-08-12

**현재 상황**: 1주차 1일차 완료, 2일차 진행 예정