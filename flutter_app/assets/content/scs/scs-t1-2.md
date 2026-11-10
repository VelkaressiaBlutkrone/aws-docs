---
examGuideTaskId: scs-t1-2
certCode: SCS-C03
domain: 1
domainName: 탐지
domainWeightPct: 16
title: 로깅 솔루션 설계 (소스 파악·조직 추적·데이터 레이크·로그 분석·정규화·네트워크 로그)
coversTasks:
  - "1.2"
sources:
  - title: Creating a trail for an organization (AWS CloudTrail)
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html
  - title: CloudWatch Logs agent reference (deprecated)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html
  - title: "Quick Start: Install and configure the CloudWatch Logs agent on a running EC2 Linux instance"
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html
  - title: Functionality deprecated in AL2 and removed in AL2023
    url: https://docs.aws.amazon.com/linux/al2/ug/deprecated-al2.html
  - title: Analyzing log data with CloudWatch Logs Insights
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
  - title: Collecting data from AWS services in Security Lake
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/internal-sources.html
  - title: Collecting data from custom sources in Security Lake
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html
  - title: AWS Transit Gateway Flow Logs
    url: https://docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html
  - title: Resolver query logging (Amazon Route 53)
    url: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
lastVerified: 2026-11-08
  - title: How CloudTrail works — 기록되는 이벤트와 주체
    url: https://docs.aws.amazon.com/awscloudtrail/latest/userguide/how-cloudtrail-works.html
  - title: What is Amazon Athena? — S3 데이터를 표준 SQL로 조회
    url: https://docs.aws.amazon.com/athena/latest/ug/what-is.html
  - title: What is Amazon Security Lake? — OCSF·Parquet 정규화
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html
---

# 로깅 솔루션 설계 (소스 파악·조직 추적·데이터 레이크·로그 분석·정규화·네트워크 로그)

