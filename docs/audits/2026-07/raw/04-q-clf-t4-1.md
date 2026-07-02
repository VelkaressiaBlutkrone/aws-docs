# ④ 문항 품질 감사 샤드 — 04-q-clf-t4-1 — 2026-07

## 요약
- **15문항 전수** 점검(정답 유일성·해설-정답 일치·wrongExplanations·앵커·태그·AWS 사실·스키마 7항목). **발견 5건**(H 0 · M 2 · L 3, 사실의심 Y 2건).
- 정답 유일성·해설-정답 일치 **15/15 통과**, wrongExplanations 키 정합(누락 0)·반박 논리 **15/15 통과**, 스키마 위생(id 유일·correct 0~3 범위·verified true·옵션 4개) **15/15 통과**, skill·difficulty 전 문항 채움·내용 정합.
- section 앵커: 13문항의 값(purchase-options·data-transfer·storage-pricing)이 t4-1.md `{#id}`에 **전부 실존**. q10·q12는 section 자체가 없음(규칙상 빈 값 통과 — 단 q10은 발견 03의 스코프 이슈와 결부).
- **DOC-CLF-305 전파 확인됨**: q2 해설·출처 제목이 Compute SP의 완전 유연성에 "최대 72%"를 결부(발견 01, 사실의심 Y — 공식 문서 실조회로 확정). **DOC-CLF-306(Glacier "수 분~수 시간" 일반화)은 문항·해설에 전파 없음**(복원 시간 수치를 언급하는 문항 없음).
- 참고(비발견): correct 인덱스가 0에 편중(12/15)이나, 노출 경로 4곳(quiz_page·review_page·exam_page·cert_exam_page) 전부 `randomOptionOrders` 런타임 선택지 셔플을 적용해 편향이 사용자에게 노출되지 않음을 코드로 확인.

## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t4-1-01 | t4-1.questions.json:clf-t4-1-q2 | explanation이 "Compute Savings Plans는 인스턴스 패밀리·크기·OS·테넌시·리전과 무관하게 … Fargate·Lambda … 유연합니다(최대 72% 절감)"로 **Compute SP에 72%를 결부** — 공식 Savings Plans 사용 설명서(plan-types, 2026-07-02 실조회)는 Compute SP "up to **66%**"(완전 유연), EC2 Instance SP "up to **72%**"(특정 패밀리·리전 고정)로 명시. sources[0] 제목의 "EC2·Fargate·Lambda 유연 적용(최대 72%)"도 동일 결합. **DOC-CLF-305의 문항 전파.** 정답 선택 자체(0=Savings Plans)는 유효 — 스템은 %를 주장하지 않고 유연성 서술은 Compute SP에 부합 | M | 높 | explanation의 "(최대 72% 절감)"을 삭제하거나 "Savings Plans 전체로는 최대 72%(단, 72%는 패밀리·리전 고정인 EC2 Instance SP 기준이고 Compute SP는 최대 66%)"로 정정 + sources[0] 제목 동일 정정. 문서(t4-1.md 표·시험 포인트)와 함께 일괄 수정(DOC-CLF-305) | A | Y (docs.aws.amazon.com/savingsplans plan-types: "Compute Savings Plans provide the most flexibility and prices that are up to 66% off", "EC2 Instance Savings Plans provide savings up to 72% … commitment to a specific instance family in a chosen AWS Region") |
| Q-CLF-t4-1-02 | t4-1.questions.json:clf-t4-1-q10 | 스템·해설이 프리 티어 3유형(12개월 무료·상시 무료·단기 평가판)을 **현행 보편 사실로 단정** — 문항이 인용한 출처 페이지(billing-free-tier.html) 자체가 현재 "This section **only applies to** … accounts **before July 15, 2025**"로 재편됐고(2026-07-02 실조회), 2025-07-15 이후 생성 계정은 크레딧 기반 신 프리 티어(free-tier.md)가 적용됨. 단 CLF-C02 시험 가이드는 개정되지 않아 시험 문제은행 관점에서는 3유형 답이 여전히 통용될 가능성이 높음(2~4주 내 응시 대비 실익 판단 필요) | M | 높 | 사람 결정: (a) 스템/해설에 "2025-07-15 이전 생성 계정 기준(레거시 프리 티어)" 한정 문구 추가 + 신 프리 티어(크레딧 기반) 한 줄 병기(시험 정합 유지하면서 현행성 확보 — 권장), (b) 현행 유지, (c) 문항 교체 중 택1 | B | Y (인용 출처가 "before July 15, 2025" 한정으로 개정됨 — 신규 계정은 크레딧 기반 Free Tier로 안내) |
| Q-CLF-t4-1-03 | t4-1.questions.json:clf-t4-1-q10 | **스코프/커버리지**: 공식 시험 가이드 Task 4.1 스킬 5종(구매 옵션·RI 유연성·RI Organizations 동작·데이터 전송 비용·스토리지 티어 요금 — assets/exam_guides/CLF-C02.json 실측, 도메인 4 전 태스크에 '프리 티어' 부재)에 프리 티어 항목이 없고, 대응 학습문서 t4-1.md에도 프리 티어 내용이 전무(section 앵커도 없음 — 규칙상 통과이나 문서에서 가르치지 않은 내용을 이 문항셋에서 출제, 오답 시 딥링크 학습 경로 부재) | L | 높 | 사람 결정: 문항을 프리 티어를 다루는 태스크/문서로 이동, t4-1.md에 프리 티어 절 보강(앵커 부여), 또는 시험 전반 대비용으로 현행 유지 중 택1 (발견 02와 함께 처리) | B | N |
| Q-CLF-t4-1-04 | t4-1.questions.json:clf-t4-1-q5 | option 0·explanation이 "Savings Plans는 사용량 기반으로 더 유연(EC2·Fargate·Lambda), 패밀리·리전 바뀌어도 적용"을 **SP 일반 속성처럼 서술** — 엄밀히는 Compute SP만의 속성(EC2 Instance SP는 특정 패밀리·리전 고정, Fargate·Lambda 미적용). 프로그램 수준 서술로는 참이고(AWS 자체 SP vs RI 비교도 동일 프레임) 72% 수치를 결부하지 않아 DOC-CLF-305 오류 결합은 아니며, 정답 유일성에 영향 없음 | L | 높 | explanation에 "(Compute Savings Plans 기준)" 괄호 보강 — 발견 01 수정 시 함께 처리 권장 | A | N |
| Q-CLF-t4-1-05 | t4-1.questions.json:clf-t4-1-q1·q3·q15 | "**1~3년** 약정" 표기 3곳(q1 wrongExplanations."3" "Savings Plans는 1~3년 사용량 약정", q3 wrongExplanations."2" "Reserved Instances는 1~3년 약정", q15 스템 "RI로 1~3년 약정") — 약정 기간은 **1년 또는 3년 2종뿐**(2년 약정 없음)이라 범위 표기는 2년 존재로 오독 여지. t4-1.md와 타 문항(q2·q5·q7 해설)은 "1년 또는 3년"으로 일관 | L | 높 | 3곳을 "1년 또는 3년"으로 통일 | A | N |

