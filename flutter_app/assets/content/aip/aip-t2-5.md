---
examGuideTaskId: aip-t2-5
certCode: AIP-C01
domain: 2
domainName: 구현 및 통합
domainWeightPct: 26
title: 애플리케이션 통합 패턴과 개발 도구 (API 인터페이스·접근 가능한 UI·비즈니스 시스템·개발자 생산성·오케스트레이션·문제 해결)
coversTasks:
  - "2.5"
sources:
  - title: API Gateway 프록시 통합의 응답 스트리밍
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html
  - title: API Gateway에서 OpenAPI로 REST API 개발
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-import-api.html
  - title: Amazon Bedrock 토큰 번다운과 쿼터
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html
  - title: Amazon Bedrock CountTokens API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html
  - title: Amazon Bedrock Converse API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
  - title: Step Functions 워크플로의 오류 처리
    url: https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html
  - title: AgentCore Gateway의 속도 제한
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rate-limits.html
  - title: AWS Amplify Hosting 사용자 안내서
    url: https://docs.aws.amazon.com/amplify/latest/userguide/welcome.html
  - title: Amazon Bedrock Flows로 종단 간 GenAI 워크플로 만들기
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/flows.html
  - title: Amazon Bedrock Data Automation
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/bda.html
  - title: Amazon Q Developer IDE 플러그인 지원 종료
    url: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html
  - title: Amazon Q Developer 개요
    url: https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/what-is.html
  - title: AgentCore harness — 선언형 오케스트레이션 계층
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html
  - title: Amazon Bedrock Agents Classic 유지 관리 모드
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html
  - title: AGENTPERF05-BP02 최적화된 다중 에이전트 협업 모델
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html
  - title: AGENTPERF06-BP03 메타 도구로 도구 순서 묶기
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf06-bp03.html
  - title: CloudWatch Logs Insights로 로그 데이터 분석
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
  - title: AWS X-Ray 개요
    url: https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html
  - title: Amazon ECS MCP 서버
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-mcp-introduction.html
lastVerified: 2026-11-14
---

# 애플리케이션 통합 패턴과 개발 도구 (API 인터페이스·접근 가능한 UI·비즈니스 시스템·개발자 생산성·오케스트레이션·문제 해결)

> **커버하는 공식 Task** — AIP-C01 · 도메인 2 「구현 및 통합」(26%) · **작업 2.5 애플리케이션 통합 패턴 및 개발 도구 구현** (`aip-t2-5`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 6개(2.5.1~2.5.6)를 모두 덮습니다. 작업 2.1이 **에이전트의 기계**를 보는 자리라면 이 작업은 **그 기계를 애플리케이션에 꽂는 자리**입니다 — API 계층의 계약, 사람이 쓰는 인터페이스, 그리고 **깨졌을 때 무엇으로 들여다보는가**입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] API Gateway **응답 스트리밍의 계약과 못 쓰게 되는 기능**을 안다
- [ ] 토큰 제한을 **선차감과 사전 계산**으로 관리할 수 있다
- [ ] Step Functions의 **재시도·캐처가 닿지 않는 자리**를 안다
- [ ] Amplify Hosting이 주는 것과 **AWS docs 범위의 경계**를 안다
- [ ] OpenAPI 가져오기의 **두 모드**를 구분할 수 있다
- [ ] Bedrock Data Automation의 **용례 셋과 내장 보호 장치**를 안다
- [ ] 개발 도구의 **지원 종료와 대안 관계**를 안다
- [ ] Logs Insights와 X-Ray가 **각각 무엇을 보여 주는지** 가를 수 있다

---

## 🎯 왜 중요한가

GenAI 기능을 애플리케이션에 붙일 때 실제로 문제가 되는 것은 모델이 아니라 **경계**입니다. 토큰이 흘러나오는 속도, 29초라는 API 한도, 재시도가 닿지 않는 상태, 실패했을 때 남는 흔적 — 전부 **FM 바깥의 계약**입니다.

공식 기술 여섯 개가 그 경계를 하나씩 집습니다. 그리고 ⚠️ **이 작업은 작업 2.4(FM API 통합)와 축이 겹칩니다.** 이 문서는 **API 계층이 지키는 계약**(전송 모드·토큰 한도·재시도)을 소유하고, **모델 쪽 스트리밍 API와 WebSocket·SSE 자체**는 작업 2.4가 봅니다. 같은 스트리밍이라도 「무엇이 토큰을 내보내는가」와 「그것을 받아 내보내는 계층이 무엇을 포기하는가」는 다른 질문입니다.

---

## ⚡ 시험 직전 요약

