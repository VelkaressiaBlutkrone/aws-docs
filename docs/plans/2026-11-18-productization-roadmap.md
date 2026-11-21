# 제품화·Google Play 출시 로드맵 (2026-11-18 ~ 2026-12-31)

> 상태: **재점검판(2026-11-18) — 사용자 승인 대기.** 각 단계는 착수 전에 별도 설계·승인을 거친다(CLAUDE.md 절대 조건 6).
> 범위: Android 앱 출시 + DVA-C03 전환 + 추가 기능 2종(공지·피드백 게시판, 프레젠테이션 학습 화면).
> 비범위(출시 후): 미저작 자격증 콘텐츠(§6), 사용자 간 커뮤니티, iOS.
> 이 문서의 수치·경로는 2026-11-18에 레포에서 직접 세거나 읽은 것이다(§1 각 표의 「출처」). 기준선 테스트 수는 여기 적지 않는다 — 정본은 [CLAUDE.md](../../CLAUDE.md) 「빌드·테스트」 절이다.

---

## 0. 결정 요약

| 순서 | 무엇 | 왜 이 자리인가 |
|---|---|---|
| 0 | **(사람) Play 개발자 계정·본인 확인 + 테스터 모집** | 일정의 임계 경로다. 코드가 끝나도 계정·테스터가 없으면 비공개 테스트를 시작할 수 없다. **오늘 시작한다** |
| 1 | **Android 이식 최소 기반**(로컬 저장 → Firebase → 로그인 → 링크·복귀 신호) | 지금 그대로 빌드하면 학습 기록이 재시작마다 사라지고 Firebase 초기화가 예외로 끝난다(§1-2) |
| 2 | **출시 필수 요건**(계정 삭제 · 개인정보처리방침 · Data safety) | 비공개 테스트 트랙도 Data safety 제출 대상이다(§2). **테스트 시작 전에** 끝나야 한다 |
| 3 | **비공개 테스트 시작 — 목표 12-01~12-05, 한계 12-08** | 12명 × 연속 14일 + 심사 「보통 7일 이내」를 12-31에서 거꾸로 센 값이다(§4) |
| 4 | **DVA-C03 전환(웹 먼저)** | 날짜가 고정된 유일한 콘텐츠 작업. C02 마지막 응시가 11-30이라 12-01부터 사이트 표기가 낡는다 |
| 5 | **Android 오디오** | 테스트 **시작의 전제에서 뺀다**(초안 대비 변경, §5-①). 테스트 기간에 넣는다 |
| 6 | **공지·피드백 게시판** | 테스트 기간 중 구현. 사용자 간 글은 넣지 않는다 |
| 7 | **프레젠테이션 학습 화면** | 연내는 설계까지, 구현은 여유가 있을 때만(§5-④) |
| 출시 후 | 콘텐츠 원격 전달, 미저작 자격증, 커뮤니티 | §5-②, §6 |

---

## 1. 현재 상태 실측 (2026-11-18)

### 1-1. 앱 구조

| 항목 | 실측 | 출처 |
|---|---|---|
| 플랫폼 | `flutter_app/` 에 `web/` 만 있고 **`android/`·`ios/` 가 없다** | `ls flutter_app` |
| 코드 규모 | `lib/` Dart 파일 119개 · `test/` 항목 175개 | `find … -name '*.dart'` |
| 라우터 | `lib/app_router.dart` — `/` 아래 `cert/:code` (`exam`·`exam/weak`·`review`·`report`·`plan`·`audio`·`study/:taskId`(`quiz`·`exam`)) + `/audio` | `grep "path:"` |
| 의존성 | `web` · `go_router` · `firebase_core` · `firebase_auth` · `cloud_firestore` (+ `cupertino_icons`). 저장소·오디오·링크용 네이티브 패키지는 **없다** | `pubspec.yaml` |
| Firebase 구성 | `lib/firebase_options.dart` 는 `web` 만 있고 android·ios 등은 `UnsupportedError` 를 던진다. `firebase_bootstrap.dart` 의 `cloudConfigured()` 도 `web` 옵션을 직접 읽는다 | 파일 본문 |
| 로그인 | `lib/data/cloud/firebase_auth_service.dart:23` — `signInWithPopup(GoogleAuthProvider())` (웹 팝업 전용) | 파일 본문 |
| 동기 데이터 | Firestore `users/{uid}/{collection}/{docId}` (예: `attempts`·`viewed`·`meta`). 규칙은 본인만 읽기·쓰기 | `firestore_cloud_store.dart:13` · `firestore.rules` |
| 계정 삭제·개인정보 고지 | **앱에 없다** (`lib` 에서 「개인정보」 0건, 계정 삭제 호출 0건) | `grep` |
| CI | `ci.yml`(node 도구 → analyze → test → 릴리스 플래그 테스트) · `pages.yml`(웹 빌드·배포) · `firestore-rules.yml`. Flutter `3.47.2` 고정 | `.github/workflows/` |

### 1-2. 웹 전용 코드 네 곳 (`dart.library.js_interop` 조건부 import, 비웹은 스텁)

| 경계 파일 | 웹 구현 | 비웹 스텁의 동작 | Android 에서의 결과 |
|---|---|---|---|
| `lib/data/local_kv.dart` | `web_backend_web.dart`(localStorage) | `defaultBackend()` 가 **`MemoryBackend`** | ⚠️⚠️ **학습 기록·시험 세션·일정·테마가 앱 재시작마다 사라진다** |
| `lib/data/audio_runtime.dart` | `audio_runtime_web.dart` + `web_audio_backend.dart`(DOM `<audio>` · Media Session) | `audioRuntime == null` | 오디오 미동작. 단 진입점이 `--dart-define=audio_lecture=true` 게이트 뒤라 **플래그 없이 빌드하면 화면에 나타나지 않는다** |
| `lib/data/cloud/app_resume.dart` | `visibilitychange` 이벤트 | 빈 스트림 | 앱 복귀 시 동기화 신호 없음(주기 동기는 남는다) |
| `lib/util/open_link.dart` | `window.open` | no-op | 홈 히어로의 출처 링크가 열리지 않는다(사용처는 `pages/home/hero_section.dart` **한 곳**) |

- `KvBackend` 는 **동기 인터페이스**(`read`·`write`·`keys`)이고 `defaultBackend()` 를 부르는 파일이 **14개**다(정의가 있는 `local_kv.dart` 제외). Android 구현은 「`runApp` 전에 한 번 읽어 메모리에 올리고 쓰기는 뒤에서 내보내는」 형태여야 호출부를 바꾸지 않는다.
- 오디오는 `AudioBackend`·`MediaSessionBackend` 추상(`audio_controller.dart:30` · `media_session_binder.dart:21`) 뒤에 있어, Android 는 **두 인터페이스의 구현체 + 런타임 스텁 교체**로 붙는다. 재생 상태 머신·플레이리스트는 그대로 쓴다.

### 1-3. 콘텐츠

| 자격증 | 학습문서(md) | 문항 | verified | `content_index` 등재 |
|---|---|---|---|---|
| CLF-C02 | 19 | 301 | 301 | 19 |
| SAA-C03 | 24 | 360 | 360 | 24 |
| SOA-C03 | 20 | 300 | 300 | 20 |
| DEA-C01 | 17 | 256 | 256 | 17 |
| MLA-C01 | 12 | 321 | 321 | 12 |
| AIF-C01 | 14 | 210 | 210 | 14 |
| SCS-C03 | 16 | 240 | 240 | 16 |
| AIP-C01 | 20 | 300 | 300 | 20 |
| **합계(등재 8종)** | **142** | **2,288** | **2,288** | **142** |
| DVA(C03 기준 저작) | 12 | **0** | — | **미등재**(`pubspec` 에도 `assets/content/dva/` 선언 없음) |

출처: `assets/content/<cert>/*.md`·`*.questions.json` 파일 수와 `"verified": true|false` 줄 수, `lib/data/content_index.dart` 의 `certCode:` 줄 수. **`"verified": false` 가 든 파일은 0개**다 — 2026-11-18의 AIF·AIP·SCS 전 드래프트 flip 이후 비-DVA 8종은 사람 검수 대기 문항이 없다.

