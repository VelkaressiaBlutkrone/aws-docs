---
examGuideTaskId: mla-t4-2
certCode: MLA-C01
domain: 4
domainName: ML 솔루션 모니터링·유지 관리·보안
domainWeightPct: 24
title: 인프라·비용 모니터링과 최적화 (지연 분해·CloudTrail·적정 규모·구매 옵션·태깅)
coversTasks:
  - "4.2"
sources:
  - title: Amazon SageMaker AI metrics in Amazon CloudWatch (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html
  - title: What is AWS X-Ray? (공식 문서)
    url: https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html
  - title: Analyzing log data with CloudWatch Logs Insights (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
  - title: Using Amazon CloudWatch alarms (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Alarms.html
  - title: Logging Amazon SageMaker AI API calls using AWS CloudTrail (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/logging-using-cloudtrail.html
  - title: AWS CloudTrail — Creating a trail for your AWS account (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html
  - title: Amazon EventBridge — AWS service events delivered via AWS CloudTrail (공식 문서)
    url: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-event-cloudtrail.html
  - title: Amazon SageMaker Inference Recommender (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender.html
  - title: Compute Optimizer — Viewing idle resource recommendations (공식 문서)
    url: https://docs.aws.amazon.com/compute-optimizer/latest/ug/view-idle-recommendations.html
  - title: Organizing and tracking costs using AWS cost allocation tags (공식 문서)
    url: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html
  - title: Savings Plans types (공식 문서)
    url: https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html
  - title: Managed Spot Training in Amazon SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html
  - title: Deploy models with Amazon SageMaker Serverless Inference (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html
  - title: Inference cost optimization best practices (SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 인프라·비용 모니터링과 최적화 (지연 분해·CloudTrail·적정 규모·구매 옵션·태깅)

> **커버하는 공식 Task** — MLA-C01 · 도메인 4 「ML 솔루션 모니터링, 유지 관리 및 보안」(24%) · **Task 4.2 인프라 및 비용 모니터링 및 최적화** (`mla-t4-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. ⚠️ **도메인 4에서 가이드 항목이 가장 많은 Task**(지식 6 · 기술 10)여서 다루는 서비스 수도 가장 많습니다. 4.1이 "모델이 나빠졌는가"였다면 4.2는 **"인프라가 느리거나 비싼가, 그리고 어디를 고치는가"** 입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 지연을 **모델·오버헤드·네트워크**로 분해하고 각 구간의 지표와 조치를 짝짓는다
- [ ] 호출 지표와 인스턴스 지표의 **네임스페이스를 구분**하고, 게시 주기·`EnableEnhancedMetrics`·값 읽는 법을 안다
- [ ] X-Ray · Lambda Insights · Logs Insights가 **보는 단위**를 가르고, 경보 3종을 용도로 고른다
- [ ] CloudTrail의 **관리 이벤트와 데이터 이벤트**를 구분하고 추적(trail)을 만드는 이유와 절차를 말한다
- [ ] 재훈련 호출 경로(CloudTrail → EventBridge → Pipelines)와 **추적이 필요한 이유**를 설명한다
- [ ] 인스턴스 범주 4종을 용도로 고르고, **Inference Recommender와 Compute Optimizer의 입력 차이**를 안다
- [ ] 비용 도구 4종(Cost Explorer·Budgets·Trusted Advisor·CUR)의 역할을 가르고, **비용 할당 태그는 활성화가 별도 단계**임을 안다
- [ ] 구매 옵션에서 **가격 약정과 용량 예약을 구분**하고, 쿼터·동시성·오토 스케일링으로 용량 문제를 진단한다

> **이 문서가 다루는 것** — 1) 핵심 성능 지표 5종 · 2) CloudWatch 네임스페이스 · 3) 지연 분해 · 4) 관찰성 도구 3종 · 5) 경보·대시보드 · 6) CloudTrail · 7) EventBridge와 재훈련 호출 · 8) 인스턴스 범주와 적정 규모 도구 · 9) 비용 분석·통제 도구 · 10) 태깅과 비용 할당 태그 · 11) 구매 옵션 · 12) 용량 문제 해결 · 13) 진단표 · 14) 비용 최적화 종합 · 15) ⚠️ 서비스 수명·명칭 · 16) 도구 고르기

---

## 🎯 왜 중요한가

4.2는 **서비스 이름이 가장 많이 나오는 Task**입니다. 그래서 암기 과목처럼 보이지만, 실제로 묻는 것은 두 질문뿐입니다.

**① 이 증상의 원인이 어디인가.** "엔드포인트가 느리다"는 증상 하나에 모델·오버헤드·네트워크 세 가지 원인이 있고, 각각 조치가 완전히 다릅니다. 원인을 가르지 않고 인스턴스만 키우면 오버헤드·네트워크 문제에는 효과가 없습니다.

**② 이 질문에 답하는 도구가 무엇인가.** 네 서비스가 늘 함께 나옵니다.

| 질문 | 서비스 |
|---|---|
| 누가·언제·어떤 API를 호출했나 | **CloudTrail**(감사) |
| 지금 얼마나 느리고 바쁜가 | **CloudWatch**(지표·로그·경보) |
| 상태가 바뀌면 무엇을 자동 실행하나 | **EventBridge**(라우터) |
| 요청 하나가 어느 구간에서 시간을 썼나 | **X-Ray**(요청 추적) |

비용 쪽도 같은 구조입니다 — Cost Explorer는 **분석**, Budgets는 **통제**, Trusted Advisor는 **권고**, CUR은 **원천 데이터**입니다. 그리고 가장 자주 나오는 함정 하나 — **태그를 달기만 하면 Cost Explorer에 보이지 않습니다.** 비용 할당 태그로 **활성화**하는 별도 단계가 있습니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **네 서비스의 역할**: 감사 → **CloudTrail** · 지표·경보 → **CloudWatch** · 상태 변화 자동 대응 → **EventBridge** · 구간별 요청 추적 → **X-Ray**. 로그 패턴 집계는 **Logs Insights**, Lambda 구간은 **Lambda Insights**
- **지연 3분할**: `ModelLatency`(컨테이너 통신 + 추론) · `OverheadLatency`(전체 − `ModelLatency`) · 네트워크(**SageMaker 지표 없음**). ⚠️ CloudWatch는 **마이크로초**, Inference Recommender 결과와 `ClientLatency`는 **밀리초**
- **네임스페이스 둘**: 호출(요청)은 **`AWS/SageMaker`** · 인스턴스(자원)는 **`/aws/sagemaker/Endpoints`**. 게시 주기 기본 1분, 호출 지표를 바꾸려면 **`EnableEnhancedMetrics=True`**
- ⚠️ **데이터 이벤트는 기본 미기록이고 이벤트 기록(90일)에도 남지 않는다.** `InvokeEndpoint`는 `AWS::SageMaker::Endpoint` **데이터 이벤트로 옵트인**, `CreateEndpoint` 등은 관리 이벤트로 기본 기록
- **추적(trail)이 필요한 이유 둘**: 90일 초과 보관 · 데이터 이벤트 기록. ⚠️ **EventBridge가 CloudTrail 이벤트를 받으려면 로깅 중인 추적이 있어야** 한다(`AWS API Call via CloudTrail`)
- **적정 규모 도구 둘**: **Inference Recommender** = 모델 + 샘플 페이로드로 **모의 부하 테스트**(배포 전) · **Compute Optimizer** = 이미 쌓인 CloudWatch 지표(기본 14일). ⚠️ 문서가 SageMaker 엔드포인트에 명시하는 것은 **유휴 권장(14일 호출 0건)** 이다
- **비용 도구 4분할**: **Cost Explorer**(분석·예측, 알림 아님) · **Budgets**(임계 알림·작업) · **Trusted Advisor**(점검 권고, 전체 점검은 유료 지원 플랜) · **CUR**(가장 상세한 원천 데이터 → Athena·Quick)
- ⚠️ **태그는 달기만 하면 안 보인다.** AWS 생성(`aws:`)·사용자 정의(`user:`) **둘 다 각각 활성화**해야 하고, 반영에 최대 24시간(필터에 뜨기까지 24~48시간)
- **가격 약정 ≠ 용량 예약**: **SageMaker AI Savings Plans**는 시간당 사용량 약정(1·3년, 최대 64%)이고 **용량을 보장하지 않는다.** 확정 시점의 용량은 **훈련 플랜**, 중단 허용 훈련은 **관리형 스팟(최대 90%) + 체크포인트**(⚠️ 온디맨드 폴백 없음)
- **용량 문제 3분할**: `ResourceLimitExceeded` → **Service Quotas 계정 수준 증설**(미리 요청) · 서버리스 콜드 스타트 → **Provisioned Concurrency**(≤ `MaxConcurrency`, 엔드포인트당 **최대 200**) · 스케일 반응이 느림 → **Datapoints to alarm·쿨다운·쿼터·AZ 용량**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **관리 이벤트 / 데이터 이벤트** | CloudTrail의 두 범주. 리소스를 **관리**하는 작업(제어 평면) vs 리소스 **안·위**에서 일어나는 고빈도 작업(데이터 평면) |
| **이벤트 기록(Event history)** | 계정 생성과 함께 켜지는, 리전별 최근 **90일 관리 이벤트**의 변경 불가 조회 기록 |
| **추적(trail)** | 이벤트를 S3(·CloudWatch Logs)로 전송하는 구성. 90일 초과 보관과 데이터 이벤트 기록의 전제 |
| **적정 규모 조정(rightsizing)** | 실제 사용량에 맞게 인스턴스 유형·크기를 조정하는 일 |
| **비용 할당 태그** | 리소스 태그를 **결제 쪽에서 활성화**해 비용을 분해할 수 있게 만든 것 |
| **Savings Plans** | 시간당 사용량($/hour)을 1년 또는 3년 약정해 할인받는 **가격** 약정. 용량 보장이 아니다 |
| **`MaxConcurrency` / Provisioned Concurrency** | 서버리스 엔드포인트가 동시에 처리할 호출의 **상한** vs 그 안에서 **미리 데워 두는 몫** |
| **쿨다운(cooldown)** | 스케일링 직후 다음 조정까지 기다리는 시간. 용량의 급격한 변동을 막는 장치 |

---

## 📖 핵심 개념

### 1) 핵심 성능 지표 5종과 ML Lens 원칙 {#infra-kpis}

가이드는 ML 인프라의 주요 성능 지표 예시로 **활용률 · 처리량 · 가용성 · 확장성 · 내결함성**을 듭니다. ⚠️ **공식 문서에서 이 다섯을 한 문장으로 정의한 곳은 없습니다.** 아래 표는 ML Lens의 문장들을 SageMaker AI 지표에 이어 붙인 **학습용 정리**이며 표 자체가 AWS 문장은 아닙니다.

| 개념 | 묻는 질문 | SageMaker AI에서 보는 곳 |
|---|---|---|
| **활용률** | 인스턴스가 얼마나 일하는가 → 과소·과다 프로비저닝 판단 | `CPUUtilization`·`MemoryUtilization`·`DiskUtilization`·`GPUUtilization` |
| **처리량** | 단위 시간에 몇 건을 처리하는가 | `Invocations`(Sum), `InvocationsPerInstance` |
| **가용성** | 요청에 계속 응답하는가 | 다중 인스턴스·다중 AZ 배치, `Invocation5XXErrors`·`InvocationModelErrors` |
| **확장성** | 부하 변화에 맞춰 용량이 늘고 줄어드는가 | 엔드포인트 오토 스케일링과 이를 뒷받침하는 모니터링 |
| **내결함성** | 장애가 나도 서비스와 복구가 유지되는가 | 다중 AZ 분산, 헬스 체크(`/ping`) 실패 시 인스턴스 자동 교체 |

ML Lens가 직접 명시하는 것은 **추론 엔드포인트의 핵심 KPI로 "지연·처리량·자원 활용률"**, 그리고 설계 원칙 "Enable resiliency"의 **내결함성·복구 가능성 검증**입니다. 필러 정의도 둘 있습니다 — 성능 효율성은 "컴퓨팅 자원의 효율적 사용", 신뢰성은 "워크로드가 의도한 기능을 올바르고 일관되게 수행하는 능력".

> 🧠 원리: 활용률·처리량은 **"자원을 효율적으로 쓰는가"**(성능 효율성·비용) 질문이고, 가용성·확장성·내결함성은 **"필요할 때 계속 동작하는가"**(신뢰성) 질문입니다. 그래서 문항이 어느 쪽을 묻는지 보면 고를 지표가 좁혀집니다.

**문서 근거가 있는 가용성 권고** — 운영 엔드포인트마다 인스턴스를 **여러 개** 배포하고, VPC를 쓰면 **서로 다른 AZ의 서브넷을 2개 이상** 지정합니다. 추론 컴포넌트로 **99.95% 가용성**을 목표로 하면 복사본을 2개 초과로 두고 관리형 오토 스케일링의 **최소 인스턴스를 2**로 설정합니다. SageMaker AI는 AZ 장애나 인스턴스 장애 시 인스턴스를 **AZ 전반에 다시 분산**하려 시도합니다.

**ML Lens MLOPS05-BP01의 실행 순서**(시험 관점 요약) — CloudWatch로 성능 지표 수집(CPU·Memory·Disk 활용률, `ModelLatency`, `InvocationsPerInstance`) → 사고 시 대시보드·로그·트레이스로 원인 분석 → KPI 정의 → 경보 기반 SNS 알림 → **이상 탐지로 KPI 예상 범위를 만들어 이탈 시 배포 중단·롤백** → EventBridge로 자동 워크플로 → X-Ray로 분산 추적.

### 2) CloudWatch 네임스페이스와 지표 읽기 {#sagemaker-namespaces}

| 네임스페이스 | 대상 | 대표 지표 |
|---|---|---|
| **`AWS/SageMaker`** | 엔드포인트 **호출** | `Invocations`·`InvocationsPerInstance`·`Invocation4XXErrors`·`Invocation5XXErrors`·`InvocationModelErrors`·`ModelLatency`·`OverheadLatency`·`ModelSetupTime`(서버리스). 멀티 모델: `ModelLoadingWaitTime`·`ModelDownloadingTime`·`ModelLoadingTime`·`ModelCacheHit` |
| **`/aws/sagemaker/Endpoints`** | 엔드포인트 **인스턴스** | `CPUUtilization`·`MemoryUtilization`·`DiskUtilization`·`GPUUtilization`·`GPUMemoryUtilization`, 멀티 모델 `LoadedModelCount` |
| `/aws/sagemaker/InferenceComponents` | 추론 컴포넌트 | `*UtilizationNormalized` 계열 |
| `/aws/sagemaker/TrainingJobs`·`ProcessingJobs`·`TransformJobs` | 훈련·처리·배치 변환 잡 | CPU·Memory·GPU·GPUMemory·Disk 활용률(**`DiskUtilization`은 배치 변환 미지원**) |
| `/aws/sagemaker/InferenceRecommendationsJobs` | Inference Recommender 잡 | `ClientInvocations`·`ClientInvocationErrors`·**`ClientLatency`(밀리초)**·`NumberOfUsers` |
| `AWS/Sagemaker/ModelBuildingPipeline` | 파이프라인 실행·단계 | `ExecutionStarted`/`Failed`/`Succeeded`/`Stopped`/`Duration`, `Step*` |

**게시 주기·보존**

- 기본 **1분**. `MetricsConfig`의 `MetricPublishFrequencyInSeconds`로 **10·30·60·120·180·240·300초** 중에서 바꿉니다
- ⚠️ 호출 지표(`AWS/SageMaker`)에서 이 설정을 쓰려면 **`EnableEnhancedMetrics=True`** 가 필요하고, **인스턴스 지표는 필요 없습니다**
- `EnableEnhancedMetrics=True`이면 **`InstanceId`**(GPU는 `AcceleratorId`) 차원이 추가돼 인스턴스별로 드릴다운할 수 있습니다
- 지표는 **15개월 보관**되지만 콘솔 검색은 **최근 2주** 안에 갱신된 지표만 보여 줍니다

**값 읽기 — 100%가 상한이 아닙니다**

- `CPUUtilization`은 **코어별 0~100을 합산**하므로 4코어면 **0~400%**, `GPUUtilization`도 GPU 수만큼 곱해집니다. `MemoryUtilization`은 0~100%입니다
- 다중 인스턴스 잡은 인스턴스마다 지표를 보고하지만 **CloudWatch 기본 보기는 전체 인스턴스 평균**입니다

**로그.** 컨테이너·노트북 수명 주기 구성의 `stdout`/`stderr` 출력은 CloudWatch Logs로 갑니다 — 엔드포인트 `/aws/sagemaker/Endpoints/[EndpointName]`(스트림 `[production-variant-name]/[instance-id]`), 훈련·처리·변환·Inference Recommender 그룹. 기본 보존은 **무기한**입니다. ⚠️ **로그 스트림이 없거나 비어 있으면 실행 역할 권한**을 확인합니다 — `logs:CreateLogGroup`·`logs:CreateLogStream`·`logs:PutLogEvents`·`cloudwatch:PutMetricData`.

⚠️ 더 촘촘한 훈련 프로파일링에 지표 문서는 SageMaker Debugger를 권하지만 **Debugger는 신규 고객에게 닫혀 있고**, **SageMaker Profiler는 2027-06-30에 지원이 종료**됩니다. Profiler 문서는 시스템 자원 모니터링을 **CloudWatch로 대체**하라고 안내합니다.

> 🧠 원리: 호출 지표는 **"요청"을 세고**, 인스턴스 지표는 **"자원"을 잽니다.** 호출이 느린 이유가 모델인지 자원 포화인지 가르려면 두 네임스페이스를 같은 시간축에 겹쳐 봐야 합니다. 지표가 안 보이면 네임스페이스와 차원(`EndpointName`·`VariantName`)부터 확인합니다.

### 3) 지연 분해 — 모델·오버헤드·네트워크 {#latency-breakdown}

클라이언트가 체감하는 전체 시간은 **네트워크 지연 + 오버헤드 지연 + 모델 지연**으로 나뉩니다.

| 구성 | 지표 | 무엇을 재는가 | 줄이는 법(문서 권고) |
|---|---|---|---|
| **모델 지연** | `ModelLatency`(µs) | 모델 컨테이너와의 통신 시간 + **컨테이너 안에서 추론을 끝내는 시간** | 엔드포인트 밖에서 모델 벤치마크, SageMaker Neo 컴파일, Inferentia 컴파일, 모델이 지원하면 GPU, 과부하면 오토 스케일링 |
| **오버헤드 지연** | `OverheadLatency`(µs) | 요청 수신~응답 반환에서 **`ModelLatency`를 뺀** 값. **요청·응답 페이로드 크기, 요청 빈도, 인증/인가**에 따라 변함 | 페이로드 줄이기, 첫 호출 콜드 스타트는 **테스트 요청으로 사전 워밍**. 서버리스는 콜드 스타트가 여기에 포함 |
| **네트워크 지연** | **해당 SageMaker 지표 없음** | 클라이언트↔엔드포인트 왕복. **AWS 인프라 밖**에서 발생 | 클라이언트를 엔드포인트 리전 가까이에, CDN·엣지 활용, 클라이언트 네트워크 최적화 |

- **엔드 투 엔드 지연은 두 지표의 단순 합이 아닙니다** — 인터넷 구간이 더해집니다. 로드 테스트 때는 엔드포인트 지표에 집중하라는 권고가 있습니다
- **꼬리 지연은 평균이 아니라 백분위수로** 봅니다 — `ModelLatency`의 유효 통계에 Percentiles가 포함됩니다
- 오류 지표 — `Invocation4XXErrors`/`Invocation5XXErrors`는 모델이 4xx/5xx를 반환한 호출(응답마다 1 또는 0), **`InvocationModelErrors`는 2XX가 아닌 모든 모델 호출**이라 소켓 오류·비정상 HTTP 응답·요청 타임아웃까지 포함합니다
- ⚠️ **단위 함정**: CloudWatch `ModelLatency`·`OverheadLatency`는 **마이크로초**, Inference Recommender 결과 표의 `ModelLatency`와 `ClientLatency`는 **밀리초**입니다

⚠️ 서버리스에서는 **콜드 스타트 시간이 `OverheadLatency`에 포함**되고, `ModelSetupTime`이 **새 컴퓨트 기동 시간**을 따로 잽니다. 두 지표가 다른 것을 가리키는 것처럼 읽히므로 **한쪽만 정답으로 두지 않습니다.**

> 🧠 원리: 문서가 첫 단계로 권하는 것은 **"지연이 모델·오버헤드·네트워크 중 어디에서 나는지부터 가르는 것"** 입니다. 어디서 나는지에 따라 조치가 완전히 갈리므로(모델/확장 vs 페이로드/워밍 vs 클라이언트 위치) 진단표(13))도 이 순서를 따릅니다.

### 4) 관찰성 도구 3종 — X-Ray·Lambda Insights·Logs Insights {#observability-tools}

| 도구 | 보는 **단위** | 언제 쓰나 | 핵심 사실·주의 |
|---|---|---|---|
| **AWS X-Ray** | **요청 하나**가 거치는 구성요소와 다운스트림 호출(세그먼트·서브세그먼트), 트레이스 맵 | API Gateway → Lambda → (엔드포인트)처럼 여러 구성요소를 거치는 요청에서 **어느 구간이 느린지** | ML Lens는 "ML 애플리케이션 구성요소 간 요청 추적"에 X-Ray를 권한다. ⚠️ 통합 서비스 목록은 '예시'이며 **SageMaker는 기재돼 있지 않다.** ⚠️ X-Ray SDK/Daemon은 **2026-02-25부터 유지보수 모드**이며 OpenTelemetry 이전 권장(서비스 자체는 계속) |
| **CloudWatch Lambda Insights** | **Lambda 실행 환경**의 시스템 지표(CPU 시간·메모리·디스크·네트워크)와 **콜드 스타트**·워커 종료 진단 | 추론 전·후처리 Lambda의 콜드 스타트·메모리 문제를 가릴 때 | Lambda 확장(레이어)을 설치하면 호출마다 성능 로그 이벤트가 나가고 **임베디드 메트릭 형식**으로 지표가 추출된다. 지표·로그와 확장 실행 시간에 과금 |
| **CloudWatch Logs Insights** | **로그 텍스트**의 집계·검색 | 엔드포인트 로그에서 오류 패턴·느린 요청을 찾을 때, 사고 원인 후보 확인과 수정 검증 | 쿼리 언어 3종(Logs Insights QL·OpenSearch PPL·OpenSearch SQL), 계정당 **동시 쿼리 100개**, **60분 타임아웃**, **결과 7일**, **스캔한 데이터량 기준 과금** |

예시 쿼리 — 엔드포인트 로그에서 최근 오류 20건. 명령은 파이프로 연결하고 `fields`·`filter`·`stats`·`sort`·`limit` 등을 씁니다.

```
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 20
```

⚠️ **"엔드포인트가 X-Ray 세그먼트를 자동으로 보낸다"는 단정은 근거가 없습니다.** X-Ray는 **앞단 애플리케이션 체인**(API Gateway·Lambda 등)의 구간별 지연 추적으로 이해합니다. `InvokeEndpoint`의 `CustomAttributes`로 trace ID를 실어 보내는 예시는 있으나 **모델 코드가 응답에 되돌려야** 합니다.

> 🧠 원리: 세 도구는 **보는 단위가 다릅니다.** CloudWatch 지표(2))가 "무엇이 느려졌나"를 알려 주면, X-Ray가 "요청이 어느 서비스에서 멈췄나", Lambda Insights가 "그 Lambda의 자원·콜드 스타트", Logs Insights가 "로그에 뭐라고 찍혔나"를 좁힙니다.

### 5) 경보 3종과 대시보드 {#alarms-dashboards}

| 경보 | 판정 방식 | 용도 | 제약·주의 |
|---|---|---|---|
| **지표 경보**(정적 임계값) | 단일 지표 또는 지표 수학식 결과를 임계값과 **여러 주기에 걸쳐** 비교 | `CPUUtilization` 지속 80% 초과 / 20% 미만 같은 규칙 | 동작: SNS 알림, EC2 작업, Auto Scaling 작업, 조사 시작, OpsItem·인시던트 생성 |
| **이상 탐지 경보** | **정적 임계값 없이** 통계·ML 모델이 만든 **예상 값 밴드**와 비교(밴드 위·아래·양쪽 선택) | **시간대·요일 패턴(계절성)**과 추세가 있는 호출량·지연 | AWS 제공 지표와 사용자 지정 지표 모두 가능. ML Lens는 이상 탐지로 KPI 예상값을 만들어 이탈 시 배포를 중단·롤백하라고 안내 |
| **복합 경보** | **다른 경보들의 상태**를 규칙 식으로 조합 | **경보 소음 감소** — 여러 지표 경보가 함께 ALARM일 때만 알림 | ⚠️ SNS 알림·조사·OpsItem은 가능하지만 **EC2 작업·Auto Scaling 작업은 불가** |

- 경보 상태는 **OK · ALARM · INSUFFICIENT_DATA** 이며, 지표를 보내지 않는 리소스는 INSUFFICIENT_DATA가 될 수 있습니다. 누락 데이터 처리 방식을 경보별로 지정합니다
- **경보 이력은 30일 보존**됩니다. 경보는 **상태가 바뀔 때만** 작업을 호출합니다(Auto Scaling 작업은 해당 상태가 유지되는 동안 분당 1회)
- SageMaker 엔드포인트 배포의 **자동 롤백도 CloudWatch 경보를 모니터링**합니다 — 배포 상태 `Baking`이 그 대기 기간입니다
- 서비스 쿼터 사용률을 경보로 감시하려면 SageMaker AI의 사용량 지표와 **`SERVICE_QUOTA()` 수학 함수**를 씁니다(12) 참조)

**대시보드 둘의 구분**

| 구분 | CloudWatch 대시보드 | Amazon Quick Sight |
|---|---|---|
| 정체 | 콘솔의 사용자 지정 홈 화면. **여러 리전에 흩어진 리소스의 지표·경보를 한 화면**에서 본다 | Amazon Quick 안의 BI 기능. **데이터 소스에 연결해** 대시보드를 만들고 애플리케이션에 임베드한다 |
| 만드는 법 | 콘솔·CLI·`PutDashboard` API. Logs Insights 쿼리와 경보도 올릴 수 있다 | 데이터셋 기반(예: CUR을 Athena로 쿼리) |
| 성격 | 운영 지표·경보의 **실시간 상태판** | **데이터셋 기반 BI·분석 대시보드** |

⚠️ **"Quick Sight에 CloudWatch 지표를 직접 연결한다"는 단정은 근거가 없습니다.** 확인된 예는 CUR → Athena → Quick 데이터셋처럼 **S3/Athena를 경유**하는 구성입니다.

⚠️ **명칭 정리** — AWS BI 블로그 공지의 제목은 "Amazon QuickSight evolves to Amazon Quick Suite"이고, 현재 사용자 가이드는 **Amazon Quick**이 QuickSight에서 발전한 것이며 **QuickSight는 Quick 안의 BI 기능 "Amazon Quick Sight"로 계속**된다고 씁니다(기존 API·SDK·통합은 변경 없이 동작). 그래서 가이드의 세 표기는 **같은 대상의 시기·위치 차이**입니다 — 영문 PDF 'Amazon QuickSight'(구명칭), 한국어 Skill 'Amazon Quick Sight'(Quick 안의 BI 기능명), 범위 내 서비스 목록 'Amazon Quick'(제품명).

### 6) CloudTrail — 관리 vs 데이터 이벤트, 추적 만들기 {#cloudtrail-events}

CloudTrail은 SageMaker AI에 대한 **모든 API 호출을 이벤트로 캡처**합니다(콘솔 호출·코드 호출 모두).

| 구분 | 관리 이벤트 | 데이터 이벤트 |
|---|---|---|
| 의미 | 리소스 **관리** 작업(제어 평면) | 리소스 **안·위**에서 일어나는 작업(데이터 평면), 고빈도 |
| 기본값 | **기본적으로 기록** | ⚠️ **기본적으로 기록하지 않음, 추가 요금** |
| 이벤트 기록(90일) | 기록됨 | ⚠️ **기록되지 않음** → 추적(trail)에서 별도 선택 |
| SageMaker 예 | 모든 제어 평면 작업(`CreateEndpoint`·`CreateModel`·`CreateTrainingJob` 등) | `AWS::SageMaker::Endpoint` → `InvokeEndpoint`·`InvokeEndpointAsync`·`InvokeEndpointWithResponseStream` · `AWS::SageMaker::Job` → `CompleteRollout`·`Sample`·`SampleWithResponseStream` |
| 요청 파라미터 | 기록됨(`requestParameters`) | ⚠️ `InvokeEndpoint`·`InvokeEndpointAsync`·`Sample`·`SampleWithResponseStream`은 **요청 파라미터를 기록하지 않음** |

**`InvokeEndpoint` 기록 여부** — 현재 문서 기준으로 **데이터 이벤트로 기록할 수 있습니다(옵트인).** 기본값은 미기록이고 이벤트 기록에도 남지 않습니다. **고급 이벤트 선택기**(`eventCategory`=`Data`, `resources.type`, `resources.ARN`)로 필요한 엔드포인트만 골라 기록하고, 기존 추적에는 `aws cloudtrail put-event-selectors`로 붙입니다.

자동 모델 튜닝이 만드는 훈련 잡처럼 **고객 API 호출이 아닌 서비스 이벤트**는 `eventType`이 `AwsApiCall`이 아니라 **`AwsServiceEvent`** 입니다.

**이벤트 기록(Event history)** — 계정을 만들면 **자동으로 켜져 있고**, 리전별 최근 **90일의 관리 이벤트**를 조회·검색·다운로드할 수 있는 **변경 불가** 기록입니다. 90일을 넘겨 보관하려면 추적을 만듭니다.

**추적 만들기 — 콘솔 절차**

1. CloudTrail 콘솔 → Trails → **Create trail**, 추적 이름 입력
2. (조직 추적이면) **관리 계정 또는 위임된 관리자 계정**에서만 만들 수 있습니다
3. **저장 위치** — 새 S3 버킷 생성(CloudTrail이 필요한 **버킷 정책을 만들어 적용**, 서버 측 암호화 기본 활성) 또는 기존 버킷(CloudTrail 쓰기 권한이 있는 버킷 정책 필요)
4. 로그 파일 **SSE-KMS 암호화**(콘솔 기본값 Enabled, 끄면 SSE-S3), Additional settings의 **로그 파일 검증**(다이제스트 파일)·SNS 알림, 선택 사항인 **CloudWatch Logs 전송**(새·기존 로그 그룹 + IAM 역할, 로그 그룹은 현재 계정에 있어야 함)
5. **Choose log events** — 관리 이벤트(Read/Write 선택)와 데이터 이벤트를 고릅니다. 데이터 이벤트는 추가 요금이 붙고, 고급 이벤트 선택기에서 **리소스 유형**(엔드포인트는 `AWS::SageMaker::Endpoint`)과 로그 선택기 템플릿(전체·읽기 전용·쓰기 전용)을 정하거나 Custom 조건을 만듭니다

- ⚠️ **콘솔로 만든 추적은 모두 다중 리전 추적**이고, 단일 리전 추적은 **AWS CLI로만** 만듭니다. 다중 리전이 권장입니다
- 진행 중인 **관리 이벤트 사본 1부는 CloudTrail 요금 없이** 전송됩니다(S3 저장 요금은 별도)
- 추적의 이점 셋 — 90일을 넘는 보관, CloudWatch Logs 전송을 통한 **자동 모니터링·경보**, **Athena로 로그 쿼리**
- 추적 설정이 잘못되면(예: S3 버킷 접근 불가) CloudTrail이 **30일 동안 재전송을 시도하며 그 요금이 부과**됩니다

⚠️ **CloudTrail Lake** — 이벤트를 SQL로 질의하는 이벤트 데이터 스토어 기능입니다. **2026-05-31부터 신규 고객에게 닫혔고** 기존 고객은 계속 사용합니다. 추적·Insights·집계 이벤트는 영향이 없으며 CloudWatch로의 이전이 권장됩니다. 가이드의 기술 항목은 **'CloudTrail 추적 만들기'** 이므로 Lake는 개념 구분 정도로만 다룹니다.

> 🧠 원리: CloudTrail은 **"누가·언제·어떤 API를 어떤 파라미터로 호출했는가"** 를 남기는 **감사 기록**입니다. 성능 지표를 보여 주는 CloudWatch와 목적이 다릅니다. 데이터 이벤트는 양이 많아 기본 제외이고(이벤트 기록에도 안 남음) 필요한 리소스만 골라 추적으로 켭니다.

### 7) EventBridge로 인프라 모니터링과 재훈련 호출 {#eventbridge-retraining}

**(a) SageMaker AI → EventBridge 상태 변경 이벤트**

SageMaker AI는 상태 변경 이벤트를 **거의 실시간으로** EventBridge에 보냅니다. 한 상태 변경에 **이벤트가 여러 번 올 수 있으며 오류가 아닙니다.**

| `detail-type`(`source`=`aws.sagemaker`) | 활용 예 |
|---|---|
| SageMaker Training Job State Change | 훈련 완료·실패(`FailureReason`) 알림, 후속 단계 자동 시작 |
| Processing Job / Transform Job / HyperParameter Tuning Job State Change | 전처리·배치 변환·튜닝 잡 상태 감시 |
| SageMaker Endpoint State Change | 엔드포인트 InService·Failed 등 |
| SageMaker Endpoint Deployment State Change | 블루/그린·카나리 배포 중 `Baking`·`Updating` 등 세부 상태 |
| SageMaker Model Package State Change | 모델 승인 상태 변경 등 레지스트리 이벤트 |
| Model Building Pipeline Execution / Step Status Change | 파이프라인 실행·단계 상태 |
| Feature Group · Image · Model Card · Model · Job · HyperPod 계열 | 그 밖의 리소스 상태 |

호출 가능한 동작 예 — Lambda 호출, EC2 Run Command, Kinesis Data Streams 중계, Step Functions 상태 머신 활성화, SNS 알림.

**(b) CloudWatch 경보 → EventBridge.** CloudWatch는 `CloudWatch Alarm State Change`·`CloudWatch Alarm Configuration Change`·`CloudWatch Alarm Contributor State Change`를 EventBridge로 보냅니다(`source`=`aws.cloudwatch`). 지표 임계 이탈(예: 엔드포인트 CPU 포화)을 규칙으로 받아 Lambda·SSM Automation·SNS로 연결합니다.

**(c) CloudTrail로 재훈련 활동 기록·모니터링·호출**

| 단계 | 방법 |
|---|---|
| **기록** | `CreateTrainingJob`·`StartPipelineExecution` 등 제어 평면 호출은 **관리 이벤트로 기본 기록.** 90일 초과 보관·분석은 추적 + S3 |
| **모니터링** | 추적을 **CloudWatch Logs로 보내 경보**를 걸거나, EventBridge 규칙으로 특정 API 이벤트를 감시 |
| **호출(트리거)** | 새 훈련 데이터 감지에는 **CloudTrail과 EventBridge를 결합해 Step Functions 워크플로를 자동 시작** |
| **대상** | SageMaker Pipelines는 **EventBridge 대상**이며 `StartPipelineExecution`을 호출한다. 이벤트 예: S3 새 파일 업로드, 드리프트로 인한 엔드포인트 상태 변경, SNS 토픽 |

**새 데이터 파일 업로드 감지 경로** — S3 객체 쓰기는 **데이터 이벤트**이므로 ① 해당 버킷의 데이터 이벤트를 기록하는 **추적이 있어야** 하고 ② EventBridge 규칙이 **`AWS API Call via CloudTrail`** 이벤트를 매칭하며 ③ 대상으로 SageMaker Pipeline 또는 Step Functions를 둡니다. 대안으로 **S3 버킷의 EventBridge 알림**을 켜서 `ObjectCreated` 이벤트를 직접 받는 구성도 쓰입니다.

⚠️ **EventBridge가 CloudTrail 이벤트를 받으려면 로깅 중인 추적이 반드시 있어야 합니다.** 규칙의 기본 상태 `ENABLED`는 **쓰기(변경) 관리 이벤트와 데이터 이벤트**를 매칭하고(데이터 이벤트는 추적이 해당 유형을 캡처하도록 설정돼 있어야 함), **읽기 전용 관리 이벤트**는 규칙 상태가 **`ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`** 일 때만 매칭됩니다.

ML Lens MLPERF06-BP05는 재훈련 트리거를 **일정 · 성능 임계 이탈 · 데이터 드리프트 · 새 훈련 데이터 도착**으로 정의하고, 성능 지표 기반 CloudWatch 알림이 재훈련 워크플로를 알리거나 자동 실행하도록 구성하라고 합니다.

> 🧠 원리: CloudTrail은 **감사 기록**, EventBridge는 **이벤트 라우터**입니다. 둘을 잇는 이벤트가 `AWS API Call via CloudTrail`이고, "S3에 파일이 올라왔다"는 사실은 **S3 데이터 이벤트로 CloudTrail에 남아야** 이 경로로 흐릅니다. 반대로 **SageMaker가 직접 보내는 상태 변경 이벤트는 추적 없이도** EventBridge로 옵니다.

### 8) 인스턴스 범주와 적정 규모 도구 {#rightsizing-tools}

**인스턴스 범주**

| 범주 | 문서 정의 | 계열 예 | ML에서의 의미 |
|---|---|---|---|
| 범용(General purpose) | 컴퓨팅·메모리·네트워킹 자원의 **균형** | M, T | 균형 잡힌 요구의 모델·노트북 |
| 컴퓨팅 최적화(Compute optimized) | 고성능 프로세서가 유리한 컴퓨팅 집약 애플리케이션용. **용도 예에 머신 러닝 추론이 있음** | C | CPU 기반 추론·배치 처리 |
| 메모리 최적화(Memory optimized) | **대용량 데이터셋을 메모리에서** 처리하는 워크로드 | R, X, U, z1d | 메모리 병목(큰 모델·큰 데이터프레임) |
| 가속 컴퓨팅(Accelerated computing) | **하드웨어 가속기·보조 프로세서**로 부동소수점 연산·그래픽 처리 등을 효율화 | G, P, DL, Inf, Trn | GPU 추론·훈련 |
| 추론 최적화(AWS Inferentia: Inf1·Inf2) | 딥러닝 추론용으로 **고성능·저지연** 제공 | Inf1·Inf2(가속 컴퓨팅 목록에 포함) | 모델을 Inferentia용으로 컴파일하면 **추론당 비용을 낮추며 처리량을 높일 수 있음**(모델이 지원할 때) |

- SageMaker 추론에는 Inferentia·Graviton 칩을 포함해 **70종이 넘는** 인스턴스 유형·크기가 있습니다. SageMaker 훈련 인스턴스 유형은 **`ml.` 접두를 뗀 EC2 인스턴스 유형**에 대응합니다
- **선택 순서(ML Lens)** — 알고리즘이 **컴퓨트·메모리·I/O 중 어디에 묶이는지 먼저 분석**하고, 새 모델은 **작은 인스턴스로 시작해 데이터로 확인될 때만** 키웁니다. 딥러닝은 GPU 이득 여부를, 전통 ML은 CPU로 충분한지를 따집니다

**도구 비교 — 입력이 다릅니다**

| 항목 | SageMaker AI Inference Recommender | AWS Compute Optimizer |
|---|---|---|
| 방식 | **로드 테스트·모델 튜닝을 자동화**해 인스턴스 유형·구성을 추천 | **리소스 구성과 CloudWatch 사용 지표**를 분석해 rightsizing·유휴 권장(**옵트인 필요**, 기본 최근 **14일** 분석) |
| 입력 | SageMaker 모델 또는 Model Registry 등록 모델 **+ 샘플 페이로드** | **이미 실행 중인 리소스의 지표** |
| 출력 | 인스턴스 유형·개수·컨테이너 파라미터·모델 최적화와 비용·처리량·지연 지표 | EC2 등: 사이징 권장 / **SageMaker 엔드포인트: 유휴(idle) 권장** |
| SageMaker 적용 | 실시간·서버리스 엔드포인트 대상 | 문서 기준 SageMaker 지원은 **유휴 권장(14일간 호출 0건)** |
| 비용 | **잡이 실행되는 동안 사용한 인스턴스에 대해서만** 과금 | (이 문서에서 요금 미조사) |

⚠️ **"Compute Optimizer로 SageMaker 엔드포인트를 사이징한다"는 단정을 피합니다.** 사용자 가이드가 SageMaker에 대해 명시하는 것은 **유휴 권장**뿐이고, FAQ의 권장 대상 나열에는 'SageMaker Endpoint'가 들어 있으나 **권장 유형을 구분하지 않습니다.** 사이징의 정답은 **Inference Recommender**, Compute Optimizer는 **유휴·EC2 등**으로 한정합니다.

**추천 잡 2종**

| 잡 | 입력 | 소요 | 특징 |
|---|---|---|---|
| **Default** | 모델 패키지 ARN만 | **45분 안에** 끝남 | 추천 인스턴스에서 일련의 부하 테스트를 실행 |
| **Advanced** | 사용자가 인스턴스·트래픽 패턴·지연/처리량 요건을 정함 | 평균 **2시간** | 맞춤 부하 테스트. 결과의 **초기 인스턴스 수**를 오토 스케일링 정책 구성에 쓴다 |

⚠️ **기존 엔드포인트 벤치마크 제약** — 잡당 **엔드포인트 1개·변형 1개**, **오토스케일링을 쓰는 엔드포인트 불가**, 실시간 전용(멀티 모델 불가). **라이브 트래픽을 받는 운영 엔드포인트에는 돌리지 않습니다.**

**결과 지표** — `ModelLatency`(밀리초)·`MaximumInvocations`·`CostPerHour`·`CostPerInference`·`CpuUtilization`·`MemoryUtilization`. **지연에 민감하면 지연, 처리량이 목적이면 `CostPerInference`** 에 초점을 둡니다.

**적정 규모 신호** — ML Lens 예시는 CPU 활용률이 지속적으로 **80%를 넘으면 과소 프로비저닝**, **20% 미만이면 과다 프로비저닝** 신호로 경보를 두라고 합니다. 새 모델·사용 패턴 변화 때 Inference Recommender를 **다시 돌립니다.**

> 🧠 원리: Inference Recommender는 **배포 전(또는 비운영 엔드포인트)에 모의 부하로** 후보 구성을 비교하고, Compute Optimizer는 **이미 쌓인 사용 지표로** 자원을 평가합니다. 입력이 "모델 + 샘플"인가 "지표 이력"인가로 갈리므로, **"배포 전 후보 비교"는 전자의 일**입니다.

> ℹ️ 추론 옵션 4종의 선택 기준 자체는 `mla-t3-1` 1) 추론 옵션이, 컴퓨팅 인스턴스 선택은 `mla-t3-1` 9) 컴퓨팅 선택이 정본입니다.

### 9) 비용 분석·통제 도구 {#cost-tools}

| 도구 | 무엇을 하나 | 핵심 사실 | 주의 |
|---|---|---|---|
| **AWS Billing and Cost Management** | 청구·결제 설정 + 비용 분석·구성·계획·최적화 기능 묶음 | 하위 기능: Bills, Cost Explorer, Data exports, Cost Anomaly Detection, Cost categories, Cost allocation tags, Budgets, Cost Optimization Hub, Savings Plans, Reservations | **개별 도구를 담는 우산** 개념 |
| **AWS Cost Explorer** | 비용·사용량을 **시각화·필터·그룹·예측** | 최근 **13개월 조회**, 향후 **18개월 예측**(현재 문서). UI는 무료·API 요청당 $0.01, **최소 24시간마다 갱신**. CUR과 같은 데이터셋 | ⚠️ **알림 도구가 아니다** |
| **AWS Budgets** | 비용·사용량 예산을 만들고 **임계값 도달 시 알림·작업** | 예산 유형 **6종** — 비용·사용량·RI 사용률·RI 적용 범위·Savings Plans 사용률·Savings Plans 적용 범위. 알림 대상은 SNS 토픽·이메일. 예: 임계값 도달 시 **추가 프로비저닝을 막는 IAM 정책 자동 적용** | 정보 갱신은 **하루 최대 3회**, 비용 발생과 알림 사이에 지연 가능 |
| **AWS Trusted Advisor** | AWS 환경을 **점검해 권고** | 비용 최적화 점검에 **SageMaker AI Savings Plans 구매 권장**이 포함되고, 이 점검은 **Cost Optimization Hub 옵트인** 필요 | ⚠️ 전체 점검은 **유료 지원 플랜** |
| **CUR / Data Exports** | **가장 상세한** 비용·사용량 원천 데이터를 S3로 전달 | CSV, 시간·일·월·리소스·태그 단위. **Athena·Redshift·Quick 연동.** CUR 2.0은 Data Exports로 전달되며 권장 | 태그 기반 분석은 **태그 활성화가 선행**(10) 참조) |
| **AWS Cost Anomaly Detection** | 비정상 지출 패턴 **자동 감지·알림** | 훈련 시간 증가 등으로 인한 ML 비용 급증 감시 | 가이드 예시에는 없음(참고) |

⚠️ **Trusted Advisor의 지원 플랜 명칭은 외우지 않습니다.** 2026-10-17 문서 기준으로 전체 점검은 Business Support+ · Enterprise Support · Unified Operations 플랜이고 Basic은 Service Limits 범주 중심입니다. 다만 Developer Support·Business Support·Enterprise On-Ramp는 **2027-01-01 종료 공지**가 있어 플랜 명칭이 시험 가이드 시점과 다를 수 있습니다. **"유료 지원 플랜에서 전체 점검, Basic은 Service Limits 중심"** 수준으로 기억합니다.

가이드 기술 항목의 "**비용 할당량 설정**"은 영문 'setting cost quotas'로, 도구 예에 Budgets가 들어 있으므로 **예산으로 한도 임계값을 정하고 알림·작업을 거는 것**으로 읽습니다.

**ML Lens가 권하는 흐름** — AWS Budgets로 SageMaker AI 비용(개발·훈련·호스팅)을 **실제·예측 임계값**으로 감시 → 일관된 태깅 전략 → 태그를 **비용 할당 태그로 활성화** → Cost Explorer로 분석 → Cost Anomaly Detection → 거버넌스 프로세스.

> 🧠 원리: 넷은 **같은 데이터(CUR 데이터셋)를 서로 다른 방식으로** 씁니다. Cost Explorer는 "이미 발생한 비용을 분석·예측"하는 **조회** 도구, Budgets는 "임계값을 정해 알림·작업"을 거는 **통제** 도구, Trusted Advisor는 "점검 기반 **권고**", CUR은 **원천 데이터**입니다.

### 10) 태깅 전략과 비용 할당 태그 — 활성화가 핵심 {#cost-allocation-tags}

**① 태그와 비용 할당 태그.** 태그는 **키·값 쌍 레이블**이고, 비용 할당 태그는 이를 이용해 **AWS 비용을 세부 수준으로 추적**합니다. 유형은 둘입니다.

| 유형 | 누가 정의·적용 | 접두 | 예 |
|---|---|---|---|
| **AWS 생성 태그** | AWS가 정의·적용 | `aws:` | `createdBy` |
| **사용자 정의 태그** | 사용자가 정의·적용 | `user:` | 프로젝트·팀 이름 |

**② 활성화가 필수.** ⚠️ **두 유형 모두 각각 활성화해야** Cost Explorer와 비용 할당 보고서에 나타납니다. 활성화는 Billing and Cost Management 콘솔의 Cost allocation tags에서 **태그 키 단위**로 하고, 키를 활성화·비활성화하면 **같은 키의 모든 값에 적용**됩니다. `UpdateCostAllocationTagsStatus` API로 일괄 활성화할 수 있습니다. 조직에서는 **관리 계정(또는 단독 계정)만** 이 관리자 화면에 접근합니다.

**③ 지연.** 태그를 적용하면 활성화 대상에 뜨기까지 **최대 24시간**, 활성화되기까지 다시 **최대 24시간**입니다. SageMaker Studio 가이드는 활성화 후 Cost Explorer 필터에 뜨기까지 **24~48시간**으로 안내합니다.

**④ SageMaker 자동 태그.** Studio에서 만든 훈련 잡·처리 잡·커널 앱 등에 **`sagemaker:domain-arn`** 이 자동으로 붙고, 더 세밀하게 `sagemaker:user-profile-arn` 또는 `sagemaker:space-arn`이 붙습니다(2022-11-30 이후 Studio UI에서 만든 리소스부터). ⚠️ **이 자동 태그도 비용 분석에 쓰려면 먼저 활성화**해야 합니다.

**⑤ 태그 전파 — 인프라 준비**

- 도메인 **`TagPropagation`** 속성(`CreateDomain`/`UpdateDomain`)을 켜면 도메인·사용자 프로필·스페이스에 지정한 사용자 지정 태그가 Studio·JupyterLab·Code Editor·Canvas에서 만들어지는 리소스로 전파됩니다(**도메인 수준 설정만** 가능)
- ⚠️ SageMaker 리소스는 **태그 50개 한도**가 있고, 도메인 + 프로필 태그 합계가 한도를 넘으면 **리소스 생성이 실패**합니다. **자동 ARN 태그도 한도에 포함**됩니다
- ⚠️ 하이퍼파라미터 튜닝 잡의 태그는 **`AddTags` 호출 이후 시작되는** 훈련 잡에만 전파되므로, 처음부터 모두 적용하려면 `CreateHyperParameterTuningJob`의 `Tags`로 지정합니다. 도메인·사용자 프로필 태그도 **이후 시작하는 앱에만** 적용됩니다

**⑥ 전략과 거버넌스(ML Lens).** 프로젝트·환경·ML 단계(훈련·추론·실험)·소유자·비용 센터 같은 **일관된 스키마**를 정하고, CloudFormation·CDK·Terraform으로 태깅을 **자동화**하며, **AWS Config 규칙이나 Organizations 태그 정책으로 강제**합니다. 재훈련·호스팅 같은 ML 활동 범주로 비용을 묶습니다.

> 🧠 원리: 리소스 태그는 **"리소스에 붙은 라벨"일 뿐**이고, 결제 시스템이 그 라벨로 비용을 나눠 보여 주려면 **비용 할당 태그로 활성화하는 별도 단계**가 필요합니다. 그래서 **"태그를 달았는데 Cost Explorer에서 안 보인다"의 1순위 점검 항목은 활성화 여부와 반영 지연**입니다.

### 11) 구매 옵션 {#purchase-options}

| 옵션 | SageMaker AI에서의 형태 | 절감·약정 | 핵심 제약 |
|---|---|---|---|
| **온디맨드** | 기본 옵션. 훈련 잡은 시작 시 프로비저닝·종료 시 해제, **초 단위 과금** | 약정 없음 | 용량은 **best-effort.** 없으면 대기 상태(`MaxPendingTimeInSeconds` 30분~28일) 후 **`InsufficientCapacityError`** |
| **관리형 스팟 훈련** | 훈련 잡·자동 모델 튜닝에 **`EnableManagedSpotTraining=True`** | 온디맨드 대비 **최대 90%** | **중단 가능 → 체크포인트 권장.** ⚠️ **온디맨드로 폴백하지 않음**(스팟 용량이 없으면 `MaxWaitTimeInSeconds`까지 대기 후 중지). `MaxWaitTimeInSeconds` > `MaxRuntimeInSeconds`, 체크포인트 없는 내장·마켓플레이스 알고리즘은 **3600초 한도** |
| 예약 인스턴스(RI) | ⚠️ 문서가 예약 용량 예로 드는 서비스는 **EC2·RDS 등**. SageMaker 인스턴스에 RI를 적용한다는 서술은 찾지 못함 | — | SageMaker AI 비용 절감 수단으로 문서가 지목하는 것은 **SageMaker Savings Plans** |
| **SageMaker AI Savings Plans** | **시간당 사용량($/hour) 약정**, 1년 또는 3년 | 온디맨드 대비 **최대 64%** | 인스턴스 패밀리·크기·리전·구성요소와 **무관하게 자동 적용**(훈련 → 추론으로 옮겨도 유지). 약정 조건은 **구매 후 변경 불가.** 결제는 All/Partial/No upfront. ⚠️ **용량 보장은 아님** |
| **훈련 플랜** | 훈련 잡·HyperPod 클러스터·추론 엔드포인트·Studio 앱의 컴퓨팅 용량을 **인스턴스 유형·수량·AZ·기간·시작/종료 시각으로 예약** | (가격은 오퍼링별) | ⚠️ **대상 리소스별로 호환되지 않음**(교환 불가) |

⚠️ **"SageMaker는 RI를 쓸 수 없다"고 단정하지 않습니다.** 문서에 적용된다는 문장도, 적용되지 않는다는 문장도 없습니다. RI를 오답으로 가를 때의 근거는 **"문서가 SageMaker 비용 절감 수단으로 지목하는 것은 SageMaker AI Savings Plans"** 입니다.

- **Savings Plans 유형 4종** — Compute(**EC2·Fargate·Lambda**), Database, EC2 Instance, **SageMaker AI**. SageMaker 사용량에는 SageMaker AI Savings Plans가 맞습니다
- **적용 대상** — Studio Classic 노트북·On-Demand 노트북·Processing·Data Wrangler·Training·Real-Time Inference·Batch Transform의 ML 인스턴스 사용량. ⚠️ 목록이 'including'이라 **서버리스·비동기 적용 여부는 단정하지 않습니다**
- **순서** — ⚠️ **Savings Plans를 사기 전에 먼저 인스턴스를 right-size** 합니다. 약정 후보는 오래 실행될 구성요소를 골라 분석하고, Cost Explorer에서 권장 약정 수준을 봅니다

> 🧠 원리: **가격 약정과 용량 예약은 다른 상품**입니다. Savings Plans는 **할인일 뿐 용량을 예약해 주지 않습니다.** 특정 GPU 인스턴스를 확정된 시점에 확보해야 한다면 **훈련 플랜**처럼 용량을 예약하는 수단이 별도입니다.

### 12) 용량 문제 해결 — 쿼터·동시성·오토 스케일링 {#capacity-troubleshoot}

| 증상 | 원인 | 조치 |
|---|---|---|
| **`ResourceLimitExceeded`** — "account-level service limit … is 0 Instances" | 계정·리전·사용 유형별 **SageMaker 쿼터 초과** | Service Quotas 콘솔 → AWS services → Amazon SageMaker → 해당 쿼터 → **Request increase at account-level.** ⚠️ **즉시 반영되지 않으므로 미리 요청** |
| 오토 스케일링 중 "Failed to set desired instance count … service limit" | 스케일 아웃이 **인스턴스 유형 쿼터**에 도달 | 해당 쿼터 증설 요청 |
| 훈련 잡이 대기하다 `InsufficientCapacityError` | 온디맨드 용량 부재(best-effort) | `MaxPendingTimeInSeconds` 조정, **후보 인스턴스 유형 목록**, 여러 AZ 서브넷, 훈련 플랜 |
| 오토 스케일링이 아예 동작 안 함 | 선택한 **AZ에 인스턴스 유형 없음**, 용량 부족, 정책 오설정 | AZ별 가용성 확인, 다른 인스턴스 유형, 임계값 조정, `describe-scaling-activities --include-not-scaled-activities` |
| 서버리스 엔드포인트 지연·스로틀 | 엔드포인트의 **최대 동시성을 넘는 호출은 스로틀** | `MaxConcurrency` 조정, Provisioned Concurrency |
| 서버리스 유휴 후 첫 요청 지연 | **콜드 스타트**(모델 크기·다운로드·컨테이너 시작 시간에 좌우) | **Provisioned Concurrency**(≤ `MaxConcurrency`) — 할당한 만큼은 밀리초 내 응답 준비 |
| Lambda 콜드 스타트 | 사전 초기화된 실행 환경이 없음 | **프로비저닝된 동시성**(추가 요금) |

**서비스 쿼터 모니터링.** SageMaker AI는 사용량 지표를 **Service Quotas와 통합**하는 서비스이며, 사용량이 쿼터에 근접하면 알리는 CloudWatch 경보를 만들 수 있고 **`SERVICE_QUOTA(m1)` 수학 함수**로 사용률(%)을 계산합니다.

**SageMaker 서버리스의 숫자**

| 항목 | 값 |
|---|---|
| 기본 동작 | 요청이 없으면 **0으로 축소** |
| 메모리 | **1024~6144MB**(1GB 단위) |
| 엔드포인트당 최대 동시성 | **200** |
| 리전당 서버리스 엔드포인트 | **50개** |
| Provisioned Concurrency | **≤ `MaxConcurrency`.** Application Auto Scaling으로 목표 지표 또는 일정 기반 관리 가능 |
| 되돌리기 | ⚠️ **서버리스를 실시간으로 바꾸면 되돌릴 수 없다** |

**스케일링이 느리거나 안 줄어드는 이유**

- 경보가 **여러 데이터 포인트를 모은 뒤에야** 동작 → **Datapoints to alarm** 감소
- **CPU 활용률 기반 정책은 트래픽이 줄어도 스케일 다운하지 않을 수 있음**
- **워밍업 중인 인스턴스는 집계 지표에 포함되지 않음**
- 타깃 트래킹은 **Application Auto Scaling이 CloudWatch 경보를 직접 만들고 관리**합니다. `ScaleOutCooldown`·`ScaleInCooldown`이 **용량의 급격한 변동을 막는 장치**입니다
- 스케일링 지표는 실시간 엔드포인트가 **`InvocationsPerInstance`**, 비동기가 **`ApproximateBacklogSizePerInstance`** 입니다

⚠️ **오토 스케일링 반응 시간의 구체적 수치는 외우지 않습니다.** 스케일 아웃 3분·스케일 인 15분 같은 수치는 블로그에만 있고 공식 SageMaker 개발자 가이드에서 확인되지 않습니다. **"경보 평가 기간 + 지표 게시·반응 지연 + 쿨다운이 스케일 반응 시간을 이룬다"** 수준으로 이해합니다.

> ℹ️ 오토 스케일링 정책의 선언·구성 자체와 용량 모델은 `mla-t3-2` 1) 오토 스케일링 구조 · 3) 스케일링 지표 · 5) 용량 모델이 정본입니다. 여기서는 **문제가 생겼을 때의 진단·조치**만 다룹니다.

### 13) 지연·스케일링 진단표 {#scaling-diagnosis}

| 증상 | 먼저 볼 지표·도구 | 원인 | 조치 |
|---|---|---|---|
| `ModelLatency` 상승 | `ModelLatency`(p99), CPU·Memory·GPU 활용률, `InvocationsPerInstance` | 모델·추론 코드·프레임워크 설정, 엔드포인트 과사용 | 엔드포인트 밖 벤치마크, Neo·Inferentia 컴파일, GPU, 오토 스케일링, 활용률이 높으면 더 큰 인스턴스 |
| `OverheadLatency` 상승 | `OverheadLatency`, 호출 패턴 | 큰 페이로드, **드문 호출**, 인증·인가, 첫 호출 콜드 스타트 | 페이로드 축소, 사전 워밍, (서버리스) Provisioned Concurrency |
| **클라이언트만 느림**(두 지표 정상) | 클라이언트 측 측정, X-Ray(앞단 구간) | **네트워크 지연은 AWS 인프라 밖** | 리전 가까이 배치, CDN·엣지 |
| 5XX 증가 | `Invocation5XXErrors`·`InvocationModelErrors`, 엔드포인트 로그(Logs Insights), 인스턴스 자원 지표 | 컨테이너·모델 코드 오류, 자원 고갈, **메모리 부족**(503 'No worker is available'), 헬스 체크 실패 | 재시도(일시 오류), 로그 확인, 인스턴스 유형 상향·**워커 수(`model_server_workers`)** 조정, **실제 모델 로드 여부를 확인하는 `/ping` 구현** |
| 4XX 증가 | `Invocation4XXErrors`, 로그 | 모델이 4xx를 반환한 호출이 늘어남 | 엔드포인트 로그에서 **반환 이유를 확인**(Logs Insights) |
| 스케일 아웃이 느림 | `InvocationsPerInstance`·`CPUUtilization` 추이, `describe-scaling-activities`, 경보 상태 | 경보 데이터 포인트 집계, 쿨다운, 쿼터·용량·AZ 문제 | **Datapoints to alarm 감소**, 임계값 낮춤, 쿼터 증설, 다른 인스턴스 유형 |
| 스케일 인이 안 됨 | 스케일링 지표 선택, 경보가 ALARM으로 가는지 | **CPU 기반 정책**, 잘못된 지표, 워밍업 | 지표를 `InvocationsPerInstance`(실시간)·`ApproximateBacklogSizePerInstance`(비동기)로, 임계값·쿨다운 조정 |
| 서버리스 콜드 스타트 | `OverheadLatency`, `ModelSetupTime`, **`ServerlessProvisionedConcurrencySpilloverInvocations`**, `ServerlessProvisionedConcurrencyUtilization`, `ServerlessConcurrentExecutionsUtilization` | 유휴 후 첫 요청, 또는 동시 요청이 현재 동시성 사용량을 넘어 새 컴퓨트 기동 | Provisioned Concurrency — **스필오버 지표가 0이 아니면 PC 부족.** 필요 시 Application Auto Scaling으로 PC 조정 |
| 멀티 모델 엔드포인트 첫 호출 지연 | `ModelLoadingWaitTime`·`ModelDownloadingTime`·`ModelLoadingTime`·`ModelCacheHit`·`LoadedModelCount` | 대상 모델 다운로드·로드 대기 | **`ModelCacheHit`**(이미 로드된 모델로 간 요청 비율)과 `LoadedModelCount`로 로드 빈도 확인 |
| 지표가 안 보임 | 네임스페이스·차원, 실행 역할 권한 | 잘못된 네임스페이스·차원, 로그·지표 게시 권한 | `AWS/SageMaker` vs `/aws/sagemaker/Endpoints` 확인, `EndpointName`·`VariantName` 차원 확인, 정책에 `cloudwatch:PutMetricData` 포함 |

**도구 선택 요약** — 지표 → 경보(CloudWatch) · 로그 패턴 → Logs Insights · 여러 서비스에 걸친 요청 경로 → X-Ray · Lambda 구간 → Lambda Insights · API 호출 감사 → CloudTrail · 상태 변화 자동 대응 → EventBridge.

### 14) 비용 최적화 모범 사례 종합 {#cost-optimization}

공식 문서가 권하는 것만 모았습니다.

1. **추론 옵션을 워크로드에 맞게 선택** — 실시간(예측 가능한 트래픽·일관된 낮은 지연) · 서버리스(스파이크 트래픽·p99 변동 허용, **유휴 비용 없음**) · 비동기(최대 1GB 페이로드·지연 둔감, **0대로 축소 가능**) · 배치 변환(오프라인 대량 추론, **잡 기간만 과금**)
2. **오토 스케일링** — ⚠️ **피크 기준 상시 프로비저닝은 낮은 활용률·낭비를 낳습니다**
3. **엔드포인트 통합** — 활용률이 낮은 여러 엔드포인트를 **멀티 모델·멀티 컨테이너 엔드포인트 하나로** 합칩니다(CloudWatch 활용률로 판단)
4. **모델 최적화** — SageMaker Neo 등으로 최적화하면 **더 적거나 작은 인스턴스로 같은 성능**을 낼 수 있습니다
5. **인스턴스 right-size** — Inference Recommender로 비교하고 **모델·사용 패턴이 바뀌면 다시 실행**합니다. CloudWatch 활용률 경보(80%/20%)와 대시보드로 지속 점검합니다
6. **구매 옵션** — 일관된 사용량에는 **Savings Plans(최대 64%)**, 중단 허용 훈련에는 **관리형 스팟(최대 90%) + 체크포인트**. ⚠️ **약정 전에 right-size**
7. **서버리스·비동기·배치로 유휴 제거** — 간헐적·예측 불가 트래픽에는 서버리스
8. **유휴 리소스 종료** — Studio 자동 종료 확장, 노트북 자동 종료. **호출이 14일간 0건인 엔드포인트는 Compute Optimizer가 유휴로 권장**하며 삭제 또는 scale-to-zero를 고려하라고 합니다
9. **태깅 + 예산 + 분석** — 일관된 태그 → **비용 할당 태그 활성화** → Budgets(실제·예측 임계값) → Cost Explorer → Cost Anomaly Detection
10. **추론 비중 인식** — ML 애플리케이션 인프라 지출의 **최대 90%가 추론**에 쓰이는 경우가 많다고 ML Lens가 서술하므로 호스팅 최적화의 효과가 큽니다
11. **관리형 서비스** — 자체 구축보다 관리형 사용이 **TCO에 유리**하다고 ML Lens가 서술합니다

⚠️ **갱신 횟수·예측 개월 수 같은 수치는 정답 근거로 쓰지 않습니다.** Cost Explorer 13개월·18개월, Budgets 하루 최대 3회는 2026-10-17 문서 기준이고, CUR 문서는 한 페이지 안에서 '하루 한 번'·'하루 최소 한 번'·'하루 최대 세 번'이 섞여 있습니다.

### 15) ⚠️ 서비스 수명·명칭 공지 {#infra-service-status}

| 대상 | 상태(2026-10-17 문서 기준) | 이 Task와의 관계 |
|---|---|---|
| Amazon SageMaker → **Amazon SageMaker AI** | 2024-12-03 개명. API·CLI·정책·URL의 `sagemaker`는 **유지** | 모든 지표·API 이름 |
| Amazon QuickSight → Amazon Quick Suite(블로그) → **Amazon Quick**(현재), BI 기능은 'Amazon Quick Sight' | 기존 API·SDK 호환 | 대시보드 |
| ⚠️ **AWS CloudTrail Lake** | **2026-05-31부터 신규 고객 불가**(기존 고객 계속). 추적·Insights는 영향 없음, CloudWatch 이전 권장 | 추적·감사 |
| ⚠️ SageMaker Model Monitor | 신규 고객 중단. 대체: 오픈소스 모니터링 솔루션 + QuickSight 대시보드 + CloudWatch | 지표 대안 |
| ⚠️ SageMaker Debugger | 신규 고객 중단 | 훈련 프로파일링 |
| ⚠️ SageMaker Profiler | **2027-06-30 지원 종료 예고.** 시스템 자원 모니터링은 CloudWatch로 안내 | 훈련 자원 모니터링 |
| ⚠️ AWS X-Ray SDK/Daemon | **2026-02-25부터 유지보수 모드**(OpenTelemetry 이전 권장). **X-Ray 서비스 자체는 계속** | 관찰성 도구 |
| Trusted Advisor 지원 플랜 | 전체 점검 = Business Support+·Enterprise Support·Unified Operations. Developer·Business·Enterprise On-Ramp는 **2027-01-01 종료** 공지 | 비용 도구 |
| Compute Optimizer의 SageMaker 지원 | 문서상 **엔드포인트 유휴 권장** | 적정 규모 |

**수명 용어** — **Maintenance** = 신규 온보딩 불가(기존 고객은 계속 사용). 위 "신규 고객 중단"은 이 상태입니다. 시험은 가이드(Version 1.0) 기준이므로 **이 서비스들도 개념은 학습하되 상태를 함께** 압니다.

> ℹ️ 서비스 수명 주기 용어 전반과 중단 서비스 목록은 `mla-t2-1` 8) 서비스 상태가 정본입니다.

### 16) 도구 고르기 — 무엇에 답하는가 {#tool-selection}

| 서비스 | 답하는 질문 | SageMaker 예 |
|---|---|---|
| **CloudTrail** | 누가·언제·어떤 API를 호출했나(**감사 기록**) | `CreateEndpoint` 등 관리 이벤트, `InvokeEndpoint`는 데이터 이벤트(옵트인) |
| **CloudWatch** | **지금 얼마나 느리고 바쁜가**, 임계 초과를 알려라 | `ModelLatency`, `CPUUtilization`, 경보·대시보드 |
| **EventBridge** | 어떤 **상태 변화·API 호출**이 일어나면 무엇을 자동 실행하나 | Training Job State Change → Lambda·Pipelines |
| **X-Ray** | **요청 하나**가 구성요소 사이를 지나며 어디서 시간을 썼나 | API Gateway → Lambda → 엔드포인트 호출 체인 |

**비용 쪽 4분할**

| 도구 | 답하는 질문 |
|---|---|
| **Cost Explorer** | 비용이 어디에 얼마나 들었고 앞으로 얼마가 될까(**분석·예측**) |
| **Budgets** | 임계값을 넘으면 **알리거나 막아라**(통제) |
| **Trusted Advisor** | 내 환경에 **절감 기회가 있나**(점검 권고) |
| **CUR / Data Exports** | 가장 상세한 **원천 데이터**를 주고, 내가 쿼리하겠다 |

⚠️ 자주 섞이는 오답 — **CloudTrail은 성능 원인 분석 도구가 아닙니다**(API 호출 감사). **Inference Recommender는 배포 전 벤치마크**이지 운영 모니터링이 아닙니다. **Cost Explorer에 알림을 기대하면 안 됩니다.** **원인 분해 없이 인스턴스만 키우는 조치는 오버헤드·네트워크 원인에 효과가 없습니다.**

---

## ✍️ 시험 포인트

- **지연 증상은 먼저 분해합니다** — `ModelLatency`면 모델 최적화·오토 스케일링·인스턴스 상향, `OverheadLatency`·콜드 스타트면 페이로드 축소·사전 워밍(서버리스는 Provisioned Concurrency), 두 지표가 정상이면 **네트워크(AWS 밖)**
- **여러 서비스를 거치는 요청의 구간 지연은 X-Ray, Lambda 구간은 Lambda Insights, 로그 패턴은 Logs Insights**
- **이벤트 기록(Event history)에서 데이터 이벤트를 찾을 수 없습니다** — 90일 관리 이벤트만 보여 줍니다
- **추적 없이 CloudTrail 이벤트를 EventBridge로 받을 수 없습니다** — 로깅 중인 추적이 전제입니다
- **읽기 전용 관리 이벤트**를 EventBridge 규칙으로 받으려면 규칙 상태가 `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`여야 합니다
- **"배포 전에 인스턴스 후보를 비교"는 Inference Recommender**이고, **"이미 쌓인 지표로 평가"는 Compute Optimizer**입니다. 운영 중 엔드포인트에는 Inference Recommender를 돌리지 않습니다
- **Reserved Instances·Compute Savings Plans는 EC2·Fargate·Lambda 쪽**입니다. SageMaker 사용량에는 SageMaker AI Savings Plans
- **Savings Plans에 용량 보장을 기대하면 틀립니다** — 확정 시점의 용량은 훈련 플랜
- **관리형 스팟은 온디맨드로 폴백하지 않습니다** — 스팟 용량이 없으면 대기 후 중지되므로 체크포인트가 필수입니다
- **태그를 달기만 하고 활성화를 빼먹는 선택지**가 가장 흔한 함정입니다
- **쿼터는 인스턴스 유형별로 따로** 있어서 유형만 바꾼다고 해결되지 않습니다. 증설은 **계정 수준으로 미리** 요청합니다
- **서버리스 엔드포인트에 인스턴스 오토 스케일링을 적용하는 선택지**는 틀립니다 — 동시성(`MaxConcurrency`·Provisioned Concurrency)으로 다룹니다

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| `CPUUtilization`이 100%를 넘어서 이상하다고 본다 | **코어별 0~100을 합산**하므로 4코어면 0~400%가 정상입니다. `MemoryUtilization`만 0~100%입니다 |
| 호출 지표와 인스턴스 지표를 같은 네임스페이스에서 찾는다 | 호출은 `AWS/SageMaker`, 인스턴스는 `/aws/sagemaker/Endpoints` 입니다 |
| 게시 주기만 바꾸면 호출 지표가 촘촘해진다고 본다 | 호출 지표에는 **`EnableEnhancedMetrics=True`** 가 필요합니다(인스턴스 지표는 불필요) |
| `ModelLatency` 값을 밀리초로 읽는다 | CloudWatch는 **마이크로초**입니다. 밀리초인 것은 Inference Recommender 결과와 `ClientLatency` 입니다 |
| 엔드 투 엔드 지연을 두 지표의 합으로 본다 | 인터넷 구간이 더해집니다. 네트워크 지연에는 **SageMaker 지표가 없습니다** |
| 엔드포인트가 X-Ray 세그먼트를 자동으로 보낸다고 본다 | 근거가 없습니다. X-Ray는 **앞단 애플리케이션 체인**의 구간 추적으로 씁니다 |
| 복합 경보로 Auto Scaling 작업을 건다 | 복합 경보는 **EC2 작업·Auto Scaling 작업이 불가**합니다(SNS·조사·OpsItem만) |
| Quick Sight에 CloudWatch 지표를 직접 연결한다 | 확인된 구성은 **S3/Athena 경유**입니다. CloudWatch 대시보드가 운영 지표 상태판입니다 |
| `InvokeEndpoint`가 기본으로 CloudTrail에 남는다고 본다 | **데이터 이벤트라 기본 미기록**이고 이벤트 기록에도 없습니다. 고급 이벤트 선택기로 **옵트인**합니다 |
| 데이터 이벤트의 요청 파라미터를 분석에 쓴다 | `InvokeEndpoint`·`InvokeEndpointAsync` 등은 **요청 파라미터를 기록하지 않습니다** |
| 단일 리전 추적을 콘솔에서 만든다 | **콘솔로 만든 추적은 모두 다중 리전**입니다. 단일 리전은 CLI로만 만듭니다 |
| Compute Optimizer로 엔드포인트를 사이징한다 | 문서가 SageMaker에 명시하는 것은 **유휴 권장(14일 호출 0건)** 입니다. 사이징은 Inference Recommender |
| 라이브 트래픽 엔드포인트에 Inference Recommender를 돌린다 | 운영 엔드포인트에는 돌리지 않으며, **오토스케일링을 쓰는 엔드포인트는 벤치마크 불가**입니다 |
| 태그를 붙였으니 Cost Explorer에서 쪼개 볼 수 있다고 본다 | **비용 할당 태그 활성화**가 별도 단계이고, 반영에 최대 24시간(필터 24~48시간) 걸립니다 |
| 도메인 태그가 기존 앱에도 소급 적용된다고 본다 | **이후 시작하는 앱에만** 적용됩니다. 튜닝 잡 태그도 `AddTags` 이후 시작되는 훈련 잡에만 전파됩니다 |
| 태그를 많이 달아도 문제없다고 본다 | **태그 50개 한도**가 있고 자동 ARN 태그도 포함돼, 넘기면 **리소스 생성이 실패**합니다 |
| Savings Plans를 사면 용량이 확보된다고 본다 | **가격 할인일 뿐**입니다. 용량은 훈련 플랜으로 예약합니다 |
| right-size 전에 Savings Plans를 산다 | 문서의 순서는 **right-size가 먼저**입니다 |
| 서버리스를 실시간으로 바꿔 보고 되돌린다 | ⚠️ **되돌릴 수 없습니다** |
| 스케일 아웃이 느릴 때 쿨다운만 늘린다 | 쿨다운은 변동을 **막는** 장치입니다. **Datapoints to alarm·임계값·쿼터·AZ 용량**을 봅니다 |

---

## 🧪 자가 점검

**Q1.** 엔드포인트 호출이 느려졌다. `ModelLatency`는 평소와 같고 `OverheadLatency`만 올랐다. 원인 후보와 조치는? 두 지표가 모두 정상인데 클라이언트만 느리면? (→ 3), 13))

<details><summary>정답 보기</summary>

`OverheadLatency`는 **요청 수신부터 응답 반환까지에서 `ModelLatency`를 뺀 SageMaker AI 오버헤드**이고, **요청·응답 페이로드 크기·요청 빈도·인증/인가**에 따라 변합니다. 조치는 **페이로드 축소**, 드문 호출로 인한 첫 호출 콜드 스타트는 **테스트 요청으로 사전 워밍**, 서버리스면 **Provisioned Concurrency**입니다(서버리스의 콜드 스타트 시간이 `OverheadLatency`에 포함됩니다). 두 지표가 모두 정상이면 **네트워크 지연**이며 **AWS 인프라 밖**에서 발생하므로 SageMaker 지표가 없습니다 — 클라이언트를 엔드포인트 리전 가까이 두거나 CDN·엣지를 씁니다.
</details>

**Q2.** 엔드포인트 인스턴스의 `CPUUtilization`이 320%로 나온다. 장애인가? 그리고 다중 인스턴스 잡의 지표를 볼 때 주의할 점은? (→ 2))

<details><summary>정답 보기</summary>

**장애가 아닙니다.** `CPUUtilization`은 **코어별 0~100을 합산**하므로 4코어 인스턴스면 **0~400%** 범위이고 320%는 4코어 중 약 3.2코어가 일하는 상태입니다(`GPUUtilization`도 GPU 수만큼 곱해지며, 0~100%인 것은 `MemoryUtilization`입니다). 다중 인스턴스 잡은 인스턴스마다 지표를 보고하지만 **CloudWatch 기본 보기는 전체 인스턴스 평균**이어서 한 인스턴스만 포화된 상황이 묻힐 수 있습니다 — `EnableEnhancedMetrics=True`로 **`InstanceId` 차원**을 추가하면 인스턴스별로 드릴다운할 수 있습니다.
</details>

**Q3.** 보안팀이 "지난 6개월간 누가 엔드포인트를 호출했는지" 보고를 요구한다. CloudTrail 이벤트 기록(Event history)을 봤지만 호출 기록이 없다. 왜이고, 무엇을 해야 하는가? (→ 6))

<details><summary>정답 보기</summary>

`InvokeEndpoint`는 **`AWS::SageMaker::Endpoint` 데이터 이벤트**라서 **기본적으로 기록되지 않고 이벤트 기록에도 남지 않습니다**(이벤트 기록은 리전별 **최근 90일의 관리 이벤트**만 보여 줍니다). 그래서 두 가지가 필요합니다 — ① **추적(trail)** 을 만들어 S3로 전송해야 90일을 넘겨 보관할 수 있고 ② **고급 이벤트 선택기**(`eventCategory`=`Data`, `resources.type`, `resources.ARN`)로 데이터 이벤트를 **옵트인**해야 합니다(추가 요금). ⚠️ 지난 6개월분은 **소급해서 만들 수 없습니다** — 지금 켜야 앞으로가 남습니다. 참고로 `InvokeEndpoint`는 **요청 파라미터를 기록하지 않습니다.**
</details>

**Q4.** S3에 새 훈련 데이터가 올라오면 재훈련 파이프라인을 자동 시작하려 한다. CloudTrail 기반 경로를 구성할 때 빠뜨리기 쉬운 전제는? (→ 7))

<details><summary>정답 보기</summary>

**로깅 중인 추적(trail)이 있어야 합니다.** EventBridge가 받는 이벤트는 **`AWS API Call via CloudTrail`** 이고, S3 객체 쓰기는 **데이터 이벤트**이므로 ① 해당 버킷의 데이터 이벤트를 **캡처하도록 설정된 추적**이 있어야 하고 ② EventBridge 규칙이 그 이벤트를 매칭해 ③ 대상으로 **SageMaker Pipelines**(`StartPipelineExecution`) 또는 Step Functions를 호출합니다. ⚠️ 규칙의 기본 상태 `ENABLED`는 쓰기 관리 이벤트와 데이터 이벤트를 매칭하고, **읽기 전용 관리 이벤트**는 `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`일 때만 매칭됩니다. 더 간단한 대안은 **S3 버킷의 EventBridge 알림**을 켜서 `ObjectCreated`를 직접 받는 것입니다. 참고로 **SageMaker가 직접 보내는 상태 변경 이벤트는 추적 없이도** EventBridge로 옵니다.
</details>

**Q5.** 새 모델을 배포하기 전에 어떤 인스턴스 유형이 비용·지연에 가장 맞는지 고르고 싶다. 그리고 몇 달 전 배포한 엔드포인트가 쓰이는지 확인하려 한다. 각각 어떤 도구인가? (→ 8))

<details><summary>정답 보기</summary>

배포 전 후보 비교는 **SageMaker AI Inference Recommender**입니다 — **모델(또는 Model Registry 등록 모델) + 샘플 페이로드**로 모의 부하 테스트를 돌려 인스턴스 유형·개수와 비용·처리량·지연 지표를 냅니다(Default 잡은 모델 패키지 ARN만으로 **45분 안에**, Advanced 잡은 맞춤 트래픽 패턴으로 평균 2시간). 쓰이지 않는 엔드포인트 식별은 **AWS Compute Optimizer의 유휴 권장**입니다 — **호출이 14일간 0건**인 엔드포인트를 짚어 줍니다(또는 CloudWatch `Invocations`). ⚠️ 문서가 SageMaker 엔드포인트에 명시하는 Compute Optimizer 지원은 **유휴 권장**이고 **사이징은 Inference Recommender**의 일입니다. ⚠️ 운영 엔드포인트에는 Inference Recommender를 돌리지 않습니다.
</details>

**Q6.** 팀별로 SageMaker 비용을 쪼개 보려고 모든 리소스에 `Team` 태그를 달았다. 그런데 Cost Explorer에 `Team`이 보이지 않는다. 무엇이 빠졌고, 얼마나 기다려야 하는가? (→ 10))

<details><summary>정답 보기</summary>

**비용 할당 태그 활성화**가 빠졌습니다. 리소스에 태그를 붙이는 것과 결제 쪽에서 활성화하는 것은 **별개 단계**이며, Billing and Cost Management 콘솔의 Cost allocation tags에서 **태그 키 단위**로 활성화해야 Cost Explorer와 비용 할당 보고서에 나타납니다(`UpdateCostAllocationTagsStatus` API로 일괄 가능, 조직에서는 **관리 계정만** 접근). ⚠️ **AWS 생성 태그(`aws:`)와 사용자 정의 태그(`user:`) 모두 각각 활성화**해야 하고, SageMaker 자동 태그(`sagemaker:domain-arn` 등)도 예외가 아닙니다. 지연은 태그 적용 후 **목록에 뜨기까지 최대 24시간 + 활성화까지 다시 최대 24시간**이며, Studio 가이드는 Cost Explorer 필터에 뜨기까지 **24~48시간**으로 안내합니다.
</details>

**Q7.** 다음 셋을 각각 어떤 수단으로 해결하는가? ① 중단돼도 재개 가능한 대규모 훈련의 비용 절감 ② 상시 가동되는 ML 인스턴스의 약정 할인 ③ 다음 달 특정 날짜에 GPU 인스턴스를 반드시 확보 (→ 11))

<details><summary>정답 보기</summary>

① **관리형 스팟 훈련** — `EnableManagedSpotTraining=True`로 **최대 90%** 절감하되 **체크포인트가 필수**입니다(중단 시 S3 체크포인트에서 재개). ⚠️ **온디맨드로 폴백하지 않으므로** 스팟 용량이 없으면 `MaxWaitTimeInSeconds`까지 대기 후 중지되며, `MaxWaitTimeInSeconds`는 `MaxRuntimeInSeconds`보다 커야 합니다. ② **SageMaker AI Savings Plans** — 시간당 사용량을 1년 또는 3년 약정해 **최대 64%** 할인받고, 인스턴스 패밀리·크기·리전·구성요소와 무관하게 자동 적용됩니다(⚠️ Compute Savings Plans는 EC2·Fargate·Lambda 쪽입니다). ③ **훈련 플랜** — ⚠️ Savings Plans는 **가격 할인일 뿐 용량을 보장하지 않습니다.** 인스턴스 유형·수량·AZ·기간을 정해 용량을 예약하는 것은 훈련 플랜입니다. 순서상 **약정 전에 right-size**가 먼저입니다.
</details>

**Q8.** 서버리스 엔드포인트가 유휴 후 첫 요청에서 느리다. 어떤 지표를 보고 무엇을 조정하는가? 그리고 실시간 엔드포인트의 오토 스케일링이 "service limit" 오류로 실패하면? (→ 12))

<details><summary>정답 보기</summary>

콜드 스타트는 **`OverheadLatency`**(콜드 스타트 시간이 여기 포함)와 **`ModelSetupTime`**(새 컴퓨트 기동 시간)으로 보고, **Provisioned Concurrency**를 할당합니다(**≤ `MaxConcurrency`**, 엔드포인트당 최대 동시성 **200**). ⚠️ **`ServerlessProvisionedConcurrencySpilloverInvocations`가 0이 아니면 PC가 부족**하다는 신호이며, 필요하면 Application Auto Scaling으로 PC를 조정합니다. "service limit" 오류는 스케일 아웃이 **인스턴스 유형별 쿼터**에 도달한 것이므로 Service Quotas 콘솔에서 **계정 수준 증설을 요청**합니다 — ⚠️ **즉시 반영되지 않으니 미리 요청**해야 하고, 쿼터는 **유형별로 따로** 있어 유형만 바꿔서는 해결되지 않습니다.
</details>

**Q9.** 지표 경보·이상 탐지 경보·복합 경보를 각각 언제 쓰는가? 그리고 복합 경보가 못 하는 일은? (→ 5))

<details><summary>정답 보기</summary>

**지표 경보(정적 임계값)** 는 고정 숫자와 비교할 때 — CPU 지속 80% 초과 같은 규칙입니다. **이상 탐지 경보**는 **정적 임계값이 없고** 통계·ML이 만든 **예상 값 밴드**와 비교하므로 **시간대·요일 패턴(계절성)과 추세**가 있는 호출량·지연에 맞습니다(ML Lens는 이것으로 KPI 예상값을 만들어 이탈 시 배포를 중단·롤백하라고 안내합니다). **복합 경보**는 **다른 경보들의 상태를 규칙 식으로 조합**해 **경보 소음을 줄입니다.** ⚠️ 복합 경보는 **EC2 작업과 Auto Scaling 작업을 할 수 없습니다**(SNS 알림·조사·OpsItem만 가능). 참고로 경보 상태는 OK·ALARM·INSUFFICIENT_DATA이고 **이력은 30일** 보존되며, 경보는 **상태가 바뀔 때만** 작업을 호출합니다.
</details>

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> MLA-C02의 대응 Task는 **4.2 ML 및 AI 인프라 비용 및 성능을 최적화하고 관리합니다**입니다. ⚠️ **이 Task는 도메인 4에서 유일하게 "삭제된 콘텐츠"가 있는 Task**입니다. 아래는 공식 비교 페이지 기준이며 C01 시험 범위가 아닙니다.

**추가된 콘텐츠 4개 — 전부 생성형 AI·에이전트 비용 쪽입니다.**

- 4.2.7 프로덕션 환경에서 추론에 **FM을 사용할 경우 비용에 미치는 영향**을 평가합니다
- 4.2.8 **에이전트 리소스 사용 패턴**을 모니터링합니다
- 4.2.9 **사용 최적화를 통해 FM 추론 비용**을 관리합니다
- 4.2.10 **AI 관련 비용 패턴**을 모니터링합니다(예: 토큰 사용 최적화, 임베딩 계산 비용, 벡터 데이터베이스 스토리지 최적화)

**삭제된 콘텐츠 2개 — C01에서만 묻습니다.**

- **인프라 모니터링**(예: Amazon EventBridge 이벤트 사용) → 이 문서 7)
- **비용 및 성능과 관련된 용량 문제 해결**(예: 프로비저닝된 동시성, 서비스 할당량, 오토 스케일링) → 이 문서 12)

⚠️ 즉 7)과 12)는 **C01 고유 범위**입니다 — C02로 넘어갈 계획이라면 학습 비중을 조절할 수 있지만, **C01을 응시한다면 그대로 출제 범위**입니다.

⚠️ 비교 페이지는 '추가'된 항목만 번호로 나열하며, 번호가 건너뛰는 항목이 C01의 어느 항목에 대응하는지는 설명하지 않습니다.

---

### 📌 출처

- Amazon SageMaker AI metrics in Amazon CloudWatch (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/monitoring-cloudwatch.html
- CloudWatch Logs for Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/logging-cloudwatch.html
- Well-Architected machine learning design principles (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/design-principles.html
- MLOPS05-BP01 Establish deployment environment metrics (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlops05-bp01.html
- Machine Learning Lens — Performance efficiency — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/performance-efficiency.html
- Machine Learning Lens — Reliability — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/reliability.html
- MLREL05-BP01 Allow automatic scaling of the model endpoint (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlrel05-bp01.html
- Best practices for deploying models on SageMaker AI Hosting Services (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-best-practices.html
- Profiler availability change (Amazon SageMaker Profiler 공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/profiler-availability-change.html
- Deploy models with Amazon SageMaker Serverless Inference (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html
- Alarms and logs for tracking metrics from serverless endpoints (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints-monitoring.html
- AWS Lambda — Understanding Lambda function scaling (공식 문서) — https://docs.aws.amazon.com/lambda/latest/dg/lambda-concurrency.html
- SageMaker AI automatic scaling — Define a scaling policy (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-add-code-define.html
- How target tracking scaling for Application Auto Scaling works (공식 문서) — https://docs.aws.amazon.com/autoscaling/application/userguide/target-tracking-scaling-policy-overview.html
- Amazon CloudWatch — Visualizing your service quotas and setting alarms (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Quotas-Visualize-Alarms.html
- Get compute capacity for SageMaker Training Jobs (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/train-get-capacity.html
- What is AWS X-Ray? (공식 문서) — https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html
- Integrating AWS X-Ray with other AWS services (공식 문서) — https://docs.aws.amazon.com/xray/latest/devguide/xray-services.html
- AWS X-Ray concepts (공식 문서) — https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html
- Amazon CloudWatch Lambda Insights (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights.html
- Analyzing log data with CloudWatch Logs Insights (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
- CloudWatch Logs Insights language query syntax (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html
- Using Amazon CloudWatch alarms (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Alarms.html
- Using CloudWatch anomaly detection (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html
- Using Amazon CloudWatch dashboards (공식 문서) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Dashboards.html
- What is Amazon Quick? (공식 문서) — https://docs.aws.amazon.com/quick/latest/userguide/what-is.html
- Logging Amazon SageMaker AI API calls using AWS CloudTrail (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/logging-using-cloudtrail.html
- AWS CloudTrail — Creating a trail for your AWS account (공식 문서) — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-and-update-a-trail.html
- AWS CloudTrail — Creating a trail with the CloudTrail console (공식 문서) — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-create-a-trail-using-the-console-first-time.html
- AWS CloudTrail — CloudTrail Lake availability change (공식 공지) — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html
- Amazon EventBridge — AWS service events delivered via AWS CloudTrail (공식 문서) — https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-event-cloudtrail.html
- Events that Amazon SageMaker AI sends to Amazon EventBridge (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/automating-sagemaker-with-eventbridge.html
- Schedule Pipeline Runs (SageMaker Pipelines와 EventBridge, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/pipeline-eventbridge.html
- Amazon EventBridge event reference — Amazon CloudWatch events (공식 문서) — https://docs.aws.amazon.com/eventbridge/latest/ref/events-ref-cloudwatch.html
- MLPERF06-BP05 Establish an automated re-training framework (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlperf06-bp05.html
- Amazon EC2 instance type specifications (공식 문서) — https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-instance-type-specifications.html
- Amazon EC2 instance types (현재 세대 인스턴스 목록, 공식 문서) — https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-types.html
- Amazon SageMaker Inference Recommender (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender.html
- Recommendation jobs with Amazon SageMaker Inference Recommender (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender-recommendation-jobs.html
- Get an inference recommendation for an existing endpoint (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender-existing-endpoint.html
- Recommendation results (Inference Recommender 결과 지표, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender-interpret-results.html
- What is AWS Compute Optimizer? (공식 문서) — https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html
- AWS resources supported by Compute Optimizer (공식 문서) — https://docs.aws.amazon.com/compute-optimizer/latest/ug/supported-resources.html
- Compute Optimizer — Viewing idle resource recommendations (공식 문서) — https://docs.aws.amazon.com/compute-optimizer/latest/ug/view-idle-recommendations.html
- MLCOST04-BP01 Select optimal computing instance size (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp01.html
- MLCOST05-BP03 Right-size the model hosting instance fleet (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost05-bp03.html
- MLCOST06-BP03 Monitor endpoint usage and right-size the instance fleet (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost06-bp03.html
- Inference cost optimization best practices (SageMaker AI 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html
- Analyzing your costs and usage with AWS Cost Explorer (공식 문서) — https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html
- Use AWS Billing and Cost Management (공식 문서) — https://docs.aws.amazon.com/cost-management/latest/userguide/what-is-costmanagement.html
- AWS Trusted Advisor (공식 문서) — https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
- AWS Trusted Advisor — Cost optimization checks (공식 문서) — https://docs.aws.amazon.com/awssupport/latest/user/cost-optimization-checks.html
- Managing your costs with AWS Budgets (공식 문서) — https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
- Organizing and tracking costs using AWS cost allocation tags (공식 문서) — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html
- Activating user-defined cost allocation tags (공식 문서) — https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html
- Amazon SageMaker Studio administration best practices — Cost attribution (AWS 백서) — https://docs.aws.amazon.com/whitepapers/latest/sagemaker-studio-admin-best-practices/cost-attribution.html
- SageMaker AI — Custom tag propagation (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/custom-tags.html
- SageMaker AI — Automatic tag propagation (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/domain-multiple-tag.html
- Amazon SageMaker API Reference — AddTags — https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_AddTags.html
- MLCOST06-BP01 Monitor usage and cost by ML activity (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost06-bp01.html
- MLCOST04-BP12 Set up a budget and use resource tagging to track costs (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost04-bp12.html
- MLCOST01-BP02 Use managed services to reduce total cost of ownership (Machine Learning Lens) — https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlcost01-bp02.html
- What are AWS Cost and Usage Reports? (공식 문서) — https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html
- Cloud Intelligence Dashboards — CUDOS, CID, KPI (공식 가이던스) — https://docs.aws.amazon.com/guidance/latest/cloud-intelligence-dashboards/cudos-cid-kpi.html
- Managed Spot Training in Amazon SageMaker AI (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html
- Savings Plans types (공식 문서) — https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html
- What are Savings Plans? (공식 문서) — https://docs.aws.amazon.com/savingsplans/latest/userguide/what-is-savings-plans.html
- Compute Savings Plans and Reserved Instances (공식 문서) — https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html
- Reserve Flexible Training Plans for ML workloads (공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/reserve-capacity-with-training-plans.html
- How AWS Pricing Works — AWS Cost Optimization (AWS 백서) — https://docs.aws.amazon.com/whitepapers/latest/how-aws-pricing-works/aws-cost-optimization.html
- What is Amazon SageMaker AI? (개명·네임스페이스 유지, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html
- AWS Product Lifecycle (서비스 수명 용어, 공식 문서) — https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html
- Custom Inference Code with Hosting Services (컨테이너 헬스 체크, 공식 문서) — https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-inference-code.html
- Amazon SageMaker Model Monitor availability change (공식 공지) — https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html
- MLA-C01 공식 시험 가이드 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
