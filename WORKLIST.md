# WORKLIST — 통합 작업 목록

_생성: 2026-06-19 · HANDOFF.md(상세 이력·아키텍처)·TODOS.md(백로그)·멀티 일정 플랜에 흩어진 작업을 한곳에 통합한 단일 현황표._

🔗 라이브: https://velkaressiablutkrone.github.io/aws-docs/

> **이 문서의 역할:** "지금 무엇이 남았나"의 단일 진입점. 각 작업의 *경위·아키텍처·교훈*은 [HANDOFF.md](HANDOFF.md)에, *백로그 근거*는 [TODOS.md](TODOS.md)에 그대로 있다(이 문서가 그것들을 대체하지 않고 인덱싱한다).

**범례:** `[ ]` 미착수 · `[~]` 진행 중 · `[x]` 완료(반영 확인) · 🔒 게이트(선행조건 충족 전 착수 금지)

---

## A. 진행 중 (즉시)

- [~] **멀티 일정 학습 스케줄** — 자격증당 여러 독립 일정(자동/수동·목록·선택·삭제) + 일정별 진행
  - **상태(2026-06-19 실측): develop 머지됨(PR#30 `83d1fe7`), main 릴리스 대기.** 8 Task + spec/plan이 develop에 온전 반영(`origin/develop..feat/multi-plan-schedule` 빈 출력).
  - **남은 일:** develop→main 릴리스 + 라이브 dogfood → [Phase 1 릴리스 plan](docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md).
  - 출처: spec [2026-06-19-multi-plan-study-schedule-spec.md](docs/designs/2026-06-19-multi-plan-study-schedule-spec.md) · plan [Part1 데이터](docs/plans/2026-06-19-multi-plan-schedule-part1-data.md)(Task 1~4) · [Part2 UI](docs/plans/2026-06-19-multi-plan-schedule-part2-ui.md)(Task 5~8)

---

## B. 다음 (우선순위순 — HANDOFF.md §0)

- [ ] **① SAA-C03 문항 사람 검수 → `verified:true` flip** — 전 도메인 360개 `verified:false` 드래프트 완비(PR#22~25 develop 머지됨). 도메인/Task 순으로 검수·보완 후 flip + `content_index`의 해당 Task `questionCount`를 실제 수로 동기화.
  - 함정: `verified=사람 검수만`(AI flip 금지). verified true 1개라도 생기면 모의고사·약점 루프 자동 활성(코드 변경 0). 워크플로 → HANDOFF §0, 메모리 `question-bank-verified-workflow`.
- [~] **② develop → main 릴리스** — **C-중량 Phase2(PR#21)·SAA 드래프트(PR#22~25)는 PR#29로 이미 main 릴리스됨**(2026-06-19, `origin/main 2343260`, 라이브). **남은 릴리스 = 멀티 일정만**(§A) — 절차는 [Phase 1 릴리스 plan](docs/superpowers/plans/2026-06-19-phase1-develop-main-release.md). CI는 main push 시 Pages 자동 배포.
- [ ] **③ 학습문서 섹션 앵커 점진 채움** — C-중량 딥링크는 `clf-t1-1`만 `{#id}` 시드, 나머지는 graceful 폴백(문서 최상단). 나머지 문서·문항의 앵커를 점진 보강. 출처: HANDOFF §0-r.

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
