# 오디오 타임바 + 재생 모드 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 자격증 오디오 페이지·학습문서 미니플레이어에 탐색(seek) 가능한 타임바와 재생 모드(단일/전체 자동/반복, 기본 전체 자동)를 추가한다.

**Architecture:** `AudioBackend`에 seek·positionStream·duration을 더하고, `AudioController`가 위치/길이를 (상태 ChangeNotifier와 분리된) `ValueNotifier`로 노출한다. `LecturePlaylist`에 `PlayMode`와 ended 처리(모드별 자동전환/반복/정지)를 더하고 위치/seek를 통과시킨다. 공유 `AudioProgressBar` 위젯을 트랜스포트 바·미니플레이어가 함께 쓴다.

**Tech Stack:** Flutter Web (Dart), `package:web`(WebAudioBackend), ChangeNotifier/ValueNotifier. 테스트 `flutter test`, 분석 `flutter analyze`, 웹 빌드 `flutter build web`.

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 게이트: `flutter test` 전부 통과, `flutter analyze` **신규 0건**(기존 잔존 3건: plan_agenda cacheExtent·sync_controller_test 2건), `flutter build web --dart-define=audio_lecture=true` 성공.
- TDD: 기능마다 실패 테스트 선작성 → 최소 구현 → 통과 확인 → 커밋. Flutter는 `flutter` CLI.
- **`AudioBackend` 인터페이스 확장은 `implements AudioBackend`인 4개 테스트 fake를 모두 깬다**: `audio_controller_test.dart`(FakeAudioBackend), `lecture_playlist_test.dart`·`study_audio_player_test.dart`·`lecture_transport_bar_test.dart`(각 `_Fake`). Task 1에서 4개 모두 새 멤버를 추가해 전체 suite를 green으로 유지한다.
- 위치 갱신(~4Hz)은 `AudioController`의 **state(ChangeNotifier)와 분리된** `ValueNotifier<Duration> position`·`ValueNotifier<Duration?> duration`으로 노출(타임바만 구독 — 과리빌드 방지).
- 재생 모드: `enum PlayMode { single, autoAll, repeatOne }`, 기본 `autoAll`, `cycleMode` 순환 `autoAll→repeatOne→single→autoAll`. autoAll은 마지막 트랙에서 정지(리스트 루프 안 함). repeatOne은 ended 시 현재 트랙 재로드. 전역·인메모리(저장 안 함).
- iOS: autoAll 자동전환은 `next()`(load+play 시도) — 차단되면 다음 트랙이 로드된 채 멈춤(부분 degrade, wrong색 금지). 잠금화면은 M1 T6 별개.
- DESIGN.md: `context.c` 토큰만 · InkWell+FocusRing · 합니다체 · 비-fatal 오디오 실패에 wrong색 금지 · 새 fontWeight엔 `Wght.*` 병기.
- 커밋 직전 `git branch --show-current`로 `feat/audio-timebar-modes` 확인. 다른 세션 untracked(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`) 절대 `git add` 금지.
- 비목표(YAGNI): ② 제목별 타임스탬프(별도 후속) · 모드/위치 localStorage 저장 · 미디어세션 스크럽/위치 · 재생속도.

## File Structure

- Modify `lib/data/audio_controller.dart` — `AudioBackend` +seek/positionStream/duration; `AudioController` +position/duration/seek.
- Modify `lib/data/web_audio_backend.dart` — timeupdate→positionStream, seek, duration.
- Modify `lib/data/lecture_playlist.dart` — `PlayMode`, mode/cycleMode, ended 처리, position/duration/seek 통과.
- Create `lib/widgets/audio_progress_bar.dart` — 공유 타임바.
- Modify `lib/widgets/lecture_transport_bar.dart` — 모드 토글 + 타임바.
- Modify `lib/widgets/study_audio_player.dart` — 타임바.
- Tests: `test/audio_controller_test.dart`·`test/lecture_playlist_test.dart`·`test/study_audio_player_test.dart`·`test/lecture_transport_bar_test.dart`(수정), `test/audio_progress_bar_test.dart`(신규).

---

## Task 1: AudioBackend·AudioController 위치/길이/seek

**Files:**
- Modify: `flutter_app/lib/data/audio_controller.dart`
- Modify: `flutter_app/lib/data/web_audio_backend.dart`
- Modify: `flutter_app/test/audio_controller_test.dart`(FakeAudioBackend + 새 테스트)
- Modify: `flutter_app/test/lecture_playlist_test.dart`·`test/study_audio_player_test.dart`·`test/lecture_transport_bar_test.dart`(각 `_Fake`에 새 멤버 stub — 컴파일 유지)

**Interfaces:**
- Produces:
  - `AudioBackend`에 `void seek(double seconds)`, `Stream<Duration> get positionStream`, `Duration? get duration` 추가(abstract).
  - `AudioController`에 `final ValueNotifier<Duration> position`, `final ValueNotifier<Duration?> duration`, `void seek(Duration to)`.

- [ ] **Step 1: 실패 테스트 작성**

`test/audio_controller_test.dart`의 `FakeAudioBackend`(클래스 본문)에 새 멤버를 추가한다 — 기존 멤버 뒤, `void emit(...)` 앞:

```dart
  final _pos = StreamController<Duration>.broadcast();
  double? seekedTo;
  Duration? dur;
  @override
  void seek(double seconds) => seekedTo = seconds;
  @override
  Stream<Duration> get positionStream => _pos.stream;
  @override
  Duration? get duration => dur;
  void emitPos(Duration d) => _pos.add(d);
```

그리고 `main()` 안에 테스트 3개 추가(아무 위치):

```dart
  test('seek는 backend.seek(초) 호출 + position 낙관적 갱신', () {
    final b = FakeAudioBackend();
    final c = AudioController(backend: b);
    c.seek(const Duration(seconds: 30));
    expect(b.seekedTo, 30.0);
    expect(c.position.value, const Duration(seconds: 30));
  });

  test('positionStream 방출 → position·duration 갱신', () async {
    final b = FakeAudioBackend()..dur = const Duration(seconds: 120);
    final c = AudioController(backend: b);
    b.emitPos(const Duration(seconds: 5));
    await Future<void>.delayed(Duration.zero);
    expect(c.position.value, const Duration(seconds: 5));
    expect(c.duration.value, const Duration(seconds: 120));
  });

  test('load는 position 0·duration null 리셋', () {
    final b = FakeAudioBackend()..dur = const Duration(seconds: 120);
    final c = AudioController(backend: b);
    c.load('x.mp3');
    expect(c.position.value, Duration.zero);
    expect(c.duration.value, isNull);
  });
```

- [ ] **Step 2: 다른 3개 fake에 stub 추가(컴파일 유지)**

`test/lecture_playlist_test.dart`, `test/study_audio_player_test.dart`, `test/lecture_transport_bar_test.dart` 각각의 `_Fake` 클래스 본문에 동일 stub 3줄을 추가한다(이미 `import 'dart:async';`가 있으면 그대로):

```dart
  @override
  void seek(double seconds) {}
  @override
  Stream<Duration> get positionStream => const Stream<Duration>.empty();
  @override
  Duration? get duration => null;
```

(`lecture_transport_bar_test.dart`·`study_audio_player_test.dart`의 `_Fake`에 `dart:async` import가 없다면 `const Stream.empty()`는 import 불필요하므로 그대로 동작한다.)

- [ ] **Step 3: 실패 확인**

Run: `cd flutter_app && flutter test test/audio_controller_test.dart`
Expected: FAIL — `AudioController`에 `seek`/`position`/`duration` 미정의(컴파일 에러).

- [ ] **Step 4: AudioBackend·AudioController 구현**

`lib/data/audio_controller.dart`의 `abstract class AudioBackend { ... }` 끝(`void dispose();` 다음)에 추가:

```dart
  /// 지정 초로 탐색.
  void seek(double seconds);

  /// 재생 위치 갱신 스트림(브라우저 timeupdate, ~4Hz).
  Stream<Duration> get positionStream;

  /// 총 길이(메타데이터 로드 전 null).
  Duration? get duration;
```

`AudioController` 생성자에 위치 구독을 더하고 필드·메서드를 추가한다. 생성자:

```dart
  AudioController({required AudioBackend backend}) : _backend = backend {
    _sub = _backend.events.listen(_onEvent);
    _posSub = _backend.positionStream.listen(_onPosition);
  }

  final AudioBackend _backend;
  late final StreamSubscription<AudioEvent> _sub;
  late final StreamSubscription<Duration> _posSub;

  /// 재생 위치·총 길이(상태 ChangeNotifier와 분리 — 타임바만 구독해 과리빌드 방지).
  final ValueNotifier<Duration> position = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration?> duration = ValueNotifier<Duration?>(null);
```

`load`를 위치 리셋 포함으로 교체:

```dart
  void load(String src) {
    _backend.setSrc(src);
    position.value = Duration.zero;
    duration.value = null;
    _set(PlaybackState.loading);
  }
```

`pause()` 다음에 seek·위치 핸들러 추가:

```dart
  /// 지정 위치로 탐색(곧 timeupdate가 확정하나 즉시 반영해 UI 끊김 방지).
  void seek(Duration to) {
    _backend.seek(to.inMilliseconds / 1000.0);
    position.value = to;
  }

  void _onPosition(Duration p) {
    position.value = p;
    duration.value = _backend.duration;
  }
```

`dispose`를 교체:

```dart
  @override
  void dispose() {
    _sub.cancel();
    _posSub.cancel();
    position.dispose();
    duration.dispose();
    super.dispose();
  }
```

- [ ] **Step 5: WebAudioBackend 구현**

`lib/data/web_audio_backend.dart`의 `WebAudioBackend` 생성자에서 기존 `_wire('error', AudioEvent.error);` 다음에 timeupdate 배선 추가:

```dart
    final posListener = ((web.Event _) => _position.add(
        Duration(milliseconds: (_audio.currentTime * 1000).round()))).toJS;
    _audio.addEventListener('timeupdate', posListener);
    _wired.add(('timeupdate', posListener));
```

필드 추가(`_events` 근처):

```dart
  final _position = StreamController<Duration>.broadcast();
```

새 멤버 구현(클래스 본문, `pause()` 다음):

```dart
  @override
  void seek(double seconds) => _audio.currentTime = seconds;

  @override
  Stream<Duration> get positionStream => _position.stream;

  @override
  Duration? get duration {
    final d = _audio.duration;
    if (d.isNaN || d.isInfinite) return null;
    return Duration(milliseconds: (d * 1000).round());
  }
```

`dispose`에 `_position.close();` 추가(`_events.close();` 옆).

- [ ] **Step 6: 통과 확인 + 전체 suite + 웹 빌드**

Run: `cd flutter_app && flutter test test/audio_controller_test.dart`
Expected: PASS(신규 3 포함).

Run: `cd flutter_app && flutter test`
Expected: 전부 PASS(4개 fake 정합으로 컴파일·green).

Run(PowerShell 권장, Git Bash 금지): `flutter build web --dart-define=audio_lecture=true`
Expected: 빌드 성공(WebAudioBackend 변경 컴파일 검증).

- [ ] **Step 7: 커밋**

```bash
git add flutter_app/lib/data/audio_controller.dart flutter_app/lib/data/web_audio_backend.dart flutter_app/test/audio_controller_test.dart flutter_app/test/lecture_playlist_test.dart flutter_app/test/study_audio_player_test.dart flutter_app/test/lecture_transport_bar_test.dart
git commit -m "feat(audio): AudioBackend/AudioController에 위치·길이·seek 추가"
```

---

## Task 2: LecturePlaylist 재생 모드 + 위치 통과

**Files:**
- Modify: `flutter_app/lib/data/lecture_playlist.dart`
- Modify: `flutter_app/test/lecture_playlist_test.dart`

**Interfaces:**
- Consumes: `AudioController.position`/`duration`/`seek`(Task 1).
- Produces:
  - `enum PlayMode { single, autoAll, repeatOne }`
  - `LecturePlaylist`에 `PlayMode get mode`, `void cycleMode()`, ended 자동 처리, `ValueListenable<Duration> get position`, `ValueListenable<Duration?> get duration`, `void seek(Duration to)`.

- [ ] **Step 1: 실패 테스트 작성**

`test/lecture_playlist_test.dart`의 `_Fake`에 seek 기록·position emit을 더한다(Task 1에서 넣은 stub `void seek(...) {}` 등을 아래로 교체):

```dart
  final _pos = StreamController<Duration>.broadcast();
  double? seekedTo;
  Duration? dur;
  @override
  void seek(double seconds) => seekedTo = seconds;
  @override
  Stream<Duration> get positionStream => _pos.stream;
  @override
  Duration? get duration => dur;
```

`main()`에 테스트 추가(`import 'package:aws_docs/data/lecture_playlist.dart';`에 `PlayMode`가 함께 export됨):

```dart
  test('기본 모드는 autoAll', () {
    expect(pl.mode, PlayMode.autoAll);
  });

  test('cycleMode: autoAll→repeatOne→single→autoAll', () {
    pl.cycleMode();
    expect(pl.mode, PlayMode.repeatOne);
    pl.cycleMode();
    expect(pl.mode, PlayMode.single);
    pl.cycleMode();
    expect(pl.mode, PlayMode.autoAll);
  });

  test('autoAll: ended 시 다음 트랙 재생', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(0);
    final loads0 = fake.loads;
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 1);
    expect(fake.loads, loads0 + 1);
  });

  test('autoAll: 마지막 트랙 ended 시 정지(인덱스 불변·추가 로드 없음)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.select(2);
    final loads0 = fake.loads;
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 2);
    expect(fake.loads, loads0);
  });

  test('single: ended 시 정지(인덱스 불변·추가 로드 없음)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.cycleMode(); // repeatOne
    pl.cycleMode(); // single
    pl.select(0);
    final loads0 = fake.loads;
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 0);
    expect(fake.loads, loads0);
  });

  test('repeatOne: ended 시 현재 트랙 재로드(인덱스 불변)', () async {
    pl.setQueue('CLF-C02', tracks);
    pl.cycleMode(); // repeatOne
    pl.select(1);
    final loads0 = fake.loads;
    fake.emit(AudioEvent.ended);
    await Future<void>.delayed(Duration.zero);
    expect(pl.index, 1);
    expect(fake.loads, loads0 + 1);
  });

  test('seek/position 통과', () {
    pl.setQueue('CLF-C02', tracks);
    pl.seek(const Duration(seconds: 10));
    expect(fake.seekedTo, 10.0);
    expect(pl.position.value, const Duration(seconds: 10));
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/lecture_playlist_test.dart`
Expected: FAIL — `PlayMode`/`mode`/`cycleMode`/`pl.position`/`pl.seek` 미정의.

- [ ] **Step 3: 구현**

`lib/data/lecture_playlist.dart` 상단 `library;` 다음, import 위에 enum 추가:

```dart
/// 재생 모드 — single: 트랙 끝나면 정지 / autoAll: 다음 트랙 자동 / repeatOne: 현재 반복.
enum PlayMode { single, autoAll, repeatOne }
```

생성자를 교체(`addListener(notifyListeners)` → `_onControllerChange`):

```dart
  LecturePlaylist({required AudioController controller})
      : _controller = controller {
    _controller.addListener(_onControllerChange);
  }
```

필드 추가(`String _certCode = '';` 다음):

```dart
  PlayMode _mode = PlayMode.autoAll;
  PlaybackState _lastState = PlaybackState.idle;

  PlayMode get mode => _mode;
  ValueListenable<Duration> get position => _controller.position;
  ValueListenable<Duration?> get duration => _controller.duration;
```

getter 영역(`bool get hasNext ...` 다음)에 추가는 위 position/duration로 충분. seek·cycleMode·ended 처리 메서드를 `playPause()` 다음에 추가:

```dart
  void seek(Duration to) => _controller.seek(to);

  /// 모드 순환: autoAll → repeatOne → single → autoAll.
  void cycleMode() {
    _mode = switch (_mode) {
      PlayMode.autoAll => PlayMode.repeatOne,
      PlayMode.repeatOne => PlayMode.single,
      PlayMode.single => PlayMode.autoAll,
    };
    notifyListeners();
  }

  void _onControllerChange() {
    notifyListeners(); // 재생 상태 변화 재방출
    final s = _controller.state;
    final wasEnded = _lastState == PlaybackState.ended;
    _lastState = s;
    if (s == PlaybackState.ended && !wasEnded) _handleEnded();
  }

  void _handleEnded() {
    switch (_mode) {
      case PlayMode.single:
        break;
      case PlayMode.autoAll:
        if (hasNext) next();
        break;
      case PlayMode.repeatOne:
        _restartCurrent();
        break;
    }
  }

  /// 반복 — select(i)는 같은 트랙 재선택 시 재시작하지 않으므로 직접 load+play.
  void _restartCurrent() {
    final c = current;
    if (c == null) return;
    _controller.load(c.lectureAudioSrc);
    _controller.play();
  }
```

`dispose`를 교체(`removeListener(notifyListeners)` → `_onControllerChange`):

```dart
  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    super.dispose();
  }
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/lecture_playlist_test.dart`
Expected: PASS(기존 + 신규 7).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/lecture_playlist.dart flutter_app/test/lecture_playlist_test.dart
git commit -m "feat(audio): LecturePlaylist 재생 모드(단일/전체자동/반복) + 위치·seek 통과"
```

---

## Task 3: AudioProgressBar 공유 위젯

**Files:**
- Create: `flutter_app/lib/widgets/audio_progress_bar.dart`
- Test: `flutter_app/test/audio_progress_bar_test.dart`

**Interfaces:**
- Produces: `AudioProgressBar({required ValueListenable<Duration> position, required ValueListenable<Duration?> duration, required void Function(Duration) onSeek})`.

- [ ] **Step 1: 실패 테스트 작성**

Create `test/audio_progress_bar_test.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/theme/app_theme.dart';
import 'package:aws_docs/widgets/audio_progress_bar.dart';

Future<void> _pump(WidgetTester tester,
    {required Duration pos, Duration? dur, void Function(Duration)? onSeek}) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 360,
          child: AudioProgressBar(
            position: ValueNotifier<Duration>(pos),
            duration: ValueNotifier<Duration?>(dur),
            onSeek: onSeek ?? (_) {},
          ),
        ),
      ),
    ),
  ));
}

void main() {
  testWidgets('위치·길이를 mm:ss로 표시', (tester) async {
    await _pump(tester,
        pos: const Duration(seconds: 30), dur: const Duration(seconds: 125));
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('2:05'), findsOneWidget);
  });

  testWidgets('duration null이면 총 시간 --:--', (tester) async {
    await _pump(tester, pos: Duration.zero, dur: null);
    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('슬라이더 드래그 종료 시 onSeek 호출', (tester) async {
    Duration? seeked;
    await _pump(tester,
        pos: Duration.zero,
        dur: const Duration(seconds: 100),
        onSeek: (d) => seeked = d);
    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pump();
    expect(seeked, isNotNull);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/audio_progress_bar_test.dart`
Expected: FAIL — `audio_progress_bar.dart`/`AudioProgressBar` 미정의.

- [ ] **Step 3: 구현**

Create `lib/widgets/audio_progress_bar.dart`:

```dart
import 'dart:ui' show FontFeature;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 공유 오디오 타임바 — 위치/길이 표시 + 드래그/탭 탐색(seek).
/// 트랜스포트 바·미니플레이어가 함께 쓴다. position/duration은 컨트롤러의
/// ValueListenable을 구독(상태 ChangeNotifier와 분리 — 과리빌드 방지).
/// DESIGN.md: context.c 토큰 · accent 슬라이더.
class AudioProgressBar extends StatefulWidget {
  const AudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final ValueListenable<Duration> position;
  final ValueListenable<Duration?> duration;
  final void Function(Duration) onSeek;

  @override
  State<AudioProgressBar> createState() => _AudioProgressBarState();
}

class _AudioProgressBarState extends State<AudioProgressBar> {
  double? _dragMs; // 드래그 중 로컬 값(ms) — 놓을 때만 onSeek

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final timeStyle = TextStyle(
      fontSize: 12,
      color: c.textMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return ValueListenableBuilder<Duration?>(
      valueListenable: widget.duration,
      builder: (context, dur, _) => ValueListenableBuilder<Duration>(
        valueListenable: widget.position,
        builder: (context, pos, __) {
          final totalMs = (dur?.inMilliseconds ?? 0).toDouble();
          final hasDur = totalMs > 0;
          final curMs =
              (_dragMs ?? pos.inMilliseconds.toDouble()).clamp(0.0, hasDur ? totalMs : 0.0);
          return Row(
            children: [
              Text(_fmt(Duration(milliseconds: curMs.round())), style: timeStyle),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: c.accent,
                    inactiveTrackColor: c.border,
                    thumbColor: c.accent,
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: hasDur ? curMs : 0.0,
                    max: hasDur ? totalMs : 1.0,
                    onChanged:
                        hasDur ? (v) => setState(() => _dragMs = v) : null,
                    onChangeEnd: hasDur
                        ? (v) {
                            widget.onSeek(Duration(milliseconds: v.round()));
                            setState(() => _dragMs = null);
                          }
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Text(hasDur ? _fmt(dur!) : '--:--', style: timeStyle),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/audio_progress_bar_test.dart`
Expected: PASS(3).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/widgets/audio_progress_bar.dart flutter_app/test/audio_progress_bar_test.dart
git commit -m "feat(audio): 공유 AudioProgressBar(seek 타임바)"
```

---

## Task 4: LectureTransportBar — 모드 토글 + 타임바

**Files:**
- Modify: `flutter_app/lib/widgets/lecture_transport_bar.dart`
- Modify: `flutter_app/test/lecture_transport_bar_test.dart`

**Interfaces:**
- Consumes: `LecturePlaylist`(`mode`/`cycleMode`/`position`/`duration`/`seek`)(Task 2), `AudioProgressBar`(Task 3), `PlayMode`(lecture_playlist.dart).

- [ ] **Step 1: 실패 테스트 작성**

`test/lecture_transport_bar_test.dart`의 `main()`에 추가(상단 import에 `import 'package:aws_docs/widgets/audio_progress_bar.dart';` 추가):

```dart
  testWidgets('모드 토글 탭이 cycleMode 호출(autoAll→repeatOne)', (tester) async {
    final pl = await _pump(tester);
    expect(pl.mode, PlayMode.autoAll);
    await tester.tap(find.bySemanticsLabel('전체 자동 재생'));
    await tester.pump();
    expect(pl.mode, PlayMode.repeatOne);
  });

  testWidgets('타임바(AudioProgressBar)가 있다', (tester) async {
    await _pump(tester);
    expect(find.byType(AudioProgressBar), findsOneWidget);
  });
```

(`_pump`가 `LecturePlaylist`를 반환하지 않으면, 기존 헬퍼가 반환하도록 돼 있다 — 기존 테스트가 `final pl = await _pump(tester);`를 쓰므로 그대로 사용. `PlayMode`는 `lecture_playlist.dart` import로 이미 가시.)

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/lecture_transport_bar_test.dart`
Expected: FAIL — 모드 토글(`전체 자동 재생` semantic)·`AudioProgressBar` 없음.

- [ ] **Step 3: 구현**

`lib/widgets/lecture_transport_bar.dart` 상단 import에 추가:

```dart
import 'audio_progress_bar.dart';
```

`build`의 `ListenableBuilder` builder가 반환하는 `Column`을 교체 — 맨 위에 타임바, 제목/상태 행에 모드 토글을 둔다. 기존 `return Column(...)` 전체를 아래로 교체:

```dart
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AudioProgressBar(
                    position: playlist.position,
                    duration: playlist.duration,
                    onSeek: playlist.seek,
                  ),
                  const SizedBox(height: Gap.sm),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      _ModeToggle(
                          mode: playlist.mode, onTap: playlist.cycleMode),
                    ],
                  ),
                ],
              );
```

그리고 `_StepButton` 클래스 앞(또는 뒤)에 `_ModeToggle` 추가:

```dart
/// 재생 모드 토글 — 탭마다 cycleMode. 아이콘·툴팁이 현재 모드를 나타낸다.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onTap});

  final PlayMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (IconData icon, String label) = switch (mode) {
      PlayMode.autoAll => (Icons.playlist_play, '전체 자동 재생'),
      PlayMode.repeatOne => (Icons.repeat_one, '한 개 반복'),
      PlayMode.single => (Icons.looks_one_outlined, '한 개만 재생'),
    };
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.full),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.surface2,
              borderRadius: BorderRadius.circular(Radii.full),
              border: Border.all(color: c.border),
            ),
            child: Icon(icon, size: 20, color: c.accent, semanticLabel: label),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/lecture_transport_bar_test.dart`
Expected: PASS(기존 + 신규 2).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/widgets/lecture_transport_bar.dart flutter_app/test/lecture_transport_bar_test.dart
git commit -m "feat(audio): 트랜스포트 바에 타임바 + 재생 모드 토글"
```

---

## Task 5: StudyAudioPlayer 타임바 + 최종 검증

**Files:**
- Modify: `flutter_app/lib/widgets/study_audio_player.dart`
- Modify: `flutter_app/test/study_audio_player_test.dart`

**Interfaces:**
- Consumes: `AudioProgressBar`(Task 3), `LecturePlaylist`(`position`/`duration`/`seek`).

- [ ] **Step 1: 실패 테스트 작성**

`test/study_audio_player_test.dart` 상단 import에 `import 'package:aws_docs/widgets/audio_progress_bar.dart';` 추가, `main()`에 테스트 추가:

```dart
  testWidgets('미니플레이어에 타임바(AudioProgressBar)가 있다', (tester) async {
    final fake = _Fake();
    await _pump(tester, fake);
    expect(find.byType(AudioProgressBar), findsOneWidget);
  });
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_audio_player_test.dart`
Expected: FAIL — `AudioProgressBar` 없음.

- [ ] **Step 3: 구현**

`lib/widgets/study_audio_player.dart` 상단 import에 추가:

```dart
import 'audio_progress_bar.dart';
```

`build`의 `ListenableBuilder` builder가 반환하는 `Row(...)`를 타임바를 포함한 `Column`으로 감싼다. 기존 `return Row(children: [ ... ]);` 전체를 교체:

```dart
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AudioProgressBar(
                    position: playlist.position,
                    duration: playlist.duration,
                    onSeek: playlist.seek,
                  ),
                  const SizedBox(height: Gap.sm),
                  Row(
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
                  ),
                ],
              );
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_audio_player_test.dart`
Expected: PASS(기존 + 신규 1).

- [ ] **Step 5: 최종 전체 검증**

Run: `cd flutter_app && flutter test`
Expected: 전부 PASS.

Run: `cd flutter_app && flutter analyze`
Expected: 신규 0건(기존 잔존 3건 외 없음).

Run(PowerShell): `flutter build web --dart-define=audio_lecture=true`
Expected: 빌드 성공.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/widgets/study_audio_player.dart flutter_app/test/study_audio_player_test.dart
git commit -m "feat(audio): 미니플레이어에 타임바 추가"
```

