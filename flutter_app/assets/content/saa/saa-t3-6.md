---
examGuideTaskId: saa-t3-6
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: DynamoDB·ElastiCache — NoSQL 성능·캐싱 전략
coversTasks:
  - "3.3"
sources:
  - title: Amazon DynamoDB 개발자 안내서 — 소개 (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
  - title: DynamoDB 보조 인덱스 (GSI·LSI) (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html
  - title: DynamoDB Accelerator (DAX) (공식)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.html
  - title: Amazon ElastiCache 개발자 안내서 — What Is ElastiCache? (공식)
    url: https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.html
  - title: AWS 데이터베이스 선택 가이드(목적별 엔진) (공식)
    url: https://docs.aws.amazon.com/databases-on-aws-how-to-choose/
  - title: Amazon MemoryDB란 무엇인가(내구성 인메모리 DB) (공식)
    url: https://docs.aws.amazon.com/memorydb/latest/devguide/what-is-memorydb.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-20
---

# DynamoDB·ElastiCache — NoSQL 성능·캐싱 전략

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.3 고성능 데이터베이스 솔루션 설계** (`saa-t3-6`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. "서버리스·밀리초 지연·글로벌 쓰기"는 DynamoDB, "반복 쿼리·DB 과부하 완화"는 ElastiCache가 정답 신호입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.3의 Skill 항목 기반)

- [ ] **파티션 키 설계** — 카디널리티가 낮으면 핫 파티션이 생기는 이유를 설명할 수 있다
- [ ] **GSI vs LSI 선택** — 생성 시점·키 구성·일관성·처리량 차이를 표로 그릴 수 있다
- [ ] **용량 모드 결정** — 온디맨드와 프로비저닝(+Auto Scaling)을 워크로드 특성으로 선택할 수 있다
- [ ] **DAX·Global Tables·Streams·TTL** — 각 기능의 용도와 시험 신호어를 대응할 수 있다
- [ ] **Redis vs Memcached 선택** — 영속성·HA·자료구조·멀티스레드 기준으로 구분할 수 있다
- [ ] **Lazy Loading vs Write-Through** — 각 전략의 동작·장단점·TTL 결합 이유를 설명할 수 있다
- [ ] **DynamoDB vs RDS 선택 기준** — 스키마·조인·확장성 관점에서 선택 근거를 댈 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(24%)은 SAA의 두 번째 고비중 도메인입니다. Task 3.3은 "어떤 데이터베이스/캐시를 골라야 가장 빠른가"를 직접 묻습니다.
- DynamoDB는 서버리스·이벤트 기반 아키텍처(Lambda·API Gateway) 문제와 함께 등장하는 빈도가 높습니다.
- ElastiCache는 "DB 읽기 과부하"·"세션 공유"·"리더보드" 시나리오의 정답 후보로 반복 출제됩니다.
- 두 서비스 모두 **선택 근거**(언제 쓰고, 언제 안 쓰는지)가 핵심 — 기능 암기보다 시나리오 적용이 중요합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **카디널리티** | Cardinality | 특정 열(컬럼)이 가질 수 있는 고유값의 다양성 — 고유값이 많을수록 높다 |
| **읽기 용량 단위** | RCU (Read Capacity Unit) | DynamoDB 읽기 처리량의 단위 — 프로비저닝 모드에서 초당 읽기 능력을 수치로 지정 |
| **쓰기 용량 단위** | WCU (Write Capacity Unit) | DynamoDB 쓰기 처리량의 단위 — RCU와 함께 프로비저닝 모드의 비용·한도 기준 |
| **오래된 데이터** | Stale Data | 캐시에 저장된 후 원본 DB가 갱신됐지만 캐시에는 아직 이전 값이 남아 있는 상태 |
| **변경 데이터 캡처** | CDC (Change Data Capture) | 데이터베이스 항목의 생성·수정·삭제 이벤트를 순서대로 캡처해 후속 처리에 전달하는 패턴 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) DynamoDB 기본 구조 {#dynamodb-basics}

> 공식 정의: **"완전 관리형 서버리스 키-값·문서 NoSQL 데이터베이스. 모든 규모에서 한 자릿수 밀리초 성능을 제공합니다."**

- 스키마리스(키 외의 속성은 항목마다 다를 수 있음), 추가 인프라 관리 불필요.
- 데이터 모델: **Table → Item(행) → Attribute(열)**. 기본 키가 필수; 나머지는 선택.
- 리전 내 3개 AZ에 자동 복제 — 내구성 내장.

### 2) 기본 키(Primary Key) 설계 {#primary-key-design}

| 형태 | 구성 | 조회 방식 |
|---|---|---|
| **단순 키** | Partition Key(PK)만 | PK로만 조회 |
| **복합 키** | Partition Key + Sort Key(SK) | PK로 파티션 결정, SK로 정렬·범위 조회 |

파티션 키 설계 원칙:

- PK는 **카디널리티(고유값 다양성)가 높아야** 데이터가 여러 파티션에 고르게 분산됩니다.
- 한 PK 값에 트래픽이 집중되면 **핫 파티션** 발생 → 해당 파티션만 처리량 한도 초과 → 성능 저하.
- 핫 파티션 완화: PK에 접미사(shard 번호) 추가, 쓰기 분산 패턴 사용.

> 🧠 원리: 왜 파티션 키의 카디널리티가 낮으면 성능 문제가 생길까요?
> DynamoDB는 파티션 키 값을 해시해 데이터를 여러 물리 파티션에 분산합니다. 고유값이 적으면 같은 해시 버킷에 요청이 집중되고, 해당 파티션의 처리량 한도를 초과하는 요청은 스로틀됩니다.
> 예를 들어 `status`(active/inactive 두 값)를 PK로 쓰면 사실상 두 파티션에만 모든 트래픽이 몰려 나머지 파티션은 유휴 상태가 됩니다.
> 이 구조 때문에 PK 설계는 기능 요구사항이 아니라 트래픽 분산 관점에서 결정해야 합니다.

### 3) 보조 인덱스 — GSI vs LSI (★ 단골 출제) {#gsi-vs-lsi}

| 구분 | GSI (Global Secondary Index) | LSI (Local Secondary Index) |
|---|---|---|
| **파티션 키** | 기본 테이블과 **다른** PK 사용 가능 | 기본 테이블과 **동일한** PK 필수 |
| **정렬 키** | PK만으로도 가능, SK 선택 | 기본 테이블과 **다른** SK |
| **생성 시점** | **언제든** 추가·삭제 가능 | **테이블 생성 시에만** 추가 |
| **처리량** | 테이블과 **별도(독립)** 용량 | 테이블과 **공유** |
| **읽기 일관성** | **최종 일관성만** 지원 | **강력한 일관성** 지원 가능 |
| **용도** | 전혀 다른 접근 패턴 추가 | 같은 PK 내에서 다른 정렬 키로 조회 |

> 핵심 대비: 테이블 생성 후 인덱스를 추가해야 한다면 반드시 **GSI**. LSI는 사후 추가 불가.

> 🧠 원리: 왜 LSI는 테이블 생성 이후에 추가할 수 없을까요?
> LSI는 기본 테이블과 동일한 파티션 키를 공유하며, 이 제약으로 인해 테이블 생성 시에만 정의할 수 있고 이미 존재하는 테이블에는 추가할 수 없습니다.
> 반면 GSI는 자체 파티션 공간에 저장되고 기본 테이블과 독립적으로 확장되므로, 기존 테이블에 언제든 추가하거나 삭제할 수 있습니다.
> 즉, 파티션 키 공유 여부가 생성 시점 제약의 핵심 구분선입니다.

### 4) 읽기 일관성 {#read-consistency}

| 모드 | 설명 | 비용 |
|---|---|---|
| **최종 일관성(Eventually Consistent)** | 최근 쓰기가 즉시 반영되지 않을 수 있음. 기본값 | 낮음 |
| **강력한 일관성(Strongly Consistent)** | 요청 전 완료된 모든 쓰기 반영 보장 | RCU 2배 소비 |

LSI는 강력한 일관성 읽기를 지원하지만, GSI는 최종 일관성만 지원합니다.

> 🧠 원리: 왜 강력한 일관성 읽기는 RCU를 두 배로 소비할까요?
> DynamoDB는 같은 리전 내 여러 AZ에 데이터 복사본을 유지합니다. 최종 일관성 읽기는 어느 복사본에서 응답해도 되므로 단일 노드 조회로 처리됩니다.
> 강력한 일관성 읽기는 요청 전에 완료된 모든 쓰기가 반영된 값을 반환해야 하므로, 최신 복사본을 확인하는 추가 I/O가 발생합니다.
> 이 추가 처리 비용이 처리량 예산을 더 많이 소비하는 방식으로 설계에 반영됩니다.

### 5) 용량 모드 {#capacity-modes}

| 모드 | 동작 | 적합한 워크로드 |
|---|---|---|
| **온디맨드(On-Demand)** | AWS가 트래픽에 맞춰 자동 조정. 사용량만큼만 과금 | 트래픽 예측 불가, 스파이크, 초기 서비스 |
| **프로비저닝(Provisioned)** | RCU·WCU를 직접 지정. Auto Scaling 결합 가능 | 트래픽 예측 가능, 비용 최적화 필요 |

> RCU(Read Capacity Unit): 최종 일관성 읽기 4KB/1초당 0.5 RCU, 강력 일관성 1 RCU. WCU(Write Capacity Unit): 1KB 쓰기당 1 WCU. **트랜잭션 읽기·쓰기는 각각 2배**(4 KB까지 읽기 2 RCU, 1 KB까지 쓰기 2 WCU)를 씁니다. 온디맨드의 요청 단위(RRU·WRU)도 같은 크기 규칙을 따릅니다.

> **모드 전환에도 비대칭이 있습니다** — 프로비저닝 → 온디맨드는 **24시간 롤링 윈도에서 최대 4회**까지, 온디맨드 → 프로비저닝은 **언제든지** 가능합니다.

**용량보다 먼저 막히는 것 — 파티션 한도와 항목 크기 (★ 시험 핵심)**

| 한도 | 값 |
|---|---|
| 파티션당 읽기 | **3,000 읽기 단위/초** |
| 파티션당 쓰기 | **1,000 쓰기 단위/초** |
| 항목 최대 크기 | **400 KB** — 속성 **이름**의 바이트 길이와 값의 바이트 길이를 **모두 합한** 값입니다 |
| LSI가 있는 테이블 | 테이블 항목 데이터 + **모든 LSI의 해당 항목(키·프로젝션 속성 포함)** 합계가 400 KB |

- ⚠️ **테이블 전체 용량이 남아 있어도 한 파티션이 위 한도를 넘으면 스로틀됩니다.** 읽기와 쓰기는 파티션에서 독립적으로 관리되므로, **읽기만 스로틀되고 쓰기는 정상**일 수도 있습니다.
- 이때 스로틀 예외에 **`KeyRangeThroughputExceeded`** 이유 타입이 담겨 "핫 파티션"임을 알려 줍니다. 원인은 용량 부족이 아니라 **파티션 키 설계**입니다.
- **적응형 용량(adaptive capacity)**은 트래픽이 몰린 파티션의 처리량을 **자동·즉시** 올려 줍니다. 모든 테이블에 기본 활성이고 **추가 비용이 없으며 켜거나 끌 수 없습니다.** 단 **테이블의 총 프로비저닝 용량과 파티션 최대 용량을 넘지 못합니다** — 핫 파티션을 완화하지만 없애지는 않습니다.

**온디맨드가 "즉시" 받아 주는 양 — warm throughput**

현행 공식 문서는 온디맨드의 즉시 수용량을 **warm throughput**으로 설명합니다.

- **새 온디맨드 테이블은 읽기 12,000 단위/초 · 쓰기 4,000 단위/초**의 warm throughput으로 시작하고, 그 수준까지는 **지속 트래픽을 즉시** 받습니다.
- 그 값을 넘는 요청이 오면 warm throughput이 **자동으로 더 높은 값으로 조정**됩니다. 값 자체는 테이블·GSI가 **과거 사용량에 따라 얼마나 확장돼 있는지**를 나타내며, 모든 테이블·보조 인덱스에 기본 제공되고 무료입니다.
- 제품 출시·세일처럼 **계획된 피크**(10배·100배)가 있으면 **사전 웜업(pre-warming)**으로 값을 선제적으로 올릴 수 있습니다. 처리량 설정이나 과금 모드는 바꾸지 않습니다. ⚠️ **한 번 올린 warm throughput 값은 낮출 수 없고**, 사전 웜업 요청 자체는 과금됩니다.

> 시험 신호: "출시 당일 100배 트래픽이 예상된다 — 스로틀 없이 받으려면?" → 온디맨드로 바꾸는 것만으로는 부족하고 **사전 웜업**이 답입니다.

> 🧠 원리: 왜 온디맨드 모드는 트래픽 스파이크에 더 유연할까요?
> 프로비저닝 모드는 설정한 RCU·WCU 한도 안에서만 요청을 처리하므로, 예상보다 트래픽이 많아지면 초과 요청이 스로틀됩니다.
> 온디맨드 모드는 사전 처리량 설정 없이 AWS가 실시간 트래픽에 따라 용량을 조정하므로, 예측하기 어려운 스파이크 구간에서도 스로틀 없이 요청을 처리할 수 있습니다.
> 대신 단위 요청당 단가가 프로비저닝 모드보다 높으므로, 트래픽 패턴이 안정적이면 프로비저닝 쪽이 총비용에서 유리할 수 있습니다.

### 6) DAX (DynamoDB Accelerator) {#dax}

- DynamoDB 앞단에 배치하는 **인메모리 캐시 클러스터**. 읽기 지연을 밀리초 → **마이크로초**로 단축.
- 애플리케이션 코드 변경 최소화 — DAX 클라이언트가 DynamoDB API와 호환.
- **읽기 집약적 워크로드**(동일 항목 반복 조회)에 효과적. 강력 일관성 읽기는 DAX를 우회해 DynamoDB에 직접 요청.
- DAX는 DynamoDB 전용 캐시. ElastiCache는 더 범용적인 캐싱(RDS 등 다양한 백엔드).

> 🧠 원리: 왜 강력 일관성 읽기는 DAX를 우회해 DynamoDB에 직접 요청할까요?
> DAX는 인메모리 캐시이므로 캐시에 저장된 값은 DynamoDB에 쓰기가 완료된 직후와 미세한 시간 차가 있을 수 있습니다.
> 강력 일관성 읽기는 요청 전에 완료된 모든 쓰기가 반영된 값을 반환해야 하므로, 이 시간 차가 일관성 보장을 깨뜨립니다.
> 따라서 강력 일관성이 필요한 경우 DAX 캐시를 건너뛰고 DynamoDB 원본에 직접 조회해야 일관성 요건을 충족할 수 있습니다.

### 7) Global Tables {#global-tables}

- DynamoDB 테이블을 여러 리전에 **Active-Active**로 복제.
- 모든 리전에서 읽기와 쓰기 모두 가능 — RDS Read Replica(읽기 전용)와 다릅니다.
- 시험 신호어: "글로벌 다중 리전 쓰기", "재해 복구(DR) + 낮은 지연", "Active-Active".

**일관성 모드가 두 가지입니다 — 충돌 해결 방식이 모드에 달려 있습니다 (★ 시험 핵심)**

| 모드 | 복제 | 동작 |
|---|---|---|
| **MREC** (다중 리전 최종 일관성) | 비동기 | **기본값.** 항목 변경이 보통 **1초 내**에 다른 복제본으로 전파되고 리전 간에는 최종 일관성입니다. 충돌은 **"최후 작성자 우선(last-writer-wins)"**으로 자동 해소됩니다 |
| **MRSC** (다중 리전 강력 일관성) | **동기** | 항목 변경이 **최소 한 개의 다른 리전으로 복제된 뒤에야** 쓰기가 성공으로 반환됩니다. 어느 복제본에서든 **강력 일관성 읽기는 항상 최신 버전**을 반환합니다 |

- ⚠️ 모드를 지정하지 않으면 **MREC**가 됩니다. 하나의 글로벌 테이블 안에서 **복제본마다 다른 모드를 둘 수 없고**, **생성한 뒤에는 모드를 바꿀 수 없습니다.**
- **MRSC도 active-active**입니다 — 각 리전 테이블이 읽기·쓰기를 동등하게 받습니다.
- MRSC에서도 **최종 일관성 읽기는 최근 변경을 포함하지 않을 수 있습니다**(다른 리전의 변경은 물론, 바로 같은 리전에서 막 일어난 변경조차). 최신값이 필요하면 **강력 일관성 읽기**를 요청해야 합니다.
- 다른 리전에서 수정 중인 항목을 고치려 하면 쓰기가 **`ReplicatedWriteConflictException`**으로 실패합니다. 해당 항목이 더 이상 수정 중이 아니면 **재시도하면 성공**합니다.
- ⚠️ **MRSC는 쓰기와 강력 일관성 읽기의 지연이 높습니다** — 리전 간 통신이 필요하고, 접근 리전과 가장 가까운 참여 리전 사이의 왕복 지연만큼 늘어납니다. 최종 일관성 읽기에는 추가 지연이 없습니다.
- ⚠️ MRSC는 항목을 **개별적으로** 복제하므로 **트랜잭션 API를 지원하지 않습니다.**
- ⚠️ **MRSC 글로벌 테이블은 정확히 3개 리전에 배포해야 합니다** — **복제본 3개**, 또는 **복제본 2개 + 증인(witness) 1개**입니다. 증인은 최근 기록을 담아 가용성 구조를 받쳐 주는 구성 요소로, **읽기·쓰기를 할 수 없고 스토리지·쓰기 비용이 들지 않으며** 두 복제본과 다른 리전에 둡니다.

> 그래서 "글로벌 테이블은 last-writer-wins"라는 한 줄만 외우면 틀립니다 — 그것은 **MREC의 동작**이고, **MRSC에서는 충돌이 예외로 드러나** 애플리케이션이 재시도로 처리합니다. 다만 MRSC는 **정확히 3리전·트랜잭션 불가·쓰기 지연 증가**라는 값을 치릅니다.

> 🧠 원리: 왜 Global Tables의 기본 충돌 해결 방식이 "최후 작성자 우선"일까요?
> 여러 리전에서 동시에 같은 항목에 쓰기가 발생하면, 어느 값이 최종 상태여야 하는지를 자동으로 결정해야 합니다.
> 최후 작성자 우선 정책은 타임스탬프가 가장 늦은 쓰기를 채택하므로, 애플리케이션이 충돌 해결 로직을 별도로 구현하지 않아도 일관된 상태로 수렴할 수 있습니다.
> 다만 이 정책은 "거의 동시에" 발생한 쓰기에서는 어느 리전의 시계가 더 앞섰는지에 따라 결과가 달라질 수 있으므로, 충돌 민감도가 높은 워크로드는 설계 단계에서 이를 고려해야 합니다.

### 8) DynamoDB Streams {#dynamodb-streams}

- 테이블의 항목 **생성·수정·삭제 이벤트를 순서대로 기록**하는 변경 로그(24시간 보관).
- Lambda와 연동해 이벤트 기반 처리 — 예: 주문 생성 시 재고 차감 트리거, 변경 데이터 캡처(CDC).
- 시험 신호어: "항목 변경 시 자동 처리", "이벤트 기반 후속 작업".

### 9) TTL (Time To Live) {#ttl}

- 항목에 만료 타임스탬프 속성을 지정하면 DynamoDB가 **자동으로 항목을 삭제**합니다.
- 추가 비용 없음. 세션 데이터·임시 토큰·캐시 항목 만료에 사용.
- 삭제는 즉시가 아니라 만료 후 **통상 수일(a few days) 내**에 최선 노력으로 처리되며, 이때 **쓰기 처리량을 소비하지 않습니다**. 만료됐지만 아직 삭제되지 않은 항목이 읽히므로, 정확한 만료가 중요하면 Query·Scan에 필터 표현식을 쓰거나 애플리케이션에서 검증합니다. (글로벌 테이블에서는 복제 리전의 삭제가 복제 쓰기 용량을 소비합니다.)

### 10) DynamoDB vs RDS 선택 기준 {#dynamodb-vs-rds}

| 기준 | DynamoDB 선택 | RDS 선택 |
|---|---|---|
| **스키마** | 스키마리스, 항목마다 속성 다름 | 고정 스키마, 정규화된 구조 |
| **조인** | 불필요 또는 애플리케이션에서 처리 | 복잡한 조인·집계 쿼리 |
| **확장** | 수평 확장(파티션 분산). 단 **파티션당 읽기 3,000·쓰기 1,000 단위/초** 한도가 있고 테이블·계정 쿼터도 존재 | 수직 확장 위주 |
| **지연** | 한 자릿수 밀리초 일관 보장 | 가변적(쿼리 복잡도 의존) |
| **운영** | 완전 관리형, 서버리스 | 패치·백업 등 일부 관리 필요 |
| **워크로드 예** | 세션, IoT 텔레메트리, 카탈로그, 장바구니 | 금융 거래, ERP, 복잡 리포팅 |

---

### 11) ElastiCache — 완전 관리형 인메모리 캐시 {#elasticache}

> 공식 정의: **"클라우드에서 분산 인메모리 데이터 스토어 또는 캐시 환경을 손쉽게 배포·운영·확장할 수 있게 해주는 웹 서비스."**

- 데이터베이스가 아니라 **캐시 계층** — DB 앞단에 배치해 반복 읽기 부하를 흡수합니다.
- 지원 엔진은 **3종**: **Valkey**·**Memcached**·**Redis OSS**. Valkey는 Redis OSS 호환 오픈소스 포크로, 신규 구성에서는 Valkey 또는 Redis OSS를 고릅니다.

**배포 형태가 둘입니다 — 노드 기반 vs ElastiCache Serverless (★ 시험 포인트)**

| 형태 | 무엇을 정하나 | 특징 |
|---|---|---|
| **노드 기반(node-based)** | 노드 타입·샤드 수·복제본 수를 직접 | 버전·패치 제어 폭이 넓고, 이전 엔진 버전 호환이 필요하면 이쪽 |
| **ElastiCache Serverless** | 아무것도 — 용량이 자동 | **Valkey · Redis OSS 7.0 이상 · Memcached 1.6 이상** 호환. 용량 산정 없이 시작 |

ElastiCache Serverless의 한도:

| 한도 | 값 |
|---|---|
| 캐시당 크기 | **5,000 GiB** |
| 슬롯당 크기 | **32 GiB** |
| 처리 단위 | 초당 **15,000,000 ECPU**(ElastiCache Processing Unit) |
| 키 이름 길이 | 4 KiB |

**엔진 버전은 올리는 방향만 있습니다**

- 엔진 버전은 **업그레이드만 가능하고 다운그레이드는 지원되지 않습니다.** 되돌리려면 이전 버전으로 새 캐시를 만들어 데이터를 옮기는 수밖에 없습니다.
- ⚠️ 아래 업그레이드 특성은 **노드 기반 전용**이며 **Serverless에는 적용되지 않습니다.**
  - **Redis OSS 5.0.6 이상**은 **최소 다운타임** 업그레이드 — 업그레이드 전 과정에서 읽기가 가능하고, 쓰기도 **수초간의 페일오버를 제외하면** 대부분 가능합니다. 5.0.6 미만은 DNS 전파 때문에 페일오버가 **30초~1분** 걸릴 수 있습니다.
  - **Valkey 7.2 · Redis OSS 6.0 이상**부터는 마이너 릴리스마다 **패치 버전을 여러 개 두지 않고 단일 버전**을 제공합니다.
  - **Redis OSS 7**부터 클러스터 모드 비활성 ↔ 활성 전환을 지원하지만, **엔진 업그레이드와 동시에는 전환할 수 없습니다**(백업 후 별도 절차).
  - 업그레이드 시 기존 클라이언트 연결이 종료되므로, 클라이언트에 **재시도와 지수 백오프**를 두는 것이 권장됩니다.
  - 심각한 보안 취약점이 발생하면 AWS가 **사용자 대신 패치할 권리를 보유**합니다.

**ElastiCache vs MemoryDB — 캐시인가, 데이터베이스인가 (★ 단골 함정)**

| 항목 | ElastiCache | **Amazon MemoryDB** |
|---|---|---|
| 공식 성격 | 인메모리 **캐시/데이터 스토어** | **내구성 있는(durable) 인메모리 데이터베이스** |
| 내구성 근거 | 캐시 계층 — 원본은 뒤쪽 DB | **Multi-AZ 트랜잭션 로그**로 여러 AZ에 내구성 있게 저장 → 빠른 페일오버·DB 복구·노드 재시작 |
| 일관성 | 엔진 복제 특성에 따름 | **프라이머리는 read-after-write 강력 일관성**, 복제본은 보장된 최종 일관성 |
| 지연 | 마이크로초급 읽기 | 마이크로초 읽기 · **한 자릿수 ms 쓰기** |
| 쓰임 | DB 앞단 캐시 | **주(primary) 데이터베이스로 단독 사용 가능** — 캐시와 영속 DB를 따로 운영할 필요가 없습니다 |

> 시험 신호: "인메모리 속도가 필요하고 **데이터를 잃으면 안 된다**", "캐시와 DB를 둘 다 운영하는 부담을 없애라" → **MemoryDB**. "뒤에 RDS/DynamoDB가 있고 읽기 부하만 덜어라" → **ElastiCache**.

### 12) Redis vs Memcached 비교 (★ 단골 출제) {#redis-vs-memcached}

| 구분 | Redis | Memcached |
|---|---|---|
| **자료구조** | 문자열·리스트·해시·집합·**Sorted Set**·Bitmap·HyperLogLog·Geo·Pub/Sub | 단순 키-값(문자열) |
| **영속성** | 스냅샷(RDB) + AOF 로그 **지원** | **없음** (메모리 한정) |
| **복제·HA** | 복제 + **Multi-AZ 자동 Failover** 지원 | **없음** |
| **스레딩** | 단일 스레드(명령 처리) | **멀티스레드** |
| **수평 확장** | 클러스터 모드(샤딩) | 단순 수평 샤딩 |
| **암호화** | 저장·전송 암호화, IAM 인증 지원 | 제한적 |
| **적합 사례** | 세션 스토어, 리더보드, 랭킹, HA 필요, 복잡 자료구조 | 단순 대용량 캐시, 멀티코어 최대 활용 |

> 결정 규칙: "영속성·HA·복잡 자료구조·Sorted Set·세션 HA" → **Valkey 또는 Redis OSS**. "가장 단순·멀티스레드·스케일아웃만" → **Memcached**.
>
> ⚠️ 위 비교표의 "Redis" 열은 **Valkey와 Redis OSS**(같은 계열)에 함께 적용됩니다 — 공식 엔진 목록은 Valkey·Memcached·Redis OSS 3종이며, 시험 문항에 "Redis"로만 나오면 이 계열로 읽습니다.

> 🧠 원리: 왜 Memcached는 노드 재시작 후 데이터를 복구하지 못할까요?
> Memcached는 데이터를 메모리에만 저장하고, 스냅샷이나 쓰기 로그 같은 영속 기록 수단을 제공하지 않습니다.
> 노드가 재시작되면 메모리 내용이 사라지고, 복구할 원본이 없으므로 이전에 캐시에 있던 항목은 모두 소실됩니다.
> 이 트레이드오프는 불필요한 I/O를 없애 단순 대용량 캐시 시나리오에서 더 높은 처리량을 얻기 위한 설계 선택이며, 장애 후 재워밍(cache warming)이 허용되는 경우에만 적합합니다.

### 13) 캐싱 전략 {#caching-strategies}

| 전략 | 동작 | 장점 | 단점 |
|---|---|---|---|
| **Lazy Loading (Cache-Aside)** | 캐시 미스 → DB 조회 → 캐시에 저장 후 반환 | 실제 요청된 데이터만 캐시. 장애 시 DB 직접 사용 가능 | 첫 조회 지연(cache miss penalty). 오래된 데이터(stale) 위험 |
| **Write-Through** | 쓰기 시 DB와 캐시를 **동시에** 갱신 | 캐시 항상 최신 유지. stale 없음 | 쓰기 지연 증가. 읽히지 않는 데이터도 캐시에 적재(낭비) |
| **TTL 병행** | 캐시 항목에 만료 시간 설정 | stale 데이터를 시간 기반으로 자동 제거 | 만료 전까지는 stale 가능. 적절한 TTL 값 튜닝 필요 |

캐시-어사이드(Lazy Loading) 흐름:

```
애플리케이션 → 캐시 조회
   HIT  → 캐시에서 즉시 반환
   MISS → DB 조회 → 결과를 캐시에 저장(TTL 설정) → 반환
```

> 🧠 원리: 왜 Lazy Loading은 Write-Through보다 stale 데이터 위험이 클까요?
> Write-Through는 쓰기 시점에 DB와 캐시를 함께 갱신하므로 캐시에는 항상 최신 값이 존재합니다.
> Lazy Loading은 캐시 미스가 발생했을 때만 DB에서 값을 가져와 저장하므로, 이후 DB 값이 바뀌어도 캐시에는 이전 값이 그대로 남습니다.
> 이 차이 때문에 Lazy Loading 환경에서는 TTL을 함께 설정해 일정 시간이 지나면 캐시 항목이 자동으로 만료·재조회되도록 하는 것이 stale 위험을 줄이는 일반적인 접근입니다.

### 14) ElastiCache 대표 사용 사례 {#elasticache-use-cases}

- **DB 읽기 부하 완화**: 동일 쿼리 결과를 캐시에 저장. DB 직접 호출 횟수 대폭 감소.
- **세션 스토어**: 스테이트리스 웹 서버 + 공유 세션 저장소(Redis). Auto Scaling 환경 표준 패턴.
- **리더보드·랭킹**: Redis Sorted Set으로 실시간 순위 계산.
- **속도 제한(Rate Limiting)**: Redis 카운터로 API 호출 횟수 제어.
- **Pub/Sub 메시징**: Redis Pub/Sub으로 가벼운 실시간 메시지 전달.

---

### 15) 목적별(purpose-built) DB 유형 {#purpose-built-db}

AWS는 "하나의 DB로 모든 것"이 아니라 **데이터 모양과 질의 패턴에 맞는 엔진**을 고르라고 안내합니다. 지금까지 본 DynamoDB(키-값)와 ElastiCache(캐시) 바깥에 어떤 축이 있는지 알아 둬야 시나리오 문제에서 엉뚱한 엔진을 고르지 않습니다.

| 데이터 모양 | 서비스 | 전형적인 질의 |
|---|---|---|
| 관계형 | Aurora · RDS | 조인·트랜잭션·집계 |
| 키-값 | **DynamoDB** | 키로 단건 조회·쓰기 (세션 스토어·장바구니) |
| **문서** | **Amazon DocumentDB** | 중첩 JSON 문서 안의 필드로 필터·정렬 |
| **와이드 컬럼** | **Amazon Keyspaces**(Apache Cassandra 호환) | 파티션 키 + 넓은 컬럼 집합 |
| **그래프** | **Amazon Neptune** | 관계 순회 — "누가 누구와 연결됐나", 최단 경로 |
| **인메모리(캐시)** | **ElastiCache** | 읽기 성능 보강용 **휘발성 캐시 계층** |
| **인메모리(DB)** | **MemoryDB** | 캐시 속도를 쓰되 **데이터 자체를 보관**하는 주 DB |
| 시계열 | Timestream | 시간 축 기준 집계 (`saa-t4-3` §7) |

> **가장 자주 헷갈리는 축 — ElastiCache vs MemoryDB**: 둘 다 인메모리지만 역할이 반대입니다. **ElastiCache는 원본 DB 앞에 두는 휘발성 캐시**라 데이터가 사라져도 원본에서 다시 채우면 됩니다. **MemoryDB는 그 자체가 내구성 있는 주 DB**로, 캐시와 DB를 따로 운영하지 않아도 되는 쪽입니다. "캐시가 날아가면 곤란하다 / 캐시 외에 별도 DB를 두고 싶지 않다"가 신호면 MemoryDB입니다.

> **DocumentDB vs Neptune**: 둘 다 비정형에 가깝지만 질의 대상이 다릅니다. **문서 안의 값**을 찾으면 DocumentDB, **문서(엔티티) 사이의 연결**을 따라가면 Neptune입니다.

> 🧠 원리: 왜 AWS는 엔진을 이렇게 잘게 나눠 둘까요?
> 데이터베이스의 성능은 대부분 **저장 구조가 질의 패턴과 맞는가**에서 결정됩니다. 관계 순회를 관계형 DB에서 하면 깊이가 깊어질수록 조인이 기하급수로 늘고, 시간 축 집계를 범용 엔진에서 하면 불필요한 인덱스 유지 비용을 치릅니다.
> 하나의 엔진이 모든 패턴에 최적일 수는 없으므로, AWS는 패턴별로 저장 구조를 달리 설계한 엔진을 따로 제공하고 "요구에 맞는 것을 고르라"고 안내합니다.
> 그래서 시험에서도 서비스 이름을 외우기보다 **"이 워크로드의 질의는 무엇을 따라가는가"**(키·문서 필드·관계·시간)를 먼저 읽는 쪽이 빠릅니다.

---

## ✍️ 시험 포인트

| 시나리오 | 정답 |
|---|---|
| 서버리스 NoSQL, 한 자릿수 밀리초 | **DynamoDB** |
| 글로벌 다중 리전 **쓰기**(Active-Active) | DynamoDB **Global Tables** |
| DynamoDB 읽기를 마이크로초로 단축 | **DAX** |
| 항목 변경 시 Lambda 이벤트 트리거 | DynamoDB **Streams** |
| 항목 자동 만료 삭제(추가 비용 없음) | DynamoDB **TTL** |
| 테이블 생성 후 새 접근 패턴 인덱스 추가 | **GSI** (LSI는 생성 시에만) |
| 강력한 일관성 읽기가 필요한 인덱스 | **LSI** (GSI는 최종 일관성만) |
| 트래픽 예측 불가·스파이크 대응 | **온디맨드** 용량 모드 |
| 반복 쿼리로 DB 과부하, 지연 단축 | **ElastiCache** |
| 세션 공유 저장 + HA + Failover | ElastiCache **Redis** |
| 영속성·복잡 자료구조·Sorted Set | **Redis** |
| 가장 단순한 캐시, 멀티스레드 확장 | **Memcached** |
| 쓰기 시 캐시 항상 최신 유지 | **Write-Through** 전략 |
| Stale 위험 완화 + Lazy Loading 결합 | **TTL** 병행 |

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"LSI를 테이블 생성 후 추가할 수 있다."** → 불가능합니다. LSI는 테이블 생성 시에만 정의할 수 있습니다. 나중에 새 접근 패턴이 필요하면 **GSI**를 추가해야 합니다.
   *(원리: §3 — LSI는 기본 테이블과 같은 파티션 키를 공유하므로 테이블 생성 시에만 정의할 수 있고, GSI는 자체 파티션 공간에서 독립적으로 확장되므로 언제든 추가 가능하다.)*

2. **"GSI에서 강력한 일관성 읽기를 쓸 수 있다."** → GSI는 최종 일관성 읽기만 지원합니다. 강력한 일관성이 필요하면 기본 테이블 또는 LSI를 사용해야 합니다.
   *(원리: §4 본문 — GSI는 최종 일관성만 지원하며, 강력한 일관성이 필요하면 기본 테이블 또는 LSI를 사용해야 한다.)*

3. **"DynamoDB Global Tables = RDS Read Replica."** → 전혀 다릅니다. Read Replica는 읽기 전용이지만 Global Tables는 **모든 리전에서 읽기·쓰기가 모두 가능한 Active-Active** 구성입니다.
   *(원리: §7 — Active-Active는 타임스탬프 기반 최후 작성자 우선으로 충돌을 처리하며 모든 리전에서 쓰기를 허용한다.)*

4. **"핫 파티션이 생겨도 DynamoDB가 자동으로 처리한다."** → DynamoDB는 파티션 키 기반으로 트래픽을 분산하므로, 카디널리티 낮은 PK를 선택하면 특정 파티션에 부하가 집중됩니다. 설계 단계에서 PK를 신중하게 선택해야 합니다.
   *(원리: §2 — 카디널리티 낮은 PK는 해시 편중을 유발하고, 해당 파티션 처리량 한도 초과 시 스로틀이 발생한다.)*

5. **"DAX와 ElastiCache는 같은 용도다."** → DAX는 **DynamoDB 전용** 인메모리 캐시로, DynamoDB API와 호환됩니다. ElastiCache는 RDS·DynamoDB 등 다양한 백엔드에 범용으로 사용하는 캐시입니다.
   *(원리: §6 — DAX는 강력 일관성 읽기를 우회하므로 일관성 요건에 따라 캐시 경로가 달라진다.)*

6. **"Memcached를 세션 스토어로 쓰면 장애 시에도 안전하다."** → Memcached는 영속성과 복제가 없습니다. 노드 장애 시 세션이 사라집니다. 세션 저장 HA가 필요하면 **Redis**를 사용해야 합니다.
   *(원리: §12 — Memcached는 영속 기록 수단 없이 메모리에만 저장하므로 노드 재시작 시 모든 항목이 소실된다.)*

7. **"Write-Through만 쓰면 완벽하다."** → Write-Through는 쓰기 지연이 증가하고 실제로 읽히지 않는 데이터도 캐시에 적재됩니다. 서비스 특성에 따라 Lazy Loading + TTL과 병행하거나 선택합니다.
   *(원리: §13 — Lazy Loading은 미스 시에만 DB를 조회해 낭비가 없지만 stale 위험이 있고, Write-Through는 stale 없지만 쓰기 지연과 불필요한 적재가 생긴다.)*

8. **"TTL이 설정한 시각에 정확히 삭제된다."** → DynamoDB TTL 삭제는 만료 후 **통상 수일 내**에 최선 노력으로 처리됩니다(언제든 삭제될 수 있고, 보장 시한이 있는 것이 아닙니다). 정확한 시점 제어가 필요하면 쿼리에 필터 표현식을 쓰거나 애플리케이션에서 만료 여부를 직접 확인해야 합니다.
   *(원리: §9 본문 — TTL 삭제는 비동기 백그라운드 프로세스로 처리되므로 만료 직후 항목이 즉시 사라지지 않을 수 있다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 전자상거래 앱에서 상품 카탈로그 테이블에 `productId`(PK)로 조회하는 패턴 외에, `category`별로 상품을 조회해야 하는 요구사항이 추가되었습니다. 테이블은 이미 운영 중입니다. 어떻게 해결하나요?

<details><summary>정답 보기</summary>

**GSI(Global Secondary Index)를 추가**합니다. `category`를 파티션 키로 하는 GSI를 생성하면 카테고리별 조회가 가능합니다. LSI는 테이블 생성 시에만 추가할 수 있으므로 이미 운영 중인 테이블에는 사용할 수 없습니다. GSI는 테이블과 독립적인 처리량을 가지며, 최종 일관성 읽기만 지원합니다.
</details>

**Q2.** 글로벌 게임 서비스가 미국·유럽·아시아 사용자 모두에게 낮은 지연으로 **쓰기**를 제공해야 합니다. RDS와 DynamoDB 중 무엇을 선택하고, 어떤 기능을 사용하나요?

<details><summary>정답 보기</summary>

**DynamoDB Global Tables**를 선택합니다. Global Tables는 여러 리전에서 동시에 읽기와 쓰기가 가능한 Active-Active 복제를 제공합니다. RDS Read Replica는 읽기 전용이므로 멀티 리전 쓰기 요구사항을 충족하지 못합니다. 충돌은 최후 작성자 우선(last-writer-wins)으로 자동 해결됩니다.
</details>

**Q3.** 웹 애플리케이션이 동일한 DB 쿼리를 초당 수천 번 반복 실행해 RDS 부하가 높습니다. 지연도 줄이고 DB 부하도 낮추려면 어떤 서비스와 전략을 사용하나요?

<details><summary>정답 보기</summary>

**ElastiCache**를 추가하고 **Lazy Loading(Cache-Aside)** 전략을 적용합니다. 캐시 미스 시에만 DB를 조회하고 결과를 캐시에 저장(TTL 설정)하면, 반복 조회는 캐시에서 처리되어 DB 호출이 대폭 감소합니다. TTL을 함께 설정해 오래된 데이터(stale) 위험을 완화합니다.
</details>

**Q4.** 오토스케일링 그룹 뒤에 있는 여러 웹 서버가 사용자 로그인 세션을 공유해야 합니다. 노드 장애 시에도 세션이 유지되어야 합니다. 어떤 서비스를 선택하나요?

<details><summary>정답 보기</summary>

**ElastiCache for Redis**를 선택합니다. Redis는 복제와 Multi-AZ 자동 Failover를 지원하므로 노드 장애 시에도 세션이 유지됩니다. Memcached는 영속성과 HA 기능이 없어 노드 장애 시 세션이 사라집니다. DynamoDB도 세션 스토어로 사용할 수 있지만, 인메모리 속도가 필요한 경우 Redis가 적합합니다.
</details>

**Q5 (원리).** 왜 카디널리티가 낮은 속성을 DynamoDB 파티션 키로 선택하면 프로비저닝 처리량이 충분해도 스로틀이 발생할 수 있나요?

<details><summary>정답 보기</summary>

DynamoDB는 파티션 키를 해시해 데이터를 여러 물리 파티션에 분산하며, 프로비저닝 처리량도 파티션 수에 나눠 배분됩니다. 카디널리티가 낮으면 대부분의 요청이 소수 파티션에 집중되어 해당 파티션의 처리량 몫이 빠르게 소진되는 반면, 나머지 파티션의 용량은 유휴 상태로 남습니다. 테이블 전체 처리량은 여유가 있어도 핫 파티션만 한도를 초과하면 그 파티션으로 향하는 요청이 스로틀되므로, 설계 단계에서 고카디널리티 PK를 선택하는 것이 핵심입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon DynamoDB 개발자 안내서 — 소개 — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
2. DynamoDB 보조 인덱스 (GSI·LSI) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html
3. DynamoDB Accelerator (DAX) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.html
4. Amazon ElastiCache 개발자 안내서 — What Is ElastiCache? — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.html
5. DynamoDB TTL("within a few days of their expiration time, without consuming write throughput") — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
6. ElastiCache 엔진 비교(Valkey·Memcached·Redis OSS) — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/SelectEngine.html
7. DynamoDB 파티션 키 설계(파티션당 3,000 읽기·1,000 쓰기 단위/초) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html
8. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
9. AWS 데이터베이스 선택 가이드(관계형·키-값·문서·와이드 컬럼·그래프·인메모리 등 목적별 엔진) — https://docs.aws.amazon.com/databases-on-aws-how-to-choose/
10. Amazon MemoryDB란 무엇인가("durable, in-memory database service that delivers ultra-fast performance") — https://docs.aws.amazon.com/memorydb/latest/devguide/what-is-memorydb.html
11. DynamoDB 제약(항목 400 KB·용량 단위 크기·트랜잭션 2배·모드 전환 24시간 4회) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Constraints.html (갭 배치 B8a: 2026-10-21)
12. DynamoDB 버스트·적응형 용량(파티션 3,000/1,000 초과 시 스로틀·적응형은 기본 활성·무료) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/burst-adaptive-capacity.html (갭 배치 B8a: 2026-10-21)
13. DynamoDB warm throughput(새 온디맨드 테이블 읽기 12,000·쓰기 4,000·사전 웜업·값 하향 불가) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/warm-throughput.html (갭 배치 B8a: 2026-10-21)
14. 핫 파티션 스로틀 이유 타입 `KeyRangeThroughputExceeded` — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/throttling-key-range-limit-exceeded-mitigation.html (갭 배치 B8a: 2026-10-21)
15. 글로벌 테이블 동작 — 일관성 모드(MREC 기본·MRSC·생성 후 변경 불가) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html (갭 배치 B8a: 2026-10-21)
16. 글로벌 테이블 설계 — MRSC 핵심 사실(정확히 3리전·증인·트랜잭션 API 미지원·`ReplicatedWriteConflictException`) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-global-table-design.html (갭 배치 B8a: 2026-10-21)
17. ElastiCache Serverless 엔진 버전·한도(Valkey·Redis OSS 7.0+·Memcached 1.6+ / 5,000 GiB·32 GiB·15,000,000 ECPU·키 4 KiB) — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/migration-to-serverless-prerequisites.html (갭 배치 B8a: 2026-10-21)
18. ElastiCache 노드 기반 업그레이드 고려사항(5.0.6+ 최소 다운타임·Valkey 7.2/Redis OSS 6.0+ 단일 버전·Serverless 비적용) — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/VersionManagement-upgrade-considerations.html (갭 배치 B8a: 2026-10-21)
19. MemoryDB 기능(Multi-AZ 트랜잭션 로그·프라이머리 read-after-write 일관성·한 자릿수 ms 쓰기) — https://docs.aws.amazon.com/memorydb/latest/devguide/servicename-feature-overview.html (갭 배치 B8a: 2026-10-21)

> 📝 **2026-10-21 보강 (갭 배치 B8a)**: ① §5에 **파티션 한도**(읽기 3,000·쓰기 1,000)와 **항목 400 KB**(속성 이름 바이트 포함·LSI 합산), `KeyRangeThroughputExceeded`, **적응형 용량**(기본 활성·무료·끌 수 없음·파티션 최대를 못 넘음), **모드 전환 비대칭**(프로비저닝→온디맨드 24시간 4회), 트랜잭션 2배, 그리고 현행 온디맨드 모델인 **warm throughput**(새 테이블 읽기 12,000·쓰기 4,000·사전 웜업·**올린 값 하향 불가**)을 추가했습니다(근거 11~14번). ② §7에 **일관성 모드 두 가지**를 넣었습니다 — 기존 서술이 충돌 해소를 **last-writer-wins로만** 적고 있었는데, 그것은 **기본 모드 MREC의 동작**이고 **MRSC**에서는 충돌이 `ReplicatedWriteConflictException`으로 드러납니다. MRSC의 값(정확히 **3리전**·복제본 2+**증인** 1 가능·**트랜잭션 API 미지원**·쓰기·강력읽기 지연 증가·**생성 후 모드 변경 불가**)도 함께 적었습니다(근거 15·16번). ③ §11에 **ElastiCache Serverless와 한도**, **엔진은 업그레이드만 가능**(다운그레이드 미지원)과 노드 기반 업그레이드 특성, **ElastiCache vs MemoryDB 비교표**를 추가했습니다(근거 17~19번) — §15의 목적별 DB 개요보다 한 단 깊은 층입니다.
>
> **파생 문항 1개소 정밀화**: `saa-t3-6.questions.json`의 글로벌 테이블 해설이 충돌 해소를 LWW로만 적어, **기본 모드 MREC에서의 동작**임을 밝히도록 고쳤습니다(정답 인덱스·`verified` 무변경, 드래프트라 라이브 노출 없음).
>
> **쓰지 않은 것**: 갭 노트가 적은 온디맨드의 **"이전 피크 2배·30분 규칙"**과 **프로비저닝 버스트 5분** — 현행 공식 문서는 그 규칙 대신 **warm throughput**으로 설명하며 두 수치를 두지 않아 쓰지 않았습니다.

> 📝 **2026-10-19 정정**: ① TTL 삭제 시점을 현행 서술인 **만료 후 수일 내(최선 노력)**로 고쳤습니다(근거 5번). ② ElastiCache 엔진을 **Valkey·Memcached·Redis OSS 3종**으로 갱신했습니다(근거 6번). ③ DynamoDB를 "무제한 처리량"으로 적었던 칸에 **파티션당 읽기 3,000·쓰기 1,000 단위/초** 한도를 명시했습니다(근거 7번).

> 📝 **2026-10-20 보강**: 공식 가이드 Task 3.3 Knowledge 「목적별 DB 유형」에 대응하는 서술이 없어 **§15**를 신설했습니다(근거 9~10번). 문서(DocumentDB)·와이드 컬럼(Keyspaces)·그래프(Neptune)·인메모리 두 갈래(ElastiCache = 휘발 캐시 / MemoryDB = 내구성 주 DB)를 선택 축으로 정리했습니다.
