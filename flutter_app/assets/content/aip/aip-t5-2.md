---
examGuideTaskId: aip-t5-2
certCode: AIP-C01
domain: 5
domainName: 테스트, 검증 및 문제 해결
domainWeightPct: 11
title: GenAI 애플리케이션 문제 해결 (콘텐츠 처리·API 통합·프롬프트·검색 시스템·프롬프트 운영)
coversTasks:
  - "5.2"
sources:
  - title: Converse API 참조 — stopReason과 오류
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
  - title: CountTokens API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html
  - title: 콘텐츠 청킹 전략
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html
  - title: 지식 베이스 질의 구성과 검색 유형
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html
  - title: Amazon Titan Text Embeddings
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html
  - title: Aurora PostgreSQL을 Amazon Bedrock 지식 베이스로 쓰기
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
  - title: 모델 호출 로깅
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
  - title: Amazon Bedrock 런타임 지표 모니터링
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html
  - title: 프롬프트 버전 비교
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-version-compare.html
  - title: 구조화된 출력
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/structured-output.html
  - title: API Gateway 요청 검증
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html
  - title: AWS X-Ray란 무엇인가
    url: https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html
  - title: 평가 문제 진단
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/diagnose-evaluation-issues.html
  - title: RAG 평가 지표
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html
  - title: 지식 베이스용 벡터 스토어 설정
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html
  - title: AIP-C01 시험 안내서 — 콘텐츠 도메인 5
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain5.html
lastVerified: 2026-11-17
---

# GenAI 애플리케이션 문제 해결 (콘텐츠 처리·API 통합·프롬프트·검색 시스템·프롬프트 운영)

