---
examGuideTaskId: mla-t2-3
certCode: MLA-C01
domain: 2
domainName: ML 모델 개발
domainWeightPct: 26
title: 모델 성능 분석 (지표·기준선·수렴 진단·Clarify 편향·SHAP·섀도 테스트)
coversTasks:
  - "2.3"
sources:
  - title: Metrics and validation (SageMaker AI Autopilot 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-metrics-validation.html
  - title: View an Autopilot model performance report (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-model-insights.html
  - title: Pre-training Bias Metrics (SageMaker Clarify 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-data-bias.html
  - title: Post-training Data and Model Bias Metrics (SageMaker Clarify 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-post-training-bias.html
  - title: Feature Attributions that Use Shapley Values (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-shapley-values.html
  - title: List of Debugger built-in rules (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-built-in-rules.html
  - title: Shadow tests (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests.html
  - title: Testing models with production variants (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-ab-testing.html
  - title: MLPERF04-BP05 Perform a performance trade-off analysis (Machine Learning Lens)
    url: https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf04-bp05.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 모델 성능 분석 (지표·기준선·수렴 진단·Clarify 편향·SHAP·섀도 테스트)

> **커버하는 공식 Task** — MLA-C01 · 도메인 2 「ML 모델 개발」(26%) · **Task 2.3 모델 성능 분석** (`mla-t2-3`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 2.2가 "어떻게 훈련하는가"였다면 2.3은 **"이 모델이 쓸모가 있는지 어떻게 판정하는가"** — 지표를 고르고, 기준선과 견주고, 편향과 설명까지 보는 단계입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 혼동 행렬의 네 칸에서 정확도·정밀도·재현율·F1이 각각 **어떤 분모**로 나오는지 말하고, **오류 비용의 비대칭**과 클래스 불균형으로 지표를 고른다(정확도가 왜 위험한지 포함)
- [ ] 임계값을 올릴 때 FP·FN이 어떻게 움직이는지 알고, ROC-AUC와 PR-AUC를 가른다
- [ ] RMSE·MAE·R2의 차이와 잔차 히스토그램·표준화 잔차를 읽는 법을 안다
- [ ] "baseline"의 **세 가지 뜻**(성능 기준선 · 운영 기준선 · 설명 기준선)을 구분한다
- [ ] 훈련 오차와 평가 오차를 함께 보아 과적합·과소적합을 **식별**하고, 기울기 소실·폭주·죽은 ReLU 같은 수렴 문제의 징후를 Debugger 규칙과 짝짓는다
- [ ] Clarify의 **사전 편향 지표**(모델 불필요)와 **사후 편향 지표**(예측 필요)를 가른다
- [ ] SHAP과 PDP가 답하는 질문이 다르다는 것과, 설명이 기준선 대비라는 점을 안다
- [ ] 섀도 변형과 프로덕션 변형 가중치(A/B)의 **요청 처리 방식** 차이를 설명하고, Clarify·Debugger·Model Monitor의 현재 상태와 대체 경로를 안다

> **이 문서가 다루는 것** — 1) 혼동 행렬 기반 분류 지표 · 2) 곡선 지표(임계값·ROC·AUC·PR) · 3) 회귀 지표와 잔차 진단 · 4) 지표 선택 기준 · 5) baseline 세 가지 뜻 · 6) 과적합·과소적합 식별 · 7) 수렴 문제 · 8) Debugger 디버깅 · 9) 사전 편향 지표 · 10) 사후 편향 지표 · 11) SHAP과 PDP · 12) Clarify 중단과 대체 경로 · 13) 재현 가능한 실험 · 14) 섀도 vs 프로덕션 변형 · 15) 성능·시간·비용 절충

---

## 🎯 왜 중요한가

지표를 잘못 고르면 **나쁜 모델을 좋다고 판정**합니다. 사기 거래가 0.1%인 데이터에서 "전부 정상"이라고 답하는 모델도 정확도 99.9%를 받습니다. 그래서 이 Task는 숫자를 계산하는 법보다 **어떤 숫자를 볼지 정하는 법**을 묻습니다.

시험은 대개 오류의 비용을 시나리오에 깔아 둡니다. "암 검사", "안전하지 않은 항공기를 안전으로 판정", "희귀 돌연변이". 각 문장이 FP와 FN 중 무엇이 비싼지를 알려 주고, 그것이 지표를 정합니다. 여기에 편향·설명 요구가 겹치면 Clarify 쪽으로 갑니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **오류 비용을 먼저 읽는다**: "놓치면 치명적"(암 검사·충돌 탐지) → **재현율** · "잘못 통과시키면 치명적"(안전 판정) → **정밀도** · 둘 다 → **F1** 또는 임계값 조정
- ⚠️ **클래스 불균형이 보이면 정확도는 오답.** BalancedAccuracy·AUPRC·F1 쪽으로 간다. **AUPRC는 TN을 고려하지 않아** TN이 압도적인 데이터에 맞는다
- **임계값을 올리면 FP↓·FN↑ → 정밀도↑·재현율↓.** **AUC 0.5는 무작위**, 0에 가까우면 예측이 거꾸로 나오는 신호. AUC는 **임계값에 독립적**
- **RMSE는 스케일 의존**이라 크기가 다른 데이터셋끼리 비교하면 안 된다. **잔차 = 실제값 − 예측값**이므로 양의 잔차는 과소 예측, 음의 잔차는 과대 예측
- **"baseline"이 나오면 어느 baseline인지 먼저 가른다** — ① 비교용 단순 모델 ② Model Monitor 운영 기준선 ③ SHAP 설명 기준선
- **과적합·과소적합은 훈련 오차와 평가 오차를 함께 본다.** "**훈련에서도 나쁘다**"가 과소적합의 결정적 단서. 검증 손실 반등은 Debugger `overfit`·`overtraining`
- **편향은 모델 예측이 필요한가로 가른다**: 데이터만 → **CI·DPL** · 예측 필요 → **DPPL·DI·RD·AD**. **DPL ↔ DPPL** 비교가 "훈련이 편향을 키웠나"를 답한다
- **예측 양성 비율 질문**: **차**로 묻는 지표 → **DPPL** · **비**로 묻는 지표 → **DI**(1이면 인구통계 평등)
- **SHAP은 기여도, PDP는 한계 효과.** "한 특성 값을 바꾸면 예측이 어떻게 변하나"는 **PDP**. 설명은 **기준선 대비**이고 기준선을 바꾸면 설명이 달라진다
- **섀도는 응답을 반환하지 않고 A/B는 반환한다.** ⚠️ 상태 주의 — **Clarify·Debugger·Model Monitor는 신규 고객 중단**, **Profiler는 2027-06-30 지원 종료**, 섀도·A/B는 영향 없음

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **TP·TN·FP·FN** | 예측 1·실제 1 / 예측 0·실제 0 / 예측 1·실제 0 / 예측 0·실제 1 |
| **임계값(threshold)** | 확률·점수를 클래스로 바꾸는 기준값. 올리면 FP는 줄고 FN은 늘어난다 |
| **AUC** | ROC 곡선 아래 면적. 0~1이며 1이 완벽, **0.5는 무작위 분류기**와 같다 |
| **잔차(residual)** | 실제값 − 예측값. 양의 잔차는 과소 예측, 음의 잔차는 과대 예측 |
| **facet** | Clarify가 편향을 측정하는 대상 속성(열). 유리한 쪽을 facet a, 불리한 쪽을 facet d |
| **사전/사후 편향 지표** | 모델 출력 없이 데이터만 보는 지표 / **모델의 예측 레이블**이 필요한 지표 |
| **SHAP 기준선** | 특성이 "없는" 상태를 대신할 기준 인스턴스. 설명은 이 기준선과의 편차다 |
| **섀도 변형** | 복제된 요청을 받지만 **응답을 반환하지 않는** 변형 |
| **계보 추적(lineage)** | 모델을 만든 데이터·코드·파라미터·환경의 연결 관계 기록 |

---

## 📖 핵심 개념

### 1) 혼동 행렬에서 출발하는 분류 지표 {#classification-metrics}

