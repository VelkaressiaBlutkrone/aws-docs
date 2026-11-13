---
생성: 2026-11-13
목적: AIP-C01 깊이 조사 ① — RAG · 벡터 저장소 · 검색 (P-03 1/3)
조회일: 2026-11-13
---

# AIP-C01 — 95 RAG · 벡터 저장소 · 검색

> 저작 입력의 정본은 [00-overview.md](00-overview.md) §3 공식 전사이고, 저작 규율은
> [98-authoring-decisions.md](98-authoring-decisions.md), 판정하지 못한 것은
> [99-gaps.md](99-gaps.md)다. 이 노트는 **그 기술들을 쓰려면 알아야 하는 공식 사실의 측정 기록**이다.
> 서비스 상태(닫힘·개명)는 [96-service-status-audit.md](96-service-status-audit.md)가 정본이다.

## 1. 이 축의 범위 — 번호로 센다

| 자리 | 기술 | 수 |
|---|---|---:|
| 작업 1.4 벡터 저장소 솔루션 설계 및 구현 | 1.4.1 ~ 1.4.5 | 5 |
| 작업 1.5 FM 증강을 위한 검색 메커니즘 설계 | 1.5.1 ~ 1.5.6 | 6 |
| 주변 — 성능 | 4.2.2(검색 성능) · 4.2.6(벡터 DB 쿼리 최적화) | 2 |
| 주변 — 평가 | 5.1.5(RAG 평가) · 5.1.6(검색 품질 테스트) | 2 |
| 주변 — 문제 해결 | 5.2.1(컨텍스트 창·청킹) · 5.2.4(검색 시스템) | 2 |
| | **합계** | **17** |

⚠️ **98 P-03이 적은 「기술 20개」는 어림이다** — 번호로 세면 **17**이다(작업 1.4·1.5 열한 개 +
주변 여섯 개). 노트를 쓰며 바로잡았다.

## 2. Amazon Bedrock Knowledge Bases — 유형이 **둘**이고 권장이 갈린다

공식 `knowledge-base.html`이 **두 유형**을 적고 **Important로 관리형을 권장**한다
(`For optimized retrieval accuracy and a managed experience, we recommend Amazon Bedrock
Managed Knowledge Base`). 같은 권장 문구가 Kendra GenAI 인덱스 페이지에도 붙는다.

| | Managed Knowledge Base | Customer-managed Knowledge Base |
|---|---|---|
| 인프라 | Bedrock이 **ingestion·indexing·storage·retrieval**을 관리 | 내가 벡터 스토어를 세운다 |
| 모델 | 임베딩·리랭킹·추론을 **서비스 관리형 모델**로(내 모델 선택 가능) | 내가 고른다 |
| 데이터 | **멀티모달** 수집 · 스토리지 **자동 확장** | — |
| 검색 | **Agentic Retrieval**(다단계 추론) | 단일 검색 패스 |
| 통합 | **AgentCore Gateway와 네이티브 통합** | — |
| 커넥터 | S3 · SharePoint · Confluence · Google Drive · OneDrive · **Web Crawler** | — |
| 권한 | 검색 시점 **ACL 문서 수준 필터링**(⚠️ **Web Crawler 제외**) | — |
| 파싱 | **Smart Parsing** — 문서 유형별 전략 자동 선택 | 파싱 옵션을 내가 고른다 |
| 관찰성 | **AgentCore Observability** 네이티브(검색 추적·에이전틱 추적·KB별 지표) | — |

### 2-1. ⭐ `기술 1.5.6`의 **MCP 클라이언트**가 여기서 근거를 얻는다

공식 문구: Managed KB가 **AgentCore Gateway와 네이티브로 통합돼 「any MCP-compatible agent
framework can discover and invoke your Knowledge Base as a tool without custom code」**다.
즉 `기술 1.5.6`의 「벡터 쿼리를 위한 모델 컨텍스트 프로토콜(MCP) 클라이언트」는 **AWS 문서가
직접 적는 경로**다(99 **G-09**가 「MCP는 범위 목록에 없는데 기술 본문이 이름으로 든다」로 남긴
항목 중 **RAG 축 몫을 닫는다** — 에이전틱 축은 노트 `94`가 본다).

