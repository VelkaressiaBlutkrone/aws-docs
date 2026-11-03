---
생성: 2026-11-03
목적: AIF-C01 v1.1 범위 내 신규·생소 서비스의 공식 정체와 표기 확정
---

# 95 — AWS AI 도구의 정체와 표기 (AIF-C01)

> **원자료 노트** · 조회일 **2026-11-03** · 1차 출처는 `docs.aws.amazon.com`·`aws.amazon.com`만. 확인 못 한 것은 맨 끝 `## 확인 필요`에.
> URL은 전부 `curl -L` 실측했다. AWS 문서는 없는 페이지에도 404가 아니라 200 + 인덱스 리다이렉트를 주므로 **판정 신호는 상태 코드가 아니라 `num_redirects`**다([[repo-toolchain-gotchas]]).

## 1. 왜 이 노트가 필요한가

v1.1이 범위 내 목록에 넣은 `Amazon Quick`·`Kiro`·`Strands Agents`·`Amazon Bedrock AgentCore`·`AWS Transform`은 2025~2026년에 생기거나 **개명된** 것이다. 옛 교재의 이름을 그대로 쓰면 틀린다.

이름 오류는 한 곳에서 끝나지 않는다. 지문·보기·해설·출처 제목으로 파생되고, 뒤늦은 정정이 파생물에 전파되지 않아 **문서와 문항이 서로 모순**한다(SAA·SOA에서 반복된 실패). 그래서 저작 **전에** 표기를 확정하고 §4로 묶는다. 가장 위험한 세 쌍: **`Amazon Quick` ↔ `Quick Sight` ↔ `QuickSight`**, **`Kiro` ↔ `Amazon Q Developer`**, **`SageMaker JumpStart` ↔ `SageMaker AI`**.

## 2. 서비스별 판정 표

URL은 §6에, 「출처」 열은 근거를 적은 §3 소절이다.

| 이름(공식 표기) | 무엇인가 | 범주 | 출제 각도 | 출처 |
|---|---|---|---|---|
| **Amazon Quick** | 작업 자동화·분석·웹앱·리서치 AI 서비스. **QuickSight에서 진화** | 분석 | Quick Sight가 그 **안의 기능** | §3.1 |
| **Kiro** | **스펙 주도 개발**용 AWS 에이전틱 개발 시스템(IDE·CLI·웹) | 개발자 도구 | Q Developer IDE의 **후속** | §3.2 |
| **Strands Agents** | AWS가 공개한 **오픈소스 SDK**(Apache 2.0) | 개발자 도구 | 프레임워크 ↔ 런타임 구분 | §3.3 |
| **AWS Transform** | 인프라·앱·코드 **전환**을 에이전틱 AI로 | 기계 학습 | 메인프레임·VMware·.NET·Java | §3.4 |
| **Amazon Nova** | Amazon의 **FM 패밀리**. Bedrock API로만 접근 | 기계 학습 | 서비스가 아니라 **모델** | §3.5 |
| **Amazon SageMaker JumpStart** | 사전 학습 모델·솔루션 템플릿 **ML 허브** | 기계 학습 | SageMaker AI **안의 기능** | §3.6 |
| **Amazon Q** | **Q Business·Q Developer 두 축**의 어시스턴트 | §5 참조 | **양쪽 모두 축소 중** | §3.7 |
| **Amazon MemoryDB** | 벡터 검색이 **있는** 인메모리 DB. 단 **Bedrock KB 저장소 아님** | v1.1에서 제거 | 벡터 저장소 **오답 후보** | §3.8 |
| **Amazon Bedrock AgentCore** | 에이전트를 **안전하게 규모로 운영**하는 모듈형 플랫폼 | 기계 학습 | 프로덕션 **운영 계층** | §3.9 |

## 3. 서비스별 사실

### 3.1 Amazon Quick — 개명이고, "Quick Suite"는 지난 이름이다

> "an AI-powered service for automating tasks, analyzing data, building web applications, and conducting research"