- `site_data.dart`·`exam_summaries.json` 은 **12종**을 보여 준다. 콘텐츠가 없는 넷은 `DVA-C02`·`SAP-C02`·`DOP-C02`·`ANS-C01` 이고, `assets/exam_guides/` 에도 그 네 JSON 이 그 코드로 들어 있다(`DVA-C03.json` 은 없다).
- 전달 방식: 학습문서·문항·시험 가이드는 **번들 자산**이다(`rootBundle.loadString` 9곳 — `question_banks.dart` 1 · `cert_detail_page` 2 · `cert_exam_page` 1 · `exam_page` 2 · `quiz_page` 1 · `study_doc_page` 2). 크기는 `assets/content` 10.8 MB(332 파일) · `assets/fonts` 2.7 MB.
- 오디오: mp3 는 R2(`https://aws-audio.leva.ai.kr`, `audio_asset_url.dart:7`)에서 받고 번들에는 대본·메타만 있다. 대본 `script.json` **43편**(CLF 19 · SAA 24), 승인(`audioApproved: true`) **39편**, 세그먼트 총 **3,298개**(paragraph 1,442 · heading 607 · selfcheck 514 · connector 427 · table 265 · source 43).
- ⚠️ 대본의 `sourceHash` 가 현재 md(LF 정규화 sha256)와 일치하는 것은 **43편 중 1편**(`clf-t4-3`)이다(이번에 다시 계산했다).
- 정정 빈도: `origin/develop` 머지 커밋 기준 PR 번호가 2026-11-08 #401 → 2026-11-18 #608 이다.

### 1-4. 열린 항목 (HANDOFF·WORKLIST)

| 항목 | 상태 | 출처 |
|---|---|---|
| DVA-C03 12월 전환 PR | 2026-12-01 이후. 코드 표기 6곳 + `exam_guides/DVA-C03.json` + `content_index` 12줄 + `pubspec` 디렉터리 신규 등록 + `dva_questions_test.dart` 신설. ⛔ 선결 **G-03(시험 시간 — 가이드 본문에 없음)**. ⚠️ `DVA-C02` 를 「콘텐츠 없는 cert」 표본으로 쓰는 테스트 3곳이 깨진다 | HANDOFF §0 · `:5273` |
| SAA 오디오 잔여 4편 · 오디오 확대 검토 | 미착수(사람의 청취 승인이 병목) | WORKLIST §A |
| Firebase 콘솔 규칙 ↔ 레포 `firestore.rules` 대조 | 사용자 몫 | TODOS |
| 외부 검증자 블라인드 테스트 · 유입 채널 | 백로그 | TODOS |
| ⚠️ HANDOFF §0 표제(`:54`) | 「AIP 도메인 3 저작 · 사람의 검수·flip」으로 적혀 있으나 **둘 다 끝났다**(위 표). 이 로드맵 승인 시 함께 고친다 | HANDOFF `:54` |

---

## 2. Google Play 요건 (공식 Play Console 도움말, 2026-11-18 열람)