- API Gateway 응답 스트리밍은 **기본이 `BUFFERED`**이고 **`STREAM`으로 바꿔야** 합니다. ⚠️⚠️ **REST API 전용**이고 **`HTTP_PROXY`·`AWS_PROXY` 통합만**이며 **요청 스트리밍은 지원되지 않습니다.**
- 스트리밍을 켜면 **29초 타임아웃과 10MB 응답 한도를 증액 없이 넘을 수** 있지만 ⚠️⚠️ **엔드포인트 캐싱 · 콘텐츠 인코딩 · VTL 응답 변환을 쓸 수 없습니다.**
- 스트림은 **최대 15분**이고 유휴 타임아웃은 **리전·프라이빗 5분 / 엣지 최적화 30초**입니다. 첫 **10MB**는 대역폭 제한이 없고 초과분은 **2MB/s**로 제한되며, ⚠️ **연결이 타임아웃으로 닫혀도 Lambda 함수는 계속 실행될 수 있습니다.**
- ⚠️⚠️ 토큰 쿼터는 **요청 시작 시점에 「입력 토큰 + `max_tokens`」가 선차감**됩니다 — 짧게 답해도 **큰 `max_tokens`가 쿼터를 먹습니다**. 사전 계산은 **`CountTokens`**(응답은 `inputTokens`뿐)입니다.
- Step Functions 캐처는 **`Task`·`Parallel`·`Map`**에만 있고 ⚠️⚠️ **최상위 실행 실패에는 없습니다** — 자식 워크플로로 중첩하거나 **EventBridge의 `TIMED_OUT` 이벤트**로 다룹니다.
- ⚠️ **`States.ALL`은 캐처에 혼자 있어야 하고 `States.DataLimitExceeded`와 `States.Runtime`을 잡지 못합니다.** `States.Runtime`은 **재시도도 안 됩니다.**
- Amplify의 **원자적 배포**는 **전체 배포가 끝난 뒤에만** 앱을 갱신해 유지 관리 창을 없앱니다. ⚠️ AWS docs의 Amplify 사용자 안내서는 **Hosting** 범위이고 코드 우선 백엔드는 **Amplify 문서**를 가리킵니다.
- **Bedrock Data Automation**은 문서·이미지·**비디오·오디오**를 구조화 형식으로 바꾸고 내장 보호 장치로 **시각적 그라운딩과 신뢰도 점수**를 적습니다.
- ⚠️⚠️ **Amazon Q Developer IDE 플러그인은 2027-04-30 지원 종료**이고 공식이 드는 대안이 **Kiro**입니다. **콘솔의 Q Developer는 `AWS assistant`로 개명**됐습니다.
- ⚠️⚠️ **Logs Insights는 로그 그룹 생성 시각보다 앞선 타임스탬프의 이벤트에 접근할 수 없습니다.** 요금은 **언어와 무관하게 스캔한 비압축 데이터 양**입니다.

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **응답 전송 모드** | API Gateway가 통합 응답을 모아서 보낼지(`BUFFERED`) 흐르는 대로 보낼지(`STREAM`) |
| **선차감(번다운)** | 요청 시작 시점에 쓸 토큰을 미리 쿼터에서 빼는 방식 |
| **캐처(Catcher)** | Step Functions에서 오류를 잡아 다른 상태로 보내는 정의 |
| **원자적 배포** | 전체 배포가 끝난 뒤에만 앱을 갱신하는 방식 |
| **메타 도구** | 예측 가능한 도구 순서를 **하나의 서버 측 작업**으로 묶은 도구 |
| **트레이스 맵** | 클라이언트·프런트엔드·백엔드 호출 관계를 그린 X-Ray의 지도 |
| **필드 인덱스** | 자주 쓰는 로그 필드를 색인해 스캔량을 줄이는 Logs Insights 기능 |

---

## 📖 핵심 개념

### 1) FM API 인터페이스 — 전송·토큰·재시도 (기술 2.5.1) {#api-interface}

> 🧠 원리: GenAI 응답은 **길고 느립니다.** 그래서 API 계층의 기본값(모아서 보내기, 29초, 10MB)이 그대로 걸립니다. 이 기술은 그 셋을 각각 **무엇으로 넘기고 무엇을 포기하는가**입니다.

**① 응답 스트리밍** — 프록시 통합의 응답 전송 모드를 **`STREAM`**으로 두면 API Gateway가 응답이 완전히 계산되기를 기다리지 않고 보냅니다. 공식이 드는 용례에 **GenAI 챗봇의 TTFB 단축**과 **서버 전송 이벤트로 진행 상황 보고**가 있습니다.

| 축 | 계약 |
|---|---|
| 기본값 | **`BUFFERED`** — 스트리밍은 **명시적으로 바꿔야** 한다 |
| 통합 유형 | **`HTTP_PROXY` 또는 `AWS_PROXY`만**(Lambda 프록시, `HTTP_PROXY` 사설 통합 포함) |
| API 종류 | ⚠️⚠️ **REST API만** 지원 |
| 방향 | ⚠️ **요청 스트리밍은 지원되지 않는다** |
| 최대 시간 | **15분** |
| 유휴 타임아웃 | **리전·프라이빗 5분 / 엣지 최적화 30초**(리전 REST API에 내 CloudFront 배포를 쓰면 **응답 타임아웃을 올려** 30초보다 길게 할 수 있다) |
| 대역폭 | 첫 **10MB**는 제한 없음, 초과분은 **2MB/s** |

- ⚠️⚠️ **`STREAM`이면 전체 응답을 버퍼링해야 하는 기능을 쓸 수 없습니다** — **엔드포인트 캐싱 · 콘텐츠 인코딩 · VTL 응답 변환** 셋입니다. 압축이 필요하면 **통합 쪽에서** 합니다.
- ⭐ 공식이 적는 이득: **29초 타임아웃을 통합 타임아웃 증액 요청 없이 넘을 수 있고**, **10MB 응답 페이로드 한도를 넘을 수 있고**, 바이너리 미디어 유형을 구성하지 않고 바이너리 페이로드를 받을 수 있습니다.
- ⚠️ **연결이 타임아웃으로 닫혀도 Lambda 함수는 계속 실행될 수 있습니다** — 비용과 부작용이 남습니다. 응답 스트리밍은 **과금 대상**입니다.

**② 토큰 제한 관리**:

- ⚠️⚠️ 쿼터는 **요청 시작 시점에 「입력 토큰 + `max_tokens`」를 선차감**합니다. 그 합이 쿼터를 넘으면 스로틀되고, **실제로 짧게 답해도 큰 `max_tokens`는 쿼터를 먹습니다.** 그래서 `max_tokens`는 「넉넉하게」가 아니라 **실제 필요치**로 둡니다.
- 사전 계산은 **`CountTokens`**입니다 — **`POST /model/{modelId}/count-tokens`**이고 입력은 `invokeModel` 또는 `converse` **중 하나**(Union)이며 **응답은 `inputTokens`뿐**입니다. 출력 토큰은 미리 알 수 없습니다.
- 응답이 잘렸는지는 **`stopReason`**이 말합니다 — **`max_tokens`**면 모델이 멈춘 것이 아니라 **내 `max_tokens` 설정에 걸린** 것입니다. 사용자에게 「답이 끊겼다」로 보이는 전형적인 원인입니다.
- 에이전트 경로라면 Gateway 속도 제한이 추론 타깃을 **분당 토큰(TPM)**으로 제어하고 **동시 연결 수**도 제한합니다(작업 2.1 참고).

**③ 타임아웃·재시도 전략** — Step Functions로 오케스트레이션할 때의 계약입니다.

- ⚠️ 상태가 오류를 보고하면 Step Functions는 **기본적으로 전체 상태 머신 실행을 실패**시킵니다. 재시도·캐처는 **명시해야** 동작합니다.
- **`Retry`와 캐처는 `Task`·`Parallel`·`Map`에만** 있습니다. ⚠️⚠️ **최상위 실행 실패에는 캐처가 없습니다** — 호출자가 처리하거나, **자식 워크플로로 중첩**해 부모가 잡거나, **EventBridge 버스로 Standard 워크플로의 `TIMED_OUT` 이벤트를 듣고** 처리합니다.
- ⚠️ **`States.ALL`은 캐처에 혼자 있어야 하고**, **`States.DataLimitExceeded`**(종단 오류)와 **`States.Runtime`**을 **잡지 못합니다.** 그 둘은 `ErrorEquals`에 **명시**해야 하고, **`States.Runtime`은 재시도도 안 되며 항상 실행을 실패**시킵니다.
- **`States.TaskFailed`**는 재시도·캐처에서 **`States.Timeout`을 뺀 모든 알려진 오류 이름**에 걸리는 와일드카드입니다. ⚠️ **중첩 상태 머신이 `States.Timeout`을 던지면 부모는 `States.TaskFailed`를 받습니다.**
- Lambda를 부른다면 **`Lambda.ServiceException`·`Lambda.SdkClientException`**을 운영 코드가 다뤄야 하고, 타임아웃은 새 런타임에서 **`Sandbox.Timedout`**(과거에는 `Lambda.Unknown`)으로, 호출 한도 초과는 **`Lambda.TooManyRequestsException`**으로 보고됩니다.
- 재시도 간격은 **`BackoffRate`·`MaxDelaySeconds`**로 조절하고, 리드라이브(redrive)로 다시 돌리면 **그 상태들의 재시도 횟수가 0으로 초기화**됩니다.

### 2) 접근 가능한 AI 인터페이스 (기술 2.5.2) {#interfaces}

> 🧠 원리: FM 기능의 도입을 막는 것은 모델 품질이 아니라 **쓸 수 있는 표면이 없는 것**입니다. 공식 기술이 드는 셋은 그 표면을 세 층에서 만듭니다 — **UI**, **계약(API 명세)**, **노코드 조립**.

**Amplify Hosting** — Git 기반 워크플로로 풀스택 서버리스 웹 애플리케이션을 호스팅하고 **AWS 글로벌 CDN**으로 배포합니다. 기능:

- **기능 브랜치** — 브랜치를 연결해 운영·스테이징 환경을 함께 관리합니다.
- **풀 리퀘스트 프리뷰** — 코드 리뷰 중에 변경을 미리 봅니다.
- **암호 보호 브랜치** — 공개하지 않고 새 기능을 작업합니다.
- **리다이렉트·리라이트** — SEO 순위를 지키고 클라이언트 요구에 따라 트래픽을 보냅니다.
- ⭐ **원자적 배포** — **전체 배포가 끝난 뒤에만** 웹 앱이 갱신되어 **유지 관리 창을 없애고** 일부 파일만 올라가 깨지는 상황을 막습니다.
- 지원 프레임워크는 **SSR**(Next.js·Nuxt 등) · **SPA**(React·Angular·Vue.js 등) · **정적 사이트 생성기**(Gatsby·Hugo·Jekyll 등)입니다.
- ⚠️ **AWS docs의 Amplify 사용자 안내서는 Hosting 범위**입니다. **코드 우선 백엔드(Amplify Gen 2)와 Amplify UI 라이브러리**는 그 페이지가 **Amplify 문서**를 정본으로 가리킵니다 — 선언형 UI 구성 요소의 세부를 묻는 자리는 그쪽입니다.

**OpenAPI로 API 우선 개발** — API Gateway는 외부 정의 파일에서 REST API를 **가져옵니다.**

- 지원 버전은 **OpenAPI v2.0과 v3.0**입니다.
- ⚠️ 가져오기 방식이 둘입니다 — **새 정의로 덮어쓰기(overwrite)** 또는 **기존 API와 병합(merge)**. **`mode` 쿼리 파라미터**로 고릅니다.
- 반대 방향(**내보내기**)도 있어, 콘솔에서 만든 API를 정의 파일로 꺼내 소스 관리에 둘 수 있습니다.

**노코드 워크플로 빌더** — 현행 공식 표기는 **Amazon Bedrock Flows**입니다. 비주얼 빌더로 프롬프트·FM·지식 베이스·Lambda 같은 **노드를 연결**하고, **불변 워크플로를 배포**해 테스트에서 운영으로 옮깁니다. 요금은 **쓰는 리소스에 따릅니다**(프롬프트 노드가 모델을 호출하면 그 모델 호출이 과금됩니다).