관계도 공식 한 문장으로 끝난다 — "Amazon Quick **evolved from** Amazon QuickSight. QuickSight continues as **Amazon Quick Sight, a feature within Quick**." 같은 메모가 "All existing QuickSight APIs, SDKs… continue to work without changes"를 덧붙인다 — **API·SDK는 그대로고 이름만 바뀌었다**(SageMaker AI 개명과 같은 패턴).

공식 기능 6종: **Amazon Quick Sight**(BI·시각화) · **Quick Flows**(작업 자동화) · **Quick Automate**(업무 프로세스) · **Quick Index**(사내 문서·데이터 연결) · **Quick Research**(인용 포함 보고서) · **Apps in Amazon Quick**(자연어 웹앱).

⚠️ **이름이 두 번 바뀌었다.** 2025-10 GA 공지는 **`Amazon Quick Suite`**로 적지만 **현재** 제품 페이지·사용자 가이드는 `Amazon Quick`만 쓴다 — `aws.amazon.com/quick/`를 세면 `Amazon Quick` **34건 · `Quick Suite` 0건**(실측). **가이드의 `Amazon Quick`이 현행 공식 표기다.**

### 3.2 Kiro — AWS 서비스인데 AWS 도메인에 문서 홈이 없다

AWS 서비스 개요 백서가 ML/AI 범주에 **`Kiro`**로 싣는다 — "an **agentic development system from AWS**… bridge the gap from AI coding to engineering", 형태는 "**an IDE, CLI, and as an autonomous web agent**" 셋이다.

Q Developer FAQ는 "a standalone agentic development experience… with **spec-driven development**"로 적고, Q Developer의 agent mode·MCP·steering·CLI 기술을 이어받았다고 밝힌다.

⚠️ **1차 출처가 희박하다.** `docs.aws.amazon.com/kiro/`·`.../latest/userguide/`·`.../what-is-kiro.html`·`aws.amazon.com/kiro/`가 **전부 404**다(실측). AWS 공식 서술은 **백서 §Kiro + Q Developer FAQ + 지원 종료 공지**뿐이고 **기능 상세의 정본은 `kiro.dev`**다(§확인 필요 4).

### 3.3 Strands Agents — 오픈소스 SDK이고, 관리형 서비스가 아니다

> "an **open-source SDK** that was initially released by AWS… with a **model-first approach**"

오픈소스 블로그가 라이선스를 명시한다 — "an **open source, Apache 2.0-licensed** SDK". 모델이 에이전트 루프를 끌고 개발자는 도구·프롬프트·런타임 설정으로 행동을 유도한다.

**AWS API·콘솔·요금 페이지가 없다.** "AWS 관리형 에이전트 서비스"로 쓰면 틀린다. 갈림길은 **AgentCore와의 역할 분담**이다 — AgentCore 문서가 Strands를 CrewAI·LangGraph·LlamaIndex와 **나란히 "오픈소스 프레임워크"로** 나열하고 자신은 그것들을 돌리는 플랫폼이라고 말한다.

### 3.4 AWS Transform — 전환 서비스이고, 추가 요금이 없다

> "the **transformation of infrastructure, applications, and code** with an agentic AI experience"

공식 용도: IBM z/OS·**Fujitsu GS21** 메인프레임 현대화 · VMware·Hyper-V 등 가상·베어메탈 서버를 EC2로(디스커버리→웨이브 계획→랜딩 존→네트워크 전환→리호스트, 소스 코드 컨테이너화 포함) · **.NET Framework → 크로스플랫폼 .NET** · 마이그레이션 준비도 평가. 런치 가이드는 **Java·Node.js·Python 업그레이드 같은 "custom" 전환**도 적는다. 요금은 "There are no additional charge to use AWS Transform."

