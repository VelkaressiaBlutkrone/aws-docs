---
examGuideTaskId: mla-t4-1
certCode: MLA-C01
domain: 4
domainName: ML 솔루션 모니터링·유지 관리·보안
domainWeightPct: 24
title: 모델 추론 모니터링 (드리프트·Model Monitor·CloudWatch·EventBridge·A/B)
coversTasks:
  - "4.1"
sources:
  - title: Data and model quality monitoring with Amazon SageMaker Model Monitor (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor.html
  - title: Amazon SageMaker Model Monitor availability change (공식 공지)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html
  - title: Capture data from real-time endpoint (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-data-capture-endpoint.html
  - title: Schema for Constraints (constraints.json file) (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-byoc-constraints.html
  - title: Schema for Violations (constraint_violations.json file) (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-interpreting-violations.html
  - title: ScheduleConfig (SageMaker API Reference)
    url: https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ScheduleConfig.html
  - title: Ingest Ground Truth labels and merge them with predictions (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality-merge.html
  - title: Bias drift for models in production (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-bias-drift.html
  - title: Feature attribution drift for models in production (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-feature-attribution-drift.html
  - title: Amazon SageMaker AI metrics in Amazon CloudWatch (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html
  - title: Events that Amazon SageMaker AI sends to Amazon EventBridge (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/automating-sagemaker-with-eventbridge.html
  - title: Testing models with production variants (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-ab-testing.html
  - title: MLPERF06-BP04 Monitor, detect, and handle model performance degradation (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp04.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 모델 추론 모니터링 (드리프트·Model Monitor·CloudWatch·EventBridge·A/B)

> **커버하는 공식 Task** — MLA-C01 · 도메인 4 「ML 솔루션 모니터링, 유지 관리 및 보안」(24%) · **Task 4.1 모델 추론 모니터링** (`mla-t4-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 3이 "어떻게 배포하고 자동으로 돌리는가"였다면, 4.1은 **"배포된 모델이 조용히 나빠지는 것을 어떻게 알아채는가"** 입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 데이터 드리프트와 개념 드리프트를 **무엇이 변하는가**로 가르고, 왜 개념 드리프트는 입력 통계만으로 못 잡는지 설명한다
- [ ] Model Monitor의 **4단계 흐름**(캡처 → 기준선 → 스케줄 → 보고서)과 각 단계가 없을 때 생기는 증상을 짚는다
- [ ] 모니터 유형 **4종**을 증상에서 역으로 고르고, **정답 라벨이 필요한 유형**이 어느 것인지 안다
- [ ] 위반 6종과 `monitoring_config` 임계의 기본값을 알고, `baseline_drift_check`가 **무엇을 계산한 값**인지 말한다
- [ ] 정답 라벨 병합의 매칭 키와 경로 규칙, **오프셋이 분석 창을 어떻게 옮기는지** 계산한다
- [ ] 편향 드리프트의 **신뢰구간 판정**과 기여도 드리프트의 **NDCG 0.90** 기준을 구분한다
- [ ] 드리프트·운영 지표·상태 변경을 각각 Model Monitor · CloudWatch 경보 · EventBridge로 가르고, 지연·오류 지표의 측정 구간을 읽는다
- [ ] 프로덕션 변형 가중치로 A/B를 구성하고 섀도·블루/그린과 **호출자가 받는 응답**으로 구분한다

> **이 문서가 다루는 것** — 1) 드리프트의 세 층 · 2) ⚠️ 서비스 상태 · 3) Model Monitor 흐름과 제약 · 4) 모니터 유형 4종 · 5) 데이터 캡처 · 6) 기준선과 위반 · 7) 모니터링 스케줄 · 8) 정답 병합과 오프셋 · 9) 편향·기여도 드리프트 · 10) CloudWatch 지표·경보·로그 · 11) 오류·지연 지표 읽기 · 12) EventBridge 상태 변경 · 13) A/B 테스트 · 14) 감시 수단 고르기 · 15) ML Lens 모범 사례 · 16) 모니터링 비용

---

## 🎯 왜 중요한가

배포까지는 성공/실패가 눈에 보입니다. 모니터링에서 다루는 고장은 다릅니다 — **엔드포인트는 200을 반환하고 지연도 정상인데 예측이 틀리기 시작합니다.** 코드가 바뀌지 않았는데 세상이 바뀐 것입니다.

그래서 4.1의 문항은 거의 전부 **"이 증상을 어느 수단이 잡는가"** 형태입니다. 세 수단이 보기에 함께 나옵니다.

- **Model Monitor** — 기준선과 비교하는 통계적 드리프트 감시
- **CloudWatch 지표·경보** — 운영 지표의 임계 이탈
- **EventBridge 이벤트** — 리소스 상태 변경(성공·실패)

"파이프라인이 실패하면 알림"에 Model Monitor를 고르거나, "입력 분포가 변했다"에 CloudWatch 경보를 고르면 틀립니다. 두 번째 축은 **정답 라벨이 필요한가**입니다. 라벨 없이 잡을 수 있는 것은 입력 쪽 변화뿐이고, 정확도가 떨어졌다는 판정에는 반드시 라벨이 필요합니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **감시 수단 3분할**: 통계적 드리프트 → **Model Monitor** · 수치 임계 → **CloudWatch 경보** · 상태 변경(실패) → **EventBridge 이벤트**. 원인 조사는 **CloudWatch Logs**
- **드리프트 2종**: 데이터 드리프트 = **입력 분포** 변화 · 개념 드리프트 = **입력과 타깃의 관계** 변화. 개념 드리프트는 입력 분포가 그대로일 수 있어 **정답 라벨을 쓰는 모델 품질 모니터링**으로 잡는다
- **모니터 4종과 라벨 필요 여부**: 데이터 품질(**라벨 불필요**) · 모델 품질(**라벨 필요**) · 편향 드리프트(**정답 데이터 필요**) · 특성 기여도 드리프트(SHAP 기준선)
- **흐름은 4단계**: 데이터 캡처 → 학습 데이터로 **기준선** → **모니터링 스케줄** → 보고서·CloudWatch. ⚠️ **캡처만 켜면 위반 보고서는 나오지 않는다**
- ⚠️ **제약 3개가 함정**: 지표 계산은 **표 형식(tabular)만** · **멀티모델 엔드포인트 미지원** · 캡처는 디스크 사용률이 높으면 멈춘다(**75% 미만** 유지)
- **위반 6종**: `data_type_check` · `completeness_check` · `baseline_drift_check` · `missing_column_check` · `extra_column_check` · `categorical_values_check`. 분포 임계 `comparison_threshold` **기본 0.1**(두 CDF의 최대 절대 차이 = L∞)
- **스케줄**: 문서가 나열한 반복 표현식의 최단 주기는 **매시간** `cron(0 * ? * * *)`, `NOW`는 1회 즉시. 실행이 **0~20분 늦을 수 있고** 분석 창은 **24시간 초과 불가**
- **오프셋 계산**: 분석 창 = [실행 시각 − `StartTimeOffset`, 실행 시각 − `EndTimeOffset`]. `-P8D`/`-P1D`로 2020-01-09T13:00에 돌면 **2020-01-01T13:00 ~ 2020-01-08T13:00**
- **판정 기준 두 개**: 편향 드리프트는 허용 범위와 **Normal Bootstrap 신뢰구간이 서로소**일 때 경보 · 기여도 드리프트는 전역 SHAP 순위의 **NDCG 0.90 미만**
- **A/B는 변형 가중치**(`InitialVariantWeight`, **미지정 시 1.0**, 변형 **1~10개**). 비율 변경은 엔드포인트를 새로 만들지 않고 **`UpdateEndpointWeightsAndCapacities`**. `TargetVariant`는 **가중치 분배를 재정의**한다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **기준선(baseline)** | 학습에 쓴 데이터로 계산한 통계와 그로부터 제안된 제약. 모든 드리프트 검사는 이것과 비교한다 |
| **데이터 캡처** | 엔드포인트의 요청·응답(또는 배치 변환의 입출력)을 S3에 남기는 기능. Model Monitor와 **독립적으로도** 쓸 수 있다 |
| **모니터링 스케줄** | 캡처 데이터를 기준선과 비교하는 **처리 작업(processing job)** 을 주기 실행하는 일정 |
| **위반(violation)** | 현재 데이터가 기준선 제약을 벗어난 항목. `constraint_violations.json`에 기록된다 |
| **ground truth 라벨** | 모델이 맞히려는 실제 정답. 사용자가 JSON Lines로 S3에 올린다(라벨링 서비스와 이름만 같다) |
| **프로덕션 변형(production variant)** | 한 엔드포인트 안에 공존하는 모델·인스턴스 구성 단위. A/B의 기본 단위다 |
| **NDCG** | 정규화된 할인 누적 이득. 전역 SHAP 특성 순위가 기준선과 얼마나 같은지를 [0, 1]로 재는 값 |
| **baking period** | 배포 가드레일이 전환 후 CloudWatch 경보를 지켜보는 대기 기간. 이때 경보가 울리면 롤백한다 |

---

## 📖 핵심 개념

### 1) 드리프트의 세 층 — 용어가 자료마다 다르다 {#drift-types}

공식 문서는 드리프트를 **한 가지 분류로 쓰지 않습니다.** 보기에서 섞이는 이유가 여기 있습니다.

| 출처 | 쓰는 분류 |
|---|---|
| Machine Learning Lens | **데이터 드리프트 · 개념 드리프트** 2종 |
| Model Monitor | 감시 대상 기준으로 **데이터 품질 · 모델 품질 · 편향 · 특성 기여도** 4종 |
| AWS 블로그 | 데이터 드리프트를 **공변량 이동 · 레이블 이동 · 개념 이동** 3종으로 세분 |

**정의**

| 용어 | 공식 정의 요지 | 무엇이 변하나 |
|---|---|---|
| **데이터 드리프트** | 학습에 쓴 데이터와 비교한 데이터 분포의 유의미한 변화. 모델 성능 저하로 이어질 수 있다 | 입력(특성) 분포 |
| **개념 드리프트** | 타깃 변수의 성질이 바뀜. 입력과 타깃 변수 **사이의 관계** 변화 | 입력과 타깃의 관계 |
| 공변량 이동 (블로그) | 입력 분포는 변하지만 입력이 주어졌을 때 출력의 조건부 분포는 그대로 | 입력 분포 |
| 레이블 이동 (블로그) | 클래스 변수(타깃 레이블) 분포의 변화. 예: 학습 세트의 스팸 비율이 50%였는데 실제로는 이메일의 10%만 비스팸 | 레이블 분포 |
| 개념 이동 (블로그) | 분포가 아니라 입력과 타깃 사이 관계가 시간에 따라 변함 | 입력-출력 관계 |

> 🧠 원리: Model Monitor는 **학습 데이터로 만든 기준선의 통계·제약과 프로덕션 데이터를 비교**하는 방식이라 입력 분포 변화를 직접 잡습니다. 반대로 개념 드리프트는 **입력 분포가 그대로여도 일어날 수 있어** 입력에 대한 통계 검정만으로는 잡기 어렵습니다. 그래서 예측을 정답 라벨과 직접 비교하는 모델 품질 모니터링이 성능 저하를 측정하는 수단이 됩니다. 공식 가이던스는 하류 비즈니스 지표·사용자 피드백을 함께 보라고도 합니다.

⚠️ **"예측 드리프트"는 정답 근거로 쓰지 않습니다.** Model Monitor 문서와 ML Lens에 별도 정의가 없고, 가장 가까운 공식 계열 문장은 블로그의 레이블 이동입니다.

⚠️ **내장 척도의 종류를 외우지 마세요.** ML Lens는 Model Monitor가 KL 발산·Jensen-Shannon 발산·PSI를 지원한다고 쓰지만, `constraints.json` 스키마 문서는 L∞(`linf_simple`·`linf_robust`)와 범주형 `LInfinity`·`ChiSquared`만 나열합니다. 두 문서가 어긋나므로 **척도의 종류·개수를 정답 근거로 삼는 문항은 나오기 어렵습니다.** 대신 6)의 임계 기본값을 외웁니다.

참고로 AWS 가이던스는 KS 같은 흔한 드리프트 척도가 **LLM 임베딩처럼 다차원 데이터에서는 덜 효과적**이라고 지적합니다(생성형 AI 맥락).

### 2) ⚠️ 서비스 상태 — Model Monitor와 Clarify {#monitor-service-status}

가이드(Version 1.0)의 SK1·SK3은 Model Monitor와 Clarify를 "예"로 듭니다. 두 서비스는 조회일(2026-10-17) 현재 **신규 고객에게 닫혀 있습니다.** 시험 범위는 가이드 기준이므로 내용은 그대로 다루고 상태만 병기합니다.

| 대상 | 현재 상태 | 공식 문서가 안내하는 대체 경로 |
|---|---|---|
| ⚠️ Model Monitor | 신규 고객 불가. 기존 고객은 정상 사용, 보안·가용성 개선은 계속하지만 **신기능 계획 없음** | 오픈소스 SageMaker AI 모니터링 솔루션 + Amazon QuickSight 거버넌스 대시보드 + CloudWatch |
| ⚠️ Clarify | 신규 고객 불가. 기존 고객 정상 사용, 신기능 계획 없음 | pandas·scikit-learn으로 직접 계산하는 표준화 편향 지표, SHAP 라이브러리, SageMaker AI MLflow, CloudWatch, QuickSight |
| ⚠️ Amazon A2I | 2026-07 유지보수 모드, 신규 고객 불가. ML Lens의 휴먼 인 더 루프 모니터링이 권하는 서비스 | - |
| ⚠️ SageMaker Ground Truth | 신규 고객 불가. 모델 품질의 "ground truth 라벨"과 **이름만 같다**(8), 짝 7 참조) | - |

**기능 묶음 공지** — 2026-07-30부터 신규 고객 불가 대상에 Mechanical Turk, Ground Truth, Augmented AI, Studio Lab, Model Monitor, Clarify, Debugger, Role Manager, Geospatial, Profiler가 나열됩니다. 이 공지는 **그 밖의 SageMaker AI 기능의 가용성에 영향을 주지 않습니다.**

**기능별 대체 경로**

| Model Monitor 기능 | 공식 문서가 제시한 대체 |
|---|---|
| 데이터 품질 | Evidently AI `DataDriftPreset`(전 특성 PSI·KS)과 `DataSummaryPreset`(결측·이상값·무결성). 경량 대안은 **CloudWatch 커스텀 지표 + 이상 탐지 경보** |
| 모델 품질 | Evidently AI `ClassificationPreset`(ROC-AUC·precision·recall·F1·혼동 행렬). 지연된 정답은 **추론 ID로 예측과 맞춤** |
| 편향 드리프트 | 보호 속성 세그먼트별 지표를 계산해 학습 기준선과 비교하고 임계 초과 시 SNS 알림 |
| 특성 기여도 드리프트 | **SHAP 라이브러리 직접 사용**(Clarify가 내부적으로 쓰는 엔진) |
| Pipelines의 `ClarifyCheckStep` | 표준화 지표·SHAP을 실행하는 **`ProcessingStep`으로 교체** |

**명칭.** Amazon SageMaker는 2024-12-03에 **Amazon SageMaker AI**로 바뀌었습니다. `sagemaker` API 네임스페이스, CLI 명령, `AmazonSageMaker` 접두 관리형 정책, `AWS::SageMaker` CloudFormation 리소스, 문서 URL의 `sagemaker`는 **그대로**입니다. 같은 날 나온 차세대 "Amazon SageMaker"(데이터·분석·AI 통합 플랫폼)는 별개 이름입니다.

> ℹ️ 서비스 수명 주기 용어 전반과 중단 서비스 목록은 `mla-t2-1` 8) 서비스 상태가 정본입니다. 여기서는 **모니터링 관련분만** 추렸습니다.

### 3) Model Monitor의 흐름과 제약 {#model-monitor-flow}

Model Monitor는 프로덕션 모델의 품질을 모니터링하고 규칙으로 드리프트를 감지해 **편차가 생기면 알려 줍니다.** 조기에 알면 재훈련, 업스트림 시스템 감사, 품질 문제 수정 같은 조치를 사람이 지켜보지 않고도 취할 수 있습니다.

**설정 방식 3가지** — ① 실시간 엔드포인트의 지속 모니터링 ② 정기 실행되는 배치 변환 작업의 지속 모니터링 ③ 비동기 배치 변환 작업의 일정 모니터링

**흐름 4단계**

1. **데이터 캡처 활성화** — 실시간 엔드포인트는 요청과 예측을, 배치 변환은 입력과 출력을 캡처
2. **기준선 생성** — 학습에 쓴 데이터셋으로 지표를 계산하고 **지표의 제약을 제안**한다. 예측이 제약을 벗어나면 위반으로 보고
3. **모니터링 스케줄 생성** — 수집할 데이터, 수집 빈도, 분석 방법, 생성할 보고서를 정함
4. **보고서 점검** — 위반, 지표, CloudWatch 알림 확인

**실행의 정체.** 스케줄이 **처리 작업(processing job)** 을 시작해 해당 기간의 수집 데이터를 기준선 통계·제약과 비교하고 위반 보고서를 만듭니다. 특성별 CloudWatch 지표도 발행합니다. 처리 작업의 인스턴스 수와 유형은 **스케줄을 만들 때 고객이 지정**합니다. 실행 결과 상태는 `Completed` · `CompletedWithViolations` · `Failed` 입니다.

**제약 — 시험에 가장 많이 나오는 지점**

| 제약 | 내용 |
|---|---|
| 데이터 형식 | 모델 지표·통계 계산은 **표 형식(tabular) 데이터만.** 이미지 분류 모델은 입력이 아니라 **출력(레이블)에 대해서만** 계산 가능 |
| 엔드포인트 | **단일 모델을 호스팅하는 엔드포인트만.** 멀티모델 엔드포인트 모니터링은 미지원 |
| 추론 파이프라인 | 지원하지만 데이터 캡처·분석은 컨테이너별이 아니라 **파이프라인 전체 단위** |
| 디스크 | 캡처는 디스크 사용률이 높으면 **요청 캡처를 멈춤.** 75% 미만 유지 권장 |
| VPC | Studio를 사용자 지정 VPC에서 열면 S3·CloudWatch와 통신하도록 **VPC 엔드포인트 필요** |
| 컨테이너 | 사전 구축 컨테이너는 표 형식용. NLP·CV 등 비정형 모니터링이나 추가 지표가 필요하면 **자체 컨테이너(BYOC)** |
| 전·후처리 스크립트 | **데이터 품질·모델 품질 작업에서만** 동작 |
| 리전 | S3 데이터 캡처는 모니터링 스케줄과 **같은 리전** |

**사전 구축 컨테이너.** 이미지 이름은 `sagemaker-model-monitor-analyzer`이며 제약 제안, 통계 생성, 기준선 대비 제약 검증, CloudWatch 지표 발행을 제공합니다. **Spark 3.3.0 기반이고 Deequ 2.0.2로 빌드**됐습니다. 직접 pull할 수 없고 SDK로 작업을 제출할 때 사용합니다. CSV와 **평평한(flat) JSON** 입력에 대해 제약을 자동 제안합니다.

**Pipelines 연계.** `QualityCheck` 스텝은 데이터 품질·모델 품질의 기준선 제안과 드리프트 검사를, `ClarifyCheck` 스텝은 데이터 편향·모델 편향·설명가능성 기준선을 다룹니다. 두 스텝이 만든 기준선은 **모델 패키지에 등록해 Model Monitor가 재사용**할 수 있습니다. 배치 변환 모니터링은 `MonitorBatchTransformStep`으로 온디맨드 실행합니다. ⚠️ `ClarifyCheckStep`은 중단 안내에서 `ProcessingStep`으로 교체하라고 합니다.

> ℹ️ Pipelines의 단계·캐싱·DAG 자체는 `mla-t3-3` 9) SageMaker Pipelines가 정본입니다.

### 4) 모니터 유형 4종 비교 {#monitor-types}

| 유형 | 비교하는 것 | 필요한 입력 | 위반·판정 | CloudWatch 네임스페이스 (실시간) |
|---|---|---|---|---|
| **데이터 품질** | 캡처한 입력의 특성별 통계·스키마 vs 학습 기준선(Deequ 기반) | 캡처 + 기준선(`statistics.json`·`constraints.json`) | 위반 **6종** | `/aws/sagemaker/Endpoints/data-metric` |
| **모델 품질** | 예측 vs **실제 정답 라벨**로 계산한 성능 지표 | 캡처 + **S3에 올린 정답 라벨** + 예측·라벨이 있는 기준선 데이터셋 | 지표가 제안된 임계 제약을 벗어나면 위반 | `aws/sagemaker/Endpoints/model-metrics` |
| **편향 드리프트** | Clarify 편향 지표(학습 전·후)가 기준선 제약보다 나빠졌는지 | 캡처 + Clarify 분석 구성 + **정답 데이터** | `bias_drift_check` | `aws/sagemaker/Endpoints/bias-metrics` |
| **특성 기여도 드리프트** | 전역 SHAP 값의 **특성 순위**를 기준선과 비교 | 캡처 + SHAP 기준선 | **NDCG 0.9 미만**이면 `feature_attribution_drift_check` | `aws/sagemaker/Endpoints/explainability-metrics` |

배치 변환 모니터링의 네임스페이스는 `/aws/sagemaker/ModelMonitoring/...` 계열입니다(`data-metric`·`model-metrics`·`bias-metrics`·`explainability-metrics`).

ML Lens의 모니터링 단계 설명도 **같은 4종**을 모니터링 단계에서 감지하는 문제로 나열합니다. 편향·기여도 쪽은 **Clarify 모니터링이 맡고** Model Monitor에 통합돼 있습니다.

### 5) 데이터 캡처 {#data-capture}

| 항목 | 실시간 엔드포인트 | 배치 변환 작업 |
|---|---|---|
| 설정 위치 | `CreateEndpointConfig`의 `DataCaptureConfig` | `CreateTransformJob`의 `DataCaptureConfig` |
| 주요 파라미터 | `EnableCapture`(기본 enabled), `InitialSamplingPercentage`(**정수 0~100, API에서 필수**), `DestinationS3Uri`, `CaptureOptions`(Input·Output), 선택 `KmsKeyId`·`CaptureContentTypeHeader` | `DestinationS3Uri`(필수), 선택 `KmsKeyId`, `GenerateInferenceId` |
| 샘플링 | 트래픽이 많은 엔드포인트는 낮은 값 권장. **Python SDK는 미지정 시 20%** | 샘플링 파라미터가 문서에 없음 |
| 저장 경로 | `{endpoint-name}/{variant-name}/yyyy/mm/dd/hh/filename.jsonl` | `DestinationS3Uri` 아래 `/input`·`/output`. 중복을 피하려고 **원본 S3 위치를 가리키는 JSONL 매니페스트**를 저장 |
| 정답 매칭 키 | 호출 시 `InferenceId`를 주면 캡처 데이터에 추가. 없으면 **`eventId`로 매칭** | `GenerateInferenceId`를 켜면 추론 ID(UUID)와 작업 시작 시각(UTC)을 덧붙임. CSV는 마지막 두 열, JSON·JSONL은 예약 필드 `SageMakerInferenceId`·`SageMakerInferenceTime`(수정 금지) |

⚠️ **`InitialSamplingPercentage`의 기본값 20%는 Python SDK 기준입니다.** API 레퍼런스에서는 기본값 표기 없이 **필수 파라미터**입니다.

- 캡처에 **Model Monitor가 꼭 필요한 것은 아닙니다.** 요청·응답 페이로드 캡처는 학습·디버깅·모니터링에 쓰는 독립 기능입니다
- 실시간 엔드포인트는 계속 떠 있으므로 캡처를 **특정 시간에 켜고 끄거나 샘플링 빈도를 바꾸는 옵션**을 설정할 수 있고, 추론 데이터를 암호화할 수도 있습니다
- 캡처는 운영 트래픽에 영향 없이 **비동기로** 일어나며 S3 전달에 **수 분**이 걸릴 수 있습니다
- 캡처 인코딩은 `CaptureContentTypeHeader`를 지정하지 않으면 **기본 base64**입니다

> 🧠 원리: 캡처는 추론 요청을 방해하지 않도록 설계돼 있어서 **디스크 사용률이 높으면 캡처 쪽이 먼저 멈춥니다.** 그래서 "캡처가 중간에 멈췄다"는 증상의 공식 처방은 디스크 사용률을 75% 미만으로 유지하는 것입니다.

### 6) 기준선·statistics.json·constraints.json·위반 {#monitor-baseline}

**기준선 작업.** Python SDK의 `DefaultModelMonitor.suggest_baseline(..)`으로 기준선 처리 작업을 시작합니다. 사전 구축 컨테이너가 통계를 만들고 **제약을 제안**해 `output_s3_uri`에 씁니다.

- 학습에 쓴 데이터셋을 기준선으로 쓰는 것이 일반적이며, **학습 데이터와 추론 데이터의 스키마(특성 수와 순서)가 정확히 일치**해야 합니다
- 컬럼 이름은 Spark와 호환되게 **소문자와 `_`만** 씁니다
- 예측/출력 컬럼은 학습 데이터셋의 **첫 컬럼**으로 가정합니다
- 생성된 제약은 **검토·수정할 수 있습니다** — 더 공격적으로 하거나 완화해 위반의 수와 성격을 조절합니다

**산출 파일**

| 파일 | 만들어지는 때 | 내용 |
|---|---|---|
| `statistics.json` | 기준선 + **데이터 품질 모니터링 실행에서만** | 데이터셋 수준 `item_count`, 특성별 `inferred_type`. 숫자형은 `num_present`·`num_missing`·`mean`·`sum`·`std_dev`·`min`·`max`·**KLL 스케치 분포(기본 10개 버킷, 변경 불가)**, 문자열형은 `distinct_count`·범주 분포 |
| `constraints.json` | 기준선 작업 | 특성별 `inferred_type`, `completeness`, `num_constraints.is_non_negative`, `string_constraints.domains`, 그리고 `monitoring_config` |
| `constraint_violations.json` | **각 `MonitoringExecution`** 의 산출물 | 현재 데이터셋을 기준선과 비교해 찾은 위반 목록 |

**`monitoring_config` 옵션과 기본값**

| 옵션 | 의미 | 기본값 |
|---|---|---|
| `evaluate_constraints` | 현재 데이터가 제약을 만족하는지 평가 | `Enabled` |
| `emit_metrics` | 파일의 데이터에 대해 CloudWatch 지표 발행 | `Enabled` |
| `datatype_check_threshold` | 데이터 타입 불일치를 위반으로 볼 임계 | **0.1** |
| `domain_content_threshold` | 문자열 필드에서 기준선보다 많은 미지 값을 위반으로 볼 임계 | **0.1** |
| `distribution_constraints.perform_comparison` | 기준선 분포와 현재 분포 비교 수행 | `Enabled` |
| `comparison_threshold` | **두 분포 CDF의 최대 절대 차이(L∞) 임계** | **0.1** |
| `comparison_method` | `linf_simple` 또는 표본 부족 시 `linf_robust`(Two-sample K-S 기반) | 문서에 기본값 표기 없음 |
| `categorical_comparison_threshold` | 범주형 특성 임계(선택) | `comparison_threshold` 값 |
| `categorical_drift_method` | 범주형 드리프트 계산(선택) | **`LInfinity`**(K-S). 대안 `ChiSquared` |

**위반 유형 6종**

| `constraint_check_type` | 플래그되는 조건 |
|---|---|
| `data_type_check` | 현재 실행의 데이터 타입이 기준선과 다름(`datatype_check_threshold`로 조정) |
| `completeness_check` | 관측된 완전성(비-null 비율)이 특성별 완전성 임계를 초과. 기준선 단계가 완전성 값을 제안 |
| `baseline_drift_check` | 현재·기준선 데이터셋의 **분포 거리가 `comparison_threshold`보다 큼** |
| `missing_column_check` | 현재 데이터셋의 열 수가 기준선보다 **적음** |
| `extra_column_check` | 현재 데이터셋의 열 수가 기준선보다 **많음** |
| `categorical_values_check` | 현재 데이터셋의 **미지 값**이 기준선보다 많음(`domain_content_threshold`가 좌우) |

**CloudWatch 지표(데이터 품질).** `emit_metrics`가 `Enabled`면 데이터셋의 모든 특성·열에 대해 발행합니다. 숫자형은 `feature_data_{feature_name}` 이름으로 `Max`·`Min`·`Sum`·`SampleCount`·`Average` 통계를, 숫자·문자열 공통으로 완전성 `feature_non_null_{feature_name}`(`Sum`)과 기준선 드리프트 `feature_baseline_drift_{feature_name}`(`Sum`)를 냅니다. 차원은 실시간 `EndpointName`·`ScheduleName`, 배치 `MonitoringSchedule` 입니다.

> 🧠 원리: 기준선 단계의 컨테이너가 통계를 계산하고 제약을 **"제안"** 하며, 같은 컨테이너가 모니터링 단계에서 기준선 대비 검증과 지표 발행을 합니다. `baseline_drift_check`는 분포 거리가 `comparison_threshold`를 넘을 때 위반이고, 그 거리는 **두 누적분포함수의 최대 절대 차이**로 정의돼 있습니다.

### 7) 모니터링 스케줄과 실행 {#monitor-schedule}

`CreateMonitoringSchedule` API로 스케줄을 만듭니다. 반복 실행하거나 **즉시 한 번** 실행할 수 있습니다.

| 목적 | `ScheduleExpression` | 비고 |
|---|---|---|
| 매시간 | `cron(0 * ? * * *)` | 문서가 나열한 반복 표현식 중 **가장 짧은 주기(1시간)** |
| 매일 특정 시각(UTC) | `cron(0 [00-23] ? * * *)` | 정오 `cron(0 12 ? * * *)`. 일 단위는 파라미터를 생략하면 **SageMaker AI가 시각을 정함**(권장) |
| N시간마다 | `cron(0 [00-23]/[01-24] ? * * *)` | 자정부터 2시간마다 `cron(0 0/2 ? * * *)` |
| **1회 즉시** | `NOW` | `DataAnalysisStartTime`·`DataAnalysisEndTime` **필수** |

⚠️ 문서에 **"minimum interval"이라는 문구는 없습니다.** 위 지원 표현식에서 반복 주기의 최소 단위가 1시간이라는 사실만 확인됩니다 — "최소 간격은 1시간"으로 단정하는 서술은 근거가 없습니다.

- **실행 지연**: 요청 시각과 실제 실행 사이에 **0~20분**의 지연이 있을 수 있습니다. 시간당 스케줄의 첫 실행은 UTC 정시 경계를 넘은 뒤 시작합니다
- **분석 창**: `DataAnalysisStartTime`·`DataAnalysisEndTime`은 ISO 8601 기간 형식 오프셋(예: `-PT1H`)이며 두 시각의 간격은 **24시간을 넘을 수 없습니다**
- **입력 대상**: 스케줄 하나에는 **엔드포인트 입력 또는 배치 변환 입력 중 하나만** 지정합니다
- **모델 품질의 런타임**: 한 실행의 최대 런타임이 정답 병합 작업과 모니터링 작업으로 나뉘므로, 시간당 스케줄이면 `StoppingCondition`의 `MaxRuntimeInSeconds`를 **1800 이하**로 둡니다. 한 실행은 다음 실행 시작 전에 끝나야 합니다
- **리소스·삭제**: 스케줄 삭제는 스케줄을 **중지하고 실행 이력은 지우지 않습니다.** ⚠️ **엔드포인트를 지우려면 먼저 스케줄을 삭제**해야 합니다
- **온디맨드**: SageMaker Processing 작업을 직접 실행하면 온디맨드 모니터링이 됩니다

### 8) 모델 품질 — 정답 병합과 오프셋 {#ground-truth-merge}

모델 품질 모니터링은 예측을 **모델이 맞히려는 실제 정답 라벨**과 비교합니다. 데이터 품질과 같은 단계에 **정답 라벨을 S3에서 가져와 캡처한 예측과 병합하는 단계**가 더해집니다.

**절차**

1. 데이터 캡처 활성화
2. **기준선**: 예측과 정답 라벨이 함께 있는 데이터셋(보통 학습 데이터셋)으로 `ModelQualityMonitor.suggest_baseline` 실행. 인자는 `problem_type`(예: `BinaryClassification`), `inference_attribute`, `probability_attribute`, `ground_truth_attribute`. 결과 제약은 **"임계값"** 이며 지표가 임계를 넘으면 위반
3. **스케줄**: `ModelQualityMonitor.create_monitoring_schedule`
4. **정답 라벨 수집·업로드**: 캡처한 데이터에 주기적으로 라벨을 붙여 S3에 올림
5. **병합·비교**: 캡처 예측과 정답을 병합한 뒤 지표 계산

**정답 레코드(JSON Lines)**

```
{"groundTruthData": {"data": "1", "encoding": "CSV"},
 "eventMetadata": {"eventId": "aaaa-bbbb-cccc"},
 "eventVersion": "0"}
```

| 항목 | 규칙 |
|---|---|
| 매칭 키 | 레코드마다 고유 식별자가 필요. `inferenceId`(호출자가 `InvokeEndpoint`에 제공)가 캡처 데이터에 있으면 그것으로 병합하고, 없으면 자동 생성되는 `eventId`로 매칭. **정답 쪽 `inferenceId`를 캡처 쪽과 일치시키는 책임은 사용자에게** 있다 |
| 형식·경로 | JSON Lines(`.jsonl`). 캡처 데이터와 같은 경로 형식 `s3://bucket/prefix/yyyy/mm/dd/hh`. ⚠️ 경로의 날짜는 **라벨을 수집한 날짜**이며 추론이 생성된 날짜와 같을 필요가 없다 |
| 작업 정의 | boto3는 `create_model_quality_job_definition`의 `GroundTruthS3Input.S3Uri`, Python SDK는 `create_monitoring_schedule`의 `ground_truth_input` |

**오프셋 — 라벨 지연 대응.** 정답은 늦게 올 수 있으므로 스케줄에 오프셋을 지정합니다. `StartTimeOffset`·`EndTimeOffset`은 **작업의 시작·종료 시각에서 뺄 시간**이며 ISO 8601 형식(`-PT#H`, `-P#D`)입니다.

> **분석 창 = [실행 시각 − `StartTimeOffset`, 실행 시각 − `EndTimeOffset`]**

공식 계산 예시 — 라벨이 1일 뒤부터 오고 1주 뒤에 완료되면 `StartTimeOffset=-P8D`, `EndTimeOffset=-P1D`. 이 스케줄이 **2020-01-09T13:00**에 돌면 **2020-01-01T13:00부터 2020-01-08T13:00까지**의 데이터를 분석합니다.

**지표(문제 유형별)**

| 문제 유형 | 지표 |
|---|---|
| 회귀 | `mae` · `mse` · `rmse` · `r2` |
| 이진 분류 | 혼동 행렬, `recall`·`precision`·`accuracy`·`f0_5`·`f1`·`f2`·`auc`, TPR/TNR/FPR/FNR, ROC·정밀도-재현율 곡선, 그리고 각 지표의 `*_best_constant_classifier` 값 |
| 다중 분류 | 혼동 행렬, `accuracy`, `weighted_recall`·`weighted_precision`·`weighted_f0_5`·`weighted_f1`·`weighted_f2`와 `*_best_constant_classifier` |

지표의 **표준편차는 표본이 200개 이상일 때만** 제공되며, 데이터의 **80%를 무작위로 5회** 뽑아 계산합니다.

`enable_cloudwatch_metrics=True`이면 모든 지표를 CloudWatch로 보냅니다(네임스페이스는 4) 표).

> 🧠 원리: 정답이 늦게 도착하면 최신 구간에는 라벨이 없습니다. 문서는 모델 품질 작업이 **정답이 확보된 데이터만 쓰도록** 오프셋으로 작업이 쓰는 데이터의 시간 창을 고르라고 설명합니다.

### 9) 편향·기여도 드리프트 — Clarify 연계 {#clarify-drift}

⚠️ Clarify와 Model Monitor는 모두 신규 고객에게 닫혀 있습니다(2) 참조). 아래는 가이드(Version 1.0) 기준입니다.

> ℹ️ 편향 지표의 정의·계산과 SHAP 자체는 `mla-t2-3` 편향·설명가능성이 정본입니다. 여기서는 **프로덕션에서 분포 변화를 감지하는 쪽**만 다룹니다.

**분포 변화를 어떤 도구가 보는가**

| 변화의 신호 | 공식 도구 | 판정 방식 |
|---|---|---|
| 입력 특성의 통계·스키마가 학습 때와 다름 | **Model Monitor 데이터 품질**(Clarify 불필요) | 기준선 대비 분포 거리·타입·완전성 위반 |
| 라이브 데이터 변화로 공정성 지표가 나빠짐 | Clarify **편향 드리프트** | 허용 범위 + 신뢰구간 |
| 라이브 데이터 변화로 특성 중요도 **순위**가 바뀜 | Clarify **특성 기여도 드리프트** | 전역 SHAP 순위의 **NDCG** |
| 예측이 정답과 어긋남 | Model Monitor **모델 품질** | 정답 라벨 대비 성능 지표 |

**편향 드리프트의 판정**

학습 때 편향이 없어도 **배포 후 라이브 데이터가 학습 데이터와 달라지면** 편향이 도입·악화될 수 있습니다(예: 주택 가격 예측 모델에서 학습에 쓴 모기지 금리가 현재 금리와 다를 때).

1. 허용 범위 `A=(amin, amax)`를 정합니다(예: DPPL을 (-0.1, 0.1)로)
2. 검사 주기가 2일이면 **최근 2일 창의 데이터**로 지표를 계산합니다
3. 표본이 적으면 우연히 극단값이 나올 수 있으므로 **Normal Bootstrap Interval로 신뢰구간 `C`** 를 구성합니다
4. **`C`가 `A`와 겹치면** "허용 범위 안일 가능성이 있다"로 해석하고, **서로소(disjoint)면** 허용 범위 밖이라 확신해 경보를 냅니다

**위반 판정은 "0에서 멀어졌는가"** 로 봅니다. 분석 결과 파일(`analysis.json`)의 지표가 기준선 제약보다 나쁘면 위반입니다. 0에 가까울수록 분포가 균형이라는 뜻이어서, 기준선 DPPL 제약이 **0.2**일 때 분석 결과가 **0.1이면 0에 더 가까우므로 위반이 아니고**, **-0.3이면 0에서 더 멀어 위반**입니다. 위반 파일 필드는 `facet`·`facet_value`·`metric_name`·`constraint_check_type`(현재 `bias_drift_check`만)·`description` 입니다.

CloudWatch 지표 이름은 `bias_metric` 뒤에 약어를 붙입니다(클래스 불균형은 `bias_metric_CI`). 속성에 `BiasStage`(`Pre-training`/`Post-Training`)가 있습니다. 끄려면 작업 정의 `Environment`의 `publish_cloudwatch_metrics`를 `Disabled`로 둡니다.

**특성 기여도 드리프트의 판정**

라이브 데이터 분포의 드리프트는 편향뿐 아니라 **특성 속성(attribution) 값의 드리프트**도 낳습니다. 문서의 대학 입시 가상 예시 — 훈련 데이터 속성이 SAT 0.70 / GPA 0.50 / 학급 석차 0.05였는데 라이브에서 **0.10 / 0.20 / 0.70** 이 되어 순위가 완전히 뒤바뀝니다.

비교 지표에는 두 가지 요구가 있습니다 — **순위 변화에 민감**해야 하고, 같은 폭으로 순위가 떨어져도 **훈련 때 속성 점수가 높던 특성의 변화에 더 민감**해야 합니다. 이 성질 때문에 **NDCG**를 씁니다.

- `NDCG = DCG / iDCG`, 값은 **[0, 1]** 범위. **1이면 라이브의 특성 순위가 훈련 때와 같음.** 위 예시의 NDCG는 **0.69**
- **0.90 미만이면 경보**이고, 레이블별 전역 SHAP 값의 nDCG가 0.9 미만이면 위반을 기록합니다
- **합산한 전역 SHAP 값을 평가하므로 위반 항목에 "feature" 필드가 없습니다.** 필드는 `label`·`metric_name`(현재 `shap`만)·`constraint_check_type`·`description`
- CloudWatch 지표는 2종 — 특성별 전역 SHAP 값(`feature_` 뒤에 특성 이름)과 지표의 `ExpectedValue`. 속성에 `ExplainabilityMethod`(`KernelShap`)·`ValueType`(`GlobalShapValues`/`ExpectedValue`)

⚠️ **Spearman·Kendall 같은 순위 상관계수는 쓰지 않습니다.** 기여도 드리프트 공식 문서 3개 페이지(개요·위반·CloudWatch)에서 쓰는 지표는 **NDCG뿐**입니다.

> 🧠 원리: 편향 드리프트는 **단일 계산값이 아니라 신뢰구간을 허용 범위와 비교**합니다. 작은 표본으로 계산한 값이 우연히 극단값을 보일 수 있기 때문입니다. 기여도 드리프트가 순위만 비교하지 않는 이유도 문서가 밝힌 두 요구에 있습니다.

### 10) CloudWatch 지표·경보·로그 {#cloudwatch-observability}

CloudWatch는 원시 데이터를 근실시간 지표로 처리하고 이 통계를 **15개월 보관**합니다. ⚠️ **콘솔 검색은 최근 2주 안에 갱신된 지표만** 보여 줍니다.

| 대상 | 네임스페이스 | 대표 지표·차원 |
|---|---|---|
| 엔드포인트 호출 | `AWS/SageMaker` | `Invocations`, `Invocation4XXErrors`, `Invocation5XXErrors`, `InvocationModelErrors`, `ModelLatency`, `OverheadLatency`, `InvocationsPerInstance`. 차원 `EndpointName`·`VariantName` |
| 엔드포인트 인스턴스 | `/aws/sagemaker/Endpoints` | `CPUUtilization`, `MemoryUtilization`, `DiskUtilization`, `GPUUtilization` |
| 처리·훈련·변환 작업 | `/aws/sagemaker/ProcessingJobs`, `/aws/sagemaker/TrainingJobs`, `/aws/sagemaker/TransformJobs` | CPU·메모리·디스크·GPU 사용률(**`DiskUtilization`은 배치 변환 미지원**). 차원 `Host` |
| Pipelines 실행·스텝 | `AWS/Sagemaker/ModelBuildingPipeline` | 실행 `ExecutionStarted`·`ExecutionFailed`·`ExecutionSucceeded`·`ExecutionStopped`·`ExecutionDuration`, 스텝 `StepStarted`·`StepFailed`·`StepSucceeded`·`StepStopped`·`StepDuration`. 차원 `PipelineName`·`StepName` |

**지표 주기.** 기본 **1분**이며 `MetricsConfig`의 `MetricPublishFrequencyInSeconds`로 10·30·60·120·180·240·300초를 설정합니다. 호출 지표에서 이 설정을 쓰려면 **`EnableEnhancedMetrics`가 `True`** 여야 합니다. 1초 고해상도 지표는 **3시간만 보존**됩니다.

**정상 범위를 학습하는 경보.** CloudWatch **이상 탐지**는 통계·머신러닝으로 지표를 분석해 정상 기준선을 정합니다. 이 경보는 **정적 임계값이 없고** 기대 값 대역과 비교합니다. 최대 2주의 지표 데이터로 학습하며 **요금이 부과**됩니다. SageMaker 공식 안내는 Model Monitor를 대체하는 경량 옵션으로 **CloudWatch 커스텀 지표 + 이상 탐지 경보**를 듭니다.

**로그.** 컨테이너나 노트북 수명 주기 구성이 `stdout`/`stderr`로 보내는 내용은 CloudWatch Logs로 갑니다. 로그 그룹은 `/aws/sagemaker/Endpoints/[EndpointName]`(스트림 `[production-variant-name]/[instance-id]`), `/aws/sagemaker/TrainingJobs`, `/aws/sagemaker/ProcessingJobs`, `/aws/sagemaker/TransformJobs` 등입니다. **기본값은 무기한 저장**이며 그룹별 보존 기간을 바꿀 수 있습니다.

### 11) 엔드포인트 오류·지연 지표 읽기 {#endpoint-error-latency}

| 지표 | 세는 것·측정 구간 | 포함 범위·비고 |
|---|---|---|
| `Invocation4XXErrors` | 모델이 4xx를 반환한 `InvokeEndpoint` 요청 수 | 4xx만. 4xx면 1, 아니면 0을 보냄 |
| `Invocation5XXErrors` | 모델이 5xx를 반환한 요청 수 | 5xx만 |
| **`InvocationModelErrors`** | **2XX가 아닌 모든 모델 호출** | 4XX/5XX 상태 코드, **저수준 소켓 오류, 잘못된 HTTP 응답, 요청 타임아웃**까지 포함 |
| `Invocations` | `InvokeEndpoint` 요청 수 | 총 요청 수는 `Sum` |
| **`ModelLatency`** | 모델이 응답하는 데 걸린 시간 | **단위 마이크로초.** 컨테이너와의 로컬 통신 + 컨테이너 안의 추론 시간 |
| **`OverheadLatency`** | 요청 수신부터 응답 반환까지에서 **`ModelLatency`를 뺀** SageMaker AI 오버헤드 | 요청·응답 크기, 요청 빈도, 인증·권한 부여에 따라 달라짐 |

**전체 지연은 세 요소**입니다 — 네트워크 지연 + 오버헤드 지연 + 모델 지연.

호출 제약 — 모델 컨테이너는 **60초 안에 응답**해야 하며 모델 처리 시간도 최대 60초입니다. 컨테이너가 4xx·5xx를 반환하면 `ModelError`이며 **HTTP 424**입니다.

⚠️ **공식 문서는 4xx·5xx의 전형적 원인을 서술하지 않습니다.** "4xx면 요청 형식 오류, 5xx면 컨테이너 내부 오류" 같은 일반 HTTP 해석은 근거가 없으므로 판단의 기준으로 쓰지 않습니다. 대신 **범위가 넓은 `InvocationModelErrors`와 둘의 관계**를 외웁니다.

### 12) EventBridge 상태 변경 이벤트 {#eventbridge-events}

EventBridge는 SageMaker AI의 **상태 변경 이벤트**를 감시해 자동 대응하게 합니다. 이벤트는 근실시간으로 전달되고, **상태 변경마다 이벤트가 여러 번 올 수 있으며 이는 정상 동작**입니다(오류가 아닙니다). 자동화 대상 예시는 Lambda 호출, EC2 Run Command, Kinesis Data Streams, Step Functions 상태 머신, SNS 토픽입니다.

| 이벤트 | `detail-type` | 핵심 필드·값 |
|---|---|---|
| 훈련 작업 | `SageMaker Training Job State Change` | `TrainingJobStatus`. `Failed`면 `FailureReason` 포함 |
| 처리 작업 | `SageMaker Processing Job State Change` | `ProcessingJobStatus`, 실패 시 `FailureReason` |
| 배치 변환 작업 | `SageMaker Transform Job State Change` | `TransformJobStatus`, 실패 시 `FailureReason` |
| 엔드포인트 | `SageMaker Endpoint State Change` | `EndpointStatus`(예: `IN_SERVICE`) |
| 엔드포인트 배포 | `SageMaker Endpoint Deployment State Change` | `VariantStatus`: `Creating`·`Deleting`·`Updating`·`ActivatingTraffic`·**`Baking`**. `Baking`은 자동 롤백 구성의 **CloudWatch 경보를 지켜보는 대기 기간** |
| 파이프라인 실행 | `SageMaker Model Building Pipeline Execution Status Change` | `currentPipelineExecutionStatus`·`previousPipelineExecutionStatus`: `Executing`·`Succeeded`·`Failed`·`Stopping`·`Stopped` |
| 파이프라인 스텝 | `SageMaker Model Building Pipeline Execution Step Status Change` | `currentStepStatus`: `Starting`·`Executing`·`Succeeded`·`Failed`·`Stopping`·`Stopped`. `Failed`면 `failureReason`, **캐시 적중 시 `cacheHitResult`** |

**다른 워크플로 서비스의 상태 이벤트**

| 서비스 | 이벤트 | 값 |
|---|---|---|
| AWS Step Functions | `Step Functions Execution Status Change`(source `aws.states`) | `status`: `RUNNING`·`SUCCEEDED`·`FAILED`·`TIMED_OUT`·`ABORTED`·`PENDING_REDRIVE` |
| AWS Glue | `Glue Job State Change`(SUCCEEDED·FAILED·TIMEOUT·STOPPED에서 생성), `Glue Job Run Status`(지연 알림 임계 초과), `Glue Crawler State Change` | ETL 실패 시 SNS 알림, 성공 시 Lambda 호출이 문서 예시 |

**파이프라인 모니터링의 세 축** — ① EventBridge 상태 변경 이벤트 ② CloudWatch 파이프라인 지표(10) 참조) ③ 파이프라인 안의 품질 게이트 `QualityCheck`·`ClarifyCheck` 스텝.

**자동 롤백·재훈련 연결.** 배포 가드레일의 baking period 동안 지정한 CloudWatch 경보가 울리면 이전 엔드포인트로 완전 롤백합니다. ⚠️ **경보가 없으면 자동 롤백이 동작하지 않습니다.** 드리프트가 확인되면 CloudWatch 경보로 재훈련 워크플로를 알리거나 자동 실행하고, Pipelines·Model Registry·블루/그린·카나리 배포를 이어 붙이는 구성을 ML Lens가 제시합니다.

⚠️ **모니터링 실행 자체가 EventBridge 이벤트를 내는지는 문서로 확인되지 않습니다.** 위반 감지는 실행 상태 `CompletedWithViolations`·보고서·CloudWatch 지표로 서술합니다.

### 13) A/B 테스트 — 프로덕션 변형 {#ab-monitoring}

프로덕션에서 모델·인스턴스·컨테이너를 비교해 **가장 성능이 좋은 후보를 고르는** 용도로 **프로덕션 변형**을 씁니다. 멀티 변형 엔드포인트는 변형별 트래픽 분배를 지정하거나, 요청마다 특정 변형을 직접 호출할 수 있습니다.

| 방식 | 설정 | 동작 |
|---|---|---|
| **트래픽 분배** | 엔드포인트 구성에서 변형마다 가중치 `InitialVariantWeight`(Float, 최소 0, **미지정 시 기본 1.0**) | 변형의 트래픽 = **그 변형의 가중치 ÷ 모든 변형 가중치의 합.** 2와 1이면 3분의 2와 3분의 1, 1과 1이면 50%씩 |
| **직접 호출** | `InvokeEndpoint`의 `TargetVariant` | 지정 변형이 처리. ⚠️ 트래픽 분배가 있어도 **대상 지정 라우팅이 분배를 재정의(override)** 한다 |
| **운영 중 조정** | `UpdateEndpointWeightsAndCapacities` | 변형 가중치(여러 변형) 또는 변형 1개의 용량을 변경. ⚠️ **엔드포인트를 업데이트하지 않고** 트래픽 분포를 바꾼다. 호출을 받으면 상태가 `Updating`, 끝나면 `InService`. 인자는 `VariantName`과 `DesiredWeight`·`DesiredInstanceCount` |

- **변형 수 한도**: 엔드포인트 구성의 `ProductionVariants`는 **1~10개**
- **변형마다 다를 수 있는 것**: 모델, 인스턴스 유형·개수. **서로 다른 인스턴스 유형으로 모델을 시험**할 수 있습니다
- **어느 변형이 처리했는지**: 응답 헤더 `x-Amzn-Invoked-Production-Variant`. 캡처 데이터 경로에도 변형 이름이 들어갑니다
- **변형별 모니터링**: SageMaker AI가 변형마다 `Latency`·`Invocations` 같은 지표를 CloudWatch에 냅니다. `EndpointName, VariantName` 차원으로 필터합니다. 모델 성능(정확도·정밀도·재현율·F1·ROC/AUC)은 **변형별로 계산해 비교**합니다
- **절차(문서 예시 4단계)**: ① 모델 생성·배포(가중치 1·1) → ② 호출(분배 호출 + `TargetVariant` 호출) → ③ 변형별 성능 평가 → ④ 우수 변형 쪽으로 트래픽 증가(예: 25·75, 최종 0·1이면 모든 요청이 두 번째 변형으로)
- **위치**: 새 모델과 기존 모델의 프로덕션 트래픽 A/B 테스트는 **새 모델 검증의 효과적인 마지막 단계**입니다. ML Lens도 모델 업데이트 시 프로덕션 변형으로 A/B를 하라고 합니다

> 🧠 원리: 가중치는 절댓값이 아니라 **합 대비 비율**로 해석되므로 4:1이나 0.8:0.2가 같은 분배입니다. 그래서 트래픽 비율을 바꾸려면 엔드포인트 구성을 새로 만들지 않고 `UpdateEndpointWeightsAndCapacities`로 가중치만 바꿉니다.

**A/B vs 섀도 vs 블루/그린 — 프로덕션 모니터링 관점**

| 구분 | 호출자가 받는 응답 | 트래픽 | 목적 | 제약 |
|---|---|---|---|---|
| **A/B**(변형 가중치) | **가중치대로 각 변형의 응답이 실제 호출자에게** 감 | 가중치 비율로 분배 | 실제 사용자 트래픽에서 성능 비교 후 승자 선정 | 변형 1~10개 |
| `TargetVariant` 직접 호출 | 지정한 변형의 응답 | 요청 단위 지정 | 특정 변형 시험·검증 | 분배를 재정의 |
| **섀도 테스트** | **프로덕션 변형의 응답만** 호출자에게 반환. 섀도 응답은 폐기하거나 기록 | 요청 **복사본**을 섀도 변형으로 실시간 전달 | 사용자 영향 없이 지연·오류율 같은 **운영 지표** 검증 | ⚠️ 서버리스·비동기·Marketplace 컨테이너·다중 컨테이너·멀티모델·Inf1 엔드포인트 **불가**. `ShadowProductionVariants`는 `ProductionVariants`와 **각각 1개씩만** |
| 블루/그린·롤링(가드레일) | 전환 후 새 플릿이 응답 | all at once / canary / linear | 안전한 모델 업데이트와 자동 롤백 | **CloudWatch 경보가 자동 롤백의 전제** |

> ℹ️ 섀도 테스트와 A/B의 비교 관점 자체는 `mla-t2-3` 14) 섀도·A/B가 정본이고, 배포 가드레일의 구성은 `mla-t3-1` 8) 배포 가드레일이 정본입니다.

### 14) 감시 수단 고르기 {#observability-choice}

보기에 셋이 함께 나오면 **감시 대상이 무엇인가**로 가릅니다.

| 구분 | Model Monitor | CloudWatch 지표·경보 | EventBridge 이벤트 |
|---|---|---|---|
| 감시 대상 | 기준선 대비 **모델 품질**(입력 통계·성능·편향·기여도) | 엔드포인트·작업·파이프라인 **운영 지표**의 임계 또는 정상 범위 | 리소스 **상태 변경**(성공·실패·진행) |
| 트리거 | 모니터링 스케줄이 처리 작업을 주기 실행 | 지표가 임계(또는 이상 탐지 대역)를 이탈 | 상태 변경 이벤트가 규칙과 일치 |
| 대표 예 | `baseline_drift_check` 위반, `CompletedWithViolations` | `Invocation5XXErrors`, `ModelLatency`, `ExecutionFailed` | `SageMaker Training Job State Change`, 파이프라인 실행 `Failed` |
| 연결 | 특성별 지표를 CloudWatch로 발행해 경보로 이어짐 | SNS 알림·조치 | Lambda·SNS·Step Functions 호출 |

**증상 → 수단 대응표**

| 증상 | 수단 |
|---|---|
| 파이프라인·훈련·처리 작업이 실패하면 즉시 알림 | **EventBridge** 상태 변경 규칙(`Failed`) → SNS·Lambda |
| 엔드포인트 5xx·오류율·지연이 임계를 넘으면 경보 | **CloudWatch 지표 + 경보** |
| 컨테이너 내부 오류 원인 조사 | **CloudWatch Logs** `/aws/sagemaker/Endpoints/[EndpointName]` |
| 정적 임계값 없이 정상 범위를 자동 학습 | **CloudWatch 이상 탐지** |
| 파이프라인 중간에 데이터·모델 품질 게이트 | **`QualityCheck`·`ClarifyCheck` 스텝** |
| ETL·오케스트레이션 실패 | **Glue Job State Change**, **Step Functions Execution Status Change** |
| 배포 후 문제 시 자동 롤백 | **배포 가드레일 + CloudWatch 경보** |
| 입력 분포·스키마가 학습 때와 달라짐 | **Model Monitor 데이터 품질** |
| 정확도·RMSE가 떨어졌다(라벨이 늦게 온다) | **Model Monitor 모델 품질 + 오프셋** |

⚠️ 자주 섞이는 오답 — **Data Capture는 알림 기능이 아닙니다**(요청·응답을 S3에 남기는 기능). **Model Monitor는 작업 실패·5xx 알림 수단이 아닙니다**(통계적 드리프트 감시). **A/B·섀도는 드리프트 감시 도구가 아닙니다**(배포 비교 기법).

### 15) ML Lens — 모니터링 관련 설계 원칙과 모범 사례 {#ml-lens-monitoring}

정식 명칭은 "Machine Learning Lens - AWS Well-Architected Framework"이며 페이지 상단 공개일은 **2025-11-19**입니다. 개정 이력의 최신 항목은 **"New lens version"(2025-11-19)** — 모든 모범 사례를 새 구조로 갱신했습니다. 그 이전 주요 개정은 2023-07-05(지속가능성 필러 추가)입니다. 생성형 AI는 **별도의 Generative AI Lens**가 다룹니다.

렌즈 서문은 **데이터가 시간에 따라 변하므로** 정확도·성능 문제를 감지·교정·완화하는 지속적 모니터링이 필수이고, 정제된 데이터셋으로 재훈련이 필요한 경우가 많다고 밝힙니다.

**설계 원칙 10개 중 monitoring이 직접 나오는 것은 하나뿐입니다.**

| 원칙 | 요지 | monitoring 직접 언급 |
|---|---|---|
| **Enable continuous improvement** | **지속적인 모니터링, 분석, 학습으로 워크로드를 발전·개선** | **예** |
| Enable resiliency | 버전 관리·추적성·설명가능성으로 내결함성·복구 가능성 확인 | 아니오 |
| Enable automation | 파이프라이닝·스크립팅·CI/CD·**지속적 훈련(CT)** 활용 | 아니오 |
| Assign ownership / Provide protection / Enable reusability / Enable reproducibility / Optimize resources / Reduce cost / Minimize environmental impact | 각각 책임·보안 통제·모듈 재사용·버전 관리·트레이드오프·비용 절감·지속가능성 | 아니오 |

⚠️ 가이드의 "모니터링과 관련된 ML 렌즈의 설계 원칙"이 **이 10개 중 어느 것을 가리키는지는 문서가 지정하지 않습니다.** 그래서 "지속적 개선 = 지속적인 모니터링·분석·학습" 수준으로만 쓰고, 세부는 아래 모범 사례 ID를 근거로 삼습니다.

**Model monitoring 단계의 필러별 모범 사례**

| 필러 | 모범 사례 |
|---|---|
| 운영 우수성 | MLOPS06-BP01 환경 간 스큐 점검 / **MLOPS06-BP02 모델 관측성·추적 활성화** |
| 보안 | MLSEC06-BP01 의도한 정당한 소비자로 접근 제한 / MLSEC06-BP02 데이터에 대한 사람의 이상 활동 모니터링 |
| 신뢰성 | **MLREL05-BP01 모델 엔드포인트 자동 스케일링 허용** / MLREL05-BP02 관리된 버전 통제 전략으로 복구 가능한 엔드포인트 |
| 성능 효율성 | MLPERF06-BP01 휴먼 인 더 루프 모니터링 / BP02 설명가능성 평가 / **BP03 데이터 드리프트 평가** / **BP04 성능 저하 모니터링·감지·처리** / **BP05 자동 재훈련 프레임워크 확립** / BP06 재훈련용 갱신 데이터·특성 검토 |
| 비용 최적화 | MLCOST06-BP01 ML 활동별 사용량·비용 모니터링 / BP02 ROI 모니터링 / BP03 엔드포인트 사용량 모니터링·플릿 적정 규모 / BP04 디버깅·로깅 활성화 |
| 지속가능성 | MLSUS06-BP01 물질 효율 측정 / **MLSUS06-BP02 필요할 때만 재훈련** |

**출제 후보 — 안티패턴이 핵심입니다**

| ID | 핵심 내용 | 문서가 명시한 안티패턴 |
|---|---|---|
| MLOPS06-BP02 | 모델 성능 지표, 실시간 엔드포인트의 컴퓨트 운영·응답 상태, 계보(lineage) 추적. Model Monitor 4종 + CloudWatch 대시보드·경보 + SNS, Model Dashboard, Model Cards, 섀도 테스트 | **모니터링 없는 모델 배포**, 데이터·개념 드리프트 미모니터링 |
| MLPERF06-BP01 | 사람이 붙인 라벨과 모델 추론을 비교해 드리프트·성능 저하 감지(⚠️ A2I 신규 고객 불가) | **자동 지표에만 의존** |
| MLPERF06-BP03 | 기준선 → 모니터링 스케줄 → 통계 척도 → 임계값 → CloudWatch 경보 → 재훈련 전략 | **고정 일정으로 재훈련**(실제 드리프트 패턴 무시) |
| MLPERF06-BP04 | 학습·검증 단계에서 기준선 성능 확립, 정확도뿐 아니라 데이터 통계·특성 분포·예측 패턴 감시, 경보 심각도 설정, 자동 스케일링, 재훈련 파이프라인, 업데이트 시 프로덕션 변형 A/B | **데이터·개념 드리프트를 심각해질 때까지 무시** |
| MLPERF06-BP05 | 정기 간격 **또는 성능 지표가 정의된 임계에 도달할 때** 자동 재훈련. CloudWatch 경보 → Pipelines → Model Registry → 블루/그린·카나리 + 자동 롤백 | **모델 성능과 무관한 고정 일정 재훈련** |

> ℹ️ 재훈련 메커니즘의 배선(트리거 4종)은 `mla-t3-3` 14) 모델 재훈련이 정본입니다.

### 16) 모니터링 비용 구조 {#monitor-cost}

| 항목 | 내용 |
|---|---|
| **스케줄 비용의 단위** | 모니터링 스케줄은 반복 일정에 따라 **Processing Job 인스턴스를 기동**한다. 스케줄을 삭제하면 지속 컴퓨팅 비용이 사라진다 |
| 인스턴스 예약 | 스케줄에서 고객이 처리 작업의 인스턴스 수·유형을 지정하고, **이 리소스는 스케줄이 삭제될 때까지 예약된다**(FAQ) |
| 삭제의 의미 | 스케줄 삭제는 스케줄을 **중지하며 실행 이력은 지우지 않는다** |
| 섀도 테스트 | **추가 요금 없음.** 섀도 모델을 호스팅하는 인스턴스·스토리지 요금만 발생하고 입출력 데이터 처리 추가 요금은 없음 |
| CloudWatch 이상 탐지 | 이상 탐지 모델을 쓰는 경보는 **요금이 부과**됨 |

⚠️ **요금 수치는 정답 근거로 쓰지 않습니다.** 요금 페이지의 "내장 규칙 최대 30시간 무료" 문장은 Real-Time Inference 항목 아래에 있고 프리 티어 표와의 관계가 확인되지 않습니다. 시험에서 묻는 것은 **"스케줄이 처리 작업 인스턴스를 반복 기동해 비용이 생기며 스케줄 삭제로 멈춘다"** 수준입니다.

> 🧠 원리: 모니터링 비용의 단위는 **"스케줄이 기동하는 처리 인스턴스"** 입니다. 그래서 쓰지 않는 스케줄과 엔드포인트는 **스케줄부터 삭제**하는 것이 문서의 순서이고, 엔드포인트 삭제의 전제 조건도 같습니다.

---

## ✍️ 시험 포인트

- **증상 → 모니터 유형**: 입력 분포·스키마·결측 변화 → 데이터 품질 · 정확도·RMSE 하락(정답이 며칠 뒤 확정) → 모델 품질 · 공정성 지표 이탈 → 편향 드리프트 · SHAP 특성 순위 뒤바뀜 → 기여도 드리프트
- **"입력 분포는 그대로인데 정확도가 떨어졌다"** → 개념 드리프트이므로 **정답 라벨을 쓰는 모델 품질 모니터링**. 데이터 품질로 교체하는 선택지는 라벨이 필요 없지만 정확도를 측정하지 못합니다
- **"캡처만 켰는데 위반 보고서가 없다"** → 기준선과 모니터링 스케줄이 있어야 비교·보고가 일어납니다
- **"멀티모델 엔드포인트 모니터링"·"이미지·텍스트 입력"** → 멀티모델 미지원, 사전 구축 컨테이너는 표 형식만이므로 **BYOC**
- **"엔드포인트를 지울 수 없다"** → 모니터링 스케줄을 먼저 삭제
- **"스케줄 최소 주기"** → 문서가 나열한 지원 표현식 중 최단은 매시간. **분 단위 cron은 지원 표현식에 없고**, `NOW`는 반복이 아니라 1회 즉시
- **오프셋 계산**은 스케줄 페이지의 예시를 기준으로 합니다 — `-P8D`/`-P1D`, 실행 2020-01-09T13:00 → 분석 2020-01-01T13:00~2020-01-08T13:00
- **상태 변경은 EventBridge, 수치 임계는 CloudWatch 경보, 원인 분석은 로그.** 셋을 섞으면 틀립니다
- **A/B 가중치 변경에 엔드포인트를 새로 만들지 않습니다** — `UpdateEndpointWeightsAndCapacities`
- **섀도로 A/B를 수행할 수 없습니다** — 섀도 변형의 응답은 호출자에게 가지 않습니다
- **자동 롤백에는 CloudWatch 경보가 전제**입니다. 경보가 없으면 가드레일이 되돌리지 않습니다

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 데이터 품질 모니터링으로 편향·기여도 순위 변화까지 잡으려 한다 | 데이터 품질은 **통계·스키마 제약 위반만** 봅니다. 편향·기여도는 Clarify 모니터링입니다 |
| 모델 품질 모니터링을 라벨 없이 구성한다 | 모델 품질은 **정답 라벨을 S3에 올려 병합**하는 단계가 필수입니다. 편향 드리프트 실행도 정답 데이터가 필요합니다 |
| 정답 라벨 경로의 날짜를 추론 시각으로 맞춘다 | 경로 `yyyy/mm/dd/hh`의 날짜는 **라벨을 수집한 날짜**이며 추론 생성 날짜와 같을 필요가 없습니다 |
| 라벨 지연을 샘플링 비율로 해결하려 한다 | 샘플링은 캡처량 조절입니다. 라벨 지연은 **`StartTimeOffset`·`EndTimeOffset`** 으로 분석 창을 옮깁니다 |
| 분 단위 cron으로 스케줄을 만든다 | 문서의 지원 표현식에 **분 단위 반복이 없습니다.** 최단은 매시간이고 실행은 0~20분 늦을 수 있습니다 |
| 분석 창을 길게 잡는다 | `DataAnalysisStartTime`과 `EndTime`의 간격은 **24시간을 넘을 수 없습니다** |
| `TargetVariant`를 쓰면서 가중치가 적용된다고 본다 | 대상 지정 라우팅이 **가중치 분배를 재정의**합니다 |
| 가중치 4:1과 0.8:0.2가 다르다고 본다 | 가중치는 **합 대비 비율**이라 같은 분배입니다 |
| 섀도 테스트를 서버리스·멀티모델 엔드포인트에 적용한다 | 서버리스·비동기·Marketplace 컨테이너·다중 컨테이너·멀티모델·Inf1 엔드포인트는 **사용 불가**입니다 |
| `Invocation4XXErrors`와 `InvocationModelErrors`를 같게 본다 | `InvocationModelErrors`는 **2XX가 아닌 모든 호출**로 범위가 넓고 소켓 오류·타임아웃까지 포함합니다 |
| `OverheadLatency`를 네트워크 지연으로 본다 | 전체 지연 = 네트워크 + 오버헤드 + 모델이며, `OverheadLatency`는 **SageMaker AI 오버헤드**(전체 − `ModelLatency`)입니다 |
| CloudWatch 콘솔에서 지표가 안 보이면 발행되지 않았다고 본다 | 콘솔 검색은 **최근 2주 안에 갱신된 지표만** 보여 줍니다. 통계 자체는 15개월 보관됩니다 |
| 모니터링 스케줄 실행이 EventBridge 이벤트로 온다고 가정한다 | 문서로 확인되지 않습니다. 위반은 **`CompletedWithViolations` 상태·보고서·CloudWatch 지표**로 감지합니다 |
| 기여도 드리프트에 Spearman·Kendall 상관을 쓴다 | 공식 문서가 쓰는 지표는 **NDCG뿐**이며 기준은 0.90 미만입니다 |
| 편향 드리프트에서 지표가 작아지면 위반이라고 본다 | **0에 가까울수록 균형**입니다. 기준선 제약 0.2에 결과 0.1은 위반이 아니고, -0.3은 위반입니다 |
| 고정 일정 재훈련을 모범 사례로 본다 | ML Lens가 **명시한 안티패턴**입니다. 성능 지표가 임계에 도달할 때 재훈련하는 것이 권고입니다 |

---

## 🧪 자가 점검

**Q1.** 입력 특성의 분포는 학습 때와 거의 같은데 모델 정확도가 꾸준히 떨어진다. 어떤 드리프트이고, Model Monitor의 어느 유형이 이것을 잡는가? (→ 1), 4))

<details><summary>정답 보기</summary>

**개념 드리프트**입니다 — 입력과 타깃 변수 **사이의 관계**가 변한 것이어서 입력 분포가 그대로여도 일어납니다. 입력 통계 검정만으로는 잡히지 않으므로 **모델 품질 모니터링**으로 잡습니다. 예측을 실제 정답 라벨과 병합해 성능 지표를 기준선 임계와 비교하는 유형이고, 따라서 **정답 라벨이 필요**합니다. 데이터 품질 모니터링은 라벨이 필요 없지만 정확도를 측정할 수 없습니다.
</details>

**Q2.** 엔드포인트에 데이터 캡처를 켜고 며칠을 기다렸지만 위반 보고서가 하나도 생기지 않는다. 무엇이 빠졌는가? (→ 3))

<details><summary>정답 보기</summary>

**기준선과 모니터링 스케줄**이 빠졌습니다. 캡처는 요청·응답을 S3에 남기는 **독립 기능**이라 Model Monitor 없이도 쓸 수 있습니다. 비교·보고가 일어나려면 ① 학습 데이터로 기준선(`statistics.json`·`constraints.json`)을 만들고 ② 모니터링 스케줄을 만들어 **처리 작업이 주기적으로 캡처 데이터를 기준선과 비교**해야 합니다. 그 실행의 산출물이 `constraint_violations.json`이고 상태는 `Completed`·`CompletedWithViolations`·`Failed`입니다.
</details>

**Q3.** 멀티모델 엔드포인트에 Model Monitor를 붙이려 한다. 그리고 입력이 이미지인 분류 모델도 모니터링하려 한다. 각각 가능한가? (→ 3))

<details><summary>정답 보기</summary>

**멀티모델 엔드포인트 모니터링은 미지원**입니다 — Model Monitor는 **단일 모델을 호스팅하는 엔드포인트**만 지원합니다. 이미지 분류 모델은 지표·통계 계산이 **표 형식(tabular) 데이터만** 대상이라서 **입력이 아니라 출력(레이블)에 대해서만** 계산할 수 있습니다. NLP·CV 같은 비정형 모니터링이나 추가 지표가 필요하면 사전 구축 컨테이너 대신 **자체 컨테이너(BYOC)** 를 씁니다.
</details>

**Q4.** 정답 라벨이 예측 1일 뒤부터 도착해 1주 뒤에 완료된다. 오프셋을 어떻게 두고, 그 스케줄이 2020-01-09T13:00에 돌면 어느 구간을 분석하는가? (→ 8))

<details><summary>정답 보기</summary>

**`StartTimeOffset=-P8D`, `EndTimeOffset=-P1D`** 입니다. 분석 창은 **[실행 시각 − 시작 오프셋, 실행 시각 − 종료 오프셋]** 이므로 **2020-01-01T13:00부터 2020-01-08T13:00까지**를 분석합니다. 이렇게 두는 이유는 모델 품질 작업이 **정답이 확보된 데이터만 쓰도록** 시간 창을 옮기는 것입니다. 라벨은 JSON Lines로 `s3://bucket/prefix/yyyy/mm/dd/hh` 경로에 올리고, 매칭은 `inferenceId`(없으면 `eventId`)로 합니다.
</details>

**Q5.** 기준선의 DPPL 제약이 0.2다. 이번 실행의 분석 결과가 0.1이면 위반인가? -0.3이면? 그리고 편향 드리프트 경보는 무엇을 비교해 판정하는가? (→ 9))

