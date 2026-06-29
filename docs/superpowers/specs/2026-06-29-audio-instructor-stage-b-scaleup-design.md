# 설계: 오디오 대본 LLM 재강의 확대 (Stage B 도구화 — enrich/verify + 신규필드 + 위험기반 청취)

- 날짜: 2026-06-29
- 생성: /superpowers:brainstorming
- 상태: APPROVED (설계 사용자 승인)
- 모드: Builder(개인 학습 도구)
- 범위: clf-t1-1 파일럿(세션 내 수작업 풍부화) 결과를 **재현·일괄화**하기 위한 인프라. ① `enrich`/`verify` 서브커맨드(Claude API) 도구화, ② 풍부화본을 `enrichedScriptText` **신규필드**로 분리 저장, ③ 사람 청취를 **위험기반 표본 + 초기 캘리브레이션**으로. clf-t1-1을 신규필드로 마이그레이션하고 도구를 1~2문서에 실제 적용해 검증한다. **18문서 전량 합성은 비목표**(인프라 완성 후 별도 운영 반복).

## 배경

[[audio-instructor-pilot-stage-b]](`2026-06-29-audio-instructor-pilot-stage-b-design.md`)에서 clf-t1-1 1문서를 세션 내 서브에이전트로 풍부화(대화체+비유) → AI 사실검증 PASS(환각 0, 비유 2개만 절제 삽입) → 사람 승인·재합성까지 완료했다. 파일럿이 입증한 것:

- 세그먼트별 풍부화는 환각을 만들지 않았고(verify PASS), 비유는 억지로 모든 세그먼트에 들어가지 않았다.
- 그러나 메커니즘이 **세션 내 수작업**이라 18문서로 확대하면 18회 디스패치 + 18회 검증 디스패치로 재현성이 약하다.
- 저장이 `scriptText` **덮어쓰기**라 원문 평문이 git 히스토리에만 남아, 재풍부화·롤백·원문대조가 매번 git을 들춰야 한다.

이 설계는 그 두 약점(재현성·저장)을 도구화 + 신규필드로 해결하고, 청취 부담을 위험기반으로 낮춘다.

### 기존 코드 사실 (확인됨)

- `gen_lecture_audio.py`는 순수 도구로, 외부 호출이 Polly(boto3)뿐이다(네트워크 의존 최소). enrich/verify는 여기에 **Claude API(anthropic SDK) 의존성을 새로 도입**한다.
- 발화 텍스트 결정: `_segment_speech`(L722)·`script_to_speech`(L411)·`synthesize`는 비-skip·비-table 세그먼트에서 `scriptText`를 발화하고, table은 `audioSummary`를 발화한다.
- `gate_script`(L473)의 토큰보존(`check_token_preservation` L313)은 세그먼트별 `(sourceExcerpt, scriptText)`로 약어(hard)·수치(soft) **누락**을 검사한다. **추가 환각(원문에 없는 새 주장)은 못 잡는다** → 의미 수준 사실검증은 LLM(verify)이 필요하다.
- 서브커맨드 구조: `generate`/`synthesize`/`gate`/`chapters`/`descaffold`/`connectors`(argparse). enrich/verify를 같은 패턴으로 추가한다.
- clf-t1-1은 이미 A1(skip)·A2(connector 7개) + Stage B 풍부화(scriptText 덮어씀)·reviewStatus=approved 상태다.
- 나머지 18문서는 `generate`만 된 검수 전 상태(`_corpus_scan_report.md`): gate FAIL(발음사전·3열표 audioSummary 미작성), mp3 없음, untracked. **enrich는 그 선행 작업이 끝난 위에 얹힌다(이 설계 비목표).**

## 결정사항 (brainstorming)

1. **저장 = 신규필드 분리.** `enrichedScriptText`(선택)를 추가하고 발화는 "있으면 enriched, 없으면 scriptText". `sourceExcerpt`·`scriptText`를 파일 안에 영구 보존 → diff·롤백·재풍부화·A/B가 git 없이 가능. (대안 비채택: scriptText 덮어쓰기=원문 유실 위험 · 3단 풀분리=과설계.)
2. **enrich 메커니즘 = Claude API 직접 호출.** 세그먼트별 자동 일괄, 프롬프트 코드 내장. 18문서 재현 쉬움. 비결정성은 verify + 사람청취 게이트로 흡수. (대안 비채택: 세션 반복=재현성 약함 · `--api` 이중경로=YAGNI 위반.)
3. **사실검증 = `verify` 별도 서브커맨드.** enrich(풍부화)와 verify(LLM 사실대조)를 분리해 재실행·디버그를 쉽게 하고, 사람이 verify 리포트를 게이트로 본다. (대안 비채택: enrich 2단 내장=책임 결합 · 세션 검증 유지=자동화 이점 반감.)
4. **청취 = 위험기반 표본 + 초기 캘리브레이션.** AI verify는 전수, 사람 청취는 위험 지점(비유 삽입·verify 플래그·신규 영문 토큰)만. 단 확대 첫 2~3문서는 전수 청취로 기준을 잡는다.
5. **모델 기본 = 풍부화·검증 모두 Opus 4.8**(시험 콘텐츠라 환각 비용↑). `--model`로 풍부화만 Sonnet로 낮출 수 있게 둔다.
6. **clf-t1-1 마이그레이션 포함.** 현재 scriptText의 풍부화본을 enrichedScriptText로 옮기고 원문 평문을 scriptText로 복원(git 히스토리에서). 음성 동일 → 재합성 불필요, 재승인만.

