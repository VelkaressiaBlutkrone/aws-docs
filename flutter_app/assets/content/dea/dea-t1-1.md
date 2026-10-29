---
examGuideTaskId: dea-t1-1
certCode: DEA-C01
domain: 1
domainName: 데이터 수집 및 변환
domainWeightPct: 34
title: 데이터 수집 수행 (스트리밍·배치·트리거)
coversTasks:
  - "1.1"
sources:
  - title: Amazon Kinesis Data Streams FAQs (공식)
    url: https://aws.amazon.com/kinesis/data-streams/faqs/
  - title: Quotas and limits — Kinesis Data Streams (공식 문서)
    url: https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
  - title: Amazon Data Firehose FAQs (공식)
    url: https://aws.amazon.com/firehose/faqs/
  - title: Change data capture for DynamoDB Streams (공식 문서)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html
  - title: Event notification types and destinations — Amazon S3 (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html
  - title: DEA-C01 공식 시험 가이드 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
lastVerified: 2026-10-19
---

# 데이터 수집 수행 (스트리밍·배치·트리거)

> **커버하는 공식 Task** — DEA-C01 · 도메인 1 「데이터 수집 및 변환」(34%) · **Task 1.1 데이터 수집 수행** (`dea-t1-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 1은 시험에서 가장 큰 덩어리이고, 그중 1.1은 **"데이터가 어디서 어떻게 들어오는가"** — 파이프라인의 입구입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 1.1의 Skill 항목)

- [ ] **스트리밍 소스 네 갈래**(Kinesis Data Streams · Data Firehose · MSK · DynamoDB Streams)를 요구사항으로 구분해 고를 수 있다
- [ ] KDS의 **샤드 한도·용량 모드·소비자 방식(공유 vs EFO)** 을 숫자로 말할 수 있다
- [ ] Firehose의 **버퍼링 힌트·형식 변환·동적 파티셔닝·재시도 한도**가 무엇을 조절하는지 안다
- [ ] **배치 수집의 증분 전략**(Glue 북마크 · AppFlow 증분 · Redshift COPY/UNLOAD)을 구분한다
- [ ] **스케줄러**(EventBridge Scheduler · 예약 규칙 · Glue 일정 · MWAA)와 **이벤트 트리거**(S3 알림 · EventBridge)를 상황에 맞게 선택한다
- [ ] **스로틀링 대처와 재처리(replayability)**, 그리고 스테이트풀·스테이트리스 처리의 차이를 설명한다
- [ ] 데이터 소스 연결을 위한 **IP 허용 목록·고정 출구 IP** 구성을 안다

---

## 🎯 왜 중요한가

- 도메인 1은 채점 콘텐츠의 **34%** 로 네 도메인 중 가장 큽니다. 그 입구인 Task 1.1은 **Skill 12개·서비스 20여 개**에 걸쳐 있어 출제 표면이 넓습니다.
- 시험은 서비스 이름을 묻지 않고 **"이 요구사항에 무엇을 쓰는가"** 를 묻습니다. 그래서 서비스별 한도와 제약이 곧 정답 근거가 됩니다 — 샤드 처리량, 버퍼 크기, 보존 기간, 재시도 한도가 선택지를 갈라냅니다.
- 이 Task의 개념은 뒤 Task(1.2 변환·1.3 오케스트레이션·1.4 프로그래밍)의 전제입니다. 수집 경로를 잘못 고르면 뒤의 변환·스케줄 설계가 전부 흔들립니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **샤드** | shard | Kinesis Data Streams의 용량 단위 — 처리량 한도가 샤드 단위로 매겨짐 |
| **파티션 키** | partition key | 레코드를 어느 샤드로 보낼지 결정하는 값. 같은 키는 같은 샤드로 가 순서가 유지됨 |
| **팬인 / 팬아웃** | fan-in / fan-out | 많은 소스가 하나의 스트림으로 모이는 것 / 하나의 데이터를 여러 소비자에게 퍼뜨리는 것 |
| **EFO** | enhanced fan-out | 소비자마다 전용 읽기 처리량을 주는 KDS 소비자 방식 |
| **CDC** | change data capture | 원본 DB의 변경分만 뽑아 전달하는 방식(보통 트랜잭션 로그를 읽음) |
| **버퍼링** | buffering | 데이터를 일정 크기나 시간만큼 모아 한 번에 전달하는 것 |
| **잡 북마크** | job bookmark | AWS Glue가 이미 처리한 지점을 기억해 다음 실행에서 증분만 읽게 하는 상태 |
| **스로틀링** | throttling | 한도를 넘는 요청을 서비스가 거절·지연시키는 것 |
| **재생 가능성** | replayability | 같은 데이터를 다시 읽어 재처리할 수 있는 성질 |

---

## 📖 핵심 개념

### 1) 스트리밍 소스 네 갈래 — 무엇으로 받을까 {#streaming-choice}

스트리밍 수집 문제는 다섯 질문으로 갈립니다. **누가 읽는가 · 재처리가 필요한가 · 순서가 중요한가 · 소비자 코드를 쓸 것인가 · Kafka 호환이 필요한가.**

| 서비스 | 이럴 때 고른다 | 핵심 제약 | 시험 단서 |
|---|---|---|---|
| **Kinesis Data Streams (KDS)** | 여러 소비자가 같은 데이터를 독립 소비, 샤드 내 순서, 보존 기간 내 재처리 | 샤드당 쓰기 1 MB/s·1,000 records/s, 읽기 2 MB/s · 보존 기본 24시간~최대 365일 | "여러 애플리케이션이 동일 스트림", "재처리", "샤드" |
| **Amazon Data Firehose** | 소비자 코드 없이 S3·Redshift·OpenSearch 등으로 적재 + 형식 변환 | 버퍼링 후 전달(S3 기본 5 MB·300초) · **at-least-once라 중복 가능** · 스트림당 S3 버킷 1개 | "코드·서버 없이 S3로", "Parquet 변환", "버퍼 크기/간격" |
| **Amazon MSK** | 관리형 Apache Kafka — 기존 Kafka 앱·Kafka Connect·오픈소스 선호 | Provisioned는 브로커 단위 확장, Serverless는 추상화 | "Apache Kafka", "토픽·파티션·컨슈머 그룹" |
| **DynamoDB Streams** | DynamoDB 테이블의 항목 수준 변경 캡처 | **보존 24시간**, 샤드당 읽기 프로세스 2개 이하 | "DynamoDB 변경 캡처", "항목 단위 순서" |

> 선택 규칙: 목적지가 S3·Redshift이고 필요한 처리가 **변환·형식 변환·파티셔닝 정도면 Firehose**가 소비자 코드를 없애 줍니다. 반대로 **소비자가 둘 이상이거나 과거 데이터를 다시 읽어야 하면 KDS**입니다. KDS를 Firehose의 소스로 붙일 수도 있는데, 이때 Firehose의 읽기도 **샤드 읽기 한도를 소모**합니다.

> 🧠 원리: 왜 "소비자 코드 유무"가 KDS와 Firehose를 가르는 첫 질문일까요?
> KDS는 데이터를 **보관**하고 소비자가 당겨 읽는 스트림 저장소라서, 읽는 주체(KCL 앱·Lambda·Flink)를 반드시 누군가 운영해야 합니다.
> Firehose는 반대로 목적지로 **밀어 주는** 전달 파이프라서 소비자 운영이 사라지지만, 그 대가로 보관·재읽기 능력을 잃습니다.
> 즉 "코드를 없앨 것인가 vs 다시 읽을 것인가"의 교환이고, 시험 문항의 요구사항 문장이 그 교환을 어느 쪽으로 밀어 두었는지를 보면 정답이 나옵니다.

### 2) KDS 용량 모드·샤드·소비자 {#kds-capacity}

KDS는 **샤드가 용량 단위**입니다. 시험은 한도와 모드를 요구사항에 맞춰 고르게 합니다.

- **프로비저닝 모드** — 샤드 수를 직접 정합니다. 초기 샤드 수는 `max(쓰기 KB/1000, 읽기 KB/2000)`으로 산정하고, 확장은 샤드 분할(SplitShard)·병합(MergeShard) 또는 UpdateShardCount로 합니다(이 API는 프로비저닝 전용).
- **온디맨드 모드** — 용량을 자동 관리합니다. 새 스트림 기본 한도는 **쓰기 4 MB/s·읽기 8 MB/s**이고, **직전 30일 피크의 2배**까지 수용합니다. 15분 안에 그보다 더 늘면 스로틀되므로 재시도가 필요합니다. 모드 전환은 **스트림당 24시간에 2회**까지입니다.
- **쓰기 경로** — PutRecord/PutRecords, KPL, Kinesis Agent. **PutRecords는 요청당 500 레코드**, 데이터 블롭은 **최대 10 MiB**입니다. 파티션 키로 샤드를 결정하고, 같은 키의 시퀀스 번호는 시간에 따라 증가합니다.
- **보존** — 기본 24시간, **최대 365일**. 기본보다 길게 보존한 데이터도 같은 읽기 API로 읽습니다.
- **한도 초과** — 쓰기·읽기 모두 한도를 넘으면 스로틀됩니다. 재시도로 흡수하고, 지속되면 샤드를 늘립니다.

**소비자 방식 — 공유 처리량 vs EFO**

| 항목 | 공유 처리량(기본) | EFO (향상된 팬아웃) |
|---|---|---|
| 전달 방식 | GetRecords — 소비자가 당겨 읽음 | SubscribeToShard — 지속 연결로 밀어 줌(HTTP/2) |
| 읽기 처리량 | 샤드의 **2 MB/s·초당 5 읽기 트랜잭션을 소비자들이 나눠 씀** | **소비자마다 샤드당 전용 2 MB/s** |
| 지연 | 소비자가 늘수록 경합 | 통상 **70 ms**(GetRecords 대비 약 65% 빠름) |
| 등록 수 | 해당 없음 | 기본 20 (On-demand Advantage에서 50) |
| 시험 단서 | 소비자 1개 | **소비자 2개 이상**, "읽기 스로틀·지연" |

> 🧠 원리: 소비자를 추가했는데 왜 전체가 느려질까요?
> 공유 처리량 모드에서 샤드의 읽기 한도(2 MB/s·초당 5회)는 **샤드에 붙은 모든 소비자의 합**에 걸립니다.
> 소비자 수가 늘면 각자가 쓸 수 있는 몫이 줄고 GetRecords 호출이 서로 경합해 지연이 커집니다.
> EFO는 소비자별로 전용 파이프를 하나씩 더 열어 주는 방식이라, 추가 비용을 내고 이 경합 자체를 없애는 선택입니다.

### 3) Amazon Data Firehose — 버퍼링이 전부다 {#firehose}

- **소스**: Direct PUT/API, KDS, MSK, AWS 서비스(CloudWatch·EventBridge·IoT), Kinesis Agent, Lambda. **KDS를 소스로 지정하면 Firehose 쪽 PutRecord는 비활성화**되고 KDS API로만 넣습니다.
- **버퍼링(배치 구성의 핵심)**: 버퍼 **크기와 간격 중 먼저 충족된 조건**에서 전달합니다. S3 목적지는 크기 **1~128 MB**, 간격 **0~900초**, 기본값 **5 MB·300초**입니다. Parquet 변환·동적 파티셔닝을 켜면 크기가 **64~128 MB** 범위가 되고, 간격 0(제로 버퍼링)은 수 초 안에 전달하지만 **동적 파티셔닝과 함께 쓸 수 없습니다**. 크기는 압축 전 기준이며, 전달이 밀리면 Firehose가 버퍼를 자동으로 키웁니다.
- **Lambda 변환**: 변환 버퍼 힌트 0.2~3 MB(기본 1 MB). 호출 실패는 **기본 3회 재시도 후 그 배치를 건너뛰고**(0~300회로 설정), 처리 실패 레코드는 S3의 `processing_failed` 폴더로 갑니다. 변환 전 원본은 S3에 따로 백업할 수 있습니다.
- **형식 변환·동적 파티셔닝**: JSON을 Parquet/ORC로 변환하고, JSON 키(내장 jq 파서)나 Lambda가 만든 키로 S3 prefix를 나눕니다. 활성 파티션은 **스트림당 기본 500개**입니다.
- **재시도·손실 시점**: 목적지 장애 시 **Direct PUT 소스 데이터는 최대 24시간 보관**(그 뒤 폐기), **KDS 소스는 KDS에 설정한 보존 기간까지**. Redshift 목적지는 S3에 쓴 뒤 COPY를 **5분 간격·최대 120분** 재시도합니다. 전달은 **at-least-once**라 중복이 생길 수 있습니다.
- **한도**: 레코드 **1,000 KiB**, PutRecordBatch 500개 또는 4 MiB, 하나의 Firehose 스트림은 **S3 버킷 하나**에만 전달.

### 4) CDC와 DB 소스 — DynamoDB·DMS·Glue·Redshift {#cdc-sources}

| 항목 | DynamoDB Streams | Kinesis Data Streams for DynamoDB |
|---|---|---|
| 보존 | **24시간** | 기본 24시간, **최대 1년** |
| 소비자 | 샤드당 2개 이하 | EFO 사용 시 샤드당 최대 20 |
| 순서 | **항목별 순서 보장** | 보장 없음 — 클라이언트가 타임스탬프로 정렬 |
| 중복 | 레코드는 한 번만 | 간헐적 중복 가능 — 클라이언트가 걸러냄 |
| 시험 단서 | "항목 단위 순서", Lambda 트리거 | "장기 재생", KCL/Flink/Firehose 연동 |

- **스트림 뷰 타입**(KEYS_ONLY / NEW_IMAGE / OLD_IMAGE / NEW_AND_OLD_IMAGES)은 **설정 후 변경할 수 없습니다.**
- **AWS DMS** — 소스 DB의 트랜잭션 로그를 읽어 변경을 전달합니다. ①전체 로드만 ②전체 로드 후 CDC ③CDC만, 세 방식입니다. **CDC는 실시간 복제가 아니며 지연 SLA가 없습니다.** 전체 로드 병렬도는 `MaxFullLoadSubTasks`로 조절(기본 8, 최대 49). Kinesis를 대상으로 쓰면 중복은 소비자가 처리해야 합니다.
- **AWS Glue 스트리밍 ETL** — KDS·Kafka·MSK를 읽어 변환 후 S3/JDBC에 적재합니다. 기본 100초 윈도로 처리하고, 위치 추적은 **북마크가 아니라 체크포인트**입니다.
- **Redshift 스트리밍 수집** — KDS·MSK에서 **구체화된 뷰로 직접**(S3 스테이징 없음) 들어옵니다. 스트림/토픽당 구체화된 뷰 1개를 권장하며, KDS 24시간·MSK 7일 기본 보존이라 전체 재계산은 불가능합니다. **KPL로 집계한 레코드는 파싱되지 않고 바이너리로 저장**됩니다.

### 5) 배치 수집·증분 전략·데이터 API {#batch-ingestion}

배치 문제는 **무엇을 증분으로 읽는가 · 파일 크기·형식·파티션 · 어떤 주기**로 풀립니다.

- **S3 → Glue 북마크**: 처리 대상을 **S3 객체의 수정 시각**으로 판별하므로, 이미 처리한 파일도 **수정되면 다시 처리**됩니다. 북마크 기본값은 **비활성(매번 전체 처리)**. 입력 파일이 5만 개를 넘으면 Glue가 파일 그룹화를 자동으로 켭니다.
- **JDBC → Glue 북마크**: 기본키를 북마크 키로 쓰되 **순증가(또는 순감소)해야** 합니다. 병렬 읽기는 해시 필드·해시 표현식으로 나눕니다.
- **Amazon Redshift**: 적재는 **COPY** — 파일을 비슷한 크기(압축 후 **1 MB~1 GB**)로 나누고 **파일 수를 슬라이스 수의 배수**로 맞춥니다. 추출은 **UNLOAD** — 파일 **128~512 MB**를 권장하고 Parquet이 텍스트보다 저장 공간이 적습니다.
- **Amazon AppFlow**: SaaS ↔ AWS 전송. 트리거는 **온디맨드·이벤트·스케줄** 세 종류이며, 스케줄 플로는 전체/증분을 고르고 **첫 증분 실행은 30일 치**를 가져옵니다.
- **AWS Lambda**: 함수 제한 시간이 **900초(15분)** 이라 장시간 배치 읽기에는 부적합합니다.
- **Amazon EMR**: `S3DistCp`로 S3의 대량 데이터를 HDFS로 효율적으로 복사합니다.
- **Redshift Data API**: 드라이버·연결·네트워크를 관리하지 않고 SDK/HTTP로 SQL을 실행합니다. **호출은 비동기**이고 자격은 Secrets Manager 또는 임시 DB 자격 증명을 씁니다. 쿼리 최대 24시간, 결과 500 MB(gzip 후)·보관 24시간입니다.

### 6) 언제 시작할까 — 스케줄 vs 이벤트 {#triggers}

**시간으로 시작하는 수단**

| 수단 | 특성 | 정밀도·제약 | 시험 단서 |
|---|---|---|---|
| **EventBridge Scheduler** | rate / cron / one-time, **시간대 지정**, 유연한 시간 창·재시도 | 모든 스케줄 유형이 **60초 정밀도** | "스케줄 + 재시도/시간대" (권장 수단) |
| EventBridge 예약 규칙 | **legacy** 기능, 기본 이벤트 버스만, **UTC+0** | 최소 1분 | "legacy" 표기 → Scheduler 권장 |
| Glue 트리거·크롤러 일정 | cron 기반(**UTC**), 조건부 트리거는 앞선 잡 상태에 반응 | **최소 5분**, 트리거 하나가 시작할 크롤러는 2개 | "Glue 잡 체이닝", "크롤러 주기" |
| Amazon MWAA (Airflow) | DAG `schedule_interval`에 cron | — | "복잡한 워크플로 오케스트레이션" |

**S3 이벤트를 받는 두 방법**

| 항목 | S3 Event Notifications(직접) | S3 → EventBridge |
|---|---|---|
| 대상 | SNS(Standard만)·SQS(Standard만)·Lambda·EventBridge | 규칙으로 다중 대상 |
| 이벤트당 대상 | 알림 설정 하나에 **대상 유형 하나** | 같은 이벤트를 여러 대상에 |
| FIFO | **SQS/SNS FIFO 불가** (FIFO는 EventBridge 경유) | FIFO 큐 대상 가능 |
| 필터 | 알림 설정 범위 안에서 | 객체 크기·키 이름·시간 범위 등 고급 필터 |
| 전달 보장 | **최소 1회·순서 비보장·드물게 중복** | 최소 1회 |
| 재처리 | — | **이벤트 아카이브·재생** |

> 주의: 알림이 **같은 버킷에 쓰기를 일으키면 실행 루프**가 생깁니다 — 버킷을 분리하거나 prefix를 제한하세요. **Glue 크롤러 S3 이벤트 모드**는 전체 목록 대신 변경된 폴더만 리스팅해 재크롤 비용을 줄입니다(크롤 한 번에 메시지 최대 100,000개).

### 7) 스로틀·재처리·연결 제약 {#throttle-replay}

- **Kinesis → Lambda 튜닝**: 지연(IteratorAge 증가)은 `ParallelizationFactor` 상향(1~10, **파티션 키 수준 순서는 유지**) 또는 샤드 증설로 풉니다. 호출 횟수는 `BatchSize`(최대 10,000)·배치 윈도(최대 5분)로 조절합니다. **기본값은 재시도·레코드 연령이 무제한이라 불량 레코드 하나가 샤드를 최대 1주 막습니다** — `MaximumRetryAttempts`·`MaximumRecordAgeInSeconds`로 끊고, `BisectBatchOnFunctionError`로 불량 레코드를 격리하고, 폐기 레코드는 **실패 대상(SQS/SNS)** 으로 보관합니다.
- **재처리 수단**: KDS는 보존 기간 안에서 `TRIM_HORIZON`/`AT_TIMESTAMP`로 다시 읽습니다. 이벤트는 **EventBridge 아카이브 재생**, 큐는 **SQS DLQ redrive**. **Firehose는 재생 수단이 아닙니다**(Direct PUT 보관 24시간).
- **쓰기 스로틀 대처**: SDK의 **지수 백오프 + 지터**(백오프는 간격을 늘리고, 지터는 재시도 시점을 흩뜨려 군집을 막습니다), DynamoDB는 파티션 키 카디널리티·온디맨드 모드 검토, Lambda→RDS 연결 폭증은 **RDS Proxy**.
- **IP 허용 목록·고정 출구 IP**: 상대 방화벽이 고정 IP만 허용하면 **프라이빗 서브넷의 Lambda + 퍼블릭 서브넷 NAT 게이트웨이의 Elastic IP**로 나갑니다. 퍼블릭 서브넷에 함수를 붙이는 것만으로는 인터넷에 나가지 못하고, `ip-ranges.json`의 AWS 범위는 **서비스 공용 범위이지 우리 고정 출구 IP가 아닙니다.**
- **스테이트풀 vs 스테이트리스**: Lambda는 기본 무상태이고, **텀블링 윈도**로 샤드당 1 MB 상태를 들 수 있으나 리샤딩을 지원하지 않습니다. 대규모 상태는 **Managed Service for Apache Flink**의 체크포인트/스냅샷을 씁니다.

---

## ✍️ 시험 포인트

- "**코드·서버 없이** S3/Redshift로 적재 + Parquet" → **Firehose**. "**여러 앱이 독립 소비**·재처리·순서" → **KDS**. "**기존 Kafka**" → **MSK**. "DynamoDB 항목 변경 + 항목별 순서" → **DynamoDB Streams**.
- 숫자로 갈리는 보기: 샤드 **1 MB/s 쓰기·2 MB/s 읽기**, 온디맨드 기본 **4/8 MB/s**, Firehose S3 기본 버퍼 **5 MB·300초**, DynamoDB Streams 보존 **24시간**, Lambda 제한 시간 **900초**.
- "소비자를 추가하니 읽기 스로틀" → **EFO**(소비자당 전용 2 MB/s).
- "전달 실패 후 **언제 데이터가 사라지나**" → Direct PUT **24시간**, KDS 소스는 **KDS 보존 기간**, Redshift COPY는 **최대 120분 재시도**.
- "FIFO 큐로 S3 이벤트" → 직접 알림 불가, **EventBridge 경유**. "여러 대상·고급 필터·재생" → **EventBridge**.
- 스케줄 정밀도: Scheduler **60초** / 예약 규칙(legacy) **1분·UTC** / Glue **5분·UTC**.
- "북마크를 켰는데 다시 처리됨" → S3 **수정 시각** 기준이라 파일이 수정되면 재처리. 북마크 **기본값은 비활성**.
- 개명 함정: **Kinesis Data Firehose → Amazon Data Firehose**, **Kinesis Data Analytics → Managed Service for Apache Flink**(SQL 애플리케이션은 단종).

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"Firehose로도 과거 데이터를 다시 읽을 수 있다."** → ❌. Firehose는 전달 서비스로 **Direct PUT 데이터는 장애 시 최대 24시간만 보관**합니다. 재생이 필요하면 KDS(보존 최대 365일)입니다.
   (원리: §1 — 보관·재읽기는 스트림 저장소의 성질이고, Firehose는 그 성질을 버려 소비자 코드를 없앤 서비스다.)
2. **"소비자를 늘리면 처리량도 늘어난다."** → ❌. 공유 처리량 모드에서는 **샤드의 2 MB/s를 소비자들이 나눠 씁니다.** 소비자가 둘 이상이면 EFO가 정답 방향입니다.
   (원리: §2 — 한도는 샤드에 걸리므로 소비자 수를 늘리면 몫이 쪼개진다.)
3. **"동적 파티셔닝과 제로 버퍼링을 같이 쓰면 가장 빠르다."** → ❌. **간격 0은 동적 파티셔닝과 함께 쓸 수 없고**, Parquet 변환·동적 파티셔닝을 켜면 버퍼 크기는 **64~128 MB** 범위가 됩니다.
4. **"DynamoDB Streams의 뷰 타입은 나중에 바꾸면 된다."** → ❌. **설정 후 변경 불가**입니다. 장기 재생·다수 소비자가 필요하면 애초에 **KDS for DynamoDB**를 고릅니다(최대 1년, 단 순서·중복 비보장).
5. **"DMS CDC면 거의 실시간 복제가 보장된다."** → ❌. **지연 SLA가 없습니다.** "실시간 보장" 문구가 붙은 보기는 의심하세요.
6. **"Lambda 소비자는 기본 설정으로도 안전하다."** → ❌. **기본은 재시도·레코드 연령 무제한**이라 불량 레코드 하나가 샤드를 **최대 1주** 막습니다. 재시도 제한 + Bisect + 실패 대상이 한 묶음입니다.
7. **"고정 출구 IP는 `ip-ranges.json`을 상대에게 등록하면 된다."** → ❌. 그건 **AWS 서비스의 공용 범위**입니다. 우리 고정 IP는 **NAT 게이트웨이의 Elastic IP**입니다.
8. **"S3 알림은 SQS FIFO 큐에 바로 붙일 수 있다."** → ❌. 직접 알림은 **Standard 큐만**이고, FIFO는 EventBridge를 경유합니다. 또한 알림은 **순서 비보장·드물게 중복**입니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (문항 뱅크는 `dea-t1-1.questions.json` — 사람 검수 전이라 사이트에는 노출되지 않습니다)

**Q1.** 애플리케이션 로그를 S3 데이터 레이크에 Parquet으로 적재해야 합니다. 소비자 코드와 서버 운영은 최소화하고 싶습니다. 무엇을 고르나요?

<details><summary>정답 보기</summary>

**Amazon Data Firehose.** 버퍼링해 묶어 전달하고, JSON → Parquet 형식 변환과 동적 파티셔닝을 붙일 수 있어 소비자 코드가 필요 없습니다. KDS는 소비자(KCL·Lambda)를 운영해야 하고, MSK는 Kafka 호환 요구가 있을 때, DynamoDB Streams는 DynamoDB 변경 전용입니다.
</details>

**Q2.** 분석 애플리케이션 3개가 같은 스트림을 독립적으로 읽습니다. 소비자를 추가한 뒤 읽기 스로틀과 지연이 생겼습니다. 원인과 처방은?

<details><summary>정답 보기</summary>

원인은 **공유 처리량 모드에서 샤드의 읽기 한도(2 MB/s·초당 5 읽기 트랜잭션)를 소비자들이 나눠 쓰기** 때문입니다. 처방은 **EFO 등록** — 소비자마다 샤드당 전용 2 MB/s를 받고 지연도 통상 70 ms로 낮아집니다.
</details>

**Q3.** Firehose가 S3로 전달하지 못하는 장애가 길어질 때, Direct PUT으로 넣은 데이터는 언제까지 보관되나요? KDS를 소스로 쓴 경우는 어떻게 다른가요?

<details><summary>정답 보기</summary>

**Direct PUT은 최대 24시간**까지 보관되고 그 뒤에는 폐기됩니다. **KDS를 소스로 쓰면 KDS에 설정한 보존 기간(기본 24시간, 최대 365일)까지** 데이터가 스트림에 남아 있어 복구 창이 더 길어집니다.
</details>

**Q4.** Glue 잡 북마크를 켰는데 이미 처리한 S3 파일이 다시 처리됐습니다. 왜일까요?

<details><summary>정답 보기</summary>

S3 소스의 북마크는 **객체의 수정 시각**으로 처리 여부를 판별합니다. 파일을 덮어써서 수정 시각이 바뀌면 같은 파일도 새 데이터로 간주돼 다시 처리됩니다. (JDBC 소스는 순증가하는 기본키를 북마크 키로 씁니다.)
</details>

**Q5.** S3에 파일이 도착하면 처리하되, FIFO 큐와 "객체 크기" 조건 필터가 필요하고 같은 이벤트를 여러 대상에 보내야 합니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**S3 → EventBridge**로 보냅니다. 직접 S3 알림은 알림 설정 하나에 대상 유형 하나이고 **SQS/SNS FIFO를 지원하지 않으며** 고급 필터도 없습니다. EventBridge 규칙은 다중 대상·객체 크기 등 고급 필터·아카이브 재생을 제공합니다.
</details>

---

**Q6 (원리).** 왜 "보존 기간"이 수집 서비스 선택의 결정적 기준이 되나요?

<details><summary>정답 보기</summary>

**보존 기간이 곧 재처리(replayability)의 한계이기 때문입니다.** 소비자 버그를 고친 뒤 과거 데이터를 다시 흘려보낼 수 있는지, 장애가 길어질 때 어디까지 버틸 수 있는지가 모두 보존으로 결정됩니다. 그래서 같은 "스트리밍 수집"이라도 DynamoDB Streams(24시간)·KDS(최대 365일)·Firehose(장애 시 24시간 보관) 중 무엇을 골랐는지에 따라 복구 설계가 달라집니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-19 · 사람 검수 전)

1. Amazon Kinesis Data Streams FAQs — https://aws.amazon.com/kinesis/data-streams/faqs/
2. Quotas and limits (Kinesis Data Streams) — https://docs.aws.amazon.com/streams/latest/dev/service-sizes-and-limits.html
3. Amazon Data Firehose FAQs — https://aws.amazon.com/firehose/faqs/
4. Amazon Data Firehose Quota — https://docs.aws.amazon.com/firehose/latest/dev/limits.html
5. Transform source data in Amazon Data Firehose — https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html
6. Change data capture for DynamoDB Streams — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html
7. Choose the right change data capture strategy for your Amazon DynamoDB applications — https://aws.amazon.com/blogs/database/choose-the-right-change-data-capture-strategy-for-your-amazon-dynamodb-applications/
8. Creating tasks for ongoing replication using AWS DMS — https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Task.CDC.html
9. Tracking processed data using job bookmarks (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
10. Time-based schedules for jobs and crawlers (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/monitor-data-warehouse-schedule.html
11. Schedule types in EventBridge Scheduler — https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html
12. Event notification types and destinations (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html
13. Lambda parameters for Kinesis Data Streams event source mappings — https://docs.aws.amazon.com/lambda/latest/dg/services-kinesis-parameters.html
14. Loading data files (Amazon Redshift best practices) — https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-use-multiple-files.html
15. Using the Amazon Redshift Data API — https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html
16. Flow triggers (Amazon AppFlow) — https://docs.aws.amazon.com/appflow/latest/userguide/flow-triggers.html
17. Enable internet access for VPC-connected Lambda functions — https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc-internet.html
18. DEA-C01 공식 시험 가이드 도메인 1 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
