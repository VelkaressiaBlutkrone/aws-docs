---
examGuideTaskId: aip-t4-3
certCode: AIP-C01
domain: 4
domainName: GenAI 애플리케이션을 위한 운영 효율성 및 최적화
domainWeightPct: 12
title: GenAI 모니터링 시스템 (관찰성 세 계층·이상 탐지·감사·도구·벡터 저장소 운영·실패 모드)
coversTasks:
  - "4.3"
sources:
  - title: AgentCore 관찰성과 텔레메트리 개념
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-telemetry.html
  - title: AGENTOPS05 — 포괄적 관찰성 구현
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05.html
  - title: AGENTOPS05-BP04 — 에이전트 KPI 정의와 추적
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp04.html
  - title: AGENTOPS05-BP02 — 행동 이상 탐지
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp02.html
  - title: AGENTOPS04-BP03 — 도구 신뢰성과 성능 추적
    url: https://docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp03.html
  - title: Amazon Bedrock 런타임 지표 모니터링
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html
  - title: 모델 호출 로깅
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html
  - title: CloudWatch 이상 탐지
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html
  - title: CloudTrail로 Amazon Bedrock API 호출 로깅
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html
  - title: CloudTrail Lake 가용성 변경
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html
  - title: 내장 도구 관찰성 데이터
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-tool-metrics.html
  - title: 관찰성 지원 프레임워크와 계측
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html
  - title: OpenSearch 클러스터 지표를 CloudWatch로 모니터링
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-cloudwatchmetrics.html
  - title: OpenSearch Service의 k-NN 검색 — 튜닝과 한계
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/knn.html
  - title: OpenSearch 샤드 수 선택
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html
  - title: OpenSearch Serverless 모니터링
    url: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-monitoring.html
  - title: Aurora PostgreSQL을 Amazon Bedrock 지식 베이스로 쓰기
    url: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
  - title: 지식 베이스와 데이터 동기화
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html
  - title: Converse API 참조 — stopReason과 오류
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html
  - title: CountTokens API 참조
    url: https://docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html
  - title: 평가 문제 진단
    url: https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/diagnose-evaluation-issues.html
  - title: 판정 모델 평가의 내장 지표
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html
lastVerified: 2026-11-15
---

# GenAI 모니터링 시스템 (관찰성 세 계층·이상 탐지·감사·도구·벡터 저장소 운영·실패 모드)

