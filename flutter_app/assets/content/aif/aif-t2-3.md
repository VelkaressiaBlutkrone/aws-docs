---
examGuideTaskId: aif-t2-3
certCode: AIF-C01
domain: 2
domainName: GenAI의 기초
domainWeightPct: 24
title: GenAI 애플리케이션을 위한 AWS 인프라와 기술 (서비스 선택·이점·인프라 보증·비용 절충)
coversTasks:
  - "2.3"
sources:
  - title: Amazon Bedrock Overview
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html
  - title: What is Amazon Quick?
    url: https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
  - title: What is Amazon SageMaker AI?
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html
  - title: SageMaker JumpStart pretrained models
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html
  - title: What is Amazon Bedrock AgentCore?
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html
  - title: Strands Agents (AWS Prescriptive Guidance)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/strands-agents.html
  - title: Machine Learning (ML) and Artificial Intelligence (AI) — AWS 서비스 개요 백서 (Kiro)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-overview/machine-learning.html
  - title: Amazon Bedrock Agents Classic maintenance mode
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html
  - title: Amazon Bedrock or Amazon SageMaker AI?
    url: https://docs.aws.amazon.com/decision-guides/latest/decision-guides/bedrock-or-sagemaker.html
  - title: Choosing a generative AI service
    url: https://docs.aws.amazon.com/decision-guides/latest/decision-guides/genai-guide.html
  - title: Data protection (Amazon Bedrock)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/data-protection.html
  - title: Protect your data using Amazon VPC and AWS PrivateLink
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/usingVPC.html
  - title: Compliance validation for Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/compliance-validation.html
  - title: Amazon Bedrock FAQs
    url: https://aws.amazon.com/bedrock/faqs/
  - title: Detect and filter harmful content by using Amazon Bedrock Guardrails
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html
  - title: Set up inference for a custom model (Amazon Bedrock) — 프로비저닝 처리량과 온디맨드 배포 두 경로
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html
  - title: "Responsible AI: From principles to practice"
    url: https://aws.amazon.com/ai/responsible-ai/
  - title: Increase model invocation capacity with Provisioned Throughput in Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html
  - title: Process multiple prompts with batch inference
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html
  - title: Prompt caching for faster model inference
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html
  - title: Route model inference requests across AWS Regions with cross-Region inference
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html
  - title: Customize your model to improve its performance for your use case
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html
  - title: Amazon Bedrock (AWS Prescriptive Guidance — 추론 서비스 계층)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-inference-architecture-and-best-practices-on-aws/amazon-bedrock.html
  - title: AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain2.html
lastVerified: 2026-11-06
---

# GenAI 애플리케이션을 위한 AWS 인프라와 기술 (서비스 선택·이점·인프라 보증·비용 절충)

> **커버하는 공식 Task** — AIF-C01 · 도메인 2 「GenAI의 기초」(24%) · **작업 2.3 GenAI 애플리케이션을 구축하기 위한 AWS 인프라 및 기술 설명** (`aif-t2-3`)
> 공식 목표 4개(2.3.1~2.3.4)를 모두 덮습니다. 이 작업은 **"무엇을 만들 때 무엇을 고르는가"**와 **"왜 AWS에서 만드는가"**, 그리고 **"무엇을 포기하고 무엇을 얻는가"** 세 가지를 묻습니다.

> ⚠️ **가이드 v1.1에서 바뀐 것** — 목표 2.3.1의 **서비스 예시가 통째로 교체됐습니다.** v1.0의 `Amazon Bedrock PartyRock` · `Amazon Bedrock Data Automation` · `Amazon Q`가 빠지고 **`Amazon Bedrock` · `Amazon SageMaker AI` · `SageMaker JumpStart` · `Amazon Quick` · `Kiro` · `Strands Agents` · `Amazon Bedrock AgentCore`**가 들어왔습니다. 목표 2.3.4에도 **`토큰 기반 요금` · `프로비저닝 처리량` · `사용자 지정 모델`**이 추가됐습니다. 2026-04-30 이전 교재는 이 일곱 이름과 세 비용 축을 전부 빠뜨립니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 2.3.1의 서비스 일곱 개를 **"무엇을 만들 때 고르는가"**로 가른다
- [ ] `Amazon Bedrock` ↔ `Amazon SageMaker AI`를 **필요한 통제 수준**으로 갈라 고른다
- [ ] `Strands Agents`(SDK)와 `Amazon Bedrock AgentCore`(플랫폼)가 **층이 다르다**는 것을 설명한다
- [ ] `Amazon Quick` · `Kiro`가 **모델 서비스가 아니라는 것**과 Quick의 개명 관계를 안다
- [ ] AWS GenAI 서비스를 쓰는 이점 여섯 가지를 공식 서술로 설명한다
- [ ] 보안 · 규정 준수 · 책임 · 안전 각각에 대응하는 AWS 장치를 하나씩 든다
- [ ] 온디맨드 · 배치 · 프로비저닝 처리량 · 프롬프트 캐싱 · 교차 리전 추론을 **비용 절충 축**으로 고른다

---

## 🎯 왜 중요한가

도메인 2는 전체의 **24%**로 가장 큰 도메인 중 하나이고, 그 안에서 2.3은 **유일하게 서비스 이름을 직접 묻는** 작업입니다. 작업 2.1은 개념(토큰·임베딩·에이전트), 2.2는 장단점이고, **AWS 서비스를 고르게 하는 문항은 여기로 모였습니다.**

주의할 점이 둘 있습니다. 첫째, **v1.1이 이 목록을 갈아 치웠습니다.** 2023~2024년 교재로 공부하면 `Amazon Q`를 고르게 되는데 그 이름은 **v1.1 범위 내 목록 본문에 없습니다.** 둘째, 이 작업은 **구축 방법을 묻지 않습니다.** 공식 가이드가 대상 응시자를 "AI/ML 솔루션을 사용해야 하지만 반드시 구축할 필요는 없다"고 적으므로, 문항은 **역할 매칭**과 **절충 판단**으로만 나옵니다.

