# C-중량: 개념→학습문서 섹션 앵커 딥링크 — 설계 스펙

_작성: 2026-06-18 · 브레인스토밍 승인 후. TODOS.md "C-중량" 항목 + "AttemptRecord.wrongSkills[] 비정규화" 항목을 함께 구현._

## 0. 배경 / 문제

오답 복기(quiz/exam 결과)의 개념 큐(`_ConceptCue`, `quiz_widgets.dart`)는 현재 "학습문서 →" 링크가 `/cert/{code}/study/{taskId}`로 **문서 최상단**에 떨어뜨린다. 사용자가 해당 개념 문단을 찾으려면 스크롤해야 한다(C-경량까지가 깐 동선). 목표: "이 개념 → 바로 그 섹션"으로 정밀 처방.

report_page는 현재 Task 단위 정답률만 보여주고, 약점 Task는 학습문서 **최상단**으로만 보낸다(`report_page.dart:228`). 개념 단위 처방이 없다.

## 1. 확정된 설계 결정 (브레인스토밍)

| # | 결정 | 기각안 |
|---|---|---|
| 1 | **매핑 = 문항 JSON의 선택적 `section` 필드** (문항이 자기 학습문서의 앵커 id를 가리킴) | 중앙 `concept_step_map.dart`(이중 소스) · 휴리스틱 자동 매칭(추측 금지 위반) |
| 2 | **범위 = 전체** (딥링크 + report Task→개념 개조 + `wrongSkills[]` 비정규화) | 딥링크만(thin) |
| 3 | **앵커 = 명시 `{#id}`** (학습문서 제목에 `## … {#id}`) | 제목 슬러그 자동생성(텍스트 드리프트 깨짐) · 위치 인덱스(불투명·재정렬 취약) |

### 1.1 정직성 정정 (범위 의존성)
report 개조는 `wrongSkills[]` 비정규화에 **반드시 의존하지 않는다.** `report_page._load()`는 이미 `wrongQuestionIds → QuestionBank → taskId` **라이브 조인**을 한다(`report_page.dart:50-66`). 같은 조인으로 `(skill, section)`도 얻는다. 비정규화의 **고유 가치는 개정·삭제된 stale 문항의 개념 보존** 뿐이다(TODO 본래 근거). 따라서 report는 **"비정규화 우선 → 없으면 라이브 조인 폴백"** 통합 소스로 설계해 레거시 레코드도 자연 처리한다.

`skill` 값은 거의 고유한 자유 텍스트다(CLF ~285 distinct, 각 1회). 문서 섹션(문서당 5~8개)과 1:1 자동 대응 불가 → 수기 `section` 지정이 유일한 정직한 길(결정 1).

## 2. 단계 (PR 분할 — 각 독립 출고)

### Phase 1 — 딥링크 코어 (end-to-end)
브랜치 `feat/concept-deeplink` → develop PR.

### Phase 2 — report 개조 + 비정규화
브랜치 `feat/concept-report` → develop PR. Phase 1 출고·검증 후 착수.

각 Phase는 `flutter test` 그린 + `flutter analyze` 신규 0건 게이트 통과 후 머지.

## 3. 컴포넌트 설계

### 3.1 마크다운 앵커 파싱 (Phase 1)
**파일:** `lib/content/markdown_parser.dart`, `lib/models/study_content.dart`

- `MdHeading`에 `final String? anchor` 추가.
- 제목 파싱 시 끝의 `{#id}`를 추출: 정규식 `RegExp(r'\s*\{#([a-z0-9][a-z0-9-]*)\}\s*$')`. 매치되면 `anchor`=id, 표시 텍스트에서 `{#id}` 제거. 미매치면 `anchor=null`, 텍스트 그대로(`{#...}`가 형식 안 맞으면 리터럴로 표시).
- 파서는 기존 계약대로 **절대 throw 안 함**.
- 적용 대상: H1~H3 모두(`^(#{1,3})` 그룹). H3 하위 개념(예: `### 2) 클라우드의 핵심 이점 {#core-benefits}`)이 주요 딥링크 타깃.

**테스트(`markdown_parser_test`):**
- `## 핵심 {#core}` → anchor=`core`, text=`핵심`.
- `## 핵심` → anchor=null.
- `## 핵심 {# bad id}` → anchor=null, text 원본 유지(공백·대문자 불허).
- `### 1) 이점 {#benefits}` (이모지/괄호 혼합) → anchor=`benefits`, text에 `{#benefits}` 없음.

### 3.2 문항 `section` 필드 (Phase 1)
**파일:** `lib/models/question.dart`

- `final String section`(기본 `''`) 추가. `fromJson`: `(j['section'] ?? '').toString()`.
- **`withOptionOrder`가 section을 운반**(새 Question 생성 시 `section: section` 포함) — 셔플 시 유실 방지.

**테스트(`question_model_test`):**
- `fromJson`에 `section` 있으면 파싱, 없으면 `''`.
- `withOptionOrder` 후 `section` 보존.

