---
examGuideTaskId: aif-t3-4
certCode: AIF-C01
domain: 3
domainName: 파운데이션 모델의 적용
domainWeightPct: 28
title: FM 성능 평가 (평가 접근 방식·지표·애플리케이션 평가·비즈니스 목표 조정)
coversTasks:
  - "3.4"
sources:
  - title: Evaluate the performance of Amazon Bedrock resources
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html
  - title: EvaluationDatasetMetricConfig (Amazon Bedrock API Reference)
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_EvaluationDatasetMetricConfig.html
  - title: Review metrics for an automated model evaluation job in Amazon Bedrock (console)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-report-programmatic.html
  - title: Review metrics for RAG evaluations that use LLMs (console)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-eval-llm-results.html
  - title: Use prompt datasets for model evaluation in Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-prompt-datasets.html
  - title: HumanEvaluationCustomMetric (Amazon Bedrock API Reference)
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_HumanEvaluationCustomMetric.html
  - title: Built-in metric evaluator prompts for model-as-a-judge evaluation jobs
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-type-judge-prompt.html
  - title: Accuracy (Amazon SageMaker AI 파운데이션 모델 평가)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-accuracy-evaluation.html
  - title: Clarify availability change
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html
  - title: How it works (Amazon Bedrock AgentCore Evaluations)
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/how-it-works-evaluations.html
  - title: Evaluation types (Amazon Bedrock AgentCore Evaluations)
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html
  - title: Built-in evaluators (Amazon Bedrock AgentCore Evaluations)
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html
  - title: Evaluators and evaluations (Amazon CloudWatch)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/omni-agents-evaluators.html
  - title: AGENTREL02-BP03 Implement behavioral anomaly detection and monitoring
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentrel02-bp03.html
  - title: Delivering and sustaining the value of a generative AI application
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/prod-value.html
  - title: Measuring the success of generative AI in software development
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-accelerate-software-dev-lifecycle-gen-ai/measuring-success.html
  - title: AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html
lastVerified: 2026-11-03
---

# FM 성능 평가 (평가 접근 방식·지표·애플리케이션 평가·비즈니스 목표 조정)