> 파이프라인 단계별 서비스 배치(S3 → Glue → SageMaker AI → CloudWatch)와 관리형 API ↔ 자체 호스팅 대비는 **작업 1.3에서 이미 다뤘습니다.** 이 문서는 겹치지 않게 **GenAI 전용 서비스 선택 · AWS를 쓰는 이점 · 비용 절충 축**에 분량을 씁니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **Bedrock은 "모델을 API로 쓰는 쪽", SageMaker AI는 "모델을 만들고 호스팅하는 쪽"**입니다. 공식 결정 가이드가 **"Bedrock으로 시작해 사용자 지정 요구가 커지면 SageMaker AI로 넘어가는 것이 일반적 경로"**라고 적습니다
- **`Strands Agents`는 오픈소스 SDK**이고 관리형 서비스가 아닙니다. **`Amazon Bedrock AgentCore`가 그 코드를 운영하는 플랫폼**이고 "인프라 관리 없이" 돌립니다 — **경쟁이 아니라 층이 다릅니다**
- ⚠️ **`Amazon Bedrock Agents`는 `Agents Classic`으로 개명되고 2026-07-30부터 신규 고객을 받지 않습니다.** 에이전트 구축의 정본은 **AgentCore**입니다. Bedrock 모델 · Knowledge Bases · Guardrails는 **영향 없습니다**
- **`Amazon Quick`은 Amazon QuickSight의 개명**입니다 — "QuickSight는 **Quick 안의 기능인 Amazon Quick Sight**로 이어진다"이고 **기존 API·SDK는 변경 없이 동작**합니다
- **`Kiro`는 "AWS의 에이전틱 개발 시스템"**입니다 — **개발 도구**이고 모델 서비스가 아닙니다
- **`SageMaker JumpStart`는 SageMaker AI 안의 ML 허브**입니다. 사전 훈련 공개 모델 · **솔루션 템플릿** · 예제 노트북을 줍니다. ⚠️ 2024-12-03 **개명은 기능 이름에 적용되지 않으므로** `SageMaker AI JumpStart`가 아닙니다
- **AWS를 쓰는 이점의 핵심은 "ML 전문성 없이도 쓸 수 있다"**입니다 — 공식은 Bedrock을 "ML 전문성이나 리소스가 제한적일 때 특히 유용"하다고 적고 필요 전문성을 **"사전 훈련 모델을 쓰는 데 필요한 기본 수준"**으로 적습니다
- ⚠️ **사용자 지정 모델의 추론 설정은 둘입니다** — **프로비저닝 처리량 구매**와 **온디맨드 추론용 배포**. 공식은 온디맨드 쪽을 **"쓴 만큼만 내고 프로비저닝된 컴퓨팅 리소스를 설정할 필요가 없다"**고 적습니다. 프로비저닝 처리량은 과금이 **모델 단위(MU) × 시간**이고 약정은 **무약정 · 1개월 · 6개월**입니다
- ⚠️ **프롬프트 캐싱은 배치 추론과 함께 못 씁니다** — "온디맨드 추론 엔드포인트에서만 지원되고 배치 추론 API에서는 지원되지 않는다". 그리고 **배치 추론은 프로비저닝된 모델도 지원하지 않습니다**
- **교차 리전 추론은 데이터 상주성과 비용을 맞바꿉니다** — **지리적(Geographic)**은 US·EU·APAC 경계 안에서만 라우팅하고 **글로벌(Global)**은 전 세계 상용 리전으로 라우팅하면서 **약 10% 절감**입니다. **규정 준수 요구가 있으면 지리적**을 고릅니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **파운데이션 모델(FM)** | 광범위한 데이터로 사전 훈련돼 여러 작업을 그대로 수행하는 대규모 모델. Bedrock이 API로 제공합니다 |
| **서버리스** | 인프라를 프로비저닝·관리하지 않는 운영 형태. **공식 결정 가이드**가 Bedrock을 "서버리스이므로 인프라를 관리하지 않아도 된다"고 적습니다(`bedrock-or-sagemaker.html` — ⚠️ **개요 페이지가 아닙니다.** 그쪽은 Quickstart로 재구성돼 「서버리스」가 0건입니다) |
| **토큰 기반 요금** | 처리된 **입력·출력 토큰** 수로 과금하는 모델. Bedrock 온디맨드의 과금 축입니다 |
| **모델 단위(MU)** | 프로비저닝 처리량의 과금·용량 단위. **1분 동안 처리할 입력 토큰 수와 생성할 출력 토큰 수**를 정합니다 |
| **프로비저닝 처리량(PT)** | 고정 비용으로 더 높은 처리량을 확보하는 방식. **시간당 과금**이고 사용자 지정 모델에도 쓸 수 있습니다 — 다만 **필수는 아닙니다**(온디맨드 추론용 배포 경로가 따로 있습니다) |
| **배치 추론** | 프롬프트 파일을 S3에 올리고 **비동기로** 다수 응답을 받는 방식. 대규모 데이터셋에 쓰는 처리 모드입니다 |
| **프롬프트 캐싱** | 길고 반복되는 프롬프트 **접두부**를 재사용해 지연과 **입력 토큰 비용**을 줄이는 선택적 기능 |
| **추론 서비스 계층** | `Reserved` · `Priority` · `Standard` · `Flex` 네 가지. 모델·API를 바꾸지 않고 **가용성·지연·비용을 맞바꿉니다** |
| **교차 리전 추론(CRIS)** | 요청을 여러 AWS 리전의 컴퓨팅으로 라우팅해 처리량을 높이는 추론 프로필 |
| **에이전틱 개발 시스템** | 공식이 `Kiro`를 가리킬 때 쓰는 범주 — 코드를 쓰는 사람을 돕는 **개발 도구**입니다 |

---

## 📖 핵심 개념

### 1) GenAI 개발을 위한 AWS 서비스와 기능 (목표 2.3.1) {#services}

이 목표의 전부는 **"무엇을 만들 때 무엇을 고르는가"**입니다. 일곱 이름을 역할로 세워 둡니다.

| 만들려는 것 | 고르는 것 | 공식이 적는 정체 |
|---|---|---|
| FM을 **API로 호출**해 애플리케이션·에이전트를 돌린다 | `Amazon Bedrock` | **"선도 AI 기업의 고성능 파운데이션 모델에 안전한 엔터프라이즈급 접근을 제공하는 완전관리형 서비스"** |
| 모델을 **훈련·사용자 지정·배포**하며 통제를 쥔다 | `Amazon SageMaker AI` | **"완전관리형 ML 서비스"** — 구축·훈련·배포를 프로덕션 규모로 |
| **사전 훈련 공개 모델**을 골라 시작한다 | `SageMaker JumpStart` | **"ML 여정을 가속하는 ML 허브"** — 사전 훈련 공개 모델 · 솔루션 템플릿 · 예제 노트북 |
| 에이전트를 **안전하게 규모로 운영**한다 | `Amazon Bedrock AgentCore` | **"어떤 프레임워크와 파운데이션 모델로든 매우 효과적인 에이전트를 안전하게 규모로 구축·배포·운영하는 에이전틱 플랫폼"** |
| 에이전트를 **코드로 짠다** | `Strands Agents` | **"AWS가 처음 공개한 오픈소스 SDK"** — 모델 우선(model-first) 설계 |
| 데이터를 **분석·시각화**하고 업무를 자동화한다 | `Amazon Quick` | **"작업 자동화, 데이터 분석, 웹 애플리케이션 구축, 리서치를 위한 AI 기반 서비스"** |
| **코드를 쓰는 작업**을 에이전트에게 맡긴다 | `Kiro` | **"AWS의 에이전틱 개발 시스템"** — IDE · CLI · 자율 웹 에이전트 형태 |

