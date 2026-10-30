---
examGuideTaskId: saa-t3-9
certCode: SAA-C03
domain: 3
domainName: 고성능 아키텍처 설계
domainWeightPct: 24
title: 데이터 수집·변환·분석 — Kinesis·Glue·Athena·EMR·Lake Formation
coversTasks:
  - "3.5"
sources:
  - title: Amazon Kinesis Data Streams — 소개 (공식)
    url: https://docs.aws.amazon.com/streams/latest/dev/introduction.html
  - title: Amazon Data Firehose — 서비스 소개 (공식)
    url: https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
  - title: AWS Glue — 서비스 소개 (공식)
    url: https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html
  - title: Amazon Athena — 서비스 소개 (공식)
    url: https://docs.aws.amazon.com/athena/latest/ug/what-is.html
  - title: Amazon EMR — 서비스 소개 (공식)
    url: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html
  - title: AWS Lake Formation — 서비스 소개 (공식)
    url: https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html
  - title: AWS DataSync FAQ — DataSync와 Storage Gateway를 언제 쓰는가 (공식)
    url: https://aws.amazon.com/datasync/faqs/
  - title: AWS Transfer Family FAQ — 요금 부과 방식 (공식)
    url: https://aws.amazon.com/aws-transfer-family/faqs/
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-10-20
---

# 데이터 수집·변환·분석 — Kinesis·Glue·Athena·EMR·Lake Formation

> **커버하는 공식 Task** — SAA-C03 · 도메인 3 「고성능 아키텍처 설계」(24%) · **Task 3.5 고성능 데이터 수집·변환 솔루션 결정** (`saa-t3-9`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 배치·스트리밍 수집부터 ETL·쿼리·분석·거버넌스까지 데이터 파이프라인 전 계층을 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.5의 Skill 항목 기반)

- [ ] **Kinesis 4종 구분** — Data Streams·Data Firehose·Managed Service for Apache Flink·Video Streams 각각의 역할과 선택 기준을 설명할 수 있다
- [ ] **샤드(Shard) 모델** — Kinesis Data Streams의 샤드당 처리량 한계와 스케일 방법을 안다
- [ ] **Firehose 목적지** — Firehose가 지원하는 적재 목적지와 버퍼 설정 방식을 설명할 수 있다
- [ ] **AWS Glue 구성 요소** — Data Catalog·크롤러·ETL 잡·Glue Studio의 역할을 구분할 수 있다
- [ ] **Athena 작동 방식** — S3 직접 쿼리·서버리스·비용 모델을 설명할 수 있다
- [ ] **EMR vs Glue 선택** — 관리형 클러스터(EMR) vs 서버리스 ETL(Glue)의 선택 기준을 안다
- [ ] **Lake Formation 역할** — Glue Data Catalog 위의 세밀한 접근 제어 계층 역할을 설명할 수 있다
- [ ] **배치 vs 스트리밍 수집** — 요구사항에 따라 DataSync·Transfer Family·AWS Data Transfer Terminal·Kinesis 중 올바른 서비스를 고를 수 있다(Snow 패밀리는 신규 주문 불가)

---

## 🎯 왜 중요한가

- 도메인 3(24%)에서 Task 3.5는 데이터 파이프라인 설계를 직접 묻습니다. "실시간 스트리밍 vs 배치", "서버리스 쿼리 vs 관리형 클러스터", "ETL 서비스 선택" 유형이 반복 출제됩니다.
- 시험 시나리오는 "초당 수천 건의 클릭스트림 데이터를 실시간으로 처리해야 한다", "S3에 있는 수 TB 로그를 SQL로 분석해야 한다", "온프레미스 데이터를 데이터 레이크로 옮겨야 한다" 식으로 구체적입니다. 각 서비스의 **역할 경계**를 정확히 아는 것이 정답과 오답을 가릅니다.
- Kinesis Data Streams와 Firehose는 이름이 비슷해 혼동이 잦습니다. Glue와 EMR도 둘 다 ETL이 가능해 구분이 필요합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **컨슈머** | Consumer | 스트림에서 데이터를 읽어 처리하는 애플리케이션 또는 서비스 |
| **ETL** | Extract, Transform, Load | 원본 데이터를 추출하고, 형식을 변환한 뒤, 목적지에 적재하는 일련의 데이터 처리 과정 |
| **데이터 레이크** | Data Lake | S3처럼 구조화·비구조화 데이터를 원본 형태로 대규모 저장하는 중앙 저장소 |
| **메타데이터** | Metadata | 데이터 자체가 아닌 데이터의 스키마·위치·형식 등 구조 정보 — 도서관 카탈로그처럼 실제 책 대신 책의 제목·위치를 기록한다 |
| **크롤러** | Crawler | 데이터 소스를 자동 스캔해 스키마를 추론하고 Data Catalog에 등록하는 Glue 구성 요소 |
| **DPU** | Data Processing Unit | AWS Glue ETL 잡의 컴퓨팅 용량 단위 — DPU 수에 비례해 처리 병렬도와 과금이 결정된다 |

---

## 📖 핵심 개념 {#core-concepts}

### 1) 데이터 파이프라인 전체 구조 {#pipeline-overview}

```
[수집 계층]           [저장·처리 계층]          [분석·시각화 계층]
Kinesis Data Streams  →  S3 (데이터 레이크)   →  Athena (서버리스 SQL)
Kinesis Data Firehose →  Redshift (DW)        →  EMR (Spark/Hadoop)
DataSync / 전송 터미널 →  Glue Data Catalog    →  Quick Sight (BI)
Transfer Family       →  Lake Formation (거버넌스)
```

> 수집 계층이 데이터를 들여오고, 저장·처리 계층이 변환·카탈로깅하며, 분석 계층이 쿼리·시각화합니다. 각 계층은 독립적으로 교체 가능합니다.

---

### 2) Kinesis 패밀리 4종 {#kinesis-family}

#### Kinesis Data Streams (실시간 수집·처리)

> 공식 정의: "대규모 데이터 레코드 스트림을 실시간으로 수집하고 처리하는 서비스."

- **샤드(Shard)** 단위로 처리량을 관리합니다. 샤드 1개당:
  - 쓰기(수집): 초당 1 MB 또는 초당 1,000 레코드
  - 읽기(소비): 초당 2 MB
- 데이터 보존(retention): 기본 24시간, 최대 365일까지 연장 가능
- 동일 스트림을 여러 컨슈머가 **각자 오프셋을 유지하며** 읽을 수 있습니다 (fan-out). 예: 아카이브 애플리케이션 + 실시간 집계 애플리케이션이 같은 스트림을 소비
  - 기본(비-EFO) 컨슈머는 `GetRecords`로 **샤드당 읽기 2 MB/s를 공유**합니다 — 컨슈머가 늘면 서로 처리량을 나눠 씁니다(샤드당 읽기 트랜잭션 초당 5회)
  - 컨슈머별 **전용 처리량**이 필요하면 **EFO(Enhanced Fan-Out)** 컨슈머를 등록해 `SubscribeToShard`로 읽습니다 — 스트림당 최대 20개(On-demand Advantage는 50개)
- 레코드 재처리(replay)가 가능합니다 — 보존 기간 내에 오프셋을 되돌릴 수 있습니다
- Kinesis Client Library(KCL) 또는 AWS Lambda를 컨슈머로 사용할 수 있습니다

#### Amazon Data Firehose (관리형 적재)

> 공식 정의: "실시간 스트리밍 데이터를 목적지로 전달하는 완전 관리형 서비스. 애플리케이션 작성이나 리소스 관리 불필요."

- 목적지: S3, Amazon Redshift, Amazon OpenSearch Service, Splunk, Apache Iceberg Tables, 커스텀 HTTP 엔드포인트, Datadog·New Relic 등 서드파티
- Redshift 적재 시 **S3 경유 후 COPY 명령**으로 로드합니다
- **버퍼(Buffer)** 설정: 크기(MB) 또는 시간(초) 중 먼저 충족되는 조건에서 전달 → near real-time (수 초~수 분 지연)
- 적재 전 Lambda를 이용한 데이터 변환 가능
- 자체적인 컨슈머 코드 작성 불필요 — Firehose가 전달 로직을 전담합니다
- Kinesis Data Streams를 소스로 연결해 스트림 → 적재 파이프라인을 구성할 수 있습니다

#### Amazon Managed Service for Apache Flink (스트림 분석)

