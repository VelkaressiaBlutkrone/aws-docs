# WORKLIST — 통합 작업 목록

_생성: 2026-06-19 · 갱신: 2026-10-29(SAA·MLA 트랙 완료 표시 + SOA·DEA 검수 트랙 §B⑫ 신설 — HANDOFF §0-2026-10-29) · 그 앞은 2026-10-27(이탤릭 트랙 §B⑪ 신설 + §B⑦에 readiness 정책 반영 — HANDOFF §0-2026-10-27) · 그 앞은 2026-10-27(MLA-C01 트랙 §B⑩ 신설 — 콘텐츠 완주·1차 검수 반영·첫 flip `mla-t2-2`) · 그 앞은 2026-10-21(SAA 갭 배치 B8 완결·B9a·명칭 일관성 — HANDOFF §0-2026-10-21-b) · 그 앞은 2026-10-21(SAA 갭 배치 B3·B5·B6·B7 — HANDOFF §0-2026-10-21) · 그 앞은 2026-10-21(갭 배치 행 매핑 재도출 — §B⑨가 [97-gap-batch-map.md](docs/content-research/SAA-C03/97-gap-batch-map.md)를 가리키도록) · HANDOFF.md(상세 이력·아키텍처)·TODOS.md(백로그)·멀티 일정 플랜에 흩어진 작업을 한곳에 통합한 단일 현황표._

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

