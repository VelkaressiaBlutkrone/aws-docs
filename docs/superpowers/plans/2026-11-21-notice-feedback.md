# 공지·피드백(D2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 비공개 테스트 14일 동안 테스터가 앱 안에서 의견(문항 오류 신고 포함)을 보내고 운영자 공지를 읽을 수 있게 한다.

**Architecture:** 공지는 번들 자산(`assets/notices.json`)이고 읽음 상태만 로컬 KV 에 둔다. 피드백은 기존 규칙이 이미 허용하는 `users/{uid}/feedback/{id}` 에 기존 `CloudStore` 추상화로 쓴다. **Firestore 규칙을 바꾸지 않는다.** 계정 삭제가 피드백까지 지우도록 「동기하는 컬렉션」과 「사용자 소유 컬렉션」을 두 상수로 가른다.

**Tech Stack:** Flutter(Dart) · go_router · cloud_firestore(기존) · `rootBundle` 자산 로딩 · 의존성 **추가 없음**

**Spec:** `docs/superpowers/specs/2026-11-21-notice-feedback-design.md`

## Global Constraints

- 게이트: `cd flutter_app && flutter test`(전부 통과) · `flutter analyze`(**0건**). 착수 시점 기준선은 **4,611 통과 / analyze 0**이고, 각 Task 커밋 메시지에 그 Task 의 증가분을 **실측값으로** 적는다(예측값을 적지 않는다).
- **실패 테스트 선작성**(레포 절대 조건 2). 테스트 없는 구현 변경을 금지한다.
- **Firestore 규칙 파일(`firestore.rules`)을 수정하지 않는다.** 수정하면 사용자의 콘솔 배포가 필요해져 설계 §4-1 의 반목표를 위반한다.
- **의존성을 추가하지 않는다**(`pubspec.yaml` 의 `dependencies:` 블록 불변). 앱 버전은 Task 5 의 상수로 얻는다.
- 시각 직렬화는 **`createdAtMs`(UTC epoch ms, `int`)** — 이 레포는 Firestore `Timestamp` 를 쓰지 않는다.
- 카피는 **합니다체**이고 개발자 어휘(엔진·런타임·엔트리포인트)를 노출하지 않는다(`DESIGN.md` Voice).
- **새 색 토큰을 만들지 않는다.** 경고·실패 문구는 `warningText`/`surface2` 쌍을 쓴다(`theme_contrast_test` 가 이미 AA 로 단정한다).
- 새 인터랙티브 요소는 `TouchTarget`(48dp 탭 영역) **바깥**에 `FocusRing` 이 들어가지 않게 — `TouchTarget` 이 `FocusRing` 을 감싼다.
- 새 스크롤 뷰는 하단 패딩에 **`scrollBottomInset(context)`**, 상단에 `headerScrollInset(context)` 를 쓴다(둘 다 `lib/widgets/app_header.dart`, **Scaffold body 아래 컨텍스트**에서 호출).
- 새 비동기 페이지는 `lib/widgets/state_views.dart` 의 **`LoadingView(label:)` / `EmptyView` / `ErrorView`** 만 쓴다(페이지별 임의 로딩 표시 금지).
- 공지 본문·피드백 본문은 **평문**이다 — 마크다운 링크 `[x](y)` 와 단일 `*이탤릭*` 을 쓰지 않는다(렌더 경로가 평문 `Text`).
- 브랜치: `develop` 에서 `feat/d2-notice-feedback` 를 분기한다. **커밋 직전마다 `git branch --show-current` 로 의도한 브랜치인지 확인한다**(레포 절대 조건 5 — 공유 워킹트리).

## 확정 카피

테스트가 이 문구를 그대로 단정하므로 **구현자가 바꾸지 않는다**(바꾸려면 이 표와 테스트를 함께 고친다). `DESIGN.md` Voice 의 상태 카피 패턴과 due 배너의 기존 어투(「지난 일정 N개」)를 따랐다.

| 자리 | 문구 |
|---|---|
| 공지 로딩 | `공지를 불러오고 있습니다…` |
| 공지 빈 상태 | `아직 공지가 없습니다` |
| 홈 배너 | `새 공지 N개` (N 은 숫자) |
| 메뉴 항목 | `공지` · `의견 보내기` |
| 의견 로딩 | `보낸 의견을 불러오고 있습니다…` |
| 의견 빈 상태 | `아직 보낸 의견이 없습니다` |
| 전송 성공(`sent`) | `의견을 보냈습니다.` |
| 전송 대기(`queued`) | `의견을 저장했습니다 — 네트워크가 연결되면 올라갑니다.` |
| 전송 실패(`failed`) | `의견을 보내지 못했습니다.` + 보조 `네트워크가 잠시 불안정했을 수 있습니다. 다시 시도하면 대부분 해결됩니다.` |
| 비로그인 안내 | `의견을 보내려면 Google 로그인이 필요합니다.` |
| 서비스 미설정 | `의견 보내기는 지금 사용할 수 없습니다.` |
| 보기 지목 유도 | `어느 보기인지 내용을 그대로 적어 주시면 더 빠릅니다.` |
| 학습문서 오류 안내 | `어느 학습 문서인지 함께 적어 주세요.` |

