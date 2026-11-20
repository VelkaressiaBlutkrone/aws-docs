# Play 제출 초안 — Data safety · 스토어 등록정보 (A8, 2026-11-20)

> **초안이다.** Play Console 에 넣고 **제출하는 것은 사람**이다(로드맵 §6). 아래 답은 코드·번들·공식 문서에서
> 실측한 것이고, 실측으로 정할 수 없는 것은 ⚖️ 로 표시해 **결정을 사람에게 남겼다.**
> 처리방침 본문은 `flutter_app/web/privacy.html`, 삭제 안내는 `flutter_app/web/delete-account.html` 이 정본이며
> `flutter_app/test/legal_pages_test.dart` 가 코드와의 일치를 지킨다.

## 0. 공개 URL (main 릴리스 뒤 200)

| 항목 | URL |
|---|---|
| 개인정보처리방침 | `https://velkaressiablutkrone.github.io/aws-docs/privacy.html` |
| 계정 삭제 요청(웹 리소스) | `https://velkaressiablutkrone.github.io/aws-docs/delete-account.html` |
| 연락처(공개) | `info@leva.ai.kr` — ⚖️ **메일함·별칭이 실제로 받는지 시험 메일로 확인**(DNS 의 MX 가 `smtp.google.com` 인 것까지만 실측했다) |

## 1. Data safety 답안

### 1-1. 개요 질문

| 질문 | 답 | 근거 |
|---|---|---|
| 필수 사용자 데이터 유형을 수집하거나 공유합니까? | **예(수집)** | 로그인하면 Firebase Auth·Firestore 로 기기 밖에 전송된다. Play 의 「수집」은 기기 밖 전송이다 |
| 모든 사용자 데이터가 전송 중 암호화됩니까? | **예** | Firebase·R2·GitHub Pages 모두 HTTPS 다 |
| 사용자가 데이터 삭제를 요청할 수 있습니까? | **예** | 앱 안 「계정 삭제」(A7) + 위 웹 URL + 이메일 |
| 계정 생성 방식 | **OAuth(Google 로그인)** | 앱 자체 아이디·비밀번호가 없다 |

### 1-2. 수집 데이터

전부 **선택(optional)** 이다 — 로그인하지 않으면 학습 기록은 기기에만 남고 아무것도 전송되지 않는다.
**공유 없음** — Firebase 는 개발자를 대신해 처리하는 **서비스 제공자**라 Play 정의상 「공유」가 아니다.

| 데이터 유형 | 수집 | 목적 | 근거 |
|---|---|---|---|
| 개인 정보 › **이메일 주소** | 예 · 선택 | 앱 기능, 계정 관리 | Firebase Auth 사용자 레코드 |
| 개인 정보 › **사용자 ID** | 예 · 선택 | 앱 기능, 계정 관리 | Firebase uid 가 Firestore 경로 `users/{uid}` 다 |
| 개인 정보 › **이름** | ⚖️ **예 · 선택 권장** | 계정 관리 | 앱 코드는 이름을 읽지 않지만 Google 로그인 시 Firebase Auth 레코드에 표시 이름이 **담길 수 있다**. SDK 가 수집하는 것도 신고 대상이라 신고 쪽이 안전하다 |
| 앱 활동 › **앱 상호작용** | 예 · 선택 | 앱 기능 | 동기 컬렉션 6종(`attempts`·`checks`·`meta`·`plans`·`progress`·`viewed`, `kSyncedCollections`) |
| 앱 활동 › 기타 사용자 생성 콘텐츠 | ⚖️ 판단 필요 | — | `plans`(학습 계획)는 사용자가 고른 날짜·범위라 「앱 상호작용」으로 볼 수도 있다. 자유 텍스트 입력은 없다 |

**신고하지 않는 것(실측)**

| 유형 | 이유 |
|---|---|
| 위치(대략·정확) | IP 를 위치 추정에 쓰지 않는다. Firebase Auth 의 보안용 IP 로그는 위치 용도가 아니다 |
| 기기 또는 기타 ID | Firebase Installations·Analytics·Crashlytics·Messaging·광고 SDK 가 **lock 에 없다** — `legal_pages_test` 가 그 부재를 고정한다(넣으면 테스트가 먼저 깨진다) |
| 앱 정보 및 성능(비정상 종료 로그 등) | 위와 같다. `appLog` 는 콘솔에만 찍는다 |
| 오디오·사진·연락처·금융·건강·메시지 | 없음. **Android 앱에는 강의 음성이 없다**(웹 전용, R2 서빙) |

### 1-3. 보안 관행