> **커버하는 공식 Task** — AIP-C01 · 도메인 4 「GenAI 애플리케이션을 위한 운영 효율성 및 최적화」(12%) · **작업 4.3 GenAI 애플리케이션을 위한 모니터링 시스템 구현** (`aip-t4-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 6개(4.3.1~4.3.6)를 모두 덮습니다. 작업 4.1이 「같은 결과를 더 싸게」, 작업 4.2가 「같은 비용으로 더 빠르게」였다면 이 작업은 **「그 둘이 실제로 되고 있는지 어떻게 아는가」**입니다. 그래서 공식 기술이 **무엇을 볼 것인가**(`4.3.1`~`4.3.3`)와 **무엇이 고장 났는지 어떻게 아는가**(`4.3.4`~`4.3.6`)로 갈립니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 관찰성 **세 계층**과 **기본 제공 ↔ 계측 경계**를 안다
- [ ] KPI **네 차원**과 하나가 빠질 때 생기는 일을 안다
- [ ] Bedrock 런타임 지표가 **서로 다른 집합을 세는 경계**를 안다
- [ ] 모델 호출 로깅의 **기본 상태와 캡처 범위**를 안다
- [ ] 행동 이상 탐지가 **성능 지표보다 먼저 보는 것**을 안다
- [ ] 도구 호출 관찰성의 **세 층**을 가른다
- [ ] 벡터 저장소의 **용량 한계 신호와 데이터 품질 검증**을 안다
- [ ] `stopReason`과 오류 코드로 **GenAI 고유 실패 모드**를 가른다

---

## 🎯 왜 중요한가

전통적인 ML 시스템의 모니터링은 **지연과 오류율**이면 상당 부분 끝납니다. 요청이 실패하거나 느려지면 지표가 즉시 움직이고, 정확도는 배포 시점에 측정한 값이 오래 유지됩니다.

GenAI 애플리케이션은 둘 다 성립하지 않습니다. **응답이 200 OK로 돌아오면서 틀릴 수** 있고, **지연과 오류율이 완전히 정상인데 품질만 조용히 내려갈 수** 있습니다. 게다가 요청 하나가 모델 호출 한 번이 아니라 **검색 → 추론 → 도구 호출 → 재추론**의 사슬이라, 「느리다」는 신고가 들어왔을 때 어느 고리인지 지표만으로는 알 수 없습니다.

그래서 이 작업의 공식 기술 여섯 개가 **층을 쌓는 순서**로 배열돼 있습니다 — 요청 하나를 끝까지 따라갈 수 있게 만들고(`4.3.1`), 거기서 나오는 수치에 **이상 탐지**를 걸고(`4.3.2`), 사람이 조치할 수 있는 형태로 묶고 **감사 가능하게** 남기고(`4.3.3`), 그 사슬에서 가장 자주 깨지는 두 고리인 **도구**(`4.3.4`)와 **벡터 저장소**(`4.3.5`)를 따로 보며, 마지막으로 **GenAI에만 있는 실패 모드**를 식별합니다(`4.3.6`).

---

## ⚡ 시험 직전 요약

- **세 계층**: 세션(전체 상호 작용 맥락·격리) · 트레이스(단일 요청-응답 주기) · 스팬(개별 작업 단위·부모-자식)
- ⚠️⚠️ **트레이스 데이터는 ADOT로 코드를 계측해야** 모인다. 기본으로 오는 것은 **Runtime 세션 수준 지표**와 메모리·게이트웨이·내장 도구의 기본 지표다
- **KPI 네 차원**: 운영 · 품질 · 효율 · 비즈니스. **하나라도 빠지면 「완성돼 보이지만 오해를 만드는」 대시보드**가 된다
- ⚠️⚠️ `InvocationThrottles`는 **`Invocations`·`ClientErrors`·`ServerErrors` 어디에도 들어가지 않고**, **쿼터 초과로 거부된 요청은 `InvocationClientErrors`**로 센다
- ⚠️⚠️ **모델 호출 로깅은 기본이 꺼져 있고** `bedrock-runtime` 엔드포인트로 들어온 호출만 캡처한다. 대상은 **같은 계정·같은 리전**의 S3와 CloudWatch Logs뿐이다
- **CloudWatch 이상 탐지**는 **최대 2주 데이터로 학습**하고 ⚠️ **지표 하나 + 통계 하나에 고유**하다. 알람에 쓰면 **과금**된다
- ⚠️⚠️ **성능 지표(지연·오류율)는 필요하지만 충분하지 않다** — 드리프트는 **행동 지표**(에스컬레이션 비율·도구 선택 패턴)에서 먼저 나타난다
- ⚠️ **내장 도구 지표는 코드 인터프리터·브라우저 둘에만** 있고 리소스 사용 데이터는 **최대 60분 지연**될 수 있다
- ⚠️⚠️ `KNNGraphMemoryUsagePercentage`가 **100%에 닿으면 서킷 브레이커가 발동해 새 `knn_vector` 색인이 거부된다**
- ⭐ **`max_tokens`에 걸린 잘림과 컨텍스트 창 초과는 `stopReason`이 다른 값**이다(`max_tokens` ↔ `model_context_window_exceeded`)

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **세션(session)** | 사용자와 에이전트의 **완전한 상호 작용 맥락**. 컨텍스트 지속·상태 관리·대화 이력·리소스 할당과 **다른 사용자 상호 작용과의 격리**를 담는다 |
| **트레이스(trace)** | **단일 요청-응답 주기**의 상세 기록. 처리 단계 순서·도구 호출의 입출력과 실행 시간·오류와 복구 시도를 담고 다른 에이전트 호출을 포함할 수 있다 |
| **스팬(span)** | 실행 흐름 안의 **측정 가능한 개별 작업 단위**. 작업 이름·시작·종료 타임스탬프·**부모-자식 관계**를 갖는다 |
| **ADOT** | AWS Distro for OpenTelemetry. ⚠️ **트레이스 데이터 수집의 전제**다 |
| **기준선(baseline)** | 에이전트별 **정상 행동의 통계적 기준**. 공식은 **초기 관찰 2~4주**를 권한다 |
| **드리프트(drift)** | 데이터 드리프트(입력 분포 변화) · 개념 드리프트(입력-출력 관계 변화) · 성능 드리프트(출력 품질 저하) |
| **`stopReason`** | `Converse` 응답이 **왜 생성을 멈췄는지** 알려 주는 필드. 실패 모드 진단의 1차 신호다 |
| **서킷 브레이커(k-NN)** | 벡터 그래프가 쓰는 네이티브 메모리가 한계에 닿으면 **새 벡터 색인을 거부**하는 OpenSearch 보호 장치 |

---

## 📖 핵심 개념

### 1) 총체적 관찰성 — 세 계층과 KPI 네 차원 (기술 4.3.1) {#observability}

> 🧠 원리: 관찰성의 목적은 「지표를 많이 모으는 것」이 아니라 **요청 하나를 끝까지 재조립할 수 있게 만드는 것**입니다. 그래서 공식이 세 계층을 두었습니다 — 스팬이 **한 작업**을, 트레이스가 **한 요청**을, 세션이 **한 대화**를 담습니다. 이 구조가 없으면 「느리다」는 신고에 대해 어느 고리가 느렸는지 영원히 추측하게 됩니다.

공식이 정의하는 세 계층과 각각이 담는 것:

| 계층 | 정의 | 담는 것 |
|---|---|---|
| **세션** | 사용자와 에이전트의 완전한 상호 작용 맥락 | 컨텍스트 지속 · 상태 관리 · 대화 이력 · 리소스 할당 · **다른 사용자 상호 작용과의 격리** |
| **트레이스** | 단일 요청-응답 주기의 상세 기록 | 요청 상세 · 처리 단계 순서 · **도구 호출의 입출력과 실행 시간** · 리소스 사용 · **오류와 복구 시도** · 응답 생성 |
| **스팬** | 실행 흐름 안의 측정 가능한 개별 작업 단위 | 작업 이름 · 시작·종료 타임스탬프 · **부모-자식 관계** |

**⚠️⚠️ 기본으로 오는 것과 계측해야 오는 것이 갈립니다.** 이 경계가 시험 소재입니다.

- **기본 제공**: AgentCore Runtime에서 도는 에이전트의 **세션 수준 지표**, 그리고 **메모리·게이트웨이·내장 도구**의 기본 지표. ⭐ **메모리 리소스는 로그와 스팬도 기본으로** 옵니다.
- **계측해야 오는 것**: 내 에이전트의 **사용자 지정 지표·로그·스팬**. 그리고 ⚠️⚠️ **트레이스 데이터를 모으려면 ADOT로 코드를 계측해야 합니다.**
- 보는 곳이 둘입니다 — **AgentCore 콘솔의 관찰성 페이지**와 **CloudWatch 콘솔의 GenAI 관찰성 페이지**.

**KPI는 네 차원입니다.** 공식이 차원마다 예시를 듭니다:

| 차원 | 예시 |
|---|---|
| **운영** | 작업 완료율 · 해결 시간 · 오류율 · 에스컬레이션 비율 |
| **품질** | 결정 정확도 · **할루시네이션 비율** · 사용자 만족도 |
| **효율** | **작업당 토큰 · 작업당 도구 호출 · 작업당 비용** |
| **비즈니스** | 결과 달성률 · SLA 준수 · 고객 만족 영향 |

- ⚠️⚠️ **하나라도 빠지면 「완성돼 보이지만 오해를 만드는」 대시보드**가 됩니다(공식 표현). ⚠️ 반대로 **한쪽이 열 배 중요한데 운영·비즈니스 지표에 같은 가중치**를 주는 것도 안티패턴입니다.
- 기준선은 **초기 관찰 기간 2~4주**면 보통 충분하고, 그 뒤 **CloudWatch 이상 탐지**로 자동 조정합니다.
- ⭐ **경고 임계는 검토를 시작하고 치명 임계는 조치를 지시합니다** — 둘을 나눕니다.
- 주간 KPI 보고는 **`Amazon Quick`**으로 만들어 **기술·비즈니스 이해관계자가 같은 대시보드**를 보게 합니다. 그리고 **분기별 검토**로 KPI 정의가 아직 현행 사업 목표를 반영하는지 확인합니다.

공식이 드는 **흔한 실패 넷**:

1. **인프라 지표만 계측하고** 추론 반복·도구 호출·메모리 작업 같은 **에이전트 고유 스팬을 놓친다.**
2. ⚠️⚠️ **경계를 넘어 컨텍스트를 전파하지 않아** 재조립할 수 없는 **조각난 트레이스**가 된다.
3. ⚠️⚠️ **기준선을 배포 때 한 번 세우고 갱신하지 않아** 정당한 행동 변화가 **거짓 양성**을 내고, 기준선을 재정의할 만큼의 **점진적 드리프트는 탐지되지 않는다.**
4. 로그를 **변경 가능한 스토리지**에 둔다(감사 추적이 못 된다).

---

### 2) 사전 식별 — 런타임 지표·호출 로그·이상 탐지 (기술 4.3.2) {#monitoring}

> 🧠 원리: 「사전에 식별한다」는 **문제가 사용자에게 닿기 전에 수치가 움직이는 것**입니다. 그런데 Bedrock 런타임 지표는 **세 가지가 서로 다른 집합을 셉니다** — 성공·실패·스로틀의 포함 관계가 직관과 다르고, 그 경계를 모르면 「오류가 없는데 사용자는 실패를 본다」는 상황을 설명할 수 없습니다.

**CloudWatch 런타임 지표**(네임스페이스 **`AWS/Bedrock`**)의 비자명한 경계:

| 지표 | ⚠️ 비자명한 점 |
|---|---|
| `Invocations` | **나중에 클라이언트·서버 오류로 실패한 요청을 포함**하고, **스로틀된 요청과 처리 시작 전 입력 검증에서 거부된 요청은 포함하지 않는다** |
| `InvocationLatency` | **요청 전송 ~ 마지막 토큰 수신**(전체) |
| `TimeToFirstToken` | 요청 전송 ~ 첫 토큰 — ⚠️ **스트리밍 API에만** 있다 |
| `InvocationClientErrors` | ⚠️⚠️ **서비스 쿼터 초과로 거부된 요청이 여기 들어가고 스로틀로 세지 않는다** |
| `InvocationThrottles` | ⚠️⚠️ **`Invocations`·`ClientErrors`·`ServerErrors` 어디에도 들어가지 않는다.** 보이는 수는 **SDK 재시도 설정에 따라 달라진다** |
| `InputTokenCount` · `OutputTokenCount` | 토큰 사용 추적의 기본 지표 |
| `EstimatedTPMQuotaUsage` | ⚠️⚠️ **근삿값이고 스로틀링 결정을 끌고 가는 예약 기반 소비를 반영하지 않는다.** 공식이 **쿼터 사용·용량 계획의 단독 지표로 쓰지 말라**고 적는다 |
| `CacheReadInputTokenCount` | **감액 요율로 과금되고 TPM 쿼터에 들어가지 않는다** |
| `CacheWriteInputTokenCount` | ⚠️ **TPM 쿼터에 들어간다** |

- ⚠️⚠️ **`ModelId` 차원으로 필터하면 오류를 적게 셉니다** — 요청이 **어느 모델을 겨냥하는지 판정되기 전에** 실패하면 그 요청의 지표는 **차원 없이** 발행됩니다. 전수를 보려면 **차원을 지정하지 않고** 질의합니다.
- 토큰 버스트 패턴을 볼 때는 **`max_tokens`가 쓰이지 않아도 쿼터를 먹는다**는 성질을 함께 봅니다(`aip-t4-1` 문서 §1).

**모델 호출 로깅** — 지표가 「얼마나」를 주고 이 로그가 **「무엇을」**을 줍니다.

- **전체 요청 데이터·응답 데이터·메타데이터**를 모읍니다. 대상 작업 넷: **`Converse` · `ConverseStream` · `InvokeModel` · `InvokeModelWithResponseStream`**.
- ⚠️⚠️ **기본적으로 비활성**이고, 켜면 **로깅 구성을 삭제할 때까지** 로그가 저장됩니다.
- 대상은 **Amazon S3**와 **CloudWatch Logs**이고 ⚠️ **같은 계정·같은 리전만** 지원합니다.
- ⚠️⚠️ **`bedrock-runtime` 엔드포인트로 들어온 호출만 캡처됩니다.** OpenAI 호환 API도 그 엔드포인트면 포함되지만, **같은 API라도 다른 엔드포인트를 거치면 현재 캡처되지 않습니다.**
- ⚠️ S3 대상은 **버킷 ACL이 비활성**이어야 버킷 정책이 효력을 갖습니다.
- 전달 자체의 지표 넷이 따로 있습니다 — `ModelInvocationLogsCloudWatchDeliverySuccess`/`…Failure` · `ModelInvocationLogsS3DeliverySuccess`/`…Failure`.

**CloudWatch 이상 탐지** — 공식 기술이 드는 「토큰 버스트 패턴 및 응답 드리프트에 대한 이상 탐지」의 수단입니다.

- 과거 데이터에 ML을 적용해 **기대값 모델**을 만들고 **추세와 시간별·일별·주별 패턴**을 봅니다.
- **최대 2주 데이터로 학습**하고 ⭐ **2주가 다 차지 않아도 켤 수 있습니다.**
- ⚠️⚠️ **모델은 지표 하나 + 통계 하나에 고유합니다** — `AVG`로 켜면 그 모델은 `AVG` 전용입니다.
- **임계값이 크면 「정상」 띠가 두꺼워집니다.** 흔한 AWS 지표는 **논리적 범위를 벗어나지 않게** 묶입니다(0~100 · 음수 불가 등).
- ⭐ **특정 기간을 학습에서 제외**할 수 있습니다 — 배포 같은 이례적 사건을 빼면 모델이 정확해집니다.
- ⚠️ **이상 탐지 모델을 알람에 쓰면 과금됩니다.**

---

### 3) 실행 가능한 인사이트 — 행동 이상 탐지와 감사·포렌식 (기술 4.3.3) {#insights}

> 🧠 원리: 「실행 가능한」의 반대는 **「보이지만 무엇을 해야 할지 모르는」**입니다. 그 차이를 만드는 것이 둘입니다 — 이상을 **심각도별로 다른 경로로 보내는 것**, 그리고 사후에 **무슨 일이 있었는지 증명할 수 있게 남기는 것**입니다. 앞은 사람의 시간을 아끼고 뒤는 사람의 판단을 가능하게 합니다.

**행동 이상 탐지** — 성능 지표만으로는 늦습니다.

- 기준선은 **2~4주** 동안 **추론 반복 수 · 도구 선택 빈도 · 에스컬레이션 비율 · 작업 완료율 · 신뢰도 점수 분포**를 모아 **에이전트별로** 세웁니다. **기준선 없는 이상 탐지는 신뢰할 수 없는 신호**를 냅니다.
- ⚠️⚠️ **성능 지표(지연·오류율)는 필요하지만 충분하지 않습니다** — 미묘한 드리프트는 **행동 지표**에서 먼저 나타납니다(천천히 오르는 에스컬레이션 비율 · 조용히 늘어나는 할루시네이션 빈도 · **덜 유능한 도구로 쏠리는 선택 패턴**).
- ⭐ **심각도별 라우팅이 셋**입니다: 성능 이상 → **자동 조사** · 행동 이상 → **사람 검토** · 보안 관련 이상 → **즉시 에스컬레이션**. 셋을 섞으면 소음과 과소 대응이 됩니다.
- ⚠️⚠️ **드리프트 세 종류를 구분하지 못하면 처방이 엉뚱해집니다** — **데이터 드리프트**(입력 분포 변화) · **개념 드리프트**(입력-출력 관계 변화) · **성능 드리프트**(출력 품질 저하).

**감사·포렌식 추적성** — CloudTrail이 「누가 무엇을 호출했는가」를 남깁니다.

- ⭐ **일부 Runtime API가 「관리 이벤트」로 기록됩니다** — `InvokeModel`·`InvokeModelWithResponseStream`·`Converse`·`ConverseStream` 같은 호출 API가 그렇습니다. 그 밖의 Runtime API는 **데이터 이벤트**입니다.
- ⚠️ **데이터 이벤트는 대용량이라 CloudTrail이 기본으로 기록하지 않습니다.**
- 추적(trail)을 만들면 **콘솔 기본값이 전 리전**이고 로그 파일이 S3로 전달됩니다. 추적이 없어도 **Event history**에서 최근 이벤트를 봅니다.
- ⚠️ 그 목록은 개정되므로 **개수를 외우지 않고** 「호출 API가 관리 이벤트로 남고 나머지는 데이터 이벤트라 기본 비기록」이라는 성질을 씁니다.

**⚠️⚠️ 감사 로그 저장소를 새로 고를 때 밟는 자리가 있습니다.** `AWS CloudTrail Lake`는 공식 가용성 변경 공지로 **2026년 5월 31일부터 신규 고객에게 열려 있지 않습니다**. 다음을 함께 기억합니다:

- **`AWS CloudTrail` 본체는 완전히 지원되고** Trails·Insights·Aggregated Events는 **영향을 받지 않습니다.** 닫힌 것은 Lake뿐입니다.
- 기존 고객은 계속 쓸 수 있지만 **Lake는 치명적 버그 수정과 보안 업데이트만** 받습니다.
- ⚠️⚠️ **계속 지원 수준이 이벤트 데이터 스토어 유형마다 다릅니다** — **조직 이벤트 데이터 스토어**는 신규 멤버 계정과 추가 리전까지 그대로 동작하지만, **계정 이벤트 데이터 스토어만 있으면 조직에 새로 추가된 계정의 수집을 지원하지 않습니다.** 새 계정을 덮으려면 조직 EDS를 만들거나 이전해야 합니다.
- 공식 권장 이전 대상은 **Amazon CloudWatch**입니다 — **OCSF와 OTel 형식 내장 지원** · OpenSearch 기반 네이티브 분석 · Apache Iceberg API를 통한 개방 접근을 듭니다.

> **규정 준수 모니터링**은 이 작업이 아니라 작업 3.3이 소유합니다 — `aip-t3-3` 문서 §4(지속적 모니터링)를 함께 봅니다. 여기서는 그 결과를 **운영 대시보드에 올리는 쪽**만 다룹니다.

---

### 4) 도구 성능 프레임워크 — 세 층과 복합 알람 (기술 4.3.4) {#tool-perf}

> 🧠 원리: 「도구 호출 관찰성」이라는 한 낱말 뒤에 **서로 다른 세 출처**가 있습니다. 어디서 오는 수치인지 섞으면 「도구 지표가 안 보인다」와 「도구가 안 불렸다」를 구별할 수 없습니다. 그리고 도구는 **한 지표가 임계를 넘기 전에 여러 지표가 함께 나빠지는** 전형적인 자리라, 단일 임계로는 열화를 놓칩니다.

| 층 | 무엇을 주는가 | ⚠️ 경계 |
|---|---|---|
| **내장 도구 지표** | `Invocations` · `Throttles` · `SystemErrors` · `UserErrors` · `Latency` · `Duration`(+ 브라우저의 테이크오버 수·해제 수·시간) | ⚠️⚠️ **코드 인터프리터와 브라우저 둘에만** 있다. **1분 간격 배치** |
| **Gateway 쪽** | 게이트웨이 관찰성 데이터 · 속도 제한 지표 · CloudTrail 이벤트 | 도구가 **게이트웨이를 지날 때만** |
| **에이전트 자신의 도구 호출** | 프레임워크가 내는 스팬 — `gen_ai.operation.name`이 **`invoke_agent` · `execute_tool` · `chat`** | **프레임워크 계측에 달렸다** |

- `Throttles`는 TPS·쿼터 초과로 서비스가 거부한 수이고 **`ThrottlingException` + HTTP 429**입니다.
- ⚠️ `Latency`는 **요청 수신부터 첫 응답 토큰을 보내기 시작할 때까지**입니다 — 전체 처리 시간이 아닙니다.
- 리소스 사용 지표는 **`CPUUsed-vCPUHours` · `MemoryUsed-GBHours`**이고 차원은 `Service`(`AgentCore.CodeInterpreter` 또는 `AgentCore.Browser`)와 `Resource`(도구 ID)입니다. 계정 수준·도구 수준 모두 **1분 해상도**로 벤딩됩니다.
- ⚠️⚠️ **리소스 사용 데이터는 최대 60분 지연될 수 있고** 지표마다 정밀도가 다를 수 있습니다(공식 Note) — 「실시간으로 CPU·메모리를 보고 스케일한다」류 설계는 이 사실에 걸립니다.

**호출 패턴 추적과 이상 탐지 기준선** — Lens 쪽 축입니다.

- 도구별로 **호출 수 · 성공률 · 유형별 오류율 · 지연 백분위수**를 추적합니다.
- ⭐ **복합 알람(composite alarm)**이 여러 지표를 묶습니다 — **지연이 오르면서 타임아웃 비율도 오르는 도구**는 단일 임계로는 어느 쪽도 울리지 않아도 **차단에 가까워진 도구**이고, 복합 보기가 단일 임계보다 **먼저** 열화를 잡습니다.
- 반복되는 호출 순서는 **하나의 서버 측 작업으로 묶어** 한 번의 추론 반복으로 끝낼 수 있습니다. 판단 근거는 **텔레메트리에서 세 번 이상 반복되는 순서**이고, 묶은 작업의 지연을 **단계별로 분해**해 가장 느린 단계를 고칩니다. ⚠️ 안티패턴은 변형을 너무 많이 떠안아 **개별 도구보다 느려지는** 것입니다.

**다중 에이전트 조정 추적** — 스팬이 어디서 오는지의 문제입니다.

- 서비스는 스팬의 **`scope.name`**으로 어느 계측 라이브러리인지 판별하고, 스팬 분류는 **`gen_ai.operation.name`**으로 합니다. 도구 이름은 **`gen_ai.tool.name`**입니다.
- **Strands Agents는 SDK에 계측이 내장**돼 추가 라이브러리가 필요하지 않고, 나머지 지원 프레임워크는 **OpenTelemetry 또는 OpenInference 계측 라이브러리**와 **권장 버전 하한**이 있습니다.
- AgentCore Runtime + **ADOT**에 배포하면 Runtime이 **`session.id`를 주입**하고 스팬·이벤트를 자동으로 내보냅니다.
- ⚠️⚠️ **계측만으로는 평가되지 않습니다** — 공식 Note가 계측은 한 단계이고 에이전트가 **관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야** 평가 서비스가 읽는다고 적습니다.
- ⭐ 배치 평가는 그라운드 트루스를 세션 메타데이터로 받는데, 그 안에 **기대 도구 궤적(expected tool trajectories)**이 들어갑니다 — 「도구를 올바른 순서로 썼는가」를 재는 근거입니다.

---

### 5) 벡터 저장소 운영 — 용량 신호·인덱스·데이터 품질 (기술 4.3.5) {#vector-ops}

> 🧠 원리: 벡터 저장소는 **메모리에 그래프를 올려 놓고 검색하는 구조**라, 다른 데이터베이스와 달리 **용량 한계가 「느려짐」이 아니라 「거부」로 나타납니다.** 그리고 품질 쪽에는 더 조용한 실패가 있습니다 — **오류 없이 결과가 적게 오는 것**입니다. 그래서 이 자리의 모니터링은 **메모리 신호**와 **결과 수의 기대치**를 함께 봐야 합니다.

**① 벡터 데이터베이스 성능 모니터링** — OpenSearch Service의 k-NN 지표가 공식 수단입니다.

| 지표 | 무엇을 말하는가 |
|---|---|
| `KNNGraphMemoryUsage` | 현재 캐시 크기(메모리에 있는 전 그래프의 합, 킬로바이트). 통계는 **평균** |
| `KNNGraphMemoryUsagePercentage` | ⚠️⚠️ 서킷 브레이커 한계 대비 네이티브 메모리 사용 **비율**. **100%에 닿으면 서킷 브레이커가 발동해 새 `knn_vector` 색인이 거부된다.** 통계는 **최대** |
| `KNNCacheCapacityReached` | 노드별로 캐시 용량에 도달했는지 |
| `KNNCircuitBreakerTriggered` | 클러스터 단위. ⭐ **어느 노드든 `KNNCacheCapacityReached`가 1이면 이 값도 1이 된다** |
| `KNNEvictionCount` | 메모리 제약이나 유휴 시간으로 **축출된 그래프 수**. ⚠️ **인덱스 삭제로 생긴 명시적 축출은 세지 않는다** |
| `KNNGraphIndexErrors` / `KNNGraphIndexRequests` | 문서의 `knn_vector` 필드를 그래프에 넣는 요청의 실패·총수 |
| `KNNGraphQueryErrors` / `KNNGraphQueryRequests` | 그래프 질의의 실패·총수 |
| `KNNHitCount` | 캐시 적중 — **이미 메모리에 적재된 그래프를 질의한 횟수** |

⚠️ 위 지표 가운데 `KNNCacheCapacityReached`·`KNNCircuitBreakerTriggered`·`KNNEvictionCount`·`KNNGraphMemoryUsage`는 **근사 k-NN 검색에만 해당**합니다.

**용량 산술이 공식에 적혀 있습니다.** OpenSearch Service는 인스턴스 RAM의 **절반을 Java 힙**으로 쓰고(힙 크기 최대 32 GiB), **k-NN이 남은 절반의 50%까지** 씁니다 — 그래서 **RAM 32 GiB 인스턴스는 그래프 8 GiB**를 담습니다(32 × 0.5 × 0.5). 그 값을 넘으면 **성능이 저하됩니다.** ⭐ 그래서 운영 점검은 **데이터 노드마다 `KNNGraphMemoryUsage`를 `knn.memory.circuit_breaker.limit`과 인스턴스 유형의 가용 RAM에 대조**하는 것입니다.

- ⚠️ k-NN 설정은 `_cluster/settings` API로 바꿀 수 있지만 **OpenSearch Service에서는 `knn.memory.circuit_breaker.enabled`와 `knn.circuit_breaker.triggered` 둘을 바꿀 수 없습니다.**
- 2.x 이후에 만든 k-NN 인덱스는 **2.17 이상 도메인에서 UltraWarm·콜드 스토리지로 이전**할 수 있습니다. ⚠️⚠️ 다만 **warm 인덱스에서는 캐시 정리·웜업 API가 차단**되고, **첫 쿼리가 S3에서 그래프 파일을 내려받아 메모리에 적재**하며 **TTL이 만료되면 자동으로 축출**됩니다 — 「웜업으로 첫 쿼리 지연을 없앤다」는 전략이 그 계층에서는 통하지 않습니다.
- **OpenSearch Serverless**의 모니터링 수단은 셋입니다 — **CloudWatch**(지표·대시보드·알람) · **CloudTrail**(API 호출과 관련 이벤트) · **EventBridge**(거의 실시간 시스템 이벤트 스트림으로 자동 조치를 트리거).

**② 자동화된 인덱스 최적화 루틴** — 운영 전에 정해야 하는 것과 운영 중에 고칠 수 있는 것이 갈립니다.

- ⚠️⚠️ **샤드 수는 첫 문서를 색인하기 전에 정합니다** — 기존 인덱스의 기본 샤드 수는 쉽게 바꿀 수 없습니다. 지침도 워크로드에 따라 갈립니다: **검색 지연이 핵심 목표면 샤드당 10–30 GiB**, **쓰기 중심이면 30–50 GiB**.
- Aurora PostgreSQL을 벡터 스토어로 쓸 때 ⚠️⚠️ **Bedrock이 질의에 쓰는 인덱스가 하나가 아닙니다** — 벡터용 **HNSW**(`hnsw (embedding vector_cosine_ops)`) · 텍스트용 **GIN**(`gin (to_tsvector('simple', chunks))`) · 사용자 지정 메타데이터용 **GIN**(`gin (custom_metadata)`)입니다. **벡터 인덱스만 만들면 텍스트 검색과 메타데이터 필터가 제 성능을 내지 못합니다.**
- ⭐ **`ef_construction`을 256으로** 설정하는 것이 공식 권장이고, 그 권장의 조건은 **병렬 인덱스 빌드를 쓰는 `pgvector` 0.6.0 이상**입니다. HNSW 색인 자체는 **`pgvector` 0.5.0 이상**이 필요합니다.
- ⚠️ **`custom_metadata` 열을 만들지 않으면** 수집을 시작하기 전에 **메타데이터 속성마다 개별 열**을 테이블에 만들어 두어야 합니다.
- ⚠️⚠️ 메타데이터 필터링을 쓰면 **HNSW 반복 인덱스 스캔을 활성화**합니다(**`pgvector` 0.8.0 이상**). 이유가 핵심입니다 — **반복 스캔이 없으면 선택적 메타데이터 필터가 기대보다 적은 결과를 돌려줍니다.** 필터가 HNSW 인덱스 스캔 **뒤에** 적용되기 때문입니다.

**③ 데이터 품질 검증 프로세스** — 수집·동기화가 품질의 1차 관문입니다.

- 동기화는 **증분**입니다. 공식이 시나리오 넷을 표로 적습니다: **변경 없음 → 건너뛴다** · **콘텐츠나 메타데이터 변경 → 재수집**(재파싱·재청킹·재임베딩·재색인) · **신규 문서 → 그것만 수집** · **문서 삭제 → 벡터 스토어에서 제거**.
- ⭐ **메타데이터 전용 최적화**가 있습니다 — 기존 벡터 임베딩을 꺼내 새 메타데이터를 병합해 다시 쓰므로 **임베딩 모델 호출을 피합니다.** 조건 셋을 **모두** 만족해야 합니다: **`metadata.json`만 수정**(콘텐츠 파일 무변경) · **연결된 콘텐츠 파일이 CSV가 아니다** · **데이터 소스가 사용자 지정 변환 Lambda를 쓰지 않는다**.
- ⚠️ **CSV는 메타데이터가 갱신되면 항상 재수집**됩니다 — `documentStructureConfiguration`이 어느 열을 색인할지 정하는데, 파일을 재처리하지 않고는 그 구조 설정이 바뀌었는지 알 수 없기 때문입니다.
- ⚠️⚠️ **메타데이터 파일이 조용히 무시되는 조건**이 있습니다 — `.metadata.json`은 연결된 소스 파일과 **같은 파일 이름·확장자**를 공유해야 하고, 벡터 인덱스가 OpenSearch Serverless에 있으면 **`faiss` 엔진으로 구성돼 있어야** 합니다. **`nmslib`이면** 새 인덱스를 `faiss`로 만들어 다시 지식 베이스를 구성해야 합니다.
- 상태 추적은 **`StartIngestionJob` → `GetIngestionJob`**이고, 완료되면 `status`가 **`COMPLETE`**입니다. ⭐ **응답의 `statistics` 객체가 데이터 소스 문서별로 수집 성공·실패 정보**를 줍니다. 콘솔에서는 데이터 소스의 **Sync history**에서 **View warnings**로 실패 이유를 봅니다. 전 작업 조회는 `ListIngestionJobs`이고 상태 필터·정렬·`maxResults`를 지원합니다.
- ⚠️⚠️ **동기화가 끝난 직후가 「검색 가능」은 아닙니다** — 공식 Note가 **Amazon Aurora(RDS) 외의 벡터 스토어를 쓰면 새로 수집된 데이터의 벡터 임베딩이 질의에 반영되기까지 몇 분 걸릴 수 있다**고 적습니다.

---

### 6) GenAI 고유 실패 모드 — `stopReason`·오류 분류·골든 데이터세트 (기술 4.3.6) {#failure-modes}

> 🧠 원리: 기존 ML 시스템의 실패는 대개 **요청이 실패하는 것**입니다. GenAI의 실패는 **요청이 성공하면서 내용이 잘리거나 틀리는 것**이라, HTTP 상태 코드만 보는 문제 해결 틀로는 보이지 않습니다. 그래서 공식이 응답 자체에 **왜 멈췄는지 알려 주는 필드**를 두었고, 품질 쪽에는 **골든 데이터세트와 판정 지표**를 두었습니다.

**① `stopReason`이 실패 모드를 구분합니다.** `Converse` 응답의 유효값은 다음과 같습니다:

```
end_turn | tool_use | max_tokens | stop_sequence | guardrail_intervened |
content_filtered | malformed_model_output | malformed_tool_use | model_context_window_exceeded
```

| 증상 | 신호 |
|---|---|
| **응답이 잘렸다** | **`max_tokens`** — 모델이 아니라 **내 `max_tokens` 설정**에 걸렸다 |
| ⭐ **컨텍스트 창을 넘겼다** | **`model_context_window_exceeded`** — 전용 값이 따로 있다 |
| 도구 호출 형식이 깨졌다 | **`malformed_tool_use`**(모델 출력 전체가 깨졌으면 `malformed_model_output`) |
| 가드레일이 막았다 | `guardrail_intervened` / `content_filtered` |
| 정상 종료 | `end_turn` · `stop_sequence` · (도구를 부르려고 멈춤) `tool_use` |

⚠️⚠️ **「잘림」과 「컨텍스트 창 초과」를 한 신호로 묶으면 처방이 틀립니다** — 앞은 `max_tokens`를 올리는 문제이고 뒤는 **입력을 줄이거나 나누는** 문제입니다.

**② 오류와 HTTP 코드** — 재시도해도 되는 것과 안 되는 것이 갈립니다.

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

⚠️⚠️ **429가 둘입니다** — `ThrottlingException`(쿼터)과 `ModelNotReadyException`(모델 준비 안 됨). **코드만 보고 쿼터 문제로 처방하면 틀립니다.** 그리고 **400·408·424는 같은 요청을 다시 보내 해결되는 종류가 아닙니다.**

**③ 사전 진단** — 컨텍스트 창 초과는 호출 전에 셀 수 있습니다. `CountTokens`(**`POST /model/{modelId}/count-tokens`**)가 그 수단입니다.

- ⚠️ **토큰화가 모델별이라 모델을 지정**해야 하고, 돌려주는 수는 ⭐ **같은 입력을 `InvokeModel`·`Converse`로 보냈을 때 과금될 토큰 수와 일치합니다.**
- 입력은 `invokeModel` 또는 `converse` **중 하나**이고 응답은 **`inputTokens`**뿐입니다.
- 공식 용례 셋: **비용 추정 · 토큰 한도에 맞게 프롬프트 최적화 · 토큰 사용 계획.**

**④ 골든 데이터세트로 할루시네이션을 탐지합니다.** 판정 모델 평가의 내장 지표 가운데 이 자리에 쓰는 것이 둘입니다.

- **`Builtin.Faithfulness`** — ⭐ **프롬프트에 없는 정보가 응답에 들어 있는지**를 봅니다. 할루시네이션 축이 여기입니다.
- **`Builtin.Correctness`** — 응답이 옳은지를 보고, ⭐ **참조 응답(그라운드 트루스)을 주면 평가자가 그것을 고려합니다.** 골든 데이터세트가 들어가는 자리입니다.
- 응답 일관성 분석에는 **`Builtin.Coherence`**(논리적 공백·불일치·모순)가 붙고, 지시 이탈에는 **`Builtin.FollowingInstructions`**가 붙습니다.
- ⭐ **내 응답 데이터를 프롬프트 데이터세트에 직접 넣으면** Bedrock이 **모델 호출 단계를 건너뛰고 그 데이터를 바로 평가**합니다 — Bedrock 밖에서 돌리는 모델의 출력도 같은 척도로 채점할 수 있습니다.
- ⚠️ 콘솔 지표 카드는 **점수 히스토그램과 처음 다섯 프롬프트**의 설명을 보여 주고 **전체 보고서는 내가 지정한 S3 버킷**에 있습니다.
- ⚠️⚠️ 공식 기술이 품질 지표로 드는 네 낱말 가운데 **「유창성」에 대응하는 내장 지표는 판정 지표 목록에 없습니다**(관련성·정확성·일관성은 있습니다). 그 자리는 **판정 프롬프트를 직접 쓰는 사용자 지정 지표**로 갑니다.

**⑤ 특수 관찰성 파이프라인 자체가 안 돌 때.** 평가가 「빈 결과」를 돌려주는 것도 실패 모드입니다. 공식이 흔한 원인을 열거합니다.

- **빈 평가 결과**(구성은 켜져 있는데 점수가 없다)
- **`LogEventMissingException`** — 스팬에 대응하는 로그 이벤트가 없다
- **`AgentSpanMappingException`·`ToolSpanMappingException`** — 스팬에서 사용자 질의나 도구 출력을 추출할 수 없다
- **`SpanEventParsingException`** · **`Gateway Timeout (504)`**
- **`evaluatorId`의 `ValidationException`** — 평가자 ID 형식이 틀렸다
- **다중 에이전트 평가 스코핑** — 평가자가 다중 에이전트 트레이스에서 **엉뚱한 에이전트를 겨냥**한다

⚠️⚠️ 전제가 중요합니다 — **에이전트가 관찰성을 켠 상태로 최소 한 번 호출됐어야** 진단이 성립합니다. ⭐ 진단은 **내 계정의 CloudWatch 로그 그룹을 질의**하고 서비스 측 접근은 필요하지 않습니다(필요 권한: `logs:DescribeLogGroups`·`DescribeLogStreams`·`StartQuery`·`GetQueryResults`).

---

## ✍️ 시험 포인트

- **관찰성 세 계층은 범위로 외웁니다** — 스팬은 **한 작업**, 트레이스는 **한 요청-응답 주기**, 세션은 **한 상호 작용 맥락**입니다. 「도구 호출의 입출력과 실행 시간」은 **트레이스**에 담깁니다.
- ⚠️⚠️ **「트레이스가 안 보인다」의 1차 원인은 계측 부재**입니다. 기본으로 오는 것은 세션 수준 지표와 메모리·게이트웨이·내장 도구의 기본 지표이고 **트레이스는 ADOT 계측이 전제**입니다.
- **KPI 네 차원 중 무엇이 빠졌는지 묻는 문항**에 대비합니다. 「토큰·도구 호출·비용」은 **효율**, 「할루시네이션 비율」은 **품질**, 「에스컬레이션 비율」은 **운영**, 「SLA 준수」는 **비즈니스**입니다.
- ⚠️⚠️ **스로틀은 어느 집합에도 안 들어가고 쿼터 초과는 클라이언트 오류로 센다** — 이 두 줄이 Bedrock 지표 문항의 핵심입니다. 그리고 **`EstimatedTPMQuotaUsage`를 쿼터 사용의 단독 근거로 쓰는 보기는 공식이 금지한 쪽**입니다.
- **「프롬프트와 응답 본문을 보고 싶다」 → 모델 호출 로깅**이고 **「누가 호출했는지 보고 싶다」 → CloudTrail**입니다. 전자는 **기본 꺼짐 + 같은 계정·리전**, 후자는 **호출 API가 관리 이벤트**라는 점이 갈림길입니다.
- **이상 탐지 수치 셋**만 기억합니다 — **최대 2주 학습** · **지표 하나 + 통계 하나에 고유** · **알람에 쓰면 과금**. 그리고 **배포 기간을 학습에서 제외**할 수 있습니다.
- ⚠️⚠️ **「지연과 오류율이 정상인데 품질이 내려간다」 → 행동 지표와 기준선**입니다. 심각도 라우팅은 **성능=자동 조사 / 행동=사람 검토 / 보안=즉시 에스컬레이션**입니다.
- **내장 도구 지표는 둘에만 있다**와 **리소스 사용 데이터 최대 60분 지연**이 도구 관찰성의 두 함정입니다. 「실시간 CPU로 스케일」은 그래서 성립하지 않습니다.
- ⚠️⚠️ **벡터 쪽 「거부」 신호는 `KNNGraphMemoryUsagePercentage` 100%**이고, **「오류 없이 결과가 적다」는 반복 인덱스 스캔 부재**입니다. 두 증상이 완전히 다릅니다.
- **동기화 성공 ≠ 즉시 검색 가능**(Aurora 외 스토어는 몇 분) · **`nmslib`이면 메타데이터가 무시된다** · **CSV는 메타데이터만 바뀌어도 항상 재수집** — 데이터 품질 문항의 단골입니다.
- ⭐ **`max_tokens` ↔ `model_context_window_exceeded`**와 **429 둘**이 실패 모드 문항에서 가장 많이 갈리는 자리입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **「관찰성을 켰으니 트레이스가 모인다」** → 트레이스는 **ADOT 계측**이 있어야 모입니다. 그리고 ⚠️ **계측만으로도 평가되지 않습니다** — 관찰성을 켜서 CloudWatch로 텔레메트리를 내보내야 평가 서비스가 읽습니다.
- ❌ **「오류율이 0이니 사용자 요청은 모두 처리됐다」** → `Invocations`는 **스로틀된 요청과 입력 검증에서 거부된 요청을 포함하지 않고**, `InvocationThrottles`는 **오류 지표 어디에도 들어가지 않습니다.** 스로틀 수는 **SDK 재시도 설정에 따라 보이는 값이 달라집니다.**
- ❌ **「`ModelId`로 필터해서 모델별 오류를 전수 본다」** → 어느 모델을 겨냥하는지 **판정되기 전에 실패한 요청은 차원 없이** 발행됩니다. 전수는 **차원 없이** 질의합니다.
- ❌ **「모델 호출 로그를 다른 리전의 중앙 버킷으로 모은다」** → 로깅 대상은 **같은 계정·같은 리전**만 지원합니다. 그리고 **기본적으로 꺼져 있습니다.**
- ❌ **「이상 탐지를 `AVG`로 만들어 두고 `MAX` 알람에 쓴다」** → 모델은 **지표 하나 + 통계 하나에 고유**합니다. 통계를 바꾸려면 그 통계로 모델을 따로 만듭니다.
- ❌ **「성능 이상과 행동 이상을 같은 알람 경로로 보낸다」** → 공식 라우팅은 **성능=자동 조사 / 행동=사람 검토 / 보안=즉시 에스컬레이션**입니다. 셋을 섞으면 소음과 과소 대응이 됩니다.
- ❌ **「기준선은 배포할 때 한 번 세우면 된다」** → 갱신하지 않으면 **정당한 변화가 거짓 양성**을 내고 **점진적 드리프트는 탐지되지 않습니다.**
- ❌ **「감사 로그 저장소로 CloudTrail Lake를 새로 도입한다」** → **2026년 5월 31일부터 신규 고객에게 열려 있지 않습니다.** ⚠️ 단 **CloudTrail 본체는 완전히 지원되고 Trails·Insights·Aggregated Events는 영향이 없습니다.** 새 설계의 권장 이전 대상은 **CloudWatch**입니다.
- ❌ **「계정 이벤트 데이터 스토어만 있어도 조직이 커지면 자동으로 덮인다」** → **계정 EDS는 조직에 새로 추가된 계정의 수집을 지원하지 않습니다.** 조직 EDS가 필요합니다.
- ❌ **「도구 지표가 안 보이니 도구가 안 불렸다」** → **내장 도구 지표는 코드 인터프리터·브라우저 둘에만** 있습니다. 내 도구는 **프레임워크 스팬**이나 **게이트웨이 쪽**에서 봅니다.
- ❌ **「도구 `Latency`가 정상이니 도구 처리가 빠르다」** → 그 값은 **첫 응답 토큰을 보내기 시작할 때까지**입니다. 전체 처리 시간이 아닙니다.
- ❌ **「벡터 인덱스를 HNSW로 만들었으니 메타데이터 필터도 빠르다」** → Aurora에서는 **텍스트용 GIN과 메타데이터용 GIN 인덱스가 따로** 필요합니다. 그리고 **반복 인덱스 스캔이 없으면 결과가 조용히 적게** 옵니다.
- ❌ **「샤드 수는 나중에 조정한다」** → 기존 인덱스의 기본 샤드 수는 **쉽게 바꿀 수 없습니다.** 첫 문서를 색인하기 전에 정합니다.
- ❌ **「동기화가 COMPLETE면 바로 검색된다」** → **Aurora(RDS) 외의 벡터 스토어는 몇 분** 걸릴 수 있습니다. 그리고 실패 이유는 **Sync history의 View warnings**와 응답의 **`statistics`**에서 봅니다.
- ❌ **「응답이 잘렸으니 컨텍스트 창을 넘겼다」** → `stopReason`이 **`max_tokens`**면 내 설정에 걸린 것이고, 컨텍스트 창 초과는 **`model_context_window_exceeded`**라는 전용 값으로 옵니다.
- ❌ **「429니까 쿼터를 올린다」** → `ModelNotReadyException`도 **429**입니다. 그쪽은 **SDK가 최대 5회 자동 재시도**하는 종류입니다.

---

## 🧪 자가 점검

**Q1.** 에이전트를 AgentCore Runtime에 배포하고 관찰성을 켰습니다. 콘솔에서 세션 수준 지표는 보이는데 **도구 호출의 입출력과 실행 시간은 어디에도 없습니다.** 원인과 해결은 무엇입니까?

<details><summary>정답 보기</summary>

**트레이스 데이터를 모으려면 ADOT로 코드를 계측해야 합니다.** ⚠️⚠️ 공식이 기본 제공 범위를 명확히 가릅니다 — **기본으로 오는 것**은 AgentCore Runtime에서 도는 에이전트의 **세션 수준 지표**와 **메모리·게이트웨이·내장 도구의 기본 지표**이고(⭐ **메모리 리소스는 로그와 스팬도 기본**으로 옵니다), **계측해야 오는 것**은 내 에이전트의 **사용자 지정 지표·로그·스팬**입니다. 도구 호출의 입출력과 실행 시간은 **트레이스**에 담기는 정보이므로(세션이나 스팬이 아닙니다) 계측이 전제입니다. ⭐ **Strands Agents는 SDK에 계측이 내장**돼 추가 라이브러리가 필요하지 않고, 다른 지원 프레임워크는 **OpenTelemetry 또는 OpenInference 계측 라이브러리**와 권장 버전 하한이 있습니다. 배포 후에는 Runtime이 **`session.id`를 주입**하고, 서비스는 스팬의 **`scope.name`**으로 계측 라이브러리를 판별하며 **`gen_ai.operation.name`**(`invoke_agent`·`execute_tool`·`chat`)으로 스팬을 분류합니다. ⚠️ 보는 곳은 **AgentCore 콘솔의 관찰성 페이지**와 **CloudWatch 콘솔의 GenAI 관찰성 페이지** 둘입니다.
</details>

**Q2.** 운영팀이 「Bedrock 오류 지표가 0인데 사용자는 실패를 본다」고 보고했습니다. 어떤 지표를 어떻게 봐야 합니까?

<details><summary>정답 보기</summary>

**세 가지 경계를 확인합니다.** ⚠️⚠️ ① **`InvocationThrottles`는 `Invocations`·`InvocationClientErrors`·`InvocationServerErrors` 어디에도 들어가지 않습니다** — 스로틀로 거부된 요청은 오류 지표에 나타나지 않으므로 그 지표를 **따로** 봐야 하고, 보이는 수는 **SDK 재시도 설정에 따라 달라집니다.** ② 반대로 **서비스 쿼터 초과로 거부된 요청은 `InvocationClientErrors`에 들어가고 스로틀로 세지 않습니다.** ③ `Invocations` 자체도 **나중에 오류로 실패한 요청은 포함하지만 스로틀된 요청과 처리 시작 전 입력 검증에서 거부된 요청은 포함하지 않습니다.** 그리고 ⚠️⚠️ **`ModelId` 차원으로 필터하면 오류를 적게 셉니다** — 요청이 어느 모델을 겨냥하는지 **판정되기 전에** 실패하면 그 지표가 **차원 없이** 발행되기 때문입니다. 전수를 보려면 **차원을 지정하지 않고** 질의합니다. ⚠️ 용량 계획을 함께 본다면 **`EstimatedTPMQuotaUsage`를 단독 근거로 쓰지 않습니다** — 근삿값이고 **스로틀링 결정을 끌고 가는 예약 기반 소비를 반영하지 않는다**고 공식이 적습니다.
</details>

**Q3.** 사고 조사를 위해 「특정 시점에 모델에 들어간 프롬프트와 나온 응답 전문」이 필요합니다. 그런데 CloudTrail 로그에는 그 본문이 없습니다. 어떻게 해야 하고, 지금부터라도 켜려면 무엇을 확인합니까?

<details><summary>정답 보기</summary>

**CloudTrail은 요청 메타데이터를 남기고 본문은 모델 호출 로깅이 남깁니다** — 둘은 다른 장치입니다. ⚠️⚠️ **모델 호출 로깅은 기본적으로 비활성**이므로 과거 시점의 본문은 **지금 켜도 소급되지 않습니다.** 켤 때 확인할 것들 — 대상 작업은 **`Converse`·`ConverseStream`·`InvokeModel`·`InvokeModelWithResponseStream`** 넷이고, 대상 저장소는 **Amazon S3와 CloudWatch Logs**이며 ⚠️ **같은 계정·같은 리전만** 지원합니다(다른 리전의 중앙 버킷으로 바로 모을 수 없습니다). ⚠️⚠️ **`bedrock-runtime` 엔드포인트로 들어온 호출만 캡처**되므로 같은 API라도 다른 엔드포인트를 거치면 남지 않습니다. ⚠️ S3 대상은 **버킷 ACL이 비활성**이어야 버킷 정책이 효력을 갖고, 켜면 **로깅 구성을 삭제할 때까지** 저장됩니다. 전달이 되고 있는지는 **`ModelInvocationLogsS3DeliverySuccess`/`…Failure`·`ModelInvocationLogsCloudWatchDeliverySuccess`/`…Failure`** 네 지표로 확인합니다. 한편 CloudTrail 쪽은 ⭐ **호출 API가 「관리 이벤트」로 기록**되고 그 밖의 Runtime API는 **데이터 이벤트라 기본으로 기록되지 않습니다.**
</details>

**Q4.** 지연·오류율·가용성이 3개월간 완전히 평탄한데, 고객 만족도가 조용히 내려가고 있습니다. 무엇을 측정해야 하고 어떤 체계를 세웁니까?

<details><summary>정답 보기</summary>

**행동 지표와 기준선입니다.** ⚠️⚠️ 공식이 **성능 지표(지연·오류율)는 필요하지만 충분하지 않다**고 직접 적습니다 — 미묘한 열화는 **행동 지표**에서 먼저 나타납니다: **천천히 오르는 에스컬레이션 비율 · 조용히 늘어나는 할루시네이션 빈도 · 덜 유능한 도구로 쏠리는 선택 패턴**입니다. 체계는 이렇습니다 — **2~4주** 동안 **추론 반복 수 · 도구 선택 빈도 · 에스컬레이션 비율 · 작업 완료율 · 신뢰도 점수 분포**를 모아 **에이전트별** 기준선을 세우고(**기준선 없는 이상 탐지는 신뢰할 수 없는 신호**를 냅니다), 그 뒤 **CloudWatch 이상 탐지**로 자동 조정하며, ⭐ **심각도별로 경로를 나눕니다**(성능 이상 → 자동 조사 / 행동 이상 → 사람 검토 / 보안 관련 → 즉시 에스컬레이션). 그리고 **드리프트 세 종류를 구분**해야 처방이 맞습니다 — **데이터 드리프트**(입력 분포) · **개념 드리프트**(입력-출력 관계) · **성능 드리프트**(출력 품질). ⚠️ 대시보드 쪽에서는 **KPI 네 차원**(운영·품질·효율·비즈니스) 가운데 빠진 것이 없는지 봅니다 — 하나라도 빠지면 **「완성돼 보이지만 오해를 만드는」 대시보드**가 됩니다. ⚠️ 기준선은 **갱신**해야 합니다(배포 때 한 번 세우고 두면 정당한 변화가 거짓 양성을 냅니다).
</details>

**Q5.** 코드 인터프리터 도구의 CPU·메모리를 보고 자동으로 용량을 조절하는 설계를 검토 중입니다. 또 내가 만든 사내 API 도구의 지표는 같은 대시보드에서 보이지 않습니다. 각각 어떻게 판단합니까?

<details><summary>정답 보기</summary>

**첫째는 성립하지 않고 둘째는 층이 다릅니다.** ⚠️⚠️ 리소스 사용 지표(**`CPUUsed-vCPUHours`·`MemoryUsed-GBHours`**, 차원은 `Service`=`AgentCore.CodeInterpreter`/`AgentCore.Browser`와 `Resource`=도구 ID)는 **1분 해상도로 벤딩**되지만 공식 Note가 **최대 60분 지연될 수 있고 지표마다 정밀도가 다를 수 있다**고 적습니다 — 「실시간으로 CPU·메모리를 보고 스케일한다」는 설계가 그 사실에 걸립니다. 둘째는 **「도구 호출 관찰성」이 세 층**이기 때문입니다: **내장 도구 지표**(`Invocations`·`Throttles`·`SystemErrors`·`UserErrors`·`Latency`·`Duration`)는 ⚠️ **코드 인터프리터와 브라우저 둘에만** 있고 **1분 간격 배치**이며, **Gateway 쪽**은 도구가 **게이트웨이를 지날 때만** 데이터를 주고, **에이전트 자신의 도구 호출**은 프레임워크가 내는 스팬(**`gen_ai.operation.name`=`execute_tool`**, 도구 이름은 **`gen_ai.tool.name`**)에서 봅니다. 사내 API 도구는 뒤의 두 층에서 봐야 합니다. ⚠️ 함께 기억할 것 — `Throttles`는 **`ThrottlingException` + HTTP 429**이고, `Latency`는 **첫 응답 토큰을 보내기 시작할 때까지**(전체 처리 시간이 아닙니다)입니다. ⭐ 도구 열화는 **복합 알람**으로 잡습니다 — 지연이 오르면서 타임아웃 비율도 오르는 도구는 단일 임계로는 어느 쪽도 울리지 않아도 **차단에 가까워진** 상태입니다.
</details>

**Q6.** OpenSearch 벡터 인덱스에 문서를 대량 적재하던 중 **새 벡터 색인이 거부**되기 시작했습니다. 그리고 별도 Aurora 기반 지식 베이스에서는 **오류 없이 검색 결과가 요청보다 적게** 옵니다. 각각의 원인은 무엇입니까?

<details><summary>정답 보기</summary>

**두 증상은 완전히 다른 원인입니다.** 첫째는 **k-NN 서킷 브레이커**입니다 — ⚠️⚠️ **`KNNGraphMemoryUsagePercentage`가 100%에 닿으면 서킷 브레이커가 발동해 새 `knn_vector` 색인이 거부**됩니다. 확인은 **데이터 노드마다 `KNNGraphMemoryUsage`를 `knn.memory.circuit_breaker.limit`과 인스턴스 유형의 가용 RAM에 대조**하는 것이고, 공식 산술은 **RAM의 절반이 Java 힙(최대 32 GiB)이고 k-NN이 남은 절반의 50%**이므로 **RAM 32 GiB 인스턴스는 그래프 8 GiB**(32 × 0.5 × 0.5)를 담습니다. ⭐ `KNNCircuitBreakerTriggered`는 클러스터 단위이고 **어느 노드든 `KNNCacheCapacityReached`가 1이면 이 값도 1**이 됩니다. ⚠️ OpenSearch Service에서는 **`knn.memory.circuit_breaker.enabled`와 `knn.circuit_breaker.triggered`를 바꿀 수 없습니다.** 둘째는 **HNSW 반복 인덱스 스캔이 꺼져 있는 것**입니다 — 공식 권장이 메타데이터 필터링을 쓰면 **반복 인덱스 스캔을 활성화**하라는 것이고(**`pgvector` 0.8.0 이상**), 이유는 **반복 스캔이 없으면 선택적 메타데이터 필터가 기대보다 적은 결과를 돌려주기** 때문입니다 — **필터가 HNSW 인덱스 스캔 뒤에 적용**되므로 그렇습니다. ⚠️ Aurora 쪽은 함께 볼 것이 있습니다: Bedrock이 쓰는 인덱스가 **HNSW(벡터)·GIN(텍스트)·GIN(사용자 지정 메타데이터) 셋**이고, **`ef_construction`을 256**으로 두는 것이 권장(병렬 인덱스 빌드를 쓰는 **`pgvector` 0.6.0 이상**)입니다.
</details>

**Q7.** 데이터 소스의 `.metadata.json` 파일만 수정하고 동기화했는데, ① 어떤 문서는 메타데이터가 반영되지 않고 ② 어떤 CSV는 전체가 다시 수집돼 임베딩 비용이 예상보다 컸습니다. 무엇을 확인합니까?

<details><summary>정답 보기</summary>

**셋을 확인합니다.** ① ⚠️⚠️ **메타데이터 파일이 무시되는 조건**이 있습니다 — `.metadata.json`은 연결된 소스 파일과 **같은 파일 이름·확장자**를 공유해야 하고, 벡터 인덱스가 **OpenSearch Serverless**에 있으면 **`faiss` 엔진으로 구성**돼 있어야 합니다. **`nmslib`이면** 새 인덱스를 `faiss`로 만들어 지식 베이스를 다시 구성해야 합니다(Aurora면 **`custom_metadata` 열**에 메타데이터를 모아 그 열에 인덱스를 두는 것이 권장이고, 그 열이 없으면 **속성마다 개별 열**을 수집 전에 만들어 둬야 합니다). ② ⭐ **메타데이터 전용 최적화**는 조건 셋을 **모두** 만족할 때만 적용됩니다 — **`metadata.json`만 수정**(콘텐츠 파일 무변경) · **연결된 콘텐츠 파일이 CSV가 아님** · **데이터 소스가 사용자 지정 변환 Lambda를 쓰지 않음**. 만족하면 기존 임베딩을 꺼내 메타데이터를 병합해 다시 쓰므로 **임베딩 모델 호출을 피합니다.** ⚠️ **CSV는 메타데이터가 갱신되면 항상 재수집**됩니다 — `documentStructureConfiguration`이 어느 열을 색인할지 정하는데 재처리 없이는 그 구조가 바뀌었는지 알 수 없기 때문입니다. ③ 결과 확인은 **`GetIngestionJob`**(완료 시 `status`가 **`COMPLETE`**)의 ⭐ **`statistics` 객체**와 콘솔 **Sync history → View warnings**입니다. ⚠️⚠️ 그리고 **동기화 완료가 곧 검색 가능은 아닙니다** — **Aurora(RDS) 외의 벡터 스토어는 새 임베딩이 질의에 반영되기까지 몇 분** 걸릴 수 있습니다.
</details>

**Q8.** 운영 중 세 가지 신고가 들어왔습니다 — ① 긴 문서 요약의 **응답이 중간에 끊긴다** ② 간헐적으로 **429**가 난다 ③ 품질 평가를 돌렸는데 **점수가 비어 있다**. 각각 무엇을 보고 어떻게 가릅니까?

<details><summary>정답 보기</summary>

**① `stopReason`을 봅니다.** ⚠️⚠️ **`max_tokens`면 내 설정에 걸린 잘림**이고 **`model_context_window_exceeded`면 컨텍스트 창 초과**로, 공식이 전용 값을 따로 두었기 때문에 **두 증상을 한 신호로 묶으면 처방이 틀립니다**(앞은 한도를 올리는 문제, 뒤는 입력을 줄이거나 나누는 문제). 호출 전에 미리 가리려면 **`CountTokens`**(`POST /model/{modelId}/count-tokens`)를 씁니다 — ⚠️ **토큰화가 모델별이라 모델을 지정**해야 하고, 돌려주는 수는 ⭐ **같은 입력을 보냈을 때 과금될 토큰 수와 일치**하며 응답은 **`inputTokens`**뿐입니다. 그 밖의 값으로 **`malformed_tool_use`**(도구 호출 형식) · **`guardrail_intervened`·`content_filtered`**(차단)도 구분합니다. **② 429가 둘입니다** — ⚠️⚠️ **`ThrottlingException`**(계정 쿼터 초과)과 **`ModelNotReadyException`**(모델 준비 안 됨)이고 뒤쪽은 **SDK가 최대 5회 자동 재시도**하는 종류입니다. **코드만 보고 쿼터를 올리면 틀립니다.** 함께 **400 `ValidationException`·408 `ModelTimeoutException`·424 `ModelErrorException`은 같은 요청을 다시 보내 해결되는 종류가 아니라**는 것을 기억합니다. **③ 평가 파이프라인 자체의 실패**입니다 — 공식이 **빈 평가 결과**와 함께 **`LogEventMissingException`**(스팬에 대응하는 로그 이벤트가 없다) · **`AgentSpanMappingException`·`ToolSpanMappingException`**(스팬에서 질의·도구 출력을 추출할 수 없다) · **`SpanEventParsingException`** · **`Gateway Timeout (504)`** · **`evaluatorId`의 `ValidationException`** · **다중 에이전트 평가 스코핑**(엉뚱한 에이전트를 겨냥)을 열거합니다. ⚠️⚠️ 전제가 **에이전트가 관찰성을 켠 상태로 최소 한 번 호출됐어야** 한다는 것입니다.
</details>

**Q9.** 골든 데이터세트로 할루시네이션을 탐지하는 체계를 만들려고 합니다. 어떤 지표를 쓰고, 모델이 Bedrock 밖에서 돌고 있다면 어떻게 합니까?

<details><summary>정답 보기</summary>

**판정 모델 평가의 내장 지표 둘이 이 자리입니다.** ⭐ **`Builtin.Faithfulness`**가 **프롬프트에 없는 정보가 응답에 들어 있는지**를 보는 할루시네이션 축이고, **`Builtin.Correctness`**는 응답이 옳은지를 보며 ⭐ **참조 응답(그라운드 트루스)을 주면 평가자가 그것을 고려**합니다 — 골든 데이터세트가 들어가는 자리입니다. 응답 일관성에는 **`Builtin.Coherence`**(논리적 공백·불일치·모순), 지시 이탈에는 **`Builtin.FollowingInstructions`**를 붙입니다. 모델이 Bedrock 밖에 있어도 됩니다 — ⭐ **내 응답 데이터를 프롬프트 데이터세트에 직접 넣으면 Bedrock이 모델 호출 단계를 건너뛰고 그 데이터를 바로 평가**하므로, 외부 모델의 출력도 같은 척도로 채점할 수 있습니다. ⚠️ 결과는 콘솔 지표 카드가 **점수 히스토그램과 처음 다섯 프롬프트**의 설명을 보여 주고 **전체 보고서는 내가 지정한 S3 버킷**에 있습니다. ⚠️⚠️ 한 가지 주의 — 공식 기술이 품질 지표로 드는 네 낱말 가운데 **「유창성」에 대응하는 내장 지표는 판정 지표 목록에 없습니다**(관련성·정확성·일관성은 있습니다). 그 자리는 **판정 프롬프트를 직접 쓰는 사용자 지정 지표**로 갑니다.
</details>

**Q10.** 조직 전체의 감사 로그를 한곳에 모으는 설계를 새로 시작합니다. 팀이 「CloudTrail Lake로 하자」고 제안했습니다. 어떻게 판단합니까?

<details><summary>정답 보기</summary>

**새로 도입할 수 없습니다.** ⚠️⚠️ 공식 가용성 변경 공지가 **2026년 5월 31일부터 AWS CloudTrail Lake가 신규 고객에게 열려 있지 않다**고 적습니다. 다만 범위를 정확히 봐야 합니다 — ⚠️ **AWS CloudTrail 본체는 완전히 지원되고 Trails·Insights·Aggregated Events는 영향을 받지 않습니다.** 닫힌 것은 Lake뿐이고, 기존 고객은 계속 쓸 수 있지만 **Lake는 치명적 버그 수정과 보안 업데이트만** 받습니다. ⚠️⚠️ 이미 쓰고 있는 조직이라면 **이벤트 데이터 스토어 유형에 따라 계속 지원 수준이 다릅니다** — **조직 이벤트 데이터 스토어**는 신규 멤버 계정과 추가 리전까지 그대로 동작하지만, **계정 이벤트 데이터 스토어만 있으면 조직에 새로 추가된 계정의 수집을 지원하지 않습니다**(새 계정을 덮으려면 조직 EDS를 만들거나 이전합니다). 공식 권장 이전 대상은 **Amazon CloudWatch**이고 근거로 **OCSF와 OTel 형식 내장 지원** · **OpenSearch 기반 네이티브 분석** · **Apache Iceberg API를 통한 개방 접근**을 듭니다. ⭐ 설계 자체는 바뀌지 않습니다 — **CloudTrail로 호출 메타데이터를, 모델 호출 로깅으로 프롬프트·응답 본문을** 남기고 **변경 불가능한 저장소**에 둡니다(변경 가능한 스토리지에 둔 로그는 감사 추적이 못 된다는 것이 공식이 드는 흔한 실패 중 하나입니다).
</details>

---

### 📌 출처

1. AgentCore 관찰성과 텔레메트리 (세션·트레이스·스팬 정의와 담는 것 · 기본 제공 ↔ 계측 경계 · ADOT 전제 · 콘솔 둘) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-telemetry.html` (2026-11-15 확인)
2. AGENTOPS05 관찰성 구현 (분산 트레이스 의도 · 컨텍스트 전파 · 흔한 실패 넷) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05.html` (2026-11-15 확인)
3. AGENTOPS05-BP04 KPI (네 차원과 예시 · 기준선 2~4주 · 경고 ↔ 치명 임계 · 주간 보고 · 분기별 검토) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp04.html` (2026-11-15 확인)
4. AGENTOPS05-BP02 행동 이상 탐지 (기준선 다섯 신호 · 성능 지표의 불충분성 · 심각도 라우팅 셋 · 드리프트 세 종) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops05-bp02.html` (2026-11-15 확인)
5. AGENTOPS04-BP03 도구 신뢰성 (호출 수·성공률·유형별 오류율·지연 백분위수 · 복합 알람) — `docs.aws.amazon.com/wellarchitected/latest/agentic-ai-lens/agentops04-bp03.html` (2026-11-15 확인)
6. Bedrock 런타임 지표 (`Invocations`의 포함·제외 · 스로틀이 어느 집합에도 없음 · 쿼터 초과는 클라이언트 오류 · `EstimatedTPMQuotaUsage` 단독 사용 금지 · 캐시 읽기 ↔ 쓰기의 쿼터 차이 · `ModelId` 차원 함정) — `docs.aws.amazon.com/bedrock/latest/userguide/monitoring-runtime-metrics.html` (2026-11-15 확인)
7. 모델 호출 로깅 (기본 꺼짐 · 대상 작업 넷 · 같은 계정·리전 · `bedrock-runtime`만 · 버킷 ACL 비활성 · 전달 지표 넷) — `docs.aws.amazon.com/bedrock/latest/userguide/model-invocation-logging.html` (2026-11-15 확인)
8. CloudWatch 이상 탐지 (최대 2주 학습 · 2주 미만에도 켤 수 있음 · 지표 + 통계에 고유 · 논리 범위 묶임 · 기간 제외 · 알람 사용 시 과금) — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Anomaly_Detection.html` (2026-11-15 확인)
9. CloudTrail로 Bedrock API 호출 로깅 (호출 API는 관리 이벤트 · 나머지는 데이터 이벤트로 기본 비기록 · 전 리전 기본값 · Event history) — `docs.aws.amazon.com/bedrock/latest/userguide/logging-using-cloudtrail.html` (2026-11-15 확인)
10. CloudTrail Lake 가용성 변경 (2026-05-31 신규 고객 비개방 · 본체·Trails·Insights·Aggregated Events 영향 없음 · 치명 버그·보안 업데이트만 · 조직 EDS ↔ 계정 EDS 비대칭 · CloudWatch 이전 권장과 근거) — `docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html` (2026-11-15 확인)
11. 내장 도구 관찰성 데이터 (지표 여섯 + 브라우저 테이크오버 · 둘에만 있음 · 1분 배치 · `Throttles`=429 · `Latency`의 경계 · 리소스 지표와 차원 · 최대 60분 지연) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability-tool-metrics.html` (2026-11-15 확인)
12. 관찰성 지원 프레임워크와 계측 (Strands는 SDK 내장 · 나머지는 OTel·OpenInference + 버전 하한 · `scope.name` 판별 · `gen_ai.operation.name` 세 값 · `gen_ai.tool.name` · `session.id` 주입 · 계측만으로는 평가되지 않음 · 기대 도구 궤적) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/supported-frameworks.html` (2026-11-15 확인)
13. OpenSearch 클러스터 지표 (k-NN 지표 전수 · `KNNGraphMemoryUsagePercentage` 100%에서 색인 거부 · 클러스터 ↔ 노드 관계 · 축출 집계 제외 · 근사 k-NN 한정) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/managedomains-cloudwatchmetrics.html` (2026-11-15 확인)
14. OpenSearch k-NN 튜닝과 한계 (설정 둘은 변경 불가 · RAM 절반 힙 · 남은 절반의 50% · 32 GiB → 8 GiB 산술 · UltraWarm 이전 2.17+ · warm에서 캐시 정리·웜업 차단 · 첫 쿼리가 S3에서 적재 · TTL 축출) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/knn.html` (2026-11-15 확인)
15. OpenSearch 샤드 수 선택 (검색 지연 10–30 GiB ↔ 쓰기 중심 30–50 GiB · 기본 샤드 수는 쉽게 바꿀 수 없음) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/bp-sharding.html` (2026-11-15 확인)
16. OpenSearch Serverless 모니터링 (CloudWatch · CloudTrail · EventBridge 셋) — `docs.aws.amazon.com/opensearch-service/latest/developerguide/serverless-monitoring.html` (2026-11-15 확인)
17. Aurora PostgreSQL을 Bedrock 지식 베이스로 (인덱스 셋 — HNSW·텍스트 GIN·메타데이터 GIN · `ef_construction` 256과 pgvector 0.6.0 · HNSW는 0.5.0 이상 · `custom_metadata` 열 없으면 속성별 열 필요) — `docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html` (2026-11-15 확인)
18. 지식 베이스 데이터 동기화 (증분 · 시나리오 넷 · 메타데이터 전용 최적화 조건 셋 · CSV 항상 재수집 · 메타데이터 무시 조건과 `faiss` 요구 · `GetIngestionJob`·`statistics` · Sync history·View warnings · Aurora 외 스토어의 반영 지연) — `docs.aws.amazon.com/bedrock/latest/userguide/kb-data-source-sync-ingest.html` (2026-11-15 확인)
19. Converse API 참조 (`stopReason` 아홉 값 · 오류 아홉 종과 HTTP 코드 · `ModelNotReadyException`의 SDK 자동 재시도) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_Converse.html` (2026-11-15 확인)
20. CountTokens API 참조 (모델별 토큰화 · 과금 토큰과 일치 · 입력 Union · 응답은 `inputTokens` · 용례 셋) — `docs.aws.amazon.com/bedrock/latest/APIReference/API_runtime_CountTokens.html` (2026-11-15 확인)
21. 평가 문제 진단 (빈 결과 · 예외 여섯 종 · 다중 에이전트 스코핑 · 관찰성 전제 · 필요 권한) — `docs.aws.amazon.com/bedrock-agentcore/latest/devguide/diagnose-evaluation-issues.html` (2026-11-15 확인)
22. 판정 모델 평가의 내장 지표 (`Builtin.Faithfulness`의 정의 · `Builtin.Correctness`와 참조 응답 · `Coherence`·`FollowingInstructions` · 응답 데이터 직접 제공 시 호출 생략 · 히스토그램과 S3 보고서) — `docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation-metrics.html` (2026-11-15 확인)
