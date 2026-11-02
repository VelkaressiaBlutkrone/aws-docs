---
examGuideTaskId: dva-t4-2
certCode: DVA-C03
domain: 4
domainName: 문제 해결 및 최적화
domainWeightPct: 22
title: 로깅·모니터링·관찰성 모범 사례 (구조화 로깅·사용자 지정 지표·알림·추적·워크로드 상태)
coversTasks:
  - "4.2"
sources:
  - title: Configuring JSON and plain text log formats (Lambda)
    url: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs-logformat.html
  - title: LoggingConfig (Lambda API)
    url: https://docs.aws.amazon.com/lambda/latest/api/API_LoggingConfig.html
  - title: Publish custom metrics (PutMetricData / EMF)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html
  - title: Embedding metrics within logs
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format.html
  - title: Specification - Embedded metric format
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html
  - title: CloudWatch usage metrics
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Usage-Metrics.html
  - title: Visualizing your service quotas and setting alarms
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Quotas-Visualize-Alarms.html
  - title: Monitoring deployments with Amazon SNS event notifications (CodeDeploy)
    url: https://docs.aws.amazon.com/codedeploy/latest/userguide/monitoring-sns-event-notifications.html
  - title: Visualize Lambda Event Function invocations using AWS X-Ray
    url: https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html
  - title: Health checks for Application Load Balancer target groups
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
  - title: Amazon ECS task definition parameters
    url: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  - title: Configure probes and load balancer health checks (AWS Prescriptive Guidance)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/ha-resiliency-amazon-eks-apps/probes-checks.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
lastVerified: 2026-11-02
---

# 로깅·모니터링·관찰성 모범 사례 (구조화 로깅·사용자 지정 지표·알림·추적·워크로드 상태)

