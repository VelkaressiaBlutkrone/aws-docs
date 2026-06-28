# 설계: 오디오 타임바 + 재생 모드 (하위 프로젝트 A)

- 날짜: 2026-06-27
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: 자격증 오디오 페이지·학습문서 미니플레이어에 **① 탐색(seek) 가능한 타임바**와 **③ 재생 모드(단일/전체 자동/반복)** 추가. **② 문서내 제목별 타임스탬프는 별도 후속 spec**(제목→오디오 시점 매핑 데이터가 없어 Polly speech-mark 데이터 파이프라인 + 19문서 재합성을 동반하는 데이터 작업이라 분리).

## 배경

자격증별 오디오 학습 페이지(허브→cert 페이지+하단 트랜스포트+통합 전역 `LecturePlaylist`)가 출고됐다. 현재 오디오는 재생/정지·트랙 이동만 되고 **진행 위치·탐색(seek)이 없으며**, 트랙 종료 시 항상 정지한다(수동 전환). 듣는 흐름을 위해 타임바(탐색)와 재생 모드를 추가한다.

기존 코드 사실(탐색 결과):
- `AudioBackend`(`lib/data/audio_controller.dart`)는 `setSrc/play/pause/events(AudioEvent)`만 노출 — **position·duration·seek 없음**. `WebAudioBackend`의 `<audio>`엔 `currentTime`/`duration`/`timeupdate`가 있으나 추상화 밖.
- `AudioController extends ChangeNotifier`는 `state`(PlaybackState)만.
- `LecturePlaylist`는 `ended` 시 인덱스 불변(수동 전환). 트랙 변경은 select/next/prev/first/last.
- UI: `LectureTransportBar`(오디오 페이지 하단)·`StudyAudioPlayer`(학습문서 미니플레이어) 둘 다 같은 전역 `LecturePlaylist` 구독.
- **타이밍 데이터 부재**: audio_meta.json에 duration 없음, script.json seg에 시간 필드 없음, synthesize는 Polly `OutputFormat="mp3"`만(speech marks 미사용) → ②는 데이터 생성이 선행되어야 함(후속).

## 결정사항 (brainstorming)

1. **분해**: 지금 = ① 타임바 + ③ 재생 모드(순수 코드, 기존 인프라 위). ② 제목별 타임스탬프 = **별도 후속 spec**(데이터 파이프라인). ①의 seek가 ②의 전제.
2. **타임바 = 탐색(seek) 가능**: 드래그/탭으로 위치 이동 + 경과/총 시간 표시.
3. **타임바 위치 = 둘 다**: 오디오 페이지 트랜스포트 + 학습문서 미니플레이어(공유 위젯).
4. **재생 모드 = 단일/전체 자동/반복, 기본 `autoAll`(전체 자동)**. iOS 자동전환 차단은 graceful 처리.

## 컴포넌트

### 1. `AudioBackend` / `WebAudioBackend` 확장 — `lib/data/audio_controller.dart`, `lib/data/web_audio_backend.dart`

`AudioBackend` 인터페이스에 추가:
- `void seek(double seconds)`
- `Stream<Duration> get positionStream` — 재생 위치 갱신(브라우저 `timeupdate`, ~4Hz)
- `Duration? get duration` — 메타데이터 로드 전 null, 후 확정

`WebAudioBackend` 구현: `seek(s)` → `_audio.currentTime = s`; `timeupdate` 이벤트 → positionStream에 `Duration(현재초)` 방출; `duration` getter → `_audio.duration`(NaN/Infinity면 null). 웹 전용이라 단위 테스트 제외(기존 정책). 테스트는 `FakeAudioBackend`(테스트 파일)에 동일 인터페이스 추가.

### 2. `AudioController` 확장 — `lib/data/audio_controller.dart`

4Hz 위치 갱신이 재생/정지·상태 위젯까지 리빌드하지 않도록 **상태(ChangeNotifier)와 위치를 분리**한다:
- `final ValueNotifier<Duration> position`(초기 0), `final ValueNotifier<Duration?> duration`(초기 null) — 타임바만 구독.
- `void seek(Duration to)` → `backend.seek(to.inMilliseconds / 1000)`.
- 생성자에서 `backend.positionStream` 구독 → 방출마다 `position.value = 방출값` **및** `duration.value = backend.duration`(메타데이터 전 null, 후 확정값 — 별도 durationStream 없이 매 timeupdate에 읽어 동기화). `load(src)` 시 `position.value = Duration.zero; duration.value = null`로 리셋. `dispose`에서 구독·notifier 정리.

### 3. `LecturePlaylist` 재생 모드 — `lib/data/lecture_playlist.dart`

- `enum PlayMode { single, autoAll, repeatOne }`(파일 상단 또는 lecture_playlist.dart 내).
- `PlayMode _mode = PlayMode.autoAll;` + `PlayMode get mode` + `void cycleMode()`(순환: autoAll → repeatOne → single → autoAll). 전역·인메모리(저장 안 함 — YAGNI).
- **ended 처리**: 컨트롤러 상태가 `ended`로 전이될 때 모드별 동작. (기존 `_controller.addListener(notifyListeners)`에 더해, ended 전이를 감지하는 처리를 둔다 — 이전 상태를 추적해 idle/playing→ended 진입 1회만 반응. 재진입 방지.)
  - `single`: 정지(인덱스 불변 — 현행).
  - `autoAll`: `hasNext`면 `next()`(load+play), 아니면 마지막에서 정지(리스트 루프 안 함).
  - `repeatOne`: 현재 트랙 재로드+play(`select(_index)`는 같은 트랙 재선택 시 재시작 안 하므로, 반복은 명시적으로 load+play를 다시 호출하는 내부 경로 사용).