### 3) 비즈니스 시스템 개선 (기술 2.5.3) {#business}

> 🧠 원리: 이 기술이 드는 셋은 **역할이 겹치지 않습니다** — 단일 로직은 함수, 여러 단계의 순서와 상태는 워크플로, 비정형 콘텐츠의 구조화는 전용 서비스입니다. 세 번째를 직접 조립하려 하는 것이 전형적인 과설계입니다.

- **Lambda 함수** — CRM 개선처럼 **단일 요청·응답 로직**을 붙입니다. 웹훅·이벤트 처리의 기본 단위입니다.
- **Step Functions** — 문서 처리처럼 **여러 단계와 분기·재시도가 있는 흐름**을 오케스트레이션합니다. 오류 처리 계약은 위 §1 ③과 같습니다.
- **Amazon Bedrock Data Automation** — 문서·이미지·**비디오·오디오** 같은 비정형 콘텐츠를 **구조화 형식으로 변환**합니다. 공식이 드는 용례 셋:

| 용례 | 내용 |
|---|---|
| **IDP**(지능형 문서 처리) | ⭐ 분류·추출·정규화·검증을 **직접 오케스트레이션하지 않는다** |
| **미디어 분석** | 장면 요약 · 안전하지 않은 콘텐츠 식별 · 영상 내 텍스트 추출 · 광고·브랜드 기준 분류 |
| **RAG 보강** | 모달리티별 풍부한 표현을 질의응답 애플리케이션에 공급 |

- **단일 인터페이스의 API 주도 경험**이고, 내장 보호 장치로 **시각적 그라운딩과 신뢰도 점수**를 적습니다 — 추출한 값이 **원본의 어디에서 왔는지**와 **얼마나 확신하는지**를 함께 줍니다.
- ⚠️ 그래서 「OCR → 분류 모델 → 검증 규칙」을 Lambda와 Step Functions로 직접 엮는 설계는, 공식이 **그 오케스트레이션을 하지 않아도 된다**고 적는 자리에서는 과설계입니다. 반대로 **사람 승인 단계나 사내 시스템 호출**이 흐름에 끼면 Step Functions가 그 바깥을 맡습니다.

### 4) 개발자 생산성 (기술 2.5.4) {#devtools}

> 🧠 원리: 이 기술은 **도구 이름을 외우는 자리가 아니라 관계를 아는 자리**입니다. 공식 범위 목록이 두 제품을 **나란히** 들지만, 하나는 지원 종료가 공지됐고 공식이 다른 하나를 대안으로 가리킵니다.

- ⚠️⚠️ **`Amazon Q Developer` IDE 플러그인은 2027-04-30에 지원 종료**됩니다. 공식 개요 페이지가 그 문장과 함께 **`For capabilities similar to Amazon Q Developer IDE plugins, explore Kiro`**를 적습니다.
- ⚠️ **콘솔의 Amazon Q Developer는 `AWS assistant`로 개명**됐습니다 — 같은 페이지가 **`Amazon Q Developer in the AWS Management Console is now the AWS assistant`**로 적습니다. 「콘솔의 Q Developer」와 「IDE 플러그인」은 **다른 운명**입니다.
- ⚠️ **`Kiro`는 AWS docs에 가이드가 없습니다.** 공식 지원 종료 페이지가 **마이그레이션 가이드를 `kiro.dev`로 링크**하고 그것이 그 페이지의 유일한 외부 링크입니다. 그래서 이 사이트는 **Kiro의 기능 수·가격·모델 목록을 다루지 않습니다** — 근거가 AWS 공식 문서에 없습니다.
- 공식 기술이 드는 축은 **코드 생성과 리팩터링 · API 지원을 위한 코드 제안 · AI 구성 요소 테스트 · 성능 최적화**입니다. 시험은 「어떤 도구가 코드를 더 잘 쓰는가」가 아니라 **그 도구가 개발 워크플로의 어느 단계를 줄이는가**를 묻습니다.
- ⭐ MCP 쪽 개발 도구도 docs에 있습니다 — **Amazon ECS MCP 서버**는 **Kiro** 같은 MCP 호환 AI 코딩 어시스턴트를 직접 들고, **완전관리형으로 AWS 클라우드에 호스팅**되어 로컬 설치가 필요하지 않으며 **IAM 통합과 CloudTrail 감사 로깅**을 적습니다.

### 5) 고급 GenAI 애플리케이션 — 오케스트레이션 (기술 2.5.5) {#orchestration}

> 🧠 원리: 작업 2.1이 **에이전트 하나의 기계**를 본다면 이 기술은 **여럿을 어떻게 엮는가**입니다. 그리고 엮는 수단이 **프레임워크 · 상태 머신 · 프롬프트 체인** 셋으로 갈립니다 — 결정적인 것은 상태 머신, 판단이 필요한 것은 프레임워크입니다.

