---
examGuideTaskId: dva-t4-1
certCode: DVA-C03
domain: 4
domainName: 문제 해결 및 최적화
domainWeightPct: 22
title: 근본 원인 분석 지원 (디버깅·지표/로그/추적 해석·로그 쿼리·배포 실패 로그·AI 조사)
coversTasks:
  - "4.1"
sources:
  - title: Types of metrics for Lambda Event Functions
    url: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html
  - title: Invoking a Lambda Event Function asynchronously
    url: https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
  - title: Analyzing log data with CloudWatch Logs Insights
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
  - title: Supported logs and discovered fields (Logs Insights)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_AnalyzeLogData-discoverable-fields.html
  - title: StartQuery (CloudWatch Logs API)
    url: https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html
  - title: Creating metrics from log events using filters
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html
  - title: AWS X-Ray segment documents
    url: https://docs.aws.amazon.com/xray/latest/devguide/xray-api-segmentdocuments.html
  - title: Configuring sampling rules (X-Ray)
    url: https://docs.aws.amazon.com/xray/latest/devguide/xray-console-sampling.html
  - title: View log data for CodeDeploy EC2/On-Premises deployments
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-view-logs.html
  - title: Choose how to handle failures when provisioning resources (CloudFormation)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stack-failure-options.html
  - title: Set up an investigation group (CloudWatch investigations)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Investigations-GetStarted-Group.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
lastVerified: 2026-11-02
---

# 근본 원인 분석 지원 (디버깅·지표/로그/추적 해석·로그 쿼리·배포 실패 로그·AI 조사)

