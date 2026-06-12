---
examGuideTaskId: saa-t3-5
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: RDS·Aurora 고성능 — Multi-AZ·Read Replica·프록시
coversTasks:
  - "3.3"
sources:
  - title: Amazon RDS — 소개 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html
  - title: RDS 읽기 복제본 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html
  - title: Amazon Aurora 개요 (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html
  - title: Amazon RDS Proxy (공식)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
---

# RDS·Aurora 고성능 — Multi-AZ·Read Replica·프록시

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.3 고성능 데이터베이스 솔루션 결정** (`saa-t3-5`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 관계형 DB 고가용성과 읽기 확장 구분은 시험 단골 출제입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.3의 Skill 항목 기반)

- [ ] **RDS 지원 엔진** — MySQL·PostgreSQL·MariaDB·Oracle·SQL Server 각각의 위치를 안다
- [ ] **Multi-AZ 목적** — 동기 복제·자동 페일오버·가용성(HA)의 의미를 설명할 수 있다
- [ ] **Read Replica 목적** — 비동기 복제·읽기 확장·교차 리전·최대 개수를 설명할 수 있다
- [ ] **Multi-AZ vs Read Replica 구분** — 목적·복제 방식·읽기 가능 여부를 비교 설명할 수 있다
- [ ] **Aurora 차별점** — 클라우드 네이티브 스토리지(3 AZ·6벌 복제)·15개 복제본·글로벌 DB·Serverless v2를 설명할 수 있다
- [ ] **RDS Proxy 필요 상황** — Lambda 연결 풀링·페일오버 단축 시나리오를 안다
- [ ] **스토리지 타입 선택** — 범용 SSD vs Provisioned IOPS 적합 워크로드를 구분할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)에서 DB 관련 시나리오 비중이 높습니다. "DB 장애 대응 vs 읽기 부하 분산"은 **시험 최빈출 비교** 중 하나입니다.
- Multi-AZ와 Read Replica는 이름에서 오해를 유발합니다. Multi-AZ는 읽기 확장이 아니고, Read Replica는 자동 페일오버가 아닙니다. 둘을 혼동하면 바로 오답입니다.
- Aurora는 RDS의 확장이지만 스토리지 구조·복제·페일오버 속도가 근본적으로 다릅니다. Aurora Global Database와 Serverless v2는 시험 시나리오에 자주 등장합니다.
- RDS Proxy는 Lambda + RDS 조합에서 연결 고갈 문제를 해결하는 패턴으로 단독 출제됩니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **완전 관리형** | Fully Managed | 인프라 프로비저닝·패치·백업 등 운영 작업을 AWS가 대신 처리하는 서비스 유형 |
| **고가용성** | High Availability (HA) | 장애가 발생해도 서비스가 중단 없이 계속 운영될 수 있는 설계 속성 |
| **가용성 영역** | Availability Zone (AZ) | 하나의 AWS 리전 안에서 전력·냉각·네트워크가 독립된 데이터센터 묶음 |
| **연결 풀링** | Connection Pooling | DB 연결을 미리 만들어 두고 여러 요청이 재사용하게 하는 방식 — 연결 생성 비용과 동시 연결 수를 줄임 |
| **복제 지연** | Replication Lag | 주 DB의 변경이 복제본에 반영되기까지 걸리는 시간 차 |

---

## 📖 핵심 개념

### 1) Amazon RDS 기본

> 공식 정의: **"AWS 클라우드에서 관계형 데이터베이스를 더 쉽게 설정·운영·확장할 수 있는 웹 서비스."** 프로비저닝·패치·백업·복구·Multi-AZ를 AWS가 관리합니다.

RDS는 **완전 관리형** 서비스입니다. OS 접근·SSH·직접 패치는 사용자 영역이 아닙니다.

**지원 엔진(공식):**

| 엔진 | 특징 요약 |
|---|---|
| **MySQL** | 가장 널리 사용되는 오픈소스 RDBMS |
| **PostgreSQL** | 확장성·표준 준수 강점의 오픈소스 RDBMS |
| **MariaDB** | MySQL 포크, 오픈소스 |
| **Oracle Database** | 상용 엔터프라이즈 RDBMS |
| **Microsoft SQL Server** | 상용 Windows 생태계 RDBMS |
| **IBM Db2** | 상용 엔터프라이즈 RDBMS |

