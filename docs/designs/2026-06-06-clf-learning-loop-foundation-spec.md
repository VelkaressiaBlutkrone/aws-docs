---
status: DRAFT (사용자 검토 대기)
sub_project: "1/4 — 기반: 콘텐츠 렌더 + 퀴즈 코어 + 이력 저장"
parent_design: docs/designs/clf-learning-loop.md
created: 2026-06-06
generated_by: superpowers:brainstorming
---

# CLF 학습 루프 — 하위 프로젝트 #1 스펙 (기반)

## 0. 한 줄 목표

CLF-C02 상세 페이지에서 `공동 책임 모델`(clf-t2-1) **학습문서를 DESIGN.md대로 읽고 → 연습 문제 5개를 풀고 → 점수·오답해설을 보고 → 결과가 localStorage 이력에 남는다.** 18개 Task로 복제 가능한 구조로.

## 1. 배경 / 맥락

- 스택: **Flutter Web 3.38.9 / Dart 3.10.8**. 라이트 기본 + 다크, 토큰은 `app_theme.dart`(`context.c`/`Gap`/`Radii`/`Layout`).
- 콘텐츠 산출물은 이미 존재: `flutter_app/assets/content/clf/t2-1.md`(학습문서, YAML 프런트매터 + Markdown), `t2-1.questions.json`(검증 문항 5개, `verified:true`). pubspec에 `assets/content/clf/` 등록 완료.
- 현재 앱은 **그릇만**: 자격증 카드 → `CertDetailPage`(공식 가이드 JSON + 요약본 렌더). 학습문서/퀴즈 **렌더러는 없음.**
- 이 스펙은 풀 러닝 루프(E1~E6)의 **척추**다. E1~E6은 전부 여기서 만드는 퀴즈 엔진 + 이력 스키마 위에 얹힌다.

## 2. 범위

### 2.1 포함 (#1)
- 학습문서 렌더러: 우리 Markdown 하위집합 → 네이티브 위젯(자체 섹션 렌더러), DESIGN.md 준수.
- 문항 모델 + 로더(`t2-1.questions.json`).
- 퀴즈 실행: 문항 풀기 → 정답/오답해설 공개 → 최종 점수 + 문항별 리뷰.
- **이력 저장(D14 스키마)**: 제출 시 `{certId, examId, date, correct, total, wrongQuestionIds[], flaggedQuestionIds[], durationSpentSec}`를 localStorage에 기록.
- 진입 동선: `CertDetailPage`에 "학습 콘텐츠 · 검증 문항" 섹션 추가 → `StudyDocPage` → `QuizPage`.
- 검증: `flutter analyze` 무경고 · 단위 테스트(파서/문항 모델) · `flutter test` · `flutter build web` 성공.

### 2.2 제외 (→ 후속 하위 프로젝트)
- E3 타이머·자동제출·세션복원, E4 플래그 UI → #2
- E1 오답노트(틀린 문항 재응시), E2 약점 리포트 → #3
- E5 카드 진행률, E6 약점 가중 모의고사 → #4
- 단, 이력 스키마의 `wrongQuestionIds`·`durationSpentSec`는 **#1에서 기록**해 후속 기능이 바로 읽게 한다. `flaggedQuestionIds`는 빈 배열로 기록(스키마 자리만 확보).

### 2.3 비목표 (YAGNI)
- 라우터 패키지 도입 안 함(기존 `Navigator.push` 유지).
- 외부 Markdown/스토리지 패키지 도입 안 함(자체 렌더러 + `package:web`).
- 에셋 매니페스트 동적 스캔 안 함(정적 `content_index`).
- 다중 자격증/다중 Task 일괄 처리 안 함(인덱스에 1건; 구조만 복제 가능).

## 3. 아키텍처

### 3.1 새 파일 / 책임

| 파일 | 책임 | 의존 |
|---|---|---|
| `lib/models/study_content.dart` | `StudyContent`(메타 + `List<MdBlock>`), `StudySource`, `MdBlock` 계층 | — |
| `lib/content/markdown_parser.dart` | 우리 Markdown 하위집합 + YAML 프런트매터 → `StudyContent` | study_content |
| `lib/content/study_markdown_view.dart` | `List<MdBlock>` → 위젯(섹션 인식 스타일링) | study_content, theme |
| `lib/models/question.dart` | `Question`, `QuestionBank` + `fromJson` | — |
| `lib/data/content_index.dart` | (자격증 코드 → 콘텐츠 항목들) 정적 인덱스 | — |
| `lib/data/history_store.dart` | `AttemptRecord` 영속화(localStorage), 백엔드 주입식 | — |
| `lib/pages/study_doc_page.dart` | 학습문서 페이지(검수 메타 헤더 + 섹션 + CTA) | 위 전부 |
| `lib/pages/quiz_page.dart` | 퀴즈 실행 + 결과 + 이력 기록 | question, history_store |

