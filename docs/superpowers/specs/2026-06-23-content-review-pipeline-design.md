# 학습 오디오 콘텐츠 검수 파이프라인 — 설계 (M2)

작성: 2026-06-23
브랜치: `feat/content-review-pipeline` (develop에서 분기)
범위: 오프라인 대본 생성·보정·검증 파이프라인 (단일 spec). 구현 단계 분해는 writing-plans에서.

## 한 줄 요약

학습 문서 `.md`를 음성 강의로 만들 때, 자동 정제만으로는 표·기호·출처·약어가 음성 문맥에 맞지 않는다.
대본을 **사람이 보정 가능한 `script.json`(SSOT)** 으로 분리하고, 발음사전·표 요약·정적 게이트·청취
검수표를 붙여 `reviewStatus=approved`까지 갈 수 있는 검수 인프라를 만든다. 실제 보정·청취·승인은 사람,
도구·스키마·게이트는 Claude가 만든다.

## 배경

- `gen_lecture_audio.py`는 현재 `md → mp3` 직결이다. 정제(`markdown_to_speech_text`)·기호변환·
  품질게이트(`quality_issues`)·청크·`audio_meta.json`·ID3 strip은 구현됐다.
- 미구현: 문장 단위 사람 보정 `script.json`, 약어 발음사전, 표→음성요약, 청취 검수표.
- 근거 문서: `2026-06-21-clf-t1-1-tts-audio-correction.md`(P0/P1 검수 이슈),
  `2026-06-22-study-audio-m1-failure-taxonomy.md`(게이트 분기). ID3 다중연결(P0-1)은 이미
  `id3Count:1, ok:true`로 해결됐다.

## 목표 / 비목표

**목표**
- `md → script.json(초안) → [사람 보정] → mp3` 2단계 오프라인 파이프라인.
- 발음사전, 표 audioSummary, 정적 게이트, 청취 검수표 템플릿, reviewStatus 전이 규약.
- `reviewStatus=approved`에 도달 가능한 검수 인프라(승인 자체는 사람).

**비목표 (이번 spec 밖)**
- Flutter 런타임 reviewStatus 노출 게이트·stale 메타 비교 UI → **M2 런타임**으로 분리.
- 실제 대본 보정·청취 검수·approved 판정 → **사람**.
- 음질 고도화(PCM 재인코딩·loudness normalization, correction P1-10) → 후속(아래 "후속 과제").

## 아키텍처 — 2단계 파이프라인

```
t1-1.md
  │  generate   (자동: 정제 + 발음사전 치환 + 표 audioSummary 초벌 + skip + issues)
  ▼
script.json     reviewStatus: needs_human_review
  │  ← [사람 보정] scriptText 다듬기 · audioSummary 작성/수정 · skip 확정 · 미등록 토큰 처리
  ▼  synthesize  (보정된 scriptText만 사용 → Polly → ID3 1개)
lecture.mp3 + audio_meta.json
  │  gate        (정적 검증) + review_checklist.md [사람 청취]
  ▼
reviewStatus: approved   ← 사람만. 도구는 자동 설정 경로 없음.
```

- `gen_lecture_audio.py`를 서브커맨드로 재구성: `generate`(md→script.json) · `synthesize`
  (script.json→mp3) · `gate`(정적 검증). 기존 `--meta-only`·`--self-test`·`--dry-run` 유지.
- 파일 배치(현 규약 유지): `assets/audio/{family}/{docId}/` 아래 `script.json` · `lecture.mp3` ·
  `audio_meta.json` · `review_checklist.md`.
- **핵심 불변식**: `synthesize`는 `script.json`의 `scriptText`만 읽는다(md 재파싱 금지). 사람이 보정한
  대본이 음성의 단일 진실원천(SSOT)이다.

## script.json 스키마 (v2)