- 실시간 스트림 데이터에 **Java·Scala·Python·SQL**로 분석 로직을 작성합니다
- 완전 관리형 — Apache Flink 인프라를 직접 관리하지 않아도 됩니다
- 입력 소스로 Kinesis Data Streams 또는 Amazon MSK(Kafka)를 사용합니다
- 이전 명칭: Kinesis Data Analytics for Apache Flink

#### Amazon Kinesis Video Streams (영상 스트리밍)

- 카메라·IoT 디바이스에서 AWS로 비디오 스트림을 안전하게 수집·저장·재생합니다
- Amazon Rekognition과 연동해 실시간 영상 분석을 할 수 있습니다

> 🧠 원리: 왜 Kinesis 패밀리는 하나의 서비스가 아닌 4가지 서비스로 나뉘어 있을까요?
> 스트리밍 데이터 파이프라인의 각 단계(수집·보존, 관리형 적재, 분석·집계, 영상 처리)는 요구하는 지연 허용치, 컨슈머 코드 복잡도, 목적지 유형이 서로 달라 단일 서비스로 모든 경우를 최적화하기 어렵습니다.
> Data Streams는 재처리와 다중 컨슈머 fan-out을 위해 데이터를 보존하는 데 집중하고, Firehose는 목적지 전달 로직을 완전 관리형으로 제공해 컨슈머 코드 없이 적재를 가능하게 합니다.
> 용도에 맞는 서비스를 조합하면 각 단계의 복잡도를 필요한 곳에만 집중시킬 수 있습니다.

---

### 3) Kinesis 4종 비교표 (★ 시험 핵심) {#kinesis-comparison}

| 서비스 | 핵심 역할 | 직접 코드 작성 | 보존·재처리 | 주요 목적지/소비 방식 |
|---|---|---|---|---|
| **Data Streams** | 실시간 수집, 커스텀 처리 | 필요(KCL·Lambda) | 가능(최대 365일) | 직접 컨슈머 코드 |
| **Data Firehose** | 관리형 적재 | 불필요 | 불가(적재 후 삭제) | S3·Redshift·OpenSearch·Splunk |
| **Managed Flink** | 스트림 분석·집계 | 필요(Flink 코드) | 소스에 따라 다름 | 스트림 분석 결과 출력 |
| **Video Streams** | 영상 수집·저장 | 일부 필요(SDK) | 가능(설정 기간) | Rekognition 등 분석 서비스 |

> 핵심 구분: **재처리·커스텀 처리**가 필요하면 Data Streams. **코드 없이 S3 등으로 그냥 적재**하면 Firehose. **스트림에 집계·분석 로직**이 필요하면 Managed Flink.

#### Data Streams 설계 세부 — 소비자가 몇이냐가 설계를 가릅니다 (★ 시험 핵심)

**① 보존 기간의 정확한 모델**

| 항목 | 공식 값 |
|---|---|
| 기본값 | 생성 시 **24시간** |
| 최댓값 | **8,760시간(365일)** — `IncreaseStreamRetentionPeriod` |
| 최솟값 | **24시간** — `DecreaseStreamRetentionPeriod` |
| 과금 | ⚠️ **24시간을 넘는 보존에는 추가 요금**이 붙습니다 |

- 늘릴 때: 옛 보존 기간에 걸려 접근 불가가 되던 레코드가 **수 분 내**에 다시 살아납니다(24→48시간이면 23시간 55분 전 레코드도 24시간 뒤에 여전히 읽힙니다). ⚠️ 다만 **이미 만료된 데이터는 되살아나지 않습니다** — 24→168시간으로 올려도 24시간보다 오래된 데이터는 그대로 접근 불가입니다.
- 줄일 때: ⚠️ **새 보존 기간보다 오래된 레코드가 거의 즉시 접근 불가**가 됩니다. `DecreaseStreamRetentionPeriod` 호출은 되돌릴 수 없는 손실로 이어질 수 있습니다.
- 현재 값은 `DescribeStream`으로 확인합니다. 보존 기간은 **"컨슈머가 장애에서 회복할 시간을 벌어 주는 안전망"**으로 잡습니다 — 처리 로직 결함이나 다운스트림 장애가 몇 시간 이어질 수 있다면 그만큼 길게 둡니다.

**② 소비자 처리량 — 향상된 팬아웃(EFO)**

| 항목 | 공유 처리량 소비자 (기본, 비-EFO) | **향상된 팬아웃(EFO) 소비자** |
|---|---|---|
| 읽기 처리량 | **샤드당 총 2 MB/초 고정** — 여러 소비자가 그 2 MB/초를 **나눠 씁니다** | 등록한 **소비자마다 샤드당 최대 2 MB/초**를 다른 소비자와 **독립적으로** |
| 메시지 전파 지연 | 소비자 1개면 평균 약 **200 ms**, 5개면 약 **1,000 ms** | 1개든 5개든 평균 약 **70 ms** |
| 전달 모델 | `GetRecords`로 **끌어오기(pull)** | `SubscribeToShard`로 Kinesis가 **HTTP/2로 밀어 줌(push)** |
| 비용 | 해당 없음 | **데이터 검색 비용 + 소비자-샤드 시간 비용** |

- 등록 한도는 스트림당 **On-demand Advantage 50개 / On-demand Standard·프로비저닝 20개**이고, 한 소비자는 한 번에 **한 스트림**에만 등록됩니다. `RegisterStreamConsumer`는 계정당 **초당 5건**, 동시에 `CREATING` 상태인 소비자 **5개**까지입니다(6번째는 `LimitExceededException`).
- ⚠️ **EFO는 읽기 쪽 기능입니다.** 샤드의 **입력(쓰기) 처리량을 늘리지 않습니다** — 쓰기가 막히면 샤드를 늘려야 합니다.
- 시험 신호: **"소비자를 더 붙였더니 전부 느려졌다"** → 공유 처리량의 2 MB/초를 나눠 쓰고 있다는 뜻이고 답은 **EFO**입니다. 반대로 **"수집 자체가 스로틀된다"** 면 EFO가 아니라 **샤드 증설·온디맨드 전환**입니다.

> 🧠 원리: 왜 Data Streams는 데이터를 전달 후에도 보존하는 반면, Firehose는 전달 즉시 제거할까요?
> Data Streams는 여러 컨슈머가 각자의 속도로 같은 데이터를 읽어야 하므로, 가장 느린 컨슈머가 읽을 때까지 데이터를 스트림에 유지해야 fan-out이 가능합니다.
> Firehose는 단일 목적지로 데이터를 전달하는 역할만 수행하므로, 전달이 완료된 데이터를 별도로 보존할 이유가 없고 보존 비용도 발생하지 않습니다.
> 이 차이가 "재처리 필요 여부"를 Data Streams와 Firehose 선택의 핵심 기준으로 만드는 설계 근거입니다.

---

### 4) AWS Glue (서버리스 ETL) {#glue}

> 공식 정의: "데이터 통합을 쉽게 만드는 서버리스 데이터 통합 서비스. 데이터 발견·준비·이동·통합을 지원."

#### 구성 요소

| 구성 요소 | 역할 |
|---|---|
| **Data Catalog** | 중앙 메타데이터 저장소. 데이터베이스·테이블 스키마 관리. Athena·EMR·Redshift Spectrum이 공유 사용 |
| **크롤러(Crawler)** | S3·RDS 등 데이터 소스를 자동 스캔해 스키마를 추론, Data Catalog에 등록 |
| **ETL 잡(Job)** | Apache Spark 기반 서버리스 코드로 데이터 추출·변환·적재. Python(PySpark) 또는 Scala |
| **Glue Studio** | ETL 잡을 시각적으로 생성·편집하는 그래픽 인터페이스 |
| **Glue DataBrew** | 코드 없이 데이터 클렌징·정규화를 수행하는 시각적 도구 |
| **워크플로(Workflow)** | 크롤러·잡·트리거를 묶어 파이프라인 오케스트레이션 |

- 서버리스 — 인프라 프로비저닝 불필요. 워커(DPU) 단위 과금
- 70개 이상의 데이터 소스(온프레미스 DB, S3, Redshift, 서드파티 등) 연결 지원
- Data Catalog는 Athena·EMR·Redshift Spectrum이 공통으로 참조하는 **메타데이터 허브**입니다