## Review Focus

스펙이 암시하지만 어느 Task 의 본 테스트도 다루지 않아, 사람을 물 가능성이 높은 입력 다섯. 각 줄의 테스트를 담당 Task 에 붙였다.

1. **`notices.json` 이 손상된 JSON 이거나 빈 배열일 때** — 공지 화면이 깨지거나 앱이 죽어서는 안 된다. 빈 배열은 **초기 상태**다. → Task 1 Step 1·Task 3 Step 1
2. **피드백 본문이 비었거나 2000자를 넘을 때** — 빈 전송을 막지 않으면 빈 문서가 쌓이고, 상한이 없으면 운영자가 읽을 수 없는 문서가 들어온다. → Task 6 Step 1
3. **폼을 열어 둔 채 다른 탭·기기에서 로그아웃했을 때** — 전송 시점에 `uid` 가 `null` 이면 조용히 사라지지 않고 「로그인이 필요합니다」로 떨어져야 한다. → Task 6 Step 1
4. **공지 `id` 가 중복이거나 `date` 가 내림차순이 아닐 때** — 콘텐츠 규율 위반은 **가드가 레드로 잡고**, 런타임은 그래도 안전하게 흡수해야 한다(읽음 기준이 깨져 전 기기 배너가 되살아나는 것이 더 나쁜 실패다). → Task 1 Step 1(가드) · Task 2 Step 1(흡수)
5. **전송 버튼이 두 번 눌렸을 때** — 같은 의견이 두 문서로 들어오면 운영자가 중복을 읽는다. 전송 중에는 버튼이 비활성이어야 한다. → Task 6 Step 1

## File Structure

| 파일 | 책임 |
|---|---|
| `flutter_app/assets/notices.json` | 공지 데이터(번들). 초기값은 빈 배열 `[]` |
| `flutter_app/lib/models/notice.dart` | `Notice` 값 객체 + `fromJson` |
| `flutter_app/lib/data/notices.dart` | 자산 로딩 · 읽음 상태 계산 · 읽음 표시 |
| `flutter_app/lib/app_version.dart` | `kAppVersion` 상수(pubspec 과 가드로 동기) |
| `flutter_app/lib/data/cloud/feedback_service.dart` | 피드백 전송 · 내 의견 조회 · 전송 결과 3분기 |
| `flutter_app/lib/data/cloud/synced_collections.dart` (수정) | `kSyncedCollections`(동기) + `kUserOwnedCollections`(삭제 범위) |
| `flutter_app/lib/pages/notices_page.dart` | 공지 목록 화면 |
| `flutter_app/lib/pages/feedback_page.dart` | 피드백 폼 + 내 의견 목록 + 비로그인 안내 |
| `flutter_app/lib/content/quiz_widgets.dart` (수정) | `ResultCard`·`ResultsView` 에 `onReport` 콜백 |

---

### Task 1: 공지 데이터 계층

**Files:**
- Create: `flutter_app/assets/notices.json` (내용 `[]`)
- Create: `flutter_app/lib/models/notice.dart`
- Create: `flutter_app/lib/data/notices.dart`
- Modify: `flutter_app/pubspec.yaml` (`assets:` 목록에 `- assets/notices.json` 한 줄)
- Test: `flutter_app/test/notices_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces:
  - `class Notice { final String id; final String date; final String title; final String body; factory Notice.fromJson(Map<String, dynamic>) }`
  - `typedef AssetStringLoader = Future<String> Function(String key);` — 이미 `lib/data/question_banks.dart` 에 있으므로 **재정의하지 않고 import 한다**
  - `Future<List<Notice>> loadNotices({AssetStringLoader? loadString})` — 자산 키는 `'assets/notices.json'`. 파싱 실패·키 부재는 **빈 목록**으로 degrade 한다(던지지 않는다)

- [ ] **Step 1: 실패 테스트 작성**

```dart
// test/notices_test.dart
test('정상 JSON 을 최신 먼저 순서대로 읽는다', () async {
  final list = await loadNotices(loadString: (_) async => '''
    [{"id":"n-20261202-01","date":"2026-12-02","title":"두 번째","body":"본문2"},
     {"id":"n-20261201-01","date":"2026-12-01","title":"첫 번째","body":"본문1"}]''');
  expect(list.map((n) => n.id).toList(),
      ['n-20261202-01', 'n-20261201-01']);
  expect(list.first.title, '두 번째');
});

// Review Focus 1
test('빈 배열은 빈 목록이다', () async {
  expect(await loadNotices(loadString: (_) async => '[]'), isEmpty);
});

test('손상된 JSON 은 던지지 않고 빈 목록이다', () async {
  expect(await loadNotices(loadString: (_) async => '{not json'), isEmpty);
});

test('자산이 없어도 던지지 않는다', () async {
  expect(await loadNotices(loadString: (_) async => throw Exception('404')), isEmpty);
});

// 대조군 — 실제 번들 자산이 파싱된다(로더가 보는 키가 맞는지)
testWidgets('번들 자산이 파싱된다', (tester) async {
  expect(await loadNotices(), isA<List<Notice>>());
});