⚠️ **Q Developer 종료 공지가 Transform을 대체재로 직접 지목한다.** Java 런타임 업그레이드·AWS SDK 마이그레이션은 "AWS Transform custom", .NET 포팅은 "full-stack Windows modernization"으로 가라고 적는다. **v1.1의 Transform 추가와 Q Developer 코드 전환 종료는 같은 사건의 양면이다.**

⚠️ **리다이렉트**: 그럴듯한 `userguide/what-is-transform.html`은 **없고** 가이드 인덱스로 1회 리다이렉트된다. 정본은 **`what-is-service.html`**.

### 3.5 Amazon Nova — 서비스가 아니라 모델 패밀리다

> "you must **access the models through an API using Amazon Bedrock**"

Bedrock 쪽은 독점성까지 적는다 — "**available exclusively in Amazon Bedrock**".

공식이 적는 **3개 범주**(Nova 1):

- **Understanding** — **Premier · Pro · Lite · Micro**. 텍스트·이미지·비디오 → 텍스트(**Micro만 텍스트 전용**)
- **Creative** — **Canvas**(이미지) · **Reel**(비디오). 텍스트·이미지 → 이미지/비디오
- **Speech** — **Sonic**. 음성 → 음성 + 텍스트 전사

⚠️ **Nova 2가 별도 가이드로 있다.** Nova 1 가이드 첫머리가 "Amazon Nova 2 is now available"을 알리고 문서가 `nova2-userguide`로 갈린다. 신규 모델은 **Nova 2 Lite · Nova 2 Pro(Preview) · Nova 2 Sonic · Nova Multimodal Embeddings**다. 가이드 이름은 패밀리명 하나이므로 문항은 **세대에 걸쳐 참인 사실**(Bedrock 경유·3개 범주)로 쓰고 모델별 수치는 피한다(§확인 필요 5).

⚠️ **리다이렉트**: `nova/latest/userguide/what-is-nova2.html`은 없고 인덱스로 1회 리다이렉트. 정본은 `nova2-userguide/whats-new.html`.

### 3.6 Amazon SageMaker JumpStart — 개명이 **기능에는 적용되지 않았다**

> "a **machine learning (ML) hub** that can help you accelerate your ML journey"

개발자 안내서는 "pretrained, open-source models"와 **솔루션 템플릿·예제 노트북**을 적고, 접근 경로는 SageMaker Studio의 Models 랜딩 페이지와 **SageMaker Python SDK**다. `SageMaker AI`와의 관계도 공식 문장 하나로 끝난다.

> "On December 03, 2024, Amazon SageMaker was renamed to Amazon SageMaker AI. **This name change does not apply to any of the existing Amazon SageMaker features.**"

따라서 **`Amazon SageMaker JumpStart`이고 `SageMaker AI JumpStart`가 아니다.** JumpStart는 SageMaker AI 안의 **기능(허브)**이며 독립 서비스가 아니다.

⚠️ **공식 문서끼리 어긋난다.** 서비스 개요 백서는 같은 항목을 **`Amazon SageMaker AI JumpStart`**로 적는다. 해당 서비스의 정본이고 더 구체적인 **개발자 안내서의 개명 메모가 이긴다**. 가이드 표기가 맞다.

### 3.7 Amazon Q — **양쪽 축이 모두 축소 중**이다

백서 정의는 두 제품으로 갈린다 — **Q Business**(사내 데이터 질의·요약·작업), **Q Developer**(코딩·테스트·업그레이드·오류 진단·보안 스캔).

**Q Business — 신규 고객에게 닫혔다.** "no longer open to new customers." 기존 고객에게는 버그 수정·보안 업데이트만 이어지고 **신규 기능 요청은 받지 않는다**. 이전 대상은 **Amazon Quick**이다.

**Q Developer — IDE 플러그인·유료 구독이 종료된다.**

| 대상 | 지원 종료 | 신규 차단 |
|---|---|---|
| IDE 플러그인 + 유료 구독 | **2027-04-30** | 신규 가입 **2026-05-15** |
| for GitHub 앱 | **2027-01-30** | 신규 설치 **2026-11-18** |

