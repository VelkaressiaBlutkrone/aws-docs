# SAA-C03 weighted-ready 사람 검수 batch — 2026-08-06

> 목적: SAA-C03 통합/약점 모의고사 공개 게이트를 채우기 위한 다음 사람 검수 단위.
> AI는 읽기 전용 후보 선정만 수행했다. `verified:true` flip과 최종 정답 판정은 사람만 한다.
> 상세 체크시트: [2026-08-06-weighted-ready-review-sheet.md](2026-08-06-weighted-ready-review-sheet.md)

## 현재 공개 게이트

게이트는 **도메인별 weighted capacity**다(라이브 함수 `certExamHasWeightedCapacity`). 정의와 함수 근거는 [review-rubric.md](review-rubric.md) §1 — 옛 "전 도메인 일괄 flip" 서술은 2026-10-20에 개정됐다.

공식 도메인 비중(30/26/24/20%)을 앱의 65문항 연습 세트에 적용한 필요 수량. 산출은 `allocateByWeight`로 **floor 후 최대 잉여법**이다: 65×비중을 내림하면 19·16·15·13(합 63)이고, 남는 2문항이 소수부가 큰 **D2(.9)·D3(.6)** 에 +1씩 붙어 아래 값이 된다(동률은 선언 순서). 비중이 바뀌어도 이 규칙으로 재현된다.

| Domain | 필요 | 현재 verified | 부족 |
|---|---:|---:|---:|
| D1 보안 | 19 | 0 | 19 |
| D2 복원력 | 17 | 15 | 2 |
| D3 고성능 | 16 | 45 | 0 |
| D4 비용 | 13 | 30 | 0 |

_현재 verified는 2026-10-20 실측(`content_index.dart` questionCount == 각 `.questions.json`의 `verified:true` 수, 합 90)._

기존 flip 도구는 Task 단위(15문항)다. 따라서 최소 공개 목표를 실무적으로 채우려면
D1 2개 Task + D2 1개 Task를 검수하고 Task 단위로 flip하는 것이 가장 단순하다.

## 추천 batch

| 순서 | Task | 이유 | advisory 확인 |
|---:|---|---|---|
| 1 | `saa-t1-1` IAM — 자격증명·권한·페더레이션 | D1에서 가장 낮은 리스크. pass 14, review 1, 구조 플래그 0 | `q13` STS 리전/글로벌 표현 확인 |
| 2 | `saa-t1-4` 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager | D1 중 낮은 리스크이면서 공식 Task 1.2 범위를 보강. pass 12, review 3, 구조 플래그 0 | `q4`, `q10`, `q12` 출처/표현 확인 |
| 3 | `saa-t2-5` DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active | D2 추가 2문항 부족을 Task 단위로 해소. pass 14, review 1, 구조 플래그 0 | `q8` Aurora Global DB 승격 수치 표현 확인 |

이 batch가 모두 통과하면 D1 30/19, D2 30/17, D3 45/16, D4 30/13이 되어 SAA-C03 weighted capacity 게이트를 통과한다.

> ⚠️ **리스크 — 공개 시점 D1은 공식 Task 1.3(데이터 보안 제어)이 0문항이다.** 이 batch의 D1 두 Task는 `saa-t1-1`(공식 Task 1.1 범위)·`saa-t1-4`(Task 1.2 범위)이고, Task 1.3에 해당하는 `saa-t1-5`(KMS·CloudHSM·ACM·백업·거버넌스)는 verified 0으로 남는다. 수량 게이트는 통과하지만 **D1 노출 문항이 공식 Task 1.3을 전혀 다루지 않는 상태**로 열린다는 뜻이다. 따라서 `saa-t1-5`를 **공개 직후 1순위 보강 batch로 확정**한다(아래 대체 후보와 달리 선택 사항이 아니다). 품질 균형 기준을 "공식 Task Statement마다 verified 1개 이상"으로 올릴지는 별도 결정 사항이다.
>
> 2026-10-20 검증에서 이 batch의 advisory 5문항은 **정답 변경 0건, 해설·오답근거 `fix` 5건**으로 판정됐다(`q13`·`q4`·`q10`·`q12`·`q8`). 근거와 수정 문구는 체크시트에 기입돼 있다.

## 대체 후보

| 후보 | 쓸 때 | advisory 확인 |
|---|---|---|
| `saa-t1-2` | D1에서 Task 1.1 다중 계정/IAM Identity Center를 먼저 강화하고 싶을 때 | `q3`, `q13`, `q14` |
| `saa-t2-3` | D2에서 DR보다 ELB/Auto Scaling을 먼저 강화하고 싶을 때 | `q5`, `q6` |

`saa-t1-5`는 D1 공식 Task 1.3 범위라 중요하지만 review 11건으로 이번 공개 최소 batch에는 넣지 않는다. 공개 후 D1 품질 균형 보강 batch로 따로 잡는다 — 위 리스크 항목에서 **1순위**로 확정했다.

## 검수 절차

0. 브랜치·freeze 준비(루브릭 §0):
   `git checkout -b saa-review/weighted-ready` (SAA 콘텐츠 변경은 `saa-review*` 브랜치에서만)
   freeze를 발효시킬 경우 `git config core.hooksPath .githooks`를 **먼저** 1회 설정해야 `.githooks/pre-commit` 가드가 걸린다(2026-10-20 실측: 이 레포 로컬은 `core.hooksPath` 미설정·`.saa-frozen` 부재 = dormant).
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