**Bedrock ↔ SageMaker AI는 "통제 수준"으로 갈립니다.** 공식 결정 가이드의 서술이 그대로 문항 재료입니다.

| 축 | `Amazon Bedrock` | `Amazon SageMaker AI` |
|---|---|---|
| 용도 | 사용자 지정 모델 개발에 **크게 투자하지 않고** AI 애플리케이션·에이전트를 만든다 | 훈련·사용자 지정·배포를 **최대한의 통제**로 한다 |
| 대상 사용자 | 기술 의사 결정자 · 개발자 · 애플리케이션 팀 | ML 실무자 · ML 엔지니어 · 데이터 과학자 · AI 플랫폼 팀 |
| 필요 전문성 | **"사전 훈련 모델을 쓰는 데 필요한 기본 수준의 ML 전문성"** | ⚠️ **두 층입니다** — **"안내형 UI와 AI 에이전트 지원 워크플로가 커스터마이징을 단순하게 만들고"**, **고급 훈련 작업에는 더 깊은 ML 전문성**이 도움이 된다 |
| 요금 | 입력·출력 토큰 기반 **종량제**(+ Priority·Flex·Reserved 계층) | 서버리스 사용자 지정은 토큰 기반, 훈련·추론·HyperPod는 **컴퓨팅 사용량 기반** |
| 배포·호스팅 | **서버리스** — 인프라를 관리하지 않는다 | 전용 엔드포인트로 관리형 추론, 또는 Bedrock으로 서버리스 추론 |

가르는 질문 한 줄 — **"컨테이너나 오케스트레이션 계층에 손을 넣어 비용·지연·처리량을 직접 조절해야 하는가?"** 그래야 한다면 SageMaker AI입니다. 공식이 든 예가 **"GPU 사용률을 최대화하면서 비용과 목표 처리량·지연을 맞추는 대규모 LLM 배포"**입니다. 그럴 필요가 없으면 Bedrock입니다. 그리고 공식은 **"둘 중 하나를 고르기보다 필요한 사용자 지정 수준을 보라"**고 하면서 **"Bedrock으로 시작해 사용자 지정 요구가 커지면 SageMaker AI로 나아가는 것이 일반적 경로"**라고 적습니다.

**에이전트 쪽은 층이 둘입니다.** `Strands Agents`는 **라이브러리**이고 `AgentCore`는 **플랫폼**입니다. AgentCore 공식 문서가 이 관계를 직접 적습니다 — AgentCore 서비스들은 **"CrewAI · LangGraph · LlamaIndex · Strands Agents 같은 어떤 오픈소스 프레임워크와도, 어떤 파운데이션 모델과도 함께 또는 독립적으로 동작한다."** 즉 Strands로 짠 에이전트를 AgentCore가 돌리는 구성이 정상이고, **Strands를 "AWS 관리형 에이전트 서비스"라고 하면 틀립니다.**

AgentCore의 모듈 중 시험 범위에서 의미 있는 것만 골라 둡니다.

| 모듈 | 하는 일 |
|---|---|
| **Runtime** | **세션 격리**된 서버리스 런타임. 동적 에이전트·도구를 배포·확장합니다 |
| **Memory** | 단기(여러 턴 대화)·장기(세션을 넘는 지속) 메모리를 **무엇을 기억할지 통제**하며 둡니다 |
| **Gateway** | API·Lambda·기존 서비스를 **MCP 호환 도구로 변환**해 에이전트에 제공합니다 |
| **Identity** | 에이전트의 ID·접근·인증 관리. **기존 자격 증명 공급자와 호환**됩니다 |
| **Policy** | 에이전트가 **정의된 경계와 업무 규칙 안에서** 움직이게 하는 결정적 통제. Gateway에서 **모든 도구 호출을 실행 전에 가로챕니다** |
| **Observability** | 프로덕션 에이전트의 추적·디버깅·모니터링을 한 화면에서 봅니다 |

> ⚠️ **이름이 비슷한 두 서비스를 섞으면 안 됩니다.** `Amazon Bedrock Agents`는 **`Amazon Bedrock Agents Classic`으로 개명**됐고 공식 문서 첫 문장이 **"2026년 7월 30일부터 신규 고객에게 열리지 않는다"**고 적습니다. 같은 페이지가 범위를 좁혀 둡니다 — **"Amazon Bedrock은 계속 완전히 지원된다. Agents Classic 서비스만 신규 고객에게 열리지 않으며, 기존 Bedrock 모델·Knowledge Bases·Guardrails는 영향을 받지 않는다."** 그래서 **"에이전트를 새로 만든다"는 지문의 정답은 AgentCore**입니다.

> ⚠️ **`Amazon Quick`의 이름이 함정입니다.** 공식 메모가 **"Amazon Quick은 Amazon QuickSight에서 진화했다. QuickSight는 Quick 안의 기능인 Amazon Quick Sight로 이어진다"**고 적고 **"기존 QuickSight API·SDK·통합은 변경 없이 계속 동작한다"**를 덧붙입니다. Quick의 기능은 `Amazon Quick Sight`(시각화·BI) · `Amazon Quick Flows` · `Amazon Quick Automate` · `Amazon Quick Index` · `Amazon Quick Research` · `Apps in Amazon Quick` 여섯입니다. **`Amazon QuickSight`는 개명 전 이름이고, 띄어 쓰지 않는 표기를 현재 기능명으로 쓰지 않습니다.**

### 2) AWS GenAI 서비스로 만들 때의 이점 (목표 2.3.2) {#benefits}

목표가 든 여섯 낱말에 공식 서술을 하나씩 붙입니다. **암기할 것은 낱말이 아니라 "그 이점이 어디서 나오는가"**입니다.

