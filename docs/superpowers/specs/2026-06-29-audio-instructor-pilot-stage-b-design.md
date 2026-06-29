# 설계: 오디오 대본 LLM 재강의 파일럿 (Stage B — 세그먼트별 풍부화, clf-t1-1)

- 날짜: 2026-06-29
- 생성: /superpowers:brainstorming
- 상태: APPROVED (설계 사용자 승인)
- 모드: Builder(개인 학습 도구)
- 범위: A1(스캐폴딩 제거)·A2(연결문) 위에, **1문서(clf-t1-1)**의 세그먼트별 `scriptText`를 LLM으로 풍부화(대화체 + 비유/예시)하되 **사실 보존**. AI 사실검증 + 사람 최종승인. **앱 무변경**. 파일럿으로 품질·검수부담 실측 후 18문서 확대(도구화) 여부 결정.

## 배경

A1·A2가 낭독·흐름 문제를 해결했지만(라이브), 본문 내용은 여전히 학습문서를 다듬은 평문이라 "가르치는" 느낌이 약하다. Stage B는 LLM이 각 세그먼트를 대화체로 풀고 이해를 돕는 비유/예시를 더해 실제 강사 수준으로 올린다. 위험은 **사실 환각**(틀린 비유·없던 주장) — 시험 콘텐츠라 오개념을 만든다. 그래서 **세그먼트별**(가드 안전·환각 표면 최소) + **사람 사실검수**(계약)로 제한한다.

기존 코드 사실:
- 세그먼트 `{id,kind,sourceExcerpt,scriptText,audioSummary,skip,issues}`. `sourceExcerpt`=원문(검증된 학습문서 줄), `scriptText`=정제 평문.
- `script_to_speech`(L411)·synthesize: 비-skip·비-table는 `scriptText` 발화. A2 connector(kind="connector")·A1 skip 공존.
- gate 토큰보존(L496-503): seg별 `(sourceExcerpt, scriptText)` 약어(hard)·수치(soft) **보존**만 검사. **추가 환각은 못 잡음**(target→source 역검사 없음). 기호/URL/링크 hard 규칙은 target 전체.
- clf-t1-1은 이미 A1(스캐폴딩 skip)·A2(connector 7개) 적용됨. reviewStatus=approved.

## 결정사항 (brainstorming)

1. **입자 = A(세그먼트별 풍부화)**. 섹션통째 재구성(B) 비채택(가드 깨짐·환각/검수 부담). 세그먼트 경계 유지 → 기존 토큰보존 gate 그대로.
2. **범위 = 1문서 파일럿(clf-t1-1)**. 품질·검수부담 실측 후 확대.
3. **메커니즘 = 세션 내 풍부화 서브에이전트**(파일럿=무도구). 18문서 확대 시 `enrich` 서브커맨드+Claude API로 도구화(YAGNI).
4. **저장 = `scriptText` 교체**. `sourceExcerpt`는 검증 원문 유지(세그먼트별 정본 레퍼런스). 이전 scriptText는 git 보존.
5. **사실검수 2단**: AI 검증 에이전트(세그먼트별 원문 미뒷받침 주장 플래그) → 사용자 최종승인. 승인 전 `reviewStatus=needs_human_review`.

## 컴포넌트

### 1. 세그먼트 풍부화 (세션 내 서브에이전트)

대상: clf-t1-1 script.json의 **비-skip·비-connector·비-table·비-heading** 세그먼트(본문 paragraph/list 등, scriptText 보유). **heading 세그먼트는 풍부화 제외**(제목 원문 유지 — A2 전환구가 정제해 참조하므로 변경 금지).

각 세그먼트 풍부화 규칙(서브에이전트 지시):
- 입력: 그 세그먼트의 `sourceExcerpt`(원문)·현재 `scriptText`.
- 출력: 풍부화 `scriptText` — (a) 대화체로 자연스럽게, (b) 이해를 돕는 **짧은 비유/예시 1개**를 자연스러운 곳에만, (c) **원문(sourceExcerpt)의 약어·수치·핵심 주장 보존**, (d) **원문에 없는 새 시험 사실 주장 금지**(비유는 설명용 *예시*; 새 사실을 단정하지 않음), (e) 평문(기호 `→≠↓§|`·URL·마크다운 금지)·합니다체·간결(원문 길이의 ~2배 이내).
- 발음사전 일관: 영문 약어는 기존 한글 발음 표기 관례 따름(예 AWS→에이더블유에스). 새로 도입한 영문은 발음 표기.

### 2. AI 사실검증 (서브에이전트)

풍부화 후, 별도 검증 에이전트가 세그먼트별 `(sourceExcerpt → 풍부화 scriptText)`를 대조:
- 풍부화본의 각 주장이 원문에 의해 **뒷받침되는가**? 원문에 없는 사실 단정·틀린 비유·수치 변경을 **플래그**(seg id + 문제 + 근거).
- 출력: 플래그 목록(없으면 PASS). 플래그 있으면 풍부화 재작업.

### 3. 사람 최종승인

AI 검증 PASS 후, 사용자(SME)가 풍부화본을 학습문서와 대조해 최종 사인. 시험 콘텐츠라 사람이 최종 책임. 승인 시에만 reviewStatus를 approved로 flip.

### 4. 데이터 계약·앱

- `scriptText` 교체뿐, 스키마·필드 불변. 세그먼트 경계·앵커 불변 → split_sections/chapters 동일(fraction 값만 길이 변화로 재계산). 앱·테스트 무변경.
- gate: seg별 토큰보존 그대로 적용(풍부화본이 원문 약어·수치 보존 → 통과; 기호/URL 없음 → 통과).

## 테스트·검증 전략

- **도구 게이트**: `gate --script clf-t1-1` PASS(토큰보존·기호 0), `--self-test` 불변(이번 작업은 도구 코드 무변경).
- **AI 사실검증**: §2 플래그 0(또는 재작업 후 0).
- **사람 검토**: 사용자 승인.
- **재합성·청취**: clf-t1-1 재합성 → "교과서"가 아니라 "강의"로 들리는가 + 사실 정확. reviewStatus flip(청취·승인 후).
- **앱 회귀**: `flutter test` 776 그린(동기화 테스트 — clf-t1-1 meta approved 유지), analyze 신규 0, web build.

## 범위 / 비목표

- 범위: clf-t1-1 1문서 세그먼트별 풍부화 + AI검증 + 사람승인 + 재합성. **도구 코드·Dart·앱 무변경.**
- 비목표(YAGNI): 18문서 확대(파일럿 결과로 결정) · `enrich` API 도구화(확대 시) · 섹션통째 재구성 · 비-clf 문서.

## 파일럿 후 결정

품질(강의다움)·검수부담(사람 시간)·환각 빈도를 실측 → (a) 확대할 가치가 있나 (b) 18문서는 도구화(Claude API 서브커맨드)할까 세션 반복할까 (c) 저장을 신규 필드로 분리할까([[content-review-pipeline-planned]] S1).

## 정본·관련

- 상위 설계: `docs/superpowers/specs/2026-06-29-audio-instructor-script-design.md`(Stage B 정의)
- 선행: A1·A2 [[audio-instructor-script-planned]]
- 코드: `flutter_app/tool/gen_lecture_audio.py`(`script_to_speech`·gate_script L473·토큰보존 L496)
- 재합성·재승인: [[audio-section-timestamps-shipped]](청취 후 flip)