> **커버하는 공식 Task** — AIF-C01 · 도메인 3 「파운데이션 모델의 적용」(28%) · **작업 3.4 FM 성능을 평가하는 방법 설명** (`aif-t3-4`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 목표 5개(3.4.1~3.4.5)를 모두 덮습니다. 도메인 3은 **시험의 가장 큰 덩어리**이고, 3.4는 그 안에서 **"만든 것이 쓸 만한지 어떻게 아는가"**를 묻습니다.

> ⚠️ **가이드 v1.1에서 바뀐 것** — 목표 3.4.2의 지표 목록에 **LLM-as-a-judge**가 들어왔습니다. 그리고 **목표 3.4.5(비즈니스 목표 조정 지표)가 v1.1에서 새로 생겼습니다.** 2026-04-30 이전 교재는 이 둘을 빠뜨립니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 평가 접근 방식을 **사람 · 벤치마크 데이터세트 · 관리형 평가**로 가르고 각자 언제 쓰는지 말한다
- [ ] Amazon Bedrock 모델 평가의 **네 종류**와 각자 쓸 수 있는 **지표 집합이 다름**을 안다
- [ ] ROUGE · BLEU · BERTScore · LLM-as-a-judge를 **무엇을 어떻게 재는가**로 가른다
- [ ] 같은 「Accuracy」가 **작업 유형마다 다른 수식**인 것을 안다
- [ ] 기술 지표를 **비즈니스 성과로 번역하는 방향**을 쥔다(생산성·사용자 참여)
- [ ] **모델 평가와 애플리케이션 평가가 다르다**는 것을 알고 RAG·에이전트 평가 지표를 고른다
- [ ] 3.4.5의 조정 지표 세 개가 **어디서 나오는 숫자인지** 말한다

---

## 🎯 왜 중요한가

이 작업은 도메인 3의 마지막 조각이면서, 앞의 세 작업(설계·프롬프트·훈련)이 만든 결과를 **판정**합니다. 그래서 문항이 거의 항상 **"이 상황에서 무엇을 재야 하는가"** 형태로 나옵니다. 모델을 만드는 능력이 아니라 **고르고 읽는 능력**을 묻습니다.

여기서 점수를 잃는 자리는 거의 정해져 있습니다. **평가 종류마다 유효한 지표 집합이 겹치지 않게 정의**돼 있는데, 오답 보기는 **모델 평가 지표를 RAG 평가 자리에 섞어** 둡니다. 그리고 같은 이름의 지표가 **작업 유형마다 다른 수식**으로 계산되는 것을 모르면 "요약 정확도"와 "질의응답 정확도"를 같은 것으로 읽게 됩니다.

> ⚠️ **전통 ML 지표는 여기서 다루지 않습니다.** 정확도·정밀도·재현율·F1의 정의와 불균형 데이터 함정은 작업 1.3이 끝냈습니다(그 문서의 「모델 성능 지표와 비즈니스 지표」 절). 이 문서는 **FM·생성형 AI 평가**에 분량을 씁니다. 다만 **QA 작업의 Accuracy가 F1로 계산된다**는 점에서 둘이 만납니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **Amazon Bedrock 모델 평가는 네 종류**입니다 — 프로그래매틱(알고리즘 채점) · **사람 작업자** · **심사 모델(LLM-as-a-judge)** · **RAG 평가**
- ⚠️ **유효 지표 집합이 겹치지 않게 정의**돼 있습니다 — 자동 모델 평가는 **`Accuracy`·`Robustness`·`Toxicity` 셋뿐**, 검색 전용 RAG 평가는 **`ContextRelevance`·`ContextCoverage` 둘뿐**
- ⚠️ **같은 「Accuracy」가 작업 유형마다 다른 수식**입니다 — 일반 생성 = **RWK 점수** · **요약 = BERT Score** · **질의응답 = F1** · 분류 = accuracy
- **ROUGE는 N-gram 겹침, BERTScore는 임베딩 코사인 유사도**입니다. 겹침 기반은 **정답 텍스트가 필요**하고 **추상적 요약에서 신뢰가 떨어집니다**
- ⚠️ **BLEU는 `docs.aws.amazon.com`에서 평가 지표로 확인되지 않습니다** — 가이드가 드는 일반 NLP 지표로 알아 두고, **AWS 관리형 평가가 계산해 주는 지표로 고르지 않습니다**
- **LLM-as-a-judge는 모델이 둘** 필요합니다(생성기 + 평가자). **점수와 설명을 함께** 주고, 지표가 **다차원 + 책임 있는 AI 3종**입니다
- ⚠️ **판정 방향이 섞입니다** — Accuracy는 **높을수록** 좋고 **Robustness·Toxicity는 낮을수록** 좋습니다. RAG 평가의 Harmfulness·Stereotyping·Refusal도 **높을수록 나쁩니다**
- **애플리케이션 평가 ≠ 모델 평가**입니다 — RAG는 **retrieve only / retrieve and generate** 둘로 갈리고 **ground truth가 데이터셋에 있어야** 기대와 대조됩니다
- **에이전트·워크플로의 정본은 Amazon Bedrock AgentCore Evaluations**입니다 — **작업 완료(목표 달성) 정확성 · 도구 호출 정확성 · 사용자 정의 지표**를 계산하고 평가 수준이 **trace · session · tool call** 셋입니다
- ⚠️ **Amazon SageMaker Clarify는 신규 고객에게 열려 있지 않습니다** — FM 평가의 대체 경로는 **fmeval 라이브러리 · Amazon Bedrock Evaluations · Amazon Bedrock Guardrails**이고, **표형(전통 ML) 편향 탐지·설명 가능성의 대체는 아닙니다**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **벤치마크 데이터세트** | 평가용으로 공개된 프롬프트 모음. Amazon Bedrock은 오픈 소스 데이터셋을 바탕으로 **내장 데이터셋**을 제공합니다 |
| **정답(ground truth)** | 모델 응답과 비교할 **기준 답**. 「정확도」 계열 지표는 대부분 이것 없이는 계산되지 않습니다 |
| **프로그래매틱 평가** | 평가 **알고리즘이 점수를 계산**하는 자동 평가. 사람도 심사 모델도 개입하지 않습니다 |
| **LLM-as-a-judge** | **두 번째 LLM**이 응답을 채점하는 방식. 공식은 그 모델을 **평가자 모델**, 채점 대상 모델을 **생성기 모델**이라 부릅니다 |
| **섭동(perturbation)** | 의미를 보존한 작은 입력 변형(오타·대소문자·공백 등). **강건성**을 재는 데 씁니다 |
| **trace · session · tool call** | 에이전트 평가의 세 수준 — **요청·응답 한 쌍** · **대화 전체** · **도구 호출 하나** |
| **온라인 평가** | **라이브 프로덕션 트래픽**을 지속적으로 채점하는 평가(개발 환경의 1회성 평가와 대비됩니다) |
| **KPI** | 핵심 성과 지표. 3.4.5는 기술 지표를 **이것으로 번역**하는 문제입니다 |

---

## 📖 핵심 개념

### 1) 평가 접근 방식을 결정한다 (목표 3.4.1) {#approaches}

공식 가이드가 드는 예 세 개가 그대로 세 갈래입니다 — **인간 평가 · 벤치마크 데이터세트 · Amazon Bedrock 모델 평가**. 그런데 셋은 배타적이지 않습니다. 관리형 서비스 안에 **사람 평가도 들어 있고** 벤치마크 데이터세트도 **내장**돼 있습니다.

**Amazon Bedrock 평가는 네 종류입니다.** 공식 문서의 분류를 그대로 옮깁니다.

| 종류 | 누가·무엇이 채점하는가 | 공식이 적는 쓸모 |
|---|---|---|
| **프로그래매틱 모델 평가** | **평가 알고리즘**이 계산 | 모델이 **작업을 수행하는 능력을 빠르게** 평가. 내 프롬프트 데이터셋 또는 **내장 데이터셋** |
| **사람 작업자 평가** | **사람** | 평가 과정에 **사람의 입력**을 들인다. **사내 직원** 또는 **업계 주제 전문가 집단** |
| **심사 모델 평가** | **두 번째 LLM** | 응답을 **빠르게** 평가. 그 LLM이 **점수를 주고 응답마다 설명을 함께** 준다 |
| **RAG 평가(LLM 기반)** | **LLM** | 지식 기반·RAG 소스가 **관련 정보를 검색하고 유용·적절한 응답을 생성하는지** |

평가 대상도 공식이 열거합니다 — **파운데이션 모델 · Amazon Bedrock Marketplace 모델 · 사용자 지정 FM · 가져온 FM · 프롬프트 라우터 · 프로비저닝된 처리량을 구매한 모델**. 그리고 **Amazon Bedrock 밖의 모델과 RAG 소스**도 **응답 데이터를 직접 넣으면** 평가됩니다.

**사람 평가의 채점 방식은 다섯 가지**이고 API 값까지 정해져 있습니다 — `ThumbsUpDown` · `IndividualLikertScale` · `ComparisonLikertScale` · `ComparisonChoice` · `ComparisonRank`. 가르는 축은 **비교형인가 개별형인가**입니다.

- **비교형**(Likert 비교 · 선택 버튼 · 순위)은 **두 응답 사이의 선호**를 봅니다. 모델이 둘 이상일 때 쓸 수 있습니다.
- **개별형**(좋아요·싫어요 · Likert 개별)은 **응답 하나를 그 자체로** 봅니다. ⚠️ **모델이 하나면 개별형을 써야 합니다.**

**벤치마크(내장) 데이터세트**는 작업 유형별로 추천됩니다. ⚠️ 공식이 적는 중요한 단서가 있습니다 — 각 내장 데이터셋은 오픈 소스 데이터셋을 **무작위로 다운샘플링해 프롬프트 100개만** 담습니다.

| 작업 유형 | 내장 데이터셋 | 계산되는 지표 |
|---|---|---|
| **일반 텍스트 생성** | TREX · BOLD · WikiText2 · RealToxicityPrompts | 정확도 = **RWK 점수** · 강건성 = **단어 오류율** · 독성 |
| **텍스트 요약** | Gigaword | 정확도 = **BERTScore** · 강건성 = **BERTScore와 deltaBERTScore** · 독성 |
| **질의응답** | BoolQ · NaturalQuestions · TriviaQA | 정확도 = **F1** · 강건성 = **F1과 deltaF1** · 독성 |
| **텍스트 분류** | Women's E-Commerce Clothing Reviews | 정확도 = **accuracy** · 강건성 |

데이터셋의 성격도 공식이 적습니다 — **BOLD**는 **직업·성별·인종·종교 이념·정치 이념 다섯 도메인**으로 **일반 텍스트 생성의 공정성**을 평가하고(프롬프트 23,679개), **RealToxicityPrompts**는 독성 평가용으로 모델이 유해한 표현을 내게 **유도**합니다(프롬프트 100,000개).

**사용자 지정 데이터셋**을 쓰려면 Amazon S3에 **`.jsonl`** 형식으로 올리고, 자동 평가 작업당 **최대 1,000개 프롬프트**까지 넣습니다. 키는 **`prompt`**(필수) · **`referenceResponse`**(정확도·강건성 평가와 질의응답에서 필수인 정답) · **`category`**(선택, 범주별 점수 보고).

> ⚠️ **「SageMaker Clarify로 FM을 평가한다」는 지금 틀린 답입니다.** 공식이 **"Amazon SageMaker Clarify is no longer open to new customers"**라고 적습니다. 기존 고객은 계속 쓸 수 있고 AWS는 보안·가용성 개선은 이어가지만 **신규 기능은 도입하지 않을 계획**입니다. 공식이 적는 대체 경로는 **① fmeval 라이브러리**(SageMaker 호스팅 모델에 권장) **② Amazon Bedrock Evaluations**(관리형) **③ Amazon Bedrock Guardrails**(런타임 안전)입니다. ⚠️ 그리고 공식이 못박는 단서가 있습니다 — 이 셋은 **"표형(전통 ML) 편향 탐지나 설명 가능성의 대체는 아닙니다."** 편향 지표(DPL·DPPL·DI·CI 등)는 **공표된 업계 표준 수식**이라 직접 계산하고, 설명 가능성은 **Clarify가 내부적으로 쓰는 엔진인 SHAP**을 직접 씁니다. 즉 Clarify는 **편향 지표와 SHAP의 유래**로 알아 두는 이름입니다.

### 2) 관련 지표를 파악한다 (목표 3.4.2) {#metrics}

**이 절이 이 문서의 심장입니다.** 가이드가 드는 네 이름을 **무엇을 어떻게 재는가**로 갈라 둡니다.

| 지표 | 재는 방식 | 정답 텍스트 | 공식이 적는 한계 | AWS 관리형 평가에서 |
|---|---|---|---|---|
| **ROUGE** | 생성 요약과 정답 요약 사이의 **N-gram(겹치는 단어 단위) 겹침**. 값은 **0(불일치)~1(완전 일치)**, **대소문자 무시** | **필요** | ⚠️ **추상적 요약에서 신뢰가 떨어집니다** — 점수가 **정확한 단어 겹침**에 의존합니다 | SageMaker AI 요약 정확도의 세 지표 중 하나 |
| **BLEU** | **겹침 기반**으로 기계 번역이 **참조 인간 번역과 얼마나 유사한지** 계산. 보통 **0~1**, 높을수록 좋습니다 | **필요** | ⚠️ AWS는 **"기계 번역 품질을 정확히 재는 유일한 방법은 전문가 검토"**라고 적고, BLEU는 **두 출력 사이의 상대적 품질 개선 추정치**를 준다고 선을 긋습니다 | ⚠️ **계산해 주는 지표 목록에 없습니다**(아래 경고 블록) |
| **BERTScore** | **BERT 계열 모델의 사전 훈련 문맥 임베딩**으로 문장 임베딩을 만들어 **코사인 유사도**로 후보와 참조를 맞춥니다 | **필요** | ⚠️ 비교에 쓰는 **모델의 한계를 상속**하고, **짧은 텍스트에서 중요한 단어 하나가 바뀌면** 신뢰가 떨어집니다 | **Amazon Bedrock 요약 작업의 Accuracy 그 자체** |
| **LLM-as-a-judge** | **평가자 모델**이 응답을 읽고 **점수와 설명**을 냅니다 | 지표에 따라 다릅니다 | ⚠️ 모델이 **둘** 필요하고, 심사 모델에 **트레이스·응답 내용이 전송**됩니다 | **심사 모델 평가**의 다차원 지표 집합 |

> ⚠️ **BLEU는 이 레포가 `docs.aws.amazon.com`에서 근거를 찾지 못한 지표입니다.** 2026-11-03 재탐색에서도 BLEU를 평가 지표로 정의하거나 관리형 평가의 계산 지표로 올려 둔 **문서 페이지는 0건**이었고, 확인된 것은 **AWS 블로그와 사례 연구**뿐입니다(위 표의 정의가 그 블로그 서술입니다). 반면 **ROUGE·BERTScore는 문서에 있습니다.** → 공식 가이드가 드는 이름이니 **일반 NLP 지표로 알아 두되**, **"AWS 평가 작업이 계산해 주는 지표"를 고르는 문항에서는 BLEU를 답으로 쓰지 않습니다.**

**ROUGE의 변종**까지 공식이 적습니다. `ROUGE_1`은 **단어 하나(유니그램)**, `ROUGE_2`는 **단어 쌍(바이그램, 기본값)**, `ROUGE_L`은 **최장 공통 부분수열**입니다 — ⚠️ 부분수열은 **어순은 고려하고 연속성은 고려하지 않습니다**(공식 예: 모델 요약 "It is autumn" ↔ 참조 "It is once again autumn"의 최장 공통 부분수열은 3). 바이그램 계산 예도 공식이 직접 싣습니다: 정답 "The dog played fetch with the ball in the park." ↔ 생성 "The dog played with the ball."에서 공통 바이그램 4개를 정답의 바이그램 9개로 나눠 **`ROUGE-2 = 4/9 = 0.444`**.

**혼동 1순위 — 평가 종류마다 유효 지표 집합이 겹치지 않게 정의돼 있습니다.** 공식 API 레퍼런스가 유효값을 못박습니다.

| 평가 종류 | 유효한 내장 지표 |
|---|---|
| **자동(프로그래매틱) 모델 평가** | **`Builtin.Accuracy` · `Builtin.Robustness` · `Builtin.Toxicity` — 셋뿐입니다** |
| **심사 모델(LLM-as-a-judge)** | `Correctness` · `Completeness` · `Faithfulness` · `Helpfulness` · `Coherence` · `Relevance` · `FollowingInstructions` · `ProfessionalStyleAndTone`, 그리고 **책임 있는 AI** `Harmfulness` · `Stereotyping` · `Refusal` |
| **RAG — 검색 전용** | **`Builtin.ContextRelevance` · `Builtin.ContextCoverage` — 둘뿐입니다** |
| **RAG — 검색 + 응답 생성** | `Correctness` · `Completeness` · `Helpfulness` · `LogicalCoherence` · `Faithfulness` + 책임 있는 AI 3종 |
| **사람 평가** | 내가 정의한 사용자 지정 지표 이름(채점 방식은 위 다섯 중 하나) |

작업 유형(`taskType`)의 유효값도 다섯으로 고정입니다 — **`Summarization` · `Classification` · `QuestionAndAnswer` · `Generation` · `Custom`**.

**혼동 2순위 — 같은 「Accuracy」가 작업 유형마다 다른 수식입니다.** 이것이 3.4.2에서 가장 자주 쓰이는 함정입니다.

| 작업 유형 | Accuracy의 계산 | Robustness의 계산 |
|---|---|---|
| **일반 텍스트 생성** | **RWK 점수**(real world knowledge) — 모델이 **실세계의 사실 지식을 담고 있는 능력** | 의미 강건성(**단어 오류율** 기반) |
| **텍스트 요약** | **BERT Score** | **(Delta BERTScore / BERTScore) × 100** (퍼센트) |
| **질의응답** | **F1 점수**(0~1, 높을수록 좋습니다) | **(Delta F1 / F1) × 100** (퍼센트) |
| **텍스트 분류** | **accuracy** — 예측 클래스를 **정답 레이블과 비교** | (delta 분류 정확도 / 분류 정확도) × 100 |

**Robustness는 전 유형 공통으로 섭동 기반**입니다. 공식이 적는 섭동은 **소문자로 변환 · 키보드 오타 · 숫자를 단어로 변환 · 무작위 대문자화 · 공백의 무작위 추가·삭제**이고, **"데이터셋의 각 프롬프트는 약 5회 섭동됩니다."** **Toxicity는 전 유형 공통으로 detoxify 알고리즘**입니다.

> ⚠️ **판정 방향이 지표마다 다릅니다.** Accuracy는 **높을수록** 좋고, **Robustness는 낮을수록 강건**하며(섭동 때문에 점수가 덜 흔들렸다는 뜻), **Toxicity도 낮을수록** 좋습니다. "강건성 점수가 높아졌다 = 좋아졌다"로 읽으면 틀립니다.

### 3) FM이 비즈니스 목표에 부합하는지 판단한다 (목표 3.4.3) {#business-fit}

3.4.2가 **모델 쪽 숫자**였다면 3.4.3은 **그 숫자가 조직의 목표를 향하고 있는지**를 묻습니다. 출발점은 공식이 적는 **문제 진술**입니다 — **생성형 AI 프로젝트의 핵심 과제는 엔지니어링 팀이 추적하는 기술 지표와 리더십이 기대하는 비즈니스 가치 사이의 단절**입니다. 해법은 PoC 단계의 **평가 프레임워크를 라이브 KPI 모니터링 프레임워크로 키워** 모든 기술 지표가 **의미 있는 비즈니스 성과로 추적되게** 만드는 것이고, 공식은 이것이 **기능 팀 사이의 공용어**를 만든다고 적습니다.

공식 가이드가 3.4.3의 예로 드는 낱말 셋을 차례로 처리합니다.

**생산성.** 공식 처방적 지침이 **「팀 생산성과 만족도」**를 지표 범주로 두고 네 개를 듭니다.

| 지표 | 공식이 적는 내용 |
|---|---|
| **생산성 개선** | **작업별 생산성 비율의 증가**를 모니터링합니다 |
| **만족도 점수** | **정기 설문**으로 팀의 사기와 직무 만족 개선을 측정합니다 |
| **지식 공유 효율** | 팀이 **정보를 찾거나 반복 질문을 하는 데 쓰는 시간의 감소** |
| **온보딩 시간** | 새 팀원이 **생산적이 되기까지 걸리는 시간의 감소** |

**사용자 참여.** 같은 문서의 **「비즈니스 영향」** 범주가 이것을 직접 적습니다 — **기능 채택률**은 **출시한 새 기능에 대한 사용자 참여(user engagement)의 증가**를 측정하는 지표입니다. 함께 드는 것이 **고객 만족도 점수**(사용자 피드백·평점 개선)와 **매출 영향**(출시 속도·생산성 증가에 기인한 매출 증가)입니다. 프로덕션 쪽 문서도 애플리케이션의 가치가 **사용자 채택률과 사용자 행동 변화**에 좌우된다고 적습니다.

**태스크 엔지니어링.** ⚠️ **AWS 문서에 「태스크 엔지니어링」이라는 용어 정의는 없습니다.** 공식 가이드가 예로 드는 낱말이니 이름만 알아 두고, **수식이나 정의를 지어내지 않습니다.** 가장 가까운 공식 개념은 **복잡한 작업을 하위 작업으로 쪼개는 것**이고(AWS 블로그는 그 기법을 「프롬프트 체이닝」으로 부르며 **"작업이 복잡해지면 LLM이 작업을 빠뜨리거나 원하는 정확도로 수행하지 못하는 것으로 알려져 있다"**고 적습니다), 평가 관점의 의미는 **"작업을 어떻게 쪼개 두었는지가 평가 단위를 결정한다"**는 쪽입니다 — 작업 하나를 통째로 재면 어디서 실패했는지 모릅니다.

공식이 지표를 **쓰는 절차**로 적는 다섯 단계도 그대로 시험 재료입니다 — ⚠️ **① 베이스라인 수립**(도입 전 현재 성능 데이터를 모아 둔다. 이것이 없으면 뒤의 비교가 성립하지 않습니다) **② 현실적 목표 설정** **③ 지속적 모니터링**(자동 도구로 상시 수집) **④ 정기 리뷰**(분기·반년) **⑤ 반복과 조정**.

> 참고로 **ROI·전환율·사용자당 평균 수익 같은 「비즈니스 가치 지표」 묶음 자체**는 작업 2.2의 목표 2.2.4가 다룹니다(그 문서의 「비즈니스 가치와 지표」 절). 3.4.3이 묻는 것은 그 목록이 아니라 **"모델이 목표를 향하고 있는지 판정하는 관점"**입니다.

### 4) FM으로 구축된 애플리케이션을 평가한다 (목표 3.4.4) {#app-eval}

**이 목표의 갈림길은 「모델 평가 ≠ 애플리케이션 평가」입니다.** 모델 평가는 **프롬프트 하나에 대한 응답 하나**를 봅니다. 그런데 RAG는 그 앞에 **검색**이 있고, 에이전트는 **도구 호출과 여러 단계의 추론**이 있습니다. 그래서 평가 대상과 지표가 달라집니다.

**RAG 애플리케이션 — 작업이 두 종류입니다.**

| 평가 작업 | 무엇을 보는가 | 내장 지표 |
|---|---|---|
| **검색 전용(retrieve only)** | **검색된 데이터만** | **Context relevance** — 검색된 텍스트 청크가 **질문과 맥락상 관련 있는가** · **Context coverage** — 청크가 **정답 텍스트가 제공하는 정보를 모두 덮는가**(⚠️ **정답 필요**) |
| **검색 + 응답 생성(retrieve and generate)** | 검색 **+ 생성된 응답** | Correctness(정확히 답하는가) · Completeness(질문의 **모든 측면**을 해결하는가) · Helpfulness(전체적으로 유용한가) · Logical coherence(**논리적 공백·모순이 없는가**) · **Faithfulness**(⚠️ **검색된 텍스트 청크에 대해 할루시네이션을 피하는가**) + 책임 있는 AI 3종 |

공식이 적는 공통 요건이 하나 있습니다 — 데이터셋은 **ground truth, 즉 기대되는 검색 텍스트와 응답을 포함해야** 지식 기반이 **기대와 맞는지 검사**됩니다. 그리고 평가 대상은 **Amazon Bedrock Knowledge Base**뿐 아니라 **외부 RAG 소스의 응답을 직접 넣는** 경로도 됩니다.

점수 읽는 법도 공식이 명시합니다. **계산된 점수는 0과 1 사이이고, 1에 가까울수록 그 지표의 특성이 검색 텍스트·응답에 많이 나타납니다.** ⚠️ 그래서 **Harmfulness · Stereotyping · Refusal은 점수가 높을수록 나쁩니다**(공식 예시가 Completeness 0.82에 Stereotyping 0.94인 보고서를 "대체로 완전한 응답을 만들지만 일반화된 서술이 많다"로 읽습니다). 콘솔 보고서는 여기에 **Citation precision**(인용된 구절 중 올바르게 인용된 비율)과 **Citation coverage**(응답이 인용 구절로 얼마나 잘 뒷받침되는가, 대략 인용 재현율)를 더하고 ⚠️ **둘을 함께 써야 인용 품질의 전체 그림이 나온다**고 적습니다.

**에이전트와 워크플로 — 정본은 Amazon Bedrock AgentCore Evaluations입니다.** 공식이 적는 계산 대상은 세 가지 — 에이전트의 **종단 간 작업 완료(목표 달성, goal attainment) 정확성** · 사용자 요청을 처리하며 **호출한 도구의 정확성** · 행동의 특정 차원을 재는 **사용자 정의 지표**. ⚠️ **AgentCore Runtime에서 호스팅되는 에이전트뿐 아니라 AgentCore 밖의 에이전트도 평가합니다.**

평가자는 **세 수준** 중 하나에서 점수를 냅니다 — **trace**(요청·응답 한 쌍) · **session**(대화 전체) · **tool call**(도구 호출 하나). ⚠️ 그래서 **트레이스가 입력과 출력을 모두 담고 있어야** 하고, 결과가 비면 **텔레메트리의 콘텐츠 추출 설정**을 봅니다. 내장 평가자는 **13개**이고 수준별로 이렇게 나뉩니다.

| 수준 | 내장 평가자 |
|---|---|
| **session** | **GoalSuccessRate** — 대화가 **사용자의 목표를 성공적으로 충족했는지** |
| **trace** | Helpfulness · Correctness · Faithfulness · Coherence · Conciseness · ResponseRelevance · InstructionFollowing · Refusal · Harmfulness · Stereotyping |
| **tool call** | **ToolSelectionAccuracy**(**적절한 도구를 골랐는가**) · **ToolParameterAccuracy**(**사용자 질의에서 파라미터를 얼마나 정확히 추출했는가**) |

평가자의 출처는 셋입니다 — **내장**(설정 없이 쓰는 기성 검사. 일부는 내부적으로 심사 모델을 쓰고 일부는 **규칙 기반**입니다) · **서드파티**(DeepEval·AutoEval 오픈 소스 지표. ⚠️ 공식이 **"AWS는 내장 평가자는 테스트·벤치마크하지만 이 라이브러리들의 품질은 보증하지 않으니 내 트레이스로 먼저 검증하라"**고 적습니다) · **사용자 정의**(자연어 기준으로 채점하는 **model-as-judge** · 기존 평가자 로직을 내가 고른 심사 모델로 돌리는 **derived** · 내 Lambda 함수인 **code-based**).

평가를 **언제 돌리는가**도 세 유형입니다.

| 유형 | 공식이 적는 성격 |
|---|---|
| **온라인 평가** | **라이브 프로덕션 트래픽**으로 배포된 에이전트의 품질을 **지속적으로** 모니터링. **비율 기반 샘플링**(예: 전체 세션의 10%)이나 조건 필터로 범위를 정합니다 |
| **온디맨드 평가** | **span·trace ID를 직접 지정**해 선택한 상호 작용만 평가. 특정 고객 사례 조사·수정 검증·**빌드 시점 테스트**에 맞습니다 |
| **배치 평가** | 여러 세션을 **하나의 비동기 작업**으로. **CloudWatch Logs 위치**와 평가자를 지정하면 세션 발견·수집·채점을 서비스가 합니다. **세션 메타데이터로 ground truth**(기대 응답·어서션·**기대 도구 궤적**)를 줄 수 있습니다 |

> ⚠️ **내장 평가자는 도메인 특화 실패를 놓칩니다.** 공식이 드는 예가 결정적입니다 — 고객 지원 에이전트가 **엉뚱하게 레시피를 답했을 때**, helpfulness 평가자는 **"잘 답했다"로 높은 점수**를 주고 정책 준수 평가자도 **"유해한 것이 없다"로 높은 점수**를 줍니다. 모든 점수가 높은데 에이전트는 **자기 범위를 벗어났습니다.** 범용 기준은 **내 에이전트의 범위를 알지 못합니다.** → 허용 주제·필수 행동·금지 행동 같은 **내 규칙마다 사용자 정의 평가자**를 씁니다.

> ⚠️ **절대 점수 하나는 뜻이 적습니다.** 공식은 **"correctness 0.8은 무언가에 상대적으로만 좋거나 나쁘다"**고 적고, 점수를 **비교**로 읽으라고 합니다 — **같은 데이터셋의 변경 전후** · **에이전트 간** · **시간에 따른 추세**. 며칠에 걸쳐 **통과율이 떨어지면** 개별 점수가 다 그럴듯해 보여도 **회귀 신호**입니다.

Well-Architected도 같은 방향을 적습니다. 에이전트별로 **도구 호출 빈도 · 출력 토큰 수 분포 · 작업 완료율 · 유형별 오류율**을 대표 기간 동안 모으고, **Amazon CloudWatch Anomaly Detection**으로 **기대 범위를 학습**시켜(고정 임계값 대신) 경보를 걸고, **AgentCore Evaluations를 정기적으로 돌려** 인프라 오류로 드러나지 않는 **행동 드리프트**를 잡으라는 것입니다.

### 5) 비즈니스 목표 조정 지표 (목표 3.4.5) {#alignment-metrics}

v1.1에서 **새로 생긴 목표**입니다. 가이드가 드는 예가 셋이고, 셋의 **근거 상태가 서로 다릅니다.** 이 차이를 알고 가는 것이 이 목표의 핵심입니다.

| 지표 | 공식에서 확인되는 자리 | 어떻게 쥐는가 |
|---|---|---|
| **작업 완료율** | ⚠️ **생성형 AI 일반 KPI로 수식을 정의한 문서 페이지는 없습니다.** 대신 **에이전트 평가 쪽에 두 번** 나옵니다 — AgentCore Evaluations가 **종단 간 작업 완료(목표 달성) 정확성**을 계산하고 내장 평가자 **`GoalSuccessRate`**가 **대화가 사용자의 목표를 성공적으로 충족했는지** 평가합니다. Well-Architected도 수집할 에이전트별 지표로 **작업 완료율**을 직접 듭니다 | **수식을 외우지 말고 "어디서 나오는 숫자인가"**를 쥡니다 — 에이전트 평가의 **세션 수준** 신호입니다 |
| **사용자 만족도** | ROI 대시보드의 **비즈니스 가치 지표**에 **CSAT 점수 개선**이 들어갑니다. 소프트웨어 개발 쪽 문서도 **고객 만족도 점수**(사용자 피드백·평점 개선)를 비즈니스 영향 지표로 듭니다 | **설문·피드백에서 오는 숫자**입니다. 기술 지표가 아니라 **번역된 결과**입니다 |
| **상호 작용당 비용** | ROI 대시보드의 **재무 지표**에 **총 인프라 지출**과 함께 명시됩니다 | **비용 축의 대표 지표**입니다. 토큰 소비가 움직이면 이 숫자가 움직입니다 |

세 지표를 한 화면에 올리는 그릇이 **ROI 대시보드**이고, 공식은 그것을 **프로덕션 단계의 핵심 산출물**로 부릅니다. ⚠️ 그리고 **ROI를 출시 시점의 정적 계산으로 다룰 수 없다**고 못박습니다 — **지속적으로 추적해 시각화하는 동적 KPI**여야 하고, 그래야 ROI가 **"과거의 정당화"에서 "비즈니스 리더를 위한 실시간 운영 건강 지표"로** 바뀝니다.

왜 정적일 수 없는지도 공식이 양쪽으로 적습니다. **비용**이 움직이는 이유는 **API 토큰 소비 · 수요에 맞춘 인프라 확장 · 미세 조정 같은 유지 활동의 연산 비용**이고(작업 2.1·2.3의 비용 축과 그대로 이어집니다), **가치**가 움직이는 이유는 **사용자 채택률 · 사용자 행동 변화 · 시간 경과에 따른 모델 성능 저하 · 비용·성능 효율을 위한 모델 교체**입니다. 공식은 결정론적 소프트웨어와 달리 생성형 AI 애플리케이션의 성능과 관련성이 **데이터 드리프트 · 개념 드리프트 · 사용자 기대 변화**로 **시간이 지나며 저하될 수 있다**고 적습니다.

> ROI 대시보드가 담는 지표 묶음의 세부(절약 시간·매출 증가 등)는 작업 2.2의 「비즈니스 가치와 지표」 절에 있습니다. 3.4.5가 묻는 것은 **"이 기술 지표를 어느 조정 지표로 보고하는가"**입니다.

---

## ✍️ 시험 포인트

- **평가 종류 ↔ 지표 문항**은 **집합이 겹치지 않는다**는 사실로 풀립니다. "정답 데이터가 없다"면 정확도 계열이 빠지고, **"검색 품질만"이면 retrieve only + Context relevance·coverage**입니다. 오답 보기는 **모델 평가 지표를 RAG 평가 자리에** 섞습니다.
- **「Accuracy」가 등장하면 작업 유형을 먼저 봅니다** — 요약이면 **BERT Score**, 질의응답이면 **F1**, 일반 생성이면 **RWK 점수**, 분류면 **accuracy**입니다.
- **지표의 좋은 방향을 섞는 문항**에 주의합니다 — **Robustness·Toxicity는 낮을수록** 좋고, RAG 평가의 **Harmfulness·Stereotyping·Refusal은 높을수록 나쁩니다.**
- **"사람 평가가 필요한 상황"**은 **주관적·뉘앙스가 필요한 기준**입니다. 모델이 **하나뿐이면 개별형 채점**(좋아요·싫어요 또는 Likert 개별)을 써야 합니다.
- **"에이전트가 엉뚱한 일을 하는데 점수는 다 높다"**가 보이면 답은 **사용자 정의 평가자**입니다. 내장 평가자는 **범용 기준**이라 내 에이전트의 **범위**를 모릅니다.
- **"라이브 트래픽을 계속 보고 싶다"면 온라인 평가**, **"특정 상호 작용만"이면 온디맨드**, **"세션 묶음을 한 작업으로"면 배치**입니다.
- **FM 평가 도구를 묻는 문항에 SageMaker Clarify를 고르지 않습니다** — **신규 고객에게 열려 있지 않고**, 대체는 **fmeval · Bedrock Evaluations · Bedrock Guardrails**입니다.
- **BLEU가 보기에 있으면 "가이드가 드는 일반 지표"**로만 취급합니다. **AWS 관리형 평가가 계산해 주는 지표를 고르는 문항**이면 ROUGE·BERTScore·F1 계열 쪽입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"ROUGE·BLEU·BERTScore가 Amazon Bedrock 평가 보고서에 나란히 나온다"** → 아닙니다. **BERTScore가 요약 작업의 Accuracy 그 자체**이고, ROUGE는 **SageMaker AI 쪽 요약 정확도**의 세 지표 중 하나이며, **BLEU는 문서에서 확인되지 않습니다.**
- ❌ **"겹침 기반 지표면 의미가 같은 요약도 높은 점수를 받는다"** → 거꾸로입니다. 공식은 ROUGE가 **정확한 단어 겹침에 의존해 추상적 요약에서 신뢰가 떨어진다**고 적습니다. 의미 유사도를 보는 쪽이 **BERTScore**입니다.
- ❌ **"강건성 점수가 올라갔으니 모델이 좋아졌다"** → **낮을수록 강건합니다.** 섭동 전후 점수 차이를 원본으로 나눈 **퍼센트**이기 때문입니다.
- ❌ **"RAG 평가에 Accuracy·Robustness·Toxicity를 쓴다"** → 그 셋은 **자동 모델 평가 전용**입니다. RAG 평가의 유효 지표는 **검색 전용 둘**과 **검색+생성 집합**입니다.
- ❌ **"Context relevance와 Context coverage는 둘 다 정답 없이 계산된다"** → **coverage는 정답(ground truth)을 요구합니다** — 청크가 **정답 텍스트의 정보를 모두 덮는지**를 보기 때문입니다.
- ❌ **"에이전트 평가도 프롬프트와 응답만 있으면 된다"** → 평가자가 **trace·session·tool call** 수준에서 채점하므로 **도구 호출 순서와 검색 컨텍스트까지** 트레이스에 있어야 합니다. **기대 도구 궤적**을 ground truth로 주는 평가 유형도 있습니다.
- ❌ **"내장 평가자 점수가 모두 높으면 에이전트가 올바르게 동작했다"** → 공식 반례가 **범위를 벗어나 레시피를 답한 고객 지원 에이전트**입니다. 범용 기준은 **범위 이탈을 모릅니다.**
- ❌ **"평가 점수 0.8은 좋은 점수다"** → 공식은 **절대 점수 하나로는 뜻이 거의 없고 비교로 읽어야 한다**고 적습니다.
- ❌ **"ROI는 출시 때 한 번 계산하면 된다"** → 공식이 **정적 계산으로 다룰 수 없다**고 못박고 **동적 KPI로 대시보드에서 추적**하라고 적습니다.
- ❌ **"작업 완료율은 AWS가 정의한 생성형 AI 표준 KPI다"** → 그 수식을 정의한 문서 페이지는 **없습니다.** 공식에서 확인되는 것은 **에이전트 평가의 작업 완료(목표 달성) 신호**와 **`GoalSuccessRate` 내장 평가자**입니다.
- ❌ **"Bedrock Evaluations가 Clarify를 완전히 대체한다"** → **FM(LLM) 평가만** 대체합니다. 공식이 **표형(전통 ML) 편향 탐지·설명 가능성의 대체는 아니라고** 명시합니다.

---

## 🧪 자가 점검

**Q1.** 자동(프로그래매틱) 모델 평가 작업에서 쓸 수 있는 내장 지표를 모두 말하세요. 그리고 거기에 `Faithfulness`를 추가할 수 있나요? (→ 2) 관련 지표)

