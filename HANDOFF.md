# HANDOFF — 다음 세션 이관

_갱신: 2026-08-06 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

---

## 0. 다음: SAA-C03 weighted-ready 사람 검수 batch → flip (통합/약점 모의고사 게이트)

**브랜치 전략(2026-06-15~):** `main` 보호, `develop` 통합. 작업 브랜치 → develop PR → (릴리스 시) develop → main PR. 전역 규칙 `~/.claude/rules/git-branch-flow.md`.

**✅ 최신 반영(2026-08-06): SAA-C03 통합/약점 모의고사 공개 조건은 이제 `verified:true` 1개가 아니라 공식 도메인 비중 기반 weighted capacity다.** 앱의 65문항 연습 세트 기준 SAA 필요/현재 = **D1 19/0 · D2 17/15 · D3 16/45 · D4 13/30** → 현재 잠김. 부족분은 D1 최소 19문항 + D2 최소 2문항이며, 추천 batch는 [2026-08-06-weighted-ready-batch.md](docs/saa-review/2026-08-06-weighted-ready-batch.md), 검수지는 [2026-08-06-weighted-ready-review-sheet.md](docs/saa-review/2026-08-06-weighted-ready-review-sheet.md). 단, `verified:true` flip은 계속 사람만 수행한다.

**✅ 완료(2026-06-18 세션3) ① C-중량 Phase 2 develop 복구:** 누락 복구 소스로 `feat/concept-deeplink`(cfbb34f, 머지커밋 노이즈) 대신 **`feat/concept-report`(41e81bf, 정확히 델타 5커밋)** 선택 — develop 결과물 diff 동일(`ce0a6a8`), base=develop 직접 PR이라 스택 경합 회피. **PR#21 머지(merge `6421603`)** → develop에 `wrongSkills`·`buildConceptReport` 복구 확인, develop 실측 **519 그린**. 차기 develop→main 릴리스로 라이브 예정. 메모리 [[concept-deeplink]] [[stacked-pr-merge-order-race]].

