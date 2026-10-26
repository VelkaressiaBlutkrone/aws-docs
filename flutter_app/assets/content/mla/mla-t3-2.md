---
examGuideTaskId: mla-t3-2
certCode: MLA-C01
domain: 3
domainName: ML 워크플로의 배포 및 오케스트레이션
domainWeightPct: 22
title: 인프라 생성·스크립팅 (오토 스케일링·용량 모델·IaC·컨테이너 운영·VPC)
coversTasks:
  - "3.2"
sources:
  - title: Automatically scale Amazon SageMaker AI models (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling.html
  - title: Scaling policy options (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-policy.html
  - title: Load testing for variant automatic scaling (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-scaling-loadtest.html
  - title: Application Auto Scaling 사용 설명서 (공식 문서)
    url: https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html
  - title: Optimize costs for inference (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html
  - title: AWS CloudFormation vs AWS CDK — Getting started with the AWS CDK (공식 문서)
    url: https://docs.aws.amazon.com/cdk/v2/guide/home.html
  - title: Walkthrough — Refer to resource outputs in another stack (공식 문서)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-crossstackref.html
  - title: Adapting your own Docker container to work with SageMaker AI (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-training-algo-dockerfile.html
  - title: Amazon ECR 사용 설명서 (공식 문서)
    url: https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html
  - title: Give SageMaker AI hosted endpoints access to resources in your VPC (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/host-vpc.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 인프라 생성·스크립팅 (오토 스케일링·용량 모델·IaC·컨테이너 운영·VPC)

> **커버하는 공식 Task** — MLA-C01 · 도메인 3 「ML 워크플로의 배포 및 오케스트레이션」(22%) · **Task 3.2 기존 아키텍처 및 요구 사항을 기반으로 인프라 만들기 및 스크립팅** (`mla-t3-2`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 3.1이 **"무엇을 고르는가"**였다면 3.2는 **"고른 것을 어떻게 선언하고 얼마나 늘릴 것인가"** — 스케일링 정책, IaC 템플릿, 컨테이너, VPC 설정이 전부 이 Task입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] SageMaker 엔드포인트의 오토 스케일링을 실제로 수행하는 서비스와 **확장 대상(scalable target) 3종**을 말할 수 있다
- [ ] 대상 추적·단계·예약 정책을 **트리거·설정 내용·경보 주체**로 구분하고 어느 것이 권장인지 안다
- [ ] 인스턴스당 호출 수·CPU 사용률·백로그·동시 요청 수 중 상황에 맞는 지표를 고르고, **대상 추적 지표가 만족해야 하는 조건**을 안다
- [ ] 부하 테스트로 목표값을 정하는 공식 공식과 **SAFETY_FACTOR의 출발값**을 안다
- [ ] 최소 용량·쿨다운 기본값과 **0대까지 줄일 수 있는 유형·그 깨우기 방법**을 구분한다
- [ ] 추론 옵션을 **온디맨드 vs 프로비저닝** 축으로 다시 읽는다
- [ ] 가격 할인(Savings Plans·Spot)과 용량 확보(프로비저닝된 동시성·용량 예약·훈련 계획)가 **독립된 차원**임을 안다
- [ ] 공식 문서가 드는 비용·확장·유지관리 모범 사례를 열거하고, 가이드 SK1의 예시 구절을 **개별 패턴으로** 읽는다
- [ ] CloudFormation과 CDK의 절충을 **선언형 vs 명령형·추상화 계층**으로 설명하고 SageMaker 리소스의 갱신 동작을 안다
- [ ] 스택 간 값 전달 세 방식(Export·중첩 스택·GetStackOutput)을 **범위와 참조 강도**로 가른다
- [ ] 컨테이너·이미지 개념과 ECR·ECS·EKS·Fargate의 역할을 혼동하지 않는다
- [ ] 훈련 컨테이너 계약(`/opt/ml` 경로·`train` 실행)과 ECR 운영(스캔 2종·수명 주기 정책)을 안다
- [ ] `VpcConfig`·`EnableNetworkIsolation`·인터페이스 엔드포인트·S3 게이트웨이 엔드포인트가 각각 **무엇을 해결하는지** 구분한다
- [ ] 배포 API 3단계와 SDK 버전별 클래스 대응을 안다

---

## 🎯 왜 중요한가

3.2는 "스크립팅"이라는 말 때문에 코드 암기처럼 보이지만, 문항이 실제로 가르는 지점은 **"왜 그 설정이어야 하는가"**입니다. 오토 스케일링에서 지표를 잘못 고르면 정책이 수렴하지 않습니다. 공식 문서가 "인스턴스가 늘어나면 지표 값이 줄어야 한다"고 요구하는 이유를 모르면, 보기에 섞인 그럴듯한 지표를 골라 틀립니다.

두 번째 축은 **"어디까지가 관리형인가"**입니다. 서버리스 추론은 스케일링 정책을 만들 일이 없고, 비동기는 0대까지 내려가지만 깨우는 장치를 따로 붙여야 하며, 일반 실시간 변형은 최소 1대를 유지합니다. 같은 "자동 확장"이라는 말 아래에 서로 다른 계약이 있습니다.

세 번째는 **격리 설정의 방향**입니다. `VpcConfig`는 컨테이너에 VPC 네트워크를 *주는* 설정이고 `EnableNetworkIsolation`은 컨테이너의 네트워크를 *끊는* 설정입니다. 둘을 반대로 외우면 시나리오 문항에서 반드시 틀립니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **Application Auto Scaling(AAS)** | EC2 Auto Scaling이 다루지 않는 개별 서비스(ECS 서비스·DynamoDB·Lambda 프로비저닝된 동시성·SageMaker 변형 등)의 자동 조정을 맡는 서비스 |
| **확장 대상(scalable target)** | 조정의 단위. 리소스 ID + 확장 차원(scalable dimension) + 네임스페이스의 조합으로 식별한다. 정책을 만들기 전에 먼저 등록해야 한다 |
| **쿨다운(cooldown)** | 한 번 조정한 뒤 다음 조정까지 기다리는 시간. 한국어 문서는 "휴지 기간"으로 옮긴다 |
| **온디맨드 / 프로비저닝** | 필요할 때 용량을 받아 쓴 만큼 내는 방식 / 용량이나 사용 약정을 미리 정해 두는 방식 |
| **합성(synthesize)** | CDK 코드를 실행해 CloudFormation 템플릿을 만들어 내는 단계 |
| **L1 / L2 / L3** | CDK의 추상화 계층. L1은 CloudFormation 리소스와 1:1(`Cfn*`), L2는 의도 기반 API에 안전한 기본값, L3는 패턴 |
| **컨테이너 이미지** | 컨테이너를 만드는 읽기 전용(불변) 템플릿. 이미지를 보관하는 곳이 레지스트리(ECR) |

---

## 📖 핵심 개념

### 1) 오토 스케일링의 구조 — 실제로 조정하는 것은 AAS다 {#autoscaling-architecture}

SageMaker 오토 스케일링은 "모델에 프로비저닝된 인스턴스 수를 워크로드 변화에 맞춰 늘리고 줄이는" 기능입니다. 중요한 점은 **실제 조정을 SageMaker가 아니라 Application Auto Scaling이 수행**한다는 것입니다. SageMaker AI·CloudWatch·AAS 세 서비스의 API가 함께 동작합니다.

**확장 대상 3종**

| 확장 대상 | `ScalableDimension` | `ResourceId` 형식 | 늘리고 줄이는 것 |
|---|---|---|---|
| 엔드포인트 변형 | `sagemaker:variant:DesiredInstanceCount` | `endpoint/<엔드포인트명>/variant/<변형명>` | 인스턴스 수 |
| 서버리스의 프로비저닝된 동시성 | `sagemaker:variant:DesiredProvisionedConcurrency` | 위와 동일 | 프로비저닝된 동시성 값 |
| 추론 컴포넌트 | `sagemaker:inference-component:DesiredCopyCount` | `inference-component/<이름>` | 모델 복사본 수 |

- **구성 순서**(CLI·API) — ① 확장 대상 등록(`MinCapacity`·`MaxCapacity`) → ② 정책 정의 → ③ 정책 적용. **콘솔로 구성하면 SageMaker가 확장 대상을 자동 등록**합니다.
- **권한** — `SagemakerFullAccessPolicy`에 필요한 권한이 모두 들어 있습니다. 자체 정책을 쓰면 `application-autoscaling:*`, `cloudwatch:PutMetricAlarm`·`DescribeAlarms`·`DeleteAlarms`, `iam:CreateServiceLinkedRole` 등을 직접 넣어야 합니다. 서비스 연결 역할은 확장 대상을 처음 등록할 때 자동 생성됩니다.
- ⚠️ **엔드포인트 업데이트와의 충돌** — 오토 스케일링이 걸린 변형의 **인스턴스 유형**을 바꾸는 `UpdateEndpoint`는 **실패**합니다. 정책을 삭제하고 `DeregisterScalableTarget`으로 등록을 해제한 뒤 업데이트하고, 다시 등록·정책 연결을 합니다. 예외로 **모델만** 바꾸는 업데이트는 허용됩니다.
- **IaC 표현** — `AWS::ApplicationAutoScaling::ScalableTarget` + `AWS::ApplicationAutoScaling::ScalingPolicy`로 선언합니다(→ 8)).

> 🧠 원리: **대상 추적** 정책이면 AAS가 CloudWatch 경보를 직접 만들고 관리하며 지표·목표값으로 조정량을 계산합니다. **단계** 정책은 사용자가 CloudWatch 경보를 만들어 정책에 연결해야 합니다. 이 차이가 두 정책을 가르는 가장 실용적인 기준입니다.

### 2) 정책 유형 — 대상 추적·단계·예약 {#policy-types}

SageMaker 문서는 워크로드 변화에 자동 대응하는 정책으로 **대상 추적과 단계 두 가지**를 소개하고, 시간 기반 조정은 **예약 작업**으로 따로 설명합니다.

| 정책 유형 | 언제 | 메커니즘 |
|---|---|---|
| **대상 추적**(Target tracking) | 지표를 목표값 근처로 유지. 문서가 **"대부분의 경우" 권장** | 지표와 목표값만 지정하면 AAS가 경보·조정량 계산을 맡는다. 증가 시 공격적, 감소 시 보수적으로 조정. 쿨다운 기본 300초 |
| **단계**(Step) | 위반 크기에 따라 증감량을 다르게 주는 고급 구성. ⚠️ **활성 인스턴스 0대에서 scale-out 하려면 필수** | 경보를 사용자가 정의해 정책에 연결한다 |
| **예약**(Scheduled) | 예측 가능한 시간대 패턴 | 정해진 시각에 최소·최대 용량을 바꾼다. 현재 용량이 새 최소보다 작으면 최소까지 scale-out. ⚠️ SageMaker에서는 **CLI·API로만** 관리한다 |
| **예측**(Predictive) | AAS 기능 목록에는 있다 | CloudFormation 레퍼런스는 **"ECS 서비스에서 지원"**이라 명시하고, SageMaker 정책 소개에는 등장하지 않는다 |

- **여러 정책 동시 적용** — 한 대상에 대상 추적 정책을 여러 개 둘 수 있습니다(지표가 서로 달라야 함). **scale-out은 하나라도 준비되면 수행하고 scale-in은 모두 준비돼야 수행**하며, 동시에 지시하면 가장 큰 용량을 주는 정책을 따릅니다. 단계 정책과 섞으면 충돌로 의도치 않은 동작이 날 수 있습니다.
- **예약 + 정책** — 예약은 조정의 **경계(min/max)를 옮기고**, 그 안에서 정책이 동적으로 움직입니다. 예약은 선제적이고 정책은 반응적입니다.
- 가이드 K5의 "수요 기준"은 대상 추적·단계, "시간 기준"은 예약 스케일링에 대응합니다.

> 🧠 원리: 예약 작업은 "현재 용량 vs 지정한 최소·최대"를 비교해 최소보다 작으면 올리고 최대보다 크면 내립니다. 그래서 "아침 9시에 최소 용량을 올려 두는" 방식으로 사전 준비를 구현합니다.

> ⚠️ **예측 스케일링을 SageMaker 정답으로 고르지 않습니다.** 다만 공식 문서가 "SageMaker는 지원하지 않는다"고 쓴 문장도 없습니다(CloudFormation이 ECS만 명시하고 SageMaker 소개 목록에 없다는 것이 근거의 전부입니다).

### 3) 스케일링 지표 선택 {#scaling-metrics}

**사전 정의 지표** — 열거형으로 정의되어 코드나 콘솔에서 이름으로 지정합니다.

| `PredefinedMetricType` | 대상 | 의미·비고 |
|---|---|---|
| `SageMakerVariantInvocationsPerInstance` | 변형(실시간) | 변형의 인스턴스 하나가 **분당** 호출된 평균 횟수. SageMaker가 **"강력 권장"**. 표준 지표라 1분 주기. ⚠️ **비동기 엔드포인트에서는 발행되지 않는다** |
| `SageMakerInferenceComponentInvocationsPerCopy` | 추론 컴포넌트 | 복사본당 호출 수 |
| `SageMakerVariantConcurrentRequestsPerModelHighResolution` | 변형 | 모델 컨테이너가 받는 동시 요청 수. **10초마다 발행** → scale-out이 빨라지고 scale-in 속도는 표준 지표와 같다 |
| `SageMakerInferenceComponentConcurrentRequestsPerCopyHighResolution` | 추론 컴포넌트 | 위와 동일 |
| `SageMakerVariantProvisionedConcurrencyUtilization` | 서버리스 PC | 프로비저닝된 동시성 사용률 |

**사용자 지정 지표** — "용량에 비례해 변하는 어떤 프로덕션 변형 지표든" 쓸 수 있지만 조건이 있습니다: **유틸리제이션 지표여야 하고, 인스턴스가 얼마나 바쁜지를 나타내야 하며, 인스턴스가 늘면 값이 줄어야 합니다.** 그리고 **프로덕션에 쓰기 전에 반드시 테스트**해야 합니다.

- 예시: `CPUUtilization`(네임스페이스 `/aws/sagemaker/Endpoints`, 평균 50%). GPU 기반 멀티 모델 엔드포인트에는 `GPUUtilization` 예시가 있습니다. 비동기에는 `ApproximateBacklogSizePerInstance`를 씁니다.
- ⚠️ **`CPUUtilization`은 코어별 사용률의 합**이라 4 vCPU면 범위가 0%~400%입니다. 목표값을 정할 때 이 척도를 고려해야 합니다.

**지표 선택 기준**

| 후보 | 선택 기준 |
|---|---|
| 인스턴스당 호출 수 | 요청량에 부하가 비례하는 일반 실시간 추론, 멀티 모델 엔드포인트. **기본 선택지** |
| CPU 사용률 | 추론이 CPU에 묶일 때(사용자 지정 지표). GPU 엔드포인트는 사용률 계열 지표 |
| 동시 요청 수(고해상도) | 트래픽 급증에 더 빨리 반응해야 할 때(10초 주기) |
| 백로그 크기 | 큐 기반 비동기 추론 |
| 프로비저닝된 동시성 사용률 | 서버리스 PC를 부하에 맞춰 조정 |
| 모델 지연 시간(`ModelLatency`) | ⚠️ **사전 정의 지표 목록에 없다.** 부하 테스트에서 **피크 RPS를 판정하는 기준**과 알람·모니터링에 쓴다. 정책의 직접 스케일링 지표로 쓰라는 공식 권고 문장은 확인되지 않았다 |

**부하 테스트로 목표값 정하기(공식 절차)**

1. 인스턴스 1대로 엔드포인트를 만들고 병렬 요청을 늘려 가며 RPS와 모델 지연을 관찰한다. **모델 지연이 늘거나 성공률이 떨어지는 지점**이 인스턴스당 피크 RPS(`MAX_RPS`)다
2. 목표값 = **`(MAX_RPS × SAFETY_FACTOR) × 60`** (분당으로 측정했다면 ×60 생략)
3. `SAFETY_FACTOR`는 **0.5부터** 시작해 증가·감소 트래픽에서 모두 검증한다

예: `MAX_RPS` 100, `SAFETY_FACTOR` 0.5 → 목표값 3000.

**Inference Recommender의 정책 추천** — 완료된 추천 작업에서 `GetScalingConfigurationRecommendation`으로 정책 추천을 받습니다. 입력은 `TargetCpuUtilizationPerCore`(기본 50%)와 예상 트래픽, 출력은 권장 `MinCapacity`·`MaxCapacity`·쿨다운·지표별 목표값이며 `PutScalingPolicy`로 적용합니다.

> 🧠 원리: 대상 추적은 "지표가 목표값을 넘으면 용량을 더하고 밑돌면 뺀다"는 구조입니다. 그래서 **지표가 용량에 반비례해 움직여야** 수렴합니다. 문서가 "인스턴스가 늘면 지표가 줄어야 한다"고 요구하는 이유가 바로 이것입니다 — 인스턴스를 늘려도 값이 그대로인 지표를 쓰면 정책이 계속 늘리기만 합니다.

### 4) 용량 한도·쿨다운·0대로 줄이기 {#capacity-limits}

| 항목 | 값·동작 |
|---|---|
| 최소 용량 | 일반 변형은 **1 이상**이어야 하고 최대값 이하여야 한다 |
| 최대 용량 | 최소값 이상. SageMaker가 이 값에 한도를 강제하지는 않는다 |
| 트래픽이 0이 되면 | 지정한 **최소 인스턴스 수까지** scale-in(0대가 아니다). 값이 0인 지표를 발행한다 |
| 수동 조정 | 최소값을 올리면 수동 scale-out, 최대값을 내리면 수동 scale-in |
| 쿨다운 기본값 | scale-in·scale-out 각각 **300초** |
| 쿨다운 조정 지침 | 인스턴스가 **너무 빨리 늘고 줄면 값을 늘리고**, 충분히 빨리 늘지 않으면 줄인다 |

**0대까지 줄일 수 있는 것**

| 유형 | 0대 | 방법·주의 |
|---|---|---|
| 일반 실시간 변형 | **불가** | 최소값 ≥ 1. 트래픽이 0이어도 최소 인스턴스 수가 유지된다 |
| 추론 컴포넌트 기반 | 가능 | 컴포넌트 `MinCapacity` 0 + 변형 `ManagedInstanceScaling.MinInstanceCount` 0 |
| 비동기 | 가능 | `MinCapacity` 0. 요청은 큐에서 대기한다(보조 정책은 [`mla-t3-1` 3)](mla-t3-1.md#async-detail)) |
| 서버리스 | 유휴 시 0 | 정책이 필요 없다(SageMaker가 관리). 단 **프로비저닝된 동시성의 최소는 1** |

- **쿨다운의 의미** — scale-out 쿨다운은 "지속적으로, 그러나 과하지 않게" 늘리려는 장치이고, scale-in 쿨다운은 가용성을 지키려 보수적으로 줄이려는 장치입니다. **scale-in 쿨다운 중에 다른 경보가 scale-out을 요구하면 즉시 scale-out 하며 scale-in 쿨다운은 중단됩니다.** 쿨다운은 정책 관련 조정에만 적용되고 예약 작업은 기다리지 않습니다.
- **추론 컴포넌트를 0대에서 깨우기** — 0대로 줄어든 엔드포인트는 인스턴스가 다시 프로비저닝될 때까지 요청에 응답하지 못합니다. 자동화하려면 **단계 스케일링 정책 + CloudWatch 경보**를 만들고, 경보 지표로 **`NoCapacityInvocationFailures`**(엔드포인트가 요청을 받았는데 활성 인스턴스가 없을 때 발행)를 씁니다. 프로비저닝에 수 분이 걸리고 **그동안의 호출은 오류**가 납니다.
- **최소 용량과 가용성** — 프로덕션 엔드포인트는 인스턴스를 여러 대 두라는 것이 공식 권고이고, VPC를 쓰면 서로 다른 AZ의 서브넷을 최소 2개 구성합니다. 추론 컴포넌트로 99.95% 가용성을 목표로 하면 **복사본을 2개보다 많이**, 관리형 오토 스케일링의 최소 인스턴스를 **2**로 두라고 안내합니다.

### 5) 추론 옵션별 용량 모델 {#capacity-models}

**용량을 누가 정하느냐**(프로비저닝 vs 온디맨드)가 스케일링 방식을 가릅니다. 각 옵션의 **한도**(페이로드·처리 시간)는 [`mla-t3-1` 1)](mla-t3-1.md#inference-options)이 정본입니다.

| 옵션 | 용량 모델 | 스케일링 방식 | 0대까지? |
|---|---|---|---|
| 실시간(인스턴스 기반) | **프로비저닝** — 항상 가용, 인스턴스를 쓰는 만큼 과금 | AAS 대상 추적·단계·예약, 변형 `DesiredInstanceCount` | 불가(최소 1) |
| 실시간 + 추론 컴포넌트 | 인스턴스는 프로비저닝, 모델은 복사본 단위 | 컴포넌트 `DesiredCopyCount` + 변형 `ManagedInstanceScaling` | 가능 |
| 서버리스 | **온디맨드** — SageMaker가 컴퓨트를 자동 시작·확장. **인스턴스 선택·스케일링 정책 관리가 불필요** | 정책 없음. 동시성 한도(1~200)로 상한 | 유휴 시 0 |
| 서버리스 + 프로비저닝된 동시성 | 온디맨드 + 지정한 수만큼 미리 웜 | PC를 AAS로 대상 추적·예약 | PC 최소 1 |
| 비동기 | 큐 + 인스턴스(고정 수로 처리율 조절 가능) | 백로그 지표 대상 추적 | 가능 |
| 배치 변환 | 작업 시간 동안만 인스턴스 과금, 상시 엔드포인트 없음 | 해당 없음 | — |

- **서버리스 동시성** — 리전·계정 전체 서버리스 엔드포인트가 공유하는 총 동시성은 주요 8개 리전에서 1000, 나머지 500이고, 엔드포인트별 최대 동시성은 200, 리전당 서버리스 엔드포인트는 50개입니다. 상한을 넘는 호출은 스로틀링됩니다.
- **멀티 모델 엔드포인트** — 오토 스케일링에는 인스턴스당 호출 수를 권장하고, 목표값은 지연 요구에 따라 달라지므로 부하 테스트로 정합니다.

### 6) 온디맨드 vs 프로비저닝, 할인 vs 용량 확보 {#on-demand-vs-provisioned}

| 영역 | 온디맨드 | 프로비저닝 | 고르는 기준 |
|---|---|---|---|
| SageMaker 추론 | 서버리스 추론 — 컴퓨트를 자동 시작·확장하고 유휴 시 0 | 실시간 엔드포인트 — 인스턴스를 상시 확보 | 간헐·예측 불가·콜드 스타트 허용 → 서버리스. 일관된 지연이 필요한 지속 트래픽 → 실시간 |
| 서버리스 안에서 | 순수 온디맨드(콜드 스타트 가능) | **프로비저닝된 동시성** — 지정한 수만큼 미리 초기화해 ms 내 응답. PC 사용량(메모리·기간·동시성)에 별도 과금 | 예측 가능한 버스트 + 지연 예측성 |
| EC2 구매 옵션 | **On-Demand**(약정·선결제 없이 종량) · **Spot**(여분 용량, **2분 전 통지로 중단** 가능) | Savings Plans · Reserved Instances | 중단 허용·유연 → Spot, 지속·예측 가능 → 약정 |
| SageMaker 약정 | 온디맨드 요금 | **SageMaker AI Savings Plans** — 시간당 일정 사용량을 1년 또는 3년 약정, **최대 64% 절감**. 적용 대상으로 노트북·Processing·Data Wrangler·훈련·**실시간 추론·배치 변환**의 ML 인스턴스 사용이 나열되며 인스턴스 패밀리·크기·리전과 무관하게 자동 적용 | 여러 SageMaker 서비스에 걸쳐 일정한 사용량이 있을 때 |
| 용량 예약 | — | **SageMaker 훈련 계획**(training plans) — 훈련 작업·HyperPod·추론 엔드포인트·Studio 앱용 컴퓨트 용량을 예약. **추론 엔드포인트는 예약 기간에만 동작**한다 | 고수요 GPU 확보가 목적일 때(할인이 목적이 아니다) |

⚠️ **가격 할인 ≠ 용량 확보.** EC2 의사결정 가이드는 구매 옵션(On-Demand·Savings Plans·Reserved Instances·Spot)은 **청구 계산 방식**이고 용량 예약은 **용량을 잡아 두는 방식**이어서 서로 독립적이며 겹쳐 쓴다고 설명합니다. Spot은 Savings Plans 대상이 아닙니다.

> Savings Plans 적용 대상 목록에 **서버리스·비동기 추론은 명시돼 있지 않습니다.** 적용 여부를 단정하는 문장을 문서에서 찾을 수 없으므로 이 관계를 판단 근거로 쓰지 않습니다.

**SageMaker의 Spot** — SageMaker 문서가 설명하는 Spot 활용은 **관리형 스팟 훈련**입니다(최대 90% 절감, `EnableManagedSpotTraining` + `MaxWaitTimeInSeconds`, 체크포인트 권장). 상세는 [`mla-t2-2` 4)](mla-t2-2.md#speedup)가 정본입니다. **호스팅 엔드포인트 인스턴스에 Spot을 쓰는 공식 설명은 확인되지 않았으므로** 그 조합을 정답으로 고르지 않습니다.

### 7) 비용 효율·확장성·유지관리 모범 사례 {#cost-best-practices}

**공식 문서가 권하는 것**

1. 작업에 맞는 추론 옵션 고르기 → [`mla-t3-1` 5)](mla-t3-1.md#option-decision)
2. 오토 스케일링으로 **피크 기준 상시 프로비저닝을 피함**. 비동기는 고정 인스턴스 수로 처리율을 맞추거나 0대까지 줄여 추가 절감
3. SageMaker AI Savings Plans
4. **Inference Recommender로 인스턴스 비교**(SageMaker 추론은 70종 이상 인스턴스 유형·크기 제공, Inferentia·Graviton 포함)
5. **모델 최적화(SageMaker Neo)**로 더 작은 인스턴스 사용
6. 여러 엔드포인트를 멀티 모델·멀티 컨테이너 엔드포인트로 **통합**
7. 프로덕션 엔드포인트는 인스턴스를 여러 대, VPC는 서로 다른 AZ의 서브넷 2개 이상
8. ML Lens MLREL05-BP01: 자동 스케일링 허용, 정책 지표(CPU·메모리·요청 수/지연)와 최소·최대 인스턴스 설정, 모니터링, 서버리스, Inference Recommender, 부하 테스트

**가이드 SK1의 예시 구절을 어떻게 읽는가** — SK1은 "SageMaker AI 엔드포인트에서 오토 스케일링, Amazon EC2 인스턴스 사용, 엔드포인트 뒤에서 Lambda 사용으로 스팟 인스턴스 동적 추가"를 예시로 듭니다. ⚠️ **이 구절들을 하나의 아키텍처로 묶어 설명하는 단일 공식 문서는 확인되지 않았습니다.** 영문 원문이 세 항목을 쉼표로 나열한 것이라 **개별 패턴으로** 읽는 것이 맞습니다.

| 예시 구절 | 공식 문서에서 확인되는 내용 |
|---|---|
| 엔드포인트 오토 스케일링 | 1)~4). ML Lens MLREL05-BP01 |
| 스팟 인스턴스 동적 추가 | SageMaker에서는 **관리형 스팟 훈련**. EC2 Spot은 2분 전 통지로 중단될 수 있어 유연·중단 허용 워크로드에 적합. 자체 호스팅(EKS)에서는 Spot과 On-Demand를 한 풀에 섞는 방식을 안내 |
| Amazon EC2 인스턴스 사용 | Generative AI Lens: 사용자 지정 ML 인프라에는 **EC2 Auto Scaling**으로 수요에 맞춰 자원을 배분 |
| 엔드포인트 뒤에서 Lambda 사용 | API Gateway → Lambda → SageMaker 엔드포인트 호출 구조(블로그). Lambda 컨테이너 이미지로 작은 모델 추론도 가능 |

⚠️ 옛 비용 최적화 글의 **Elastic Inference 권고는 더 이상 유효하지 않습니다**(→ [`mla-t3-1` 15)](mla-t3-1.md#deploy-service-status)).

### 8) IaC 선택 — CloudFormation vs CDK {#iac-choice}

| 비교 축 | AWS CloudFormation | AWS CDK |
|---|---|---|
| 작성 방식 | JSON/YAML 텍스트, **선언형** — 원하는 상태를 선언 | TypeScript·JavaScript·Python·Java·C#·Go 같은 범용 언어, **명령형** 로직(조건·반복) 사용 가능 |
| 배포 | 템플릿을 CloudFormation이 프로비저닝 | 코드를 **합성**해 CloudFormation 템플릿을 만들고 CloudFormation으로 배포 — 광범위한 리소스 지원·견고한 배포 프로세스라는 CFN의 이점을 유지 |
| 추상화 | 리소스 1:1 | **L1**(1:1, `Cfn*`) / **L2**(의도 기반, 안전한 기본값) / **L3**(패턴) |
| 신규 리소스 | CloudFormation에 리소스가 있어야 CDK L1이 생성된다 | L1에 새 리소스·속성이 반영되기까지 **최대 1주** 걸릴 수 있다 |
| 선택 기준 | 단순하고 선언적인 인프라 | **복잡한 인프라**는 CDK 고려. 개발 역량이 있는 조직에는 CDK 권장 |
| 절충 | 상태를 선언하는 방식 — 그 상태에 이르는 로직·순서를 코드로 정의하는 것은 CDK 쪽 기능 | 추상화 계층과 언어·툴체인을 알아야 하고, **실험적(alpha) 모듈은 API가 바뀔 수 있다** |

**SageMaker 리소스의 IaC 표현**

- ⚠️ 2024-12-03 개명에도 **CloudFormation 리소스 접두어 `AWS::SageMaker::`는 그대로**입니다(경위는 [`mla-t3-1` 15)](mla-t3-1.md#deploy-service-status)). 템플릿을 고칠 필요가 없습니다.
- 리소스 타입: `AWS::SageMaker::Model` · `EndpointConfig` · `Endpoint` · `InferenceComponent` · `Pipeline` · `Project` · `ModelPackageGroup` · `FeatureGroup` 등.
- **의존 체인 `Model → EndpointConfig → Endpoint`** — 같은 템플릿에서 `Fn::GetAtt`로 연결합니다(예: `Model.ModelName`, `EndpointConfig.EndpointConfigName`).

| 변경 대상 | 갱신 동작 |
|---|---|
| `Endpoint`의 `EndpointConfigName` | **무중단(No interruption)** |
| `EndpointConfig`의 `ProductionVariants` | **교체(Replacement)** |
| `Model`의 `VpcConfig`·`EnableNetworkIsolation` | **교체(Replacement)** |

`EndpointConfig`는 변형을 최대 10개까지 둘 수 있습니다. 오토 스케일링은 `AWS::ApplicationAutoScaling::ScalableTarget`·`ScalingPolicy`로 **별도 선언**합니다.

> ⚠️ 서버리스 문서는 "프로비저닝된 동시성의 오토 스케일링은 CloudFormation에서 현재 지원되지 않는다"고 쓰는데, CloudFormation `ScalableTarget` 레퍼런스는 `sagemaker:variant:DesiredProvisionedConcurrency`를 허용 값으로 나열합니다(문서 간 상충). **이 지원 여부를 정답 근거로 쓰지 않습니다.**

- **CDK의 SageMaker 지원** — `aws_cdk.aws_sagemaker`는 **L1만** 있고 "공식 손으로 작성한 L2가 아직 없다"고 안내합니다. 별도 패키지 `@aws-cdk/aws-sagemaker-alpha`가 L2를 제공하지만 **실험적**이어서 하위 호환 없이 API가 바뀔 수 있습니다. alpha 모듈은 서버리스 변형과 인스턴스 변형을 **한 EndpointConfig에 섞을 수 없습니다.**
- **SageMaker Projects** — 조직이 ML 개발 환경과 MLOps용 CI/CD를 표준화하는 기능입니다. 템플릿은 **S3 버킷에 둔 사용자 지정 템플릿**, AWS Service Catalog 템플릿, SageMaker 제공 템플릿으로 프로비저닝하며 **문서는 Service Catalog보다 S3 보관을 권장**합니다. 템플릿 구성과 CI/CD 연결은 [`mla-t3-3` 10)](mla-t3-3.md#projects-registry)이 정본입니다.
- **배포 방법 선택** — 노코드는 Studio JumpStart, 코드 기반 세밀 제어는 SDK `ModelBuilder`, **대규모·반복 운영은 Boto3·CloudFormation 같은 IaC와 CI/CD 도구**입니다.

### 9) 스택 간 통신 {#cross-stack}

| 방식 | 범위 | 참조 강도·규칙 |
|---|---|---|
| `Outputs` + `Export` → `Fn::ImportValue` | **같은 계정·같은 리전** | **강함** — Export 이름은 계정·리전 내 고유하고, 임포트 중인 출력은 **삭제·변경 불가** |
| `Fn::GetStackOutput` | **계정·리전을 넘어 가능** | **약함** — Export가 필요 없고, 대상이 삭제돼도 소비 스택에 알리지 않으며 참조 무결성을 강제하지 않는다 |
| 중첩 스택(`AWS::CloudFormation::Stack`) | 하나의 부모 아래 **그룹 내부** | 그룹 *내부* 정보 공유용. 그룹 밖의 스택과 공유하려면 Export를 쓴다 |
| CDK 자동 참조 | 같은 환경의 다른 스택 | CDK가 생산 스택에 export, 소비 스택에 `Fn::ImportValue`를 자동 합성(기본 = strong). 강도: Strong / Weak(`Fn::GetStackOutput`) / Both(전환 단계) |

- 전형적 사용: 네트워크 스택이 VPC·보안 그룹·서브넷을 `Export`하고 애플리케이션 스택이 `Fn::ImportValue`로 가져옵니다. 네트워크 스택을 먼저 만들어야 하고, 스택 이름을 export 이름 접두어로 써 출처를 구분합니다. SageMaker에서는 네트워크 스택의 서브넷·보안 그룹 ID를 모델 스택의 `VpcConfig`가 쓰는 구조에 해당합니다.
- `Export` 이름에는 리소스에 의존하는 `Ref`/`GetAtt`를 쓸 수 없고 `Fn::ImportValue` 인수도 마찬가지입니다.
- CDK에서 강한 참조끼리 얽히면 **의존성 교착(deadly embrace)**이 생길 수 있어 CDK가 참조 강도를 제어하게 합니다.
- 같은 스택 안에서는 `Ref`·`Fn::GetAtt`로 충분합니다.

> 🧠 원리: `Export`/`ImportValue`는 CloudFormation이 "누가 무엇을 쓰는지"를 추적하므로 소비자가 남아 있으면 생산 스택의 출력을 지우거나 바꿀 수 없습니다. `GetStackOutput`은 값을 **읽기만** 하므로 자유롭지만 참조 무결성이 없습니다.

### 10) 컨테이너화 개념과 AWS 컨테이너 서비스 {#container-services}

**개념** — 컨테이너는 애플리케이션의 코드·구성·의존성을 하나의 객체로 패키징하는 표준 방식이고, **컨테이너 이미지는 컨테이너를 만드는 읽기 전용(불변) 템플릿**입니다. SageMaker AI는 스크립트 실행·알고리즘 훈련·모델 배포 때 **항상 Docker 컨테이너를 사용**합니다.

| 서비스 | 역할 | 핵심 | 헷갈리는 것 |
|---|---|---|---|
| **Amazon ECR** | 컨테이너 이미지 **레지스트리** | 수명 주기 정책, 이미지 스캔, 교차 리전·계정 복제, pull through cache | 이미지를 **저장**할 뿐 실행하지 않는다 |
| **Amazon ECS** | AWS 관리형 **컨테이너 오케스트레이션** | 용량 옵션: ECS Managed Instances / EC2 인스턴스(직접 관리) / **Fargate**(서버리스) / ECS Anywhere(온프레미스). 서비스 오토 스케일링이 태스크 수를 조정 | Kubernetes가 아닌 AWS 고유 오케스트레이터 |
| **Amazon EKS** | 완전 관리형 **Kubernetes** | 표준 EKS는 컨트롤 플레인을 AWS가 관리, **EKS Auto Mode는 노드(데이터 플레인)까지** 관리 | ECS와 달리 Kubernetes API·도구를 쓴다 |
| **AWS Fargate** | ECS의 **서버리스 컴퓨트 엔진** | 서버 관리·용량 계획 불필요, 종량 과금 | ECS의 EC2 용량 옵션(서버를 직접 관리)과 대비된다 |
| **SageMaker AI** | 컨테이너를 **관리형으로 실행하는 ML 플랫폼** | 이미지는 ECR 등에서 가져온다. 엔드포인트·AAS 오토 스케일링·모델 레지스트리와 통합 | ECS·EKS에 직접 올리는 서빙과 달리 ML 전용 운영 기능을 제공한다 |

배포 대상 자체를 고르는 문제(SageMaker 엔드포인트 vs Kubernetes vs ECS·EKS vs Lambda)는 [`mla-t3-1` 14)](mla-t3-1.md#deploy-target)가 정본입니다.

### 11) 컨테이너 구축·유지 — 훈련 계약과 ECR 운영 {#byoc-ecr}

**컨테이너 선택 사다리**(내장 → 사전 빌드 → 확장 → 어댑트 → 직접 빌드)와 **추론 컨테이너 계약**(8080·`/invocations`·`/ping`)은 [`mla-t3-1` 11)](mla-t3-1.md#container-choice)이 정본입니다. 여기서는 **만들고 유지하는 쪽**을 다룹니다.

**툴킷** — SageMaker Training Toolkit(훈련용)과 SageMaker AI Inference Toolkit(배포용)이 컨테이너를 SageMaker에 맞추는 기능을 구현하며 코드·리소스 위치와 시작 시 실행할 엔트리포인트를 정의합니다. 훈련·추론 이미지를 **하나로 쓸 수도, 둘로 나눌 수도** 있습니다. 둘로 나누면 저장 요구와 비용이 늘 수 있지만 **작은 컨테이너가 더 빨리 시작해 호스팅이 트래픽 증가에 더 빠르게 확장**합니다.

**훈련 컨테이너 계약**

| 항목 | 규칙 |
|---|---|
| 실행 | 기본 `docker run image train` — 이미지 안에서 `train` 스크립트를 찾는다 |
| ENTRYPOINT | exec 형식 권장(SIGTERM·SIGKILL 수신). ⚠️ `tini`는 `train`/`serve` 인자 때문에 사용할 수 없다 |
| 하이퍼파라미터 | `/opt/ml/input/config/hyperparameters.json` |
| 입력 채널 | `/opt/ml/input/data/<channel_name>` (File·FastFile). Pipe 모드는 에폭별 파이프 |
| 분산 정보 | `/opt/ml/input/config/resourceconfig.json` (`current_host`, `hosts`, `network_interface_name`) |
| 모델 출력 | 스크립트가 모델을 `/opt/ml/model/`에 저장한다 |
| 예약 경로 | **`/opt/ml` 이하 전체를 SageMaker 훈련이 예약** — 필요한 데이터를 두지 않는다 |
| 중지 | `StopTrainingJob` = SIGTERM 후 **2분**(`docker stop -t 120`) 뒤 SIGKILL |

모델 아티팩트가 있는 S3 버킷은 만들려는 모델과 **같은 리전**이어야 합니다. 서버리스 추론에서 BYOC는 이미지 10 GB 이하, 컨테이너당 워커 1개·모델 1벌 권장이고 프라이빗 Docker 레지스트리를 쓸 수 없습니다.

**ECR에 올려 SageMaker에서 쓰는 절차** — ① 리포지토리 생성 ② `aws ecr get-login-password`로 Docker 로그인 ③ `docker build` → `docker tag`(레지스트리 URI) → `docker push` ④ 푸시 후에는 SageMaker 환경 어디서나 **ECR 이미지 URI**로 호출. 모델·엔드포인트 배포 전에 ECR 이미지 URI·모델 아티팩트의 S3 경로·실행 역할을 준비합니다.

**ECR 이미지 유지**

| 기능 | 내용 |
|---|---|
| **스캔 — 기본(Basic)** | CVE 데이터베이스로 **OS 취약점만**, 수동 또는 푸시 시 스캔 |
| **스캔 — 강화(Enhanced)** | **Amazon Inspector 연동**으로 OS + 프로그래밍 언어 패키지, 푸시 시·**지속 스캔**, 새 취약점은 EventBridge 이벤트로 통지 |
| **수명 주기 정책** | 하나 이상의 규칙이 만료시킬 이미지를 결정한다. 적용 전에 **미리보기(preview)**로 만료 대상을 확인하고, 규칙 **우선순위 숫자가 낮을수록 우선**이며, 조건을 충족한 이미지는 **24시간 이내** 만료된다 |

컨테이너 파일 변경이 파이프라인을 일으켜 이미지를 빌드·ECR에 푸시하는 SageMaker Projects 템플릿도 있습니다(→ [`mla-t3-3` 10)](mla-t3-3.md#projects-registry)).

### 12) VPC 안의 SageMaker 엔드포인트 {#vpc-endpoint}

| 요구 | 구성 | 핵심 제약 |
|---|---|---|
| 엔드포인트 컨테이너를 내 VPC에 두고 VPC 리소스에 접근 | `CreateModel`의 **`VpcConfig`**(`Subnets`, `SecurityGroupIds`) — SageMaker가 ENI를 만들어 모델 컨테이너에 연결 | ⚠️ **서로 다른 AZ의 서브넷 2개 이상**(호스팅 인스턴스가 1대여도). API 한도: 서브넷 1~16개, 보안 그룹 1~5개. 사용자 정의 IAM 정책에는 `ec2:CreateNetworkInterface` 등 ENI 권한이 필요 |
| VPC 안 컨테이너가 S3의 모델·데이터에 접근 | **S3 VPC 엔드포인트(게이트웨이)** + 라우팅 테이블 | 인터넷이 막힌 VPC에서 이 엔드포인트가 없으면 S3 버킷에 연결할 수 없다. 엔드포인트 정책으로 접근을 제한할 수 있다 |
| 컨테이너가 다른 AWS 서비스·외부에 접근 | 인터페이스 엔드포인트를 지원하는 서비스는 **인터페이스 VPC 엔드포인트**, 미지원 서비스·외부 리소스는 **NAT 게이트웨이** + 보안 그룹 아웃바운드 허용 | |
| 클라이언트가 인터넷 없이 SageMaker API·Runtime 호출 | **인터페이스 VPC 엔드포인트(AWS PrivateLink)** — SageMaker API용, SageMaker Runtime용 | 프라이빗 DNS를 켜면 기본 호스트명이 VPC 엔드포인트로 해석된다. **Runtime 엔드포인트는 클라이언트의 AZ에서 활성화돼야** DNS 해석이 정상이다 |
| 컨테이너가 어떤 네트워크 호출도 못 하게 | **`EnableNetworkIsolation=true`**(`CreateModel`) → 인바운드·아웃바운드 호출 불가(S3 포함), AWS 자격 증명 미제공 | **S3 다운로드·업로드는 SageMaker가 실행 역할로 컨테이너와 별도로 처리**한다. VPC와 함께 쓰면 이 전송이 VPC 서브넷을 경유한다. AWS Marketplace 리소스를 쓰는 모델·훈련에는 필수 |
| 서버리스 엔드포인트에 VPC | **불가** — VPC 구성·네트워크 격리가 제외 기능 | → [`mla-t3-1` 2)](mla-t3-1.md#serverless-detail) |

- VPC를 구성하지 않으면 훈련·추론 컨테이너는 **기본적으로 인터넷에 접근하고 VPC 내부 리소스에는 접근하지 못합니다.**
- 클라이언트가 VPC 밖(온프레미스)이면 Site-to-Site VPN 또는 Direct Connect로 VPC에 연결한 뒤 PrivateLink를 씁니다.
- Studio에서 모델과 엔드포인트를 함께 배포하려면 IAM 역할·VPC(서브넷·보안 그룹)·네트워크 격리 설정이 **같아야** 합니다.
- ⚠️ 네트워크 격리를 켜면 Chainer·SageMaker 강화 학습 관리형 컨테이너는 S3 접근이 필요해 **지원되지 않습니다.**

> 🧠 원리: 네트워크 격리는 **컨테이너의** 네트워크를 끊을 뿐 SageMaker 서비스의 데이터 이동까지 끊지 않습니다 — 모델 다운로드·결과 업로드는 컨테이너 **밖에서** 실행 역할로 수행됩니다. `VpcConfig`는 반대로 컨테이너에 VPC 안의 네트워크 인터페이스를 **줘서** VPC 리소스와 통신하게 하는 설정입니다. 하나는 빼는 설정, 하나는 주는 설정입니다.

### 13) SDK로 배포·호스팅 {#sdk-deploy}

**배포 흐름(API 수준)**

1. **`CreateModel`** — 컨테이너 이미지 + `ModelDataUrl` + 실행 역할
2. **`CreateEndpointConfig`** — 프로덕션 변형에 모델·인스턴스 유형·초기 인스턴스 수를 할당
3. **`CreateEndpoint`** — 구성을 받아 리소스를 프로비저닝하고 모델을 배포

추론 컴포넌트 방식은 ③ 이후 `CreateInferenceComponent`로 모델을 올리고 CPU·메모리 같은 자원을 할당합니다. SageMaker Python SDK의 **`.deploy()`는 엔드포인트 구성을 대신 만들어 줍니다.** 배포 수단은 Studio(대화형)·SageMaker Python SDK·Boto3·AWS CLI입니다.

**SDK 클래스 대응** ⚠️ 메이저 버전에 따라 이름이 다릅니다.

| 단계 | SDK v2(레거시) | SDK v3(현재 문서 기준) |
|---|---|---|
| 훈련 | `Estimator` 및 프레임워크 서브클래스 `.fit()` | `ModelTrainer` 단일 클래스 `.train()` |
| 모델·배포 | `Model` / `Estimator.deploy()` → `Predictor` | `ModelBuilder` → `.deploy()` → `Endpoint` |
| 호출 | `Predictor.predict()` | `endpoint.invoke(body=..., content_type=...)` |

현재 개발자 가이드는 **v3 기준**으로 `ModelBuilder`를 소개하고, 공식 GitHub README는 "`Estimator`·`Model`·`Predictor` 및 모든 하위 클래스는 V3에서 지원되지 않는다"고 하며 v2를 쓰려면 `pip install sagemaker==2.*`를 안내합니다. ⚠️ **시험 가이드(v1.0)는 SDK 버전을 명시하지 않으므로** 어느 쪽이 출제된다고 단정하지 않고 **둘 다 알아 둡니다.** 문항 판단은 API 흐름(`CreateModel → CreateEndpointConfig → CreateEndpoint`)과 서비스 선택 중심으로 합니다.

`ModelBuilder`는 모델 아티팩트나 추론 코드를 받아 **의존성 수집·직렬화·패키징을 자동으로** 처리합니다. 추론 컴포넌트 기반 엔드포인트는 엔드포인트 유형을 `EndpointType.INFERENCE_COMPONENT_BASED`로 지정합니다.

---

## ✍️ 시험 포인트

- **"시간 기준"이면 예약, "수요 기준"이면 대상 추적입니다.** 둘은 함께 쓸 수 있고, 예약이 최소·최대 경계를 옮기면 그 안에서 정책이 움직입니다.
- **0대에서 깨우려면 단계 스케일링이 필수**입니다. 대상 추적만으로는 활성 인스턴스가 0인 상태를 벗어나지 못합니다(추론 컴포넌트는 `NoCapacityInvocationFailures`, 비동기는 `HasBacklogWithoutCapacity` 경보).
- **지표 함정 세 개**: ① `ModelLatency`는 사전 정의 지표가 아닙니다 ② 인스턴스당 호출 수는 **비동기에서 발행되지 않습니다** ③ `CPUUtilization`은 코어 합산이라 4 vCPU에서 0~400%입니다.
- 부하 테스트 공식은 **`(MAX_RPS × SAFETY_FACTOR) × 60`**, `SAFETY_FACTOR`는 **0.5부터** 시작합니다.
- **쿨다운 조정 방향**을 반대로 외우지 않습니다. 너무 잦게 흔들리면 **늘리고**, 너무 느리면 줄입니다. 기본값은 양방향 300초입니다.
- **할인과 용량은 다른 차원**입니다. Savings Plans는 청구 계산 방식이고 용량을 잡아 주지 않습니다. 용량 확보는 프로비저닝된 동시성·EC2 용량 예약·SageMaker 훈련 계획 쪽입니다.
- **CDK는 CloudFormation을 대체하지 않습니다.** 코드를 합성해 CFN 템플릿을 만들고 CFN이 배포합니다. SageMaker는 `aws_sagemaker`에 **L1만** 있고 L2는 alpha 패키지입니다.
- **스택 간 전달은 범위로 갈립니다.** 같은 계정·리전 → `Export`+`ImportValue`(강한 참조, 소비자가 있으면 삭제 불가), 계정·리전을 넘으면 → `Fn::GetStackOutput`, 한 부모 아래 그룹 내부 → 중첩 스택.
- **방향을 외웁니다**: `VpcConfig` = 주는 설정, `EnableNetworkIsolation` = 끊는 설정. 격리 상태에서도 **모델 로드는 됩니다**(SageMaker가 실행 역할로 수행).
- VPC 서브넷은 **서로 다른 AZ에 2개 이상** — 인스턴스가 1대여도 그렇습니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 대상 추적만 걸어 두고 인스턴스가 0대에서 올라오기를 기다린다 | 활성 인스턴스 0대에서 scale-out 하려면 **단계 스케일링 정책**이 필요하다. 문서가 "must use step scaling"이라고 명시한다 |
| 일반 실시간 변형의 최소 용량을 0으로 두려 한다 | 일반 변형의 최소는 **1 이상**이다. 트래픽이 0이어도 최소 인스턴스 수가 유지된다. 0대는 추론 컴포넌트·비동기·서버리스의 이야기다 |
| 비동기 엔드포인트에 인스턴스당 호출 수 지표를 쓴다 | 이 지표는 **비동기에서 발행되지 않는다.** 비동기는 인스턴스당 대략적인 백로그 크기를 쓴다 |
| `ModelLatency`를 대상 추적의 사전 정의 지표로 고른다 | 사전 정의 목록에 없다. 지연은 **부하 테스트의 피크 RPS 판정**과 알람·모니터링 지표다 |
| `CPUUtilization` 목표를 0~100% 척도로 잡는다 | 코어별 사용률의 **합**이라 4 vCPU면 0~400%다. 목표값을 이 척도에 맞춘다 |
| 인스턴스가 너무 자주 늘고 줄어 쿨다운을 줄인다 | 방향이 반대다. 너무 빨리 흔들리면 쿨다운을 **늘린다.** 줄이는 것은 반응이 느릴 때다 |
| 오토 스케일링이 걸린 변형의 인스턴스 유형을 그대로 `UpdateEndpoint` 한다 | 실패한다. 정책 삭제 → `DeregisterScalableTarget` → 업데이트 → 재등록 순서를 지킨다(**모델만** 바꾸는 업데이트는 예외로 허용된다) |
| Savings Plans를 사면 용량이 확보된다고 본다 | 구매 옵션은 **청구 계산 방식**이고 용량 예약은 별개 차원이다. 둘은 겹쳐 쓴다. Spot은 Savings Plans 대상도 아니다 |
| 호스팅 엔드포인트 인스턴스에 Spot을 붙이는 보기를 고른다 | SageMaker 문서가 설명하는 Spot은 **관리형 스팟 훈련**이다. 호스팅 엔드포인트에서 Spot을 쓰는 공식 설명은 확인되지 않았다 |
| CDK를 쓰면 CloudFormation을 쓰지 않는다고 본다 | CDK는 코드를 **합성해 CFN 템플릿을 만들고** CFN으로 배포한다. `aws_sagemaker`는 L1만이고 L2는 실험적 alpha 패키지다 |
| `Export`한 값을 다른 리전·계정에서 `ImportValue` 한다 | Export 범위는 **같은 계정·같은 리전**이다. 경계를 넘으려면 `Fn::GetStackOutput`(약한 참조)을 쓴다 |
| 중첩 스택을 독립 스택 간 공유 수단으로 쓴다 | 중첩 스택은 **그룹 내부** 공유용이다. 그룹 밖과 공유하려면 Export를 쓴다 |
| 네트워크 격리를 켜면 S3의 모델도 못 읽는다고 본다 | 모델 다운로드·결과 업로드는 **SageMaker가 컨테이너 밖에서 실행 역할로** 수행한다. 끊기는 것은 컨테이너 자신의 네트워크 호출이다 |
| NAT 게이트웨이를 두면 격리가 유지된다고 본다 | NAT는 **외부 연결을 허용하는** 수단이라 격리와 양립하지 않는다 |
| VPC 서브넷을 하나만 지정한다 | 호스팅 인스턴스가 1대여도 **서로 다른 AZ의 서브넷 2개 이상**을 요구한다 |
| ECR을 컨테이너 실행 서비스로 본다 | ECR은 이미지 **레지스트리**다. 실행은 ECS·EKS·SageMaker 같은 서비스가 한다 |
| `/opt/ml` 아래에 필요한 데이터를 둔다 | **`/opt/ml` 이하 전체가 SageMaker 훈련의 예약 경로**다. 여기에 둔 데이터는 보장되지 않는다 |

---

## 🧪 자가 점검

1. 엔드포인트 오토 스케일링을 CLI로 구성할 때 정책을 만들기 전에 반드시 해야 하는 일은? 콘솔로 하면 무엇이 달라지는가? *(→ 1))*
2. 매주 월요일 오전에만 트래픽이 세 배가 된다. 어떤 정책을 쓰고, 동시에 쓸 수 있는 다른 정책은 무엇인가? SageMaker에서 그 정책의 관리 수단 제약은? *(→ 2))*
3. 인스턴스 1대에서 초당 80건까지 처리하다 지연이 늘기 시작했다. 목표값을 계산하고 안전 계수의 출발값을 말하라. *(→ 3))*
4. 비동기 엔드포인트에 인스턴스당 호출 수로 대상 추적을 걸었는데 아무 일도 일어나지 않는다. 왜이고 무엇으로 바꾸는가? *(→ 3))*
5. 추론 컴포넌트 기반 엔드포인트를 0대까지 줄였다. 다시 깨우는 장치 두 가지(정책 유형·지표)와 그동안 호출에 생기는 일은? *(→ 4))*
6. 1년간 꾸준한 실시간 추론 사용량이 예상되고 GPU 수급도 불안하다. 비용과 용량을 각각 무엇으로 다루는가? *(→ 6))*
7. 네트워크 팀이 VPC 스택을, ML 팀이 엔드포인트 스택을 따로 관리한다. 같은 리전이라면 어떤 방식이고, 그 방식의 제약 하나는? *(→ 9))*
8. 훈련 스크립트가 하이퍼파라미터와 입력 데이터를 읽을 경로, 모델을 저장할 경로는? 그리고 그 상위 디렉터리에 데이터를 둬도 되는가? *(→ 11))*
9. 컨테이너가 인터넷과 VPC 어디에도 나가지 못해야 하지만 S3의 모델은 로드돼야 한다. 어떤 설정이고 모델 로드는 누가 하는가? *(→ 12))*
10. 엔드포인트 구성의 `ProductionVariants`를 CloudFormation에서 바꾸면 리소스에 무슨 일이 생기는가? 엔드포인트의 구성 이름만 바꿀 때와 비교하라. *(→ 8))*

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가된 항목**이며 C01 시험 범위가 아닙니다.

