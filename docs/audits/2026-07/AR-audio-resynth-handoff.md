# AR 트랙(오디오 재합성) 핸드오프 — 다음 세션 이관

> 작성 2026-07-03 · 브랜치 `fix/2026-07-clf-audio-resynth` · 감사 2026-07 Phase A 후속
> 이 문서 하나로 다음 세션이 AR 트랙을 이어받는다. 상위 맥락은 같은 폴더의 `human-review-list.md`·`ROADMAP.md`.

---

## 0. 30초 요약

- **감사 Phase A(콘텐츠·코드 정정)는 전부 develop 머지 완료** (PR#104·#105·#106·#107).
- **남은 것은 오디오 트랙뿐**: 정정된 CLF 학습문서의 강의 음성(mp3)이 아직 **옛 사실을 낭독**한다. 텍스트(대본)는 고쳤으나 음성 재합성이 미완.
- **AR-1(t4-3 재합성 파일럿) 완료** — 절차 검증됨. **AR-2(나머지 재합성) 미착수.**
- **사람 청취 게이트가 자동화 불가**: 재합성 후 사용자가 mp3를 듣고 `reviewStatus=approved`로 flip해야 라이브 노출. 그 전까지 `audioApproved=false`로 비노출.

---

## 1. 현재 브랜치 상태 (사실)

- 현재 브랜치: **`fix/2026-07-clf-audio-resynth`** — **origin에 push 여부는 §6 참조** (작성 시점 미push였음)
- 워킹트리: 깨끗(미커밋 변경 없음, 이 문서 커밋 전 기준)
- 분기점: `5e0e933`(PR#106 머지) — **PR#107보다 이전**
- `origin/develop`은 이 분기점보다 **2 커밋 앞섬**(PR#107 포함)

### 커밋 3개 (최신순)

| 커밋 | 성격 | 변경 | mp3 |
|---|---|---|---|
| `1eb684a` | stale 표 요약 issues 플래그 70건 정리 | script.json `qualityIssues` 필드 | 무변경 |
| `b618d4a` | **대본 텍스트 전수검토** 정정 15문서 72개소 | 15개 script.json 텍스트 | **무변경** |
| `8462c65` | **t4-3 재합성 파일럿(AR-1)** | clf-t4-3 mp3/meta/script + content_index.dart | **변경** |

> ⚠️ **두 갈래가 한 브랜치에 섞임**: 텍스트 전수검토(`b618d4a`+`1eb684a`, mp3 무변경·완결)와 t4-3 재합성(`8462c65`, mp3 변경·청취 대기). §5에서 분리 옵션 제시.

---

## 2. AR-1 파일럿(t4-3)에서 확립된 재합성 절차 ★황금 참조 = 커밋 `8462c65`

정정 대상 세그먼트만 손대는 **부분 정정 + 전체 재합성** 워크플로. 도구는 `flutter_app/tool/gen_lecture_audio.py`. 정확한 인자는 `py flutter_app/tool/gen_lecture_audio.py <sub> --help`로 확인(도구가 정답). 개요:

1. **대본 편집**: 대상 세그먼트의 `scriptText` / `enrichedScriptText`(강사체·낭독 우선) / `audioSummary`(표) 정정. **낭독되는 실제 텍스트는 `enrichedScriptText`가 있으면 그것** (`_spoken_body` 우선순위: enriched → scriptText → audioSummary).
2. **sourceHash 갱신**: 원문 md의 해시를 **`read_text(utf-8)` 방식**(CRLF→LF 정규화 후 utf-8 인코딩)으로 계산해 `script.json`의 `sourceHash`에 넣고 `reviewStatus`를 `needs_human_review`로. **synthesize가 이 값을 audio_meta.source.sha256으로 복사하므로 synthesize 전에 올바르게 설정.**
   - 해시 계산: `py -c "import hashlib; print(hashlib.sha256(open('flutter_app/assets/content/clf/<doc>.md',encoding='utf-8').read().encode('utf-8')).hexdigest())"`
   - ❌ 함정: `open(...,'rb')` raw 바이트로 계산하면 CRLF 때문에 gate가 stale로 hard fail. 반드시 `read_text(utf-8)` 정규화.
3. **synthesize** (Polly Seoyeon neural, ap-northeast-2, loudnorm -16 LUFS, ID3 strip): mp3 재생성. AWS 자격증명은 `~/.aws`.
4. **chapters** `--script --audio-meta` (⚠️ `--md`는 받지 않음): 챕터 fraction 재계산.
5. **gate** `--script --md --audio-meta --lexicon`: **hard 0**이어야 통과. sourceHash 불일치는 여기서 hard로 잡힌다.
6. **content_index**: `flutter_app/lib/data/content_index.dart`의 해당 문서 `audioApproved: false` (청취 재승인 전 비노출). 파일럿에서 clf-t4-3에 주석과 함께 설정함.
7. **동기화 테스트**: `cd flutter_app && flutter test test/data/content_index_test.dart` 그린 확인. (`audioApproved ↔ reviewStatus=approved + mp3 존재`를 강제. **md sha256은 검사 안 함** — 그래서 sourceHash stale이 테스트를 막지는 않는다.)

### ❌ 절대 금지
- **`generate`(재생성) 서브커맨드를 이미 강사화된 문서에 실행 금지.** 수동 `enrichedScriptText`/connector/`audioSummary`를 덮어쓴다("t1-1 재generate 금지"). 부분 정정은 **script.json 직접 편집**으로만.
- **`.env` 비밀 값 열람 금지**(키 이름만).

---

## 3. 🔴 t4-3 특이사항 — 파일럿은 절차 검증이지 최종본 아님

**t4-3는 AR-2와 함께 한 번 더 재합성해야 한다.** 이유:

- 파일럿 `8462c65`는 seg012/seg013(Support "비즈니스 크리티컬 15분" 등급 정정)만 반영해 재합성했다.
- **그 뒤** `b618d4a`가 seg009 `audioSummary`(컴플라이언스 정의)를 또 정정했다 — 하지만 **재합성 안 함**.
- 따라서 **현재 t4-3 mp3에는 seg009 정정이 반영돼 있지 않다.** (mp3 = `8462c65` 시점 대본)

### sourceHash 3자 대조 (2026-07-03 실측)

| t4-3.md 버전 | sha256 | audio_meta(`c2e66308`)와 |
|---|---|---|
| 내 브랜치 워킹트리 (PR#107 전) | `c2e663083109585c9d788c507fffd969078a137b292dd25696009ad7a179a7a2` | ✅ 일치 |
| develop 최신 (PR#107 후) | `8e5e05f9718db13601e291c76b486196c80ff8f02e4d43bfb2b110332773e9eb` | ❌ stale |

- **develop과 병합하는 순간 t4-3 오디오 sourceHash가 stale**이 된다(PR#107이 t4-3.md 용어표 "컴플라이언스" 셀 1줄 정정: "내부 정책 등 외부 요건"→"등의 요건").
- 정정 **방향은 정합**: PR#107 원문 정정과 대본 seg009 정정(b618d4a)이 같은 방향. PR#107 저자가 커밋 메시지에 "sourceHash 불일치는 재generate 전까지 허용 상태"로 명시.
- **다음 세션 t4-3 재합성 시**: develop 최신 t4-3.md(=`8e5e05f9`) 기준으로 sourceHash를 다시 계산해 넣고 재합성하면 seg009 반영 + PR#107 정합 + sourceHash 정상이 한 번에 해소된다.

---

## 4. AR-2 — 재합성 대기 문서 (미착수)

정정 대상 8문서 중 **t4-3(파일럿, 단 §3대로 재재합성) 외 나머지 7문서**:

`t2-1` · `t2-3` · `t3-3` · `t3-4` · `t3-6` · `t3-8` · `t4-1`

각 문서마다:
1. 어느 세그먼트가 정정됐는지 매핑 — `b618d4a`가 바꾼 script.json diff가 출발점: `git show b618d4a -- flutter_app/assets/audio/clf/clf-<doc>/script.json`
2. §2 절차 적용 (sourceHash는 **develop 최신 원문 md** 기준으로 계산).
3. `audioApproved: false` 설정 + 동기화 테스트.

> 정정 근거 원본: `human-review-list.md`(CONFIRMED/UNCERTAIN 목록)와 `03-docs-facts.md`. 대본에 실제 반영된 것은 `b618d4a` diff가 정본.

---

## 5. 브랜치 정리 옵션 (다음 세션 결정)

현재 브랜치엔 성격이 다른 두 작업이 섞여 있다. 다음 중 택1(추천: **B**):

- **A. 통째로 진행**: 현 브랜치에서 AR-2 재합성까지 마친 뒤 develop PR 1건. 단순하지만 텍스트정정(라이브 무영향)과 재합성(청취 게이트)이 한 PR에 묶여 머지가 청취까지 대기.
- **B. 분리(추천)**: 텍스트 전수검토(`b618d4a`+`1eb684a`, mp3 무변경)를 별도 브랜치로 떼어 **먼저 develop PR → 머지**(라이브 대본-원문 정합 즉시 확보, 청취 불필요). t4-3 재합성 + AR-2는 이 브랜치에 남겨 청취 게이트 후 별도 PR.
  - 분리 방법: `b618d4a`·`1eb684a`를 새 브랜치(예 `fix/2026-07-clf-script-text-review`)로 cherry-pick, 재합성 커밋(`8462c65`)은 audio-resynth에 유지. 순서 주의(`8462c65`가 t4-3 script.json도 건드리므로 cherry-pick 충돌 가능 — t4-3는 재합성 브랜치 쪽으로).

> ⚠️ **공유 워킹트리(§CLAUDE.md 5)**: 커밋 직전마다 `git branch --show-current` 검증. 다른 세션 브랜치 강제이동·reset 금지. 동시 세션(PR#107 저자 Fable 5 등)이 활동 중일 수 있음.

---

## 6. 다음 세션 착수 체크리스트

1. `git branch --show-current` → `fix/2026-07-clf-audio-resynth` 확인. `git fetch origin` 후 `git log --oneline origin/develop -3`로 PR#107 이후 develop 추가 변동 재확인.
2. 브랜치 정리 방향(§5 A/B) 사용자에게 확인.
3. **AR-1 파일럿 t4-3 mp3 청취**(사람 게이트) — `flutter_app/assets/audio/clf/clf-t4-3/lecture.mp3`. 단 §3대로 seg009 미반영이므로 **재재합성이 선행**될 수도. 청취 확인 포인트: "비즈니스 크리티컬 15분" 정정·강사체 자연스러움·발음.
4. t4-3 재재합성(§3) → AR-2 7문서(§4) 순차. 각 문서 §2 절차.
5. 각 재합성 후 `flutter test test/data/content_index_test.dart` 그린.
6. 전부 끝나면 사용자 일괄 청취 → `reviewStatus=approved` + `audioApproved=true` flip(사람) → develop PR → CI 그린 → 머지 → develop→main 릴리스.

---

## 7. 참조 파일

- 대본: `flutter_app/assets/audio/clf/clf-<doc>/script.json` (낭독=`enrichedScriptText`)
- 메타: `flutter_app/assets/audio/clf/clf-<doc>/audio_meta.json` (`reviewStatus`·`source.sha256`·chapters)
- 음성: `flutter_app/assets/audio/clf/clf-<doc>/lecture.mp3`
- 원문: `flutter_app/assets/content/clf/<doc>.md`
- 노출 게이트: `flutter_app/lib/data/content_index.dart` (`audioApproved` 필드)
- 재합성 도구: `flutter_app/tool/gen_lecture_audio.py`
- 사람 확인 목록: `docs/audits/2026-07/human-review-list.md`
- 로드맵: `docs/audits/2026-07/ROADMAP.md`
- 관련 메모리: `full-audit-2026-07`, `clf-audio-text-review-2026-07`, `audio-instructor-script-planned`, `audio-runtime-gate-shipped`