<details><summary>정답 보기</summary>

**`Builtin.Accuracy` · `Builtin.Robustness` · `Builtin.Toxicity` 셋뿐입니다.** 공식 API 레퍼런스가 **"For automated model evaluation jobs, valid values are `Builtin.Accuracy`, `Builtin.Robustness`, and `Builtin.Toxicity`"**로 유효값을 못박습니다.

**`Faithfulness`는 추가할 수 없습니다.** 그 지표는 **심사 모델(LLM-as-a-judge) 평가**와 **RAG 검색+생성 평가**의 유효값입니다. 평가 종류마다 **유효 지표 집합이 겹치지 않게** 정의돼 있다는 것이 이 목표의 핵심 사실입니다.
</details>

**Q2.** 같은 「Accuracy」 지표를 선택했는데 작업 유형이 **텍스트 요약**인 경우와 **질의응답**인 경우, 각각 무엇으로 계산되나요? (→ 2) 관련 지표)

<details><summary>정답 보기</summary>

- **텍스트 요약 = BERT Score.** 공식은 **"BERT 모델의 사전 훈련 문맥 임베딩으로 계산되며, 후보 문장과 참조 문장의 단어를 코사인 유사도로 맞춘다"**고 적습니다.
- **질의응답 = F1 점수.** 공식은 **정밀도(전체 예측 중 올바른 예측의 비율)와 재현율(관련 예측 전체 중 올바른 예측의 비율)**로 계산하며 **0~1 범위이고 값이 높을수록 성능이 좋다**고 적습니다.

