# Aurora Serverless v2 명칭 정리 — 완료 (PR #166, 머지 전)

- PR: https://github.com/VelkaressiaBlutkrone/aws-docs/pull/166 (base `develop`, head `saa-review/aurora-naming`)
- 커밋: `05980fd` · 분기 base `c231932` (= `origin/develop`, PR #165 머지 직후)
- 세션: trusting-turing-2955d7 (PR #165와 같은 세션. 사용자가 "여기서 진행" 선택)
- 검수지: `docs/saa-review/2026-10-20-aurora-naming-review-sheet.md`
- 선행: [saa-propagation-done.md](saa-propagation-done.md)

## 결과

`Aurora Serverless v2` → `Aurora serverless`, **5문항 23필드** (전부 `verified:true` = 라이브).
`correct`·보기 개수·문항 id·`verified`·출처 URL·`questionCount` 전부 무변경.

| 게이트 | 결과 |
|---|---|
| `flutter test` | **1,289 그린** (base `c231932` 1,288 + 신규 규칙 1) |
| `flutter analyze` | 0건 |
| `saa_prescreen build` | 24 Task 플래그 0건 |
| 신규 규칙 RED | 치환 전 `+46 -1`, 히트가 실측 5문항과 일치 |

## 다른 세션이 알아야 할 것

1. **`skill` 라벨은 사용자 데이터 적재 키가 아니다 — PR #165에 쓴 "고아가 된다"는 틀렸다.**
   `WrongSkill.skill` 은 "stale 문항에도 개념 보존"을 위한 **비정규화 스냅샷**이다
   (`lib/models/attempt_record.dart`). 로컬 적재 키는 `awsdocs.history.v1`
   (`history_store.dart:17`), 클라우드 동기 키는 `certId|examId|date`
   (`sync_merge.dart:9`). `skill` 소비처 5곳은 전부 표시·Task별 dedup이고 딥링크는
   `section` 을 쓴다. **문항의 `skill` 을 고쳐도 데이터는 안전하다** — 남는 영향은
   리포트가 문자열로 dedup하므로 옛/새 라벨이 두 줄로 보일 수 있다는 것뿐이다.
   앞으로 `skill` 수정을 "데이터 호환" 이유로 미루지 말 것.
2. **공식 명칭은 "Aurora serverless"(소문자 s)다.** `aurora-serverless-v2.html` 의 현재
   제목이 "Using Aurora serverless"이고 본문에 `v2` 가 없다. **URL 슬러그는 그대로
   `aurora-serverless-v2.html`** 이고 정상 응답하므로 출처 URL은 바꾸지 말 것.
3. **md 가드의 `isTrue` 요구 문구를 보면 표기 정본을 알 수 있다.** `saa_t2_t4` G-3.3-13이
   `contains('Aurora serverless')` 를 `isTrue` 로 요구하므로 md가 쓰는 소문자 표기가
   정본이다. 문항을 md에 맞추면 두 가드가 동시에 만족된다.
4. **한국어 조사 함정 없음:** `투`(v2)와 `스`(serverless) 모두 열린 음절이라
   `를/는/가/로/의` 가 그대로 유효했다. 다른 명칭 치환에서는 조사를 반드시 확인할 것.

## ⛔ 보류 — PR #166은 머지하지 말 것

**사용자가 이번 배치의 릴리스를 보류했다(2026-10-20).** PR #166은 **열린 상태로 그대로 두고
보류가 해제될 때까지 대기**하라는 사용자 지시가 있다. CI는 1/1 통과·`MERGEABLE/CLEAN`이고
`origin/develop`에는 들어가지 않았으므로 **라이브 영향 0**이다.

- 다른 세션도 **머지하지 말 것.** 재개하려면 사용자 지시가 필요하다.
- 재개 시 남은 사람 작업: 5문항 문구 확인(라이브 노출 변경) → 머지.
- `05980fd`는 `saa-review/aurora-naming` 브랜치에만 있다. 되돌릴 필요가 생기면 PR을 닫으면
  되고, 커밋을 다시 쓸 필요는 없다.

## 별건으로 남긴 것 — 오디오 대본의 `v2`

| 문서 | `script.json` 내 `Aurora Serverless v2` | 노출 |
|---|---|---|
| `saa-t3-5` | **8건** | `content_index` `audioApproved: true` · `audioSha8: b0a8e6a1` → **라이브 음성이 "v2"라고 말한다** |
| `saa-t4-3` | 23건 | `audioApproved` 없음 → 노출 0 (`audio_meta.json` 없음) |

고치면 **재합성 → `tool/publish_audio.py` R2 재발행 → `reviewStatus` 가
`needs_human_review` 로 리셋되므로 사람 재승인**이 따라온다(메모리 `audio-section-timestamps-shipped`
의 함정과 동일). 2026-07 감사와 같은 계열이다.

오디오 대본은 `assets/audio/**/script.json` 이라 `saa_question_propagation_test.dart` 가
**검사하지 않는다.** 대본용 전파 가드는 지금 넣으면 재합성 전까지 RED로 남으므로 별도 판단이
필요하다 — **재합성과 같은 PR에서 함께 넣는 것이 맞다.**