| 지표 | 정의 | 범위·방향 | 언제 우선 | 한계 |
|---|---|---|---|---|
| Accuracy(정확도) | 올바르게 분류한 수 ÷ 전체 | 0~1, 클수록 좋음 | 클래스가 균형일 때의 기본 | **양성·음성 수 차이가 크면 왜곡**(문서 예: 스팸이 1%) |
| Precision(정밀도) | TP ÷ (TP+FP) | 0~1 | **FP 비용이 클 때**(문서 예: 안전하지 않은 항공기를 안전으로 판정) | FN을 보지 않음 |
| Recall(재현율·리콜·민감도·TPR) | TP ÷ (TP+FN) | 0~1 | 양성을 빠짐없이 찾아야 할 때(문서 예: 암 검사) | **전부 양성으로 예측하면 만점** → 단독 사용 금지 |
| F1 | 정밀도와 재현율의 **조화평균** | 0~1 | 둘 다 중요할 때. Autopilot 이진 분류의 기본 목적 지표 | 이진용. 다중 분류는 `F1macro` |
| BalancedAccuracy | 0.5 × ((TP/P) + (TN/N)) | 0~1 | **양성·음성 수가 크게 다른** 불균형 데이터 | — |
| LogLoss | 클래스가 아니라 **확률 출력의 품질**을 평가 | 0~∞, 0이 완벽 | 높은 확률로 틀리는 예측을 크게 벌주고 싶을 때 | 확률 출력이 있어야 함 |
| FPR(위양성률) | FP ÷ (FP+TN). ROC 곡선의 가로축 | 0~1, 작을수록 좋음 | ROC 곡선을 읽을 때 | — |

**도구별 지표와 기본값**

| 도구 | 쓸 수 있는 지표 | 기본 목적 지표 |
|---|---|---|
| Autopilot 표 형식 | 이진: Accuracy·AUC·BalancedAccuracy·F1·Precision·Recall / 다중: Accuracy·BalancedAccuracy·F1macro·PrecisionMacro·RecallMacro / 회귀: MAE·MSE·R2·RMSE | 회귀 **MSE**, 이진 **F1**, 다중 **Accuracy** |
| Autopilot 이미지·텍스트 분류 | Accuracy만 | Accuracy |
| Autopilot 시계열 | RMSE·wQL·Average wQL·MASE·MAPE·WAPE | **AverageWeightedQuantileLoss** |
| 내장 XGBoost | `validation:accuracy`·`auc`·`f1`·`map`·`ndcg`는 Maximize, `error`·`logloss`·`mae`·`mse`·`rmse` 등은 Minimize | `eval_metric` 미지정이면 목적에 따라 회귀 `rmse`·분류 `error`·랭킹 `map` |

- 혼동 행렬 읽기(Autopilot 품질 보고서): 세로축이 실제 레이블, 가로축이 예측 레이블이고 색 막대가 샘플이 많은 칸을 짙게 칠합니다. **왼쪽 위에서 오른쪽 아래 대각선이 맞은 예측**입니다. 다중 분류 보고서는 레이블 최대 15개를 담고, 어떤 행이 `Nan`이면 **검증 데이터에 그 레이블이 없다**는 뜻입니다.

> 🧠 **원리** — 정확도·정밀도·재현율·F1은 모두 같은 네 칸(TP·FP·FN·TN)을 **서로 다른 분모**로 나눈 값입니다. 뒤에 나오는 Clarify 사후 편향 지표도 "그룹별 혼동 행렬의 숫자를 조합한 것"이라, 이 네 칸을 이해하면 둘이 한 묶음으로 보입니다.

### 2) 곡선 지표 — 임계값·ROC·AUC·PR {#curve-metrics}

- **임계값**은 확률·점수를 클래스로 바꾸는 기준값입니다. **임계값을 올리면 FP는 줄고 FN은 늘어납니다.** Clarify가 수치 예측을 이진 레이블로 바꿀 때 쓰는 `probability_threshold`의 기본값은 **0.5**입니다.
- **ROC 곡선**은 임계값을 바꿔 가며 TPR(= 재현율)을 FPR에 대해 그린 곡선이고, **AUC**는 그 아래 면적으로 모든 임계값에 걸친 성능을 한 값으로 요약합니다. 1이 완벽, **0.5는 무작위**입니다. **0에 가까우면 패턴은 배웠지만 예측이 거꾸로 나온다**는 뜻이고 데이터 문제의 신호일 수 있습니다.
- AUC는 **임계값에 독립적**이라 임계값을 고르지 않고도 모델을 비교할 수 있습니다(⚠️ 이 서술의 근거는 구서비스 Amazon ML 문서입니다).
- **PR 곡선·AUPRC**는 정밀도와 재현율의 트레이드오프를 그립니다. AUPRC는 **TN의 수를 고려하지 않기 때문에** TN이 매우 많은 데이터(문서 예: 희귀 돌연변이 유전자 모델링)의 평가에 좋습니다.
- **이득(gain)·향상(lift) 곡선**은 데이터의 일부만 골랐을 때 양성을 얼마나 찾는지와 무작위 대비 몇 배 찾는지를 보여 줍니다.

| 곡선 지표 | 가로 · 세로 | 우선 쓰는 상황 |
|---|---|---|
| ROC-AUC | FPR · TPR | 임계값과 무관하게 모델 간 분리 능력 비교 |
| PR 곡선 · AUPRC | 재현율 · 정밀도 | **양성이 드물고 TN이 압도적**인 데이터 |
| 혼동 행렬 | 실제 · 예측 | 특정 임계값에서 FP·FN이 어디서 나는지 확인 |

> 🧠 **원리** — FPR = FP/(FP+TN)이라 **분모에 TN이 들어가고**, 정밀도 = TP/(TP+FP)에는 TN이 들어가지 않습니다. 그래서 TN이 압도적으로 많으면 FPR이 거의 0으로 깔려 ROC가 낙관적으로 보이고, 정밀도 기반 곡선이 더 정직합니다.

### 3) 회귀 지표와 잔차 진단 {#regression-metrics}

| 지표 | 정의 | 특징·함정 |
|---|---|---|
| MSE | 차이를 제곱해 평균 | Autopilot 회귀의 기본 목적 지표 |
| RMSE | 제곱 평균의 제곱근 | **큰 오차·이상치의 존재를 드러냄**. ⚠️ **스케일에 의존**하므로 크기가 다른 데이터셋끼리 비교하면 안 된다 |
| MAE | 절대 오차의 평균 | 오차 크기를 그대로 평균 |
| R2(결정계수) | 종속변수의 분산을 얼마나 설명하는지 | 문서 표기 −1~1, 클수록 좋음. 0 근처는 설명력이 거의 없고 음수는 상수 함수보다 못하다는 뜻 |
| MASE(시계열) | 예측의 MAE를 단순 기준 예측의 MAE로 나눈 값 | **1 미만이면 기준보다 좋고 1 초과면 나쁨** |
| wQL·Average wQL(시계열) | P10·P50·P90 분위수 예측의 가중 절대 차이 | Average wQL이 시계열 Autopilot 기본 지표 |

**잔차 진단**

- 잔차는 실제값 − 예측값입니다. **양의 잔차**는 모델이 실제보다 낮게 본 **과소 예측**, **음의 잔차**는 과대 예측입니다(⚠️ 구서비스 문서 근거).
- 잔차 히스토그램이 **0을 중심으로 한 종 모양**이면 특정 구간을 체계적으로 과대·과소 예측하지 않는다는 뜻입니다. 0을 중심으로 하지 않으면 오차에 구조가 남아 있어 **변수를 더 넣는 것이 도움이 될 수 있습니다.**
- Autopilot 보고서는 **표준화 잔차**(잔차 ÷ 표준편차)를 그리고 **절댓값이 3보다 큰 점을 일반적으로 이상치**로 봅니다. "실제 대 예측" 도표에서는 최적 직선에서 멀수록 오차가 큽니다.

> 🧠 **원리** — RMSE는 오차를 제곱한 뒤 평균하므로 큰 오차가 더 크게 반영됩니다. 그래서 문서가 RMSE를 "큰 오차와 이상치의 존재를 알려 주는 지표"로 설명합니다. MAE는 절대 오차의 단순 평균이라 이상치에 덜 민감합니다.

### 4) 지표 선택 기준 {#metric-choice}

| 상황 | 우선 볼 지표 | 피해야 할 선택 |
|---|---|---|
| **FP 비용이 큼** | Precision | Recall 단독 |
| **FN 비용이 큼**(양성을 놓치면 치명적) | Recall — 문서 예: 암 검사, 자율주행의 임박한 충돌 탐지 | Precision 단독, Accuracy |
| 둘 다 중요 | F1, 또는 오류 비용에 맞춘 **임계값 조정** | Accuracy |
| **클래스 불균형**(양성이 드묾) | BalancedAccuracy · AUPRC · F1 | **Accuracy** |
| 불균형을 학습 단계에서 보정 | 샘플 가중치(Autopilot 앙상블 모드), XGBoost `scale_pos_weight`(전형적 값은 음성 수 ÷ 양성 수) | — |
| 임계값과 무관하게 모델 비교 | AUC | 특정 임계값의 Accuracy |
| 확률 출력의 품질 | LogLoss | Accuracy |
| 회귀 | RMSE(이상치 민감) · MAE · R2 | **스케일이 다른 데이터셋 간 RMSE 비교** |
| 다중 클래스 | F1macro · PrecisionMacro · RecallMacro | 단일 클래스 지표만 |

