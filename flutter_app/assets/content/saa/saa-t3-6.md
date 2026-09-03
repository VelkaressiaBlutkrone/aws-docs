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
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
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

> RCU(Read Capacity Unit): 최종 일관성 읽기 4KB/1초당 0.5 RCU, 강력 일관성 1 RCU. WCU(Write Capacity Unit): 1KB 쓰기당 1 WCU.

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
- 충돌 해결: "최후 작성자 우선(last-writer-wins)" 정책 자동 적용.
- 시험 신호어: "글로벌 다중 리전 쓰기", "재해 복구(DR) + 낮은 지연", "Active-Active".

> 🧠 원리: 왜 Global Tables의 충돌 해결 방식이 "최후 작성자 우선"일까요?
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
- 삭제는 즉시가 아닌 **48시간 이내** 처리(근사치). 정확한 만료 시점이 중요하면 애플리케이션에서 별도 검증 필요.

### 10) DynamoDB vs RDS 선택 기준 {#dynamodb-vs-rds}

| 기준 | DynamoDB 선택 | RDS 선택 |
|---|---|---|
| **스키마** | 스키마리스, 항목마다 속성 다름 | 고정 스키마, 정규화된 구조 |
| **조인** | 불필요 또는 애플리케이션에서 처리 | 복잡한 조인·집계 쿼리 |
| **확장** | 수평 확장, 무제한 처리량 | 수직 확장 위주 |
| **지연** | 한 자릿수 밀리초 일관 보장 | 가변적(쿼리 복잡도 의존) |
| **운영** | 완전 관리형, 서버리스 | 패치·백업 등 일부 관리 필요 |
| **워크로드 예** | 세션, IoT 텔레메트리, 카탈로그, 장바구니 | 금융 거래, ERP, 복잡 리포팅 |

---

### 11) ElastiCache — 완전 관리형 인메모리 캐시 {#elasticache}

> 공식 정의: **"클라우드에서 분산 인메모리 데이터 스토어 또는 캐시 환경을 손쉽게 배포·운영·확장할 수 있게 해주는 웹 서비스."**

- 데이터베이스가 아니라 **캐시 계층** — DB 앞단에 배치해 반복 읽기 부하를 흡수합니다.
- 두 가지 엔진 지원: **Redis**와 **Memcached**.

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

> 결정 규칙: "영속성·HA·복잡 자료구조·Sorted Set·세션 HA" → **Redis**. "가장 단순·멀티스레드·스케일아웃만" → **Memcached**.

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

8. **"TTL이 설정한 시각에 정확히 삭제된다."** → DynamoDB TTL 삭제는 만료 후 **최대 48시간 이내** 처리됩니다. 정확한 시점 제어가 필요하면 애플리케이션에서 만료 여부를 직접 확인해야 합니다.
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
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