- **Strands Agents**는 AWS 문서가 **자기 오픈소스 에이전트 프레임워크**로 귀속하는 프레임워크입니다 — `harness.html`이 **`The harness is powered by Strands Agents, the open-source agent framework from AWS.`**로 적습니다. **agent-as-tool** 패턴으로 수퍼바이저-워커 오케스트레이션을 만들고, AgentCore 쪽에서는 **SDK에 계측이 내장**돼 있습니다.
- ⚠️ **`AWS Agent Squad`는 공식 시험 가이드가 이름을 들지만 AWS docs에 제품 문서가 없습니다.** 그래서 이 사이트는 **내부 동작·구성요소 이름·수치를 다루지 않고 패턴만** 봅니다 — **분류기 기반 라우팅 · 수퍼바이저 · agent-as-tool**이고, 그 패턴의 근거는 docs에 있는 **Agents Classic 비교표**와 **Agentic AI Lens의 협업 모델**입니다. ⚠️ 반대로 「AWS 제품이 아니다」로도 단정하지 않습니다 — 측정된 것은 **문서의 부재**입니다.
- **Step Functions**는 **결정적 위임**과 **오래 걸리는 내구성 워크플로**의 공식 대안으로 적힙니다. ⭐ 그리고 harness가 **`InvokeHarness` 상태**로 그 파이프라인에 들어가므로, **결정적 단계가 에이전트 단계를 감싸는** 구조를 공식 경로로 만들 수 있습니다.
- ⚠️ **`Amazon Bedrock Agents`는 이제 `Amazon Bedrock Agents Classic`이고 신규 고객에게 열려 있지 않습니다.** 새 설계의 오케스트레이션은 **AgentCore harness**(구성 기반)나 **AgentCore에 올리는 코드 정의 에이전트**로 갑니다. ⭐ 그 비교표가 **완전한 다중 에이전트 협업에는 사용자 지정 프레임워크 코드가 필요**하다고 적는 것이 「프레임워크를 왜 쓰는가」의 공식 근거입니다.
- **프롬프트 체인**은 Bedrock 쪽에서 **Flows의 노드 연결**로 만들거나 애플리케이션 코드가 직접 잇습니다. 노드 기반은 **불변 배포**로 버전을 고정할 수 있는 것이 이점입니다.
- ⭐⭐ **메타 도구**(`AGENTPERF06-BP03`)가 오케스트레이션 성능의 공식 수단입니다 — **예측 가능한 도구 순서를 하나의 서버 측 작업으로 묶어** 한 번의 추론 반복으로 끝냅니다. **Lambda 함수로 구현**하고 **MCP·Gateway로 개별 도구와 나란히 노출**해 에이전트가 **일상 작업엔 메타 도구, 새로운 작업엔 개별 도구**를 고르게 합니다.
  - 판단 근거는 **텔레메트리에서 세 번 이상 반복되는 순서**이고, 메타 도구의 지연은 **단계별로 분해**해 가장 느린 단계를 고칩니다.
  - ⚠️ 안티패턴: 변형을 너무 많이 떠안아 **개별 도구보다 느려지는 메타 도구**.

### 6) 문제 해결 효율 (기술 2.5.6) {#troubleshooting}

> 🧠 원리: GenAI 애플리케이션의 장애는 **「무엇이 느린가」와 「무엇이라고 답했는가」가 다른 도구에** 남습니다. 로그는 내용을, 트레이스는 경로와 시간을 봅니다. 하나로 다 보려 하면 둘 다 놓칩니다.

**CloudWatch Logs Insights — 프롬프트와 응답의 내용**:

- 쿼리 언어가 **셋**입니다 — 전용 **Logs Insights QL** · **OpenSearch PPL**(파이프로 잇는 명령) · **OpenSearch SQL**(`SELECT`·`JOIN`·서브쿼리까지).
- 동시 실행 한도: **계정당 Logs Insights QL 100개**(대시보드에 올린 쿼리 포함) + **PPL 또는 SQL 각 15개**.
- ⚠️ **`filterIndex` 명령은 Logs Insights QL 전용**이고 **비교 쿼리**(이전 기간과 대조)도 **QL 전용**입니다.
- ⚠️ **PPL·SQL에서는 특수 문자가 든 필드를 백틱으로 감싸야** 합니다(`@message` 같은 것). 순수 알파벳 필드는 필요 없습니다.
- ⚠️⚠️ **로그 그룹 생성 시각보다 앞선 타임스탬프의 로그 이벤트에는 접근할 수 없습니다**(공식 Important). 그리고 검색 가능한 데이터는 **2018년 11월 5일 이후** 전송된 것입니다.
- 쿼리는 **60분 뒤 타임아웃**되고 **결과는 7일** 제공됩니다. 요금은 **언어와 무관하게 스캔한 비압축 로그 데이터 양**으로 매겨집니다 — 그래서 **필드 인덱스**로 스캔량을 줄이는 것이 비용 수단입니다.
- 그 밖에: AWS 서비스와 JSON 로그의 **필드 자동 발견** · **패턴 탐지**(반복되는 텍스트 구조) · 쿼리 저장·이력·파라미터 · **자연어로 쿼리 생성**(줄 단위 설명 제공) · 결과 **KMS 암호화** · **주변 로그**(선택한 레코드 앞뒤 5·10·20·50·100줄) · 교차 계정 관찰성의 모니터링 계정에서 **여러 계정의 로그 그룹을 한 쿼리로**.

**AWS X-Ray — 호출 경로와 시간**:

- 애플리케이션이 받는 요청에 대한 데이터를 모으고, **다운스트림 AWS 리소스·마이크로서비스·데이터베이스·웹 API 호출까지** 보여 줍니다.
- ⚠️ 전송 구조가 특이합니다 — 클라이언트 SDK는 X-Ray로 직접 보내지 않고 **JSON 세그먼트 문서를 UDP 트래픽을 듣는 데몬 프로세스에** 보냅니다. **데몬이 큐에 버퍼링해 배치로 업로드**합니다. 데몬은 Linux·Windows·macOS용이 있고 **Elastic Beanstalk과 Lambda 플랫폼에 포함**돼 있습니다.
- **트레이스 맵**이 클라이언트·프런트엔드·백엔드 서비스를 그려 **병목과 지연 급증**을 찾게 합니다.
- X-Ray와 통합된 AWS 서비스는 들어오는 요청에 **추적 헤더를 추가**하거나, 트레이스 데이터를 보내거나, 데몬을 실행합니다. 많은 계측 시나리오는 **구성 변경만으로** 됩니다.