> **커버하는 공식 Task** — DVA-C03 · 도메인 4 「문제 해결 및 최적화」(22%) · **작업 4.1 근본 원인 분석을 지원합니다** (`dva-t4-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 다섯 개(4.1.1~4.1.5)를 모두 덮습니다.

> ⚠️ **C03에서 기술 4.1.5가 신설됐습니다** — "**AWS AI 도구**를 사용하여 오류를 분석하고 문제 해결 제안을 생성합니다". 그리고 도메인 4의 비중이 **18% → 22%**로 올랐습니다.

> ⚠️ **Lambda 공식 문서의 용어가 바뀌었습니다** — 원래의 함수 유형을 이제 **`Event Function`(이벤트 함수)**이라고 부르고(Web Functions·MicroVMs와 구분하기 위한 이름), 지표 페이지 제목도 「Types of metrics for Lambda **Event Functions**」입니다. ⭐ **기반 리소스는 그대로입니다** — `CreateFunction`·`Invoke` 같은 API, SDK·CLI, `AWS::Lambda::Function` 리소스 유형, ARN이 전부 `function`을 계속 쓰므로 **코드·템플릿·IAM 권한을 바꿀 필요가 없습니다.** 시험 가이드는 "AWS Lambda"로만 적으니 **용어 차이를 결함으로 읽지 않습니다.**

---

## ✅ 학습 목표 체크리스트

- [ ] 비동기 호출의 **재시도·보관·폐기** 경로를 따라가며 결함을 좁힌다
- [ ] Lambda 지표를 **호출·성능·동시성·비동기** 네 묶음으로 읽는다
- [ ] X-Ray의 **주석과 메타데이터**를 색인 여부로 구분하고 샘플링을 설명한다
- [ ] Logs Insights **세 가지 쿼리 언어**와 시스템 필드·쿼터를 안다
- [ ] **지표 필터와 Logs Insights**를 용도로 갈라 쓴다
- [ ] 배포 실패를 **어느 로그에서 읽는지** 서비스별로 짚는다
- [ ] CloudFormation의 **실패 처리 선택지**를 설명한다
- [ ] 기술 4.1.5의 범위를 **확인된 사실**로만 잡는다

---

## 🎯 왜 중요한가

근본 원인 분석 문항은 "**무엇을 고치는가**"가 아니라 "**어디를 보면 그것이 보이는가**"를 묻습니다. 그래서 서비스별 증상 목록을 외우는 것보다 **신호가 어디에 남는지**를 아는 쪽이 빠릅니다 — 호출 결과는 **지표**에, 실행 중 일어난 일은 **로그**에, 호출이 지나간 경로는 **추적**에 남습니다.

그리고 이 작업의 함정은 대개 **"신호가 없는 것"이 신호**라는 데 있습니다. 스로틀된 요청은 `Invocations`에도 `Errors`에도 세지 않고, 프로비저닝된 동시성 지표는 함수가 한가하면 **발행되지 않으며**, 지표 필터는 **만든 뒤의 이벤트만** 지표로 만듭니다. "지표가 0이다"를 "문제가 없다"로 읽으면 그 자리에서 틀립니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **비동기 호출**: 이벤트를 큐에 넣고 **`202`만 돌려줍니다**(응답 본문 없음). 함수 오류는 **2회 재시도**(0~2로 조정), 스로틀·시스템 오류는 큐에 **최대 6시간**(이벤트 최대 수명 60초~6시간). ⚠️ **예약 동시성 0이면 재시도가 없습니다**
- **폐기 이벤트**는 **DLQ**(SQS 큐·SNS 주제) 또는 **대상(destination)**으로 보냅니다 — 대상은 큐·주제·함수·이벤트 버스이고 ⚠️ **S3는 on-failure 대상만** 됩니다
- ⚠️ **스로틀된 요청은 `Invocations`에도 `Errors`에도 세지 않습니다**(`TooManyRequestsException`). `Invocations`는 **청구된 요청 수**와 같습니다
- **`Duration`은 콜드 스타트 시간을 포함하지 않고** 백분위(`p95`) 통계를 지원합니다. ⚠️ **`Errors` 지표의 타임스탬프는 오류 시점이 아니라 호출 시점**입니다
- **X-Ray**: **`annotations`는 색인되어 필터(`annotation[key]`)로 검색**되고 **추적당 50개**까지, **`metadata`는 색인되지 않습니다**
- **기본 샘플링은 "초당 첫 요청(저수지 1) + 추가 요청의 5%"**입니다. ⚠️ **로컬 JSON 규칙은 인스턴스마다 독립 샘플링**이라 전체 비율이 올라갑니다 — 콘솔 규칙은 **서비스가 저수지를 인스턴스에 쿼터로 배분**합니다
- **Logs Insights 세 언어**: Logs Insights QL · OpenSearch **PPL** · OpenSearch **SQL**. 동시 실행은 **QL 100개/계정**(대시보드 위젯 포함) · **PPL·SQL 15개**
- **`StartQuery`**: 로그 그룹 **최대 50개**, `limit` 최대 **100,000**(한 번의 `GetQueryResults`는 **10,000**). ⚠️ **100,000은 QL 전용**이고 PPL·SQL은 지원하지 않습니다
- **지표 필터**는 수집 시점에 로그를 **숫자 지표로** 바꿔 경보를 걸게 합니다 — 로그 그룹당 **100개**, ⚠️ **소급 적용되지 않고** 커스텀 지표로 **과금**되며 고카디널리티 차원은 1시간에 **1,000개** 쌍을 넘기면 **비활성화될 수 있습니다**
- **CloudWatch investigations**(기술 4.1.5): 텔레메트리를 훑어 **지표·로그·배포 이벤트·근본 원인 가설**을 제안합니다. ⚠️ API·CLI(**`aiops`**)로는 **조사 그룹과 그룹 정책만** 다루고 **조사의 시작·관리는 콘솔에서만** 합니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **세그먼트(segment)** | X-Ray에서 한 서비스가 한 요청에 대해 기록하는 작업 단위 문서. 하위 작업은 **하위 세그먼트** |
| **주석(annotation)** | 세그먼트에 붙이는 키-값. **색인되어 필터 검색에 쓰인다**(추적당 50개) |
| **메타데이터(metadata)** | 세그먼트에 붙이는 임의 데이터. **색인되지 않아 검색 조건이 되지 못한다** |
| **저수지(reservoir)** | 샘플링 규칙이 **초당 반드시 기록할 요청 수**. 그 위로는 고정 비율(rate)이 적용된다 |
| **시스템 필드** | Logs Insights가 모든 이벤트에 자동으로 붙이는 `@`로 시작하는 필드(`@message`·`@timestamp` 등) |
| **지표 필터(metric filter)** | 로그가 들어올 때 패턴을 찾아 **CloudWatch 지표로 변환**하는 규칙 |
| **구독 필터(subscription filter)** | 로그 이벤트를 **다른 서비스로 실시간 전달**하는 규칙 |
| **Live Tail** | 수집되는 로그를 **실시간으로 들여다보는** 콘솔 기능 |
| **조사 그룹(investigation group)** | CloudWatch investigations의 1회성 설정 단위(접근 권한·보존 기간·암호화) |

---

## 📖 핵심 개념

### 1) 코드·서비스 통합 디버깅 (기술 4.1.1) {#debugging}

공식 문구는 "애플리케이션 코드 및 **서비스 통합 문제**를 디버깅하여 결함을 식별합니다"입니다. **통합**이 핵심어입니다 — 코드 안의 예외보다 **경계에서 일어나는 일**이 더 자주 문제입니다.

**비동기 호출 경로를 끝까지 따라갑니다**

- 비동기 호출(`InvocationType=Event`)은 Lambda가 **이벤트를 내부 큐에 넣고 `{"StatusCode": 202}`만** 돌려줍니다. 출력 파일은 만들어지지만 **내용이 없습니다.** 별도 프로세스가 큐에서 읽어 함수로 보냅니다.
- ⚠️ 그래서 **호출이 성공했다는 응답은 함수가 성공했다는 뜻이 아닙니다.** 결함은 호출자가 아니라 **지표·로그·DLQ**에서 찾습니다.
- 큐에 **이벤트를 넣지 못한 경우에만** 오류가 호출 출력에 나타납니다.

| 원인 | 재시도 동작 | 바꿀 수 있는 것 |
|---|---|---|
| **함수 오류**(코드·런타임 예외, 타임아웃) | **2회 재시도** | 함수의 재시도 횟수를 **0~2**로 |
| **스로틀(429)·시스템 오류(5xx)** | 큐에 보관하며 **최대 6시간** 재시도 | 이벤트 최대 수명을 **60초~6시간**으로 |
| ⚠️ **예약 동시성이 0** | **재시도하지 않습니다** | — |

- 모든 시도가 실패하거나 큐에 너무 오래 머문 이벤트는 Lambda가 **폐기**합니다. 폐기분을 잡으려면 **DLQ**(SQS 큐 또는 SNS 주제, **실행 역할에 쓰기 권한 필요**)나 **대상(destination)**을 구성합니다.
- **대상**은 성공(on-success)과 실패(on-failure)를 **따로** 지정하고 큐·주제·함수·이벤트 버스를 쓸 수 있습니다. ⚠️ **S3는 on-failure 대상만** 지원하므로 성공 기록을 S3에 남기려 하면 구성이 되지 않습니다. DLQ와 **함께 또는 대신** 쓸 수 있습니다.

**지표가 결함의 위치를 가리킵니다**

| 지표 | 무엇을 말해 주는가 |
|---|---|
| **`DeadLetterErrors`** | Lambda가 **DLQ로 보내려다 실패**한 횟수 — 리소스 설정 오류·크기 한도 |
| **`DestinationDeliveryFailures`** | **대상으로 보내려다 실패**한 횟수 — 권한·구성·크기 한도, ⚠️ **SQS FIFO·SNS FIFO처럼 지원되지 않는 대상 유형**일 때도 난다 |
| **`Throttles`** | 동시성이 없어 거절된 호출(`TooManyRequestsException`). ⚠️ **`Invocations`·`Errors`에 세지 않는다** |
| **`RecursiveInvocationsDropped`** | 무한 재귀 고리를 감지해 Lambda가 **호출을 멈춘** 횟수 — 지원 SDK가 넣는 메타데이터로 체인을 추적해 **약 16회**에서 다음 호출을 폐기한다(기능을 끄면 이 지표도 발행되지 않는다) |
| **`SignatureValidationErrors`** | 코드 서명 정책이 **`Warn`**일 때 만료·불일치·취소 검사에 실패했지만 배포가 허용된 횟수 |

- ⭐ **이벤트 소스 매핑 스로틀의 전형적인 모습**: 처리 시간이 긴 함수가 큐에서 메시지를 읽으면 메시지가 처리보다 빨리 쌓이고, 계정의 미예약 동시성(예: 100)까지 확장한 뒤 스로틀이 걸립니다. ⚠️ **이때 오류 지표는 올라가지 않습니다** — `Concurrent executions`가 상한에 닿고 `Throttles`만 올라갑니다. 대응은 **동시성 증가 요청 · 함수 처리 속도 개선 · 배치 크기 증가**입니다.

**API Gateway 통합은 로그를 켜야 보입니다**

- 로그는 두 종류입니다 — **실행 로그**(권한 부여자 평가·요청 검증·통합 디스패치·매핑·오류 처리 같은 **내부 처리 과정**)와 **액세스 로그**(요청당 요약 한 줄, 형식과 대상을 직접 지정). ⚠️ **두 가지는 서로 독립적으로 켭니다.**
- 실행 로그 수준은 **`Off` / 오류만 / 오류와 정보**입니다. ⚠️ **오류만으로 두면 성공한 요청이 기록되지 않습니다.**
- **데이터 추적(Data tracing)**을 켜면 **전체 요청·응답 데이터**가 남습니다 — ⚠️ 민감 데이터가 기록될 수 있어 **운영 API에는 권장되지 않습니다.**
- 계정마다 **CloudWatch 로그 역할 ARN을 한 번** 설정해야 하고, ⭐ **스테이지 설정을 바꿀 때는 API를 다시 배포하지 않아도 됩니다.**

> 🧠 **원리** — 비동기·이벤트 기반 경계에서는 **호출자에게 돌아오는 응답이 결과를 담지 않습니다.** 그래서 디버깅은 "응답을 읽는 일"이 아니라 **"신호가 남는 네 곳(지표·로그·DLQ·대상)을 순서대로 확인하는 일"**이 됩니다. 어느 신호도 올라가지 않는데 결과가 없다면 **이벤트가 애초에 큐에 들어갔는지**부터 봅니다.

### 2) 지표·로그·추적 해석 (기술 4.1.2) {#interpret}

**Lambda 지표는 네 묶음으로 읽습니다.** 묶음마다 **봐야 하는 통계**가 다릅니다.

| 묶음 | 대표 지표 | 통계 | 메모 |
|---|---|---|---|
| **호출** | `Invocations` · `Errors` · `Throttles` · `DeadLetterErrors` · `DestinationDeliveryFailures` | **`Sum`** | 결과의 이진 지시자다. `Invocations` = **청구된 요청 수**, `Errors` = 코드·런타임 예외(**타임아웃·구성 오류 포함**) |
| **성능** | `Duration` · `PostRuntimeExtensionsDuration` · `IteratorAge` · `OffsetLag` | **`Average`·`Max`**(+백분위) | `Duration`은 ⚠️ **콜드 스타트 시간을 포함하지 않고**, 청구 duration은 **ms 단위로 올림**이다 |
| **동시성** | `ConcurrentExecutions` · `ProvisionedConcurrentExecutions` · `ProvisionedConcurrencyUtilization` · `UnreservedConcurrentExecutions` · `ClaimedAccountConcurrency` | **`Max`** | 상한에 얼마나 가까운지를 보는 지표다 |
| **비동기** | 비동기 호출 관련 지표 | — | 큐에 머문 이벤트·폐기를 본다 |

- **오류율**은 `Errors ÷ Invocations`로 계산합니다. ⚠️ 그런데 **`Errors`의 타임스탬프는 오류가 난 시점이 아니라 함수가 호출된 시점**이라, 긴 함수에서는 오류가 **앞쪽 분(minute)에 찍힙니다.**
- **`Duration`은 백분위(`p`) 통계를 지원합니다** — `p95`는 가장 느린 5%를 빼고 본 최대 시간이라 **평균·최대가 이상치에 끌려가는 것**을 피합니다.
- **`IteratorAge`**는 DynamoDB·Kinesis·Amazon DocumentDB 이벤트 소스에서 **이벤트 안 마지막 레코드의 나이(ms)**입니다 — 스트림이 레코드를 받은 시점과 이벤트 소스 매핑이 함수로 보낸 시점의 차이이고, **소비가 생산을 못 따라가고 있다는 신호**입니다. Kafka 쪽은 같은 역할을 **`OffsetLag`**(토픽 수준)가 합니다.
- ⚠️ **`ProvisionedConcurrencyUtilization`은 함수가 한가하면 발행되지 않습니다**(`ProvisionedConcurrentExecutions`에서 파생되기 때문). **이 지표로 경보를 걸면 "데이터 없음" 처리를 함께 정해야 합니다.**
- **`ClaimedAccountConcurrency`** = `UnreservedConcurrentExecutions` + 할당된 동시성(예약 + 프로비저닝 총합) — **온디맨드 호출에 쓸 수 없는 동시성**이라 리전 쿼터에 얼마나 다가갔는지를 봅니다.

**추적은 "경로"를 남깁니다**

- 세그먼트·하위 세그먼트 문서에 **`annotations`**를 붙이면 X-Ray가 **색인**해 필터 식의 **`annotation[key]`**로 검색할 수 있습니다. 제약: **문자열·숫자·부울만**(객체·배열 불가) · **추적당 50개** · 키는 **영숫자(밑줄·점 허용) 최대 500자** · 값은 **최대 1,000 유니코드 문자** · ⚠️ **같은 키로 다시 쓰면 앞 값을 덮어씁니다.**
- **`metadata`**는 색인되지 않습니다 — 보기에는 담기지만 **검색 조건으로 쓸 수 없습니다.** "주석 대신 메타데이터에 넣었더니 필터가 안 된다"가 정확히 이 차이입니다.
- 세그먼트는 `aws` 블록에 리소스 정보(예: EC2 인스턴스 ID·가용 영역)와 `http` 블록에 요청·응답(상태 코드 포함)을 담습니다.

**샘플링을 모르면 "추적이 없다"를 오진합니다**

- 기본값은 **초당 첫 요청(저수지 1) + 추가 요청의 5%**입니다. 저수지는 **서비스가 요청을 받는 동안 매초 최소 1건은 기록되게** 하고, 비율은 **저수지를 넘은 요청**에 적용됩니다.
- 규칙 옵션은 **우선순위(Priority)·고정 비율(FixedRate)·저수지 크기(ReservoirSize)**와 호스트·메서드·URL·서비스 이름·서비스 유형·리소스 ARN 일치 조건, 그리고 ⚠️ **요청 속성 일치(최대 5개)**입니다.
- ⚠️ **로컬 JSON 규칙은 인스턴스마다 독립적으로 샘플링**합니다 — 여러 인스턴스를 돌리면 **저수지가 합산되는 효과**로 전체 샘플 비율이 올라가고, 규칙을 바꾸려면 **코드를 다시 배포**해야 합니다. 콘솔(서비스) 규칙을 쓰면 **서비스가 저수지를 관리하고 실행 중인 인스턴스 수에 맞춰 쿼터를 배분**합니다.
- 샘플링 구성을 지원하는 **활성 추적** 경로: **API Gateway 스테이지 · AWS AppSync · Step Functions 상태 머신**, 그리고 EC2·ECS·Elastic Beanstalk에서 **ADOT 또는 X-Ray SDK로 계측**한 애플리케이션.

> 🧠 **원리** — 세 신호는 **해상도와 수명이 다릅니다.** 지표는 **집계값**이라 "언제 나빠졌는가"에 강하고, 로그는 **원문**이라 "무엇이 일어났는가"에 강하며, 추적은 **경로**라 "어느 구간이 느렸는가"에 강합니다. 그래서 문항이 "어떤 구간이 지연을 만드는가"를 물으면 추적, "어떤 요청이 왜 실패했는가"를 물으면 로그, "언제부터 비정상인가"를 물으면 지표가 답입니다.

### 3) 로그를 쿼리해 관련 데이터 찾기 (기술 4.1.3) {#log-query}

**CloudWatch Logs Insights는 쿼리 언어가 셋입니다.**

| 언어 | 성격 | 동시 실행 |
|---|---|---|
| **Logs Insights QL** | 이 목적에 맞춰 만든 언어. 명령을 **파이프 문자로 잇고** 주석은 `#`로 단다 | **계정당 100개**(⚠️ **대시보드에 올린 쿼리 포함**) |
| **OpenSearch PPL** | 파이프로 구분된 명령으로 분석. 수학·문자열·날짜·조건 함수 | **15개** |
| **OpenSearch SQL** | `SELECT`·`FROM`·`WHERE`·`GROUP BY`·`HAVING`. ⭐ **로그 그룹 간 JOIN·하위 쿼리** | **15개** |

- ⚠️ **PPL·SQL에서는 특수문자가 든 필드를 백틱으로 감쌉니다** — `` `@message` ``·`` `Operation.Export` ``·`` `Test::Field` ``. 순수 알파벳 이름은 감싸지 않아도 됩니다.
- ⚠️ **SQL은 로그 그룹을 쿼리 문자열 안에** 적습니다(다른 언어는 파라미터로 지정).

**시스템 필드는 자동으로 붙습니다**

`@message`(원문) · `@timestamp`(이벤트 시각) · `@ingestionTime`(CloudWatch Logs가 받은 시각) · `@logStream` · `@log`(**`account-id:log-group-name`** — 여러 로그 그룹을 한 번에 쿼리할 때 출처를 가른다) · `@entity`(관련 텔레메트리용 평탄화 JSON).

- ⚠️ **필드 자동 검색은 Standard 로그 클래스에서만** 됩니다.
- **Lambda 로그의 검색 필드**: `@requestId` · `@duration` · `@billedDuration` · `@type` · `@maxMemoryUsed` · `@memorySize`, 그리고 로그 줄에 X-Ray 추적 ID가 있으면 **`@xrayTraceId`·`@xraySegmentId`**까지. ⚠️ **한 로그 이벤트에서 자동 검색되는 것은 첫 번째 JSON 조각뿐**이라, 조각이 여러 개면 **`parse`**로 직접 꺼냅니다.
- **JSON 필드는 점 표기**로 읽습니다(`userIdentity.type`, 배열은 `...items.0.instanceId`). ⚠️ **값이 "JSON 문자열"이면 점 표기가 통하지 않습니다** — 그때는 **`jsonParse`**로 맵으로 바꿔야 하위 필드에 닿습니다. 그리고 ⚠️ **JSON 로그에서 추출되는 필드는 최대 200개**입니다.

**쿼터와 비용 규율**

- **`StartQuery`**: 로그 그룹 **최대 50개**, `limit` **최대 100,000**(한 번의 `GetQueryResults`로는 **10,000**, 나머지는 `nextToken`으로 페이지네이션). ⚠️ **100,000은 Logs Insights QL 전용**이고 PPL·SQL은 지원하지 않습니다.
- 공식 권장: **필요한 로그 그룹만 선택** · **가장 좁은 시간 범위** · ⚠️ **콘솔을 닫기 전에 쿼리를 취소**(그러지 않으면 완료될 때까지 계속 실행됩니다) · ⚠️ **대시보드 위젯은 새로 고침마다 새 쿼리를 시작**하므로 높은 빈도를 피합니다.
- ⚠️ **로그 클래스에 따라 못 쓰는 명령이 있습니다** — Essentials 클래스(구 Infrequent Access)는 **`pattern`·`diff`·`unmask`**를 지원하지 않습니다.

**지표 필터·구독 필터·Live Tail은 Insights와 다른 도구입니다**

- 이 셋은 **공통 필터 패턴 문법**을 씁니다(⚠️ **Logs Insights QL과 다른 문법**입니다). 용도는 각각 **지표로 변환 · 다른 서비스로 전달 · 실시간 열람**입니다.
- **지표 필터**는 수집되는 로그를 숫자 지표로 바꿔 **그래프·경보**를 걸게 합니다. 로그 그룹당 **최대 100개**, 차원·단위를 붙일 수 있고(⚠️ **단위는 나중에 바꿔도 반영되지 않습니다**), 백분위 통계도 쓸 수 있습니다(값에 음수가 없을 때).
- ⚠️ **소급 적용되지 않습니다** — 필터를 만든 **뒤에** 생긴 이벤트만 지표가 됩니다. 콘솔 미리보기는 검증용으로 **최대 50줄**만 보여 줍니다.
- ⚠️ **추출된 지표는 커스텀 지표로 과금**됩니다. `IPAddress`·`requestID` 같은 **고카디널리티 필드를 차원으로 쓰면** 값마다 별도 지표가 되고, **한 시간에 1,000개의 다른 이름/값 쌍**을 만들면 CloudWatch Logs가 그 **지표 필터를 비활성화할 수 있습니다.**
- 정규식도 쓸 수 있지만 쿼터가 있습니다 — **필터 패턴 하나에 정규식 2개**, **로그 그룹당 5개**.

> 🧠 **원리** — **"지금 조사하는가, 앞으로 감시하는가"**가 도구를 가릅니다. 조사는 **임의의 질문을 그때그때** 던지는 일이라 Logs Insights(스캔 비용·쿼터)가 맞고, 감시는 **같은 질문을 계속** 던지는 일이라 지표 필터(수집 시 변환 → 경보)가 맞습니다. 그래서 "경보를 걸고 싶다"는 요구는 거의 항상 **지표 필터 또는 EMF** 쪽입니다.

### 4) 출력 로그로 배포 실패 문제 해결 (기술 4.1.4) {#deploy-failure}

공식 문구는 "**출력 로그**를 사용하여 배포 실패 문제를 해결합니다"입니다. 배포 경로마다 **읽어야 하는 로그가 다릅니다.**

**CodeDeploy EC2·온프레미스 — 로그가 인스턴스에 있습니다**

| 로그 | 위치(Amazon Linux·RHEL·Ubuntu) | 담는 것 |
|---|---|---|
| **배포 로그** | `/opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log` | 배포 진행 기록 |
| **에이전트 로그** | `/var/log/aws/codedeploy-agent/codedeploy-agent.log` | 에이전트 상태·전체 배포 상태 |
| **스크립트 로그** | `/opt/codedeploy-agent/deployment-root/<배포 그룹 ID>/<배포 ID>/logs/scripts.log` | **수명 주기 훅 스크립트의 `stdout`·`stderr`** |

- 에이전트 로그는 **매일 또는 64 MB에서 회전**하고(`codedeploy-agent.YYYYMMDD.log`), **7일 뒤 정리**됩니다. 스크립트 로그는 **64 MB 기준으로 최대 8개** 보관합니다(둘 다 구성 가능).
- ⭐ 훅 스크립트가 실패한 이유는 **거의 항상 `scripts.log`**에 있습니다 — 배포 상태만 보고 "원인 불명"으로 끝내지 않습니다.

**CloudFormation — 실패 처리 방식을 먼저 고릅니다**

- 실패 시 CloudFormation은 **독립적인 프로비저닝 경로마다 첫 실패 지점에서 멈춥니다**(리소스 의존성을 분석해 독립 경로를 병렬 처리하기 때문입니다).
- **"성공적으로 프로비저닝된 리소스 보존"** 옵션을 켜면 처음부터 다시 만들지 않고 **`CREATE_FAILED`·`UPDATE_FAILED` 리소스만 고쳐 이어서** 진행할 수 있습니다. 이 옵션은 **모든 스택 배포와 변경 세트 작업**에 쓸 수 있습니다.
  - **생성**에서는 성공한 리소스의 상태를 보존하고 실패한 것은 **다음 업데이트까지 실패 상태로 둡니다.**
  - **업데이트·변경 세트**에서는 성공분을 보존하고 실패분을 **마지막으로 알려진 안정 상태로 롤백**합니다. ⚠️ **안정 상태가 없는 리소스는 다음 스택 작업에서 삭제됩니다.**

**그 밖의 경로**

- **Lambda 배포**: 코드 서명 정책이 `Warn`이면 검증 실패에도 배포가 진행되고 **`SignatureValidationErrors`**로만 드러납니다 — 지표를 안 보면 조용히 지나갑니다.
- **API Gateway**: 배포 자체보다 **스테이지 설정(로그 수준·역할 ARN)**이 빠져 로그가 없는 경우가 많습니다. ⚠️ **로그가 없는 것을 "요청이 안 왔다"로 읽지 않습니다.**

> 🧠 **원리** — 배포 실패의 로그는 **"누가 실행했는가"가 있는 곳**에 남습니다. 스크립트는 **인스턴스**가 실행하므로 인스턴스 파일 시스템에, 리소스 생성은 **CloudFormation**이 하므로 스택 이벤트에, 트래픽 전환 검증은 **훅 함수**가 하므로 그 함수의 로그에 남습니다. 그래서 "실패했다"를 받으면 먼저 **그 단계의 실행 주체**를 정하고 그 주체의 로그로 갑니다.

### 5) AI 도구로 오류 분석·문제 해결 제안 (기술 4.1.5) {#ai-rca}

🆕 **C03 신설 기술**입니다. 범위 내 기능에서 이 문구에 정확히 대응하는 것은 **CloudWatch investigations**입니다.

- **생성형 AI 기반 인시던트 대응 보조 기능**으로, 시스템의 **텔레메트리를 훑어** 관련될 수 있는 것을 꺼내 줍니다 — 공식 설명이 꼽는 것은 **지표 · 로그 · 배포 이벤트 · 근본 원인 가설**입니다.
- ⚠️ **API·CLI(`aiops` 네임스페이스)로 할 수 있는 일은 조사 그룹과 그룹 정책의 생성·관리·삭제뿐**이고, **조사를 시작하고 관리하는 것은 CloudWatch 콘솔에서만** 합니다. 이 비대칭이 이 기술에서 가장 자주 묻히는 사실입니다.
- **조사 그룹**은 **1회성 설정**이고 접근 권한 · **교차 계정 조사 지원** · 고객 관리형 KMS 키 암호화 · **보존 기간**을 중앙에서 관리합니다. 공식 사용자 가이드는 **계정에 조사 그룹 하나**로 적고, API 참조는 **계정의 리전마다 하나**(각 리전의 조사는 그 리전의 그룹에 속한다)로 적습니다.
- 설정에는 **`AIOpsConsoleAdminPolicy`** 또는 **`AdministratorAccess`**가 붙은 IAM 주체가 필요하고, 권장 방식인 "새 IAM 역할 생성"을 고르려면 **`iam:CreateRole`·`iam:AttachRolePolicy`·`iam:PutRolePolicy`**가 필요합니다.
- ⚠️ **경보가 조사를 시작하게 하려면 리소스 정책이 따로 필요합니다** — `CreateInvestigationGroup`으로 그룹을 만든 경우 **`PutInvestigationGroupPolicy`**로 CloudWatch 경보에 그 권한을 줘야 합니다.
- ⚠️ **교차 리전 추론(cross-Region inference)**을 사용해 트래픽을 여러 리전에 분산합니다 — 데이터 처리 리전을 제약으로 보는 조직에서는 이것이 검토 사항이 됩니다.

**이 기술을 공부할 때의 경계**

- ⚠️ **기술 문구가 특정 서비스를 지목하지 않습니다.** 그러니 "오류 분석을 자동화하는 **그 서비스**는 무엇인가" 같은 단일 정답 구도는 공식 근거가 약합니다 — **확인된 사실**(콘솔 전용 동작 · `aiops`가 다루는 범위 · 필요한 IAM 정책 이름)을 묻는 쪽이 정확합니다.
- 같은 수명 주기의 AI 기술 넷은 **1.1.9(개발) · 3.2.5(테스트) · 3.3.9(CI/CD) · 4.1.5(오류 분석)**이고, **4.3.6(최적화 기회)**이 다섯째입니다. 도구가 바뀌는 것이 아니라 **붙는 단계가 바뀝니다.**

> 🧠 **원리** — investigations가 하는 일은 **"사람이 평소 열어 보는 창을 한꺼번에 열어 주는 것"**입니다(지표·로그·배포 이벤트·변경 이력). 그래서 이 기능이 유용한 조건은 **텔레메트리가 이미 모여 있을 때**이고, 로그를 안 보내고 추적을 끈 시스템에서는 AI가 꺼낼 것이 없습니다 — 4.2(관찰성)가 4.1.5의 전제라는 뜻입니다.

---

## ✍️ 시험 포인트

- **"비동기로 호출했는데 결과가 없다"** → 응답은 **`202`뿐**입니다. **지표·로그·DLQ·대상** 순으로 확인합니다.
- **"함수 오류인데 재시도가 안 된다"** → ⚠️ **예약 동시성이 0**이면 재시도가 없습니다.
- **"폐기 이벤트를 S3에 모으고 싶다"** → **on-failure 대상**으로만 됩니다(on-success는 불가).
- **"오류는 0인데 처리량이 안 오른다"** → **`Throttles`**를 봅니다. 스로틀은 **`Invocations`·`Errors`에 세지 않습니다.**
- **"평균 지연은 괜찮은데 사용자 불만"** → **`Duration`의 `p95`**로 봅니다.
- **"스트림 처리가 밀린다"** → **`IteratorAge`**(Kafka는 `OffsetLag`).
- **"주석으로 검색이 안 된다"** → **메타데이터에 넣은 것**이거나 **추적당 50개**를 넘겼거나 **같은 키를 덮어썼습니다.**
- **"추적이 일부만 보인다"** → **기본 샘플링(초당 1건 + 5%)** 때문입니다. 저수지·비율을 올립니다.
- **"인스턴스를 늘렸더니 샘플 비율이 올라갔다"** → **로컬 JSON 규칙**이라 저수지가 합산된 것입니다 → **콘솔 규칙**으로 옮깁니다.
- **"로그 그룹 60개를 한 쿼리로"** → ⚠️ **`StartQuery`는 50개**까지입니다.
- **"쿼리 결과를 10만 건 받아야 한다"** → **QL만** 가능하고 **`GetQueryResults`는 한 번에 10,000건**입니다.
- **"지표 필터를 만들었는데 과거 데이터가 없다"** → ⚠️ **소급 적용되지 않습니다.**
- **"지표 필터가 어느 순간 멈췄다"** → 고카디널리티 차원으로 **1시간에 1,000쌍**을 넘겼을 수 있습니다.
- **"훅 스크립트가 왜 실패했는지 모른다"** → 인스턴스의 **`scripts.log`**를 읽습니다.
- **"스택 생성이 중간에 실패했는데 전부 지우고 다시 하기는 싫다"** → **성공 리소스 보존** 옵션으로 이어서 진행합니다.
- **"CLI로 조사를 시작하려는데 명령이 없다"** → ⚠️ **`aiops`는 조사 그룹·정책만** 다루고 조사 시작은 **콘솔 전용**입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 비동기 호출의 `202`를 처리 성공으로 읽는다 | **큐에 들어갔다는 뜻**일 뿐이다 |
| 스로틀이 `Errors`에 섞여 보일 것이라고 본다 | ⚠️ **`Invocations`·`Errors` 어디에도 세지 않는다** |
| 예약 동시성 0에서도 재시도가 있다고 본다 | **재시도하지 않는다** |
| 성공 기록을 S3 대상으로 보내려 한다 | **S3는 on-failure 대상만** 지원한다 |
| `Duration`에 콜드 스타트가 포함된다고 본다 | **포함되지 않는다** |
| `Errors` 타임스탬프를 오류 발생 시점으로 읽는다 | ⚠️ **호출된 시점**이다 |
| `ProvisionedConcurrencyUtilization` 경보가 항상 평가될 것이라고 본다 | 함수가 한가하면 **지표가 발행되지 않는다** |
| 검색용 값을 `metadata`에 넣는다 | **색인되는 것은 `annotations`뿐**이다 |
| 주석을 추적당 무제한으로 붙인다 | **50개**까지다 |
| 추적이 없으면 호출이 없었다고 본다 | **샘플링(초당 1 + 5%)** 때문일 수 있다 |
| 로컬 샘플링 JSON으로 전체 비율을 통제한다고 본다 | 인스턴스마다 **독립 샘플링**된다 — 콘솔 규칙을 쓴다 |
| Logs Insights 문법으로 지표 필터 패턴을 쓴다 | ⚠️ **문법이 다르다**(필터 패턴 ≠ Insights QL) |
| PPL·SQL에서 `@message`를 그냥 쓴다 | **백틱으로 감싼다** |
| 로그 그룹 50개 제한을 모른 채 더 넣는다 | `StartQuery`는 **50개**까지다 |
| 콘솔을 닫으면 쿼리가 멈춘다고 본다 | ⚠️ **완료될 때까지 계속 실행된다** — 닫기 전에 취소한다 |
| 지표 필터가 과거 로그도 지표로 만든다고 본다 | **소급 적용되지 않는다** |
| `requestId`를 지표 필터 차원으로 쓴다 | 커스텀 지표가 폭증하고 **필터가 비활성화될 수 있다** |
| Lambda 로그의 JSON 조각이 전부 자동 검색된다고 본다 | **첫 조각만**이다 — 나머지는 `parse` |
| JSON 문자열 필드에 점 표기를 쓴다 | **`jsonParse`**로 맵으로 바꿔야 한다 |
| API Gateway 로그 수준을 "오류만"으로 두고 성공 요청을 찾는다 | **기록되지 않는다** — "오류와 정보"로 올린다 |
| 운영 API에 데이터 추적을 켠다 | ⚠️ **민감 데이터가 기록된다** — 권장되지 않는다 |
| `aiops` CLI로 조사를 시작하려 한다 | **조사 그룹·정책 전용**이다 |
| 경보에 조사 작업을 붙이면 바로 된다고 본다 | API로 만든 그룹은 **`PutInvestigationGroupPolicy`**가 필요하다 |

---

## 🧪 자가 점검

**Q1.** S3 이벤트로 비동기 호출되는 함수가 "가끔 아무 일도 하지 않는다"는 신고를 받았다. 어떤 순서로 확인하고, 재시도·보관 규칙은 무엇인가? (→ 1) 디버깅)

