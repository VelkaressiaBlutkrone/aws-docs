---
examGuideTaskId: scs-t1-1
certCode: SCS-C03
domain: 1
domainName: 탐지
domainWeightPct: 16
title: 모니터링 및 경보 솔루션 설계 (요구 사항·상태 확인·이벤트 집계·탐지 서비스·평가 자동화)
coversTasks:
  - "1.1"
sources:
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
  - title: Exposure findings in Security Hub
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/exposure-findings.html
  - title: Enabling Security Hub
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-v2-enable.html
  - title: Understanding cross-Region aggregation in Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/finding-aggregation.html
  - title: Understanding cross-Region aggregation in Security Hub
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/security-hub-region-aggregation.html
  - title: What is Amazon GuardDuty?
    url: https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
  - title: What is Amazon Macie?
    url: https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
  - title: What is Amazon Security Lake?
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html
  - title: Alarm evaluation (Amazon CloudWatch)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html
  - title: Configuring how CloudWatch alarms treat missing data
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html
  - title: CloudWatch cross-account observability
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Unified-Cross-Account.html
  - title: Conformance Packs for AWS Config
    url: https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html
  - title: AWS Systems Manager State Manager
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html
lastVerified: 2026-11-08
---

# 모니터링 및 경보 솔루션 설계 (요구 사항·상태 확인·이벤트 집계·탐지 서비스·평가 자동화)

