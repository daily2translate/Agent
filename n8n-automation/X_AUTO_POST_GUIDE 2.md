# X(Twitter) 자동 게시 워크플로우 가이드

## 🎯 목표
n8n을 사용하여 X(Twitter)에 자동으로 게시물을 올리는 워크플로우 구축

## ⚠️ X API 무료 티어 제약

### Free Tier 제한사항:
- ✅ 읽기 전용 (Read-only)
- ❌ 트윗 작성 불가 (POST 권한 없음)
- ❌ 좋아요, 리트윗 불가
- ✅ 트윗 검색, 프로필 조회만 가능

### 유료 플랜:
- **Basic**: $100/월 → 트윗 작성 가능
- **Pro**: $5,000/월 → 고급 기능

---

## ✅ 무료 해결책: IFTTT 연동 (추천)

### 작동 원리:
```
n8n Schedule Trigger
    ↓
n8n HTTP Request (IFTTT Webhook)
    ↓
IFTTT Applet
    ↓
X(Twitter) 자동 게시
```

### 장점:
- ✅ 완전 무료
- ✅ X API 키 불필요
- ✅ 설정 간단
- ✅ 신뢰성 높음

### 단점:
- ⚠️ IFTTT 무료 플랜: 5개 Applet 제한
- ⚠️ 커스터마이징 제약

---

## 📋 IFTTT 설정 방법

### 1단계: IFTTT 계정 생성

1. https://ifttt.com 접속
2. **Sign Up** (무료 계정)
3. 이메일 인증

---

### 2단계: X 계정 연결

1. IFTTT에서 **Create** 클릭
2. **If This** 클릭
3. **Webhooks** 검색 및 선택
4. **Receive a web request** 선택
5. Event Name 입력: `post_to_x` (또는 원하는 이름)
6. **Create Trigger**

---

### 3단계: X 작업 설정

1. **Then That** 클릭
2. **Twitter** 검색 및 선택 (X로 변경됨)
3. X 계정 연결 (로그인)
4. **Post a tweet** 선택
5. Tweet text 설정:
   ```
   {{Value1}}
   ```
   또는 커스텀 텍스트:
   ```
   {{Value1}}

   #automation #n8n
   ```
6. **Create Action**
7. **Finish** 클릭

---

### 4단계: Webhook URL 확인

1. IFTTT에서 **My Applets** → **Webhooks** → **Settings**
2. **Documentation** 클릭
3. Webhook URL 확인:
   ```
   https://maker.ifttt.com/trigger/{event}/with/key/{your_key}
   ```
4. `{event}`: `post_to_x` (위에서 설정한 이름)
5. `{your_key}`: IFTTT가 제공하는 고유 키

**예시:**
```
https://maker.ifttt.com/trigger/post_to_x/with/key/abc123xyz456
```

---

## 🔧 n8n 워크플로우 생성

### 방법 1: API로 자동 생성 (추천)

```bash
curl -X POST "https://n8n-dogdoh1338-173f3ee3.koyeb.app/api/v1/workflows" \
  -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Auto Post to X via IFTTT",
    "nodes": [
      {
        "parameters": {
          "rule": {"interval": [{}]},
          "intervalSize": 1,
          "unit": "hours"
        },
        "name": "Every Hour",
        "type": "n8n-nodes-base.scheduleTrigger",
        "typeVersion": 1.2,
        "position": [250, 300]
      },
      {
        "parameters": {
          "values": {
            "string": [
              {
                "name": "tweet_content",
                "value": "안녕하세요! n8n 자동화 테스트 중입니다. 🤖 #automation"
              }
            ]
          },
          "options": {}
        },
        "name": "Set Tweet Content",
        "type": "n8n-nodes-base.set",
        "typeVersion": 3.4,
        "position": [450, 300]
      },
      {
        "parameters": {
          "method": "POST",
          "url": "https://maker.ifttt.com/trigger/post_to_x/with/key/YOUR_IFTTT_KEY",
          "sendBody": true,
          "bodyParameters": {
            "parameters": [
              {
                "name": "value1",
                "value": "={{ $json.tweet_content }}"
              }
            ]
          },
          "options": {}
        },
        "name": "Send to IFTTT",
        "type": "n8n-nodes-base.httpRequest",
        "typeVersion": 4.2,
        "position": [650, 300]
      }
    ],
    "connections": {
      "Every Hour": {
        "main": [[{"node": "Set Tweet Content", "type": "main", "index": 0}]]
      },
      "Set Tweet Content": {
        "main": [[{"node": "Send to IFTTT", "type": "main", "index": 0}]]
      }
    }
  }'
```

**주의:** `YOUR_IFTTT_KEY`를 실제 IFTTT Webhook 키로 교체하세요!

---

### 방법 2: 웹 UI에서 수동 생성

1. n8n 웹 UI 접속: https://n8n-dogdoh1338-173f3ee3.koyeb.app
2. **New Workflow** 클릭
3. 노드 추가:

