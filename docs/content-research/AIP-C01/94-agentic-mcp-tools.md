---
생성: 2026-11-14
목적: AIP-C01 깊이 조사 ② — 에이전틱 AI · MCP · 도구 통합 (P-03 2/3)
조회일: 2026-11-14
---

# AIP-C01 — 94 에이전틱 AI · MCP · 도구 통합

> 저작 입력의 정본은 [00-overview.md](00-overview.md) §3 공식 전사이고, 저작 규율은
> [98-authoring-decisions.md](98-authoring-decisions.md), 판정하지 못한 것은
> [99-gaps.md](99-gaps.md)다. 이 노트는 **그 기술들을 쓰려면 알아야 하는 공식 사실의 측정 기록**이다.
> 서비스 상태(닫힘·개명)는 [96-service-status-audit.md](96-service-status-audit.md)가 정본이고,
> RAG·벡터·검색 축은 [95-rag-vector-retrieval.md](95-rag-vector-retrieval.md)가 본다.

## 1. 이 축의 범위 — 번호로 센다

| 자리 | 기술 | 수 |
|---|---|---:|
| 작업 2.1 에이전틱 AI 솔루션 및 도구 통합 구현 | 2.1.1 ~ 2.1.7 | 7 |
| 작업 2.5 애플리케이션 통합 패턴 및 개발 도구 구현 | 2.5.1 ~ 2.5.6 | 6 |
| 주변 — 모니터링 | 4.3.4(도구 성능 프레임워크) | 1 |
| 주변 — 평가 | 5.1.7(에이전트 성능 프레임워크) | 1 |
| | **합계** | **15** |

### 1-1. 노트 사이의 경계 — 누가 무엇을 소유하는가

세 깊이 노트가 같은 기술을 양쪽에서 보는 자리가 있어 **소유권을 선언해 둔다.**
선언이 없으면 같은 사실을 두 번 적고, 둘이 어긋나면 어느 쪽이 정본인지 알 수 없다.

| 겹치는 자리 | 소유 | 다른 노트의 역할 |
|---|---|---|
| `기술 1.5.6` MCP 클라이언트로 벡터 쿼리 | **95**(RAG 축) | 94는 MCP 프로토콜·게이트웨이 쪽만 본다 |
| `기술 4.3.4` 도구 호출 관찰성 | **94** | 93은 관찰성 전체 설계(작업 4.3)를 본다 |
| `기술 5.1.7` 에이전트 성능 평가 | **94**(에이전트 쪽 지표·궤적) | 93은 평가 시스템 기계(AgentCore Evaluations 유형·평가자)를 본다 |
| AgentCore Evaluations 일반 | **93** | 94는 에이전트 도구 궤적에 필요한 부분만 인용한다 |

## 2. ⚠️⚠️ G-09 판정 — 세 이름의 공식 실재를 재고 갈랐다

`99-gaps.md` **G-09**가 「기술 본문이 이름으로 드는데 범위 목록 어디에도 없다」로 남긴 셋이다.
저작 전에 공식 실재를 확인하라는 지시였고, **셋의 결론이 서로 다르다.**

### 2-1. ✅ `Strands Agents` — AWS docs에 전용 페이지가 있고 AWS가 자기 프레임워크로 적는다

- AgentCore 개발자 안내서 TOC(598항목)에 **`Strands Agents`**(`supported-frameworks-strands.html`) ·
  **`Strands Agents SDK`**(`strands-sdk-memory.html`) · **`Using AgentCore Code Interpreter via AWS
  Strands`**(`code-interpreter-using-strands.html`) 세 항목이 있다.
- ⭐ `harness.html`이 **`The harness is powered by Strands Agents, the open-source agent framework
  from AWS.`**라고 적는다 — AWS 문서가 직접 자기 프레임워크로 귀속한다.
- 제품 문서 `strandsagents.com/latest/`는 `200 r=0`(313,560바이트)이다.
- **판정: 출제 가능.** 단 표기·개수는 D-05대로 묻지 않는다.

### 2-2. ✅ `MCP` — 전용 페이지가 여럿이고 프로토콜 계약까지 문서화돼 있다

AgentCore TOC에서 **`MCP protocol contract` · `Deploy MCP servers` · `Stateful MCP features` ·
`MCP targets` · `MCP servers targets` · `MCP sessions` · `Use the MCP Inspector` ·
`Using the Registry MCP endpoint` · `AgentCore MCP Server: Vibe coding with your coding assistant`**가
걸린다. 본문은 §5·§6이 정본이다. **판정: 출제 가능.**

### 2-3. ⚠️⚠️ `AWS Agent Squad` — 이름은 AWS가 들지만 **제품 문서가 docs에 없다**

| 측정 | 결과 |
|---|---|
| `docs.aws.amazon.com/agent-squad/` | **`404 r=0`** (= 없는 가이드 접두사 신호. 대조군 `zz-no-such-guide`와 동일) |
| `aws.amazon.com/agent-squad/` | **`404 r=0`** |
| AgentCore TOC에서 `squad` | **0건** (⚠️ 대조군: 같은 파일 `Strands Agents` **2건** — 탐지기는 작동한다) |
| `awslabs.github.io/agent-squad/`(문서 사이트) | **`404 r=0`** |
| `github.com/awslabs/agent-squad` | **`200 r=1` → `github.com/2FastLabs/agent-squad`** |
| 이름을 드는 AWS 쪽 페이지 | `aws.amazon.com/smart-business/resources-for-smb/ai-agent-framework/` (**AWS Editorial · 2025-09-01 · Thought Leadership**) |

그 편집 페이지는 Agent Squad를 **`an AWS Labs framework`**로 적고 분류기 기반 라우팅 ·
`SupervisorAgent`의 **agent-as-tools** 접근 · Python·TypeScript 퀵스타트를 든다.
같은 페이지가 LangChain · Langflow · LangGraph · SmolAgents · CrewAI · OpenAgents를 **나란히** 들어,
제품 문서가 아니라 **프레임워크 비교 글**이다.

- ⚠️⚠️ **리다이렉트는 아카이브가 아니다.** 적을 수 있는 것은 「`awslabs` 슬러그가 `2FastLabs`로
  이동했다」까지이고(`archived`·`public archive` 문구 **0건**), **GitHub는 공식 문서가 아니다.**
- ⚠️ **AgentCore의 공식 프레임워크 목록 둘에 Agent Squad가 없다** — 평가 지원 프레임워크 7종
  (Strands Agents · LangGraph · OpenAI Agents · Vercel AI SDK · LlamaIndex · Google ADK ·
  Claude Agent SDK, §12-3) · Gateway 호환 4종(CrewAI · LangGraph · LlamaIndex · Strands Agents, §6-1).
