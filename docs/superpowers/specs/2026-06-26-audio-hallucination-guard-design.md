# 설계: 학습 오디오 환각 가드 (④ 대본 원문 보존 검출)

- 날짜: 2026-06-26
- 상태: 설계 승인됨(brainstorming) → 구현 계획(writing-plans) 대기 (구현은 새 세션 권장)
- 범위: 후속 마일스톤 ④(환각 가드 — 대본이 원문 핵심 토큰을 보존하는지 자동 검출).

## 배경

학습 오디오 대본은 결정적으로 만들어진다: `scriptText`는 원문 md를 parse + 발음사전 치환(생성 아님), `audioSummary`는 사람이 3열표를 음성 요약(이미 청취 승인). 따라서 LLM식 "환각"은 없으나, **사람이 쓴 audioSummary가 원문 표의 핵심 토큰(서비스 약어·수치)을 누락·오기할 여지**가 있고, scriptText도 원문 토큰 보존을 회귀 검증할 가치가 있다(문서 확장 시).

목표: generate된 대본이 원문 seg의 핵심 토큰을 보존하는지 `gate`에서 자동 검출한다.

## 결정사항 (brainstorming)

1. **대상 = (a) audioSummary + (b) scriptText 토큰 보존.** (c) 향후 LLM 생성 대비는 본 spec에 기록만(비목표).
2. **토큰 범위 = lexicon 등록 약어 + 수치.** 서비스 풀네임("Amazon EC2")은 오탐 많아 제외.
3. **검출 단위 = (A) seg별.** 각 seg의 `sourceExcerpt`(원문) 토큰을 그 seg의 대본(table=`audioSummary`, 그 외=`scriptText`)과 대조. 위치별 정밀, 오배치도 검출.
4. **약어 누락 = hard, 수치 누락 = soft.** 약어는 lexicon say 매핑이 확실해 hard; 수치는 한글 수사 변환("일레븐 나인스") 오탐 여지로 soft.
5. **gate 통합.** `generate` 후 `gate` 실행 시 자동 검출. lexicon은 `gate --lexicon`(기본 `tool/lexicon.json`)으로 로드.

## 검출 (seg별)

`script.json`의 각 seg는 `sourceExcerpt`·`scriptText`·`audioSummary`·`kind`·`skip`을 보유하므로 **md 재파싱 불필요**. `skip=true`(source·selfcheck 등)는 제외. 각 비-skip seg에서:
- 원문 = `sourceExcerpt`, 대본 = `kind=="table"`이면 `audioSummary`, 아니면 `scriptText`
- **약어(hard)**: sourceExcerpt에서 lexicon 등록 약어를 추출(단어경계·긴 키 우선, `apply_lexicon`과 동일 규칙) → 각 약어의 say(예 `이씨투`)가 대본에 substring으로 존재하나? 없으면 hard
- **수치(soft)**: sourceExcerpt에서 숫자/퍼센트(정규식, 예 `\d+%?`)를 추출 → 대본에 같은 아라비아 표기가 있나? 없으면 soft

## 컴포넌트 (`gen_lecture_audio.py`)

1. **`check_token_preservation(source: str, target: str, lexicon: dict) -> tuple[list, list]`** (순수 함수)
   - lexicon 약어 추출(source) → say 발음형이 target에 없으면 hard 메시지
   - 수치 추출(source) → target에 없으면 soft 메시지
   - 단위 테스트 대상(self-test assert).
2. **gate 통합**: `gate` 흐름이 각 비-skip seg에서 `check_token_preservation(seg.sourceExcerpt, 대본, lexicon)` 호출 → hard/soft 누적해 기존 gate 결과에 합산.
3. **lexicon 로드**: `gate` 서브커맨드에 `--lexicon`(type=Path, 기본 `tool/lexicon.json`) 추가. 미존재 시 토큰 검사 skip(경고 로그).

## 기존 19문서 영향

④ 검출이 기존 audioSummary/scriptText에서 약어 누락을 잡으면 해당 문서 gate가 **hard FAIL**할 수 있다. 이는 의도된 점검이다 — 사용자가 audioSummary를 보완하고(약어 추가) 재확인한다. 약어 누락이 없으면 19문서 gate는 그대로 통과. (이 검증·보완은 구현 후 사용자 몫.)

## 테스트 전략 (TDD)

- **`check_token_preservation` self-test assert**: 약어 보존/누락, 수치 보존/누락 케이스. (네트워크·ffmpeg 불필요 — 문자열.)
- 게이트: `py tool/gen_lecture_audio.py --self-test` 그린.
- 구현 후 19문서 `gate` 재실행으로 기존 누락을 발견(사용자 검토·보완).

## 범위 / 비목표

- 범위: `gen_lecture_audio.py`의 `check_token_preservation` + gate 통합 + `--lexicon` + self-test. **Dart/lib·pubspec 무변경**.
- 비목표: (c) LLM 생성 대비 가드(미래 LLM 대본 생성 도입 시 별도) / 서비스 풀네임 매칭 / 수치 한글 수사 정밀 매칭(soft로 보수적) / 사용자의 19문서 재검토·audioSummary 보완.

## 정본·관련

- loudness(③): `docs/superpowers/specs/2026-06-26-audio-loudness-normalization-design.md`
- 런타임 게이트(①+②): `docs/superpowers/specs/2026-06-26-audio-runtime-review-gate-design.md`
- 콘텐츠 검수 파이프라인: `docs/superpowers/specs/2026-06-23-content-review-pipeline-design.md`
- 도구: `flutter_app/tool/gen_lecture_audio.py`(parse_segments·apply_lexicon·gate_script)