- ML Lens는 지표를 **비즈니스 KPI와 맞추라**고 합니다(기술 지표인 정밀도·재현율·지연 시간 ↔ 전환율·비용 절감). **정확도만 보고 설명 가능성·공정성·추론 속도를 무시하는 것은 안티패턴**입니다.
- 성능 지표만으로 충분하지 않을 때는 모델 **편향**도 평가 기준에 넣습니다(→ 9·10).

**⚠️ 가이드의 "히트 맵"이 무엇인가** — 가이드 K1은 "혼동 행렬, 히트 맵, F1 점수 …"를 예로만 나열하고 설명하지 않습니다. 공식 자료에서 이 단어나 같은 시각화가 쓰인 곳은 ① **혼동 행렬의 색 농도**(Autopilot 보고서는 "색 막대"라고만 적습니다) ② AWS 블로그 예제가 혼동 행렬을 `heatmap`으로 그린 것 ③ **Clarify 컴퓨터 비전 설명**의 슈퍼픽셀별 SHAP 히트 맵 ④ Debugger Insights의 시스템 사용률입니다. 출제 의도는 문서로 확정되지 않으므로 이 문서는 **두 의미(혼동 행렬의 색 농도, SHAP 히트 맵)를 병기**합니다.

> 🧠 **원리** — "무엇이 더 비싼 오류인가"가 지표를 정합니다. FP가 비싸면 **분모에 FP가 들어가는** 정밀도를, FN이 비싸면 **분모에 FN이 들어가는** 재현율을 봅니다. 임계값을 올리면 FP가 줄고 FN이 늘어나므로 임계값도 두 비용의 상대 크기로 조정합니다.

### 5) "baseline"의 세 가지 뜻 {#baselines}

공식 문서에서 baseline은 서로 다른 세 가지를 가리킵니다. 가이드 K2의 "성능 기준선"은 ①이며 구체 서비스를 명시하지 않습니다.

| 구분 | 목적 | 만드는 방법 | 상태 |
|---|---|---|---|
| ① **성능 기준선**(비교용 단순 모델) | 개선 여부를 재는 기준점 | 단순한 아키텍처·명백한 특성·단순한 알고리즘으로 기준 모델을 만들고(내장 알고리즘으로 빠르게) 이후 실험을 이 기준점과 비교. 교차 검증으로 견고성 확인. **기준 없이 복잡한 알고리즘부터 고르는 것이 안티패턴** | 현행 |
| ①′ **지표 자체의 기준값** | "상수 답만 내는 모델보다 나은가" | 이진 분류 **AUC 0.5**(무작위) · 회귀는 **항상 평균을 예측하는 가상 모델의 RMSE** · 다중 분류는 **항상 최빈 클래스를 예측하는 모델의 macro-F1** · 시계열 MASE는 단순 기준 예측으로 정규화 | ⚠️ AUC·RMSE·macro-F1 기준값 정의는 **구서비스 Amazon ML 문서** 근거 |
| ② **운영 기준선**(Model Monitor baseline) | 배포 후 드리프트·품질 저하 탐지 기준 | 학습 데이터셋으로 baseline job을 돌려 기준 통계와 제약을 제안. 모델 품질은 예측값 + 정답 레이블이 든 데이터셋으로 계산 | ⚠️ **Model Monitor는 신규 고객 중단** |
| ③ **설명 기준선**(SHAP baseline) | 특성이 "없는" 상태를 대신할 기준 인스턴스 | 생략하면 입력 데이터를 K-means·K-prototypes로 클러스터링해 자동 계산. 평균·중앙값·최빈값의 평균적 인스턴스를 직접 줄 수도 있음 | ⚠️ **Clarify는 신규 고객 중단** |

- **평가는 학습에 쓰지 않은 데이터로** 합니다. 학습 데이터로 정확도를 재면 일반화가 아니라 암기를 보상합니다. 모델 설정까지 평가 데이터로 고르면 **모델 선택 자체가 과적합**될 수 있어 검증용을 따로 둡니다(예: 60/20/20). Autopilot 앙상블 모드는 검증 데이터를 주지 않으면 **80% 학습·20% 검증**으로 자동 분할합니다.
- ML Lens의 성능 개선 절차: ① 기준 모델 → ② 실험 추적(관리형 MLflow) → ③ 알고리즘 비교 → ④ 특성 공학 → ⑤ 데이터 양·품질 → ⑥ 앙상블 → ⑦ 하이퍼파라미터 튜닝 → ⑧ 개선 여부를 체계적으로 평가.
- **현재 운영 중인 모델이 곧 기준선**이 되기도 합니다 — 섀도 테스트와 A/B가 그 경우입니다(→ 14).

### 6) 과적합·과소적합을 식별하는 방법 {#fit-diagnosis}

> 📍 처방(정규화·조기 중지·증강 등)의 정본은 **Task 2.2 문서 6) 정규화**입니다. 여기서는 **식별**만 다룹니다.

핵심 진단은 **훈련 데이터의 오차와 평가 데이터의 오차를 함께 보는 것**입니다.

| | 과소적합 | 과적합 |
|---|---|---|
| 징후 | **훈련 데이터에서도** 성능이 나쁨. 훈련·테스트 모두 부정확 → **높은 편향** | 훈련은 좋고 평가·테스트는 나쁨. **훈련-테스트 격차가 큼** → **높은 분산** |
| 원인(문서) | 모델이 데이터 관계에 비해 너무 단순, 특성 부족, 충분한 데이터로 충분히 학습하지 못함 | 훈련 데이터가 적거나 잡음이 많음, 모델이 패턴 대신 데이터를 암기, 복잡도가 높아 잡음까지 학습 |

- 특성 부족이 아니라 **학습 데이터 양이 부족해서** 둘 다 나쁠 수도 있습니다. 이때는 훈련 예제 수와 학습 패스 수를 늘립니다.
- 문서가 **가장 좋은 과적합 탐지법**으로 꼽는 것은 **더 많은(보지 않은) 데이터로 시험하는 것**입니다. **K-겹 교차 검증**은 훈련 세트를 K개 폴드로 나눠 번갈아 검증에 쓰고 점수를 평균합니다.
- Autopilot은 HPO 모드에서 훈련 인스턴스 **50,000개 이하**의 작은 데이터셋에 **k=5** 교차 검증을 자동 적용하고, 앙상블 모드는 크기와 무관하게 교차 검증을 합니다. 교차 검증은 과적합·선택 편향을 줄이지만 **훈련 시간을 평균 20% 늘릴 수 있습니다.**
- 클래스 불균형도 과적합 위험과 이어집니다 — 작은 facet의 데이터가 적으면 모델이 큰 facet에 맞춰 학습하고 작은 데이터셋에 과적합될 위험이 커집니다.
- **Debugger 규칙**: `overfit`은 검증 손실과 훈련 손실을 비교해 과적합을 탐지하고, `overtraining`은 둘이 모두 줄다가 개선이 멈춘 뒤에도 학습을 이어가 **검증 손실이 다시 증가하는** 상황을 다룹니다(⚠️ Debugger는 신규 고객 중단).

> 🧠 **원리** — 모델이 훈련 데이터를 암기하면 훈련 오차는 계속 줄지만 보지 못한 데이터의 오차는 오릅니다. 그래서 **두 오차의 격차**(또는 검증 손실의 반등)가 과적합 신호이고, **두 오차가 모두 높으면** 관계를 포착하지 못한 과소적합입니다.

### 7) 수렴 문제의 종류와 징후 {#convergence}

수렴 문제는 Debugger 문서가 **비수렴(non-converging) 문제**라고 부르는 훈련 문제 묶음입니다.

| 문제 | 징후 | 원인 | Debugger 규칙 |
|---|---|---|---|
| **기울기 소실** | 기울기 절댓값의 평균이 임계값 밑으로 떨어지거나 0 → 가중치가 거의 갱신되지 않음 | 너무 작은 가중치 초기화, 포화된 tanh·sigmoid | `vanishing_gradient` · `saturated_activation` |
| **텐서·기울기 폭주** | 훈련 중 텐서에 무한대 또는 NaN 발생 | 너무 큰 가중치 초기화 | `exploding_tensor` · `weight_update_ratio` |
| 손실이 줄지 않음 | 손실이 적절한 비율로 감소하지 않음 | 학습률·초기화 등 | `loss_not_decreasing` |
| 아주 느린 수렴 | 가중치 대비 업데이트 비율이 너무 작음 | — | `weight_update_ratio` |
| 학습 정체 | 일정 시간 동안 새 텐서 출력이 없음 | 작업이 멈춤 | `stalled_training_rule`(발동 시 훈련 중지 가능) |
| 불량 가중치 초기화 | 층마다 활성화 입력 분산이 크게 다름, 기울기 분포가 좁음 | 초기화가 너무 작으면 소실, 크면 폭주 | `poor_weight_initialization`(처음 몇 단계만 검사) |
| **죽은 ReLU** | 한 층의 비활성 ReLU 비율이 임계를 넘음 → 출력이 0이라 기울기도 0이 되어 가중치가 갱신되지 않음 | ReLU 활성도 저하 | `dead_relu` |
| 입력·데이터 문제 | 이미지 입력 평균이 0에서 벗어남, 패딩·미지 토큰 비율이 높음, 클래스 불균형 | 전처리·데이터 | `check_input_images` · `nlp_sequence_ratio` · `class_imbalance` · `all_zero` · `tensor_variance` |
| 학습률 | 너무 높으면 최적해를 지나쳐 불안정, 너무 낮으면 안정적이나 느림 | 하이퍼파라미터 | 손실 곡선 · `loss_not_decreasing` |
| 검증 손실 반등 | 훈련 손실은 줄지만 검증 손실이 다시 늚 | 과적합·과훈련 | `overfit` · `overtraining` |

