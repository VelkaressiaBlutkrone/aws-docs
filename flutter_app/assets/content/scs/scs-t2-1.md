---
examGuideTaskId: scs-t2-1
certCode: SCS-C03
domain: 2
domainName: 인시던트 대응
domainWeightPct: 14
title: 인시던트 대응 계획 설계와 테스트 (런북·사전 구성·혼돈 실험·자동 해결)
coversTasks:
  - "2.1"
sources:
  - title: AWS Systems Manager OpsCenter
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/OpsCenter.html
  - title: What is AWS Fault Injection Service?
    url: https://docs.aws.amazon.com/fis/latest/userguide/what-is.html
  - title: What is AWS Resilience Hub?
    url: https://docs.aws.amazon.com/resilience-hub/latest/userguide/what-is.html
  - title: What is ARC? (Amazon Application Recovery Controller)
    url: https://docs.aws.amazon.com/r53recovery/latest/dg/what-is-route53-recovery.html
  - title: AWS Shield Advanced overview
    url: https://docs.aws.amazon.com/waf/latest/developerguide/ddos-advanced-summary.html
  - title: Architecture overview — Automated Forensics Orchestrator for Amazon EC2 and EKS
    url: https://docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/architecture-overview.html
  - title: What is AWS Security Incident Response?
    url: https://docs.aws.amazon.com/security-ir/latest/userguide/what-is.html
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
lastVerified: 2026-11-08
---

# 인시던트 대응 계획 설계와 테스트 (런북·사전 구성·혼돈 실험·자동 해결)