> 🧠 원리: 왜 Glue Data Catalog는 Athena·EMR·Redshift Spectrum이 따로 스키마를 관리하지 않고 하나의 중앙 카탈로그를 공유할까요?
> 동일 데이터 소스에 대해 서비스마다 스키마 정의를 별도로 유지하면, 원본 데이터 구조가 바뀔 때 각 서비스의 정의를 개별적으로 갱신해야 해 불일치와 관리 부담이 발생합니다.
> Data Catalog를 중앙 메타데이터 허브로 두면 크롤러가 스키마를 한 번 등록하고, 모든 분석 서비스가 그 정의를 참조하므로 스키마 변경이 한 지점에서만 반영됩니다.
> 이 공유 참조 구조가 "중복 스키마 정의 없이 여러 분석 도구를 전환하며 사용할 수 있다"는 Glue 데이터 통합 설계의 근거입니다.

---

### 5) Amazon Athena (서버리스 S3 쿼리) {#athena}

> 공식 정의: "표준 SQL로 S3에 저장된 데이터를 직접 분석하는 대화형 쿼리 서비스."

- **서버리스** — 클러스터 설정·관리 불필요. 쿼리 제출 즉시 실행
- Presto/Trino 기반 분산 SQL 엔진
- 비용 모델: **스캔한 데이터 양 기준 과금**(쿼리당, TB당 5 USD 수준). 인프라 상시 비용 없음
- 지원 형식: Parquet, ORC, JSON, CSV, Avro 등. **Parquet·ORC 같은 컬럼형 포맷**은 스캔량을 줄여 비용 절감
- Glue Data Catalog와 기본 통합 — 크롤러가 등록한 테이블을 바로 쿼리
- S3 데이터를 이동·복사 없이 제자리에서 쿼리합니다
- Apache Spark 노트북 환경도 지원(Athena Spark)

> 🧠 원리: 왜 Athena의 비용은 쿼리 결과 크기가 아닌 스캔한 데이터 양으로 결정될까요?
> 분산 SQL 엔진이 쿼리를 처리하는 데 필요한 컴퓨팅 비용은, 결과 행 수보다 S3에서 읽어야 하는 원본 데이터 크기에 비례합니다.
> Parquet·ORC 같은 컬럼형 포맷은 쿼리에 필요한 컬럼만 선택적으로 읽고 나머지를 건너뛸 수 있어, 같은 결과를 얻더라도 스캔량이 줄어 비용이 낮아집니다.
> 이 과금 구조가 "데이터 형식 선택이 곧 비용 최적화 수단"이 되는 이유이며, 파티셔닝이 스캔 범위를 좁혀 추가로 비용을 줄이는 방식과 연결됩니다.

---

### 6) Amazon EMR (관리형 빅데이터 클러스터) {#emr}

> 공식 정의: "Apache Hadoop·Spark 같은 빅데이터 프레임워크를 실행하는 관리형 클러스터 플랫폼."

- 지원 프레임워크: Apache Spark, Hadoop(MapReduce), Hive, HBase, Presto, Flink, Hudi, Iceberg 등
- 배포 옵션:
  - **EMR on EC2** — 마스터·코어·태스크 노드로 구성된 클러스터. 가장 유연하고 세밀한 제어 가능
  - **EMR on EKS** — Kubernetes 위에서 Spark 잡 실행
  - **EMR Serverless** — 인프라 관리 없이 Spark·Hive 잡 실행
- S3를 스토리지 계층으로 사용(EMRFS). S3에서 데이터를 읽고 S3에 결과 기록
- 대규모·복잡한 데이터 처리, 머신러닝, 커스텀 프레임워크 필요 시 적합
- Kinesis Data Streams를 직접 읽어 스트리밍 데이터 처리 가능

> 🧠 원리: 왜 같은 ETL 작업에 대해 Glue가 아닌 EMR을 선택해야 하는 경우가 있을까요?
> Glue는 서버리스로 인프라 관리를 추상화하지만, 실행 환경 커스터마이징(커스텀 라이브러리 설치, 특정 Spark 버전 고정, 노드 인스턴스 유형 세밀 조정)이 제한됩니다.
> EMR은 클러스터 직접 제어를 허용하므로, 특정 라이브러리 의존성이 있는 머신러닝 파이프라인이나 수십 TB 이상 장기 실행 잡처럼 실행 환경을 세밀하게 통제해야 하는 상황에 적합합니다.
> 운영 복잡도와 비용 구조가 다르므로, 관리 편의성 우선이면 Glue, 실행 환경 제어 우선이면 EMR을 선택하는 판단 기준이 됩니다.

---

### 7) AWS Lake Formation (데이터 레이크 거버넌스) {#lake-formation}

> 공식 정의: "분석·머신러닝을 위해 데이터 레이크를 중앙에서 거버넌스·보안·공유하는 서비스."

- Glue Data Catalog 위에 올라가는 **권한 제어 계층**입니다 — Catalog가 메타데이터를 담당하고, Lake Formation이 접근 제어를 담당합니다
- 컬럼·행·셀 수준의 세밀한(fine-grained) 접근 제어 지원
- 적용 범위는 **엔진마다 다릅니다**: Athena SQL·Redshift Spectrum·EMR(EC2)의 Apache Spark·EMR Serverless의 Spark는 테이블 읽기/쓰기 + 열·행·셀 읽기를 지원하지만, **EMR의 Apache Hive는 행·셀 수준을 지원하지 않고**, **Athena Spark·EMR on EKS·EMR Serverless의 Hive는 미지원**이며, **Glue ETL의 열·행·셀 읽기는 Glue 5.0 이상**에서만 됩니다
- IAM 권한 모델을 **확장**(augment)합니다 — IAM을 대체하지 않고 그 위에 추가됩니다
- 태그 기반 접근 제어(TBAC·LF-Tag): 수천 개 리소스에 태그를 붙여 권한을 일괄 관리
- 교차 계정 데이터 공유 지원
- CloudTrail 연동 감사 로그로 "누가, 언제, 어떤 데이터에 접근했는지" 추적

> 🧠 원리: 왜 Lake Formation은 IAM을 대체하지 않고 그 위에 추가되는 방식으로 설계됐을까요?
> IAM은 AWS 서비스 전반의 API 수준 접근을 제어하는 범용 계층이고, 데이터 레이크에서 필요한 "테이블 X의 컬럼 Y만 허용" 같은 데이터 객체 수준 세밀 제어는 IAM 정책 모델로 표현하기 복잡합니다.
> Lake Formation은 이 데이터 객체 수준 권한을 별도 모델로 관리하면서, 실제 접근은 IAM과 Lake Formation 권한을 모두 만족해야만 허용하는 방식으로 두 계층을 결합합니다.
> 이 확장 구조 덕분에 기존 IAM 기반 인프라 보안 설계를 바꾸지 않고도 데이터 레이크에 세밀한 접근 제어를 추가할 수 있습니다.

---

### 8) Amazon Quick Sight (BI 시각화) {#quicksight}

> ⚠️ **명칭이 바뀌었습니다.** 공식 문서는 **`Amazon Quick`** 을 상위 서비스로 두고, 기존 QuickSight 를 그 안의 **`Amazon Quick Sight`**(두 단어) **기능**으로 잇습니다. 공식 서술은 "Amazon Quick evolved from Amazon QuickSight. QuickSight continues as Amazon Quick Sight, a feature within Quick" 이며, ⚠️ **기존 QuickSight API·SDK·연동은 변경 없이 그대로 동작합니다**(API 네임스페이스는 여전히 `quicksight`). 문서 경로도 `/quick/` 으로 옮겨졌습니다. 과거 자료의 `QuickSight` 표기는 **같은 기능의 옛 이름**입니다.
>
> **Amazon Quick** 은 자연어 챗으로 상호작용하며 AI 에이전트가 연결된 데이터·앱에 대해 요청을 처리하는 서비스이고, **Quick Sight**(시각화·BI) 외에 **Quick Flows**(작업 자동화) · **Quick Automate**(업무 프로세스 자동화) · **Quick Index**(사내 문서·데이터 연결) · **Quick Research**(인용 포함 리서치 보고서) · **Apps in Amazon Quick**(자연어로 웹 앱 구축)을 함께 가집니다.

