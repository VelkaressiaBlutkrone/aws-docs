---
examGuideTaskId: mla-t1-3
certCode: MLA-C01
domain: 1
domainName: 기계 학습(ML)을 위한 데이터 준비
domainWeightPct: 28
title: 데이터 무결성·편향 관리 (지표·불균형·암호화·민감정보·품질)
coversTasks:
  - "1.3"
sources:
  - title: Pre-training Bias Metrics (SageMaker Clarify 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-data-bias.html
  - title: Pre-training Data Bias — facet·label 정의 (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-detect-data-bias.html
  - title: Transform Data (SageMaker Data Wrangler — Balance data·Split data)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html
  - title: Protecting data with server-side encryption (Amazon S3 공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
  - title: Notebook instances, SageMaker AI jobs, and Endpoints 암호화 (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-at-rest-nbi.html
  - title: Detect and process sensitive data (AWS Glue 공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/detect-PII.html
  - title: AWS Glue Data Quality (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html
  - title: Setting up training jobs to access datasets (SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 데이터 무결성·편향 관리 (지표·불균형·암호화·민감정보·품질)

> **커버하는 공식 Task** — MLA-C01 · 도메인 1 「기계 학습(ML)을 위한 데이터 준비」(28%) · **Task 1.3 데이터 무결성을 보장하고 모델링을 위한 데이터 준비** (`mla-t1-3`)
> 도메인 1의 마지막 Task입니다. **"이 데이터로 학습해도 괜찮은가"**를 네 각도에서 묻습니다 — 편향, 품질, 보안(암호화·민감정보), 그리고 학습 리소스로의 로드.

---

## ✅ 학습 목표 체크리스트

- [ ] **facet · label · positive label · group variable**을 구분하고, 사전 훈련 편향 지표 8종이 **무엇을 재는지**(개수 / 긍정 비율 / 분포 / 조건부)로 분류한다
- [ ] 클래스 불균형을 **리샘플링·SMOTE·클래스 가중치** 중 무엇으로 풀지 고른다
- [ ] 증강·합성 데이터의 **편향 승계**와 "합성 ≠ 익명화"를 설명한다
- [ ] 분할 4종(무작위·순서·층화·키)과 셔플이 왜 필요한지 안다
- [ ] S3 서버 측 암호화 4종과 SageMaker가 **KMS 키를 받는 자리**를 구분한다
- [ ] Macie·Comprehend·Comprehend Medical·Glue·DataBrew의 **입력과 결과물**을 구분한다
- [ ] Glue Data Quality와 DataBrew 품질 규칙을 **실행 위치와 판정 방식**으로 가른다
- [ ] File·FastFile·Pipe·EFS·FSx for Lustre를 데이터 특성으로 고르고 **VPC·보안 그룹 요건**을 안다

> **이 문서가 다루는 것** — 1) Clarify 상태·용어 · 2) 사전 훈련 편향 지표 8종 · 3) 지표 선택 · 4) 클래스 불균형 해소 · 5) 증강과 합성 · 6) 편향 소스 · 7) 분할·셔플·층화 · 8) 암호화 · 9) 민감 데이터 탐지·마스킹 · 10) 접근 통제와 데이터 레지던시 · 11) 데이터 품질 검증 · 12) 훈련 리소스로 데이터 로드(C01 전용)

---

## 🎯 왜 중요한가

모델이 차별적으로 작동하는 이유는 대개 알고리즘이 아니라 **학습 데이터**입니다. 특정 그룹이 과소 대표되거나(선택 편향), 레이블 자체가 과거의 편견을 담고 있으면(레이블 편향) 모델은 그것을 충실히 재현합니다. 그래서 학습 **전에** 데이터를 재는 지표가 따로 있습니다.