| 목표의 낱말 | 어디서 나오는가 | 공식 근거 |
|---|---|---|
| **접근성** | 모델을 **API 호출 하나**로 쓴다. 모델 독립적인 단일 API라 모델을 바꿔도 **코드 변경이 최소**다 | Bedrock은 "보안·프라이버시·책임 있는 AI를 갖춘 GenAI 애플리케이션 구축에 필요한 것"을 제공하며 "모델 독립적인 단일 API 접근"을 준다(정본은 **생성형 AI 결정 가이드** `genai-guide.html`의 `model-independent, single API access`) |
| **낮은 진입 장벽** | 필요한 ML 전문성이 **기본 수준**이다. Quick은 "프로비저닝할 인프라도, 호스팅할 모델도, 필요한 ML 전문성도 없다" | Bedrock은 **"ML 전문성이나 리소스가 제한적일 때 특히 유용"**하다 |
| **효율성** | AWS가 **프로비저닝·확장·유지 보수를 포함한 인프라 수명 주기 전체를 관리**해 팀이 애플리케이션 개발에 집중한다 | "AWS가 수요 패턴에 따라 용량을 자동 조정"한다 |
| **비용 효과** | **종량제**다. 처리된 입력·출력 토큰으로 과금하고 선행 약정이 필요 없다(절충은 목표 2.3.4) | Bedrock 요금은 "API 소비 기반의 유연한 요금" |
| **출시 소요 시간** | 사전 훈련 모델로 **바로 실험**하고, 모델 교체·최신 버전 업그레이드가 쉽다 | GenAI가 **"수동으로는 불가능한 양의 변형과 개념을 더 빠르게 실험"**하게 한다 |
| **비즈니스 목표 달성 능력** | 사용자 지정(미세 조정·증류·가져오기)과 RAG로 **우리 데이터에 맞춘** 경험을 만든다 | 모델 사용자 지정이 **"차별화되고 개인화된 사용자 경험"**을 준다 |

> 🧠 가르는 질문 — **"이 이점이 서비스에서 오는가, 아니면 우리 팀이 한 일에서 오는가?"** AWS가 주는 것은 **모델 접근 · 관리형 인프라 · 종량제 · 안전장치**이고, **정확도와 비즈니스 성과는 데이터와 평가 설계에서 옵니다.** "AWS GenAI 서비스를 쓰면 모델이 할루시네이션을 일으키지 않는다" 같은 보기는 이 구분으로 걸러집니다.

### 3) AWS 인프라의 이점 — 보안·규정 준수·책임·안전 (목표 2.3.3) {#infrastructure}

네 낱말에 **범위 내 서비스**를 하나씩 붙입니다.

**보안.** 공식이 적는 축이 셋입니다.

- **데이터 격리** — **"Amazon Bedrock이 처리하는 모든 고객 콘텐츠는 암호화되어 Bedrock을 사용하는 AWS 리전에 저장된다."** 그리고 **"사용자 입력과 모델 출력은 어떤 모델 공급자와도 공유되지 않는다."** Bedrock은 모델 공급자별 **모델 배포 계정**을 두는데, 공급자는 그 계정에 접근할 수 없어 **Bedrock 로그나 고객 프롬프트·완성에 접근하지 못합니다.**
- **네트워크 격리** — `Amazon VPC`로 트래픽을 통제하고, **`AWS PrivateLink` 인터페이스 VPC 엔드포인트**로 "데이터를 인터넷 트래픽에 노출하지 않고" VPC에서 Bedrock으로 **비공개 연결**을 만듭니다.
- **접근·암호화·감사** — `AWS IAM`으로 최소 권한을 주고 MFA를 쓰며, `AWS KMS` 기반 암호화 솔루션과 기본 보안 통제를 쓰고, **`AWS CloudTrail`로 API·사용자 활동 로깅**을 설정합니다. 통신은 **TLS 1.2가 요구 사항이고 TLS 1.3이 권장**입니다. S3의 민감 데이터 발견·보호에는 **`Amazon Macie`** 같은 관리형 보안 서비스를 씁니다.

**규정 준수.** 공식 문서가 세 가지를 적습니다 — ① 어떤 서비스가 특정 컴플라이언스 프로그램 범위에 드는지는 **「AWS services in Scope by Compliance Program」**에서 본다 ② **`AWS Artifact`로 제3자 감사 보고서를 내려받는다** ③ **"AWS 서비스를 쓸 때의 컴플라이언스 책임은 데이터의 민감도, 회사의 컴플라이언스 목표, 적용되는 법규로 결정된다."** 지속적 평가가 필요하면 `AWS Config` · `Amazon Inspector` · `AWS Trusted Advisor` · `AWS Well-Architected Tool`이 범위 내 도구입니다.

**책임.** **AWS 책임 있는 AI 페이지**는 책임 있는 AI를 **여덟 차원**으로 정의합니다 — **공정성 · 설명 가능성 · 프라이버시와 보안 · 안전 · 제어 가능성 · 진실성과 견고성 · 거버넌스 · 투명성.** 투명성 쪽에는 **AWS AI Service Cards**가 있어 AI 서비스·모델의 **의도된 사용 사례와 한계, 책임 있는 AI 설계 선택**을 한곳에서 찾게 합니다. 이 차원들과 거버넌스 실무는 **도메인 4의 작업 4.1·4.2**에서 본격적으로 다룹니다. ⚠️ **개수는 외우지 않습니다** — 위 여덟 개는 AWS 책임 있는 AI 페이지와 생성형 AI 렌즈의 분해이고, **Responsible AI Lens는 프라이버시와 보안, 진실성과 견고성을 각각 갈라 열 개**로 적습니다(둘 다 2026-11-03 실측). 공식이 **"we update over time"**이라고 적으므로 **차원이 몇 개인지를 묻는 문항은 성립하지 않습니다** — 작업 4.1·4.2가 그 분기를 자세히 다룹니다.

**안전.** 런타임 안전장치의 정본은 **`Amazon Bedrock Guardrails`**입니다. 공식은 **"안전한 생성형 AI 애플리케이션을 만들도록 돕는 구성 가능한 안전장치"**로 정의하고 필터 여섯 종을 적습니다.

| 필터 | 무엇을 막는가 |
|---|---|
| **Content filters** | 유해 텍스트·이미지. 공식 정의 절의 범주는 **Hate · Insults · Sexual · Violence · Misconduct**이고 범주별 강도를 설정합니다(프롬프트 공격은 **별도 정책**이지만 콘솔에서는 같은 화면에서 고릅니다 — **개수는 외우지 않습니다**) |
| **Denied topics** | 애플리케이션 맥락에서 바람직하지 않은 주제를 **질의와 응답 양쪽에서** 차단합니다 |
| **Word filters** | 사용자 정의 단어·구. **대소문자 무시 + 전체 단어·구 일치**이고 욕설은 기성 옵션입니다 |
| **Sensitive information filters** | PII를 **차단 또는 마스킹**합니다(SSN·생년월일·주소 등 + 사용자 정규식) |
| **Contextual grounding checks** | 응답이 소스에 **근거하지 않거나** 질의와 **무관한지** 탐지합니다 — RAG·요약의 할루시네이션 탐지 |
| **Automated Reasoning checks** | 응답의 정확성을 **논리 규칙 집합에 대해 검증**하고, 할루시네이션 탐지·수정 제안·진술되지 않은 가정을 짚습니다 |

