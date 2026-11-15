---
examGuideTaskId: aip-t5-1
certCode: AIP-C01
domain: 5
domainName: 테스트, 검증 및 문제 해결
domainWeightPct: 11
title: GenAI 평가 시스템 (품질 지표·모델 평가·사람 평가·품질 게이트·RAG·검색·에이전트·보고·배포 검증)
coversTasks:
  - "5.1"
sources:
  - title: Amazon Bedrock 평가 개요 — 네 종류
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html
  - title: 판정 모델 평가
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-judge.html
  - title: 판정 모델 평가의 내장 지표
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html
  - title: 자동 평가의 작업 유형과 내장 데이터세트
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-tasks.html
  - title: 사람 작업자를 쓰는 모델 평가 작업
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-human.html
  - title: 사람 평가의 작업 팀 관리
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/human-worker-evaluations.html
  - title: 사람 기반 평가 작업 만들기
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-jobs-management-create-human.html
  - title: 사람 기반 평가 보고서 검토 — 등급 방법 다섯
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-report-human-customer.html
  - title: AgentCore Evaluations 작동 방식
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/how-it-works-evaluations.html
  - title: AgentCore 평가 유형
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html
  - title: AgentCore 평가자 네 갈래
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluators.html
  - title: AgentCore 내장 평가자 개요
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html
  - title: AgentCore 내장 평가자의 프롬프트 템플릿 — 세 수준
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/prompt-templates-builtin.html
  - title: AgentCore 스킬 평가자
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/skill-evaluators.html
  - title: AgentCore 통찰 평가자
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/insight-evaluators.html
  - title: 관찰성 지원 프레임워크와 계측
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html
  - title: AGENTOPS06-BP01 — 테스트 네 계층
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp01.html
  - title: AGENTOPS06-BP02 — 지속 평가
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp02.html
  - title: AGENTOPS05-BP04 — KPI 네 차원과 보고
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp04.html
  - title: RAG 평가 작업
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation-kb.html
  - title: RAG 평가 지표
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html
  - title: 리랭킹으로 검색 결과 재정렬
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/rerank.html
  - title: SageMaker AI 배포 가드레일 — 카나리·선형·롤링
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails.html
  - title: Amazon Augmented AI로 사람 검토하기
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html
  - title: SageMaker Ground Truth로 훈련 데이터 레이블링
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/sms.html
  - title: AWS Quick이란 무엇인가
    url: https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
lastVerified: 2026-11-15
---

# GenAI 평가 시스템 (품질 지표·모델 평가·사람 평가·품질 게이트·RAG·검색·에이전트·보고·배포 검증)

