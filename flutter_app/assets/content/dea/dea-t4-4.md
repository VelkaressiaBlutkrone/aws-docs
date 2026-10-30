---
examGuideTaskId: dea-t4-4
certCode: DEA-C01
domain: 4
domainName: 데이터 보안 및 거버넌스
domainWeightPct: 18
title: 감사용 로그 준비 (CloudTrail·CloudWatch Logs·Lake·로그 분석)
coversTasks:
  - "4.4"
sources:
  - title: Security best practices in AWS CloudTrail (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html
  - title: Validating CloudTrail log file integrity (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html
  - title: Creating a trail for an organization (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html
  - title: Security OU – Log Archive account (AWS Security Reference Architecture) (공식 문서)
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/log-archive.html
  - title: CloudTrail Lake availability change (공식 문서)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html
  - title: Log classes (Amazon CloudWatch Logs) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html
  - title: Real-time processing of log data with subscriptions (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
  - title: Cross-account cross-Region log centralization (공식 문서)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs_Centralization.html
  - title: Query AWS CloudTrail logs (Amazon Athena User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html
  - title: DEA-C01 공식 시험 가이드 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
lastVerified: 2026-10-20
---

# 감사용 로그 준비 (CloudTrail·CloudWatch Logs·Lake·로그 분석)

> **커버하는 공식 Task** — DEA-C01 · 도메인 4 「데이터 보안 및 거버넌스」(18%) · **Task 4.4 감사용 로그 준비** (`dea-t4-4`)
> 이 문서의 관점은 **감사 대응을 위한 준비·보존·무결성·중앙화**입니다. 파이프라인 **운영·알림·성능 문제 해결**(이벤트 선택기, 메트릭/구독 필터 운영, 보존 자동화)은 **`dea-t3-3`** 이 다룹니다.
> ⚠️ **Skill 4.4.3은 CloudTrail Lake를 그대로 요구하지만, 공식 문서는 2026-05-31부터 신규 고객 중단을 알립니다.** 개념은 알아 두고 **상태도 함께** 기억하세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.4의 Skill 항목)

- [ ] **이벤트 기록(Event history)과 trail** 의 차이를 범위·보존으로 가른다
- [ ] **조직 trail** 을 누가 만들고 무엇을 기록하는지 안다
- [ ] **로그 파일 무결성 검증·S3 Object Lock·MFA Delete** 를 구분한다
- [ ] **AWS CLI 무결성 검증의 전제**를 설명한다
- [ ] **별도 Log Archive 계정**을 두는 이유를 설명한다
- [ ] **CloudWatch Logs의 KMS 암호화 시점**을 안다
- [ ] **로그 클래스**(Standard·IA·Delivery)의 차이와 구독 필터 제약을 안다
- [ ] **교차 계정 구독과 조직 중앙화 규칙**을 가른다
- [ ] **내보내기와 구독** 중 지속 아카이브에 맞는 것을 고른다
- [ ] **CloudTrail Lake의 EDS·보존·비용 모델**과 **현재 상태**를 함께 설명한다
- [ ] **Athena·Logs Insights·OpenSearch·EMR** 을 데이터 위치와 질의 특성으로 고른다

---

## 🎯 왜 중요한가

- 감사 문항은 **"바뀌지 않았음을 증명할 수 있는가"** 를 묻습니다. ⚠️ **무결성 검증은 "입증", Object Lock·MFA Delete는 "방지"** 로 역할이 다릅니다.
- **보존의 기본값**이 승부처입니다 — 이벤트 기록은 **최근 90일·관리 이벤트만**, trail의 S3 보관은 **무기한**, CloudWatch Logs도 **무기한**입니다.
- 중앙화는 **두 길**이 있습니다 — **교차 계정 구독(destination + 구독 필터)** 과 **조직 중앙화 규칙**. ⚠️ **중앙화 규칙은 과거 로그를 가져오지 않습니다.**
- 분석 서비스 선택은 **"데이터가 어디에 있는가"** 로 결정됩니다 — S3면 Athena, CloudWatch Logs면 Logs Insights, 전문 검색·실시간이면 OpenSearch, 페타바이트급 배치면 EMR.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **trail** | trail | CloudTrail 이벤트를 S3 등으로 지속 기록하는 설정 |
| **이벤트 기록** | event history | 설정 없이 볼 수 있는 최근 90일 관리 이벤트 목록 |
| **관리 이벤트** | management event | 리소스를 만들고 바꾸고 지우는 API 호출 |
| **데이터 이벤트** | data event | 객체 수준 작업 등 데이터에 대한 호출(기본 비활성·추가 비용) |
| **digest 파일** | digest file | 로그 파일의 해시·서명을 담아 무결성을 증명하는 파일 |
| **Object Lock** | S3 Object Lock | 객체의 삭제·덮어쓰기를 막는 S3 기능 |
| **구독 필터** | subscription filter | 로그 이벤트를 거의 실시간으로 다른 서비스에 전달하는 설정 |
| **destination** | destination | 교차 계정 전달을 받으려고 수신 계정이 만드는 대상 |
| **EDS** | event data store | CloudTrail Lake가 이벤트를 모아 두는 불변 컬렉션 |
| **로그 클래스** | log class | 로그 그룹의 기능·수집 단가 등급(Standard·IA·Delivery) |

---

## 📖 핵심 개념

### 1) CloudTrail로 API 호출 추적 — 감사 준비 {#cloudtrail}

감사에서 CloudTrail의 역할은 **"누가·언제·무엇을 했는가"를 변조되지 않은 상태로 오래 보관하고 증명**하는 것입니다. 이벤트에는 **요청자, 사용한 서비스, 수행한 작업, 작업 파라미터, 응답 요소**가 담깁니다.

- ⚠️ **이벤트 기록 ≠ 감사 기록** — 이벤트 기록은 **현재 리전 최근 90일의 관리 이벤트만** 보여 주며 **영구 기록이 아니므로 지속 기록에는 trail이 필요**합니다.
- **다중 리전·다중 계정 범위** — **모든 리전에 적용하는 trail은 새로 생기는 리전도 자동으로 기록**합니다. **조직 trail** 은 ⚠️ **관리 계정 또는 위임 관리자 계정에서 만들고 관리 계정과 모든 멤버 계정의 이벤트를 기록**합니다. 조직 trail을 쓰지 않으면 모든 계정에 trail을 만들고 **보관 버킷을 로그 아카이브 계정의 S3로 지정**합니다. 여러 계정의 로그를 **하나의 S3 버킷으로 모을 수도** 있습니다.
- **보관 계정 분리** — 별도 AWS 계정을 **로그 아카이브 계정**으로 만들고 조직 trail 도입을 고려합니다. AWS SRA의 **Log Archive 계정** 은 보안 관련 로그·백업을 수집·보관하는 전용 계정으로, **불변 스토리지이며 통제·자동화·모니터링되는 경로로만 접근**하도록 설계합니다(업무 분리).

**무결성 — "입증"과 "방지"를 가르세요.**

- **로그 파일 무결성 검증** 을 켜면 CloudTrail이 **digest 파일을 시간 단위로** 전달합니다. 해시는 **SHA-256**, 디지털 서명은 **SHA-256 with RSA** 입니다. digest 파일은 **로그 파일과 별도 폴더**에 놓여 세분화된 보안 정책을 적용할 수 있습니다.
- ⚠️ **AWS CLI는 CloudTrail이 전달한 위치의 파일을 검증**하고, **digest 파일이 참조하는 로그 파일만** 검증하며 ⚠️ **로컬로 내려받은 로그 파일은 CLI로 검증할 수 없습니다**(옮긴 로그는 직접 만든 도구로 검증).
- CloudTrail 로그 객체의 **무결성 보호·검증 수단은 로그 파일 무결성 검증과 S3 Object Lock 두 가지**입니다.
- **MFA Delete** 는 IAM 사용자 암호가 유출되어도 영구 삭제를 막는 추가 계층이지만 ⚠️ **수명 주기 구성과 함께 쓸 수 없습니다.**
- **보관** — trail 기본값은 로그를 **S3에 무기한 보관**하며 **S3 수명 주기 규칙**(예: 오래된 로그를 Glacier로 이동)으로 보존 정책을 정합니다. 로그 **가용성**은 **S3 Object Lock·객체 버전·수명 주기 규칙**으로 확보합니다.
- **암호화·접근 통제** — 기본적으로 로그 파일은 **S3 서버 측 암호화(SSE)** 로 암호화되고 **SSE-KMS는 추가 계층**입니다. SSE-KMS를 쓰면 로그를 읽을 때 **S3 읽기 권한과 KMS 복호화 권한이 모두** 필요합니다. ⚠️ **KMS 키가 비활성화되었거나 키 정책이 CloudTrail에 맞게 구성되지 않으면 CloudTrail이 로그를 전달하지 못합니다.** 버킷·KMS 정책에는 **`aws:SourceArn` 조건 키**를 넣는 것이 모범 사례입니다.
- **비용** — ⚠️ **데이터 이벤트는 trail 구성 시 기본 비활성이며 관리 이벤트와 달리 추가 비용**이 들고, **리전별 관리 이벤트 첫 사본은 무료**입니다.

| 통제 수단 | 무엇을 막거나 증명하나 | 제약·주의 | 시험 단서 |
|---|---|---|---|
| **로그 파일 무결성 검증** | 로그가 변경·삭제되었는지 **사후 확인(입증)** | digest는 **시간당** 전달, CLI는 **원래 S3 위치**의 파일만 | "변조되지 않았음을 **입증**" |
| **S3 Object Lock** | 무결성 보호 수단 중 하나, 가용성 확보 | 무결성 검증과 **별개 옵션** | "삭제·덮어쓰기 **방지**" |
| **MFA Delete** | 버전 상태 변경·객체 버전 삭제에 추가 인증 | ⚠️ **수명 주기 구성과 병용 불가** | "MFA", "영구 삭제 방지" |
| **SSE-KMS** | 암호화 + 키 정책 기반 2차 접근 통제 | **키 비활성·정책 오류 시 전달 실패** | "KMS 키 정책" |
| **Log Archive 계정 + 조직 trail** | 관리자 권한 분리, 전 계정 로그 중앙 보관 | 조직 trail은 **관리 계정/위임 관리자만** 생성 | "업무 분리", "중앙 보관" |
| **S3 수명 주기** | 보존 기간 정책 | ⚠️ **MFA Delete와 병용 불가** | "1년 지난 로그를 Glacier로" |

### 2) CloudWatch Logs에 애플리케이션 로그 저장 {#cloudwatch-logs}

- **보존** — 기본은 **무기한 저장**이며 **로그 그룹마다 언제든 보존 기간을 바꿀 수 있습니다.**
- **암호화** — 로그 그룹 데이터는 **항상 암호화**되며 기본은 CloudWatch Logs의 서버 측 암호화이고 **대안으로 AWS KMS**를 쓸 수 있습니다. KMS는 **로그 그룹 수준**에서 연결하며(생성 시 또는 이후) ⚠️ **연결 후 새로 수집되는 데이터만 해당 키로 암호화**됩니다. 키를 나중에 분리해도 **이미 그 키로 암호화된 데이터는 그대로 남고 CloudWatch Logs가 계속 읽을 수 있지만, 키가 나중에 비활성화되면 그 로그를 읽지 못합니다.** ⚠️ **대칭 KMS 키만** 지원합니다.
- **로그 클래스** — **Standard**(전체 기능)와 **Infrequent Access(IA)**(기능 일부·낮은 수집 단가, **임시 쿼리와 사후 포렌식 분석에 적합**)가 있고 ⚠️ **생성 후 클래스를 바꿀 수 없으며 두 클래스는 수집 비용만 다릅니다.** ⚠️ **구독 필터는 Standard 클래스 로그 그룹에서만 지원**됩니다. Lambda 로그를 S3나 Amazon Data Firehose로 보내는 용도의 **Delivery 클래스** 는 **Logs Insights 같은 기능을 제공하지 않습니다.**
- **교차 계정 공유** — **수신 계정이 Kinesis Data Streams를 감싸는 destination을 만들고 송신 계정이 구독 필터로 보냅니다.** 송신자는 단일 계정 또는 조직이 될 수 있고 ⚠️ **로그 그룹과 destination은 같은 리전**이어야 합니다. 한 조직의 여러 계정이 한 수신 계정으로 보내게 하는 정책을 줄 수 있지만 ⚠️ **송신 계정마다 구독 필터는 따로 만들어야** 합니다.
- **조직 단위 중앙화** — AWS Organizations와 연동한 **중앙화 규칙**으로 여러 멤버 계정·리전의 로그를 조직 내 중앙 계정으로 복제하며, 목적지 계정에서 **백업 리전**을 둘 수 있고 소스의 고객 관리형 KMS 암호화 로그 처리 방식을 고를 수 있습니다. ⚠️ **규칙 생성 이후 도착한 새 로그만 대상이며 과거 로그는 중앙화되지 않습니다.**
- **S3 내보내기와 구독** — 내보내기(`CreateExportTask`)는 **KMS 암호화 버킷과 보존 기간이 지정된 Object Lock 버킷도 지원**하지만, ⚠️ **지속 아카이브용으로 정기 내보내기를 쓰기보다 구독을 쓰라고 권고**합니다. 구독 필터는 **Kinesis Data Streams, Amazon Data Firehose, Lambda** 로 **거의 실시간**(보통 3분 미만) 전달합니다.
- **데이터 보호** — 민감 데이터를 자동 탐지해 마스킹하며, **상승된 IAM 권한이 있으면 마스킹되지 않은 데이터를 볼 수 있습니다.**

| 보관·전달 경로 | 지연·방식 | 적합한 경우 | 제약 |
|---|---|---|---|
| **로그 그룹에 그대로 보존** | 직접 조회, 보존 기간 설정 | 최근 로그 쿼리·경보 | **기본 무기한 보존** |
| **구독 필터 → Kinesis/Firehose/Lambda** | **거의 실시간**(보통 3분 미만) | **지속 아카이브**·외부 분석 전달 | ⚠️ **Standard 클래스만** |
| **`CreateExportTask` → S3** | 비동기 작업 | **일회성** 아카이브, KMS·Object Lock 버킷 | ⚠️ **지속 아카이브에는 비권장** |
| **교차 계정 구독(destination)** | 구독 필터로 거의 실시간 | 수신 보안 계정으로 전달 | ⚠️ **로그 그룹과 destination 같은 리전** |
| **중앙화 규칙(Organizations)** | 규칙 생성 이후 로그 복제 | 조직 전체·다중 리전 중앙화 | ⚠️ **과거 로그 미포함** |

### 3) CloudTrail Lake — 중앙 쿼리와 현재 상태 {#cloudtrail-lake}

- **개념** — CloudTrail Lake는 이벤트에 **SQL 기반 쿼리**를 실행합니다. 이벤트는 **이벤트 데이터 스토어(EDS)** 에 모이고 **EDS는 불변 컬렉션**이며, 보존 기간은 **1년 연장형 가격 옵션이면 최대 3,653일(약 10년), 7년형이면 최대 2,557일(약 7년)** 입니다. **조직의 이벤트(여러 리전·계정)를 조직 EDS** 에 둘 수 있습니다. **쿼리 결과는 7일까지** 볼 수 있고 **쿼리는 스캔한 데이터량으로 과금**됩니다. ⚠️ **EDS를 AWS Glue Data Catalog에 연합(federate)하면 Athena로 SQL 쿼리도** 할 수 있습니다. 기본으로 EDS의 모든 이벤트는 CloudTrail이 암호화하며 자체 KMS 키를 선택할 수 있습니다(⚠️ **연결 후 키를 제거·변경할 수 없음**).
- ⚠️ **현재 공식 상태(중요)** — AWS는 **2026-05-31부터 CloudTrail Lake를 신규 고객에게 열지 않습니다.** 기존 고객은 계속 사용하고 **Lake에는 중요한 버그 수정·보안 업데이트만** 제공되며, **CloudTrail 자체(trail, Insights, 집계 이벤트)는 영향이 없습니다.** **조직 EDS가 있으면 신규 멤버 계정·리전 확장까지 계속 동작하지만, 계정 단위 EDS만 있으면 조직에 새로 추가되는 계정의 수집은 지원하지 않습니다.** 문서는 **Lake 로그를 Amazon CloudWatch로 이전하길 권고**하고 **2023년 이전 데이터는 이전되지 않습니다.**
  - 📌 한편 Athena 문서의 CloudTrail 로그 쿼리 페이지는 **여전히 Lake를 대안으로 소개**합니다(문서 간 시차). 시험 가이드 v1.1은 **Skill 4.4.3에 Lake를 그대로 포함**하므로 **개념(EDS·SQL·보존·조직 통합·비용 모델)은 알아 두되 "신규 고객 중단" 상태를 함께** 기억하세요.
- **비용 모델** — **수집과 저장을 함께 과금**하며 수집은 **비압축 데이터 기준**, 저장은 **압축 데이터 기준**이고 쿼리는 선택해 분석한 **압축 데이터량 기준**입니다. 가격 옵션 2가지로 **1년 연장형은 월 사용량이 25 TB 미만이면, 7년형은 25 TB를 넘으면 권장**됩니다. ⚠️ **7년형 → 1년 연장형으로는 바꿀 수 있지만 1년 연장형 → 7년형으로는 바꿀 수 없습니다.**
- **trail+Athena와의 차이** — Athena는 **S3에 쌓인 CloudTrail 로그 파일을** CloudTrail 콘솔 또는 Athena 콘솔에서 **테이블을 만들어 직접 쿼리**합니다. Lake는 **S3 버킷 대신 데이터 레이크에 이벤트를 저장**해 더 풍부하고 빠른 쿼리를 하며 **Athena 없이 CloudTrail 콘솔에서** 쿼리합니다.

| 항목 | **trail + S3 + Athena** | **CloudTrail Lake** | **CloudWatch**(문서 권고 대체) |
|---|---|---|---|
| 저장소 | 로그 파일 S3(Object Lock·수명 주기·무결성 검증) | **EDS(불변 컬렉션)** | CloudWatch Logs 등 통합 저장 |
| 보존 상한 | S3 정책에 따름(**기본 무기한**) | **최대 3,653일 / 2,557일** | 로그 그룹 보존 설정 |
| 쿼리 | **Athena SQL**(테이블 직접 생성) | CloudTrail 콘솔 SQL, **Athena 연합 가능** | Logs Insights, OpenSearch 기반 분석 |
| 비용 | Athena는 **실행한 쿼리**에 과금 | **수집+저장 일체형 + 스캔량** | 문서는 비슷한 가격대라고 설명 |
| 상태 | **계속 지원** | ⚠️ **신규 고객 중단(2026-05-31)** | **마이그레이션 권고** |

### 4) 로그 분석 서비스 선택 {#log-analysis}

감사 로그 분석 서비스는 **데이터가 어디에 있는가**, **질의가 얼마나 자주·빨라야 하는가**, **검색 방식(SQL vs 전문 검색)** 으로 고릅니다.

| 서비스 | 데이터 위치 | 적합한 경우 | 비용·제약 | 시험 단서 |
|---|---|---|---|---|
| **Amazon Athena** | **S3의 로그**(CloudTrail 등) | S3 데이터를 **표준 SQL로 임시(ad-hoc) 쿼리** | 서버리스, **실행한 쿼리에 대해서만 과금** | "S3 로그", "서버리스 SQL" |
| **CloudWatch Logs Insights** | **CloudWatch Logs의 로그** | 대화형 로그 분석, **별도 설정·인프라 없이 즉시** | 종량제, **쿼리가 스캔한 수집 로그량**으로 과금 | "CloudWatch Logs의 로그를 바로 쿼리" |
| **Amazon OpenSearch Service** | 도메인에 **인덱싱한** 로그 | **실시간 로그 분석, 빈번한 쿼리, 전문(full-text) 검색** | 비실시간·가끔 쿼리는 Light Engine 옵션 | "전문 검색", "실시간 대시보드" |
| **CloudTrail Lake** | CloudTrail EDS | CloudTrail 이벤트 SQL 조사 | ⚠️ **신규 고객 중단** | "CloudTrail 이벤트 SQL" |

- **선택 규칙** — S3에 이미 있고 가끔 조사 → **Athena**. CloudWatch Logs에 이미 있고 즉석 조사 → **Logs Insights**. 실시간·반복 검색·전문 검색·시각화 대시보드 → **OpenSearch Service**.
- 📌 **Centralized Logging with OpenSearch** 솔루션은 **2026년 12월 종료 예정**이며, ⚠️ **종료되는 것은 솔루션이고 OpenSearch Service 자체가 아닙니다.**

### 5) 다양한 서비스 통합 로깅 {#integrated-logging}

- **중앙 S3 로그 저장소** — CloudTrail, VPC Flow Logs, Elastic Load Balancing, GuardDuty, AWS Config, AWS WAF 같은 서비스가 S3에 로그를 남기므로, **전용 계정의 중앙 S3 버킷에 모아 소수 버킷에서 통제·접근·업무 분리를 강제**합니다.
- **CloudWatch Logs 중앙화** — **조직 단위 중앙화 규칙** 또는 **교차 계정 구독**으로 모읍니다.
- **스트리밍 적재** — 구독 필터가 **Kinesis Data Streams·Amazon Data Firehose·Lambda** 로 전달하고, **VPC Flow Logs는 CloudWatch Logs, S3, Amazon Data Firehose** 로 게시할 수 있습니다. **Firehose는 S3, Amazon Redshift, OpenSearch Service, Splunk 등**으로 전달합니다. 📌 **Firehose의 이전 이름은 Amazon Kinesis Data Firehose** 입니다(개명).
- **OpenSearch로 AWS 서비스 로그 수집** — **Centralized Logging with OpenSearch** 솔루션이 AWS 서비스 로그를 OpenSearch 도메인으로 수집·정제하는 파이프라인과 시각화용 대시보드 템플릿을 제공합니다(위 종료 예정 참고).
- **대용량 후처리·분석** — ⚠️ **로그 파일 집합이 매우 크면 Amazon EMR 클러스터로 페타바이트급 분석**을 수행합니다. 보존 요구사항을 정해 S3 수명 주기를 적용합니다.

| 패턴 | 흐름 | 적합한 경우 | 제약 |
|---|---|---|---|
| **조직 trail → Log Archive S3** | 모든 계정 이벤트 → 전용 계정 버킷 | 감사 증적 중앙 보관 | KMS 정책 오류 시 **전달 실패** |
| **구독 필터 → Firehose → 대상** | 로그 → Firehose → S3·Redshift·OpenSearch·Splunk | 관리형 적재·변환 | **Standard 클래스만** |
| **VPC Flow Logs → CloudWatch Logs·S3·Firehose** | 게시 대상 선택 | 네트워크 트래픽 로그 | — |
| **중앙화 규칙** | 멤버 계정·리전 로그 → 중앙 계정 | 조직 전체 CloudWatch Logs | **과거 로그 제외** |
| **EMR** | 거대한 로그 집합 분석 | **페타바이트급** 분석 | EMR 클러스터를 직접 실행 |

---

## ✍️ 시험 포인트

1. **"90일을 넘겨 영구 기록"** → **trail**(이벤트 기록은 **현재 리전 최근 90일 관리 이벤트만**).
2. **변조 방지 감사 설계의 정석** — **관리 계정(또는 위임 관리자)의 멀티 리전 조직 trail → 별도 Log Archive 계정의 S3 + 로그 파일 무결성 검증 + 최소 권한 버킷 정책**, 필요하면 **SSE-KMS·S3 Object Lock**.
3. **"입증"과 "방지"를 가르기** — **입증 = 무결성 검증**(digest 시간당), **방지 = Object Lock·MFA Delete**. ⚠️ **MFA Delete는 수명 주기와 병용 불가**입니다.
4. **"다른 버킷으로 복사한 로그를 CLI로 검증"** → **불가**합니다. CLI는 **CloudTrail이 전달한 원래 위치**의 파일만 검증합니다.
5. **"KMS 키를 비활성화했더니 로그가 안 쌓인다"** → **CloudTrail이 로그를 전달하지 못하는 상태**입니다.
6. **"기존 로그도 새 KMS 키로 재암호화되나"** → **아닙니다.** CloudWatch Logs KMS는 **연결 이후 신규 수집분만**입니다.
7. **"임시 쿼리·사후 포렌식, 수집 단가를 낮추고 싶다"** → **IA 클래스**. 단 ⚠️ **구독 필터는 Standard만**이고 **클래스는 변경 불가**입니다.
8. **"계속 S3로 아카이브"** → **구독**(내보내기 `CreateExportTask` 는 **일회성·비동기**이며 지속 아카이브에는 비권장).
9. **"조직 전체를 규칙 하나로"** → **중앙화 규칙**. ⚠️ **과거 로그는 포함되지 않습니다.** "다른 계정으로 실시간 전달"은 **destination + 송신 계정별 구독 필터(같은 리전)**.
10. **"새 계정이 자동 포함되나"** → **조직 trail은 멤버 계정 전부**, Lake는 **조직 EDS면 지원·계정 EDS면 미지원**입니다.
11. **분석 서비스는 데이터 위치로** → S3 = **Athena**, CloudWatch Logs = **Logs Insights**, 전문 검색·실시간 = **OpenSearch**, 페타바이트 배치 = **EMR**, 관리형 적재 = **Firehose**.

---

## ⚠️ 흔한 함정

1. **이벤트 기록으로 1년 전 활동을 조사하려 함** — **최근 90일·관리 이벤트·현재 리전**뿐입니다.
2. **이벤트 기록이 데이터 이벤트도 보여 준다고 생각** — **관리 이벤트로 한정**됩니다.
3. **데이터 이벤트가 기본으로 켜져 있다고 생각** — ⚠️ **기본 비활성이며 추가 비용**이 듭니다(관리 이벤트 첫 사본은 리전별 무료).
4. **멤버 계정마다 trail을 만들어야 한다고 생각** — **조직 trail** 이 관리 계정과 모든 멤버 계정을 기록합니다.
5. **조직 trail을 멤버 계정에서 만들려 함** — **관리 계정 또는 위임 관리자 계정**에서 만듭니다.
6. **무결성 검증이 삭제를 "막아 준다"고 생각** — **사후에 변경·삭제를 확인(입증)** 할 뿐입니다. 막는 것은 Object Lock·MFA Delete입니다.
7. **로컬에 내려받은 로그를 CLI로 검증** — ⚠️ **불가**합니다.
8. **digest 파일이 참조하지 않는 로그도 CLI가 검증한다고 생각** — **참조하는 로그만** 검증합니다.
9. **MFA Delete와 S3 수명 주기를 함께 설정** — ⚠️ **병용할 수 없습니다.**
10. **trail의 S3 보관이 자동으로 만료된다고 생각** — **기본 무기한**이며 **수명 주기 규칙**으로 정합니다.
11. **SSE-KMS 로그를 S3 권한만으로 읽으려 함** — **S3 읽기 + KMS 복호화 권한 둘 다** 필요합니다.
12. **CloudWatch Logs 보존이 기본 며칠이라고 생각** — ⚠️ **기본 무기한**입니다.
13. **KMS를 로그 그룹에 연결하면 기존 로그까지 재암호화된다고 생각** — **신규 수집분만**입니다.
14. **비대칭 KMS 키를 로그 그룹에 쓰려 함** — ⚠️ **대칭 키만** 지원합니다.
15. **IA 클래스에 구독 필터를 붙이려 함** — ⚠️ **Standard 클래스만** 지원합니다.
16. **로그 클래스를 나중에 바꾸려 함** — ⚠️ **생성 후 변경 불가**입니다.
17. **Delivery 클래스에서 Logs Insights를 쓰려 함** — **제공하지 않습니다**(Lambda 로그를 S3/Firehose로 보내는 용도).
18. **교차 계정 구독에서 로그 그룹과 destination의 리전이 달라도 된다고 생각** — ⚠️ **같은 리전**이어야 합니다.
19. **조직 정책 하나로 구독 필터까지 자동 생성된다고 생각** — ⚠️ **송신 계정마다 구독 필터를 따로** 만듭니다.
20. **중앙화 규칙이 과거 로그를 가져온다고 생각** — ⚠️ **규칙 생성 이후 로그만**입니다.
21. **지속 아카이브로 정기 내보내기를 설정** — **구독을 권고**합니다(내보내기는 일회성·비동기).
22. **CloudTrail Lake가 S3 버킷에 저장한다고 생각** — **EDS(데이터 레이크)** 에 저장하며 Athena 없이 CloudTrail 콘솔에서 쿼리합니다.
23. **EDS의 KMS 키를 나중에 바꾸려 함** — ⚠️ **연결 후 제거·변경할 수 없습니다.**
24. **계정 단위 EDS로 새 멤버 계정까지 수집된다고 생각** — ⚠️ **조직 EDS만** 지원합니다.
25. **1년 연장형에서 7년형으로 전환하려 함** — ⚠️ **불가**합니다(역방향만 가능).
26. **Lake 중단이 CloudTrail 전체 중단이라고 생각** — **trail·Insights·집계 이벤트는 영향 없습니다.**
27. **Lake 로그를 CloudWatch로 이전하면 전체가 옮겨진다고 생각** — ⚠️ **2023년 이전 데이터는 이전되지 않습니다.**
28. **CloudWatch Logs의 로그를 Athena로 바로 쿼리하려 함** — Athena는 **S3**, CloudWatch Logs는 **Logs Insights** 입니다.
29. **OpenSearch Service 자체가 종료된다고 생각** — 종료 예정은 **Centralized Logging with OpenSearch 솔루션**입니다.
30. **Kinesis Data Firehose와 Amazon Data Firehose를 다른 서비스로 생각** — **같은 서비스의 개명**입니다.

---

## 🧪 자가 점검

**Q1.** 여러 계정·리전의 API 활동을 한 곳에 보관하고, 로그가 사후에 바뀌거나 지워지지 않았음을 입증해야 한다. 보안팀만 접근할 수 있어야 한다. 어떻게 설계하는가?

<details><summary>정답 보기</summary>

**관리 계정(또는 위임 관리자 계정)에서 멀티 리전 조직 trail을 만들어 별도 Log Archive 계정의 S3 버킷으로 보내고, 로그 파일 무결성 검증을 켜고 최소 권한 버킷 정책을 적용합니다**(필요하면 SSE-KMS·S3 Object Lock). 조직 trail은 **관리 계정과 모든 멤버 계정의 이벤트를 기록**하고, 모든 리전에 적용하면 **새로 생기는 리전도 자동 기록**합니다. **이벤트 기록은 최근 90일·관리 이벤트만**이라 감사 기록이 될 수 없고, ⚠️ **MFA Delete는 수명 주기 구성과 병용할 수 없습니다.**
</details>

**Q2.** 감사인이 S3에 보관된 CloudTrail 로그를 다른 분석용 버킷으로 복사한 뒤 AWS CLI로 무결성을 검증하려 한다. 결과는?

<details><summary>정답 보기</summary>

**검증할 수 없습니다.** ⚠️ **AWS CLI는 CloudTrail이 전달한 위치의 파일을 검증**하며, **digest 파일이 참조하는 로그 파일만** 검증합니다. **로컬로 내려받거나 다른 위치로 옮긴 로그는 CLI로 검증할 수 없고**, 그런 경우에는 직접 만든 검증 도구를 써야 합니다. 참고로 해시는 **SHA-256**, 서명은 **SHA-256 with RSA** 이고 digest 파일은 **시간 단위**로 전달되며 **로그 파일과 별도 폴더**에 놓입니다.
</details>

**Q3.** 애플리케이션 로그를 고객 관리형 KMS 키로 암호화하려 한다. 기존 로그 그룹에 키를 연결하면 어떻게 되는가?

<details><summary>정답 보기</summary>

**연결 이후 새로 수집되는 데이터만 해당 키로 암호화됩니다**(기존 로그는 재암호화되지 않습니다). 키를 나중에 분리해도 **이미 그 키로 암호화된 데이터는 그대로 남고 CloudWatch Logs가 계속 읽을 수 있지만, 키가 비활성화되면 그 로그를 읽지 못합니다.** KMS는 **로그 그룹 수준**에서 연결하며 ⚠️ **대칭 KMS 키만** 지원합니다.
</details>

**Q4.** 보안 계정으로 여러 멤버 계정의 CloudWatch Logs를 지속적으로 모으려 한다. 선택지는 교차 계정 구독과 조직 중앙화 규칙이다. 무엇을 알아야 하는가?

<details><summary>정답 보기</summary>

**교차 계정 구독은 수신 계정이 destination을 만들고 송신 계정마다 구독 필터를 따로 만들며 로그 그룹과 destination이 같은 리전이어야 합니다. 조직 중앙화 규칙은 Organizations 연동으로 여러 계정·리전을 한 번에 복제하지만 ⚠️ 규칙 생성 이후 도착한 새 로그만 대상이고 과거 로그는 중앙화되지 않습니다.** 또 지속 아카이브가 목적이라면 **정기 내보내기(`CreateExportTask`)보다 구독을 권고**합니다(내보내기는 일회성·비동기).
</details>

**Q5.** 여러 계정·리전의 CloudTrail 이벤트를 SQL로 중앙 조사하려 한다. 2026-10 현재 공식 문서를 근거로 무엇을 고려해야 하는가?

<details><summary>정답 보기</summary>

**개념상 CloudTrail Lake(EDS·조직 EDS·최대 3,653일/2,557일 보존)가 이 용도이지만, 공식 문서는 2026-05-31부터 신규 고객에게 열지 않는다고 알리고 CloudWatch로의 이전을 권고합니다.** 그래서 신규 구축의 대안은 **조직 trail → S3 → Athena** 또는 **CloudWatch** 입니다. ⚠️ **CloudTrail 자체(trail·Insights·집계 이벤트)는 영향이 없고**, 기존 고객 중 **계정 단위 EDS만 있으면 조직에 새로 추가되는 계정의 수집이 지원되지 않습니다.** 시험 가이드 v1.1은 Skill 4.4.3에 Lake를 그대로 포함하므로 **개념과 상태를 함께** 기억해야 합니다.
</details>

---

**Q6 (원리).** 왜 감사 로그 설계에서 "어느 계정에 두는가"가 암호화나 보존 기간보다 먼저 결정될까요?

<details><summary>정답 보기</summary>

**로그를 지울 수 있는 사람이 로그를 만드는 사람과 같으면, 그 뒤의 어떤 통제도 증거력을 보장하지 못하기 때문입니다.** 무결성 검증은 **변경을 사후에 알려 줄 뿐 막지 못하고**, Object Lock·MFA Delete도 결국 **그 계정에서 권한을 가진 주체**가 설정을 바꿀 수 있습니다. 그래서 AWS SRA는 **전용 Log Archive 계정**을 두고 **통제·자동화·모니터링되는 경로로만 접근**하게 설계합니다 — 이것이 **업무 분리**이고, 조직 trail이 **관리 계정 또는 위임 관리자에서만** 만들어지는 이유와 같은 논리입니다. 계정 경계가 먼저 정해지면 그 위의 선택(SSE-KMS로 두 번째 통제를 걸까, 수명 주기로 Glacier에 보낼까)은 **모두 같은 경계 안의 세부 사항**이 됩니다. 순서를 뒤집으면 암호화와 보존을 열심히 설정해도 **같은 계정의 관리자가 전부 되돌릴 수 있는** 설계가 남습니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-19 · 저작: 2026-10-20 · 사람 검수 전)

1. AWS CloudTrail FAQs — https://aws.amazon.com/cloudtrail/faqs/
2. Security best practices in AWS CloudTrail — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html
3. Validating CloudTrail log file integrity — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-intro.html
4. Validating CloudTrail log file integrity with the AWS CLI — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-validation-cli.html
5. Creating a trail for an organization — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html
6. Configure AWS KMS key policies for CloudTrail — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-kms-key-policy-for-cloudtrail.html
7. Security OU – Log Archive account (AWS Security Reference Architecture) — https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/log-archive.html
8. CloudTrail Lake availability change — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake-service-availability-change.html
9. Working with AWS CloudTrail Lake — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html
10. AWS CloudTrail pricing — https://aws.amazon.com/cloudtrail/pricing/
11. Query AWS CloudTrail logs (Amazon Athena User Guide) — https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html
12. Amazon CloudWatch FAQs — https://aws.amazon.com/cloudwatch/faqs/
13. Encrypt log data in CloudWatch Logs using AWS Key Management Service — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
14. Log classes (Amazon CloudWatch Logs) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html
15. Real-time processing of log data with subscriptions — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/Subscriptions.html
16. Cross-account cross-Region log data sharing using Amazon Kinesis Data Streams — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CrossAccountSubscriptions-Kinesis.html
17. Cross-account cross-Region log centralization — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatchLogs_Centralization.html
18. CreateExportTask (Amazon CloudWatch Logs API Reference) — https://docs.aws.amazon.com/AmazonCloudWatchLogs/latest/APIReference/API_CreateExportTask.html
19. What is Amazon Athena? — https://docs.aws.amazon.com/athena/latest/ug/what-is.html
20. AWS service logs (Centralized Logging with OpenSearch) — https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/aws-service-logs.html
21. Welcome (Amazon Data Firehose API Reference) — https://docs.aws.amazon.com/firehose/latest/APIReference/Welcome.html
22. REL06-BP05 Analyze logs (AWS Well-Architected Framework, Reliability Pillar) — https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_monitor_aws_resources_storage_analytics.html
23. Build your own centralized log analytics platform with Amazon OpenSearch Service in 20 minutes (solution overview) — https://docs.aws.amazon.com/solutions/latest/centralized-logging-with-opensearch/solution-overview.html