<details><summary>정답 보기</summary>

비동기 호출은 Lambda가 **이벤트를 큐에 넣고 `{"StatusCode": 202}`만** 돌려주므로 **호출자 쪽 응답에는 결과가 없습니다.** 확인 순서는 **지표 → 로그 → DLQ·대상**입니다.

재시도 규칙: **함수 오류는 2회 재시도**(0~2로 조정), **스로틀(429)·시스템 오류(5xx)는 큐에 최대 6시간**(이벤트 최대 수명 60초~6시간으로 조정), ⚠️ **예약 동시성이 0이면 재시도하지 않습니다.** 폐기분은 **DLQ**(SQS 큐·SNS 주제, 실행 역할에 쓰기 권한 필요)나 **대상**으로 보냅니다 — 대상은 성공·실패를 따로 지정하며 큐·주제·함수·이벤트 버스를 쓰고 ⚠️ **S3는 on-failure만** 됩니다.

DLQ·대상 자체가 실패하면 **`DeadLetterErrors`·`DestinationDeliveryFailures`**로 드러납니다(SQS FIFO·SNS FIFO 같은 **지원되지 않는 대상 유형**도 이 지표를 올립니다).
</details>

**Q2.** 큐를 읽는 함수의 처리량이 오르지 않는데 오류 지표는 0이다. 무엇을 보고, 어떤 대응이 있는가? (→ 1) 디버깅 · 2) 해석)

