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
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-reserved-instances.html
  - title: Aurora Serverless v2 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html
  - title: DynamoDB 읽기/쓰기 용량 모드 (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html
  - title: AWS 데이터베이스 서비스 개요 (공식 화이트페이퍼)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
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
- [ ] **서버리스·온디맨드 옵션** — Aurora Serverless v2(ACU)와 DynamoDB 온디맨드/프로비저닝 모드를 언제 선택하는지 안다
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
| **절감 약정** | Savings Plans | EC2·Lambda 사용량에 대해 일정 금액을 1~3년 약정해 할인받는 옵션 — RDS에는 적용되지 않음 |
| **온라인 트랜잭션 처리** | OLTP (Online Transaction Processing) | 다수의 짧은 읽기·쓰기 트랜잭션을 빠르게 처리하는 워크로드 유형 — 관계형 DB가 전통적으로 담당하는 패턴 |

---

## 📖 핵심 개념

### 1) 워크로드별 DB 서비스 선택과 비용

> 목적에 맞는 DB(purpose-built database)를 고르는 것 자체가 비용 최적화의 출발점입니다. 범용 관계형 DB로 모든 것을 처리하면 불필요한 스케일업 비용이 발생합니다.

**워크로드별 AWS DB 선택 + 비용 비교**

| 워크로드 유형 | 적합한 서비스 | 비용 특성 | 피해야 할 선택(과비용) |
|---|---|---|---|
| OLTP 관계형 (예측 가능한 부하) | RDS (MySQL/PostgreSQL) | 예약 인스턴스로 최대 60% 절감 | EC2 자체 관리(운영 인건비 추가) |
| OLTP 관계형 (가변·고가용성) | Aurora (프로비저닝) | 스토리지 자동 확장, I/O 비용 별도 | 과스펙 Multi-AZ RDS |
| 관계형·불규칙 부하 | Aurora Serverless v2 | ACU 단위 초당 과금, 유휴 시 최소 비용 | 상시 프로비저닝 인스턴스 |
| 대규모 key-value / 서버리스 앱 | DynamoDB | 온디맨드(예측 불가) / 프로비저닝(예측 가능) | RDS over-provision |
| 읽기 캐싱·세션 저장 | ElastiCache (Redis/Memcached) | RDS 읽기 부하 감소 → 인스턴스 다운사이즈 가능 | 읽기 복제본만 무한 추가 |
| 시계열·IoT 데이터 | Amazon Timestream | 관계형 DB 대비 1/10 비용 | RDS에 시계열 저장 |
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

### 2) RDS 예약 인스턴스 — 예측 가능한 부하의 비용 절감

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

> RI는 **인스턴스 클래스·엔진·리전·Multi-AZ 여부**에 따라 별도로 구매합니다. 워크로드 변화가 예상되면 1년 RI + Partial Upfront가 유연성과 절감의 균형점입니다.

> 🧠 원리: 왜 RDS RI는 인스턴스 클래스·엔진·리전 조합에 묶여 있을까요?
> RDS RI는 물리 서버를 예약하는 것이 아니라, 특정 구성 속성(엔진·클래스·리전·Multi-AZ)에 결부된 청구 할인 약정입니다. 할인은 실제 사용 구성이 약정한 구성과 일치할 때만 자동 적용됩니다.
> 이 구조 때문에 워크로드가 변경되어 인스턴스 클래스를 바꾸거나 리전을 이동하면 기존 RI가 적용되지 않아 낭비가 생길 수 있습니다.
> 따라서 RI 구매 전에 워크로드의 안정성을 충분히 검토하는 것이 비용 절감을 실현하는 전제 조건입니다.

---

### 3) 용량 계획 — 스토리지·인스턴스 rightsizing

**스토리지 자동 확장 (Storage Auto Scaling)**

RDS와 Aurora 모두 스토리지 자동 확장을 지원합니다. 사전에 과잉 프로비저닝하지 않고 실제 사용량에 맞게 확장되므로 낭비를 줄입니다.

- RDS: 설정한 최대 스토리지 임계치까지 자동 확장. 수동 다운사이즈는 불가이므로 최대치 설정이 비용 상한선이 됩니다.
- Aurora: 10GB 단위로 자동 확장, 최대 256TiB(2025년 상향 — 구버전 엔진 128TiB). 미사용 스토리지는 반환. 데이터 삭제 후 공간이 회수됩니다.

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

> 🧠 원리: 왜 RDS 스토리지는 자동 확장 후 다운사이즈가 불가능할까요?
> RDS 스토리지는 블록 스토리지(EBS) 위에서 동작하는데, 블록 스토리지는 볼륨 확장 후 기존 데이터의 레이아웃과 파일시스템 경계가 변경되어 축소 작업이 데이터 무결성을 위협합니다.
> 축소를 지원하려면 데이터를 새 볼륨으로 모두 이전하는 대규모 작업이 필요하고, 이 과정에서 운영 중인 DB가 일시 중단될 위험이 있어 AWS는 이를 관리형 기능으로 제공하지 않습니다.
> 이 제약이 "처음부터 필요한 크기를 정확히 잡거나 자동 확장 최대치를 신중히 설정하라"는 운영 권고의 기술적 근거입니다.

---

### 4) 서버리스·온디맨드 옵션

**Aurora Serverless v2**

| 항목 | 내용 |
|---|---|
| 스케일 단위 | ACU(Aurora Capacity Unit) — 0.5 ACU 단위로 미세 조정 |
| 청구 방식 | 실제 사용 ACU × 초당 과금. 유휴 시 최솟값(0.5 ACU)만 과금 |
| 최솟값 | 0 ACU(자동 일시정지, 별도 설정 필요) ~ 설정한 최솟값 |
| 지원 엔진 | Aurora MySQL, Aurora PostgreSQL |
| 적합한 워크로드 | 트래픽이 불규칙하거나 간헐적인 앱, 개발·테스트 환경, 신규 앱 용량 예측 불가 상황 |
| 장점 | 관계형 DB 기능(트랜잭션·복잡한 쿼리)을 유지하면서 서버리스 비용 모델 적용 |

> Aurora Serverless v2는 0.5 ACU 단위로 스케일되므로 프로비저닝 클러스터처럼 인스턴스 클래스 전체를 업그레이드할 필요가 없습니다. 처리량이 증가할 때 부분적으로만 용량이 추가됩니다.

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

> DynamoDB 기본 권장은 **온디맨드 모드**입니다. 트래픽이 안정적이고 예측 가능한 경우에만 프로비저닝+Auto Scaling으로 비용을 낮춥니다.

> 🧠 원리: 왜 Aurora Serverless v2는 인스턴스 클래스 전체를 교체하지 않고 0.5 ACU 단위로 조금씩 스케일할 수 있을까요?
> 전통적인 프로비저닝 인스턴스는 CPU·메모리가 고정된 서버 단위로 운영되기 때문에 용량을 늘리려면 다음 단계 인스턴스 클래스로 전환해야 합니다.
> Aurora Serverless v2는 Aurora의 공유 스토리지 아키텍처 위에서 컴퓨팅 용량을 동적으로 조정하도록 설계되어, 서버 교체 없이 할당된 CPU·메모리 비율을 세밀하게 변경할 수 있습니다.
> 이 덕분에 트래픽이 조금씩 증가할 때도 용량이 그에 맞게 부분적으로만 추가되어, 과잉 프로비저닝 없이 필요한 만큼만 비용이 발생합니다.

---

### 5) 데이터 수명주기 — 백업 보존 비용

| 항목 | 내용 |
|---|---|
| RDS 자동 백업 보존 기간 | 0~35일 설정 가능. 0으로 설정 시 자동 백업 비활성화(스냅샷은 수동 유지) |
| 백업 스토리지 비용 | 프로비저닝 스토리지 크기까지는 무료(RDS 기본 제공 범위). 초과분은 GB당 요금 |
| 스냅샷 보존 | 수동 스냅샷은 삭제 전까지 보존·과금. 불필요한 스냅샷은 주기적으로 삭제 권장 |
| Aurora 백업 | Aurora는 자동으로 연속 백업(S3) — 보존 기간 설정이 비용에 직접 영향 |
| 교차 리전 복사 | 스냅샷 교차 리전 복사 시 대상 리전 스토리지 요금 별도 발생 |

> 프로덕션에서는 규정상 최소 보존 기간을 충족하되, 보존 기간을 필요 이상 길게 설정하면 스토리지 비용이 누적됩니다.

> 🧠 원리: 왜 수동 스냅샷은 RDS 인스턴스를 삭제해도 자동으로 사라지지 않을까요?
> 자동 백업은 인스턴스의 수명과 연동되어 인스턴스 삭제 시 함께 제거되는 반면, 수동 스냅샷은 사용자가 명시적으로 생성한 시점 복사본으로 인스턴스와 독립된 수명을 가집니다.
> 이 분리 설계는 인스턴스를 잠깐 내렸다가 다시 복구하거나 다른 리전에 복원하는 시나리오를 지원하기 위한 것입니다.
> 결과적으로 불필요한 수동 스냅샷을 주기적으로 삭제하지 않으면 인스턴스가 없어도 스토리지 비용이 계속 발생할 수 있습니다.

---

## ✍️ 시험 포인트

- **"예측 불가 트래픽 + 관계형 DB"** → Aurora Serverless v2. DynamoDB는 NoSQL이므로 관계형 스키마 요구 시 부적합.
- **"예측 불가 트래픽 + NoSQL"** → DynamoDB 온디맨드 모드.
- **"안정적·예측 가능 + NoSQL"** → DynamoDB 프로비저닝 + Auto Scaling. 동일 처리량 기준 온디맨드보다 저렴.
- **"상시 실행 RDS + 비용 절감"** → 예약 인스턴스(RI). All Upfront 3년이 최대 절감.
- **"읽기 부하 증가 + 비용 최소화"** → Read Replica 또는 ElastiCache로 분산 → Primary 인스턴스 다운사이즈.
- **"minimal operational overhead"** → 관리형 서비스(RDS/Aurora/DynamoDB). EC2 위 자체 설치는 운영 부담·비용 증가.
- **"개발·테스트 환경 + 비용 최소화"** → Aurora Serverless v2(최솟값 설정) 또는 DynamoDB 온디맨드.
- **RDS RI vs EC2 RI 혼동 주의**: RDS RI는 인스턴스 클래스·엔진·Multi-AZ 조합으로 구매. Savings Plans는 RDS에 적용되지 않습니다(Compute/EC2 Savings Plans는 RDS 미적용).

---

## ⚠️ 흔한 함정

1. **"가장 싸면 정답이다."** → 오답. 비용 문제는 "요구를 충족하는 것들 중 가장 저렴한 것"입니다. HA·성능 SLA를 깨는 선택은 무조건 탈락입니다.
   *(원리: §1 — 워크로드에 맞는 DB를 고르면 더 작은 인스턴스와 단순한 운영으로 같은 부하를 처리할 수 있어 인스턴스·운영 비용이 함께 줄어든다.)*

2. **"Aurora Serverless v2는 항상 무료에 가깝다."** → 최솟값 ACU를 0으로 설정하지 않으면 유휴 상태에서도 최솟값만큼 과금됩니다. 개발 환경에서는 자동 일시정지(Pause) 설정을 확인하세요.
   *(원리: §4 — Aurora Serverless v2는 공유 스토리지 위에서 컴퓨팅을 동적으로 조정하도록 설계되어 최솟값 아래로는 축소되지 않는다.)*

3. **"DynamoDB 온디맨드가 항상 저렴하다."** → 트래픽이 예측 가능하고 대량이면 프로비저닝 모드가 더 저렴합니다. 온디맨드는 단가가 더 높고, 높은 트래픽이 지속되면 비용이 역전됩니다.
   *(원리: §4 본문 — 온디맨드는 요청 단위 과금으로 미사용 비용이 없지만 단가가 높아, 예측 가능·안정적 트래픽에서는 프로비저닝 총비용이 더 유리하다.)*

4. **"RDS 스토리지를 줄이면 비용이 바로 절감된다."** → RDS 스토리지는 자동 확장 후 수동 다운사이즈가 불가입니다. 처음부터 과잉 프로비저닝하지 않는 것이 중요합니다.
   *(원리: §3 — 블록 스토리지 특성상 확장 후 축소는 데이터 이전 작업이 필요해 관리형 기능으로 제공되지 않는다.)*

5. **"ElastiCache를 추가하면 비용이 오른다."** → ElastiCache 추가 비용이 발생하지만, DB 인스턴스를 다운사이즈하거나 읽기 복제본을 줄이면 순비용은 절감될 수 있습니다. 트레이드오프를 계산해야 합니다.
   *(원리: §3 본문 — 읽기 부하를 Read Replica나 ElastiCache로 분산하면 Primary 인스턴스를 더 작은 클래스로 유지할 수 있다.)*

6. **"Compute Savings Plans가 RDS에도 적용된다."** → Compute Savings Plans와 EC2 Instance Savings Plans는 RDS에 적용되지 않습니다. RDS 비용 절감은 RDS 예약 인스턴스로만 가능합니다.
   *(원리: §2 — RDS RI는 인스턴스 클래스·엔진·리전·Multi-AZ 조합에 묶여 있으며, 조합이 바뀌면 할인이 적용되지 않아 워크로드 안정성 확인 후 구매해야 한다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 스타트업이 신규 서비스를 출시했습니다. 트래픽이 얼마나 될지 예측하기 어렵고, 관계형 스키마가 필요합니다. 비용을 최소화하면서 운영 부담도 줄이려면 어떤 DB를 선택해야 하나요?

<details><summary>정답 보기</summary>

**Aurora Serverless v2**입니다. 관계형 스키마(MySQL/PostgreSQL 호환)를 유지하면서, ACU 단위로 트래픽에 따라 자동 스케일합니다. 유휴 시 최솟값 ACU만 과금되므로 예측 불가 워크로드에서 비용 효율적입니다. 미리 인스턴스 클래스를 정하지 않아도 되므로 운영 부담도 줄어듭니다.
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

RDS RI는 인스턴스 클래스·엔진·리전·Multi-AZ 여부의 특정 조합에 결부된 청구 할인 약정이라, 실제 사용 구성이 약정 구성과 일치할 때만 할인이 자동 적용됩니다. Compute Savings Plans는 EC2·Fargate·Lambda의 컴퓨팅 사용량 총액에 대한 약정이라 서비스·인스턴스 유형과 무관하게 적용되는 반면, RDS RI는 구성 속성이 하나라도 달라지면 할인이 적용되지 않습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon RDS 예약 인스턴스 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-reserved-instances.html
2. Aurora Serverless v2 — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html
3. DynamoDB 읽기/쓰기 용량 모드 — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html
4. AWS 데이터베이스 서비스 개요 — https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
