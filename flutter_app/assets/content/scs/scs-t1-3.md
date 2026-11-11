---
examGuideTaskId: scs-t1-3
certCode: SCS-C03
domain: 1
domainName: 탐지
domainWeightPct: 16
title: 모니터링·로깅·경보 문제 해결 (리소스 기능·권한·구성 분석과 잘못된 구성 교정)
coversTasks:
  - "1.3"
sources:
  - title: Sending Lambda Event Function logs to CloudWatch Logs
    url: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
  - title: Set up CloudWatch logging for REST APIs in API Gateway
    url: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html
  - title: Configure standard logging (v2) — Amazon CloudFront
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging.html
  - title: Configure standard logging (legacy) — Amazon CloudFront
    url: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging-legacy-s3.html
  - title: Troubleshooting the CloudWatch agent
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/troubleshooting-CloudWatch-Agent.html
  - title: Alarm evaluation (Amazon CloudWatch)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html
  - title: Configuring how CloudWatch alarms treat missing data
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
  - title: Health checks for your target groups — 경로·포트·간격·임계값
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html
  - title: Register targets with your target group — 보안 그룹 요건
    url: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-register-targets.html
lastVerified: 2026-11-08
---

# 모니터링·로깅·경보 문제 해결 (리소스 기능·권한·구성 분석과 잘못된 구성 교정)

