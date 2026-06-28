# 설계: 문서내 제목별 타임스탬프(추정) — 하위 프로젝트 B

- 날짜: 2026-06-28
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: 학습문서의 각 제목(헤딩)을 오디오의 해당 위치로 점프하는 시크포인트. **타임스탬프는 글자수 비례 추정**(재합성·Polly·과금 없음). UI는 학습문서 헤딩 옆 재생 아이콘.
- **선행 의존: PR #84(오디오 타임바 + 재생 모드)의 `seek`·`duration` 인프라가 develop에 머지된 뒤 구현한다.**

## 배경

자격증 오디오 페이지(허브→cert 페이지+트랜스포트+통합 `LecturePlaylist`)와 타임바/재생모드(seek, position/duration)가 출고됐다. 학습문서를 들으며 특정 제목으로 바로 건너뛰고 싶다. 정확한 제목→시각 매핑(Polly speech marks)은 19문서 재합성·과금·정렬 위험이 커서 **글자수 비례 추정**으로 시작한다(부족하면 후속에 speech-mark로 업그레이드 — 데이터 계약 동일).

기존 코드 사실(탐색):
- `parse_segments`(gen_lecture_audio.py): 헤딩은 독립 세그먼트(`kind:"heading"`, 음성 포함, `sourceExcerpt`=원문 헤딩 줄 `## 제목 {#id}`, `scriptText`=정제된 제목). 세그먼트 `id`(seg000…).
- 합성 = 비-skip 세그먼트 순서대로 → speech text → 청크 → Polly mp3 → concat → loudnorm. **loudnorm/비트레이트 재인코딩은 길이(타이밍) 불변.**
- 헤딩 `sourceExcerpt`의 `{#id}`가 학습문서 앵커와 일치(섹션 딥링크 — [[concept-deeplink]]).
- 런타임 seek/duration: `AudioController.seek(Duration)`·`ValueNotifier<Duration?> duration`, `LecturePlaylist.seek`·통과 getter(PR #84).
- `audio_meta.json`은 per-doc 자산(pubspec 등록됨, content-review 파이프라인 PR#62).

## 결정사항 (brainstorming)

1. **생성 = 추정(A)**: 글자수 비례. 재합성·Polly·ffprobe 없음. (정확 speech-mark는 비목표·후속.)
2. **저장 단위 = `fraction`(0~1)**, 절대 ms 아님. 도구는 `script.json` 글자수만으로 계산, 앱이 런타임 `duration`에 곱해 시각 산출(실측 길이에 자동 적응).
3. **저장 위치 = `audio_meta.json`의 `chapters` 배열**(기존 등록 자산 재사용 — 새 에셋·pubspec 추가 없음).
4. **UI = 학습문서 헤딩 시크포인트**: 각 헤딩 옆 재생 아이콘. **게이트 = 현재 플레이리스트 트랙이 이 문서일 때만** 활성(seek 타이밍 안전).

## 컴포넌트

### 1. 챕터 fraction 계산 (순수) — `flutter_app/tool/gen_lecture_audio.py`

순수 함수 `chapters_from_segments(segments: list[dict]) -> list[dict]`:
- 비-skip 세그먼트를 선언 순서대로 훑으며 누적 발음 글자수를 센다. 발음 텍스트 = `kind=="table"`이면 `audioSummary`, 그 외 `scriptText`(공백 제거 후 `len`). `skip=true`·빈 텍스트는 0.
- 각 `kind=="heading"` 세그먼트에서: **그 헤딩 세그먼트 텍스트를 더하기 전까지의 누적 글자수 ÷ 총 발음 글자수 = `fraction`**(총 0이면 0.0). → 시크 시 헤딩의 발음 시작점에 안착.
- 헤딩 `sourceExcerpt`에서 앵커 추출(`\{#([^}]+)\}`). **앵커 없는 헤딩은 제외**(렌더 헤딩과 매칭 불가). title = `scriptText`, level = 선행 `#` 개수.
- 반환: `[{ "anchor": str, "title": str, "level": int, "fraction": float }]`(선언 순서). 단위 테스트(self-test assert) 대상.

### 2. 도구 통합 — `gen_lecture_audio.py`

- **신규 서브커맨드 `chapters`**(`--audio-meta` 또는 `--script`+`--audio-meta`): 기존 `script.json`을 읽어 `chapters_from_segments`로 계산, `audio_meta.json`의 `chapters` 필드를 갱신해 다시 쓴다. **재합성·Polly·ffmpeg 불필요**(글자수만 사용). 19문서에 1회 실행.
- **`synthesize` 통합**: `build_audio_meta`(또는 run_synthesize)가 동일 함수로 `chapters`를 채운다 → 향후 재합성 시 chapters 유지.
- `chapters` 추가는 `audio_meta`의 reviewStatus·source·audio·loudness에 영향 없음(가산 필드) → 동기화 테스트·gate 무영향.

### 3. 앱 로딩 — `flutter_app/lib/`

- 순수 파서 `parseChapters(Map<String,dynamic> audioMetaJson) -> Map<String,double>`(anchor→fraction) 또는 `List<Chapter>`(anchor/title/level/fraction). 단위 테스트.
- 학습문서 진입 시 그 문서의 `audio_meta.json`(경로 = `ContentEntry.lectureAudioMetaSrc`)을 `rootBundle.loadString`으로 fetch → 파싱. (현재 런타임 미fetch라 신규 — 자산은 번들됨. 실패/없음이면 빈 맵 → 시크포인트 미표시.)

### 4. UI — 학습문서 헤딩 시크포인트 — `flutter_app/lib/content/` (study markdown 렌더)

- 학습문서 렌더의 각 heading 옆 작은 재생 아이콘(InkWell+FocusRing, accent, semantic "이 위치부터 듣기").
- **게이트(순수 함수)**: `shouldShowHeadingSeek({required bool enabled, required bool approved, required bool isCurrentTrack, required bool hasDuration, required bool hasFraction})` — 모두 참일 때만 활성. `isCurrentTrack` = `lecturePlaylist?.current?.taskId == 이 문서 taskId`.
- 탭 → `seekMs = (fraction * duration.inMilliseconds).round()`; `playlist.seek(Duration(milliseconds: seekMs))` 호출. 이어서 **재생 중이 아니면 재생 시작**(`state != playing`일 때 `playlist.playPause()` — playPause는 비재생 상태에서 play). 현재 트랙이 이 문서라 오디오가 로드돼 있어 seek 안전.

### 5. 의존성·순서

- **PR #84 머지 후** 이 브랜치를 develop에서 재분기(또는 #84 위에 스택 — 스택 시 [[stacked-pr-merge-order-race]] 주의). `LecturePlaylist.seek`/`duration`/`current` 사용.
- 데이터(도구) 부분(§1·2)은 #84와 무관하게 선행 가능하나, UI(§3·4)는 seek/duration 필요.

## 테스트 전략 (TDD)

- **도구 단위(self-test)**: `chapters_from_segments` — 헤딩만 추출·앵커 없는 헤딩 제외·table은 audioSummary 길이·fraction 단조 증가·총 0 가드·첫 헤딩 fraction(앞 본문 글자수 비례). `py tool/gen_lecture_audio.py --self-test` 그린.
- **앱 단위**: `parseChapters`(정상·빈·필드 누락), 시크 시각 계산(fraction×duration), `shouldShowHeadingSeek` 게이트 분기.
- **위젯**: 헤딩 시크 위젯(주입된 fraction·duration·onSeek — 탭 시 올바른 Duration으로 onSeek). 게이트 off면 미표시.
- 게이트: `flutter test` 전부 통과, `flutter analyze` 신규 0(기존 잔존 3), `flutter build web --dart-define=audio_lecture=true` 성공.

## DESIGN.md 준수

`context.c` 토큰 · 헤딩 시크 아이콘 InkWell+FocusRing(GestureDetector 단독 금지) · 합니다체(semantic/툴팁) · 비-fatal 오디오 실패에 wrong색 금지 · 절제(헤딩 옆 작은 아이콘, 과한 장식 금지).

## 범위 / 비목표

- 범위: 챕터 fraction 계산·도구(chapters 서브커맨드+synthesize 통합)·19문서 audio_meta 갱신, 앱 챕터 로딩·헤딩 시크포인트 UI·게이트. Python 도구 + Dart.
- 비목표(YAGNI): **speech-mark 정확 타임스탬프(후속 업그레이드 — fraction→정확 ms, 계약 동일)** · 타임바 위 챕터 마커 · 오디오 페이지 챕터 패널 · 다른 트랙으로의 헤딩 점프(현재 트랙만) · 앵커 없는 헤딩 지원.

## 정본·관련

- 선행: `docs/superpowers/specs/2026-06-27-audio-timebar-modes-design.md`(PR #84, seek/duration)
- 오디오 페이지: `docs/superpowers/specs/2026-06-27-cert-audio-page-design.md`
- 코드: `flutter_app/tool/gen_lecture_audio.py`(parse_segments·build_audio_meta), `lib/data/{lecture_playlist,content_index}.dart`, `lib/content/`(study markdown 렌더·anchor)
- 후속(정확도 업그레이드): Polly speech marks — 스크립트 제목마다 `<mark>`, mp3와 별도 speech-marks 요청, 청크별 시각+누적 길이 → fraction 대신 정확 ms. 19문서 재합성 동반. 별도 brainstorming→spec.
