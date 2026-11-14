---
examGuideTaskId: aip-t1-4
certCode: AIP-C01
domain: 1
domainName: 파운데이션 모델 통합, 데이터 관리 및 규정 준수
domainWeightPct: 31
title: 벡터 저장소 솔루션 설계와 구현 (아키텍처·메타데이터·대규모 성능·통합·데이터 유지 관리)
coversTasks:
  - "1.4"
sources:
  - title: Amazon Bedrock Knowledge Bases 개요
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html
  - title: 지식 베이스용 벡터 스토어 설정
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html
  - title: 데이터 소스 메타데이터
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-metadata.html
  - title: Neptune Analytics 그래프로 지식 베이스 만들기 (GraphRAG)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-graphs.html
  - title: Kendra GenAI 인덱스로 지식 베이스 만들기
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-kendra-genai-index.html
  - title: 지식 베이스와 데이터 동기화
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html
  - title: 지식 베이스에 변경을 직접 수집
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-direct-ingestion.html
  - title: Confluence 데이터 소스 커넥터 (증분 동기화)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/confluence-data-source-connector.html
  - title: OpenSearch Service 벡터 검색
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/vector-search.html
  - title: OpenSearch Service 샤드 수 선택
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html
  - title: Amazon S3 Vectors
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors.html
  - title: Aurora PostgreSQL을 Bedrock 지식 베이스로
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
  - title: Amazon DynamoDB 개발자 안내서 소개
    url: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
lastVerified: 2026-11-14
---

# 벡터 저장소 솔루션 설계와 구현 (아키텍처·메타데이터·대규모 성능·통합·데이터 유지 관리)