- **규칙의 적용 범위가 다릅니다.** `dead_relu`·`exploding_tensor`·`poor_weight_initialization`·`saturated_activation`·`vanishing_gradient`·`weight_update_ratio`는 **딥러닝 프레임워크 전용**이고 XGBoost에는 쓸 수 없습니다.

> 🧠 **원리** — `weight_update_ratio` 문서에 따르면 훈련은 **업데이트가 기울기에 걸맞을 때** 가장 좋습니다. 지나치게 큰 업데이트는 가중치를 최적값에서 멀어지게 하고, 아주 작은 업데이트는 수렴을 매우 느리게 합니다. 학습률도 같은 구조입니다.

### 8) Debugger로 수렴 디버깅 {#debugger}

> ⚠️ **상태**: SageMaker Debugger는 **신규 고객에게 닫혀 있습니다**(기존 고객은 계속 사용, 새 기능 없음). 묶음 공지의 신규 고객 중단일은 2026-07-30입니다. 별개로 **SageMaker Profiler는 2027-06-30 지원 종료**로 이후 콘솔·리소스에 접근할 수 없습니다. 가이드(Version 1.0)가 SK6에서 Debugger를 명시하므로 개념과 규칙 이름은 그대로 익히고 대체 경로를 함께 봅니다.

**무엇을 하나** — 훈련 작업의 **출력 텐서**를 실시간으로 디버깅해 수렴하지 않는 문제를 찾습니다. 텐서는 훈련 반복마다 순전파·역전파에서 갱신된 파라미터의 데이터 모음입니다. 지원 프레임워크는 **Apache MXNet·PyTorch·TensorFlow·XGBoost**입니다.

**절차(SK6)** — ① 필요하면 훈련 스크립트를 `sagemaker-debugger` SDK로 수정하고 hook 설정 + 규칙을 구성 → ② 훈련을 시작하고 규칙이 감시하는 상태를 실시간으로 봄 → ③ 규칙이 발동하면 내장 액션 `StopTraining`·`Email`·`SMS`(SNS 토픽 필요)나 CloudWatch Events + Lambda로 조치 → ④ 수집한 텐서를 **TensorBoard**로 시각화 → ⑤ 고치고 반복.

- 텐서는 `CollectionConfig`·`DebuggerHookConfig`로 **컬렉션**으로 묶여 S3에 저장되고, 지정이 없으면 기본 경로는 `<훈련 작업 이름>/debug-output/`입니다. 내장 컬렉션 예는 `weights`·`gradients`·`losses`·`biases`입니다.
- 한 훈련 작업에 붙일 수 있는 **내장 규칙은 최대 20개**이고 **내장 규칙 사용에 추가 비용은 없습니다.** `create_xgboost_report`는 XGBoost 훈련의 출력 텐서를 모아 보고서를 자동 생성합니다.

**⚠️ 대체 경로** — 공지가 역량별로 안내하는 대체

| Debugger 역량 | 대체 |
|---|---|
| 훈련 지표 로깅·실행 비교 | **MLflow** / TensorBoard |
| 모델·파라미터 추적 | **MLflow**(하이퍼파라미터·모델 버전·아티팩트를 재현성 있게 추적) |
| 기울기·활성화·가중치 분석 | **TensorBoard**(히스토그램·분포 플러그인) |
| 시스템 리소스 프로파일링 | **Amazon CloudWatch** |
| 자동 훈련 진단 | **CloudWatch Alarms + MLflow** |
| (Profiler) 커널 추적·동기화 분석 | **PyTorch/TensorFlow Profiler + TensorBoard**, CloudWatch |

- 구분: **MLflow는 스칼라 지표와 실행 비교**에, **TensorBoard는 기울기 히스토그램·가중치 분포 같은 다차원 모델 내부 점검**에 강하며 둘을 함께 쓰라고 안내합니다. 과거 텐서 데이터는 S3에 남고 `smdebug` 라이브러리로 읽을 수 있습니다.

### 9) Clarify와 사전(pre-training) 편향 지표 {#pre-bias}

> ⚠️ **상태**: SageMaker Clarify도 **신규 고객에게 닫혀 있습니다**(묶음 공지 2026-07-30). 가이드 K4·SK5가 Clarify를 명시하므로 지표 이름과 의미는 그대로 익히고 대체 경로는 12)에서 봅니다.

**Clarify가 제공하는 분석 범주(K4)** — ① **사전 편향 지표**(데이터 속 편향) ② **사후 편향 지표**(알고리즘·하이퍼파라미터 선택이 만든 편향, **모델 예측 사용**) ③ **Shapley 값(SHAP)** — **훈련된 모델 필요** ④ **부분 의존성 도표(PDP)** — **훈련된 모델 필요**. 분석은 Clarify 전용 컨테이너로 도는 **처리 작업**으로 실행하고 설정은 JSON(`analysis_config`)으로 줍니다.

**용어** — `facet`은 편향을 측정하는 속성(열)이고 유리한 쪽을 **facet a**, 불리한 쪽을 **facet d**로 씁니다. `group variable`은 조건부 인구통계 격차에서 하위 그룹을 나누는 범주형 열로 **심슨 역설** 대응이며 그 지표에만 필요합니다.

**사전 편향 지표 8종**(CI·DPL·KL·JS·LP·TVD·KS·CDD)은 모두 **모델 출력에 의존하지 않아 어떤 모델에도 유효**합니다.

> 📍 **사전 지표의 정의·산식·암기 틀은 Task 1.3 문서 「데이터 무결성·편향 관리」가 정본**입니다. 그 문서가 CI·DPL·CDD와 분포형 5종(KL·JS·LP·TVD·KS)을 산식과 함께 정리합니다. 여기서는 이 Task(2.3)의 몫인 **사후 지표와의 관계**만 다룹니다.

이 Task에서 기억할 것은 **두 짝**입니다.

| 사전(관측 레이블) | 사후(예측 레이블) | 두 값을 비교하면 |
|---|---|---|
| **DPL** — facet별 양성 **레이블** 비율 차 | **DPPL** — facet별 양성 **예측** 비율 차 | 훈련이 양성 비율 편향을 **키웠는지**(DPPL > DPL이면 증가) |
| **CDD** — 하위 그룹별 결과 격차(심슨 역설 배제) | **CDDPL** — 같은 지표를 **예측 레이블로** 계산 | 하위 그룹 수준에서 같은 질문 |

- 나머지 사전 지표(CI와 분포형 5종)는 사후 짝이 없습니다. **CI만 결과가 아니라 표본 수**를 본다는 점이 사후 지표 전체와 가르는 특징입니다.
- 설정의 `methods`에 쓰는 약어는 `CI`·`DPL`·`KL`·`JS`·`LP`·`TVD`·`KS`·**`CDDL`**(CDD의 설정 약어)이며, `all`로 두면 사전 지표를 모두 계산합니다. 편향 분석에는 `label_values_or_threshold`(긍정 결과를 뜻하는 값)가 **필수**입니다.
- **쓰는 순서(SK1)**: ① 데이터 단계에서 **CI·DPL**로 표본 불균형과 레이블 편향을 본다 → ② 훈련 후 같은 facet에 사후 지표를 계산한다 → ③ **DPL과 DPPL을 비교**한다. 어떤 지표가 맞는지는 **사람이 이해관계자와 협의해** 정합니다.

> 🧠 **원리** — 사전 지표는 모델 출력 없이 원본 데이터의 레이블·facet 분포만 비교하므로 **모델 훈련에 자원을 쓰기 전에** 계산할 수 있습니다. 반대로 사후 지표는 예측 레이블이 필요해 모델(또는 예측 결과)이 있어야 합니다.

### 10) 사후(post-training) 편향 지표 {#post-bias}

