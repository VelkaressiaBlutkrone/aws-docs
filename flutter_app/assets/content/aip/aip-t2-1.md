---
examGuideTaskId: aip-t2-1
certCode: AIP-C01
domain: 2
domainName: 구현 및 통합
domainWeightPct: 26
title: 에이전틱 AI 솔루션과 도구 통합 (메모리와 상태·구조화된 추론·제어된 동작·모델 조정·인간 증강·도구 통합·MCP 서버)
coversTasks:
  - "2.1"
sources:
  - title: AgentCore harness — 선언형 오케스트레이션 계층
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html
  - title: AgentCore Runtime 동작 방식 — 세션과 microVM 격리
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html
  - title: AgentCore Runtime에 MCP 서버 배포
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-mcp.html
  - title: 상태 유지(stateful) MCP 기능
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/mcp-stateful-features.html
  - title: AgentCore Memory의 메모리 유형
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-types.html
  - title: AgentCore Memory 전략
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html
  - title: AgentCore Gateway 개요
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html
  - title: Gateway의 MCP 서버 타깃
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-target-MCPservers.html
  - title: Gateway의 MCP 의미 검색
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using-mcp-semantic-search.html
  - title: Gateway의 라우팅 규칙과 폴백
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rules-fallback.html
  - title: Gateway의 속도 제한
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rate-limits.html
  - title: Policy in AgentCore
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html
  - title: AgentCore의 지원 프레임워크와 계측
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html
  - title: Amazon Bedrock Agents Classic 유지 관리 모드
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html
  - title: Agents Classic의 다중 에이전트 협업
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html
  - title: Amazon Bedrock 지능형 프롬프트 라우팅
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html
  - title: AGENTPERF05-BP02 최적화된 다중 에이전트 협업 모델
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html
  - title: AGENTPERF02-BP01 추론 루프의 반복 제어
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf02-bp01.html
  - title: AGENTCOST01-BP01 종료 조건과 반성 패턴
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentcost01-bp01.html
  - title: AGENTREL05-BP01 모듈형 추론 단계
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentrel05-bp01.html
  - title: AGENTSEC04-BP02 인간 감독 경로
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec04-bp02.html
  - title: AGENTSEC06-BP02 오케스트레이션 보안 통제
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec06-bp02.html
  - title: AGENTOPS04-BP02 표준 프로토콜 기반 도구 통합
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp02.html
  - title: AGENTOPS04-BP03 도구 신뢰성과 자동 차단
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp03.html
lastVerified: 2026-11-14
---

# 에이전틱 AI 솔루션과 도구 통합 (메모리와 상태·구조화된 추론·제어된 동작·모델 조정·인간 증강·도구 통합·MCP 서버)

