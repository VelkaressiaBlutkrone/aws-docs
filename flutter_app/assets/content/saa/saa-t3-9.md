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
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-07
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
- [ ] **배치 vs 스트리밍 수집** — 요구사항에 따라 DataSync·Snow 패밀리·Transfer Family·Kinesis 중 올바른 서비스를 고를 수 있다

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
| **샤드** | Shard | Kinesis Data Streams에서 처리량을 나누는 단위 — 파이프를 여러 개로 늘리는 것처럼 샤드를 추가해 수집 용량을 확장한다 |
| **컨슈머** | Consumer | 스트림에서 데이터를 읽어 처리하는 애플리케이션 또는 서비스 |
| **fan-out** | Fan-out | 하나의 스트림을 여러 컨슈머가 독립적으로 동시에 읽는 구성 |
| **ETL** | Extract, Transform, Load | 원본 데이터를 추출하고, 형식을 변환한 뒤, 목적지에 적재하는 일련의 데이터 처리 과정 |
| **데이터 레이크** | Data Lake | S3처럼 구조화·비구조화 데이터를 원본 형태로 대규모 저장하는 중앙 저장소 |
| **메타데이터** | Metadata | 데이터 자체가 아닌 데이터의 스키마·위치·형식 등 구조 정보 — 도서관 카탈로그처럼 실제 책 대신 책의 제목·위치를 기록한다 |
| **크롤러** | Crawler | 데이터 소스를 자동 스캔해 스키마를 추론하고 Data Catalog에 등록하는 Glue 구성 요소 |
| **DPU** | Data Processing Unit | AWS Glue ETL 잡의 컴퓨팅 용량 단위 — DPU 수에 비례해 처리 병렬도와 과금이 결정된다 |

---

## 📖 핵심 개념

### 1) 데이터 파이프라인 전체 구조

```
[수집 계층]           [저장·처리 계층]          [분석·시각화 계층]
Kinesis Data Streams  →  S3 (데이터 레이크)   →  Athena (서버리스 SQL)
Kinesis Data Firehose →  Redshift (DW)        →  EMR (Spark/Hadoop)
DataSync / Snow 패밀리→  Glue Data Catalog    →  QuickSight (BI)
Transfer Family       →  Lake Formation (거버넌스)
```

> 수집 계층이 데이터를 들여오고, 저장·처리 계층이 변환·카탈로깅하며, 분석 계층이 쿼리·시각화합니다. 각 계층은 독립적으로 교체 가능합니다.

---

### 2) Kinesis 패밀리 4종

#### Kinesis Data Streams (실시간 수집·처리)

> 공식 정의: "대규모 데이터 레코드 스트림을 실시간으로 수집하고 처리하는 서비스."

- **샤드(Shard)** 단위로 처리량을 관리합니다. 샤드 1개당:
  - 쓰기(수집): 초당 1 MB 또는 초당 1,000 레코드
  - 읽기(소비): 초당 2 MB
- 데이터 보존(retention): 기본 24시간, 최대 365일까지 연장 가능
- 동일 스트림을 **여러 컨슈머가 동시에 독립적으로** 읽을 수 있습니다 (fan-out). 예: 아카이브 애플리케이션 + 실시간 집계 애플리케이션이 같은 스트림을 동시 소비
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

- 실시간 스트림 데이터에 **Java·Scala·SQL**로 분석 로직을 작성합니다
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

### 3) Kinesis 4종 비교표 (★ 시험 핵심)

| 서비스 | 핵심 역할 | 직접 코드 작성 | 보존·재처리 | 주요 목적지/소비 방식 |
|---|---|---|---|---|
| **Data Streams** | 실시간 수집, 커스텀 처리 | 필요(KCL·Lambda) | 가능(최대 365일) | 직접 컨슈머 코드 |
| **Data Firehose** | 관리형 적재 | 불필요 | 불가(적재 후 삭제) | S3·Redshift·OpenSearch·Splunk |
| **Managed Flink** | 스트림 분석·집계 | 필요(Flink 코드) | 소스에 따라 다름 | 스트림 분석 결과 출력 |
| **Video Streams** | 영상 수집·저장 | 일부 필요(SDK) | 가능(설정 기간) | Rekognition 등 분석 서비스 |

> 핵심 구분: **재처리·커스텀 처리**가 필요하면 Data Streams. **코드 없이 S3 등으로 그냥 적재**하면 Firehose. **스트림에 집계·분석 로직**이 필요하면 Managed Flink.

