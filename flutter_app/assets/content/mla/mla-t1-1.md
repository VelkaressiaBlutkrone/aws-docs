---
examGuideTaskId: mla-t1-1
certCode: MLA-C01
domain: 1
domainName: 기계 학습(ML)을 위한 데이터 준비
domainWeightPct: 28
title: 데이터 수집·저장 (형식·스트리밍·스토리지·학습 입력 모드)
coversTasks:
  - "1.1"
sources:
  - title: Common Data Formats for Training (Amazon SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/cdf-training.html
  - title: Setting up training jobs to access datasets (Amazon SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html
  - title: Choosing an input mode and a storage unit (Amazon SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data-best-practices.html
  - title: What is Amazon Data Firehose? (공식 문서)
    url: https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html
  - title: Choose the right mode to stream in (Amazon Kinesis Data Streams 공식 문서)
    url: https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html
  - title: Understanding and managing Amazon S3 storage classes (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html
  - title: Data sources and ingestion (Amazon SageMaker Feature Store 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-ingest-data.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 데이터 수집·저장 (형식·스트리밍·스토리지·학습 입력 모드)

> **커버하는 공식 Task** — MLA-C01 · 도메인 1 「기계 학습(ML)을 위한 데이터 준비」(28%) · **Task 1.1 데이터를 수집 및 저장** (`mla-t1-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 1은 시험에서 가장 큰 덩어리이고, 그중 1.1은 **"데이터가 어디서 들어와 어디에 놓이고, 학습 잡은 그걸 어떻게 읽는가"** — ML 파이프라인의 입구입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 행 기반(CSV·JSON·Avro)과 열 기반(Parquet·ORC)을 **접근 패턴**으로 가를 수 있다
- [ ] SageMaker 내장 알고리즘이 받는 **content type**이 정해져 있다는 것을 알고, 분석용 형식과 학습 입력 형식을 구분한다
- [ ] File·FastFile·Pipe·FSx for Lustre·EFS를 **데이터 크기·파일 개수·읽기 패턴**으로 고를 수 있다
- [ ] KDS·Firehose·Managed Service for Apache Flink·MSK를 **"저장·재처리 / 전달·변환 / 상태 있는 계산 / Kafka 호환"**으로 가른다
- [ ] S3 스토리지 클래스와 EBS·EFS·FSx를 **데이터 구조 × 접근 빈도 × 비용 구조**로 고른다
- [ ] Transfer Acceleration·멀티파트·prefix 분산이 각각 **어떤 병목**을 푸는지 구분한다
- [ ] Feature Store의 온라인·오프라인 스토어와 `PutRecord`(스트리밍) vs 배치 수집을 구분한다
- [ ] 오류 메시지에서 **어느 층의 한도**(샤드·prefix·버퍼·드라이버 메모리·볼륨 vs 인스턴스)인지 좁힌다

---

## 🎯 왜 중요한가

ML 파이프라인에서 가장 먼저 깨지는 곳은 모델이 아니라 **입구**입니다. 형식을 잘못 고르면 Athena 스캔 비용이 몇 배가 되고, 입력 모드를 잘못 고르면 학습이 시작도 못 한 채 수십 분을 다운로드에 씁니다. 수집 서비스를 잘못 고르면 "소비자 코드를 직접 운영"하게 되고, 스토리지를 잘못 고르면 복원해야만 읽을 수 있는 아카이브에 학습 데이터를 넣게 됩니다.

시험이 이 Task에서 묻는 것도 구현 코드가 아니라 **선택과 그 제약**입니다. "이 상황에서 무엇을 고르는가", 그리고 "이 오류가 났을 때 어느 층을 손대는가".

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **스트리밍 4분기**: 소비자 코드 없이 S3 적재·형식 변환 → **Firehose** · 여러 소비자·재처리 → **KDS** · 윈도·조인 → **Managed Service for Apache Flink** · 기존 Kafka → **MSK**
- **Firehose 형식 변환 3요소**: 입력이 **JSON일 때만** 동작하고 역직렬화기 + **Glue Data Catalog 스키마** + 직렬화기가 모두 필요
- **Firehose 버퍼**: S3는 크기 1–128 MB(기본 5)·간격 0–900초(기본 300)에서 **먼저 충족되는 쪽**. Parquet 변환을 켜면 크기가 **64–128 MB**로 올라감
- **Lambda 변환 3숫자**: 버퍼 0.2–3 MB · 호출 **5분** · 요청과 응답 **각 6 MB**
- **KDS 샤드 한도**: 쓰기 **1 MB/s·1,000 records/s** · 읽기 **2 MB/s·초당 5 트랜잭션** · `PutRecords` 한 요청 500 레코드
- **입력 모드는 크기 → 파일 개수 → 읽기 패턴 순**: 이미 EFS면 EFS → 작으면 **File** → 작은 파일이 많으면 **큰 컨테이너로 직렬화** → 크고 파일도 크면 **FastFile** → 임의 읽기·직렬화 불가면 **FSx for Lustre**
- **한도 층을 먼저 말한다**: `ProvisionedThroughputExceededException`은 **샤드**, `503 Slow Down`은 **prefix**
- ⚠️ **on-demand는 파티션 키 불균형을 고치지 못한다** — 단일 키가 샤드 한도를 넘으면 **키 설계**를 바꾼다
- **S3 클래스**: 접근 패턴을 모르면 **Intelligent-Tiering**(단 **128 KB 미만은 모니터링 대상 아님**) · Standard-IA는 **최소 과금 128 KB·최소 보관 30일**
- **Feature Store `PutRecord`**: `EventTime`이 더 크면 온라인·오프라인 **둘 다**, 그렇지 않으면 과거 레코드로 보고 **오프라인에만** 쓴다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **content type** | 학습 잡이 알고리즘 컨테이너에 데이터를 넘길 때 쓰는 MIME 형식(`text/csv`, `application/x-recordio-protobuf` 등). 알고리즘마다 받는 것이 정해져 있다 |
| **입력 모드** | 학습 인스턴스가 데이터를 읽는 방식(File·FastFile·Pipe) 또는 파일 시스템 마운트(FSx for Lustre·EFS) |
| **샤드(shard)** | Kinesis Data Streams의 용량 단위. 스트림 용량 = 샤드 용량의 합 |
| **파티션 키** | KDS 레코드를 어느 샤드에 넣을지 정하는 키. MD5 해시로 128비트 정수에 매핑된다 |
| **버퍼 힌트** | Firehose가 "얼마나 모았다가 보낼지"(크기 MB·간격 초). **먼저 충족되는 조건**에서 전달한다 |
| **prefix** | S3 키의 앞부분. 요청률 한도가 prefix 단위로 적용된다 |
| **온라인/오프라인 스토어** | Feature Store의 두 저장소. 온라인은 최신 레코드만(ms 지연 서빙), 오프라인은 전체 이력(S3 Parquet, 학습용) |

---

## 📖 핵심 개념

### 1) 데이터 형식 — 행 기반과 열 기반을 가르는 질문 {#formats}

형식을 고르는 기준은 **"누가, 어떻게 읽는가"** 하나입니다.

| 형식 | 저장 방식 | 쓰는 때 | 제약 |
|---|---|---|---|
| CSV | 행 기반 | 단순·범용. 내장 알고리즘 다수가 `text/csv`로 받음 | 열 단위 선택·통계 기반 건너뛰기 불가. 압축된 텍스트는 일반적으로 병렬 처리 불가 |
| JSON / JSON Lines | 행 기반 텍스트(중첩 가능) | 이벤트·로그. Firehose 형식 변환의 입력. BlazingText·DeepAR는 `application/jsonlines` | CSV와 같은 텍스트 제약 |
| Avro | 행 기반 | **쓰기가 잦은** 수집·스트리밍 단계 | 압축률은 Parquet·ORC보다 낮다 |
| Parquet | 열 기반 | **읽기 중심 분석**. Athena가 필요한 열·블록만 읽음. XGBoost·DeepAR가 입력으로 받음 | 파일이 너무 작으면 열 기반 오버헤드가 이점을 넘음 |
| ORC | 열 기반 | 파일이 더 작은 편이고 인덱스가 쿼리를 빠르게 할 수 있음 | **쿼리 유형의 범위**는 Parquet이 더 넓다고 서술됨 |
| RecordIO-protobuf | SageMaker 이진 레코드 | 내장 알고리즘 다수의 표준 입력. Pipe 모드와 함께 | 직접 만들려면 변환이 필요 |

- 기본 블록 크기는 **Parquet row group 128 MB · ORC stripe 64 MB**입니다. 기본값보다 줄이는 것은 권장되지 않습니다.
- **복합 타입은 ORC**: Athena에서 `array`·`map`·`struct` 같은 복합 타입 열을 조회하면, Parquet는 **지정한 열만 선택적으로 읽는 대신 행 전체를 읽습니다.** Athena 문서가 "알려진 문제(known issue)"로 적고 **대안으로 ORC를 고려하라**고 안내하는 지점입니다.
  > 원문: *"when you query columns stored in Parquet that have complex data types … Athena reads an entire row of data instead of selectively reading only the specified columns. This is a known issue in Athena. As a workaround, consider using ORC."* ([Optimize your tables](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning-s3-throttling-optimizing-your-tables.html), 2026-10-26 재확인)
- 쿼리 **유형의 범위**가 넓어야 하면 Parquet, **복합 타입 조회**가 잦으면 ORC — 둘은 서로 다른 축입니다.

> 🧠 **원리** — 열 기반이 분석에 유리한 이유는 세 가지입니다. ① 쿼리에 필요한 열만 읽고, ② 같은 열의 값이 모여 있어 압축이 잘 되며, ③ 파일 메타데이터(최솟값·최댓값)로 필요 없는 데이터를 건너뜁니다. Athena는 **압축 해제 전 스캔 바이트 수**로 요금을 매기므로 열 기반 + 압축은 속도와 비용을 함께 줄입니다.

### 2) 학습 입력 형식 — 분석용 형식과 다르다 {#training-input}

| ContentType | 받는 알고리즘(공식 표의 일부) |
|---|---|
| `text/csv` | IP Insights, K-Means, k-NN, LDA, Linear Learner, NTM, PCA, RCF, XGBoost |
| `application/x-recordio-protobuf` | Factorization Machines, K-Means, k-NN, LDA, Linear Learner, NTM, PCA, RCF, Sequence-to-Sequence |
| `application/jsonlines` | BlazingText, DeepAR |
| `text/libsvm` | XGBoost |
| `application/x-image`, `image/jpeg`, `image/png` | Object Detection, Semantic Segmentation |

자주 걸리는 규칙:

- **CSV는 헤더 레코드가 없어야 하고, 타깃(레이블)은 첫 번째 열**이어야 합니다. 레이블이 없는 비지도 알고리즘은 content type에 레이블 열 수를 적습니다(예: `content_type=text/csv;label_size=0`).
- **XGBoost**는 `text/libsvm`(기본)·`text/csv`·`application/x-parquet`·`application/x-recordio-protobuf`를 지원하고, 공식 문서는 성능을 위해 File 모드를 권장합니다.
- **Linear Learner**는 recordIO-wrapped protobuf와 CSV를 지원합니다. `application/x-recordio-protobuf` 입력은 Float32 텐서만 지원합니다.
- `application/x-recordio`(Object Detection, MXNet)와 `application/x-recordio-protobuf`(SageMaker protobuf)는 **이름이 비슷한 다른 형식**입니다.

> ⚠️ 공식 가이드 K1의 "유효성이 검증된 형식 및 검증되지 않은 형식"은 이 용어를 정의한 공식 문서 페이지를 찾지 못했습니다. 겹칠 수 있는 메커니즘으로 **Glue Schema Registry**(Kinesis 스트림 데이터를 등록된 스키마로 지속 검증), **Firehose 형식 변환**(Glue Data Catalog 스키마 참조), **SageMaker 형식 규칙**(CSV 헤더 없음·레이블 첫 열)이 있지만 같은 개념이라고 단정하지 않습니다.

### 3) 학습 데이터 소스와 입력 모드 {#input-modes}

SageMaker 학습 잡이 데이터를 읽는 위치는 **S3 · EFS · FSx for Lustre** 셋입니다. 데이터셋은 학습 잡과 **같은 리전**에 있어야 합니다.

| 모드 | 동작 | 고르는 기준 | 제약 |
|---|---|---|---|
| **File**(기본) | 학습 시작 **전에 전부 내려받고** 그다음 시작 | 데이터가 비교적 작을 때(약 50–100 GB 미만). 로컬 모드 호환 | 인스턴스 스토리지에 전체가 들어가야 함. 다운로드 시간이 시작 지연 |
| **FastFile** | S3 객체를 POSIX 파일 인터페이스로 노출하고 **읽는 시점에 스트리밍** | 더 큰 데이터셋·큰 파일(50 MB 초과)에서 먼저 시도 | S3 prefix만(manifest·augmented manifest 불가). 순차 읽기에 최적 |
| **Pipe** | FIFO 파이프로 스트리밍, 디스크는 모델 아티팩트 분량만 | 시작 시간·EBS 크기를 줄여야 하는 대용량 | 파이프 하나를 한 프로세스만 읽음. FastFile로 대체되는 추세 |
| **FSx for Lustre** | 파일 시스템 마운트(보통 S3 연결, 지연 로딩) | File에는 너무 크거나, 작은 파일이 많거나, 임의 읽기 | VPC 필수·단일 AZ. 콜드 스타트 |
| **EFS** | 파일 시스템 마운트 | 데이터가 **이미 EFS에 있을 때** | 학습 전에 데이터가 EFS에 있어야 함. VPC 필수 |

**공식 가이드의 선택 흐름**: ① 이미 EFS에 있으면 EFS → ② S3에 있고 비교적 작으면 File → ③ 작지만 **작은 파일이 많으면** TFRecord·WebDataset·RecordIO 같은 큰 컨테이너로 직렬화 → ④ 더 크고 큰 파일이면 먼저 FastFile → ⑤ File에 너무 크거나 작은 파일을 못 묶거나 임의 읽기면 FSx for Lustre.

- 분산 학습에서 File 모드는 `ShardedByS3Key`로 데이터셋을 인스턴스 간에 나눕니다.
- **FSx for NetApp ONTAP**은 학습의 직접 소스 목록에 없습니다. ONTAP 볼륨에 **S3 access point**를 붙이면 `GetObject`·`PutObject` 같은 S3 연산으로 읽을 수 있고 데이터는 ONTAP에 그대로 남습니다 — 즉 "S3 호환 경로"로 쓰는 것이지 학습 채널로 직접 마운트한다고 문서에 적혀 있지는 않습니다.

> 🧠 **원리** — File은 "다 받고 시작", FastFile·Pipe는 "읽는 만큼 스트리밍", FSx·EFS는 "마운트"입니다. 그래서 **시작 지연·디스크 부족**은 스트리밍이나 마운트로 풀고, **작은 파일이 너무 많은 것**은 직렬화하거나 FSx로 갑니다.

### 4) 스트리밍 수집 — 네 서비스를 가르는 한 문장 {#streaming}

| 서비스 | 한 줄 정의 | 고르는 단서 |
|---|---|---|
| **Kinesis Data Streams**(KDS) | 스트림을 **저장**하고 소비자가 읽음 | 여러 소비자·재처리·세밀한 제어 |
| **Amazon Data Firehose** | 대상으로 **전달·변환**(코드·서버 없음) | S3 적재 + JSON→Parquet/ORC + 운영 최소 |
| **Managed Service for Apache Flink** | 스트림을 **처리·분석**(Java·Scala·Python·SQL) | 윈도 집계·조인·상태 있는 계산 |
| **Amazon MSK** | 관리형 **Apache Kafka** | 기존 Kafka 애플리케이션·오픈소스 선호 |

**KDS 핵심 숫자** — 샤드당 쓰기 **1 MB/s·1,000 records/s**, 읽기 **2 MB/s·초당 5 트랜잭션**. 보존 기본 24시간, 최대 365일. `PutRecords` 한 요청은 최대 500 레코드.

| 용량 모드 | 관리 | 고르는 때 | 주의 |
|---|---|---|---|
| Provisioned | 샤드 수를 직접 지정 | 예측 가능한 트래픽, 샤드 분할 같은 세밀한 제어 | 피크를 못 따라가면 예외 |
| On-demand Standard | 자동 확장(직전 30일 피크의 2배까지) | 변동이 크고 예측이 어려울 때 | 피크의 2배를 넘으면 약 15분간 쓰기 예외 가능. **파티션 키 불균형은 해결하지 못함** |
| On-demand Advantage | 계정 수준 설정, warm throughput으로 사전 확보 | 일정한 대량 처리량·많은 EFO 소비자 | 활성화 후 최소 24시간 유지 |

**Firehose 핵심** — 대상은 S3·Redshift·OpenSearch·Apache Iceberg Tables·HTTP 엔드포인트 등. S3 버퍼는 크기 1–128 MB(기본 5)·간격 0–900초(기본 300)이며 **먼저 충족되는 조건**에서 전달합니다(간격 하한은 문서에 따라 60초로도 적혀 있습니다). Parquet 변환·동적 파티셔닝을 켜면 S3 버퍼 크기는 64–128 MB(기본 128)가 됩니다. Lambda 변환은 버퍼 0.2–3 MB·호출 최대 5분·요청과 응답 각각 6 MB 한도입니다. 형식 변환은 **입력이 JSON일 때만** 동작하고 역직렬화기 + Glue Data Catalog 스키마 + 직렬화기 3요소가 필요합니다.

> 🧠 **원리** — KDS는 파티션 키를 해시해 샤드에 배정하므로 **키 분포가 곧 처리량 분포**입니다. 특정 키가 몰리면 샤드 하나만 한계에 닿고, 이건 on-demand 자동 확장으로도 풀리지 않습니다. Firehose는 버퍼가 차거나 시간이 되면 내보내므로 "준실시간 + 큰 파일"에 맞습니다.

### 5) 스토리지 선택 — 구조 × 접근 빈도 × 비용 {#storage-choice}

| S3 클래스 | 설계 용도 | 기억할 제약 |
|---|---|---|
| S3 Standard | 자주 접근, 밀리초 | 최소 보관 기간·최소 객체 크기 없음 |
| S3 Intelligent-Tiering | 접근 패턴을 **모를 때** | 객체당 모니터링 요금, 검색 요금 없음. 30일 미접근이면 IA 티어로. 128 KB 미만은 모니터링 대상 아님 |
| Standard-IA / One Zone-IA | 월 1회 접근, 밀리초 | **최소 과금 크기 128 KB·최소 보관 30일**, GB당 검색 요금. One Zone은 AZ 손실 시 복원 불가 |
| S3 Express One Zone | 지연 민감, 한 자릿수 ms | 단일 AZ·디렉터리 버킷. SageMaker 학습 입력으로 사용 가능 |
| Glacier Instant Retrieval | 분기 1회, 밀리초 | GB당 검색 요금 |
| Glacier Flexible / Deep Archive | 연 1회 이하 | **보관 상태라 실시간 접근 불가 — 먼저 복원해야 한다** |

| 스토리지 | 데이터 구조 | ML에서의 역할 |
|---|---|---|
| S3 | 객체 | 데이터 레이크, 학습 입력·출력, 모델 아티팩트. prefix당 3,500 쓰기류·5,500 읽기류 req/s |
| EBS | 블록(한 AZ의 EC2에 연결) | 학습 인스턴스 볼륨. 지속 IOPS가 필요하면 io2/io1 |
| EFS | 공유 파일(NFS), 서버리스 | 여러 인스턴스가 공유하는 학습 데이터 |
| FSx for Lustre | 병렬 파일 시스템(S3 연동) | 대규모 학습·HPC. scratch(임시·저렴, 복제 없음) vs persistent |
| FSx for NetApp ONTAP | 멀티프로토콜 엔터프라이즈 파일 | 기존 NetApp/NAS 데이터. S3 access point로 S3 API 접근 |
| RDS / DynamoDB | 관계형 / 키-값 | 운영 데이터 원본 → S3 export로 ML에 사용 |

⚠️ **"Amazon Glacier" 서비스와 "S3 Glacier 스토리지 클래스"는 다릅니다.** S3 Glacier 클래스 객체는 S3 안에 있고, 독립 서비스 Amazon Glacier는 2025-11-07부터 신규 고객이 쓸 수 없는 Maintenance 상태입니다.

### 6) 추출·전송 — 어떤 병목을 푸는가 {#transfer}

| 문제 | 해결 | 핵심 |
|---|---|---|
| 대륙 간·장거리 업로드가 느리다 | **S3 Transfer Acceleration** | CloudFront 엣지 경유. 버킷 이름이 DNS 호환이어야 하고 **마침표(".")가 없어야** 하며, 가상 호스트 스타일 요청만 지원. 켠 뒤 최대 20분 뒤 속도 향상 |
| 100 MB 이상 객체, 불안정한 네트워크 | **멀티파트 업로드** | 파트 5 MiB–5 GiB·최대 10,000 파트. 미완료 파트도 저장 요금 → `AbortIncompleteMultipartUpload` 수명주기 규칙 |
| 초당 수천 요청에서 `503 Slow Down` | **prefix 분산·지수 백오프** | prefix당 3,500/5,500 req/s |
| 운영 RDS에 영향 없이 ML 데이터 | **스냅샷 S3 export(Parquet)** | 백그라운드 실행. 내보낸 데이터를 DB로 되돌릴 수는 없음 |
| DynamoDB 테이블 덤프 | **Export to S3** | **RCU를 소모하지 않음**. PITR 활성화 필요 |
| 온프레미스·타 클라우드 파일 이전 | **AWS DataSync** | S3·EFS·FSx로/에서 전송 |

> 🧠 **원리** — Transfer Acceleration은 "**거리** 때문에 느린 구간"을, 멀티파트·병렬 요청은 "**한 연결**의 처리량 한계"를, prefix 분산은 "**요청률 한도**"를 푸는 것입니다. 목적이 서로 달라 함께 쓸 수 있고, 하나를 다른 문제의 답으로 고르면 오답입니다.

### 7) Data Wrangler와 Feature Store로 수집하기 {#wrangler-featurestore}

- **Data Wrangler는 지금 SageMaker Canvas 안에 통합**돼 있습니다. 예전에는 Studio Classic의 기능이었고, 새 Studio는 클래식 Data Wrangler UI를 지원하지 않습니다. Studio Classic은 신규 온보딩이 불가하며 2024-12-31에 유지보수가 종료됐습니다.
- 가져오기 한도: 가져온 데이터셋 최대 **1,000 열**, Canvas 데이터 흐름은 한 번에 최대 30 파일 또는 폴더 1개. 단일 파일은 CSV·Parquet·JSON·ORC·이미지, 폴더 단위는 CSV·Parquet·ORC·이미지(JSON 없음).
- Data Wrangler는 **Athena 연합 쿼리를 지원하지 않습니다.**

**Feature Store에 넣는 경로**

| 경로 | 성격 | 설명 |
|---|---|---|
| `PutRecord` API | 스트리밍(동기) | 한 번에 소량을 밀어 넣어 최신 값을 즉시 반영. `TargetStores`로 온라인·오프라인·둘 다 지정 |
| SDK `ingest` | 배치(DataFrame) | `feature_group.ingest(data_frame=..., max_workers=3, wait=True)`. 최신 SDK 문서는 `ingest_dataframe` 표기도 사용 |
| Data Wrangler 내보내기 | 배치 | 데이터 흐름을 노트북으로 내보내 Processing 잡이 수집 |
| EMR + Spark 커넥터 | 대용량 배치 | Feature Store Spark 커넥터 |

- **온라인 스토어는 최신 레코드만**(ms 지연 읽기, 실시간 추론), **오프라인 스토어는 전체 이력**(S3 Parquet, Athena 쿼리, append-only)입니다.
- `PutRecord`는 새 레코드의 `EventTime`이 더 크면 온라인·오프라인 모두에 쓰고, 그렇지 않으면 **과거 레코드로 보고 오프라인에만** 씁니다.

> 📍 Feature Store의 **설계**(특성 그룹 요건·TTL·시점 정확 조인·교차 계정)는 Task 1.2 문서 「데이터 변환·특성 추출」 8) Feature Store가 정본입니다. 여기서는 **수집 경로**만 다룹니다.

### 8) 여러 소스의 데이터 병합 {#merge}

| 상황 | 도구 | 이유·제약 |
|---|---|---|
| 서버리스 대규모 ETL + 카탈로그 | **AWS Glue** | 크롤러가 스키마를 추론해 Data Catalog에 테이블 생성. Join 변환의 입력은 **정확히 2개** |
| SQL로 결합하고 결과를 새 테이블로 | **Athena CTAS · Federated Query** | CTAS는 Parquet·ORC로 저장. 연합 쿼리는 **읽기 전용**(`INSERT INTO` 불가) |
| 클러스터를 직접 다루는 대규모 Spark | **Amazon EMR** | 기존 Hadoop/Spark 자산 |
| 약 10 GB 이하 기본 ETL | **Glue Python shell** | 1 DPU(16 GB) 또는 0.0625 DPU(1 GB) |
| 스트림 + 정적 데이터 결합 | **Managed Service for Apache Flink** · Glue 스트리밍 ETL | Glue 스트리밍 오토스케일링은 `ForEachBatch` 밖에서 만든 정적 DataFrame과의 조인을 지원하지 않음 |

- **DynamoDB에는 JOIN 연산자가 없습니다.** 다른 소스와 결합하려면 S3로 내보낸 뒤 Athena·Glue·EMR로 처리합니다.
- Glue Join에서 양쪽에 같은 이름의 키가 있으면 충돌이 나고, **Resolve it**이 `ApplyMapping` 노드를 추가해 한쪽 키에 접두를 붙입니다.

### 9) 용량·확장성 문제 — 어느 층의 한도인가 {#troubleshoot}

| 증상 | 원인 | 조치 |
|---|---|---|
| KDS `ProvisionedThroughputExceededException` | 샤드 처리량 한도 초과(급증·샤드 부족·**파티션 키 불균형**) | 지수 백오프 재시도 · 샤드 증가 · **키 분산** · 핫 샤드 분할 · 소비자가 여럿이면 향상된 팬아웃(EFO) |
| on-demand인데도 예외가 계속 | 단일 파티션 키가 샤드 한도를 넘음(자동 확장 범위 밖) | **파티션 키 설계 변경**. 키별 세밀한 분할이 필요하면 provisioned |
| S3 `503 Slow Down` | prefix당 요청률 초과(작은 파일 수천 개를 읽는 쿼리가 대표적) | 지수 백오프 · prefix 분산 · 요청률 점진 상향 · **파일을 크게 합치기** |
| Firehose → S3 전달 실패 | 버킷 없음·IAM·네트워크·S3 5xx | Direct PUT은 최대 24시간 재시도(넘으면 유실), KDS·MSK 소스는 **스트림 보존 기간까지** 재시도 |
| Glue 드라이버 OOM(`Exit Code 1`) | 작은 파일 100만 개 이상의 목록을 드라이버가 메모리에 유지 | **그룹화(grouping)** · 쓰기 전에 파일 합치기 |
| Glue 실행기 OOM | 대형 JDBC 테이블 fetch size 기본 0 → 한꺼번에 가져와 캐시 | 동적 프레임(기본 1,000행) 또는 `fetchsize` 설정 |
| EBS 지연 증가 | 볼륨 IOPS 초과 **또는 인스턴스의 EBS 한도** | 볼륨이면 io2/io1 상향, 인스턴스면 더 큰·EBS-optimized 인스턴스 |
| 학습 시작이 느림·디스크 부족 | File 모드가 전체를 먼저 내려받음 | FastFile·Pipe·FSx 전환, 작은 파일은 큰 컨테이너로 직렬화 |

> 🧠 **원리** — 병목은 항상 **"어느 층의 한도인가"**로 좁힙니다. KDS는 샤드, S3는 prefix, Firehose는 쿼터·버퍼·전달 대상, Glue는 드라이버 vs 실행기 메모리, EBS는 볼륨 vs 인스턴스. 층이 정해지면 조치는 **분산·증설·재시도·합치기** 중 하나로 좁혀집니다.

---

## ✍️ 시험 포인트

- **"운영·코드 최소 + S3에 Parquet"** → Firehose(형식 변환). **"여러 소비자·재처리"** → KDS. **"윈도·조인"** → Managed Service for Apache Flink. **"기존 Kafka"** → MSK.
- **"실시간으로 계산한 특성을 바로 서빙"** → 소비자가 Feature Store `PutRecord`(온라인 스토어).
- 입력 모드는 **데이터 크기 → 파일 개수 → 읽기 패턴** 순으로 좁힙니다. "작은 파일 수백만 개"는 File 모드의 적신호입니다.
- 형식 문제는 **"이 알고리즘이 받는 content type인가"**로 끝납니다. 분석에 좋은 Parquet이라도 Linear Learner의 입력은 아닙니다.
- 오류 코드가 보이면 **한도 층**을 먼저 말하세요. `ProvisionedThroughputExceededException`은 샤드, `503 Slow Down`은 prefix입니다.
- on-demand 전환은 **파티션 키 불균형을 고치지 못합니다.** 키 분포 문제는 키 설계로 풉니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| KDS와 Firehose를 같은 것으로 본다 | KDS는 **저장소**(소비자가 읽음, 보존 최대 365일), Firehose는 **전달 파이프**(대상 하나 + 변환, 장기 보존용 아님) |
| Transfer Acceleration을 `503 Slow Down`의 해결책으로 고른다 | 가속은 **거리** 문제를 푸는 것이고, 요청률 한도는 **prefix 분산·백오프**로 푼다 |
| 분석용 형식(Parquet)을 모든 알고리즘의 학습 입력으로 쓴다 | 알고리즘이 받는 **content type**을 먼저 확인한다(XGBoost·DeepAR는 Parquet을 받지만 Linear Learner는 recordIO-protobuf·CSV) |
| FastFile에 manifest를 쓴다 | FastFile은 **S3 prefix만** 지원한다 |
| FSx for NetApp ONTAP을 학습 채널로 직접 마운트한다 | 학습의 직접 소스는 S3·EFS·**FSx for Lustre**뿐이다. ONTAP은 **S3 access point 경유** |
| CSV 학습 데이터에 헤더를 남기고 레이블을 마지막 열에 둔다 | 헤더 없음 · **레이블은 첫 열** |
| 핫 파티션 키 문제를 on-demand 전환이나 보존 연장으로 해결하려 한다 | 둘 다 키 불균형을 고치지 못한다 — **키 설계**를 바꾼다 |
| Glacier 계열에 학습 데이터를 둔다 | Flexible·Deep Archive는 **복원해야** 접근할 수 있다. 밀리초 접근이 필요하면 Instant Retrieval 이상 |
| 폐지·개명된 이름을 그대로 고른다 | Kinesis Data Firehose → **Amazon Data Firehose**, Kinesis Data Analytics → **Managed Service for Apache Flink**(SQL 전용 애플리케이션은 폐지), SageMaker → **SageMaker AI**(ML 서비스 쪽) |

---

## 🧪 자가 점검

**Q1.** 이벤트 JSON을 S3에 Parquet으로 쌓되 소비자 코드를 만들고 싶지 않다. 무엇을 고르고, 그 서비스가 형식 변환을 하려면 무엇이 필요한가? (→ 4) 스트리밍 수집)

<details><summary>정답 보기</summary>

**Amazon Data Firehose.** 대상으로 전달·변환을 맡아 주므로 소비자 코드와 서버가 필요 없습니다. 다만 형식 변환은 **입력이 JSON일 때만** 동작하고 **역직렬화기 + Glue Data Catalog 스키마 + 직렬화기** 세 요소가 모두 있어야 합니다. Parquet 변환을 켜면 S3 버퍼 크기가 64–128 MB(기본 128)로 올라갑니다.
</details>

**Q2.** 학습 데이터가 20 GB이고 파일은 300만 개다. File 모드가 느린 이유와, 공식 선택 흐름이 제시하는 두 가지 방향은? (→ 3) 입력 모드)

<details><summary>정답 보기</summary>

File 모드는 **학습 시작 전에 전부 내려받고** 그다음 시작하므로, 작은 파일이 수백만 개면 다운로드 시간이 그대로 시작 지연이 됩니다. 공식 흐름은 ① **TFRecord·WebDataset·RecordIO 같은 큰 컨테이너로 직렬화**해 파일 수를 줄이거나 ② 직렬화가 어렵거나 임의 읽기가 필요하면 **FSx for Lustre**로 가라고 안내합니다.
</details>

**Q3.** `ProvisionedThroughputExceededException`이 on-demand 스트림에서도 계속 난다. 가장 먼저 의심할 것은? (→ 9) 한도 층)

<details><summary>정답 보기</summary>

**단일 파티션 키로 쏠린 핫 샤드.** KDS는 파티션 키를 해시해 샤드를 고르므로 키 분포가 곧 처리량 분포이고, **on-demand 자동 확장은 파티션 키 불균형을 해결하지 못합니다**(직전 30일 피크의 2배까지만 확장). 처방은 **파티션 키 설계 변경**이며, 키별 세밀한 분할이 필요하면 provisioned로 갑니다.
</details>

**Q4.** 접근 패턴을 알 수 없는 수집 데이터를 비용 효율적으로 두려면 어떤 S3 클래스를 고르고, 그 클래스가 모니터링하지 않는 객체 크기는? (→ 5) 스토리지 선택)

<details><summary>정답 보기</summary>

**S3 Intelligent-Tiering.** 접근 패턴을 모를 때 쓰며 검색 요금이 없고 30일 미접근이면 IA 티어로 내립니다. 대가는 **객체당 모니터링 요금**이고, ⚠️ **128 KB 미만 객체는 모니터링 대상이 아닙니다**(티어링되지 않습니다). 참고로 Standard-IA는 **최소 과금 크기 128 KB·최소 보관 30일**입니다.
</details>

**Q5.** 온라인 스토어에만 값이 보이지 않고 오프라인에만 쌓인다. `PutRecord`의 어떤 규칙 때문인가? (→ 7) Feature Store 수집)

<details><summary>정답 보기</summary>

**`EventTime` 비교 규칙** 때문입니다. `PutRecord`는 새 레코드의 `EventTime`이 기존보다 **더 클 때만** 온라인·오프라인 둘 다에 쓰고, 그렇지 않으면 **과거 레코드로 보고 오프라인에만** 씁니다(오프라인은 append-only 이력, 온라인은 최신 레코드만). `TargetStores`로 대상을 좁혀 둔 것도 함께 확인합니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며, C01 시험 범위는 아닙니다.

- **C02 대응 Task**: 1.1 「데이터를 수집하고 저장합니다」
- **추가된 항목 2개**
  - `1.1.7` 사양에 따라 AI 애플리케이션을 위한 **확장 가능한 벡터 데이터베이스**를 구성합니다(예: OpenSearch Service, pgvector 기반 Amazon RDS, Amazon S3).
  - `1.1.8` AI 및 ML 애플리케이션을 위한 **다양한 데이터 유형**(텍스트·이미지·오디오)을 수집하고 저장합니다.
- **삭제된 항목**: 이 Task에는 없음

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- [Common Data Formats for Training (SageMaker AI)](https://docs.aws.amazon.com/sagemaker/latest/dg/cdf-training.html) · [Parameters for Built-in Algorithms](https://docs.aws.amazon.com/sagemaker/latest/dg/common-info-all-im-models.html) · [XGBoost 입출력 인터페이스](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost-how-to-use.html) · [Linear Learner](https://docs.aws.amazon.com/sagemaker/latest/dg/linear-learner.html)
- [Setting up training jobs to access datasets](https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html) · [Choosing an input mode and a storage unit](https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data-best-practices.html)
- [Use columnar storage formats (Athena)](https://docs.aws.amazon.com/athena/latest/ug/columnar-storage.html) · [Optimize data (Athena)](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning-data-optimization-techniques.html) · [Optimize your tables (Athena)](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning-s3-throttling-optimizing-your-tables.html)
- [What is Amazon Data Firehose?](https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html) · [Convert input data format](https://docs.aws.amazon.com/firehose/latest/dev/record-format-conversion.html) · [Configure buffering hints](https://docs.aws.amazon.com/firehose/latest/dev/create-configure-backup.html) · [Transform source data](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html) · [Handle data delivery failures](https://docs.aws.amazon.com/firehose/latest/dev/retry.html)
- [KDS Terminology and concepts](https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html) · [Choose the right mode to stream in](https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html) · [Quotas and limits](https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html) · [Provisioned throughput exception errors](https://docs.aws.amazon.com/streams/latest/dev/kinesis-fis-provisioned-throughput.html)
- [What is Amazon Managed Service for Apache Flink?](https://docs.aws.amazon.com/managed-flink/latest/java/what-is.html) · [KDA for SQL 폐지 안내](https://docs.aws.amazon.com/kinesisanalytics/latest/dev/discontinuation.html) · [What is MSK Serverless?](https://docs.aws.amazon.com/msk/latest/developerguide/serverless.html)
- [S3 스토리지 클래스](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html) · [S3 성능 모범 사례](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance.html) · [Transfer Acceleration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html) · [멀티파트 업로드](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpuoverview.html)
- [EBS 볼륨 유형](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volume-types.html) · [EBS Provisioned IOPS](https://docs.aws.amazon.com/ebs/latest/userguide/provisioned-iops.html) · [What is Amazon EFS?](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) · [What is FSx for Lustre?](https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html) · [FSx for ONTAP S3 access points](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/accessing-data-via-s3-access-points.html)
- [Feature Store 수집 경로](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-ingest-data.html) · [Feature Store 개요](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store.html) · [PutRecord API](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_feature_store_PutRecord.html) · [Data Wrangler 가져오기](https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-import.html)
- [Glue 크롤러](https://docs.aws.amazon.com/glue/latest/dg/add-crawler.html) · [Glue Join](https://docs.aws.amazon.com/glue/latest/dg/transforms-configure-join.html) · [Glue OOM 디버깅](https://docs.aws.amazon.com/glue/latest/dg/monitor-profile-debug-oom-abnormalities.html) · [Athena CTAS](https://docs.aws.amazon.com/athena/latest/ug/ctas.html) · [Athena Federated Query](https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html)
- [RDS 스냅샷 S3 export](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ExportSnapshot.html) · [DynamoDB Export to S3](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/S3DataExport.HowItWorks.html) · [AWS DataSync](https://docs.aws.amazon.com/datasync/latest/userguide/what-is-datasync.html)
- [SageMaker AI 개명 안내](https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html) · [AWS 서비스 수명주기](https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html) · [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/1-1.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
