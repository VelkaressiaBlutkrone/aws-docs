# 설계: 오디오 대본 연결 조직 (Stage A2 — 도입·전환·마무리)

- 날짜: 2026-06-29
- 생성: /superpowers:brainstorming
- 상태: APPROVED (설계·템플릿 사용자 승인)
- 모드: Builder(개인 학습 도구)
- 범위: A1(스캐폴딩 제거) 위에, 강의 흐름을 위한 **결정적 회전 템플릿** 연결 멘트(도입/섹션 전환/마무리)를 삽입. Python 도구 중심, **Dart/앱 무변경**.

## 배경

A1([[audio-instructor-script-planned]], PR#89→#90 라이브)이 메타·체크리스트 낭독을 제거했다. 그러나 본문은 여전히 도입 없이 본론으로 떨어진다. 사용자는 "실제 강의처럼" 시작·전환·마무리 프레임을 원한다. 정확 speech-mark·LLM 재저작은 비목표(후속 Stage B). 여기서는 **결정적 회전 템플릿**으로 도입·전환·마무리만 삽입한다(과금·비결정성·환각 없음).

기존 코드 사실:
- `parse_segments`/script.json 세그먼트: 각 `{id,kind,sourceExcerpt,scriptText,audioSummary,skip,issues}`.
- `script_to_speech`(L411): 비-skip 세그먼트 발음 텍스트를 `\n`로 join(table=audioSummary, 그 외 scriptText).
- gate 토큰보존(L496-503): `if source and target`일 때만 seg별 `check_token_preservation` → **sourceExcerpt 빈 세그먼트는 토큰검사 스킵**. 기호/URL/링크 hard 규칙(L480-492)은 target 전체에 적용.
- `split_sections`/`chapters_from_section_durations`: **앵커 있는 heading**만 섹션 경계. 비앵커 세그먼트 삽입은 경계 불변(fraction 값만 섹션 길이 변화로 재계산).
- A1: `mark_scaffolding`·`descaffold`(스캐폴딩 skip). H1 제목 세그먼트(seg000)는 비-skip(낭독됨).

## 결정사항 (brainstorming)

1. **범위 = C(도입+마무리+섹션 전환)**. 가장 강의다운 흐름.
2. **생성 = A(결정적 회전 템플릿)**. LLM 비채택(비용·비결정성·경계월권). 설계의 "Stage A=결정적" 제약 정합.
3. **삽입 세그먼트는 `sourceExcerpt=""`** → gate 토큰검사 스킵. **순수 네비게이션**(사실 무첨가) → 재청취 외 검수 우회 정당. **평문**(기호/URL/링크 hard 규칙 통과).
4. **josa 정확**: 받침 계산 헬퍼로 `을/를`·`으로/로` 처리.
5. **앱 무변경**(fraction 계약 동일). 19문서 재합성·재승인(A1 패턴, 청취 후 flip).

## 컴포넌트

### 1. josa 헬퍼 (순수)

- `_josa_eul(word) -> "을"|"를"`, `_josa_ro(word) -> "으로"|"로"`. 마지막 Hangul 음절의 받침 유무로 결정(`(ord(ch)-0xAC00) % 28`; ㄹ받침은 `로` 예외 처리). 비-Hangul 끝이면 기본형(`를`/`로`).

### 2. 연결문 삽입 (순수) — `insert_connectors`

순수 함수 `insert_connectors(segments: list[dict], title: str) -> int`(새 세그먼트 삽입, 삽입 수 반환). `title`=문서 H1 제목(첫 heading 세그먼트 scriptText).

- **도입 1개**: 첫 비-skip 발화 세그먼트(통상 H1 제목 seg000) **직후**에 삽입. 문서 index(또는 docId 해시 불가 → 호출자가 doc 순번 전달)로 회전. 실무: 호출자가 doc 순번을 못 주므로 **title 길이 기반 결정적 인덱스**(`len(title) % N`)로 회전(결정적·문서마다 다양).
- **전환 N개**: 각 **앵커 있는 heading** 세그먼트 **직전**에 삽입(직전 섹션 오디오 끝에 붙음 → 앵커 경계 불변). 앵커 순번(0,1,2…)으로 틀 회전 + 그 heading scriptText를 `{S}`로 채움.
- **마무리 1개**: 마지막 비-skip 세그먼트 **직후**(문서 끝)에 삽입. `len(title)` 기반 회전.
- 삽입 세그먼트: `{id: "conN", kind: "connector", sourceExcerpt: "", scriptText: <문구>, audioSummary: None, skip: False, issues: []}`. (`kind:"connector"`는 신규 — gate/script_to_speech는 kind 무관하게 비-table·비-skip·scriptText면 발화하므로 동작.)
- 멱등: 이미 `kind=="connector"` 세그먼트가 있으면 재삽입 안 함(재적용 0).

### 템플릿 (합니다체·절제)

`{T}`=H1 제목, `{S}`=섹션 제목. josa는 헬퍼로 치환.

- **도입**(`len(title)%3` 회전):
  - `이번 강의에서는 {T}{을/를} 다룹니다.`
  - `{T}, 지금부터 함께 살펴보겠습니다.`
  - `이번 시간에는 {T}{을/를} 짚어 보겠습니다.`
- **전환**(앵커 순번 `i%4` 회전):
  - `다음으로 {S}{을/를} 살펴보겠습니다.`
  - `이어서 {S}{으로/로} 넘어가겠습니다.`
  - `이번에는 {S}입니다.`
  - `계속해서 {S}{을/를} 보겠습니다.`
- **마무리**(`len(title)%3` 회전):
  - `여기까지가 이 주제의 핵심입니다.`
  - `이상으로 이번 강의를 마칩니다.`
  - `핵심은 여기까지입니다. 수고하셨습니다.`

### 3. 도구 통합 — `connectors` 서브커맨드

- 신규 `connectors --script <path>`: script.json 로드 → `insert_connectors(segments, title)` (title=첫 heading scriptText) → 삽입 있으면 `reviewStatus="needs_human_review"` → 다시 쓴다(A1 `descaffold`와 동일 구조).
- A1과 독립 적용 가능(이미 descaffold된 script.json에 추가 삽입). 순서: descaffold(완료) → connectors → synthesize.

### 4. 데이터 계약·앱

- 삽입은 비앵커 세그먼트 → `split_sections` 앵커 경계 불변 → chapters 스키마 동일, fraction 값만 섹션 길이 변화로 재계산(정상). 앱·테스트 무변경.

## 테스트 전략 (TDD)

- **josa self-test**: 받침 있는 단어→`을`/`으로`, 없는 단어→`를`/`로`, ㄹ받침→`로`.
- **insert_connectors self-test**: 도입(첫 발화 직후 1개)·전환(앵커 heading마다 직전, 틀 회전·제목 채움)·마무리(끝 1개) 위치·개수, 삽입문 `sourceExcerpt==""`·`skip==False`, 멱등(재적용 0). 회전 인덱스 결정성.
- **connectors 서브커맨드 self-test**: 임시 script.json 적용 → 삽입 반영·reviewStatus 강등(A1 패턴).
- **운영 검증**: 19문서 connectors 적용 → 합성음성에 연결문 존재(예 "살펴보겠습니다")·스캐폴딩 0 유지·기호/URL 0 → 재합성 → gate 19/19 → flutter test 그린·analyze 신규0·web build → **청취 후** reviewStatus flip.

## 범위 / 비목표

- 범위: josa 헬퍼·`insert_connectors`·`connectors` 서브커맨드 + self-test + 19문서 재합성·재승인. **Dart/앱 무변경.**
- 비목표(YAGNI): LLM 연결문 · 마커 탈출구 · 본문 재저작(Stage B) · 비앵커 헤딩 전환 · 타임바 챕터 마커.

## 정본·관련

- 선행: A1 [[audio-instructor-script-planned]] · 상위 설계 `docs/superpowers/specs/2026-06-29-audio-instructor-script-design.md`
- 코드: `flutter_app/tool/gen_lecture_audio.py`(`script_to_speech`·gate·`split_sections`·`descaffold`)
- 재합성·재승인 패턴: [[audio-section-timestamps-shipped]](청취 후 flip)
