---
examGuideTaskId: soa-t4-2
certCode: SOA-C03
domain: 4
domainName: 보안 및 규정 준수
domainWeightPct: 16
title: 규정 준수·거버넌스 — Config·Security Hub·GuardDuty·Inspector
coversTasks:
  - "4.1"
sources:
  - title: AWS Config — 소개 (공식)
    url: https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html
  - title: AWS Config 규칙으로 리소스 평가 (공식)
    url: https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html
  - title: AWS Security Hub — 소개 (공식)
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
  - title: Amazon GuardDuty — 소개 (공식)
    url: https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
  - title: Amazon Inspector — 소개 (공식)
    url: https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html
  - title: AWS Trusted Advisor (공식)
    url: https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
  - title: AWS Support 플랜 — 현행 목록 (공식)
    url: https://aws.amazon.com/premiumsupport/plans/
  - title: 조직 전체의 규정 준수 팩 관리 API (공식)
    url: https://docs.aws.amazon.com/config/latest/developerguide/conformance-pack-organization-apis.html
  - title: AWS 전역 조건 컨텍스트 키 — aws:RequestedRegion (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html
  - title: AWS Security Agent (공식 제품 페이지)
    url: https://aws.amazon.com/security-agent/
  - title: AWS Security Agent 사용자 안내서 — 조사 결과 (공식)
    url: https://docs.aws.amazon.com/securityagent/latest/userguide/run-diff-scan-s3.html
lastVerified: 2026-10-20
---

# 규정 준수·거버넌스 — Config·Security Hub·GuardDuty·Inspector

> **커버하는 공식 Task** — SOA-C03 · 도메인 4 「보안 및 규정 준수」(16%) · **Task 4.1 보안 및 규정 준수 도구와 정책 구현 및 관리** (`soa-t4-2`)
> 이 문서는 **거버넌스·위협 탐지·취약점 스캔** 도구에 집중합니다. IAM·계정 보안은 `soa-t4-1`, 데이터·인프라 암호화는 `soa-t4-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 운영할 수 있어야 합니다.

- [ ] **각 도구가 무엇을 보는가** — Config(구성)·GuardDuty(위협)·Inspector(취약점)·Macie(민감정보)를 명확히 구분한다
- [ ] **AWS Config** — 구성 기록·규칙 평가·규정 준수 팩·SSM 자동 교정을 설명할 수 있다
- [ ] **Security Hub** — 보안 표준(CIS/FSBP)·통합 결과(ASFF)·보안 점수의 역할을 안다
- [ ] **GuardDuty** — 에이전트 없이 로그 분석으로 위협을 탐지함을 설명할 수 있다
- [ ] **Inspector** — EC2·ECR·Lambda 취약점(CVE)을 자동·지속 스캔함을 안다
- [ ] **Trusted Advisor** — 5개 점검 범주(비용·보안·내결함성·성능·서비스 한도)를 안다
- [ ] **결과 통합 운영** — 여러 도구의 결과를 Security Hub로 모으고 자동 대응을 거는 흐름을 그린다

---

## 🎯 왜 중요한가

- 도메인 4는 "보안 도구를 구현하고 **관리**한다"가 핵심입니다. 운영자는 어느 도구가 무엇을 탐지/평가하는지를 정확히 알고, 결과를 통합해 **지속적 규정 준수**를 유지해야 합니다.
- 시험은 도구를 **헷갈리게 섞어** 냅니다. "EC2 인스턴스의 비정상 아웃바운드 트래픽 탐지"는 GuardDuty, "EC2의 미패치 CVE 스캔"은 Inspector, "S3 버킷이 퍼블릭으로 바뀌었는지"는 Config — 이 경계를 못 그으면 오답으로 유도됩니다.
- SOA는 일회성이 아니라 **지속 모니터링**을 강조합니다. Config 규칙으로 비준수를 자동 평가하고 SSM으로 자동 교정하며, 결과를 Security Hub로 통합하는 운영 루프를 묻습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **VPC 흐름 로그** | VPC Flow Logs | VPC 안에서 오가는 IP 트래픽의 메타데이터(소스·대상 IP·포트·허용/거부 여부)를 기록하는 로그 — 네트워크 망의 CCTV 기록 같은 것 |
| **AWS CloudTrail** | AWS CloudTrail | AWS 계정 안에서 발생한 API 호출과 콘솔 활동을 감사 로그로 남기는 서비스 |
| **Amazon EventBridge** | Amazon EventBridge | AWS 서비스·애플리케이션의 이벤트를 받아 규칙에 따라 Lambda·SNS 등 대상으로 라우팅하는 이벤트 버스 |
| **SSM 자동화 런북** | SSM Automation Runbook | AWS Systems Manager Automation이 실행하는 단계별 운영 자동화 절차서 — 비준수 리소스를 자동 교정할 때 사용 |
| **ASFF** | AWS Security Finding Format | Security Hub가 여러 보안 서비스의 결과를 하나의 형식으로 정규화하는 JSON 스키마 |
| **위협 인텔리전스** | Threat Intelligence | 알려진 악성 IP·도메인·패턴 목록을 뜻하며, GuardDuty가 로그와 대조해 침해 징후를 찾는 데 사용 |
| **이상 탐지** | Anomaly Detection | 평소 행동 기준선을 학습한 뒤 벗어나는 패턴을 찾아내는 기법 — GuardDuty가 비정상 API 호출을 찾을 때 쓰는 방식 |

---

## 📖 핵심 개념

### 0) 한눈에 보는 "무엇을 보는가" (★ 가장 중요)

| 도구 | 무엇을 보는가 | 데이터 소스 / 방식 |
|---|---|---|
| **AWS Config** | **구성(설정)이 규칙을 준수하는가** — 리소스 설정 변경 추적 | 리소스 구성 항목 + Config 규칙 |
| **Amazon GuardDuty** | **위협·악성 활동** — 침해 징후 | 로그 분석(VPC Flow Logs·DNS·CloudTrail), 머신러닝. **에이전트 불필요** |
| **Amazon Inspector** | **소프트웨어 취약점(CVE)·네트워크 노출** | EC2·ECR·Lambda 자동 스캔 |
| **Amazon Macie** | **민감정보(PII)가 어디 있는가** | S3 객체 머신러닝 분류 |
| **Security Hub** | 위 결과들을 **통합·표준 점검·점수화** | ASFF로 결과 집계 + 보안 표준 |
| **Trusted Advisor** | 계정 전반의 **모범 사례 점검** | 5개 범주 점검 |

> 외우는 한 줄: **Config=구성 준수, GuardDuty=위협 탐지, Inspector=취약점(CVE), Macie=민감정보, Security Hub=통합 대시보드.**

> 🧠 원리: 왜 보안 도구마다 보는 대상이 분리되어 있을까요?
> "구성", "위협 활동", "소프트웨어 취약점", "민감정보"는 각각 다른 데이터 소스와 분석 기법을 요구합니다.
> 하나의 도구가 모두를 처리하려면 서로 다른 수집 경로·모델을 하나의 서비스 안에 뭉쳐야 해, 평가 지연과 노이즈가 커집니다.
> 도구를 역할별로 분리하면 각 도구가 자신의 데이터 소스에 최적화된 방식으로 동작하고, 결과를 Security Hub에서 한 화면으로 통합하는 구조가 됩니다.
> 운영자 입장에서는 "어떤 도구가 무엇을 탐지했는가"가 명확해져 후속 조치 우선순위를 정하기 쉬워집니다.

### 1) AWS Config — 구성 기록과 규칙 평가

> 공식 정의: **"AWS 리소스의 구성을 평가·감사·심사할 수 있게 하는 서비스."** Config는 리소스 설정의 **시간에 따른 변화**를 기록하고, 원하는 상태와 비교합니다.

| 구성 요소 | 설명 |
|---|---|
| **구성 항목/기록기(Configuration Recorder)** | 리소스의 현재 설정을 스냅샷으로 기록하고 변경 이력을 보관 |
| **Config 규칙(Rule)** | 리소스가 *준수(COMPLIANT)/비준수(NONCOMPLIANT)*인지 평가. AWS 관리형 규칙 또는 Lambda/Guard 커스텀 규칙 |
| **규정 준수 팩(Conformance Pack)** | 규칙·교정 액션을 묶은 패키지를 한 번에 배포(예: PCI/HIPAA 운영 모범 사례 팩) |
| **자동 교정(Remediation)** | 비준수 리소스를 **SSM Automation 런북**으로 자동 수정(예: 퍼블릭 버킷 차단) |

> **운영 흐름**: 구성 변경 발생 → Config 규칙이 평가 → NONCOMPLIANT면 SSM Automation 교정 실행 또는 EventBridge로 알림. "S3 퍼블릭 차단", "EBS 암호화 미설정 볼륨 탐지" 같은 가드레일을 **지속적으로** 강제합니다.

> 🧠 원리: 왜 Config는 "변경이 발생할 때"가 아니라 "지속적으로" 규칙을 평가할까요?
> 리소스 설정은 콘솔·CLI·자동화 스크립트 등 다양한 경로로 언제든 바뀔 수 있습니다.
> 변경 이벤트만 감시하면 이벤트가 누락된 경우나 드리프트가 누적된 상태를 놓칩니다.
> 지속 평가 방식은 어떤 경로로 구성이 바뀌었든 다음 평가 주기에 비준수 상태를 반드시 포착하게 합니다.
> 이 덕분에 수동 변경, 자동화 오류, 권한 부여된 예외 처리 후 미복구 같은 상황도 동일한 가드레일 안에 들어옵니다.

### 2) Security Hub — 보안 표준·통합 결과·점수

> 공식 정의: **"여러 AWS 서비스와 파트너 제품의 보안 경보를 한곳에서 보고, 보안 표준에 대해 환경을 자동 점검하는 서비스."**

- **보안 표준 자동 점검**: **CIS AWS Foundations Benchmark**, **AWS Foundational Security Best Practices(FSBP)**, PCI DSS 등 표준에 대해 환경을 점검하고 **보안 점수(%)**를 산출합니다.
- **통합 결과 형식(ASFF)**: GuardDuty·Inspector·Macie·Config 등 여러 서비스의 결과를 **AWS Security Finding Format**으로 정규화해 한 화면에 모읍니다.
- **자동 대응**: 결과를 EventBridge로 보내 Lambda·SSM으로 자동 조치(티켓 생성, 격리 등)를 트리거합니다.

> Security Hub는 **탐지 도구가 아니라 통합·표준화 계층**입니다. 직접 위협을 찾기보다, GuardDuty/Inspector 등이 찾은 것을 모아 우선순위화합니다.

> 🧠 원리: 왜 Security Hub는 직접 탐지하지 않고 다른 서비스의 결과를 모으는 역할에 집중할까요?
> 각 탐지 서비스(GuardDuty·Inspector·Macie 등)는 자신만의 데이터 소스·알고리즘에 최적화되어 있습니다.
> Security Hub가 동일한 탐지 로직을 중복 구현하면 유지 비용이 늘고, 서비스별 고유 맥락을 잃게 됩니다.
> 대신 ASFF로 결과를 정규화해 모으면, 서로 다른 포맷의 경보를 단일 쿼리·자동화 규칙으로 다룰 수 있습니다.
> 운영자는 도구마다 콘솔을 열지 않고 한 화면에서 보안 점수와 우선순위 높은 결과를 확인할 수 있습니다.

### 3) Amazon GuardDuty — 위협 탐지 (★ Inspector와 구분)

> 공식 정의: **"악성 활동과 비인가 행위를 지속적으로 모니터링하는 위협 탐지 서비스."**

- **에이전트가 필요 없습니다.** 인스턴스에 무엇을 설치하지 않고, **로그를 분석**합니다:
  - **VPC Flow Logs** (네트워크 흐름)
  - **DNS 쿼리 로그**
  - **CloudTrail 이벤트** (관리/데이터 이벤트)
- **머신러닝·이상 탐지·위협 인텔리전스**로 침해 징후를 찾습니다. 예: 암호화폐 채굴 통신, 알려진 악성 IP와의 통신, 비정상적인 API 호출(예: 자격증명 탈취 후 권한 정찰), 포트 스캔.
- 결과는 심각도(Low/Medium/High)와 함께 제공되며 Security Hub·EventBridge로 통합됩니다.

> **추가 보호 플랜**: S3 보호, EKS/런타임 모니터링, Malware Protection, RDS 보호 등 데이터 소스를 확장할 수 있습니다(런타임 모니터링은 별도 에이전트 사용). 기본 탐지는 에이전트 없이 로그 기반이라는 점이 핵심입니다.

> 🧠 원리: 왜 GuardDuty는 인스턴스에 에이전트를 설치하지 않고 로그 분석만으로 위협을 탐지할 수 있을까요?
> 많은 침해 시나리오는 네트워크 통신(VPC Flow Logs)이나 AWS API 호출(CloudTrail) 같은 관측 가능한 신호를 남깁니다.
> 로그는 인스턴스 외부에서 수집되므로, 공격자가 인스턴스 안의 에이전트를 무력화해도 탐지 데이터가 사라지지 않습니다.
> 반면 에이전트를 설치하면 모든 EC2에 배포·업데이트·권한 관리가 필요해 운영 부담이 생기고, 에이전트 자체가 공격 표면이 될 수 있습니다.
> 로그 기반 외부 분석은 이 두 문제를 모두 피하면서 계정 전체를 동일한 방식으로 커버합니다.

### 4) Amazon Inspector — 취약점(CVE) 스캔 (★ GuardDuty와 구분)

> 공식 정의: **"워크로드의 소프트웨어 취약점과 의도치 않은 네트워크 노출을 자동으로 발견하는 취약점 관리 서비스."**

- **자동·지속 스캔 대상**: **EC2 인스턴스**, **컨테이너 이미지(ECR)**, **Lambda 함수**.
- 알려진 **CVE(소프트웨어 취약점)**와 네트워크 도달 가능성을 평가해 **위험 점수**를 매깁니다.
- 새 CVE가 공개되거나 패키지가 바뀌면 **재스캔**해 지속적으로 최신 상태를 유지합니다(스캔 일정 수동 관리 불필요).

> **GuardDuty vs Inspector 한 줄 정리**: GuardDuty = "지금 **공격/침해**가 일어나고 있는가"(행위·트래픽), Inspector = "이 워크로드에 **고칠 취약점(CVE)**이 있는가"(소프트웨어 상태).

> 🧠 원리: 왜 Inspector는 스캔 일정을 수동으로 관리하지 않아도 새 CVE를 반영할 수 있을까요?
> CVE 데이터베이스는 새 취약점이 공개될 때마다 갱신되는데, Inspector는 이 데이터베이스 갱신을 모니터링하고 영향받는 패키지가 설치된 워크로드를 자동으로 재평가합니다.
> 소프트웨어 패키지 변경(설치·업데이트·삭제)도 마찬가지로 재스캔을 트리거합니다.
> 이 방식으로 "마지막 스캔 이후 새로 공개된 CVE"가 자동으로 반영되어, 운영자가 스캔 주기를 별도로 관리할 필요가 없습니다.
> 결과적으로 취약점 스캔 상태가 현재 CVE 데이터베이스 기준으로 항상 최신을 유지합니다.

### 5) Trusted Advisor — 모범 사례 점검 5범주

> 공식 정의: **"AWS 모범 사례에 따라 환경을 점검하고 권장 사항을 제시하는 서비스."**

| 범주 | 예시 점검 |
|---|---|
| **비용 최적화** | 유휴 리소스, 미사용 EIP·로드밸런서 |
| **보안** | 퍼블릭 S3 버킷, 보안 그룹 과개방, 루트 MFA 미설정, IAM 키 노출 |
| **내결함성(Fault Tolerance)** | 다중 AZ, 백업, 스냅샷 구성 |
| **성능** | 과소/과대 프로비저닝, 서비스 한도 근접 |
| **서비스 한도(할당량)** | 계정 한도 사용률 |

> **점검 전체**는 **AWS Business Support+ · AWS Enterprise Support · AWS Unified Operations** 플랜 고객에게 제공됩니다. **Basic Support** 플랜에서는 **서비스 한도 범주의 모든 점검**과 **보안·내결함성 범주의 선택된 점검**만 콘솔에서 볼 수 있고, **자동 갱신이 제공되지 않아** 보안 범주 점검은 수동으로 새로 고쳐야 합니다. (과거 자료의 Developer·Business·Enterprise On-Ramp 플랜은 **2027-01-01 종료** 예정이라 플랜 명칭이 달라졌습니다.)

> 🧠 원리: 왜 Trusted Advisor의 점검 범위가 지원 플랜에 따라 달라질까요?
> Trusted Advisor 점검은 계정 구성을 지속적으로 평가하고 결과를 갱신하는 운영 서비스이므로, AWS는 이 범위를 지원 플랜의 구성 요소로 제공합니다.
> Basic 플랜에서는 서비스 한도 전체와 보안·내결함성의 선택된 점검만 열리고 자동 갱신이 없어, 운영자가 콘솔에서 직접 새로 고쳐야 최신 결과를 봅니다.
> 따라서 Basic 환경을 점검할 때는 "보이지 않는 점검 항목이 있고, 보이는 항목도 자동으로 갱신되지 않는다"는 두 가지를 전제로 결과를 읽어야 합니다.

### 6) Amazon Detective (간단 참고)

- GuardDuty 등이 결과를 *탐지*하면, Detective는 그 **근본 원인 조사(분석·시각화)**를 돕습니다. 로그를 그래프로 연결해 "이 IP가 어떤 리소스와 언제 통신했는지"를 추적합니다. **탐지가 아니라 사후 조사** 도구라는 점이 구분 포인트입니다.

> 🧠 원리: 왜 탐지 경보만으로는 보안 사고의 범위를 파악하기 어렵고, 별도 조사 도구가 필요할까요?
> GuardDuty 같은 탐지 서비스는 개별 이벤트를 경보로 알리지만, 경보들 사이의 연관 관계(어떤 IP가 언제 어떤 리소스를 거쳐 이동했는지)를 자동으로 연결하지는 않습니다.
> 사고 범위를 파악하려면 수십~수백 개의 로그 항목을 손으로 교차 검색해야 해, 시간이 길어질수록 추가 피해 위험이 커집니다.
> Detective는 이미 수집된 로그 데이터를 그래프 구조로 미리 인덱싱해, 운영자가 "이 엔티티와 연결된 활동 전체"를 수 클릭으로 조회할 수 있게 합니다.
> 탐지(GuardDuty)와 조사(Detective)를 분리한 구조 덕분에 각 단계에 최적화된 방식으로 대응할 수 있습니다.

### 7) 규정 준수 요구 사항 적용 — 규정 준수 팩·리전 및 서비스 선택 (v1.1 신규 범위)

공식 가이드 v1.1은 Skill 4.1.5를 **「규정 준수 요구 사항 및 지속적인 모니터링 적용(예: 리전 및 서비스 선택, AWS Config 규정 준수 팩)」**으로 확장했습니다(v1.0은 「규정 준수 요구 사항 적용(예: AWS 리전 및 서비스 선택)」). 예시 두 개가 그대로 출제 축입니다.

**① AWS Config 규정 준수 팩(Conformance Pack) — 조직 단위로 배포:**

- 규정 준수 팩은 **Config 규칙과 (선택적으로) 교정 작업을 묶은 묶음**으로, 한 계정·한 리전에 **또는 AWS Organizations 조직 전체에** 하나의 단위로 배포합니다(§1).
- 조직 배포는 **`PutOrganizationConformancePack`** API가 조직의 회원 계정 전체에 팩을 배치합니다. 배포 전에 **Config 기록이 켜져 있어야** 합니다.
- 조직 규정 준수 팩은 **관리 계정 또는 위임 관리자(delegated administrator) 계정**에서 배포할 수 있습니다. 보안상 위임 관리자 계정을 쓰는 편이 권장됩니다(관리 계정에 워크로드·운영을 모으지 않는다는 `soa-t4-1` §7 원칙과 같은 방향).
- 운영 API 묶음: 배포는 `PutOrganizationConformancePack`, 조회는 `DescribeOrganizationConformancePacks`, 배포 상태는 `DescribeOrganizationConformancePackStatuses`, 계정별 상세는 `GetOrganizationConformancePackDetailedStatus`, 삭제는 `DeleteOrganizationConformancePack`입니다. **삭제는 모든 회원 계정에서 규칙과 교정 작업을 함께 제거**합니다.
- 이것이 Skill 문구의 **「지속적인 모니터링」**에 해당하는 수단입니다: 팩을 조직에 한 번 배포해 두면 새 계정·새 리소스도 같은 가드레일 안에서 계속 평가됩니다.

**② 리전 및 서비스 선택 — `aws:RequestedRegion`:**

- **`aws:RequestedRegion`**은 요청이 호출한 리전을 정책에 적힌 리전과 비교하는 **전역 조건 키**입니다. 이 키로 **어느 리전을 요청할 수 있는지** 통제합니다. 항상 요청 컨텍스트에 포함되는 단일 값 문자열입니다.
- 모든 서비스·모든 작업에 적용되므로, SCP(`soa-t4-1` §8)나 자격증명 기반 정책에 넣어 "승인된 리전만 사용" 가드레일을 만듭니다.
- **함정 1 — 글로벌 서비스:** IAM처럼 **단일 엔드포인트를 쓰는 일부 글로벌 서비스**는 엔드포인트가 US East(N. Virginia)에 물리적으로 있어 **IAM 호출이 항상 `us-east-1`로 나갑니다.** 따라서 "요청 리전이 `us-west-2`가 아니면 모두 거부"하는 정책을 만들면 **IAM 호출이 전부 실패**합니다. 글로벌 서비스를 `NotAction`으로 빼는 식의 예외가 필요합니다.
- **함정 2 — 영향 범위 ≠ 호출 리전:** 이 조건 키는 **어느 엔드포인트가 호출되는지를 통제하지만 그 작업의 영향(impact)은 통제하지 않습니다.** 일부 서비스는 리전을 넘는 영향을 갖습니다. 예를 들어 `s3:PutBucketReplication`은 한 리전에서 호출되지만 복제 구성에 따라 **다른 리전이 영향을 받습니다.** `s3:CreateBucket`으로 다른 리전에 버킷을 만들 수도 있어, 이 경우는 **`s3:LocationConstraint`** 조건 키로 통제합니다.

> 정리: 데이터 거주(data residency) 요구를 `aws:RequestedRegion` 하나로 완결했다고 보면 안 됩니다. **호출 리전 통제 + 리전 간 영향을 갖는 작업의 개별 통제 + Config 규정 준수 팩의 지속 평가**가 함께 필요합니다.

> 🧠 원리: 왜 리전 조건 키만으로는 데이터 거주 요구를 충족할 수 없을까요?
> `aws:RequestedRegion`은 요청이 **어느 엔드포인트로 들어갔는지**를 기준으로 평가됩니다. 이는 접근 통제가 관찰할 수 있는 유일한 지점이 호출 시점이기 때문입니다.
> 그런데 일부 API는 호출 한 번으로 **다른 리전의 상태를 바꿉니다.** S3 복제 구성이 대표적입니다 — 호출은 한 리전에서 일어나지만 데이터는 구성에 적힌 목적지 리전으로 흐릅니다. 조건 키는 그 흐름을 볼 수 없습니다.
> 그래서 통제가 두 층으로 갈립니다: 호출 자체는 조건 키로 막고, **리전 간 영향을 갖는 작업은 그 작업 고유의 조건 키**(예: `s3:LocationConstraint`)나 리소스 정책으로 따로 막습니다.
> 마지막으로 "이미 만들어진 리소스가 지금도 규정을 지키는가"는 접근 통제가 답할 수 없는 질문이라, **Config 규정 준수 팩의 지속 평가**가 세 번째 층으로 필요합니다.

### 8) AWS Security Agent — 조사 결과의 새 소스 (v1.1 신규 범위)

공식 가이드 v1.1은 Skill 4.2.5의 조사 결과(finding) 소스 목록에 **AWS Security Agent**를 추가했습니다(기존: Security Hub · GuardDuty · Config · Inspector).

> ℹ️ 공식 제품 페이지의 제목은 **"AWS Security Agent (now part of AWS Continuum)"** 로, **AWS Continuum**의 일부로 병기돼 있습니다. v1.1에서 처음 등장한 항목이라 공식 문서가 밝히는 범위만 적습니다.

- 공식 정의: **개발 수명 주기 전반에서 애플리케이션을 선제적으로 보호하는 프런티어 에이전트**입니다.
- 주요 기능:
  - **애플리케이션에 맞춰 수행하는 온디맨드 침투 테스트(penetration testing)** — 검증된 보안 위험을 찾아 보고합니다.
  - **위협 모델(threat model) 생성**과 **코드 보안 검토(code security review)** 수행 — 취약점을 찾고 검증하고 교정까지 제공합니다.
- 조사 결과(finding)에 담기는 것: 보안 문제 설명 · **심각도(Critical·High·Medium·Low)** · 코드 위치 · 영향에 대한 위험 추론 · **교정 지침**.
- 다른 서비스와의 경계:

| 서비스 | 무엇을 보는가 | 시점 |
|---|---|---|
| **Inspector** | 알려진 취약점(CVE) 스캔 | 배포된 리소스(EC2·ECR·Lambda) |
| **GuardDuty** | 런타임 위협·악성 활동 | 운영 중 |
| **Config** | 구성 준수 | 운영 중(지속 평가) |
| **AWS Security Agent** | **애플리케이션 고유의 보안 위험**(침투 테스트·위협 모델·코드 검토) | **개발 수명 주기 전반** |
| **Security Hub** | 위 결과들을 **집계·표준 점검** | 상시 |

> 경계 정리: Inspector가 **알려진 CVE**를 찾는 쪽이라면, Security Agent는 **직접 작성한 코드의 애플리케이션 고유 위험**을 침투 테스트로 검증하는 쪽입니다. Security Agent는 Security Hub나 GuardDuty의 하위 기능이 아니라 **별도 서비스**이며, Skill 4.2.5의 문맥에서는 **조사 결과를 만들어 내는 또 하나의 소스**로 읽습니다.

> 🧠 원리: 왜 CVE 스캔과 별개로 애플리케이션 고유 위험을 찾는 수단이 따로 필요할까요?
> Inspector 같은 CVE 스캔은 **이미 공개된 취약점 목록과 설치된 패키지·버전을 대조**합니다. 대조할 식별자가 존재한다는 전제가 깔려 있습니다.
> 그러나 직접 작성한 코드의 결함에는 대조할 CVE가 없습니다. 권한 검사를 빠뜨린 관리자 엔드포인트처럼 **코드가 "설계대로" 동작하는데도 위험한** 경우가 그렇습니다. 목록 대조 방식은 이런 결함을 원리적으로 찾을 수 없습니다.
> 그래서 접근법이 갈립니다: 알려진 취약점은 **목록 대조**로, 애플리케이션 고유 위험은 **실제로 공격을 시도해 보는 방식**(침투 테스트)과 위협 모델·코드 검토로 찾습니다.
> 운영자 관점의 함의는 **두 결과를 같은 심각도 척도로 단순 비교하지 말아야 한다**는 점입니다. 전자는 패치로 닫히고, 후자는 설계·코드 수정이 필요해 교정 경로가 다릅니다.

---

## ✍️ 시험 포인트

- **Config = 구성 준수**(설정이 규칙을 지키나). 비준수 시 **SSM Automation 자동 교정** + 규정 준수 팩으로 묶어 배포.
- **GuardDuty = 위협 탐지**. **에이전트 불필요**, VPC Flow Logs·DNS·CloudTrail을 머신러닝으로 분석.
- **Inspector = 취약점(CVE) 스캔**. 대상은 **EC2·ECR(컨테이너)·Lambda**. 지속 재스캔.
- **Macie = S3 민감정보(PII) 탐지** (데이터 *내용*). Inspector(취약점)·GuardDuty(위협)와 혼동 금지.
- **Security Hub = 통합·표준 점검(CIS/FSBP)·보안 점수**. 직접 탐지하지 않고 결과를 **ASFF**로 모은다.
- **Trusted Advisor 5범주**: 비용·보안·내결함성·성능·서비스 한도. 점검 전체는 **Business Support+·Enterprise·Unified Operations** 플랜, **Basic**은 서비스 한도 전체 + 보안·내결함성 선택 점검(자동 갱신 없음).
- **Detective = 사후 근본 원인 조사**(탐지 아님).
- **결과 통합 흐름**: 탐지 도구(GuardDuty/Inspector/Macie/Config) → Security Hub 집계 → EventBridge → Lambda/SSM 자동 대응.
- **규정 준수 팩 조직 배포 = `PutOrganizationConformancePack`**. **관리 계정 또는 위임 관리자**에서 배포. 배포 전 **Config 기록 활성화** 필요. 삭제 시 회원 계정의 규칙·교정까지 제거.
- **`aws:RequestedRegion` = 호출 리전 통제 전역 조건 키.** 함정 ①**IAM 등 글로벌 서비스는 항상 `us-east-1`** → 예외 없으면 전부 실패. 함정 ②**호출 리전은 막아도 리전 간 영향은 못 막는다**(예: `s3:PutBucketReplication`; 버킷 위치는 `s3:LocationConstraint`).
- **AWS Security Agent**(공식 제목에 **AWS Continuum** 병기) = **온디맨드 침투 테스트·위협 모델·코드 보안 검토**로 애플리케이션 고유 위험을 찾는 **별도 서비스**. Inspector(알려진 CVE)와 구분.

---

## ⚠️ 흔한 함정

1. **"GuardDuty가 EC2의 미패치 CVE를 찾아준다."** → 아닙니다. CVE·취약점은 **Inspector**입니다. GuardDuty는 악성 *활동/트래픽*(위협)을 로그로 탐지합니다.
   *(원리: §4 — Inspector는 CVE 데이터베이스 갱신을 모니터링해 영향받는 워크로드를 자동 재평가하며, GuardDuty는 소프트웨어 상태가 아닌 네트워크·API 행위 로그를 분석한다.)*

2. **"GuardDuty를 쓰려면 인스턴스에 에이전트를 깔아야 한다."** → 기본 탐지는 **에이전트가 필요 없습니다.** VPC Flow Logs·DNS·CloudTrail 로그를 분석합니다(런타임/EKS 모니터링 등 일부 확장 기능만 별도 에이전트 사용).
   *(원리: §3 — 로그는 인스턴스 외부에서 수집되므로 공격자가 인스턴스 안의 에이전트를 무력화해도 탐지 데이터가 사라지지 않는다.)*

3. **"Security Hub가 직접 위협을 탐지한다."** → Security Hub는 **통합·표준 점검·점수화 계층**입니다. 실제 탐지는 GuardDuty·Inspector·Macie·Config 등이 하고, Security Hub는 그 결과를 ASFF로 모읍니다.
   *(원리: §2 — Security Hub가 탐지 로직을 중복 구현하면 각 서비스의 최적화된 맥락을 잃으므로, ASFF 정규화로 통합하는 역할에 집중한다.)*

4. **"S3 버킷이 퍼블릭으로 바뀐 걸 GuardDuty가 평가한다."** → 구성(설정) 변화의 준수 여부는 **AWS Config 규칙**입니다. Config가 NONCOMPLIANT로 표시하고 SSM으로 자동 교정합니다.
   *(원리: §1 — Config는 어떤 경로로 구성이 바뀌었든 지속 평가로 비준수 상태를 포착하며, GuardDuty는 구성이 아니라 위협 행위를 본다.)*

5. **"Inspector가 S3의 개인정보를 찾는다."** → S3 민감정보(PII)는 **Macie**입니다. Inspector는 워크로드의 소프트웨어 취약점(CVE)을 봅니다.
   *(원리: §0 — 각 도구는 서로 다른 데이터 소스에 최적화되어 역할이 분리되어 있어, Inspector는 소프트웨어 상태를, Macie는 데이터 내용을 본다.)*

6. **"Config 자동 교정은 Lambda를 직접 호출한다."** → Config의 자동 교정은 **SSM Automation 런북**을 실행합니다(런북 안에서 Lambda를 부를 수는 있음).
   *(원리: §1 본문 — Config 운영 흐름에서 교정 단계는 SSM Automation 런북을 실행하며, 런북이 필요에 따라 추가 서비스를 호출하는 구조다.)*

7. **"Trusted Advisor 모든 점검을 어느 계정에서나 볼 수 있다."** → 점검 전체는 **Business Support+ · Enterprise · Unified Operations** 플랜에서 제공됩니다. **Basic**에서는 서비스 한도 범주 전체와 보안·내결함성의 선택된 점검만 열리고 자동 갱신도 없습니다.
   *(원리: §5 — 점검은 지원 플랜의 구성 요소로 제공되며, Basic은 범위와 갱신 방식이 모두 제한된다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 한 EC2 인스턴스가 알려진 악성 IP와 비정상적인 아웃바운드 통신을 하고 있습니다(암호화폐 채굴 의심). 이를 에이전트 설치 없이 탐지하려면 어떤 서비스를 쓰나요?

<details><summary>정답 보기</summary>

**Amazon GuardDuty**입니다. GuardDuty는 VPC Flow Logs·DNS 로그·CloudTrail을 머신러닝과 위협 인텔리전스로 분석해 악성 IP 통신·암호화폐 채굴 같은 위협을 **에이전트 없이** 탐지합니다. CVE 패치 여부(Inspector)나 구성 준수(Config)와는 다른 영역입니다.
</details>

**Q2.** 보안 정책상 모든 새 EBS 볼륨은 암호화되어야 합니다. 비암호화 볼륨이 만들어지면 자동으로 탐지하고, 가능하면 자동으로 조치까지 하고 싶습니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**AWS Config 규칙**으로 EBS 암호화 여부를 평가하고(예: `encrypted-volumes` 관리형 규칙), NONCOMPLIANT 리소스에 **SSM Automation 자동 교정**을 연결합니다. 여러 규칙·교정을 **규정 준수 팩(Conformance Pack)**으로 묶어 일괄 배포하면 계정·OU 전반에 가드레일을 지속적으로 강제할 수 있습니다.
</details>

**Q3.** 여러 계정에서 GuardDuty·Inspector·Macie 결과가 흩어져 나옵니다. CIS·FSBP 표준 대비 보안 점수를 보고 결과를 한곳에서 우선순위화하려면?

<details><summary>정답 보기</summary>

**AWS Security Hub**를 활성화합니다. Security Hub는 GuardDuty·Inspector·Macie·Config 등의 결과를 **ASFF**로 정규화해 한 대시보드에 모으고, **CIS AWS Foundations·FSBP** 같은 보안 표준에 대해 환경을 자동 점검하여 **보안 점수**를 산출합니다. EventBridge로 자동 대응도 연결할 수 있습니다.
</details>

**Q4.** 컨테이너 이미지(ECR)와 Lambda 함수에 알려진 CVE가 있는지 지속적으로 스캔하려 합니다. 어떤 서비스가 적합한가요?

<details><summary>정답 보기</summary>

**Amazon Inspector**입니다. Inspector는 EC2·ECR 컨테이너 이미지·Lambda 함수를 대상으로 알려진 **CVE(소프트웨어 취약점)**와 네트워크 노출을 자동·지속적으로 스캔하고, 새 CVE가 공개되면 재스캔합니다. 위협 활동 탐지(GuardDuty)나 민감정보 탐지(Macie)와는 목적이 다릅니다.
</details>

**Q5 (원리).** 왜 AWS Config의 비준수 자동 교정은 SSM Automation 런북을 통해 이루어지며, Config가 Lambda를 직접 호출하는 방식을 쓰지 않을까요?

<details><summary>정답 보기</summary>

Config 자동 교정은 실행 흐름을 SSM Automation에 위임하며, 런북은 검증·교정·알림 같은 여러 단계를 순서대로 처리하고 실패 시 재시도·롤백 로직을 런북 안에 정의할 수 있습니다. Lambda를 직접 호출하면 이 단계 제어와 실행 이력 추적이 모두 Lambda 코드 안에 들어가야 해 관리가 복잡해집니다. SSM Automation은 실행 이력을 콘솔에서 확인하고 AWS Config가 제공하는 관리형 Automation 문서를 재사용할 수 있어, 별도 코드 없이 표준 교정 흐름을 구축할 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09 · 고도화 검수: 2026-06-12)

1. AWS Config — 소개 — https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html
2. AWS Config 규칙으로 리소스 평가 — https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html
3. AWS Security Hub — 소개 — https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
4. Amazon GuardDuty — 소개 — https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
5. Amazon Inspector — 소개 — https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html
6. AWS Trusted Advisor — 플랜별 점검 범위·Basic 수동 갱신 — https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
7. AWS Support 플랜(현행 목록) — https://aws.amazon.com/premiumsupport/plans/

> 📝 **2026-10-19 정정**: Trusted Advisor 점검 범위를 구식 유료 지원 플랜 명칭으로 적었던 §5·시험 포인트·함정 7을 현행 기준으로 고쳤습니다 — 점검 전체는 **Business Support+ · Enterprise · Unified Operations**에 제공되고, **Basic**은 서비스 한도 범주 전체와 보안·내결함성의 선택된 점검만 열리며 **자동 갱신이 없습니다**(근거 6번). Developer·Business·Enterprise On-Ramp 플랜의 2027-01-01 종료 예정도 함께 적었습니다(근거 6·7번).
