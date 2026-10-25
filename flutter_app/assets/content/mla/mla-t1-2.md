---
examGuideTaskId: mla-t1-2
certCode: MLA-C01
domain: 1
domainName: 기계 학습(ML)을 위한 데이터 준비
domainWeightPct: 28
title: 데이터 변환·특성 추출 (정리·인코딩·도구 선택·Feature Store)
coversTasks:
  - "1.2"
sources:
  - title: Transform Data (SageMaker Data Wrangler 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html
  - title: What is AWS Glue DataBrew? (공식 문서)
    url: https://docs.aws.amazon.com/databrew/latest/dg/what-is.html
  - title: Transform data with AWS Glue managed transforms (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/edit-jobs-transforms.html
  - title: DynamicFrame class (AWS Glue 공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-pyspark-extensions-dynamic-frame.html
  - title: Create, store, and share features with Feature Store (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store.html
  - title: Time to live (TTL) duration for records (Feature Store 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-time-to-live.html
  - title: Transform source data in Amazon Data Firehose (공식 문서)
    url: https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html
  - title: Automate data labeling (SageMaker Ground Truth 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/sms-automated-labeling.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 데이터 변환·특성 추출 (정리·인코딩·도구 선택·Feature Store)

> **커버하는 공식 Task** — MLA-C01 · 도메인 1 「기계 학습(ML)을 위한 데이터 준비」(28%) · **Task 1.2 데이터 변환 및 특성 추출 수행** (`mla-t1-2`)
> 수집한 데이터를 **모델이 먹을 수 있는 형태**로 바꾸는 단계입니다. 시험은 기법 자체보다 **"어떤 도구로, 어떤 변환을, 어떤 제약 아래"**를 묻습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 이상값·결측·중복·결합을 Data Wrangler·DataBrew·Glue에서 **어떤 변환 이름**으로 하는지 안다
- [ ] 스케일링 4종(Standard·Min Max·Robust·Max Absolute)과 **이상값에 강건한 선택**을 구분한다
- [ ] 원-핫·서수·유사성 인코딩을 **범주 수와 잡음**으로 가른다
- [ ] Glue의 DynamicFrame이 Spark DataFrame과 무엇이 다른지, `resolveChoice`·`relationalize`가 왜 필요한지 설명한다
- [ ] Data Wrangler·Glue·DataBrew·EMR·Processing을 **코드 여부 → 실행 기반 → 연동 → 규모** 순으로 고른다
- [ ] 스트리밍 변환 선택지 5가지와 각각의 한도를 구분한다
- [ ] Feature Store의 필수 요소(레코드 식별자·이벤트 시간)와 TTL·시점 정확 조인을 설명한다
- [ ] Ground Truth의 자동 레이블링 조건과 A2I의 용도를 구분한다 ⚠️ 현재 상태 주의

---

## 🎯 왜 중요한가

모델 성능은 특성 품질을 넘지 못합니다. 이상값 하나가 스케일을 망치면 그 특성이 모델을 지배하고, 범주 수천 개를 원-핫으로 펼치면 차원이 폭발합니다. 그래서 이 Task는 **"변환을 어떻게 설계하는가"**와 **"그 변환을 어디서 실행하는가"**를 함께 묻습니다.

도구가 많다는 것도 포인트입니다. Data Wrangler·DataBrew·Glue·EMR·Processing은 하는 일이 겹치지만 **대상 사용자, 실행 기반, 연동 대상**이 다릅니다. 시험은 겹치는 부분이 아니라 **다른 부분**을 묻습니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **레시피(recipe)** | DataBrew에서 변환 단계를 모아 저장·게시하는 단위. 레시피 잡이 이것을 실행한다 |
| **데이터 흐름(data flow)** | Data Wrangler에서 가져오기 → 변환 단계 → 내보내기로 이어지는 작업 단위 |
| **DynamicFrame** | Glue의 데이터 구조. 레코드가 **자기 기술적(self-describing)**이라 초기 스키마 없이 읽고, 타입 불일치는 choice 타입으로 표현한다 |
| **특성 그룹(feature group)** | Feature Store의 저장 단위. 온라인·오프라인 설정 중 최소 하나가 필요하다 |
| **레코드 식별자 / 이벤트 시간** | 모든 특성 그룹에 필수. 둘의 조합이 레코드를 고유하게 식별한다 |
| **시점 정확 조인** | 과거 특정 시점의 특성 값을 재현해 미래 정보 유입(feature leakage)을 막는 조인 |

---

## 📖 핵심 개념

### 1) 도구 지형과 현재 상태 ⚠️ {#tool-landscape}

이 Task의 도구는 네 갈래입니다. **배치 변환**(Data Wrangler·Glue·DataBrew·EMR Spark·SageMaker Processing) · **스트리밍 변환**(Firehose+Lambda·Glue/EMR Spark·Flink) · **특성 저장**(Feature Store) · **레이블링**(Ground Truth·Mechanical Turk·A2I).

| 대상 | 현재 상태 |
|---|---|
| Amazon SageMaker → **SageMaker AI** | 2024-12-03 개명(ML 서비스 쪽). 문서 URL의 `sagemaker`는 그대로 |
| SageMaker Data Wrangler | Studio Classic 기능 → **Canvas 안으로 통합**. 새 Studio에서는 Canvas로만 접근 |
| Studio Classic | ⚠️ 기존 워크로드만 유지, 신규 온보딩 불가 |
| Ground Truth · A2I · Mechanical Turk | ⚠️ 신규 고객 불가 / 유지 모드 / 폐쇄 — 자세한 것은 9) |
| Feature Store · Canvas | 'SageMaker AI 기능 묶음' 신규 고객 중단 공지 **대상이 아님** |

> 시험 가이드는 Version 1.0 기준이라 **이미 신규 고객을 받지 않는 서비스도 범위에 남아 있습니다.** 기능은 가이드대로 익히되 현재 상태를 함께 기억하세요.

### 2) 정리 — 이상값·결측·중복·결합 {#cleaning}

| 작업 | Data Wrangler | DataBrew | Glue |
|---|---|---|---|
| 이상값 | **Handle outliers**: Robust standard deviation · Standard deviation · Quantile · Min-Max numeric. 처리 방식은 **Clip·Remove·Invalidate**. 범주는 Replace rare | FLAG/REMOVE/REPLACE_OUTLIERS, RESCALE_OUTLIERS_WITH_Z_SCORE, RESCALE_OUTLIERS_WITH_SKEW. 전략 Z_SCORE·MODIFIED_Z_SCORE·IQR(threshold 기본 3) | 전용 변환 없음 → Filter·SQL·Derived column으로 구현 |
| 결측 | **Handle missing values**: Fill missing(**지정한 값**) · Impute missing(**계산값**: 숫자 평균·중앙값, 범주 최빈값) · Add indicator · Drop missing | FILL_WITH_AVERAGE·_MEDIAN·_MODE·_CUSTOM 등, REMOVE_MISSING | **FillMissingValues**(ML 모델이 대체값을 예측해 새 필드에 기록), Drop Null Fields |
| 중복 | Concatenate의 중복 제거, 사용자 지정 변환 | DELETE_DUPLICATE_ROWS(행 전체 일치) · **REMOVE_DUPLICATES(선택 열 기준)** · FLAG 계열 | Drop Duplicates, **FindMatches**(공통 키 없는 유사 중복, ML) |
| 결합 | Join 7종, Concatenate | JOIN 7종, UNION | Join, Union, **mergeDynamicFrame**(기본키 병합, 스테이징이 덮어씀), Lookup |

자주 틀리는 지점:

- **Fill missing은 지정한 값, Impute missing은 계산값**(평균·중앙값·최빈값)입니다. 상수로 채우려면 Fill입니다.
- Process numeric·Handle missing은 **한 번에 한 열에만** 적용됩니다.
- Glue **Drop Null Fields는 모든 값이 null인 열을 제거**합니다. 빈 문자열·문자열 `"null"`·`-1`·`0` 같은 자리표시자는 자동으로 null로 인식하지 않습니다.
- 정확 일치 중복은 DELETE_DUPLICATE_ROWS·Drop Duplicates로, **철자·표기가 다른 유사 중복은 FindMatches**로 풉니다.

> 🧠 **원리** — Spark DataFrame은 스키마가 먼저 필요하고 같은 필드의 타입이 레코드마다 다르면 string으로 보고하기 쉽습니다. Glue **DynamicFrame**은 레코드가 자기 기술적이라 초기 스키마 없이 읽고, 불일치를 choice 타입으로 표현했다가 `resolveChoice`로 해소합니다. 지저분한 데이터 ETL에 DynamicFrame을 쓰는 이유입니다.

### 3) 특성 변환 — 스케일링·비닝·로그·분할·차원 축소 {#feature-transforms}

| 기법 | 정의 | Data Wrangler | DataBrew |
|---|---|---|---|
| 정규화(Min-Max) | 값을 지정한 범위로 | Min Max Scaler | MIN_MAX(0~1), SCALE_BETWEEN |
| 표준화(Z-score) | 평균 0·표준편차 1 | Standard Scaler | Z_SCORE(**이상값 처리에 가장 적합**하다고 문서가 명시), MEAN_NORMALIZATION |
| 이상값에 강건 | 이상값에 덜 흔들리는 통계 | **Robust Scaler** | RESCALE_OUTLIERS_WITH_Z_SCORE |
| 최대 절대값 | 최대 절대값으로 나눔 | Max Absolute Scaler | — |
| 비닝 | 숫자를 구간(범주)으로 | 변환 목록에 binning 그룹 **없음** → Custom formula | **BUCKETIZATION**(콘솔명 Binning) |
| 로그 변환 | 분포의 왜도를 바꿈 | Custom formula(Spark SQL) | **SKEWNESS**의 LOG·ROOT·SQUARE |
| 특성 분할 | 한 열을 여러 특성으로 | Featurize date/time, Split string by delimiter, Flatten | SPLIT_COLUMN_* 계열 |
| 차원 축소 | 주성분으로 압축 | **Reduce dimensionality(PCA)** — 성분 수 **또는** 분산 임계 비율 중 하나만 지정 | — |

- **용어 주의**: DataBrew의 SCALE은 "scales or normalizes"로 서술하고, Linear Learner 문서는 "Normalization, or feature scaling"이라 부르지만 구현은 평균 0·표준편차 1입니다. `normalization`이 min-max인지 z-score인지는 **서비스 정의를 따라** 판단하세요.
- **스케일에 민감하다는 공식 근거가 있는 것**: Linear Learner의 정규화 옵션(`normalize_data`·`normalize_label`, 회귀는 둘 다 기본 켜짐·이진 분류는 특성만), Data Wrangler 문서의 "모델은 분포·범위에 민감하고 이상값은 정확도 저하·학습 시간 증가를 부른다".
- **Featurize date/time**: 선형 모델·딥 네트워크에는 **cyclic**, 트리 기반에는 **ordinal** 임베딩 모드를 권장합니다. 형식을 지정하고 추론을 끄면 가장 빠르고, 추론을 켜면 첫 형식을 열 전체로 가정해 다른 형식은 NaN이 됩니다.

### 4) 인코딩과 토큰화 {#encoding}

| 선택지 | 언제 | 핵심 옵션·제약 |
|---|---|---|
| **One-hot encode** | 순서 없는(nominal) 범주 | 출력 Vector 또는 Columns, Drop last category, Invalid handling(Skip·Keep·Error) |
| **Ordinal encode** | 순서가 있는(ordinal) 범주 | Invalid handling에 **Replace with NaN**(알고리즘이 결측을 처리할 때 권장) |
| **Similarity encode** | 범주가 **매우 많거나 오탈자 등 잡음**이 많을 때 | 3-gram 토큰 → min-hash 임베딩. 비슷한 문자열이 비슷한 벡터가 된다. Target dimension 기본 30 |
| DataBrew **ONE_HOT_ENCODING** | 범주를 n개 열로 | 대상 열 **고유값 최대 10개** |
| DataBrew **CATEGORICAL_MAPPING** | 범주를 숫자·다른 값으로 매핑 | categoryMap, keepOthers, deleteOtherRows |

- ⚠️ 새 범주 주의: Data Wrangler 인코더는 **단계를 정의한 시점의 범주**만 학습합니다. 이후 갱신된 데이터에 새 범주가 나오면 누락값으로 취급되어 Invalid handling 전략이 적용됩니다.
- DataBrew의 **BINARIZATION은 숫자 열을 임계값과 비교해 0/1로 만드는 별도 단계**이며 범주 인코딩이 아닙니다.
- 텍스트: Data Wrangler **Featurize text**의 Vectorize(Tokenizer Standard/Custom, Vectorizer Count/Hashing, Apply IDF로 TF-IDF)와 Character statistics, DataBrew의 **TOKENIZATION**(stemmingMode PORTER·LANCASTER, 불용어 제거).

> 공식 가이드 예시에 나오는 'binary encoding'·'label encoding'은 **AWS 도구에 같은 이름의 변환이 없습니다.** 가장 가까운 것이 Ordinal encode·CATEGORICAL_MAPPING이지만 공식 대응표는 없으므로 일반 ML 개념으로 이해하세요.

### 5) Glue 변환 — 세 층과 DynamicFrame {#glue-transforms}

| 층 | 무엇 | 대표 |
|---|---|---|
| Glue Studio 관리형 변환 | 시각적 편집기 노드 | ChangeSchema, Join, Union, **FillMissingValues**, Filter, Drop Duplicates, SQL, Aggregate, Flatten, Derived Column, Lookup |
| PySpark 변환 클래스 | 스크립트용 | ApplyMapping, DropNullFields, **FindMatches**, Relationalize, **ResolveChoice**, SplitRows, Unbox, UnnestFrame |
| 데이터 통합(DI) 변환 | 정리·마스킹·암호화. Glue 4.0 이상에서 `--enable-glue-di-transforms` | FormatPhoneNumber, FillWithMode, RemoveDuplicates, CryptographicHash, Encrypt/Decrypt |

기억할 DynamicFrame 메서드:

- `apply_mapping` — 원본 열·타입 → 대상 열·타입 매핑. **지정하지 않은 필드는 결과에서 빠집니다.**
- `resolveChoice` — choice 타입 해소: `cast`, `make_cols`(타입별 열 생성), `make_struct`, `project`.
- `relationalize` — **중첩 열을 풀고 배열을 피벗**해 관계형 DB에 맞는 테이블 목록으로. NoSQL → RDB 이전에 유용합니다.
- `mergeDynamicFrame` — 기본키로 병합하되 **스테이징 레코드가 소스를 덮어쓰고 중복은 제거하지 않습니다.**

### 6) 도구 비교 — 무엇으로 고르나 {#tool-choice}

| 도구 | 언제 | 핵심 제약 |
|---|---|---|
| **Data Wrangler**(Canvas) | ML 데이터를 시각적으로 가져와 변환·특성화하고 Feature Store·Pipelines로 내보낼 때 | 대화형 변환은 **샘플에만** 적용, 전체 처리는 별도 처리 잡. **5 GB 초과 데이터에 권장**. Process numeric·Handle missing은 단일 열 |
| **AWS Glue**(ETL) | 서버리스 Spark ETL + Data Catalog 연동 + ML 변환 + 스트리밍 ETL | 시각적 노드 또는 PySpark·Scala. DynamicFrame |
| **AWS Glue DataBrew** | 코드 없이 정리·정규화하고 **레시피를 재사용**할 때 | 250개 이상 사전 구축 변환, 서버리스, **레시피 1개에 변환 100개까지** |
| **Amazon EMR**(Spark) | 기존 Hadoop·Spark 자산, 클러스터·인스턴스까지 제어 | 배포 옵션 EC2·EKS·Outposts·Serverless |
| **SageMaker Processing** | SageMaker 안에서 전·후처리, 특성 엔지니어링, 모델 평가를 스크립트로 | 잡이 인스턴스를 띄우고 끝나면 해제. 입력 S3(대안 Athena·Redshift), 출력 S3 |

**고르는 순서**: 코드 여부 → 실행 기반(서버리스·클러스터·관리형 컨테이너) → 입출력 연동(Feature Store·Pipelines·Data Catalog) → 규모.

### 7) 스트리밍 변환 — 다섯 선택지와 한도 {#streaming-transform}

| 선택지 | 언제 | 기억할 한도 |
|---|---|---|
| **Firehose + Lambda 변환** | 전송 경로에서 레코드 단위 가벼운 변환 | 변환 버퍼 힌트 0.2–3 MB(기본 1 MB)·0–900초, **Lambda 동기 호출 요청·응답 각 6 MB**, 호출 **최대 5분**, 실패 시 기본 3회 재시도 후 배치 건너뜀 |
| **Firehose 레코드 포맷 변환** | JSON → Parquet·ORC | 역직렬화기 + Glue 카탈로그 스키마 + 직렬화기. JSON이 아니면 Lambda로 먼저 JSON 변환 |
| **Lambda 이벤트 소스 매핑** | Kinesis·MSK를 Lambda가 직접 소비 | BatchSize 기본 100, 배칭 윈도 0–300초, 동기 호출 6 MB |
| **Glue 스트리밍 ETL** | 서버리스 Spark Structured Streaming | 기본 100초 윈도, **작업 북마크 대신 체크포인트**, 타임아웃 7일 미만 |
| **Managed Service for Apache Flink** | 장기 실행·상태 세밀 제어·사용자 지정 타이머 | Java·Scala·Python·SQL. 체크포인트·스냅샷·자동 확장을 서비스가 처리 |

> 🧠 **원리** — Firehose의 Lambda 변환은 레코드를 하나씩 호출하지 않고 **버퍼링한 배치를 동기 호출**합니다. 그래서 "버퍼 크기 ≤ 6 MB, 응답 ≤ 6 MB, 5분 이내"라는 세 숫자가 동시에 걸립니다. Glue 스트리밍은 체크포인트로 읽은 위치를 추적하므로 멈췄다 재시작해도 이어서 처리하고, 처음부터 다시 하려면 체크포인트 폴더를 지웁니다.

### 8) Feature Store — 특성 생성·관리 {#feature-store}

| 요소 | 요건 |
|---|---|
| 특성 그룹 | 이름은 리전·계정 안에서 고유. **온라인·오프라인 설정 중 최소 하나** 필요 |
| 특성 정의 | 이름 + 타입(Integral·Fractional·String). 그룹당 **최대 2,500개**. `is_deleted`·`write_time`·`api_invocation_time`은 이름으로 쓸 수 없음 |
| 레코드 식별자 | 필수. 식별자 값별 **최신 레코드만** 온라인에 저장 |
| 이벤트 시간 | 필수. Fractional은 Unix 초, String은 ISO-8601 |

- **오프라인 스토어는 고객 계정의 S3에 append-only로 쌓이며 파일 형식은 Parquet뿐**입니다. 테이블 형식은 Glue(기본, 시간 단위 파티션)와 Apache Iceberg(일 단위 파티션)이고 파티션 단위는 구성할 수 없습니다. 레코드에는 `api_invocation_time`·`write_time`·`is_deleted`가 덧붙습니다.
- **TTL**: `ExpiresAt = EventTime + TtlDuration`. 특성 그룹 수준(기본값) 또는 레코드 수준(`PutRecord`, 우선)으로 지정합니다. **온라인 스토어 없이 TTL을 쓰면 400 오류**이고, 만료 레코드는 온라인에서 하드 삭제되며 삭제 레코드는 오프라인에 추가됩니다.
- **`DeleteRecord`**: SoftDelete(기본, 값을 null로 두고 조회 불가)와 HardDelete 모두 **오프라인에 삭제 마커를 추가**합니다.
- **시점 정확 조인**: 오프라인 스토어가 append-only이고 이벤트 시간이 있어 과거 시점의 특성 값을 재현할 수 있습니다. 제품 문서는 이것이 **미래 데이터 유입(feature leakage)을 막는다**고 설명합니다.
- **교차 계정 공유**는 AWS RAM으로 합니다. **발견 가능성과 접근 권한은 따로** 부여해야 합니다 — 접근 권한만 주면 검색이 되지 않습니다.

### 9) 레이블링과 사람 검토 ⚠️ {#labeling}

| 서비스 | 현재 상태 |
|---|---|
| SageMaker Ground Truth | ⚠️ 신규 고객 불가. 기존 고객은 사용 가능, 신기능 계획 없음 |
| Amazon A2I | ⚠️ 2026-07 유지 모드, 신규 고객 불가 |
| Ground Truth Plus | ⚠️ 2026-06-30 지원 종료 |
| Mechanical Turk | ⚠️ 폐쇄(SageMaker 문서 2026-09-30, What's New 2026-09-29 — 하루 차이) |

**Ground Truth 핵심**

- 작업 인력 3종: Mechanical Turk · **비공개**(자체 직원, Cognito 또는 자체 OIDC) · **공급업체**(AWS Marketplace).
- **주석 통합**: 여러 작업자의 주석을 하나로 합칩니다(경계 상자는 IoU 기반 평균, 의미 분할은 픽셀 투표, 다중 클래스는 EM 변형).
- **자동 데이터 레이블링**: 능동 학습으로 사람이 레이블링할 데이터를 골라 비용을 줄입니다. 지원 유형은 **이미지 분류(단일)·의미 분할·객체 감지(경계 상자)·텍스트 분류(단일)** 4종이고, **최소 1,250개 객체**(5,000개 이상 강력 권장), 사용자 지정 작업 유형과 **스트리밍 잡은 불가**합니다.
- **검증 vs 조정**: 검증(verification)은 기존 레이블의 정확성을 표시·평가만 하고 **수정하지 못합니다.** 조정(adjustment)이 이전 주석을 수정합니다.
- MTurk 인력에는 **기밀·개인·보호 건강 정보를 보내면 안 되고**, 입력에 PII가 없음을 지정하지 않으면 잡이 실패합니다.

**A2I**는 AI 서비스(Textract·Rekognition 등)나 자체 모델의 **저신뢰 예측 또는 무작위 표본**을 사람이 검토하게 하는 워크플로입니다. 즉 Ground Truth는 **학습용 레이블을 처음부터 만드는 것**, A2I는 **운영 중 예측을 사람이 검토하는 것**입니다.

---

## ✍️ 시험 포인트

- "코드 없이, 레시피를 재사용" → **DataBrew**. "ML 데이터를 시각적으로 준비해 Feature Store로" → **Data Wrangler**. "서버리스 Spark + 카탈로그" → **Glue**. "클러스터 제어" → **EMR**. "SageMaker 안의 스크립트 잡" → **Processing**.
- 이상값에 강건한 스케일 → **Robust Scaler**(DataBrew는 Z_SCORE 계열).
- 범주가 매우 많고 오탈자가 섞였다 → **Similarity encode**.
- 공통 키 없이 중복을 찾는다 → **FindMatches**.
- 중첩 JSON을 관계형 테이블로 → **relationalize**.
- Firehose + Lambda 변환의 세 숫자(**6 MB 요청·6 MB 응답·5분**)는 자주 나옵니다. 변환 버퍼 힌트(0.2–3 MB)와 혼동하지 마세요.
- 자동 데이터 레이블링의 **최소 1,250개**와 지원 4종은 기억해 두세요.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| Fill missing과 Impute missing을 같은 것으로 본다 | Fill은 **지정한 값**, Impute는 **계산값**(평균·중앙값·최빈값) |
| REMOVE_DUPLICATES가 행 전체 중복을 지운다고 본다 | 행 전체 일치는 **DELETE_DUPLICATE_ROWS**, REMOVE_DUPLICATES는 **선택한 열** 기준 |
| Drop Null Fields가 빈 문자열·`-1`도 지워 준다고 본다 | **모든 값이 null인 열**만 제거한다. 자리표시자는 먼저 null로 바꿔야 한다 |
| 범주가 수천 개인데 원-핫을 쓴다 | 차원이 폭발한다 — **Similarity encode**(또는 Replace rare로 드문 범주 정리) |
| Data Wrangler 대화형 변환이 전체 데이터에 적용된다고 본다 | 대화형은 **샘플**에만 적용된다. 전체는 처리 잡으로 실행한다 |
| Feature Store 오프라인 스토어에 다른 형식을 기대한다 | 파일 형식은 **Parquet뿐**이고 append-only다 |
| 온라인 스토어 없이 TTL을 설정한다 | **400 오류**가 난다 |
| 교차 계정에서 접근 권한만 주고 검색을 기대한다 | **발견 가능성**은 따로 부여해야 한다 |
| 자동 데이터 레이블링을 스트리밍 잡이나 사용자 지정 작업 유형에 쓴다 | 둘 다 **불가**하고, 최소 1,250개 객체가 필요하다 |
| 레이블 '검증'이 잘못된 레이블을 고쳐 준다고 본다 | 검증은 표시·평가만, 수정은 **조정(adjustment)** |

---

## 🧪 자가 점검

1. 범주 값이 수천 개이고 오탈자가 많은 열을 인코딩해야 한다. 어떤 인코딩을 고르고, 그 방식이 one-hot과 다른 점은?
2. 중첩 JSON 로그를 관계형 테이블로 옮기려 한다. Glue의 어떤 메서드를 쓰고 무엇을 해 주는가?
3. Firehose에서 Lambda 변환이 타임아웃으로 실패한다. 확인할 한도 세 가지는?
4. 특성 그룹에 레코드를 넣었는데 온라인 조회에 나오지 않는다. 확인할 두 가지는?(이벤트 시간, TTL)
5. 레이블 품질이 낮아 다시 작업해야 한다. 검증과 조정 중 무엇을 골라야 하는가?

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며 C01 시험 범위는 아닙니다.

- **C02 대응 Task**: 1.2 「데이터 변환, 특성 추출 및 사전 처리를 수행합니다」
- **추가된 항목 5개**
  - `1.2.5` 임베딩 모델을 구성·사용해 텍스트·이미지를 **수치 표현으로 변환**
  - `1.2.6` 고급 텍스트 사전 처리(토큰화, 도메인별 증강)
  - `1.2.7` **RAG 애플리케이션용 문서 준비**(청킹 전략, 메타데이터 추출)
  - `1.2.8` 데이터 **마스킹·편집·익명화**
  - `1.2.9` **FM 미세 조정·지속적 사전 훈련·모델 증류**용 데이터 준비
- **삭제된 항목**: 이 Task에는 없음

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- [Transform Data (Data Wrangler)](https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html) · [Transform data (Canvas)](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-transform.html) · [How data processing works in Data Wrangler](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-data-processing.html) · [Export](https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-data-export.html)
- [What is AWS Glue DataBrew?](https://docs.aws.amazon.com/databrew/latest/dg/what-is.html) · [DataBrew recipes](https://docs.aws.amazon.com/databrew/latest/dg/recipes.html) · [Data science recipe steps](https://docs.aws.amazon.com/databrew/latest/dg/recipe-actions.data-science.html) · [ONE_HOT_ENCODING](https://docs.aws.amazon.com/databrew/latest/dg/recipe-actions.ONE_HOT_ENCODING.html) · [BUCKETIZATION](https://docs.aws.amazon.com/databrew/latest/dg/recipe-actions.BUCKETIZATION.html) · [REMOVE_DUPLICATES](https://docs.aws.amazon.com/databrew/latest/dg/recipe-actions.REMOVE_DUPLICATES.html)
- [What is AWS Glue?](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html) · [Glue managed transforms](https://docs.aws.amazon.com/glue/latest/dg/edit-jobs-transforms.html) · [PySpark transforms reference](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-python-transforms.html) · [DynamicFrame class](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-crawler-pyspark-extensions-dynamic-frame.html) · [FindMatches](https://docs.aws.amazon.com/glue/latest/dg/machine-learning.html) · [Streaming ETL jobs](https://docs.aws.amazon.com/glue/latest/dg/add-job-streaming.html)
- [What is Amazon EMR?](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html) · [EMR Serverless](https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/emr-serverless.html) · [SageMaker Processing](https://docs.aws.amazon.com/sagemaker/latest/dg/processing-job.html)
- [Transform source data in Firehose](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html) · [Convert input data format](https://docs.aws.amazon.com/firehose/latest/dev/record-format-conversion.html) · [Managed Service for Apache Flink](https://docs.aws.amazon.com/managed-flink/latest/java/what-is.html)
- [Feature Store 개요](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store.html) · [Feature Store 개념](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-concepts.html) · [오프라인 스토어 형식](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-offline.html) · [TTL](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-time-to-live.html) · [데이터셋 만들기(시점 정확 조인)](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-create-a-dataset.html) · [교차 계정 공유](https://docs.aws.amazon.com/sagemaker/latest/dg/feature-store-cross-account.html)
- [Ground Truth 개요](https://docs.aws.amazon.com/sagemaker/latest/dg/sms.html) · [자동 데이터 레이블링](https://docs.aws.amazon.com/sagemaker/latest/dg/sms-automated-labeling.html) · [주석 통합](https://docs.aws.amazon.com/sagemaker/latest/dg/sms-annotation-consolidation.html) · [레이블 검증·조정](https://docs.aws.amazon.com/sagemaker/latest/dg/sms-verification-data.html) · [작업 인력](https://docs.aws.amazon.com/sagemaker/latest/dg/sms-workforce-management.html) · [Amazon A2I](https://docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html)
- [Well-Architected ML Lens: 특성 엔지니어링](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/feature-engineering.html) · [How linear learner works](https://docs.aws.amazon.com/sagemaker/latest/dg/ll_how-it-works.html) · [AWS 서비스 수명주기](https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html)

조사 노트: `docs/content-research/MLA-C01/tasks/1-2.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
