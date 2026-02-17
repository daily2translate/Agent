# X API 설정 가이드 - n8n 전용

## 🎯 목표
n8n만 사용하여 X(Twitter)에 자동으로 게시물 올리기

---

## ⚠️ 중요: X API Elevated Access 필요

### 현재 상황:
- ❌ **Free Tier**: 읽기 전용 (트윗 작성 불가)
- ✅ **Elevated Access**: 무료 + 트윗 작성 가능!
- ❌ **Basic ($100/월)**: 유료 플랜

### Elevated Access 신청 방법:

1. **X Developer Portal 접속**
   - https://developer.twitter.com/en/portal/dashboard

2. **Elevated Access 신청**
   - Portal → Overview → Apply for Elevated
   - 사용 목적 작성 (영어):
     ```
     I'm building a personal automation workflow to post scheduled tweets
     using n8n workflow automation tool. This will be used for:
     - Sharing blog posts automatically
     - Daily motivational quotes
     - Personal updates and announcements

     Expected usage: ~10 tweets per day
     No commercial use, personal project only.
     ```

3. **승인 대기** (보통 1-3일)

4. **승인 후 API 키 발급**

---

## 🔑 X API 인증 정보 생성

### 1단계: App 생성

1. https://developer.twitter.com/en/portal/projects-and-apps
2. **+ Create Project** 클릭
3. 프로젝트 정보 입력:
   - Project Name: `n8n-automation`
   - Use Case: `Making a bot`
   - Description: `Personal automation for scheduled tweets`

### 2단계: App 생성

1. App Name: `n8n-tweet-bot`
2. **Keys and Tokens** 탭으로 이동

### 3단계: API 키 발급

**필요한 4가지 키:**

1. **API Key** (Consumer Key)
   - Regenerate → 복사하여 저장

2. **API Secret Key** (Consumer Secret)
   - 함께 생성됨 → 복사하여 저장

3. **Access Token**
   - Generate → 복사하여 저장

4. **Access Token Secret**
   - 함께 생성됨 → 복사하여 저장

⚠️ **중요:** 이 키들은 한 번만 표시됩니다. 반드시 안전한 곳에 저장하세요!

---

## 🔧 n8n X Credentials 설정

### 방법 1: 웹 UI에서 수동 설정 (추천)

1. **n8n 접속**
   - https://n8n-dogdoh1338-173f3ee3.koyeb.app

2. **Credentials 메뉴**
   - 좌측 메뉴 → Settings → Credentials
   - **+ New Credential** 클릭

3. **Twitter OAuth2 API 선택**
   - 검색: `Twitter`
   - 선택: `Twitter OAuth2 API`

4. **인증 정보 입력**
   - API Key: `{your_api_key}`
   - API Secret: `{your_api_secret}`
   - Access Token: `{your_access_token}`
   - Access Token Secret: `{your_access_token_secret}`

5. **저장**
   - Credential Name: `X Main Account`
   - **Save** 클릭

---

## 🚀 n8n 워크플로우 생성

### 워크플로우 구조:

```
[Schedule Trigger] → [Set Tweet Content] → [Twitter Node] → [Success Notification]
```

### 노드 구성:

#### 1. Schedule Trigger
- **Trigger Interval**: `Hours`
- **Hours Between Triggers**: `1`
- 또는 Cron: `0 9,12,18 * * *` (오전 9시, 12시, 오후 6시)

#### 2. Set Tweet Content
- **Add Field** → String
- **Name**: `tweet_text`
- **Value**:
  ```
  안녕하세요! 자동화 테스트 중입니다. 🤖

  #n8n #automation #bot
  ```

#### 3. Twitter Node
- **Credential**: `X Main Account` (위에서 생성한 것)
- **Resource**: `Tweet`
- **Operation**: `Create`
- **Text**: `={{ $json.tweet_text }}`

#### 4. Success Notification (선택사항)
- HTTP Request로 자신에게 이메일 전송
- 또는 Slack 알림

---

## 🎨 고급 워크플로우 예시

### 예시 1: 동적 콘텐츠 생성

```javascript
// Code Node에서 실행
const quotes = [
  "성공은 매일의 작은 노력이 쌓여 만들어집니다. 💪",
  "오늘 할 수 있는 일을 내일로 미루지 마세요. 🚀",
  "실패는 성공의 어머니입니다. 계속 도전하세요! 🎯"
];

const now = new Date();
const dateStr = `${now.getFullYear()}년 ${now.getMonth()+1}월 ${now.getDate()}일`;

return {
  tweet_text: `${dateStr}\n\n${quotes[Math.floor(Math.random() * quotes.length)]}\n\n#motivation #daily`
};
```

### 예시 2: RSS 피드 자동 공유

```
[RSS Feed Read]
    ↓
