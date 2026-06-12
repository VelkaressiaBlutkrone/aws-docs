# HANDOFF — 다음 세션 이관

_갱신: 2026-06-13 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

---

## 0. 다음: 시각 리펙토링 B안 PR4 (4분할 중 마지막)

**설계 정본:** `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/deepe-main-design-20260612-200051.md` (승인 8/10, eng+design CLEARED). PR1(§0-x)·PR2(§0-w)·PR3(§0-v) 출고 완료.

- **PR4 — 공용 위젯 + AppHeader 롤아웃 + 페이지 분해 (T7·T8·T9·T12·DT4 + DT3 잔여 + T10):** 8페이지 AppBar 인벤토리 선행 → AppHeader 슬롯(back/title/actions)·collapse 규약(날짜→배지→섹션라벨→ellipsis·햄버거 금지) → 문서형 5페이지(cert_detail·study_doc·review·report·plan) 교체·세션형 3페이지 시각 셸 공통 → home/cert_detail/plan 분해(섹션 단위 위젯 테스트 선행, home 내부 섹션 클래스는 이미 위젯 단위라 파일 이동 위주) → 글로벌 에러 핸들러(`FlutterError.onError`/`PlatformDispatcher.onError` — state_views의 ErrorView와 연결) → **전 화면 키보드 접근성 감사**(Tab 순서·focus-visible 전 인터랙티브·Enter/Space — 퀴즈 선택지·플래그·카드·로드맵 노드 포함) + **17종 패턴 매핑표(T10/SC7)**. 와이어프레임 정답지 2번 섹션(AppHeader). 게이트: 단계별 analyze+전체 테스트+dogfood(360/768/1180px), AppBar 기능 손실 0(인벤토리 대조), Tab 전 화면 내비 dogfood, **DESIGN.md 갱신(헤더 2변형+collapse 규약)**.
- **재사용 인프라:** state_views/FocusRing(`lib/widgets/`)을 헤더 내비 focus-visible에 그대로 사용. 카피 매트릭스 정본: `docs/superpowers/specs/2026-06-13-pr2-state-views-copy-matrix.md`. 새 weight 토큰 규율: **fontWeight를 추가하면 반드시 `Wght` 토큰 병기**(§0-v).

## 0-v. 완료: 시각 리펙토링 PR3 — Pretendard Variable(woff2) 전환, main 배포됨 (2026-06-13)

**폰트 6.9MB → 2.75MB(−4.15MB), flutter view 2,579→1,611ms(−37%, 스로틀 700ms 동일 조건).** 474 테스트 그린·analyze 신규 0건·weight 렌더 전/후 동등(홈·학습문서·오답노트 스크린샷 대조 — 400 균일화 회귀 없음).

- **구현:** `PretendardVariable.woff2`(2.06MB, v1.3.9) 단일 등록 — 정적 4 OTF 삭제. **woff2 번들 가능 확인 경위**: 설계 가정 ~2.3MB는 woff2 수치였고 Variable TTF는 6.7MB(전환 무의미) → 엔진 소스에서 Noto 폴백이 woff2를 에셋과 같은 `Typeface.MakeFreeTypeFaceFromData`로 디코드함을 확인 → 실증 빌드로 입증. `Wght` const 토큰(`app_theme.dart`) 신설 + lib 전체 `fontWeight:` 88곳에 `fontVariations:` 1:1 병기(일괄 치환, mono 포함 — 정적 폰트에선 무시되어 무해, 게이트 단순화). `verify_splash.mjs` 보정: 리소스 필터·스로틀(HEAVY)·MIME에 woff2 추가(미보정 시 전/후 비교 불공정).
- **게이트 산출물:** `build/verify_splash/pr3-before-light.json`(전)·`pr3-after2-light.json`(후). 한자는 기존대로 엔진 Noto 폴백(콘솔 경고 1건 = 기존 동작).
- **유지 규율:** 새 코드에 fontWeight 추가 시 Wght 병기(1:1 게이트 grep: `fontWeight: FontWeight\.w\d{3}(?!, fontVariations)` 0건). Flutter 업그레이드 시 woff2 디코드 전제 재확인(DESIGN.md Typography 참조).