<details><summary>정답 보기</summary>

⚠️ **스로틀은 `Invocations`에도 `Errors`에도 세지 않습니다**(`TooManyRequestsException`). 그래서 **`Throttles`**와 **`ConcurrentExecutions`(`Max` 통계)**를 봐야 합니다 — 처리 시간이 긴 함수는 메시지가 처리보다 빨리 쌓이고 계정의 **미예약 동시성 상한**까지 확장한 뒤 스로틀이 걸립니다.

공식 대응 세 가지: **리전의 동시성 증가 요청 · 함수의 처리 속도 개선 · 배치 크기 증가.** 스트림 소스라면 **`IteratorAge`**(Kafka는 `OffsetLag`)가 밀림의 크기를 보여 줍니다. 스로틀 감지는 **`Throttles > 0` 경보**로 잡습니다.
</details>

**Q3.** 특정 고객 ID의 요청만 추적에서 찾아야 한다. 어디에 무엇을 기록하고, 제약은 무엇인가? (→ 2) 해석)

<details><summary>정답 보기</summary>

**`annotations`**에 키-값으로 기록합니다 — X-Ray가 **색인**하므로 필터 식의 **`annotation[key]`**로 검색할 수 있습니다. ⚠️ **`metadata`는 색인되지 않아** 같은 값을 넣어도 검색 조건이 되지 못합니다.