보안도 같은 자리에 있습니다. ML 파이프라인은 원본 데이터를 여러 서비스로 복사해 가며 처리하므로, **어디서 암호화되고 누가 키를 쥐는지**를 모르면 규정 준수가 깨집니다. 민감 정보는 학습에 들어가기 전에 **식별 → 분류 → 처리** 순으로 다뤄야 합니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **편향 지표 3분기**: 그룹 **수**가 치우쳤다 → **CI** · **긍정 레이블 비율**이 치우쳤다 → **DPL** · 하위집단마다 뒤집힌다 → **CDD**(`group_variable` 필요)
- **사전 vs 사후**: 사전 훈련 지표는 **모델 없이** 계산한다. 모델 예측이 필요하면 사후 훈련 지표다
- ⚠️ 지표의 **범위 숫자는 문서마다 달라 암기 대상이 아니다** — 무엇을 재는지로 가른다
- **불균형 해소 3수단**: **SMOTE**는 보간해 새 값을 만들고(비현실적 샘플 위험) · 오버샘플링은 **복제**하며 · 데이터를 건드리지 않으려면 **클래스 가중치**(`scale_pos_weight` 등)
- ⚠️ **합성 ≠ 익명화** — SMOTE 같은 불균형용 합성은 PII를 제거·편집하지 않는다(목적이 다르다)
- **분할**: 같은 고객이 훈련·테스트에 섞이면 안 된다 → **Split by key** · 클래스 비율 유지 → **Stratified split**(고유값 100개 이하)
- **민감 데이터는 입력으로 가른다**: **Macie는 S3 객체** · **Comprehend는 텍스트** · **Glue·DataBrew는 표 형식 열**. 편집·해시·암호화까지 하는 쪽은 Glue·DataBrew
- **PHI는 Comprehend Medical `DetectPHI`**(임상 영어 텍스트, 규정 준수 용도에는 **사람 검토 권고**). Comprehend PII의 **편집은 비동기 배치 작업만**
- **교차 계정 S3 출력 → 고객 관리형 KMS 키.** `aws/s3` AWS managed key는 키 정책을 편집할 수 없어 교차 계정 권한을 줄 수 없다
- **분산 학습 노드 간 암호화**: `EnableInterContainerTrafficEncryption` + **UDP 500·ESP 50** 허용. 품질은 Glue Data Quality가 **점수(통과 비율)**, DataBrew가 **ruleset 전체 통과/실패**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **facet** | 편향을 재는 대상 속성이 담긴 열(예: 연령대·성별). 모델이 학습에 쓰지 않는 속성이어도 지정할 수 있다 |
| **label / positive label** | 모델이 예측할 목표 / 특정 그룹에 **유리한** 결과를 뜻하는 레이블 값 |
| **facet a / facet d** | a = 편향이 유리하게 작용하는 쪽, d = 불리한 쪽 |
| **group variable** | CDD 계산에서 하위집단을 만드는 범주형 열. 이 지표에만 필요하다 |
| **DQDL** | Glue Data Quality의 규칙 언어(Data Quality Definition Language) |
| **LF-Tags** | Lake Formation의 태그 기반 접근 제어용 태그. **IAM 태그와 다르고 서로 바꿔 쓸 수 없다** |

---

## 📖 핵심 개념

### 1) SageMaker Clarify — 상태와 용어 ⚠️ {#clarify-status}

> ⚠️ **SageMaker Clarify는 신규 고객에게 닫힌 상태**입니다(기존 고객은 계속 사용, 보안·가용성 개선만 지속). 다만 **지표의 정의·공식은 그대로 유효**합니다 — 공식 '가용성 변경' 페이지는 DPL·DI·CI 같은 지표가 라벨 개수와 혼동 행렬로 계산되는 **공개된 표준 공식**이고, pandas·scikit-learn으로 직접 재현하면 Clarify 출력과 일치한다고 안내합니다. 시험 가이드(Version 1.0)는 Clarify를 명시하므로 **개념·지표는 그대로 학습 대상**입니다.

어디서 계산하나:

| 실행 위치 | 방법 |
|---|---|
| Clarify 처리 작업 | SDK `SageMakerClarifyProcessor`의 `run_pre_training_bias`. 분석 구성 JSON의 `methods.pre_training_bias.methods`에 `CI`·`DPL`·`KL`·`JS`·`LP`·`TVD`·`KS`·`CDDL` 또는 `all` |
| Data Wrangler **Bias Report** | 데이터 흐름 → Add analysis → Analysis type = Bias Report → 레이블·facet·지표 선택 (현재 Canvas에 통합) |
| 직접 계산 | pandas·scikit-learn (공식이 안내하는 대체 경로) |

- **사전 훈련 지표는 모델 출력에 의존하지 않습니다**(model-agnostic). 모델 없이 학습 전에 계산합니다. 사후 훈련 지표는 예측 레이블이 필요하고, 모델 이름을 주면 임시(shadow) 엔드포인트를 만들어 예측을 얻은 뒤 삭제합니다.
- Data Wrangler 분석은 데이터셋의 **최대 200,000행 샘플**로 생성됩니다.

### 2) 사전 훈련 편향 지표 8종 {#pretraining-metrics}

| 지표 | 무엇을 재나 | 한 줄 정의 | 기억 포인트 |
|---|---|---|---|
| **CI** (Class Imbalance) | facet 간 **구성원 수** 불균형 | (n_a − n_d) / (n_a + n_d) | **레이블과 무관**. 큰 불균형이면 재균형 고려 |
| **DPL** (Difference in Proportions of Labels) | 관측 **긍정 레이블 비율** 차이 | q_a − q_d | 0이면 demographic parity. 높은 DPL은 예측에도 반영될 수 있다 |
| **KL** | 두 facet 레이블 분포의 발산 | Σ P_a·log(P_a/P_d) | **비대칭**이고 삼각부등식을 만족하지 않아 거리(distance)가 아니다. 한쪽에 특정 레이블 샘플이 없으면 무한대 |
| **JS** | KL 기반의 **대칭** 발산 | ½[KL(P_a‖P)+KL(P_d‖P)] | KL의 무한대 문제를 피한다 |
| **LP** | 분포 간 p-노름 거리 | (Σ‖P_a−P_d‖^p)^(1/p) | 음이 아닌 값이라 **역방향 편향을 탐지하지 못한다** |
| **TVD** | L1-노름의 절반 | ½·L1(P_a,P_d) | "facet a의 몇 개 결과를 바꿔야 d와 같아지는가" |
| **KS** | 분포 간 **최대** 발산 | max\|P_a(y) − P_d(y)\| | **가장 불균형한 레이블**을 찾아 준다 |
| **CDD** (`CDDL`) | 거절 비중 − 수락 비중을 **하위집단으로 조건화** | 하위집단 크기 가중 평균 | **`group_variable` 필요**. Simpson's paradox 배제용 |

