# 2단 반박 검증 — V4 RDS·DB — 2026-07

독립 검증자가 발견자 의심 항목의 오탐 여부를 AWS 공식 문서로 적극 반박. 판정 3값(REFUTED=발견자 틀림·문서 정확 / CONFIRMED=문서 오류 실재 / UNCERTAIN). 이 클러스터는 수치·단정 정확도가 핵심이라 현행 공식 한도·옵션을 직접 확인함. 역방향 의심(문항이 옳고 문서가 틀림) 항목은 CONFIRMED가 곧 "문서 오류 확정"을 뜻함.

## 조회 출처 (URL 목록)
- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html (RDS 읽기 복제본 개요 — 엔진별 하위 페이지 링크)
- https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_MySQL.Replication.ReadReplicas.html (MySQL 읽기 복제본 — "up to 15 read replicas" 원문 2회)
- https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html (DynamoDB 파티션 키 — "Adaptive capacity applies to on-demand mode and provisioned capacity")
- https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-uniform-load.html (DynamoDB 워크로드 분산 설계)
- https://aws.amazon.com/ec2/pricing/reserved-instances/pricing/ (RI 할인율 — Standard "up to 72%", Convertible "up to 66%")
- https://aws.amazon.com/rds/reserved-instances/ + docs USER_WorkingWithReservedDBInstances.html (RDS RI — No Upfront "only available for one year term"; 사이즈 유연성 대상 엔진·정규화 계수)

## 판정

| ID | 판정 | 근거(3줄 이내) |
| --- | --- | --- |
| DOC-SAA-208 (M) RDS 읽기 복제본 최대 5개 | **CONFIRMED** | 공식 MySQL 페이지 원문: "You can create up to **15** read replicas from one DB instance within the same Region"(2회). MySQL·MariaDB·PostgreSQL은 15개, Oracle·SQL Server는 5개가 현행. saa-t3-5의 "RDS 최대 5개"(line 110·130·194·281·288 반복)는 엔진 구분 없는 일괄 5개로 오류 → 문서 수정 필요(15개 표기 + 상용엔진 5개 예외 병기). |
| DOC-SAA-407 (L) RDS RI "속성 하나라도 다르면 미적용" 절대단정 | **CONFIRMED** | 공식: "Amazon RDS Reserved Instances provide **size flexibility** for the Aurora, MySQL, MariaDB, PostgreSQL, and Db2 ... discounted rate will automatically apply to usage of any **size in the instance family**"(정규화 단위, db.r3.large=8×db.r3.small). 사이즈는 같은 패밀리·엔진 내 비례 적용됨. saa-t4-3 Q5(line 289) "구성 속성이 하나라도 달라지면 할인이 적용되지 않습니다"는 사이즈에 한해 과일반화 오류 → 문서 수정 필요. |
| DOC-SAA-307 (L) DynamoDB 프로비저닝 처리량 파티션 수 균등 배분 | **CONFIRMED** | 공식(bp-partition-key-design): "**Adaptive capacity** applies to on-demand mode and provisioned capacity." adaptive capacity가 핫 파티션으로 용량을 자동 재배분함(균등분배는 구모델). saa-t3-6 Q5(line 333) "프로비저닝 처리량도 파티션 수에 나눠 배분됩니다"는 adaptive capacity 미반영 구모델 서술 → 문서 오류 실재(스로틀 원인은 파티션당 3,000 RCU/1,000 WCU 물리한도로 재기술 권장). |
| Q-SAA-c-02 (M, 역방향) Convertible RI 최대할인 54% vs 66% | **CONFIRMED** | 공식 EC2 RI 가격 페이지: "Convertible RIs: up to **66%**", "Standard RIs: up to 72%". saa-t4-2.md는 Convertible을 "최대 54%"로 2곳 기재(line 77 표·line 286 함정6)나 questions.json q2는 정답으로 "최대 66%" 사용. **문서의 54%가 오류**, 문항 66%가 정확 → 문서 2곳 수정 필요. |
| Q-SAA-c-03 (M, 역방향) RDS RI 3년 No Upfront 행 존재 | **CONFIRMED** | 공식: "All Upfront and Partial Upfront ... can be purchased for **one or three year terms**, while **No Upfront** Reserved Instances are **only available for one year term**." saa-t4-3.md line 118 "3년 / No Upfront / ~45%" 행은 존재하지 않는 옵션 → **문서의 3년 No Upfront 행이 오류**, 문항(No Upfront=1년 전용) 정확 → 문서 표 행 삭제/정정 필요. |
| Q-SAA-b-05 (M, 항목1 계열) saa-t3-5.questions.json "RDS 최대 5개" | **CONFIRMED (항목1 적용)** | questions.json 해설(q2 line 44 "RDS는 최대 5개", q14 line 288 "일반 RDS MySQL은 최대 5개")도 DOC-SAA-208과 동일 오류. 항목1 판정(MySQL/MariaDB/PostgreSQL=15개)을 문항 해설에도 그대로 적용 → 문항 해설 수정 필요(별도 재론 없이 기록만). |

## 요약
- **CONFIRMED 6건 전부** — REFUTED/UNCERTAIN 0건. 발견자 의심이 모두 실재 오류로 확인됨. 이 클러스터는 오탐이 없다.
- **정방향 3건**(문서 오류): DOC-SAA-208(RDS 읽기복제본 15개가 현행, 5개는 상용엔진 한정), DOC-SAA-407(RDS RI 사이즈 유연성 실재→절대단정 과함), DOC-SAA-307(DynamoDB adaptive capacity 실재→균등배분은 구모델).
- **역방향 2건**(문항 옳음·문서 틀림): Q-SAA-c-02(Convertible RI 66%가 정답, 문서 54% 오류), Q-SAA-c-03(No Upfront 1년 전용이 정답, 문서 3년 No Upfront 행 오류).
- **문항 계열 1건**: Q-SAA-b-05는 항목1과 동일 오류로 함께 수정 대상(15개 정정).
- 참고: questions.json의 Standard 72%/Convertible 66% 및 "RDS 최대 5개, Aurora 최대 15개"의 Aurora 15개는 공식과 일치(정확). 오류는 RDS측 5개 일괄표기·문서 54%·문서 3년 No Upfront에 한정됨.
