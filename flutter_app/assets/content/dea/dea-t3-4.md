---
examGuideTaskId: dea-t3-4
certCode: DEA-C01
domain: 3
domainName: 데이터 운영 및 지원
domainWeightPct: 22
title: 데이터 품질 보장 (Glue DQ·DataBrew 규칙·샘플링·스큐)
coversTasks:
  - "3.4"
sources:
  - title: AWS Glue Data Quality (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html
  - title: Evaluating data quality for ETL jobs in AWS Glue Studio (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/tutorial-data-quality.html
  - title: Anomaly detection in AWS Glue Data Quality (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/data-quality-anomaly-detection.html
  - title: Validating data quality in AWS Glue DataBrew (공식 문서)
    url: https://docs.aws.amazon.com/databrew/latest/dg/profile.data-quality-rules.html
  - title: Optimize shuffles (AWS Prescriptive Guidance) (공식 문서)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/optimize-shuffles.html
  - title: Using write sharding to distribute workloads evenly in your DynamoDB table (공식 문서)
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-sharding.html
  - title: Choose the best distribution style (Amazon Redshift) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html
  - title: DEA-C01 공식 시험 가이드 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
lastVerified: 2026-10-20
---

# 데이터 품질 보장 (Glue DQ·DataBrew 규칙·샘플링·스큐)

> **커버하는 공식 Task** — DEA-C01 · 도메인 3 「데이터 운영 및 지원」(22%) · **Task 3.4 데이터 품질 보장** (`dea-t3-4`)
> Skill 5개로 도메인 3에서 가장 작지만, **두 개의 비슷한 서비스(Glue Data Quality · DataBrew)** 를 가르는 문항이 집중됩니다.
> **Skill 3.4.4(샘플링)와 3.4.5(스큐)는 Skill 문구에 서비스 예시가 없어** 출제 범위가 넓게 열려 있습니다. 서비스별 기능으로 외우세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.4의 Skill 항목)

- [ ] **AWS Glue Data Quality의 두 진입점**(Data Catalog · ETL 잡)을 구분한다
- [ ] **DQDL 규칙**으로 빈 필드를 검사하고 **규칙 실패 시 잡 동작**을 설정한다
- [ ] **행 수준 결과와 전체 결과**가 다를 수 있다는 점을 설명한다
- [ ] **DataBrew ruleset**이 어떻게 정의·검증되고 결과가 어디에 남는지 안다
- [ ] **Glue DQ와 DataBrew 품질 규칙**을 시나리오로 가른다
- [ ] **프로파일 잡·데이터셋 간 규칙·이상 탐지**로 일관성을 조사한다
- [ ] 서비스별 **샘플링 수단**(DataBrew 프로젝트·프로파일 잡·크롤러·Athena)을 고른다
- [ ] **Spark·Redshift·DynamoDB·Kinesis** 의 스큐 증상과 완화 메커니즘을 구분한다

---

## 🎯 왜 중요한가

- 품질 문항은 거의 항상 **"어느 서비스의 어느 진입점인가"** 를 먼저 묻습니다. Glue Data Quality에도 진입점이 둘이고, DataBrew에도 비슷한 ruleset이 있어 **세 갈래**가 됩니다.
- **기본값이 또 승부처입니다.** Glue Studio의 Evaluate Data Quality는 **규칙이 실패해도 기본적으로 잡이 계속 실행**됩니다. "불량 데이터를 적재하면 안 된다"는 요구는 옵션을 바꿔야 충족됩니다.
- 스큐(3.4.5)는 **증상이 똑같고 해법만 다릅니다.** Spark는 솔팅·AQE, Redshift는 분산 키, DynamoDB는 write sharding, Kinesis는 샤드 split — 서비스 이름이 곧 정답의 절반입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **DQDL** | data quality definition language | Glue Data Quality에서 품질 규칙을 적는 전용 언어 |
| **ruleset** | ruleset | 함께 평가되는 규칙 묶음 |
| **analyzer** | analyzer | 규칙 없이 통계만 모으는 Glue DQ 구성 요소 |
| **프로파일 잡** | profile job | 데이터셋을 훑어 통계와 품질 보고서를 만드는 DataBrew 작업 |
| **이상 탐지** | anomaly detection | 쌓인 통계의 평소 범위를 벗어난 값을 찾아내는 것 |
| **샘플링** | sampling | 전체를 읽지 않고 일부만 뽑아 보는 것 |
| **데이터 스큐** | data skew | 일부 조각에 데이터·요청이 몰려 전체가 느려지는 현상 |
| **솔팅** | salting | 몰린 키에 임의 접두어를 붙여 흩뜨리는 기법 |
| **AQE** | adaptive query execution | Spark가 실행 중 통계를 보고 계획을 바꾸는 기능 |
| **write sharding** | write sharding | DynamoDB에서 파티션 키에 접미사를 붙여 쓰기를 분산하는 것 |

---

## 📖 핵심 개념

### 1) 처리 중 데이터 품질 검사 — AWS Glue Data Quality {#glue-dq}

AWS Glue Data Quality는 **오픈소스 DeeQu 프레임워크 위에 만든 관리형 서버리스 서비스**이며, 규칙은 **DQDL(Data Quality Definition Language)** 이라는 도메인 특화 언어로 정의합니다.

**진입점이 둘입니다 — 이것부터 가르세요.**

| 진입점 | 무엇을 하는가 | 시험 단서 |
|---|---|---|
| **Glue Data Catalog** | 카탈로그 테이블을 **코드 없이 평가**. ruleset은 **Data Catalog 테이블에 연결** | "이미 카탈로그에 있는 데이터를 정기 평가", "거버넌스" |
| **Glue ETL 잡** | 파이프라인 **중간에서 검사**하고 잡 흐름을 제어 | "변환 도중 불량 레코드 분리", "적재 전 검사" |

- **빈 필드 검사** — **`IsComplete`** 규칙은 컬럼의 모든 값이 비어 있지 않은지(null 아님) 검사합니다. **규칙 추천** 기능은 컬럼 데이터를 분석해 `IsComplete`·`Uniqueness`·`ColumnValues`·`ColumnLength` 같은 규칙을 제안하므로 **코드 없이 시작**할 수 있습니다.
- **ETL 잡 안에서** — Glue Studio의 **Evaluate Data Quality** 변환은 **여러 부모(입력)를 지원**해 여러 데이터셋에 걸친 규칙을 검증하고 **규칙을 통과하지 못한 레코드를 식별**할 수 있습니다. 원본 데이터를 그대로 내보내며 **오류 표시 컬럼을 붙이는 `rowLevelOutcomes` 출력**과, 규칙별 통과·실패 결과를 내보내는 출력이 있습니다.
- ⚠️ **행 단위로는 통과여도 전체 결과는 FAIL일 수 있습니다.** `RowCount` 같은 규칙은 데이터셋 단위로 평가되기 때문입니다. "불량 레코드만 분리"가 요구면 **행 수준 출력**을 봐야 합니다.
- **규칙 실패 시 잡 동작** — **기본값(None)은 규칙이 실패해도 잡이 계속 실행**됩니다. 실패를 잡 실패로 연결하려면 옵션을 골라야 하며, **"Fail job without loading to target data"** 는 데이터 품질 오류가 나는 즉시 잡을 실패시키고 **어떤 타깃에도 쓰지 않습니다.**
- **액션** — **CloudWatch 지표를 게시**하거나 **잡을 중단**할 수 있고, **같은 지표가 EventBridge에도 게시**됩니다.
- **S3 타깃 기본 규칙** — S3를 타깃으로 하는 ETL 잡에는 **적재할 데이터에 컬럼이 하나 이상 있는지** 보는 규칙이 자동으로 켜집니다. 이 규칙이 실패해도 **잡은 실패하지 않고 데이터 품질 점수만 내려갑니다.**
- **점수·알림·스케줄** — **점수는 평가한 규칙 중 통과한 규칙의 비율**입니다. 평가가 끝나면 **EventBridge 이벤트가 게시되며 알림은 EventBridge 방식이 권장**입니다. CloudWatch의 **사용자 지정 네임스페이스 `Glue Data Quality`** 지표로 알람을 만들 수도 있습니다. 카탈로그에서 정한 스케줄은 EventBridge에 만들어집니다.

> 📌 시험 범위 목록에는 "AWS Glue"와 "AWS Glue DataBrew"가 있고 **"AWS Glue Data Quality"라는 별도 항목은 없습니다.** AWS Glue에 포함되는 것으로 보이지만 확정 근거는 없으니, Skill 3.4.2·3.4.3의 예시가 **DataBrew**라는 점도 함께 기억하세요.

### 2) 데이터 품질 규칙 정의 — DataBrew ruleset {#databrew-rules}

DataBrew는 데이터 품질 규칙을 **ruleset**에 정의합니다. ruleset은 **데이터 지표를 기대값과 비교하는 규칙의 집합**이며, ⚠️ **규칙의 기준을 하나라도 충족하지 못하면 ruleset 전체가 검증에 실패**합니다.

- 규칙은 **컬럼 하나 또는 선택한 여러 컬럼**에 적용할 수 있고, 한 규칙은 여러 단순 체크로 구성되어 **모두 참이어야 할지 하나라도 참이면 될지**를 정할 수 있습니다.
- ⚠️ **컬럼 단위 규칙은 문자열·숫자 같은 단순 타입에만** 정의할 수 있고 **배열·구조체 같은 복합 타입에는 정의할 수 없습니다.**
- **검증 방법** — **ruleset을 프로파일 잡에 추가하면** 잡이 프로파일과 함께 **검증 보고서**를 만들고, 보고서는 **프로파일 데이터와 같은 위치**에 저장됩니다. **한 데이터셋에 ruleset을 여러 개** 둘 수 있습니다(예: 최소 허용 기준용과 더 엄격한 기준용).
- **후속 조치** — 프로파일 잡이 끝나면 DataBrew가 **CloudWatch 이벤트를 보내며 검증한 ruleset마다 이벤트가 하나씩** 발행되므로, **실패한 검증만 골라** 알림·자동화를 걸 수 있습니다.

**두 서비스 비교 — 문항은 거의 이 표에서 갈립니다.**

| 구분 | **AWS Glue Data Quality** | **DataBrew 데이터 품질 규칙** |
|---|---|---|
| 규칙 정의 | **DQDL** 규칙, 규칙 추천 지원 | 콘솔의 **ruleset**(컬럼별 체크 조합) |
| 검증 실행 | Data Catalog 테이블 평가 또는 **ETL의 Evaluate Data Quality 변환** | **ruleset을 프로파일 잡에 붙여** 검증 |
| 결과 | **점수**(통과 규칙 비율), **행 수준 결과**(ETL), EventBridge 이벤트·CloudWatch 지표 | **프로파일 데이터와 같은 위치의 검증 보고서**, ruleset별 CloudWatch 이벤트 |
| 실패 처리 | ETL 잡 실패 옵션(**None 기본**) | **하나라도 미충족이면 ruleset 전체 실패**, 이벤트로 후속 조치 |
| 시험 단서 | "ETL 처리 중 검사", "빈 필드", "DQDL", "Evaluate Data Quality" | "프로파일 잡", "ruleset", "검증 보고서" |

### 3) 데이터 일관성 조사 {#consistency}

일관성 조사는 세 갈래입니다. **① 프로파일링(중복·이상치·상관) · ② 데이터셋 간 비교 규칙 · ③ 시간 추이 기반 이상 탐지.**

- **DataBrew 프로파일 잡** — 데이터셋에 대한 일련의 평가를 실행해 **결과를 S3에 출력**합니다. **중복 행을 탐지·집계**하는 기능과 **컬럼 간 상관 행렬**을 켤 수 있습니다. 이상치는 개수와 z-score 샘플 목록으로 나오고 **기본 임계값은 3**이며, **상관은 기본으로 앞쪽 숫자 컬럼 10개**를 계산합니다.
- **Glue DQ의 데이터셋 간 비교** — 여러 데이터셋에 걸친 규칙은 **`ReferentialIntegrity` 와 `DatasetMatch` ruleset**으로 설정합니다.
- **Glue DQ 이상 탐지** — 규칙과 **analyzer**(규칙 없이 통계만 수집)가 시간에 따라 쌓은 통계를 **ML로 분석**해, 실제 값이 예측 범위를 벗어나면 **이상 관측**을 만듭니다.
  - ⚠️ **최소 세 개의 데이터 포인트**가 필요합니다.
  - ⚠️ **이상이 생겨도 데이터 품질 점수에는 영향이 없습니다.**
  - **ETL과 Data Catalog 모두에서 지원**됩니다.

### 4) 데이터 샘플링 기법 {#sampling}

샘플링은 큰 데이터를 전부 읽지 않고 일부로 **탐색·프로파일링·스키마 추론**을 하는 기법입니다. **샘플이 작을수록 변환이 빠르고, 클수록 원본 구성을 더 정확히 반영**한다는 교환이 있습니다.

| 서비스·기능 | 샘플링 방식 | 기본값·한도 |
|---|---|---|
| **DataBrew 프로젝트**(대화형 편집) | **첫 n행** 또는 **무작위 행** | **기본 첫 500행**, 사용자 지정 크기는 **최대 5,000행** |
| **DataBrew 프로파일 잡** | **`JobSample`** 로 프로파일 대상 행 수 지정(전체 데이터셋 모드도 있음) | API 문서 기준 기본은 `CUSTOM_ROWS` 모드·20,000행 |
| **Glue 크롤러(S3 대상)** | **리프 폴더당 크롤링할 파일 수(`SampleSize`)** 지정 | **1–249**, 미설정이면 **모든 파일 크롤링** |
| **Amazon Athena** | **`TABLESAMPLE BERNOULLI` / `SYSTEM`**(percentage) | **BERNOULLI**는 모든 물리 블록을 스캔하며 **행 단위 확률**로 선택, **SYSTEM**은 **논리 세그먼트 단위**로 샘플링하며 **독립 확률을 보장하지 않음** |

> ⚠️ **무작위·체계적·층화 같은 일반 통계 기법명은 위 서비스(DataBrew·Glue·Athena) 문서에서 확인되지 않았습니다.** 이 Task는 **"서비스별로 어떤 샘플링을 제공하는가"** 의 틀로 공부하세요.

### 5) 데이터 스큐 메커니즘 {#skew}

데이터 스큐는 **일부 파티션·슬라이스·키·샤드에 데이터나 요청이 몰려 가장 느린 조각이 전체를 끌어내리는 현상**입니다. 증상은 비슷하지만 **영역마다 진단 도구와 해법이 다릅니다.**

| 영역 | 스큐 증상·진단 | 완화 메커니즘 |
|---|---|---|
| **Spark / AWS Glue** | 소수 태스크만 오래 걸림(**Spark UI 요약 지표 편향**) | **AQE 스큐 조인 최적화**, 고카디널리티·복합 조인 키, **솔팅**, 브로드캐스트 |
| **Amazon Redshift** | 일부 슬라이스에 행·쿼리 부하 집중(**`SVV_TABLE_INFO`**) | **분산 키 재선택**, 작은 차원 테이블은 **ALL 분산** |
| **Amazon DynamoDB** | 특정 파티션 키에 쓰기·읽기 집중(**hot partition**) | **균일한 파티션 키 설계**, **랜덤 접미사 write sharding** |
| **Kinesis Data Streams** | 일부 샤드로 레코드 집중(**hot shard**) | **hot 샤드 split** / cold 샤드 merge |

- **Spark/Glue** — 스큐는 **Spark 잡의 가장 흔한 병목 원인 중 하나**이며, 스큐된 파티션의 태스크가 오래 걸려 전체 처리 시간을 늦춥니다. **AQE(Adaptive Query Execution)** 의 스큐 조인 최적화를 쓰며 **Glue 4.0부터 기본 활성**입니다. 조인 키는 **카디널리티가 높은 키나 복합 키**가 낫습니다. **솔팅(salting)** 은 스큐된 키에 **임의 접두어를 붙여 파티션에 고르게 분산**하고 처리 후 접두어를 제거하는 기법입니다.
- **Amazon Redshift** — 분산 키는 조인 컬럼에 맞추되 **팩트 테이블은 분산 키를 하나만** 가질 수 있습니다. ⚠️ **날짜 컬럼을 분산 키로 하고 좁은 날짜 범위로 자주 필터하면 필터된 행이 일부 슬라이스에 몰려 쿼리 워크로드가 스큐됩니다.** 작은 차원 테이블은 **ALL 분산**으로 모든 노드에 두는 선택지가 있습니다. 분포 스큐는 **`SVV_TABLE_INFO` 시스템 뷰(`skew_rows` 등)** 로 진단합니다.
- **Amazon DynamoDB** — **모든 파티션 키에 걸쳐 균일한 활동**이 되도록 설계해야 합니다. 쓰기가 한 키에 몰리면 파티션 키에 **임의 숫자(랜덤 접미사)** 를 붙이는 **write sharding** 으로 분산하되, ⚠️ **읽을 때는 모든 접미사를 조회해 결과를 병합**해야 합니다.
- **Kinesis Data Streams** — 지표로 데이터를 훨씬 많이/적게 받는 **hot/cold 샤드**를 찾고, **hot 샤드만 선택적으로 split** 해 해당 해시 키 범위의 용량을 늘립니다(cold 샤드는 merge).

---

## ✍️ 시험 포인트

1. **진입점부터 가르기** — "ETL 처리 중 검사, DQDL, Evaluate Data Quality" → **Glue DQ의 ETL 진입점**. "이미 카탈로그에 있는 테이블을 정기 평가" → **Data Catalog 진입점**. "프로파일 잡, ruleset, 검증 보고서" → **DataBrew**.
2. **"적재하면 안 된다"는 옵션 변경** — 기본값(None)은 규칙이 실패해도 잡이 계속 돕니다. **"Fail job without loading to target data"** 를 골라야 합니다.
3. **"불량 레코드만 골라내라"** — **행 수준 출력(`rowLevelOutcomes`)** 입니다. 전체 결과가 FAIL이어도 개별 레코드는 통과일 수 있습니다.
4. **"규칙을 쓰지 않고 평소 범위 이탈 탐지"** — **analyzer + 이상 탐지**입니다. **최소 세 개의 데이터 포인트**가 필요하고 **점수에는 영향이 없습니다.**
5. **샘플링은 "무엇을 줄이는가"** — 크롤러 `SampleSize` 는 **읽을 파일 수**(1–249)를 줄여 스키마 추론 시간을 줄이고, Athena `TABLESAMPLE` 은 **질의 결과 행**을 확률로 고릅니다.
6. **스큐는 서비스 이름이 절반** — Spark는 솔팅·AQE, Redshift는 분산 키·`SVV_TABLE_INFO`, DynamoDB는 write sharding, Kinesis는 hot 샤드 split.

---

## ⚠️ 흔한 함정

1. **Glue DQ와 DataBrew 품질 규칙 혼동** — Glue DQ는 **DQDL**을 카탈로그 테이블이나 **ETL 잡 안에서** 평가하고, DataBrew는 **ruleset을 프로파일 잡에 붙여** 검증합니다.
2. **기본값(None)으로 두고 "적재 차단"을 기대** — 기본은 **규칙이 실패해도 잡이 계속 실행**됩니다.
3. **전체 FAIL이면 모든 레코드가 불량이라고 생각** — 데이터셋 단위 규칙 때문에 **전체는 FAIL이어도 개별 레코드는 통과**일 수 있습니다.
4. **S3 타깃 기본 규칙이 잡을 실패시킨다고 생각** — 이 규칙이 실패해도 **잡은 실패하지 않고 점수만 내려갑니다.**
5. **품질 점수를 "통과한 행의 비율"로 오해** — 점수는 **통과한 규칙의 비율**입니다.
6. **DataBrew ruleset을 따로 실행할 수 있다고 생각** — **프로파일 잡에 붙여야** 검증됩니다.
7. **ruleset 일부만 실패하면 통과라고 생각** — **하나라도 미충족이면 ruleset 전체가 실패**합니다.
8. **복합 타입 컬럼에 DataBrew 규칙을 걸려 함** — **문자열·숫자 같은 단순 타입에만** 정의할 수 있습니다.
9. **이상 탐지가 품질 점수를 떨어뜨린다고 생각** — **점수에 영향이 없습니다.**
10. **데이터 포인트 하나로 이상 탐지를 기대** — **최소 세 개**가 필요합니다.
11. **데이터셋 간 비교를 일반 규칙으로 하려 함** — **`ReferentialIntegrity`·`DatasetMatch`** ruleset을 씁니다.
12. **프로젝트 샘플과 프로파일 잡 샘플 혼동** — 프로젝트는 **대화형 편집용**(기본 첫 500행, 최대 5,000행), 프로파일 잡은 **`JobSample` 로 통계 계산 범위**를 정합니다.
13. **크롤러 `SampleSize` 를 행 수로 오해** — **리프 폴더당 읽을 파일 수**(1–249)이며, 설정하지 않으면 모든 파일을 크롤링합니다.
14. **`TABLESAMPLE SYSTEM` 을 균등 무작위로 생각** — SYSTEM은 **논리 세그먼트 단위**이며 **독립 확률을 보장하지 않습니다.** 행 단위 확률은 BERNOULLI입니다.
15. **샘플을 키우면 항상 좋다고 생각** — 원본 구성은 더 정확해지지만 **변환·세션이 느려집니다.**
16. **모든 스큐를 솔팅으로 해결하려 함** — 솔팅은 **Spark/Glue** 영역의 기법입니다.
17. **Redshift에서 날짜 분산 키를 유지한 채 좁은 날짜 범위로 필터** — **필터된 행이 일부 슬라이스에 몰려** 쿼리가 스큐됩니다.
18. **팩트 테이블에 분산 키를 여러 개 두려 함** — **하나만** 가질 수 있습니다.
19. **write sharding의 읽기 비용을 무시** — 랜덤 접미사는 쓰기를 퍼뜨리지만 **읽을 때 모든 접미사를 조회해 병합**해야 합니다.
20. **Kinesis hot 샤드에 전체 리샤딩** — 지표로 찾아 **hot 샤드만 선택적으로 split** 합니다.
21. **AQE를 직접 켜야 한다고 생각** — **Glue 4.0부터 기본 활성**입니다.

---

## 🧪 자가 점검

**Q1.** AWS Glue ETL 잡이 S3로 적재하기 전에 필수 컬럼의 빈 값을 검사하고, 규칙을 어기는 데이터가 있으면 **어떤 타깃에도 쓰지 않은 채** 잡을 즉시 실패시켜야 한다. 가장 적합한 구성은?

<details><summary>정답 보기</summary>

**Glue Studio의 Evaluate Data Quality 변환에 `IsComplete` 규칙을 넣고, 규칙 실패 시 동작으로 "Fail job without loading to target data"를 고릅니다.** `IsComplete` 는 컬럼의 모든 값이 null이 아닌지 검사하고, 이 옵션은 데이터 품질 오류가 나는 즉시 잡을 실패시키며 어떤 타깃에도 쓰지 않습니다. **기본값(None)으로 두면 규칙이 실패해도 잡이 계속 실행**됩니다.
</details>

**Q2.** 품질 검사를 통과하지 못한 **개별 레코드만** 격리 버킷으로 보내려 한다. 전체 결과는 FAIL로 나오지만 모든 레코드가 불량은 아니다. 무엇을 써야 하는가?

<details><summary>정답 보기</summary>

**Evaluate Data Quality 변환의 행 수준 출력(`rowLevelOutcomes`)을 사용합니다.** 이 출력은 원본 데이터를 그대로 내보내면서 **오류 표시 컬럼을 붙여** 규칙을 통과하지 못한 레코드를 식별하게 해 줍니다. `RowCount` 같은 규칙은 데이터셋 단위로 평가되므로 **전체 결과가 FAIL이어도 개별 레코드는 통과**일 수 있습니다.
</details>

**Q3.** 데이터 엔지니어가 **규칙을 따로 작성하지 않고** 테이블 통계가 평소 범위를 벗어나는 때를 탐지하고 싶어 한다. 어떤 기능이며 무엇을 알아야 하는가?

<details><summary>정답 보기</summary>

**AWS Glue Data Quality의 analyzer + 이상 탐지**입니다. analyzer는 명시적 규칙 없이 통계를 수집하고, 쌓인 통계를 ML로 분석해 실제 값이 예측 범위를 벗어나면 이상 관측을 만듭니다. 알아야 할 두 가지는 **최소 세 개의 데이터 포인트가 필요하다**는 것과 **이상이 생겨도 데이터 품질 점수에는 영향이 없다**는 것입니다. ETL과 Data Catalog 모두에서 지원됩니다.
</details>

**Q4.** Amazon S3 경로에 작은 파일이 수십만 개 있어 AWS Glue 크롤러 실행이 너무 오래 걸린다. 스키마 구조는 폴더마다 동일하다. 실행 시간을 줄이려면?

<details><summary>정답 보기</summary>

**S3 대상의 `SampleSize` 를 지정해 리프 폴더당 크롤링할 파일 수를 제한합니다.** 유효 값은 **1에서 249 사이의 정수**이고, 설정하지 않으면 모든 파일을 크롤링합니다. 이것은 **읽을 파일 수**를 줄이는 샘플링이며, 질의 결과의 행을 확률로 고르는 Athena `TABLESAMPLE` 과는 다른 층위입니다.
</details>

**Q5.** Amazon DynamoDB 테이블에서 특정 파티션 키 하나에 쓰기가 몰려 쓰로틀이 발생한다. write sharding을 적용하려 한다. 무엇을 함께 고려해야 하는가?

<details><summary>정답 보기</summary>

**파티션 키 값에 임의 숫자(랜덤 접미사)를 붙이면 쓰기는 여러 파티션으로 분산되지만, 읽을 때는 모든 접미사를 조회해 결과를 병합해야 합니다.** 근본 원칙은 **모든 파티션 키에 걸쳐 균일한 활동이 되도록 설계**하는 것이며, write sharding은 그 설계가 어려울 때 쓰는 분산 기법입니다.
</details>

---

**Q6 (원리).** 왜 "스큐"는 서비스마다 같은 말인데 해법이 전부 다를까요?

<details><summary>정답 보기</summary>

**스큐라는 말은 증상을 가리키고, 해법은 그 서비스가 데이터를 "무엇 단위로 쪼개는가"에 달려 있기 때문입니다.** Spark는 **파티션**으로 쪼개니 키를 흩뜨리는 솔팅과 실행 중 분할(AQE)이 답이고, Redshift는 **슬라이스**로 쪼개니 **분산 키**를 바꾸는 것이 답이며, DynamoDB는 **파티션 키**로 쪼개니 키 설계와 **write sharding**, Kinesis는 **샤드**로 쪼개니 **샤드 split**이 답입니다. 그래서 문항을 풀 때는 "스큐"라는 단어가 아니라 **문장에 나온 서비스 이름과 "슬라이스·파티션 키·샤드" 같은 어휘**를 먼저 잡아야 합니다. 어휘가 쪼개는 단위를 알려 주고, 쪼개는 단위가 해법을 결정합니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 보강: 2026-10-19 · 저작: 2026-10-20 · 사람 검수 전)

1. AWS Glue Data Quality — https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html
2. Evaluating data quality for ETL jobs in AWS Glue Studio — https://docs.aws.amazon.com/glue/latest/dg/tutorial-data-quality.html
3. Getting started with AWS Glue Data Quality for the Data Catalog — https://docs.aws.amazon.com/glue/latest/dg/data-quality-getting-started.html
4. Setting up alerts, deployments, and scheduling (AWS Glue Data Quality) — https://docs.aws.amazon.com/glue/latest/dg/data-quality-alerts.html
5. Anomaly detection in AWS Glue Data Quality — https://docs.aws.amazon.com/glue/latest/dg/data-quality-anomaly-detection.html
6. IsComplete (DQDL rule type reference) — https://docs.aws.amazon.com/glue/latest/dg/dqdl-rule-types-IsComplete.html
7. Validating data quality in AWS Glue DataBrew — https://docs.aws.amazon.com/databrew/latest/dg/profile.data-quality-rules.html
8. Creating and working with AWS Glue DataBrew profile jobs — https://docs.aws.amazon.com/databrew/latest/dg/jobs.profile.html
9. Building a profile job configuration programmatically in AWS Glue DataBrew — https://docs.aws.amazon.com/databrew/latest/dg/profile.configuration.html
10. Creating and using AWS Glue DataBrew projects — https://docs.aws.amazon.com/databrew/latest/dg/projects.html
11. JobSample (AWS Glue DataBrew API Reference) — https://docs.aws.amazon.com/databrew/latest/APIReference/API_JobSample.html
12. AWS::Glue::Crawler S3Target (CloudFormation Template Reference) — https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-glue-crawler-s3target.html
13. SELECT (Amazon Athena SQL reference) — https://docs.aws.amazon.com/athena/latest/ug/select.html
14. Optimize shuffles (AWS Prescriptive Guidance: tuning AWS Glue for Apache Spark) — https://docs.aws.amazon.com/prescriptive-guidance/latest/tuning-aws-glue-for-apache-spark/optimize-shuffles.html
15. Detect and handle data skew on AWS Glue (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/detect-and-handle-data-skew-on-aws-glue/
16. Choose the best distribution style (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-best-dist-key.html
17. SVV_TABLE_INFO (Amazon Redshift) — https://docs.aws.amazon.com/redshift/latest/dg/r_SVV_TABLE_INFO.html
18. Best practices for designing and using partition keys effectively in DynamoDB — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html
19. Using write sharding to distribute workloads evenly in your DynamoDB table — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-sharding.html
20. Decide on a strategy for resharding (Amazon Kinesis Data Streams) — https://docs.aws.amazon.com/streams/latest/dev/kinesis-using-sdk-java-resharding-strategies.html
21. In-Scope AWS Services (DEA-C01 exam guide) — https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
22. DEA-C01 공식 시험 가이드 도메인 3 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