// Review Focus 4 (가드) — 콘텐츠 규율: id 유일 · date 형식 · 내림차순 · 평문
testWidgets('번들 공지가 콘텐츠 규율을 지킨다', (tester) async {
  final list = await loadNotices();
  final ids = list.map((n) => n.id).toList();
  expect(ids.toSet().length, ids.length, reason: 'id 가 중복이다');
  for (final n in list) {
    expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(n.date), isTrue);
    expect(RegExp(r'^n-\d{8}-\d{2}$').hasMatch(n.id), isTrue);
    expect(n.title.trim(), isNotEmpty);
    expect(n.body.trim(), isNotEmpty);
    expect(RegExp(r'\[[^\]]+\]\([^)]+\)').hasMatch(n.body), isFalse,
        reason: '본문은 평문이다 — 마크다운 링크를 쓰지 않는다');
  }
  final dates = list.map((n) => n.date).toList();
  final sorted = [...dates]..sort((a, b) => b.compareTo(a));
  expect(dates, sorted, reason: 'date 내림차순이어야 한다(최신 먼저)');
});

// pubspec 선언 — 2026-11-14 라이브 404 선례
test('pubspec 이 notices.json 을 선언한다', () {
  expect(File('pubspec.yaml').readAsStringSync(),
      contains('- assets/notices.json'));
});
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/notices_test.dart`
Expected: FAIL — `Notice`·`loadNotices` 가 없어 컴파일되지 않는다

- [ ] **Step 3: `Notice` 와 `loadNotices` 구현**

`lib/models/notice.dart` 에 값 객체를, `lib/data/notices.dart` 에 `loadNotices` 를 만든다. 로더는 `question_banks.dart` 의 패턴을 따른다 — `loadString ?? rootBundle.loadString`, `try/catch` 로 실패를 빈 목록으로 흡수. `assets/notices.json` 에 `[]` 를 쓰고 pubspec 에 한 줄 더한다.

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/notices_test.dart`
Expected: PASS

- [ ] **Step 5: 커밋**

```bash
git branch --show-current   # feat/d2-notice-feedback 인지 확인
git add flutter_app/assets/notices.json flutter_app/lib/models/notice.dart flutter_app/lib/data/notices.dart flutter_app/pubspec.yaml flutter_app/test/notices_test.dart
git commit -m "feat(notices): 공지 데이터 계층 — 번들 자산 로더와 콘텐츠 규율 가드"
```

---

### Task 2: 공지 읽음 상태

**Files:**
- Modify: `flutter_app/lib/data/notices.dart`
- Test: `flutter_app/test/notices_test.dart` (그룹 추가)

**Interfaces:**
- Consumes: Task 1 의 `Notice`, `loadNotices`
- Produces:
  - `const kNoticeReadUpToKey = 'notices.readUpTo';`
  - `int unreadCount(List<Notice> notices, KvBackend backend)` — 저장된 id **뒤에 온** 공지 수
  - `void markAllRead(List<Notice> notices, KvBackend backend)` — 최신 id 를 저장한다. 목록이 비면 아무것도 쓰지 않는다

- [ ] **Step 1: 실패 테스트 작성**

```dart
// Review Focus 4 (런타임 흡수) + 설계 §7-1 폴백 둘
group('공지 읽음 상태', () {
  final a = Notice(id: 'n-20261203-01', date: '2026-12-03', title: 't3', body: 'b');
  final b = Notice(id: 'n-20261202-01', date: '2026-12-02', title: 't2', body: 'b');
  final c = Notice(id: 'n-20261201-01', date: '2026-12-01', title: 't1', body: 'b');
  final all = [a, b, c]; // 최신 먼저

  test('신규 설치(키 없음)는 전부 읽음이다', () {
    expect(unreadCount(all, MemoryBackend()), 0);
  });

  test('저장된 id 뒤에 온 공지만 센다', () {
    final kv = MemoryBackend()..write(kNoticeReadUpToKey, c.id);
    expect(unreadCount(all, kv), 2);
  });

  test('최신을 읽었으면 0 이다', () {
    final kv = MemoryBackend()..write(kNoticeReadUpToKey, a.id);
    expect(unreadCount(all, kv), 0);
  });

  test('번들에 없는 id 는 전부 읽음으로 흡수한다', () {
    final kv = MemoryBackend()..write(kNoticeReadUpToKey, 'n-20250101-99');
    expect(unreadCount(all, kv), 0);
  });

  test('빈 공지 목록은 0 이고 markAllRead 가 아무것도 쓰지 않는다', () {
    final kv = MemoryBackend();
    expect(unreadCount(const [], kv), 0);
    markAllRead(const [], kv);
    expect(kv.read(kNoticeReadUpToKey), isNull);
  });

  test('markAllRead 뒤에는 0 이다', () {
    final kv = MemoryBackend()..write(kNoticeReadUpToKey, c.id);
    markAllRead(all, kv);
    expect(kv.read(kNoticeReadUpToKey), a.id);
    expect(unreadCount(all, kv), 0);
  });
});
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/notices_test.dart`
Expected: FAIL — `unreadCount`·`markAllRead` 미정의

- [ ] **Step 3: `unreadCount`·`markAllRead` 구현**

