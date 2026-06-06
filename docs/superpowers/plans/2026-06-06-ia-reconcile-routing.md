# IA 재조정 + URL 라우팅 구현 계획 (Spec 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 랜딩을 `content_index` 파생 뷰로 재조정하고 go_router(hash)로 모든 화면에 고유 URL을 부여해, 상단 메뉴/랜딩에서 실제 작업 콘텐츠에 도달하게 한다.

**Architecture:** `MaterialApp.router` + go_router 중첩 라우트. 라우트 빌더가 path param(code/taskId)→엔티티(Certification/ContentEntry)를 해석해 기존 페이지에 주입. 테마 토글 상태는 루트 `ThemeScope`(InheritedWidget)로 상향. 가짜 placeholder(studyDocs/exams)를 제거하고 랜딩 섹션을 콘텐츠 보유 여부 기반 하이브리드로 재작성.

**Tech Stack:** Flutter Web, go_router, GitHub Pages(base-href `/aws-docs/`, hash URL 전략 — 무설정 기본값).

**실행 환경:** 모든 명령은 `aws-docs/flutter_app/`에서 실행. 브랜치 `feat/ia-reconcile-routing` (이미 생성됨).

**스펙:** `docs/superpowers/specs/2026-06-06-ia-reconcile-routing-design.md`

---

## 파일 구조

| 파일 | 책임 | 작업 |
|---|---|---|
| `pubspec.yaml` | 의존성 | 수정(go_router 추가) |
| `lib/data/content_index.dart` | 콘텐츠 단일 소스 + 헬퍼 | 수정(`certHasContent`/`certContentSummary` 추가) |
| `lib/data/cert_lookup.dart` | code/taskId→엔티티 순수 해석 | 생성 |
| `lib/theme/theme_scope.dart` | 테마 토글 InheritedWidget | 생성 |
| `lib/app_router.dart` | go_router 설정(createRouter) + 에러 페이지 | 생성 |
| `lib/pages/cert_exam_page.dart` | 통합 모의고사 "준비 중" placeholder(Spec 2 예약) | 생성 |
| `lib/main.dart` | MaterialApp.router + ThemeScope 배선 | 수정 |
| `lib/pages/home_page.dart` | 네비 context.push, 랜딩 섹션 하이브리드 재작성, HomePage 시그니처 | 수정 |
| `lib/pages/cert_detail_page.dart` | Task 진입 context.push | 수정 |
| `lib/pages/study_doc_page.dart` | 퀴즈/시험 진입 context.push | 수정 |
| `lib/pages/exam_page.dart` | onExit context.pop | 수정 |
| `lib/models/certification.dart` | placeholder 모델 제거 | 수정 |
| `lib/data/site_data.dart` | placeholder 데이터 제거 | 수정 |
| `test/content_index_test.dart` | 헬퍼 테스트 | 생성 |
| `test/cert_lookup_test.dart` | 해석 테스트 | 생성 |
| `test/theme_scope_test.dart` | ThemeScope 테스트 | 생성 |
| `test/app_router_test.dart` | 라우트 해석·redirect 테스트 | 생성 |
| `test/home_sections_test.dart` | 랜딩 하이브리드 테스트 | 생성 |

---

## Task 1: go_router 의존성 추가

**Files:**
- Modify: `flutter_app/pubspec.yaml`

- [ ] **Step 1: pubspec.yaml에 go_router 추가**

`dependencies:` 블록의 `web: ^1.1.0` 아래 줄에 추가:

```yaml
  web: ^1.1.0
  go_router: ^16.0.0
```

- [ ] **Step 2: 패키지 받기**

Run: `flutter pub get`
Expected: 성공. `go_router` 및 전이 의존성 해결. (만약 SDK 제약으로 `^16.0.0`이 해결되지 않으면 `flutter pub add go_router`로 호환 버전 설치 후 그 버전으로 고정.)

- [ ] **Step 3: 분석으로 기준선 확인**

Run: `flutter analyze`
Expected: 신규 에러 없음(기존 상태 유지).

- [ ] **Step 4: 커밋**