암기 틀: **CI**(수) · **DPL**(양성 비율) · **CDD**(조건화) · **분포형 5종**(KL·JS·LP·TVD·KS).

> ⚠️ 값 범위는 요약표와 개별 지표 페이지의 표기가 서로 다릅니다(요약표는 분포형을 모두 0~+∞로, 개별 페이지는 JS < ln 2, LP < √2, TVD < 1로 적습니다). **범위 숫자를 암기 대상으로 삼지 마세요** — 무엇을 재는지가 중요합니다.

### 3) 지표를 어떻게 고르나 {#metric-choice}

1. **그룹 표현이 현실을 반영하나?** → **CI**(레이블과 무관).
2. **레이블이 한 그룹에 긍정을 더 많이 주나?** → **DPL**. 하위집단 효과(Simpson's paradox)가 의심되면 **CDD**.
3. **레이블별 분포 자체를 비교**하고 싶다 → KL(고급: JS·LP·TVD·KS). 단, **이진 레이블이면 분포형 지표가 DPL과 같은 통찰**을 주므로 DPL로 충분합니다.
4. **사전 vs 사후**: 사전(CI·DPL 등)은 **원시 데이터**의 편향, 사후(DPPL·DI 등)는 **모델 예측**의 편향입니다. DPL과 DPPL을 비교하면 학습 후 편향이 증폭됐는지 볼 수 있습니다.

이름이 비슷한 다른 기능과 구분하세요 — Data Wrangler의 **Data Quality and Insights Report**(결측·이상치·불균형·target leakage)는 Bias Report와 다른 분석이고, SageMaker Debugger의 `ClassImbalance` 규칙은 **훈련 중** 점검입니다.

### 4) 클래스 불균형 해소 {#imbalance}

> 🧠 **원리** — facet 불균형이 크면 모델이 **큰 쪽에 맞춰 적합**하고 작은 쪽의 훈련 오차가 커집니다. 대응은 ① 데이터 분포를 바꾸거나(리샘플링·증강·합성) ② 손실에서 소수 클래스를 크게 반영(가중치)하는 두 갈래입니다. Clarify는 불균형을 **측정**만 하고, 조정은 Data Wrangler의 **Balance data** 같은 별도 단계가 합니다.

| 전략 | 동작 | 구현 | 주의 |
|---|---|---|---|
| Random oversampling | 소수 범주 샘플을 **복제** | Balance data | 새 값은 만들지 않는다. 이진 분류용이고 **열 벡터가 있는 데이터셋은 불가** |
| Random undersampling | 다수 범주에서 **제거** | Balance data | 데이터 양이 줄어든다 |
| **SMOTE** | 소수 샘플 사이를 **보간**해 합성 샘플 생성 | Balance data | 숫자 특징은 가중 평균, 비수치는 두 원본 중 하나에서 복사. 이웃 계산은 숫자 특징만 사용. **비현실적 샘플**이 나올 수 있다 |
| 클래스 가중치 | 손실에서 소수 클래스에 큰 가중 | XGBoost `scale_pos_weight`(기본 1, 전형값 sum(음성)/sum(양성)) · Linear Learner `positive_example_weight_mult`·`balance_multiclass_weights` | 데이터는 그대로 두고 학습만 조정 |

- **CI와 Balance data는 보는 대상이 다릅니다.** CI는 facet별 구성원 수, Balance data는 선택한 **target column의 클래스 비율**입니다. 자동 연동된다는 설명은 문서에 없습니다.

### 5) 증강과 합성 데이터 {#augmentation}

- **정의**: 기존 데이터로부터 새 데이터를 인위적으로 생성하는 과정. 성능 향상·과적합 완화·제한된 데이터 대응이 이점입니다.
- 기법: 컴퓨터 비전(자르기·뒤집기·회전·밝기·대비, random erasing), 오디오(노이즈·속도·피치), 텍스트(문장 섞기·동의어 치환·임의 단어 삽입/삭제), 생성형 AI(GAN·VAE·확산 모델).
- ⚠️ **편향 승계**: 합성 증강은 **원본과 같은 편향을 가진** 새 데이터를 만듭니다 → **증강 전에 원본의 편향을 먼저 해소**하세요.
- ⚠️ **합성 ≠ 익명화**: AWS Clean Rooms ML의 합성 데이터는 비식별화를 돕지만 **PII를 포함한 개별 값을 제거·편집·난독화하지 않습니다**(값을 샘플링하므로 비슷한 행이 있으면 원본과 똑같아 보이는 행이 생길 수 있습니다). 불균형 해소용 합성(SMOTE)과 프라이버시용 합성은 **목적이 다릅니다**.
- 합성 데이터 품질 검증: 현실성, 특정 그룹 편향 증폭 여부, 통계 속성(분포·상관) 보존, 엣지 케이스, 한계·실패 모드 문서화.

### 6) 편향 소스 — 어디서 들어오나 {#bias-sources}

| 편향 소스 | 정의 | 대응 |
|---|---|---|
| **선택 편향** | 수집한 데이터셋이 모집단을 대표하지 못함 | 그룹 표현 점검(CI) → 리샘플링·가중·합성 |
| **측정 편향** | 수집 과정의 오류 — 모범적 수집 관행 없이 모은 데이터는 부정확하거나 비대표적이다. 문서는 **한 플랫폼 사용자만으로 한 실험**을 이 분류의 예로 든다(선택 편향과 겹쳐 보이는 지점이니 문서 표현임을 기억하세요) | 학습 전 통계 분석으로 대표성 확인 |
| **레이블 편향** | 주석자가 무의식적으로 편향을 주입 | 레이블 분포 비교(DPL). 다양한 주석팀 |
| **배제 편향** | 중요한 정보를 학습 데이터에서 누락 | 대표성 점검 |
| **알고리즘 편향** | 모델 구조·설정 문제 | 데이터 준비가 아니라 모델 측 — 사후 훈련 지표 |

완화는 **전처리(학습 데이터 수정) · 훈련 중(공정성 제약) · 후처리(출력 조정)** 3단계이고, **이 Task의 범위는 전처리**입니다. 단일 지표만 쓰는 것은 안티패턴입니다.

### 7) 분할·셔플·층화 {#split}

| 기법 | 동작 | 언제·주의 |
|---|---|---|
| Randomized split | 겹치지 않는 무작위 표본으로 분할 | 큰 데이터에서는 ordered보다 느릴 수 있다 |
| Ordered split | 관측 순서대로 분할 | 기존 순서를 유지해야 할 때 |
| **Stratified split** | 입력 열의 각 값이 각 분할에 **비례해** 들어가게 | **고유값 100개 이하**여야 한다 |
| **Split by key** | 같은 키가 둘 이상의 분할에 나타나지 않게 | 같은 고객의 데이터가 훈련·테스트에 섞이는 것을 막는다 |
| 공통 옵션 | 비율 합 1, error threshold, **random seed**(재현 가능한 분할) | |
| 훈련 채널 셔플 | `ShuffleConfig(Seed)` — S3 객체·manifest 줄 순서를 셔플. Pipe 모드는 **매 에폭** 셔플 | 문서 표현상 "편향과 과적합 가능성"을 줄인다 |

- **target leakage**(타깃과 지나치게 상관돼 실제 예측 시점엔 없는 열)는 Data Wrangler의 Target Leakage 분석으로 확인합니다 — **AUC-ROC가 1이면 누수를 의심**합니다.
- 중복 행은 훈련/검증을 독립 분할로 나누는 과정을 방해하므로 먼저 제거합니다.

### 8) 암호화 — S3와 SageMaker {#encryption}

| 옵션 | 키 관리 | 핵심 |
|---|---|---|
| **SSE-S3** | S3 관리 키(AES-256) | **모든 버킷의 기본값**. 2023-01-05부터 신규 객체는 추가 비용·성능 영향 없이 자동 암호화. 기존 객체는 자동 암호화되지 않는다 |
| **SSE-KMS** | KMS 키(AWS managed `aws/s3` 또는 고객 관리형) | 키 정책·교체·CloudTrail 감사를 직접 통제. 키는 버킷과 **같은 리전의 대칭 키**. S3 Bucket Keys로 KMS 요청 비용 절감. **AWS managed key로 암호화한 객체는 교차 계정 공유 불가** → 고객 관리형 키 필요 |
| **DSSE-KMS** | KMS 키 | **AES-256 두 계층**을 서버 측에서 적용(다층 암호화 요구 대응) |
| **SSE-C** | 고객이 **요청마다** 키 제공 | 공유가 비실용적. ⚠️ 2026-04부터 신규 범용 버킷 등에서 **기본 차단**(차단 중 SSE-C 요청은 403) |

- 네 옵션은 **상호 배타적**입니다. 버킷 기본 설정으로 바꿀 수 있는 것은 SSE-KMS·DSSE-KMS입니다.
- **전송 중**: 버킷 정책에서 `aws:SecureTransport`가 false인 요청을 Deny하면 HTTPS만 허용됩니다.

SageMaker에서 KMS 키를 주는 자리:

| 대상 | 파라미터 |
|---|---|
| 학습 작업 **볼륨** | `ResourceConfig.VolumeKmsKeyId` (Nitro 로컬 스토리지 인스턴스는 지정 불가) |
| 학습 **출력**(S3 모델 아티팩트) | `OutputDataConfig.KmsKeyId` — 실행 역할에 `kms:Encrypt` 필요 |
| 처리 작업 볼륨·출력 | `ProcessingResources.ClusterConfig.VolumeKmsKeyId` · `ProcessingOutputConfig.KmsKeyId` |
| 엔드포인트 | `CreateEndpointConfig.KmsKeyId` |
| Studio 도메인(EFS) | `CreateDomain.KmsKeyId` |
| **컨테이너 간 트래픽**(분산 학습) | `EnableInterContainerTrafficEncryption=True` — 보안 그룹에 자기 자신을 소스로 하는 **UDP 500·ESP 50** 규칙 필요 |

- **KMS 키를 주지 않으면** 작업 볼륨은 일회용(transient) 키로 암호화되고 그 키는 즉시 폐기됩니다.
- SSE-KMS로 암호화된 입력을 읽으려면 실행 역할에 **`kms:Decrypt`**, 출력 쓰기에는 **`kms:GenerateDataKey`**가 필요하고, 작업 볼륨에 KMS 키를 쓰면 **`kms:CreateGrant`**도 필요합니다.
- 출력 버킷이 **다른 계정**이면 `aws/s3` AWS managed key는 키 정책을 편집할 수 없어 교차 계정 권한을 줄 수 없습니다 → **고객 관리형 키**를 지정합니다.
- 컨테이너 간 암호화는 **분산 딥러닝에서 훈련 시간이 늘 수 있고** 단일 인스턴스 작업에는 영향이 없습니다.

### 9) 민감 데이터 — 탐지·분류·마스킹 {#sensitive-data}

> 🧠 **원리** — ML Lens는 민감 데이터를 **식별 → 분류 → 처리**(제거·마스킹·토큰화) 순으로 다루라고 합니다. 서비스마다 **입력**(S3 객체 / 텍스트 / 표 형식 열)과 **결과물**(탐지만 / 편집 / 해시·암호화)이 다릅니다.

| 서비스 | 입력 | 하는 일 |
|---|---|---|
| **Amazon Macie** | **S3 객체** | ML과 패턴 매칭(managed data identifiers)으로 민감 데이터를 **탐지·보고**. 정규식 기반 사용자 정의 식별자 가능. 방식은 자동 민감 데이터 검색과 검색 작업 2가지 |
| **Amazon Comprehend**(PII) | **영어·스페인어 텍스트** | PII 엔터티 위치 파악 또는 **편집(redaction)**. ⚠️ **편집은 비동기 배치 작업만** 가능(`Mode=ONLY_REDACTION`, `MaskMode`는 엔터티 타입 치환 또는 마스크 문자) |
| **Comprehend Medical**(PHI) | **임상 텍스트(영어)** | `DetectPHI`로 PHI 탐지. 신뢰 점수를 주며 규정 준수 용도에는 사람 검토 권고 |
| **AWS Glue — Detect Sensitive Data** | ETL 중인 **표 형식 데이터** | 탐지 + 처리: Redact, Partially redact, **SHA-256 해시**, 탐지 결과 열 추가. 스캔은 **셀 전수** 또는 **행 샘플링**(비용 절감) |
| **AWS Glue DataBrew** | 표 형식 데이터 | 프로파일 작업에서 PII 탐지 + 레시피로 마스킹·해시·암호화 |

- **DataBrew 마스킹·익명화 8가지**: Substitution · Shuffling · **결정적 암호화**(같은 값 → 항상 같은 암호문) · **확률적 암호화**(적용할 때마다 다른 암호문) · Decryption · Nulling out · Masking out · Hashing.
- **마스킹 vs 해시 vs 암호화**: 마스킹은 가리거나 대체, 해시는 단방향, 암호화는 키로 **가역**입니다. Glue에서는 **한 열에 편집과 해시를 함께 쓸 수 없습니다.**

### 10) 접근 통제와 데이터 레지던시 {#access-residency}

- **LF-TBAC**: LF-Tags를 Data Catalog 리소스에 붙이고 주체에게 **태그 값에 대한 권한**을 줍니다. 리소스가 많고 정책 관리가 번거로운 환경에 권장됩니다. ⚠️ **LF-Tags와 IAM 태그는 다르고 서로 바꿔 쓸 수 없습니다.** LF-Tags는 계층적이라 DB에 붙이면 테이블이, 테이블에 붙이면 열이 상속합니다.
- **데이터 필터**: 열·행·셀 수준 보안을 구현합니다(모든 열 + 행 표현식 = 행 수준, 특정 열 + 모든 행 = 열 수준, 둘 다 = 셀 수준). **값을 변환하는 기능이 아니라 노출을 제한하는 기능**입니다.
- **리전 제한**: `aws:RequestedRegion` 조건 키로 지정 리전 밖 작업을 Deny합니다. **IAM·CloudFront 같은 글로벌 서비스는 `NotAction`으로 제외**해야 요청이 막히지 않습니다.
- ML 맥락의 리전 규칙: 훈련 데이터는 훈련 작업과 같은 리전, SSE-KMS 키는 버킷과 같은 리전, Comprehend 입력·출력 버킷은 API와 같은 리전.

### 11) 데이터 품질 검증 {#data-quality}

| 항목 | **AWS Glue Data Quality** | **DataBrew 품질 규칙 + 프로파일 작업** |
|---|---|---|
| 성격 | 서버리스, 오픈소스 **Deequ** 기반 | 코딩 없는 시각적 준비 도구 |
| 규칙 | **DQDL**(25개 이상 기본 규칙, 규칙 추천 지원) | 콘솔에서 ruleset 정의(AND/OR 결합) |
| 판정 | **데이터 품질 점수 = 통과한 규칙의 비율** | 기준 하나라도 미충족이면 **ruleset 전체 실패**(SUCCEEDED/FAILED/ERROR) |
| 실행 위치 | **Data Catalog** 또는 **ETL 작업** | **프로파일 작업**에 ruleset 연결 → 보고서를 S3로 |
| ML 기능 | **이상 탐지**(최소 3개 데이터 포인트), 동적 규칙(`last()`, **ETL 전용**) | 서술 없음 |
| 불량 레코드 식별 | **ETL 작업에서만** 가능 | 규칙별 결과 확인 |
| 제약 | 중첩·리스트형 데이터 평가 불가, ruleset당 규칙 2,000개 | 배열·구조체 열에는 규칙 정의 불가 |

고르는 기준: 규칙을 **코드로 관리하고 파이프라인에 게이트**를 넣는다 → Glue Data Quality. **이상 탐지·동적 임계값** → Glue Data Quality. **불량 레코드 행 단위 격리** → Glue Data Quality의 ETL. **코딩 없이 시각적으로** → DataBrew. SageMaker 안에서 모델링 직전 점검 → Data Wrangler의 Data Quality and Insights Report.

### 12) 훈련 리소스로 데이터 로드 (C01 전용) {#training-load}

> 📍 이 Skill은 **MLA-C02에서 삭제**됐습니다(C01에서만 묻습니다). 입력 모드의 정본 설명은 Task 1.1 문서 「데이터 수집·저장」 3) 입력 모드에 있고, 여기서는 **무결성·보안 관점의 요건**(VPC·AZ·보안 그룹·분배)을 중심으로 봅니다.

