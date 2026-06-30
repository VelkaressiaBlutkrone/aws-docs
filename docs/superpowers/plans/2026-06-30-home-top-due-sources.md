# 홈 상단 due 배너·출처 칩 시각 정리 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈 상단 `_dueBanner`(오늘/지난 일정 색 시맨틱 분리·아이콘)와 `_SourcePill`(외부 ↗·full radius·weight 절제)을 DESIGN.md에 맞게 정리하고, 두 블록 사이 여백을 구분한다.

**Architecture:** 순수 UI 변경. due 아이콘 분기만 top-level 순수 함수(`dueIcon`)로 빼 단위테스트하고, 색 분기는 위젯 내부(context 의존). 출처 칩 ↗ 아이콘은 home 펌프 위젯 테스트로 확인. 홈은 SelectionArea+비동기라 due 배너 자체는 위젯 렌더 테스트 불가(플랜 스토어가 비어 미표시) — 라우팅/존재만.

**Tech Stack:** Flutter (Dart), `AppColors` ThemeExtension(`context.c`), `Wght` fontVariations 토큰, go_router.

## Global Constraints

- 색은 `context.c`(`AppColors`) 토큰만 — 하드코딩 금지(DESIGN.md). `c.accent`·`c.warning`·`c.textFaint`·`c.textMuted` 사용.
- `fontWeight`를 쓰는 모든 TextStyle에 `fontVariations: Wght.wNNN` 1:1 병기(DESIGN.md L35 — 누락 시 400 균일화).
- 칩/배지 radius는 `Radii.full`(DESIGN.md L97). 일반 표면은 sm/md/lg.
- 카피 변경 금지(문구 "오늘 학습할 항목 N개"·"지난 일정 N개"·"일정 보기 →" 유지). due 계산 로직(`planDueCounts`·`active`·`oneCert`)·표시 조건 불변.
- 모든 명령은 `flutter_app/` 기준.
- 커밋 직전 `git branch --show-current`로 `fix/home-top-due-sources` 확인(공유 워킹트리). 다른 세션 untracked 파일 `git add` 금지.

---

### Task 1: due 배너 — 색 시맨틱 분리 + 상태 아이콘

`_dueBanner`의 단색 텍스트·완료 뉘앙스 아이콘을, today=accent·overdue=warning 인라인 분리 + 상태 아이콘으로. 아이콘 분기는 순수 함수 `dueIcon`으로 빼 TDD.

**Files:**
- Create: `flutter_app/test/home_due_banner_test.dart`
- Modify: `flutter_app/lib/pages/home_page.dart` (`dueIcon` top-level 신규, `_dueBanner` L108-145 본문)

**Interfaces:**
- Produces: `IconData dueIcon(int overdue)` — top-level 공개 함수.

- [ ] **Step 1: 실패 테스트 작성**

`flutter_app/test/home_due_banner_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/pages/home_page.dart';

void main() {
  test('dueIcon: overdue>0이면 event_busy, 없으면 event_upcoming', () {
    expect(dueIcon(3), Icons.event_busy_outlined);
    expect(dueIcon(1), Icons.event_busy_outlined);
    expect(dueIcon(0), Icons.event_upcoming_outlined);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/home_due_banner_test.dart`
Expected: FAIL — `dueIcon` 미정의(컴파일 에러 "The function 'dueIcon' isn't defined").

- [ ] **Step 3: `dueIcon` top-level 함수 추가**

`home_page.dart`에서 `class HomePage` 선언 **바로 앞**(import 블록 다음)에 추가:

```dart
/// due 배너 아이콘 — 지난 일정(overdue)이 있으면 주의(busy), 없으면 예정(upcoming).
IconData dueIcon(int overdue) =>
    overdue > 0 ? Icons.event_busy_outlined : Icons.event_upcoming_outlined;
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/home_due_banner_test.dart`
Expected: PASS.

- [ ] **Step 5: `_dueBanner` 본문 — 색 분리 + 아이콘 적용**