> 🧠 원리: 왜 Data Streams는 데이터를 전달 후에도 보존하는 반면, Firehose는 전달 즉시 제거할까요?
> Data Streams는 여러 컨슈머가 각자의 속도로 같은 데이터를 읽어야 하므로, 가장 느린 컨슈머가 읽을 때까지 데이터를 스트림에 유지해야 fan-out이 가능합니다.
> Firehose는 단일 목적지로 데이터를 전달하는 역할만 수행하므로, 전달이 완료된 데이터를 별도로 보존할 이유가 없고 보존 비용도 발생하지 않습니다.
> 이 차이가 "재처리 필요 여부"를 Data Streams와 Firehose 선택의 핵심 기준으로 만드는 설계 근거입니다.

---

### 4) AWS Glue (서버리스 ETL)

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

### 5) Amazon Athena (서버리스 S3 쿼리)

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

### 6) Amazon EMR (관리형 빅데이터 클러스터)

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

### 7) AWS Lake Formation (데이터 레이크 거버넌스)

> 공식 정의: "분석·머신러닝을 위해 데이터 레이크를 중앙에서 거버넌스·보안·공유하는 서비스."

- Glue Data Catalog 위에 올라가는 **권한 제어 계층**입니다 — Catalog가 메타데이터를 담당하고, Lake Formation이 접근 제어를 담당합니다
- 컬럼·행·셀 수준의 세밀한(fine-grained) 접근 제어 지원
- 적용 범위: Athena, EMR(Apache Spark), Redshift Spectrum, Glue ETL 전반에 Lake Formation 권한이 일관되게 적용됩니다
- IAM 권한 모델을 **확장**(augment)합니다 — IAM을 대체하지 않고 그 위에 추가됩니다
- 태그 기반 접근 제어(TBAC·LF-Tag): 수천 개 리소스에 태그를 붙여 권한을 일괄 관리
- 교차 계정 데이터 공유 지원
- CloudTrail 연동 감사 로그로 "누가, 언제, 어떤 데이터에 접근했는지" 추적

> 🧠 원리: 왜 Lake Formation은 IAM을 대체하지 않고 그 위에 추가되는 방식으로 설계됐을까요?
> IAM은 AWS 서비스 전반의 API 수준 접근을 제어하는 범용 계층이고, 데이터 레이크에서 필요한 "테이블 X의 컬럼 Y만 허용" 같은 데이터 객체 수준 세밀 제어는 IAM 정책 모델로 표현하기 복잡합니다.
> Lake Formation은 이 데이터 객체 수준 권한을 별도 모델로 관리하면서, 실제 접근은 IAM과 Lake Formation 권한을 모두 만족해야만 허용하는 방식으로 두 계층을 결합합니다.
> 이 확장 구조 덕분에 기존 IAM 기반 인프라 보안 설계를 바꾸지 않고도 데이터 레이크에 세밀한 접근 제어를 추가할 수 있습니다.

---

### 8) Amazon QuickSight (BI 시각화)

- 완전 관리형 **비즈니스 인텔리전스(BI)** 서비스. 대화형 대시보드·차트 생성
- 소스: Athena, S3, Redshift, RDS, Aurora, 온프레미스 DB 등
- **SPICE** (Super-fast, Parallel, In-memory Calculation Engine) — 인메모리 캐시로 빠른 쿼리 응답
- 서버리스, 사용자 수 기반 과금(Standard·Enterprise 에디션)
- 데이터를 분석한 다음 결과를 **시각화·공유**하는 마지막 계층

---

### 9) 배치 vs 스트리밍 수집 비교

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

### 10) 데이터 전송 서비스

| 서비스 | 용도 | 핵심 특성 |
|---|---|---|
| **AWS DataSync** | 온프레미스 ↔ AWS 파일 반복 동기화 | NFS·SMB → S3·EFS·FSx. 증분·스케줄·검증 지원 |
| **Snow 패밀리** | 대역폭 부족 시 오프라인 대용량 이전 | Snowcone(수 TB) → Snowball Edge(TB~PB) → Snowmobile(EB) |
| **Transfer Family** | 기존 SFTP/FTPS/FTP 워크플로우를 S3·EFS로 | 관리형 파일 전송 서버. 클라이언트 수정 불필요 |
| **Direct Connect** | 전용 네트워크 회선으로 안정적 대용량 전송 | 낮은 지연·일관된 대역폭. 초기 구축 필요 |

> 선택 기준: 네트워크 대역폭이 있고 반복 동기화면 **DataSync**, 대역폭 부족·초대용량 일회성 이전이면 **Snow**, 기존 SFTP 도구를 그대로 쓰면 **Transfer Family**.

> 🧠 원리: 왜 Snow 패밀리는 "대역폭 부족" 상황에서 네트워크 전송보다 물리적 장치 배송이 빠른 수단이 될 수 있을까요?
> 수백 TB 이상의 데이터를 인터넷이나 전용 회선으로 전송할 때 걸리는 시간은 가용 대역폭에 반비례하며, 낮은 대역폭 환경에서는 수 주~수 개월이 걸릴 수 있습니다.
> 물리적 장치에 데이터를 담아 배송하면 배송 시간은 대역폭과 무관하게 수 일 수준으로 고정되므로, 대역폭이 충분하지 않은 환경에서는 물리 이전이 더 짧은 시간 안에 완료됩니다.
> 이 물리-네트워크 트레이드오프가 Snow 패밀리의 선택 기준이 "데이터 크기와 가용 대역폭의 비율"로 결정되는 이유입니다.

