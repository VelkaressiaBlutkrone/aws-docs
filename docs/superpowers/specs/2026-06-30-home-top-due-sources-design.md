# 설계: 홈 상단 정리 — due 배너 + 출처 칩 + 레이아웃

- 날짜: 2026-06-30
- 생성: /superpowers:brainstorming
- 상태: APPROVED (설계 사용자 승인)
- 범위: 홈(`home_page.dart`) 상단 두 컴포넌트의 **시각 정리** — ① `_dueBanner`(오늘 할 일/지난 일정) 신호 명료화, ② `_SourcePill`(공식 출처 칩) 외부 단서·radius·weight, ③ 두 블록 간 여백 구분. **계산 로직·데이터 무변경**, DESIGN.md 정합.

## 배경

홈 상단은 `Hero → _dueBanner → SourcesRow → 본문 섹션` 순이다. 스크린샷 점검에서 세 가지 어긋남이 드러났다:

- **`_dueBanner`**(`home_page.dart:86-146`): "오늘 학습할 항목 N개 · 지난 일정 N개 · 일정 보기 →"가 전부 `accent` 틸 + `event_available_outlined`(완료 뉘앙스) 아이콘. *밀린 일정(overdue)*을 긍정 신호로 가려 DESIGN 브랜드 "정직함"과 어긋나고, today(오늘 할 일)와 overdue(밀림)의 긴급도가 평탄화된다.
- **`_SourcePill`**(`hero_section.dart:79-128`): 새 탭 외부 링크인데 시각 단서(↗)가 없어(Semantics만 존재) 클릭 결과를 눈으로 예측 못 함. `Radii.sm`(6px)이라 DESIGN.md L97("칩/배지만 full(999px)")과 불일치(클래스명은 `Pill`). 보조 정보인데 `w700` bold.
- **레이아웃**: due(개인 상태 surface2 카드)와 sources(외부 자료 칩 행)가 인접해 성격이 혼동된다.

## 결정사항 (brainstorming)

1. **due 색 = overdue→warning, today→accent.** wrong(빨강)은 압박/불안 유발이라 비채택(반마케팅 "차분"). warning(앰버)이 정직함과 절제의 균형.
2. **due 표현 = 인라인 색 분리.** 한 줄 유지, 세그먼트별 색. 배지 2개·2영역 구조는 배너에 과함(비채택).
3. **출처 칩 = ↗ 외부 아이콘 + full radius + weight 절제(w700→w500).** DESIGN 칩 정책 정합 + 외부 명료 + 절제.
4. **레이아웃 = 순서 유지 + 시각 구분.** due를 상단에 두되(개인 액션 가치) due/sources 사이 여백을 명확히. 라벨 추가 없이 여백만(에디토리얼 절제).

## 컴포넌트

### A. `_dueBanner` (`home_page.dart`)

- **텍스트 색 분리**: 현재 `parts.join(' · ')` 단색 → 세그먼트별 색을 가진 `Text.rich`/`RichText`. "오늘 할 일 N개"=`accent`, "지난 일정 N개"=`warning`, 구분점 `·`=`textFaint`. (문구는 현행 "오늘 학습할 항목 N개"·"지난 일정 N개" 유지 — 카피 변경 아님.)
- **아이콘 상태 반영**: `event_available_outlined`(완료) 교체.
  - overdue>0 → `event_busy_outlined` + `warning` 색
  - overdue==0(today만) → `event_upcoming_outlined` + `accent` 색
- **컨테이너**: surface2 + border 유지(border까지 색칠 금지 — 압박 방지, 절제). 텍스트·아이콘 색만 시맨틱.
- "일정 보기 →": `accent` 유지(액션 어포던스).
- 탭 동작·카운트 로직(`planDueCounts`·`active`·`oneCert`)·표시 조건 **불변**.

### B. `_SourcePill` (`hero_section.dart`)

- **↗ 외부 단서**: 라벨 뒤 `Icon(Icons.north_east, size: 14)`. 색은 라벨과 동일(active면 accent, 아니면 textMuted). `Row`로 라벨+아이콘(`SizedBox(width: 6)` 간격).
- **radius**: `Radii.sm` → `Radii.full`. 컨테이너 `decoration`·`InkWell.borderRadius`·`InsetFocusRing.borderRadius` 세 곳 일관 변경.
- **weight**: 라벨 `w700`/`Wght.w700` → `w500`/`Wght.w500`(fontWeight↔fontVariations 1:1 규율 유지 — DESIGN.md L35).
- **패딩**: 좌우 12→14(full radius 균형). 상하 10 유지.
- 색·hover·focus·openLink·Semantics **불변**.

### C. 레이아웃 (`home_page.dart` build)

- 순서 `Hero → ?dueBanner → SourcesRow → ...` 유지.
- due/sources 시각 구분: `SourcesRow` 위 여백을 명확히. `_dueBanner`는 현재 `Padding(top: Gap.lg)`로 hero와 분리되어 있고, `SourcesRow`는 자체 `Padding(bottom: Gap.xl2)`만 가져 due와 붙는다. → due 카드 아래 또는 sources 위에 `Gap.xl` 분리를 추가(둘 중 한 곳, 이중 여백 금지).

## 데이터·DESIGN

- 색 토큰: `c.accent`·`c.warning`·`c.warningWeak`(미사용 시 생략)·`c.textFaint`·`c.textMuted` — 모두 기존 `AppColors`. 하드코딩 금지.
- DESIGN.md: 칩 radius·due 시맨틱은 기존 토큰/정책 적용이라 **시스템 변경 없음**. Decisions Log에 1줄 기록(2026-06-30 홈 상단 due 시맨틱·출처 칩 full/↗).

## 테스트·검증 전략

- **순수 함수화(가능한 만큼)**: due 아이콘·색 분기는 overdue 카운트에 따른 결정이라, 분기를 작은 헬퍼(예: `dueIcon(overdue)`·세그먼트 색)로 빼 단위테스트. 홈은 SelectionArea+비동기라 위젯 렌더 테스트 불가([[flutter-selectionarea-widget-test-pitfall]]) — 라우팅/존재만.
- `home_sections_test.dart` 회귀(섹션 렌더 깨지지 않음).
- `flutter test` 그린 · `flutter analyze` 신규 0(기존 잔존 3) · web build.
- 실브라우저 dogfood(가능 시): due 배너 색 분리·출처 칩 알약+↗ 육안 확인([[flutter-web-dogfood-browse]]).

## 범위 / 비목표

- 범위: `_dueBanner`·`_SourcePill` 시각 정리 + due/sources 여백. DESIGN Decisions Log 1줄.
- 비목표(YAGNI): due 계산/표시 조건 변경 · 출처 데이터(`officialSources`) 변경 · 카피 변경 · `schedule_section`/`ScheduleSection` · 다른 페이지 칩.

## 정본·관련

- 코드: `flutter_app/lib/pages/home_page.dart`(`_dueBanner`), `flutter_app/lib/pages/home/hero_section.dart`(`SourcesRow`·`_SourcePill`), `flutter_app/lib/data/site_data.dart`(`officialSources`)
- DESIGN: `DESIGN.md`(L97 칩 radius, L35 Wght 규율, Color semantic warning, Voice 합니다체)
- 함정: [[flutter-selectionarea-widget-test-pitfall]] · [[flutter-web-dogfood-browse]]