`notices.dart` 에 더한다. `unreadCount` 는 저장값의 **인덱스를 목록에서 찾아** 그 앞의 개수를 돌려주고, 키가 없거나 인덱스를 찾지 못하면 **0**(전부 읽음)이다.

- [ ] **Step 4: 통과 확인** → `flutter test test/notices_test.dart` PASS

- [ ] **Step 5: 커밋**

```bash
git commit -m "feat(notices): 읽음 상태 — 신규 설치·사라진 id 는 전부 읽음으로 흡수"
```

---

### Task 3: 공지 화면·라우트·메뉴 진입점

**Files:**
- Create: `flutter_app/lib/pages/notices_page.dart`
- Modify: `flutter_app/lib/app_router.dart` (`/notices` 라우트)
- Modify: `flutter_app/lib/pages/home/home_header.dart` (메뉴 항목)
- Test: `flutter_app/test/notices_page_test.dart`
- Modify: `flutter_app/test/scroll_bottom_inset_test.dart` · `flutter_app/test/korean_line_break_survey_test.dart` (라우트 표에 추가)

**Interfaces:**
- Consumes: Task 1·2 전부
- Produces: `class NoticesPage extends StatefulWidget { const NoticesPage({super.key, KvBackend? backend, AssetStringLoader? loadString}) }` — **테스트 주입구 둘**(레포 관례: 주입구가 없으면 테스트가 심은 상태를 페이지가 못 본다)

- [ ] **Step 1: 실패 테스트 작성**

```dart
// 테스트 둘이 쓰는 고정 입력 — 최신 먼저
const _two = '''
[{"id":"n-20261202-01","date":"2026-12-02","title":"두 번째","body":"본문2"},
 {"id":"n-20261201-01","date":"2026-12-01","title":"첫 번째","body":"본문1"}]''';

// Review Focus 1 — 빈 공지에서 화면이 정상이다
testWidgets('공지가 없으면 빈 상태 문구를 보인다', (tester) async {
  await _pumpNotices(tester, json: '[]');
  expect(find.text('아직 공지가 없습니다'), findsOneWidget);
});

testWidgets('공지를 최신 먼저 카드로 그린다', (tester) async {
  await _pumpNotices(tester, json: _two);
  expect(find.text('두 번째'), findsOneWidget);
  expect(find.text('본문1'), findsOneWidget);
});

testWidgets('화면을 열면 최신 id 로 읽음 표시된다', (tester) async {
  final kv = MemoryBackend()..write(kNoticeReadUpToKey, 'n-20261201-01');
  await _pumpNotices(tester, json: _two, backend: kv);
  expect(kv.read(kNoticeReadUpToKey), 'n-20261202-01');
});

testWidgets('메뉴에 「공지」 항목이 있다', (tester) async {
  // 홈 헤더의 PopupMenuButton 을 열고 라벨을 단정한다
  expect(find.text('공지'), findsOneWidget);
});
```

`_pumpNotices` 는 `ThemeScope` 로 감싸 `NoticesPage(loadString: (_) async => json, backend: backend ?? MemoryBackend())` 를 렌더하는 테스트 헬퍼다(레포 위젯 테스트 관례 — `runAsync` 로 에셋 Future 를 기다린다).

- [ ] **Step 2: 실패 확인** → FAIL

- [ ] **Step 3: `NoticesPage` 와 라우트·메뉴 항목 구현**

- 라우터: `/notices` → `NoticesPage`. 상위 라우트가 아니므로 `ValueKey` 는 필요 없다(경로 파라미터가 없다).
- 메뉴: `home_header.dart` 의 `static const _noticesKey = '__notices__';` + `PopupMenuItem(value: _noticesKey)` + `onSelected` 분기 → `context.go('/notices')`. 안 읽은 수가 0 보다 크면 라벨에 함께 보인다.
- 화면: 스크롤 뷰 하단에 `scrollBottomInset(context)`, 빈 상태는 `EmptyView`, 로딩은 `LoadingView(label: '공지를 불러오고 있습니다…')`.

- [ ] **Step 4: 통과 확인** → `flutter test test/notices_page_test.dart test/scroll_bottom_inset_test.dart test/korean_line_break_survey_test.dart` PASS

- [ ] **Step 5: 커밋**

```bash
git commit -m "feat(notices): 공지 화면·라우트·메뉴 진입점"
```

---

### Task 4: 홈 공지 배너

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` (`_dueBanner` 옆에 `_noticeBanner`)
- Test: `flutter_app/test/home_sections_test.dart` (그룹 추가) 또는 `flutter_app/test/notices_page_test.dart`

**Interfaces:**
- Consumes: Task 1·2·3
- Produces: 없음(화면 내부)

- [ ] **Step 1: 실패 테스트 작성**

```dart
testWidgets('안 읽은 공지가 있으면 홈에 배너가 보인다', (tester) async {
  // readUpTo 를 심지 않고(= 신규 설치) 대신 더 오래된 id 를 심어 2개를 안 읽음으로 만든다
  expect(find.textContaining('새 공지 2개'), findsOneWidget);
});

testWidgets('안 읽은 공지가 없으면 배너가 없다', (tester) async {
  expect(find.textContaining('새 공지'), findsNothing);
});