- ⛔ **판정: 내부 동작·구성요소 이름·수치를 묻지 않는다.** 가이드가 이름을 드는 자리
  (`기술 2.1.1`·`2.5.5`)는 **패턴**(분류기 라우팅 · 수퍼바이저 · agent-as-tool)을 묻고,
  그 패턴의 근거는 docs-proper에 둔다 — Agents Classic 비교표의 `agent-as-tool`(§4-2)과
  Agentic AI Lens `AGENTPERF05-BP02`의 협업 모델 넷(supervisor-worker · pipeline ·
  peer-to-peer/blackboard · swarm)이다.
- ⛔ 그리고 **「AWS 제품이 아니다」로도 단정하지 않는다** — AWS 편집 페이지가 지금도
  `AWS Labs framework`로 적는다. 측정이 말하는 것은 **문서의 부재**뿐이다.

## 3. AgentCore 지도 — 에이전틱 축의 기반

TOC 구역으로 확인한 구성요소: **Runtime** · **Memory** · **Gateway** · **Identity** ·
**Code Interpreter** · **Browser** · **Observability** · **Policy** · **Evaluations** ·
**Payments** · 그리고 그 위의 **harness**.

### 3-1. harness — 선언형 오케스트레이션 계층

`harness.html`이 적는 것(인용 아닌 요약):

- 선언하는 것은 **모델 · 도구 · 스킬 · 지시**이고, AgentCore가 **환경 · 컴퓨팅 · 메모리 ·
  ID · 네트워킹 · 관찰성**을 맡는다. 모델 교체·도구 추가가 **코드 수정이 아니라 구성 변경**이다.
- 세션마다 **격리된 microVM**(Runtime 기반)에서 돌고 **자체 파일시스템과 셸**을 가진다.
  단기·장기 메모리와 파일은 **microVM 세션이 만료돼 교체된 뒤에도** 유지된다.
- 모델은 **Bedrock · OpenAI · Google Gemini · LiteLLM 호환** 공급자 중 아무거나 쓸 수 있고
  ⭐ **세션 중간에 공급자를 바꿔도 컨텍스트를 잃지 않는다**(계획은 한 모델, 실행은 다른 모델).
- 도구는 **Gateway · MCP 서버 · 내장 브라우저 · 코드 인터프리터**로 붙고, **AWS 스킬**을
  Git·S3·큐레이티드 카탈로그에서 토글로 붙인다. 사용자 지정 환경은 **컨테이너를 직접** 가져오고
  **S3 Files 또는 EFS를 마운트**해 세션·harness 사이에 데이터를 공유한다.
- **모든 동작이 자동으로 추적**되고, evaluations·optimization으로 **세션별 통계적 유의성**까지
  보고하는 A/B 테스트를 돌린다. 배포는 **불변 버전 + 명명 엔드포인트**이고 엔드포인트를 이전
  버전으로 돌리면 **즉시 롤백**이다.
- ⭐ **AWS Step Functions의 `InvokeHarness` 상태**로 더 큰 파이프라인에 넣거나,
  구성으로 모자라면 **Strands 코드로 내보내** Runtime에서 돌린다.
- **별도 harness 과금이 없다**(쓰는 AgentCore 역량만 과금). GA.

## 4. ⚠️⚠️ `Amazon Bedrock Agents`는 이제 `Agents Classic`이고 신규 고객에게 닫힌다

`agents-classic-maintenance-mode.html` 첫 문단(공식):
**`Amazon Bedrock Agents (launched November 2023) is now Amazon Bedrock Agents Classic and will no
longer be open to new customers starting on July 30, 2026.`**

- ⚠️⚠️ **집계표와 전용 페이지의 날짜가 다르다** — `99-gaps.md` G-08의 lifecycle 표는
  `Amazon Bedrock Agents Classic`을 **2026-06-30**으로 적는데 전용 페이지는 **2026-07-30**이다.
  레포 규율대로 **전용 페이지를 정본**으로 삼고, **날짜 자체는 묻지 않는다**(§13).
- ⚠️ **트리거를 `Bedrock`으로 넓히면 거짓이 된다**(D-13) — 같은 페이지의 Note가
  `Amazon Bedrock continues to be fully supported`와 **기존 모델·Knowledge Bases·Guardrails는
  영향받지 않는다**를 명시한다. 상태 메모의 대상은 **`Agents Classic`**뿐이다.
- 마이그레이션 경로는 둘이다: **AgentCore의 관리형 harness(권장, 구성 기반)**와
  **AgentCore에 올리는 코드 정의 에이전트**(프롬프트 단계 오버라이드 · 다중 에이전트 협업 ·
  사용자 지정 오케스트레이션 · OpenAI 호환 엔드포인트 · 아무 프레임워크나). AgentCore CLI로
  기존 Classic 구성을 **가져와** 시작점으로 쓸 수 있다.

### 4-1. 비교표의 비자명한 넷

| Classic | AgentCore 대응 | 비자명한 점 |
|---|---|---|
| 단계별 프롬프트 오버라이드(전처리·오케스트레이션·KB 응답 생성·후처리) | harness의 `--system-prompt` | **직접 복제되지 않는다** — 시스템 프롬프트 + 명령 실행 + 자기 관리 스크립트를 조합해야 같은 동작이 된다 |
| `AMAZON.UserInput`(자동 재질의·파라미터 유도) | 인라인 함수 도구 | **return-of-control과 등가**이고 **자동 elicitation이 아니라 명시적 도구 정의가 필요**하다 |
| `AMAZON.CodeInterpreter` | AgentCore 코드 인터프리터 | — |
| 다중 에이전트 협업 역할·라우팅 | **`Limited`** | §4-2 |

### 4-2. ⭐⭐ 가이드가 `기술 2.1.1`에서 프레임워크를 드는 이유가 공식에 적혀 있다

비교표의 다중 에이전트 행(공식): **수퍼바이저 패턴은 에이전트를 MCP 도구로 노출해
(`agent-as-tool`) 가능하지만 **라우팅 모드 다중 에이전트는 오늘 간단하지 않고**,
완전한 다중 에이전트 협업은 **사용자 지정 프레임워크 코드가 필요하다**.

즉 「에이전트 프레임워크를 왜 쓰는가」가 AWS 문서 자신의 서술로 설명된다 —
`기술 2.1.1`(다중 에이전트 시스템)과 `기술 2.5.5`(AWS 네이티브 오케스트레이션)의 갈림길이 여기다.

### 4-3. Classic의 다중 에이전트 협업 — 배너 아래의 사실

`agents-multi-agent-collaboration.html`은 **Classic 가용성 배너**를 달고 있다
(`You can no longer sign up for Amazon Bedrock Agents (now Amazon Bedrock Agents Classic).`).
그 아래 사실: 수퍼바이저를 지정하고 협업 에이전트를 연결하는 **계층형** 모델 ·
⚠️ **수퍼바이저 에이전트를 먼저 저장해야** 협업을 켤 수 있다 · 역할·책임을 자연어로 적고
**중복을 최소화**해야 한다 · 협업 에이전트도 도구·액션 그룹·지식 베이스·가드레일을 전부 쓴다.

