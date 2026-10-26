---
examGuideTaskId: mla-t3-1
certCode: MLA-C01
domain: 3
domainName: ML 워크플로의 배포 및 오케스트레이션
domainWeightPct: 22
title: 배포 인프라 선택 (추론 옵션 4종·다중 모델·가드레일·컴퓨팅·컨테이너·엣지)
coversTasks:
  - "3.1"
sources:
  - title: Deploy models for inference — 추론 옵션 비교 (Amazon SageMaker AI 공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-model-options.html
  - title: Serverless Inference (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html
  - title: Asynchronous inference (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference.html
  - title: Batch transform (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/batch-transform.html
  - title: Deployment guardrails (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails.html
  - title: Multi-model endpoints (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoints.html
  - title: Inference Recommender (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender.html
  - title: Use Docker containers to build models (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers.html
  - title: SageMaker Neo — Optimize model performance (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/neo.html
  - title: Optimize costs for inference (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html
  - title: MLA-C01 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html
lastVerified: 2026-10-17
---

# 배포 인프라 선택 (추론 옵션 4종·다중 모델·가드레일·컴퓨팅·컨테이너·엣지)

> **커버하는 공식 Task** — MLA-C01 · 도메인 3 「ML 워크플로의 배포 및 오케스트레이션」(22%) · **Task 3.1 기존 아키텍처 및 요구 사항에 따라 배포 인프라를 선택합니다** (`mla-t3-1`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 도메인 2가 "쓸 만한 모델을 어떻게 만드는가"였다면, 3.1은 **"그 모델을 어디에, 어떤 모양으로 올리는가"** — 트래픽·페이로드·지연·비용이라는 네 개의 숫자가 선택을 거의 다 정해 줍니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 실시간·서버리스·비동기·배치 변환 네 옵션을 **페이로드·처리 시간·0 스케일·GPU·과금 단위**로 가른다
- [ ] 서버리스 추론의 메모리·동시성 한도와 **"쓸 수 없는 기능" 목록**을 보고 배제 판단을 한다
- [ ] 비동기 추론이 왜 큰 입력과 긴 처리를 다룰 수 있는지 호출 응답의 내용으로 설명한다
- [ ] 배치 변환의 `SplitType`·`BatchStrategy`·`MaxPayloadInMB` 관계와 **100 MB 곱 제한**을 안다
- [ ] 트래픽·페이로드·지연·비용 단서를 네 옵션에 매핑하고, 성능·비용·지연의 절충을 옵션별로 설명한다
- [ ] 같은 엔드포인트에 여러 모델을 얹는 네 방식(MME·멀티 컨테이너·직렬 파이프라인·추론 컴포넌트)을 프레임워크·콜드 스타트·자원 할당으로 구분한다
- [ ] Model Registry의 승인 상태가 배포·롤백에서 하는 역할을 안다
- [ ] 배포 가드레일의 네 가지 트래픽 이동 방식과 **자동 롤백이 CloudWatch 경보에 의존한다**는 전제를 안다
- [ ] 요구사항(CPU·GPU·Inferentia·Graviton·대역폭)에서 인스턴스 계열을 고르고, 신규 고객이 쓸 수 없는 가속기를 배제한다
- [ ] Inference Recommender의 Default·Advanced 차이와 **Compute Optimizer와의 역할 구분**을 말한다
- [ ] 사전 빌드 → 확장 → BYOC 순서로 컨테이너를 고르고 추론 컨테이너 계약(8080·`/invocations`·`/ping`)을 안다
- [ ] 엣지 배포에서 Neo의 역할과 Edge Manager 중단·Greengrass 범위 밖임을 안다
- [ ] 배포 오케스트레이터(Pipelines·Step Functions·MWAA)와 배포 대상(엔드포인트·EKS·ECS·Lambda)을 각각의 단서로 고른다
- [ ] 보기에 섞이는 **지금 고를 수 없는 배포 수단**(Elastic Inference·Edge Manager·Greengrass v1·원 버전 K8s Operators)을 배제한다

---

## 🎯 왜 중요한가

3.1은 "배포"를 묻지만 실제로 채점하는 것은 **요구사항 읽기**입니다. 네 가지 추론 옵션은 기능이 겹치고, 시나리오는 늘 그 겹치는 구간에 놓입니다. "유휴 시간에 비용이 들면 안 된다"는 조건만 보면 서버리스와 비동기가 둘 다 맞고, 거기에 "입력이 500 MB"나 "GPU가 필요하다"가 붙는 순간 하나만 남습니다.

그래서 이 Task의 문항은 **한도(limit)로 갈립니다.** 4 MB·60초·GPU 불가 — 서버리스를 배제하는 세 문장입니다. 1 GB·1시간 — 비동기를 가리키는 두 숫자입니다. 영속 엔드포인트가 필요 없다 — 배치 변환입니다. 한도를 외우라는 뜻이 아니라, **보기에서 한도를 넘는 선택지를 먼저 지우는 훈련**이 필요하다는 뜻입니다.

두 번째 축은 **운영 부담의 위치**입니다. 같은 카나리 배포를 SageMaker 가드레일로 선언만 할 수도 있고, EKS에서 직접 만들 수도 있습니다. 시나리오가 "오케스트레이션·모니터링·롤백 메커니즘을 직접 만들고 싶지 않다"고 말하면 답은 관리형 쪽입니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **엔드포인트 / 엔드포인트 구성 / 모델** | 배포의 세 엔티티. 모델(컨테이너 + 아티팩트) → 엔드포인트 구성(프로덕션 변형: 인스턴스 유형·수) → 엔드포인트(실제로 떠 있는 것) |
| **프로덕션 변형(production variant)** | 엔드포인트 구성 안에서 모델 하나 + 인스턴스 유형·수를 묶은 단위. A/B 테스트의 트래픽 분배 단위이기도 하다 |
| **콜드 스타트** | 컴퓨팅 자원이나 모델이 준비되지 않은 상태에서 들어온 첫 요청이 기다리는 시간 |
| **0 스케일(scale to zero)** | 요청이 없을 때 인스턴스를 0대까지 줄여 유휴 비용을 없애는 것. 어떤 옵션이 되고 안 되는지가 핵심 쟁점이다 |
| **베이킹 기간(baking period)** | 새 플릿으로 트래픽을 옮긴 뒤 경보를 감시하며 기다리는 구간. 이 동안 이상이 생기면 구 플릿으로 되돌린다 |
| **추론 컴포넌트(inference component)** | 모델 하나 + 그 모델이 쓸 CPU·가속기·메모리 + 복사본 수를 묶은 호스팅 객체 |
| **BYOC** | Bring Your Own Container. 사전 빌드 이미지가 없을 때 직접 만든 컨테이너를 ECR에 올려 쓰는 방식 |

---

## 📖 핵심 개념

### 1) 추론 옵션 4종 — 한도가 선택을 정한다 {#inference-options}

SageMaker AI는 모델을 올리는 방식을 네 가지로 나눕니다. 먼저 **배포 경로**(어떤 도구로 올리는가)와 **추론 옵션**(어떤 모양으로 뜨는가)은 다른 축입니다.

**배포 경로 3종**

| 경로 | 대상 | 제약 |
|---|---|---|
| JumpStart (Studio UI) | 로우코드, 인기 오픈소스 모델을 빠르게 | 컨테이너 설정·애플리케이션별 맞춤이 제한된다 |
| `ModelBuilder` (SageMaker Python SDK) | 자체 모델, 인스턴스 유형·네트워크 격리·자원 할당을 세밀하게 | UI 없이 Python 코드를 유지해야 한다 |
| CloudFormation / Boto3 + IaC·CI/CD | 대규모·반복 가능한 프로덕션 운영 | 인프라 관리 역량이 필요하다 |

**추론 옵션 4종 비교**

| 옵션 | 페이로드 | 처리 시간 | 0 스케일 | GPU | 과금 단위 |
|---|---|---|---|---|---|
| **실시간**(Real-time) | 25 MB | 일반 60초, 스트리밍 응답 8분 | 일반 변형은 불가 | 가능 | 인스턴스 사용 시간 |
| **서버리스**(Serverless Inference) | 4 MB | 60초 | 요청 없으면 0 | **불가** | 추론 코드 실행 시간(ms) + 처리 데이터량 |
| **비동기**(Asynchronous inference) | 최대 1 GB | 최대 1시간 | 가능 | 가능 | 인스턴스 시간 |
| **배치 변환**(Batch transform) | GB급 데이터셋, 미니배치 상한 100 MB | 일(day) 단위 | 엔드포인트 자체가 없음 | 가능 | 잡 기간의 인스턴스 |

> ⚠️ **문서 간 불일치** — 실시간 페이로드는 개발자 가이드 비교 페이지와 호스팅 FAQ가 **25 MB**인데 `InvokeEndpoint` API 레퍼런스의 `Body` 길이 제약은 **6,291,456 바이트(6 MiB)**, aws.amazon.com FAQ는 6 MB로 적습니다. 비동기 처리 시간도 개발자 가이드는 **최대 1시간**(요청 기본 15분), aws.amazon.com FAQ는 15분으로 적습니다. 어느 쪽이 최신인지 문서에 날짜가 없습니다. **시험 대비로는 개발자 가이드 기준(25 MB·1시간)을 쓰고, 이 수치 자체를 정답 근거로 삼는 문항은 피합니다.**

> 🧠 원리: 실시간은 백엔드 인스턴스가 상시 떠 있는 **영속 엔드포인트**라 지연이 낮고 일정하지만 유휴 시간에도 인스턴스 요금이 듭니다. 서버리스는 요청이 올 때 컴퓨팅을 시작하므로 유휴 요금이 없는 대신 콜드 스타트가 생깁니다(길이는 모델 크기·다운로드·컨테이너 시작 시간에 좌우). 비동기는 페이로드를 S3에 두고 요청을 큐에 넣어 처리한 뒤 결과를 다시 S3에 씁니다. 배치 변환은 S3 객체를 키 기준으로 인스턴스에 매핑해 **잡**으로 처리합니다.

스트리밍 응답은 `InvokeEndpointWithResponseStream`으로 받으며, 실시간의 8분 한도가 이 경우에 해당합니다. LLM 토큰 스트리밍이 시나리오에 나오면 실시간입니다.

### 2) 서버리스 추론 — 유휴 0원의 대가 {#serverless-detail}

| 항목 | 값 |
|---|---|
| 메모리 | 1024–6144 MB, 1 GB 단위(1024·2048·3072·4096·5120·6144). 메모리에 비례해 vCPU가 배정된다 |
| 엔드포인트당 최대 동시성 `MaxConcurrency` | 1–200. 초과 호출은 스로틀링된다 |
| 계정·리전 합산 동시성 | 주요 8개 리전 1000, 그 밖 500 |
| 리전당 서버리스 엔드포인트 수 | 50 |
| 컨테이너 이미지 | 최대 10 GB |
| 호출 한도 | 요청·응답 4 MB, `/invocations` 응답 1분, `/ping` 3분 |
| Provisioned Concurrency(PC) | 지정한 수만큼 웜 상태로 유지해 ms 내 응답. `MaxConcurrency` 이하여야 하고 별도 요금(구성 메모리·프로비저닝 기간·동시성)이 든다 |

**쓸 수 없는 기능** — 이 목록이 배제 판단의 근거입니다: GPU · AWS Marketplace 모델 패키지 · 프라이빗 Docker 레지스트리 · 멀티 모델 엔드포인트 · **VPC 구성** · **네트워크 격리** · 데이터 캡처 · 다중 프로덕션 변형 · Model Monitor · 추론 파이프라인. 롤링 배포와 섀도 테스트도 쓸 수 없습니다.

**변환 방향** — 인스턴스 기반 실시간 엔드포인트를 서버리스로 바꿀 수는 **없습니다**(`ValidationError`). 서버리스 → 실시간은 가능하지만 되돌릴 수 없습니다.

선택 단서: 유휴 구간이 길고 콜드 스타트를 허용하며 CPU 모델이고 4 MB·60초 안에 끝난다 → 서버리스. 버스트 시점이 예측 가능하고 지연이 민감하다 → 서버리스 + PC. 용량 모델과 PC 오토 스케일링은 [`mla-t3-2` 5)·6)](mla-t3-2.md#capacity-models)이 정본입니다.

### 3) 비동기 추론 — 큐와 S3 {#async-detail}

**흐름**

1. `CreateEndpointConfig`에 `AsyncInferenceConfig`를 넣는다(`OutputConfig` 필수, `ClientConfig` 선택). 이 설정이 있으면 그 엔드포인트는 **비동기 호출만** 받는다
2. 요청 페이로드를 S3에 두고 `InvokeEndpointAsync`에 `InputLocation`으로 지정한다(인라인 `Body`는 128,000 바이트 이하이며 `InputLocation`과 상호 배타)
3. SageMaker가 요청을 큐에 넣고, **처리 완료와 무관하게** `InferenceId`와 출력 위치를 HTTP 202로 반환한다
4. 결과는 `S3OutputPath`(실패 응답은 `S3FailurePath`)에 저장되고 SNS 성공·오류 토픽으로 알릴 수 있다

| 항목 | 값·동작 |
|---|---|
| `InvocationTimeoutSeconds` | 요청 처리 한도. 기본 900초, 범위 1–3600초 |
| `RequestTTLSeconds` | 큐 대기 한도. 기본 21,600초(6시간), 범위 60–21,600초 |
| `MaxConcurrentInvocationsPerInstance` | 인스턴스당 동시 호출 수 1–1000. 지정하지 않으면 SageMaker가 고른다 |
| SNS 알림 | `SuccessTopic`·`ErrorTopic`. 추론 응답을 알림에 싣는 것은 **128 KB 이하일 때만** |
| 오토 스케일링 | `ApproximateBacklogSizePerInstance` 기반 목표 추적을 권장하고, `MinCapacity=0`으로 0까지 줄인다 |
| 0에서 되살리기 | 정책이 없으면 큐 길이가 목표를 넘어야 스케일 업한다. 큐에 요청이 생기자마자 깨우려면 `HasBacklogWithoutCapacity` 경보에 단계 스케일링 정책을 붙인다 |
| 가드레일·섀도 | 배포 가드레일은 비동기에도 적용되지만 섀도 테스트는 쓸 수 없다 |

> 🧠 원리: `InvokeEndpointAsync` 응답에는 **추론 결과가 없고 결과 위치만** 있습니다. 그래서 클라이언트가 처리 완료까지 연결을 붙잡지 않고, 동기 호출의 60초 한도를 넘는 긴 처리와 큰 페이로드를 다룰 수 있습니다. 요청이 없으면 인스턴스를 0까지 줄일 수 있는 것도 큐가 요청을 받아 주기 때문입니다.

> ⚠️ 개발자 가이드는 요청 페이로드를 S3에 두라고 요구하는데 API 레퍼런스는 128,000 바이트 이하 인라인 `Body`를 허용합니다(문서 간 불일치). 시험 대비로는 **"대용량은 S3"**까지만 외웁니다.

### 4) 배치 변환 — 데이터셋 단위 잡 {#batch-transform}

용도: 대규모 데이터셋 추론 · **영속 엔드포인트가 필요 없는 추론** · 입력 레코드와 추론을 연계해 해석 · 데이터 전처리.

잡이 시작되면 SageMaker가 인스턴스를 띄워 워크로드를 분산하고 S3 객체를 **키 기준으로** 인스턴스에 매핑합니다. 그래서 **입력 파일이 하나뿐이면 인스턴스를 여러 대 띄워도 한 대만 일합니다.** 출력은 입력 파일명에 `.out`이 붙은 파일이고 입력 순서를 유지합니다.

| 파라미터 | 의미 | 값 |
|---|---|---|
| `SplitType` | `None`/`Line`/`RecordIO`/`TFRecord`. `Line`이면 줄 단위 미니배치, `None`이면 파일 전체를 한 요청으로 | `BatchStrategy`는 `Line`·`RecordIO`·`TFRecord`일 때만 의미가 있다 |
| `BatchStrategy` | `MultiRecord`(한도까지 레코드를 묶음) / `SingleRecord`(요청당 1건) | |
| `MaxPayloadInMB` | 미니배치 페이로드 상한 | 기본 **6 MB**, 최대 **100 MB**. `0`은 HTTP chunked(알고리즘이 지원할 때만, 내장 알고리즘은 미지원) |
| `MaxConcurrentTransforms` | 인스턴스당 동시 요청 수 | `0`/미설정이면 execution-parameters를 쓰고, 미활성이면 1. **`MaxConcurrentTransforms × MaxPayloadInMB ≤ 100 MB`** |
| `AssembleWith` | `Line`이면 출력 레코드를 줄 구분자로 연결(출력 파일 수 = 입력 파일 수) | |
| `TransformResources.InstanceCount` | 변환 인스턴스 수 | 기본 1, 최대 100. 분산 변환은 2 이상 |
| `ModelClientConfig` | `InvocationsTimeoutInSeconds`(기본 600, 1–3600) · `InvocationsMaxRetries`(기본 3, 0–3) | |
| `DataProcessing` | `InputFilter`·`OutputFilter`·`JoinSource`로 추론 입력을 걸러내고 해석용 입력을 결과에 붙인다 | |

제약: CSV 입력에 **줄바꿈이 들어 있는 필드는 지원하지 않습니다.** 변형끼리 비교하려면 변형마다 별도 변환 잡을 만듭니다. 추론 파이프라인 모델도 배치 변환에 쓸 수 있고, SageMaker AI Savings Plans가 적용됩니다.

### 5) 선택 의사결정과 절충 {#option-decision}

| 요구·단서 | 선택 |
|---|---|
| 상시 트래픽, 낮고 일관된 지연, 항상 가용 | 실시간 |
| 간헐적·예측 불가 트래픽, 유휴 많음, 콜드 스타트 허용, 4 MB·60초 이내, CPU | 서버리스 |
| 위와 같은데 버스트 시점이 예측 가능하고 지연이 민감 | 서버리스 + Provisioned Concurrency |
| 큰 입력(최대 1 GB)·긴 처리(최대 1시간), 지연 둔감·비용 민감, 유휴 시 0 | 비동기 |
| 사전에 모인 대규모 데이터를 오프라인 처리, 영속 엔드포인트 불필요 | 배치 변환 |
| **GPU가 필요하고 유휴 구간이 많다** | 서버리스 배제 → 비동기(0 스케일) 또는 실시간 |
| 실시간인데 입력이 한도를 넘는다 | 입력 분할(예: 영상 프레임) 또는 비동기 |
| LLM 토큰 스트리밍 응답 | 실시간(스트리밍 8분) |
| **VPC·네트워크 격리·데이터 캡처·Model Monitor·멀티 모델이 필요하다** | 서버리스 배제 → 실시간 |
| 모델이 많고 개별 트래픽이 적다 | 실시간 + MME / 멀티 컨테이너 / 추론 컴포넌트 |

**절충 관점(SK1)** — 실시간은 낮고 일관된 지연을 얻는 대신 유휴 비용을 냅니다. 서버리스는 유휴 비용이 없고 p99 지연 변동을 감수합니다. 비동기는 지연에 둔감한 대신 고정 인스턴스 수로 비용을 통제하고 0까지 줄일 수 있습니다. 배치는 잡 기간만 인스턴스를 씁니다.

비용 절감 수단은 ① 옵션 선택 ② **SageMaker AI Savings Plans**(최대 64% 절감, 적용 대상에 실시간 추론·배치 변환이 나열됨) ③ Neo 최적화로 더 작은 인스턴스 ④ MME·멀티 컨테이너로 엔드포인트 통합 ⑤ 오토 스케일링입니다. 요금 단가는 동적이라 **구조**(인스턴스 시간 / ms + 데이터량 / 잡 기간)로 판단합니다.

### 6) 한 엔드포인트에 여러 모델 — 네 가지 방식 {#multi-model}

| 방식 | 정의 | 핵심 제약 | 언제 |
|---|---|---|---|
| **멀티 모델 엔드포인트(MME)** | 같은 플릿과 **공유 서빙 컨테이너**에서 S3 프리픽스의 많은 모델을 호출 시 동적으로 로드·캐시·언로드. 생성 시 `Mode: MultiModel`, `ModelDataUrl`은 프리픽스 | **같은 ML 프레임워크**가 전제. 첫 호출 콜드 스타트. CPU 전체 + **단일 GPU** 인스턴스(GPU는 Triton). 서버리스 불가. 직렬 파이프라인에는 MME 컨테이너 1개만. TPS·지연이 엄격한 모델은 전용 엔드포인트 권고 | 수천 개 모델, 호출 빈도 편차가 큼, 호스팅 비용 절감 |
| **멀티 컨테이너 엔드포인트(MCE)** | 서로 다른 프레임워크·모델의 컨테이너를 한 엔드포인트에. `Containers` + `InferenceExecutionConfig.Mode` = `Direct`(독립 호출) 또는 `Serial`(**기본값**, 파이프라인) | **최대 15개.** direct는 `ContainerHostname` 필수. 전부 메모리에 상주해 **콜드 스타트가 없다** | 서로 다른 프레임워크 소수 모델을 항상 로드해 두고 각각 호출 |
| **직렬 추론 파이프라인** | **2–15개** 컨테이너의 선형 시퀀스. 앞 컨테이너 응답이 다음 컨테이너 요청이 된다 | 같은 EC2 인스턴스에 공존해 저지연. 파이프라인 모델은 불변(`UpdateEndpoint`로 교체). 추가 요금 없음. 실시간·배치 변환 모두 가능 | 전처리 → 예측 → 후처리를 한 엔드포인트에 |
| **추론 컴포넌트(IC)** | 모델 하나 + 자원 요구량 + 복사본 수를 가진 호스팅 객체. 가장 유연한 다중 모델 방식 | 자원(CPU 코어·가속기·메모리)을 **모델별로** 지정. 복사본을 0까지 줄일 수 있고, **실시간 엔드포인트가 0 인스턴스까지 줄어드는 것은 IC를 호스팅할 때만** 가능 | 대형·파운데이션 모델 여러 개를 모델별 자원·스케일링으로 |

**호출할 때 대상을 가리키는 파라미터**(`InvokeEndpoint`)

| 대상 | 파라미터 |
|---|---|
| 멀티 모델 엔드포인트 | `TargetModel` |
| 멀티 컨테이너(direct) | `TargetContainerHostname` |
| 추론 컴포넌트 | `InferenceComponentName` |
| 프로덕션 변형(A/B) | `TargetVariant` |

> 🧠 원리: MME는 요청이 오면 해당 모델을 S3에서 인스턴스 스토리지로 받아 컨테이너 메모리에 로드하고, 메모리가 부족하면 쓰지 않는 모델을 메모리에서 내립니다(스토리지 볼륨에는 남고 볼륨이 차면 삭제). 그래서 첫 호출에 콜드 스타트가 있고, **인스턴스 메모리는 모델 캐시 공간, vCPU 수는 동시 호출 한도**로 사이징합니다. MCE는 컨테이너를 모두 띄워 두므로 콜드 스타트가 없지만 15개로 제한됩니다.

Triton 컨테이너는 단일 모델·앙상블·MME 모드를 모두 지원합니다. ⚠️ 컨테이너 헬스체크 실패 시 인스턴스를 자동 교체하는 동작은 **추론 컴포넌트를 쓰는 엔드포인트에는 적용되지 않는다**고 문서가 명시합니다.

### 7) 모델 버전 관리·승인·롤백 {#versioning-rollback}

- **Model Registry** — 모델 그룹이 같은 문제의 모델 버전들을 묶고, 학습할 때마다 새 버전으로 등록합니다. 승인 상태(`PendingManualApproval` → `Approved`/`Rejected`)로 스테이징하고 메타데이터·리니지·CI/CD 자동화를 연결합니다.
- **승인이 배포를 트리거** — `Approved`로 바꾸면 CI/CD 배포가 시작될 수 있고, 파이프라인의 조건 단계가 성능 평가 후 상태를 자동 변경할 수 있습니다.
- **롤백 패턴** — SageMaker 프로젝트 템플릿에서 `Approved` → `Rejected` 전환은 **"가장 최근 `Approved` 버전"을 다시 배포하는** CI/CD를 시작합니다.
- **엔드포인트 갱신은 기본이 블루/그린** — 새 플릿(그린)을 띄우고 트래픽을 옮긴 뒤 구 플릿(블루)을 종료합니다(→ 8).
- **다른 배포 대상의 롤백** — Lambda는 버전 + **가중 별칭**으로 카나리를 만들고 빠르게 되돌립니다. ECS는 롤링 업데이트의 **배포 서킷 브레이커**가 실패 배포를 마지막 `COMPLETED` 배포로 자동 롤백합니다.
- **테스트 환경** — 프로덕션 엔드포인트에 올리기 전에 노트북 인스턴스에서 **로컬 모드**(`instance_type='local'`)로 배포해 검증할 수 있습니다. 서버리스·비동기(0 스케일)는 개발·테스트의 유휴 비용을 줄입니다.

> 승인 상태 전이가 **CI/CD 파이프라인을 어떻게 시작시키는지**(전이 4종 표, EventBridge 이벤트)는 [`mla-t3-3` 10)](mla-t3-3.md#projects-registry)이 정본입니다. 여기서는 배포 모범 사례로서의 버전 관리·롤백만 다룹니다.

### 8) 배포 가드레일 — 블루/그린과 롤링 {#deployment-guardrails}

가드레일은 프로덕션 모델 갱신을 위한 완전 관리형 배포 옵션 세트로, **오케스트레이션·모니터링·롤백 메커니즘을 직접 만들 필요가 없습니다.** ⚠️ **실시간·비동기 엔드포인트에만** 적용됩니다.

| 방식 | 트래픽 이동 | 주요 파라미터 | 장점 | 단점 |
|---|---|---|---|---|
| 블루/그린 **all-at-once** | 한 번에 100% 이동 후 베이킹 | — | 업데이트 시간·비용 최소 | 회귀가 트래픽 100%에 영향 |
| 블루/그린 **canary** | 2단계: 소량 canary → 나머지 | `CanarySize` ≤ **50%**(아래 ⚠️), `WaitIntervalInSeconds`, `TerminationWaitInSeconds`, `MaximumExecutionTimeoutInSeconds` | 영향 범위를 canary 플릿으로 한정 | 배포 내내 두 플릿 병행 |
| 블루/그린 **linear** | n개 균등 단계 | `LinearStepSize` **10–50%**, 단계마다 베이킹 | 회귀 위험 최소 | 기간·비용이 단계 수에 비례 |
| **롤링** | 배치 크기만큼 새 인스턴스 → 트래픽 이동 → 구 인스턴스 정리를 반복 | `MaximumBatchSize` **5–50%**, `RollbackMaximumBatchSize`, `WaitIntervalInSeconds`, `MaximumExecutionTimeoutInSeconds` ≤ 28,800초(8시간) | 블루/그린보다 필요 용량이 적다 | 서버리스·다중 변형 엔드포인트 불가 |

> ⚠️ **`CanarySize` 50%의 기준이 문서마다 다르게 적혀 있습니다.** 개발자 가이드는 "그린(새) 플릿 용량의 50% 이하"(원문 "50% of the new fleet's capacity"), API 레퍼런스는 "변형 전체 인스턴스 수의 50% 이하"(원문 "50% of the variant's total instance count")라고 씁니다. 상한 비율 50%는 양쪽이 같으니 **그 수치만** 기억하고, 분모가 무엇인지에 답이 걸리는 문항은 피합니다. API 파라미터 관점의 정리는 [`mla-t3-3` 12)](mla-t3-3.md#deploy-strategy-rollback)에 있습니다.

**공통 전제** — 모니터링용 **CloudWatch 경보를 먼저 만들고** `DeploymentConfig.AutoRollbackConfiguration.Alarms`에 이름으로 지정합니다. 베이킹 기간에 경보가 하나라도 울리면 트래픽이 블루(구) 플릿으로 롤백됩니다. 신규 엔드포인트 구성은 기존과 **변형 이름이 같아야** 합니다. Marketplace 컨테이너나 Inf1 인스턴스를 쓰는 엔드포인트는 가드레일을 쓸 수 없고 **"all-at-once + 최종 베이킹 없음" 블루/그린으로 폴백**합니다. 다단계·베이킹이 있는 블루/그린은 업데이트 동안 **두 플릿 요금을 모두** 냅니다. 롤링이 실패하고 자동 롤백도 실패하면 `UpdateRollbackFailed` 상태가 되며 다시 `UpdateEndpoint`로 복구합니다.

**섀도 테스트와 A/B** — 섀도 변형은 요청 **사본**을 받고 프로덕션 변형의 응답만 호출자에게 돌아가므로 사용자 영향이 없습니다(서버리스·비동기·Marketplace·멀티 컨테이너·MME·Inf1 엔드포인트는 사용 불가). A/B는 프로덕션 변형의 가중치로 트래픽을 나누거나 `TargetVariant`로 특정 변형을 직접 호출합니다. 두 기법의 상세·비교는 [`mla-t2-3` 14)](mla-t2-3.md#shadow-ab)이 정본입니다.

> 🧠 원리: 블루/그린은 새 플릿을 **전부** 띄운 뒤 트래픽을 옮기며 베이킹 기간 동안 경보를 감시합니다. 롤링은 단계마다 구 플릿을 정리하므로 한꺼번에 필요한 추가 용량이 **배치 크기 수준**입니다. GPU처럼 수급이 어려운 인스턴스를 쓰는 대형 엔드포인트에 롤링을 권하는 이유가 이것입니다.

CodeDeploy의 사전 정의 구성(`LambdaCanary10Percent5Minutes` 등)과의 대응은 [`mla-t3-3` 12)](mla-t3-3.md#deploy-strategy-rollback)에 있습니다.

### 9) 컴퓨팅 자원 선택 — 패밀리·가속기·대역폭 {#compute-choice}

EC2 범주: **범용**(컴퓨트·메모리·네트워킹 균형) / **컴퓨팅 최적화**(고성능 프로세서가 이점인 컴퓨트 집약 — 예시 워크로드에 **ML 추론**이 들어 있다) / **메모리 최적화**(대용량 데이터를 메모리에서 처리) / 스토리지 최적화 / **가속 컴퓨팅**(하드웨어 가속기·보조 프로세서 — DL·G·Inf·P·Trn) / HPC.

| 요구사항 | 선택 |
|---|---|
| 트리 기반 고전 ML 훈련 | CPU. **LightGBM은 메모리 바운드라 범용(M5)이 컴퓨트 최적화(C5)보다 낫다**고 문서가 명시한다. XGBoost는 CPU·GPU 훈련·추론을 모두 지원한다 |
| 대규모 딥러닝 훈련 | GPU **P 계열**(P3은 HPC·딥러닝 훈련용으로 설계) 또는 Trainium. 인스턴스 간 통신이 중요한 확장형 훈련은 **EFA** 지원 고대역 인스턴스 |
| 딥러닝·생성형 AI 추론의 지연·비용 | GPU **G 계열**(g4dn은 ML 추론·컴퓨터 비전에 적합) 또는 **Inferentia**(Neuron SDK로 배포, Neo 컴파일 대상에 포함) |
| 소형 모델·낮은 QPS·분류·임베딩 | CPU(Graviton 포함). EKS 모범 사례의 판단표는 CPU 쪽을 **p95 100–500 ms 허용 + 엔드포인트당 100 req/s 미만**으로 잡는다 |
| CPU 추론의 가격 대비 성능 | **Graviton**(ARM). 컨테이너 이미지가 ARM 호환이거나 멀티 아키텍처여야 한다 |
| 모델이 인스턴스 메모리보다 크다 | 메모리가 더 큰 인스턴스(모델 크기가 선택 요인이다) |
| 소형 모델이 매우 많다 | 인스턴스 공유(MME·MCE·IC) → 6) |
| GPU 용량 확보가 어렵다 | GPU는 용량 예약이 필요한 경우가 많다 → **롤링 배포**로 추가 용량을 최소화 |

**네트워킹 대역폭** — Elastic Fabric Adapter(EFA)는 AI·ML·HPC 가속을 위해 EC2 인스턴스에 붙이는 네트워크 장치입니다. 대역폭은 크기마다 크게 다르고(예: `inf2.48xlarge` 100 Gbps, `p5.48xlarge` 3200 Gbps), 작은 크기는 기준 대역폭에 **크레딧 기반 버스트**가 붙습니다(예: `g5.xlarge` 기준 2.5 Gbps / 최대 10 Gbps). 수치가 필요하면 EC2 인스턴스 유형 사양표를 기준으로 봅니다.

SageMaker AI 호스팅은 `ml.` 접두 인스턴스를 **70종 이상** 제공하며 Inferentia·Graviton이 포함됩니다.

**프로덕션 vs 테스트(K4)** — 테스트는 로컬 모드로 배포 전에 검증하고 서버리스·비동기(0 스케일)로 유휴 비용을 억제합니다. 프로덕션은 Inference Recommender 결과 + 오토 스케일링 + Savings Plans로 맞춥니다. Inference Recommender 작업은 **비프로덕션 엔드포인트에서** 돌립니다.

> ⚠️ **Amazon Elastic Inference** — 2023-04-15부터 신규 고객은 SageMaker·ECS·EC2에서 EI 액셀러레이터 인스턴스를 시작할 수 없고, ECS 콘솔 문서는 "더 이상 제공되지 않는다"고 적습니다. **선택지로 고르지 않습니다**(최종 종료일은 문서에서 확인되지 않습니다).

> ⚠️ **Trainium 표기가 문서마다 다릅니다.** 제품 페이지는 현재 "AI training and inference" 모두를 표방하고, AWS 블로그는 "주로 훈련용", Neuron SDK 문장은 "Inferentia에 배포, Trainium에서 훈련", DLAMI의 Trainium 페이지는 추론 워크로드용이라 적습니다. **Inf와 Trn을 짝으로 볼 때는 "추론 특화는 Inf"까지만** 근거로 씁니다.

### 10) Inference Recommender — 부하 테스트로 고른다 {#inference-recommender}

SageMaker AI ML 인스턴스 전반에서 **부하 테스트와 모델 튜닝을 자동화**해 실시간 또는 **서버리스** 엔드포인트에 가장 적합한 인스턴스 유형·구성을 고르게 돕습니다. 고려 요소는 인스턴스 수·컨테이너 파라미터·모델 최적화·최대 동시성·메모리 크기이고, **작업 중 쓴 인스턴스에 대해서만** 요금을 냅니다.

| 구분 | Default (Inference recommendations) | Advanced (Endpoint recommendations) |
|---|---|---|
| 입력 | **모델 패키지 ARN만** | 원하는 인스턴스 또는 서버리스 + **커스텀 트래픽 패턴** + 지연·처리량 요구 |
| 소요 | **45분 이내** | 평균 **2시간** |
| 용도 | 예비 추천 | 맞춤 부하 테스트 기반 엔드포인트 추천 |

출력은 인스턴스 구성 목록 + 환경 변수 + 비용·처리량·지연 지표이며, **오토 스케일링 정책에 쓸 초기 인스턴스 수**도 제공합니다. 둘 중 하나만 써도 됩니다. 모델 세부 페이지에서 상위 5개 "prospective instances"를 즉시 볼 수도 있습니다(예비 결과이므로 작업 실행을 권장).

**기존 엔드포인트 벤치마킹 제약** — 작업당 엔드포인트 1개 · 변형 1개 · **오토 스케일링 사용 불가** · 실시간 전용 · 실시간 멀티 모델 엔드포인트 미지원 · 라이브 트래픽을 받는 프로덕션 엔드포인트에서 실행 금지 권고.

**역할 구분** — Neo는 대상 하드웨어용 **모델 컴파일·최적화**, Inference Recommender는 **SageMaker 엔드포인트의 인스턴스·구성 추천**, Compute Optimizer는 EC2·Auto Scaling 그룹·Lambda·EBS·ECS(Fargate) 같은 **컴퓨트 리소스의 크기 조정 권고**입니다. SageMaker 엔드포인트 추천을 묻는 문항에서 고를 것은 Inference Recommender입니다.

### 11) 컨테이너 선택 — 제공 vs 사용자 지정 {#container-choice}

**판단 순서** — ① 내장 알고리즘을 쓰면 해당 이미지 ② 지원 프레임워크(TensorFlow·PyTorch·MXNet·Chainer·scikit-learn·Spark ML 등)는 **사전 빌드 이미지**를 쓰고 추가 패키지는 `requirements.txt` 또는 사전 빌드 이미지 **확장**으로 ③ 사전 빌드 이미지가 없는 커스텀 프레임워크면 **사용자 지정 컨테이너(BYOC)**.

| 선택지 | 언제 | 핵심 |
|---|---|---|
| 사전 빌드 이미지(DLC) | 지원 프레임워크 모델 | 제공 목록 내 프레임워크·버전에서 고른다 |
| 사전 빌드 이미지 확장 | 의존성을 다른 방법으로 가져올 수 없을 때 | 제공 베이스 이미지 위에 Dockerfile로 의존성을 더한다 |
| BYOC | 프레임워크에 사전 빌드 이미지가 없을 때 | 아래 계약을 지키고 ECR에 푸시한다 |
| DJL Serving / LMI | 대형 모델·모델 병렬 추론 | CPU·GPU·Inferentia를 지원한다 |
| Triton | 다중 프레임워크(TensorRT·TensorFlow·PyTorch·ONNX 등), 앙상블, MME GPU | 모델마다 `config.pbtxt`가 필요하다 |

**BYOC 추론 계약**

| 항목 | 요구 |
|---|---|
| 서버 | **포트 8080**에서 `/invocations`·`/ping`을 수용한다 |
| 응답 | 소켓 연결은 **250 ms** 이내 수락, 요청은 **60초** 이내 응답. 시작 후 **8분** 안에 `/ping`이 200을 계속 반환하지 않으면 인스턴스 시작이 실패한다. `/ping` 요청 타임아웃은 2초 |
| 실행 | `docker run <image> serve`로 실행되고 루트 사용자를 전제한다. ENTRYPOINT는 exec 형식 권장(SIGTERM을 받아야 하며, 중지 시 SIGTERM 후 30초 뒤 SIGKILL) |
| 모델 | `ModelDataUrl`은 `tar.gz`여야 하며 **`/opt/ml/model`**에 풀린다(읽기 전용) |
| GPU | `nvidia-docker` 호환이어야 하고 NVIDIA 드라이버는 이미지에 넣지 않는다 |

> ⚠️ 요구사항 목록은 `/invocations`와 `/ping`에 **POST**를 수용한다고 쓰고 헬스체크 절은 주기적 **GET** 요청이라 씁니다(원문 불일치). 실무·시험 기준으로는 **"추론은 POST `/invocations`, 헬스체크는 `/ping` 200 응답"**까지만 외웁니다.

컨테이너를 **만들고 유지하는 쪽**(ECR 푸시 절차, 이미지 스캔, 수명 주기 정책, 훈련 컨테이너 계약)은 [`mla-t3-2` 11)](mla-t3-2.md#byoc-ecr)이 정본입니다. 여기서는 **"어느 이미지를 고를 것인가"**만 다룹니다.

### 12) 엣지 최적화 — SageMaker Neo {#edge-neo}

- **Neo**는 모델을 한 번 학습해 클라우드와 엣지 어디서나 실행하도록 **컴파일**합니다(컴파일러 + 런타임). Gluon·Keras·MXNet·PyTorch·TensorFlow·TensorFlow-Lite·ONNX 모델을 Android·Linux·Windows 기기의 Ambarella·ARM·Intel·Nvidia·NXP·Qualcomm·Texas Instruments·Xilinx 프로세서용으로 최적화하며 FP32 또는 INT8·FP16 양자화 파라미터를 다룹니다.
- **대상은 두 가지** — 클라우드 인스턴스(`ml_c4`·`ml_c5`·`ml_m4`·`ml_m5`·`ml_p2`·`ml_p3`·`ml_g4dn`, Inf1, 문서가 지정한 리전의 Inf2·Trn1)와 엣지 디바이스(Raspberry Pi 3, Texas Instruments Sitara, Jetson TX1 등).
- **엣지 실행** — 컴파일된 모델을 S3에서 디바이스로 내려받아 **DLR(Deep Learning Runtime)**로 실행하거나 AWS IoT Greengrass로 배포합니다.
- ⚠️ **SageMaker Edge Manager는 2024-04-26에 중단**됐습니다(콘솔 접근·엣지 패키징 작업·디바이스 플릿 관리 불가, 서비스 내 참조 삭제). 공식 대안은 크로스 플랫폼 엣지 런타임 **ONNX**, 엣지 배포·모니터링의 **AWS IoT Greengrass V2**, 또는 MQTT + IoT Jobs 기반 OTA입니다.
- ⚠️ **AWS IoT Greengrass v1**은 2025-10 Sunset 공지 후 **2026-10-07에 지원이 종료**됐습니다. v2로 이전합니다. 다만 **IoT Greengrass는 시험 가이드의 범위 외 서비스 목록**에 있으므로 Neo(컴파일·DLR)까지만 학습하고 Greengrass 운영 세부는 보지 않습니다.

> 🧠 원리: Neo의 컴파일러는 프레임워크별 연산을 **프레임워크 중립 중간 표현**으로 바꿔 최적화한 뒤 대상용 바이너리를 만들고, 대상 플랫폼마다 컴파일된 모델을 실행하는 런타임이 따로 있습니다. 그래서 "한 번 학습하고 여러 하드웨어에서 실행"이 가능합니다.

### 13) 배포 오케스트레이터 선택 {#orchestrator-choice}

SageMaker AI Workflows 개요는 **SageMaker가 직접 제공하는 것**(Pipelines, Kubernetes 오케스트레이션, Notebook Jobs)과 **SageMaker와 통합되는 외부 서비스**(Airflow, Step Functions, AWS Batch)를 나눕니다.

| 서비스 | 공식 정의 | 인프라·운영 | 선택 단서 |
|---|---|---|---|
| **SageMaker AI Pipelines** | ML 개발 자동화를 위한 **목적 특화 워크플로 오케스트레이션 서비스**. 단계의 DAG | 서버리스 — 오케스트레이션 컴퓨트를 자동 프로비저닝·스케일·종료 | SageMaker 중심 ML CI/CD. 파이프라인 업데이트·실행 이력의 **내장 버전 관리와 리니지 추적** |
| **AWS Step Functions** | 다단계 ML 워크플로를 Python으로 만들어 SageMaker 인프라를 오케스트레이션 | 별도 리소스 프로비저닝 없이 오케스트레이션 | 여러 AWS 서비스를 엮는 워크플로. SageMaker 잡과 `.sync` 연동(**콜백 Task Token은 미지원**) |
| **Amazon MWAA** | 관리형 Apache Airflow, Python DAG | 환경(스케줄러·워커)이 자동 스케일 | **이미 Airflow를 쓰거나** 워크플로를 AWS 리소스에서 추상화하고 싶을 때 |
| **Kubernetes용 Operators·Kubeflow 컴포넌트** | Kubernetes API·`kubectl`로 SageMaker 작업 생성 | ACK 기반 최신 Operators | Kubernetes 중심 조직 |

시험 범위 내 오케스트레이션 서비스 목록에는 MWAA·SNS·SQS·Step Functions가 있습니다. Pipelines의 **내부 구조**(DAG·단계 18종·캐싱·재시도 정책)와 CI/CD 도구(CodePipeline 등)는 [`mla-t3-3` 9)](mla-t3-3.md#sagemaker-pipelines)이 정본입니다.

### 14) 배포 대상 선택 — 엔드포인트 vs EKS·ECS·Lambda {#deploy-target}

| 대상 | 관리 범위 | 주요 한도·특징 | 롤아웃·롤백 |
|---|---|---|---|
| **SageMaker AI 엔드포인트** | 완전 관리형. 가드레일을 쓰면 오케스트레이션·모니터링·롤백을 직접 만들 필요가 없다 | 추론 옵션 4종, MME·IC·파이프라인, Model Registry·Inference Recommender·Neo 연계 | 가드레일(블루/그린·롤링), 섀도 테스트 |
| **Amazon EKS** (Kubernetes) | 서빙 스택·스케일링을 직접 구성 | 소형 모델 고밀도 CPU 서빙에 적합. **CPU 파드는 디바이스 플러그인·GPU 리소스 타입 없이 표준 스케줄링**. SageMaker Operators(ACK)로 `kubectl`에서 SageMaker 작업도 만들 수 있다 | Kubernetes 방식 |
| **Amazon ECS** | GPU 인스턴스 + GPU 최적화 AMI(NVIDIA 드라이버 사전 구성), 태스크 정의에서 GPU 수 지정 | GPU 지원 인스턴스: p2·p3·p4d·p5·g3·g4·g5·g6·g6e·g6f | 롤링 업데이트 + **배포 서킷 브레이커** 자동 롤백 |
| **AWS Lambda** | 서버리스 함수 | 이미지 **10 GB**, 메모리 128–10,240 MB, 타임아웃 **900초(15분)**, 동기 페이로드 **6 MB**(스트리밍 응답 200 MB, 비동기 1 MB), 1,769 MB에서 1 vCPU 상당 | 버전 + **가중 별칭** 카나리 |

**서버리스 추론 vs Lambda** — 둘 다 "서버리스"지만 다른 서비스입니다. 서버리스 추론은 SageMaker 엔드포인트(메모리 1–6 GB, 4 MB·60초, 엔드포인트당 동시성 ≤200, GPU 불가, Model Registry·MLOps 파이프라인과 통합)이고, Lambda는 범용 함수(메모리 ≤10,240 MB, 이미지 10 GB, 15분, 동기 6 MB)입니다. 서버리스 추론이 내부적으로 Lambda와 통합되어 고가용성을 제공하지만 같은 서비스는 아닙니다.

**시험 범위** — 범위 내 컴퓨팅·컨테이너 서비스는 EC2·Lambda·Batch·ECR·ECS·EKS이고, **App Runner·Elastic Beanstalk·Lightsail·Outposts는 범위 밖**입니다. 보기에 범위 밖 서비스가 섞여 있으면 그것부터 지웁니다.

> Lambda에 GPU가 없다고 단정하는 공식 문서 문장은 확인되지 않았습니다(AWS 블로그가 "GPU가 필요하면 컨테이너 서비스·Kubernetes·SageMaker 엔드포인트를 고려하라"고 안내할 뿐입니다). Lambda 적합성은 **한도(10 GB·15분·6 MB)**로 판단합니다.

### 15) 배포·오케스트레이션 수단의 현재 가용성 {#deploy-service-status}

> 📍 **수명 주기 용어**(Maintenance · Sunset · Full Shutdown)와 **시험 범위에 남아 있지만 신규 고객이 못 쓰는 서비스 표**, 그리고 "날짜가 둘 적힌 행은 공지일 → 발효일"이라는 읽는 법은 [`mla-t2-1` 8)](mla-t2-1.md#service-status)이 정본입니다. 여기서는 다시 쓰지 않습니다.

이 절이 다루는 것은 하나뿐입니다 — **"이 배포·오케스트레이션 수단을 지금 새 계정에서 쓸 수 있는가."** 3.1의 보기에는 기능 자체는 맞지만 더는 선택할 수 없는 항목이 섞여 들어옵니다.

| 배포·오케스트레이션 수단 | 상태 | 대신 고를 것 |
|---|---|---|
| **Amazon Elastic Inference** | 2023-04-15 이후 신규 고객은 SageMaker·ECS·EC2에서 EI 액셀러레이터 인스턴스를 시작할 수 없다. ECS 콘솔 문서는 "no longer available"이라 적는다(최종 종료일은 문서에서 확인되지 않는다) | 추론 가속·절감은 **Inferentia·Graviton·Neo·MME** → 9) |
| **SageMaker Edge Manager** | 2024-04-26 중단. 콘솔 접근·엣지 패키징 작업·디바이스 플릿 관리가 모두 불가하고 서비스 내 참조가 삭제됐다 | 런타임은 **ONNX**, 엣지 배포·모니터링은 **IoT Greengrass V2** → 12) |
| **AWS IoT Greengrass v1** | 2025-10 Sunset 공지 → **2026-10-07 지원 종료**. v2로 이전한다. 다만 Greengrass 자체가 **가이드 범위 외 서비스**다 | 엣지 문항은 **Neo 컴파일 + DLR**까지만 → 12) |
| **SageMaker AI Operators for Kubernetes**(원 버전) | 2023-02-15 지원 종료 | **ACK 기반** 최신 Operators → 13) |

**개명이 배포 도구에 남기는 것** — 2024-12-03에 Amazon SageMaker가 Amazon SageMaker AI로 바뀌었지만(경위는 `mla-t2-1` 8)), 배포 관점에서 기억할 결론은 하나입니다: **`sagemaker` API 네임스페이스·CLI·`AmazonSageMaker*` 관리형 정책·`AWS::SageMaker::*` CloudFormation 리소스 접두어·콘솔·문서 URL이 모두 그대로**라는 것입니다. 즉 개명은 템플릿·SDK 코드를 바꾸지 않습니다(IaC 쪽 세부는 [`mla-t3-2` 8)](mla-t3-2.md#iac-choice)).

**오케스트레이터 선택지의 가용성** — 13)의 네 선택지(Pipelines · Step Functions · MWAA · Kubernetes Operators) 가운데 신규 고객이 막힌 것은 없습니다. 주의할 것은 위 표의 **원 버전 Operators**뿐이고, 그 밖에는 "Step Functions의 콜백 Task Token이 SageMaker 통합에서 미지원"처럼 **가용성이 아니라 기능 범위**의 제약입니다.

⚠️ 배포 경로에 얽히는 기능 중 **Model Monitor·Clarify·Debugger**는 신규 고객에게 닫혀 있습니다(상태·대안은 `mla-t2-1` 8)의 표). 이 Task에서 그 사실이 실제로 쓰이는 지점은 **서버리스 추론의 "쓸 수 없는 기능" 목록**(→ 2))이고, 드리프트 기반 재훈련에서의 영향은 [`mla-t3-3` 14)](mla-t3-3.md#retraining)가 다룹니다.

---

## ✍️ 시험 포인트

- **한도로 먼저 지웁니다.** 4 MB 초과·60초 초과·GPU 필요 → 서버리스 배제. VPC·네트워크 격리·데이터 캡처·Model Monitor·MME 필요 → 서버리스 배제. 영속 엔드포인트 불필요 + 사전에 모인 데이터셋 → 배치 변환. 1 GB급 입력 + 수십 분 처리 + 유휴 0 → 비동기.
- **"0 스케일"은 모두의 기능이 아닙니다.** 서버리스는 유휴 시 0, 비동기는 `MinCapacity=0`, 실시간은 **추론 컴포넌트를 호스팅할 때만** 0까지 갑니다. "실시간 + 오토 스케일링"으로 유휴 비용을 0으로 만들겠다는 보기는 일반 변형에서는 틀립니다.
- **MME와 멀티 컨테이너는 프레임워크로 갈립니다.** 같은 프레임워크 + 모델 수천 개 + 호출 빈도 편차 → MME(콜드 스타트 감수). 다른 프레임워크 + 15개 이하 + 콜드 스타트 불허 → MCE direct. 순서가 있는 체인 → 직렬 파이프라인. 모델별 GPU·메모리 몫 → 추론 컴포넌트.
- **자동 롤백은 공짜가 아닙니다.** 가드레일의 자동 롤백은 **미리 만들어 둔 CloudWatch 경보**를 `AutoRollbackConfiguration`에 지정했을 때만 동작합니다. "경보 없이 자동 롤백"은 성립하지 않습니다.
- **가속 인스턴스 수급이 어렵거나 대형 모델**이면 롤링입니다. 블루/그린은 새 플릿을 전부 띄워야 해서 추가 용량이 두 배로 필요합니다.
- **역할이 겹쳐 보이는 세 서비스**: Neo = 컴파일, Inference Recommender = 엔드포인트 인스턴스 추천(부하 테스트), Compute Optimizer = EC2·ASG·Lambda·EBS·ECS(Fargate) 크기 조정.
- **보기에 섞이는 "못 쓰는 선택지"**: Elastic Inference(신규 불가) · SageMaker Edge Manager(중단) · IoT Greengrass(범위 밖) · App Runner·Elastic Beanstalk(범위 밖) · Step Functions의 콜백 Task Token(SageMaker 통합 미지원).
- BYOC 숫자 네 개는 자주 나옵니다: **8080 / 250 ms / 60초 / 8분.**

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 서버리스와 비동기를 "둘 다 0까지 줄어드니 같다"고 본다 | 서버리스는 **4 MB·60초·GPU 불가**이고 비동기는 **1 GB·1시간·GPU 가능**이다. 큰 입력이나 GPU가 보이면 서버리스는 지워진다 |
| 비동기와 배치 변환을 섞는다 | 비동기는 **요청 단위**(엔드포인트가 떠 있고 큐에 쌓인다), 배치 변환은 **데이터셋 단위 잡**(영속 엔드포인트가 없다) |
| 배치 변환에서 인스턴스를 늘리면 늘 빨라진다고 본다 | S3 객체를 **키 기준으로** 매핑하므로 **입력 파일이 하나면 한 대만 일한다.** 파일을 쪼개야 분산된다 |
| `MaxPayloadInMB`를 100으로, `MaxConcurrentTransforms`를 10으로 함께 올린다 | **곱이 100 MB를 넘을 수 없다.** 둘은 독립적으로 올릴 수 없다 |
| 실시간 엔드포인트를 서버리스로 "전환"하려 한다 | 인스턴스 기반 → 서버리스 전환은 **불가**(`ValidationError`). 반대 방향만 가능하고 되돌릴 수 없다 |
| 멀티 컨테이너 엔드포인트의 기본 모드를 `Direct`라고 생각한다 | 기본값은 **`Serial`**(파이프라인)이다. 독립 호출을 원하면 `Direct`로 명시하고 `ContainerHostname`을 쓴다 |
| MME에 서로 다른 프레임워크 모델을 올린다 | MME는 **공유 서빙 컨테이너**를 전제하므로 같은 프레임워크여야 한다. 프레임워크가 다르면 멀티 컨테이너다 |
| 가드레일을 서버리스 엔드포인트에 적용한다 | 가드레일은 **실시간·비동기에만** 적용된다. 롤링은 서버리스·다중 변형에서 추가로 제외된다 |
| 섀도 테스트를 "점진 배포 수단"으로 쓴다 | 섀도는 사본만 받고 응답이 사용자에게 가지 않아 **영향이 없는 검증 수단**이다. 실제 트래픽 일부를 받는 것은 canary다 |
| Inf1 인스턴스에서도 canary를 쓸 수 있다고 본다 | Marketplace 컨테이너·Inf1 엔드포인트는 가드레일 제외 대상이고 **all-at-once 블루/그린으로 폴백**된다 |
| 추론 비용을 줄이려고 Elastic Inference를 고른다 | 2023-04-15 이후 신규 고객이 쓸 수 없다. 현재 문서가 드는 수단은 Inferentia·Graviton·Neo·MME다 |
| 엣지 배포 문항에서 Edge Manager를 고른다 | 2024-04-26 중단됐다. Neo로 컴파일하고 ONNX 또는 IoT Greengrass V2로 배포한다 |
| SageMaker 엔드포인트 인스턴스 추천을 Compute Optimizer에서 받는다 | Compute Optimizer의 대상에 SageMaker 엔드포인트를 명시한 문서는 없다. 엔드포인트 추천은 **Inference Recommender**다 |
| 개명 때문에 `AWS::SageMaker::*`가 바뀌었다고 본다 | API 네임스페이스·CLI·관리형 정책·CloudFormation 리소스 접두어는 **그대로**다 |

---

## 🧪 자가 점검

1. 요청마다 입력이 약 700 MB이고 처리에 30분이 걸리며, 요청이 없는 시간에는 인스턴스 비용이 들면 안 된다. 어떤 옵션이고, 응답에는 무엇이 담기는가? *(→ 1), 3))*
2. 간헐적 트래픽에 서버리스를 고르려 했으나 요구사항에 "엔드포인트를 VPC 안에 둬야 한다"가 있다. 왜 안 되고 무엇으로 바꾸는가? *(→ 2), 5))*
3. 고객사별 모델 3,000개가 모두 같은 프레임워크이고 호출 빈도 차이가 크다. 어떤 방식이고, 인스턴스 메모리와 vCPU는 각각 무엇을 정하는가? *(→ 6))*
4. 대형 모델을 올린 인스턴스 20대 엔드포인트를 갱신하는데 GPU 수급이 어렵다. 어떤 가드레일 방식이고 왜인가? *(→ 8), 9))*
5. 같은 엔드포인트에서 전처리 → 추론 → 후처리를 순서대로 돌리고 싶다. 컨테이너 수 범위와 비용 조건은? *(→ 6))*
6. 모델을 Raspberry Pi에 올려야 한다. 어떤 서비스로 준비하고 디바이스에서 무엇으로 실행하며, 보기에 있는 Edge Manager는 왜 답이 아닌가? *(→ 12))*
7. 인스턴스 유형을 커스텀 트래픽 패턴으로 부하 테스트해 정하려 한다. 어떤 작업 유형이고 소요 시간은? 프로덕션 엔드포인트에서 돌려도 되는가? *(→ 10))*
8. 지원 프레임워크에 없는 언어로 짠 추론 서버를 올려야 한다. 컨테이너가 반드시 지켜야 하는 네 가지 숫자는? *(→ 11))*
9. 기존에 Apache Airflow DAG 자산이 많은 팀이 ML 워크플로를 오케스트레이션한다. 무엇을 고르고, SageMaker 중심이라면 무엇이 달라지는가? *(→ 13))*

