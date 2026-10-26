---
examGuideTaskId: mla-t2-2
certCode: MLA-C01
domain: 2
domainName: ML 모델 개발
domainWeightPct: 26
title: 모델 훈련·개선 (분산·조기 중지·정규화·AMT·파인튜닝·Model Registry)
coversTasks:
  - "2.2"
sources:
  - title: Distributed training in Amazon SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/distributed-training.html
  - title: Strategies for distributed training (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/distributed-training-strategies.html
  - title: Understand the hyperparameter tuning strategies available in Amazon SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-how-it-works.html
  - title: Best Practices for Hyperparameter Tuning (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-considerations.html
  - title: Managed Spot Training in Amazon SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html
  - title: Model Fit — Underfitting vs. Overfitting (Amazon Machine Learning 개발자 가이드, 레거시 서비스 문서)
    url: https://docs.aws.amazon.com/machine-learning/latest/dg/model-fit-underfitting-vs-overfitting.html
  - title: Foundation models and hyperparameters for fine-tuning (SageMaker JumpStart 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning.html
  - title: Customize your model to improve its performance for your use case (Amazon Bedrock 공식 문서)
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html
  - title: Model Registration Deployment with Model Registry (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 모델 훈련·개선 (분산·조기 중지·정규화·AMT·파인튜닝·Model Registry)

> **커버하는 공식 Task** — MLA-C01 · 도메인 2 「ML 모델 개발」(26%) · **Task 2.2 모델 훈련 및 개선** (`mla-t2-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 2.1이 "무엇으로 모델을 얻을까"였다면 2.2는 **"그 훈련을 어떻게 빠르게, 싸게, 더 좋게 만드는가"** — 도메인 2에서 Skill 항목이 가장 많은 Task입니다(지식 8 + 기술 9).

---

## ✅ 학습 목표 체크리스트

- [ ] 에포크·반복(스텝)·글로벌 배치 크기·학습률의 관계를 식으로 설명할 수 있다
- [ ] **조기 중지의 세 층위**(알고리즘 내부 · AMT 튜닝 작업 · Hyperband 내부)를 구분하고 각 전제를 안다
- [ ] 데이터 병렬과 모델 병렬을 **"모델이 한 GPU에 들어가는가"**로 가르고(메모리 부족 시 시도 순서 포함), 스팟·체크포인트·웜 풀·혼합 정밀도가 각각 **어떤 비용·지연**을 줄이는지 구분한다
- [ ] 모델 크기를 바꾸는 요인과 양자화·가지치기·증류·특성 선택의 차이를 안다
- [ ] 과적합·과소적합 **증상 → 처방**을 정규화·하이퍼파라미터로 연결하고, L1·L2와 **뉴런** 드롭아웃 vs **트리** 드롭아웃(XGBoost DART)을 가른다
- [ ] AMT의 네 전략을 **병렬성과 알고리즘 전제**로 고르고, 로그 스케일이 필요한 범위를 판단한다
- [ ] 웜 스타트 두 유형과 외부 모델 반입 세 경로, 도메인 적응 vs 명령 기반 미세조정의 **데이터 형식**을 구분한다
- [ ] Model Registry의 Model Group·버전·승인 상태가 CI/CD와 어떻게 연결되는지 안다

> **이 문서가 다루는 것** — 1) 훈련 프로세스의 요소 · 2) 조기 중지 3층위 · 3) 분산 훈련 · 4) 시간·비용 단축 · 5) 모델 크기 · 6) 정규화·과적합·치명적 망각 · 7) 성능 개선과 하이퍼파라미터 · 8) AMT 전략·범위·지표 · 9) AMT 웜 스타트·할당량·Autotune · 10) 내장 알고리즘과 스크립트 모드 · 11) 외부 모델 반입 · 12) 파인튜닝 · 13) 앙상블·부스팅·배깅·스태킹 · 14) Model Registry

---

## 🎯 왜 중요한가

훈련은 "돌아간다/안 돌아간다"가 아니라 **시간과 돈과 품질의 삼각형**입니다. 같은 모델을 같은 데이터로 학습시켜도 입력 모드·인스턴스·분산 전략·조기 중지 설정에 따라 비용이 몇 배 차이 납니다.

시험이 이 Task에서 묻는 것은 **증상 → 처방**입니다. "훈련이 느리다", "GPU 메모리가 부족하다", "훈련 정확도는 높은데 테스트가 낮다", "미세조정 후 일반 능력이 떨어졌다". 각 증상마다 손댈 층이 정해져 있고, 엉뚱한 층을 고르는 선택지가 함께 나옵니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **반복 수 = (샘플 수 ÷ 글로벌 배치 크기) × 에포크 수.** 글로벌 배치 = 복제본 수 × 복제본별 배치 크기
- **"훈련이 느리다"는 원인을 먼저 나눈다**: 데이터 로딩 → 입력 모드 · 인스턴스 기동 → **웜 풀** · 연산 → 혼합 정밀도·인스턴스 · 중단 → **체크포인트** · 돈 → **스팟**(최대 90%)
- **"GPU 메모리 부족"이면 배치 크기부터 줄이고**, 1로 줄여도 안 되면 **모델 병렬**. 모델이 애초에 한 GPU에 안 들어가면 처음부터 모델 병렬
- **조기 중지 3층위**: "다른 작업들의 중앙값과 비교" → **AMT** · "내 검증 지표가 patience 동안 개선 없음" → **알고리즘 내부** · "자원 재할당" → **Hyperband**. ⚠️ Hyperband를 쓰면 **AMT 조기 중지는 OFF**
- **과적합은 유연성을 줄이고 과소적합은 늘린다.** "**훈련 데이터에서도 나쁘다**"가 과소적합의 결정적 단서
- **L1은 특성을 지우고(희소) L2는 모두 줄인다.** ⚠️ **뉴런** 드롭아웃은 신경망 기법이지만 **XGBoost DART의 `rate_drop`은 트리**를 떨어뜨린다 — 보기에 드롭아웃이 보이면 대상을 확인
- **AMT 전략은 병렬성과 전제로**: 대규모 병렬 → **Random** · 이전 결과 활용 → **Bayesian** · 범주형 전수 → **Grid** · 큰 반복형 → **Hyperband**
- **학습률처럼 여러 자릿수 범위는 로그 스케일.** 로그 스케일은 **0보다 큰 범위만** 가능
- **미세조정 유형은 데이터 형식이 단서**: CSV·TXT 묶음 → **도메인 적응** · 프롬프트-응답 JSON Lines → **명령 기반**. 미세조정 뒤 일반 능력이 떨어지면 **치명적 망각**(완화: PEFT·데이터 믹싱·과거 데이터 재사용)
- **Model Registry는 승인 상태가 CI/CD 트리거**다. 스테이징 구성은 별도 체계

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **에포크(epoch)** | 전체 데이터셋을 한 번 통과하는 훈련 주기 |
| **반복(iteration)** | 글로벌 배치 크기의 미니 배치로 수행하는 순방향·역방향 패스 1회 |
| **글로벌 배치 크기** | 매 반복에서 클러스터의 GPU로 보내는 레코드 수 = 복제본 수 × 복제본별 배치 크기 |
| **학습률** | 계산된 오차에 대해 가중치를 얼마나 바꿀지에 영향을 주는 변수 |
| **하이퍼파라미터** | 훈련 과정 자체를 지배하는 구성 변수(훈련 중 학습되는 모델 파라미터와 다름) |
| **AMT** | SageMaker AI 자동 모델 튜닝. 지정한 범위로 훈련 작업을 여러 번 돌려 지표 기준 최적 모델을 찾는다 |
| **allreduce** | 데이터 병렬에서 각 워커의 그래디언트를 평균해 모든 워커에 공유하는 동기화 단계 |
| **PEFT** | 파라미터 효율 미세조정. LoRA·어댑터처럼 일부 파라미터만 갱신한다 |
| **Model Group** | Model Registry에서 같은 문제를 푸는 모델 버전들을 담는 묶음 |

---

## 📖 핵심 개념

### 1) 훈련 프로세스의 요소 {#training-elements}

| 요소 | 정의 | 관계·주의 |
|---|---|---|
| 에포크 | 전체 데이터셋 한 번 통과 | 한 에포크 안에 여러 반복이 들어간다. 에포크 수는 모델·사용 사례마다 다르다 |
| 반복 | 미니 배치 단위 순방향·역방향 1회 | **반복 수 = (샘플 수 ÷ 글로벌 배치 크기) × 에포크 수**. 샘플 5,000개·배치 500이면 에포크당 10회 |
| 글로벌 배치 크기 | 한 반복에서 그래디언트를 계산하는 레코드 수 | 데이터 병렬이면 복제본 수 × 복제본별 배치 크기 |
| 마이크로 배치 | 미니 배치의 부분집합 | 모델 병렬 라이브러리가 파이프라인에 하나씩 투입 |
| 학습률 | 가중치 변경 폭에 영향 | 수렴 능력·수렴 속도·최적성에 중요 |

- ⚠️ 영문 가이드는 **steps**를 쓰지만 SageMaker 문서가 정의하는 용어는 **iteration**입니다. 두 단어를 같다고 명시한 문장은 없으므로 이 문서는 "가중치를 갱신하는 1회"로만 설명합니다. Bedrock 이미지 모델은 `stepCount`를 "각 배치에 모델이 노출되는 횟수"로 따로 정의합니다.
- **같은 개념, 다른 파라미터 이름** — Linear Learner는 `epochs`·`mini_batch_size`·`learning_rate`, XGBoost는 에포크 대신 **`num_round`**(부스팅 라운드)와 `eta`(보폭 축소), JumpStart FM은 `epoch`·`per_device_train_batch_size`, Bedrock은 `epochCount`·`batchSize`·`learningRate`(+`learningRateWarmupSteps`)입니다.
- **배치 크기와 학습률의 연동**: 분산에서 노드를 늘리면 배치 크기를 비례해 늘리고, 수렴 속도를 위해 학습률도 함께 올립니다(**선형 스케일링 규칙** — 미니 배치가 k배면 학습률도 k배). 배치 정규화가 있는 모델은 GPU당 배치가 너무 작아지면 단일 노드에서 본 수렴이 깨질 수 있습니다.
- **학습률의 양 끝**: 0.01은 조정 폭이 작아 수렴이 오래 걸릴 수 있고, 0.1은 커서 오버슈트할 수 있습니다. 급격한 증가를 막으려고 학습률을 점진적으로 올리는 **워밍업**을 씁니다.
- **에포크와 비용**: Bedrock 훈련 비용은 처리 토큰 수(훈련 말뭉치 × 에포크)에 비례합니다. 큰 데이터셋은 더 적은 에포크로, 작은 데이터셋은 더 많은 에포크로 수렴합니다.

> 🧠 **원리** — 미니 배치 SGD는 배치 안의 각 레코드로 그래디언트를 구해 **평균**으로 갱신 방향을 정합니다. 레코드 사이 통신이 최종 평균뿐이라 병렬화에 적합하지만, 그 평균을 모든 워커와 주고받는 allreduce가 클러스터가 커질수록 오버헤드가 됩니다.

### 2) 조기 중지 — 세 층위를 구분한다 {#early-stopping}

"조기 중지"는 서로 다른 세 장치를 가리킵니다. 보기에서 이름이 같아 헷갈리므로 **무엇과 비교해 멈추는가**로 가릅니다.

| 층위 | 설정 | 동작 | 전제·제약 |
|---|---|---|---|
| ① 알고리즘 내부 | XGBoost `early_stopping_rounds` · Linear Learner `early_stopping_patience`·`early_stopping_tolerance` · Image Classification `early_stopping`(기본 False) · Bedrock `earlyStoppingThreshold`·`earlyStoppingPatience` | **자기 자신의 검증 지표 추이**가 patience 동안 개선되지 않으면 그 훈련 작업을 종료 | 파라미터 이름이 알고리즘·모델마다 다르다. Linear Learner는 검증 데이터가 없으면 훈련 데이터의 손실로 평가 |
| ② AMT 튜닝 작업 | `TrainingJobEarlyStoppingType`=`AUTO`(**API 기본값은 OFF**) | 각 에포크 후 목표 지표를 **이전 훈련 작업들의 같은 에포크까지 이동 평균의 중앙값**과 비교해 더 나쁘면 중단 | **에포크마다 목표 지표를 내는 알고리즘만** 가능. 사용자 코드는 에포크별 지표를 로그에 기록해야 한다. **다중 알고리즘 튜닝에서는 사용 불가** |
| ③ Hyperband 내부 | `Strategy`=`Hyperband` | 중간·최종 결과로 자원을 재할당하고 부진한 구성을 자동 중지 | `TrainingJobEarlyStoppingType`은 **OFF**여야 한다. 반복형 알고리즘에만 |

- 효과는 **컴퓨트 시간 절감 + 과적합 회피**입니다. 다만 멈추는 시점을 잘못 잡으면 여전히 부정확할 수 있습니다.
- ⚠️ 조기 중지를 지원하는 내장 알고리즘 목록은 문서 스스로 2018-12-13 기준이라고 밝힙니다. 목록을 외우는 대신 **"에포크별 목표 지표를 발행하는가"**라는 조건으로 판단합니다.
- 참고로 Debugger 규칙 기반 중지도 있었지만 SageMaker Debugger는 **신규 고객 중단**입니다(진단 상세는 Task 2.3).

### 3) 분산 훈련 — 데이터 병렬 vs 모델 병렬 {#distributed}

| 구분 | 데이터 병렬(SMDDP) | 모델 병렬(SMP v2) |
|---|---|---|
| 하는 일 | 데이터를 여러 GPU로 나누고 **각 GPU가 모델 복제본**을 가진 채 서로 다른 배치를 처리한 뒤 갱신을 동기화 | **모델 자체를** 여러 GPU로 분할하고 데이터가 그 사이를 흐름 |
| 언제 | 큰 데이터셋 + **모델이 단일 GPU에 들어갈 때** | 모델이 단일 디바이스에 안 맞을 때, 또는 모델 크기 때문에 작고 비효율적인 배치를 강요받을 때 |
| 핵심 제약 | 모델과 레코드 한 개가 디바이스 하나에 들어가야 함. **allreduce 오버헤드가 클러스터 확장에 따라 증가**. TensorFlow 지원 중단 | v1은 보관되고 현행은 v2(PyTorch FSDP API와 정렬). 분할 방식·실행 일정에 따라 GPU 활용도가 크게 달라짐 |
| 구성 요소 | `AllReduce`·`AllGather`를 AWS 네트워크·인스턴스 토폴로지에 맞게 최적화 | 하이브리드 샤딩 데이터 병렬·전문가 병렬(MoE)·텐서 병렬·활성화 체크포인트·혼합 정밀도 |
| 메모리 산정 | — | 혼합 정밀도 + Adam이면 **파라미터당 약 20바이트** → 100억 파라미터는 최소 200 GB. 풋프린트는 파라미터 수에 비례 |

**메모리가 부족할 때의 시도 순서**(문서 권고) — ① 큰 데이터셋이면 **데이터 병렬부터** ② 메모리가 부족하면 모델 하이퍼파라미터 변경 → 배치 크기 축소(1로 줄여도 부족하면 모델 병렬) → 그래디언트 압축·혼합 정밀도 → 입력 크기 축소(시퀀스 길이·이미지 해상도) ③ 그래도 안 되면 모델 병렬 또는 하이브리드 ④ 모델이 애초에 단일 디바이스에 안 맞으면 **처음부터 모델 병렬**.

- ⚠️ **인스턴스를 늘려도 항상 빨라지지 않습니다.** 클러스터가 커지면 노드 간 통신이 오버헤드가 되고, 단순한 모델은 큰 인스턴스에서 추가 컴퓨트를 못 쓰거나 GPU 통신 오버헤드로 더 느려질 수 있습니다.
- SMDDP는 **다중 노드**에서 효과가 큽니다. 훈련 중 CPU 라이브러리로 전처리하면 AllReduce도 CPU를 쓰므로 CPU 병목이 생길 수 있어, 전처리를 훈련 전에 끝내거나 GPU로 옮기라고 권합니다. 다중 노드에는 **FSx for Lustre를 권장**합니다.
- **샤딩 데이터 병렬**(모델 상태를 데이터 병렬 그룹 안에서 쪼개는 메모리 절감 기법)은 SMP v2가 제공하며, **하이브리드**는 모델 병렬 + 데이터 병렬 조합입니다.
- 내장 알고리즘은 자체적으로 병렬화를 제공합니다. XGBoost의 CPU 분산 훈련은 입력을 인스턴스 수 이상의 파일로 나누고 `ShardedByS3Key`를 쓰며, **GPU 분산 훈련은 Dask를 쓰고 CSV·Parquet만 지원하며 Pipe 모드에서는 실패**합니다.
- ⚠️ SMDDP 지원 인스턴스 목록은 문서 사이에 서술 범위가 달라 암기 대상이 아닙니다(지원 표는 `ml.p3dn.24xlarge`·`ml.p4d.24xlarge`·`ml.p4de.24xlarge`를 열거합니다).

> 🧠 **원리** — 데이터 병렬은 "모델은 같고 데이터만 나눠" 그래디언트를 평균해 같은 가중치를 유지합니다. 그래서 모델 + 레코드 1개가 한 디바이스에 들어가야 하고 워커가 늘수록 통신 비용이 커집니다. 모델 병렬은 "데이터는 같고 모델을 나눠" 메모리 한계를 넘지만, 순진하게 층을 나누면 한 시점에 한 GPU만 계산하므로 파이프라인 일정으로 보완합니다.

### 4) 시간·비용 단축 — 어떤 지연을 줄이는가 {#speedup}

| 수단 | 줄이는 것 | 핵심 설정·제약 |
|---|---|---|
| 입력 모드(File·FastFile·Pipe·FSx·EFS) | 데이터 로딩·시작 지연 | **정본은 Task 1.1 문서 3) 입력 모드**입니다. 훈련 관점의 추가 사실: File 모드는 **다운로드 시간도 청구 시간에 포함**되고 SageMaker local mode와 호환됩니다 |
| 관리형 스팟 훈련 | 비용(최대 90%) | `EnableManagedSpotTraining`=True + **대기 시간 상한**(`MaxWaitTimeInSeconds`)을 실행 시간 상한보다 크게 지정. 짧게 끝나지 않으면 체크포인트 권장. 체크포인트 없는 내장·Marketplace 알고리즘은 대기 상한 3,600초. AMT도 스팟을 쓸 수 있음 |
| 체크포인트 | 중단 후 처음부터 다시 하는 낭비 | `/opt/ml/checkpoints` ↔ S3 자동 동기화. AWS DLC와 일부 내장 알고리즘은 스크립트 변경 없이 지원. **모델 아티팩트 경로(`/opt/ml/model`)와 다릅니다** |
| 관리형 웜 풀 | 반복 실험의 인스턴스 기동 지연 | `KeepAlivePeriodInSeconds`로 인스턴스를 유지. ⚠️ AMT **웜 스타트**와 이름만 비슷합니다 |
| 혼합 정밀도 | 속도 + 메모리 | Tensor Core 하드웨어에서 속도 향상·메모리 감소. SMP v2는 FP16/BF16과 P5의 FP8 지원. ⚠️ 훈련용 혼합 정밀도는 **추론용 양자화와 다릅니다** |
| 인스턴스 선택 | 비용·시간 | 알고리즘이 compute·memory·I/O 중 무엇에 묶이는지 먼저 봅니다. **XGBoost는 memory-bound**라 CPU 훈련에 범용(M5)이 컴퓨트 최적화보다 적합하고, GPU는 단가가 높아도 더 빨라 비용 효율적일 수 있습니다. 작은 인스턴스에서 시작해 필요할 때만 키웁니다 |

- ⚠️ **SageMaker Profiler는 2027-06-30 지원 종료 예고**이며 대체는 프레임워크 프로파일러 + TensorBoard, 시스템 자원은 CloudWatch입니다. **Debugger는 신규 고객 중단**, **Training Compiler는 신규 릴리스·버전이 없습니다**(기존 DLC로는 계속 쓸 수 있으나 패치를 받지 못함).
- 스팟 절감 폭은 "최대" 표기이고 절감률은 **청구 시간 대비**로 계산됩니다.

> 🧠 **원리** — 스팟 훈련이 안전한 이유는 체크포인트 때문입니다. 중단되면 SageMaker가 로컬 체크포인트를 S3로 복사해 두었다가 재시작 시 다시 로컬로 내려 **마지막 체크포인트에서 이어갑니다.**

### 5) 모델 크기 — 무엇이 키우고 무엇이 줄이는가 {#model-size}

**크기를 바꾸는 요인**(문서가 직접 말하는 것만)

| 요인 | 문서의 서술 |
|---|---|
| 파라미터 수 | 메모리 풋프린트는 파라미터 수에 비례. 혼합 정밀도 + Adam 훈련은 파라미터당 약 20바이트 |
| 수치 정밀도 | 70억 파라미터 기준 FP32 약 28 GB → FP16/BF16 약 14 GB → FP8 약 7 GB → 4비트 약 3.5 GB |
| 특성 수 | 속성·파생 특성이 많으면 저장되는 패턴이 많아진다. 다만 **입력 데이터가 커도 모델이 반드시 커지는 것은 아닙니다**(모델은 패턴을 저장) — ⚠️ 레거시 서비스 문서 근거 |
| 저장되는 체크포인트 수 | Image Classification `checkpoint_frequency`로 저장된 체크포인트가 `model.tar.gz`에 포함돼 **파일 크기가 체크포인트 수에 비례** |

**축소 기법** — 가이드 SK8의 "데이터 유형 변경·정리·특성 선택 업데이트·압축"

| 가이드 용어 | 영문 | 정의 | 트레이드오프 |
|---|---|---|---|
| 데이터 유형 변경 | 양자화 | 가중치·활성화를 나타내는 수의 **정밀도를 낮춤** | 크기 감소·추론 가속. 품질 저하 가능성을 보정·혼합 정밀도로 완화. 사전 양자화된 체크포인트를 선호 |
| 정리 | 가지치기(pruning) | 모델에서 **중복·불필요한 파라미터 제거** | 기여도가 낮은 가중치를 지워 더 작고 효율적인 모델 |
| 압축 | compression | 중복 정보 제거 또는 정밀도 감소의 **총칭** | 독립 또는 조합 적용 |
| (증류) | distillation | 작은 모델이 **큰 모델의 성능을 모방**하도록 훈련 | 비용·지연 감소. Bedrock 모델 증류는 교사 → 학생 |
| 특성 선택 업데이트 | feature selection | 가장 중요한 특성만 남기고 무관한 특성 제거 | 모델 복잡도·과적합 감소. PCA는 차원을 줄이는 내장 알고리즘 |

⚠️ **용어 충돌**: 한국어 가이드의 "정리"는 영문 pruning이며 **가중치·파라미터 제거** 맥락입니다. 그런데 AWS "What is Overfitting?" 페이지는 **특성 선택**을 pruning이라고도 부릅니다. 보기에 pruning이 나오면 **무엇을 제거하는가(가중치 vs 특성)**를 지문에서 확인해야 합니다.

### 6) 정규화와 과적합·과소적합·치명적 망각 {#regularization}

정규화의 목적은 모델이 훈련 예제를 일반화하지 않고 **암기(과적합)하지 않도록 극단적인 가중치에 패널티를 주는 것**입니다.

| 기법 | 효과 | 파라미터 | 헷갈리는 것 |
|---|---|---|---|
| L1 | **작은 가중치를 0으로 밀어** 사용 특성 수를 줄임 → 희소 모델·노이즈 감소 | Linear Learner `l1` · XGBoost `alpha` | 가중치를 0으로 만들어 **특성 선택 효과**가 남는다 |
| L2 | 전체 가중치를 **고르게 작게** 만들고 특성 간 상관이 높을 때 가중치를 안정화 | Linear Learner `wd`(weight decay) · XGBoost `lambda` | Linear Learner 문서는 weight decay와 L2를 동일시한다. 단 Image Classification `weight_decay`는 sgd·nag에만 적용 |
| 드롭아웃 | **뉴런 드롭아웃**은 훈련 중 무작위 뉴런을 비활성화해 특정 뉴런에 의존하지 않게 함 — 공식 정의가 "인공 신경망 전용 기법" | 신경망: JumpStart LoRA `lora_dropout` | 선형 모델(Linear Learner)에는 해당 없음 |
| 드롭아웃(트리) | **드롭아웃 개념은 신경망 밖에서도 쓰입니다** — XGBoost DART의 `rate_drop`은 뉴런이 아니라 **직전까지 만든 트리의 일부를 버리는** 비율 | XGBoost `rate_drop`(`one_drop`·`skip_drop`과 한 묶음) | 뉴런 드롭아웃과 **대상이 다르다**. 보기에 드롭아웃이 나오면 **무엇을 떨어뜨리는지** 확인 |
| 조기 중지 | 모델이 노이즈를 학습하기 전에 훈련을 멈춤 | → 2) | 시점을 잘못 잡으면 여전히 부정확 |
| 데이터 증강 | 샘플을 조금씩 변형해 과도하게 특정한 특성을 배우지 않게 함 | Image Classification `augmentation_type` | |
| 앙상블 | 약한 학습자를 결합해 더 정확한 결과 | → 13) | |

⚠️ L1·L2의 효과를 가장 또렷하게 설명한 공식 문장은 **레거시 Amazon Machine Learning 문서**(서비스 신규 사용자 중단)에 있습니다. 현행 SageMaker 문서는 파라미터 설명만 둡니다. 개념 근거로만 쓰고 레거시 서비스 자체를 답으로 고르지는 않습니다.

**증상 → 처방**

| 진단 | 지표 패턴 | 처방 |
|---|---|---|
| **과적합**(높은 분산) | 훈련 성능은 좋은데 평가·테스트 성능이 나쁨. 훈련·테스트 정확도 격차가 큼 | **모델 유연성을 줄인다** — 정규화 증가, 특성 선택, 조기 중지, 드롭아웃, 데이터 증강, 앙상블, 데이터 양 확대. XGBoost는 `max_depth`↓ · `eta`↓ · `subsample`<1 · `gamma`↑ · `min_child_weight`↑ · `alpha`·`lambda`↑ |
| **과소적합**(높은 편향) | **훈련 데이터에서도** 성능이 나쁨. 모델이 너무 단순하거나 특성이 부족하거나 충분히 훈련되지 않음 | **모델 유연성을 늘린다** — 도메인 특성·특성 곱 추가, 특성 처리 변경, **정규화 감소**, 에포크(패스) 증가 |
| 데이터 부족 | 훈련·평가 정확도가 모두 낮음 | 훈련 예제 수와 패스 수를 늘림 |
| 검증 방법 | — | 별도 데이터로 테스트하거나 K-겹 교차 검증. AMT는 **훈련 지표 대신 검증 지표**로 튜닝 |

**치명적 망각(catastrophic forgetting)** — 좁은 도메인 데이터로 미세조정하면 사전 훈련에서 얻은 **일반 능력을 덮어써** 도메인 밖 작업(지시 따르기·추론·폭넓은 지식) 성능이 떨어지는 현상입니다. ⚠️ 이 정의 문장은 **AWS 블로그**에서 확인한 것이고, 공식 문서에는 PEFT 설명 속 "치명적인 언어 능력 손실" 언급만 있습니다.

| 완화 방법 | 설명 |
|---|---|
| PEFT | LoRA·어댑터·프리픽스 튜닝처럼 **일부 파라미터만 갱신**. 단점은 전체 갱신 대비 성능이 낮을 수 있음. JumpStart는 `lora_r`·`lora_alpha`·`lora_dropout` 제공 |
| 데이터 믹싱 | 미세조정 중 사용자 데이터에 기반 모델 쪽 데이터를 섞어 일반 능력을 보존 |
| 이전 데이터 재사용 | 재훈련 때 과거 데이터를 일부 보관해 재사용 — 블로그 근거 |

> 🧠 **원리** — 복잡한 모델은 진짜 패턴뿐 아니라 우연한 아티팩트까지 학습해 새 데이터에 일반화하지 못합니다. 정규화는 극단적 가중치에 패널티를 줘 유연성을 낮춥니다. L1은 작은 가중치를 0으로 밀어 특성 수를 줄이고(희소), L2는 모든 가중치를 고르게 줄입니다.

### 7) 성능 개선 방법과 하이퍼파라미터의 영향 {#improve-performance}

| 개선 방법 | 문서가 말하는 내용 |
|---|---|
| 데이터 확대 | 반복 개선의 **첫 단계는 훈련 예제 수 증가**. 성능이 나쁠 때 하이퍼파라미터 조정 전에 데이터 양 부족부터 배제한다 |
| 증분 훈련 | 기존 모델 아티팩트 + 확장된 데이터셋으로 새 모델을 훈련 |
| 특성 처리 | 변수 추가와 더 나은 특성 처리. Autopilot이 분석·전처리·특성 선택을 자동화 |
| 하이퍼파라미터 튜닝 | 훈련 파라미터의 대안 값을 시도(→ 8·9) |
| 전이 학습·미세조정 | 사전 훈련 모델을 새 데이터셋으로 이어서 훈련 — 더 작은 데이터셋·더 짧은 시간(→ 12) |
| 앙상블 | 약한 학습자를 결합(→ 13) |
| 클래스 불균형 처리 | XGBoost `scale_pos_weight` · Linear Learner `positive_example_weight_mult`·`balance_multiclass_weights` |

**하이퍼파라미터의 영향** — ML Lens는 신경망의 핵심 하이퍼파라미터로 학습률·배치 크기·아키텍처 파라미터를, 트리 모델은 **트리 깊이·트리 수·리프당 최소 샘플**을 듭니다.

| 알고리즘 | 파라미터 | 문서가 말하는 효과 |
|---|---|---|
| XGBoost | `num_round` | 훈련 라운드 수(필수). AMT 문서가 성능 영향이 가장 큰 파라미터 중 하나로 꼽음 |
| XGBoost | `max_depth` | 키울수록 **모델이 복잡해지고 과적합 가능성이 커짐** |
| XGBoost | `eta` | 업데이트 보폭을 줄여 과적합을 막음(작을수록 보수적) |
| XGBoost | `gamma`·`min_child_weight` | 클수록 알고리즘이 **보수적** |
| XGBoost | `subsample`·`colsample_*` | 행·열을 샘플링해 트리를 키움 → 과적합 방지 |
| Image Classification | `num_layers` | 네트워크 층 수. **전이 학습이면 베이스 네트워크 아키텍처를 정의**하므로 권장 집합에서만 선택 |
| Image Classification | `use_pretrained_model` | 켜면 사전 훈련 모델을 로드하고 **최상단 FC 층만 재초기화**(전이 학습), 끄면 처음부터 훈련 |
| Linear Learner | `l1`·`wd`·`learning_rate`·`mini_batch_size` | AMT 권장 튜닝 대상. **AMT를 쓰면 내부 병렬 모델 튜닝이 꺼지고 `num_models`=1** |

⚠️ 트리 **수**가 정확히 어떤 방향으로 성능을 바꾸는지는 확인한 SageMaker 문서에 직접 서술이 없습니다. 문서가 말하는 것은 `num_round`가 영향이 큰 파라미터라는 점과, 검증 점수가 정체하면 `early_stopping_rounds`로 멈출 수 있다는 점까지입니다.

### 8) AMT ① — 전략·범위·스케일·지표 {#amt-strategies}

AMT는 지정한 알고리즘·하이퍼파라미터 범위로 훈련 작업을 여러 번 돌려 선택한 지표 기준 최적 모델을 찾습니다. 내장 알고리즘·사용자 지정 알고리즘·프레임워크 컨테이너에 모두 쓸 수 있고 관리형 스팟 훈련도 함께 쓸 수 있습니다.

| 전략 | 동작 | 병렬성 | 제약·선택 기준 |
|---|---|---|---|
| Grid | **범주형 값 조합을 모두** 시도 | 조합 수만큼 | **범주형만 지원**. 재현·투명성이 필요하거나 공간을 고르게 훑을 때 |
| Random | 매 작업마다 범위에서 무작위 조합, **이전 결과와 무관** | 가장 많은 병렬 | 최대 동시 작업을 써도 튜닝 성능이 변하지 않음 → 대규모 병렬에 유리 |
| Bayesian | 회귀로 다음 후보를 선택, 탐색·활용 절충 | **순차적 성격이라 대규모 확장에 약함** | 이전 결과를 활용해 점진적 개선. 짧은 훈련 작업에서 효율적 |
| Hyperband | 다중 충실도 — 중간·최종 결과로 에포크 재할당, 부진한 구성 자동 중지 | 많은 병렬로 확장 | **반복형 알고리즘만**. `TrainingJobEarlyStoppingType`은 OFF. 큰 작업에서 계산 시간 절감 |

**범위와 스케일** — 동적 범위는 `ParameterRanges`의 범주형·정수형·연속형으로 정의하고, 동시 탐색은 최대 30개, 정적 포함 총 100개입니다.

| 스케일 | 언제 | 제약 |
|---|---|---|
| `Auto` | 스케일을 모르거나 판단이 어려울 때(기본 가정은 선형) | — |
| `Linear` | 최저~최고 범위가 상대적으로 작을 때 | — |
| `Logarithmic` | 범위가 **여러 자릿수**에 걸칠 때(예: 학습률 0.0001~1.0) | 값이 **0보다 큰** 범위만 |
| `ReverseLogarithmic` | 1에 매우 가까운 작은 변화에 민감한 범위 | **연속형만**, 0 이상 1 미만 |

**목표 지표** — 내장 알고리즘은 지표가 이미 정의돼 자동 전달되고, 사용자 지정 알고리즘은 `MetricDefinitions`(이름 + 정규식)로 **로그에서 파싱**합니다. 과적합을 피하려면 훈련 지표보다 **검증 지표**로 튜닝하고, 분산 훈련에서는 **마지막으로 실행 중인 작업이 보고한 지표**가 쓰입니다. 여러 알고리즘을 한 튜닝 작업에서 비교할 수 있지만 **웜 스타트·조기 중지는 단일 알고리즘 튜닝에서만** 가능합니다.

> 🧠 **원리** — 선형 스케일로 0.0001~1.0을 균일하게 뽑으면 구간 길이 비율 때문에 대부분의 시도가 0.1~1.0에 몰려 작은 값 영역을 거의 못 봅니다. 로그 스케일은 **자릿수마다 균등하게** 뽑아 전체 범위를 고르게 탐색합니다.

### 9) AMT ② — 웜 스타트·할당량·Autotune {#amt-warmstart}

**웜 스타트**는 이전 튜닝 작업(들)을 출발점으로 새 튜닝 작업을 시작하며 Bayesian 또는 Random을 씁니다.

| 유형 | 새 작업이 쓰는 것 | 바꿀 수 있는 것 |
|---|---|---|
| `IDENTICAL_DATA_AND_ALGORITHM` | 부모와 **같은 입력 데이터·훈련 이미지** | 탐색 범위, 최대 훈련 작업 수, 튜닝 가능↔정적 전환(총수 동일). `OverallBestTrainingJob` 필드 제공 |
| `TRANSFER_LEARNING` | 입력 데이터·범위·작업 수·이미지 버전이 **부모와 달라도 됨** | 데이터셋·알고리즘 변경이 목표 지표에 크게 영향을 주면 웜 스타트의 유용성이 떨어질 수 있음 |

제약: 부모 **최대 5개**(모두 종료 상태), **목표 지표 동일**, 정적 + 튜닝 가능 하이퍼파라미터 총수 동일·타입 변경 불가, **비재귀**, 시작이 더 오래 걸림.

**할당량(기본값)** — 동시 튜닝 작업 100(상향 불가) · 동시 탐색 하이퍼파라미터 30(상향 불가) · 튜닝 작업당 병렬 훈련 작업 10(100까지 상향) · 튜닝 작업 최대 실행 시간 30일. ⚠️ **튜닝 작업당 훈련 작업 최대 수와 지표 수는 공식 문서 사이에 수치가 엇갈립니다**(한도 표와 웜 스타트 문서, 한도 표와 지표 문서). 암기 대상이 아니며 상향은 Support Center의 Service limit increase로 요청합니다.

**모범 사례** — ① 큰 작업은 Hyperband, 작은 작업은 Random·Bayesian ② 튜닝 하이퍼파라미터 수는 적게 ③ **범위는 알려진 부분집합으로 좁게**(모든 값을 덮는 범위는 계산 시간이 크고 일반화가 나빠질 수 있음) ④ 올바른 스케일 ⑤ 병렬 수는 의미 있는 추가 결과를 주는 최대치 ⑥ 시드(`RandomSeed`)로 재현.

**Autotune**은 범위·`ResourceLimits`·조기 중지·재시도·전략·수렴 감지의 값을 자동 추측합니다. `AutoParameters`에 이름과 예시 값을 주고 모드를 켜면 AMT가 적합 여부를 판단해 범위를 정합니다.

⚠️ 가이드 SK5 "자동화된 하이퍼파라미터 최적화 기능 통합"이 가리키는 기능은 **원문이 특정하지 않습니다.** 후보는 **AMT Autotune · Pipelines 튜닝 스텝 · Autopilot HPO 모드 · Canvas AutoML** 네 가지이며, 하나를 정답으로 단정하지 않습니다. 참고로 Autopilot HPO 모드는 100 MB 미만이면 Bayesian, 초과면 다중 충실도를 쓰고 기본 최대 100 trial입니다.

### 10) 구현 선택 — 내장 알고리즘과 스크립트 모드 {#script-mode}

> 📍 노력·통제권 사다리의 **정본은 Task 2.1 문서 1) 선택 사다리**입니다. 여기서는 훈련 구현에 필요한 규약만 다룹니다.

| 구현 | 코드 | 사전 코딩된 알고리즘 | 서드파티 패키지 |
|---|---|---|---|
| 내장 알고리즘 | 불필요 | 있음 | 불가 |
| scikit-learn · Spark ML · XGBoost(오픈소스) | 필요 | 있음 | **PyPI만** |
| TensorFlow · PyTorch · MXNet ⚠️ · Chainer ⚠️ | 필요 | 없음(직접 구현) | **PyPI만** |
| 사용자 지정 이미지 | 필요 | 없음 | 모든 출처 |

(⚠️ MXNet·Chainer는 SageMaker Python SDK v3에서 미지원)

- 내장 알고리즘은 데이터·하이퍼파라미터·컴퓨트만 주면 실험을 시작할 수 있고, 해당 알고리즘은 다중 인스턴스 병렬화와 GPU 지원이 기본입니다. 문서는 **이미 사전 훈련된 모델이 있어도 같은 알고리즘의 내장 버전에 알려진 하이퍼파라미터를 넣는 편이 스크립트 모드로 이식하는 것보다 쉬울 수 있다**고 설명합니다.
- XGBoost는 **내장 알고리즘으로도, 프레임워크(오픈소스) 모드로도** 쓰이고, 이미지 URI 태그에는 `:latest`·`:1` 대신 지원 버전을 명시합니다.

**스크립트가 따르는 경로 규약**

| 변수·경로 | 의미 |
|---|---|
| `SM_MODEL_DIR` → `/opt/ml/model` | 최종 모델 아티팩트. 종료 시 `model.tar.gz`로 압축돼 S3 업로드 |
| `SM_CHANNEL_<채널명>` → `/opt/ml/input/data/<채널>` | 채널별 훈련 데이터. **채널은 작업당 최대 20개** |
| `/opt/ml/output/data` | 손실·정확도·가중치 같은 **부수 출력**. 모델 아티팩트와 다른 경로(환경 변수 이름 표기는 문서와 예제가 엇갈립니다) |
| `/opt/ml/checkpoints` | 체크포인트 ↔ S3 동기화 |
| `/opt/ml/code` | 훈련 스크립트·라이브러리가 복사되는 위치 |
| `SM_HPS` · `SM_HP_<NAME>` | 하이퍼파라미터 JSON 딕셔너리 / 개별 값 |

- Estimator에 넘긴 하이퍼파라미터는 스크립트의 **명령행 인자**로 전달됩니다. SDK 세대가 바뀌는 중이라 보기에 **v2 `Estimator`+`entry_point`**와 **v3 `ModelTrainer`+`SourceCode`** 표기가 함께 나올 수 있습니다.

### 11) 외부에서 만든 모델을 SageMaker로 {#byom}

| 경로 | 언제 | 핵심 |
|---|---|---|
| **BYOM**(훈련은 외부, 호스팅은 SageMaker) | 이미 훈련한 프레임워크 모델 | 프레임워크별 디렉터리 구조의 `model.tar.gz`(모델 파일 + `code/inference.py` + 필요 시 `requirements.txt`)를 S3에 올리고 사전 빌드 이미지로 모델·엔드포인트 생성. **심볼릭 링크·불필요한 파일 금지** |
| 사전 빌드 컨테이너 **확장** | 프레임워크는 맞지만 의존성이 더 필요 | 베이스 이미지에 의존성을 얹음 — 이미지를 처음부터 만들 필요 없음 |
| **BYOC** | 사용자 지정 프레임워크·알고리즘 | Docker 이미지를 ECR에 푸시. 호스팅 컨테이너는 **포트 8080에서 `/invocations`·`/ping`에 응답**해야 함 |

- 외부에서 만든 모델도 `create_model_package`의 `InferenceSpecification`(이미지 + `ModelDataUrl`)으로 **Model Registry에 등록**해 승인·계보 관리를 받을 수 있습니다.
- ⚠️ 이 경로는 "SageMaker로 통합"이고, Bedrock의 Custom Model Import는 다른 서비스 기능입니다.

> 🧠 **원리** — SageMaker 호스팅은 전부 컨테이너 기반이고 프레임워크 컨테이너는 `/opt/ml/model/`에 풀린 아티팩트와 `code/` 아래 추론 스크립트를 찾습니다. 그래서 **구조가 맞는 tar.gz만 만들면** 사전 빌드 컨테이너가 그대로 서빙하고, 구조·런타임을 맞출 수 없을 때만 확장하거나 BYOC로 갑니다.

### 12) 사전 훈련 모델 파인튜닝 {#fine-tuning}

파인튜닝은 사전 훈련 모델을 새 데이터셋으로 **처음부터가 아니라 이어서** 훈련하는 것으로, 전이 학습이라고도 하며 더 작은 데이터셋과 더 짧은 시간으로 정확한 모델을 만들 수 있습니다. **모델 가중치를 바꾸는** 맞춤화 방법입니다.

**SageMaker JumpStart의 두 유형** — 데이터 형식이 구분 기준입니다.

| 유형 | 훈련 데이터 | 특징 |
|---|---|---|
| **도메인 적응** 미세조정 | **CSV·JSON·TXT**, 한 폴더 안의 단일 파일. CSV/JSON은 `Text` 열(없으면 첫 열) 사용 | 업계 전문 용어 같은 도메인 언어에 적응. 검증 폴더는 선택이며 없으면 훈련 데이터의 일부를 분할 |
| **명령 기반** 미세조정 | **JSON Lines**의 프롬프트-응답 쌍 + 선택적 `template.json` | 일부 모델만 호환. `instruction_tuned` 하이퍼파라미터로 전환 |

- 공통 하이퍼파라미터: `epoch`·`learning_rate`·`per_device_train_batch_size`·`lora_r`·`lora_alpha`·`lora_dropout`·`int8_quantization`·`enable_fsdp` 등. 모델마다 지원 범위가 다릅니다.
- Studio에서는 **선택한 모델과 호환되는 인스턴스만** 고를 수 있고 일부 모델은 EULA 수락이 필요합니다. ⚠️ 지원 모델 목록은 변동되므로 암기 대상이 아닙니다.

**Amazon Bedrock 맞춤화**

| 방법 | 데이터 | 목적 |
|---|---|---|
| 지도 미세조정(SFT) | 레이블된 입력→출력 예제(JSONL) | 특정 작업 성능 개선 |
| 강화 미세조정(RFT) | 훈련 프롬프트 + Lambda 보상 함수 | 피드백 기반 정렬 개선 |
| 증류 | 사용 사례별 프롬프트 — 교사 응답을 생성해 학생 모델을 미세조정 | 큰 모델의 지식을 작고 빠르고 저렴한 모델로 이전 |
| 연속 사전 훈련(CPT) | **레이블 없는** 대용량 도메인 데이터 | 새 도메인 지식 학습 ⚠️ 개요 페이지는 이 항목을 열거하지 않고 콘솔 도움말·API는 포함합니다 |

- 데이터는 `.jsonl`(한 줄 = 한 레코드)이며 비대화형은 `prompt`+`completion`, 대화형은 Converse API 형식입니다. 훈련 데이터셋은 필수이고 **검증 데이터셋 지원 여부는 모델마다 다릅니다.**
- 비용은 **처리 토큰 수(말뭉치 토큰 × 에포크)** + 월별 모델 스토리지로 구성됩니다.
- ⚠️ 사용자 지정 모델 추론은 문서 사이 서술이 다릅니다 — 일반 경로는 **Provisioned Throughput 구매**이고, 온디맨드 배포는 **조건부 옵션**(지원 모델·리전·시점 제한)입니다.
- **선택 단서**: 훈련 인스턴스·하이퍼파라미터·VPC·암호화 키를 직접 구성하고 SageMaker로 배포해야 하면 JumpStart·SageMaker 훈련, 훈련 인프라를 관리하지 않고 데이터셋과 하이퍼파라미터만 주려면 Bedrock 맞춤화입니다.

### 13) 앙상블·부스팅·배깅·스태킹 {#ensembling}

| 기법 | 정의(공식 문서) | SageMaker 사례 |
|---|---|---|
| 앙상블 | 여러 알고리즘의 예측을 결합. 결과가 자주 부정확한 **약한 학습자들을 결합**해 더 정확한 결과를 얻음 | 과적합을 막는 전략 중 하나로 소개됨 |
| **부스팅** | 서로 다른 모델을 **차례로(순차)** 훈련해 최종 결과를 얻음 | XGBoost·LightGBM·CatBoost — 그래디언트 부스팅 트리 구현 |
| **배깅** | 모델들을 **병렬로** 훈련 | ⚠️ SageMaker 문서의 직접 사례는 확인되지 않았습니다 |
| 스태킹 | 여러 모델을 **다층으로 쌓아** 결합 | AutoGluon-Tabular, Autopilot Ensembling 모드(AutoGluon으로 베이스 모델을 훈련해 스태킹) |

- 구분: **Autopilot Ensembling**은 AutoGluon 기반 스태킹으로 모델을 결합하고, **HPO 모드**는 하이퍼파라미터를 튜닝해 최적 모델 하나를 찾습니다. Auto 모드는 데이터셋이 100 MB보다 크면 HPO, 아니면 Ensembling을 고릅니다.
- **AMT와 앙상블은 다른 층**입니다 — AMT는 한 알고리즘의 최적 구성을 찾고, 앙상블은 여러 모델의 예측을 결합합니다.

> 🧠 **원리** — 문서가 부스팅과 배깅을 가르는 기준은 **순차 대 병렬**입니다. 부스팅은 앞 모델의 결과를 받아 다음 모델을 훈련하고, 배깅은 모델들을 독립적으로 병렬 훈련해 결합합니다.

### 14) 모델 버전 관리 — Model Registry {#model-registry}

**구조** — **Model Group**은 특정 문제를 푸는 모델들을 추적하는 묶음이고, 훈련한 모델을 등록할 때마다 **새 모델 버전**으로 추가됩니다. 버전은 **1부터 시작해 증가**하고 반드시 Model Group에 속합니다. **Collection**은 Model Group을 카테고리로 묶는 선택 계층입니다. AWS Marketplace 모델 패키지는 버전 관리 엔터티가 아니며 Model Group과 연결되지 않습니다.

**승인 상태와 CI/CD**

| 상태 | 의미·동작 |
|---|---|
| `PendingManualApproval` | 버전 등록 시 설정하는 초기 상태(문서 예시) |
| `Approved` | 요구 성능을 충족. 이 상태로 바꾸면 **CI/CD 배포가 시작될 수 있음** |
| `Rejected` | 요구 성능에 못 미침 |

전이(제공 프로젝트 템플릿 기준): `PendingManualApproval`→`Approved`는 배포 시작, →`Rejected`는 동작 없음, `Rejected`→`Approved`는 배포 시작, `Approved`→`Rejected`는 **`Approved` 상태의 최신 버전을 배포하도록** CI/CD를 시작합니다. 상태는 Boto3 `update_model_package`의 `ModelApprovalStatus`, Studio 콘솔, 파이프라인 조건 단계로 바꿉니다.

- 등록은 Pipelines의 모델 등록 스텝(문서 표기는 `RegisterModel`, SDK 버전에 따라 `ModelStep`일 수 있음), Boto3 `create_model_package`, Studio 화면으로 합니다. 모델 버전에는 **모델 아티팩트가 필수이고 추론 코드는 선택**입니다.
- **교차 계정**: 다른 계정의 Model Group에 등록하려면 ECR·S3·KMS 리소스 정책이 필요하고 훈련 출력 암호화에 KMS 키를 써야 합니다. AWS RAM으로 모델 패키지 그룹을 공유할 수 있습니다.
- **스테이징 구성**(`ModelLifeCycle`)은 stage·stageStatus·stageDescription으로 구성하며 **CI/CD 트리거용 승인 상태와는 별도 체계**입니다. EventBridge로 승인·스테이지 변경 이벤트를 받습니다.
- "반복성·감사"와의 연결: 계보를 통한 추적성·재현성, 훈련 지표 같은 메타데이터 기록, 번호가 있는 버전, 승인·스테이징 이벤트 이력, 교차 계정 권한 분리.

---

## ✍️ 시험 포인트

- **"훈련이 느리다"**는 원인을 먼저 나눕니다 — 데이터 로딩이면 입력 모드, 인스턴스 기동이면 웜 풀, 연산이면 혼합 정밀도·인스턴스 선택, 중단이면 체크포인트, 돈이면 스팟입니다.
- **"GPU 메모리 부족"**이면 배치 크기부터 줄이고, 1로 줄여도 안 되면 모델 병렬입니다. 모델이 애초에 한 GPU에 안 들어가면 **처음부터 모델 병렬**입니다.
- 조기 중지 문항은 **층위**를 묻습니다. "다른 작업들의 중앙값과 비교"는 AMT, "내 검증 지표가 patience 동안 개선 안 됨"은 알고리즘 내부, "자원 재할당"은 Hyperband입니다. Hyperband를 쓰면 AMT 조기 중지는 OFF여야 합니다.
- **과적합은 유연성을 줄이고, 과소적합은 늘립니다.** 정규화 증가가 과적합 처방이면 정규화 감소가 과소적합 처방입니다. "훈련 데이터에서도 나쁘다"가 과소적합의 결정적 단서입니다.
- **L1은 특성을 지우고(희소), L2는 모두 줄입니다.** **뉴런** 드롭아웃은 신경망 기법이라 선형 모델 시나리오에서는 오답이지만, XGBoost DART의 `rate_drop`은 **트리**를 떨어뜨리는 다른 기법입니다 — 보기에 드롭아웃이 보이면 대상을 확인하세요.
- AMT 전략은 **병렬성과 전제**로 고릅니다 — 대규모 병렬은 Random, 이전 결과 활용은 Bayesian, 범주형 전수는 Grid, 큰 반복형 작업은 Hyperband입니다.
- 학습률처럼 **여러 자릿수에 걸친 범위**는 로그 스케일입니다. 로그 스케일은 0보다 큰 범위만 됩니다.
- 미세조정 유형은 **데이터 형식**이 단서입니다 — CSV·TXT 묶음은 도메인 적응, 프롬프트-응답 JSON Lines는 명령 기반입니다.
- 미세조정 뒤 **일반 능력이 떨어졌다**면 치명적 망각이고, 문서가 제시하는 완화는 PEFT·데이터 믹싱·과거 데이터 재사용입니다.
- Model Registry는 **승인 상태가 CI/CD 트리거**라는 점이 핵심입니다. 스테이징 구성은 별도 체계입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 데이터 병렬과 모델 병렬을 데이터 크기만으로 고른다 | 기준은 **모델이 단일 GPU에 들어가는가**다. 큰 데이터 + 들어가는 모델이면 데이터 병렬, 안 들어가면 모델 병렬 |
| 인스턴스를 늘리면 항상 빨라진다고 본다 | 노드 간 통신이 오버헤드가 되어 느려질 수 있고, 단순한 모델은 큰 인스턴스의 컴퓨트를 쓰지 못한다 |
| AMT 조기 중지를 켜면 어떤 알고리즘이든 동작한다고 본다 | **에포크마다 목표 지표를 내야** 한다. 또 다중 알고리즘 튜닝에서는 쓸 수 없다 |
| Hyperband와 AMT 조기 중지를 함께 켠다 | Hyperband는 자체적으로 부진한 구성을 중지하므로 `TrainingJobEarlyStoppingType`은 **OFF**여야 한다 |
| 과소적합에 정규화를 더 건다 | 과소적합은 모델이 너무 단순한 상태다. **정규화를 줄이고** 특성·에포크를 늘린다 |
| 선형 모델에 드롭아웃을 처방한다 | 뉴런 드롭아웃은 **신경망** 기법이다. 선형 모델은 L1·L2로 조절한다 |
| 드롭아웃이면 무조건 신경망이라고 본다 | XGBoost DART의 `rate_drop`은 **트리**를 버리는 드롭아웃이다. 떨어뜨리는 **대상**으로 가른다 |
| 웜 풀과 웜 스타트를 같은 것으로 본다 | **웜 풀은 인스턴스를 살려 두는 것**(기동 지연 감소), **웜 스타트는 이전 튜닝 결과를 출발점으로 쓰는 것**이다 |
| 체크포인트를 모델 아티팩트 경로에 쓴다 | 체크포인트는 `/opt/ml/checkpoints`, 최종 아티팩트는 `/opt/ml/model`이다 |
| 학습률 범위를 선형 스케일로 탐색한다 | 0.0001~1.0처럼 자릿수가 넓으면 시도가 큰 값에 몰린다 — **로그 스케일** |
| pruning을 항상 가중치 제거로 읽는다 | 가이드의 "정리"는 가중치·파라미터 제거지만, 일부 AWS 페이지는 **특성 선택**을 pruning이라 부른다. 지문에서 제거 대상을 확인한다 |
| 부스팅과 배깅을 섞는다 | 문서 기준은 **순차(부스팅) 대 병렬(배깅)**이다 |
| 스크립트 모드에서 PyPI 밖 패키지를 쓰려 한다 | 프레임워크 이미지에 추가할 수 있는 것은 PyPI 패키지까지다(→ Task 2.1 사다리) |

---

## 🧪 자가 점검

**Q1.** 샘플 100,000개를 글로벌 배치 1,000으로 10 에포크 훈련한다. 반복 수는 몇 회이고 그 식은? (→ 1) 훈련 요소)

<details><summary>정답 보기</summary>

**1,000회**입니다. 식은 **반복 수 = (샘플 수 ÷ 글로벌 배치 크기) × 에포크 수** = (100,000 ÷ 1,000) × 10 = 1,000. 에포크당 100회가 나오고 그것이 10번 반복됩니다. 데이터 병렬이면 글로벌 배치 크기는 **복제본 수 × 복제본별 배치 크기**로 결정됩니다.
</details>

**Q2.** 70억 파라미터 모델이 단일 GPU 메모리에 들어가지 않는다. 문서 권고 순서대로 무엇을 먼저 시도하고, 끝내 안 되면 무엇으로 가는가? (→ 3) 분산 훈련)

<details><summary>정답 보기</summary>

메모리 부족의 일반 순서는 **배치 크기를 줄이는 것부터**이고, 1로 줄여도 들어가지 않으면 **모델 병렬**로 갑니다. 다만 이 경우처럼 **모델이 애초에 한 GPU에 들어가지 않는다면 처음부터 모델 병렬**이 답입니다 — 데이터 병렬은 모델 복제본이 각 GPU에 들어간다는 전제가 있어 성립하지 않습니다.
</details>

**Q3.** AMT 튜닝에서 Hyperband를 쓰려 한다. 함께 끄거나 확인해야 하는 설정 두 가지는? (→ 2) 조기 중지, 8) AMT 전략)

<details><summary>정답 보기</summary>

① **AMT 조기 중지를 OFF**로 둬야 합니다 — Hyperband는 자체적으로 자원을 재할당하며 중지를 판단하므로 두 층위가 겹치면 안 됩니다. ② 알고리즘이 **반복마다 중간 목표 지표를 보고하는지** 확인해야 합니다 — Hyperband는 그 중간 지표로 자원을 재배분하므로 보고하지 않는 알고리즘에는 쓸 수 없습니다.
</details>

**Q4.** 훈련 정확도 0.98, 테스트 정확도 0.71이다. XGBoost 하이퍼파라미터로 쓸 수 있는 처방 세 가지는? (→ 6) 정규화, 7) 하이퍼파라미터)

<details><summary>정답 보기</summary>

전형적인 **과적합**이므로 모델의 유연성을 줄입니다 — ① **`max_depth` 감소**(트리를 얕게) ② **`eta` 감소 + 라운드 수 조절**(학습을 보수적으로) ③ **`subsample`·`colsample_bytree` 감소**로 샘플·특성을 무작위로 덜 쓰기. 그 밖에 `lambda`·`alpha`(L2·L1) 증가, `min_child_weight` 증가, `gamma` 증가도 같은 방향입니다. 과소적합이면 전부 반대로 움직입니다.
</details>

**Q5.** 사내 보고서 텍스트 파일 묶음으로 FM을 사내 용어에 적응시키려 한다. JumpStart의 어느 유형이고 데이터 형식은? (→ 12) 파인튜닝)

<details><summary>정답 보기</summary>

**도메인 적응 미세조정**입니다. 데이터 형식은 **CSV·TXT 같은 비정형 텍스트 묶음**으로, 레이블 쌍이 필요 없습니다. 반대로 **프롬프트-응답 JSON Lines**를 주는 경우가 **명령 기반 미세조정**이므로, 데이터 형식만 봐도 유형이 갈립니다.
</details>

**Q6.** 미세조정 뒤 모델이 일반 상식 질문에 약해졌다. 현상 이름과 문서가 제시하는 완화 방법은? (→ 6) 치명적 망각)

<details><summary>정답 보기</summary>

**치명적 망각(catastrophic forgetting)**입니다. 특정 도메인에 맞추면서 이전에 학습한 일반 능력을 잃는 현상입니다. 문서가 제시하는 완화는 **PEFT**(가중치 일부만 갱신) · **데이터 믹싱**(도메인 데이터에 일반 데이터를 섞기) · **과거 데이터 재사용**입니다.
</details>

**Q7.** 모델 버전을 `Approved`로 바꾸면 무엇이 일어나고, 스테이징 구성과는 어떻게 다른가? (→ 14) Model Registry)

<details><summary>정답 보기</summary>

`Approved`로 바꾸면 **그 버전의 CI/CD 배포가 시작될 수 있습니다** — 승인 상태 전이 자체가 트리거입니다(파이프라인의 Condition 단계가 평가 후 자동으로 바꿀 수도 있습니다). 반면 **스테이징 구성**은 모델을 어떤 환경 단계로 올릴지 관리하는 **별도 체계**로, 승인 상태와 같은 축이 아닙니다. 전이가 어떤 배포를 시작시키는지는 `mla-t3-3` 10)이 정본입니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task의 변경**이며, C01 시험 범위 판단에는 쓰지 않습니다.

- **C02 대응 Task**: 2.2 「ML 및 AI 솔루션을 위한 모델을 학습, 미세 조정 및 사용자 지정합니다」
- **추가된 항목 2개**
  - `2.2.8` AI 솔루션에 **사용자 지정 기술**을 적용합니다(예: 작업별 프롬프트 엔지니어링, 미세 조정).
  - `2.2.9` **검색 구성 요소 및 임베딩 모델**을 최적화합니다.
- **삭제된 항목 2개** — C01에서만 묻는 내용이라 C02 대비 학습 비중을 낮출 수 있습니다.
  - 사용자 지정 데이터세트를 사용하여 **사전 훈련된 모델 미세 조정**(예: Amazon Bedrock, SageMaker JumpStart)
  - **모델 크기 축소**(예: 데이터 유형 변경, 정리, 특성 선택 업데이트, 압축)
- 읽는 법: 이 문서의 5) 모델 크기와 12) 파인튜닝은 **C01 고유 비중이 큰 절**입니다. C02에서는 그 무게가 프롬프트 엔지니어링과 검색·임베딩 최적화로 옮겨갑니다.

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- 분산 훈련: [Distributed training](https://docs.aws.amazon.com/sagemaker/latest/dg/distributed-training.html) · [Strategies for distributed training](https://docs.aws.amazon.com/sagemaker/latest/dg/distributed-training-strategies.html) · [SMDDP 소개](https://docs.aws.amazon.com/sagemaker/latest/dg/data-parallel-intro.html) · [SMDDP 구성 팁](https://docs.aws.amazon.com/sagemaker/latest/dg/data-parallel-config.html) · [SMDDP 지원 범위](https://docs.aws.amazon.com/sagemaker/latest/dg/distributed-data-parallel-support.html) · [SMP v2](https://docs.aws.amazon.com/sagemaker/latest/dg/model-parallel-v2.html) · [모델 병렬 개념](https://docs.aws.amazon.com/sagemaker/latest/dg/model-parallel-intro-v2.html) · [혼합 정밀도](https://docs.aws.amazon.com/sagemaker/latest/dg/model-parallel-core-features-v2-mixed-precision.html)
- 시간·비용: [관리형 스팟 훈련](https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html) · [StoppingCondition](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_StoppingCondition.html) · [체크포인트](https://docs.aws.amazon.com/sagemaker/latest/dg/model-checkpoints.html) · [관리형 웜 풀](https://docs.aws.amazon.com/sagemaker/latest/dg/train-warm-pools.html) · [훈련 데이터 접근 설정](https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html) · [환경 변수·경로](https://docs.aws.amazon.com/sagemaker/latest/dg/model-train-storage-env-var-summary.html) · [MLCOST04-BP01 인스턴스 크기](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp01.html) · [MLCOST04-BP07 분산 훈련](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp07.html)
- AMT: [자동 모델 튜닝](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning.html) · [튜닝 전략](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-how-it-works.html) · [범위 정의](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-define-ranges.html) · [조기 중지](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-early-stopping.html) · [웜 스타트](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-warm-start.html) · [리소스 한도](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-limits.html) · [모범 사례](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-considerations.html) · [지표 정의](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-define-metrics-variables.html) · [다중 알고리즘 HPO](https://docs.aws.amazon.com/sagemaker/latest/dg/multiple-algorithm-hpo.html)
- 알고리즘·하이퍼파라미터: [XGBoost](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost.html) · [XGBoost 하이퍼파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost_hyperparameters.html) · [XGBoost 튜닝](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost-tuning.html) · [Linear Learner 하이퍼파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/ll_hyperparameters.html) · [Image Classification 하이퍼파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/IC-Hyperparameter.html) · [AutoGluon-Tabular](https://docs.aws.amazon.com/sagemaker/latest/dg/autogluon-tabular.html) · [증분 훈련](https://docs.aws.amazon.com/sagemaker/latest/dg/incremental-training.html)
- 과적합·정규화: [Model Fit: Underfitting vs. Overfitting (레거시)](https://docs.aws.amazon.com/machine-learning/latest/dg/model-fit-underfitting-vs-overfitting.html) · [Training Parameters (레거시)](https://docs.aws.amazon.com/machine-learning/latest/dg/training-parameters.html) · [Improving Model Accuracy (레거시)](https://docs.aws.amazon.com/machine-learning/latest/dg/improving-model-accuracy.html) · [What Is Overfitting?](https://aws.amazon.com/what-is/overfitting/)
- 모델 크기: [GENSUS03-BP01 (Generative AI Lens)](https://docs.aws.amazon.com/wellarchitected/latest/generative-ai-lens/gensus03-bp01.html) · [모델 최적화 기법 (Prescriptive Guidance)](https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-inference-architecture-and-best-practices-on-aws/model-optimization.html) · [SageMaker Neo](https://docs.aws.amazon.com/sagemaker/latest/dg/neo.html)
- 구현·통합: [Types of Algorithms](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-choose.html) · [프레임워크·언어](https://docs.aws.amazon.com/sagemaker/latest/dg/frameworks.html) · [Model Hosting FAQs](https://docs.aws.amazon.com/sagemaker/latest/dg/hosting-faqs.html) · [커스텀 Docker 컨테이너](https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers-adapt-your-own.html) · [MXNet](https://docs.aws.amazon.com/sagemaker/latest/dg/mxnet.html) · [Chainer](https://docs.aws.amazon.com/sagemaker/latest/dg/chainer.html)
- 파인튜닝: [JumpStart 미세조정 하이퍼파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning.html) · [도메인 적응](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-domain-adaptation.html) · [명령 기반](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-fine-tuning-instruction-based.html) · [Studio에서 미세조정](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-use-studio-updated-fine-tune.html) · [Bedrock 모델 맞춤화](https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html) · [Bedrock 하이퍼파라미터](https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models-hp.html) · [Bedrock 데이터 준비](https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prepare.html) · [사용자 지정 모델 추론](https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html) · [PEFT (Prescriptive Guidance)](https://docs.aws.amazon.com/prescriptive-guidance/latest/generative-ai-nlp-healthcare/fine-tuning.html)
- AutoML: [Autopilot](https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-automate-model-development.html) · [Autopilot 훈련 모드](https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-model-support-validation.html) · [MLCOST04-BP05 AutoML](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp05.html) · [MLCOST04-BP11 HPO](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp11.html)
- Model Registry: [Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html) · [모델·버전·그룹](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-models.html) · [승인 상태](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-approve.html) · [버전 등록](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-version.html) · [교차 계정 공유](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-ram.html) · [스테이징 구성](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-staging-construct.html)
- 상태 공지: [Profiler 지원 종료](https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html) · [Debugger 신규 중단](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-availability-change.html) · [Training Compiler](https://docs.aws.amazon.com/sagemaker/latest/dg/training-compiler.html) · [SageMaker AI 개명](https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/2-2.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