**수정:** `lib/pages/cert_detail_page.dart` — "학습 콘텐츠 · 검증 문항" 섹션 추가(인덱스에 콘텐츠 있는 자격증만).

> **격리·테스트성 규칙:** 페이지는 **얇은 로더**(자산 `FutureBuilder`)이고, 실제 렌더는 **모델 주입식 view 위젯**이 한다 — 학습문서=`StudyMarkdownView(blocks)`, 퀴즈=`QuizView(bank)`. 위젯 테스트는 view에 파싱된 모델을 직접 주입해 `rootBundle` 의존을 피한다(§11).

### 3.2 데이터 흐름
```
CLF 카드(home) ─push─▶ CertDetailPage
   └─ (신규) 학습 콘텐츠 섹션  ── content_index[CLF-C02]
        └─push─▶ StudyDocPage(asset md 로드 → markdown_parser → study_markdown_view)
             └─ "연습 문제 풀기" ─push─▶ QuizPage(asset json 로드 → QuestionBank)
                  └─ 제출 ─▶ HistoryStore.add(AttemptRecord) ─▶ 결과 요약
```

## 4. 데이터 모델

### 4.1 StudyContent / MdBlock
```dart
class StudyContent {
  final String examGuideTaskId, certCode, title;
  final int domain;
  final int? domainWeightPct;
  final String? domainName, lastVerified;
  final List<String> coversTasks;
  final List<StudySource> sources;
  final List<MdBlock> blocks; // 본문(프런트매터 제외)
}
class StudySource { final String title, url; }
```
`MdBlock` 계층(렌더러가 분기):
- `MdHeading(level 1..3, text, emoji?)`
- `MdParagraph(List<MdSpan>)`
- `MdBullets(List<List<MdSpan>> items)` / `MdNumbered(...)`
- `MdChecklist(List<({bool checked, List<MdSpan> spans})>)`
- `MdTable(List<String> headers, List<List<String>> rows)`
- `MdQuote(List<MdSpan>)`
- `MdCode(String text)`
- `MdDetails(String summary, List<MdBlock> body)`
- `MdDivider()`

`MdSpan`: `{ text, bold, code, url? }` (인라인 `**bold**`, `` `code` ``, 원시 URL).

### 4.2 Question / QuestionBank (t2-1.questions.json와 1:1)
```dart
class QuestionBank { final String examGuideTaskId, taskTitle, certCode; final int domain; final List<Question> questions; }
class Question {
  final String id, examGuideTaskId, skill, difficulty, stem, explanation;
  final List<String> options;
  final int correct;                       // 0-base
  final Map<int,String> wrongExplanations; // 오답 인덱스 → 설명
  final List<StudySource> sources;
  final bool verified;
}
```
- `fromJson`은 `verified != true`인 문항을 **로드에서 제외**(DESIGN.md 브랜드 규칙: 비검증 비노출 — verified 게이트의 런타임 강제).

### 4.3 AttemptRecord (이력 스키마 = 설계 D14)
```dart
class AttemptRecord {
  final String certId;      // 'CLF-C02'
  final String examId;      // 연습: 'practice:clf-t2-1' / (후속) 모의고사 id
  final String mode;        // 'practice' | 'exam'  (D14 확장; 후속 호환용)
  final String date;        // ISO-8601
  final int correct, total;
  final List<String> wrongQuestionIds;
  final List<String> flaggedQuestionIds; // #1=빈 배열
  final int durationSpentSec;
}
```
- 저장 키: `awsdocs.history.v1` → `List<AttemptRecord>` JSON.
- `examId` 의미: 연습 모드는 `practice:<taskId>`. 후속 모의고사(E6)는 별도 id. `mode`로 구분.

## 5. Markdown 하위집합 명세 (파서 계약)

