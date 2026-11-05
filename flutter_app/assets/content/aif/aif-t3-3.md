---
examGuideTaskId: aif-t3-3
certCode: AIF-C01
domain: 3
domainName: 파운데이션 모델의 적용
domainWeightPct: 28
title: FM의 훈련과 미세 조정 (훈련 4요소·미세 조정 방법·데이터 준비와 RLHF)
coversTasks:
  - "3.3"
sources:
  - title: What are Foundation Models?
    url: https://aws.amazon.com/what-is/foundation-models/
  - title: Customize your model to improve its performance for your use case (Amazon Bedrock)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html
  - title: Customize a model with distillation in Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-distillation.html
  - title: Prepare data for fine-tuning your models (Amazon Bedrock)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html
  - title: Submit a model customization job for fine-tuning (Amazon Bedrock)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-submit.html
  - title: Increase model invocation capacity with Provisioned Throughput in Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html
  - title: Custom models (Amazon Bedrock 콘솔 도움말)
    url: https://docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-custom-models.html
  - title: Create a Continued Pre-training job (Amazon Bedrock 콘솔 도움말)
    url: https://docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-custom-models-create-continued-pre-training-job.html
  - title: Amazon Bedrock FAQs
    url: https://aws.amazon.com/bedrock/faqs/
  - title: create_model_customization_job (Amazon Bedrock API 레퍼런스)
    url: https://docs.aws.amazon.com/boto3/latest/reference/services/bedrock/client/create_model_customization_job.html
  - title: Foundation models and hyperparameters for fine-tuning (Amazon SageMaker AI)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning.html
  - title: Fine-tune a large language model (LLM) using prompt instructions (Amazon SageMaker AI)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-instruction-based.html
  - title: Fine-tune a large language model (LLM) using domain adaptation (Amazon SageMaker AI)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-domain-adaptation.html
  - title: What is Transfer Learning?
    url: https://aws.amazon.com/what-is/transfer-learning/
  - title: MLSUS02-BP01 Consider AI services and pre-trained models (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlsus02-bp01.html
  - title: What is RLHF?
    url: https://aws.amazon.com/what-is/reinforcement-learning-from-human-feedback/
  - title: Data lifecycle in generative AI (AWS Prescriptive Guidance)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-data-considerations-gen-ai/lifecycle.html
  - title: Governance perspective: Managing an AI-driven organization (AWS CAF for AI)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-caf-for-ai/governance-perspective-managing-an-aiml-driven-organization.html
  - title: Security perspective: Compliance and assurance of AI systems (AWS CAF for AI)
    url: https://docs.aws.amazon.com/whitepapers/latest/aws-caf-for-ai/security-perspective-compliance-and-assurance-of-aiml-systems.html
  - title: RAIDP01-BP02 Identify the datasets needed for training and customizing your system
    url: https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp01-bp02.html
  - title: RAIDP03-BP02 Minimize unwanted bias in your datasets
    url: https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp02.html
  - title: RAIDP03-BP04 Include both intrinsic and confounding variations in your datasets
    url: https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp04.html
  - title: RAIDP03-BP05 Review the correctness of the content of your datasets
    url: https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp05.html
  - title: MLSEC03-BP04 Enforce data lineage (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlsec03-bp04.html
  - title: What Is AI Bias?
    url: https://aws.amazon.com/what-is/ai-bias/
  - title: What is Data Governance?
    url: https://aws.amazon.com/what-is/data-governance/
  - title: AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html
lastVerified: 2026-11-03
---

# FM의 훈련과 미세 조정 (훈련 4요소·미세 조정 방법·데이터 준비와 RLHF)

> **커버하는 공식 Task** — AIF-C01 · 도메인 3 「파운데이션 모델의 적용」(28%) · **작업 3.3 파운데이션 모델의 훈련과 미세 조정 프로세스 설명** (`aif-t3-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 목표 3개(3.3.1~3.3.3)를 모두 덮습니다. 이 Task는 **"모델을 어떻게 만드는가"가 아니라 "어느 훈련 단계가 어떤 데이터를 요구하는가"**를 묻습니다. 그 한 축만 잡으면 대부분의 문항이 갈립니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 사전 훈련 · 미세 조정 · 지속적인 사전 훈련 · 증류를 **무엇을 입력으로 받는가**로 가른다
- [ ] 「미세 조정」과 「지속적인 사전 훈련」을 **레이블 데이터가 필요한가**로 즉시 구분한다
- [ ] 명령 튜닝과 도메인 적응의 **데이터 형식 차이**를 말할 수 있다
- [ ] 전이 학습이 상위 개념이고 미세 조정·증류가 그 수단임을 설명한다
- [ ] 증류의 지식 방향(교사 → 학생)과 **숨은 비용**을 안다
- [ ] 미세 조정 데이터 준비의 여섯 축(큐레이션·거버넌스·크기·레이블·대표성·RLHF)을 든다
- [ ] RLHF 네 단계에서 **사람이 들어가는 자리**를 정확히 지목한다
- [ ] 훈련 데이터와 평가 데이터를 분리해야 하는 이유를 공식 근거로 말한다

---

## 🎯 왜 중요한가

도메인 3은 전체의 **28%**로 가장 큰 도메인이고, 3.3은 그중 **훈련 쪽 절반**입니다. 그런데 이 작업의 문항은 모델을 만들라고 하지 않습니다. 묻는 것은 늘 같은 모양입니다 — **"이 상황에서 어떤 훈련·사용자 지정 방법을 고를 것인가."**

고르는 기준은 사실 둘뿐입니다.

1. **가진 데이터에 레이블이 있는가** — 있으면 미세 조정, 없으면 지속적인 사전 훈련.
2. **바꾸려는 것이 「작업 수행 방식」인가 「도메인 지식」인가** — 앞은 미세 조정, 뒤는 지속적인 사전 훈련.

여기에 「비용」 축을 더해 무엇을 고를지 판단하는 것은 **목표 3.1.5**의 몫이고 `aif-t3-1`이 다룹니다. 이 문서는 **각 방법이 무엇이고 어떻게 돌아가는가**에 집중합니다. 전체 사용자 지정 사다리(프롬프트 엔지니어링 → RAG → 미세 조정 → 처음부터 구축)의 큰 그림은 `aif-t2-1`에 있습니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **사전 훈련은 자기 지도 학습입니다** — 공식은 FM이 **"입력 데이터에서 레이블을 만든다"**고 적고, 이것이 지도·비지도를 쓰던 이전 아키텍처와의 **구분점**이라고 못박습니다
- **미세 조정 = 레이블 데이터**, **지속적인 사전 훈련 = 비레이블 데이터.** 이 한 줄이 3.3 문항의 절반을 가릅니다
- **지속적인 사전 훈련의 목적은 「새 도메인 지식」**입니다 — 공식은 기본 모델에 **"아직 없는 도메인 지식을 가르치는"** 용도로 적습니다
- ⚠️ **먼저 지속적 사전 훈련을 하면 이후 미세 조정에 레이블 레코드가 훨씬 적게 듭니다** — 공식 FAQ가 "**significantly fewer labeled training records and ... shorter training duration**"으로 적습니다
- **명령 튜닝은 「프롬프트-응답 쌍」**(지시문 형태)을, **도메인 적응은 「원시 텍스트」**를 받습니다. **둘 다 모델의 가중치를 바꿉니다**
- **전이 학습이 상위 개념입니다** — 공식은 사전 훈련 모델에서 출발해 미세 조정하는 접근을 **"전이 학습으로 알려진"** 것이라고 부릅니다. 증류의 교사-학생도 전이 학습 전략의 하나입니다
- **증류는 교사 → 학생 방향입니다** — 교사는 **더 크고 유능**, 학생은 **더 작고 빠르고 비용 효율적**. 공식은 교사 응답으로 만든 **합성 데이터로 학생을 미세 조정**한다고 적습니다
- ⚠️ **증류는 공짜 절감이 아닙니다** — 데이터 합성 기법이 돌면 **교사 모델 추론이 온디맨드 요율로 추가 과금**되고 데이터셋이 **최대 15k 프롬프트-응답 쌍**까지 커질 수 있습니다
- ⚠️ **사용자 지정한 모델은 추론을 따로 설정해야 호출됩니다** — **프로비저닝된 처리량 구매** 또는 **사용자 지정 모델 배포(온디맨드)** 둘 중 하나입니다(리전·기반 모델·시점 제약이 있습니다)
- **RLHF에서 사람은 「선호 순위」만 매깁니다** — 그 선호로 **별도의 보상 모델**을 만들고, 그 보상 모델이 언어 모델의 정책을 최적화합니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **사전 훈련(pre-training)** | 방대한 일반 데이터로 FM을 처음부터 훈련하는 단계. 공식은 **"현재 수백만 달러가 든다"**고 적습니다 |
| **미세 조정(fine-tuning)** | 사전 훈련된 모델을 **내 데이터로 더 훈련**해 특정 작업 성능을 올리는 것. **가중치가 바뀝니다** |
| **지속적인 사전 훈련(continued pre-training)** | 사전 훈련된 모델에 **비레이블 데이터**를 더 먹여 새 도메인 지식을 넣는 것. 「계속 사전 훈련」으로도 번역됩니다 |
| **증류(distillation)** | 크고 유능한 **교사** 모델의 지식을 작고 빠른 **학생** 모델로 옮기는 것 |
| **전이 학습(transfer learning)** | 한 작업에 사전 훈련된 모델을 **관련된 새 작업에 맞춰 미세 조정**하는 ML 기법 |
| **명령 튜닝(instruction tuning)** | 레이블 예제를 **프롬프트-응답 쌍**으로, 그것도 **지시문 형태**로 주는 미세 조정 |
| **도메인 적응(domain adaptation)** | 도메인 전문 용어·기술 용어를 이해시키기 위한 미세 조정 |
| **RLHF** | 사람 피드백을 **보상 함수에 넣어** 모델을 사람의 목표에 정렬시키는 ML 기법 |
| **보상 모델(reward model)** | 어떤 응답에 사람이 몇 점을 줄지 **자동으로 추정하는** 별도 모델 |
| **데이터 큐레이션(data curation)** | 데이터를 획득·레이블·정제·가공하는 일. 공식은 이것이 **모델 성능을 끌어올린다**고 적습니다 |
| **데이터 계보(data lineage)** | 데이터가 출처에서 변환을 거쳐 모델 배포까지 간 **여정의 기록** |
| **하이퍼파라미터** | 데이터로 **학습되지 않고 미리 정하는** 값(학습률·에폭 등). 가중치와 다릅니다 |

---

## 📖 핵심 개념

### 1) FM 훈련의 네 가지 요소 (목표 3.3.1) {#training-elements}

공식 목표가 예로 드는 넷을 **입력 데이터**와 **바뀌는 것**으로 세우면 외울 것이 거의 없습니다.

| 요소 | 입력 데이터 | 무엇이 바뀌는가 | 가르는 질문 |
|---|---|---|---|
| **사전 훈련** | 방대한 **일반·비레이블** 데이터 | 모델 자체가 **처음부터** 생긴다 | 모델이 아직 없는가 |
| **미세 조정** | 내 **레이블** 데이터(입력-출력 쌍) | 특정 작업의 **성능** | 정답 쌍을 갖고 있는가 |
| **지속적인 사전 훈련** | 내 **비레이블** 데이터(사내 문서 등) | 모델이 가진 **도메인 지식** | 레이블은 없고 도메인 말뭉치만 있는가 |
| **증류** | **프롬프트**(교사가 응답을 만든다) | 더 **작고 빠른** 모델이 생긴다 | 큰 모델급 품질을 작은 모델에서 원하는가 |

**사전 훈련.** 공식은 FM을 **"방대한 데이터셋으로 훈련된 대규모 딥 러닝 신경망"**으로 정의하고, 「파운데이션 모델」이라는 말 자체가 **"광범위한 일반화되고 비레이블인 데이터로 훈련돼 언어 이해·텍스트와 이미지 생성 같은 다양한 일반 작업을 수행할 수 있는"** 모델을 가리키기 위해 만들어졌다고 적습니다. 핵심 메커니즘은 **자기 지도 학습**입니다 — **"FM은 자기 지도 학습을 사용해 입력 데이터에서 레이블을 만든다"**, 그리고 **"이것이 지도 또는 비지도 학습을 쓰던 이전 ML 아키텍처와 LLM을 구분하는 특징"**입니다. 비용 때문에 실무자가 직접 할 일은 거의 없습니다 — 공식은 처음부터 FM을 만드는 데 **"현재 수백만 달러가 든다"**고 적고, 사전 훈련된 FM을 쓰는 쪽이 **"더 빠르고 저렴하다"**고 결론 냅니다.

**미세 조정.** 공식은 미세 조정을 **"더 훈련시키는 사용자 지정 방법이고 모델의 가중치를 바꾼다"**고 못박습니다. 그리고 쓸 자리를 다섯 가지로 열거합니다 — 특정 비즈니스 요구에 맞추기 · **도메인 전문 용어**(업계 전문 용어·기술 용어·특수 어휘)와 잘 동작하기 · 특정 작업의 성능 향상 · 애플리케이션에서 정확하고 맥락을 아는 응답 · **더 사실에 가깝고 덜 유해하며 요구에 더 정렬된** 응답.

**지속적인 사전 훈련.** 공식 설명이 가장 명확합니다 — **"새 비레이블 데이터로 모델을 훈련한다. 기본 모델에 아직 없는 새 도메인 지식을 가르치는 데 쓴다. 대규모 언어 모델 훈련에 공개되지 않은 사내 문서 같은 비공개 데이터로 훈련할 수 있고, 비레이블 데이터가 더 생기는 대로 재훈련해 계속 개선할 수 있다."**

### 2) 지속적인 사전 훈련이 미세 조정의 비용을 깎는다 (목표 3.3.1) {#cpt-then-ft}

이 둘은 **고르는 것이 아니라 이어 쓰는 것**일 수 있습니다. 공식 FAQ의 서술이 그 순서와 이유를 그대로 적습니다.

> 기본 모델은 특정 도메인의 기술 전문 용어로 훈련되지 않았을 수 있습니다. 그래서 기본 모델을 **바로 미세 조정하면** 정확한 결과를 얻기까지 **"대량의 레이블 훈련 레코드와 긴 훈련 시간"**이 듭니다. 그 부담을 줄이려면 대신 **대량의 비레이블 데이터로 지속적 사전 훈련 작업**을 돌려 기본 모델을 새 도메인에 적응시킵니다. 그 뒤 새로 사전 훈련된 사용자 지정 모델을 다운스트림 작업에 미세 조정하면 **"현저히 더 적은 레이블 훈련 레코드와 더 짧은 훈련 시간"**으로 됩니다.

⚠️ **이 FAQ 답변의 주어는 `Amazon Titan` 기본 모델입니다** — 원문이 "This job will adapt the **Amazon Titan base model** to the new domain"으로 적습니다(2026-11-06 실측). 순서와 이유는 일반적으로 성립하지만 **"현저히 더 적은 레이블 레코드"라는 수혜를 모든 기본 모델에 단정하는 근거로는 이 문장을 쓸 수 없습니다.**

운영 축에서도 한 자리가 더 있습니다. 공식 처방적 지침은 모델이 훈련 도메인에서 멀어지는 **드리프트**에 대비해 **"정기적인 미세 조정 또는 지속적 사전 훈련을 일정에 넣는 것"**을 한 접근으로 들고, 지속적 사전 훈련을 **"처음부터 시작하지 않고 새 비레이블 텍스트 데이터에 노출시켜 이해를 다듬고 새 정보에 적응하게 하는"** 과정이라고 적습니다.

Amazon Bedrock에서 이 넷이 **작업 유형(customization type)**으로 드러납니다. 공식 API의 유효값이 그 목록입니다 — `FINE_TUNING` · `CONTINUED_PRE_TRAINING` · `DISTILLATION` · `REINFORCEMENT_FINE_TUNING` · `IMPORTED`.

> ⚠️ **사용자 지정의 끝에는 늘 「추론을 따로 설정한다」가 붙습니다.** 네 방법 중 무엇을 쓰든 결과물은 사용자 지정 모델이고, **기반 모델처럼 바로 호출되지 않습니다.** 공식이 적는 경로는 **둘**입니다 — **프로비저닝된 처리량 구매**(전용 용량) 또는 **사용자 지정 모델 배포를 만들어 온디맨드로 호출**("쓴 만큼만 내고 프로비저닝된 컴퓨팅 자원을 설정할 필요가 없다"). ⚠️ 프로비저닝된 처리량 페이지는 아직 **"사용자 지정했다면 프로비저닝된 처리량을 구매해야 한다"**고만 적지만, **추론 설정 전용 페이지가 두 선택지를 나란히 싣습니다** — 더 구체적인 쪽이 정본입니다. 온디맨드 배포에는 **리전·기반 모델·사용자 지정 시점** 제약이 있습니다. 경로별 비용 축은 `aif-t3-1`에 있습니다.

### 3) 증류 — 교사에서 학생으로 (목표 3.3.1) {#distillation}

공식 정의는 방향이 분명합니다 — **"더 크고 더 똑똑한 모델(교사)에서 더 작고 빠르고 비용 효율적인 모델(학생)로 지식을 옮기는 과정"**이고, 이 과정에서 **학생 모델의 특정 용례 성능이 올라갑니다.** 메커니즘은 **"최신 데이터 합성 기법으로 교사 모델에서 다양하고 품질 높은 응답(합성 데이터)을 생성해 학생 모델을 미세 조정"**하는 것입니다. 즉 **증류의 마지막 단계는 미세 조정**입니다.

절차는 세 걸음입니다.

1. **교사 모델과 학생 모델을 고른다.**
2. **훈련 데이터를 준비한다** — 프롬프트 모음을 `.jsonl` 파일로 둡니다. 선택적으로 **레이블된 프롬프트-응답 쌍**을 넣으면 교사가 비슷한 고품질 응답을 내게 하는 **「골든 예제」**로 쓰입니다.
3. **증류 작업을 만든다** — 공식은 **"최종 증류 모델에 접근할 수 있는 것은 당신뿐이고, Amazon Bedrock은 당신의 데이터를 공개용 교사·학생 모델 훈련에 쓰지 않는다"**고 적습니다.

데이터 경로가 **둘**이라는 점이 시험 포인트입니다.

| 경로 | 동작 | 주의 |
|---|---|---|
| **내 프롬프트 제공** | 교사가 응답을 **새로 생성**한다. 필요하면 비슷한 프롬프트를 더 만들어 응답을 다양화한다 | 합성 기법이 돌면 **교사 추론이 추가 과금**된다 |
| **호출 로그의 프롬프트만 사용** | 로그의 프롬프트로 교사가 응답을 **새로 생성**한다 | 호출 로깅을 켜 두고 S3에 쌓여 있어야 한다 |
| **호출 로그의 프롬프트-응답 쌍 사용** | 교사 응답을 **재생성하지 않고** 로그의 응답을 그대로 쓴다 | ⚠️ 작업의 **교사 모델이 로그에 쓰인 모델과 일치하지 않으면 로그가 아예 사용되지 않는다** |

> ⚠️ **증류의 숨은 비용.** 공식 주의 문구가 두 가지를 적습니다 — Bedrock이 독자 데이터 합성 기법으로 더 품질 높은 교사 응답을 만들면 **"교사 모델 추론 호출에 대해 교사 모델의 온디맨드 요율로 추가 요금이 청구된다"**, 그리고 데이터 합성 기법이 **"미세 조정 데이터셋의 크기를 최대 15k 프롬프트-응답 쌍까지 늘릴 수 있다"**. "작은 모델이니 싸다"는 **추론 단계**의 이야기이고 **만드는 단계는 교사 호출만큼 돈이 듭니다.**

### 4) FM을 미세 조정하는 네 가지 방법 (목표 3.3.2) {#fine-tuning-methods}

공식 SageMaker AI 문서는 미세 조정의 **주요 접근을 둘**로 갈라 둡니다 — **도메인 적응**과 **명령 기반 미세 조정**. 여기에 목표 3.3.2가 드는 **전이 학습**(상위 개념)과 **지속적인 사전 훈련**(앞 절)을 합치면 넷이 됩니다.

| 방법 | 공식이 적는 목적 | 데이터 형식 | 가중치 |
|---|---|---|---|
| **명령 튜닝** | 사전 훈련된 FM의 **특정 작업** 성능 향상 | **JSON Lines**. 프롬프트-응답 쌍을 **지시문 형태**로 | 바뀐다 |
| **도메인 적응** | **도메인 전문 용어**(업계 전문 용어·기술 용어) 이해 | **CSV · JSON · TXT**. 단일 폴더의 **단일 파일** | 바뀐다 |
| **전이 학습** | 사전 훈련 모델을 **관련된 새 작업**에 재사용 | 전략에 따라 다르다 | 전략에 따라 다르다 |
| **지속적인 사전 훈련** | 모델에 **새 도메인 지식** 주입 | **비레이블** 말뭉치 | 바뀐다 |

**명령 튜닝.** 공식 정의는 **"레이블 예제를 써서 사전 훈련된 파운데이션 모델의 특정 작업 성능을 개선한다. 레이블 예제는 프롬프트-응답 쌍으로 형식을 갖추고 지시문으로 표현된다. 이 미세 조정 과정은 모델의 가중치를 수정한다"**입니다. 데이터는 **JSON Lines** 형식이고 한 폴더에 여러 `.jsonl` 파일을 둘 수 있으며, 선택적으로 `template.json`으로 입출력 형식을 정의합니다. 템플릿을 주지 않으면 기본 템플릿이 쓰이고, 그 경우 각 줄에 **`{instruction}` · `{context}` · `{response}`** 필드가 있어야 합니다. 직접 템플릿을 쓸 때는 `"prompt"`와 `"completion"` 키로 필요한 필드를 정의합니다. 공식은 **FLAN** 계열(Fine-tuned LAnguage Net)이 바로 이 명령 튜닝으로 **다양한 작업에서 제로샷 성능을 높인** 모델군이라고 적습니다.

**도메인 적응.** 공식 정의는 **"사전 훈련된 파운데이션 모델을 활용해 제한된 도메인 특화 데이터로 특정 작업에 적응시킨다. 프롬프트 엔지니어링 노력이 충분한 사용자 지정을 주지 못하면 도메인 적응 미세 조정으로 업계 전문 용어·기술 용어 같은 도메인 특화 언어와 동작하게 할 수 있다. 이 미세 조정 과정은 모델의 가중치를 수정한다"**입니다. 데이터 형식이 명령 튜닝과 다릅니다 — **CSV · JSON · TXT** 중 하나이고 **모든 훈련 데이터가 한 폴더 안의 단일 파일**이어야 하며, CSV·JSON이면 **`Text` 열**에서, `Text`로 이름 붙은 열이 없으면 **첫 열**에서 데이터를 가져옵니다.

> ⚠️ **두 방법 모두 검증 데이터가 선택입니다.** 공식은 검증 폴더를 주지 않으면 **"훈련 데이터의 일정 비율이 검증용으로 떼어진다"**고 적고, 그 비율은 **하이퍼파라미터로 조정**합니다.

**전이 학습.** 공식 정의는 **"한 작업에 사전 훈련된 모델을 새롭고 관련된 작업에 맞춰 미세 조정하는 ML 기법"**입니다. Well-Architected 렌즈가 둘의 관계를 한 줄로 못박습니다 — 완전 관리형 서비스가 요구를 못 맞추면 **"내 데이터로 미세 조정할 수 있는 사전 훈련 모델에서 시작하는 것을 고려하라. 전이 학습으로 알려진 이 접근은 이미 자원 집약적 훈련을 거친 모델의 이익을 누리게 해 준다"**, 그래서 **"처음부터 훈련하는 것과 비슷하거나 더 나은 성능을 현저히 적은 연산 자원으로"** 얻습니다.

공식이 드는 전이 학습 **전략 세 가지**는 "무엇이 다른가"로 갈립니다.

| 전략 | 소스와 타깃 | 쓰는 때 |
|---|---|---|
| **전도적(transductive)** | 도메인이 **다르지만 관련**됨, 작업은 같다 | 타깃 도메인의 **레이블 데이터가 거의 없을 때** |
| **귀납적(inductive)** | 도메인은 **같고 작업이 다르다** | 예: 대량 텍스트로 사전 훈련한 뒤 감정 분석으로 미세 조정 |
| **비지도** | **양쪽 모두 비레이블**일 때 | 레이블 소스 데이터를 얻기 어렵거나 비쌀 때 |

미세 조정 절차도 세 걸음으로 정리돼 있습니다 — **① 사전 훈련 모델 선택**(원래 어떤 작업을 했는지 알면 전환이 잘 되는 모델을 고를 수 있다) **② 모델 구성**(사전 훈련 층의 **가중치 동결** · **마지막 층 제거** · **새 층 추가**) **③ 타깃 도메인으로 훈련**. 이 셋째 단계에서 공식은 **하이퍼파라미터가 가중치와 달리 데이터로 학습되지 않고 미리 정해진다**는 점을 따로 짚습니다.

> ⚠️ **증류도 전이 학습의 한 전략입니다.** 공식이 생성형 AI의 전이 학습 전략으로 **교사-학생 학습**을 들고 **"더 크고 복잡한 교사 모델이 더 작고 단순한 학생 모델을 가르치고, 학생은 교사의 행동을 모방하도록 배워 사실상 지식이 전이된다"**고 적습니다. 같은 목록에 **제로샷·퓨샷 학습**, 도메인 적대적 훈련, 특성 분리, **교차 모달 전이 학습**도 들어 있습니다.

### 5) 미세 조정용 데이터 준비 — 여섯 축 (목표 3.3.3) {#data-prep}

공식 목표가 드는 여섯 항목을 그대로 축으로 씁니다. 출발점은 공식 처방적 지침의 한 문장입니다 — **"어느 접근이든 데이터 품질이 가장 중요하다. 깨끗하고 대표성 있고 적절한 크기의 데이터셋이 모델 성능을 유지하고 끌어올리는 데 필수적이다."**

**① 데이터 큐레이션.** AWS CAF의 AI 거버넌스 관점이 이것을 **"데이터 카탈로그와 데이터 제품에서 가치를 만드는"** 역량으로 올려 두고 이렇게 적습니다 — **"데이터를 획득·레이블·정제·가공하고 상호 작용하는 능력이 속도를 높이고 가치 실현 시간을 줄이며 모델 성능(예: 정확도)을 끌어올린다. 모델 정확도가 정체되면 돌아가서 알고리즘에 먹이는 데이터를 풍부하게 하거나 늘리거나 개선하는 것을 고려하라. 그것이 아키텍처를 다시 짜거나 모델링만으로 마지막 1%를 짜내는 것보다 훨씬 쉬울 때가 많다."** 데이터 잠재력을 늘리는 길로 **외부 데이터 소스 구매 · ML 알고리즘으로 합성 데이터 증강·생성 · 사내 데이터 레이블을 위한 크라우드소싱 · 데이터 생성과 수집을 자동화하도록 업무 방식 변경**을 듭니다.

사전 훈련 쪽 데이터 정제의 원칙도 같습니다. 공식은 **"쓰레기를 넣으면 쓰레기가 나온다"**를 인용하며 **"생성형 AI는 흔히 방대한 데이터셋으로 시작하지만 양만으로는 충분하지 않다"**고 적고, 할 일로 **중복 제거 · 민감한 개인 정보 삭제 · 유해하거나 무관한 콘텐츠 필터링 · 정규화와 형식 변환**(토큰화, HTML 태그 제거, 이미지 해상도 정규화)을 듭니다. 그리고 ⚠️ **"나쁜 데이터가 작은 비율이어도 출력에 과도한 영향을 줄 수 있다"**고 경고합니다.

**② 거버넌스.** 공식은 AI 거버넌스를 **"데이터 거버넌스의 많은 관행을 AI/ML 용례에 적용하는 것"**으로 정의하고, 역량으로 **모델 훈련·버전 관리·지원 용례의 문서화**, 윤리적 모델 사용 안내, **프로덕션에서 정확도·드리프트·과적합·과소적합 모니터링**을 듭니다. 생성형 AI에는 **데이터 품질과 무결성, 생성형 AI 독성·편향의 거버넌스, FMOps**가 추가로 필요하고, **"민감한 데이터는 적절히 보호해 파운데이션 모델 훈련에 민감한 데이터를 쓰는 위험을 완화해야 한다"**고 적습니다.

보안 쪽 공식 지침은 더 구체적입니다 — **"모델 개발의 사전 훈련·미세 조정 단계에서 수집된 데이터는 전송 중·저장 중·사용 중 모두 보호돼야 한다"**, ⚠️ **"모델 훈련에 민감한 데이터를 쓰는 것을 피하라. 추론 중 데이터 유출 등으로 모델 출력에서 의도치 않은 공개가 생길 수 있다"**, 그리고 **훈련에 쓰인 데이터에 태그·레이블을 붙여 데이터 분류 정책에 정렬**시키고 **모델이 쓴 모든 데이터 소스에 대해 검증 가능한 메커니즘**을 만들라고 합니다.

**데이터 계보**는 그 검증 가능성의 구현입니다. 공식은 계보를 **"책임 있는 ML 운영의 핵심 구성 요소"**로 적고, **"출처에서 여러 변환을 거쳐 모델 배포까지 데이터의 여정을 추적해 ML 시스템에 책임성과 투명성을 만든다"**고 설명합니다. 추적 시스템은 **누가 데이터에 접근했고 무엇이 언제 바뀌었는지**를 기록해야 하며, ⚠️ **"데이터 손상이나 악의적 조작으로 생긴 예상 밖 편차를 탐지하기 위해 훈련 데이터에 대한 무결성 검사를 구현"**해야 합니다. 공식이 드는 관련 위험이 **"미세 조정 시나리오에서 악의적 훈련 데이터가 모델 동작에 영향을 주는 데이터 포이즈닝"**입니다.

Amazon Bedrock에서 쓸 수 있는 보호 장치도 공식 절차에 들어 있습니다 — 기본적으로 **AWS가 소유·관리하는 키로 모델을 암호화**하고, 원하면 **사용자 지정 KMS 키**를 고를 수 있으며, 입력·출력 S3 위치를 포함하는 **VPC**를 지정해 훈련 데이터와 작업을 보호할 수 있습니다. ⚠️ 다만 **VPC 구성을 포함하면 콘솔이 작업용 서비스 역할을 새로 만들어 주지 못하므로** 사용자 지정 서비스 역할을 먼저 만들어야 합니다.

**③ 크기.** 두 층으로 기억합니다.

- **상대적 크기** — 공식은 **"미세 조정 데이터셋은 보통 최초 사전 훈련에 쓰인 것보다 훨씬 작지만, 효과적인 모델 적응을 위해 신중하게 선별돼야 한다"**고 적습니다.
- **절대적 한도** — 모델마다 다릅니다. Amazon Bedrock의 공식 요구 표에서 **Meta Llama 3.1·3.2·3.3**은 훈련과 검증 레코드 합이 **최소 100 · 최대 10,000**(서비스 쿼터로 조정 가능), **Amazon Titan Image Generator G1 V1**은 훈련 데이터셋 레코드 **5~10,000**, **Amazon Titan Multimodal Embeddings G1**은 **1,000~500,000**입니다. Amazon Titan Text 계열은 **훈련 데이터셋 파일 1 GB · 검증 데이터셋 파일 100 MB**가 상한입니다.

> ⚠️ **"미세 조정에는 N건이 필요하다"는 보편 숫자는 공식에 없습니다.** 숫자는 **모델별 표**에 있고, 시험은 "모델·방법에 따라 요구가 다르다"는 사실까지만 묻습니다.

**④ 레이블 지정.** 레이블은 **미세 조정과 지속적 사전 훈련을 가르는 바로 그 축**입니다. 공식은 작업 미세 조정의 데이터셋이 **"명시적으로 레이블된다"**고, 도메인 미세 조정은 **"비레이블 텍스트를 쓸 수 있다"**고 적습니다. 그리고 레이블 자체가 품질 문제의 출처입니다 — 공식 AI 편향 문서가 **"사람이 데이터를 훑어 레이블을 달아야 할 때가 있고, 그 과정에서 사람이 무의식적으로 자기 편향을 데이터셋에 넣을 수 있다"**고 적고, 예로 **"어떤 물건이나 브랜드가 싫어서 평범한 제품 리뷰를 부정으로 레이블하는"** 경우를 듭니다.

그래서 공식 책임 있는 AI 지침은 레이블을 **검토 프로세스로** 다룹니다 — **"정답 레이블과 사실 콘텐츠에 대한 정기 검토 프로세스를 만들라"**, 사람 검토자나 **권위 있는 출처와의 대조로 사실 확인**을 하라, 그리고 ⚠️ **평가용 데이터셋에는 더 엄격한 기준을 적용**해 **여러 검토자가 각 주장을 검증하고 높은 일치율을 달성한 뒤 레이블을 받아들이라고 합니다.** 이 모범 사례가 **확립되지 않았을 때의 위험 수준은 High**입니다.

**⑤ 대표성.** 공식 기준은 **"예상되는 시스템 사용자 범위의 인구통계를 적절히 대표하는가"**이고, **"통계적으로 유효한 공정성 평가를 할 만큼 각 인구통계 집단의 표현이 충분한지 계산하라"**고 합니다. 구현 고려 사항이 그대로 시험 문항이 됩니다.

| 공식 권고 | 요점 |
|---|---|
| 과대·과소 대표 집단 식별 | 용례 기준으로 구성을 **분석**한다 |
| **자기 보고 인구통계 레이블** 고려 | 알고리즘이나 사람이 **추정한** 인구통계보다 설문·사용자 제공 정보를 쓴다 |
| **통계적 검정력 계산** | 출시 기준에서 거꾸로 짚어, 집단별로 요구 신뢰도를 낼 만큼 예제가 있는지 본다 |
| 표현 격차 해소 | 과소 대표 집단 데이터를 더 모으거나 **계층 추출(stratified sampling)**을 쓴다 |
| ⚠️ 완화가 새 문제를 만들지 않는지 검증 | 한 축을 균형 맞추다 **교차 집단에 새 불균형**이 생길 수 있다 |

대표성은 인구통계만이 아닙니다. 공식은 데이터셋에 **본질적 변이(intrinsic)**와 **교란 변이(confounding)**를 **둘 다** 넣으라고 하고, 둘을 **"시스템이 주의해야 할 변이"**와 **"시스템이 무시해야 할 변이"**로 정의합니다. 개 인식 시스템의 공식 예가 선명합니다 — **코 모양의 전 분포**는 본질적 변이, **머리 자세의 전 범위**는 교란 변이입니다.

**⑥ 사용자 피드백을 통한 강화 학습(RLHF).** 다음 절에서 따로 다룹니다.

> ⚠️ **훈련 데이터와 평가 데이터는 완전히 분리합니다.** 공식은 데이터셋 종류를 **훈련 · 미세 조정 · 검증 · 교정(calibration) · 정렬(alignment)**로 들고, 이것들을 단계에 배분할 때 **"평가 데이터셋과 완전히 분리"**하라고 하며 **"측정 무결성을 보호하기 위해 훈련-평가 중복을 차단하는 시스템을 설계하라"**고 적습니다. 이 모범 사례의 미확립 위험도 **High**입니다.

### 6) RLHF — 사람 피드백이 들어가는 자리 (목표 3.3.3) {#rlhf}

공식 정의는 **"사람 피드백을 사용해 ML 모델이 더 효율적으로 자기 학습하도록 최적화하는 ML 기법"**이고, 핵심은 한 문장으로 요약됩니다 — **"RLHF는 사람 피드백을 보상 함수에 넣어, ML 모델이 사람의 목표·욕구·필요에 더 정렬된 작업을 수행하게 한다."** 위상도 분명합니다 — **"RLHF는 LLM이 진실하고 무해하며 유용한 콘텐츠를 생산하게 하는 업계 표준 기법으로 인정된다."**

공식은 모델이 준비됐다고 볼 때까지 **네 단계**를 거친다고 적습니다.

| 단계 | 하는 일 | 사람의 역할 |
|---|---|---|
| **① 데이터 수집** | 사람이 만든 프롬프트-응답 세트를 훈련 데이터로 준비 | 지식 근로자가 **정확하고 자연스러운 답**을 쓴다 |
| **② 언어 모델의 지도 미세 조정** | 상용 사전 훈련 모델을 기준 모델로 삼아 미세 조정하고, 응답을 ①의 사람 응답과 비교해 **유사도를 점수화**한다 | 비교 대상이 된다 |
| **③ 별도의 보상 모델 구축** | 같은 프롬프트에 대한 **여러 응답**을 두고 모은 **선호**로 보상 모델을 만든다 | ⚠️ **응답 품질의 선호를 표시**한다 |
| **④ 보상 모델로 언어 모델 최적화** | 언어 모델이 내부적으로 응답들을 평가해 **보상이 가장 클 응답**을 고르도록 정책을 다듬는다 | 직접 개입하지 않는다 |

③이 공식이 **"RLHF의 핵심"**이라고 부르는 자리입니다 — **"사람 피드백에 기반해 별도의 AI 보상 모델을 훈련하고, 그 모델을 보상 함수로 써서 강화 학습으로 정책을 최적화한다. (...) 이 응답 평가 선호를 써서, 어떤 프롬프트 응답에 사람이 몇 점을 줄지 자동으로 추정하는 보상 모델을 만든다."**

RLHF를 쓰는 자리는 **후속 훈련·미세 조정 단계**입니다. 공식 처방적 지침은 배포 후의 **사용자 생성 데이터와 피드백 루프**를 수명 주기의 일부로 다루면서, 사용자 질문·모델 응답·명시적 평가를 모아 **정답(ground truth) 데이터셋에 넣고** 주기적으로 재훈련·미세 조정하라고 합니다. 그리고 **"정식 RLHF 없이도 더 단순한 접근이 있다 — 모델 출력의 일부를 지속적으로 사람이 검토하는 것, 품질 보증과 비슷하다"**고 적습니다.

> ⚠️ **RLHF와 「강화 미세 조정」은 다릅니다.** Amazon Bedrock의 강화 미세 조정은 **"레이블된 입력-출력 쌍을 주는 대신 응답 품질을 평가하는 보상 함수를 내가 정의하고, 모델이 그 보상 함수에서 받은 피드백 점수로 반복 학습"**합니다. RLHF의 보상 신호는 **사람의 선호에서 학습된 보상 모델**에서 오고, 강화 미세 조정의 보상 신호는 **내가 작성한 함수**에서 옵니다.

> ℹ️ **사람 피드백 수집의 공식 경로.** 공식 RLHF 문서는 Amazon SageMaker Ground Truth가 **"ML 수명 주기 전반에 사람 피드백을 반영하는 가장 포괄적인 human-in-the-loop 기능 집합"**을 제공하고, 응답을 **순위 매기거나 분류한 「비교·순위 데이터」가 "사실상 보상 모델 또는 보상 함수"**가 된다고 적습니다. 다만 이 기능은 공식 시험 가이드의 범위 내 서비스 목록에 들어 있지 않으므로, 이 사이트의 문항에서는 정답 보기로 쓰지 않습니다.

---

## ✍️ 시험 포인트

- **데이터에 레이블이 있는지만 먼저 봅니다.** 있으면 **미세 조정**, 없으면 **지속적인 사전 훈련**. "사내 문서 수십만 건" 같은 표현은 거의 항상 비레이블 신호입니다.
- **"바꾸려는 것"을 봅니다** — **작업 수행 방식**(요약·분류·응답 형식)이면 미세 조정, **도메인 지식·전문 용어**면 지속적인 사전 훈련입니다.
- **데이터 형식이 방법을 지목합니다** — **프롬프트-응답 쌍**이 보이면 명령 튜닝, **원시 텍스트 한 파일**이면 도메인 적응입니다.
- **"작은 모델로 큰 모델급 품질"**이라는 말이 나오면 **증류**입니다. 반대로 **"사용자 선호에 맞게 정렬"**이면 **RLHF**입니다.
- **증류 비용 문항은 교사 쪽을 봅니다** — 절감은 **추론 단계**에서 나고, **만드는 단계에는 교사 추론 요금이 추가로 붙습니다.**
- **사용자 지정 모델 + 호출량이 적다**는 조합에서 **"프로비저닝된 처리량이 유일한 길"은 오답**입니다 — **사용자 지정 모델 배포(온디맨드)**가 있고, 그쪽이 적은 호출량에 맞습니다(제약은 리전·기반 모델·시점).
- **데이터 준비 문항은 「여섯 축」 중 하나만 묻습니다** — 대표성이면 **인구통계 표현과 통계적 검정력**, 레이블이면 **검토·사실 확인**, 거버넌스면 **계보·접근 기록·무결성 검사**입니다.
- **"평가 데이터를 훈련에 섞어 성능을 올렸다"**는 보기는 항상 오답입니다 — 공식은 **훈련-평가 중복 차단**을 명시하고 위험을 **High**로 둡니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"미세 조정과 지속적인 사전 훈련은 사실상 같다"** → 입력 데이터가 다릅니다. 미세 조정은 **레이블 데이터**, 지속적인 사전 훈련은 **비레이블 데이터**입니다.
- ❌ **"레이블 데이터가 없어도 미세 조정하면 된다"** → 공식 FAQ가 바로 그 상황의 처방으로 **지속적 사전 훈련을 먼저** 하라고 적습니다. 그러면 이후 미세 조정에 **훨씬 적은 레이블 레코드**로 됩니다.
- ❌ **"명령 튜닝은 가중치를 바꾸지 않는다"** → 공식 문서는 **"이 미세 조정 과정은 모델의 가중치를 수정한다"**고 명시합니다. 가중치를 안 바꾸는 것은 **프롬프트 엔지니어링·컨텍스트 내 학습**입니다.
- ❌ **"전이 학습은 미세 조정과 다른 별개 기법이다"** → 공식은 **사전 훈련 모델에서 출발해 미세 조정하는 접근 자체**를 "전이 학습으로 알려진" 것이라고 부릅니다. 전이 학습이 상위 개념이고 미세 조정이 수단입니다.
- ❌ **"증류는 학생 모델이 교사를 가르치는 것이다"** → 방향이 반대입니다. 지식은 **교사(크고 유능) → 학생(작고 빠르고 저렴)**으로 갑니다.
- ❌ **"증류는 교사 응답을 공짜로 얻는다"** → 데이터 합성 기법이 돌면 **교사 모델 추론 호출이 온디맨드 요율로 추가 과금**됩니다.
- ❌ **"호출 로그의 프롬프트-응답 쌍을 쓰면 교사 모델을 아무것으로 지정해도 된다"** → **작업의 교사 모델이 로그의 모델과 일치하지 않으면 로그가 아예 사용되지 않습니다.**
- ❌ **"RLHF에서 사람이 모델에 직접 점수를 매겨 학습시킨다"** → 사람은 **선호를 표시**하고, 그 선호로 만든 **별도의 보상 모델**이 정책 최적화의 보상 함수가 됩니다.
- ❌ **"보상 함수를 정의하면 그것이 RLHF다"** → 보상 함수를 내가 작성하는 것은 **강화 미세 조정**입니다. RLHF의 보상은 **사람 선호에서 학습**됩니다.
- ❌ **"데이터는 많으면 많을수록 좋다"** → 공식은 **"양만으로는 충분하지 않다"**고 적고, **"나쁜 데이터가 작은 비율이어도 출력에 과도한 영향"**을 준다고 경고합니다.
- ❌ **"미세 조정에는 최소 N건이 필요하다"** → 보편 숫자는 공식에 없습니다. 한도는 **모델별 표**에 있습니다(Llama 3.x 100~10,000 · Titan Multimodal Embeddings 1,000~500,000).
- ❌ **"한 집단 데이터를 늘려 균형을 맞췄으니 대표성 문제는 끝났다"** → 공식은 **"한 인구통계 축을 균형 맞추다 교차 집단에 새 불균형이 생기지 않았는지 검증하라"**고 적습니다.

---

## 🧪 자가 점검

**Q1.** 사내 보험 약관·심사 지침 12만 건이 있습니다. 레이블은 없고, 모델이 업계 용어를 이해하지 못해 답이 엉성합니다. 어떤 방법이고, 나중에 "청구 요약" 작업으로 미세 조정할 계획에는 어떤 이득이 있나요? (→ 2) 지속적인 사전 훈련이 미세 조정의 비용을 깎는다)

<details><summary>정답 보기</summary>

**지속적인 사전 훈련**입니다. 공식은 이것을 **"새 비레이블 데이터로 모델을 훈련해 기본 모델에 아직 없는 새 도메인 지식을 가르치는"** 용도로 적고, **"대규모 언어 모델 훈련에 공개되지 않은 사내 문서 같은 비공개 데이터"**를 그 예로 듭니다.

이득은 공식 FAQ가 직접 적습니다 — 기본 모델을 **바로 미세 조정하면** 정확한 결과까지 **"대량의 레이블 훈련 레코드와 긴 훈련 시간"**이 들지만, 먼저 비레이블 데이터로 도메인에 적응시킨 뒤 그 사용자 지정 모델을 다운스트림 작업에 미세 조정하면 **"현저히 더 적은 레이블 훈련 레코드와 더 짧은 훈련 시간"**으로 됩니다.
</details>

**Q2.** 명령 튜닝과 도메인 적응은 둘 다 "미세 조정"인데, 준비해야 할 **데이터 파일**이 어떻게 다른가요? 가중치는 각각 바뀌나요? (→ 4) FM을 미세 조정하는 네 가지 방법)

<details><summary>정답 보기</summary>

**데이터 형식이 다릅니다.**

- **명령 튜닝** — **JSON Lines** 형식이고, 레이블 예제가 **프롬프트-응답 쌍**으로, 그것도 **지시문으로 표현**돼야 합니다. 한 폴더에 여러 `.jsonl` 파일을 둘 수 있고, `template.json`을 주지 않으면 기본 템플릿이 쓰여 각 줄에 **`{instruction}` · `{context}` · `{response}`** 필드가 필요합니다.
- **도메인 적응** — **CSV · JSON · TXT** 중 하나이고 **모든 훈련 데이터가 한 폴더 안의 단일 파일**이어야 합니다. CSV·JSON이면 **`Text` 열**에서, 그런 이름의 열이 없으면 **첫 열**에서 데이터를 가져옵니다.

**가중치는 둘 다 바뀝니다.** 공식이 양쪽 페이지에 **"이 미세 조정 과정은 모델의 가중치를 수정한다"**를 똑같이 적습니다.
</details>

**Q3.** 프로덕션에서 교사 모델을 수개월 호출해 왔고 호출 로그가 S3에 쌓여 있습니다. 그 **프롬프트-응답 쌍**을 증류 훈련 데이터로 쓰려면 어떤 조건이 있고, 요금 축에서 무엇을 주의해야 하나요? (→ 3) 증류)

<details><summary>정답 보기</summary>

**조건:** 호출 로그의 **프롬프트-응답 쌍**을 쓰기로 하면 Amazon Bedrock은 교사 응답을 **재생성하지 않고** 로그의 응답으로 학생 모델을 미세 조정합니다. 그래서 ⚠️ **증류 작업에 지정한 교사 모델이 호출 로그에 쓰인 모델과 일치해야 하고, 일치하지 않으면 그 호출 로그는 아예 사용되지 않습니다.** 응답에 `requestMetadata`를 붙여 뒀다면 메타데이터 필터로 **용례별 로그만** 골라 쓸 수 있습니다.

**요금:** 이 경로는 교사 재생성이 없지만, Bedrock이 독자 데이터 합성 기법으로 더 품질 높은 교사 응답을 만드는 경로에서는 **"교사 모델 추론 호출에 대해 교사 모델의 온디맨드 요율로 추가 요금이 청구"**되고, 합성 기법이 **"미세 조정 데이터셋의 크기를 최대 15k 프롬프트-응답 쌍까지 늘릴 수 있다"**는 점을 함께 봐야 합니다. 그리고 결과물은 사용자 지정 모델이므로 **프로비저닝된 처리량을 구매해야 쓸 수 있습니다.**
</details>

**Q4.** RLHF 네 단계에서 **사람이 실제로 하는 일**은 무엇이고, 그 입력이 무엇으로 변환돼 모델을 바꾸나요? (→ 6) RLHF)

<details><summary>정답 보기</summary>

사람은 **같은 프롬프트에 대한 여러 응답을 보고 품질에 대한 선호를 표시**합니다(그 앞 단계에서는 프롬프트에 대한 정확하고 자연스러운 **모범 답안**을 씁니다).

그 선호는 **별도의 보상 모델**로 변환됩니다. 공식은 이것을 **"RLHF의 핵심"**이라고 부르며 **"사람 피드백에 기반해 별도의 AI 보상 모델을 훈련하고, 그 모델을 보상 함수로 써서 강화 학습으로 정책을 최적화한다"**고 적고, 보상 모델이 **"어떤 프롬프트 응답에 사람이 몇 점을 줄지 자동으로 추정"**한다고 설명합니다.

네 단계는 **① 데이터 수집 → ② 언어 모델의 지도 미세 조정 → ③ 별도의 보상 모델 구축 → ④ 보상 모델로 언어 모델 최적화**입니다. 마지막 단계에서 언어 모델은 내부적으로 응답들을 평가해 **보상이 가장 클 응답**을 고르도록 정책을 다듬습니다.
</details>

**Q5.** 미세 조정 데이터가 부족해 **평가(벤치마크) 데이터셋 일부를 훈련에 섞겠다**는 제안이 올라왔습니다. 공식 근거로 검토하세요. (→ 5) 미세 조정용 데이터 준비)

<details><summary>정답 보기</summary>

**해서는 안 됩니다.** 공식 책임 있는 AI 지침은 데이터셋을 단계에 배분할 때 **"평가 데이터셋과 완전히 분리"**하라고 하고, **"측정 무결성을 보호하기 위해 훈련-평가 중복을 차단하는 시스템을 설계하라"**고 명시합니다. 이 모범 사례가 확립되지 않았을 때의 **위험 수준은 High**입니다. 같은 지침의 다른 모범 사례가 **"데이터셋 사이의 잠재적 중복을 식별"**하는 것을 따로 둘 정도로 중요한 축입니다.

데이터가 부족할 때의 공식 처방은 다릅니다 — 기존 데이터의 **격차를 평가**한 뒤 **외부 소스 · 자체 수집 · 크라우드소싱 · 합성 생성**으로 **빠진 데이터셋을 확보하거나 만드는** 것입니다.
</details>

**Q6.** 공정성 평가를 위해 데이터셋의 대표성을 점검합니다. 공식이 권고하는 레이블 수집 방식과, "균형을 맞췄다"고 끝내면 안 되는 이유는 무엇인가요? (→ 5) 미세 조정용 데이터 준비)

<details><summary>정답 보기</summary>

**레이블 수집:** 공식은 **자기 보고(self-reported) 인구통계 레이블**을 쓰라고 권고하고, 그 대비로 **"알고리즘이나 사람이 인구통계 정보를 추정한 것"**을 듭니다. 예로 **설문 응답이나 사용자가 제공한 정보**를 씁니다. 표현 격차는 **과소 대표 집단의 데이터를 더 모으거나 계층 추출(stratified sampling)**로 메웁니다.

**끝내면 안 되는 이유:** 공식 구현 고려 사항의 마지막 항목이 ⚠️ **"편향 완화 노력이 새로운 공정성 문제를 들여오지 않았는지 검증하라"**이고, 그 예가 **"한 인구통계 축을 균형 맞추다 교차(intersectional) 집단에 의도치 않게 불균형을 만들지 않았는지 확인"**하는 것입니다. 더해서 공식은 **"통계적으로 유효한 공정성 평가를 할 만큼 각 집단의 표현이 충분한지"**를 **출시 기준에서 거꾸로 계산**하라고 합니다.
</details>

---

### 📌 출처

1. What are Foundation Models? — `aws.amazon.com/what-is/foundation-models/` (2026-11-03 확인)
2. Customize your model to improve its performance for your use case (Amazon Bedrock) — `docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html` (2026-11-06 재확인) · ⚠️ **이 페이지가 적는 사용자 지정 방법은 세 가지입니다** — 지도 미세 조정 · 강화 미세 조정 · 증류. **지속적인 사전 훈련과 가져온 모델은 더 이상 이 페이지에 없습니다**(두 방법으로 확인: 본문 추출과 AWS 문서 리더 양쪽에서 `pre-training` 0건, 대조군 `fine-tuning` 8건). 지속적 사전 훈련의 살아 있는 정본은 **콘솔 도움말** `help-panel/bedrock/latest/console/hp-custom-models-create-continued-pre-training-job.html`(아래 8번)과 **API `customizationType` 유효값**이고, 다섯 작업 유형 목록은 §2가 그 유효값으로 적습니다. 이 페이지에서 쓰는 사실은 **세 방법의 정의**와 **훈련 과금 축**(처리 토큰 수 = 코퍼스 토큰 × 에폭, 그리고 모델당 월 저장 요금)입니다
3. Customize a model with distillation in Amazon Bedrock — `docs.aws.amazon.com/bedrock/latest/userguide/model-distillation.html` (2026-11-03 확인)
4. Prepare data for fine-tuning your models (Amazon Bedrock) — `docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html` (2026-11-03 확인)
5. Submit a model customization job for fine-tuning (Amazon Bedrock) — `docs.aws.amazon.com/bedrock/latest/userguide/model-customization-submit.html` (2026-11-03 확인)
6. Increase model invocation capacity with Provisioned Throughput in Amazon Bedrock — `docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html` (2026-11-03 확인)
7. Custom models (Amazon Bedrock 콘솔 도움말) — `docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-custom-models.html` (2026-11-03 확인)
8. Create a Continued Pre-training job (Amazon Bedrock 콘솔 도움말) — `docs.aws.amazon.com/help-panel/bedrock/latest/console/hp-custom-models-create-continued-pre-training-job.html` (2026-11-03 확인)
9. Amazon Bedrock FAQs (지속적 사전 훈련을 쓰는 이유) — `aws.amazon.com/bedrock/faqs/` (2026-11-03 확인)
10. create_model_customization_job — 사용자 지정 유형 유효값 — `docs.aws.amazon.com/boto3/latest/reference/services/bedrock/client/create_model_customization_job.html` (2026-11-03 확인)
11. Foundation models and hyperparameters for fine-tuning (Amazon SageMaker AI) — `docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning.html` (2026-11-03 확인)
12. Fine-tune a large language model (LLM) using prompt instructions — `docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-instruction-based.html` (2026-11-03 확인)
13. Fine-tune a large language model (LLM) using domain adaptation — `docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-domain-adaptation.html` (2026-11-03 확인)
14. What is Transfer Learning? — `aws.amazon.com/what-is/transfer-learning/` (2026-11-03 확인)
15. MLSUS02-BP01 Consider AI services and pre-trained models — `docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlsus02-bp01.html` (2026-11-03 확인)
16. What is RLHF? — `aws.amazon.com/what-is/reinforcement-learning-from-human-feedback/` (2026-11-03 확인)
17. Data lifecycle in generative AI (AWS Prescriptive Guidance) — `docs.aws.amazon.com/prescriptive-guidance/latest/strategy-data-considerations-gen-ai/lifecycle.html` (2026-11-03 확인)
18. Governance perspective: Managing an AI-driven organization (AWS CAF for AI) — `docs.aws.amazon.com/whitepapers/latest/aws-caf-for-ai/governance-perspective-managing-an-aiml-driven-organization.html` (2026-11-06 재확인) · ⚠️ **브라우저로는 열리지 않습니다.** 이 URL은 `302`로 Well-Architected 머신 러닝 렌즈 인덱스로 보내지고(실제 브라우저로 확인), 그 인덱스에는 아래 §5 ①·②가 인용하는 문장이 없습니다. ⚠️ **다만 문서가 사라진 것은 아닙니다** — 같은 URL에서 본문 **14,909자가 그대로 서빙**되고 그중 「Data curation」 절(7,030~9,564자)이 §5 ①의 인용문을 담고 있습니다(2026-11-06 실측). 즉 **인용은 유효하고 사람이 열 수 없을 뿐**입니다. 사람이 열 수 있는 인접 정본은 일반 AWS CAF 거버넌스 관점 `whitepapers/latest/overview-aws-cloud-adoption-framework/governance-perspective.html`(「Data curation」 역량 — ⚠️ 그쪽은 **메타데이터와 데이터 카탈로그 중심이라 내용이 다릅니다**)과 머신 러닝 렌즈의 `MLREL02-BP03`(훈련 데이터 버전 관리)·`MLPERF06-BP03`(데이터 드리프트)입니다(셋 다 2026-11-06 실측 `200`·리다이렉트 0)
19. Security perspective: Compliance and assurance of AI systems (AWS CAF for AI) — `docs.aws.amazon.com/whitepapers/latest/aws-caf-for-ai/security-perspective-compliance-and-assurance-of-aiml-systems.html` (2026-11-06 재확인) · ⚠️ **위 18번과 같은 상태입니다** — 브라우저로는 `302`로 머신 러닝 렌즈 인덱스로 튕기지만 본문 **19,086자가 그 URL에 그대로** 있고 「Data protection」 절(14,971~17,706자)이 §5 ②의 보안 인용문을 담고 있습니다. ⭐ **이 페이지 자신이 머신 러닝 렌즈를 가리킵니다** — 데이터 보호 정책이 "operationalized, like **MLSEC-07: Keep only relevant data** in the Machine Learning Lens"라고 적어, 사람이 열 수 있는 정본으로 가는 길을 공식이 직접 줍니다. 그 밖에 살아 있는 인접 출처는 **민감 데이터 프라이버시** `MLSEC03-BP03`, **데이터 계보** `MLSEC03-BP04`, **Bedrock 훈련의 KMS 키·VPC** `bedrock/latest/userguide/model-customization-submit.html`입니다(셋 다 2026-11-06 실측 `200`·리다이렉트 0)
20. RAIDP01-BP02 Identify the datasets needed for training and customizing your system — `docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp01-bp02.html` (2026-11-03 확인)
21. RAIDP03-BP02 Minimize unwanted bias in your datasets — `docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp02.html` (2026-11-03 확인)
22. RAIDP03-BP04 Include both intrinsic and confounding variations in your datasets — `docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp04.html` (2026-11-03 확인)
23. RAIDP03-BP05 Review the correctness of the content of your datasets — `docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp03-bp05.html` (2026-11-03 확인)
24. MLSEC03-BP04 Enforce data lineage — `docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlsec03-bp04.html` (2026-11-03 확인)
25. Capability 1. Providing developers and data scientists secure access to generative AI FMs — `docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-generative-ai/gen-ai-model-inference.html` (2026-11-03 확인)
26. What Is AI Bias? — `aws.amazon.com/what-is/ai-bias/` (2026-11-03 확인)
27. What is Data Governance? — `aws.amazon.com/what-is/data-governance/` (2026-11-03 확인)
28. Prepare data for open-weight models (강화 미세 조정 데이터) — `docs.aws.amazon.com/bedrock/latest/userguide/rft-prepare-data-open-weight.html` (2026-11-03 확인)
29. AIF-C01 공식 시험 가이드 · 콘텐츠 도메인 3 (한국어) — `docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-practitioner-01/ai-practitioner-01-domain3.html` (2026-11-03 확인)