> ⚠️ **Guardrails는 Bedrock 모델 전용이 아닙니다.** **`ApplyGuardrail` API로 파운데이션 모델을 호출하지 않고** 입력·출력만 평가할 수 있어, 자체 호스팅 모델에도 같은 안전·프라이버시 통제를 걸 수 있습니다. 그리고 가드레일을 만들면 **작업 드래프트**가 자동 생성되고, 만족스러우면 **버전**을 만들어 추론 시 **ID와 버전**을 넘겨 씁니다.
>
> ⚠️ **AWS 공동 책임 모델**이 데이터 보호에도 그대로 적용됩니다 — AWS는 클라우드를 돌리는 **글로벌 인프라**를 보호하고, 고객은 **그 인프라에 올린 콘텐츠의 통제와 쓰는 서비스의 보안 구성·관리**를 책임집니다. 이 모델 자체는 **공식 목표 5.1.1이 드는 항목**이므로 도메인 5에서 자세히 봅니다.

### 4) AWS GenAI 서비스의 비용 절충점 (목표 2.3.4) {#cost-tradeoffs}

이 목표의 낱말은 **비용 축(토큰 기반 요금 · 프로비저닝 처리량 · 사용자 지정 모델)**과 **맞바꾸는 품질 축(응답성 · 가용성 · 중복성 · 성능 · 리전 적용 범위)**으로 갈립니다. **절충이 핵심이므로 "무엇을 포기하는가"를 함께 외웁니다.**

⚠️ **단가는 외우지 않습니다.** 요금 페이지의 요율 표는 본문에 산문으로 적히지 않고, 프로비저닝 처리량의 **MU당 토큰 수조차 공식 문서가 적지 않고 "AWS 계정 매니저에게 문의"로 보냅니다.** 시험이 묻는 것은 **과금 단위와 모드 구분**입니다.

| 선택 | 과금 축 | 얻는 것 | 포기하는 것 |
|---|---|---|---|
| **온디맨드** | 처리된 **입력·출력 토큰** | 약정 없음, 즉시 시작 | 처리량이 모델별 공유 쿼터에 묶인다 |
| **배치 추론** | 토큰 | **대규모 데이터셋**에서 추론 성능을 높인다 | **응답성** — 프롬프트를 파일로 올리고 결과를 S3에서 받는 **비동기**다 |
| **프로비저닝 처리량(PT)** | **MU × 시간**(시간당 과금) | 고정 비용으로 **더 높은 처리량**. 사용자 지정 모델을 쓸 수 있다 | **탄력성** — 약정분은 기간 종료 전에 삭제할 수 없고 삭제할 때까지 과금이 이어진다 |
| **프롬프트 캐싱** | 캐시 읽기는 **캐시 읽기 요율** | **지연과 입력 토큰 비용**을 줄인다 | 확실성 — 캐시 히트가 **보장되지 않고**, 모델에 따라 **캐시 쓰기가 표준 입력 요율보다 비쌀 수 있다** |
| **교차 리전 추론 — 지리적** | 소스 리전 기준, **라우팅 추가 비용 없음** | US·EU·APAC **경계 안**에서 라우팅해 **데이터 상주성**을 지킨다 | 글로벌 대비 **비용 절감 폭** |
| **교차 리전 추론 — 글로벌** | 소스 리전 기준 | 전 세계 상용 리전으로 라우팅해 **약 10% 절감**과 최대 용량 | **지리적 제약** — 데이터 상주 규제가 있으면 쓸 수 없다 |
| **추론 서비스 계층** | 요청 시점 파라미터로 선택 | `Reserved` · `Priority` · `Standard` · `Flex`로 **가용성·지연·비용**을 모델·API 변경 없이 바꾼다 | Reserved는 **최소 약정**이 있는 별도 풀이다 |

**사용자 지정 모델의 비용은 세 겹입니다.**

1. **훈련 비용** — 공식이 과금 구조를 산문으로 적습니다: **"모델이 처리한 토큰 수(훈련 데이터 코퍼스의 토큰 수 × 에포크 수)를 기준으로 모델 훈련 요금이 청구되고, 모델 저장은 모델당 월 단위로 청구된다."**
2. **서빙 비용** — 추론 설정을 **둘 중에서** 고릅니다. **프로비저닝 처리량**을 사면 호출량이 적어도 **시간당 과금이 계속 발생**하고, **온디맨드 추론용 배포**를 고르면 공식이 적듯 **"쓴 만큼만 내고 프로비저닝된 컴퓨팅 리소스를 설정할 필요가 없습니다."** 그래서 호출이 드문 워크로드에서는 온디맨드 쪽이 유리할 수 있고, 처리량을 보장받아야 하면 프로비저닝 처리량 쪽입니다.
3. **숨은 비용** — **증류(distillation)**는 교사 모델에서 합성 데이터를 만들어 학생 모델을 미세 조정하므로, 그 과정의 **교사 모델 추론 호출이 따로 과금**됩니다. 결과물은 사용자 지정 모델이므로 **위 두 추론 설정 중 하나를 골라야** 합니다.

> ⚠️ **같이 쓸 수 없는 조합 두 개가 시험 함정입니다.**
> - **프롬프트 캐싱 + 배치 추론** → 캐싱은 **"온디맨드 추론 엔드포인트에서만 지원되고 배치 추론 API에서는 지원되지 않습니다."**
> - **배치 추론 + 프로비저닝된 모델** → **"배치 추론은 프로비저닝된 모델을 지원하지 않습니다."**
>
> 그리고 **프로비저닝 처리량 + 교차 리전 추론**도 조합이 아닙니다 — **"추론 프로필은 현재 프로비저닝 처리량을 지원하지 않습니다."** 반면 **프롬프트 캐싱과 교차 리전 추론은 함께 쓸 수 있고**, 수요가 높을 때는 그 최적화가 **캐시 쓰기를 늘릴 수 있습니다.**

**중복성은 "리전을 넘기는 것"으로 얻습니다.** 교차 리전 추론은 요청을 여러 리전의 컴퓨팅으로 라우팅하고, **전송 데이터는 AWS 네트워크를 벗어나지 않으며 리전 간 전송 중 암호화**됩니다. 다만 공식이 한계를 적습니다 — **가용성 목표를 맞추려면 애플리케이션에 "제한된 재시도와 다중 리전 또는 다중 모델 폴백"을 두어야 합니다.** 즉 CRIS만으로 가용성 목표가 자동 충족되지는 않습니다.

---

## ✍️ 시험 포인트