`home_page.dart`의 `_dueBanner`에서 `if (today == 0 && overdue == 0) return null;` **다음** 블록을 교체한다. 기존:
```dart
    final parts = <String>[
      if (today > 0) '오늘 학습할 항목 $today개',
      if (overdue > 0) '지난 일정 $overdue개',
    ];
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg),
```
를 다음으로(여백은 Task 3에서 다룸 — 여기선 `parts` 제거 + Row 내부만 교체):
```dart
    final hasToday = today > 0;
    final hasOverdue = overdue > 0;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg),
```
그리고 같은 `Row`의 `children`(아이콘·텍스트)을 교체. 기존:
```dart
              Icon(Icons.event_available_outlined, size: 18, color: c.accent),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(parts.join(' · '),
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontVariations: Wght.w700, color: c.text)),
              ),
```
를:
```dart
              Icon(dueIcon(overdue),
                  size: 18, color: overdue > 0 ? c.warning : c.accent),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    if (hasToday)
                      TextSpan(
                          text: '오늘 학습할 항목 $today개',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontVariations: Wght.w700,
                              color: c.accent)),
                    if (hasToday && hasOverdue)
                      TextSpan(
                          text: ' · ',
                          style: TextStyle(color: c.textFaint)),
                    if (hasOverdue)
                      TextSpan(
                          text: '지난 일정 $overdue개',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontVariations: Wght.w700,
                              color: c.warning)),
                  ]),
                ),
              ),
```
("일정 보기 →" Text는 그대로 둔다.)

- [ ] **Step 6: 회귀·분석 확인**

Run:
```bash
cd flutter_app
flutter test test/home_sections_test.dart 2>&1 | tail -2
flutter analyze lib/pages/home_page.dart test/home_due_banner_test.dart 2>&1 | tail -3
```
Expected: home_sections 그린(특히 "플랜 없으면 오늘-할-일 배너 미표시" 유지 — 배너 미표시 조건 불변), analyze 신규 0.

- [ ] **Step 7: 커밋**

```bash
git branch --show-current   # fix/home-top-due-sources
git add flutter_app/lib/pages/home_page.dart flutter_app/test/home_due_banner_test.dart
git commit -m "fix(home): due 배너 today=accent·overdue=warning 색 분리 + 상태 아이콘(dueIcon)"
```

---

### Task 2: 출처 칩 — ↗ 외부 단서 + full radius + weight 절제

`_SourcePill`을 외부 링크 시각 단서(↗) + 알약 radius + w500으로.

**Files:**
- Modify: `flutter_app/lib/pages/home/hero_section.dart` (`_SourcePillState.build` L92-127)
- Modify: `flutter_app/test/home_sections_test.dart` (위젯 테스트 1개 추가)

**Interfaces:**
- Consumes: `officialSources`(site_data — 3개), `Icons.north_east`.

- [ ] **Step 1: 실패 테스트 추가**

`home_sections_test.dart`의 `main()` 안, `testWidgets('플랜 없으면 ...')` **앞**에 추가:

```dart
  testWidgets('출처 칩: 외부 링크 ↗ 아이콘 표시', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pump();
    // officialSources 각 칩에 외부 단서 아이콘(north_east).
    expect(find.byIcon(Icons.north_east), findsWidgets);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/home_sections_test.dart -n "출처 칩"`
Expected: FAIL — `find.byIcon(Icons.north_east)` findsNothing(아직 아이콘 없음).

- [ ] **Step 3: `_SourcePill` 본문 교체**

`hero_section.dart`의 `_SourcePillState.build`에서 `InsetFocusRing`부터 안쪽까지 교체. 기존(L104-124):
```dart
        child: InsetFocusRing(
          borderRadius: BorderRadius.circular(Radii.sm),
          child: InkWell(
            onTap: () => openLink(widget.href),
            borderRadius: BorderRadius.circular(Radii.sm),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: active ? c.accent : c.border),
              ),
              child: Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700, fontVariations: Wght.w700,
                      color: active ? c.accent : c.textMuted)),
            ),
          ),
        ),
```
를:
```dart
        child: InsetFocusRing(
          borderRadius: BorderRadius.circular(Radii.full),
          child: InkWell(
            onTap: () => openLink(widget.href),
            borderRadius: BorderRadius.circular(Radii.full),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(Radii.full),
                border: Border.all(color: active ? c.accent : c.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500, fontVariations: Wght.w500,
                          color: active ? c.accent : c.textMuted)),
                  const SizedBox(width: 6),
                  Icon(Icons.north_east,
                      size: 14, color: active ? c.accent : c.textMuted),
                ],
              ),
            ),
          ),
        ),
```

- [ ] **Step 4: 통과·회귀 확인**

