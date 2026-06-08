# 모바일 햄버거 네비게이션 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 홈 상단 nav가 좁은 화면에서 잘리는 문제를 768px 미만 햄버거 드롭다운으로 해결한다.

**Architecture:** `_Header.build`에 `LayoutBuilder`를 끼워 가용 폭으로 분기 — ≥768px는 기존 `_NavLink` 나열, <768px는 새 `_NavMenuButton`(PopupMenuButton) 하나. 브랜드·테마 토글은 두 경우 모두 노출. `onNav` 맵을 두 경로가 공유하므로 새 상태·인자 없음.

**Tech Stack:** Flutter (Dart), flutter_test. 스펙: `docs/superpowers/specs/2026-06-08-mobile-hamburger-nav-design.md`

**작업 디렉터리:** 명령은 `flutter_app/`에서 실행.

---

### Task 1: `_NavMenuButton` + 반응형 분기

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` (`_Header` 클래스 109-148행, 새 위젯은 `_NavLink` 뒤에 추가)

- [ ] **Step 1: 실패하는 테스트 작성**

기존 파일에는 `_home()`(router + ThemeScope) 헬퍼와 필요한 import가 이미 있다. `main()` 끝에 아래 그룹을 추가한다(import 추가 불필요).

본문에도 '로드맵'·'모의고사' 같은 섹션 제목이 있어 `find.text`가 nav와 본문을 함께 잡을 수 있으므로, 햄버거 판별은 nav에만 유일한 `Icons.menu`로, 메뉴 열림은 항목 개수 증감(델타)으로 검증한다.

```dart
  group('_Header 반응형 nav', () {
    // _Header는 private이라 HomePage(라우터 '/')를 펌프해 헤더를 관찰한다.
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_home());
      await tester.pump();
    }

    testWidgets('좁은 폭(420): 햄버거 노출', (tester) async {
      await pumpAt(tester, 420);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('넓은 폭(1200): 햄버거 없음(링크 모드)', (tester) async {
      await pumpAt(tester, 1200);
      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('좁은 폭: 햄버거 탭 → 메뉴 항목(모의고사) 추가 노출', (tester) async {
      await pumpAt(tester, 420);
      final before = find.text('모의고사').evaluate().length;
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('모의고사').evaluate().length, before + 1);
    });
  });
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `cd flutter_app; flutter test test/home_sections_test.dart`
Expected: FAIL — 좁은 폭에서 `Icons.menu`가 없어 `findsOneWidget` 실패(현재는 링크가 오버플로로 그려짐). import 누락 시 컴파일 에러.

- [ ] **Step 3: `_NavMenuButton` 위젯 추가**

`home_page.dart`의 `_NavLink` 클래스 정의 바로 뒤(204행 부근)에 추가:

```dart
class _NavMenuButton extends StatelessWidget {
  const _NavMenuButton({required this.onNav});
  final Map<String, VoidCallback> onNav;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return PopupMenuButton<String>(
      tooltip: '메뉴',
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: c.border),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      onSelected: (key) => onNav[key]?.call(),
      itemBuilder: (context) => [
        for (final key in onNav.keys)
          PopupMenuItem<String>(
            value: key,
            child: Text(key,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.text)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.full),
          border: Border.all(color: c.border),
        ),
        child: Icon(Icons.menu, size: 18, color: c.textMuted),
      ),
    );
  }
}
```

- [ ] **Step 4: `_Header`에 반응형 분기 적용**

`_Header` 클래스에 브레이크포인트 상수를 추가한다. `preferredSize` getter 위(110행 부근)에:

```dart
  static const _navBreakpoint = 768.0;
```

`_Header.build`의 `Padding` 안 `Row`(128-140행)를 `LayoutBuilder`로 감싸 분기한다. 기존:

```dart
              child: Row(
                children: [
                  const _Brand(),
                  const Spacer(),
                  ...onNav.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: Gap.lg),
                      child: _NavLink(label: e.key, onTap: e.value),
                    ),
                  ),
                  const SizedBox(width: Gap.lg),
                  _ThemeToggle(isDark: isDark, onTap: onToggleTheme),
                ],
              ),
```

를 다음으로 교체:

```dart
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < _navBreakpoint;
                  return Row(
                    children: [
                      const _Brand(),
                      const Spacer(),
                      if (compact)
                        _NavMenuButton(onNav: onNav)
                      else
                        ...onNav.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(left: Gap.lg),
                            child: _NavLink(label: e.key, onTap: e.value),
                          ),
                        ),
                      const SizedBox(width: Gap.lg),
                      _ThemeToggle(isDark: isDark, onTap: onToggleTheme),
                    ],
                  );
                },
              ),
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `cd flutter_app; flutter test test/home_sections_test.dart`
Expected: PASS (신규 3개 포함)

- [ ] **Step 6: 전체 분석·테스트**

Run: `cd flutter_app; flutter analyze; flutter test`
Expected: analyze 이슈 0, 전체 PASS (회귀 없음)

- [ ] **Step 7: Commit**

```bash
git add flutter_app/lib/pages/home_page.dart flutter_app/test/home_sections_test.dart
git commit -m "feat: 모바일 햄버거 네비게이션 — 768px 미만 nav 드롭다운"
```

---

## Self-Review 결과

- **스펙 커버리지:** §3.1 브레이크포인트(768·LayoutBuilder)→Step 4 / §3.2 분기(브랜드·Spacer·테마토글 공통)→Step 4 / §3.3 `_NavMenuButton`(PopupMenuButton·알약 트리거·테마 토큰)→Step 3 / §3.4 onNav 공유→Step 4(새 상태 없음) / §4 테스트 3종→Step 1
- **플레이스홀더 스캔:** 없음
- **타입 일관성:** `_NavMenuButton({required Map<String, VoidCallback> onNav})`, `_navBreakpoint`(double 768.0), `constraints.maxWidth` 비교 — 전 Step 일관
- **주의:** `_NavLink`/`_ThemeToggle`/`_Brand`/`Radii`/`Gap`/`context.c`는 기존 파일에 존재(무변경 재사용). 테스트는 기존 `_home()`(router '/' + ThemeScope) 헬퍼를 재사용하므로 import 추가 불필요. 본문 섹션 제목과의 텍스트 충돌을 피하려 `Icons.menu`(nav 유일) + 항목 델타로 검증
- **본문 오버플로 리스크:** 좁은 폭에서 펌프 시 본문 다른 섹션이 오버플로 예외를 던질 수 있어 테스트 높이를 1400으로 넉넉히 잡음. 그래도 본문 Row가 좁은 폭에서 오버플로하면 별도 대응 필요(현재 범위 밖이나 실행 중 확인)
