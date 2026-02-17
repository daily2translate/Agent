# n8n Automation Environment

Agent 워크스페이스를 위한 n8n 자동화 환경입니다. Cloudflare Tunnel을 통해 외부에서 접근 가능합니다.

## 설치

```bash
npm install
```

## 사용법

### 1. Cloudflare Tunnel과 함께 시작

```bash
npm run start:tunnel
```

또는

```bash
bash start-with-tunnel.sh
```

### 2. 중지

```bash
bash stop.sh
```

## 접속 정보

시작 시 자동 생성된 URL과 인증 정보가 터미널에 표시됩니다.

- **URL**: `logs/tunnel-url.txt` 파일 참조
- **Username**: `admin`
- **Password**: `.env` 파일의 `N8N_BASIC_AUTH_PASSWORD` 참조

## 로그 확인

```bash
# n8n 로그
tail -f logs/n8n.log

# Cloudflare Tunnel 로그
tail -f logs/cloudflare.log
```

## 디렉토리 구조

- `.n8n/` - n8n 데이터 저장소
- `logs/` - 로그 파일
- `.env` - 환경 변수 설정