## 5. MCP — 프로토콜 계약과 버전 경계 (`기술 2.1.6`·`2.1.7`)

### 5-1. Runtime에 MCP 서버를 올릴 때의 계약

`runtime-mcp.html`:

- 서버는 **`0.0.0.0:8000/mcp`**에 있어야 한다(대부분의 공식 MCP SDK 기본 경로).
- ⚠️⚠️ **`protocolConfiguration.serverProtocol`을 `MCP`로 설정하지 않으면** Runtime은 HTTP로
  동작하고 **JSON-RPC 오류 응답 같은 MCP 동작을 얻지 못한다**(`CreateAgentRuntime`·
  `UpdateAgentRuntime`에서 설정).
- **같은 세션 ID의 요청은 같은 microVM으로** 라우팅된다(microVM stickiness).
- `InvokeAgentRuntime` 페이로드는 **그대로 통과 전달**되므로 MCP 같은 RPC 메시지를 쉽게 프록시한다.
- 배포는 둘 — **직접 코드 배포**(AgentCore CLI가 코드·의존성을 S3로 올리고 Runtime이 환경을 관리) ·
  **컨테이너 이미지**(⚠️ **ARM64**를 빌드해 ECR에 푸시).

### 5-2. ⚠️⚠️ 버전 경계에서 상태성 요구가 뒤집힌다

| MCP 프로토콜 버전 | elicitation · sampling · progress notifications |
|---|---|
| **`2025-11-25` 및 이전** | **stateful 필요** (`stateless_http=False`). 서버가 요청을 먼저 보내는 방식이다 |
| **`2026-07-28` 및 이후** | **stateless**로 동작한다 — 그 방식이 제거되고 **multi round-trip requests 패턴**으로 바뀌었다 |

- stateful 모드에서는 initialize 응답에 **`Mcp-Session-Id` 헤더**가 오고 이후 요청에 실어야 한다.
  서버가 종료되거나 세션이 만료되면 **404**가 올 수 있고 클라이언트는 **재초기화**해야 한다.
- MCP 기능은 여섯이다: **Resources**(URI로 식별되는 데이터) · **Prompts**(재사용 템플릿) ·
  **Tools**(모델이 호출하는 함수) · **Elicitation**(서버가 시작하는 사용자 입력 요청) ·
  **Sampling**(서버가 클라이언트에 LLM 생성을 요청) · **Progress notifications**.

### 5-3. ⚠️ Lambda ↔ ECS 서열은 docs-proper에 없다

`기술 2.1.7`은 「경량 스테이트리스 MCP 서버에 **Lambda**, 복잡한 도구를 제공하는 MCP 서버에
**Amazon ECS**」로 적는다. 측정 결과:

- **docs-proper가 적는 MCP 서버 경로는 둘**이다 — Runtime 호스팅(§5-1)과 Gateway가 **기존 MCP
  서버를 앞단에 두는 타깃**(§6-3). Gateway는 **Lambda 함수를 MCP 도구로 변환**한다(§6-1).
- 세 경로를 가르는 서술은 **AWS Containers 블로그**에 있다(Lambda=경량·스테이트리스·버스티 /
  AgentCore=완전관리 / **ECS on Fargate=런타임·네트워킹·연결 수명을 더 통제해야 할 때**,
  세션형·스트리밍 중심·의존성 무거운·VPC 내부 서버).
- ⚠️ **블로그는 AWS가 발행하지만 문서가 아니다** → **블로그 전용 서열·용례는 묻지 않는다**(§13).
  문항은 docs-proper 사실(Gateway의 Lambda 타깃 · Runtime의 두 배포 경로)로 쓴다.

## 6. Gateway — 도구를 MCP로 만드는 계층 (`기술 2.1.6`·`2.1.7`·`4.3.4`)

### 6-1. 무엇인가

`gateway.html`: 에이전트 트래픽의 **단일 보안 진입점**이다. API·Lambda 함수·기존 서비스를
**MCP 호환 도구로 변환**하고, 다른 에이전트·HTTP 서비스는 **패스스루 타깃**으로 앞단에 두며
(**A2A** 트래픽 포함), 추론 요청은 **모델 기반 라우팅 엔드포인트**로 여러 공급자에 보낸다.
도구 입력 유형은 **OpenAPI · Smithy · Lambda**이고, **인그레스·이그레스 인증을 모두** 제공하는
유일한 완전관리 솔루션이라고 적는다. Salesforce·Slack·Jira·Asana·Zendesk **1-클릭 통합**.

역량 여섯: **Security Guard**(OAuth 인가) · **Translation**(MCP 요청 → API 호출·Lambda 호출) ·
**Composition**(여러 API·함수·도구·에이전트·모델 공급자를 한 엔드포인트 뒤로) ·
**Secure Credential Exchange**(도구별 자격 증명 주입) · **Semantic Tool Selection** ·
**Infrastructure Manager**.

⚠️ 프레임워크 호환으로 적는 것은 **CrewAI · LangGraph · LlamaIndex · Strands Agents**다
(Agent Squad 없음 — §2-3).

### 6-2. 의미 검색 — 도구가 많아질 때의 공식 답

- 도구 이름은 **`x_amz_bedrock_agentcore_search`**이고 `tools/call`로 호출한다.
- ⚠️⚠️ **게이트웨이를 만들 때 켜 둬야 한다**(`gateway-using-mcp-semantic-search.html`:
  `If you enabled semantic search for your gateway when you created it`).
- 공식이 적는 값: **수천 개의 도구를 쓰면서 프롬프트 크기를 최소화하고 지연을 줄인다.**
- 지원 리전은 **18개**이고 **서울(`ap-northeast-2`)이 든다**. ⚠️ 리전 **수**는 묻지 않는다(§13).
- ⚠️ 게이트웨이는 `protocolConfiguration.mcp`의 **`supportedVersions`에 든 버전만** 받는다
  (`UpdateGateway`로 바꾼다).

### 6-3. MCP 서버 타깃 — `ListingMode`가 다른 기능을 끈다

`gateway-target-MCPservers.html`:

| ListingMode | 동작 | ⚠️ |
|---|---|---|
| **`DEFAULT`**(기본) | `SynchronizeGatewayTargets`가 제공하는 동기화로 역량을 발견한다 | 생성·수정 시 **암시적 동기화**가 돌아 `tools/list`·`prompts/list`·`resources/list`·`resources/templates/list`를 통합 카탈로그에 넣는다 |
| **`DYNAMIC`** | 사용자가 MCP 작업을 호출할 때 클라이언트가 역량을 발견한다(게이트웨이가 요청을 전달) | ⚠️⚠️ **의미 검색과 아웃바운드 3LO(three-legged OAuth)와 상호 운용되지 않는다** |

- MCP 서버의 도구·프롬프트·리소스 정의가 바뀌면 **`SynchronizeGatewayTargets`를 호출해야 한다**
  (PUT `/gateways/{id}/synchronize`, **202를 즉시 반환하고 비동기로 처리**).
