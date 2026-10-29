---
examGuideTaskId: dea-t2-2
certCode: DEA-C01
domain: 2
domainName: 데이터 스토어 관리
domainWeightPct: 26
title: 데이터 카탈로그 시스템 (Glue Data Catalog·크롤러·파티션·SageMaker Catalog)
coversTasks:
  - "2.2"
sources:
  - title: AWS Glue concepts (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/components-key-concepts.html
  - title: Supported data sources for crawling (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/crawler-data-stores.html
  - title: Preventing a crawler from changing an existing schema (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/crawler-schema-changes-prevent.html
  - title: Use partition projection with Amazon Athena (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html
  - title: Creating partition indexes (AWS Glue) (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/partition-indexes.html
  - title: Amazon SageMaker Unified Studio terminology and concepts (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/concepts.html
  - title: DEA-C01 공식 시험 가이드 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
lastVerified: 2026-10-20
---

# 데이터 카탈로그 시스템 (Glue Data Catalog·크롤러·파티션·SageMaker Catalog)

> **커버하는 공식 Task** — DEA-C01 · 도메인 2 「데이터 스토어 관리」(26%) · **Task 2.2 데이터 카탈로그 시스템 이해** (`dea-t2-2`)
> 카탈로그는 **데이터를 담는 곳이 아니라 "어디에 무엇이 있는지"를 담는 곳**입니다. 이 구분이 Task 2.2 문항의 절반을 가릅니다.
> **Skill 2.2.6(비즈니스 데이터 카탈로그)은 v1.1 신규**, **2.2.2는 v1.1 개정**("data catalog" → "**technical** data catalog")입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.2의 Skill 항목)

- [ ] Glue Data Catalog의 **구조(데이터베이스·테이블·파티션·연결)** 와 **엔진별 소비 방식**(Athena·Spectrum·EMR·Glue ETL)을 말할 수 있다
- [ ] **Hive 메타스토어 호환**과 외부 Hive 메타스토어 연동 방식을 구분한다
- [ ] 크롤러의 **분류자 우선순위·스키마 감지·지원 스토어**를 안다
- [ ] **스키마 변경 정책**(갱신 / 새 컬럼만 / 무시)과 **재크롤 모드**(전체 / 증분 / S3 이벤트)를 요구사항으로 고른다
- [ ] 크롤러가 **언제 파티션을 만들고 언제 테이블을 여러 개 만드는지** 설명한다
- [ ] **파티션 동기화 수단 6가지**를 구분하고, **파티션 프로젝션과 파티션 인덱스의 차이**를 말할 수 있다
- [ ] Glue **연결(Connection)** 의 유형과 VPC 네트워킹 요건을 안다
- [ ] **기술 카탈로그(Glue) vs 비즈니스 카탈로그(SageMaker Catalog)** 를 시나리오로 구분한다

---

## 🎯 왜 중요한가

- 카탈로그는 도메인 2의 **"접착제"** 입니다. Task 2.1에서 고른 저장소, 2.3의 수명 주기, 2.4의 스키마 진화가 전부 카탈로그를 거쳐 쿼리 엔진에 닿습니다.
- 실무에서 가장 자주 나는 사고가 그대로 출제됩니다 — **"S3에 파일은 있는데 Athena에 안 보인다"(파티션 미등록)**, **"ETL로 고친 스키마를 크롤러가 덮어썼다"(스키마 변경 정책)**, **"재크롤이 너무 느리고 비싸다"(재크롤 모드)**.
- v1.1에서 **비즈니스 데이터 카탈로그(2.2.6)가 신설**되면서, 같은 "카탈로그"라는 단어가 **기술 메타데이터**와 **거버넌스·구독 승인**이라는 두 뜻으로 갈라졌습니다. 문항은 이 둘을 섞어 냅니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **메타데이터** | metadata | 데이터 자체가 아니라 데이터에 관한 정보(컬럼 이름·타입·위치) |
| **메타스토어** | metastore | 테이블 정의를 담는 저장소. Hive 생태계의 표준 구성 요소 |
| **분류자** | classifier | 크롤러가 파일 형식·스키마를 추론할 때 쓰는 규칙(내장 또는 사용자 정의) |
| **파티션** | partition | 테이블을 키=값 폴더로 쪼갠 단위. 필터로 읽을 범위를 줄인다 |
| **Hive 스타일 파티션** | Hive-style partitioning | 경로가 `year=2026/month=10` 처럼 키=값 쌍으로 된 방식 |
| **파티션 프로젝션** | partition projection | 카탈로그를 조회하지 않고 설정 규칙으로 파티션을 계산하는 Athena 기능 |
| **파티션 인덱스** | partition index | 카탈로그에 등록된 파티션의 조회를 가속하는 Glue 기능 |
| **연결** | connection | 자격 증명·URL·VPC 정보를 담은 Data Catalog 객체 |
| **도메인 / 프로젝트** | domain / project | SageMaker Unified Studio의 범위 단위 — 발견 범위는 도메인, 소유 단위는 프로젝트 |
| **구독 요청** | subscription request | 다른 프로젝트의 자산을 쓰게 해 달라고 요청하고 승인받는 절차 |

---

## 📖 핵심 개념

### 1) Glue Data Catalog의 구조와 소비 방식 {#catalog-structure}

AWS Glue Data Catalog는 테이블 정의·잡 정의 같은 제어 정보를 담는 **영속 메타데이터 저장소**이며 **계정당 리전마다 하나**입니다. 가격 페이지는 이를 모든 데이터 자산의 **"기술(technical) 메타데이터" 저장소**라고 부릅니다 — v1.1에서 Skill 2.2.2 문구가 "technical data catalog"로 바뀐 배경입니다.

- **구조** — **데이터베이스**는 연관된 테이블 정의를 묶은 논리 그룹이고, **테이블**은 컬럼 이름·타입·파티션 정보 같은 메타데이터 정의입니다. **둘 다 메타데이터일 뿐 실제 데이터는 원래 저장소(S3 객체, RDS 테이블)에 그대로 남습니다.**
- **함께 관리되는 객체** — 파티션·테이블 버전·파티션 인덱스는 **과금 대상 메타데이터 객체**이고, **연결(Connection)도 Data Catalog 객체**입니다.
- **스키마 버전** — `UpdateTable`은 기본으로 **갱신 전 테이블의 아카이브 버전**을 만듭니다.

| 소비 엔진 | 카탈로그 연결 방식 | 제약 | 시험 단서 |
|---|---|---|---|
| **Amazon Athena** | S3 데이터의 DB·테이블 스키마를 Glue Data Catalog에 저장. 스키마는 **크롤러 또는 DDL(`CREATE TABLE`)** 로 만듦 | 외부 Hive 메타스토어는 **Lambda 커넥터가 따로 필요** | "Athena로 S3 쿼리", "스키마 자동 추론" |
| **Redshift Spectrum** | `CREATE EXTERNAL SCHEMA`로 **외부 데이터 카탈로그의 외부 DB**를 참조. 카탈로그·S3 접근용 **IAM 역할 ARN** 지정 | 외부 DB는 Athena·Glue Data Catalog·**Hive 메타스토어(예: EMR)** 중 어디든 가능 | "Redshift에서 S3 직접 쿼리" |
| **Amazon EMR (Hive)** | Glue Data Catalog를 **Hive 메타스토어로 지정**(EMR **5.8.0 이상**). 다른 계정 카탈로그는 EMR **5.16.0 이상** | **Hive 트랜잭션·테이블 이름 변경 미지원** | "클러스터 간 공유 영속 메타스토어" |
| **AWS Glue ETL** | 카탈로그 테이블이 잡의 **소스·타깃** | 잡이 쓰면서 카탈로그를 갱신하는 옵션은 §6 참조 | "ETL 잡이 카탈로그 테이블 참조" |

> ⚠️ EMR 함정: **`LOCATION` 없이 Hive 테이블을 만들면 기본 위치가 HDFS**입니다. HDFS는 임시 저장소라 **클러스터가 종료되면 데이터가 사라집니다.** 문서는 S3 `LOCATION` 지정을 권고합니다.

### 2) Hive 메타스토어 호환과 외부 메타스토어 {#hive-metastore}

- Data Catalog는 **Apache Hive 메타스토어와 호환되는 애플리케이션**과 통합됩니다.
- **이미 쓰는 외부 Hive 메타스토어를 유지**하려면: Athena는 "S3 - Apache Hive metastore" 데이터 소스를 만들고 **Lambda 함수를 만들어 구성**해야 합니다. Redshift Spectrum 외부 스키마는 **Hive 메타스토어(예: EMR)의 외부 DB도 참조**할 수 있습니다.
- **크롤러가 크롤할 수 있는 데이터 스토어 목록에 Hive 메타스토어는 없습니다.** "크롤러로 Hive 메타스토어를 가져온다"는 보기는 오답 방향입니다.

### 3) 크롤러 — 분류자·스키마 감지·지원 스토어 {#crawler-basics}

크롤러는 데이터 스토어에 연결해 **우선순위가 매겨진 분류자 목록**을 거치며 스키마를 결정하고 Data Catalog에 메타데이터 테이블을 만드는 프로그램입니다.

- **분류자 순서** — **사용자 정의(custom) 분류자를 지정한 순서대로 먼저** 호출하고, 필요하면 내장 분류자를 호출합니다. **certainty=1.0을 반환한 분류자의 결과**를 쓰고, 없으면 **가장 높은 certainty**를, **0.0을 넘는 것이 없으면 `UNKNOWN`** 을 씁니다. 사용자 정의 분류자는 grok 패턴이나 XML row 태그 등으로 정의합니다.
- **지원 데이터 스토어** — 네이티브 클라이언트(**S3·DynamoDB·Delta Lake·Iceberg·Hudi**), **JDBC**(Redshift·Snowflake·RDS 안팎의 Aurora·MariaDB·SQL Server·MySQL·Oracle·PostgreSQL), **MongoDB 클라이언트**(MongoDB·Atlas·DocumentDB). **데이터 스트림용 크롤러는 없습니다** — 스트리밍 소스는 **테이블을 직접 정의하고 스트림 속성을 지정**합니다.
- **연결 요건** — **JDBC·MongoDB·DocumentDB는 연결이 필수**이고, **S3는 Network 유형 연결을 선택적으로** 지정합니다.
- **스키마 감지(샘플링)** — 첫 실행에서 파일마다 **처음 1,000 레코드 또는 첫 1 MB**를 읽어 스키마를 추정하고, 추정하지 못하면 **1 MB씩 늘려 최대 10 MB**까지 읽습니다. S3 대상에 `SampleSize`(1~249)를 주면 리프 폴더당 일부 파일만 크롤합니다(미지정이면 전부).
- **실행** — 수동(온디맨드) 또는 **cron 스케줄(UTC, 최소 5분)**. 비용은 **DPU-hour 단가로 초 단위 과금**입니다.

### 4) 스키마 변경 정책과 재크롤 모드 {#crawler-policy}

**기본 동작은 크롤러가 카탈로그 스키마를 크롤 대상에 맞게 갱신하는 것**입니다. 바꾸지 않으려면 두 가지 선택지가 있습니다.

| 원하는 것 | 콘솔 선택 | API 표현 |
|---|---|---|
| 기존 정의 유지 + **새 컬럼만 추가** | "Add new columns only" | `Tables.AddOrUpdateBehavior=MergeNewColumns` |
| 스키마 **완전 고정**(새 컬럼도 추가 안 함) | "Ignore the change and don't update the table…" | `UpdateBehavior=LOG` |
| 삭제된 객체 처리 | — | `DeleteBehavior` = `LOG` / `DELETE_FROM_DATABASE` / `DEPRECATE_IN_DATABASE` |
| 파티션 스키마를 테이블에서 상속 | "Update all new and existing partitions with metadata from the table" | `Partitions.AddOrUpdateBehavior=InheritFromTable` |

> ⚠️ **이 정책은 이미 존재하는 테이블에서 감지한 변경에만 적용됩니다. 신규 테이블·파티션은 정책과 상관없이 항상 생성됩니다.** "정책을 LOG로 했는데 새 파티션이 추가됐다"는 버그가 아닙니다.

| 재크롤 모드 | 동작 | 제약 | 시험 단서 |
|---|---|---|---|
| **전체**(`CRAWL_EVERYTHING`) | 매 실행마다 데이터셋 전체 재크롤 | 비용·시간이 큼. **일회성 대폭 스키마 변경 때 잠시 전체로 바꿨다가 되돌리라**고 권고 | "스키마 대폭 변경", "한 번만 전체" |
| **증분**(`CRAWL_NEW_FOLDERS_ONLY`) | 첫 실행은 전체, 이후 **새로 생긴 폴더만** 추가 | **기존 파티션의 수정·삭제는 감지 못 함**, update/delete 동작을 **`LOG`로 강제**, S3 대상 변경 불가 | "새 폴더만 계속 추가", "스키마 안정" |
| **S3 이벤트**(`CRAWL_EVENT_MODE`) | **SQS에서 S3 이벤트를 소비**해 변경된 하위 폴더만 리스팅. **첫 크롤은 전체 리스팅** | **크롤당 최대 100,000 메시지**, 큐에 이벤트가 없으면 비용 없음 | "기존 폴더에 객체 추가·삭제", "재크롤 비용 절감" |

### 5) 크롤러의 테이블·파티션 판정 {#crawler-tables}

- 크롤러는 폴더 구조에서 테이블 루트와 파티션 폴더를 판정합니다. **폴더 수준 스키마가 대체로 비슷하면 별도 테이블이 아니라 한 테이블의 파티션**으로 만듭니다. 예: `s3://sales/year=2019/month=Jan/day=1` 같은 말단 폴더들은 파티션 키 `year`·`month`·`day`를 가진 **테이블 1개**가 됩니다.
- **별도 테이블로 만들고 싶으면** 각 테이블의 루트 폴더를 **크롤러의 별도 데이터 스토어로 추가**합니다.
- 반대로 **파일 포맷·압축 방식·스키마·S3 파티션 구조가 서로 다르면 크롤러가 테이블을 여러 개 만듭니다.** "테이블이 왜 10개나 생겼나"의 원인은 대개 이것입니다.

### 6) 파티션 동기화 수단 — 6가지 비교 {#partition-sync}

S3에 새 파티션(프리픽스)이 생겨도 **카탈로그에 등록되지 않으면 엔진이 보지 못합니다.**

| 수단 | 동작 | 제약 | 시험 단서 |
|---|---|---|---|
| **크롤러 재실행**(증분/이벤트) | 새 폴더·변경을 감지해 등록 | 포맷·스키마가 다르면 테이블이 쪼개짐. 증분은 기존 파티션 수정·삭제 미감지 | "자동 감지", "스케줄/이벤트" |
| **`MSCK REPAIR TABLE`**(Athena) | S3의 **Hive 호환 파티션**을 스캔해 추가 | **추가만 하고 제거하지 않음**(제거는 `ALTER TABLE DROP PARTITION`) | "`key=value` 프리픽스", "테이블 생성 직후 일괄" |
| **`ALTER TABLE ADD PARTITION`**(Athena) | 지정한 파티션 값·위치만 추가 | Hive 스타일이면 `LOCATION` 생략 가능, **아니면 필수**. 대량이면 나눠 실행 권장 | "비 Hive 스타일 경로", "특정 파티션만" |
| **`BatchCreatePartition`**(Glue API) | 파티션을 배치로 생성 | 호출당 **최대 100개** | "프로그램으로 등록" |
| **Athena 파티션 프로젝션** | 파티션 값 범위·타입을 **테이블 속성에 정의**해 쿼리 시 계산 | **켜면 카탈로그의 파티션 메타데이터를 무시**. **Athena 쿼리에서만 유효**(Spectrum·EMR은 표준 메타데이터 사용). 프로젝션 파티션의 **절반 넘게 비면 전통 파티션 권장** | "파티션 등록 작업 제거", "Athena 전용" |
| **Glue ETL 잡이 쓰면서 갱신** | `enableUpdateCatalog=True` + `partitionKeys`로 등록 | **S3 타깃만**, json·csv·avro·parquet만. `enableUpdateCatalog`가 true가 아니면 **`updateBehavior`를 줘도 갱신 안 됨** | "잡이 쓰는 즉시 반영" |

**파티션 인덱스는 "동기화"가 아니라 "조회 가속"입니다**(프로젝션과 혼동 주의).

- 인덱스가 없으면 Glue가 **테이블의 모든 파티션을 로드한 뒤 표현식으로 필터링**합니다.
- 인덱스는 파티션 키의 부분 목록으로 만들며 **테이블당 최대 3개**이고, **표현식에 인덱스의 첫 키가 있어야** 사용됩니다.
- ACTIVE 인덱스는 **Redshift Spectrum·EMR·Glue ETL Spark DataFrame이 자동 활용**하고, **Athena와 Glue ETL DynamicFrame은 추가 설정**이 필요합니다(Athena는 테이블 속성 `partition_filtering.enabled=true`).
- 파티션마다 인덱스 항목이 생기고 **과금 대상**입니다.

> 🧠 원리: 왜 프로젝션과 인덱스를 섞으면 안 될까요?
> 둘은 **서로 다른 병목**을 풉니다. 프로젝션은 "**카탈로그를 아예 보지 않겠다**"는 선택이라 파티션 등록 작업 자체가 사라지지만, 그 대가로 **Athena 밖의 엔진은 혜택을 받지 못하고** 카탈로그에 등록된 파티션은 무시됩니다.
> 인덱스는 "**카탈로그는 계속 쓰되 조회를 빠르게**" 하는 선택이라 Spectrum·EMR처럼 **여러 엔진이 같은 테이블을 읽을 때** 유효합니다.
> 그래서 문항의 결정적 단서는 성능 숫자가 아니라 **"누가 이 테이블을 읽는가"** 입니다.

### 7) Glue 연결(Connection)과 VPC 네트워킹 {#glue-connection}

연결은 **자격 증명·URL·VPC 정보 등 접속 정보를 저장한 Data Catalog 객체**입니다.

- **유형** — JDBC 또는 특정 유형(예: Amazon RDS), **VPC 안의 데이터 소스에 접근하는 Network**, **Kafka**(콤마로 구분한 부트스트랩 서버 URL과 포트; MSK는 다른 계정 클러스터 지정 가능).
- **VPC 네트워킹** — Glue는 연결의 서브넷에 **사설 IP를 가진 ENI**를 만듭니다. 연결의 보안 그룹 중 하나는 **모든 TCP 포트에 대한 self-referenced 인바운드 규칙**이 있어야 하고 하나는 아웃바운드가 열려 있어야 합니다. **서브넷의 여유 IP 수는 잡 worker 수보다 많아야** 합니다.
- **VPC 밖 데이터** — 온프레미스나 퍼블릭 호스트명 RDS처럼 VPC 밖 데이터는 서브넷 라우트 테이블에 **퍼블릭 서브넷의 NAT 게이트웨이**가 있어야 하며, 없으면 **연결이 시간 초과**됩니다. Secrets Manager·STS가 필요하면 엔드포인트를 붙이고, S3로 가는 엔드포인트나 NAT 경로를 제공합니다.

> ⚠️ "Test connection 실패"의 정답은 **인바운드 전체 개방(0.0.0.0/0)이 아니라 self-referenced 규칙**입니다.

### 8) 비즈니스 데이터 카탈로그 — Amazon SageMaker Catalog {#business-catalog}

**정의·위치** — SageMaker Catalog는 여러 프로젝트가 **게시한** 모든 자산의 카탈로그이며 **범위는 도메인**입니다. **SageMaker Unified Studio를 통해 접근**하고, **Amazon DataZone 위에 구축**되어 같은 거버넌스 기능을 제공합니다(기존 DataZone 경험도 그대로 유지). **프로젝트 안의 산출물은 카탈로그에 게시하기 전에는 프로젝트 밖에서 접근할 수 없습니다.** 도메인에는 **Identity Center 기반과 IAM 기반** 두 유형이 있습니다.

**핵심 객체**

- **자산(Asset)** — 단일 물리 데이터 객체(테이블·대시보드·파일) 또는 가상 데이터 객체(뷰). **모든 자산에는 소유(생산자) 프로젝트**가 있고 소유 프로젝트가 구독 이행 정책을 통제합니다.
- **비즈니스 용어집(Glossary)·용어** — 자산·컬럼에 붙여 검색과 식별을 돕습니다. **만든 프로젝트가 소유**해 그 멤버만 수정·삭제하지만, **도메인 모든 사용자에게 보이고** 모든 프로젝트가 용어를 붙일 수 있습니다.
- **메타데이터 폼** — 수집·저장할 메타데이터를 정의합니다(필드 타입: boolean·date·decimal·integer·string·business glossary).
- **데이터 제품(Data product)** — 자산을 업무 용도에 맞게 묶은 독립 패키지. **구독 요청**은 approved·rejected·revoked·granted 상태를 가집니다.
- **데이터 소스** — **Glue Data Catalog·Redshift**의 기술 메타데이터를 가져와 프로젝트 인벤토리에 자산을 만듭니다.

**게시·구독 흐름** — (IDC 기반) 프로젝트 인벤토리로 자산을 가져오고 → 비즈니스 이름·설명·README·용어·메타데이터 폼으로 **큐레이션** → **게시**해야 도메인 사용자가 발견합니다. **인벤토리 자산은 게시 전에는 프로젝트 멤버만** 볼 수 있고, **최신 버전만 게시**할 수 있으며 갱신 후에는 **다시 게시**해야 합니다. (IAM 기반) **Glue 테이블은 도메인에서 자동으로 발견**되고, 접근 요청이 승인되면 **필요한 Lake Formation 권한이 자동 부여**됩니다.

| 구분 | AWS Glue Data Catalog (기술) | Amazon SageMaker Catalog (비즈니스) |
|---|---|---|
| 담는 정보 | 테이블 정의·스키마·파티션 | 비즈니스 이름·설명·README·용어집·메타데이터 폼·데이터 제품 |
| 범위 단위 | **계정·리전당 1개** | **도메인**(발견 범위), 소유 단위는 **프로젝트** |
| 채우는 방법 | 크롤러·ETL 잡·DDL | 데이터 소스(Glue·Redshift) → 큐레이션 → **게시** |
| 주 사용자 | 쿼리·ETL 엔진 | 데이터 소유 팀·소비 팀(검색 → 구독 요청 → 승인) |
| 시험 단서 | "스키마·파티션·크롤러·ETL 소스" | "**용어집·검색·구독/승인·데이터 제품**" |

---

## ✍️ 시험 포인트

- "**S3에 파일은 있는데 Athena에서 안 보인다**" → 파티션 미등록. 경로가 **`key=value`면 `MSCK REPAIR TABLE`**, **아니면 `ALTER TABLE ADD PARTITION`(`LOCATION` 필수)**, **파티션 규칙이 예측 가능하고 Athena 전용이면 프로젝션**.
- "**여러 엔진이 같은 테이블을 읽는데 파티션이 수십만 개**" → **크롤러로 등록 + Glue 파티션 인덱스**. 프로젝션은 **Athena에서만** 유효하니 오답 방향입니다.
- "**ETL로 정제한 컬럼 정의를 크롤러가 덮어쓴다**" → **"Add new columns only"**(`MergeNewColumns`). 완전 고정은 `UpdateBehavior=LOG`.
- "**기존 폴더 안에 객체가 추가·삭제된다**" → **S3 이벤트 모드**. "**새 폴더만 계속 쌓인다**" → **증분 크롤**(기존 파티션 수정·삭제는 감지 못 함).
- "**크롤러가 테이블을 여러 개 만든다**" → 포맷·압축·스키마·파티션 구조가 다름. 맞추거나 루트 폴더를 별도 데이터 스토어로 분리.
- "**Kinesis/Kafka 소스를 크롤러로 자동 추론**" → **불가**. 스트리밍은 테이블을 직접 정의합니다.
- "**프라이빗 서브넷 RDS에 Test connection 시간 초과**" → **self-referenced 인바운드 규칙**, 서브넷 여유 IP > worker 수, VPC 밖이면 **NAT 경로**.
- "**현업이 비즈니스 용어로 검색하고, 사유를 적어 접근을 요청·승인**" → **SageMaker Catalog**(게시 → 구독). "**Athena·EMR·Spectrum이 스키마를 공유**" → **Glue Data Catalog**.
- "**다른 팀이 검색해도 자산이 안 보인다**" → **게시 누락**(인벤토리 상태). 갱신했으면 **다시 게시**해야 합니다.
- 숫자로 갈리는 보기: 크롤러 샘플링 **1,000 레코드 / 1 MB(최대 10 MB)**, `SampleSize` **1~249**, S3 이벤트 **100,000 메시지/크롤**, `BatchCreatePartition` **100개/호출**, 파티션 인덱스 **테이블당 3개**, 크롤러 스케줄 **최소 5분**, EMR Hive 메타스토어 **5.8.0 이상**.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"카탈로그에 테이블을 만들면 데이터도 복사된다."** → ❌. 테이블·DB는 **메타데이터일 뿐**이고 데이터는 원래 저장소에 그대로 있습니다.
2. **"스키마 변경 정책을 `LOG`로 하면 새 파티션도 안 생긴다."** → ❌. 정책은 **이미 있는 테이블에서 감지한 변경**에만 적용되고 **신규 테이블·파티션은 항상 생성**됩니다.
3. **"증분 크롤이면 기존 폴더의 파일 추가·삭제도 반영된다."** → ❌. 증분은 **새 폴더만** 봅니다. 기존 폴더 변경까지 반영하려면 **S3 이벤트 모드**입니다.
4. **"`MSCK REPAIR TABLE`이면 삭제된 파티션도 정리된다."** → ❌. **추가만 하고 제거하지 않습니다**(제거는 `ALTER TABLE DROP PARTITION`). 느릴 수도 있습니다.
5. **"파티션 프로젝션을 켜면 Spectrum·EMR도 빨라진다."** → ❌. **Athena 쿼리에서만 유효**하고, 켜면 **카탈로그의 파티션 메타데이터는 무시**됩니다.
6. **"파티션 인덱스를 만들면 Athena가 자동으로 쓴다."** → ❌. **Athena와 Glue ETL DynamicFrame은 추가 설정**이 필요합니다(`partition_filtering.enabled=true`). Spectrum·EMR·Spark DataFrame은 자동입니다.
7. **"ETL 잡에 `updateBehavior`만 주면 카탈로그가 갱신된다."** → ❌. **`enableUpdateCatalog=True`가 아니면 갱신되지 않습니다.** 게다가 **S3 타깃·json/csv/avro/parquet**만 해당합니다.
8. **"크롤러로 Hive 메타스토어를 가져온다."** → ❌. **크롤러 지원 스토어 목록에 Hive 메타스토어는 없습니다.** Athena는 **Lambda 커넥터**로 외부 Hive 메타스토어에 연결합니다.
9. **"Test connection이 실패하니 보안 그룹 인바운드를 0.0.0.0/0으로 연다."** → ❌. 문서가 요구하는 것은 **모든 TCP 포트에 대한 self-referenced 인바운드 규칙**입니다.
10. **"EMR에서 Hive 테이블을 `LOCATION` 없이 만들어도 된다."** → ❌. 기본 위치가 **HDFS**라 **클러스터 종료 시 데이터가 사라집니다.**
11. **"SageMaker Catalog는 Glue Data Catalog를 대체한다."** → ❌. 전자는 **도메인 단위 비즈니스 카탈로그**(용어집·구독 승인), 후자는 **엔진이 쓰는 기술 메타데이터**입니다. SageMaker Catalog는 오히려 **Glue 테이블을 자동으로 수집**합니다.
12. **"프로젝트 인벤토리에 넣었으니 다른 팀이 검색할 수 있다."** → ❌. **게시(publish)해야** 도메인 사용자가 발견합니다. 갱신 후에는 **최신 버전을 다시 게시**해야 합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (문항 뱅크는 `dea-t2-2.questions.json` — 사람 검수 전이라 사이트에는 노출되지 않습니다)

**Q1.** Glue ETL 잡이 산출 테이블의 컬럼 정의를 사람이 다듬어 둔 상태인데, 야간 크롤러가 그 정의를 덮어씁니다. 새로 생기는 컬럼은 반영하되 기존 정의는 지키려면?

<details><summary>정답 보기</summary>

크롤러의 스키마 변경 정책을 **"Add new columns only"**(API로는 `Tables.AddOrUpdateBehavior=MergeNewColumns`)로 설정합니다. 기존 스키마를 바꾸지 않고 새 컬럼만 추가합니다. 완전히 고정하려면 `UpdateBehavior=LOG`("Ignore the change…")인데 이러면 **새 컬럼도 추가되지 않습니다.**
</details>

**Q2.** 수백 GB의 S3 테이블에서 **기존 파티션 폴더 안에 객체가 계속 추가·삭제**됩니다. 전체 재크롤은 느리고 비쌉니다. 어떤 재크롤 모드를 쓰나요?

<details><summary>정답 보기</summary>

**S3 이벤트 모드**(`CRAWL_EVENT_MODE`)입니다. SQS에서 S3 이벤트를 소비해 **변경이 생긴 하위 폴더만 리스팅**하므로 재크롤 시간·비용이 줄고, 큐에 이벤트가 없으면 비용도 없습니다(첫 크롤은 전체 리스팅, 크롤당 최대 100,000 메시지). **증분 크롤은 새 폴더만 감지하고 기존 파티션의 수정·삭제는 감지하지 못해** 이 요구를 만족하지 못합니다.
</details>

**Q3.** 같은 Glue 테이블을 Athena·Redshift Spectrum·EMR이 함께 읽습니다. 파티션이 수십만 개로 늘면서 쿼리 계획 단계가 느려졌습니다. 어떻게 하나요?

<details><summary>정답 보기</summary>

**Glue 파티션 인덱스**를 만듭니다(테이블당 최대 3개, 표현식에 인덱스의 첫 키 포함 필요). 인덱스가 없으면 Glue가 **모든 파티션을 로드한 뒤 필터링**합니다. ACTIVE 인덱스는 Spectrum·EMR·Glue ETL Spark DataFrame이 자동 활용하고, **Athena는 `partition_filtering.enabled=true`** 를 추가로 켭니다. **파티션 프로젝션은 Athena 쿼리에서만 유효**해 여러 엔진이 읽는 이 상황에는 맞지 않습니다.
</details>

**Q4.** 하나의 S3 프리픽스를 크롤했더니 의도와 달리 테이블이 여러 개 생겼습니다. 원인과 대응은?

<details><summary>정답 보기</summary>

**파일 포맷·압축 방식·스키마·S3 파티션 구조가 서로 다르면** 크롤러가 테이블을 여러 개 만듭니다. 반대로 폴더 수준 스키마가 대체로 비슷하면 **한 테이블의 파티션**으로 묶입니다. 대응은 ① 형식·스키마를 통일하거나 ② 의도한 각 테이블의 **루트 폴더를 크롤러의 별도 데이터 스토어로 추가**하는 것입니다.
</details>

**Q5.** 현업 분석가들이 **비즈니스 용어로 데이터를 검색**하고, 사유를 적어 **접근을 요청·승인**받는 흐름이 필요합니다. 기술 스키마는 이미 Glue Data Catalog에 있습니다.

<details><summary>정답 보기</summary>

**Amazon SageMaker Catalog**(SageMaker Unified Studio로 접근, DataZone 기반)를 씁니다. 데이터 소스로 **Glue·Redshift 메타데이터를 가져와** 프로젝트 인벤토리를 만들고, 비즈니스 이름·용어집·메타데이터 폼으로 큐레이션한 뒤 **게시**하면 도메인 사용자가 발견합니다. 소비 프로젝트가 **구독을 요청**하고 소유 프로젝트가 승인하면 권한이 제공됩니다(IAM 기반 도메인에서는 승인 시 **Lake Formation 권한이 자동 부여**). Glue Data Catalog는 기술 메타데이터 저장소라 이 워크플로를 제공하지 않습니다.
</details>

---

**Q6 (원리).** 왜 "파티션을 등록하는 일"이 데이터 레이크에서 계속 문제가 될까요?

<details><summary>정답 보기</summary>

**S3는 파일 시스템이 아니라 객체 저장소여서, 데이터가 늘어나도 아무도 "테이블이 커졌다"고 알려 주지 않기 때문입니다.** 데이터(S3)와 메타데이터(카탈로그)가 분리된 구조의 대가입니다 — 그 덕에 엔진을 자유롭게 바꿔 끼울 수 있지만, **둘을 맞추는 일은 누군가 해야** 합니다. 그래서 해법이 세 갈래로 갈립니다: **주기적으로 맞추기**(크롤러·`MSCK`), **쓰는 쪽이 바로 알리기**(ETL 잡의 `enableUpdateCatalog`), **아예 맞추지 않기**(프로젝션 — 규칙으로 계산). 문항은 "누가 읽는가·얼마나 자주 바뀌는가·관리를 없애고 싶은가"로 이 셋 중 하나를 가리킵니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. AWS Glue concepts — https://docs.aws.amazon.com/glue/latest/dg/components-key-concepts.html
2. AWS Glue pricing — https://aws.amazon.com/glue/pricing/
3. Table API (AWS Glue Web API Reference) — https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-catalog-tables.html
4. Use AWS Glue Data Catalog to connect to your data (Athena) — https://docs.aws.amazon.com/athena/latest/ug/data-sources-glue.html
5. External schemas in Amazon Redshift Spectrum — https://docs.aws.amazon.com/redshift/latest/dg/c-spectrum-external-schemas.html
6. Using the AWS Glue Data Catalog as the metastore for Hive (Amazon EMR) — https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-hive-metastore-glue.html
7. Connect Athena to an Apache Hive metastore — https://docs.aws.amazon.com/athena/latest/ug/connect-to-data-source-hive-connecting-athena-to-an-apache-hive-metastore.html
8. Supported data sources for crawling — https://docs.aws.amazon.com/glue/latest/dg/crawler-data-stores.html
9. Defining and managing classifiers — https://docs.aws.amazon.com/glue/latest/dg/add-classifier.html
10. Using crawlers to populate the Data Catalog — https://docs.aws.amazon.com/glue/latest/dg/add-crawler.html
11. Preventing a crawler from changing an existing schema — https://docs.aws.amazon.com/glue/latest/dg/crawler-schema-changes-prevent.html
12. Crawler API (AWS Glue Developer Guide) — https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-crawling.html
13. AWS::Glue::Crawler SchemaChangePolicy (CloudFormation) — https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-glue-crawler-schemachangepolicy.html
14. Scheduling incremental crawls for adding new partitions — https://docs.aws.amazon.com/glue/latest/dg/incremental-crawls.html
15. Accelerating crawls using Amazon S3 event notifications — https://docs.aws.amazon.com/glue/latest/dg/crawler-s3-event-notifications.html
16. Time-based schedules for jobs and crawlers — https://docs.aws.amazon.com/glue/latest/dg/monitor-data-warehouse-schedule.html
17. How do I prevent the creation of multiple tables during an AWS Glue crawler run? — https://repost.aws/knowledge-center/glue-crawler-multiple-tables
18. MSCK REPAIR TABLE (Athena) — https://docs.aws.amazon.com/athena/latest/ug/msck-repair-table.html
19. ALTER TABLE ADD PARTITION (Athena) — https://docs.aws.amazon.com/athena/latest/ug/alter-table-add-partition.html
20. Use partition projection with Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html
21. Creating partition indexes (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/partition-indexes.html
22. BatchCreatePartition (AWS Glue Web API Reference) — https://docs.aws.amazon.com/glue/latest/webapi/API_BatchCreatePartition.html
23. Updating the schema, and adding new partitions in the Data Catalog using AWS Glue ETL jobs — https://docs.aws.amazon.com/glue/latest/dg/update-from-job.html
24. AWS Glue connection properties — https://docs.aws.amazon.com/glue/latest/dg/connection-properties.html
25. Why does my AWS Glue test connection fail? — https://repost.aws/knowledge-center/glue-test-connection-failed
26. Amazon SageMaker Unified Studio terminology and concepts — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/concepts.html
27. Catalog in IDC-based domains (Amazon SageMaker Unified Studio) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/working-with-business-catalog.html
28. Working with data and catalog in IAM-based domains — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/catalog-iam-based-domains.html
29. Amazon SageMaker Catalog FAQs — https://aws.amazon.com/sagemaker/catalog/faqs/
30. Create new data products in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/create-new-data-product.html
31. DEA-C01 공식 시험 가이드 Revisions (v1.1 변경 이력) — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html
32. Domains in Amazon SageMaker Unified Studio (Administrator Guide) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/working-with-domains.html
33. DEA-C01 공식 시험 가이드 도메인 2 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