#### 노드 1: Schedule Trigger
- Trigger Interval: `Hours`
- Hours between triggers: `1` (매시간 실행)

#### 노드 2: Set Node (선택사항)
- Add Field → String
- Name: `tweet_content`
- Value: `안녕하세요! n8n 자동화 테스트 중입니다. 🤖`

#### 노드 3: HTTP Request
- Method: `POST`
- URL: `https://maker.ifttt.com/trigger/post_to_x/with/key/YOUR_IFTTT_KEY`
- Body Content Type: `JSON`
- Body:
  ```json
  {
    "value1": "{{ $json.tweet_content }}"
  }
  ```

4. 노드 연결:
   ```
   [Schedule Trigger] → [Set Node] → [HTTP Request]
   ```

5. **Save** 및 **Activate**

---

## 🎨 고급 설정

### 동적 콘텐츠 생성

#### 예시 1: 날짜/시간 포함
```
오늘은 {{ $now.format('YYYY년 MM월 DD일') }}입니다! #automation
```

#### 예시 2: 랜덤 메시지
Set Node에서 Code 사용:
```javascript
const messages = [
  "안녕하세요! n8n 자동화 테스트 1 🤖",
  "자동화의 힘! n8n으로 만들었습니다. 💪",
  "n8n + IFTTT = 완벽한 조합! 🎯"
];

return {
  tweet_content: messages[Math.floor(Math.random() * messages.length)]
};
```

#### 예시 3: RSS 피드 자동 공유
1. RSS Feed Read 노드 추가
2. 새 글 감지
3. 제목 + 링크를 X에 자동 게시

```
[RSS Feed Read] → [Filter] → [Set Tweet] → [HTTP Request (IFTTT)]
```

---

## 🔍 테스트 방법

### 1. IFTTT Webhook 테스트 (curl)
```bash
curl -X POST https://maker.ifttt.com/trigger/post_to_x/with/key/YOUR_IFTTT_KEY \
  -H "Content-Type: application/json" \
  -d '{"value1": "테스트 트윗입니다! #n8n #automation"}'
```

**결과:** X에 트윗이 즉시 게시됨

### 2. n8n에서 수동 실행
1. 워크플로우 열기
2. **Test Workflow** 클릭
3. 실행 결과 확인
4. X에서 트윗 확인

---

## 📊 워크플로우 예시

### 예시 1: 매일 아침 인사 트윗
```
Schedule Trigger (매일 09:00 KST)
    ↓
Set Node (인사 메시지)
    ↓
HTTP Request (IFTTT)
```

**메시지:**
```
좋은 아침입니다! 오늘도 화이팅! 🌞 #goodmorning
```

### 예시 2: GitHub 활동 자동 공유
```
Schedule Trigger (매일 20:00 KST)
    ↓
HTTP Request (GitHub API - 오늘의 커밋 조회)
    ↓
IF Node (커밋 있으면)
    ↓
Set Node (커밋 메시지 생성)
    ↓
HTTP Request (IFTTT)
```

### 예시 3: 블로그 RSS 자동 공유
```
RSS Feed Read (1시간마다)
    ↓
Filter (새 글만)
    ↓
Set Node (제목 + 링크)
    ↓
HTTP Request (IFTTT)
```

---

## ⚠️ 주의사항

### IFTTT 제약사항:
- 무료 플랜: 5개 Applet 제한
- 실행 지연: 최대 1-5분 (즉시 실행 아님)
- 복잡한 로직 불가능

### X(Twitter) 정책:
- ✅ 스팸 방지: 같은 내용 반복 게시 금지
- ✅ 빈도 제한: 너무 자주 게시하지 말 것
- ✅ 저작권 준수

### 추천 게시 빈도:
- 1시간에 1회 이하
- 하루 10-15개 이하
- 동적 콘텐츠 사용 (중복 방지)

---

## 🚀 다음 단계

1. **IFTTT 계정 생성 및 Applet 설정**
2. **Webhook URL 확인**
3. **n8n 워크플로우 생성** (API 또는 UI)
4. **테스트 실행**
5. **활성화 및 모니터링**

---

## 📚 참고 자료

- [IFTTT 공식 문서](https://ifttt.com/docs)
- [IFTTT Webhooks](https://ifttt.com/maker_webhooks)
- [n8n HTTP Request 노드](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [X Developer Portal](https://developer.twitter.com/)

---

## 💡 팁

1. **동적 콘텐츠 사용**: 같은 메시지 반복 방지
2. **해시태그 활용**: 노출 증가
3. **이미지 추가**: IFTTT에서 이미지 URL 지원
4. **에러 처리**: n8n IF 노드로 실패시 재시도
5. **로그 저장**: 게시 내역을 구글 시트에 자동 저장

---

## 준비 완료!

이제 IFTTT Webhook URL만 제공하시면 즉시 워크플로우를 생성하겠습니다! 🚀