Run:
```bash
cd flutter_app
flutter test test/home_sections_test.dart 2>&1 | tail -2
flutter analyze lib/pages/home/hero_section.dart 2>&1 | tail -3
```
Expected: 전체 그린(추가한 "출처 칩" 테스트 포함), analyze 신규 0.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/pages/home/hero_section.dart flutter_app/test/home_sections_test.dart
git commit -m "fix(home): 출처 칩 외부 ↗ 단서 + full radius + weight 절제(w500)"
```

---

### Task 3: 레이아웃 여백 + DESIGN 기록 + 통합 게이트

due 카드와 출처 칩 사이 여백 구분 + DESIGN Decisions Log + 전체 회귀.

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` (`_dueBanner`의 Padding)
- Modify: `DESIGN.md` (Decisions Log 1줄)

- [ ] **Step 1: due/sources 여백 분리**

`home_page.dart` `_dueBanner`의 `return Padding(padding: const EdgeInsets.only(top: Gap.lg),`를 다음으로(due가 표시될 때만 아래 SourcesRow와 `Gap.xl` 분리 — 조건부 일관, 이중 여백 없음):
```dart
    return Padding(
      padding: const EdgeInsets.only(top: Gap.lg, bottom: Gap.xl),
```

- [ ] **Step 2: DESIGN Decisions Log 추가**

`DESIGN.md`의 Decisions Log 테이블 **마지막 행 다음**에 추가:
```markdown
| 2026-06-30 | 홈 상단 due 배너 색 시맨틱(today=accent·overdue=warning)·상태 아이콘 + 출처 칩 full radius·외부 ↗·w500 | 밀린 일정을 긍정 신호(accent+완료 아이콘)로 가리던 것을 정직하게 분리(warning, 빨강은 압박이라 배제). 출처 칩을 L97 "칩=full" 정책에 정합 + 외부 새 탭 단서 명시 |
```

- [ ] **Step 3: 전체 회귀 게이트**

```bash
cd flutter_app
flutter test 2>&1 | tail -2
flutter analyze 2>&1 | tail -5
```
Expected: 전체 그린(기존 776 + dueIcon 1 + 출처 칩 1 ≈ 778), analyze 신규 0(기존 잔존 3: plan_agenda cacheExtent·sync_controller_test 2).

- [ ] **Step 4: 웹 빌드(PowerShell)**

PowerShell: `flutter build web --release --base-href /aws-docs/`
Expected: `√ Built build\web`. ([[flutter-build-web-powershell]] — Git Bash 금지.)

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/pages/home_page.dart DESIGN.md
git commit -m "fix(home): due/출처 블록 여백 구분 + DESIGN Decisions Log 기록"
```

- [ ] **Step 6: 마무리**

REQUIRED SUB-SKILL: `superpowers:finishing-a-development-branch` → 옵션 2(develop PR). 실브라우저 dogfood([[flutter-web-dogfood-browse]])로 due 색 분리·칩 알약+↗ 육안 확인 권장(선택).

---

## Self-Review

**1. Spec coverage:**
- A due 색 분리(today=accent·overdue=warning)·아이콘 → Task 1. ✓
- B 출처 칩 ↗·full·weight → Task 2. ✓
- C 레이아웃 여백 → Task 3 Step 1. ✓
- DESIGN Decisions Log → Task 3 Step 2. ✓
- 검증(test/analyze/web) → Task 1·2 부분 + Task 3 전체. ✓
- 비목표(로직·데이터·카피·schedule_section 불변) → Global Constraints. ✓

**2. Placeholder scan:** 모든 코드 스텝에 완전 코드·명령·기대출력. TODO/TBD 없음. ✓

**3. Type consistency:** `dueIcon(int) -> IconData`(Task 1 정의·테스트 일치). `Radii.full`·`Wght.w500`·`Icons.north_east`·`c.warning`/`c.accent`/`c.textFaint` 전부 기존 토큰(app_theme 확인됨). 카피 문구 spec과 동일. ✓

## 범위 / 비목표

- 범위: `_dueBanner`·`_SourcePill` 시각 정리 + 여백 + DESIGN 기록.
- 비목표(YAGNI): due 계산/조건 변경, 출처 데이터, 카피, schedule_section, 다른 페이지 칩.

## 정본·관련

- 설계: `docs/superpowers/specs/2026-06-30-home-top-due-sources-design.md`(APPROVED)
- 코드: `lib/pages/home_page.dart`(`_dueBanner` L86·`dueIcon` 신규)·`lib/pages/home/hero_section.dart`(`_SourcePill` L79)
- 토큰: `lib/theme/app_theme.dart`(`Wght.w500` L225·`warning` L77/102), `DESIGN.md`(L97 칩 radius·L35 Wght)
- 함정: [[flutter-selectionarea-widget-test-pitfall]]·[[flutter-web-dogfood-browse]]·[[flutter-build-web-powershell]]