- 완전 관리형 **비즈니스 인텔리전스(BI)** 기능. 대화형 대시보드·차트 생성
- 소스: Athena, S3, Redshift, RDS, Aurora, 온프레미스 DB 등
- **SPICE** (Super-fast, Parallel, In-memory Calculation Engine) — 인메모리 캐시로 밀리초급 응답. 데이터셋은 **최대 200 GB**까지 확장
- 데이터를 분석한 다음 결과를 **시각화·공유**하는 마지막 계층

**가져오기(SPICE) vs 직접 쿼리 — 데이터셋 모드 (★ 시험 포인트)**

| 모드 | 동작 | 고르는 기준 |
|---|---|---|
| **SPICE(가져오기)** | 데이터를 인메모리 엔진으로 **복제해 두고** 질의 | 대시보드 동시 사용자가 많고 **응답 속도**가 중요할 때. 소스 부하를 차단합니다. 대신 **신선도는 갱신 주기에 묶입니다** |
| **직접 쿼리(Direct Query)** | 질의마다 **소스에 그대로** 전달 | **항상 최신**이어야 할 때. 대신 소스가 질의 부하를 전부 받습니다 |

**과금과 임베디드**

- 두 요소로 갈립니다 — **리포트 작성자는 사용자당**, **리포트 독자는 30분 세션당**이며 독자는 **월 최대 $5.00**입니다. 그래서 "보기만 하는 사용자가 수천 명"인 설계에서 사용자당 과금을 가정하면 비용을 크게 틀립니다.
- 대시보드를 자사 애플리케이션에 **임베디드**로 넣을 수 있어, 고객에게 분석을 그대로 노출하는 구조가 가능합니다.

**⚠️ VPC 연결은 데이터 소스를 가립니다 (★ 함정)**

프라이빗 서브넷의 DB에 붙으려면 **VPC 연결**을 쓰는데, **모든 소스가 지원되지 않습니다.**

| 구분 | 소스 |
|---|---|
| VPC 연결 **지원** | OpenSearch Service · Redshift · RDS · Aurora · Impala · Databricks · Exasol · MariaDB · SQL Server · MySQL · Oracle · PostgreSQL · Presto · Snowflake · Starburst · Teradata · Trino |
| VPC 연결 **미지원** | ⚠️ **Athena** · Google BigQuery · Apache Spark · Timestream, 그리고 SaaS 커넥터(Salesforce·ServiceNow·Jira·GitHub) |

> 미지원 소스에 VPC 연결을 붙이면 요청이 **잘못된 파라미터(invalid parameter) 오류로 실패**합니다. "Athena 쿼리를 VPC 연결로 사설화하라"는 선택지는 그래서 오답입니다 — Athena 쪽 사설 접근은 **VPC 엔드포인트**로 푸는 문제입니다.

---

### 9) 배치 vs 스트리밍 수집 비교 {#batch-vs-streaming}

| 특성 | 배치 수집 | 스트리밍 수집 |
|---|---|---|
| 처리 단위 | 일정 시간 묶음 | 레코드 단위 실시간 |
| 지연 | 분~시간 | 밀리초~초 |
| 대표 서비스 | Glue ETL, EMR, DataSync | Kinesis Data Streams, Firehose |
| 비용 패턴 | 잡 실행 시에만 과금 | 샤드 시간·레코드 수로 상시 과금 |
| 적합한 상황 | 정기 리포트, 대용량 이관 | 실시간 알림·모니터링, 클릭스트림 |

> 🧠 원리: 왜 배치 수집과 스트리밍 수집은 같은 데이터를 처리하더라도 서비스와 비용 패턴이 근본적으로 다를까요?
> 배치 수집은 일정 기간 데이터를 모아 한 번에 처리하므로 잡 실행 시간에만 컴퓨팅 자원을 사용하고, 그 외 시간에는 비용이 발생하지 않습니다.
> 스트리밍 수집은 데이터 도착 즉시 처리해야 하므로 수집 채널(샤드)과 처리 인프라가 상시 대기해야 하고, 이 대기 상태 자체에도 비용이 발생합니다.
> 따라서 실시간 알림처럼 지연 허용이 낮은 요구에는 스트리밍이, 정기 리포트처럼 지연을 허용할 수 있는 대용량 처리에는 배치가 비용 측면에서 합리적인 선택이 됩니다.

---

### 10) 데이터 전송 서비스 {#data-transfer}

| 서비스 | 용도 | 핵심 특성 |
|---|---|---|
| **AWS DataSync** | 온프레미스 ↔ AWS 파일 반복 동기화 | NFS·SMB → S3·EFS·FSx. 증분·스케줄·검증 지원 |
| **Snow 패밀리** ⚠️ | 과거의 오프라인 대용량 이전 수단 | **신규 고객은 어떤 Snow Family 디바이스도 주문할 수 없습니다**(기존 고객은 계속 사용). 엣지 컴퓨팅 대안은 **Outposts** |
| **AWS Data Transfer Terminal** | 물리 저장장치를 가져가 고속 업로드 | AWS 시설을 예약해 직접 업로드 — 현행 물리 전송 경로 |
| **Transfer Family** | 기존 **SFTP·FTPS·FTP·AS2** 워크플로우를 S3·EFS로 | 관리형 파일 전송 서버. 클라이언트 수정 불필요. 요금은 **활성화한 프로토콜별 시간당 + 전송량(GB)**, AS2는 **주고받은 메시지 수** 기준 |
| **Direct Connect** | 전용 네트워크 회선으로 안정적 대용량 전송 | 낮은 지연·일관된 대역폭. 초기 구축 필요 |
| **Storage Gateway**(S3 File Gateway 등) | 이전이 끝난 뒤에도 온프레미스에서 **지속적으로** 클라우드 데이터 접근 | NFS·SMB·iSCSI 인터페이스 + 로컬 캐시. **전송 작업 도구가 아니라 상시 접근 계층** |

> **DataSync vs Storage Gateway — 공식이 가르는 기준**: AWS는 **"DataSync로 기존 데이터를 S3로 이전하고, 그 뒤 Storage Gateway의 File Gateway 구성으로 이전된 데이터에 계속 접근하라"**고 안내합니다. 즉 **옮기는 작업은 DataSync**, **옮긴 뒤 온프레미스 앱이 계속 읽고 쓰는 통로는 File Gateway**입니다. 둘은 경쟁 관계가 아니라 **단계가 다른 조합**이고, 시나리오에 "마이그레이션 후에도 온프레미스 애플리케이션이 그대로 파일에 접근해야 한다"가 붙으면 File Gateway가 답에 들어갑니다.

> 선택 기준: 네트워크 대역폭이 있고 반복 동기화면 **DataSync**, 대역폭 부족·초대용량 일회성 이전이면 **AWS Data Transfer Terminal**(또는 파트너 솔루션), 기존 SFTP 도구를 그대로 쓰면 **Transfer Family**. Snow 패밀리는 신규 주문이 불가하므로 신규 설계의 정답이 아닙니다.

**크기·속도 요건을 숫자로 환산하기 (★ 시험 포인트)**

전송 방식 선택은 감이 아니라 산수입니다.

```
전송 소요 시간 ≈ 데이터량 ÷ 실효 대역폭

예) 100 TB를 1 Gbps(≈ 0.125 GB/s)로 보내면
    100,000 GB ÷ 0.125 GB/s ≈ 800,000초 ≈ 9.3일   ← 회선을 100% 쓴다는 낙관적 가정
```

- 실효 대역폭은 **업무 시간대 다른 트래픽과 나눠 쓰는 몫**이므로, 위 계산보다 길어지는 쪽이 정상입니다. 그래서 **DataSync에 대역폭 제한을 걸어 업무 시간에는 양보하고 야간에 몰아주는** 운영이 흔합니다.
- **DataSync 대역폭 제한**: 콘솔에서 **"Use available"**(가용 대역폭 전부) 또는 **"Set bandwidth limit (MiB/s)"** 로 상한을 줍니다. API로는 `UpdateTaskExecution`의 **`BytesPerSecond`** 파라미터입니다.
- ⚠️ **이미 실행 중이거나 대기 중인 태스크 실행의 제한도 수정할 수 있고**, 새 제한은 **60초 내**에 적용됩니다 — 전송을 멈추고 다시 시작할 필요가 없습니다.
- DataSync는 **증분 전송**이라 두 번째 실행부터는 바뀐 파일만 옮깁니다. 스케줄로 반복하면 "최초 1회는 길고 이후는 짧은" 패턴이 됩니다.