```json
{
  "schemaVersion": 2,
  "docId": "clf-t1-1",
  "sourceAsset": "assets/content/clf/t1-1.md",
  "sourceHash": "<md sha256>",
  "lexiconVersion": "<발음사전 해시>",
  "generatedAt": "<UTC ISO8601>",
  "reviewStatus": "needs_human_review",
  "segments": [
    {
      "id": "intro",
      "kind": "frontmatter|heading|paragraph|table|selfcheck|source",
      "sourceExcerpt": "<원문 일부>",
      "scriptText": "<음성 대본>",
      "audioSummary": null,
      "skip": false,
      "issues": []
    }
  ]
}
```

- `segment` 단위 = 블록(헤딩/문단/표/자가점검/출처). 문단 segment의 `scriptText`는 여러 문장을 포함할 수 있고, 사람은 그 안에서 문장 단위로 보정한다.
- `kind=table`: `skip=true` 또는 `audioSummary≠null` 중 하나가 필수(게이트 강제).
- `kind=source`: 기본 `skip=true`(URL 낭독 금지).
- `reviewStatus`를 도구가 `approved`로 올리는 경로는 **존재하지 않는다**(검수 전 공개 1차 잠금).
- `sourceHash`는 `synthesize`/`gate`에서 현재 md와 대조해 stale을 판정한다.
- `lexiconVersion`은 generate에 쓰인 발음사전의 해시다. 사전이 바뀌면 재생성이 필요한지 판정하는 추적용(soft)이다.

## 약어 발음사전 (`tool/lexicon.json`, 전 문서 공유)

```json
{
  "schemaVersion": 1,
  "entries": {
    "AWS":     { "say": "에이더블유에스" },
    "CapEx":   { "say": "자본 지출" },
    "OpEx":    { "say": "운영 지출" },
    "CLF-C02": { "say": "씨엘에프 씨 공이" },
    "AZ":      { "firstSay": "가용 영역", "thenSay": "에이제트" }
  }
}
```

- `generate` 단계에서 **텍스트 치환**으로 적용한다(합성 시점 아님 → 결과가 script.json에 박혀 사람이 검수 가능).
- 기본은 `say` 하나. 첫 등장/이후가 다른 항목만 `firstSay`/`thenSay`(예: AZ). generate가 segment
  순서대로 처리하며 첫 등장을 추적한다.
- **단어 경계** 매칭으로 부분 문자열 오치환을 막는다.
- 미등록 영문 대문자 토큰(예: `EC2`, `S3`)은 치환하지 않고 해당 segment `issues`에
  `"unmapped-token: EC2"`로 올린다(soft, 검수 큐). 사람이 사전에 추가하거나 대본에서 직접 보정한다.
- 초기 시드: correction §7 후보(AWS·CapEx·OpEx·on-demand·pay-as-you-go·resource pool·single
  point of failure·IT·axis 등).

## 표 → audioSummary

`generate`가 `kind=table` 세그먼트를 만들 때:
- 원본 표를 `sourceExcerpt`에 보존한다.
- **2열 표**: `audioSummary`에 `"{1열}은 {2열}입니다"` 나열로 **초벌 자동 생성** + `issues:
  ["table-summary-draft"]`(사람 보정 필요 표시).
- **3열 이상/복잡 표**: `audioSummary=null` + `issues: ["table-needs-summary"]`(사람이 작성).
- 정적 게이트는 `kind=table`에 `skip` 또는 `audioSummary` 중 하나를 강제한다. 요약의 *내용 품질*은
  청취 검수(사람)가 책임진다.

## 정적 게이트 (`gate` 서브커맨드)

기존 `quality_issues`를 확장한다. **hard(차단)** 와 **soft(경고)** 를 구분한다.

**script.json — hard**
- 원시 URL 없음.
- 금지 기호 없음: `→`, `≠`, `↓`, `§`, `|`, raw markdown link, `.questions.json`.
- `정답 보기` 잔존 없음(selfcheck 전용 문장으로 변환).
- `❌`/`⚠️` 제거 후 고아 부호(`→ .` 등) 없음.
- `kind=table`은 `skip=true` 또는 `audioSummary≠null`.
- `kind=source`는 `skip=true`.

**script.json — soft**
- 미등록 영문 대문자 토큰 → 검수 큐 경고(차단하지 않음).