## 0-w. 완료: 시각 리펙토링 PR2 — 전환 모션 6키 + state_views 7페이지, main 배포됨 (2026-06-13)

게이트 전부 그린: **474 테스트**(신규 14 — 6키 등록·duration 150–250·iOS fade·disableAnimations 생략·Loading 150ms 유예/해소 시 미표시·Empty 아이콘 금지·Error 콜백·FocusRing 점등/소등), analyze 신규 0건(기존 3건 잔존), 해요체 grep 0건, dogfood(빈 상태 라이트/다크 와이어프레임 대조·cert 상세·학습문서·퀴즈 골든 패스·콘솔 에러 0).

- **T4 전환 모션:** `app_theme.dart`의 `AppFadePageTransitionsBuilder` — enter 200ms ease-out / exit 150ms ease-in(`transitionDuration`/`reverseTransitionDuration` 오버라이드), TargetPlatform 6키 전부, `MediaQuery.disableAnimationsOf` 시 child 그대로. `app_router.dart` 무변경.
- **T5 state_views:** `lib/widgets/state_views.dart`(Loading 150ms 유예+80ms 페이드인 / Empty 아이콘 없음+선택 CTA / Error wrong 시맨틱+재시도+홈) + `lib/widgets/focus_ring.dart`(액센트 2px+오프셋 2px, 레이아웃 시프트 없음). 7페이지 와이어링: **cert_detail StatefulWidget 전환+fatal 승격**(승인된 변경 ③ — build마다 `_load()` 재호출 패턴은 보존해 복귀 시 진행률 재계산 동작 유지, 재시도=`setState`), cert_exam **에러/빈 분기 분리**(로드 실패가 "문항 없음"으로 위장하던 것 교정), 나머지 5페이지 `late final`→`late`+재시도 재할당. optional degrade(cert_detail:guide/summary/뱅크, review/report/cert_exam:개별 뱅크, exam:가이드 메타) 전부 주석과 함께 보존. review/report 빈 상태에 "모의고사 시작하기" CTA(와이어프레임 3번 섹션 승인 패턴).
- **DT1·DT2·DT3 일부:** 카피 매트릭스+fatal/optional 분류표+빈 상태 매핑 = `docs/superpowers/specs/2026-06-13-pr2-state-views-copy-matrix.md`. DESIGN.md 갱신(Motion 확정값·Focus 토큰 섹션·State Views 섹션·Voice 카피 패턴·Decisions Log). focus-visible 적용: 상태뷰 버튼+홈 테마 토글(헤더는 PR4).
- **dogfood 교훈:** 학습문서 딥링크 taskId는 `clf-t1-1` 형식(`t1-1` 아님 — 틀리면 redirect 가드가 홈으로, 라이브도 동일한 정상 동작). SPA 부팅 후 해시 goto는 풀 리로드가 아님 — 테마 키 주입 후엔 `reload` 필요.

**그 외 대기(사용자 우선순위 결정 사항):**
- **모의고사 중량·증가 검토 브레인스토밍(직전 §0, 사용자 지시 2026-06-11):** §2 백로그(①CLF ≥15 심화 ②SAA-C03 문항 ③C-중량) 우선순위 재검토. 시각 리펙토링 트랙(PR2~4)과의 선후는 사용자 결정 — 끼어들기 가능.
- 잔여 존치 플래그(필요 시 재론): 배치 B 미지적 5건(§0-z) · 배치 C [유지] t2-3 "참조 구조".
- §0-b 선택 항목(2기기 pull 검증·개인정보 고지).

## 0-x. 완료: 시각 리펙토링 PR1 — 스플래시·부팅 재배열·테마 영속화, main 배포됨 (2026-06-13)

**백색 화면 2,957ms → 123ms(실측, 스로틀 700ms 동일 조건 전/후).** main `925df74` 머지·push → Pages 자동 배포 → 실사이트 dogfood(스플래시 표시→소멸·콘솔 에러 0) 확인. 게이트 전부 그린: 테스트 460케이스(신규 9 — SyncEntry 늦은 주입 회귀·테마 라운드트립·파손 폴백·init 실패 degrade), analyze 신규 0건(기존 3건 잔존: plan_page cacheExtent deprecated·sync_controller_test 2건 — PR1 범위 외 보존), 라이트/다크 스크린샷 와이어프레임 대조.