**둘을 가르는 질문**: 「모델이 무엇이라고 답했고 어떤 프롬프트를 받았나」는 **Logs Insights**, 「이 요청이 어느 구간에서 느려졌나」는 **X-Ray**입니다. ⚠️ 그리고 **에이전트의 도구 호출**은 작업 4.3이 보는 관찰성 설계에서 다룹니다.

---

## ✍️ 시험 포인트

- 「챗봇 응답이 29초에 끊긴다」면 **응답 전송 모드를 `STREAM`으로** 바꾸는 것이 증액 요청 없는 공식 경로입니다.
- 「스트리밍을 켰는데 캐싱이 안 된다」면 **정상**입니다 — `STREAM`은 캐싱·콘텐츠 인코딩·VTL 응답 변환을 포기합니다.
- 「HTTP API로 스트리밍」은 **안 됩니다** — **REST API 전용**입니다. 통합도 **프록시 유형만**입니다.
- 「클라이언트가 끊겼으니 Lambda도 멈췄겠지」는 **틀렸습니다** — 계속 실행될 수 있습니다.
- 「짧게 답하게 했는데 스로틀이 난다」면 **`max_tokens` 선차감**입니다.
- 「요청을 보내기 전에 토큰을 알아야 한다」면 **`CountTokens`**이고 **입력 토큰만** 나옵니다.
- 「응답이 중간에 끊겼다」면 **`stopReason`**을 보고 **`max_tokens`**인지 확인합니다.
- 「상태 머신 실행 전체가 타임아웃되는 것을 잡아야 한다」면 **캐처로는 안 되고** 자식 워크플로 중첩이나 **EventBridge `TIMED_OUT`**입니다.
- 「`States.ALL`로 다 잡자」는 **`DataLimitExceeded`·`Runtime`을 못 잡습니다.**
- 「배포 중에 일부 파일만 올라가 앱이 깨졌다」면 **원자적 배포**가 답입니다.
- 「기존 API에 경로만 추가하고 싶다」면 OpenAPI 가져오기의 **병합(merge)** 모드입니다.
- 「스캔 PDF와 영상에서 구조화 데이터를 뽑는다」면 **Bedrock Data Automation**이고 **시각적 그라운딩·신뢰도 점수**가 내장입니다.
- 「IDE에서 코드 생성 도구를 새로 도입한다」면 **Q Developer IDE 플러그인은 지원 종료 예정**이고 공식 대안이 **Kiro**입니다.
- 「프롬프트와 응답을 분석」은 **Logs Insights**, 「호출 경로와 지연」은 **X-Ray**입니다.
- 「예전 로그가 조회되지 않는다」면 **로그 그룹 생성 시각보다 앞선 이벤트**인지 확인합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ⚠️⚠️ **응답 스트리밍이 기본이라고 생각하기.** 기본은 **`BUFFERED`**입니다.
- ⚠️ **HTTP API나 비프록시 통합에서 스트리밍을 기대하기.** **REST API + 프록시 통합**만입니다.
- ⚠️ **요청도 스트리밍된다고 생각하기.** **지원되지 않습니다.**
- ⚠️⚠️ **`STREAM`에서 엔드포인트 캐싱을 쓰려 하기.** 버퍼링이 필요한 기능은 함께 못 씁니다.
- ⚠️ **엣지 최적화 엔드포인트의 30초 유휴 타임아웃을 모르고 설계하기.** 리전·프라이빗은 5분입니다.
- ⚠️⚠️ **`max_tokens`를 넉넉하게 두기.** **선차감**이라 쿼터를 그만큼 먹습니다.
- ⚠️ **`CountTokens`로 출력 토큰을 알려 하기.** 응답은 **`inputTokens`뿐**입니다.
- ⚠️⚠️ **캐처가 최상위 실행 실패도 잡는다고 생각하기.** `Task`·`Parallel`·`Map`에만 있습니다.
- ⚠️ **`States.Runtime`을 재시도로 넘기려 하기.** **재시도되지 않습니다.**
- ⚠️ **`States.ALL`을 다른 오류와 함께 캐처에 넣기.** **혼자** 있어야 합니다.
- ⚠️ **Lambda 타임아웃을 `Lambda.Unknown`으로만 매칭하기.** 새 런타임은 **`Sandbox.Timedout`**입니다.
- ⚠️ **Amplify 사용자 안내서에서 선언형 UI 구성 요소 문서를 찾기.** 그 안내서는 **Hosting** 범위입니다.
- ⚠️ **OpenAPI 가져오기가 항상 덮어쓰기라고 생각하기.** **`mode`로 병합**을 고릅니다.
- ⚠️⚠️ **BDA가 할 일을 Lambda·Step Functions로 직접 엮기.** 공식은 그 오케스트레이션을 **직접 하지 않는다**고 적습니다.
- ⚠️⚠️ **콘솔의 Q Developer와 IDE 플러그인을 같은 운명으로 보기.** 콘솔 쪽은 **개명**, IDE 쪽은 **지원 종료**입니다.
- ⚠️ **Kiro의 기능 수·가격을 외우려 하기.** AWS docs에 가이드가 없습니다.
- ⚠️ **`AWS Agent Squad`의 내부 구성요소를 외우려 하기.** AWS docs에 제품 문서가 없어 **패턴만** 봅니다.
- ⚠️⚠️ **메타 도구에 변형을 다 떠안기기.** 개별 도구보다 느려지면 안티패턴입니다.
- ⚠️ **Logs Insights 요금이 쿼리 언어에 따라 다르다고 생각하기.** **스캔한 비압축 데이터 양**입니다.
- ⚠️ **X-Ray SDK가 X-Ray로 직접 보낸다고 생각하기.** **데몬에 UDP로** 보내고 데몬이 배치 업로드합니다.