⚠️ **전부 끝나는 것은 아니다.** 종료 공지가 남는 것을 명시한다 — **AWS Management Console**과 1st-party 경험(AWS 마케팅·문서 웹사이트, Console Mobile App, **Q Developer for Chat Apps**(Slack·Teams))은 "**not impacted** by this sunset". 종료되는 것은 **IDE 플러그인·유료 구독·코드 전환**이다.

**결론(어긋남 판정)**: 개정 표는 `Amazon Q`를 범위 내 추가로 적는데 **본문 목록에는 보이지 않는다**(실측). 공식 사실이 같은 방향을 가리킨다 — Q의 두 축을 잇는 후속이 각각 **Amazon Quick**과 **Kiro**이고 **그 둘이 바로 v1.1에서 추가된 이름**이다. 저작 운영은 §5, 재실측 과제는 §확인 필요 2.

### 3.8 Amazon MemoryDB — 제거와 `Aurora` 추가는 **같은 축**에서 설명된다

MemoryDB에 벡터 검색이 **있다**. 공식 기능 페이지가 "store millions of vector embeddings… at more than 99% recall"과 **single-digit millisecond** 검색, HNSW 인덱스·코사인·내적·유클리드 거리, **추가 요금 없음**을 적는다. "MemoryDB는 벡터를 저장할 수 없다"고 쓰면 틀린다.

⚠️ **그런데 MemoryDB는 Bedrock 지식 기반(KB)의 벡터 저장소가 아니다.** 공식 API 레퍼런스 `StorageConfiguration.type` 유효값 전수가 다음이고 **MemoryDB는 0건**이다.

> `OPENSEARCH_SERVERLESS | PINECONE | REDIS_ENTERPRISE_CLOUD | RDS | MONGO_DB_ATLAS | NEPTUNE_ANALYTICS | OPENSEARCH_MANAGED_CLUSTER | S3_VECTORS`

여기서 **`RDS`가 Aurora PostgreSQL-Compatible과 RDS for PostgreSQL(pgvector)을 함께 덮는다.** 목표 3.1.4의 v1.1 예시(**OpenSearch Service · Aurora · Neptune · RDS for PostgreSQL**)는 이 유효값에서 **서드파티를 뺀 AWS 자체 저장소 집합**과 정확히 겹친다.

**판정**: Aurora 추가·MemoryDB 제거는 범위 내 목록을 **"Bedrock KB가 지원하는 AWS 자체 벡터 저장소"**에 맞춘 것으로 **일관되게 설명된다**. ⚠️ 단 **AWS가 그것을 이유로 적은 문장은 없다** — 두 목록을 대조한 **추론**이고 문항 근거로는 쓰지 않는다.

- ⚠️ **Bedrock이 지원하는 Neptune은 `Neptune Analytics`다**(GraphRAG 용도). Neptune Database가 아니다. 가이드는 "Amazon Neptune"으로만 적어 그 구분을 **생략한다**.
- ⚠️ **`S3_VECTORS`는 유효값인데 가이드 3.1.4 예시에는 없다.** "목록에 없다" ≠ "범위 밖"이므로 언급은 하되 **정답 보기로는 쓰지 않는다**.

### 3.9 Amazon Bedrock AgentCore — 운영 계층이고, 모듈을 따로 쓸 수 있다

(조사 질문 1~8 밖이지만 v1.1 범위 내 목록에 있어 함께 확정했다.)

> "an **agentic platform** for building, deploying, and operating highly effective agents **securely at scale**"

공식이 강조하는 둘: **인프라 관리가 없다**("without any infrastructure management")와 **모듈이 독립적**("work together or independently"). 모델은 "**in or outside of** Amazon Bedrock"까지 된다.