---

## 🔭 MLA-C02에서 달라지는 것 {#c02-delta}

> C01과 C02의 차이는 공식 비교 페이지가 정본입니다. 아래는 **이 Task에 추가·삭제된 항목**이며 C01 시험 범위가 아닙니다.

- **C02 대응 Task**: 3.1 「ML 및 AI 모델 유형의 배포 인프라를 관리합니다」
- **추가된 항목 5개**
  - `3.1.4` 적절한 **파운데이션 모델(FM) 배포 옵션**을 평가하고 선택합니다.
  - `3.1.5` **AWS 외부에서 구축한 모델**을 AWS 환경에 배포합니다(예: Amazon SageMaker AI, Amazon Bedrock Custom Model Import).
  - `3.1.6` 특정 작업, 다른 서비스·도구와의 통합, **에이전트 통신 프로토콜**을 위한 에이전트를 배포·구성합니다.
  - `3.1.7` **FM 배포·모델 호스팅·리소스 할당**을 구성합니다.
  - `3.1.8` **검색 증강 생성(RAG) 시스템 구성**을 적용합니다(예: 검색 전략, 순위 조정).
- **삭제된 항목 1개**: 「엣지 디바이스에서 모델을 최적화하는 방법(예: SageMaker Neo)」 — 즉 **12)는 C01에서만 묻습니다.**
- 읽는 법: C01의 3.1이 "고전적 추론 옵션 + 인스턴스·컨테이너 선택"이었다면 C02는 그 무게를 **FM 호스팅·에이전트·RAG**로 옮깁니다. 1)의 옵션 비교와 9)의 가속기 선택은 그대로 쓰이고, **엣지(12))의 비중은 사라집니다.**