| 소스·모드 | 유리한 상황 | 제약 |
|---|---|---|
| S3 **File**(기본) | 작은 데이터셋(약 50–100 GB 미만) | 전체가 인스턴스 스토리지에 들어가야 하고, **Spot 중단 후 재개하면 다시 다운로드** |
| S3 **FastFile** | 큰 파일(50 MB 초과) 중심의 큰 데이터셋 | **S3 prefix만**, 순차 읽기 최적, CloudTrail 비용 증가 가능 |
| S3 **Pipe** | 디스크를 아껴야 할 때 | 파이프 하나당 한 프로세스. 관리형 샤딩·셔플 지원 |
| **FSx for Lustre** | File엔 너무 크거나, 작은 파일이 많거나, 무작위 읽기 | **VPC 필수·단일 AZ**. S3 연결 시 **지연 로딩 콜드 스타트** |
| **EFS** | 데이터가 **이미 EFS에 있을 때** | VPC 필수 |

- 입력 채널은 `FileSystemDataSource`에 `FileSystemId`·`FileSystemType`(`EFS`/`FSxLustre`)·`DirectoryPath`·`FileSystemAccessMode`를 **모두** 지정합니다. FSx의 `DirectoryPath`는 **`MountName`으로 시작**해야 합니다.
- 보안 그룹: **FSx for Lustre는 TCP 988과 1018–1023**, **EFS는 NFS TCP 2049**를 허용해야 합니다. 인터넷이 없는 VPC에서 S3를 읽으려면 **S3 VPC 엔드포인트(Gateway)**가 필요합니다.
- 분산 학습의 분배: `FullyReplicated`(전체 복제) vs `ShardedByS3Key`(인스턴스당 약 1/n). ⚠️ **S3 객체 수보다 인스턴스가 많으면** 일부 노드는 데이터를 못 받고 비용만 냅니다.

