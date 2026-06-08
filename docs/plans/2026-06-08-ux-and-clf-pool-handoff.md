# UX 개선 + CLF 문항 풀 확장 Handoff (2026-06-08 세션)

> 한 줄 상태: **출제 셔플·차출, 모바일 반응형, 표 렌더 버그, CLF 문항 풀(130→190) 모두 완료·배포.** CLF-C02는 19개 Task 전부 10문항으로 5문항 차출 로테이션 활성. 다음 작업 = (CLF 합격 게이트 후) SAA 문항 생산 또는 CLF 풀을 10→20으로 추가 확대.

## 0. 지금 어디인가 (2026-06-08 기준)

- **라이브:** https://velkaressiablutkrone.github.io/aws-docs/ · 저장소 `VelkaressiaBlutkrone/aws-docs` · 브랜치 `main`(직접 커밋·push). 최신 커밋 `c414d40`.
- **CLF-C02:** 19개 Task × **10문항 = 190 verified** 문항. 연습/시험은 풀에서 5문항 무작위 차출 + 선택지 셔플. 통합·약점 모의고사 활성.
- **SAA-C03:** 학습문서 24개 라이브, verified 문항 0(노출 가드로 모의고사·배지 숨김) — 이번 세션에서 변경 없음.

## 1. 이번 세션에 한 일 (4개 작업, 전부 배포됨)

### 1.1 선택지 셔플 + 문항 랜덤 차출 (엔진)
- **문제:** CLF 130문항 중 88.5%가 정답 인덱스 0(A)에 쏠림 → "A만 찍어도 88점". 또 Task 연습과 시험이 같은 풀 전체를 같은 순서로 출제해 사실상 동일.
- **해결(데이터 계층 순수 변환):**
  - `Question.withOptionOrder(order)` — 옵션·`correct`·`wrongExplanations` 키를 함께 재매핑(순수, 잘못된 순열이면 원본 폴백). 화면/채점 파이프라인 무수정.
  - `mock_exam.dart`: `taskSampleCount=5`, `samplePool`, `randomOptionOrders`, `applyOptionOrders`, `ordersCoverQuestions`.
  - Task 연습(`QuizPage`)·시험(`ExamPage`)이 풀에서 5문항 차출 + 셔플. 통합/약점 모의고사·오답노트도 셔플.
  - 시험 새로고침 복원: `ExamSession.optionOrders`(문항ID→표시순서)를 **명시 저장**(시드 재셔플 기각 — RNG 변경 시 답 어긋남 방지). Task 시험은 전체 뱅크 지문(`sessionFingerprint`)으로 개정 감지.
- **주의 발견:** `QuizPage`가 `FutureBuilder(future: _load())`로 빌드마다 재샘플 → 리빌드 시 풀이 중 문항이 바뀜. `late final Future`를 갖는 StatefulWidget으로 전환해 차단.
- 스펙 `docs/superpowers/specs/2026-06-08-option-shuffle-question-sampling-design.md`, 플랜 `…/plans/2026-06-08-option-shuffle-question-sampling.md`. 커밋 `17d34ab`~`da92501`.

### 1.2 모바일 햄버거 네비게이션
- 홈 상단 nav(`home_page.dart` `_Header`)가 좁은 화면에서 잘림. 가용 폭 **768px 미만**이면 `LayoutBuilder`로 분기해 5개 링크를 `_NavMenuButton`(PopupMenuButton 드롭다운)으로 대체. 테마 토글은 밖에 유지. `onNav` 맵 공유, 새 상태 없음.
- 스펙 `…/specs/2026-06-08-mobile-hamburger-nav-design.md`, 플랜 `…/plans/2026-06-08-mobile-hamburger-nav.md`. 커밋 `072bfab`.

### 1.3 표 인라인 서식 + 모바일 표 가독성 + AppBar 제목
- **표 셀 버그:** `MdTable`이 셀을 raw String으로 저장·렌더 → `**굵게**`/`` `코드` ``가 리터럴로 노출. `MdTable`을 `List<List<MdSpan>>`/`List<List<List<MdSpan>>>`로 바꿔 파서가 셀에 `_inline()` 적용, 렌더러가 `_spans()` 재사용.
- **모바일 표:** `_table`을 `LayoutBuilder`+가로 스크롤로 감싸고 표 폭 = `max(가용폭, 열수×140)` → 좁은 화면에서 열 최소폭 보장.
- **AppBar 제목:** `cert_exam`/`review`/`report`의 긴 영문 제목(`cert.title`)이 모바일 말줄임 → `cert.code`로(예: `CLF-C02 · 통합 모의고사`).
- 스펙 `…/specs/2026-06-08-md-table-inline-and-appbar-title-design.md`, 플랜 `…/plans/2026-06-08-md-table-inline-and-appbar-title.md`. 커밋 `aff187e`(표)·`32507fe`(제목).

### 1.4 CLF 문항 풀 확장 (130 → 190)
- **문제:** Task당 6~9문항뿐이라 5문항 차출이 거의 같은 문제 → 로테이션 빈약. 목표: 각 Task 풀을 10개로.
- **작업:** 19개 Task 전부 10문항으로(도메인1 +13, 도메인2~4 +47 = **+60 신규**).
  - Task별 병렬 서브에이전트가 학습문서·기존 문항을 읽고 중복 없이 작성 → 각 `<taskId>.questions.json`에 직접 append. AWS 공식 문서 대조 + 실재 출처 URL, 정답 위치 분산, 기존이 덜 다룬 포인트 보강.
  - `verified:true`(사용자 검수 신뢰 결정) + `content_index.dart`의 `questionCount`를 19개 Task 모두 10으로 갱신.
