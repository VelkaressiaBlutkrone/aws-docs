# 설계: 제목 타임스탬프 정확화(섹션 길이) — 하위 B 정확화

- 날짜: 2026-06-28
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: `audio_meta.chapters`의 `fraction`을 글자수 추정 → **실제 오디오 섹션 길이 측정(ffprobe)** 기반 정확값으로 업그레이드. **데이터 계약(fraction) 동일 → 앱 무변경**, 도구(`gen_lecture_audio.py` synthesize)·19문서 재합성만.

## 배경

문서내 제목별 타임스탬프(하위 B, #85)가 출고됐다. 현재 `fraction`은 `chapters_from_segments`의 **글자수 비례 추정**(±수초)이다. 정확도를 높이려면 실제 오디오에서 각 제목의 시작 시각을 측정해야 한다. 사용자가 처음 제안한 Polly speech-mark(단어 정밀)는 SSML 청킹·이중요청·정렬 검증이 복잡·고위험이고 목표(제목 시작 위치)엔 과하다. **제목 경계로 섹션을 나눠 합성하고 각 섹션의 실제 길이를 ffprobe로 재면, 제목 시작이 곧 섹션 시작이라 정확하고 단순**하다.

기존 코드 사실:
- `script_to_speech(script)`: 비-skip 세그먼트의 발음 텍스트를 `\n`로 join(평문). `run_synthesize`: speech → `chunk_text(2900)` → `synthesize_polly`(청크별 mp3·ID3 strip·concat) → `_loudnorm_2pass` → `build_audio_meta(chapters=chapters_from_segments(...))`.
- `chapters_from_segments`(#85): heading 세그먼트(앵커 있는)별 글자수 비례 fraction(공백 제외).
- loudnorm/비트레이트 재인코딩은 **길이 불변**(fraction 안정). ffmpeg/ffprobe 로컬 설치됨. Polly 자격증명 있음.
- 앱: `parseChapters`/`chapterSeekMs(fraction×duration)`/헤딩 시크 — `fraction` 계약에만 의존(값 정밀화엔 무영향).

## 결정사항 (brainstorming)

1. **방식 = 섹션별 합성 + ffprobe 길이(A)**. speech-mark(B) 비채택(과함·고위험).
2. **섹션 경계 = 앵커 있는 heading**. section[0]=첫 앵커 헤딩 전 intro, section[i]=앵커 헤딩 i부터 다음 앵커 헤딩 전까지.
3. **총길이 = Σ섹션길이**(self-consistent), `fraction = 누적시작/총길이`.
4. **데이터 계약(fraction) 유지** → 앱 무변경.
5. **19문서 재합성·재승인**. 음성 내용 동일(같은 세그먼트·voice — 청킹만 다름) → 재청취 없이 reviewStatus 재전환(loudness 때와 동일).
6. **1문서 선검증** 후 19문서.

## 컴포넌트

### 1. 섹션 분할 (순수) — `gen_lecture_audio.py`

순수 함수 `split_sections(segments) -> list[dict]`:
- 비-skip 세그먼트를 선언 순서로 훑어, **앵커 있는 heading**(sourceExcerpt에 `{#id}` + 선행 `#`)에서 새 섹션 시작. 그 전(첫 앵커 헤딩 전)은 intro 섹션.
- 각 섹션: `{ anchor: str|None, title: str|None, level: int|None, speech: str }` — anchor/title/level은 그 섹션을 여는 앵커 헤딩(intro는 None), speech는 섹션에 속한 비-skip 세그먼트들의 발음 텍스트(table=audioSummary, 그 외 scriptText)를 `\n`로 join.
- 불변식: 모든 섹션 speech를 `\n`로 이으면 `script_to_speech(script)`와 **동일**(음성 누락·중복 없음). self-test로 가드.

### 2. synthesize 재구조화 — `run_synthesize`/`synthesize_polly`

- `run_synthesize`: `split_sections` → **섹션마다** `chunk_text`(2900) → Polly 합성 → 섹션 mp3(ID3 1개) → `ffprobe`로 섹션 길이(ms) → 모든 섹션 mp3 concat = 최종 mp3 → `_loudnorm_2pass`(길이 불변).
- 누적은 **순수 함수** `chapters_from_section_durations(sections: list[dict], durations_ms: list[int]) -> list[dict]`로 분리(오디오 없이 단위 테스트 가능): `start_i = Σ(0..i-1 길이)`, `total = Σ(모든 길이)`, 앵커 있는 섹션마다 `{anchor,title,level, fraction: start_i/total}`(total 0이면 0.0). `synthesize`는 섹션별 ffprobe 길이 리스트를 이 함수에 넘겨 chapters를 얻는다.
- `build_audio_meta(..., chapters=정확값)`. 나머지(loudness·source·script reviewStatus 처리)는 기존과 동일.
- `synthesize_polly`를 "청크 리스트 → 단일 mp3"에서 섹션 단위로 호출하거나, 섹션별 임시 mp3 생성 후 concat하도록 정리. ID3 strip·concat 규약은 기존 유지(최종 ID3 1개).
- ffprobe 헬퍼 `_audio_duration_ms(path) -> int`(ffprobe `-show_entries format=duration`; ffmpeg/ffprobe 없으면 명확히 종료).

### 3. 데이터 계약 (앱 무변경)

`audio_meta.json`의 `chapters: [{anchor,title,level,fraction}]` 스키마 그대로. 앱·테스트 무변경(fraction 값만 정밀해짐). `chapterSeekMs(fraction, duration)` = `fraction × 런타임 duration` 그대로.

### 4. 추정 fallback 유지

기존 `chapters` 서브커맨드(글자수 추정, 재합성 없음)는 **유지**(재합성 불가·빠른 갱신용). `synthesize`는 정확 fraction을 쓴다. `chapters_from_segments`(추정)는 그대로 둔다.

## 19문서 재합성·재승인 (운영)

- ffmpeg/ffprobe + Polly 자격증명으로 19문서 `synthesize` 재실행(정확 chapters 포함 audio_meta 생성). 24kHz/48k(기존 비트레이트 fix)·loudnorm 유지.
- 음성 내용 동일 → **재청취 없이** `audio_meta` top-level + script reviewStatus를 approved로 재전환(직전 loudness 패턴, content_index 동기화 테스트 통과). mp3 바이트 재생성되어 라이브 교체(체감 동일).

## 테스트 전략 (TDD)

- **도구 단위(self-test)**: `split_sections` — 앵커 헤딩 경계·intro 섹션·세그먼트 누락 없음(`Σ섹션 speech == script_to_speech`)·앵커 없는 헤딩은 경계 안 됨(같은 섹션). `chapters_from_section_durations`(섹션+길이 리스트 입력 → fraction 단조·[0,1)·앵커 섹션만·total 0 가드). `py tool/gen_lecture_audio.py --self-test` 그린.
- **1문서 선검증(수동)**: 1문서 synthesize → `Σ섹션길이 ≈ ffprobe(최종 mp3)`(±작은 오차), chapters fraction 단조·[0,1), `gate --audio-meta` PASS.
- **앱 회귀**: 변경 없음 — 기존 `audio_chapters_test`·`content_index_test` 그대로 통과(fraction 값만 바뀌므로 스키마·로딩 무영향).
- 게이트: `flutter test` 통과, `flutter analyze` 신규 0, `flutter build web` 성공(앱 무변경이라 자명하나 확인).

## 범위 / 비목표

- 범위: `gen_lecture_audio.py`의 `split_sections`·`synthesize` 재구조화·ffprobe 길이·정확 chapters + self-test + 19문서 재합성·재승인. **Dart/앱 무변경**.
- 비목표(YAGNI): Polly speech-mark(단어 정밀) · 앵커 없는 헤딩 타임스탬프 · 챕터 UI 변경 · 섹션 외 마커 · 타임바 챕터 마커.

## 정본·관련

- 선행: `docs/superpowers/specs/2026-06-28-audio-section-timestamps-design.md`(#85, fraction 계약·앱 UI)
- 코드: `flutter_app/tool/gen_lecture_audio.py`(script_to_speech·chunk_text·synthesize_polly·_loudnorm_2pass·chapters_from_segments·build_audio_meta)
- 재합성 패턴: loudness 정규화(audio_meta 재승인·content 불변) — [[audio-runtime-gate-shipped]]