testWidgets('진행 중인 시험이 있으면 공지 배너보다 그것이 앞선다', (tester) async {
  // 진행 중 세션을 심고 안 읽은 공지도 함께 둔다
  expect(find.textContaining('이어서 풀기'), findsOneWidget);
  expect(find.textContaining('새 공지'), findsNothing);
});
```

- [ ] **Step 2: 실패 확인** → FAIL

- [ ] **Step 3: 배너 구현**

`_dueBanner` 와 같은 모양으로 만들고 조립 지점(`home_page.dart:230` 부근)에서 **진행 중인 시험 > due > 공지** 순서로 고른다. ⚠️ `HomePage` 의 주입구를 배너까지 넘긴다 — 넘기지 않으면 테스트가 심은 상태를 배너가 못 보고 「배너가 그려졌는가」 전제가 **거짓 통과**한다(2026-10-30 실측 선례).

- [ ] **Step 4: 통과 확인** → PASS

- [ ] **Step 5: 커밋**

```bash
git commit -m "feat(notices): 안 읽은 공지 홈 배너 — 진행 중 시험·일정 다음 순위"
```

---

### Task 5: 사용자 소유 컬렉션 분리 + 처리방침 기록 목록

**Files:**
- Modify: `flutter_app/lib/data/cloud/synced_collections.dart`
- Modify: `flutter_app/lib/data/cloud/sync_controller.dart` (`deleteAccount` 의 순회 대상)
- Modify: `flutter_app/web/privacy.html` (`data-record="feedback"` 를 **별 소절**로)
- Modify: `flutter_app/test/account_deletion_test.dart` · `flutter_app/test/legal_pages_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces: `const List<String> kUserOwnedCollections` = `kSyncedCollections` + `'feedback'`

- [ ] **Step 1: 실패 테스트 작성**

```dart
// account_deletion_test.dart — 기존 「sync_service가 쓰는 컬렉션 집합과 같다」는 그대로 둔다
test('feedback 은 동기 집합에 없고 소유 집합에 있다', () {
  expect(kSyncedCollections, isNot(contains('feedback')));
  expect(kUserOwnedCollections, contains('feedback'));
  expect(kUserOwnedCollections.toSet().length, kUserOwnedCollections.length);
});

test('계정 삭제가 소유 집합 전부를 지운다', () async {
  // _seedCloud 를 kUserOwnedCollections 로 돌려 심고, 삭제 뒤 0 을 단정한다
});

// legal_pages_test.dart — 기존 단정의 비교 대상을 바꾼다
test('클라우드 기록 목록이 사용자 소유 컬렉션과 같다', () {
  expect(records, equals(kUserOwnedCollections.toSet()));
});
```

- [ ] **Step 2: 실패 확인** → FAIL (`kUserOwnedCollections` 미정의 · `data-record="feedback"` 부재)

- [ ] **Step 3: 상수·삭제 흐름·처리방침 수정**

- `synced_collections.dart` 에 `kUserOwnedCollections` 를 더하고 **왜 둘로 갈랐는지**(동기 소스 스캔 가드는 `kSyncedCollections` 를 보고, 삭제는 더 넓다) 주석에 적는다.
- `sync_controller.dart:163` 의 순회를 `kUserOwnedCollections` 로 바꾼다. 순서(동기 정지 → 문서 → Auth → 로컬)는 **건드리지 않는다**.
- `privacy.html`: 기존 「동기하는 학습 기록」 목록 **밖에** 새 소절을 만들고 `<li data-record="feedback">보낸 의견 — 의견의 유형·본문과 보낸 시각, 앱 버전·플랫폼, 문항 오류면 그 문항의 식별자와 보여 드린 보기. 운영자가 읽습니다.</li>` 를 둔다.

- [ ] **Step 4: 통과 확인** → `flutter test test/account_deletion_test.dart test/legal_pages_test.dart` PASS

- [ ] **Step 5: 커밋**

```bash
git commit -m "feat(sync): 삭제 범위와 동기 범위를 가른다 — kUserOwnedCollections"
```

---

### Task 6: 앱 버전 상수

**Files:**
- Create: `flutter_app/lib/app_version.dart`
- Test: `flutter_app/test/app_version_sync_test.dart`

**Interfaces:**
- Produces: `const String kAppVersion = '1.0.0+1';`

- [ ] **Step 1: 실패 테스트 작성**

```dart
test('kAppVersion 이 pubspec 의 version 과 같다', () {
  final m = RegExp(r'^version:\s*(\S+)', multiLine: true)
      .firstMatch(File('pubspec.yaml').readAsStringSync());
  expect(m, isNotNull, reason: 'pubspec 에서 version 을 읽지 못했다');
  expect(kAppVersion, m!.group(1));
});
```

- [ ] **Step 2: 실패 확인** → FAIL
- [ ] **Step 3: `lib/app_version.dart` 작성** — 상수 하나 + 「pubspec 과 함께 올린다」 주석
- [ ] **Step 4: 통과 확인** → PASS
- [ ] **Step 5: 커밋** `chore: 앱 버전 상수와 pubspec 동기 가드`

---

### Task 7: 피드백 서비스

**Files:**
- Create: `flutter_app/lib/data/cloud/feedback_service.dart`
- Test: `flutter_app/test/feedback_service_test.dart`

