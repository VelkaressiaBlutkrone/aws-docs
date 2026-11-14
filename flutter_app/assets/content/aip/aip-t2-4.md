---
examGuideTaskId: aip-t2-4
certCode: AIP-C01
domain: 2
domainName: 구현 및 통합
domainWeightPct: 26
title: FM API 통합 (동기와 비동기·요청 검증·스트리밍과 WebSocket·복원력·모델 라우팅)
coversTasks:
  - "2.4"
sources:
  - title: Amazon Bedrock Converse API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
  - title: Amazon Bedrock ConverseStream API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ConverseStream.html
  - title: 배치 추론으로 여러 프롬프트 처리
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html
  - title: SageMaker 비동기 추론
    url: https://docs.aws.amazon.com/sagemaker/latest/dg/async-inference.html
  - title: API Gateway REST API의 요청 검증
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html
  - title: API Gateway WebSocket API 개요
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-websocket-api-overview.html
  - title: API Gateway 프록시 통합의 응답 스트리밍
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html
  - title: API Gateway REST API 요청 스로틀링
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html
  - title: AWS SDK의 재시도 동작
    url: https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html
  - title: AWS X-Ray 개요
    url: https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html
  - title: AgentCore Gateway의 라우팅 규칙과 폴백
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rules-fallback.html
  - title: Amazon Bedrock 지능형 프롬프트 라우팅
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html
  - title: Step Functions 워크플로의 오류 처리
    url: https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
lastVerified: 2026-11-14
---

# FM API 통합 (동기와 비동기·요청 검증·스트리밍과 WebSocket·복원력·모델 라우팅)

