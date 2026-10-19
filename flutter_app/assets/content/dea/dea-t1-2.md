---
examGuideTaskId: dea-t1-2
certCode: DEA-C01
domain: 1
domainName: 데이터 수집 및 변환
domainWeightPct: 34
title: 데이터 변환 및 처리 (엔진 선택·비용·형식)
coversTasks:
  - "1.2"
sources:
  - title: AWS Glue FAQs (공식)
    url: https://aws.amazon.com/glue/faqs/
  - title: AWS Glue worker types (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/worker-types.html
  - title: Use CTAS and INSERT INTO for ETL and data analysis — Amazon Athena (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/ctas-insert-into-etl.html
  - title: Considerations when using zero-ETL integrations with Amazon Redshift (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/mgmt/zero-etl.reqs-lims.html
  - title: Process multiple prompts with batch inference — Amazon Bedrock (공식 문서)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html
  - title: DEA-C01 공식 시험 가이드 도메인 1 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
lastVerified: 2026-10-19
---

# 데이터 변환 및 처리 (엔진 선택·비용·형식)

> **커버하는 공식 Task** — DEA-C01 · 도메인 1 「데이터 수집 및 변환」(34%) · **Task 1.2 데이터 변환 및 처리** (`dea-t1-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. Task 1.1이 "어떻게 들어오는가"였다면, 1.2는 **"들어온 데이터를 무엇으로 어떻게 바꾸는가"** 입니다.
> 공식 가이드 **v1.1에서 Skill 1.2.10 「데이터 처리를 위한 LLM 통합」이 신규로 추가**됐습니다(§9).

---

## ✅ 학습 목표 체크리스트

- [ ] **변환 엔진 5종**(Glue · EMR · Lambda · Redshift · Athena)을 요구사항으로 골라 그 이유를 말할 수 있다
- [ ] Glue의 **작업 유형·워커 타입·Auto Scaling·Flex**가 각각 무엇을 해결하는지 구분한다
- [ ] EMR의 **배포 옵션 3종**과 Spot·플릿·Managed Scaling 같은 **비용 레버**를 설명한다
- [ ] **CSV → Parquet 변환 수단 4가지**를 상황별로 고른다
- [ ] 여러 소스 통합에서 **제자리 조회(페더레이션·Spectrum) vs 복제(Zero-ETL·AppFlow)** 를 가른다
- [ ] JDBC/ODBC 연결 요건과 **연결 풀링(RDS Proxy)** 을 안다
- [ ] 변환 실패·성능 문제(OOM · 작은 파일 · 데이터 스큐 · 동시 실행 한도)를 **증상에서 원인으로** 추적한다
- [ ] **LLM 통합**(Bedrock Converse/InvokeModel · 배치 추론 · Redshift ML)의 선택 기준을 설명한다

---

## 🎯 왜 중요한가

- 도메인 1(34%) 안에서 1.2는 **"무엇으로 처리할까"** 라는 가장 자주 반복되는 설계 질문입니다. 엔진 선택 문항은 서비스 이름이 아니라 **제약(실행 시간·분산 여부·과금 단위)** 으로 갈립니다.
- 비용 최적화(1.2.4)는 단독 문항으로도 나오고 엔진 선택 문항의 꼬리로도 붙습니다. **DPU-시간·스캔 바이트·Spot·유휴 과금** 같은 과금 축을 알고 있어야 보기가 걸러집니다.
- 트러블슈팅(1.2.7)은 "증상 → 원인" 매핑입니다. 작은 파일, 스큐, OOM은 처방이 각기 달라서 섞으면 틀립니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **DPU** | data processing unit | Glue의 과금·용량 단위. 1 DPU = 4 vCPU·16 GB |
| **ETL / ELT** | — | 밖에서 변환 후 적재 / 먼저 적재하고 웨어하우스 안에서 변환 |
| **컬럼형 형식** | columnar | Parquet·ORC처럼 *열 단위로* 저장해 필요한 컬럼만 읽게 하는 형식 |
| **푸시다운** | pushdown | 필터·연산을 *데이터가 있는 쪽으로* 내려보내 전송량을 줄이는 기법 |
| **데이터 스큐** | data skew | 일부 파티션에 데이터가 쏠려 *특정 태스크만* 오래 걸리는 현상 |
| **OOM** | out of memory | 실행기 메모리가 부족해 작업이 실패하는 것 |
| **Zero-ETL** | — | 파이프라인을 직접 만들지 않고 소스→Redshift 복제를 AWS가 관리하는 통합 |
| **멀티플렉싱** | multiplexing | 여러 클라이언트 연결을 *트랜잭션 단위로* DB 연결 하나에 태우는 것 |

---

## 📖 핵심 개념

### 1) 변환 엔진 선택 {#engine-choice}

| 엔진 | 이럴 때 고른다 | 제약·과금 | 시험 단서 |
|---|---|---|---|
| **Glue Spark ETL** | 서버 관리 없이 Spark로 스케일아웃하는 배치 ETL | Spark 기반(Spark 밖 도구는 EMR) · **DPU-시간 초 단위**(2.0 이상 최소 1분) | "서버리스 ETL", "Spark" |
| **Glue Python shell** | 단일 머신에서 돌리는 기본 스크립트, **약 10 GB까지** | 분산 처리가 아님 | "작은 데이터", "간단한 스크립트" |
| **Glue Streaming** | 스트림 마이크로배치 변환(**exactly-once**) | 저용량 스트리밍용 G.025X 워커 | "스트리밍 ETL" |
| **EMR** | Hadoop 환경 **직접 접근** — Spark 밖 도구, 세밀한 구성 | 클러스터 운영(배포 옵션은 §3) | "Spark 외 도구", "커스텀 구성" |
| **Lambda** | 이벤트로 트리거되는 짧은 변환 | **함수당 900초**, 메모리 128~10,240 MB | "15분 이내", "이벤트 기반" |
| **Redshift (ELT)** | 이미 적재된 데이터를 SQL로 변환 | **Python UDF는 2026-06-30 이후 지원 중단** | "적재 후 변환" |
| **Athena** | S3 데이터를 SQL로 변환(CTAS·INSERT INTO·UNLOAD) | 매우 큰 ETL은 EMR/Glue 권장 · **스캔 바이트 과금** | "SQL만으로", "형식 변환" |

> 공식 문서의 기준은 단순합니다. **배치 ETL = Glue 또는 EMR**, 그 둘의 차이는 "서버리스 Spark(Glue) vs 하위 수준 접근과 유연성(EMR)". ETL이 아닌 일반 배치는 **AWS Batch**가 더 맞을 수 있습니다.

> 🧠 원리: 왜 "900초"가 Lambda를 변환 엔진에서 탈락시키는 결정적 숫자일까요?
> Lambda는 요청 단위로 수명이 끝나는 실행 모델이라 함수당 최대 실행 시간이 15분으로 고정돼 있습니다.
> 대용량 변환은 데이터량에 따라 실행 시간이 선형으로 늘어나므로, 데이터가 커지면 언젠가 반드시 이 벽에 부딪힙니다.
> 그래서 공식 문서도 더 긴 작업은 EC2·EKS·ECS를 쓰거나 Step Functions로 쪼개라고 안내합니다 — 시험에서 "처리 시간이 늘어나는 추세"라는 문장은 Lambda 보기를 지우라는 신호입니다.

### 2) Glue 운영 레버 — 작업 유형·버전·워커·스케일링 {#glue-levers}

- **버전**: 최신은 **Glue 6.0**(Spark 4.1.1·Python 3.13)이고, 버전을 지정하지 않고 만든 잡은 **5.1**로 생성됩니다. **Glue 1.0·2.0은 2026-04-01에 수명 종료**됐고, **Glue for Ray는 2026-04-30부터 신규 고객에게 닫혔습니다**(대안: EKS + KubeRay).
- **워커 타입**: 대부분 **G.1X·G.2X**로 시작합니다. 메모리 부족(OOM)이 잦으면 같은 크기 대비 **메모리가 2배인 R 워커**를 씁니다. G.12X·G.16X·R 워커는 시작 지연이 있을 수 있습니다.
- **Auto Scaling**(Glue 3.0+): 최대 워커 수만 정하면 Glue가 워커를 자동으로 늘리고 줄입니다 — **부하가 변동하는 잡**의 비용을 낮춥니다.
- **Flex 실행 클래스**(Glue 3.0+ Spark 잡): 시작·완료 시각이 달라도 되는 **시간 비민감 잡에서 최대 35% 절감**. 긴급한 잡에는 쓰지 않습니다.
- **타임아웃**: 비워 두면 Glue 4.0 이하 **2,880분**, 5.0 이상 **480분**이 기본입니다.
- **동시 실행**: `MaxConcurrentRuns` 기본값은 **1**이라 초과 호출은 `ConcurrentRunsExceededException`으로 실패합니다. **잡 큐잉**을 켜면 즉시 실패 대신 Waiting 상태로 재시도합니다(최대 15분·10회).

### 3) EMR 배포 옵션과 비용 레버 {#emr-options}

| 옵션 | 이럴 때 | 특징 |
|---|---|---|
| **EMR on EC2** | 구성에 대한 최대 통제·유연성 | 클러스터를 직접 운영. Spot·인스턴스 플릿·Managed Scaling으로 비용 조절 |
| **EMR on EKS** | 이미 EKS를 운영, 한 클러스터에서 **여러 Spark 버전** | 클러스터 프로비저닝 없이 작업 제출, 자원 활용률 상승 |
| **EMR Serverless** | 클러스터를 관리하고 싶지 않을 때 | 자동 확장·쓴 만큼 과금. **사전 초기화 워커는 유휴에도 과금** |

- **core vs task 노드**: core 노드는 **HDFS를 보유**하므로 On-Demand로 두고, **Spot은 task 노드**에 씁니다. core를 Spot으로 두면 노드 회수 시 성능 저하·데이터 손실이 생깁니다.
- **인스턴스 플릿**: 기본은 플릿당 인스턴스 타입 5개, **할당 전략을 쓰면 30개**까지 — 더 빠른 프로비저닝과 적은 Spot 중단을 위해 할당 전략이 권장됩니다.
- **Managed Scaling**: 최소·최대 용량을 정하면 클러스터 크기를 자동 조절하고, core 상한·On-Demand 상한으로 배분을 제어합니다.
- **Graviton**: Spark에서 이전 세대 대비 **최대 30% 비용 절감**과 성능 향상.

### 4) 비용 최적화 — 축이 몇 개뿐이다 {#cost-levers}

- **얼마나 큰 자원을, 얼마나 오래, 어떤 구매 방식으로** — Glue 워커/Auto Scaling/Flex, EMR Spot/플릿/Managed Scaling, Lambda 메모리.
- **얼마나 적게 읽는가** — Athena·Spectrum은 **스캔한 바이트로 과금**(최소 10 MB)되므로, **압축·파티셔닝·컬럼형 변환으로 쿼리당 비용을 30~90%** 줄입니다. 파일은 **대략 128 MB를 넘거나 분할 가능**해야 효율적이고, 텍스트는 **BZIP2·LZO만 분할 가능**합니다.
- **Lambda**: CPU가 메모리에 비례하므로 메모리가 성능의 핵심 레버입니다. 기본값이자 최저값인 **128 MB**는 단순 라우팅·변환에만 권장됩니다. 적정값은 **Lambda Power Tuning**이나 **Compute Optimizer**(x86_64 함수만)로 찾습니다.
- **Athena 커넥터**: Lambda 기반 페더레이션 커넥터는 **내 계정의 Lambda 요금이 따로** 붙습니다.

### 5) 형식 변환 — CSV에서 Parquet로 {#format-conversion}

| 수단 | 특징 | 주의 |
|---|---|---|
| **Athena CTAS** | 한 문장에서 파티셔닝·압축·컬럼형 변환, 결과 테이블·파티션이 **Glue 카탈로그에 자동 등록** | **쿼리당 파티션 100개 한도** → 초과분은 INSERT INTO로 나눠 실행 |
| **Athena INSERT INTO** | 기존 대상 테이블에 변환 결과를 추가 | 같은 100 파티션 한도 |
| **Athena UNLOAD** | 테이블을 만들지 않고 **파일만** 출력(Parquet·JSON 등) | 테이블 메타데이터가 필요하면 CTAS |
| **Firehose 형식 변환** | 스트림 적재 시점에 JSON → Parquet/ORC | **입력은 JSON만** (CSV는 Lambda로 선변환) · Glue 카탈로그 스키마 필요 |
| **Glue/EMR Spark 잡** | 이미 쌓인 대량 S3 데이터의 일괄 변환 | 분산 처리 필요 시 기본 선택 |

> 컬럼형으로 바꾸면 Athena가 **필요한 컬럼만** 읽어 스캔량과 비용이 줄어듭니다. 반대로 읽기보다 쓰기가 빈번한 워크로드는 행 기반(Avro)이 유리합니다.

### 6) 여러 소스 통합 — 옮길까, 제자리에서 볼까 {#integration}

| 방식 | 성격 | 제약 |
|---|---|---|
| **Athena Federated Query** | S3 외 소스를 **제자리 조회**(커넥터가 병렬성·필터 푸시다운 관리) | 커넥터 Lambda 요금 별도 |
| **Redshift Federated Query** | RDS/Aurora(PostgreSQL·MySQL) **라이브 데이터**를 Redshift 쿼리에 결합 | 일부 연산을 원격 DB로 푸시다운 |
| **Redshift Spectrum** | S3 데이터를 Redshift에서 쿼리 | 스캔 바이트 과금 |
| **Zero-ETL** | 소스 → Redshift **복제를 AWS가 관리** | **소스 테이블에 기본 키 필수**, 애플리케이션 소스는 **최소 지연 1시간**, 값이 **VARCHAR 65,535바이트** 초과 시 해당 테이블 실패(`TRUNCATECOLUMNS`로 잘라내기) |
| **AppFlow** | SaaS ↔ AWS 서비스, **코드 없이** | — |
| **Glue ETL(DynamicFrame)** | 여러 소스를 읽어 조인·정제, **스키마 불일치 해소** | 불일치는 choice 타입 → `resolveChoice` |

> **DynamicFrame vs DataFrame**: DataFrame은 스키마를 먼저 지정해야 하지만, DynamicFrame은 레코드가 **자기기술적**이라 스키마가 없어도 됩니다. 같은 필드의 타입이 레코드마다 다르면 choice(union) 타입으로 들고 있다가 `resolveChoice`로 고정 스키마에 맞춥니다.

### 7) 연결 — JDBC·ODBC·풀링 {#connections}

- **Glue → VPC 안의 JDBC**: Glue가 내 계정에 **ENI**를 만들어 접속합니다. 보안 그룹에 **모든 TCP 포트에 대한 자기참조 인바운드 규칙**이 필요하고, ENI에는 퍼블릭 IP가 없어 인터넷·VPC 엔드포인트 없는 AWS 서비스 접근에는 **NAT**가 필요합니다(인터넷 게이트웨이를 서브넷 라우트로 직접 쓸 수 없음).
- **JDBC 병렬 읽기(Glue)**: `hashfield`(고르게 분포한 컬럼) 또는 `hashexpression`(정수 반환 SQL 식)으로 논리 파티션을 나누고 `hashpartitions`로 병렬 쿼리 수를 정합니다. **미지정 기본값은 7**이며, 이 속성은 **Redshift·S3 테이블에서는 무시**됩니다.
- **Athena ODBC(1.x)**: 결과 스트리밍 **포트 444 아웃바운드**가 열려야 하고, IAM 주체에 **`athena:GetQueryResultsStream`** 권한이 필요합니다(일반 쿼리 API로는 노출되지 않는 권한).
- **연결 풀링(RDS Proxy)**: 연결 개설·종료 오버헤드를 줄이고, **멀티플렉싱**으로 트랜잭션 단위 재사용을 해 클라이언트가 많은 연결을 열어도 DB 쪽 연결 수는 적게 유지합니다.

### 8) 변환 실패·성능 디버깅 — 증상에서 원인으로 {#troubleshooting}

| 증상 | 원인 | 처방 |
|---|---|---|
| 태스크가 **수백만 개**, 실행이 비정상적으로 느림 | 작은 파일 폭증 | **파일 그룹화**(Glue `groupFiles`) · 입력 파일 5만 개 초과 시 Glue가 자동 적용 |
| **일부 파티션만** 오래 걸림 | 데이터 스큐 | AQE·솔팅·브로드캐스트 조인 |
| 캐싱·셔플·집계에서 **OOM** | 실행기 메모리 부족 | **R 워커**(메모리 2배) 또는 파티션 조정 |
| `ConcurrentRunsExceededException` | `MaxConcurrentRuns` 기본 1 초과 | 한도 상향 또는 **잡 큐잉** |
| 실패 원인·줄 번호를 모른다 | 로깅 부족 | **Job run insights**(실패 줄 번호·근본 원인 요약) · Glue 5.0+는 실시간 로깅 기본 |

### 9) LLM 통합 — v1.1 신규 Skill 1.2.10 {#llm}

데이터 처리 파이프라인에 **대규모 언어 모델**을 붙이는 방식과 선택 기준입니다.

- **호출 API**: **Converse**는 모델과 무관한 **일관된 인터페이스**라 모델 교체가 쉽습니다. **InvokeModel**은 모델 고유 형식을 쓰며, 배치에서 tool calling이 필요한 경우가 여기에 해당합니다.
- **추론 방식**: **On-Demand**(토큰 과금) · **배치 추론**(비동기, **On-Demand 대비 50% 낮은 가격**, 프로비저닝 모델 미지원) · **Provisioned Throughput**(시간당 과금·1·6개월 약정, 커스텀 모델에 필수).
- **문서·이미지 추출**: **Bedrock Data Automation(BDA)** 이 문서·이미지·오디오·비디오에서 표준/커스텀(blueprint) 출력으로 필드를 추출합니다.
- **파이프라인에 넣는 위치**: **Redshift ML 외부 모델**(SQL 함수로 호출) · **Step Functions**(워크플로 태스크로 호출) · **Lambda**(함수 코드에서 호출).

> 시험 단서: "**지연을 감수하고 대량**" → 배치 추론. "**모델을 바꿔 끼울 수 있게**" → Converse. "**PDF·이미지에서 필드 추출**" → BDA. "**SQL에서 LLM 호출**" → Redshift ML.

### 10) 데이터 API 만들기와 볼륨·속도·다양성 {#data-apis}

- **데이터 API 만들기(1.2.8)**: Redshift **Data API**는 비동기로 SQL을 실행하고 쿼리 ID로 결과를 받아, Lambda를 VPC에 넣지 않고도 호출할 수 있습니다. 외부에 노출할 때는 **API Gateway 동기 통합 타임아웃 기본 29초**를 넘기지 않도록 **비동기 시작 + 폴링** 구조로 만듭니다(Lambda 자체는 900초).
- **볼륨·속도·다양성(1.2.9)**: **정형**은 미리 정의된 스키마(웨어하우스), **비정형**은 정해진 데이터 모델이 없음(문서·이미지), **반정형**은 JSON·XML처럼 자기기술 요소를 가집니다(Redshift는 SUPER 타입으로 질의).

---

## ✍️ 시험 포인트

- "서버 관리 없이 Spark ETL" → **Glue**. "Spark 밖 도구·세밀한 구성" → **EMR**. "15분 이내 이벤트 변환" → **Lambda**. "적재 후 SQL 변환" → **Redshift ELT**. "SQL로 S3 형식 변환" → **Athena CTAS**.
- 비용 보기를 가르는 숫자: Glue **1 DPU = 4 vCPU·16 GB**, Flex **최대 35% 절감**, Graviton **최대 30% 절감**, Athena 스캔 **최소 10 MB**·압축/파티셔닝으로 **30~90% 절감**, Lambda 기본 메모리 **128 MB**.
- "지연 허용 비긴급 잡" → **Flex**. "부하 변동" → **Auto Scaling**. 둘을 섞지 마세요.
- "Spot을 어디에" → **task 노드만**. core는 HDFS 때문에 On-Demand.
- "파티션이 100개를 넘어 실패" → CTAS 후 **INSERT INTO 분할**.
- Zero-ETL 탈락 조건: **기본 키 없는 소스 테이블**, **SaaS 소스에 분 단위 지연 요구**.
- "ODBC 드라이버가 결과를 못 받음" → **포트 444**와 **GetQueryResultsStream** 권한.
- "API가 타임아웃" → API Gateway **29초** 벽 → 비동기 + 폴링.
- 버전 함정: Glue **1.0·2.0 종료(2026-04-01)**, **Ray 신규 중단(2026-04-30)**, Redshift **Python UDF 2026-06-30 이후 중단**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"Glue와 EMR은 사실상 같다."** → ❌. Glue는 **Spark 위 서버리스**, EMR은 **Hadoop 환경 직접 접근**으로 Spark 밖 도구까지 씁니다. "하위 수준 접근·유연성" 문장은 EMR 신호입니다.
2. **"Flex를 켜면 모든 잡이 싸진다."** → ❌. Flex는 **시간 비민감 잡 전용**(Glue 3.0+ Spark)입니다. 시작·완료 시각이 보장되지 않습니다.
3. **"EMR 비용은 Spot을 다 쓰면 최소다."** → ❌. **core 노드를 Spot으로 두면 HDFS 데이터 손실 위험**이 있습니다. Spot은 task 노드에.
4. **"EMR Serverless는 안 쓰면 공짜다."** → ⚠️ 기본은 쓴 만큼이지만 **사전 초기화 워커는 유휴에도 과금**됩니다.
5. **"Firehose로 CSV를 Parquet으로 바꾸면 된다."** → ❌. Firehose 형식 변환의 **입력은 JSON만**입니다. CSV는 Lambda로 JSON으로 먼저 바꿔야 하고, Glue 카탈로그 스키마도 필요합니다.
6. **"CTAS면 파티션을 몇 개든 만들 수 있다."** → ❌. **쿼리당 100 파티션** 한도가 있어 `HIVE_TOO_MANY_OPEN_PARTITIONS`를 만납니다 — CTAS 후 INSERT INTO로 나눕니다.
7. **"Zero-ETL이면 모든 테이블이 자동 복제된다."** → ❌. **기본 키가 없는 테이블은 제외**되고, 값이 **VARCHAR 65,535바이트**를 넘으면 그 테이블이 실패 상태가 됩니다.
8. **"작은 파일이 많아 느리니 R 워커로 올리자."** → ❌. 작은 파일은 **그룹화**, 메모리 집약 OOM이 **R 워커**입니다. 증상과 처방을 맞추세요.
9. **"배치 추론은 프로비저닝 모델에도 쓸 수 있다."** → ❌. 배치 추론은 **프로비저닝 모델을 지원하지 않습니다**(대신 On-Demand 대비 50% 저렴).
10. **"Glue JDBC 병렬 읽기는 어떤 테이블에서도 동작한다."** → ❌. `hashfield`/`hashexpression` 설정은 **Redshift·S3 테이블에서는 무시**됩니다.

---

## 🧪 자가 점검

> 학습용 자가 점검입니다. (문항 뱅크 `dea-t1-2.questions.json` — 사람 검수 전이라 사이트 비노출)

**Q1.** 수 TB 규모 S3 데이터를 Spark로 정제해야 하는데, 클러스터 운영은 하고 싶지 않고 Spark 외 도구도 필요 없습니다. 무엇을 고르나요?

<details><summary>정답 보기</summary>

**AWS Glue(Spark ETL 잡).** 서버리스 Spark 환경에서 워커를 늘려 스케일아웃합니다. Spark 밖 도구나 Hadoop 환경에 대한 하위 수준 접근이 필요할 때가 EMR이고, Lambda는 함수당 900초 제약으로 TB급 변환에 맞지 않습니다.
</details>

**Q2.** 매일 새벽에 도는 리포트 생성 Glue 잡이 있습니다. 완료 시각이 한두 시간 늦어도 괜찮습니다. 비용을 줄이는 설정은?

<details><summary>정답 보기</summary>

**Flex 실행 클래스**(Glue 3.0+ Spark 잡, 최대 35% 절감). 시간 비민감 잡 전용이라 이 시나리오에 정확히 맞습니다. 부하 변동이 문제라면 Auto Scaling이지만, 여기서는 "지연 허용"이 단서입니다.
</details>

**Q3.** Athena CTAS로 날짜별 파티션 300개를 한 번에 만들려다 실패했습니다. 왜이고 어떻게 하나요?

<details><summary>정답 보기</summary>

CTAS·INSERT INTO는 **쿼리당 100 파티션 한도**가 있습니다. 먼저 CTAS로 100개까지 만들고, 남은 파티션은 **INSERT INTO를 여러 번 나눠 실행**해 채웁니다.
</details>

**Q4.** Aurora MySQL의 운영 데이터를 파이프라인 구축·운영 없이 Redshift에서 분석하려 합니다. Zero-ETL 통합을 검토할 때 먼저 확인할 제약은?

<details><summary>정답 보기</summary>

**소스 테이블에 기본 키가 있는지**입니다. 기본 키가 필수이며, 애플리케이션(SaaS) 소스는 최소 지연이 1시간, 값이 Redshift VARCHAR 한도(65,535바이트)를 넘으면 해당 테이블이 실패 상태가 됩니다.
</details>

**Q5.** Glue 잡이 수백만 개의 작은 JSON 파일을 읽으며 태스크 수가 폭증했습니다. 처방은?

<details><summary>정답 보기</summary>

**입력 파일 그룹화**(`groupFiles`)로 여러 파일을 한 태스크가 묶어 읽게 합니다. 입력 파일이 5만 개를 넘으면 Glue가 자동으로 그룹화를 켭니다. 메모리 집약 연산에서의 OOM이라면 그때 R 워커(메모리 2배)를 검토합니다.
</details>

---

**Q6 (원리).** 왜 Athena·Redshift Spectrum에서는 "파일을 어떻게 저장했는가"가 곧 비용이 되나요?

<details><summary>정답 보기</summary>

**과금 단위가 스캔한 바이트이기 때문입니다.** 컬럼형(Parquet/ORC)으로 저장하면 쿼리가 필요한 컬럼만 읽고, 파티셔닝하면 필요한 파티션만 읽으며, 압축하면 같은 데이터의 바이트 수가 줄어듭니다. 세 조치가 모두 "읽는 바이트"를 직접 줄이므로 공식 문서가 쿼리당 30~90% 절감을 말할 수 있는 것입니다. 반대로 분할 불가능한 gzip 단일 대용량 파일은 병렬 읽기까지 막아 성능과 비용을 함께 악화시킵니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-19 · 사람 검수 전)

1. AWS Glue FAQs — https://aws.amazon.com/glue/faqs/
2. AWS Glue versions — https://docs.aws.amazon.com/glue/latest/dg/release-notes.html
3. AWS Glue for Ray end of support — https://docs.aws.amazon.com/glue/latest/dg/awsglue-ray-jobs-availability-change.html
4. AWS Glue worker types — https://docs.aws.amazon.com/glue/latest/dg/worker-types.html
5. CreateJob (AWS Glue Web API Reference) — https://docs.aws.amazon.com/glue/latest/webapi/API_CreateJob.html
6. Introducing AWS Glue Auto Scaling — https://aws.amazon.com/blogs/big-data/introducing-aws-glue-auto-scaling-automatically-resize-serverless-computing-resources-for-lower-cost-with-optimized-apache-spark/
7. Reading input files in larger groups (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/grouping-input-files.html
8. Reading from JDBC tables in parallel (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/run-jdbc-parallel-read-job.html
9. Connecting to a JDBC data store in a VPC (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/connection-JDBC-VPC.html
10. DynamicFrame class (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-pyspark-extensions-dynamic-frame.html
11. Monitoring with AWS Glue job run insights — https://docs.aws.amazon.com/glue/latest/dg/monitor-job-insights.html
12. Planning and configuring instance fleets (Amazon EMR) — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-instance-fleet.html
13. Introducing Amazon EMR Managed Scaling — https://aws.amazon.com/blogs/big-data/introducing-amazon-emr-managed-scaling-automatically-resize-clusters-to-lower-cost/
14. Pre-initialized capacity in EMR Serverless — https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/pre-init-capacity.html
15. Cost optimization in analytics services (Cost Modeling Data Lakes) — https://docs.aws.amazon.com/whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html
16. Amazon Athena (Big Data Analytics Options on AWS) — https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/amazon-athena.html
17. Use CTAS and INSERT INTO for ETL and data analysis (Athena) — https://docs.aws.amazon.com/athena/latest/ug/ctas-insert-into-etl.html
18. Use CTAS and INSERT INTO to work around the 100 partition limit — https://docs.aws.amazon.com/athena/latest/ug/ctas-insert-into.html
19. Convert input data format in Amazon Data Firehose — https://docs.aws.amazon.com/firehose/latest/dev/record-format-conversion.html
20. Considerations when using zero-ETL integrations with Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/mgmt/zero-etl.reqs-lims.html
21. Use Amazon Athena Federated Query — https://docs.aws.amazon.com/athena/latest/ug/federated-queries.html
22. Querying data with federated queries in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/federated-overview.html
23. Configure Lambda function memory — https://docs.aws.amazon.com/lambda/latest/dg/configuration-memory.html
24. Process multiple prompts with batch inference (Amazon Bedrock) — https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html
25. Converse (Amazon Bedrock API Reference) — https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
26. Using the Amazon Redshift Data API — https://docs.aws.amazon.com/redshift/latest/mgmt/data-api.html
27. Integration timeout (Amazon API Gateway) — https://docs.aws.amazon.com/help-panel/apigateway/latest/console/rest-timeout.html
28. DEA-C01 공식 시험 가이드 도메인 1 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html
