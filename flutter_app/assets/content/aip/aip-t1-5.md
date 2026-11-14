---
examGuideTaskId: aip-t1-5
certCode: AIP-C01
domain: 1
domainName: 파운데이션 모델 통합, 데이터 관리 및 규정 준수
domainWeightPct: 31
title: FM 증강을 위한 검색 메커니즘 설계 (청킹·임베딩·벡터 검색·하이브리드와 리랭킹·쿼리 처리·액세스)
coversTasks:
  - "1.5"
sources:
  - title: 콘텐츠 청킹 (표·그림 맥락 교체)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html
  - title: Titan Text Embeddings 모델
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html
  - title: 지식 베이스 동작 방식 (float32 ↔ binary 벡터)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html
  - title: 지식 베이스용 벡터 스토어 설정
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html
  - title: 질의 구성 (검색 유형·필터·결과 수)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html
  - title: 리랭커 모델
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/rerank.html
  - title: 리랭커 사용
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/rerank-use.html
  - title: 에이전틱 검색 (하위 쿼리 분해·반복·충분성 평가)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-agentic-retrieve.html
  - title: Amazon Bedrock Knowledge Bases 개요 (AgentCore Gateway·MCP 통합)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html
  - title: OpenSearch Service 시맨틱 검색
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/semantic-search.html
  - title: OpenSearch Serverless Neural·하이브리드 검색 구성
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-configure-neural-search.html
  - title: Aurora PostgreSQL을 Bedrock 지식 베이스로 (pgvector)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
lastVerified: 2026-11-14
---

# FM 증강을 위한 검색 메커니즘 설계 (청킹·임베딩·벡터 검색·하이브리드와 리랭킹·쿼리 처리·액세스)