참고로 **일반 텍스트 생성은 RWK 점수**(실세계 사실 지식), **텍스트 분류는 accuracy**(예측 클래스 ↔ 정답 레이블)입니다. 지표 **이름이 같아도 수식이 다르다**는 것이 함정의 자리입니다.
</details>

**Q3.** 지식 기반의 **검색 단계만** 평가하려고 합니다. 쓸 수 있는 내장 지표는 무엇이고, 그중 정답(ground truth)이 필요한 것은? (→ 4) 애플리케이션 평가)

<details><summary>정답 보기</summary>

**`Builtin.ContextRelevance`와 `Builtin.ContextCoverage` 둘뿐입니다.** 공식 API 레퍼런스가 **"For knowledge base evaluation jobs that evaluate retrieval only, valid values are `Builtin.ContextRelevance`, `Builtin.ContextCoverage`"**로 적습니다.

**정답이 필요한 것은 Context coverage입니다.** 공식 콘솔 설명이 그 지표를 **"Context coverage (requires ground truth)"**로 적고, 뜻은 **검색된 텍스트 청크가 정답 텍스트에서 제공된 정보를 모두 덮는가**입니다. Context relevance는 **청크가 질문과 맥락상 관련 있는가**만 보므로 정답이 필요하지 않습니다.
</details>

