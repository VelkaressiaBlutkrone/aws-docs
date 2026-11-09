---
examGuideTaskId: scs-t6-3
certCode: SCS-C03
domain: 6
domainName: 보안 기반 및 거버넌스
domainWeightPct: 14
title: 규정 준수 평가 (Config 규칙·준수 팩·애그리게이터·Security Hub CSPM·증거 수집)
coversTasks:
  - "6.3"
sources:
  - title: What Is AWS Config?
    url: https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html
  - title: Components of an AWS Config Rule
    url: https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_components.html
  - title: Evaluating Your Resources with AWS Config Rules
    url: https://docs.aws.amazon.com/config/latest/developerguide/evaluating-your-resources.html
  - title: Remediating Noncompliant Resources with AWS Config
    url: https://docs.aws.amazon.com/config/latest/developerguide/remediation.html
  - title: Conformance Packs for AWS Config
    url: https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html
  - title: Multi-Account Multi-Region Data Aggregation for AWS Config
    url: https://docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
  - title: What is AWS Audit Manager?
    url: https://docs.aws.amazon.com/audit-manager/latest/userguide/what-is.html
  - title: What is AWS Artifact?
    url: https://docs.aws.amazon.com/artifact/latest/ug/what-is-aws-artifact.html
  - title: What is AWS Well-Architected?
    url: https://docs.aws.amazon.com/wellarchitected/latest/userguide/well-architected.html
lastVerified: 2026-11-09
---

# 규정 준수 평가 (Config 규칙·준수 팩·애그리게이터·Security Hub CSPM·증거 수집)