## 컴포넌트

### A. 저장 모델 (신규필드)

- 세그먼트 스키마: `{id, kind, sourceExcerpt, scriptText, enrichedScriptText?, audioSummary, skip, issues}`. `enrichedScriptText`는 선택 필드(없으면 미풍부화 = 기존과 동일 동작).
- 발화 소스 우선순위(`_segment_speech`·`script_to_speech`):
  - table → `audioSummary` (불변).
  - 그 외 비-skip → `enrichedScriptText` 있으면 그것, 없으면 `scriptText`.
- 하위호환: enrichedScriptText가 없는 기존 19 CLF 문서·테스트는 동작 불변(스키마 추가 필드, 발화 폴백).

### B. `enrich` 서브커맨드 (Claude API)

- 시그니처: `enrich --script <path> [--model <id>] [--only segNNN[,segNNN...]] [--dry-run]`.
- 대상 필터: `not skip and kind not in {heading, connector, table} and scriptText`(파일럿과 동일). heading=제목 원문 유지, connector=A2 전환구, table=audioSummary, skip=A1 스캐폴딩.
- 세그먼트별 Claude API 호출. 프롬프트(코드 내장 — 파일럿 지시문 정형화): 입력은 `sourceExcerpt`(원문)·현재 `scriptText`. 출력 규칙:
  - (a) 대화체·합니다체로 자연스럽게,
  - (b) 이해를 돕는 **짧은 비유/예시 1개**를 자연스러운 곳에만(억지 삽입 금지),
  - (c) `sourceExcerpt`의 약어·수치·핵심 주장 보존,
  - (d) **원문에 없는 새 시험 사실 단정 금지**(비유는 설명용 예시일 뿐),
  - (e) 평문(기호 `→≠↓§|`·URL·마크다운·괄호부연 남발 금지)·원문 ~2배 이내,
  - (f) 영문 약어는 한글 발음 표기 관례 유지(예 AWS→에이더블유에스).
- 결과를 `enrichedScriptText`에 머지(다른 필드·세그먼트 순서/개수 불변), top-level `reviewStatus=needs_human_review`.
- `--dry-run`: API 호출 없이 대상 세그먼트 목록만 출력(비용 0 사전점검). `--only`: 특정 세그먼트만 재풍부화(verify 플래그 후 재작업용).
- 의존성: `anthropic` SDK, `ANTHROPIC_API_KEY`(env). 키 없으면 명확한 에러로 중단(추측 금지).
- 출력 리포트: `<doc-dir>/enrich_report.md` — 풍부화 세그먼트 수, 비유 삽입 세그먼트, 신규 영문 토큰, **사람 청취 권장 대상 목록**(§D 위험 지점).

### C. `verify` 서브커맨드 (LLM 사실대조)

- 시그니처: `verify --script <path> [--model <id>]`.
- 대상: `enrichedScriptText`가 있는 세그먼트.
- 세그먼트별 `(sourceExcerpt → enrichedScriptText)`를 Claude API로 대조해 다음을 플래그:
  - 원문이 뒷받침하지 않는 **사실 단정**(없던 수치·서비스명·인과·"항상/모두" 과일반화),
  - **틀린 비유/예시**(개념 오도),
  - 원문 수치·약어 **변경/누락**.
- 출력: 플래그 목록(`seg id | 유형 | 원문 근거 | 제안`) 또는 `PASS`. stdout + `<doc-dir>/enrich_verify.md`. 코드/파일 수정 없음(검증만).
- 종료코드: 플래그 있으면 non-zero(파이프라인에서 게이트). 플래그 0이어야 청취 단계로.

### D. 청취·승인 절차 (위험기반 표본)

- **AI verify는 전수**(모든 enriched 세그먼트, §C).
- **사람 청취는 위험 지점만**: enrich 리포트(§B)가 뽑는 ① 비유/예시 삽입 세그먼트 ② verify 플래그(있었던) 세그먼트 ③ 신규 영문 토큰 포함 세그먼트.
- **초기 캘리브레이션**: 확대 첫 2~3문서는 전수 청취로 품질 기준(강의다움·발음·호흡)을 잡는다. 이후 문서부터 위험기반 표본 적용.
- **사람 최종승인 게이트**: 시험 콘텐츠 = 사람 책임. AI verify PASS 후에도 사용자 사인 전엔 `reviewStatus=approved` flip 금지. 승인 후 재합성·flip(기존 [[audio-section-timestamps-shipped]] 패턴).