<details><summary>정답 보기</summary>

**0.1은 위반이 아니고 -0.3은 위반**입니다 — 편향 지표는 **0에 가까울수록 분포가 균형**이라는 뜻이므로, 0.1은 제약 0.2보다 0에 더 가깝고 -0.3은 0에서 더 멉니다. 경보 판정은 단일 계산값이 아니라 **허용 범위 `A`와 Normal Bootstrap 신뢰구간 `C`** 를 비교합니다. 겹치면 "허용 범위 안일 가능성이 있다"로 보고, **서로소(disjoint)면** 범위 밖이라 확신해 경보를 냅니다. 작은 표본의 값이 우연히 극단적일 수 있기 때문입니다.
</details>

**Q6.** 전역 SHAP 특성 순위가 학습 때와 뒤바뀌었다. 어떤 지표로 재고 경보 기준은 얼마인가? 위반 항목에 특성 이름이 없는 이유는? (→ 9))

<details><summary>정답 보기</summary>

**NDCG**(정규화된 할인 누적 이득)로 재고 **0.90 미만이면 경보**입니다. `NDCG = DCG / iDCG`이고 값은 [0, 1]이며 **1이면 라이브 순위가 훈련 때와 같음**을 뜻합니다. 순위 변화에 민감하면서 **훈련 때 속성 점수가 높던 특성의 변화에 더 민감**해야 한다는 두 요구 때문에 이 지표를 씁니다. 위반에 "feature" 필드가 없는 이유는 **합산한 전역 SHAP 값을 평가**하기 때문입니다. ⚠️ Spearman·Kendall 같은 순위 상관계수는 공식 문서가 쓰지 않습니다.
</details>