- 전송 중 암호화: 예
- 삭제 요청 방법: 앱 안 「메뉴 › 기기 간 동기 › 계정 삭제」 · 웹 URL · 이메일
- ⚖️ 독립 보안 검토(MASA): 받지 않았다 → 「아니요」

### 1-4. 이메일 삭제 요청 처리 절차(사람)

웹 페이지가 「본인 확인 뒤 지체 없이 삭제하고 결과를 회신」을 약속하므로 받으면 다음을 한다.

1. 요청 메일의 발신 주소가 로그인 이메일과 같은지 본다(다르면 그 계정에서 다시 보내 달라고 회신).
2. Firebase 콘솔 › Authentication 에서 그 이메일의 **uid** 를 찾는다.
3. Firestore 콘솔에서 `users/{uid}` 아래 6개 컬렉션을 지운다 — ⚠️ **문서를 지워도 하위 컬렉션은 남는다.** 컬렉션 단위로 지운다.
4. Authentication 에서 그 사용자를 삭제한다(**문서가 먼저** — 앱의 A7 순서와 같다).
5. 결과를 회신한다.

## 2. 스토어 등록정보 초안

⚖️ **앱 이름은 사람이 정한다(로드맵 A0).** 「AWS Docs Roadmap」은 AWS 상표를 앞에 두어 Play 의 사칭·상표
정책에 걸릴 수 있다. 아래는 현재 이름을 쓰되 **비공식 고지**를 설명 첫 단락에 두었다.

- **앱 이름(30자 이내)** — ⚖️ 미정. 후보: `AWS 자격증 이해 노트`(상표를 서술적으로만 쓰는 형태) · 현행 `AWS Docs Roadmap`
- **간단한 설명(80자 이내)**
  `AWS 자격증을 한국어로, 외우지 않고 이해하며 공부하는 학습 문서와 모의고사 (비공식)`
- **자세한 설명(4,000자 이내)**

```
AWS 자격증을 한국어로, 이해 중심으로 공부하는 학습 도구입니다.

이 앱은 Amazon Web Services, Inc.와 제휴하거나 그 승인을 받지 않은 비공식 학습 도구입니다.

■ 무엇을 공부하나요
공식 시험 가이드의 작업(Task) 단위로 나눈 학습 문서와 연습 문항을 제공합니다.
Cloud Practitioner, Solutions Architect – Associate, CloudOps Engineer – Associate,
Data Engineer – Associate, Machine Learning Engineer – Associate, AI Practitioner,
Security – Specialty, Generative AI Developer – Professional 과정을 다룹니다.

■ 검수한 문항만 보여 줍니다
문항은 사람이 공식 문서와 대조해 검수한 것만 공개됩니다. 아직 검수 중인 범위는
「준비 중」으로 표시하고 숨기지 않습니다.

■ 모의고사와 오답 노트
공식 도메인 비중에 맞춘 통합 모의고사, 틀린 문항 다시 풀기, 약점 리포트를 제공합니다.
시험 중에 앱을 닫아도 이어서 풀 수 있습니다.

■ 기기 간 동기(선택)
Google 계정으로 로그인하면 학습 기록을 여러 기기에서 이어 볼 수 있습니다.
로그인하지 않아도 모든 기능을 쓸 수 있고, 기록은 기기에만 저장됩니다.
앱 안에서 언제든 계정과 동기된 기록을 삭제할 수 있습니다.
```

⚠️ 자격증 목록은 **공개 문항이 있는 것만** 적어야 한다 — 제출 직전 `grep -l '"verified": true'` 로 다시 센다
(DVA-C03 은 미등재라 넣지 않았다). 공식 자격증 영문 명칭은 제출 전에 AWS 인증 페이지와 대조한다.

- **카테고리** — 교육
- **태그·연락처** — 이메일 `info@leva.ai.kr`, 웹사이트 `https://velkaressiablutkrone.github.io/aws-docs/`
- **그래픽** — 아이콘 512×512 는 `tool/make_app_icon.py` 로 만든다(A6-3 자산). 스크린샷·기능 그래픽은 **A8-2** 에서 에뮬레이터로 만든다.

## 3. 사람이 결정·확인할 것

1. `info@leva.ai.kr` 수신 확인(시험 메일)
2. 앱 이름(A0) — 상표 위험
3. 대상 연령 — 처리방침이 「만 14세 미만 대상 아님」으로 적었다. Play 「타겟층」 답을 **18세 이상** 또는 **13세 이상** 중 무엇으로 할지(아동 대상이 아님과 일치해야 한다)
4. Data safety 의 「이름」 신고 여부와 `plans` 분류
5. 이메일 삭제 처리 약속(1-4)을 운영할 수 있는지
6. 콘텐츠 등급 설문 — A8-2 에서 초안