사후 지표는 데이터·레이블에 **모델의 예측 레이블**을 더해 계산합니다. 대부분은 **facet별 이진 분류 혼동 행렬의 숫자를 조합**한 값이고, 이 개념들을 동시에 모두 만족시킬 수는 없어 **사용 사례에 맞는 지표를 사람이 골라야** 합니다. 예측을 이진화하는 `probability_threshold` 기본값은 0.5입니다.

| 약어 | 이름 | 무엇을 비교하나 |
|---|---|---|
| **DPPL** | Difference in Positive Proportions in Predicted Labels | facet a·d의 **예측 양성 비율 차** |
| **DI** | Disparate Impact | 예측 양성 비율의 **비**(q′d ÷ q′a). 공식 예시는 a 60%·d 50% → `.5/.6 = 0.8`(문서 표기 그대로이고 정확히는 ≈0.83). **1이면 인구통계 평등**, 1 미만이면 a의 예측 양성 비율이 높음 |
| CDDPL | Conditional Demographic Disparity in Predicted Labels | 하위 그룹별 예측 레이블의 거절·수락 격차(사전 CDD를 **예측 레이블로** 계산) |
| **FT** | Counterfactual Fliptest | facet d의 각 구성원과 **가장 비슷한 facet a 구성원**(k-최근접 이웃)의 예측이 다른지 |
| **AD** | Accuracy Difference | facet 간 **예측 정확도 차**. 한계: Type I과 Type II 오류를 구분하지 못함 |
| **RD** | Recall Difference | facet 간 **재현율(TPR) 차** |
| SD | Specificity Difference | facet 간 **특이도(TNR) 차** |
| DAR | Difference in Acceptance Rates | facet 간 **정밀도 차**(예측 양성 중 TP 비율) |
| DRR | Difference in Rejection Rates | facet 간 **음성 예측의 정밀도 차**(예측 음성 중 TN 비율) |
| DCAcc | Difference in Conditional Acceptance | **관측 양성 대비 예측 양성** 비율의 facet 간 차 |
| DCR | Difference in Conditional Rejection | **관측 음성 대비 예측 음성** 비율의 facet 간 차 |
| TE | Treatment Equality | facet 간 **FP와 FN 비율**의 차 |
| **GE** | Generalized Entropy | 예측이 개별 입력에 준 **혜택의 불평등**. facet의 유리·불리와 무관. 0이면 불평등 없음 |

⚠️ **주석 두 개** — ① 요약표에 실린 사후 지표는 13개인데 **같은 페이지 본문은 "eleven"이라고 적습니다.** 개수는 암기 대상이 아닙니다. ② **DCAcc·DCR·TE는 요약표와 개별 페이지의 부호 해석·정의가 서로 다릅니다.** 이름·비교 대상·범위까지만 익히고 부호의 의미는 단정하지 않습니다.

**시험 단서 → 지표**

- "그룹 간 **예측 양성 비율**이 다른가?" → **DPPL**(차이) · **DI**(비율) · 하위 그룹까지 → CDDPL
- "그룹마다 **같은 정확도**인가?" → **AD** · "**재현율**이 다른가?" → **RD** · "**특이도**가 다른가?" → SD
- "수락 예측의 **정밀도**가 같은가?" → DAR · "거절 예측의 정밀도가 같은가?" → DRR
- "모든 특성이 비슷한 다른 그룹 사람과 **예측이 다른가**?" → **FT**
- "두 후보 모델 중 어느 쪽 결과 분포가 더 **불평등**한가?" → **GE**

**사전·사후의 짝** — 사전 **DPL**(관측 레이블) ↔ 사후 **DPPL**(예측 레이블), 사전 **CDD** ↔ 사후 **CDDPL**. 같은 질문을 관측 레이블로 묻는가 예측 레이블로 묻는가의 차이입니다.

> 🧠 **원리** — 사후 지표의 상당수는 facet별 혼동 행렬에서 나옵니다. RD는 TPR의 차, SD는 TNR의 차, DAR·DRR은 정밀도 계열의 차, AD는 정확도의 차입니다. 1)의 분류 지표 정의를 **facet a와 d에 따로 적용한 것**입니다.

### 11) 모델 출력 해석 — SHAP과 PDP {#explainability}

Clarify의 설명 가능성은 **모델 비의존(model-agnostic) 특성 기여도** 방식입니다. 기여도 분석은 디버깅에도 쓰입니다 — 모델이 잡음이거나 무관한 특성으로 추론하는지 확인할 수 있기 때문입니다.

| 방법 | 답하는 질문 | 산출물 |
|---|---|---|
| **SHAP** | 각 특성이 **이 예측**(로컬) 또는 **모델 전체**(글로벌)에 얼마나 기여했나 | 로컬 SHAP 값, 글로벌 SHAP 값, `expected_value`, 상위 글로벌 SHAP 막대 차트 |
| **PDP** | **한 특성 값을 바꾸면** 예측이 평균적으로 어떻게 변하나(다른 특성은 주변화) | 특성별 값·분포·예측, PDP 차트. `grid_resolution`으로 버킷 수 지정 |
| CV 설명 | 이미지의 어느 **슈퍼픽셀**이 예측에 영향을 줬나 | 슈퍼픽셀별 SHAP 값의 **히트 맵** |
| NLP 설명 | 어떤 **토큰·문장**이 기여했나 | 단위별 로컬 SHAP, 상위 토큰의 글로벌 SHAP(`granularity`: token·sentence·paragraph) |
| 시계열 설명 | 시간 단계·입력 변수가 얼마나 기여했나 | 비대칭 Shapley 값(`timewise`·`fine_grained`) |

- **Shapley 값의 원리**: 예측을 "게임", 특성을 "플레이어"로 봅니다. 특성 d개면 조합이 2^d개라 모두 훈련하는 것은 비현실적이므로 Clarify는 **Kernel SHAP** 근사를 씁니다. 특성별 값의 합은 모델 예측과 "특성이 없는 더미 모델" 예측의 차이에 해당합니다.
- **기준선이 중요한 이유**: 설명은 **기준선과의 편차**를 설명하므로 같은 예측도 기준선에 따라 설명이 달라집니다. 기준선을 주지 않으면 입력 데이터를 **K-means·K-prototypes로 클러스터링해 자동 계산**하고(1~12개 클러스터), 결과는 `explanations_shap/baseline.csv`에 저장됩니다.
- **재현성**: `seed`를 지정하면 같은 작업에서 일관된 SHAP 값이 나오고, **지정하지 않으면 같은 작업을 다시 돌릴 때 값이 조금 달라질 수 있습니다.** `num_samples`는 합성 데이터셋 크기와 작업 시간에 직접 영향을 줍니다(정밀도 대 시간). `agg_method` 기본값은 `mean_abs`입니다.
- **결과 파일**: `analysis.json`(편향 지표·특성 중요도) · 보고서(Notebook·HTML·PDF) · `explanations_shap/out.csv`(로컬 SHAP, 옵션). 글로벌 값은 로컬 값을 `agg_method`로 집계한 것이고 `expected_value`는 기준선 데이터셋의 평균 예측입니다.
- **운영 주의**: `shap`·`pdp`·`post_training_bias`에 모델 이름을 주면 Clarify가 **임시 엔드포인트(shadow endpoint)**를 만들고 끝나면 삭제합니다. ⚠️ 이 이름은 14)의 **섀도 테스트 shadow variant와 무관**합니다. 기존 엔드포인트를 지정하면 부하가 커지고 **합성 데이터가 엔드포인트 지표·캡처 데이터를 오염**시킬 수 있어 프로덕션 엔드포인트 사용은 권장되지 않습니다.
- **실시간 설명**: 실시간 엔드포인트에 Clarify explainer를 붙이면 `InvokeEndpoint` 응답에 예측과 설명이 함께 옵니다.

> 🧠 **원리** — Shapley 값은 "특성이 있을 때와 **기준선 값으로 대체했을 때**의 예측 차이"를 특성 조합 전반에 걸쳐 평균한 값입니다. Clarify는 기준선과 입력 사이에 합성 인스턴스를 만들어 계산하므로 **기준선과 `num_samples`가 결과와 실행 시간을 좌우**합니다.

### 12) Clarify 중단과 대체 경로 {#clarify-alternatives}

| Clarify 기능 | 공지가 안내하는 대체 |
|---|---|
| 사전·사후 편향 지표 | **표준화된 산식이므로 pandas·scikit-learn으로 직접 계산.** 산식은 Clarify 레퍼런스를 따르고 코드는 자체 파이프라인에서 소유·테스트·버전 관리. 결과를 **SageMaker AI MLflow**에 기록해 계보·거버넌스를 훈련 실행과 함께 관리 |
| SHAP 특성 기여도 | **SHAP 라이브러리 직접 사용** — Clarify가 내부에서 쓰는 것과 같은 엔진 |
| 편향·기여도 드리프트 모니터링 | AWS 오픈소스 모니터링 솔루션(EventBridge + Lambda + Athena + MLflow + SNS + QuickSight 패턴) |
| 파운데이션 모델 평가 | `fmeval` 라이브러리, **Amazon Bedrock Evaluations**(관리형), Bedrock Guardrails(런타임 안전). ⚠️ 단 **Bedrock Evaluations는 예측형(표 형식·고전 ML) 편향 감지·설명의 대체가 아닙니다** |
| Pipelines의 `ClarifyCheckStep` | 표준 지표 계산과 SHAP을 돌리는 `ProcessingStep` |
| 기존 산출물 | `analysis.json`·`explanations_shap/out.csv`·글로벌 SHAP·PDP·제약 파일은 S3에 남으므로 감사 목적이면 보관 |