- ⭐ 이유가 문서에 있다 — Gateway가 **의미 검색용 벡터 임베딩을 미리 계산**하고 정규화된 카탈로그를
  유지하기 때문이다. 동기화하지 않으면 **최신 도구를 발견·호출할 수 없다.**

### 6-4. 속도 제한 — 리소스 경계를 트래픽 시점에 적용한다 (`기술 2.1.3`)

`gateway-rate-limits.html`: **dimension keys**로 트래픽을 버킷으로 묶고 **entries**로 버킷별
허용 속도를 정한다.

- `dimensionKeys`는 **1~10개이고 생성 후 불변**, `entries`는 **1~1,000개**.
- ⚠️ 활성 속도 제한이 여럿이면 **전부 통과해야 요청이 진행된다(AND)**.
- 변경은 **30초 안에** 데이터 플레인으로 전파된다.
- ⚠️⚠️ 고객 정의 값은 **서비스 상한을 넘을 수 없고 유효 속도는 둘 중 최솟값**이다.
- **속도를 0으로 두면 특정 호출자를 차단**한다. 추론 타깃은 **분당 토큰(TPM)**으로 제어하고
  엔드포인트의 **동시 연결 수**도 제한한다.

### 6-5. ⚠️⚠️ 모델 라우팅·폴백 — 서킷 브레이커가 여기 있다 (`기술 2.1.3`·`2.4.3`·`2.4.4`)

`gateway-rules-fallback.html`:

- `matchModels` 조건 + `routeToTarget.staticRoute` 액션으로 **기본 모델 기반 라우팅을 덮어쓴다**
  (여러 타깃이 같은 모델을 맡으면 기본 라우팅은 **아무 쪽으로나** 보낸다 — 규칙이 고정한다).
  `staticRoute`에 `model`을 적으면 **호출자가 요청한 모델과 다른 모델을 서빙**할 수 있다.
- `targetFallback`은 **1~2개**의 대체 목적지를 순서대로 둔다. `triggerOn`이 떠나는 조건이고,
  **`firstByteTimeoutMilliseconds`**는 공급자가 깔끔한 오류 없이 **멈춰 있을 때**를 위한 것이다.
- **`circuitBreaker`는 기본 `ENABLED`**이고, 지금 실패 중인 목적지를 **건너뛴다**.
- 게이트웨이는 체인을 순서대로 걷고 각 목적지를 **한 번** 시도한다. 전부 실패하면
  호출자는 **마지막 오류**를 받는다.
- ⚠️⚠️ **스트리밍 응답이 시작된 뒤에는 폴백할 수 없다** — 호출자는 **부분 응답과 오류**를 받고
  직접 재시도해야 한다. ⭐ `기술 2.4.2`(스트리밍)와 `기술 2.4.3`(복원력)이 충돌하는 자리다.

## 7. 메모리와 상태 관리 (`기술 2.1.1`)

### 7-1. 두 가지 메모리

| | 단기 | 장기 |
|---|---|---|
| 담는 것 | **원시 상호 작용**(이벤트) | 추출된 **구조화 레코드**(요약 · 사실 · 사용자 선호) |
| 범위 | **한 세션** | **여러 세션에 걸쳐 유지** |
| API | `CreateEvent` · `ListSessions` · `ListEvents` · `GetEvent` | 전략이 자동 추출 |

- 이벤트는 `sessionId`로 묶이고, 값을 주지 않으면 시스템이 만든다.
- **이벤트 메타데이터**는 키-값으로 붙이고 `ListEvents` 필터로 꺼낸다(세션 전체를 훑지 않는다).
  ⚠️⚠️ **고객 관리 키로 암호화되지 않으므로 민감 콘텐츠를 담지 않는다**(공식 서술).

### 7-2. ⚠️⚠️ 전략을 지정하지 않으면 장기 메모리가 만들어지지 않는다

`memory-strategies.html`: **`If no strategies are specified, long-term memory records will not be
extracted for that memory.`** — 메모리 리소스를 만든 것만으로는 장기 기억이 생기지 않는다.

| 전략 | 통제 | ⚠️ 저장 비용 |
|---|---|---|
| **내장(Built-in)** | AgentCore가 추출·통합을 전부 자동으로. 트리거 설정 외 구성 불필요 | **더 높다** |
| **내장 오버라이드** | 관리형 추출 파이프라인을 쓰면서 **프롬프트를 수정**한다(Bedrock 모델을 **내 계정에서** 호출) | 내장보다 낮다 |
| **자기 관리(Self-managed)** | 추출·통합 알고리즘·스키마·네임스페이스를 전부 소유. 외부 시스템 통합 가능 | 내장보다 낮다 |

- 한 메모리 리소스가 **내장과 사용자 지정 전략을 동시에** 쓸 수 있다.
- 내장 전략 종류는 TOC로 확인된다: **semantic · user preference · episodic**(각각 시스템 프롬프트
  페이지가 따로 있다) + **custom** + **self-managed**.

### 7-3. Runtime 세션의 수명과 격리 (`기술 2.1.3`과 함께 읽는다)

`runtime-how-it-works.html`:

- 세션은 **`runtimeSessionId`**로 식별된다 — 애플리케이션이 주거나, 비워 두면 **첫 호출에서
  Runtime이 만든다**.
- **세션마다 전용 microVM**에서 돌고 **CPU·메모리·파일시스템이 완전히 격리**된다.
- **총 런타임 최대 8시간**까지 유지된다. 종료 조건 셋: **비활성 15분** · **최대 수명 8시간** ·
  **비정상(unhealthy) 판정**.
- ⚠️⚠️ 종료되면 **microVM 전체가 종료되고 메모리가 소거된다.** 같은 `runtimeSessionId`로
  다시 요청하면 **새 실행 환경이 만들어진다**(이어지지 않는다).
- 버전은 **불변**이고 생성 시 V1이 자동으로 만들어진다. **`DEFAULT` 엔드포인트는 최신 버전을
  자동으로 참조**하고, 환경별(dev·test·prod) 엔드포인트는 `CreateAgentRuntimeEndpoint`로 만든다.
  엔드포인트 상태는 `CREATING`·`CREATE_FAILED`·`READY`·`UPDATING`·`UPDATE_FAILED`이고
  **무중단 업데이트·롤백**이 된다.

## 8. 제어된 FM 동작 (`기술 2.1.3`)

### 8-1. ⭐⭐ Policy in AgentCore — 정책 언어가 **둘**이고 AIF 트랙의 열린 판정을 닫는다

`policy.html`: 정책 엔진을 만들어 **게이트웨이에 연결**하면 **모든 에이전트 트래픽을 가로채**
도구 접근 **전에** 각 요청을 평가한다. 보안 제어가 **에이전트 코드 밖으로** 나가므로
에이전트 조작으로 정책을 우회할 위험이 줄어든다.