> 🧠 원리: 왜 "대역폭 부족" 상황에서는 네트워크 전송보다 물리적 데이터 이동이 빠른 수단이 될 수 있을까요?
> 수백 TB 이상의 데이터를 인터넷이나 전용 회선으로 전송할 때 걸리는 시간은 가용 대역폭에 반비례하며, 낮은 대역폭 환경에서는 전송 완료까지 매우 긴 시간이 걸릴 수 있습니다.
> 물리적 장치에 데이터를 담아 배송하면 배송 시간은 가용 대역폭에 의존하지 않으므로, 대역폭이 충분하지 않은 환경에서는 물리 이전이 네트워크 전송보다 짧은 시간 안에 완료될 수 있습니다.
> 이 물리-네트워크 트레이드오프 때문에 오프라인 이전의 선택 기준은 "데이터 크기와 가용 대역폭의 비율"로 결정됩니다. 과거에는 Snow 패밀리가 그 역할을 맡았고, 신규 고객에게는 **AWS Data Transfer Terminal**·파트너 솔루션이 같은 자리를 대체합니다.

---

### 11) 분석 서비스 선택 비교표 (★ 시험 핵심) {#analytics-selection}

| 시나리오 | 권장 서비스 | 이유 |
|---|---|---|
| S3 데이터를 인프라 없이 SQL로 즉시 쿼리 | **Athena** | 서버리스, 스캔량 과금, S3 직접 쿼리 |
| 복잡한 Spark 변환, 커스텀 라이브러리 필요 | **EMR** | 클러스터 직접 제어, 프레임워크 자유도 |
| 서버리스 ETL, 스키마 자동 발견 | **Glue** | 서버리스, Data Catalog 연동, 크롤러 |
| 실시간 스트림 → S3·Redshift 적재 | **Firehose** | 코드 불필요, 완전 관리형 적재 |
| 실시간 스트림 + 재처리·다중 컨슈머 | **Kinesis Data Streams** | 보존 기간, fan-out, 커스텀 처리 |
| 데이터 레이크 컬럼·행 수준 접근 제어 | **Lake Formation** | Glue Catalog 위의 세밀한 권한 관리 |
| 대화형 BI 대시보드 | **Amazon Quick Sight** | 완전 관리형 BI, SPICE 인메모리 (옛 이름 QuickSight — §8) |
| **데이터 웨어하우스 + S3를 걸치는 복잡 쿼리·다수 동시 BI** | **Redshift / Redshift Spectrum** | Redshift SQL을 **엑사바이트 규모 S3 데이터에 제자리로** 실행. CSV·TSV·Parquet·Sequence·**RCFile** 직접 쿼리 |
| **로그·전문 검색 분석과 운영 대시보드** | **OpenSearch Service** | 전문 검색 + OpenSearch Dashboards + 알림 플러그인 |

**Athena vs Redshift Spectrum — 공식이 가르는 기준 (★ 단골)**

- ⚠️ 둘은 **공통 데이터 카탈로그와 공통 데이터 형식을 공유**하므로 **같은 데이터에 둘 다 쓸 수 있습니다.** 양자택일 문제로 보이면 함정입니다.
- 공식 안내는 역할 분담입니다 — **Athena**는 **일회성 데이터 탐색과 SQL 쿼리**, **Redshift Spectrum**은 **더 복잡한 쿼리**와 **다수의 데이터 레이크 사용자가 동시에 BI·리포팅을 돌리는** 상황입니다.
- Spectrum의 강점은 **Redshift 로컬에 있는 자주 쓰는 데이터와 S3의 전체 데이터셋을 한 쿼리로 걸치는** 것입니다. ⚠️ **S3 데이터를 Redshift로 적재하는 기능이 아닙니다** — 적재 없이 제자리에서 읽습니다.

**OpenSearch를 CloudWatch 대신 고르는 이유**

CloudWatch Logs로도 로그를 보지만, 공식이 드는 OpenSearch 전환 사유는 이렇습니다.

- **필드 수준의 세분화된 데이터 접근 제어** — 사용자 권한에 따라 특정 필드를 익명화할 수 있어, 민감 데이터를 노출하지 않고 트러블슈팅을 맡길 수 있습니다.
- **여러 계정·리전·인프라의 로그를 한 클러스터에 집계**해 중앙 운영팀이 교차 분석.
- Fluent Bit·Fluentd·Logstash 같은 **ElasticSearch 계열 에이전트로 직접 수집·보강**(CloudWatch 에이전트가 지원하지 않는 OS 포함).
- 이미 **ELK 스택·Kibana 대시보드에 투자**가 되어 있는 경우.

> CloudWatch Logs 구독 필터로 로그를 OpenSearch로 **스트리밍**할 수 있어, "CloudWatch로 1차 수집하고 OpenSearch로 심화 분석"이 현실적인 조합입니다.

### 12) 데이터 형식 변환과 수집 패턴 {#format-conversion-patterns}

"CSV로 들어온 로그를 Parquet로 바꿔 Athena 비용을 줄여라"는 전형적인 요구입니다. 수단이 **셋**이고, 어느 층에서 바꾸느냐가 다릅니다.

| 수단 | 어디서 바꾸나 | 특징 |
|---|---|---|
| **Firehose 레코드 형식 변환** | **수집 중(적재 직전)** | JSON → **Parquet 또는 ORC**. ⚠️ **S3 목적지만 지원**합니다. 지정하면 **Snappy 압축이 자동 활성화**되고, **AWS Glue 테이블의 컬럼 정보**로 역직렬화·직렬화합니다. **동적 파티셔닝**을 함께 걸면 키별로 접두어를 나눠 씁니다 |
| **Athena CTAS** | **이미 S3에 있는 데이터를 쿼리로** | `CREATE TABLE AS SELECT` 한 문장에 **파티셔닝 + 압축 지정 + 컬럼 형식 변환**을 동시에. 출력 형식은 **PARQUET·ORC·AVRO·JSON·TEXTFILE** |
| **Glue ETL 잡 / EMR** | **별도 처리 단계** | 복잡한 변환·조인·커스텀 라이브러리가 필요할 때 |

**Athena CTAS 의 두 가지 결정적 성질**

- 만들어진 **테이블과 파티션이 Glue Data Catalog 에 자동 등록**되어 후속 쿼리에서 **즉시** 쓸 수 있습니다 — 별도 크롤러 실행이 필요하지 않습니다.
- ⚠️ **S3 출력 위치가 비어 있어야 합니다.** 데이터가 이미 있는 경로를 지정하면 쿼리가 오류로 실패합니다. 워크그룹의 결과 위치 설정이 우선하는 경우에는 `s3://.../tables/query_id/` 에 생성됩니다.
- 기존 테이블에 **행을 덧붙일** 때는 `INSERT INTO` 를 씁니다 — CTAS 가 지원하는 모든 변환을 그대로 쓸 수 있습니다.

**Glue 작업 북마크 — 같은 파일을 두 번 처리하지 않기**

- 북마크는 **작업의 상태(state)** 를 `job_name` + 버전 번호로 저장합니다. 스크립트가 `job.init` 으로 **최신 상태를 읽고**, `job.commit` 에서 상태 요소를 **원자적으로 저장**합니다.
- 상태 요소는 스크립트의 **소스·변환·싱크 인스턴스별**이며 **transformation context** 로 식별됩니다.
- S3 소스의 북마크는 **타임스탬프로 새 객체만 걸러** 증분 처리합니다 — 상위 작업이 계속 쓰는 경로에서 "어디까지 처리했는가"를 그렇게 기억합니다.
- 북마크에는 **실행 번호**(성공한 실행마다 단조 증가)·**시도 번호**(실패 뒤 재실행에서만 증가)·**버전 번호**가 함께 들어갑니다. 재처리를 강제해야 하면 북마크를 비활성화하거나 되감습니다.

**수집 패턴 — 배치와 스트리밍 사이**

§9의 2분법만으로는 실무 요건을 다 담지 못합니다.