**Interfaces:**
- Consumes: `CloudStore`·`AuthService`(기존), Task 6 의 `kAppVersion`
- Produces:
  - `enum FeedbackKind { question, content, bug, idea, other }`
  - `enum FeedbackSendResult { sent, queued, failed, notSignedIn, invalid }`
  - `class FeedbackContext { const FeedbackContext({this.certCode, this.taskId, this.questionId, this.shownOptions, this.pickedIndex}); Map<String, dynamic> toJson(); }`
  - `class FeedbackService { FeedbackService(this._cloud, this._auth, {Duration ackTimeout = const Duration(seconds: 3), DateTime Function()? now}); Future<FeedbackSendResult> send({required FeedbackKind kind, required String body, FeedbackContext? context}); Future<List<Map<String, dynamic>>> mine(); }`
  - 상수 `const kFeedbackBodyMax = 2000;`

- [ ] **Step 1: 실패 테스트 작성**

```dart
test('정상 전송은 sent 이고 문서가 users/{uid}/feedback 에 쓰인다', () async {
  // kind·body·createdAtMs·app.version(kAppVersion)·app.platform 을 단정
});

// Review Focus 2
test('빈 본문은 invalid 이고 아무것도 쓰지 않는다', () async { ... });
test('공백만 있는 본문도 invalid 다', () async { ... });
test('2000자 초과는 invalid 다', () async { ... });
test('2000자 정확히는 보낸다', () async { ... });

// Review Focus 3
test('비로그인은 notSignedIn 이고 아무것도 쓰지 않는다', () async { ... });

// 설계 §7-2 전송 3분기
test('ack 가 늦으면 queued 다', () async {
  // setDoc 이 영원히 완료되지 않는 Fake + ackTimeout 을 짧게 주입
});
test('예외는 failed 다', () async { ... });

test('context 를 주면 shownOptions·pickedIndex 까지 담는다', () async { ... });
test('context 가 없으면 문서에 context 키가 없다', () async { ... });
test('mine 은 내 의견만 돌려준다', () async { ... });
```

- [ ] **Step 2: 실패 확인** → FAIL

- [ ] **Step 3: `FeedbackService` 구현**

`send` 는 ① 로그인 확인 ② 본문 `trim()` 길이 검증 ③ 문서 조립 ④ `setDoc(...).timeout(ackTimeout)` — 성공 `sent`, `TimeoutException` **`queued`**, 그 밖 예외 `failed`. 문서 id 는 `'${createdAtMs}-${난수}'`. 플랫폼은 `kIsWeb ? 'web' : defaultTargetPlatform.name`.

> ⚠️ `queued` 를 성공으로 보는 근거는 설계 §7-2 다 — Firestore 오프라인 큐는 앱을 닫아도 유지된다. **타임아웃을 실패로 바꾸지 않는다.**

- [ ] **Step 4: 통과 확인** → PASS
- [ ] **Step 5: 커밋** `feat(feedback): 전송 서비스 — 검증·오프라인 큐·실패 3분기`

---

### Task 8: 피드백 화면·라우트·메뉴·주입

**Files:**
- Create: `flutter_app/lib/pages/feedback_page.dart`
- Modify: `flutter_app/lib/app_router.dart` (`/feedback`)
- Modify: `flutter_app/lib/pages/home/home_header.dart` (메뉴 항목)
- Modify: `flutter_app/lib/main.dart` (`ValueNotifier<FeedbackService?>` 주입)
- Test: `flutter_app/test/feedback_page_test.dart`
- Modify: `flutter_app/test/scroll_bottom_inset_test.dart` · `flutter_app/test/korean_line_break_survey_test.dart`

**Interfaces:**
- Consumes: Task 7 전부
- Produces:
  - `class FeedbackPage extends StatefulWidget { const FeedbackPage({super.key, this.service, this.initialKind, this.initialContext}) }` — `service` 가 null 이면 전역 `feedbackService` 를 구독한다(테스트 주입구)
  - `final feedbackService = ValueNotifier<FeedbackService?>(null);` (`main.dart` — 기존 `syncController` 와 같은 자리·같은 패턴)
  - **라우트 `extra` 타입(Task 9 가 이 모양으로 담는다):** `typedef FeedbackLaunch = ({FeedbackKind kind, FeedbackContext context});` — `feedback_service.dart` 에 둔다. `extra` 가 이 타입이 아니거나 null 이면 **빈 폼**으로 연다(던지지 않는다).

- [ ] **Step 1: 실패 테스트 작성**