- 정책은 **Cedar**(오픈소스 인가 언어)로 구성한다.
- ⭐ **그리고 `Dogwood`로도 저작할 수 있다** — AIF-C01 트랙이 「공식 내부가 Cedar/Dogwood로
  어긋난다」로 남긴 자리인데, **현행 페이지는 둘을 함께 적는다**(어긋남이 아니라 **둘 다 지원**).
  Dogwood 하나의 정책이 세 종류의 조건을 **같은 permit·forbid 모델 안에서** 조합한다:
  ① **입력 기반**(주체·도구·리소스·입력 파라미터) ② **세션 인식 시간 조건**(전송 전에 승인이
  있었는지 · 정해진 횟수 뒤 차단 · 누적 예산 유지) ③ **정보 공급자**(Guardrails가 평가 시점에
  내는 콘텐츠 안전·프롬프트 공격 **점수**로 판단).
- **자연어로 정책을 적을 수 있고**, 생성된 후보 정책을 도구 스키마로 검증하고 **자동 추론**으로
  **과도 허용·과도 제한·절대 충족될 수 없는 조건**을 **적용 전에** 잡는다.
- TOC에 **`Test a policy in LOG_ONLY mode`**가 있다(차단 전에 관찰하는 모드).

### 8-2. 서킷 브레이커 — 공식 근거가 세 자리에 있다

| 자리 | 사실 |
|---|---|
| Gateway 규칙 | `circuitBreaker`가 **기본 ENABLED**(§6-5) |
| Lens `AGENTOPS04-BP03` | **자동 차단**이 연쇄 실패를 막는 가장 효과적인 통제다. 임계 예시 — **60초 창에서 오류 50%** 또는 **연속 타임아웃 5회**면 차단, **약 30초** 뒤 probing. **이미 사고를 낸 의존성만이 아니라 모든 외부 의존성에** 적용한다 |
| Lens `AGENTSEC06-BP02` | Step Functions의 오류 처리·재시도로 구현하고 **catch 상태가 실패 실행을 quarantine 경로로** 보낸다(무한 재시도 금지). **EventBridge가 임계 초과 시 서킷 브레이커 이벤트를 낸다** |

⚠️ **폴백 순서는 도구 레지스트리에 둔다** — 에이전트 코드에 박으면 도구 목록이 바뀔 때 따라가지
못한다(`AGENTOPS04-BP03`). 재시도·타임아웃 정책은 **전역이 아니라 도구별**이다.

### 8-3. 중지 조건과 반복 상한

| 자리 | 사실 |
|---|---|
| `AGENTPERF02-BP01` | **perceive-reason-act 루프**의 반복 수가 지연과 비용을 **곱한다**. **반복 상한 + 신뢰도 기반 조기 종료**로 폭주를 막고, **작업당 평균 추론 반복 수를 1급 KPI**로 지연·토큰 지표와 나란히 본다 |
| `AGENTCOST01-BP01` | 종료 조건은 셋 — **최대 반복 수 · 신뢰도 임계 · 세션당 토큰 예산**. ⚠️ **고정 반복 수를 신뢰도 임계 대신 쓰는 것이 안티패턴**이다(토큰을 낭비하거나 복잡한 추론을 조기에 끊는다). 반성(reflection)은 **초기 출력 품질이 임계 아래일 때만** 선택적으로 돌린다 |
| `AGENTPERF02-BP01` 안티패턴 | ⚠️ **실패한 LLM 호출을 같은 프롬프트·같은 모델로 재시도하는 것** — 의미를 바꿔 다시 묻거나 작업을 단순화하거나 더 유능한 모델로 폴백한다 |

## 9. 추론 구조화와 모델 조정 (`기술 2.1.2`·`2.1.4`)

### 9-1. ⚠️⚠️ `ReAct`라는 낱말은 docs-proper에서 확인되지 않았다

- Agentic AI Lens가 쓰는 표현은 **`perceive-reason-act loop`**(`AGENTPERF02-BP01`)와
  `reasoning loop`·`reflection pattern`(`AGENTCOST01-BP01`)이다.
- **`ReAct`를 논문까지 인용하는 것은 AWS 오픈소스 블로그**(`Strands Agents and the Model-Driven
  Approach`)다 — 「the ReAct paradigm ... 위에 세웠다」로 적는다.
- ⛔ **전수 탐색이 아니므로 「docs에 `ReAct`가 0건」으로 단정하지 않는다**(「목록에 없다 ≠ 없다」).
- ✅ 처리: **낱말이 아니라 동작을 묻는다** — 추론과 행동이 번갈아 일어나는 루프, 반복 상한,
  조기 종료, 재시도 전략. 이것들은 전부 docs-proper에 있다(§8-3).

### 9-2. Step Functions와의 역할 분담

`AGENTSEC06-BP02`가 두 오케스트레이션 패턴을 **범위로 가른다**:

- **Step Functions 상태 머신** — 실행 경로가 **JSON으로 정의**되고 오케스트레이터가 순서를 강제하는
  **결정적** 워크플로.
- **AgentCore Runtime + A2A 프로토콜** — 오케스트레이터 에이전트가 **어느 하위 에이전트를
  호출할지 동적으로 결정**하는 에이전트 위임 워크플로.

그 위의 통제: IAM으로 워크플로 시작·중지·수정 권한을 주체·상태 머신 단위로 제한 ·
리소스 기반 정책으로 정의 변경 방지 · **입력 검증은 상태 머신 정의 안**(JSONPath 필터 + Lambda
검증 함수)에서 하고 **밖에서 하지 않는다** · 실행 로깅을 CloudWatch Logs **`ALL` 레벨**로 켜서
모든 상태 전이·입출력·오류를 남긴다.

⭐ 그리고 harness는 Step Functions의 **`InvokeHarness` 상태**로 파이프라인에 들어간다(§3-1) —
결정적 단계가 비결정적 에이전트 단계를 감싸는 구조가 공식 경로로 있다.

### 9-3. 모델 조정 — 공식 경로가 셋이고 제약이 서로 다르다

| 경로 | 무엇을 하는가 | ⚠️ 제약 |
|---|---|---|
| **Bedrock intelligent prompt routing** | 단일 서버리스 엔드포인트가 요청마다 **각 모델의 응답 품질을 예측**해 가장 좋은 쪽으로 보낸다. 기본 라우터(Nova·Llama 계열)와 구성 라우터, **폴백 모델**, 응답 품질 차이 기준 | ⚠️⚠️ **같은 모델 패밀리 안에서만** 라우팅한다. ⚠️ **영어 프롬프트에만 최적화**돼 있다 |
| **Gateway 모델 라우팅·폴백** | 규칙으로 모델→타깃을 고정하고 **1~2개 대체 목적지**와 서킷 브레이커를 둔다(§6-5) | 스트리밍 시작 후 폴백 불가 |
| **harness의 공급자 전환** | **세션 중간에** Bedrock·OpenAI·Gemini·LiteLLM 호환 공급자를 바꿔도 컨텍스트가 유지된다(§3-1) | — |