## 점검 상세 (통과 집계)
- **정답 유일성 (15/15)**: 구매 옵션 변별(온디맨드 vs RI vs SP vs Spot vs Dedicated Hosts vs Capacity Reservations)이 스템의 결정 신호(약정 유무·중단 허용·물리 전용·구성 고정)로 전 문항 유일 결정. 데이터 전송 3문항(q4·q8·q13)은 방향별 과금(수신 무료/발신·리전 간 과금) 구분 정확, q13 해설은 "리전 내 무조건 무료 아님" 뉘앙스까지 정확. q7은 SP가 보기에 없어 RI 유일, q11은 Dedicated Instances 미제시로 Dedicated Hosts 유일, q15는 Standard RI 미제시로 Convertible RI 유일.
- **해설-정답 일치 (15/15)**: correct 인덱스의 옵션 텍스트와 explanation 서술 전 문항 일치(q7 correct=1 Reserved Instances, q8 correct=2 무료, q9 correct=3 사용량 기반 구성 포함).
- **wrongExplanations (15/15)**: 전 문항 오답 키 3개 완비·인덱스 정합, 각 서술이 해당 오답을 실제 반박(플레이스홀더 없음).
- **section 앵커 (13/13 실존 + 2 없음)**: purchase-options(q1·2·3·5·7·11·14·15)·data-transfer(q4·8·13)·storage-pricing(q6·9) 모두 t4-1.md에 `{#id}` 실존. q10·q12 section 없음 — 규칙상 통과(q10은 발견 03 참조, q12 '비용의 3대 동인'은 문서 §1~3 전체에 걸친 총론이라 무앵커가 자연스러움).
- **skill·difficulty (15/15)**: 전 문항 채움, 내용 정합. difficulty는 foundational 12 · applied 3(q13 시나리오·q14 함정·q15 심화)로 적절.
- **AWS 사실**: q2(발견 01)·q10(발견 02) 외 13문항 사실 정확 — Spot 최대 90%(공식 제품 페이지 부합), 3대 비용 동인(컴퓨팅·스토리지·아웃바운드 — How AWS Pricing Works 부합), 리전 간 전송 발신 리전 기준 과금, Convertible RI "동등 이상 가치 교환", Capacity Reservations 무할인, S3 요금 구성(저장량·요청·아웃바운드) 모두 정확.
- **스키마 위생 (15/15)**: id `clf-t4-1-q1`~`q15` 유일, correct 전부 0~3 범위, verified 전부 true, 옵션 전부 4개, sources 전 문항 존재. content_index.dart questionCount=15와 실제 문항 수 일치.