---

## 🧪 자가 점검

**Q1.** GenAI 챗봇의 응답이 29초를 넘겨 504가 납니다. 통합 타임아웃 증액을 요청하지 않고 해결하는 공식 경로는 무엇이고, 그 대가로 포기하는 것은 무엇입니까?

<details><summary>정답 보기</summary>

프록시 통합의 **응답 전송 모드를 `STREAM`으로** 바꿉니다. 공식이 용례로 **「통합 타임아웃 증액 요청 없이 29초 한도를 넘는다」**를 직접 적습니다. 대가는 ⚠️⚠️ **엔드포인트 캐싱 · 콘텐츠 인코딩 · VTL 응답 변환**입니다(전체 응답 버퍼링이 필요한 기능). 조건도 있습니다 — **REST API 전용**, **`HTTP_PROXY`·`AWS_PROXY`만**, 최대 **15분**, 유휴 타임아웃은 **리전·프라이빗 5분 / 엣지 30초**입니다.
</details>

**Q2.** 응답은 평균 200토큰인데 `max_tokens`를 4096으로 두었습니다. 쿼터에는 어떤 영향이 있습니까?

<details><summary>정답 보기</summary>

영향이 **있습니다.** 쿼터는 ⚠️⚠️ **요청 시작 시점에 「입력 토큰 + `max_tokens`」를 선차감**하므로, 실제로 200토큰만 답해도 **4096만큼 쿼터를 먹습니다.** 합이 쿼터를 넘으면 스로틀됩니다. 그래서 `max_tokens`는 실제 필요치로 두고, 입력 쪽은 **`CountTokens`**로 미리 계산합니다(응답은 **`inputTokens`뿐**).
</details>

**Q3.** Step Functions 워크플로의 **실행 전체**가 타임아웃되는 경우를 처리해야 합니다. 캐처로 됩니까?

<details><summary>정답 보기</summary>

안 됩니다. 캐처는 **`Task`·`Parallel`·`Map`** 상태에만 있고 ⚠️⚠️ **최상위 상태 머신 실행 실패에는 없습니다.** 공식이 드는 대안 셋: **호출자가 오류를 처리** · **자식 워크플로로 중첩**해 부모가 잡기 · **EventBridge 버스로 Standard 워크플로의 `TIMED_OUT` 이벤트를 듣고** 조치하기. 덧붙여 **중첩 상태 머신이 `States.Timeout`을 던지면 부모는 `States.TaskFailed`를 받습니다.**
</details>

**Q4.** 캐처를 `"ErrorEquals": ["States.ALL"]` 하나로 두었는데 어떤 실패가 잡히지 않습니다. 무엇이고 왜입니까?

<details><summary>정답 보기</summary>

**`States.DataLimitExceeded`**(페이로드 크기 초과 — 종단 오류)와 **`States.Runtime`**입니다. 공식이 **`States.ALL`은 캐처에 혼자 있어야 하고 그 둘을 잡을 수 없다**고 적습니다. 잡으려면 `ErrorEquals`에 **명시**해야 하고, ⚠️ **`States.Runtime`은 재시도도 되지 않고 항상 실행을 실패**시킵니다. Lambda 쪽은 **`Lambda.Unknown`·`Sandbox.Timedout`·`States.TaskFailed`**를 함께 매칭합니다.
</details>

**Q5.** 스캔된 계약서와 교육 영상에서 구조화 데이터를 뽑아 사내 검색에 넣으려 합니다. 무엇을 쓰고, 추출 신뢰성은 무엇으로 확인합니까?

<details><summary>정답 보기</summary>

**Amazon Bedrock Data Automation**입니다. 문서·이미지·**비디오·오디오**를 구조화 형식으로 바꾸고 용례에 **IDP · 미디어 분석 · RAG 보강**이 듭니다. 신뢰성은 내장 보호 장치인 **시각적 그라운딩과 신뢰도 점수**로 봅니다 — 추출한 값이 원본의 어디에서 왔는지와 확신 정도를 함께 줍니다. ⭐ 그리고 IDP 용례에서 **분류·추출·정규화·검증을 직접 오케스트레이션하지 않아도** 됩니다.
</details>

**Q6.** 팀이 IDE에서 쓸 AI 코딩 도구를 새로 표준화하려 합니다. `Amazon Q Developer`에 대해 반드시 알아야 할 두 가지는 무엇입니까?

<details><summary>정답 보기</summary>

① ⚠️⚠️ **IDE 플러그인은 2027-04-30에 지원 종료**되고 공식이 **`explore Kiro`**로 대안을 가리킵니다. ② ⚠️ **콘솔의 Amazon Q Developer는 `AWS assistant`로 개명**됐습니다 — 둘은 **다른 운명**이라 「Q Developer가 없어진다」로 뭉개면 틀립니다. 그리고 **Kiro는 AWS docs에 가이드가 없고** 공식 EOS 페이지가 `kiro.dev`를 링크하므로, 기능 수·가격 같은 제품 세부는 AWS 공식 문서 근거가 없습니다.
</details>

**Q7.** 에이전트가 「고객 조회 → 주문 조회 → 배송 조회」를 거의 항상 같은 순서로 호출합니다. 공식 최적화 수단과 그 판단 근거는 무엇입니까?

<details><summary>정답 보기</summary>

