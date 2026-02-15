# n8n 로그인 정보 (Koyeb)

## 접속 정보
- **URL**: https://n8n-dogdoh1338-173f3ee3.koyeb.app
- **Email**: (생성 완료)
- **Password**: (생성 완료)

## API 키
- **API Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0YWJlNDVhNi1iNGFkLTRhYjUtODg0Zi1lZThjN2NhY2M2MTIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiNzMwYzU2NWItZjI4My00NDY3LThkMTctNzEwOGZiNTU4MjM3IiwiaWF0IjoxNzcxMTE1OTIxfQ.OPQUCSBXiZ8XsN5Z9xpuf_SkEOLiOu8uu4BIwMRAwtQ`
- **사용 예시**:
  ```bash
  curl -X GET https://n8n-dogdoh1338-173f3ee3.koyeb.app/api/v1/workflows \
    -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0YWJlNDVhNi1iNGFkLTRhYjUtODg0Zi1lZThjN2NhY2M2MTIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiNzMwYzU2NWItZjI4My00NDY3LThkMTctNzEwOGZiNTU4MjM3IiwiaWF0IjoxNzcxMTE1OTIxfQ.OPQUCSBXiZ8XsN5Z9xpuf_SkEOLiOu8uu4BIwMRAwtQ"
  ```

## 서버 정보
- **Provider**: Koyeb (무료 티어)
- **Region**: Frankfurt (fra)
- **Instance**: Free (512MB RAM, 0.1 vCPU)
- **Status**: HEALTHY ✅

## Koyeb 관리
- **대시보드**: https://app.koyeb.com
- **앱 이름**: n8n
- **서비스 이름**: n8n-service
- **도메인**: n8n-dogdoh1338-173f3ee3.koyeb.app

## CLI 명령어
```bash
# 서비스 상태 확인
/Users/admin/.koyeb/bin/koyeb service get n8n/n8n-service

# 앱 상태 확인
/Users/admin/.koyeb/bin/koyeb app get n8n

# 로그 확인 (런타임)
/Users/admin/.koyeb/bin/koyeb service logs n8n/n8n-service

# 로그 확인 (빌드)
/Users/admin/.koyeb/bin/koyeb service logs n8n/n8n-service -t build

# 서비스 재시작
/Users/admin/.koyeb/bin/koyeb service redeploy n8n/n8n-service

# 서비스 삭제
/Users/admin/.koyeb/bin/koyeb service delete n8n/n8n-service

# 앱 삭제
/Users/admin/.koyeb/bin/koyeb app delete n8n
```

## 생성된 워크플로우

### 1. Keep-Alive (필수)
- **ID**: WV1OgvdpNpiJMJ5M
- **상태**: ✅ Active
- **스케줄**: 매 5분마다
- **목적**: Koyeb scale-to-zero 방지, 24/7 무중단 운영
- **생성일**: 2026-02-15

### 2. Daily Health Check
- **ID**: NAgiDckJQ8sEBQRQ
- **상태**: ✅ Active
- **스케줄**: 매일 자정 UTC (오전 9시 KST)
- **목적**: 서버 상태 확인, 실행 기록
- **생성일**: 2026-02-15

### 3. Webhook Test Example
- **ID**: NQnOSpIsP6DAH96H
- **상태**: ✅ Active
- **URL**: https://n8n-dogdoh1338-173f3ee3.koyeb.app/webhook/test-endpoint
- **목적**: 외부 서비스 연동 예제
- **생성일**: 2026-02-15
- **참고**: 웹 UI에서 수정하여 HTTP 메소드 설정 필요

### 4. Auto Post to X (Twitter)
- **ID**: QWsCoVbHzuThUo0I
- **상태**: ✅ Active
- **스케줄**: 매 3시간마다
- **목적**: X(Twitter) 자동 게시
- **생성일**: 2026-02-15
- **특징**:
  - 동적 콘텐츠 생성 (5가지 인용구 중 랜덤)
  - 자동 해시태그 추가 (#automation #n8n)
  - 날짜 자동 포함
  - OAuth 1.0a 인증 사용
- **Credential**: X Main Account (ID: nBY9kzhLAyoK7Pdl)

## X API 인증 정보 (저장됨)
- **Credential ID**: nBY9kzhLAyoK7Pdl
- **Credential Name**: X Main Account
- **Type**: Twitter OAuth 1.0a
- **생성일**: 2026-02-15

## 다음 단계: Keep-Alive 워크플로우 설정

### ⚠️ 중요: Scale-to-Zero 방지

Koyeb 무료 티어는 15분 무트래픽시 자동 중지됩니다.
**해결책**: n8n Schedule Trigger로 자동 실행

### Keep-Alive 워크플로우 생성

1. **n8n 접속**: https://n8n-dogdoh1338-173f3ee3.koyeb.app
2. **계정 생성**: 이메일, 비밀번호 설정
3. **New Workflow** 생성
4. **Schedule Trigger 노드 추가**:
   - Trigger Rules: `Cron Expression`
   - Expression: `*/5 * * * *` (5분마다)
5. **HTTP Request 노드 추가**:
   - Method: `GET`
   - URL: `https://n8n-dogdoh1338-173f3ee3.koyeb.app`
6. **저장 및 활성화**:
   - 이름: `Keep-Alive`
   - Active: ✅ 체크

**결과**: 5분마다 자동 실행 → 서비스가 계속 깨어있음 → 24/7 무중단!

## 비용
- **Koyeb**: $0/월 (무료 티어)
- **n8n**: $0/월 (Community Edition)
- **총 비용**: $0/월

## 제약사항
- 무료 인스턴스 1개만 사용 가능
- 15분 무트래픽시 scale-to-zero (Keep-Alive로 방지 가능)
- 512MB RAM 제한

## 설치 일시
- **배포 날짜**: 2026-02-15
- **배포 시각**: 08:57 UTC (17:57 KST)

## 참고 자료
- [n8n 공식 문서](https://docs.n8n.io)
- [Koyeb 문서](https://www.koyeb.com/docs)
- [Schedule Trigger 가이드](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/)
- [설정 가이드](./KOYEB_SETUP_GUIDE.md)