> **커버하는 공식 Task** — AIP-C01 · 도메인 1 「파운데이션 모델 통합, 데이터 관리 및 규정 준수」(31%) · **작업 1.4 벡터 저장소 솔루션 설계 및 구현** (`aip-t1-4`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(1.4.1~1.4.5)를 모두 덮습니다. 이 작업은 **「무엇에 담는가」**를 묻고, 다음 작업(1.5)이 **「어떻게 꺼내는가」**를 묻습니다. 둘을 섞어 외우면 보기에서 갈리지 않습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 지식 베이스 **두 유형**과 공식이 권하는 쪽을 말할 수 있다
- [ ] 지원 **벡터 스토어**를 성질로 가를 수 있다(관리형 ↔ 직접 구축 ↔ 3자)
- [ ] GraphRAG·Kendra GenAI 인덱스가 **벡터 스토어 선택이 아닌** 이유를 안다
- [ ] 메타데이터로 검색 정밀도를 올리는 **세 수단**을 안다
- [ ] OpenSearch **샤딩·차원 한도**를 대규모 설계 근거로 쓸 수 있다
- [ ] 동기화가 **증분**이고 네 시나리오에서 무엇이 일어나는지 말할 수 있다
- [ ] `StartIngestionJob` ↔ `IngestKnowledgeBaseDocuments`를 가를 수 있다
- [ ] ⚠️ 동기화한 데이터의 **권한 경계**가 어디로 바뀌는지 안다

---

## 🎯 왜 중요한가

RAG에서 **틀리는 답의 절반은 검색에서 나옵니다.** 그리고 검색이 틀리는 이유는 대개 질의가 아니라 **담을 때의 결정** — 어느 스토어에 담았는가, 메타데이터를 무엇으로 붙였는가, 바뀐 문서를 다시 넣었는가 — 입니다.

이 작업은 그래서 **운영까지** 묻습니다. 기술 1.4.5가 「정확한 최신 정보가 포함되도록」이라고 적는 것은 **한 번 넣고 끝나는 설계는 틀렸다**는 뜻입니다. 시험은 「벡터 DB가 무엇인가」를 묻지 않고 **「이 요구 사항이면 어느 스토어이고, 바뀐 데이터는 어떻게 따라가는가」**를 묻습니다.

---

## ⚡ 시험 직전 요약

- 지식 베이스는 **두 유형**(관리형 ↔ 고객 관리형)이고 공식이 **Important로 관리형을 권한다**(최적화된 검색 정확도와 관리형 경험).
- 지원 벡터 스토어는 **OpenSearch Serverless · OpenSearch 관리형 클러스터 · S3 Vectors · Aurora(RDS) · Neptune Analytics 그래프 · Pinecone · Redis Enterprise Cloud · MongoDB Atlas**다.
- ⚠️ **Neptune Analytics(GraphRAG)와 Kendra GenAI 인덱스는 「벡터 스토어 고르기」가 아니라 다른 종류의 지식 베이스**다.
- ⚠️⚠️ 관리형 KB의 **검색 시점 ACL 문서 수준 필터링은 Web Crawler 데이터 소스에 적용되지 않는다**.
- 메타데이터 수단 셋 — **S3 객체 메타데이터**(타임스탬프 등) · **사용자 지정 속성**(소유권) · **태깅**(도메인 분류).
- OpenSearch `knn_vector`의 차원 상한은 **16,000**이고, 샤드 설계 지침은 **샤드당 10–30 GiB**(검색) / **30–50 GiB**(로그)다.
- ⚠️⚠️ **동기화는 증분이다** — 마지막 동기화 이후 **추가·수정·삭제된 문서만** 처리하고, 재수집은 **파싱 → 청킹 → 임베딩 → 색인**을 다시 돈다.
- ⚠️ **첫 동기화는 전체를 크롤**한다. 커넥터는 그 뒤 데이터 소스의 변경 추적 메커니즘을 쓴다.
- ⚠️⚠️ **S3 데이터 소스에 직접 수집(`IngestKnowledgeBaseDocuments`)한 변경은 S3 위치에 반영되지 않는다** — 즉시 반영되지만 뒤이어 S3를 맞춰야 한다.
- ⚠️⚠️ **동기화한 데이터는 `bedrock:Retrieve` 권한이 있는 누구나 검색할 수 있다** — 소스 쪽에서 권한이 제어되던 데이터까지 포함될 수 있다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **지식 베이스** | 데이터 소스를 수집·색인해 FM이 검색할 수 있게 만든 Bedrock 리소스 |
| **벡터 스토어** | 임베딩을 담고 유사도로 찾아 주는 저장소 |
| **수집(ingestion)** | 파싱 → 청킹 → 임베딩 생성 → 벡터 스토어 색인의 한 묶음 |
| **동기화(sync)** | 데이터 소스의 변경을 지식 베이스에 반영하는 작업(`StartIngestionJob`) |
| **GraphRAG** | 문서 사이 관계를 그래프로 담아 검색에 쓰는 방식(Neptune Analytics) |
| **`knn_vector`** | OpenSearch에서 벡터를 담는 필드 유형 |

---

## 📖 핵심 개념

### 1) 벡터 데이터베이스 아키텍처를 고른다 (기술 1.4.1) {#architecture}

> 🧠 원리: 「어느 벡터 DB가 좋은가」는 답이 없고, **「누가 무엇을 관리하는가」**로 갈립니다. Bedrock 지식 베이스는 그 선을 **두 유형**으로 먼저 긋습니다.

| | **관리형 지식 베이스** | **고객 관리형 지식 베이스** |
|---|---|---|
| 인프라 | Bedrock이 **수집·색인·스토리지·검색**을 관리한다 | 내가 벡터 스토어를 세운다 |
| 모델 | 임베딩·리랭킹·추론을 **서비스 관리형 모델**로(내 모델도 가능) | 내가 고른다 |
| 데이터 | **멀티모달** 수집 · 스토리지 **자동 확장** | — |
| 검색 | **Agentic Retrieval**(다단계) | 단일 검색 패스 |
| 파싱 | **Smart Parsing**(문서 유형별 전략 자동 선택) | 파싱 옵션을 내가 고른다 |

⭐ 공식이 **Important로 관리형을 권합니다** — 「최적화된 검색 정확도와 관리형 경험」이 이유입니다.

고객 관리형을 고르면 **벡터 스토어를 직접 고릅니다.** 공식 설정 문서가 드는 것은 여덟입니다:

**Amazon OpenSearch Serverless** · **OpenSearch Service 관리형 클러스터** · **Amazon S3 Vectors** ·
**Amazon Aurora(RDS)** · **Neptune Analytics 그래프(GraphRAG)** · **Pinecone** ·
**Redis Enterprise Cloud** · **MongoDB Atlas**

⚠️⚠️ **두 가지는 「벡터 스토어 고르기」가 아닙니다** — **Neptune Analytics(GraphRAG)**와 **Kendra GenAI 인덱스**는 **다른 종류의 지식 베이스를 만드는 경로**입니다. 보기에서 「벡터 스토어로 GraphRAG를 고른다」처럼 섞어 놓으면 그것이 함정입니다.

⚠️ 공식 기술 본문이 드는 예시 중 **「메타데이터 및 임베딩을 위한 벡터 데이터베이스를 갖춘 Amazon DynamoDB」는 이 사이트가 문항 축으로 쓰지 않습니다.** Bedrock 지식 베이스의 지원 벡터 스토어 여덟에 DynamoDB가 없고, DynamoDB 개발자 안내서 소개 페이지에서 벡터·임베딩 서술을 찾지 못했습니다. ⛔ 그렇다고 **「DynamoDB에 벡터 검색이 없다」고 단정하지도 않습니다** — 한 페이지의 부재는 제품의 부재가 아닙니다. 직접 구축하는 아키텍처에서 **메타데이터를 DynamoDB에 담는** 읽기는 가능하지만, 그 읽기를 공식으로 확정할 근거를 찾지 못했습니다.

### 2) 메타데이터로 정밀도를 올린다 (기술 1.4.2) {#metadata}

> 🧠 원리: 벡터 유사도만으로는 **「최신 것」·「내 팀 것」·「이 도메인 것」**을 가릴 수 없습니다. 그 구분은 **메타데이터**가 합니다.

공식 기술이 드는 세 수단과 각각이 맡는 일:

| 수단 | 맡는 일 |
|---|---|
| **S3 객체 메타데이터** | 문서 **타임스탬프** 같은 객체 수준 사실 |
| **사용자 지정 속성** | **소유권** 정보 |
| **태깅 시스템** | **도메인 분류** |

Bedrock 지식 베이스 쪽에서는 데이터 소스 메타데이터를 붙여 **검색 시점의 필터**로 씁니다(필터 종류와 동작은 작업 1.5에서 다룹니다). ⭐ **메타데이터를 붙이지 않으면 나중에 필터를 쓸 수 없고, 필터가 없으면 「최신 문서만」 같은 요구를 검색으로 표현할 수 없습니다.**

⚠️⚠️ **권한은 메타데이터로 해결되지 않습니다.** 관리형 KB는 **검색 시점 ACL 문서 수준 필터링**을 제공하지만 ⚠️ **Web Crawler 데이터 소스에는 적용되지 않습니다.** 그리고 §5의 경고(동기화한 데이터는 `bedrock:Retrieve` 권한자에게 열린다)가 함께 걸립니다.

### 3) 대규모에서 성능을 낸다 (기술 1.4.3) {#scale}

> 🧠 원리: 벡터 검색이 느려지는 원인은 대개 **알고리즘이 아니라 샤드와 인덱스 설계**입니다. 공식이 수치를 주는 자리가 거기입니다.

OpenSearch 쪽 사실:

- 벡터는 **`knn_vector`** 필드 유형에 담고 **차원 상한은 16,000**입니다.
- 샤드 수 설계 지침: **검색 중심 워크로드는 샤드당 10–30 GiB**, **로그 분석형은 30–50 GiB**를 권합니다.
- 공식 기술이 드는 **다중 인덱스 접근 방식**(특수 도메인별로 인덱스를 나눔)과 **계층적 인덱싱**은 이 샤드 설계와 함께 봅니다 — 인덱스를 나누면 **각 인덱스의 샤드 크기를 지침 범위에 유지**하기 쉬워집니다.

⚠️ **스토어마다 성능 성질이 다릅니다** — 예컨대 **S3 Vectors**는 공식 문서가 값과 **조건부 지연**을 함께 적습니다. ⛔ 그래서 이 사이트는 **스토어를 「가장 빠르다·가장 느리다」로 서열화하지 않습니다**(조건부입니다).

### 4) 리소스와 연결하는 통합 구성 요소 (기술 1.4.4) {#integration}

> 🧠 원리: 지식 베이스의 가치는 **내부 문서에 닿는 것**입니다. 그 연결은 커넥터가 합니다.

관리형 KB가 제공하는 커넥터(공식): **S3 · SharePoint · Confluence · Google Drive · OneDrive · Web Crawler**.
공식 기술 본문이 드는 「문서 관리 시스템 · 지식 기반 · 내부 위키」가 이 커넥터들에 대응합니다.

- ⚠️ **Web Crawler는 예외가 둘 있습니다** — 위에서 본 **ACL 문서 수준 필터링 미적용**이고, 자격 증명 기반으로 보호된 내부 콘텐츠에는 보통 맞지 않습니다.
- ⭐ **커넥터를 쓰지 않는 길도 있습니다** — **사용자 지정 데이터 소스**로 두면 §5의 `KnowledgeBaseDocuments` 작업으로 직접 넣고 지웁니다.

### 5) 데이터를 최신으로 유지한다 (기술 1.4.5) {#maintenance}

> 🧠 원리: 이 기술이 이 작업의 **가장 시험다운 자리**입니다. 「증분 업데이트 · 실시간 변경 감지 · 자동 동기화 · 예약 새로 고침」이라는 네 표현이 전부 **한 질문**을 가리킵니다 — **바뀐 문서를 어떻게 다시 넣는가**.

**동기화는 증분입니다**(공식):

- 데이터 소스에서 파일을 **추가·수정·제거할 때마다 동기화**해야 지식 베이스에서 다시 색인됩니다.
- Bedrock은 **마지막 동기화 이후 추가·수정·삭제된 문서만** 처리합니다.
- 재수집(re-ingestion)은 **파싱 · 청킹 · 임베딩 생성 · 벡터 스토어 색인**을 포함합니다.

| 시나리오 | 무엇이 일어나는가 |
|---|---|
| 변경이 감지되지 않음 | 그 문서는 **건너뜁니다** |
| 콘텐츠 또는 **메타데이터**가 바뀜 | **재수집**합니다(재파싱·재청킹·재임베딩·재색인) |
| 새 문서 추가 | **새 문서만** 수집합니다 |
| 문서 삭제 | **벡터 스토어에서 제거**합니다 |

⭐ **메타데이터만 바뀌어도 재수집된다**는 것이 비자명합니다 — 메타데이터를 대량으로 고치면 임베딩 비용이 다시 듭니다.

**커넥터의 증분 동기화**: 커넥터는 동기화마다 **새·수정·삭제된 콘텐츠를 크롤**하고, 데이터 소스가 제공하는 **변경 추적 메커니즘**을 쓸 수 있습니다. ⚠️ **첫 동기화에서는 기본적으로 전체 콘텐츠를 크롤**합니다. 동기화는 **`StartIngestionJob` API** 또는 콘솔의 **Sync**로 시작합니다.

⚠️⚠️ **API 집합이 둘이고 쓰는 자리가 다릅니다**:

| | **`StartIngestionJob`**(데이터 소스 동기화) | **`IngestKnowledgeBaseDocuments`**(직접 수집) |
|---|---|---|
| 하는 일 | 연결된 데이터 소스의 **각 문서를 스캔**해 색인됐는지 확인하고, 안 됐으면 색인한다 | **문서 배열을 벡터 스토어에 직접** 색인한다 — **데이터 소스에 추가하는 단계를 건너뛴다** |
| 사용자 지정 데이터 소스 | ⭐ **필요하지 않다** — `KnowledgeBaseDocuments` 작업이나 콘솔로 추가·수정·삭제하면 **데이터 소스와 지식 베이스 양쪽**에 반영된다 | 이것으로 다룬다 |
| S3 데이터 소스 | 첫 연결 뒤 **반드시 한 번 동기화**해야 한다 | ⚠️⚠️ **직접 색인한 변경은 S3 위치에 반영되지 않는다** — 즉시 반영되지만 **뒤이어 S3를 맞춰야** 한다 |

⚠️⚠️ **규정 준수 경고**(공식 Important): **데이터 소스에서 동기화한 모든 데이터는 `bedrock:Retrieve` 권한이 있는 누구나 검색할 수 있습니다.** 소스 쪽에서 **권한이 제어되던 데이터**까지 포함될 수 있습니다. 즉 **지식 베이스를 만드는 것은 권한 경계를 다시 그리는 일**입니다 — 도메인 1이 「데이터 관리 및 규정 준수」를 함께 묻는 이유가 여기 있습니다.

---

## ✍️ 시험 포인트

- 「관리 부담을 줄이고 검색 정확도를 우선」이면 **관리형 지식 베이스**입니다(공식 권장).
- 「문서 사이 관계를 따라가야 한다」면 **GraphRAG**이지만 그것은 **벡터 스토어 선택이 아닙니다**.
- 「최신 문서만 검색」이면 **메타데이터 + 필터**이고, 메타데이터를 안 붙였으면 **먼저 붙여야** 합니다.
- 「벡터 검색이 느리다 + 인덱스가 거대하다」면 **샤드 크기 지침**과 **다중 인덱스**를 봅니다.
- 「자료가 바뀌는데 답이 옛것이다」면 **동기화를 안 돌린 것**입니다.
- 「S3에 넣지 않고 바로 색인」이면 **`IngestKnowledgeBaseDocuments`**이고, **S3와 어긋남**을 함께 답해야 합니다.
- 「내부 위키를 붙였더니 비공개 문서가 검색된다」면 **`bedrock:Retrieve` 경고**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **GraphRAG·Kendra GenAI 인덱스를 「벡터 스토어 중 하나」로 읽기.**
- ⚠️ **ACL 문서 수준 필터링이 모든 데이터 소스에 적용된다고 생각하기.** **Web Crawler는 제외**입니다.
- ⚠️⚠️ **동기화가 전체 재색인이라고 생각하기.** **증분**입니다 — 다만 **메타데이터만 바뀌어도 재수집**됩니다.
- ⚠️ **첫 동기화도 증분이라고 생각하기.** 기본적으로 **전체 크롤**입니다.
- ⚠️⚠️ **직접 수집이 S3를 갱신한다고 생각하기.** 반영되지 않습니다.
- ⚠️ **지식 베이스를 만들면 소스의 권한이 따라온다고 생각하기.** `bedrock:Retrieve` 권한자에게 열립니다.
- ⚠️ **스토어를 속도로 서열화하기.** 공식이 적는 것은 **조건부** 성질입니다.
- ⚠️ **DynamoDB를 Bedrock 지식 베이스의 벡터 스토어로 고르기.** 지원 여덟에 없습니다.

---

## 🧪 자가 점검

**Q1.** 팀이 벡터 스토어 운영 경험이 없고 검색 정확도를 우선합니다. 공식은 무엇을 권합니까?

<details><summary>정답 보기</summary>

**관리형 지식 베이스(Amazon Bedrock Managed Knowledge Base)**입니다. 공식이 Important로 **「최적화된 검색 정확도와 관리형 경험」**을 이유로 권합니다. Bedrock이 수집·색인·스토리지·검색을 관리하고, 멀티모달 수집·스토리지 자동 확장·Smart Parsing·Agentic Retrieval이 따라옵니다.
</details>

**Q2.** 「벡터 스토어로 Neptune Analytics 그래프를 고르면 GraphRAG가 된다」는 서술의 문제는 무엇입니까?

<details><summary>정답 보기</summary>

**GraphRAG는 「벡터 스토어 고르기」가 아니라 다른 종류의 지식 베이스를 만드는 경로**입니다. Kendra GenAI 인덱스도 같습니다. 벡터 스토어 선택(OpenSearch Serverless·관리형 클러스터·S3 Vectors·Aurora·Pinecone·Redis Enterprise Cloud·MongoDB Atlas 등)과 **별 축**으로 두고 봐야 보기에서 갈립니다.
</details>

**Q3.** 문서 수천 개의 **메타데이터만** 일괄 수정했습니다. 다음 동기화에서 무엇이 일어납니까?

<details><summary>정답 보기</summary>

⚠️ **그 문서들이 재수집됩니다.** 공식 시나리오 표가 「콘텐츠 **또는 메타데이터**가 바뀜 → 재수집(재파싱·재청킹·**재임베딩**·재색인)」으로 적습니다. 즉 **임베딩 비용이 다시 듭니다** — 메타데이터 대량 수정은 비용 계획에 넣어야 합니다.
</details>

**Q4.** S3를 데이터 소스로 쓰는 지식 베이스에 긴급 문서 하나를 **즉시** 반영해야 합니다. 무엇을 쓰고 무엇을 뒤이어 해야 합니까?

<details><summary>정답 보기</summary>

**`IngestKnowledgeBaseDocuments`**로 직접 색인하면 데이터 소스에 넣는 단계를 건너뛰고 **즉시** 반영됩니다. ⚠️⚠️ 다만 **그 변경은 S3 위치에 반영되지 않으므로** 뒤이어 **S3 쪽을 맞춰야** 합니다. 그러지 않으면 다음 `StartIngestionJob`에서 상태가 어긋납니다.
</details>

**Q5.** 사내 위키를 커넥터로 붙였더니, 원래 일부 팀만 볼 수 있던 문서가 다른 직원 질의에 인용됩니다. 무엇이 원인입니까?

<details><summary>정답 보기</summary>

⚠️⚠️ **동기화한 데이터는 `bedrock:Retrieve` 권한이 있는 누구나 검색할 수 있습니다**(공식 Important) — **소스 쪽에서 권한이 제어되던 데이터까지 포함**됩니다. 관리형 KB의 **검색 시점 ACL 문서 수준 필터링**이 해법이지만 ⚠️ **Web Crawler 데이터 소스에는 적용되지 않습니다.**
</details>

**Q6.** OpenSearch 인덱스가 거대해져 벡터 검색이 느립니다. 공식 지침에서 먼저 볼 수치는 무엇입니까?

<details><summary>정답 보기</summary>

**샤드 크기**입니다 — 검색 중심 워크로드는 **샤드당 10–30 GiB**, 로그 분석형은 **30–50 GiB**가 공식 지침입니다. 거기에 **다중 인덱스**(도메인별 분리)와 계층적 인덱싱을 더해 각 인덱스의 샤드 크기를 범위에 유지합니다. 참고로 `knn_vector`의 **차원 상한은 16,000**입니다.
</details>

---

### 📌 출처

1. Amazon Bedrock Knowledge Bases 개요 (유형 둘 · 관리형 권장 · 커넥터 · ACL 필터링) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html` (2026-11-14 확인)
2. 지식 베이스용 벡터 스토어 설정 (지원 스토어 여덟) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html` (2026-11-14 확인)
3. 데이터 소스 메타데이터 — `docs.aws.amazon.com/bedrock/latest/userguide/kb-metadata.html` (2026-11-14 확인)
4. Neptune Analytics 그래프로 지식 베이스 만들기(GraphRAG) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-graphs.html` (2026-11-14 확인)
5. Kendra GenAI 인덱스로 지식 베이스 만들기 — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-build-kendra-genai-index.html` (2026-11-14 확인)
6. 지식 베이스와 데이터 동기화 (증분 · 시나리오 네 가지 · 재수집 범위) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html` (2026-11-14 확인)
7. 지식 베이스에 변경을 직접 수집 (두 API 집합의 차이 · S3 미반영 경고) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-direct-ingestion.html` (2026-11-14 확인)
8. Confluence 데이터 소스 커넥터 (증분 동기화 · 첫 동기화 전체 크롤 · `bedrock:Retrieve` 경고) — `docs.aws.amazon.com/bedrock/latest/userguide/confluence-data-source-connector.html` (2026-11-14 확인)
9. OpenSearch Service 벡터 검색 (`knn_vector` 16,000 차원) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/vector-search.html` (2026-11-14 확인)
10. OpenSearch Service 샤드 수 선택 (10–30 / 30–50 GiB) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html` (2026-11-14 확인)
11. Amazon S3 Vectors (값과 조건부 지연) — `docs.aws.amazon.com/AmazonS3/latest/userguide/s3-vectors.html` (2026-11-14 확인)
12. Aurora PostgreSQL을 Bedrock 지식 베이스로 — `docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html` (2026-11-14 확인)
13. Amazon DynamoDB 개발자 안내서 소개 (벡터·임베딩 서술 부재 — 문항 축으로 쓰지 않는 근거) — `docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html` (2026-11-14 확인)