---

## ✍️ 시험 포인트

- "그룹 **수**가 치우쳤다" → **CI**. "**긍정 레이블 비율**이 치우쳤다" → **DPL**. "하위집단마다 뒤집힌다" → **CDD**(`group_variable`).
- 사전 훈련 지표는 **모델 없이** 계산합니다. 모델 예측이 필요하면 사후 훈련 지표입니다.
- SMOTE는 **보간해 새 값을 만들고**, 오버샘플링은 **복제**합니다. 데이터를 건드리지 않으려면 **클래스 가중치**(`scale_pos_weight` 등).
- 같은 고객이 훈련·테스트에 섞이면 안 된다 → **Split by key**. 클래스 비율을 유지해야 한다 → **Stratified split**(고유값 100개 이하).
- **Macie는 S3 객체, Comprehend는 텍스트, Glue·DataBrew는 표 형식 열**입니다. 편집·해시·암호화까지 하는 쪽은 Glue·DataBrew입니다.
- 교차 계정 S3 출력 → **고객 관리형 KMS 키**. 분산 학습 노드 간 암호화 → `EnableInterContainerTrafficEncryption` + **UDP 500·ESP 50**.
- Glue Data Quality는 **점수(통과 비율)**, DataBrew는 **ruleset 전체 통과/실패**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| CI가 레이블 편향까지 잡아 준다고 본다 | CI는 **레이블과 무관한** 구성원 수 불균형이다. 레이블 비율은 **DPL** |
| KL을 거리(distance)로 본다 | KL은 **비대칭**이고 삼각부등식을 만족하지 않는다. 대칭이 필요하면 **JS** |
| LP로 역방향 편향을 찾으려 한다 | LP는 음이 아닌 값이라 **방향을 구분하지 못한다** |
| 불균형을 Clarify가 고쳐 준다고 본다 | Clarify는 **측정**만 한다. 조정은 Balance data 같은 별도 단계 |
| SMOTE를 쓰면 항상 성능이 오른다고 본다 | 비현실적 합성 샘플이 생길 수 있고, 과도한 오버샘플링은 일부 지표를 떨어뜨릴 수 있다 |
| 증강으로 편향을 줄이려 한다 | 증강은 **원본의 편향을 승계**한다 — 편향 해소가 **먼저** |
| 합성 데이터를 익명화로 본다 | 합성은 개별 값을 제거·편집하지 않는다. 원본과 똑같아 보이는 행이 나올 수 있다 |
| SSE-S3 기본값이 **기존 객체**까지 암호화한다고 본다 | 자동 암호화 대상은 **신규 업로드**다. 기존 객체는 재암호화(Batch Operations Copy)가 필요 |
| 교차 계정 출력에 `aws/s3` 키를 쓴다 | AWS managed key는 키 정책을 편집할 수 없어 교차 계정 권한을 줄 수 없다 |
| Comprehend로 실시간 편집을 기대한다 | **편집(redaction)은 비동기 배치 작업만** 가능하다 |
| Lake Formation 데이터 필터가 값을 마스킹한다고 본다 | 필터는 **노출을 제한**한다. 값 변환은 DataBrew·Glue 쪽 |
| 리전 Deny 정책에 글로벌 서비스를 그대로 둔다 | IAM·CloudFront 등은 **`NotAction`으로 제외**해야 한다 |
| 인스턴스를 S3 객체 수보다 많이 띄운다 | `ShardedByS3Key`에서 **일부 노드는 데이터를 못 받는다** |