- [x] **① SAA-C03 문항 사람 검수 → `verified:true` flip** — ✅ **완료(2026-10-29): 24 Task 360문항 전부 `verified` · 통합·약점 모의고사 게이트 개방.** 2026-10-27 외부 2차 검수 보고의 전 절 처리(#258~#270) + 전 Task flip(#267·#272) → 릴리스 #260·#265·#269·#271·#273. 정답 인덱스가 바뀐 것은 273문항 중 **1건**(`saa-t2-3-q4`, 사용자 승인)이다. 경위·교훈의 정본은 [HANDOFF.md](HANDOFF.md) §0-2026-10-29. **아래는 이력이다.** 재검토 인프라 **T1~T8 완료·PR#47 릴리스**(saa_prescreen 도구·content_index 동적 불변식·통합시험 균형 게이트·freeze 가드·문서 스캔/수정·검수 루브릭·전360 의미+출처 prescreen). **첫 flip 6/24 Task**(suspect7+t3-4 출처, PR#46): 90문항 verified. **나머지 18 draft.** 검수·flip은 사용자(AI flip 금지) — 통합/약점 모의고사는 아래 weighted capacity 충족 시 노출. 도구 `review.mjs flip saa <taskId>`, 루브릭 [review-rubric.md](docs/saa-review/review-rubric.md), prescreen [docs/saa-review/](docs/saa-review/).
  - 함정: `verified=사람 검수만`(AI flip 금지). verified flip이 생기면 학습문서/문항 수는 자동 반영되지만, 통합·약점 모의고사는 아래 도메인별 weighted capacity를 채울 때까지 잠김. 워크플로 → HANDOFF §0, 메모리 `question-bank-verified-workflow`.
  - **실행 플랜(잠금 2026-06-20, `/plan-eng-review`+codex 합의):** [2-pass 재검토 플랜](docs/superpowers/plans/2026-06-20-saa-rereview-plan.md) — 전수 360문항+24문서, AI 읽기전용 사전심사→사람 flip. 핵심 보강: 공개 게이트(`questionCount>0`→전 도메인 균형 세트), `content_index_test` 동적 불변식(첫 flip 회귀 차단), 문서 오류 스캔 문항 flip 선행. 착수=릴리스 후.
  - **다음 시험 구성 게이트(2026-08-06):** 통합/약점 모의고사는 공식 도메인 비중을 앱의 65문항 연습 세트에 적용할 수 있을 만큼 도메인별 검증 문항이 있어야 열린다. SAA-C03 기준 필요/현재 = D1 19/0 · D2 17/15 · D3 16/45 · D4 13/30 → 현재 잠김. 다음 사람 검수 batch의 공개 목표는 **D1 최소 19문항 + D2 최소 2문항 추가 verified** 확보. 부분 통과 규칙: 이미 필요 수량을 넘긴 도메인(D3/D4)은 공개 게이트 관점에서 pass로 두고, 부족 도메인만 계속 검수한다. 추천 batch: [2026-08-06-weighted-ready-batch.md](docs/saa-review/2026-08-06-weighted-ready-batch.md). 단, `verified:true` flip은 계속 사람만 수행한다.
  - **검수 freeze 정책(T8 · 전체 SAA · 규약+가드):** 검수 발효~전 도메인 flip 완료까지 SAA 콘텐츠(`flutter_app/assets/content/saa/*.{md,questions.json}`) 동결. **허용**=검수 구동 변경만(수정루프·T6 문서수정·flip·읽기전용 사전심사 산출물). **금지**=신규/무관 SAA 편집·대량 리포맷. **가드**=`.githooks/pre-commit`(발효 중 `saa-review*`/`review/saa*` 밖에서 SAA 콘텐츠 커밋 차단). 설치 1회 `git config core.hooksPath .githooks`; 발효 `touch .saa-frozen` / 해제 `rm .saa-frozen`(현재 dormant). 도구·테스트·플랜은 비대상. 우회 `--no-verify`(권장 안 함).
- [~] **② develop → main 릴리스** — 릴리스마다 반복되는 **상시 항목**이다. **미릴리스 여부는 여기 적지 않는다**(HANDOFF §0 서술 규약 ②) — `git log --oneline origin/main..develop`(비어 있으면 미릴리스 0)과 `gh pr list --state open`으로 조회한다. 기준선 수치의 정본은 [CLAUDE.md](CLAUDE.md) 빌드·테스트 절이다.
  - **릴리스 절차 주의:** `develop` push에는 CI가 돌지 않으므로(ci.yml은 `pull_request` 트리거) 통합 상태는 **릴리스 PR의 `test` 체크**로 확인한다. 같은 파일을 건드린 PR이 둘 이상 열려 있으면 머지 전에 **로컬에서 순차 머지를 시험**한다(§B⑧ 교훈). 앞 PR 머지 **직후**의 연속 머지는 GitHub 판정 지연으로 실패하니, `gh pr view <n> --json mergeable,mergeStateStatus`가 `MERGEABLE/CLEAN`이 된 뒤 다시 실행한다 — 이 레포는 `--auto` 예약이 거부된다(Allow auto-merge 꺼짐). **타이밍 문제를 아예 없애는 한 줄**(체크가 끝날 때까지 기다리고 성공일 때만 머지):
    ```sh
    gh pr checks <n> --watch --fail-fast --repo VelkaressiaBlutkrone/aws-docs && gh pr merge <n> --merge --repo VelkaressiaBlutkrone/aws-docs
    ```
    2026-10-20에 머지 시도가 네 번 막혔는데(`has merge conflicts` 2회 · `not mergeable` 1회 · `base branch policy prohibits the merge` 1회) **전부 필수 체크 pending 또는 base 이동 직후의 재계산 지연**이었다. `--admin`은 CI 게이트를 건너뛰므로 쓰지 않는다.
  - **콘텐츠 릴리스 PR#142**(`68ab263`, Pages run 39230610259 build·deploy success) — 머지 9건(#133·#134 + #135~#141)을 한 번에 출고. 라이브 검증: index 200 · DEA 신규 문서 200 · 정정된 SAA/SOA 본문 반영 · `exam_guides/SOA-C03.json` `guideVersion 1.1`.
  - **부기 릴리스 2건**(루트 현황 문서만 담은 릴리스) — PR#144(`b12cd10`, Pages success) · PR#146(`de20ee0`, Pages run 39239830730 success). 부기 문서 PR가 그것을 릴리스하는 PR을 다시 부르는 순환이라, 2026-10-20부터 현황을 번호가 아닌 불변식으로 적는다(HANDOFF §0 서술 규약 ②).
  - **직전 릴리스 이력:** 2026-09-23 PR#132 `58154b7`(동기 v2 → §B⑤) · 2026-09-22 PR#127 `34b1cde`(앱 리뷰 반영 → §B④) · 2026-09-03 PR#121 `acfbeac`(강의 mp3 R2 분리) · 2026-09-03 PR#118(run 33717705582 success, 라이브 SAA mp3 206·미승인 t4-2 404 실측 — weighted capacity 게이트 PR#113·시험 게이트 해제 PR#114·SAA 오디오 PR#115·#116 포함) · 2026-07-03 PR#110·#112(감사 Phase A+AR) · 2026-06-20 PR#47 `00528f9`(SAA 재검토 인프라 T1~T8 + 첫 flip 6 Task) · 2026-06-20 PR#37 `a68ae14`(CLF 섹션 앵커) · 2026-06-20 PR#31 `89e2795`(멀티 일정).
- [x] **③ 학습문서 섹션 앵커 점진 채움(CLF)** — **구현 완료·PR#34 develop 머지**(merge `58a1463`, 2026-06-20). CLF 18 Task(clf-t1-2~t4-3) 헤딩 `{#slug}` + 문항 `section` 사람 매핑 편집 + Dart **존재** 가드(`f1f3679`). spec·plan: [spec](docs/superpowers/specs/2026-06-20-section-anchors-design.md)·[plan](docs/superpowers/plans/2026-06-20-section-anchors.md). ⚠️ 가드는 *앵커 존재*만 보장 — *올바른 섹션* 의미 매핑은 사람 검토 권장. SAA 앵커는 B-① 검수·flip 후 별도. **main 릴리스 완료**(PR#37 `a68ae14`, 2026-06-20 라이브). 출처: HANDOFF §0-r.

- [x] **④ 2026-09-22 앱 코드·UX 리뷰 반영** — 외부 리뷰(🔴2·🟡10·🟢6·🎨5)를 코드 대조·재현 프로브·공식 문서로 전건 검증한 뒤 **PR#122~#126 develop 머지 → PR#127 `34b1cde` main 릴리스·Pages success**(2026-09-22). 내용: 동기 lost-update 경합(C-1·`CODE-D-004` 상향)·초기화 부활 임시 조치(C-2)·합격선 하드코딩 700 제거(M-1)·PR 게이트 CI 신설+Flutter 3.47.2 고정(M-5)·손상 이력 덮어쓰기 방지(M-3). **ANS-C01 합격선 750 정정은 반려 — 공식 가이드가 700이라 앱 데이터가 옳다.** 설정: develop·main 브랜치 보호에 `CI / test` 필수 체크 등록. 원문+검증 부록 [2026-09-22-app-code-ux-review.md](docs/audits/2026-09-22-app-code-ux-review.md), 잔여는 §B⑥. 메모리 [[app-review-2026-09-22]].

- [x] **⑤ 동기 프로토콜 v2 — 삭제 표식·일정/진행 3-way·보안 규칙** — 리뷰 C-2의 근본 해결이 설계 선행을 요구해 [spec](docs/superpowers/specs/2026-09-23-sync-protocol-v2-design.md)을 먼저 쓰고, **PR#128(설계)·#129(PR1 삭제 표식)·#130(PR2 일정·진행 3-way, 일정 개별 삭제 전파)·#131(PR3 레거시 LWW·옛 사이드카 제거·관용 파싱·`firestore.rules`) develop 머지 → PR#132 `58154b7` main 릴리스·Pages success**(2026-09-23). 초기화가 모든 기기·클라우드에서 실제로 지워지고, 일정·일정 진행이 집합 3-way로 병합된다. 동기 대상은 응시·열람 기록 + 일정(v2)·일정 진행이며 진행 중 시험 세션은 로컬 전용(비범위). 보안 규칙은 레포(`firestore.rules`+`firebase.json`)가 관리하고 에뮬레이터 테스트(`tool/firestore_rules_test`)·`firestore-rules` 워크플로가 검증한다 — **콘솔 배포 규칙 대조는 사용자 몫(§D)**. 기준선: 테스트 **892 그린**·analyze **0건**(2026-10-17 실측). 메모리 [[sync-protocol-v2]].

- [ ] **⑥ 2026-09-22 리뷰 후속 잔여** — 정본은 [리뷰 §V-4 "남은 일"](docs/audits/2026-09-22-app-code-ux-review.md)과 [sync v2 PR3 "남은 것"](docs/superpowers/plans/2026-09-23-sync-protocol-v2-pr3.md), 백로그 상세는 [TODOS.md](TODOS.md).
  - ✅ **출고됨:** QuizView `_finish`·오답노트 `_onFinished`의 try/finally + 저장 실패 사용자 알림(PR-m11)은 `c8540b8`로 들어갔다 — **"바로 가능" 분류는 이제 비어 있고, ⑥에 남은 것은 아래 디자인·후순위·보류뿐이다**(2026-10-24 실측 정정).
  - **디자인 결정 필요:** M-6 대비 토큰(DESIGN.md 정렬 선행) · UX-1·2(시험 러너 모바일) · UX-4(진행 중 세션 "이어서 풀기" 진입점) · M-10/UX-5(결과 화면).
  - **후순위:** M-4(콘텐츠 공용 로더+병렬+가드) · M-7 · 리뷰 원문 Minor m-1~m-5 · `PlanCheckStore` 제거 여부(동기에서는 이미 제외, 읽는 화면 없음).
  - **보류(근거 있음):** M-8 주기 reconcile(watch에 onError·재구독이 없어 주기 동기가 타 기기 변경 수신의 안전망 — HANDOFF §1) · m-6 에셋 디렉터리 등록(원본 mp3·enrich 산출물이 같은 디렉터리라 로컬 빌드에 섞임).

- [x] **⑦ Associate 5종 콘텐츠 1차 — DEA 도메인 1 · SOA 가이드 v1.1·문항 300 · SAA/SOA 학습문서 사실 정정** — 2026-10-19 **#135~#140 develop 머지 → PR#142로 main 릴리스·라이브 배포 완료**(`68ab263`). 자세한 경위·가드·남은 일은 [HANDOFF.md](HANDOFF.md) §0-2026-10-19.
  - **#135 DEA-C01 도메인 1**: 학습문서 4개(`dea-t1-1`~`t1-4`) + 문항 드래프트 61개 + `dea_questions_test.dart` 가드 + `content_index`·`pubspec` 등록(questionCount 0). 조사 노트 정본은 `docs/content-research/`.
  - **#136 SOA-C03**: 공식 시험 가이드를 **v1.1로 동기화**(스킬 10건 문구 교체 + `soa_guide_v11_test.dart` 재발 방지) + **20개 엔트리 전부 문항 드래프트 300개**(`soa_questions_test.dart` 전수 가드).
  - **#137·#138·#139 SAA 학습문서 사실 정정 68건**(Task 1.1 5건 · 1.2·1.3 15건 · 2.1~4.4 48건) — `[오류]`·`[구식]`·`[부정확]`만 공식 문서로 전건 재확인, 근거 미확보 하위 주장은 쓰지 않고 PR 본문에 기록. 가드 3종(`saa_t1_facts_test`·`saa_t12_t13_facts_test`·`saa_t2_t4_facts_test`).
  - **#140 SOA 학습문서 사실 4건 정정** — Flow Logs REJECT 의미(공식 `action` 정의) · KMS 키 정책의 IAM 위임 · ACM 내보내기 가능 인증서 유료 · Trusted Advisor 현행 플랜(Business Support+·Enterprise·Unified Operations) + ElastiCache 3엔진·DynamoDB MREC/MRSC. 덤으로 학습문서 8개 끝의 작성 artifact(`</content>`·`</invoke>` 10줄) 제거·재발 가드.
  - **라이브 노출 불변식 유지:** SOA 300 + DEA 61 문항은 전부 `verified:false`이고 `content_index` questionCount는 0 — 사이트 노출·문항 수 변화 0. flip은 사람 검수 전용.
  - **남은 일:** SOA·DEA 문항 사람 검수→flip(**현황·착수 정본은 §B⑫**. **게이트 정책은 #254로 들어갔다** — 그전까지는 `kExamReadinessRequirements`에 두 자격증이 없어 전 문항을 flip해도 fail closed로 잠긴 채였다) · SAA/SOA 갭 노트의 다른 분류(`[누락]`·`[부분]`·`[의심]`) · DVA는 2026-10-27 C03 가이드 공개 후 전환 · MLA는 C01 기준 + C02 델타 부록. **DEA-C01은 도메인 1~4 전부 완료 · SOA v1.1 신규 주제 13항목 반영 완료**(§B⑧).

- [x] **⑧ SAA 검수 문서 외부 리뷰 검증 + SAA 문항 fix 5건 + DEA 도메인 2·3·4 완주 + SOA v1.1** — 2026-10-20, **전부 main 릴리스·Pages success·라이브 실측 완료**(#153·#157·#161·#163). 경위·교훈 정본은 [HANDOFF.md](HANDOFF.md) §0-2026-10-20.
  - **게이트 정의 확정 + 옛 게이트 제거:** 라이브 게이트는 `certExamHasWeightedCapacity`(lib 5곳)이고, 루브릭이 공개 조건으로 적고 있던 `certExamIsBalanced`는 **lib 호출 0 = dead code**였다. 루브릭 §1·§4를 "Task 단위 flip + 도메인별 weighted capacity"로 개정(#149)하고, **그 함수·테스트를 제거**했다(커버리지 손실 없음을 weighted capacity 테스트로 확인, 테스트 6건 감소).
  - **외부 리뷰 중 반영하지 않은 것:** 상단 인용문 "문장 잘림" 2건(실제로는 완결) · prescreen "경로 통일"(서로 다른 산출물이라 둘 다 기재가 맞음).
  - **문항 fix 5건(정답 변경 0):** `saa-t1-1-q13` STS 엔드포인트 · `saa-t1-4-q4`·`q12` WAF 보호 대상 9종(리뷰가 빠뜨린 Bedrock AgentCore Gateway 포함) · `saa-t1-4-q10` 관리형 교체(해설 + **정답 선택지 본문**) · `saa-t2-5-q8` Aurora 복제본 vs RDS 복제본. Test-First 가드 `test/saa_question_facts_test.dart` 20건(13건 RED → 20건 GREEN).
  - **DEA 도메인 2·3·4(#148·#151·#155):** 학습문서 13편 + 드래프트 195문항 → **DEA 누계 학습문서 17편·드래프트 256문항(도메인 1~4 전부)**, 전부 `verified:false`·questionCount 0(라이브 노출 변화 0). 도메인별 세션 위임 + 컨트롤러 PR 실물 검증. `pubspec.yaml`은 디렉터리 등록이라 무변경이 정답.
  - **⚠️ 교훈:** 같은 파일을 건드리는 병렬 PR은 GitHub이 각각 `CLEAN`으로 표시해도 **순차 머지 시 both-added 충돌**이 난다(로컬 시험 머지로만 드러남). 또 앞 PR 머지 직후의 연속 머지는 mergeability 재계산 지연으로 실패하며, **이 레포는 `--auto` 예약이 거부되므로**(Allow auto-merge 꺼짐) `MERGEABLE/CLEAN` 확인 후 재실행한다. 애초에 같은 레지스트리 파일을 건드리는 콘텐츠 작업은 **병렬로 돌리지 않는 것**이 정답이다.
  - **SOA-C03 v1.1 신규 주제(#159):** 공식 Revisions Skill 변경 10건 + in-scope 추가 5건을 갭 노트 §4로 필터한 **13항목을 학습문서 10편**에 반영 + `soa_v11_topics_test.dart` 가드 35건. **기존 문서 본문 수정이라 라이브에 노출된다**(DEA 작업과 달리 신규 문서 추가가 아님). `soa_facts_test`의 `lastVerified`는 문서별 날짜 맵으로 강화.
  - **다음(사람 몫):** `saa-t1-1`·`saa-t1-4`·`saa-t2-5` 재검수 → flip. 열리면 D1 30/19·D2 30/17이지만 그 시점 D1에 **공식 Task 1.3이 0문항**이라 `saa-t1-5`가 1순위 보강 batch다.

- [~] **⑨ SAA 검수 2차 트랙 — md→문항 전파 감사 + 영구 가드 + 갭 배치** — 2026-10-20, #164~#168 + 부기 #169가 **PR#170으로 main 릴리스·Pages success·라이브 실측 완료**(main `3fd4b7d`). 경위·교훈·운영 규칙 정본은 [HANDOFF.md](HANDOFF.md) §0-2026-10-20. **열린 항목은 갭 배치뿐** — 행 단위 배정의 정본은 [97-gap-batch-map.md](docs/content-research/SAA-C03/97-gap-batch-map.md)다(134행 전수 → B1~B11 · 겹치는 문서가 있어 **순차로만** · **B11은 사람 flip 이후**). 어느 배치까지 들어왔는지는 `git log --oneline --grep="갭 배치" origin/main..develop`과 `gh pr list --state merged --search "갭 배치"`로 확인한다(여기에 진행 상태를 적지 않는다 — §0 서술 규약 ②). 배치 저작의 경위·교훈(가드 설계 순서 ①~④와 그 반대 사례·맵 상세 표가 원본 행을 대체하는 규칙·공식이 통념과 달랐던 항목)은 [HANDOFF.md](HANDOFF.md) §0-2026-10-21이 정본이고, **B8 완결·B9a·명칭 일관성은 §0-2026-10-21-b**다(공식이 통념과 달랐던 12건 표·가드 설계의 반대 방향 3건·2단 머지 체인이 끊기는 조건 포함).
  - **핵심 발견:** 2026-10-19 md 사실 정정이 **파생 문항에 전파되지 않았다.** md 가드의 금지 문장을 문항 전수와 대조해 **7건**을 찾았고 그중 `saa-t4-2`는 **이미 flip돼 라이브 노출 중**이었다. 신설 가드 `flutter_app/test/saa_question_propagation_test.dart`가 같은 계열을 막는다 — **md 가드에 금지 문장을 추가하면 이 목록에도 추가**해야 한다.
  - **문항 수정 누계(2차 트랙):** t1-5 fix 6·출처 11 · 전파 7건(fix 5 + 전제 보강 2) · Aurora 명칭 5건 · Snow 전제 1건. **정답 인덱스 변경은 전 구간 0건**이고 `verified` flip은 하지 않았다(사람 전용).
  - **갭 배치:** SAA `[누락]` 50 + `[부분]` 84 = **134행**을 B1~B11에 **전수 배정**했다(미배정 0) — 정본 [97-gap-batch-map.md](docs/content-research/SAA-C03/97-gap-batch-map.md). 2026-10-20 서술의 배치 행수(4+32+63+13=112)는 같은 문단의 "실질 열림 129행"과 **17행 어긋나고** 제외 5행의 번호도 기록되지 않아, 2026-10-21에 공식 Task 경계로 **재도출**했다. **배치는 순차로만** — 겹치는 문서가 7쌍 있어 병렬은 both-added 충돌을 낸다. 부분 제약 16항목은 `99-gaps.md` V 목록 때문에 수치·단정 금지.
  - **SOA:** §3 Skill 커버리지에서 「없음」 **6개**만 배치 대상(「부분」 45는 커버리지 등급이라 제외 — 올리면 20편 전면 재집필).
  - **라이브 노출된 변경:** `saa-t1-5.md`(#164) · 문항 `saa-t4-2`·`t3-5`·`t4-3`(flip된 Task, #165·#166) · md 3편 보강(#168). 나머지는 드래프트라 노출 0.

- [x] **⑩ MLA-C01 문항 사람 검수 → `verified:true` flip** — ✅ **완료(2026-10-29): 12 Task 321문항 전부 `verified` · 통합·약점 모의고사 게이트 개방**(flip 선결 #274 + flip #275 → 릴리스 #276. 게이트 D1 69/18 · D2 78/17 · D3 74/14 · D4 100/16). 경위·교훈의 정본은 [HANDOFF.md](HANDOFF.md) §0-2026-10-29. **아래는 이력이다.** 콘텐츠는 **공식 Task 12개(4도메인 × 3) 전부 완료·라이브**다: 학습문서 **12편** · 문항 **321**(배치 #224·#230·#234·#240 + 외부 리뷰 반영 #225~#228·#232·#236 + 포맷 3종 #238, 릴리스 #231·#233·#235·**#242**). 경위·레시피·가드의 정본은 [HANDOFF.md](HANDOFF.md) §0-2026-10-26과 [2026-10-26-mla-content-review.md](docs/audits/2026-10-26-mla-content-review.md)다(같은 지적이 3회 반복·3회 기각된 항목이 있으니 그 문서의 ④·⑤를 먼저 읽는다). **열린 항목은 사람 flip뿐** — 검수·flip은 사용자 전용(AI flip 금지)이고, 도구는 `cd flutter_app && node tool/review.mjs build mla` → `flip mla <taskId>`로 `verified`·`content_index` questionCount·`mla_questions_test.dart`의 `flipApprovedTaskIds`를 함께 갱신한다(#247).
  - **1차 검수(2026-10-27) 반영 완료:** 외부 검수 **307 pass·정답 오류 0** 중 수정 14건(사실 오류 4·해설 보강 2·작성자 메모 7·출처 교체 1)은 #250, 출처 재확인 19건은 #251에서 닫았다. 재확인 기록의 정본은 [2026-10-27-mla-source-recheck.md](docs/saa-review/2026-10-27-mla-source-recheck.md) — 루브릭이 요구하는 **flip 직전 재확인은 그 표를 여는 것으로 갈음**하고, 문서 끝 "다시 확인해야 하는 조건" 3가지에 걸리는 항목만 다시 연다. ⭐ 가용성 날짜의 정본은 개발자 가이드가 아니라 **제품 features 페이지의 End of Support Notice**다(dg의 `*-availability-change.html`은 날짜를 적지 않는다). 신설 가드: `mla_questions_test.dart`의 **M2 — 문항 본문에 작성 과정 메모 0건**.
  - **첫 flip(2026-10-27):** `mla-t2-2` **28문항** verified(#252). 나머지 11 Task는 드래프트다. 도메인별 보유량의 정본은 `content_index.dart`의 questionCount이고 게이트 충족 여부는 `content_index_test.dart`의 MLA 가중 게이트 케이스가 단정한다(여기에 진행 수치를 더 적지 않는다 — §0 서술 규약 ②).
  - **게이트:** 필요 수량은 321이 아니라 **65**다(공식 비중을 앱의 연습 65문항에 배분) → **D1 18 · D2 17 · D3 14 · D4 16**. flip 단위가 Task라 **도메인당 1 Task**면 열리고, t2-2로 D2가 충족됐으니 **남은 건 D1·D3·D4 각 1 Task**다. ⚠️ **정책이 없는 자격증은 `hasPolicy:false → ready:false`로 fail closed** — MLA는 #246에서 정책을 넣고 "MLA 문항은 전부 드래프트"라는 단정 2곳을 걷어내야 비로소 첫 flip이 가능했다(그 단정이 첫 flip에서 테스트를 깨뜨리게 돼 있었다). SOA·DEA는 **아직 정책이 없다**(§B⑦의 남은 일).
  - **Task 고를 때:** 1차 검수가 **같은 사실 묶음 7건**을 flip 후 교체 후보로 남겼다. t2-2가 flip된 지금 **D3는 어느 Task를 골라도 쌍이 노출되고**(t3-1-q12·t3-3-q18 ↔ t2-2-q23), t4-2는 t2-2-q10과 쌍 + 내부 중복(q15·q17)까지 있다 — **D1은 `t1-2`, D4는 `t4-1`이 깨끗**하다(t1-1은 q7·q19가 내부 중복). 품질로는 검수 보고가 `mla-t3-3`(수정 0건)을 다음으로 권한다.
  - ⚠️ **freeze 가드는 MLA에 없다:** `.githooks/pre-commit`은 `flutter_app/assets/content/saa/**`만 보고 마커도 `.saa-frozen` 하나뿐인데, 레포에 그 마커가 없고 `core.hooksPath`도 미설정이라 **현재 아무 자격증도 동결돼 있지 않다**(2026-10-27 실측). MLA에 같은 동결을 둘지는 미결정.

- [~] **⑪ 레포 전역 평문 표기 — 단일 `*이탤릭*` 잔여** — 앱의 마크다운 파서는 `**굵게**`와 코드 스팬만 렌더하고 단일 `*이탤릭*`은 **별표를 글자로 노출**한다. 링크 표기(`[텍스트](링크)`)는 전 자격증 **0건**이 됐고 [content_format_test.dart](flutter_app/test/content_format_test.dart)가 `.md` 전수를 고정한다. 이탤릭은 **clf·mla가 0건**이 되어 그 둘만 집계 가드 `italicCleanCerts`에 들어가 있다 — 한 자격증을 비울 때마다 그 집합에 추가해 전역으로 좁힌다. 경위·교훈은 [HANDOFF.md](HANDOFF.md) §0-2026-10-27이 정본이다.
  - **남은 양:** **saa 192 · soa 145 · dea 194**(코드 스팬 제외 정밀 계수, 2026-10-27 실측). ⚠️ 가드 레시피 기준 숫자는 다르다 — [CLAUDE.md](CLAUDE.md)에는 saa 194 · soa 144 · dea 194로 적혀 있고, CLF도 레시피 762 vs 정밀 726이었다(차이는 `**굵게**` 안쪽·경계의 이탤릭).
  - **판단 기준(CLF에서 확립, #255):** ① 강조가 의미 있으면 `**굵게**`로 올린다 ② **문장급 괄호 주석**(`*(…)*`)은 강조가 아니라 톤 표시이므로 **별표만 지운다** — 굵게로 올리면 문서가 굵은 글씨로 뒤덮인다 ③ 용어 첫 등장·영문 병기는 그 문서의 다른 곳과 일관되게 맞춘다.
  - **자격증별 성격:** 괄호 주석 비중이 **saa 162/192 · soa 134/145**로 높아 대부분 ②로 끝나지만, **dea는 3/194**라 ①·③ 판단이 거의 전부다 — dea가 가장 손이 많이 간다.
  - ⚠️ **측정 함정:** 이 환경의 `grep -P`는 `-P supports only unibyte and UTF-8 locales`로 **실패**한다. 0건이 나오면 믿지 말고 별표 총수 − `**` 쌍으로 대조하거나 node로 센다(코드 스팬을 자리표시자로 가린 뒤).
  - **라이브 영향:** saa·soa·dea 학습문서는 모두 라이브라 본문이 바뀐다. 자격증 하나당 PR 하나로 끊어 간다(겹치는 파일이 없어 병렬도 가능하지만 `CLAUDE.md` 기준선 줄이 겹치므로 **순차가 안전**하다 — §0-2026-10-27 교훈 3).

- [ ] **⑫ SOA-C03 · DEA-C01 문항 사람 검수 → `verified:true` flip** — SAA·MLA가 전 문항 공개로 끝나(§B①·§B⑩) **남은 드래프트는 SOA 300 · DEA 256뿐**이다. 둘 다 `verified` 0이라 사이트 문항 노출이 0이고(학습문서 37편은 이미 라이브), readiness 정책은 #254로 이미 들어가 있다. **착수 노트 정본은 [2026-10-29-soa-dea-review-prep.md](docs/saa-review/2026-10-29-soa-dea-review-prep.md)** — 게이트 산술·flip 선결 단정·표본 문제·준비 작업이 전부 거기 있다.
  - **게이트:** SOA는 도메인이 **5개**(필요 D1 14 · D2 14 · D3 14 · D4 11 · D5 12)이고 Task가 각 15문항이라 **도메인당 1 Task = 5 Task 75문항**이면 열린다. DEA는 필요 D1 22 · D2 17 · D3 14 · D4 12이라 **D1·D2는 2 Task씩 → 6 Task 91문항**이다. ⚠️ **부분 flip은 개방이 아니다** — Task 하나만 flip하면 약점 모의고사 줄이 **잠긴 채로 노출**되고 통합은 "준비 중"으로 남는다.
  - ⚠️ **flip 선결 — 먼저 바꿔야 하는 단정이 4건 있다.** `content_index_test.dart`의 `'SOA-C03·DEA-C01: 정책 추가 후에도 현재는 locked'`는 **flip 명령 자신의 검증 경로**에 있다(`review.mjs`의 `cmdFlip`이 끝에 `content_index_test`를 돌린다) — 2026-10-28에 같은 구조의 SAA 선언이 `flip saa saa-t2-5`를 **파일을 다 쓴 뒤** 레드로 끝냈다. DEA 개방 시에는 `cert_exam_restore`·`home_sections`·`weighted_exam`이 추가로 깨진다. **순서는 ① 선언 변경 → ② 사람 flip → ③ 커밋**이고 `--force`는 소용없다.
  - ⚠️ **DEA가 지금 테스트의 "잠긴 cert" 표본**이다(SAA → MLA → DEA로 두 번 이사). DEA까지 열면 콘텐츠 있는 5종이 전부 개방돼 **옮길 cert가 없다** — **SOA를 먼저, DEA를 마지막에** 열고 그 PR에서 표본을 구조적으로 푼다(선례 = `cert_detail_sections_test`의 합성 엔트리. 정책 없는 cert로는 대체 불가 — `domainProgressLabel`이 빈 문자열이 된다).
  - **AI가 바로 할 수 있는 준비:** 루브릭 자격증 확장(제목이 아직 `SAA-C03 · MLA-C01`) · flip 선결 선언 정리 + 표본 해소 · **출처 URL 전수 실측**(가드는 `http` 시작만 본다 — MLA 도메인 3에서 23건, SAA에서 죽은 링크 6문항이 실제 오류였다) · 전파 가드 SOA·DEA 판 신설(SAA 판만 있다) · `saa_prescreen.mjs` 자격증 일반형 · 이탤릭 평문화(§B⑪). 상세는 착수 노트 §6.
  - **검수·flip은 사람 전용(AI flip 금지).** 도구는 `cd flutter_app && node tool/review.mjs build soa`(→ `build/SOA-C03_review/index.html`) → `flip soa <taskId>`. ⚠️ `flipAllowlist`는 MLA에만 있어 SOA·DEA에는 "허용 목록 밖의 `verified:true`를 막는" 가드가 없다. 워크플로 메모리 `question-bank-verified-workflow`.

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
