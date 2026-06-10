# HANDOFF — 다음 세션 이관

_작성: 2026-06-10 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/ (main = 동기 **코어까지** 배포됨, 단 휴면)

---

## 0. 지금 IN-FLIGHT: 클라우드 동기 Phase 1 — 브랜치 미병합

**무엇:** Google 로그인 시 학습 데이터(일정·응시이력·열람·체크)를 **기기 간 동기**. 로컬-퍼스트 + *선택적* 로그인. 미설정/미로그인은 **로컬-only(graceful degrade)** — 지금 배포된 앱은 현재와 동작 동일.

- 설계 스펙: `docs/superpowers/specs/2026-06-10-cloud-sync-design.md` (reconcile-on-trigger 반영본)
- 타당성·방향: `docs/plans/2026-06-10-firebase-fcm-feasibility.md` (Phase 1 지향 / 푸시 Phase 2 보류 결정)
- 플랜: Plan 1 `docs/superpowers/plans/2026-06-10-cloud-sync-core.md` · Plan 2 `docs/superpowers/plans/2026-06-10-cloud-sync-integration.md`

### 상태
| | 상태 |
|---|---|
| **Plan 1 (동기 코어)** | ✅ **main 병합·배포 완료.** 인터페이스+Fake · 병합 엔진(attempts union·viewed set union·plan/checks LWW) · `SyncService`. |
| **Plan 2 (앱 통합)** | ⏳ 브랜치 **`feat/cloud-sync-integration`** (main +8커밋, **256 테스트**, 미병합). Firebase 의존성·스텁·게이트 · Firestore/Auth 구현(컴파일만) · `SyncController` · 부트스트랩+UI. 6 Task 전부 구현+리뷰. **시각 QA 통과**(데스크톱 ⚙ + 모바일 햄버거 → "기기 간 동기" → 미설정 시트, 콘솔 에러 0). |

### ⚠️ 다음 세션이 **먼저** 할 일 — 머지 전 닫아야 할 갭
**1. 로컬→클라우드 트리거 미배선 (실질 기능 누락).**
- 현재 `SyncController`는 **로그인 + 클라우드 변경 수신(watch)**에만 reconcile 발동.
- 스펙 §6.2가 명시한 **앱 복귀·주기 트리거가 구현에서 빠짐** → *이 기기에서 만든 로컬 변경이 다음 로그인(앱 재시작) 전까지 클라우드로 안 올라감*(단일 기기 사용 시 백업 지연).
- **Fix:** `SyncController`에 (a) 주기 `Timer`(예: 30s, signed-in일 때만) + (b) 선택적 web `visibilitychange`(앱 복귀) → `sync()` 호출. 둘 다 `dispose`/`signOut`에서 정리. 테스트: 트리거가 `sync()`를 부르는지(주입 시계/수동 발화). 파일: `lib/data/cloud/sync_controller.dart` (+ `test/cloud/sync_controller_test.dart`).

**2. 종합 리뷰 판정 확정.** Plan 2 최종 종합 리뷰(opus, 백그라운드)가 완료됐으나 최종 판정 텍스트를 회수 못 함(세션 중단). 위 트리거 갭이 그 리뷰의 핵심 지적일 공산이 큼 — **트리거 보강 후** 짧은 재리뷰 1회 권장.

### 그다음 — 마무리 + 라이브
3. 트리거·리뷰 반영 → `cd flutter_app && flutter analyze lib && flutter test` → **브랜치 마무리(main 병합 + 푸시 → 배포)**. 휴면 코드라 배포해도 사용자 화면 변화 0.
4. **라이브 검증 = 사용자 액션 필요(에이전트 크레덴셜 없음, Plan 2 Task 6):** Firebase 프로젝트 생성 → `flutterfire configure`(→ `lib/firebase_options.dart` 실값으로 덮음, *현재 `REPLACE_ME` 스텁*) → Cloud Firestore + Google Auth 활성화 → 보안 규칙(스펙 §8) 배포 → Auth authorized domains에 `velkaressiablutkrone.github.io` 추가 → 2기기 같은 Google 계정 로그인 동기 확인.