**Q7.** 다음 세 요구를 각각 어떤 수단으로 구현하는가? ① 훈련 작업이 실패하면 즉시 Slack 알림 ② 엔드포인트 5xx가 임계를 넘으면 경보 ③ 정적 임계값 없이 정상 범위를 자동 학습 (→ 12), 14))

<details><summary>정답 보기</summary>

① **EventBridge** — `SageMaker Training Job State Change` 이벤트 규칙으로 `TrainingJobStatus`가 `Failed`인 것을 걸러 SNS·Lambda를 호출합니다(`FailureReason`이 함께 옵니다). ② **CloudWatch 지표 + 경보** — `Invocation5XXErrors`(또는 범위가 더 넓은 `InvocationModelErrors`)에 임계 경보를 둡니다. ③ **CloudWatch 이상 탐지** — 정적 임계값 없이 기대 값 대역과 비교하며, 최대 2주 데이터로 학습하고 **요금이 부과**됩니다. 원칙은 **상태 변경 = EventBridge, 수치 임계 = CloudWatch 경보, 원인 분석 = CloudWatch Logs**입니다.
</details>

**Q8.** 새 모델을 실제 트래픽의 25%만 받게 하고 성능을 비교하려 한다. 어떻게 구성하고, 비율을 바꿀 때 엔드포인트를 다시 만들어야 하는가? 사용자에게 영향을 주지 않고 지연만 검증하려면 무엇을 쓰는가? (→ 13))

