# HANDOFF — 다음 세션 이관

_작성: 2026-06-09 · 다음 작업자(사람 또는 새 세션)가 이 문서만 읽고 이어받을 수 있도록._

---

## 0. 지금까지 (전부 라이브)

🔗 https://velkaressiablutkrone.github.io/aws-docs/

| 영역 | 상태 | 근거 |
|---|---|---|
| **처방 허브 (A+C-경량)** | ✅ 라이브 | 시험 결과화면 → 복습/약점모의고사/리포트 1탭 + 오답 개념 라벨→학습문서 |
| **CLF 문항 밀도 (B)** | ✅ 19 Task × **12 verified = 228문항** | D1~D4 전 도메인 진단 유의미 밀도 |
| **학습문서 정합** | ✅ 9개 문서 보강 | 새 문항이 도입한 개념을 문서에도 추가(처방 링크가 빈 문서로 안 떨어지게) |

주요 커밋(main): `f6da516`(처방 허브 머지) · `5690f14`(D3) · `d9f87bf`(D1·D2·D4) · `8c2c57e`(학습문서 보강).
설계 문서: `~/.gstack/projects/VelkaressiaBlutkrone-aws-docs/G-main-design-20260609-113031.md`

---

## 1. 검증된 워크플로 (그대로 재사용)

**콘텐츠 밀도 루프** — 정직함 원칙: `verified:true`는 **사람이 공식 문서와 대조 검수한 것만** (AI 자동 verified 금지).

1. AI가 각 Task **학습문서(`t*.md`) 근거 + 공식 출처**로 `verified:false` 초안 작성 → `*.questions.json`에 삽입.
   - `QuestionBank.fromJson`이 verified만 노출하므로 초안은 시험에 안 뜸 → **안전, 무해**.
   - 삽입은 Python 문자열 삽입(`\n  ]` 앞)으로 **+N만 깔끔한 diff**. 전체 재포맷 금지.
2. 초안을 **단일 리뷰 파일**(`C:\workspace\clf-*_for_review.json` 등)로 추출 → 본인이 공식 문서 대조 검수 → `verified:true`.
3. 검수본을 각 파일에 반영 + `lib/data/content_index.dart`의 해당 Task `questionCount` 갱신(배지·로드 가드의 단일 진실).
4. `flutter test` + 커밋 + (원하면) `git push`(→ GitHub Pages 자동 배포).

**철칙 — 문항·문서 정합:** 새 개념을 문항에 넣으면 **학습문서(`t*.md`)에도 보강**해야 한다. 안 그러면 "오답 → 이 개념 틀림 → 학습문서" 처방이 *그 개념이 없는 문서*로 떨어진다. (이번 세션이 그래서 9개 문서를 보강함.)

스키마: `id`/`examGuideTaskId`/`skill`/`difficulty`/`stem`/`options[4]`/`correct`/`explanation`/`wrongExplanations{정답 아닌 인덱스→text}`/`sources[{title,url}]`/`verified`.

---

## 2. 다음 수 3개

### ① ≥15 심화 (문항 밀도 12 → 15)  ← **추천 1순위**
- **What:** CLF 각 Task를 12→15 verified로 (+3씩, 19 Task = **+57문항**).
- **Why:** 실전 65문항 모의고사가 매 회차 더 다양해지고, 약점 진단 표본이 두꺼워져 신뢰도↑.
- **How:** §1 워크플로 그대로. 각 Task의 *아직 안 다룬 각도* 3개씩(기존 12문항 skill/정답 덤프로 중복 회피).
- **파일:** `flutter_app/assets/content/clf/t*.questions.json`, `content_index.dart`(questionCount 12→15), 보강 필요 시 `t*.md`.
- **주의:** `question_model_test`의 `≥12` 가드는 통과(15면). 새 서비스 개념은 학습문서에도 보강.
- **Effort:** 큼(콘텐츠 노동). **Dep:** 본인 검수 시간. **Risk:** 낮음(엔진·문서 정합 이미 됨, 문항만 추가).

### ② SAA-C03 착수 (현재 문항 0)
- **What:** SAA-C03은 학습문서만 있고 **문항 0**(`content_index`의 saa-* 전부 `questionCount: 0` → "준비 중" 게이트). 첫 검증 문항 세트 작성.
- **Why:** 두 번째 자격증 — "포맷이 통한다"는 증명 확장. (원 설계 쐐기: CLF 완성 후 SAA.)
- **현황:** `assets/content/saa/saa-t1-1.md`…(학습문서 존재). **별개 주의:** 과거 `saaQuestions`(구 325문항, Vite 시절)가 있었는지/현 구조와 정합되는지 먼저 확인.
- **How:** SAA 학습문서 기반 Task당 검증 문항 작성(§1 루프). `content_index` questionCount 0→N + `certHasVerifiedQuestions('SAA-C03')` true 전환.
- **주의:** `content_index_test`의 SAA 단언(`certContentSummary('SAA-C03').questions == 0`, hasQuestions 전부 false)을 **갱신**해야 함. 게이트(questionCount>0, hasQuestions, 모의고사 시작 버튼)가 SAA에 켜지는지 확인.
- **Effort:** 매우 큼(신규 자격증). **Dep:** SAA 학습 진도.

### ③ C-중량 (개념 → 학습문서 *섹션* 앵커 딥링크)
- **What:** 처방 링크를 Task 문서가 아니라 **그 개념 문단으로 점프**. ⓐ `report_page` Task→개념 중첩 개조 ⓑ `study_doc_page` 마크다운 앵커/스크롤 인프라(현재 없음) ⓒ `concept_step_map.dart`(개념→stepId).
- **Why:** 지금 개념 라벨은 Task 문서로만 보냄(스크롤은 사용자 몫). 앵커면 "이 개념 → 정확히 그 문단".
- **현황:** `TODOS.md`에 대기(P3). 짝 작업: `AttemptRecord.wrongSkills[]` 비정규화(다회차 개념 추세).
- **How:** 설계 문서의 "C-중량" 섹션 + `TODOS.md` 참조. **A+C-경량 사용 관찰로 가치(스크롤 마찰) 증명 후 착수** 권장.
- **Effort:** 큼(파서·라우트·스크롤). **Risk:** 가치 증명 전 인프라 선건축 주의(Codex도 연기 동의함).

---

## 3. 잊지 말 것 (제약·아키텍처)

- **verified = 사람 검수만.** AI가 `verified:true` 직접 박지 말 것.
- **시각/UI는 `DESIGN.md` 먼저.** 반마케팅 에디토리얼, 액센트(verified 틸 `#0E8175`) 드물게, 3단 CTA·그라데이션 금지.
- **처방 루프(이미 구현):** `report_page`(약점 리포트) · `wrong_answer_index`(오답노트 졸업) · `weighted_exam`(약점 집중 모의고사). 결과화면 진입점 = `ExamView.resultsActionsBuilder(ctx, justFinished)` 빌더(잠금 stale 방지).
- **Support 플랜 표기:** 시험 대비는 전통 분류(Basic·Developer·Business·Enterprise), 현 명칭은 **Business(현 Business Support+)** 병기로 통일됨.
- **워킹트리:** `flutter_app/pubspec.lock`이 미커밋으로 남아 있음(테스트 중 `flutter pub get`의 의존성 범프, 무해 — 되돌리려면 `git checkout`).
- **검증:** 변경 후 항상 `cd flutter_app && flutter analyze lib && flutter test`.

**추천 다음 1수: ①(≥15 심화).** 리스크 최저, 즉시 가치. ②는 큰 신규 착수, ③은 가치 증명 후.