- 묶음 공지는 **다른 SageMaker AI 기능의 가용성에는 영향이 없다**고 명시하며, 같은 페이지의 기능 목록에는 Feature Store·Canvas·Autopilot·Experiments·Pipelines가 그대로 남아 있습니다.

### 13) 재현 가능한 실험 {#reproducibility}

ML Lens는 **릴리스마다 변경을 추적하는 계보 추적 시스템이 재현성을 가능하게** 한다고 설명하고, 추적 대상으로 원본·가공 데이터, 특성 세트, 모델 파라미터, 코드 버전, 훈련 환경, 배포 구성을 듭니다. ⚠️ 가이드 SK3은 서비스 이름 없이 "AWS 서비스를 사용하여 재현 가능한 실험 수행"이라고만 적으므로 **하나를 정답으로 못 박지 않습니다.**

| 도구 | 기록·관리하는 것 | 상태·주의 |
|---|---|---|
| **SageMaker Experiments** | 반복 실험의 입력·파라미터·설정·결과를 **run**으로 자동 추적하고 run들을 **experiment**로 묶음 | ⚠️ Python SDK 추적은 **Studio Classic에서만** 가능하고 문서는 MLflow 통합을 권장. Studio Classic은 신규 온보딩 불가 |
| **관리형 MLflow** | run·파라미터·지표·아티팩트 추적, 실행 비교, MLflow Model Registry → SageMaker Model Registry 자동 등록, 배포 | 추적 서버는 컴퓨트 + 백엔드 메타데이터 저장소 + **내 계정의 S3 아티팩트 저장소**. **MLflow App이 최신 관리형 제품** |
| **Model Registry** | 모델 그룹·버전, 훈련 지표 메타데이터, 승인 상태, CI/CD | "모델 계보를 보고 추적 가능성·재현성을 확보"(상세는 Task 2.2 문서 14) |
| **ML Lineage Tracking** | 훈련 작업·데이터셋·파이프라인·엔드포인트·모델 사이 관계를 **백엔드에서 자동 기록** | 정확한 데이터셋에 접근할 수 있으면 같은 워크플로를 다시 만들어 재현. ⚠️ 문서에 Studio Classic 공지가 붙어 있음 |
| **시드(seed)** | AMT 튜닝 시드 · XGBoost `seed` · Clarify SHAP `seed` | 아래 표 |
| 데이터·코드 버전 관리 | 코드·구성·파이프라인 정의는 Git, 데이터는 DVC 같은 도구 | DVC는 AWS 서비스가 아님 |

**시드의 효과** — AMT에서 같은 시드를 쓰면 **Random·Hyperband는 같은 튜닝 작업에서 이전 구성을 최대 100% 재현**하고 Bayesian은 재현성이 개선됩니다. Grid는 모든 조합을 체계적으로 탐색하므로 같은 하이퍼파라미터면 최적값이 작업 간 동일합니다. XGBoost `seed`의 기본값은 0이고, Clarify SHAP은 시드를 주지 않으면 값이 조금 달라질 수 있습니다.

> 🧠 **원리** — 계보 추적은 "이 모델을 만든 데이터·코드·파라미터·환경"의 연결 관계를 서비스가 자동 기록하는 것이고, **재현은 그 기록을 따라 같은 입력으로 워크플로를 다시 돌리는 것**입니다. 문서도 **정확한 데이터셋에 접근할 수 있어야** 같은 모델을 재현한다고 못 박습니다. 확률적 단계는 시드로 고정합니다.

### 14) 섀도 변형 vs 프로덕션 변형 {#shadow-ab}

엔드포인트 하나 뒤에 여러 모델·버전을 **변형(variant)**으로 둘 수 있습니다. 같은 엔드포인트의 모든 변형은 같은 추론 코드를 공유하고, 인스턴스 유형이나 모델이 달라도 되며 서로 독립적으로 오토스케일됩니다. 유형은 **production variant**와 **shadow variant** 둘입니다.

| 항목 | 섀도 테스트 | 프로덕션 변형 가중치(A/B) |
|---|---|---|
| **요청 처리** | 프로덕션 변형이 요청의 **100%**를 받아 응답. 섀도 변형은 복제된 일부를 받지만 **응답을 반환하지 않는다** | 요청이 가중치에 따라 **한 변형에만** 라우팅되고 그 변형이 호출자에게 응답 |
| 사용자 영향 | **없음**. 섀도 응답은 폐기하거나 오프라인 비교용으로 기록 | 새 변형으로 간 요청의 응답이 **실제 사용자에게 간다** |
| 쓰는 이유 | 모델·컨테이너·인스턴스 변경을 **사용자 영향 없이** 검증. 지연 시간·오류율 같은 **운영 성능** 확인 | 새 모델과 기존 모델을 **실제 트래픽**으로 비교해 더 나은 쪽으로 교체 |
| 설정 | 콘솔 Inference → Shadow tests, 또는 `CreateEndpointConfig`의 `ShadowProductionVariants` / 추론 실험(`Type` = `ShadowMode`) | 엔드포인트 구성의 `InitialVariantWeight`(미지정 기본 1.0, 비율 = 해당 가중치 ÷ 전체 합) |
| 개수 제한 | **엔드포인트당 shadow variant 1개**이고, 섀도가 있으면 production variant도 **1개** | production variant를 여러 개 둘 수 있음 |
| 기간 | **기본 7일, 최소 1시간·최대 30일.** 끝나면 엔드포인트가 시험 이전 상태로 복귀 | 기간 개념 없음 — 가중치를 직접 조정 |
| 비율 조정 | `SamplingPercentage`(최대 100). 진행 중에도 변경 가능 | `UpdateEndpointWeightsAndCapacities`로 **엔드포인트 갱신 없이** 가중치 변경 |
| 비교 지표 | 콘솔 대시보드가 양쪽의 `Invocations`·`ModelLatency`·`Invocation4XXErrors`·`Invocation5XXErrors`·`CPUUtilization` 등을 나란히 보여 줌. ⚠️ **정확도 같은 모델 품질은 Data Capture로 요청·응답을 기록해 오프라인 비교** | 변형별 지연·호출이 CloudWatch로. 예제는 변형마다 정확도·정밀도·재현율·F1·AUC를 계산해 비교 |
| 승격 | 대시보드의 **Deploy shadow variant**. 섀도·사용자 지정 설정을 쓰려면 **100% 샘플링으로 시험하라고 권장**. 승격하면 기존 프로덕션 변형이 빠지고 섀도가 대체 | 가중치를 옮김(예: 50:50 → 25:75 → 0:100 후 이전 변형 삭제) |
| 호환 불가 | **서버리스 추론·비동기 추론·Marketplace 컨테이너·다중 컨테이너·다중 모델 엔드포인트·Inf1 인스턴스**는 섀도 테스트 불가 | 문서에 같은 제한 목록 없음 |

- 섀도 테스트·A/B는 2026-07-30 중단 묶음의 대상이 **아닙니다.**

> 🧠 **원리** — 섀도는 "요청을 복제하되 **응답은 버리는**" 구조라 사용자는 프로덕션 응답만 받고, 새 변형의 지연·오류를 실제 트래픽에서 안전하게 측정합니다. A/B는 "요청을 가중치로 나눠 **한 변형에만** 보내는" 구조라 두 모델을 실제 결과로 비교할 수 있는 대신 새 변형의 응답이 사용자에게 전달됩니다.

### 15) 성능·훈련 시간·비용의 절충 {#tradeoffs}

ML Lens는 트레이드오프 분석을 "**경쟁하는 요구**(정확도·복잡도·편향·공정성·운영 제약)를 균형 맞추는 모델 구성을 찾는 일"로 정의하고 **수명주기 내내 다시 평가**하라고 합니다. 안티패턴은 ① **정확도만 보는 것** ② 편향을 무시하는 것 ③ 단순 모델로 충분한데 복잡한 모델을 배포하는 것입니다.

> 📍 각 수단의 설정·제약(조기 중지 층위·튜닝 전략·스팟·분산·인스턴스 선택)은 **Task 2.2 문서**가 정본입니다. 여기서는 **평가 관점의 절충**만 봅니다.