**audio_meta — hard (synthesize 후)**
- `id3Count == 1`.
- `contentType == audio/mpeg`.
- `sourceHash == 현재 md sha256`(불일치면 stale, `approved` 금지).

## 청취 검수표 (`review_checklist.md` 템플릿, 사람)

문서별 체크리스트. 항목:
- [ ] 표 핵심 정보가 음성에 포함됐다.
- [ ] 약어 발음이 자연스럽다.
- [ ] 출처 URL을 읽지 않는다.
- [ ] 자가 점검 음성 흐름이 자연스럽다.
- [ ] 첫 20초가 헤더 낭독이 아니다(P1-6).
- [ ] 청크 경계 끊김·메타 재해석이 없다.
- [ ] 사실 정확성: 고유명사·서비스명·수치가 원문과 일치한다.
- 최종: reviewer 서명 + 날짜 → `reviewStatus=approved`.

## reviewStatus 전이 + 공개 잠금 (3중)

```
generate   → needs_human_review
synthesize → needs_human_review (유지)
[사람 청취 + 검수표 완료] → approved   (사람이 script.json·audio_meta 수동 편집)
```

- **잠금①**: 도구가 `approved`를 자동 설정하는 경로가 없다.
- **잠금②**: `approved` 전에는 mp3·script.json을 repo에 포함하지 않고 `pubspec.yaml`의
  `assets/audio/`에도 등록하지 않는다(운영 규율).
- **잠금③**: 기본 빌드 `audio_lecture=false`(진입점 미연결).

## 테스트 전략 (절대조건 2: Test-First)

각 항목은 **실패 테스트를 먼저 작성**한 뒤 최소 구현으로 통과시킨다.

- `generate`: segment 분할 · `kind` 분류 · 발음 치환(첫 등장/이후) · 2열 표 초벌 · unmapped 경고.
- `lexicon`: 단어 경계 치환 · `firstSay`/`thenSay` 순서.
- `gate`: 금지 기호·URL·`정답 보기`·table·source·`id3Count`·stale 각각의 **실패 케이스 우선**.
- `synthesize`: md를 읽지 않고 `script.json`만 읽는다 · ID3 1개(Polly 합성은 `--self-test`/모킹 경로로 분리).
- `--self-test`: 네트워크·TTS 엔진 없이 도는 경로를 유지·확장한다.

분석 게이트(`flutter analyze` 신규 0)·테스트 게이트(`flutter test` 전부 통과)는 기존 CLAUDE.md 규약을 따른다.
단, 이 파이프라인은 `flutter_app/tool/`의 파이썬 도구라 Dart 테스트와 별개로 파이썬 단위 테스트(`--self-test`
또는 별도 테스트 파일)로 검증한다.

## 산출물

- `flutter_app/tool/gen_lecture_audio.py` — `generate`/`synthesize`/`gate` 서브커맨드.
- `flutter_app/tool/lexicon.json` — 약어 발음사전(시드).
- `assets/audio/{family}/{docId}/script.json` — 대본 SSOT(검수 전 미커밋).
- `assets/audio/{family}/{docId}/review_checklist.md` — 청취 검수표 템플릿.
- 파이썬 단위 테스트(generate/lexicon/gate/synthesize).

## 후속 과제 (이 spec 밖)

- Flutter 런타임 reviewStatus 게이트 + stale 메타 비교 UI(M2 런타임).
- 음질 고도화: PCM 재인코딩, loudness normalization(correction P1-10).
- 환각 가드: 고유명사·서비스명·수치 토큰이 원문↔대본 사이에서 보존되는지 검사(correction 대본 정제 규칙 확장).
- 전체 문서(442개) 일괄 generate 및 CI 자동화.

## 검증 분리 (failure taxonomy 준수)

- 재생 엔진 게이트(iOS/Android standalone 잠금 재생 등)와 호스팅 게이트(Range/캐시)와 **콘텐츠 게이트
  (이 spec)** 는 분리해 판정한다. 재생·호스팅이 통과해도 `approved` 전에는 공개 진입점을 열지 않는다.