- **C02 대응 Task**: 3.2 「기존 아키텍처 및 요구 사항에 따라 ML 및 AI 워크로드를 위한 리소스를 프로비저닝하고 구성합니다」
- **추가된 항목 4개**
  - `3.2.6` **모델 서빙 인프라의 성능**을 최적화합니다.
  - `3.2.7` **FM 추론 비용** 최적화 전략을 적용합니다.
  - `3.2.8` 사용 사례에 맞게 **처리량과 지연 시간**을 최적화합니다.
  - `3.2.9` 생성형 AI 애플리케이션을 위한 **Amazon Bedrock 리소스**(예: 프롬프트 관리, 지식 기반, 가드레일)를 프로비저닝하고 구성합니다.
- **삭제된 항목**: 이 Task에는 없음
- 읽는 법: C01의 3.2가 "엔드포인트 오토 스케일링 + IaC + 컨테이너·VPC 구성"이었다면, C02는 거기에 **FM 서빙 성능·비용 최적화와 Bedrock 리소스 프로비저닝**을 더합니다. 1)~4)의 스케일링 구조와 8)~9)의 IaC는 그대로 쓰이고, 그 위에 Bedrock 쪽 구성 대상이 올라옵니다.

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- 오토 스케일링: [엔드포인트 오토 스케일링](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling.html) · [정책 옵션](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-policy.html) · [사전 요구 사항](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-prerequisites.html) · [고해상도 지표](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-add-code-define.html) · [0 인스턴스 스케일](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html) · [부하 테스트](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-scaling-loadtest.html) · [비동기 오토 스케일링](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference-autoscale.html) · [서버리스 PC 오토 스케일링](https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints-autoscale.html)
- Application Auto Scaling: [What is AAS](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html) · [대상 추적 정책](https://docs.aws.amazon.com/autoscaling/application/userguide/target-tracking-scaling-policy-overview.html) · [단계 정책](https://docs.aws.amazon.com/autoscaling/application/userguide/step-scaling-policy-overview.html) · [예약 스케일링](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-scheduled-scaling.html) · [SageMaker 통합](https://docs.aws.amazon.com/autoscaling/application/userguide/services-that-can-integrate-sagemaker.html)
- 비용·용량: [Optimize costs for inference](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html) · [관리형 스팟 훈련](https://docs.aws.amazon.com/sagemaker/latest/dg/model-managed-spot-training.html) · [EC2 구매 옵션 의사결정 가이드](https://docs.aws.amazon.com/decision-guides/latest/decision-guides/ec2-purchasing-options-aws-how-to-choose.html) · [EC2 Spot 인스턴스](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html) · [SageMaker 훈련 계획](https://docs.aws.amazon.com/sagemaker/latest/dg/reserve-capacity-with-training-plans.html) · [MLREL05-BP01](https://docs.aws.amazon.com/wellarchitected/latest/machine-learning-lens/mlrel05-bp01.html)
- IaC: [CDK 시작하기](https://docs.aws.amazon.com/cdk/v2/guide/home.html) · [CDK 구성 요소(L1·L2·L3)](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html) · [CDK 스택 간 참조](https://docs.aws.amazon.com/cdk/v2/guide/resources.html) · [스택 간 참조 워크스루](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-crossstackref.html) · [SageMaker CloudFormation 리소스](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/AWS_SageMaker.html) · [AWS::SageMaker::Endpoint](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-sagemaker-endpoint.html) · [AWS::SageMaker::EndpointConfig](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-sagemaker-endpointconfig.html) · [AWS::ApplicationAutoScaling::ScalableTarget](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-applicationautoscaling-scalabletarget.html)
- 컨테이너: [Docker 컨테이너](https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers.html) · [자체 컨테이너 어댑트](https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-training-algo-dockerfile.html) · [훈련 컨테이너 환경 변수·경로](https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-training-algo-running-container.html) · [추론 코드 요구 사항](https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-inference-code.html) · [What is Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html) · [ECR 이미지 스캔](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html) · [ECR 수명 주기 정책](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html) · [What is Amazon ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) · [What is Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- VPC·배포: [호스팅 엔드포인트와 VPC](https://docs.aws.amazon.com/sagemaker/latest/dg/host-vpc.html) · [인터페이스 VPC 엔드포인트](https://docs.aws.amazon.com/sagemaker/latest/dg/interface-vpc-endpoint.html) · [네트워크 격리](https://docs.aws.amazon.com/sagemaker/latest/dg/mkt-algo-model-internet-free.html) · [실시간 추론 배포](https://docs.aws.amazon.com/sagemaker/latest/dg/realtime-endpoints-deploy-models.html) · [SageMaker Projects](https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-projects-whatis.html) · [SageMaker Python SDK](https://sagemaker.readthedocs.io/en/stable/)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/3-2.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
