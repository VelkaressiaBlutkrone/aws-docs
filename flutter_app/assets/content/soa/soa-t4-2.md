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
lastVerified: 2026-06-09
---

# 규정 준수·거버넌스 — Config·Security Hub·GuardDuty·Inspector

> **커버하는 공식 Task** — SOA-C03 · 도메인 4 「보안 및 규정 준수」(16%) · **Task 4.1 보안 및 규정 준수 도구와 정책 구현 및 관리** (`soa-t4-2`)
> 이 문서는 **거버넌스·위협 탐지·취약점 스캔** 도구에 집중합니다. IAM·계정 보안은 `soa-t4-1`, 데이터·인프라 암호화는 `soa-t4-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 운영할 수 있어야 합니다.

- [ ] **각 도구가 무엇을 보는가** — Config(구성)·GuardDuty(위협)·Inspector(취약점)·Macie(민감정보)를 명확히 구분한다
- [ ] **AWS Config** — 구성 기록·규칙 평가·적합성 팩·SSM 자동 교정을 설명할 수 있다
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

### 1) AWS Config — 구성 기록과 규칙 평가

> 공식 정의: **"AWS 리소스의 구성을 평가·감사·심사할 수 있게 하는 서비스."** Config는 리소스 설정의 **시간에 따른 변화**를 기록하고, 원하는 상태와 비교합니다.

| 구성 요소 | 설명 |
|---|---|
| **구성 항목/기록기(Configuration Recorder)** | 리소스의 현재 설정을 스냅샷으로 기록하고 변경 이력을 보관 |
| **Config 규칙(Rule)** | 리소스가 *준수(COMPLIANT)/비준수(NONCOMPLIANT)*인지 평가. AWS 관리형 규칙 또는 Lambda/Guard 커스텀 규칙 |
| **적합성 팩(Conformance Pack)** | 규칙·교정 액션을 묶은 패키지를 한 번에 배포(예: PCI/HIPAA 운영 모범 사례 팩) |
| **자동 교정(Remediation)** | 비준수 리소스를 **SSM Automation 런북**으로 자동 수정(예: 퍼블릭 버킷 차단) |

> **운영 흐름**: 구성 변경 발생 → Config 규칙이 평가 → NONCOMPLIANT면 SSM Automation 교정 실행 또는 EventBridge로 알림. "S3 퍼블릭 차단", "EBS 암호화 미설정 볼륨 탐지" 같은 가드레일을 **지속적으로** 강제합니다.

### 2) Security Hub — 보안 표준·통합 결과·점수

> 공식 정의: **"여러 AWS 서비스와 파트너 제품의 보안 경보를 한곳에서 보고, 보안 표준에 대해 환경을 자동 점검하는 서비스."**

- **보안 표준 자동 점검**: **CIS AWS Foundations Benchmark**, **AWS Foundational Security Best Practices(FSBP)**, PCI DSS 등 표준에 대해 환경을 점검하고 **보안 점수(%)**를 산출합니다.
- **통합 결과 형식(ASFF)**: GuardDuty·Inspector·Macie·Config 등 여러 서비스의 결과를 **AWS Security Finding Format**으로 정규화해 한 화면에 모읍니다.
- **자동 대응**: 결과를 EventBridge로 보내 Lambda·SSM으로 자동 조치(티켓 생성, 격리 등)를 트리거합니다.

> Security Hub는 **탐지 도구가 아니라 통합·표준화 계층**입니다. 직접 위협을 찾기보다, GuardDuty/Inspector 등이 찾은 것을 모아 우선순위화합니다.

### 3) Amazon GuardDuty — 위협 탐지 (★ Inspector와 구분)

> 공식 정의: **"악성 활동과 비인가 행위를 지속적으로 모니터링하는 위협 탐지 서비스."**

- **에이전트가 필요 없습니다.** 인스턴스에 무엇을 설치하지 않고, **로그를 분석**합니다:
  - **VPC Flow Logs** (네트워크 흐름)
  - **DNS 쿼리 로그**
  - **CloudTrail 이벤트** (관리/데이터 이벤트)
- **머신러닝·이상 탐지·위협 인텔리전스**로 침해 징후를 찾습니다. 예: 암호화폐 채굴 통신, 알려진 악성 IP와의 통신, 비정상적인 API 호출(예: 자격증명 탈취 후 권한 정찰), 포트 스캔.
- 결과는 심각도(Low/Medium/High)와 함께 제공되며 Security Hub·EventBridge로 통합됩니다.

> **추가 보호 플랜**: S3 보호, EKS/런타임 모니터링, Malware Protection, RDS 보호 등 데이터 소스를 확장할 수 있습니다(런타임 모니터링은 별도 에이전트 사용). 기본 탐지는 에이전트 없이 로그 기반이라는 점이 핵심입니다.

### 4) Amazon Inspector — 취약점(CVE) 스캔 (★ GuardDuty와 구분)

> 공식 정의: **"워크로드의 소프트웨어 취약점과 의도치 않은 네트워크 노출을 자동으로 발견하는 취약점 관리 서비스."**

- **자동·지속 스캔 대상**: **EC2 인스턴스**, **컨테이너 이미지(ECR)**, **Lambda 함수**.
- 알려진 **CVE(소프트웨어 취약점)**와 네트워크 도달 가능성을 평가해 **위험 점수**를 매깁니다.
- 새 CVE가 공개되거나 패키지가 바뀌면 **재스캔**해 지속적으로 최신 상태를 유지합니다(스캔 일정 수동 관리 불필요).

> **GuardDuty vs Inspector 한 줄 정리**: GuardDuty = "지금 **공격/침해**가 일어나고 있는가"(행위·트래픽), Inspector = "이 워크로드에 **고칠 취약점(CVE)**이 있는가"(소프트웨어 상태).

### 5) Trusted Advisor — 모범 사례 점검 5범주

> 공식 정의: **"AWS 모범 사례에 따라 환경을 점검하고 권장 사항을 제시하는 서비스."**

| 범주 | 예시 점검 |
|---|---|
| **비용 최적화** | 유휴 리소스, 미사용 EIP·로드밸런서 |
| **보안** | 퍼블릭 S3 버킷, 보안 그룹 과개방, 루트 MFA 미설정, IAM 키 노출 |
| **내결함성(Fault Tolerance)** | 다중 AZ, 백업, 스냅샷 구성 |
| **성능** | 과소/과대 프로비저닝, 서비스 한도 근접 |
| **서비스 한도(할당량)** | 계정 한도 사용률 |

> 전체 점검 항목은 **Business/Enterprise Support 플랜**에서 열립니다. 기본 플랜은 일부 보안·서비스 한도 점검만 제공합니다.

### 6) Amazon Detective (간단 참고)

- GuardDuty 등이 결과를 *탐지*하면, Detective는 그 **근본 원인 조사(분석·시각화)**를 돕습니다. 로그를 그래프로 연결해 "이 IP가 어떤 리소스와 언제 통신했는지"를 추적합니다. **탐지가 아니라 사후 조사** 도구라는 점이 구분 포인트입니다.

---

## ✍️ 시험 포인트

- **Config = 구성 준수**(설정이 규칙을 지키나). 비준수 시 **SSM Automation 자동 교정** + 적합성 팩으로 묶어 배포.
- **GuardDuty = 위협 탐지**. **에이전트 불필요**, VPC Flow Logs·DNS·CloudTrail을 머신러닝으로 분석.
- **Inspector = 취약점(CVE) 스캔**. 대상은 **EC2·ECR(컨테이너)·Lambda**. 지속 재스캔.
- **Macie = S3 민감정보(PII) 탐지** (데이터 *내용*). Inspector(취약점)·GuardDuty(위협)와 혼동 금지.
- **Security Hub = 통합·표준 점검(CIS/FSBP)·보안 점수**. 직접 탐지하지 않고 결과를 **ASFF**로 모은다.
- **Trusted Advisor 5범주**: 비용·보안·내결함성·성능·서비스 한도. 전체 점검은 Business/Enterprise 지원 플랜.
- **Detective = 사후 근본 원인 조사**(탐지 아님).
- **결과 통합 흐름**: 탐지 도구(GuardDuty/Inspector/Macie/Config) → Security Hub 집계 → EventBridge → Lambda/SSM 자동 대응.

---

## ⚠️ 흔한 함정

1. **"GuardDuty가 EC2의 미패치 CVE를 찾아준다."** → 아닙니다. CVE·취약점은 **Inspector**입니다. GuardDuty는 악성 *활동/트래픽*(위협)을 로그로 탐지합니다.

2. **"GuardDuty를 쓰려면 인스턴스에 에이전트를 깔아야 한다."** → 기본 탐지는 **에이전트가 필요 없습니다.** VPC Flow Logs·DNS·CloudTrail 로그를 분석합니다(런타임/EKS 모니터링 등 일부 확장 기능만 별도 에이전트 사용).

3. **"Security Hub가 직접 위협을 탐지한다."** → Security Hub는 **통합·표준 점검·점수화 계층**입니다. 실제 탐지는 GuardDuty·Inspector·Macie·Config 등이 하고, Security Hub는 그 결과를 ASFF로 모읍니다.

4. **"S3 버킷이 퍼블릭으로 바뀐 걸 GuardDuty가 평가한다."** → 구성(설정) 변화의 준수 여부는 **AWS Config 규칙**입니다. Config가 NONCOMPLIANT로 표시하고 SSM으로 자동 교정합니다.

5. **"Inspector가 S3의 개인정보를 찾는다."** → S3 민감정보(PII)는 **Macie**입니다. Inspector는 워크로드의 소프트웨어 취약점(CVE)을 봅니다.

6. **"Config 자동 교정은 Lambda를 직접 호출한다."** → Config의 자동 교정은 **SSM Automation 런북**을 실행합니다(런북 안에서 Lambda를 부를 수는 있음).

7. **"Trusted Advisor 모든 점검이 무료다."** → 전체 점검 항목은 **Business/Enterprise Support 플랜**에서 제공됩니다. 기본 플랜은 일부만 열립니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 한 EC2 인스턴스가 알려진 악성 IP와 비정상적인 아웃바운드 통신을 하고 있습니다(암호화폐 채굴 의심). 이를 에이전트 설치 없이 탐지하려면 어떤 서비스를 쓰나요?

<details><summary>정답 보기</summary>

**Amazon GuardDuty**입니다. GuardDuty는 VPC Flow Logs·DNS 로그·CloudTrail을 머신러닝과 위협 인텔리전스로 분석해 악성 IP 통신·암호화폐 채굴 같은 위협을 **에이전트 없이** 탐지합니다. CVE 패치 여부(Inspector)나 구성 준수(Config)와는 다른 영역입니다.
</details>

**Q2.** 보안 정책상 모든 새 EBS 볼륨은 암호화되어야 합니다. 비암호화 볼륨이 만들어지면 자동으로 탐지하고, 가능하면 자동으로 조치까지 하고 싶습니다. 어떻게 구성하나요?

<details><summary>정답 보기</summary>

**AWS Config 규칙**으로 EBS 암호화 여부를 평가하고(예: `encrypted-volumes` 관리형 규칙), NONCOMPLIANT 리소스에 **SSM Automation 자동 교정**을 연결합니다. 여러 규칙·교정을 **적합성 팩(Conformance Pack)**으로 묶어 일괄 배포하면 계정·OU 전반에 가드레일을 지속적으로 강제할 수 있습니다.
</details>

**Q3.** 여러 계정에서 GuardDuty·Inspector·Macie 결과가 흩어져 나옵니다. CIS·FSBP 표준 대비 보안 점수를 보고 결과를 한곳에서 우선순위화하려면?

<details><summary>정답 보기</summary>

**AWS Security Hub**를 활성화합니다. Security Hub는 GuardDuty·Inspector·Macie·Config 등의 결과를 **ASFF**로 정규화해 한 대시보드에 모으고, **CIS AWS Foundations·FSBP** 같은 보안 표준에 대해 환경을 자동 점검하여 **보안 점수**를 산출합니다. EventBridge로 자동 대응도 연결할 수 있습니다.
</details>

**Q4.** 컨테이너 이미지(ECR)와 Lambda 함수에 알려진 CVE가 있는지 지속적으로 스캔하려 합니다. 어떤 서비스가 적합한가요?

<details><summary>정답 보기</summary>

**Amazon Inspector**입니다. Inspector는 EC2·ECR 컨테이너 이미지·Lambda 함수를 대상으로 알려진 **CVE(소프트웨어 취약점)**와 네트워크 노출을 자동·지속적으로 스캔하고, 새 CVE가 공개되면 재스캔합니다. 위협 활동 탐지(GuardDuty)나 민감정보 탐지(Macie)와는 목적이 다릅니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. AWS Config — 소개 — https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html
2. AWS Config 규칙으로 리소스 평가 — https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config.html
3. AWS Security Hub — 소개 — https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
4. Amazon GuardDuty — 소개 — https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
5. Amazon Inspector — 소개 — https://docs.aws.amazon.com/inspector/latest/user/what-is-inspector.html
6. AWS Trusted Advisor — https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html