---

## Self-Review (작성자 점검 결과)

1. **Spec coverage:** ① 타임바 seek = Task 1(백엔드/컨트롤러)+Task 3(위젯)+Task 4·5(배선). ③ 모드 = Task 2(PlayMode·ended·cycleMode, 기본 autoAll)+Task 4(토글 UI). 타임바 위치 둘 다 = Task 4(트랜스포트)+Task 5(미니플레이어). iOS graceful = autoAll의 next()가 기존 select(load+play) 경로 재사용(별도 코드 없음 — play() 거부 시 error 상태). 4Hz 분리 = Task 1 ValueNotifier. ② 제목 타임스탬프 = 비목표(후속). 누락 없음.
2. **Placeholder scan:** 모든 step에 실제 코드·정확한 명령·기대 출력. TBD/TODO 없음. fake 정합(Task 1 4개 fake)·테스트 시퀀싱 명시.
3. **Type consistency:** `AudioBackend.seek(double)`/`positionStream`/`duration`(Task 1) ↔ WebAudioBackend·fake 구현 일치. `AudioController.position`(ValueNotifier<Duration>)·`duration`(ValueNotifier<Duration?>)·`seek(Duration)`(Task 1) ↔ `LecturePlaylist.position`/`duration`(ValueListenable 통과)·`seek(Duration)`(Task 2) ↔ `AudioProgressBar`(ValueListenable + onSeek(Duration))(Task 3) ↔ Task 4·5 배선 일치. `PlayMode{single,autoAll,repeatOne}`·`mode`·`cycleMode`(Task 2) ↔ Task 4 `_ModeToggle` switch 일치. `AudioController.seek`는 `to.inMilliseconds/1000.0`로 초 변환, backend.seek(double seconds) 일치.
