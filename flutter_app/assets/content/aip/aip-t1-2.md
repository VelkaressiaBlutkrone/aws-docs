---
examGuideTaskId: aip-t1-2
certCode: AIP-C01
domain: 1
domainName: 파운데이션 모델 통합, 데이터 관리 및 규정 준수
domainWeightPct: 31
title: FM 선택 및 구성 (평가와 선택·동적 전환·복원력·사용자 지정 배포와 수명 주기)
coversTasks:
  - "1.2"
sources:
  - title: Evaluate the performance of Amazon Bedrock resources
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html
  - title: Understanding intelligent prompt routing in Amazon Bedrock
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html
  - title: What is AWS AppConfig?
    url: https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html
  - title: Handling errors in Step Functions workflows
    url: https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
  - title: Route model inference requests across AWS Regions with cross-Region inference
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html
  - title: Set up inference for a custom model
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html
  - title: Deploy a custom model for on-demand inference
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/deploy-custom-model-on-demand.html
  - title: Model Registry Models, Model Versions, and Model Groups
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/model-registry-models.html
  - title: Get recommendations for models with LoRA adapters
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/generative-ai-inference-recommendations-adapters.html
  - title: SFT on Nova 1.0 (PEFT · LoRA)
    url: https://docs.aws.amazon.com/nova/latest/userguide/nova-sft-1.html
lastVerified: 2026-11-14
---

# FM 선택 및 구성 (평가와 선택·동적 전환·복원력·사용자 지정 배포와 수명 주기)

