---
examGuideTaskId: dea-t2-1
certCode: DEA-C01
domain: 2
domainName: 데이터 스토어 관리
domainWeightPct: 26
title: 데이터 스토어 선택 (분석·NoSQL·스트림·벡터·잠금)
coversTasks:
  - "2.1"
sources:
  - title: Amazon Redshift provisioned clusters (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html
  - title: Considerations when choosing a table class in DynamoDB (공식 문서)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithTables.tableclasses.html
  - title: What is AWS Lake Formation? (공식 문서)
    url: https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html
  - title: Vector database options — Choosing an AWS vector database for RAG use cases (공식 문서)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-an-aws-vector-database-for-rag-use-cases/vector-db-options.html
  - title: Considerations when accessing federated data with Amazon Redshift (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/federated-limitations.html
  - title: Working with Amazon S3 Tables and table buckets (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html
  - title: DEA-C01 공식 시험 가이드 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
lastVerified: 2026-10-20
---

# 데이터 스토어 선택 (분석·NoSQL·스트림·벡터·잠금)

> **커버하는 공식 Task** — DEA-C01 · 도메인 2 「데이터 스토어 관리」(26%) · **Task 2.1 데이터 스토어 선택** (`dea-t2-1`)
> Skill이 **8개**로 도메인 2에서 가장 넓습니다. 서비스 소개가 아니라 **"이 요구사항이면 무엇을 고르는가"** 를 묻는 Task입니다.
> **Skill 2.1.7(오픈 테이블 형식)·2.1.8(벡터 인덱스 유형)은 v1.1 신규**, **2.1.3은 v1.1 개정**(HNSW·MemoryDB 예시 추가)입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.1의 Skill 항목)

- [ ] **요구사항 키워드 → 저장소**를 1:1로 매칭할 수 있다(분석·OLTP·key-value·스트림·검색·그래프·인메모리)
- [ ] Redshift의 **배포 형태(RA3·DC2·Serverless)** 와 **접근 패턴 구성**(분산 스타일·정렬 키·WLM·동시성 스케일링)을 구분한다
- [ ] EMR의 **HDFS vs S3(EMRFS)** 선택 기준과 **core vs task 노드**의 차이를 안다
- [ ] **Lake Formation이 저장소가 아니라 권한 계층**임을 설명하고 LF-Tag 기반 제어를 안다
- [ ] DynamoDB의 **용량 모드·테이블 클래스·파티션 한도·GSI/LSI**를 요구사항으로 고른다
- [ ] **벡터 인덱스 유형(HNSW·IVF·FLAT)** 의 차이와 서비스별 지원을 말할 수 있다
- [ ] **마이그레이션 도구**(Transfer Family·DataSync·DMS)와 **Redshift 원격 액세스**(페더레이션·MV·Spectrum·데이터 공유)를 상황에 맞게 고른다
- [ ] **잠금 경합 증상 → 진단·해제 절차**(Redshift·RDS)를 설명한다
- [ ] **Apache Iceberg 유지 관리 3종**과 **S3 Tables**가 그중 무엇을 대신해 주는지 안다

---

## 🎯 왜 중요한가

- 도메인 2는 채점 콘텐츠의 **26%** 로 두 번째로 큽니다. 그 안에서 2.1은 **Skill 8개**로 가장 넓고, Redshift·EMR·DynamoDB·Kinesis·MSK·RDS/Aurora·OpenSearch·S3까지 걸칩니다.
- 시험은 "무슨 서비스인가"가 아니라 **"요구사항 문장이 어느 교환(trade-off)을 가리키는가"** 를 묻습니다. 예측 불가 트래픽·저장 비용 지배·마이크로초 읽기·장기 재처리처럼, **요구사항 한 줄이 곧 정답 근거**입니다.
- v1.1에서 **오픈 테이블 형식(2.1.7)과 벡터 인덱스(2.1.8)가 신설**됐습니다. 새 Skill은 출제 비중이 올라갈 가능성이 있으니 개념을 확실히 잡아 두세요.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **관리형 스토리지** | managed storage | Redshift RA3·RG가 쓰는 저장 계층 — 노드의 로컬 SSD + S3 를 합쳐 컴퓨트와 따로 확장·과금 |
| **RPU** | Redshift Processing Unit | Redshift Serverless의 용량 단위. 1 RPU = 16 GB 메모리 |
| **슬라이스** | slice | Redshift 노드 안의 병렬 처리 단위. 적재 파일 수를 여기에 맞춘다 |
| **colocation** | colocation | 조인하는 두 테이블의 매칭 값을 같은 슬라이스에 두어 네트워크 이동을 없애는 것 |
| **핫 파티션** | hot partition | DynamoDB에서 한 파티션 키에 트래픽이 몰려 한도에 먼저 걸리는 상태 |
| **EFO** | enhanced fan-out | 소비자마다 전용 읽기 처리량을 주는 Kinesis Data Streams 소비자 방식 |
| **ANN** | approximate nearest neighbor | 정확도를 조금 양보하고 속도를 얻는 근사 최근접 이웃 검색 |
| **recall** | recall | 근사 검색이 진짜 정답을 얼마나 찾아내는가의 비율 |
| **오픈 테이블 형식** | open table format | S3 파일 위에 트랜잭션·스키마 진화·시간 여행을 얹는 표준(예: Apache Iceberg) |
| **compaction** | compaction | 작은 파일 여러 개를 큰 파일로 병합해 조회 성능을 올리는 유지 관리 |

---

## 📖 핵심 개념

### 1) 요구사항 → 저장소 선택 지도 {#store-map}

Skill 2.1.1은 "비용·성능 요구 → 저장소"를 고르는 능력입니다. 서비스 설명이 아니라 **지연 시간·동시성·보존 기간·트래픽 예측 가능성·운영 부담** 같은 키워드로 갈립니다.

| 저장소 | 이럴 때 고른다 | 핵심 제약·비용 특성 | 시험 단서 |
|---|---|---|---|
| **Amazon Redshift** | 대규모 SQL 분석 데이터 웨어하우스 | RA3·RG는 컴퓨트와 관리형 스토리지를 독립 확장, Serverless는 RPU-시간 과금 | "스토리지·컴퓨트 분리", "간헐적 ad hoc 분석" |
| **Amazon EMR** | Spark·Hadoop 처리 | 영구 데이터는 S3, 중간 결과는 HDFS가 흔한 구성 | "transient cluster", "Spot task node" |
| **AWS Lake Formation** | S3 데이터 레이크의 **세밀한 접근 제어** | **저장소가 아니라 권한 계층** | "열·행·셀 수준 권한", "중앙 거버넌스" |
| **Amazon RDS / Aurora** | 관계형 OLTP, 읽기 복제본으로 읽기 확장 | Aurora는 Standard vs I/O-Optimized 과금 선택 | "읽기 복제본", "I/O 비용 비중" |
| **Amazon DynamoDB** | 한 자릿수 밀리초 key-value | 용량 모드·테이블 클래스로 비용 조절, 파티션 한도 존재 | "예측 불가 트래픽", "저장 비용 지배" |
| **Kinesis Data Streams** | 실시간 수집 + 보존 기간 안의 재처리 | 보존 기본 24시간 ~ 최대 365일 | "replay", "샤드" |
| **Amazon MSK** | Apache Kafka 호환 | tiered storage로 장기 저비용 보존(프로비저닝 전용) | "Kafka", "장기 보존 + 비용" |
| **Amazon OpenSearch Service** | 검색·로그 분석 | UltraWarm·cold(S3 기반)로 오래된 로그 비용 절감 | "full-text search", "log analytics" |
| **Amazon MemoryDB** | **마이크로초 읽기 + 내구성** 있는 주 DB | Multi-AZ 트랜잭션 로그로 내구성 확보 | "fast key/value인데 주 DB" |
| **Amazon Neptune** | 관계 탐색이 중심인 그래프 데이터 | — | "highly connected", "그래프" |
| **Amazon Keyspaces** | Cassandra API·드라이버를 쓰는 워크로드 | — | "Cassandra" |
| **Amazon DocumentDB** | MongoDB API 애플리케이션(벡터 검색 지원) | — | "MongoDB 호환" |

> ⚠️ 가장 흔한 함정: **Lake Formation을 저장소로 고르는 것.** Lake Formation은 S3의 데이터와 Glue Data Catalog 메타데이터에 대한 **세밀한 접근 제어·거버넌스 계층**이고, 실제 저장은 S3입니다.

### 2) Redshift 배포 형태 — 비용 모델이 곧 선택지 {#redshift-deploy}

- **RA3·RG(관리형 스토리지)** — 노드의 빠른 로컬 SSD를 쓰고 장기 데이터는 S3에 둡니다. **컴퓨트와 스토리지를 독립적으로 확장·과금**하며, 데이터가 SSD에 있든 S3에 있든 **같은 요율**입니다.
- **DC2** — 데이터를 로컬 SSD에 두는 노드. **압축 기준 1 TB 미만** 데이터셋에 권장합니다. 데이터 증가가 예상되면 RA3입니다. **DS2는 더 이상 제공되지 않습니다.**
- **RG** — Graviton 기반 신규 노드 유형으로, **데이터 레이크 쿼리 엔진이 클러스터 자체 컴퓨트에서** 돕니다(RA3는 데이터 레이크 쿼리에 Spectrum을 씁니다). 시판 교재·문항은 아직 RA3·DC2·Serverless만 다룰 수 있습니다.
- **Serverless** — 용량 단위는 **RPU(1 RPU = 16 GB 메모리)**, 기본 base capacity는 **128 RPUs**입니다(최대치는 리전에 따라 512 또는 1024). 쿼리가 도는 동안 **RPU-시간을 초 단위(60초 최소)** 로 과금하고, **동시성 스케일링·Spectrum 요금이 따로 없습니다.**
- **비용 레버** — 예약 노드는 **steady-state 운영 워크로드**에 맞고, 클러스터를 일시 중지하면 백업 스토리지만 과금됩니다.

| 선택지 | 적합한 경우 | 시험 단서 |
|---|---|---|
| RA3·RG 프로비저닝 | 상시 가동·예측 가능한 대규모 워크로드, 데이터 성장 | "steady-state", "예약 노드" |
| DC2 | 압축 기준 1 TB 미만 소규모 | "작은 데이터셋 최저가" |
| Serverless | 간헐적·예측 불가 워크로드, 관리 최소화 | "ad hoc", "유휴 시 비용 최소" |

### 3) Redshift 접근 패턴 구성 — 분산·정렬·WLM·동시성 {#redshift-access}

- **분산 스타일(DISTSTYLE)** — 지정하지 않으면 **AUTO**입니다. AUTO는 작은 테이블을 ALL로 시작해, 커지면 KEY로, 적합한 컬럼이 없으면 EVEN으로 바꿀 수 있습니다.

| DISTSTYLE | 동작 | 적합한 경우 | 주의 |
|---|---|---|---|
| AUTO | 크기에 맞춰 자동 할당(기본값) | 초기 선택이 불분명할 때 | ALL→KEY→EVEN으로 바뀔 수 있음 |
| EVEN | 리더 노드가 슬라이스에 라운드 로빈 분배 | **조인에 참여하지 않는 테이블** | — |
| KEY | 같은 값을 같은 슬라이스에 배치 | 조인 키 기준 **colocation** | — |
| ALL | 전체 테이블을 모든 노드에 복사 | 모든 조인에서 함께 있어야 하는 **작은** 테이블 | **스토리지가 노드 수만큼 증가** |

- **정렬 키** — 최근 데이터를 주로 조회하면 **timestamp를 정렬 키 선두**에 둡니다. 자주 조인하는 컬럼을 **정렬 키이자 분산 키**로 지정하면 옵티마이저가 sort merge join을 고를 수 있습니다.
- **WLM** — 프로비저닝 클러스터의 기본값은 **자동 WLM(권장)**, **Serverless 워크그룹은 항상 자동 WLM**입니다. 수동 WLM은 정적이어서 대부분 권장하지 않습니다.
- **동시성 스케일링** — 동시 쿼리가 몰릴 때 임시 클러스터를 붙입니다. **쓰기 작업은 RG·RA3 노드에서만** 지원되고, 클러스터는 **하루 1시간의 무료 크레딧**을 쌓습니다(활성 클러스터당 최대 30시간 누적). **페더레이션 쿼리와는 함께 동작하지 않습니다.**

> 🧠 원리: 왜 "조인 키 = 분산 키"가 그렇게 자주 정답일까요?
> MPP 웨어하우스에서 조인의 진짜 비용은 계산이 아니라 **노드 사이 데이터 이동**입니다.
> 두 테이블을 같은 조인 키로 분산하면 매칭될 행이 처음부터 같은 슬라이스에 있어 이동이 사라집니다.
> ALL은 "작은 테이블을 전부 복사해 이동을 없애는" 다른 해법이고, 그 대가가 **노드 수만큼 늘어나는 스토리지와 느려지는 적재**입니다.

### 4) EMR 스토리지와 노드 구성 {#emr-storage}

- **HDFS** — 인스턴스에 분산 저장하며 **클러스터를 종료하면 회수되는 임시 저장소**입니다. **같은 데이터셋을 반복해서 읽거나 Disk I/O가 큰 워크로드**, 중간 결과 캐싱에 씁니다.
- **EMRFS(S3)** — 데이터셋을 실행마다 한 번 읽을 때 적합합니다. **컴퓨트와 스토리지를 분리**하므로 저장하려고 core 노드를 늘릴 필요도, **HDFS 복제 비용**도 없고, 여러 클러스터가 같은 데이터를 쓰며, 클러스터를 종료해도 데이터가 남습니다. 흔한 구성은 **입출력은 S3, 중간 결과는 HDFS**입니다.
- **커넥터 변경** — **EMR 7.10.0부터 S3A 파일 시스템이 기본 S3 커넥터**로 EMRFS를 대체했습니다(시험 문항은 여전히 "EMRFS" 용어를 쓸 수 있습니다).
- **노드 유형** — **task 노드는 HDFS에 데이터를 저장하지 않아** 임시 용량(Spot)에 적합하고, **core 노드가 HDFS 데이터를 보유**합니다.

### 5) Lake Formation — 저장소가 아니라 권한 계층 {#lake-formation}

- **역할** — S3의 데이터와 **Glue Data Catalog 메타데이터**에 대한 세밀한 접근 제어·공유를 중앙에서 관리합니다. **Lake Formation은 자체 권한 모델로 IAM 권한 모델을 보강**합니다.
- **강제 지점** — RDBMS식 grant/revoke로 **열·행·셀 수준** 제어를 하고, Athena·Amazon Quick·Redshift Spectrum·EMR·Glue에서 강제됩니다.
- **LF-TBAC** — LF-Tag(키-값 속성)를 Data Catalog 리소스에 붙이고 태그 기준으로 권한을 줍니다. **Data Catalog 객체가 많을 때 권장되는 방법**입니다. **IAM 태그와 LF-Tag는 서로 다른 것이며 호환되지 않습니다.**
- **점진 도입** — **hybrid access mode**로 Lake Formation 권한과 IAM 정책을 병행하면서 유스케이스 하나씩 전환할 수 있습니다. 별개로 여러 계정·조직 사이의 데이터 공유 기능도 제공합니다.

### 6) DynamoDB — 용량 모드·테이블 클래스·키·인덱스 {#dynamodb-store}

- **용량 모드** — **on-demand가 기본이자 권장**입니다. 요청 단위로 과금하고 용량 계획이 필요 없으며 이전에 도달한 트래픽 수준까지 즉시 확장합니다. **provisioned**는 트래픽이 **일정하거나 점진적으로 늘고 예측 가능할 때** 비용을 통제하려고 씁니다.
- **테이블 클래스** — Standard가 기본이고, **저장 비용이 Standard 테이블 처리량 비용의 50%를 넘으면 Standard-IA**가 총비용을 줄여 줍니다. 전환에 **애플리케이션 코드 변경이 필요 없고**, 보조 인덱스는 테이블과 같은 클래스를 씁니다. (S3 스토리지 클래스와 다른 개념입니다.)
- **키 설계** — 파티션 하나는 **읽기 3,000 단위/초·쓰기 1,000 단위/초**가 한도라, 한 키에 몰리면 핫 파티션이 됩니다. 모든 파티션 키에서 활동이 고르게 나오도록 설계합니다.
- **DAX** — DynamoDB 앞단 인라인 캐시로, **eventually consistent 읽기에서 마이크로초 응답**이 필요할 때 씁니다.

| 항목 | GSI | LSI |
|---|---|---|
| 키 | 파티션 키·정렬 키가 base table과 **달라도 됨** | 파티션 키는 **같고** 정렬 키만 다름 |
| 처리량 | **자체 설정**(테이블과 분리) | 테이블과 **공유** |
| 크기 | 제한 없음 | 파티션 키 값 하나당 인덱스 항목 총 **10 GB 이하** |
| 개수(기본) | 테이블당 **20개** | 테이블당 **5개** |

### 7) 스트림·관계형·검색 저장소의 갈림길 {#stream-rel-search}

- **Kinesis Data Streams** — 보존은 기본 **24시간, 최대 8,760시간(365일)**. **보존 기간을 줄이면 새 기간보다 오래된 레코드가 거의 즉시 접근 불가**가 되니 주의합니다. 샤드 하나는 쓰기 **1 MB/초(1,000 records/초)**, on-demand 신규 스트림의 기본 처리량은 **쓰기 4 MB/s·읽기 8 MB/s**이며 기본적으로 on-demand 스트림은 **50개**까지 만듭니다(한도 증설 요청 가능).
- **Amazon MSK tiered storage** — primary + 저비용 두 티어로 보존 비용을 낮춥니다. **프로비저닝 모드 전용**, 저비용 스토리지 **최소 보존 3일**, **compacted topic 미지원**입니다.
- **Aurora** — 한 클러스터 볼륨을 공유하는 **Aurora Replica를 최대 15개**, 복제 지연은 보통 **100밀리초보다 훨씬 짧습니다**. 스토리지 구성은 **I/O 지출이 전체 Aurora 지출의 25% 이상이면 I/O-Optimized**, 그보다 적으면 Standard가 유리하고 **Standard→I/O-Optimized 전환은 30일에 한 번**입니다.
- **RDS 읽기 복제본 vs Multi-AZ** — 읽기 복제본은 **비동기 복제로 읽기 트래픽을 분산**하고, **Multi-AZ standby는 동기 복제이지만 읽기 트래픽을 받지 못합니다.**
- **OpenSearch 비용** — 오래된 로그는 **UltraWarm·cold storage**로 옮기고 **ISM**으로 티어 이동·보존을 관리합니다. UltraWarm은 **S3를 스토리지로 써서 데이터가 불변이고 사본이 하나만 필요**하며, hot 데이터가 약 **2.5 TiB** 규모일 때부터 비용 효율적입니다.
- **S3 클래스(2.1 관점)** — 접근 패턴을 **모르거나 변하면 Intelligent-Tiering**입니다. **30일 연속 미접근** 객체를 Infrequent Access 티어로 옮기고 **retrieval 요금이 없으며**, **128 KB 미만 객체는 모니터링·자동 티어링 대상이 아닙니다.** Standard-IA·One Zone-IA는 **128 KB보다 큰 객체를 30일 이상** 저장하는 용도입니다. (수명 주기 정책 운영은 `dea-t2-3`.)

### 8) 벡터 저장소와 인덱스 유형 — HNSW·IVF·FLAT {#vector-index}

**정확 검색 vs 근사 검색.** 인덱스가 없으면 모든 벡터와 거리를 계산하는 **정확(exact) 검색**이라 정확하지만 큰 데이터셋에서는 성능이 부족할 수 있습니다. **ANN 인덱스는 정확도를 조금 양보하고 속도를 얻습니다.** MemoryDB의 **FLAT**은 인덱스의 모든 벡터를 선형으로 처리하는 brute force 방식이라 정확한 답을 줍니다.

- **HNSW(Hierarchical Navigable Small World)** — 벡터를 **다층 그래프**로 조직합니다. IVFFlat보다 **구축은 느리지만 쿼리 성능과 recall이 좋고, 훈련 단계가 없어 초기 데이터 적재 없이 인덱스를 만들 수 있습니다.** 조정 값은 구축 시 `m`·`ef_construction`, 검색 시 `hnsw.ef_search`이며, `m`이 크면 메모리를 더 쓰고 근사 품질이 좋아질 수 있습니다. MemoryDB에서는 `M`·`EF_CONSTRUCTION`을 **생성 시 정하고 바꿀 수 없으며** `EF_RUNTIME`만 쿼리마다 덮어씁니다.
- **IVF(IVFFlat)** — 벡터 공간을 **K-means로 영역(lists)** 으로 나누고 쿼리 시 가까운 영역 일부(**probes**)만 검색합니다. probes를 늘리면 recall이 좋아지지만 성능이 떨어지고, **중심점을 정하려면 데이터가 먼저 있어야 해 테이블에 적재한 뒤 인덱스를 만듭니다.**
- **pgvector** — PostgreSQL 확장으로 Aurora PostgreSQL·RDS for PostgreSQL에서 쓰며 **0.5.0 버전부터 IVFFlat과 HNSW를 지원**합니다.

| 서비스 | 확인된 인덱스 유형 | 선택 단서 |
|---|---|---|
| Aurora PostgreSQL · RDS for PostgreSQL (pgvector) | IVFFlat, HNSW | **관계형(SQL) 쿼리와 벡터 검색을 같은 DB에서** |
| Amazon DocumentDB | HNSW, IVFFlat | MongoDB API 앱에 벡터 검색 추가 |
| Amazon OpenSearch Service | HNSW(NMSLIB·Faiss·Lucene), IVF(Faiss) | 풀텍스트 검색과 벡터 검색을 한 플랫폼에서 |
| Amazon MemoryDB | **FLAT, HNSW** | 초저지연 실시간 애플리케이션 |
| Amazon S3 Vectors | (문서에 알고리즘 명시 없음) | 인덱스당 최대 20억 벡터, 장기 저장·드문 조회에 최적화 |
| Neptune Analytics | (문서에 알고리즘 명시 없음) | GraphRAG — 벡터 검색 + 그래프 탐색 |

- **MemoryDB vs ElastiCache vs DAX** — MemoryDB는 **마이크로초 읽기·단일 자릿수 밀리초 쓰기**에 **Multi-AZ 트랜잭션 로그로 내구성**을 갖춘 **주 DB**입니다. **ElastiCache는 다른 DB 앞단의 캐시**, **DAX는 DynamoDB 전용 인라인 캐시**입니다.
- **Bedrock Knowledge Bases 벡터 스토어**(API 허용값): OpenSearch Serverless, Pinecone, Redis Enterprise Cloud, RDS(Aurora), MongoDB Atlas, Neptune Analytics, OpenSearch Managed Cluster, S3 Vectors. **EMR Serverless는 벡터 스토어가 아닙니다.**

> 🧠 원리: 왜 "빈 테이블에 인덱스부터 만들고 싶다"가 HNSW의 단서일까요?
> IVFFlat은 **데이터를 K-means로 군집화해 중심점을 먼저 구해야** 영역을 나눌 수 있습니다 — 데이터가 없으면 중심점이 없습니다.
> HNSW는 들어오는 벡터를 그래프에 차례로 이어 붙이는 구조라 **훈련 단계가 없고**, 그래서 비어 있는 테이블에도 인덱스를 먼저 만들어 둘 수 있습니다.
> 대신 그래프를 유지하는 대가로 구축이 느립니다 — "선적재 필요 여부"와 "구축 속도"가 한 쌍의 교환입니다.

### 9) 마이그레이션 도구 통합 {#migration-tools}

"**무엇을 옮기나(파일/DB)·어떤 프로토콜·온라인인가**"로 갈립니다.

| 도구 | 주 용도 | 소스·대상 | 시험 단서 |
|---|---|---|---|
| **AWS Transfer Family** | 표준 프로토콜로 **외부 파트너와 파일 교환** | **SFTP·FTPS·FTP·AS2**(및 브라우저) ↔ **S3·EFS** | "third parties와 SFTP", "서버 운영 제거" |
| **AWS DataSync** | 대량 파일·객체의 **온라인 이전·정기 복제** | NFS·SMB·HDFS·객체 스토리지 ↔ S3·EFS·FSx | "NFS/SMB 마이그레이션", "예약 전송·검증" |
| **AWS DMS** | **데이터베이스 이전과 지속 복제**(동종·이종) | DB 소스 → 목표 DB | "minimal downtime", "heterogeneous" |
| ~~Snow Family~~ | 오프라인 대용량 이전 | **Snowball Edge는 신규 고객 제공 중단** | 보기에 Snow가 보이면 **최신성 함정** 의심 |

- Transfer Family는 **최대 3개 AZ**에 걸친 오토스케일링 플릿이 뒷받침합니다.
- DMS는 **일회성 이전 또는 지속 복제** 작업을 설정할 수 있고, 이전 중에도 소스 DB를 운영 상태로 둘 수 있습니다.

### 10) Redshift 원격 액세스·데이터 이동 {#redshift-remote}

| 방식 | 데이터 위치 | 핵심 특성 | 제약 | 선택 기준 |
|---|---|---|---|---|
| **페더레이션 쿼리** | 운영 RDS·Aurora(PostgreSQL·MySQL) | 라이브 데이터를 Redshift·S3 쿼리와 함께 조회 | **읽기 전용**, **동시성 스케일링 미지원**, 리전이 다르면 지연·전송 요금 | "운영 DB **최신** 데이터와 조인" |
| **구체화된 뷰(MV)** | Redshift 내부 | 미리 계산된 결과, 증분 또는 전체 새로 고침 | **새로 고치기 전에는 최신이 아님**, 자동 새로 고침은 지연될 수 있음 | "반복되는 무거운 집계 가속" |
| **Spectrum** | S3 외부 테이블 | **로드·ETL 없이** S3 쿼리 | **UPDATE·DELETE 불가**, RA3·DC2는 클러스터와 버킷이 **같은 리전** | "S3 데이터 레이크 쿼리" |
| **데이터 공유** | 다른 Redshift 클러스터·워크그룹 | **복사·이동 없이** 라이브 공유 | Redshift 사이의 공유 | "팀·계정 간 공유" |
| **Zero-ETL** | Aurora → Redshift | 거의 실시간 분석, **ETL 파이프라인 구축·유지 불필요** | Aurora가 소스 | "ETL 제거" |

- MV의 새로 고침은 **증분이 가능하면 증분으로, 불가능하면 전체**로 합니다. `AUTO REFRESH`를 켜면 기반 테이블 변경 후 자동으로 새로 고칩니다.
- RG 클러스터와 Serverless는 **통합 데이터 레이크 쿼리 엔진이 자체 컴퓨트에서** 돌며 리전 간 S3 쿼리도 지원합니다.

### 11) 잠금 관리 — 증상에서 조치까지 {#lock-management}

- **Redshift 테이블 잠금** — `LOCK` 명령은 트랜잭션 블록 안에서 **ACCESS EXCLUSIVE** 모드의 테이블 잠금을 얻어 다른 세션의 읽기·쓰기를 대기시키고, **LOCK을 포함한 트랜잭션이 끝나면 풀립니다**. `DROP TABLE`·`TRUNCATE` 같은 일부 DDL도 **독점 잠금**을 만듭니다.
- **진단** — `SVV_TRANSACTIONS`로 **열린 트랜잭션과 잠금 경합**을 확인합니다. `STV_LOCKS`는 현재 테이블 갱신을 보여 주며 **수퍼유저만** 볼 수 있습니다.
- **해제** — 잠금을 쥔 세션을 **`PG_TERMINATE_BACKEND`로 종료**하면 트랜잭션이 롤백되고 모든 잠금이 풀립니다. **트랜잭션 블록(BEGIN…END) 안이라 쿼리를 취소할 수 없으면 세션 자체를 종료**합니다.
- **격리 수준** — **SNAPSHOT이 프로비저닝 클러스터·Serverless 워크그룹의 기본값**으로 더 많은 데이터를 더 짧은 시간에 처리하게 하고, **SERIALIZABLE은 더 엄격**해 충돌하는 동시 트랜잭션을 `serializable isolation violation` 오류로 취소합니다.
- **데드락** — 스냅샷 격리에서 `INSERT`·`COPY`가 공유 잠금으로 진행하는 중 한 트랜잭션이 `UPDATE`·`DELETE`·`MERGE`·DDL처럼 **독점 잠금이 필요한 문장을 이어 실행**하면 데드락이 날 수 있습니다. **독점 잠금 문장을 별도 트랜잭션으로 분리**하거나 재시도 로직을 둡니다.
- **RDS for PostgreSQL** — 행 수준 잠금을 세밀하게 쓰므로 같은 행에 동시 요청이 몰리면 충돌이 커집니다. **COMMIT/ROLLBACK 없이 열린 채 둔 `idle in transaction` 세션과 장기 트랜잭션이 잠금을 오래 쥡니다.** `pg_stat_activity`·`pg_locks`로 진단합니다.
- **RDS for MySQL** — 잠금 대기가 `innodb_lock_wait_timeout`(**기본 50초**)을 넘으면 **error 1205**로 현재 문장이 롤백됩니다. 잠금을 쥔 세션은 `SHOW ENGINE INNODB STATUS`로 확인합니다.
- **모니터링 도구 공지** — **RDS Performance Insights는 2026-06-30 수명 종료**이며, 업그레이드하지 않으면 **Database Insights의 Standard mode**가 기본이 되고 실행 계획·온디맨드 분석은 Advanced mode에서만 지원됩니다.

### 12) 오픈 테이블 형식 — Apache Iceberg와 S3 Tables {#open-table-format}

**Apache Iceberg**는 S3의 대용량 데이터셋을 위한 오픈 테이블 형식으로 **빠른 쿼리 성능, 원자적 커밋, 동시 쓰기, SQL 호환 테이블 진화**를 제공합니다. **스키마 진화·파티션 진화**를 지원하고, 변경을 추적해 **time travel 쿼리와 과거 버전 롤백**이 가능합니다.

- **엔진 지원** — **Glue 3.0 이상**은 Iceberg·Hudi·Delta Lake를 지원하고, **EMR은 6.5.0부터** Spark 3에서 Iceberg를 씁니다. **Redshift는 Glue Data Catalog의 Iceberg 테이블을 트랜잭션 일관성으로 조회**하고 S3·S3 table bucket의 Iceberg 테이블을 만들고 쓸 수도 있습니다. 단 **Iceberg 테이블을 Redshift 로컬 테이블로 적재할 때는 `INSERT INTO`·CTAS를 쓰며 `COPY`는 쓸 수 없습니다.**
- **직접 운영 시 유지 관리 3종** — ① **compaction**(작은 파일·delete 파일 병합) ② **snapshot expiration**(오래된 스냅샷 제거) ③ **unreferenced file removal**(고아 파일 제거). Athena에서는 **`OPTIMIZE`가 bin-packing으로 작은 파일을 병합**하고, **`VACUUM`이 스냅샷 만료와 고아 파일 제거**를 수행합니다. **스냅샷을 만료하면 그 스냅샷으로는 더 이상 time travel할 수 없습니다.** Athena 기본값은 최소 보존 스냅샷 **1개**, 최대 스냅샷 보존 **432,000초(5일)** 입니다.
- **자동 최적화** — **Glue Data Catalog**는 Iceberg 테이블의 compaction·스냅샷 보존·고아 데이터 관리를 자동 수행합니다(compaction은 파일 수가 설정값(기본 5개)을 넘고 각 파일이 목표 크기의 75% 미만일 때 시작).
- **S3 Tables** — **table bucket**은 테이블 전용 버킷으로, 테이블이 **Iceberg 형식**으로 저장되고 **compaction·스냅샷 관리·미참조 파일 제거를 자동 수행**합니다. **Iceberg V3**를 지원하며 compaction 기본 목표 파일 크기는 **512MB**(64MB~512MB로 변경 가능), 스냅샷 관리 기본값은 **MinimumSnapshots 1·MaximumSnapshotAge 120시간**입니다. 일반 버킷의 Iceberg 테이블 대비 **최대 10배 높은 TPS**를 제공합니다.

| 항목 | 일반 S3 버킷의 Iceberg(직접 관리) | S3 Tables(table bucket) |
|---|---|---|
| 유지 관리 | `OPTIMIZE`·`VACUUM`을 직접 하거나 **Glue 자동 최적화** 사용 | compaction·스냅샷 관리·미참조 파일 제거 **자동** |
| 성능 | — | 높은 TPS·쿼리 처리량(**최대 10배 TPS**) |
| 시험 단서 | "작은 파일이 쌓인다", "스냅샷이 늘어난다" | **"운영 부담 최소"** |

---

## ✍️ 시험 포인트

- "**예측 불가 트래픽 + 용량 계획 없이**" → DynamoDB **on-demand**. "**저장 비용이 처리량 비용의 50% 초과**" → **Standard-IA 테이블 클래스**(코드 변경 없음). 둘은 다른 축이니 섞지 마세요.
- "**마이크로초 읽기 + 내구성 있는 주 DB**" → **MemoryDB**. "**DynamoDB 읽기 가속**" → **DAX**. "**다른 DB 앞단 캐시**" → **ElastiCache**.
- "**간헐적·예측 불가 분석**" → **Redshift Serverless**(유휴 시 컴퓨트 과금 없음). "**steady-state**" → 예약 노드.
- "**소비자를 늘렸는데 읽기 스로틀**" 같은 스트림 문제는 Task 1.1 영역이고, 2.1에서는 **보존·비용**이 쟁점입니다 — "**1년 재처리**"는 KDS 보존 연장, "**Kafka 장기 저비용 보존**"은 MSK **tiered storage**(프로비저닝 전용·최소 3일).
- "**운영 DB의 최신 데이터와 조인, ETL 없이**" → **페더레이션 쿼리**(읽기 전용). "**S3 데이터를 로드 없이**" → **Spectrum**(UPDATE·DELETE 불가). "**다른 클러스터와 복사 없이 공유**" → **데이터 공유**. "**Aurora를 거의 실시간 분석**" → **zero-ETL**.
- "**빈 테이블에 벡터 인덱스를 먼저**" → **HNSW**(훈련 단계 없음). "**IVFFlat**"은 중심점 계산 때문에 **데이터 선적재 필요**.
- "**트랜잭션이 열린 채 멈춰 다른 세션이 대기**" → `SVV_TRANSACTIONS` 확인 후 **`PG_TERMINATE_BACKEND`**. 트랜잭션 블록 안의 쿼리는 취소할 수 없습니다.
- "**작은 파일 + 오래된 스냅샷**" → Athena **`OPTIMIZE` + `VACUUM` 둘 다**. 하나로는 둘 다 못 잡습니다. "**유지 관리 부담 자체를 없애고 싶다**" → **S3 Tables** 또는 **Glue 자동 최적화**.
- 최신성 함정: **Snowball Edge는 신규 고객 제공 중단**(대안은 DataSync), **EMR 7.10.0부터 S3A가 기본 커넥터**, **RDS Performance Insights 2026-06-30 수명 종료**, **DS2 노드 제공 종료**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"Lake Formation은 데이터 레이크 저장소다."** → ❌. Lake Formation은 **S3 데이터와 Glue Data Catalog 메타데이터의 접근 제어·거버넌스 계층**이고 **IAM 권한 모델을 보강**합니다. 저장은 S3입니다.
   (원리: §1·§5 — "어디에 담는가"와 "누가 볼 수 있는가"는 다른 축이다.)
2. **"on-demand로 바꾸면 저장 비용도 줄어든다."** → ❌. 용량 모드는 **처리량 과금 방식**을 바꿀 뿐입니다. 저장 비용이 지배적이면 **Standard-IA 테이블 클래스**입니다.
3. **"소비자를 늘리려면 ALL 분산으로 바꾸면 된다"처럼 축을 섞는 보기.** → ❌. ALL은 **스토리지를 노드 수만큼 늘리는** 조인 colocation 수단이지 동시성·잠금·처리량 해법이 아닙니다.
4. **"DC2가 언제나 가장 싸다."** → ❌. DC2는 **압축 기준 1 TB 미만** 소규모에 권장됩니다. 데이터 증가가 예상되면 RA3입니다.
5. **"동시성 스케일링을 켜면 페더레이션 쿼리도 같이 빨라진다."** → ❌. **페더레이션 쿼리는 동시성 스케일링과 함께 동작하지 않습니다.** 쓰기 작업의 동시성 스케일링도 **RG·RA3 노드 전용**입니다.
6. **"Spectrum 외부 테이블도 UPDATE/DELETE 할 수 있다."** → ❌. **불가능**합니다. 또 RA3·DC2 프로비저닝 클러스터는 **버킷과 같은 리전**이어야 합니다.
7. **"구체화된 뷰는 항상 최신이다."** → ❌. MV는 **미리 계산된 결과**라 **새로 고치기 전에는 기반 테이블 변경이 반영되지 않습니다.** "항상 최신"이 요구사항이면 페더레이션 쿼리 방향입니다.
8. **"HDFS에 두면 클러스터를 종료해도 데이터가 남는다."** → ❌. HDFS는 **클러스터 종료 시 회수되는 임시 저장소**입니다. 지속이 필요하면 S3입니다. (**task 노드는 아예 HDFS에 데이터를 저장하지 않습니다.**)
9. **"IVFFlat은 빈 테이블에도 만들 수 있다."** → ❌. **중심점·영역 계산에 데이터가 필요해** 적재 후 만들어야 합니다. 빈 테이블에 먼저 만들 수 있는 쪽은 **HNSW**입니다.
10. **"`VACUUM`만 돌리면 작은 파일도 정리된다."** → ❌. Athena에서 **작은 파일 병합은 `OPTIMIZE`**, **스냅샷 만료·고아 파일 제거는 `VACUUM`** 입니다. 그리고 **만료한 스냅샷으로는 time travel할 수 없습니다.**
11. **"Iceberg 테이블도 `COPY`로 Redshift에 적재한다."** → ❌. **`COPY`는 쓸 수 없고** `INSERT INTO`·CTAS를 씁니다.
12. **"대용량이면 Snowball Edge."** → ❌. **신규 고객에게는 제공되지 않습니다.** 온라인 전송은 **DataSync**가 안내되는 대안입니다.
13. **"Multi-AZ standby로 읽기를 분산한다."** → ❌. **standby는 읽기 트래픽을 받지 못합니다.** 읽기 확장은 **읽기 복제본**(Aurora는 Aurora Replica, 최대 15개)입니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (문항 뱅크는 `dea-t2-1.questions.json` — 사람 검수 전이라 사이트에는 노출되지 않습니다)

**Q1.** 주문 이력 DynamoDB 테이블의 데이터 대부분이 오래되어 거의 읽히지 않고, 월 비용에서 **저장 비용이 읽기·쓰기 처리량 비용의 50%를 넘습니다.** 성능·내구성·가용성을 유지하고 **애플리케이션 코드 변경 없이** 총비용을 줄이려면?

<details><summary>정답 보기</summary>

**테이블 클래스를 DynamoDB Standard-IA로 변경합니다.** 저장 비용이 Standard 테이블 처리량 비용의 50%를 넘으면 Standard-IA가 총비용을 줄여 주고, 클래스 전환에는 애플리케이션 코드 변경이 필요 없습니다(보조 인덱스는 테이블과 같은 클래스를 씁니다). on-demand 전환은 처리량 과금 방식을 바꿀 뿐 저장 비용을 낮추지 않고, DAX는 읽기 지연을 줄이는 캐시입니다.
</details>

**Q2.** Aurora PostgreSQL에 있는 상품 데이터에 대해 **SQL 조인과 임베딩 유사도 검색을 같은 DB에서** 수행하려 합니다. 벡터 인덱스를 **빈 테이블에 먼저 만들고** 데이터를 점진 적재하면서도 높은 recall을 원합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**pgvector 확장을 설치하고 HNSW 인덱스를 만듭니다.** 관계형 쿼리와 벡터 검색을 한 DB에서 하려면 Aurora PostgreSQL + pgvector가 권장되고, pgvector는 0.5.0부터 IVFFlat과 HNSW를 지원합니다. **IVFFlat은 중심점 계산 때문에 데이터를 먼저 적재해야** 하지만 **HNSW는 훈련 단계가 없어** 빈 테이블에도 만들 수 있고 쿼리 성능·recall도 대체로 더 좋습니다.
</details>

**Q3.** Redshift 테이블을 **운영 Aurora PostgreSQL의 최신 주문 데이터와 조인**해야 합니다. 복사·적재 ETL 없이 **항상 최신 값**이어야 합니다.

<details><summary>정답 보기</summary>

**페더레이션 쿼리**(외부 스키마)를 씁니다. 외부 데이터베이스의 **라이브 데이터**를 Redshift·S3 쿼리와 통합하며 RDS·Aurora의 PostgreSQL·MySQL을 지원합니다. Spectrum은 S3 외부 테이블용이고, 구체화된 뷰는 새로 고치기 전에는 최신이 아니며, 데이터 공유는 Redshift 사이의 공유입니다. 단 페더레이션은 **읽기 전용**이고 **동시성 스케일링과 함께 동작하지 않습니다.**
</details>

**Q4.** 야간 ETL 세션이 트랜잭션을 연 채 멈춰 있고, 같은 테이블에 DDL과 쿼리를 보내는 다른 세션들이 계속 대기합니다. 가장 적절한 조치는?

<details><summary>정답 보기</summary>

**`SVV_TRANSACTIONS`로 열린 트랜잭션과 잠금 경합을 확인하고, 잠금을 쥔 세션을 `PG_TERMINATE_BACKEND`로 종료**합니다. 세션을 종료하면 트랜잭션이 롤백되고 모든 잠금이 풀립니다. **트랜잭션 블록 안의 쿼리는 취소할 수 없어** 세션 종료가 필요합니다. WLM 큐 조정이나 동시성 스케일링은 큐·용량 문제의 해법이지 테이블 잠금의 해법이 아닙니다.
</details>

**Q5.** Athena로 쿼리하는 Iceberg 테이블에 잦은 변경이 쌓여 **작은 파일이 많아지고, 오래된 스냅샷 때문에 스토리지도 늘고** 있습니다. 두 문제를 모두 해결하려면?

<details><summary>정답 보기</summary>

**`OPTIMIZE`로 작은 파일을 병합(compaction)하고, `VACUUM`으로 오래된 스냅샷과 고아 파일을 정리**합니다. 직접 운영하는 Iceberg는 compaction·snapshot expiration·unreferenced file removal 세 가지가 모두 필요합니다. `VACUUM`만으로는 작은 파일이 병합되지 않고, `OPTIMIZE`만으로는 스냅샷이 정리되지 않습니다. 운영 부담 자체를 줄이려면 **Glue Data Catalog 자동 최적화**나 **S3 Tables**를 씁니다. 단 **만료한 스냅샷으로는 time travel할 수 없습니다.**
</details>

---

**Q6 (원리).** 왜 Task 2.1의 문항은 "서비스 이름"이 아니라 거의 항상 **"요구사항 한 줄"** 로 갈릴까요?

<details><summary>정답 보기</summary>

**AWS의 데이터 저장소는 기능이 겹치도록 만들어져 있고, 서로 다른 것은 기능이 아니라 교환(trade-off)이기 때문입니다.** 같은 key-value 조회도 DynamoDB(관리형·확장)·MemoryDB(마이크로초·내구성)·DAX(DynamoDB 앞 캐시)가 모두 "할 수" 있습니다. 그래서 문항은 **무엇을 포기할 수 있는지**를 요구사항 문장에 심어 둡니다 — "코드 변경 없이"(테이블 클래스), "주 DB로"(MemoryDB), "예측 불가"(on-demand), "운영 부담 최소"(S3 Tables). 보기를 보기 전에 **요구사항에서 제약을 먼저 뽑아내는 순서**가 이 Task의 풀이법입니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. Amazon Redshift provisioned clusters — https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html
2. Compute capacity for Amazon Redshift Serverless — https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-capacity.html
3. Amazon Redshift Pricing — https://aws.amazon.com/redshift/pricing/
4. Distribution styles (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_choosing_dist_sort.html
5. Choose the best sort key (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-sort-key.html
6. Workload management (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_workload_mngmt_classification.html
7. Concurrency scaling (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/concurrency-scaling.html
8. Amazon EMR architecture and service layers — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-overview-arch.html
9. Choosing the right storage (Amazon EMR hardware, AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/amazon-emr-hardware/storage.html
10. Understand node types in Amazon EMR — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-master-core-task-nodes.html
11. What is AWS Lake Formation? — https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html
12. Lake Formation tag-based access control — https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
13. DynamoDB on-demand capacity mode — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/on-demand-capacity-mode.html
14. Considerations when choosing a table class in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithTables.tableclasses.html
15. Best practices for designing and using partition keys effectively in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html
16. General guidelines for secondary indexes in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-indexes-general.html
17. Evaluating the suitability of DAX for your use cases — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/evaluate-dax-suitability.html
18. Change the data retention period (Amazon Kinesis Data Streams) — https://docs.aws.amazon.com/streams/latest/dev/kinesis-extended-retention.html
19. Quotas and limits (Amazon Kinesis Data Streams) — https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
20. Tiered storage for Standard brokers (Amazon MSK) — https://docs.aws.amazon.com/msk/latest/developerguide/msk-tiered-storage.html
21. Amazon Aurora storage — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.StorageReliability.html
22. Managing performance and scaling for Aurora DB clusters — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Performance.html
23. Working with DB instance read replicas (Amazon RDS) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html
24. Operational best practices for Amazon OpenSearch Service — https://docs.aws.amazon.com/opensearch-service/latest/developerguide/bp.html
25. Understanding and managing Amazon S3 storage classes — https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
26. Features of MemoryDB — https://docs.aws.amazon.com/memorydb/latest/devguide/servicename-feature-overview.html
27. Choosing between MemoryDB and ElastiCache — https://docs.aws.amazon.com/memorydb/latest/devguide/related-services-choose-between-memorydb-and-redis.html
28. Vector search overview (Amazon MemoryDB) — https://docs.aws.amazon.com/memorydb/latest/devguide/vector-search-overview.html
29. Optimize generative AI applications with pgvector indexing (AWS Database Blog) — https://aws.amazon.com/blogs/database/optimize-generative-ai-applications-with-pgvector-indexing-a-deep-dive-into-ivfflat-and-hnsw-techniques/
30. Vector database options (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/choosing-an-aws-vector-database-for-rag-use-cases/vector-db-options.html
31. Vector search for Amazon DocumentDB — https://docs.aws.amazon.com/documentdb/latest/devguide/vector-search.html
32. Amazon OpenSearch Service's vector database capabilities explained (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/amazon-opensearch-services-vector-database-capabilities-explained/
33. StorageConfiguration (Agents for Amazon Bedrock API Reference) — https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent_StorageConfiguration.html
34. What is AWS Transfer Family? — https://docs.aws.amazon.com/transfer/latest/userguide/what-is-aws-transfer-family.html
35. AWS DataSync FAQs — https://aws.amazon.com/datasync/faqs/
36. AWS Database Migration Service Documentation (overview) — https://aws.amazon.com/documentation-overview/dms/
37. AWS Snowball Edge availability change — https://docs.aws.amazon.com/snowball/latest/developer-guide/snowball-edge-availability-change.html
38. Querying data with federated queries in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/federated-overview.html
39. Considerations when accessing federated data with Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/federated-limitations.html
40. Refreshing a materialized view (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html
41. Amazon Redshift Spectrum limitations — https://docs.aws.amazon.com/redshift/latest/dg/c-spectrum-considerations.html
42. Data sharing in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/datashare-overview.html
43. Developer productivity: zero-ETL integration with Amazon Redshift — https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-features-developer-productivity.html
44. LOCK (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_LOCK.html
45. STV_LOCKS (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_STV_LOCKS.html
46. PG_CANCEL_BACKEND (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/PG_CANCEL_BACKEND.html
47. Isolation levels in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/c_serial_isolation.html
48. Write and read/write operations (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_write_readwrite.html
49. Lock:transactionid (Amazon RDS for PostgreSQL wait event) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/wait-event.locktransactionid.html
50. How do I resolve "Error 1205: Lock wait timeout exceeded" in RDS for MySQL? — https://repost.aws/knowledge-center/rds-mysql-error-1205
51. synch/cond/innodb/row_lock_wait_cond (Amazon Aurora MySQL wait event) — https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/ams-waits.row-lock-wait-cond.html
52. How do I troubleshoot a slow query in Amazon RDS for MySQL? (Performance Insights 수명 종료 공지) — https://repost.aws/knowledge-center/rds-mysql-slow-query
53. Using Apache Iceberg tables with Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/querying-iceberg.html
54. Writing to Apache Iceberg tables (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/iceberg-writes.html
55. Iceberg (Amazon EMR Release Guide) — https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-iceberg.html
56. Using Data Lake frameworks with AWS Glue Studio — https://docs.aws.amazon.com/glue/latest/dg/gs-data-lake-formats.html
57. VACUUM (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/vacuum-statement.html
58. Working with Amazon S3 Tables and table buckets — https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html
59. Amazon S3 FAQs — https://aws.amazon.com/s3/faqs/
60. Amazon S3 Features — https://aws.amazon.com/s3/features/
61. Best practices for querying Apache Iceberg data with Amazon Redshift (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/best-practices-for-querying-apache-iceberg-data-with-amazon-redshift/
62. AWS Glue Data Catalog supports automatic optimization of Apache Iceberg tables (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/aws-glue-data-catalog-supports-automatic-optimization-of-apache-iceberg-tables-through-your-amazon-vpc/
63. DEA-C01 공식 시험 가이드 도메인 2 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