- position/duration/seek는 컨트롤러의 것을 그대로 노출(통과 getter): `ValueListenable<Duration> get position`, `ValueListenable<Duration?> get duration`, `void seek(Duration)`.

> **repeatOne 주의**: `select(i)`는 같은 인덱스 재선택 시 재시작하지 않는다(직전 다듬기). 반복은 "끝났을 때 처음부터"이므로 ended 처리에서 `_controller.load(current.lectureAudioSrc); _controller.play();`를 직접 호출하는 내부 메서드(`_restartCurrent()`)를 둔다.

### 4. UI

- **공유 `AudioProgressBar` — `lib/widgets/audio_progress_bar.dart`**: `position`·`duration` ValueListenable 구독 + `onSeek(Duration)` 콜백. 슬라이더(드래그/탭으로 이동) + 경과/총 시간(`mm:ss`, duration null이면 `--:--`). `context.c` 토큰·DESIGN.md(슬라이더 색=accent, 트랙=border). 드래그 중에는 로컬 값으로 표시하고 놓을 때 onSeek 호출(스크럽 중 4Hz 위치와 충돌 방지).
- **모드 토글 — `LectureTransportBar`**: 아이콘 버튼(전체자동/반복/단일 순환). 아이콘·툴팁(합니다체): autoAll="전체 자동 재생"(`Icons.playlist_play`), repeatOne="한 개 반복"(`Icons.repeat_one`), single="한 개만 재생"(`Icons.looks_one_outlined`). 미니플레이어엔 **모드 토글 없음**(컴팩트 — 모드는 오디오 페이지에서 제어).
- 배치: `LectureTransportBar` = 기존 버튼 행(처음·이전·재생정지·다음·마지막) + 모드 토글 + **타임바 행** + 제목·상태. `StudyAudioPlayer`(미니플레이어) = **타임바** + 재생/정지 + 제목·상태.

### 5. iOS graceful (autoAll)

트랙 종료 후 자동 다음 재생(`next()`)은 데스크톱 브라우저에선 정상이나, iOS 브라우저에선 사용자 제스처 없는 `play()`가 차단될 수 있다. `next()`는 다음 트랙을 **load 후 play() 시도**하며, play()가 거부되면 `AudioController`가 error 상태로 전이한다(기존 동작). 이때 다음 트랙은 src가 로드된 채이므로 사용자가 재생 버튼을 한 번 탭하면 이어진다 — UI 상태줄은 "오디오를 재생하지 못했습니다."가 잠깐 보일 수 있다(부분 degrade, wrong색 금지). **잠금화면 연속재생·백그라운드는 별개**(M1 T6 iOS 실기기 수동 게이트).

## 테스트 전략 (TDD)

- **단위**:
  - `AudioController`: fake backend가 positionStream에 방출 → `position`/`duration` ValueNotifier 갱신; `seek(Duration)` → `backend.seek(초)` 호출; `load` 시 position 0 리셋.
  - `LecturePlaylist`: ended 전이 시 모드별 — single=인덱스 불변·정지, autoAll=다음 트랙 load+play(마지막에선 정지), repeatOne=현재 트랙 재로드+play; `cycleMode` 순서(autoAll→repeatOne→single→autoAll); 기본 autoAll; position/duration/seek 통과.
  - ended 재진입 가드(ended 전이 1회만 반응).
- **위젯**:
  - `AudioProgressBar`: position·duration 렌더(경과/총 mm:ss, duration null이면 `--:--`), 드래그 종료 시 onSeek(Duration) 호출.
  - `LectureTransportBar` 모드 토글: 탭 시 cycleMode 호출·아이콘/툴팁 변화. 타임바 존재.
  - `StudyAudioPlayer`: 타임바 존재·모드 토글 없음.
- **fake 확장**: 테스트의 `FakeAudioBackend`에 `seek`/`positionStream`/`duration` 추가(위치 emit 헬퍼).
- 게이트: `flutter test` 전부 통과, `flutter analyze` 신규 0(기존 잔존 3), `flutter build web --dart-define=audio_lecture=true` 성공.

## DESIGN.md 준수

`context.c` 토큰만 · 인터랙티브는 InkWell/FocusRing(슬라이더는 Material `Slider`의 FocusRing 동등 처리) · 합니다체 · 비-fatal 오디오 실패에 wrong색 금지 · 반마케팅 절제. 새 fontWeight엔 `Wght.*` 병기.

## 범위 / 비목표

- 범위: `AudioBackend`/`WebAudioBackend`/`AudioController`/`LecturePlaylist` 확장, `AudioProgressBar` 신규, `LectureTransportBar`·`StudyAudioPlayer`에 타임바·모드 토글 배선. Dart/Flutter만.
- 비목표(YAGNI): **② 문서내 제목별 타임스탬프(별도 후속 spec)** · 모드/위치 localStorage 저장 · 미디어세션 잠금화면 스크럽·위치 표시 · 재생속도 조절 · 리스트 전체 루프(autoAll은 마지막에서 정지).

## 정본·관련

- 오디오 페이지 기능: `docs/superpowers/specs/2026-06-27-cert-audio-page-design.md`
- 코드: `lib/data/{audio_controller,web_audio_backend,lecture_playlist}.dart`, `lib/widgets/{lecture_transport_bar,study_audio_player}.dart`
- 후속(②): 제목별 타임스탬프 — Polly speech-mark 캡처(스크립트 제목마다 `<mark>`)→19문서 재합성→타이밍 데이터 저장→이 seek로 시점 이동. 별도 brainstorming→spec.
