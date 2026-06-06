# IA 재조정 + URL 라우팅 설계 (Spec 1)

- **상태:** 설계 승인됨 (2026-06-06). 구현 계획(writing-plans) 대기.
- **범위:** 랜딩 IA 재조정(A) + go_router URL 라우팅(B). 통합 모의고사(C)는 **Spec 2**로 분리, 본 스펙은 라우트·섹션 자리만 예약.
- **대상 코드베이스:** `aws-docs/flutter_app` (Flutter Web, GitHub Pages 배포, base-href `/aws-docs/`).
- **브랜드 제약:** `DESIGN.md` "조용한 레퍼런스" + "정직함의 시각화". 새 디자인 언어 금지, 기존 테마 토큰·위젯 재사용.

## 1. 목표 & 성공 기준

랜딩의 상단 메뉴/섹션이 가리키는 콘텐츠와 **실제 작업된 콘텐츠를 일치**시키고, 모든 화면에 **고유 URL**을 부여한다.

성공 기준:
- 랜딩 "상세 학습 문서"·"모의고사" 섹션에서 실제 검증 콘텐츠(`content_index`)에 도달한다.
- 가짜 placeholder(`studyDocs` 요약, `_examSets()` 6회차)가 **사라진다** — 존재하지 않는 콘텐츠를 암시하지 않음(정직함).
- 각 페이지가 고유 URL(hash)을 가진다 → 새로고침·뒤로가기·딥링크·공유가 동작한다.
- 콘텐츠 없는 11개 자격증은 "준비 중"으로 **정직하게** 표시된다.
- 기존 deep 페이지(StudyDoc/Quiz/Exam/CertDetail)와 기존 테스트가 그대로 동작한다.

## 2. 현재 상태 (문제의 구조)

콘텐츠가 **두 갈래로 분리**되어 있고 상단 메뉴는 옛 갈래만 가리킨다.

- **시스템 A (랜딩/레거시):** `lib/data/site_data.dart`의 `Certification.studyDocs`/`exams`. `src/data.ts`에서 포팅한 **플레이스홀더**. `_examSets()`(`site_data.dart:31`)가 6회차를 보일러플레이트로 자동 생성. 12개 자격증 전부 커버하지만 전부 가짜.
- **시스템 B (실콘텐츠):** `lib/data/content_index.dart`의 `kContentIndex`. **CLF-C02만** 채워짐(19 Task). `CertDetailPage`의 `_LearningContent` → `StudyDocPage` → `QuizPage`/`ExamPage`로 이어지는 실제 검증 콘텐츠.
- **단절:** 상단 메뉴(`home_page.dart:55-61`)는 `_goto()` 스크롤 전용. 도착지 `_StudyDocsSection`/`_ExamsSection`은 시스템 A를 렌더 → "옛날것". 시스템 B로 가는 유일 입구는 자격증 카드(`home_page.dart:369`)뿐.
- **라우팅 부재:** `main.dart:33`이 `home: HomePage`만 지정. 모든 이동이 `Navigator.push(MaterialPageRoute)` → 웹앱인데 딥링크·뒤로가기·공유 URL 없음.

## 3. 라우트 트리 (go_router · hash 전략)

`MaterialApp.router` + go_router. **hash URL 전략(기본값)** — GitHub Pages 프로젝트 페이지에서 서버 설정·`404.html` 없이 딥링크/새로고침이 동작.

```
/                                  → HomePage
/cert/:code                        → CertDetailPage
/cert/:code/study/:taskId          → StudyDocPage
/cert/:code/study/:taskId/quiz     → QuizPage
/cert/:code/study/:taskId/exam     → ExamPage  (per-task, 기존)
/cert/:code/exam                   → [Spec 2 예약] 통합 모의고사 — 본 스펙에선 "준비 중" placeholder 페이지
잘못된 code / taskId               → '/' 로 redirect
```