파서는 **우리가 작성하는** 문서만 지원한다. 지원 구문:
1. **YAML 프런트매터**: 파일 시작 `---` ~ `---`. 키: `examGuideTaskId, certCode, domain, domainName, domainWeightPct, title, coversTasks[], sources[{title,url}], lastVerified`. (간단한 키:값 + 2단계 리스트만. 범용 YAML 파서 아님 — 우리 스키마 전용 라인 파서.)
2. `# `→H1(제목, 헤더에서 사용하므로 본문 렌더 생략 가능), `## `→H2(섹션), `### `→H3.
3. `> `→인용/콜아웃(연속 줄 병합).
4. `- [ ]`/`- [x]`→체크리스트, `- `→불릿, `1. `→번호 목록.
5. 표: `| a | b |` + 구분선 `|---|---|`.
6. 펜스 코드: ```` ``` ```` ~ ```` ``` ````.
7. `<details><summary>요약</summary> … </details>`(자가 점검 토글; 내부 블록 재귀 파싱).
8. `---`(빈 줄 사이) → 수평선.
9. 인라인: `**bold**`, `` `code` ``, 원시 `https://` URL.
- **degrade 규칙:** 인식 못 한 줄은 `MdParagraph`로 폴백(절대 크래시 금지). 알 수 없는 인라인은 평문.
- 이 규칙은 18개 문서가 따라야 할 **작성 컨벤션**이며 스펙 부록(§10)에 체크리스트로 둔다.

## 6. 렌더링 명세 (DESIGN.md 매핑)

- 본문 폭 `Layout.measure`(720), 본문 17px/line-height 1.75(`bodyLarge`).
- **헤더(검수 메타, 브랜드 규칙):** 제목(`headlineMedium`) + Task/도메인 칩 + **`✓ 검증됨` 배지**(correct/correctWeak) + `최종 검수 {lastVerified}` + `출처 {n}` 칩. 펼치면 출처 목록.
- 섹션 인식 스타일(H2 이모지 선두로 판별):
  - `✅`(체크리스트) → 체크박스 불릿.
  - `🎯`(왜 중요한가) → **액센트 콜아웃**(accentWeak 배경 + 좌측 accent 바) = DESIGN.md `.why`.
  - `📖`(핵심 개념) → 기본; 내부 `###`·표·코드 정상 렌더.
  - `✍️`(시험 포인트) → 기본(보조 강조 info 허용).
  - `⚠️`(흔한 함정) → **warning 블록**(warningWeak 배경 + warning 마커).
  - `🧪`(자가 점검) → `MdDetails`를 **ExpansionTile**(요약=질문, 본문=정답 토글).
  - `📌`(출처) → 출처 리스트(Mono URL).
- 표 → 테두리 있는 위젯, 헤더 행 강조, 숫자 tabular.
- 코드 → Mono, surface2 배경, 가로 스크롤.
- 인용 → 좌측 border + surface2 콜아웃.
- 색은 **전부 `context.c` 토큰**(하드코딩 금지). 모션: 정답/오답 공개 페이드(150–250ms).

## 7. 로딩 / 인덱스

- `content_index.dart`: `Map<String, List<ContentEntry>>`. `ContentEntry{ taskId, title, domain, mdAsset, questionsAsset, questionCount }`. 현재: `'CLF-C02' → [clf-t2-1]`.
- 로드: `rootBundle.loadString(asset)` (기존 `cert_detail_page` 패턴 재사용). `FutureBuilder`로 로딩/에러 처리.

## 8. 이력 영속화

- `HistoryStore`는 백엔드 주입식: `HistoryBackend`(인터페이스) → `WebLocalStorageBackend`(`package:web`, `kIsWeb`) / `MemoryBackend`(테스트·비웹 폴백). 기본 팩토리가 `kIsWeb`로 선택.
- API: `List<AttemptRecord> all()`, `void add(AttemptRecord)`, (후속) `byCert/byTask`.
- 직렬화: `jsonEncode(list.map(toJson))`. 손상 데이터는 무시하고 빈 목록으로 시작(방어적).

## 9. 페이지 / 상태 / 흐름

### 9.1 CertDetailPage(수정)
- `content_index[cert.code]`가 있으면 요약본 아래·공식 가이드 위에 **"학습 콘텐츠 · 검증 문항"** 섹션. 각 항목 카드: Task 제목 + "검증 문항 N" 배지 + "학습문서 →". 탭 → `StudyDocPage`.
- 콘텐츠 없으면 섹션 미표시(빈 상태로 부담 주지 않음).