**메타 도구**(`AGENTPERF06-BP03`)입니다 — 예측 가능한 도구 순서를 **하나의 서버 측 작업으로 묶어** 한 번의 추론 반복으로 끝내고, **Lambda 함수로 구현**해 **MCP·Gateway로 개별 도구와 나란히 노출**합니다. 판단 근거는 **텔레메트리에서 세 번 이상 반복되는 순서**입니다. ⚠️ 안티패턴은 변형을 너무 많이 떠안아 **개별 도구보다 느려지는** 메타 도구이고, 지연은 **단계별로 분해**해 가장 느린 단계를 고칩니다.
</details>

**Q8.** 어제 만든 로그 그룹에서 지난주 프롬프트를 조회하려는데 결과가 비어 있습니다. 왜입니까?

<details><summary>정답 보기</summary>

⚠️⚠️ **Logs Insights는 로그 그룹 생성 시각보다 앞선 타임스탬프의 로그 이벤트에 접근할 수 없습니다**(공식 Important). 함께 기억할 경계: 검색 가능 데이터는 **2018-11-05 이후**, 쿼리는 **60분 뒤 타임아웃**, 결과는 **7일** 제공, 요금은 **언어와 무관하게 스캔한 비압축 데이터 양**입니다.
</details>

**Q9.** 「프롬프트와 응답 내용」과 「요청이 어느 구간에서 느려졌는지」를 각각 무엇으로 봅니까? 후자의 전송 구조에서 비자명한 점은 무엇입니까?

<details><summary>정답 보기</summary>

내용은 **CloudWatch Logs Insights**, 경로와 시간은 **AWS X-Ray**(트레이스 맵으로 병목·지연 급증 식별)입니다. 비자명한 점은 ⚠️ **클라이언트 SDK가 X-Ray로 직접 보내지 않는다**는 것입니다 — **JSON 세그먼트 문서를 UDP를 듣는 데몬에** 보내고 **데몬이 큐에 버퍼링해 배치로 업로드**합니다. 데몬은 **Elastic Beanstalk과 Lambda 플랫폼에 포함**돼 있습니다.
</details>

---

### 📌 출처

1. API Gateway 프록시 통합의 응답 스트리밍 (`BUFFERED` 기본 · REST 전용 · 15분 · 유휴 타임아웃 · 포기하는 기능 셋) — `docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html` (2026-11-14 확인)
2. API Gateway에서 OpenAPI로 REST API 개발 (v2.0·v3.0 · `mode`로 덮어쓰기·병합 · 내보내기) — `docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-import-api.html` (2026-11-14 확인)
3. Amazon Bedrock 토큰 번다운과 쿼터 (입력 토큰 + `max_tokens` 선차감) — `docs.aws.amazon.com/bedrock/latest/userguide/quotas-token-burndown.html` (2026-11-14 확인)
4. Amazon Bedrock `CountTokens` API 참조 (`POST /model/{modelId}/count-tokens` · 응답은 `inputTokens`) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html` (2026-11-14 확인)
5. Amazon Bedrock `Converse` API 참조 (`stopReason` 유효값 · `max_tokens`) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html` (2026-11-14 확인)
6. Step Functions 워크플로의 오류 처리 (캐처 범위 · `States.ALL` 제약 · Lambda 오류 이름 · 리드라이브) — `docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html` (2026-11-14 확인)
7. AgentCore Gateway 속도 제한 (추론 타깃의 TPM·동시 연결) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway-rate-limits.html` (2026-11-14 확인)
8. AWS Amplify Hosting 사용자 안내서 (원자적 배포 · PR 프리뷰 · 기능 브랜치 · Amplify 문서로의 경계) — `docs.aws.amazon.com/amplify/latest/userguide/welcome.html` (2026-11-14 확인)
9. Amazon Bedrock Flows (현행 표기 · 노드 연결 · 불변 워크플로 배포 · 요금) — `docs.aws.amazon.com/bedrock/latest/userguide/flows.html` (2026-11-14 확인)
10. Amazon Bedrock Data Automation (용례 셋 · 시각적 그라운딩·신뢰도 점수) — `docs.aws.amazon.com/bedrock/latest/userguide/bda.html` (2026-11-14 확인)
11. Amazon Q Developer IDE 플러그인 지원 종료 (`kiro.dev` 마이그레이션 가이드 링크) — `docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html` (2026-11-14 확인)
12. Amazon Q Developer 개요 (2027-04-30 EOS 문장 · 콘솔 쪽 `AWS assistant` 개명) — `docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/what-is.html` (2026-11-14 확인)
13. AgentCore harness (Strands가 구동한다 · `InvokeHarness` 상태) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/harness.html` (2026-11-14 확인)
14. Amazon Bedrock Agents Classic 유지 관리 모드 (신규 고객 비개방 · 프레임워크 코드가 필요한 자리) — `docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html` (2026-11-14 확인)
15. AGENTPERF05-BP02 (협업 모델 넷 · Step Functions를 결정적 위임 대안으로) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html` (2026-11-14 확인)
16. AGENTPERF06-BP03 (메타 도구 · 세 번 이상 반복되는 순서 · 안티패턴) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentperf06-bp03.html` (2026-11-14 확인)
17. CloudWatch Logs Insights로 로그 데이터 분석 (언어 셋 · 동시 한도 · 로그 그룹 생성 시각 제약 · 요금) — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html` (2026-11-14 확인)
18. AWS X-Ray 개요 (UDP 데몬 · 배치 업로드 · 트레이스 맵) — `docs.aws.amazon.com/xray/latest/devguide/aws-xray.html` (2026-11-14 확인)
19. Amazon ECS MCP 서버 (완전관리형 호스팅 · IAM·CloudTrail) — `docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-mcp-introduction.html` (2026-11-14 확인)
