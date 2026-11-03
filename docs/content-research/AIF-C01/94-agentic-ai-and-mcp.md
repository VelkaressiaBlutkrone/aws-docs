---
생성: 2026-11-03
목적: AIF-C01 v1.1 신규 「에이전틱 AI」 계열 목표의 공식 근거 수집
대상 목표: 1.1.1 · 1.1.2 · 1.2.4 · 2.1.6 · 2.3.1 · 3.1.6 · 5.1.1
---

# 94 — 에이전틱 AI와 MCP (AIF-C01)

## 1. 왜 이 노트가 필요한가

공식 가이드 v1.1(2026-04-30)은 목표 2.1.6을 **신설**해 "기본 에이전트 AI 개념 (예: 복잡한 AI 애플리케이션을 위한 다중 에이전트 시스템 패턴, 모델 컨텍스트 프로토콜 (MCP) 및 에이전트를 외부 시스템에 연결하는 역할, 다중 에이전트 통신 패턴, 메모리 관리, 도구 사용, 워크플로 오케스트레이션)을 정의"하라고 요구한다. 같은 개정에서 목표 1.1.1·1.1.2의 기본 용어에 **에이전틱 AI**가 들어가 "AI, ML, GenAI, 딥 러닝, 에이전틱 AI 간의 유사점과 차이점"이 직접 출제 대상이 됐고, 1.2.4의 적용 사례에 **지식 기반·에이전틱 AI**가, 2.3.1의 GenAI 개발 서비스 예시에 **Strands Agents · Amazon Bedrock AgentCore**가 추가됐으며, 5.1.1의 보안 서비스 예시에 **Amazon Bedrock AgentCore Identity · AgentCore의 정책 · Amazon Bedrock Guardrails**가 추가됐다.

반대 방향의 변화도 하나 있다. 목표 3.1.6은 v1.0의 "Amazon Bedrock Agent, 에이전틱 AI, 모델 컨텍스트 프로토콜" 예시가 **삭제**되고 "AI 에이전트의 역할을 정의하고 AI 에이전트의 비즈니스 애플리케이션을 설명"이라는 서비스 중립 문구로 바뀌었다. 즉 **도메인 3은 서비스 이름을 묻는 자리에서 빠졌고**, 서비스 이름은 도메인 2(2.1.6·2.3.1)와 도메인 5(5.1.1)로 옮겨 붙었다. 아래 §4가 이 이동을 출제 각도로 풀어 둔다.

