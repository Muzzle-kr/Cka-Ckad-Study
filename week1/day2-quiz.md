# Day 2 퀴즈: Linux 필수 도구

## 🌟 인터랙티브 HTML 퀴즈
더 나은 학습 경험을 위해 **[day2-quiz.html](./day2-quiz.html)** 을 이용해보세요!
- ✅ 실시간 정답 확인
- 🎉 동기부여 메시지와 애니메이션  
- 📊 진행도 표시
- 💡 힌트와 상세 설명

---

## 🎯 퀴즈 (총 10문제)

### 1. grep 관련 (2문제)
**Q1:** `/var/log/syslog` 파일에서 "error"라는 단어가 포함된 줄을 대소문자 구분 없이 검색하고 줄 번호도 함께 출력하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
grep -in "error" /var/log/syslog
# 또는
grep -i -n "error" /var/log/syslog
```
(-i: 대소문자 구분 없음, -n: 줄 번호 표시)
</details>

**Q2:** kubectl logs 출력에서 "failed"와 "error"가 포함된 줄을 모두 찾는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
kubectl logs pod-name | grep -E "failed|error"
# 또는
kubectl logs pod-name | grep -E "(failed|error)"
```
(-E: 확장 정규식 사용)
</details>

### 2. awk 관련 (3문제)
**Q3:** `kubectl get pods` 출력에서 헤더 줄을 제외하고 첫 번째 컬럼(Pod 이름)만 출력하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
kubectl get pods | awk 'NR>1 {print $1}'
```
(NR>1: 줄 번호가 1보다 큰 줄, 즉 헤더 제외)
</details>

**Q4:** `file.txt`에서 세 번째 컬럼이 "Running"인 행의 첫 번째 컬럼을 출력하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
awk '$3=="Running" {print $1}' file.txt
```
($3=="Running": 세 번째 컬럼이 "Running"인 조건)
</details>

**Q5:** `/etc/passwd` 파일에서 콜론(:) 기준으로 분할하여 첫 번째 필드(사용자명)만 출력하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
awk -F: '{print $1}' /etc/passwd
```
(-F:: 구분자를 콜론으로 지정)
</details>

### 3. sed 관련 (2문제)
**Q6:** `deployment.yaml` 파일에서 `nginx:latest`를 `nginx:1.20`으로 모두 바꾸는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
sed 's/nginx:latest/nginx:1.20/g' deployment.yaml
```
(s/old/new/g: 모든 매치를 치환, g 플래그 필수)
</details>

**Q7:** `config.txt` 파일에서 "debug"라는 단어가 포함된 줄을 모두 삭제하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
sed '/debug/d' config.txt
```
(/pattern/d: 패턴이 매치하는 줄 삭제)
</details>

### 4. find 관련 (1문제)
**Q8:** `/etc` 디렉토리에서 확장자가 `.conf`인 파일만 찾는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
find /etc -name "*.conf"
```
(-name: 파일명 패턴으로 검색)
</details>

### 5. systemctl & journalctl 관련 (2문제)
**Q9:** `kubelet` 서비스를 재시작하고 상태를 확인하는 명령어 2개는?

<details>
<summary>정답 보기</summary>

```bash
systemctl restart kubelet
systemctl status kubelet
```
</details>

**Q10:** `docker` 서비스의 최근 10분간 로그를 실시간으로 확인하는 명령어는?

<details>
<summary>정답 보기</summary>

```bash
journalctl -u docker --since "10 minutes ago" -f
```
(-u: 특정 유닛, --since: 시간 범위, -f: 실시간 팔로우)
</details>

---

## 🏆 채점 기준
- **8-10개 정답**: 🥇 우수! 다음 단계 진행
- **6-7개 정답**: 🥈 양호! 틀린 부분 복습 후 진행  
- **5개 이하**: 🥉 복습 필요! 학습 내용 다시 읽어보기

---

## 💡 추가 학습 팁
1. **실제로 명령어 실행해보기**: 이론만으로는 부족합니다
2. **man 페이지 활용**: `man grep`, `man awk` 등으로 상세 옵션 확인
3. **조합 연습**: `kubectl get pods | grep Running | awk '{print $1}'` 같은 파이프라인 연습
4. **CKA/CKAD 환경**: 시험에서는 이런 명령어들이 매우 중요합니다!