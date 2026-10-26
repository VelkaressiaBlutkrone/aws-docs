---
examGuideTaskId: mla-t2-1
certCode: MLA-C01
domain: 2
domainName: ML 모델 개발
domainWeightPct: 26
title: 모델링 접근 방식 선택 (선택 사다리·내장 알고리즘·AI 서비스·해석 가능성·비용)
coversTasks:
  - "2.1"
sources:
  - title: Types of Algorithms (Amazon SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-choose.html
  - title: Built-in algorithms and pretrained models in Amazon SageMaker (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/algos.html
  - title: Parameters for Built-in Algorithms (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/common-info-all-im-models.html
  - title: Choosing an AWS machine learning service (AWS 의사결정 가이드)
    url: https://docs.aws.amazon.com/decision-guides/latest/decision-guides/ml-guide.html
  - title: Amazon Bedrock or Amazon SageMaker AI? (AWS 의사결정 가이드)
    url: https://docs.aws.amazon.com/decision-guides/latest/decision-guides/bedrock-or-sagemaker.html
  - title: MLPERF06-BP02 Evaluate model explainability (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp02.html
  - title: MLCOST02-BP01 Identify if machine learning is the right solution (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost02-bp01.html
  - title: AWS Lifecycle Changes (공식 문서)
    url: https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 모델링 접근 방식 선택 (선택 사다리·내장 알고리즘·AI 서비스·해석 가능성·비용)

> **커버하는 공식 Task** — MLA-C01 · 도메인 2 「ML 모델 개발」(26%) · **Task 2.1 모델링 접근 방식 선택** (`mla-t2-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 1이 "데이터를 어떻게 준비하는가"였다면, 2.1은 **"그 데이터로 모델을 어디서 얻을 것인가"** — 직접 학습할지, 사전 구축 서비스를 부를지, 파운데이션 모델에 맡길지를 정하는 분기점입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] AI 서비스 → 파운데이션 모델 → 내장 알고리즘 → 스크립트 모드 → 커스텀 이미지의 **노력·통제권 사다리**를 순서대로 말할 수 있다
- [ ] "ML이 이 문제에 맞는가"를 **규칙 가능성·데이터·복잡도·비용·설명 요구** 다섯 축으로 판단한다
- [ ] 지도·비지도·강화 학습과 분류·회귀·군집·차원 축소·이상 탐지·토픽 모델링을 **데이터 조건**으로 가른다
- [ ] 문제 유형과 데이터 형태에서 내장 알고리즘을 고르고, **하드웨어 제약**(CPU 전용·GPU 전용·단일 인스턴스)을 함께 본다
- [ ] 혼동 짝(LDA/NTM · RCF/IP Insights · 이미지 3종 · Linear Learner/FM)을 출력 단위와 입력 성격으로 구분한다
- [ ] 설명 의무가 있을 때 **내재적 해석 모델 우선**, 성능이 필요하면 복잡 모델 + 사후 설명이라는 권고 순서를 안다
- [ ] Translate·Transcribe·Rekognition·Textract·Comprehend 등 AI 서비스를 **입력의 형태**로 구분한다
- [ ] JumpStart와 Bedrock을 통제권·실행 환경·과금으로 가르고, 맞춤화는 프롬프트 → RAG → 미세조정 순으로 올린다
- [ ] 수명 주기(Maintenance·Sunset)를 알고, 신규 고객이 쓸 수 없는 서비스가 보기에 섞여 있음을 안다

---

## 🎯 왜 중요한가

이 Task는 알고리즘 지식을 묻는 것처럼 보이지만, 실제로 묻는 것은 **"얼마나 만들 것인가"**입니다. 같은 번역 문제를 Amazon Translate 한 번 호출로 끝낼 수도 있고, Sequence-to-Sequence를 GPU 인스턴스에서 학습시킬 수도 있습니다. 둘 다 "맞는" 답이지만 시나리오가 "ML 전문 인력이 없고 빠르게 출시해야 한다"고 말했다면 정답은 하나입니다.

그래서 시험 문항은 대개 **제약을 먼저 깔고** 선택을 요구합니다. 운영 부담, 레이블 데이터 양, 설명 의무, 트래픽 패턴, 예산. 제약을 읽지 않고 "가장 정확한 모델"을 고르면 틀립니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **파운데이션 모델(FM)** | 다양한 하위 작업에 적응할 수 있는 대형 사전학습 모델. 더 특화된 모델 개발의 출발점 |
| **전이학습(transfer learning)** | 사전학습 모델을 자체 데이터로 미세조정해 쓰는 방식. 대량 데이터가 없어도 학습이 가능해진다 |
| **스크립트 모드** | SageMaker가 제공하는 프레임워크 이미지(TensorFlow·PyTorch 등)에 **내 학습 스크립트**를 넣어 돌리는 방식 |
| **Parallelizable** | 공식 알고리즘 표의 열 이름. **다중 인스턴스 분산 학습 가능 여부**를 뜻한다 |
| **내재적/사후 해석** | 모델 자체를 읽어 설명하는가(선형 계수·트리 분기), 학습된 뒤 외부 기법으로 설명하는가(SHAP·PDP) |
| **Maintenance / Sunset** | AWS 수명 주기 단계. Maintenance는 **신규 온보딩 불가 + 기존 고객 계속 사용**, Sunset은 종료 일정이 정해진 단계 |
| **MU(모델 단위)** | Bedrock Provisioned Throughput의 과금·용량 단위. 시간당 과금되고 삭제할 때까지 청구된다 |
| **AutoML** | 알고리즘 선택·튜닝·배포를 자동화하는 접근(SageMaker Autopilot·Canvas) |

---

## 📖 핵심 개념

### 1) 선택 사다리 — 노력과 통제권은 함께 올라간다 {#approach-ladder}

SageMaker 공식 문서는 구현 선택지를 **사전학습 모델 → 내장 알고리즘 → 프레임워크 스크립트 모드 → 커스텀 Docker 이미지** 순으로 노력이 커진다고 정리합니다. AWS 의사결정 가이드는 이 사다리의 가장 아래에 "ML 전문성 없이 사전 구축 기능을 앱에 넣는" 관리형 AI 서비스를 둡니다.

| 단계 | 대표 선택지 | 코드·전문성 | 통제권 | 언제 |
|---|---|---|---|---|
| ① 관리형 AI 서비스 | Translate·Transcribe·Polly·Rekognition·Textract·Comprehend·Lex·Personalize | 거의 없음 | 낮음(입력·일부 파라미터) | 사전 구축 기능이 요구와 일치 |
| ② 파운데이션 모델 | Amazon Bedrock · JumpStart의 FM | API 호출 중심 | 중간 | 생성형(요약·질의응답·생성) |
| ③ 내장 알고리즘 | XGBoost·Linear Learner·K-Means 등 24종 | 코딩 불필요(데이터·하이퍼파라미터·컴퓨트만) | 중간(알고리즘 고정) | 자체 데이터로 학습, 대규모 확장 |
| ④ 프레임워크 스크립트 모드 | scikit-learn·Spark ML·TensorFlow·PyTorch·MXNet·Chainer | 코드 필요 | 높음(단 PyPI 패키지까지) | 내장에 없는 알고리즘을 직접 코딩 |
| ⑤ 커스텀 Docker 이미지 | ECR 등의 이미지 | 가장 많음 | 최고 | 지원 프레임워크 밖의 언어·패키지 |

- 사다리를 **낮게** 유지하는 쪽이 기본값입니다. ML Lens는 사용 가능한 사전학습 대안을 검토하지 않고 모든 사례에 커스텀 모델을 만드는 것을 **안티패턴**으로 명시합니다.
- 스크립트 모드의 경계: 지원 프레임워크 이미지에는 **PyPI에 있는 패키지만** 추가할 수 있습니다. PyPI 밖 소프트웨어(예: Stan·Julia)가 필요하면 커스텀 이미지입니다.
- 생성형 AI의 일반적 진행 경로는 **Bedrock에서 시작해 맞춤화 요구가 커지면 SageMaker AI로** 가는 것입니다.

> 🧠 **원리** — 알고리즘과 문제 유형의 대응은 일대일이 아니라 **다대다**입니다. 그래서 "이 문제를 풀 수 있는가"만으로는 선택이 끝나지 않고, 데이터량·맞춤 정도·운영 부담·해석 요구·비용이 사다리의 높이를 정합니다.

### 2) ML이 맞는 문제인가 — 적합성 판단 {#ml-fitness}

서비스·알고리즘을 고르기 전에 **ML이 이 문제에 맞는지**부터 판단합니다. ML Lens의 "ML 문제 프레이밍"은 규칙으로 충분한 문제와 데이터가 부족한 문제를 부적합 사례로 들고, MLCOST02-BP01은 이를 비용 관점으로 구체화합니다 — ML은 데이터 준비·전용 하드웨어·유지보수 투자가 필요하므로 **단순 규칙이 더 싸게 개발·유지될 수 있습니다.**

| 평가 축 | 확인 질문 | 판단 |
|---|---|---|
| 규칙 가능성 | 목표값을 단순 규칙·계산·정해진 단계로 정할 수 있는가 | 가능하면 ML 불필요. **규칙 기반 baseline과 비교하지 않는 것이 안티패턴** |
| 데이터 가용성·품질 | 가진 데이터와 모을 데이터의 양·품질이 충분한가 | 부족하면 ML 부적합 또는 수집·레이블링이 선행 |
| 문제 복잡도 | 규칙이 못 잡는 패턴이거나 조건이 계속 변하는가 | 사기 탐지처럼 패턴이 변하면 ML 유리, 단순 재고 관리는 규칙이 적합할 수 있음 |
| 비용·자원 | 준비·학습·레이블링·재학습·호스팅·유지보수 비용이 가치로 정당화되는가 | **데이터 과학자 시간**이 가장 부족한 자원일 수 있어 인력도 비용 |
| 설명 요구 | 규제·감사로 예측 이유를 설명해야 하는가 | 해석하기 쉬운 단순 모델로 시작(→ 6) |

- 권고 절차: 문제·성공 기준 정의 → 데이터 충분성 평가 → 비용 산정 → **baseline 설정**(규칙 기반, 또는 JumpStart·Marketplace 사전 구축 솔루션) → 프로토타입 후 정확도·추론 시간·총비용 비교 → 데이터 기반 결정.
- ⚠️ "ML에 충분한 데이터량"의 **보편적 수치 기준을 서술한 공식 문서는 없습니다.** 공식 수치는 서비스별 최소 요건뿐입니다 — Personalize는 상호작용 1,000건 + 상호작용 2회 이상인 고유 사용자 25명(품질 권장 50,000건·1,000명), DeepAR는 전체 학습 시계열의 **관측치 합계 300**, Rekognition Custom Labels는 클래스당 수백 장 이하. 수치를 일반 임계값으로 외우면 안 됩니다.

### 3) 문제 유형과 학습 패러다임 {#problem-types}

| 패러다임 | 데이터 조건 | 문제 유형 | 내장 알고리즘 예 |
|---|---|---|---|
| 지도 학습 | 입력(특징) + **목표값(레이블)** | 분류(목표값 범주형)·회귀(목표값 연속형) | XGBoost·Linear Learner·k-NN·Factorization Machines·LightGBM·CatBoost·AutoGluon·TabTransformer·DeepAR |
| 비지도 학습 | 레이블·목표값 **없음** | 차원 축소·군집·이상 탐지·밀도 추정·토픽 모델링 | PCA·K-Means·Random Cut Forest·IP Insights·LDA·NTM |
| 강화 학습 | 환경과 시행착오로 상호작용해 장기 보상 최대화 | 탐험과 활용의 균형 | SageMaker RL 툴킷 — **컨테이너는 2024-04 지원 종료** ⚠️ |

- 비지도 문제 유형의 공식 정의: **차원 축소**는 고차원 희소 공간을 중요한 성질을 보존한 저차원으로 변환, **군집**은 특징·거리 함수·군집 수를 정해 유사한 것끼리 묶기, **이상 탐지**는 나머지와 크게 다른 드문 항목 식별, **밀도 추정**은 관측 데이터로 기저 확률 밀도 함수를 구성.
- 신경망처럼 여러 패러다임·여러 문제 유형에 쓰이는 알고리즘이 있어 **"알고리즘 이름 → 패러다임"이 항상 일대일은 아닙니다.** 예: Object2Vec은 레이블된 쌍을 쓰는 지도 알고리즘이고, BlazingText는 모드에 따라 비지도(Word2vec)와 지도(텍스트 분류) 양쪽입니다.
- 일반 ML 알고리즘의 공식 설명: 로지스틱 회귀는 특정 분류에 속할 가능성 판단, 결정 트리는 if-then-else 구조, 랜덤 포레스트는 여러 결정 트리로 단일 트리보다 정확한 결과, 서포트 벡터 머신은 데이터셋을 더 높은 차원으로 변환한 뒤 처리, 선형 회귀는 직선 적합으로 가장 단순한 알고리즘 중 하나.

### 4) 내장 알고리즘 카탈로그 — 하드웨어 제약이 단서다 {#builtin-catalog}

"Parameters for Built-in Algorithms" 표(행 24개)가 현재 문서의 내장 알고리즘 전체 목록입니다. 아래는 계열별 페이지와 알고리즘 페이지를 합친 것이며, **"분산"은 공식 표의 Parallelizable**(다중 인스턴스)입니다.

**표 형식 지도 학습 (8종)**

| 알고리즘 | 무엇을 | 입력 | 하드웨어 | 포인트 |
|---|---|---|---|---|
| XGBoost | 그래디언트 부스티드 트리 — 회귀·분류·랭킹 | CSV·LibSVM·Parquet | CPU, 일정 버전 이상 GPU | **메모리 바운드** → 범용(M5) 인스턴스 권장 |
| Linear Learner | 선형 함수(회귀)·선형 임계 함수(분류) | recordIO-protobuf·CSV | CPU/GPU | 여러 학습 목표를 동시 탐색해 검증 세트에서 최선 선택 |
| k-NN | 비모수 분류·회귀 | recordIO-protobuf·CSV | CPU/GPU | 학습 = 샘플링 → 차원 축소 → 인덱스 구축. 추론 지연은 CPU가 낮음 |
| Factorization Machines | 선형 모델 확장 — **쌍별(2차) 상호작용** | **recordIO-protobuf(Float32)만** | CPU(희소), GPU는 밀집만 | 고차원 희소(클릭 예측·추천) |
| LightGBM | GBDT + GOSS·EFB | CSV | CPU | 메모리 바운드 |
| CatBoost | GBDT + ordered boosting·범주형 처리 | CSV | **CPU 전용** | 단일 인스턴스. 메모리 바운드 |
| AutoGluon-Tabular | 모델 앙상블 + 다층 스태킹 | CSV | CPU 또는 GPU, **단일 인스턴스** | 가공하지 않은 표 데이터에서 높은 정확도 |
| TabTransformer | 셀프 어텐션 트랜스포머 기반 딥 표 모델 | CSV | CPU 또는 GPU, **단일 인스턴스** | 문서가 결측·노이즈 강건성과 해석 가능성을 직접 언급 |

**비지도 (6종)**

| 알고리즘 | 무엇을 | 하드웨어 | 포인트 |
|---|---|---|---|
| K-Means | 이산 군집 탐색 — 출력은 `closest_cluster`·`distance_to_cluster` | CPU 권장, GPU는 단일 GPU 인스턴스로 제한 | 행=관측치, 열=속성(유클리드 거리) |
| PCA | 차원 축소(주성분 투영) — **regular / randomized** 두 모드 | CPU/GPU, 분산 가능 | 희소·중간 규모는 regular, 관측치·특징이 모두 많으면 randomized(근사) |
| Random Cut Forest | 포인트별 **이상 점수** | CPU. **GPU에서 돌 수는 있으나 활용 못 함** | 평균에서 표준편차 3 초과를 이상으로 보는 관행. 임의 차원 입력 |
| IP Insights | **(엔터티, IPv4) 쌍**의 이례성 점수화 | CPU/GPU(학습 GPU·추론 CPU 권장) | **File 모드만**, 모델 크기 상한 8 GB. IP 임베딩도 학습 |
| LDA | 확률적 토픽 모델링 | **CPU 단일 인스턴스만** | perplexity 면에서 우수 |
| NTM | 신경망 기반 토픽 모델링 | CPU/GPU, 여러 GPU 인스턴스 병렬화 | 토픽 일관성(coherence)에 유망. 보조 채널 `vocab.txt` |

**텍스트·시퀀스·임베딩 (4종)** — BlazingText(Word2vec cbow·skip-gram·batch_skipgram + 텍스트 분류, subword로 OOV 벡터 생성, fastText와 모델 바이너리 호환) · Sequence-to-Sequence(**GPU 전용·단일 머신**, 번역·요약·음성→텍스트) · Text Classification - TensorFlow(TF Hub 사전학습 전이학습) · Object2Vec(**쌍** 임베딩, JSON Lines, 단일 인스턴스).

**이미지 (5종)** — Image Classification - MXNet / - TensorFlow · Object Detection - MXNet(SSD, 3채널만) / - TensorFlow · Semantic Segmentation(**GPU 전용 단일 인스턴스**, PNG 주석 채널).

**시계열 (1종)** — DeepAR: RNN 기반 스칼라 시계열 예측, **관련 시계열 여러 개를 하나의 모델로 공동 학습**. 관련 시계열이 수백 개일 때 ARIMA·ETS보다 우수하고, 시계열이 하나뿐이면 ARIMA·ETS가 더 정확할 수 있습니다. 추론은 CPU만.

> ⚠️ **상태 주석** — 24종 모두 현재 알고리즘 목록에 있고, 이름이 바뀌거나 폐기 표시된 내장 알고리즘은 없습니다. 다만 버전·컨테이너 수준의 경고가 있습니다: DeepAR 컨테이너는 기반 **MXNet이 end-of-maintenance**라 보안 패치 중단 공지가 있고, RL 컨테이너는 지원 종료입니다. 이 경고가 알고리즘을 목록에서 제외했다는 뜻인지 설명한 문구는 없습니다. **LightGBM·BlazingText의 분산 가능 여부와 XGBoost 버전 번호는 공식 문서 사이에 표기가 엇갈립니다** — 암기 대상이 아닙니다.

### 5) 문제 유형 → 알고리즘·대안 {#algo-selection}

| 문제 유형 | 공식 예시 | 내장 알고리즘 | 노력이 더 낮은 대안 |
|---|---|---|---|
| 분류·회귀(표) | 스팸 필터, 주택 가치 추정 | 위 8종 | Canvas·Autopilot |
| 시계열 예측 | 신제품 판매 예측 | DeepAR | Amazon Forecast ⚠️(신규 불가) → Canvas |
| 임베딩 | 중복 티켓 식별 | Object2Vec | — |
| 차원 축소 | 관련 약한 열 제거 | PCA | — |
| 이상 탐지 | IoT 센서 비정상 판독 | Random Cut Forest | Lookout 계열 ⚠️(종료) → CloudWatch·OpenSearch |
| IP 이상 | 악의적 공격자 IP | IP Insights | — |
| 군집 | 지출 수준별 고객 묶기 | K-Means | — |
| 토픽 모델링 | 사전에 모르는 토픽 | LDA·NTM | Comprehend 토픽 모델링 ⚠️(신규 불가) |
| 텍스트 분류 | 도서를 학문 분야로 | BlazingText·Text Classification - TF | Comprehend 사용자 정의 분류 |
| 기계 번역 | 스페인어 → 영어 | Sequence-to-Sequence | Amazon Translate |
| 음성 → 텍스트 | 콜센터 전사 | Sequence-to-Sequence | Amazon Transcribe |
| 텍스트 요약 | 논문 초록 | Sequence-to-Sequence | Bedrock·JumpStart FM |
| 이미지 레이블 | 성인 콘텐츠 알림 | Image Classification | Rekognition(Custom Labels) |
| 객체 탐지 | 사진에서 사람·사물 | Object Detection | Rekognition |
| 픽셀 분류 | 자율주행 객체 식별 | Semantic Segmentation | — |
| 추천·클릭 예측 | 아이템 추천 | Factorization Machines·Object2Vec | Amazon Personalize |

**빠른 결정 순서** — ① 레이블이 있는가(없으면 비지도) → ② 목표값이 범주형(분류)인가 연속형(회귀)인가 → ③ 데이터 형태가 표·희소·텍스트·이미지·시계열 중 무엇인가 → ④ 출력이 점수·군집·토픽·경계 상자·픽셀·임베딩 중 무엇인가 → ⑤ 같은 기능의 관리형 서비스가 있고 맞춤이 필요 없으면 서비스부터.

### 6) 해석 가능성이 선택을 바꿀 때 {#interpretability}

해석 가능성(interpretability)은 **사람이 결정의 원인을 이해할 수 있는 정도**입니다. AWS는 기법을 두 부류로 나눕니다 — ① 블랙박스 모델의 결정을 내린 뒤 설명하는 **사후(post hoc)** 방법, ② 모델 자체가 해석 가능하게 동작함을 활용하는 **내재적(interpretable)** 방법.

| 접근 | 대표 모델 | 해석 방식 | 성능 |
|---|---|---|---|
| 내재적 | 선형 회귀(예측 = 입력의 가중합), 결정 트리(if-then 규칙), 규칙 기반 | 계수 자체가 설명, 분기 변수·리프 값이 곧 설명 | 비선형 상호작용을 못 잡아 낮은 경우가 많음 |
| 사후 | 신경망, 트리 앙상블, 딥 표 모델 | 모델 비의존 기법 — LIME·SHAP·PDP. 트리 앙상블은 Tree SHAP, 신경망은 integrated gradients, 그 밖은 Kernel SHAP | 높음. 대신 설명이 사후·근사이고 Kernel SHAP은 비용이 큼 |

**AWS 권고 순서**: 해석 가능하고 성능이 충분한 **단순 모델로 시작**하고, 성능 개선이 필요해지면 복잡도를 높이면서 사후 분석으로 해석합니다. MLPERF06-BP02가 드는 안티패턴은 ① 모델을 불투명한 채로 두는 것 ② **설명 요구를 배포 뒤로 미루는 것** ③ 규제·비즈니스가 설명을 요구하는데 성능 지표를 우선하는 것 ④ 단순 모델로 충분한데 복잡 모델을 쓰는 것입니다.

- 비즈니스 맥락이 결정합니다. ML Lens 예시 — **신용 승인**은 거절 이유 설명이 필요하고, **제조 품질관리**는 설명보다 정확도를 우선할 수 있습니다.
- "복잡한 모델은 설명이 불가능하다"는 단정은 틀립니다. 사후 기법은 신경망 같은 복잡 모델에도 적용됩니다.
- ⚠️ 개별 내장 알고리즘의 해석 가능성을 **직접 서술한 공식 페이지는 TabTransformer뿐**입니다. 그래서 이 문서의 배정은 "선형 모델·결정 트리는 내재적, 복잡 모델은 사후"라는 **일반 원칙** 수준으로만 읽어야 합니다. 내장 24종에는 단일 결정 트리 전용 알고리즘이 없습니다.
- ⚠️ SageMaker Clarify는 **신규 고객에게 닫혀 있습니다**(→ 8). 설명 도구를 고를 때 상태를 함께 봐야 합니다.

### 7) AI 서비스 — 입력의 형태로 가른다 {#ai-services}

| 비즈니스 요구 | 서비스 | 입력 → 출력 |
|---|---|---|
| 다국어 번역 | Amazon Translate | 텍스트 → 번역 텍스트 |
| 음성을 텍스트로 | Amazon Transcribe | 오디오 → 텍스트(실시간 스트리밍·S3 배치, 화자 분리·다채널) |
| 텍스트를 음성으로 | Amazon Polly | 텍스트 → 음성(generative·long-form·neural·standard) |
| 이미지·비디오 분석 | Amazon Rekognition | 이미지·비디오 → 레이블·경계·얼굴. Custom Labels로 용도 특화 분류기 |
| 스캔 문서 추출 | Amazon Textract | 이미지·PDF → 텍스트·양식(key-value)·표·송장·신분증 |
| 텍스트 인사이트 | Amazon Comprehend | **이미 텍스트인 입력** → 엔터티·감성·핵심 구문·PII. 사용자 정의 분류·엔터티 인식 학습 가능 |
| 임상 텍스트 | Comprehend Medical | 임상 텍스트 → 의료 엔터티·PHI, RxNorm·ICD-10-CM 연결(영어만) |
| 챗봇 | Amazon Lex V2 | 음성·텍스트 → 의도·슬롯 |
| 개인화 추천 | Amazon Personalize | 상호작용 데이터 → 추천·사용자 세그먼트 |
| 생성형 AI | Amazon Bedrock | 프롬프트 → 생성 결과 |

- **연계 패턴**: 스캔 문서 → Textract로 텍스트화 → Comprehend로 분석. Transcribe 자막 → Translate 번역 → Polly 음성화. SageMaker Canvas의 Ready-to-use 모델은 Rekognition·Textract·Comprehend로 구동됩니다.
- **맞춤이 필요할 때 서비스 안에서**: Comprehend 사용자 정의 모델, Rekognition Custom Labels(소량 이미지), Textract Custom Queries.
- 보안·지연·정확도 기준: 대부분의 특화 AI 서비스는 VPC 프라이빗 엔드포인트를 지원하지 않지만 **Rekognition Custom Labels·Comprehend Custom은 VPC 엔드포인트로 접근**할 수 있고 Translate·Transcribe·Comprehend도 지원합니다. 상위 AI 서비스는 빠르지만 특정 지연 요구는 못 맞출 수 있고, 직접 만든 모델이 더 높은 정확도를 낼 수 있습니다.

### 8) 서비스 수명 주기 — 보기에 섞이는 "못 쓰는 서비스" {#service-status}

**Maintenance** = 신규 온보딩 불가, 기존 고객은 계속 사용 · **Sunset** = 종료 일정이 정해진 단계 · **Full Shutdown** = 완전 제거. 아래는 **시험 범위에는 남아 있지만 실제 상태가 다른** 항목입니다(2026-10-17 기준).

| 서비스·기능 | 상태 | 공식 안내 대안 |
|---|---|---|
| Amazon Forecast | 신규 고객 접근 종료(2024-07-29 효력) | SageMaker Canvas 시계열 예측 |
| Lookout for Vision | 2025-10-31 중단 | SageMaker·JumpStart 이미지 모델·Bedrock |
| Lookout for Metrics | 2025-10-10 지원 종료 | OpenSearch·CloudWatch·Redshift ML·QuickSight |
| Lookout for Equipment | 2026-10-07 지원 종료 | AWS IoT SiteWise 다변량 이상 탐지 |
| Amazon Fraud Detector | 2025-11-07부터 신규 불가 | SageMaker·AutoGluon·AWS WAF |
| CodeGuru Reviewer | 2025-11-07부터 새 리포지토리 연결 불가 | Q Developer 코드 리뷰·Inspector |
| Amazon DevOps Guru | 신규 불가 2026-10-29, 지원 종료 2027-09-30 | CloudWatch 이상 탐지 |
| Amazon Kendra | 2026-06-30 Maintenance, 2026-07-30부터 신규 불가 | **Bedrock Knowledge Bases** |
| Amazon Q Business | 신규 고객 불가 | **Amazon Quick** |
| Amazon A2I · Clarify · Debugger · Model Monitor | SageMaker AI 기능 묶음으로 2026-07-30부터 신규 불가 | (개별 안내) |
| Comprehend 일부 | 토픽 모델링·이벤트 탐지·프롬프트 안전 분류 2026-04-30부터 신규 불가 | Bedrock LLM·Guardrails |
| Rekognition 일부 | 스트리밍 비디오 분석·배치 이미지 콘텐츠 중재 신규 불가(다른 기능 영향 없음) | (페이지 참조) |
| Bedrock Agents | Agents Classic으로 개명, 신규 불가 — **Bedrock 자체는 영향 없음** | Bedrock AgentCore |

- 이름 변경도 함께 봅니다: **SageMaker → SageMaker AI**(2024-12-03, ML 서비스 쪽), 새 "Amazon SageMaker"는 통합 플랫폼. **Autopilot UI → Canvas**(2023-11-30 이후).
- ⚠️ **JumpStart 솔루션 템플릿**은 "Studio Classic에서만 사용 가능"이고 "Studio Classic은 신규 온보딩 불가"입니다. 두 문장을 합치면 신규 계정은 쓸 수 없다고 읽히지만 문서가 그렇게 직접 쓴 문장은 없으므로 이 문서도 단정하지 않습니다.

### 9) JumpStart와 Bedrock {#jumpstart-bedrock}

FM 맞춤화의 권장 순서는 ① **프롬프트 엔지니어링**(가중치 변경 없음) → ② 부족하면 도메인 데이터로 **미세조정**(가중치 변경) → ③ 지식 라이브러리를 쓰되 재학습이 필요 없는 **RAG**입니다.

| 기준 | SageMaker JumpStart | Amazon Bedrock |
|---|---|---|
| 정체 | SageMaker 안의 **모델 허브** — 사전학습 모델·FM·솔루션 템플릿 | **서버리스 FM 플랫폼(API)** |
| 모델 풀 | 1,000개에 가까운 모델 | 100개 이상 FM. Claude 등 일부 독점 모델은 Bedrock에만 |
| 실행 환경 | 사용자가 정하는 인스턴스·엔드포인트(컨테이너·오케스트레이션 접근) | 서버리스, 인프라 관리 최소 |
| 과금 | 학습·추론 **인스턴스 사용량** | **토큰당**(온디맨드)·배치·Provisioned Throughput·서비스 티어 |
| 맞춤화 | 프롬프트 → 미세조정 → RAG(모델별 지원 상이) | 지도 미세조정·강화 미세조정·증류·Custom Model Import·Knowledge Bases |
| 적합 | 컨테이너 계층에 접근해 비용-지연-처리량을 직접 관리할 때, 예측형·고전 ML 포함 | 맞춤 모델 개발에 크게 투자하지 않고 앱·에이전트를 만들 때 |

- JumpStart는 사전학습 모델의 **배포·미세조정·평가**를 지원하지만 모든 모델이 미세조정·평가를 지원하지는 않습니다. 솔루션 템플릿은 수요 예측·신용 등급·사기 탐지·예지보전·이탈 예측 같은 사용 사례를 다룹니다.
- 모델 라이선스는 제공자별로 다르고 **사용자가 검토·준수할 책임**이 있으며 일부 FM은 EULA 수락이 필요합니다.
- SageMaker에서 학습한 사용자 정의 모델을 **Bedrock에 가져와(Custom Model Import)** 서버리스로 추론할 수도 있습니다.

### 10) AutoML — Autopilot과 Canvas {#automl}

- **Autopilot**: 데이터 분석·전처리, **모델 선택**(여러 알고리즘 탐색 + 교차 검증 리샘플링으로 지표 비교), 하이퍼파라미터 최적화, 학습·평가, 배포를 자동화합니다. 표 형식 회귀·분류 외에 텍스트 분류·이미지 분류·시계열 예측·LLM 미세조정도 지원하며 **표 형식 외에는 AutoML API V2로만** 씁니다. AUTO 모드는 데이터셋이 **100 MB 미만이면 ENSEMBLING, 더 크면 HYPERPARAMETER_TUNING**을 선택합니다. 특징 중요도 설명 리포트를 자동 생성합니다.
- **Canvas**: 분석가·시민 데이터 과학자를 위한 **무코드** 환경. 숫자 예측, 2범주·3범주 이상 예측, 시계열 예측, 단일 레이블 이미지 예측, 다중 범주 텍스트 예측을 지원하고 데이터셋으로 **최대 250개 모델**을 만들어 가장 좋은 것을 고릅니다.
- 혼동 주의: **AutoGluon-Tabular는 앙상블·스태킹을 쓰는 하나의 내장 알고리즘**이고, **Autopilot은 선택 과정 자체의 자동화**입니다.

### 11) 비용 기준 선택 {#cost-choice}

비용 선택의 출발점은 **과금 단위**입니다. 관리형 AI 서비스는 문자·초·호출·페이지 같은 사용량, 자체 학습·호스팅은 인스턴스 시간, Bedrock FM은 토큰 또는 약정 시간입니다.

| 선택지 | 과금 | 유리한 상황 | 유의 |
|---|---|---|---|
| Translate·Polly | 문자 수 종량제 | 간헐·변동 수요 | Polly는 생성 음성을 캐시해 재생하면 추가 비용 없음 |
| Transcribe | 전사한 오디오 초 단위 | 〃 | PII 삭제·사용자 정의 언어 모델은 추가 요금 |
| Rekognition Image | 호출당 + 얼굴 메타데이터 저장 | 소량·변동 | **월 수천 장 이상이면 SageMaker 엔드포인트가 더 저렴할 수 있음** |
| Comprehend | 비동기는 문자 수, 사용자 정의 실시간은 **엔드포인트 가동 시간** | 배치 분석 | 실시간 엔드포인트는 켜 둔 시간 전체가 과금 |
| Bedrock 온디맨드 | 입력·출력 **토큰당** | 변동·PoC | 모델별 RPM/TPM 한도 |
| Bedrock 배치 | 온디맨드 대비 **최대 50% 절감** | 비실시간 대량 | 즉시 응답 불가 |
| Bedrock Provisioned Throughput | **MU당 시간**, 무약정·1개월·6개월 | 안정적 대량·처리량 보장 | **사용 여부와 무관하게 삭제할 때까지 청구** |
| SageMaker 학습·호스팅 | 컴퓨트·스토리지 종량제, Savings Plans로 최대 64% 절감 | 대량·세밀한 통제 | 엔드포인트 운영 책임 |

- **단순 알고리즘 먼저**: 계산량이 큰 알고리즘은 정확도를 근소하게 올리는 대신 운영비를 크게 늘릴 수 있고, 단순 알고리즘 탐색 없이 딥러닝을 쓰는 것은 안티패턴입니다.
- **하드웨어도 비용**: CatBoost는 CPU 전용, RCF는 GPU를 활용하지 못하고, LDA는 단일 인스턴스 CPU입니다. 이들에 GPU를 붙이면 낭비입니다. 반대로 XGBoost는 GPU 단가가 높아도 더 빨리 끝나 비용 효율적일 수 있습니다.
- ⚠️ Bedrock 사용자 정의 모델 추론은 문서 사이에 설명이 다릅니다 — Provisioned Throughput 문서는 "PT를 구매해야 한다"고, 추론 설정 문서는 **PT 구매 또는 온디맨드 배포** 두 가지를 제시합니다. 시험 문항이 구 규칙(PT 필수)을 전제할 수 있습니다.

---

## ✍️ 시험 포인트

- 제약을 먼저 읽습니다. **"ML 전문 인력이 없다·운영 최소·빠른 출시"** → AI 서비스. **"맞춤은 필요한데 레이블 데이터가 적다"** → 서비스의 사용자 정의 기능 또는 JumpStart 미세조정. **"요약·질의응답·생성"** → Bedrock. **"대규모 자체 데이터 + 알고리즘 통제"** → 내장 알고리즘. **"내장에 없는 알고리즘을 직접 코딩"** → 스크립트 모드. **"지원 프레임워크 밖 패키지"** → 커스텀 이미지.
- 내장 알고리즘은 **출력 단위**로 좁힙니다. 이미지 전체 레이블 → 분류, 클래스 + 경계 상자 → 탐지, 모든 픽셀 → 분할. 점수 → RCF, (엔터티, IP) → IP Insights, 미지정 토픽 → LDA·NTM.
- **고차원 희소 + 클릭 예측**은 Factorization Machines입니다. 입력이 recordIO-protobuf만이라는 점이 함께 단서가 됩니다.
- **설명 의무**가 시나리오에 있으면 정확도 최고 모델을 고르지 않습니다. 내재적 모델로 시작하거나 복잡 모델 + 사후 설명을 계획합니다. 설명 검토를 **배포 후로 미루는 선택지는 안티패턴**입니다.
- 비용 문항은 **트래픽 패턴**으로 끝납니다. 변동·PoC → 온디맨드, 비실시간 대량 → 배치, 안정적 대량 → 약정(PT·Savings Plans).
- 최신 상태를 묻는 문항에서는 신규 고객이 못 쓰는 서비스가 보기에 섞입니다. Kendra → **Bedrock Knowledge Bases**, Q Business → **Amazon Quick**, Forecast → **Canvas**가 공식 대안입니다.
- 폐지·개명 이름 주의: SageMaker → **SageMaker AI**, Autopilot UI → **Canvas**, Bedrock Agents → **Agents Classic**(Bedrock 본체는 무영향).

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| Textract·Rekognition·Comprehend를 섞어 고른다 | **입력의 형태**로 가른다 — 문서는 Textract, 이미지·비디오는 Rekognition, **이미 텍스트인 입력**은 Comprehend |
| 모든 표 형식 알고리즘이 분산·GPU를 지원한다고 가정한다 | CatBoost는 CPU 전용, AutoGluon·TabTransformer는 단일 인스턴스, RCF는 GPU 이점이 없고 Seq2Seq는 GPU 전용이다 |
| LDA와 NTM을 같은 것으로 본다 | 같은 문제를 풀지만 **LDA는 단일 인스턴스 CPU**, NTM은 CPU·GPU에 다중 GPU 병렬화가 된다. 지표 성향도 perplexity 대 coherence로 다르다 |
| RCF로 (엔터티, IP) 조합의 이례성을 잡으려 한다 | RCF는 **임의 차원 수치 데이터**의 포인트 점수이고, 엔터티-IP 쌍의 사용 패턴은 **IP Insights**다 |
| Object2Vec을 비지도로 분류한다 | Object2Vec은 **레이블된 쌍**을 쓰는 지도 알고리즘이다. BlazingText가 모드에 따라 양쪽인 것과 다르다 |
| "복잡한 모델은 설명할 수 없다"고 단정한다 | 사후(post hoc) 기법은 신경망·트리 앙상블에도 적용된다. 트리 앙상블은 Tree SHAP, 신경망은 integrated gradients |
| AutoGluon-Tabular와 Autopilot을 같은 층으로 본다 | 전자는 **하나의 내장 알고리즘**(앙상블·스태킹), 후자는 **선택 과정의 자동화**다 |
| Bedrock Agents 신규 불가를 Bedrock 전체로 읽는다 | 개명·신규 중단은 **Agents Classic**에 한정되고 Bedrock 자체는 영향이 없다 |
| 비용을 줄이려고 항상 Provisioned Throughput을 고른다 | PT는 **사용 여부와 무관하게 삭제할 때까지 청구**된다. 변동 트래픽은 온디맨드, 비실시간 대량은 배치다 |
| 규칙으로 풀리는 문제에 ML을 붙인다 | 목표값을 규칙·계산으로 정할 수 있으면 ML은 불필요하다. **규칙 기반 baseline과 비교하지 않는 것이 안티패턴**이다 |

---

## 🧪 자가 점검

1. 콜센터 녹취를 전사해 감성을 분석하려 한다. ML 인력은 없다. 서비스 두 개를 어떤 순서로 연계하는가? *(→ 7) AI 서비스)*
2. 클릭 로그가 수백만 행이고 특징이 매우 희소하다. 어떤 내장 알고리즘이 맞고, 그 알고리즘의 입력 형식 제약은? *(→ 4) 카탈로그, 5) 선택표)*
3. 대출 거절 사유를 고객에게 설명해야 한다. 모델 선택을 어떤 순서로 하고, 어떤 선택이 안티패턴인가? *(→ 6) 해석 가능성)*
4. 사내 문서 자연어 검색을 새로 만들려는데 Amazon Kendra가 보기에 있다. 왜 답이 아니고, 공식 대안은? *(→ 8) 수명 주기)*
5. 지원 프레임워크에 없는 언어로 작성된 알고리즘을 학습시켜야 한다. 사다리의 어느 단계이고, 그 앞 단계가 왜 불가능한가? *(→ 1) 선택 사다리)*
6. 사전에 모르는 토픽으로 문서를 묶되 학습을 GPU 여러 대로 병렬화하고 싶다. 두 토픽 모델 중 무엇인가? *(→ 4) 카탈로그)*

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며, C01 시험 범위는 아닙니다.

- **C02 대응 Task**: 2.1 「ML 및 AI 솔루션에 적합한 모델링 접근 방식을 선택합니다」
- **추가된 항목 5개**
  - `2.1.1` 작업 요구 사항 및 성능 기준에 따라 **Amazon Bedrock에서 적절한 FM을 평가하고 선택**합니다.
  - `2.1.2` 사전 훈련된 FM이 비즈니스 요구 사항을 충족할 수 있는 **미세 조정 전략**을 파악합니다.
  - `2.1.4` **맞춤형 솔루션·관리 서비스·사전 학습된 모델·FM 사이의 장단점**을 평가합니다.
  - `2.1.5` 사용 사례 요구 사항에 따라 **검색 증강 생성(RAG) 아키텍처 패턴**을 선택합니다.
  - `2.1.7` **AI 모델 성능·지연 시간·비용 사이의 절충점**을 평가합니다.
- **삭제된 항목**: 이 Task에는 없음
- 읽는 법: C01에서 이 Task가 "고전 ML 알고리즘 선택 + AI 서비스 매핑"이었다면, C02는 그 무게를 **FM 평가·미세조정 전략·RAG 패턴**으로 옮깁니다. 1)의 사다리와 11)의 과금 비교는 그대로 쓰이고, 4)의 내장 알고리즘 카탈로그 비중이 줄어듭니다.

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- [Types of Algorithms](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-choose.html) · [Built-in algorithms and pretrained models](https://docs.aws.amazon.com/sagemaker/latest/dg/algos.html) · [Parameters for Built-in Algorithms](https://docs.aws.amazon.com/sagemaker/latest/dg/common-info-all-im-models.html)
- 계열별 알고리즘 페이지: [표 형식](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-tabular.html) · [텍스트](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-text.html) · [비지도](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-unsupervised.html) · [컴퓨터 비전](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-vision.html) · [시계열](https://docs.aws.amazon.com/sagemaker/latest/dg/algorithms-time-series.html)
- 개별 알고리즘: [XGBoost](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost.html) · [Linear Learner](https://docs.aws.amazon.com/sagemaker/latest/dg/linear-learner.html) · [k-NN](https://docs.aws.amazon.com/sagemaker/latest/dg/k-nearest-neighbors.html) · [Factorization Machines](https://docs.aws.amazon.com/sagemaker/latest/dg/fact-machines.html) · [CatBoost](https://docs.aws.amazon.com/sagemaker/latest/dg/catboost.html) · [AutoGluon-Tabular](https://docs.aws.amazon.com/sagemaker/latest/dg/autogluon-tabular.html) · [TabTransformer](https://docs.aws.amazon.com/sagemaker/latest/dg/tabtransformer.html)
- [K-Means](https://docs.aws.amazon.com/sagemaker/latest/dg/k-means.html) · [PCA](https://docs.aws.amazon.com/sagemaker/latest/dg/pca.html) · [Random Cut Forest](https://docs.aws.amazon.com/sagemaker/latest/dg/randomcutforest.html) · [IP Insights](https://docs.aws.amazon.com/sagemaker/latest/dg/ip-insights.html) · [LDA](https://docs.aws.amazon.com/sagemaker/latest/dg/lda.html) · [NTM](https://docs.aws.amazon.com/sagemaker/latest/dg/ntm.html)
- [BlazingText](https://docs.aws.amazon.com/sagemaker/latest/dg/blazingtext.html) · [Sequence-to-Sequence](https://docs.aws.amazon.com/sagemaker/latest/dg/seq-2-seq.html) · [Object2Vec](https://docs.aws.amazon.com/sagemaker/latest/dg/object2vec.html) · [Semantic Segmentation](https://docs.aws.amazon.com/sagemaker/latest/dg/semantic-segmentation.html) · [DeepAR](https://docs.aws.amazon.com/sagemaker/latest/dg/deepar.html)
- 의사결정 가이드: [Choosing an AWS machine learning service](https://docs.aws.amazon.com/decision-guides/latest/decision-guides/ml-guide.html) · [Amazon Bedrock or Amazon SageMaker AI?](https://docs.aws.amazon.com/decision-guides/latest/decision-guides/bedrock-or-sagemaker.html)
- ML Lens: [ML problem framing](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/ml-problem-framing.html) · [MLCOST02-BP01](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost02-bp01.html) · [MLCOST02-BP02](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost02-bp02.html) · [MLCOST04-BP14](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp14.html) · [MLPERF06-BP02](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp02.html)
- 해석 가능성: [Model interpretability (백서)](https://docs.aws.amazon.com/whitepapers/latest/ml-best-practices-healthcare-life-sciences/model-interpretability.html) · [ML model interpretability (Prescriptive Guidance)](https://docs.aws.amazon.com/prescriptive-guidance/latest/ml-model-interpretability/introduction.html) · [Local interpretability](https://docs.aws.amazon.com/prescriptive-guidance/latest/ml-model-interpretability/local.html) · [What Is Explainable AI?](https://aws.amazon.com/what-is/explainable-ai/)
- AutoML·JumpStart: [Autopilot](https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-automate-model-development.html) · [Canvas](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas.html) · [How custom models work](https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-build-model.html) · [AutoMLJobConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_AutoMLJobConfig.html) · [JumpStart 사전학습 모델](https://docs.aws.amazon.com/sagemaker/latest/dg/studio-jumpstart.html) · [JumpStart 솔루션 템플릿](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-solutions.html) · [FM 맞춤화](https://docs.aws.amazon.com/sagemaker/latest/dg/jumpstart-foundation-models-customize.html)
- Bedrock: [What is Amazon Bedrock?](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html) · [Provisioned Throughput](https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html) · [사용자 정의 모델 추론 설정](https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html) · [모델 맞춤화](https://docs.aws.amazon.com/bedrock/latest/userguide/custom-models.html) · [Agents Classic maintenance](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html) · [요금](https://aws.amazon.com/bedrock/pricing/)
- AI 서비스: [Translate](https://docs.aws.amazon.com/translate/latest/dg/what-is.html) · [Transcribe](https://docs.aws.amazon.com/transcribe/latest/dg/what-is.html) · [Polly](https://docs.aws.amazon.com/polly/latest/dg/what-is.html) · [Textract](https://docs.aws.amazon.com/textract/latest/dg/what-is.html) · [Comprehend](https://docs.aws.amazon.com/comprehend/latest/dg/what-is.html) · [Rekognition](https://docs.aws.amazon.com/rekognition/latest/dg/what-is.html) · [Lex V2](https://docs.aws.amazon.com/lexv2/latest/dg/what-is.html) · [Personalize](https://docs.aws.amazon.com/personalize/latest/dg/what-is-personalize.html) · [Personalize 준비 체크리스트](https://docs.aws.amazon.com/personalize/latest/dg/readiness-checklist.html)
- 수명 주기·가용성: [AWS Lifecycle Changes](https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html) · [Kendra](https://docs.aws.amazon.com/kendra/latest/dg/kendra-availability-change.html) · [Q Business](https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/qbusiness-availability-change.html) · [Comprehend](https://docs.aws.amazon.com/comprehend/latest/dg/comprehend-availability-change.html) · [Clarify](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html) · [Forecast](https://docs.aws.amazon.com/forecast/latest/dg/what-is-forecast.html) · [Fraud Detector](https://docs.aws.amazon.com/frauddetector/latest/ug/what-is-frauddetector.html) · [DevOps Guru](https://docs.aws.amazon.com/devops-guru/latest/userguide/devops-guru-end-of-support.html) · [컨테이너 지원 정책](https://docs.aws.amazon.com/sagemaker/latest/dg/pre-built-containers-support-policy.html)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/2-1.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