> Aurora는 RDS의 엔진 옵션이지만, 스토리지 구조가 달라 별도 섹션에서 다룹니다.

> 🧠 원리: 왜 RDS는 OS 접근이나 직접 패치를 허용하지 않을까요?
> AWS가 OS와 DB 소프트웨어를 직접 관리해야 패치 일정·보안 설정·백업 메커니즘을 일관되게 보장할 수 있습니다.
> 사용자가 OS를 임의로 변경하면 AWS가 그 상태를 전제로 동작하는 Multi-AZ 복제·자동 백업·페일오버 기능이 예기치 않게 깨질 수 있습니다.
> 이 제약이 관리 부담을 AWS에 넘기는 완전 관리형 계약의 기술적 근거이며, 이를 수용하지 못하는 경우에는 EC2에 직접 DB를 설치하는 방식을 선택하게 됩니다.

### 2) Multi-AZ — 고가용성(HA) 전용

- 다른 AZ에 **동기 복제(synchronous)** 스탠바이 인스턴스를 유지합니다.
- 주 인스턴스 장애 시 AWS가 **자동 페일오버** — DNS 엔드포인트가 스탠바이로 전환됩니다(약 1~2분).
- 스탠바이 인스턴스는 **읽기에 사용 불가**입니다(고가용성 전용).
- Multi-AZ DB 클러스터(신형) 구성에서는 리더 인스턴스가 읽기를 처리할 수 있으나, 기본 인스턴스 배포에서는 스탠바이가 읽기를 제공하지 않습니다.

> 🧠 원리: 왜 Multi-AZ 스탠바이는 읽기를 허용하지 않을까요?
> 동기 복제는 주 인스턴스의 모든 쓰기가 스탠바이에도 완료돼야 확인을 반환하므로, 스탠바이가 읽기 요청까지 처리하면 쓰기 확인 경로와 읽기 처리가 같은 자원을 경쟁합니다.
> 스탠바이를 읽기에서 격리해 두면, 페일오버 시점에 스탠바이가 주 인스턴스와 완전히 동기화된 상태임을 보장할 수 있습니다.
> 이 설계는 HA 전용이라는 단일 목적에 집중해 복잡성을 낮추는 방향으로 이어집니다.
> 읽기 확장이 필요하면 Read Replica를 별도로 추가하는 구성이 권장되는 이유입니다.

### 3) Read Replica — 읽기 확장 전용

- **비동기 복제(asynchronous)**로 주 인스턴스의 변경사항을 복제합니다.
- RDS 최대 **5개**, Aurora 최대 **15개** Read Replica를 지원합니다.
- 읽기 전용 독립 엔드포인트를 가집니다. 읽기 트래픽을 분산해 주 인스턴스 부하를 낮춥니다.
- **교차 리전(Cross-Region)** Read Replica 지원 — 글로벌 읽기 분산 및 재해 복구(DR) 활용.
- 필요 시 독립 DB 인스턴스로 **수동 승격(promote)** 가능합니다.
- 비동기 특성상 **복제 지연(lag)** 이 있어, 쓰기 직후 즉시 읽기가 필요한 워크로드에는 부적합할 수 있습니다.

> 🧠 원리: 왜 Read Replica는 비동기 복제를 사용할까요?
> 동기 복제는 모든 쓰기가 복제본의 확인을 기다려야 하므로, 복제본이 많아질수록 주 인스턴스의 쓰기 지연이 복제본 수만큼 누적됩니다.
> 비동기 복제는 주 인스턴스가 쓰기를 완료한 직후 응답을 반환하고 복제는 이후에 전달되므로, 복제본을 여러 개 추가해도 주 인스턴스 쓰기 성능에 미치는 영향이 작습니다.
> 다만 이 구조는 복제 지연 동안 복제본이 최신 데이터를 반영하지 못할 수 있어, 읽기 일관성이 중요한 워크로드에서는 복제 지연을 모니터링해야 합니다.

### 4) Multi-AZ vs Read Replica 비교 (★ 단골 출제)