시험 자체는 Foundational 등급이고 90분·65문항·100 USD이며 한국어로 제공된다([AWS Certified AI Practitioner](https://aws.amazon.com/certification/certified-ai-practitioner/), 조회 2026-11-03).

## 2. 핵심 개념 (한국어 표)

| 개념 | 공식 정의/설명 | 출처 (조회 2026-11-03) |
| --- | --- | --- |
| 에이전틱 AI | "Agentic AI is an autonomous AI system that can act independently to achieve pre-determined goals." 전통 소프트웨어는 사전 정의된 규칙을 따르고, 전통 AI도 프롬프트와 단계별 안내를 요구하지만 에이전틱 AI는 **선제적(proactive)**이다. "'Agentic' indicates agency"— 즉 독립적으로, 그러나 목표 지향적으로 행동하는 능력. | [What is Agentic AI?](https://aws.amazon.com/what-is/agentic-ai/) |
| AI 에이전트 | "AI agents are autonomous entities that are capable of perceiving their environment, reasoning, and taking actions to achieve defined goals." GenAI에서 에이전트 시스템의 핵심은 보통 LLM이고, 여기에 **검색(retrieval)·도구(tools)·메모리(memory)**가 덧붙는다. | [Well-Architected Generative AI Lens — Agentic AI](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/agentic-ai.html) |
| 에이전시(agency)의 정도 | "Agentic systems can have varying degrees of agency, ranging from making narrowly scoped actions to autonomously orchestrating themselves." 설계 원칙은 "only increase the agency of the system when the task complexity requires it". | 같은 Lens 페이지 |
| 동작 4단계 | Perceive → Reason → Act → Learn. 공식 페이지가 이 네 단계를 명시적 제목으로 나눠 적는다. | [What is Agentic AI?](https://aws.amazon.com/what-is/agentic-ai/) |
| 도구 사용 (tool use) | "In Amazon Bedrock, the model doesn't directly call the tool." 모델은 도구가 필요한 시점을 **결정**하고, 실행은 애플리케이션 코드(또는 server-side 모드에서는 Amazon Bedrock 자신)가 한다. | [Use a tool to complete an Amazon Bedrock model response](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html) |
| 메모리 | AgentCore Memory는 에이전틱 AI의 근본 문제인 **무상태성(statelessness)**을 다룬다. 단기 = 한 세션 안의 턴 단위 맥락, 장기 = 여러 세션에 걸친 선호·사실·요약. | [Add memory to your AgentCore agent](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory.html) |
| 오케스트레이션 | "Workflow orchestration coordinates these multi-agent interactions through patterns like supervisor-worker hierarchies, peer-to-peer collaboration, and pipeline-based task decomposition." | [Agentic AI Lens — AGENTPERF05](https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05.html) |
| MCP (Model Context Protocol) | "MCP provides a communication layer that enables agents to interact with external data and services and **can also be used to enable agents to interact with other agents**." Streamable HTTP 전송은 무상태 요청/응답과 영속 ID 기반 상태 세션을 모두 지원한다. | [Getting started with MCP](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-mcp.html) |
| A2A (Agent2Agent) | "The Agent2Agent (A2A) protocol enables decentralized collaboration between agents through a shared semantic layer." 중앙 오케스트레이터를 거치지 않고 서로를 발견·협상한다. "Each agent publishes a capability manifest." | [Getting started with A2A](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-a2-a.html) |
| 다중 에이전트 구조(수평/수직) | 수평(horizontal): "every AI agent has the same level of technical proficiency and complexity"— 측면 협업. 수직(vertical): "a hierarchical structure in which lower-level AI agents have 'easier' tasks compared to the higher ones". | [What is Agentic AI?](https://aws.amazon.com/what-is/agentic-ai/) |
| 지식 기반 (목표 1.2.4) | Amazon Bedrock Knowledge Bases는 RAG를 구현한다. 유형은 **Managed Knowledge Base**, **Customer-managed(비정형)**, **Customer-managed(정형, Amazon Redshift)** 세 가지다. | [Amazon Bedrock Knowledge Bases](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html) |

## 3. 서비스별 사실

### 3.1 Amazon Bedrock Agents (현재 **Amazon Bedrock Agents Classic**)

**⚠️ 이 노트에서 가장 중요한 실측 결과다.** 공식 문서의 첫 문장이 이렇게 적는다:

> "Amazon Bedrock Agents (launched November 2023) is now Amazon Bedrock Agents Classic and will no longer be open to new customers starting on July 30, 2026."
> — [Amazon Bedrock Agents Classic maintenance mode](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html), 조회 2026-11-03

같은 페이지가 범위를 좁혀 둔다: "Amazon Bedrock continues to be fully supported. Only the Amazon Bedrock Agents Classic service is no longer open to new customers as of July 30, 2026. Your existing Amazon Bedrock models, Knowledge Bases, and Guardrails are not affected." 기존 고객은 그대로 쓸 수 있고, 서비스는 **유지 보수 모드(maintenance mode)**다. `agents-how.html`·API Reference `Welcome.html`에도 같은 주의 상자가 붙어 있다.

**무엇인가 / 구성요소** — 빌드 시점의 에이전트는 **Foundation model**(입력 해석·응답 생성), **Instructions**(무엇을 하도록 설계됐는지), 그리고 **Action groups**(OpenAPI 스키마 또는 function detail 스키마로 파라미터를 정의하고 선택적으로 Lambda가 실행) 또는 **Knowledge bases**(응답 보강) 중 **최소 하나**, 거기에 **Prompt templates**(기본 4개 — pre-processing · orchestration · knowledge base response generation · post-processing, 단계별 수정·끄기 가능)로 이뤄진다([How Amazon Bedrock Agents works](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-how.html)).

**다중 에이전트 협업** — "you can quickly designate an Amazon Bedrock Agent as the supervisor and then associate one or more collaborator agents with the supervisor. You can use this **hierarchical collaboration model**"([Use multi-agent collaboration](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html)). 콘솔 설정은 두 가지다: 감독자가 응답을 조율하는 **Supervisor**, 적절한 협업자에게 라우팅해 그쪽이 최종 응답을 보내는 **Supervisor with routing**([Create multi-agent collaboration](https://docs.aws.amazon.com/bedrock/latest/userguide/create-multi-agent-collaboration.html)).

**경계** — maintenance mode 페이지의 비교 표가 Classic의 다중 에이전트 기능이 AgentCore에서 그대로 재현되지 않는다고 적는다: "Limited. The supervisor pattern is possible by exposing agents as MCP tools (agent-as-tool). **Routing mode multi-agent is not straightforward today.** Full multi-agent collaboration requires custom framework code." 마이그레이션 경로는 ① **managed harness in AgentCore(권장)**, ② **code-defined agents on AgentCore**(Strands·LangChain·OpenAI Agents SDK·Claude Agent SDK 등 임의 프레임워크) 두 갈래다.

### 3.2 Amazon Bedrock AgentCore

**무엇인가** — "an agentic platform for building, deploying, and operating highly effective agents securely at scale using any framework and foundation model"([Overview](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html)). 모듈형이라 "work together or independently"이며 CrewAI·LangGraph·LlamaIndex·Strands Agents 등 오픈소스 프레임워크와 Bedrock 내외의 임의 FM에서 쓸 수 있다. 지원 프로토콜은 **MCP와 A2A** 두 개다("A2A support is currently available in AgentCore Runtime, with broader A2A support across other AgentCore services coming soon" — [AgentCore FAQs](https://aws.amazon.com/bedrock/agentcore/faqs/)).

**⚠️ 구성요소는 더 이상 6~7개가 아니다.** devguide의 "Core services" 표가 **13개**를 싣는다(조회 2026-11-03): Harness · Runtime · Memory · Gateway · Identity · Code Interpreter · Browser · Observability · Payments · Evaluations · Optimization · Policy · Registry. 시험 범위로 의미 있는 것만 정리한다.

**Runtime** — "a secure, serverless runtime environment purpose-built for deploying and scaling dynamic AI agents and tools." 세션은 전용 microVM에서 돌며 CPU·메모리·파일시스템이 완전히 분리되고, "Can persist for up to 8 hours of total runtime"이다([runtime-how-it-works](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html)). 종료 조건은 비활성 15분, 최대 수명 8시간, 비정상 판정. 종료 후에는 "the entire microVM is terminated and memory is sanitized"이고, "Session state is ephemeral and should not be used for long-term durability (use AgentCore Memory for context durability)"라고 못박는다. 두 값은 각각 `idleRuntimeSessionTimeout`·`maxLifetime`으로 조정 가능하다([Quotas](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/bedrock-agentcore-limits.html)). **컴퓨팅 유형에 따라 상한이 다르다**: "Sessions last up to 8 hours for each lifecycle on microVMs, or **up to 14 days on Instances**"([runtime-sessions](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-sessions.html)).

**Memory** — 단기는 "turn-by-turn interactions within a single session", 장기는 "automatically extracts and stores key insights from conversations across multiple sessions"다([memory](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory.html)). 장기 메모리는 **memory strategy**가 있어야 생긴다: "If no strategies are specified, long-term memory records will not be extracted for that memory"([memory-strategies](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html)). 전략 분류는 **built-in / built-in overrides / self-managed** 셋이고, 추출 유형은 "semantic, summarization, user preference, episodic, or custom"으로 열거된다([harness-memory](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-memory.html)). 이벤트는 `actorId` + `sessionId`로 범위가 갈려 행위자별로 분리된다.

**Gateway** — "a fully managed AI gateway that provides a single, secure entry point for agentic traffic"([gateway](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html)). API·Lambda·기존 서비스를 **MCP 호환 도구로 변환**하고, 입력 유형으로 **OpenAPI · Smithy · Lambda**를 지원하며, "is the only solution that provides both comprehensive ingress authentication and egress authentication in a fully managed service"라고 적는다. 도구가 많아지면 **Semantic Tool Selection**이 "allowing agents to use thousands of tools while minimizing prompt size and reducing latency"; 실제 호출 이름은 `x_amz_bedrock_agentcore_search`다([semantic search](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using-mcp-semantic-search.html)). MCP 규격 버전 **4종**(2026-07-28 · 2025-11-25 · 2025-06-18 · 2025-03-26)을 지원하고 `tools/list`·`tools/call` 등 표준 MCP 연산을 노출한다([gateway-using](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using.html) — Foundational 시험에 버전 문자열이 나올 자리는 아니다).

**Identity** (목표 5.1.1) — "an identity and credential management service designed specifically for AI agents and automated workloads"이며 "Agent identities are implemented as **workload identities**"다([identity](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/identity.html)). 축이 둘이다: **인바운드 인증**은 호출자가 AWS IAM 또는 외부 IdP의 **JWT**로 에이전트에 인증하는 쪽, **아웃바운드 인증**은 에이전트가 하류 서비스에 쓸 자격 증명을 관리하는 쪽([콘솔 도움말](https://docs.aws.amazon.com/help-panel/bedrock-agentcore/latest/console/hp-identity.html)). **토큰 볼트**가 OAuth 2.0 액세스·리프레시 토큰, API 키, OAuth 클라이언트 시크릿을 저장하고 "When the user token expires, AgentCore Identity uses the refresh token to obtain a new access token, or triggers a new authorization prompt"([FAQs](https://aws.amazon.com/bedrock/agentcore/faqs/)). 호환 IdP로 Amazon Cognito·Okta·Microsoft Entra ID·Auth0 등이 열거된다.

**Policy** (목표 5.1.1의 "AgentCore의 정책") — "provides real-time, deterministic control over agent interactions with enterprise tools through AgentCore Gateway"([policy](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html)). 집행 지점이 **Gateway**라는 것이 핵심이다: "Every agent action through Amazon Bedrock AgentCore Gateway is intercepted and evaluated at the boundary **outside of agent's code**." 언어는 **둘**이다 — **Cedar**("an open source language for writing and enforcing authorization policies")와 **Dogwood**("an open-source policy language for session-aware authorization... Dogwood **extends the authorization model of Cedar**", [policy-temporal](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-temporal.html)). 평가 모델은 `permit`/`forbid`에 **forbid-wins** 의미론이다: "Multiple policies can apply to a single request, with forbid-wins semantics"([API_Policy](https://docs.aws.amazon.com/bedrock-agentcore-control/latest/APIReference/API_Policy.html)). **자연어로 작성**할 수도 있고, 그 경우 자동 추론이 "overly permissive, overly restrictive, or contain conditions that can never be satisfied"인 정책을 집행 전에 잡아낸다. 생성 산출물은 7일 후 자동 삭제되며 운영 투입 전 **log-only mode** 검증을 권고한다([StartPolicyGeneration](https://docs.aws.amazon.com/bedrock-agentcore-control/latest/APIReference/API_StartPolicyGeneration.html)).

**Guardrails와의 접점** — Dogwood 정책은 "information providers, such as Guardrails, that emit a signal at evaluation time — such as a content-safety or prompt-attack score"를 조회해 판단할 수 있다(policy.html). 즉 5.1.1에 Guardrails와 AgentCore 정책이 함께 들어간 것은 우연이 아니다.

**Amazon Bedrock Guardrails** (목표 5.1.1) — 안전장치 6종이다: **Content filters**(Hate, Insults, Sexual, Violence, Misconduct, Prompt Attack), **Denied topics**, **Word filters**, **Sensitive information filters**(PII·커스텀 정규식), **Contextual grounding checks**(환각 탐지), **Automated Reasoning checks**("validate the accuracy of foundation model responses against a set of logical rules"). FM 호출 없이 **`ApplyGuardrail` API**만으로도 평가할 수 있다([guardrails](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html)).

### 3.3 Strands Agents

**무엇인가** — "The Strands Agents SDK empowers developers to quickly build, manage, evaluate and deploy AI-powered agents." 공식 Quickstart가 성격을 절 제목으로 못박는다: **"A library, not a platform."** 본문은 "Strands runs inside your own process... there is no hosted control plane, scheduler, or database to stand up first"다([Get started](https://strandsagents.com/docs/user-guide/sdk/quickstart/overview/), 조회 2026-11-03 — `https://strandsagents.com/latest/documentation/docs/`에서 **리다이렉트**된 최종 URL).

**모델 종속성** — "Any model provider works. Amazon Bedrock is the default, and swapping in Anthropic, OpenAI, Gemini, or Ollama is a one-line change, so **an AWS account is only required if you keep the default**." Python·TypeScript 두 언어를 지원한다.

**접근 방식** — **model-driven approach**: 모든 시나리오를 미리 코딩하는 대신 "we let modern large language models drive their own behavior, make intelligent decisions about tool usage, and adapt dynamically"([블로그](https://strandsagents.com/blog/strands-agents-model-driven-approach/)). 오픈소스 공개는 **2025년 5월**이다([Introducing Strands Labs](https://strandsagents.com/blog/introducing-strands-labs/)).

**다중 에이전트 패턴** — 공식 문서가 다섯 가지를 싣는다: **Agents as tools**(오케스트레이터가 전문 에이전트를 도구로 호출) · **Agent-to-Agent (A2A)**(별도 서비스로 돌아가는 에이전트 연결) · **Swarm**("autonomously hand off tasks to one another") · **Graph**("a flowchart of agents where an LLM decision at each node picks the path, with branching and loops") · **Workflow**("a fixed task graph (DAG) as a single, reusable tool"). 경계가 명시돼 있다: "**Graph and Swarm are built-in SDK orchestrators. Workflow is a pattern you implement in code** by chaining agents together"([Coordinate multiple agents](https://strandsagents.com/docs/user-guide/sdk/multi-agent/multi-agent-patterns/)). 세 패턴을 가르는 축도 적혀 있다 — "the most difference you should consider among those patterns is **how the path of execution is determined**."

**AgentCore와의 관계** — "Strands Agents enables developers to leverage modern models' capabilities for planning, reasoning, and tool use, while seamlessly integrating with AgentCore services through a simple SDK"([AgentCore FAQs](https://aws.amazon.com/bedrock/agentcore/faqs/)). 즉 **경쟁이 아니라 층이 다르다**: Strands는 에이전트 코드, AgentCore는 그 코드를 운영하는 인프라·통제면이다.

### 3.4 MCP와 AWS

**무엇인가** — AWS 문서가 MCP를 "an open standard defining a uniform interface through which AI agents discover, connect to, and invoke capabilities across external systems"으로 설명하고, 효과를 "implement the connector once, and any MCP-compatible agent can discover and invoke it immediately"로 적는다([Integration as Intelligence](https://aws.amazon.com/blogs/contact-center/integration-as-intelligence-amazon-connect-customer-integrates-with-salesforce-via-mcp/)). 에이전트는 MCP 서버에 **capability manifest**(도구 목록·입력 스키마·기대 출력)를 질의한 뒤 호출한다.

**AWS의 역할** — "AWS actively supports the Model Context Protocol (MCP) through contributions to the protocol's development and implementation"이며 LangGraph·CrewAI·LlamaIndex와 협력한다([Getting started with MCP](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-mcp.html)). AWS에서 MCP가 구체화되는 자리는 **AgentCore Gateway**(기존 API·Lambda → MCP 도구)와 **AgentCore Runtime**(MCP·A2A로 에이전트 호스팅)이고, Well-Architected Agentic AI Lens도 "Adopt MCP as the standard tool integration protocol and use Amazon Bedrock AgentCore Gateway to expose tools as MCP-compatible endpoints"를 권고한다([AGENTPERF06-BP01](https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf06-bp01.html)).

**MCP ↔ A2A 경계** — 둘은 대체재가 아니다. AWS 블로그가 역사와 용도를 함께 적는다: "MCP was initially created to connect agents to tools but can also be used to connect agents to agents. A2A was created to connect agents to agents and can also be used in conjunction with MCP"([Open Protocols for Agent Interoperability Part 4](https://aws.amazon.com/blogs/opensource/open-protocols-for-agent-interoperability-part-4-inter-agent-communication-on-a2a/)). A2A는 JSON-RPC 2.0 over HTTP이고 각 에이전트가 `/.well-known/agent-card.json`에 **Agent Card**를 게시한다([A2A protocol contract](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-a2a-protocol-contract.html)).

**도구 사용의 세 가지 모드** (Bedrock 수준) — [tool-use](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html)가 표로 적는다: **Client-side**(애플리케이션 코드가 실행; Responses·Chat Completions·Converse·InvokeModel), **Server-side**("Amazon Bedrock itself. You register a Lambda function or **AgentCore Gateway**, and Amazon Bedrock invokes the tool on the model's behalf" — 현재 Responses API), **Anthropic Claude tool use**(`computer_*`·`bash_*`·`text_editor_*`·`memory_*`).

## 4. 시험에서 묻는 방식

Foundational 등급이므로 "구축"이 아니라 **구분·선택·설명**을 묻는다. 목표 문구에 비춘 출제 각도:

1. **용어 가르기 (1.1.1·1.1.2)** — "AI / ML / 딥 러닝 / 생성형 AI / 에이전틱 AI" 중 하나를 고르게 하고, 정답을 가르는 단서로 **"목표를 받아 스스로 여러 단계를 실행한다"**(에이전틱)와 **"프롬프트에 응답해 콘텐츠를 만든다"**(생성형)를 대비시킨다. 공식 정의의 대조문("traditional artificial intelligence also requires prompting and step-by-step guidance")이 그대로 보기 재료가 된다.
2. **에이전트의 구성요소 (2.1.6)** — "LLM + 검색 + 도구 + 메모리"라는 Lens의 구성을 주고 빠진 요소를 짚게 하거나, "에이전트에 상태를 주는 것"으로 **메모리**를 고르게 한다.
3. **단기 vs 장기 메모리 (2.1.6)** — "같은 대화에서 '내일은?'을 이해한다"(단기) vs "다음 예약에서 창가 좌석을 먼저 제안한다"(장기). 공식 문서의 두 예시가 거의 그대로 쓸 수 있다.
4. **MCP의 역할 (2.1.6)** — "에이전트를 외부 시스템에 연결하는 표준 인터페이스"를 고르게 한다. 오답 후보로 "모델을 미세 조정하는 방식", "임베딩 생성 규격", "프롬프트 템플릿 언어"가 자연스럽다.
5. **다중 에이전트 통신 패턴 (2.1.6)** — 수평(동급·측면 협업) vs 수직(계층·상위가 추론) 구분, supervisor-worker vs swarm vs pipeline 중 과제 성격에 맞는 것 고르기.
6. **서비스 역할 매칭 (2.3.1)** — "오픈소스 SDK로 에이전트를 코드로 만든다" → Strands Agents, "그 에이전트를 세션 격리된 서버리스 환경에서 운영한다" → AgentCore(Runtime).
7. **보안 서비스 매칭 (5.1.1)** — "에이전트에 고유 ID를 주고 하류 서비스용 토큰을 관리한다" → AgentCore Identity, "에이전트가 호출할 수 있는 도구와 조건을 Gateway에서 결정적으로 통제한다" → AgentCore의 정책, "유해 콘텐츠·PII·환각을 필터링한다" → Bedrock Guardrails. **세 개가 각자 다른 층을 막는다**는 점이 갈림길이다.
8. **비즈니스 적용 (1.2.4·3.1.6)** — 3.1.6이 서비스 중립 문구로 바뀐 만큼, 서비스 이름 없이 "AI 에이전트를 쓰면 좋은 업무"를 고르는 형태가 유력하다. 공식 사용 사례는 연구·개발 지원, 코드 전환(.NET 현대화·COBOL 분해), 사고 대응 자동화, 고객 서비스 자동화 네 가지다.

## 5. 흔한 함정·혼동 짝

| 혼동 짝 | 공식 문서가 적는 구분점 | 근거 |
| --- | --- | --- |
| **Bedrock Agents ↔ Bedrock Agents Classic** | 같은 서비스다. 2023-11 출시된 Amazon Bedrock Agents가 **개명**됐고 2026-07-30부터 **신규 고객에게 열리지 않는다**. 단 범위는 그 서비스 하나다 — "Amazon Bedrock continues to be fully supported... Bedrock 모델·Knowledge Bases·Guardrails는 영향 없음". | [maintenance mode](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html) |
| **Bedrock Agents Classic ↔ AgentCore** | Classic은 **구성(config) 기반 단일 관리형 에이전트**(action groups·prompt templates·KB 연결). AgentCore는 **모듈형 플랫폼**이고 "work together or independently", 임의 프레임워크·임의 FM. Classic의 다중 에이전트 라우팅은 AgentCore에서 "not straightforward today". | 같은 페이지 비교 표 |
| **AgentCore Identity ↔ AWS IAM** | Identity는 **에이전트/워크로드 전용**이고 **외부 IdP의 JWT와 서드파티 OAuth 토큰**까지 다룬다(인바운드는 IAM 또는 JWT, 아웃바운드는 토큰 볼트). IAM 하나로 대체되지 않는다. | [identity](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/identity.html) · [hp-identity](https://docs.aws.amazon.com/help-panel/bedrock-agentcore/latest/console/hp-identity.html) |
| **AgentCore의 정책 ↔ IAM 정책 ↔ Guardrails** | 정책은 **Gateway를 지나는 도구 호출**을 Cedar/Dogwood로 가로채 결정적으로 허용·거부한다("outside of agent's code"). Guardrails는 **콘텐츠**(유해성·PII·환각)를 본다. 둘은 겹치지 않고, 오히려 Guardrails가 Dogwood 정책의 **information provider**로 쓰인다. | [policy](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html) · [guardrails](https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html) |
| **Cedar ↔ Dogwood** | 둘 다 쓴다. Dogwood는 Cedar를 **확장**해 세션 인식(temporal) 조건과 information provider를 더한 것이고, "Your existing point-in-time policies written in Dogwood or Cedar continue to work without changes." Cedar만 적는 자료는 낡았다. | [policy-temporal](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-temporal.html) |
| **Strands Agents ↔ 관리형 서비스** | Strands는 **오픈소스 SDK(라이브러리)**다. "A library, not a platform... there is no hosted control plane, scheduler, or database to stand up first." Amazon Bedrock은 **기본값일 뿐**이고 "an AWS account is only required if you keep the default". | [Get started](https://strandsagents.com/docs/user-guide/sdk/quickstart/overview/) |
| **MCP ↔ 에이전트 프레임워크** | MCP는 **프로토콜**이고 에이전트 로직을 담지 않는다. 프레임워크(Strands·LangGraph·CrewAI)는 에이전트 루프를 구현하고, MCP는 그 루프가 외부 도구·다른 에이전트에 닿는 **통신 계층**이다. | [Getting started with MCP](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-mcp.html) |
| **MCP ↔ A2A** | MCP는 도구 연결용으로 만들어졌으나 에이전트 간에도 쓸 수 있고, A2A는 에이전트 간 연결용으로 만들어졌으나 MCP와 함께 쓸 수 있다. "AWS supports both protocols." **"MCP는 도구용, A2A는 에이전트용"이라는 단정은 공식 서술보다 좁다.** | [Part 4 블로그](https://aws.amazon.com/blogs/opensource/open-protocols-for-agent-interoperability-part-4-inter-agent-communication-on-a2a/) |
| **도구(tool) ↔ 하위 에이전트(sub-agent)** | 공식 기준이 있다. 하위 에이전트는 "its own reasoning... its own context or memory scope, multi-step tool orchestration... a different model or prompt, or independent failure isolation"이 필요할 때. 도구는 "deterministic, stateless, single-step, and fast (under 2-3 seconds)"일 때. 애매하면 "start with a tool and promote to a sub-agent". 그리고 **에이전시는 많을수록 좋은 것이 아니다** — "only increase the agency of the system when the task complexity requires it"이고, 결정론적 위임·장기 워크플로에는 "AWS Step Functions remains a strong alternative". | [AGENTPERF05-BP02](https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html) · [Gen AI Lens](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/agentic-ai.html) |
| **에이전트 세션 ↔ 영속 메모리** | Runtime 세션은 **임시(ephemeral)**다. "Session state is ephemeral and should not be used for long-term durability (use AgentCore Memory for context durability)." 세션 종료 시 microVM이 폐기되고 메모리가 소독된다. 그리고 AgentCore Memory 쪽도 **memory strategy를 지정하지 않으면 장기 메모리 레코드가 추출되지 않는다**. | [runtime-how-it-works](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html) · [memory-strategies](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html) |
| **"모델이 도구를 직접 실행한다"** | Bedrock에서는 아니다("the model doesn't directly call the tool"). 다만 **server-side tool use** 모드에서는 **Amazon Bedrock이** Lambda나 AgentCore Gateway를 대신 호출한다 — "애플리케이션이 항상 실행한다"도 정확하지 않다. | [tool-use](https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html) |
| **AgentCore Gateway = MCP 도구 게이트웨이** | 범위가 더 넓다. "Rather than serving only as an MCP tool gateway, Gateway routes and secures any agentic traffic through one endpoint" — A2A 패스스루 타깃과 **모델 기반 추론 라우팅**까지 포함한다. | [gateway](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html) |

## 6. 자가 점검 후보

**Q1.** 생성형 AI 애플리케이션과 에이전틱 AI 시스템을 가르는 공식 기준은 무엇인가?
**정답:** 에이전틱 AI는 사전에 정해진 목표를 달성하기 위해 **독립적으로 행동**하며, 지속적인 사람의 감독 없이 복잡한 과제를 수행한다(선제적). 생성형 AI는 프롬프트에 응답해 콘텐츠를 만드는 쪽이다.
**근거:** <https://aws.amazon.com/what-is/agentic-ai/>

**Q2.** 기존 REST API와 Lambda 함수를 MCP 호환 도구로 바꿔 에이전트에 제공하고, 인바운드·아웃바운드 인증을 함께 처리하는 AgentCore 구성요소는?
**정답:** **AgentCore Gateway**. (Runtime은 에이전트 호스팅, Memory는 맥락 유지, Identity는 자격 증명·ID 관리)
**근거:** <https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html>

**Q3.** AgentCore Memory에서 장기 메모리 레코드가 생성되기 위해 반드시 필요한 설정은?
**정답:** **memory strategy**. 전략을 지정하지 않으면 해당 메모리에서 장기 메모리 레코드가 추출되지 않는다.
**근거:** <https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html>

**Q4.** 에이전트가 Gateway를 통해 호출할 수 있는 도구와 그 조건을, 에이전트 코드 **바깥**에서 결정적으로 통제하는 AgentCore 기능은?
**정답:** **AgentCore의 정책(Policy in AgentCore)**. Cedar 또는 Dogwood로 작성하며 Gateway를 지나는 모든 요청을 가로채 평가한다.
**근거:** <https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html>

**Q5.** Strands Agents를 쓰려면 반드시 AWS 계정이 필요한가?
**정답:** 아니다. Amazon Bedrock이 **기본 모델 공급자**이므로 기본값을 유지할 때만 AWS 계정이 필요하고, 다른 공급자(Anthropic·OpenAI·Gemini·Ollama)로 한 줄 교체가 가능하다. Strands는 호스팅 컨트롤 플레인이 없는 **라이브러리**다.
**근거:** <https://strandsagents.com/docs/user-guide/sdk/quickstart/overview/>

## 7. 출처 목록

| 제목 | URL | 조회일 |
| --- | --- | --- |
| What Is Agentic AI? | https://aws.amazon.com/what-is/agentic-ai/ | 2026-11-03 |
| AWS Certified AI Practitioner | https://aws.amazon.com/certification/certified-ai-practitioner/ | 2026-11-03 |
| Well-Architected Generative AI Lens — Agentic AI | https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/agentic-ai.html | 2026-11-03 |
| Agentic AI Lens — AGENTPERF05 (오케스트레이션) | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05.html | 2026-11-03 |
| Agentic AI Lens — AGENTPERF05-BP02 (도구 vs 하위 에이전트) | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html | 2026-11-03 |
| Agentic AI Lens — AGENTPERF06-BP01 (도구 통합 전략) | https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf06-bp01.html | 2026-11-03 |
| Amazon Bedrock Agents Classic maintenance mode | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html | 2026-11-03 |
| How Amazon Bedrock Agents works | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-how.html | 2026-11-03 |
| Use multi-agent collaboration with Amazon Bedrock Agents | https://docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html | 2026-11-03 |
| Create multi-agent collaboration | https://docs.aws.amazon.com/bedrock/latest/userguide/create-multi-agent-collaboration.html | 2026-11-03 |
| Amazon Bedrock AgentCore — Overview | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html | 2026-11-03 |
| AgentCore Runtime — microVMs / how it works | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html | 2026-11-03 |
| AgentCore Runtime — Use isolated sessions for agents | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-sessions.html | 2026-11-03 |
| Quotas for Amazon Bedrock AgentCore | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/bedrock-agentcore-limits.html | 2026-11-03 |
| AgentCore Runtime — A2A protocol contract | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-a2a-protocol-contract.html | 2026-11-03 |
| Add memory to your Amazon Bedrock AgentCore agent | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory.html | 2026-11-03 |
| AgentCore Memory — Memory strategies | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html | 2026-11-03 |
| AgentCore Harness — Memory (전략 유형 열거) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness-memory.html | 2026-11-03 |
| Get started with AgentCore Memory | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-get-started.html | 2026-11-03 |
| AgentCore Gateway | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html | 2026-11-03 |
| Use an AgentCore gateway (MCP 버전·연산) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using.html | 2026-11-03 |
| Search for tools with a natural language query | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using-mcp-semantic-search.html | 2026-11-03 |
| AgentCore Identity (devguide) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/identity.html | 2026-11-03 |
| AgentCore Identity (콘솔 도움말 — 인바운드/아웃바운드) | https://docs.aws.amazon.com/help-panel/bedrock-agentcore/latest/console/hp-identity.html | 2026-11-03 |
| Policy in Amazon Bedrock AgentCore | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html | 2026-11-03 |
| Temporal policies (Dogwood) | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-temporal.html | 2026-11-03 |
| Getting started with Policy in AgentCore | https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-getting-started.html | 2026-11-03 |
| API_Policy (forbid-wins) | https://docs.aws.amazon.com/bedrock-agentcore-control/latest/APIReference/API_Policy.html | 2026-11-03 |
| API_StartPolicyGeneration (7일 만료·log-only) | https://docs.aws.amazon.com/bedrock-agentcore-control/latest/APIReference/API_StartPolicyGeneration.html | 2026-11-03 |
| Amazon Bedrock AgentCore FAQs | https://aws.amazon.com/bedrock/agentcore/faqs/ | 2026-11-03 |
| Amazon Bedrock Guardrails | https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html | 2026-11-03 |
| Use a tool to complete an Amazon Bedrock model response | https://docs.aws.amazon.com/bedrock/latest/userguide/tool-use.html | 2026-11-03 |
| Amazon Bedrock Knowledge Bases | https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html | 2026-11-03 |
| Getting started with MCP (Prescriptive Guidance) | https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-mcp.html | 2026-11-03 |
| Getting started with A2A (Prescriptive Guidance) | https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/getting-started-with-a2-a.html | 2026-11-03 |
| Amazon Bedrock AgentCore (Prescriptive Guidance) | https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/amazon-bedrock-agent-core.html | 2026-11-03 |
| Protocol-based tools (Prescriptive Guidance) | https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/protocol-based-tools.html | 2026-11-03 |
| AWS SRA for AI (AgentCore 모듈 열거) | https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-generative-ai/gen-ai-sra.html | 2026-11-03 |
| Integration as Intelligence (MCP 설명) | https://aws.amazon.com/blogs/contact-center/integration-as-intelligence-amazon-connect-customer-integrates-with-salesforce-via-mcp/ | 2026-11-03 |
| Open Protocols for Agent Interoperability Part 4 (MCP↔A2A) | https://aws.amazon.com/blogs/opensource/open-protocols-for-agent-interoperability-part-4-inter-agent-communication-on-a2a/ | 2026-11-03 |
| Why Policy in AgentCore chose Cedar | https://aws.amazon.com/blogs/security/why-policy-in-amazon-bedrock-agentcore-chose-cedar-for-securing-agentic-workflows/ | 2026-11-03 |
| Securing AI agents with AgentCore Identity (토큰 볼트·Cognito) | https://aws.amazon.com/blogs/security/securing-ai-agents-with-amazon-bedrock-agentcore-identity/ | 2026-11-03 |
| Strands Agents — Get started ("A library, not a platform") | https://strandsagents.com/docs/user-guide/sdk/quickstart/overview/ | 2026-11-03 |
| Strands Agents — Coordinate multiple agents | https://strandsagents.com/docs/user-guide/sdk/multi-agent/multi-agent-patterns/ | 2026-11-03 |
| Strands Agents and the Model-Driven Approach (블로그) | https://strandsagents.com/blog/strands-agents-model-driven-approach/ | 2026-11-03 |
| Introducing Strands Labs (오픈소스 공개 시점) | https://strandsagents.com/blog/introducing-strands-labs/ | 2026-11-03 |

### 리다이렉트가 확인된 URL

- `https://strandsagents.com/latest/documentation/docs/` → **`https://strandsagents.com/docs/user-guide/sdk/quickstart/overview/`** (출처 표에는 최종 URL을 적었다. 옛 `/latest/documentation/` 경로를 인용하는 자료는 낡은 슬러그다.)
- `https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-getting-started.html` → **`.../what-is-bedrock-agentcore.html`** (존재하지 않는 슬러그를 추측한 결과다. 정본은 `memory-get-started.html` — `getting`이 아니라 `get`이다. AWS 문서는 없는 페이지에 404를 주지 않고 가이드 상위로 보내므로 리다이렉트 여부로만 판정할 수 있다.)

위 두 건을 제외하면 §7의 URL은 모두 리다이렉트 없이 그 페이지 본문을 반환했다. `https://aws.amazon.com/certification/certified-ai-practitioner/`는 리다이렉트 없이 200이었다 — DVA-C03 조사 노트가 남긴 "`certification/…`은 404이고 `aws-certification/…`이 정본"이라는 메모는 **자격증 상세 페이지에는 적용되지 않는다**(실측).

## 확인 필요

1. **AIF-C01 공식 시험 가이드 PDF 본문을 이 세션에서 직접 열지 못했다.** §1의 목표 원문 인용은 컨트롤러가 이미 실측해 지시문에 담아 준 공식 한국어 본문을 그대로 쓴 것이고, 이 노트에서 재검증하지 않았다. 가이드 PDF는 `d1.awsstatic.com` 하위에 있어 이 조사에 쓴 AWS 문서 도구의 허용 접두어(`docs.aws.amazon.com` · `aws.amazon.com` 등)에 들지 않는다. 목표 번호·배점·시험 시간을 문항에 쓰려면 가이드 PDF를 별도로 실측해야 한다.
2. **AIF-C01 v1.1에서 "에이전틱 AI"의 공식 한국어 역어가 무엇인지 확정하지 못했다.** 지시문이 인용한 목표 2.1.6 본문은 "기본 **에이전트 AI** 개념"으로 적고 1.1.1은 "**에이전틱 AI**"로 적어 가이드 안에서 표기가 갈린다(DVA-C03에서 도메인 1 이름이 한 페이지 안에서 두 가지로 적힌 것과 같은 계열). 학습문서 저작 시 어느 쪽을 정본으로 쓸지는 저작 결정 문서에서 정해야 하고, 그 판정 근거도 가이드 PDF 실측이다.
3. **"AgentCore의 정책" 공식 한국어 명칭을 확인하지 못했다.** 영문 정본은 "Policy in AgentCore"(서비스명 뒤가 아니라 앞에 Policy를 두지 않는 어순)이며, `AgentCore Policy`와 `Policy in AgentCore`가 공식 문서 안에서 혼용된다(devguide 제목은 "Policy in Amazon Bedrock AgentCore", SRA·FAQ·CDK는 "AgentCore Policy"). 한국어 문서 페이지를 찾지 못했다.
4. **AgentCore Memory 장기 메모리의 보관 기간 기본값을 공식 수치로 확정하지 못했다.** `memory-get-started.html`의 CLI 예시에 "Keep the default event retention of 30 days"가 나오지만 이는 **이벤트(단기) 보존**에 대한 튜토리얼 지문이고, 장기 메모리 레코드의 기본 보존 정책을 적는 페이지를 찾지 못했다. Foundational 시험에 수치가 나올 자리는 아니라고 보지만, 노트에 수치로 적지는 않았다.
5. **AgentCore의 리전 가용 개수를 본문에 쓰지 않았다.** FAQ가 "AgentCore is available in fifteen AWS Regions"로 시작하는 문장을 싣지만, 읽은 구간이 그 문장 중간에서 잘려 리전 목록까지 확인하지 못했고 이 값은 빠르게 변한다. 시험 관련성도 낮아 본문에서 제외했다.
6. **Amazon Bedrock Agents Classic의 "유지 보수 모드" 종료일(서비스 중단일)은 공식 문서에 없다.** 확인된 것은 "신규 고객에게 열리지 않는 날짜"가 2026-07-30이라는 것과 "Existing customers can continue to use the service as normal"뿐이다. 중단 예정일을 단정하는 서술은 쓰지 않았다.