```dart
testWidgets('비로그인이면 폼 대신 로그인 안내를 보인다', (tester) async {
  expect(find.text('의견을 보내려면 Google 로그인이 필요합니다.'), findsOneWidget);
  expect(find.byType(TextField), findsNothing);
});

testWidgets('본문을 적어 보내면 성공 문구가 보인다', (tester) async {
  expect(find.text('의견을 보냈습니다.'), findsOneWidget);
});

testWidgets('ack 가 늦으면 대기 문구가 보인다', (tester) async {
  expect(find.text('의견을 저장했습니다 — 네트워크가 연결되면 올라갑니다.'),
      findsOneWidget);
});

testWidgets('실패하면 실패 문구와 보조 설명이 보인다', (tester) async {
  expect(find.text('의견을 보내지 못했습니다.'), findsOneWidget);
  expect(find.textContaining('다시 시도하면'), findsOneWidget);
});

testWidgets('본문이 비면 전송 버튼이 비활성이다', (tester) async {
  expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull);
});

// Review Focus 5
testWidgets('전송 중에는 두 번 눌러도 한 번만 쓰인다', (tester) async {
  // setDoc 이 완료되지 않는 Spy 로 전송 중 상태를 만들고 두 번 탭한다
  expect(spy.setDocCalls, 1);
});

testWidgets('initialContext 를 주면 대상 문항을 보여 준다', (tester) async {
  expect(find.textContaining('saa-t1-1-q3'), findsOneWidget);
  expect(find.text('어느 보기인지 내용을 그대로 적어 주시면 더 빠릅니다.'),
      findsOneWidget);
});

testWidgets('내가 보낸 의견 목록을 보인다', (tester) async {
  expect(find.text('먼저 보낸 의견'), findsOneWidget);
});

testWidgets('보낸 의견이 없으면 빈 상태 문구를 보인다', (tester) async {
  expect(find.text('아직 보낸 의견이 없습니다'), findsOneWidget);
});

testWidgets('서비스 미설정(null)이면 안내를 보인다', (tester) async {
  expect(find.text('의견 보내기는 지금 사용할 수 없습니다.'), findsOneWidget);
});
```

- [ ] **Step 2: 실패 확인** → FAIL

- [ ] **Step 3: `FeedbackPage`·라우트·메뉴·주입 구현**

- 라우트 `/feedback`. 컨텍스트는 `GoRouterState.extra` 로 받는다(쿼리에 배열을 넣지 않는다).
- 메뉴: `static const _feedbackKey = '__feedback__';` 항목 「의견 보내기」.
- `main.dart`: `initCloudSync()` 안에서 `syncController` 를 만드는 자리에 `feedbackService.value = FeedbackService(cloud, auth);` 를 더한다. **동기 쪽 코드를 바꾸지 않는다.**
- 비로그인 안내는 **전용 위젯**이다 — `SyncEntry` 를 재사용하지 않는다(로그아웃·계정 삭제가 섞여 들어온다).
- 하단 `scrollBottomInset(context)`, 로딩·에러는 State Views.

- [ ] **Step 4: 통과 확인** → PASS
- [ ] **Step 5: 커밋** `feat(feedback): 폼 화면·라우트·메뉴 진입점·서비스 주입`

---

### Task 9: 문항 신고 배선

**Files:**
- Modify: `flutter_app/lib/content/quiz_widgets.dart` (`ResultCard`·`ResultsView`)
- Modify: `flutter_app/lib/pages/exam/exam_view.dart:425` · `flutter_app/lib/pages/quiz_page.dart:197`
- Test: `flutter_app/test/question_report_test.dart`

**Interfaces:**
- Consumes: Task 7 의 `FeedbackKind`·`FeedbackContext`, Task 8 의 `/feedback` 라우트
- Produces: `ResultCard`·`ResultsView` 의 `void Function(Question q, int? pickedIndex)? onReport` — **`onOpenStudy` 와 같은 모양이고 null 이면 버튼을 그리지 않는다**

- [ ] **Step 1: 실패 테스트 작성**

```dart
testWidgets('onReport 를 주지 않으면 신고 버튼이 없다', (tester) async {
  await _pumpCard(tester, onReport: null);
  expect(find.text('신고'), findsNothing);
});

testWidgets('onReport 를 주면 버튼이 보이고 q 와 pickedIndex 를 넘긴다', (tester) async {
  Question? got;
  int? picked = -1;
  await _pumpCard(tester, pickedIndex: 2, onReport: (q, p) { got = q; picked = p; });
  await tester.tap(find.text('신고'));
  expect(got!.id, 'x-q1');
  expect(picked, 2);
});

testWidgets('ResultsView 가 onReport 를 카드마다 전달한다', (tester) async {
  // 3문항 뱅크를 렌더하고 신고 버튼이 3개인지 센다
  expect(find.text('신고'), findsNWidgets(3));
});

testWidgets('신고 버튼의 탭 영역이 48dp 이상이다', (tester) async {
  expect(tester.getSize(find.ancestor(
          of: find.text('신고'), matching: find.byType(TouchTarget)))
      .height, greaterThanOrEqualTo(48));
});
```

- [ ] **Step 2: 실패 확인** → FAIL

- [ ] **Step 3: `onReport` 추가와 호출부 배선**

`ResultCard`·`ResultsView` 에 선택적 콜백을 더한다(`onOpenStudy` 바로 아래, 같은 주석 양식). 버튼은 `TouchTarget` 으로 감싼다. 호출부 둘에서 `onReport` 를 넘겨 `/feedback` 으로 **`push`** 하고 `extra` 에 **Task 8 이 정의한 레코드**를 담는다:

```dart
(
  kind: FeedbackKind.question,
  context: FeedbackContext(
    certCode: cert.code,
    taskId: q.examGuideTaskId,
    questionId: q.id,
    shownOptions: q.options,
    pickedIndex: pickedIndex,
  ),
)
```