---

## 🧪 자가 점검

**Q1.** 연령대 열의 구성 비율이 현실과 다른지 보려면 어떤 지표를, 승인률이 연령대별로 다른지 보려면 어떤 지표를 쓰는가? (→ 2) 지표 8종)

<details><summary>정답 보기</summary>

구성 비율은 **CI(Class Imbalance)** — 그룹의 **수**가 치우쳤는지를 봅니다. 승인률 차이는 **DPL(Difference in Proportions of Labels)** — **긍정 레이블의 비율**이 그룹 간에 다른지를 봅니다. 둘 다 **모델 없이** 계산하는 사전 훈련 지표입니다.
</details>

**Q2.** 하위집단별로 보면 격차가 반대로 나타나는 현상을 배제하려면 어떤 지표와 어떤 설정이 필요한가? (→ 2) CDD)

<details><summary>정답 보기</summary>

**CDD(Conditional Demographic Disparity)**를 쓰고 **`group_variable`로 하위집단을 지정**해야 합니다. 전체에서는 한쪽이 유리해 보이는데 하위집단마다 방향이 뒤집히는 경우(심슨의 역설형)를 잡아내려면 그 조건 변수가 필요합니다 — 지정하지 않으면 전체 집계만 보게 됩니다.
</details>

**Q3.** 소수 클래스를 복제하지 않고 늘리려면 어떤 연산자를 쓰고, 그 방식의 위험은? (→ 4) 불균형 해소)