**Q4.** 모델 평가 보고서에서 **Robustness 값이 전보다 크게 올라갔습니다.** 좋은 신호인가요? 그 값이 어떻게 계산되는지와 함께 답하세요. (→ 2) 관련 지표)

<details><summary>정답 보기</summary>

**좋은 신호가 아닙니다 — 낮은 값이 더 강건하다는 뜻입니다.** 공식은 각 작업 유형의 Robustness를 **퍼센트**로 계산하고 **"낮은 점수가 선택한 모델이 더 강건함을 나타낸다"**고 적습니다.

계산 방식은 **섭동 전후 점수의 차이를 원본 점수로 나눈 비율**입니다 — 요약은 **(Delta BERTScore / BERTScore) × 100**, 질의응답은 **(Delta F1 / F1) × 100**. 섭동은 **소문자 변환 · 키보드 오타 · 숫자를 단어로 변환 · 무작위 대문자화 · 공백의 무작위 추가·삭제**이고, **"데이터셋의 각 프롬프트는 약 5회 섭동됩니다."** 값이 커졌다는 것은 **작은 입력 변형에 출력이 더 많이 흔들렸다**는 뜻입니다.
</details>

**Q5.** 고객 지원 에이전트가 **지원 범위와 무관한 요리 레시피를 답했는데** 내장 평가자 점수는 모두 높게 나왔습니다. 공식 설명으로 이 현상을 설명하고 대응책을 말하세요. (→ 4) 애플리케이션 평가)