- **서비스 역할 매칭 문항**은 "무엇을 만드는가"를 먼저 읽습니다 — **FM 호출**은 Bedrock, **모델 훈련·통제**는 SageMaker AI, **사전 훈련 모델 고르기**는 SageMaker JumpStart, **에이전트 코드**는 Strands Agents, **에이전트 운영**은 AgentCore, **BI·분석**은 Amazon Quick, **코딩 작업**은 Kiro입니다.
- **Bedrock ↔ SageMaker AI 문항**의 갈림길은 **"컨테이너·오케스트레이션 계층 접근이 필요한가"**입니다. GPU 사용률·비용·지연·처리량을 직접 조절하는 지문이면 SageMaker AI입니다.
- **"관리형 서비스" 함정**은 Strands Agents에 걸립니다 — Strands는 **오픈소스 SDK**이고, AWS 콘솔·요금·API가 있는 쪽은 **AgentCore**입니다.
- **개명·종료 함정**이 셋 있습니다 — `Bedrock Agents` → **Agents Classic**(신규 고객 차단 2026-07-30) · `QuickSight` → **Amazon Quick Sight**(Quick 안의 기능) · `SageMaker` → **SageMaker AI**(단, **기능 이름에는 개명이 적용되지 않아** `SageMaker JumpStart`가 맞습니다).
- **이점 문항**은 "ML 전문성"을 자주 집습니다 — Bedrock에 필요한 전문성은 **기본 수준**이고, 공식이 Bedrock을 **"ML 전문성이나 리소스가 제한적일 때 특히 유용"**하다고 적습니다.
- **비용 절충 문항**은 세 패턴입니다 — **"실시간 불필요 + 대량"**이면 배치, **"사용자 지정 모델 서빙"**이면 PT(필수), **"길고 반복되는 공통 프롬프트"**면 캐싱입니다. 함정은 **배치와 캐싱을 같이 고르게** 유도하는 보기입니다.
- **리전 문항**은 **데이터 상주성 요구가 있는지**만 보면 갈립니다 — 있으면 **지리적**, 비용 최적화가 목적이면 **글로벌**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"Strands Agents는 AWS 관리형 에이전트 서비스다"** → **오픈소스 SDK**입니다. AgentCore 문서가 Strands를 CrewAI·LangGraph·LlamaIndex와 **나란히 오픈소스 프레임워크로** 나열하고, 자신은 그것들을 돌리는 플랫폼이라고 적습니다.
- ❌ **"에이전트를 새로 만들 때는 Amazon Bedrock Agents를 쓴다"** → 그 서비스는 **Agents Classic**이 되었고 **2026-07-30부터 신규 고객에게 열리지 않습니다.** 정본은 **AgentCore**입니다.
- ❌ **"Agents Classic이 닫히므로 Bedrock의 다른 기능도 영향을 받는다"** → **아닙니다.** 공식이 **"기존 Bedrock 모델·Knowledge Bases·Guardrails는 영향을 받지 않는다"**고 명시합니다.
- ❌ **"Amazon QuickSight가 현재 BI 서비스 이름이다"** → **개명 전 이름**입니다. 현재는 **`Amazon Quick` 안의 기능인 `Amazon Quick Sight`**이고, 기존 API·SDK는 변경 없이 동작합니다.
- ❌ **"Kiro와 Amazon Quick도 모델을 제공한다"** → Kiro는 **개발 도구**, Quick은 **분석·자동화 서비스**입니다. 모델을 API로 주는 쪽은 Bedrock입니다.
- ❌ **"SageMaker AI JumpStart"** → 2024-12-03 개명은 **기존 기능 이름에 적용되지 않습니다.** `SageMaker JumpStart`가 맞습니다.
- ❌ **"사용자 지정 모델을 쓰려면 프로비저닝 처리량을 반드시 사야 한다"** → 공식은 추론 설정을 **둘**로 적습니다 — 프로비저닝 처리량 구매와 **온디맨드 추론용 배포**("쓴 만큼만 내고 프로비저닝된 컴퓨팅 리소스를 설정할 필요가 없다"). 다만 **처리량을 보장받으려면** 프로비저닝 처리량 쪽입니다.
- ❌ **"배치로 돌리면서 프롬프트 캐싱으로 더 절감한다"** → 캐싱은 **온디맨드 추론 엔드포인트 전용**이고 배치 추론 API에서는 지원되지 않습니다.
- ❌ **"프로비저닝 처리량을 사면 교차 리전 추론으로 가용성까지 함께 얻는다"** → **추론 프로필은 현재 프로비저닝 처리량을 지원하지 않습니다.**
- ❌ **"글로벌 교차 리전 추론이 항상 더 낫다"** → **데이터 상주 규제가 있으면 지리적**을 골라야 합니다. 공식 표가 "규정 준수 요구에는 Geographic을 고르라"고 적습니다.
- ❌ **"모델 공급자가 우리 프롬프트를 볼 수 있다"** → **아닙니다.** 모델 배포 계정에 공급자는 접근할 수 없어 **Bedrock 로그나 고객 프롬프트·완성에 접근하지 못합니다.**
- ❌ **"Guardrails는 Bedrock 모델에만 걸 수 있다"** → **`ApplyGuardrail` API로 모델 호출 없이** 입력·출력만 평가할 수 있습니다.

---

## 🧪 자가 점검

**Q1.** 팀이 오픈소스 SDK로 에이전트 로직을 직접 코딩했고, 이제 그것을 세션이 격리된 서버리스 환경에서 인프라 관리 없이 운영하려 합니다. SDK와 운영 플랫폼의 이름과 둘의 관계를 설명하세요. (→ 1) GenAI 개발을 위한 AWS 서비스와 기능)

<details><summary>정답 보기</summary>

SDK는 **`Strands Agents`**, 운영 플랫폼은 **`Amazon Bedrock AgentCore`**이고 **둘은 경쟁 관계가 아니라 층이 다릅니다.**

- Strands Agents는 공식 서술로 **"AWS가 처음 공개한 오픈소스 SDK"**이고 모델 우선 설계입니다. AWS 콘솔·요금 페이지가 있는 관리형 서비스가 아닙니다.
- AgentCore는 **"어떤 프레임워크와 파운데이션 모델로든 매우 효과적인 에이전트를 안전하게 규모로 구축·배포·운영하는 에이전틱 플랫폼"**이고 **"인프라 관리 없이"** 돌립니다. 공식 문서가 AgentCore 서비스들이 **"CrewAI·LangGraph·LlamaIndex·Strands Agents 같은 어떤 오픈소스 프레임워크와도 함께 또는 독립적으로 동작한다"**고 적습니다.
- 세션 격리된 서버리스 실행은 AgentCore의 **Runtime** 모듈이 담당합니다.
</details>

**Q2.** 미세 조정한 사용자 지정 모델을 Amazon Bedrock에서 쓰려 합니다. 호출량이 하루 수십 건뿐이라 온디맨드 토큰 과금으로 두고 싶습니다. 가능한가요? (→ 4) 비용 절충점)

