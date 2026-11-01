---
examGuideTaskId: dva-t1-3
certCode: DVA-C03
domain: 1
domainName: AWS 서비스를 통한 개발
domainWeightPct: 30
title: 애플리케이션 개발 중 데이터 스토어 사용 (수명 주기·선택·캐싱·DynamoDB)
coversTasks:
  - "1.3"
sources:
  - title: Managing the lifecycle of objects (Amazon S3 User Guide)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
  - title: Using time to live (TTL) in DynamoDB
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
  - title: Select a database service for your Lambda-based applications
    url: https://docs.aws.amazon.com/lambda/latest/dg/ddb-rds-database-decision.html
  - title: Caching strategies (Amazon ElastiCache User Guide)
    url: https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html
  - title: In-memory acceleration with DynamoDB Accelerator (DAX)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.html
  - title: Designing partition keys to distribute your workload in DynamoDB
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-uniform-load.html
  - title: DynamoDB read consistency
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html
  - title: Improving data access with secondary indexes in DynamoDB
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
lastVerified: 2026-11-01
---

# 애플리케이션 개발 중 데이터 스토어 사용 (수명 주기·선택·캐싱·DynamoDB)

> **커버하는 공식 Task** — DVA-C03 · 도메인 1 「AWS 서비스를 통한 개발」(30%) · **작업 1.3 애플리케이션 개발 중에 데이터 스토어를 사용합니다** (`dva-t1-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 네 개(1.3.1~1.3.4)를 모두 덮습니다.

> ⚠️ **C03에서 이 작업은 통합됐습니다.** C02의 Task 1.3은 기술 9개였는데 **C03은 4개**입니다. DynamoDB 관련 네 기술(파티션 키·일관성·Query/Scan·키·인덱스)이 **기술 1.3.4 하나로 묶였고**, **직렬화·역직렬화는 작업 1.1(기술 1.1.7)로 나갔습니다**. 그래서 이 문서에서 직렬화는 다루지 않습니다 — `dva-t1-1` 7)절을 봅니다.
>
> ⚠️ **캐싱은 두 작업에 걸쳐 있습니다.** 여기(기술 1.3.3)는 **"무엇을 고르는가"**이고, 작업 4.3(기술 4.3.4)은 **"성능을 어떻게 올리는가"**입니다. 같은 서비스를 다른 관점으로 봅니다.

---

## ✅ 학습 목표 체크리스트

- [ ] S3 Lifecycle의 전환·만료 규칙과 **버전 관리 버킷에서 달라지는 점**을 설명한다
- [ ] DynamoDB TTL이 **즉시 삭제가 아니라는 것**과 그로 인한 코드 주의점을 안다
- [ ] 접근 패턴으로 DynamoDB·RDS·S3·ElastiCache·OpenSearch를 고를 수 있다
- [ ] 지연 로딩·write-through·TTL의 **장단점과 조합 방식**을 말할 수 있다
- [ ] DAX와 ElastiCache를 **대상·코드 변경·일관성·쓰기 처리**로 가른다
- [ ] 높은 카디널리티 파티션 키가 왜 필요한지와 **쓰기 샤딩** 두 방식을 안다
- [ ] 최종적 일관성과 강력한 일관성의 **비용·지원 범위**를 구분한다(⚠️ GSI는 최종적 일관성만)
- [ ] Query·Scan·GetItem을 가르고 **FilterExpression이 읽은 뒤에 적용된다**는 것을 안다

---

## 🎯 왜 중요한가

데이터 스토어 문항은 **"무엇을 고르는가"**와 **"왜 느리고 비싼가"** 둘로 갈립니다. 앞쪽은 접근 패턴을 보기와 맞추면 풀리고, 뒤쪽은 거의 전부 **DynamoDB의 세 가지 오해**에서 나옵니다 — 파티션 키를 잘못 골라 스로틀되는 것, 필터가 읽기 비용을 줄여 준다고 믿는 것, GSI에 강력한 일관성 읽기를 기대하는 것.

C03에서는 이 Task가 네 기술로 좁아졌지만 **DynamoDB의 비중은 오히려 분명해졌습니다** — 네 기술 중 하나가 DynamoDB 통합 기술이고, 그 안에 파티션 키·일관성·Query/Scan·인덱스가 모두 들어 있습니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **S3 Lifecycle**: 전환은 **하향식**이고(Standard-IA → Standard 불가), **128 KB 미만은 기본 전환 제외**이며 기존·신규 객체 모두에 적용됩니다. 규칙이 겹치면 **영구 삭제가 전환보다 우선**합니다
- **버전 관리 버킷**: `Expiration`은 현재 버전에 **delete marker를 추가**하고, `NoncurrentVersionExpiration`은 비현재 버전을 **영구 삭제**합니다(복구 불가)
- ⚠️ **DynamoDB TTL은 즉시 삭제가 아닙니다**(보통 수일 내). 만료됐지만 안 지워진 항목은 **읽히므로** Query·Scan에서 `FilterExpression`으로 제외합니다. **쓰기 처리량을 쓰지 않습니다**
- **파티션 한도**: 읽기 **3,000 read units/s**, 쓰기 **1,000 write units/s**. 테이블 용량이 남아도 **한 파티션 키로 쏠리면** 스로틀됩니다
- ⚠️ **적응형 용량·버스트는 완충이지 해법이 아닙니다** — 근본 처방은 **높은 카디널리티 키**와 **쓰기 샤딩**입니다
- **일관성**: 강력한 일관성 읽기는 **처리량을 2배** 씁니다. ⚠️ **GSI는 최종적 일관성만**이고 `ConsistentRead=true`면 `ValidationException`입니다
- ⚠️ **`FilterExpression`은 읽은 뒤에 적용됩니다** — 소모 RCU와 1 MB 한도는 **필터 전** 기준입니다. 필터는 "덜 돌려받게" 할 뿐 **덜 읽게 하지 않습니다**
- **Query vs Scan**: Query는 **파티션 키 동등 조건이 필수**이고 정렬 키 순서로 돌려줍니다. `ScannedCount`가 `Count`보다 훨씬 크면 **비효율 신호**입니다
- **GSI vs LSI**: GSI는 **나중에 추가·삭제 가능·자체 용량·최종적 일관성만**, LSI는 **테이블 생성 시에만·베이스 용량 사용·강력한 일관성 가능·PK당 10 GB 한도**
- **캐시 선택**: DynamoDB 전용·코드 변경 최소·write-through 내장이면 **DAX**, 범용 인메모리이고 앱이 전략을 구현하면 **ElastiCache**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **파티션** | DynamoDB의 내부 물리 저장 단위. 파티션 키 해시값이 어느 파티션인지 정한다 |
| **카디널리티** | 값의 고유함 정도. 높으면 요청이 여러 파티션으로 넓게 퍼진다 |
| **항목 컬렉션** | 같은 파티션 키 값을 가진 항목들(+투영된 LSI 항목)의 묶음. LSI의 10 GB 한도가 걸리는 단위 |
| **RCU / WCU** | 읽기·쓰기 용량 단위. 강력한 일관성 읽기는 같은 데이터에 **2배**를 쓴다 |
| **투영(projection)** | 보조 인덱스에 복사할 속성 집합(`KEYS_ONLY`·`INCLUDE`·`ALL`) |
| **희소 인덱스** | 인덱스 키 속성이 **존재하는 항목만** 담기는 GSI의 성질 |
| **지연 로딩(cache-aside)** | 캐시를 먼저 보고 미스면 DB에서 읽어 캐시에 채우는 전략 |
| **thundering herd** | 많은 프로세스가 같은 키의 미스를 동시에 겪어 같은 DB 질의를 병렬로 날리는 현상 |

---

## 📖 핵심 개념

### 1) 데이터 수명 주기 — S3 Lifecycle (기술 1.3.1) {#s3-lifecycle}

S3 Lifecycle 구성은 **전환 액션**(예: 30일 후 Standard-IA, 1년 후 Glacier Flexible Retrieval)과 **만료 액션**(S3가 대신 삭제)으로 이뤄지고 **기존·신규 객체 모두에** 적용됩니다.

- ⚠️ **전환은 하향식**입니다 — Standard-IA에서 Standard로 되돌릴 수 없습니다.
- ⚠️ **128 KB 미만 객체는 기본적으로 전환되지 않습니다.** 필요하면 `ObjectSizeGreaterThan`·`ObjectSizeLessThan` 필터로 허용합니다.
- 최소 저장 기간이 있는 클래스에서 **일찍 옮기거나 만료하면 남은 기간만큼 과금**됩니다.
- 접근 패턴을 모르면 **Intelligent-Tiering**을 씁니다.
- ⚠️ **버킷 정책으로 Lifecycle의 삭제·전환을 막을 수 없습니다.** 규칙이 겹치면 **영구 삭제가 전환보다 우선**합니다.

**버전 관리 버킷**에서는 동작이 둘로 갈립니다.

| 액션 | 대상 | 결과 |
|---|---|---|
| `Expiration` | **현재** 버전 | 현재 버전을 비현재로 남기고 **delete marker를 추가**한다(데이터는 남는다) |
| `NoncurrentVersionExpiration` | **비현재** 버전 | **영구 삭제**한다(복구 불가). `NoncurrentDays`·`NewerNoncurrentVersions`로 조절 |

비현재 버전이 없는 delete marker가 **expired object delete marker**이고, 정리 규칙으로 제거합니다.

> 🧠 **원리** — Lifecycle은 "언제"만 정하고 "되돌리기"는 주지 않습니다. 그래서 설계는 **되돌릴 수 없는 방향**(싼 클래스로, 삭제로)만 자동화하고, 복구가 필요한 축은 버전 관리·백업 같은 **다른 기능**에 맡깁니다.

### 2) 데이터 수명 주기 — DynamoDB TTL과 보존 (기술 1.3.1) {#ttl}

TTL은 항목별 만료 시각 속성(**Number 타입, Unix epoch 초**)으로 동작합니다.

- ⚠️ **TTL 속성이 Number가 아니면 무시됩니다.**
- ⚠️ **즉시 삭제가 아닙니다** — 만료 항목은 보통 **수일 내** 자동 삭제되고, **쓰기 처리량을 쓰지 않습니다**(무료). 만료됐지만 아직 안 지워진 항목은 **읽기·갱신이 됩니다.**
- 그래서 공식 문서가 두 가지를 권장합니다 — Scan·Query에서 만료 항목을 **`FilterExpression`으로 제외**하고, 만료 항목을 갱신할 때는 **조건식**을 씁니다. 미래 시각으로 갱신하거나 속성을 지우면 **삭제되지 않습니다.**
- TTL 삭제는 **Streams에 서비스 삭제로 기록**되고 **GSI·LSI에서도 제거**됩니다. 글로벌 테이블에서는 복제되며 복제본 리전에서 **복제 쓰기 단위를 소모**합니다.
- TTL 활성·비활성 변경은 **테이블당 시간당 1회**입니다.

보존·복구 수단은 따로입니다 — **PITR 보존 1~35일**, 장기 보관은 **온디맨드 백업**, 드물게 읽는 데이터는 **Standard-IA 테이블 클래스**. ⚠️ **DynamoDB export to S3를 쓰려면 PITR 활성화가 필요**합니다.

> 🧠 **원리** — TTL은 **백그라운드 청소부**이지 트랜잭션 삭제가 아닙니다. "만료 시각이 지났다"와 "항목이 없다"가 같지 않다는 점이 코드에 그대로 영향을 줍니다 — 그래서 읽는 쪽에서 한 번 더 걸러야 합니다.

### 3) 액세스 패턴으로 스토어 고르기 (기술 1.3.2) {#store-choice}

선택 원칙은 하나입니다 — **접근 패턴이 먼저이고 스토어는 그에 맞춥니다.** DynamoDB는 키 기반 접근에 맞춰져 있어 **JOIN과 count·sum·min·max 같은 집계를 제공하지 않습니다.**

| 접근 패턴 | 적합한 스토어 |
|---|---|
| 키로 단건·범위 조회, 서버리스, 일관된 한 자릿수 ms | **DynamoDB** |
| 정규화된 관계형 데이터, SQL | **RDS**(Aurora 포함. Lambda에서는 **RDS Proxy**로 연결 풀링) |
| 자유 텍스트(전문) 검색, 로그·클릭스트림 분석 | **OpenSearch Service** |
| DynamoDB 앞단의 마이크로초 반복 읽기 | **DAX** |
| DB 앞단의 범용 인메모리 캐시 | **ElastiCache** |
| 대용량 객체·정적 자산 | **S3** |

- **DynamoDB ↔ OpenSearch zero-ETL**: OpenSearch Ingestion의 DynamoDB 플러그인이 초기에는 **export to S3 스냅샷**으로 적재하고 이후 **DynamoDB Streams로 변경을 near real time 복제**합니다. **PITR 활성화와 Streams(new & old images)**가 필요하고 **테이블의 읽기·쓰기 처리량을 쓰지 않습니다.** ⚠️ 중단이 **24시간을 넘으면 업데이트가 유실**될 수 있습니다.
- OpenSearch 개념 대응: **인덱스 ≈ 테이블 · 문서 ≈ 행 · 필드 ≈ 열**. 인덱스를 만들 때 **주 샤드 수**를 정하고 복제본 샤드는 중복성과 읽기 용량을 더합니다(최소 1개 권장).

> 🧠 **원리** — "DynamoDB로 검색까지 하려는 것"이 가장 흔한 설계 실패입니다. 키 설계 밖의 임의 조건 검색·분석은 DynamoDB의 강점이 아니므로, **원본은 DynamoDB에 두고 검색용 복제본을 다른 스토어에 만드는 것**이 공식이 제시하는 패턴입니다.

### 4) 캐싱 전략 — 지연 로딩·write-through·TTL (기술 1.3.3) {#cache-strategy}

| 전략 | 동작 | 장점 | 단점 |
|---|---|---|---|
| **지연 로딩**(cache-aside) | 캐시 조회 → 미스면 DB 조회 후 캐시에 저장 | 요청된 데이터만 캐시, 노드 장애에도 앱이 동작(지연만 증가), 새 노드가 자동으로 채워짐 | 미스 시 **3번 왕복** 페널티, stale 데이터 |
| **write-through** | DB에 쓸 때 **캐시도 함께 갱신** | 캐시가 항상 최신, 지연을 쓰기 쪽으로 이전 | 새·교체 노드의 **누락 데이터**, 읽히지 않는 데이터로 캐시 낭비 |
| **TTL 추가** | 키마다 만료 시간(초) 부여 | 두 전략의 단점 완화, 캐시 비대화 방지 | 값이 **여전히 stale일 수 있음** |

- 실무 조합은 **지연 로딩을 기반으로 깔고 특정 데이터에만 write-through를 얹는 것**이며, write-through로 갱신하는 키를 뺀 모든 키에 TTL을 주고 변화가 빠른 데이터는 **몇 초짜리 짧은 TTL**을 씁니다.
- 가장 먼저 판단할 것은 **"캐시해도 안전한 데이터인가"**(일관성 요구)입니다.
- ⚠️ **thundering herd**는 TTL 만료나 **새 캐시 노드(빈 메모리)**에서 악화됩니다. 사전 워밍으로 완화하고, **같은 TTL을 일괄 적용하지 않습니다** — 키들이 같은 시간대에 만료되므로 **TTL에 지터**를 더합니다.

> 🧠 **원리** — 캐시는 원본의 복사본이므로 **신선도는 갱신 전략과 TTL이 정합니다.** 지연 로딩은 DB가 바뀌어도 캐시를 갱신하지 않으니 stale해지고, write-through는 최신이지만 읽히지 않을 데이터까지 씁니다. 그래서 둘을 섞고 TTL로 상한을 둡니다.

### 5) ElastiCache 엔진과 DAX (기술 1.3.3) {#elasticache-dax}

| 항목 | **Memcached** | **Valkey / Redis OSS** |
|---|---|---|
| 데이터 타입 | 단순(문자열·객체) | 복합(집합·정렬 집합·리스트·해시·비트맵 등) |
| 멀티스레드 | **예** | 아니오 |
| 복제·고가용성 | **없음** | 있음(클러스터 모드 활성 시 자동 장애 조치) |
| Pub/Sub·정렬 집합 | 없음 | 있음 |
| 백업·복원 | 서버리스 캐시만 | 예 |

**Memcached 선택 기준**(공식)은 가장 단순한 모델, 멀티코어 큰 노드, 노드 추가·제거로 스케일 인·아웃, 객체 캐싱입니다. **Valkey가 ElastiCache의 권장 엔진**이고 Redis OSS·Memcached도 계속 지원합니다.

**DAX**는 DynamoDB 호환 인메모리 캐시입니다. DAX 클라이언트로 클러스터 엔드포인트를 쓰면 되므로 **API 호환 → 코드 변경 최소**이고, VPC 안에서 실행되며 최종적 일관성 읽기 지연을 **밀리초에서 마이크로초로** 줄입니다.

- **읽기**: `GetItem`·`BatchGetItem`·`Query`·`Scan` 중 **최종적 일관성 읽기만 캐시**하고, ⚠️ **강력한 일관성·트랜잭션 읽기는 패스스루**(캐시하지 않음)입니다.
- **쓰기**: **write-through** — DynamoDB에 먼저 쓰고 성공해야 DAX에 반영합니다. 대량 적재처럼 캐시 오염이 걱정되면 DynamoDB에 직접 쓰는 **write-around**를 쓰되 **캐시와 불일치**가 생깁니다.
- ⚠️ **두 캐시는 독립입니다** — **항목 캐시**(`GetItem`·`BatchGetItem`, 기본 키로 저장)와 **쿼리 캐시**(`Query`·`Scan`, 파라미터로 저장). **항목 쓰기는 쿼리 캐시를 무효화하지 않고**, Scan으로 항목 캐시를 데울 수 없습니다. 항목 캐시 TTL 기본 **5분** + LRU이고, 항목이 없어도 **빈 결과를 캐시**합니다(음수 캐싱).
- **적합·부적합**: 반복 읽기가 많은 핫 키·읽기 집약 워크로드에 적합하고(**적중률 90% 초과일 때 최적**), 강력한 일관성이 필요하거나 **쓰기 집약**이거나 반복 읽기가 적으면 부적합합니다. 가용성은 **3개 이상 노드·여러 AZ**를 권장합니다.

| 질문 | **DAX** | **ElastiCache** |
|---|---|---|
| 대상 | **DynamoDB 전용** | DB 앞단의 **범용** 인메모리 키-값 저장소 |
| 코드 변경 | API 호환 → 엔드포인트·클라이언트 교체 | 앱이 조회·채움·무효화 로직을 **직접 구현** |
| 일관성 | 최종적 일관성 읽기만 캐시 | 전략·TTL에 따라 stale 가능 |
| 쓰기 처리 | **write-through 내장** | 앱이 write-through 구현 |

> 🧠 **원리** — DAX가 강력한 일관성 읽기를 캐시하지 못하는 이유는 **DAX가 DynamoDB와 느슨하게 결합돼 있기** 때문입니다. 캐시가 "최신인지"를 스스로 알 수 없으니, 최신을 요구하는 읽기는 원본으로 보낼 수밖에 없습니다.

### 6) DynamoDB 파티션 키와 카디널리티 (기술 1.3.4) {#partition-key}

파티션 키 값은 내부 해시 함수의 입력이고, 출력이 **항목이 저장될 파티션**을 정합니다. 같은 파티션 키 값의 항목은 한곳에 **정렬 키 순으로** 저장됩니다.

- 파티션 하나는 **읽기 최대 3,000 read units/s · 쓰기 최대 1,000 write units/s**를 처리하도록 설계돼 있습니다. 항목이 크면 읽기 1회가 여러 단위를 쓰므로 한 항목에 보낼 수 있는 요청 수가 줍니다(예: 20 KB 항목의 일관된 읽기 = 5 read units → 초당 600회).

| 파티션 키 후보 | 균등성 | 근거 |
|---|---|---|
| 사용자 ID(사용자가 많음) | 좋음 | 고유 값이 많고 분산된다 |
| 상태 코드(값이 몇 개뿐) | **나쁨** | 고유 값이 적어 한 키로 쏠린다 |
| 생성일(일·시·분으로 반올림) | **나쁨** | 같은 기간의 모든 새 항목이 한 키로 간다 |
| 디바이스 ID(접근 간격이 비슷) | 좋음 | 접근이 고르게 분산된다 |
| 디바이스 ID(하나가 압도적 인기) | **나쁨** | 인기 키에 쏠린다 |

**쓰기 샤딩** 두 방식:

1. **랜덤 접미사** — 날짜 키 뒤에 1~200 난수를 붙입니다(`2026-11-01.1` … `.200`). ⚠️ 읽을 때는 **모든 접미사를 Query해 앱이 병합**해야 합니다.
2. **계산 접미사** — `OrderId` 같은 조회 값으로 해시를 계산해 접미사로 붙입니다. 특정 항목은 `GetItem`이 가능하지만, **하루치 전체 조회는 여전히 모든 접미사를 Query해 병합**해야 합니다.

⚠️ **완충 장치는 근본 해법이 아닙니다.** **적응형 용량**은 모든 테이블에 자동·무료로 켜져 있고 트래픽이 테이블 총 프로비저닝이나 파티션 최대 용량을 넘지 않는 한 핫 파티션을 스로틀 없이 처리합니다. **버스트 용량**은 미사용 용량을 최대 300초 분량 best-effort로 보관할 뿐 **파티션 수준 스로틀을 막지 못합니다.** 읽기 쏠림은 **DAX**가 흡수할 수 있습니다.

> 🧠 **원리** — 테이블 총 용량이 남아도 요청이 **소수의 파티션 키 값에 몰리면** 그 파티션의 상한에서 스로틀됩니다. 그래서 "용량을 늘렸는데도 스로틀된다"의 정답은 거의 항상 **키 설계**입니다.

### 7) 읽기 일관성 모델 (기술 1.3.4) {#consistency}

| 읽기 대상 | 최종적 일관성 | 강력한 일관성 |
|---|---|---|
| 테이블 | 지원(**기본값**) | 지원 — `ConsistentRead=true` |
| LSI | 지원 | **지원** |
| **GSI** | 지원(**유일**) | ⚠️ **불가** — `ConsistentRead=true`면 `ValidationException` |
| DynamoDB Streams | 지원(유일) | 불가 |
| 글로벌 테이블 | **MREC**(기본): 비동기 복제, 보통 1초 내 | **MRSC**: 동기 복제 |
| DAX 캐시 | 히트 시 캐시 값 | `ConsistentRead=true`는 **DynamoDB로 패스스루** |

- 쓰기가 **HTTP 200으로 성공하면 내구성 있게 저장**된 것입니다. DynamoDB는 **read-committed 격리**를 제공해 커밋된 값만 읽히지만, 읽은 직후의 수정까지 막지는 않습니다.
- ⚠️ **강력한 일관성 읽기는 처리량을 2배 씁니다**(비용 2배)이고 지연이 더 클 수 있습니다. `Scan`도 기본은 최종적 일관성이며 `ConsistentRead=true`면 RCU가 2배입니다. 트랜잭션 읽기는 **4 KB당 2 read units**입니다.
- **GSI는 베이스 테이블 변경을 비동기로 반영**하며 보통 1초 미만이지만 드물게 더 길어질 수 있어 **앱이 오래된 결과를 가정**해야 합니다.
- 글로벌 테이블 **MREC는 last writer wins**로 수렴시킵니다. **MRSC**는 쓰기가 다른 리전에 동기 복제된 뒤 반환되고 **정확히 3개 리전**으로 구성하며 ⚠️ **트랜잭션 API·TTL·LSI를 지원하지 않습니다.** 일관성 모드는 **생성 시 정하고 이후 바꿀 수 없습니다.**

> 🧠 **원리** — GSI가 강력한 일관성을 못 주는 이유는 **GSI가 베이스 테이블과 별도 파티션 공간에 저장되고 따로 확장되기** 때문입니다. 쓰기가 인덱스에 전파되는 데 시간이 걸리므로, 인덱스를 읽는 순간의 "최신"을 보장할 수 없습니다.

### 8) Query와 Scan (기술 1.3.4) {#query-scan}

| 구분 | **GetItem** | **Query** | **Scan** |
|---|---|---|---|
| 필요한 입력 | **전체 기본 키** | **PK 동등 조건 필수**, SK 조건 선택 | 없음(전체 읽기) |
| 읽는 범위 | 항목 1개(⚠️ **GSI에는 사용 불가**) | 같은 PK 값의 항목들(테이블·LSI·GSI) | 테이블·인덱스의 **모든 항목** |
| 결과 순서 | — | **항상 SK 순**(`ScanIndexForward=false`면 역순) | PK 간 임의, 같은 PK 안은 SK 오름차순 |
| 1회 응답 한도 | — | **1 MB**(필터·프로젝션 적용 **전**) | **1 MB**(필터 적용 전) |
| 필터 | — | `FilterExpression`(⚠️ **PK·SK 속성 사용 불가**) | `FilterExpression`(키 속성도 가능) |

- Query의 **키 조건에는 비키 속성을 쓸 수 없고**, SK 조건 연산자는 `=`·`<`·`<=`·`>`·`>=`·`BETWEEN`·`begins_with`입니다.
- ⚠️ **`FilterExpression`은 읽은 뒤에 적용됩니다** — 소모 RCU는 필터 유무와 같고 **1 MB 한도도 필터 전**에 적용됩니다. 필터는 **"덜 돌려받게" 할 뿐 "덜 읽게" 하지 않습니다.** 많이 읽어 대부분 버리는 Query는 피하라고 권고합니다.
- **페이지네이션**: 응답에 `LastEvaluatedKey`가 있으면 그 값을 다음 요청의 `ExclusiveStartKey`로 넣어 반복하며, **`LastEvaluatedKey`가 없을 때만 끝**입니다. ⚠️ `Limit`은 **필터 적용 전에 평가할 최대 항목 수**라 필터 후 결과는 `Limit`보다 적을 수 있습니다.
- ⚠️ **`ScannedCount`(필터 전)가 `Count`(필터 후)보다 훨씬 크면 비효율적 Scan 신호**입니다.
- **병렬 Scan**: 워커마다 `Segment`와 `TotalSegments`를 지정해 구간을 나눠 읽습니다(순차 Scan은 한 번에 한 파티션만 읽어 단일 파티션 최대치에 묶입니다). 다만 프로비저닝 처리량을 모두 소모할 수 있어 `Limit`으로 조절하고, **PK가 고르지 않으면 세그먼트를 늘려도 빨라지지 않을 수** 있습니다.
- 대안: 키를 아는 여러 항목은 **`BatchGetItem`**(항목별로 4 KB 올림 후 합산), 다른 속성으로 조회는 **GSI·LSI**입니다.

> 🧠 **원리** — Query는 **PK 해시로 한 파티션 안의 정렬된 구간만** 읽습니다. Scan은 모든 항목을 읽으므로 테이블이 커질수록 느려지고 비싸집니다. "조건을 걸었으니 적게 읽는다"가 성립하지 않는 이유도 같습니다 — 조건(필터)은 **읽은 다음** 단계입니다.

### 9) 키와 인덱스 (기술 1.3.4) {#indexes}

기본 키는 두 종류입니다 — **단순 키**(파티션 키만)와 **복합 키**(파티션 키 + 정렬 키). 복합 키에서는 같은 파티션 키 값의 항목이 여럿이어도 **정렬 키 값이 서로 달라야** 합니다. 키 속성 타입은 **문자열·숫자·이진만** 가능하고, 값 길이 한도는 **파티션 키 2,048 B · 정렬 키 1,024 B**입니다.

| 특성 | **GSI** | **LSI** |
|---|---|---|
| 키 구성 | 단순 또는 복합, **임의 속성** | 반드시 복합: **PK는 베이스와 동일**, SK만 다름 |
| 생성 시점 | 테이블 생성 시 **또는 이후 추가·삭제 가능** | ⚠️ **테이블 생성 시에만**(추가·삭제 불가) |
| 쿼리 범위 | 전체 테이블(모든 파티션) | 지정한 PK 값의 **단일 파티션** |
| 읽기 일관성 | ⚠️ **최종적 일관성만** | 최종적 **또는 강력** 선택 |
| 처리량 | **인덱스 자체 RCU/WCU** | **베이스 테이블 용량** 사용 |
| 크기 제한 | 없음 | ⚠️ **PK 값당 10 GB 이하** |
| 투영 밖 속성 | **요청 불가** | 요청하면 테이블에서 가져온다 |
| 테이블당 개수 | 기본 **20** | **5** |

- **투영**: `KEYS_ONLY`(가장 작음) / `INCLUDE` / `ALL`(가장 큼). 필요한 속성만 투영하면 저장·쓰기 비용이 줄고, 자주 쓰는 속성을 빼면 **베이스 테이블을 추가 조회**해야 합니다. `INCLUDE` 투영 속성은 테이블의 모든 인덱스 합쳐 **최대 100개**입니다.
- **희소 인덱스**: GSI는 **자신의 키 속성이 존재하는 항목만** 담고, GSI 키 값은 **유일할 필요가 없습니다.**
- **GSI 주의**: ① ⚠️ **`GetItem`·`BatchGetItem` 불가**(Query·Scan만) ② 프로비저닝 테이블에서 **GSI 쓰기 용량이 부족하면 베이스 테이블 쓰기가 스로틀**되므로 GSI 쓰기 용량은 베이스 이상으로 ③ 키 속성 타입이 인덱스 정의와 다르면 `ValidationException` ④ GSI는 베이스 테이블의 **용량 모드·테이블 클래스를 따릅니다.**
- **LSI 주의**: 같은 PK의 항목 컬렉션(테이블 + 투영된 LSI 항목)이 **10 GB를 넘으면 `ItemCollectionSizeLimitExceededException`**입니다. LSI가 있는 테이블은 항목 데이터와 모든 LSI 항목의 합도 **400 KB 이하**여야 합니다.
- **설계 원칙**: 접근 패턴을 먼저 정하고, 관련 데이터를 함께 두고, 정렬 순서를 활용하고, 질의를 분산하고, **필요한 질의마다 GSI를 만듭니다.**

> 🧠 **원리** — LSI의 10 GB 한도는 **LSI 항목이 베이스 항목과 같은 파티션에 함께 저장되기** 때문입니다. PK를 공유하므로 항목 컬렉션이 여러 파티션으로 나뉘지 못하고, 그래서 한 PK가 담을 수 있는 총량에 상한이 생깁니다. GSI는 별도 공간이라 이 한도가 없습니다.

---

## ✍️ 시험 포인트

- **"용량을 늘렸는데도 스로틀된다"** → **파티션 키 카디널리티**. 적응형 용량·버스트는 완충이고 처방은 **키 설계·쓰기 샤딩**입니다.
- **"GSI에서 방금 쓴 값이 안 보인다"** → GSI는 **최종적 일관성만**입니다. `ConsistentRead=true`를 주면 `ValidationException`입니다.
- **"필터를 걸었는데 비용이 그대로다"** → `FilterExpression`은 **읽은 뒤** 적용됩니다. `ScannedCount` ≫ `Count`면 설계를 바꿉니다(GSI·키 재설계).
- **"다른 속성으로 조회해야 한다"** → **GSI**. 그 속성으로 **같은 파티션 안에서 다른 정렬**이 필요하면 LSI이지만, **테이블 생성 시에만** 만들 수 있다는 제약이 보기를 가릅니다.
- **"코드 변경을 최소화하면서 DynamoDB 읽기를 마이크로초로"** → **DAX**(API 호환). 범용 캐시가 필요하거나 DynamoDB가 아니면 **ElastiCache**.
- **"만료된 항목이 조회에 나온다"** → TTL은 **즉시 삭제가 아닙니다**. `FilterExpression`으로 제외합니다.
- **"작은 객체가 Glacier로 안 넘어간다"** → **128 KB 미만은 기본 전환 제외**입니다.
- **"비현재 버전만 지우고 싶다"** → **`NoncurrentVersionExpiration`**. `Expiration`은 현재 버전에 **delete marker만** 추가합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 적응형 용량이 핫 파티션을 "해결"한다고 본다 | **완충**이다. 파티션 상한을 넘으면 스로틀되고 처방은 키 설계·쓰기 샤딩 |
| 버스트 용량을 상시 용량처럼 쓴다 | 미사용 용량을 **최대 300초 분량 best-effort**로 보관할 뿐이다 |
| GSI에 강력한 일관성 읽기를 쓴다 | **`ValidationException`**이다. GSI는 최종적 일관성만 |
| `FilterExpression`이 읽기 비용을 줄인다고 본다 | **읽은 뒤** 적용된다 — RCU와 1 MB 한도는 필터 전 기준 |
| `Limit`을 "결과 개수"로 본다 | **필터 전에 평가할 항목 수**다. 필터 후 결과는 더 적을 수 있다 |
| `LastEvaluatedKey`가 비어 보여 페이지네이션을 멈춘다 | **없을 때만** 끝이다. 있으면 `ExclusiveStartKey`로 계속 |
| GSI를 `GetItem`으로 읽으려 한다 | **Query·Scan만** 된다 |
| LSI를 나중에 추가하려 한다 | **테이블 생성 시에만** 만들 수 있다 |
| GSI 쓰기 용량을 베이스보다 작게 둔다 | 프로비저닝 테이블에서 **베이스 테이블 쓰기가 스로틀**된다 |
| TTL이 즉시 삭제라고 본다 | 보통 **수일 내**이고 그 사이 항목은 읽힌다 — 읽는 쪽에서 필터 |
| TTL 속성을 문자열로 넣는다 | **Number(Unix epoch 초)**가 아니면 무시된다 |
| DAX가 모든 읽기를 캐시한다고 본다 | **최종적 일관성 읽기만**이다. 강력한 일관성·트랜잭션은 패스스루 |
| 항목을 쓰면 DAX 쿼리 캐시도 갱신된다고 본다 | **두 캐시는 독립**이다 — 항목 쓰기는 쿼리 캐시를 무효화하지 않는다 |
| 모든 키에 같은 TTL을 준다 | 같은 시간대에 만료되어 thundering herd가 된다 — **TTL에 지터** |
| S3 Lifecycle 전환을 되돌릴 수 있다고 본다 | **하향식**이다(Standard-IA → Standard 불가) |

---

## 🧪 자가 점검

**Q1.** 테이블 프로비저닝 용량이 절반밖에 안 쓰이는데 `ProvisionedThroughputExceededException`이 난다. 원인과 근본 처방, 그리고 "완충"에 그치는 수단 둘은? (→ 6) 파티션 키)

<details><summary>정답 보기</summary>

요청이 **소수의 파티션 키 값에 몰려** 그 파티션의 상한(읽기 3,000 · 쓰기 1,000 units/s)에서 스로틀된 것입니다. 근본 처방은 **높은 카디널리티·균등 분포 키**로 바꾸거나 **쓰기 샤딩**(랜덤 접미사 또는 계산 접미사)을 적용하는 것입니다.

완충에 그치는 수단은 **적응형 용량**(자동·무료이지만 테이블 총 프로비저닝·파티션 최대 용량을 넘으면 소용없음)과 **버스트 용량**(미사용 용량을 최대 300초 분량 best-effort로 보관, 파티션 수준 스로틀은 막지 못함)입니다. 읽기 쏠림이라면 **DAX**가 흡수할 수 있습니다.
</details>

**Q2.** Query에 `FilterExpression`을 넣었는데 소모 RCU가 줄지 않았다. 왜 그런가? 그리고 비효율을 어떤 지표로 확인하는가? (→ 8) Query·Scan)

<details><summary>정답 보기</summary>

**`FilterExpression`은 항목을 읽은 뒤에 적용**되기 때문입니다. 소모 RCU는 필터 유무와 같고 **1 MB 응답 한도도 필터 전** 기준입니다. 필터는 "덜 돌려받게" 할 뿐 **"덜 읽게" 하지 않습니다.**

확인 지표는 **`ScannedCount`(필터 전)와 `Count`(필터 후)의 비**입니다 — `ScannedCount`가 훨씬 크면 많이 읽고 대부분 버리는 중이므로, 그 조건으로 조회할 **GSI를 만들거나 키를 재설계**합니다. 참고로 `Limit`도 **필터 전에 평가할 항목 수**라 결과가 `Limit`보다 적을 수 있습니다.
</details>

**Q3.** 주문 테이블을 고객 ID로도 조회해야 한다. GSI와 LSI 중 무엇을 고르고, 각각의 제약은? (→ 9) 키와 인덱스)

<details><summary>정답 보기</summary>

베이스 테이블의 파티션 키와 **다른 속성을 파티션 키로** 쓰려면 **GSI**입니다(LSI는 PK가 베이스와 같아야 하고 SK만 다릅니다). GSI는 **나중에 추가·삭제할 수 있고** 자체 RCU/WCU를 가지며 전체 테이블을 쿼리하지만, ⚠️ **최종적 일관성만** 지원하고 **`GetItem`·`BatchGetItem`을 쓸 수 없으며**(Query·Scan만), 프로비저닝 테이블에서 **GSI 쓰기 용량이 부족하면 베이스 테이블 쓰기가 스로틀**됩니다.

LSI는 **테이블 생성 시에만** 만들 수 있고 베이스 용량을 쓰며 **강력한 일관성**이 가능하지만, **PK 값당 항목 컬렉션 10 GB** 한도가 있습니다(초과 시 `ItemCollectionSizeLimitExceededException`).
</details>

**Q4.** TTL을 켰는데 만료 시각이 지난 항목이 조회 결과에 나온다. 정상인가? 코드에서 무엇을 해야 하는가? (→ 2) TTL)

<details><summary>정답 보기</summary>

**정상입니다.** TTL 삭제는 백그라운드로 처리되어 보통 **수일 내**에 일어나고(쓰기 처리량은 쓰지 않습니다), 그 사이 만료 항목은 **읽기·갱신이 됩니다.** 그래서 공식 문서는 Scan·Query에서 **`FilterExpression`으로 만료 항목을 제외**하고, 만료 항목을 갱신할 때는 **조건식**을 쓰라고 권장합니다.

⚠️ TTL 속성은 **Number(Unix epoch 초)**여야 하며 아니면 무시됩니다. 미래 시각으로 갱신하거나 속성을 지우면 삭제되지 않습니다. TTL 삭제는 Streams에 **서비스 삭제**로 기록되고 GSI·LSI에서도 제거됩니다.
</details>

**Q5.** DynamoDB 읽기 지연을 마이크로초로 줄이려 한다. DAX를 골랐을 때 캐시되지 않는 읽기와, 항목을 써도 갱신되지 않는 캐시는? (→ 5) ElastiCache·DAX)

<details><summary>정답 보기</summary>

캐시되지 않는 것은 **강력한 일관성 읽기와 트랜잭션 읽기**입니다 — DAX는 DynamoDB와 느슨하게 결합돼 있어 이들을 **패스스루**합니다. 캐시되는 것은 `GetItem`·`BatchGetItem`·`Query`·`Scan`의 **최종적 일관성 읽기**뿐입니다.

갱신되지 않는 것은 **쿼리 캐시**입니다 — 항목 캐시와 쿼리 캐시는 **독립**이라 **항목 쓰기가 쿼리 캐시를 무효화하지 않고**, 반대로 Scan으로 항목 캐시를 데울 수도 없습니다. 항목 캐시 TTL 기본은 **5분**이고, 항목이 없어도 **빈 결과를 캐시**합니다.
</details>

**Q6.** 캐시 노드를 새로 띄운 직후 DB 부하가 폭증했다. 무슨 현상이고 어떻게 완화하는가? (→ 4) 캐싱 전략)

<details><summary>정답 보기</summary>

**thundering herd**입니다 — 많은 프로세스가 같은 키의 미스를 동시에 겪어 같은 DB 질의를 병렬로 날립니다. **새 캐시 노드는 메모리가 비어 있어** 이 현상이 악화되고, TTL이 한꺼번에 만료될 때도 같습니다.

완화책은 **사전 워밍**과 **TTL에 지터를 더하는 것**입니다(같은 TTL을 일괄 적용하면 키들이 같은 시간대에 만료됩니다). 전략 조합으로는 **지연 로딩을 기반으로 깔고 특정 데이터에만 write-through를 얹고**, write-through로 갱신하는 키를 뺀 모든 키에 TTL을 주며 변화가 빠른 데이터는 몇 초짜리 짧은 TTL을 씁니다.
</details>

**Q7.** 버전 관리가 켜진 버킷에서 "오래된 버전만 영구 삭제"하려면 어떤 Lifecycle 액션인가? 그리고 작은 객체가 전환되지 않는 이유는? (→ 1) S3 Lifecycle)

<details><summary>정답 보기</summary>

**`NoncurrentVersionExpiration`**입니다(`NoncurrentDays`·`NewerNoncurrentVersions`로 조절, **복구 불가**). ⚠️ **`Expiration`은 현재 버전을 비현재로 남기고 delete marker를 추가**할 뿐이라 데이터가 남습니다.

작은 객체가 전환되지 않는 이유는 **128 KB 미만 객체가 기본적으로 전환 대상에서 제외**되기 때문입니다 — 필요하면 `ObjectSizeGreaterThan`·`ObjectSizeLessThan` 필터로 허용합니다. 그리고 전환은 **하향식**이라 되돌릴 수 없고, 규칙이 겹치면 **영구 삭제가 전환보다 우선**합니다.
</details>

---

### 📌 출처

1. Managing the lifecycle of objects (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html
2. Transitioning objects using Amazon S3 Lifecycle — https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html
3. Deleting object versions from a versioning-enabled bucket — https://docs.aws.amazon.com/AmazonS3/latest/userguide/DeletingObjectVersions.html
4. Using time to live (TTL) in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html
5. Select a database service for your Lambda-based applications — https://docs.aws.amazon.com/lambda/latest/dg/ddb-rds-database-decision.html
6. Caching strategies (Amazon ElastiCache) — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html
7. Comparing node-based Valkey, Memcached, and Redis OSS clusters — https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/SelectEngine.html
8. Caching Best Practices (AWS) — https://aws.amazon.com/caching/best-practices/
9. In-memory acceleration with DynamoDB Accelerator (DAX) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.html
10. DAX: How it works — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DAX.concepts.html
11. Designing partition keys to distribute your workload in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-uniform-load.html
12. Using write sharding to distribute workloads evenly — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-sharding.html
13. Core components of Amazon DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
14. DynamoDB read consistency — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadConsistency.html
15. Improving data access with secondary indexes in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html
16. Using Global Secondary Indexes in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html
17. Key condition expressions for the Query operation — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.KeyConditionExpressions.html
18. Filter expressions for the Query operation — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Query.FilterExpression.html
19. Scanning tables in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Scan.html
20. Constraints in Amazon DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Constraints.html
21. DynamoDB read and write operations — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/read-write-operations.html
22. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 1 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain1.html