- **구현:** `web/index.html` 커스텀 부트스트랩(단계 문구 3종 합니다체 + 헤어라인 진짜 진행률 33/66/100 + stall 워치독 20s 비차단 + flutter-first-frame 페이드아웃 250ms + reduced-motion) · `ThemePrefStore` 신설(테마 영속화) · `main.dart` 부팅 재배열 · `tool/verify_splash.mjs`(T3 검증 도구) · DESIGN.md Voice/Splash 섹션(DT2-PR1).
- **승인된 의도적 동작 변경 2건 발효:** Sync 시작이 첫 프레임 뒤로(수백 ms) · 테마 영속화(세션 한정→영속). 나머지 동작 변화는 결함으로 취급.
- **도구 교훈:** verify_splash에서 같은 node 프로세스가 정적 서버를 돌리며 browse를 `spawnSync`로 부르면 이벤트 루프 데드락(서버가 browse 요청에 응답 불가) — browse 호출은 반드시 비동기 spawn. 자세한 수치·경위: 메모리 [[visual-refactor-design-approved]].

## 0-y. 완료: 배치 C(SOA 20) — main 배포됨 (2026-06-12)

검수 게이트 판정 5건 반영(필수 2: t2-4 §4 버전 ID 인과·t4-2 §3 "반드시" 단정 / 권장 2: t2-1 "비례 응답"·t4-2 Q5 관리형 Automation 문서 용어 / 유지 1) → 20개 lastVerified=2026-06-12(+출처 줄 병기) → main 병합·배포·브랜치 삭제. 리뷰 실적: 단정·내부 구현 보수화 ~25건, SAA 동주제 표절 블록 5건 재작성, 무출처 수치 4건 제거, T 패밀리 모드 일반화 선제 교정, 포인터 라벨·길이 교정 ~27건.

## 0-z. 완료: 배치 B(SAA 24) — main 배포됨 (2026-06-12)

검수 피드백 8건(공식 문서 WebFetch 대조) 반영 → 24개 lastVerified=2026-06-12 → main 병합(681b193)·배포·브랜치 삭제. 핵심 교정: 스팟 '경매' 모델(기존 본문 포함)·TGW 중복 CIDR 미지원·T 패밀리 모드 구분·SR-IOV DMA 제거·LSI 보수화·CUR backfill. **검수-존치 플래그(미지적 — 필요 시 재론):** t1-2 '권한 세트' 행 · t3-6 RCU/WCU 행 · t3-8 '비전이' 행 · t3-9 Kinesis 설계 의도 · t4-4 '캐시 히트율' 행.