> **커버하는 공식 Task** — AIP-C01 · 도메인 2 「구현 및 통합」(26%) · **작업 2.4 FM API 통합 구현** (`aip-t2-4`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(2.4.1~2.4.4)를 모두 덮습니다. ⚠️ 작업 2.5와 축이 겹치는 자리는 **소유권을 갈라 뒀습니다** — 이 문서가 **모델 쪽 API 계약**(동기·스트리밍·비동기)과 **클라이언트 쪽 복원력**을 소유하고, **API Gateway 응답 전송 모드의 제약**은 작업 2.5가 봅니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 동기·스트리밍·비동기 **호출 경로 셋**을 요구 조건으로 가를 수 있다
- [ ] API Gateway 요청 검증이 **확인하는 것과 확인하지 않는 것**을 안다
- [ ] 스트리밍 지원 여부를 **어떻게 확인**하고 권한이 무엇인지 안다
- [ ] WebSocket API의 **라우트 셋과 연결 수명**을 안다
- [ ] SDK 재시도 모드 셋과 **adaptive를 쓰면 안 되는 조건**을 안다
- [ ] API Gateway 스로틀링의 **적용 순서**를 안다
- [ ] 폴백과 서킷 브레이커가 **어디까지 자동인지** 안다
- [ ] 모델 라우팅 수단 셋의 **제약**을 가를 수 있다

---

## 🎯 왜 중요한가

GenAI 애플리케이션에서 FM API 통합의 실패는 대부분 **「어느 호출 경로였나」에서 갈립니다.** 같은 모델을 부르는데도 동기 호출은 **타임아웃**에 걸리고, 스트리밍은 **시작된 뒤 폴백이 불가능**하고, 비동기는 **결과를 S3에서 가져와야** 합니다.

공식 기술 넷이 그 경로들을 각각 집고, 마지막 하나(2.4.4)가 **그 사이를 고르는 로직**을 묻습니다. 그래서 이 작업은 서비스 이름보다 **계약의 경계**를 외우는 자리입니다.

---

## ⚡ 시험 직전 요약

- 동기 호출의 결과 해석은 **`stopReason`**이 쥡니다 — **`max_tokens`**면 모델이 멈춘 것이 아니라 **내 설정에 걸려 잘린** 것입니다.
- ⚠️⚠️ **스트리밍 지원 여부는 `GetFoundationModel`의 `responseStreamingSupported` 필드**로 확인하고, **AWS CLI는 Bedrock의 스트리밍 작업을 지원하지 않습니다.**
- ⚠️⚠️ `ConverseStream`의 권한은 **`bedrock:InvokeModelWithResponseStream`**입니다. 추론을 완전히 막으려면 **`bedrock:InvokeModel`과 `bedrock:InvokeModelWithResponseStream` 둘 다 거부**해야 합니다.
- ⚠️ Prompt management의 프롬프트를 쓰면 **`inferenceConfig`·`system`·`toolConfig`·`additionalModelRequestFields`를 요청에 넣을 수 없습니다** — Prompt management에서 정의합니다.
- API Gateway 요청 검증은 실패 시 **즉시 400을 반환하고 CloudWatch Logs에 결과를 게시**해 **백엔드 호출을 줄입니다**. ⚠️⚠️ 필수 파라미터는 **존재만 확인하고 유형·형식은 확인하지 않습니다.**
- ⚠️ 페이로드 검증은 **일치하는 콘텐츠 유형이 없으면 수행되지 않습니다**(`$default`로 두면 콘텐츠 유형과 무관하게 같은 모델을 씁니다).
- WebSocket API는 **상태 유지 양방향**이고 미리 정의된 라우트가 **`$connect`·`$disconnect`·`$default`**입니다. ⚠️⚠️ **유휴 10분 또는 최대 2시간 연결 수명**에서 **1001**로 닫히고 **바이너리 미디어 유형은 지원되지 않습니다**(1003).
- SDK 재시도 기본은 **standard**(지수 백오프 + 지터 + **재시도 쿼터**)이고 `max_attempts` 기본은 **3**(초기 1 + 재시도 2, **1이면 재시도 없음**). ⚠️⚠️ **adaptive는 초기 요청까지 지연·차단**하고 **클라이언트 인스턴스 단위**라 **여러 리소스를 쓰는 클라이언트에는 권장되지 않습니다.**
- ⚠️⚠️ API Gateway 스로틀·쿼터는 **최선 노력이고 보장된 상한이 아닙니다.** 적용 순서는 **사용량 계획(클라이언트·메서드) → 스테이지 메서드 → 계정 수준 → AWS 리전**입니다.
- ⚠️ **스트리밍 응답이 시작된 뒤에는 폴백할 수 없습니다** — 호출자는 **부분 응답과 오류**를 받습니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **`stopReason`** | 모델이 왜 생성을 멈췄는지 알려 주는 응답 필드 |
| **요청 검증기** | 검증 규칙을 담아 API 메서드에 할당하는 API Gateway 리소스 |
| **라우트 선택 표현식** | WebSocket 메시지에서 어느 라우트로 보낼지 정하는 API 수준 설정 |
| **재시도 쿼터** | 재시도마다 토큰을 차감하고 성공하면 보충하는 SDK의 토큰 버킷 |
| **지터(jitter)** | 재시도 간격에 무작위를 섞어 동시 재시도를 흩는 기법 |
| **토큰 버킷** | 속도·버스트를 토큰 보충 속도와 버킷 용량으로 표현하는 알고리즘 |
| **폴백** | 1차 목적지가 실패했을 때 순서대로 시도하는 대체 목적지 |

---

## 📖 핵심 개념

### 1) 유연한 모델 상호 작용 — 동기·비동기·요청 검증 (기술 2.4.1) {#interaction}

> 🧠 원리: 같은 프롬프트를 보내는 방법이 셋입니다 — **기다린다**(동기), **흘려받는다**(스트리밍), **맡기고 나중에 받는다**(비동기). 고르는 기준은 모델이 아니라 **응답을 기다릴 수 있는 시간과 페이로드 크기**입니다.

**동기 호출** — `Converse`가 메시지를 지원하는 모든 Bedrock 모델에 **일관된 API**를 줍니다. 한 번 쓴 코드를 다른 모델에 쓸 수 있고, 모델 고유 파라미터는 따로 넘깁니다. 응답에서 반드시 보는 것이 **`stopReason`**입니다 — ⚠️ **`max_tokens`면 내 설정에 걸려 잘린 것**이고 모델이 끝맺은 것이 아닙니다.

**비동기 경로는 AWS 관리형이 둘입니다.**

| 경로 | 계약 |
|---|---|
| **Bedrock 배치 추론** | 입력 파일을 **S3**에 올려 작업을 제출하고 결과를 S3에서 회수한다. 형식은 **`InvokeModel` 또는 `Converse` 형식**. ⭐ 폴링 대신 **EventBridge로 상태 변경 알림** |
| **SageMaker 비동기 추론** | 페이로드를 **S3에 두고 포인터**를 넘기면 **식별자와 출력 위치를 즉시 반환**하고, 결과가 S3에 들어오며 통지는 **SNS**다 |

- ⚠️ 「SDK와 큐로 비동기 처리」는 **애플리케이션 패턴**입니다 — API 계층이 요청을 큐에 넣고 즉시 수락 응답을 돌려주며 워커가 모델을 부릅니다. 위 둘과 달리 **진행 상태·재시도·결과 저장을 내가 설계**해야 합니다.
- ⚠️ 배치 추론의 제약 둘: **프로비저닝된 모델에서 지원되지 않고**, `Converse` 호출 유형에서는 **도구 호출을 지원하지 않습니다**(`toolConfig`가 든 레코드는 **400**).

**요청 검증**(API Gateway) — 통합 요청으로 넘어가기 **전에** 기본 검증을 합니다. 실패하면 **즉시 400을 반환하고 검증 결과를 CloudWatch Logs에 게시**합니다. ⭐ 공식이 적는 값은 **불필요한 백엔드 호출을 줄이고** 애플리케이션 고유 검증에 집중하게 하는 것입니다.

검증하는 것은 둘입니다:

- **URI·쿼리 문자열·헤더의 필수 요청 파라미터**가 포함되고 비어 있지 않은지. ⚠️⚠️ **존재만 확인하고 유형이나 형식은 확인하지 않습니다.**
- 요청 페이로드가 **해당 콘텐츠 유형에 구성된 JSON 스키마**를 따르는지. ⚠️⚠️ **일치하는 콘텐츠 유형이 없으면 요청 검증이 수행되지 않습니다** — 콘텐츠 유형과 무관하게 같은 모델을 쓰려면 데이터 모델의 콘텐츠 유형을 **`$default`**로 둡니다.

켜는 절차는 **요청 검증기에 규칙을 적고 → API의 검증기 맵에 추가하고 → 개별 메서드에 할당**하는 것입니다. ⚠️ 그리고 **요청 본문 검증과 「매핑 템플릿 없는 페이로드의 메서드 요청 동작」은 별개 주제**입니다 — 모델 스키마가 일치하지 않을 때 원본 페이로드를 **패스스루할지 차단할지**는 그쪽에서 정합니다.

### 2) 실시간 상호 작용 — 스트리밍 (기술 2.4.2) {#realtime}

> 🧠 원리: 「빨라 보이게」 만드는 것은 **총 시간 단축이 아니라 첫 토큰까지의 시간 단축**입니다. 그래서 실시간 설계의 전부는 **토큰이 나오는 쪽부터 사용자 화면까지 끊김 없이 흐르게 하는 것**이고, 그 길에 **세 계층의 계약**이 있습니다.

**① 모델 쪽** — `ConverseStream`이 응답을 스트림으로 돌려줍니다.

- ⚠️⚠️ **모델이 스트리밍을 지원하는지는 `GetFoundationModel`을 불러 `responseStreamingSupported` 필드로 확인**합니다. 모델마다 다릅니다.
- ⚠️⚠️ **AWS CLI는 Bedrock의 스트리밍 작업을 지원하지 않습니다**(`ConverseStream` 포함) — 콘솔·CLI로 검증하려다 막히는 자리입니다.
- ⚠️⚠️ 필요한 권한은 **`bedrock:InvokeModelWithResponseStream`**입니다. 그리고 특정 모델에 대한 추론을 완전히 막으려면 **`bedrock:InvokeModel`과 `bedrock:InvokeModelWithResponseStream` 둘 다 거부**해야 합니다 — 하나만 거부하면 다른 경로로 열립니다.
- 요청에 **`guardrailConfig.streamProcessingMode`**(가드레일이 스트림을 어떻게 처리할지)와 **`performanceConfig.latency`** 같은 설정을 함께 넘길 수 있습니다.
- ⚠️ Prompt management의 프롬프트 버전 ARN을 쓰면 **`additionalModelRequestFields`·`inferenceConfig`·`system`·`toolConfig`를 요청에 넣을 수 없습니다** — 그 필드들은 **Prompt management에서 정의**해야 합니다.
- Bedrock은 **제공한 텍스트·이미지·문서를 저장하지 않습니다**(응답 생성에만 씁니다).

**② 전송 계층** — 클라이언트에 흘려보내는 방법이 둘입니다.

- **서버 전송 이벤트(SSE)·청크 전송** — 단방향으로 충분할 때입니다. API Gateway 쪽에서는 프록시 통합의 **응답 전송 모드를 `STREAM`**으로 두면 응답이 완전히 계산되기를 기다리지 않습니다. ⚠️ 그 계약과 포기하는 기능은 **작업 2.5**가 소유합니다(REST 전용 · 프록시 통합만 · 캐싱·콘텐츠 인코딩·VTL 변환 불가).
- **WebSocket API** — **상태 유지 양방향**이 필요할 때입니다. REST와 달리 **백엔드가 연결된 클라이언트에 콜백 메시지를 보낼 수 있습니다.**

**WebSocket의 계약**:

| 축 | 내용 |
|---|---|
| 라우팅 | 들어오는 **JSON** 메시지를 **라우트**로 보낸다. ⚠️ **비JSON 메시지는 `$default` 라우트**로 간다 |
| 라우트 선택 | `routeSelectionExpression`은 **API 수준 속성**이고 메시지 페이로드의 JSON 속성을 지정한다(예: `${request.body.action}`) |
| 미리 정의된 라우트 | **`$connect`**(연결 시작) · **`$disconnect`**(연결 종료) · **`$default`**(표현식을 평가할 수 없거나 일치 라우트가 없을 때) |
| 역방향 전송 | 통합 응답 + 라우트 응답, 또는 **`@connections` API로 POST** |

- ⚠️⚠️ 연결 수명이 시험 포인트입니다 — **클라이언트가 10분 유휴이거나 최대 2시간 연결 수명에 도달하면 `1001`**로 닫힙니다. 긴 대화를 WebSocket 하나로 유지하려는 설계는 여기 걸립니다.
- ⚠️⚠️ **WebSocket API는 바이너리 미디어 유형을 지원하지 않습니다** — 엔드포인트가 받으면 **`1003`**입니다. 그 밖에 **`1008`**(특정 클라이언트의 요청 과다) · **`1009`**(메시지가 너무 큼) · **`1011`**(내부 오류) · **`1012`**(서비스 재시작)가 있습니다.

### 3) 복원력이 뛰어난 FM 시스템 (기술 2.4.3) {#resilience}

> 🧠 원리: FM 호출은 **스로틀링과 일시 오류가 정상 운영의 일부**입니다. 그래서 복원력은 「실패하지 않게」가 아니라 **「실패를 어떻게 흡수하고 언제 포기하는가」**입니다. 포기하지 않는 재시도가 장애를 키웁니다.

**① SDK 재시도** — 모드가 셋입니다.

| 모드 | 성질 |
|---|---|
| **standard**(기본) | 지수 백오프 + **지터**. 일시 오류는 짧은 지연, 스로틀링 오류는 긴 지연. **재시도 쿼터**를 쓴다 |
| **adaptive** | standard에 **클라이언트 측 속도 제한기**를 더한다. ⚠️⚠️ **초기 요청도 지연·차단할 수 있다** |
| **legacy** | 표준화된 재시도 쿼터가 없어 **중단 중에도 전속력으로 재시도**한다. 하위 호환용 |

- **재시도 쿼터**는 토큰 버킷입니다 — 재시도마다 토큰을 차감하고 **요청이 성공하면 보충**합니다. 토큰이 소진되면 **재시도하지 않고 오류를 반환**해 애플리케이션이 **빠르게 실패**합니다. ⭐ 재시도 트래픽을 줄여 **서비스 장애가 더 빨리 해소되게** 돕습니다. ⚠️ 쿼터는 **초기 요청을 지연·차단하지 않습니다**(재시도만).
- **adaptive를 쓰는 조건**: 클라이언트가 **단일 리소스**를 향하고 **빈번한 스로틀링**을 예상할 때입니다 — ⭐ 공식이 그 예로 **한 API 작업을 고용량으로 부르는 AI 워크로드**를 직접 듭니다.
- ⚠️⚠️ **쓰지 말아야 하는 조건**: 클라이언트가 **여러 리소스·여러 테넌트**를 향할 때입니다 — 속도 제한기는 **SDK 클라이언트 인스턴스 단위**라, 한 리소스의 스로틀링이 **무관한 리소스로 가는 요청까지 늦춥니다.** 초기 요청의 예측 가능한 지연이 필요할 때도 아닙니다. 공식이 **일반 기본값으로 권장하지 않는다**고 적습니다.
- 설정은 **`AWS_RETRY_MODE`/`retry_mode`**(기본 `standard`)와 **`AWS_MAX_ATTEMPTS`/`max_attempts`**(기본 **3** = 초기 1회 + 재시도 2회)이고 **1로 두면 재시도가 비활성**됩니다. ⚠️ **DynamoDB·DynamoDB Streams 클라이언트는 기본 4회**이고 기본 백오프가 **25ms**(다른 서비스 50ms)입니다. 우선순위는 **코드의 명시적 클라이언트 구성 > 환경 변수 > 공유 구성 파일**입니다.
- ⚠️⚠️ 이 동작은 **`AWS_NEW_RETRIES_2026=true`로 옵트인**해야 적용됩니다 — 설정하지 않으면 **2026 이전 동작**(백오프 타이밍 · 재시도 쿼터 비용 · 서비스별 기본값이 다릅니다)입니다. 「기본값이 이렇다」를 환경 확인 없이 단정하면 틀립니다.

**② 속도 제한**(API Gateway) — 토큰 버킷 알고리즘으로 **계정 내 전 API를 리전별로** 봅니다. 초과하면 클라이언트가 **`429 Too Many Requests`**를 받습니다.

- ⚠️⚠️ **스로틀과 쿼터는 최선 노력(best-effort)이고 보장된 상한이 아니라 목표로 생각해야 합니다.**
- 네 종류: **AWS 스로틀링 한도**(리전의 전 계정·클라이언트, **고객이 바꿀 수 없다**) · **계정별 한도**(증액 요청 가능 — ⭐ **타임아웃이 짧고 페이로드가 작은 API에서 더 높은 한도가 가능**하다) · **API별·스테이지별**(메서드 수준) · **클라이언트별**(사용량 계획의 API 키, **계정별 한도보다 높을 수 없다**).
- ⚠️ **적용 순서 넷**: ① 사용량 계획의 **클라이언트별·메서드별** → ② 스테이지의 **메서드별** → ③ **리전별 계정 수준** → ④ **AWS 리전 스로틀링**.
- 사용량 계획에서 정하는 둘: **스로틀링 속도**(토큰이 버킷에 더해지는 초당 속도) · **스로틀링 버스트**(버킷 용량).

**③ 정상적인 성능 저하와 폴백** — 에이전트 경로에서는 Gateway 규칙이 관리형으로 줍니다. `targetFallback`에 **1~2개**의 대체 목적지를 순서대로 두고 `triggerOn`이 떠나는 조건이며, **`circuitBreaker`는 기본 `ENABLED`**로 **지금 실패 중인 목적지를 건너뜁니다**. 체인을 순서대로 걷고 각 목적지를 **한 번** 시도하며, 전부 실패하면 호출자는 **마지막 오류**를 받습니다. ⚠️ **`firstByteTimeoutMilliseconds`**는 공급자가 **깔끔한 오류 없이 멈춰 있을 때**를 위한 것입니다.

- ⚠️⚠️ **스트리밍 응답이 시작된 뒤에는 폴백할 수 없습니다** — 호출자는 **부분 응답과 오류**를 받고 직접 재시도해야 합니다. 기술 2.4.2(스트리밍)와 2.4.3(복원력)이 정면으로 충돌하는 자리이고, 그래서 **첫 토큰이 나가기 전에 폴백 판단이 끝나야** 합니다.
- 오케스트레이션이 Step Functions라면 **`Retry`와 캐처**로 구현합니다. ⚠️ 캐처는 **`Task`·`Parallel`·`Map`에만** 있고 **최상위 실행 실패에는 없습니다** — 자식 워크플로로 중첩하거나 **EventBridge의 `TIMED_OUT` 이벤트**로 다룹니다. 그 계약의 나머지는 작업 2.5가 봅니다.

**④ 관찰성** — **AWS X-Ray**가 서비스 경계를 넘는 호출을 봅니다. 애플리케이션이 받은 요청뿐 아니라 **다운스트림 AWS 리소스·마이크로서비스·데이터베이스·웹 API 호출까지** 보여 주고, **트레이스 맵**으로 **병목과 지연 급증**을 찾습니다. ⚠️ 클라이언트 SDK는 X-Ray로 직접 보내지 않고 **UDP를 듣는 데몬에 JSON 세그먼트 문서를** 보내며 **데몬이 큐에 버퍼링해 배치로 업로드**합니다(데몬은 **Elastic Beanstalk·Lambda 플랫폼에 포함**).

### 4) 지능형 모델 라우팅 (기술 2.4.4) {#routing}

> 🧠 원리: 라우팅은 **정적 → 동적 → 지표 기반**으로 올라갈수록 비싸고 복잡해집니다. 그래서 질문은 「어느 것이 좋은가」가 아니라 **「이 요구 조건에 필요한 최소 수준이 무엇인가」**입니다.

| 수준 | 수단 | 성질 |
|---|---|---|
| **정적 라우팅** | 애플리케이션 코드의 구성 | 작업 유형이 고정이면 가장 단순하고 예측 가능하다 |
| **콘텐츠 기반 동적 라우팅** | **Step Functions** | 입력을 보고 어느 특수 FM으로 보낼지 **상태 머신이 결정**한다. 경로가 **JSON으로 정의**돼 감사 가능하다 |
| **품질 예측 라우팅** | **지능형 프롬프트 라우팅** | 요청마다 **각 모델의 응답 품질을 예측**해 더 좋은 쪽으로 보낸다. **폴백 모델**과 응답 품질 차이 기준을 둔다 |
| **규칙 기반 고정·폴백** | **Gateway 라우팅 규칙** | `matchModels` + `routeToTarget.staticRoute`로 기본 라우팅을 덮어쓰고 **1~2개 대체 목적지**를 둔다 |
| **요청 변환** | **API Gateway** | 라우팅 로직이 기대하는 모양으로 요청을 바꿔 넘긴다 |

- ⚠️⚠️ 지능형 프롬프트 라우팅의 **결정적 제약**: **같은 모델 패밀리 안에서만** 라우팅하고 **영어 프롬프트에 최적화**돼 있습니다. 「패밀리를 넘어 더 싼 모델로」는 이 기능으로 되지 않습니다.
- ⚠️ Gateway 규칙의 세부: 여러 타깃이 같은 모델을 맡으면 기본 라우팅이 **아무 쪽으로나** 보내므로 규칙이 고정합니다. `staticRoute`에 `model`을 적으면 **호출자가 요청한 모델과 다른 모델을 서빙**할 수 있습니다 — 호출자가 모르는 변경이므로 관찰성과 함께 설계합니다.
- 「지표 기반」 라우팅은 **지연·오류율·비용 지표를 보고 경로를 바꾸는 것**이고, 지표는 X-Ray의 트레이스와 서비스별 지표에서 옵니다. ⚠️ 그 판단을 **매 요청에서 하면** 라우팅 자체가 지연이 되므로, 보통 **집계된 신호로 구성을 바꾸는 쪽**이 설계입니다.

---

## ✍️ 시험 포인트

- 「응답이 중간에 끊겼다」면 **`stopReason`**을 보고 **`max_tokens`**인지 확인합니다.
- 「이 모델이 스트리밍을 지원하나」는 **`GetFoundationModel`의 `responseStreamingSupported`**입니다.
- 「CLI로 스트리밍을 테스트한다」는 **안 됩니다.**
- 「추론을 완전히 막아라」면 **`InvokeModel`과 `InvokeModelWithResponseStream` 둘 다** 거부입니다.
- 「필수 헤더가 숫자인지 검증」은 API Gateway 요청 검증으로 **안 됩니다** — **존재만** 봅니다.
- 「검증을 켰는데 본문이 통과한다」면 **콘텐츠 유형이 일치하지 않는** 경우입니다(`$default`를 봅니다).
- 「서버가 클라이언트에 먼저 보내야 한다」면 **WebSocket**이고, 단방향이면 **SSE·`STREAM`**입니다.
- 「연결이 2시간/10분에 끊긴다」면 **1001**이고 정상 동작입니다.
- 「WebSocket으로 이미지 바이트를 보낸다」는 **지원되지 않습니다**(1003).
- 「한 테이블을 고용량으로 부르는 워크로드가 계속 스로틀된다」면 **adaptive**가 맞고, 「여러 리소스를 쓰는 공용 클라이언트」면 **standard**입니다.
- 「재시도를 끄고 싶다」면 **`max_attempts`를 1**로 둡니다.
- 「API 키별로 다른 한도」면 **사용량 계획**이고, 그 한도는 **계정별 한도를 넘을 수 없습니다.**
- 「스트리밍 중 공급자가 죽었다」면 **폴백이 불가능**하고 **부분 응답 + 오류**입니다.
- 「입력을 보고 특수 모델로 보낸다」면 **Step Functions**, 「품질을 예측해 고른다」면 **프롬프트 라우팅**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **`ConverseStream` 권한을 `bedrock:ConverseStream`으로 생각하기.** **`bedrock:InvokeModelWithResponseStream`**입니다.
- ⚠️ **거부 정책을 한 액션만 걸기.** 두 액션을 모두 거부해야 막힙니다.
- ⚠️ **모든 모델이 스트리밍된다고 가정하기.** **`responseStreamingSupported`**를 봅니다.
- ⚠️ **Prompt management 프롬프트와 `inferenceConfig`를 함께 보내기.** 그 필드는 **넣을 수 없습니다.**
- ⚠️⚠️ **요청 검증이 유형·형식을 본다고 생각하기.** 파라미터는 **존재만** 봅니다.
- ⚠️⚠️ **콘텐츠 유형이 안 맞는데 검증이 돈다고 생각하기.** **수행되지 않습니다.**
- ⚠️ **비JSON WebSocket 메시지가 사용자 지정 라우트로 간다고 생각하기.** **`$default`**로 갑니다.
- ⚠️⚠️ **WebSocket 연결을 무기한 유지하려 하기.** **유휴 10분 · 최대 2시간**입니다.
- ⚠️⚠️ **adaptive 모드를 기본으로 쓰기.** **일반 기본값으로 권장되지 않고** 공용 클라이언트에서는 무관한 요청까지 늦춥니다.
- ⚠️ **재시도 쿼터가 초기 요청을 막는다고 생각하기.** **재시도만** 영향받습니다.
- ⚠️⚠️ **SDK 재시도 기본값을 환경 확인 없이 단정하기.** **`AWS_NEW_RETRIES_2026`** 옵트인 여부로 달라집니다.
- ⚠️⚠️ **API Gateway 스로틀을 보장된 상한으로 믿기.** **최선 노력**입니다.
- ⚠️ **클라이언트별 한도를 계정 한도보다 높게 두려 하기.** **불가능**합니다.
- ⚠️⚠️ **스트리밍 시작 뒤에도 폴백된다고 생각하기.** **안 됩니다.**
- ⚠️ **상태 머신 전체 타임아웃을 캐처로 잡으려 하기.** 캐처는 `Task`·`Parallel`·`Map`에만 있습니다.
- ⚠️⚠️ **프롬프트 라우팅으로 패밀리를 넘으려 하기.** **같은 패밀리 안에서만**입니다.

---

## 🧪 자가 점검

**Q1.** 챗봇을 스트리밍으로 바꾸려 합니다. 코드를 쓰기 전에 확인할 두 가지와, IAM에서 손댈 것은 무엇입니까?

<details><summary>정답 보기</summary>

① **모델이 스트리밍을 지원하는지** — **`GetFoundationModel`**을 불러 **`responseStreamingSupported`** 필드를 봅니다. ② ⚠️ **AWS CLI는 Bedrock 스트리밍 작업을 지원하지 않으므로** CLI로 검증할 계획이면 바꿔야 합니다. IAM은 **`bedrock:InvokeModelWithResponseStream`** 권한이고(`bedrock:ConverseStream`이라는 액션이 아닙니다), 반대로 추론을 **완전히 막으려면 `bedrock:InvokeModel`과 `bedrock:InvokeModelWithResponseStream`을 둘 다** 거부해야 합니다.
</details>

**Q2.** API Gateway 요청 검증을 켰는데 `X-Tenant-Id` 헤더에 문자열 `"abc"`가 와도 통과합니다. 왜이고 어디서 막아야 합니까?

<details><summary>정답 보기</summary>

⚠️⚠️ 요청 검증은 **필수 파라미터의 존재만 확인하고 유형이나 형식은 확인하지 않습니다**(URI·쿼리 문자열·헤더). 형식 검증은 **요청 본문의 JSON 스키마**로 하거나 **백엔드의 애플리케이션 고유 검증**으로 합니다. 공식이 적는 역할 분담이 그것입니다 — API Gateway가 **기본 검증**을 맡아 **불필요한 백엔드 호출을 줄이고**, 애플리케이션은 자기 고유 검증에 집중합니다.
</details>

**Q3.** 본문 스키마를 지정했는데 검증이 전혀 수행되지 않습니다. 가장 흔한 원인은 무엇입니까?

<details><summary>정답 보기</summary>

⚠️⚠️ **일치하는 콘텐츠 유형이 없기** 때문입니다 — 공식이 「일치하는 콘텐츠 유형이 없으면 요청 검증이 수행되지 않는다」고 적습니다. 콘텐츠 유형과 무관하게 같은 모델을 쓰려면 데이터 모델의 콘텐츠 유형을 **`$default`**로 둡니다. 그리고 모델 스키마가 없을 때 원본 페이로드를 **패스스루할지 차단할지**는 「매핑 템플릿 없는 페이로드의 메서드 요청 동작」이라는 **별개 주제**입니다.
</details>

**Q4.** 서버가 분석을 끝낼 때마다 클라이언트에 결과를 밀어 넣어야 합니다. WebSocket API로 설계할 때 라우트 셋과 연결 수명의 제약은 무엇입니까?

<details><summary>정답 보기</summary>

미리 정의된 라우트는 **`$connect`·`$disconnect`·`$default`**이고 사용자 지정 라우트를 더합니다. 라우팅은 **API 수준의 `routeSelectionExpression`**이 메시지의 JSON 속성을 지정해 결정하며 ⚠️ **비JSON 메시지는 `$default`**로 갑니다. 역방향 전송은 라우트 응답이나 **`@connections` API POST**입니다. ⚠️⚠️ 수명 제약은 **유휴 10분 또는 최대 2시간 연결 수명에서 `1001`**로 닫히는 것이고, **바이너리 미디어 유형은 지원되지 않아 `1003`**입니다.
</details>

**Q5.** 한 Bedrock 모델을 고용량으로 호출하는 배치 처리기가 계속 스로틀됩니다. SDK 재시도 모드를 무엇으로 두고, 같은 설정을 쓰면 안 되는 상황은 무엇입니까?

<details><summary>정답 보기</summary>

**adaptive**가 맞습니다 — 공식이 쓰는 조건으로 **단일 리소스를 향하고 빈번한 스로틀링을 예상할 때**를 들고, 예로 **한 API 작업을 고용량으로 부르는 AI 워크로드**를 직접 적습니다. ⚠️⚠️ 쓰면 안 되는 상황은 **여러 리소스·여러 테넌트를 향하는 클라이언트**입니다 — 속도 제한기가 **클라이언트 인스턴스 단위**라 한 리소스의 스로틀링이 **무관한 요청까지 늦춥니다.** 초기 요청의 예측 가능한 지연이 필요할 때도 아닙니다(adaptive는 **초기 요청도 지연·차단**합니다).
</details>

**Q6.** 「`max_attempts`가 3이니 재시도가 3번」이라고 적힌 설계 문서를 검토합니다. 무엇이 틀렸고, 재시도를 끄려면 어떻게 합니까?

<details><summary>정답 보기</summary>

**`max_attempts`는 초기 요청을 포함한 총 시도 수**입니다 — 3이면 **초기 1회 + 재시도 2회**입니다. 끄려면 **1**로 둡니다. ⚠️ **DynamoDB·DynamoDB Streams 클라이언트는 기본 4회**이고 기본 백오프가 **25ms**(다른 서비스 50ms)입니다. ⚠️⚠️ 그리고 이 동작 자체가 **`AWS_NEW_RETRIES_2026=true` 옵트인**이 필요하므로, 설정하지 않은 환경은 **2026 이전 동작**(백오프 타이밍·쿼터 비용·서비스별 기본값이 다릅니다)입니다.
</details>

**Q7.** API Gateway에서 프리미엄 고객에게 더 높은 호출 한도를 주려 합니다. 어디에 설정하고, 적용 순서에서 몇 번째입니까? 넘을 수 없는 한도는 무엇입니까?

<details><summary>정답 보기</summary>

**사용량 계획**의 클라이언트별(API 키) 한도이고 적용 순서의 **첫 번째**입니다(① 사용량 계획의 클라이언트별·메서드별 → ② 스테이지의 메서드별 → ③ 리전별 계정 수준 → ④ AWS 리전 스로틀링). ⚠️ 클라이언트별 한도는 **계정별 한도보다 높을 수 없고**, 계정별·메서드별 한도는 **AWS 스로틀링 한도보다 높을 수 없습니다**(그 한도는 고객이 바꿀 수 없습니다). ⚠️⚠️ 그리고 스로틀·쿼터는 **최선 노력이고 보장된 상한이 아닙니다.**
</details>

**Q8.** 스트리밍 응답 중간에 모델 공급자가 오류를 냅니다. 폴백 모델로 자동 전환됩니까?

<details><summary>정답 보기</summary>

**되지 않습니다.** ⚠️⚠️ **스트리밍 응답이 시작된 뒤에는 폴백할 수 없고** 호출자는 **부분 응답과 오류**를 받아 직접 재시도해야 합니다. 그래서 복원력 설계는 **첫 토큰이 나가기 전에 폴백 판단을 끝내야** 합니다. 시작 전이라면 Gateway 규칙의 **`targetFallback`**(대체 목적지 **1~2개**)과 **기본 `ENABLED`인 `circuitBreaker`**가 실패 중인 목적지를 건너뛰며, 공급자가 **깔끔한 오류 없이 멈춰 있을 때**는 **`firstByteTimeoutMilliseconds`**가 그 자리를 맡습니다.
</details>

---

### 📌 출처

1. Amazon Bedrock `Converse` API 참조 (일관된 API · `stopReason`) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html` (2026-11-14 확인)
2. Amazon Bedrock `ConverseStream` API 참조 (`responseStreamingSupported` · CLI 미지원 · 권한 · Prompt management 제약) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_ConverseStream.html` (2026-11-14 확인)
3. 배치 추론으로 여러 프롬프트 처리 (S3 경유 · 프로비저닝 모델 미지원 · `Converse` 도구 호출 미지원 · EventBridge) — `docs.aws.amazon.com/bedrock/latest/userguide/batch-inference.html` (2026-11-14 확인)
4. SageMaker 비동기 추론 (S3 포인터 · 식별자·출력 위치 · SNS 통지) — `docs.aws.amazon.com/sagemaker/latest/dg/async-inference.html` (2026-11-14 확인)
5. API Gateway REST API의 요청 검증 (400 즉시 반환 · 존재만 확인 · 콘텐츠 유형 일치 · `$default`) — `docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html` (2026-11-14 확인)
6. API Gateway WebSocket API 개요 (라우트 셋 · `routeSelectionExpression` · `@connections` · 상태 코드) — `docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-websocket-api-overview.html` (2026-11-14 확인)
7. API Gateway 프록시 통합의 응답 스트리밍 (SSE 용례 · 계약은 작업 2.5가 소유) — `docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html` (2026-11-14 확인)
8. API Gateway REST API 요청 스로틀링 (최선 노력 · 토큰 버킷 · 네 종류 · 적용 순서) — `docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-request-throttling.html` (2026-11-14 확인)
9. AWS SDK의 재시도 동작 (모드 셋 · 재시도 쿼터 · `max_attempts` · `AWS_NEW_RETRIES_2026` 옵트인) — `docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html` (2026-11-14 확인)
10. AWS X-Ray 개요 (UDP 데몬 · 배치 업로드 · 트레이스 맵) — `docs.aws.amazon.com/xray/latest/devguide/aws-xray.html` (2026-11-14 확인)
11. AgentCore Gateway의 라우팅 규칙과 폴백 (`targetFallback` · 서킷 브레이커 · 스트리밍 후 폴백 불가) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rules-fallback.html` (2026-11-14 확인)
12. Amazon Bedrock 지능형 프롬프트 라우팅 (같은 패밀리 · 영어 최적화 · 폴백 모델) — `docs.aws.amazon.com/bedrock/latest/userguide/prompt-routing.html` (2026-11-14 확인)
13. Step Functions 워크플로의 오류 처리 (캐처 범위 · EventBridge `TIMED_OUT`) — `docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html` (2026-11-14 확인)
