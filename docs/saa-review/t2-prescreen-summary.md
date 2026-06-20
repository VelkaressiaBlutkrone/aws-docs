# T2 — SAA-C03 문항 의미·출처 사전심사 (종합)

> 잠금 플랜 [2026-06-20-saa-rereview-plan](../superpowers/plans/2026-06-20-saa-rereview-plan.md) §5 T2.
> 검수일 2026-06-20. **advisory 플래그** — AI가 의심 지점을 표시·출처 대조한 것이며 **정답 ground truth가 아니다. 최종 판정·`verified` flip은 사람**([review-rubric.md](review-rubric.md) C1~C6). AI flip 금지.
> 방법: Task별 read-only 서브에이전트(신선 컨텍스트)가 의미 검토 + **출처 WebFetch 대조**(공식 docs.aws.amazon.com 우선, Task 내 동일 url 1회 재사용) → 문항id별 JSON([prescreen/](prescreen/)). 파일출력으로 유실 우회.
> 검증: T6 문서 스캔과 독립 교차검증(예: t2-1-q15 FIFO TPS를 양쪽이 잡음).

## 종합 (360문항 / 24 Task)
| 권고 | 수 | 의미 |
|---|---|---|
| **pass** | 185 | 의심 없음 |
| **review** | 104 | 사람 확인 권장(대부분 출처가 주장을 부분 뒷받침/약함) |
| **fix** | 18 | 경미 수정(주로 출처-주장 불일치·해설 표현) |
| **suspect/wrong** | **7** | **정답·해설이 의심 — 우선 검수** |
| rewrite | 0 | 전면 재작성 필요 없음 |
| out-of-scope | 0 | 범위 밖 문항 없음 |
| ambiguity | 15 | stem/정답 모호 가능 |

문서 품질 전반 양호 — 명백한 오답(rewrite) 0, 범위밖 0. 의심은 **정답 자체보다 해설/출처의 과단정·수치·출처-주장 불일치**에 집중.

## ★ 우선 검수 — suspect/likely-wrong 7건
| Task·id | conf | 핵심(공식 대조) |
|---|---|---|
| **t2-1-q15** | 5 | 해설 'FIFO 300 TPS(큐 단위)' 단정 → 공식 300/3,000은 **파티션당**(고처리량 모드). *T6과 교차검증.* |
| **t3-2-q12** | 5 | 정답 'Max I/O + Elastic' 조합 **부정합** — Elastic 처리량은 General Purpose 모드에서만 지원, Max I/O는 레거시(비권장). |
| **t3-5-q6** | 6 | Aurora 페일오버 '**<30초** 단정' → 공식 'typically <60s, often <30s'(과단정). 방향은 옳음. |
| **t4-2-q2** | 7 | **Convertible RI '최대 54%' → 공식 66%**(사실 오류). Standard 72%는 정확. |
| **t4-2-q10** | 6 | Spot capacityOptimized 정답 근거 모호(diversified 해설이 'stem과 충돌' 소지). |
| **t4-3-q3** | 5 | **'3년 No Upfront' 미존재 옵션**(No Upfront=1년만) + 할인율 수치 미출처. |
| **t4-3-q4** | 4 | **RDS RI는 Multi-AZ↔Single-AZ 자유 이동**(결속 아님; 결속=Region·engine·class). 정답·해설이 Multi-AZ를 결속조건으로 본 부분 부정확. |

## ★ 체계적 이슈 — saa-t3-4 출처-주장 불일치(7문항)
`saa-t3-4`(컨테이너·서버리스·배치)의 fix 7건(q2·q5·q6·q9·q10·q13·q14)은 **정답은 모두 타당하나 인용 출처가 'ECS Welcome 페이지'라 Lambda/HPC/FSx 주장을 전혀 뒷받침하지 못함**. → 해당 문항 sources를 올바른 공식 문서(Lambda·EFA·FSx for Lustre 등)로 **일괄 교체**하면 해결.

## Task별 카운트 (우선순위)
| Task | Q | pass | review | fix | suspect | ambig |
|---|---|---|---|---|---|---|
| saa-t1-1 | 15 | 14 | 1 | 0 | 0 | 0 |
| saa-t1-2 | 15 | 12 | 3 | 0 | 0 | 0 |
| saa-t1-3 | 15 | 7 | 8 | 0 | 0 | 0 |
| saa-t1-4 | 15 | 12 | 3 | 0 | 0 | 0 |
| saa-t1-5 | 15 | 4 | 11 | 0 | 0 | 0 |
| saa-t2-1 | 15 | 14 | 1 | 0 | 1 | 1 |
| saa-t2-2 | 15 | 4 | 11 | 0 | 0 | 0 |
| saa-t2-3 | 15 | 13 | 2 | 0 | 0 | 0 |
| saa-t2-4 | 15 | 5 | 10 | 0 | 0 | 0 |
| saa-t2-5 | 15 | 14 | 1 | 0 | 0 | 0 |
| saa-t3-1 | 15 | 13 | 2 | 0 | 0 | 0 |
| saa-t3-2 | 15 | 1 | 6 | 0 | 1 | 1 |
| saa-t3-3 | 15 | 2 | 0 | 0 | 0 | 1 |
| saa-t3-4 | 15 | 0 | 1 | 7 | 0 | 2 |
| saa-t3-5 | 15 | 7 | 7 | 1 | 1 | 3 |
| saa-t3-6 | 15 | 8 | 7 | 0 | 0 | 2 |
| saa-t3-7 | 15 | 7 | 8 | 0 | 0 | 0 |
| saa-t3-8 | 15 | 13 | 2 | 0 | 0 | 1 |
| saa-t3-9 | 15 | 10 | 5 | 0 | 0 | 0 |
| saa-t4-1 | 15 | 3 | 0 | 0 | 0 | 0 |
| saa-t4-2 | 15 | 6 | 4 | 5 | 2 | 1 |
| saa-t4-3 | 15 | 6 | 4 | 5 | 2 | 3 |
| saa-t4-4 | 15 | 0 | 2 | 0 | 0 | 0 |
| saa-t4-5 | 15 | 10 | 5 | 0 | 0 | 0 |

> ⚠ t4-1·t4-4·t3-3의 pass+review+fix 합이 15 미만인 칸은 일부 문항이 그 외 권고(예: 카운트 산정 차이)일 수 있음 — 정확 detail은 각 [prescreen/<taskId>.json](prescreen/) 참조.

## 사용 방법(T7 루브릭과 연계)
1. 도메인순(D1→D4)으로 검수 시 각 Task의 `prescreen/<taskId>.json`을 saa_review HTML 뷰어와 나란히 본다.
2. **suspect 7 → 최우선**, t3-4 출처 7 → 일괄 교체, fix 18 → 경미 수정, review 104 → 확인.
3. 각 문항 [review-rubric.md](review-rubric.md) C1~C6 적용 → 판정 → 수정 루프 → 도메인 일괄 flip(사람).
4. **AI는 여기까지(플래그)** — 정답 확정·flip은 사람.