> **커버하는 공식 Task** — SCS-C03 · 도메인 1 「탐지」(16%) · **작업 1.1 AWS 계정 또는 조직용 모니터링 및 경보 솔루션 설계 및 구현** (`scs-t1-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(1.1.1~1.1.5)를 모두 덮습니다. 도메인 1은 **「무엇이 무엇을 탐지하는가」의 경계**를 묻습니다. 서비스 이름을 외우는 것보다 **그 사실을 알려면 무엇을 켜야 하는지**를 아는 것이 훨씬 빠른 투자입니다.

> ⚠️⚠️ **먼저 알아야 할 것 — `Security Hub`는 지금 두 제품입니다.** 공식 문서의 소개 페이지 제목이 「Introduction to AWS **Security Hub CSPM**」이고, 그냥 「AWS Security Hub」라는 이름은 **OCSF 형식의 노출 조사 결과를 내는 다른 제품**을 가리킵니다. 공식 시험 가이드는 「AWS Security Hub」로만 적지만 실제 문서는 갈려 있으니, 이 사이트에서는 **표준 점검·ASFF 쪽은 `Security Hub CSPM`**, **신호 상관·노출 조사 결과 쪽은 `Security Hub`**로 구분해 적습니다. 자세한 것은 아래 3절입니다.

---

## 🧭 시험 형식 (16편 중 여기서 한 번만 정리합니다)

공식 가이드가 적는 사실입니다. 시험장에서 처음 보면 당황하는 부분이라 먼저 짚습니다.

| 항목 | 값 |
|---|---|
| 등급 | **Specialty** |
| 채점 문항 | **50개** |
| 채점되지 않는 문항 | **15개**(시험에서 식별되지 않습니다) |
| 시험 시간 | **170분** · 응시 화면 문항 **65개** |
| 합격 최소 점수 | **750**(변환 점수 100~1,000) |
| 채점 모델 | **보상 점수 모델** — 섹션마다 합격할 필요가 없고 전체 시험만 합격하면 됩니다 |

답안 유형은 **네 가지**이고 채점 규칙이 다릅니다.

- **선다형** — 정답 1개, 오답 3개
- **복수 응답형** — 5개 이상의 응답 중 정답 2개 이상. **정답을 모두 선택해야** 점수를 받습니다
- **순서 배열** — 3~5개 응답을 **올바른 순서로 배열**해야 점수를 받습니다
- **매칭형** — 3~7개 프롬프트와 응답의 **모든 쌍을 정확히 맞춰야** 점수를 받습니다

> ⚠️ **답하지 않은 문항은 오답으로 채점되고 추측에 따른 불이익은 없습니다.** 모르는 문항도 반드시 표시하고 넘어갑니다.
> 이 사이트의 연습 문항은 **선다형**으로 제공됩니다. 나머지 세 유형은 "모두 맞아야 득점"이라는 성질만 기억하면 되고, 묻는 지식은 같습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 워크로드를 보고 **무엇을 모니터링해야 하는지** 요구 사항으로 적을 수 있다
- [ ] CloudWatch 알람의 **Period · Evaluation Periods · Datapoints to Alarm** 세 설정과 「M out of N」을 설명한다
- [ ] **누락 데이터 처리 4종**을 고르고 기본값과 예외를 안다
- [ ] 계정·리전 경계를 넘어 이벤트를 **집계하는 두 경로**(CloudWatch 크로스 계정 관측성 · Security Hub 크로스 리전 집계)를 구분한다
- [ ] GuardDuty · Inspector · Macie · Security Hub CSPM · Security Hub · Security Lake가 **각자 무엇을 보는지** 한 줄로 말한다
- [ ] 「이 사실을 알려면 무엇을 켜야 하나」에 서비스 하나로 답한다
- [ ] AWS Config 준수 팩 · Security Hub CSPM · State Manager로 **정기 평가를 자동화**하는 설계를 고른다

## 🎯 왜 중요한가

도메인 1은 **16%**이고 작업이 셋(1.1 설계 · 1.2 로깅 · 1.3 문제 해결)입니다. 그중 이 작업은 **서비스 선택 문항이 가장 많이 나오는 자리**입니다.

그런데 공식 기술 설명은 서비스를 **예시 묶음**으로만 나열합니다. 예를 들어 `기술 1.1.4`는 "지표, 알림 및 대시보드를 만들어 이상 데이터 및 이벤트 탐지(예: Amazon GuardDuty, Amazon Security Lake, AWS Security Hub, Amazon Macie)"라고만 적습니다. **네 서비스가 하는 일이 전부 다른데 한 줄에 묶여 있으니**, 묶음을 외우면 문항에서 갈라낼 수 없습니다.

Specialty 문항은 거의 항상 **시나리오**로 나옵니다. "S3에 민감 데이터가 있는지 알고 싶다"와 "S3에서 데이터가 빠져나가는 중인지 알고 싶다"는 **다른 서비스**이고, "그 두 신호가 한 리소스에서 겹쳐 실제 위험이 되는지"는 **또 다른 서비스**입니다. 이 문서의 3절과 4절이 그 경계를 표로 고정합니다.

## ⚡ 시험 직전 요약

- 알람 상태는 **OK · ALARM · INSUFFICIENT_DATA** 셋이고, 그와 **별도로 평가 상태**(`PARTIAL_DATA` · `IN_WARM_UP` · `EVALUATION_ERROR` · `EVALUATION_FAILURE`)가 있습니다
- 누락 데이터 처리 기본값은 **`missing`**입니다. 단 **`AWS/DynamoDB` 네임스페이스 알람은 기본이 `ignore`**입니다
- EC2 지표에 **중지·종료·재부팅·복구** 작업을 붙인 알람은 누락 데이터를 **`missing`**으로 두고 **ALARM 상태에서만** 동작하게 두는 것이 공식 권장입니다
- 크로스 계정 관측성은 **sink(모니터링 계정) + 링크(소스 계정)** 구조이고, **sink는 계정·리전당 하나**입니다
- **소스 계정이 모니터링 계정보다 더 많은 원격 측정 유형을 선택하면 링크 생성이 실패**합니다(반대 방향은 교집합만 공유)
- Security Hub CSPM의 **「집계 리전」은 「홈 리전」으로 개명**됐고 일부 API만 옛 용어를 씁니다. **홈 리전은 옵트인 리전일 수 없습니다**
- **Security Hub CSPM은 소급 적용되지 않습니다** — 켠 뒤 생성된 조사 결과만 집계하고, **활성화한 리전에서만** 받습니다
- Security Hub CSPM의 **대부분 제어는 AWS Config를 켜고 리소스를 기록해야** 조사 결과를 만듭니다
- **GuardDuty Extended Threat Detection은 추가 비용이 없고 계정마다 자동으로 켜집니다**(보호 플랜이 필요 없습니다)
- **Malware Protection for S3는 GuardDuty 서비스를 켜지 않고 단독으로** 쓸 수 있습니다. 다른 보호 플랜은 전부 GuardDuty를 켜야 합니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **지표(metric)** | 시간에 따라 쌓이는 수치 데이터. 알람과 대시보드의 입력입니다 |
| **알람(alarm)** | 지표나 지표 수식을 임계값과 비교해 상태를 바꾸고 **작업을 실행**하는 리소스 |
| **평가 범위(evaluation range)** | 알람이 상태를 바꿀지 판단할 때 **실제로 조회하는 더 넓은 구간**. 평가 기간보다 넓습니다 |
| **조사 결과(finding)** | 보안 서비스가 "문제일 수 있다"고 내놓는 구조화된 레코드 |
| **ASFF** | AWS Security Finding Format. **Security Hub CSPM**이 조사 결과를 담는 표준 형식 |
| **OCSF** | Open Cybersecurity Schema Framework. 벤더 중립 보안 스키마로, **신 Security Hub**와 **Security Lake**가 씁니다 |
| **노출 조사 결과(exposure finding)** | 여러 신호를 **상관**해 실제 위험과 공격 경로를 드러낸 조사 결과. 신 Security Hub가 만듭니다 |
| **홈 리전(home Region)** | 크로스 리전 집계에서 데이터를 모으는 리전. 옛 이름은 **집계 리전**입니다 |
| **sink / 링크** | 크로스 계정 관측성에서 모니터링 계정의 **부착 지점**과 소스 계정이 만드는 **연결** |
| **준수 팩(Conformance Pack)** | AWS Config 규칙과 개선 조치를 **단일 엔터티로 배포**하는 묶음 |

## 📖 핵심 개념

### 1) 모니터링 요구 사항을 결정한다 (기술 1.1.1) {#requirements}

공식 기술은 "워크로드를 분석하여 모니터링 요구 사항 결정"입니다. 시험에서는 **「무엇을 모니터링할지」가 아니라 「무엇을 알아야 하는지」에서 출발하는 설계**를 고르게 합니다.

실무 순서로 적으면 이렇습니다.

1. **보호할 자산과 그 위협**을 적는다 — 데이터가 어디 있고 누가 닿을 수 있는가
2. **알아야 할 사실**을 문장으로 적는다 — "자격 증명이 외부에서 쓰였다", "버킷이 공개로 바뀌었다"
3. 그 사실을 **만들어 주는 신호원**을 찾는다 — 로그인가 조사 결과인가 구성 항목인가
4. 신호원을 **내놓는 서비스**를 켠다(4절의 경계 표)
5. **누가 받고 무엇을 하는지** 정한다 — 알림·자동 조치·티켓

⚠️ 거꾸로 하면(서비스를 먼저 켜고 나서 무엇을 볼지 정하면) **비용은 다 내면서 정작 필요한 사실이 빠지는** 설계가 됩니다. Specialty 문항의 오답 보기가 대개 이 형태입니다.

### 2) 모니터링 전략과 상태 확인 (기술 1.1.2) {#strategy}

알람은 **세 설정**으로 평가됩니다(공식 용어 그대로 씁니다).

| 설정 | 뜻 |
|---|---|
| **Period** | 데이터 포인트 하나를 만들기 위해 지표를 평가하는 **시간 길이**(초) |
| **Evaluation Periods** | 상태를 판단할 때 보는 **최근 기간(데이터 포인트) 수** |
| **Datapoints to Alarm** | 그 기간 중 **몇 개가 임계값을 넘어야** ALARM이 되는가 |

**Datapoints to Alarm을 Evaluation Periods보다 작게 두면 「M out of N」 알람**입니다. 공식 예시는 "1분 기간으로 5개 중 4개"면 평가 간격이 5분, "10분 기간으로 3개 중 3개"면 30분입니다. ⚠️ **넘는 데이터 포인트가 연속이어야 할 필요는 없습니다** — 최근 N개 안에 M개가 있으면 됩니다.

알람 상태는 **OK · ALARM · INSUFFICIENT_DATA** 셋입니다. ⚠️⚠️ 그런데 그와 **별도로 「평가 상태」가 있습니다** — 문제 해결(작업 1.3)에서 직접 쓰입니다.

- **`PARTIAL_DATA`** — 쿼터 제한 때문에 가용한 데이터를 **전부 가져오지 못했다**
- **`IN_WARM_UP`** — 워밍업 기간이라 **아직 평가하지 않는다**. 이 동안 알람은 `INSUFFICIENT_DATA`에 머물고 **작업을 실행하지 않는다**
- **`EVALUATION_ERROR`** — **구성 오류**다. 알람의 `StateReason`을 봐야 한다
- **`EVALUATION_FAILURE`** — **일시적인 CloudWatch 문제**다. 해결될 때까지 수동 모니터링을 권한다

⚠️ **기간이 1분 이상이면 알람은 매분 평가되고**, 10·20·30초면 **10초마다** 평가됩니다(고해상도 알람, 추가 요금). ⚠️ **평가 기간 수 × 기간 길이가 하루를 넘으면 「다중 일 알람」이고 시간당 한 번만** 평가됩니다(정시 :00 기준).

⚠️ 기본 평가 창은 **슬라이딩 창**입니다(매 평가마다 1분씩 전진, 벽시계에 정렬되지 않음). **벽시계 창**으로 바꿀 수 있고, 그 차이가 누락 데이터 처리에 영향을 줍니다(4절).

### 3) 보안·모니터링 이벤트를 집계한다 (기술 1.1.3) {#aggregation}

**경계를 넘는 집계 경로가 두 갈래이고 서로 다른 축을 넘습니다.**

#### 3-1. 계정을 넘는다 — CloudWatch 크로스 계정 관측성

**한 리전 안에서** 여러 계정의 관측 데이터를 중앙에서 봅니다. **모니터링 계정**과 **소스 계정**을 연결하고, 공유할 수 있는 원격 측정은 지표 · 로그 그룹 · X-Ray 트레이스 · Application Signals 서비스와 SLO · Application Insights 애플리케이션 · Internet Monitor입니다.

구조는 **sink**(모니터링 계정의 부착 지점)와 **관측성 링크**(소스 계정이 만드는 연결)이고, CLI·API 이름은 **Observability Access Manager**입니다.

- ⚠️ **sink는 계정·리전당 하나**이고 모니터링 계정이 관리합니다. **링크는 소스 계정이 관리**합니다
- ⚠️ **모니터링 계정 하나에 최대 100,000 소스 계정**, **소스 계정 하나는 최대 5개 모니터링 계정**
- ⚠️⚠️ **원격 측정 유형 선택이 비대칭입니다** — 모니터링 계정이 소스 계정보다 **더 많이** 선택하면 **양쪽에서 선택된 것만** 공유되고 연결은 성립합니다. 반대로 **소스 계정이 더 많이 선택하면 링크 생성이 실패하고 아무것도 공유되지 않습니다**
- ⚠️ **링크 제거는 소스 계정에서** 하고, **sink를 삭제하려면 모든 링크를 먼저 제거**해야 합니다
- ⚠️ 한 계정을 **모니터링 계정과 소스 계정 둘 다로 둘 수 있지만**, 그 계정은 **자기 데이터만** 보내고 **자기 소스 계정의 데이터를 중계하지 않습니다**
- 조직을 쓰면 **나중에 만들어지는 계정이 자동으로 소스 계정이 됩니다** — 공식 권장입니다

#### 3-2. 리전을 넘는다 — Security Hub 크로스 리전 집계

⚠️⚠️ **두 제품에 각각 집계 기능이 있고 모으는 것이 다릅니다.**

| | **Security Hub CSPM** | **Security Hub**(신) |
|---|---|---|
| 모으는 것 | 조사 결과 · 조사 결과 업데이트 · **통찰(insights)** · **제어 준수 상태** · **보안 점수** | 조사 결과 · **리소스** · **추세** |
| 용어 | **홈 리전**(옛 이름 「집계 리전」, 일부 API는 아직 옛 용어) | 홈 리전 |

- ⚠️⚠️ **홈 리전은 옵트인 리전일 수 없습니다.** 2019-03-20 이후 도입된 리전이 옵트인 리전이고, 조직에서 그 리전을 활성화하기 전에는 그곳에 Security Hub CSPM을 구성할 수도 없습니다
- ⚠️ **연결 리전에서는 켜고 홈 리전에서는 끈 제어**는 홈 리전에서 **준수 상태만 볼 수 있고 켜거나 끌 수 없습니다.** 예외는 **중앙 구성(central configuration)**을 쓰는 경우이고, 그때는 위임 관리자가 홈 리전에서 양쪽을 구성합니다
- ⚠️ GovCloud(US)와 중국 리전은 **조사 결과·업데이트·통찰만** 집계되고 **각 파티션 안에서만** 됩니다
- ⚠️ 크로스 리전 **보안 점수와 준수 상태를 보려면** IAM 역할에 `ListSecurityControlDefinitions` · `BatchGetStandardsControlAssociations` · `BatchUpdateStandardsControlAssociations`가 필요합니다

#### 3-3. 활성화 순서 — CSPM이 전제 조건은 아니지만 위임 관리자를 묶습니다

공식 활성화 문서는 "**Security Hub는 어떤 AWS 계정에서도 켤 수 있다**"로 시작하고, 독립 계정 절차에 CSPM 선행 요건이 없습니다. 즉 **CSPM은 전제 조건이 아닙니다.**

⚠️⚠️ **그런데 위임 관리자 선택은 CSPM 쪽에 묶입니다.** CSPM 위임 관리자가 이미 지정돼 있고 그 계정이 **조직 관리 계정이 아니면**, 그 계정이 **자동으로 Security Hub 위임 관리자가 되고 다른 계정을 고를 수 없습니다.** CSPM 위임 관리자가 관리 계정이거나 아예 없으면 고를 수 있습니다(단 **조직 관리 계정은 제외**).

Security Hub를 켜면 계정에 다음이 만들어집니다 — 서비스 연결 역할 **`AWSServiceRoleForSecurityHubV2`**, **서비스 연결 구성 레코더**, **서비스 연결 분석기**. ⚠️ 즉 **구성 기록과 액세스 분석을 Security Hub가 자기 몫으로 함께 세웁니다.**

⚠️ 조직 설정에서 **「신뢰할 수 있는 액세스」 체크박스**를 켜면 위임 관리자가 멤버 계정에 **GuardDuty Malware Protection 같은 기능을 구성**할 수 있습니다. 끄면 **그 기능은 해당 서비스에서 직접 켜야** 합니다.

### 4) 이상 데이터와 이벤트를 탐지한다 (기술 1.1.4) {#detection}

#### 4-1. 경계 표 — 「무엇이 무엇을 보는가」

이 표가 이 문서의 결론입니다. 시나리오 문항의 갈림길은 거의 전부 이 표의 한 칸입니다.

| 서비스 | 입력(무엇을 보나) | 산출물 | 이것은 하지 않는다 |
|---|---|---|---|
| **GuardDuty** | CloudTrail 관리 이벤트 · VPC 흐름 로그 · DNS 로그(기초, 자동) + 보호 플랜별 소스 | 위협 조사 결과 · **공격 시퀀스** | 취약성을 스캔하지 않고, 민감 데이터를 분류하지 않습니다 |
| **Inspector** | EC2 · ECR 컨테이너 이미지 · Lambda 함수 | 취약성·네트워크 노출 조사 결과 | 런타임 행위를 보지 않습니다(그쪽은 GuardDuty Runtime Monitoring) |
| **Macie** | **S3 범용 버킷**의 객체와 버킷 설정 | 민감 데이터 조사 결과 · 정책 조사 결과 | S3 밖을 보지 않고, 위협 행위를 탐지하지 않습니다 |
| **Security Hub CSPM** | AWS Config 등 통합 서비스 + 타사 + 사용자 정의 | **ASFF** 제어 조사 결과 · 보안 점수 | 신호를 상관해 공격 경로를 만들지 않습니다 |
| **Security Hub**(신) | Security Hub CSPM · Inspector · GuardDuty · Macie 신호 | **OCSF 노출 조사 결과** | 스스로 탐지하지 않습니다 — **상관합니다** |
| **Security Lake** | 기본 지원 AWS 소스 + 사용자 지정 소스 | **OCSF + Parquet** 데이터 레이크(내 계정 S3) | 탐지도 상관도 하지 않습니다 — 모으고 정규화합니다 |

#### 4-2. 서비스별로 기억할 한 가지

- **GuardDuty** — 켜면 **기초 데이터 소스를 따로 켤 것이 없습니다.** 그리고 **Extended Threat Detection이 추가 비용 없이 자동으로** 켜져 개별로는 위협이 아닌 이벤트들의 **순서**를 보고 **공격 시퀀스**를 식별합니다. ⚠️ **처음 켜면 Runtime Monitoring을 뺀 전 보호 플랜이 자동으로 켜지고 30일 무료 평가에 들지만, 기존 고객에게는 나중에 나온 플랜이 자동으로 켜지지 않습니다.** ⚠️ **Malware Protection for S3는 GuardDuty를 켜지 않고 단독 사용이 가능합니다**
- **Macie** — 대상은 **S3 범용 버킷**입니다. 검색 경로가 둘(**자동 민감 데이터 검색**은 표본 추출로 폭넓게, **민감 데이터 검색 작업**은 깊고 표적화되며 1회성·반복을 고를 수 있습니다). 조사 결과도 둘(**정책** 조사 결과와 **민감 데이터** 조사 결과)입니다
- **Security Hub CSPM** — ⚠️⚠️ **소급 적용되지 않습니다**("켠 뒤 생성된 조사 결과만"). **활성화한 리전에서만** 받아 처리하고, **CIS 벤치마크 전체 준수를 위해서는 지원되는 모든 리전에서 켜야** 합니다. ⚠️ **대부분의 제어가 AWS Config를 요구**합니다(서비스 연결 규칙을 쓰므로 AWS Config를 켜고 리소스를 기록해야 합니다). 단 **보안 표준이 활성화한 AWS Config 규칙 자체에는 과금되지 않습니다**
- **Security Hub(신)** — **노출 조사 결과**를 만듭니다. 심각도는 Critical·High·Medium·Low 네 단계이고, 구성 요소에 **기여 특성**(취약성·구성 문제·네트워크 노출·권한 설정·**리소스 중요도**)과 **공격 경로·폭발 반경 시각화**가 들어갑니다. ⚠️ **리소스 하나는 최대 하나의 노출 조사 결과에서만 주 리소스가 되고**, 특성이 없거나 부족하면 조사 결과가 만들어지지 않습니다
- **Security Lake** — 데이터 레이크는 **내 계정의 S3**로 뒷받침되고 **소유권이 내게 남습니다.** 수집한 데이터를 **OCSF + Parquet**로 변환하고, **롤업 리전**으로 여러 리전을 통합해 데이터 레지던시 요건에 맞출 수 있습니다

#### 4-3. 알람의 누락 데이터 처리 — 탐지가 거짓 양성이 되는 자리

데이터 포인트는 **임계값 내(not breaching) · 임계값 초과(breaching) · 누락(missing)** 셋 중 하나입니다. 누락을 어떻게 볼지 **네 가지**로 지정합니다.

| 설정 | 동작 |
|---|---|
| `notBreaching` | 누락을 **"정상"**으로 본다 |
| `breaching` | 누락을 **"이상"**으로 본다 |
| `ignore` | **현재 알람 상태를 유지**한다 |
| `missing` | 평가 범위의 데이터가 **전부 누락이면 INSUFFICIENT_DATA**로 간다 |

- **기본값은 `missing`입니다.** ⚠️⚠️ 단 **`AWS/DynamoDB` 네임스페이스 지표를 평가하는 알람은 기본이 `ignore`**입니다(명시적으로 바꿀 수 있습니다)
- 선택 기준은 **지표의 성질**입니다. 계속 데이터를 보내는 지표로 롤백 알람을 만든다면 누락은 **`breaching`**이 맞고, DynamoDB의 `ThrottledRequests`처럼 **오류가 있을 때만 데이터가 생기는** 지표라면 **`notBreaching`**이 맞습니다
- ⚠️⚠️ **EC2 지표 알람에 중지·종료·재부팅·복구 작업을 붙였다면** 누락을 **`missing`**으로 두고 **ALARM 상태에서만** 동작하게 두라고 공식이 권합니다. EC2 지표 보고가 끊기면 **인스턴스가 정상인데도** 드물게 `INSUFFICIENT_DATA`로 갈 수 있기 때문입니다
- ⚠️ **누락 데이터 설정이 무시되는 경우가 있습니다.** 평가 범위에서 실제로 가져온 데이터 포인트 수가 **Evaluation Periods 이상이면** CloudWatch는 실제 데이터만으로 평가하고 누락 설정을 쓰지 않습니다. 더 넓은 평가 범위는 **슬라이딩 창에만** 적용되고 **벽시계 창은 정렬된 창의 데이터만** 조회합니다

### 5) 정기 평가와 조사를 자동화한다 (기술 1.1.5) {#automation}

공식 예시는 **AWS Config 준수 팩 · Security Hub · AWS Systems Manager State Manager 연결**입니다.

#### 5-1. AWS Config 준수 팩

**AWS Config 규칙과 개선 조치의 모음**을 계정·리전 단위 또는 **조직 전체에 단일 엔터티로 배포**합니다. **YAML 템플릿**으로 만들고, 관리형 규칙·사용자 지정 규칙·개선 조치를 담습니다.

- ⚠️ **SSM 문서에 템플릿을 저장해 SSM 문서 이름으로 직접 배포**할 수 있습니다 — 템플릿을 버전 관리하는 경로입니다
- ⚠️ **지원 리전이 제한적이고, 조직 멤버 계정 배포의 지원 리전은 그보다 더 좁습니다.** "전 리전에 조직 준수 팩을 배포한다"는 설계는 리전 목록을 먼저 확인해야 합니다
- 빠른 시작용 **샘플 준수 팩 템플릿**이 제공되고, 처음부터 쓰는 **사용자 지정 준수 팩**도 가능합니다

> ⚠️ **표기 메모** — 이 기능의 영문 이름은 `Conformance Packs`입니다. 한국어 표기가 세 가지로 갈려 있습니다: SCS 공식 시험 가이드는 **「준수 팩」**, SOA 공식 시험 가이드는 「규정 준수 팩」, AWS Config 한국어 제품 문서(기계 번역)는 「적합성 팩」입니다. **이 사이트의 SCS 문서는 SCS 가이드 표기를 따라 「준수 팩」으로 적습니다.** 시험장에서 다른 표기를 보더라도 같은 기능입니다.

#### 5-2. Security Hub CSPM의 표준과 제어

보안 표준(AWS 기초 보안 모범 사례(FSBP) · CIS · PCI DSS · NIST)을 켜면 **제어마다 점검을 돌려 제어 조사 결과**를 만들고 **보안 점수**를 계산합니다. 자동화 규칙으로 조사 결과를 자동 갱신하고, **EventBridge 통합**으로 특정 조사 결과에 자동 대응을 걸 수 있습니다.

#### 5-3. State Manager 연결

Systems Manager State Manager는 **관리형 노드를 내가 정의한 상태로 유지**합니다. 「연결(association)」이 그 단위이고, 문서·대상·일정을 묶습니다. 에이전트 설치·구성 파일 배포처럼 **"이 상태여야 한다"를 반복 적용**하는 데 씁니다.

⚠️ **세 수단은 층이 다릅니다.** 준수 팩은 **구성이 규칙에 맞는지 평가**하고, Security Hub CSPM은 **여러 소스의 조사 결과를 모아 점수로** 만들고, State Manager는 **원하는 상태를 실제로 적용**합니다. 문항이 "평가"를 물으면 앞의 둘, "유지·적용"을 물으면 State Manager입니다.

## ✍️ 시험 포인트

- **"이 사실을 알려면 무엇을 켜야 하나"** — 민감 데이터의 위치는 Macie, 유출 시도는 GuardDuty(S3 Protection), 둘이 겹친 실제 위험은 신 Security Hub의 노출 조사 결과입니다
- **형식이 갈림길인 문항** — 기존 자동화가 **ASFF**를 전제로 돌고 있는데 신 Security Hub 조사 결과를 받으려면? 형식이 **OCSF**이고 EventBridge `detail-type`도 다릅니다(CSPM은 `Security Hub Findings – Imported`, 신 제품은 `Findings Imported V2`)
- **소급 함정** — 사고가 **난 뒤에** Security Hub CSPM을 켜면 그 전 조사 결과는 집계되지 않습니다
- **리전 함정** — 홈 리전으로 옵트인 리전을 고르려는 설계, 그리고 "한 리전에만 켜고 CIS 전체 준수를 기대하는" 설계
- **크로스 계정 링크 실패** — 소스 계정이 모니터링 계정보다 많은 원격 측정 유형을 선택한 경우
- **누락 데이터** — EC2 복구 작업 알람에 `breaching`을 주면 정상 인스턴스를 재부팅할 수 있습니다
- **평가 상태** — "알람이 ALARM으로 가지 않는다"의 원인이 `IN_WARM_UP`이나 `EVALUATION_ERROR`일 수 있습니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"Security Hub를 켜면 과거 조사 결과도 모인다"** → **아닙니다.** 소급 적용되지 않습니다
- ❌ **"Security Hub CSPM만 켜면 제어 조사 결과가 다 생긴다"** → **대부분의 제어는 AWS Config를 켜고 리소스를 기록해야** 합니다
- ❌ **"GuardDuty의 다단계 공격 탐지는 유료 플랜이다"** → **Extended Threat Detection은 추가 비용이 없고 자동입니다**
- ❌ **"S3 업로드 악성코드를 스캔하려면 GuardDuty를 켜야 한다"** → **Malware Protection for S3는 단독으로** 쓸 수 있습니다
- ❌ **"Macie가 모든 스토리지의 민감 데이터를 찾아 준다"** → 대상은 **S3**입니다
- ❌ **"Security Lake를 켜면 탐지가 된다"** → Security Lake는 **모으고 정규화**합니다. 탐지는 다른 서비스가 합니다
- ❌ **"크로스 계정 관측성으로 다른 리전 데이터도 본다"** → 그것은 **리전 안**의 계정 경계를 넘는 기능입니다. 리전을 넘는 것은 Security Hub 크로스 리전 집계이거나 **크로스 계정 크로스 리전 대시보드**입니다
- ❌ **"알람 누락 데이터 기본값은 notBreaching이다"** → 기본은 **`missing`**이고 **DynamoDB 네임스페이스만 `ignore`**입니다
- ❌ **"위임 관리자는 아무 계정이나 고를 수 있다"** → **CSPM 위임 관리자가 멤버 계정으로 지정돼 있으면 그 계정이 자동으로 Security Hub 위임 관리자**가 되고, **조직 관리 계정은 고를 수 없습니다**

## 🧪 자가 점검

**Q1.** 한 리전에서 20개 계정의 CloudWatch 지표와 로그를 중앙 계정에서 보려 합니다. 중앙 계정에서는 지표·로그·트레이스를 공유받도록 설정했고, 어느 소스 계정은 지표·로그·트레이스·**Application Signals**까지 공유하도록 설정했습니다. 어떻게 됩니까? (→ 3-1 계정을 넘는다)

<details><summary>정답 보기</summary>

**그 소스 계정의 링크 생성이 실패하고 아무것도 공유되지 않습니다.** 공식이 비대칭을 명시합니다 — 모니터링 계정에 **더 많은** 원격 측정 유형이 선택돼 있으면 계정은 연결되고 **양쪽에서 선택된 것만** 공유되지만, **소스 계정에 더 많은 유형이 선택돼 있으면 링크 생성이 실패합니다.**

⚠️ 함께 기억할 것: **sink는 계정·리전당 하나**, **모니터링 계정당 소스 계정 최대 100,000개**, **소스 계정당 모니터링 계정 최대 5개**, 링크 제거는 **소스 계정에서**.
</details>

**Q2.** 보안팀이 "EC2 인스턴스가 응답하지 않으면 자동 복구하라"는 알람을 만들었습니다. 지표 데이터가 간헐적으로 끊기는 환경이고, 누락 데이터를 `breaching`으로 설정했습니다. 무엇이 문제이고 공식 권장은 무엇입니까? (→ 4-3 누락 데이터 처리)

<details><summary>정답 보기</summary>

**정상 인스턴스가 복구(재부팅) 작업을 받을 수 있습니다.** 공식은 EC2 지표 알람이 **지표 보고가 끊기면 인스턴스가 정상인데도 드물게 `INSUFFICIENT_DATA`로 갈 수 있다**고 적고, **중지·종료·재부팅·복구 작업을 붙인 알람은 누락 데이터를 `missing`으로 두고 ALARM 상태에서만 동작하게** 하라고 권합니다.

`breaching`은 "계속 데이터를 보내는 지표"로 **롤백 알람**을 만들 때 맞는 선택입니다. 반대로 오류가 있을 때만 데이터가 생기는 지표(예: DynamoDB `ThrottledRequests`)는 **`notBreaching`**이 맞습니다.
</details>

**Q3.** 조직에서 Security Hub CSPM 위임 관리자를 보안 도구 계정(멤버 계정)으로 이미 지정해 뒀습니다. 이제 신 Security Hub를 조직에 켜려 하는데, 다른 멤버 계정을 Security Hub 위임 관리자로 쓰고 싶습니다. 가능합니까? (→ 3-3 활성화 순서)

<details><summary>정답 보기</summary>

**불가능합니다.** 공식 활성화 문서가 적습니다 — CSPM 위임 관리자가 구성돼 있고 **그 계정이 조직 관리 계정이 아니면, 그 계정이 자동으로 Security Hub 위임 관리자가 되고 다른 계정을 고를 수 없습니다.** 고를 수 있는 것은 CSPM 위임 관리자가 **관리 계정이거나 아예 지정되지 않은** 경우이고, 그때도 **조직 관리 계정은 제외**됩니다.

⚠️ 다만 **CSPM이 신 Security Hub의 전제 조건은 아닙니다** — "Security Hub는 어떤 AWS 계정에서도 켤 수 있다"가 공식 문장이고, 독립 계정 절차에는 CSPM 선행 요건이 없습니다. 묶이는 것은 **위임 관리자 선택**입니다.
</details>

**Q4.** Amazon Inspector가 EC2 인스턴스에서 심각한 취약성을 찾았고, Security Hub CSPM이 같은 인스턴스의 보안 그룹 구성 위반을 찾았습니다. "이 둘이 합쳐져 실제로 악용 가능한 경로가 되는지"를 보고하는 것은 무엇이고, 그 조사 결과는 어떤 형식입니까? (→ 4-1 경계 표)

<details><summary>정답 보기</summary>

**신 `Security Hub`의 노출 조사 결과**이고 형식은 **OCSF**입니다. 공식은 Security Hub가 **Security Hub CSPM · Inspector · GuardDuty · Macie의 신호를 상관**해 노출 조사 결과를 만들고, **네트워크 도달 가능성**을 평가해 **공격 경로와 폭발 반경**을 보여 준다고 적습니다.

⚠️ `Security Hub CSPM`은 조사 결과를 **ASFF**로 모아 점수를 내지만 **상관해 공격 경로를 만들지는 않습니다.** 두 제품을 「Security Hub」 한 이름으로 섞으면 이 문항을 가를 수 없습니다.

⚠️ 리소스 하나는 **최대 하나의 노출 조사 결과에서만 주 리소스**가 되고, 기여 특성이 없거나 부족하면 조사 결과가 **생성되지 않습니다**.
</details>

**Q5.** "조직 전체 계정에서 S3 버킷 암호화 규칙과 그 개선 조치를 한 번에 배포하고 정기적으로 평가하라"는 요구입니다. 어느 수단이고, 설계 전에 반드시 확인할 것은 무엇입니까? (→ 5-1 준수 팩)

<details><summary>정답 보기</summary>

**AWS Config 준수 팩**입니다(조직 준수 팩). 규칙과 **개선 조치**를 YAML 템플릿에 담아 **단일 엔터티로** 배포합니다.

⚠️ 확인할 것은 **리전 지원**입니다. 공식 문서가 준수 팩 지원 리전 표와 **조직 멤버 계정 배포 지원 리전 표를 따로** 싣고, **후자가 더 좁습니다.** "전 리전에 조직 준수 팩" 설계는 목록을 먼저 봐야 합니다.

⚠️ 템플릿을 **SSM 문서에 저장해 문서 이름으로 배포**할 수도 있습니다. 그리고 「적용」이 필요한 일(에이전트 설치 등)은 준수 팩이 아니라 **State Manager 연결**의 몫입니다.
</details>

**Q6.** 알람을 만들었는데 임계값을 넘는 데이터가 보이는데도 ALARM으로 바뀌지 않습니다. 상태는 `INSUFFICIENT_DATA`입니다. 콘솔에서 무엇을 먼저 봐야 합니까? (→ 2 모니터링 전략과 상태 확인)

<details><summary>정답 보기</summary>

**평가 상태(evaluation state)**입니다. 알람 상태 셋(`OK`·`ALARM`·`INSUFFICIENT_DATA`)과 **별도로** 평가 과정을 알려 주는 상태가 있고, 콘솔의 알람 상세나 `describe-alarms`(`DescribeAlarms`)로 볼 수 있습니다.

- **`IN_WARM_UP`** — 워밍업 기간이라 **아직 평가하지 않고** `INSUFFICIENT_DATA`에 머물며 **작업을 실행하지 않습니다.** 방금 만든 알람이라면 이것이 가장 유력합니다
- **`EVALUATION_ERROR`** — **구성 오류**입니다. 알람의 `StateReason`을 봅니다
- **`PARTIAL_DATA`** — 쿼터 제한으로 데이터를 **전부 가져오지 못했습니다**
- **`EVALUATION_FAILURE`** — 일시적인 CloudWatch 문제입니다

⚠️ 그리고 **다중 일 알람**(평가 기간 수 × 기간 길이가 하루를 넘는 알람)은 **시간당 한 번만** 평가됩니다 — "왜 즉시 안 바뀌나"의 또 다른 원인입니다.
</details>

---

### 📌 출처

1. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-08 확인)
2. Exposure findings in Security Hub — `docs.aws.amazon.com/securityhub/latest/userguide/exposure-findings.html` (2026-11-08 확인)
3. Enabling Security Hub (위임 관리자·서비스 연결 리소스) — `docs.aws.amazon.com/securityhub/latest/userguide/securityhub-v2-enable.html` (2026-11-08 확인)
4. Understanding cross-Region aggregation in Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/finding-aggregation.html` (2026-11-08 확인)
5. Understanding cross-Region aggregation in Security Hub — `docs.aws.amazon.com/securityhub/latest/userguide/security-hub-region-aggregation.html` (2026-11-08 확인)
6. What is Amazon GuardDuty? — `docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html` (2026-11-08 확인)
7. What is Amazon Macie? — `docs.aws.amazon.com/macie/latest/user/what-is-macie.html` (2026-11-08 확인)
8. What is Amazon Security Lake? — `docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html` (2026-11-08 확인)
9. Alarm evaluation — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html` (2026-11-08 확인)
10. Configuring how CloudWatch alarms treat missing data — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html` (2026-11-08 확인)
11. CloudWatch cross-account observability — `docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Unified-Cross-Account.html` (2026-11-08 확인)
12. Conformance Packs for AWS Config — `docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html` (2026-11-08 확인)
13. AWS Systems Manager State Manager — `docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-state.html` (2026-11-08 확인)