```bash
git add flutter_app/pubspec.yaml flutter_app/pubspec.lock
git commit -m "build: add go_router dependency"
```

---

## Task 2: content_index 헬퍼 (certHasContent, certContentSummary)

**Files:**
- Modify: `flutter_app/lib/data/content_index.dart`
- Test: `flutter_app/test/content_index_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

Create `flutter_app/test/content_index_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  test('certHasContent: CLF-C02 true, 미보유/미지정 false', () {
    expect(certHasContent('CLF-C02'), isTrue);
    expect(certHasContent('SAA-C03'), isFalse);
    expect(certHasContent('NOPE'), isFalse);
  });

  test('certContentSummary: docs/questions 합산', () {
    final entries = contentFor('CLF-C02');
    var sum = 0;
    for (final e in entries) {
      sum += e.questionCount;
    }
    final s = certContentSummary('CLF-C02');
    expect(s.docs, entries.length);
    expect(s.questions, sum);
    expect(s.questions, greaterThan(0));
  });

  test('certContentSummary: 콘텐츠 없는 cert는 0', () {
    final s = certContentSummary('SAA-C03');
    expect(s.docs, 0);
    expect(s.questions, 0);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/content_index_test.dart`
Expected: FAIL — `certHasContent`/`certContentSummary` 미정의(컴파일 에러).

- [ ] **Step 3: 헬퍼 구현**

`flutter_app/lib/data/content_index.dart` 끝의 `contentFor` 함수 아래에 추가:

```dart
List<ContentEntry> contentFor(String certCode) =>
    kContentIndex[certCode] ?? const [];

/// 해당 자격증에 검증 콘텐츠(학습문서)가 존재하는가.
bool certHasContent(String certCode) => contentFor(certCode).isNotEmpty;

/// 랜딩 요약용: 학습문서 수 + 총 검증 문항 수.
({int docs, int questions}) certContentSummary(String certCode) {
  final entries = contentFor(certCode);
  var questions = 0;
  for (final e in entries) {
    questions += e.questionCount;
  }
  return (docs: entries.length, questions: questions);
}
```

(기존 `contentFor` 줄은 그대로 두고 그 아래에 두 함수만 추가.)

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/content_index_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/content_index.dart flutter_app/test/content_index_test.dart
git commit -m "feat(content): add certHasContent/certContentSummary helpers"
```

---

## Task 3: ThemeScope (테마 토글 InheritedWidget)

**Files:**
- Create: `flutter_app/lib/theme/theme_scope.dart`
- Test: `flutter_app/test/theme_scope_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

Create `flutter_app/test/theme_scope_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/theme_scope.dart';

void main() {
  testWidgets('ThemeScope.of 로 isDark/toggle 접근', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      ThemeScope(
        isDark: true,
        toggle: () => toggled = true,
        child: Builder(
          builder: (context) {
            final scope = ThemeScope.of(context);
            return MaterialApp(
              home: Scaffold(
                body: TextButton(
                  onPressed: scope.toggle,
                  child: Text(scope.isDark ? 'dark' : 'light'),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('dark'), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(toggled, isTrue);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/theme_scope_test.dart`
Expected: FAIL — `theme_scope.dart` / `ThemeScope` 미존재.

- [ ] **Step 3: ThemeScope 구현**

Create `flutter_app/lib/theme/theme_scope.dart`:

```dart
import 'package:flutter/material.dart';

/// 앱 전역 테마 토글 상태를 라우터 하위 페이지에 전달하는 InheritedWidget.
/// MaterialApp.router 상위에 배치되어 모든 라우트 페이지가 조상으로 접근 가능.
class ThemeScope extends InheritedWidget {
  const ThemeScope({
    super.key,
    required this.isDark,
    required this.toggle,
    required super.child,
  });

  final bool isDark;
  final VoidCallback toggle;

  static ThemeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => isDark != oldWidget.isDark;
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/theme_scope_test.dart`
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/theme/theme_scope.dart flutter_app/test/theme_scope_test.dart
git commit -m "feat(theme): add ThemeScope inherited widget for app-wide theme toggle"
```

---

## Task 4: cert_lookup 순수 해석 함수

**Files:**
- Create: `flutter_app/lib/data/cert_lookup.dart`
- Test: `flutter_app/test/cert_lookup_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

Create `flutter_app/test/cert_lookup_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cert_lookup.dart';

void main() {
  test('certByCode: 알려진 코드 해석, 미지정 null', () {
    expect(certByCode('CLF-C02')?.code, 'CLF-C02');
    expect(certByCode('NOPE'), isNull);
  });

  test('entryByTask: 알려진 Task 해석, 미지정/잘못된 cert null', () {
    expect(entryByTask('CLF-C02', 'clf-t1-1')?.taskId, 'clf-t1-1');
    expect(entryByTask('CLF-C02', 'clf-nope'), isNull);
    expect(entryByTask('NOPE', 'clf-t1-1'), isNull);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/cert_lookup_test.dart`
Expected: FAIL — `cert_lookup.dart` 미존재.

- [ ] **Step 3: 해석 함수 구현**

Create `flutter_app/lib/data/cert_lookup.dart`:

```dart
import '../models/certification.dart';
import 'content_index.dart';
import 'site_data.dart';

/// 라우트 param(code) → Certification. 미존재 시 null.
Certification? certByCode(String code) {
  for (final cert in certifications) {
    if (cert.code == code) return cert;
  }
  return null;
}

/// 라우트 param(code, taskId) → ContentEntry. 미존재 시 null.
ContentEntry? entryByTask(String code, String taskId) {
  for (final entry in contentFor(code)) {
    if (entry.taskId == taskId) return entry;
  }
  return null;
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/cert_lookup_test.dart`
Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/cert_lookup.dart flutter_app/test/cert_lookup_test.dart
git commit -m "feat(routing): add pure cert/task lookup resolvers"
```

---

## Task 5: CertExamPage placeholder (통합 모의고사 예약)

**Files:**
- Create: `flutter_app/lib/pages/cert_exam_page.dart`

- [ ] **Step 1: placeholder 페이지 작성**

Create `flutter_app/lib/pages/cert_exam_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/certification.dart';
import '../theme/app_theme.dart';

/// 통합 모의고사 진입점(Spec 2 예약). 본 스펙에선 "준비 중" 안내만.
class CertExamPage extends StatelessWidget {
  const CertExamPage({super.key, required this.cert});
  final Certification cert;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: c.border)),
        title: Text('${cert.title} · 통합 모의고사',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(Gap.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('통합 모의고사 준비 중', style: t.headlineSmall),
                const SizedBox(height: Gap.sm),
                Text(
                  '자격증 전체 문항 풀에서 출제하는 통합 모의고사는 곧 제공됩니다. '
                  '지금은 각 학습문서의 "시험처럼 풀기"로 Task별 시험을 응시할 수 있습니다.',
                  style: t.bodyMedium?.copyWith(color: c.textMuted),
                ),
                const SizedBox(height: Gap.xl),
                FilledButton(
                  onPressed: () => context.go('/cert/${cert.code}'),
                  child: const Text('학습 콘텐츠로 이동'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

Run: `flutter analyze lib/pages/cert_exam_page.dart`
Expected: 에러 없음.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/pages/cert_exam_page.dart
git commit -m "feat(exam): add cert-wide exam placeholder page (reserved for Spec 2)"
```

---

## Task 6: 라우터 전환 (app_router + main.dart + HomePage 시그니처 + 네비 마이그레이션)

이 Task는 라우팅으로의 원자적 전환이다. 커밋 시점에 트리가 컴파일·동작해야 하므로 모든 스텝을 끝낸 뒤 커밋한다.

**Files:**
- Create: `flutter_app/lib/app_router.dart`
- Modify: `flutter_app/lib/main.dart`
- Modify: `flutter_app/lib/pages/home_page.dart` (HomePage 시그니처 + cert 카드 네비)
- Modify: `flutter_app/lib/pages/cert_detail_page.dart` (Task 네비)
- Modify: `flutter_app/lib/pages/study_doc_page.dart` (퀴즈/시험 네비)
- Modify: `flutter_app/lib/pages/exam_page.dart` (onExit)
- Test: `flutter_app/test/app_router_test.dart`

- [ ] **Step 1: 실패하는 라우터 테스트 작성**

Create `flutter_app/test/app_router_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _app(String location) {
  final router = createRouter(initialLocation: location);
  return ThemeScope(
    isDark: false,
    toggle: () {},
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('"/" → 홈(브랜드 노출)', (tester) async {
    await tester.pumpWidget(_app('/'));
    await tester.pumpAndSettle();
    expect(find.text('AWS Docs Roadmap'), findsWidgets);
  });

  testWidgets('"/cert/CLF-C02" → 자격증 상세', (tester) async {
    await tester.pumpWidget(_app('/cert/CLF-C02'));
    await tester.pumpAndSettle();
    expect(find.text('AWS Certified Cloud Practitioner'), findsWidgets);
  });

  testWidgets('잘못된 코드 → 홈으로 redirect', (tester) async {
    await tester.pumpWidget(_app('/cert/NOPE'));
    await tester.pumpAndSettle();
    expect(find.text('AWS Docs Roadmap'), findsWidgets);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/app_router_test.dart`
Expected: FAIL — `app_router.dart` / `createRouter` 미존재.

- [ ] **Step 3: app_router.dart 작성**

Create `flutter_app/lib/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/cert_lookup.dart';
import 'pages/cert_detail_page.dart';
import 'pages/cert_exam_page.dart';
import 'pages/exam_page.dart';
import 'pages/home_page.dart';
import 'pages/quiz_page.dart';
import 'pages/study_doc_page.dart';
import 'theme/app_theme.dart';

/// go_router 설정. 웹 기본 hash 전략(무설정) → GitHub Pages 딥링크 동작.
/// 라우트 빌더가 path param을 엔티티로 해석해 기존 페이지에 주입한다.
GoRouter createRouter({String initialLocation = '/'}) => GoRouter(
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: <RouteBase>[
            GoRoute(
              path: 'cert/:code',
              redirect: (context, state) =>
                  certByCode(state.pathParameters['code']!) == null ? '/' : null,
              builder: (context, state) =>
                  CertDetailPage(cert: certByCode(state.pathParameters['code']!)!),
              routes: <RouteBase>[
                GoRoute(
                  path: 'exam',
                  builder: (context, state) =>
                      CertExamPage(cert: certByCode(state.pathParameters['code']!)!),
                ),
                GoRoute(
                  path: 'study/:taskId',
                  redirect: (context, state) => entryByTask(
                            state.pathParameters['code']!,
                            state.pathParameters['taskId']!,
                          ) ==
                          null
                      ? '/'
                      : null,
                  builder: (context, state) => StudyDocPage(
                    entry: entryByTask(
                      state.pathParameters['code']!,
                      state.pathParameters['taskId']!,
                    )!,
                  ),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'quiz',
                      builder: (context, state) => QuizPage(
                        entry: entryByTask(
                          state.pathParameters['code']!,
                          state.pathParameters['taskId']!,
                        )!,
                      ),
                    ),
                    GoRoute(
                      path: 'exam',
                      builder: (context, state) => ExamPage(
                        entry: entryByTask(
                          state.pathParameters['code']!,
                          state.pathParameters['taskId']!,
                        )!,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => _RouteErrorPage(),
    );

class _RouteErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('페이지를 찾을 수 없습니다.',
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: HomePage 시그니처를 ThemeScope 기반으로 변경**

`flutter_app/lib/pages/home_page.dart`:

(a) import 추가 — 파일 상단 import 블록에:

```dart
import 'package:go_router/go_router.dart';

import '../data/content_index.dart';
import '../data/site_data.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';
import '../theme/theme_scope.dart';
import 'cert_detail_page.dart';
```

(기존 import 중 누락분만 추가. `cert_detail_page.dart` import는 §Step 7에서 제거하지 않는다 — `CertDetailPage` 직접 참조는 사라지지만 해롭지 않음. 단 분석 경고가 나면 제거.)

(b) `HomePage` 생성자에서 `isDark`/`onToggleTheme` 제거:

기존:
```dart
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}
```

변경 후:
```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
```

(c) `_HomePageState.build`의 `appBar:` 에서 ThemeScope 사용:

기존:
```dart
      appBar: _Header(
        isDark: widget.isDark,
        onToggleTheme: widget.onToggleTheme,
        onNav: {
```

변경 후:
```dart
      appBar: _Header(
        isDark: ThemeScope.of(context).isDark,
        onToggleTheme: ThemeScope.of(context).toggle,
        onNav: {
```

- [ ] **Step 5: home_page cert 카드 네비를 context.push로**

`flutter_app/lib/pages/home_page.dart` `_CertCard`:

기존:
```dart
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CertDetailPage(cert: cert))),
```

변경 후:
```dart
      onTap: () => context.push('/cert/${cert.code}'),
```

- [ ] **Step 6: cert_detail Task 네비를 context.push로**

`flutter_app/lib/pages/cert_detail_page.dart`:

(a) import 추가(상단 import 블록):
```dart
import 'package:go_router/go_router.dart';
```

(b) `_LearningContent`의 Task 카드 onTap:

기존:
```dart
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudyDocPage(entry: e))),
```

변경 후:
```dart
                onTap: () =>
                    context.push('/cert/${e.certCode}/study/${e.taskId}'),
```

(`StudyDocPage` import(`import 'study_doc_page.dart';`)는 직접 참조가 사라지면 분석 경고가 날 수 있다. 경고 시 제거.)

- [ ] **Step 7: study_doc 퀴즈/시험 네비를 context.push로**

`flutter_app/lib/pages/study_doc_page.dart`:

(a) import 추가:
```dart
import 'package:go_router/go_router.dart';
```

(b) `_StartQuizButton`의 두 onTap:

기존:
```dart
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => QuizPage(entry: entry))),
```
변경 후:
```dart
          onTap: () => context.push(
              '/cert/${entry.certCode}/study/${entry.taskId}/quiz'),
```

기존:
```dart
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ExamPage(entry: entry))),
```
변경 후:
```dart
          onTap: () => context.push(
              '/cert/${entry.certCode}/study/${entry.taskId}/exam'),
```

(`exam_page.dart`/`quiz_page.dart` import는 직접 참조가 사라지면 경고 가능 — 단 `quiz_page`/`exam_page`는 다른 곳에서 쓰지 않으므로 경고 시 제거.)

- [ ] **Step 8: exam_page onExit를 context.pop으로**

`flutter_app/lib/pages/exam_page.dart`:

(a) import 추가:
```dart
import 'package:go_router/go_router.dart';
```

(b) `onExit`:

기존:
```dart
                onExit: () => Navigator.of(context).maybePop(),
```
변경 후:
```dart
                onExit: () => context.pop(),
```

- [ ] **Step 9: main.dart를 MaterialApp.router + ThemeScope로 전환**

`flutter_app/lib/main.dart` 전체를 아래로 교체:

```dart
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_scope.dart';

void main() => runApp(const AwsDocsApp());

class AwsDocsApp extends StatefulWidget {
  const AwsDocsApp({super.key});

  @override
  State<AwsDocsApp> createState() => _AwsDocsAppState();
}

class _AwsDocsAppState extends State<AwsDocsApp> {
  // Light is the default theme (DESIGN.md); dark is a toggle.
  ThemeMode _mode = ThemeMode.light;
  final _router = createRouter();

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      isDark: _mode == ThemeMode.dark,
      toggle: _toggleTheme,
      child: MaterialApp.router(
        title: 'AWS Docs Roadmap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _mode,
        routerConfig: _router,
      ),
    );
  }
}
```

- [ ] **Step 10: 라우터 테스트 통과 확인**

Run: `flutter test test/app_router_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 11: 회귀 — 전체 테스트**

Run: `flutter test`
Expected: 전부 PASS. 특히 `widget_test.dart`(브랜드+CLF-C02, 테마 토글)가 그대로 통과해야 한다(`MaterialApp.router`도 `MaterialApp`, 토글은 ThemeScope 경유).
만약 `widget_test.dart`의 `find.byType(MaterialApp)`/토글이 실패하면 systematic-debugging으로 원인 분석 후 수정(추측 금지).

- [ ] **Step 12: 분석**

Run: `flutter analyze`
Expected: 에러 없음. 미사용 import 경고가 있으면 해당 import 제거 후 재실행.

- [ ] **Step 13: 커밋**

```bash
git add flutter_app/lib/app_router.dart flutter_app/lib/main.dart flutter_app/lib/pages/home_page.dart flutter_app/lib/pages/cert_detail_page.dart flutter_app/lib/pages/study_doc_page.dart flutter_app/lib/pages/exam_page.dart flutter_app/test/app_router_test.dart
git commit -m "feat(routing): wire go_router (hash) with MaterialApp.router + ThemeScope"
```

---

## Task 7: 랜딩 하이브리드 재작성 + placeholder 데이터 제거

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` (`_StudyDocsSection`, `_ExamsSection`, `_DocItem` 제거)
- Modify: `flutter_app/lib/models/certification.dart` (StudyDoc/PracticeExam/studyDocs/exams 제거)
- Modify: `flutter_app/lib/data/site_data.dart` (`_examSets`/studyDocs/exams 제거)
- Test: `flutter_app/test/home_sections_test.dart`

- [ ] **Step 1: 실패하는 섹션 테스트 작성**

Create `flutter_app/test/home_sections_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/app_router.dart';
import 'package:aws_docs/theme/theme_scope.dart';

Widget _home() {
  final router = createRouter(initialLocation: '/');
  return ThemeScope(
    isDark: false,
    toggle: () {},
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('학습문서 섹션: CLF-C02 요약 카드 + 준비 중 그룹', (tester) async {
    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    // 콘텐츠 보유 자격증 요약 카드.
    expect(find.textContaining('검증 학습문서'), findsWidgets);
    // 콘텐츠 없는 자격증은 "준비 중" 그룹에 코드 칩으로.
    expect(find.text('준비 중'), findsWidgets);
    expect(find.text('SAA-C03'), findsWidgets);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/home_sections_test.dart`
Expected: FAIL — 아직 "검증 학습문서"/"준비 중" 문구 없음(기존 placeholder 렌더).

- [ ] **Step 3: `_StudyDocsSection`/`_ExamsSection` 재작성 + `_DocItem` 제거**

`flutter_app/lib/pages/home_page.dart`에서 기존 `_StudyDocsSection`(`// ─ Study docs` 주석부터 `_DocItem` 끝까지)과 `_ExamsSection`(`// ─ Exams` 블록)을 아래로 교체:

```dart
// ─────────────────────────────────────────────────────────── Study docs

class _StudyDocsSection extends StatelessWidget {
  const _StudyDocsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final withContent =
        certifications.where((c) => certHasContent(c.code)).toList();
    final pending =
        certifications.where((c) => !certHasContent(c.code)).toList();
    return _Band(
      title: '상세 학습 문서',
      meta: '검증된 학습 콘텐츠',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in withContent)
                _ContentCertCard(
                  cert: cert,
                  summaryLabel: () {
                    final s = certContentSummary(cert.code);
                    return '검증 학습문서 ${s.docs} · 총 ${s.questions}문항';
                  }(),
                  cta: '학습문서 보기 →',
                  onTap: () => context.push('/cert/${cert.code}'),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            _PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────── Exams

class _ExamsSection extends StatelessWidget {
  const _ExamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final withContent =
        certifications.where((c) => certHasContent(c.code)).toList();
    final pending =
        certifications.where((c) => !certHasContent(c.code)).toList();
    return _Band(
      title: '학습 문서 기반 모의고사',
      meta: '검증 문항 기반',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gap.lg,
            runSpacing: Gap.lg,
            children: [
              for (final cert in withContent)
                _ContentCertCard(
                  cert: cert,
                  summaryLabel: '통합 모의고사 · 준비 중',
                  cta: '모의고사 →',
                  onTap: () => context.push('/cert/${cert.code}/exam'),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: Gap.lg),
            _PendingGroup(certs: pending),
          ],
        ],
      ),
    );
  }
}

/// 콘텐츠 보유 자격증 진입 카드(학습문서/모의고사 공용).
class _ContentCertCard extends StatelessWidget {
  const _ContentCertCard({
    required this.cert,
    required this.summaryLabel,
    required this.cta,
    required this.onTap,
  });
  final Certification cert;
  final String summaryLabel;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cert.title, style: t.titleMedium),
            const SizedBox(height: Gap.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(Radii.full),
              ),
              child: Text(summaryLabel,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.textMuted)),
            ),
            const SizedBox(height: Gap.md),
            Text(cta,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: c.accent)),
          ],
        ),
      ),
    );
  }
}

/// 콘텐츠 미보유 자격증을 "준비 중" 코드 칩으로 묶음.
class _PendingGroup extends StatelessWidget {
  const _PendingGroup({required this.certs});
  final List<Certification> certs;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('준비 중',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: c.textMuted)),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final cert in certs) _Chip(label: cert.code)],
          ),
        ],
      ),
    );
  }
}
```

(주의: 기존 `_DocItem` 클래스는 위 교체로 삭제된다. `_Chip` 위젯은 파일 하단 Shared 영역에 이미 존재하므로 재사용.)

- [ ] **Step 4: certification.dart에서 placeholder 모델 제거**

`flutter_app/lib/models/certification.dart`:

(a) `StudyDoc` 클래스(`class StudyDoc { ... }` 전체)와 `PracticeExam` 클래스(`class PracticeExam { ... }` 전체) 삭제.

(b) `Certification` 생성자에서 두 줄 삭제:
```dart
    required this.studyDocs,
    required this.exams,
```

(c) `Certification` 필드에서 두 줄 삭제:
```dart
  final List<StudyDoc> studyDocs;
  final List<PracticeExam> exams;
```

- [ ] **Step 5: site_data.dart에서 placeholder 데이터 제거**

`flutter_app/lib/data/site_data.dart`:

(a) `_examSets` 함수 전체 삭제:
```dart
List<PracticeExam> _examSets(String prefix) => List.generate(6, (index) {
      return PracticeExam(
        title: '$prefix 모의고사 ${index + 1}회차',
        scenario: index.isEven
            ? '공식 시험 가이드의 도메인 비중을 따라 시나리오형 문항으로 구성합니다.'
            : '실무 상황을 제시하고 가장 적절한 AWS 서비스와 설계 판단을 고르게 합니다.',
        checks: const [
          '정답뿐 아니라 오답 제거 근거를 기록',
          '도메인별 취약 영역 태깅',
          '재응시 전 관련 상세 학습 문서로 회귀',
        ],
      );
    });
```

(b) 12개 `Certification(...)` 리터럴 각각에서 `studyDocs: const [ ... ],` 블록과 `exams: _examSets('...'),` 줄을 삭제. (각 cert에서 `roadmap:` 다음의 `studyDocs:` 블록 시작부터 `exams: _examSets(...),`까지 제거. `roadmap` 블록과 닫는 `),`는 유지.)

예 — Cloud Practitioner(첫 cert) 변경 후 형태:
```dart
  Certification(
    id: 'cloud-practitioner',
    level: Level.foundational,
    title: 'AWS Certified Cloud Practitioner',
    code: 'CLF-C02',
    audience: 'AWS를 처음 시작하는 학습자와 비기술/기술 공통 입문자',
    focus: const ['클라우드 개념', '보안과 규정 준수', '기술 개요', '요금과 지원'],
    roadmap: const [
      '클라우드 가치 제안과 AWS 글로벌 인프라를 정리합니다.',
      'IAM, 공동 책임 모델, 기본 보안 제어를 학습합니다.',
      'EC2, S3, RDS, VPC, Lambda의 역할을 구분합니다.',
      '요금, 지원 플랜, 비용 관리 도구를 문제풀이로 확인합니다.',
    ],
  ),
```

12개 전부 동일 패턴으로 `studyDocs`/`exams` 제거.

- [ ] **Step 6: 섹션 테스트 통과 확인**

Run: `flutter test test/home_sections_test.dart`
Expected: PASS.

- [ ] **Step 7: 회귀 — 전체 테스트 + 분석**

Run: `flutter test`
Expected: 전부 PASS.

Run: `flutter analyze`
Expected: 에러 없음. (placeholder 제거로 `home_page.dart`/`cert_detail_page.dart`의 일부 import가 미사용이 되면 제거.)

- [ ] **Step 8: 커밋**

```bash
git add flutter_app/lib/pages/home_page.dart flutter_app/lib/models/certification.dart flutter_app/lib/data/site_data.dart flutter_app/test/home_sections_test.dart
git commit -m "feat(home): rebuild study/exam sections from content_index; drop placeholder data"
```

---

## Task 8: 통합 검증 (analyze + test + 웹 빌드)

**Files:** 없음(검증 전용).

- [ ] **Step 1: 정적 분석**

Run: `flutter analyze`
Expected: "No issues found!" (경고 포함 0). 경고가 있으면 해당 파일에서 제거/수정.

- [ ] **Step 2: 전체 테스트**

Run: `flutter test`
Expected: 모든 테스트 PASS(신규 5파일 + 기존 8파일).

- [ ] **Step 3: 릴리스 웹 빌드(배포 동등 명령)**

Run: `flutter build web --release --base-href /aws-docs/`
Expected: 빌드 성공, `build/web` 생성. (CI와 동일 플래그로 회귀 없음 확인.)

- [ ] **Step 4: 수동 확인 체크리스트(로컬 빌드 결과 또는 `flutter run -d chrome`)**

다음을 눈으로 확인(자동 테스트로 못 잡는 흐름):
- 홈 상단 메뉴 "학습 문서" → 스크롤된 섹션에 CLF-C02 "검증 학습문서 …" 카드 + "준비 중" 그룹.
- CLF-C02 카드 클릭 → URL `…/aws-docs/#/cert/CLF-C02`, 상세 페이지 진입.
- Task → 학습문서(`#/cert/CLF-C02/study/clf-t1-1`) → "연습 문제 풀기"/"시험처럼 풀기" 진입 + URL 갱신.
- 브라우저 뒤로가기로 단계별 복귀.
- 상단 메뉴 "모의고사" → CLF-C02 "통합 모의고사 · 준비 중" 카드 → `#/cert/CLF-C02/exam` 준비 중 페이지.
- 새로고침(F5)에서 현재 딥링크 유지.

- [ ] **Step 5: (선택) 최종 정리 커밋**

Step 1~3에서 수정이 있었다면:
```bash
git add -A
git commit -m "chore: resolve analyzer warnings post-routing"
```

---

## Self-Review (작성자 점검 완료)

**1. 스펙 커버리지:**
- §3 라우트 트리 → Task 6(app_router). 예약 `/cert/:code/exam` → Task 5(CertExamPage) + Task 6(라우트).
- §4 데이터 단일화(헬퍼/제거) → Task 2(헬퍼), Task 7(제거).
- §5 랜딩 하이브리드 + delegate → Task 7.
- §6 네비 마이그레이션 + 테마 상향 → Task 6.
- §7 엣지(redirect/준비중) → Task 6(redirect), Task 5(준비중 페이지).
- §8 테스트/의존성 → Task 1(go_router), Task 2·3·4·6·7(테스트), Task 8(회귀/빌드). widget_test는 무변경·회귀 검증.
- §9 범위 밖(통합 모의고사 구현) → 미포함(의도).

**2. 플레이스홀더 스캔:** 모든 코드 스텝에 실제 코드 포함. "TBD/추후" 없음. site_data 12개 cert 제거는 패턴+예시 제시.

**3. 타입 일관성:** `createRouter({initialLocation})`·`certByCode`·`entryByTask`·`certHasContent`·`certContentSummary(→({int docs,int questions}))`·`ThemeScope.of(...).isDark/toggle`·`_ContentCertCard(summaryLabel/cta/onTap)`·`_PendingGroup(certs)` — 정의와 사용 일치 확인.

**알려진 잔여 리스크(실행 중 확인):**
- go_router 버전(`^16.0.0`)이 SDK와 안 맞으면 `flutter pub add go_router`로 해석된 버전 사용. `pathParameters` 접근자는 현행 메이저(7~16)에서 동일.
- 미사용 import 경고는 Task 6/7 분석 단계에서 정리.