⚠️ **「같은 모델 패밀리」가 결정적 제약이다** — 패밀리를 넘어 라우팅한다고 적는 보기는 거짓이다.
`기술 2.2.3`의 「API 기반 모델 캐스케이딩」과 `기술 2.1.4`의 「모델 선택 프레임워크」는
이 셋 중 어느 것인지로 갈린다.

## 10. 인간 증강 (`기술 2.1.5`)

`AGENTSEC04-BP02`가 이 기술의 정본이다. 핵심 문장: **전건을 사람에게 보내면 고무도장이 되고,
아무것도 보내지 않으면 무제한 자율이 된다.**

- 기준선: **읽기 전용은 자율 진행** · **저위험 쓰기는 단일 검토자 승인** · **고위험(금융 거래 ·
  데이터 삭제 · 외부 통신)은 더 엄격**(단일·복수·대역 외 — 위험 정책에 따라).
- ⚠️⚠️ **위험 분류 자체를, 평가 대상과 같은 비신뢰 콘텐츠에 노출된 LLM에 의존할 수 없다** —
  적대적 콘텐츠가 분류기를 꾀어 저위험으로 표시하게 만들 수 있다. **결정적 로직**(정책 엔진 ·
  규칙 기반 분류기)이 권위 있는 신호이고, LLM 분류는 **결정적 계층이 다시 검사하는** 선택 입력이다.
- **지속 신뢰 부여**(한 번 승인하면 같은 패턴은 재승인 없이 통과)는 유용한 탈출 밸브지만
  **판단 시점을 앞으로 옮긴다**. 각 부여를 **특정 명령·파라미터 모양·리소스로 한정**하고,
  고위험은 부여 대상에서 빼거나 정해진 주기로 재확인하게 하고, 부여 자체를 감사·철회 가능하게 한다.
  ⚠️⚠️ **와일드카드 신뢰 부여(파라미터 범위 없이 그 유형의 모든 미래 작업을 승인)는 발급하지 않는다.**
- 승인 결정은 **타임스탬프와 검토자 신원**과 함께 로깅해 감사 기록을 만든다.
- 승인 경로: Step Functions 워크플로라면 **`.waitForTaskToken` 콜백 패턴**으로 승인 단계를 넣는다
  (워크플로가 태스크 토큰을 내고 멈춘다).
- 안티패턴 셋: 전건 검토 · **컨텍스트 없는 검토**(제안 동작만 주고 추론 체인·데이터 출처·결과를
  주지 않으면 검토가 형식이 된다) · ⚠️ **타임아웃·에스컬레이션 경로 없는 승인 워크플로**
  (검토자가 없으면 실행이 무한정 멈춘다).
- Classic 비교표의 **인라인 함수 도구 = return-of-control**(에이전트가 멈추고 `tool_use`를
  클라이언트 코드에 돌려주고, 클라이언트가 사람과 상호 작용한 결과를 돌려보낸다. §4-1).

## 11. 애플리케이션 통합과 개발 도구 (작업 2.5)

### 11-1. ⚠️ `Amazon Bedrock Prompt Flows` ↔ 현행 `Amazon Bedrock Flows`

`기술 2.5.2`는 「노코드 워크플로 빌더를 위한 **Amazon Bedrock Prompt Flows**」로 적는다. 측정:

| 측정 | 결과 |
|---|---|
| 현행 페이지 제목 | **`Build an end-to-end generative AI workflow with Amazon Bedrock Flows`** |
| Bedrock 사용자 안내서 TOC에서 `prompt flow` | **0건** (⚠️ 대조군: `flow`를 담은 항목 **57건**) |
| `prompt-flows.html` | **`200 r=1` → 가이드 인덱스**(2,257바이트) |

- ⛔ **개명을 단정하지 않는다** — `prompt-flows.html`의 신호는 **없는 슬러그와 똑같다**
  (대조군 `zz-bogus-control.html`도 같은 인덱스·같은 크기). 「이름이 바뀌었다」와 「그 슬러그가
  애초에 없었다」를 이 측정으로 가를 수 없다.
- ✅ 적을 수 있는 것: **현행 공식 표기는 `Amazon Bedrock Flows`**이고 TOC에 구 표기가 없다.
- Flows 사실: **비주얼 빌더**로 프롬프트·FM·지식 베이스·Lambda 등 **노드를 연결**하고,
  **불변 워크플로를 배포**해 테스트에서 운영으로 옮긴다. 요금은 **쓰는 리소스에 따른다**
  (예: 프롬프트 노드가 모델을 호출하면 그 모델 호출이 과금된다).

### 11-2. Bedrock Data Automation (`기술 2.5.3`)

`bda.html`: 문서·이미지·**비디오·오디오** 같은 비정형 콘텐츠를 **구조화 형식으로 변환**한다.
용례 셋 — **IDP**(분류·추출·정규화·검증을 직접 오케스트레이션하지 않는다) · **미디어 분석**
(장면 요약 · 안전하지 않은 콘텐츠 식별 · 영상 내 텍스트 추출 · 광고·브랜드 기준 분류) ·
**RAG 보강**(모달리티별 풍부한 표현을 질의응답 애플리케이션에 공급).
**단일 인터페이스의 API 주도 경험**이고, 내장 보호 장치로 **시각적 그라운딩과 신뢰도 점수**를 적는다.

### 11-3. 개발 도구 (`기술 2.5.4`·`2.5.6`)

- `Amazon Q Developer`는 **콘솔 쪽이 개명**됐고 **IDE 플러그인은 2027-04-30 지원 종료**이며
  공식이 드는 대안이 **Kiro**다 — 정본은 `96-service-status-audit.md` §6-3·§6-4(**G-15**·**G-16**).
  ⚠️ 관계를 모르면 **대체된 쪽을 정답으로** 가르친다.
- ⭐ 덤으로 docs-proper에 **`Amazon ECS MCP server`**가 있다
  (`AmazonECS/latest/developerguide/ecs-mcp-introduction.html`) — **Kiro**를 MCP 호환 AI 코딩
  어시스턴트로 직접 들고, **완전관리형으로 AWS 클라우드에 호스팅**되며(로컬 설치 불필요)
  IAM 통합·**CloudTrail 감사 로깅**을 적는다. 배포 상태·서비스 이벤트·컨테이너 상태 모니터링,
  작업 실패·이미지 풀 오류·컨테이너 로그 분석, VPC·서브넷·보안 그룹 점검이 도구로 제공된다.
  `기술 2.5.6`(문제 해결 효율)의 **MCP 쪽 근거**로 쓸 수 있다.

## 12. 도구 관찰성과 에이전트 평가 (`기술 4.3.4`·`5.1.7`)

### 12-1. ⚠️⚠️ 「도구 호출 관찰성」은 **세 층**이고 섞으면 거짓이 된다

