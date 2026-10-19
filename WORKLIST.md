# WORKLIST — 통합 작업 목록

_생성: 2026-06-19 · 갱신: 2026-10-20(현황을 릴리스 번호 대신 불변식으로 표기) · HANDOFF.md(상세 이력·아키텍처)·TODOS.md(백로그)·멀티 일정 플랜에 흩어진 작업을 한곳에 통합한 단일 현황표._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

> **이 문서의 역할:** "지금 무엇이 남았나"의 단일 진입점. 각 작업의 *경위·아키텍처·교훈*은 [HANDOFF.md](HANDOFF.md)에, *백로그 근거*는 [TODOS.md](TODOS.md)에 그대로 있다(이 문서가 그것들을 대체하지 않고 인덱싱한다).

**범례:** `[ ]` 미착수 · `[~]` 진행 중 · `[x]` 완료(반영 확인) · 🔒 게이트(선행조건 충족 전 착수 금지)

---

## A. 진행 중 (즉시)

- [~] **SAA-C03 오디오 강사체 롤아웃** — 24문서 스캐폴드 완료·20문서 합성·**20문서 청취면제 승인(PR#116)** develop 머지. 남은 4문서(t4-2~t4-5) enrich·합성은 Anthropic 크레딧 충전 후. 정본: [saa-audio-rollout-handoff.md](docs/superpowers/plans/2026-07-19-saa-audio-rollout-handoff.md). ✅ 번들 493MB 문제는 R2 분리 호스팅(감사 B-4, [spec](docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md))으로 해소 — mp3는 `aws-audio.leva.ai.kr` 서빙, 번들 약 60MB.

- [x] **멀티 일정 학습 스케줄** — 자격증당 여러 독립 일정(자동/수동·목록·선택·삭제) + 일정별 진행
  - **상태(2026-06-20 완료): main 릴리스됨(PR#31 `89e2795`), 라이브 dogfood 통과.** develop test 651 그린·analyze 신규 0 → develop→main(PR#31) → Pages 배포 → 라이브 4페이지 콘솔 에러 0(plan "학습 일정" 빈 상태 정상 렌더).
  - 릴리스 절차: [Phase 1 릴리스 plan](docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md).
  - 출처: spec [2026-06-19-multi-plan-study-schedule-spec.md](docs/designs/2026-06-19-multi-plan-study-schedule-spec.md) · plan [Part1 데이터](docs/plans/2026-06-19-multi-plan-schedule-part1-data.md)(Task 1~4) · [Part2 UI](docs/plans/2026-06-19-multi-plan-schedule-part2-ui.md)(Task 5~8)

---

## B. 다음 (우선순위순 — HANDOFF.md §0)

- [~] **① SAA-C03 문항 사람 검수 → `verified:true` flip** — 재검토 인프라 **T1~T8 완료·PR#47 릴리스**(saa_prescreen 도구·content_index 동적 불변식·통합시험 균형 게이트·freeze 가드·문서 스캔/수정·검수 루브릭·전360 의미+출처 prescreen). **첫 flip 6/24 Task**(suspect7+t3-4 출처, PR#46): 90문항 verified. **나머지 18 draft.** 검수·flip은 사용자(AI flip 금지) — 통합/약점 모의고사는 아래 weighted capacity 충족 시 노출. 도구 `saa_review.mjs flip <taskId>`, 루브릭 [review-rubric.md](docs/saa-review/review-rubric.md), prescreen [docs/saa-review/](docs/saa-review/).
  - 함정: `verified=사람 검수만`(AI flip 금지). verified flip이 생기면 학습문서/문항 수는 자동 반영되지만, 통합·약점 모의고사는 아래 도메인별 weighted capacity를 채울 때까지 잠김. 워크플로 → HANDOFF §0, 메모리 `question-bank-verified-workflow`.
  - **실행 플랜(잠금 2026-06-20, `/plan-eng-review`+codex 합의):** [2-pass 재검토 플랜](docs/superpowers/plans/2026-06-20-saa-rereview-plan.md) — 전수 360문항+24문서, AI 읽기전용 사전심사→사람 flip. 핵심 보강: 공개 게이트(`questionCount>0`→전 도메인 균형 세트), `content_index_test` 동적 불변식(첫 flip 회귀 차단), 문서 오류 스캔 문항 flip 선행. 착수=릴리스 후.
  - **다음 시험 구성 게이트(2026-08-06):** 통합/약점 모의고사는 공식 도메인 비중을 앱의 65문항 연습 세트에 적용할 수 있을 만큼 도메인별 검증 문항이 있어야 열린다. SAA-C03 기준 필요/현재 = D1 19/0 · D2 17/15 · D3 16/45 · D4 13/30 → 현재 잠김. 다음 사람 검수 batch의 공개 목표는 **D1 최소 19문항 + D2 최소 2문항 추가 verified** 확보. 부분 통과 규칙: 이미 필요 수량을 넘긴 도메인(D3/D4)은 공개 게이트 관점에서 pass로 두고, 부족 도메인만 계속 검수한다. 추천 batch: [2026-08-06-weighted-ready-batch.md](docs/saa-review/2026-08-06-weighted-ready-batch.md). 단, `verified:true` flip은 계속 사람만 수행한다.
  - **검수 freeze 정책(T8 · 전체 SAA · 규약+가드):** 검수 발효~전 도메인 flip 완료까지 SAA 콘텐츠(`flutter_app/assets/content/saa/*.{md,questions.json}`) 동결. **허용**=검수 구동 변경만(수정루프·T6 문서수정·flip·읽기전용 사전심사 산출물). **금지**=신규/무관 SAA 편집·대량 리포맷. **가드**=`.githooks/pre-commit`(발효 중 `saa-review*`/`review/saa*` 밖에서 SAA 콘텐츠 커밋 차단). 설치 1회 `git config core.hooksPath .githooks`; 발효 `touch .saa-frozen` / 해제 `rm .saa-frozen`(현재 dormant). 도구·테스트·플랜은 비대상. 우회 `--no-verify`(권장 안 함).
- [x] **② develop → main 릴리스** — **develop·main 내용 동일(미릴리스 0) · 열린 PR 0**(2026-10-20 실측) · `flutter test` **1,076 그린** · `flutter analyze` **0건**. 현황에는 릴리스 PR 번호를 적지 않는다(HANDOFF §0 서술 규약 ②) — 번호가 필요하면 `gh pr list --base main --state merged --limit 1`로 조회한다.
  - **콘텐츠 릴리스 PR#142**(`68ab263`, Pages run 39230610259 build·deploy success) — 머지 9건(#133·#134 + #135~#141)을 한 번에 출고. 라이브 검증: index 200 · DEA 신규 문서 200 · 정정된 SAA/SOA 본문 반영 · `exam_guides/SOA-C03.json` `guideVersion 1.1`.
  - **부기 릴리스 2건**(루트 현황 문서만 담은 릴리스) — PR#144(`b12cd10`, Pages success) · PR#146(`de20ee0`, Pages run 39239830730 success). 부기 문서 PR가 그것을 릴리스하는 PR을 다시 부르는 순환이라, 2026-10-20부터 현황을 번호가 아닌 불변식으로 적는다(HANDOFF §0 서술 규약 ②).
  - **직전 릴리스 이력:** 2026-09-23 PR#132 `58154b7`(동기 v2 → §B⑤) · 2026-09-22 PR#127 `34b1cde`(앱 리뷰 반영 → §B④) · 2026-09-03 PR#121 `acfbeac`(강의 mp3 R2 분리) · 2026-09-03 PR#118(run 33717705582 success, 라이브 SAA mp3 206·미승인 t4-2 404 실측 — weighted capacity 게이트 PR#113·시험 게이트 해제 PR#114·SAA 오디오 PR#115·#116 포함) · 2026-07-03 PR#110·#112(감사 Phase A+AR) · 2026-06-20 PR#47 `00528f9`(SAA 재검토 인프라 T1~T8 + 첫 flip 6 Task) · 2026-06-20 PR#37 `a68ae14`(CLF 섹션 앵커) · 2026-06-20 PR#31 `89e2795`(멀티 일정).
- [x] **③ 학습문서 섹션 앵커 점진 채움(CLF)** — **구현 완료·PR#34 develop 머지**(merge `58a1463`, 2026-06-20). CLF 18 Task(clf-t1-2~t4-3) 헤딩 `{#slug}` + 문항 `section` 사람 매핑 편집 + Dart **존재** 가드(`f1f3679`). spec·plan: [spec](docs/superpowers/specs/2026-06-20-section-anchors-design.md)·[plan](docs/superpowers/plans/2026-06-20-section-anchors.md). ⚠️ 가드는 *앵커 존재*만 보장 — *올바른 섹션* 의미 매핑은 사람 검토 권장. SAA 앵커는 B-① 검수·flip 후 별도. **main 릴리스 완료**(PR#37 `a68ae14`, 2026-06-20 라이브). 출처: HANDOFF §0-r.

- [x] **④ 2026-09-22 앱 코드·UX 리뷰 반영** — 외부 리뷰(🔴2·🟡10·🟢6·🎨5)를 코드 대조·재현 프로브·공식 문서로 전건 검증한 뒤 **PR#122~#126 develop 머지 → PR#127 `34b1cde` main 릴리스·Pages success**(2026-09-22). 내용: 동기 lost-update 경합(C-1·`CODE-D-004` 상향)·초기화 부활 임시 조치(C-2)·합격선 하드코딩 700 제거(M-1)·PR 게이트 CI 신설+Flutter 3.47.2 고정(M-5)·손상 이력 덮어쓰기 방지(M-3). **ANS-C01 합격선 750 정정은 반려 — 공식 가이드가 700이라 앱 데이터가 옳다.** 설정: develop·main 브랜치 보호에 `CI / test` 필수 체크 등록. 원문+검증 부록 [2026-09-22-app-code-ux-review.md](docs/audits/2026-09-22-app-code-ux-review.md), 잔여는 §B⑥. 메모리 [[app-review-2026-09-22]].

- [x] **⑤ 동기 프로토콜 v2 — 삭제 표식·일정/진행 3-way·보안 규칙** — 리뷰 C-2의 근본 해결이 설계 선행을 요구해 [spec](docs/superpowers/specs/2026-09-23-sync-protocol-v2-design.md)을 먼저 쓰고, **PR#128(설계)·#129(PR1 삭제 표식)·#130(PR2 일정·진행 3-way, 일정 개별 삭제 전파)·#131(PR3 레거시 LWW·옛 사이드카 제거·관용 파싱·`firestore.rules`) develop 머지 → PR#132 `58154b7` main 릴리스·Pages success**(2026-09-23). 초기화가 모든 기기·클라우드에서 실제로 지워지고, 일정·일정 진행이 집합 3-way로 병합된다. 동기 대상은 응시·열람 기록 + 일정(v2)·일정 진행이며 진행 중 시험 세션은 로컬 전용(비범위). 보안 규칙은 레포(`firestore.rules`+`firebase.json`)가 관리하고 에뮬레이터 테스트(`tool/firestore_rules_test`)·`firestore-rules` 워크플로가 검증한다 — **콘솔 배포 규칙 대조는 사용자 몫(§D)**. 기준선: 테스트 **892 그린**·analyze **0건**(2026-10-17 실측). 메모리 [[sync-protocol-v2]].

- [ ] **⑥ 2026-09-22 리뷰 후속 잔여** — 정본은 [리뷰 §V-4 "남은 일"](docs/audits/2026-09-22-app-code-ux-review.md)과 [sync v2 PR3 "남은 것"](docs/superpowers/plans/2026-09-23-sync-protocol-v2-pr3.md), 백로그 상세는 [TODOS.md](TODOS.md).
  - **바로 가능:** QuizView `_finish`·오답노트 `_onFinished`에 같은 try/finally + 저장 실패 사용자 알림(PR-m11).
  - **디자인 결정 필요:** M-6 대비 토큰(DESIGN.md 정렬 선행) · UX-1·2(시험 러너 모바일) · UX-4(진행 중 세션 "이어서 풀기" 진입점) · M-10/UX-5(결과 화면).
  - **후순위:** M-4(콘텐츠 공용 로더+병렬+가드) · M-7 · 리뷰 원문 Minor m-1~m-5 · `PlanCheckStore` 제거 여부(동기에서는 이미 제외, 읽는 화면 없음).
  - **보류(근거 있음):** M-8 주기 reconcile(watch에 onError·재구독이 없어 주기 동기가 타 기기 변경 수신의 안전망 — HANDOFF §1) · m-6 에셋 디렉터리 등록(원본 mp3·enrich 산출물이 같은 디렉터리라 로컬 빌드에 섞임).

- [x] **⑦ Associate 5종 콘텐츠 1차 — DEA 도메인 1 · SOA 가이드 v1.1·문항 300 · SAA/SOA 학습문서 사실 정정** — 2026-10-19 **#135~#140 develop 머지 → PR#142로 main 릴리스·라이브 배포 완료**(`68ab263`). 자세한 경위·가드·남은 일은 [HANDOFF.md](HANDOFF.md) §0-2026-10-19.
  - **#135 DEA-C01 도메인 1**: 학습문서 4개(`dea-t1-1`~`t1-4`) + 문항 드래프트 61개 + `dea_questions_test.dart` 가드 + `content_index`·`pubspec` 등록(questionCount 0). 조사 노트 정본은 `docs/content-research/`.
  - **#136 SOA-C03**: 공식 시험 가이드를 **v1.1로 동기화**(스킬 10건 문구 교체 + `soa_guide_v11_test.dart` 재발 방지) + **20개 엔트리 전부 문항 드래프트 300개**(`soa_questions_test.dart` 전수 가드).
  - **#137·#138·#139 SAA 학습문서 사실 정정 68건**(Task 1.1 5건 · 1.2·1.3 15건 · 2.1~4.4 48건) — `[오류]`·`[구식]`·`[부정확]`만 공식 문서로 전건 재확인, 근거 미확보 하위 주장은 쓰지 않고 PR 본문에 기록. 가드 3종(`saa_t1_facts_test`·`saa_t12_t13_facts_test`·`saa_t2_t4_facts_test`).
  - **#140 SOA 학습문서 사실 4건 정정** — Flow Logs REJECT 의미(공식 `action` 정의) · KMS 키 정책의 IAM 위임 · ACM 내보내기 가능 인증서 유료 · Trusted Advisor 현행 플랜(Business Support+·Enterprise·Unified Operations) + ElastiCache 3엔진·DynamoDB MREC/MRSC. 덤으로 학습문서 8개 끝의 작성 artifact(`</content>`·`</invoke>` 10줄) 제거·재발 가드.
  - **라이브 노출 불변식 유지:** SOA 300 + DEA 61 문항은 전부 `verified:false`이고 `content_index` questionCount는 0 — 사이트 노출·문항 수 변화 0. flip은 사람 검수 전용.
  - **남은 일:** SOA·DEA 문항 사람 검수→flip · DEA 도메인 2~4 · SAA/SOA 갭 노트의 다른 분류(`[누락]`·`[부분]`·`[의심]`) · DVA는 2026-10-27 C03 가이드 공개 후 전환 · MLA는 C01 기준 + C02 델타 부록.

---

## C. 백로그 (TODOS.md / phase3-handoff) — **게이트 해제(2026-09-03, 사용자 결정: CLF 시험은 다른 일정으로 미응시 → 시험 결과와 무관하게 진행)**. 아래 🔒 표기는 이력 보존용이며 더 이상 착수 조건이 아니다.

- [ ] 🔒 **Phase 3 — 비-CLF 콘텐츠 생산** _(게이트: 본인 CLF 합격 후)_ — 학습 루프 엔진(E1~E6)은 자격증 일반이라 콘텐츠만 채우면 즉시 노출. 복제 레시피·부트스트랩 체크리스트는 [phase3-content-handoff.md](docs/plans/2026-06-07-phase3-content-handoff.md). SAA는 학습문서 24개 라이브 + 문항 360 드래프트 상태(B-①이 SAA 문항 게이트).
- [ ] 🔒 **외부 검증자 블라인드 테스트** _(게이트: CLF 콘텐츠 완성 + 본인 합격)_ — 외부 학습자 2~3명이 이 사이트만으로 학습→응시, 후기 수집(첫 마케팅 자산). 근거: [TODOS.md](TODOS.md).
- [ ] 🔒 **유입 채널 실행** _(게이트: CLF 완성 + 본인 합격)_ — 한국어 검색 키워드 최적화·커뮤니티 공유(OKKY/커리어리/AWSKRUG)·README 랜딩 중 최소 1개. CLF 1개일 때 홍보 시 "준비 중 11개"가 첫인상이라 완성 후. 근거: [TODOS.md](TODOS.md).
- [ ] 🔒 **자격증별 문항 데이터 코드 스플리팅** _(게이트: 3번째 자격증 콘텐츠 추가 시점)_ — 콘텐츠 레지스트리를 dynamic import로 전환. ⚠️ TODOS의 경로 `src/content/index.ts`는 Flutter 이전 Vite 경로 — 현재는 `lib/data/content_index.dart`(경로 갱신 필요). 근거: [TODOS.md](TODOS.md).

---

## D. 선택 항목 (작음 — HANDOFF.md §0-b)

- [ ] **2기기 pull 검증** — 두 번째 기기/브라우저에서 같은 계정 로그인 시 첫 기기 데이터가 내려오는지(push·병합은 검증됨, pull 실기기만 남음).
- [ ] **콘솔 Firestore 규칙 대조** — Firebase 콘솔에 배포된 실제 규칙을 레포 `firestore.rules`와 맞추기(**사용자 작업** — 콘솔 접근 필요). 레포 쪽은 에뮬레이터 테스트·`firestore-rules` 워크플로가 검증한다. 출처: sync v2 PR3 "남은 것".

- [ ] **개인정보 고지** — Google 로그인 라이브 ↔ "무계정·무추적" 정체성 관계 정리(간단 고지 문구).
- [ ] 🔒 **FCM 푸시 알림(Phase 2)** _(보류)_ — [2026-06-10-firebase-fcm-feasibility.md](docs/plans/2026-06-10-firebase-fcm-feasibility.md).

---

## E. 정리 / 부채

- [x] **TODOS.md stale 정리** — 완료 2건(C-중량·wrongSkills)은 2026-07-02에 제거됨. 코드 스플리팅 항목 경로도 `lib/data/content_index.dart`로 갱신(2026-09-03).
- [x] **`.semgrep/` 인증 캐시 무시** — 플러그인이 레포 루트에 생성하는 `.semgrep/guardian.yml`(토큰성 파일) `.gitignore` 등재(2026-09-03 완료).
- [x] **임시 워크트리 잔재 삭제** — `D:\workspace\awc-before`(전/후 측정용) 부재 실측·종료(2026-10-19). git 등록은 그 전에 prune 완료. 출처: HANDOFF §3.

---

## F. 최근 완료 (참조 — TODOS.md에 stale로 남아있던 항목)

- [x] **C-중량: 개념→학습문서 섹션 앵커 딥링크** — Phase 1·2 모두 **main 릴리스 완료**(Phase1 PR#15·#19 · Phase2 PR#21→PR#29 릴리스, 2026-06-19 라이브). _※ TODOS.md엔 아직 "대기"로 표기 — §E에서 정리 대상._ 출처: HANDOFF §0-r.
- [x] **AttemptRecord.wrongSkills[] 비정규화** — C-중량 Phase 2에 포함 구현(`WrongSkill` 모델 + `buildWrongSkills` + `buildConceptReport`). _※ TODOS.md엔 아직 "대기"로 표기 — §E에서 정리 대상._
- [x] **CLF 문항 밀도 ≥15 심화** — 19 Task 12→15 verified(+57). main 배포. 출처: HANDOFF §0-q.
- [x] **SAA-C03 문항 드래프트 360개** — 전 도메인 `verified:false` 완비, **main 릴리스됨(PR#29, 화면변화 0)**. 검수→flip은 B-①. 출처: HANDOFF §0.
- [x] **시각 리펙토링 B안(PR1~4)** — 스플래시·테마·모션·Variable woff2·AppHeader·페이지 분해. main 배포. 출처: HANDOFF §0-u~0-x.
- [x] **학습 루프 엔진 E1~E6 + Spec 1/2** — 오답노트·약점리포트·진행률·약점 가중 모의고사·통합 모의고사. 과거 plans(`2026-06-06`·`-07`)에 스냅샷, 전부 main 배포·흡수됨.