**✅ 완료(2026-06-18 세션3) ② SAA-C03 문항 드래프트 전 도메인 완비:** 사용자 결정 = 작성+flip(게이트 해제 전제), 단 **verified=사람 검수만**(AI flip 금지). **24 Task 전부 각 15문항 = 총 360문항 `verified:false` 드래프트** develop 머지 완료. 도메인 4배치: D1(PR#22)·D3(PR#23)·D2(PR#24)·D4(PR#25). `saa-t1-1`=직접 작성 정본, 나머지 23개=Task별 스코프락 서브에이전트(파일 1개·git 미조작 → 컨트롤러 파일 실측). 신규 가드 `test/saa_questions_test.dart`(24 Task 전수: 파일·≥15·id유일·options 4·correct 0~3·wrongExplanations 키=비정답 인덱스 전부·sources http). 출처는 각 문서 frontmatter 범위 내(기계 대조 24/24 OK). **전부 verified:false라 verified 게이트로 비노출·`content_index` questionCount:0 불변**(사이트·카운트 변화 0). 테스트 **567 그린**(519 + SAA 가드 48)·analyze 신규 0. 메모리 [[saa-c03-study-docs-first]] [[question-bank-verified-workflow]].

**⚠️ 미수행(의도적): SAA 문항 내용 정확성 딥리뷰는 안 함** — verified flip은 사람 검수 전용이라 구조·출처만 기계 검증함. 정답·해설·distractor 품질은 검수자가 확인할 몫.

**다음 작업 우선순위:**
- **① SAA-C03 weighted-ready 사람 검수 → flip** — 공개 게이트 관점에서는 부족 도메인만 우선한다. 현재 목표는 D1 19문항 이상 + D2 2문항 이상 추가 verified 확보. flip 후 `content_index` 해당 Task `questionCount` 실제 수로 동기화한다. `verified:true` flip은 사람 전용이며, 통합/약점 모의고사는 도메인별 weighted capacity 충족 전까지 계속 잠긴다. 워크플로 [[question-bank-verified-workflow]].
- **② 릴리스/PR 정리** — develop→main 릴리스 최신 상태는 [WORKLIST.md](WORKLIST.md) §B를 우선 기준으로 본다. CI는 main push 시 Pages 배포.
- **점진:** 나머지 학습문서·문항의 `{#id}`/`section` 앵커 채움(C-중량은 t1-1만 시드, 나머지는 graceful 폴백=문서 최상단). 메모리 [[concept-deeplink]].
- §0-b 선택 항목(2기기 pull 검증·개인정보 고지) · 잔여 존치 플래그(§0-y).
- (이연 기록) cert_detail Master-Detail 적응형(OQ1) · 홈 내비 활성탭 언더라인(허브형 라우팅 도입 시) · plan 글래스 헤더(NestedScrollView 구조 변경 시).

**라이브 dogfood 참고(세션2):** 딥링크 라우트 형식 = `/cert/CLF-C02/study/clf-t1-1?at=<section>`(study는 `cert/:code` 하위 중첩; 잘못된 taskId/code는 `redirect→'/'`, 매칭 없는 경로는 "페이지를 찾을 수 없습니다"). Phase 1 릴리스 PR#19(main fc7b07f).

## 0-r. C-중량 개념→학습문서 섹션 앵커 딥링크 — Phase 1 main 릴리스 / Phase 2 develop 복구 완료(PR#21) (2026-06-18)

**오답 복기 개념 큐 + 약점 리포트 개념 칩이 학습문서 최상단이 아니라 해당 섹션으로 딥링크.** 스펙 `docs/superpowers/specs/2026-06-18-concept-deeplink-design.md`, 플랜 `…/plans/2026-06-18-concept-deeplink-phase{1,2}.md`. 2단계 스택 PR: **PR#15 Phase 1(`feat/concept-deeplink`→develop, 머지됨·main 릴리스됨)** · **PR#16 Phase 2(`feat/concept-report`→`feat/concept-deeplink`)**. ⚠️ PR#16 base가 develop이 아니라 `feat/concept-deeplink`였고 머지가 PR#15보다 13초 늦어(05:02:49 vs 05:02:36Z) Phase 2가 한때 develop에 미반영됐었음 → **세션3에서 `feat/concept-report`(델타 5커밋)→develop PR#21로 복구 완료(merge `6421603`, develop 519 그린)**. 차기 develop→main 릴리스로 라이브 예정.

- **흐름:** `학습문서 제목 {#id} → MdHeading.anchor` · `문항 section → ?at= → targetAnchor → 섹션 스크롤(헤더 보정)`.
- **Phase 1(딥링크 코어):** `{#id}` 파서(`markdown_parser`·`MdHeading.anchor`, throw 없음·잘못된 형식 리터럴) · 문항 `section` 필드(+`withOptionOrder` 셔플 운반) · `anchor_scroll.dart`(`anchorScrollOffset`·`buildAnchorKeys` 순수) · `StudyDocPage(targetAnchor)` ScrollController·post-frame `getOffsetToReveal`·graceful no-op·reduced-motion jump · 라우트 `study/:taskId?at=` · 개념 큐 `onOpenStudy(taskId, section)`+`studyDeepLink()` · 정본 t1-1 시드(앵커 5·문항 6).
- **Phase 2(리포트·비정규화):** `WrongSkill{skill,section,taskId}`+`AttemptRecord.wrongSkills`(레거시 빈 리스트)+`buildWrongSkills`(응시 제출부 2곳) · `buildConceptReport`(순수, **비정규화 우선 → 없으면 라이브 뱅크 조인 폴백**·Task별 dedup) · report_page 약점 Task별 개념 칩(`_ConceptLink`: InkWell+InsetFocusRing, 중립 라벨+액센트 화살표)+`studyDeepLink`.
- **게이트:** `flutter test` **519 그린(`feat/concept-deeplink` = Phase 1+2 병합본 기준)** · **develop(Phase 1만) 실측 512** · `flutter analyze` 신규 0건 · 라이브 dogfood(딥링크 `?at=core-benefits`/`ha-elasticity` 섹션 스크롤·미존재 앵커 최상단 폴백·약점 t1-1 60% 리포트 6칩 렌더·콘솔 클린). 스크롤은 SelectionArea 위젯테스트 함정 회피 위해 순수 함수 단위테스트로 검증.
- **교훈:** subagent-driven 실행 중 리뷰어 서브에이전트가 긴 리포트 본문을 잃고 verdict만 반환(모델 무관) → 컨트롤러가 diff 직접 정독 검증. 메모리 [[subagent-reviewer-empty-output]].

## 0-q. 완료: CLF 문항 밀도 ≥15 심화 — main 배포됨 (2026-06-15, 라이브 확인)

**CLF-C02 19개 Task 전부 12 → 15 verified(총 228→285, +57).** 백로그 ① 완료. 스펙 `docs/superpowers/specs/2026-06-12-clf-question-density-15-design.md`, 플랜 `docs/superpowers/plans/2026-06-15-clf-question-density-15.md`.

- **파이프라인(서브에이전트 구동):** Task당 +3(원리형·함정 혼동형·미커버 보완) 드래프터 → AI 리뷰어 → 컨트롤러 실측 → **사람 검수 게이트(배치별 종합 판정)** → flip. 도메인 4배치(D1·D2·D3 24문항·D4) 각 `feat/clf-q15-d{1..4}` → develop PR(#2~#6).
- **게이트:** 전부 applied 중심, 해당 고도화 문서·frontmatter 출처 범위 내(새 개념 0 — grep 검증), content_index questionCount 19×15, **밀도 가드 `question_model_test` 12→15 상향**, 전체 499 테스트 그린.
- **검수 반영 주요 수정:** t1-1 q13(가상화 단정 보수화)·q15(냉각 출처/q8 중복), t2-4 q14(정답 단일성: '누가'→Config 전용), t3-4 q14(ElastiCache 단정 완화), t4-1 q13(리전 내 무료 오독 방지)·q15(RI 교환 제약)·t4-2 q15(태그 Billing 활성화)·t4-3 q13(Support 플랜명 완충).
- **사고·복구(D1):** 리뷰어 서브에이전트가 임의 브랜치 생성 → flip 커밋이 feat 브랜치 밖에 쌓여 PR#2가 검수 전 초안으로 머지됨. 직접 grep 검증으로 포착, PR#3로 복구. 이후 위임 프롬프트에 git 조작 금지 + push 전 head SHA 검증 도입. 메모리 [[subagent-git-branch-pollution]].

## 0-u. 완료: 시각 리펙토링 PR4 — AppHeader 롤아웃·페이지 분해·키보드 감사, main 배포됨 (2026-06-13)

**main `914bcb1` 머지·push → Pages 배포 성공 → 실사이트 dogfood ✓**(홈 글래스 헤더·학습문서 브레드크럼+검수 메타·콘솔 에러 0 — 기존 Noto 한자 폴백 경고만).

**B안 마지막 슬라이스 (T7·T8·T9·T12·DT4+DT3 잔여·T10).** 게이트: analyze 신규 0건(기존 3건 잔존 — cacheExtent는 plan_agenda.dart로 이주) · **499 테스트 전부 그린**(474→499: AppHeader 14·cert_detail 섹션 8·에러 핸들러 3) · Wght 1:1 게이트 0건 · dogfood 9페이지×(1180+반응형 360/768+다크) 콘솔 에러 0 · 키보드 Tab/Enter/FocusRing 실증.

- **T12 AppHeader 롤아웃:** `widgets/app_header.dart`(문서형+셸 56px·blur 14·88%+`HeaderCollapse` 순수 함수+`ThemeToggleButton`+`HeaderIconButton`+`headerScrollInset`) — 9페이지 전부 교체. 홈형은 `pages/home/home_header.dart`(60→56px, compact 햄버거 이식). 브레드크럼 "섹션 / 제목"으로 기존 타이틀 분해(정보 손실 0 — 인벤토리 대조 체크리스트 전 항목 ✓). collapse는 TextPainter 실측 기반(날짜→배지→섹션→ellipsis 12자→backLabel 최후). **글래스(extend)는 plan 제외 전 페이지** — plan은 내부 SliverAppBar 충돌(재량 결정 3). 세션 액션(타이머·플래그)은 본문 유지=OQ2 해소. 홈 앵커 스크롤은 헤더 높이 보정(`_goto` alignment). study_doc은 FutureBuilder가 Scaffold를 감싸도록 재구조화(헤더 검수 메타 `✓ 검증됨 · 날짜` 로드 후 표시). 테마 토글이 전 페이지 헤더에 신설(ThemeScope 셀프서비스). 인벤토리·재량 결정 정본: `docs/superpowers/specs/2026-06-13-pr4-appbar-inventory.md`.
- **T8 분해:** home 1,286→**202줄**(`pages/home/` 10파일) · cert_detail 904→**164줄**(`pages/cert_detail/` 5파일, **섹션 위젯 테스트 8케이스 선행** — SelectionArea 셸 밖 단독 렌더) · plan 707→**64줄**(`pages/plan/` 3파일, planSummary는 plan_page가 re-export해 테스트 import 보존). 전부 ≤400 게이트 ✓. 분해가 잠재 결함 1건 노출·수정: cert_detail 도메인 아코디언의 잉크가 장식 밑에 그려지던 문제(투명 Material 삽입).
- **T7 공용 위젯:** `AppBadge`(4페이지 중복 배지 레시피 통합) 신설 + 헤더 4종 + FocusRing 계열 + state_views 3종 = lib/widgets/ ≥5종 ✓. 카드·진행률바·섹션헤더는 페이지별 기하가 달라 미승격(선제 승격 금지 — 매핑표에 기록).
- **T9 에러 핸들러:** `lib/app_errors.dart` — FlutterError.onError(presentError+로그)·PlatformDispatcher.onError(true)·ErrorWidget.builder(절제 박스)·`appLog` 단일 훅(부팅 degrade 경로 연결). 단위 테스트 3(핸들러 저장→복원 필수 — 테스트 프레임워크가 onError 소유).
- **DT4 키보드 감사:** focus-visible **인셋 변형 신설**(`InsetFocusRing`/`FocusTap` — 밀집 그리드에서 레이아웃 불변) + 전 인터랙티브 적용(선택지·버튼·그리드 칩·플래그·카드·CTA·플랜 행/월 셀). **히어로 출처 필이 GestureDetector라 키보드 조작 불가였던 결함 수정**(InkWell 전환). 감사표+17종 매핑표(T10): `docs/superpowers/specs/2026-06-13-pr4-pattern-mapping.md` (SC7의 "16 적용"은 10 Local Storage의 오기로 판단·기록).
- **유지 규율:** 새 인터랙티브는 InkWell 계열+(Inset)FocusRing 필수, GestureDetector 단독 금지(DESIGN.md Focus 규칙). 헤더 슬롯 변경 시 인벤토리 문서의 기능 손실 0 체크리스트 갱신.

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

## 0-y~0-a. 완료(2026-06-11~12): 콘텐츠 고도화 배치 A(CLF 19)·B(SAA 24)·C(SOA 20) — 전부 main 배포됨

3개 배치 전체 검수·고도화·lastVerified 갱신 완료. 검수 경위·교정 실적·테스트 카운팅 변경 전문은 **git `a9e4463`의 HANDOFF.md(§0-y·0-z·0-a)** 참조.
- **살아있는 플래그(필요 시 재론):** 배치 B 검수-존치 5건 — t1-2 '권한 세트' · t3-6 RCU/WCU · t3-8 '비전이' · t3-9 Kinesis 설계 의도 · t4-4 '캐시 히트율' / 배치 C [유지] 1건 — t2-3 "참조 구조".
- **방향 결정(2026-06-11, 사용자):** 고도화 우선 → 완료됐으므로 모의고사 중량·증가 브레인스토밍이 §0 대기 목록에 올라가 있음. 스펙·플랜: `docs/superpowers/specs/2026-06-11-content-enrichment-design.md` 외(§0-a 전문 참조).

---

## 0-b. 완료(2026-06-11): 클라우드 동기 Phase 1 전체 출고 — 라이브 Firebase `awc-docs-cf67d`

로컬-퍼스트 + *선택적* Google 로그인 동기(미로그인=로컬-only), 라이브 e2e 실측 완료. 아키텍처는 §1에 살아 있고, 구축 경위 전문은 **git `a9e4463`의 HANDOFF.md(§0-b)** 참조.

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
- **① ≥15 심화:** ~~CLF 각 Task 12→15 verified(+57문항).~~ **완료·배포(2026-06-15, §0-q) — 라이브 반영.** 워크플로 메모리 [[content-density-loop]].
- **② SAA-C03 문항 착수:** 현재 문항 0(학습문서만). **고도화 후 재검토.**
- **③ C-중량:** ~~개념 → 학습문서 *섹션* 앵커 딥링크.~~ **완료(2026-06-18, §0-r) — develop 머지·main 릴리스 대기.** Phase 1·2(PR #15·#16).
- **철칙:** `verified=사람 검수만`(AI가 true 금지) · 문항 새 개념은 학습문서(`t*.md`)도 보강 · 시각/UI는 `DESIGN.md` 먼저.

---

## 3. 워킹트리 / 메모
- 미커밋: 없음. 전체 스위트 기준점: **develop = 512 그린**(Phase 1 딥링크 코어) · **`feat/concept-deeplink` = 519 그린**(Phase 1+2; Phase 2 복구 PR로 develop 반영 예정). 499→519 신규: 앵커 파서·문항 section·anchor_scroll·study_deep_link·wrong_skills·concept_report 단위테스트(이 중 wrong_skills·concept_report = Phase 2, 현재 develop 미포함).
- **브랜치(2026-06-15~):** `main`(보호·배포)·`develop`(통합)만 존재. 작업은 `feat/*`→develop PR→(릴리스)develop→main PR. main은 develop보다 릴리스 머지커밋만큼 앞설 수 있으나 콘텐츠 동일. 문항 추가 워크플로·서브에이전트 위임 규율: [[question-bank-verified-workflow]]·[[subagent-git-branch-pollution]].
- **테스트 함정 추가(PR4):** testWidgets 본문에서 `rootBundle.loadString`을 await하면 파일 연속 실행에서 행(10분 타임아웃, 단독은 통과) — 에셋은 `setUpAll` 1회 로드. 메모리 [[flutter-selectionarea-widget-test-pitfall]] 갱신됨.
- `verify_splash` 사용: `cd flutter_app && node tool/verify_splash.mjs [--skip-build] [--throttle <ms>] [--theme dark] [--label <x>]` — 보고서/스크린샷은 `build/verify_splash/`. PR3에서 리소스 필터·스로틀(HEAVY)·MIME에 woff2 보정 완료(otf/ttf/woff2 동등 취급). 전/후 비교 보고서: `pr3-before-light.json` / `pr3-after2-light.json`.
- **로컬 dogfood 서버 주의:** 포트 8124에 이전 세션의 진단용 node 서버(cwd 기준 `build/web` 서빙)가 살아 있을 수 있음 — `EADDRINUSE`면 새로 띄우지 말고 서빙 콘텐츠 해시를 로컬 빌드와 대조 후 재사용(요청 시점에 파일을 읽는 구조라 재빌드가 그대로 반영됨). browse dogfood 함정 모음(SW 캐시·taskId `clf-t1-1` 형식·해시 goto≠리로드·main.dart.js 한국어 grep 무효): 메모리 [[flutter-web-dogfood-browse]].
- **정리 필요(사소):** `D:\workspace\awc-before`(전/후 측정용 임시 워크트리 잔재)가 파일 잠금으로 미삭제 — 탐색기에서 수동 삭제. git 등록은 prune 완료.
- 시각 QA 레시피: 메모리 [[flutter-web-visual-qa-recipe]]. 방향·결정: [[study-app-cloud-direction]]. 시각 리펙토링 경위·실측: [[visual-refactor-design-approved]].

**✅ 완료(2026-06-18 세션2): C-중량 Phase 1 develop → main 릴리스·라이브 확인.** 스택 PR 경합으로 Phase 2가 develop에 누락됐음을 확인(§0 정정 박스) → 사용자 결정으로 **Phase 1만 우선 릴리스**(PR#19, main fc7b07f → Pages 배포 성공 → 라이브 dogfood 통과). **다음 세션 첫 수: ①C-중량 Phase 2 develop 복구** (`feat/concept-deeplink`→develop PR, 델타 5커밋, 머지 후 519 검증 → 차기 릴리스). 그다음 **②SAA-C03 문항 착수**(현재 0) · C-중량 나머지 문서 앵커 점진 채움 · §0-b 선택 항목. 문항 생산은 §0-q 파이프라인(서브에이전트 드래프터→AI 리뷰→컨트롤러 실측→사람 검수 게이트→flip) 재사용.