핵심 서비스(공식 표): **Harness**(단일 API 호출 에이전트 루프) · **Runtime**(세션 격리 서버리스) · **Memory** · **Gateway**(API·Lambda를 **MCP 호환 도구**로) · **Identity** · **내장 도구**(Code Interpreter·Browser) · **Observability** · **Evaluations**. 보안 축은 **전용 microVM 세션 격리**·암호화 자격증명·네임스페이스 메모리 격리·감사 로깅.

## 4. 표기 규율 (학습문서·문항에서 이렇게 쓴다)

| 이렇게 쓴다 | 이렇게 쓰지 않는다 |
|---|---|
| **`Amazon Quick`** | ~~`Amazon Quick Suite`~~ — 2025-10 GA 당시 이름. 현행 페이지엔 0건 |
| **`Amazon Quick Sight`**(띄어 쓴다) | ~~`Amazon QuickSight`~~ — 옛 이름. 붙여쓰기 금지 |
| `QuickSight`는 **옛 이름을 가리킬 때만** | 현재 기능명으로 쓰지 않는다. API·SDK 식별자 불변을 함께 적는다 |
| **`Kiro`**(접두어 없이) | ~~`Amazon Kiro`~~를 기본 표기로 쓰지 않는다 — 가이드·백서 모두 `Kiro`(일부 AWS 블로그 제목엔 `Amazon Kiro`가 있어 **금지 가드는 걸지 않는다**) |
| **`Strands Agents`** | ~~`Strands Agent`~~(단수) · ~~`AWS Strands`~~ · "관리형 서비스"라는 서술 |
| **`Amazon Bedrock AgentCore`** | ~~`Bedrock Agents`~~와 섞지 않는다 — **다른 것**. 하위는 `AgentCore Runtime`처럼 |
| **`Amazon SageMaker JumpStart`** | ~~`SageMaker AI JumpStart`~~ — 백서가 그렇게 적지만 **개명은 기능에 적용되지 않는다** |
| **`Amazon SageMaker AI`**(본체) | ~~`Amazon SageMaker`~~로 본체를 가리키지 않는다(2024-12-03 개명) |
| **`AWS Transform`** | ~~`Amazon Transform`~~ · ~~`AWS Transform for Mainframe`~~(용도별 에이전트일 뿐) |
| **`Amazon Nova`**(패밀리) / `Amazon Nova Pro`(모델) | ~~`Nova`~~ 단독. `Nova 2 Pro`를 `Nova Pro`로 쓰지 않는다 |
| **`Amazon Q Developer` · `Amazon Q Business`**(구분) | ~~`Amazon Q`~~로 뭉뚱그려 기능을 서술하지 않는다 — 두 축의 상태가 다르다 |

## 5. 범위 판정

⚠️ **이 레포 규율**: 두 목록 모두 "전체 목록이 아니며 변경될 수 있다"(non-exhaustive and subject to change)고 적으므로 **"목록에 없다" ≠ "범위 밖"**이다. 목록에 없는 공식 정본 서비스는 **"학습문서에 적고 문항 정답 보기로는 쓰지 않는다"**로 운영한다(DVA-C03 저작 결정 D-07과 같은 규율).

| 이름 | 판정 | 저작 운영 |
|---|---|---|
| `Amazon Quick` | **범위 내**(분석) | 정답 가능. Quick Sight 포함 관계를 문항 축으로 |
| `Kiro` | **범위 내**(개발자 도구) | 정답 가능. 기능 상세는 AWS 도메인 근거가 있는 것만 |
| `Strands Agents` | **범위 내**(개발자 도구) | 정답 가능. "오픈소스 SDK" ↔ "관리형 서비스" 갈림길 |
| `AWS Transform` · `Amazon SageMaker JumpStart` · `Amazon Bedrock AgentCore` | **범위 내**(기계 학습) | 정답 가능 |
| `Amazon Nova` | **범위 내**(기계 학습) | 정답 가능. **세대 무관한 사실만** |
| `Amazon Q`(`Q Developer`·`Q Business`) | **목록에 없음** — 개정 표에만 있다 | **정답 금지.** Quick·Kiro의 전신으로만 언급 + 종료 상태 병기 |
| `Amazon MemoryDB` | **v1.1 범위 내 목록에서 제거됨** | 정답 금지. **오답 보기는 가능** — 갈림길은 "벡터 저장 불가"가 아니라 **Bedrock KB 저장소가 아니라는 점** |
| `Amazon S3 Vectors` | **목록에 없음**(Bedrock 유효값엔 있다) | 학습문서에만 적는다 |
| `Amazon Neptune Analytics` | 가이드는 `Amazon Neptune`으로만 적는다 | 문항은 가이드 표기를, 해설에서 **Bedrock 지원 대상은 Neptune Analytics**임을 밝힌다 |
| `Amazon QuickSight` | 옛 이름 | 서비스명으로 쓰지 않는다 |

