#!/bin/bash
# Oracle Cloud에 Ubuntu 22.04 ARM 인스턴스 생성 스크립트
# Cloud Shell에서 실행하세요!

set -e

COMPARTMENT_ID="ocid1.tenancy.oc1..aaaaaaaauudft5tii6bp62axx4k2kxoslwmqyjr4snwilzxu7jnzzgocirfa"
REGION="ap-chuncheon-1"

echo "=========================================="
echo "Oracle Cloud 인스턴스 생성 (Ubuntu 22.04)"
echo "=========================================="

# 1. 기존 인스턴스 확인 및 삭제
echo ""
echo "[1/8] 기존 인스턴스 확인 중..."
INSTANCES=$(oci compute instance list \
  --compartment-id $COMPARTMENT_ID \
  --lifecycle-state RUNNING \
  --query 'data[*].{Name:"display-name", ID:id}' \
  --output table)

echo "$INSTANCES"

if [ -n "$INSTANCES" ] && [ "$INSTANCES" != "No data found" ]; then
  echo ""
  read -p "기존 인스턴스를 삭제하시겠습니까? (y/n): " DELETE_CONFIRM

  if [ "$DELETE_CONFIRM" = "y" ]; then
    INSTANCE_IDS=$(oci compute instance list \
      --compartment-id $COMPARTMENT_ID \
      --lifecycle-state RUNNING \
      --query 'data[*].id' \
      --raw-output)

    for INSTANCE_ID in $INSTANCE_IDS; do
      echo "삭제 중: $INSTANCE_ID"
      oci compute instance terminate \
        --instance-id $INSTANCE_ID \
        --preserve-boot-volume false \
        --force
    done

    echo "인스턴스 삭제 대기 중... (30초)"
    sleep 30
  fi
fi

# 2. VCN 및 Subnet 정보 가져오기
echo ""
echo "[2/8] 네트워크 정보 확인 중..."
VCN_ID=$(oci network vcn list \
  --compartment-id $COMPARTMENT_ID \
  --query 'data[0].id' \
  --raw-output)

if [ -z "$VCN_ID" ] || [ "$VCN_ID" = "None" ]; then
  echo "❌ VCN을 찾을 수 없습니다. 먼저 VCN을 생성하세요."
  exit 1
fi

echo "VCN ID: $VCN_ID"

SUBNET_ID=$(oci network subnet list \
  --compartment-id $COMPARTMENT_ID \
  --vcn-id $VCN_ID \
  --query 'data[0].id' \
  --raw-output)

if [ -z "$SUBNET_ID" ] || [ "$SUBNET_ID" = "None" ]; then
  echo "❌ Subnet을 찾을 수 없습니다."
  exit 1
fi

echo "Subnet ID: $SUBNET_ID"

# 3. Availability Domain 확인
echo ""
echo "[3/8] Availability Domain 확인 중..."
AD_NAME=$(oci iam availability-domain list \
  --compartment-id $COMPARTMENT_ID \
  --query 'data[0].name' \
  --raw-output)

echo "Availability Domain: $AD_NAME"

# 4. Ubuntu 22.04 ARM Image 찾기
echo ""
echo "[4/8] Ubuntu 22.04 ARM 이미지 검색 중..."
IMAGE_ID=$(oci compute image list \
  --compartment-id $COMPARTMENT_ID \
  --operating-system "Canonical Ubuntu" \
  --operating-system-version "22.04" \
  --shape "VM.Standard.A1.Flex" \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --query 'data[0].id' \
  --raw-output)

if [ -z "$IMAGE_ID" ] || [ "$IMAGE_ID" = "None" ]; then
  echo "❌ Ubuntu 22.04 ARM 이미지를 찾을 수 없습니다."
  echo "수동으로 이미지 OCID를 입력하세요:"
  read -p "Image OCID: " IMAGE_ID
fi

echo "Image ID: $IMAGE_ID"

# 5. SSH 키 생성 또는 사용
echo ""
echo "[5/8] SSH 키 설정..."

if [ -f ~/.ssh/id_rsa.pub ]; then
  echo "기존 SSH 공개 키 사용: ~/.ssh/id_rsa.pub"
  SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
else
  echo "새 SSH 키 생성 중..."
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/oracle_ubuntu -N ""
  SSH_PUBLIC_KEY=$(cat ~/.ssh/oracle_ubuntu.pub)
  echo "✅ 새 키 생성 완료: ~/.ssh/oracle_ubuntu"
fi

