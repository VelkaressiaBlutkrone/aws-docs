---
examGuideTaskId: dea-t2-4
certCode: DEA-C01
domain: 2
domainName: 데이터 스토어 관리
domainWeightPct: 26
title: 데이터 모델·스키마 진화 설계 (테이블 설계·스키마 변환·계보·벡터화)
coversTasks:
  - "2.4"
sources:
  - title: Distribution styles (Amazon Redshift) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/c_choosing_dist_sort.html
  - title: NoSQL design for DynamoDB (공식 문서)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-general-nosql-design.html
  - title: AWS Glue Schema registry (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/schema-registry.html
  - title: Handle schema updates (Amazon Athena) (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/handling-schema-updates-chapter.html
  - title: Converting database schemas using DMS Schema Conversion (공식 문서)
    url: https://docs.aws.amazon.com/dms/latest/userguide/CHAP_SchemaConversion.html
  - title: How Amazon Bedrock knowledge bases work (공식 문서)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html
  - title: DEA-C01 공식 시험 가이드 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
lastVerified: 2026-10-20
---

# 데이터 모델·스키마 진화 설계 (테이블 설계·스키마 변환·계보·벡터화)

> **커버하는 공식 Task** — DEA-C01 · 도메인 2 「데이터 스토어 관리」(26%) · **Task 2.4 데이터 모델 및 스키마 진화 설계** (`dea-t2-4`)
> **"처음에 어떻게 설계하는가"(모델)** 와 **"나중에 바뀔 때 어떻게 버티는가"(진화)** 가 한 Task에 묶여 있습니다.
> **Skill 2.4.6(벡터화 개념)은 v1.1 신규**, **2.4.4(계보)는 v1.1 개정**(SageMaker Catalog 추가)입니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 2.4의 Skill 항목)

- [ ] Redshift의 **분산 스타일·정렬 키·압축·제약조건**을 설계 요구로 고를 수 있다
- [ ] DynamoDB의 **액세스 패턴 우선 설계**와 GSI/LSI 선택 기준을 말할 수 있다
- [ ] Lake Formation의 **LF-Tag 설계 제약**을 안다
- [ ] 스키마 변경을 계층별로 흡수한다 — **크롤러 정책 · Schema Registry 호환성 · Athena 포맷 · Iceberg · Redshift ALTER · DMS DDL**
- [ ] **DMS Schema Conversion과 AWS SCT**의 차이와 시험 범위상 주의점을 안다
- [ ] **SageMaker ML Lineage Tracking vs SageMaker Catalog 데이터 계보**를 구분한다
- [ ] **파티셔닝·버킷팅·정렬·컬럼형 압축**으로 Athena 스캔을 줄이는 방법을 설명한다
- [ ] **벡터화 파이프라인**(청킹 → 임베딩 → 벡터 스토어 → sync)을 설명한다

---

## 🎯 왜 중요한가

- 2.4는 **앞 세 Task의 결론이 모이는 곳**입니다. 2.1에서 고른 저장소에 **어떤 모양으로 담을지**, 2.2의 카탈로그가 **스키마 변화를 어떻게 따라갈지**, 2.3의 수명 주기가 **어떤 파티션 위에서 돌지**를 정합니다.
- 실무 사고가 그대로 문항이 됩니다 — "조인이 느리다"(분산 스타일), "소스 스키마가 바뀌어 파이프라인이 깨졌다"(Schema Registry·Iceberg), "작은 파일이 수만 개"(파티션 설계).
- v1.1 신규 Skill 2.4.6은 **"벡터화 개념 설명"** 수준입니다. 시험 가이드의 일반 IT 지식 항목에도 "벡터의 일반 개념"이 있으니, **파이프라인 구성요소와 역할**을 아는 선에서 준비하면 됩니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **zone map** | zone map | Redshift가 1 MB 블록마다 저장하는 min/max 메타데이터 — 범위 조건에서 블록을 건너뛴다 |
| **팩트 / 디멘션** | fact / dimension | 사건 기록을 담는 큰 테이블 / 그 속성을 설명하는 작은 테이블 |
| **ATO** | automatic table optimization | Redshift가 정렬 키·분산 키를 자동으로 골라 적용하는 자가 튜닝 |
| **스키마 드리프트** | schema drift | 소스의 컬럼·타입이 예고 없이 바뀌어 파이프라인이 어긋나는 현상 |
| **호환성 모드** | compatibility mode | 스키마 레지스트리가 새 버전 등록을 허용할지 판단하는 규칙 |
| **스키마 온 리드** | schema-on-read | 저장할 때가 아니라 읽을 때 스키마를 적용하는 방식(Athena) |
| **계보** | lineage | 데이터가 어디서 왔고 어떻게 변환됐는지 추적한 기록 |
| **임베딩** | embedding | 텍스트 청크를 나타내는 숫자열(벡터) |
| **청킹** | chunking | 문서를 임베딩하기 좋은 조각으로 나누는 전처리 |
| **RAG** | retrieval augmented generation | 저장소에서 관련 정보를 찾아와 LLM 응답을 보강하는 기법 |

---

## 📖 핵심 개념

### 1) Redshift 테이블 설계 — 분산·정렬·압축·제약조건 {#redshift-table-design}

Redshift는 **테이블을 만들 때 정하는 분산 스타일·정렬 키·압축 인코딩**이 쿼리 성능을 좌우합니다. 먼저 중요한 전제: **Redshift는 객체 안에서 데이터를 파티셔닝하는 개념 자체를 지원하지 않습니다** — 테이블스페이스나 파티션 스킴을 정의할 필요가 없습니다(S3 데이터 레이크의 파티셔닝과 혼동 금지).

**분산 스타일**

| 스타일 | 적합한 경우 | 제약·비용 | 시험 단서 |
|---|---|---|---|
| **AUTO**(기본) | 어떤 스타일이 맞는지 모를 때 | 작은 테이블 ALL → 커지면 KEY 또는 EVEN으로 **백그라운드 자동 변경** | "기본", "관리 부담 최소" |
| **EVEN** | **조인에 참여하지 않는** 테이블 | 열 값과 무관한 라운드 로빈 — colocation 없음 | "조인 없음" |
| **KEY** | 큰 팩트 + 큰 디멘션을 **공통 조인 열로 colocate** | **팩트 테이블은 분산 키가 하나뿐** | "조인 열", "colocate" |
| **ALL** | 다른 테이블과 colocate할 수 없고 **거의 갱신되지 않는** 디멘션 | **저장 공간 × 노드 수**, 적재·갱신 느림 | "slow moving" |

> ⚠️ **"작은 디멘션 = 무조건 ALL"은 함정입니다.** 공식 문서는 **colocate할 수 없는 디멘션에는 ALL이 성능을 크게 올릴 수 있다**고 하면서도, **재분산 비용이 낮은 작은 디멘션 테이블은 ALL로 얻는 이점이 크지 않다**고도 말합니다. 갱신 빈도와 colocate 가능성을 함께 보세요.
> 분산 키는 **필터링된 결과 집합에서 카디널리티가 높은 열**로 고릅니다.

**정렬 키** — 정렬하면 Redshift가 **1 MB 디스크 블록마다 min/max를 메타데이터로 저장**해 범위 조건 쿼리에서 블록을 대거 건너뜁니다. **COMPOUND(기본값)** 는 정렬 키 열의 **접두(prefix) 조건**에 효율적이고, **INTERLEAVED**는 키의 각 열에 **같은 가중치**를 주어 어떤 열 부분집합이든 조건으로 쓸 수 있으며 **최대 8열**입니다. **`INSERT`/`UPDATE`/`DELETE`로 정기 갱신하면 COMPOUND가 권장**됩니다.

**자동 테이블 최적화(ATO)** — 쿼리 패턴을 관찰해 **정렬 키·분산 키를 자동으로** 고르고 적용합니다. 분산 스타일 또는 정렬 키가 `AUTO`인 테이블은 이미 대상이고, 기존 테이블은 `ALTER DISTSTYLE AUTO` / `ALTER SORTKEY AUTO`로 전환합니다. **분산 스타일을 ALL·EVEN·KEY로 직접 바꾸면 더 이상 ATO 후보가 아닙니다.**

**압축 인코딩** — **`ENCODE AUTO`가 테이블의 기본값**으로 Redshift가 전 열의 인코딩을 자동 관리합니다. **한 열이라도 인코딩을 직접 지정하면 그 테이블은 `ENCODE AUTO`가 아니게 되고**, 지정하지 않은 열은 **정렬 키·BOOLEAN·REAL·DOUBLE PRECISION → RAW**, **정수·DECIMAL·DATE·TIMESTAMP 계열 → AZ64**, **CHAR·VARCHAR → LZO**로 배정됩니다.

**제약조건** — **UNIQUE·PRIMARY KEY·FOREIGN KEY는 정보용일 뿐 적재 시 강제되지 않지만** 쿼리 플래너가 **계획 힌트**로 씁니다. 키가 실제로 유효하지 않으면 `SELECT DISTINCT`가 중복 행을 돌려주는 등 **잘못된 결과**가 날 수 있어 무결성이 보장될 때만 선언합니다. **`NOT NULL`은 강제됩니다.**

### 2) DynamoDB 데이터 모델링 — 액세스 패턴이 먼저 {#dynamodb-model}

DynamoDB는 **스키마리스**라 속성을 미리 다 정의할 필요가 없고, **파티션 키는 필수·정렬 키는 선택**입니다. 기본 키는 파티션 키만 쓰는 simple 또는 파티션 키+정렬 키의 composite 형태입니다.

- **설계 순서** — **첫 단계는 시스템이 만족해야 할 쿼리 패턴을 식별하는 것**입니다. 데이터 크기·모양·피크 부하를 먼저 파악하고, 관련 데이터를 함께 두고, 정렬 순서를 활용하고, **쿼리를 파티션에 고르게 분산**하며(핫스팟 회피), 필요한 쿼리마다 GSI를 만듭니다. **테이블은 가능한 한 적게** 유지하는 것이 일반 원칙이고(단일 테이블), **대용량 시계열 데이터나 액세스 패턴이 매우 다른 데이터셋은 예외**입니다.
- **파티션 키** — **카디널리티가 높은 키**를 골라 자주 접근하는 항목이 한 파티션에 몰리지 않게 합니다. 모든 파티션은 **초당 읽기 3,000 단위·쓰기 1,000 단위**를 제공하도록 설계됩니다.
- **항목 크기** — **항목당 최대 400 KB**이며 **속성 이름과 값의 길이를 모두 합산**합니다. 넘을 수 있으면 직렬화한 항목을 **S3에 저장하고 위치를 속성으로** 담는 우회책이 안내됩니다(키·인덱스에 쓰는 속성은 테이블에 남김).

| 구분 | GSI | LSI |
|---|---|---|
| 키 구성 | 파티션 키·정렬 키 **모두 달라도 됨** | **파티션 키는 같고** 정렬 키만 다름(composite 필수) |
| 생성 시점 | 테이블 생성 시 또는 **이후 추가·삭제 가능** | **테이블 생성 시에만** — 나중에 추가·삭제 불가 |
| 크기 제한 | 없음 | **파티션 키 값당 10 GB** |
| 읽기 일관성 | **최종 일관성만** | **최종 또는 강한 일관성 선택** |
| 처리량 | 인덱스 자체 설정 | **base 테이블 용량에서 소비** |
| 개수(기본) | 테이블당 **20개** | 테이블당 **5개** |

> 테이블 변경은 정상 조건에서 **아주 짧은 시간(a fraction of a second)** 안에 GSI로 전파됩니다.

### 3) Lake Formation — LF-Tag 설계 {#lf-tag-design}

Lake Formation에서 "스키마 설계"는 **Data Catalog의 데이터베이스·테이블·열을 어떻게 분류하고 어떤 LF-Tag를 붙여 권한을 줄지** 정하는 일에 가깝습니다. **LF-TBAC(태그 기반 접근 제어)** 는 Data Catalog 객체가 많을 때 **권장되는 방법**입니다.

- LF-Tag는 리소스에 부여하거나 보안 주체에 허용하기 전에 **미리 정의**되어 있어야 합니다.
- 한 리소스에 LF-Tag를 여러 개 달 수 있지만 **같은 키에는 값을 하나만** 지정할 수 있습니다(`module=Orders,Customers` 불가).
- **리소스를 만들 때 LF-Tag를 함께 지정할 수 없고**, 이미 존재하는 리소스에만 추가합니다.
- 보안 주체에는 **LF-Tag 표현식**을 부여할 수 있습니다(`module=sales AND division=(consumer OR commercial)`). **서로 다른 키 조건을 OR로 허용하려면 grant를 둘로 나눕니다.**
- **IAM 태그와 LF-Tag는 서로 다른 것이며 호환되지 않습니다.**

### 4) 데이터 특성 변경에 대응하기 — 계층별 수단 {#schema-evolution}

소스 스키마가 바뀔 때 어디서 흡수할지는 계층마다 다릅니다.

- **Glue 크롤러(카탈로그 계층)** — "Update the table definition"(갱신) / **"Add new columns only"**(수동 수정 보존, 새 컬럼만) / "Ignore the change…"(미갱신) 중에서 고릅니다. 파티션 메타데이터를 테이블과 같게 유지하려면 "Update all new and existing partitions…"도 켭니다.
- **Glue Schema Registry(스트리밍 계약 계층)** — 스키마마다 버전이 있고, **새 버전 등록은 호환성 규칙 검사를 통과해야만** 성공합니다. **호환성 모드는 8가지**입니다. 하드 한도는 리전당 **레지스트리 100개·스키마 버전 10,000개·스키마 페이로드 170 KB**입니다.

| 모드 | 소비자가 읽을 수 있는 범위 | 허용되는 변경(Avro 기준) | 검사 대상 | 시험 단서 |
|---|---|---|---|---|
| NONE | 검사 없음 | 모두 | 없음 | "개발 단계" |
| DISABLED | **새 버전 추가 자체가 막힘** | 없음 | — | "버저닝 금지" |
| **BACKWARD**(권장) | 현재 + **직전** 버전 | 필드 삭제, **선택(optional) 필드 추가** | 직전 버전 | "최근 스키마로 만든 앱" |
| BACKWARD_ALL | 현재 + **모든 이전** 버전 | 필드 삭제, 선택 필드 추가 | 모든 이전 버전 | "모든 이전 버전과 호환" |
| **FORWARD** | 현재 + **다음(이후)** 버전 | **필드 추가**, 선택 필드 삭제 | 직전 버전 | "**이전 스키마로 만든 앱**이 최신 데이터를 처리" |
| FORWARD_ALL | 새로 등록된 어떤 스키마로 쓴 데이터든 | 필드 추가, 선택 필드 삭제 | 모든 이전 버전 | — |
| **FULL** | 이전 **또는** 다음 버전 | **선택 필드 추가/삭제** | 직전 버전 | "선택 필드만 변경" |
| FULL_ALL | 모든 이전 버전 | 선택 필드 추가/삭제 | 모든 이전 버전 | — |

- **Athena(쿼리 계층)** — Athena는 **스키마 온 리드** 엔진이라 **읽을 때 스키마를 적용할 뿐 기저 데이터를 다시 쓰지 않습니다.** 포맷별로 가능한 변경이 다릅니다.

| 변경 종류 | CSV/TSV | JSON·Avro | **Parquet(이름 기준, 기본)** | Parquet(인덱스 기준) | **ORC(인덱스 기준, 기본)** | ORC(이름 기준) |
|---|---|---|---|---|---|---|
| 컬럼 이름 변경 | 가능 | 불가 | 불가 | **가능** | **가능** | 불가 |
| 맨 앞·중간에 컬럼 추가 | 불가 | 가능 | **가능** | 불가 | 불가 | 가능 |
| 맨 끝에 컬럼 추가 | 가능 | 가능 | 가능 | 가능 | 가능 | 가능 |
| 컬럼 삭제 | 불가 | 가능 | **가능** | 불가 | 불가 | 가능 |
| 컬럼 순서 변경 | 불가 | 가능 | 가능 | 불가 | 불가 | 가능 |

  (Parquet는 기본이 **이름 기준**, ORC는 기본이 **인덱스 기준**이며 `parquet.column.index.access` / `orc.column.index.access` SerDe 속성으로 전환합니다. Parquet·ORC에서 **타입 변경은 파티션된 테이블에서만** 동작합니다.)

- **Iceberg(테이블 포맷 계층)** — **Iceberg 스키마 업데이트는 메타데이터 전용 변경**이라 **데이터 파일을 다시 쓰지 않고** 컬럼 추가·삭제·이름 변경·순서 변경·**타입 확장**(integer→bigint, float→double, decimal 정밀도 증가)을 지원합니다.
- **Redshift(웨어하우스 계층)** — `ALTER TABLE`로 `ADD COLUMN`·`DROP COLUMN`·`RENAME COLUMN`을 지원합니다. **`ALTER COLUMN TYPE`은 VARCHAR 크기 변경만** 지원하고, **기존 데이터의 최대 크기보다 줄일 수 없으며**, 기본값·UNIQUE·PK·FK가 있는 열이나 트랜잭션 블록 안에서는 바꿀 수 없습니다.
- **DynamoDB(NoSQL 계층)** — **스키마리스**라 항목마다 속성이 달라도 되므로 새 속성 추가에 DDL이 필요 없습니다(키 속성만 필수).
- **DMS(복제 계층)** — CDC 중 대상 테이블의 DDL 처리는 `ChangeProcessingDdlHandlingPolicy`가 결정합니다 — `HandleSourceTableDropped` · `HandleSourceTableTruncated` · `HandleSourceTableAltered`.

> 🧠 원리: 왜 Parquet는 "이름 기준", ORC는 "인덱스 기준"이 기본일까요?
> 컬럼을 **이름으로 찾으면** 파일 안 순서가 달라져도 되니 **중간 삽입·삭제·순서 변경**을 견디지만, **이름을 바꾸면 못 찾습니다.**
> **순서(인덱스)로 찾으면** 정반대입니다 — **이름 변경은 자유롭지만** 중간에 컬럼을 끼우면 전부 어긋납니다.
> 즉 둘 중 하나를 고르는 게 아니라, **어떤 변경을 자주 할 것인지**가 포맷과 기본 접근 방식을 결정합니다. Iceberg는 컬럼마다 고유 ID를 들고 있어 이 교환 자체를 없앤 쪽입니다.

### 5) 스키마 변환 — DMS Schema Conversion과 AWS SCT {#schema-conversion}

이기종 DB 마이그레이션은 **"스키마·코드 객체 변환"과 "데이터 이동"이 분리**됩니다.

| 구분 | **DMS Schema Conversion** | **AWS SCT** |
|---|---|---|
| 형태 | AWS DMS 안의 **완전 관리형·웹 기반 기능** | **독립 실행형 애플리케이션 + 명령줄 도구**(Windows·Fedora·Ubuntu) |
| 관계 | **SCT 변환 엔진 위에 구축** | 변환 엔진의 원조 |
| 소스·대상 | Oracle·SQL Server·PostgreSQL·MySQL·Db2·SAP ASE → **Aurora·RDS·Redshift**(문서의 경로 표 한정) | DW(**Teradata·Netezza·Vertica·Greenplum·Snowflake·BigQuery** 등) → Redshift, **Cassandra → DynamoDB**, ETL 스크립트·빅데이터 변환 |
| 공통 | 마이그레이션 프로젝트 → **평가 보고서**(자동 변환 가능/수작업 필요) → 변환 → 적용 또는 SQL 스크립트 내보내기 | 관계형 OLTP + DW 스키마 변환 |
| 중요 | **스키마만 변환하며 데이터는 옮기지 않습니다**(데이터는 DMS의 데이터 마이그레이션 기능) | — |

> ⚠️ **시험 범위 주의** — v1.1 "범위 내 서비스" 목록의 Migration and Transfer에는 **AWS DMS가 있지만 AWS SCT는 없고**, 개정 이력도 SCT를 **범위 목록에서 제거된 서비스**로 적습니다. 그런데 **Skill 2.4.3 예시에는 SCT가 남아** 있습니다. 중심은 **DMS Schema Conversion**으로 잡고 SCT는 "기반 엔진이자 DW 소스 변환 보조 도구"로 기억하세요.
> Db2 for z/OS 변환 경로는 **콘솔에 없고 DMS API/CLI로만** 씁니다.

### 6) 데이터 계보(Lineage) {#lineage}

| 도구 | 적합한 경우 | 특성 | 시험 단서 |
|---|---|---|---|
| **SageMaker ML Lineage Tracking** | 어떤 데이터셋·학습 잡으로 **어떤 모델·엔드포인트**가 만들어졌는지 재현·감사 | **tracking entity**로 ML 워크플로 요소를 표현 | "모델 거버넌스", "재현" |
| **SageMaker Catalog 데이터 계보** | Glue·Redshift 등 **데이터 자산의 출처·변환·소비**를 카탈로그에서 시각화 | **OpenLineage 호환**, DataZone 기반 | "OpenLineage", "downstream 영향 분석" |

- **ML Lineage Tracking** — SageMaker AI는 학습·처리·배치 변환 잡을 만들면 **trial component와 관련 trial·experiment의 tracking entity를 자동 생성**하고, **이미 있는 엔티티는 재사용**합니다. 계보 엔티티는 **artifact**(URI로 지정되는 객체·데이터, 보통 입력 또는 출력), **action**(활동 — 보통 입력/출력 artifact를 하나 이상 가짐), **context**(다른 엔티티의 논리적 묶음), **association**(엔티티 사이의 연결)입니다.
- **SageMaker Catalog 계보** — **OpenLineage 지원 시스템이나 API에서 오는 계보 이벤트를 수집·시각화**합니다. 자동화 수준은 소스마다 다릅니다 — **Glue 크롤러와 Amazon Redshift는 SageMaker Unified Studio에서 기본 자동**이고, **Glue 콘솔의 Glue 잡과 EMR은 기본 자동이 아니라 설정이 필요**합니다(Glue 잡은 "generate lineage events" + 도메인 ID, EMR은 Spark conf).
- ⚠️ **Lake Formation 자체가 계보 기능을 제공한다는 공식 문서는 확인되지 않았습니다.** LF-Tag는 **권한을 주는 속성이지 계보가 아닙니다.**

### 7) 인덱싱·파티셔닝·압축 모범 사례 (Athena·S3) {#optimization}

- **파티셔닝** — 파티션 키는 **가상 컬럼**이며, 키로 필터링하면 일치하는 파티션만 읽습니다. **키가 너무 많으면 파일이 잘게 쪼개지고, 너무 적으면 필요 이상을 스캔**합니다. **가장 흔한 쿼리에 맞추고 드문 쿼리를 위해 최적화하지 마세요** — 일 단위 조회가 대부분이면 시간 단위로 쪼개지 말고 **타임스탬프로 정렬**해 두면 짧은 구간 쿼리에 거의 동등한 효과를 냅니다. **파티션 키 타입은 항상 STRING**을 씁니다(그래야 파티션 필터가 Glue로 푸시다운).
- **Hive 스타일 vs 비 Hive 스타일** — 경로가 `year=2021/month=01/`이면 Hive 스타일이고 **`MSCK REPAIR TABLE`은 Hive 스타일에서만** 동작합니다. CloudTrail 로그·Firehose 전송 스트림처럼 날짜가 별도 경로 요소면 **`ALTER TABLE ADD PARTITION`으로 수동 추가**합니다. S3 경로는 **소문자**여야 합니다(camel case면 `MSCK`가 파티션을 추가하지 못함).
- **파티션 수 한도** — Glue 테이블이 **1천만 개 파티션**을 가져도 질의는 가능하지만 **한 번의 스캔에서 100만 개를 넘는 파티션은 읽지 못합니다.**
- **파티션 메타데이터 관리** — `MSCK REPAIR TABLE`은 느릴 수 있고 **새 파티션만 추가할 뿐 오래된 파티션은 제거하지 못합니다.** 대안은 Glue Data Catalog API·`ALTER TABLE ADD PARTITION`·크롤러이고, **파티션 프로젝션**은 관리 자체를 없앱니다(단 **sparse 테이블에서는 오히려 느려질 수 있고 모든 파티션 키에 조건**이 필요).
- **컬럼형 + 압축** — Parquet·ORC는 **필요한 컬럼만 읽고** 파일 메타데이터(min/max)로 구간을 건너뜁니다. **데이터를 정렬해 두면 이 효과가 커집니다.** **Parquet row group 기본 128 MB·ORC stripe 기본 64 MB**이며, 컬럼이 많으면 키우는 편이 낫고 기본값보다 줄이는 것은 권장되지 않습니다. **압축 데이터는 스캔 바이트 기준 과금**이라 더 빠르고 더 쌉니다(gzip은 압축률·호환성, zstd는 균형). **압축 텍스트(JSON/CSV)는 대부분 병렬 처리가 불가**합니다.
- **버킷팅** — **카디널리티가 높은 키로 특정 값을 조회**하는 쿼리가 많을 때 유용하지만, 여러 값을 자주 조회하면 이점이 줄어듭니다.
- **작은 파일 병합** — 작은 파일이 많으면 **파일별 오버헤드와 S3 요청 한도** 때문에 느려지고 `SlowDown` 오류가 날 수 있습니다. **가장 좋은 시점은 쓰기 전에 합치는 것**입니다(쓰는 쪽에서 더 큰 파일, Glue ETL로 병합, 파티션 키 수 줄이기). **파티션 한 곳에 파일이 1,000개를 넘으면** S3 목록 연산이 여러 번 필요합니다.

### 8) 벡터화 개념과 Bedrock Knowledge Bases {#vectorization}

**벡터 임베딩은 텍스트 청크를 나타내는 숫자열(벡터)** 이며, 모델이 각 청크를 벡터로 바꿔 텍스트를 **수학적으로 비교(의미 유사도)** 할 수 있게 합니다. 벡터는 **부동소수점(float32)** 또는 **이진(binary)** 일 수 있고, **이진 벡터는 차원당 1비트**만 써 부동소수점의 32비트보다 저장 비용이 낮지만 정밀도는 낮습니다. **이진 임베딩 모델을 고르면 이진 벡터를 지원하는 벡터 스토어도 함께** 골라야 합니다.

**Bedrock Knowledge Bases 흐름** — 지식 베이스는 **RAG**를 구현하도록 돕습니다. 만들 때 **데이터 소스 커넥터·임베딩 모델·벡터 스토어**를 설정하고, 만든 뒤에는 **데이터를 sync(수집)해야 질의**할 수 있습니다.

| 구성요소 | 역할 | 시험 단서 |
|---|---|---|
| **청킹** | 문서를 조각으로 분할 — `FIXED_SIZE` / `HIERARCHICAL`(큰 층 + 파생한 작은 층) / `SEMANTIC`(NLP로 유사 내용끼리) / `NONE`(파일 하나 = 청크 하나) | "문서 분할", "청크 크기" |
| **임베딩 모델** | 청크·질의를 벡터로 변환 (Titan Embeddings G1 - Text, Titan Text Embeddings V2, Cohere Embed English/Multilingual v3, 멀티모달 모델 등) | "의미 유사도", "차원" |
| **벡터 스토어** | 임베딩을 저장·검색 — OpenSearch Serverless, Pinecone, Redis Enterprise Cloud, **RDS(Aurora)**, MongoDB Atlas, Neptune Analytics, OpenSearch Managed Cluster, S3 Vectors | "벡터 DB", "유사 청크 검색" |
| **sync(수집 작업)** | 데이터 소스 변경을 **증분** 반영 | "문서가 바뀌면 재동기화" |

- **전처리** — 데이터를 텍스트로 변환하고 **관리 가능한 청크로 나눈 뒤 임베딩으로 변환**해 **원본 문서와의 매핑을 유지한 채** 벡터 인덱스에 기록합니다.
- **런타임** — **임베딩 모델로 사용자 질의를 벡터로 바꾸고**, 벡터 인덱스에서 의미가 비슷한 청크를 찾아 **프롬프트에 추가 컨텍스트로 붙여** 응답을 생성합니다.
- **sync** — 데이터를 추가·수정·삭제할 때마다 **sync해야 다시 색인**됩니다. sync는 **증분**이라 바뀐 문서만 처리하고 삭제된 문서는 벡터 스토어에서 제거됩니다(API: `StartIngestionJob` → `GetIngestionJob`). **Aurora(RDS) 이외의 스토어는 sync 후에도 새 임베딩이 질의에 반영되기까지 몇 분 걸릴 수 있습니다.**
- ⚠️ 공지: **2026-09-30부터 customer-managed 지식 베이스에서 Confluence·SharePoint·Salesforce·Web Crawler 커넥터를 새로 만들 수 없습니다**(기존 커넥터는 계속 동작).

---

## ✍️ 시험 포인트

- "**큰 팩트 + 큰 디멘션이 자주 조인**" → **조인 열을 DISTKEY**로 colocate(또는 AUTO에 맡김). "**최근 N일 범위 조건**" → **timestamp 정렬 키**. 튜닝 인력이 없으면 **ATO**.
- "**팩트 테이블에 분산 키를 둘 이상**" 같은 보기는 **불가능**(팩트 테이블은 분산 키가 하나뿐). "**정기 갱신 + 정렬**" → **COMPOUND**(INTERLEAVED 아님).
- "**제약조건을 위반한 INSERT도 성공한다**" → Redshift의 UNIQUE·PK·FK는 **정보용**이고 **`NOT NULL`만 강제**됩니다.
- "**이미 운영 중인 테이블에 다른 파티션 키로 조회할 인덱스 추가**" → **GSI**(LSI는 테이블 생성 시에만). "**강한 일관성 필요**" → **LSI**.
- "**크롤러가 수동 수정한 스키마를 덮어쓴다**" → **"Add new columns only"**.
- "**이전 스키마로 만든 소비자가 최신 데이터를 처리해야 한다**" → **FORWARD**. "**최근 스키마로 만든 소비자가 직전 버전도 읽어야**" → **BACKWARD**(권장). 둘 다면 **FULL**. "**계약을 강제해야 한다**"에서 **NONE은 오답**(검사 없음).
- "**컬럼 이름을 바꿔야 한다**" → Parquet **인덱스 기준** 또는 ORC 기본. "**중간에 컬럼을 추가·삭제**" → Parquet 기본(이름 기준)·JSON·Avro. **CSV는 순서 변경·중간 삽입 불가.** "**재작성 없이 전부**" → **Iceberg**(메타데이터 전용 변경).
- "**설치 없이 콘솔에서 스키마 변환 + 평가 보고서**" → **DMS Schema Conversion**(데이터는 안 옮김). "**Teradata·Netezza → Redshift**", "**Cassandra → DynamoDB**" → **AWS SCT**.
- "**어떤 학습 잡·데이터셋에서 이 모델이 나왔나**" → **SageMaker ML Lineage Tracking**(artifact·action·context·association). "**Glue·Redshift 자산 흐름을 OpenLineage로**" → **SageMaker Catalog 계보**. **Lake Formation은 계보 도구가 아닙니다.**
- "**파티션이 수만 개라 관리가 부담**" → **파티션 프로젝션**(Athena 전용·sparse에 역효과). "**user_id 단일 값 조회가 잦다**" → **버킷팅**. "**작은 파일 수만 개**" → **쓰기 전에 병합**.
- "**문서를 고쳤는데 RAG 답변이 그대로다**" → **sync 미실행**. sync는 **증분**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

1. **"Redshift도 테이블을 파티셔닝한다."** → ❌. **Redshift는 객체 안의 파티셔닝 개념을 지원하지 않습니다.** 배치는 **분산 스타일**이 정합니다(S3/Athena의 `PARTITIONED BY`와 다른 세계).
2. **"작은 디멘션 테이블은 무조건 ALL."** → ❌. **colocate할 수 없는 디멘션**에는 ALL이 유효하지만, **재분산 비용이 낮은 작은 테이블은 이점이 크지 않다**고 같은 문서가 말합니다. 게다가 **저장 공간이 노드 수만큼 늘고 적재가 느려집니다.**
3. **"Redshift에 PK를 걸었으니 중복이 안 들어온다."** → ❌. **강제되지 않습니다.** 유효하지 않은 키를 선언하면 **잘못된 쿼리 결과**가 날 수 있습니다.
4. **"압축 인코딩을 한 열만 지정했으니 나머지는 계속 자동."** → ❌. **한 열이라도 지정하면 그 테이블은 `ENCODE AUTO`가 아니게 되고**, 나머지는 RAW/AZ64/LZO 규칙으로 배정됩니다.
5. **"LSI는 나중에 추가하면 된다."** → ❌. **LSI는 테이블 생성 시에만** 만들 수 있습니다. 나중에 추가하려면 **GSI**입니다.
6. **"GSI로 강하게 일관된 읽기를 한다."** → ❌. **GSI는 최종 일관성만** 지원합니다. 강한 일관성은 **LSI**입니다.
7. **"LF-Tag를 리소스 생성 시 같이 붙인다."** → ❌. **이미 존재하는 리소스에만** 추가할 수 있고, **같은 키에는 값 하나만** 지정됩니다. **IAM 태그와도 호환되지 않습니다.**
8. **"Schema Registry 호환성을 NONE으로 두면 안전하다."** → ❌. NONE은 **검사 없이 수락**이라 계약을 강제하지 못합니다. DISABLED는 반대로 **새 버전 자체가 막힙니다.**
9. **"CSV 테이블도 중간에 컬럼을 끼울 수 있다."** → ❌. **CSV/TSV는 순서 변경과 앞·중간 삽입이 불가**합니다(맨 끝 추가·이름 변경·타입 변경은 가능).
10. **"DMS로 스키마까지 한 번에 옮긴다."** → ❌. **DMS Schema Conversion은 스키마만** 변환하고 **데이터는 DMS의 데이터 마이그레이션 기능**이 옮깁니다.
11. **"Lake Formation에서 데이터 계보를 본다."** → ❌. **Lake Formation이 계보 기능을 제공한다는 공식 문서는 확인되지 않았습니다.** 계보는 **SageMaker ML Lineage Tracking / SageMaker Catalog**입니다.
12. **"Glue 잡의 계보는 자동으로 수집된다."** → ❌. **Glue 크롤러·Redshift는 기본 자동**이지만 **Glue 콘솔의 Glue 잡과 EMR은 설정이 필요**합니다.
13. **"파티션을 잘게 쪼갤수록 빠르다."** → ❌. 키가 너무 많으면 **작은 파일이 늘어** 오히려 느려집니다. **가장 흔한 쿼리에 맞추고**, 짧은 구간 쿼리는 **정렬**로도 해결됩니다.
14. **"`MSCK REPAIR TABLE`이면 파티션 관리가 끝난다."** → ❌. 느릴 수 있고 **새 파티션만 추가**하며 **오래된 파티션은 제거하지 않습니다.** Hive 스타일 경로에서만 동작하고 **경로가 대문자를 섞으면 추가에 실패**합니다.
15. **"원본 문서를 고치면 지식 베이스가 알아서 재색인한다."** → ❌. **sync를 실행해야** 다시 색인됩니다(증분). Aurora 외 스토어는 반영까지 **몇 분** 걸릴 수 있습니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (문항 뱅크는 `dea-t2-4.questions.json` — 사람 검수 전이라 사이트에는 노출되지 않습니다)

**Q1.** Redshift에서 큰 팩트 테이블이 큰 디멘션 테이블과 `customer_id`로 자주 조인되고, 쿼리 대부분이 최근 30일 범위 조건을 씁니다. 어떻게 설계하나요?

<details><summary>정답 보기</summary>

**조인 열(`customer_id`)을 분산 키로 지정(DISTSTYLE KEY)해 colocate**하고, **날짜 열을 정렬 키 선두**에 둡니다. 정렬하면 1 MB 블록의 min/max 메타데이터로 범위 조건에서 블록을 대거 건너뜁니다. 정기 갱신이 있으면 **COMPOUND**(기본값)가 권장됩니다. 튜닝 인력이 부족하면 **AUTO + ATO**에 맡기는 선택지도 있습니다. 큰 테이블에 ALL은 **저장 공간이 노드 수만큼 늘고 적재가 느려져** 부적합하고, EVEN은 colocation이 없습니다.
</details>

**Q2.** 스트리밍 프로듀서가 스키마에 필드를 추가하려 합니다. **이미 배포된(이전 스키마로 만든) 컨슈머들이 새 데이터를 계속 처리**해야 합니다. Glue Schema Registry 호환성 모드는?

<details><summary>정답 보기</summary>

**FORWARD**입니다. FORWARD는 **현재 버전과 다음(이후) 버전**을 소비자가 읽게 해 주며, 허용되는 변경이 **필드 추가와 선택 필드 삭제**입니다. 반대로 BACKWARD는 **최신 스키마로 만든 소비자가 직전 버전도 읽는** 방향이고(필드 삭제·선택 필드 추가), 둘 다 필요하면 FULL(선택 필드만 추가/삭제)입니다. **NONE은 검사 자체를 하지 않아** 계약 강제가 안 됩니다.
</details>

**Q3.** S3의 Parquet 테이블에서 **컬럼 이름을 바꿔야** 합니다. 기존 Athena 쿼리는 그대로 쓰고 데이터는 다시 쓰고 싶지 않습니다.

<details><summary>정답 보기</summary>

Parquet의 **기본은 이름 기준 접근이라 이름 변경이 불가**합니다. `parquet.column.index.access` SerDe 속성으로 **인덱스 기준으로 전환**하면 이름 변경이 가능해지지만, 대신 **중간 컬럼 추가·삭제·순서 변경은 불가**가 됩니다. 추가·삭제·이름 변경·순서 변경·타입 확장을 모두 **데이터 파일 재작성 없이** 처리하려면 **Apache Iceberg 테이블**이 답입니다(스키마 업데이트가 메타데이터 전용 변경).
</details>

**Q4.** 배포된 추천 모델이 **어떤 학습 잡과 어떤 S3 데이터셋에서 나왔는지** 감사 목적으로 추적해야 합니다.

<details><summary>정답 보기</summary>

**Amazon SageMaker ML Lineage Tracking**입니다. SageMaker AI는 학습·처리·배치 변환 잡을 만들면 **tracking entity를 자동 생성**하고, **artifact**(S3 URI 등 입력·출력)·**action**(활동)·**context**(논리적 묶음)·**association**(연결)으로 워크플로를 표현해 모델 거버넌스·재현성에 씁니다. Glue·Redshift **데이터 자산**의 흐름을 OpenLineage 호환으로 보는 것은 **SageMaker Catalog 데이터 계보**이고, **Lake Formation의 LF-Tag는 권한 속성이지 계보가 아닙니다.**
</details>

**Q5.** 사내 문서를 Bedrock Knowledge Base로 RAG에 쓰고 있습니다. 원본 문서 수십 개를 수정했는데 답변이 예전 내용 그대로입니다.

<details><summary>정답 보기</summary>

**데이터 소스를 sync(`StartIngestionJob`)해야 다시 색인됩니다.** 데이터를 추가·수정·삭제할 때마다 sync가 필요하고, sync는 **증분이라 바뀐 문서만 재처리**(파싱·청킹·임베딩 생성·색인)하며 삭제된 문서는 벡터 스토어에서 제거됩니다. 또 **Aurora(RDS) 이외의 벡터 스토어는 sync가 끝난 뒤에도 새 임베딩이 질의에 반영되기까지 몇 분 걸릴 수 있습니다.**
</details>

---

**Q6 (원리).** 왜 DynamoDB는 "정규화부터" 하지 않고 **액세스 패턴부터** 설계할까요?

<details><summary>정답 보기</summary>

**RDBMS는 조인으로 쿼리 시점에 데이터를 재구성하지만, DynamoDB는 그 재구성을 하지 않기 때문입니다.** 그래서 데이터의 모양 자체를 **미리 쿼리에 맞춰 조직**해 두어야 하고, 공식 문서도 첫 단계를 **"시스템이 만족해야 할 쿼리 패턴 식별"** 로 못박습니다. 이것이 "**테이블은 가능한 한 적게**"(단일 테이블)라는 일반 원칙으로 이어지고, 필요한 쿼리마다 **GSI**를 두는 설계가 따라옵니다. 대용량 시계열이나 액세스 패턴이 아주 다른 데이터셋은 예외입니다. 같은 이유로 **파티션 키 카디널리티**가 성능 설계의 중심이 됩니다 — 쿼리가 파티션에 고르게 퍼져야 파티션당 한도(읽기 3,000·쓰기 1,000 단위/초)에 먼저 걸리지 않습니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. Distribution styles (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_choosing_dist_sort.html
2. Choose the best distribution style (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html
3. Sort keys (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_Sorting_data.html
4. Automatic table optimization (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_Creating_tables.html
5. Compression encodings (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_Compression_encodings.html
6. Table constraints (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/t_Defining_constraints.html
7. ALTER TABLE (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_ALTER_TABLE.html
8. NoSQL design for DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-general-nosql-design.html
9. Best practices for designing and using partition keys effectively in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html
10. DynamoDB overview (AWS Prescriptive Guidance, RDBMS to DynamoDB) — https://docs.aws.amazon.com/prescriptive-guidance/latest/modernization-rdbms-dynamodb/overview.html
11. Improving data access with secondary indexes in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html
12. Using Global Secondary Indexes in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html
13. Local secondary indexes (DynamoDB) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/LSI.html
14. Lake Formation tag-based access control — https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
15. Lake Formation tag-based access control best practices and considerations — https://docs.aws.amazon.com/lake-formation/latest/dg/lf-tag-considerations.html
16. How do I configure the AWS Glue crawler to manage schema changes? — https://repost.aws/knowledge-center/glue-configure-crawler-schema-changes
17. AWS Glue Schema registry — https://docs.aws.amazon.com/glue/latest/dg/schema-registry.html
18. Evolve Iceberg table schema (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/querying-iceberg-evolving-table-schema.html
19. Handle schema updates (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/handling-schema-updates-chapter.html
20. Task settings for change processing DDL handling (AWS DMS) — https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.DDLHandling.html
21. Converting database schemas using DMS Schema Conversion — https://docs.aws.amazon.com/dms/latest/userguide/CHAP_SchemaConversion.html
22. What is the AWS Schema Conversion Tool? — https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html
23. Installing and Configuring AWS Schema Conversion Tool — https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Installing.html
24. DEA-C01 시험 가이드 — In-Scope AWS Services — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
25. DEA-C01 시험 가이드 — Revisions (v1.1 변경 이력) — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html
26. Lineage Tracking Entities (Amazon SageMaker AI) — https://docs.aws.amazon.com/sagemaker/latest/dg/lineage-tracking-entities.html
27. Data lineage in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/datazone-data-lineage.html
28. Data lineage support matrix (Amazon SageMaker Unified Studio) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/datazone-support-matrix.html
29. Data lineage support (Amazon SageMaker Unified Studio) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/datazone-data-lineage-support.html
30. Amazon SageMaker and when to use Amazon SageMaker vs Amazon DataZone — https://docs.aws.amazon.com/datazone/latest/userguide/sagemaker-datazone.html
31. Optimize data (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/performance-tuning-data-optimization-techniques.html
32. Partition your data (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/partitions.html
33. How Amazon Bedrock knowledge bases work — https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html
34. Supported models and Regions for Amazon Bedrock knowledge bases — https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-supported.html
35. StorageConfiguration (Amazon Bedrock API Reference) — https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent_StorageConfiguration.html
36. ChunkingConfiguration (Amazon Bedrock API Reference) — https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent_ChunkingConfiguration.html
37. Sync your data with your Amazon Bedrock knowledge base — https://docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html
38. Connect a data source to your knowledge base (Amazon Bedrock) — https://docs.aws.amazon.com/bedrock/latest/userguide/data-source-connectors.html
39. DEA-C01 공식 시험 가이드 도메인 2 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html
