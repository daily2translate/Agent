#!/bin/bash
# Koyeb로 n8n 완전 자동 배포 스크립트

set -e

echo "=========================================="
echo "Koyeb n8n 자동 배포"
echo "=========================================="

# 1. Koyeb CLI 설치
echo "[1/4] Koyeb CLI 설치 중..."
if ! command -v koyeb &> /dev/null; then
  echo "Installing Koyeb CLI..."
  curl -fsSL https://raw.githubusercontent.com/koyeb/koyeb-cli/master/install.sh | sh
  export PATH="$HOME/.koyeb:$PATH"
else
  echo "✅ Koyeb CLI 이미 설치됨"
fi

# 2. API 토큰 확인
echo ""
echo "[2/4] Koyeb API 토큰 설정"
echo "=========================================="
echo "Koyeb 계정이 필요합니다:"
echo "1. https://app.koyeb.com/auth/signup 에서 가입 (GitHub 계정 사용)"
echo "2. https://app.koyeb.com/account/api 에서 API 토큰 생성"
echo "3. 아래에 토큰을 붙여넣으세요"
echo "=========================================="
echo ""
read -sp "Koyeb API 토큰: " KOYEB_TOKEN
echo ""

# 3. 로그인
echo ""
echo "[3/4] Koyeb 로그인 중..."
echo "$KOYEB_TOKEN" | koyeb login

# 4. n8n 배포
echo ""
echo "[4/4] n8n 배포 중... (3-5분 소요)"
koyeb service create n8n-app \
  --docker docker.n8n.io/n8nio/n8n:latest \
  --ports 5678:http \
  --routes /:5678 \
  --env N8N_HOST=0.0.0.0 \
  --env N8N_PORT=5678 \
  --env WEBHOOK_URL=https://n8n-app-YOUR_ORG.koyeb.app \
  --instance-type free \
  --regions fra

echo ""
echo "=========================================="
echo "✅ n8n 배포 완료!"
echo "=========================================="

# 서비스 정보 가져오기
echo ""
echo "배포 상태 확인 중..."
sleep 10
koyeb service get n8n-app

echo ""
echo "=========================================="
echo "접속 URL 확인:"
echo "koyeb service get n8n-app | grep 'Public URL'"
echo ""
echo "로그 확인:"
echo "koyeb service logs n8n-app"
echo "=========================================="