> **커버하는 공식 Task** — AIP-C01 · 도메인 2 「구현 및 통합」(26%) · **작업 2.1 에이전틱 AI 솔루션 및 도구 통합 구현** (`aip-t2-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 7개(2.1.1~2.1.7)를 모두 덮습니다. 이 작업이 도메인 2에서 가장 두껍고(기술 7개), 묻는 축은 **에이전트를 똑똑하게 만드는 법이 아니라 에이전트를 제어하고 도구에 안전하게 붙이는 법**입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 단기·장기 메모리를 구분하고 **전략이 없으면 장기 기억이 생기지 않는다**는 것을 안다
- [ ] 다중 에이전트 협업 모델 넷과 **도구 ↔ 하위 에이전트 결정 순서**를 안다
- [ ] 추론 루프를 **반복 상한·신뢰도 임계·토큰 예산**으로 끊을 수 있다
- [ ] 제어된 동작을 **정책 엔진·속도 제한·서킷 브레이커**로 가를 수 있다
- [ ] 모델 조정 경로 셋과 각자의 **결정적 제약**을 안다
- [ ] 인간 증강을 **위험 등급별 승인**으로 설계할 수 있다
- [ ] Gateway가 도구를 **MCP 호환으로 바꾸는** 방식과 동기화 요구를 안다
- [ ] MCP 서버를 올리는 **두 경로**와 상태성 요구를 안다

---

## 🎯 왜 중요한가

에이전트는 **모델이 아니라 루프**입니다. 모델을 한 번 부르는 GenAI 애플리케이션은 실패하면 오류 하나를 받지만, 에이전트는 **스스로 도구를 고르고 여러 번 부르며 상태를 쌓습니다.** 그래서 이 작업의 공식 기술 일곱 개 중 **셋이 「제어」**입니다 — 안전한 워크플로(2.1.3), 신뢰할 수 있는 도구 운영(2.1.6), 인간 증강(2.1.5).

시험이 묻는 것도 그쪽입니다. 「에이전트를 만드는 코드」가 아니라 **「폭주를 무엇으로 멈추는가」**, **「도구를 어디에 붙이는가」**, **「누가 승인하는가」**입니다. AWS의 공식 Agentic AI Lens가 그 판단 기준을 숫자까지 적어 둔 것이 이 작업의 근거입니다.

---

## ⚡ 시험 직전 요약

- **메모리는 둘** — 단기는 한 세션의 **원시 이벤트**, 장기는 여러 세션에 걸친 **구조화 레코드**(요약·사실·선호). ⚠️⚠️ **전략을 지정하지 않으면 장기 메모리 레코드가 추출되지 않는다.**
- ⚠️ **이벤트 메타데이터는 고객 관리 키로 암호화되지 않으므로 민감 콘텐츠를 담지 않는다.**
- Runtime 세션은 **세션마다 전용 microVM**이고 종료 조건 셋 — **비활성 15분 · 최대 수명 8시간 · 비정상 판정**. ⚠️⚠️ 종료되면 **메모리가 소거**되고 같은 세션 ID로 다시 요청해도 **이어지지 않는다**.
- ⚠️⚠️ **패턴을 고르기 전에 「도구냐 하위 에이전트냐」를 먼저 정한다** — 도구는 **결정적·스테이트리스·단일 단계·2~3초 미만**, 하위 에이전트는 **자기 추론·자기 컨텍스트·독립 실패 격리**가 필요할 때다.
- 협업 모델 넷 — **수퍼바이저-워커**(명확한 분해 + 중앙 품질 통제) · **파이프라인**(순차 흐름) · **피어 투 피어/블랙보드**(비동기 부분 해답 공유) · **스웜**(병렬 탐색, ⚠️ **수렴 기준과 토큰 예산 필수**).
- 종료 조건 셋은 **최대 반복 수 · 신뢰도 임계 · 세션당 토큰 예산**이고 ⚠️ **고정 반복 수를 신뢰도 임계 대신 쓰는 것이 안티패턴**이다.
- ⚠️⚠️ **실패한 호출을 같은 프롬프트·같은 모델로 재시도하는 것이 안티패턴**이다 — 의미를 바꿔 다시 묻거나 더 유능한 모델로 폴백한다.
- 제어 셋을 가른다 — **Policy**(도구 접근 **전에** 트래픽을 가로채 평가) · **속도 제한**(트래픽 시점의 리소스 경계) · **서킷 브레이커**(실패 중인 목적지를 건너뛴다, Gateway에서 **기본 ENABLED**).
- 모델 조정 셋 — **지능형 프롬프트 라우팅**(⚠️⚠️ **같은 모델 패밀리 안에서만** · 영어 최적화) · **Gateway 규칙·폴백**(⚠️ 스트리밍 시작 후 폴백 불가) · **harness의 공급자 전환**(세션 중간에도 컨텍스트 유지).
- MCP 서버 경로는 둘 — **Runtime 호스팅**(⚠️ `serverProtocol`을 `MCP`로 설정해야 한다) · **Gateway 타깃**(⚠️ 정의가 바뀌면 **동기화를 호출해야** 새 도구를 발견한다).

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **에이전트** | 모델이 도구를 골라 부르며 목표를 향해 반복하는 시스템 |
| **MCP** | 모델과 도구가 주고받는 표준 프로토콜. 도구를 모델에 붙이는 공통 계약 |
| **Gateway** | 도구·API·함수를 MCP 호환 도구로 바꿔 한 엔드포인트 뒤에 두는 계층 |
| **harness** | 모델·도구·스킬·지시를 **선언**하면 AgentCore가 실행 환경을 맡는 관리형 계층 |
| **메모리 전략** | 원시 이벤트에서 장기 기억 레코드를 **추출하는 방식**의 정의 |
| **서킷 브레이커** | 실패가 임계를 넘은 의존성으로 가는 호출을 **자동으로 끊는** 통제 |
| **agent-as-tool** | 에이전트를 다른 에이전트의 **도구로 노출**해 수퍼바이저 패턴을 만드는 방식 |

---

## 📖 핵심 개념

### 1) 메모리·상태 관리와 다중 에이전트 (기술 2.1.1) {#agentic}

> 🧠 원리: 자율 시스템에서 어려운 것은 추론이 아니라 **무엇을 기억하고 무엇을 잊는가**입니다. 그리고 에이전트를 여럿 두는 결정은 **그 전에** 「이건 도구면 되는 일인가」를 통과해야 합니다.

**메모리 두 층**(AgentCore Memory):

| | 단기 | 장기 |
|---|---|---|
| 담는 것 | **원시 상호 작용**(이벤트) | 추출된 **구조화 레코드** — 요약·사실·사용자 선호 |
| 범위 | **한 세션** | **여러 세션에 걸쳐 유지** |
| 다루는 법 | `CreateEvent`·`ListEvents`·`GetEvent`·`ListSessions` | **전략**이 자동으로 추출한다 |

- 이벤트는 `sessionId`로 묶이고, 값을 주지 않으면 시스템이 만듭니다. **이벤트 메타데이터**를 키-값으로 붙여 `ListEvents` 필터로 꺼내면 세션 전체를 훑지 않아도 됩니다.
- ⚠️⚠️ 공식이 명시합니다 — **이벤트 메타데이터는 고객 관리 키로 암호화되지 않습니다.** 민감 콘텐츠를 메타데이터에 담으면 안 됩니다.
- ⚠️⚠️ **`전략을 지정하지 않으면 그 메모리에 대해 장기 메모리 레코드가 추출되지 않습니다.`** 메모리 리소스를 만든 것만으로는 장기 기억이 생기지 않습니다.

전략 셋의 통제와 비용 방향:

| 전략 | 통제 | 저장 비용 |
|---|---|---|
| **내장(Built-in)** | AgentCore가 추출·통합을 전부 자동으로. 트리거 설정 외 구성 불필요 | **더 높다** |
| **내장 오버라이드** | 관리형 파이프라인을 쓰면서 **프롬프트를 수정**한다(모델을 **내 계정에서** 호출) | 내장보다 낮다 |
| **자기 관리(Self-managed)** | 추출·통합 알고리즘·스키마·네임스페이스를 전부 소유. 외부 시스템과 통합 가능 | 내장보다 낮다 |

한 메모리 리소스가 **내장과 사용자 지정 전략을 동시에** 쓸 수 있습니다.

**다중 에이전트 — 결정 순서가 공식에 있습니다.** `AGENTPERF05-BP02`는 **어떤 다중 에이전트 패턴을 고르기 전에** 그 역량이 하위 에이전트여야 하는지 **도구면 되는지**를 먼저 정하라고 적습니다. 이유도 적습니다 — **도구 호출은 밀리초에 끝나지만 하위 에이전트 위임은 완전한 추론 루프**라 시간과 토큰을 먹습니다.

- **도구로 두는 조건**: 결정적 · 스테이트리스 · 단일 단계 · 빠르다(**2~3초 미만**).
- **하위 에이전트로 두는 조건**: 자기 추론이 필요하다(모호한 입력·판단) · 자기 컨텍스트나 메모리 범위가 필요하다 · 순서 결정에 추론이 필요한 다단계 도구 오케스트레이션 · **다른 모델이나 프롬프트**를 쓴다 · **독립적인 실패 격리**가 필요하다.
- 애매하면 **도구로 시작**하고, 재호출 패턴이 잦아 자기 추론 루프가 필요하다고 드러날 때 하위 에이전트로 **승격**합니다.

협업 모델 넷과 선택 기준:

| 모델 | 언제 | 구현 메모 |
|---|---|---|
| **수퍼바이저-워커** | 작업 분해가 명확하고 **중앙 품질 통제**가 필요하다 | Strands Agents의 **agent-as-tool**과 Bedrock Agents의 다중 에이전트 협업이 **자동 컨텍스트 전달·결과 집계**를 준다 |
| **파이프라인** | 자연스러운 **순차 흐름**이다 | **단계 소요 시간을 균형** 맞추고 프레임워크의 그래프 오케스트레이션으로 잇는다 |
| **피어 투 피어/블랙보드** | 여러 에이전트가 **비동기로 부분 해답**을 낸다 | **AgentCore Memory 또는 DynamoDB**로 공유 작업 공간을 만들고 이벤트 기반 통지를 붙인다 |
| **스웜** | **병렬 탐색**과 창발적 동작에서 이득이 있다 | ⚠️⚠️ **수렴 감지와 스웜별 토큰 예산**을 넣어 무한 소비를 막는다 |

- ⚠️ 안티패턴 셋: 결정적·단일 단계 역량을 하위 에이전트에 위임하기 · **모든 워크플로에 수퍼바이저-워커를 쓰기**(수퍼바이저가 모든 중간 결과를 처리하는 병목이 된다) · **수렴 기준이나 예산 없이 스웜을 돌리기.**
- 모든 협업 모델에 **에이전트별 타임아웃과 폴백**을 넣어 한 에이전트가 전체를 막지 않게 합니다. 배포는 **AgentCore Runtime**(관리형 확장·관찰성) 또는 **EKS·ECS**(사용자 지정 컨테이너)입니다.
- ⭐ 관찰 지표도 적혀 있습니다 — **조정 지연(coordination latency) · 중복 작업률 · 모델별 처리량.**
- ⚠️ **`Amazon Bedrock Agents`는 이제 `Amazon Bedrock Agents Classic`이고 신규 고객에게 열려 있지 않습니다.** 공식 마이그레이션 경로는 **AgentCore의 관리형 harness**(권장, 구성 기반)와 **AgentCore에 올리는 코드 정의 에이전트**입니다. ⚠️ Bedrock 자체와 기존 모델·지식 베이스·Guardrails는 영향받지 않습니다.
- ⭐⭐ 그리고 **「프레임워크를 왜 쓰는가」가 공식 비교표에 적혀 있습니다** — 수퍼바이저 패턴은 에이전트를 MCP 도구로 노출해(agent-as-tool) 가능하지만 **라우팅 모드 다중 에이전트는 오늘 간단하지 않고**, 완전한 다중 에이전트 협업에는 **사용자 지정 프레임워크 코드가 필요**합니다.

### 2) 구조화된 추론으로 복잡한 문제를 푼다 (기술 2.1.2) {#reasoning}

> 🧠 원리: 「단계적으로 생각하라」는 프롬프트 기법이고, 이 기술이 묻는 것은 **그 단계를 무엇이 강제하는가**입니다. 모델이 스스로 도는 루프와 오케스트레이터가 강제하는 순서는 다릅니다.

- 공식 Lens가 쓰는 표현은 **perceive-reason-act 루프**입니다. ⚠️ 루프 반복 수는 지연과 비용을 **곱합니다** — 그래서 **작업당 평균 추론 반복 수를 1급 KPI**로 지연·토큰 지표와 나란히 봅니다.
- **모듈형 추론 단계**(`AGENTREL05-BP01`)는 큰 추론을 작은 단계로 쪼개 각 단계를 검증 가능하게 만듭니다. 깨진 단계만 고치고 되돌릴 수 있습니다.
- **오케스트레이션 둘을 범위로 가릅니다**(`AGENTSEC06-BP02`):
  - **Step Functions 상태 머신** — 실행 경로가 **JSON으로 정의**되고 오케스트레이터가 순서를 강제하는 **결정적** 워크플로.
  - **AgentCore Runtime + A2A 프로토콜** — 오케스트레이터 에이전트가 **어느 하위 에이전트를 부를지 동적으로 결정**하는 위임 워크플로.
- ⭐ 둘을 겹치는 공식 경로가 있습니다 — harness는 **Step Functions의 `InvokeHarness` 상태**로 더 큰 파이프라인에 들어갑니다. **결정적 단계가 비결정적 에이전트 단계를 감싸는** 구조입니다.
- Step Functions 쪽 통제: IAM으로 워크플로 시작·중지·수정 권한을 주체·상태 머신 단위로 제한 · 리소스 기반 정책으로 정의 변경 방지 · ⚠️ **입력 검증은 상태 머신 정의 안**(JSONPath 필터 + 검증 Lambda)에서 하고 밖에서 하지 않는다 · 실행 로깅을 CloudWatch Logs **`ALL` 레벨**로 켜 모든 상태 전이·입출력·오류를 남긴다.

### 3) 안전한 워크플로 — 제어된 FM 동작 (기술 2.1.3) {#control}

> 🧠 원리: 에이전트의 폭주는 **세 자리**에서 막습니다 — **요청이 도구에 닿기 전**(정책), **트래픽 시점**(속도 제한), **실패가 쌓일 때**(서킷 브레이커). 한 자리로 다 하려 하면 뚫립니다.

**① Policy in AgentCore** — 정책 엔진을 만들어 **게이트웨이에 연결**하면 모든 에이전트 트래픽을 가로채 **도구 접근 전에** 각 요청을 평가합니다. ⭐ 보안 제어가 **에이전트 코드 밖으로** 나가므로 에이전트를 조작해 정책을 우회할 위험이 줄어듭니다.

- 정책은 **Cedar**(오픈소스 인가 언어)로 구성하고 **Dogwood**로도 저작할 수 있습니다. Dogwood 정책 하나가 세 종류의 조건을 같은 permit·forbid 모델 안에서 조합합니다 — **입력 기반**(주체·도구·리소스·입력 파라미터) · **세션 인식 시간 조건**(전송 전 승인 여부 · 정해진 횟수 뒤 차단 · 누적 예산 유지) · **정보 공급자**(Guardrails가 평가 시점에 내는 콘텐츠 안전·프롬프트 공격 **점수**).
- **자연어로 정책을 적을 수 있고**, 생성된 후보를 도구 스키마로 검증하고 **자동 추론**으로 **과도 허용·과도 제한·절대 충족될 수 없는 조건**을 **적용 전에** 잡습니다. 차단 전에 관찰하는 **`LOG_ONLY` 모드**도 있습니다.

**② 속도 제한**(Gateway) — **차원 키**로 트래픽을 버킷으로 묶고 **엔트리**로 버킷별 허용 속도를 정합니다.

- `dimensionKeys`는 **1~10개이고 생성 후 불변**, `entries`는 **1~1,000개**입니다.
- ⚠️ 활성 속도 제한이 여럿이면 **전부 통과해야 요청이 진행됩니다(AND)**.
- 변경은 **30초 안에** 데이터 플레인으로 전파됩니다.
- ⚠️⚠️ 고객 정의 값은 **서비스 상한을 넘을 수 없고 유효 속도는 둘 중 최솟값**입니다.
- **속도를 0으로 두면 특정 호출자를 차단**합니다. 추론 타깃은 **분당 토큰(TPM)**으로 제어하고 엔드포인트의 **동시 연결 수**도 제한합니다.

**③ 서킷 브레이커** — 근거가 세 자리에 있습니다.

| 자리 | 사실 |
|---|---|
| Gateway 라우팅 규칙 | `circuitBreaker`가 **기본 ENABLED**이고 지금 실패 중인 목적지를 **건너뛴다** |
| `AGENTOPS04-BP03` | **자동 차단**이 연쇄 실패를 막는 가장 효과적인 통제다. 임계 예시 — **60초 창에서 오류 50%** 또는 **연속 타임아웃 5회**면 차단하고 **약 30초** 뒤 probing. ⚠️⚠️ **이미 사고를 낸 의존성만이 아니라 모든 외부 의존성에** 적용한다 |
| `AGENTSEC06-BP02` | Step Functions의 오류 처리·재시도로 구현하고 **catch 상태가 실패 실행을 quarantine 경로로** 보낸다(무한 재시도 금지). **EventBridge가 임계 초과 시 서킷 브레이커 이벤트를 낸다** |

- ⚠️ **폴백 순서는 도구 레지스트리에 둡니다** — 에이전트 코드에 박으면 도구 목록이 바뀔 때 따라가지 못합니다. 재시도·타임아웃 정책은 **전역이 아니라 도구별**입니다.

**④ 중지 조건** — 종료 조건 셋은 **최대 반복 수 · 신뢰도 임계 · 세션당 토큰 예산**입니다.

- ⚠️⚠️ **고정 반복 수를 신뢰도 임계 대신 쓰는 것이 안티패턴**입니다 — 토큰을 낭비하거나 복잡한 추론을 조기에 끊습니다. 반성(reflection)은 **초기 출력 품질이 임계 아래일 때만** 선택적으로 돌립니다.
- ⚠️⚠️ **실패한 호출을 같은 프롬프트·같은 모델로 재시도하는 것**도 안티패턴입니다. 의미를 바꿔 다시 묻거나, 작업을 단순화하거나, 더 유능한 모델로 폴백합니다.
- Runtime 세션 자체에도 경계가 있습니다 — 세션마다 **전용 microVM**에서 돌고 **CPU·메모리·파일시스템이 완전히 격리**되며, 종료 조건은 **비활성 15분 · 최대 수명 8시간 · 비정상 판정**입니다. ⚠️⚠️ 종료되면 **microVM 전체가 종료되고 메모리가 소거**되어 같은 `runtimeSessionId`로 다시 요청해도 **새 실행 환경**이 만들어집니다.

### 4) 모델 조정 시스템 (기술 2.1.4) {#model-routing}

> 🧠 원리: 「작업마다 다른 모델을 쓴다」는 요구를 AWS는 **세 가지 다른 기계**로 구현합니다. 셋의 제약이 서로 달라서, 시나리오가 그중 하나만 허용하는 경우가 많습니다.

| 경로 | 무엇을 하는가 | ⚠️ 결정적 제약 |
|---|---|---|
| **지능형 프롬프트 라우팅** | 단일 서버리스 엔드포인트가 요청마다 **각 모델의 응답 품질을 예측**해 더 좋은 쪽으로 보낸다. 기본 라우터와 구성 라우터, **폴백 모델**, 응답 품질 차이 기준을 둔다 | ⚠️⚠️ **같은 모델 패밀리 안에서만** 라우팅한다. ⚠️ **영어 프롬프트에만 최적화**돼 있다 |
| **Gateway 라우팅 규칙·폴백** | `matchModels` 조건과 `routeToTarget.staticRoute` 액션으로 모델→타깃을 고정하고 **1~2개 대체 목적지**와 서킷 브레이커를 둔다 | ⚠️⚠️ **스트리밍 응답이 시작된 뒤에는 폴백할 수 없다** — 호출자는 **부분 응답과 오류**를 받고 직접 재시도해야 한다 |
| **harness의 공급자 전환** | Bedrock·OpenAI·Google Gemini·LiteLLM 호환 공급자 중 아무거나 쓰고 ⭐ **세션 중간에 바꿔도 컨텍스트를 잃지 않는다**(계획은 한 모델, 실행은 다른 모델) | — |

- Gateway 규칙의 세부: 여러 타깃이 같은 모델을 맡으면 기본 라우팅은 **아무 쪽으로나** 보내므로 규칙이 고정합니다. `staticRoute`에 `model`을 적으면 **호출자가 요청한 모델과 다른 모델을 서빙**할 수 있습니다. `triggerOn`이 떠나는 조건이고 **`firstByteTimeoutMilliseconds`**는 공급자가 깔끔한 오류 없이 **멈춰 있을 때**를 위한 것입니다. 게이트웨이는 체인을 순서대로 걷고 각 목적지를 **한 번** 시도하며, 전부 실패하면 호출자는 **마지막 오류**를 받습니다.
- ⚠️ 「모델 앙상블의 사용자 지정 집계 로직」처럼 공식 서비스가 대신해 주지 않는 부분은 **애플리케이션 코드나 오케스트레이터**가 맡습니다 — 라우팅 기능이 앙상블 집계를 해 준다고 적는 보기는 거짓입니다.

### 5) 인간 전문 지식으로 FM을 보강한다 (기술 2.1.5) {#human}

> 🧠 원리: 공식이 이 기술의 핵심 문장을 직접 적습니다 — **전건을 사람에게 보내면 고무도장이 되고, 아무것도 보내지 않으면 무제한 자율이 됩니다.** 그래서 설계는 「승인을 받는가」가 아니라 **「무엇에 대해 받는가」**입니다.

- 기준선(`AGENTSEC04-BP02`): **읽기 전용은 자율 진행** · **저위험 쓰기는 단일 검토자 승인** · **고위험(금융 거래 · 데이터 삭제 · 외부 통신)은 더 엄격**하게(단일·복수·대역 외 — 위험 정책에 따라).
- ⚠️⚠️ **위험 분류 자체를, 평가 대상과 같은 비신뢰 콘텐츠에 노출된 모델에 의존할 수 없습니다** — 적대적 콘텐츠가 분류기를 꾀어 저위험으로 표시하게 만들 수 있습니다. **결정적 로직**(정책 엔진·규칙 기반 분류기)이 권위 있는 신호이고, 모델 분류는 **결정적 계층이 다시 검사하는** 선택 입력입니다.
- **지속 신뢰 부여**(한 번 승인하면 같은 패턴은 재승인 없이 통과)는 유용한 탈출 밸브지만 **판단 시점을 앞으로 옮깁니다.** 각 부여를 **특정 명령·파라미터 모양·리소스로 한정**하고, 고위험은 부여 대상에서 빼거나 정해진 주기로 재확인하게 하고, 부여 자체를 감사·철회 가능하게 합니다. ⚠️⚠️ **와일드카드 신뢰 부여**(파라미터 범위 없이 그 유형의 모든 미래 작업을 승인)는 발급하지 않습니다.
- 승인 결정은 **타임스탬프와 검토자 신원**과 함께 로깅해 감사 기록을 만듭니다.
- 승인 경로: Step Functions 워크플로라면 **`.waitForTaskToken` 콜백 패턴**으로 승인 단계를 넣습니다(워크플로가 태스크 토큰을 내고 멈춥니다). 피드백 수집은 API 계층(예: API Gateway)으로 받습니다.
- ⚠️ 안티패턴 셋: 전건 검토 · **컨텍스트 없는 검토**(제안 동작만 주고 추론 체인·데이터 출처·결과를 주지 않으면 검토가 형식이 된다) · ⚠️⚠️ **타임아웃·에스컬레이션 경로 없는 승인 워크플로**(검토자가 없으면 실행이 무한정 멈춘다).
- Agents Classic의 **인라인 함수 도구는 return-of-control과 등가**입니다 — 에이전트가 멈추고 `tool_use`를 클라이언트 코드에 돌려주고, 클라이언트가 사람과 상호 작용한 결과를 돌려보냅니다. ⚠️ Classic의 `AMAZON.UserInput`처럼 **자동으로 재질의하는 동작은 복제되지 않고 명시적 도구 정의가 필요**합니다.

### 6) 지능형 도구 통합 (기술 2.1.6) {#tools}

> 🧠 원리: 도구를 「붙인다」는 것은 두 가지입니다 — **모델이 이해하는 형식으로 설명하는 것**(표준화된 함수 정의)과 **그 호출이 안전하게 끝나게 하는 것**(검증·오류 처리). 둘 중 하나만 하면 에이전트가 도구를 잘못 부르고도 성공했다고 믿습니다.

- **Gateway**가 그 변환 계층입니다. API·Lambda 함수·기존 서비스를 **MCP 호환 도구로 변환**하고, 다른 에이전트·HTTP 서비스는 **패스스루 타깃**으로 앞단에 두며(**A2A** 트래픽 포함), 추론 요청은 **모델 기반 라우팅 엔드포인트**로 보냅니다. 도구 입력 유형은 **OpenAPI · Smithy · Lambda**이고, **인그레스·이그레스 인증을 모두** 제공한다고 적습니다.
- 역량: **Security Guard**(OAuth 인가) · **Translation**(MCP 요청을 API·Lambda 호출로) · **Composition**(여러 API·함수·도구·에이전트·모델 공급자를 한 엔드포인트 뒤로) · **Secure Credential Exchange**(도구별 자격 증명 주입) · **Semantic Tool Selection** · **Infrastructure Manager**.
- **도구가 많아질 때의 공식 답은 의미 검색**입니다 — 도구 이름이 **`x_amz_bedrock_agentcore_search`**이고 `tools/call`로 부릅니다. 공식이 적는 값은 **수천 개의 도구를 쓰면서 프롬프트 크기를 최소화하고 지연을 줄인다**입니다. ⚠️⚠️ **게이트웨이를 만들 때 켜 둬야 합니다.** 지원 리전에 **서울(`ap-northeast-2`)이 듭니다**.
- **표준 프로토콜을 쓰는 이유**(`AGENTOPS04-BP02`): **MCP**로 도구를, **A2A**로 에이전트 간 통신을 표준화하면 도구마다 어댑터를 쓰지 않아도 되고 통제를 한 자리에 모을 수 있습니다. 그 자리가 Gateway이고, **정책 평가는 트래픽 시점**에 일어납니다.
- **도구 신뢰성은 지표로 봅니다**(`AGENTOPS04-BP03`): AgentCore Observability가 **도구별 호출 수 · 성공률 · 유형별 오류율 · 지연 백분위수**를 추적합니다. ⭐ **복합 알람**이 여러 지표를 묶습니다 — **지연이 오르면서 타임아웃 비율도 오르는 도구**는 단일 임계로는 어느 쪽도 울리지 않아도 차단에 가까워진 도구이고, 복합 보기가 단일 임계보다 **먼저** 열화를 잡습니다.
- ⚠️ 파라미터 검증과 오류 처리는 **도구 쪽 구현**(예: Lambda 함수) 책임입니다. 에이전트는 오류 메시지를 다음 추론의 입력으로 받으므로, **무엇이 왜 틀렸는지 적힌 오류**가 품질을 바꿉니다.

### 7) 모델 확장 프레임워크 — MCP 서버를 올린다 (기술 2.1.7) {#mcp-servers}

> 🧠 원리: MCP는 **프로토콜**이고, 그 프로토콜을 말하는 **서버를 어디서 돌리는가**가 이 기술입니다. AWS docs가 적는 경로는 둘이고, 각자 계약이 다릅니다.

**경로 ① AgentCore Runtime 호스팅**:

- 서버는 **`0.0.0.0:8000/mcp`**에 있어야 합니다(대부분의 공식 MCP SDK 기본 경로).
- ⚠️⚠️ **`protocolConfiguration.serverProtocol`을 `MCP`로 설정하지 않으면** Runtime은 HTTP로 동작하고 **JSON-RPC 오류 응답 같은 MCP 동작을 얻지 못합니다**(`CreateAgentRuntime`·`UpdateAgentRuntime`에서 설정).
- **같은 세션 ID의 요청은 같은 microVM으로** 라우팅됩니다. `InvokeAgentRuntime` 페이로드는 **그대로 통과 전달**되므로 RPC 메시지를 프록시하기 쉽습니다.
- 배포는 둘 — **직접 코드 배포**(CLI가 코드·의존성을 올리고 Runtime이 환경을 관리) · **컨테이너 이미지**(⚠️ **ARM64**로 빌드해 ECR에 푸시).

**경로 ② Gateway의 MCP 서버 타깃** — 기존 MCP 서버를 게이트웨이 뒤에 둡니다.

| `ListingMode` | 동작 | ⚠️ |
|---|---|---|
| **`DEFAULT`**(기본) | 동기화로 역량을 발견한다 | 생성·수정 시 **암시적 동기화**가 돌아 `tools/list`·`prompts/list`·`resources/list`를 통합 카탈로그에 넣는다 |
| **`DYNAMIC`** | 사용자가 MCP 작업을 호출할 때 클라이언트가 역량을 발견한다 | ⚠️⚠️ **의미 검색과 아웃바운드 3LO(three-legged OAuth)와 상호 운용되지 않는다** |

- MCP 서버의 도구·프롬프트·리소스 정의가 바뀌면 **`SynchronizeGatewayTargets`를 호출해야 합니다**(**202를 즉시 반환하고 비동기로 처리**). ⭐ 이유가 문서에 있습니다 — Gateway가 **의미 검색용 벡터 임베딩을 미리 계산**하고 정규화된 카탈로그를 유지하기 때문입니다. 동기화하지 않으면 **최신 도구를 발견·호출할 수 없습니다.**
- ⚠️ 게이트웨이는 `protocolConfiguration.mcp`의 **`supportedVersions`에 든 버전만** 받습니다.

**상태성 요구가 버전 경계에서 뒤집힙니다**:

| MCP 프로토콜 버전 | elicitation · sampling · progress notifications |
|---|---|
| **`2025-11-25` 및 이전** | **stateful 필요**(`stateless_http=False`) — 서버가 요청을 먼저 보내는 방식이다 |
| **`2026-07-28` 및 이후** | **stateless**로 동작한다 — 그 방식이 제거되고 **multi round-trip requests 패턴**으로 바뀌었다 |

- stateful 모드에서는 initialize 응답에 **`Mcp-Session-Id` 헤더**가 오고 이후 요청에 실어야 합니다. 서버가 종료되거나 세션이 만료되면 **404**가 올 수 있고 클라이언트는 **재초기화**해야 합니다.
- MCP 기능: **Resources**(URI로 식별되는 데이터) · **Prompts**(재사용 템플릿) · **Tools**(모델이 호출하는 함수) · **Elicitation**(서버가 시작하는 사용자 입력 요청) · **Sampling**(서버가 클라이언트에 생성을 요청) · **Progress notifications**.
- ⚠️ 프레임워크를 고를 때 **계측도 함께 봅니다** — AgentCore가 적는 Strands Agents는 **SDK에 계측이 내장**돼 추가 라이브러리가 필요 없고, 나머지는 **OpenTelemetry 또는 OpenInference 계측 라이브러리**와 권장 버전 하한이 있습니다.

---

## ✍️ 시험 포인트

- 「여러 세션에 걸쳐 사용자 선호를 기억해야 한다」면 **장기 메모리**이고, **전략을 지정**해야 레코드가 만들어집니다.
- 「세션 ID를 그대로 다시 썼는데 대화가 이어지지 않는다」면 **세션이 종료돼 microVM 메모리가 소거된 것**입니다(비활성 15분·최대 8시간).
- 「이 역량을 에이전트로 둘까 도구로 둘까」면 **결정적·단일 단계·2~3초 미만이면 도구**이고, 애매하면 **도구로 시작해 승격**합니다.
- 「탐색형 작업을 여러 에이전트가 병렬로」면 **스웜**이고, **수렴 기준과 토큰 예산**이 빠진 설계는 오답입니다.
- 「모든 작업을 수퍼바이저가 모아 처리한다」는 선택지는 **병목 안티패턴**입니다.
- 「에이전트 폭주를 막을 통제」를 고를 때 **반복 상한만** 있는 보기보다 **신뢰도 임계·토큰 예산**이 함께 있는 보기가 정답입니다.
- 「도구 접근 전에 모든 요청을 평가」면 **Policy**, 「호출자별 트래픽을 묶어 제한」이면 **속도 제한**, 「실패 중인 목적지를 건너뛴다」면 **서킷 브레이커**입니다.
- 「다른 패밀리의 더 싼 모델로 자동 라우팅」은 **지능형 프롬프트 라우팅으로 할 수 없습니다**(같은 패밀리 안에서만).
- 「스트리밍 중 공급자가 죽었다」면 **폴백이 안 되고 부분 응답과 오류**를 받습니다.
- 「고위험 작업에 사람 승인」이면 **위험 등급별 설계 + 타임아웃·에스컬레이션**이 있어야 하고, **분류를 모델에만 맡기는 보기**는 오답입니다.
- 「도구가 수천 개」면 **의미 검색**이고 **게이트웨이 생성 시 켜야** 합니다.
- 「MCP 서버에 도구를 추가했는데 에이전트가 못 본다」면 **동기화 호출 누락**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **메모리 리소스를 만들면 장기 기억이 생긴다고 생각하기.** **전략이 없으면 추출되지 않습니다.**
- ⚠️ **이벤트 메타데이터에 민감 정보를 넣기.** **고객 관리 키로 암호화되지 않습니다.**
- ⚠️⚠️ **세션이 영구적이라고 생각하기.** 종료되면 **메모리가 소거**되고 이어지지 않습니다.
- ⚠️⚠️ **패턴부터 고르기.** 공식은 **도구냐 하위 에이전트냐를 먼저** 정하라고 적습니다.
- ⚠️ **결정적 단일 단계 작업을 하위 에이전트에 위임하기.** 밀리초짜리 일에 추론 루프 비용을 냅니다.
- ⚠️⚠️ **스웜에 수렴 기준·예산을 안 두기.** 무한 탐색이 됩니다.
- ⚠️ **고정 반복 수를 신뢰도 임계 대신 쓰기.** 공식이 **안티패턴**으로 적습니다.
- ⚠️⚠️ **같은 프롬프트·같은 모델로 재시도하기.** 의미를 바꾸거나 모델을 올려야 합니다.
- ⚠️ **서킷 브레이커를 사고 낸 의존성에만 걸기.** **모든 외부 의존성에** 적용합니다.
- ⚠️ **폴백 순서를 에이전트 코드에 박기.** **도구 레지스트리**에 둡니다.
- ⚠️⚠️ **프롬프트 라우팅이 패밀리를 넘는다고 생각하기.** **같은 패밀리 안에서만**입니다.
- ⚠️ **스트리밍 중에도 폴백이 된다고 생각하기.** 시작된 뒤에는 **안 됩니다**.
- ⚠️⚠️ **위험 분류를 비신뢰 콘텐츠를 본 모델에 맡기기.** 결정적 로직이 권위 있는 신호입니다.
- ⚠️ **와일드카드 신뢰 부여를 발급하기.** 파라미터 범위로 한정해야 합니다.
- ⚠️ **`serverProtocol`을 설정하지 않고 MCP 동작을 기대하기.** HTTP로 동작합니다.
- ⚠️⚠️ **MCP 서버 정의를 바꾸고 동기화를 건너뛰기.** 새 도구를 발견할 수 없습니다.
- ⚠️ **`DYNAMIC` 리스팅으로 의미 검색을 쓰려 하기.** 상호 운용되지 않습니다.
- ⚠️ **컨테이너 이미지를 x86으로 빌드하기.** **ARM64**가 필요합니다.

---

## 🧪 자가 점검

**Q1.** AgentCore Memory 리소스를 만들고 이벤트를 쌓았는데 다음 세션에서 사용자 선호가 기억되지 않습니다. 무엇이 빠졌습니까?

<details><summary>정답 보기</summary>

**메모리 전략**입니다. 공식이 명시합니다 — **전략을 지정하지 않으면 그 메모리에 대해 장기 메모리 레코드가 추출되지 않습니다.** 이벤트(단기)는 쌓이지만 요약·사실·선호 같은 **구조화 레코드**는 전략이 추출합니다. 전략은 **내장 · 내장 오버라이드 · 자기 관리** 셋이고, 내장이 **저장 비용이 더 높은** 대신 구성이 필요 없습니다.
</details>

**Q2.** 「환율을 조회하는 기능」을 하위 에이전트로 만들려 합니다. 공식 기준으로 맞습니까?

<details><summary>정답 보기</summary>

아닙니다 — **도구**로 둡니다. `AGENTPERF05-BP02`의 기준은 **결정적 · 스테이트리스 · 단일 단계 · 2~3초 미만**이면 도구이고, 하위 에이전트는 **자기 추론·자기 컨텍스트·독립 실패 격리**가 필요할 때입니다. 공식이 적는 이유는 **도구 호출은 밀리초에 끝나지만 하위 에이전트 위임은 완전한 추론 루프**라 시간과 토큰을 먹는다는 것입니다. 애매하면 **도구로 시작해 재호출 패턴을 보고 승격**합니다.
</details>

**Q3.** 여러 에이전트가 각자 가설을 내고 서로의 중간 결과를 비동기로 참조해야 합니다. 어떤 협업 모델이고 공유 상태는 무엇으로 둡니까?

<details><summary>정답 보기</summary>

**피어 투 피어/블랙보드**입니다. 공식 구현 메모는 **AgentCore Memory 또는 DynamoDB로 공유 작업 공간**을 만들고 **이벤트 기반 통지**를 붙이는 것입니다. 작업이 명확히 분해되고 중앙 품질 통제가 필요하면 수퍼바이저-워커, 순차 흐름이면 파이프라인, 병렬 탐색이면 스웜입니다.
</details>

**Q4.** 비용이 급증해 「추론 반복을 5회로 고정」했습니다. 공식 판정은 무엇이고 대안은 무엇입니까?

<details><summary>정답 보기</summary>

**안티패턴**입니다. `AGENTCOST01-BP01`이 **고정 반복 수를 신뢰도 임계 대신 쓰는 것**을 안티패턴으로 적습니다 — 토큰을 낭비하거나 복잡한 추론을 조기에 끊습니다. 종료 조건은 셋을 함께 씁니다: **최대 반복 수 · 신뢰도 임계 · 세션당 토큰 예산.** 반성은 **초기 출력 품질이 임계 아래일 때만** 선택적으로 돌립니다.
</details>

**Q5.** 「다른 모델 패밀리의 더 저렴한 모델로 쉬운 질문을 자동 라우팅」하려 합니다. 지능형 프롬프트 라우팅으로 됩니까?

<details><summary>정답 보기</summary>

안 됩니다. 지능형 프롬프트 라우팅은 ⚠️ **같은 모델 패밀리 안에서만** 라우팅하고 **영어 프롬프트에 최적화**돼 있습니다. 패밀리를 넘기려면 **Gateway의 라우팅 규칙**(`matchModels` + `staticRoute`)이나 **애플리케이션·오케스트레이터 로직**으로 갑니다. Gateway 쪽은 **1~2개 대체 목적지**와 **기본 ENABLED인 서킷 브레이커**를 주지만, ⚠️ **스트리밍이 시작된 뒤에는 폴백할 수 없습니다.**
</details>

**Q6.** 에이전트가 고위험 작업을 하기 전에 사람 승인을 받게 설계합니다. 반드시 넣어야 하는 두 가지와, 하면 안 되는 한 가지는 무엇입니까?

<details><summary>정답 보기</summary>

넣어야 하는 것은 **타임아웃과 에스컬레이션 경로**(없으면 검토자가 없을 때 실행이 무한정 멈춥니다)와 **검토에 필요한 컨텍스트**(추론 체인·데이터 출처·예상 결과 — 없으면 검토가 형식이 됩니다)입니다. 하면 안 되는 것은 ⚠️⚠️ **위험 분류를 평가 대상과 같은 비신뢰 콘텐츠에 노출된 모델에 맡기는 것**입니다. **결정적 로직**이 권위 있는 신호입니다. Step Functions라면 **`.waitForTaskToken`** 콜백으로 승인 단계를 넣습니다.
</details>

**Q7.** 사내 MCP 서버에 도구 세 개를 추가했는데 Gateway를 지나는 에이전트가 새 도구를 보지 못합니다. 왜이고 무엇을 합니까?

<details><summary>정답 보기</summary>

**동기화를 호출하지 않았기** 때문입니다. MCP 서버의 도구·프롬프트·리소스 정의가 바뀌면 **`SynchronizeGatewayTargets`**를 불러야 하고(**202를 즉시 반환하고 비동기 처리**), 이유는 Gateway가 **의미 검색용 벡터 임베딩을 미리 계산**하고 정규화된 카탈로그를 유지하기 때문입니다. ⚠️ `ListingMode`가 **`DYNAMIC`**이면 발견은 호출 시점에 일어나지만 **의미 검색과 아웃바운드 3LO와 상호 운용되지 않습니다.**
</details>

**Q8.** MCP 서버를 Runtime에 올렸는데 JSON-RPC 오류 응답이 오지 않고 평범한 HTTP 응답만 옵니다. 무엇을 확인합니까?

<details><summary>정답 보기</summary>

**`protocolConfiguration.serverProtocol`이 `MCP`로 설정됐는지**입니다. 설정하지 않으면 Runtime은 HTTP로 동작하고 MCP 특유의 동작을 얻지 못합니다(`CreateAgentRuntime`·`UpdateAgentRuntime`에서 설정). 함께 볼 것: 서버가 **`0.0.0.0:8000/mcp`**에 있는지, 컨테이너 배포라면 **ARM64**로 빌드했는지입니다.
</details>

---

### 📌 출처

1. AgentCore harness (선언형 계층 · 공급자 전환 · `InvokeHarness`) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html` (2026-11-14 확인)
2. AgentCore Runtime 동작 방식 (microVM 격리 · 비활성 15분 · 최대 8시간 · 메모리 소거) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-how-it-works.html` (2026-11-14 확인)
3. Runtime에 MCP 서버 배포 (`0.0.0.0:8000/mcp` · `serverProtocol` · ARM64 · 세션 stickiness) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-mcp.html` (2026-11-14 확인)
4. 상태 유지 MCP 기능 (기능 여섯 · `Mcp-Session-Id` · 버전 경계) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/mcp-stateful-features.html` (2026-11-14 확인)
5. AgentCore Memory 유형 (단기 ↔ 장기 · 이벤트 메타데이터 미암호화) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-types.html` (2026-11-14 확인)
6. AgentCore Memory 전략 (전략 없으면 장기 기억 없음 · 비용 방향) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html` (2026-11-14 확인)
7. AgentCore Gateway 개요 (MCP 변환 · 역량 · 도구 입력 유형 셋) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html` (2026-11-14 확인)
8. Gateway의 MCP 서버 타깃 (`ListingMode` · `SynchronizeGatewayTargets`) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-target-MCPservers.html` (2026-11-14 확인)
9. Gateway의 MCP 의미 검색 (`x_amz_bedrock_agentcore_search` · 생성 시 활성화) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-using-mcp-semantic-search.html` (2026-11-14 확인)
10. Gateway 라우팅 규칙과 폴백 (서킷 브레이커 기본 ENABLED · 스트리밍 후 폴백 불가) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rules-fallback.html` (2026-11-14 확인)
11. Gateway 속도 제한 (차원 키 1~10 불변 · AND · 30초 전파 · 최솟값 · TPM) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rate-limits.html` (2026-11-14 확인)
12. Policy in AgentCore (Cedar·Dogwood · 자연어·자동 추론 · `LOG_ONLY`) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy.html` (2026-11-14 확인)
13. AgentCore의 지원 프레임워크와 계측 (Strands는 SDK 내장 계측) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html` (2026-11-14 확인)
14. Amazon Bedrock Agents Classic 유지 관리 모드 (신규 고객 비개방 · 마이그레이션 경로 둘 · 비교표) — `docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html` (2026-11-14 확인)
15. Agents Classic의 다중 에이전트 협업 (계층형 · 수퍼바이저 먼저 저장) — `docs.aws.amazon.com/bedrock/latest/userguide/agents-multi-agent-collaboration.html` (2026-11-14 확인)
16. Amazon Bedrock 지능형 프롬프트 라우팅 (같은 패밀리 · 영어 최적화 · 폴백 모델) — `docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html` (2026-11-14 확인)
17. AGENTPERF05-BP02 다중 에이전트 협업 모델 (도구 ↔ 하위 에이전트 결정 · 모델 넷 · 지표) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html` (2026-11-14 확인)
18. AGENTPERF02-BP01 (perceive-reason-act · 반복 수 KPI) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf02-bp01.html` (2026-11-14 확인)
19. AGENTCOST01-BP01 (종료 조건 셋 · 고정 반복 안티패턴 · 반성 패턴) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentcost01-bp01.html` (2026-11-14 확인)
20. AGENTREL05-BP01 (모듈형 추론 단계) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentrel05-bp01.html` (2026-11-14 확인)
21. AGENTSEC04-BP02 (위험 등급별 승인 · 분류기를 비신뢰 모델에 맡기지 않는다 · `.waitForTaskToken`) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec04-bp02.html` (2026-11-14 확인)
22. AGENTSEC06-BP02 (오케스트레이션 둘 · catch → quarantine · EventBridge) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentsec06-bp02.html` (2026-11-14 확인)
23. AGENTOPS04-BP02 (표준 프로토콜 MCP·A2A · 트래픽 시점 정책 평가) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp02.html` (2026-11-14 확인)
24. AGENTOPS04-BP03 (자동 차단 임계 · 도구별 지표 · 복합 알람 · 폴백 레지스트리) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp03.html` (2026-11-14 확인)