---

### 11) 분석 서비스 선택 비교표 (★ 시험 핵심)

| 시나리오 | 권장 서비스 | 이유 |
|---|---|---|
| S3 데이터를 인프라 없이 SQL로 즉시 쿼리 | **Athena** | 서버리스, 스캔량 과금, S3 직접 쿼리 |
| 복잡한 Spark 변환, 커스텀 라이브러리 필요 | **EMR** | 클러스터 직접 제어, 프레임워크 자유도 |
| 서버리스 ETL, 스키마 자동 발견 | **Glue** | 서버리스, Data Catalog 연동, 크롤러 |
| 실시간 스트림 → S3·Redshift 적재 | **Firehose** | 코드 불필요, 완전 관리형 적재 |
| 실시간 스트림 + 재처리·다중 컨슈머 | **Kinesis Data Streams** | 보존 기간, fan-out, 커스텀 처리 |
| 데이터 레이크 컬럼·행 수준 접근 제어 | **Lake Formation** | Glue Catalog 위의 세밀한 권한 관리 |
| 대화형 BI 대시보드 | **QuickSight** | 완전 관리형 BI, SPICE 인메모리 |

---

## ✍️ 시험 포인트

- **Data Streams vs Firehose**: 재처리·커스텀 컨슈머 코드가 필요하면 Data Streams. 코드 없이 목적지로 자동 적재하면 Firehose. Firehose를 Data Streams의 컨슈머로 연결하는 구성도 가능합니다.
- **Firehose 목적지**: S3, Redshift(S3 경유 COPY), OpenSearch, Splunk, 커스텀 HTTP가 공식 목적지입니다. Redshift 직접 스트리밍이 아닌 **S3 → COPY** 경로임을 기억하세요.
- **Athena 비용 절감**: Parquet·ORC 컬럼형 형식 + 파티셔닝으로 스캔량을 줄입니다. 스캔량 = 비용.
- **Glue vs EMR**: Glue는 서버리스·관리 불필요·빠른 시작. EMR은 클러스터 직접 제어·커스텀 프레임워크·장기 실행 대규모 처리에 적합합니다.
- **Lake Formation은 추가 계층**: Glue Data Catalog를 그대로 사용하면서 그 위에 컬럼·행·셀 수준 권한을 추가합니다. Lake Formation 자체가 Data Catalog를 대체하지 않습니다.
- **샤드 계산**: Data Streams에서 처리량이 부족하면 샤드를 추가(스케일 아웃)합니다. 쓰기 1 MB/s·1,000건/s, 읽기 2 MB/s 한계를 기억하세요.
- **Data Catalog 공유**: Glue 크롤러가 등록한 테이블은 Athena·EMR·Redshift Spectrum이 동일 메타데이터를 공유 사용합니다. 중복 스키마 정의가 불필요합니다.
- **Snow 패밀리 선택**: "대역폭 부족 + 수백 TB 이상"이면 네트워크 전송 시간 계산 없이 Snow를 선택합니다. Snowball Edge는 엣지 컴퓨팅도 가능합니다.

---

## ⚠️ 흔한 함정

1. **"Firehose는 실시간이다."** → near real-time(준실시간)입니다. 버퍼 설정(크기·시간)에 따라 수 초~수 분 지연이 발생합니다. 밀리초 단위 실시간 처리가 필요하면 Data Streams + 컨슈머를 사용합니다.
   *(원리: §3 — Firehose는 목적지 전달 역할만 수행해 데이터를 보존하지 않으므로, 버퍼가 충족될 때까지 대기하는 near real-time 동작이 설계의 필연적 결과다.)*

2. **"Firehose로 재처리할 수 있다."** → Firehose는 적재 전용입니다. 전달 후 스트림을 보존하지 않으므로 재처리가 불가합니다. 재처리가 필요하면 Data Streams를 선택합니다.
   *(원리: §3 — Data Streams는 여러 컨슈머의 fan-out을 위해 데이터를 보존하고, Firehose는 전달 완료 즉시 제거하는 설계 차이가 재처리 가능 여부를 결정한다.)*

3. **"Athena는 데이터를 복사해 저장한다."** → Athena는 S3의 데이터를 제자리에서 쿼리합니다. 별도 데이터베이스 서버나 스토리지가 없습니다. 비용은 스캔한 데이터 양으로 결정됩니다.
   *(원리: §5 — Athena의 비용은 S3에서 읽어야 하는 원본 데이터 크기에 비례하며, 데이터 이동 없이 제자리 쿼리하므로 스캔량이 유일한 과금 기준이 된다.)*