⚠️ `FeedbackContext` 에는 `kind` 가 없다 — 유형은 `send()` 의 인자이고 화면에는 `initialKind` 로 들어간다. 둘을 한 객체에 섞지 않는다.

> ⚠️ `q.options` 는 **이미 셔플이 적용된** 보기다(`applyOptionOrders`). 그래서 그대로 담으면 사용자가 본 순서가 된다 — 인덱스 배열을 따로 만들지 않는다.

- [ ] **Step 4: 통과 확인** — 이 Task 는 공용 위젯을 건드리므로 **관련 기존 가드를 함께 돌린다**

Run: `cd flutter_app && flutter test test/question_report_test.dart test/exam_page_snapshot_test.dart test/touch_target_test.dart test/accent_on_surface2_test.dart`
Expected: PASS (스냅샷이 깨지면 `onReport` 미전달 시 버튼이 그려지지 않는지 먼저 확인한다)

- [ ] **Step 5: 커밋** `feat(feedback): 결과 복기 카드에서 문항 신고`

---

### Task 10: 공시 문서·규칙 회귀 테스트·운영 문서 정정

**Files:**
- Modify: `flutter_app/web/delete-account.html` (「남는 것」 절)
- Modify: `tool/firestore_rules_test/rules.test.mjs`
- Modify: `docs/play/2026-11-20-data-safety-and-listing-draft.md`
- Modify: `docs/plans/2026-11-18-productization-roadmap.md` (D2 행 완료 기준)
- Modify: `docs/superpowers/specs/2026-06-13-pr2-state-views-copy-matrix.md` (새 페이지 둘의 카피)
- Modify: `flutter_app/test/legal_pages_test.dart` (「남는 것」 단정 보강)

**Interfaces:** 없음(문서·규칙 테스트)

- [ ] **Step 1: 실패 테스트 작성**

```dart
// legal_pages_test.dart
test('삭제 페이지가 전사한 사본이 남는다는 것을 적는다', () {
  final s = _section(deleteHtml, 'scope');
  expect(s, contains('의견'));
  expect(s, contains('남'));
});
```

```js
// rules.test.mjs — 규칙은 바꾸지 않는다. 지금 동작이 의도한 것임을 못박는다.
test('본인 feedback 문서는 쓰고 읽을 수 있다', ...);
test('타인 uid 의 feedback 문서는 쓸 수 없다', ...);
test('비로그인은 feedback 을 쓸 수 없다', ...);
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/legal_pages_test.dart`
Expected: FAIL — 「남는 것」 절에 의견 서술이 없다

- [ ] **Step 3: 문서 수정**

- `delete-account.html` 「남는 것」: 「보내 주신 의견을 운영자가 읽고 학습 자료 정정에 반영한 기록은 남습니다. 그 기록에는 계정을 알아볼 수 있는 정보를 담지 않습니다.」
- Data safety 초안: 「메시지 › 기타 인앱 메시지」 **예(수집)** · 「앱 활동 › 기타 사용자 생성 콘텐츠」의 근거를 **의견 본문이 자유 텍스트임**으로 고치고, **분류의 최종 근거는 Console 양식 화면**이라고 적는다(로드맵 §8-⑤).
- 로드맵 D2 행: 공지 규칙 케이스가 **번들 안에서는 존재할 수 없고** `users/{uid}/feedback` 은 **본인도 읽는다**는 점을 반영해 완료 기준을 고친다.
- 카피 매트릭스: `NoticesPage`·`FeedbackPage` 의 로딩·빈·에러 문구 3종씩을 표에 더한다.

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/legal_pages_test.dart`
Run: `cd tool/firestore_rules_test && npm test` (Firestore 에뮬레이터 · Java 필요)
Expected: 둘 다 PASS

- [ ] **Step 5: 커밋** `docs: 공지·피드백 공시와 규칙 회귀 테스트`

---

### Task 11: 전체 게이트와 인계 문서

**Files:**
- Modify: `CLAUDE.md` (기준선 줄 — **실측값**)
- Modify: `HANDOFF.md` · `WORKLIST.md` (갱신 줄은 **밀어 내린다**, 교체하지 않는다)

- [ ] **Step 1: 전체 스위트와 분석**

Run: `cd flutter_app && flutter test` → 전부 통과, **통과 수를 적어 둔다**
Run: `cd flutter_app && flutter analyze` → `No issues found!`
Run: `cd flutter_app && node tool/review.test.mjs && node tool/prescreen.test.mjs`

- [ ] **Step 2: 웹 회귀 확인(PowerShell)**

Run: `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: 성공. `main.dart.js` 크기 증가분을 적는다(의존성을 더하지 않았으므로 코드 분량만큼이어야 한다).

- [ ] **Step 3: 기준선·인계 문서 갱신**

`CLAUDE.md` 의 기준선 수치를 **Step 1 의 실측값**으로 고친다(예측값 금지). `HANDOFF.md` `_갱신:` 과 `WORKLIST.md` 갱신 줄을 **밀어 내려** 추가한다.

- [ ] **Step 4: 커밋 후 PR**

```bash
git commit -m "docs: D2 공지·피드백 기준선·인계 갱신"
git push -u origin feat/d2-notice-feedback
gh pr create --base develop
```