> **커버하는 공식 Task** — SCS-C03 · 도메인 1 「탐지」(16%) · **작업 1.3 보안 모니터링, 로깅 및 경보 솔루션 문제 해결** (`scs-t1-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 2개(1.3.1~1.3.2)를 모두 덮습니다. 기술이 **둘뿐**이라 도메인 1에서 가장 얇은 작업이지만, **문항은 "로그가 안 온다"는 시나리오로 자주 나옵니다.**

> ⚠️ **이 작업의 문항은 거의 전부 「권한」과 「세대 차이」입니다.** 로그가 안 오는 이유는 대개 ① 실행 역할·서비스 역할에 권한이 없다 ② 계정·리전 수준 설정을 빼먹었다 ③ 구세대 기능을 쓰고 있다 — 셋 중 하나입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] Lambda 로그가 안 올 때 **실행 역할 권한 3종**과 로그 그룹을 확인한다
- [ ] API Gateway 로깅의 **계정·리전 수준 역할 ARN** 요건을 설명한다
- [ ] API Gateway의 **실행 로깅과 액세스 로깅**을 구분한다
- [ ] CloudFront **표준 로깅 v2와 레거시**의 차이와 공존 시 주의점을 안다
- [ ] CloudWatch 에이전트 문제를 **구성 검증 로그와 자동화 런북**으로 좁힌다
- [ ] 알람이 안 울리는 원인을 **평가 상태**와 **누락 데이터 설정**으로 가른다
- [ ] "로그가 없다"와 "로그가 안 보인다"를 **지연·권한·대상**으로 가른다

## 🎯 왜 중요한가

작업 1.1과 1.2가 **설계**라면 이 작업은 **디버깅**입니다. 그리고 보안 시험에서 디버깅 문항은 **"탐지가 조용한 이유"**를 묻습니다. 탐지 파이프라인이 조용한 것은 두 가지 중 하나입니다 — **정말 아무 일도 없다**, 또는 **신호가 끊겨 있다.** 후자를 못 알아보면 보안 사고를 놓칩니다.

이 문서는 서비스별로 **"로그가 안 오는 전형적 이유"**를 공식 문서가 적는 그대로 모아 둡니다. 추측으로 고치는 것이 아니라 **확인할 자리**를 아는 것이 이 작업의 핵심입니다.

## ⚡ 시험 직전 요약

- Lambda 로그는 기본 로그 그룹 **`/aws/lambda/<함수 이름>`**이고, **실행 역할에 `logs:CreateLogGroup`·`logs:CreateLogStream`·`logs:PutLogEvents`**가 필요합니다(`AWSLambdaBasicExecutionRole`이 그것을 담습니다)
- ⚠️ Lambda 로그는 호출 후 **5~10분** 걸릴 수 있습니다 — "안 온다"와 "아직 안 왔다"를 가릅니다
- API Gateway는 **실행 로깅**과 **액세스 로깅**이 있고 **서로 독립적으로** 켭니다
- ⚠️⚠️ API Gateway CloudWatch 로깅은 **계정의 `cloudWatchRoleArn`을 리전마다 따로** 설정해야 합니다
- ⚠️ API Gateway가 그 역할을 맡으려고 **AWS STS를 호출**하므로 **그 리전에서 STS가 활성화**돼 있어야 합니다
- CloudFront **표준 로깅 v2**는 CloudWatch Logs·Data Firehose·S3로 보낼 수 있고 **필드를 고를 수 있습니다.** **레거시는 S3만**입니다
- ⚠️ v2와 레거시를 **같은 버킷·같은 경로**에 쓰면 로그 파일이 서로 덮어씁니다 — 다른 버킷이나 다른 경로를 씁니다
- CloudWatch 에이전트가 시작되지 않으면 **`configuration-validation.log`**를 봅니다
- ⚠️ Run Command로 에이전트를 설치하려면 **SSM Agent 2.2.93.0 이상**이 필요합니다
- 알람이 안 울리면 **평가 상태**(`IN_WARM_UP`·`EVALUATION_ERROR`·`PARTIAL_DATA`·`EVALUATION_FAILURE`)를 먼저 봅니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **실행 역할(execution role)** | Lambda 함수가 **맡는** IAM 역할. 로그 기록 권한이 여기 있습니다 |
| **실행 로깅(execution logging)** | API Gateway가 **요청 처리 과정**(오류·실행 추적)을 남기는 로그 |
| **액세스 로깅(access logging)** | **누가 어떻게 접근했는가**를 내가 정한 형식으로 남기는 로그 |
| **`cloudWatchRoleArn`** | API Gateway가 CloudWatch Logs에 쓰기 위해 맡는 역할의 ARN. **계정·리전 수준 설정**입니다 |
| **표준 로깅 v2** | CloudFront 액세스 로그의 현행 방식. 대상과 필드를 고를 수 있습니다 |
| **구성 검증 로그** | 통합 CloudWatch 에이전트가 구성 파싱 결과를 적는 파일 |
| **평가 상태(evaluation state)** | 알람 상태와 **별도로** 평가 과정을 알려 주는 상태 |

## 📖 핵심 개념

### 1) 리소스의 기능·권한·구성을 분석한다 (기술 1.3.1) {#analyze}

#### 1-1. Lambda 로깅

공식 문서의 현재 제목은 「Sending Lambda **Event Function** logs to CloudWatch Logs」입니다(문서가 함수를 **Event Function**으로 부르도록 바뀌었습니다).

- 기본적으로 Lambda가 **모든 호출의 로그를 자동 수집**해 CloudWatch Logs로 보냅니다 — ⚠️ **단 실행 역할에 필요한 권한이 있을 때만입니다**
- 기본 로그 그룹은 **`/aws/lambda/<함수 이름>`**이고, **다른 로그 그룹으로 보내도록 구성**할 수 있습니다(콘솔·CLI·API)
- 필요 권한은 **`logs:CreateLogGroup` · `logs:CreateLogStream` · `logs:PutLogEvents`** 셋이고, 관리형 정책 **`AWSLambdaBasicExecutionRole`**이 이를 담습니다
- ⚠️ **호출 후 로그가 보이기까지 5~10분이 걸릴 수 있습니다**
- 요금은 **Lambda 로그 자체에 추가 비용이 없고 CloudWatch Logs 표준 요금**이 적용됩니다

⚠️ 문제 해결 순서 — ① 실행 역할에 세 권한이 있는가 ② 로그 그룹이 **다른 곳으로 지정**돼 있지 않은가 ③ **5~10분** 지났는가 ④ (대상 로그 그룹을 바꿨다면) 그 로그 그룹에 대한 권한이 있는가.

#### 1-2. API Gateway 로깅 — 계정 수준 설정이 함정이다

REST API의 CloudWatch 로깅은 **두 종류**입니다.

| | **실행 로깅** | **액세스 로깅** |
|---|---|---|
| 담는 것 | API Gateway가 **요청을 처리한 동작**(오류·실행 추적) | **누가 어떻게 접근했는가** |
| 로그 그룹 | API Gateway가 관리(전달 대상을 직접 지정할 수도 있습니다) | **내가 만든 로그 그룹** |
| 형식 | 고정 | **내가 고르고 `$context` 변수를 지정** |

⚠️ **둘은 서로 독립적으로 켤 수 있습니다.** "액세스 로그는 오는데 오류 추적이 없다"면 실행 로깅이 꺼진 것입니다.

⚠️⚠️ **가장 자주 틀리는 자리** — CloudWatch Logs를 켜려면 **API Gateway에 내 계정의 CloudWatch 로그 읽기·쓰기 권한을 줘야** 합니다. 절차가 이렇습니다.

1. 신뢰 주체가 **`apigateway.amazonaws.com`**인 IAM 역할을 만든다
2. 관리형 정책 **`AmazonAPIGatewayPushToCloudWatchLogs`**를 붙인다(필요 권한을 전부 담습니다)
3. 그 역할 ARN을 **계정의 `cloudWatchRoleArn` 속성**에 설정한다
4. ⚠️ **CloudWatch Logs를 켜려는 리전마다 따로** 설정한다

⚠️ **역할 ARN 설정에서 오류가 나면 STS를 확인합니다.** 공식이 "API Gateway가 IAM 역할을 맡기 위해 **AWS STS를 호출**하므로 **그 리전에서 STS가 활성화**돼 있어야 한다"고 적습니다. 리전 단위로 STS를 끄는 조직에서 실제로 걸리는 자리입니다.

#### 1-3. CloudFront 로깅 — 세대가 둘이다

| | **표준 로깅 v2** | **표준 로깅(레거시)** |
|---|---|---|
| 대상 | **CloudWatch Logs · Data Firehose · S3** | **S3만** |
| 필드 | **고를 수 있음**(실시간 로그 필드의 부분집합도 가능) | 고정 |
| 출력 형식 | **추가 형식 선택 가능** | 고정 |
| S3 옵션 | **옵트인 리전 전송 · 파티셔닝 · Hive 호환 파일명** | 없음 |

- ⚠️ **v2를 켜도 레거시에 영향이 없고 둘을 함께 쓸 수 있습니다**
- ⚠️⚠️ **둘을 함께 쓸 때 같은 S3 버킷·같은 경로를 쓰면 로그 파일이 서로 덮어씁니다.** 공식이 **다른 버킷이나 같은 버킷의 다른 경로**(접두사·파티셔닝)를 쓰라고 권합니다
- 설정은 **CloudFront 콘솔 또는 CloudWatch API**로 합니다(v2가 CloudWatch의 전달 기능을 쓰기 때문입니다) — 그래서 **대상 서비스(CloudWatch Logs·Firehose·S3)별 권한을 먼저 세워야** 합니다

#### 1-4. 상태 확인

작업 1.1에서 본 **상태 확인**은 여기서 "왜 비정상으로 보이나"로 되돌아옵니다. 확인 순서는 ① 상태 확인의 **대상 경로와 포트**가 맞는가 ② **보안 그룹·네트워크 ACL**이 상태 확인 트래픽을 허용하는가 ③ 임계값(연속 실패 수)과 간격이 **애플리케이션 기동 시간**보다 짧지 않은가입니다.

### 2) 잘못된 구성을 해결한다 (기술 1.3.2) {#fix}

#### 2-1. CloudWatch 에이전트 문제 해결

⚠️⚠️ **먼저 쓸 수 있는 자동화 수단이 있습니다** — 공식이 **`AWSSupport-TroubleshootCloudWatchAgent` 자동화 런북**을 안내하고, 그 런북이 하는 일을 이렇게 적습니다.

- **IAM 권한과 인스턴스 프로파일 검증**
- **에이전트 상태 확인과 로그 분석**
- **엔드포인트 연결 테스트**
- **관련 로그를 자동 수집해 S3에 업로드**

수동으로 좁힐 때의 자리들입니다.

| 증상 | 확인할 곳 |
|---|---|
| 에이전트가 **시작되지 않는다** | **구성 오류**일 수 있습니다. `/opt/aws/amazon-cloudwatch-agent/logs/configuration-validation.log`(Linux) · `$Env:ProgramData\Amazon\AmazonCloudWatchAgent\Logs\configuration-validation.log`(Windows Server) |
| **Run Command 설치가 실패**한다 | **SSM Agent가 2.2.93.0 이상**이어야 합니다. 그 아래면 `no latest version found for package AmazonCloudWatchAgent` 같은 오류가 납니다 |
| 에이전트가 **도는지 모르겠다** | Systems Manager **Run Command**에서 `AmazonCloudWatch-ManageAgent` 문서의 **status** 작업, 또는 로컬에서 `amazon-cloudwatch-agent-ctl ... -a status` |
| 시작 실패 오류에 **EC2 리전 엔드포인트**가 나온다 | 구성의 **`append_dimensions`**가 EC2 메타데이터에 의존하는데(프록시 환경 등) 서버가 **EC2 엔드포인트에 접근할 수 없는** 경우입니다 |
| 구성을 바꿨는데 **새 지표·로그가 안 보인다** | 에이전트를 **중지·재시작**해야 적용됩니다 |
| 자격 증명이 **엉뚱하다** | 에이전트가 쓰는 자격 증명(인스턴스 프로파일 또는 구성 파일의 프로파일)을 확인합니다 |

⚠️ 전체 파라미터는 `amazon-cloudwatch-agent-ctl -help`로 볼 수 있습니다.

#### 2-2. 누락된 로그를 좁히는 순서

로그가 보이지 않을 때 **원인은 네 층** 중 하나입니다. 위에서 아래로 봅니다.

1. **생성** — 그 기능의 로깅이 **켜져 있는가**(API Gateway 실행 로깅, CloudFront 표준 로깅, 흐름 로그 구독)
2. **권한** — 쓰는 주체(실행 역할 · 서비스 역할 · 서비스 주체)에게 **대상 쓰기 권한**이 있는가. 대상이 **KMS로 암호화**돼 있으면 **키 정책**까지
3. **대상** — 로그가 **내가 보고 있는 곳으로** 가고 있는가(로그 그룹을 바꿨는가, 리전이 다른가, 같은 버킷을 다른 기능이 덮어쓰고 있는가)
4. **시간** — **지연**인가(Lambda 5~10분, 흐름 로그는 생성 후 수집 시작까지 몇 분)

⚠️ 보안 맥락에서 하나 더 — **Security Hub CSPM은 소급 적용되지 않습니다.** 켠 시점 이후 생성된 조사 결과만 집계하므로, "왜 지난주 조사 결과가 없나"의 답이 **"그때는 켜져 있지 않았다"**일 수 있습니다.

#### 2-3. 알람이 울리지 않는다

작업 1.1의 두 축이 그대로 문제 해결 도구가 됩니다.

- **평가 상태** — `IN_WARM_UP`(워밍업 중이라 평가하지 않고 작업도 실행하지 않습니다) · `EVALUATION_ERROR`(구성 오류, `StateReason` 확인) · `PARTIAL_DATA`(쿼터 제한으로 데이터를 전부 못 가져옴) · `EVALUATION_FAILURE`(일시적 CloudWatch 문제)
- **누락 데이터 처리** — 기본값은 **`missing`**이고 **`AWS/DynamoDB` 네임스페이스만 기본이 `ignore`**입니다. 누락이 많은 지표에 `missing`이 걸려 있으면 알람은 `INSUFFICIENT_DATA`에 머물고 **ALARM으로 가지 않습니다**
- ⚠️ **다중 일 알람**(평가 기간 수 × 기간 길이 > 1일)은 **시간당 한 번**만 평가됩니다

## ✍️ 시험 포인트

- **Lambda 로그 없음 → 실행 역할 권한** 또는 **대상 로그 그룹 변경**. 그리고 **5~10분 지연**
- **API Gateway 로그 없음 → 계정의 `cloudWatchRoleArn`**, 그리고 **리전마다 설정**해야 함
- **역할 ARN 설정 오류 → 그 리전의 STS 활성화 여부**
- **CloudFront 로그가 섞여 사라짐 → v2와 레거시가 같은 버킷·경로**
- **에이전트 시작 실패 → `configuration-validation.log`**. 설치 실패는 **SSM Agent 버전**
- **프록시 환경에서 에이전트 실패 → `append_dimensions`와 EC2 엔드포인트 접근**
- **알람이 조용함 → 평가 상태**(특히 방금 만든 알람의 `IN_WARM_UP`)와 **누락 데이터 설정**
- **"지난주 조사 결과가 없다" → Security Hub CSPM의 비소급 성질**

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"Lambda는 자동으로 로그를 남기니 권한은 필요 없다"** → **실행 역할에 세 권한이 있어야** 합니다
- ❌ **"API Gateway 스테이지에서 로깅만 켜면 된다"** → **계정 수준 역할 ARN을 리전마다** 설정해야 합니다
- ❌ **"API Gateway 역할 ARN 오류는 정책 문제다"** → **그 리전의 STS가 꺼져 있을 수** 있습니다
- ❌ **"CloudFront 표준 로그는 S3로만 간다"** → **v2는 CloudWatch Logs·Firehose·S3** 셋입니다(레거시가 S3만)
- ❌ **"v2를 켜면 레거시가 자동으로 꺼진다"** → **영향을 주지 않고 공존**합니다. 같은 경로면 **덮어씁니다**
- ❌ **"에이전트를 설치하면 바로 지표가 보인다"** → 구성을 바꾼 뒤에는 **중지·재시작**이 필요합니다
- ❌ **"알람이 INSUFFICIENT_DATA면 지표가 없는 것이다"** → **워밍업·누락 데이터 설정·쿼터 제한**일 수 있습니다
- ❌ **"로그가 없으면 공격도 없었다"** → **신호가 끊긴 것**과 **사건이 없는 것**은 다릅니다. 이 작업의 요지입니다

## 🧪 자가 점검

**Q1.** Lambda 함수를 배포하고 1분 뒤 CloudWatch Logs를 봤는데 로그 그룹이 아예 없습니다. 무엇을 먼저 확인합니까? (→ 1-1 Lambda 로깅)

<details><summary>정답 보기</summary>

**① 실행 역할의 로그 권한 ② 지연**입니다.

- 필요 권한은 **`logs:CreateLogGroup` · `logs:CreateLogStream` · `logs:PutLogEvents`** 셋이고, 로그 그룹이 **아예 없다**면 `CreateLogGroup`이 없을 가능성이 큽니다. 관리형 정책 **`AWSLambdaBasicExecutionRole`**을 붙이면 해결됩니다
- 공식이 **"호출 후 로그가 보이기까지 5~10분이 걸릴 수 있다"**고 적습니다. 1분은 판단하기에 이릅니다

⚠️ 그리고 **로그 그룹을 다른 곳으로 지정**했을 수 있습니다 — 기본은 `/aws/lambda/<함수 이름>`이지만 콘솔·CLI·API로 **다른 로그 그룹**을 쓰도록 구성할 수 있습니다.
</details>

**Q2.** REST API 스테이지에서 실행 로깅을 켰는데 CloudWatch Logs에 아무것도 오지 않습니다. 스테이지 설정은 맞습니다. 무엇이 빠졌습니까? (→ 1-2 API Gateway 로깅)

<details><summary>정답 보기</summary>

**계정의 `cloudWatchRoleArn`**입니다. API Gateway에 내 계정의 CloudWatch Logs 읽기·쓰기 권한을 줘야 하고, 절차는 **신뢰 주체 `apigateway.amazonaws.com`인 역할 + 관리형 정책 `AmazonAPIGatewayPushToCloudWatchLogs` + 그 역할 ARN을 계정 속성에 설정**입니다.

⚠️⚠️ **그 설정은 리전마다 따로** 해야 합니다 — "다른 리전에서는 되는데 여기서는 안 된다"의 전형적 원인입니다.

⚠️ 역할 ARN을 설정할 때 오류가 나면 **그 리전에서 AWS STS가 활성화돼 있는지** 확인합니다(API Gateway가 역할을 맡으려고 STS를 호출합니다).
</details>

**Q3.** CloudFront 액세스 로그를 CloudWatch Logs로 받아 Logs Insights로 조사하고 싶습니다. 기존에는 레거시 표준 로깅으로 S3에 쌓고 있었습니다. 어떻게 하고, 무엇을 주의합니까? (→ 1-3 CloudFront 로깅)

<details><summary>정답 보기</summary>

**표준 로깅 v2를 켭니다.** v2는 **CloudWatch Logs · Data Firehose · S3**로 보낼 수 있고 **원하는 필드만** 고를 수 있습니다(레거시는 **S3만**이고 필드가 고정입니다).

⚠️ 주의할 점 둘 —
- **v2를 켜도 레거시는 그대로 돌아갑니다**(영향을 주지 않습니다). 둘을 함께 쓸 수 있습니다
- ⚠️⚠️ **v2를 S3로도 보낸다면 레거시와 같은 버킷·같은 경로를 쓰지 않습니다.** 공식이 **다른 버킷이나 다른 경로**(접두사·파티셔닝)를 권하는 이유는 **로그 파일이 서로 덮어쓰기** 때문입니다

그리고 v2는 **CloudWatch의 전달 기능**을 쓰므로(콘솔 또는 CloudWatch API로 구성) **대상 서비스별 권한을 먼저** 세워야 합니다.
</details>

**Q4.** EC2 인스턴스에 통합 CloudWatch 에이전트를 Run Command로 설치하려는데 `no latest version found for package AmazonCloudWatchAgent` 오류가 납니다. 원인은? (→ 2-1 에이전트 문제 해결)

<details><summary>정답 보기</summary>

**대상 서버의 SSM Agent 버전이 낮습니다.** 공식이 **2.2.93.0 이상**을 요구하고, 그보다 낮으면 이 메시지나 `failed to download installation package reliably`가 납니다. SSM Agent를 올리면 해결됩니다.

⚠️ 에이전트가 **시작되지 않는** 경우는 다른 문제입니다 — **구성 오류**일 수 있으므로 **`configuration-validation.log`**를 봅니다(Linux는 `/opt/aws/amazon-cloudwatch-agent/logs/` 아래).

⭐ 그리고 공식이 **`AWSSupport-TroubleshootCloudWatchAgent` 자동화 런북**을 제공합니다 — IAM 권한·인스턴스 프로파일 검증, 상태·로그 분석, **엔드포인트 연결 테스트**, 로그 수집·S3 업로드를 한 번에 합니다.
</details>

**Q5.** 방금 만든 알람이 임계값을 넘는 데이터가 있는데도 `INSUFFICIENT_DATA`에 머물고 알림도 오지 않습니다. 가장 유력한 원인과 확인 방법은? (→ 2-3 알람이 울리지 않는다)

<details><summary>정답 보기</summary>

**평가 상태가 `IN_WARM_UP`**일 가능성이 큽니다. 워밍업 기간에는 알람이 **평가하지 않고** `INSUFFICIENT_DATA`에 머물며 **작업을 실행하지 않습니다.** 확인은 콘솔의 알람 상세 또는 **`describe-alarms`(`DescribeAlarms`)**입니다.

다른 후보 — **`EVALUATION_ERROR`**(구성 오류, `StateReason` 확인) · **`PARTIAL_DATA`**(쿼터 제한) · **`EVALUATION_FAILURE`**(일시적 CloudWatch 문제) · **누락 데이터 처리**(기본 `missing`이면 데이터가 전부 누락일 때 `INSUFFICIENT_DATA`로 갑니다. **`AWS/DynamoDB`만 기본 `ignore`**).

⚠️ **다중 일 알람**이면 **시간당 한 번**만 평가되므로 즉시 바뀌지 않는 것이 정상입니다.
</details>

**Q6.** 감사에서 "지난달 보안 제어 위반 조사 결과를 제출하라"고 했는데 Security Hub CSPM 콘솔에 그 기간 조사 결과가 없습니다. Security Hub CSPM은 **3주 전에** 켰습니다. 무엇을 설명해야 합니까? (→ 2-2 누락된 로그)

<details><summary>정답 보기</summary>

**Security Hub CSPM은 소급 적용되지 않습니다.** 공식이 "**켠 뒤에 생성된 조사 결과만** 탐지·통합하고, 그 전에 생성된 보안 조사 결과를 소급해서 탐지·통합하지 않는다"고 적습니다. 3주 전에 켰다면 **그 이전 기간의 조사 결과는 존재하지 않습니다.**

⚠️ 함께 설명할 것 —
- Security Hub CSPM은 **활성화한 리전에서만** 조사 결과를 받아 처리합니다. 다른 리전의 위반은 그 리전에서 켜야 보입니다
- **대부분의 제어는 AWS Config를 켜고 리소스를 기록해야** 조사 결과를 만듭니다

⭐ 대안은 **원시 로그**입니다 — CloudTrail(S3)이 그 기간을 담고 있다면 **Athena**로 조회할 수 있습니다.
</details>

---

### 📌 출처

1. Sending Lambda Event Function logs to CloudWatch Logs — `docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html` (2026-11-08 확인)
2. Set up CloudWatch logging for REST APIs in API Gateway — `docs.aws.amazon.com/apigateway/latest/developerguide/set-up-logging.html` (2026-11-08 확인)
3. Configure standard logging (v2) — `docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging.html` (2026-11-08 확인)
4. Configure standard logging (legacy) — `docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging-legacy-s3.html` (2026-11-08 확인)
5. Troubleshooting the CloudWatch agent — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/troubleshooting-CloudWatch-Agent.html` (2026-11-08 확인)
6. Alarm evaluation — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html` (2026-11-08 확인)
7. Configuring how CloudWatch alarms treat missing data — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html` (2026-11-08 확인)
8. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-08 확인)
9. Health checks for your target groups — 경로·포트·간격·임계값 — `docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-health-checks.html` (2026-11-10 확인)
10. Register targets with your target group — 보안 그룹 요건 — `docs.aws.amazon.com/elasticloadbalancing/latest/application/target-group-register-targets.html` (2026-11-10 확인)