<details><summary>정답 보기</summary>

**가능합니다.** 공식은 사용자 지정 모델의 추론 설정을 **둘**로 적습니다 — **프로비저닝 처리량 구매**와 **온디맨드 추론용 배포**. 후자는 **"쓴 만큼만 내고 프로비저닝된 컴퓨팅 리소스를 설정할 필요가 없다"**고 명시돼 있어, 호출이 하루 수십 건인 이 상황에 맞습니다.

반대로 **프로비저닝 처리량**을 고르면 비용이 호출량과 무관하게 **시간당으로 발생**합니다. 과금은 **모델 단위(MU) 수 × 시간**이고 약정은 **무약정 · 1개월 · 6개월** 중에서 고르며, 약정이 길수록 시간당 가격이 할인되지만 **약정 기간이 끝나기 전에는 삭제할 수 없고 삭제할 때까지 과금이 이어집니다.** 그래서 처리량을 보장받아야 할 때 고르는 쪽입니다.

훈련 자체의 과금도 따로입니다 — **"모델이 처리한 토큰 수(훈련 데이터 코퍼스의 토큰 수 × 에포크 수)"**를 기준으로 훈련 요금이, 그리고 **모델당 월 단위로 저장 요금**이 청구됩니다.
</details>

**Q3.** 야간에 리뷰 50만 건을 배치로 분류하면서, 모든 요청에 들어가는 긴 공통 시스템 프롬프트를 캐싱해 추가 절감을 노리는 계획입니다. 이 계획의 문제는 무엇인가요? (→ 4) 비용 절충점)

<details><summary>정답 보기</summary>

**프롬프트 캐싱과 배치 추론을 함께 쓸 수 없습니다.** 공식 문서가 적습니다 — **"프롬프트 캐싱은 온디맨드 추론 엔드포인트에서만 지원된다. 배치 추론 API에서는 지원되지 않는다."**

같은 계열의 제약이 하나 더 있습니다 — **"배치 추론은 프로비저닝된 모델을 지원하지 않습니다."** 그래서 "배치 + 캐싱" 또는 "배치 + 프로비저닝된 모델"로 묶은 보기는 전부 오답입니다. 배치의 절충은 비용 쪽이 아니라 **응답성** 쪽입니다 — 프롬프트를 파일로 올리고 결과를 S3에서 받는 **비동기** 처리입니다.
</details>

**Q4.** 금융 고객이 데이터 처리를 EU 안으로 묶어야 한다는 규제를 받습니다. 동시에 처리량도 늘리고 싶습니다. 교차 리전 추론의 두 프로필 중 무엇을 고르고, 무엇을 포기하나요? (→ 4) 비용 절충점)

<details><summary>정답 보기</summary>

**지리적(Geographic) 교차 리전 추론**을 고릅니다. 공식 비교 표가 데이터 상주성을 **"US·EU·APAC 같은 지리적 경계 안"**으로 적고 **"규정 준수 요구에는 Geographic을 고르라"**고 권고합니다.

포기하는 것은 **글로벌 프로필의 비용 절감**입니다 — 글로벌은 전 세계 상용 리전으로 라우팅하면서 **약 10% 절감**을 주지만 지리적 제약이 없어 데이터 상주 규제에는 맞지 않습니다. 라우팅 자체에는 추가 비용이 없고 요금은 **추론 프로필을 호출한 리전 기준**으로 계산됩니다.

⚠️ 함께 기억할 것 둘 — **추론 프로필은 현재 프로비저닝 처리량을 지원하지 않습니다.** 그리고 **가용성 목표를 맞추려면** 공식 권고대로 애플리케이션에 **제한된 재시도와 다중 리전 또는 다중 모델 폴백**을 두어야 합니다.
</details>

**Q5.** "우리 BI 도구는 Amazon QuickSight이고, 기존 QuickSight API를 쓰는 코드가 많아 Amazon Quick으로는 못 옮깁니다"라는 설명을 검토하세요. (→ 1) GenAI 개발을 위한 AWS 서비스와 기능)

<details><summary>정답 보기</summary>

**두 군데가 틀렸습니다.**

- **이름**: 공식 메모가 **"Amazon Quick은 Amazon QuickSight에서 진화했다. QuickSight는 Quick 안의 기능인 Amazon Quick Sight로 이어진다"**고 적습니다. 즉 QuickSight는 **개명 전 이름**이고 현재 BI 기능의 이름은 **`Amazon Quick Sight`**입니다.
- **호환성**: 같은 메모가 **"기존 QuickSight API·SDK·통합은 변경 없이 계속 동작한다"**고 덧붙입니다. 코드가 많다는 것이 이전을 막는 근거가 되지 않습니다.

Quick의 기능은 `Amazon Quick Sight` · `Amazon Quick Flows` · `Amazon Quick Automate` · `Amazon Quick Index` · `Amazon Quick Research` · `Apps in Amazon Quick` 여섯이고, Quick 자체는 **"작업 자동화, 데이터 분석, 웹 애플리케이션 구축, 리서치를 위한 AI 기반 서비스"**입니다.
</details>

**Q6.** 보안 심사에서 "FM 공급자가 우리 프롬프트를 볼 수 있는가"와 "데이터가 리전을 벗어나는가"를 묻습니다. Amazon Bedrock에 대해 공식 서술을 근거로 답하세요. (→ 3) AWS 인프라의 이점)

<details><summary>정답 보기</summary>

**둘 다 아닙니다.**

- **공급자 접근**: Bedrock은 리전마다 모델 공급자별 **모델 배포 계정**을 두고 그 계정은 Bedrock 서비스 팀이 소유·운영합니다. **모델 공급자는 그 계정에 접근할 수 없어 Bedrock 로그나 고객 프롬프트·완성에 접근하지 못합니다.** 공식 FAQ도 **"사용자 입력과 모델 출력은 어떤 모델 공급자와도 공유되지 않는다"**고 적고, 입력·출력이 기본 모델 개선이나 모델 훈련에 쓰이지 않는다고 명시합니다.
- **리전**: **"Amazon Bedrock이 처리하는 모든 고객 콘텐츠는 암호화되어 Bedrock을 사용하는 AWS 리전에 저장된다."** 교차 리전 추론을 쓰면 요청이 다른 리전에서 처리될 수 있지만, 그때도 **전송 데이터는 AWS 네트워크를 벗어나지 않고 리전 간 전송 중 암호화**되며, 지리적 프로필을 쓰면 **라우팅이 그 지리 경계 안으로 제한**됩니다.