> **커버하는 공식 Task** — AIP-C01 · 도메인 1 「파운데이션 모델 통합, 데이터 관리 및 규정 준수」(31%) · **작업 1.2 FM 선택 및 구성** (`aip-t1-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(1.2.1~1.2.4)를 모두 덮습니다. 이 작업의 네 기술은 **「무엇을 고르나 → 어떻게 바꾸나 → 끊기면 어쩌나 → 내 모델은 어떻게 올리나」** 순서로 읽으면 한 줄로 이어집니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Bedrock 평가의 **네 종류**와 평가 대상이 될 수 있는 **모델 유형**을 안다
- [ ] 코드 수정 없는 전환을 **AppConfig · 프롬프트 라우팅 · 추상화 계층**으로 가를 수 있다
- [ ] 지능형 프롬프트 라우팅의 **두 제약**(같은 패밀리 · 영어)을 말할 수 있다
- [ ] Step Functions의 **기본 실패 동작**과 **Catcher가 없는 자리**를 안다
- [ ] 지리형 ↔ 글로벌 크로스 리전 추론을 **데이터 레지던시·비용·SCP**로 가를 수 있다
- [ ] 사용자 지정 모델 추론 경로가 **둘**이고 각각 언제 맞는지 말할 수 있다
- [ ] 온디맨드 사용자 지정 모델 배포의 **리전 제약**을 안다
- [ ] 모델 레지스트리의 **그룹·버전·승인 상태**로 수명 주기를 설명할 수 있다

---

## 🎯 왜 중요한가

FM은 **고르는 순간이 아니라 바뀌는 순간**에 비용이 발생합니다. 모델이 더 좋은 것으로 교체되거나, 리전에서 용량이 모자라거나, 미세 조정한 내 모델을 올려야 할 때 **애플리케이션 코드를 고쳐야 한다면** 그 아키텍처는 이미 실패한 것입니다.

그래서 이 작업의 네 기술은 전부 **「바꿀 수 있게 만들어 두었는가」**를 묻습니다. 평가는 바꿀 근거를 만들고, AppConfig와 라우팅은 바꾸는 수단이고, 크로스 리전 추론과 서킷 브레이커는 **원하지 않을 때 강제로 바뀌는 상황**을 다루고, 모델 레지스트리는 바뀐 것을 **되돌릴 수 있게** 합니다.

---

## ⚡ 시험 직전 요약

- Bedrock 평가는 **네 종류** — 프로그래매틱(자동) · **사람 작업자** · **판정 모델(LLM-as-judge)** · RAG 평가. ⭐ 평가 대상에 **프롬프트 라우터**와 프로비저닝 처리량 모델도 든다.
- **AppConfig**는 **코드를 재배포하지 않고** 프로덕션 동작을 바꾼다 — 기능 플래그 · 허용/차단 목록 · 제한값 · 로깅 수준.
- ⚠️⚠️ **지능형 프롬프트 라우팅은 같은 모델 패밀리 안에서만** 라우팅하고 **영어 프롬프트에만 최적화**돼 있다.
- ⚠️ Step Functions는 상태가 오류를 보고하면 **기본적으로 전체 실행을 실패**시킨다. **Catcher는 Task·Parallel·Map에만** 있고 **최상위 실행 실패에는 없다**.
- ⚠️ **`States.ALL`은 `States.DataLimitExceeded`와 `Runtime` 오류를 잡지 못하고** Catcher 안에 **단독으로만** 써야 한다.
- 크로스 리전 추론은 **지리형 ↔ 글로벌** 둘이다. 글로벌이 **약 10% 저렴**하고, 지리형은 **데이터 레지던시**가 필요할 때다.
- ⚠️⚠️ **추론 프로필은 프로비저닝 처리량을 지원하지 않는다.** 그리고 **계정에서 수동으로 활성화하지 않은 리전으로도 라우팅될 수 있다**.
- CloudTrail은 크로스 리전 요청을 **소스 리전에** 남기고 **`additionalEventData.inferenceRegion`**으로 처리 리전을 알려 준다.
- ⚠️⚠️ 사용자 지정 모델 추론 경로는 **둘** — **프로비저닝 처리량 구매** 또는 **온디맨드 추론용 배포**. 후자는 **버지니아 북부·오리건**에서만 된다.
- 모델 레지스트리의 버전은 **1부터 1씩 증가**하고, ⚠️ **Marketplace 모델 패키지는 버전 관리 대상이 아니며 모델 그룹에 연결되지 않는다**.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **추론 프로필** | FM과 요청을 보낼 수 있는 리전 묶음을 정의하는 객체. 크로스 리전 추론이 이것으로 동작한다 |
| **프롬프트 라우터** | 요청마다 응답 품질을 예측해 같은 패밀리의 다른 모델로 보내는 단일 서버리스 엔드포인트 |
| **기능 플래그** | 코드를 재배포하지 않고 기능을 켜고 끄는 구성 값 |
| **모델 패키지 / 모델 그룹** | 모델 레지스트리에 등록되는 버전 단위와 그 묶음 |
| **LoRA 어댑터** | 고정된 기본 모델 위에 작은 어댑터 가중치만 훈련하는 파라미터 효율적 미세 조정 산출물 |
| **PT**(프로비저닝 처리량) | 전용 컴퓨팅 용량을 사서 보장된 처리량을 얻는 방식 |

---

## 📖 핵심 개념

### 1) FM을 평가하고 고른다 (기술 1.2.1) {#selection}

> 🧠 원리: 모델 선택은 **의견이 아니라 측정**이어야 합니다. Bedrock 평가는 그 측정을 네 가지 방식으로 제공하고, 각 방식이 답할 수 있는 질문이 다릅니다.

| 종류 | 무엇을 하는가 |
|---|---|
| **프로그래매틱(자동) 모델 평가** | 작업 수행 능력을 빠르게 평가한다. **내장 데이터세트** 또는 내 프롬프트 데이터세트를 쓴다 |
| **사람 작업자 평가** | 사내 직원 또는 업계 **주제 전문가**가 평점과 선호를 준다 |
| **판정 모델 평가(LLM-as-judge)** | **두 번째 LLM**이 응답을 채점하고 **각 응답에 설명을 붙인다** |
| **RAG 평가(LLM 기반)** | 지식 베이스·RAG 소스가 관련 정보를 검색하고 적절한 응답을 생성하는지 본다 |

공식이 적는 성질 둘:

- **자동 평가**는 계산된 점수와 지표를 내고, **사람 기반 평가**는 평점과 선호를 낸다. 같은 질문에 다른 종류의 답입니다.
- ⭐ **평가 대상이 될 수 있는 모델 유형이 여섯**입니다 — 파운데이션 모델 · **Bedrock Marketplace 모델** · 사용자 지정 FM · **가져온 FM** · **프롬프트 라우터** · **프로비저닝 처리량을 구매한 모델**. 프롬프트 라우터가 들어 있다는 것은 **라우팅 구성 자체를 평가해 비교할 수 있다**는 뜻입니다.

⚠️ 「성능 벤치마크·역량 분석·한계 평가」라는 기술 본문의 표현은 **평가를 한 번 돌리는 것이 아니라 축을 나눠 보는 것**입니다. 축의 정의는 `aip-t1-1` 문서 §4의 다섯 지표를, 작업별 성능이 전이되지 않는다는 사실은 같은 문서 `GENPERF01` 항목을 보세요.

### 2) 코드를 고치지 않고 모델을 바꾼다 (기술 1.2.2) {#dynamic}

> 🧠 원리: 「코드 수정 없이」라는 조건이 붙으면 답은 **구성과 라우팅 계층**입니다. 공식 기술이 드는 예시가 그 계층의 이름입니다 — **Lambda · API Gateway · AppConfig**.

**AWS AppConfig** — 공식 첫 문장이 `safely change application behavior in production without redeploying code`입니다.

- **기능 플래그**와 동적 자유 형식 구성으로 애플리케이션 실행 방식을 **실시간으로** 제어합니다.
- **차단 목록·허용 목록·제한값·로깅 수준**을 배포 없이 즉시 바꿉니다.
- 구성 저장소를 네 곳에서 가져옵니다 — **AppConfig 호스팅 구성 저장소 · Secrets Manager · Systems Manager Parameter Store · Amazon S3**.
- 점진적 출시: 특정 사용자에게 **단계적으로** 내보내고 영향을 관찰한 뒤 확대합니다. 문제가 생기면 **즉시 되돌립니다**.
- ⭐ **AppConfig 실험**으로 프로덕션 트래픽에서 A/B 테스트를 돌립니다. 가설 정의 → 대상 지정 → 트래픽 분할 → 노출 확대를 CloudWatch 등으로 관찰하면서 합니다. 에이전트가 지원하는 컴퓨팅이면 어디서나 동작합니다(EC2 · Lambda · ECS · EKS).

**Bedrock 지능형 프롬프트 라우팅** — 단일 서버리스 엔드포인트가 요청마다 **각 모델의 응답 품질을 예측**해 가장 좋은 쪽으로 보냅니다.

- **기본 라우터**(Bedrock 제공, 사전 구성)와 **구성 라우터**(내가 정의)가 있습니다. 공식은 **기본 라우터로 먼저 실험**하라고 권합니다.
- 폴백 모델과 응답 품질 차이 기준을 둡니다.
- ⚠️⚠️ **같은 모델 패밀리 안에서만** 라우팅합니다. 「서로 다른 제공자의 모델 사이에서 품질로 라우팅한다」는 보기는 거짓입니다.
- ⚠️ **영어 프롬프트에만 최적화**돼 있습니다.

⚠️ **셋을 섞지 않습니다** — AppConfig는 **내 코드가 어느 모델을 부를지 바꾸는 구성**이고, 프롬프트 라우팅은 **Bedrock이 대신 고르는 엔드포인트**이고, Lambda·API Gateway는 **그 결정을 감싸는 추상화 계층**입니다.

### 3) 끊겨도 돌게 만든다 (기술 1.2.3) {#resilience}

> 🧠 원리: 복원력은 「재시도하면 된다」가 아닙니다. **어떤 오류에 재시도하고, 어떤 오류에 포기하고, 어디로 빠져나가는가**를 정해 둔 것입니다.

**Step Functions 오류 처리** — 공식이 적는 성질:

- `Pass`·`Wait`를 **제외한 모든 상태**가 런타임 오류를 만날 수 있습니다. 원인은 셋 — **상태 머신 정의 문제**(매칭 규칙 없는 Choice) · **작업 실패**(Lambda 예외) · **일시적 문제**(네트워크 분단).
- ⚠️⚠️ **상태가 오류를 보고하면 Step Functions는 기본적으로 전체 상태 머신 실행을 실패시킵니다.**
- ⚠️⚠️ **Catcher는 `Task`·`Parallel`·`Map` 상태에만 있고 최상위 상태 머신 실행 실패에는 없습니다.** 그런 실패를 다루려면 **호출자가 처리**하거나, 그 실행을 **자식 워크플로로 중첩**해 부모가 잡거나, EventBridge 버스로 **`TIMED_OUT` 이벤트를 수신**해 조치합니다.
- 오류 이름은 **대소문자를 구분하는 문자열**이고 내장 이름은 **`States.` 접두사**로 시작합니다. 내가 만드는 오류 이름은 그 접두사를 쓸 수 없습니다.
- ⚠️ **`States.ALL`은 Catcher 안에 단독으로만 와야 하고 `States.DataLimitExceeded`(종단 오류)와 `Runtime` 오류 유형을 잡지 못합니다.** 그 둘은 `ErrorEquals`에 **명시적으로 적어야** 잡거나 재시도할 수 있습니다.
- 재시도는 `BackoffRate`·`MaxDelaySeconds`로 조절하고, 「`States.Timeout`만 제외하고 전부 재시도」 같은 패턴을 쓸 수 있습니다.
- ⚠️ 프로덕션 코드는 **Lambda 서비스 예외**(`Lambda.ServiceException`·`Lambda.SdkClientException`)를 처리해야 합니다.

⭐ 기술 본문이 드는 **「서킷 브레이커 패턴」**은 이 장치들의 조합입니다 — 보수적인 재시도 한도 + 지수 백오프 + **catch로 실패를 격리(quarantine) 경로로 보내기**(무한 재시도 금지), 그리고 임계 초과 시 **EventBridge가 이벤트를 내보내** 경보와 자동 교정을 트리거하는 것입니다. 에이전트 쪽 상세는 깊이 노트 `94` §8-2에 있습니다.

**Bedrock 크로스 리전 추론** — 리전별 가용성이 제한된 모델을 쓰는 공식 수단입니다.

| | **지리형(Geographic)** | **글로벌(Global)** |
|---|---|---|
| 데이터 레지던시 | **지리적 경계 안**(US·EU·APAC 등) | 지원되는 **모든 상용 리전** |
| 요청 라우팅 | 그 지리 안에서 | 전 세계 |
| 비용 | 표준 요금 | ⭐ **약 10% 절감** |
| SCP 요구 | 프로필의 **모든 대상 리전을 허용** | **`"aws:RequestedRegion": "unspecified"`를 허용** |
| 권장 | **규정 준수 요구가 있을 때** | **비용 최적화를 우선할 때** |

공식이 적는 일반 고려 사항:

- **추가 라우팅 비용이 없고** 요금은 **추론 프로필을 호출한 리전** 기준으로 계산됩니다.
- ⚠️⚠️ **계정에서 수동으로 활성화하지 않은 리전으로도 라우팅될 수 있습니다** — 크로스 리전 추론이 동작하는 데 수동 리전 활성화가 필요하지 않습니다.
- 모든 데이터는 **AWS 네트워크에 머물고 퍼블릭 인터넷을 지나지 않으며** 리전 간 전송 중 암호화됩니다.
- ⭐ **CloudTrail은 모든 크로스 리전 추론 요청을 소스 리전에 기록**하고 **`additionalEventData.inferenceRegion`** 필드로 **어디서 처리됐는지** 알려 줍니다.
- ⚠️⚠️ **추론 프로필은 프로비저닝 처리량을 지원하지 않습니다.** 처리량을 늘리려면 PT를 사는데, 그 둘을 함께 쓸 수 없습니다.
- 가용성 목표를 맞추려면 **경계가 있는 재시도 + 다중 리전·다중 모델 폴백**을 애플리케이션에 둡니다(공식 권고).

### 4) 내 모델을 올리고 수명 주기를 관리한다 (기술 1.2.4) {#customization}

> 🧠 원리: 사용자 지정 모델은 **만드는 것과 서빙하는 것이 별개**입니다. 그래서 「미세 조정했는데 호출이 안 된다」가 가장 흔한 사고입니다.

⚠️⚠️ **사용자 지정 모델 추론 경로는 둘입니다**(공식 `model-customization-use.html`):

1. **프로비저닝 처리량 구매** — 전용 컴퓨팅 용량을 사서 **보장된 처리량**으로 일관된 성능과 낮은 지연을 얻습니다.
2. **온디맨드 추론용 배포** — **사용자 지정 모델 배포**를 만들어 올립니다. **쓴 만큼만 내고 프로비저닝된 컴퓨팅을 세울 필요가 없습니다.** 호출할 때는 **그 배포의 ARN을 `modelId`로** 씁니다.

- ⚠️⚠️ **온디맨드 배포는 리전이 제한됩니다** — 공식이 **미국 동부(버지니아 북부)**와 **미국 서부(오리건)**를 적습니다.
- 「사용자 지정 모델을 쓰려면 반드시 프로비저닝 처리량을 사야 한다」는 서술은 **거짓**입니다.

**LoRA와 어댑터** — 공식이 적는 성질:

- **LoRA**는 **고정된(frozen) 기본 모델 위에 작은 어댑터 가중치 집합만 훈련**하는 파라미터 효율적 미세 조정 기법입니다.
- ⭐ **하나의 엔드포인트에서 단일 기본 모델을 공유하는 여러 어댑터를 서빙할 수 있습니다.** 미세 조정 변형마다 모델 복사본을 따로 배포하는 것보다 **비용 효율적**입니다. SageMaker AI의 **멀티 어댑터 배포**는 같은 엔드포인트에 **어댑터당 추론 구성 요소 하나**를 두는 모양이고, 권장 구성은 **기본 모델과 어댑터의 메모리를 함께** 검증합니다.
- LoRA 어댑터 계층은 추론 시 가중치를 수정하면서 **원래 모델 파라미터는 그대로 둡니다**. 공식은 빠른 훈련, 기본 모델 성능이 이미 충분할 때, **작은 작업별 데이터세트**의 지시 미세 조정에 맞다고 적습니다.
- ⭐ **갈림길이 하나 명시돼 있습니다** — **Bedrock 사용자 지정 데이터 한도를 넘는 큰 레이블 데이터세트**가 있으면 **SageMaker AI의 LoRA PEFT**로 더 나은 결과를 낼 수 있습니다.

**SageMaker 모델 레지스트리** — 버전 관리와 롤백의 자리입니다.

- 구조는 **모델(패키지) 그룹** + 각 그룹 안의 **모델 패키지**이고, 그룹은 선택적으로 **컬렉션**에 넣습니다.
- 버전은 **1부터 시작해 새 패키지가 추가될 때마다 1씩 증가**합니다.
- ⚠️⚠️ **모델 패키지가 두 종류입니다** — **AWS Marketplace용**과 **모델 레지스트리용**. **Marketplace 쪽은 버전 관리 대상이 아니고 모델 그룹에 연결되지 않습니다.** 레지스트리용 패키지는 **버전이 있고 반드시 모델 그룹에 연결돼야** 합니다.
- 제공되는 수명 주기 작업: 버전 등록 · **승인 상태 업데이트** · 버전 비교 · **스테이징 구성** · 배포 이력 보기 · 계보(lineage) 보기 · **교차 계정 검색 가능성**.

⚠️ 「자동 배포 파이프라인 · 실패한 배포 롤백 · 모델 사용 중지와 교체」는 이 레지스트리의 **승인 상태와 버전**을 축으로 구성합니다. 승인된 버전만 배포 단계로 넘기고, 문제가 생기면 **이전 버전으로 엔드포인트를 되돌립니다**.

---

## ✍️ 시험 포인트

- 「코드 수정 없이」가 보이면 **AppConfig(구성) · 프롬프트 라우팅(Bedrock이 고름) · 추상화 계층(Lambda·API Gateway)** 중 어느 층을 묻는지 가립니다.
- 「리전별 가용성이 제한된 모델」이 보이면 **크로스 리전 추론**이고, **데이터 레지던시**가 조건에 있으면 **지리형**입니다.
- 「비용을 10% 아끼면서 전 세계로」가 보이면 **글로벌**이고, **SCP에 `unspecified`를 허용**해야 합니다.
- 「처리량을 보장해야 한다」와 「크로스 리전 추론」이 **함께** 나오면 함정입니다 — 추론 프로필은 PT를 지원하지 않습니다.
- 「미세 조정한 모델을 호출할 수 없다」가 보이면 **PT를 샀는가 / 온디맨드 배포를 만들었는가**를 봅니다.
- 「최상위 실행이 실패해도 잡아야 한다」가 보이면 **Catcher가 아니라** 자식 워크플로 중첩이나 EventBridge입니다.
- 「Marketplace에서 가져온 모델 패키지의 버전을 비교한다」는 거짓입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **프롬프트 라우팅이 제공자를 넘나든다고 읽기.** 같은 **모델 패밀리** 안입니다.
- ⚠️ **프롬프트 라우팅을 다국어 워크로드에 그대로 적용하기.** 공식은 **영어에 최적화**라고 적습니다.
- ⚠️⚠️ **`States.ALL`이 모든 오류를 잡는다고 생각하기.** `States.DataLimitExceeded`와 `Runtime`은 못 잡습니다.
- ⚠️ **Catch만 달아 두고 최상위 실패를 덮었다고 생각하기.**
- ⚠️⚠️ **크로스 리전 추론을 쓰려면 대상 리전을 계정에서 켜야 한다고 생각하기.** 수동 활성화는 필요하지 않습니다.
- ⚠️ **크로스 리전 요청을 처리 리전의 CloudTrail에서 찾기.** 기록은 **소스 리전**에 남고 처리 리전은 **`additionalEventData.inferenceRegion`**에 있습니다.
- ⚠️⚠️ **「사용자 지정 모델은 PT 필수」로 외우기.** 온디맨드 배포 경로가 있습니다(단, **두 리전**).
- ⚠️ **모델 레지스트리 버전이 0부터 시작한다고 생각하기.** **1부터** 증가합니다.

---

## 🧪 자가 점검

**Q1.** 규정 준수 때문에 데이터가 EU를 벗어나면 안 되는데, 쓰려는 모델이 한 리전에서 용량이 부족합니다. 무엇을 쓰고, SCP는 어떻게 둡니까?

<details><summary>정답 보기</summary>

**지리형(Geographic) 크로스 리전 추론**을 씁니다 — 요청이 그 지리 경계 안에서만 라우팅됩니다. SCP는 **프로필에 든 모든 대상 리전을 허용**하도록 둡니다. 글로벌 프로필은 약 10% 저렴하지만 전 세계로 라우팅되고 SCP에 **`"aws:RequestedRegion": "unspecified"`**를 허용해야 하므로 데이터 레지던시 요구와 맞지 않습니다.
</details>

**Q2.** 크로스 리전 추론으로 처리량을 보장받으려고 프로비저닝 처리량을 함께 구매하려 합니다. 무엇이 문제입니까?

<details><summary>정답 보기</summary>

**추론 프로필은 프로비저닝 처리량을 지원하지 않습니다.** 보장된 처리량이 필요하면 PT를, 리전 용량을 흡수하려면 크로스 리전 추론을 선택하고, 가용성 목표는 **경계가 있는 재시도 + 다중 리전·다중 모델 폴백**으로 맞춥니다.
</details>

**Q3.** 미세 조정한 Bedrock 사용자 지정 모델을 만들었는데 호출이 되지 않습니다. 가능한 두 가지 해결 경로는 무엇입니까?

<details><summary>정답 보기</summary>

**① 프로비저닝 처리량을 구매**해 전용 용량을 두거나, **② 온디맨드 추론용 사용자 지정 모델 배포를 만들고 그 배포의 ARN을 `modelId`로** 호출합니다. ⚠️ 온디맨드 배포는 **미국 동부(버지니아 북부)·미국 서부(오리건)**에서만 됩니다.
</details>

**Q4.** 변형이 20개인 미세 조정 모델을 서빙해야 하는데 비용이 걱정됩니다. LoRA가 어떻게 돕습니까?

<details><summary>정답 보기</summary>

LoRA는 **고정된 기본 모델 위에 작은 어댑터 가중치만** 훈련하므로, **하나의 엔드포인트에서 단일 기본 모델을 공유하는 여러 어댑터를 서빙**할 수 있습니다. 변형마다 모델 복사본을 따로 배포하는 것보다 비용 효율적이고, SageMaker AI의 멀티 어댑터 배포는 **어댑터당 추론 구성 요소 하나**를 같은 엔드포인트에 둡니다.
</details>

**Q5.** Step Functions 워크플로의 최상위 실행이 실패하는 경우를 처리해야 합니다. `Catch`를 어디에 달면 됩니까?

<details><summary>정답 보기</summary>

**어디에도 달 수 없습니다.** Catcher는 **`Task`·`Parallel`·`Map` 상태에만** 있고 **최상위 상태 머신 실행 실패에는 없습니다.** 호출자가 오류를 처리하거나, 그 실행을 **자식 워크플로로 중첩**해 부모에서 잡거나, EventBridge 버스로 **`TIMED_OUT` 이벤트를 수신**해 조치합니다.
</details>

**Q6.** AWS Marketplace에서 가져온 모델 패키지들의 버전을 모델 그룹에서 비교하려 합니다. 무엇이 문제입니까?

<details><summary>정답 보기</summary>

**Marketplace용 모델 패키지는 버전 관리되는 엔터티가 아니고 모델 레지스트리의 모델 그룹에 연결되지 않습니다.** 버전 비교·승인 상태·스테이징은 **레지스트리용 모델 패키지**에서만 가능하고, 그 패키지는 반드시 모델 그룹에 연결돼야 하며 버전이 **1부터 1씩** 증가합니다.
</details>

**Q7.** 운영 중에 모델을 더 싼 것으로 바꿔 보고, 문제가 생기면 즉시 되돌리려 합니다. 재배포 없이 하려면 무엇을 씁니까?

<details><summary>정답 보기</summary>

**AWS AppConfig**의 기능 플래그입니다 — 코드를 재배포하지 않고 동작을 바꾸고, 특정 사용자에게 **단계적으로** 내보내 영향을 관찰하고, 문제가 생기면 **즉시 비활성화**합니다. 프로덕션 트래픽으로 A/B를 돌리려면 **AppConfig 실험**을 씁니다.
</details>

---

### 📌 출처

1. Evaluate the performance of Amazon Bedrock resources (평가 네 종류 · 평가 대상 모델 유형 여섯) — `docs.aws.amazon.com/bedrock/latest/userguide/evaluation.html` (2026-11-14 확인)
2. Understanding intelligent prompt routing in Amazon Bedrock (같은 패밀리 · 영어 최적화 · 기본/구성 라우터) — `docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html` (2026-11-14 확인)
3. What is AWS AppConfig? (재배포 없는 변경 · 구성 저장소 네 곳 · 실험) — `docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html` (2026-11-14 확인)
4. Handling errors in Step Functions workflows (기본 전체 실패 · Catcher 범위 · `States.ALL`의 예외) — `docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html` (2026-11-14 확인)
5. Route model inference requests across AWS Regions with cross-Region inference (지리형 ↔ 글로벌 · PT 미지원 · `inferenceRegion`) — `docs.aws.amazon.com/bedrock/latest/userguide/cross-region-inference.html` (2026-11-14 확인)
6. Set up inference for a custom model (추론 경로 둘) — `docs.aws.amazon.com/bedrock/latest/userguide/model-customization-use.html` (2026-11-14 확인)
7. Deploy a custom model for on-demand inference (배포 ARN을 `modelId`로 · 두 리전) — `docs.aws.amazon.com/bedrock/latest/userguide/deploy-custom-model-on-demand.html` (2026-11-14 확인)
8. Model Registry Models, Model Versions, and Model Groups (그룹·버전·승인 상태 · Marketplace 패키지의 차이) — `docs.aws.amazon.com/sagemaker/latest/dg/model-registry-models.html` (2026-11-14 확인)
9. Get recommendations for models with LoRA adapters (멀티 어댑터 배포) — `docs.aws.amazon.com/sagemaker/latest/dg/generative-ai-inference-recommendations-adapters.html` (2026-11-14 확인)
10. SFT on Nova 1.0 (PEFT · LoRA) (LoRA PEFT 용례와 Bedrock 한도 갈림길) — `docs.aws.amazon.com/nova/latest/userguide/nova-sft-1.html` (2026-11-14 확인)