### 3.3 섹션 스크롤 인프라 (Phase 1)
**파일:** `lib/pages/study_doc_page.dart`, `lib/content/study_markdown_view.dart`, 신규 `lib/content/anchor_scroll.dart`

- `StudyDocPage`에 `final String? targetAnchor` 추가(위젯 파라미터).
- `study_markdown_view.dart`: 앵커가 있는 제목 블록 렌더 시 `GlobalKey`를 부착하고, 부모가 준 `Map<String, GlobalKey> anchorKeys`에 등록(생성자 파라미터로 주입). 앵커 없는 제목은 키 없음.
- `StudyDocPage`: `ScrollController` 소유, `anchorKeys` 맵 생성·전달. 문서 로드 완료 + `targetAnchor != null` 이면 `addPostFrameCallback`에서 해당 키의 `RenderObject`로 스크롤.
- **순수 함수 `anchorScrollOffset`**(`anchor_scroll.dart`):
  ```
  double anchorScrollOffset({
    required double targetTopInScroll, // 타깃 위젯의 스크롤 좌표계 top
    required double headerInset,        // 글래스 헤더가 가리는 높이
    required double maxScrollExtent,
  }) => (targetTopInScroll - headerInset).clamp(0.0, maxScrollExtent);
  ```
  헤더 보정: 타깃이 글래스 헤더 **아래**에 오도록 `headerInset`(= `headerScrollInset` 계열 값)만큼 위로 당김.
- 스크롤 실행: `RenderObject` 미배치(null)면 skip. `MediaQuery.disableAnimationsOf(context)`면 `jumpTo`, 아니면 `animateTo`(200ms ease — PR2 모션 토큰 정합).
- 타깃 좌표 산출: 타깃 키의 `RenderBox`를 스크롤 뷰포트의 `RenderBox` 기준으로 `localToGlobal`해 상대 top + `controller.offset` → `targetTopInScroll`.

**SelectionArea 위젯테스트 함정(메모리 [[flutter-selectionarea-widget-test-pitfall]]):** StudyDocPage는 SelectionArea+비동기라 위젯테스트에서 "RenderBox was not laid out" 위험. 따라서 **스크롤 로직 검증은 순수 함수 `anchorScrollOffset` 단위 테스트로** 하고, 전체 페이지 스크롤 위젯테스트는 시도하지 않는다.

**테스트(`anchor_scroll_test`):**
- 정상: `target=500, inset=56, max=2000` → `444`.
- 음수 클램프: `target=20, inset=56` → `0`.
- 상한 클램프: `target=3000, max=2000` → `2000`.

### 3.4 라우트 쿼리 파라미터 (Phase 1)
**파일:** `lib/app_router.dart`

- `study/:taskId` 빌더: `state.uri.queryParameters['at']`을 읽어 `StudyDocPage(targetAnchor: at, entry: ...)`. 빈/없음 → null.
- URL 형식: `/cert/{code}/study/{taskId}?at={anchor}`. (해시 라우팅에서 go_router `state.uri.queryParameters` 정상 동작.)
- redirect 가드는 기존대로 entry 존재만 검사(앵커 유효성은 검사 안 함 — 미발견은 graceful no-op).

### 3.5 개념 큐 딥링크 배선 (Phase 1)
**파일:** `lib/content/quiz_widgets.dart`, `lib/pages/cert_exam_page.dart`, `lib/pages/exam_page.dart`

- `onOpenStudy` 시그니처: `void Function(String taskId)` → **`void Function(String taskId, String section)`**.
- `_ConceptCue` 호출부(`quiz_widgets.dart:262`): `() => onOpenStudy!(q.examGuideTaskId, q.section)`.
- 호출 사이트(`cert_exam_page.dart:246`, `exam_page.dart:646`):
  ```
  onOpenStudy: (taskId, section) {
    final at = section.isEmpty ? '' : '?at=$section';
    context.push('/cert/${cert.code}/study/$taskId$at');
  }
  ```
  `exam_page.dart`는 위젯 파라미터 `onOpenStudy` 타입도 함께 갱신(`:45,77`).

**테스트(`concept_cue_url_test` 또는 헬퍼 단위 테스트):**
- URL 빌드 헬퍼 `studyDeepLink(code, taskId, section)`를 추출해 단위 테스트(section 있으면 `?at=`, 없으면 쿼리 없음). 위젯 펌프 대신 순수 문자열 검증.

### 3.6 콘텐츠 시드 (Phase 1)
**파일:** `flutter_app/assets/content/clf/t1-1.md`, `…/t1-1.questions.json`(정본)

- `t1-1.md`의 H2/H3 핵심 섹션에 `{#id}` 부여(영문 kebab id). 최소: `📖 핵심 개념` 하위 H3들 + `⚠️ 흔한 함정`.
- `t1-1.questions.json`의 해당 문항 일부에 `section` 채움 → 실제 딥링크 동작 dogfood.
- 나머지 문서·문항은 **점진 채움**(graceful 폴백 = 현행 최상단). 본 PR은 정본 1문서로 메커니즘 입증.

