---
examGuideTaskId: dva-t2-3
certCode: DVA-C03
domain: 2
domainName: 보안
domainWeightPct: 26
title: AI 서비스 통합의 보안 위험 완화 (모델 접근·사설 연결·Guardrails·에이전트·로그)
coversTasks:
  - "2.3"
sources:
  - title: Access Amazon Bedrock foundation models
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html
  - title: Use interface VPC endpoints (AWS PrivateLink) with Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html
  - title: Amazon Bedrock Guardrails
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html
  - title: Components of a guardrail
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-components.html
  - title: Use the ApplyGuardrail API independently
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-independent-api.html
  - title: Get user confirmation before invoking action group function
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-userconfirmation.html
  - title: Return control to the agent developer
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-returncontrol.html
  - title: Monitor model invocation using CloudWatch Logs and Amazon S3
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
lastVerified: 2026-11-01
---

# AI 서비스 통합의 보안 위험 완화 (모델 접근·사설 연결·Guardrails·에이전트·로그)

> **커버하는 공식 Task** — DVA-C03 · 도메인 2 「보안」(26%) · **작업 2.3 AI 서비스를 사용하고 애플리케이션 개발에 통합하는 것과 관련된 보안 위험을 식별하고 완화합니다** (`dva-t2-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 다섯 개(2.3.1~2.3.5)를 모두 덮습니다.

> ⚠️ **완전 신설 Task입니다.** 다섯 기술 전부 C03에서 새로 생겼고, C02 교재에는 프롬프트 인젝션·Guardrails·AgentCore에 해당하는 내용이 **없습니다.**
>
> ⚠️ **번호 충돌**: **C02의 2.3(민감 데이터 관리) ≠ C03의 2.3(AI 보안)**입니다. C02에서 민감 데이터였던 내용은 C03의 **작업 2.2**(`dva-t2-2`)로 들어갔습니다.

> ⛔ **이 작업에서 넘지 말아야 할 선** — 가이드의 "범위에 해당하지 않는 작업"에 **"AI 안전 프레임워크 설계, 가드레일 구현, AI 거버넌스 구현"**이 있습니다. 모순이 아닙니다: 범위 밖은 안전 프레임워크를 **설계**하고 거버넌스를 **구현**하는 일이고, 기술 2.3.3이 요구하는 것은 **제공되는 통제를 적용**하는 일입니다. 그래서 묻는 것은 "가드레일 정책을 어떻게 설계하는가"가 아니라 **"이 요구사항에 어떤 통제를 켜는가"**입니다. **파운데이션 모델 선택·프롬프트 엔지니어링·RAG 설계**도 범위 밖입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 모델 접근이 **기본 허용**이라는 것과 `AccessDeniedException`의 전제 조건 세 가지를 안다
- [ ] 인터페이스 VPC 엔드포인트로 **인터넷을 거치지 않는 호출**을 구성할 수 있다
- [ ] "입출력이 학습에 쓰이지 않는다"가 **설정이 아니라 서비스 약속**임을 설명한다
- [ ] Guardrails의 보호 장치를 **요구사항 → 통제**로 고를 수 있다
- [ ] **프롬프트 공격이 콘텐츠 필터의 한 범주**라는 것과 단어 필터·거부 주제의 차이를 안다
- [ ] 인라인 guardrail과 **`ApplyGuardrail`**을 고르는 기준을 말한다
- [ ] 사용자 확인과 제어 반환을 **누가 실행하는가**로 가른다
- [ ] 모델 호출 로깅이 **가드레일 이전 입력**을 담는다는 것과 로그 보호 조합을 안다

---

## 🎯 왜 중요한가

이 작업은 **AI 기능을 붙이는 개발자가 실제로 밟는 순서**를 그대로 따릅니다 — 모델에 접근하고(2.3.1), 데이터를 사설 경로로 보내고(2.3.2), 입출력을 거르고(2.3.3), 에이전트가 함부로 행동하지 못하게 하고(2.3.4), 로그로 새지 않게 합니다(2.3.5).

그래서 문항도 "이 요구사항에 무엇을 켜는가"로 나올 가능성이 큽니다. 반대로 **모델을 고르거나 프롬프트를 설계하는 문항은 범위 밖**입니다. 그 선을 알고 있으면 보기 중 절반이 먼저 지워집니다.

가장 자주 틀릴 지점 두 개를 미리 적어 둡니다 — **모델 접근은 이제 "요청"이 아니고**(기본 허용), **"학습에 쓰지 않도록 설정"하는 옵트아웃은 Bedrock에 존재하지 않습니다**(끌 설정이 없어서입니다).

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- ⚠️ **모델 접근은 기본 허용**입니다 — "Access to many Amazon Bedrock foundation models is enabled by default with the correct AWS Marketplace permissions." 첫 호출 시 **구독이 자동으로 시작**됩니다(설정 최대 **15분**, 권한 부여 후 완료까지 최대 **2분**)
- **`AccessDeniedException`이면 셋을 봅니다** — ① IAM의 `aws-marketplace:Subscribe`·`Unsubscribe`·`ViewSubscriptions` ② **Anthropic 모델은 최초 사용(FTU) 양식** ③ 유효한 결제 수단
- **세분화 통제는 모델 ARN**으로 합니다 — `arn:aws:bedrock:<region>::foundation-model/<model-id>`에 `bedrock:InvokeModel` Allow·Deny
- ⚠️ **VPC 엔드포인트를 통한 요청에는 `aws:SourceIp`가 없습니다** — IAM 정책에 `IpAddress` 조건을 걸면 **충족될 수 없습니다**
- **사설 연결**: 인터페이스 VPC 엔드포인트(PrivateLink). 런타임 서비스 이름은 **`com.amazonaws.<region>.bedrock-runtime`**이고 **퍼블릭 IP가 필요 없습니다**
- ⚠️ **"입출력을 학습에 쓰지 않는다"는 서비스 약속이고 설정이 아닙니다** — 그래서 **Bedrock은 AI 서비스 옵트아웃 정책의 대상이 아닙니다.** 단 **일부 모델은 남용 탐지 목적으로 최대 30일 보관**합니다
- ⚠️ **프롬프트 공격은 별도 보호 장치가 아니라 콘텐츠 필터의 한 범주**입니다(6종: Hate · Insults · Sexual · Violence · Misconduct · **Prompt Attack**)
- **단어 필터는 정확 일치**, **거부 주제는 주제 단위**입니다. 민감 정보 필터는 PII·정규식을 **차단 또는 마스킹**합니다
- **`ApplyGuardrail`은 모델을 호출하지 않고** 텍스트를 평가합니다 — RAG의 **검색 전** 검사, **Bedrock 밖 모델**에도 적용
- ⚠️ **모델 호출 로깅은 기본 꺼짐**이고, 켜면 **가드레일 이전의 사용자 입력**이 담깁니다 — 로그에 민감 정보가 있다고 가정하고 **데이터 보호 정책 + `logs:Unmask` 분리 + KMS**로 막습니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **FTU 양식** | Anthropic 모델의 **최초 사용(first-time use)** 신청. 콘솔 또는 `PutUseCaseForModelAccess` API로 낸다 |
| **guardrail** | 입력·출력에 적용하는 보호 장치 묶음. 콘텐츠 필터·거부 주제·단어 필터·민감 정보 필터 등 |
| **프롬프트 인젝션** | 외부 입력에 섞인 지시를 모델이 시스템 지시처럼 따르게 만드는 공격 |
| **프롬프트 유출** | 시스템 프롬프트 자체를 토해 내게 만드는 공격 |
| **사용자 확인** | 작업 그룹의 특정 작업 전에 에이전트가 **사람에게 승인을 묻는** 기능 |
| **제어 반환** | Lambda로 넘기지 않고 **호출 정보를 애플리케이션에 돌려주는** 실행 방식 |
| **WAT / WIC** | AgentCore의 Workload Access Token과 Workload Identity Chain — 다중 홉에서 **세션 동일성**을 보존한다 |
| **모델 호출 로깅** | Bedrock의 호출 로그·모델 입력·출력 수집 기능(기본 꺼짐) |

---

## 📖 핵심 개념

### 1) 모델 접근 — 이제 "기본 허용"이다 (기술 2.3.1) {#model-access}

⚠️ **가장 흔한 구식 오해**입니다. 예전 자료는 "콘솔에서 모델 액세스를 요청해야 한다"고 적지만 공식 문서는 이렇게 적습니다.

> 원문: "Access to many Amazon Bedrock foundation models is enabled by default with the correct AWS Marketplace permissions."

- 기본 접근은 **모델이 지원되는 모든 상용 리전**에 적용됩니다.
- 서드파티 모델을 **처음 호출하면 Bedrock이 배경에서 구독 절차를 자동 시작**합니다. 설정 기간(**최대 15분**) 동안 호출이 일시적으로 성공할 수 있고, 전제 조건이 빠져 있으면 구독이 실패해 이후 호출이 `AccessDeniedException`을 돌려줍니다. 권한을 부여한 뒤 구독 완료까지 **최대 2분**이 더 걸릴 수 있습니다.
- **전제 조건 세 가지**: ① IAM 역할의 **`aws-marketplace:Subscribe`·`Unsubscribe`·`ViewSubscriptions`** ② **Anthropic 모델은 최초 사용(FTU) 양식** 제출 ③ **유효한 결제 수단**.
- FTU 양식은 콘솔 또는 **`PutUseCaseForModelAccess`** API로 냅니다. ⚠️ 제출이 즉시 끝나지 않고 계약이 **보류 상태**에 머물 수 있으며 그동안 호출은 계속 `AccessDeniedException`입니다. 상태는 **`GetFoundationModelAvailability`**의 `agreementAvailability`로 확인합니다. 관리 계정의 제출은 같은 Organization의 다른 계정에 **상속**됩니다.
- **EULA를 먼저 검토해야 하는 조직**은 ① SCP·IAM으로 모델 접근을 **선차단** → ② EULA 검토 → ③ 동의할 때만 정책으로 개방합니다. ⚠️ 서드파티 모델은 **첫 호출 자체가 EULA 동의**로 간주됩니다.
- **세분화 통제는 IAM 리소스 ARN**으로 합니다 — `arn:aws:bedrock:<region>::foundation-model/<model-id>`에 `bedrock:InvokeModel`·`InvokeModelWithResponseStream`을 Allow·Deny.

> ⭐ **2.3.2와 이어지는 함정** — 구독을 여는 첫 호출도 보통의 `bedrock:InvokeModel`처럼 인가됩니다. 그래서 **`IpAddress` 조건으로 `aws:SourceIp`를 걸어 두면** 그 조건을 만족하는 곳에서 호출해야 하는데, ⚠️ **VPC 엔드포인트를 통한 요청에는 `aws:SourceIp`가 아예 없습니다.** 그런 조건은 **충족될 수 없습니다.**

> 🧠 **원리** — 접근 통제의 축이 **"요청·승인"에서 "구독 전제 조건 + IAM 리소스 정책"으로** 옮겨갔습니다. 그래서 막혔을 때 보는 곳도 콘솔의 승인 화면이 아니라 **Marketplace 권한·계약 상태·결제 수단**입니다.

### 2) 사설 연결 — 인터페이스 VPC 엔드포인트 (기술 2.3.2) {#private-link}

> 원문: "You can access Amazon Bedrock as if it were in your VPC, without the use of an internet gateway, NAT device, VPN connection, or Direct Connect connection."

- 인터페이스 엔드포인트를 만들면 활성화한 **서브넷마다 엔드포인트 네트워크 인터페이스**가 생깁니다. ⚠️ VPC 인스턴스에 **퍼블릭 IP가 필요 없습니다.**
- 런타임 호출용 서비스 이름은 **`com.amazonaws.<region>.bedrock-runtime`**입니다(제어 평면용은 별도).
- **엔드포인트 정책**으로 특정 **모델 ARN·특정 보안 주체만** 허용하는 최소 권한을 걸 수 있습니다.

> 🧠 **원리** — PrivateLink는 "방화벽을 여는 것"이 아니라 **서비스를 내 VPC 안의 ENI로 끌어오는 것**입니다. 그래서 인터넷 경로가 아예 필요 없어지고, 동시에 **IP 기반 조건이 의미를 잃습니다**(요청에 `aws:SourceIp`가 없습니다). 통제는 **엔드포인트 정책과 IAM**으로 옮겨갑니다.

### 3) 학습 미사용 — 설정이 아니라 약속 (기술 2.3.2) {#no-training}

> 원문: "Amazon Bedrock does not use your inputs or outputs to train models or to improve the service, and does not share them with model providers."

- ⚠️ 그래서 **Bedrock은 AI 서비스 옵트아웃 정책의 대상 서비스가 아닙니다** — **끌 설정이 없기 때문**입니다. "옵트아웃 정책을 적용해야 학습에 안 쓰인다"는 **거짓**입니다.
- ⚠️ 다만 **일부 모델은 남용 탐지(abuse detection) 목적으로 입출력을 최대 30일 보관**합니다. 남용 탐지는 **서비스 개선과 별개**이고 옵트아웃 정책의 적용 대상도 아닙니다.

> 🧠 **원리** — 요구사항이 "우리 데이터가 모델 학습에 쓰이지 않아야 한다"일 때 **고를 설정이 없는 것이 정답**인 경우가 있습니다. 이 기술에서 실제로 구성하는 것은 **전송 경로**(사설 연결)와 **보관되는 로그**(2.3.5)이고, 학습 미사용은 서비스가 이미 보장합니다.

### 4) Guardrails — 보호 장치 고르기 (기술 2.3.3) {#guardrails}

| 보호 장치 | 하는 일 |
|---|---|
| **콘텐츠 필터** | 유해 텍스트·이미지 탐지·필터링. 사전 정의 범주 **6종** — Hate · Insults · Sexual · Violence · Misconduct · **Prompt Attack**. 범주별 **강도 조절** |
| └ **프롬프트 공격** | ⚠️ **콘텐츠 필터 안의 한 범주**입니다(별도 보호 장치가 아닙니다). **탈옥(jailbreak) · 프롬프트 인젝션 · 프롬프트 유출** 탐지 |
| **거부 주제** | 애플리케이션 맥락에서 원치 않는 **주제**를 정의해 차단(예: 금융 앱의 불법 투자 조언) |
| **단어 필터** | 사용자 지정 단어·구문 **정확 일치** 차단. 욕설은 기성 옵션 제공 |
| **민감 정보 필터** | PII(표준 형식) 또는 **사용자 지정 정규식** 탐지 → **차단 또는 마스킹** 선택. 확률적 ML 기반이고 **맥락 의존적** |
| **맥락 근거 확인** | 근거 없는(환각) 응답 탐지 |
| **자동 추론 확인** | 구조화된 수학적 지식 표현과 대조해 사실 부정확성 탐지 |

- ⚠️ **표준(Standard) 티어에서는 콘텐츠 필터·거부 주제 탐지가 코드 요소 안**(주석·변수·함수 이름·문자열 리터럴)**까지 확장**됩니다. 추론(reasoning) 콘텐츠 블록은 평가 대상에서 제외됩니다.

> 🧠 **원리** — 보호 장치는 **탐지 방식이 다릅니다.** 단어 필터는 **문자열 일치**(결정적), 거부 주제는 **주제 분류**, 민감 정보 필터는 **확률적 ML**입니다. 그래서 "특정 경쟁사 이름을 반드시 막아야 한다"면 단어 필터이고, "투자 조언 전반을 막아야 한다"면 거부 주제입니다. 확률적 통제에 **정확한 차단**을 기대하면 안 됩니다.

### 5) 적용 방식 — 인라인과 `ApplyGuardrail` (기술 2.3.3) {#apply-guardrail}

1. **인라인** — 추론 API 호출에 **guardrail ID·버전을 지정**합니다.
2. **독립 실행 — `ApplyGuardrail` API** — ⚠️ **파운데이션 모델을 호출하지 않고** 임의의 텍스트를 평가합니다.
   - 입력과 출력을 **따로** 평가할 수 있습니다.
   - RAG라면 **검색 전에** 사용자 입력을 먼저 검사할 수 있습니다.
   - 모델과 **분리돼 있어** **Bedrock 밖 모델**(자체 호스팅·서드파티)의 트래픽에도 쓸 수 있습니다.

> 🧠 **원리** — 가드레일을 **모델 호출에서 떼어내면** 적용 지점을 자유롭게 고를 수 있습니다. 그래서 "우리 자체 LLM에도 같은 정책을" 또는 "검색을 돌리기 전에 먼저 거르고 싶다"는 요구는 **`ApplyGuardrail`**로 풀립니다. 인라인은 간단한 대신 Bedrock 모델 호출에 묶입니다.

### 6) 에이전트 — 도구 권한과 사람 승인 (기술 2.3.4) {#agent-approval}

Skill이 든 예시 세 가지 중 **도구 사용 권한 부여**와 **사람 승인 흐름**이 여기에 해당합니다.

- **사용자 확인(user confirmation)**: 작업 그룹을 구성할 때 특정 작업에 켭니다. 켜면 에이전트가 **확인 질문을 던지고** 사용자가 승인·거부합니다. ⭐ **공식 문서가 이 기능의 목적을 프롬프트 인젝션 방어로 직접 적습니다** — 응답에 섞여 들어온 지시를 에이전트가 그대로 따르는 것을 **사람이 끊습니다.**
- **제어 반환(return of control)**: 작업 그룹의 `actionGroupExecutor`에 **`customControl = RETURN_CONTROL`**을 지정하면, Lambda로 넘기는 대신 **`InvokeAgent` 응답의 `invocationInputs`**로 호출 정보를 돌려줍니다(고유 `invocationId` 동반). 애플리케이션이 직접 실행한 뒤 **같은 `invocationId`·`actionGroup`**으로 `sessionState`에 결과를 실어 다시 보냅니다.
- ⚠️ `sessionState`에 `returnControlInvocationResults`를 넣으면 **`inputText`는 무시됩니다.**

> 🧠 **원리** — 두 기능은 **끊는 지점이 다릅니다.** 사용자 확인은 **사람에게 묻고**, 제어 반환은 **실행 주체를 애플리케이션으로 옮깁니다.** 그래서 "민감 작업 전에 승인"은 사용자 확인이고, "우리 시스템이 직접 실행해야 한다"(권한·감사 때문에)는 제어 반환입니다.

### 7) 세션 격리 — AgentCore (기술 2.3.4) {#session-isolation}

- **AgentCore Identity**는 **인바운드 인증**(IAM 또는 외부 IdP의 JWT로 호출자 검증)과 **아웃바운드 인증**(에이전트가 외부 서비스에 쓸 자격 증명 관리)을 나눠 다룹니다.
- 다중 홉(Gateway → Runtime → Gateway → Target)에서 세션 동일성은 **Workload Identity Chain(WIC)**으로 보존됩니다. Gateway가 `sessionId`와 `callerPrincipal`을 담은 **Workload Access Token(WAT)**을 발급하고 Runtime이 교환하며 체인을 늘립니다.
- 호출자는 **최초 요청에만** `x-amzn-bedrock-agentcore-policy-session-id`를 넘기면 되고, **에이전트 코드가 내부 WAT 헤더를 읽거나 전달할 필요가 없습니다.** ⚠️ **세션 ID가 WAT 안에 실려 중간 경유지가 위조·변조할 수 없습니다.**

> 🧠 **원리** — 세션 격리의 핵심은 "누가 이 호출의 주인인가"를 **체인 끝까지 변조 불가능하게 운반하는 것**입니다. 애플리케이션이 세션 ID를 헤더로 직접 옮기면 중간에서 바꿀 수 있으므로, 토큰 안에 넣어 **서비스가 운반**합니다.

### 8) 모니터링 로그의 민감 콘텐츠 (기술 2.3.5) {#logs}

**모델 호출 로깅**

- ⚠️ **기본적으로 꺼져 있습니다.** 켜면 **호출 로그·모델 입력·모델 출력**이 수집됩니다.
- 대상은 **S3·CloudWatch Logs**(둘 다 가능)이고 **KMS 키로 암호화**할 수 있습니다.
- ⚠️ **Guardrails를 걸어 둬도 이 로그에는 가드레일 이전의 사용자 입력이 담깁니다** — 즉 프롬프트·완성 로그에는 **민감 정보가 있다고 가정**해야 합니다.

**CloudWatch Logs 데이터 보호 정책**

- 선택한 데이터 식별자와 일치하는 민감 데이터가 **모든 송출 지점**(Logs Insights · 지표 필터 · 구독 필터)에서 마스킹됩니다.
- 마스킹 해제는 **`logs:Unmask`** 권한자만 가능합니다(`GetLogEvents`·`FilterLogEvents`의 `unmask` 파라미터, Insights의 `unmask` 명령).
- **계정 수준**(`PutAccountPolicy`)과 **로그 그룹 수준**(`PutDataProtectionPolicy`)이 있고 둘 다 걸리면 **누적**됩니다. 로그 그룹당 그룹 수준 정책은 **1개**이고 길이 상한은 **30,720자**입니다.
- **관리형 데이터 식별자**(금융·PHI·PII)와 **사용자 지정 식별자**를 쓸 수 있습니다. ⚠️ 일부 관리형 식별자는 **근처에 특정 키워드가 함께 있어야** 탐지됩니다.
- ⚠️ **탐지·마스킹은 수집(ingest) 시점**에 일어납니다 — **정책을 걸기 전에 들어온 로그 이벤트는 마스킹되지 않습니다.**
- 탐지 시 `AWS/Logs` 네임스페이스에 **`LogEventsWithFindings`** 지표가 로그 그룹별로 발행됩니다. 감사 결과는 CloudWatch Logs·S3·**Data Firehose**로 보낼 수 있습니다.

> 🧠 **원리** — 가드레일은 **모델에 들어가고 나오는 것**을 막고, 로그 보호는 **기록된 것**을 막습니다. 두 통제는 적용 지점이 달라 **서로를 대체하지 못합니다** — 그래서 "가드레일을 켰으니 로그도 안전하다"가 성립하지 않습니다.

---

## ✍️ 시험 포인트

- **"입출력이 모델 학습에 쓰이지 않게 하려면?"** → **설정이 아니라 서비스 약속**입니다. **옵트아웃 정책을 고르는 보기는 오답**입니다. 단 남용 탐지 **30일 보관**은 별개입니다.
- **"인터넷을 거치지 않고 Bedrock을 호출"** → **인터페이스 VPC 엔드포인트**(PrivateLink), `com.amazonaws.<region>.bedrock-runtime`.
- **"프롬프트 인젝션을 막으려면?"** → Guardrails **콘텐츠 필터의 Prompt Attack 범주**. 에이전트라면 **사용자 확인**이 함께 나옵니다.
- **"Bedrock 밖 모델에도 같은 안전장치"** → **`ApplyGuardrail`** API.
- **"로그에 PII가 남는다"** → 모델 호출 로깅은 **가드레일 이전 입력**을 담습니다 → **데이터 보호 정책 + `logs:Unmask` 분리 + KMS 암호화**.
- **"민감 작업 전에 사람이 승인"** → 작업 그룹의 **사용자 확인**. **"우리 시스템이 직접 실행"** → **제어 반환**.
- **`AccessDeniedException`** → **Marketplace 권한 · Anthropic FTU 양식 · 결제 수단** 셋을 봅니다. 상태는 `GetFoundationModelAvailability`로 확인합니다.
- ⛔ **모델 선택·프롬프트 엔지니어링·RAG 설계·가드레일 설계를 묻는 보기는 범위 밖 신호**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 콘솔에서 모델 액세스를 "요청"해야 한다고 본다 | 지금은 **기본 허용 + 첫 호출 시 자동 구독**이다. 막히면 Marketplace 권한·FTU·결제 수단을 본다 |
| 옵트아웃 정책으로 Bedrock 학습 사용을 끈다 | ⚠️ **Bedrock은 그 정책의 대상이 아니다** — 끌 설정이 없다(이미 쓰지 않는다) |
| 남용 탐지 보관을 "학습에 쓴다"로 읽는다 | **별개**다. 일부 모델이 **최대 30일** 보관하며 서비스 개선과 무관 |
| VPC 엔드포인트 호출에 `aws:SourceIp` 조건을 건다 | ⚠️ 그 요청에는 **`aws:SourceIp`가 없다** — 조건이 충족될 수 없다 |
| 프롬프트 공격을 별도 보호 장치로 본다 | **콘텐츠 필터 안의 한 범주**다 |
| 단어 필터와 거부 주제를 같은 것으로 본다 | 단어 필터는 **정확 일치**, 거부 주제는 **주제 단위** |
| 민감 정보 필터가 100% 결정적이라고 본다 | **확률적 ML 기반이고 맥락 의존적**이다 |
| 자체 호스팅 모델에는 Guardrails를 못 쓴다고 본다 | **`ApplyGuardrail`**은 모델과 분리돼 있어 쓸 수 있다 |
| 가드레일을 켰으니 로그도 안전하다고 본다 | 모델 호출 로그에는 **가드레일 이전 입력**이 담긴다 |
| 로그 마스킹이 과거 로그에도 적용된다고 본다 | **수집 시점** 처리라 **소급되지 않는다** |
| 사용자 확인과 제어 반환을 혼동한다 | 전자는 **사람에게 묻고**, 후자는 **앱에 실행을 넘긴다** |
| 제어 반환 응답에 `inputText`를 함께 보낸다 | `returnControlInvocationResults`가 있으면 **`inputText`는 무시된다** |
| 에이전트 코드가 세션 ID 헤더를 직접 전달해야 한다고 본다 | **최초 요청에만** 넘기면 되고, 이후는 **WAT가 운반**한다 |
| 가드레일 정책 설계를 시험 범위로 본다 | ⛔ **설계·거버넌스 구현은 범위 밖**이다 — 제공되는 통제를 **적용**하는 것이 범위다 |

---

## 🧪 자가 점검

**Q1.** Bedrock 호출이 `AccessDeniedException`을 돌려준다. 리전은 지원되고 모델도 카탈로그에 있다. 가장 먼저 확인할 세 가지는? (→ 1) 모델 접근)

<details><summary>정답 보기</summary>

① IAM 역할에 **`aws-marketplace:Subscribe`·`Unsubscribe`·`ViewSubscriptions`**가 있는지 ② **Anthropic 모델이면 최초 사용(FTU) 양식**을 냈는지 ③ **유효한 결제 수단**이 있는지입니다.

접근 자체는 **기본 허용**이고 **첫 호출이 구독을 자동으로 시작**합니다(설정 최대 15분, 권한 부여 후 완료까지 최대 2분). 전제 조건이 빠지면 구독이 실패해 이후 호출이 거부됩니다. ⚠️ FTU 제출 후 계약이 **보류 상태**일 수 있으므로 **`GetFoundationModelAvailability`의 `agreementAvailability`**로 상태를 확인합니다. 관리 계정의 제출은 같은 Organization의 다른 계정에 **상속**됩니다.
</details>

**Q2.** 프롬프트를 인터넷으로 내보내지 않으면서 특정 모델 ARN만 쓰게 하려 한다. 무엇을 구성하고, 함께 쓰면 안 되는 IAM 조건은? (→ 1) 모델 접근 · 2) 사설 연결)

<details><summary>정답 보기</summary>

**인터페이스 VPC 엔드포인트(PrivateLink)**를 `com.amazonaws.<region>.bedrock-runtime` 서비스 이름으로 만들고, **엔드포인트 정책**으로 특정 **모델 ARN과 보안 주체만** 허용합니다. 활성화한 **서브넷마다 엔드포인트 네트워크 인터페이스**가 생기고 인스턴스에 **퍼블릭 IP가 필요 없습니다.** 모델 단위 통제는 IAM에서도 `arn:aws:bedrock:<region>::foundation-model/<model-id>`에 `bedrock:InvokeModel`·`InvokeModelWithResponseStream`을 Allow·Deny로 걸 수 있습니다.

함께 쓰면 안 되는 것은 ⚠️ **`aws:SourceIp`에 대한 `IpAddress` 조건**입니다 — **VPC 엔드포인트를 통한 요청에는 `aws:SourceIp`가 아예 없어** 그 조건은 **충족될 수 없습니다.** 사설 경로에서 범위를 좁히는 수단은 IP 조건이 아니라 **엔드포인트 정책과 IAM의 모델 ARN**입니다.
</details>

**Q3.** 자체 호스팅 LLM에 조직의 거부 주제 정책을 그대로 적용하려 한다. 무엇을 쓰는가? (→ 5) 적용 방식)

<details><summary>정답 보기</summary>

**`ApplyGuardrail` API**입니다 — **파운데이션 모델을 호출하지 않고** 임의의 텍스트를 평가하므로 모델과 분리돼 있고, 그래서 **Bedrock 밖 모델**(자체 호스팅·서드파티)의 트래픽에도 같은 guardrail을 적용할 수 있습니다. 입력과 출력을 **따로** 평가할 수 있고, RAG라면 **검색 전에** 사용자 입력을 먼저 검사할 수 있습니다.

인라인 방식(추론 API 호출에 guardrail ID·버전 지정)은 간단하지만 **Bedrock 모델 호출에 묶입니다.**
</details>

**Q4.** 에이전트가 외부 응답에 섞인 지시를 따라 DB를 수정하려 한다. 코드 변경을 최소화하면서 막으려면? 그리고 "우리 시스템이 직접 실행해야 한다"면? (→ 6) 에이전트)

<details><summary>정답 보기</summary>

**작업 그룹의 사용자 확인(user confirmation)**을 그 작업에 켭니다 — 에이전트가 **확인 질문을 던지고** 사람이 승인·거부합니다. ⭐ **공식 문서가 이 기능의 목적을 프롬프트 인젝션 방어로 직접 적습니다**(응답에 섞여 들어온 지시를 사람이 끊습니다). 설정만으로 되므로 코드 변경이 가장 적습니다.

"우리 시스템이 직접 실행"이면 **제어 반환**입니다 — `actionGroupExecutor`에 **`customControl = RETURN_CONTROL`**을 지정하면 Lambda로 넘기지 않고 **`InvokeAgent` 응답의 `invocationInputs`**로 호출 정보를 돌려줍니다. 앱이 실행한 뒤 같은 `invocationId`로 결과를 `sessionState`에 실어 보냅니다. ⚠️ 그때 `returnControlInvocationResults`가 있으면 **`inputText`는 무시됩니다.**
</details>

**Q5.** 운영팀은 Bedrock 호출 로그를 읽어야 하지만 PII는 보면 안 되고, 보안팀만 원본을 봐야 한다. 어떻게 구성하는가? (→ 8) 로그)

<details><summary>정답 보기</summary>

① **모델 호출 로깅을 켜고**(기본 꺼짐) 대상을 CloudWatch Logs·S3로 정하며 **KMS 키로 암호화**합니다. ② 로그 그룹에 **데이터 보호 정책**을 걸어 관리형·사용자 지정 식별자로 PII를 **마스킹**합니다 — 마스킹은 Logs Insights·지표 필터·구독 필터 등 **모든 송출 지점**에 적용됩니다. ③ **`logs:Unmask` 권한을 보안팀에만** 줍니다.

⚠️ 두 가지를 전제해야 합니다 — **Guardrails를 걸어 둬도 이 로그에는 가드레일 이전의 사용자 입력이 담기고**, **마스킹은 수집 시점 처리라 정책을 걸기 전 로그는 가려지지 않습니다.** 계정 수준과 로그 그룹 수준 정책은 **누적**되며 로그 그룹당 그룹 정책은 1개입니다.
</details>

**Q6.** 보안 검토에서 "입출력이 모델 학습에 쓰이지 않도록 옵트아웃 정책을 적용하라"는 요구가 왔다. 어떻게 답하는가? (→ 3) 학습 미사용)

<details><summary>정답 보기</summary>

**Bedrock은 그 정책의 대상 서비스가 아닙니다** — 공식 문서가 "Amazon Bedrock does not use your inputs or outputs to train models or to improve the service, and does not share them with model providers."라고 적고, **끌 설정이 없기 때문**입니다. 그래서 "옵트아웃 정책을 적용해야 학습에 안 쓰인다"는 서술은 거짓입니다.

다만 ⚠️ **일부 모델은 남용 탐지 목적으로 입출력을 최대 30일 보관**하며, 이것은 서비스 개선과 별개이고 옵트아웃 대상도 아닙니다. 이 기술에서 실제로 구성할 것은 **전송 경로**(인터페이스 VPC 엔드포인트)와 **로그 보호**(2.3.5)입니다.
</details>

**Q7.** "경쟁사 이름은 반드시 차단"과 "투자 조언 전반은 응답하지 않기"라는 두 요구가 있다. 각각 어떤 보호 장치인가? (→ 4) Guardrails)

<details><summary>정답 보기</summary>

"경쟁사 이름"은 **단어 필터**입니다 — 사용자 지정 단어·구문의 **정확 일치**를 차단합니다. "투자 조언 전반"은 **거부 주제**입니다 — 애플리케이션 맥락에서 원치 않는 **주제**를 정의해 차단합니다(공식 예시가 금융 앱의 불법 투자 조언입니다).

⚠️ 둘을 섞으면 안 됩니다. 단어 필터는 **문자열 일치**라 변형 표기를 놓치고, 거부 주제는 **주제 분류**라 특정 단어의 확실한 차단을 보장하지 않습니다. 그리고 **민감 정보 필터는 확률적 ML 기반이고 맥락 의존적**이라 역시 결정적 차단 수단이 아닙니다.
</details>

---

### 📌 출처

1. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
2. Access Amazon Bedrock foundation models — https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html
3. Use interface VPC endpoints (AWS PrivateLink) with Amazon Bedrock — https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html
4. Opting out of using your data for service improvement — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/omni-opting-out-of-using-your-data-for-service-improvement.html
5. Amazon Bedrock Guardrails — https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html
6. Components of a guardrail — https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-components.html
7. Use the ApplyGuardrail API independently — https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-use-independent-api.html
8. Get user confirmation before invoking action group function — https://docs.aws.amazon.com/bedrock/latest/userguide/agents-userconfirmation.html
9. Return control to the agent developer — https://docs.aws.amazon.com/bedrock/latest/userguide/agents-returncontrol.html
10. AgentCore Identity (콘솔 도움말) — https://docs.aws.amazon.com/help-panel/bedrock-agentcore/latest/console/hp-identity.html
11. AgentCore 정책 세션·ID 전파(WIC·WAT) — https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/policy-session-based-temporal.html
12. Monitor model invocation using CloudWatch Logs and Amazon S3 — https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
13. Help protect sensitive log data with masking (CloudWatch Logs) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data.html