| 층 | 무엇을 주는가 | ⚠️ 경계 |
|---|---|---|
| **내장 도구 지표** | `Invocations` · `Throttles` · `SystemErrors` · `UserErrors` · `Latency` · `Duration` (+ 브라우저 **테이크오버 수·해제 수·시간**) | ⚠️⚠️ **코드 인터프리터와 브라우저 둘에만** 있다. **1분 간격 배치** |
| **Gateway 쪽** | gateway observability data · 속도 제한 지표 · CloudTrail 이벤트 | 도구가 **게이트웨이를 지날 때만** |
| **에이전트 자신의 도구 호출** | 프레임워크가 내는 스팬 — `gen_ai.operation.name`이 **`invoke_agent` · `execute_tool` · `chat`** | 프레임워크 계측에 달렸다(§12-3) |

- `Throttles`는 TPS·쿼터 초과로 서비스가 거부한 수이고 **`ThrottlingException` + HTTP 429**다.
- `Latency`는 **요청 수신부터 첫 응답 토큰을 보내기 시작할 때까지**다(전체 처리 시간이 아니다).
- 리소스 사용 지표는 **`CPUUsed-vCPUHours` · `MemoryUsed-GBHours`**이고 차원은
  `Service`(**`AgentCore.CodeInterpreter`** 또는 **`AgentCore.Browser`**)와 `Resource`(도구 ID)다.
  계정 수준·도구 수준 모두 **1분 해상도**로 벤딩된다.
- ⚠️⚠️ **리소스 사용 데이터는 최대 60분 지연될 수 있고** 지표마다 정밀도가 다를 수 있다
  (공식 Note) — 「실시간으로 CPU·메모리를 보고 스케일한다」류 설계는 이 사실에 걸린다.

### 12-2. 도구 신뢰성 지표 — Lens 쪽 축

`AGENTOPS04-BP03`: **AgentCore Observability가 도구별로 호출 수 · 성공률 · 유형별 오류율 ·
지연 백분위수를 추적**한다. ⭐ **복합 알람(composite alarm)**이 여러 지표를 묶는다 —
**지연이 오르면서 타임아웃 비율도 오르는 도구**는 단일 임계로는 어느 쪽도 울리지 않아도
차단에 가까워진 도구이고, 복합 보기가 **단일 임계보다 먼저** 열화를 잡는다.

`AGENTPERF06-BP03`(메타 도구): 예측 가능한 도구 순서는 **하나의 서버 측 작업으로 묶어**
한 번의 추론 반복으로 끝낸다 — **Lambda 함수로 구현**하고 **MCP·Gateway로 개별 도구와 나란히
노출**해 에이전트가 **일상 작업엔 메타 도구, 새로운 작업엔 개별 도구**를 고르게 한다.
판단 근거는 **텔레메트리에서 세 번 이상 반복되는 순서**이고, 메타 도구 지연을 **단계별로 분해**해
가장 느린 단계를 고친다. ⚠️ 안티패턴: 변형을 너무 많이 떠안아 **개별 도구보다 느려지는 메타 도구**.

### 12-3. 에이전트 평가 — `기술 5.1.7`에 필요한 만큼

> 평가 시스템 전체(유형 · 평가자 종류 · 온라인/배치 운영)는 노트 **93**이 본다. 여기서는
> **에이전트 쪽**만 적는다.

- **지원 프레임워크 7종과 계측 라이브러리**(`supported-frameworks.html`):
  **Strands Agents**(Python·TypeScript, **SDK 내장 계측 — 추가 라이브러리 불필요**) ·
  **LangGraph** · **OpenAI Agents** · **Vercel AI SDK** · **LlamaIndex** · **Google ADK** ·
  **Claude Agent SDK**, 그리고 **Generic framework support**.
  나머지는 **OpenTelemetry 또는 OpenInference 계측 라이브러리**와 **권장 버전 하한**이 있다.
- 서비스는 스팬의 **`scope.name`**으로 어느 계측 라이브러리인지 판별한다. 같은 프레임워크라도
  **Python과 TypeScript가 다른 scope name**을 낸다(추출하는 값은 같다).
- 스팬 분류는 **`gen_ai.operation.name`**으로 한다(`invoke_agent`·`execute_tool`·`chat`).
  도구 이름은 **`gen_ai.tool.name`**이고, 인자·결과는 전달 모드에 따라 **분리 텔레메트리의
  이벤트 레코드** 또는 **스팬에 붙은 인라인 이벤트**에서 읽는다.
- AgentCore Runtime + **ADOT**에 배포하면 Runtime이 **`session.id`를 주입**하고 스팬·이벤트를
  자동으로 내보낸다.
- ⚠️⚠️ **계측만으로는 평가되지 않는다** — 공식 Note: 계측은 한 단계이고 에이전트가
  **관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야** 평가 서비스가 읽는다.
- **배치 평가는 그라운드 트루스를 세션 메타데이터로** 받는다 — 기대 응답 · 어서션 ·
  ⭐ **기대 도구 궤적(expected tool trajectories)**. `기술 5.1.7`의 「도구 사용 효율성 평가」가
  여기서 근거를 얻는다.
- **스킬 평가자는 도구 호출이 스킬을 적재할 때만** 적용된다
  (`built-in-evaluators-overview.html`).

## 13. 묻지 않을 것 (이 축의 D-규율 적용)

- **Agent Squad의 내부 동작·구성요소 이름·수치**(§2-3). 가이드가 이름을 드는 자리는
  **패턴**으로만 묻는다.
- **개수** — AgentCore 구성요소 수 · 지원 프레임워크 수 · Gateway 역량 수 · MCP 기능 수 ·
  의미 검색 리전 수(⚠️ 단 **서울이 든다** · **게이트웨이 생성 시 켜야 한다**는 **성질**이라 쓴다).
- **날짜** — Agents Classic 신규 고객 차단일(⚠️ **집계표 2026-06-30 ↔ 전용 페이지 2026-07-30**.
  상태 **사실**은 쓰고 날짜는 묻지 않는다).
- **MCP 프로토콜 버전 문자열을 외우게 하는 것**(⚠️ 단 **버전 경계에서 상태성 요구가 뒤집힌다**는
  성질은 쓴다 — §5-2).
- **`ReAct`라는 낱말의 공식 여부**(§9-1). 동작만 묻는다.
- **Lambda ↔ ECS 호스팅 서열**(블로그 전용 — §5-3).
- **`Prompt Flows` → `Flows` 개명 여부**(측정으로 가를 수 없다 — §11-1). 표기만 현행으로 쓴다.
- **`Strands`·`Agent Squad`의 표기·개수**(D-05 그대로).
- **`Kiro`의 기능 수·가격·모델 목록**(D-12 — AWS docs에 근거가 없다).
- **내장 도구 지표를 모든 도구에 일반화하는 것**(§12-1 — 둘에만 있다).

## 14. 출처 (전부 `curl -sL` 실측 · 2026-11-14 · **38개 전부 `200 r=0`**)