4. **"Glue와 EMR은 항상 교환 가능하다."** → Glue는 서버리스·관리 편의성에 최적화됩니다. EMR은 커스텀 라이브러리 설치, 장기 실행 클러스터, 세밀한 리소스 제어가 필요할 때 선택합니다. 비용·운영 복잡도가 다릅니다.
   *(원리: §6 — Glue가 추상화한 실행 환경 제어권을 EMR은 직접 허용하므로, 커스텀 의존성이나 클러스터 세밀 조정이 필요한 상황에서는 EMR이 대체 불가한 선택이 된다.)*

5. **"Lake Formation이 IAM을 대체한다."** → Lake Formation은 IAM 권한 모델을 대체하지 않고 **확장**합니다. Lake Formation 권한과 IAM 권한 모두 충족해야 접근이 허용됩니다.
   *(원리: §7 — Lake Formation은 IAM이 표현하기 어려운 데이터 객체 수준 세밀 제어를 추가하는 확장 계층이므로, IAM과 Lake Formation 권한이 모두 만족돼야 접근이 허용된다.)*

6. **"Kinesis Data Streams 샤드는 자동 확장된다."** → 샤드 수는 자동으로 증가하지 않습니다. 처리량이 한계에 도달하면 수동으로 샤드 수를 늘리거나 Shard Split을 사용합니다. (Enhanced Fan-Out은 소비 측 처리량을 늘리는 기능입니다.)
   *(원리: §2 본문 — Kinesis 4종은 각 단계의 수집·처리 복잡도를 분리한 설계이며, Data Streams의 샤드는 처리량 단위를 명시적으로 제어하는 수동 관리 구조다.)*

7. **"DataSync와 Firehose가 같은 역할이다."** → DataSync는 파일 시스템(NFS·SMB)을 S3·EFS로 동기화하는 전송 도구입니다. Firehose는 스트리밍 레코드를 목적지로 전달하는 적재 서비스입니다. 데이터 성격이 다릅니다.
   *(원리: §9 — 배치 수집(파일 동기화)과 스트리밍 수집(레코드 단위 실시간)은 데이터 단위와 처리 지연이 근본적으로 다르므로 서비스 역할도 다르다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 웹 애플리케이션에서 초당 수천 건의 클릭스트림 이벤트를 수집합니다. 수집 후 두 개의 독립적인 애플리케이션이 같은 데이터를 각각 다른 용도로 처리해야 합니다. 가장 적합한 서비스는?

<details><summary>정답 보기</summary>

**Amazon Kinesis Data Streams**입니다. 동일 스트림을 여러 컨슈머가 독립적으로 읽는 fan-out을 지원합니다. 두 애플리케이션(예: 집계용 + 아카이브용)이 같은 스트림에서 각자의 오프셋을 유지하며 데이터를 소비할 수 있습니다. Firehose는 단일 목적지 적재 전용이므로 다중 독립 컨슈머 시나리오에는 적합하지 않습니다.
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

**AWS Lake Formation**입니다. Glue Data Catalog 위에 컬럼·행·셀 수준의 세밀한 접근 제어를 제공합니다. 분석가 IAM 역할별로 특정 컬럼 접근을 허용하거나 거부할 수 있으며, 이 권한은 Athena·EMR·Redshift Spectrum 쿼리 시 일관되게 적용됩니다.
</details>

**Q5 (원리).** 왜 Glue Crawler가 스키마를 등록한 테이블은 Athena와 EMR이 별도 설정 없이 바로 쿼리할 수 있을까요?

<details><summary>정답 보기</summary>

Glue Data Catalog가 Athena·EMR·Redshift Spectrum이 모두 참조하는 중앙 메타데이터 허브이기 때문입니다. 크롤러가 스키마를 Catalog에 한 번 등록하면, 각 서비스가 동일 Catalog의 테이블 정의를 공유 참조하므로 서비스마다 스키마를 별도로 정의할 필요가 없습니다. 분석 도구를 전환하거나 복수의 도구를 병행해도 스키마 불일치 없이 동일 데이터를 쿼리할 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. 모든 URL은 WebFetch로 HTTP 200 확인 완료. (작성·대조: 2026-06-07)

1. Amazon Kinesis Data Streams — 소개 — https://docs.aws.amazon.com/streams/latest/dev/introduction.html
2. Amazon Data Firehose — 서비스 소개 — https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
3. AWS Glue — 서비스 소개 — https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html
4. Amazon Athena — 서비스 소개 — https://docs.aws.amazon.com/athena/latest/ug/what-is.html
5. Amazon EMR — 서비스 소개 — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html
6. AWS Lake Formation — 서비스 소개 — https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html
7. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