<details><summary>정답 보기</summary>

**프로덕션 변형 가중치**로 구성합니다 — 엔드포인트 구성에서 변형마다 `InitialVariantWeight`를 주고(미지정 시 기본 **1.0**), 트래픽은 **그 변형의 가중치 ÷ 전체 가중치 합**으로 정해집니다(예: 75와 25). 변형은 **1~10개**까지입니다. 비율 변경에 엔드포인트를 다시 만들 필요가 **없습니다** — **`UpdateEndpointWeightsAndCapacities`** 가 엔드포인트를 업데이트하지 않고 가중치(또는 용량)만 바꿉니다. 사용자 영향 없이 운영 지표만 검증하려면 **섀도 테스트**입니다 — 요청 복사본을 섀도 변형으로 보내지만 **호출자에게는 프로덕션 변형의 응답만** 반환합니다. ⚠️ 섀도로는 A/B를 할 수 없습니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> MLA-C02의 대응 Task는 **4.1 ML 및 AI 모델 추론 및 성능을 모니터링합니다**로, C01의 범위를 그대로 품으면서 **생성형 AI와 에이전트 쪽이 추가**됩니다. 아래는 공식 비교 페이지 기준이며 **C01 시험 범위가 아닙니다.**

- **추가 ①** — 4.1.5 에이전트 성능 및 조정 관리를 모니터링하고 자동화합니다(예: **조정 실패 감지, 잘린 스트리밍, 도구 실패**)
- **추가 ②** — 4.1.6 **Amazon Bedrock 평가 도구 세트**와 같은 파운데이션 모델(FM)에 대한 AI 관련 성능 모니터링을 구성합니다
- **삭제된 콘텐츠** — 이 Task에는 없습니다