# 6. 인스턴스 생성
echo ""
echo "[6/8] 인스턴스 생성 중... (3-5분 소요)"
echo "=========================================="
echo "설정:"
echo "  - Name: n8n-ubuntu"
echo "  - Shape: VM.Standard.A1.Flex"
echo "  - OCPU: 2"
echo "  - RAM: 12GB"
echo "  - OS: Ubuntu 22.04"
echo "=========================================="

INSTANCE_RESULT=$(oci compute instance launch \
  --display-name "n8n-ubuntu" \
  --compartment-id $COMPARTMENT_ID \
  --availability-domain "$AD_NAME" \
  --shape "VM.Standard.A1.Flex" \
  --shape-config '{"ocpus": 2, "memory_in_gbs": 12}' \
  --image-id $IMAGE_ID \
  --subnet-id $SUBNET_ID \
  --assign-public-ip true \
  --ssh-authorized-keys-file <(echo "$SSH_PUBLIC_KEY") \
  --wait-for-state RUNNING \
  --query 'data.{ID:id, Name:"display-name", State:"lifecycle-state"}')

echo "$INSTANCE_RESULT"

INSTANCE_ID=$(echo "$INSTANCE_RESULT" | jq -r '.ID')

if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" = "None" ]; then
  echo "❌ 인스턴스 생성 실패"
  exit 1
fi

echo ""
echo "✅ 인스턴스 생성 완료!"
echo "Instance ID: $INSTANCE_ID"

# 7. Public IP 가져오기
echo ""
echo "[7/8] Public IP 확인 중..."
sleep 10

PUBLIC_IP=$(oci compute instance list-vnics \
  --instance-id $INSTANCE_ID \
  --query 'data[0]."public-ip"' \
  --raw-output)

echo "Public IP: $PUBLIC_IP"

# 8. Security List 업데이트 (포트 5678 열기)
echo ""
echo "[8/8] 방화벽 설정 중... (포트 5678)"

SECURITY_LIST_ID=$(oci network subnet get \
  --subnet-id $SUBNET_ID \
  --query 'data."security-list-ids"[0]' \
  --raw-output)

# 현재 ingress rules 가져오기
CURRENT_RULES=$(oci network security-list get \
  --security-list-id $SECURITY_LIST_ID \
  --query 'data."ingress-security-rules"')

# 포트 5678 규칙 추가 (이미 있으면 스킵)
if echo "$CURRENT_RULES" | grep -q "5678"; then
  echo "✅ 포트 5678이 이미 열려있습니다."
else
  echo "포트 5678 추가 중..."

  # 새 규칙 생성
  NEW_RULE='{"source": "0.0.0.0/0", "protocol": "6", "tcp-options": {"destination-port-range": {"min": 5678, "max": 5678}}}'

  # 기존 규칙에 추가
  UPDATED_RULES=$(echo "$CURRENT_RULES" | jq ". + [$NEW_RULE]")

  oci network security-list update \
    --security-list-id $SECURITY_LIST_ID \
    --ingress-security-rules "$UPDATED_RULES" \
    --force

  echo "✅ 포트 5678 추가 완료"
fi

# 완료 정보 출력
echo ""
echo "=========================================="
echo "🎉 인스턴스 생성 완료!"
echo "=========================================="
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"
echo "Username: ubuntu"
echo "SSH Command: ssh ubuntu@$PUBLIC_IP"
echo ""
echo "다음 단계:"
echo "1. SSH 접속 대기 (60초 후):"
echo "   ssh ubuntu@$PUBLIC_IP"
echo ""
echo "2. 접속 후 n8n 설치:"
echo "   (별도 스크립트 실행)"
echo "=========================================="

# 로그인 정보 저장
cat > oracle-instance-info.txt <<EOF
# Oracle Cloud 인스턴스 정보

## 생성 일시
$(date)

## 인스턴스 정보
- Instance ID: $INSTANCE_ID
- Instance Name: n8n-ubuntu
- Shape: VM.Standard.A1.Flex (2 OCPU, 12GB RAM)
- OS: Ubuntu 22.04 (ARM)
- Region: $REGION

## 접속 정보
- Public IP: $PUBLIC_IP
- Username: ubuntu
- SSH Command: ssh ubuntu@$PUBLIC_IP

## SSH 키
- Private Key: ~/.ssh/id_rsa 또는 ~/.ssh/oracle_ubuntu
- Public Key: ~/.ssh/id_rsa.pub 또는 ~/.ssh/oracle_ubuntu.pub

## 방화벽
- Port 22: ✅ SSH
- Port 5678: ✅ n8n

## 다음 단계
1. SSH 접속 테스트
2. n8n 설치 (Docker)
3. Keep-Alive 설정
EOF

echo ""
echo "📄 인스턴스 정보가 oracle-instance-info.txt에 저장되었습니다."
