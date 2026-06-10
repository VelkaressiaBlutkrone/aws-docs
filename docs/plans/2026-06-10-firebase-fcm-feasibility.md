# Firebase·FCM 도입 타당성 검토 — 데이터 동기 + 일정 푸시/알림

작성일: 2026-06-10
범위: (A) Firebase로 학습 데이터(일정·진행) 저장/동기, (B) FCM으로 일정 푸시·알림
대상 아키텍처: Flutter Web + **GitHub Pages(정적 호스팅)** + localStorage + **무계정**

---

## 0. 결론 요약

| 영역 | 가능성 | 핵심 제약 |
|---|---|---|
| **데이터 저장·동기 (Firestore + Auth)** | ✅ 충분히 가능 | 호스팅 이전 불필요(클라이언트 SDK). 무료 티어로 이 규모 충분. 비용은 *복잡도*(인증+동기+규칙)와 *제품 방향 전환*(계정·Google 의존·개인정보). |
| **일정 푸시·정시 알림 (FCM)** | ⚠️ 가능하나 제약+추가 인프라 | 예약 발송은 정적 호스팅만으론 불가 → **Cloud Functions(Blaze) + Cloud Scheduler + Firestore** 필요(저장과 묶임). 웹 푸시 신뢰성이 네이티브보다 본질적으로 약함(특히 iOS·앱 종료 시). |

**권장:** 서버 없이 즉시 가치를 내는 **Phase 0(앱 내 "오늘 할 일/밀림" 알림)**부터. 클라우드/푸시는 "정직한 로컬 도구 → 계정 기반 클라우드 앱" 전환 의사를 정한 뒤 단계적으로.

---

## 1. 현 아키텍처와의 적합성

- 현재: localStorage(`awsdocs.{plan,history,viewed,checks}`) + 무계정 + 정적 호스팅(서버 없음). `KvBackend` 추상화 덕에 저장소 교체/추가가 깔끔.
- Firebase는 서버리스 프론트와 궁합이 좋다 → **GitHub Pages는 호스팅만 유지, Firebase(Google 백엔드)를 클라이언트에서 호출.** 호스팅 마이그레이션 불필요.
- **유일한 예외:** *예약 푸시 발송*은 "특정 시각에 서버가 send를 트리거"해야 하므로 정적 호스팅 밖의 서버(=Cloud Functions)가 필요.

## 2. Part A — Firebase 데이터 저장 (Firestore + Auth)

### 목적·전제
- 목적(추정): **기기 간 동기·백업** (현 localStorage는 브라우저·기기별 독립, 동기 X).
- 동기하려면 **신원** 필요 → Firebase **Auth**:
  - **익명 인증**: 클라우드 백업 가능하나 기기별(동기 X; 나중에 계정 연결 시 가능).
  - **로그인(Google/이메일)**: 진짜 기기 간 동기. → 로그인 UI·동선 추가.

### 통합
- FlutterFire: `firebase_core`, `cloud_firestore`, `firebase_auth`. `flutterfire configure`로 `firebase_options.dart` 생성. **웹 지원 O.**
- 데이터 모델: 현 4개 키 → `users/{uid}/state` 문서들(작은 JSON). 
- **`KvBackend` seam 활용**: `FirestoreBackend implements KvBackend` 또는 로컬↔클라우드 동기 레이어(오프라인 우선 + 동기 충돌 해소: offline edit vs cloud last-write-wins/머지).
- **Firestore 보안 규칙**: `users/{uid}` uid 격리 필수.

### 비용·난이도
- 비용: Spark(무료) 티어 — Firestore 1GiB·일 5만 read/2만 write 등 → 이 규모면 사실상 무료.
- 난이도: 중~중상(인증 동선 + 오프라인·동기 충돌 + 보안 규칙).

### ⚠️ 제품/브랜드 함의 (가장 중요)
현재는 무계정·무서버·무추적의 "정직한 공부 도구". 클라우드+계정은 **Google 의존·개인정보처리방침·(EU)GDPR 고려**를 부르고, DESIGN.md "파는 곳이 아니라 공부하는 곳" 정서와 충돌할 수 있는 **방향 결정**.

## 3. Part B — FCM 푸시 + 일정 알림

웹 FCM 수신 자체는 가능: `firebase_messaging`(≥11.2.8) + `web/firebase-messaging-sw.js`(정적 파일, Pages OK) + **VAPID 웹푸시 키** + 알림 권한 + HTTPS(Pages OK). 그러나 3중 제약:

- **제약 ① 예약 발송엔 서버 필요.** FCM은 "서버→기기" 푸시. "오늘 학습 알림"을 *정시에* 보내려면 그 시각에 send를 트리거할 서버 필요 → GitHub Pages(정적) 불가 → **Cloud Functions for Firebase(Blaze 종량제) + Cloud Scheduler(cron)**: cron 함수가 Firestore의 일정·FCM 토큰을 읽어 대상자에게 발송. (Scheduler 잡 3개 무료, 이후 ~$0.10/잡/월) → **Part A(Firestore 저장)와 사실상 묶임.**
- **제약 ② 웹 푸시 신뢰성.**
  - 데스크톱(Chrome/FF/Edge): 브라우저가 백그라운드로 살아있으면 SW가 깨워져 알림 OK, 완전 종료 시 OS따라 제한.
  - **iOS: Push API는 "홈 화면에 추가(설치형 PWA)"에서만**, iOS 16.4+. Safari 탭/모든 iOS 브라우저(WebKit) 동일 제약. EU는 DMA로 한때 standalone PWA 푸시 제거 등 유동적. → iOS는 PWA 설치를 유도해도 반쪽.
  - 안드로이드 크롬: 탭에서도 비교적 양호.
- **제약 ③ 클라이언트-only 예약 불가.** 탭 닫힌 뒤 정시 알림을 *서버 없이* 띄우는 표준 웹 API 없음(Notification Triggers는 실험·사실상 폐기). → 서버 경로가 유일.

### 대안 (정시 알림이 진짜 목표라면)
웹 푸시는 본질적으로 약함. 현실적 후보:
- (a) **PWA 설치 유도 + FCM** — iOS 포함 커버하나 설치 마찰.
- (b) **이메일 리마인더** — 서버 cron 발송, 웹푸시 제약 회피, 더 신뢰성↑·구현 단순. (이메일 주소 필요 → 계정)
- (c) **네이티브/모바일 앱** — 가장 신뢰성↑, 가장 큰 투자.

## 4. 단계적 권장안 (각 단계 독립 가치)

- **Phase 0 — 서버 없이 지금 가능·최고신뢰:** 앱 내 **"오늘 할 일/밀림" 표시**(홈 일정 카드·어젠다 상단) + (선택) 브라우저 열렸을 때 `Notification` 가벼운 알림. 데이터(`computePlanDone`/`isOverdue`)가 이미 있어 *며칠*. 푸시는 아니지만 "열면 확실".
- **Phase 1 — 동기:** Firestore + Auth(우선 익명/Google). `KvBackend`에 클라우드 동기 레이어. 기기 간 동기·백업.
- **Phase 2 — 푸시:** Cloud Functions(Blaze) + Scheduler + FCM **또는 이메일 리마인더**. Firestore의 일정 읽어 정시 발송. iOS는 PWA 설치 안내. *가장 무겁고 제약 많으니 마지막.*

## 5. 비용·운영 요약
- Firestore·Auth·FCM 수신: 무료 티어 가능성 큼.
- 예약 발송(Functions+Scheduler): **Blaze 필요**(소규모면 월 몇 달러 이내).
- 운영: Firebase 프로젝트·보안 규칙·**개인정보 처리방침**·서비스워커 관리.

## 6. 의사결정 포인트 (다음 단계 입력)
1. **방향:** 로컬-퍼스트 유지(Phase 0만) vs 클라우드 동기 도입(Phase 1+)? — 제품/브랜드 결정.
2. **인증:** 익명(백업) vs 로그인(기기 간 동기)?
3. **알림 채널:** 앱 내만 / 웹 푸시(FCM, iOS 제약) / 이메일 / 네이티브?

## 출처
- FCM Web 시작: https://firebase.google.com/docs/cloud-messaging/web/get-started
- FlutterFire Messaging: https://firebase.flutter.dev/docs/messaging/usage/
- Cloud Functions 예약(Scheduler): https://firebase.google.com/docs/functions/schedule-functions
- iOS 웹푸시 "홈 화면 추가" 제약: https://notificare.com/blog/2024/09/16/web-push-in-ios-add-to-home-screen/
- iOS 웹푸시 요건(Pushpad): https://pushpad.xyz/blog/ios-special-requirements-for-web-push-notifications