- 실 URL 예: `…/aws-docs/#/cert/CLF-C02/study/clf-t1-1`.
- **엔티티 해석은 라우트 빌더가 수행:** `code`→`certifications`에서 `Certification`, `taskId`→`contentFor(code)`에서 `ContentEntry`. 페이지는 **해석된 객체를 받는다**(생성자 시그니처 유지) → 딥링크/새로고침 진입에도 동작.
- 해석 실패(알 수 없는 code/taskId) → `redirect`로 `/`.
- 상단 메뉴의 단계/추천순서/로드맵/학습문서/모의고사는 **`/`의 섹션 스크롤** 유지(별도 라우트 아님).

## 4. 데이터 단일 소스화

- `content_index.dart`를 콘텐츠 존재의 **유일 소스**로 격상. 헬퍼 추가:
  - `bool certHasContent(String code)` — `contentFor(code).isNotEmpty`.
  - `({int docs, int questions}) certContentSummary(String code)` — 문서 수 + 총 검증 문항 수(`questionCount` 합).
- **플레이스홀더 제거:**
  - `models/certification.dart`: `StudyDoc`·`PracticeExam` 클래스, `Certification.studyDocs`·`exams` 필드 삭제.
  - `data/site_data.dart`: `_examSets()` + 각 cert 리터럴의 `studyDocs:`/`exams:` 삭제.
  - 유지: `roadmap`·`focus`·`audience`·`level`·`code`·`recommendedPaths`·`officialSources`(정당한 개요).
- **blast radius(확인됨):** 위 심볼은 `site_data.dart`·`certification.dart`·`home_page.dart`에서만 사용. **테스트는 참조하지 않음** → 기존 테스트 직접 영향 없음.

## 5. 랜딩 섹션 재작성 (하이브리드 + delegate)

- `_StudyDocsSection`(`home_page.dart:552`) 재작성:
  - 콘텐츠 보유 자격증(현재 CLF-C02): 실데이터 요약 카드 — "검증 학습문서 N · 총 M문항"(`certContentSummary`) → `context.push('/cert/<code>')`.
  - 나머지 11개: **"준비 중" compact 칩 묶음**(코드/제목). 가짜 문서 없음.
- `_ExamsSection`(`home_page.dart:624`) 재작성:
  - CLF-C02 카드 → `context.push('/cert/<code>/exam')`(Spec 2 예약; 지금은 "준비 중" 페이지로 진입).
  - 나머지 11개: "준비 중" 묶음.
- `_DocItem`(StudyDoc 의존, `home_page.dart:589`) 제거/대체.
- **delegate 원칙:** Task 목록의 단일 소재는 `CertDetailPage._LearningContent`. 랜딩에 Task 목록을 인라인하지 않는다 — 같은 목록이 두 곳에 생기면 본 스펙이 없애려는 중복을 재도입하기 때문. 랜딩은 **요약 + 진입**만 담당.
- 상단 메뉴는 스크롤 유지하되 **도착지가 실콘텐츠**가 되어 신고된 단절 해소.

## 6. 네비게이션 마이그레이션 & 테마 상태

- `Navigator.push(MaterialPageRoute(...))` → `context.push('/...')` 4곳:
  - `home_page.dart:369` 자격증 카드 → `/cert/<code>`
  - `cert_detail_page.dart:171` Task 카드 → `/cert/<code>/study/<taskId>`
  - `study_doc_page.dart:170` 연습 → `…/quiz`, `:178` 시험 → `…/exam`
- 라우트가 아닌 `Navigator.pop`(exam 다이얼로그 `exam_page.dart:143,187,190`)은 **유지**. `onExit`(`exam_page.dart:547`) `maybePop` → `context.pop()`.
- **`main.dart`:** `MaterialApp` → `MaterialApp.router(routerConfig: appRouter)`.
  - 테마 토글 상태(`_AwsDocsAppState._mode`)는 라우터가 페이지를 빌드하므로 루트로 올린다: `ValueNotifier<ThemeMode>` + `ThemeScope`(InheritedNotifier/InheritedWidget). `HomePage`의 토글은 `ThemeScope.of(context).toggle()`로 접근. `MaterialApp.router`는 notifier를 listen해 재빌드.