제약: **문자열·숫자·부울만**(객체·배열 불가) · **추적당 50개** · 키는 **영숫자(점·밑줄 허용) 최대 500자** · 값은 **최대 1,000 유니코드 문자** · ⚠️ **같은 키로 다시 기록하면 앞 값을 덮어씁니다.** 필터가 동작하려면 키에 공백·기호를 쓰지 않습니다.
</details>

**Q4.** 추적이 전체 요청의 일부만 보인다. 원인과, 인스턴스를 늘렸을 때 생기는 또 다른 문제는? (→ 2) 해석)

<details><summary>정답 보기</summary>

기본 샘플링이 **초당 첫 요청(저수지 1) + 추가 요청의 5%**이기 때문입니다. 더 보려면 **저수지 크기와 고정 비율**을 올립니다(규칙 옵션: 우선순위·고정 비율·저수지 크기 + 호스트·메서드·URL·서비스 이름·서비스 유형·리소스 ARN·**속성 최대 5개** 일치).

⚠️ **로컬 JSON 규칙을 쓰면 인스턴스마다 독립적으로 샘플링**합니다 — 여러 인스턴스의 저수지가 **합산되는 효과**로 전체 샘플 비율이 의도보다 올라가고, 규칙 변경에 **재배포**가 필요합니다. 콘솔(서비스) 규칙으로 옮기면 **서비스가 저수지를 관리하고 실행 중인 인스턴스 수에 맞춰 쿼터를 배분**합니다.
</details>

