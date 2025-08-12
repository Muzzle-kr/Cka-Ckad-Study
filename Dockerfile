# CKA/CKAD 학습용 리눅스 컨테이너
FROM ubuntu:22.04

# 기본 패키지 설치
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    tree \
    htop \
    net-tools \
    iputils-ping \
    dnsutils \
    telnet \
    nc \
    jq \
    systemctl \
    && rm -rf /var/lib/apt/lists/*

# kubectl 설치
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# Docker CLI 설치 (containerd와 함께 사용)
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && rm get-docker.sh

# 작업 디렉토리 설정
WORKDIR /study

# 학습 자료 복사
COPY . /study/

# 샘플 로그 생성을 위한 스크립트
RUN echo '#!/bin/bash\nwhile true; do\n  echo "$(date) INFO Application running normally"\n  sleep 5\n  echo "$(date) WARNING Memory usage high"\n  sleep 3\n  echo "$(date) ERROR Connection timeout"\n  sleep 10\ndone' > /usr/local/bin/generate-logs.sh \
    && chmod +x /usr/local/bin/generate-logs.sh

# 유용한 별칭 설정
RUN echo 'alias ll="ls -la"' >> /root/.bashrc \
    && echo 'alias k="kubectl"' >> /root/.bashrc \
    && echo 'alias kgp="kubectl get pods"' >> /root/.bashrc \
    && echo 'alias kgs="kubectl get svc"' >> /root/.bashrc

# 컨테이너 시작 시 bash 실행
CMD ["/bin/bash"]