<details><summary>정답 보기</summary>

**내장 평가자가 범용 기준을 채점하기 때문입니다.** 공식이 이 상황을 예로 직접 적습니다 — 에이전트가 범위를 벗어난 질문에 답하면 **helpfulness 평가자는 "잘 답했다"로 높은 점수**를 주고 **정책 준수 평가자도 "유해한 것이 없다"로 높은 점수**를 줍니다. 공식의 결론은 **"모든 점수가 높은데 에이전트는 자신의 지정된 범위를 벗어났다. 어떤 범용 기준도 내 에이전트의 범위가 무엇인지 알지 못한다"**입니다.

**대응책은 사용자 정의 평가자입니다.** 공식 지침은 **범용 기준에는 내장 평가자를, 내 에이전트에 특정한 규칙(허용 주제·필수 행동·금지 행동)마다 사용자 정의 평가자**를 쓰라는 것입니다. 한 문장으로 말할 수 있는 규칙이면 **model-as-judge**로, 기계적으로 검사 가능하면 **code-based**(Lambda) 평가자로 만듭니다.
</details>

**Q6.** 이제 FM 평가를 시작하려는 팀이 **Amazon SageMaker Clarify로 LLM을 평가하겠다**고 합니다. 검토하세요. (→ 1) 평가 접근 방식)