> **커버하는 공식 Task** — SCS-C03 · 도메인 1 「탐지」(16%) · **작업 1.2 로깅 솔루션 설계 및 구현** (`scs-t1-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 6개(1.2.1~1.2.6)를 모두 덮습니다. 기술이 **여섯 개**로 도메인 1에서 가장 많고, 그만큼 문항도 많이 나옵니다.

> ⚠️⚠️ **공식 가이드가 드는 예시 하나가 이미 폐지된 기능입니다.** `기술 1.2.2`의 예시에 "Amazon CloudWatch Logs 에이전트 구성"이 있는데, 그 **구 에이전트는 공식적으로 폐지(deprecated)**됐고 **Amazon Linux 2023에는 패키지가 아예 없습니다.** 현행 축은 **통합 CloudWatch 에이전트**입니다. 아래 2절이 둘을 가릅니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 요구 사항에서 출발해 **어떤 로그 소스를 확보해야 하는지** 결정한다
- [ ] **조직 추적**의 성질(다중 리전 기본·옵트인 리전 조합·멤버 계정 권한)을 설명한다
- [ ] **통합 CloudWatch 에이전트**와 폐지된 구 로그 에이전트를 구분한다
- [ ] Security Lake의 **기본 지원 소스**와 **사용자 지정 소스 요건**을 구분한다
- [ ] Logs Insights의 **쿼리 언어 3종**과 각각의 한도·전용 기능을 고른다
- [ ] 정규화·상관을 위해 OpenSearch Service · Lambda · Managed Grafana를 **어느 층에 둘지** 정한다
- [ ] VPC · 전송 게이트웨이 · Route 53 Resolver 로그가 **각각 무엇을 담는지** 말한다
- [ ] Resolver 쿼리 로그가 **캐시 응답을 남기지 않는다**는 성질을 설계에 반영한다

## 🎯 왜 중요한가

로깅은 **탐지의 재료**입니다. 작업 1.1이 "무엇을 켜서 알아낼까"였다면 이 작업은 "그 신호를 어디에 어떻게 쌓을까"입니다. 그리고 Specialty 문항이 가장 좋아하는 형태가 **"이 로그로는 그 사실을 알 수 없다"**입니다.

예를 들어 "어떤 인스턴스가 어떤 도메인을 조회했는지"는 VPC 흐름 로그로 알 수 없습니다. 흐름 로그는 IP 트래픽을 담고 **DNS 질의 이름은 Route 53 Resolver 쿼리 로그**에 있습니다. 반대로 "전송 게이트웨이를 지나간 트래픽"은 VPC 흐름 로그가 아니라 **전송 게이트웨이 흐름 로그**입니다.

이 문서는 **소스별로 "담는 것"과 "담지 않는 것"**을 먼저 고정하고, 그 뒤에 저장·분석 층을 다룹니다.

## ⚡ 시험 직전 요약

- **콘솔로 만든 조직 추적은 전부 다중 리전**입니다. 단일 리전 조직 추적은 **CLI로만** 만들 수 있습니다
- ⚠️ **다중 리전 조직 추적의 홈 리전이 옵트인 리전이면**, 그 리전을 옵트인하지 않은 멤버 계정은 **활동을 그 추적으로 보내지 않습니다**
- **리소스 검증이 실패해도 CloudTrail은 멤버 계정에 조직 추적을 만듭니다**(잘못된 버킷 정책 등). 멤버 계정은 `get-trail-status`로 실패를 봅니다
- 멤버 계정 사용자는 조직 추적을 **볼 수는 있지만** 끄거나 바꿀 수 없습니다
- **구 CloudWatch Logs 에이전트는 폐지**됐고 **IMDSv2를 쓰면 통합 에이전트가 필수**입니다
- Security Lake **기본 지원 소스는 6종**이고, **`CloudTrail 관리 이벤트`만 별도 로깅 구성이 필요**합니다
- **사용자 지정 소스는 보내기 전에 OCSF로 변환해야** 하고 **Parquet·파티셔닝·5분~1일** 요건이 있습니다. **계정당 50개**가 상한입니다
- Logs Insights는 **쿼리 언어 3종**이고 **동시 실행 한도가 다릅니다**(QL 100 / PPL·SQL 각 15)
- **`filterIndex`와 비교 쿼리는 Logs Insights QL 전용**입니다
- **Resolver 쿼리 로그는 고유 쿼리만 남깁니다** — 캐시에서 응답한 쿼리는 기록되지 않습니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **추적(trail)** | CloudTrail 이벤트를 S3·CloudWatch Logs로 **전달하는 구성**. 이벤트 기록 자체와 다릅니다 |
| **조직 추적** | 조직의 **모든 계정 이벤트**를 담는 추적. 관리 계정 또는 위임 관리자가 만듭니다 |
| **통합 CloudWatch 에이전트** | 로그와 지표를 **함께** 수집하는 현행 에이전트(`amazon-cloudwatch-agent`) |
| **데이터 레이크** | 분석을 전제로 원시 데이터를 모아 둔 저장소. Security Lake는 **내 계정 S3**에 만듭니다 |
| **OCSF** | 벤더 중립 보안 스키마. Security Lake가 수집 데이터를 이 스키마로 정규화합니다 |
| **흐름 로그(flow log)** | 네트워크 **IP 트래픽의 메타데이터** 레코드. 패킷 내용이 아닙니다 |
| **Resolver 쿼리 로그** | VPC에서 발생한 **DNS 질의와 응답** 기록 |
| **필드 인덱스** | Logs Insights에서 자주 쓰는 필드를 색인해 **스캔량을 줄이는** 기능 |

## 📖 핵심 개념

### 1) 요구 사항에서 로그 소스를 정한다 (기술 1.2.1) {#sources}

공식 기술 문구는 "요구 사항에 따라 로그 수집과 스토리지를 **확보할** 소스 파악"입니다. 소스를 고르는 축은 셋입니다.

| 축 | 질문 | 예 |
|---|---|---|
| **누가 무엇을 했나** | API 호출의 주체·대상·조건 | CloudTrail |
| **무엇이 어디로 흘렀나** | 네트워크 메타데이터 | VPC·전송 게이트웨이 흐름 로그 |
| **무엇을 찾으려 했나** | 이름 해석 | Route 53 Resolver 쿼리 로그 |

여기에 **애플리케이션 층**(Lambda·API Gateway·CloudFront 로깅 — 작업 1.3에서 다룹니다)과 **구성 변경**(AWS Config)이 더해집니다.

⚠️ 이 단계에서 자주 빠지는 질문이 **보존 기간**과 **무결성**입니다. "사고 뒤 90일 전 기록을 봐야 한다"는 요구가 있으면 **쌓는 곳**(S3 수명 주기)과 **쿼리 수단**(Athena)까지 한 묶음으로 설계해야 합니다.

### 2) AWS 서비스와 애플리케이션 로깅을 구성한다 (기술 1.2.2) {#configure}

#### 2-1. 조직 추적 — 공식이 적는 성질 다섯

- **관리 계정이 위임 관리자를 지정**해 조직 추적을 만들거나 관리하게 할 수 있습니다. 조직 추적을 만들려면 **관리 계정 또는 위임 관리자 계정**으로 로그인해야 합니다
- 기존 추적을 **조직에 적용**해 조직 추적으로 바꿀 수도 있습니다
- ⚠️⚠️ **콘솔로 만든 조직 추적은 전부 다중 리전**입니다. **단일 리전 조직 추적은 CLI로만** 만들 수 있고, 그때는 그 추적의 **홈 리전** 활동만 기록합니다
- ⚠️⚠️ **옵트인 리전 조합이 네 갈래**입니다. 가장 자주 틀리는 것이 마지막입니다 — **다중 리전 조직 추적의 홈 리전이 옵트인 리전이면, 그 리전을 활성화하지 않은 멤버 계정은 활동을 그 추적으로 보내지 않습니다.** 공식 예시가 유럽(스페인)입니다
- ⚠️ **리소스 검증이 실패해도 CloudTrail은 멤버 계정에 추적을 만듭니다.** 실패 예로 잘못된 S3 버킷 정책·잘못된 SNS 주제 정책·CloudWatch Logs 로그 그룹 전달 불가·KMS 키 암호화 권한 부족이 열거됩니다. 멤버 계정은 콘솔의 추적 상세나 **`get-trail-status`**로 실패를 볼 수 있습니다

그 밖에 기억할 것 — 서비스 연결 역할은 **`AWSServiceRoleForCloudTrail`**이고, 계정이 조직에 추가되면 추적과 역할이 그 계정에 추가돼 **자동으로 로깅이 시작**됩니다. 계정이 조직에서 빠지면 추적과 역할이 삭제되지만 **이미 쌓인 로그 파일은 S3에 남습니다.** ⚠️ 그리고 **관리 계정이 관리 계정 자격을 잃으면 그 계정이 만든 조직 추적은 비조직 추적이 됩니다.**

⚠️ 멤버 계정 사용자는 `describe-trails` 등으로 조직 추적을 **볼 수 있지만** 삭제·로깅 중단·이벤트 유형 변경 등 **어떤 변경도 할 수 없습니다.** 「전용 로깅 계정」 설계가 성립하는 근거가 이것입니다.

#### 2-2. 로그 에이전트 — 현행과 폐지된 것

| | **통합 CloudWatch 에이전트** | **구 CloudWatch Logs 에이전트** |
|---|---|---|
| 수집 | **로그와 지표를 함께** | 로그만 |
| 상태 | **현행** | ⚠️ **폐지(deprecated)** |
| IMDSv2 | 지원 | ⚠️ **미지원 — IMDSv2를 쓰면 통합 에이전트가 필수** |
| 플랫폼 | 현행 플랫폼 | Python **2.6~3.5**만 지원 · **AL2에서 폐지, AL2023에는 패키지 없음** |

공식 문서가 직접 적습니다 — "**The older logs agent is deprecated**", 그리고 IMDSv2를 쓰지 않더라도 "**통합 에이전트를 쓰는 것을 강력히 권장**"합니다. ⚠️ 공식 시험 가이드 `기술 1.2.2`가 "CloudWatch Logs 에이전트 구성"을 예시로 들지만, **지금 설계하는 문항의 답은 통합 에이전트**입니다.

#### 2-3. 전용 로깅 계정

조직 추적의 성질(멤버 계정이 바꿀 수 없다)과 S3 버킷 정책을 묶으면 **로그를 별도 계정에 쌓고 워크로드 계정에는 쓰기 권한만 주는** 구조가 됩니다. 여기에 작업 1.1의 **CloudWatch 크로스 계정 관측성**(모니터링 계정 ↔ 소스 계정)을 더하면 운영 로그까지 중앙에서 볼 수 있습니다. ⚠️ 두 기능은 **다른 것**입니다 — 조직 추적은 **CloudTrail 이벤트의 전달**이고, 크로스 계정 관측성은 **CloudWatch 지표·로그 그룹 등의 조회**입니다.

### 3) 로그 스토리지와 데이터 레이크 (기술 1.2.3) {#lake}

Amazon Security Lake는 **내 계정의 S3 버킷**에 보안 데이터 레이크를 만들고 **데이터 소유권을 내게 남깁니다.** 수집한 데이터를 **Apache Parquet** 형식과 **OCSF** 스키마로 변환합니다.

**기본 지원 AWS 소스 6종**

- CloudTrail **관리 및 데이터 이벤트(S3, Lambda)**
- EKS 감사 로그
- **Route 53 Resolver 쿼리 로그**
- **Security Hub CSPM 조사 결과**
- VPC 흐름 로그
- **WAFv2 로그**

- ⚠️⚠️ **그 서비스들에서 로깅을 따로 구성할 필요가 없습니다 — `CloudTrail 관리 이벤트`만 예외입니다.** 이미 로깅을 구성해 뒀어도 바꿀 필요가 없고, Security Lake는 **"독립적이고 중복된 이벤트 스트림"**으로 직접 당겨옵니다
- **롤업 리전**으로 여러 리전 데이터를 통합해 데이터 레지던시 요건에 맞출 수 있습니다
- 구독자는 **지정한 소스와 리전에서만** 소비하고, **새 객체 알림을 받거나** **쿼리**합니다. 뒤에서 EventBridge · AWS Glue 크롤러와 Data Catalog · Lake Formation 테이블 · Lambda를 씁니다

**타사 통합 = 사용자 지정 소스.** 요건이 분명합니다.

- ⚠️⚠️ **보내기 전에 소스가 OCSF로 변환해야 합니다.** Security Lake가 대신 변환해 주는 것은 **기본 지원 AWS 소스**뿐입니다
- 각 S3 객체는 **Parquet**이어야 하고, 한 객체 안의 레코드는 **같은 OCSF 이벤트 클래스**여야 합니다
- 파티셔닝은 `source location/region=…/accountId=…/eventDay=yyyyMMdd/`이고, ⚠️ **AWS 밖 계정의 레코드는 `external` 같은 문자열을 권장**합니다
- 전송 주기는 **5분 ~ 1 이벤트 일** 사이이고(256 MB 초과면 더 자주 가능), 객체 안에서 **시간순 정렬**이 권장됩니다
- ⚠️ **계정당 사용자 지정 로그 소스는 최대 50개**입니다
- Security Lake가 대신 해 주는 것 — 고유 접두사, 쓰기용 IAM 역할(권한 경계는 관리형 정책 **`AmazonSecurityLakePermissionsBoundary`**), Lake Formation 테이블, Glue 크롤러

### 4) 로그를 분석한다 (기술 1.2.4) {#analyze}

#### 4-1. CloudWatch Logs Insights — 쿼리 언어가 셋이다

| 언어 | 성질 | 동시 실행 한도 |
|---|---|---|
| **Logs Insights QL** | 전용 언어. 단순하지만 강력한 명령 몇 개 | **계정당 100개**(대시보드 쿼리 포함) |
| **OpenSearch PPL** | 파이프(`\|`)로 명령을 잇는 방식 | **15개** |
| **OpenSearch SQL** | 선언적. `SELECT`·`FROM`·`WHERE`·`GROUP BY`·`HAVING` + **로그 그룹 간 `JOIN`**·하위 쿼리 | **15개** |

- ⚠️⚠️ **`filterIndex` 명령은 Logs Insights QL 전용**이고 **비교 쿼리**(이전 기간과 비교)도 **QL 전용**입니다
- ⚠️ SQL·PPL에서 **특수문자가 든 필드는 백틱으로 감싸야** 합니다(`@message`·`Operation.Export`·`Test::Field`). 순수 알파벳 필드는 필요 없습니다
- 공통 기능 — **필드 자동 발견**(Route 53·Lambda·CloudTrail·VPC 및 JSON을 내는 애플리케이션), **필드 인덱스**로 스캔량·비용 절감, **패턴 탐지**, 쿼리 저장·이력·파라미터, 대시보드 추가, **KMS로 쿼리 결과 암호화**, **자연어 쿼리 생성**, **주변 로그 보기**(선택 레코드 앞뒤 5·10·20·50·100줄)

#### 4-2. Athena와 Security Hub CSPM 조사 결과

- **Athena** — S3에 쌓인 로그를 **SQL로** 조회합니다. CloudTrail·VPC 흐름 로그·Security Lake 테이블처럼 **대량·장기 보존 데이터**를 다룰 때 Logs Insights보다 적합합니다
- **Security Hub CSPM 조사 결과** — 서비스별 원시 로그를 뒤지는 대신 **정규화된(ASFF) 조사 결과**를 한곳에서 봅니다. ⚠️ **소급 적용되지 않으므로**(작업 1.1) "사고 전 기록"을 보려면 원시 로그 쪽으로 가야 합니다

⚠️ 세 수단은 **질문의 모양**으로 갈립니다. "지금 무슨 일이 벌어지나"는 Logs Insights, "석 달치에서 패턴을 찾자"는 Athena, "지금 우리 보안 자세가 어떤가"는 Security Hub CSPM입니다.

### 5) 정규화·구문 분석·상관 관계 분석 (기술 1.2.5) {#correlate}

공식 예시는 **Amazon OpenSearch Service · AWS Lambda · Amazon Managed Grafana**입니다. 층으로 보면 이렇습니다.

| 층 | 수단 | 하는 일 |
|---|---|---|
| **변환** | **Lambda** | 형식이 다른 로그를 받아 **파싱·정규화**해 다음 단계로 넘깁니다 |
| **색인·검색** | **OpenSearch Service** | 대량 로그를 색인해 **자유 검색과 집계**를 제공합니다 |
| **시각화** | **Managed Grafana** | 여러 데이터 소스를 한 대시보드에서 **함께** 봅니다 |

⚠️ **Security Lake와 이 묶음은 경쟁 관계가 아닙니다.** Security Lake가 **OCSF로 정규화해 쌓는** 쪽이고, 위 묶음은 **쌓인 것을 검색·시각화하거나 Security Lake가 기본 지원하지 않는 형식을 변환**하는 쪽입니다. 문항이 "여러 벤더의 로그 형식을 하나로 맞춘다"를 물으면 **OCSF 정규화**가 먼저 떠올라야 합니다.

### 6) 네트워크 로그 소스를 결정한다 (기술 1.2.6) {#network}

| 소스 | 담는 것 | 보낼 수 있는 곳 |
|---|---|---|
| **VPC 흐름 로그** | VPC **네트워크 인터페이스**를 오가는 IP 트래픽 메타데이터 | CloudWatch Logs · S3 · **Data Firehose** |
| **전송 게이트웨이 흐름 로그** | **전송 게이트웨이**를 오가는 IP 트래픽 | CloudWatch Logs · S3 · **Firehose** |
| **Route 53 Resolver 쿼리 로그** | VPC에서 발생한 **DNS 질의와 응답** | CloudWatch Logs 로그 그룹 · S3 · **Firehose 전송 스트림** |

#### 6-1. 전송 게이트웨이 흐름 로그

- ⚠️ **전송 게이트웨이의 소유자만 흐름 로그를 만들 수 있습니다**(아니면 소유자가 권한을 줘야 합니다)
- **네트워크 트래픽 경로 밖에서 수집**되므로 처리량·지연에 영향이 없고, 만들거나 지워도 네트워크 성능 위험이 없습니다
- ⚠️ **실시간 스트림이 아닙니다.** 만든 뒤 수집·게시 시작까지 **몇 분**이 걸리고, 지운 뒤 수집이 멈추는 데도 몇 분이 걸립니다
- 제한 셋 — **멀티캐스트 미지원** · **Connect 어태치먼트 미지원**(Connect 흐름 로그는 **전송 어태치먼트 아래** 나타나므로 전송 게이트웨이나 Connect 전송 어태치먼트에서 켜야 합니다) · **리소스·계정당 최대 250개 구독**
- 형식은 **기본**(버전 2~6의 전 필드, **변경 불가**)과 **사용자 지정**(원하는 필드와 순서, 최소 1개) 둘입니다
- ⚠️ 흐름 로그를 지워도 **이미 쌓인 레코드·로그 스트림·S3 객체는 남습니다**

#### 6-2. Route 53 Resolver 쿼리 로깅

기록할 수 있는 질의가 **네 종류**입니다 — 지정한 VPC에서 발생한 질의와 **그 응답** · **인바운드 Resolver 엔드포인트**를 쓰는 온프레미스 질의 · **아웃바운드 Resolver 엔드포인트**를 쓰는 재귀 해석 · **Resolver DNS Firewall 규칙**이 차단·허용·모니터링한 질의.

로그에 담기는 값에는 리전·VPC ID·발신 인스턴스의 IP와 인스턴스 ID·시각·**질의한 DNS 이름**·레코드 유형·**응답 코드**(`NoError`·`ServFail` 등)·응답 데이터·DNS Firewall 규칙 작업에 대한 응답이 있습니다.

⚠️⚠️ **캐시에서 응답한 질의는 기록되지 않습니다.** 공식이 "**고유 질의만 기록한다**"고 적습니다. 어떤 인스턴스가 같은 이름을 TTL 안에 다시 조회하면 **두 번째 질의는 로그에 없습니다.** 「조회 횟수」를 세는 설계는 이 성질 때문에 성립하지 않습니다.

## ✍️ 시험 포인트

- **"그 로그로는 알 수 없다"** — 도메인 이름은 흐름 로그에 없고(Resolver 쿼리 로그), 전송 게이트웨이 트래픽은 VPC 흐름 로그에 없습니다
- **조직 추적의 리전 조합** — 특히 **다중 리전 + 옵트인 홈 리전**에서 멤버 계정이 보내지 않는 경우
- **검증 실패해도 추적은 만들어진다** — "조직 추적을 만들었는데 로그가 안 온다"의 원인이 버킷 정책·KMS 권한일 수 있고, 멤버 계정은 `get-trail-status`로 봅니다
- **에이전트 세대** — IMDSv2 환경에서 구 로그 에이전트를 쓰려는 설계는 성립하지 않습니다
- **사용자 지정 소스의 변환 책임** — 타사 로그를 Security Lake에 넣을 때 **OCSF 변환은 소스 쪽** 일입니다
- **Logs Insights 언어 선택** — 로그 그룹 간 `JOIN`이 필요하면 **SQL**, `filterIndex`로 비용을 줄이려면 **QL**입니다
- **분석 수단의 모양** — 실시간 조사는 Logs Insights, 장기·대량은 Athena
- **Resolver 로그의 캐시 성질** — 질의 횟수·빈도를 근거로 삼는 설계는 틀립니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"VPC 흐름 로그로 어떤 도메인에 접속했는지 본다"** → 흐름 로그는 **IP 트래픽 메타데이터**입니다. 이름은 **Resolver 쿼리 로그**입니다
- ❌ **"흐름 로그는 CloudWatch Logs와 S3 둘뿐"** → **Data Firehose**도 대상입니다(VPC·전송 게이트웨이 모두)
- ❌ **"Connect 어태치먼트에 흐름 로그를 켠다"** → **지원되지 않습니다.** Connect 흐름 로그는 **전송 어태치먼트 아래** 나타납니다
- ❌ **"조직 추적을 만들면 단일 리전으로도 쉽게 만들 수 있다"** → **콘솔은 다중 리전만**이고 단일 리전은 **CLI**입니다
- ❌ **"멤버 계정 관리자가 조직 추적을 끌 수 있다"** → **볼 수만 있습니다**
- ❌ **"CloudWatch Logs 에이전트를 설치하면 지표도 수집된다"** → 구 에이전트는 **로그만**이고 **폐지**됐습니다. 로그와 지표를 함께 수집하는 것은 **통합 에이전트**입니다
- ❌ **"Security Lake를 켜면 기본 지원 소스의 로깅도 따로 켜야 한다"** → **`CloudTrail 관리 이벤트`만** 예외입니다
- ❌ **"타사 로그를 S3에 넣으면 Security Lake가 OCSF로 바꿔 준다"** → **사용자 지정 소스는 변환해서 보내야** 합니다
- ❌ **"Logs Insights 동시 쿼리 한도는 하나다"** → **QL 100 / PPL·SQL 각 15**로 다릅니다
- ❌ **"Resolver 쿼리 로그로 조회 빈도를 센다"** → **고유 질의만** 남습니다

## 🧪 자가 점검

**Q1.** 보안팀이 "지난주에 어떤 EC2 인스턴스가 `malware.example.com`을 조회했는지" 확인해 달라고 합니다. VPC 흐름 로그는 CloudWatch Logs에 쌓고 있고 Resolver 쿼리 로깅은 켜지 않았습니다. 가능합니까? (→ 6 네트워크 로그 소스)

<details><summary>정답 보기</summary>

**VPC 흐름 로그만으로는 알 수 없습니다.** 흐름 로그는 **IP 트래픽의 메타데이터**이고 **질의한 DNS 이름을 담지 않습니다.** 이름·레코드 유형·응답 코드·응답 데이터는 **Route 53 Resolver 쿼리 로그**에 들어갑니다.

⚠️ 그리고 지금부터 Resolver 쿼리 로깅을 켜도 **과거는 복구되지 않습니다.** 앞으로를 위해 켜되, **캐시에서 응답한 질의는 기록되지 않는다**(고유 질의만 남는다)는 성질까지 고려해야 합니다.

⭐ 참고로 Resolver 쿼리 로그는 **Security Lake의 기본 지원 소스 6종**에 들어 있어, 레이크로 모아 두면 장기 조회가 쉬워집니다.
</details>

**Q2.** 조직 관리 계정에서 다중 리전 조직 추적을 만들었고 홈 리전을 **유럽(스페인)**으로 잡았습니다. 그런데 일부 멤버 계정의 활동이 추적에 전혀 보이지 않습니다. 왜입니까? (→ 2-1 조직 추적)

<details><summary>정답 보기</summary>

**유럽(스페인)은 옵트인 리전이고, 그 리전을 활성화하지 않은 멤버 계정은 활동을 조직 추적으로 보내지 않습니다.** 공식이 이 조합을 명시하고 예시로 든 리전이 바로 유럽(스페인)입니다.

네 조합을 정리하면 — **단일 리전 + 비옵트인 홈**: 전 멤버 계정의 그 리전에 사본 생성 / **단일 리전 + 옵트인 홈**: 그 리전을 활성화한 멤버 계정에만 / **다중 리전 + 비옵트인 홈**: 전 멤버 계정의 활성화된 전 리전에 사본(멤버가 옵트인 리전을 나중에 켜면 그때 사본 생성) / **다중 리전 + 옵트인 홈**: 그 리전을 옵트인한 멤버 계정만 보냅니다.
</details>

**Q3.** 타사 EDR 제품의 로그를 Security Lake에 모아 Athena로 함께 조회하려 합니다. 제품은 로그를 JSON Lines로 S3에 쓸 수 있습니다. 그대로 쓸 수 있습니까? (→ 3 로그 스토리지와 데이터 레이크)

<details><summary>정답 보기</summary>

**그대로는 안 됩니다.** 사용자 지정 소스는 **보내기 전에 로그를 OCSF로 변환**해야 하고, 각 S3 객체는 **Apache Parquet** 형식이어야 합니다. Security Lake가 변환해 주는 것은 **기본 지원 AWS 소스**뿐입니다.

요건을 더 적으면 — 한 객체의 모든 레코드가 **같은 OCSF 이벤트 클래스**여야 하고, `region=…/accountId=…/eventDay=yyyyMMdd/`로 **파티셔닝**해야 하며, 전송 주기는 **5분~1 이벤트 일**, 객체 안은 **시간순 정렬**이 권장됩니다. **계정당 사용자 지정 소스는 50개**가 상한입니다.

⚠️ 변환 층이 필요하면 `기술 1.2.5`의 **Lambda**가 그 자리입니다(파싱·정규화 후 적재).
</details>

**Q4.** 로그 그룹 두 개를 조인해 "같은 요청 ID가 양쪽에 어떻게 기록됐는지" 보려 합니다. Logs Insights에서 가능합니까? (→ 4-1 쿼리 언어)

<details><summary>정답 보기</summary>

**가능합니다 — OpenSearch SQL을 씁니다.** 공식이 SQL에서 **로그 그룹 간 `JOIN`**과 하위 쿼리로 로그를 상관할 수 있다고 적습니다.

⚠️ 대신 **동시 실행 한도가 다릅니다** — Logs Insights QL은 **계정당 100개**(대시보드 쿼리 포함)인데 **PPL·SQL은 각 15개**입니다. 그리고 **`filterIndex`와 비교 쿼리는 QL 전용**이라 비용 절감 색인을 쓰려면 QL로 돌아와야 합니다.

⚠️ SQL·PPL에서는 **특수문자가 든 필드를 백틱으로** 감싸야 합니다(`@message` 등).
</details>

**Q5.** EC2 플릿을 IMDSv2 전용으로 강제했습니다. 기존 AMI에는 구 CloudWatch Logs 에이전트가 들어 있습니다. 무엇을 해야 합니까? (→ 2-2 로그 에이전트)

<details><summary>정답 보기</summary>

**통합 CloudWatch 에이전트로 옮겨야 합니다.** 공식이 "**IMDSv2를 쓰면 새 통합 CloudWatch 에이전트를 반드시 써야 한다**"고 적고, 구 에이전트는 **폐지(deprecated)** 상태입니다.

함께 기억할 것 — 구 에이전트는 **Python 2.6~3.5만** 지원하고, **Amazon Linux 2에서 폐지돼 AL2023에는 `awslogs` 패키지가 아예 없습니다**(대체는 `amazon-cloudwatch-agent`). 통합 에이전트는 **로그와 지표를 함께** 수집합니다.

⚠️ 공식 시험 가이드의 `기술 1.2.2`가 "CloudWatch Logs 에이전트 구성"을 예시로 들지만, **가이드가 예시로 든다는 것이 그 기능이 현행이라는 뜻은 아닙니다.**
</details>

**Q6.** "3개월치 CloudTrail 로그에서 특정 IAM 역할의 `AssumeRole` 패턴을 집계하라"는 요구입니다. 로그는 S3에 있고 CloudWatch Logs에는 최근 2주만 있습니다. 어떤 수단이 적합합니까? (→ 4-2 Athena)

<details><summary>정답 보기</summary>

**Athena**입니다. S3에 쌓인 대량·장기 로그를 **SQL로** 조회하는 자리이고, Logs Insights는 **CloudWatch Logs의 로그 그룹**을 대상으로 합니다(여기서는 최근 2주뿐입니다).

⚠️ 세 수단의 모양을 기억합니다 — **"지금 무슨 일이 벌어지나"는 Logs Insights**, **"장기·대량 패턴"은 Athena**, **"지금 보안 자세가 어떤가"는 Security Hub CSPM**입니다. 그리고 **Security Hub CSPM은 소급 적용되지 않으므로** 사고 이전 기록을 찾는 데 쓸 수 없습니다.
</details>

---

### 📌 출처

1. Creating a trail for an organization (AWS CloudTrail) — `docs.aws.amazon.com/awscloudtrail/latest/userguide/creating-trail-organization.html` (2026-11-08 확인)
2. CloudWatch Logs agent reference (폐지 안내) — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html` (2026-11-08 확인)
3. Quick Start: CloudWatch Logs agent on a running EC2 Linux instance (폐지·Python·IMDSv2) — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html` (2026-11-08 확인)
4. Functionality deprecated in AL2 and removed in AL2023 — `docs.aws.amazon.com/linux/al2/ug/deprecated-al2.html` (2026-11-08 확인)
5. Analyzing log data with CloudWatch Logs Insights — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html` (2026-11-08 확인)
6. Collecting data from AWS services in Security Lake — `docs.aws.amazon.com/security-lake/latest/userguide/internal-sources.html` (2026-11-08 확인)
7. Collecting data from custom sources in Security Lake — `docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html` (2026-11-08 확인)
8. AWS Transit Gateway Flow Logs — `docs.aws.amazon.com/vpc/latest/tgw/tgw-flow-logs.html` (2026-11-08 확인)
9. Resolver query logging (Amazon Route 53) — `docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html` (2026-11-08 확인)
10. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-08 확인)
11. How CloudTrail works — 기록되는 이벤트와 주체 — `docs.aws.amazon.com/awscloudtrail/latest/userguide/how-cloudtrail-works.html` (2026-11-10 확인)
12. What is Amazon Athena? — S3 데이터를 표준 SQL로 조회 — `docs.aws.amazon.com/athena/latest/ug/what-is.html` (2026-11-10 확인)
13. What is Amazon Security Lake? — OCSF·Parquet 정규화 — `docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html` (2026-11-10 확인)