| 패턴 | 설명 | 신호 |
|---|---|---|
| **마이크로 배치** | 작은 묶음을 짧은 주기로 — 스트리밍의 지연과 배치의 단순함 사이 | "분 단위 신선도면 충분하다" |
| **스트리밍 배칭** | 스트림을 모아 한 번에 적재(Firehose의 버퍼링이 이 방식) | 목적지의 쓰기 비용·작은 파일 문제를 줄일 때 |
| **동종 수집** | 소스와 대상의 엔진·스키마가 같음 | 리프트 앤 시프트 |
| **이기종 수집** | 엔진·스키마가 달라 변환이 필요 | 스키마 변환·형식 변환이 끼는 설계 |
| **하이브리드(람다 아키텍처형)** | **실시간 계층 + 배치 계층을 함께** 두고 결과를 합침 | "대시보드는 즉시, 정산은 정확히" 둘 다 요구될 때 |

> 작은 파일이 많이 쌓이면 Athena·Spark 모두 느려집니다. 그래서 스트리밍 수집에서는 **버퍼링으로 파일을 키우는 것**이 성능·비용 양쪽에 이롭습니다 — 다만 그만큼 **신선도를 내주는** 교환입니다.

### 13) 수집 접점의 보안 {#ingestion-security}

파이프라인의 보안은 저장소뿐 아니라 **데이터가 들어오는 접점**에서 결정됩니다.

**Kinesis 인터페이스 VPC 엔드포인트 — 경로 자체를 묶기**

- 인터페이스 엔드포인트(PrivateLink)를 두면 VPC 안의 생산자·소비자가 **인터넷을 거치지 않고** Kinesis API 를 호출합니다.
- **VPC 엔드포인트 정책**으로 그 엔드포인트를 통한 동작을 제한할 수 있습니다. 예를 들어 조회만 허용하려면 `kinesis:List*`·`kinesis:Describe*` 만 `Allow` 하고, 특정 스트림만 쓰게 하려면 `Resource` 를 그 스트림 ARN 으로 좁힙니다.
- ⚠️ **엔드포인트 정책 하나로는 "그 경로로만"이 성립하지 않습니다.** 공식 방식은 **IAM 정책과 함께** 쓰는 것입니다 — IAM 사용자·역할에 붙인 정책에서 **지정한 VPC 엔드포인트를 경유할 때만** Kinesis 동작을 허용하도록 조건을 걸어야, 퍼블릭 경로로 우회하는 호출이 막힙니다.

```
① 엔드포인트 정책  : 이 엔드포인트를 지나는 호출 중 무엇을 허용할지
② IAM 정책 조건    : 이 자격증명은 그 엔드포인트를 지날 때만 허용
→ 둘을 겹쳐야 "사설 경로 전용"이 된다
```

**레이크 쪽 접점**

- S3 데이터 레이크는 **버킷 정책 + 암호화 + 감사 로그**가 기본 3축입니다(세부는 `saa-t3-1`·`saa-t4-1` 계열 참고).
- 컬럼·행 수준 권한이 필요하면 **Lake Formation** 이 Glue Data Catalog 위에서 그 역할을 합니다(§7·§11).
- 분석 계층의 사설 접근은 서비스마다 수단이 다릅니다 — ⚠️ **Amazon Quick Sight 의 VPC 연결은 Athena 를 지원하지 않습니다**(§8). Athena 쪽은 **VPC 엔드포인트**로 푸는 문제입니다.

> 🧠 원리: 왜 엔드포인트 정책만으로는 "사설 경로 전용"이 되지 않을까요?
> 엔드포인트 정책은 **그 엔드포인트를 지나는 트래픽에만** 적용됩니다. 즉 "이 문으로 들어오면 무엇을 할 수 있는가"를 정하는 규칙입니다.
> 그런데 같은 자격증명은 퍼블릭 엔드포인트로도 Kinesis API 를 호출할 수 있습니다 — 그 호출은 엔드포인트 정책을 아예 거치지 않으므로, 아무리 엔드포인트 정책을 좁혀도 **다른 문이 열려 있는 상태**가 됩니다.
> 그래서 자격증명 쪽(IAM 정책)에 "지정한 엔드포인트를 경유할 때만 허용"이라는 조건을 함께 걸어야 두 경로가 모두 닫힙니다. 보안 경계를 **경로에만** 두거나 **주체에만** 두면 한쪽이 비는 것이 이 구조의 교훈입니다.

---

## ✍️ 시험 포인트

- **Data Streams vs Firehose**: 재처리·커스텀 컨슈머 코드가 필요하면 Data Streams. 코드 없이 목적지로 자동 적재하면 Firehose. Firehose를 Data Streams의 컨슈머로 연결하는 구성도 가능합니다.
- **Firehose 목적지**: S3, Redshift(S3 경유 COPY), OpenSearch, Splunk, 커스텀 HTTP가 공식 목적지입니다. Redshift 직접 스트리밍이 아닌 **S3 → COPY** 경로임을 기억하세요.
- **Athena 비용 절감**: Parquet·ORC 컬럼형 형식 + 파티셔닝으로 스캔량을 줄입니다. 스캔량 = 비용.
- **Glue vs EMR**: Glue는 서버리스·관리 불필요·빠른 시작. EMR은 클러스터 직접 제어·커스텀 프레임워크·장기 실행 대규모 처리에 적합합니다.
- **Lake Formation은 추가 계층**: Glue Data Catalog를 그대로 사용하면서 그 위에 컬럼·행·셀 수준 권한을 추가합니다. Lake Formation 자체가 Data Catalog를 대체하지 않습니다.
- **샤드 계산**: Data Streams에서 처리량이 부족하면 샤드를 추가(스케일 아웃)합니다. 쓰기 1 MB/s·1,000건/s, 읽기 2 MB/s 한계를 기억하세요.
- **Data Catalog 공유**: Glue 크롤러가 등록한 테이블은 Athena·EMR·Redshift Spectrum이 동일 메타데이터를 공유 사용합니다. 중복 스키마 정의가 불필요합니다.
- **오프라인 대용량 이전**: "대역폭 부족 + 수백 TB 이상"이면 물리 전송을 고려합니다. 다만 **Snow 패밀리는 신규 고객 주문이 불가**하므로 현행 대안은 **AWS Data Transfer Terminal**·파트너이고, 엣지 컴퓨팅은 **Outposts**입니다. (공식 In-Scope 서비스 목록에는 "AWS Snow Family"가 아직 남아 있어, 보기로 등장하면 기존 고객 맥락으로 읽습니다.)

---

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"Firehose는 실시간이다."** → near real-time(준실시간)입니다. 버퍼 설정(크기·시간)에 따라 수 초~수 분 지연이 발생합니다. 밀리초 단위 실시간 처리가 필요하면 Data Streams + 컨슈머를 사용합니다.
   (원리: §2 본문 — Firehose는 버퍼 크기·시간 조건이 충족될 때 전달하는 구조로, 이 버퍼링이 밀리초 실시간이 아닌 near real-time 지연의 원인이다.)

2. **"Firehose로 재처리할 수 있다."** → Firehose는 적재 전용입니다. 전달 후 스트림을 보존하지 않으므로 재처리가 불가합니다. 재처리가 필요하면 Data Streams를 선택합니다.
   (원리: §3 — Data Streams는 여러 컨슈머의 fan-out을 위해 데이터를 보존하고, Firehose는 전달 완료 즉시 제거하는 설계 차이가 재처리 가능 여부를 결정한다.)

3. **"Athena는 데이터를 복사해 저장한다."** → Athena는 S3의 데이터를 제자리에서 쿼리합니다. 별도 데이터베이스 서버나 스토리지가 없습니다. 비용은 스캔한 데이터 양으로 결정됩니다.
   (원리: §5 — Athena의 비용은 S3에서 읽어야 하는 원본 데이터 크기에 비례하며, 데이터 이동 없이 제자리 쿼리하므로 스캔량이 유일한 과금 기준이 된다.)

4. **"Glue와 EMR은 항상 교환 가능하다."** → Glue는 서버리스·관리 편의성에 최적화됩니다. EMR은 커스텀 라이브러리 설치, 장기 실행 클러스터, 세밀한 리소스 제어가 필요할 때 선택합니다. 비용·운영 복잡도가 다릅니다.
   (원리: §6 — Glue가 추상화한 실행 환경 제어권을 EMR은 직접 허용하므로, 커스텀 의존성이나 클러스터 세밀 조정이 필요한 상황에서는 EMR이 대체 불가한 선택이 된다.)