### 2-2. Agentic Retrieval — 세 동작을 **한 묶음으로** 가르친다

`kb-test-agentic-retrieve.html`: FM이 ① 복잡한 쿼리를 **하위 쿼리로 분해**하고 ② **반복적으로**
여러 지식 베이스에서 검색하고 ③ 결과가 원 질문에 답하기에 **충분한지 평가**한다.
공식 예시 질문이 `"Which magazine was started first, Arthur's Magazine or First for Women?"`다.

⚠️ **두 페이지가 다른 낱말을 쓴다** — `knowledge-base.html`은 `multi-hop reasoning`이라 적지만
`kb-test-agentic-retrieve.html`에 `multi-hop`은 **0건**이다(`sub-quer` 7 · `sufficien` 3 ·
`iterativ` 1). **「공식이 multi-hop이라 부른다」를 그 페이지 근거로 적으면 틀린다.**

## 3. 벡터 스토어는 **8종**이고 성질이 갈린다

`knowledge-base-setup.html`의 탭을 기계로 세면 **정확히 8개**다:

**Amazon OpenSearch Serverless** · **OpenSearch Service Managed Clusters** · **Amazon S3 Vectors** ·
**Amazon Aurora (RDS)** · **Neptune Analytics graphs (GraphRAG)** · **Pinecone** ·
**Redis Enterprise Cloud** · **MongoDB Atlas**

갈림길이 되는 성질 셋(전부 실측):

1. ⚠️⚠️ **이진(binary) 벡터를 저장할 수 있는 것은 OpenSearch Serverless와 OpenSearch Managed
   Clusters 둘뿐이다.** 임베딩 벡터는 `float32`(차원당 32비트) 또는 **binary**(차원당 **1비트**)인데,
   **binary 임베딩 모델을 고르면 그것을 지원하는 모델과 벡터 스토어를 함께 골라야 한다.**
   (`kb-how-it-works.html` + `knowledge-base-setup.html`)
2. ⚠️⚠️ **하이브리드 검색은 Amazon RDS · OpenSearch Serverless · MongoDB 세 스토어만** 지원하고
   그마저 **필터 가능한 텍스트 필드가 있어야** 한다 — 없으면 **쿼리가 조용히 시맨틱 검색으로
   떨어진다**(`If you use a different vector store or your vector store doesn't contain a
   filterable text field, the query uses semantic search`). 검색 유형은 **Default**(Bedrock이
   결정) · **Hybrid**(벡터 + 원문) · **Semantic**(벡터만) 셋이다.
3. **Aurora만 메타데이터 필터용 필드를 미리 만들어야 한다** — 「다른 벡터 스토어에서 필터링을
   설정할 계획이면 이 필드를 만들지 않아도 된다」가 공식 문구다.

### 3-1. Amazon S3 Vectors — 값과 한계가 함께 적혀 있다

- `AmazonS3/latest/userguide/s3-vectors.html`: **AI 에이전트·추론·RAG·시맨틱 검색을 위한
  목적 특화 비용 최적화 벡터 저장소**이고 **인프라를 프로비저닝하지 않는 전용 API**를 쓴다.
  구성요소는 **벡터 버킷**(새 버킷 유형) · **벡터 인덱스** · **벡터**다.
- ⚠️ **지연 특성이 조건부다** — 「**드문 쿼리**에 대해 1초 미만, **더 빈번한 쿼리**에는 최저 100밀리초」.
  Bedrock 쪽 문서는 **`best suited for infrequent query workloads`**라고 적는다.
  **「가장 빠른 벡터 스토어」로 쓰면 거짓이고, 갈림길은 비용 ↔ 쿼리 빈도다.**
- ⚠️ 표·그림 맥락 교체(§4-1)를 쓸 때 **S3 벡터 버킷에서는 그 맥락이 벡터별 메타데이터 크기
  한도에 계산된다** — 인덱스 생성 시 `AMAZON_BEDROCK_TEXT`·`AMAZON_BEDROCK_METADATA`를
  **non-filterable 메타데이터 키**로 추가해야 한다.

### 3-2. Neptune Analytics(GraphRAG)와 Kendra GenAI 인덱스는 **벡터 스토어 선택이 아니다**