| 항목 | Multi-AZ | Read Replica |
|---|---|---|
| **목적** | 고가용성(HA) | 읽기 확장(Scale-out) |
| **복제 방식** | 동기(synchronous) | 비동기(asynchronous) |
| **스탠바이/복제본 읽기** | 불가(HA 전용) | 가능(읽기 전용) |
| **페일오버** | 자동(약 1~2분) | 수동 승격 필요 |
| **교차 리전** | 불가 | 가능 |
| **최대 수량** | 1개(스탠바이) | RDS 5개, Aurora 15개 |
| **주요 활용** | 장애 내구성 | 읽기 트래픽 분산, 보고/분석 |

> 둘은 함께 사용할 수 있습니다. Multi-AZ로 가용성을 확보하고, Read Replica로 읽기를 분산하는 구성이 프로덕션 모범 사례입니다.

> 🧠 원리: 왜 Multi-AZ와 Read Replica를 하나의 기능으로 통합하지 않고 별개로 제공할까요?
> 두 기능은 해결하는 문제가 다릅니다. Multi-AZ는 AZ 장애 시 데이터를 잃지 않고 빠르게 전환하는 것이 목표이므로 동기 복제가 필요합니다.
> Read Replica는 읽기 트래픽을 여러 인스턴스에 분산하는 것이 목표이므로, 주 인스턴스 쓰기 성능을 보호하는 비동기 복제가 적합합니다.
> 동기와 비동기를 하나의 인스턴스로 혼용하면 각각의 보장 수준을 유지하기 어렵고, 목적별로 독립 운영해야 운용 규모와 비용을 워크로드에 맞게 조정할 수 있습니다.

### 5) RDS 백업

| 종류 | 특징 |
|---|---|
| **자동 백업** | 보존 기간 0~35일. **특정 시점 복구(PITR)** 가능. 삭제 시 함께 삭제 |
| **수냔샷(수동)** | 삭제 전까지 무기한 보존. **교차 리전 복사** 가능 |

### 6) RDS 스토리지 타입

| 타입 | 적합 워크로드 |
|---|---|
| **범용 SSD(gp2/gp3)** | 중간 규모, 개발·테스트, 비용 효율 중시 |
| **Provisioned IOPS SSD(io1/io2)** | I/O 집약·저지연·일관된 처리량이 필요한 프로덕션 |
| **Magnetic** | 하위 호환 전용. 신규 사용 비권장 |

> 🧠 원리: 왜 I/O 집약 워크로드에서는 범용 SSD보다 Provisioned IOPS가 필요할까요?
> 범용 SSD(gp2/gp3)는 버스트 크레딧 방식으로 순간적인 높은 처리량을 허용하지만, 크레딧이 소진되면 기준 처리량으로 되돌아가 성능이 불규칙해집니다.
> Provisioned IOPS는 요청한 IOPS를 지속적으로 제공하도록 설계되어, 트랜잭션이 밀집된 OLTP 워크로드에서 예측 가능한 낮은 지연을 유지할 수 있습니다.
> 따라서 피크 I/O가 간헐적이면 범용 SSD로 충분하지만, 높은 I/O가 지속된다면 Provisioned IOPS를 선택해야 성능 저하 없이 서비스가 가능합니다.

### 7) Amazon Aurora — 클라우드 네이티브 관계형 DB

Aurora는 MySQL·PostgreSQL 호환이지만 스토리지 구조가 근본적으로 다릅니다.

**스토리지 특성:**

- 데이터를 **3개 AZ에 6벌 복제** — 자가 치유(self-healing) 분산 스토리지.
- 스토리지 자동 확장(최대 **128TiB** — 공식 문서는 256TiB까지 지원).
- 스토리지 레이어가 컴퓨팅과 분리되어 있어 I/O 경합 없이 읽기/쓰기 처리.

**복제 및 가용성:**

- 최대 **15개** Aurora Replica — 빠른 페일오버(30초 미만), Reader/Writer 엔드포인트 분리.
- 일반 RDS Multi-AZ보다 페일오버 속도가 빠릅니다.

**Aurora 고급 기능:**

| 기능 | 설명 |
|---|---|
| **Aurora Serverless v2** | 트래픽에 따라 자동 미세 스케일. 간헐적·불규칙 워크로드, 운영 부담 최소화 |
| **Aurora Global Database** | 리전 간 복제 **1초 미만**. 글로벌 저지연 읽기 및 재해 복구(RPO~1초, RTO~1분) |
| **자동 백업 + 역추적(Backtrack)** | PITR 외에도 특정 시점으로 DB를 되감기 가능(MySQL 호환만) |

