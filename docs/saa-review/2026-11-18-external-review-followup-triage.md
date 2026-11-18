# 외부 리뷰 후속 명세서 — 항목별 판정 (2026-11-18)

> 원문: `2026-11-18-external-review-followup-spec.md`(§12에서 잘린 채로 들어왔다).
> 판정 기준: 명세가 요구하는 것이 **레포에 이미 있는지**를 2026-11-18에 직접 세어 정했다. 보고는 데이터이고, 판정은 실측으로 한다.
> 판정 값: **채택**(새 작업) · **부분 채택**(있는 것을 넓힘) · **이미 있음**(작업 없음, 근거 표기) · **보류**(설계·승인 필요) · **기각**(이 레포에 맞지 않음).

## 요약

- 명세의 P0 여섯 항목 가운데 넷은 **이미 상당 부분 있다**. 실제로 비어 있는 곳은 좁고 구체적이다.
- 데이터 자체는 깨끗하다 — 2,288문항 전수 스캔에서 `correct` 범위 밖·보기 수 ≠ 4·빈 보기·빈 지문/해설·**ID 중복 모두 0건**(Python 전수 스캔, 2026-11-18).
- 진짜 구멍은 **가드의 범위**다: CLF 구조 가드가 19 Task 중 **7개만** 보고, 문항 모델은 `correct`가 없으면 **조용히 −1**로 읽는다.

## 항목별 판정