- **GraphRAG**는 벡터 스토어 탭에 있지만 성격이 다르다 — **벡터 검색 + 그래프 분석**을 합쳐
  **문서에서 엔티티·구조 관계를 자동으로 찾아 쓴다.** 공식이 드는 용례가 **「여러 논리 단계를
  거쳐 정보를 연결해야 할 때」**다.
- **Kendra GenAI 인덱스**는 **별 KB 유형**(TOC가 `knowledge-base-build-kendra-genai-index`로 분리)이고
  벡터 스토어 목록에 **0건**이다. 값은 **색인 재사용**(여러 Bedrock 애플리케이션에서 인덱스를
  다시 만들거나 재수집하지 않는다) + **Kendra의 고정확도 검색**이다.
  ⚠️ **Kendra 자체는 신규 고객에게 열려 있지 않다**(96 §5-1) — 공식이 권하는 대안이 바로
  **Bedrock Knowledge Bases**다. **새 설계의 답으로 Kendra를 고르게 하지 않는다.**
- **구조화 데이터 스토어 연결**도 별 유형이다 — Bedrock이 **사용자 쿼리를 구조화 스토어에서
  데이터를 꺼내는 언어로 변환**한다(내가 SQL을 쓰지 않는다).

## 4. 청킹 — 전략보다 **경계 조건**이 시험 소재다

`kb-chunking.html`은 **Standard**(fixed-size · default) · **Hierarchical** · **Semantic** ·
**Multimodal**을 적는다. 비자명한 것은 아래다.

### 4-1. ⚠️⚠️ 표·그림이 있는 페이지는 **청크가 더 넓은 맥락으로 교체된다**

- **적용 범위**: **최대 토큰 한도를 두는 모든 전략**(fixed-size · default · semantic · hierarchical).
  **`no chunking`에는 적용되지 않는다.**
- **조건**: 전체 페이지 텍스트 또는 전체 표가 **10,000자 이하**일 때만. 그보다 크면 맥락을 붙이지
  않고 일치한 청크를 그대로 돌려준다.
- **결과**: 같은 맥락을 공유하는 청크들이 **하나의 결과로 합쳐져** 반환 수가 `numberOfResults`보다
  **적을 수 있다.**
- 표 내용을 **청크 단위로** 받으려면 **`no chunking`을 고르고 사용자 지정 변환 Lambda로 직접 청킹**한다.

### 4-2. ⚠️ 반환 수가 요청보다 적어지는 경로가 **둘**이다

| 경로 | 기제 |
|---|---|
| 표·그림 맥락 교체 | 같은 맥락을 공유하는 청크가 **한 결과로** 합쳐진다(§4-1) |
| 계층형 청킹 | `numberOfResults`는 **자식 청크 수**에 매핑되고, 같은 부모를 공유하는 자식들이 **부모 청크로 대체**된다 |

⭐ 이 레포가 AIF 트랙에서 「반환 결과 수가 요청보다 적다는 것은 계층형 전용이 아니다」로
판정한 자리가 **여기서 다시 확인됐다.** 그리고 `numberOfResults`는 **최대치**다.

### 4-3. 텍스트 전략은 텍스트 문서에만 적용된다

**멀티모달 콘텐츠(오디오·비디오·이미지)는 이 텍스트 전략들을 타지 않고 임베딩 모델 수준에서
청킹된다.** 「멀티모달에 의미 기반 청킹을 적용한다」는 보기는 공식과 어긋난다.

## 5. 임베딩 — 수치와 **책임 분담**

`titan-embedding-models.html` · `model-parameters-titan-embed-text.html` 실측:

| 항목 | Titan Text Embeddings V2 |
|---|---|
| 모델 ID | `amazon.titan-embed-text-v2:0` |
| 최대 입력 | **8,192 토큰** / **50,000자**(영어 평균 **4.7자/토큰**) |
| 출력 차원 | **1,024(기본) · 512 · 256** |
| 추론 유형 | 온디맨드 · 프로비저닝된 처리량 |
| 용례 | RAG · 문서 검색 · **리랭킹** · 분류 |

- ⚠️⚠️ **임베딩 모델은 TPM이 아니라 RPM으로 스로틀된다** — 용량 계획이나 쿼터 증액 요청에
  **RPM 쿼터**를 쓴다(`기술 4.2.5`의 용량 계획과 직결된다).