### 9.2 StudyDocPage
- `FutureBuilder`로 md 로드 → 파싱 → 헤더(검수 메타) + `study_markdown_view`. 하단 고정 CTA **"연습 문제 풀기 (N문항)"** → `QuizPage`.

### 9.3 QuizPage (핵심)
- 상태: `index`, `Map<int,int> picked`(문항→선택), `Set<int> revealed`, `DateTime startedAt`.
- 한 문항씩: stem + 보기(선택 카드). "확인" → 공개: 정답 보기(correctWeak), 내가 틀렸으면 내 선택(wrongWeak) + 해당 `wrongExplanations`, + `explanation`(accent `.why` 콜아웃). "다음".
- 마지막 후 **결과**: 점수(correct/total, %), 문항별 정/오 리스트(stem + 내 답/정답 + 해설 재표시), `wrongQuestionIds` 산출. `durationSpentSec = now - startedAt`.
- 제출 시 `HistoryStore.add(AttemptRecord(certId, examId:'practice:clf-t2-1', mode:'practice', ...))`. "다시 풀기" / "학습문서로".
- 라벨 = **연습 문제**(모의고사 아님 — cross-task·타이머는 후속).

## 10. 빈 상태 / 에러 (DESIGN.md 브랜드)
- 자산 로드 실패: "콘텐츠를 불러오지 못했습니다" + 재시도.
- 검증 문항 0개(필터 후): "검증된 연습 문제가 아직 없습니다"(시작 버튼 비활성 — 가짜 자신감 방지).
- 학습문서만 있고 문항 없음: CTA 숨김.

## 11. 테스트 전략 (완료 기준)
- `test/markdown_parser_test.dart`: 디스크에서 `t2-1.md` 읽어 파싱 → 프런트매터 `examGuideTaskId=='clf-t2-1'` & sources≥5; 섹션에 🎯/⚠️/🧪 존재; `MdDetails`≥4; 표 1개 이상 헤더 파싱; degrade(이상 줄→Paragraph).
- `test/question_model_test.dart`: `t2-1.questions.json` → `QuestionBank.fromJson` → 5문항, 전부 `verified`, `correct` 범위 내, `wrongExplanations` 키가 정답 아닌 인덱스와 일치, sources 비어있지 않음, 비검증 문항 필터 동작.
- 위젯 스모크: 이미 파싱된 `StudyContent`/`QuestionBank`를 **주입**해 `StudyDocPage`/`QuizPage` 펌프(자산 의존 회피) → 제목·섹션 렌더, 보기 선택→공개 동작.
- `flutter analyze`(0) · `flutter test`(통과) · `flutter build web --release --base-href /aws-docs/`(성공).

## 12. 리스크 / 완화
| 리스크 | 완화 |
|---|---|
| 자체 Markdown 파서 취약성 | 제한·문서화된 하위집합 + 실제 문서 단위 테스트 + degrade 폴백 |
| `package:web` localStorage가 테스트(비웹)에서 미동작 | 백엔드 주입(Memory 폴백) + `kIsWeb` 가드 |
| DESIGN.md 이탈(하드코딩) | 색·간격 전부 `context.c`/`Gap`/`Radii` 토큰만 |
| 콘텐츠 추가 시 인덱스 누락 | 정적 인덱스 + 부록 작성 컨벤션 체크리스트 |

## 13. 파일별 구현 요약 (plan 입력)
1. `study_content.dart`(모델) → 2. `markdown_parser.dart`(+테스트) → 3. `question.dart`(+테스트) → 4. `history_store.dart` → 5. `study_markdown_view.dart` → 6. `study_doc_page.dart` → 7. `quiz_page.dart` → 8. `content_index.dart` → 9. `cert_detail_page.dart` 배선 → 10. analyze/test/build.

## 14. 부록 — 학습문서 작성 컨벤션 (18 Task 복제용)
- 프런트매터 필수 키: examGuideTaskId, certCode, domain, title, sources[≥1], lastVerified.
- 섹션 이모지 규약: ✅ 체크리스트 / 🎯 왜 / 📖 핵심개념 / ✍️ 시험포인트 / ⚠️ 함정 / 🧪 자가점검 / 📌 출처.
- 자가 점검은 `<details><summary>질문</summary>정답</details>`.
- 표·코드펜스·`**bold**`·`` `code` ``·원시 URL만 사용(파서 지원 범위).