<details><summary>정답 보기</summary>

**SMOTE**(Data Wrangler의 Balance data)입니다. 소수 샘플 **사이를 보간**해 합성 샘플을 만들며, 숫자 특징은 가중 평균을 쓰고 비수치는 두 원본 중 하나에서 복사하며 이웃 계산에는 숫자 특징만 씁니다. 위험은 **비현실적 샘플**이 생길 수 있다는 것입니다. ⚠️ 또 **합성은 익명화가 아닙니다** — 프라이버시 목적의 합성과 불균형 해소용 합성은 목적이 다릅니다. 데이터를 아예 건드리지 않으려면 **클래스 가중치**로 갑니다.
</details>

**Q4.** 학습 출력이 다른 계정의 S3 버킷으로 나간다. 어떤 KMS 키를 써야 하고 왜인가? (→ 8) 암호화)

<details><summary>정답 보기</summary>

**고객 관리형 KMS 키**입니다. `aws/s3` 같은 AWS managed key는 **키 정책을 편집할 수 없어 교차 계정 권한을 줄 수 없고**, 그 키로 암호화한 객체는 교차 계정 공유가 되지 않습니다. 키는 버킷과 **같은 리전의 대칭 키**여야 하며, KMS 요청 비용은 S3 Bucket Keys로 줄일 수 있습니다.
</details>

**Q5.** 임상 노트에서 PHI를 찾아 가려야 한다. 어떤 서비스로 탐지하고, 편집은 어떤 제약이 있는가? (→ 9) 민감 데이터)

<details><summary>정답 보기</summary>

탐지는 **Comprehend Medical의 `DetectPHI`**(임상 영어 텍스트)로 하고 신뢰 점수를 돌려주며, 규정 준수 용도라면 **사람 검토가 권고**됩니다. 편집이 필요하면 **Amazon Comprehend의 PII 편집**을 쓰는데 ⚠️ **비동기 배치 작업만** 가능합니다(`Mode=ONLY_REDACTION`). 표 형식 열이라면 Glue·DataBrew가 편집·해시까지 하지만 **한 열에 편집과 해시를 함께 쓸 수는 없습니다.**
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task의 변화**이며 C01 시험 범위는 아닙니다.

