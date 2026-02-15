# Koyeb n8n 완전 무료 24/7 가이드

## 🎯 개요
Koyeb 무료 티어로 n8n을 24/7 무중단으로 실행하는 방법

## ⚠️ Koyeb Scale-to-Zero 동작
- 무료 티어는 15분 무트래픽시 자동 중지
- 첫 요청시 5-10초 콜드 스타트
- **해결책**: n8n Schedule Trigger로 자동 실행

---

## 🚀 배포 단계

### 1. Koyeb 가입 및 배포
```bash
cd "/Users/admin/Library/Mobile Documents/iCloud~md~obsidian/Documents/Agent/n8n-automation"
./deploy-koyeb.sh
```

### 2. n8n 접속
배포 완료 후 제공된 URL로 접속:
```
https://n8n-app-YOUR_ORG.koyeb.app
```

### 3. 초기 계정 생성
- 이메일 입력
- 비밀번호 설정 (기억할 것!)
- Owner 계정 생성 완료

---

## 🔄 24/7 Keep-Alive 워크플로우 설정

### 방법 A: 간단한 Self-Ping (5분)

1. **New Workflow 생성**
2. **Schedule Trigger 노드 추가**
   - Trigger Rules: `Cron Expression`
   - Expression: `*/5 * * * *` (5분마다)

3. **HTTP Request 노드 추가**
   - Method: `GET`
   - URL: `https://n8n-app-YOUR_ORG.koyeb.app`

4. **워크플로우 저장 및 활성화**
   - 이름: `Keep-Alive`
   - Active: ✅ 활성화

**결과**: 5분마다 자동 실행 → Koyeb이 계속 깨어있음

---

### 방법 B: 실제 작업 + Keep-Alive (10분)

**예시 1: 날씨 알림**
```
[Schedule Trigger (10분)] → [HTTP Request (날씨 API)] → [Slack 메시지]
```

**예시 2: RSS 모니터링**
```
[Schedule Trigger (15분)] → [RSS Feed Read] → [필터링] → [Discord 알림]
```

**예시 3: 웹사이트 모니터링**
```
[Schedule Trigger (5분)] → [HTTP Request] → [상태 체크] → [이메일 알림]
```

---

## 📊 Schedule Trigger 설정 예시

### 매 5분마다
```
*/5 * * * *
```

### 매 10분마다
```
*/10 * * * *
```

### 매 30분마다
```
*/30 * * * *
```

### 매시간 정각
```
0 * * * *
```

### 매일 오전 9시
```
0 9 * * *
```

---

## 🎯 권장 설정

**최소한의 Keep-Alive:**
- Schedule: 매 **10분** (`*/10 * * * *`)
- 이유: Koyeb은 15분 무트래픽시 중지

**안전한 Keep-Alive:**
- Schedule: 매 **5분** (`*/5 * * * *`)
- 이유: 여유있게 중지 방지

---

## 📝 배포 후 로그인 정보 저장

**파일**: `N8N_LOGIN_INFO.md`

```markdown
# n8n 로그인 정보 (Koyeb)

## 접속 정보
- **URL**: https://n8n-app-YOUR_ORG.koyeb.app
- **Email**: your-email@example.com
- **Password**: [생성한 비밀번호]

## Koyeb 관리
- **대시보드**: https://app.koyeb.com
- **서비스**: n8n-app

## CLI 명령어
```bash
# 상태 확인
koyeb service get n8n-app

# 로그 확인
koyeb service logs n8n-app

# 재시작
koyeb service redeploy n8n-app
```

## Keep-Alive 워크플로우
- **이름**: Keep-Alive
- **스케줄**: 매 5분 (`*/5 * * * *`)
- **상태**: ✅ 활성화

## 설치 날짜
2026-02-15
```

---

## 🔧 트러블슈팅

### 문제: 서비스가 자꾸 중지됨
**원인**: Keep-Alive 워크플로우가 비활성화됨
**해결**: 워크플로우 Active 체크박스 확인

### 문제: 워크플로우가 실행 안됨
**원인**: Cron Expression 오류
**해결**: https://crontab.guru 에서 표현식 검증

### 문제: 콜드 스타트 느림
**원인**: Scale-to-zero 후 재시작
**해결**: Keep-Alive 주기를 5분으로 단축

---

## 💰 비용

**Koyeb 무료 티어:**
- ✅ 영구 무료
- ✅ 512MB RAM
- ✅ 무료 PostgreSQL 포함
- ✅ 신용카드 불필요
- ⚠️ 1개 서비스만 무료

**n8n 라이센스:**
- ✅ Community Edition 완전 무료
- ✅ 무제한 워크플로우
- ✅ 무제한 실행

**총 비용: $0/월**

---

## 📚 추가 자료

- [n8n Schedule Trigger 문서](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/)
- [Koyeb Scale-to-Zero 설명](https://www.koyeb.com/docs/run-and-scale/scale-to-zero)
- [Cron Expression Generator](https://crontab.guru)
- [n8n 커뮤니티](https://community.n8n.io)
