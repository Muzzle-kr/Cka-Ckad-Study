#!/bin/bash

# CKA/CKAD 학습 환경 설정 스크립트

echo "🚀 CKA/CKAD 학습 환경을 설정합니다..."

# Docker 컨테이너 빌드 및 실행
echo "📦 Docker 컨테이너 빌드 중..."
docker-compose build

echo "🔄 컨테이너 시작 중..."
docker-compose up -d

echo "✅ 설정 완료!"
echo ""
echo "📖 사용 방법:"
echo "  docker-compose exec linux-practice bash  # 메인 학습 컨테이너 접속"
echo "  docker-compose logs -f linux-practice    # 컨테이너 로그 확인"
echo "  docker-compose down                      # 컨테이너 중지"
echo ""
echo "🎯 학습 시작:"
echo "  cd /study/week1/examples                 # 예시 파일 디렉토리로 이동"
echo "  grep -i error sample-log.txt            # 실습 명령어 실행"
echo ""
echo "💡 유용한 명령어:"
echo "  ll                                       # ls -la 별칭"
echo "  k get pods                              # kubectl 별칭" 
echo "  generate-logs.sh &                      # 샘플 로그 생성"