## 6. 출처 목록

| 제목 | URL | 조회일 |
|---|---|---|
| Amazon Quick 정본 | https://docs.aws.amazon.com/quick/latest/userguide/what-is.html | 2026-11-03 |
| Quick FAQs | https://aws.amazon.com/quick/faqs/ | 2026-11-03 |
| Quick 제품 페이지 | https://aws.amazon.com/quick/ | 2026-11-03 |
| Quick Suite GA(옛 이름) | https://aws.amazon.com/about-aws/whats-new/2025/10/amazon-quick-suite-agentic-ai-powered-workspace/ | 2026-11-03 |
| 서비스 개요 백서 ML/AI | https://docs.aws.amazon.com/whitepapers/latest/aws-overview/machine-learning.html | 2026-11-03 |
| Q Developer FAQs | https://aws.amazon.com/q/developer/faqs/ | 2026-11-03 |
| Strands Agents 정본 | https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/strands-agents.html | 2026-11-03 |
| Strands 공개(Apache 2.0) | https://aws.amazon.com/blogs/opensource/introducing-strands-agents-an-open-source-ai-agents-sdk/ | 2026-11-03 |
| AWS Transform 정본 | https://docs.aws.amazon.com/transform/latest/userguide/what-is-service.html | 2026-11-03 |
| Transform 런치 가이드 | https://docs.aws.amazon.com/transform/latest/launchguide/aws-transform.html | 2026-11-03 |
| Transform FAQs | https://aws.amazon.com/transform/faq/ | 2026-11-03 |
| Nova 1 정본 | https://docs.aws.amazon.com/nova/latest/userguide/what-is-nova.html | 2026-11-03 |
| Nova 2 정본 | https://docs.aws.amazon.com/nova/latest/nova2-userguide/whats-new.html | 2026-11-03 |
| Nova 2 GA 공지 | https://aws.amazon.com/about-aws/whats-new/2025/12/nova-2-foundation-models-amazon-bedrock/ | 2026-11-03 |
| JumpStart 정본 | https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html | 2026-11-03 |
| SageMaker AI 개명 | https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html | 2026-11-03 |
| JumpStart 정의 | https://aws.amazon.com/documentation-overview/sagemaker/ | 2026-11-03 |
| AgentCore 정본 | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html | 2026-11-03 |
| AgentCore 보안(SRA) | https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-generative-ai/gen-ai-sra.html | 2026-11-03 |
| Q Business 신규 차단 | https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html | 2026-11-03 |
| Q Developer IDE 종료 | https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html | 2026-11-03 |
| Q Developer 종료 공지 | https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ | 2026-11-03 |
| MemoryDB 벡터 검색 | https://aws.amazon.com/memorydb/features/ | 2026-11-03 |
| Bedrock KB 저장소 유효값 | https://docs.aws.amazon.com/bedrock/latest/APIReference/API_agent_StorageConfiguration.html | 2026-11-03 |
| 자체 벡터 저장소 전제 | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html | 2026-11-03 |

### 리다이렉트·부재 실측 기록

