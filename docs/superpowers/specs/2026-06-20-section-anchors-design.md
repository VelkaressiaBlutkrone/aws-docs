# 섹션 앵커 점진 확대 — 설계 spec

- 날짜: 2026-06-20
- 상태: 설계 승인 → 구현 plan 입력 대기. **구현(18 Task 편집)은 다음 세션**(이 세션은 spec·plan만)
- 출처: [WORKLIST.md](../../../WORKLIST.md) §B-③ · [B 진행계획 spec](2026-06-19-b-tasks-progress-plan-design.md) §6
- 영향: `assets/content/clf/t*.md`(앵커) · `assets/content/clf/t*.questions.json`(section) · `test/`(신규 검증 테스트)

## 1. 배경 / 목표

C-중량 개념→섹션 딥링크 인프라(`markdown_parser`의 `{#id}` 파싱·`MdHeading.anchor`, `anchor_scroll`, 문항 `section` 필드, `study_doc_page` targetAnchor 스크롤)는 Phase 1에서 구축·main 릴리스됨. 현재 `clf-t1-1`만 섹션 앵커 5개 + 문항 section 6개 시드. 나머지 문서·문항은 graceful 폴백(앵커 없으면 문서 최상단).

**목표:** CLF 나머지 학습문서에 `{#slug}` 앵커 + 문항 `section`을 연결해 "개념→바로 그 문단" 정밀 딥링크를 점진 확대. graceful 폴백이 있어 비차단·점진.

## 2. 결정 사항 (확정)

| 항목 | 결정 |
|---|---|
| 범위 | **CLF 18 Task**(t1-1 제외, verified 문항 있음). SAA 제외(검수 후 별도) |
| slug 명명 | 사람 — 의미 기반 영문 kebab(자동 생성 X) |
| 문항 매핑 | 사람 — 문항이 다루는 섹션 slug |
| 품질 가드 | **Dart 테스트**(문항 section ↔ 학습문서 앵커 존재) |
| 구현 분리 | spec·plan = 이 세션, 실제 18 Task 편집 = 다음 세션 |

## 3. 패턴 정본 (clf-t1-1)

- 앵커: 헤딩 끝에 `{#slug}` — `### 클라우드의 핵심 이점 (★ 시험 핵심) {#core-benefits}`
- 문항: `"section": "core-benefits"` — 그 문항이 다루는 섹션 slug
- slug는 헤딩 텍스트와 별개의 안정 식별자(`core-benefits`·`ha-elasticity`·`global-infra`·`pitfalls`·`core-concepts`)

## 4. 방식 (Task당, 전부 사람 의미 판단)

1. 학습문서 헤딩에 의미 `{#slug}` 부여(소문자 kebab, 헤딩 텍스트 바뀌어도 유지 = 문항 계약)
2. 문항 `section` = 그 문항이 다루는 섹션 slug(없으면 미연결 = 폴백 허용)
3. Dart 검증 테스트 통과 확인

## 5. 품질 가드 (신규 Dart 테스트)

- 각 CLF Task의 각 문항 `section`(있으면)이 그 Task 학습문서의 실제 `{#id}` 앵커 집합에 **존재하는지** 검증.
- 앵커 추출은 `markdown_parser`의 `{#id}` 파싱(`MdHeading.anchor`) 재사용.
- 위반(앵커 없음) = 테스트 실패 → 오타·유실 포착.
- `section` 없는 문항은 통과(점진 — 미연결 허용).

## 6. slug 규칙

- 소문자 영문 kebab(`a-z0-9-`), 의미 기반(헤딩 텍스트 압축).
- 안정성: 헤딩 텍스트가 바뀌어도 slug 유지(문항 `section` 계약 보호).
- 한 문서 내 유일.

## 7. 비범위 (YAGNI)

- SAA 앵커(B-① 검수·flip 후 별도) · 자동 slug 생성(의미라 사람) · node 도구(Dart 테스트로 충분) · 전 Task 일괄(점진).

## 8. 테스트

- 신규 Dart 검증 테스트(문항 section ↔ 학습문서 앵커 존재).
- 기존 `all_content_parse_test`(전 md 파싱 회귀) 유지.

## 9. 다음 단계

writing-plans로 plan(검증 테스트 코드 + Task별 편집 절차 + Task 순서)을 작성한다. **실제 18 Task 앵커·매핑 편집은 다음 세션**(신선한 컨텍스트)에서 그 plan으로 진행한다.
