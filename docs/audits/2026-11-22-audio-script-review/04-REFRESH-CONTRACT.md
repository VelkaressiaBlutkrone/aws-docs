# 2026-11-22 오디오 대본 최신화 — 공통 계약

이 문서는 **대본 수정 세션 5개가 모두 읽는 단일 계약**이다. 각 세션은 앞 단계에서 자기가 검수한
문서의 `script.json`만 고친다. 합성·승인·발행·커밋은 하지 않는다.

## 0. 단계

| 단계 | 하는 일 | 누가 |
|---|---|---|
| **3-a (지금)** | 맡은 대본을 현재 학습문서에 맞춰 수정 + 결과 보고 | 수정 세션 5개(Fable 5.2) |
| 3-b | 대본 검증 · 음성 합성 | 컨트롤러 |
| 4 | **청취 승인** | **사람만** |

## 1. 담당 범위

앞 단계와 같다. 보고서 위치는 `D:\workspace\awc-docs\docs\audits\2026-11-22-audio-script-review\`이다.

| 세션 | 문서 | 검수 보고서 | 결과 보고서 |
|---|---|---|---|
| `audio-clf-d12` | `clf-t1-1`~`t1-4`, `clf-t2-1`~`t2-4` | `clf-d12.md` | `05-refresh-clf-d12.md` |
| `audio-clf-d34` | `clf-t3-1`~`t3-8`, `clf-t4-1`~`t4-3` | `clf-d34.md` | `05-refresh-clf-d34.md` |
| `audio-saa-d12` | `saa-t1-1`~`t1-5`, `saa-t2-1`~`t2-5` | `saa-d12.md` | `05-refresh-saa-d12.md` |
| `audio-saa-d3` | `saa-t3-1`~`t3-9` | `saa-d3.md` | `05-refresh-saa-d3.md` |
| `audio-saa-d4` | `saa-t4-1`~`t4-5` | `saa-d4.md` | `05-refresh-saa-d4.md` |

## 2. 사용자 결정 — 그대로 따른다

- **R3 중요 누락은 전부 반영한다.** 합성 뒤 문서에 추가된 절과 사실이 음성에 들어가야 한다.
- 대본은 학습문서의 **강의체 확장판**이다. 대화체 풀이와 짧은 비유는 허용하고, **문서에 없는 새 시험 사실은 금지**한다.
- **Lambda 표준 함수 타임아웃 상한은 30분(1,800초)** 이다. Managed Instances의 비동기·이벤트 소스 매핑은 90분이다. 15분으로 말하는 발화를 남기지 않는다. 다른 서비스의 15분(API Gateway 스트림, 토큰 수명 등)은 건드리지 않는다.
- 사실의 기준은 **현재 학습문서**다. 검수 뒤 문서가 정정됐으므로 보고서의 제안 발화를 그대로 넣기 전에 **현재 문서와 다시 대조**한다. 정정 내역은 `02-docfix-*.md`에 있다.

## 3. 작업 순서 (문서마다)

경로: `TOOL=D:\workspace\awc-docs\flutter_app\tool\gen_lecture_audio.py`, 대본 `flutter_app\assets\audio\<cert>\<docId>\script.json`, 문서 `flutter_app\assets\content\<cert>\...md`(CLF는 `t1-1.md`처럼 접두사가 없다).

1. `py <TOOL> resync --script <script.json> --md <md> --dry-run`으로 규모를 확인한다.
2. `py <TOOL> resync --script <script.json> --md <md>`를 **문서당 한 번** 실행한다. 강의체 문장과 세그먼트 id는 보존되고, 바뀐 블록은 `resyncStatus: changed`, 새 블록은 `new`가 된다.
3. 보고서 항목을 **채택 / 기각 / 이미 해결**로 판정해 적용한다. R1·R2·R3·R4는 필수이고 R5도 발화 품질이 나아지면 적용한다.
4. `changed`·`new` 문단에 `enrichedScriptText`를 **직접 쓴다.** `enrich` 명령은 쓰지 않는다.
5. `audioSummary`가 없는 비-skip `table`·`code`에 음성용 요약을 쓴다. 표는 핵심 비교를, 코드 블록은 예고 문장이 약속한 내용을 말로 풀어 준다. 코드를 글자 그대로 읽지 않는다.
6. 발음사전(`flutter_app\tool\lexicon.json`)의 표준 표기로 발화를 맞춘다. 근거는 `03-pronunciation-canon.md`다. 이 때문에 **보존된 문장의 표기만** 바꾸는 것은 허용한다. 영문 뒤 조사도 한글 표기에 맞춘다.
7. 생성된 전환 문구(`connector`)의 조사·어색함을 **마지막 resync 뒤에** 고친다.
8. `py <TOOL> gate --script <script.json> --md <md>`가 **hard 0**이 될 때까지 고친다. `audio_meta`는 넘기지 않는다.

## 4. 발화 작성 규칙

- 합니다체 대화체, 음성용 평문. URL·마크다운·기호(`→ ≠ ↓ § |`)·괄호 부연 남발 금지.
- 문서의 약어·수치·핵심 주장을 보존한다. 비유는 꼭 필요할 때만 쓰고 같은 소재를 반복하지 않는다.
- 분량은 원문의 약 2배 이내다. 시험에 필요한 사실을 빠뜨려 짧게 만들지도 않는다.
- 서비스 종료·유지 관리·범위 외 메모는 **문서당 첫 언급에 한 번** 말한다.
- 제목 세그먼트의 번호 괄호·줄표·「(보강)」 같은 작성용 꼬리표는 음성에서 자연스럽게 정리한다.

## 5. 금지

- ⛔ 맡은 문서의 `script.json`과 자기 결과 보고서 외의 파일을 만들거나 고치지 않는다.
- ⛔ `sourceExcerpt`·`sourceHash`·세그먼트 `id`·`skip`을 손으로 바꾸지 않는다(`resync`가 관리한다). 스캐폴딩의 skip을 풀지 않는다.
- ⛔ `reviewStatus`를 `approved`로 바꾸지 않는다. `audio_meta.json`, mp3, `content_index.dart`, 학습문서, 문항, 발음사전, 코드, 테스트를 고치지 않는다.
- ⛔ `generate`, `enrich`, `verify`, `synthesize`, `publish_audio.py`를 실행하지 않는다. 외부 API를 호출하지 않는다.
- ⛔ git 쓰기 명령 금지: 커밋, 브랜치 전환, `stash`, `checkout`, `reset`, push. 현재 브랜치는 `feat/audio-script-refresh`다.
- ⛔ 전체 `flutter test`를 돌리지 않는다. 이 브랜치에서는 승인 상태 동기 테스트가 의도적으로 레드가 된다.
- `script.json`은 파이썬 `json`으로 읽고, 쓸 때는 **도구의 `write_json`과 같은 서식**을 유지한다. 임시 스크립트는 세션 스크래치패드에 파일로 쓰고 `py`로 실행한다. `py -`는 쓰지 않는다. stdout은 UTF-8로 설정한다.
- 모든 파일 명령은 **절대경로**를 쓴다. 맡은 범위 밖 문서로 진행하지 않는다.
- 학습문서 자체가 틀려 보이면 고치지 말고 결과 보고서의 `## 컨트롤러 요청`에 적는다.
- 명세가 부족하면 추측하지 말고 멈춰 `NEEDS_CONTEXT`로 보고한다.

## 6. 결과 보고서 형식

```markdown
# <세션> 대본 최신화 결과

| 문서 | resync(kept/changed/new/removed) | 직접 쓴 문단 | 쓴 요약(표/코드) | 보고 항목(채택/기각/이미 해결) | gate hard | gate soft |

## 기각·변경 판정
(항목, 이유, 현재 문서 근거)

## 컨트롤러 요청
```

끝나면 결과 보고서 경로, 문서별 gate hard, `NEEDS_CONTEXT`만 보고하고 정지한다.
