---
examGuideTaskId: aip-t1-3
certCode: AIP-C01
domain: 1
domainName: 파운데이션 모델 통합, 데이터 관리 및 규정 준수
domainWeightPct: 31
title: 데이터 검증과 처리 파이프라인 (품질 규칙·멀티모달 처리·입력 형식·입력 품질 개선)
coversTasks:
  - "1.3"
sources:
  - title: AWS Glue Data Quality
    url: https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html
  - title: Getting started with AWS Glue Data Quality for the Data Catalog
    url: https://docs.aws.amazon.com/glue/latest/dg/data-quality-getting-started.html
  - title: Data preparation (SageMaker Canvas)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-data-prep.html
  - title: Migrate the UI from Studio Classic to Studio
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-ui.html
  - title: How Amazon SageMaker Processing Configures Input and Output For Your Processing Container
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/byoc-input-and-output.html
  - title: How Amazon Transcribe works
    url: https://docs.aws.amazon.com/transcribe/latest/dg/how-it-works.html
  - title: Data input and output (Amazon Transcribe)
    url: https://docs.aws.amazon.com/transcribe/latest/dg/how-input.html
  - title: Converse (Amazon Bedrock Runtime API Reference)
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
  - title: Entities (Amazon Comprehend)
    url: https://docs.aws.amazon.com/comprehend/latest/dg/how-entities.html
  - title: Amazon Comprehend availability change
    url: https://docs.aws.amazon.com/comprehend/latest/dg/comprehend-availability-change.html
lastVerified: 2026-11-14
---

# 데이터 검증과 처리 파이프라인 (품질 규칙·멀티모달 처리·입력 형식·입력 품질 개선)