- `transform/latest/userguide/**what-is-transform.html**` → 200 · **리다이렉트 1회** → 가이드 인덱스(**부재**). 정본 `what-is-service.html`
- `nova/latest/userguide/**what-is-nova2.html**` → 200 · **리다이렉트 1회** → 인덱스(**부재**). 정본 `nova2-userguide/whats-new.html`
- `docs.aws.amazon.com/kiro/` · `/kiro/latest/userguide/` · `/kiro/latest/userguide/what-is-kiro.html` · `aws.amazon.com/kiro/` → **전부 404**(리다이렉트 0). **AWS 도메인에 Kiro 문서 홈이 없다**
- 위 §6 표의 URL 25개는 전부 **200 · 리다이렉트 0**이다.

## 확인 필요

> ✅ **1·2·3은 해소됐다(컨트롤러 실측, 2026-11-03).** 공식 **HTML** 범위 내·범위 외 페이지를 **전수**(잘림 없음) 읽어 대조했다 — 전사는 [00-overview.md](00-overview.md) §4다. PDF는 필요하지 않았다.
> - **`Amazon MemoryDB`**: 범위 내에 없고 **범위 외에도 없다.** 즉 v1.1의 "제거"는 범위 밖으로의 이동이 아니라 **목록에서 삭제**다 → **non-exhaustive 규율 적용**("목록에 없다 ≠ 범위 밖"). §5의 MemoryDB 줄을 그렇게 읽는다.
> - **`Amazon Q`**: 범위 내 목록 본문에 **없고** 범위 외에도 **없다**(개정 표에만 있다). 가이드 내부의 어긋남으로 기록했고 "가이드 오류"로는 단정하지 않는다 — [99-gaps.md](99-gaps.md) G-06.
> - **`Amazon Quick Sight`**: 양쪽 목록에 **모두 없다**(범위 내에는 `Amazon Quick`만 있다). **DVA-C03에서 기록된 "Quick 범위 내 / Quick Sight 범위 밖" 짝은 AIF-C01에는 없다.** 문항에서 둘을 가를 근거로 범위 목록을 쓸 수 없다.
>
> ✅ **6도 절반 해소됐다** — `Amazon Quick` 사용자 가이드의 「What is Amazon Quick?」가 기능을 **`Amazon Quick Sight` · `Amazon Quick Flows` · `Amazon Quick Automate` · `Amazon Quick Index` · `Amazon Quick Research` · `Apps in Amazon Quick`**으로 적는다(2026-11-03 실측). **접두어 붙인 전체 표기가 정본**이고 Q Business 전환 안내의 약칭은 같은 문서의 축약으로 읽는다.
**남은 항목 (4 · 5 · 6):**

4. **Kiro 기능 상세의 AWS 도메인 근거.** Specs·Hooks·Steering files·Custom subagents·Powers·Kiro Crew·CLI 인증(`KIRO_API_KEY`)은 AWS 도메인에 **전용 문서가 없고**(네 슬러그 404 실측) 정본은 `kiro.dev`다. AWS 공식만 쓰는 규율에서는 **기능 단위 문항 근거가 부족하다** — 블로그를 쓸지, 범위를 "Kiro가 무엇인가"로 좁힐지 저작 결정 필요.
5. **`Amazon Nova`를 어느 세대로 가르칠지.** 가이드는 패밀리명만 적고 공식 문서는 Nova 1·Nova 2로 갈린다(모델 구성·컨텍스트 창·최대 출력 토큰이 전부 다르다). **시험 전제 세대는 가이드에 없다.** §3.5는 "세대 무관한 사실만"으로 뒀으나 커버리지 공백 여부는 저작 단계 판정.
6. **`Amazon Quick` 기능 표기가 공식 문서 안에서 흔들리는지.** 사용자 가이드는 `Amazon Quick Sight`·`Amazon Quick Flows`처럼 접두어를 붙이는데, Q Business 전환 안내는 같은 것을 `Quick Sight`·`Flows`·`Automate`로 적는다. **접두어 붙인 전체 표기만 정본인지** 두 페이지로는 확정 못 했다.