참고로 Clarify 중단 안내도 파운데이션 모델 평가는 **Amazon Bedrock Evaluations**를 가리킵니다(예측형 ML의 편향·설명가능성 대체는 아닙니다). C01에서 이 문서가 다룬 드리프트·기준선·모니터 4종은 C02에서도 그대로 유효합니다.

⚠️ 비교 페이지는 **'추가'된 항목만 번호로 나열**하며, 번호가 건너뛰는 항목이 C01의 어느 항목에 대응하는지는 설명하지 않습니다.

---

### 📌 출처

- Data and model quality monitoring with Amazon SageMaker Model Monitor (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor.html
- Amazon SageMaker Model Monitor availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html
- Clarify availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html
- Data capture (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-data-capture.html
- Capture data from real-time endpoint (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-data-capture-endpoint.html
- Capture data from batch transform job (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-data-capture-batch.html
- DataCaptureConfig (SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_DataCaptureConfig.html
- Create a Baseline (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-create-baseline.html
- Schema for Statistics (statistics.json file) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-interpreting-statistics.html
- Schema for Constraints (constraints.json file) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-byoc-constraints.html
- Schema for Violations (constraint_violations.json file) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-interpreting-violations.html
- Interpret results (Model Monitor) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-interpreting-results.html
- CloudWatch Metrics (Model Monitor 데이터 품질) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-interpreting-cloudwatch.html
- Schedule monitoring jobs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-scheduling.html
- ScheduleConfig (SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ScheduleConfig.html
- Model Monitor FAQs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-faqs.html
- Data quality (Model Monitor) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-data-quality.html
- Model quality (Model Monitor) (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality.html
- Schedule model quality monitoring jobs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality-schedule.html
- Ingest Ground Truth labels and merge them with predictions (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality-merge.html
- Model quality metrics and Amazon CloudWatch monitoring (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality-metrics.html
- Amazon SageMaker Model Monitor prebuilt container (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-pre-built-container.html
- Bias drift for models in production (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-bias-drift.html
- Bias Drift Violations (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-bias-drift-violations.html
- CloudWatch Metrics for Bias Drift Analysis (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-bias-drift-cw.html
- Feature attribution drift for models in production (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-feature-attribution-drift.html
- Model Feature Attribution Drift Violations (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-model-attribution-drift-violations.html
- CloudWatch Metrics for Feature Drift Analysis (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-feature-attribute-drift-cw.html
- Amazon SageMaker AI metrics in Amazon CloudWatch (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html
- CloudWatch Logs for Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/logging-cloudwatch.html
- Events that Amazon SageMaker AI sends to Amazon EventBridge (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/automating-sagemaker-with-eventbridge.html
- Using CloudWatch anomaly detection (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html
- Automating Step Functions event delivery with EventBridge (공식 문서) — https://docs.aws.amazon.com/step-functions/latest/dg/eventbridge-integration.html
- Automating AWS Glue with EventBridge (공식 문서) — https://docs.aws.amazon.com/glue/latest/dg/automating-awsglue-with-cloudwatch-events.html
- Baseline calculation, drift detection and lifecycle with ClarifyCheck and QualityCheck steps (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines-quality-clarify-baseline-lifecycle.html
- Testing models with production variants (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-ab-testing.html
- ProductionVariant (SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ProductionVariant.html
- UpdateEndpointWeightsAndCapacities (SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_UpdateEndpointWeightsAndCapacities.html
- InvokeEndpoint (SageMaker Runtime API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_runtime_InvokeEndpoint.html
- CreateEndpointConfig (SageMaker API Reference) — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_CreateEndpointConfig.html
- Shadow tests (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests.html
- Auto-Rollback Configuration and Monitoring (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-configuration.html
- Machine Learning Lens — Document revisions — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/document-revisions.html
- Well-Architected machine learning design principles (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/design-principles.html
- Machine Learning Lens — Monitoring (ML 수명주기 단계) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/monitoring.html
- Machine Learning Lens — Best practices by ML lifecycle — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/best-practices-by-ml-lifecycle-phase.html
- MLPERF06-BP01 Include human-in-the-loop monitoring (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp01.html
- MLPERF06-BP03 Evaluate data drift (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp03.html
- MLPERF06-BP04 Monitor, detect, and handle model performance degradation (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp04.html
- MLPERF06-BP05 Establish an automated re-training framework (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html
- MLOPS06-BP02 Enable model observability and tracking (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops06-bp02.html
- AWS Prescriptive Guidance — Detecting drift in production applications — https://docs.aws.amazon.com/prescriptive-guidance/latest/gen-ai-lifecycle-operational-excellence/prod-monitoring-drift.html
- MLA-C01 공식 시험 가이드 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