[Filter: 새 글만]
    ↓
[Set Node: 제목 + 링크]
    ↓
[Twitter Node: 트윗 작성]
```

**Set Node 설정:**
```javascript
return {
  tweet_text: `📝 새 블로그 글: ${$json.title}\n\n${$json.link}\n\n#blog #tech`
};
```

### 예시 3: GitHub 활동 자동 공유

```
[Schedule Trigger: 매일 저녁 8시]
    ↓
[HTTP Request: GitHub API]
    ↓
[IF Node: 커밋 있으면]
    ↓
[Code Node: 요약 생성]
    ↓
[Twitter Node: 트윗]
```

---

## 📊 워크플로우 JSON (자동 생성용)

아래 JSON은 X API 키를 받은 후 사용할 수 있습니다:

```json
{
  "name": "Auto Post to X",
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
              "name": "tweet_text",
              "value": "안녕하세요! n8n 자동화 테스트 중입니다. 🤖\n\n#automation #n8n"
            }
          ]
        }
      },
      "name": "Set Tweet Content",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [450, 300]
    },
    {
      "parameters": {
        "resource": "tweet",
        "operation": "create",
        "text": "={{ $json.tweet_text }}"
      },
      "name": "Post Tweet",
      "type": "n8n-nodes-base.twitter",
      "typeVersion": 2,
      "position": [650, 300],
      "credentials": {
        "twitterOAuth2Api": {
          "id": "CREDENTIAL_ID_HERE",
          "name": "X Main Account"
        }
      }
    }
  ],
  "connections": {
    "Every Hour": {
      "main": [[{"node": "Set Tweet Content", "type": "main", "index": 0}]]
    },
    "Set Tweet Content": {
      "main": [[{"node": "Post Tweet", "type": "main", "index": 0}]]
    }
  }
}
```

---

## ✅ 설정 체크리스트

완료 여부를 확인하세요:

- [ ] X Developer 계정 생성
- [ ] Elevated Access 신청
- [ ] Elevated Access 승인 받음
- [ ] App 생성 완료
- [ ] 4가지 API 키 발급
- [ ] API 키 안전하게 저장
- [ ] n8n에서 X Credential 생성
- [ ] 테스트 워크플로우 생성
- [ ] 수동 테스트 성공
- [ ] 워크플로우 활성화

---

## 🔍 테스트 방법

### 1. Credential 테스트
1. n8n → Settings → Credentials
2. X Main Account 선택
3. **Test** 버튼 클릭
4. ✅ "Connection tested successfully" 확인

### 2. 워크플로우 테스트
1. 워크플로우 열기
2. **Test Workflow** 클릭
3. 실행 성공 확인
4. X에서 트윗 확인

---

## ⚠️ 주의사항

### X API 제한사항 (Elevated Access):
- 트윗 생성: **최대 300개/3시간**
- 충분히 여유로운 제한 (개인 사용)

### 추천 게시 빈도:
- 1시간에 1-2회
- 하루 10-20개 이하
- 동적 콘텐츠 사용 (중복 방지)

### 스팸 방지:
- ✅ 같은 내용 반복 게시 금지
- ✅ 해시태그 남용 금지
- ✅ 의미 있는 콘텐츠 게시

---

## 🚀 다음 단계

### 지금 바로 진행:

1. **X Developer Portal 접속**
   - https://developer.twitter.com/en/portal/dashboard

2. **Elevated Access 신청**
   - 위의 템플릿 사용

3. **승인 대기 중 준비사항:**
   - 게시할 콘텐츠 아이디어 정리
   - 워크플로우 구조 설계
   - 게시 스케줄 계획

4. **승인 후 즉시:**
   - API 키 발급
   - 저에게 키 제공 (또는 직접 n8n에 입력)
   - 워크플로우 자동 생성
   - 테스트 및 활성화

---

## 💡 팁

1. **이미지 첨부**: Twitter Node에서 Media 파라미터 사용
2. **Thread 작성**: 여러 트윗 연결
3. **멘션/해시태그**: 텍스트에 @username, #hashtag 포함
4. **URL 단축**: 자동으로 t.co로 단축됨
5. **에러 처리**: Error Trigger로 실패시 재시도

---

## 준비 완료!

X API Elevated Access가 승인되고 API 키를 받으시면:

**저에게 4가지 키를 제공하세요:**
1. API Key
2. API Secret
3. Access Token
4. Access Token Secret

즉시 n8n 워크플로우를 자동으로 생성하겠습니다! 🚀