**Q5.** 로그 그룹 60개를 한 번에 조사하며 결과 5만 건을 받아야 한다. 가능한가? 비용을 줄이는 공식 권장은? (→ 3) 로그 쿼리)

<details><summary>정답 보기</summary>

⚠️ **한 쿼리의 로그 그룹은 최대 50개**이므로 60개는 나눠야 합니다. 결과 상한은 **`limit` 최대 100,000**이지만 ⚠️ **그것은 Logs Insights QL 전용**이고(PPL·SQL 미지원), **한 번의 `GetQueryResults`는 10,000건**이라 **`nextToken`으로 페이지네이션**해야 합니다.

비용 규율: **필요한 로그 그룹만 선택** · **가장 좁은 시간 범위** · ⚠️ **콘솔을 닫기 전에 쿼리 취소**(닫아도 완료까지 계속 실행됩니다) · **대시보드 위젯의 높은 새로 고침 빈도 피하기**(새로 고침마다 새 쿼리). 동시 실행 쿼터는 **QL 100개/계정(대시보드 포함)**, **PPL·SQL 15개**입니다.
</details>

**Q6.** "오류 로그가 나오면 경보를 받고 싶다." Logs Insights로 해결하는가? 선택한 도구의 제약 네 가지는? (→ 3) 로그 쿼리)