> **커버하는 공식 Task** — SCS-C03 · 도메인 6 「보안 기반 및 거버넌스」(14%) · **작업 6.3 AWS 리소스의 규정 준수 평가** (`scs-t6-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 3개(6.3.1~6.3.3)를 모두 덮습니다.

> ⚠️ 이 작업의 문항은 **"그 도구가 평가만 하는가, 고치기도 하는가, 막기도 하는가"**로 갈립니다. Config 규칙은 **평가**하고, **수정은 SSM Automation 문서**가 하며, ⚠️⚠️ **Config의 사전 평가는 배포를 막지 않습니다**(§1-3). 막는 것은 작업 6.1의 예방 제어입니다.

> 그리고 증거 수집 쪽에는 **상태를 반드시 확인해야 하는 서비스**가 있습니다 — 공식 가이드가 예시로 드는 **AWS Audit Manager는 신규 고객에게 열려 있지 않습니다**(§2-1). 아키텍처 평가 쪽은 docs가 **두 서비스로 갈렸습니다**(§3-1).

---

## ✅ 학습 목표 체크리스트

- [ ] Config 규칙의 **평가 결과 4종과 트리거 3종**을 안다
- [ ] **사전 평가가 막지 않는 것**을 설명한다
- [ ] 수정이 **SSM Automation 문서**로 이뤄지는 것을 안다
- [ ] **준수 팩**이 규칙과 수정을 함께 담는 것을 안다
- [ ] 애그리게이터가 **읽기 전용**인 이유와 권한 부여 예외를 안다
- [ ] Security Hub CSPM의 **ASFF와 표준·제어** 모델을 안다
- [ ] **Audit Manager의 상태**와 Artifact의 역할을 가른다
- [ ] Well-Architected의 **Tool과 Agent**를 가른다

## 🎯 왜 중요한가

준수 평가 문항은 "탐지했는데 아무도 고치지 않았다"와 "고칠 수 있다고 생각했는데 평가만 했다" 사이에서 나옵니다. AWS는 **평가 · 수정 · 차단 · 증거**를 **서로 다른 서비스와 기능**에 나눠 뒀고, 보기 네 개가 그 넷을 섞어 놓습니다.

가장 날카로운 자리는 **Config의 사전 평가**입니다. 이름이 "사전"이라 배포를 막는 것처럼 읽히는데, 공식이 Note로 **"사전 규칙은 비준수로 표시된 리소스를 수정하지도, 배포를 막지도 않는다"**고 적습니다(§1-3). 반면 작업 6.1의 Control Tower **사전 제어**는 **비준수 리소스를 프로비저닝하지 않습니다** — 단 `preCreate`·`preUpdate` 후크로 구현되므로 **CloudFormation 경로에 한정**됩니다. 두 "사전"을 섞으면 어느 쪽이든 거짓이 됩니다.

증거 쪽에서는 **범위와 책임의 구분**이 핵심입니다. Artifact는 **AWS의** 준수 문서를 주고, Audit Manager는 **내 사용에 대한** 증거를 모읍니다. 그리고 Audit Manager는 **스스로 준수를 평가하지 않습니다**(§2-1).

## ⚡ 시험 직전 요약

- Config 규칙의 평가 결과는 **`COMPLIANT` · `NON_COMPLIANT` · `ERROR`(매개변수 문제) · `NOT_APPLICABLE`(규칙 논리를 적용할 수 없는 리소스)** 넷입니다
- 트리거는 **구성 변경 · 주기적 · 하이브리드** 셋입니다. 구성 변경 범위는 **리소스 유형 / 유형+리소스 ID / 태그 키와 값 / 기록되는 모든 리소스**로 정합니다
- ⚠️⚠️ **사전 평가(proactive)는 배포를 막지 않습니다** — 공식 Note: 비준수로 표시된 리소스를 **수정하지도, 배포를 막지도 않습니다.** 켜는 방법은 `EvaluationModes`에 **`PROACTIVE`**이고 확인은 **`StartResourceEvaluation`·`GetResourceEvaluationSummary`** API입니다
- ⚠️ **수정은 AWS Systems Manager Automation 문서**가 수행합니다. 관리형 문서가 제공되고 **사용자 지정 문서**를 연결할 수 있으며 **수동·자동** 둘입니다
- **준수 팩**은 **Config 규칙과 수정 작업을 한 단위로** 묶은 YAML 템플릿입니다. **SSM 문서로 저장해 문서 이름으로 배포**할 수 있고 **조직 전체 배포**가 가능합니다
- ⚠️⚠️ **애그리게이터는 읽기 전용 뷰**입니다 — 소스 계정·리전에 **변경 액세스를 주지 않아** 애그리게이터로 **규칙을 배포하거나 스냅샷을 푸시할 수 없습니다.** **추가 비용이 없고**, **Organizations 소스면 권한 부여가 필요 없습니다**
- **Security Hub CSPM**은 결과를 **ASFF**라는 표준 형식으로 처리하고 **FSBP·CIS·PCI DSS·NIST** 같은 표준의 **제어**로 검사하며, GuardDuty·Inspector·Macie와 3자 제품의 결과도 받습니다
- ⚠️⚠️ **AWS Audit Manager는 신규 고객에게 열려 있지 않습니다**(기존 고객은 정상 사용). 그리고 **스스로 준수를 평가하지 않고 증거를 모읍니다**
- **AWS Artifact**는 **AWS의** 보안·준수 문서(ISO·PCI·SOC)를 온디맨드로 주고 **계약을 검토·수락·추적**하며 **무료**입니다
- ⚠️ **Well-Architected는 두 서비스입니다** — **Tool**(워크로드·렌즈·마일스톤, 수동 검토, **HRI·MRI** 출력)과 **Agent**(프로필, AI 분석, **프리뷰**)

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **구성 항목** | 어느 시점의 리소스 구성을 담은 기록. Config가 변경을 추적하는 단위입니다 |
| **평가 모드** | 리소스 프로비저닝 과정의 **어느 시점**에 평가할지 — **사전(배포 전)**과 **탐지(배포 후)** |
| **준수 팩** | Config 규칙과 수정 작업의 모음을 **한 단위로 배포**하는 YAML 템플릿 |
| **애그리게이터** | 여러 계정·리전의 Config 구성·준수 데이터를 모으는 **Config 리소스 유형** |
| **ASFF** | AWS 보안 결과 형식. Security Hub CSPM이 결과를 처리하는 **표준 형식**입니다 |
| **제어** | Security Hub CSPM에서 **보안 모범 사례 하나**를 나타내는 검사. 표준은 제어의 묶음입니다 |
| **평가(assessment)** | Audit Manager에서 프레임워크를 바탕으로 만들어 **증거를 모으는** 단위 |
| **감사 아티팩트** | 감사인·규제 기관에 제출하는 Artifact 문서 |
| **워크로드 / 렌즈 / 마일스톤** | Well-Architected Tool에서 비즈니스 가치를 주는 구성요소의 집합 / 검토 기준 / 시점 기록 |

## 📖 핵심 개념

### 1) 비준수 리소스를 탐지·해결하고 알린다 (기술 6.3.1) {#config-rules}

#### 1-1. Config가 무엇을 하는가

Config는 계정 안 AWS 리소스 구성의 **상세한 뷰**를 줍니다 — 리소스가 서로 어떻게 연관되고 **과거에 어떻게 구성됐는지**를 보여 줘서 구성과 관계의 변화를 시간에 따라 볼 수 있습니다.

| 쓰는 방향 | 무엇을 얻나 |
|---|---|
| **리소스 관리** | 리소스가 **만들어지거나 수정되거나 삭제될 때** 알림을 받습니다. 각 리소스 호출을 폴링하지 않아도 됩니다 |
| **감사와 준수** | 준수를 입증하려면 **과거 구성에 접근**해야 하고 그것을 Config가 줍니다 |
| **구성 변경 추적** | 서로 의존하는 리소스에서 한쪽 변경이 다른 쪽에 주는 영향을 봅니다 |
| **보안 분석** | 시간에 따른 IAM 권한·보안 그룹 규칙 등을 봅니다 |

⚠️ 전제가 다섯입니다 — 활성 **AWS 계정**, 구성 스냅샷·히스토리를 받을 **S3 버킷**, 변경 알림을 받을 **Amazon SNS 주제**, Config 접근 권한이 있는 **IAM 역할**, 그리고 **기록할 리소스 유형** 선택.

> 🧠 **원리:** Config의 1차 산출물은 "지금 준수인가"가 아니라 **구성의 시계열**입니다. 준수 평가는 그 시계열 위에 올라가는 규칙 계층이고, 그래서 **규칙을 나중에 추가해도 평가가 시작됩니다.**

#### 1-2. 규칙의 구성요소 — 결과 4종과 트리거 3종

**평가 결과는 넷**입니다.

| 결과 | 뜻 |
|---|---|
| `COMPLIANT` | 준수 검사 조건을 통과했습니다 |
| `NON_COMPLIANT` | 준수 검사 조건에 실패했습니다 |
| ⚠️ `ERROR` | **필수·선택 매개변수**가 유효하지 않거나 형식·유형이 잘못됐습니다 |
| ⚠️ `NOT_APPLICABLE` | **규칙 논리를 적용할 수 없는 리소스를 걸러낼 때** 씁니다. 예: `alb-desync-mode-check` 규칙은 Application Load Balancer만 검사하고 **Network Load Balancer와 Gateway Load Balancer는 무시**합니다 |

⚠️ **`ERROR`와 `NOT_APPLICABLE`을 "비준수"로 읽으면 안 됩니다.** 전자는 **규칙 설정 문제**, 후자는 **대상 밖**입니다. 대시보드에서 "비준수가 0인데 안전하지 않다"가 나오는 이유가 보통 후자입니다.

**트리거는 셋**입니다.

| 트리거 | 언제 평가하나 |
|---|---|
| **구성 변경** | 규칙 **범위(scope)**에 맞는 리소스의 구성이 바뀔 때. 구성 항목 변경 알림이 온 뒤 평가합니다 |
| **주기적** | 내가 고른 빈도로(예: 24시간마다) 평가합니다 |
| **하이브리드** | 일부 규칙은 **구성 변경과 주기 트리거를 모두** 갖습니다 |

⚠️ **범위를 정하는 방법 넷** — ① 하나 이상의 **리소스 유형** ② **리소스 유형 + 리소스 ID** 조합 ③ **태그 키와 값** 조합 ④ **기록되는 모든 리소스가 만들어지거나 업데이트되거나 삭제될 때**. ③이 작업 6.2의 태그 전략과 이어집니다.

#### 1-3. 평가 모드 — 사전 평가는 막지 않는다

규칙을 추가할 때 **리소스 프로비저닝 과정의 어느 시점**에 평가할지 고릅니다. 배포 **전**이 **사전 평가**, 배포 **후**가 **탐지 평가**이고, 규칙에 따라 **둘 다** 가능합니다.

⚠️⚠️ **사전 평가의 한계를 공식이 Note로 못박습니다.**

> **사전 규칙은 `NON_COMPLIANT`로 표시된 리소스를 수정하지도, 배포를 막지도 않습니다.**

즉 사전 평가가 주는 것은 **"이 속성 집합으로 리소스를 정의하면 준수일까 비준수일까"라는 답**뿐입니다. 평가 대상 속성은 **리소스 유형 스키마**가 정하고, 그 스키마는 CloudFormation 레지스트리의 **AWS 퍼블릭 확장**에서 보거나 `aws cloudformation describe-type --type-name "AWS::S3::Bucket" --type RESOURCE`로 봅니다.

**켜는 방법과 확인 방법** —

- 콘솔에서 규칙의 **평가 모드**에서 **사전 평가 켜기**를 고릅니다. 지원하는 관리형 규칙은 **평가 모드별 관리형 규칙 목록**에 있습니다
- API·CLI로는 `put-config-rule`(또는 `PutConfigRule`)에서 **`EvaluationModes`에 `PROACTIVE`**를 켭니다
- 켠 뒤 **`StartResourceEvaluation`**과 **`GetResourceEvaluationSummary`** API로 지정한 리소스가 비준수로 표시될지 확인합니다

> 🧠 **원리:** Config는 **기록과 평가**의 서비스이고 **요청 경로에 서 있지 않습니다.** 그래서 "미리 알려 줄" 수는 있어도 "막을" 수는 없습니다. 막는 것은 요청 경로나 제어 플레인에 서 있는 것들입니다 — SCP·RCP·선언적 정책, 그리고 CloudFormation 후크로 구현된 Control Tower 사전 제어(작업 6.1 §2-2).

#### 1-4. 수정 — SSM Automation 문서가 한다

⚠️ **Config는 수정을 직접 하지 않습니다.** 공식 문장 그대로 — **Config는 AWS Systems Manager Automation 문서를 사용해 수정을 적용합니다.** 그 문서가 비준수 리소스에 수행할 작업을 정의합니다.

- **관리형 자동화 문서 묶음**이 수정 작업과 함께 제공됩니다
- **사용자 지정 자동화 문서**를 만들어 규칙에 연결할 수 있습니다
- 연결은 **콘솔 또는 API**로 합니다
- 설정은 **수동 수정**과 **자동 수정** 둘입니다

#### 1-5. 준수 팩과 애그리게이터 — 묶음과 집계

**준수 팩**은 **Config 규칙과 수정 작업의 모음을 한 단위로** 계정·리전 또는 **조직 전체**에 배포하는 것입니다.

- **YAML 템플릿**을 저작해 관리형·사용자 지정 규칙과 수정 작업을 나열합니다
- ⚠️ **AWS Systems Manager 문서(SSM 문서)에 준수 팩 템플릿을 저장**하고 **문서 이름으로 직접 배포**할 수 있습니다
- 콘솔 또는 AWS CLI로 배포하고, 시작은 **샘플 준수 팩 템플릿**을 권합니다
- ⚠️ 주제에 **프로세스 검사(Process Checks)**가 있습니다 — 자동 평가로 덮을 수 없는 요건을 준수 팩 안에서 추적하는 장치입니다

**애그리게이터**는 Config 구성·준수 데이터를 모으는 Config 리소스 유형이고 소스는 셋입니다 — **여러 계정과 여러 리전** / **단일 계정과 여러 리전** / **Organizations 조직과 Config가 켜진 모든 계정**.

| 성질 | 내용 |
|---|---|
| **용례** | 준수 모니터링 · 변경 추적 · **리소스 관계 분석** |
| ⚠️⚠️ **읽기 전용** | 소스 계정·리전의 데이터를 애그리게이터 계정으로 **복제**합니다. **변경 액세스를 주지 않아** 애그리게이터로 **규칙을 배포하거나 스냅샷 파일을 푸시할 수 없습니다** |
| **비용** | ⚠️ **추가 비용이 없습니다** |
| ⚠️ **권한 부여** | 애그리게이터 계정·리전에 데이터 수집 권한을 줘야 하는데, **Organizations에 속한 소스 계정을 집계할 때는 권한 부여가 필요하지 않습니다** |
| **서비스 연결 애그리게이터** | 특정 AWS 서비스에 연결되고 **범위를 그 서비스가 정합니다** |

#### 1-6. Security Hub CSPM — 한 창에 모은다

**AWS Security Hub CSPM**(Cloud Security Posture Management)은 AWS 보안 상태의 종합 뷰를 주고 환경을 **보안 업계 표준과 모범 사례에 비춰 평가**합니다.

| 축 | 내용 |
|---|---|
| **표준과 제어** | **FSBP**(AWS Foundational Security Best Practices) 외에 **CIS · PCI DSS · NIST** 같은 외부 준수 프레임워크를 지원합니다. 각 표준은 **여러 제어**를 담고 **제어 하나가 보안 모범 사례 하나**입니다 |
| ⚠️ **표준 형식** | 결과를 **ASFF**(AWS Security Finding Format)로 처리합니다. 그래서 여러 출처·형식의 결과를 따로 관리하지 않아도 됩니다 |
| **결과 수신** | **GuardDuty · Amazon Inspector · Amazon Macie**와 지원되는 3자 제품의 결과를 받습니다. 반대로 Security Hub CSPM 결과를 다른 서비스·제품으로 **보낼** 수도 있습니다 |
| **자동화** | **자동화 규칙**으로 기준에 따라 결과를 수정·억제하고, **EventBridge 통합**으로 특정 결과에 자동 대응을 트리거합니다. **사용자 지정 작업**으로 티켓 시스템이나 자동 수정 시스템에 보냅니다 |
| **집계** | **교차 리전 집계**로 집계 리전을 만들고 여러 리전의 결과를 한곳에서 봅니다 |
| **점수** | 검사 결과로 **보안 점수**를 계산하고 주의가 필요한 계정·리소스를 식별합니다 |

⚠️ 작업 6.1과의 연결 — Control Tower의 통합 탐지 제어는 **`Service-Managed Standard: AWS Control Tower`** 표준이 소유하고 다른 Security Hub 제어처럼 **Config 규칙으로 구현**됩니다. 즉 "Control Tower 탐지 제어"와 "Security Hub CSPM 제어"와 "Config 규칙"은 **같은 기제의 다른 이름**인 경우가 있습니다.

> 🧠 **원리:** Config는 **구성**을 보고 Security Hub CSPM은 **결과(finding)**를 모읍니다. 그래서 "여러 계정의 구성 이력을 한 계정에서 조회"는 **애그리게이터**이고, "여러 출처의 보안 결과를 한 창에서 우선순위 매기기"는 **Security Hub CSPM**입니다.

### 2) 감사 서비스로 증거를 수집·정리한다 (기술 6.3.2) {#evidence}

#### 2-1. AWS Audit Manager — 상태를 먼저 적는다

⚠️⚠️ **`AWS Audit Manager`는 신규 고객에게 열려 있지 않습니다.** 공식 사용자 안내서가 페이지 머리에 적습니다 — 신규 고객에게 더 이상 열려 있지 않고 **기존 고객은 정상적으로 서비스를 계속 사용**할 수 있습니다. 공식 시험 가이드가 `기술 6.3.2`의 예시로 이 서비스를 들기 때문에 **이름과 역할은 알아 두되 신규 도입 선택지로 다루지 않습니다.**

역할 자체는 명확합니다 — AWS 사용을 **지속적으로 감사**해 위험·규정 준수 관리를 단순화하고 **증거 수집을 자동화**해 정책·절차·활동(= **제어**)이 효과적으로 작동하는지 평가하기 쉽게 합니다.

| 개념 | 내용 |
|---|---|
| **프레임워크** | 특정 준수 표준·규정에 맞춰 평가를 구조화·자동화하는 **사전 구축 묶음**. 제어와 설명·테스트 절차를 담습니다. 표준 프레임워크는 **CIS Foundation Benchmark · PCI DSS · GDPR · HIPAA · SOC2 · GxP · AWS 운영 모범 사례** 등을 덮습니다 |
| **평가(assessment)** | 프레임워크로 만들면 **리소스 평가가 자동 실행**되고 범위 내 계정의 데이터를 모아 **감사에 쓸 수 있는 증거**로 변환해 관련 제어에 붙입니다 |
| **수집 중단** | 감사가 끝나 증거 수집이 필요 없으면 **평가 상태를 비활성(inactive)으로** 바꿉니다 |
| **하이브리드·멀티클라우드** | AWS 환경 밖 **온프레미스·멀티클라우드 증거를 업로드해 중앙 관리**할 수 있습니다 |
| **사용자 지정** | 제어를 처음부터 만들거나 기존 제어의 **편집 가능한 복사본**을 만듭니다. **위험 평가 질문을 만들고 응답을 수동 증거로 저장**할 수도 있습니다 |
| **공유** | 사용자 지정 프레임워크를 **다른 계정과 공유**하거나 **내 계정의 다른 리전으로 복제**합니다 |
| **협업** | 제어 집합을 주제 전문가에게 **위임**해 증거를 검토하고 의견을 달고 상태를 갱신하게 합니다 |

⚠️⚠️ **공식이 Note로 분명히 적는 한계가 있습니다** — Audit Manager는 특정 표준·규정 준수 검증에 **관련된 증거를 모으는 것을 돕지만 준수 자체를 평가하지는 않습니다.** 모은 증거가 감사에 필요한 **모든** 정보를 담지 않을 수도 있습니다. "Audit Manager를 켜면 준수 여부를 판정해 준다"는 거짓입니다.

⚠️ 관련 서비스도 공식이 나열합니다 — **Security Hub CSPM · CloudTrail · License Manager · Control Tower · Artifact · EventBridge**입니다.

#### 2-2. AWS Artifact — 누구의 문서인가가 핵심이다

Artifact는 **AWS의 보안·준수 문서를 온디맨드로 다운로드**합니다.

| 무엇을 주나 | 예 |
|---|---|
| **준수 보고서** | **ISO** 표준 준수, **PCI** 보안 표준, **SOC** 보고서 |
| **인증서** | AWS 보안 제어의 구현과 운영 효과를 검증한 **인증 기관의 인증서** |
| **ISV 문서** | AWS Marketplace에서 제품을 파는 **독립 소프트웨어 공급업체**의 보안·준수 문서(Marketplace Vendor Insights) |
| **계약** | AWS와의 계약을 **검토·수락하고 상태를 추적**합니다. **내 계정과 조직의 여러 계정**에 대해 할 수 있습니다 |
| **Assurance Assistant** | 준수·실사 질문에 **AI 기반 응답**을 생성합니다 |

⚠️ 쓰는 방향이 둘입니다 — 내가 쓰는 **AWS 인프라와 서비스의** 보안·준수를 입증하려고 감사인·규제 기관에 **감사 아티팩트로 제출**하고, 그 아티팩트를 **내 클라우드 아키텍처를 평가하고 사내 통제의 효과를 가늠하는 지침**으로도 씁니다.

⚠️⚠️ **공식이 Note로 책임 경계를 적습니다** — **AWS 고객은 자기 회사의 보안·준수를 입증하는 문서를 직접 개발하거나 확보할 책임이 있습니다**(공동 책임 모델). Artifact가 주는 것은 **AWS 쪽** 문서입니다.

⚠️ **요금은 무료입니다** — AWS가 Artifact 문서와 계약을 **무료로** 제공합니다.

> 🧠 **원리:** 두 서비스를 가르는 축은 **"누구에 대한 증거인가"**입니다. Artifact는 **AWS가 한 일**의 증거를, Audit Manager는 **내가 AWS에서 한 일**의 증거를 다룹니다. "감사인이 AWS 데이터센터의 물리 보안 증거를 요구한다" → Artifact. "감사인이 우리 계정의 제어 운영 증거를 요구한다" → Audit Manager(쓸 수 있는 경우).

### 3) 아키텍처가 보안 모범 사례를 준수하는지 평가한다 (기술 6.3.3) {#well-architected}

#### 3-1. 지금은 두 서비스다

공식 시험 가이드는 `기술 6.3.3`에서 **「AWS Well-Architected Framework 도구」** 하나를 예시로 듭니다. 그런데 공식 문서는 지금 **두 가지 방식**을 나란히 싣습니다.

| 축 | **AWS Well-Architected Tool** | **AWS Well-Architected Agent** |
|---|---|---|
| **접근 방식** | **수동**, 안내에 따라 워크로드를 Well-Architected Framework에 비춰 **자가 검토** | **자동화**된 **AI 기반** 분석 — 배포된 리소스와 IaC 템플릿을 분석 |
| **주 엔티티** | **워크로드**(비즈니스 가치를 주는 구성요소의 집합을 문서화) | **프로필**(분석할 계정·리전·원칙·목표를 정의) |
| **출력** | ⚠️ **식별된 위험(HRI·MRI)**과 검토 답변에 기반한 **개선 계획** | 우선순위가 매겨진 권장 사항 + **절충 분석** + 자동화 스크립트 + 갱신된 IaC 템플릿 |
| **언제** | **구조적 아키텍처 검토, 거버넌스, 마일스톤으로 시간에 따른 개선 추적** | 지속적·목표 주도 최적화와 즉시 실행 가능한 수정 |
| **상태** | 일반 사용 | ⚠️⚠️ **프리뷰 릴리스**이고 **변경될 수 있습니다** |

⚠️⚠️ **시험이 묻는 쪽은 `Well-Architected Tool`입니다.** Agent는 **프리뷰**이고, 공식 문서도 두 서비스가 **서로 보완하며 같은 콘솔에서 동시에 쓸 수 있다**고 적습니다.

⚠️ Tool의 어휘 셋을 기억합니다 — **워크로드 · 렌즈 · 마일스톤**. 결정을 문서화하고 개선 영역을 식별하고 **시간에 따라 진행을 추적**하는 데 그 셋을 씁니다.

> 🧠 **원리:** Tool과 Agent는 **증거의 출처**가 다릅니다. Tool은 **사람의 답변**을, Agent는 **배포된 리소스와 IaC**를 읽습니다. 그래서 "검토 결과를 거버넌스 기록으로 남기고 시점 비교"는 Tool의 마일스톤이고, "지금 환경에서 자동으로 권장 사항을 받아 바로 적용"은 Agent 쪽입니다.

## ✍️ 시험 포인트

- **"비준수 리소스를 자동으로 고쳐라"** → Config **수정 작업** + **SSM Automation 문서**(자동 수정). 규칙 자체는 고치지 않습니다
- **"비준수 리소스가 만들어지지 않게 하라"** → ⚠️ **Config 사전 평가가 아닙니다.** 막는 것은 SCP·RCP·선언적 정책 또는 CloudFormation 후크 제어입니다(작업 6.1)
- **"배포 전에 준수 여부를 미리 알고 싶다"** → **사전 평가** + `StartResourceEvaluation`
- **"규칙과 수정을 묶어 조직 전체에 배포"** → **준수 팩**(조직 준수 팩)
- **"자동 평가가 불가능한 요건도 같은 팩에서 추적"** → **프로세스 검사**
- **"여러 계정·리전의 구성·준수를 한 계정에서 조회"** → **애그리게이터**. ⚠️ **읽기 전용**이라 규칙 배포는 못 합니다
- **"애그리게이터로 규칙을 배포"** → **불가능**합니다. 조직 준수 팩이나 StackSets를 씁니다
- **"여러 출처의 보안 결과를 한 창에서 우선순위"** → **Security Hub CSPM**(ASFF)
- **"결과를 기준에 따라 자동 억제·수정"** → Security Hub CSPM **자동화 규칙**
- **"AWS의 SOC 보고서를 감사인에게 제출"** → **Artifact**(무료)
- **"우리 계정의 제어 운영 증거를 모아 보고서로"** → **Audit Manager**. ⚠️ **신규 고객에게 열려 있지 않습니다**
- **"준수 여부를 서비스가 판정"** → 어느 서비스도 하지 않습니다. Audit Manager도 **증거를 모으고 준수를 평가하지는 않습니다**
- **"아키텍처 검토 결과를 시점별로 비교"** → **Well-Architected Tool**의 **마일스톤**(HRI·MRI와 개선 계획)

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"사전 평가를 켜면 비준수 리소스 배포가 차단된다"** → 공식 Note: **수정하지도, 배포를 막지도 않습니다**
- ❌ **"`NOT_APPLICABLE`은 문제가 있다는 뜻"** → **규칙 논리를 적용할 수 없는 리소스를 걸러낸 것**입니다. `ERROR`가 매개변수 문제입니다
- ❌ **"Config 규칙이 리소스를 직접 고친다"** → 수정은 **SSM Automation 문서**가 합니다
- ❌ **"준수 팩은 규칙만 담는다"** → **규칙과 수정 작업**을 담습니다. **SSM 문서로 저장·배포**도 됩니다
- ❌ **"애그리게이터 계정에서 규칙을 배포하면 전 계정에 퍼진다"** → **읽기 전용**입니다. 변경 액세스가 없습니다
- ❌ **"애그리게이터는 비용이 든다"** → **추가 비용이 없습니다**
- ❌ **"조직 계정을 집계할 때도 계정마다 권한 부여가 필요하다"** → **Organizations 소스면 필요 없습니다**
- ❌ **"Security Hub CSPM이 자체 형식으로 결과를 만든다"** → **ASFF**라는 표준 형식으로 처리해 출처가 달라도 하나로 다룹니다
- ❌ **"Audit Manager가 준수 여부를 판정한다"** → **증거를 모을 뿐 준수를 평가하지 않습니다**
- ❌ **"Audit Manager를 지금 새로 도입하면 된다"** → **신규 고객에게 열려 있지 않습니다**
- ❌ **"Artifact로 우리 회사의 준수 문서를 받는다"** → Artifact는 **AWS 쪽** 문서입니다. 고객 문서는 **고객 책임**입니다
- ❌ **"Well-Architected 도구는 하나다"** → **Tool과 Agent 둘**이고 **Agent는 프리뷰**입니다

## 🧪 자가 점검

**Q1.** 플랫폼팀이 "암호화되지 않은 EBS 볼륨이 **아예 만들어지지 않게**" 하려고 해당 Config 관리형 규칙에 **사전 평가**를 켰습니다. 그런데 암호화되지 않은 볼륨이 계속 생깁니다. 왜이고, 요건을 만족시키는 방법은? (→ 1-3 평가 모드)

<details><summary>정답 보기</summary>

**Config의 사전 평가는 배포를 막지 않습니다.**

- 공식이 Note로 못박습니다 — **"사전 규칙은 `NON_COMPLIANT`로 표시된 리소스를 수정하지도, 배포를 막지도 않습니다."**
- 사전 평가가 주는 것은 **"이 속성 집합으로 리소스를 정의하면 준수일지 비준수일지"에 대한 답**입니다. 확인은 **`StartResourceEvaluation`**과 **`GetResourceEvaluationSummary`** API로 하고, 켜는 방법은 `EvaluationModes`에 **`PROACTIVE`**입니다
- 실제로 막으려면 **요청 경로나 제어 플레인에 서 있는 통제**가 필요합니다 — **SCP·RCP·선언적 정책**(API 수준·제어 플레인), 또는 **CloudFormation 후크로 구현된 Control Tower 사전 제어**(단 그쪽은 CloudFormation 경로만 봅니다, 작업 6.1 §2-4)
- 이미 만들어진 것은 **탐지 평가 + 자동 수정**으로 다룹니다 — 수정은 **SSM Automation 문서**가 수행합니다

⚠️ 두 "사전"을 섞지 않는 것이 이 작업의 핵심입니다 — **Config 사전 평가는 알려 주고, Control Tower 사전 제어는 프로비저닝하지 않습니다**(그 대신 `preCreate`·`preUpdate` 후크를 거치는 **CloudFormation 경로에 한정**됩니다).
</details>

**Q2.** 보안팀이 Config 대시보드에서 "비준수 리소스 0건"을 확인하고 감사인에게 "전부 준수"라고 보고했습니다. 그런데 감사인이 몇몇 로드 밸런서가 검사되지 않았다고 지적했습니다. 무엇을 잘못 읽었습니까? (→ 1-2 결과 4종)

<details><summary>정답 보기</summary>

**`NOT_APPLICABLE`을 "준수"로 읽었습니다.**

- 공식이 평가 결과 넷을 적습니다 — `COMPLIANT` / `NON_COMPLIANT` / **`ERROR`**(필수·선택 매개변수가 유효하지 않거나 유형·형식이 잘못된 경우) / **`NOT_APPLICABLE`**
- `NOT_APPLICABLE`은 **규칙 논리를 적용할 수 없는 리소스를 걸러낼 때** 쓰입니다. 공식이 드는 예가 바로 이 상황입니다 — **`alb-desync-mode-check` 규칙은 Application Load Balancer만 검사하고 Network Load Balancer와 Gateway Load Balancer는 무시합니다**
- 즉 "비준수 0"은 **"검사 대상 중 실패가 없다"**는 뜻이고 **"전부 검사됐다"**는 뜻이 아닙니다
- `ERROR`도 함께 봐야 합니다 — 규칙 매개변수가 잘못돼 평가가 성립하지 않은 경우이고, 이 역시 "준수"가 아닙니다

⚠️ 검사 범위를 넓히려면 규칙의 **범위(scope)**를 봅니다 — ① 리소스 유형 ② 리소스 유형 + 리소스 ID ③ **태그 키와 값** ④ 기록되는 모든 리소스의 생성·업데이트·삭제. 그리고 애초에 **기록할 리소스 유형**이 선택돼 있는지도 확인합니다.
</details>

**Q3.** 거버넌스팀이 보안 계정에 Config 애그리게이터를 세워 조직 전체의 구성·준수를 보고 있습니다. 이제 "같은 애그리게이터에서 모든 계정에 Config 규칙을 배포"하려고 합니다. 가능합니까? (→ 1-5 애그리게이터)

<details><summary>정답 보기</summary>

**불가능합니다. 애그리게이터는 읽기 전용 뷰입니다.**

- 공식이 Note로 적습니다 — 애그리게이터는 소스 계정의 데이터를 애그리게이터 계정으로 **복제해 읽기 전용 뷰**를 제공하고 **소스 계정·리전에 변경 액세스를 제공하지 않습니다.** 그래서 **애그리게이터를 통해 규칙을 배포하거나 스냅샷 파일을 소스 계정·리전으로 푸시할 수 없습니다**
- 규칙을 전 계정에 배포하려면 다른 수단을 씁니다 — **조직 준수 팩**(규칙과 **수정 작업**을 묶은 YAML 템플릿을 조직 전체에 배포), **조직 Config 규칙**, 또는 **CloudFormation StackSets**(작업 6.2)
- ⚠️ 애그리게이터의 좋은 성질 둘도 기억합니다 — **추가 비용이 없고**, **Organizations에 속한 소스 계정을 집계할 때는 권한 부여가 필요하지 않습니다**(개별 계정을 직접 지정할 때만 권한 부여가 필요합니다)
- 소스는 셋입니다 — 여러 계정·여러 리전 / 단일 계정·여러 리전 / **조직과 Config가 켜진 그 조직의 모든 계정**

⚠️ 용례도 공식이 적습니다 — 준수 모니터링, 변경 추적, **리소스 관계 분석**입니다.
</details>

**Q4.** 감사인이 두 가지를 요구합니다 — ① **AWS 데이터센터의 물리 보안 통제에 대한 제3자 인증 보고서** ② **우리 계정에서 제어가 실제로 운영됐다는 증거**. 각각 무엇으로 대응합니까? (→ 2-1·2-2 증거의 주체)

<details><summary>정답 보기</summary>

**①은 AWS Artifact, ②는 AWS Audit Manager입니다 — 다만 Audit Manager는 상태를 확인해야 합니다.**

**① AWS Artifact**

- **AWS의** 보안·준수 문서를 온디맨드로 다운로드합니다 — **ISO** 준수 보고서, **PCI** 보안 표준, **SOC** 보고서, 그리고 **AWS 보안 제어의 구현과 운영 효과를 검증한 인증 기관의 인증서**
- 감사인·규제 기관에 **감사 아티팩트로 제출**합니다. **무료**입니다
- 계약도 Artifact에서 **검토·수락·추적**하고, **Assurance Assistant**로 준수·실사 질문에 AI 기반 응답을 받을 수 있습니다

**② AWS Audit Manager**

- ⚠️⚠️ **신규 고객에게 열려 있지 않습니다.** 기존 고객은 정상적으로 계속 쓸 수 있습니다. 새로 도입하는 조직이라면 이 선택지가 없습니다
- 쓸 수 있다면 역할은 명확합니다 — **프레임워크**(CIS Foundation Benchmark·PCI DSS·GDPR·HIPAA·SOC2·GxP·AWS 운영 모범 사례 등)로 **평가**를 만들면 리소스 평가가 자동 실행돼 **감사에 쓸 수 있는 증거**로 변환되고 관련 제어에 붙습니다
- ⚠️ 그리고 공식 Note를 함께 봐야 합니다 — Audit Manager는 **증거 수집을 돕지만 준수 자체를 평가하지 않고**, 모은 증거가 감사에 필요한 **모든** 정보를 담지 않을 수도 있습니다

⚠️ 공동 책임 경계도 Artifact 문서가 적습니다 — **AWS 고객은 자기 회사의 보안·준수를 입증하는 문서를 직접 개발하거나 확보할 책임**이 있습니다.
</details>

**Q5.** 아키텍처팀이 "Well-Architected로 보안 검토를 하고 분기마다 개선을 추적하자"고 합니다. 콘솔에 들어가니 선택지가 둘입니다. 무엇을 고르고 왜입니까? (→ 3-1 Tool과 Agent)

<details><summary>정답 보기</summary>

**AWS Well-Architected Tool입니다.**

- 공식이 두 서비스를 표로 가릅니다 — Tool은 **워크로드를 Well-Architected Framework에 비춰 수동으로 안내에 따라 자가 검토**하고, 출력이 **식별된 위험(HRI·MRI)과 검토 답변에 기반한 개선 계획**입니다
- **언제 쓰는가**에 요건이 그대로 있습니다 — **"구조적 아키텍처 검토, 거버넌스, 마일스톤으로 시간에 따른 개선 추적"**. "분기마다 개선을 추적"이 **마일스톤**입니다
- Tool의 주 엔티티는 **워크로드**(비즈니스 가치를 주는 구성요소의 집합을 문서화)이고 어휘는 **워크로드·렌즈·마일스톤**입니다
- ⚠️⚠️ 다른 선택지인 **AWS Well-Architected Agent는 프리뷰 릴리스이고 변경될 수 있습니다.** 주 엔티티가 **프로필**(분석할 계정·리전·원칙·목표)이고, 배포된 리소스와 IaC 템플릿을 **AI로 분석**해 절충 분석·자동화 스크립트·갱신된 IaC 템플릿을 줍니다
- 둘은 **서로 보완**하며 **같은 콘솔에서 동시에** 쓸 수 있습니다

⚠️ 시험 관점 — 공식 시험 가이드 `기술 6.3.3`이 드는 것은 **「Well-Architected Framework 도구」**이고, 묻는 쪽은 Tool입니다. Agent는 **프리뷰**라는 사실만 알아 둡니다.
</details>

**Q6.** 보안팀이 GuardDuty·Inspector·Macie와 3자 WAF 제품을 쓰는데 "결과 형식이 다 달라 우선순위를 못 매긴다"고 합니다. 그리고 "심각도 높은 결과가 오면 티켓을 자동 생성"하고 싶습니다. 무엇을 어떻게 씁니까? (→ 1-6 Security Hub CSPM)

<details><summary>정답 보기</summary>

**AWS Security Hub CSPM입니다.**

- 공식이 그 효과를 이렇게 적습니다 — Security Hub CSPM은 결과 데이터를 **ASFF(AWS Security Finding Format)라는 표준 형식**으로 처리해 **여러 출처의 여러 형식 결과를 따로 관리할 필요를 없애고**, 제공자 간 결과를 **상호 연관**시켜 중요한 것의 우선순위를 돕습니다
- 결과를 받는 출처가 공식에 적혀 있습니다 — **GuardDuty · Amazon Inspector · Amazon Macie**와 지원되는 3자 제품. 반대로 Security Hub CSPM 결과를 다른 AWS 서비스·3자 제품으로 **보낼** 수도 있습니다
- 티켓 자동 생성은 두 장치로 합니다 — **자동화 규칙**(정의한 기준에 따라 결과를 수정·억제)과 **Amazon EventBridge 통합**(특정 결과에 자동 대응 트리거). 공식이 드는 예가 **결과를 티켓 시스템이나 자동 수정 시스템으로 보내는 사용자 지정 작업**입니다
- 여러 리전을 쓰면 **교차 리전 집계**로 집계 리전을 만들어 한곳에서 봅니다

⚠️ 표준과 제어 모델도 함께 기억합니다 — **FSBP** 외에 **CIS·PCI DSS·NIST**를 지원하고, 표준은 **제어의 묶음**이며 **제어 하나가 보안 모범 사례 하나**입니다. 검사 결과로 **보안 점수**가 계산됩니다.
</details>

### 📌 출처

1. What Is AWS Config? — `docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html` (2026-11-09 확인)
2. Components of an AWS Config Rule — `docs.aws.amazon.com/config/latest/developerguide/evaluate-config_components.html` (2026-11-09 확인)
3. Evaluating Your Resources with AWS Config Rules — `docs.aws.amazon.com/config/latest/developerguide/evaluating-your-resources.html` (2026-11-09 확인)
4. Remediating Noncompliant Resources with AWS Config — `docs.aws.amazon.com/config/latest/developerguide/remediation.html` (2026-11-09 확인)
5. Conformance Packs for AWS Config — `docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html` (2026-11-09 확인)
6. Multi-Account Multi-Region Data Aggregation for AWS Config — `docs.aws.amazon.com/config/latest/developerguide/aggregate-data.html` (2026-11-09 확인)
7. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-09 확인)
8. What is AWS Audit Manager? — `docs.aws.amazon.com/audit-manager/latest/userguide/what-is.html` (2026-11-09 확인)
9. What is AWS Artifact? — `docs.aws.amazon.com/artifact/latest/ug/what-is-aws-artifact.html` (2026-11-09 확인)
10. What is AWS Well-Architected? — `docs.aws.amazon.com/wellarchitected/latest/userguide/well-architected.html` (2026-11-09 확인)