<details><summary>정답 보기</summary>

**쓸 수 없습니다.** 공식이 **"Amazon SageMaker Clarify is no longer open to new customers"**라고 적습니다. 기존 고객은 그대로 쓸 수 있고 AWS는 보안·가용성 개선은 계속하지만 **신규 기능은 도입하지 않을 계획**입니다.

공식이 적는 **FM(LLM) 평가의 대체 경로는 셋**입니다 — **① fmeval 라이브러리**(SageMaker 호스팅 모델에 권장) **② Amazon Bedrock Evaluations**(관리형 서비스) **③ Amazon Bedrock Guardrails**(런타임 안전).

⚠️ 단서를 함께 기억해야 합니다. 공식은 이 둘이 Clarify의 **파운데이션 모델 평가 기능을 대체한다**고 하면서도 **"표형(전통 ML) 편향 탐지나 설명 가능성의 대체는 아니다"**라고 못박습니다. 편향 지표는 **공표된 업계 표준 수식**이라 직접 계산하고, 설명 가능성은 **Clarify가 내부적으로 쓰는 엔진인 SHAP**을 직접 씁니다.
</details>

---

### 📌 출처

1. Evaluate the performance of Amazon Bedrock resources — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html` (2026-11-03 확인)
2. EvaluationDatasetMetricConfig (Amazon Bedrock API Reference) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_EvaluationDatasetMetricConfig.html` (2026-11-03 확인)
3. Review metrics for an automated model evaluation job in Amazon Bedrock (console) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-report-programmatic.html` (2026-11-03 확인)
4. Review metrics for RAG evaluations that use LLMs (console) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-eval-llm-results.html` (2026-11-03 확인)
5. Use prompt datasets for model evaluation in Amazon Bedrock — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-prompt-datasets.html` (2026-11-03 확인)
6. HumanEvaluationCustomMetric (Amazon Bedrock API Reference) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_HumanEvaluationCustomMetric.html` (2026-11-03 확인)
7. Built-in metric evaluator prompts for model-as-a-judge evaluation jobs — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-type-judge-prompt.html` (2026-11-03 확인)
8. Accuracy (Amazon SageMaker AI 파운데이션 모델 평가 — ROUGE·METEOR·BERTScore 수식과 한계) — `docs.aws.amazon.com/sagemaker/latest/dg/clarify-accuracy-evaluation.html` (2026-11-03 확인)
9. Clarify availability change (신규 고객 차단과 대체 경로) — `docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html` (2026-11-03 확인)
10. How it works (Amazon Bedrock AgentCore Evaluations) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/how-it-works-evaluations.html` (2026-11-03 확인)
11. Evaluation types (온라인·온디맨드·배치) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/evaluations-types.html` (2026-11-03 확인)
12. Built-in evaluators (Amazon Bedrock AgentCore Evaluations) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/built-in-evaluators-overview.html` (2026-11-03 확인)
13. Evaluators and evaluations (평가 수준 셋·평가자 출처 셋·점수 읽는 법) — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/omni-agents-evaluators.html` (2026-11-03 확인)
14. AGENTREL02-BP03 Implement behavioral anomaly detection and monitoring (작업 완료율 등 에이전트별 지표) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentrel02-bp03.html` (2026-11-03 확인)
15. Delivering and sustaining the value of a generative AI application (ROI 대시보드·상호 작용당 비용·CSAT) — `docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/prod-value.html` (2026-11-03 확인)
16. Measuring the success of generative AI in software development (생산성·기능 채택률·베이스라인 절차) — `docs.aws.amazon.com/prescriptive-guidance/latest/strategy-accelerate-software-dev-lifecycle-gen-ai/measuring-success.html` (2026-11-03 확인)
17. AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어) — `docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html` (2026-11-03 확인)
18. BLEU의 정의와 한계 (AWS 블로그 — `docs.aws.amazon.com`에 근거가 없어 블로그를 명시합니다) — `aws.amazon.com/blogs/machine-learning/build-a-multilingual-automatic-translation-pipeline-with-amazon-translate-active-custom-translation/` (2026-11-03 확인)
19. 프롬프트 체이닝 (AWS 블로그 — 복잡한 작업을 하위 작업으로 쪼개기) — `aws.amazon.com/blogs/machine-learning/building-generative-ai-prompt-chaining-workflows-with-human-in-the-loop/` (2026-11-03 확인)