- ⚠️ **유사도 계산과 검색은 임베딩 모델이 아니라 벡터 데이터베이스가 한다**(공식 문장).
  「임베딩 모델이 검색을 수행한다」는 보기는 거짓이다.
- ⚠️ **V1·V2는 `maxTokenCount`·`topP` 같은 추론 파라미터를 지원하지 않는다.**
- V2는 긴 문서를 받지만 **검색 작업에는 문단·절 같은 논리 단위로 쪼개는 것을 권장**한다.
- Bedrock의 임베딩 선택지는 Titan 말고도 **Cohere Embed(v3 · v4 · English · Multilingual)** ·
  **Amazon Nova Multimodal Embeddings** · **TwelveLabs Marengo Embed(2.7 · 3.0)**가 있다
  (TOC 전수). **개수는 묻지 않는다** — 모델 목록은 자주 바뀐다.

## 6. 검색 품질 — 리랭킹 · 메타데이터 필터

### 6-1. 리랭커 모델

`rerank.html` · `rerank-use.html`: 리랭커는 **쿼리와 청크의 관련성을 계산해 결과를 재정렬**한다.

- **쓰는 두 경로**: `Rerank` API **직접 호출**, 또는 KB의 `Retrieve`/`RetrieveAndGenerate` 호출
  (콘솔 질의 포함)에서 지정.
- ⚠️ **리랭킹 결과가 Knowledge Bases의 기본 순위를 override한다.**
- ⚠️ **텍스트 데이터에만** 쓸 수 있다.
- 값: **더 적지만 더 관련 있는 결과**를 FM에 넣어 **비용과 지연을 함께 줄인다**
  (`기술 4.2.2`·`4.2.6`의 축이 여기다).
- 모델: Bedrock 모델 카드에 **Cohere Rerank 3.5**가 있다.

### 6-2. 메타데이터 필터링 — 세 가지가 서로 다르다

| 종류 | 공식 사실 |
|---|---|
| 수동 필터 | 문서 필드·속성에 필터를 적용한다. 데이터 소스가 **어떤 필드를 임베딩에 포함할지도 지정**한다 |
| **관리형 KB 제약** | ⚠️ **`startsWith`·`stringContains` 미지원** → `equals` · `greaterThan` · `lessThan` · `in` · `notIn` 을 쓴다 |
| **암시적 필터** | Bedrock이 **사용자 쿼리와 메타데이터 스키마로 검색 필터를 생성·적용**한다. ⚠️ **Anthropic Claude 모델에서 지원** |

### 6-3. ⚠️⚠️ Aurora pgvector의 **조용한 결과 누락**

공식 권장: **메타데이터 필터링을 쓰면 HNSW 반복 인덱스 스캔을 활성화**하라
(**pgvector 0.8.0 이상** 필요). 이유가 시험 소재다 — **반복 스캔이 없으면 선택적 메타데이터
필터가 기대보다 적은 결과를 돌려준다. 필터가 HNSW 인덱스 스캔 "뒤에" 적용되기 때문**이다.
반복 스캔은 충분한 필터 결과를 찾을 때까지 인덱스를 더 스캔한다.

## 7. OpenSearch 쪽 사실 (기술 1.4.1 · 1.4.3 · 1.5.3 · 1.5.4)

- **벡터 필드**: `knn_vector` 타입, 차원 **최대 16,000**.
- **검색 방법**: k-NN과 **근사 k-NN**(HNSW 같은 알고리즘 — 대규모 데이터셋에서 더 빠르다).
- **거리 지표**: 유클리드 · 코사인 유사도 · 내적.
- **시맨틱 검색 경로가 둘**이다 — **2.9부터** `neural search` 또는 `k-NN`,
  그리고 **2.19부터 automatic semantic enrichment**가 **sparse encoding을 자동 생성**해
  **수동 ingestion 파이프라인 설정을 없앤다**.
- **Serverless는 Neural Search와 Hybrid Search를 따로 구성**한다
  (`serverless-configure-neural-search.html`).
