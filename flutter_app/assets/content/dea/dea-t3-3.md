---
examGuideTaskId: dea-t3-3
certCode: DEA-C01
domain: 3
domainName: 데이터 운영 및 지원
domainWeightPct: 22
title: 파이프라인 유지 관리·모니터링 (로그·알림·성능·CloudTrail)
coversTasks:
  - "3.3"
sources:
  - title: AWS CloudTrail FAQs (공식 문서)
    url: https://aws.amazon.com/cloudtrail/faqs/
  - title: Logging data events (CloudTrail User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html
  - title: Real-time processing of log data with subscriptions (CloudWatch Logs) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
  - title: Configuring how CloudWatch alarms treat missing data (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html
  - title: Automating AWS Glue with EventBridge (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/automating-awsglue-with-cloudwatch-events.html
  - title: Using an auto-termination policy for Amazon EMR cluster cleanup (공식 문서)
    url: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-auto-termination-policy.html
  - title: Troubleshooting Kinesis Data Streams consumers (공식 문서)
    url: https://docs.aws.amazon.com/streams/latest/dev/troubleshooting-consumers.html
  - title: DEA-C01 공식 시험 가이드 도메인 3 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
lastVerified: 2026-10-20
---

# 파이프라인 유지 관리·모니터링 (로그·알림·성능·CloudTrail)

> **커버하는 공식 Task** — DEA-C01 · 도메인 3 「데이터 운영 및 지원」(22%) · **Task 3.3 데이터 파이프라인 유지 관리 및 모니터링** (`dea-t3-3`)
> Skill 8개가 CloudTrail·CloudWatch·EventBridge·Glue·EMR·Redshift·Athena·Kinesis·Lambda·DynamoDB에 걸쳐 있습니다.
> 이 문서는 **운영·알림·분석** 관점입니다. 감사용 로그의 **보존·무결성·중앙화**(도메인 4 Task 4.4)와 Skill이 겹치는 부분이 있으니, 같은 서비스라도 **"운영이 묻는가, 감사가 묻는가"** 를 먼저 구분하세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 3.3의 Skill 항목)

- [ ] **로그 원천별 추출 경로**(CloudTrail·CloudWatch Logs·S3·VPC·Redshift)와 각각의 제약을 안다
- [ ] **CloudTrail · CloudWatch · AWS Config** 가 각각 어떤 질문에 답하는지 구분한다
- [ ] **지표 기반·이벤트 기반·로그 기반** 알림 경로를 상황에 맞게 고른다
- [ ] CloudWatch 경보의 **누락 데이터 처리 네 가지**와 기본값을 설명한다
- [ ] 서비스별 **"먼저 볼 신호 지표"** 를 떠올려 병목 위치를 좁힌다
- [ ] CloudTrail의 **이벤트 유형 네 가지**와 기본 활성 여부를 구분한다
- [ ] **Glue 북마크·재시도·타임아웃**, **EMR 로그·ActionOnFailure·자동 종료** 로 파이프라인을 유지 관리한다
- [ ] CloudWatch Logs의 **보존·로그 클래스·메트릭 필터·구독 필터**를 구성한다
- [ ] **Logs Insights·Athena·OpenSearch Service·EMR** 중 로그 분석 도구를 고른다

---

## 🎯 왜 중요한가

- 운영 문항은 **"무엇을 설치할까"가 아니라 "어느 신호를 먼저 볼까"** 를 묻습니다. 같은 "느리다"라도 Kinesis는 **IteratorAge**, Lambda는 **Throttles**, Redshift는 **WLM 큐 대기**가 출발점입니다.
- 로그 관련 선택지는 **기본값**으로 갈립니다. CloudTrail 데이터 이벤트는 **기본 꺼짐**, Redshift 감사 로깅도 **기본 꺼짐**, Glue 북마크도 **기본 꺼짐**, CloudWatch Logs 보존은 **기본 무기한**입니다.
- **알림 경로를 섞어 쓰면 틀립니다.** "작업이 FAILED 되면"은 EventBridge 규칙, "지표가 N분 연속 초과하면"은 CloudWatch 경보입니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **관리 이벤트** | management event | 리소스를 *만들고 바꾸고 지우는* control plane API 기록 |
| **데이터 이벤트** | data event | 리소스 *안의 데이터*를 읽고 쓰는 data plane 작업 기록 |
| **구성 항목** | configuration item | AWS Config가 남기는 *그 시점 리소스 구성의 스냅샷* |
| **메트릭 필터** | metric filter | 로그에서 찾은 패턴을 *CloudWatch 지표로 바꾸는* 규칙 |
| **구독 필터** | subscription filter | 로그 이벤트를 *거의 실시간으로 다른 서비스에 흘려보내는* 설정 |
| **이터레이터 나이** | iterator age | 스트림 레코드가 *소비될 때까지 기다린 시간* — 소비 지연의 지표 |
| **쓰로틀** | throttle | 한도를 넘어 *요청이 거부되는* 것 |
| **WLM** | workload management | Redshift가 *쿼리를 큐로 나눠 자원을 배분하는* 구조 |
| **DPU** | data processing unit | Glue·Athena의 *컴퓨트·메모리 단위* |
| **executor** | executor | Spark에서 *실제 태스크를 실행하는 작업자 프로세스* |

---

## 📖 핵심 개념

### 1) 감사용 로그 추출 수단 {#extract-logs}

감사 대응에서는 이미 쌓인 기록을 **원천별로 꺼낼 경로**를 고르는 것이 핵심입니다. 원천마다 저장 위치·지연·완전성이 다릅니다.

| 로그 원천 | 꺼내는 수단 | 지연·제약 | 시험 단서 |
|---|---|---|---|
| **CloudTrail 이벤트** | 이벤트 기록(Event history) / **trail** → S3·CloudWatch Logs·EventBridge | 이벤트 기록은 **현재 리전 최근 90일·관리 이벤트만**, trail은 보통 **5분** 안에 도착 | "지난 90일", "데이터 이벤트", "장기 보관" |
| **CloudWatch Logs** | **구독 필터**(준실시간) / **`CreateExportTask`**(배치) | 구독은 **Standard 클래스만**, 내보내기는 **활성 작업 수 한도** | "실시간 전달" vs "S3로 아카이브" |
| **S3 요청** | CloudTrail **데이터 이벤트** / S3 **서버 액세스 로그** | **무결성 검증은 CloudTrail만**, 수명 주기 동작·인증 실패 요청은 **서버 액세스 로그만** | "객체 수준 감사", "무결성" |
| **VPC 네트워크** | **VPC Flow Logs** → CloudWatch Logs·S3·Amazon Data Firehose | 게시 대상을 고름 | "IP 트래픽 로그" |
| **Amazon Redshift** | 감사 로그(S3·CloudWatch Logs), 시스템 테이블 | **감사 로깅 기본 꺼짐** | "연결·사용자·사용자 활동 로그" |

- **CloudTrail 이벤트 기록**은 설정 없이 쓸 수 있지만 **현재 리전의 최근 90일**, 그것도 생성·수정·삭제 같은 **관리 이벤트로 한정**됩니다. 데이터 이벤트와 읽기 전용 활동까지 포함한 완전한 기록은 **trail**이 필요합니다. trail이 없어도 콘솔·CLI·API(`lookup-events`)로 최근 90일은 조회할 수 있습니다.
- **CloudWatch Logs → S3 내보내기**(`CreateExportTask`)는 **비동기 배치성 작업**입니다. 동시에 활성인 내보내기 작업 수에 계정·리전별 한도가 있습니다. ⚠️ API 문서는 **로그를 계속 아카이브하는 용도로는 정기적 내보내기 대신 구독을 쓰라고 권고**합니다.
- **구독 필터**는 로그 이벤트를 **Kinesis Data Streams·Amazon Data Firehose·Lambda**로 거의 실시간 전달합니다. 전달 데이터는 **base64 인코딩 + gzip 압축**이며 **Standard 로그 클래스에서만** 지원됩니다. OpenSearch Service로의 준실시간 스트리밍도 구독으로 구성합니다.
- **Redshift 감사 로깅**(연결 로그·사용자 로그·사용자 활동 로그)은 **기본 꺼짐**이고, 켜면 CloudWatch Logs로 내보내거나 S3에 업로드합니다. **사용자 활동 로그는 `enable_user_activity_logging` 파라미터도 켜야** 남습니다. 시스템 테이블 로깅은 선택이 아니라 자동입니다.

### 2) 감사·추적성을 위한 로깅·모니터링 배포 {#deploy-logging}

추적성은 **세 질문**으로 나누면 서비스가 갈립니다.

| 서비스 | 답하는 질문 | 기록 단위 | 시험 단서 |
|---|---|---|---|
| **AWS CloudTrail** | **누가·언제·어디서 어떤 API를 호출했나** | API 호출 이벤트(요청자, 서비스, 작업, 파라미터, 응답 요소) | "누가 삭제했나", "API 호출 추적" |
| **Amazon CloudWatch Logs** | **애플리케이션·서비스가 무엇을 출력했나** | 로그 그룹/스트림의 로그 이벤트 | "애플리케이션 로그", "로그 패턴에 경보" |
| **AWS Config** | **리소스 구성이 시간에 따라 어떻게 바뀌었나** | 구성 항목(CI)·구성 이력 파일·구성 스냅샷 | "구성 변경 이력", "규정 준수 변화" |

- **CloudTrail 배포** — 모든 리전에 적용하는 trail(`IsMultiRegionTrail`=true)은 **새로 추가되는 리전도 자동으로 기록**하며 설정 복제는 보통 **30초** 안에 끝납니다. **리전당 trail은 최대 5개**이고 모든 리전 trail은 각 리전에서 1개로 셉니다. **조직 trail**은 관리 계정과 모든 멤버 계정의 이벤트를 같은 S3 버킷·CloudWatch Logs·EventBridge로 전달하며, **콘솔에서 만든 조직 trail은 모두 멀티 리전**입니다.
- **CloudTrail → CloudWatch Logs 통합**을 켜면 예를 들어 보안 그룹·네트워크 ACL을 만들고 바꾸고 지우는 API 호출에 **CloudWatch 경보**를 걸어 SNS로 알림을 받을 수 있습니다. 이때 **표준 CloudWatch Logs·CloudWatch 요금이 별도로** 붙습니다.
- **AWS Config** — 지원 리소스가 바뀔 때마다 **구성 항목**을 만들고 리소스 유형별 **구성 이력 파일을 지정한 S3 버킷에 자동 전달**합니다. ⚠️ **한 리소스가 짧은 시간에 연속 변경되면 최종 상태를 나타내는 구성 항목 하나만 생길 수 있어**, CloudTrail 이벤트와 구성 항목을 시간·리소스 ID로 맞춰도 "누가 무엇을 바꿨는지"가 완전히 대응되지 않을 수 있습니다.
- **서비스별 로그 설정** — Glue는 **4.0 이하에서 연속 로깅을 켜야** CloudWatch Logs로 보내고 **5.0부터는 모든 작업이 실시간 로깅 기능**을 갖습니다. **Spark UI**를 켜면 Spark 이벤트 로그를 지정한 S3 경로에 씁니다. EMR은 노드의 `/mnt/var/log/` 를 S3로 아카이브하도록 **클러스터에 로그 경로를 지정**합니다.

> 📌 오래된 문서에 남아 있는 **"CloudWatch Events"** 표기는 현재의 **Amazon EventBridge**입니다. 보기에 구명칭이 나와도 같은 서비스로 취급하세요.

### 3) 모니터링 알림 — 세 가지 경로 {#notifications}

| 경로 | 무엇에 반응하는가 | 대표 구성 |
|---|---|---|
| **지표 기반** | 지표가 임계값을 넘음 | **CloudWatch 경보** → SNS |
| **이벤트 기반** | 서비스가 **상태 변경 이벤트**를 발행 | **EventBridge 규칙** → SNS·Lambda |
| **로그 기반** | 로그에 특정 패턴이 나타남 | **메트릭 필터 → 경보**, 또는 **구독 필터** → Lambda |

**CloudWatch 경보** — 지표를 고르고 평가 기간과 통계(Average, Maximum 등), 비교 연산자·임계값을 정합니다. 작업으로 이메일, SQS 게시, EC2 중지·종료, Auto Scaling 정책 실행을 걸 수 있고 **SNS와 통합되어 SNS가 지원하는 모든 알림 유형**을 쓸 수 있습니다. 임계값 위반이 이어지면 경보가 **ALARM 상태를 유지하는 것은 정상 동작**입니다. **복합 경보**는 여러 경보를 계층으로 묶어 동시에 울리는 경보를 한 번만 알려 **소음을 줄입니다.** 고해상도 사용자 지정 지표에는 **초 단위 주기의 고해상도 경보**를 걸 수 있습니다.

**누락 데이터 처리 — 시험 단골입니다.**

| 설정 | 의미 | 쓸 곳 |
|---|---|---|
| `missing` | **기본값** — 누락 구간을 평가에서 빼고 이전 상태 유지 | 일반적인 경우 |
| `notBreaching` | 누락을 **정상**으로 취급 | **오류가 날 때만 데이터가 생기는 지표**(예: DynamoDB `ThrottledRequests`) |
| `breaching` | 누락을 **위반**으로 취급 | **연속 보고되는 지표**가 끊기면 문제인 경우 |
| `ignore` | 경보 상태를 바꾸지 않음 | `AWS/DynamoDB` 네임스페이스 지표의 **기본값** |

**이벤트 기반 알림 — 서비스가 이미 상태 이벤트를 발행합니다.**

- **AWS Glue** — `Glue Job State Change`(**SUCCEEDED, FAILED, TIMEOUT, STOPPED**)와, **지연 알림 임계값을 설정해야 받는** `Glue Job Run Status`(RUNNING, STARTING, STOPPING). 문서 예시는 ETL 작업 성공 시 Lambda 실행·실패 시 SNS 통지입니다.
- **AWS Step Functions** — `Step Functions Execution Status Change`, status는 **RUNNING, SUCCEEDED, FAILED, TIMED_OUT, ABORTED, PENDING_REDRIVE**.
- **Amazon EMR** — `EMR Step Status Change`, `EMR Cluster State Change` 등.
- **Amazon Redshift** — 이벤트 구독으로 SNS에 알립니다. ⚠️ **SNS 표준 주제만 쓸 수 있고(FIFO 불가)**, 소스 유형·ID·범주(Monitoring, Security 등)·심각도(INFO, ERROR)로 필터링합니다.

**로그 기반** — **메트릭 필터**는 로그에서 찾은 용어·패턴을 CloudWatch 지표로 바꿔 그래프나 경보에 쓰게 합니다. **구독 필터**는 로그 이벤트를 Lambda 등으로 실시간 전달합니다.

### 4) 성능 문제 해결 — 서비스별 "먼저 볼 신호" {#perf-troubleshoot}

| 서비스 | 먼저 볼 신호 | 해석·조치 |
|---|---|---|
| **Athena** | 스캔량·플래닝 시간·S3 요청 | 컬럼형(Parquet/ORC)·압축·적정 크기 파일로 정리, **작은 파일은 S3DistCp 등으로 병합**, **파티션 프로젝션**으로 카탈로그 조회 부담 제거 |
| **Redshift** | **WLM 큐 대기**, 쿼리 모니터링 규칙(QMR) 지표, CloudWatch 지표, Advisor | **자동 WLM + 동시성 확장**(기본 꺼짐)으로 버스트 흡수, 폭주 쿼리는 **QMR**, 통계 부족은 **ANALYZE** |
| **AWS Glue** | **최대 필요 executor 대비 활성 executor**, 작업 지표, Spark UI | 필요 executor가 할당량을 크게 넘으면 **DPU 과소 할당** → 워커·DPU 증설 |
| **Amazon EMR** | 단계 로그(**controller·stderr·syslog**), 클러스터 로그 | 실패 단계의 로그에서 스택 트레이스 확인 |
| **Kinesis Data Streams** | **`GetRecords.IteratorAgeMilliseconds`**, `Read/WriteProvisionedThroughputExceeded` | 소비 지연과 쓰로틀을 구분. **급증은 하류 API 실패 같은 일시 문제, 완만한 증가는 소비자 처리 속도 부족** |
| **AWS Lambda** | **`Throttles`**, `Duration`, **`ConcurrentExecutions`(Max 통계)**, `IteratorAge` | `ConcurrentExecutions` 가 **리전 동시 실행 할당량 또는 함수 예약 동시성 한도**에 닿으면 쓰로틀. ⚠️ **쓰로틀된 요청은 `Invocations`·`Errors`에 잡히지 않습니다** |
| **Amazon DynamoDB** | `ThrottledRequests`, `ReadThrottleEvents`, `WriteThrottleEvents` | **요청 단위 지표(`ThrottledRequests`)는 규모를 가릴 수 있어** 이벤트 단위 지표와 비교 |

- **Athena** — 파일은 **분할(split) 크기를 적정 수준으로 맞추는 것이 일반 지침**입니다(블로그 지침은 약 128 MB — 수치 자체를 정답 근거로 삼지는 마세요). **Parquet·ORC 같은 분석용 포맷은 항상 분할 가능하지만 압축된 텍스트 파일 대부분은 분할되지 않아 단일 split으로** 처리됩니다. **과도한 파티셔닝은 작은 파일을 낳고, 최악의 경우 S3 요청 한도 때문에 쿼리가 실패**할 수 있습니다.
- **Redshift** — **자동 WLM**은 ML로 메모리·동시성을 동적으로 관리합니다. WLM 큐를 여러 개 정의해 워크로드를 분리하고 우선순위를 줄 수 있으며 **단기 쿼리 가속(SQA)은 기본 파라미터 그룹에서 기본 활성**입니다. **동시성 확장은 기본으로 꺼져 있고 WLM 큐별로 켭니다(AUTO).** QMR 지표(`query_cpu_time` 등)는 **규칙을 만들지 않아도 자동 수집**되며 `SVL_QUERY_METRICS_SUMMARY` 등으로 봅니다.
- **AWS Glue** — **DPU는 4 vCPU와 16 GB 메모리의 상대 측정 단위**입니다. **최대 필요 executor**는 실행 중 태스크와 대기 태스크를 더해 executor당 태스크 수로 나눠 계산하고 활성 executor와 비교해 과소 할당 배율을 구합니다. **동시 실행 한도(`MaxConcurrentRuns`) 기본값은 1** 이고 초과하면 오류가 반환됩니다.
- **Kinesis** — 이터레이터 나이가 **보존 기간(기본 24시간, 최대 365일)의 50%** 를 넘으면 **레코드 만료로 인한 데이터 손실 위험**이 있습니다. 임시 방편은 보존 기간 연장이고, **근본 해결은 소비 로직 점검과 샤드 증설을 통한 병렬성 확대**입니다. 이 지표는 **Maximum 통계에 경보**를 걸어 두는 것이 권장됩니다.

### 5) CloudTrail로 API 호출 추적 {#cloudtrail}

CloudTrail은 **"누가 어떤 API를 호출했는가"** 의 기록입니다. 이벤트에는 요청자, 사용한 서비스, 수행한 작업, 작업 파라미터, 응답 요소가 담기며 **콘솔·SDK·CLI·상위 AWS 서비스가 부르는 API 호출이 모두** 기록됩니다.

| 이벤트 유형 | 기본 로깅 | 내용 | 비용·특성 |
|---|---|---|---|
| **관리 이벤트** | **기본 기록** | control plane 작업, `ConsoleLogin` 같은 비 API 이벤트 포함 | 리전별 **첫 사본 무료**, 추가 사본 유료 |
| **데이터 이벤트** | **기본 비활성** | S3 객체 수준 API(`GetObject`·`PutObject`·`DeleteObject`), Lambda `Invoke`, SNS `Publish` 등 | **대용량·추가 요금** |
| **Insights 이벤트** | trail 설정에서 켜야 함 | API **호출량·오류율이 기준선에서 벗어난** 비정상 활동 탐지 | 개별 trail에 구성 |
| **네트워크 활동 이벤트** | 명시적으로 켜야 함 | **VPC 엔드포인트로 AWS 서비스를 호출한** API 활동(허용·거부 모두) | 추가 요금, VPC 엔드포인트 소유자에게만 전달 |

- **이벤트 선택기** — 데이터 이벤트는 **고급 이벤트 선택기로 필드(예: `eventName`)를 필터링**해 관심 있는 이벤트만 기록하면 **비용을 통제**할 수 있습니다. trail에서는 S3 객체(범용 버킷)·Lambda 함수·DynamoDB 테이블에 기본·고급 선택기를 모두 쓸 수 있고, 나머지 리소스 유형은 고급 선택기만, 이벤트 데이터 스토어는 고급 선택기만 씁니다.
- **읽기/쓰기 구분** — 읽기 전용·쓰기 전용·둘 다 중 무엇을 기록할지 정할 수 있습니다.
- **Insights** — **개별 trail에 구성하므로 trail이 먼저 있어야** 합니다. 비정상 이벤트는 기준선에서 벗어난 API 호출량으로 정의됩니다.
- ⚠️ **중복 이벤트** — CloudTrail은 **최소 1회 전달**을 목표로 설계되어 같은 이벤트가 두 번 올 수 있으며 **중복 이벤트는 같은 `eventID`** 를 갖습니다. 로그를 파이프라인으로 적재할 때 `eventID` 로 중복을 제거해야 합니다.

### 6) 파이프라인 유지 관리 — Glue·EMR {#glue-emr-maintain}

**AWS Glue**

- **로그** — **4.0 이하는 연속 로깅(`--enable-continuous-cloudwatch-log`)을 켜야** 하며 사용자 지정 로그 그룹·스트림 접두사·변환 패턴을 줄 수 있고 **기본 로그 그룹은 `/aws-glue/jobs/logs-v2`** 입니다. **5.0부터는 모든 작업이 실시간 로깅 기능**을 갖습니다. 버전을 지정하지 않고 만든 작업의 **기본 Glue 버전은 5.1** 입니다.
- **Spark UI** — Apache Spark 웹 UI로 Glue ETL 작업을 모니터링·디버깅하며, 콘솔에서 **Spark 이벤트 로그를 쓸 S3 경로**를 입력합니다.
- **작업 북마크** — **Enable**(상태를 갱신하며 새 데이터만 처리) · **Disable(기본값, 매번 전체 처리)** · **Pause**(상태를 갱신하지 않고 마지막 성공 실행 이후 증분 처리). S3 입력은 **객체의 마지막 수정 시각**으로 재처리 대상을 판단하므로 수정된 파일은 다시 처리됩니다.
- **재시도·시간 제한·동시 실행** — `MaxRetries` 는 JobRun 실패 후 재시도 횟수, `Timeout` 은 실행이 자원을 쓸 수 있는 최대 시간이며 초과하면 **`TIMEOUT` 상태**가 됩니다. 작업 타임아웃은 **7일(10,080분) 미만**이어야 하고, 비워 두면 **Glue 4.0 이하는 2,880분, 5.0 이상은 480분**이 기본입니다. `MaxConcurrentRuns` **기본 1** 을 넘기면 오류가 반환됩니다.

**Amazon EMR**

- **로그 위치** — 기본으로 모든 노드의 **`/mnt/var/log/`** 에 쓰이며, **클러스터 종료 후에는 노드 로컬 로그를 못 쓰므로 S3 로그 경로를 지정해 아카이브**해야 합니다. **6.8.0 이하는 5분 간격**으로 아카이브하고 **6.9.0 이상은 스케일다운 시에도** 아카이브합니다. ⚠️ **콘솔로 만든 클러스터는 로그 아카이빙이 기본으로 켜지고, CLI·API로 만든 클러스터는 수동 설정**이 필요합니다.
- **단계 로그 4종** — **`controller`**(단계 처리 정보, 로딩 중 실패 시 스택 트레이스) · **`syslog`**(Hadoop 잡 실행) · **`stderr`** · **`stdout`**.
- **단계 실패 정책** — `ActionOnFailure` 로 지정합니다. `TERMINATE_CLUSTER`·`TERMINATE_JOB_FLOW` 를 고르면 **단계 실패 때 클러스터가 종료**되며, `CONTINUE` 또는 `CANCEL_AND_WAIT` 로 이를 피합니다.
- **자동 종료** — 유휴 판정은 **활성 YARN 애플리케이션 없음, HDFS 사용률 낮음, 활성 노트북·EMR Studio 연결 없음, 온클러스터 UI 미사용, 대기 중 단계 없음** 등을 보며 EMR 릴리스에 따라 기준이 다릅니다. **유휴 시간 기본 60분, 범위는 1분~7일** 입니다. ⚠️ **Presto·Trino·HBase 같은 비 YARN 애플리케이션에서는 자동 종료가 지원되지 않습니다.**

### 7) CloudWatch Logs 구성·자동화 {#cwlogs-config}

로그는 **로그 그룹 → 로그 스트림 → 로그 이벤트** 구조이며, **보존·로그 클래스·메트릭 필터·구독 필터는 모두 로그 그룹 단위**로 설정합니다.

- **수집** — **CloudWatch 에이전트**로 AWS·온프레미스·멀티클라우드 호스트의 지표와 로그를 수집하고, Lambda를 포함한 많은 AWS 서비스는 CloudWatch와 **직접 통합**됩니다. 텍스트 기반 일반 로그와 **JSON 로그**를 받습니다.
- **보존** — **기본은 무기한 저장**이며 로그 그룹마다 언제든 바꿀 수 있습니다. 비용 문항에서 자주 나오는 출발점입니다.
- **로그 클래스** — **Standard**(전체 기능)와 **Infrequent Access(IA)**(부분 기능)이며 두 클래스는 **수집(ingestion) 비용만 다르고 생성 후 클래스를 바꿀 수 없습니다.** IA는 **구독 필터·메트릭 필터·Live Tail·`GetLogEvents`/`FilterLogEvents` 미지원**이고 **Logs Insights·교차 계정 기능은 지원**합니다.
- **메트릭 필터** — 로그 데이터를 지표로 바꿔 경보에 씁니다. ⚠️ **소급 적용되지 않습니다**(필터를 만든 뒤 발생한 이벤트만 지표가 됩니다). **Standard 클래스에서만** 지원됩니다.
- **구독 필터** — Kinesis Data Streams·Firehose·Lambda(+OpenSearch)로 전달합니다. **계정 수준 구독 필터는 리전당 1개**이고 **로그 그룹 수준 구독 필터에는 로그 그룹당 개수 한도**가 있습니다(사용자 가이드와 API 레퍼런스의 수치 서술이 달라 이 문서는 숫자를 단정하지 않습니다 — **개수를 묻는 문항은 피하세요**).
- **자동화** — 새 로그 그룹마다 보존 기간을 맞추려면 **EventBridge + Lambda로 로그 그룹 생성 시 보존 정책을 자동 적용**하고, **AWS Config 관리형 규칙 `cw-loggroup-retention-period-check`** 로 최소 보존 기간 미달 로그 그룹을 주기적으로 탐지합니다. 보존은 콘솔 또는 **`put-retention-policy`** CLI로도 설정합니다.
- **한도** — 로그 이벤트 크기, `PutLogEvents` 배치 크기, 로그 그룹당 필터 개수, 활성 내보내기 작업 수 같은 기본 한도는 **CloudWatch Logs quotas 표**에서 확인하며, 일부는 조정 가능하고 일부는 조정할 수 없습니다.

### 8) 로그 분석 도구 선택 {#log-analysis}

분석 도구는 **로그가 어디에 있는가**와 **질의 빈도·지연 요구**로 갈립니다.

| 도구 | 데이터 위치 | 적합한 경우 | 제약·비용 특성 |
|---|---|---|---|
| **CloudWatch Logs Insights** | CloudWatch Logs | **운영 문제 대응용 즉석 쿼리**, 설정·인프라 불필요 | **쿼리가 스캔한 수집 로그량으로 과금**(실패 쿼리 무과금, 취소 쿼리는 취소 시점까지 과금), **쿼리 한 번에 최대 50개 로그 그룹** |
| **Amazon Athena** | **S3의 로그**(CloudTrail 등) | S3 로그를 **SQL로 직접 쿼리** | 컬럼형·압축·파티션·파일 크기에 민감, **파티션 프로젝션** 활용 |
| **Amazon OpenSearch Service** | 인덱싱된 로그 | **실시간 로그 분석·빈번한 쿼리·전문(full-text) 검색** | 로그를 도메인에 적재(구독 필터 등) |
| **Amazon EMR** | S3의 대용량 로그 | **거대한 로그 집합의 페타바이트급 배치 분석** | 클러스터 운영 |

- **Logs Insights** — 쿼리 언어는 **Logs Insights QL · OpenSearch PPL · OpenSearch SQL** 세 가지입니다. Lambda·CloudTrail·Route 53·VPC Flow Logs 같은 서비스 로그와 JSON 로그의 필드를 **자동 탐지**하고 `@message`·`@logStream`·`@timestamp` 시스템 필드를 만듭니다. 사용하려면 **`logs:DescribeLogGroups` 와 `logs:FilterLogEvents` 권한**이 필요합니다.
- **Athena로 S3 로그** — CloudTrail 로그는 CloudTrail 콘솔에서 테이블을 만들거나 Athena 콘솔에서 수동으로 만들어 쿼리하며, **파티션 프로젝션 방식**도 있습니다. AWS 서비스 로그는 구조가 알려져 있어 파티션 스킴을 지정하기 쉽습니다.
- **작은 파일 문제** — EMR의 **S3DistCp** 유틸리티로 작은 파일을 큰 객체로 병합하는 방법이 소개됩니다.
- 📌 참고: "Centralized Logging with OpenSearch"는 **AWS Solution(솔루션 패키지)** 이며 **2026년 12월 종료 예정**입니다. 종료되는 것은 솔루션이고 **OpenSearch Service 자체가 아닙니다.** 이 솔루션 자체를 학습·출제 대상으로 삼지 마세요.

---

## ✍️ 시험 포인트

1. **알림 경로 식별이 먼저** — *"Glue 작업이 FAILED/TIMEOUT이 되면 코드를 고치지 않고 알려라"* → **EventBridge 규칙 → SNS**(서비스가 이미 상태 이벤트를 발행합니다). *"지표가 N분 연속 임계값 초과"* → **CloudWatch 경보**. *"로그에 특정 문자열이 나오면"* → **메트릭 필터 → 경보**.
2. **감사 증거 추적** — *"객체를 누가 삭제했는지 1년간"* → **trail + S3 보관 + S3 데이터 이벤트 활성화**. 이벤트 기록(90일·관리 이벤트·현재 리전)으로는 부족합니다. 비용이 걱정이면 **고급 이벤트 선택기로 범위를 좁힙니다.**
3. **신호 지표 고르기** — Kinesis는 **IteratorAge(Maximum)**, Lambda는 **Throttles·ConcurrentExecutions**, DynamoDB는 **쓰로틀 지표**, Redshift는 **WLM 큐 대기**, Glue는 **최대 필요 executor 대비 활성 executor**.
4. **누락 데이터 처리** — 기본은 **`missing`**. **오류가 날 때만 생기는 지표는 `notBreaching`**, 연속 보고 지표가 끊기면 문제인 경우는 `breaching`. `AWS/DynamoDB` 네임스페이스는 기본이 **`ignore`**.
5. **아카이브 방식** — **지속적으로** S3에 보내야 하면 **구독**, **한 번에 배치로** 내보내면 **`CreateExportTask`**. 문서가 지속 아카이브에는 내보내기를 권하지 않습니다.
6. **기본값 모음** — CloudTrail 데이터 이벤트 **꺼짐**, Redshift 감사 로깅 **꺼짐**, Glue 북마크 **Disable**, Glue `MaxConcurrentRuns` **1**, CloudWatch Logs 보존 **무기한**, EMR 자동 종료 유휴 **60분**, Redshift 동시성 확장 **꺼짐**.

---

## ⚠️ 흔한 함정

1. **이벤트 기록으로 1년치 감사** — 이벤트 기록은 **현재 리전 최근 90일·관리 이벤트**뿐입니다. 장기·완전 기록은 **trail**.
2. **데이터 이벤트가 기본으로 기록된다고 가정** — **기본 꺼짐**입니다. S3 객체 삭제 주체를 찾으려면 먼저 켜야 합니다.
3. **CloudTrail과 AWS Config 혼동** — "누가 호출했나"는 CloudTrail, "구성이 어떻게 바뀌었나"는 Config. **연속 변경은 구성 항목 하나로 합쳐질 수 있습니다.**
4. **Insights를 작업 상태 알림에 사용** — Insights는 **API 호출량·오류율의 기준선 이탈 탐지**이고 trail이 먼저 있어야 합니다. 작업 실패 알림이 아닙니다.
5. **CloudTrail 이벤트 중복을 버그로 오해** — **최소 1회 전달** 설계라 중복이 올 수 있고, 중복은 같은 **`eventID`** 입니다.
6. **내보내기와 구독 혼동** — 내보내기는 **비동기 배치**(활성 작업 수 한도), 구독은 **거의 실시간**이며 **Standard 클래스만**.
7. **IA 로그 클래스에 경보를 걸려 함** — IA는 **구독 필터·메트릭 필터·Live Tail을 쓸 수 없습니다.** 그리고 **클래스는 생성 후 변경 불가**입니다.
8. **메트릭 필터가 과거 로그에도 적용된다고 생각** — **소급 적용되지 않습니다.**
9. **보존을 설정하지 않음** — CloudWatch Logs 보존 **기본은 무기한**이라 비용이 계속 쌓입니다.
10. **Glue 연속 로깅을 모든 버전에서 켜야 한다고 생각** — **4.0 이하만** 해당하고 **5.0부터는 기본 제공**입니다.
11. **Glue 타임아웃을 버전과 무관하게 암기** — **4.0 이하 2,880분 / 5.0 이상 480분**. 문항이 버전을 말하지 않으면 수치를 근거로 삼지 마세요.
12. **EMR 로그를 종료 후에 찾음** — 노드 로컬 로그는 **클러스터 종료 후 사라집니다.** **S3 로그 경로**를 미리 지정해야 하고, **CLI·API로 만든 클러스터는 기본으로 켜지지 않습니다.**
13. **EMR 자동 종료를 모든 애플리케이션에서 기대** — **Presto·Trino·HBase 같은 비 YARN 애플리케이션에서는 지원되지 않습니다.**
14. **Lambda 쓰로틀을 `Errors`에서 찾음** — **쓰로틀된 요청은 `Invocations`·`Errors`에 잡히지 않습니다.** `Throttles` 를 보세요.
15. **`ConcurrentExecutions`를 Average로 봄** — 한도 접촉 여부는 **Maximum 통계**로 봅니다.
16. **IteratorAge 증가를 모두 같은 원인으로 처리** — **급증은 하류 API 실패 같은 일시 문제**, **완만한 증가는 소비자 처리 속도 부족**입니다.
17. **보존 기간 연장을 근본 해결로 생각** — 이터레이터 나이 문제의 **임시 방편**일 뿐입니다. 근본 해결은 **소비 로직 점검·샤드 증설**.
18. **DynamoDB `ThrottledRequests` 만 보고 판단** — **요청 단위 지표라 규모를 가릴 수 있어** 이벤트 단위 지표와 함께 봅니다.
19. **Redshift 이벤트 구독에 SNS FIFO 주제 사용** — **표준 주제만** 지원합니다.
20. **Redshift 동시성 확장이 기본 켜짐이라고 가정** — **기본 꺼짐**이며 WLM 큐별로 켭니다.
21. **압축 텍스트 파일이 분할된다고 가정** — **대부분 분할되지 않아 단일 split**으로 처리됩니다. Parquet·ORC는 항상 분할 가능합니다.
22. **파티션을 잘게 쪼갤수록 좋다고 생각** — **과도한 파티셔닝은 작은 파일을 낳고 S3 요청 한도로 쿼리가 실패**할 수 있습니다.
23. **"CloudWatch Events"를 다른 서비스로 오해** — 현재의 **EventBridge**입니다.
24. **로그 분석 도구를 용도와 무관하게 선택** — 즉석 운영 쿼리는 **Logs Insights**, S3 로그 SQL은 **Athena**, 실시간·전문 검색은 **OpenSearch Service**, 페타바이트 배치는 **EMR**.

---

## 🧪 자가 점검

**Q1.** AWS Glue ETL 작업이 실패하거나 타임아웃되면 운영팀 SNS 주제로 즉시 알려야 한다. 작업 스크립트는 수정할 수 없다. 가장 적절한 구성은?

<details><summary>정답 보기</summary>

**`Glue Job State Change` 이벤트(FAILED·TIMEOUT)를 매칭하는 EventBridge 규칙을 만들고 대상을 SNS 주제로 지정합니다.** Glue는 SUCCEEDED·FAILED·TIMEOUT·STOPPED 상태 변경 이벤트를 발행하므로 스크립트를 고치지 않고도 알림을 걸 수 있습니다. 공식 문서 예시도 "성공 시 Lambda 실행, 실패 시 SNS 통지"입니다.
</details>

**Q2.** DynamoDB `ThrottledRequests` 지표에 경보를 걸었더니 쓰로틀이 없는 평온한 시간대에 경보가 INSUFFICIENT_DATA로 흔들린다. 누락 데이터 처리를 어떻게 설정해야 하는가?

<details><summary>정답 보기</summary>

**`notBreaching`(누락을 정상으로 취급)으로 설정합니다.** `ThrottledRequests` 처럼 **오류가 날 때만 데이터 포인트가 생기는 지표**는 데이터가 없는 것이 정상입니다. 참고로 경보의 누락 데이터 처리 기본값은 `missing` 이지만, `AWS/DynamoDB` 네임스페이스 지표를 평가하는 경보는 기본이 `ignore` 입니다.
</details>

**Q3.** 특정 S3 버킷에서 어떤 IAM 주체가 객체를 삭제했는지 지난 6개월분을 조사해야 한다. CloudTrail은 기본 설정 그대로다. 왜 지금은 조사할 수 없으며 앞으로 무엇을 해야 하는가?

<details><summary>정답 보기</summary>

**이벤트 기록은 현재 리전 최근 90일의 관리 이벤트만 담고, S3 객체 수준 작업은 데이터 이벤트라 기본으로 기록되지 않기 때문입니다.** 앞으로는 **trail을 만들어 S3에 장기 보관**하고 **해당 버킷에 대한 데이터 이벤트를 활성화**해야 합니다. 데이터 이벤트는 대용량·추가 요금이므로 **고급 이벤트 선택기로 `eventName` 등을 필터링**해 범위를 좁히는 것이 비용 측면의 정답입니다.
</details>

**Q4.** Kinesis Data Streams 소비 애플리케이션의 `GetRecords.IteratorAgeMilliseconds` 가 며칠에 걸쳐 완만하게 증가하고 있다. 어떤 해석과 조치가 맞는가?

<details><summary>정답 보기</summary>

**완만한 증가는 소비자의 처리 속도가 유입을 따라가지 못한다는 뜻입니다**(반면 급증은 하류 API 실패 같은 일시적 문제를 가리킵니다). 이터레이터 나이가 **보존 기간의 50%** 를 넘으면 레코드 만료로 인한 데이터 손실 위험이 있습니다. **보존 기간 연장은 임시 방편**이고, 근본 해결은 **소비 로직 점검과 샤드 증설을 통한 병렬성 확대**입니다. 이 지표는 **Maximum 통계**로 경보를 거는 것이 권장됩니다.
</details>

**Q5.** 비용 절감을 위해 자주 조회하지 않는 애플리케이션 로그 그룹을 Infrequent Access 로그 클래스로 만들었다. 이후 "이 로그에 ERROR 패턴이 나오면 경보"를 걸려는데 메트릭 필터를 만들 수 없다. 원인은?

<details><summary>정답 보기</summary>

**IA 로그 클래스는 메트릭 필터를 지원하지 않기 때문입니다.** IA는 구독 필터·메트릭 필터·Live Tail·`GetLogEvents`/`FilterLogEvents` 를 쓸 수 없고 Logs Insights·교차 계정 기능은 지원합니다. 또한 **로그 클래스는 생성 후 변경할 수 없으므로** 경보가 필요하면 Standard 클래스 로그 그룹을 새로 만들어야 합니다.
</details>

---

**Q6 (원리).** 왜 이 Task의 문항은 거의 항상 **"지표냐, 이벤트냐, 로그냐"** 를 먼저 가르게 되어 있을까요?

<details><summary>정답 보기</summary>

**AWS의 관측 데이터가 세 가지 서로 다른 모양으로 나오기 때문입니다.** 지표는 **숫자 시계열**이라 임계값·통계·평가 기간이라는 언어로 다루고(CloudWatch 경보), 이벤트는 **구조화된 사건**이라 패턴 매칭으로 다루며(EventBridge 규칙), 로그는 **자유 텍스트**라 필터·쿼리로 다룹니다(메트릭 필터·Logs Insights). 요구사항 문장은 셋 중 어느 모양을 가리키는지 거의 항상 드러냅니다 — "N분 연속 초과"(숫자), "작업이 FAILED 되면"(사건), "이 문자열이 나오면"(텍스트). 보기를 비교하기 전에 **데이터의 모양부터 정하면** 엉뚱한 서비스를 고르지 않습니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. AWS CloudTrail FAQs — https://aws.amazon.com/cloudtrail/faqs/
2. CloudTrail concepts — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-concepts.html
3. Logging data events (CloudTrail User Guide) — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/logging-data-events-with-cloudtrail.html
4. Amazon CloudWatch FAQs — https://aws.amazon.com/cloudwatch/faqs/
5. Real-time processing of log data with subscriptions (CloudWatch Logs) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
6. CreateExportTask (CloudWatch Logs API Reference) — https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_CreateExportTask.html
7. CloudWatch Logs quotas — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/cloudwatch_limits_cwl.html
8. Log classes (CloudWatch Logs) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html
9. Creating metrics from log events using filters — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MonitoringLogData.html
10. StartQuery (CloudWatch Logs API Reference) — https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_StartQuery.html
11. Configuring how CloudWatch alarms treat missing data — https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html
12. A Practical Guide to Amazon CloudWatch Logs Cost Optimization (AWS Cloud Operations Blog) — https://aws.amazon.com/blogs/mt/a-practical-guide-to-amazon-cloudwatch-logs-cost-optimization/
13. Automating AWS Glue with EventBridge — https://docs.aws.amazon.com/glue/latest/dg/automating-awsglue-with-cloudwatch-events.html
14. Automating Step Functions event delivery with EventBridge — https://docs.aws.amazon.com/step-functions/latest/dg/eventbridge-integration.html
15. Amazon Redshift cluster event notification subscriptions — https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-event-notifications-subscribe.html
16. Amazon EMR events (Amazon EventBridge Events Reference) — https://docs.aws.amazon.com/eventbridge/latest/ref/events-ref-emr.html
17. Enabling continuous logging for AWS Glue 4.0 and earlier jobs — https://docs.aws.amazon.com/glue/latest/dg/monitor-continuous-logging-enable.html
18. Spark UI (AWS Glue console help panel) — https://docs.aws.amazon.com/help-panel/glue/latest/console/edit-job-details-sparkui-hp.html
19. Tracking processed data using job bookmarks (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
20. Monitoring for DPU capacity planning (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/monitor-debug-capacity.html
21. Jobs (AWS Glue API) — https://docs.aws.amazon.com/glue/latest/dg/aws-glue-api-jobs-job.html
22. Configure Amazon EMR cluster logging and debugging — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan-debugging.html
23. View Amazon EMR log files — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-manage-view-web-log-files.html
24. Using an auto-termination policy for Amazon EMR cluster cleanup — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-auto-termination-policy.html
25. Why does my Amazon EMR cluster terminate? (AWS re:Post) — https://repost.aws/knowledge-center/emr-cluster-terminated-unexpectedly
26. Database audit logging (Amazon Redshift Management Guide) — https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html
27. Top 10 performance tuning techniques for Amazon Redshift (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/top-10-performance-tuning-techniques-for-amazon-redshift/
28. Top 10 Performance Tuning Tips for Amazon Athena (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/top-10-performance-tuning-tips-for-amazon-athena/
29. Use partition projection with Amazon Athena — https://docs.aws.amazon.com/athena/latest/ug/partition-projection.html
30. Query AWS CloudTrail logs (Amazon Athena User Guide) — https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html
31. Monitor the Amazon Kinesis Data Streams service with Amazon CloudWatch — https://docs.aws.amazon.com/streams/latest/dev/monitoring-with-cloudwatch.html
32. Types of metrics for Lambda — https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics-types.html
33. CloudWatch throttling metrics (Amazon DynamoDB Developer Guide) — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TroubleshootingThrottling-cloudwatch.html
34. Logging options for Amazon S3 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/logging-with-S3.html
35. AWS Config terminology and concepts — https://docs.aws.amazon.com/config/latest/developerguide/config-concepts.html
36. AWS service logs (Centralized Logging with OpenSearch solution) — https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/aws-service-logs.html
37. REL06-BP05 Analyze logs (AWS Well-Architected Framework, Reliability Pillar) — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_monitor_aws_resources_storage_analytics.html
38. Troubleshooting Kinesis Data Streams consumers — https://docs.aws.amazon.com/streams/latest/dev/troubleshooting-consumers.html
39. Centralized Logging with OpenSearch — solution overview (종료 예정 공지) — https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/solution-overview.html
40. DEA-C01 공식 시험 가이드 도메인 3 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain3.html
