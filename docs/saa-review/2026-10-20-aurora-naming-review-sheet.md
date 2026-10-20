# SAA-C03 `Aurora Serverless v2` 명칭 정리 검수 체크시트 — 2026-10-20

> 대상: `saa-t3-5` 1문항 · `saa-t4-3` 4문항 — **두 Task 모두 15/15 `verified:true` = 라이브**.
> [2026-10-20-propagation-review-sheet.md](2026-10-20-propagation-review-sheet.md)가 「별건」으로
> 분리한 항목을 이어받은 작업이다. 운영 가이드는 [review-rubric.md](review-rubric.md).

**이 시트의 판정 열은 「AI 권고 — 검수자 확정 필요」다.** `verified` flip과 최종 정답 판정은
사람만 한다. 이 작업은 `verified` 플래그를 건드리지 않았다.

## 검수 메타

| 항목 | 값 |
|---|---|
| 검수자 | _(기입)_ |
| 검수일 | _(기입)_ |
| 브랜치 | `saa-review/aurora-naming` |
| 기준 커밋 | `c231932` (분기 base = `origin/develop`, PR #165 머지 직후) |
| AI 재검수 수행 | 2026-10-20 · 공식 문서 직접 조회 + 앱 코드 확인 |
| 변경 성격 | **명칭 통일만** — 사실 주장·정답·보기 구성은 건드리지 않았다 |

## 왜 미뤘다가 지금 하는가 — PR #165의 판단을 정정한다

PR #165는 이 항목을 두 이유로 뺐다. ①은 유효했고 **②는 틀렸다.**

| PR #165의 사유 | 지금의 판정 |
|---|---|
| ① 사실 오류가 아니라 명칭 현대화다 | **유효.** 그래서 `fix`가 아니라 명칭 통일로 따로 처리했다 |
| ② `skill` 라벨이 `wrongSkills`에 적재돼 **라벨을 바꾸면 적재 키가 고아가 된다** | **틀렸다.** `skill`은 키가 아니다 — 아래 근거 |

### `skill`은 적재 키가 아니다 (코드 확인)

| 확인 항목 | 근거 |
|---|---|
| `wrongSkills`는 **설계상 비정규화 스냅샷** | `lib/models/attempt_record.dart` — *"한 응시의 오답 개념(비정규화) — stale 문항에도 개념 보존(report 개념 집계용)"* |
| 로컬 적재 키 | `lib/data/history_store.dart:17` — `awsdocs.history.v1`. `skill`은 레코드 **값**으로만 직렬화된다 |
| 클라우드 동기 키 | `lib/data/cloud/sync_merge.dart:9` — `certId\|examId\|date`. `skill` 무관 |
| 소비처 5곳 전부 표시·dedup | `quiz_widgets.dart:259`(라이브 뱅크에서 개념 큐) · `wrong_skills.dart:13`(응시 시 스냅샷) · `concept_report.dart:35·40`(Task별 dedup) · `report_page.dart:70`(레거시 레코드용 라이브 조인) · `report_page.dart:310` `Text(concept.skill)` — **표시 전용**. 딥링크는 `section`을 쓴다 |
| 라벨을 단정하는 테스트 | **없음**(전체 `.dart` 대조) |

**남는 영향(경미):** `buildConceptReport`가 문자열 일치로 dedup하므로, 그 3문항을 **이미 틀린
이력이 있는** 사용자는 옛 라벨이 history에 남고 앞으로 틀리면 새 라벨이 저장돼 약점 리포트의
같은 Task 아래 **비슷한 두 줄**이 보일 수 있다. 데이터 손실·고아 없음, 마이그레이션 코드
불필요, 이력이 교체되면 자연 해소된다.

## 표기 결정 — `Aurora serverless` (소문자 s)

문항이 인용하는 **그 URL**
(`AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html`)의 현재 제목이
"**Using Aurora serverless**"이고 본문에 `v2`가 한 번도 나오지 않는다(하위 주제도 "How Aurora
serverless works" 등으로 전부 `v2`를 뗐다). `saa-t3-5.md`·`saa-t4-3.md`도 이미
`Aurora serverless`를 파일당 15회 쓴다 — **문항을 md에 맞췄다.**

URL 슬러그는 여전히 `aurora-serverless-v2.html`이고 페이지가 정상 응답하므로 **출처 URL은
그대로 뒀다**(3개 전부 불변 확인). 출처 `title`만 `Aurora serverless (공식)`로 맞췄다.

한국어 조사는 안전하다 — `투`와 `스`가 모두 열린 음절이라 `를/는/가/로/의`가 그대로 유효하다.

## 공통 체크

- [x] `saa-review/*` 브랜치에서 작업 (`saa-review/aurora-naming` — SAA 콘텐츠 freeze 규약)
- [x] **Test-First**: `_rules`에 항목을 먼저 넣고 RED(`+46 -1`, 실패 1건) 확인 후 본문 치환
- [x] `correct` 인덱스 · 보기 개수 · 문항 id · `verified` · 출처 URL — **전부 무변경**(기계 대조)
- [x] `content_index`의 `questionCount` 무변경
- [x] 원문 바이트 치환 — CRLF 보존·bare LF 0 실측, `sources` 1줄 compact 서식 보존
- [ ] 5문항 문구 확인 (**사람**)
- [ ] 라이브 노출 문구 변경 승인 (**사람**)

## 변경 위치 — 5문항 / 23필드

치환은 `Aurora Serverless v2` → `Aurora serverless` 단일 규칙이다. 23건 전부 `Aurora` 접두
형태였고 standalone `Serverless v2`는 없었다.

- [ ] `saa-t3-5-q8` — 3필드: `skill` · `explanation` · `options[0]`(★정답)
  - `skill`: `Aurora Serverless v2 적합 워크로드` → `Aurora serverless 적합 워크로드`
- [ ] `saa-t4-3-q1` — 4필드: `explanation` · `options[1]`(★정답) · `wrongExplanations.3` ·
      `sources[0].title`
- [ ] `saa-t4-3-q8` — 7필드: `stem` · `skill` · `explanation` · `wrongExplanations.0/1/3` ·
      `sources[0].title`
  - `skill`: `Aurora Serverless v2 과금 단위` → `Aurora serverless 과금 단위`
- [ ] `saa-t4-3-q13` — 2필드: `options[0]`(오답 보기) · `wrongExplanations.0`
- [ ] `saa-t4-3-q15` — 7필드: `stem` · `skill` · `explanation` · `options[1]` · `options[3]` ·
      `wrongExplanations.1` · `sources[0].title`
  - `skill`: `Aurora Serverless v2 스케일 단위 특성` → `Aurora serverless 스케일 단위 특성`

## 라이브 영향

**5문항 전부 라이브 변경이다** — `saa-t3-5`·`saa-t4-3`은 둘 다 15/15 flip 상태다. 다만
바뀌는 것은 **제품 명칭 표기뿐**이고 정답 인덱스·보기 구성·사실 주장은 그대로이므로 **채점
결과는 바뀌지 않는다.** 학습문서(`*.md`)는 건드리지 않았다(이미 `Aurora serverless`를 쓴다).

## ⚠️ 별건으로 남긴 것 — 오디오 대본의 `v2`

| 문서 | `script.json` 내 `Aurora Serverless v2` | 노출 |
|---|---|---|
| `saa-t3-5` | **8건** | `content_index`에 `audioApproved: true` · `audioSha8: b0a8e6a1` → **라이브 음성이 "v2"라고 말한다** |
| `saa-t4-3` | 23건 | `audioApproved` 없음 → 노출 0 (`audio_meta.json`도 없음) |

`saa-t3-5` 대본을 고치면 **재합성 → R2 재발행(`tool/publish_audio.py`) → `reviewStatus`가
`needs_human_review`로 리셋되므로 사람 재승인**이 따라온다. 2026-07 감사에서 겪은 것과 같은
계열(학습문서 정정이 오디오 대본에 미전파)이다. 이번 PR 범위 밖으로 남긴다.

오디오 대본은 문항 JSON이 아니라 `assets/audio/**/script.json`이므로
`saa_question_propagation_test.dart`가 **검사하지 않는다.** 대본용 전파 가드를 만들지는
별도 판단이 필요하다(재합성 비용이 걸려 있어 가드만 넣으면 RED로 남는다).

## 게이트 실측

| 게이트 | 결과 |
|---|---|
| `flutter test` | **1,289 그린** (exit 0). 분기 base `c231932` 1,288 + 신규 규칙 1 |
| `flutter analyze` | **No issues found!** (0건) |
| `node tool/saa_prescreen.mjs build` | 24 Task **구조·정합성 플래그 0건** |
| 신규 규칙 RED 확인 | 치환 **전** `+46 -1` — 실패 1건의 히트가 0단계 실측 5문항과 일치 |