### E. 도구 게이트 변경

- `gate_script` 토큰보존 검사 대상을 `(sourceExcerpt, 발화소스)`로 — 발화소스가 enriched면 enriched 기준(누락 검사). 기호/URL hard 규칙도 발화소스에 적용.
- `--self-test`에 케이스 추가: enriched 우선순위 발화, enrich 대상 필터, verify 입출력 형식, gate가 enriched 기준으로 토큰보존 판정.
- enrich/verify의 API 호출 자체는 self-test에서 **모킹/스킵**(네트워크·비결정성 — 결정적 self-test 유지). 검증되는 건 머지·필터·발화소스·리포트 로직.

### F. clf-t1-1 마이그레이션

- 현재 clf-t1-1 script.json은 scriptText에 풍부화본이 들어있고 원문 평문은 git 히스토리(파일럿 직전 커밋)에 있다.
- 마이그레이션: 풍부화 직전 커밋(`9deed07`의 부모)에서 원문 평문 scriptText를 복원해 `scriptText`에 두고, 현재 풍부화본을 `enrichedScriptText`로 이동. 발화 결과는 enriched 우선이라 **음성 동일** → 재합성 불필요, gate PASS·reviewStatus=approved 유지(재승인만, 음성 무변).
- 일회성 마이그레이션 스크립트(`assets/audio/clf/` 보조 .py, repo 등록 안 함) 또는 도구 내 `migrate` 보조. 검증: 마이그레이션 후 `_segment_speech` 출력이 마이그레이션 전과 바이트 동일.

## 테스트·검증 전략

- **TDD(도구 코드)**: enriched 발화 우선순위·enrich 대상 필터·gate enriched 토큰보존·verify 출력 파싱은 실패 테스트 선작성 후 구현. `flutter_app/tool/` Python 테스트 또는 `--self-test` 케이스.
- **결정적 self-test**: API 호출은 모킹/스킵. self-test는 코드 변경 후에도 OK.
- **앱 회귀**: `flutter test`(현 기준 그린 유지 — enrichedScriptText는 추가 필드, 동기화 테스트 무영향), `flutter analyze` 신규 0, web build.
- **실적용 검증**: clf-t1-1을 마이그레이션해 `enrichedScriptText` 필드를 갖춘 뒤 `verify`→`gate`(→재합성 불필요, 음성 동일)를 끝까지 돌려본다. `enrich`(API 신규 호출)는 **이미 선행작업이 끝나 gate 통과 가능한 문서가 있을 때만** 1문서에 실적용한다 — 18문서 선행작업은 비목표라, 그런 문서가 없으면 enrich는 `--dry-run`(대상 필터·리포트만, API 호출 0)으로 경로를 검증하고 실호출 적용은 확대 운영으로 미룬다.
- **마이그레이션 검증**: clf-t1-1 발화 텍스트 바이트 동일(음성 무변), gate PASS.

## 범위 / 비목표

- **범위**: 신규필드(`enrichedScriptText`) + `enrich`/`verify` 서브커맨드(Claude API) + gate/self-test 갱신 + clf-t1-1 마이그레이션 + clf-t1-1로 verify/gate 실적용 검증(+ 선행작업 끝난 문서가 있으면 1문서 enrich 실호출, 없으면 `--dry-run` 경로검증).
- **비목표(YAGNI)**:
  - 18문서 **전량** enrich/합성(인프라 완성 후 별도 운영 반복 — 본 설계는 인프라 + 검증까지),
  - 18문서 **선행 작업**(발음사전 결정·3열표 audioSummary 작성·기본 generate/gate 통과) — 이건 [[content-review-pipeline]] S1~S2 영역,
  - 세션/`--api` 이중 경로,
  - 섹션 통째 재구성(B 입자),
  - 비-CLF 문서.

## 파일럿 후 확대 운영 (이 설계 이후)

인프라가 서면, 18문서 확대는: (선행) 발음사전·audioSummary·generate → `enrich` → `verify`(플래그 0까지 `--only` 재작업) → `gate` → 청취(첫 2~3 전수 후 위험기반) → 승인 → 재합성·flip → 배포 PR. 첫 캘리브레이션 결과로 모델(Opus/Sonnet)·청취 비율을 조정한다.

## 정본·관련

- 선행 파일럿: `docs/superpowers/specs/2026-06-29-audio-instructor-pilot-stage-b-design.md`
- 상위 Stage B 정의: `docs/superpowers/specs/2026-06-29-audio-instructor-script-design.md`
- 코드: `flutter_app/tool/gen_lecture_audio.py`(`_segment_speech` L722·`script_to_speech` L411·`gate_script` L473·`check_token_preservation` L313·`main`/argparse L1583)
- 18문서 선행(비목표): `_corpus_scan_report.md`, [[content-review-pipeline]]
- 재합성·청취후 flip 패턴: [[audio-section-timestamps-shipped]]
