# WORKLIST — 통합 작업 목록

_생성: 2026-06-19 · HANDOFF.md(상세 이력·아키텍처)·TODOS.md(백로그)·멀티 일정 플랜에 흩어진 작업을 한곳에 통합한 단일 현황표._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

> **이 문서의 역할:** "지금 무엇이 남았나"의 단일 진입점. 각 작업의 *경위·아키텍처·교훈*은 [HANDOFF.md](HANDOFF.md)에, *백로그 근거*는 [TODOS.md](TODOS.md)에 그대로 있다(이 문서가 그것들을 대체하지 않고 인덱싱한다).

**범례:** `[ ]` 미착수 · `[~]` 진행 중 · `[x]` 완료(반영 확인) · 🔒 게이트(선행조건 충족 전 착수 금지)

---

## A. 진행 중 (즉시)

- [x] **멀티 일정 학습 스케줄** — 자격증당 여러 독립 일정(자동/수동·목록·선택·삭제) + 일정별 진행
  - **상태(2026-06-20 완료): main 릴리스됨(PR#31 `89e2795`), 라이브 dogfood 통과.** develop test 651 그린·analyze 신규 0 → develop→main(PR#31) → Pages 배포 → 라이브 4페이지 콘솔 에러 0(plan "학습 일정" 빈 상태 정상 렌더).
  - 릴리스 절차: [Phase 1 릴리스 plan](docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md).
  - 출처: spec [2026-06-19-multi-plan-study-schedule-spec.md](docs/designs/2026-06-19-multi-plan-study-schedule-spec.md) · plan [Part1 데이터](docs/plans/2026-06-19-multi-plan-schedule-part1-data.md)(Task 1~4) · [Part2 UI](docs/plans/2026-06-19-multi-plan-schedule-part2-ui.md)(Task 5~8)

---

## B. 다음 (우선순위순 — HANDOFF.md §0)

- [~] **① SAA-C03 문항 사람 검수 → `verified:true` flip** — 재검토 인프라 **T1~T8 완료·PR#47 릴리스**(saa_prescreen 도구·content_index 동적 불변식·통합시험 균형 게이트·freeze 가드·문서 스캔/수정·검수 루브릭·전360 의미+출처 prescreen). **첫 flip 6/24 Task**(suspect7+t3-4 출처, PR#46): 90문항 verified. **나머지 18 draft.** 검수·flip은 사용자(AI flip 금지) — D1 포함 전 도메인 flip 시 통합 모의고사 자동 노출(T4). 도구 `saa_review.mjs flip <taskId>`, 루브릭 [review-rubric.md](docs/saa-review/review-rubric.md), prescreen [docs/saa-review/](docs/saa-review/).
  - 함정: `verified=사람 검수만`(AI flip 금지). verified true 1개라도 생기면 모의고사·약점 루프 자동 활성(코드 변경 0). 워크플로 → HANDOFF §0, 메모리 `question-bank-verified-workflow`.
  - **실행 플랜(잠금 2026-06-20, `/plan-eng-review`+codex 합의):** [2-pass 재검토 플랜](docs/superpowers/plans/2026-06-20-saa-rereview-plan.md) — 전수 360문항+24문서, AI 읽기전용 사전심사→사람 flip. 핵심 보강: 공개 게이트(`questionCount>0`→전 도메인 균형 세트), `content_index_test` 동적 불변식(첫 flip 회귀 차단), 문서 오류 스캔 문항 flip 선행. 착수=릴리스 후.
  - **검수 freeze 정책(T8 · 전체 SAA · 규약+가드):** 검수 발효~전 도메인 flip 완료까지 SAA 콘텐츠(`flutter_app/assets/content/saa/*.{md,questions.json}`) 동결. **허용**=검수 구동 변경만(수정루프·T6 문서수정·flip·읽기전용 사전심사 산출물). **금지**=신규/무관 SAA 편집·대량 리포맷. **가드**=`.githooks/pre-commit`(발효 중 `saa-review*`/`review/saa*` 밖에서 SAA 콘텐츠 커밋 차단). 설치 1회 `git config core.hooksPath .githooks`; 발효 `touch .saa-frozen` / 해제 `rm .saa-frozen`(현재 dormant). 도구·테스트·플랜은 비대상. 우회 `--no-verify`(권장 안 함).
- [x] **② develop → main 릴리스** — **완료(최신 2026-06-20 PR#47 `00528f9`).** 이력: 멀티 일정 PR#31 · CLF 섹션 앵커 PR#37 `a68ae14` · **SAA 재검토 인프라(T1~T8)+T6 문서 정확성 수정+첫 flip 6 Task PR#47**(679 test·analyze 신규0·build web·배포 그린·라이브 200+로더 확인; SAA 통합시험은 D1 미flip이라 게이트 숨김 유지). develop=main 동기.
- [x] **③ 학습문서 섹션 앵커 점진 채움(CLF)** — **구현 완료·PR#34 develop 머지**(merge `58a1463`, 2026-06-20). CLF 18 Task(clf-t1-2~t4-3) 헤딩 `{#slug}` + 문항 `section` 사람 매핑 편집 + Dart **존재** 가드(`f1f3679`). spec·plan: [spec](docs/superpowers/specs/2026-06-20-section-anchors-design.md)·[plan](docs/superpowers/plans/2026-06-20-section-anchors.md). ⚠️ 가드는 *앵커 존재*만 보장 — *올바른 섹션* 의미 매핑은 사람 검토 권장. SAA 앵커는 B-① 검수·flip 후 별도. **main 릴리스 완료**(PR#37 `a68ae14`, 2026-06-20 라이브). 출처: HANDOFF §0-r.

---

## C. 백로그 (게이트 있음 — TODOS.md / phase3-handoff)

- [ ] 🔒 **Phase 3 — 비-CLF 콘텐츠 생산** _(게이트: 본인 CLF 합격 후)_ — 학습 루프 엔진(E1~E6)은 자격증 일반이라 콘텐츠만 채우면 즉시 노출. 복제 레시피·부트스트랩 체크리스트는 [phase3-content-handoff.md](docs/plans/2026-06-07-phase3-content-handoff.md). SAA는 학습문서 24개 라이브 + 문항 360 드래프트 상태(B-①이 SAA 문항 게이트).
- [ ] 🔒 **외부 검증자 블라인드 테스트** _(게이트: CLF 콘텐츠 완성 + 본인 합격)_ — 외부 학습자 2~3명이 이 사이트만으로 학습→응시, 후기 수집(첫 마케팅 자산). 근거: [TODOS.md](TODOS.md).
- [ ] 🔒 **유입 채널 실행** _(게이트: CLF 완성 + 본인 합격)_ — 한국어 검색 키워드 최적화·커뮤니티 공유(OKKY/커리어리/AWSKRUG)·README 랜딩 중 최소 1개. CLF 1개일 때 홍보 시 "준비 중 11개"가 첫인상이라 완성 후. 근거: [TODOS.md](TODOS.md).
- [ ] 🔒 **자격증별 문항 데이터 코드 스플리팅** _(게이트: 3번째 자격증 콘텐츠 추가 시점)_ — 콘텐츠 레지스트리를 dynamic import로 전환. ⚠️ TODOS의 경로 `src/content/index.ts`는 Flutter 이전 Vite 경로 — 현재는 `lib/data/content_index.dart`(경로 갱신 필요). 근거: [TODOS.md](TODOS.md).

---

## D. 선택 항목 (작음 — HANDOFF.md §0-b)

- [ ] **2기기 pull 검증** — 두 번째 기기/브라우저에서 같은 계정 로그인 시 첫 기기 데이터가 내려오는지(push·병합은 검증됨, pull 실기기만 남음).
- [ ] **개인정보 고지** — Google 로그인 라이브 ↔ "무계정·무추적" 정체성 관계 정리(간단 고지 문구).
- [ ] 🔒 **FCM 푸시 알림(Phase 2)** _(보류)_ — [2026-06-10-firebase-fcm-feasibility.md](docs/plans/2026-06-10-firebase-fcm-feasibility.md).

---

## E. 정리 / 부채

- [ ] **TODOS.md stale 정리** — 완료된 2건이 "대기"로 남아 있음(아래 §F 참조). 제거 또는 완료 표시 + 코드 스플리팅 항목 경로 갱신.
- [ ] **임시 워크트리 잔재 삭제** — `D:\workspace\awc-before`(전/후 측정용)가 파일 잠금으로 미삭제. 탐색기 수동 삭제(git 등록은 prune 완료). 출처: HANDOFF §3.

---

## F. 최근 완료 (참조 — TODOS.md에 stale로 남아있던 항목)

- [x] **C-중량: 개념→학습문서 섹션 앵커 딥링크** — Phase 1·2 모두 **main 릴리스 완료**(Phase1 PR#15·#19 · Phase2 PR#21→PR#29 릴리스, 2026-06-19 라이브). _※ TODOS.md엔 아직 "대기"로 표기 — §E에서 정리 대상._ 출처: HANDOFF §0-r.
- [x] **AttemptRecord.wrongSkills[] 비정규화** — C-중량 Phase 2에 포함 구현(`WrongSkill` 모델 + `buildWrongSkills` + `buildConceptReport`). _※ TODOS.md엔 아직 "대기"로 표기 — §E에서 정리 대상._
- [x] **CLF 문항 밀도 ≥15 심화** — 19 Task 12→15 verified(+57). main 배포. 출처: HANDOFF §0-q.
- [x] **SAA-C03 문항 드래프트 360개** — 전 도메인 `verified:false` 완비, **main 릴리스됨(PR#29, 화면변화 0)**. 검수→flip은 B-①. 출처: HANDOFF §0.
- [x] **시각 리펙토링 B안(PR1~4)** — 스플래시·테마·모션·Variable woff2·AppHeader·페이지 분해. main 배포. 출처: HANDOFF §0-u~0-x.
- [x] **학습 루프 엔진 E1~E6 + Spec 1/2** — 오답노트·약점리포트·진행률·약점 가중 모의고사·통합 모의고사. 과거 plans(`2026-06-06`·`-07`)에 스냅샷, 전부 main 배포·흡수됨.