- ⚠️ **샤딩 가이드라인은 워크로드에 따라 갈린다**(`bp-sharding.html`) —
  **검색 지연이 핵심 목표면 샤드당 10–30 GiB**, **로그 분석 같은 쓰기 중심이면 30–50 GiB**.
  그리고 **기존 인덱스의 기본 샤드 수는 쉽게 바꿀 수 없어** **첫 문서를 색인하기 전에** 정해야 한다
  (`기술 1.4.3`의 「샤딩 전략」이 이 제약을 말한다).
- **임베딩 생성 연동**: Amazon Bedrock · SageMaker AI · Hugging Face · 사용자 모델.

## 8. RAG 평가 (기술 5.1.5 · 5.1.6)

`evaluation-kb.html` · `knowledge-base-evaluation-metrics.html` 실측 — **작업 유형이 둘**이고
**지표 집합이 다르다.**

| 유형 | 내장 지표 |
|---|---|
| **Retrieve only** | **둘** — `Builtin.ContextRelevance` · `Builtin.ContextCoverage`(⚠️ **커버리지는 프롬프트 데이터셋에 ground truth가 있어야 한다**) |
| **Retrieve and generate** | **열** — Correctness · Completeness · Helpfulness · LogicalCoherence · **Faithfulness**(검색된 텍스트 대비 할루시네이션 회피) · **CitationPrecision** · **CitationCoverage** · Harmfulness · Stereotyping · Refusal |

- **외부 RAG 소스**의 추론 응답 데이터를 가져와 평가할 수도 있다(Bedrock KB가 아니어도 된다) —
  그래서 **서로 다른 KB·RAG 시스템을 비교해 고르는 것**이 이 기능의 목적이다.
- 사용자 지정 지표도 정의할 수 있다.
- ⚠️ **평가자 모델 목록은 자주 바뀐다**(Nova Pro/2 Lite/Micro/Premier · Claude 여러 세대 ·
  OpenAI GPT-5.4/5.5 …) — **모델 이름·개수를 묻지 않는다.**

## 9. ⚠️⚠️ 가이드가 드는 예시와 공식 제품 사실이 어긋나는 자리

`기술 1.4.1`은 예시로 **「메타데이터 및 임베딩을 위한 벡터 데이터베이스를 갖춘 Amazon DynamoDB」**와
**「Amazon S3 문서 리포지토리를 사용하는 Amazon RDS」**를 든다. 측정 결과:

- **Bedrock KB 지원 벡터 스토어 8종에 DynamoDB는 없다**(탭 전수 — `DynamoDB` **0건**).
- DynamoDB 개발자 안내서 소개 페이지에 **`vector` 0건 · `embedding` 0건**이다
  (대조군: 같은 페이지에서 `table` 48건 · `index` 5건 — 탐지기는 작동한다).

판정과 저작 규율:

1. **「Bedrock Knowledge Bases의 벡터 스토어로 DynamoDB를 고른다」류를 정답으로 쓰지 않는다.**
2. 다만 **「DynamoDB에 벡터 검색 기능이 없다」고 단정하지도 않는다** — 한 소개 페이지의 부재는
   제품 전체의 부재가 아니다(이 레포의 「목록에 없다 ≠ 없다」 규율). 가이드 문구는 **직접 구축하는
   아키텍처에서 메타데이터·임베딩을 DynamoDB에 담는다**는 읽기가 가능하고, 그 읽기를 공식으로
   확정할 근거는 찾지 못했다 → **99 G-23**으로 남긴다.
3. **「Amazon S3 문서 리포지토리를 사용하는 Amazon RDS」**는 공식 구성과 어긋나지 않는다 —
   Aurora PostgreSQL 쪽 공식 페이지 제목이 **`Using Aurora PostgreSQL as a Knowledge Base for
   Amazon Bedrock`**이고, KB가 **S3의 비정형 텍스트를 청크·벡터로 바꿔 PostgreSQL에 저장**한다.
   즉 **S3는 데이터 소스, Aurora는 벡터 스토어**다. 그 역할 분담을 섞는 보기는 거짓이다.
4. **벡터 스토어 개수(8종)를 묻지 않는다** — 목록이 바뀐다(S3 Vectors·GraphRAG가 뒤에 들어왔다).

## 10. 묻지 않을 것 (이 축의 D-규율 적용)