> **커버하는 공식 Task** — AIP-C01 · 도메인 1 「파운데이션 모델 통합, 데이터 관리 및 규정 준수」(31%) · **작업 1.3 FM 사용을 위한 데이터 검증 및 처리 파이프라인 구현** (`aip-t1-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(1.3.1~1.3.4)를 모두 덮습니다. 네 기술은 **「검증 → 처리 → 형식 → 품질 개선」** 순서로 한 파이프라인을 만듭니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Glue Data Quality의 **진입점 둘**과 각각이 보는 것을 말할 수 있다
- [ ] **DQDL**과 권장 규칙을 **그대로 쓰지 않는 이유**를 안다
- [ ] ⚠️ **Data Wrangler에 어떻게 접근하는지**(Canvas) 안다
- [ ] SageMaker Processing의 **컨테이너 경로 규칙**을 안다
- [ ] Transcribe의 **배치 ↔ 스트리밍** 차이와 기능 지원 차이를 안다
- [ ] `Converse`가 모델 간 코드 재사용을 어떻게 만드는지 설명할 수 있다
- [ ] Comprehend 엔터티 탐지의 **언어 제약**과 사용자 지정 인식의 차이를 안다
- [ ] Comprehend에서 **어느 기능이 유지 관리 상태인지** 안다

---

## 🎯 왜 중요한가

FM에 들어가는 데이터는 **모델이 고쳐 주지 않습니다.** 잘못된 값, 빠진 필드, 형식이 어긋난 요청은 그대로 응답 품질로 내려갑니다. 그런데 GenAI 파이프라인의 데이터는 전통적 ETL과 달라서 **표 형식만 오지 않습니다** — 텍스트·이미지·오디오·표가 섞여 들어오고, 각각 처리 수단이 다릅니다.

그래서 이 작업은 「어느 서비스를 쓰나」보다 **「이 데이터 유형에 맞는 수단이 무엇이고, 그 수단의 제약이 무엇인가」**를 묻습니다. 그리고 이 자격증의 도메인 1은 **규정 준수**를 함께 다루므로, 처리 과정에서 **데이터가 어디에 머무는지**를 아는 것이 같은 비중으로 중요합니다.

---

## ⚡ 시험 직전 요약

- Glue Data Quality는 **오픈소스 DeeQu 기반**의 서버리스 관리형이고 **DQDL**로 규칙을 쓴다. **25개 이상 내장 규칙**과 **데이터 품질 점수**를 준다.
- ⚠️ 진입점이 **둘**이다 — **Data Catalog**(정지 데이터: 테이블과 지원되는 Athena 뷰) · **Glue ETL 작업**(이동 중 데이터).
- ⚠️ **권장 규칙은 그대로 쓰지 않고 검토·편집한 뒤** 평가에 씁니다(공식 지시).
- ⚠️⚠️ **Data Wrangler는 이제 SageMaker Canvas로 접근한다** — 새 Studio 경험은 **클래식 Data Wrangler UI를 지원하지 않고** Canvas 애플리케이션을 만들어야 하며 **권한이 더 필요**하다.
- SageMaker Processing의 컨테이너 입출력 경로는 **반드시 `/opt/ml/processing/`로 시작**해야 하고 ⚠️ **심볼릭 링크로는 출력을 업로드할 수 없다**.
- Transcribe는 **배치**(S3의 미디어 파일)와 **스트리밍**(실시간) 둘이고 ⚠️⚠️ **둘의 기능·언어 지원이 다르다**. API는 `StartTranscriptionJob` / `StartStreamTranscription`.
- ⚠️ Transcribe는 **분석 모델 품질 개선을 위해 콘텐츠를 일시 저장할 수 있고**, 삭제를 원하면 **Support 케이스**를 엽니다.
- `Converse`는 **메시지를 지원하는 모든 모델에 같은 인터페이스**를 줘서 **한 번 쓴 코드를 여러 모델에 쓰게** 한다. 모델 고유 파라미터는 따로 넘긴다.
- ⭐ **Bedrock은 콘텐츠로 제공한 텍스트·이미지·문서를 저장하지 않는다** — 응답 생성에만 쓴다.
- Comprehend 엔터티는 **9개 유형**이고 신뢰도 **점수로 걸러낸다**. ⚠️ **모든 문서가 같은 언어여야** 하고, 주요 언어 전체 지원은 **사전 정의 엔터티**에만 해당한다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **DQDL** | Data Quality Definition Language — Glue Data Quality에서 규칙을 쓰는 도메인 특화 언어 |
| **DeeQu** | Glue Data Quality가 올라가 있는 오픈소스 프레임워크 |
| **데이터 품질 점수** | 규칙 평가 결과를 데이터 건강 상태로 요약한 값 |
| **배치 전사 / 스트리밍 전사** | S3에 올린 미디어 파일을 전사 / 미디어 스트림을 실시간 전사 |
| **엔터티** | 사람·장소·상품 같은 실세계 객체의 고유 이름, 또는 날짜·수량 같은 정확한 참조 |
| **추론 구성 요소** | 엔드포인트 위에서 모델·어댑터를 담는 배포 단위(작업 1.2에서 다룹니다) |

---

## 📖 핵심 개념

### 1) 데이터가 품질 표준을 넘는지 검증한다 (기술 1.3.1) {#validation}

> 🧠 원리: 품질 검증은 **규칙을 쓰는 일**이고, 규칙을 처음부터 손으로 쓰면 아무도 쓰지 않습니다. 그래서 Glue Data Quality는 **데이터를 분석해 규칙을 먼저 제안**하고, 사람은 **고르고 고치는** 일을 합니다.

**AWS Glue Data Quality**가 적는 성질:

- **오픈소스 DeeQu 프레임워크** 위에 올라간 **관리형·서버리스** 경험입니다. 설치·패치·유지 관리가 없습니다.
- 규칙은 **DQDL**로 씁니다 — 비즈니스 사용자도 이해할 수 있는 언어이면서, 엔지니어에게는 **코드 생성·버전 관리·배포 자동화**의 유연성을 줍니다.
- **두 번의 클릭으로 시작**합니다 — `Create Data Quality Rules → Recommend rules`.
- **25개 이상의 내장 규칙**에서 출발해 필요에 맞게 고칩니다.
- 평가하면 **데이터 품질 점수**가 나와 데이터 건강 상태를 요약합니다.
- ⭐ **점수를 떨어뜨린 정확한 레코드를 찾아** 격리하고 고칠 수 있습니다.
- **ML로 이상과 탐지하기 어려운 품질 문제**를 잡습니다.
- 라이선스가 없는 **사용한 만큼 과금**이고, DeeQu 기반이라 **규칙에 잠금(lock-in)이 없습니다**.

⚠️ **진입점이 둘이고 보는 데이터가 다릅니다**:

| 진입점 | 보는 것 |
|---|---|
| **AWS Glue Data Catalog** | 카탈로그에 저장된 **테이블과 지원되는 Amazon Athena 뷰**를 평가한다. 비개발자가 규칙을 세우기 쉽다 — **정지 데이터**(at rest) |
| **AWS Glue ETL 작업** | 파이프라인 안에서 평가한다 — **이동 중 데이터**(in transit) |

권장 규칙의 예와 뜻(공식 예시):

- `IsComplete "SET_FINE_AMOUNT"` — 그 열이 **모든 행에서 채워져** 있는지. 열을 **필수**로 표시할 때 씁니다.
- `Uniqueness "TICKET_NUMBER" > 0.95` — 열 안 데이터가 **고유성 임계**를 넘는지.
- `ColumnValues "PROVINCE" in ["ON","QC","AB","NY",...]` — 기존 내용에 근거한 **유효 값 집합**.
- `ColumnLength "INFRACTION_DESCRIPTION" between 15 and 31` — **길이 제약**(표본의 최소·최대 길이에서 생성).

⚠️⚠️ **공식이 「쓰기 전에 검토하고 편집하라」고 명시합니다** — 권장 규칙은 **표본 데이터의 경계에서 나온 것**이어서 그대로 운영에 걸면 정상 데이터를 거부할 수 있습니다.

⚠️⚠️ **`SageMaker Data Wrangler`는 접근 경로가 바뀌었습니다.** 공식 데이터 준비 문서의 Note가 적습니다 — 전에는 **Studio Classic** 경험의 일부였고, **새 Studio 경험으로 업데이트하면 Data Wrangler에 접근하고 최신 기능 업데이트를 받으려면 SageMaker Canvas를 써야 합니다.** 마이그레이션 문서는 더 분명합니다: **새 Studio 경험은 클래식 Data Wrangler UI를 지원하지 않고, 계속 쓰려면 Canvas 애플리케이션을 만들어야 하며 그 권한이 필요합니다**(예: `AmazonSageMakerFullAccess` 또는 범위를 좁힌 정책 + `sagemaker:CreateApp`·`DeleteApp`).

Canvas 안의 Data Wrangler가 주는 것: **데이터 플로**(ML 데이터 준비 단계의 연쇄) · **변환**(문자열·벡터·수치 서식, 텍스트·날짜 임베딩, 범주형 인코딩) · ⭐ **데이터 인사이트 생성**(Data Quality and Insights Report로 품질을 자동 검증하고 이상을 탐지) · **분석**(산점도·히스토그램, **타깃 누수 분석**, 빠른 모델링) · **내보내기**(S3 · **Feature Store**) · **데이터 준비 자동화**.

그리고 **CloudWatch 지표**로 검증 워크플로 자체를 관찰합니다(실패율·지연 등). 지표 설계는 깊이 노트 `93`의 관찰성 절과 같은 틀을 씁니다.

### 2) 복잡한 데이터 유형을 처리한다 (기술 1.3.2) {#processing}

> 🧠 원리: 텍스트·이미지·오디오·표가 섞이면 **한 서비스로 끝나지 않습니다.** 각 유형을 FM이 읽을 수 있는 형태로 바꾸는 **전처리 단계**가 필요하고, 그 단계가 어디서 도는지가 아키텍처입니다.

**SageMaker Processing** — 전처리·후처리를 컨테이너로 돌리는 자리입니다.

- `CreateProcessingJob`에 **여러 `ProcessingInput`과 `ProcessingOutput`**을 줍니다. 입력은 **S3 URI → 컨테이너 경로**, 출력은 **컨테이너 경로 → S3 URI**입니다.
- ⚠️⚠️ **입력과 출력 모두 컨테이너 안 경로가 `/opt/ml/processing/`으로 시작해야 합니다.**
- ⚠️⚠️ **심볼릭 링크(symlink)로는 출력 데이터를 S3에 업로드할 수 없습니다** — 업로드할 때 심링크를 따라가지 않습니다.
- 구성은 환경 변수와 **두 개의 JSON 파일**로 들어옵니다 — `/opt/ml/config/processingjobconfig.json`(입출력·호스트 이름 등)과 `/opt/ml/config/resourceconfig.json`.
- 입력에는 `S3DataDistributionType`·`S3InputMode`·`S3DownloadMode`, 출력에는 **`S3UploadMode`**(예: `EndOfJob`)를 둡니다.

**Amazon Transcribe** — 오디오를 텍스트로 바꿉니다.

- 전사 결과에는 텍스트와 함께 **단어·구두점마다 신뢰도 점수와 타임스탬프**가 들어갑니다.
- 방식이 **두 범주**입니다:

| | **배치 전사** | **스트리밍 전사** |
|---|---|---|
| 입력 | **S3 버킷에 업로드된 미디어 파일** | **실시간 미디어 스트림** |
| 수단 | AWS CLI · 콘솔 · SDK | 콘솔 · **HTTP/2** · **WebSockets** · SDK |
| API | **`StartTranscriptionJob`** | **`StartStreamTranscription`**(WebSocket 변형 포함) |

- ⚠️⚠️ **배치와 스트리밍의 기능 지원과 언어 지원이 다릅니다**(공식 Note). 「스트리밍에서도 같은 기능을 쓸 수 있다」고 가정하면 틀립니다.
- ⭐ 배치에는 **작업 큐잉**이 있어 동시에 다 처리할 필요가 없으면 Transcribe가 슬롯이 날 때 처리합니다.
- ⚠️⚠️ **규정 준수 포인트**: Transcribe는 **분석 모델 품질을 지속적으로 개선하기 위해 콘텐츠를 일시적으로 저장할 수 있습니다.** 저장됐을 수 있는 콘텐츠의 삭제를 요청하려면 **Support 케이스를 엽니다**.

**Bedrock 멀티모달** — `Converse`로 이미지와 문서를 메시지에 담아 보냅니다. 세부는 §3입니다.

### 3) FM 추론용 입력 형식을 맞춘다 (기술 1.3.3) {#format}

> 🧠 원리: 모델마다 요청 본문이 다르면 **모델을 바꿀 때 코드를 고쳐야** 합니다. `Converse`는 그 문제를 인터페이스 통일로 풉니다 — 작업 1.2의 「코드 수정 없는 전환」과 같은 목표를 **API 층에서** 달성합니다.

공식 `Converse` API 참조가 적는 성질:

- **메시지를 지원하는 모든 모델과 동작하는 일관된 인터페이스**를 제공합니다. 그래서 ⭐ **코드를 한 번 쓰고 여러 모델에 쓸 수 있습니다.**
- 모델에 **고유한 추론 파라미터**가 있으면 그 파라미터도 함께 넘길 수 있습니다.
- 프롬프트는 **`messages` 필드**에 넣고 `modelId`로 FM 또는 **추론 프로필**을 지정합니다.
- ⭐ **Prompt management의 프롬프트 버전 ARN**을 지정하고 **`promptVariables`에 변수 맵**을 주는 방식으로도 호출합니다. 그 경우 `messages`로 메시지를 **덧붙일** 수 있습니다.
- ⚠️⚠️ **Amazon Bedrock은 콘텐츠로 제공한 텍스트·이미지·문서를 저장하지 않습니다** — 데이터는 **응답 생성에만** 쓰입니다. 도메인 1의 규정 준수 질문에서 자주 쓰이는 문장입니다.
- 응답에는 **`usage`**(입력+출력 토큰 합계)와 **`metrics`**가 함께 옵니다 — 형식 검증과 비용 추적을 같은 응답에서 합니다.

SageMaker AI 엔드포인트를 쓰는 경로라면 형식은 **엔드포인트가 받는 구조화 데이터**에 맞춥니다(같은 「형식 지정」 작업이지만 **계약이 Bedrock과 다릅니다**). 대화 기반 애플리케이션이면 역할(`user`/`assistant`)이 번갈아 오는 **대화 형식**을 유지해야 합니다.

### 4) 입력 품질을 올려 응답 품질을 올린다 (기술 1.3.4) {#enrich}

> 🧠 원리: 같은 모델이라도 **입력이 정리돼 있으면 응답이 안정됩니다.** 그래서 이 기술은 FM 앞에 **작은 전처리 모델과 함수**를 두는 패턴입니다.

**Amazon Comprehend 엔터티 추출** — 공식이 적는 사실:

- **엔터티**는 사람·장소·상품 같은 실세계 객체의 고유 이름, 또는 날짜·수량 같은 정확한 참조입니다.
- 유형이 **9개**입니다 — `COMMERCIAL_ITEM` · `DATE` · `EVENT` · `LOCATION` · `ORGANIZATION` · `OTHER` · `PERSON` · `QUANTITY` · `TITLE`.
- 각 엔터티에 **신뢰도 점수**가 붙고, ⭐ **점수가 낮은 것을 걸러내 잘못된 탐지의 위험을 줄입니다.**
- API 셋: **`DetectEntities`**(동기·단건) · **`BatchDetectEntities`**(문서마다 목록을 돌려준다) · **`StartEntitiesDetectionJob`**(비동기 작업이 문서별 엔터티 목록 파일을 만든다).
- ⚠️⚠️ **언어 제약이 둘입니다** — 주요 지원 언어 전체에서 되는 것은 **사전 정의(비사용자 지정) 엔터티 탐지**뿐이고, **모든 문서가 같은 언어여야** 합니다.
- 응답에는 `Text`·`Score`·`Type`과 **`BeginOffset`·`EndOffset`**이 들어갑니다.

⚠️⚠️ **Comprehend에서 유지 관리 상태인 기능이 있습니다.** 공식 가용성 변경 페이지가 **주제 모델링(Topic Modeling) · 이벤트 탐지(Event Detection) · 프롬프트 안전 분류(Prompt Safety Classification)**를 **2026-03-31** 공지로 적습니다. ⭐ **엔터티 탐지는 그 셋에 들어 있지 않습니다** — 기술 1.3.4가 드는 「Comprehend로 항목 추출」은 유효한 경로입니다. 다만 **새 설계에서 주제 모델링이나 프롬프트 안전 분류를 고르면** 공식이 닫고 있는 쪽을 쓰는 것입니다.

나머지 두 수단:

- **Bedrock으로 텍스트 다시 쓰기** — 들어온 텍스트를 FM이 정규화·재작성하게 합니다. 같은 `Converse` 인터페이스를 씁니다(§3).
- **Lambda로 데이터 정규화** — 결정적이고 가벼운 변환(공백·대소문자·단위·날짜 형식)은 LLM을 부르지 않습니다. ⭐ **LLM을 쓰지 않아도 되는 일에 LLM을 쓰지 않는 것**이 이 작업의 설계 감각입니다.

---

## ✍️ 시험 포인트

- 「카탈로그의 테이블을 평가」면 **Data Catalog 진입점**, 「파이프라인 안에서 평가」면 **ETL 작업 진입점**입니다.
- 「권장 규칙을 바로 운영에 적용했다」는 보기는 공식 지시(**검토·편집 후 사용**)와 어긋납니다.
- Data Wrangler가 보기에 나오면 **Canvas 경로**를 확인합니다 — 새 Studio에서 클래식 UI는 없습니다.
- 「출력이 S3에 올라가지 않는다」 + Processing이면 **경로가 `/opt/ml/processing/`인지**와 **심링크를 쓰지 않았는지**를 봅니다.
- 「실시간 자막」은 **스트리밍**, 「녹음 파일 일괄 전사」는 **배치**이고, **기능 지원이 다릅니다**.
- 「여러 모델을 바꿔 쓰면서 코드를 유지」면 **`Converse`**입니다.
- 「프롬프트로 보낸 문서가 저장되는가」는 **저장되지 않는다**가 답입니다.
- 「여러 언어가 섞인 문서 묶음에서 엔터티 추출」은 **같은 언어여야 한다**는 제약에 걸립니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️ **Glue Data Quality를 ETL 전용으로 외우기.** **Data Catalog 진입점**이 따로 있습니다.
- ⚠️⚠️ **권장 규칙을 「자동 생성이니 정확하다」로 믿기.** 표본 경계에서 나온 값입니다.
- ⚠️⚠️ **Data Wrangler를 Studio Classic UI에서 찾기.** 새 Studio는 그 UI를 지원하지 않습니다.
- ⚠️ **Processing 컨테이너의 입출력 경로를 임의로 두기.** `/opt/ml/processing/`로 시작해야 합니다.
- ⚠️ **심링크로 출력 경로를 가리키기.** 업로드되지 않습니다.
- ⚠️⚠️ **배치에서 쓰던 Transcribe 기능이 스트리밍에서도 된다고 가정하기.**
- ⚠️ **Transcribe가 콘텐츠를 저장하지 않는다고 단정하기.** 공식은 **일시 저장 가능성**과 **Support 케이스를 통한 삭제 요청**을 적습니다.
- ⚠️ **Comprehend 전체가 유지 관리라고 읽기.** 닫히는 것은 **주제 모델링·이벤트 탐지·프롬프트 안전 분류**이고 **엔터티 탐지는 아닙니다**.
- ⚠️ **정규화까지 LLM으로 하기.** 결정적 변환은 Lambda가 싸고 빠릅니다.

---

## 🧪 자가 점검

**Q1.** Glue Data Quality로 **카탈로그에 있는 테이블**의 품질을 보려고 합니다. 규칙을 어떻게 만들고, 만든 규칙을 바로 써도 됩니까?

<details><summary>정답 보기</summary>

**Data Catalog 진입점**에서 `Create Data Quality Rules → Recommend rules`로 **권장 규칙을 생성**합니다(DQDL). ⚠️ **그대로 쓰지 않습니다** — 공식은 **평가에 쓰기 전에 검토하고 편집**하라고 적습니다. 권장 규칙은 표본 데이터의 경계(최소·최대 길이, 고유성 임계 등)에서 나온 값이라 정상 데이터를 거부할 수 있습니다.
</details>

**Q2.** 팀이 새 SageMaker Studio 경험으로 옮겼는데 Data Wrangler 플로를 열 수 없습니다. 무엇을 해야 합니까?

<details><summary>정답 보기</summary>

**SageMaker Canvas 애플리케이션을 만들어 거기서 Data Wrangler를 씁니다.** 새 Studio 경험은 **클래식 Data Wrangler UI를 지원하지 않고**, Canvas가 Data Wrangler 기반 데이터 준비 기능을 제공합니다. ⚠️ Canvas 애플리케이션을 만들고 쓸 **권한이 추가로 필요**합니다(`AmazonSageMakerFullAccess` 또는 `sagemaker:CreateApp`·`DeleteApp`을 포함한 범위 축소 정책).
</details>

**Q3.** SageMaker Processing 작업이 성공으로 끝나는데 S3에 출력이 없습니다. 먼저 확인할 두 가지는 무엇입니까?

<details><summary>정답 보기</summary>

**① 컨테이너 안 출력 경로가 `/opt/ml/processing/`으로 시작하는지**(입력·출력 모두 그 접두사가 필수입니다). **② 출력 경로가 심볼릭 링크인지** — **심링크는 업로드할 때 따라가지 않으므로 출력이 올라가지 않습니다.** 덧붙여 `S3UploadMode`(예: `EndOfJob`) 설정도 봅니다.
</details>

**Q4.** 회의 녹음 파일 1,000개를 전사해 FM에 넣으려 합니다. 어떤 방식이고, 실시간 자막과 무엇이 다릅니까?

<details><summary>정답 보기</summary>

S3에 올린 파일이므로 **배치 전사**(`StartTranscriptionJob`)이고, 동시 처리가 필요 없으면 **작업 큐잉**을 씁니다. 실시간 자막은 **스트리밍 전사**(`StartStreamTranscription`, HTTP/2·WebSockets)입니다. ⚠️⚠️ **둘의 기능 지원과 언어 지원이 다르므로** 배치에서 쓰던 기능이 스트리밍에서 된다고 가정할 수 없습니다.
</details>

**Q5.** 여러 FM을 바꿔 쓰면서 애플리케이션 코드를 그대로 두고 싶습니다. 어떤 API를 쓰고, 모델 고유 파라미터는 어떻게 넘깁니까?

<details><summary>정답 보기</summary>

**`Converse`**를 씁니다 — 메시지를 지원하는 모든 모델에 **일관된 인터페이스**를 주므로 **코드를 한 번 쓰고 여러 모델에 쓸 수 있습니다.** 모델에 고유한 추론 파라미터가 있으면 **그 파라미터를 함께 전달**할 수 있습니다. `modelId`에는 FM 또는 **추론 프로필**을 지정하고, Prompt management의 **프롬프트 버전 ARN + `promptVariables`**로도 호출할 수 있습니다.
</details>

**Q6.** 규정 준수 검토에서 「프롬프트로 보낸 계약서 PDF가 Bedrock에 남는가」를 묻습니다. 무엇이라고 답합니까?

<details><summary>정답 보기</summary>

**남지 않습니다.** 공식 `Converse` 참조가 **Amazon Bedrock은 콘텐츠로 제공한 텍스트·이미지·문서를 저장하지 않고 데이터는 응답 생성에만 쓰인다**고 적습니다. ⚠️ 다만 **Transcribe는 다릅니다** — 분석 모델 개선을 위해 콘텐츠를 **일시 저장할 수 있고** 삭제 요청은 **Support 케이스**로 합니다. 서비스마다 확인해야 합니다.
</details>

**Q7.** 한국어와 영어가 섞인 문서 묶음에서 Comprehend로 사람 이름과 날짜를 뽑으려 합니다. 무엇이 문제입니까?

<details><summary>정답 보기</summary>

⚠️ **모든 문서가 같은 언어여야 합니다.** 그리고 주요 지원 언어 전체에서 되는 것은 **사전 정의(비사용자 지정) 엔터티 탐지**뿐입니다. 언어별로 묶어 따로 호출해야 하고, 뽑으려는 `PERSON`·`DATE`는 사전 정의 9개 유형에 들어 있으므로 **신뢰도 점수로 낮은 탐지를 걸러내며** 쓰면 됩니다.
</details>

**Q8.** 새 설계에서 Comprehend의 **프롬프트 안전 분류**를 입력 필터로 쓰려 합니다. 무엇을 확인해야 합니까?

<details><summary>정답 보기</summary>

공식 가용성 변경 페이지가 **주제 모델링 · 이벤트 탐지 · 프롬프트 안전 분류**를 **2026-03-31** 공지로 적습니다 — **새 설계에서 고르면 공식이 닫고 있는 쪽**입니다. ⭐ 반면 **엔터티 탐지는 그 목록에 없어** 계속 쓸 수 있습니다. 입력·출력 안전 제어는 도메인 3(작업 3.1)에서 다루는 수단을 먼저 봅니다.
</details>

---

### 📌 출처

1. AWS Glue Data Quality (DeeQu · DQDL · 25+ 규칙 · 진입점 둘 · 품질 점수) — `docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html` (2026-11-14 확인)
2. Getting started with AWS Glue Data Quality for the Data Catalog (권장 규칙의 뜻과 **검토·편집 지시**) — `docs.aws.amazon.com/glue/latest/dg/data-quality-getting-started.html` (2026-11-14 확인)
3. Data preparation (SageMaker Canvas) (Data Wrangler는 Canvas로 · 기능 묶음) — `docs.aws.amazon.com/sagemaker/latest/dg/canvas-data-prep.html` (2026-11-14 확인)
4. Migrate the UI from Studio Classic to Studio (새 Studio는 클래식 UI 미지원 · 필요한 권한) — `docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-ui.html` (2026-11-14 확인)
5. How SageMaker Processing Configures Input and Output (`/opt/ml/processing/` · 심링크 불가) — `docs.aws.amazon.com/sagemaker/latest/dg/byoc-input-and-output.html` (2026-11-14 확인)
6. How Amazon Transcribe works (배치 ↔ 스트리밍 · API · 기능·언어 지원 차이) — `docs.aws.amazon.com/transcribe/latest/dg/how-it-works.html` (2026-11-14 확인)
7. Data input and output (Amazon Transcribe) (작업 큐잉 · **콘텐츠 일시 저장과 삭제 요청**) — `docs.aws.amazon.com/transcribe/latest/dg/how-input.html` (2026-11-14 확인)
8. Converse (API Reference) (일관된 인터페이스 · 콘텐츠 미저장 · Prompt management ARN) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html` (2026-11-14 확인)
9. Entities (Amazon Comprehend) (9개 유형 · 신뢰도 점수 · API 셋 · 언어 제약) — `docs.aws.amazon.com/comprehend/latest/dg/how-entities.html` (2026-11-14 확인)
10. Amazon Comprehend availability change (유지 관리 상태인 세 기능) — `docs.aws.amazon.com/comprehend/latest/dg/comprehend-availability-change.html` (2026-11-14 확인)