| 요건 | 페이지가 적는 것 | 이 앱에서 할 일 |
|---|---|---|
| **비공개 테스트** | 2023-11-13 이후 만든 **개인** 계정은 프로덕션 신청 전에 비공개 테스트에서 **12명 이상이 연속 14일 opt-in**. 중간에 나갔다 다시 들어오면 연속으로 세지 않는다. 신청 양식은 테스터 모집·피드백 수집 방법·테스트로 바꾼 점을 묻고, 심사는 「보통 7일 이내, 더 걸릴 수 있다」 — [App testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en) | 테스터 12명+여유분 확보 · 14일간 이탈 관리 · 피드백 기록 보관 |
| **계정 삭제** | 앱에서 계정을 만들 수 있으면 **앱 안의 삭제 경로** + **앱 밖에서 삭제를 요청할 웹 링크**가 둘 다 필요하고, 계정과 함께 연관 데이터를 지워야 한다 — [Account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) | Firebase Auth 계정 + `users/{uid}` 하위 문서 삭제. 웹 앱에도 같은 기능을 넣어 「웹 링크」로 쓴다 |
| **Data safety** | Play 에 게시된 모든 앱이 제출한다(비공개·공개 테스트 트랙 포함, **내부 테스트 트랙만 면제**). 개인정보처리방침 링크가 있어야 양식을 끝낼 수 있고, 서드파티 SDK 가 수집하는 데이터도 신고 대상이다 — [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en) | 처리방침 게시(공개 URL) · 수집 항목 정리(계정 이메일·uid, 동기화한 학습 기록, Firebase SDK 수집분) |
| **Target API** | 2026-08-31부터 신규 앱·업데이트는 **Android 16(API 36) 이상**을 target — [Target API level](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en) | `flutter create` 가 만든 `targetSdk` 를 확인하고 36 미만이면 올린다 |
| **앱 생성** | 패키지 이름은 **영구적**(삭제·재사용 불가). 앱을 만들 때 Play App Signing 약관에 동의한다 — [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) | 패키지 이름을 A1 에서 사람이 확정 |
| **계정 정보** | 개인/조직 두 유형. 법적 이름·주소·연락처·결제 프로필을 정확히 제공 — [Play Console Requirements](https://support.google.com/googleplay/android-developer/answer/10788890?hl=en) | 사람 몫(§7) |
| **UGC** | UGC 는 「앱 사용자 일부에게라도 보이거나 접근 가능한」 사용자 콘텐츠다. 해당하면 게시 전 약관 동의 · 금지 콘텐츠 정의 · 신고·차단 · 지속 모더레이션이 필요하다 — [User Generated Content](https://support.google.com/googleplay/android-developer/answer/9876937?hl=en) | 연내에는 **다른 사용자에게 보이는 글을 만들지 않는다**(§5-③) |

⚠️ 페이지에 갱신일 표시가 없다. 계정 유형에 따라 달라지므로 **Play Console 화면이 최종 근거**다. 페이지가 답하지 않은 것은 §8에 모았다.

---

## 3. 단계별 작업과 완료 기준

공통 게이트(모든 PR): `cd flutter_app && flutter test && flutter analyze`(0건) · 웹 회귀 확인은 PowerShell 에서 `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`. 실패 테스트 선작성(절대 조건 2), 플랫폼 분기는 지금처럼 **조건부 import + 스텁**을 유지해 VM 테스트가 계속 컴파일되게 한다. 패키지 선택은 착수 시 Context7 로 현행 문서를 확인해 정한다(아래 이름은 후보다).

### 단계 A — Android 최소 기반 (11-18 ~ 11-30)

| # | 작업 | 완료 기준(검증) | 주체 |
|---|---|---|---|
| A0 | Play 개발자 계정 생성·본인 확인, 테스터 모집 시작, 패키지 이름·앱 이름 확정 — ✅ **앱 이름 확정 2026-11-20**: Play 등록명 「구름사다리 — AWS 자격증 학습·모의고사」 · 짧은 이름 「구름사다리」 · 대상 18세 이상(앱·웹·정책 페이지 전부 반영, 가드 `brand_name_test.dart`) | Play Console 에서 앱을 만들 수 있다 | 사람 |
| ~~A1~~ **완료 2026-11-18** (PR #617, 머지 `66f3c82`) | `flutter create --platforms=android --org kr.ai.leva .`, `applicationId` `kr.ai.leva.awsdocs`, `minSdk 24`·`targetSdk 36` 리터럴, `key.properties` 서명 + debug 폴백, main manifest INTERNET, 가드 8건 | ✅ `flutter build appbundle --release` **exit 0** · 에뮬레이터에서 홈 렌더 · **Pretendard(woff2) 렌더 확인**(§8-⑥ 해소). 남은 사람 몫: `flutter doctor --android-licenses`(법적 승인) · 업로드 키스토어 생성·보관 | AI + 사람 |
| ~~A2~~ **완료 2026-11-19** (PR #619) | **로컬 저장소** Android 구현(동기 `KvBackend` 뒤의 영속 캐시) — **가장 먼저** | 단위 테스트: 쓰기 → 새 인스턴스에서 읽힘 · 실기기: 퀴즈 응시 → 앱 강제 종료 → 재실행 후 기록 유지 — ✅ 단위 테스트 + 에뮬레이터에서 통합 모의고사 1문항 답 → `am force-stop` → 재실행에 「이어서 풀기」 배너(문구 그대로 검증) | AI |
| ~~A3~~ **완료 2026-11-19** | Firebase Android 앱 등록(`1:169329324307:android:4209f5427fe911f1b6aae6`, 패키지 `kr.ai.leva.awsdocs`) + `firebase_options.dart` android 엔트리 + 디버그 SHA-1·SHA-256 등록, 가드 7건 | ✅ 에뮬레이터 logcat: 실패 줄 `have not been configured for android` **1건 → 0건**, `FirebaseApp: Device unlocked: initializing all Firebase APIs for app [DEFAULT]` **신규 등장**(= `[DEFAULT]` 앱이 생성됐다는 직접 증거) · VM 테스트 불변 | **사람은 `firebase login --reauth` 한 줄**(브라우저 구글 로그인) + 나머지 AI |
| ~~A4~~ **코드 완료 2026-11-19** | Android Google 로그인 — `google_sign_in_android` + 플랫폼 인터페이스로 idToken → `GoogleAuthProvider.credential`, 초기화 1회(`OnceInitializer`), 로그인 실패 화면 노출, 로그아웃은 양쪽에서, 가드 16건 | ✅ 에뮬레이터 logcat before/after: `UnimplementedError: signInWithPopup() is only supported on web based platforms`(UncaughtError) **1건 → 0건** · `CredentialManager` **0 → 11건** · `GoogleSignInActivity` **표시됨(+457ms)** · 취소 시 내 코드의 `Google 로그인 취소` 줄이 찍힌다. ⏳ **로그인 성공·기록 내려옴·로그아웃은 사람 몫** — 에뮬레이터에 구글 계정이 없어 시스템이 자격 증명 입력 화면까지 띄웠고 거기서부터는 사람만 진행할 수 있다 | AI + **사람(실기기 로그인 1회)** |
| ~~A5~~ **완료 2026-11-19** (PR #620) | 외부 링크 · 앱 복귀 신호(`AppLifecycleListener` 류) | 히어로 출처 링크가 브라우저로 열린다 · 복귀 시 동기 1회(단위 테스트는 신호 스트림 주입) — ✅ 에뮬레이터에서 히어로 칩 → `com.android.chrome` 이 전면(앱 내 웹뷰 아님) · 비활성 → 재개 전이에서 신호 1회(동작 테스트) | AI |
| A6 **진행 중** — 결함 4건 해소(A6-1 #623 · A6-2 #624 · A6-3·4 #622, 점검 문서 #621), **체크리스트 미완** | 모바일 사용성 점검(시스템 뒤로 가기 · 안전 영역 · 글자 크기 · 스플래시·아이콘) | 주요 라우트(§1-1) 전부를 실기기에서 한 번씩 통과한 체크리스트 — ⏳ 미점검: 시험 진행·결과·학습 일정·오답노트·약점 리포트 **5화면** + 3버튼 내비·가로·태블릿 폭·실기기 **4조건**(`docs/audits/2026-11-19-a6-mobile-usability-audit.md` 「점검하지 않은 것」). ⚠️ 그 문서가 말한 판정 스크립트는 **커밋되지 않았다** — 재점검은 스크립트를 `tool/` 에 커밋하는 것부터다 | AI + 사람 |
| ~~A7~~ **코드 완료 2026-11-20** | 계정 삭제(앱·웹 공통) — **동기 정지 → 재인증 → 클라우드 문서(6 컬렉션) → Auth 계정 → 로컬 기록·동기 사이드카**, 가드 14건 + 규칙 테스트 2건 | ✅ 단위 14건(순서·취소·부분 실패·드리프트) · 규칙 테스트 **3 → 5건**(에뮬레이터가 `PERMISSION_DENIED: false for 'delete' @ L7` 로 **타인 경로 삭제 거부를 규칙 줄 번호까지** 보여 준다) · 웹·APK 릴리스 빌드 통과 | AI + **사람(실계정 1회 삭제 + 콘솔에서 문서 0건 확인)** |
| A8 **1차 완료 2026-11-20** | 개인정보처리방침(공개 URL) · Data safety 답안 초안 · 스토어 등록정보(설명·스크린샷·콘텐츠 등급) — 1차: `web/privacy.html` · `web/delete-account.html`(정적, 스크립트·외부 글꼴 없음) + 앱 안 처리방침 링크(메뉴·설정) + 초안 `docs/play/2026-11-20-data-safety-and-listing-draft.md`. **2차(A8-2) 완료 2026-11-20: 스토어 아이콘 · 기능 그래픽 · 스크린샷 6장(`docs/play/assets/`) + 콘텐츠 등급 답안 근거표(초안 §4), 가드 7건(`store_assets_test.dart`)** | 처리방침 URL 200 · Play Console 「앱 콘텐츠」 항목이 전부 완료 표시 — ✅ 가드 19건(수집 항목 ↔ `kSyncedCollections` · 앱 코드 서비스 호스트 ↔ 처리방침 · **텔레메트리 SDK 부재** · 메뉴 탭이 실제로 처리방침 URL 을 연다) · 민감도 변이 5종 전부 레드 | AI(초안) + 사람(승인·제출 · `info@leva.ai.kr` 수신 확인 · 앱 이름 A0 · 타겟 연령) |

- **단계 A 남은 것(2026-11-20 정리)** — AI 몫은 **A6 체크리스트 하나**다(판정 스크립트 커밋 → 5화면·4조건 순회 → 결함은 원인 보고 후 수정). A6-4 의 잔여(시스템 다크 + 앱 라이트 조합에서 스플래시가 어둡다 — 네이티브가 저장 테마를 읽어야 한다)는 **별 작업**으로 둔다. **사람 몫:** ① A0 Play 개발자 계정·본인 확인·테스터 12명 모집 ② A1 `flutter doctor --android-licenses`(법적 승인)·**업로드 키스토어 생성·보관**(비밀번호는 직접 입력) ③ A4 실계정 로그인·기록 내려옴·로그아웃 확인 ④ A7 실계정 1회 삭제 + 콘솔에서 문서 0건 확인 ⑤ A8 Play Console 「앱 콘텐츠」 입력·제출(처리방침·삭제 URL · Data safety · 콘텐츠 등급 · 타겟층 **18세 이상** · 그래픽 업로드 — 답은 `docs/play/2026-11-20-data-safety-and-listing-draft.md`) ⑥ A6 실기기 점검. ✅ 이미 끝난 사람 몫: 앱 이름 「구름사다리 — AWS 자격증 학습·모의고사」·대상 18세 이상 결정, `info@leva.ai.kr` 수신 확인(시험 메일 2026-11-20).
- **로드맵 밖에서 같은 기간에 한 것** — 앱 이름 변경(#631) · 한국어 어절 단위 줄바꿈 앱 전체(#633, Flutter 에 `word-break: keep-all` 설정이 없어 U+2060 을 넣는 같은 이름의 `Text` 위젯) · 릴리스 3회(#629 · #632 · #634, 라이브 `7f38c44`).
- A2 → A3 → A4 는 순서 의존이다(동기는 로컬 저장 위에서 돈다). A5·A6·A7·A8 은 서로 독립이다.
- **A3 실측(2026-11-19):** 콘솔 작업이 필요하지 않았다 — firebase CLI 가 `apps:create ANDROID`·`apps:sdkconfig`·`apps:android:sha:create` 를 모두 제공하므로 **사람 몫은 만료된 토큰 재인증 한 줄**이다. ⚠️ **`google-services.json` 과 `com.google.gms.google-services` 플러그인은 쓰지 않는다** — FlutterFire 는 `Firebase.initializeApp(options:)` 로 값을 코드에서 받고, 그 플러그인은 Crashlytics·Performance·FCM 을 넣을 때 필요해진다(공식 문서 확인). 그래서 네이티브 `FirebaseInitProvider` 자동 초기화 경고 2건은 **설계대로 남는다**(`no default options were found` → `initialization unsuccessful`); 그 직후 Dart 가 수동 초기화에 성공한다. json 을 넣는 쪽은 레포 관례(`.gitignore` 등재)와 충돌한다 — 커밋되지 않는 파일을 Gradle 플러그인이 요구하면 다른 환경의 빌드가 깨진다.
- **등록된 디버그 SHA(2026-11-19):** SHA-1 `a71f3ad3fa4363a4dad457ec62b20d1fa11cb6a8` · SHA-256 `a48bb9b2e487d6249e95f3b0a5c2a391ddd1ea87d6e676e0b7c3ac376b9af809` (`~/.android/debug.keystore`, 유효기간 2055). **릴리스 키스토어는 아직 없어**(`android/key.properties` 부재) 릴리스 SHA 는 미등록이고, Play 내부 테스트 빌드는 **Play 앱 서명 키**의 SHA 를 따로 등록해야 한다(§8-⑦·B1). ⚠️ `apps:android:sha:create` 가 SHA-1 등록에서 **실패를 보고했는데 실제로는 등록됐다** — 판정은 `apps:android:sha:list` 로 한다(firebase CLI 는 성공한 다음 명령에서 `firebase-debug.log` 를 지우므로 원인은 사후에 볼 수 없다).
- **A4 실측(2026-11-19):** 공식 문서가 Google 에 적는 네이티브 경로는 **credential** 이다 — firebase_auth 6.7.1 의 `signInWithProvider` 는 Apple·Facebook 같은 generic OAuth 공급자용이고 Google 경로로는 문서에 없다. `google-services.json` 을 쓰지 않으므로(A3) **웹 OAuth 클라이언트 ID**(`apps:sdkconfig` 의 `oauth_client` 중 `client_type: 3`)를 `serverClientId` 로 넘긴다. ⚠️ 그 json 에 **Android OAuth 클라이언트(`client_type: 1`) 항목이 없다**(새로 내려받아도 web 하나뿐) — 공식 문서가 요구하는 것은 web 항목이고, 실제로 Credential Manager 가 `TYPE_GOOGLE_ID_TOKEN_CREDENTIAL meets all filtering condition` 으로 통과했다.
- ⚠️⚠️ **앱 대면 패키지 `google_sign_in` 을 의존하지 않는다.** 그 패키지의 웹 구현(`google_sign_in_web`)이 플러그인 **등록 시점**에 생성자에서 `loadWebSdk()` 를 불러 `accounts.google.com/gsi/client` `<script>` 를 **조건 없이** 주입한다(패키지 소스 실측). 웹은 Firebase 팝업 경로를 쓰므로 그 SDK 가 필요 없는데도 **모든 페이지 로드가 구글에 3자 요청**을 하게 된다. 그래서 웹 구현이 없는 `google_sign_in_android`(`platforms: android`)와 `google_sign_in_platform_interface` 만 의존하고, 호출은 그 패키지의 **예제 앱이 쓰는** `GoogleSignInPlatform.instance` 직접 호출로 한다. 실측 비교(`main.dart.js`): A4 이전 **3,263,238** → 앱 대면 패키지안 **3,271,818**(+8,580 B, GIS 마커 3건) → 채택안 **3,264,055**(+817 B, **GIS 마커 0건**, 웹 플러그인 등록기의 google import **0건**).
- **A4 분기는 `kIsWeb` 이다**(`supportsAuthenticate()` 가 아니다) — 공식이 `initialize` 를 **다른 메서드보다 먼저, 정확히 한 번** 부르라고 요구하므로 그 질의부터 초기화 뒤여야 하고, 웹에서 초기화하려면 쓰지도 않을 웹 clientId 설정이 필요해진다. `kIsWeb` 은 컴파일 시점 상수라 네이티브 분기가 웹 번들에서 **죽은 코드로 제거**된다(위 +817 B 가 그 증거다).
- ⚠️ **로그인 실패를 화면에 알린다**(A4 범위에 포함, 사용자 승인). 호출부가 Future 를 버리므로(`onPressed: ctrl.signIn`) 컨트롤러가 던지면 **unhandled async error** 가 되고 화면에는 아무 변화가 없어 버튼이 고장난 것처럼 보인다 — A4 이전 안드로이드가 정확히 그 상태였다(before 측정의 `UncaughtError`). 취소는 실패가 아니라 null 이다. 문구 색은 `warningText`/`surface2` 로 `theme_contrast_test` 가 이미 AA 로 단정하는 쌍이다.
- **A7 실측(2026-11-20):** ⚠️⚠️ **Firestore 클라이언트 SDK 는 서브컬렉션을 나열할 수 없다**(`listCollections` 는 서버 SDK 전용). 그래서 계정 삭제는 **알려진 목록**(`lib/data/cloud/synced_collections.dart` 의 `kSyncedCollections` — `attempts`·`checks`·`meta`·`plans`·`progress`·`viewed` 여섯)을 돌며 지울 수밖에 없고, **그 목록이 낡으면 지워지지 않은 데이터가 조용히 남는다**(사용자는 지워졌다고 믿는다). 컬렉션 이름이 `sync_service.dart` 에 리터럴로 24곳 흩어져 있어, 가드가 **그 소스에서 집합을 뽑아 목록과 맞댄다** — 동기가 새 컬렉션을 쓰기 시작하면 그 가드가 먼저 깨진다.
- ⚠️⚠️ **삭제 순서가 안전 설계다.** `firestore.rules` 가 `request.auth.uid == uid` 를 요구하므로 **Auth 계정을 먼저 지우면 그 사용자의 문서를 영원히 지울 수 없다**(고아 데이터). 문서 → Auth 순서면 중간에 실패해도 계정이 남아 그대로 재시도된다 — 그래서 실패를 **전파하고** 뒷단계를 진행하지 않는다.
- ⚠️⚠️ **동기를 먼저 멈춘다 — 가드가 실제 결함을 잡았다.** 문서를 지우면 `watchCollection` 이 변경을 내보내고 그 구독이 `sync()` 를 돌려 **삭제 도중에 reconcile 이 끼어든다**(로컬 데이터를 클라우드에 다시 써서 방금 지운 문서를 되살릴 수 있고, Auth 계정이 사라진 뒤라면 규칙 거부로 status 가 error 가 된다). 그래서 첫 단계가 `_onUser(null)` 이다 — `_teardownTriggers()` 가 타이머·구독을 **동기적으로** 끊는다.
- ⚠️⚠️ **끝에 동기 사이드카를 비운다.** `resetAll()` 은 설계상 삭제 표식을 남기는데(다른 기기의 부활 방지), 계정이 사라진 뒤 그 표식이 남으면 **다음에 다른 계정으로 로그인할 때 그 계정의 클라우드 기록을 「표식보다 오래된 것」으로 보고 지운다.** 계정 삭제는 이 기기를 **동기 미경험 상태**로 되돌려야 한다.
- ⚠️ **패널 안의 「계정 삭제」는 중립 톤이다**(`textMuted`). `wrong`/`surface2` 는 다크에서 **4.40 으로 AA(4.5) 미달**이다(WCAG 계산 실측 — 라이트는 4.82 로 통과). 레포 관례도 위험 톤을 **다이얼로그의 확인 버튼**에서만 쓴다(`reset_dialog.dart`). ⚠️ 그 계산을 처음 틀리게 했다 — `0xAARRGGBB` 에서 **알파를 R 로 읽어** `wrong`/`surface` 가 1.63(FAIL)으로 나왔고, 레포 가드가 이미 AA 로 단정하는 그 쌍이 **대조군**이 돼 즉시 드러났다.
- **계정 삭제는 이 기기의 로컬 기록도 지운다**(사용자 판정 2026-11-20) — 남기면 나중에 **다른 계정으로 로그인했을 때 그 기록이 새 계정으로 올라간다**. §8-⑪ 도 이로써 닫힌다(「Google 로그인만 있는 앱도 앱 계정으로 보고 A7 을 한다」를 실제로 구현했다).
- Android 빌드는 `audio_lecture` 플래그 **없이** 만든다 — 오디오 진입점이 통째로 숨는다(§1-2). 웹 빌드는 그대로 플래그를 켠다.
- CI: 필수 체크 이름 `test` 는 그대로 둔다. Android 빌드 확인은 별도 선택 job 으로 더한다(필수 목록에 없는 job 은 게이트가 되지 않는다).

### 단계 B — 비공개 테스트 (목표 12-01 ~ 12-05 시작, 14일)

| # | 작업 | 완료 기준 |
|---|---|---|
| B1 | 내부 테스트 트랙에 AAB 업로드 → 설치 확인 | Play 에서 받은 빌드로 A2·A4·A7 재확인(업로드 키가 아니라 **Play 서명 키**로 서명된 빌드에서 로그인이 되는지 — §8-⑦) |
| B2 | 비공개 테스트 트랙 개설, 12명+여유분 초대 | Console 에 opt-in 12명 이상 표시 |
| B3 | 14일 유지 + 피드백 기록 | 14일 연속 12명 이상 · 피드백과 그에 따른 변경 목록(프로덕션 신청 양식 답안의 재료) |

### 단계 C — DVA-C03 전환 (12-01 이후 첫 주, 웹 먼저)

- 범위는 §1-4 그대로다. 선결 G-03(시험 시간)을 공식 페이지에서 먼저 확인한다.
- 완료 기준: `flutter test`·`flutter analyze` 그린 · `node tool/review.test.mjs` · 릴리스 후 라이브에서 DVA 학습문서 12편 200.
- **문항은 이 PR 의 범위가 아니다.** 저작(선례는 Task 당 15문항 — DVA 수량은 레포 문서에 고정돼 있지 않다) → 사람 검수·flip 은 출시 일정과 분리한다(§6).

### 단계 D — 테스트 기간 중 기능 (12-02 ~ 12-19)

| # | 작업 | 완료 기준 |
|---|---|---|
| ~~D1~~ **완료 2026-11-21** | **Android 오디오** — `AudioBackend`·`MediaSessionBackend` 구현, 백그라운드 재생·잠금화면 컨트롤. **둘로 쪼갰다** — ~~D1-a 재생 경로~~ / ~~D1-b 백그라운드·잠금화면~~ | **D1-a ✅**: 에뮬레이터에서 R2 강의가 **실제로 재생**된다(`ExoPlayerImpl Init [AndroidXMedia3/1.4.1]` · `MediaCodec adapter for track type audio` · `dumpsys audio` 가 우리 pid 를 `state:started` `USAGE_MEDIA` 24kHz 로 인식 · 미니플레이어 **3:53 / 30:08** 진행 바와 「재생 중입니다」). 웹 번들 **+1,367 B(0.04%)** · 가드 10건 · 민감도 변이 5종 전부 레드. **D1-b ✅**: 포그라운드 서비스(`types=0x00000002` MEDIA_PLAYBACK) · 잠금화면 카드(A 글리프 배지 + 제목 + 구름사다리 + 일시정지·정지) · 미디어 버튼 왕복 · `audio_lecture` 플래그 켠 릴리스 빌드 스크립트. 가드 38건 · 웹 번들 누계 **+896 B(0.027%)**. §8-⑧ 해소. **남은 것은 실기기 확인(사람)** |
| D2 | **공지·피드백 게시판**(§5-③) | 규칙 테스트에 공지(운영자만 쓰기)·피드백(본인만 쓰기, 운영자만 읽기) 케이스 추가 후 그린 · Data safety 답안 갱신 |
| D3 | **프레젠테이션 화면 설계**(§5-④) | 설계 문서 승인. 구현은 D1·D2 가 끝나고 일정이 남을 때만 |

- 테스트 빌드는 이 기간에 계속 갱신한다. D1·D2 는 서로 독립이라 병행할 수 있다.

**D1-a 실측(2026-11-21).** Play 신원 확인 대기 중에 착수했다(단계 A 의 AI 몫이 비어 있었다).

- ⭐ **기존 경계가 그대로 재사용됐다.** `AudioBackend`·`MediaSessionBackend` 가 추상 인터페이스이고 `AudioController`(상태 머신)·`MediaSessionBinder`·`LecturePlaylist` 가 순수 Dart 라 **한 줄도 바뀌지 않았다**. 새로 쓴 것은 `NativeAudioBackend`(just_audio 래핑)와 `audio_runtime_io.dart` 둘뿐이고, 웹은 `audio_runtime_web` 이 그대로 돈다.
- ⭐ **URL 이 공짜였다** — `ContentEntry.lectureAudioSrc` 가 승인분을 **R2 절대 URL**(`{base}/{family}/{taskId}/{sha8}/lecture.mp3`)로 주므로 네이티브도 그대로 `setUrl` 한다.
- ⚠️⚠️ **`dart.library.io` 분기는 VM 테스트도 고른다.** 지금까지 비웹은 stub(→ `audioRuntime == null`)이었고 그 성질에 기대는 가드가 있다. 게이트 없이 io 판을 넣으면 **Windows·CI 의 `flutter test` 가 `AudioPlayer()` 를 만들어** 깨진다 — 민감도 측정에서 그 변이가 **전체 스위트 3건 레드 + 컴파일 에러**로 확인됐다. 그래서 런타임 getter 가 플랫폼을 먼저 보고, 그 판정은 **순수 함수**(`nativeAudioSupported`)로 빼 양쪽 분기를 합성 입력으로 짚는다(`Platform.isAndroid` 를 직접 쓰면 VM 에서 영원히 false 라 한쪽만 증명된다).
- ⚠️⚠️ **`just_audio` 의 `play()` 는 「재생이 끝날 때까지」 완료되지 않는 Future 다**(공식 문서: 「Play while waiting for completion」). `AudioController.play()` 가 그것을 await 하므로 그대로 두면 **트랙 하나가 끝날 때까지 호출이 매달린다.** 웹의 `<audio>.play()` 는 "재생 시작" Promise 라 **같은 인터페이스 뒤에서 의미가 갈리는 자리**다 — await 하지 않고 실패는 이벤트로 알린다.
- ⚠️ **`completed` 를 `playing` 보다 먼저 본다** — just_audio 의 `playing` 은 재생 "의도"라 트랙이 끝난 뒤에도 true 로 남을 수 있다. 순서를 뒤집으면 끝난 트랙이 계속 재생 중으로 보이고 `PlayMode.autoAll` 의 자동 다음 트랙이 돌지 않는다.
- ✅ **웹 번들 오염은 A4 와 질적으로 달랐다.** A4 의 `google_sign_in` 은 웹 구현이 **등록 시점에** 3자 스크립트를 조건 없이 주입했지만, `just_audio_web` 의 `registerWith` 는 `JustAudioPlatform.instance = JustAudioPlugin();` **한 줄**이고 `document.createElement('audio')` 는 `Html5AudioPlayer` 의 **필드**라 플레이어를 만들 때만 실행된다(우리 웹은 만들지 않는다). 실측: `main.dart.js` **3,280,274 → 3,281,641(+1,367 B)** · just_audio 마커 **0건** · 대조군(`aws-audio.leva.ai.kr` 1건)으로 grep 유효성 확인 · 남은 것은 채널 문자열 `com.ryanheise` 1건뿐. APK 는 61.0 → **63.5MB**(네이티브 라이브러리). ⭐ **io 구현을 다 넣은 뒤 다시 빌드해도 `3,281,641` 로 1바이트도 늘지 않았다** — 조건부 import 가 io 판을 웹에서 **완전히** 배제한다는 직접 증거다(그 빌드가 순서 계약의 실측 검증이기도 하다 — io 분기를 앞에 두면 웹이 `dart:io` 를 끌어와 깨진다).
- ⚠️⚠️ **백그라운드 재생은 포그라운드 서비스 **없이도** 유지됐다**(에뮬레이터 실측 — 홈 키로 보낸 뒤 15초, `state:started`, 포그라운드 서비스 0개). 그래서 **D1-b 의 근거는 「멈춘다」가 아니다**: ① 포그라운드 서비스가 없으면 OS 가 메모리 압박 시 이 프로세스를 우선 회수할 수 있고 ② **잠금화면·알림 컨트롤과 미디어 버튼이 없다**(지금은 `_NoopMediaSession`). 제조사별 배터리 관리가 더 공격적인 실기기에서는 다를 수 있다 — **실기기 확인은 아직이다.**
- ⚠️ **측정 방법에서 두 번 틀렸고 둘 다 「화면은 멀쩡한데 내 스크립트가 못 본」 경우다.** ① uiautomator XML 의 속성 순서가 `index,text,…,content-desc` 라 `(?:content-desc|text)` 로 쓰면 **앞의 빈 `text=""` 를 먼저 잡아** Flutter 노드가 전부 걸러진다(노드 0건) ② 탭 대상이 글래스 헤더(상단 ~210px) 뒤에 있으면 **헤더가 받는다**(A6 에 적힌 함정인데 이 스크립트에만 필터를 빠뜨렸다). ⭐⭐ 그리고 **재생 위치는 접근성 트리에 없다** — Flutter `Text` 가 Semantics 로 올라가지 않아 `0:00` 만 잡혔고, 실제 화면은 `3:53 / 30:08` 이었다. **스크린샷이 유일한 판정 수단이다**(A6 의 「접근성 노드는 손가락이 닿는 영역이 아니다」와 같은 계열).
- Android 빌드의 `audio_lecture` 플래그는 **아직 켜지 않는다** — 잠금화면이 붙는 **D1-b 의 마지막 단계**다. D1-a 검증은 플래그를 켠 **로컬 전용** APK 로 했다.

**D1-b 실측(2026-11-21).** `_NoopMediaSession` 을 `audio_service` 구현으로 갈아끼웠다. 예고대로 **`AudioController`·`MediaSessionBinder`·`LecturePlaylist` 는 또 한 줄도 바뀌지 않았다** — 새로 쓴 것은 `audio_service_session.dart`(매핑·핸들러·백엔드)와 배선뿐이다.

- 🏁 **`audio_lecture` 플래그를 켰다.** 빌드 시점 상수라 켜는 곳이 빌드 명령뿐인데 Android 에는 워크플로가 없어 **켤 자리가 없었다** — 릴리스 AAB 명령을 `flutter_app/tool/build_android_release.ps1` 로 커밋해 단일 출처로 두고, 새 가드가 **웹 릴리스(`pages.yml`)가 켜는 dart-define 을 전부 켜는지** 맞댄다.
- ⚠️⚠️⚠️ **릴리스 빌드에서만 잠금화면이 통째로 없었다 — 이 배치의 핵심이다.** Flutter 의 Gradle 플러그인이 릴리스에 `isMinifyEnabled`·`isShrinkResources` 를 켜는데(`FlutterPlugin.kt`, 기본값이 켬) audio_service 는 알림 버튼 아이콘을 **런타임 이름 조회**(`getResources().getIdentifier`)로 찾는다. 축소기가 그 호출을 볼 수 없어 드로어블 7개를 전부 지웠고, SDK 33+ 에서 `MediaControl.stop` 은 **CustomAction** 으로 만들어지므로 `IllegalArgumentException: You must specify an icon resource id` 가 **`AudioService.setState` 전체를 중단**시켰다. 증상이 「오디오는 재생되는데 알림도 포그라운드 서비스도 잠금화면도 없다」(`state=NONE(0)` · `metadata: null` · `active=false` · `startForegroundCount=0`)라 **재생만 보면 성공으로 보인다.** `res/raw/keep.xml` 의 `tools:keep` 으로 고정했다.
- ⚠️⚠️ **파일 이름으로는 가를 수 없다.** 축소기가 경로를 `res/-B.png` 꼴로 줄이므로 **지워진 것과 이름만 바뀐 것이 같아 보인다** — `unzip -l | grep audio_service` 는 양쪽 모두 0건이다. 판정은 `aapt2 dump resources` 의 **자원 테이블**이고 대조군이 필수다(수정 전후 `audio_service` **0 → 7**, 대조군 `ic_launcher` **3 불변**).
- ⚠️⚠️ **디버그 빌드에는 축소가 없어 이 결함이 보이지 않는다.** 미디어 세션 검증은 반드시 **릴리스 빌드**로 한다.
- ⚠️ 우리가 만든 알림 아이콘도 같은 경로로 찾는다(`androidNotificationIcon` → `getIdentifier`)라 keep 규칙에 함께 넣어야 한다. 가드는 **우리가 내보내는 모든 `MediaControl.androidIcon` + 알림 아이콘이 keep 규칙에 덮이는지**를 기계로 맞댄다 — 플러그인이 아이콘 이름 규칙을 바꾸면 거기서 먼저 깨진다.
- ⚠️⚠️ **잠금화면 제목이 비어 있었다.** `nowPlaying` 을 부르는 곳이 `study_doc_page` **하나뿐**이라 오디오 허브·자격증 오디오 페이지로 재생을 시작하면 `metadata: null` 이었다(웹도 같은 구멍이지만 네이티브는 잠금화면이 주 표면이라 바로 드러난다). `audio_runtime.dart` 의 `bindNowPlaying` 이 플레이리스트의 현재 트랙 제목을 민다 — **트랙 자동 전환(`autoAll`)도 여기서 따라온다**(화면 쪽 한 번의 호출로는 다음 트랙 제목을 갱신할 수 없다).
- ⚠️⚠️ **앱 배지가 글리프 없는 단색 원이었다.** 안드로이드는 small icon 의 **알파 채널만** 쓰고 그것을 강조색으로 칠하는데 런처 아이콘은 사각형 전체가 불투명하다. 배경 없는 흰 'A' 를 `tool/make_app_icon.py --notification` 으로 5개 밀도에 생성했다(적응형 foreground 와 같은 그림, 캔버스만 작다).
- ⚠️⚠️ **stop 뒤 알림이 되살아났다.** stop 이 부른 일시정지는 just_audio 를 거쳐 **비동기로** `paused` 를 돌려주므로 방금 실은 idle 을 덮어써 **소리는 멈췄는데 치울 수 없는 알림이 `PAUSED` 로 남았다.** `onStop` 래치로 **다시 재생될 때까지** 상태 갱신을 막는다.
- ⚠️⚠️ **`BaseAudioHandler.stop()` 을 그냥 부르면 영원히 매달린다.** 기본 구현이 `playbackState.firstWhere(processingState == idle)` 을 await 하는데 우리 바인더에는 **idle 을 내보내는 경로가 없다**(컨트롤러 상태는 playing·paused·none 뿐). idle 을 **먼저 싣고** super 를 부른다(공식 문서가 "may be overridden" 으로 허용하지만, 상류 변화를 따라가려 super 는 유지했다).
- ⚠️ **`androidStopForegroundOnPause` 는 양쪽을 다 실측했고 관측 가능한 차이가 없었다.** `true`(패키지 기본값)로 바꿔도 일시정지·정지 뒤 `isForeground=true` 와 `flags=NO_CLEAR|FOREGROUND_SERVICE` 가 그대로였다 — 플러그인의 `stop()` 이 `stopSelf()` 만 부르는데 **Flutter 엔진이 서비스에 바인딩돼 있어 `onDestroy()`(거기서 `stopForeground` 한다)가 돌지 않기** 때문이다. 구별이 안 되므로 **문서 권장값 `false`**(Android 12+ 재개 시점 예외 위험이 없는 쪽)를 쓴다. 정지 뒤 남는 카드는 **Android 13+ 의 미디어 재개 카드**이고 우리 세션은 `state=NONE` · `active=false` 로 내려가 있다.
- ✅ **웹 번들 오염은 A4 와 질적으로 다르다.** `audio_service_web.registerWith` 는 `AudioServicePlatform.instance = AudioServiceWeb()` **대입 한 줄**이고 생성자의 지원 여부 검사는 **지연 클로저**다(패키지 소스 실측). 실측: `main.dart.js` **3,281,641 → 3,282,537(+896 B · 0.027%**, `bindNowPlaying` 포함) · `audio_service`·`flutter_cache_manager`·`sqflite` 마커 **0건**(대조군 `aws-audio.leva.ai.kr` 1건) · APK 63.5 → **64.3MB**. 전이로 따라오는 `flutter_cache_manager`·`sqflite` 는 `AudioService.init`(네이티브 전용)이 쓰는 아트워크 캐시라 웹에서 트리 셰이킹된다. lock 은 **추가 11개뿐**(기존 버전 변경 0 · 제거 0).
- ⭐ **실측 증거**: `ServiceRecord{… com.ryanheise.audioservice.AudioService}` `isForeground=true types=0x00000002`(MEDIA_PLAYBACK) `foregroundNoti=Notification(channel=kr.ai.leva.awsdocs.channel.lecture … category=transport vis=PUBLIC)` · `media-session … active=true state=PLAYING(3) custom actions=[Stop, mIcon=2131230815]` · `metadata: size=4, description=AWS 클라우드의 이점, 구름사다리` · **홈 키로 보낸 뒤에도 포그라운드 유지** · `KEYCODE_MEDIA_PAUSE` 로 **오디오 트랙 수 0**, `KEYCODE_MEDIA_PLAY` 로 복귀(= 버튼이 `MediaButtonReceiver` → 핸들러 → 바인더 → 플레이어까지 왕복한다) · 잠금화면 카드 스크린샷.
- ⚠️ **측정 함정 둘이 또 났다** — **없는 문자열로 폴링하면 무한 루프**가 된다(`mDreamingLockscreen` 은 이 버전에 없다 → `KeyguardStateMonitor` 의 `mIsShowing`), **cp949 콘솔은 `PYTHONIOENCODING=utf-8` 없이 한국어 출력을 깨뜨린다**(노드 라벨이 전부 모지바케였다).
- ⏳ **실기기 확인은 아직이다** — 제조사 배터리 관리가 더 공격적인 기기에서 백그라운드 유지가 다를 수 있다(D1-a 에 적은 그대로다).

### 단계 E — 프로덕션 신청·출시 (14일 충족 직후)

- 완료 기준: 프로덕션 액세스 승인 → 프로덕션 트랙 출시 → Play 스토어에서 설치한 빌드로 A2·A4·A7 재확인 · 웹 라이브 회귀 없음(`py tool/publish_audio.py --verify-all` 포함).

---

## 4. 일정과 의존 관계

```
A0(사람: 계정·테스터) ─────────────┐
A1 ─ A2 ─ A3 ─ A4 ─┐               ├─ B1 ─ B2 ─ B3(14일) ─ E(심사 ≤7일 통상)
        A5·A6 ─────┤               │         │
        A7 ─ A8 ───┘───────────────┘         ├─ D1(오디오) ─ D3 구현(선택)
C(DVA 전환, 12-01 이후 · 웹)  ── 독립         └─ D2(게시판)
```

| 비공개 테스트 시작 | 14일 충족 | 심사 7일 가정 시 승인 | 12-31까지 여유 |
|---|---|---|---|
| 12-01 | 12-15 | 12-22 | 9일 |
| 12-05 | 12-19 | 12-26 | 5일 |
| **12-08** | 12-22 | 12-29 | **2일 — 한계** |

- 초안의 「12월 중순 전 시작」은 **성립하지 않는다.** 12-15에 시작하면 14일 충족이 12-29이고 심사가 연내에 끝나지 않는다.
- 단계 A 에 쓸 수 있는 날은 오늘부터 **12일 안팎**이다. 그래서 오디오를 테스트 시작 뒤로 뺐다(§5-①).

---

## 5. 판단 근거 (초안·출발 가설 대비 바뀐 것)

**① 오디오를 비공개 테스트 시작의 전제에서 뺀다.** 초안은 A4(오디오)를 단계 A 의 가장 큰 항목으로 두었다. 그러나 오디오는 dart-define 게이트 뒤라 플래그 없이 빌드하면 화면에서 사라지고(§1-2), 테스트 기간에는 빌드를 자유롭게 갱신할 수 있다. 백그라운드 재생은 서비스 선언까지 걸려 있어(§8-⑧) 12일 안에 넣으면 테스트 시작 자체가 밀린다. 프로덕션 출시 전에는 넣는다.

**② 콘텐츠 원격 전달은 「출시 전 결정·구현」이 아니라 「출시 후 설계」로 둔다(권고 — 사용자 결정 필요).** 초안은 「출시 후에는 바꾸기 어렵다」고 적었지만 근거를 찾지 못했다 — 원격 전달은 앱 업데이트로 나중에 더할 수 있다. 반대로 지금 넣으면 번들 파일을 전제로 한 가드 전체(파일 시스템을 읽는 테스트, `verified` 게이트, `pubspec` 선언 가드)와 무결성·오프라인 설계를 12일 안에 다시 해야 한다. 첫 출시는 번들로 가고, 정정은 앱 업데이트로 낸다. 업데이트 심사 소요는 미확인이다(§8-④) — 그것이 길면 이 판단을 다시 본다.

**③ 게시판은 「운영자 공지 + 사용자 → 운영자 피드백」만.** UGC 정의는 「다른 사용자에게 보이는 콘텐츠」이고(§2), 운영자만 보는 피드백을 페이지가 직접 다루지는 않는다 — 정의 밖으로 읽히지만 **확정은 아니다**(§8-⑤). 사용자 간 글·댓글은 약관 동의·신고·차단·모더레이션이 따라오므로 출시 후로 둔다. 문항 오류 신고를 피드백 유형으로 두면 기존 검수 흐름(보고 → 실측 → 가드)에 그대로 들어온다. 저장은 기존 Firestore + 규칙 테스트(`tool/firestore_rules_test`).

**④ 프레젠테이션 화면은 연내 설계까지.** 재료는 `script.json` 세그먼트(3,298개)지만 현재 md 와 맞는 대본이 43편 중 1편이라 대본 발췌(`sourceExcerpt`)를 그대로 슬라이드에 쓰면 **현재 학습문서와 다른 문장**이 나온다. 설계에서 먼저 정할 것: 슬라이드 본문을 ⓐ 현재 md 를 같은 구간 규칙으로 다시 나눠 만들지 ⓑ 재합성으로 md 와 맞춘 문서에만 제공할지. 음성 동기는 `audio_meta.json` 의 `chapters`(제목 단위 `fraction`)가 지금 있는 유일한 타임라인이고 세그먼트 단위 시각은 없다. 오디오 없는 6종은 텍스트 전용이다. 디자인은 `DESIGN.md` 를 따른다.

**⑤ 계정·테스터를 0번으로 올렸다.** 초안은 위험 표에만 있었다. 14일은 줄일 수 없고 시작 조건이 사람 쪽에 있다.

**⑥ 초안의 정책 근거 URL 하나를 바꿨다.** 계정 삭제 요건의 정본은 answer/13327111 이고, 그 페이지가 **웹 링크도 필수**라고 적는다(초안에는 없던 요건).

---

## 6. 자격증 콘텐츠 작업과 제품화의 우선순위

**연말까지는 제품화가 먼저다. 콘텐츠는 DVA 전환(등재)만 한다.**

- 근거 1 — 콘텐츠는 지금 막힌 것이 없다. 등재 8종 2,288문항이 전부 공개 상태이고(§1-3), 새 콘텐츠의 병목은 AI 저작이 아니라 **사람의 검수·flip** 이다. 같은 사람이 12월에 테스터 관리와 Play 제출을 해야 한다.
- 근거 2 — 제품화에는 줄일 수 없는 대기(14일 + 심사)가 있고 콘텐츠에는 없다.
- 근거 3 — DVA 전환만 날짜에 묶여 있다(C02 마지막 응시 2026-11-30, C03 2026-12-01). 등재는 작고 웹에 바로 나간다. 문항 저작·flip 은 출시 뒤로 미뤄도 잃는 것이 없다.

**「빠진 3종」은 출발 가설과 상태가 다르다**(레포 조사 기록 기준 — `docs/content-research/README.md:65-67`, HANDOFF `:2076`):

| 자격증 | 레포 기록 | 판단 |
|---|---|---|
| SAP-C02 | 마지막 응시 2026-11-16, **SAP-C03 가 11-17 개시** | C02 로 저작하지 않는다. 출시 후 **SAP-C03** 로 조사부터. 사이트의 `SAP-C02` 표기는 이미 낡았다 |
| ANS-C01 | 2026-12-31 은퇴·후속 없음(**3자 출처, 공식 미확인**) | 공식 확인 전에는 저작하지 않는다. 사실이면 카드 제거가 맞다 |
| DOP-C02 | C03 전환 공지 **미실측** | 출시 후 착수 전에 확인 |

---

## 7. 사람 몫과 AI 몫

**사람만 할 수 있는 일**
- Play 개발자 계정 생성 · 등록비 결제 · 본인(및 기기) 확인 · Play App Signing 약관 동의
- 패키지 이름·앱 이름 확정(영구), 업로드 키 생성 위치·백업 결정
- 테스터 12명 이상 모집과 14일 유지, 실기기 확인
- Firebase 콘솔: Android 앱 등록, SHA 지문 등록, 배포된 Firestore 규칙 대조
- 개인정보처리방침·Data safety·콘텐츠 등급 답안의 **승인과 제출**, 프로덕션 신청 양식 제출
- 문항 `verified` flip, 오디오 청취 승인

**AI가 할 수 있는 일**
- 단계 A 의 코드 전부(A1~A7)와 테스트, CI job 추가
- 처리방침·Data safety 답안·스토어 설명·프로덕션 신청 답안의 **초안**(수집 항목은 코드에서 실측)
- DVA 전환 PR, 게시판·오디오·프레젠테이션의 설계와 구현, 규칙 테스트
- 머지·릴리스·라이브 확인(상시 승인 범위), R2 오디오 발행

---

## 8. 미확인 사항

| # | 무엇 | 왜 중요한가 | 확인 방법 |
|---|---|---|---|
| ① | ~~Play 개발자 계정이 이미 있는지, 유형과 생성일~~ | **해소 2026-11-18 — 계정이 없다.** 지금 만들면 2023-11-13 이후 **개인** 계정이므로 **12명 × 14일이 그대로 적용된다**. 이 전제 위에서 §4 일정을 읽는다 | 사용자 답변 |
| ② | 신규 계정의 기기 확인·본인 확인 **소요**(등록비는 **US$25 일회성**으로 확인) | A0 가 며칠 걸리는지 | Console |
| ③ | 조직 계정의 테스트 요건 면제 여부 | **실측 2026-11-18 — 면제를 적은 공식 문장을 찾지 못했다.** 요건 페이지(answer/14151465)는 제목·본문 모두 `personal developer accounts created after November 13, 2023` 로 한정하지만, 계정 유형 선택 페이지(answer/13634885)는 테스트·테스터·프로덕션 액세스를 **한 번도 언급하지 않는다** — 「문면에 없다」가 「면제다」는 아니다. 게다가 조직 계정은 **D-U-N-S 가 필수이고 발급에 최대 30일**(answer/13628312, 무료·신속 경로 없음)이라 연내 일정과 양립하지 않는다 → **개인 계정으로 간다** | 공식 페이지 실측 |
| ④ | 프로덕션 승인 뒤 첫 출시·이후 업데이트의 심사 소요 | §4 여유와 §5-② 판단 | Console · 도움말 |
| ⑤ | 운영자 전용 피드백의 UGC 해당 여부, Data safety 에서의 분류 | D2 범위 | 정책 문의 또는 Console 양식 |
| ⑥ | ~~`PretendardVariable.woff2` 가 Android 엔진에서 렌더되는지~~ | **해소 2026-11-18 — 렌더된다.** 에뮬레이터(API 36)에 릴리스 APK 를 설치해 실행: 폰트·자산 로드 실패 로그 **0건**(대조군 — 같은 추출에서 `I flutter` 15줄), 굵기가 단계별로 다르게 그려진다(번들 폰트가 하나뿐이고 `fontVariations(wght)` 로 제어하므로 디코드 실패면 불가능). ⭐ 렌더 백엔드는 **Impeller(OpenGLES)** 라 pubspec 주석의 canvaskit 근거와 **다른 경로인데도** 양쪽 다 렌더한다 | A1 에뮬레이터 실측 |
| ⑦ | ~~Android Google 로그인 방식~~ / Play 서명 키 지문 등록 절차 | **로그인 방식은 해소 2026-11-19** — 공식은 `google_sign_in` 으로 받은 idToken 을 `GoogleAuthProvider.credential` 로 바꾸는 경로이고 `signInWithProvider` 는 Google 용이 아니다. `google-services.json` 없이는 **웹 OAuth 클라이언트 ID 를 `serverClientId`** 로 넘긴다. ⏳ **Play 서명 키 지문은 B1 에 남는다** — 릴리스 키스토어가 아직 없고, 내부 테스트 빌드는 업로드 키가 아니라 **Play 앱 서명 키**의 SHA-1 을 Firebase 에 등록해야 로그인이 된다 | A4 실측 · B1 |
| ⑧ | ~~백그라운드 오디오의 포그라운드 서비스 선언 요건~~ | **해소 2026-11-21(D1-a 착수 조사)** — `audio_service` 공식 README 가 그대로 적는다: 권한 **`WAKE_LOCK`·`FOREGROUND_SERVICE`**, 그리고 **SDK 34+ 에서 `FOREGROUND_SERVICE_MEDIA_PLAYBACK`**(우리는 targetSdk 36 이라 필수) · `<service android:foregroundServiceType="mediaPlayback">` + 미디어 버튼 리시버 · **Activity 를 `AudioServiceActivity` 로 교체**(매니페스트가 틀리면 `AudioService.init` 이 `PlatformException`). ⚠️ Android 12+ 는 백그라운드에서 포그라운드 서비스를 **재시작할 권한**이 없으면 `ForegroundServiceStartNotAllowedException` 이라, `androidStopForegroundOnPause: false` 로 일시정지 중에도 서비스를 유지하는 쪽을 쓴다. ⚠️ **`MainActivity` 가 A6-4 의 스플래시 테마 코드를 들고 있으므로** 교체는 상속만 바꾼다(`FlutterActivity` → `AudioServiceActivity`). D1-b 범위 | Context7 공식 문서 |
| ⑨ | ~~Flutter 3.47.2 템플릿의 기본 `targetSdk`·`minSdk`~~ | **해소 2026-11-18** — `FlutterExtension.kt` 실측으로 **compileSdk 36 · minSdk 24 · targetSdk 36 · ndk 28.2.13676358**. 기본값이 이미 Play 요건(36)을 넘지만 **리터럴로 고정**해 감사 가능하게 했다. minSdk 24 에서 Firebase 플러그인이 빌드된다(AAB·APK 빌드 exit 0) | A1 실측 |
| ⑩ | DVA-C03 시험 시간(G-03), ANS-C01 은퇴·DOP-C02 개정의 공식 확인 | 단계 C · §6 | AWS 인증 페이지 |
| ⑪ | ~~Google 로그인만 있는 앱이 「앱 계정」 정의에 드는지~~ | **해소 2026-11-20 — 든다고 보고 A7 을 구현했다.** 앱·웹 공통 경로로 계정과 클라우드·로컬 데이터를 지운다(로드맵 A7 행). 남은 것은 A8 의 「데이터 삭제 요청 URL」 항목이고 그 URL 로 웹 앱 주소를 쓸 수 있다 | A7 완료 |
| ⑫ | 테스터 12명을 실제로 모을 수 있는지 | **사용자 답변 2026-11-18 — 확신할 수 없다.** ①에 따라 우회 경로가 없으므로 **연내 출시 여부가 이 하나에 달렸다**. 12-10(테스트 시작 한계일)에 재판정하고, 미달이면 1월로 옮기고 그동안 웹으로 서비스한다. ⚠️ 공식이 거절 사유로 **`insufficient tester engagement`** 도 적으므로 머릿수만 채우는 교환방이 아니라 **실제 수험생 15~18명**을 목표로 한다 | 사용자 · 12-10 재판정 |

---

## 9. 위험

| 위험 | 영향 | 대응 |
|---|---|---|
| A0 지연(계정 확인·테스터) | 테스트 시작이 12-08을 넘으면 연내 출시 불가 | 오늘 시작 · 테스터는 12명보다 넉넉히 |
| 테스터 이탈 | 연속 14일이 깨진다 | 여유 인원 · 주 1회 빌드 갱신과 안내 |
| 심사가 7일을 넘김 | 출시가 1월로 | 12-01 시작을 목표로 여유 확보 |
| Android 작업의 웹 회귀 | 라이브 손상 | 조건부 import 유지 · 공통 게이트 · 릴리스마다 라이브 확인 |
| 업로드 키 분실 | 업데이트 불가 | Play App Signing + 키 백업 위치를 A1 에서 기록 |
| 출시 후 콘텐츠 정정 지연 | 틀린 문항이 앱에 남는 기간 | 웹은 즉시 반영 · 앱은 정기 업데이트 · 출시 후 원격 전달 설계(§5-②) |
