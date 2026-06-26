# 자격증별 오디오 학습 페이지 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 자격증별로 학습 오디오 강의를 모아 듣는 전용 페이지(`/cert/:code/audio`)와 오디오 허브(`/audio`)·상단 메뉴 진입점·하단 트랜스포트(처음/이전/재생정지/다음/마지막)를 추가한다.

**Architecture:** 전역 `LecturePlaylist`가 기존 전역 `AudioController`를 감싸 앱 전체 오디오의 단일 소스가 된다(통합 플레이리스트). 새 페이지와 기존 학습문서 미니플레이어가 같은 플레이리스트의 뷰가 되어 화면을 옮겨도 재생이 끊기지 않는다. 트랙 변경은 오디오 페이지의 트랜스포트/행 탭으로만 일어나고, 문서 진입(`openDoc`)은 비중단 규칙을 따른다.

**Tech Stack:** Flutter Web (Dart), go_router(해시 라우팅), ChangeNotifier 상태. 테스트는 `flutter test`(위젯/단위), 정적 분석 `flutter analyze`.

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 게이트: `flutter test` 전부 통과, `flutter analyze` **신규 0건**(기존 잔존 3건: plan_agenda cacheExtent·sync_controller_test 2건).
- TDD: 기능마다 실패 테스트 선작성 → 최소 구현 → 통과 확인 → 커밋. Windows는 `py` 아닌 `flutter` CLI 사용.
- DESIGN.md 준수: `context.c` 토큰만, 인터랙티브는 `InkWell`+`FocusRing`(GestureDetector 단독 금지), 합니다체, 비-fatal 오디오 실패에 `wrong` 색 금지, 반마케팅 절제. 새 fontWeight엔 `Wght.*` 병기.
- 재생 흐름 = **수동 전환**: 트랙 종료(ended) 시 자동 전환 없음(인덱스 불변). 트랙 변경은 `select/next/prev/first/last`로만.
- 경계 규칙: 처음·이전은 `hasPrev`(index>0)일 때만, 다음·마지막은 `hasNext`(index<length-1)일 때만 동작(아니면 no-op, 트랜스포트는 muted).
- `openDoc` 비중단 규칙: 컨트롤러가 idle일 때만 해당 트랙 `load`(준비), 재생/일시정지 중이면 컨트롤러 미변경(연속성).
- 게이트: `audioLectureEnabled`(const, dart-define) — 로직은 `enabled` 인자 받는 순수 함수로 두고 라우트/헤더에서 const 주입(기존 `shouldShowLecturePlayer` 패턴). 라우터 테스트 안전을 위해 게이트 off(테스트 기본)면 항상 안전 페이지(HomePage)로 redirect.
- 커밋 직전 `git branch --show-current`로 `feat/audio-cert-page` 확인(공유 워킹트리). 다른 세션 untracked(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`)는 절대 `git add` 금지.
- 비목표(YAGNI): 연속(자동)재생·재생속도·seek·진행률바·다운로드·다중 cert 정렬/필터·잠금화면 트랜스포트 확장·오디오 진행 이력.

## File Structure

- Create `lib/data/lecture_playlist.dart` — `LecturePlaylist`(전역 플레이리스트 컨트롤러, AudioController 래핑).
- Create `lib/data/audio_nav.dart` — 순수 게이트/리다이렉트 함수(`shouldShowAudioMenu`, `audioHubRedirect`, `certAudioRedirect`).
- Create `lib/pages/cert_audio_page.dart` — `CertAudioPage`(트랙 목록 + 트랜스포트).
- Create `lib/pages/audio_hub_page.dart` — `AudioHubPage`(자격증 카드 목록).
- Create `lib/widgets/lecture_transport_bar.dart` — `LectureTransportBar`(하단 고정 트랜스포트).
- Modify `lib/data/content_index.dart` — `approvedAudioEntries`, `certsWithApprovedAudio` 추가(`contentFor` 근처, 약 483행).
- Modify `lib/data/audio_runtime.dart` — 전역 `lecturePlaylist` getter 추가.
- Modify `lib/widgets/study_audio_player.dart` — `LecturePlaylist` 기반으로 전환(auto-load 제거, 현재 트랙 표시).
- Modify `lib/pages/study_doc_page.dart` — `_onDocReady`에서 `openDoc` 호출, `_miniPlayer`가 playlist 사용.
- Modify `lib/pages/home_page.dart` — 상단 메뉴 '오디오' 항목(조건부).
- Modify `lib/app_router.dart` — `/audio`·`/cert/:code/audio` 라우트+redirect.
- Tests: `test/lecture_playlist_test.dart`, `test/audio_nav_test.dart`, `test/content_index_audio_test.dart`, `test/lecture_transport_bar_test.dart`, `test/study_audio_player_test.dart`(수정), `test/app_router_test.dart`(추가).

---

## Task 1: content_index 오디오 헬퍼

**Files:**
- Modify: `flutter_app/lib/data/content_index.dart` (약 483~487행 `contentFor` 뒤)
- Test: `flutter_app/test/content_index_audio_test.dart`

**Interfaces:**
- Consumes: 기존 `contentFor(String) -> List<ContentEntry>`(483행), `kContentIndex`, `ContentEntry.audioApproved`/`certCode`.
- Produces:
  - `List<ContentEntry> approvedAudioEntries(String certCode)` — 선언 순서, `audioApproved==true`만.
  - `List<String> certsWithApprovedAudio()` — 승인 오디오 ≥1 cert 코드(kContentIndex 키 순서).

- [ ] **Step 1: 실패 테스트 작성**

Create `flutter_app/test/content_index_audio_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/content_index.dart';

void main() {
  test('approvedAudioEntries: CLF-C02는 승인 오디오 19문서 모두 반환(선언 순서)', () {
    final list = approvedAudioEntries('CLF-C02');
    expect(list, isNotEmpty);
    expect(list.every((e) => e.audioApproved), isTrue);
    expect(list.first.taskId, 'clf-t1-1'); // 선언 순서 첫 항목
  });

  test('approvedAudioEntries: 미존재/무오디오 cert는 빈 리스트', () {
    expect(approvedAudioEntries('NOPE-X'), isEmpty);
  });

  test('certsWithApprovedAudio: CLF-C02 포함', () {
    expect(certsWithApprovedAudio(), contains('CLF-C02'));
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/content_index_audio_test.dart`
Expected: FAIL — `approvedAudioEntries`/`certsWithApprovedAudio` 미정의(컴파일 에러).

- [ ] **Step 3: 구현**

`content_index.dart`에서 `bool certHasContent(...)` 정의(약 487행) **다음**에 추가:

```dart
/// 청취 검수 승인(audioApproved) 오디오 강의가 있는 엔트리만 선언 순서로.
List<ContentEntry> approvedAudioEntries(String certCode) =>
    contentFor(certCode).where((e) => e.audioApproved).toList(growable: false);

/// 승인 오디오 강의를 1개 이상 가진 자격증 코드(kContentIndex 키 순서).
List<String> certsWithApprovedAudio() => kContentIndex.keys
    .where((code) => approvedAudioEntries(code).isNotEmpty)
    .toList(growable: false);
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/content_index_audio_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/content_index.dart flutter_app/test/content_index_audio_test.dart
git commit -m "feat(audio): content_index 승인 오디오 헬퍼(approvedAudioEntries·certsWithApprovedAudio)"
```

---

## Task 2: audio_nav 순수 게이트·리다이렉트

**Files:**
- Create: `flutter_app/lib/data/audio_nav.dart`
- Test: `flutter_app/test/audio_nav_test.dart`

**Interfaces:**
- Produces:
  - `bool shouldShowAudioMenu({required bool enabled, required bool hasAudio})` — 상단 메뉴 '오디오' 노출 여부.
  - `String? audioHubRedirect({required bool enabled, required bool hasAudio})` — `/audio` redirect 대상(null=렌더).
  - `String? certAudioRedirect({required bool certExists, required bool enabled, required bool hasAudio, required String code})` — `/cert/:code/audio` redirect 대상(null=렌더).

- [ ] **Step 1: 실패 테스트 작성**

Create `flutter_app/test/audio_nav_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_nav.dart';

void main() {
  test('shouldShowAudioMenu: enabled+hasAudio일 때만 true', () {
    expect(shouldShowAudioMenu(enabled: true, hasAudio: true), isTrue);
    expect(shouldShowAudioMenu(enabled: false, hasAudio: true), isFalse);
    expect(shouldShowAudioMenu(enabled: true, hasAudio: false), isFalse);
  });

  test('audioHubRedirect: 게이트 통과면 null, 아니면 "/"', () {
    expect(audioHubRedirect(enabled: true, hasAudio: true), isNull);
    expect(audioHubRedirect(enabled: false, hasAudio: true), '/');
    expect(audioHubRedirect(enabled: true, hasAudio: false), '/');
  });

  test('certAudioRedirect: 분기별 대상', () {
    expect(certAudioRedirect(certExists: false, enabled: true, hasAudio: true, code: 'X'), '/');
    expect(certAudioRedirect(certExists: true, enabled: false, hasAudio: true, code: 'CLF-C02'), '/');
    expect(certAudioRedirect(certExists: true, enabled: true, hasAudio: false, code: 'CLF-C02'), '/cert/CLF-C02');
    expect(certAudioRedirect(certExists: true, enabled: true, hasAudio: true, code: 'CLF-C02'), isNull);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/audio_nav_test.dart`
Expected: FAIL — 파일/함수 미정의.

- [ ] **Step 3: 구현**

Create `flutter_app/lib/data/audio_nav.dart`:

```dart
/// 오디오 페이지 노출·라우트 게이트(순수 함수 — 위젯/라우터 밖에서 단위 테스트).
/// audioLectureEnabled(const, dart-define)는 호출부에서 주입한다(기존
/// shouldShowLecturePlayer 패턴). 라우터 테스트 안전을 위해 게이트 off면
/// 항상 안전 페이지("/", HomePage)로 보낸다(비-안전 페이지 렌더 회피).
library;

/// 상단 메뉴 '오디오' 항목 노출 여부.
bool shouldShowAudioMenu({required bool enabled, required bool hasAudio}) =>
    enabled && hasAudio;

/// `/audio` 허브 redirect 대상. null이면 그대로 렌더.
String? audioHubRedirect({required bool enabled, required bool hasAudio}) =>
    (enabled && hasAudio) ? null : '/';

/// `/cert/:code/audio` redirect 대상. null이면 그대로 렌더.
String? certAudioRedirect({
  required bool certExists,
  required bool enabled,
  required bool hasAudio,
  required String code,
}) {
  if (!certExists) return '/';
  if (!enabled) return '/';
  if (!hasAudio) return '/cert/$code';
  return null;
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/audio_nav_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/audio_nav.dart flutter_app/test/audio_nav_test.dart
git commit -m "feat(audio): 오디오 페이지 게이트·리다이렉트 순수 함수(audio_nav)"
```

---

## Task 3: LecturePlaylist 컨트롤러

**Files:**
- Create: `flutter_app/lib/data/lecture_playlist.dart`
- Modify: `flutter_app/lib/data/audio_runtime.dart` (전역 getter 추가)
- Test: `flutter_app/test/lecture_playlist_test.dart`

**Interfaces:**
- Consumes: `AudioController`(`load(String)`, `play()`, `pause()`, `state`/`PlaybackState`, ChangeNotifier) from `audio_controller.dart`; `ContentEntry`(`taskId`/`title`/`lectureAudioSrc`)·`approvedAudioEntries` from `content_index.dart`.
- Produces:
  - `class LecturePlaylist extends ChangeNotifier`:
    - `LecturePlaylist({required AudioController controller})`
    - getters: `List<ContentEntry> queue`, `int index`, `String certCode`, `ContentEntry? current`, `String? currentTitle`, `PlaybackState state`, `bool hasPrev`, `bool hasNext`
    - `setQueue(String certCode, List<ContentEntry> tracks, {int startIndex = 0})`
    - `openDoc(String certCode, String taskId)`
    - `select(int i)`, `next()`, `prev()`, `first()`, `last()`, `playPause()`
  - 전역 `LecturePlaylist? get lecturePlaylist`(audio_runtime.dart) — 웹이면 전역 컨트롤러 래핑 싱글톤, VM/test면 null.

- [ ] **Step 1: 실패 테스트 작성**

Create `flutter_app/test/lecture_playlist_test.dart`:

```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  String? src;
  int playCalls = 0;
  int pauseCalls = 0;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) => src = s;
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() => _ev.close();
  void emit(AudioEvent e) => _ev.add(e);
}

ContentEntry _e(String taskId, {bool approved = true}) => ContentEntry(
      certCode: 'CLF-C02',
      taskId: taskId,
      title: 'T $taskId',
      domain: 1,
      mdAsset: 'a',
      questionsAsset: 'b',
      questionCount: 0,
      audioApproved: approved,
    );

void main() {
  late _Fake fake;
  late AudioController ctrl;
  late LecturePlaylist pl;
  final tracks = [_e('clf-t1-1'), _e('clf-t1-2'), _e('clf-t1-3')];

  setUp(() {
    fake = _Fake();
    ctrl = AudioController(backend: fake);
    pl = LecturePlaylist(controller: ctrl);
  });

  test('setQueue: 큐·인덱스 설정, 자동재생 안 함', () {
    pl.setQueue('CLF-C02', tracks);
    expect(pl.queue.length, 3);
    expect(pl.index, 0);
    expect(fake.playCalls, 0);
    expect(fake.src, isNull); // load 안 함
  });

  test('select(i): 그 트랙 load+play, currentTitle 갱신', () {
    pl.setQueue('CLF-C02', tracks);
    pl.select(1);
    expect(pl.index, 1);
    expect(fake.src, 'assets/audio/clf/clf-t1-2/lecture.mp3');
    expect(fake.playCalls, 1);
    expect(pl.currentTitle, 'T clf-t1-2');
  });

  test('next/prev 경계 no-op(끝에서 next, 처음에서 prev는 멈춤)', () {
    pl.setQueue('CLF-C02', tracks);
    expect(pl.hasPrev, isFalse);
    pl.prev();
    expect(pl.index, 0);
    expect(fake.playCalls, 0); // 경계 no-op: 재생 안 함
    pl.last();
    expect(pl.index, 2);
    expect(pl.hasNext, isFalse);
    final calls = fake.playCalls;
    pl.next();
    expect(pl.index, 2);
    expect(fake.playCalls, calls); // 경계 no-op
  });

  test('first/last: 점프(처음/마지막 트랙)', () {
    pl.setQueue('CLF-C02', tracks, startIndex: 1);
    pl.last();
    expect(pl.index, 2);
    pl.first();
    expect(pl.index, 0);
  });

  test('ended 이벤트는 인덱스 불변(수동 전환 — 자동전환 없음)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(0);
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 0); // 다음으로 넘어가지 않음
  });

  test('openDoc: idle이면 해당 트랙 load(준비), 재생 안 함', () {
    pl.openDoc('CLF-C02', 'clf-t1-2');
    expect(pl.current?.taskId, 'clf-t1-2');
    expect(fake.src, 'assets/audio/clf/clf-t1-2/lecture.mp3');
    expect(fake.playCalls, 0);
  });

  test('openDoc 비중단: 재생 중이면 컨트롤러·트랙 미변경', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(2); // t1-3 재생
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    final srcBefore = fake.src;
    pl.openDoc('CLF-C02', 'clf-t1-1'); // 다른 문서로 진입
    expect(pl.index, 2); // 트랙 안 바뀜
    expect(fake.src, srcBefore); // 재로드 없음(연속성)
  });

  test('playPause: playing이면 pause, 아니면 play', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.playPause();
    expect(fake.playCalls, 1);
    fake.emit(AudioEvent.playing);
    await Future<void>.delayed(Duration.zero);
    pl.playPause();
    expect(fake.pauseCalls, 1);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/lecture_playlist_test.dart`
Expected: FAIL — `lecture_playlist.dart`/`LecturePlaylist` 미정의.

- [ ] **Step 3: LecturePlaylist 구현**

Create `flutter_app/lib/data/lecture_playlist.dart`:

```dart
/// 자격증 오디오 강의 플레이리스트 — 전역 [AudioController]를 감싸는 단일 소스.
///
/// 오디오 페이지(CertAudioPage)와 학습문서 미니플레이어가 같은 인스턴스를 구독해
/// 화면 전환에도 재생이 끊기지 않는다(주머니 라디오). 트랙 변경은
/// select/next/prev/first/last로만 일어나고, 트랙 종료(ended)는 자동 전환하지
/// 않는다(수동 전환 — iOS 잠금 자동전환 함정 회피).
///
/// 설계: docs/superpowers/specs/2026-06-27-cert-audio-page-design.md
library;

import 'package:flutter/foundation.dart';

import 'audio_controller.dart';
import 'content_index.dart';

class LecturePlaylist extends ChangeNotifier {
  LecturePlaylist({required AudioController controller})
      : _controller = controller {
    _controller.addListener(notifyListeners); // 재생 상태 변화 재방출
  }

  final AudioController _controller;
  List<ContentEntry> _queue = const <ContentEntry>[];
  int _index = 0;
  String _certCode = '';

  List<ContentEntry> get queue => _queue;
  int get index => _index;
  String get certCode => _certCode;
  ContentEntry? get current =>
      (_index >= 0 && _index < _queue.length) ? _queue[_index] : null;
  String? get currentTitle => current?.title;
  PlaybackState get state => _controller.state;
  bool get hasPrev => _index > 0;
  bool get hasNext => _index < _queue.length - 1;

  /// 큐 설정(자동재생 안 함). 같은 cert·같은 트랙 목록이면 위치 보존.
  void setQueue(String certCode, List<ContentEntry> tracks,
      {int startIndex = 0}) {
    if (certCode == _certCode && listEquals(_queue, tracks)) return;
    _queue = tracks;
    _certCode = certCode;
    _index = tracks.isEmpty ? 0 : startIndex.clamp(0, tracks.length - 1);
    notifyListeners();
  }

  /// 학습문서 진입 — 비중단 규칙: idle일 때만 해당 트랙 load(준비). 재생/일시정지
  /// 중이면 컨트롤러를 건드리지 않는다(연속성). 큐 cert만 정합.
  void openDoc(String certCode, String taskId) {
    if (certCode != _certCode) {
      setQueue(certCode, approvedAudioEntries(certCode));
    }
    if (_controller.state == PlaybackState.idle) {
      final i = _queue.indexWhere((e) => e.taskId == taskId);
      if (i >= 0) _index = i;
      final src = current?.lectureAudioSrc;
      if (src != null) _controller.load(src);
      notifyListeners();
    }
  }

  /// 명시적 트랙 변경 — 그 트랙 load 후 play(사용자 제스처 동기 진입).
  void select(int i) {
    if (_queue.isEmpty) return;
    _index = i.clamp(0, _queue.length - 1);
    _controller.load(current!.lectureAudioSrc);
    _controller.play();
    notifyListeners();
  }

  void next() {
    if (hasNext) select(_index + 1);
  }

  void prev() {
    if (hasPrev) select(_index - 1);
  }

  void first() {
    if (hasPrev) select(0);
  }

  void last() {
    if (hasNext) select(_queue.length - 1);
  }

  void playPause() {
    if (_controller.state == PlaybackState.playing) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    super.dispose();
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/lecture_playlist_test.dart`
Expected: PASS (8 tests).

- [ ] **Step 5: 전역 getter 추가**

`lib/data/audio_runtime.dart` 끝(파일 마지막 `}` 다음, `library;`·import는 상단에 이미 있음)에 추가하되, 상단 import 블록(`import 'audio_controller.dart';` 위)에 `import 'lecture_playlist.dart';`를 더한 뒤 파일 끝에:

```dart
/// 전역 플레이리스트(웹 전용, 지연 초기화). 전역 [AudioController]를 감싼다.
/// VM/test에선 audioRuntime이 null이라 함께 null이다(웹에서만 동작).
LecturePlaylist? _lecturePlaylist;
LecturePlaylist? get lecturePlaylist {
  final rt = audioRuntime;
  if (rt == null) return null;
  return _lecturePlaylist ??= LecturePlaylist(controller: rt.controller);
}
```

- [ ] **Step 6: 분석 통과 확인(전역 getter 컴파일)**

Run: `cd flutter_app && flutter analyze lib/data/audio_runtime.dart lib/data/lecture_playlist.dart`
Expected: 신규 경고/에러 0건.

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/lib/data/lecture_playlist.dart flutter_app/lib/data/audio_runtime.dart flutter_app/test/lecture_playlist_test.dart
git commit -m "feat(audio): LecturePlaylist(통합 플레이리스트) + 전역 lecturePlaylist getter"
```

---

## Task 4: StudyAudioPlayer를 LecturePlaylist 기반으로 전환

**Files:**
- Modify: `flutter_app/lib/widgets/study_audio_player.dart`
- Test: `flutter_app/test/study_audio_player_test.dart` (재작성)

**Interfaces:**
- Consumes: `LecturePlaylist`(`currentTitle`, `state`, `playPause()`) from Task 3.
- Produces: `StudyAudioPlayer({required LecturePlaylist playlist})` — 현재 트랙 제목·상태 표시 + 재생/정지(playlist.playPause). **auto-load 제거**(로딩은 호출부 책임).

- [ ] **Step 1: 실패 테스트 작성(재작성)**

Replace `flutter_app/test/study_audio_player_test.dart` 전체:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';
import 'package:aws_docs/widgets/study_audio_player.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  int playCalls = 0;
  int pauseCalls = 0;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) {}
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() => pauseCalls++;
  @override
  void dispose() => _ev.close();
  void emit(AudioEvent e) => _ev.add(e);
}

ContentEntry _e(String t) => ContentEntry(
    certCode: 'CLF-C02', taskId: t, title: 'T $t', domain: 1,
    mdAsset: 'a', questionsAsset: 'b', questionCount: 0, audioApproved: true);

Future<LecturePlaylist> _pump(WidgetTester tester, _Fake fake) async {
  final pl = LecturePlaylist(controller: AudioController(backend: fake));
  pl.setQueue('CLF-C02', [_e('clf-t1-1'), _e('clf-t1-2')]);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(bottomNavigationBar: StudyAudioPlayer(playlist: pl)),
  ));
  return pl;
}

void main() {
  testWidgets('현재 트랙 제목을 표시한다', (tester) async {
    final fake = _Fake();
    final pl = await _pump(tester, fake);
    pl.select(1);
    await tester.pump();
    expect(find.text('T clf-t1-2'), findsOneWidget);
  });

  testWidgets('재생 버튼 탭이 playlist.playPause 경유로 backend.play 호출', (tester) async {
    final fake = _Fake();
    await _pump(tester, fake);
    await tester.tap(find.bySemanticsLabel('재생'));
    await tester.pump();
    expect(fake.playCalls, 1);
  });

  testWidgets('playing 상태면 일시정지 시맨틱·탭 시 pause', (tester) async {
    final fake = _Fake();
    await _pump(tester, fake);
    fake.emit(AudioEvent.playing);
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('일시정지'));
    await tester.pump();
    expect(fake.pauseCalls, 1);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_audio_player_test.dart`
Expected: FAIL — `StudyAudioPlayer`가 아직 `controller`/`title`/`audioSrc` 시그니처(playlist 미지원).

- [ ] **Step 3: StudyAudioPlayer 재작성**

Replace `flutter_app/lib/widgets/study_audio_player.dart` 전체:

```dart
import 'package:flutter/material.dart';

import '../data/audio_controller.dart';
import '../data/lecture_playlist.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';

/// 학습 문서 오디오 강의("주머니 라디오") — 하단 고정 미니 플레이어(UI).
///
/// 전역 [LecturePlaylist]의 현재 트랙 제목·재생 상태를 구독해 재생/일시정지와
/// 상태 안내를 그린다. 로딩(트랙 load)은 호출부(study_doc_page의 openDoc /
/// CertAudioPage의 select) 책임 — 이 위젯은 표시·토글만 한다.
///
/// DESIGN.md: context.c 토큰만 · InkWell+FocusRing · State Views 보이스 ·
/// 합니다체. 오디오 실패는 부분 degrade라 wrong 색을 쓰지 않는다.
class StudyAudioPlayer extends StatelessWidget {
  const StudyAudioPlayer({super.key, required this.playlist});

  /// 전역 플레이리스트(소유하지 않음 — dispose에서 정리 금지).
  final LecturePlaylist playlist;

  String? _statusLine(PlaybackState s) => switch (s) {
        PlaybackState.loading => '오디오를 준비하고 있습니다…',
        PlaybackState.error => '오디오를 재생하지 못했습니다.',
        PlaybackState.playing => '재생 중입니다.',
        PlaybackState.paused => '일시정지했습니다.',
        PlaybackState.ended => '재생을 마쳤습니다.',
        PlaybackState.idle => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
          child: ListenableBuilder(
            listenable: playlist,
            builder: (context, _) {
              final state = playlist.state;
              final isPlaying = state == PlaybackState.playing;
              final status = _statusLine(state);
              return Row(
                children: [
                  PlayPauseButton(
                      isPlaying: isPlaying, onTap: playlist.playPause),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.currentTitle ?? '오디오 강의',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontVariations: Wght.w700,
                            color: c.text,
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              fontVariations: Wght.w400,
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 재생/일시정지 토글 — 액센트 원형 아이콘 버튼(InkWell+FocusRing, DESIGN.md).
/// 트랜스포트 바와 공유한다.
class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({super.key, required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Material(
        color: c.accent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: c.onAccent,
                size: 24,
                semanticLabel: isPlaying ? '일시정지' : '재생',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_audio_player_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/widgets/study_audio_player.dart flutter_app/test/study_audio_player_test.dart
git commit -m "refactor(audio): StudyAudioPlayer를 LecturePlaylist 기반으로(auto-load 제거, 현재 트랙 표시)"
```

---

## Task 5: LectureTransportBar 위젯

**Files:**
- Create: `flutter_app/lib/widgets/lecture_transport_bar.dart`
- Test: `flutter_app/test/lecture_transport_bar_test.dart`

**Interfaces:**
- Consumes: `LecturePlaylist`(`currentTitle`, `state`, `hasPrev`, `hasNext`, `first/prev/playPause/next/last`) from Task 3; `PlayPauseButton` from Task 4(`study_audio_player.dart`).
- Produces: `LectureTransportBar({required LecturePlaylist playlist})` — 하단 고정 트랜스포트(처음·이전·재생/정지·다음·마지막 + 현재 제목·상태).

- [ ] **Step 1: 실패 테스트 작성**

Create `flutter_app/test/lecture_transport_bar_test.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_controller.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:aws_docs/data/lecture_playlist.dart';
import 'package:aws_docs/widgets/lecture_transport_bar.dart';

class _Fake implements AudioBackend {
  final _ev = StreamController<AudioEvent>.broadcast();
  int playCalls = 0;
  String? src;
  @override
  Stream<AudioEvent> get events => _ev.stream;
  @override
  void setSrc(String s) => src = s;
  @override
  Future<void> play() async => playCalls++;
  @override
  void pause() {}
  @override
  void dispose() => _ev.close();
}

ContentEntry _e(String t) => ContentEntry(
    certCode: 'CLF-C02', taskId: t, title: 'T $t', domain: 1,
    mdAsset: 'a', questionsAsset: 'b', questionCount: 0, audioApproved: true);

Future<LecturePlaylist> _pump(WidgetTester tester, {int start = 0}) async {
  final pl = LecturePlaylist(controller: AudioController(backend: _Fake()));
  pl.setQueue('CLF-C02', [_e('clf-t1-1'), _e('clf-t1-2'), _e('clf-t1-3')],
      startIndex: start);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(bottomNavigationBar: LectureTransportBar(playlist: pl)),
  ));
  return pl;
}

void main() {
  testWidgets('다음 버튼 탭이 index를 증가시킨다', (tester) async {
    final pl = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('다음 강의'));
    await tester.pump();
    expect(pl.index, 1);
  });

  testWidgets('마지막 버튼 탭이 마지막 트랙으로 점프', (tester) async {
    final pl = await _pump(tester);
    await tester.tap(find.bySemanticsLabel('마지막 강의'));
    await tester.pump();
    expect(pl.index, 2);
  });

  testWidgets('처음 트랙에선 이전 탭이 no-op', (tester) async {
    final pl = await _pump(tester, start: 0);
    await tester.tap(find.bySemanticsLabel('이전 강의'));
    await tester.pump();
    expect(pl.index, 0);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/lecture_transport_bar_test.dart`
Expected: FAIL — `lecture_transport_bar.dart`/`LectureTransportBar` 미정의.

- [ ] **Step 3: 구현**

Create `flutter_app/lib/widgets/lecture_transport_bar.dart`:

```dart
import 'package:flutter/material.dart';

import '../data/audio_controller.dart';
import '../data/lecture_playlist.dart';
import '../theme/app_theme.dart';
import 'focus_ring.dart';
import 'study_audio_player.dart' show PlayPauseButton;

/// 자격증 오디오 페이지 하단 고정 트랜스포트(A안). 좌→우: 처음·이전·재생/정지·
/// 다음·마지막 + 현재 트랙 제목·상태. 경계(첫/끝)에선 해당 버튼 muted+no-op.
/// DESIGN.md: context.c 토큰 · InkWell+FocusRing · 합니다체 · disabled 회피(muted).
class LectureTransportBar extends StatelessWidget {
  const LectureTransportBar({super.key, required this.playlist});

  final LecturePlaylist playlist;

  String? _statusLine(PlaybackState s) => switch (s) {
        PlaybackState.loading => '오디오를 준비하고 있습니다…',
        PlaybackState.error => '오디오를 재생하지 못했습니다.',
        PlaybackState.playing => '재생 중입니다.',
        PlaybackState.paused => '일시정지했습니다.',
        PlaybackState.ended => '재생을 마쳤습니다. 다음 강의를 들어 보세요.',
        PlaybackState.idle => null,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
          child: ListenableBuilder(
            listenable: playlist,
            builder: (context, _) {
              final isPlaying = playlist.state == PlaybackState.playing;
              final status = _statusLine(playlist.state);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StepButton(
                        icon: Icons.skip_previous,
                        semantic: '처음 강의',
                        enabled: playlist.hasPrev,
                        onTap: playlist.first,
                      ),
                      const SizedBox(width: Gap.sm),
                      _StepButton(
                        icon: Icons.fast_rewind,
                        semantic: '이전 강의',
                        enabled: playlist.hasPrev,
                        onTap: playlist.prev,
                      ),
                      const SizedBox(width: Gap.md),
                      PlayPauseButton(
                          isPlaying: isPlaying, onTap: playlist.playPause),
                      const SizedBox(width: Gap.md),
                      _StepButton(
                        icon: Icons.fast_forward,
                        semantic: '다음 강의',
                        enabled: playlist.hasNext,
                        onTap: playlist.next,
                      ),
                      const SizedBox(width: Gap.sm),
                      _StepButton(
                        icon: Icons.skip_next,
                        semantic: '마지막 강의',
                        enabled: playlist.hasNext,
                        onTap: playlist.last,
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.sm),
                  Text(
                    playlist.currentTitle ?? '오디오 강의',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontVariations: Wght.w700,
                      color: c.text,
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontVariations: Wght.w400,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 트랜스포트 보조 버튼 — enabled=false면 muted 색·탭 무반응(disabled 위젯 회피).
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semantic,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String semantic;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Tooltip(
        message: semantic,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(Radii.full),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.border),
            ),
            child: Icon(
              icon,
              size: 22,
              color: enabled ? c.textMuted : c.textFaint,
              semanticLabel: semantic,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/lecture_transport_bar_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/widgets/lecture_transport_bar.dart flutter_app/test/lecture_transport_bar_test.dart
git commit -m "feat(audio): LectureTransportBar 하단 트랜스포트(처음/이전/재생정지/다음/마지막)"
```

---

## Task 6: CertAudioPage + 라우트

**Files:**
- Create: `flutter_app/lib/pages/cert_audio_page.dart`
- Modify: `flutter_app/lib/app_router.dart` (cert/:code 하위에 audio 라우트)
- Test: `flutter_app/test/app_router_test.dart` (추가)

**Interfaces:**
- Consumes: `lecturePlaylist`(audio_runtime.dart), `approvedAudioEntries`(content_index.dart), `audioLectureEnabled`·`certAudioRedirect`(audio_nav.dart), `LectureTransportBar`(Task 5), `AppHeader.document`(app_header.dart), `certByCode`(cert_lookup.dart), `Certification`(models). `context.go`.
- Produces: `class CertAudioPage extends StatefulWidget { CertAudioPage({required Certification cert}) }` — 트랙 목록 + 트랜스포트. 라우트 `/cert/:code/audio`.

- [ ] **Step 1: 실패 테스트 작성(라우터 redirect 안전 케이스)**

`flutter_app/test/app_router_test.dart`의 `main()` 안 마지막 test 다음에 추가(파일 상단 import에 필요 시 `CertDetailPage`는 이미 있음):

```dart
  testWidgets('게이트 off에서 "/cert/CLF-C02/audio" → "/"로 redirect(HomePage)',
      (tester) async {
    // audioLectureEnabled는 dart-define 미지정 시 false → 안전 페이지로.
    await tester.pumpWidget(MaterialApp.router(
        routerConfig: createRouter(initialLocation: '/cert/CLF-C02/audio')));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('게이트 off에서 "/audio" → "/"로 redirect(HomePage)', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
        routerConfig: createRouter(initialLocation: '/audio')));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
```

(주의: 이 두 test 중 `/audio`는 Task 7에서 라우트가 생긴 뒤 통과한다. Task 6에선 `/cert/.../audio` test만 먼저 통과시키고 `/audio` test는 Task 7에서 통과. 한 번에 추가하되 Task 6 통과 기준은 cert audio redirect test다.)

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/app_router_test.dart`
Expected: FAIL — `/cert/CLF-C02/audio` 라우트 미정의 → 에러 페이지(`_RouteErrorPage`) 렌더라 HomePage 미발견.

- [ ] **Step 3: CertAudioPage 구현**

Create `flutter_app/lib/pages/cert_audio_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/audio_runtime.dart';
import '../data/content_index.dart';
import '../data/lecture_playlist.dart';
import '../models/certification.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/focus_ring.dart';
import '../widgets/lecture_transport_bar.dart';

/// 자격증별 오디오 학습 페이지(A안) — 승인 오디오 강의 목록 + 하단 트랜스포트.
/// 진입 시 전역 플레이리스트가 이 cert 큐가 아니면 setQueue(자동재생 안 함).
/// 행 탭=그 트랙 재생(select), "문서 보기"=학습문서로 이동(재생 유지).
class CertAudioPage extends StatefulWidget {
  const CertAudioPage({super.key, required this.cert});

  final Certification cert;

  @override
  State<CertAudioPage> createState() => _CertAudioPageState();
}

class _CertAudioPageState extends State<CertAudioPage> {
  @override
  void initState() {
    super.initState();
    final pl = lecturePlaylist;
    if (pl != null && pl.certCode != widget.cert.code) {
      pl.setQueue(widget.cert.code, approvedAudioEntries(widget.cert.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pl = lecturePlaylist;
    final tracks = approvedAudioEntries(widget.cert.code);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppHeader.document(
        backLabel: widget.cert.code,
        title: '오디오 강의',
      ),
      bottomNavigationBar: pl == null ? null : LectureTransportBar(playlist: pl),
      body: pl == null
          ? Center(
              child: Text('오디오는 웹에서만 재생할 수 있습니다.',
                  style: TextStyle(color: c.textMuted)))
          : ListenableBuilder(
              listenable: pl,
              builder: (context, _) => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                itemCount: tracks.length,
                itemBuilder: (context, i) => _TrackRow(
                  index: i,
                  entry: tracks[i],
                  current: pl.index == i,
                  onPlay: () => pl.select(i),
                  onOpenDoc: () => context.go(
                      '/cert/${widget.cert.code}/study/${tracks[i].taskId}'),
                ),
              ),
            ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  const _TrackRow({
    required this.index,
    required this.entry,
    required this.current,
    required this.onPlay,
    required this.onOpenDoc,
  });

  final int index;
  final ContentEntry entry;
  final bool current;
  final VoidCallback onPlay;
  final VoidCallback onOpenDoc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: current ? c.surface2 : null,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FocusRing(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: InkWell(
                onTap: onPlay,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Gap.lg, vertical: Gap.md),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${index + 1}',
                            style: TextStyle(
                                fontSize: 13,
                                color: c.textMuted,
                                fontFeatures: const []),
                            textAlign: TextAlign.right),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                current ? FontWeight.w700 : FontWeight.w500,
                            fontVariations:
                                current ? Wght.w700 : Wght.w500,
                            color: current ? c.accent : c.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          FocusRing(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: InkWell(
              onTap: onOpenDoc,
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Gap.lg, vertical: Gap.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 16, color: c.textMuted),
                    const SizedBox(width: 4),
                    Text('문서 보기',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontVariations: Wght.w600,
                            color: c.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 라우트 추가**

`lib/app_router.dart` 상단 import에 추가:

```dart
import 'data/audio_nav.dart';
import 'data/audio_runtime.dart' show audioLectureEnabled;
import 'data/content_index.dart' show approvedAudioEntries;
import 'pages/cert_audio_page.dart';
```

그리고 `cert/:code`의 `routes:` 배열(약 31~100행, `exam`/`review` 등 형제) 안에 추가(예: `plan` GoRoute 다음):

```dart
                GoRoute(
                  path: 'audio',
                  redirect: (context, state) {
                    final code = state.pathParameters['code']!;
                    return certAudioRedirect(
                      certExists: certByCode(code) != null,
                      enabled: audioLectureEnabled,
                      hasAudio: approvedAudioEntries(code).isNotEmpty,
                      code: code,
                    );
                  },
                  builder: (context, state) => CertAudioPage(
                      cert: certByCode(state.pathParameters['code']!)!),
                ),
```

- [ ] **Step 5: 통과 확인(cert audio redirect)**

Run: `cd flutter_app && flutter test test/app_router_test.dart -p vm 2>&1 | head` (또는 그냥 `flutter test test/app_router_test.dart`)
Expected: `/cert/CLF-C02/audio → "/"` test PASS. (`/audio` test는 Task 7 전까지 FAIL 가능 — Task 7에서 통과.)

> 임시: `/audio` test가 Task 7 전이라 실패하면, Task 6 커밋 시 그 test를 잠시 `skip:`하지 말고 Task 7과 함께 묶어 통과시킨다. 권장 순서는 Task 6→7 연속 구현 후 한 번에 `flutter test test/app_router_test.dart` 통과 확인.

- [ ] **Step 6: 분석·커밋**

Run: `cd flutter_app && flutter analyze lib/pages/cert_audio_page.dart lib/app_router.dart`
Expected: 신규 0건.

```bash
git add flutter_app/lib/pages/cert_audio_page.dart flutter_app/lib/app_router.dart flutter_app/test/app_router_test.dart
git commit -m "feat(audio): CertAudioPage + /cert/:code/audio 라우트·redirect"
```

---

## Task 7: AudioHubPage + 라우트

**Files:**
- Create: `flutter_app/lib/pages/audio_hub_page.dart`
- Modify: `flutter_app/lib/app_router.dart` (top-level `/audio`)
- Test: `flutter_app/test/app_router_test.dart` (Task 6의 `/audio` test 통과)

**Interfaces:**
- Consumes: `certsWithApprovedAudio`(content_index.dart), `audioLectureEnabled`·`audioHubRedirect`(audio_nav.dart), `certByCode`(cert_lookup.dart), `AppHeader.document`, `context.go`.
- Produces: `class AudioHubPage extends StatelessWidget` — 승인 오디오 보유 자격증 카드 목록. 라우트 `/audio`.

- [ ] **Step 1: 실패 확인(기존 `/audio` test)**

Run: `cd flutter_app && flutter test test/app_router_test.dart`
Expected: `/audio → "/"` test FAIL(라우트 없음 → 에러 페이지).

- [ ] **Step 2: AudioHubPage 구현**

Create `flutter_app/lib/pages/audio_hub_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/cert_lookup.dart';
import '../data/content_index.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/focus_ring.dart';

/// 오디오 허브 — 승인 오디오 강의를 가진 자격증 목록. 각 항목 → /cert/:code/audio.
class AudioHubPage extends StatelessWidget {
  const AudioHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final codes = certsWithApprovedAudio();
    return Scaffold(
      backgroundColor: c.bg,
      appBar: const AppHeader.document(title: '오디오 강의'),
      body: ListView(
        padding: const EdgeInsets.all(Gap.lg),
        children: [
          for (final code in codes)
            _CertCard(
              code: code,
              count: approvedAudioEntries(code).length,
              onTap: () => context.go('/cert/$code/audio'),
            ),
        ],
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  const _CertCard(
      {required this.code, required this.count, required this.onTap});

  final String code;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cert = certByCode(code);
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: FocusRing(
        borderRadius: BorderRadius.circular(Radii.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Container(
            padding: const EdgeInsets.all(Gap.lg),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.headphones_outlined, size: 22, color: c.accent),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cert?.code ?? code,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontVariations: Wght.w700,
                              color: c.text)),
                      const SizedBox(height: 2),
                      Text('강의 $count개',
                          style:
                              TextStyle(fontSize: 13, color: c.textMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: c.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 라우트 추가**

`lib/app_router.dart` 상단 import에 `import 'pages/audio_hub_page.dart';` 추가. 그리고 최상위 `routes:` 배열에서 `path: '/'` GoRoute(약 21행) **다음 형제**로 추가:

```dart
        GoRoute(
          path: '/audio',
          redirect: (context, state) => audioHubRedirect(
            enabled: audioLectureEnabled,
            hasAudio: certsWithApprovedAudio().isNotEmpty,
          ),
          builder: (context, state) => const AudioHubPage(),
        ),
```

(상단 import에 `import 'data/content_index.dart' show approvedAudioEntries, certsWithApprovedAudio;`로 갱신 — Task 6에서 추가한 show 목록에 `certsWithApprovedAudio` 추가.)

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/app_router_test.dart`
Expected: PASS — `/cert/CLF-C02/audio → "/"`·`/audio → "/"` 둘 다 HomePage.

- [ ] **Step 5: 분석·커밋**

Run: `cd flutter_app && flutter analyze lib/pages/audio_hub_page.dart lib/app_router.dart`
Expected: 신규 0건.

```bash
git add flutter_app/lib/pages/audio_hub_page.dart flutter_app/lib/app_router.dart
git commit -m "feat(audio): AudioHubPage + /audio 라우트·redirect"
```

---

## Task 8: 상단 메뉴 진입점 + study_doc 정합 + 전체 검증

**Files:**
- Modify: `flutter_app/lib/pages/home_page.dart` (onNav '오디오' 조건부)
- Modify: `flutter_app/lib/pages/study_doc_page.dart` (_onDocReady openDoc, _miniPlayer playlist)
- Test: 전체 `flutter test`·`flutter analyze`

**Interfaces:**
- Consumes: `shouldShowAudioMenu`(audio_nav.dart), `certsWithApprovedAudio`(content_index.dart), `audioLectureEnabled`·`lecturePlaylist`(audio_runtime.dart), `shouldShowLecturePlayer`(audio_runtime.dart), `StudyAudioPlayer({required playlist})`(Task 4).

- [ ] **Step 1: home_page 상단 메뉴 '오디오' 추가**

`lib/pages/home_page.dart` 상단 import에 추가:

```dart
import '../data/audio_nav.dart';
import '../data/audio_runtime.dart' show audioLectureEnabled;
import '../data/content_index.dart' show certsWithApprovedAudio;
```

`onNav: { ... }` 맵(약 156~163행)에서, 빌드 메서드 안 `final c = context.c;` 다음에 조건 계산을 두고 onNav를 동적으로 구성한다. `HomeHeader(onResetAll: ..., onNav: {...})` 부분을 아래로 교체:

```dart
      appBar: HomeHeader(
        onResetAll: _resetAll,
        onNav: {
          '단계': () => _goto(_levels),
          '추천 순서': () => _goto(_paths),
          '로드맵': () => _goto(_roadmaps),
          '학습 문서': () => _goto(_docs),
          '모의고사': () => _goto(_exams),
          '일정': () => _goto(_schedule),
          if (shouldShowAudioMenu(
              enabled: audioLectureEnabled,
              hasAudio: certsWithApprovedAudio().isNotEmpty))
            '오디오': () => context.go('/audio'),
        },
      ),
```

(`context.go`는 home_page가 이미 `import 'package:go_router/go_router.dart';` 함 — 확인됨.)

- [ ] **Step 2: study_doc_page 정합 — openDoc + playlist 미니플레이어**

`lib/pages/study_doc_page.dart` 상단 import에 `import '../data/lecture_playlist.dart';`가 필요하면 추가(아래 코드는 `lecturePlaylist` getter 사용 — 이미 `audio_runtime.dart` import됨이면 추가 import 불필요. import 목록 확인 후 없으면 추가).

`_onDocReady`의 오디오 블록(약 67~70행)을 교체:

```dart
    // 오디오 강의(주머니 라디오): 잠금화면 메타 + 플레이리스트 비중단 정합 —
    // 웹·dart-define on·검수 승인일 때만.
    if (audioLectureEnabled && widget.entry.audioApproved) {
      audioRuntime?.nowPlaying(widget.entry.title);
      lecturePlaylist?.openDoc(widget.entry.certCode, widget.entry.taskId);
    }
```

`_miniPlayer`(약 99~114행)를 교체:

```dart
  Widget? _miniPlayer(StudyContent? doc) {
    final pl = lecturePlaylist;
    if (!shouldShowLecturePlayer(
      enabled: audioLectureEnabled,
      approved: widget.entry.audioApproved,
      hasDoc: doc != null,
      hasRuntime: pl != null,
    )) {
      return null;
    }
    return StudyAudioPlayer(playlist: pl!);
  }
```

- [ ] **Step 3: 전체 테스트 통과 확인**

Run: `cd flutter_app && flutter test`
Expected: 전부 PASS(신규 테스트 포함). 실패 시 해당 파일만 재실행해 원인 규명.

- [ ] **Step 4: 정적 분석 게이트**

Run: `cd flutter_app && flutter analyze`
Expected: 신규 경고/에러 0건(기존 잔존 3건 외 새 항목 없음).

- [ ] **Step 5: 웹 빌드 검증(배포 산출물)**

Run(PowerShell, Git Bash 금지): `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true`
Expected: 빌드 성공(웹 경로 컴파일 — 조건부 import·lecturePlaylist 웹 분기 검증).

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/pages/home_page.dart flutter_app/lib/pages/study_doc_page.dart
git commit -m "feat(audio): 상단 메뉴 오디오 진입점 + study_doc 플레이리스트 정합(openDoc)"
```

---

## Self-Review (작성자 점검 결과)

1. **Spec coverage:**
   - 진입 모델(허브→cert) = Task 6·7(+8 메뉴). 재생 흐름 수동 전환 = Task 3(ended 인덱스 불변)·5(경계 muted). 연속성(전역) = Task 3 전역 getter·8 openDoc 비중단. A안 레이아웃 = Task 5·6. 통합 플레이리스트 = Task 3·4·8. 게이트 헬퍼 = Task 1·2. 테스트 전략 = 각 Task 단위/위젯/라우터. 누락 없음.
2. **Placeholder scan:** 모든 코드 step에 실제 코드·정확한 명령·기대 출력. TBD/TODO 없음. (Task 6 Step 5의 `/audio` test 임시 처리만 명시적 주석으로 안내 — Task 7에서 통과.)
3. **Type consistency:** `LecturePlaylist` 메서드(`setQueue`/`openDoc`/`select`/`next`/`prev`/`first`/`last`/`playPause`/`currentTitle`/`state`/`hasPrev`/`hasNext`)가 Task 3 정의와 Task 4·5·6·8 호출에서 일치. `StudyAudioPlayer({required playlist})`가 Task 4 정의·Task 8 호출 일치. `PlayPauseButton`(Task 4) → Task 5 재사용. `approvedAudioEntries`/`certsWithApprovedAudio`(Task 1) → 3·6·7·8. `shouldShowAudioMenu`/`audioHubRedirect`/`certAudioRedirect`(Task 2) → 6·7·8. `lecturePlaylist` getter(Task 3) → 6·8. 일관.