| 제목 | URL |
|---|---|
| AgentCore 개요 | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html |
| AgentCore harness(**Strands가 구동한다** · `InvokeHarness` · 공급자 전환) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html |
| Runtime microVM·세션(8시간 · 비활성 15분 · 메모리 소거) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html |
| MCP 서버 배포(`0.0.0.0:8000/mcp` · ARM64 · 세션 stickiness) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-mcp.html |
| MCP 프로토콜 계약 | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-mcp-protocol-contract.html |
| Stateful MCP 기능(기능 6종 · `Mcp-Session-Id` · 버전 경계) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/mcp-stateful-features.html |
| 메모리 유형(이벤트 메타데이터 **CMK 미암호화**) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-types.html |
| 메모리 전략(**전략 없으면 장기 기억 없음** · 비용 서열) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html |
| Gateway 개요(역량 6종 · 프레임워크 호환 4종) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html |
| MCP 서버 타깃(`ListingMode` · `SynchronizeGatewayTargets`) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-target-MCPservers.html |
| 의미 검색(`x_amz_bedrock_agentcore_search` · 생성 시 활성화 · 18리전) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using-mcp-semantic-search.html |
| 모델 라우팅·폴백(**서킷 브레이커 기본 ENABLED** · 스트리밍 후 폴백 불가) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rules-fallback.html |
| 속도 제한(차원 1~10 불변 · AND · 30초 전파 · 최솟값) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rate-limits.html |
| Policy in AgentCore(**Cedar + Dogwood** · 자연어·자동 추론) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html |
| 내장 도구 관찰성(둘에만 · 60분 지연 · vCPU·GB-Hours) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-tool-metrics.html |
| 평가 유형 셋(+그라운드 트루스·도구 궤적) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html |
| 평가자(내장·3자·사용자 지정) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluators.html |
| 내장 평가자(`Builtin.<이름>` · 변경 불가 · 스킬 평가자 조건) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html |
| 지원 프레임워크 7종·계측 라이브러리·`scope.name` | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html |
| Strands 텔레메트리(`gen_ai.operation.name` · 내장 계측) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks-strands.html |
| 코드 인터프리터 × AWS Strands | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/code-interpreter-using-strands.html |
| **Agents Classic 유지 관리 모드**(2026-07-30 · 비교표 · 다중 에이전트 `Limited`) | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html |
| Classic 다중 에이전트 협업(수퍼바이저 먼저 저장) | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html |
| 지능형 프롬프트 라우팅(**같은 패밀리** · 영어 최적화) | https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html |
| **Amazon Bedrock Flows**(현행 표기 · 불변 배포) | https://docs.aws.amazon.com/bedrock/latest/userguide/flows.html |
| Bedrock Data Automation(시각적 그라운딩·신뢰도 점수) | https://docs.aws.amazon.com/bedrock/latest/userguide/bda.html |
| `AGENTOPS04-BP02` 표준 프로토콜(MCP·A2A) · Cedar 트래픽 시점 평가 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp02.html |
| `AGENTOPS04-BP03` 자동 차단 임계 · 도구별 지표 · 복합 알람 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp03.html |
| `AGENTSEC04-BP02` 위험 등급 승인 · **분류기 비신뢰 LLM 금지** · `.waitForTaskToken` | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec04-bp02.html |
| `AGENTSEC06-BP02` 두 오케스트레이션 · catch→quarantine · EventBridge | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec06-bp02.html |
| `AGENTPERF02-BP01` perceive-reason-act · 반복 KPI | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf02-bp01.html |
| `AGENTPERF06-BP03` 메타 도구 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf06-bp03.html |
| `AGENTCOST01-BP01` 종료 조건 셋 · 반성 패턴 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentcost01-bp01.html |
| `AGENTREL05-BP01` 모듈형 추론 단계 | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentrel05-bp01.html |
| **Amazon ECS MCP server**(Kiro 언급 · 완전관리형) | https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-mcp-introduction.html |
| AWS 편집 페이지 — Agent Squad를 `AWS Labs framework`로 적는 유일한 AWS 쪽 근거 | https://aws.amazon.com/smart-business/resources-for-smb/ai-agent-framework/ |
| Strands Agents 제품 문서 | https://strandsagents.com/latest/ |
| ⚠️ **블로그**(문서 아님) — MCP 서버 호스팅 세 경로 | https://aws.amazon.com/blogs/containers/deploying-model-context-protocol-mcp-servers-on-amazon-ecs/ |

## 15. 측정 방법과 함정

- 슬러그는 **추정하지 않고 가이드 TOC(`toc-contents.json`)에서 뽑았다** —
  AgentCore 개발자 안내서 **598항목** · Bedrock 사용자 안내서 **1,147항목** ·
  Agentic AI Lens **212항목**.
  ⚠️ 그 JSON은 **`"href" : "..."`처럼 콜론 앞에 공백**이 있다 — `"href":`로 세면 **0건**이고
  「TOC가 비었다」로 읽힌다(실측: 공백 포함 **598** vs 미포함 **0**). 95가 적은 함정이 재현됐다.
- **세 갈래 신호를 대조군으로 재현했다**:
  ① 있는 가이드의 없는 슬러그 → **`200 r=1`**(그 가이드 인덱스로, AgentCore는 2,208바이트)
  ② 없는 가이드 접두사 → **진짜 `404 r=0`**
  ③ `aws.amazon.com`의 없는 경로 → **`404 r=0`**(⚠️ 본문이 **299KB 오류 페이지**다 —
  **크기로 판정하면 「정상 페이지」로 잘못 읽는다**).
- 「없다」는 **알려진 양성 대조군을 통과한 뒤에만** 적었다 —
  AgentCore TOC `squad` **0건** ↔ 같은 파일 `Strands Agents` **2건** /
  Bedrock TOC `prompt flow` **0건** ↔ `flow` 포함 **57건**.
- ⚠️ **GitHub 리다이렉트는 조직 이전을 보여 주지만 아카이브 여부는 아니다**
  (`archived`·`public archive` 문구 **0건**). 그리고 **GitHub는 공식 문서가 아니다** —
  §2-3의 결론은 「문서의 부재」까지다.
- ⚠️ **블로그는 AWS가 발행하지만 문서가 아니다** — 블로그에만 있는 사실(ECS 서열 · `ReAct`
  낱말 · Step Functions 에이전틱 단계 발표)은 **묻지 않는 쪽**으로 분류하고, 같은 사실의
  docs-proper 대응물이 있으면 그쪽을 썼다(`InvokeHarness` 상태는 `harness.html`에 있다).
- ⭐ **보조 신호**: 이 세션의 AWS 공식 문서 MCP 도구가 **`strands_docs` 토픽**을 두고
  **`strandsagents.com/latest/documentation/docs/`를 허용 목록**에 넣는다 — Strands 실재의
  두 번째 신호였다. 다만 **본문 사실의 출처로는 쓰지 않았다**(도구 설명은 공식 문서가 아니다).
- 큰 페이지(Classic 17KB · Runtime 23KB · 의미 검색 10KB)는 **TOC 오프셋으로 필요한 절만** 읽었다.