### 3.7 wrongSkills 비정규화 (Phase 2)
**파일:** `lib/models/attempt_record.dart`, 응시 제출부(`exam_page.dart`/`quiz_page.dart`의 record 생성 지점)

- 신규 값객체 `WrongSkill { String skill; String section; String taskId; }`(toJson/fromJson).
- `AttemptRecord`에 `final List<WrongSkill> wrongSkills`(기본 `const []`). toJson/fromJson 추가. **레거시 레코드 → 빈 리스트**(`presentedQuestionIds` 패턴 동일).
- 레코드 생성 시: 오답 문항만 순회해 `WrongSkill(skill: q.skill, section: q.section, taskId: q.examGuideTaskId)` 수집(정답·무태그 제외; skill 빈 문항은 스킵).

**테스트(`attempt_record_test`):**
- wrongSkills 직렬화 라운드트립.
- 레거시 JSON(필드 없음) → `wrongSkills == []`.
- 빌더: 오답만 포함, 정답 제외, skill 빈 문항 제외.

### 3.8 report 개조 (Phase 2)
**파일:** `lib/pages/report_page.dart`, 신규 `lib/data/concept_report.dart`(순수 집계)

- 순수 함수/모델 `ConceptReport.build(...)`: 약점 Task별로 미스 개념 목록을 집계. **소스 = 비정규화 우선**(`AttemptRecord.wrongSkills`) → 해당 레코드가 비었으면 `wrongQuestionIds`를 라이브 뱅크로 조인해 `(skill, section)` 도출(폴백). 동일 개념 중복 제거.
- `report_page` UI: 기존 Task 행을 확장형으로 — 약점 Task(`TaskStatus.weak`) 아래에 미스 개념 칩 리스트, 각 칩이 `?at=section` 딥링크(`section` 없는 개념은 라벨만, 링크는 문서 최상단).
- DESIGN.md 정합: 칩=중립색 라벨, 액센트=링크에만(2026-06-09 D3 규칙, `_ConceptCue`와 동일 패턴 재사용 검토).

**테스트(`concept_report_test`):**
- 비정규화 소스로 개념 그룹핑.
- 폴백: wrongSkills 빈 레코드 → 라이브 뱅크 조인으로 개념 도출.
- 중복 개념 dedup.
- 약점 아닌 Task는 개념 미노출.

## 4. 데이터 흐름

```
문항(skill, section) ──┐
                       ├─ 오답 큐(quiz/exam 결과) ─ push(study?at=section) ─┐
학습문서(## … {#id}) ──┘                                                   ├→ 섹션 스크롤(헤더 보정)
응시 제출 ─ wrongSkills[{skill,section,taskId}] ─ history ─ report(Task→개념) ─ push(study?at=section) ┘
```

## 5. 에러 처리 / graceful degrade
- `section` 없음 / `at` 없음 → 문서 최상단(현행 동작).
- 앵커 미발견(at가 어떤 `{#id}`와도 불일치) → 스크롤 no-op, 최상단 유지.
- `RenderObject` 미배치 → 스크롤 skip.
- 오프셋 `clamp[0, maxScrollExtent]`.
- reduced-motion → `jumpTo`(애니메이션 생략).
- 레거시 `wrongSkills=[]` → report 라이브 조인 폴백.
- 파서: 잘못된 `{#...}` → 리터럴 텍스트, throw 없음.

## 6. 테스트 / 게이트 (CLAUDE.md 절대조건 2 — Test-First)
신규/수정마다 실패 테스트 선작성. 게이트: `cd flutter_app && flutter test`(전부 그린) + `flutter analyze`(신규 0건, 기존 잔존 3건 외 금지). 웹 빌드는 PowerShell `--base-href /aws-docs/`(메모리 [[flutter-build-web-powershell]]). 실브라우저 dogfood로 딥링크 스크롤 1회 확인(메모리 [[flutter-web-dogfood-browse]] — taskId `clf-t1-1` 형식, 해시 goto≠리로드 주의).

## 7. 영향 파일 요약
**Phase 1:** `markdown_parser.dart`, `study_content.dart`, `question.dart`, `study_doc_page.dart`, `study_markdown_view.dart`, `anchor_scroll.dart`(신규), `app_router.dart`, `quiz_widgets.dart`, `cert_exam_page.dart`, `exam_page.dart`, `assets/content/clf/t1-1.md`, `t1-1.questions.json` + 테스트.
**Phase 2:** `attempt_record.dart`, 응시 제출부, `report_page.dart`, `concept_report.dart`(신규) + 테스트.

## 8. 비범위 (YAGNI)
- 전체 문서·문항 `section` 일괄 채움(점진 — 본 PR은 정본 t1-1 입증).
- SAA·SOA 등 비-CLF 콘텐츠 앵커링(콘텐츠 생산 트랙 별건).
- 본문 내 임의 문단(헤딩 아닌) 앵커링 — 섹션(헤딩) 단위로 한정.
- 앵커 유효성 라우트 가드(graceful no-op로 충분).