- **배치 C 준비·실행 기록:** 사전 점검 결과 SOA 코드 펜스 오염 0건(테스트 보강 불필요), `####` 0건, 캡 케이스 없음(서브섹션 5~8), 기존 왜-Q 4개 문서(t2-2·t3-2·t3-4·t5-1)는 Q 생략(t1-5 전례). RED 29e7c67(+133 -56) → 문서별 루프(배치 B 검증 패턴 + 개선: 블록 줄 수 직접 세기·포인터 1:1 대조·실재성 전수 검사표 강제·교차 정합 재검·컨트롤러 tail 실측+스팟 체크) → 전체 그린.
- **테스트 카운팅(main 반영됨, faa16d9):** `^### `만 카운트(#### 제외) + 하한 캡 8.

## 0-a. 완료: 배치 A(CLF) — main 배포됨

**CLF 19/19 고도화 출고(2026-06-11).** 본인 검수 5건 보수화 반영(S3 기본암호화·SecurityHub CSPM·Support 최신성·SP/RI·VPN-DX), lastVerified 갱신, 319 테스트. 배치 C(SOA 20)는 코드 펜스 `###` 오염 사전 점검 필수(Plan 2 Task 7 — 배치 B의 사전 점검에선 SAA 오염 0건이었음).

- 문서: 스펙 `docs/superpowers/specs/2026-06-11-content-enrichment-design.md`(§4.4 freeze) · 플랜 `docs/superpowers/plans/2026-06-11-content-enrichment-rollout.md` · 파일럿 전례 `plans/2026-06-11-content-enrichment-pilot.md`.
- **방향 결정(2026-06-11, 사용자):** 모의고사 중량화·문항 증가보다 학습 내용 고도화 우선. 고도화(배치 B·C) 완료 후 모의고사 중량·증가 검토.

---

## 0-b. 같은 날 완료: 클라우드 동기 Phase 1 — **전체 출고**

Google 로그인 시 학습 데이터(일정·응시이력·열람·체크)를 기기 간 동기. 로컬-퍼스트 + *선택적* 로그인, 미로그인은 로컬-only.

**2026-06-11 세션에서 닫은 것 (모두 main 병합·배포):**
- **라이브 Firebase 연결** — 사용자 프로젝트 `awc-docs-cf67d` 생성, `flutterfire configure`로 `firebase_options.dart` 실값(게이트 ON), Google Auth + Firestore + 보안 규칙(스펙 §8) + authorized domain(`velkaressiablutkrone.github.io`) 설정 완료.
- **로컬→클라우드 트리거 갭 보강** — `SyncController`에 주기 Timer(`defaultSyncInterval` 30s, signed-in 한정) + 앱 복귀(web `visibilitychange`, `app_resume*.dart` 조건부 import) 트리거. 스펙 §6.2 충족.
- **리뷰 후속 하드닝** — 전환 인터리브 시 고아 타이머/스테일 부착 차단(세대 가드 `_gen`), 트리거 해제를 진입 시 **동기** teardown으로(await 뒤로 밀리는 창 제거), dispose 후 notify 가드, signOut 시 `_pending` 클리어.
- **라이브 e2e 검증(실측):** 로그인 → 데이터 생성 → **재로그인 없이** 30s/탭복귀로 Firestore `users/{uid}/*` 반영 확인. 콘솔 에러 0.

**검증:** `cd flutter_app && flutter analyze lib && flutter test` (**262 테스트**). 배포는 main 푸시 시 GitHub Actions(`pages.yml`) 자동.

### 남은 선택 항목 (작음)
1. **2기기 pull 검증(사용자 5분):** 두 번째 기기/브라우저에서 같은 계정 로그인 → 첫 기기 데이터가 내려오는지. push 방향·병합 로직은 검증됨, pull 실기기 확인만 남음.
2. **개인정보 고지:** Google 로그인이 라이브가 됐으므로 "무계정·무추적" 정체성과의 관계 정리(간단 고지 문구). 메모리 [[study-app-cloud-direction]] 하단 주의 참조.
3. **Phase 2(푸시 알림)는 보류** — `docs/plans/2026-06-10-firebase-fcm-feasibility.md`.

---

## 1. 아키텍처 핵심 (이어받기 전 알아야 할 것)
- **부팅 순서(PR1, 2026-06-13):** `main()`은 `runApp()` 즉시 호출 → `addPostFrameCallback`에서 `initCloudSync()`(Firebase/SyncController 후행 초기화). 전역 `syncController`는 `ValueNotifier<SyncController?>` — `SyncEntry`가 `ValueListenableBuilder`로 구독해 늦은 주입 시 리빌드. init 실패는 try/catch → 로컬 전용 degrade + debugPrint(글로벌 핸들러 연결은 PR4/WS8). **Firebase init을 첫 프레임 앞에 await로 되돌리면 안 됨** — 백색 화면 주범 ②였음.
- **테마 키 계약(PR1):** localStorage `awsdocs.theme.v1` = `'dark'|'light'` **평문**(JSON 금지 — `web/index.html` 스플래시 JS가 파싱 없이 직접 읽어 첫 페인트 색을 맞춤). Dart 쪽은 `lib/data/theme_pref_store.dart`(파손/미존재 → 라이트 폴백). 키/값 계약 테스트: `test/theme_pref_store_test.dart`.
- **스플래시 유지비(PR1):** `web/index.html`이 `{{flutter_js}}`/`{{flutter_build_config}}` 토큰 기반 커스텀 부트스트랩 — Flutter 마이너 업그레이드 시 토큰 호환 확인 후 `node tool/verify_splash.mjs` 1회 실행(존재→소멸 어서션+타이밍). browse 데몬(gstack) 필요.
- **reconcile-on-trigger (가로채기 없음):** 스토어와 `SyncService`가 **같은 localStorage**(`defaultBackend()`)를 읽고/써서 reconcile 결과가 스토어 다음 읽기에 자동 반영. 트리거(로그인·cloud watch·주기 30s·앱 복귀)에 **멱등** `reconcileAll` 재실행.
- **graceful degrade 게이트:** `firebase_bootstrap.dart`의 `cloudConfigured()` — `DefaultFirebaseOptions.web.projectId`로 판독(웹 전용 앱; `currentPlatform`은 테스트 VM에서 throw하므로 금지).
- **충돌 해소:** history=레코드 union(무손실), viewed=set union, plan/checks=LWW(사이드카 `awsdocs.sync.v1`). 순수 함수 `sync_merge.dart`.
- **SyncController 동시성:** auth 스트림이 `_onUser`를 await 없이 호출 → 전환 인터리브 가능. 세대 가드(`_gen`)가 스테일 전환의 watch/timer 부착을 차단, teardown은 진입 시 동기 수행(cancel future를 기다리면 해제가 밀림 — 코드 주석 참조).
- **파일:** `lib/data/cloud/{auth_user,auth_service,cloud_store,sync_merge,sync_service,firebase_bootstrap,firestore_cloud_store,firebase_auth_service,sync_controller,app_resume,app_resume_stub,app_resume_web}.dart` · `lib/firebase_options.dart`(실값, 공개 안전) · `lib/pages/sync_entry.dart` · `lib/main.dart` · `lib/pages/home_page.dart`(⚙ + 햄버거 진입점).
- **비용 노트:** 주기 트리거는 변경 없어도 틱마다 4컬렉션 로드(개인 규모 수용). 조정점 = `SyncController.defaultSyncInterval`.

---

## 2. 대기 작업 (콘텐츠 백로그 — 연기 조건 "고도화 완료"는 2026-06-12 충족, **모의고사 중량·증가 브레인스토밍에서 우선순위 재검토 대기**)
이전 핸드오프 상세는 git `9c30e72`의 `HANDOFF.md` 참조. 요약:
- **① ≥15 심화:** CLF 각 Task 12→15 verified(+57문항). 워크플로 메모리 [[content-density-loop]]. **고도화 후 재검토.**
- **② SAA-C03 문항 착수:** 현재 문항 0(학습문서만). **고도화 후 재검토.**
- **③ C-중량:** 개념 → 학습문서 *섹션* 앵커 딥링크. 가치 증명 후.
- **철칙:** `verified=사람 검수만`(AI가 true 금지) · 문항 새 개념은 학습문서(`t*.md`)도 보강 · 시각/UI는 `DESIGN.md` 먼저.

---

## 3. 워킹트리 / 메모
- 미커밋: 없음(이 문서 갱신 커밋 제외). 전체 스위트 **474 테스트** 그린 기준점(2026-06-13, PR3까지 출고 후에도 동일).
- `verify_splash` 사용: `cd flutter_app && node tool/verify_splash.mjs [--skip-build] [--throttle <ms>] [--theme dark] [--label <x>]` — 보고서/스크린샷은 `build/verify_splash/`. PR3 폰트 전환의 전/후 타이밍 비교에 그대로 재사용.
- **정리 필요(사소):** `D:\workspace\awc-before`(전/후 측정용 임시 워크트리 잔재)가 파일 잠금으로 미삭제 — 탐색기에서 수동 삭제. git 등록은 prune 완료.
- 시각 QA 레시피: 메모리 [[flutter-web-visual-qa-recipe]]. 방향·결정: [[study-app-cloud-direction]]. 시각 리펙토링 경위·실측: [[visual-refactor-design-approved]].

**다음 세션 첫 수: §0 시각 리펙토링 PR4(AppHeader 롤아웃·페이지 분해·키보드 감사·17종 매핑표 — B안 마지막 슬라이스). 끼어들기 후보: 모의고사 중량·증가 브레인스토밍(§0 대기 목록). 그 외: §0-b 선택 항목(2기기 pull·개인정보 고지).**