- **C02 대응 Task**: 1.3 「데이터 품질을 검증하고 편향을 관리합니다」
- **추가된 항목 3개**
  - `1.3.4` 숫자·텍스트·이미지 자산에 편향 지표를 적용해 **멀티모달 데이터 분포 최적화**
  - `1.3.6` **AI 학습 데이터 무결성 검증**(프롬프트-응답 쌍 검증, 콘텐츠 안전 검사)
  - `1.3.7` 데이터 정리(이상값 감지, 결측 대체, 중복 제거)
- **삭제된 항목 1개** — C01에서만 묻습니다
  - **모델 훈련 리소스에 로드할 데이터 구성**(예: Amazon EFS, Amazon FSx) → 이 문서의 12)

출처: MLA-C01 및 MLA-C02 비교 (한국어 공식) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html · 조회일 2026-10-17

---

### 📌 출처

1. Pre-training Bias Metrics — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-data-bias.html
2. Pre-training Data Bias(용어) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-detect-data-bias.html
3. CI — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-bias-metric-class-imbalance.html
4. DPL — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-true-label-imbalance.html
5. KL — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-kl-divergence.html
6. JS — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-jensen-shannon-divergence.html
7. LP — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-lp-norm.html
8. TVD — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-total-variation-distance.html
9. KS — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-kolmogorov-smirnov.html
10. CDD — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-cddl.html
11. Clarify 가용성 변경 — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html
12. Transform Data (Data Wrangler — Balance data·Split data) — https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html
13. EDA(Canvas) — https://docs.aws.amazon.com/sagemaker/latest/dg/canvas-analyses.html
14. XGBoost 하이퍼파라미터 — https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost_hyperparameters.html
15. Linear learner 하이퍼파라미터 — https://docs.aws.amazon.com/sagemaker/latest/dg/ll_hyperparameters.html
16. Channel(ShuffleConfig) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_Channel.html
17. What is Data Augmentation? — https://aws.amazon.com/what-is/data-augmentation/
18. 합성 데이터 생성 고려사항(Clean Rooms ML) — https://docs.aws.amazon.com/clean-rooms/latest/userguide/considerations-for-data-generation.html
19. RAIDP02-BP04 — https://docs.aws.amazon.com/wellarchitected/latest/responsible-ai-lens/raidp02-bp04.html
20. MLREL03-BP04 — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlrel03-bp04.html
21. S3 서버 측 암호화 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
22. SSE-KMS — https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html
23. SSE-C — https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerSideEncryptionCustomerKeys.html
24. SageMaker 저장 시 암호화 — https://docs.aws.amazon.com/sagemaker/latest/dg/encryption-at-rest-nbi.html
25. 분산 학습 통신 암호화 — https://docs.aws.amazon.com/sagemaker/latest/dg/train-encrypt.html
26. KMS 키 정책 — https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
27. Amazon Macie — https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
28. Comprehend PII — https://docs.aws.amazon.com/comprehend/latest/dg/pii.html
29. PII 편집(비동기) — https://docs.aws.amazon.com/comprehend/latest/dg/redact-api-pii.html
30. Comprehend Medical DetectPHI — https://docs.aws.amazon.com/comprehend-medical/latest/dev/textanalysis-phi.html
31. Glue 민감 데이터 탐지 — https://docs.aws.amazon.com/glue/latest/dg/detect-PII.html
32. DataBrew PII 처리 — https://docs.aws.amazon.com/databrew/latest/dg/personal-information-protection.html
33. Lake Formation 태그 기반 접근 제어 — https://docs.aws.amazon.com/lake-formation/latest/dg/tag-based-access-control.html
34. 데이터 필터·셀 수준 보안 — https://docs.aws.amazon.com/lake-formation/latest/dg/data-filtering.html
35. 리전 기반 Deny(IAM) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_deny-requested-region.html
36. AWS Glue Data Quality — https://docs.aws.amazon.com/glue/latest/dg/glue-data-quality.html
37. DQDL 레퍼런스 — https://docs.aws.amazon.com/glue/latest/dg/dqdl.html
38. Glue 이상 탐지 — https://docs.aws.amazon.com/glue/latest/dg/data-quality-anomaly-detection.html
39. DataBrew 품질 검증 — https://docs.aws.amazon.com/databrew/latest/dg/profile.data-quality-rules.html
40. 훈련 데이터 접근 설정 — https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data.html
41. FSx for Lustre 입력 채널 — https://docs.aws.amazon.com/sagemaker/latest/dg/model-access-training-data-fsx.html
42. FileSystemDataSource — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_FileSystemDataSource.html
43. 훈련 작업 VPC 접근 — https://docs.aws.amazon.com/sagemaker/latest/dg/train-vpc.html
44. S3DataSource — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_S3DataSource.html

조사 노트: `docs/content-research/MLA-C01/tasks/1-3.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
