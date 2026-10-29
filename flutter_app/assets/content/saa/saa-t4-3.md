---
examGuideTaskId: saa-t4-3
certCode: SAA-C03
domain: 4
domainName: 비용에 최적화된 아키텍처 설계
domainWeightPct: 20
title: 비용 최적화 데이터베이스 — DB 서비스 선택·용량 계획·서버리스 옵션
coversTasks:
  - "4.3"
sources:
  - title: Amazon RDS 예약 인스턴스 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html
  - title: Aurora serverless (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html
  - title: DynamoDB 읽기/쓰기 용량 모드 (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html
  - title: AWS 데이터베이스 서비스 개요 (공식 화이트페이퍼)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html
  - title: AWS DMS 요금(복제 인스턴스·로그 스토리지·SCT 무료) (공식)
    url: https://aws.amazon.com/dms/pricing/
  - title: Amazon Timestream — What is?(InfluxDB 검토 권고) (공식)
    url: https://docs.aws.amazon.com/timestream/latest/developerguide/what-is-timestream.html
  - title: Amazon Redshift 요금(컴퓨트·관리형 스토리지 독립 과금) (공식)
    url: https://aws.amazon.com/redshift/pricing/
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-28
---

# 비용 최적화 데이터베이스 — DB 서비스 선택·용량 계획·서버리스 옵션

> **커버하는 공식 Task** — SAA-C03 · 도메인 4 「비용에 최적화된 아키텍처 설계」(20%) · **Task 4.3 비용에 최적화된 데이터베이스 솔루션 설계** (`saa-t4-3`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. DB 성능(saa-t3-5·t3-6)과 중복을 피해 **"비용"** 관점에 집중합니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.3의 Skill 항목 기반)

- [ ] **워크로드별 DB 서비스 선택** — 관계형·NoSQL·인메모리·서버리스 중 비용 기준 선택 이유를 설명할 수 있다
- [ ] **관리형 vs 자체 관리 비용 차이** — EC2 위 DB와 RDS/Aurora의 총소유비용(TCO) 차이를 안다
- [ ] **RDS 예약 인스턴스** — 기간·결제 옵션별 할인율과 선택 기준을 안다
- [ ] **용량 계획 비용 절감** — 스토리지 자동 확장·인스턴스 rightsizing·읽기 복제본·캐싱의 비용 효과를 안다
- [ ] **서버리스·온디맨드 옵션** — Aurora serverless(ACU)와 DynamoDB 온디맨드/프로비저닝 모드를 언제 선택하는지 안다
- [ ] **데이터 수명주기 비용** — 백업 보존 기간이 스토리지 비용에 미치는 영향을 안다

---

## 🎯 왜 중요한가

- 도메인 4(20%)는 "요구를 충족하면서 가장 저렴한" 선택을 묻습니다. DB는 클라우드 비용에서 큰 비중을 차지하므로, DB 선택과 용량 설정이 곧 아키텍처 비용을 좌우합니다.
- 시험은 워크로드 패턴(예측 가능/불규칙/간헐적/고트래픽)을 주고 **비용 효율적인 DB 서비스·모드를 고르는** 시나리오를 냅니다.
- "가장 저렴"이라는 함정에 주의해야 합니다 — 요구사항(가용성·성능 SLA)을 충족하지 못하면 아무리 싸도 오답입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **총소유비용** | TCO (Total Cost of Ownership) | 인스턴스 비용 외에 운영·인건비·관리 도구 비용까지 포함한 실질 총비용 |
| **NoSQL** | NoSQL | 고정 스키마 없이 key-value·문서·그래프 등 유연한 데이터 모델을 쓰는 비관계형 DB 범주 |
| **다중 가용 영역** | Multi-AZ | 같은 리전 내 2개 이상 AZ에 DB를 복제해 AZ 장애를 자동으로 극복하는 RDS 배포 옵션 |
| **절감 약정** | Savings Plans | 일정 금액을 약정해 할인받는 옵션. Compute·EC2 Instance 유형은 RDS에 적용되지 않지만, **Database Savings Plans**는 Aurora·RDS·DynamoDB·ElastiCache 등에 적용됨 |
| **온라인 트랜잭션 처리** | OLTP (Online Transaction Processing) | 다수의 짧은 읽기·쓰기 트랜잭션을 빠르게 처리하는 워크로드 유형 — 관계형 DB가 전통적으로 담당하는 패턴 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 워크로드별 DB 서비스 선택과 비용 {#db-service-selection}

> 목적에 맞는 DB(purpose-built database)를 고르는 것 자체가 비용 최적화의 출발점입니다. 범용 관계형 DB로 모든 것을 처리하면 불필요한 스케일업 비용이 발생합니다.

**워크로드별 AWS DB 선택 + 비용 비교**

| 워크로드 유형 | 적합한 서비스 | 비용 특성 | 피해야 할 선택(과비용) |
|---|---|---|---|
| OLTP 관계형 (예측 가능한 부하) | RDS (MySQL/PostgreSQL) | 예약 인스턴스로 최대 60% 절감 | EC2 자체 관리(운영 인건비 추가) |
| OLTP 관계형 (가변·고가용성) | Aurora (프로비저닝) | 스토리지 자동 확장, I/O 비용 별도 | 과스펙 Multi-AZ RDS |
| 관계형·불규칙 부하 | Aurora serverless | ACU 단위 초당 과금, 유휴 시 최소 비용 | 상시 프로비저닝 인스턴스 |
| 대규모 key-value / 서버리스 앱 | DynamoDB | 온디맨드(예측 불가) / 프로비저닝(예측 가능) | RDS over-provision |
| 읽기 캐싱·세션 저장 | ElastiCache (Redis/Memcached) | RDS 읽기 부하 감소 → 인스턴스 다운사이즈 가능 | 읽기 복제본만 무한 추가 |
| 시계열·IoT 데이터 | Amazon Timestream for InfluxDB | LiveAnalytics는 **2025-06-20부터 신규 고객 접근 불가**(기존 고객은 계속 사용) → 신규는 InfluxDB 선택 | RDS에 시계열 저장 |
| 그래프 관계 데이터 | Amazon Neptune | 목적 최적화로 쿼리 비용↓ | 복잡한 JOIN으로 RDS 과부하 |
| 문서 (MongoDB 호환) | Amazon DocumentDB | 관리형으로 운영비↓ | EC2 위 MongoDB 자체 관리 |

**관리형 vs 자체 관리 TCO 요소**

| 비용 항목 | RDS/Aurora (관리형) | EC2 위 직접 설치 (자체 관리) |
|---|---|---|
| 인스턴스 비용 | 동일 수준 | 동일 수준 |
| 패치·업그레이드 | AWS 자동 | 직접 (엔지니어 시간) |
| 백업·복구 설정 | 자동 포함 | 직접 구성·테스트 |
| HA(Multi-AZ) | 클릭 하나 | 직접 구성(복잡) |
| 모니터링 | 기본 제공 | 추가 도구 설치 |
| 총비용 판단 | 인스턴스 비용은 소폭 높으나 운영 비용 절감으로 TCO 유리 | 인스턴스 비용은 낮으나 운영 인건비 포함 시 TCO 불리 |

> 시험 원칙: "minimal operational overhead"가 조건이면 관리형(RDS/Aurora/DynamoDB)이 정답 후보입니다.

> 🧠 원리: 왜 목적에 맞는 DB를 고르는 것 자체가 비용 최적화의 출발점이 될까요?
> 범용 관계형 DB는 모든 접근 패턴을 처리할 수 있지만, 특정 패턴에 특화된 DB보다 더 많은 인스턴스 용량과 복잡한 쿼리를 필요로 합니다.
> 예를 들어 시계열 데이터를 관계형 DB에 저장하면 시간 기반 집계를 위해 대규모 인덱스와 파티셔닝을 직접 관리해야 하지만, 시계열 특화 DB는 그 패턴에 맞는 저장 구조를 내부적으로 사용합니다.
> 결과적으로 워크로드에 맞는 DB를 고르면 같은 부하를 더 작은 인스턴스와 더 단순한 운영으로 처리할 수 있어 인스턴스 비용과 운영 비용이 함께 줄어듭니다.

---

### 2) RDS 예약 인스턴스 — 예측 가능한 부하의 비용 절감 {#rds-reserved-instances}

예약 인스턴스(Reserved Instance, RI)는 1년 또는 3년을 약정해 On-Demand 대비 할인을 받는 방식입니다. 프로덕션에서 **상시 실행되는 RDS 인스턴스**라면 RI 구매가 가장 직접적인 비용 절감 수단입니다.

**기간·결제 옵션별 할인율 (대략적 범위)**

| 기간 | 결제 옵션 | 할인율(On-Demand 대비) | 선택 기준 |
|---|---|---|---|
| 1년 | All Upfront | ~40% | 초기 자금 여유, 중기 약정 |
| 1년 | Partial Upfront | ~35% | 초기 부담과 할인의 균형 |
| 1년 | No Upfront | ~25% | 초기 비용 최소화 |
| 3년 | All Upfront | ~60% | 장기 안정 워크로드, 최대 절감 |
| 3년 | Partial Upfront | ~55% | 장기 약정 + 유연한 결제 |
| 3년 | No Upfront | ~45% | 장기 약정, 초기 비용 0 |

> RI는 **리전·엔진·인스턴스 클래스·에디션·라이선스 유형**을 지정해 구매합니다. 단 **사이즈 유연성**이 있어 같은 인스턴스 클래스 타입 안에서는 크기가 달라도 할인이 자동 적용되고(예: db.r6i.large → db.r6i.xlarge, 단 db.r6id·db.r7g는 다른 타입), **Single-AZ ↔ Multi-AZ 사이에도 정규화 단위 기준으로 적용**됩니다. 사이즈 유연성 대상 엔진은 Db2·MariaDB·MySQL·Oracle(BYOL)·PostgreSQL이고, **RDS for SQL Server와 Oracle License Included는 예외**입니다. RI 할인은 **인스턴스 시간 요금만** 깎아 주며 스토리지·백업·I/O는 그대로입니다. 워크로드 변화가 예상되면 1년 RI + Partial Upfront가 유연성과 절감의 균형점입니다.

> 🧠 원리: 왜 RDS RI는 인스턴스 클래스 타입·엔진·리전 조합에 묶여 있을까요?
> RDS RI는 물리 서버를 예약하는 것이 아니라, 특정 구성 속성(엔진·클래스 타입·리전)에 결부된 청구 할인 약정입니다. 할인은 실제 사용 구성이 약정 구성과 같은 범주에 들어올 때 자동 적용되며, 사이즈 유연성 덕분에 **크기와 AZ 구성(Single/Multi-AZ)은 정규화 단위로 환산해 흡수**됩니다.
> 그래도 클래스 타입 자체를 바꾸거나(db.r6i → db.r7g) 리전을 이동하면 기존 RI가 적용되지 않아 낭비가 생길 수 있습니다.
> 따라서 RI 구매 전에 워크로드의 안정성을 충분히 검토하는 것이 비용 절감을 실현하는 전제 조건입니다.

---

### 3) 용량 계획 — 스토리지·인스턴스 rightsizing {#capacity-planning}

**스토리지 자동 확장 (Storage Auto Scaling)**

RDS와 Aurora 모두 스토리지 자동 확장을 지원합니다. 사전에 과잉 프로비저닝하지 않고 실제 사용량에 맞게 확장되므로 낭비를 줄입니다.

- RDS: 설정한 최대 스토리지 임계치까지 자동 확장. 수동 다운사이즈는 불가이므로 최대치 설정이 비용 상한선이 됩니다.
- Aurora: 10GB 단위로 자동 확장, 최대 256TiB(2025년 상향 — 구버전 엔진 128TiB). 미사용 스토리지는 반환. 데이터 삭제 후 공간이 회수됩니다.

**Aurora 스토리지 구성 — I/O 지출 비중이 기준입니다.**

| 구성 | 과금 | 언제 고르나 |
|---|---|---|
| **Standard** | 스토리지 + **I/O 요청당** 과금 | I/O 지출이 전체 Aurora 지출의 **25% 미만**일 때 |
| **I/O-Optimized** | 스토리지 단가가 높은 대신 **읽기·쓰기 I/O 요금이 없음** | I/O 지출이 **25% 이상**일 때 |

- 공식 요금 페이지는 **I/O 지출이 전체 Aurora 지출의 25%를 넘으면 최대 40% 절감**할 수 있다고 적습니다.
- ⚠️ 전환은 **방향에 따라 제약이 다릅니다** — **I/O-Optimized → Standard는 언제든** 되돌릴 수 있지만, **Standard → I/O-Optimized는 30일에 한 번**만 바꿀 수 있습니다. 그래서 먼저 Cost Explorer로 **I/O가 Aurora 지출에서 차지하는 비중**을 확인하고 고릅니다.

**인스턴스 rightsizing**

| 방법 | 설명 |
|---|---|
| AWS Compute Optimizer | RDS 인스턴스 CPU·메모리 사용률 분석 후 적정 크기 추천 |
| CloudWatch 지표 모니터링 | CPUUtilization·FreeableMemory·DatabaseConnections 추이 확인 |
| 버스터블 인스턴스(db.t*) | 개발·테스트 환경에 적합. 크레딧 소진 시 성능 제한이 있어 프로덕션에는 주의 |

**읽기 복제본과 캐싱으로 인스턴스 다운사이즈**

읽기 부하를 Read Replica나 ElastiCache로 분산하면 주(Primary) 인스턴스를 더 작은 클래스로 유지할 수 있습니다.

| 전략 | 효과 |
|---|---|
| Aurora Read Replica (최대 15개) | Writer 인스턴스 부하↓ → 더 작은 인스턴스로 운영 가능 |
| ElastiCache (Redis/Memcached) 앞단 | 반복 쿼리 캐시 → DB 요청 수↓ → RDS 인스턴스 다운사이즈 가능 |
| RDS Read Replica (리전 내) | 읽기 전용 앱을 Replica로 라우팅 |

**복제본은 공짜가 아닙니다 — 비용 축을 먼저 봅니다.**

- 읽기 복제본은 **표준 DB 인스턴스와 같은 요율**로 과금됩니다. 복제본을 하나 띄우면 **별도 인스턴스** 요금이 그대로 더해지므로, "주 인스턴스를 한 단계 낮춘 절감"이 **복제본 요금보다 커야** 이득입니다.
- **교차 리전 복제본**은 인스턴스 요금에 더해 원본↔대상 리전 간 **데이터 전송**이 과금됩니다(생성 시 스냅샷 전송 + 이후 변경분마다). 리전 내 복제본과 비용 성격이 다릅니다.
- MySQL·MariaDB는 복제본에서 다시 복제본을 만드는 **연쇄** 구성이 가능하고, 같은 리전 안의 전송은 과금되지 않아 복제본을 여러 개 둘 때 전송 비용을 줄일 수 있습니다.
- ⚠️ **Multi-AZ 대기 인스턴스는 읽기를 처리하지 않습니다**(비용은 §10의 약 2배). **읽기 분산이 목적이면 복제본**, **가용성이 목적이면 Multi-AZ**로 수단이 갈립니다.

> 🧠 원리: 왜 RDS 스토리지는 자동 확장 후 다운사이즈가 불가능할까요?
> RDS 스토리지는 블록 스토리지(EBS) 위에서 동작하는데, 블록 스토리지는 볼륨 확장 후 기존 데이터의 레이아웃과 파일시스템 경계가 변경되어 축소 작업이 데이터 무결성을 위협합니다.
> 축소를 지원하려면 데이터를 새 볼륨으로 모두 이전하는 대규모 작업이 필요하고, 이 과정에서 운영 중인 DB가 일시 중단될 위험이 있어 AWS는 이를 관리형 기능으로 제공하지 않습니다.
> 이 제약이 "처음부터 필요한 크기를 정확히 잡거나 자동 확장 최대치를 신중히 설정하라"는 운영 권고의 기술적 근거입니다.

---

### 4) 서버리스·온디맨드 옵션 {#serverless-on-demand}

**Aurora serverless**

| 항목 | 내용 |
|---|---|
| 스케일 단위 | ACU(Aurora Capacity Unit) — 0.5 ACU 단위로 미세 조정 |
| 청구 방식 | 실제 사용 ACU × 초당 과금. 유휴 시 최솟값(0.5 ACU)만 과금 |
| 최솟값 | 0 ACU(자동 일시정지, 별도 설정 필요) ~ 설정한 최솟값 |
| 지원 엔진 | Aurora MySQL, Aurora PostgreSQL |
| 적합한 워크로드 | 트래픽이 불규칙하거나 간헐적인 앱, 개발·테스트 환경, 신규 앱 용량 예측 불가 상황 |
| 장점 | 관계형 DB 기능(트랜잭션·복잡한 쿼리)을 유지하면서 서버리스 비용 모델 적용 |

> Aurora serverless는 0.5 ACU 단위로 스케일되므로 프로비저닝 클러스터처럼 인스턴스 클래스 전체를 업그레이드할 필요가 없습니다. 처리량이 증가할 때 부분적으로만 용량이 추가됩니다.

**DynamoDB 용량 모드 비교 (★ 시험 핵심)**

| 항목 | 온디맨드(On-Demand) | 프로비저닝(Provisioned) |
|---|---|---|
| 청구 단위 | 실제 요청 수(읽기 요청 단위 RRU / 쓰기 요청 단위 WRU) | 시간당 프로비저닝된 RCU/WCU |
| 용량 설정 | 불필요 (자동) | 직접 설정 필요 |
| 자동 스케일링 | 즉시·자동 | Auto Scaling 별도 구성 가능 |
| 비용 패턴 | 사용량 비례 — 트래픽 없으면 비용 없음 | 미사용 용량도 과금 |
| 적합한 워크로드 | 트래픽 예측 불가, 신규 앱, 간헐적 사용 | 트래픽 예측 가능·안정적, 대량 처리로 단가 낮춤 |
| 비용 비교 | 동일 트래픽 기준 프로비저닝보다 비쌀 수 있음 | 예측 가능 워크로드에서 총비용 유리 |
| 모드 전환 | 언제든 전환 가능 (전환 후 24시간 내 재전환 제한) | — |

> **모드 선택의 정량 기준**: 공식은 "예측 불가 트래픽에는 **온디맨드가 모범 사례**, 일관되거나 점진적으로 증가하는 트래픽에는 **프로비저닝 + 자동 확장**"으로 적습니다. 수치로는 **프로비저닝 용량의 평균 활용률 35% 미만이면 온디맨드가 저렴**합니다. 활용률이 35% 이상이어도 **한가한 구간과 피크가 심하게 섞여 있으면** 온디맨드가 나을 수 있습니다.

**DynamoDB 절감 수단 — 처리량·저장·수명을 따로 줄입니다.**

| 수단 | 줄이는 축 | 조건 |
|---|---|---|
| **예약 용량**(프로비저닝 전용) | 처리량 단가 | 1년 최대 54% · 3년 최대 77%. **단일 리전·Standard 클래스 전용** |
| **Standard-IA 테이블 클래스** | **저장** 비용 60% 절감 | 저장 비용이 테이블 총비용의 **약 50% 이상**일 때 유리. ⚠️ **처리량 단가는 Standard보다 높습니다.** 코드 변경 없이 클래스 전환 |
| **TTL로 만료** | 저장량 자체 | 만료된 항목을 자동 삭제 — 같은 리전 내 삭제에는 추가 비용이 없습니다 |
| **Database Savings Plans** | 처리량 단가 | 온디맨드·프로비저닝 모두 대상. ⚠️ 같은 워크로드에 **예약 용량과 병용할 수 없습니다** |

**다른 서버리스 선택지**

- **Redshift Serverless** — RPU-시간을 초 단위로 재되 **최소 60초**가 붙습니다. 분석 질의가 간헐적이면 프로비저닝 노드보다 유리합니다.
- **ElastiCache Serverless** — 캐시도 용량을 미리 잡지 않고 쓸 수 있습니다(§9의 Valkey·예약 노드는 노드 기반 선택지입니다).

> 🧠 원리: 왜 Aurora serverless는 인스턴스 클래스 전체를 교체하지 않고 0.5 ACU 단위로 조금씩 스케일할 수 있을까요?
> 전통적인 프로비저닝 인스턴스는 CPU·메모리가 고정된 서버 단위로 운영되기 때문에 용량을 늘리려면 다음 단계 인스턴스 클래스로 전환해야 합니다.
> Aurora serverless는 Aurora의 공유 스토리지 아키텍처 위에서 컴퓨팅 용량을 동적으로 조정하도록 설계되어, 서버 교체 없이 할당된 CPU·메모리 비율을 세밀하게 변경할 수 있습니다.
> 이 덕분에 트래픽이 조금씩 증가할 때도 용량이 그에 맞게 부분적으로만 추가되어, 과잉 프로비저닝 없이 필요한 만큼만 비용이 발생합니다.

---

### 5) 데이터 수명주기 — 백업 보존 비용 {#backup-retention-cost}

| 항목 | 내용 |
|---|---|
| RDS 자동 백업 보존 기간 | 0~35일 설정 가능. 0으로 설정 시 자동 백업 비활성화(스냅샷은 수동 유지) |
| 백업 스토리지 비용 | 과금 기준은 **리전 전체의 자동 백업 + 수동 스냅샷 합계**(인스턴스별이 아님). 프로비저닝한 DB 스토리지 합계에 해당하는 무료 제공량이 있고 초과분은 GB당 요금 — 정확한 무료 범위는 RDS 요금 페이지 기준 |
| 스냅샷 보존 | 수동 스냅샷은 삭제 전까지 보존·과금. 불필요한 스냅샷은 주기적으로 삭제 권장 |
| Aurora 백업 | Aurora는 자동으로 연속 백업(S3) — 보존 기간 설정이 비용에 직접 영향 |
| 교차 리전 복사 | 스냅샷 교차 리전 복사 시 대상 리전 스토리지 요금 별도 발생 |

- 백업은 **증분**이라 과금 크기는 프로비저닝한 크기가 아니라 **실제 데이터 양**을 따릅니다. 보존 기간이 1일이면 대개 무과금 범위에 들어갑니다.
- **Aurora는 기준이 다릅니다** — 클러스터의 **총 Aurora 스토리지의 100%까지 무료**이고(트랜잭션 로그·메타데이터 포함) 그 위부터 과금됩니다. 보존 기간 **안의** 스냅샷은 개수 제한 없이 무료이고, **보존 기간 밖**으로 남긴 수동 스냅샷부터 GB-월이 붙습니다.
- ⚠️ 자동 시스템 스냅샷은 복사하지 않으면 무료지만 **복사본은 항상 과금**됩니다 — 교차 리전·교차 계정 복사를 습관처럼 걸어 두면 조용히 쌓입니다.

**DynamoDB 백업은 별도 축입니다.**

- **PITR**(특정 시점 복구)은 켜 둔 동안 테이블 크기를 지속 추적해 **GB-월로 과금**됩니다 — 필요한 테이블에만 켭니다.
- **온디맨드 백업**은 백업 저장량에 GB-월이 붙고, **복원**은 복원한 데이터 양만큼 따로 과금됩니다.
- **AWS Backup**으로 RDS·Aurora·DynamoDB의 백업을 한곳에서 일정·보존 규칙으로 관리하면 수동 스냅샷이 흩어져 쌓이는 것을 막을 수 있습니다.

> 프로덕션에서는 규정상 최소 보존 기간을 충족하되, 보존 기간을 필요 이상 길게 설정하면 스토리지 비용이 누적됩니다.

> 🧠 원리: 왜 수동 스냅샷은 RDS 인스턴스를 삭제해도 자동으로 사라지지 않을까요?
> 자동 백업은 인스턴스의 수명과 연동되어 인스턴스 삭제 시 함께 제거되는 반면, 수동 스냅샷은 사용자가 명시적으로 생성한 시점 복사본으로 인스턴스와 독립된 수명을 가집니다.
> 이 분리 설계는 인스턴스를 잠깐 내렸다가 다시 복구하거나 다른 리전에 복원하는 시나리오를 지원하기 위한 것입니다.
> 결과적으로 불필요한 수동 스냅샷을 주기적으로 삭제하지 않으면 인스턴스가 없어도 스토리지 비용이 계속 발생할 수 있습니다.

---

### 6) DB 마이그레이션 비용 — DMS·SCT {#db-migration-cost}

엔진 전환·클라우드 이전의 비용은 **이전 도구 자체**보다 **얼마나 오래 복제를 띄워 두는가**에서 갈립니다.

| 항목 | 과금 |
|---|---|
| **DMS 온디맨드** | **복제 인스턴스** 시간당 + **추가 로그 스토리지**. 인스턴스에는 스왑·로그·캐시용 스토리지가 이미 포함 |
| **DMS 서버리스** | 사용한 만큼 시간당 |
| **AWS SCT** | **무료** — DMS에 포함돼 별도 비용이 없습니다 |
| 데이터 전송 | **DMS로 들어오는 전송 무료**. DMS ↔ RDS·Redshift·EC2가 **같은 AZ면 무료**, 다른 AZ·리전·AWS 외부는 표준 전송 요금 |
| 절감 약정 | **Database Savings Plans** 적용 가능 |

**비용을 줄이는 지점**

- **복제 인스턴스를 같은 AZ에** 두면 전송 요금이 사라집니다 — 원본·대상·복제 인스턴스의 배치가 곧 비용입니다.
- **CDC를 언제 끄는가**가 총액을 좌우합니다. 전체 로드만 하면 짧게 끝나지만, 컷오버까지 지속 복제를 띄워 두면 그 기간 전체가 인스턴스 요금입니다.
- 스키마 변환 때문에 비용을 걱정할 필요는 없습니다 — SCT는 무료입니다.

> 🧠 원리: 왜 마이그레이션 요금이 "옮긴 데이터 양"이 아니라 "띄워 둔 시간"으로 매겨질까요?
> DMS는 파일을 복사해 주는 서비스가 아니라, 원본의 트랜잭션 로그를 계속 읽어 대상에 적용하는 **실행 중인 복제 엔진**입니다. 전체 로드가 끝난 뒤에도 컷오버 전까지 변경분을 따라가야 하므로 인스턴스가 살아 있어야 합니다.
> 그래서 과금의 주축이 전송량이 아니라 인스턴스 시간이 되고, 같은 데이터를 옮겨도 컷오버를 미루면 비용이 늘어납니다.
> 비용 설계의 결론은 단순합니다 — **전환 일정을 짧게 잡고, 복제 경로를 같은 AZ 안에 두는 것**입니다.

---

### 7) 시계열·열 기반 DB의 비용 축 {#timeseries-columnar-cost}

시간 축 데이터와 분석용 열 기반 저장은 관계형과 과금 축 자체가 다릅니다.

| 선택지 | 과금 축 |
|---|---|
| **Timestream for InfluxDB** | 컴퓨트와 스토리지가 **분리**돼 사용한 만큼 과금. 내부적으로 **Parquet 열 저장(S3)** 구조 |
| **Amazon Redshift**(RA3·RG 노드) | **컴퓨트와 관리형 스토리지(RMS)를 독립 과금**. RMS는 SSD↔S3 자동 오프로드이고 **리더 노드는 무료** |
| **Redshift Serverless** | **RPU-시간**을 초 단위로(최소 60초) |
| **Athena + Parquet**(`saa-t3-9` 참조) | 스캔한 데이터 양 — 열 형식으로 저장하면 스캔량이 줄어 비용이 내려감 |

> ⚠️ **Timestream for LiveAnalytics 대신 Timestream for InfluxDB**를 검토하라는 것이 현행 안내입니다(LiveAnalytics는 신규 접근이 닫혔습니다).

> 선택은 **쿼리 빈도와 상주 여부**로 갈립니다. 상시 대시보드가 붙어 클러스터를 계속 띄워 둬야 하면 프로비저닝 노드, 하루에 몇 번 도는 배치면 Serverless나 Athena 쪽이 유휴 시간 비용을 피합니다. 어느 서비스가 절대적으로 더 싸다고 말할 수 있는 공식 기준은 없습니다 — 워크로드의 상주 시간으로 판단하세요.

> 🧠 원리: 왜 분석용 DB는 컴퓨트와 스토리지를 따로 과금할까요?
> 분석 워크로드는 보관 기간이 길고 쿼리는 간헐적입니다. 데이터는 몇 년치가 쌓이지만 실제로 계산이 도는 시간은 하루 중 일부뿐인 경우가 많습니다.
> 컴퓨트와 스토리지가 묶여 있으면 데이터를 더 보관하려고 쓰지도 않는 계산 자원까지 늘려야 하므로, 쌓을수록 낭비가 커집니다.
> 두 축을 분리하면 "오래 보관하되 계산은 필요할 때만"이 가능해지고, 그래서 Redshift의 관리형 스토리지나 Timestream의 분리 과금처럼 **보관 비용과 질의 비용을 따로 내는 구조**가 분석 쪽의 표준이 됩니다.

### 8) DB 엔진 선택과 라이선스 비용 {#engine-license-cost}

같은 관계형이라도 엔진 선택이 **성능 특성과 라이선스 비용** 양쪽을 가릅니다.

| | MySQL | PostgreSQL |
|---|---|---|
| 성격 | 순수 관계형 | **객체-관계형**(사용자 정의 타입·상속 등) |
| 성능 경향 | **읽기 빈번** 작업에 유리 | **쓰기 빈번** 작업과 복잡한 질의에 유리 |
| 고급 기능 | 상대적으로 단순 — 시작이 쉬움 | 구체화 뷰·`INSTEAD OF` 트리거·다중 언어 저장 프로시저·풍부한 인덱스 유형 |
| ACID | 스토리지 엔진에 달림(InnoDB 등) | **항상** 보장 |

- 둘 다 널리 쓰이는 오픈소스라 **라이선스 요금이 없습니다.** 비용 차이는 주로 **상용 엔진과 비교할 때** 생깁니다.
- **라이선스 모델** — RDS는 **License Included**(요금에 라이선스 포함)와 **BYOL**(보유 라이선스 반입)로 나뉩니다. SQL Server·Oracle 같은 상용 엔진은 인스턴스 요금에 라이선스가 얹혀 같은 크기라도 오픈소스 엔진보다 비쌉니다.
- 그래서 **상용 엔진에서 오픈소스**(PostgreSQL·MySQL·Aurora)로 옮기는 것이 DB 비용 절감에서 가장 큰 한 수가 될 수 있습니다. 다만 이식 공수·기능 매핑·검증 비용을 함께 계산해야 하며, 절감 폭은 워크로드마다 달라 일반화된 수치를 그대로 믿지 않습니다.

> 🧠 원리: 왜 엔진을 바꾸는 것이 인스턴스 크기를 줄이는 것보다 큰 절감이 될 수 있을까요?
> 상용 엔진의 라이선스 요금은 vCPU 수에 비례해 인스턴스 요금 위에 더해지므로, 같은 성능을 내는 동안 **컴퓨팅 요금과 별개의 고정 비용**이 계속 따라붙습니다.
> 크기를 줄이면 그 비례분이 함께 줄긴 하지만 라이선스 체계 자체는 남고, 성능 요구가 있는 한 줄일 수 있는 폭도 제한됩니다.
> 반면 오픈소스 엔진으로 옮기면 그 축이 **통째로 사라지므로**, 이식 공수를 한 번 치르고 나면 이후 기간 내내 절감이 누적됩니다.

### 9) 연결과 캐싱 — 인스턴스를 키우지 않고 버티기 {#connection-caching-cost}

DB가 버거울 때 **인스턴스를 키우는 것은 가장 비싼 선택**입니다. 연결과 읽기를 앞단에서 흡수하면 같은 인스턴스로 더 오래 버틸 수 있습니다.

**RDS Proxy — 연결 폭주를 흡수합니다.**

- 과금은 **대상 DB의 용량에 비례**합니다 — 프로비저닝 인스턴스는 **DB 인스턴스 vCPU-시간당**, Aurora serverless는 **ACU-시간당**입니다.
- 초 단위로 재되 상태 변경 후 **10분 최소** 과금이 붙습니다.
- 판단 축은 단순합니다 — **"연결 수 때문에 인스턴스를 한 단계 키우는 비용"과 "프록시 요금"을 비교**합니다. Lambda처럼 연결이 폭발하는 호출 패턴에서 프록시가 유리해지는 구간이 생깁니다.

**ElastiCache — 반복 읽기를 흡수합니다.** 캐싱 전략을 먼저 고르고 비용 레버를 얹습니다.

| 전략 | 동작 | 비용·정합성 성격 |
|---|---|---|
| **지연 로딩**(lazy loading) | 캐시 미스일 때만 DB에서 읽어 채움 | 쓰지 않는 데이터는 캐시에 안 올라가 **캐시 크기가 작다**. 첫 요청은 느리고, 갱신이 늦으면 오래된 값이 남을 수 있음 |
| **쓰기 시 갱신**(write-through) | 쓸 때 캐시도 함께 갱신 | 캐시가 항상 최신이지만 **쓰지 않는 데이터까지 캐시를 차지**해 크기가 커짐 |
| **TTL** | 항목에 수명을 둠 | 위 둘 중 무엇을 쓰든 **오래된 값의 수명을 끊는** 안전장치 |

- **DynamoDB 앞단**은 ElastiCache가 아니라 **DAX**가 전용 캐시입니다(마이크로초 응답, 애플리케이션 변경 최소).
- 비용 레버 — 엔진으로 **Valkey**를 고르면 Redis OSS보다 단가가 낮고, 상시 가동 노드에는 **예약 노드**(1·3년 약정, 노드 패밀리 안에서 크기 유연)를 겁니다. 접근 빈도가 낮은 데이터가 많으면 **데이터 티어링**(메모리 + SSD)으로 같은 데이터를 더 싸게 담을 수 있습니다.

> 🧠 원리: 왜 캐시를 앞에 두는 것이 DB 인스턴스를 키우는 것보다 싸질 수 있을까요?
> DB 인스턴스는 읽기·쓰기·연결·저장을 모두 감당하도록 설계돼 있어, 읽기 때문에 한 단계 키우면 쓰지도 않는 쓰기·저장 능력까지 함께 사게 됩니다.
> 캐시는 **반복 읽기 하나만** 처리하는 단순한 자원이라 같은 읽기 처리량을 훨씬 낮은 단가로 살 수 있고, 적중률이 높을수록 DB에 도달하는 질의 자체가 줄어듭니다.
> 그래서 "읽기가 많아 CPU가 높다"는 상황에서는 크기를 올리기 전에 **앞단에서 흡수할 수 있는 몫**부터 덜어내는 것이 비용 효율적입니다.

### 10) 끄고·낮추고·찾기 — 중지·Multi-AZ·Extended Support·비용 도구 {#db-stop-and-find}

**비프로덕션은 끕니다.** RDS 인스턴스는 중지할 수 있고, 중지 중에는 **DB 인스턴스 시간이 과금되지 않습니다.**

- ⚠️ 중지는 **최대 7일**까지만 유지되고 그 뒤 유지 보수를 위해 **자동으로 다시 시작**됩니다. 더 오래 꺼 두려면 일정 자동화로 다시 중지해야 합니다.
- ⚠️ "끄면 0원"이 아닙니다 — **프로비저닝 스토리지(PIOPS 포함)·백업 스토리지·퍼블릭 IPv4**는 중지 중에도 계속 과금됩니다.
- **Multi-AZ**는 대기 인스턴스와 그 스토리지가 함께 붙어 Single-AZ보다 **약 2배** 수준이 됩니다. 프로덕션의 가용성 요구에는 필요하지만, **비프로덕션에 기본값으로 켜 두면 그대로 낭비**입니다.

**오래된 엔진 버전은 비용이 됩니다.** 커뮤니티 지원이 끝난 메이저 버전을 계속 쓰면 **RDS Extended Support**가 적용돼 **vCPU-시간 단위 요금이 추가**됩니다(Aurora serverless는 ACU-시간 단위). 단가는 리전과 **연차에 따라 오르고**, **Multi-AZ 대기 인스턴스에도 붙습니다.** 표준 지원 버전으로 업그레이드하면 과금이 멈추므로, 업그레이드 미루기는 **눈에 안 보이는 비용**입니다.

**비용 도구는 DB도 봅니다.** 4.1의 도구들이 DB 영역에서 무엇을 찾아 주는지 알아 두면 "어디부터 볼까"가 빨라집니다.

| 도구 | DB 관점에서 찾아 주는 것 |
|---|---|
| **Trusted Advisor** | **유휴 DB 인스턴스**(Amazon RDS Idle DB Instances) · RDS·ElastiCache·Redshift·OpenSearch의 **예약 최적화** 권고 |
| **Compute Optimizer** | RDS·Aurora의 인스턴스 크기·스토리지 권고와 **유휴 권고** |
| **AWS Budgets** | **RI 사용률·커버리지 알림** — EC2뿐 아니라 **RDS·Redshift·ElastiCache 예약**을 지원 |

> 🧠 원리: 왜 "끄기"가 rightsizing보다 먼저 와야 할까요?
> rightsizing은 **쓰고 있는 자원의 크기**를 줄이는 일이라, 아무리 잘해도 그 자원이 돌아가는 동안의 요금은 남습니다.
> 반면 비프로덕션처럼 **쓰지 않는 시간이 긴** 자원은 그 시간 동안의 요금을 통째로 없앨 수 있어 절감의 상한이 훨씬 높습니다.
> 그래서 순서는 "안 쓰는 것을 끄고 → 남은 것의 크기를 맞추고 → 그 위에 약정을 얹는" 쪽이 되고, 유휴 탐지 도구가 그 첫 단계를 자동화해 줍니다.

---

## ✍️ 시험 포인트

- **"예측 불가 트래픽 + 관계형 DB"** → Aurora serverless. DynamoDB는 NoSQL이므로 관계형 스키마 요구 시 부적합.
- **"예측 불가 트래픽 + NoSQL"** → DynamoDB 온디맨드 모드.
- **"안정적·예측 가능 + NoSQL"** → DynamoDB 프로비저닝 + Auto Scaling. 동일 처리량 기준 온디맨드보다 저렴.
- **"상시 실행 RDS + 비용 절감"** → 예약 인스턴스(RI). All Upfront 3년이 최대 절감.
- **"읽기 부하 증가 + 비용 최소화"** → Read Replica 또는 ElastiCache로 분산 → Primary 인스턴스 다운사이즈.
- **"minimal operational overhead"** → 관리형 서비스(RDS/Aurora/DynamoDB). EC2 위 자체 설치는 운영 부담·비용 증가.
- **"개발·테스트 환경 + 비용 최소화"** → Aurora serverless(최솟값 설정) 또는 DynamoDB 온디맨드.
- **RDS RI vs EC2 RI 혼동 주의**: RDS RI는 리전·엔진·인스턴스 클래스 타입으로 구매하되 **크기와 Single/Multi-AZ는 사이즈 유연성으로 흡수**됩니다(SQL Server·Oracle LI 제외). **Compute/EC2 Instance Savings Plans는 RDS에 적용되지 않지만, Database Savings Plans는 RDS·Aurora·DynamoDB·ElastiCache 등에 적용**됩니다(같은 워크로드에 RDS RI와 중복 적용은 불가).
- **"상용 엔진 라이선스 비용이 큰 비중"** → **상용 엔진에서 오픈소스**(PostgreSQL·MySQL·Aurora)로 전환 검토. 이식 공수와 함께 계산.
- **"Lambda 호출 폭증으로 DB 연결 고갈"** → **RDS Proxy**. 인스턴스를 한 단계 키우는 비용과 프록시 요금(vCPU-시간당 / Aurora serverless는 ACU-시간당, **10분 최소**)을 비교.
- **"반복 읽기로 DB CPU가 높다"** → ElastiCache **지연 로딩**(+TTL). **DynamoDB 앞단이면 DAX**.
- **"상시 가동 캐시 노드의 비용 절감"** → **예약 노드**(+ Valkey 엔진), 접근 빈도가 낮은 데이터가 많으면 **데이터 티어링**.
- **"개발 DB를 밤·주말에 꺼 두고 싶다"** → RDS 중지. ⚠️ **최대 7일** 뒤 자동 재시작되고, **스토리지·백업·퍼블릭 IPv4는 중지 중에도 과금**.
- **"커뮤니티 EOL 버전을 계속 쓰는 중"** → **Extended Support** 추가 과금(vCPU-시간 단위, Multi-AZ 대기에도 부과). 표준 지원 버전으로 업그레이드하면 멈춤.
- **"안 쓰는 DB·미사용 예약을 찾아야 한다"** → **Trusted Advisor**(유휴 DB 인스턴스·예약 최적화) + **Compute Optimizer**(RDS 권고) + **Budgets RI 사용률** 알림.
- **Multi-AZ 비용 주의**: 대기 인스턴스와 스토리지가 함께 붙어 Single-AZ의 **약 2배**. 비프로덕션에 기본값으로 켜 두면 그대로 낭비.
- **"읽기 복제본으로 비용을 줄인다"** → ⚠️ 복제본은 **같은 요율의 별도 인스턴스**입니다. 주 인스턴스 다운사이즈 절감이 복제본 요금보다 **커야** 이득.
- **"Aurora의 I/O 요금이 크다"** → I/O 지출이 전체 Aurora 지출의 **25% 초과**면 **I/O-Optimized**(최대 40% 절감). ⚠️ Standard → I/O-Optimized 전환은 **30일에 한 번**.
- **"DynamoDB 저장 비용이 총비용의 절반 이상"** → **Standard-IA** 테이블 클래스(저장 60%↓). ⚠️ 처리량 단가는 Standard보다 **높음**.
- **"DynamoDB 처리량에 약정 할인"** → **예약 용량**(프로비저닝 전용) 또는 **Database Savings Plans**. ⚠️ 같은 워크로드에 **병용 불가**.
- **"DynamoDB를 특정 시점으로 복구"** → **PITR** — 켜 둔 동안 **GB-월 과금**.
- **"Aurora 백업 비용이 걱정"** → 클러스터 총 Aurora 스토리지의 **100%까지 무료**. 보존 기간 **밖** 수동 스냅샷과 **스냅샷 복사본**부터 과금.
- **"분석 질의가 간헐적"** → **Redshift Serverless**(RPU-시간, **최소 60초**).

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"가장 싸면 정답이다."** → 오답. 비용 문제는 "요구를 충족하는 것들 중 가장 저렴한 것"입니다. HA·성능 SLA를 깨는 선택은 무조건 탈락입니다.
   (원리: §1 — 워크로드에 맞는 DB를 고르면 더 작은 인스턴스와 단순한 운영으로 같은 부하를 처리할 수 있어 인스턴스·운영 비용이 함께 줄어든다.)

2. **"Aurora serverless는 항상 무료에 가깝다."** → 최솟값 ACU를 0으로 설정하지 않으면 유휴 상태에서도 최솟값만큼 과금됩니다. 개발 환경에서는 자동 일시정지(Pause) 설정을 확인하세요.
   (원리: §4 — Aurora serverless는 공유 스토리지 위에서 컴퓨팅을 동적으로 조정하도록 설계되어 최솟값 아래로는 축소되지 않는다.)

3. **"DynamoDB 온디맨드가 항상 저렴하다."** → 트래픽이 예측 가능하고 대량이면 프로비저닝 모드가 더 저렴합니다. 온디맨드는 단가가 더 높고, 높은 트래픽이 지속되면 비용이 역전됩니다.
   (원리: §4 본문 — 온디맨드는 요청 단위 과금으로 미사용 비용이 없지만 단가가 높아, 예측 가능·안정적 트래픽에서는 프로비저닝 총비용이 더 유리하다.)

4. **"RDS 스토리지를 줄이면 비용이 바로 절감된다."** → RDS 스토리지는 자동 확장 후 수동 다운사이즈가 불가입니다. 처음부터 과잉 프로비저닝하지 않는 것이 중요합니다.
   (원리: §3 — 블록 스토리지 특성상 확장 후 축소는 데이터 이전 작업이 필요해 관리형 기능으로 제공되지 않는다.)

5. **"ElastiCache를 추가하면 비용이 오른다."** → ElastiCache 추가 비용이 발생하지만, DB 인스턴스를 다운사이즈하거나 읽기 복제본을 줄이면 순비용은 절감될 수 있습니다. 트레이드오프를 계산해야 합니다.
   (원리: §3 본문 — 읽기 부하를 Read Replica나 ElastiCache로 분산하면 Primary 인스턴스를 더 작은 클래스로 유지할 수 있다.)

6. **"Compute Savings Plans가 RDS에도 적용된다."** → Compute Savings Plans와 EC2 Instance Savings Plans는 RDS에 적용되지 않습니다. 다만 **Database Savings Plans**(Aurora·RDS·DynamoDB·ElastiCache·DocumentDB 등, 최대 35%)가 따로 있으므로 "DB 절감은 RI뿐"은 더 이상 맞지 않습니다.
   (원리: §2 — 약정 할인은 "무엇을 고정하느냐"로 갈린다. RI는 구성(엔진·클래스 타입·리전)을 고정해 깊은 할인을, Database SP는 금액을 고정해 서비스·엔진 간 이동 유연성을 준다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 스타트업이 신규 서비스를 출시했습니다. 트래픽이 얼마나 될지 예측하기 어렵고, 관계형 스키마가 필요합니다. 비용을 최소화하면서 운영 부담도 줄이려면 어떤 DB를 선택해야 하나요?

<details><summary>정답 보기</summary>

**Aurora serverless**입니다. 관계형 스키마(MySQL/PostgreSQL 호환)를 유지하면서, ACU 단위로 트래픽에 따라 자동 스케일합니다. 유휴 시 최솟값 ACU만 과금되므로 예측 불가 워크로드에서 비용 효율적입니다. 미리 인스턴스 클래스를 정하지 않아도 되므로 운영 부담도 줄어듭니다.
</details>

**Q2.** 전자상거래 회사가 RDS MySQL 인스턴스를 3년간 안정적으로 운영할 계획입니다. 비용을 최대한 줄이려면 어떤 구매 옵션을 선택해야 하나요?

<details><summary>정답 보기</summary>

**3년 All Upfront 예약 인스턴스(Reserved Instance)**입니다. On-Demand 대비 약 60% 할인을 받을 수 있습니다. 워크로드가 안정적이고 3년간 변동이 없다는 전제 하에 가장 큰 절감 효과를 제공합니다. 단, 인스턴스 클래스·엔진·리전이 변경되면 RI가 적용되지 않을 수 있으므로 주의가 필요합니다.
</details>

**Q3.** SNS 소셜 앱의 DynamoDB 테이블이 있습니다. 평일 낮에는 초당 수십만 건의 요청이 발생하지만, 야간과 주말에는 거의 트래픽이 없습니다. 어떤 용량 모드가 더 비용 효율적인가요?

<details><summary>정답 보기</summary>

**온디맨드 모드**입니다. 트래픽이 없는 야간·주말에는 비용이 발생하지 않고, 급증 시 자동으로 대응합니다. 만약 야간·주말 트래픽이 완전히 0이 아니고 프로비저닝+Auto Scaling으로 최솟값을 낮게 잡을 수 있다면 프로비저닝이 더 유리할 수 있습니다 — 정확한 판단은 실제 트래픽 패턴과 단가를 비교해야 합니다.
</details>

**Q4.** 웹 앱의 RDS 인스턴스 CPU 사용률이 주로 읽기 쿼리로 인해 높습니다. 인스턴스를 업그레이드하지 않고 비용 효율적으로 해결하려면 어떤 방법이 있나요?

<details><summary>정답 보기</summary>

두 가지 방법이 있습니다. 첫째, **Read Replica**를 추가해 읽기 트래픽을 분산합니다. 애플리케이션에서 읽기를 Replica 엔드포인트로 라우팅하면 Primary 인스턴스 부하가 줄어 더 작은 인스턴스로 운영하거나 업그레이드를 미룰 수 있습니다. 둘째, **ElastiCache(Redis)**를 앞단에 두어 반복 조회 결과를 캐시합니다. 캐시 적중 시 DB 쿼리 자체가 발생하지 않아 DB 부하를 크게 줄일 수 있습니다. 두 방법은 함께 사용할 수도 있습니다.
</details>

**Q5 (원리).** 왜 RDS 예약 인스턴스는 Compute Savings Plans처럼 엔진이나 인스턴스 클래스가 바뀌어도 자동으로 적용되지 않을까요?

<details><summary>정답 보기</summary>

RDS RI는 인스턴스 클래스·엔진·리전·Multi-AZ 여부의 특정 조합에 결부된 청구 할인 약정이라, 실제 사용 구성이 약정 구성과 일치할 때만 할인이 자동 적용됩니다. Compute Savings Plans는 EC2·Fargate·Lambda의 컴퓨팅 사용량 총액에 대한 약정이라 서비스·인스턴스 유형과 무관하게 적용되는 반면, RDS RI는 약정한 범주(엔진·클래스 타입·리전)를 벗어나면 할인이 적용되지 않습니다 — 크기와 Single/Multi-AZ는 사이즈 유연성으로 흡수되지만, 클래스 타입이나 엔진이 바뀌면 온디맨드 요율로 돌아갑니다(SQL Server·Oracle License Included는 사이즈 유연성도 없습니다). DB 사용량 전체에 금액으로 약정하고 싶다면 **Database Savings Plans**가 그 역할을 합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Aurora serverless — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html
2. DynamoDB 읽기/쓰기 용량 모드 — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html
3. AWS 데이터베이스 서비스 개요 — https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html
4. RDS 예약 DB 인스턴스(사이즈 유연성 대상 엔진·Multi-AZ 적용·스토리지 미할인) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html
5. Savings Plans 유형(Database Savings Plans) — https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html
6. Timestream for LiveAnalytics 가용성 변경(2025-06-20 신규 고객 불가) — https://docs.aws.amazon.com/timestream/latest/developerguide/AmazonTimestreamForLiveAnalytics-availability-change.html
7. RDS 백업 소개(리전 단위 백업 스토리지 합계) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.html
8. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
9. AWS DMS 요금("The AWS Schema Conversion Tool incurs no cost", 복제 인스턴스 + 추가 로그 스토리지, DMS 인바운드·같은 AZ 전송 무료) — https://aws.amazon.com/dms/pricing/
10. Amazon Timestream — What is?(LiveAnalytics 대신 "consider Amazon Timestream for InfluxDB") — https://docs.aws.amazon.com/timestream/latest/developerguide/what-is-timestream.html
11. Amazon Redshift 요금(컴퓨트와 관리형 스토리지 독립 과금·리더 노드 무료·Serverless RPU-시간) — https://aws.amazon.com/redshift/pricing/
12. MySQL vs PostgreSQL 비교(읽기 빈번 vs 쓰기 빈번·객체-관계형·ACID) — https://aws.amazon.com/compare/the-difference-between-mysql-vs-postgresql/
13. 상용 엔진 → 오픈소스 전환의 라이선스 절감 관점 — https://docs.aws.amazon.com/prescriptive-guidance/latest/optimize-costs-microsoft-workloads/right-size-selection.html
14. RDS Proxy 요금(대상 인스턴스 용량 기준 · vCPU-시간당 / Aurora serverless는 ACU-시간당 · 초 단위 10분 최소) — https://aws.amazon.com/rds/proxy/pricing/
15. RDS 중지(최대 7일 후 자동 재시작 · 중지 중 인스턴스 시간 미과금 · 스토리지·백업·퍼블릭 IPv4는 과금) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_StopInstance.html · https://repost.aws/knowledge-center/rds-stop-seven-days
16. Multi-AZ 비용(대기 인스턴스·스토리지로 약 2배) — https://aws.amazon.com/rds/features/multi-az/ · https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_OnDemandDBInstances.html
17. RDS Extended Support 과금(vCPU-시간 단위 · Aurora serverless는 ACU-시간 · Multi-AZ 대기도 과금 · 연차에 따라 상승) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/extended-support-charges.html
18. Trusted Advisor DB 비용 점검(유휴 DB 인스턴스·RDS/ElastiCache/Redshift/OpenSearch 예약 최적화) — https://docs.aws.amazon.com/compute-optimizer/latest/ug/supported-resources.html
19. AWS Budgets RI 알림이 EC2·RDS·Redshift·ElastiCache 예약을 지원 — https://docs.aws.amazon.com/whitepapers/latest/aws-overview/aws-cost-management.html
20. Aurora 스토리지 구성(I/O-Optimized는 읽기·쓰기 I/O 요금 없음 · **I/O 지출이 전체의 25% 초과 시 최대 40% 절감**) — https://aws.amazon.com/rds/aurora/pricing/
21. RDS 교차 리전 읽기 복제본(리전 간 데이터 전송 과금) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.XRgn.html
22. Aurora 백업 보존(클러스터 총 Aurora 스토리지의 **100%까지 무료** · 보존 기간 밖 수동 스냅샷 · 스냅샷 **복사본은 항상 과금**) — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.Retaining.html
23. RDS 백업 무료 범위(계정·리전 전체의 프로비저닝 DB 스토리지 합계 · 증분 백업) — https://aws.amazon.com/rds/faqs/
24. DynamoDB 요금(예약 용량 1년 최대 54%·3년 최대 77% · Standard-IA 저장 비용 60% 절감) — https://aws.amazon.com/dynamodb/pricing/
25. DynamoDB 백업·복원 과금(PITR·온디맨드 백업·복원) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/backup-restore-billing.html
26. DynamoDB 용량 모드(**평균 활용률 35% 미만이면 온디맨드가 저렴**) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html

> 📝 **2026-10-24 보강 — 갭 배치 B10a-2(`G-4.3-06`·`07`·`08`·`10`)**: 기존 절 4곳을 깊게 했습니다. ① **§3 읽기 복제본** — 복제본은 **표준 인스턴스와 같은 요율의 별도 인스턴스**라 "주 인스턴스 다운사이즈 절감 > 복제본 요금"이어야 이득이고, **교차 리전 복제본**은 전송이 더 붙으며 MySQL·MariaDB의 **연쇄** 구성으로 전송을 줄일 수 있습니다. ⚠️ Multi-AZ 대기는 읽기를 처리하지 않아 수단이 갈립니다(근거 22번). ② **§3 Aurora 스토리지 구성** — **I/O 지출 25%** 기준과 **최대 40% 절감**, ⚠️ 전환은 **방향마다 제약이 다릅니다**(I/O-Optimized → Standard는 언제든 / Standard → I/O-Optimized는 **30일에 한 번**)(근거 21번). ③ **§4** — 모드 선택의 **정량 기준(평균 활용률 35%)**으로 "기본 권장은 온디맨드"라는 과잉 일반화를 대체하고(근거 27번), **예약 용량·Standard-IA·TTL로 만료·Database SP** 절감 표와 **Redshift Serverless(최소 60초)·ElastiCache Serverless**를 더했습니다(근거 25번). ④ **§5** — 백업이 **증분**이라는 점, **Aurora는 클러스터 총 스토리지의 100%까지 무료**이고 보존 기간 밖 수동 스냅샷·**복사본은 항상 과금**, **DynamoDB PITR·온디맨드 백업·복원**, **AWS Backup** 일원화를 넣었습니다(근거 23·24·26번). ⑤ ⚠️ **작업 중 자기 정정 2건**: `최대 40% 절감`을 블로그 전용으로 보고 금지했다가 **요금 페이지 본문에서 확인**해 금지를 걷고 요구로 바꿨고, I/O-Optimized **전환 방향을 반대로 적었다가** 바로잡았습니다. 가드는 `test/saa_gaps_b10a2_test.dart`.

> 📝 **2026-10-24 보강 — 갭 배치 B10a-1(`G-4.3-02`·`04`·`05`·`09`·`11`)**: 문서에 없던 5개 주제를 **신규 절 3개**로 넣었습니다. ① **§8 엔진·라이선스** — MySQL(읽기 빈번)·PostgreSQL(객체-관계형·쓰기 빈번) 비교와 **License Included vs BYOL**, **상용 엔진에서 오픈소스**로 가는 절감 축(근거 13·14번). ② **§9 연결·캐싱** — **RDS Proxy** 과금(대상 용량 기준 vCPU-시간당 / Aurora serverless는 **ACU-시간당** · 초 단위 **10분 최소**)과 "인스턴스를 키우는 비용과 비교"라는 판단 축, **지연 로딩·쓰기 시 갱신·TTL** 캐싱 전략, **DAX**(DynamoDB 전용), **Valkey·예약 노드·데이터 티어링** 비용 레버(근거 15번). ③ **§10 끄고·낮추고·찾기** — RDS 중지의 **최대 7일** 한도와 ⚠️ **스토리지·백업·퍼블릭 IPv4는 중지 중에도 과금**, Multi-AZ **약 2배**, **Extended Support**(vCPU-시간 단위·Multi-AZ 대기에도 부과·연차 상승), **Trusted Advisor 유휴 DB·예약 최적화 / Compute Optimizer RDS 권고 / Budgets RI 사용률 알림**(근거 16·17·18·19·20번). ④ **쓰지 않은 것**: Extended Support **vCPU-시간 단가**(리전·연차 의존) · 상용 엔진 전환의 **사례 절감률** · Valkey **33%·20%**와 캐시 도입 **55%·80배**(모두 블로그 전용 근거 — NLB 25%를 뺀 B9b-2와 같은 기준). 가드는 `test/saa_gaps_b10a1_test.dart`.

> 📝 **2026-10-19 정정**: ① "DB 절감은 RDS RI로만"을 고쳤습니다 — **Database Savings Plans**가 Aurora·RDS·DynamoDB·ElastiCache 등에 적용됩니다(근거 6번). ② RDS RI의 **사이즈 유연성**(대상 엔진, SQL Server·Oracle LI 예외, Single/Multi-AZ 적용, 인스턴스 시간만 할인)을 반영했습니다(근거 5번). ③ Timestream 칸을 **LiveAnalytics 신규 고객 불가 → InfluxDB**로 고치고 근거 없는 "1/10 비용"을 삭제했습니다(근거 7번). ④ 백업 스토리지 과금 기준을 **리전 전체 합계**로 바로잡았습니다(근거 8번). ⑤ **Aurora serverless** 명칭으로 통일했습니다.

> 📝 **2026-10-20 보강**: 공식 가이드 Task 4.3 Knowledge 「DB 마이그레이션」·「시계열·열 기반 DB」에 대응하는 서술이 없어 **§6·§7**을 신설했습니다(근거 10~12번). 과금 축만 적고 **열 기반 DB 사이의 비용 우열은 단정하지 않았습니다** — 공식 비교 기준 문장을 확보하지 못했습니다(`99-gaps.md` V-74).
