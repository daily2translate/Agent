# Oracle Cloud 인스턴스 새로 설정하기

## 참고 자료
- 블로그: https://cord-ai.tistory.com/210
- Ubuntu 22.04 ARM 기반 Always Free Tier

---

## 1단계: 기존 인스턴스 삭제 (웹 콘솔)

### 1-1. Oracle Cloud Console 접속
```
https://cloud.oracle.com
```

### 1-2. 인스턴스 삭제
1. **Compute → Instances** 메뉴 이동
2. 기존 인스턴스 찾기:
   - `n8n-server` (146.56.119.240)
   - 또는 다른 실행 중인 인스턴스
3. **⋮ (점 3개)** → **Terminate** 클릭
4. **Permanently delete the attached boot volume** ✅ 체크
5. **Terminate Instance** 확인

### 1-3. 삭제 대기
- 상태: TERMINATING → TERMINATED
- 약 1-2분 소요

---

## 2단계: 새 인스턴스 생성

### 2-1. Create Instance 시작
1. **Compute → Instances** 메뉴
2. **Create Instance** 클릭

### 2-2. 기본 정보 설정
- **Name**: `n8n-ubuntu` (또는 원하는 이름)
- **Compartment**: (기본값 유지)

### 2-3. Placement (배치)
- **Availability Domain**: AD-1 (기본값)
- **Fault Domain**: (자동 선택)

### 2-4. Image and Shape (중요!)

#### Image (운영체제):
1. **Change Image** 클릭
2. **Canonical Ubuntu** 선택
3. **22.04** 버전 선택
4. **Select Image** 클릭

#### Shape (인스턴스 타입):
1. **Change Shape** 클릭
2. **Virtual Machine** 선택
3. **Shape Series**: Ampere (ARM 기반)
4. **Shape Name**: **VM.Standard.A1.Flex** 선택
   - ✅ Always Free Eligible!
5. **OCPUs**: 1 (또는 최대 4)
6. **Memory (GB)**: 6 (또는 최대 24GB)
   - 권장: **OCPU 2개, 12GB RAM** (무료 범위 내 최대)
7. **Select Shape** 클릭

### 2-5. Networking (네트워크)

#### Primary VNIC:
- **Primary Network**: (기본 VCN 사용)
- **Subnet**: Public Subnet (기본값)
- **Public IPv4 Address**: **Assign a public IPv4 address** ✅ 체크

### 2-6. Add SSH Keys (SSH 인증)

#### 방법 A: 새 키 생성 (권장)
1. **Generate a key pair for me** 선택
2. **Save Private Key** 클릭 → `ssh-key-ubuntu.key` 저장
3. **Save Public Key** 클릭 → `ssh-key-ubuntu.key.pub` 저장

#### 방법 B: 기존 키 사용
1. **Upload public key files** 선택
2. Cloud Shell 공개 키 업로드:
   ```
   /Users/admin/.ssh/id_rsa.pub
   ```

### 2-7. Boot Volume (부트 볼륨)
- **Boot Volume Size**: 50GB (기본값, 무료 범위)
- **Use in-transit encryption**: ✅ (선택 사항)

### 2-8. Create Instance!
- **Create** 버튼 클릭
- 프로비저닝 시작 (2-3분 소요)

---

## 3단계: 인스턴스 정보 확인

### 3-1. Public IP 확인
인스턴스 Details 페이지에서:
- **Public IP Address**: (복사)
- 예: `150.230.XX.XX`

### 3-2. Username 확인
- Ubuntu 22.04의 기본 사용자: **`ubuntu`**

---

## 4단계: 방화벽 설정 (포트 5678 열기)

### 4-1. Security List 이동
1. 인스턴스 Details 페이지
2. **Primary VNIC** 섹션
3. **Subnet** 링크 클릭
4. **Security Lists** 클릭
5. **Default Security List** 클릭

### 4-2. Ingress Rule 추가
1. **Add Ingress Rules** 클릭
2. 다음 정보 입력:

```
Source Type: CIDR
Source CIDR: 0.0.0.0/0
IP Protocol: TCP
Source Port Range: (All)
Destination Port Range: 5678
Description: n8n web interface
```

3. **Add Ingress Rules** 클릭

### 4-3. SSH 포트 확인
기본적으로 포트 22는 이미 열려있어야 합니다. 확인:
- Destination Port: 22
- Source: 0.0.0.0/0

---

## 5단계: SSH 키 설정 (로컬)

### 5-1. SSH 키 이동
다운로드한 Private Key를 SSH 디렉토리로 이동:

```bash
# 키 파일 이동
mv ~/Downloads/ssh-key-ubuntu.key ~/.ssh/oracle-ubuntu.key

# 권한 설정
chmod 600 ~/.ssh/oracle-ubuntu.key
```

### 5-2. SSH Config 설정
`~/.ssh/config` 파일에 추가:

```
Host oracle-ubuntu
    HostName [PUBLIC_IP_ADDRESS]
    User ubuntu
    IdentityFile ~/.ssh/oracle-ubuntu.key
    StrictHostKeyChecking no
```

---

## 6단계: SSH 접속 테스트

### 6-1. 첫 접속
```bash
ssh ubuntu@[PUBLIC_IP_ADDRESS] -i ~/.ssh/oracle-ubuntu.key
```

또는 config 설정 후:
```bash
ssh oracle-ubuntu
```

### 6-2. 시스템 정보 확인
```bash
# OS 버전
cat /etc/os-release

# CPU 정보
lscpu

# 메모리 정보
free -h

# 디스크 정보
df -h
```

---

## 7단계: Ubuntu 방화벽 설정

### 7-1. UFW 포트 열기
```bash
sudo ufw allow 22/tcp
sudo ufw allow 5678/tcp
sudo ufw enable
sudo ufw status
```

---

## 완료 체크리스트

- [ ] 기존 인스턴스 삭제 완료
- [ ] 새 인스턴스 생성 (VM.Standard.A1.Flex, Ubuntu 22.04)
- [ ] Public IP 확인
- [ ] Security List에 포트 5678 추가
- [ ] SSH 키 다운로드 및 설정
- [ ] SSH 접속 성공
- [ ] UFW 방화벽 설정

---

## 다음 단계: n8n 설치

인스턴스 생성이 완료되면:
1. Docker 설치
2. n8n 컨테이너 실행
3. Keep-Alive 설정

(별도 가이드 참조)

---

## 주요 차이점 (이전 설정 대비)

| 항목 | 이전 | 새로 |
|------|------|------|
| OS | Oracle Linux 9 | Ubuntu 22.04 |
| Instance Type | VM.Standard.E2.1.Micro | VM.Standard.A1.Flex |
| CPU | AMD (1 OCPU) | ARM (2-4 OCPU) |
| RAM | 1GB | 12-24GB |
| 아키텍처 | x86_64 | aarch64 (ARM) |

**장점:**
- ✅ 메모리 12배 증가 (1GB → 12GB)
- ✅ 패키지 설치 문제 해결
- ✅ Docker/npm 설치 가능
- ✅ Ubuntu = 더 많은 커뮤니티 지원

---

## 참고 정보

### Always Free Tier 제한
- **VM.Standard.A1.Flex**: 최대 4 OCPU, 24GB RAM (총합)
  - 예: 인스턴스 1개 (4 OCPU, 24GB)
  - 예: 인스턴스 2개 (각 2 OCPU, 12GB)
- **Storage**: 최대 200GB Block Volume

### 권장 설정
- **OCPU**: 2개
- **RAM**: 12GB
- **Disk**: 50GB

이 설정으로 n8n + PostgreSQL을 여유롭게 실행할 수 있습니다.