- **개수** — 벡터 스토어 8종 · 임베딩 모델 수 · 평가자 모델 수 · RAG 지표 수(⚠️ 단 **retrieve-only가
  둘이고 retrieve-and-generate가 열**이라는 **대비**는 성질이므로 쓸 수 있다).
- **`multi-hop`이라는 낱말을 어느 페이지가 쓰는지**(§2-2의 어휘 불일치).
- **S3 Vectors를 「가장 빠른」·「가장 느린」으로 서열화**하는 것(조건부 지연이다).
- **Kendra를 새 설계의 검색 소재로** 고르게 하는 것(96 §5-1 — 공식 대안이 Bedrock KB다).
- Pinecone·Redis Enterprise Cloud·MongoDB Atlas의 **제품 내부 사실**(3자 제품이고 공식 문서가
  「해당 3자 약관을 따를 책임은 고객에게 있다」까지만 적는다).

## 11. 출처 (전부 `curl -sL` 실측 · 2026-11-13 · 표시 없는 것은 `200 r=0`)

| 제목 | URL |
|---|---|
| Knowledge Bases 개요(유형 둘 · 관리형 권장 · MCP/AgentCore Gateway) | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html |
| 지식 베이스 동작 방식(float32 ↔ binary 벡터) | https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html |
| 콘텐츠 청킹(표·그림 맥락 · 전략 네 종) | https://docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html |
| 데이터 소스 메타데이터 | https://docs.aws.amazon.com/bedrock/latest/userguide/kb-metadata.html |
| 벡터 스토어 설정(**8종 탭** · binary 지원 둘 · Aurora 필터 필드 · S3 Vectors) | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html |
| 질의 구성(검색 유형 셋 · 하이브리드 지원 스토어 · 암시적 필터 · `numberOfResults`) | https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html |
| 에이전틱 검색(하위 쿼리 분해 · 반복 · 충분성 평가) | https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-agentic-retrieve.html |
| 리랭커 모델(기본 순위 override · 텍스트 전용) | https://docs.aws.amazon.com/bedrock/latest/userguide/rerank.html |
| 리랭커 사용 | https://docs.aws.amazon.com/bedrock/latest/userguide/rerank-use.html |
| Titan Text Embeddings(1,024/512/256 · **RPM 스로틀**) | https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html |
| RAG 평가 작업(유형 둘 · 외부 소스) | https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-kb.html |
| RAG 평가 지표(2 ↔ 10) | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html |
| Kendra GenAI 인덱스 KB | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-kendra-genai-index.html |
| Neptune Analytics GraphRAG | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-graphs.html |
| 구조화 데이터 스토어 KB | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-structured.html |
| S3 Vectors(벡터 버킷 · 조건부 지연) | https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors.html |
| Aurora PostgreSQL을 Bedrock KB로 | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html |
| OpenSearch 벡터 검색(`knn_vector` 16,000 차원) | https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vector-search.html |
| OpenSearch k-NN | https://docs.aws.amazon.com/opensearch-service/latest/developerguide/knn.html |
| OpenSearch 시맨틱 검색(2.9 · 2.19) | https://docs.aws.amazon.com/opensearch-service/latest/developerguide/semantic-search.html |
| OpenSearch Serverless Neural·Hybrid 구성 | https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-configure-neural-search.html |
| OpenSearch 샤드 수 선택(10–30 / 30–50 GiB) | https://docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html |
| DynamoDB 개발자 안내서 소개(벡터 서술 **0건** · 대조군 통과) | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html |

## 12. 측정 방법과 함정

- 슬러그는 **추정하지 않고 가이드 TOC(`toc-contents.json`)에서 뽑았다**
  (Bedrock 1,147개 · OpenSearch 389개 항목).
  ⚠️ 그 JSON은 **`"href" : "..."`처럼 콜론 앞에 공백**이 있다 — `"href":\s*"`로 세면 **0건**이 나오고
  「TOC에 아무것도 없다」로 읽힌다(실측). 대조군(항목 수 하한)을 함께 단정했다.
- 「없다」는 **대조군을 통과한 뒤에만** 적었다(§9의 DynamoDB — 같은 페이지에서 `table` 48건).
- 큰 페이지(42KB · 40KB)는 **탭 헤딩을 기계로 열거**해 목록을 세고, 산문은 정규식 창으로 읽었다.