5. **"Lake Formation이 IAM을 대체한다."** → Lake Formation은 IAM 권한 모델을 대체하지 않고 **확장**합니다. Lake Formation 권한과 IAM 권한 모두 충족해야 접근이 허용됩니다.
   (원리: §7 — Lake Formation은 IAM이 표현하기 어려운 데이터 객체 수준 세밀 제어를 추가하는 확장 계층이므로, IAM과 Lake Formation 권한이 모두 만족돼야 접근이 허용된다.)

6. **"Kinesis Data Streams 샤드는 늘 수동 관리다."** → 모드에 따라 다릅니다. **온디맨드 모드**는 용량 계획 없이 샤드를 자동 관리하며 **이전 30일 피크의 2배**까지 수용합니다(그 이상 급증하면 약 15분간 스로틀 가능). **프로비저닝 모드**에서만 샤드 수를 직접 정하고 `UpdateShardCount`·Shard Split으로 조정합니다. (Enhanced Fan-Out은 소비 측 처리량을 늘리는 기능입니다.)
   (원리: §2 본문 — 샤드는 처리량 단위이므로, 용량 결정을 AWS에 맡기면(온디맨드) 자동 분할·관리가 되고, 직접 통제하면(프로비저닝) 분할 지점을 세밀하게 고를 수 있다.)