<details><summary>정답 보기</summary>

아닙니다 — 반복되는 감시는 **지표 필터**(또는 EMF)의 일입니다. 지표 필터는 로그가 수집될 때 패턴을 찾아 **CloudWatch 지표로 변환**하므로 그 지표에 **경보**를 걸 수 있습니다.

제약: ① **로그 그룹당 최대 100개** ② ⚠️ **소급 적용되지 않는다**(만든 뒤의 이벤트만) ③ ⚠️ **커스텀 지표로 과금**되고 `requestID`·`IPAddress` 같은 고카디널리티 차원은 값마다 지표를 만들어 **1시간에 1,000쌍**을 넘기면 **필터가 비활성화될 수 있다** ④ **Standard 로그 클래스 전용**이며 단위는 **나중에 바꿔도 반영되지 않는다**. 정규식 쿼터는 **필터 패턴당 2개·로그 그룹당 5개**이고, ⚠️ **필터 패턴 문법은 Logs Insights QL과 다릅니다.**
</details>

**Q7.** CodeDeploy 배포가 실패했고 콘솔은 훅 단계 실패만 알려 준다. 어디를 읽는가? CloudFormation 스택 생성이 중간에 실패했다면? (→ 4) 배포 실패 로그)

<details><summary>정답 보기</summary>

