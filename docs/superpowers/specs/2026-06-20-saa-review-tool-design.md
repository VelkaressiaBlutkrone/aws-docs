# SAA 검수 전용 뷰 (saa_review 도구) — 설계 spec

- 날짜: 2026-06-20
- 상태: 설계 승인 → 구현 plan 입력 대기 (writing-plans)
- 출처: [WORKLIST.md](../../../WORKLIST.md) §B-① · [B 진행계획 spec](2026-06-19-b-tasks-progress-plan-design.md) §5
- 영향: `flutter_app/tool/saa_review.mjs`(신규) · `assets/content/saa/*.questions.json`(flip 시 verified) · `lib/data/content_index.dart`(flip 시 questionCount)

## 1. 배경 / 목표

SAA-C03 360문항(24 Task × 15, 전부 `verified:false` 드래프트)을 사람이 검수해 `verified:true`로 flip해야 한다. 현재 `content_index`의 SAA questionCount는 전부 0(verified 게이트로 비노출). 검수는 stem·정답·해설·오답해설·출처를 읽고 품질을 판단하는 작업이라 읽기 효율이 핵심이다.

**목표:** node 도구로 **읽기 HTML 뷰어 + flip CLI**를 만들어 360문항 검수를 효율화한다. **철칙: AI flip 금지(verified=사람 검수만), 품질 판단은 사용자.** 도구는 읽기 보조와 flip 기계화만 담당한다.

## 2. 결정 사항 (확정)

| 항목 | 결정 |
|---|---|
| 형태 | 앱 밖 node 도구(`tool/saa_review.mjs`, `verify_splash.mjs` 선례) |
| flip 단위 | Task 단위(15문항 묶음 — 밀도 가드 ≥15와 정합) |
| 진행 추적 | **flip이 곧 마킹**(verified 상태 = 진행). 체크·메모 없음 |
| 품질 판단 | 사용자. AI flip 금지 |
| 문항 수정 | 검수자가 JSON 직접 편집(도구는 수정 안 함) |

## 3. 구성 — `flutter_app/tool/saa_review.mjs`

단일 node 스크립트(ESM, `.mjs`), 서브커맨드 2개:
- `node tool/saa_review.mjs build` → `build/saa_review/index.html` 정적 생성
- `node tool/saa_review.mjs flip <taskId>` → 해당 Task `verified:true` + content_index 동기화 + 테스트

## 4. HTML 뷰어 (`build`)

- 입력: `assets/content/saa/*.questions.json` (24파일)
- 출력: 단일 HTML. **도메인 → Task → 문항 카드** 구조. 카드 표시 순서:
  - 메타 줄: `id · skill · difficulty · verified 배지`
  - `stem` → `options`(정답 인덱스 **초록 강조**) → `explanation`(정답 해설) → `wrongExplanations`(오답 인덱스별) → `sources`(클릭 가능 링크)
  - 기계적 플래그 배지(있을 때만)
- 순수 읽기 — 체크/메모/상태 저장 없음(flip이 곧 마킹).

## 5. 기계적 플래그 (순수 함수 — 구조 신호만, 품질 판단 아님)

문항/Task의 **기계적으로 잡히는** 신호만. 정답·해설·distractor 품질은 검수자 몫.
- `options` ≠ 4개
- `correct` ∉ [0, 3]
- `wrongExplanations` 키 집합 ≠ {0,1,2,3}\{correct} (누락/잉여)
- `sources` 비었거나 `url`이 http(s)로 시작하지 않음
- (Task 단위) **정답 인덱스 쏠림**: 15문항 중 한 인덱스가 ≥ 60% (예: A에 9개 이상)

## 6. flip CLI (`flip <taskId>`)

1. `assets/content/saa/<taskId>.questions.json`의 전 문항 `verified: false → true`
2. `lib/data/content_index.dart`의 그 taskId `ContentEntry`의 `questionCount: 0 → 15`(실제 verified 수) — **taskId 앵커 정규식**(`taskId: '<taskId>'` 블록 안의 `questionCount: \d+`만 교체)
3. `flutter test test/saa_questions_test.dart` 실행, 통과 확인(실패 시 비정상 종료)
4. **안전장치**: flip 전 그 Task에 심각 구조 플래그(`options`≠4 · `correct` 범위 밖 · `wrongExplanations` 키 불일치)가 있으면 경고하고 중단(`--force`로 강행). 쏠림 플래그는 경고만(중단 안 함).

## 7. 테스트 (TDD — 절대조건 2)

- **기계적 플래그 함수**: node 내장 `node:test`로 단위 테스트(정상/각 위반 fixture).
- **flip 로직**: 임시 fixture JSON·content_index 조각에 적용 → `verified`·`questionCount` 갱신 결과 검증(실제 에셋 미변경).
- **회귀**: 기존 `test/saa_questions_test.dart`(Dart 구조·밀도 가드) 유지. flip 후에도 통과해야 한다(verified 무관 가드).

## 8. 비범위 (YAGNI)

- 체크·메모·진행률 UI(flip이 마킹) · 문항 자동 수정(검수자가 JSON 편집) · AI 품질 판단/flip.
- CLF 등 다른 cert 검수(이 도구는 SAA 전용; 일반화는 필요 시 추후).
- 검수 결과 export/통계.

## 9. 다음 단계
writing-plans 스킬로 구현 plan(뷰어 build → 기계적 플래그 함수 → flip CLI 순, 각 TDD)을 작성한다.