> **커버하는 공식 Task** — AIP-C01 · 도메인 5 「테스트, 검증 및 문제 해결」(11%) · **작업 5.2 GenAI 애플리케이션 문제 해결** (`aip-t5-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(5.2.1~5.2.5)를 모두 덮습니다. 작업 5.1이 **「잘 되고 있는지 어떻게 재는가」**였다면 이 작업은 **「안 될 때 어디가 문제인지 어떻게 좁히는가」**입니다 — 그래서 기술 다섯 개가 **고장이 생기는 층**(콘텐츠 · API · 프롬프트 · 검색 · 운영)으로 갈립니다.

---

## ✅ 학습 목표 체크리스트

- [ ] `stopReason`으로 **잘림과 컨텍스트 초과**를 가른다
- [ ] 오류 코드로 **재시도할 것과 아닌 것**을 가른다
- [ ] **429가 둘**이라는 것과 각각의 처방을 안다
- [ ] 요청·응답 **검증 수단 셋**을 가른다
- [ ] 프롬프트 **버전 비교**가 무엇을 보여 주는지 안다
- [ ] 검색 문제를 **관련성·임베딩·청킹·벡터 성능**으로 좁힌다
- [ ] 「결과가 적다」의 **두 원인**을 안다
- [ ] 프롬프트 운영의 **로그·추적·스키마** 수단을 안다

---

## 🎯 왜 중요한가

GenAI 애플리케이션의 장애는 **대개 예외를 던지지 않습니다.** HTTP 200이 돌아오고, 지연도 정상이고, 오류율도 0인데 **응답이 잘려 있거나 사실이 틀려 있거나 엉뚱한 문서를 근거로 답합니다.**

그래서 기존 문제 해결 틀이 통하지 않습니다. 스택 트레이스가 없고, 재현이 안 되고(같은 프롬프트에 매번 다른 출력), 「무엇이 잘못됐는지」를 코드가 알려 주지 않습니다.

공식이 이 작업에 둔 수단들은 전부 **그 침묵을 깨는 신호**입니다 — 응답 자체에 왜 멈췄는지 적는 필드(`stopReason`), 호출 전에 토큰을 세는 API(`CountTokens`), 프롬프트와 응답 본문을 남기는 로그, 두 프롬프트 버전을 나란히 보여 주는 콘솔, 검색 품질을 숫자로 바꾸는 RAG 지표. 이 작업을 공부하는 일은 **그 신호들이 각각 어느 고장을 가리키는지 외우는 일**입니다.

---

## ⚡ 시험 직전 요약

- ⭐ **`stopReason`이 아홉 값**이고 **`max_tokens`(내 설정에 걸린 잘림)**와 **`model_context_window_exceeded`(컨텍스트 창 초과)**가 **다른 값**이다
- ⚠️⚠️ **429가 둘**이다 — `ThrottlingException`(계정 쿼터 초과)과 `ModelNotReadyException`(⭐ **SDK가 최대 5회 자동 재시도**)
- ⚠️ **400 `ValidationException`·408 `ModelTimeoutException`·424 `ModelErrorException`은 같은 요청을 다시 보내 해결되는 종류가 아니다**
- ⭐ **`CountTokens`의 반환값은 같은 입력을 보냈을 때 과금될 토큰 수와 일치**하고 응답은 **`inputTokens`**뿐이다 — 컨텍스트 초과의 **사전** 진단 수단
- ⚠️⚠️ **모델 호출 로깅은 기본이 꺼져 있고** 켜도 **소급되지 않는다.** 대상은 **같은 계정·같은 리전**뿐이고 **`bedrock-runtime` 엔드포인트로 들어온 호출만** 캡처된다
- ⚠️⚠️ **API Gateway 요청 검증은 필수 파라미터의 존재만 확인하고 유형·형식은 확인하지 않는다.** 페이로드 검증은 **일치하는 콘텐츠 유형이 없으면 수행되지 않는다**
- ⚠️ **구조화된 출력은 모든 `object`가 `additionalProperties: false`를 명시**해야 하고 아니면 400이다
- ⭐ **프롬프트 버전 비교는 두 버전의 JSON을 나란히 보여 주고** 한쪽에만 있는 필드를 **`+`(초록)·`-`(빨강)**로 표시하며 **테스트 변수를 채워 두 버전의 모델 응답까지 비교**한다
- ⚠️⚠️ **반환 결과 수가 요청보다 적어지는 경로가 둘**이고(계층형 청킹 · 표·그림 맥락 교체) **오류 없이** 적게 온다
- ⚠️ **X-Ray는 SDK가 직접 보내지 않고 UDP 데몬이 큐에 버퍼링해 배치 업로드**한다 — **데몬이 없으면 추적이 조용히 비어 있다**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **`stopReason`** | `Converse` 응답이 **왜 생성을 멈췄는지** 알려 주는 필드. 문제 해결의 1차 신호 |
| **`model_context_window_exceeded`** | 입력이 모델의 컨텍스트 창을 넘겼음을 알리는 **전용 `stopReason` 값** |
| **`CountTokens`** | 호출 전에 토큰 수를 세는 API. **모델별 토큰화**를 쓰고 응답은 `inputTokens`뿐 |
| **계층형 청킹** | 부모·자식 청크를 두고 **자식으로 검색해 부모로 대체**하는 전략 |
| **반복 인덱스 스캔** | 메타데이터 필터가 **HNSW 스캔 뒤에** 적용돼 결과가 모자랄 때 인덱스를 더 스캔하는 pgvector 기능 |
| **프롬프트 혼동** | 템플릿·변수·맥락이 섞여 모델이 지시를 잘못 해석하는 상태. 진단 단위는 **로그에 남은 실제 프롬프트** |
| **X-Ray 데몬** | 추적 데이터를 **UDP로 받아 버퍼링해 배치 업로드**하는 프로세스 |

---

## 📖 핵심 개념

### 1) 콘텐츠 처리 문제 (기술 5.2.1) {#content-processing}

> 🧠 원리: 「정보가 완전히 처리되지 않았다」는 증상은 거의 항상 **어딘가에서 잘렸다**는 뜻입니다. 그런데 잘리는 자리가 셋입니다 — **내가 정한 출력 한도**에서, **모델의 컨텍스트 창**에서, **검색이 넣어 준 청크의 경계**에서. 공식이 앞의 둘을 다른 신호로 구분해 두었고, 세 번째는 청킹 전략의 문제입니다.

**`stopReason`이 1차 신호입니다.** `Converse` 응답의 유효값은 다음과 같습니다.

```
end_turn | tool_use | max_tokens | stop_sequence | guardrail_intervened |
content_filtered | malformed_model_output | malformed_tool_use | model_context_window_exceeded
```

| 증상 | 신호 | 처방 |
|---|---|---|
| **응답이 중간에 끊겼다** | **`max_tokens`** | 모델이 아니라 **내 `max_tokens` 설정**에 걸렸다 → 한도를 올린다 |
| ⭐ **컨텍스트 창을 넘겼다** | **`model_context_window_exceeded`** | **입력을 줄이거나 나눈다** — 한도를 올려 해결되지 않는다 |
| 도구 호출 형식이 깨졌다 | **`malformed_tool_use`** (모델 출력 전체면 `malformed_model_output`) | 스키마·도구 정의를 본다 |
| 가드레일이 막았다 | `guardrail_intervened` / `content_filtered` | 정책 구성을 본다 |

⚠️⚠️ **공식 기술이 「컨텍스트 창 오버플로 진단」과 「잘림 관련 오류 분석」을 따로 적는 이유가 이것입니다** — 둘을 한 신호로 묶으면 처방이 틀립니다.

**호출 전에 세는 수단**이 `CountTokens`입니다(**`POST /model/{modelId}/count-tokens`**).

- ⚠️ **토큰화가 모델별이라 모델을 지정**해야 하고, ⭐ 반환값은 **같은 입력을 `InvokeModel`·`Converse`로 보냈을 때 과금될 토큰 수와 일치**합니다.
- 입력은 `invokeModel` 또는 `converse` **중 하나**이고 응답은 **`inputTokens`**뿐입니다.
- 공식 용례 셋: **비용 추정 · 토큰 한도에 맞게 프롬프트 최적화 · 토큰 사용 계획.**

**동적 청킹 전략**은 검색이 넣어 주는 조각의 경계를 정합니다. 전략을 바꿀 때 두 사실이 따라옵니다.

- ⚠️⚠️ **반환 결과 수가 요청보다 적어질 수 있고 오류가 아닙니다** — **계층형 청킹**은 `numberOfResults`가 **자식 청크 수**에 매핑되고 같은 부모를 공유하는 자식들이 **부모 청크로 대체**되며, **표·그림이 있는 페이지**는 같은 맥락을 공유하는 청크가 **한 결과로 합쳐집니다.** ⭐ `numberOfResults`는 **최대치**입니다.
- ⚠️ **텍스트 전략은 텍스트 문서에만 적용됩니다** — 멀티모달 콘텐츠(오디오·비디오·이미지)는 그 전략을 타지 않고 **임베딩 모델 수준에서** 청킹됩니다.
- ⭐ **표 콘텐츠에서 청크 단위 결과를 받으려면 「청킹 없음」을 고르고 사용자 지정 변환 Lambda 함수에서 직접 청킹합니다** — 표·그림 맥락 교체는 **최대 토큰 한도를 두는 모든 청킹 전략**에 적용되고(맥락이 **10,000자 이하**일 때만 붙습니다) 청킹 없음에는 적용되지 않습니다.

**프롬프트 설계 최적화**는 `aip-t1-6` 문서의 프롬프트 관리 축과 이어집니다 — ⚠️ 단순 프롬프트 최적화는 **평가 데이터를 쓰지 않고 한 모델만** 보며 **약 1k 토큰 이하**에서 가장 잘 동작합니다.

---

### 2) FM 통합·API 문제 (기술 5.2.2) {#integration}

> 🧠 원리: API 통합 문제는 **코드가 알려 주는 쪽**이라 다루기 쉬울 것 같지만, GenAI에서는 한 가지가 특이합니다 — **같은 HTTP 코드가 완전히 다른 두 상태를 가리킵니다.** 그래서 「코드를 보고 처방한다」가 아니라 **「예외 이름을 보고 처방한다」**가 규율이 됩니다.

| 예외 | 코드 | ⚠️ |
|---|---|---|
| `ValidationException` | **400** | 입력이 제약을 만족하지 못한다 |
| `AccessDeniedException` | 403 | — |
| `ResourceNotFoundException` | 404 | 지정한 리소스가 없다 |
| **`ModelTimeoutException`** | **408** | 처리 시간이 **모델 타임아웃 길이**를 넘었다 |
| **`ModelErrorException`** | **424** | 모델 처리 중 오류(`originalStatusCode`·`resourceName`을 돌려준다) |
| **`ModelNotReadyException`** | **429** | ⭐ **SDK가 최대 5회 자동 재시도**한다 |
| **`ThrottlingException`** | **429** | **계정 쿼터 초과**로 거부됐다 |
| `InternalServerException` | 500 | — |
| `ServiceUnavailableException` | 503 | — |

- ⚠️⚠️ **429가 둘입니다** — 쿼터 초과(`ThrottlingException`)와 모델 준비 안 됨(`ModelNotReadyException`). **코드만 보고 쿼터를 올리면 틀립니다.**
- ⚠️ **400·408·424는 같은 요청을 다시 보내 해결되는 종류가 아닙니다.**

**오류 로깅**은 두 장치를 함께 씁니다.

- **모델 호출 로깅**이 **전체 요청 데이터·응답 데이터·메타데이터**를 남깁니다. ⚠️⚠️ **기본이 비활성**이므로 **과거 시점의 본문은 지금 켜도 소급되지 않습니다.** 대상 작업은 **`Converse`·`ConverseStream`·`InvokeModel`·`InvokeModelWithResponseStream`** 넷이고, 대상은 **Amazon S3와 CloudWatch Logs**인데 ⚠️ **같은 계정·같은 리전만** 지원하며 ⚠️⚠️ **`bedrock-runtime` 엔드포인트로 들어온 호출만** 캡처됩니다.
- **CloudWatch 런타임 지표**가 「얼마나」를 줍니다. ⚠️⚠️ 경계가 직관과 달라 오진을 부릅니다 — `InvocationThrottles`는 **`Invocations`·`ClientErrors`·`ServerErrors` 어디에도 들어가지 않고**(보이는 수는 **SDK 재시도 설정에 따라 달라집니다**) 반대로 **쿼터 초과로 거부된 요청은 `InvocationClientErrors`**에 들어갑니다. 자세한 것은 `aip-t4-3` 문서 §2입니다.

**요청 검증**의 수단이 둘이고 각각 보는 것이 다릅니다.

- **API Gateway 요청 검증**: ⚠️⚠️ **필수 요청 파라미터·헤더·쿼리의 존재만 확인하고 유형이나 형식은 확인하지 않습니다.** 페이로드는 모델 스키마로 검증하되 ⚠️ **요청의 콘텐츠 유형에 일치하는 모델이 없으면 검증이 수행되지 않습니다**(`$default`로 두면 무관해집니다).
- **구조화된 출력**: 응답 쪽 스키마를 모델에 강제합니다. ⚠️ 모든 `object`가 **`additionalProperties: false`를 명시**해야 하고 아니면 **400**이며, **재귀 스키마·외부 `$ref`·수치 제약·문자열 제약이 미지원**입니다(자세한 것은 `aip-t3-1` 문서 §3).

**응답 분석**은 `stopReason`(§1)과 모델 호출 로그의 본문을 함께 봅니다 — 지표만으로는 「200인데 내용이 잘렸다」를 볼 수 없습니다.

---

### 3) 프롬프트 엔지니어링 문제 (기술 5.2.3) {#prompt-troubleshoot}

> 🧠 원리: 프롬프트를 고칠 때 가장 흔한 실패는 **무엇을 바꿨는지 모르는 것**입니다. 템플릿이 길어지면 변경이 여러 줄에 걸치고, 출력이 비결정적이라 「좋아진 것 같다」는 느낌만 남습니다. 그래서 공식 수단이 **변경 자체를 보여 주는 것**과 **같은 입력으로 두 버전을 돌려 보는 것** 둘입니다.

**프롬프트 버전 비교**가 그 자리입니다.

- 콘솔이 **두 버전의 JSON을 나란히** 보여 주고 **한쪽에만 있는 필드를 `+`(초록)·`-`(빨강)**로 표시합니다.
- ⭐ 그리고 **테스트 변수를 채워 `Run prompt`로 두 버전의 모델 응답까지 비교**합니다 — 공식 기술이 드는 「버전 비교」가 이것입니다.

**프롬프트 테스트 프레임워크**는 작업 5.1의 장치를 그대로 씁니다 — 같은 프롬프트 데이터세트에 **판정 모델 평가**나 **사람 평가**를 걸어 두 버전을 같은 척도로 채점하고(`aip-t5-1` 문서 §2·§3), **CI/CD 품질 게이트**로 회귀를 막습니다(`aip-t5-1` 문서 §4). ⚠️ **정확 일치 단정은 비결정적 출력을 깨뜨리므로** 의미 동등성으로 봅니다.

**체계적 개선**의 순서는 **① 로그에서 실제로 모델에 들어간 프롬프트를 확인하고**(§5) **② 한 번에 한 가지만 바꾸고** **③ 버전으로 고정해 비교하고** **④ 평가로 채점하는** 것입니다. ⚠️ 프롬프트 관리의 프롬프트를 호출에 쓰면 **`inferenceConfig`·`system`·`toolConfig`·`additionalModelRequestFields`를 요청에 넣을 수 없다**는 제약이 있습니다(`aip-t2-2` 문서 §4).

---

### 4) 검색 시스템 문제 (기술 5.2.4) {#retrieval-troubleshoot}

> 🧠 원리: RAG가 엉뚱한 답을 줄 때 범인은 **네 층 중 하나**입니다 — 임베딩이 의미를 못 담았거나, 청킹이 맥락을 끊었거나, 벡터 검색이 못 찾았거나, 찾아 놓고 생성이 어긋났거나. 이 네 층을 **순서대로** 좁히는 것이 이 기술의 전부이고, 각 층마다 공식이 주는 신호가 다릅니다.

**① 모델 응답 관련성 분석** — RAG 평가로 숫자를 만듭니다. **`Retrieve only`**(`ContextRelevance`·`ContextCoverage`)로 검색 쪽을, **`Retrieve and generate`**(`Faithfulness`·`CitationPrecision`·`CitationCoverage` 등 열 개)로 생성 쪽을 봅니다. ⚠️ **ContextCoverage는 그라운드 트루스가 필수**입니다(`aip-t5-1` 문서 §5·§6).

**② 임베딩 품질 진단** — 차원과 처리량 제약을 봅니다.

- Titan Text Embeddings는 **1,024 / 512 / 256** 차원을 제공합니다 — 차원을 줄이면 저장·검색 비용이 줄고 정확도 절충이 생깁니다.
- ⚠️ 임베딩 모델의 쿼터는 **TPM이 아니라 RPM**이라 대량 수집에서 **요청 수**가 병목이 됩니다.
- ⚠️ 데이터 소스가 **어떤 필드를 임베딩에 포함할지 지정**할 수 있으므로, 「관련 없는 필드가 임베딩을 흐린다」는 그 설정으로 좁힙니다.

**③ 청킹·전처리 개선** — §1의 두 사실이 그대로 적용됩니다. ⚠️⚠️ **반환 결과 수가 요청보다 적은 것은 결함이 아니고**(계층형 청킹 · 표·그림 맥락 교체) ⚠️ **멀티모달은 텍스트 청킹 전략을 타지 않습니다.**

**④ 벡터 검색 성능 최적화** — 스토어마다 신호가 다릅니다.

- ⚠️⚠️ **Aurora pgvector에서 메타데이터 필터가 기대보다 적은 결과를 조용히 돌려주는 것**은 **반복 인덱스 스캔이 꺼져 있기 때문**입니다(**`pgvector` 0.8.0 이상** 필요) — **필터가 HNSW 인덱스 스캔 뒤에 적용**되기 때문입니다.
- ⚠️ 그리고 **Bedrock이 질의에 쓰는 인덱스가 셋**입니다 — 벡터용 **HNSW**, 텍스트용 **GIN**(`to_tsvector`), 사용자 지정 메타데이터용 **GIN**. **벡터 인덱스만 만들면** 텍스트 검색과 메타데이터 필터가 제 성능을 내지 못합니다. ⭐ **`ef_construction`을 256**으로 두는 것이 권장이고 그 조건은 **병렬 인덱스 빌드를 쓰는 `pgvector` 0.6.0 이상**입니다.
- OpenSearch 쪽의 **용량 한계 신호와 데이터 품질 검증**은 `aip-t4-3` 문서 §5가 소유합니다 — ⚠️⚠️ **`KNNGraphMemoryUsagePercentage`가 100%에 닿으면 서킷 브레이커가 발동해 새 색인이 거부**되고, **동기화 `COMPLETE`가 곧 검색 가능은 아닙니다**(Aurora 외 스토어는 몇 분).

**드리프트 모니터링** — 「어제는 맞던 답이 오늘 틀리다」는 드리프트 신호입니다. ⚠️⚠️ 종류가 **셋**이고 처방이 다릅니다: **데이터 드리프트**(입력 분포 변화) · **개념 드리프트**(입력-출력 관계 변화) · **성능 드리프트**(출력 품질 저하). 기준선과 행동 지표는 `aip-t4-3` 문서 §3입니다.

**질의 쪽 설정도 함께 봅니다** — 검색 유형, **하이브리드 검색이 지원되는 스토어**, **암시적 필터**(Bedrock이 쿼리와 메타데이터 스키마로 필터를 생성·적용) 같은 선택이 결과 집합을 바꿉니다. ⚠️ 관리형 지식 베이스의 필터 연산자에는 **`startsWith`·`stringContains`가 없습니다.**

---

### 5) 프롬프트 유지 관리와 관찰성 (기술 5.2.5) {#prompt-ops}

> 🧠 원리: 프롬프트 문제의 진단이 어려운 이유는 **내가 쓴 프롬프트와 모델이 받은 프롬프트가 다를 수 있다**는 것입니다 — 템플릿 변수, 검색이 끼워 넣은 청크, 시스템 프롬프트, 도구 정의가 모두 합쳐져 최종 입력이 됩니다. 그래서 운영 단계의 1차 수단이 **「실제로 들어간 것」을 남기는 로그**이고, 그다음이 **그 요청이 어느 고리에서 시간을 썼는지 보는 추적**입니다.

**① 템플릿 테스트와 CloudWatch Logs로 프롬프트 혼동 진단**

- **모델 호출 로깅**이 **최종 프롬프트와 응답 본문**을 남깁니다 — 「템플릿이 의도대로 렌더됐는가」를 볼 수 있는 유일한 자리입니다. ⚠️⚠️ **기본이 꺼져 있으므로 문제가 생긴 뒤에 켜면 그 시점의 프롬프트는 없습니다.**
- ⚠️ CloudWatch Logs Insights로 질의할 때 제약이 있습니다 — **로그 그룹 생성 시각보다 앞선 타임스탬프의 이벤트에 접근할 수 없고**, 요금은 **언어와 무관하게 스캔한 비압축 데이터 양**이며, 쿼리는 **60분 타임아웃**에 결과는 **7일** 제공됩니다(`aip-t2-1` 문서 §5).
- 템플릿 자체의 비교는 §3의 **버전 비교**로 합니다.

**② X-Ray로 관찰성 파이프라인 구현**

- X-Ray가 요청 데이터를 수집해 **병목과 오류**를 식별합니다 — RAG·도구 호출·서비스 간 왕복이 섞인 요청에서 **어느 고리가 느렸는지**를 보는 수단입니다.
- ⚠️⚠️ **SDK가 추적을 직접 보내지 않습니다** — **UDP 데몬이 큐에 버퍼링해 배치 업로드**합니다. **데몬이 없으면 추적이 조용히 비어 있습니다**(오류가 아니라 빈 결과로 나타납니다).
- 에이전트 쪽의 세션·트레이스·스팬과 **ADOT 계측**은 `aip-t4-3` 문서 §1이 소유합니다.

**③ 형식 불일치를 탐지하는 스키마 검증**

- 응답 쪽은 **구조화된 출력**으로 스키마를 강제합니다 — ⚠️ 모든 `object`에 **`additionalProperties: false`**가 필요하고(아니면 400), **첫 컴파일이 최대 약 90초**이며 **24시간 캐시**되고 **선택 속성은 12개**까지입니다.
- 요청 쪽은 **API Gateway 요청 검증**이고 ⚠️⚠️ **존재만 확인하며 유형·형식은 보지 않습니다.**
- ⭐ 그래서 「형식이 틀렸다」는 신고에는 **어느 쪽 스키마인지**를 먼저 가릅니다 — 모델이 낸 JSON이 깨졌으면 구조화된 출력과 `malformed_model_output`, 클라이언트가 보낸 것이 틀렸으면 요청 검증입니다.

**④ 평가 파이프라인 자체가 안 돌 때**

평가가 「빈 결과」를 주는 것도 이 작업의 문제 해결 대상입니다. 공식이 흔한 원인을 열거합니다.

- **빈 평가 결과**(구성은 켜져 있는데 점수가 없다)
- **`LogEventMissingException`** — 스팬에 대응하는 로그 이벤트가 없다
- **`AgentSpanMappingException`·`ToolSpanMappingException`** — 스팬에서 사용자 질의나 도구 출력을 추출할 수 없다
- **`SpanEventParsingException`** · **`Gateway Timeout (504)`**
- **`evaluatorId`의 `ValidationException`** — 평가자 ID 형식이 틀렸다
- **다중 에이전트 평가 스코핑** — 평가자가 다중 에이전트 트레이스에서 **엉뚱한 에이전트를 겨냥**한다

⚠️⚠️ 전제가 중요합니다 — **에이전트가 관찰성을 켠 상태로 최소 한 번 호출됐어야** 진단이 성립합니다. ⭐ 진단은 **내 계정의 CloudWatch 로그 그룹을 질의**하고 서비스 측 접근은 필요하지 않습니다(필요 권한: `logs:DescribeLogGroups`·`DescribeLogStreams`·`StartQuery`·`GetQueryResults`).

---

## ✍️ 시험 포인트

- ⭐ **`max_tokens` ↔ `model_context_window_exceeded`**가 이 작업에서 가장 많이 갈리는 자리입니다. 앞은 **한도를 올려** 해결되고 뒤는 **입력을 줄여야** 합니다.
- ⚠️⚠️ **429가 둘**이고 `ModelNotReadyException`은 **SDK가 최대 5회 자동 재시도**합니다. 「429니까 쿼터 증액」은 틀린 처방일 수 있습니다.
- **400·408·424는 재시도 대상이 아니다**를 함께 기억합니다.
- ⚠️⚠️ **모델 호출 로깅은 기본 꺼짐 + 소급 안 됨 + 같은 계정·리전 + `bedrock-runtime`만** — 네 제약이 로깅 문항의 핵심입니다.
- ⚠️ **스로틀은 오류 지표 어디에도 안 들어가고 쿼터 초과는 클라이언트 오류로 센다** — 「오류율 0인데 사용자는 실패를 본다」의 답입니다.
- ⚠️⚠️ **API Gateway 요청 검증은 존재만** 확인합니다. 유형·형식 검증을 그것으로 기대하는 보기는 공식과 어긋납니다.
- **구조화된 출력의 `additionalProperties: false`**와 **미지원 네 가지**(재귀·외부 `$ref`·수치 제약·문자열 제약)가 스키마 문항의 갈림길입니다.
- ⭐ **버전 비교는 JSON diff + 테스트 변수로 응답까지** 비교합니다 — 「JSON만 본다」는 절반입니다.
- ⚠️⚠️ **「결과가 적다」는 오류가 아닐 수 있습니다** — 계층형 청킹과 표·그림 맥락 교체가 **오류 없이** 줄입니다. `numberOfResults`는 **최대치**입니다.
- ⚠️ **같은 「결과가 적다」의 다른 원인**이 Aurora의 **반복 인덱스 스캔 부재**입니다(필터가 HNSW 스캔 뒤에 적용). 둘을 구별하는 것이 검색 문제 해결의 핵심입니다.
- **임베딩 쿼터는 RPM**이고 Titan 차원은 **1,024/512/256**입니다.
- **드리프트 세 종류**(데이터·개념·성능)를 구분하지 못하면 처방이 엉뚱해집니다.
- ⚠️ **X-Ray는 데몬이 없으면 조용히 빈 추적**입니다 — 「추적이 안 보인다」의 1차 원인입니다.
- **평가가 빈 결과를 줄 때**는 예외 이름으로 좁히고, 전제는 **관찰성을 켠 상태로 최소 한 번 호출**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **「응답이 잘렸으니 컨텍스트 창을 넘겼다」** → `stopReason`이 **`max_tokens`**면 내 설정이고, 컨텍스트 초과는 **`model_context_window_exceeded`**라는 전용 값으로 옵니다.
- ❌ **「`max_tokens`를 올려 컨텍스트 초과를 해결한다」** → 방향이 반대입니다. 입력을 줄이거나 나눕니다.
- ❌ **「429니까 쿼터를 증액한다」** → `ModelNotReadyException`도 429이고 **SDK가 자동 재시도**하는 종류입니다.
- ❌ **「400 `ValidationException`을 지수 백오프로 재시도한다」** → **400·408·424는 다시 보내 해결되는 종류가 아닙니다.**
- ❌ **「지금 모델 호출 로깅을 켜고 어제 프롬프트를 본다」** → **기본 꺼짐이고 소급되지 않습니다.**
- ❌ **「모델 호출 로그를 다른 리전 중앙 버킷으로 모은다」** → **같은 계정·같은 리전**만 지원합니다.
- ❌ **「요청 검증을 켜면 파라미터 유형까지 검증된다」** → **존재만** 확인합니다. 페이로드도 **콘텐츠 유형에 일치하는 모델이 없으면 검증되지 않습니다.**
- ❌ **「구조화된 출력에 재귀 스키마를 쓴다」** → 미지원입니다. `additionalProperties: false` 누락은 **400**입니다.
- ❌ **「프롬프트 버전 비교는 텍스트 diff만 보여 준다」** → **JSON을 나란히 보여 주고 `+`·`-`로 표시하며 테스트 변수로 두 버전의 응답까지** 비교합니다.
- ❌ **「프롬프트를 두 군데 동시에 고쳐 비교한다」** → 무엇이 효과였는지 알 수 없습니다. **한 번에 한 가지**만 바꾸고 버전으로 고정합니다.
- ❌ **「반환 결과가 요청보다 적으니 벡터 인덱스가 깨졌다」** → **계층형 청킹**과 **표·그림 맥락 교체**가 오류 없이 줄입니다. `numberOfResults`는 최대치입니다.
- ❌ **「멀티모달 문서에 의미 기반 청킹을 적용한다」** → 텍스트 전략은 **텍스트 문서에만** 적용되고 멀티모달은 **임베딩 모델 수준**에서 청킹됩니다.
- ❌ **「HNSW 인덱스를 만들었으니 메타데이터 필터도 정확하다」** → **반복 인덱스 스캔**(`pgvector` 0.8.0+)이 없으면 결과가 **조용히** 모자랍니다. 그리고 **텍스트용·메타데이터용 GIN 인덱스가 따로** 필요합니다.
- ❌ **「임베딩 쿼터는 TPM이니 토큰을 줄이면 된다」** → 임베딩 모델은 **RPM**입니다. 줄여야 하는 것은 **요청 수**입니다.
- ❌ **「`startsWith` 필터로 접두사 검색을 한다」** → 관리형 지식 베이스 필터에는 **`startsWith`·`stringContains`가 없습니다.**
- ❌ **「X-Ray SDK를 넣었는데 추적이 비어 있으니 버그다」** → **UDP 데몬이 버퍼링해 배치 업로드**합니다. 데몬이 없으면 조용히 비어 있습니다.
- ❌ **「평가 구성을 켰는데 점수가 없으니 평가 서비스 장애다」** → 예외 목록(`LogEventMissingException`·스팬 매핑 예외 등)으로 좁히고, 전제는 **관찰성을 켠 상태의 호출 이력**입니다.

---

## 🧪 자가 점검

**Q1.** 긴 계약서를 요약하는 기능에서 「응답이 중간에서 끊긴다」는 신고가 들어왔습니다. 무엇을 보고 어떻게 처방을 가릅니까?

<details><summary>정답 보기</summary>

**`stopReason`을 봅니다.** ⭐ `Converse` 응답의 유효값이 아홉이고 그중 둘이 「끊김」처럼 보이지만 **원인과 처방이 완전히 다릅니다**: **`max_tokens`**는 모델이 아니라 **내 `max_tokens` 설정**에 걸린 것이므로 **한도를 올리면** 해결되고, **`model_context_window_exceeded`**는 **입력이 모델의 컨텍스트 창을 넘긴 것**이므로 **입력을 줄이거나 나눠야** 하고 한도를 올려도 해결되지 않습니다. ⚠️⚠️ 공식 기술이 「컨텍스트 창 오버플로 진단」과 「잘림 관련 오류 분석」을 **따로 적는 이유**가 이것이고, 둘을 한 신호로 묶으면 처방이 틀립니다. 다른 값도 함께 기억합니다 — **`malformed_tool_use`**(도구 호출 형식), **`malformed_model_output`**(모델 출력 전체), **`guardrail_intervened`·`content_filtered`**(차단), 정상 종료는 `end_turn`·`stop_sequence`·`tool_use`입니다. ⭐ **사전에 가리려면 `CountTokens`**(`POST /model/{modelId}/count-tokens`)를 씁니다 — ⚠️ **토큰화가 모델별이라 모델을 지정**해야 하고, 반환값은 **같은 입력을 보냈을 때 과금될 토큰 수와 일치**하며 응답은 **`inputTokens`**뿐입니다. 공식 용례는 **비용 추정 · 토큰 한도에 맞게 프롬프트 최적화 · 토큰 사용 계획**입니다.
</details>

**Q2.** 간헐적으로 429가 납니다. 팀이 「쿼터 증액을 요청하자」고 합니다. 어떻게 판단합니까?

<details><summary>정답 보기</summary>

**예외 이름을 먼저 봅니다 — 429가 둘입니다.** ⚠️⚠️ **`ThrottlingException`**은 **계정 쿼터 초과**로 거부된 것이라 쿼터 증액이나 요청 분산이 맞고, **`ModelNotReadyException`**은 **모델이 준비되지 않은 것**이라 ⭐ **SDK가 최대 5회 자동 재시도**하는 종류입니다. **코드만 보고 쿼터 문제로 처방하면 틀립니다.** 함께 기억할 분류 — **400 `ValidationException`**(입력이 제약 미충족) · **408 `ModelTimeoutException`**(처리 시간이 모델 타임아웃을 넘음) · **424 `ModelErrorException`**(모델 처리 중 오류, `originalStatusCode`·`resourceName`을 돌려준다)은 ⚠️ **같은 요청을 다시 보내 해결되는 종류가 아닙니다.** ⚠️⚠️ 그리고 지표로 확인할 때 경계가 직관과 다릅니다 — **`InvocationThrottles`는 `Invocations`·`ClientErrors`·`ServerErrors` 어디에도 들어가지 않고** 보이는 수가 **SDK 재시도 설정에 따라 달라지며**, 반대로 **서비스 쿼터 초과로 거부된 요청은 `InvocationClientErrors`**에 들어갑니다. 그래서 「오류율이 0인데 사용자는 실패를 본다」가 성립합니다.
</details>

**Q3.** 사고 조사를 위해 「어제 오후에 모델에 실제로 들어간 프롬프트」가 필요합니다. CloudTrail에는 본문이 없습니다. 무엇을 확인하고 앞으로는 어떻게 합니까?

<details><summary>정답 보기</summary>

**본문은 모델 호출 로깅이 남기고, 그것은 기본이 꺼져 있습니다.** ⚠️⚠️ 따라서 **지금 켜도 어제의 본문은 없습니다**(소급되지 않습니다). CloudTrail은 **요청 메타데이터**를 남기는 다른 장치입니다. 앞으로 켤 때 확인할 것들 — 대상 작업은 **`Converse`·`ConverseStream`·`InvokeModel`·`InvokeModelWithResponseStream`** 넷, 대상 저장소는 **Amazon S3와 CloudWatch Logs**이며 ⚠️ **같은 계정·같은 리전만** 지원하고, ⚠️⚠️ **`bedrock-runtime` 엔드포인트로 들어온 호출만** 캡처되므로 다른 엔드포인트를 거치는 호출은 남지 않습니다. 켜면 **로깅 구성을 삭제할 때까지** 저장됩니다. ⚠️ 조회 쪽 제약도 있습니다 — CloudWatch Logs Insights는 **로그 그룹 생성 시각보다 앞선 타임스탬프의 이벤트에 접근할 수 없고**, 쿼리는 **60분 타임아웃**이며 결과는 **7일** 제공되고 요금은 **스캔한 비압축 데이터 양**입니다. ⭐ 이 로그가 프롬프트 혼동 진단의 1차 수단인 이유는 **내가 쓴 템플릿과 모델이 받은 최종 입력이 다를 수 있기** 때문입니다 — 템플릿 변수·검색 청크·시스템 프롬프트·도구 정의가 합쳐집니다.
</details>

**Q4.** 프롬프트를 개선하려는데 「버전 3이 버전 2보다 나은지」를 어떻게 확인해야 할지 팀 의견이 갈립니다. 공식 수단으로 어떤 절차를 제안합니까?

<details><summary>정답 보기</summary>

**버전 비교 → 평가 → 품질 게이트 순서입니다.** 먼저 **프롬프트 버전 비교**가 변경 자체를 보여 줍니다 — 콘솔이 **두 버전의 JSON을 나란히** 놓고 **한쪽에만 있는 필드를 `+`(초록)·`-`(빨강)**으로 표시하며, ⭐ **테스트 변수를 채워 `Run prompt`로 두 버전의 모델 응답까지** 비교합니다. 다음으로 **같은 프롬프트 데이터세트에 평가**를 걸어 같은 척도로 채점합니다 — 판정 모델 평가의 내장 지표나 사용자 지정 지표, 주관적 판단이 필요하면 사람 평가의 **선택 버튼이나 Likert 비교**입니다. 마지막으로 ⭐ **CI/CD 품질 게이트로 평가자를 써서** 회귀를 막습니다. ⚠️ 이때 **정확 일치 단정을 쓰면 안 됩니다** — 비결정적 출력을 깨뜨리므로 **의미 동등성**으로 봅니다. ⚠️ 절차 규율 둘 — **한 번에 한 가지만 바꾸고**(여러 군데를 고치면 무엇이 효과였는지 알 수 없습니다) **로그에서 실제로 들어간 프롬프트를 먼저 확인**합니다. ⚠️ 그리고 프롬프트 관리의 프롬프트를 호출에 쓰면 **`inferenceConfig`·`system`·`toolConfig`·`additionalModelRequestFields`를 요청에 넣을 수 없다**는 제약이 있습니다.
</details>

**Q5.** RAG 챗봇이 「관련 없는 문서를 근거로 답한다」는 신고를 받았습니다. 어떤 순서로 원인을 좁힙니까?

<details><summary>정답 보기</summary>

**네 층을 순서대로 좁힙니다.** ① **관련성을 숫자로** 만듭니다 — **`Retrieve only`** 평가(`Builtin.ContextRelevance`·`ContextCoverage`, ⚠️ **커버리지는 그라운드 트루스 필수**)로 **검색 자체**를 재고, 문제가 없으면 **`Retrieve and generate`**의 **`Faithfulness`·`CitationPrecision`·`CitationCoverage`**로 생성 쪽을 봅니다. ② **임베딩 품질** — Titan Text Embeddings의 차원은 **1,024/512/256**이고 줄이면 정확도 절충이 생기며, ⚠️ 임베딩 모델 쿼터는 **TPM이 아니라 RPM**이라 대량 수집의 병목이 **요청 수**입니다. ⚠️ 데이터 소스가 **어떤 필드를 임베딩에 포함할지 지정**하므로 「관련 없는 필드가 임베딩을 흐린다」를 그 설정으로 봅니다. ③ **청킹·전처리** — ⚠️⚠️ **반환 결과 수가 요청보다 적은 것은 결함이 아닙니다**(계층형 청킹은 자식이 부모로 대체되고, 표·그림 페이지는 같은 맥락 청크가 한 결과로 합쳐집니다. `numberOfResults`는 **최대치**입니다). ⚠️ **멀티모달은 텍스트 전략을 타지 않습니다.** ④ **벡터 검색 성능** — ⚠️⚠️ Aurora에서 **메타데이터 필터가 조용히 결과를 줄이는 것**은 **반복 인덱스 스캔**(`pgvector` 0.8.0+) 부재이고(필터가 HNSW 스캔 **뒤에** 적용), **Bedrock이 쓰는 인덱스가 셋**(HNSW·텍스트 GIN·메타데이터 GIN)이라 벡터만 만들면 텍스트·필터 성능이 안 납니다. ⚠️ 질의 쪽 설정(검색 유형·하이브리드 지원 스토어·암시적 필터)도 결과 집합을 바꾸고, 관리형 KB 필터에는 **`startsWith`·`stringContains`가 없습니다.**
</details>

**Q6.** 「지난주까지 잘 맞던 답이 요즘 자주 틀리다」는 보고가 왔습니다. 모델도 프롬프트도 바꾸지 않았습니다. 무엇을 의심하고 어떻게 구분합니까?

<details><summary>정답 보기</summary>

**드리프트이고 종류가 셋이라 처방이 다릅니다.** ⚠️⚠️ **데이터 드리프트**는 **입력 분포가 변한 것**(사용자가 전에 없던 종류의 질문을 하기 시작했다), **개념 드리프트**는 **입력-출력 관계가 변한 것**(같은 질문의 정답이 바뀌었다 — 정책·가격·제품이 바뀐 경우), **성능 드리프트**는 **출력 품질 자체가 저하된 것**입니다. 구분하는 방법은 **기준선과 행동 지표**입니다 — **2~4주** 관찰로 기준선을 세우고 **에스컬레이션 비율·작업 완료율·신뢰도 점수 분포** 같은 행동 지표를 보며, ⚠️⚠️ **성능 지표(지연·오류율)는 필요하지만 충분하지 않습니다**(자세한 것은 `aip-t4-3` 문서 §3). RAG라면 **지식 베이스 쪽**도 봅니다 — 데이터 소스가 바뀐 뒤 **동기화를 했는지**, 동기화가 `COMPLETE`여도 ⚠️ **Aurora 외의 벡터 스토어는 새 임베딩이 질의에 반영되기까지 몇 분** 걸립니다(`aip-t4-3` 문서 §5). 그리고 품질을 숫자로 확인하려면 **같은 평가 데이터세트를 다시 돌려 전과 비교**합니다 — 그것이 회귀 테스트이고, ⭐ 경보는 **임계 위반과 지속적 하락 추세 둘 다**에 걸고 **단일 시점의 하락에는 걸지 않습니다.**
</details>

**Q7.** 모델이 돌려준 JSON을 파싱하다 실패하는 일이 간헐적으로 생깁니다. 그리고 클라이언트가 보낸 요청 형식이 틀린 경우도 섞여 있습니다. 각각 어떻게 막습니까?

<details><summary>정답 보기</summary>

**두 방향의 스키마가 다른 수단입니다.** **모델이 내는 쪽**은 **구조화된 출력**으로 강제합니다 — ⚠️ 모든 `object`가 **`additionalProperties: false`를 명시**해야 하고 아니면 **400**이며, **재귀 스키마·외부 `$ref`·수치 제약·문자열 제약이 미지원**입니다. **첫 컴파일이 최대 약 90초**이고 **24시간 캐시**되며 **선택 속성은 12개**까지입니다. 그래도 깨지면 `stopReason`이 **`malformed_model_output`**(출력 전체) 또는 **`malformed_tool_use`**(도구 호출)로 옵니다. **클라이언트가 보내는 쪽**은 **API Gateway 요청 검증**인데 ⚠️⚠️ **필수 요청 파라미터·헤더·쿼리의 존재만 확인하고 유형이나 형식은 확인하지 않습니다.** 페이로드는 모델 스키마로 검증하지만 ⚠️ **요청의 콘텐츠 유형에 일치하는 모델이 없으면 검증이 수행되지 않습니다**(`$default`로 두면 무관해집니다). ⭐ 그래서 「형식 불일치」 신고에는 **어느 쪽 스키마인지를 먼저 가릅니다** — 모델 출력이면 구조화된 출력과 `stopReason`, 클라이언트 입력이면 요청 검증이고, 유형·형식까지 봐야 하면 애플리케이션 계층에서 따로 검증해야 합니다.
</details>

**Q8.** 에이전트 평가를 켰는데 점수가 비어 있습니다. 그리고 X-Ray 콘솔에도 추적이 보이지 않습니다. 각각 무엇을 확인합니까?

<details><summary>정답 보기</summary>

**둘 다 「오류 없이 비어 있는」 종류의 고장입니다.** 평가 쪽은 공식이 흔한 원인을 열거합니다 — **빈 평가 결과**(구성은 켜져 있는데 점수가 없다) · **`LogEventMissingException`**(스팬에 대응하는 로그 이벤트가 없다) · **`AgentSpanMappingException`·`ToolSpanMappingException`**(스팬에서 사용자 질의나 도구 출력을 추출할 수 없다) · **`SpanEventParsingException`** · **`Gateway Timeout (504)`** · **`evaluatorId`의 `ValidationException`**(평가자 ID 형식) · **다중 에이전트 평가 스코핑**(평가자가 엉뚱한 에이전트를 겨냥). ⚠️⚠️ 전제가 가장 자주 걸립니다 — **에이전트가 관찰성을 켠 상태로 최소 한 번 호출됐어야** 진단이 성립하고, **계측만으로는 평가되지 않습니다**(관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야 합니다). ⭐ 진단 자체는 **내 계정의 CloudWatch 로그 그룹을 질의**하므로 서비스 측 접근이 필요하지 않습니다(필요 권한 `logs:DescribeLogGroups`·`DescribeLogStreams`·`StartQuery`·`GetQueryResults`). X-Ray 쪽은 ⚠️⚠️ **SDK가 추적을 직접 보내지 않는다**는 것이 1차 원인입니다 — **UDP 데몬이 큐에 버퍼링해 배치 업로드**하므로 **데몬이 없거나 UDP 경로가 막혀 있으면 추적이 조용히 비어 있습니다.** 오류로 나타나지 않기 때문에 「버그」로 오진하기 쉬운 자리입니다.
</details>

---

### 📌 출처

1. Converse API 참조 (`stopReason` 아홉 값 · 오류 아홉 종과 HTTP 코드 · `ModelNotReadyException`의 SDK 자동 재시도 · `ModelErrorException`의 `originalStatusCode`) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html` (2026-11-15 확인)
2. CountTokens API 참조 (모델별 토큰화 · 과금 토큰과 일치 · 입력 Union · 응답은 `inputTokens` · 용례 셋) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html` (2026-11-15 확인)
3. 콘텐츠 청킹 전략 (전략 종류 · 표·그림 맥락 교체 · 멀티모달은 텍스트 전략 미적용) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-chunking.html` (2026-11-15 확인)
4. 지식 베이스 질의 구성 (검색 유형 · 하이브리드 지원 스토어 · 암시적 필터 · `numberOfResults`의 계층형 매핑과 최대치 · 관리형 KB 필터 연산자) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-test-config.html` (2026-11-15 확인)
5. Amazon Titan Text Embeddings (1,024/512/256 차원 · **RPM 스로틀**) — `docs.aws.amazon.com/bedrock/latest/userguide/titan-embedding-models.html` (2026-11-15 확인)
6. Aurora PostgreSQL을 Bedrock 지식 베이스로 (인덱스 셋 — HNSW·텍스트 GIN·메타데이터 GIN · `ef_construction` 256과 pgvector 0.6.0) — `docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html` (2026-11-15 확인)
7. 모델 호출 로깅 (기본 꺼짐 · 대상 작업 넷 · 같은 계정·리전 · `bedrock-runtime`만 · 구성 삭제까지 저장) — `docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html` (2026-11-15 확인)
8. Bedrock 런타임 지표 (스로틀이 어느 집합에도 없음 · 쿼터 초과는 클라이언트 오류 · 보이는 스로틀 수가 SDK 재시도에 달림) — `docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html` (2026-11-15 확인)
9. 프롬프트 버전 비교 (JSON 나란히 · `+`·`-` 표시 · 테스트 변수로 두 버전 응답 비교) — `docs.aws.amazon.com/bedrock/latest/userguide/prompt-management-version-compare.html` (2026-11-15 확인)
10. 구조화된 출력 (`additionalProperties: false` 필수·아니면 400 · 미지원 네 가지 · 첫 컴파일 약 90초·24시간 캐시·선택 속성 12개) — `docs.aws.amazon.com/bedrock/latest/userguide/structured-output.html` (2026-11-15 확인)
11. API Gateway 요청 검증 (필수 파라미터의 존재만 확인 · 콘텐츠 유형 불일치 시 페이로드 검증 미수행) — `docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html` (2026-11-15 확인)
12. AWS X-Ray란 무엇인가 (요청 데이터 수집으로 병목·오류 식별 · SDK가 직접 보내지 않고 UDP 데몬이 버퍼링·배치 업로드) — `docs.aws.amazon.com/xray/latest/devguide/aws-xray.html` (2026-11-15 확인)
13. 평가 문제 진단 (빈 결과 · 예외 여섯 종 · 다중 에이전트 스코핑 · 관찰성 전제 · 필요 권한) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/diagnose-evaluation-issues.html` (2026-11-15 확인)
14. RAG 평가 지표 (Retrieve only 둘 ↔ Retrieve and generate 열 · ContextCoverage의 그라운드 트루스 요구 · 인용 지표) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-evaluation-metrics.html` (2026-11-15 확인)
15. 지식 베이스용 벡터 스토어 설정 (HNSW 반복 인덱스 스캔 · pgvector 0.8.0 · 필터가 HNSW 스캔 뒤에 적용) — `docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base-setup.html` (2026-11-17 확인)
16. AIP-C01 시험 안내서 콘텐츠 도메인 5 (기술 5.2.3·5.2.4·5.2.5의 예시 목록) — `docs.aws.amazon.com/ko_kr/aws-certification/latest/ai-professional-01/ai-professional-01-domain5.html` (2026-11-17 확인)