> **커버하는 공식 Task** — DVA-C03 · 도메인 4 「문제 해결 및 최적화」(22%) · **작업 4.2 로깅, 모니터링, 관찰성 모범 사례를 적용합니다** (`dva-t4-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 다섯 개(4.2.1~4.2.5)를 모두 덮습니다.

> ⚠️ **C02의 8개 기술이 C03에서 5개로 묶였습니다.** 그래서 기술 하나가 담는 범위가 넓어졌고, 특히 **4.2.5**가 "애플리케이션 상태 확인"과 **"활성(liveness)·준비 상태(readiness) 검사"**를 함께 요구합니다 — 로드 밸런서 헬스 체크와 **Kubernetes 프로브**를 같은 기술에서 묻습니다.

> ⭐ **`dva-t4-1`과의 경계**: t4-1은 **이미 난 일을 추적하는 쪽**(해석·쿼리·실패 로그)이고, 이 문서는 **그 신호를 애초에 남기는 쪽**(무엇을 어떤 형식으로 내보낼지)입니다. 4.1.5의 AI 조사가 쓸 재료를 만드는 것이 바로 이 작업입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Lambda의 **로그 형식·로그 수준·로그 그룹** 설정을 구분한다
- [ ] 구조화 로깅에서 **이중 인코딩 함정**을 피한다
- [ ] 사용자 지정 지표의 **세 경로**(API·EMF·지표 필터)를 골라 쓴다
- [ ] `PutMetricData`의 **한도와 해상도**를 안다
- [ ] 쿼터 알림을 **`AWS/Usage` + `SERVICE_QUOTA()`**로 만든다
- [ ] 배포 완료 알림을 **CodeDeploy 트리거**로 구성한다
- [ ] Lambda **활성 추적**의 모드·권한을 설명한다
- [ ] ALB 헬스 체크와 **프로브 3종**을 용도로 가른다

---

## 🎯 왜 중요한가

관찰성 문항은 "**무엇을 켜는가**"보다 **"그 설정이 무엇을 바꾸는가"**를 묻습니다. 로그 형식을 JSON으로 바꾸면 **로그 수준 필터가 쓸 수 있게** 되고, EMF로 지표를 내보내면 **`cloudwatch:PutMetricData` 권한이 필요하지 않게** 되며, 준비 상태 프로브를 외부 데이터베이스에 걸면 **장애가 전파**됩니다.

그리고 이 작업의 수치들은 **비용과 직결**됩니다 — 고해상도 지표와 고해상도 경보는 더 비싸고, 고카디널리티 차원은 커스텀 지표를 폭증시키며, 관찰성 설계를 잘못하면 장애보다 청구서가 먼저 터집니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **Lambda 로그 설정은 넷**입니다 — **`LogFormat`**(`JSON`·`Text`) · **`ApplicationLogLevel`**(`TRACE`~`FATAL`) · **`SystemLogLevel`**(`DEBUG`·`INFO`·`WARN`) · **`LogGroup`**(기본 **`/aws/lambda/<함수 이름>`**)
- **선택한 수준과 그보다 낮은 수준만** 보냅니다(애플리케이션 로그는 `TRACE`가 가장 높고 `FATAL`이 가장 낮습니다). ⚠️ **Managed Instances는 JSON만** 지원합니다
- ⚠️ **이중 인코딩은 런타임마다 다릅니다** — Java는 "이미 JSON인 로그를 이중 인코딩하지 않는다"고 적고, .NET은 "다른 라이브러리로 JSON을 만들면 **로그 형식을 평문으로** 두라"고 적습니다
- **`PutMetricData`**: 요청 **1 MB** · 요청당 지표 **1,000개** · `Values`·`Counts`로 **값 150개** · **차원 30개** · 타임스탬프 **2주 과거 ~ 2시간 미래**
- **고해상도 지표는 1초**(표준은 1분)이고 고해상도 **경보는 10초·30초**입니다 — 둘 다 **추가 요금**이 붙습니다
- **EMF**는 `_aws` 루트의 **`CloudWatchMetrics`**로 로그에서 지표를 만듭니다. ⭐ **`logs:PutLogEvents`만 있으면 되고 `cloudwatch:PutMetricData`는 필요하지 않습니다**. ⚠️ **최소 1회 전달**이라 **중복 값이 생길 수 있습니다**
- **쿼터 알림**: **`AWS/Usage`** 네임스페이스(**1분마다**, `CallCount`·`ResourceCount`·`ThrottleCount`)에 수학 함수 **`SERVICE_QUOTA(m1)`**을 더해 **사용률 백분율**로 경보를 겁니다. ⚠️ **모든 서비스가 사용률 지표를 내보내지는 않습니다**
- **배포 완료 알림**: CodeDeploy **트리거**로 SNS에 보냅니다 — **배포 그룹당 최대 10개**, 배포 이벤트는 Success·Failure·Started·Stopped·Rollback·**Ready**(⚠️ 블루/그린 전용)
- **Lambda 추적**: 기본 **`PassThrough`는 세그먼트를 기록하지 않습니다.** **`Active`**만 기록하고 그것도 **샘플된 호출만**이며, 실행 역할에 **`xray:PutTraceSegments`·`xray:PutTelemetryRecords`**(`AWSXRayDaemonWriteAccess`)가 필요합니다
- **ALB 헬스 체크 기본값**: 간격 **30초**(`lambda` 대상은 35초) · 타임아웃 **5초**(`lambda`는 30초) · **정상 임계값 5 · 비정상 임계값 2** · 성공 코드 **200**. **ECS 컨테이너 헬스 체크**는 간격 **30초** · 타임아웃 **5초** · 재시도 **3회** · `startPeriod` **기본 꺼짐**

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **시스템 로그** | Lambda **서비스가** 만드는 로그(`START`·`REPORT` 같은 플랫폼 이벤트 로그) |
| **애플리케이션 로그** | **함수 코드가** 만드는 로그 |
| **EMF(embedded metric format)** | 로그 이벤트 안에 지표를 심어 **CloudWatch가 비동기로 추출**하게 하는 형식 |
| **고해상도 지표** | **1초** 단위로 저장되는 커스텀 지표(표준은 1분) |
| **사용률 지표(usage metrics)** | 서비스 쿼터에 대응하는 `AWS/Usage` 네임스페이스의 지표 |
| **`SERVICE_QUOTA()`** | 그래프·경보에 **현재 쿼터 값**을 선으로 더해 주는 지표 수학 함수 |
| **트리거(CodeDeploy)** | 배포·인스턴스 이벤트를 **SNS 주제로** 보내는 배포 그룹 설정 |
| **활성 추적(active tracing)** | 서비스가 **직접 세그먼트를 기록**하도록 켜는 추적 모드 |
| **프로브(probe)** | Kubernetes가 컨테이너 상태를 주기적으로 확인하는 검사(startup·liveness·readiness) |

---

## 📖 핵심 개념

### 1) 효과적인 로깅 전략 — 구조화 로깅 (기술 4.2.1) {#structured-logging}

공식 문구는 "효과적인 로깅 전략을 구현하여 애플리케이션 동작 및 상태를 기록합니다(예: **애플리케이션 이벤트 및 사용자 작업에 대한 구조화된 로깅 사용**)"입니다.

**Lambda는 로깅을 코드 변경 없이 네 가지로 제어합니다**

| 설정(`LoggingConfig`) | 값 | 메모 |
|---|---|---|
| **`LogFormat`** | **`JSON`** · **`Text`** | 애플리케이션·시스템 로그에 **함께** 적용된다 |
| **`ApplicationLogLevel`** | `TRACE` · `DEBUG` · `INFO` · `WARN` · `ERROR` · `FATAL` | ⚠️ **`TRACE`가 가장 높은 상세 수준, `FATAL`이 가장 낮다.** 선택한 수준과 **그보다 낮은** 로그만 전송된다 |
| **`SystemLogLevel`** | `DEBUG` · `INFO` · `WARN` | 범위가 셋뿐이다(`DEBUG`가 가장 높고 `WARN`이 가장 낮다) |
| **`LogGroup`** | 로그 그룹 이름(1~512자) | 기본값은 **`/aws/lambda/<함수 이름>`**. 애플리케이션 단위로 모으면 보존·보안 정책을 한곳에 적용할 수 있다 |

- **모든 관리형 런타임에서 시스템 로그**는 평문 또는 JSON으로 고를 수 있고, **지원 런타임에서 내장 로깅 방법**(Python의 `logging`, Node.js의 `console`, Java의 `LambdaLogger`·Log4j 등)을 쓰면 **애플리케이션 로그도** 구조화 JSON으로 나옵니다 — **코드를 바꾸지 않아도** 됩니다.
- ⚠️ **Lambda Managed Instances는 JSON 로그 형식만 지원합니다** — 함수를 만들 때 자동으로 JSON으로 설정되고 **평문으로 바꿀 수 없습니다.**
- JSON 레코드에는 런타임별로 최소 키가 들어갑니다 — Java는 **`timestamp`·`level`·`message`·`AWSrequestId`**, .NET은 **`timestamp`·`level`·`requestId`·`traceId`·`message`**입니다. ⭐ **수준을 지정하지 않은 로그는 `INFO`**가 됩니다.
- ⚠️ **JSON 로깅은 메타데이터를 덧붙이므로 로그 메시지 크기가 커집니다** — 수집량이 곧 비용이라는 점을 함께 봅니다.

**이중 인코딩 함정은 런타임마다 서술이 다릅니다**

- **Java**: 코드가 이미 다른 라이브러리로 JSON 구조화 로그를 만들고 있으면 **바꿀 것이 없습니다** — Lambda는 **이미 JSON으로 인코딩된 로그를 이중 인코딩하지 않고**, JSON 형식으로 설정해도 **직접 정의한 구조**가 그대로 보입니다.
- **.NET**: 다른 로깅 라이브러리로 JSON을 만든다면 ⚠️ **함수의 로그 형식을 평문으로 둬야** 합니다 — JSON으로 설정하면 **이중 인코딩**됩니다. 그리고 평문일 때는 로그 수준이 Microsoft 관례의 **네 글자 라벨**(예: `Debug` → `dbug`)로 찍히지만 JSON에서는 **전체 라벨**로 나옵니다.
- ⭐ 그래서 "구조화 로깅을 켠다"는 결정은 **런타임과 기존 로깅 라이브러리를 함께** 봐야 합니다. AWS Compute 블로그는 **JSON으로 바꾸는 것이 로그 파싱 파이프라인에는 파괴적 변경일 수 있다**고 적고, **로그 수준 제어는 로그 형식이 JSON일 때만** 쓸 수 있다고 설명합니다(블로그 근거).

**구조화 로깅이 뒤쪽 기술을 열어 줍니다**

- 로그가 JSON이면 Logs Insights에서 **점 표기**로 필드를 바로 읽고(`userIdentity.type`), **지표 필터**로 숫자를 뽑고, **EMF**로 지표를 내보낼 수 있습니다. 즉 4.2.1은 4.2.2·4.1.3의 **전제**입니다.
- 반대로 평문 로그는 **`parse`로 매번 깎아 써야** 하고, 파싱 규칙이 포맷 변경에 깨집니다.

> 🧠 **원리** — 구조화 로깅의 값은 "보기 좋다"가 아니라 **"기계가 필드로 읽을 수 있다"**입니다. 필드가 되는 순간 **쿼리·지표·경보·AI 조사**가 모두 같은 로그 하나에서 나오므로, 로깅 전략은 **나중에 묻고 싶은 질문의 목록**을 먼저 정하는 일이 됩니다.

### 2) 사용자 지정 지표를 내보내는 코드 (기술 4.2.2) {#custom-metrics}

**경로가 셋이고 고르는 기준이 다릅니다.**

| 경로 | 어떻게 | 언제 |
|---|---|---|
| **`PutMetricData` API** | 코드가 CloudWatch에 **직접 호출** | 값이 적고 즉시 반영이 필요할 때 |
| **EMF** | **로그에 지표를 심어** 보내고 CloudWatch가 추출 | ⭐ **수명이 짧은 리소스**(Lambda·컨테이너) · 지표와 **원문 로그를 함께** 남기고 싶을 때 |
| **지표 필터** | 이미 들어오는 로그에서 **패턴으로 추출** | 코드를 못 바꿀 때 · 기존 로그를 지표화할 때(⚠️ 소급 불가) |

**`PutMetricData`의 한도**

- 요청은 **1 MB**(HTTP POST)이고 **gzip 압축**을 쓸 수 있습니다. 한 요청에 **서로 다른 지표 1,000개**까지 담습니다.
- 값은 `Value`로 하나씩, 또는 **`Values`·`Counts`**로 **한 요청에 150개**까지 보냅니다 — ⭐ 후자는 **백분위 통계**를 쓸 수 있게 합니다.
- **차원은 지표당 최대 30개**(이름-값 쌍)입니다.
- 타임스탬프는 **최대 2주 과거부터 2시간 미래까지** 지정할 수 있습니다. ⚠️ **없는 지표는 호출로 생성**되지만 `ListMetrics`에 나타나기까지 **최대 15분**, **24시간 이상 과거** 타임스탬프의 데이터는 조회에 **최소 48시간**이 걸립니다.
- 해상도: **표준 1분 / 고해상도 1초**. 고해상도 지표는 **1·5·10·30초 또는 60의 배수** 주기로 읽고, **고해상도 경보는 10초·30초**(그 밖은 60의 배수)입니다. ⚠️ **`PutMetricData` 호출마다 과금**되므로 고해상도는 호출 빈도가 곧 비용입니다.

**EMF의 구조와 이점**

```json
{
  "_aws": {
    "Timestamp": 1725618677000,
    "CloudWatchMetrics": [
      {
        "Namespace": "custom-metric",
        "Dimensions": [["dimensionValue"]],
        "Metrics": [{ "Name": "time", "Unit": "Milliseconds", "StorageResolution": 60 }]
      }
    ]
  },
  "dimensionValue": "value",
  "time": 100
}
```

- **설정이 필요 없습니다** — 위 구조로 로그를 쓰거나 클라이언트 라이브러리로 만들어 **`PutLogEvents`**나 CloudWatch 에이전트로 보내면 됩니다.
- ⭐ **권한이 다릅니다**: EMF로 지표를 만들 때는 **`logs:PutLogEvents`만** 있으면 되고 **`cloudwatch:PutMetricData`는 필요하지 않습니다.**
- **크기 한도는 표준 로그 이벤트와 같은 1 MB**입니다.
- 추출된 지표에 **경보**를 걸 수 있고, 같은 로그 이벤트를 **Logs Insights로 조사**할 수 있습니다 — 지표와 맥락이 한 곳에 남는 것이 EMF의 핵심 이점입니다.
- ⚠️ **최소 1회 전달**이 보장되는 대신 **중복 값이 간헐적으로 생길 수 있습니다.** 정확히 한 번이 필요한 회계용 집계에는 맞지 않습니다.
- ⚠️ **고카디널리티 차원**(예: `requestId`)을 쓰면 **차원 조합마다 커스텀 지표**가 만들어져 비용이 폭증합니다 — 설계상 그렇게 동작합니다.
- EMF 처리 실패는 계정의 **`AWS/Logs` 네임스페이스 지표**로 추적합니다 — **파싱 실패와 검증 실패**를 구분해 볼 수 있습니다.

> 🧠 **원리** — 세 경로의 차이는 **"지표를 어디서 만드는가"**입니다. API는 **애플리케이션이**, EMF는 **CloudWatch가 로그에서**, 지표 필터는 **CloudWatch가 수집 파이프라인에서** 만듭니다. 그래서 수명이 짧은 실행 환경에서는 **호출을 기다릴 필요 없는 EMF**가 유리하고, 코드를 바꿀 수 없을 때는 **지표 필터**만 남습니다.

### 3) 특정 작업에 대한 알림 경고 (기술 4.2.3) {#notifications}

공식 예시가 **"할당량 제한, 배포 완료"** 둘을 꼽습니다. 둘의 구현 경로가 완전히 다릅니다.

**① 할당량(쿼터) 한도 알림**

- 일부 서비스는 **서비스 쿼터에 대응하는 사용률 지표**를 내보냅니다 — **`AWS/Usage` 네임스페이스**, **1분마다 수집**, 지표는 **`CallCount`·`ResourceCount`·`ThrottleCount`**이고 차원은 **`Resource`·`Service`·`Type`**(+`Class`)입니다. `Resource`는 **추적되는 API 작업 이름**입니다.
- `CallCount`는 **단위가 없고 `SUM`이 가장 유용한 통계**입니다(1분 구간의 총 호출 수).
- ⭐ 경보는 지표 수학 **`SERVICE_QUOTA(m1)`**과 함께 만듭니다 — 그래프에 **현재 쿼터가 선으로** 추가되고, `m1 / SERVICE_QUOTA(m1) * 100` 같은 표현식으로 **사용률 백분율**에 임계값을 걸 수 있습니다.
- ⚠️ **모든 서비스가 사용률 지표를 Service Quotas와 통합하지는 않습니다.** 공식 목록에는 CloudHSM · Chime SDK · **CloudWatch** · **CloudWatch Logs** · **DynamoDB** · **EC2** · **ECR** · **Elastic Load Balancing** · **Fargate** · Fault Injection Service · IVS · **KMS** · Data Firehose · Location Service · AMB Query · **SageMaker AI** · Multi-party approval이 있습니다.
- 교차 계정 가시성을 켠 **모니터링 계정**에서는 연결된 소스 계정의 쿼터도 시각화하고 경보를 걸 수 있습니다.

**② 배포 완료 알림**

- **CodeDeploy 트리거**를 배포 그룹에 추가하면 배포·인스턴스 이벤트가 **SNS 주제**로 발행되고, 구독자가 **이메일·SMS** 등으로 받습니다. ⭐ 발행되는 **JSON 데이터**를 SQS 큐로 보내거나 **Lambda 함수를 호출**하는 데도 쓸 수 있습니다.
- **배포 그룹당 트리거는 최대 10개**입니다.

| 배포 이벤트 | 인스턴스 이벤트 |
|---|---|
| Success · Failure · Started · Stopped · Rollback · **Ready**¹ · 전체 배포 이벤트 | Success · Failure · Started · **Ready**¹ · 전체 인스턴스 이벤트 |

¹ ⚠️ **블루/그린 배포에만** 적용됩니다 — 대체 환경의 인스턴스에 최신 리비전이 설치되어 **로드 밸런서 뒤로 트래픽을 돌릴 수 있게 됐다**는 뜻입니다.

- ⚠️ **알림이 나가기 전에 CodeDeploy 서비스 역할에 SNS 권한을 줘야** 합니다(관리형 `AWSCodeDeployRole`을 쓰면 포함되어 있습니다). 트리거를 만들기 전에 **SNS 주제를 먼저** 만들어 둡니다.
- 주제 이름을 `Topic-group-us-west-3-deploy-fail`처럼 **목적이 드러나게** 짓는 것이 공식 권장입니다.

**③ 그 밖의 알림 경로**

- **CloudWatch 경보**는 상태 변화에 SNS 알림을 보냅니다 — 지표 필터·EMF로 만든 지표에도 그대로 걸립니다.
- ⭐ 경보에는 **조사 시작(investigations) 작업**도 붙일 수 있습니다(기술 4.1.5) — API로 만든 조사 그룹이라면 **`PutInvestigationGroupPolicy`**로 경보에 권한을 줘야 합니다.

> 🧠 **원리** — 알림은 **"상태가 바뀌었다"를 누가 아는가**로 갈립니다. 쿼터는 **CloudWatch가 사용량 지표로** 알고 있어 경보로 충분하고, 배포 완료는 **배포 서비스만** 아는 사실이라 그 서비스의 **이벤트 발행 기능**(트리거)이 필요합니다. 그래서 "배포가 끝나면 알려 달라"에 지표 경보로 답하면 어긋납니다.

### 4) AWS 서비스·도구로 추적 구현 (기술 4.2.4) {#tracing}

**Lambda의 추적 모드는 둘이고 기본값이 함정입니다**

- **`PassThrough`(기본)**는 ⚠️ **세그먼트를 기록하지 않습니다** — 업스트림이 내린 샘플링 결정만 전달합니다.
- **`Active`**만 **`AWS::Lambda`와 `AWS::Lambda::Function` 서비스 세그먼트**를 기록하고, 그것도 ⚠️ **샘플된 호출에 대해서만** 기록합니다.
- 켜는 방법: `aws lambda update-function-configuration --tracing-config Mode=Active` · CloudFormation **`TracingConfig.Mode: Active`** · SAM **`Tracing: Active`** · CDK **`Tracing.ACTIVE`**.
- **권한**: 실행 역할에 **`xray:PutTraceSegments`·`xray:PutTelemetryRecords`**가 필요하고, 관리형 정책 **`AWSXRayDaemonWriteAccess`**가 이 둘을 담고 있습니다. ⚠️ **콘솔에서 추적을 켜면 자동으로 붙지만, IaC로 만들 때는 직접 붙여야** 합니다(CDK의 `tracing: Tracing.ACTIVE`는 역할에 추가해 줍니다).

**서비스가 직접 지원하는 활성 추적**

- **API Gateway 스테이지** · **AWS AppSync** · **Step Functions 상태 머신**은 활성 추적과 샘플링 구성을 지원합니다.
- **EC2·ECS·Elastic Beanstalk** 같은 컴퓨팅에서는 애플리케이션을 **AWS Distro for OpenTelemetry(ADOT)** 또는 **X-Ray SDK**로 계측해야 샘플링이 적용됩니다.

**추적을 "쓸 수 있게" 만드는 것은 주석입니다**

- 검색해야 하는 값은 **`annotations`**에 넣습니다 — 색인되어 필터 식 **`annotation[key]`**로 찾을 수 있고 **추적당 50개**까지, 키는 **최대 500자 영숫자**, 값은 **최대 1,000 유니코드 문자**입니다.
- **`metadata`**는 색인되지 않아 **검색 조건이 되지 못합니다.** 자세한 내용은 `dva-t4-1`의 2절에 있습니다.
- 샘플링 규칙은 **콘솔(서비스) 규칙**으로 두는 쪽이 낫습니다 — 로컬 JSON 규칙은 **인스턴스마다 독립 샘플링**되어 전체 비율이 올라가고 변경에 재배포가 필요합니다.

> 🧠 **원리** — 추적은 **"모든 요청을 기록하는 일"이 아닙니다.** 샘플링이 전제이고, 기본값은 **초당 1건 + 5%**입니다. 그래서 추적으로 답할 수 있는 질문은 **"평소 이 구간이 느린가"**이고, **"특정 요청 하나가 왜 실패했는가"**는 주석을 심어 두거나 로그로 답해야 합니다.

### 5) 워크로드 상태 모니터링 (기술 4.2.5) {#health}

공식 예시가 **"애플리케이션 상태 확인, 활성 및 준비 상태 검사"**입니다. 세 층이 있고 **층마다 하는 일이 다릅니다.**

**① 로드 밸런서 헬스 체크 — "트래픽을 보낼 대상인가"**

| 설정 | 범위 | 기본값 |
|---|---|---|
| **`HealthCheckProtocol`** | ALB는 HTTP·HTTPS(**GET**으로 보낸다) | **HTTP** |
| **`HealthCheckPort`** | — | 대상이 **트래픽을 받는 포트** |
| **`HealthCheckPath`** | HTTP/1.1·HTTP/2는 URI | **`/`**(gRPC는 **`/AWS.ALB/healthcheck`**) |
| **`HealthCheckIntervalSeconds`** | 5~300초 | **30초**(⚠️ `lambda` 대상은 **35초**) |
| **`HealthCheckTimeoutSeconds`** | 2~120초 | **5초**(⚠️ `lambda` 대상은 **30초**) |
| **`HealthyThresholdCount`** | 2~10 | **5** |
| **`UnhealthyThresholdCount`** | 2~10 | **2** |
| **`Matcher`**(성공 코드) | HTTP는 200~499 | **200**(gRPC는 0~99, 기본 **12**) |

- 요청은 **간격마다 독립적으로** 보내고 **결과가 그 간격 전체에 유효**합니다 — 대상의 응답 시간이 다음 요청 간격을 **밀지 않습니다.**
- **비정상 임계값만큼 연속 실패**하면 대상을 빼고, **정상 임계값만큼 연속 성공**하면 되돌립니다. 대상은 **초기 헬스 체크를 통과한 뒤에야** `healthy`가 됩니다.
- 상태 값은 **`initial`·`healthy`·`unhealthy`·`unused`·`draining`·`unavailable`** 여섯 가지이고 이유 코드가 원인을 알려 줍니다 — **`Target.ResponseCodeMismatch`**(코드 불일치) · **`Target.Timeout`** · **`Target.FailedHealthChecks`** · `Target.NotRegistered` · `Target.DeregistrationInProgress` · **`Target.HealthCheckDisabled`**.
- ⚠️ **대상을 등록 해제하면 `HealthyHostCount`는 줄지만 `UnhealthyHostCount`는 늘지 않습니다** — 두 지표의 합으로 전체를 계산하면 틀립니다.

**② ECS 컨테이너 헬스 체크 — "컨테이너 안 프로세스가 정상인가"**

| 파라미터 | 값 | 기본값 |
|---|---|---|
| **`command`** | `CMD`(인수 직접 실행) 또는 **`CMD-SHELL`**(컨테이너 기본 셸). 예: `[ "CMD-SHELL", "curl -f http://localhost/ || exit 1" ]` | 둘 다 없으면 **`CMD`** |
| **`interval`** | 5~300초 | **30초** |
| **`timeout`** | 2~60초 | **5초** |
| **`retries`** | 1~10 | **3회** |
| **`startPeriod`** | 0~300초 | ⚠️ **기본 꺼짐** |

- ⭐ **종료 코드 0이고 `stderr` 출력이 없으면 성공**, 0이 아니면 실패입니다.
- **`startPeriod`**는 부트스트랩 유예 시간이고, ⚠️ **그 안에 한 번 성공하면 컨테이너는 정상으로 간주되어 이후 실패만 재시도 횟수에 셉니다.**
- 콘솔에서 등록할 때는 **콤마로 구분한 목록**, JSON·CLI·API에서는 **대괄호로 감싼 배열**을 씁니다.

**③ Kubernetes 프로브 — "컨테이너를 죽일지, 트래픽을 뺄지"**

| 프로브 | 목적 | 핵심 규율 |
|---|---|---|
| **startup** | **초기화가 긴** 애플리케이션 보호 | ⭐ **성공할 때까지 다른 프로브가 비활성**된다. 최대 대기 시간을 넘기면 애플리케이션이 종료되고 새 파드가 생성된다. 기동 시간이 **예측 가능하면**(예: 10초) startup 대신 **`initialDelaySeconds`**를 쓴다 |
| **liveness** | 프로세스가 **살아 있는지**(교착 감지 — 프로세스는 돌지만 응답하지 않는 상태) | `initialDelaySeconds`로 첫 검사를 늦추고, ⚠️ **파드 외부 요소(예: 데이터베이스)에 의존시키지 않는다**. `terminationGracePeriodSeconds`를 함께 맞춘다 |
| **readiness** | **트래픽을 받을 준비**가 됐는지 · **부분 가용성** | ⚠️ **외부 연결에 의존하면 모든 파드가 동시에 실패**해 백엔드에서 다른 서비스로 **연쇄 장애**가 번진다 |

- ⚠️ **liveness와 readiness를 같은 설정으로 두지 않습니다**(최소한 타임아웃은 다르게). 일시적 문제라면 readiness가 **준비 안 됨으로만** 표시해 회복을 기다려야 하는데, liveness 설정이 틀리면 **파드를 종료**시킵니다.
- 로드 밸런서·ingress 헬스 체크는 프로브와 **함께** 씁니다. 처방적 지침은 ⚠️ **ingress의 등록 해제 지연(ALB 기본 300초)**을 염두에 두고 **readiness 프로브와 같은 값으로** 맞추라고 권합니다.
- 프로브는 **파드 컨텍스트의 명령**으로도, **kubelet·호스트 IP에 대한 HTTP·TCP 검사**로도 실행할 수 있습니다.

> 🧠 **원리** — 세 층은 **"무엇을 할 수 있는가"**가 다릅니다. 로드 밸런서는 **트래픽만 돌릴 수** 있고, 오케스트레이터(ECS·Kubernetes)는 **컨테이너를 교체할 수** 있습니다. 그래서 "회복 가능한 일시 장애"는 **트래픽을 빼는 쪽**(readiness·로드 밸런서)에, "회복 불가능한 상태"는 **교체하는 쪽**(liveness·ECS 헬스 체크)에 연결해야 합니다. 이 대응을 뒤집으면 멈춰도 될 일에 재시작 폭풍이 일거나, 죽은 프로세스에 계속 트래픽이 갑니다.

---

## ✍️ 시험 포인트

- **"코드를 바꾸지 않고 DEBUG 로그를 끊고 싶다"** → **`ApplicationLogLevel`**을 올립니다(로그 형식이 **JSON**이어야 합니다).
- **"여러 함수의 로그를 한 그룹에 모으고 싶다"** → **`LogGroup`**을 지정합니다(기본은 `/aws/lambda/<함수 이름>`).
- **".NET에서 JSON 로그가 문자열로 두 번 감싸졌다"** → 라이브러리가 이미 JSON을 만드는데 형식을 JSON으로 뒀기 때문입니다 → **평문으로** 둡니다.
- **"Managed Instances에서 평문 로그로 바꾸려는데 안 된다"** → ⚠️ **JSON만 지원**합니다.
- **"지표를 1초 단위로 보고 싶다"** → **고해상도 지표**(경보는 **10초·30초**), 추가 요금을 함께 봅니다.
- **"컨테이너 작업이 끝나기 전에 지표를 남겨야 한다"** → **EMF**. 권한은 **`logs:PutLogEvents`**만 필요합니다.
- **"지표 값이 간헐적으로 중복된다"** → EMF는 **최소 1회 전달**입니다.
- **"한 요청에 값 여러 개와 백분위"** → **`Values`·`Counts`**(요청당 **150개**).
- **"쿼터의 80%에서 알림"** → **`AWS/Usage` + `SERVICE_QUOTA()`** 수학 표현식 경보.
- **"그 서비스의 사용률 지표가 안 보인다"** → ⚠️ **통합된 서비스 목록에 있는 것만** 내보냅니다.
- **"배포가 끝나면 Slack·이메일로"** → **CodeDeploy 트리거 → SNS**(배포 그룹당 **10개**). JSON을 **Lambda·SQS**로 받아 가공할 수도 있습니다.
- **"블루/그린에서 트래픽 전환 직전에 알림"** → 이벤트 **`Ready`**(⚠️ 블루/그린 전용).
- **"알림이 아예 안 온다"** → CodeDeploy **서비스 역할의 SNS 권한**을 확인합니다.
- **"Lambda 추적을 켰는데 세그먼트가 없다"** → 모드가 **`PassThrough`**이거나 **샘플되지 않은 호출**입니다.
- **"IaC로 만든 함수에 추적만 켰는데 데이터가 없다"** → **`AWSXRayDaemonWriteAccess`**를 직접 붙여야 합니다.
- **"`lambda` 대상 그룹의 헬스 체크가 느리다"** → 기본 간격 **35초**·타임아웃 **30초**입니다.
- **"대상이 정상으로 돌아오는 데 오래 걸린다"** → **정상 임계값 기본 5회** × 간격입니다.
- **"초기화가 오래 걸리는 파드가 계속 재시작된다"** → **startup 프로브**(또는 `initialDelaySeconds`)를 씁니다.
- **"DB가 느려지자 모든 파드가 한꺼번에 빠졌다"** → ⚠️ **readiness 프로브를 외부 의존에 걸었기** 때문입니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| `ApplicationLogLevel`에서 `TRACE`가 가장 낮은 수준이라고 본다 | ⚠️ **`TRACE`가 가장 높고 `FATAL`이 가장 낮다** |
| 로그 수준 필터가 평문 형식에서도 된다고 본다 | **JSON 형식**이 전제다(블로그 근거) |
| 로그 형식 설정이 시스템 로그에만 적용된다고 본다 | 지원 런타임에서는 **애플리케이션 로그에도** 적용된다 |
| 이미 JSON을 만드는 .NET 코드에 JSON 형식을 켠다 | **이중 인코딩**된다 — 평문으로 둔다 |
| Managed Instances에서 평문 로그를 고르려 한다 | **JSON만** 지원한다 |
| JSON 로깅이 로그량을 줄여 준다고 본다 | **메타데이터가 붙어 커진다** |
| `PutMetricData` 요청에 지표를 무제한 담는다 | **1 MB · 1,000개 지표**가 한도다 |
| 차원을 지표당 수십 개 붙인다 | **최대 30개**다 |
| 한 달 전 데이터를 백필한다 | 타임스탬프는 **최대 2주 과거**까지다 |
| 새 지표가 바로 목록에 보일 것이라고 본다 | `ListMetrics`에 **최대 15분** 걸린다 |
| EMF에 `cloudwatch:PutMetricData` 권한을 준다 | **`logs:PutLogEvents`만** 필요하다 |
| EMF를 정확히 한 번 전달로 본다 | ⚠️ **최소 1회**다(중복 가능) |
| EMF 차원에 `requestId`를 쓴다 | **조합마다 커스텀 지표**가 생겨 비용이 폭증한다 |
| 모든 서비스가 `AWS/Usage` 지표를 낸다고 본다 | **통합된 서비스 목록**에 있는 것만이다 |
| 쿼터 경보를 절대값으로만 건다 | **`SERVICE_QUOTA()`**로 **백분율**을 쓴다 |
| 배포 완료를 지표 경보로 잡으려 한다 | **CodeDeploy 트리거(SNS)**가 그 사실을 아는 유일한 경로다 |
| 트리거를 배포 그룹에 무제한 붙인다 | **10개**까지다 |
| `Ready` 이벤트를 모든 배포에서 기대한다 | ⚠️ **블루/그린 전용**이다 |
| Lambda 추적 기본값이 기록한다고 본다 | **`PassThrough`는 기록하지 않는다** |
| 활성 추적이 모든 호출을 기록한다고 본다 | **샘플된 호출만**이다 |
| 콘솔과 IaC의 권한 처리가 같다고 본다 | 콘솔은 정책을 **자동 연결**, IaC는 **직접** 붙인다 |
| 검색할 값을 `metadata`에 넣는다 | 색인되는 것은 **`annotations`**다 |
| ALB 헬스 체크 기본값이 대상 유형과 무관하다고 본다 | `lambda`는 **간격 35초·타임아웃 30초**다 |
| `HealthyHostCount` + `UnhealthyHostCount`를 전체 수로 본다 | 등록 해제는 **전자만 줄인다** |
| ECS `startPeriod`가 기본으로 켜져 있다고 본다 | **기본 꺼짐**이다 |
| ECS 헬스 체크 성공을 종료 코드만으로 판단한다 | **종료 코드 0 + `stderr` 없음**이다 |
| liveness와 readiness를 같은 설정으로 둔다 | **다르게** 둔다 — 일시 장애에 파드가 죽는다 |
| readiness를 데이터베이스 연결에 건다 | **모든 파드가 동시 실패**해 연쇄 장애가 된다 |
| startup 프로브 없이 느린 초기화를 버틴다 | **startup 프로브**가 성공할 때까지 다른 프로브를 멈춘다 |

---

## 🧪 자가 점검

**Q1.** 운영 Lambda의 로그가 너무 많다. 코드를 바꾸지 않고 줄이려면 무엇을 설정하고, 전제 조건과 수준의 방향은 어떻게 되는가? (→ 1) 구조화 로깅)

<details><summary>정답 보기</summary>

**`LoggingConfig`의 `ApplicationLogLevel`**(함수 코드 로그)과 **`SystemLogLevel`**(서비스가 만드는 `START`·`REPORT` 류)을 올립니다. Lambda는 **선택한 수준과 그보다 낮은 수준만** 전송합니다.

⚠️ **방향을 거꾸로 외우기 쉽습니다** — 애플리케이션 로그는 **`TRACE`가 가장 높은 상세 수준이고 `FATAL`이 가장 낮습니다**(`TRACE`·`DEBUG`·`INFO`·`WARN`·`ERROR`·`FATAL`). 시스템 로그는 **`DEBUG`·`INFO`·`WARN`** 셋뿐입니다.

⚠️ 전제는 **로그 형식이 JSON**이라는 것입니다(AWS Compute 블로그 근거). 함께 쓸 수 있는 설정으로 **`LogFormat`**(`JSON`·`Text`)과 **`LogGroup`**(기본 `/aws/lambda/<함수 이름>`)이 있고, 로그 그룹을 애플리케이션 단위로 모으면 보존·보안 정책을 한곳에서 적용할 수 있습니다.
</details>

**Q2.** 수명이 짧은 컨테이너 작업에서 커스텀 지표를 남겨야 한다. 어떤 경로를 고르고, 권한과 전달 보장은 어떻게 되는가? (→ 2) 사용자 지정 지표)

<details><summary>정답 보기</summary>

**EMF(embedded metric format)**입니다. 로그 이벤트에 **`_aws` 루트 + `CloudWatchMetrics`**(Namespace·Dimensions·Metrics의 Name·Unit·StorageResolution)를 넣어 보내면 CloudWatch가 **비동기로 지표를 추출**하고, 같은 이벤트를 **Logs Insights로 조사**할 수 있습니다. 설정은 필요 없습니다.

⭐ **권한은 `logs:PutLogEvents`만** 필요하고 **`cloudwatch:PutMetricData`는 필요하지 않습니다.** 크기 한도는 표준 로그 이벤트와 같은 **1 MB**입니다.

⚠️ 전달 보장은 **최소 1회**라 **중복 값이 간헐적으로 생길 수 있습니다.** 그리고 ⚠️ `requestId` 같은 **고카디널리티 차원**을 쓰면 조합마다 커스텀 지표가 만들어져 비용이 폭증합니다. EMF 처리 실패(파싱·검증)는 **`AWS/Logs` 네임스페이스 지표**로 추적합니다.
</details>

**Q3.** `PutMetricData`로 1초 해상도 지표를 올리려 한다. 요청 한도와 경보 주기의 제약은? (→ 2) 사용자 지정 지표)

<details><summary>정답 보기</summary>

요청 한도: **1 MB**(HTTP POST, gzip 가능) · 요청당 **서로 다른 지표 1,000개** · **`Values`·`Counts`로 값 150개**(백분위 통계 지원) · **지표당 차원 30개** · 타임스탬프 **2주 과거 ~ 2시간 미래**.

해상도: 표준은 **1분**, 고해상도는 **1초**로 저장되고 **1·5·10·30초 또는 60의 배수** 주기로 읽습니다. 경보는 **고해상도 경보가 10초·30초**이고 그 밖에는 60의 배수 주기를 씁니다. ⚠️ **`PutMetricData` 호출마다 과금**되고 **10·30초 고해상도 경보에는 더 높은 요금**이 붙으므로, 해상도 결정은 비용 결정입니다.

참고로 ⚠️ 새로 만든 지표는 `ListMetrics`에 **최대 15분** 뒤 나타나고, **24시간 이상 과거** 타임스탬프의 데이터는 조회에 **최소 48시간**이 걸립니다.
</details>

**Q4.** "API 호출이 쿼터의 80%를 넘으면 알림"과 "배포가 끝나면 알림"을 각각 어떻게 구현하는가? (→ 3) 알림)

<details><summary>정답 보기</summary>

**쿼터**는 **`AWS/Usage` 네임스페이스**(1분마다 수집, `CallCount`·`ResourceCount`·`ThrottleCount`, 차원 `Service`·`Class`·`Type`·`Resource`)에 지표 수학 **`SERVICE_QUOTA(m1)`**을 더해 `m1 / SERVICE_QUOTA(m1) * 100` 같은 **사용률 백분율 표현식**으로 경보를 겁니다(`CallCount`는 **`SUM`** 통계가 유용합니다). ⚠️ **사용률 지표를 Service Quotas와 통합한 서비스만** 가능합니다(CloudWatch·CloudWatch Logs·DynamoDB·EC2·ECR·ELB·Fargate·KMS·Firehose·SageMaker AI 등).

**배포 완료**는 지표로 알 수 없습니다 — **CodeDeploy 트리거**를 배포 그룹에 추가해 **SNS 주제**로 발행합니다. **배포 그룹당 최대 10개**이고 이벤트는 배포(Success·Failure·Started·Stopped·Rollback·**Ready**·전체)와 인스턴스(Success·Failure·Started·Ready·전체)입니다. ⚠️ **`Ready`는 블루/그린 전용**이고, ⚠️ **CodeDeploy 서비스 역할에 SNS 권한**이 없으면 알림이 나가지 않습니다.
</details>

**Q5.** SAM으로 배포한 함수에서 X-Ray 추적을 켰는데 서비스 맵에 세그먼트가 없다. 확인할 것 세 가지는? (→ 4) 추적)

<details><summary>정답 보기</summary>

① **모드**: 기본 **`PassThrough`는 세그먼트를 기록하지 않습니다.** **`Active`**여야 하고(SAM은 `Tracing: Active`, CloudFormation은 `TracingConfig.Mode: Active`) 그래야 `AWS::Lambda`·`AWS::Lambda::Function` 서비스 세그먼트가 기록됩니다.

② **권한**: 실행 역할에 **`xray:PutTraceSegments`·`xray:PutTelemetryRecords`**가 있어야 하고 관리형 정책 **`AWSXRayDaemonWriteAccess`**가 그 둘을 담습니다. ⚠️ **콘솔에서 켜면 자동으로 붙지만 IaC에서는 직접 붙여야** 합니다.

③ **샘플링**: 활성 추적도 ⚠️ **샘플된 호출만** 기록합니다 — 기본은 **초당 1건 + 추가 요청의 5%**이므로 호출이 적으면 비어 보일 수 있습니다. 검색이 필요한 값은 **`annotations`**(색인됨, 추적당 50개)에 넣고 `metadata`에 넣지 않습니다.
</details>

**Q6.** ALB 뒤의 대상이 비정상으로 빠졌다가 돌아오는 데 오래 걸린다. 기본값으로 계산하면? 그리고 `lambda` 대상이면 무엇이 달라지는가? (→ 5) 워크로드 상태)

<details><summary>정답 보기</summary>

기본값은 **간격 30초 · 타임아웃 5초 · 비정상 임계값 2 · 정상 임계값 5**입니다. 따라서 **연속 2회 실패**(약 60초)에 빠지고, 돌아오려면 **연속 5회 성공**(약 150초)이 필요합니다. 성공 코드 기본값은 **200**이고(gRPC는 기본 **12**), 경로 기본값은 **`/`**(gRPC는 `/AWS.ALB/healthcheck`)입니다.

⚠️ **`lambda` 대상 유형은 기본값이 다릅니다** — **간격 35초 · 타임아웃 30초**입니다.

보조 사실: 헬스 체크 요청은 **간격마다 독립적**이고 결과가 그 간격 전체에 유효하므로 **대상의 응답 지연이 다음 요청을 밀지 않습니다.** 상태는 `initial`·`healthy`·`unhealthy`·`unused`·`draining`·`unavailable`이고 이유 코드로 **`Target.ResponseCodeMismatch`·`Target.Timeout`·`Target.FailedHealthChecks`** 등이 붙습니다. ⚠️ **등록 해제는 `HealthyHostCount`만 줄이고 `UnhealthyHostCount`를 늘리지 않습니다.**
</details>

**Q7.** EKS에서 초기화가 60초 걸리는 파드가 계속 재시작된다. 어떤 프로브를 쓰고, liveness·readiness 설계에서 피해야 할 것은? (→ 5) 워크로드 상태)

<details><summary>정답 보기</summary>

**startup 프로브**를 씁니다 — ⭐ **성공할 때까지 다른 프로브가 비활성**되고, 지정한 최대 시간을 넘겨도 실패하면 애플리케이션이 종료되고 새 파드가 생성됩니다. ⚠️ 기동 시간이 **예측 가능하다면**(예: 10초) startup 대신 **`initialDelaySeconds`**를 쓴 liveness·readiness가 낫습니다.

피해야 할 것: ⚠️ **liveness와 readiness를 같은 설정으로 두는 것**(일시적 문제에 파드가 종료됩니다 — readiness는 준비 안 됨으로 표시만 해야 합니다) · ⚠️ **liveness를 파드 외부 요소에 의존시키는 것** · ⚠️ **readiness를 데이터베이스 같은 외부 연결에 거는 것**(모든 파드가 동시에 실패해 **연쇄 장애**가 됩니다). 로드 밸런서 쪽은 **등록 해제 지연(ALB 기본 300초)**을 고려해 **readiness와 같은 값**으로 맞추라는 것이 처방적 지침의 권장입니다.
</details>

**Q8.** ECS 작업이 "오래 걸리는 부팅" 때문에 헬스 체크로 계속 교체된다. 어떤 파라미터를 쓰고 그 동작은? (→ 5) 워크로드 상태)

<details><summary>정답 보기</summary>

작업 정의 `healthCheck`의 **`startPeriod`**(0~300초, ⚠️ **기본 꺼짐**)를 지정합니다 — 부트스트랩 유예 시간이고 ⭐ **그 안에 한 번이라도 성공하면 컨테이너는 정상으로 간주되어, 이후 실패만 재시도 횟수에 셉니다.**

나머지 기본값: **`interval` 30초**(5~300) · **`timeout` 5초**(2~60) · **`retries` 3회**(1~10). 명령은 **`CMD`** 또는 **`CMD-SHELL`**로 시작하고(둘 다 없으면 `CMD`), 예시는 `[ "CMD-SHELL", "curl -f http://localhost/ || exit 1" ]`입니다. ⭐ 판정은 **종료 코드 0이고 `stderr` 출력이 없으면 성공**입니다. 콘솔 등록 시에는 **콤마 구분 목록**, JSON·CLI·API에서는 **대괄호 배열**을 씁니다.
</details>

---

### 📌 출처

1. Configuring JSON and plain text log formats (Lambda) — https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs-logformat.html
2. LoggingConfig (Lambda API) — https://docs.aws.amazon.com/lambda/latest/api/API_LoggingConfig.html
3. Log and monitor Java Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/java-logging.html
4. Log and monitor C# Lambda Event Functions — https://docs.aws.amazon.com/lambda/latest/dg/csharp-logging.html
5. Introducing advanced logging controls for AWS Lambda functions (AWS Compute 블로그 — JSON 전제·파이프라인 영향) — https://aws.amazon.com/blogs/compute/introducing-advanced-logging-controls-for-aws-lambda-functions/
6. Publish custom metrics (PutMetricData / EMF) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/publishingMetrics.html
7. Embedding metrics within logs — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format.html
8. Specification - Embedded metric format — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Embedded_Metric_Format_Specification.html
9. PutMetricData (CloudWatch API 동작·한도) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/API_PutMetricData.html
10. CloudWatch usage metrics — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Usage-Metrics.html
11. Visualizing your service quotas and setting alarms — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Quotas-Visualize-Alarms.html
12. Monitoring deployments with Amazon SNS event notifications (CodeDeploy) — https://docs.aws.amazon.com/codedeploy/latest/userguide/monitoring-sns-event-notifications.html
13. Create a trigger for a CodeDeploy event — https://docs.aws.amazon.com/codedeploy/latest/userguide/monitoring-sns-event-notifications-create-trigger.html
14. Visualize Lambda Event Function invocations using AWS X-Ray — https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html
15. Send application telemetry from AWS Lambda (CloudWatch) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/omni-send-application-telemetry-from-aws-lambda.html
16. Configuring sampling rules (X-Ray) — https://docs.aws.amazon.com/xray/latest/devguide/xray-console-sampling.html
17. Health checks for Application Load Balancer target groups — https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
18. Amazon ECS task definition parameters — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
19. Configure probes and load balancer health checks (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/ha-resiliency-amazon-eks-apps/probes-checks.html
20. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 4 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain4.html
21. DVA-C03 범위 내 AWS 서비스 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/dva-03-in-scope-services.html