> 🧠 원리: 왜 Aurora는 스토리지 레이어를 컴퓨팅과 분리했을까요?
> 전통적인 DB 아키텍처에서는 읽기와 쓰기가 같은 디스크 I/O 대역폭을 공유하므로, 복제본이 많아질수록 스토리지 경쟁이 심해집니다.
> Aurora는 공유 분산 스토리지 레이어가 모든 컴퓨팅 노드에 동일하게 연결되어 있어, 복제본을 추가해도 스토리지 계층에 추가 부담이 생기지 않는 구조로 이어집니다.
> 이 분리 덕분에 복제본을 최대 15개까지 추가하면서도 쓰기 인스턴스의 I/O 성능에 영향을 주지 않을 수 있습니다.

### 8) Aurora vs RDS 비교

| 항목 | Amazon RDS(일반) | Amazon Aurora |
|---|---|---|
| **호환 엔진** | MySQL·PostgreSQL·MariaDB·Oracle·SQL Server·Db2 | MySQL·PostgreSQL |
| **스토리지 복제** | 단일 AZ(기본), Multi-AZ는 스탠바이 1개 | 3개 AZ에 6벌 자동 복제 |
| **최대 Read Replica** | 5개 | 15개 |
| **페일오버 시간** | 약 1~2분 | 30초 미만 |
| **스토리지 최대** | 64TiB | 128TiB(공식 256TiB) |
| **글로벌 읽기** | 교차 리전 Read Replica | Aurora Global Database(1초 미만 복제) |
| **Serverless** | 없음 | Aurora Serverless v2 |
| **비용** | 상대적으로 낮음 | 상대적으로 높음(가용성 대비) |

> 🧠 원리: 왜 Aurora Serverless v2는 간헐적·불규칙 워크로드에 더 유리할까요?
> Serverless v2는 실제 사용량에 따라 컴퓨팅 용량을 세밀하게 조정하므로, 부하가 낮은 시간대에는 그에 비례해 비용이 줄어드는 구조입니다.
> 프로비저닝 Aurora는 피크 부하에 맞게 인스턴스를 미리 할당하므로, 부하가 낮을 때도 프로비저닝된 용량만큼의 비용이 발생합니다.
> 반대로 부하가 지속적으로 높고 예측 가능한 경우에는 프로비저닝 인스턴스가 더 안정적인 성능을 제공할 수 있습니다.
> 따라서 Serverless v2는 부하가 드문드문 있거나 예측 불가한 워크로드에 더 유리한 선택이 됩니다.

### 9) RDS Proxy

> 공식 정의: **"애플리케이션이 데이터베이스 연결을 풀링·공유하여 확장 능력을 향상시킬 수 있도록 하는 완전 관리형 프록시."**

**핵심 기능:**

- **연결 풀링(Connection Pooling)** — 동시 연결 수가 많아도 DB에 대한 실제 연결 수를 제어. Lambda처럼 함수 호출마다 연결을 새로 여는 상황에서 연결 고갈 방지.
- **페일오버 단축** — RDS 또는 Aurora 장애 시 기존 애플리케이션 연결을 유지한 채 스탠바이로 자동 전환. 페일오버 시간을 단축합니다.
- **IAM 인증·Secrets Manager 연동** — 클라이언트가 프록시에 IAM으로 인증하고, 프록시가 DB에 자격증명을 전달.

**RDS Proxy가 필요한 상황:**

| 상황 | 이유 |
|---|---|
| Lambda → RDS 연결 | 함수 실행마다 새 연결 생성으로 DB 연결 고갈 위험 |
| 연결 수가 많은 마이크로서비스 | 다수의 서비스 인스턴스가 DB에 직접 연결 시 과부하 |
| 페일오버 중단 최소화 | 프록시가 연결을 유지한 채 스탠바이로 전환 |

> 🧠 원리: 왜 Lambda가 RDS에 직접 연결하면 연결 고갈이 발생할까요?
> Lambda는 함수 실행마다 새 프로세스(컨테이너)가 기동되고, 각 프로세스가 DB에 별도 연결을 맺습니다.
> 동시 Lambda 실행 수가 수백 개로 늘면 DB에 도달하는 연결 수도 그만큼 증가하여, DB 엔진이 허용하는 최대 연결 한도를 초과할 수 있습니다.
> RDS Proxy는 연결 풀을 프록시 레이어에서 관리하고 Lambda 요청은 풀의 기존 연결을 재사용하게 하므로, DB에 도달하는 실제 연결 수가 Lambda 동시 실행 수와 무관하게 제한됩니다.