> **커버하는 공식 Task** — SCS-C03 · 도메인 2 「인시던트 대응」(14%) · **작업 2.1 인시던트 대응 계획 설계 및 테스트** (`scs-t2-1`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(2.1.1~2.1.4)를 모두 덮습니다. 도메인 2는 **「사고가 났을 때」가 아니라 「사고 전에 무엇을 해 두었나」**를 묻습니다. 이 작업이 그 「사전」이고, 작업 2.2가 「사고 중」입니다.

> ⚠️⚠️ **공식 가이드가 드는 예시 하나가 상태를 적어야 하는 기능입니다.** `기술 2.1.4`가 **Amazon Application Recovery Controller(ARC)**를 드는데, ARC의 기능 중 **준비 상태 확인(readiness check)은 2026-03-31 공지로 유지 관리 상태**입니다. 그리고 공식 문서 자신이 **"준비 상태 확인은 장애 중 실패 조치의 임계 경로에서 쓰도록 의도된 것이 아니다"**라고 적습니다. 아래 4절이 ARC의 어느 기능을 써야 하는지 가릅니다.

---

## ✅ 학습 목표 체크리스트

- [ ] OpsCenter가 **OpsItem을 어디서 자동으로 만드는지**(CloudWatch 알람·EventBridge) 설명한다
- [ ] 인시던트 전에 **미리 해 두어야 하는 네 가지**(액세스·도구·영향 범위·DDoS 보호)를 구분한다
- [ ] Shield Advanced 구독이 **덮는 AWS WAF 비용과 덮지 않는 비용**을 가른다
- [ ] AWS FIS의 **작업·대상·중단 조건** 셋과 중단 조건이 CloudWatch 알람임을 설명한다
- [ ] Resilience Hub와 FIS의 **관계**(Resilience Hub 안에서 FIS 실험을 만든다)를 안다
- [ ] 자동 포렌식 오케스트레이터의 **트리거 경로**(탐지 → Security Hub → EventBridge → Step Functions)를 그린다
- [ ] ARC의 **영역 전환·영역 자동 전환·리전 전환·라우팅 컨트롤·준비 상태 확인** 다섯을 구분한다
- [ ] 자동 해결 설계에서 **사람의 승인이 필요한 지점**을 정한다

## 🎯 왜 중요한가

Specialty 시험의 인시던트 대응 문항은 거의 전부 **「지금 당장 할 수 있는가」**를 묻습니다. 그리고 「지금 당장」이 가능한지는 **사고 전에 준비해 둔 것**으로 결정됩니다.

- 포렌식 이미지를 **미리 만들어 두지 않았다면** 메모리 덤프를 떠서 분석할 환경이 없습니다
- 격리용 보안 그룹과 그 자동화가 **없다면** 사람이 콘솔에서 클릭하는 동안 공격자가 계속 움직입니다
- 조사용 역할이 **미리 승인돼 있지 않다면** 권한을 받는 데 시간이 걸립니다

그래서 이 작업의 문항은 "사고가 났다"로 시작하지만 답은 **준비 항목**입니다. 아래 2절이 그 목록이고, 4절이 그것을 자동화로 묶습니다.

## ⚡ 시험 직전 요약

- OpsCenter는 **CloudWatch 알람이 `ALARM`에 들어갈 때**와 **EventBridge가 이벤트를 처리할 때** OpsItem을 자동으로 만들 수 있습니다
- OpsCenter는 **AWS Config · CloudTrail · CloudWatch Events** 정보를 OpsItem에 모아 줘 콘솔을 옮겨 다니지 않게 합니다
- **Shield Advanced 구독이 보호 대상 리소스의 표준 AWS WAF 비용을 덮습니다**(보호 팩당·규칙당·웹 요청 백만 건당, **1,500 WCU·기본 본문 크기까지**)
- ⚠️ 자동 애플리케이션 계층 DDoS 완화를 켜면 **150 WCU 규칙 그룹**이 보호 팩에 추가되고 그 WCU가 **사용량에 계산됩니다**
- ⚠️ **Bot Control · CAPTCHA · 1,500 WCU 초과 · 기본 본문 크기 초과 검사는 덮이지 않습니다**
- AWS FIS는 **작업(action) · 대상(target) · 중단 조건(stop condition)** 셋으로 실험을 정의하고, **중단 조건은 CloudWatch 알람**입니다
- ⚠️ **FIS는 실제 리소스에 실제 작업을 수행**하므로 공식이 **사전 프로덕션 환경에서 먼저** 돌리라고 강하게 권합니다
- **Resilience Hub 안에서 FIS 실험을 만들고 실행할 수 있습니다** — 두 서비스가 한 기술에 함께 적힌 이유입니다
- 자동 포렌식 오케스트레이터는 **포렌식 AMI가 선행 요건**이고 **Security Hub 조사 결과 → EventBridge → Step Functions**로 트리거됩니다
- ⚠️ ARC **영역 전환은 수동·임시**이고 **최대 3일 만료**(연장 가능), **영역 자동 전환은 AWS가 내부 텔레메트리로** 시작·종료합니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **런북(runbook)** | 정해진 상황에 수행할 절차를 적은 문서. Systems Manager에서는 **Automation 런북**이 실행 가능한 형태입니다 |
| **OpsItem** | OpsCenter가 다루는 **운영 작업 항목**. 서비스 경계를 넘어 한곳에 모입니다 |
| **보호 팩(protection pack)** | AWS WAF의 **web ACL**을 가리키는 현행 콘솔 용어 |
| **WCU** | Web ACL Capacity Unit. web ACL의 규칙 처리 용량 단위 |
| **혼돈 엔지니어링** | 장애를 일부러 주입해 시스템 반응을 관찰하는 방법론. FIS가 그 도구입니다 |
| **중단 조건(stop condition)** | 실험을 멈추는 임계값. **CloudWatch 알람으로** 정의합니다 |
| **영역 전환(zonal shift)** | 손상된 AZ에서 건강한 AZ로 **트래픽을 임시로 옮기는** 것 |
| **관리 연속성(chain of custody)** | 증거가 수집·보관·분석 전 과정에서 변조되지 않았음을 보일 수 있는 상태 |

## 📖 핵심 개념

### 1) 대응 계획과 런북 (기술 2.1.1) {#runbooks}

공식 예시는 **Systems Manager OpsCenter**와 **Amazon SageMaker AI 노트북**입니다.

#### 1-1. OpsCenter — 작업 항목을 한곳에 모은다

OpsCenter는 운영 엔지니어가 **AWS 리소스와 관련된 운영 작업 항목(OpsItem)을 보고 조사하고 해결하는 중앙 위치**입니다. 서비스 경계를 넘어 OpsItem을 **집계·표준화**하고, 각 OpsItem에 **맥락 조사 데이터**(관련 OpsItem·관련 리소스)와 **Systems Manager Automation 런북**을 함께 제공합니다.

⚠️ **자동 생성 경로가 둘입니다.**

| 경로 | 언제 OpsItem이 만들어지나 |
|---|---|
| **CloudWatch 알람** | 알람이 **`ALARM` 상태에 들어갈 때** |
| **EventBridge** | **이벤트를 게시하는 어떤 AWS 서비스의 이벤트**든 EventBridge가 처리할 때 |

공식이 드는 EventBridge 규칙 예시에 **`AWS Security Hub CSPM: 보안 경고 발생`**이 들어 있습니다. ⚠️ **공식 문서가 여기서도 `Security Hub CSPM` 이름을 씁니다** — 작업 1.1에서 본 이름 구분이 그대로 적용됩니다.

그 밖에 기억할 것 — OpsCenter는 **AWS Config · CloudTrail 로그 · CloudWatch Events** 정보를 리소스 단위로 집계해 **여러 콘솔 페이지를 옮겨 다니지 않게** 합니다. **CloudWatch Application Insights(.NET·SQL Server)** 통합으로 애플리케이션 문제에 OpsItem을 자동 생성할 수 있고, **공개 API**로 **기존 사례 관리 시스템·상태 대시보드와 통합**할 수 있습니다. ⚠️ 관련 리소스 ARN을 지정하면 **내장 로직이 중복 OpsItem 생성을 피하게** 도와줍니다.

#### 1-2. 노트북 — 조사 절차를 코드로 둔다

가이드가 **SageMaker AI 노트북**을 함께 드는 이유는 **조사 절차를 실행 가능한 형태로 보관**하기 위해서입니다. 로그 조회·상관 분석 질의를 노트북 셀로 두면 사고 때 **같은 순서로 재현**할 수 있고 결과가 기록으로 남습니다.

⚠️ **노트북은 「런북의 실행 가능한 판」이지 대응 계획 자체가 아닙니다.** 문항이 "대응 절차를 표준화하고 중복을 줄이려면?"을 묻는다면 **OpsCenter + Automation 런북**이고, "조사 질의를 재현 가능하게 보관하려면?"이 노트북입니다.

> ⚠️ **범위 메모** — AWS에는 **`AWS Security Incident Response`**라는 관리형 서비스가 있습니다(NIST 800-61에 맞춰 탐지·트리아지·조사·격리·복구 지침을 다루고, **스스로 조사 결과를 만들지 않고** GuardDuty와 **Security Hub CSPM을 통해 통합된 타사 도구**의 조사 결과를 수집합니다). 그런데 **이 서비스는 SCS-C03 공식 가이드의 범위 내 71개 목록에도, 범위 외 목록에도 없습니다.** 그래서 이 사이트는 **구조만 소개하고 문항으로 만들지 않습니다.** 알아 두면 좋은 두 가지는 ⚠️ **위협 탐지 조사 결과만 트리아지하고 보안 자세·준수 조사 결과는 트리아지하지 않는다**(후자는 활성 위협이 아니라 **상태를 서술**하기 때문입니다)와 ⚠️ **에스컬레이션 통지는 음소거·억제할 수 없다**(검증된 사안만 올라오기 때문입니다)입니다.

### 2) 인시던트에 대비해 서비스를 구성한다 (기술 2.1.2) {#prepare}

공식 예시는 **액세스 프로비저닝 · 보안 도구 배포 · 영향 범위 최소화 · AWS Shield Advanced 보호 기능 구성** 넷입니다. 앞의 셋은 설계 원칙이고 마지막 하나가 구체 서비스입니다.

#### 2-1. 앞의 셋 — 미리 해 두는 것

| 준비 항목 | 무엇을 미리 해 두나 | 안 해 두면 |
|---|---|---|
| **액세스 프로비저닝** | 조사·격리에 필요한 **역할과 승인 경로**를 미리 만든다 | 권한을 받는 동안 공격자가 계속 움직인다 |
| **보안 도구 배포** | 탐지·수집 도구를 **전 계정·전 리전에** 미리 켠다 | ⚠️ **Security Hub CSPM은 소급 적용되지 않아** 사고 전 조사 결과가 없다 |
| **영향 범위 최소화** | 계정·VPC·권한 경계로 **폭발 반경**을 미리 좁힌다 | 한 자격 증명이 전체로 번진다 |

⚠️ 두 번째 항목이 시험에서 가장 자주 나옵니다 — 작업 1.1에서 본 **「Security Hub CSPM은 켠 뒤 생성된 조사 결과만 집계하고 활성화한 리전에서만 받는다」**가 그대로 「사전 준비」의 근거입니다.

#### 2-2. Shield Advanced 보호 기능 구성

Shield Advanced는 **DDoS 공격 · 대량 봇 · 취약성 악용 시도** 같은 외부 위협으로부터 애플리케이션을 보호하는 관리형 서비스이고, **구독한 뒤 리소스에 보호를 추가**해야 확장된 DDoS 보호를 받습니다. ⚠️ **받는 보호는 아키텍처와 구성 선택에 따라 달라집니다** — "구독하면 끝"이 아닙니다.

⚠️⚠️ **비용 구조가 문항의 갈림길입니다.**

| 구독이 덮는 것 | 구독이 덮지 않는 것 |
|---|---|
| 보호 대상 리소스의 **표준 AWS WAF 비용** — **보호 팩(web ACL)당 비용 · 규칙당 비용 · 웹 요청 검사 백만 건당 기본 가격**(**1,500 WCU까지, 기본 본문 크기까지**) | **Bot Control** · **CAPTCHA 규칙 작업** · **1,500 WCU를 넘는 web ACL** · **기본 본문 크기를 넘는 본문 검사** |
| **L7 Anti-DDoS 관리형 규칙 그룹** 접근(월 **500억 요청**까지) | **보호하지 않는 리소스**의 AWS WAF 사용 |

⚠️ **자동 애플리케이션 계층 DDoS 완화를 켜면 보호 팩에 150 WCU 규칙 그룹이 추가되고 그 WCU가 보호 팩의 WCU 사용량에 계산됩니다.** 1,500 WCU 한도에 가까운 web ACL이라면 이것만으로 한도를 넘어 **덮이지 않는 비용**이 생길 수 있습니다.

⚠️ 조직 청구 — 멤버 계정의 Shield Advanced 구독은 **조직의 결제 계정에 청구**되고(결제 계정 자신이 구독했는지와 무관), **같은 통합 결제 가족이면 하나의 구독료가 전 계정을 덮습니다**(조직이 전 계정과 리소스를 소유해야 합니다).

### 3) 계획의 효과를 테스트한다 (기술 2.1.3) {#test}

공식 예시는 **AWS Fault Injection Service**와 **AWS Resilience Hub**입니다.

#### 3-1. AWS FIS — 혼돈 엔지니어링

**장애 주입 실험**을 수행하는 관리형 서비스입니다. 실험으로 **현실적인 조건**을 만들어 다른 방법으로는 찾기 어려운 문제를 드러냅니다.

**개념 셋** — 실험은 **실험 템플릿**(청사진)으로 정의합니다.

| 개념 | 뜻 |
|---|---|
| **작업(action)** | 실험 중 AWS 리소스에 수행하는 활동. 리소스 유형별 **사전 구성 작업**이 제공되고 **순차 또는 병렬**로 돌 수 있습니다 |
| **대상(target)** | 작업을 수행할 리소스. 특정 리소스를 고르거나 **태그·상태 같은 기준으로 그룹**을 고릅니다 |
| **중단 조건(stop condition)** | ⚠️ **내가 정의한 CloudWatch 알람**입니다. 실험 중 발동하면 FIS가 실험을 멈춥니다 |

⚠️⚠️ **FIS는 시스템의 실제 리소스에 실제 작업을 수행합니다.** 그래서 공식이 프로덕션 실험 전에 **계획 단계를 완료하고 사전 프로덕션 환경에서 실험을 돌리라고 강하게 권합니다.** 그리고 FIS가 제공하는 가드레일로 **조건 충족 시 자동 롤백·중단**이 있습니다.

⚠️ 단일 계정 실험은 **대상 리소스가 실험과 같은 계정**에 있어야 하고, **다중 계정 실험**으로 다른 계정의 리소스를 대상으로 삼을 수 있습니다.

#### 3-2. Resilience Hub — 자세를 재고 개선을 권한다

**복원력 목표를 정의하고, 그 목표에 대해 자세를 평가하고, AWS Well-Architected Framework에 기반한 개선 권장 사항을 구현**하는 중앙 위치입니다.

⚠️⚠️ **Resilience Hub 안에서 FIS 실험을 만들고 실행할 수 있습니다** — 공식 what-is가 직접 적습니다. 두 서비스가 `기술 2.1.3`에 함께 적힌 이유이고, 문항이 "복원력 목표 대비 평가와 실험을 한곳에서"를 물으면 **Resilience Hub**입니다.

⚠️ 공식이 함께 드는 관련 복원력 서비스는 **AWS Elastic Disaster Recovery · AWS Backup · Amazon Application Recovery Controller(ARC)** 셋입니다.

### 4) 자동으로 인시던트를 해결한다 (기술 2.1.4) {#automate}

공식 예시는 **Systems Manager · Amazon EC2용 자동 포렌식 오케스트레이터 · AWS Step Functions · Amazon Application Recovery Controller · Lambda 함수**입니다.

#### 4-1. 자동 포렌식 오케스트레이터 — 트리거부터 격리까지

> ⚠️ **이름이 바뀌었습니다.** 공식 문서 제목은 **「Automated Forensics Orchestrator for Amazon EC2 **and EKS**」**이고 문서가 자신을 **「Guidance」**로 부릅니다. 공식 시험 가이드는 아직 **「Amazon EC2용 자동 포렌식 오케스트레이터」**로 적으니, 시험장에서 EC2만 적힌 이름을 보더라도 **같은 솔루션**입니다.

**선행 요건** — ⚠️ **포렌식 AMI를 먼저 만들어 두어야 합니다**(EC2 Image Builder로 새로 만들거나 기존 AMI 사용). Step Functions가 그 AMI로 **메모리·디스크 조사**를 수행합니다.

**트리거 경로** — 이 순서가 문항으로 나옵니다.

1. 애플리케이션 계정에서 **AWS Config 관리형 규칙 · GuardDuty · 타사 도구**가 악성 활동을 탐지합니다
2. 조사 결과가 **보안 계정의 Security Hub**로 보내집니다(기본 통합 또는 기존 통합)
3. ⚠️ **기본적으로 모든 Security Hub 조사 결과가 EventBridge로** 보내져 하위 자동화를 호출합니다
4. EventBridge가 **인스턴스 ID**를 넘기고 **Step Functions 워크플로**를 시작합니다
5. Step Functions가 **트리아지**합니다 — 인스턴스 정보를 가져오고, ⚠️ **Security Hub 작업에 따라 격리 필요 여부**를, ⚠️ **인스턴스 태그에 따라 수집 필요 여부**를 판단합니다

**두 수집 흐름이 병렬로** 시작됩니다.

| 흐름 | 하는 일 |
|---|---|
| **메모리 포렌식** | 메모리 데이터를 캡처해 **S3**에 저장하고, ⚠️ **수집 후 보안 그룹으로 인스턴스를 격리**합니다 |
| **디스크 포렌식** | **EBS 볼륨 스냅샷**을 떠서 **포렌식 계정과 공유**합니다 |

⚠️⚠️ **격리 방식이 중요합니다** — **새 보안 그룹을 대상 인스턴스에 부착하고 사용자·관리자·개발자의 모든 접근을 제거**합니다. 공식이 그 목적을 **관리 연속성(chain of custody) 보장**으로 적습니다.

수집이 끝나면 조사 Step Functions 상태 머신에 통지가 가고, **포렌식 AMI로 인스턴스를 시작**해 S3의 메모리를 로드하고 스냅샷에서 EBS 볼륨을 만들어 연결합니다. 조사는 **SSM 문서**로 실행되고, **SNS**가 결과를 공유하며 **AppSync**로 포렌식 타임라인을 쿼리할 수 있습니다. 트리아지·수집 상태는 **DynamoDB**에 저장됩니다.

#### 4-2. ARC — 어느 기능을 쓰는지가 갈림길이다

ARC는 **AWS 글로벌 클라우드 인프라에서 도는 애플리케이션의 더 빠른 복구**를 돕고, 기능이 **다중 AZ**와 **다중 리전**으로 갈립니다.

| 기능 | 축 | 성질 |
|---|---|---|
| **영역 전환(zonal shift)** | 다중 AZ | ⚠️ **수동·임시**이고 **최대 3일 만료**(연장 가능). 손상된 AZ에서 같은 리전의 건강한 AZ로 트래픽을 옮깁니다 |
| **영역 자동 전환(zonal autoshift)** | 다중 AZ | ⚠️ **AWS가 내부 텔레메트리**(AWS 네트워크·EC2·ELB 지표 포함)로 **시작하고 종료**합니다 |
| **리전 전환(Region switch)** | 다중 리전 | 여러 계정에 걸친 **대규모·복잡한 복구 작업을 오케스트레이션**합니다 |
| **라우팅 컨트롤** | 다중 리전 | **DNS 트래픽 실패 조치**. ⚠️ **안전 규칙(safety rules)**으로 "활성·대기 중 하나만 켜진다" 같은 가드레일을 걸 수 있습니다 |
| **준비 상태 확인(readiness check)** | 다중 리전 | 쿼터·용량·네트워크 라우팅 정책을 계속 모니터링합니다. ⚠️⚠️ **2026-03-31 공지로 유지 관리 상태**이고, 공식 자신이 **"장애 중 실패 조치의 임계 경로에서 쓰도록 의도된 것이 아니다"**라고 적습니다 |

⚠️ 문항이 "단일 AZ 손상에서 빠르게 회복"을 물으면 **영역 전환**(또는 자동 전환)이고, "리전 장애에서 애플리케이션을 넘긴다"면 **리전 전환 또는 라우팅 컨트롤**입니다. **준비 상태 확인을 복구 경로의 일부로 설계하는 보기는 공식 서술과 어긋납니다.**

#### 4-3. 자동화의 경계 — 사람이 승인할 자리

자동 해결 설계에서 **되돌릴 수 없는 작업**과 **되돌릴 수 있는 작업**을 가릅니다.

- **되돌릴 수 있고 자동화해도 되는 것** — 스냅샷 생성 · 메모리 덤프 수집 · 태그 부착 · 조사 결과 보강
- **영향이 크고 승인을 두는 것** — 인스턴스 종료 · 자격 증명 폐기 · 프로덕션 트래픽 전환

⚠️ 포렌식 오케스트레이터가 **격리를 「메모리 수집 후」에 두는 것**도 같은 이유입니다 — 휘발성 증거를 먼저 확보하고 나서 접근을 끊습니다.

## ✍️ 시험 포인트

- **OpsItem 자동 생성 경로** — CloudWatch 알람의 `ALARM` 진입, EventBridge 이벤트
- **Shield Advanced 비용 경계** — 덮는 것(표준 WAF·1,500 WCU·기본 본문)과 덮지 않는 것(Bot Control·CAPTCHA·초과분)
- **자동 완화의 WCU 비용** — 150 WCU가 보호 팩 사용량에 더해진다
- **FIS 중단 조건** — CloudWatch 알람이다. "실험이 위험해지면 멈추게 하라"의 답
- **FIS 실행 위치** — 프로덕션 전에 사전 프로덕션에서
- **Resilience Hub ↔ FIS** — Resilience Hub 안에서 실험을 만든다
- **포렌식 트리거 체인** — 탐지 → Security Hub → EventBridge → Step Functions
- **포렌식 선행 요건** — 포렌식 AMI
- **격리 순서** — 메모리 수집 → 격리(관리 연속성)
- **ARC 기능 선택** — AZ는 영역 전환, 리전은 리전 전환·라우팅 컨트롤, **준비 상태 확인은 복구 경로가 아니다**

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"Shield Advanced를 구독하면 AWS WAF 비용이 전부 무료다"** → **표준 비용만** 덮고 **Bot Control·CAPTCHA·초과 WCU·초과 본문 검사는 별도**입니다
- ❌ **"자동 L7 완화는 공짜로 켜진다"** → **150 WCU**가 보호 팩 사용량에 더해집니다
- ❌ **"FIS 실험은 시뮬레이션이다"** → **실제 리소스에 실제 작업**을 합니다
- ❌ **"FIS 중단 조건은 FIS 안에서 정의하는 별도 규칙이다"** → **CloudWatch 알람**입니다
- ❌ **"Resilience Hub와 FIS는 둘 중 하나를 고른다"** → **Resilience Hub 안에서 FIS 실험을 만들 수 있습니다**
- ❌ **"포렌식 오케스트레이터를 배포하면 바로 쓴다"** → **포렌식 AMI가 선행 요건**입니다
- ❌ **"침해 인스턴스는 먼저 격리하고 그다음 증거를 모은다"** → 공식 흐름은 **메모리 수집 → 격리**입니다(휘발성 증거)
- ❌ **"ARC 준비 상태 확인으로 실패 조치를 트리거한다"** → **임계 경로용이 아니고** 그 기능은 **유지 관리 상태**입니다
- ❌ **"영역 자동 전환은 내가 시작한다"** → **AWS가 내부 텔레메트리로** 시작·종료합니다
- ❌ **"영역 전환은 영구적이다"** → **임시**이고 **최대 3일**(연장 가능)입니다

## 🧪 자가 점검

**Q1.** DDoS 보호를 강화하려고 Shield Advanced를 구독하고 ALB를 보호 대상에 넣었습니다. 그 ALB의 web ACL에는 **Bot Control 규칙 그룹**이 있고 전체 WCU가 **1,800**입니다. 비용은 어떻게 됩니까? (→ 2-2 Shield Advanced)

<details><summary>정답 보기</summary>

**두 항목이 구독에 덮이지 않습니다.**

구독이 덮는 것은 **보호 대상 리소스의 표준 AWS WAF 비용**(보호 팩(web ACL)당 비용 · 규칙당 비용 · 웹 요청 검사 백만 건당 기본 가격)이고, 그 범위가 **1,500 WCU까지, 기본 본문 크기까지**입니다.

- **Bot Control**은 공식이 명시한 **비표준 비용**이라 덮이지 않습니다
- **1,800 WCU**는 **1,500을 넘으므로** 그 초과분도 덮이지 않습니다

⚠️ 그리고 **자동 애플리케이션 계층 DDoS 완화를 켜면 150 WCU 규칙 그룹이 추가**되고 그 WCU가 보호 팩 사용량에 **계산**됩니다 — 한도에 가까운 web ACL이라면 이것만으로 넘길 수 있습니다.
</details>

**Q2.** "장애 시나리오에서 대응 런북이 실제로 동작하는지 확인하라"는 요구입니다. 프로덕션에서 바로 돌려도 됩니까? (→ 3-1 AWS FIS)

<details><summary>정답 보기</summary>

**바로 돌리지 않습니다.** 공식이 **"AWS FIS는 시스템의 실제 AWS 리소스에 실제 작업을 수행한다"**고 적고, 프로덕션 실험 전에 **계획 단계를 완료하고 사전 프로덕션 환경에서 실험을 돌리라고 강하게 권합니다.**

안전 장치는 **중단 조건(stop condition)**이고 ⚠️ **내가 정의한 CloudWatch 알람**입니다. 실험 중 발동하면 FIS가 실험을 멈춥니다. 그 밖에 **조건 충족 시 자동 롤백·중단** 가드레일이 있습니다.

⚠️ 실험은 **실험 템플릿**으로 정의하고 구성 요소는 **작업 · 대상 · 중단 조건** 셋입니다. 작업은 **순차 또는 병렬**로 돌고, 대상은 **태그·상태 같은 기준으로 그룹**을 고를 수 있습니다.
</details>

**Q3.** GuardDuty가 EC2 인스턴스의 악성 도메인 질의를 탐지했을 때 자동으로 메모리와 디스크를 수집하고 인스턴스를 격리하려 합니다. 어떤 경로로 트리거되고 무엇을 미리 준비해야 합니까? (→ 4-1 자동 포렌식 오케스트레이터)

<details><summary>정답 보기</summary>

**경로** — 애플리케이션 계정의 **GuardDuty(또는 AWS Config 관리형 규칙·타사 도구)** 탐지 → 조사 결과가 **보안 계정의 Security Hub**로 → **기본적으로 모든 Security Hub 조사 결과가 EventBridge로** → EventBridge가 **인스턴스 ID**를 넘기며 **Step Functions 워크플로**를 시작 → Step Functions가 **트리아지**(Security Hub 작업으로 **격리 필요 여부**, 인스턴스 **태그**로 **수집 필요 여부**).

**미리 준비할 것** — ⚠️ **포렌식 AMI**입니다. EC2 Image Builder로 만들거나 기존 AMI를 쓰고, Step Functions가 그 AMI로 메모리·디스크 조사를 수행합니다.

⚠️ 수집은 **메모리와 디스크 두 흐름이 병렬**이고, **메모리 수집 후 보안 그룹으로 격리**합니다 — 새 보안 그룹을 부착해 **사용자·관리자·개발자의 모든 접근을 제거**하고, 공식이 그 목적을 **관리 연속성 보장**으로 적습니다.
</details>

**Q4.** 다중 리전 애플리케이션에서 "리전 장애 시 실패 조치가 가능한 상태인지 계속 확인하고, 실제 장애가 오면 그 확인 결과로 전환을 트리거"하는 설계를 제안받았습니다. 어떻게 답해야 합니까? (→ 4-2 ARC)

<details><summary>정답 보기</summary>

**뒷부분이 공식 서술과 어긋납니다.** ARC **준비 상태 확인**은 쿼터·용량·네트워크 라우팅 정책을 계속 모니터링해 실패 조치 능력에 영향을 줄 변화를 알려 주지만, 공식이 **"장애 중 실패 조치의 임계 경로에서 쓰도록 의도된 것이 아니다"**라고 적습니다. 용도는 **ARC를 처음 구성할 때와 정상 운영 중**입니다.

⚠️ 게다가 **준비 상태 확인은 2026-03-31 공지로 유지 관리 상태**입니다. 새로 설계한다면 이 기능에 의존하지 않습니다.

전환 자체는 **리전 전환(Region switch)**이나 **라우팅 컨트롤**(안전 규칙 포함)이 맡고, 단일 AZ 손상이라면 **영역 전환**(수동·임시·최대 3일)이나 **영역 자동 전환**(AWS가 내부 텔레메트리로 시작·종료)입니다.
</details>

**Q5.** CloudWatch 알람이 `ALARM`으로 바뀔 때마다 운영팀이 수동으로 티켓을 만들고 있습니다. 표준화하고 중복을 줄이려면? (→ 1-1 OpsCenter)

<details><summary>정답 보기</summary>

**OpsCenter**입니다. 알람이 **`ALARM` 상태에 들어갈 때 OpsItem을 자동 생성**하도록 구성할 수 있고(EventBridge 이벤트로도 가능), OpsItem은 **서비스 경계를 넘어 집계·표준화**됩니다.

함께 얻는 것 —
- **AWS Config · CloudTrail 로그 · CloudWatch Events** 정보가 리소스 단위로 집계돼 콘솔을 옮겨 다니지 않습니다
- **Systems Manager Automation 런북**이 함께 제공돼 바로 해결을 시도할 수 있습니다
- ⚠️ **관련 리소스 ARN을 지정하면 내장 로직이 중복 OpsItem 생성을 피하게** 돕습니다
- **공개 API**로 기존 사례 관리 시스템·상태 대시보드와 통합할 수 있습니다

⚠️ 공식이 드는 EventBridge 규칙 예시에 **`AWS Security Hub CSPM: 보안 경고 발생`**이 있습니다 — 보안 조사 결과도 같은 경로로 OpsItem이 됩니다.
</details>

**Q6.** 침해된 EC2 인스턴스를 발견했습니다. 팀원이 "지금 바로 인스턴스를 종료해서 피해를 막자"고 합니다. 어떻게 답해야 합니까? (→ 4-3 자동화의 경계)

<details><summary>정답 보기</summary>

**종료하면 휘발성 증거가 사라집니다.** 공식 포렌식 흐름이 **메모리 수집 → 격리** 순서인 이유가 그것입니다 — 메모리 데이터를 캡처해 S3에 저장한 **뒤에** 보안 그룹으로 격리합니다.

권하는 순서는 ① **메모리·디스크 증거 확보**(메모리 덤프 → S3, EBS 스냅샷 → 포렌식 계정 공유) ② **격리**(새 보안 그룹 부착으로 사용자·관리자·개발자 접근 제거 — 관리 연속성) ③ 분석 뒤 복구·폐기 판단입니다.

⚠️ 자동화 설계에서도 같은 선을 긋습니다 — **스냅샷·덤프·태그 부착은 자동화**하고, **인스턴스 종료·자격 증명 폐기·프로덕션 트래픽 전환은 승인**을 둡니다.
</details>

---

### 📌 출처

1. AWS Systems Manager OpsCenter — `docs.aws.amazon.com/systems-manager/latest/userguide/OpsCenter.html` (2026-11-08 확인)
2. What is AWS Fault Injection Service? — `docs.aws.amazon.com/fis/latest/userguide/what-is.html` (2026-11-08 확인)
3. What is AWS Resilience Hub? — `docs.aws.amazon.com/resilience-hub/latest/userguide/what-is.html` (2026-11-08 확인)
4. What is ARC? (Amazon Application Recovery Controller) — `docs.aws.amazon.com/r53recovery/latest/dg/what-is-route53-recovery.html` (2026-11-08 확인)
5. AWS Shield Advanced overview — `docs.aws.amazon.com/waf/latest/developerguide/ddos-advanced-summary.html` (2026-11-08 확인)
6. Architecture overview — Automated Forensics Orchestrator for Amazon EC2 and EKS — `docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/architecture-overview.html` (2026-11-08 확인)
7. What is AWS Security Incident Response? (범위 메모용) — `docs.aws.amazon.com/security-ir/latest/userguide/what-is.html` (2026-11-08 확인)
8. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-08 확인)