| 축 | 무엇을 내주고 무엇을 얻나 |
|---|---|
| **정확도 ↔ 설명 가능성** | 단순 모델이 설명·배포가 쉽지만 정확도를 일부 포기할 수 있다. 단순 선형부터 딥러닝까지 복잡도별로 시험해 **기준 모델 대비 개선**과 함께 평가한다 |
| **정확도 ↔ 시간·비용** | 큰 작업의 튜닝은 Hyperband로, 하이퍼파라미터 수·범위를 좁히면 계산 시간이 줄어든다. 단 **범위가 너무 넓으면 일반화가 약한 모델**이 나올 수 있다 |
| **견고성 ↔ 시간** | 교차 검증은 과적합·선택 편향을 줄이는 대신 훈련 시간을 **평균 20%** 늘린다. Autopilot은 100 MB 미만에 앙상블 모드를 권장한다 |
| **비용 ↔ 완료 시점** | 관리형 스팟은 온디맨드 대비 **최대 90% 절감**이지만 중단으로 완료가 늦어질 수 있다(체크포인트로 재개) |
| **속도 ↔ 확장 효율** | 분산 훈련은 시간을 줄이지만 **클러스터가 커질수록 통신 오버헤드**로 전체 계산 성능이 떨어진다. 단순 모델은 큰 인스턴스에서 더 빨라지지 않는다 |
| **정밀도 ↔ 재현율** | 두 오류 유형의 **상대 비용**으로 임계값을 조정한다. 과소적합(높은 편향)과 과적합(높은 분산)도 체계적 실험으로 균형을 잡는다 |

- ⚠️ 자원 활용률(GPU·CPU)로 인스턴스를 줄이는 근거는 원래 Debugger의 시스템 모니터링이 제공했고, 대체는 **CloudWatch**입니다.

---

## ✍️ 시험 포인트

- 시나리오가 깔아 둔 **오류 비용**을 먼저 읽습니다. "놓치면 치명적"(암 검사·충돌 탐지) → **재현율**, "잘못 통과시키면 치명적"(안전 판정) → **정밀도**, 둘 다 → F1 또는 임계값 조정.
- **클래스 불균형이 보이면 정확도는 오답**입니다. BalancedAccuracy·AUPRC·F1 쪽을 봅니다. **AUPRC는 TN을 고려하지 않아** TN이 압도적인 데이터에 맞습니다.
- **AUC 0.5는 무작위**, 0에 가까우면 예측이 거꾸로 나오는 신호입니다. AUC는 임계값에 독립적입니다.
- RMSE는 **스케일 의존**이라 크기가 다른 데이터셋끼리 비교하면 안 됩니다. 잔차 히스토그램이 0을 중심으로 하지 않으면 변수를 더 넣을 여지가 있습니다.
- "baseline"이 나오면 **어느 baseline인지** 먼저 가릅니다 — 비교용 단순 모델(①), Model Monitor 운영 기준선(②), SHAP 설명 기준선(③).
- 과적합·과소적합은 **훈련 오차와 평가 오차를 함께** 봅니다. "훈련에서도 나쁘다"는 과소적합의 결정적 단서입니다.
- 편향 지표는 **모델 예측이 필요한가**로 사전·사후를 가릅니다. 데이터만 있으면 CI·DPL, 예측이 있어야 DPPL·DI·RD·AD입니다. **DPL ↔ DPPL** 비교가 "훈련이 편향을 키웠나"를 답합니다.
- **SHAP은 기여도, PDP는 한계 효과**입니다. "한 특성 값을 바꾸면 예측이 어떻게 변하나"는 PDP입니다. 설명은 **기준선 대비**이고 기준선을 바꾸면 설명이 달라집니다.
- 섀도는 **응답을 반환하지 않고** A/B는 반환합니다. "사용자 영향 없이 새 모델의 지연·오류를 보고 싶다"면 섀도, "실제 결과로 두 모델을 비교"하면 A/B입니다.
- 상태 문항 주의: **Clarify·Debugger·Model Monitor는 신규 고객 중단**, **Profiler는 2027-06-30 지원 종료**, 섀도 테스트·A/B는 영향이 없습니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 불균형 데이터에서 정확도로 판정한다 | 양성이 1%면 전부 음성이라 답해도 99%다. **BalancedAccuracy·AUPRC·F1**을 본다 |
| 재현율만 올려 "좋은 모델"로 본다 | **전부 양성으로 예측하면 재현율이 만점**이다. 정밀도와 함께 본다 |
| TN이 압도적인 데이터에서 ROC-AUC만 본다 | FPR의 분모에 TN이 들어가 낙관적으로 보인다 — **AUPRC**가 더 정직하다 |
| 스케일이 다른 데이터셋의 RMSE를 비교한다 | RMSE는 **스케일 의존**이다. 비교하려면 같은 스케일이거나 R2·MASE 같은 정규화 지표를 쓴다 |
| 사전 편향 지표를 모델 예측으로 계산한다 | 사전 지표는 **모델 출력에 의존하지 않는다**(모델 훈련 전에 계산 가능). 예측이 필요한 쪽은 사후 지표다 |
| DPL과 DPPL을 같은 지표로 본다 | DPL은 **관측 레이블**, DPPL은 **예측 레이블**의 양성 비율 차다. 둘을 비교하면 훈련이 편향을 키웠는지 보인다 |
| SHAP과 PDP를 섞어 고른다 | SHAP은 **특성의 기여도**, PDP는 **특성 값을 바꿀 때의 한계 효과**다 |
| Clarify의 shadow endpoint를 섀도 테스트로 읽는다 | Clarify가 만드는 임시 엔드포인트는 계산용이고, **섀도 테스트의 shadow variant와 무관**하다 |
| 섀도 테스트로 모델 정확도를 바로 비교한다 | 섀도 대시보드는 **운영 지표**(지연·오류·자원)다. 정확도는 **Data Capture로 기록해 오프라인 비교**한다 |
| 섀도 변형을 여러 개 붙인다 | 엔드포인트당 shadow variant는 **1개**이고, 섀도가 있으면 production variant도 1개다 |
| 세 가지 baseline을 섞는다 | 비교용 단순 모델 · Model Monitor 운영 기준선 · SHAP 설명 기준선은 **목적도 만드는 방법도 다르다** |
| Debugger 딥러닝 규칙을 XGBoost에 붙인다 | `dead_relu`·`vanishing_gradient` 등은 **딥러닝 프레임워크 전용**이다 |
| 학습 데이터로 성능을 재고 판정한다 | 학습에 쓴 데이터로 재면 **암기를 보상**한다. 모델 선택까지 하려면 검증용도 따로 둔다 |

---

## 🧪 자가 점검

**Q1.** 사기 거래가 전체의 0.2%다. 정확도 대신 무엇을 보고, 학습 단계에서 쓸 수 있는 보정 수단은? (→ 4) 지표 선택)

<details><summary>정답 보기</summary>

정확도는 전부 "정상"이라고 답해도 99.8%가 나오므로 쓸 수 없습니다. **BalancedAccuracy·F1·AUPRC**를 봅니다 — 특히 **AUPRC는 TN을 고려하지 않아** TN이 압도적인 이 데이터에 맞습니다. 학습 단계 보정은 **클래스 가중치**(`scale_pos_weight` 등)이고, 데이터 쪽에서는 리샘플링·SMOTE가 있습니다.
</details>

**Q2.** 임계값을 0.5에서 0.8로 올렸다. FP와 FN은 각각 어떻게 움직이고, 그 결과 어느 지표가 올라가는가? (→ 2) 곡선 지표)

<details><summary>정답 보기</summary>

양성 판정을 더 까다롭게 하므로 **FP는 줄고 FN은 늘어납니다.** 따라서 **정밀도가 올라가고 재현율이 내려갑니다.** 참고로 **AUC는 임계값에 독립적**이라 이 조작으로 변하지 않습니다 — 임계값 조정으로 AUC를 올리겠다는 선택지는 틀립니다.
</details>

**Q3.** 잔차 히스토그램의 중심이 0보다 왼쪽에 있다. 모델이 어느 방향으로 틀리고 있고, 문서가 제시하는 조치는? (→ 3) 회귀 지표)

<details><summary>정답 보기</summary>

잔차는 **실제값 − 예측값**이므로 중심이 음수라는 것은 예측이 실제보다 크다는 뜻, 즉 **체계적으로 과대 예측**하고 있습니다. 히스토그램이 0을 중심으로 한 종 모양이 아니면 오차에 구조가 남아 있다는 신호이고, 문서는 **변수를 더 넣는 것이 도움이 될 수 있다**고 안내합니다. 표준화 잔차에서는 절댓값이 3보다 큰 점을 일반적으로 이상치로 봅니다.
</details>