---

## ✍️ 시험 포인트

| 요구사항 | 정답 |
|---|---|
| DB 장애 **자동 복구**, 다운타임 최소화 | RDS **Multi-AZ** |
| **읽기 트래픽** 급증, 읽기 부하 분산 | **Read Replica** |
| 글로벌 저지연 읽기 / 리전 재해 복구 | **Aurora Global Database** |
| 불규칙·간헐적 부하, 운영 부담 최소화 | **Aurora Serverless v2** |
| Lambda 다량 연결로 DB 연결 고갈 | **RDS Proxy** |
| 페일오버 시 애플리케이션 연결 유지 | **RDS Proxy** |
| I/O 집약 프로덕션 DB 스토리지 | **Provisioned IOPS SSD** |

- **Multi-AZ + Read Replica 동시 사용 가능** — 가용성과 읽기 확장을 함께 확보하는 구성이 프로덕션 베스트 프랙티스입니다.
- **Read Replica 교차 리전** — 원격 리전 읽기 분산 또는 DR 목적으로 사용. 단, 자동 페일오버는 없고 수동 승격 필요.
- **Aurora vs RDS 선택 기준** — 고가용성·페일오버 속도·복제 내구성이 중요하면 Aurora. 상용 엔진(Oracle·SQL Server) 또는 비용 절감이 우선이면 일반 RDS.
- **RDS Proxy는 같은 VPC 안에만** — 퍼블릭 접근 불가. Lambda가 VPC 밖에 있다면 VPC 설정 필요.

---

## ⚠️ 흔한 함정

1. **"Multi-AZ로 읽기 부하를 분산할 수 있다."** → 불가. 기본 Multi-AZ 인스턴스 배포에서 스탠바이는 읽기를 제공하지 않습니다. 읽기 확장은 Read Replica의 역할입니다.
   *(원리: §2 — 스탠바이를 읽기에서 격리해야 페일오버 시 완전 동기화 상태를 보장할 수 있고, 읽기 확장은 별도 Read Replica로 처리해야 한다.)*

2. **"Read Replica는 자동 페일오버를 제공한다."** → 아닙니다. Read Replica는 비동기 복제이며, 주 인스턴스 장애 시 자동으로 승격되지 않습니다. 수동으로 승격해야 독립 인스턴스가 됩니다.
   *(원리: §3 본문 — 비동기 복제는 쓰기 성능을 위해 복제 지연을 허용하므로, 장애 시점에 복제본이 주 인스턴스와 완전히 동기화되지 않을 수 있어 자동 승격이 아닌 수동 승격이 필요하다.)*

3. **"Aurora는 일반 RDS에 비해 비용만 높다."** → Aurora는 3 AZ 6벌 복제·30초 미만 페일오버·15개 복제본이라는 가용성을 제공합니다. 고가용성 요구사항을 계산하면 비용 대비 이점이 있습니다.
   *(원리: §7 — 스토리지를 컴퓨팅과 분리한 공유 분산 구조 덕분에 복제본을 늘려도 쓰기 성능에 영향이 작고, 이 아키텍처가 15개 복제본·빠른 페일오버를 가능하게 한다.)*

4. **"Aurora Serverless는 아무 때나 쓰면 된다."** → Serverless v2는 간헐적·예측 불가 워크로드에 최적입니다. 일정한 높은 트래픽에는 프로비저닝 Aurora가 더 저렴하고 안정적입니다.
   *(원리: §8 — Serverless v2는 사용량에 비례해 비용이 조정되므로 부하가 낮은 구간에서 유리하고, 부하가 지속적으로 높으면 프로비저닝 인스턴스가 더 안정적인 성능을 제공할 수 있다.)*

5. **"운영 중 비암호화 RDS DB를 클릭 한 번으로 암호화할 수 있다."** → 불가. 스냅샷 생성 → 암호화 복사 → 복원의 절차가 필요합니다. 암호화는 생성 시에 설정하는 것이 권장됩니다.
   *(원리: §1 본문 — 완전 관리형 서비스는 OS·스토리지 레이어를 AWS가 관리하므로, 운영 중 암호화 적용은 새 암호화 인스턴스로 데이터를 옮기는 절차가 필요하다.)*