7. **"DataSync와 Firehose가 같은 역할이다."** → DataSync는 파일 시스템(NFS·SMB)을 S3·EFS로 동기화하는 전송 도구입니다. Firehose는 스트리밍 레코드를 목적지로 전달하는 적재 서비스입니다. 데이터 성격이 다릅니다.
   (원리: §9 — 배치 수집(파일 동기화)과 스트리밍 수집(레코드 단위 실시간)은 데이터 단위와 처리 지연이 근본적으로 다르므로 서비스 역할도 다르다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 웹 애플리케이션에서 초당 수천 건의 클릭스트림 이벤트를 수집합니다. 수집 후 두 개의 독립적인 애플리케이션이 같은 데이터를 각각 다른 용도로 처리해야 합니다. 가장 적합한 서비스는?

<details><summary>정답 보기</summary>

**Amazon Kinesis Data Streams**입니다. 동일 스트림을 여러 컨슈머가 읽는 fan-out을 지원합니다. 두 애플리케이션(예: 집계용 + 아카이브용)이 같은 스트림에서 각자의 오프셋을 유지하며 데이터를 소비할 수 있습니다. 단 기본 컨슈머는 샤드당 2 MB/s를 **공유**하므로, 컨슈머마다 전용 처리량이 필요하면 **EFO**로 등록합니다. Firehose는 단일 목적지 적재 전용이므로 다중 독립 컨슈머 시나리오에는 적합하지 않습니다.
</details>

**Q2.** 실시간으로 들어오는 IoT 센서 데이터를 코드 작성 없이 Amazon S3에 자동으로 적재하려 합니다. 어떤 서비스를 사용하나요?

<details><summary>정답 보기</summary>

**Amazon Data Firehose**입니다. 완전 관리형 서비스로 데이터 프로듀서를 Firehose 스트림에 연결하면 S3에 자동 전달합니다. 컨슈머 코드나 인프라 관리가 필요 없습니다. 버퍼 설정(크기/시간)으로 전달 빈도를 제어할 수 있습니다.
</details>

**Q3.** 데이터 분석팀이 S3에 쌓인 수 TB의 로그 파일을 SQL로 분석해야 합니다. 별도 클러스터를 프로비저닝하지 않고 즉시 쿼리하고 싶습니다. 가장 적합한 서비스는?

<details><summary>정답 보기</summary>

**Amazon Athena**입니다. 서버리스로 S3 데이터를 제자리에서 SQL 쿼리하며, 인프라 설정이 불필요합니다. 비용은 스캔한 데이터 양에만 부과됩니다. Glue Data Catalog에 테이블을 등록하면 바로 쿼리 가능합니다. 비용 절감을 위해 Parquet 형식과 파티셔닝을 적용하면 스캔량을 줄일 수 있습니다.
</details>

**Q4.** 회사가 S3 기반 데이터 레이크를 운영 중입니다. 분석가마다 접근 가능한 컬럼을 다르게 제한해야 합니다(PII 컬럼 마스킹). 어떤 서비스를 추가해야 하나요?

<details><summary>정답 보기</summary>

**AWS Lake Formation**입니다. Glue Data Catalog 위에 컬럼·행·셀 수준의 세밀한 접근 제어를 제공합니다. 분석가 IAM 역할별로 특정 컬럼 접근을 허용하거나 거부할 수 있으며, 이 권한은 Athena SQL·Redshift Spectrum·EMR의 Spark 쿼리에 적용됩니다(엔진별 지원 범위 차이는 §7 참조 — 예: EMR의 Hive는 행·셀 수준 미지원).
</details>

**Q5 (원리).** 왜 Glue Crawler가 스키마를 등록한 테이블은 Athena와 EMR이 별도 설정 없이 바로 쿼리할 수 있을까요?

<details><summary>정답 보기</summary>

Glue Data Catalog가 Athena·EMR·Redshift Spectrum이 모두 참조하는 중앙 메타데이터 허브이기 때문입니다. 크롤러가 스키마를 Catalog에 한 번 등록하면, 각 서비스가 동일 Catalog의 테이블 정의를 공유 참조하므로 서비스마다 스키마를 별도로 정의할 필요가 없습니다. 분석 도구를 전환하거나 복수의 도구를 병행해도 스키마 불일치 없이 동일 데이터를 쿼리할 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. 모든 URL은 WebFetch로 HTTP 200 확인 완료. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. Amazon Kinesis Data Streams — 소개 — https://docs.aws.amazon.com/streams/latest/dev/introduction.html
2. Amazon Data Firehose — 서비스 소개 — https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
3. AWS Glue — 서비스 소개 — https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html
4. Amazon Athena — 서비스 소개 — https://docs.aws.amazon.com/athena/latest/ug/what-is.html
5. Amazon EMR — 서비스 소개 — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html
6. AWS Lake Formation — 서비스 소개 — https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html
7. AWS Snowball Edge 가용성 변경("no longer available to new customers", 대안 DataSync·Data Transfer Terminal·Outposts) — https://docs.aws.amazon.com/snowball/latest/developer-guide/snowball-edge-availability-change.html
8. Kinesis Data Streams 모드 선택(온디맨드는 샤드 자동 관리, 이전 30일 피크의 2배) — https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html
9. Kinesis Data Streams 쿼터("maximum total data read rate of 2 MB per second via GetRecords", EFO 20·50) — https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
10. Lake Formation — 다른 AWS 서비스와 함께 사용(엔진별 지원 표) — https://docs.aws.amazon.com/lake-formation/latest/dg/working-with-services.html
11. Amazon Managed Service for Apache Flink("you can use Java, Scala, Python, or SQL") — https://docs.aws.amazon.com/managed-flink/latest/java/what-is.html
12. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
13. AWS DataSync FAQ("migrate existing data to Amazon S3, and subsequently use the File Gateway configuration") — https://aws.amazon.com/datasync/faqs/
14. AWS Transfer Family FAQ(프로토콜별 시간당 + 전송량 과금, AS2는 메시지 수, 중지해도 과금 계속·삭제해야 종료) — https://aws.amazon.com/aws-transfer-family/faqs/
15. **Amazon Quick 이란?**(상위 서비스·Quick Sight 는 그 안의 기능·"QuickSight continues as Amazon Quick Sight"·기존 API·SDK 무변경) — https://docs.aws.amazon.com/quick/latest/userguide/what-is.html (갭 배치 B8c: 2026-10-21)
16. Quick Sight VPC 연결 지원 데이터 소스(⚠️ Athena·BigQuery·Spark·Timestream 미지원·invalid parameter 오류) — https://docs.aws.amazon.com/quick/latest/userguide/vpc-connection-supported-data-sources.html (갭 배치 B8c: 2026-10-21)
17. Kinesis Data Streams 용어·개념 — 보존 기간(기본 24시간·최대 8,760시간=365일·24시간 초과 추가 과금) — https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html (갭 배치 B8c: 2026-10-21)
18. 데이터 보존 기간 변경(증가는 수 분 내 반영·만료분은 복구 안 됨·감소는 거의 즉시 접근 불가) — https://docs.aws.amazon.com/streams/latest/dev/kinesis-extended-retention.html (갭 배치 B8c: 2026-10-21)
19. 향상된 팬아웃 소비자(공유 2 MB/초 분할 vs 소비자별 2 MB/초·200/1,000 ms vs 70 ms·`SubscribeToShard` HTTP/2 푸시) — https://docs.aws.amazon.com/streams/latest/dev/enhanced-consumers.html (갭 배치 B8c: 2026-10-21)
20. `RegisterStreamConsumer`(On-demand Advantage 50 / Standard·Provisioned 20·초당 5건·동시 `CREATING` 5) — https://docs.aws.amazon.com/kinesis/latest/APIReference/API_RegisterStreamConsumer.html (갭 배치 B8c: 2026-10-21)
21. Firehose 데이터 형식 변환(JSON→Parquet/ORC·**S3 목적지만**·Snappy 자동·Glue 테이블 스키마·동적 파티셔닝) — https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_kinesisfirehose-readme.html (갭 배치 B8c: 2026-10-21)
22. Athena CTAS·`INSERT INTO` ETL(한 문장에 파티셔닝·압축·컬럼 형식·Glue Catalog 자동 등록) — https://docs.aws.amazon.com/athena/latest/ug/ctas-insert-into-etl.html (갭 배치 B8c: 2026-10-21)
23. 콘솔에서 CTAS 쿼리 만들기(⚠️ **출력 위치가 비어 있어야 함**·워크그룹 설정 우선 시 `tables/query_id/`) — https://docs.aws.amazon.com/athena/latest/ug/ctas-console.html (갭 배치 B8c: 2026-10-21)
24. Glue 작업 북마크로 처리분 추적(`job.init`/`job.commit`·transformation context·S3 타임스탬프 필터·실행·시도·버전 번호) — https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html (갭 배치 B8c: 2026-10-21)
25. DataSync 태스크 대역폭 제한(`Set bandwidth limit (MiB/s)`·실행 중·대기 중 수정 가능·60초 내 적용·`UpdateTaskExecution`의 `BytesPerSecond`) — https://docs.aws.amazon.com/datasync/latest/userguide/configure-bandwidth.html (갭 배치 B8c: 2026-10-21)
26. Kinesis Data Streams 인터페이스 VPC 엔드포인트(엔드포인트 정책 예시 3종·IAM 정책과 함께 써야 경로 한정) — https://docs.aws.amazon.com/streams/latest/dev/vpc.html (갭 배치 B8c: 2026-10-21)
27. 데이터 레이크 제자리 쿼리 — Redshift Spectrum(엑사바이트·CSV/TSV/Parquet/Sequence/RCFile·**Athena와 카탈로그·형식 공유**·역할 분담) — https://docs.aws.amazon.com/whitepapers/latest/building-data-lakes/in-place-querying.html (갭 배치 B8c: 2026-10-21)
28. OpenSearch Service 로그 분석 워크로드(전문 검색·Dashboards·알림 플러그인·수집 경로) — https://docs.aws.amazon.com/wellarchitected/latest/amazon-opensearch-service-lens/log-analytics-workloads.html (갭 배치 B8c: 2026-10-21)
29. CloudWatch 로그 분석에서 OpenSearch 로 넘어가는 사유(필드 수준 접근 제어·다계정·다리전 집계·ES 에이전트·기존 ELK) — https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/cloudwatch-search-analysis.html (갭 배치 B8c: 2026-10-21)

> 📝 **2026-10-21 보강 (갭 배치 B8c — B8 완결)**: ① §3에 **Data Streams 설계 세부**를 추가했습니다 — 보존 기간 모델(**기본 24시간 · 최소 24시간 · 최대 8,760시간(365일)** · 24시간 초과 추가 과금 · 증가는 수 분 내 반영되지만 **이미 만료된 데이터는 되살아나지 않음** · 감소는 거의 즉시 접근 불가)과 **향상된 팬아웃(EFO)** 비교표(공유는 샤드당 2 MB/초를 **나눠 씀** vs EFO는 **소비자별 2 MB/초** · 200/1,000 ms vs **70 ms** · `GetRecords` 풀 vs `SubscribeToShard` **HTTP/2 푸시** · 등록 한도 50/20)입니다(근거 17~20번). ② §8의 **명칭을 `Amazon Quick Sight` 로 정정**하고 **`Amazon Quick` 과의 상위·하위 관계**를 적었습니다 — API·SDK 는 변경 없이 동작합니다. SPICE vs **직접 쿼리**, 데이터셋 **200 GB**, 과금 2요소(작성자 사용자당 / 독자 **30분 세션·월 최대 $5.00**), 임베디드, 그리고 ⚠️ **VPC 연결 지원·미지원 소스 표**(**Athena 미지원**)를 추가했습니다(근거 15·16번). ③ §10에 **전송 시간 산술**과 **DataSync 대역폭 제한**(`BytesPerSecond` · 실행 중에도 변경 가능 · **60초 내** 적용)을 추가했습니다(근거 25번). ④ §11 선택표에 **Redshift/Spectrum·OpenSearch 행**을 넣고 **Athena vs Spectrum 역할 분담**(공통 카탈로그 공유 · Spectrum 은 적재가 아니라 제자리 쿼리)과 **OpenSearch 를 CloudWatch 대신 고르는 사유**를 적었습니다(근거 27~29번). ⑤ 새 절 **§12 데이터 형식 변환과 수집 패턴**(Firehose 변환은 **S3 목적지만** · Snappy 자동 · Athena **CTAS**의 Glue 자동 등록과 **빈 출력 위치 전제** · Glue **북마크** · 마이크로 배치·하이브리드 등 패턴)과 **§13 수집 접점의 보안**(Kinesis 엔드포인트 정책은 **IAM 정책과 겹쳐야** 사설 경로 전용이 된다)을 원리 블록과 함께 추가했습니다(근거 21~24·26번).
>
> **명칭 일관성은 별 트랙에서 마무리했습니다(2026-10-21)**: 레포는 옛 이름을 **일부러 유지**합니다 — `clf/t3-7.md` 의 정직성 메모가 "CLF 에선 '대시보드·시각화·BI = QuickSight' 로 기억하면 됩니다" 라고 적은 대로, **AWS 시험이 개명보다 늦기** 때문입니다. 그래서 블라인드 통일 대신 **옛 표기를 쓰는 모든 문서에 현행 명칭이 함께 있도록** 보강했고, 그 공존을 `test/quicksight_naming_consistency_test.dart` 가 영구 가드로 지킵니다.
>
> **쓰지 않은 것 5건**: ① **Firehose 버퍼 크기·간격 수치** — 이번 조회로 확보하지 못했습니다. ② **MSK vs Kinesis 선택의 수치 기준** — 미확보. ③ **Lake Formation S3 위치 등록·IAM 역할 세부** — 미확보로, 기능 존재와 역할만 적었습니다. ④ **OpenSearch 세부 구성**(노드·샤드 수) — `99-gaps` **V-42** 가 열려 있습니다. ⑤ **Quick Sight ML 인사이트의 알고리즘 세부** — 미확보로, 기능 수준으로만 다뤘습니다. 다섯 건 모두 가드가 표기를 금지합니다.

> 📝 **2026-10-19 정정**: ① Snow 패밀리를 현재 선택지로 서술한 대목(수집 표·선택 기준·시험 포인트·체크리스트)을 고쳤습니다 — **신규 고객은 주문할 수 없고** 대안은 DataSync·AWS Data Transfer Terminal·파트너, 엣지 컴퓨팅은 Outposts입니다(근거 7번). ② KDS 샤드 확장을 모드별로 분리했습니다 — **온디맨드는 자동 관리**(이전 30일 피크의 2배), 프로비저닝만 수동 조정(근거 8번). ③ fan-out 서술에 **기본 컨슈머는 샤드당 2 MB/s 공유, 전용 처리량은 EFO**를 명시했습니다(근거 9번). ④ Lake Formation 적용 범위를 **엔진별 차이**로 고쳤습니다(근거 10번). ⑤ Managed Flink 지원 언어에 **Python**을 더했습니다(근거 11번).

> 📝 **2026-10-20 보강**: ① 전송 서비스 표에 **Storage Gateway** 행을 넣고, 공식 DataSync FAQ가 가르는 **"이전은 DataSync · 이후 지속 접근은 File Gateway"** 구분을 명시했습니다(근거 13번). ② Transfer Family의 프로토콜에 **AS2**를 넣고 요금 구조(프로토콜별 시간당 + 전송량, AS2는 메시지 수)를 적었습니다(근거 14번).