**Q4.** 동료가 "baseline을 만들었다"고 한다. 세 가지 중 어느 것인지 가르는 질문 하나는? (→ 5) 기준선)

<details><summary>정답 보기</summary>

**"그걸 무엇과 비교하려고 만들었나?"** — ① 내 모델의 성능과 비교할 **단순 모델**이면 성능 기준선 ② 운영 중 들어오는 데이터의 통계와 비교할 것이면 **Model Monitor 운영 기준선** ③ 특정 예측의 기여도를 설명할 기준점이면 **SHAP 설명 기준선**입니다. 세 번째는 기준선을 바꾸면 설명 자체가 달라진다는 점이 특징입니다.
</details>

**Q5.** 훈련 손실은 계속 줄지만 검증 손실이 다시 늘기 시작했다. 현상 이름과 해당 Debugger 규칙은? (→ 6) 식별, 7) 수렴)

<details><summary>정답 보기</summary>

**과적합·과훈련**이고 Debugger 규칙은 **`overfit`과 `overtraining`**입니다. `overfit`은 검증 손실과 훈련 손실을 비교해 과적합을 탐지하고, `overtraining`은 둘이 모두 줄다가 개선이 멈춘 뒤에도 학습을 이어가 검증 손실이 다시 증가하는 상황을 다룹니다. ⚠️ Debugger는 **신규 고객에게 닫혀** 있어 새 계정에서는 대체 경로를 봐야 합니다(→ 12)).
</details>

**Q6.** 아직 모델을 학습시키지 않았는데 데이터의 편향을 보려 한다. 어느 지표 묶음이고 대표 두 개는? (→ 9) 사전 편향)

<details><summary>정답 보기</summary>

**사전(pre-training) 편향 지표** 묶음입니다 — 모델 예측이 필요 없고 데이터만으로 계산합니다. 대표는 **CI**(그룹의 **수**가 치우쳤는지)와 **DPL**(**긍정 레이블 비율**이 치우쳤는지)입니다. 예측이 있어야 계산되는 DPPL·DI·RD·AD는 사후 지표이므로 이 단계에서는 쓸 수 없습니다.
</details>

**Q7.** "그룹 간 예측 양성 비율의 비가 1인가"를 묻는 지표와, 같은 질문을 차로 묻는 지표는? (→ 10) 사후 편향)

<details><summary>정답 보기</summary>

**비는 DI(Disparate Impact)**, **차는 DPPL(Difference in Positive Proportions in Predicted Labels)**입니다. DI는 1이면 인구통계 평등이고, DPPL은 0이면 같습니다. 그리고 **DPL(레이블) ↔ DPPL(예측)**을 비교하면 "훈련이 양성 비율 편향을 키웠는가"를 답할 수 있습니다(DPPL > DPL이면 증가).
</details>

**Q8.** 새 모델의 지연 시간과 오류율을 사용자 영향 없이 실제 트래픽에서 보려 한다. 무엇을 쓰고, 그것으로 알 수 없는 것은? (→ 14) 섀도·A/B)

<details><summary>정답 보기</summary>

**섀도 테스트**입니다. 같은 엔드포인트에 섀도 변형을 띄워 요청 **사본**을 보내고 **프로덕션 변형의 응답만** 호출자에게 돌려주므로 사용자 영향이 없습니다. 알 수 없는 것은 **새 모델의 응답이 실제 사용자 행동에 미치는 효과**(전환율 같은 비즈니스 결과)입니다 — 그것을 재려면 응답이 사용자에게 가는 **A/B**(프로덕션 변형 가중치)로 가야 합니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며, C01 시험 범위는 아닙니다.

- **C02 대응 Task**: 2.3 「ML 및 AI 시스템의 성능을 분석하고 평가합니다」
- **추가된 항목 4개**
  - `2.3.7` **통합형 인적 평가 프레임워크**를 구현합니다(예: HITL 워크플로, 텍스트 생성 품질 평가).
  - `2.3.8` **자연어 처리(NLP) 평가 지표**를 적용합니다(예: BLEU, ROUGE, BERTScore, 시맨틱 유사성).
  - `2.3.9` **AI 평가**를 수행합니다(예: 모델 출력 평가, 콘텐츠 품질 검증, 편향 탐지, 평가형 LLM 프레임워크).
  - `2.3.10` 검색 정확도 평가를 포함한 **RAG 시스템 모니터링**을 구성합니다.
- **삭제된 항목**: 이 Task에는 없음
- 읽는 법: C01의 지표 체계(1~4)와 기준선·진단(5~7)은 그대로 쓰이고, C02는 여기에 **생성형 출력을 어떻게 평가하는가**를 더합니다. 12)에 적은 `fmeval`·Bedrock Evaluations가 그 방향의 출발점입니다.

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- 지표: [Metrics and validation (Autopilot)](https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-metrics-validation.html) · [Autopilot 성능 보고서](https://docs.aws.amazon.com/sagemaker/latest/dg/autopilot-model-insights.html) · [AutoMLJobObjective](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_AutoMLJobObjective.html) · [시계열 목적 지표](https://docs.aws.amazon.com/sagemaker/latest/dg/timeseries-objective-metric.html) · [Tune an XGBoost Model](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost-tuning.html) · [XGBoost 하이퍼파라미터](https://docs.aws.amazon.com/sagemaker/latest/dg/xgboost_hyperparameters.html)
- 기준선·절충: [MLPERF04-BP02 성능 개선 대안 탐색](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf04-bp02.html) · [MLPERF04-BP05 절충 분석](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf04-bp05.html) · [Model Monitor 기준선](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-create-baseline.html) · [모델 품질 기준선](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-model-quality-baseline.html) · [Model Monitor 가용성 변경](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html) · [MLCOST04-BP01 인스턴스 크기](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp01.html)
- 수렴·Debugger: [Amazon SageMaker Debugger](https://docs.aws.amazon.com/sagemaker/latest/dg/train-debugger.html) · [내장 규칙 목록](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-built-in-rules.html) · [텐서 저장 구성](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-configure-hook.html) · [규칙 내장 액션](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-built-in-actions.html) · [Debugger 가용성 변경](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-availability-change.html) · [Profiler 가용성 변경](https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html) · [Debugger Insights 대시보드](https://docs.aws.amazon.com/sagemaker/latest/dg/debugger-on-studio-insights-walkthrough.html)
- Clarify 편향: [처리 작업 구성](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-configure-processing-jobs.html) · [사전 데이터 편향](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-detect-data-bias.html) · [사전 편향 지표](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-data-bias.html) · [사후 편향 지표](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-measure-post-training-bias.html) · [CI](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-bias-metric-class-imbalance.html) · [DPL](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-data-bias-metric-true-label-imbalance.html) · [DPPL](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-dppl.html) · [DI](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-di.html) · [AD](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-ad.html) · [RD](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-rd.html) · [FT](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-ft.html) · [GE](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-ge.html) · [CDDPL](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-post-training-bias-metric-cddpl.html)
- Clarify 설명: [Model Explainability](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-explainability.html) · [Shapley 값 기여도](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-shapley-values.html) · [SHAP 기준선](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-feature-attribute-shap-baselines.html) · [분석 설정 파일](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-processing-job-configure-analysis.html) · [분석 결과](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-processing-job-analysis-results.html) · [온라인 설명](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-online-explainability.html) · [Clarify 가용성 변경](https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html)
- 재현성: [Experiments (Studio Classic)](https://docs.aws.amazon.com/sagemaker/latest/dg/experiments.html) · [관리형 MLflow](https://docs.aws.amazon.com/sagemaker/latest/dg/mlflow.html) · [MLflow App 설정](https://docs.aws.amazon.com/sagemaker/latest/dg/mlflow-app-setup.html) · [ML Lineage Tracking](https://docs.aws.amazon.com/sagemaker/latest/dg/lineage-tracking.html) · [Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html) · [MLOPS03-BP02 추적·버전 관리](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops03-bp02.html) · [MLOPS02-BP04 계보 추적](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops02-bp04.html) · [AMT 모범 사례](https://docs.aws.amazon.com/sagemaker/latest/dg/automatic-model-tuning-considerations.html)
- 섀도·A/B: [Validation of models in production](https://docs.aws.amazon.com/sagemaker/latest/dg/model-validation.html) · [Shadow tests](https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests.html) · [섀도 테스트 생성](https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests-create.html) · [섀도 테스트 모니터링](https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests-view-monitor-edit-dashboard.html) · [섀도 변형 승격](https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests-complete.html) · [프로덕션 변형 테스트](https://docs.aws.amazon.com/sagemaker/latest/dg/model-ab-testing.html) · [섀도 변형 배포](https://docs.aws.amazon.com/sagemaker/latest/dg/model-shadow-deployment.html) · [CreateInferenceExperiment](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_CreateInferenceExperiment.html) · [ProductionVariant](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ProductionVariant.html)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/2-3.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