---

## 1. 아키텍처 핵심 (이어받기 전 알아야 할 것)
- **reconcile-on-trigger (가로채기 없음):** 스토어와 `SyncService`가 **같은 localStorage**(`defaultBackend()`=WebBackend)를 읽고/써서 reconcile 결과가 스토어 다음 읽기에 자동 반영 → 쓰기 가로채기 불필요. 트리거에 **멱등** `reconcileAll` 재실행. (단순·저위험 위해 스펙의 SyncedKvBackend 가로채기를 이 방식으로 교체함 — 사용자 승인.)
- **graceful degrade 게이트:** `firebase_bootstrap.dart`의 `cloudConfigured()`가 `firebase_options.dart`의 `projectId == 'REPLACE_ME'`면 false → `Firebase.initializeApp` 미호출 → cloud 전부 off. 그래서 지금 빌드·배포·동작 전부 현재와 동일.
- **충돌 해소(D2):** history=레코드 union(무손실, 키 `sanitize(certId|examId|date)`), viewed=set union, plan/checks=LWW(사이드카 `awsdocs.sync.v1`에 per-cert ms 스탬프). 순수 함수 `sync_merge.dart`(완전 단위테스트).
- **파일:** `lib/data/cloud/{auth_user,auth_service,cloud_store,sync_merge,sync_service,firebase_bootstrap,firestore_cloud_store,firebase_auth_service,sync_controller}.dart` · `lib/firebase_options.dart`(스텁) · `lib/pages/sync_entry.dart` · `lib/main.dart`(부트스트랩) · `lib/pages/home_page.dart`(⚙ `_SettingsButton.openSyncSheet` static + 햄버거 `_NavMenuButton` 진입점).
- **Firebase 버전:** firebase_core ^4.10 · firebase_auth ^6.5 · cloud_firestore ^6.5. 컴파일·release 빌드 검증됨. **라이브 미검증.**
- **검증:** `cd flutter_app && flutter analyze lib && flutter test` (현재 256). 라이브는 사용자 Firebase 후.

---

## 2. 기타 대기 작업 (콘텐츠 백로그 — cloud-sync와 별개, 여전히 유효)
이전 핸드오프 상세는 git `9c30e72`의 `HANDOFF.md` 참조. 요약:
- **① ≥15 심화:** CLF 각 Task 12→15 verified(+57문항). 리스크 최저·즉시 가치. 워크플로 메모리 [[content-density-loop]].
- **② SAA-C03 착수:** 현재 문항 0(학습문서만). 첫 검증 문항 세트 + `content_index` questionCount·`content_index_test` 단언 갱신.
- **③ C-중량:** 개념 → 학습문서 *섹션* 앵커 딥링크. 가치(스크롤 마찰) 증명 후 착수.
- **철칙:** `verified=사람 검수만`(AI가 true 금지) · 문항 새 개념은 학습문서(`t*.md`)도 보강 · 시각/UI는 `DESIGN.md` 먼저.

---

## 3. 워킹트리 / 메모
- 미커밋: 없음(테스트 깨끗). Firebase 의존성 `pubspec.lock`은 Task 1에서 커밋됨.
- 이 세션 시각 QA 산출물 `qa-*.png`·`.playwright-mcp/`가 워킹트리에 **untracked**로 남아 있음(무해 — 지우려면 `rm -f qa-*.png && rm -rf .playwright-mcp`). 푸시엔 미포함.
- 시각 QA 레시피: 메모리 [[flutter-web-visual-qa-recipe]] (web-server + Playwright + `flt-semantics-placeholder` 클릭으로 시맨틱스 켜기).
- 방향·결정 메모리: [[study-app-cloud-direction]].

**다음 세션 첫 수: §0의 트리거 갭(1) 보강 → 재리뷰(2) → 브랜치 마무리(3).**
