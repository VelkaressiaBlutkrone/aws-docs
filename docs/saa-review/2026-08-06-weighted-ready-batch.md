# SAA-C03 weighted-ready 사람 검수 batch — 2026-08-06

> 목적: SAA-C03 통합/약점 모의고사 공개 게이트를 채우기 위한 다음 사람 검수 단위.
> AI는 읽기 전용 후보 선정만 수행했다. `verified:true` flip과 최종 정답 판정은 사람만 한다.
> 상세 체크시트: [2026-08-06-weighted-ready-review-sheet.md](2026-08-06-weighted-ready-review-sheet.md)

## 현재 공개 게이트

공식 도메인 비중을 앱의 65문항 연습 세트에 적용한 필요 수량:

| Domain | 필요 | 현재 verified | 부족 |
|---|---:|---:|---:|
| D1 보안 | 19 | 0 | 19 |
| D2 복원력 | 17 | 15 | 2 |
| D3 고성능 | 16 | 45 | 0 |
| D4 비용 | 13 | 30 | 0 |

기존 flip 도구는 Task 단위(15문항)다. 따라서 최소 공개 목표를 실무적으로 채우려면
D1 2개 Task + D2 1개 Task를 검수하고 Task 단위로 flip하는 것이 가장 단순하다.

## 추천 batch

| 순서 | Task | 이유 | advisory 확인 |
|---:|---|---|---|
| 1 | `saa-t1-1` IAM — 자격증명·권한·페더레이션 | D1에서 가장 낮은 리스크. pass 14, review 1, 구조 플래그 0 | `q13` STS 리전/글로벌 표현 확인 |
| 2 | `saa-t1-4` 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager | D1 중 낮은 리스크이면서 공식 Task 1.2 범위를 보강. pass 12, review 3, 구조 플래그 0 | `q4`, `q10`, `q12` 출처/표현 확인 |
| 3 | `saa-t2-5` DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active | D2 추가 2문항 부족을 Task 단위로 해소. pass 14, review 1, 구조 플래그 0 | `q8` Aurora Global DB 승격 수치 표현 확인 |

이 batch가 모두 통과하면 D1 30/19, D2 30/17, D3 45/16, D4 30/13이 되어 SAA-C03 weighted capacity 게이트를 통과한다.

## 대체 후보

| 후보 | 쓸 때 | advisory 확인 |
|---|---|---|
| `saa-t1-2` | D1에서 Task 1.1 다중 계정/IAM Identity Center를 먼저 강화하고 싶을 때 | `q3`, `q13`, `q14` |
| `saa-t2-3` | D2에서 DR보다 ELB/Auto Scaling을 먼저 강화하고 싶을 때 | `q5`, `q6` |

`saa-t1-5`는 D1 공식 Task 1.3 범위라 중요하지만 review 11건으로 이번 공개 최소 batch에는 넣지 않는다. 공개 후 D1 품질 균형 보강 batch로 따로 잡는 편이 낫다.

## 검수 절차

1. 구조 prescreen 재생성:
   `cd flutter_app && node tool/saa_prescreen.mjs build`
2. HTML 뷰어 재생성:
   `cd flutter_app && node tool/saa_review.mjs build`
3. `flutter_app/build/saa_review/index.html`을 열고 추천 batch의 모든 문항을 `docs/saa-review/review-rubric.md` C1~C6로 검수한다.
4. advisory JSON을 나란히 본다:
   `docs/saa-review/prescreen/saa-t1-1.json`,
   `docs/saa-review/prescreen/saa-t1-4.json`,
   `docs/saa-review/prescreen/saa-t2-5.json`.
5. 사람 검수자가 전 문항 pass로 판단한 Task만 flip한다:
   `cd flutter_app && node tool/saa_review.mjs flip <taskId>`

추천 flip 순서:

```powershell
cd flutter_app
node tool/saa_review.mjs flip saa-t1-1
node tool/saa_review.mjs flip saa-t1-4
node tool/saa_review.mjs flip saa-t2-5
```

각 flip은 해당 `.questions.json`의 verified 전환, `content_index.dart` questionCount 동기화, `saa_questions_test`/`content_index_test` 실행을 수행한다. flip 후에는 사람이 직접 커밋한다.