6. **"RDS Proxy를 사용하면 DB 연결 수가 늘어난다."** → 반대입니다. 프록시가 연결을 풀링·공유하여 DB에 도달하는 실제 연결 수를 줄입니다.
   *(원리: §9 — 프록시 레이어가 연결 풀을 관리하고 Lambda 요청은 풀의 기존 연결을 재사용하므로, DB에 도달하는 실제 연결 수가 Lambda 동시 실행 수와 무관하게 제한된다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 웹 애플리케이션의 읽기 트래픽이 5배 급증했습니다. DB 쓰기는 정상이나 읽기 응답이 느려집니다. 가장 적합한 해결 방법은?

<details><summary>정답 보기</summary>

**Read Replica를 추가**하고, 읽기 트래픽을 복제본 엔드포인트로 라우팅합니다. Multi-AZ는 고가용성 목적이며 스탠바이 인스턴스가 읽기를 처리하지 않으므로 읽기 확장에 사용할 수 없습니다. Read Replica는 RDS 최대 5개, Aurora 최대 15개까지 추가할 수 있습니다.
</details>

**Q2.** 글로벌 서비스에서 아시아 사용자의 DB 읽기 지연이 높습니다. 데이터는 미국 리전에 있습니다. 가장 적합한 AWS 솔루션은?

<details><summary>정답 보기</summary>

**Aurora Global Database**를 사용합니다. 리전 간 복제를 1초 미만으로 처리하며, 아시아 리전에 읽기 전용 클러스터를 배치해 로컬 읽기 지연을 크게 줄일 수 있습니다. 일반 RDS 교차 리전 Read Replica도 가능하지만, 복제 속도와 페일오버 복잡도 면에서 Aurora Global Database가 우수합니다.
</details>

**Q3.** Lambda 함수가 RDS MySQL에 연결해 데이터를 조회합니다. 동시 Lambda 실행이 수백 개에 달하면 DB 연결 오류가 발생합니다. 해결 방법은?

<details><summary>정답 보기</summary>

**RDS Proxy**를 도입합니다. Lambda는 함수 실행마다 새 DB 연결을 생성하므로 동시 실행 수가 많으면 DB의 최대 연결 한도를 초과합니다. RDS Proxy는 연결 풀을 유지하고 Lambda의 요청을 풀에서 처리해 DB에 도달하는 실제 연결 수를 크게 줄입니다. 페일오버 시에도 프록시가 연결을 유지하므로 애플리케이션 중단이 최소화됩니다.
</details>

**Q4.** 프로덕션 RDS DB의 가용성을 높이되, 장애 시 자동으로 다운타임을 최소화해야 합니다. 어떤 기능을 사용하나요?

<details><summary>정답 보기</summary>

**Multi-AZ 배포**를 활성화합니다. 다른 AZ에 동기 복제된 스탠바이 인스턴스를 유지하며, 주 인스턴스 장애 시 AWS가 자동으로 DNS 엔드포인트를 스탠바이로 전환합니다. 애플리케이션 연결 문자열(엔드포인트)을 변경할 필요 없이 약 1~2분 내에 전환이 완료됩니다.
</details>

**Q5 (원리).** 왜 Lambda 함수에서 RDS로 직접 연결할 때 동시 실행이 증가하면 DB 연결 오류가 발생하고, RDS Proxy는 이 문제를 어떻게 구조적으로 해결하나요?

<details><summary>정답 보기</summary>

Lambda는 동시 실행마다 별도 컨테이너에서 새 DB 연결을 생성하므로, 동시 실행 수가 늘면 DB에 도달하는 연결 수도 그만큼 증가해 DB 최대 연결 한도를 초과할 수 있습니다. RDS Proxy는 연결 풀을 프록시 레이어에서 유지하고 Lambda 요청이 풀의 기존 연결을 재사용하게 하여, Lambda 동시 실행 수와 DB 실제 연결 수를 분리합니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon RDS — 소개 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html
2. RDS 읽기 복제본 — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html
3. Amazon Aurora 개요 — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html
4. Amazon RDS Proxy — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