- 라우터 정의는 `lib/app_router.dart`(신규)에 분리.

## 7. 엣지/에러

- 알 수 없는 `code`/`taskId` 딥링크 → `/` redirect.
- 콘텐츠 없는 `/cert/:code` 진입 → `CertDetailPage`는 기존처럼 `contentFor` 빈 경우 학습섹션 숨김(현행 `cert_detail_page.dart:79` 가드). 정상 동작.
- 예약 `/cert/:code/exam`(통합) → 본 스펙에선 "통합 모의고사 준비 중" placeholder 페이지(Spec 2가 대체).
- hash 전략이므로 base-href `/aws-docs/`와 충돌 없음. CI 워크플로(`flutter build web --base-href /aws-docs/`) 변경 불필요.

## 8. 테스트 (TDD)

- **신규 단위/위젯 테스트:**
  - 라우터: 각 경로가 올바른 페이지로 해석되고 올바른 엔티티(Certification/ContentEntry)를 주입하는지. 잘못된 param → `/` redirect.
  - 헬퍼: `certHasContent`/`certContentSummary` 값.
  - 랜딩 섹션: 콘텐츠 보유 자격증은 요약 카드, 미보유는 "준비 중" 표시.
- **수정:** `widget_test.dart`(`MaterialApp.router` 전환 반영).
- **보존(무영향 예상):** `exam_view_test`·`quiz_view_test`·`exam_session_test`·`question_model_test`·`history_store_test`·`markdown_parser_test`·`study_markdown_view_test` — 모델 주입식/순수라 라우팅 무관.
- **의존성:** `pubspec.yaml`에 `go_router` 추가. 구현 시 **Context7로 현행 go_router API 확인**(전역 규칙).

## 9. 범위 밖 (YAGNI / 후속)

- **Spec 2 — 통합 모의고사(C):** 문항 풀 병합 + N문항 샘플링 + 도메인 가중 + 샘플 세션 복원 + `ExamView` 재사용 로더. 본 스펙은 라우트(`/cert/:code/exam`)와 랜딩 진입점만 예약.
- path URL 전략 + `404.html` SPA 폴백(hash 채택으로 불필요).
- 비-CLF 자격증의 실콘텐츠 추가(콘텐츠 작업, 별도).
- 자격증 간 통합 검색/진도 추적.

## 10. 결정 로그 (브레인스토밍 2026-06-06)

| 결정 | 선택 | 근거 |
|---|---|---|
| 재설계 범위 | 전면 재설계 X, "재조정 + 라우팅" | 페이지 IA·deep 페이지는 건강. 데이터 이중 소스 + 입구 단절만 문제 |
| 워크스트림 분해 | Spec 1(A+B) → Spec 2(C) | 신고 버그 먼저 해결·배포, 모의고사는 탄탄히 분리 |
| URL 전략 | hash | GitHub Pages 무설정·무위험. Flutter 클라이언트 렌더라 path의 SEO 이점 미미 |
| 빈 상태(콘텐츠 없는 cert) | 하이브리드 | 실콘텐츠는 풍부한 진입 카드, 나머지는 compact "준비 중" — 정직+깔끔+로드맵 유지 |
| 랜딩 렌더 | delegate(요약→CertDetailPage) | Task 목록 단일 소재 유지(DRY), 중복 재도입 방지 |
| 모의고사 범위(본 스펙) | 라우트·섹션만 예약 | 통합 모의고사 실제 구현은 Spec 2 |
| 플레이스홀더 데이터 | 제거 | 존재하지 않는 콘텐츠 암시 = 브랜드 "정직함" 위반 |