> **커버하는 공식 Task** — AIP-C01 · 도메인 5 「테스트, 검증 및 문제 해결」(11%) · **작업 5.1 GenAI용 평가 시스템 구현** (`aip-t5-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 9개(5.1.1~5.1.9)를 모두 덮습니다. **이 자격증에서 기술이 가장 많은 작업**입니다 — 도메인 비중은 11%인데 기술이 9개인 이유는, 평가가 「한 번 재는 일」이 아니라 **무엇을 잴지 정하고 · 어떻게 잴지 고르고 · 사람을 끼우고 · 자동화하고 · 보고하고 · 배포 때 다시 재는** 사슬 전체이기 때문입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 평가 기계 **둘**의 대상 차이를 가른다
- [ ] 평가 **네 종류**와 자동 평가의 작업 유형 제약을 안다
- [ ] 사람 평가의 **등급 방법 다섯**과 작업 팀 제약을 안다
- [ ] 테스트 **네 계층**과 정확 일치 단정의 문제를 안다
- [ ] RAG 평가의 **작업 유형 둘과 지표 수 차이**를 안다
- [ ] AgentCore 평가자가 **세 수준**으로 갈리는 것을 안다
- [ ] 보고 시스템의 **시각화와 저장 위치**를 안다
- [ ] 배포 검증에서 **카나리·선형·롤링**을 가른다

---

## 🎯 왜 중요한가

기존 ML 모델의 평가는 **정답이 있는 데이터셋에 정확도를 재는 일**이었습니다. 레이블이 있고, 지표가 수치로 나오고, 같은 입력에 같은 출력이 나옵니다.

FM은 세 가지가 전부 다릅니다. **정답이 하나가 아니고**(같은 질문에 좋은 답이 여러 개), **출력이 비결정적이며**(같은 프롬프트에 매번 다른 문장), **틀리는 방식이 새롭습니다**(없는 사실을 그럴듯하게 만들어 내는 것은 기존 분류 오류와 다른 종류입니다).

그래서 이 작업의 공식 기술 아홉 개가 **그 세 차이를 메우는 순서**로 배열돼 있습니다 — 무엇을 품질로 볼지 정하고(`5.1.1`), 구성을 체계적으로 비교하고(`5.1.2`), 자동 지표가 못 보는 것을 사람이 보게 하고(`5.1.3`), 그것을 반복 가능한 프로세스로 묶고(`5.1.4`), 여러 관점을 더하고(`5.1.5`), RAG의 검색 쪽을 따로 재고(`5.1.6`), 에이전트의 궤적을 재고(`5.1.7`), 결과를 이해관계자에게 전달하고(`5.1.8`), 배포할 때마다 다시 검증합니다(`5.1.9`).

---

## ⚡ 시험 직전 요약

- ⚠️⚠️ **평가 기계가 둘이고 대상이 다르다** — Bedrock Evaluations는 **모델과 지식 베이스**, AgentCore Evaluations는 **에이전트**(세션·트레이스·스팬을 입력으로 받는다)
- **Bedrock 평가 네 종류**: 자동(프로그래매틱) · 사람 작업자 · 판정 모델 · RAG. ⚠️ **자동 평가는 한 작업에 작업 유형 하나**만 고른다
- ⭐ 평가 대상이 될 수 있는 모델 유형에 **프롬프트 라우터**와 **PT를 구매한 모델**이 든다
- ⚠️⚠️ 가이드가 품질 지표로 드는 넷 가운데 **「유창성」에 대응하는 내장 지표가 없다**(관련성·정확성·일관성은 있다) — 그 자리는 **사용자 지정 지표**다
- **사람 평가의 등급 방법은 다섯**이고 각각 **JSON 키와 시각화가 다르다**(히스토그램 ↔ 비율)
- ⚠️⚠️ **작업 팀당 최대 50명**이고 **작업자 포털은 계정·리전당 하나**다. **처음 추가될 때만 알림이 가고** 평가 작업 생성 중 작업자를 삭제하면 **그가 할당된 모든 작업의 접근을 잃는다**
- ⚠️⚠️ **주석 워크플로의 전통 수단 둘이 신규 고객에게 열려 있지 않다** — `Amazon SageMaker A2I`와 `Amazon SageMaker Ground Truth`
- **테스트는 네 계층**(단위·통합·E2E·섀도)이고 ⚠️ **정확 일치 단정은 비결정적 출력을 깨뜨린다**
- **RAG 평가는 작업 유형 둘**이고 지표 수가 **2 ↔ 10**으로 다르다
- ⚠️⚠️ **카나리는 2단계, 선형은 n단계**다(둘 다 블루/그린의 트래픽 전환 모드). ⭐ **베이킹 기간에 CloudWatch 알람이 울리지 않아야** 전환이 끝난다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **판정 모델 평가(LLM-as-judge)** | **두 번째 LLM**이 응답을 채점하고 **각 응답에 설명을 붙이는** 평가 |
| **내장 데이터세트** | 자동 평가가 바로 쓸 수 있게 공식이 제공하는 프롬프트 데이터세트(작업 유형마다 다르다) |
| **작업 팀(work team)** | 사람 평가에 참여하는, **내가 고른** 작업자 집단. 사내 직원이나 업계 주제 전문가 |
| **Likert 척도** | 승인 강도나 선호 강도를 **5점**으로 받는 등급 방법 |
| **그라운드 트루스** | 기대 응답·어서션·**기대 도구 궤적**처럼 「정답」으로 두고 비교하는 참조 데이터 |
| **섀도 테스트** | **트래픽 미러링**으로 새 버전을 운영과 병행 실행하되 **그 응답은 서빙하지 않는** 테스트 |
| **베이킹 기간(baking period)** | 트래픽을 옮긴 뒤 **CloudWatch 알람으로 새 플릿을 지켜보는** 관찰 구간 |
| **통찰 평가자** | 점수가 아니라 **패턴·근본 원인·제안 수정**을 돌려주는 평가자 |

---

## 📖 핵심 개념

### 1) 품질 지표 프레임워크 — 기존 ML을 넘어서는 축 (기술 5.1.1) {#quality-metrics}

> 🧠 원리: 기존 ML 지표는 **정답과 비교**합니다. FM 출력에는 정답이 하나가 아니므로, 공식 지표가 **「무엇과 비교하는가」로 갈립니다** — 프롬프트와 비교하는 것(관련성·충실성), 참조 응답과 비교하는 것(정확성), 자기 안에서 비교하는 것(일관성), 어느 것과도 비교하지 않고 성질만 보는 것(유해성·고정관념)입니다. 이 구분을 잡으면 「어떤 지표를 켜야 하는가」가 결정됩니다.

공식 기술이 품질 지표로 드는 넷은 **관련성 · 사실적 정확성 · 일관성 · 유창성**입니다. 공식 내장 지표와 맞춰 보면 이렇습니다.

| 가이드의 지표 | 대응하는 공식 내장 지표 |
|---|---|
| 관련성 | `Builtin.Relevance` |
| 사실적 정확성 | `Builtin.Correctness`(+ `Builtin.Faithfulness`) |
| 일관성 | `Builtin.Coherence` |
| **유창성** | ⚠️⚠️ **판정 내장 지표 목록에 없고 자동 평가 지표(정확도·강건성·독성)에도 없다** |

- ✅ 그 자리는 **사용자 지정 지표**(판정 프롬프트를 직접 쓰는 경로)로 갑니다. AgentCore 쪽에는 **`Conciseness`**(간결성) 같은 다른 축이 있습니다.
- ⛔ 다만 **「공식에 유창성 지표가 없다」를 정답으로 외우지 않습니다** — 부재는 개정으로 바뀔 수 있고, 실제로 이 레포의 다른 트랙에서 「사라졌다」고 기록한 목록이 뒤에 되살아난 일이 있습니다.

**판정 모델 평가의 내장 지표**는 다음과 같습니다.

| 지표 | ID | 무엇을 보는가 |
|---|---|---|
| 정확성 | `Builtin.Correctness` | 응답이 옳은지. ⭐ **참조 응답을 주면 평가자가 그것을 고려한다** |
| 완전성 | `Builtin.Completeness` | 프롬프트의 **모든 질문**에 답했는지 |
| 충실성 | `Builtin.Faithfulness` | ⭐ **프롬프트에 없는 정보가 응답에 들어 있는지** — 할루시네이션 축 |
| 유용성 | `Builtin.Helpfulness` | 지시 준수 · 합리성·일관성 · **암시적 요구 예측** |
| 논리적 일관성 | `Builtin.Coherence` | 논리적 공백·불일치·모순 |
| 관련성 | `Builtin.Relevance` | 프롬프트에 대한 관련성 |
| 지시 준수 | `Builtin.FollowingInstructions` | 프롬프트의 **정확한 지시**를 지켰는지 |
| 전문적 문체·어조 | `Builtin.ProfessionalStyleAndTone` | — |
| 유해성 | `Builtin.Harmfulness` | — |
| 고정관념 | `Builtin.Stereotyping` | ⭐ **긍정적이든 부정적이든** |
| 거부 | `Builtin.Refusal` | 답하기를 직접 거절했는지 |

**⚠️⚠️ 평가 기계가 둘이고 대상이 다릅니다.** 이 작업에서 가장 많이 틀리는 자리입니다.

| | **Amazon Bedrock Evaluations** | **Amazon Bedrock AgentCore Evaluations** |
|---|---|---|
| 평가 대상 | **모델**과 **지식 베이스**(Bedrock 밖의 모델·RAG 소스도) | **에이전트**(AgentCore Runtime에 호스팅된 것과 **밖에 호스팅된 것 모두**) |
| 입력 | 프롬프트 데이터세트 | **세션·트레이스·스팬**(관찰성 텔레메트리) |
| 대표 지표 | 정확도·강건성·독성 / 판정 모델 내장 지표 | **목표 달성 정확성 · 호출한 도구의 정확성 · 사용자 지정 지표** |

⚠️ 섞으면 거짓이 됩니다 — 「Bedrock Evaluations로 도구 선택 정확도를 잰다」·「AgentCore Evaluations로 두 FM의 요약 품질을 비교한다」류는 둘의 대상을 바꿔 놓은 것입니다.

---

### 2) 체계적 모델 평가 — 네 종류·A/B·카나리 (기술 5.1.2) {#model-eval}

> 🧠 원리: 「최적의 구성을 찾는다」는 **같은 척도로 여러 구성을 재는 것**입니다. 그래서 공식 평가가 네 종류로 갈리고, 그 선택이 **「무엇이 정답인지 아는가」와 「사람의 판단이 필요한가」** 두 질문으로 결정됩니다. 그리고 운영에 넣는 단계에서는 척도가 하나 더 필요합니다 — **새 구성이 실제 트래픽에서 안전한가**이고, 그것이 카나리입니다.

**Bedrock 평가 네 종류**입니다.

| 종류 | 무엇인가 |
|---|---|
| **프로그래매틱(자동) 모델 평가** | 작업 수행 능력을 빠르게 평가. **내장 데이터세트** 또는 내 프롬프트 데이터세트 |
| **사람 작업자 모델 평가** | 사내 직원 또는 업계 **주제 전문가**가 평점·선호를 준다 |
| **판정 모델 평가** | **두 번째 LLM**이 채점하고 **각 응답에 설명을 붙인다** |
| **RAG 평가** | 지식 베이스·RAG 소스의 검색·생성 품질(§5에서 다룹니다) |

⭐ 평가 대상이 될 수 있는 모델 유형이 여섯입니다 — **파운데이션 모델 · Bedrock Marketplace 모델 · 사용자 지정 FM · 가져온 FM · 프롬프트 라우터 · 프로비저닝 처리량을 구매한 모델.** **프롬프트 라우터도 평가 대상**이라는 것이 라우팅 설계와 이 작업을 잇습니다.

**⚠️ 자동 평가는 한 작업에 작업 유형 하나**만 고릅니다.

| 작업 유형 | 지표 | 내장 데이터세트 | 계산되는 지표 |
|---|---|---|---|
| 일반 텍스트 생성 | 정확도 / 강건성 / 독성 | TREX / BOLD·TREX·WikiText2 / RealToxicityPrompts·BOLD | **RWK 점수** / **단어 오류율** / 독성 |
| 텍스트 요약 | 정확도 / 독성 / 강건성 | Gigaword | **BERTScore** / 독성 / **BERTScore와 deltaBERTScore** |
| 질문과 답변 | 정확도 / 강건성 / 독성 | BoolQ·NaturalQuestions·TriviaQA | **NLP-F1** / **F1과 deltaF1** / 독성 |
| 텍스트 분류 | 정확도 / 강건성 | Women's Ecommerce Clothing Reviews | 이진 정확도 / 분류 정확도와 delta |

⭐ **`delta…` 지표는 강건성 축**입니다 — 섭동을 준 입력과 원 입력의 점수 **차이**를 봅니다.

**A/B 테스트**는 같은 척도로 두 구성을 재는 것이고, 틀은 프롬프트 관리의 **버전과 변형**이 제공합니다(`aip-t4-2` 문서 §4). **토큰 효율성 · 지연 시간 대비 품질 · 비용 성능 분석**은 각각 `aip-t4-1` 문서 §1과 `aip-t4-2` 문서 §1·§3의 축입니다.

**⚠️⚠️ 카나리 테스트는 평가 기능이 아니라 배포 기능입니다.** SageMaker AI의 **배포 가드레일**이 공식 수단이고 구조가 이렇습니다.

- 배포 유형이 **둘**입니다 — **블루/그린**(새 플릿으로 트래픽을 옮긴다)과 **롤링**(내가 지정한 배치 크기만큼 점진적으로 용량을 провиж하고 트래픽을 옮긴다).
- 블루/그린의 **트래픽 전환 모드가 셋**입니다: **한 번에 전부** · **카나리** · **선형**.
  - ⚠️⚠️ **카나리는 트래픽 일부를 먼저 옮겨 베이킹 기간 동안 지켜본 뒤 나머지를 옮기는 2단계**이고, **선형은 그것을 n개의 선형 간격 단계로 확장**한 것입니다.
- ⭐ **베이킹 기간 동안 사전 지정한 CloudWatch 알람이 새 플릿을 모니터링하고, 알람이 울리지 않으면 옛 플릿을 종료**합니다. **자동 롤백**이 내장돼 문제를 조기에 잡습니다.
- 진행 상황은 **`DescribeEndpoint` API** 또는 **CloudWatch Events**로 추적합니다.
- ⚠️⚠️ **배포 가드레일은 비동기 추론과 실시간 추론 엔드포인트 유형에만** 적용됩니다. 그리고 ⚠️ **엔드포인트가 Exclusions 페이지의 기능을 쓰면 배포 가드레일을 쓸 수 없고 CloudWatch Events도 쓸 수 없습니다.**

> ⚠️⚠️ **A/B·기능 플래그를 `Amazon CloudWatch Evidently`로 설계하면 안 됩니다** — 공식 AWS Lifecycle Changes 목록이 그 기능을 **완전 종료**로 적고, 전용 문서 페이지도 더 이상 제공되지 않습니다(슬러그가 가이드 인덱스로 돌아갑니다). 새 설계의 A/B 틀은 **프롬프트 관리의 버전·변형 + 평가 작업**이고, 트래픽 수준의 점진 노출은 **배포 가드레일**입니다.

---

### 3) 사용자 중심 평가 — 등급 방법 다섯과 작업 팀 (기술 5.1.3) {#human-feedback}

> 🧠 원리: 자동 지표가 못 잡는 것은 **뉘앙스·적절성·사업 맥락 정합**입니다. 그래서 사람을 끼우는데, 여기서 비용은 사람의 시간이고 **그 시간을 무엇으로 바꾸는지가 등급 방법으로 결정됩니다.** 「좋았나」(Likert)와 「둘 중 어느 쪽」(선택·순위)은 같은 시간에 서로 다른 정보를 주고, 보고서에 나오는 그림도 달라집니다.

**등급 방법은 다섯**이고, 공식이 각각의 **JSON 키와 최종 보고서의 시각화**를 함께 적습니다.

| 등급 방법 | JSON 키 | 최종 보고서 |
|---|---|---|
| **Likert 척도 — 여러 모델 출력 비교** | `comparisonLikertScale` | 데이터세트 전체의 **선호 강도 히스토그램** |
| **선택 버튼(라디오)** | `comparisonChoice` | **모델별로 작업자가 선호한 응답의 비율(%)** |
| **순위(Ordinal rank)** | `comparisonRank` | 순위의 **히스토그램**. ⭐ 데이터 유형 이름은 **Preference Rank** |
| **Thumbs up/down** | `thumbsUpDown` | **모델별 thumbs up 비율(%)** |
| **Likert 척도 — 단일 모델 응답 평가** | `individualLikertScale` | 5점 평정의 **히스토그램** |

- ⭐ **Thumbs up/down과 단일 Likert는 모델이 하나든 여럿이든** 쓸 수 있고, 모델이 둘이면 **각 모델 응답마다 제시되고 보고서가 모델별로 집계**합니다.
- ⚠️ 다섯 방법 모두 공식이 같은 주의를 반복합니다 — **척도의 중요 지점·순위 1의 의미·「수용 가능」의 기준을 지시문에 정의**해야 평가자가 기대대로 평정합니다.

**작업 팀 운영의 제약**이 시험 소재입니다.

- ⚠️ **작업 팀당 최대 50명**이고 이메일 필드에 **한 번에 50개**까지 넣습니다. 더 추가하려면 **Cognito 콘솔 또는 Ground Truth 콘솔**을 씁니다.
- ⚠️⚠️ **작업자는 작업 팀에 처음 추가될 때만 알림을 받습니다.** 기존 작업자에게 새 평가 작업을 할당하면 **내가 직접 알리고 작업자 포털 URL을 줘야** 하고, 작업자는 **전에 만든 로그인 자격 증명**을 씁니다. ⭐ **그 포털은 계정·리전당 하나**로 모든 평가 작업에 같습니다.
- ⚠️⚠️ **평가 작업 생성 중 작업자를 삭제하면 그 작업자가 할당된 모든 평가 작업의 접근을 잃습니다.**
- 작업 팀은 **Ground Truth가 관리하는 프라이빗 워크포스**에 넣을 수 있고(Ground Truth가 더 고급 워크포스 관리 기능을 제공합니다), **Cognito·Ground Truth·Augmented AI에서 만든 프라이빗 워크포스와 작업 팀이** 평가 작업을 만들 때 보입니다.

작업을 만들 때의 사실 둘 — **추론 소스는 최대 둘**이고 **둘이 같은 유형일 필요가 없습니다**(Bedrock 모델 하나 + 내가 제공하는 추론 응답 하나도 됩니다). 내 응답을 가져오는 경우 ⚠️ **Source Name이 프롬프트 데이터세트의 `modelIdentifier` 파라미터와 일치**해야 하고, ⚠️ **모델에 대한 모든 지시는 프롬프트 자체에 포함**돼야 합니다.

**⚠️⚠️ 주석 워크플로의 전통적 수단 둘이 신규 고객에게 열려 있지 않습니다.**

- **`Amazon SageMaker A2I`** — 공식 페이지가 **`Amazon SageMaker A2I is no longer open to new customers.`**와 **기존 고객은 계속 쓸 수 있고 AWS가 보안·가용성 개선에는 계속 투자하지만 새 기능을 도입할 계획은 없다**고 적습니다. 저신뢰 예측이나 무작위 표본을 사람 검토로 보내는 **사람 검토 루프**가 그 기능이었습니다.
- **`Amazon SageMaker Ground Truth`** — **같은 문구**로 신규 고객에게 열려 있지 않습니다. ⚠️ 그리고 **`Ground Truth Plus`는 완전 종료**라 본체와 섞으면 거짓이 됩니다.
- ⭐ 그래서 **새로 짓는 설계의 사람 평가 경로는 Bedrock의 사람 기반 평가 작업과 그 작업 팀**이고, 작업자 관리의 콘솔 경로는 **Cognito** 쪽입니다.

---

### 4) 품질 보증 프로세스 — 테스트 네 계층과 품질 게이트 (기술 5.1.4) {#qa-process}

> 🧠 원리: 「일관된 성능 표준」은 **같은 검사를 매번 돌리는 것**입니다. 그런데 FM 출력은 비결정적이라 **「전과 똑같은가」를 물을 수 없습니다** — 물어야 하는 것은 **「전과 같은 품질인가」**이고, 그 차이가 테스트 설계를 전부 바꿉니다.

**테스트는 네 계층**입니다.

| 계층 | 무엇을 보는가 |
|---|---|
| **단위** | 프롬프트 템플릿 · 도구 호출 로직 · 메모리 검색 · 결정 라우팅. ⭐ 결정성이 필요하면 **LLM 응답을 목(mock)** 한다 |
| **통합** | **실제 엔드포인트가 있는 스테이징**에서 에이전트-도구·에이전트-에이전트 상호 작용 |
| **E2E** | 전체 워크플로 — ⚠️ **여기서는 정확 일치보다 의미 평가가 중요하다** |
| **섀도** | ⭐ **트래픽 미러링**으로 새 버전을 운영과 병행 실행하고 출력을 비교하되 **새 버전의 응답은 서빙하지 않는다**. 비용은 병행 추론 인프라, 값은 사용자가 만나기 전에 잡는 것 |

- ⚠️⚠️ **정확 일치 단정(exact-match)은 비결정적 LLM 출력을 깨뜨립니다** — 의미 동등성 검사를 씁니다.
- ⚠️ **테스트 데이터세트를 역량 변화에 맞춰 갱신하지 않으면** 테스트가 낡아 **회귀 탐지 가치를 잃습니다.**
- ⭐ **CI/CD의 품질 게이트로 평가자를 쓰면 비트 단위 비교 없이** 품질 회귀를 막을 수 있습니다 — 이것이 공식 기술이 드는 「배포를 위한 자동화된 품질 게이트」입니다.
- 회귀 테스트의 참조 데이터는 **배치 평가의 그라운드 트루스**로 둡니다 — 세션 메타데이터에 **기대 응답 · 어서션 · 기대 도구 궤적**을 담고, 공식 용례가 **기준선 측정 · 프롬프트·모델 변경 전후 비교 · 큐레이션된 세션 집합의 회귀 테스트 · 주기적 품질 감사**입니다.

---

### 5) 다관점 평가 — RAG·판정 모델·사람 (기술 5.1.5) {#multi-perspective}

> 🧠 원리: 한 지표로 품질을 재면 그 지표가 보는 축만 좋아집니다. 「다양한 관점」의 실제 뜻은 **서로 다른 종류의 증거를 모으는 것**입니다 — 검색이 맞았는지(RAG 지표), 생성이 근거에 충실한지(판정 지표), 사람이 보기에 쓸 만한지(사람 평가). 셋이 같은 결론을 주면 신뢰가 올라가고, 어긋나면 **어디가 문제인지가 바로 드러납니다.**

**RAG 평가는 작업 유형이 둘**이고 **지표 집합이 다릅니다.**

| 유형 | 내장 지표 |
|---|---|
| **Retrieve only** | **둘** — `Builtin.ContextRelevance` · `Builtin.ContextCoverage`(⚠️ **커버리지는 프롬프트 데이터세트에 그라운드 트루스가 있어야 한다**) |
| **Retrieve and generate** | **열** — Correctness · Completeness · Helpfulness · LogicalCoherence · **Faithfulness**(검색된 텍스트 대비 할루시네이션 회피) · **CitationPrecision** · **CitationCoverage** · Harmfulness · Stereotyping · Refusal |

- ⭐ **외부 RAG 소스**의 추론 응답 데이터를 가져와 평가할 수도 있습니다(Bedrock 지식 베이스가 아니어도 됩니다) — 그래서 **서로 다른 RAG 시스템을 비교해 고르는 것**이 이 기능의 목적입니다.
- 사용자 지정 지표도 정의할 수 있습니다. ⚠️ **평가자 모델 목록은 자주 바뀌므로 모델 이름·개수를 외우지 않습니다.**

**판정 모델 평가**는 **생성 모델과 평가자 모델**이 필요하고, ⭐ **내 응답 데이터를 프롬프트 데이터세트에 직접 넣으면 Bedrock이 모델 호출 단계를 건너뛰고 그 데이터를 바로 평가**합니다 — Bedrock 밖에서 돌리는 모델을 같은 척도로 채점하는 경로입니다. ⚠️ **내장 지표용 평가자 모델 목록과 사용자 지정 지표용 목록이 다릅니다.**

**사람 피드백 수집 인터페이스**는 §3의 등급 방법 다섯이 그 자리입니다. ⭐ Lens가 권하는 조합은 **자동 지표 + 주기적 사람 평가**이고, **LLM-as-judge는 여러 평가자 프롬프트로 합성 점수**를 만드는 것이 단일 프롬프트보다 신뢰성이 높습니다.

---

### 6) 검색 품질 테스트 (기술 5.1.6) {#retrieval-quality}

> 🧠 원리: RAG가 틀릴 때 원인은 둘입니다 — **검색이 엉뚱한 것을 가져왔거나**, **잘 가져왔는데 생성이 어긋났거나**. 두 원인의 처방이 완전히 다르므로 **검색 쪽을 따로 재는 것**이 먼저이고, 그래서 공식이 `Retrieve only` 작업 유형을 별도로 두었습니다.

공식 기술이 드는 셋을 측정 수단으로 옮기면 이렇습니다.

| 공식 예시 | 측정 수단 |
|---|---|
| **관련성 점수 매칭** | `Builtin.ContextRelevance` + **리랭커**(쿼리와 청크의 관련성을 다시 계산해 재정렬) |
| **컨텍스트 매칭 검증** | `Builtin.ContextCoverage`(⚠️ 그라운드 트루스 필수) · 생성 쪽은 `Faithfulness`·`CitationPrecision`·`CitationCoverage` |
| **검색 지연 시간 측정** | CloudWatch 런타임 지표(`aip-t4-3` 문서 §2) — ⚠️ `InvocationLatency`는 **마지막 토큰까지**이고 `TimeToFirstToken`은 **스트리밍 API에만** 있다 |

- **리랭커**를 쓰는 두 경로는 **`Rerank` API 직접 호출**과 **지식 베이스의 `Retrieve`·`RetrieveAndGenerate`에서 지정**입니다. ⚠️ **리랭킹 결과가 지식 베이스의 기본 순위를 덮어쓰고** ⚠️ **텍스트 데이터에만** 적용됩니다.
- ⭐ 리랭킹의 값은 **더 적지만 더 관련 있는 결과를 모델에 넣어 비용과 지연을 함께 줄이는 것**입니다 — 그래서 검색 품질 개선이 그대로 성능·비용 개선이 됩니다.
- ⚠️⚠️ **반환 결과 수가 요청보다 적어지는 경로가 둘**이고 **오류 없이** 적게 옵니다 — **계층형 청킹**(자식 청크가 부모로 대체된다)과 **표·그림 맥락 교체**(같은 맥락을 공유하는 청크가 한 결과로 합쳐진다). 검색 품질 테스트에서 「요청 수와 반환 수가 다르다」를 결함으로 읽으면 오진입니다.

---

### 7) 에이전트 성능 프레임워크 (기술 5.1.7) {#agent-perf}

> 🧠 원리: 에이전트의 출력은 **마지막 문장 하나가 아니라 거쳐 온 궤적 전체**입니다. 올바른 답에 엉뚱한 경로로 닿았다면 그 성공은 재현되지 않습니다. 그래서 평가 입력이 프롬프트가 아니라 **세션·트레이스·스팬**이고, 평가자가 **어느 층을 보는지**에 따라 수준이 갈립니다.

**AgentCore 평가 유형이 셋**입니다(+프리뷰 하나).

| 유형 | 언제·어떻게 | 비자명한 점 |
|---|---|---|
| **온라인** | 배포된 에이전트를 **라이브 운영 트래픽**으로 계속 평가 | **세션 샘플링·필터링**을 구성한다 — **비율 기반**(예 10%) 또는 **조건 필터** |
| **온디맨드** | **스팬·트레이스 ID를 지정**해 고른 상호 작용만 | 사용자 지정 평가자 시험 · 보고된 문제의 수정 검증 · 과거 데이터 분석. **빌드 시점 테스트**에 맞다 |
| **배치** | 여러 세션을 **비동기 작업 하나**로 | ⭐ **세션 발견·스팬 수집·채점을 서비스가 한다**(온디맨드는 내가 스팬을 모아 세션마다 호출한다). **CloudWatch Logs 위치**와 평가자를 주면 **평가자별 평균과 세션 수**를 돌려주고 세션별 상세는 CloudWatch Logs에 쓴다 |
| 데이터세트 (**프리뷰**) | 데이터세트 스키마 + 온디맨드·배치 러너 | — |

⭐ **배치만 그라운드 트루스를 세션 메타데이터로 받습니다**(기대 응답·어서션·**기대 도구 궤적**) — 「도구 사용 효율성 평가」가 여기서 근거를 얻습니다.

**평가자는 네 갈래**입니다 — **내장**(`Builtin.<이름>` 형식, ⚠️ **구성을 수정할 수 없다**) · **3자**(DeepEval·AutoEval 오픈소스에서 오고 **ID만 고르면 서비스가 실행**한다) · **사용자 지정**(LLM-판정, 또는 ⭐ **코드 기반 — 내 Lambda 함수로 결정적 검사·정규식·업무 규칙을 LLM 없이**) · **파생**(내장·3자의 로직을 내 모델로).

**⭐ 그리고 평가자가 세 수준으로 갈리고, 수준이 플레이스홀더를 정합니다.**

| 수준 | 대표 평가자 | 플레이스홀더 |
|---|---|---|
| **세션 수준** | `Goal success rate` · `Goal success rate with ground truth` | `context`(세션 전 턴) · `available_tools` |
| **트레이스 수준** | `Coherence` · `Conciseness` · `Correctness` · `Faithfulness` · `Helpfulness` · `Instruction following` · `Response relevance` 등 | `context` · `assistant_turn` |
| **도구 수준** | `Tool parameter accuracy` · `Tool selection accuracy` · `Skill selection accuracy` · `Skill instruction following` | `available_tools` · `context` · `tool_turn` |

- ⭐ **「작업 완료율 측정」은 세션 수준**입니다. 공식 프롬프트가 **대화 끝까지 사용자가 여전히 원하는 목표만** 셉니다(명시적으로 철회·대체된 요청, 사용자가 답을 안 받고 넘어간 요청은 제외).
- ⛔ **내장 평가자의 개수를 묻지 않습니다** — 공식 안에서 **Lens는 13개**로 적고 **프롬프트 템플릿 페이지는 17개를 열거**하며 개요 페이지는 수를 적지 않습니다. 가르칠 것은 **세 수준으로 갈린다는 성질과 ID 형식**입니다.
- **스킬 평가자**는 ⚠️ **스킬 호출마다 결과 하나**입니다(한 세션에서 세 번 호출하면 평가자당 결과 3개). `Builtin.SkillSelectionAccuracy`는 **`Yes`/`No`**이고 `Builtin.SkillInstructionFollowing`은 **5단계**입니다.
- **통찰 평가자**는 점수가 아니라 **패턴·근본 원인·제안 수정**을 돌려줍니다(`Builtin.FailureAnalysis`). ⚠️⚠️ **지금은 배치 평가만 통찰 평가자를 지원합니다.**
- ⚠️⚠️ **계측만으로는 평가되지 않습니다** — 에이전트가 **관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야** 평가 서비스가 읽습니다(`aip-t4-3` 문서 §1·§4).

> ⚠️ 공식 기술이 드는 「Amazon Bedrock Agent 평가」의 그 `Agents`는 **`Agents Classic`이 되어 신규 고객에게 열려 있지 않습니다**(Bedrock 본체·모델·지식 베이스·Guardrails는 영향이 없습니다). 새로 짓는 에이전트 평가의 경로는 **AgentCore Evaluations**입니다.

---

### 8) 보고 시스템 — 시각화와 전달 (기술 5.1.8) {#reporting}

> 🧠 원리: 평가의 마지막 단계는 **점수를 내는 것이 아니라 결정을 끌어내는 것**입니다. 그래서 공식 보고서가 숫자만 주지 않고 **지표·설명·등급 방법·시각화를 한 카드에** 묶습니다 — 보는 사람이 「이 점수가 무엇을 재서 나왔는지」를 같은 화면에서 알 수 있어야 결정이 가능합니다.

- **보고서 카드**는 각각 **지표 · 설명 · 등급 방법**과 **그 지표로 모은 데이터의 시각화**를 함께 보여 줍니다. 사람 평가에서는 등급 방법에 따라 **히스토그램**(Likert·순위)이나 **비율**(선택 버튼·Thumbs)로 나옵니다 — 그것이 공식 기술이 드는 **「모델 비교 시각화」**입니다.
- ⚠️⚠️ **응답 수가 「프롬프트 수 × 프롬프트당 작업자 수(1·2·3)」보다 적으면 S3 출력 파일을 확인**합니다 — **프롬프트가 모델 오류를 일으켜 추론이 없었거나**, **작업자가 그 출력의 평가를 거절**했을 수 있습니다. ⭐ **사람 작업자의 응답만 지표 계산에 쓰입니다.**
- 판정 모델 평가의 콘솔 카드는 **점수 히스토그램과 처음 다섯 프롬프트**의 설명을 보여 주고 **전체 보고서는 내가 지정한 S3 버킷**에 있습니다.
- 에이전트 쪽 배치 평가는 **평가자별 평균과 세션 수**를 돌려주고 **세션별 상세는 CloudWatch Logs**에 씁니다 — 「자동화된 보고 메커니즘」을 붙이는 자리가 거기입니다.
- **시각화 도구**는 **`AWS Quick Sight`**입니다 — ⚠️⚠️ **`AWS Quick`이 Amazon QuickSight에서 발전한 서비스**이고 **QuickSight는 Quick 안의 기능인 `AWS Quick Sight`로 계속**됩니다. ⭐ **기존 QuickSight API·SDK·통합은 변경 없이 계속 동작합니다.** Quick의 기능에는 그 밖에 **Quick Flows · Quick Automate · Quick Index · Quick Research · Apps in AWS Quick**이 있습니다. ⚠️ 공식 시험 가이드의 표기는 **`Amazon Quick`**이고 Lens는 `Amazon Quick Suite`로 적으므로 **이름의 포함 관계나 기능 개수를 묻지 않습니다.**
- 이해관계자 전달의 틀은 **KPI 네 차원**(운영·품질·효율·비즈니스)이고 ⚠️⚠️ **하나라도 빠지면 「완성돼 보이지만 오해를 만드는」 대시보드**가 됩니다. 주간 보고로 **기술·비즈니스 이해관계자가 같은 대시보드**를 보게 하고 **분기별 검토**로 KPI 정의가 아직 현행 사업 목표를 반영하는지 확인합니다(`aip-t4-3` 문서 §1).

---

### 9) 배포 검증 시스템 (기술 5.1.9) {#deploy-validation}

> 🧠 원리: 배포 시점 평가는 **「출시 가능한가」**만 답합니다. FM 업데이트는 그 답이 참인 채로도 신뢰성을 깨뜨릴 수 있습니다 — 모델이 바뀌면 **같은 프롬프트의 응답 분포가 옮겨가기** 때문입니다. 그래서 검증이 두 층입니다: 배포 **전에** 품질을 게이트하고, 배포 **후에** 「여전히 동작하는가」를 계속 묻습니다.

공식 기술이 드는 셋을 수단으로 옮기면 이렇습니다.

| 공식 예시 | 수단 |
|---|---|
| **합성 사용자 워크플로** | 테스트 네 계층의 **E2E·섀도**(§4). ⛔ 특정 합성 모니터링 제품 이름을 공식 근거 없이 끌어오지 않는다 |
| **할루시네이션 비율** | `Builtin.Faithfulness`(프롬프트에 없는 정보) · RAG는 검색된 텍스트 대비 `Faithfulness` |
| **시맨틱 드리프트** | 드리프트 **세 종류**(데이터·개념·성능)와 **행동 지표 기준선**(`aip-t4-3` 문서 §3) |
| **자동화된 품질 검사** | CI/CD **품질 게이트로서의 평가자**(§4) |

**트래픽 수준의 점진 검증**은 §2의 배포 가드레일이 담당합니다 — **카나리**로 일부만 먼저 받고 **베이킹 기간의 CloudWatch 알람**으로 지켜본 뒤 나머지를 옮기며, 알람이 울리면 **자동 롤백**합니다.

**지속 평가**의 규율 넷이 공식에 있습니다.

- 안티패턴 넷: **배포 시점만 평가** · ⚠️ **자동 지표만 쓰고 주기적 사람 평가를 빼기**(뉘앙스·적절성·사업 맥락 정합은 자동 지표가 온전히 못 잡습니다) · **모든 에이전트에 같은 일반 기준** · 평가를 운영과 분리해 **평가 부채**를 쌓기.
- 평가 차원 넷(KPI 네 차원과 짝입니다): **출력 품질 · 안전 · 효율 · 비즈니스 정합.** ⭐ **가중치는 용례가 정합니다** — 고객 지원 에이전트는 만족도를, 내부 자동화 에이전트는 효율을 더 무겁게 둡니다. **일반 가중치는 일반적인 결과를 냅니다.**
- ⭐ 경보는 **임계 위반**과 **지속적 하락 추세** 둘 다에 걸고 **단일 시점의 하락**에는 걸지 않습니다 — 진단하기 가장 어려운 느린 문제를 잡는 쪽입니다.
- 역할 분담: **AgentCore Evaluations가 지속 평가**(온디맨드=개발 중 벤치마크 · 온라인=운영 트래픽 샘플링), **Bedrock Evaluations가 모델 수준 평가로 보완**, **주기적 사람 평가가 자동 지표가 놓치는 차원**을 덮습니다.

---

## ✍️ 시험 포인트

- ⚠️⚠️ **대상으로 기계를 가릅니다** — 「두 FM의 요약 품질 비교」는 **Bedrock Evaluations**, 「도구를 올바른 순서로 썼는가」는 **AgentCore Evaluations**입니다. 보기가 둘을 바꿔 놓는 것이 가장 흔한 함정입니다.
- **자동 평가는 작업 유형 하나**라는 제약과 **`delta…`가 강건성 축**이라는 것을 함께 기억합니다.
- ⭐ **프롬프트 라우터도 평가 대상**입니다(평가 대상 모델 유형 여섯 중 하나).
- ⚠️⚠️ **「유창성」 내장 지표는 없습니다** — 보기가 `Builtin.Fluency`류를 들면 그것이 함정입니다. 다만 **부재 자체를 정답으로 외우지 않습니다.**
- **등급 방법 다섯은 「무엇을 묻는가」로 외웁니다** — 「좋았나」는 Likert(히스토그램), 「둘 중 어느 쪽」은 선택 버튼(비율), 「순서대로」는 순위(히스토그램), 「쓸 만한가」는 Thumbs(비율).
- ⚠️⚠️ **작업 팀 50명 · 포털은 계정·리전당 하나 · 처음 추가 때만 알림 · 생성 중 삭제하면 전 작업 접근 상실** — 네 줄이 사람 평가 운영 문항의 핵심입니다.
- ⚠️⚠️ **A2I와 Ground Truth는 신규 고객에게 열려 있지 않고 Ground Truth Plus는 완전 종료**입니다. 새 설계의 주석·검토 경로로 그 둘을 고르는 보기는 공식과 어긋납니다.
- **정확 일치 단정이 비결정적 출력을 깨뜨린다**와 **섀도는 응답을 서빙하지 않는다**가 테스트 계층 문항의 갈림길입니다.
- **RAG 평가는 2 ↔ 10**이고 **ContextCoverage만 그라운드 트루스가 필수**입니다.
- ⚠️⚠️ **카나리는 2단계 · 선형은 n단계**이고 **둘 다 블루/그린의 트래픽 전환 모드**입니다. **롤링은 별 배포 유형**이고, 전부 **비동기·실시간 엔드포인트에만** 적용됩니다.
- ⚠️ **`CloudWatch Evidently`는 완전 종료**라 A/B 설계의 답이 될 수 없습니다.
- ⭐ **QuickSight는 사라지지 않았습니다** — `AWS Quick` 안의 **`AWS Quick Sight`**로 계속되고 **기존 API·SDK·통합이 변경 없이 동작**합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **「AgentCore Evaluations로 모델 둘을 비교한다」** → 그쪽 입력은 **세션·트레이스·스팬**입니다. 모델 비교는 **Bedrock Evaluations**입니다.
- ❌ **「한 자동 평가 작업에 요약과 QA를 함께 넣는다」** → **작업 유형은 하나**만 고릅니다.
- ❌ **「`delta…` 지표가 정확도 지표다」** → **강건성** 축입니다(섭동 입력과 원 입력의 차이).
- ❌ **「유창성 지표를 켜면 된다」** → 판정 내장 지표에도 자동 평가 지표에도 없습니다. **사용자 지정 지표**로 갑니다.
- ❌ **「사람 평가에 작업자 200명을 넣는다」** → **작업 팀당 최대 50명**입니다.
- ❌ **「새 평가 작업을 할당하면 작업자에게 알림이 간다」** → **처음 작업 팀에 추가될 때만** 갑니다. 그 뒤로는 **내가 포털 URL을 알려야** 합니다.
- ❌ **「응답 수가 적은 것은 집계 버그다」** → **모델 오류로 추론이 없었거나 작업자가 거절**한 경우입니다. S3 출력 파일을 봅니다.
- ❌ **「새 주석 워크플로를 A2I나 Ground Truth로 만든다」** → 둘 다 **신규 고객에게 열려 있지 않습니다**(기존 고객은 계속 사용 가능하되 새 기능 도입 계획이 없습니다).
- ❌ **「E2E 테스트에서 응답 문자열이 기대와 같은지 단정한다」** → 비결정적 출력을 깨뜨립니다. **의미 동등성**을 봅니다.
- ❌ **「섀도 테스트는 새 버전 응답을 일부 사용자에게 보여 준다」** → **서빙하지 않습니다.** 일부에게 보여 주는 것은 **카나리**입니다.
- ❌ **「`Retrieve only` 평가에 ContextCoverage를 쓰면 바로 된다」** → **프롬프트 데이터세트에 그라운드 트루스**가 있어야 합니다.
- ❌ **「반환 결과가 요청보다 적으니 검색이 실패했다」** → **계층형 청킹과 표·그림 맥락 교체**가 오류 없이 결과를 줄입니다.
- ❌ **「내장 평가자는 13개다」/「17개다」** → 공식 안에서 **어긋나므로 개수를 묻지 않습니다.** 외울 것은 **세 수준**입니다.
- ❌ **「통찰 평가자를 온라인 평가에 붙인다」** → **지금은 배치 평가만** 지원합니다.
- ❌ **「관찰성을 계측했으니 평가가 돌아간다」** → **관찰성을 켜서 CloudWatch로 내보내야** 평가 서비스가 읽습니다.
- ❌ **「카나리와 선형은 같은 것이다」** → 카나리는 **2단계**, 선형은 **n개의 선형 간격 단계**입니다.
- ❌ **「배포 가드레일로 배치 변환 작업을 점진 전환한다」** → **비동기 추론과 실시간 추론 엔드포인트에만** 적용됩니다.
- ❌ **「배포 시점에 평가를 통과했으면 운영 품질이 보장된다」** → 배포 전 평가는 **출시 준비**만, 배포 후 평가가 **「여전히 동작하는가」**를 봅니다.

---

## 🧪 자가 점검

**Q1.** 「두 FM 가운데 어느 쪽이 우리 요약 작업에 맞는지」와 「우리 에이전트가 도구를 올바른 순서로 쓰는지」를 모두 재려고 합니다. 각각 어떤 기계로 어떻게 재야 합니까?

<details><summary>정답 보기</summary>

**평가 기계가 둘이고 대상이 달라 하나로 둘을 할 수 없습니다.** ⚠️⚠️ **Amazon Bedrock Evaluations**는 **모델과 지식 베이스**를 평가하고 입력이 **프롬프트 데이터세트**이므로 **FM 둘의 요약 품질 비교**가 그쪽입니다 — 자동 평가의 **텍스트 요약** 작업 유형을 고르면 정확도는 **BERTScore**, 강건성은 **BERTScore와 deltaBERTScore**, 독성 지표가 계산되고 내장 데이터세트는 **Gigaword**입니다(⚠️ **한 작업에 작업 유형 하나**). 더 세밀한 축이 필요하면 **판정 모델 평가**의 내장 지표(`Builtin.Correctness`·`Completeness`·`Faithfulness` 등)를 쓰고, 주관적 판단이 필요하면 **사람 작업자 평가**를 씁니다. **Amazon Bedrock AgentCore Evaluations**는 **에이전트**를 평가하고 입력이 **세션·트레이스·스팬**이므로 **도구 궤적**이 그쪽입니다 — **도구 수준 평가자**(`Tool selection accuracy`·`Tool parameter accuracy`)를 쓰고, 「올바른 순서」를 참조와 비교하려면 ⭐ **배치 평가의 그라운드 트루스에 기대 도구 궤적**을 넣습니다(기대 응답·어서션과 함께). ⚠️ 전제가 하나 있습니다 — **계측만으로는 평가되지 않고 관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야** 합니다.
</details>

**Q2.** 평가 설계 문서에 「품질 지표로 관련성·사실적 정확성·일관성·유창성을 내장 지표로 켠다」고 적혀 있습니다. 어떻게 검토합니까?

<details><summary>정답 보기</summary>

**셋은 그대로 되고 하나는 안 됩니다.** 관련성은 **`Builtin.Relevance`**, 사실적 정확성은 **`Builtin.Correctness`**(+ 프롬프트에 없는 정보를 보는 **`Builtin.Faithfulness`**), 일관성은 **`Builtin.Coherence`**가 있습니다. ⚠️⚠️ 그런데 **「유창성」에 대응하는 내장 지표는 판정 모델 평가의 내장 지표 목록에 없고 자동 평가 지표(정확도·강건성·독성)에도 없습니다.** 그 자리는 **판정 프롬프트를 직접 쓰는 사용자 지정 지표**로 갑니다(AgentCore 쪽에는 **`Conciseness`** 같은 다른 축이 있습니다). ⚠️ 함께 볼 것 — **`Builtin.Correctness`는 참조 응답(그라운드 트루스)을 주면 평가자가 그것을 고려**하므로 사실적 정확성을 재려면 참조 응답을 데이터세트에 넣는 쪽이 강합니다. ⛔ 그리고 **「공식에 유창성 지표가 없다」를 그 자체로 외우지 않습니다** — 지표 목록은 개정되고, 이 레포의 다른 트랙에서 「사라졌다」고 기록한 목록이 뒤에 되살아난 일이 있습니다. 검토 결과는 **「유창성만 사용자 지정 지표로 돌린다」**입니다.
</details>

**Q3.** 사람 평가로 모델 둘을 비교하려고 합니다. 「어느 쪽이 더 나은지」와 「각각이 쓸 만한지」를 모두 알고 싶습니다. 등급 방법을 어떻게 고르고 보고서에서 무엇을 보게 됩니까?

<details><summary>정답 보기</summary>

**두 질문이 다른 등급 방법으로 갑니다.** 「어느 쪽이 더 나은지」는 **비교형**입니다 — **선택 버튼(라디오)**은 선호를 하나 고르게 하고 보고서가 **모델별 선호 비율(%)**(`comparisonChoice`)로 나오며, **Likert 비교**는 선호의 **강도**를 5점으로 받아 **선호 강도 히스토그램**(`comparisonLikertScale`)으로 나옵니다. 셋 이상을 줄 세우려면 **순위**(`comparisonRank`, 데이터 유형 이름은 ⭐ **Preference Rank**, 히스토그램)입니다. 「각각이 쓸 만한지」는 **개별형**입니다 — **Thumbs up/down**(`thumbsUpDown`, **모델별 thumbs up 비율**)이나 **단일 Likert**(`individualLikertScale`, **5점 히스토그램**)이고 ⭐ **둘 다 모델이 여럿이어도 각 모델 응답마다 제시되며 보고서가 모델별로 집계**합니다. ⚠️ 어느 방법이든 공식이 같은 주의를 반복합니다 — **척도의 중요 지점·순위 1의 의미·「수용 가능」의 기준을 지시문에 정의**해야 합니다. ⚠️⚠️ 보고서를 볼 때 **응답 수가 「프롬프트 수 × 프롬프트당 작업자 수(1·2·3)」보다 적으면** S3 출력 파일을 확인합니다 — **모델 오류로 추론이 없었거나 작업자가 평가를 거절**한 경우이고, ⭐ **사람 작업자의 응답만 지표 계산에 쓰입니다.**
</details>

**Q4.** 사람 검토 워크플로를 새로 만들려고 하는데 팀이 「Amazon A2I로 저신뢰 예측을 사람에게 보내고 Ground Truth로 주석을 받자」고 제안했습니다. 어떻게 판단합니까?

<details><summary>정답 보기</summary>

**둘 다 신규 고객에게 열려 있지 않아 새로 도입할 수 없습니다.** ⚠️⚠️ 공식 페이지가 **`Amazon SageMaker A2I is no longer open to new customers.`**로 적고 **기존 고객은 계속 쓸 수 있으며 AWS가 보안·가용성 개선에는 계속 투자하지만 새 기능을 도입할 계획은 없다**고 밝힙니다. **`Amazon SageMaker Ground Truth`도 같은 문구**입니다. ⚠️ 그리고 **`Ground Truth Plus`는 완전 종료**라 본체와 섞으면 거짓이 됩니다(본체는 「신규 고객 비개방」, Plus는 「완전 종료」로 상태가 다릅니다). ⭐ 새로 짓는 설계의 사람 평가 경로는 **Bedrock의 사람 기반 모델 평가 작업과 그 작업 팀**입니다 — 작업 팀은 **내가 고른 사내 직원이나 업계 주제 전문가**이고 **최대 50명**이며, 생성 후 관리의 콘솔 경로는 **Amazon Cognito**입니다(Ground Truth 콘솔도 쓸 수 있지만 그쪽은 신규 고객에게 닫혀 있습니다). ⚠️ 작업 운영에서 기억할 것 — **작업자 포털은 계정·리전당 하나**이고 **처음 작업 팀에 추가될 때만 알림이 가며**, **평가 작업 생성 중 작업자를 삭제하면 그가 할당된 모든 평가 작업의 접근을 잃습니다.**
</details>

**Q5.** CI 파이프라인에 「프롬프트 템플릿을 바꾸면 샘플 100개의 응답이 기준 파일과 동일한지 확인한다」는 단계가 있습니다. 매번 실패합니다. 어떻게 다시 설계합니까?

<details><summary>정답 보기</summary>

**정확 일치 단정이 비결정적 LLM 출력을 깨뜨리는 것**입니다 — 공식이 그것을 안티패턴으로 적습니다. 다시 설계하는 축은 **테스트 네 계층**입니다: **단위**(프롬프트 템플릿·도구 호출 로직·메모리 검색·결정 라우팅 — ⭐ **결정성이 필요하면 LLM 응답을 목으로** 둡니다) · **통합**(**실제 엔드포인트가 있는 스테이징**) · **E2E**(전체 워크플로 — ⚠️ **정확 일치보다 의미 평가**) · **섀도**(⭐ **트래픽 미러링**으로 운영과 병행 실행하되 **새 버전 응답은 서빙하지 않는다**). 「기준 파일과 같은가」는 **의미 동등성 검사**로 바꾸고, ⭐ **CI/CD의 품질 게이트로 평가자를 쓰면 비트 단위 비교 없이** 품질 회귀를 막을 수 있습니다. 회귀의 참조 데이터는 **배치 평가의 그라운드 트루스**(기대 응답·어서션·기대 도구 궤적)로 두고, 공식 용례가 **기준선 측정 · 변경 전후 비교 · 큐레이션된 세션 집합의 회귀 테스트 · 주기적 품질 감사**입니다. ⚠️ 그리고 **테스트 데이터세트를 역량 변화에 맞춰 갱신**해야 합니다 — 갱신하지 않으면 테스트가 낡아 회귀 탐지 가치를 잃습니다.
</details>

**Q6.** RAG 챗봇의 답이 자주 어긋납니다. 검색이 문제인지 생성이 문제인지 가르고 싶습니다. 어떤 평가를 어떻게 구성합니까?

<details><summary>정답 보기</summary>

**RAG 평가의 작업 유형 둘이 정확히 그 구분입니다.** **`Retrieve only`**는 검색만 보고 내장 지표가 **둘**입니다 — `Builtin.ContextRelevance`와 `Builtin.ContextCoverage`(⚠️ **커버리지는 프롬프트 데이터세트에 그라운드 트루스가 있어야** 합니다). **`Retrieve and generate`**는 **열**입니다 — Correctness · Completeness · Helpfulness · LogicalCoherence · **Faithfulness**(검색된 텍스트 대비 할루시네이션 회피) · **CitationPrecision** · **CitationCoverage** · Harmfulness · Stereotyping · Refusal. 먼저 `Retrieve only`로 **검색 자체의 관련성**을 재고, 거기서 문제가 없으면 `Retrieve and generate`의 **Faithfulness와 인용 지표**로 생성 쪽을 봅니다. 검색이 문제라면 수단이 **리랭커**입니다 — 쿼리와 청크의 관련성을 다시 계산해 재정렬하고, **`Rerank` API 직접 호출** 또는 **`Retrieve`·`RetrieveAndGenerate`에서 지정**해 씁니다(⚠️ **기본 순위를 덮어쓰고 텍스트 전용**). ⚠️⚠️ 진단 중 오해하기 쉬운 것 — **반환 결과 수가 요청보다 적은 것은 오류가 아닙니다.** **계층형 청킹**(자식이 부모로 대체)과 **표·그림 맥락 교체**(같은 맥락 청크가 한 결과로 합쳐짐) 두 경로가 **오류 없이** 결과를 줄입니다. ⭐ **외부 RAG 소스**의 응답 데이터를 가져와 평가할 수도 있어 **서로 다른 RAG 시스템을 비교해 고를 수** 있습니다.
</details>

**Q7.** 「에이전트 내장 평가자 13개 중 작업 완료율은 무엇입니까」라는 질문을 받았습니다. 어떻게 답합니까?

<details><summary>정답 보기</summary>

**개수 전제를 받지 않고 수준으로 답합니다.** ⚠️⚠️ 내장 평가자의 **개수가 공식 안에서 어긋납니다** — Agentic AI Lens는 **`Thirteen built-in evaluators`**로 적고, 프롬프트 템플릿 페이지는 **17개를 열거**하며(세션 2 + 트레이스 11 + 도구 4), 내장 평가자 개요 페이지는 **수를 적지 않습니다**. ⛔ 그래서 **개수는 묻지도 외우지도 않습니다.** 답해야 하는 성질은 **세 수준으로 갈린다**는 것과 **ID가 `Builtin.<이름>` 형식**이라는 것입니다. 「작업 완료율」은 **세션 수준**의 **`Goal success rate`**(그라운드 트루스 변형도 있습니다)이고, ⭐ 공식 프롬프트가 **대화 끝까지 사용자가 여전히 원하는 목표만** 셉니다 — **명시적으로 철회·대체된 요청과 사용자가 답을 받지 않고 넘어간 요청은 제외**합니다. ⚠️ 수준이 플레이스홀더를 정하므로(세션은 `context`·`available_tools` / 트레이스는 `context`·`assistant_turn` / 도구는 `available_tools`·`context`·`tool_turn`) **사용자 지정 평가자도 수준을 먼저 고릅니다.** ⚠️ 내장 평가자는 **구성을 수정할 수 없고**(일관성·신뢰성 보존), 수정이 필요하면 **파생 평가자**나 **사용자 지정**(LLM-판정 또는 ⭐ **Lambda 기반 코드 평가자**)으로 갑니다.
</details>

**Q8.** 분기 보고에 「모델 평가 결과를 경영진 대시보드로 올려 달라」는 요청이 왔습니다. 무엇을 어디서 가져오고 어떤 도구로 그립니까?

<details><summary>정답 보기</summary>

**결과가 세 곳에 있고 성격이 다릅니다.** 사람 평가는 **보고서 카드**가 **지표·설명·등급 방법 + 데이터 시각화**를 함께 보여 주고, 등급 방법에 따라 **히스토그램**(Likert·순위)이나 **비율**(선택 버튼·Thumbs)로 나옵니다 — 그것이 공식이 드는 **「모델 비교 시각화」**입니다. 판정 모델 평가는 콘솔 카드가 **점수 히스토그램과 처음 다섯 프롬프트**의 설명만 보여 주고 ⭐ **전체 보고서는 내가 지정한 S3 버킷**에 있으므로, 자동화된 보고는 그 S3 산출물을 읽습니다. 에이전트 쪽 **배치 평가**는 **평가자별 평균과 세션 수**를 돌려주고 **세션별 상세는 CloudWatch Logs**에 씁니다. 그리는 도구는 **`AWS Quick Sight`**입니다 — ⚠️⚠️ **`AWS Quick`이 Amazon QuickSight에서 발전한 서비스**이고 **QuickSight는 Quick 안의 기능인 `AWS Quick Sight`로 계속**되며 ⭐ **기존 QuickSight API·SDK·통합은 변경 없이 동작**합니다(그 밖의 기능으로 Quick Flows·Quick Automate·Quick Index·Quick Research·Apps in AWS Quick이 있습니다). ⚠️ 공식 시험 가이드 표기는 **`Amazon Quick`**이고 Lens는 `Amazon Quick Suite`로 적으므로 **이름의 포함 관계나 기능 개수를 묻지 않습니다.** ⚠️⚠️ 대시보드를 설계할 때 **KPI 네 차원**(운영·품질·효율·비즈니스) 중 빠진 것이 없는지 봅니다 — 하나라도 빠지면 **「완성돼 보이지만 오해를 만드는」 대시보드**가 되고, **분기별 검토**로 KPI 정의가 현행 사업 목표를 반영하는지 확인합니다.
</details>

**Q9.** FM을 새 버전으로 올리려고 합니다. 평가 점수는 올랐습니다. 운영 전환을 어떻게 설계하고 전환 뒤에는 무엇을 계속 봅니까?

<details><summary>정답 보기</summary>

**전환은 배포 가드레일, 전환 뒤는 지속 평가입니다.** ⚠️ 먼저 **배포 전 평가는 「출시 가능한가」만 답한다**는 것을 전제합니다. 전환 설계는 SageMaker AI **배포 가드레일**이고 유형이 둘입니다 — **블루/그린**(트래픽 전환 모드 **한 번에 전부 · 카나리 · 선형**)과 **롤링**(내가 지정한 배치 크기로 점진 프로비저닝). ⚠️⚠️ **카나리는 일부를 먼저 옮겨 베이킹 기간 동안 지켜본 뒤 나머지를 옮기는 2단계**이고 **선형은 그것을 n개의 선형 간격 단계로 확장**한 것입니다. ⭐ **베이킹 기간에 사전 지정한 CloudWatch 알람이 새 플릿을 모니터링하고 울리지 않으면 옛 플릿을 종료**하며 **자동 롤백**이 내장돼 있습니다(진행은 **`DescribeEndpoint`** 또는 **CloudWatch Events**). ⚠️⚠️ 제약 둘 — **비동기 추론과 실시간 추론 엔드포인트에만** 적용되고, **엔드포인트가 Exclusions 페이지의 기능을 쓰면 배포 가드레일도 CloudWatch Events도 쓸 수 없습니다.** 전환 뒤에는 **지속 평가**입니다 — 안티패턴 넷(배포 시점만 평가 · **자동 지표만 쓰고 주기적 사람 평가를 빼기** · 모든 에이전트에 같은 일반 기준 · 평가 부채)을 피하고, 평가 차원 넷(**출력 품질·안전·효율·비즈니스 정합**)에 ⭐ **용례가 정하는 가중치**를 둡니다. ⭐ 경보는 **임계 위반과 지속적 하락 추세 둘 다**에 걸고 **단일 시점의 하락에는 걸지 않습니다.** 시맨틱 드리프트는 **드리프트 세 종류**(데이터·개념·성능)로 가르고 **행동 지표 기준선**으로 봅니다.
</details>

**Q10.** 팀이 「새 프롬프트를 사용자 10%에게만 노출하는 A/B를 CloudWatch Evidently로 구성하자」고 합니다. 어떻게 판단하고 무엇으로 대체합니까?

<details><summary>정답 보기</summary>

**Evidently로는 할 수 없습니다.** ⚠️⚠️ 공식 AWS Lifecycle Changes 목록이 **`Amazon CloudWatch Evidently`를 완전 종료**로 적고, 전용 문서 페이지도 더 이상 제공되지 않습니다(슬러그를 열면 가이드 인덱스로 돌아가는데, 이는 **없는 슬러그와 같은 신호**입니다). 대체는 **층을 나눠** 봅니다. **평가 축**은 **프롬프트 관리의 버전과 변형**으로 두 구성을 만들고 **평가 작업으로 같은 척도에 채점**합니다 — 자동 평가(작업 유형 하나), 판정 모델 평가(내장 지표 11종 또는 사용자 지정 지표), 필요하면 **사람 평가의 선택 버튼이나 Likert 비교**로 선호를 받습니다. **트래픽 축**은 **배포 가드레일의 카나리**입니다 — 일부 트래픽을 새 플릿으로 먼저 보내 **베이킹 기간의 CloudWatch 알람**으로 지켜보고, 더 세밀한 단계가 필요하면 **선형**으로 n단계로 나눕니다. **에이전트라면 온라인 평가**가 그 자리를 덮습니다 — ⭐ **라이브 운영 트래픽을 비율 기반(예 10%) 또는 조건 필터로 샘플링**해 계속 채점하므로, 「10%에만 노출해 비교」라는 요구의 평가 쪽이 거기서 성립합니다.
</details>

---

### 📌 출처

1. Amazon Bedrock 평가 개요 (네 종류 · 평가 대상 모델 유형 여섯 — 프롬프트 라우터·PT 모델 포함) — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html` (2026-11-15 확인)
2. 판정 모델 평가 (생성·평가자 모델 · 응답 직접 제공 시 호출 생략 · 평가자 모델 목록이 지표 종류마다 다름) — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation-judge.html` (2026-11-15 확인)
3. 판정 모델 평가의 내장 지표 (11종과 ID · Correctness의 참조 응답 · Faithfulness의 정의 · Stereotyping은 긍정도 포함 · 콘솔 히스토그램과 처음 다섯 프롬프트 · 전체 보고서는 S3) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html` (2026-11-15 확인)
4. 자동 평가의 작업 유형 (한 작업에 유형 하나 · 작업 유형 넷과 내장 데이터세트 · RWK·BERTScore·NLP-F1 · delta는 강건성) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-tasks.html` (2026-11-15 확인)
5. 사람 작업자를 쓰는 모델 평가 작업 (하위 절차의 목차) — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation-human.html` (2026-11-15 확인)
6. 사람 평가의 작업 팀 관리 (최대 50명 · 포털은 계정·리전당 하나 · 처음 추가 때만 알림 · 생성 중 삭제 시 전 작업 접근 상실 · Ground Truth 프라이빗 워크포스 · Cognito·Ground Truth·A2I에서 만든 작업 팀이 보인다) — `docs.aws.amazon.com/bedrock/latest/userguide/human-worker-evaluations.html` (2026-11-15 확인)
7. 사람 기반 평가 작업 만들기 (추론 소스 최대 둘·유형 혼합 가능 · Source Name == `modelIdentifier` · 모델 지시는 프롬프트에) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-jobs-management-create-human.html` (2026-11-15 확인)
8. 사람 기반 평가 보고서 검토 (등급 방법 **다섯**과 JSON 키·시각화 · 보고서 카드의 구성 · 응답 수 부족의 두 원인 · 사람 응답만 지표 계산) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-report-human-customer.html` (2026-11-15 확인)
9. AgentCore Evaluations 작동 방식 (에이전트 대상 · 밖에 호스팅된 에이전트도 · 목표 달성·도구 정확성) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/how-it-works-evaluations.html` (2026-11-15 확인)
10. AgentCore 평가 유형 (온라인·온디맨드·배치 + 데이터세트 프리뷰 · 샘플링과 조건 필터 · 배치만 그라운드 트루스 · 평가자별 평균과 세션 수) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html` (2026-11-15 확인)
11. AgentCore 평가자 네 갈래 (내장·3자 DeepEval·AutoEval·사용자 지정 LLM·코드 기반 Lambda·파생) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluators.html` (2026-11-15 확인)
12. AgentCore 내장 평가자 개요 (`Builtin.<이름>` · 구성 수정 불가 · 개수를 적지 않는다) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html` (2026-11-15 확인)
13. AgentCore 내장 평가자의 프롬프트 템플릿 (세 수준 열거 · 수준별 플레이스홀더 · 세션 수준 목표 판정 규칙) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/prompt-templates-builtin.html` (2026-11-15 확인)
14. AgentCore 스킬 평가자 (둘 · 호출마다 결과 하나 · `Yes`/`No`와 5단계) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/skill-evaluators.html` (2026-11-15 확인)
15. AgentCore 통찰 평가자 (`Builtin.FailureAnalysis` · 패턴·근본 원인·제안 수정 · **배치만** 지원) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/insight-evaluators.html` (2026-11-15 확인)
16. 관찰성 지원 프레임워크와 계측 (계측만으로는 평가되지 않는다 · 기대 도구 궤적) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html` (2026-11-15 확인)
17. AGENTOPS06-BP01 테스트 네 계층 (단위·통합·E2E·섀도 · 정확 일치 단정의 문제 · 품질 게이트로서의 평가자 · 내장 평가자 「13개」 서술) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp01.html` (2026-11-15 확인)
18. AGENTOPS06-BP02 지속 평가 (배포 전·후의 역할 · 안티패턴 넷 · 평가 차원 넷과 용례별 가중치 · 임계와 추세 둘 다 · 합성 점수) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops06-bp02.html` (2026-11-15 확인)
19. AGENTOPS05-BP04 KPI 네 차원 (하나라도 빠지면 오해를 만드는 대시보드 · 주간 보고 · 분기별 검토) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp04.html` (2026-11-15 확인)
20. RAG 평가 작업 (작업 유형 둘 · 외부 RAG 소스 · 사용자 지정 지표) — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation-kb.html` (2026-11-15 확인)
21. RAG 평가 지표 (Retrieve only 둘 ↔ Retrieve and generate 열 · ContextCoverage의 그라운드 트루스 요구 · 인용 지표) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html` (2026-11-15 확인)
22. 리랭킹 (쿼리·청크 관련성 재계산 · 두 경로 · 기본 순위 override · 텍스트 전용 · 비용과 지연 동시 감소) — `docs.aws.amazon.com/bedrock/latest/userguide/rerank.html` (2026-11-15 확인)
23. SageMaker AI 배포 가드레일 (블루/그린과 롤링 · 전환 모드 셋 · 카나리 2단계 ↔ 선형 n단계 · 베이킹 기간과 CloudWatch 알람 · 자동 롤백 · `DescribeEndpoint`·CloudWatch Events · 비동기·실시간 전용 · Exclusions) — `docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails.html` (2026-11-15 확인)
24. Amazon Augmented AI로 사람 검토하기 (신규 고객 비개방 · 기존 고객 계속 · 새 기능 도입 계획 없음 · 저신뢰 예측과 무작위 표본의 사람 검토 루프) — `docs.aws.amazon.com/sagemaker/latest/dg/a2i-use-augmented-ai-a2i-human-review-loops.html` (2026-11-15 확인)
25. SageMaker Ground Truth (신규 고객 비개방 · 같은 문구 · 프라이빗 워크포스와 벤더 · 자동 데이터 레이블링) — `docs.aws.amazon.com/sagemaker/latest/dg/sms.html` (2026-11-15 확인)
26. AWS Quick이란 무엇인가 (QuickSight에서 발전 · `AWS Quick Sight`로 계속 · **기존 API·SDK·통합은 변경 없이 동작** · 기능 목록) — `docs.aws.amazon.com/quick/latest/userguide/what-is.html` (2026-11-15 확인)
