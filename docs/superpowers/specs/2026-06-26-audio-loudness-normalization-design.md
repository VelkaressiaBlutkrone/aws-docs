# 설계: 학습 오디오 loudness 정규화 (③ 음질)

- 날짜: 2026-06-26
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기
- 범위: 후속 마일스톤 ③(음질 — loudness 정규화). ④ 환각 가드는 별도 spec.

## 배경

CLF 19문서 오디오 강의가 라이브에 노출·재생된다([[audio-runtime-gate-shipped]], mp3 404 fix 포함). 합성은 Amazon Polly Seoyeon neural mp3이며 `SampleRate` 미지정(Polly 기본). 문서마다 합성 라우드니스가 달라, 여러 강의를 연속 청취할 때 볼륨 편차가 생긴다.

목표: 모든 CLF 강의 mp3를 **-16 LUFS**(음성·팟캐스트 표준)로 정규화해 문서 간 볼륨을 균일하게 한다. PCM 무손실 보관은 파일 크기 폭증(현 110MB mp3 → 수백MB)으로 번들·repo에 비현실적이라 비목표.

## 결정사항 (brainstorming)

1. **도구 = ffmpeg `loudnorm` 2-pass.** EBU R128 업계 표준. pyloudnorm/PCM 직처리 대비 정확하고 `gen_lecture_audio.py` 통합이 단순. (pyloudnorm·Polly PCM 직수신은 mp3 I/O·인코더 의존이 오히려 복잡 — 기각.)
2. **목표 = -16 LUFS** (TP -1.5 dBTP, LRA 11).
3. **기본 loudnorm on + `--skip-loudnorm` 탈출구.** ffmpeg 미설치 시 synthesize는 명확한 에러(설치 안내)로 중단하고, 의도적으로 건너뛰려면 `--skip-loudnorm`(품질 저하 경고).
4. **재검수 불필요.** loudness는 볼륨만 바꾸고 `script.json`·`scriptText`는 불변 → `reviewStatus=approved` 유지. mp3 sha·loudness 메타만 갱신.

## 파이프라인 (`gen_lecture_audio.py` synthesize)

- 현재: Polly 청크 합성 → concat → `buf`(mp3) → `out.mp3` 기록
- 변경: Polly concat → 임시 mp3 → **`loudnorm` 2-pass(-16 LUFS)** → `out.mp3`

## 컴포넌트

1. **`_parse_loudnorm_json(stderr_text) -> dict`** (순수 함수)
   - ffmpeg pass1 stderr에서 loudnorm JSON 블록(`input_i`·`input_tp`·`input_lra`·`input_thresh`·`target_offset`)을 추출·파싱.
   - 순수 문자열→dict라 **단위 테스트 대상**.
2. **`_loudnorm_2pass(in_path, out_path, target_i=-16.0)`** (subprocess)
   - pass1: `ffmpeg -i in -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json -f null -` → stderr JSON → `_parse_loudnorm_json`
   - pass2: 측정값으로 `loudnorm=...:measured_I=...:...:linear=true` 적용 → `out.mp3`
3. **synthesize 통합**: Polly concat 결과를 임시 파일로 쓰고 `_loudnorm_2pass`로 `out.mp3` 생성(`--skip-loudnorm`이면 기존처럼 직접 기록).
4. **ffmpeg 가용성 검사**: synthesize 시작 시 `shutil.which('ffmpeg')` 확인. 없고 `--skip-loudnorm`도 아니면 즉시 에러(설치 안내).

## ID3 / audio_meta

- `loudnorm`(ffmpeg 재인코딩)이 마지막 단계 → 출력 mp3의 `_id3_count`가 1인지 확인(gate `id3Count==1` 유지). 다중이면 기존 `_strip_id3v2` 경로로 보정.
- `audio_meta.json`에 `loudness: {targetLufs: -16, normalized: true}` 추가(이력·검증). `--skip-loudnorm`이면 `normalized: false`.

## 검수 영향

loudness는 볼륨만 바꾸므로 `script.json`·`scriptText`·`reviewStatus`는 불변이다. **재합성해도 `approved`를 유지**하고 재청취 검수는 불필요하다(내용 동일). 갱신되는 것은 mp3 바이트(sha)와 audio_meta의 loudness 메타뿐. 재합성 후 `gate --audio-meta`로 `id3Count==1`·sha 정합을 재확인한다.

## 테스트 전략 (TDD — 절대조건 2)

- **`_parse_loudnorm_json` 단위 테스트**: 실제 ffmpeg loudnorm pass1 JSON 샘플 문자열 → 기대 dict. 실패 테스트 먼저. (네트워크·ffmpeg 불필요 — 문자열 파싱.)
- **self-test**: ffmpeg 가용 시 짧은 무음/톤 mp3 1개를 정규화해 출력 존재·ID3 1개 확인, 미설치면 파싱 함수 테스트만 수행하고 skip 로그.
- 게이트: `py tool/gen_lecture_audio.py --self-test` 그린, `flutter analyze`/`flutter test`는 Dart 무변경이라 영향 없음(현 상태 유지).
- 실제 음질·볼륨 균일은 사용자 재합성(Polly+ffmpeg)+청취로 확인.

## 범위 / 비목표

- 범위: `gen_lecture_audio.py`의 loudnorm 통합 + `_parse_loudnorm_json` 순수 함수 + self-test. **Dart/lib·pubspec 무변경**(볼륨만, 런타임·노출 무관).
- 비목표: 사용자의 ffmpeg 설치·CLF 19문서 재합성·청취 / PCM 무손실 보관 / ④ 환각 가드(별도 spec) / Polly SampleRate 변경(별개, 효과 작음).

## 정본·관련

- 런타임 노출 게이트: `docs/superpowers/specs/2026-06-26-audio-runtime-review-gate-design.md`
- 콘텐츠 검수 파이프라인: `docs/superpowers/specs/2026-06-23-content-review-pipeline-design.md`
- 도구: `flutter_app/tool/gen_lecture_audio.py`
