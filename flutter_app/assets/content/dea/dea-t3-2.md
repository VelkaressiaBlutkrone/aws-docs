---
examGuideTaskId: dea-t3-2
certCode: DEA-C01
domain: 3
domainName: 데이터 운영 및 지원
domainWeightPct: 22
title: 데이터 분석 (시각화·정리·뷰·Spark 노트북·SQL 집계)
coversTasks:
  - "3.2"
sources:
  - title: What is AWS Glue DataBrew? (공식 문서)
    url: https://docs.aws.amazon.com/databrew/latest/dg/what-is.html
  - title: What is Amazon Quick? (공식 문서)
    url: https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
  - title: Importing data into SPICE (공식 문서)
    url: https://docs.aws.amazon.com/quick/latest/userguide/spice.html
  - title: Views (Amazon Athena) (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/views.html
  - title: Materialized views in Amazon Redshift (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html
  - title: Using Apache Spark in Amazon Athena (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark.html
  - title: Window functions (Amazon Redshift) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/c_Window_functions.html
  - title: DEA-C01 공식 시험 가이드 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
lastVerified: 2026-10-20
---

# 데이터 분석 (시각화·정리·뷰·Spark 노트북·SQL 집계)

> **커버하는 공식 Task** — DEA-C01 · 도메인 3 「데이터 운영 및 지원」(22%) · **Task 3.2 AWS 서비스를 사용하여 데이터 분석** (`dea-t3-2`)
> Skill 6개. 서비스 운영이 아니라 **"분석가가 쓰는 도구와 SQL 개념"** 을 묻는 Task입니다.
> **Skill 3.2.3은 v1.1 개정** — v1.0의 "Athena로 쿼리·뷰 만들기"에 **Amazon Redshift가 추가**됐습니다. Redshift 뷰·구체화된 뷰의 비중을 높게 잡으세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.2의 Skill 항목)

- [ ] **DataBrew와 Amazon Quick(Quick Sight)** 이 각각 무엇을 하는 도구인지 구분한다
- [ ] **SPICE와 직접 쿼리**의 차이, 새로 고침 방식과 제약을 설명한다
- [ ] **Lambda·Athena CTAS·Quick 데이터 준비·Data Wrangler** 중 데이터 확인·정리 수단을 상황에 맞게 고른다
- [ ] **뷰 · 구체화된 뷰 · Glue Data Catalog 뷰 · CTAS** 를 요구사항으로 가른다
- [ ] Redshift의 **late-binding 뷰(WITH NO SCHEMA BINDING)** 가 왜 필요한지 안다
- [ ] Athena의 **Spark 활성 워크그룹·노트북** 절차와 **두 릴리스 버전**의 차이를 안다
- [ ] 서비스별 **서버리스 vs 프로비저닝/예약**의 교환을 설명한다
- [ ] **GROUP BY와 윈도 함수**의 차이, **롤링 평균·ROLLUP/CUBE/GROUPING SETS·PIVOT** 을 구분한다

---

## 🎯 왜 중요한가

- Task 3.2의 문항은 **"같은 일을 할 수 있는 네 가지 객체 중 무엇인가"** 로 자주 나옵니다. 뷰·구체화된 뷰·Data Catalog 뷰·CTAS는 모두 "쿼리 결과를 다시 쓰는" 방법이지만 **저장되는 것과 최신성이 다릅니다.**
- **v1.1 개정으로 Redshift가 Skill 3.2.3에 들어왔습니다.** Athena만 보고 넘어가면 구체화된 뷰·late-binding 뷰 문항에서 막힙니다.
- SQL 개념(3.2.6)은 **행이 줄어드는가 아닌가** 한 줄로 갈립니다. "각 행에 이동 평균을 붙여라"는 GROUP BY로 풀 수 없습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **SPICE** | SPICE | Quick Sight의 인메모리 분석 엔진 — 데이터를 가져와(ingest) 두고 빠르게 조회 |
| **직접 쿼리** | direct query | 조회할 때마다 원본 데이터 소스에 질의하는 방식 |
| **구체화된 뷰** | materialized view | 쿼리 결과를 실제로 저장해 두는 데이터베이스 객체 |
| **late-binding 뷰** | late-binding view | 기반 객체와 의존성을 맺지 않는 Redshift 뷰 |
| **CTAS** | create table as select | SELECT 결과로 새 테이블을 만드는 문장 |
| **DPU** | data processing unit | Athena 용량 예약의 컴퓨트·메모리 단위 |
| **윈도 함수** | window function | 행을 줄이지 않고 각 행 옆에 계산값을 붙이는 함수 |
| **프레임** | window frame | 윈도 함수가 어느 범위의 행을 보고 계산할지 정하는 절 |
| **롤링 평균** | rolling average | 최근 N개 행처럼 움직이는 구간의 평균 |
| **피벗** | pivot | 행 값을 열로 돌려 long 형식을 wide 형식으로 바꾸는 것 |

---

## 📖 핵심 개념

### 1) 데이터 시각화 — DataBrew와 Amazon Quick(Quick Sight) {#visualize}

**AWS Glue DataBrew** 는 코드 없이 데이터를 정리·정규화하는 **시각적 데이터 준비 도구**입니다. 프로젝트 워크스페이스에서 데이터를 격자형 인터페이스로 보며 **값 분포와 차트로 프로파일을 파악**하고, **250개가 넘는 사전 제작 변환**을 클릭으로 적용하며, 변환 단계를 **레시피**로 저장해 다른 데이터셋에 재사용합니다. **서버리스**라 클러스터를 만들거나 인프라를 관리하지 않습니다.

**Amazon Quick과 Quick Sight — 이름이 바뀌었습니다.** 공식 문서는 **Amazon Quick이 Amazon QuickSight에서 진화했고, QuickSight는 Quick 안의 기능인 Amazon Quick Sight로 계속되며, 기존 QuickSight API·SDK·통합은 변경 없이 동작**한다고 설명합니다. 시험 가이드 Skill 문구는 아직 "Amazon QuickSight"를 쓰므로, **보기 표기가 QuickSight여도 같은 BI 기능으로 취급**하세요.

**SPICE vs 직접 쿼리**

- 데이터셋을 만들거나 편집할 때 **SPICE 또는 직접 쿼리 중 하나**를 고릅니다(업로드한 파일 데이터셋은 예외).
- SPICE(인메모리 엔진)로 **가져오면(ingest)** 분석 쿼리가 더 빨리 처리되고 직접 쿼리를 기다릴 필요가 없습니다. **쿼리당 과금되는 데이터 소스라도 SPICE에서는 데이터셋을 처음 만들 때와 새로 고칠 때만 쿼리 비용**이 듭니다.
- **SPICE 용량은 리전별로 따로 할당**되고 한 리전의 같은 AWS 계정 사용자들이 공유하며, 관리자가 용량을 더 구매하거나 미사용분을 반납합니다.

**새로 고침** — SPICE 데이터셋은 **전체 새로 고침이 기본**이고, Redshift·Athena·PostgreSQL·Snowflake 같은 **SQL 기반 소스는 look-back 윈도우 안에서만 증분 새로 고침**을 할 수 있습니다. ⚠️ **데이터베이스 스키마가 바뀌면 Quick Sight가 자동으로 감지하지 못해 ingestion이 실패**하므로, 데이터셋을 편집·저장해 스키마를 갱신해야 합니다.

**과금 구조** — aws.com/quick에서 가입(Free·Plus 플랜)하거나 AWS 콘솔로 프로비저닝(IAM Identity Center 또는 IAM Federation, **사용자별 구독**, 표준 AWS 청구)합니다. **SPICE 용량은 별도로 구매·반납하는 자원**입니다. 사용자 유형별 단가 숫자는 자료마다 달라 이 문서에서는 다루지 않습니다 — **요금 단가를 묻는 문항은 피하세요.**

### 2) 데이터 확인·정리 도구 {#verify-clean}

| 도구 | 적합한 경우 | 제약·특성 | 시험 단서 |
|---|---|---|---|
| **AWS Glue DataBrew** | 코드 없이 시각적으로 정리·정규화, 레시피 재사용 | 250개 넘는 변환, 서버리스 | "코드 없이", "레시피" |
| **Quick Sight 데이터 준비** | BI 데이터셋을 만들기 전 단계별 변환 | **열한 가지 단계 유형**을 순서대로 조합, SQL 전문성 불필요 | "SQL 없이 데이터셋 변환" |
| **SageMaker Data Wrangler** | ML용 데이터 import·변환·featurize·분석 | **SageMaker Canvas로 통합됨**(원래 Studio Classic 기능), 자연어 인터페이스 추가 | "ML 데이터 준비", "Canvas" |
| **Athena CTAS/SQL** | S3 데이터를 SQL로 정리해 새 테이블·포맷으로 저장 | 결과 파일은 S3 지정 위치 | "쿼리 결과로 새 테이블" |
| **AWS Lambda** | S3 객체 생성·삭제 이벤트로 검증·정리 코드 실행 | **같은 버킷에 쓰면 재귀 호출 루프** | "업로드되면 자동 검증" |
| **Jupyter 계열 노트북** | 대화형 탐색·정제 | Athena 콘솔 노트북은 PySpark engine v3 한정 | "노트북" |

- **Lambda 재귀 주의** — S3는 객체가 생성·삭제될 때 Lambda 이벤트 함수로 이벤트를 보낼 수 있습니다. 그런데 **트리거한 버킷과 같은 버킷에 함수가 다시 객체를 쓰면 함수가 스스로를 재호출하는 루프**가 생깁니다. 버킷을 둘로 나누거나 수신 객체용 **프리픽스에만 트리거**를 거세요.
- **Athena CTAS** — 다른 쿼리의 SELECT 결과로 새 테이블을 만들고 데이터 파일을 S3의 지정 위치에 저장합니다. ① 원본을 반복 조회하지 않고 **한 번에 테이블 생성**, ② 결과를 **Parquet·ORC 같은 저장 형식(또는 Iceberg)으로 변환**, ③ 필요한 데이터만 담은 **테이블 사본 생성** 에 씁니다.

### 3) Redshift·Athena SQL로 쿼리·뷰 만들기 (v1.1 개정) {#views}

| 구분 | 저장되는 것 | 데이터 최신성 | 적합한 경우 |
|---|---|---|---|
| **뷰**(Redshift·Athena) | **쿼리 정의만**(논리 테이블) | 참조할 때마다 정의 쿼리 실행 | 복잡성 숨기기, 조회 단순화 |
| **Redshift 구체화된 뷰** | **사전 계산된 결과 집합** | 새로 고침 전까지 그대로 | 반복되는 무거운 집계·대시보드 |
| **Glue Data Catalog 뷰** | 정의가 **Glue Data Catalog에 저장**, Athena·Redshift 공용 | 참조할 때마다 실행 | 엔진 간 공통 뷰 + Lake Formation 권한 |
| **Athena CTAS** | 쿼리 결과를 담은 **새 테이블 파일(S3)** | 실행 시점의 결과 | 변환 결과를 Parquet·ORC·Iceberg로 저장 |

**Redshift 뷰** — 물리적으로 구체화되지 않으며 뷰를 정의한 쿼리가 **참조될 때마다 실행**됩니다. 외부 테이블로 뷰를 만들려면 **`WITH NO SCHEMA BINDING`(late-binding 뷰)** 을 씁니다. late-binding 뷰는 기반 객체(테이블·UDF 등)에 **바인딩되지 않아 의존성이 없고**, Redshift는 뷰를 쿼리할 때까지 의존성을 확인하지 않으며, **참조 객체가 없어도 뷰를 만들 수 있고, 참조 객체를 삭제·변경해도 뷰에 영향이 없습니다.**

**Redshift 구체화된 뷰(MV)** — 쿼리 결과를 저장하는 데이터베이스 객체로, 사전 계산된 결과 집합을 돌려주므로 기반 테이블에 접근하지 않아 **훨씬 빠릅니다**. **예측 가능하고 반복되는 쿼리**(대시보드를 채우는 쿼리 등)에 특히 유용합니다.

- MV의 내용은 **만든 시점의 상태**이며 기반 테이블이 바뀌어도 그대로입니다. `REFRESH MATERIALIZED VIEW` 로 수동 새로 고침하거나 **autorefresh**를 켭니다.
- 새로 고침 방식은 **가능하면 증분(incremental), 불가능하면 전체(full)** 이며 **어느 쪽을 쓸지는 Redshift가 MV 정의 SELECT에 따라 자동 선택**합니다.
- autorefresh는 기반 테이블 변경 후 가능한 한 빨리 반영하지만 **사용자 워크로드를 우선해 멈추거나 지연될 수 있어**, 결정적 동작이 필요하면 **수동 또는 스케줄 새로 고침**을 고려합니다.

**Athena 뷰** — 뷰는 **물리 테이블이 아닌 논리 테이블**이며 정의 쿼리가 참조될 때마다 실행됩니다. Athena에는 **두 종류**가 있습니다.

- **Athena 뷰** — 데이터 일부만 조회, 여러 테이블 결합(UNION ALL), 복잡성 숨기기, 쿼리 최적화 실험, 하위 테이블·열 이름 숨기기에 씁니다.
- **AWS Glue Data Catalog 뷰** — **Athena와 Redshift 같은 여러 AWS 서비스에 걸친 하나의 공통 뷰**입니다. 접근 권한이 **뷰를 조회하는 사용자가 아니라 만든 사용자 기준(definer semantics)** 으로 정해지고, 정의가 **Glue Data Catalog에 저장**되므로 **Lake Formation의 리소스·열 grant나 태그 기반 접근 제어**로 권한을 줄 수 있습니다.

> ⚠️ **최신성 함정** — Redshift 문서 상단에 **"Amazon Redshift는 2026년 6월 30일 이후 Python UDF를 지원하지 않는다"** 는 공지가 있습니다. Redshift 뷰·변환 로직을 고르는 문항에서 **Python UDF에 의존하는 선택지**를 경계하세요.

### 4) Athena 노트북과 Apache Spark {#athena-spark}

Amazon Athena는 **리소스를 계획·구성·관리하지 않고** Apache Spark로 데이터를 대화형으로 분석·탐색하게 해 줍니다. Athena 위의 Spark는 **서버리스이며 자동 on-demand 스케일링**을 제공합니다.

**⚠️ 릴리스 버전이 둘입니다 — 문항이 어느 쪽을 전제하는지부터 보세요.**

| 구분 | Athena SQL | **PySpark engine version 3**(이전) | **Apache Spark version 3.5**(현재) |
|---|---|---|---|
| 워크그룹·에디터 | Athena SQL 워크그룹, **쿼리 에디터** | **Spark 활성 워크그룹, 노트북 에디터**(쿼리 에디터 불가) | SageMaker Unified Studio 노트북 또는 **Spark Connect 클라이언트** |
| 노트북 | — | **Athena 콘솔 노트북**(Jupyter 호환) | **Athena 콘솔 노트북·노트북 API 미지원** |
| 용량·확장 | **용량 예약(DPU)** 으로 전용 용량 확보 가능 | 자동 on-demand 스케일링 | 자동 on-demand 스케일링 |
| 수명 | — | **2027-04-01 수명 종료** | 현재 버전 |

- **시작 절차(PySpark engine version 3)** — 먼저 **Spark 엔진을 쓰는 Spark 활성 워크그룹을 만듭니다.** 노트북을 열면 **새 세션이 자동으로 시작**됩니다. Spark 활성 워크그룹은 노트북 에디터를 쓸 수 있지만 **쿼리 에디터는 쓸 수 없고**, 쿼리 에디터는 Athena SQL 워크그룹 전용입니다. **노트북을 만들기 전에 워크그룹부터** 만들어야 합니다.
- **PySpark engine version 3 워크그룹은 Apache Spark 3.5로 업그레이드할 수 없습니다.**
- **용량 모델** — Athena SQL은 **용량 예약**으로 전용 서버리스 처리 용량(**DPU**)을 확보할 수 있습니다. **DPU 하나는 보통 4 vCPU와 16 GB 메모리**입니다. Spark는 필요한 컴퓨트·메모리를 Athena가 자동 결정해 확장합니다.

### 5) 프로비저닝 vs 서버리스 트레이드오프 {#serverless-tradeoff}

공통 원칙은 하나입니다. **서버리스는 용량 계획·운영 부담을 줄이고 변동 부하에 자동으로 맞추는 대신, 예측 가능하고 꾸준한 부하에서는 프로비저닝·예약이 비용과 제어에서 앞섭니다.**

| 서비스 | 서버리스·온디맨드가 맞는 경우 | 프로비저닝·예약이 맞는 경우 | 요금·제약 |
|---|---|---|---|
| **Amazon Redshift** | 클러스터 설정·튜닝·관리를 피하고 예측 불가 워크로드를 자동 확장 | 꾸준히 쓸 때는 **reservation**으로 할인 | on-demand = 쓴 만큼, reservation = 기간 약정 할인, **저장소는 컴퓨트와 별도 과금** |
| **Amazon EMR** | 클러스터 운영 없이 Spark/Hive, **과소·과대 프로비저닝 회피** | 클러스터를 직접 구성·운영하는 EMR | 필요 리소스를 자동 결정·해제, **대화형은 사전 초기화** |
| **Kinesis Data Streams** | 용량 계획 불필요, 변동·예측 불가 트래픽 | **예측 가능 트래픽·세밀한 샤드 제어** | on-demand = 기록·조회 **GB 단위 과금**, provisioned = **샤드 수 직접 지정** |
| **Amazon Athena** | 리소스 계획·구성·관리가 없는 서버리스 | **용량 예약(DPU)** 으로 워크로드 격리·예측 가능한 성능 | 예약 용량에서 도는 쿼리는 **DDL·DML 쿼리 할당량에 포함되지 않음** |

- **Redshift Serverless** — 데이터 웨어하우스 용량을 자동 프로비저닝하고 기반 리소스를 지능적으로 확장하며 **용량을 초 단위로 조정**합니다. 컴퓨트는 **on-demand**(쓴 만큼, 사용 패턴을 모르는 초기에 적합)와 **reservation**(미리 정한 컴퓨트를 일정 기간 구매해 할인) 중에서 고르며 **둘을 함께 쓸 수 있습니다.**
- **Kinesis Data Streams 용량 모드** — **On-demand Standard · On-demand Advantage · Provisioned** 가 있습니다. On-demand는 **이전 30일 동안 관측한 최대 쓰기 처리량의 두 배까지** 수용합니다. ⚠️ **파티션 키가 매우 불균등하면 granular shard split을 지원하는 provisioned 모드가 권장**됩니다 — "예측 불가 = 무조건 on-demand"가 아닙니다. On-demand Advantage는 **계정 수준 설정**입니다.

### 6) 집계·롤링 평균·그룹화·피벗 {#sql-concepts}

| 개념 | 핵심 동작 | 구문 | 시험 단서 |
|---|---|---|---|
| **그룹화·집계** | 행을 그룹으로 묶어 **그룹당 한 행** 반환 | `GROUP BY` + 집계 함수, `HAVING` 은 **집계 후** 필터 | "그룹별 합계" |
| **소계·교차 집계** | 한 문장에 여러 GROUP BY | `GROUPING SETS` / `CUBE` / `ROLLUP` | "소계", "모든 조합" |
| **롤링(이동) 평균** | **모든 행을 유지**하며 프레임 범위로 평균 | `AVG() OVER (ORDER BY …, ROWS 프레임)` | "이동 평균", "최근 N행" |
| **피벗** | 행 값을 열로 회전(long→wide) | Redshift `PIVOT`/`UNPIVOT`, Quick 데이터 준비의 Pivot 단계 | "행을 열로" |

- **그룹 함수와 윈도 함수의 결정적 차이** — **그룹 함수는 결과 행을 집계해 줄이고, 윈도 함수는 모든 행을 유지**합니다. Athena에서 `GROUP BY` 를 쓰면 SELECT의 모든 출력 식은 집계 함수이거나 GROUP BY 절에 있는 열이어야 하고, `HAVING` 은 **그룹과 집계가 계산된 뒤에** 그룹을 걸러냅니다.
- **GROUPING SETS·CUBE·ROLLUP** — 한 문장으로 여러 GROUP BY 연산을 수행하는 집계 확장입니다. **GROUPING SETS**는 그룹화할 여러 열 목록을 지정하고, **CUBE**는 주어진 열 집합의 **가능한 모든 그룹화 조합**을, **ROLLUP**은 **가능한 모든 소계**를 만듭니다. 이런 복합 그룹화는 **표현식이 아니라 열 이름만** 허용합니다.
- **윈도 함수와 롤링 평균** — 윈도 함수는 결과 집합의 파티션("윈도")에 대해 계산하되 **윈도의 모든 행에 값을 돌려줍니다.** `OVER` 명세는 **PARTITION BY**(그룹 나누기, GROUP BY와 비슷)·**ORDER BY**(순서)·**윈도 프레임**(ROWS 명세)으로 이루어집니다. **윈도 함수는 쿼리의 마지막 연산**이라 select list나 ORDER BY 절에서만 쓸 수 있고, **OVER 절은 필수**입니다. 집계 함수에 ORDER BY를 쓰면 **명시적 프레임 절이 필요**하며, Redshift 문서는 날짜별 판매 수량의 **rolling average 예제**를 제공합니다.
- **피벗** — Redshift의 **`PIVOT`·`UNPIVOT`** 은 **FROM 절의 파라미터**로 쿼리 출력을 행→열, 열→행으로 회전합니다. Quick Sight 데이터 준비의 **Pivot 단계**는 행 값을 고유 열로 바꿔 long 형식을 wide 형식으로 만듭니다. ⚠️ **Athena SELECT 레퍼런스에는 PIVOT 절 설명이 없습니다** — "Athena에서 피벗하는 방법"을 정답 근거로 삼지 마세요.

---

## ✍️ 시험 포인트

1. **네 객체 중 무엇인가** — "반복되는 무거운 집계를 빠르게" → **Redshift 구체화된 뷰**. "복잡한 쿼리를 숨긴 단순 조회 객체" → **일반 뷰**. "Athena와 Redshift가 같은 뷰를 쓰고 Lake Formation으로 권한 관리" → **Glue Data Catalog 뷰**. "쿼리 결과를 Parquet 테이블로 저장" → **Athena CTAS**.
2. **SPICE가 답인 신호** — "쿼리당 과금되는 소스", "같은 대시보드를 수백 명이 반복 조회", "응답이 느림". SPICE는 생성·새로 고침 때만 소스를 조회합니다.
3. **Athena Spark 절차 순서** — **워크그룹이 먼저, 노트북이 나중**입니다. 그리고 **Spark 활성 워크그룹에서는 쿼리 에디터를 쓸 수 없습니다.** 버전 업그레이드(v3 → 3.5)는 **불가**합니다.
4. **서버리스 = 항상 정답이 아님** — Kinesis에서 **파티션 키가 매우 불균등**하면 granular shard split이 되는 **provisioned**가 권장됩니다. Redshift도 **꾸준한 사용**이면 reservation입니다.
5. **행이 줄어드는가** — "각 행 옆에 최근 N일 평균" 은 **윈도 함수**입니다. GROUP BY는 행을 줄이므로 답이 될 수 없습니다. "소계" 는 ROLLUP, "모든 조합" 은 CUBE.

---

## ⚠️ 흔한 함정

1. **뷰로 반복 쿼리를 가속하려 함** — 일반 뷰는 **참조할 때마다 정의 쿼리를 다시 실행**합니다. 가속은 구체화된 뷰입니다.
2. **구체화된 뷰가 항상 최신이라고 가정** — 새로 고침 전까지 **기반 테이블 변경이 반영되지 않습니다.**
3. **autorefresh를 결정적 갱신으로 착각** — 사용자 워크로드가 우선이라 **멈추거나 지연될 수 있습니다.**
4. **증분/전체 새로 고침을 사용자가 고른다고 생각** — **Redshift가 MV 정의 SELECT에 따라 자동 선택**합니다.
5. **late-binding 뷰를 "성능 뷰"로 오해** — 목적은 **의존성 끊기**(외부 테이블 참조, 참조 객체 삭제·변경에도 뷰 유지)이지 속도가 아닙니다.
6. **Athena 뷰와 Glue Data Catalog 뷰 혼동** — 여러 서비스 공통 + Lake Formation 권한 + **definer semantics**는 Data Catalog 뷰입니다.
7. **CTAS를 뷰처럼 생각** — CTAS는 **실행 시점 결과를 S3에 저장**할 뿐 자동으로 갱신되지 않습니다.
8. **SPICE와 직접 쿼리를 둘 다 켤 수 있다고 생각** — 데이터셋 생성·편집 시 **둘 중 하나**를 고릅니다(업로드 파일 데이터셋 제외).
9. **SPICE 증분 새로 고침이 모든 소스에 된다고 가정** — **SQL 기반 소스의 look-back 윈도우 안**에서만 가능합니다.
10. **스키마 변경 후 ingestion 실패를 소스 장애로 오진** — **Quick Sight가 스키마 변경을 자동 감지하지 못합니다.** 데이터셋을 편집·저장해 갱신해야 합니다.
11. **QuickSight라는 이름만 보고 "없어진 서비스"로 판단** — **Quick 안의 Quick Sight 기능**으로 계속되며 기존 API·SDK는 그대로 동작합니다.
12. **Lambda 정리 결과를 트리거한 버킷에 쓰기** — **재귀 호출 루프**가 생깁니다. 버킷 분리 또는 프리픽스 제한.
13. **Data Wrangler를 독립 서비스로 기억** — 현재는 **SageMaker Canvas 안의 기능**입니다.
14. **Spark 활성 워크그룹에서 쿼리 에디터를 찾음** — 쿼리 에디터는 **Athena SQL 워크그룹 전용**입니다.
15. **engine v3 워크그룹을 3.5로 업그레이드하려 함** — **불가**합니다. 새 워크그룹을 만들어야 합니다.
16. **Spark 3.5에서 Athena 콘솔 노트북을 쓰려 함** — 3.5는 **콘솔 노트북·노트북 API를 지원하지 않습니다.** SageMaker Unified Studio 노트북 또는 Spark Connect 클라이언트를 씁니다.
17. **"예측 불가 트래픽 = 무조건 on-demand"** — **파티션 키가 매우 불균등**하면 provisioned가 권장됩니다.
18. **Redshift Serverless에서 저장소가 컴퓨트에 포함된다고 생각** — **저장소는 별도 과금**입니다.
19. **GROUP BY로 이동 평균 만들기** — GROUP BY는 행을 줄입니다. 각 행에 값을 붙이려면 **윈도 함수**입니다.
20. **윈도 함수를 WHERE 절에 사용** — 윈도 함수는 **쿼리의 마지막 연산**이라 select list·ORDER BY에서만 쓸 수 있습니다.
21. **ORDER BY만 쓰고 프레임을 생략** — 집계 함수에 ORDER BY를 쓰면 **명시적 프레임 절이 필요**합니다.
22. **ROLLUP과 CUBE 혼동** — ROLLUP은 **소계**, CUBE는 **가능한 모든 그룹화 조합**입니다.
23. **Athena에서 PIVOT 절을 찾음** — Athena SELECT 레퍼런스에는 **PIVOT 절 설명이 없습니다.** 피벗은 Redshift PIVOT/UNPIVOT 또는 Quick 데이터 준비의 Pivot 단계로 다루세요.

---

## 🧪 자가 점검

**Q1.** 수백 명이 같은 Quick Sight 대시보드를 하루 종일 열어 본다. 데이터 소스는 쿼리당 과금되는 Athena이고, 대시보드 응답이 느리며 쿼리 비용이 계속 늘고 있다. 어떻게 해야 하는가?

<details><summary>정답 보기</summary>

**데이터셋을 SPICE로 가져오고(ingest) 필요한 주기로 새로 고칩니다.** SPICE로 가져오면 분석 쿼리가 더 빨리 처리되고 직접 쿼리를 기다릴 필요가 없으며, **쿼리당 과금되는 소스라도 데이터셋을 만들 때와 새로 고칠 때만 쿼리 비용**이 듭니다. SPICE 용량은 리전별로 할당되며 관리자가 추가 구매·반납합니다.
</details>

**Q2.** Amazon Athena와 Amazon Redshift 양쪽에서 같은 뷰 정의를 쓰고, 뷰를 조회하는 사용자에게 기반 테이블 권한을 주지 않은 채 Lake Formation으로 권한을 관리하려 한다. 무엇을 만들어야 하는가?

<details><summary>정답 보기</summary>

**AWS Glue Data Catalog 뷰**입니다. Athena·Redshift 같은 여러 AWS 서비스에 걸친 하나의 공통 뷰이며, 접근 권한이 **뷰를 만든 사용자 기준(definer semantics)** 으로 정해집니다. 정의가 Glue Data Catalog에 저장되므로 Lake Formation의 리소스·열 grant나 태그 기반 접근 제어로 권한을 줄 수 있습니다. Athena 뷰는 Athena 안에서만 동작합니다.
</details>

**Q3.** Redshift Spectrum 외부 테이블을 참조하는 뷰를 만들려는데 생성이 실패한다. 또한 기반 외부 테이블을 가끔 삭제하고 다시 만드는 운영이 있어, 그때마다 뷰가 깨지지 않기를 바란다. 어떻게 해야 하는가?

<details><summary>정답 보기</summary>

**`WITH NO SCHEMA BINDING` 을 붙여 late-binding 뷰로 만듭니다.** 외부 테이블로 뷰를 만들려면 이 옵션이 필요합니다. late-binding 뷰는 기반 객체와 의존성이 없어 **참조 객체가 없어도 뷰를 만들 수 있고, 참조 객체를 삭제·변경해도 뷰에 영향이 없으며**, Redshift는 뷰를 쿼리할 때까지 의존성을 확인하지 않습니다.
</details>

**Q4.** 데이터 엔지니어가 Athena 콘솔에서 PySpark 노트북으로 S3 데이터를 탐색하려 한다(PySpark engine version 3). 가장 먼저 해야 하는 일은?

<details><summary>정답 보기</summary>

**Spark 엔진을 쓰는 Spark 활성 워크그룹을 먼저 만듭니다.** 노트북을 만들기 전에 워크그룹이 있어야 하고, 노트북을 열면 새 세션이 자동으로 시작됩니다. Spark 활성 워크그룹은 **노트북 에디터만** 쓸 수 있고 쿼리 에디터는 Athena SQL 워크그룹 전용입니다. 참고로 Apache Spark version 3.5는 Athena 콘솔 노트북을 지원하지 않으며, engine version 3 워크그룹을 3.5로 업그레이드할 수도 없습니다.
</details>

**Q5.** 일별 매출 테이블에서 **각 날짜 행마다** 최근 7일 이동 평균을 함께 보여 주어야 한다. 행 수는 줄어들면 안 된다. 어떤 SQL 구성이 맞는가?

<details><summary>정답 보기</summary>

**`AVG(...) OVER (ORDER BY 날짜 ROWS ...)` 형태의 윈도 함수**입니다. 윈도 함수는 결과 집합의 모든 행을 유지하면서 각 행에 값을 돌려줍니다. 집계 함수에 ORDER BY를 쓰면 **명시적 프레임 절이 필요**합니다. `GROUP BY` 는 행을 그룹당 한 행으로 줄이므로 요구와 어긋나고, ROLLUP·CUBE는 소계·조합 집계용입니다.
</details>

---

**Q6 (원리).** 왜 Task 3.2는 **"행이 줄어드는가"** 와 **"저장되는가"** 두 질문으로 거의 다 풀릴까요?

<details><summary>정답 보기</summary>

**이 Task가 묻는 객체와 함수들은 전부 "결과를 어떻게 다시 쓰는가"의 변형이기 때문입니다.** 뷰·구체화된 뷰·CTAS는 저장되는가(정의만 / 결과 집합 / 파일)로 갈리고, 그에 따라 최신성과 속도가 결정됩니다. GROUP BY·윈도 함수·ROLLUP·PIVOT은 행이 줄어드는가, 열로 바뀌는가로 갈립니다. 서버리스 vs 프로비저닝조차 "용량을 **미리** 잡아 두는가"라는 같은 축의 질문입니다. 보기를 비교하기 전에 **요구사항이 둘 중 어느 축을 건드리는지** 먼저 정하면 선택지 절반이 바로 떨어집니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. What is AWS Glue DataBrew? — https://docs.aws.amazon.com/databrew/latest/dg/what-is.html
2. What is Amazon Quick? — https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
3. Importing data into SPICE (Amazon Quick) — https://docs.aws.amazon.com/quick/latest/userguide/spice.html
4. Refreshing imported data (Amazon Quick) — https://docs.aws.amazon.com/quick/latest/userguide/refreshing-imported-data.html
5. Data preparation steps (Amazon Quick) — https://docs.aws.amazon.com/quick/latest/userguide/data-prep-steps.html
6. Using Lambda with Amazon S3 — https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html
7. Amazon SageMaker Data Wrangler — https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler.html
8. Creating a table from query results (CTAS) (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/ctas.html
9. Views (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/views.html
10. CREATE VIEW (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_VIEW.html
11. Materialized views in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-overview.html
12. Refreshing a materialized view (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/materialized-view-refresh.html
13. Using Apache Spark in Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark.html
14. Getting started with Apache Spark on Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-getting-started.html
15. Migrating from PySpark engine version 3 to Apache Spark version 3.5 (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-migration-v3-to-v35.html
16. Considerations and limitations for Apache Spark on Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/notebooks-spark-considerations-and-limitations.html
17. Managing query processing capacity (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/capacity-management.html
18. What is Amazon Redshift Serverless? — https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-whatis.html
19. Billing for Amazon Redshift Serverless — https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-billing.html
20. What is Amazon EMR Serverless? — https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/emr-serverless.html
21. Choosing the data stream capacity mode (Amazon Kinesis Data Streams) — https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html
22. Window functions (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_Window_functions.html
23. AVG window function (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_WF_AVG.html
24. SELECT (Amazon Athena) — https://docs.aws.amazon.com/athena/latest/ug/select.html
25. PIVOT and UNPIVOT examples (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_FROM_clause-pivot-unpivot-examples.html
26. DEA-C01 공식 시험 가이드 도메인 3 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
