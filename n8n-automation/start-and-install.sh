#!/bin/bash
# n8n 인스턴스 시작 및 설치 완전 자동화 스크립트

set -e

COMPARTMENT_ID="ocid1.tenancy.oc1..aaaaaaaauudft5tii6bp62axx4k2kxoslwmqyjr4snwilzxu7jnzzgocirfa"

echo "=========================================="
echo "n8n 자동 설치 시작"
echo "=========================================="

# 1. 인스턴스 ID 가져오기
echo "[1/5] 인스턴스 ID 가져오는 중..."
INSTANCE_ID=$(oci compute instance list --compartment-id $COMPARTMENT_ID --display-name "n8n-server" --query 'data[0].id' --raw-output)
echo "Instance ID: $INSTANCE_ID"

# 2. 인스턴스 상태 확인
echo "[2/5] 인스턴스 상태 확인 중..."
STATE=$(oci compute instance get --instance-id $INSTANCE_ID --query 'data."lifecycle-state"' --raw-output)
echo "Current state: $STATE"

# 3. 인스턴스가 STOPPED이면 시작
if [ "$STATE" = "STOPPED" ]; then
  echo "[3/5] 인스턴스 시작 중..."
  oci compute instance action --instance-id $INSTANCE_ID --action START --wait-for-state RUNNING
  echo "인스턴스 시작 완료! SSH 대기 중..."
  sleep 90
elif [ "$STATE" = "RUNNING" ]; then
  echo "[3/5] 인스턴스가 이미 실행 중입니다."
  sleep 30
else
  echo "[3/5] 인스턴스 상태가 $STATE 입니다. STOPPED 또는 RUNNING 상태가 될 때까지 대기 중..."
  while true; do
    STATE=$(oci compute instance get --instance-id $INSTANCE_ID --query 'data."lifecycle-state"' --raw-output)
    echo "Current state: $STATE"
    if [ "$STATE" = "STOPPED" ]; then
      oci compute instance action --instance-id $INSTANCE_ID --action START --wait-for-state RUNNING
      sleep 90
      break
    elif [ "$STATE" = "RUNNING" ]; then
      sleep 30
      break
    fi
    sleep 10
  done
fi

# 4. SSH 접속 테스트
echo "[4/5] SSH 연결 테스트 중..."
MAX_RETRIES=10
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no opc@146.56.119.240 "echo 'SSH OK'" 2>/dev/null; then
    echo "SSH 연결 성공!"
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT+1))
  echo "SSH 연결 대기 중... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 10
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
  echo "SSH 연결 실패. 수동으로 확인이 필요합니다."
  exit 1
fi

# 5. n8n 설치
echo "[5/5] n8n 설치 중... (5-7분 소요)"
ssh opc@146.56.119.240 << 'ENDSSH'
set -e

# 방화벽 설정
sudo firewall-cmd --permanent --add-port=5678/tcp 2>/dev/null || true
sudo firewall-cmd --reload

# Docker 저장소 추가 및 설치
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Docker 시작
sudo systemctl start docker
sudo systemctl enable docker

# n8n 컨테이너 실행
sudo docker run -d \
  --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -e N8N_PORT=5678 \
  -e N8N_HOST=0.0.0.0 \
  -v n8n_data:/home/node/.n8n \
  docker.io/n8nio/n8n

echo ""
echo "=========================================="
echo "✅ n8n 설치 완료!"
echo "=========================================="
echo "접속 URL: http://146.56.119.240:5678"
echo "초기 설정은 웹에서 진행하세요"
echo "=========================================="
ENDSSH

echo ""
echo "=========================================="
echo "🎉 모든 작업 완료!"
echo "=========================================="
echo "n8n 접속: http://146.56.119.240:5678"
echo "1-2분 후 브라우저에서 접속하세요"
echo "=========================================="
