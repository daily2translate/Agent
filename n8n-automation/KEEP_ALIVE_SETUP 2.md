# n8n Keep-Alive 워크플로우 설정 가이드

## ⚠️ 중요: 이 설정을 반드시 해야 합니다!

Koyeb 무료 티어는 **15분 무트래픽시 자동 중지**됩니다.
Keep-Alive 워크플로우를 설정하면 **24/7 무중단** 운영이 가능합니다.

---

## 🚀 빠른 설정 (5분)

### 1단계: n8n 접속

```
https://n8n-dogdoh1338-173f3ee3.koyeb.app
```

로그인하세요.

---

### 2단계: 새 워크플로우 생성

1. 좌측 상단 **"+ New Workflow"** 클릭
2. 빈 캔버스가 나타남

---

### 3단계: Schedule Trigger 노드 추가

1. 캔버스에서 **"+"** 버튼 클릭
2. 검색창에 **"Schedule Trigger"** 입력
3. **Schedule Trigger** 노드 선택

#### 설정:
- **Trigger Interval**: `Cron`
- **Cron Expression**: `*/5 * * * *`

이 설정은 **매 5분마다** 워크플로우를 실행합니다.

**Cron 표현식 설명:**
```
*/5 * * * *
│   │ │ │ │
│   │ │ │ └─── 요일 (0-7, 0과 7은 일요일)
│   │ │ └───── 월 (1-12)
│   │ └─────── 일 (1-31)
│   └───────── 시간 (0-23)
└─────────── 분 (0-59, */5 = 5분마다)
```

**다른 주기 예시:**
- `*/10 * * * *` - 10분마다
- `*/15 * * * *` - 15분마다
- `0 * * * *` - 매시간 정각

---

### 4단계: HTTP Request 노드 추가

1. Schedule Trigger 노드 옆 **"+"** 클릭
2. 검색창에 **"HTTP Request"** 입력
3. **HTTP Request** 노드 선택

#### 설정:
- **Method**: `GET`
- **URL**: `https://n8n-dogdoh1338-173f3ee3.koyeb.app`

---

### 5단계: 노드 연결

Schedule Trigger 노드와 HTTP Request 노드를 연결합니다:
- Schedule Trigger 노드 우측 점을 드래그
- HTTP Request 노드로 연결

**결과:**
```
[Schedule Trigger] ──→ [HTTP Request]
```

---

### 6단계: 워크플로우 저장 및 활성화

1. 우측 상단 **"Save"** 버튼 클릭
2. 워크플로우 이름: `Keep-Alive` 입력
3. **"Save"** 확인
4. 우측 상단 **"Active" 토글** 클릭 (꺼짐 → 켜짐)
   - 비활성화: 회색
   - **활성화: 초록색** ✅

---

## ✅ 설정 완료!

이제 n8n이 **24/7 무중단**으로 작동합니다!

### 작동 원리:
```
매 5분마다 → Schedule Trigger 실행
           → HTTP Request로 자기 자신에게 ping
           → Koyeb이 트래픽 감지
           → 서비스 유지 (중지 안됨)
```

---

## 🔍 테스트

### 워크플로우 수동 실행:
1. **"Test Workflow"** 버튼 클릭
2. 성공 메시지 확인
3. HTTP Request 노드에 200 응답 표시

### 자동 실행 확인:
1. 5분 대기
2. 좌측 메뉴 **"Executions"** 클릭
3. Keep-Alive 워크플로우 실행 기록 확인

---

## 📊 실행 내역 확인

**Executions 페이지:**
- 최근 실행 시간
- 성공/실패 여부
- 실행 횟수

**예상 실행 횟수:**
- 1시간: 12회 (60분 ÷ 5분)
- 1일: 288회
- 1주: 2,016회
- 1달: ~8,640회

---

## 🛠️ 고급 설정 (선택사항)

### 방법 1: 더 긴 주기 (10분)

Cron Expression: `*/10 * * * *`

**장점**: 실행 횟수 절반 (리소스 절약)
**단점**: 15분에 가까워서 위험

### 방법 2: 더 짧은 주기 (3분)

Cron Expression: `*/3 * * * *`

**장점**: 더 안전한 Keep-Alive
**단점**: 실행 횟수 증가

### 방법 3: 실제 작업 + Keep-Alive

Keep-Alive 대신 실제 유용한 작업을 5-10분마다 실행:

**예시 A: 날씨 정보 수집**
```
[Schedule Trigger] → [HTTP Request (날씨 API)] → [구글 시트 저장]
```

**예시 B: RSS 피드 모니터링**
```
[Schedule Trigger] → [RSS Feed Read] → [새 글 필터] → [Slack 알림]
```

**예시 C: 웹사이트 모니터링**
```
[Schedule Trigger] → [HTTP Request] → [상태 체크] → [이메일 알림]
```

---

## ⚠️ 주의사항

### Keep-Alive가 작동하지 않으면:

1. **Active 토글 확인**
   - 초록색이어야 함
   - 회색이면 클릭해서 활성화

2. **Cron Expression 확인**
   - `*/5 * * * *` 정확히 입력
   - [crontab.guru](https://crontab.guru) 에서 검증

3. **HTTP Request URL 확인**
   - `https://n8n-dogdoh1338-173f3ee3.koyeb.app`
   - 본인의 Koyeb URL 사용

4. **Executions 확인**
   - 5분마다 실행 기록이 생기는지 확인
   - 에러가 있다면 로그 확인

---

## 🔧 트러블슈팅

### Q: 워크플로우가 실행되지 않아요
**A:** Active 토글이 켜져있는지 확인

### Q: HTTP Request가 실패해요
**A:** URL이 정확한지 확인 (https:// 포함)

### Q: 5분마다 실행되지 않아요
**A:** Cron Expression 확인: `*/5 * * * *`

### Q: Koyeb이 여전히 중지돼요
**A:**
1. 워크플로우 Active 상태 확인
2. Executions에서 실행 기록 확인
3. 주기를 3분으로 단축 시도

---

## 📚 참고 자료

- [n8n Schedule Trigger 문서](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/)
- [Cron Expression Generator](https://crontab.guru)
- [Koyeb Scale-to-Zero 설명](https://www.koyeb.com/docs/run-and-scale/scale-to-zero)

---

## ✅ 체크리스트

설정이 완료되었는지 확인하세요:

- [ ] 워크플로우 생성 완료
- [ ] Schedule Trigger 노드 추가 (Cron: `*/5 * * * *`)
- [ ] HTTP Request 노드 추가 (URL: Koyeb URL)
- [ ] 노드 연결 완료
- [ ] 워크플로우 저장 완료
- [ ] **Active 토글 활성화** ✅ (가장 중요!)
- [ ] Test Workflow 성공 확인
- [ ] 5분 후 Executions에서 자동 실행 확인

**모든 항목이 체크되면 24/7 무중단 운영 완료!** 🎉