출처: [MLA-C01 및 MLA-C02 비교 (한국어 공식)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-02/mla-02-comparison.html) · 조회일 2026-10-17

---

### 📌 출처

- 추론 옵션: [Deploy models for inference](https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-model-options.html) · [Deploy models — 경로 비교](https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-model.html) · [호스팅 FAQ](https://docs.aws.amazon.com/sagemaker/latest/dg/hosting-faqs.html) · [Optimize costs for inference](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-cost-optimization.html)
- 서버리스: [Serverless Inference](https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints.html) · [서버리스 호출](https://docs.aws.amazon.com/sagemaker/latest/dg/serverless-endpoints-invoke.html) · [ProductionVariantServerlessConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ProductionVariantServerlessConfig.html)
- 비동기: [Asynchronous inference](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference.html) · [InvokeEndpointAsync](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_runtime_InvokeEndpointAsync.html) · [비동기 오토 스케일링](https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference-autoscale.html) · [AsyncInferenceNotificationConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_AsyncInferenceNotificationConfig.html)
- 배치 변환: [Batch transform](https://docs.aws.amazon.com/sagemaker/latest/dg/batch-transform.html) · [CreateTransformJob](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_CreateTransformJob.html) · [TransformResources](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_TransformResources.html) · [ModelClientConfig](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_ModelClientConfig.html)
- 다중 모델: [Multi-model endpoints](https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoints.html) · [MME 인스턴스 권고](https://docs.aws.amazon.com/sagemaker/latest/dg/multi-model-endpoint-instance.html) · [멀티 컨테이너 생성](https://docs.aws.amazon.com/sagemaker/latest/dg/multi-container-create.html) · [멀티 컨테이너 direct](https://docs.aws.amazon.com/sagemaker/latest/dg/multi-container-direct.html) · [추론 파이프라인](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-pipelines.html) · [추론 컴포넌트](https://docs.aws.amazon.com/sagemaker/latest/dg/realtime-endpoints-deploy-models.html) · [0 인스턴스 스케일](https://docs.aws.amazon.com/sagemaker/latest/dg/endpoint-auto-scaling-zero-instances.html) · [InvokeEndpoint](https://docs.aws.amazon.com/sagemaker/latest/APIReference/API_runtime_InvokeEndpoint.html)
- 배포 전략: [Deployment guardrails](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails.html) · [블루/그린](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-blue-green.html) · [canary](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-blue-green-canary.html) · [linear](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-blue-green-linear.html) · [롤링](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-rolling.html) · [제외 대상](https://docs.aws.amazon.com/sagemaker/latest/dg/deployment-guardrails-exclusions.html) · [섀도 테스트](https://docs.aws.amazon.com/sagemaker/latest/dg/shadow-tests.html) · [A/B 테스트](https://docs.aws.amazon.com/sagemaker/latest/dg/model-ab-testing.html)
- 버전·롤백: [Model Registry](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry.html) · [승인 상태](https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-approve.html) · [Lambda 별칭 라우팅](https://docs.aws.amazon.com/lambda/latest/dg/configuring-alias-routing.html) · [ECS 배포 서킷 브레이커](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/deployment-circuit-breaker.html)
- 컴퓨팅: [EC2 인스턴스 유형 사양](https://docs.aws.amazon.com/ec2/latest/instancetypes/ec2-instance-type-specifications.html) · [가속 컴퓨팅](https://docs.aws.amazon.com/ec2/latest/instancetypes/ac.html) · [EFA](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html) · [Graviton 엔드포인트](https://docs.aws.amazon.com/sagemaker/latest/dg/realtime-endpoints-graviton.html) · [Inferentia](https://aws.amazon.com/ai/machine-learning/inferentia/) · [Trainium](https://aws.amazon.com/ai/machine-learning/trainium/) · [EKS CPU 추론 모범 사례](https://docs.aws.amazon.com/eks/latest/best-practices/aiml-cpu-inference.html) · [Compute Optimizer CLI](https://docs.aws.amazon.com/cli/latest/reference/compute-optimizer/index.html)
- 추천·컨테이너: [Inference Recommender](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender.html) · [추천 작업 유형](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender-recommendation-jobs.html) · [기존 엔드포인트 벤치마킹](https://docs.aws.amazon.com/sagemaker/latest/dg/inference-recommender-existing-endpoint.html) · [Docker 컨테이너](https://docs.aws.amazon.com/sagemaker/latest/dg/docker-containers.html) · [추론 코드 요구사항](https://docs.aws.amazon.com/sagemaker/latest/dg/your-algorithms-inference-code.html) · [Triton](https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-models-frameworks-triton.html) · [DJL Serving](https://docs.aws.amazon.com/sagemaker/latest/dg/deploy-models-frameworks-djl-serving.html) · [LMI](https://docs.aws.amazon.com/sagemaker/latest/dg/large-model-inference.html)
- 엣지: [SageMaker Neo](https://docs.aws.amazon.com/sagemaker/latest/dg/neo.html) · [엣지 디바이스](https://docs.aws.amazon.com/sagemaker/latest/dg/neo-edge-devices.html) · [클라우드 대상](https://docs.aws.amazon.com/sagemaker/latest/dg/neo-supported-cloud.html) · [Edge Manager 중단](https://docs.aws.amazon.com/sagemaker/latest/dg/edge.html) · [Edge Manager EOL 안내](https://docs.aws.amazon.com/sagemaker/latest/dg/edge-eol.html) · [Greengrass v1 이전](https://docs.aws.amazon.com/greengrass/v2/developerguide/migrate-from-v1.html)
- 오케스트레이터·대상: [SageMaker AI Workflows](https://docs.aws.amazon.com/sagemaker/latest/dg/workflows.html) · [Pipelines](https://docs.aws.amazon.com/sagemaker/latest/dg/pipelines.html) · [MWAA FAQ](https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-faqs.html) · [Step Functions SageMaker 통합](https://docs.aws.amazon.com/step-functions/latest/dg/connect-sagemaker.html) · [Operators(ACK)](https://docs.aws.amazon.com/sagemaker/latest/dg/kubernetes-sagemaker-operators-ack.html) · [Lambda 할당량](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html) · [ECS GPU](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-gpu.html)
- 수명·범위: [AWS Lifecycle Changes](https://docs.aws.amazon.com/general/latest/gr/service-lifecycle.html) · [SageMaker AI 개명](https://docs.aws.amazon.com/sagemaker/latest/dg/whatis.html) · [Model Monitor 가용성 변경](https://docs.aws.amazon.com/sagemaker/latest/dg/model-monitor-availability-change.html) · [범위 내 서비스](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-in-scope-services.html) · [범위 외 서비스](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/mla-01-out-of-scope-services.html)
- [MLA-C01 공식 시험 가이드 (한국어)](https://docs.aws.amazon.com/ko_kr/aws-certification/latest/machine-learning-engineer-associate-01/machine-learning-engineer-associate-01.html)

조사 노트: `docs/content-research/MLA-C01/tasks/3-1.md` (모든 사실에 공식 URL·조회일 2026-10-17 부착)
