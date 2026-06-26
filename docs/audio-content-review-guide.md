# CLF 학습 오디오 청취 검수 가이드

학습 문서 오디오 강의("주머니 라디오")의 콘텐츠 검수(M2) 중 **합성 → 청취 → 승인** 단계를 수행하는 가이드. 발음사전·검수도구는 develop에 반영되어 있고, 이 단계는 **사람(검수자)만** 수행한다. Claude는 mp3 청취·Polly 합성을 할 수 없다.

관련 정본: 설계 `docs/superpowers/specs/2026-06-23-content-review-pipeline-design.md`, 플랜 `docs/superpowers/plans/2026-06-23-content-review-pipeline.md`, M1 핸드오프 `docs/superpowers/specs/2026-06-21-study-audio-m1-handoff.md`.

> 모든 명령은 **`flutter_app/` 디렉터리** 기준. Windows는 `py` 런처 사용(`python`은 Store alias로 깨질 수 있음). 빌드/합성 명령은 **PowerShell**로 실행(Git Bash는 경로 변형 위험).

---

## 0. 현재 상태 (출발점)

- CLF **19문서**(`clf-t1-1` ~ `clf-t4-3`)의 `script.json`이 `gate` PASS(hard 0 / soft 0), `reviewStatus: "needs_human_review"`.
- 발음사전(`tool/lexicon.json`, 147 entries)·검수도구(`apply_audio_summary.py`·`dump_tables.py`)는 develop 머지됨(PR #60).
- 산출물 위치: `flutter_app/assets/audio/clf/clf-<t>/` (모두 **untracked** — approved 후에만 repo·pubspec 등록).
  - `script.json` (대본, SSOT)
  - `review_checklist.md` (청취 체크리스트)
  - `lecture.mp3` + `audio_meta.json` (합성 후 생성)
- **남은 일 = 합성 → 청취 → `reviewStatus=approved`.** 전부 검수자(사람) 영역.

---

## 1. 사전 준비

| 항목 | 내용 |
|---|---|
| AWS 자격증명 | Amazon Polly 호출 권한 필요. `aws configure` 또는 환경변수(`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_DEFAULT_REGION`) |
| Python + boto3 | `py -c "import boto3"`로 확인. 없으면 `py -m pip install boto3` |
| 엔진(기본값) | **Seoyeon · neural · ap-northeast-2** — 인자 생략 시 자동 적용 |
| 청크 | 한 요청 최대 **2900자**(`--max-chars` 기본 0 → 내부 2900). Polly neural 3000자 한도 회피용. 6000자 이내는 사실상 단일 요청 |
| 비용 | Polly neural은 문자당 과금. 19문서 합성 비용 발생 — 한 번에 끝내는 게 좋음 |

---

## 2. 합성 (synthesize)

`script.json` → `lecture.mp3` + `audio_meta.json`(같은 폴더에 생성).

**한 문서:**
```powershell
cd D:\workspace\awc-docs\flutter_app
py tool/gen_lecture_audio.py synthesize `
  --script assets/audio/clf/clf-t1-2/script.json `
  --out    assets/audio/clf/clf-t1-2/lecture.mp3
```
(`--voice Seoyeon`, `--polly-engine neural`, `--region ap-northeast-2`, `--max-chars 2900`은 모두 기본이라 생략)

**19문서 일괄:**
```powershell
cd D:\workspace\awc-docs\flutter_app
Get-ChildItem assets/audio/clf -Directory | ForEach-Object {
  $d = $_.Name
  py tool/gen_lecture_audio.py synthesize --script "assets/audio/clf/$d/script.json" --out "assets/audio/clf/$d/lecture.mp3"
}
```

- 출력의 `[synthesize] N자 → M청크`, `[ID3] 1개 — OK` 확인(ID3는 1개여야 함 — 도구가 첫 청크 외 ID3v2를 strip).
- 합성 직후 `audio_meta.json`이 옆에 생성됨(컨테이너 검사·sha 메타 포함).

---

## 3. 청취 — 무엇을 듣는가

각 폴더 `review_checklist.md`의 7항목(생성됨). **① 표 핵심·⑦ 사실 정확성**이 가장 중요하다.

| 체크 항목 | 들으면서 확인할 것 | 어긋나면 고칠 곳 |
|---|---|---|
| 표 핵심 정보가 음성에 포함됐다 | 3열+ 표(보통 `seg009` 등)의 음성 요약이 표 내용을 빠짐없이·정확히 전달하나 | `apply_audio_summary.py`의 `SUMMARIES` |
| 약어 발음이 자연스럽다 | 에스쓰리·아이엠·나클·냇·와프 등이 어색하지 않나 | `tool/lexicon.json` |
| 출처 URL을 읽지 않는다 | 출처 segment가 음성에서 빠졌나(skip) | (gate가 보장; 청취로 재확인) |
| 자가 점검 음성 흐름이 자연스럽다 | 자가점검(Q&A) 음성이 안 나오나(skip) | 동일 |
| 첫 20초가 헤더 낭독이 아니다 | 도입부가 헤더만 읽지 않고 자연스럽나 | 원본 md 구성 |
| 청크 경계 끊김·메타 재해석이 없다 | 긴 문단(2900자 청크 분할) 경계에서 끊김·어색 없나 | 장문 분할 검토 |
| 사실 정확성: 고유명사·서비스명·수치가 원문과 일치 | 서비스명·고유명사·수치가 원문과 일치하나(요약 왜곡 없는지) | 원문 대조 후 수정 |

---

## 4. 문제를 찾으면 — 수정 절차

수정 종류에 따라 영향 범위가 다르다.

| 수정 대상 | 파일 | 영향 범위 | 재생성 |
|---|---|---|---|
| 약어 발음 | `tool/lexicon.json`의 `say` | **전 문서 공통** | 영향받는 문서 모두 재generate |
| 표 음성 요약 | `tool/apply_audio_summary.py`의 `SUMMARIES` | 해당 문서만 | 해당 문서만 |

**수정 후 반드시 이 순서**(아래 ⚠️ 참조):
```powershell
cd D:\workspace\awc-docs\flutter_app
# 1) 재생성: md → script.json (수동 audioSummary는 이 단계에서 덮어써짐)
py tool/gen_lecture_audio.py generate `
  --md assets/content/clf/t1-2.md `
  --out-dir assets/audio/clf/clf-t1-2 `
  --doc-id clf-t1-2 `
  --lexicon tool/lexicon.json
# 2) 수동 audioSummary 재주입
py tool/apply_audio_summary.py clf-t1-2
# 3) 정적 검증 (PASS 확인)
py tool/gen_lecture_audio.py gate `
  --script assets/audio/clf/clf-t1-2/script.json `
  --md assets/content/clf/t1-2.md
# 4) 재합성 (mp3는 보정 전 버전이므로 반드시 다시)
py tool/gen_lecture_audio.py synthesize `
  --script assets/audio/clf/clf-t1-2/script.json `
  --out assets/audio/clf/clf-t1-2/lecture.mp3
```

> ⚠️ **`generate`는 `parse_segments`부터 새로 만들어 수동 `audioSummary`를 덮어쓴다.** 그래서 `lexicon/SUMMARIES 수정 → generate → apply_audio_summary → gate → synthesize` 순서를 반드시 지킨다. 표 음성 요약의 SSOT는 `apply_audio_summary.py`의 `SUMMARIES`다(여기만 고치고 재주입).
>
> ⚠️ **`clf-t1-1`은 `SUMMARIES`에 없다.** 현재 PASS 상태이므로 **재generate하지 말 것**(재생성하면 수동 보정이 날아간다). t1-1을 다시 만들어야 하면 그 요약을 먼저 `SUMMARIES`에 옮겨라.
>
> `scriptText` 문장 흐름 자체(장문 호흡 등)는 원본 `assets/content/clf/t<n>.md` 영역 — 학습 본문에 영향을 주므로 신중히, 별도로 다룬다. md를 고치면 `sourceHash`가 바뀌어 gate가 `stale`을 검출하니 재generate가 필요하다.

---

## 5. 승인 (approved)

검수 통과 시:
1. `script.json`의 `"reviewStatus"`를 `"needs_human_review"` → `"approved"`로 수동 변경.
2. `audio_meta.json`의 `script.reviewStatus`도 `"approved"`로 변경(또는 변경 후 `synthesize` 재실행 시 자동 반영).
3. `review_checklist.md`에 `reviewer`·날짜 기입.

> `gate`는 `reviewStatus`를 검사하지 않는다(정적 검증만). 승인은 전적으로 사람의 수동 전환이다.

---

## 6. approved 후 repo 등록 (별도 PR)

approved된 문서만:
1. `git add` 대상: 해당 폴더의 `script.json` + `lecture.mp3` + `audio_meta.json` (+ `review_checklist.md`).
2. `pubspec.yaml`의 `assets`에 경로 등록(`assets/audio/clf/...`).
3. 라이브 노출 플래그 `audio_lecture`(현재 기본 false)는 별도 결정.
4. `develop`에서 `feat/*` 분기 → 커밋 → **develop PR**(브랜치 전략). 커밋 직전 `git branch --show-current` 검증.

---

## 7. 도구 CLI 레퍼런스 (`tool/gen_lecture_audio.py`)

| 서브커맨드 | 필수 인자 | 선택 인자(기본값) | 산출물 |
|---|---|---|---|
| `generate` | `--md`, `--out-dir` | `--doc-id`, `--lexicon` | `script.json`, `review_checklist.md` |
| `synthesize` | `--script`, `--out` | `--engine`(polly) `--voice`(Seoyeon) `--polly-engine`(neural) `--region`(ap-northeast-2) `--max-chars`(0→2900) | `*.mp3`, `audio_meta.json` |
| `gate` | `--script` | `--md`, `--audio-meta` | (검증 결과 stdout) |

- `py tool/gen_lecture_audio.py --self-test` : 네트워크·Polly 불필요한 자체 검증.
- `py tool/apply_audio_summary.py [doc-id ...]` : 생략 시 `SUMMARIES` 전체 재주입.
- `py tool/dump_tables.py` : 미작성 3열+ 표의 seg id·원문 덤프(검수 보조).

**gate hard 검사:** URL/금지기호(`→ | ≠ ↓ §` 등)/정답·보기 노출/링크 잔존/table에 `audioSummary` 없음/source 미skip. `--audio-meta` 주면 `id3Count != 1`·`stale`(sourceHash 불일치)도 hard. **soft:** 미등록 대문자 토큰(발음사전 누락 후보).

---

## 8. 주의·함정

- **검수 전(`approved` 전) mp3·script.json을 repo/pubspec에 넣지 말 것.** 외부 업로드(익명 호스트·S3 presigned)도 금지 — 자동모드 분류기가 차단하므로 검수자가 직접만.
- `audio_meta.json`의 `id3Count`는 **1**이어야 한다(다중이면 재합성/strip 확인). 합성 후 `gate --audio-meta`로 검사 가능.
- 발음/요약을 수정했다면 **반드시 재합성** — `lecture.mp3`는 수정 전 음성이다.
- iOS 실기기 연속재생 게이트(M1)는 이 콘텐츠 검수와 별개다.