네트워크 차원을 더 묻는다면 **`AWS PrivateLink` 인터페이스 VPC 엔드포인트**로 "데이터를 인터넷 트래픽에 노출하지 않고" VPC에서 Bedrock으로 비공개 연결을 만든다고 답합니다.
</details>

**Q7.** 스타트업이 "AWS GenAI 서비스를 쓰면 ML 전문가를 고용하지 않아도 고객 지원 챗봇을 만들 수 있다"고 주장합니다. 공식 서술은 이 주장을 어디까지 뒷받침하나요? (→ 2) AWS GenAI 서비스로 만들 때의 이점)

<details><summary>정답 보기</summary>

**사전 훈련 모델을 쓰는 범위까지는 뒷받침합니다.** 공식 결정 가이드가 Amazon Bedrock을 **"ML 전문성이나 리소스가 제한적일 때 특히 유용"**하다고 적고, 필요 전문성을 **"사전 훈련 모델을 쓰는 데 필요한 기본 수준의 ML 전문성"**으로 적습니다. 공식이 든 예가 바로 **"Bedrock의 자연어 처리 기능으로 사용자 문의를 이해하고 응답하는 고객 지원 챗봇"**입니다. Bedrock은 **서버리스**라 인프라를 관리하지 않고, 사전 훈련 모델·프롬프트 엔지니어링·RAG로 **깊은 ML 전문성 없이** 만들 수 있습니다.

> ⚠️ **"전문성이 필요 없는 쪽은 Bedrock뿐"으로 외우면 틀립니다.** 같은 결정 가이드가 **SageMaker AI는 청중이 둘**이라고 적고, **서버리스 커스터마이징 쪽은 "안내형 UI와 AI 에이전트 지원 워크플로가 ML 전문성을 요구하지 않는다"**고 못박습니다. 깊은 전문성이 걸리는 쪽은 **훈련 작업·전용 엔드포인트·HyperPod로 전체를 통제하려는 경우**입니다. 갈림길은 **"전문성이 있냐 없냐"가 아니라 "무엇을 통제하려 하느냐"**입니다.

**뒷받침하지 않는 범위**도 분명합니다 — 공식은 통제가 더 필요한 경우를 **Amazon SageMaker AI**로 보내며, "컨테이너나 오케스트레이션 계층에 접근해 비용·지연·처리량 절충을 직접 관리해야 할 때"를 그 기준으로 적습니다. 그리고 **"둘 중 하나를 고르기보다 필요한 사용자 지정 수준을 보라"**며 **"Bedrock으로 시작해 사용자 지정 요구가 커지면 SageMaker AI로 나아가는 것이 일반적 경로"**라고 적습니다. 즉 "전문가가 영원히 필요 없다"가 아니라 **"시작 지점의 진입 장벽이 낮다"**가 공식이 말하는 이점입니다.
</details>

---

### 📌 출처

1. Amazon Bedrock Overview — `docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html` (2026-11-06 재확인) · ⚠️ **이 페이지는 Quickstart 중심의 「Overview」로 재구성됐습니다.** 여기서 쓰는 사실은 **"fully managed service"**(완전관리형) 정의뿐이고, **「서버리스」와 「모델 독립적인 단일 API」는 이 페이지에 없습니다**(두 방법으로 확인: 본문 추출과 AWS 문서 리더 양쪽에서 `serverless`·`single API`·`model-independent` 각 0건, 대조군 `fully managed` 1건). 그 둘의 정본은 아래 결정 가이드 둘입니다
2. What is Amazon Quick? — `docs.aws.amazon.com/quick/latest/userguide/what-is.html` (2026-11-03 확인)
3. What is Amazon SageMaker AI? (개명 메모 포함) — `docs.aws.amazon.com/sagemaker/latest/dg/whatis.html` (2026-11-03 확인)
4. SageMaker JumpStart pretrained models — `docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html` (2026-11-03 확인)
5. What is Amazon Bedrock AgentCore? (핵심 서비스 표) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html` (2026-11-03 확인)
6. Strands Agents (AWS Prescriptive Guidance) — `docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/strands-agents.html` (2026-11-03 확인)
7. Machine Learning (ML) and Artificial Intelligence (AI) — AWS 서비스 개요 백서 (Kiro 정의) — `docs.aws.amazon.com/whitepapers/latest/aws-overview/machine-learning.html` (2026-11-03 확인)
8. Amazon Bedrock Agents Classic maintenance mode — `docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html` (2026-11-03 확인)
9. Amazon Bedrock or Amazon SageMaker AI? (결정 가이드) — `docs.aws.amazon.com/decision-guides/latest/decision-guides/bedrock-or-sagemaker.html` (2026-11-03 확인)
10. Choosing a generative AI service (결정 가이드) — `docs.aws.amazon.com/decision-guides/latest/decision-guides/genai-guide.html` (2026-11-03 확인)
11. Data protection (Amazon Bedrock — 공동 책임 모델·모델 배포 계정) — `docs.aws.amazon.com/bedrock/latest/userguide/data-protection.html` (2026-11-03 확인)
12. Protect your data using Amazon VPC and AWS PrivateLink — `docs.aws.amazon.com/bedrock/latest/userguide/usingVPC.html` (2026-11-03 확인)
13. Compliance validation for Amazon Bedrock (AWS Artifact) — `docs.aws.amazon.com/bedrock/latest/userguide/compliance-validation.html` (2026-11-03 확인)
14. Amazon Bedrock FAQs (리전 저장·공급자 비공유) — `aws.amazon.com/bedrock/faqs/` (2026-11-03 확인)
15. Detect and filter harmful content by using Amazon Bedrock Guardrails — `docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html` (2026-11-03 확인)
16. Responsible AI: From principles to practice (여덟 차원·AI Service Cards) — `aws.amazon.com/ai/responsible-ai/` (2026-11-03 확인)
17. Increase model invocation capacity with Provisioned Throughput in Amazon Bedrock — `docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html` (2026-11-03 확인)
18. Process multiple prompts with batch inference — `docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html` (2026-11-03 확인)
19. Prompt caching for faster model inference — `docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html` (2026-11-03 확인)
20. Route model inference requests across AWS Regions with cross-Region inference — `docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html` (2026-11-03 확인)
21. Customize your model to improve its performance for your use case (훈련 과금 구조) — `docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html` (2026-11-03 확인)
22. Amazon Bedrock (AWS Prescriptive Guidance — 추론 서비스 계층) — `docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-inference-architecture-and-best-practices-on-aws/amazon-bedrock.html` (2026-11-03 확인)
23. AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어) — `docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain2.html` (2026-11-03 확인)
24. Set up inference for a custom model (Amazon Bedrock — 프로비저닝 처리량 구매와 온디맨드 추론용 배포 두 경로) — `docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html` (2026-11-05 확인)