| 명세 | 판정 | 실측 근거 | 할 일 |
|---|---|---|---|
| §2 상태 정정 | 이미 있음 | 수치가 로드맵 §1-3과 일치한다(8종 · 2,288 · 142) | 없음 |
| §3-1 가이드 버전·동기화 | **부분 채택** | 가이드 동기화 테스트는 **5종**(CLF·SOA·AIF·SCS·AIP)에만 있고 **SAA·DEA·MLA가 없다**. `guideVersion` 필드는 **2종**(AIF·SOA)뿐 | ✅ `guide_sync_saa_dea_mla_test.dart`(2026-11-18). 공식 ko 도메인 페이지 12개(전부 `200 r=0`)와 바이트 대조: SAA 189항목 중 4곳 · DEA 120항목 중 8곳 · MLA 133항목 0곳이 달랐고 교체 후 셋 다 0. SAA 4곳은 2026-11-17 검증 Y20 이 이미 찾은 것과 같다(`Amazon QuickSuite` 는 공식에 없는 이름). ⚠️ DEA 문항 `skill` 태그는 옛 문구를 인용하는 것이 있지만 **원래부터 256개 중 77개가 가이드 문구와 다른 줄인 라벨**이라 공개 문항은 고치지 않았다. 버전 필드는 12개 JSON 중 2개뿐인 관례라 추가하지 않고 가드 주석에 대조 날짜를 남겼다 |
| §3-2 P1 오류 재검수 | 이미 있음 | 든 여섯 유형은 2026-11-06~07 2단 검토의 P1·P2에서 **전부 고치고 전수 가드로 고정했다**(Savings Plans 66/72 · `sp-ris` 권장 문구 · Magnetic 부팅 가능 · Gateway/Interface 엔드포인트 · 범위 외 정답 문항 등 — `clf_p1_review_fix_test`·`saa_p1_review_fix_test`·`clf_out_of_scope_answer_test`). Savings Plans 네 유형도 이미 다룬다(Database 14건 · SageMaker AI 18건) | 없음. 「재검수」는 2026-11-17 전 콘텐츠 검증 2단계가 마지막이다 |
| §3-3 문항 검수 메타데이터 | ✅ **Task 단위 원장으로 해소**(2026-11-18, 사용자 선택) — `docs/review-ledger/<cert>.json`(Task별 최초 공개일·공개 문항 수, 142 Task 를 git 이력에서 복원) + `review.mjs flip` 이 기록 + `ledger <cert>` 보고 명령 + `review_ledger_test.dart`. 문항 JSON 은 바꾸지 않았다. 아래는 판정 당시 기록이다 → **보류**(스키마 변경) | 누가·언제 flip했는지는 `review.mjs flip` 커밋 이력에 이미 남는다. 문항마다 `review` 객체를 넣으면 2,288문항 전체가 바뀌는 diff가 되고, 「AI는 `verified`를 쓰지 않는다」는 규율과 같은 무게의 사람 서명 필드가 하나 더 생긴다 | 하려면 별도 설계·승인(명세 §11-8과 같은 판단). 대안: flip 커밋을 모아 보여 주는 리포트 |
| §3-3 검수 기준 문서 | 이미 있음 | `docs/saa-review/review-rubric.md` | 없음 |
| §4-1 문항 JSON 검증 | **부분 채택** | 8종 모두 `*_questions_test.dart`에 정답 범위·ID 중복 단정이 있다. 그러나 **CLF는 `clf_supplement_questions_test`가 7 Task만** 본다(19 중). 그리고 `lib/models/question.dart:51`이 `correct` 누락을 **−1로 조용히 읽는다** | ① ✅ `question_structure_invariant_test.dart`(2026-11-18) — 디렉터리 유도, 드래프트 포함 ② 모델의 −1 기본값은 **그대로 둔다**: 가드가 디스크의 전 문항에서 누락을 막으므로 런타임 동작을 바꿀 이유가 없다 |
| §4-2 문서↔문항 일관성 | **부분 채택** | 문항 `section` ↔ 학습문서 `{#앵커}` 실재 가드가 **CLF만**(`section_anchor_link_test.dart:12`). 사실 전파는 SAA·SOA·DEA·MLA·AIF·SCS 전파 가드가 본다 | ✅ 등재 전 자격증으로 확장(2026-11-18). ⚠️ **SAA 360·SOA 300문항은 `section`이 0개**라 해설 → 학습문서 절 딥링크가 없다 — 별 콘텐츠 작업 후보 |
| §4-3 인덱스·자산 일관성 | 이미 있음 | `content_index_test`의 「등재 ↔ `pubspec` 선언」 가드(2026-11-14 라이브 404 뒤 신설) · `questionCount == verified` 불변식 · `all_content_parse_test` | 없음 |
| §5-1 콘텐츠 현황 표시 | 보류(UX) | 상세 화면은 「준비 중」 라벨·도메인 진행 라벨을 이미 쓴다. 가이드 버전·검수일 표시는 필드가 없어 §3-1과 묶인다 | 디자인 결정 필요 |
| §5-2 문서↔문항 이동 | 부분 있음 | 해설·오답노트 → 학습문서 섹션 딥링크(`?at=`)가 있다 | 학습문서 → 관련 문항 방향은 별도 설계 |
| §5-3 시험 화면 | 대부분 있음 | 시계 · 미응답 표시 · 플래그 · 상시 제출과 점프(2026-09-22 UX-1·UX-2) | 결과 화면의 **도메인별 점수는 없다**(Task별은 약점 리포트에 있다) — 채택 후보 |
| §5-4 오답 분석 표본 | 부분 있음 | 약점 리포트가 Task마다 「응시 a/b문항」을 함께 보인다 | 「표본이 적으면 잠정」 표시는 없다 — 채택 후보(작다) |
| §6-1 CI 확장 | 이미 있음 | `ci.yml` = node 도구 → analyze → test → 릴리스 dart-define 테스트. 콘텐츠 검증은 `flutter test` 안의 가드다 | §4-1의 새 가드가 들어오면 자동으로 CI에 든다 |
| §6-2 배포 SHA·CHANGELOG | **채택** | `pages.yml`에 커밋 SHA 기록이 없고 CHANGELOG도 없다. 라이브 판정은 지금 자산 md5로 한다 | ✅ `pages.yml`이 `build/web/version.json`(commit · builtAt · runId)을 쓴다 + `deploy_version_stamp_test.dart`(2026-11-18). 앱 화면 표시는 하지 않았다(디자인 결정 필요). CHANGELOG 는 만들지 않았다 — 릴리스 PR(develop → main) 본문이 그 역할을 한다 |
| §7 Android 연계 | 이미 있음 | 로드맵 §3과 같은 내용이다 | 없음 |
| §8 장기 | 이미 있음(일부) | 서비스 종료 추적은 `AWS Lifecycle Changes` 세 목록 + 전수 가드로 하고 있다. 프레젠테이션은 로드맵 §5-④와 같다 | 연내 범위 밖 |

## 판정에 쓴 측정

- 문항 전수 구조 스캔: 2,288문항, 위반 0건, ID 중복 0건.
- 가드 범위: `grep` — 8종 `*_questions_test.dart`에 범위·중복 단정 각 1건 이상, CLF 보강 가드 `taskIds` 7개.
- 가이드: `grep -l '"guideVersion"' assets/exam_guides/*.json` → AIF·SOA. `ls test | grep guide` → 5개.
- 배포: `pages.yml`에 SHA·version 줄 0건, 레포 루트에 CHANGELOG 없음.