- **검증:** 15개 파일 JSON 유효 + 각 verified 10, `flutter analyze` 0, `flutter test` 99 green(`question_model_test`의 t2-1 카운트 9→10 갱신), 라이브 통합 모의고사 "풀 190개" 확인.
- 커밋 `0a2229c`(D1 초안)·`b7e0f9e`(D1 활성화)·`c414d40`(D2~4).

## 2. 절대 잊지 말 환경 (매 세션 함정)
- **폴더:** git 루트 `C:\workspace\aws-docs`, Flutter `flutter_app\`. 콘텐츠 `flutter_app\assets\content\<cert>\`.
- **명령:** flutter/test/analyze는 **PowerShell**에서 `flutter_app` 기준(`cd C:\workspace\aws-docs\flutter_app`). git은 `git -C C:\workspace\aws-docs`. Git Bash로 flutter 빌드 금지(`--base-href` 깨짐).
- **Bash 도구 cwd:** 백그라운드 `flutter run`은 Bash 도구에서 cwd가 리셋될 수 있음 → `cd /c/workspace/aws-docs/flutter_app && flutter.bat run …`로 명시.
- **pubspec.lock:** `flutter run`/`build`가 추이 의존성 버전을 건드림. 기능 무관하면 `git checkout -- flutter_app/pubspec.lock`으로 되돌리고 배포(이번 세션 내내 그렇게 함).
- **로컬 콘솔 경고:** SelectionArea의 `hasSize` assertion이 모든 페이지 콘솔/일부 위젯 테스트에서 뜸 — 알려진 Flutter 웹 디버그 경고, 표시·릴리스 무관. AppBar 위젯 테스트는 라우터 스택(하단 HomePage SelectionArea + 전환) 대신 페이지를 직접 펌프해 회피.
- **커밋:** `main` 직접 커밋·push(사용자 선택). push 시 GitHub Pages 자동 배포(~1분).

## 3. 문항 풀 확장 레시피 (이번 세션 검증된 패턴)
Task당 N개 추가가 필요할 때:
1. **병렬 서브에이전트 1 Task당 1개** 디스패치 — 각자 학습문서(`<task>.md`)+기존 문항(`<task>.questions.json`) 정독 → 부족분만 작성해 **자기 파일에 직접 append**(다른 파일이라 병렬 안전). 프롬프트에 스키마·`verified` 값·실재 AWS 공식 URL·정답 위치 분산·중복 금지·들여쓰기·편집 후 JSON 재검증 명시.
2. **조율자(메인) 일괄 처리:** 전 파일 JSON 유효성+`verified` 카운트 일괄 검증 → `content_index.dart` `questionCount` 갱신(자산 경로로 정확히 타겟, SAA·미대상은 미변경) → 카운트 하드코딩 테스트(`question_model_test`) 동기화 → `flutter analyze`+`flutter test` → 커밋 → push.
- **검수 게이트:** 정직성 규율상 verified는 제작자 검수가 원칙. 이번엔 사용자가 "AI 작성 신뢰" 결정으로 바로 `verified:true`. 보수적으로 가려면 `verified:false`로 커밋 → 검수 후 true 전환(도메인1을 이 2단계로 시작했다가 사용자 B 선택으로 바로 활성화).

## 4. 다음 작업 후보
1. **CLF 풀 10→20 추가 확대** — 같은 레시피로 각 Task에 +10. "최소 10 최대 20" 요구의 상한까지. 로테이션 더 강화.
2. **(게이트 후) SAA verified 문항 생산** — 각 `saa-tX-Y.questions.json`(`verified:true`, 출처 필수) + `questionCount` 갱신 시 모의고사·약점 루프 자동 활성. **본인 CLF 합격 게이트** 유지. 직전 핸드오프 `2026-06-07-saa-study-docs-handoff.md` 참조.
3. **신규 문항 사후 검수** — 이번에 추가한 60개는 AI 작성+공식문서 대조본. 제작자 정독으로 사실/표현 재점검 권장(틀린 항목은 수정 또는 제거).
4. **보류:** `quiz_widgets` 폰트 크기 토큰화(DESIGN.md vs 코드) — 사용자 결정 대기.

## 5. 참고 문서 (이번 세션 산출)
- 스펙: `docs/superpowers/specs/2026-06-08-{option-shuffle-question-sampling,mobile-hamburger-nav,md-table-inline-and-appbar-title}-design.md`
- 플랜: `docs/superpowers/plans/2026-06-08-{option-shuffle-question-sampling,mobile-hamburger-nav,md-table-inline-and-appbar-title}.md`
- 직전 핸드오프(SAA·복제 레시피·문항 규율): `docs/plans/2026-06-07-saa-study-docs-handoff.md`, `2026-06-07-phase3-content-handoff.md`
- 콘텐츠 플레이북: `docs/plans/2026-06-06-content-production-playbook.md`
- 형식 정본: `flutter_app/assets/content/clf/t1-1.md`(학습문서), `…/t1-1.questions.json`(문항)

## 6. 한 줄 요약 (다음 작업자에게)
> 출제 셔플·5문항 차출 엔진 + 모바일 반응형 + 표 렌더 버그 수정 + CLF 풀 130→190(19 Task×10) 완료·배포. 풀 확장은 도메인 단위 병렬 서브에이전트가 자기 파일에 직접 append → 조율자가 `questionCount`·테스트 동기화 후 push로 검증됐다. 다음은 CLF 풀 10→20 확대 또는 (합격 후) SAA 문항.