**인스턴스의 로그 세 개**를 읽습니다 — 배포 로그(`/opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log`), 에이전트 로그(`/var/log/aws/codedeploy-agent/codedeploy-agent.log`), 그리고 ⭐ **훅 스크립트의 `stdout`·`stderr`가 담기는 `scripts.log`**(`/opt/codedeploy-agent/deployment-root/<배포 그룹 ID>/<배포 ID>/logs/scripts.log`)입니다. 에이전트 로그는 **매일 또는 64 MB에서 회전하고 7일 뒤 정리**됩니다.

CloudFormation은 **독립적인 프로비저닝 경로마다 첫 실패에서 멈춥니다.** **"성공적으로 프로비저닝된 리소스 보존"**을 켜면 처음부터 다시 만들지 않고 **`CREATE_FAILED`·`UPDATE_FAILED` 리소스만 고쳐 이어서** 진행할 수 있습니다 — 업데이트·변경 세트에서는 실패분이 **마지막 안정 상태로 롤백**되고 ⚠️ **안정 상태가 없는 리소스는 다음 작업에서 삭제**됩니다.
</details>

**Q8.** 기술 4.1.5를 어떻게 공부하는가? CloudWatch investigations에서 API로 할 수 있는 일과 할 수 없는 일은? (→ 5) AI 조사)

<details><summary>정답 보기</summary>

**CloudWatch investigations**는 텔레메트리를 훑어 **지표 · 로그 · 배포 이벤트 · 근본 원인 가설**을 제안하는 생성형 AI 보조 기능입니다.

⚠️ **API·CLI(`aiops`)로는 조사 그룹과 그룹 정책의 생성·관리·삭제만** 할 수 있고 **조사의 시작·관리는 CloudWatch 콘솔에서만** 합니다. 조사 그룹은 **1회성 설정**으로 접근 권한·**교차 계정 조사**·KMS 암호화·보존 기간을 관리하며(사용자 가이드는 **계정에 하나**, API 참조는 **리전마다 하나**로 적습니다), 설정에는 **`AIOpsConsoleAdminPolicy`** 또는 **`AdministratorAccess`**가 필요합니다. ⚠️ **경보가 조사를 시작하게 하려면** API로 만든 그룹에 **`PutInvestigationGroupPolicy`**로 권한을 줘야 하고, 기능은 **교차 리전 추론**을 사용합니다.

⚠️ **기술 문구가 서비스를 지목하지 않으므로** "그 AI 서비스는 무엇인가" 식의 단일 정답보다 **확인된 사실**(콘솔 전용 동작·`aiops`의 범위·필요한 IAM 정책)을 기준으로 공부합니다.
</details>

---

### 📌 출처

1. Types of metrics for Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html
2. Invoking a Lambda Event Function asynchronously — https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html
3. What is AWS Lambda? (Event Functions·Web Functions·MicroVMs 용어) — https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
4. Troubleshoot event source mapping issues in Lambda — https://docs.aws.amazon.com/lambda/latest/dg/troubleshooting-event-source-mapping.html
5. Analyzing log data with CloudWatch Logs Insights — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
6. CloudWatch Logs Insights language query syntax — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html
7. Supported logs and discovered fields — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_AnalyzeLogData-discoverable-fields.html
8. StartQuery (CloudWatch Logs API) — https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html
9. Creating metrics from log events using filters — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html
10. PutMetricFilter (CloudWatch Logs API) — https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_PutMetricFilter.html
11. Filter pattern syntax for metric filters, subscription filters, filter log events, and Live Tail — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html
12. AWS X-Ray segment documents — https://docs.aws.amazon.com/xray/latest/devguide/xray-api-segmentdocuments.html
13. Add annotations and metadata to segments with the X-Ray SDK for Java — https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-java-segment.html
14. Configuring sampling rules (X-Ray) — https://docs.aws.amazon.com/xray/latest/devguide/xray-console-sampling.html
15. SamplingRuleUpdate (X-Ray API) — https://docs.aws.amazon.com/xray/latest/api/API_SamplingRuleUpdate.html
16. Execution logging for REST APIs (API Gateway) — https://docs.aws.amazon.com/apigateway/latest/developerguide/rest-api-execution-logging.html
17. View log data for CodeDeploy EC2/On-Premises deployments — https://docs.aws.amazon.com/codedeploy/latest/userguide/deployments-view-logs.html
18. Choose how to handle failures when provisioning resources (CloudFormation) — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stack-failure-options.html
19. Set up an investigation group (CloudWatch investigations) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Investigations-GetStarted-Group.html
20. CreateInvestigationGroup (CloudWatch investigations API) — https://docs.aws.amazon.com/cloudwatchinvestigations/latest/APIReference/API_CreateInvestigationGroup.html
21. aiops (AWS CLI 명령 참조) — https://docs.aws.amazon.com/cli/latest/reference/aiops/index.html
22. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
23. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
