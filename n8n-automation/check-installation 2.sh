#!/bin/bash
# n8n 설치 진행 상황 실시간 체크 스크립트

echo "=========================================="
echo "n8n 설치 상태 점검"
echo "=========================================="

# SSH 연결 테스트
echo ""
echo "[1] SSH 연결 상태 확인..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no opc@146.56.119.240 "echo 'SSH OK'" 2>/dev/null; then
  echo "✅ SSH 연결 성공"
else
  echo "❌ SSH 연결 실패"
  exit 1
fi

# 원격 서버에서 상태 확인
ssh opc@146.56.119.240 << 'ENDSSH'
echo ""
echo "[2] Docker 설치 상태 확인..."

# Docker 설치 여부
if command -v docker &> /dev/null; then
  echo "✅ Docker 설치됨"
  docker --version

  # Docker 서비스 상태
  echo ""
  echo "[3] Docker 서비스 상태..."
  if sudo systemctl is-active --quiet docker; then
    echo "✅ Docker 서비스 실행 중"
  else
    echo "❌ Docker 서비스 중지됨"
  fi
else
  echo "⏳ Docker 설치 진행 중 또는 미설치"

  # dnf 프로세스 확인
  if ps aux | grep -v grep | grep -q "dnf\|yum"; then
    echo "   → dnf/yum이 실행 중입니다 (패키지 설치 중)"
    echo ""
    echo "   실행 중인 프로세스:"
    ps aux | grep -v grep | grep "dnf\|yum" | awk '{print "   - " $11 " " $12 " " $13}'
  fi
fi

echo ""
echo "[4] n8n 컨테이너 상태 확인..."

# n8n 컨테이너 확인
if command -v docker &> /dev/null; then
  if sudo docker ps -a --format "{{.Names}}" | grep -q "^n8n$"; then
    STATUS=$(sudo docker ps -a --filter "name=^n8n$" --format "{{.Status}}")
    if sudo docker ps --filter "name=^n8n$" --format "{{.Names}}" | grep -q "^n8n$"; then
      echo "✅ n8n 컨테이너 실행 중"
      echo "   상태: $STATUS"

      # n8n 로그 마지막 5줄
      echo ""
      echo "   최근 로그:"
      sudo docker logs n8n --tail 5 2>&1 | sed 's/^/   /'
    else
      echo "⚠️  n8n 컨테이너 존재하지만 중지됨"
      echo "   상태: $STATUS"
    fi
  else
    echo "⏳ n8n 컨테이너 아직 생성 안됨"

    # Docker 이미지 다운로드 확인
    if sudo docker images | grep -q "n8nio/n8n"; then
      echo "   → n8n 이미지는 다운로드됨"
    else
      echo "   → n8n 이미지 다운로드 대기 중"
    fi
  fi
else
  echo "⏳ Docker 미설치 (n8n 확인 불가)"
fi

echo ""
echo "[5] 방화벽 설정 확인..."
if sudo firewall-cmd --list-ports | grep -q "5678/tcp"; then
  echo "✅ 포트 5678 열림"
else
  echo "❌ 포트 5678 닫힘"
fi

echo ""
echo "[6] 네트워크 연결 테스트..."
if command -v docker &> /dev/null && sudo docker ps --filter "name=^n8n$" --format "{{.Names}}" | grep -q "^n8n$"; then
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 --connect-timeout 3 | grep -q "200\|302"; then
    echo "✅ n8n 웹 서버 응답 정상"
  else
    echo "⏳ n8n 웹 서버 시작 대기 중"
  fi
else
  echo "⏳ n8n 컨테이너 대기 중"
fi

ENDSSH

echo ""
echo "=========================================="
echo "외부 접속 테스트..."
echo "=========================================="

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://146.56.119.240:5678 --connect-timeout 5)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
  echo "✅ n8n 외부 접속 가능!"
  echo ""
  echo "🎉 설치 완료!"
  echo "접속 URL: http://146.56.119.240:5678"
else
  echo "⏳ n8n 외부 접속 대기 중 (HTTP $HTTP_CODE)"
  echo ""
  echo "아직 설치가 완료되지 않았습니다."
  echo "1-2분 후 다시 확인하세요."
fi

echo "=========================================="