> **커버하는 공식 Task** — AIP-C01 · 도메인 1 「파운데이션 모델 통합, 데이터 관리 및 규정 준수」(31%) · **작업 1.5 FM 증강을 위한 검색 메커니즘 설계** (`aip-t1-5`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 6개(1.5.1~1.5.6)를 모두 덮습니다. 작업 1.4가 **「무엇에 담는가」**였고 이 작업은 **「어떻게 꺼내는가」**입니다. 담는 쪽 결정은 `aip-t1-4` 문서를 보세요.

---

## ✅ 학습 목표 체크리스트

- [ ] 청킹에서 **경계 조건**(표·그림 맥락 교체)이 왜 중요한지 안다
- [ ] **반환 수가 요청보다 적어지는** 경로를 설명할 수 있다
- [ ] 임베딩 차원 선택의 **절충**과 스로틀 단위를 안다
- [ ] float32 ↔ **binary** 벡터의 갈림길을 안다
- [ ] 검색 유형 셋을 가르고 **하이브리드가 되는 조건**을 안다
- [ ] 리랭커가 **무엇을 덮어쓰는지**와 **적용 한계**를 안다
- [ ] 쿼리 확장·분해·변환을 공식 수단에 매핑할 수 있다
- [ ] ⭐ **MCP 클라이언트로 KB를 도구로 쓰는** 공식 경로를 안다

---

## 🎯 왜 중요한가

검색 설계는 **조각마다 「조용히 실패하는」 모양**이 있습니다. 청크가 잘려 답에 필요한 표가 빠지고, 요청한 개수보다 적게 돌아오는데 아무 오류도 없고, 필터가 걸려 후보가 사라져도 그냥 「관련 문서가 없다」로 보입니다.

그래서 이 작업은 **값이 아니라 경계**를 묻습니다. 「임베딩 차원이 몇인가」보다 **「차원을 낮추면 무엇을 잃는가」**, 「하이브리드 검색이 좋은가」보다 **「하이브리드가 가능한 스토어인가」**가 시험의 질문입니다.

---

## ⚡ 시험 직전 요약

- ⚠️⚠️ **표나 그림이 있는 페이지는 청크가 「더 넓은 맥락」으로 교체된다** — 최대 토큰 한도를 두는 전략에서 일어나고, 그래서 **청크 경계가 내가 정한 크기와 달라질 수 있다**.
- ⚠️⚠️ **반환 결과 수가 요청보다 적어지는 경로가 둘**이다 — **계층형 청킹**과 **표·그림 맥락 교체**다. 오류 없이 적게 온다.
- ⚠️ **텍스트 기반 청킹 전략은 텍스트 문서에만** 적용된다.
- **Titan Text Embeddings**는 차원 **1,024 / 512 / 256**을 고를 수 있고 ⚠️ 스로틀은 **RPM(분당 요청)** 단위다.
- 벡터는 **float32** 또는 **binary**로 담을 수 있고 ⚠️ **binary를 지원하는 스토어가 제한된다**.
- 검색 유형은 **시맨틱 · 하이브리드** 축으로 갈리고 ⚠️⚠️ **하이브리드는 지원하는 벡터 스토어에서만** 된다.
- 리랭커는 **기본 순위를 덮어쓴다**. ⚠️ **텍스트 전용**이다.
- ⚠️⚠️ **Aurora pgvector는 필터 조건에 따라 결과가 조용히 누락**될 수 있다 — 필터 필드 설정이 필요하다.
- **에이전틱 검색**이 공식 쿼리 분해 수단이다 — ① **하위 쿼리로 분해** ② **반복 검색** ③ **충분성 평가**.
- ⭐ **관리형 KB는 AgentCore Gateway와 네이티브 통합**돼 **MCP 호환 에이전트 프레임워크가 사용자 지정 코드 없이 KB를 도구로 발견·호출**한다 — `기술 1.5.6`의 정답 경로다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **청킹** | 문서를 검색 단위로 쪼개는 일. 전략에 따라 경계가 달라진다 |
| **계층형 청킹** | 부모·자식 청크를 두어 **찾는 단위와 주는 단위를 다르게** 하는 전략 |
| **임베딩 차원** | 벡터의 길이. 크면 표현력이 좋고 저장·연산이 늘어난다 |
| **binary 벡터** | float32보다 작게 담는 표현. **지원 스토어가 제한된다** |
| **하이브리드 검색** | 키워드(어휘) 검색과 벡터 검색을 **함께** 쓰는 방식 |
| **리랭커** | 1차 검색 결과의 **순서를 다시 매기는** 모델 |

---

## 📖 핵심 개념

### 1) 문서 분할(청킹)을 고른다 (기술 1.5.1) {#chunking}

> 🧠 원리: 청킹에서 외울 것은 전략 이름이 아니라 **「내가 정한 경계가 지켜지지 않는 조건」**입니다. 그 조건을 모르면 검색 결과를 보고도 원인을 못 찾습니다.

공식 청킹 문서가 적는 비자명한 사실 셋:

1. ⚠️⚠️ **표나 그림이 있는 페이지는 청크가 「더 넓은 맥락」으로 교체됩니다.** 최대 토큰 한도를 두는 전략에서 일어나고, 그래서 **결과 청크가 내가 설정한 크기와 다를 수 있습니다.** 표가 끊겨 의미를 잃는 것을 막으려는 동작입니다.
2. ⚠️⚠️ **반환 결과 수가 요청한 수보다 적어질 수 있습니다.** 경로가 둘입니다 — **계층형 청킹**(부모 청크로 합쳐지면서 줄어듭니다)과 위의 **표·그림 맥락 교체**입니다. **오류 없이 적게 옵니다.**
3. ⚠️ **텍스트 기반 전략은 텍스트 문서에만** 적용됩니다 — 다른 모달리티에 같은 설정을 기대하면 안 됩니다.

⛔ 이 사이트는 **전략의 개수를 묻지 않습니다**(공식 목록은 개정됩니다). 묻는 것은 **위 세 경계**와 「계층형을 쓰면 무엇이 달라지는가」입니다.

### 2) 임베딩을 고르고 구성한다 (기술 1.5.2) {#embedding}

> 🧠 원리: 임베딩 선택은 **차원 ↔ 비용·속도**의 절충입니다. 그리고 그 선택은 **스토어가 받아 주는 표현**에 묶여 있습니다.

- **Amazon Titan Text Embeddings**는 차원을 **1,024 · 512 · 256** 중에서 고를 수 있습니다. 차원을 낮추면 저장과 연산이 줄고 표현력이 떨어집니다 — **도메인 적합성과 함께** 고릅니다.
- ⚠️ **스로틀 단위가 RPM(분당 요청)**입니다. 그래서 **Lambda로 임베딩을 일괄 생성**할 때는 요청 수를 기준으로 속도를 설계해야 합니다(토큰 기준이 아닙니다).
- 벡터 표현은 **float32**와 **binary** 둘이고 ⚠️⚠️ **binary를 지원하는 벡터 스토어가 제한됩니다.** 「binary로 저장 비용을 줄인다」는 선택은 **스토어가 먼저 결정합니다.**

⭐ **책임 분담을 봅니다** — 관리형 지식 베이스는 임베딩 모델을 **서비스가 관리**하고(내 모델 선택도 가능), 고객 관리형은 **내가 고르고 내가 호출**합니다(작업 1.4 §1).

### 3) 벡터 검색을 배포한다 (기술 1.5.3) {#deploy}

> 🧠 원리: 공식 기술이 드는 셋 — **OpenSearch Service · Aurora(pgvector) · 관리형 KB** — 은 **관리 경계가 다른 세 지점**입니다.

| 경로 | 성질 |
|---|---|
| **관리형 Bedrock Knowledge Base** | 벡터 스토어를 **서비스가 관리**한다. 가장 적은 운영 부담 |
| **OpenSearch Service** | 벡터 검색 기능(`knn_vector`)을 쓰고 **샤드·인덱스를 내가 설계**한다. 시맨틱 검색 지원은 버전에 묶인다 |
| **Aurora PostgreSQL + pgvector** | 기존 관계형 데이터와 **같은 엔진 안에서** 벡터를 다룬다 |

- OpenSearch에서 **시맨틱 검색**과 **Neural/하이브리드 검색**은 구성이 필요하고, 지원이 **엔진 버전에 묶입니다**(공식 문서가 버전을 명시합니다). 「OpenSearch면 당연히 된다」가 아닙니다.
- ⚠️⚠️ **Aurora pgvector에는 조용한 결과 누락이 있습니다** — **필터에 쓰는 필드를 설정해 두지 않으면** 필터가 걸린 질의에서 결과가 **오류 없이 빠질 수 있습니다.** 벡터 스토어 설정 문서가 그 필드를 지정하라고 적습니다.

### 4) 관련성을 올리는 고급 검색 (기술 1.5.4) {#advanced}

> 🧠 원리: 벡터 검색만으로는 **정확한 낱말**(제품 코드·고유명사)을 놓치고, 키워드 검색만으로는 **뜻**을 놓칩니다. 그래서 둘을 합치고, 그 뒤에 순서를 다시 매깁니다.

- **하이브리드 검색** = 키워드(어휘) + 벡터. ⚠️⚠️ **지원하는 벡터 스토어에서만** 됩니다 — 질의 구성 문서가 어느 스토어가 하이브리드를 지원하는지 적습니다. 지원하지 않는 스토어를 골라 두고 하이브리드를 요구하면 **설계가 거기서 막힙니다.**
- **메타데이터 필터링은 서로 다른 세 가지**가 있습니다(명시적으로 주는 필터, 모델이 질의에서 **암시적으로** 끌어내는 필터 등) — 같은 「필터」라는 말로 묶지 말고 **누가 조건을 만드는지**로 가릅니다.
- **리랭커 모델**은 1차 검색의 **기본 순위를 덮어씁니다**(override). ⚠️ **텍스트 전용**이라 다른 모달리티 결과에는 쓸 수 없습니다.
- 결과 수는 질의 구성에서 지정하지만 **§1의 두 경로로 더 적게 올 수 있습니다.**

### 5) 쿼리 처리 시스템 (기술 1.5.5) {#query}

> 🧠 원리: 사용자 질문은 **검색에 맞는 모양이 아닙니다.** 「작년 매출이 왜 떨어졌고 올해 계획은 뭐야」는 **두 질문**이고, 한 번의 벡터 검색으로는 둘 다 못 찾습니다.

공식 기술이 드는 셋과 대응하는 수단:

| 기술 본문 | 공식 수단 |
|---|---|
| **쿼리 확장** | Bedrock(FM)으로 질의를 보강한다 |
| **쿼리 분해** | ⭐ **에이전틱 검색**이 이것을 서비스로 한다(아래) · 또는 Lambda로 직접 |
| **쿼리 변환** | Step Functions로 단계를 묶는다 |

⭐ **에이전틱 검색(Agentic Retrieval)**이 공식이 적는 분해·반복 수단입니다. FM이 ① **복잡한 쿼리를 하위 쿼리로 분해**하고 ② 여러 지식 베이스에서 **반복적으로 검색**하고 ③ 결과가 **원 질문에 답하기에 충분한지 평가**합니다. 관리형 지식 베이스의 기능입니다.

⚠️ **낱말에 끌려가지 않습니다** — 개요 문서는 이 동작을 `multi-hop reasoning`으로 부르는데, 에이전틱 검색 전용 문서에는 그 표현이 **없습니다.** 묻는 것은 **낱말이 아니라 세 동작**입니다.

### 6) 일관된 액세스 메커니즘 (기술 1.5.6) {#access}

> 🧠 원리: 검색을 **애플리케이션마다 다르게** 부르면 모델을 바꾸거나 프레임워크를 바꿀 때 전부 고쳐야 합니다. 그래서 공식은 **표준 인터페이스**를 답으로 둡니다.

공식 기술이 드는 셋:

1. **벡터 검색을 위한 함수 호출 인터페이스** — FM의 도구 호출로 검색을 노출합니다.
2. ⭐⭐ **벡터 쿼리를 위한 MCP 클라이언트** — 이것이 공식 경로를 갖습니다. **관리형 지식 베이스는 AgentCore Gateway와 네이티브로 통합**되고, 공식 문구는 **「MCP 호환 에이전트 프레임워크가 사용자 지정 코드 없이 지식 베이스를 도구로 발견하고 호출할 수 있다」**입니다.
3. **검색 증대를 위한 표준화된 API 패턴** — 위 둘을 감싸는 자기 계약입니다.

⚠️ MCP 자체의 프로토콜 계약(버전 경계·상태성·세션)은 **도메인 2**의 영역입니다 — 여기서 묻는 것은 **「KB를 도구로 노출하는 공식 경로가 있다」**는 사실입니다.

---

## ✍️ 시험 포인트

- 「청크 크기를 정했는데 결과 청크가 다르다」면 **표·그림 맥락 교체**입니다.
- 「`numberOfResults`를 N으로 줬는데 N보다 적게 온다」면 **계층형 청킹** 또는 **맥락 교체**입니다(오류가 아닙니다).
- 「저장 비용을 줄이려 binary를 쓴다」면 **스토어가 지원하는지**가 선행 조건입니다.
- 「제품 코드 검색이 안 맞는다」면 **하이브리드**이고, **스토어 지원**을 확인합니다.
- 「순위가 마음에 안 든다」면 **리랭커**이고 **텍스트 전용**입니다.
- 「필터를 걸면 결과가 사라진다 + Aurora」면 **필터 필드 설정**입니다.
- 「한 질문에 두 가지를 묻는다」면 **에이전틱 검색**(분해·반복·충분성 평가)입니다.
- 「에이전트 프레임워크에서 KB를 도구로 쓰고 싶다」면 **AgentCore Gateway + MCP**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **청크 크기 설정이 언제나 지켜진다고 생각하기.**
- ⚠️⚠️ **결과가 적게 오는 것을 오류로 읽기.** 두 경로가 정상 동작입니다.
- ⚠️ **텍스트 전략을 비텍스트 문서에 기대하기.**
- ⚠️ **임베딩 스로틀을 토큰 단위로 계산하기.** **RPM**입니다.
- ⚠️⚠️ **하이브리드 검색이 모든 스토어에서 된다고 생각하기.**
- ⚠️ **리랭커를 이미지·멀티모달 결과에 쓰려 하기.** 텍스트 전용입니다.
- ⚠️⚠️ **Aurora pgvector에서 필터 필드를 설정하지 않고 필터를 쓰기.** 결과가 조용히 빠집니다.
- ⚠️ **`multi-hop`이라는 낱말을 공식 용어로 외우기.** 동작으로 외웁니다.

---

## 🧪 자가 점검

**Q1.** 청크 최대 토큰을 300으로 설정했는데 어떤 청크가 훨씬 깁니다. 오류입니까?

<details><summary>정답 보기</summary>

**오류가 아닙니다.** 공식 청킹 문서가 **표나 그림이 있는 페이지는 청크가 「더 넓은 맥락」으로 교체된다**고 적습니다(최대 토큰 한도를 두는 전략에서 일어납니다). 표가 끊겨 뜻을 잃는 것을 막는 동작이므로, **설정값이 상한으로 늘 지켜지지는 않습니다.**
</details>

**Q2.** `numberOfResults`를 10으로 줬는데 6개만 돌아옵니다. 가능한 두 원인은 무엇입니까?

<details><summary>정답 보기</summary>

**① 계층형 청킹**(자식 청크가 부모로 합쳐지면서 반환 수가 줄어듭니다) **② 표·그림 맥락 교체**입니다. 둘 다 **오류 없이** 적게 돌려줍니다 — 「검색이 고장났다」로 진단하면 엉뚱한 곳을 고칩니다.
</details>

**Q3.** 저장 비용을 줄이려고 임베딩을 binary로 담고 차원도 256으로 낮추려 합니다. 먼저 확인할 것은 무엇입니까?

<details><summary>정답 보기</summary>

**① 고른 벡터 스토어가 binary를 지원하는지**(⚠️ 지원 스토어가 제한됩니다) **② 차원을 낮추면 표현력이 떨어지므로 도메인 적합성이 유지되는지**입니다. Titan Text Embeddings는 **1,024 · 512 · 256**을 제공합니다. 그리고 임베딩을 대량 생성할 때 스로틀은 **RPM** 단위로 계산합니다.
</details>

**Q4.** 사용자가 제품 코드(`XK-2291`)로 검색하는데 시맨틱 검색이 엉뚱한 문서를 줍니다. 무엇을 쓰고 전제는 무엇입니까?

<details><summary>정답 보기</summary>

**하이브리드 검색**(키워드 + 벡터)입니다. ⚠️⚠️ 전제는 **고른 벡터 스토어가 하이브리드를 지원해야** 한다는 것입니다 — 질의 구성 문서가 지원 스토어를 적습니다. 지원하지 않는 스토어를 이미 골랐다면 **스토어 결정으로 되돌아가야** 합니다(작업 1.4).
</details>

**Q5.** 「작년 실적이 왜 나빴고 올해 계획은 무엇인가」 같은 복합 질문의 검색 품질이 낮습니다. 공식 수단은 무엇이고 어떤 세 동작을 합니까?

<details><summary>정답 보기</summary>

**에이전틱 검색(Agentic Retrieval)**입니다 — FM이 ① **복잡한 쿼리를 하위 쿼리로 분해**하고 ② 여러 지식 베이스에서 **반복적으로 검색**하고 ③ 결과가 **원 질문에 답하기에 충분한지 평가**합니다. 관리형 지식 베이스의 기능입니다. ⚠️ `multi-hop`이라는 **낱말**로 외우지 말고 세 동작으로 외웁니다.
</details>

**Q6.** 에이전트 프레임워크(사용자 지정 코드 없이)에서 지식 베이스를 도구로 쓰고 싶습니다. 공식 경로는 무엇입니까?

<details><summary>정답 보기</summary>

**관리형 지식 베이스 + AgentCore Gateway**입니다. 공식 문구가 **「MCP 호환 에이전트 프레임워크가 사용자 지정 코드 없이 지식 베이스를 도구로 발견하고 호출할 수 있다」**고 적습니다 — `기술 1.5.6`의 「벡터 쿼리를 위한 MCP 클라이언트」가 여기서 근거를 얻습니다. MCP 프로토콜 자체의 계약은 도메인 2에서 다룹니다.
</details>

---

### 📌 출처

1. 콘텐츠 청킹 (표·그림 맥락 교체 · 텍스트 전략의 적용 범위) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html` (2026-11-14 확인)
2. Titan Text Embeddings 모델 (1,024 / 512 / 256 · RPM 스로틀) — `docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html` (2026-11-14 확인)
3. 지식 베이스 동작 방식 (float32 ↔ binary 벡터) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-how-it-works.html` (2026-11-14 확인)
4. 지식 베이스용 벡터 스토어 설정 (binary 지원 · Aurora 필터 필드) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html` (2026-11-14 확인)
5. 질의 구성 (검색 유형 · 하이브리드 지원 스토어 · 암시적 필터 · 결과 수) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html` (2026-11-14 확인)
6. 리랭커 모델 (기본 순위 override · 텍스트 전용) — `docs.aws.amazon.com/bedrock/latest/userguide/rerank.html` (2026-11-14 확인)
7. 리랭커 사용 — `docs.aws.amazon.com/bedrock/latest/userguide/rerank-use.html` (2026-11-14 확인)
8. 에이전틱 검색 (하위 쿼리 분해 · 반복 · 충분성 평가) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-test-agentic-retrieve.html` (2026-11-14 확인)
9. Knowledge Bases 개요 (AgentCore Gateway 네이티브 통합 · MCP 호환 프레임워크) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html` (2026-11-14 확인)
10. OpenSearch Service 시맨틱 검색 (지원이 엔진 버전에 묶인다) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/semantic-search.html` (2026-11-14 확인)
11. OpenSearch Serverless Neural·하이브리드 검색 구성 — `docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-configure-neural-search.html` (2026-11-14 확인)
12. Aurora PostgreSQL을 Bedrock 지식 베이스로 (pgvector) — `docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html` (2026-11-14 확인)
