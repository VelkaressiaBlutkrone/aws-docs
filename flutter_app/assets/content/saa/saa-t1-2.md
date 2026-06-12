---
examGuideTaskId: saa-t1-2
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: 다중 계정 보안 — Organizations·Control Tower·SCP
coversTasks:
  - "1.1"
sources:
  - title: AWS Organizations 소개 (공식)
    url: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html
  - title: 서비스 제어 정책(SCP) (공식)
    url: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
  - title: AWS Control Tower란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
---

# 다중 계정 보안 — Organizations·Control Tower·SCP

> **커버하는 공식 Task** — SAA-C03 · 도메인 1 「보안 아키텍처 설계」(30%) · **Task 1.1 AWS 리소스에 대한 보안 액세스 설계** (`saa-t1-2`)
> 이 문서는 다계정 거버넌스에 집중합니다. IAM 자격증명·역할·페더레이션 기초는 `saa-t1-1`을 먼저 읽으세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 1.1의 다계정 부분 기반)

- [ ] **AWS Organizations 구조** — 관리 계정·멤버 계정·OU 계층을 그릴 수 있다
- [ ] **SCP 작동 원리** — 권한을 부여하지 않고 상한선만 설정하며, 관리 계정에는 적용되지 않음을 설명할 수 있다
- [ ] **SCP vs 권한 경계** — 적용 범위(계정·OU 전체 vs 개별 사용자·역할)의 차이를 구분할 수 있다
- [ ] **다계정 전략 모범 사례** — 관리 계정·로그 계정·감사 계정을 분리하는 이유를 설명할 수 있다
- [ ] **AWS Control Tower 구성요소** — Landing Zone·가드레일(예방·탐지·사전예방)·Account Factory의 역할을 설명할 수 있다
- [ ] **IAM Identity Center 연계** — 다계정 환경에서 중앙 SSO 진입점으로 사용하는 방식을 설명할 수 있다

---

## 🎯 왜 중요한가

- 실제 기업 환경은 단일 AWS 계정이 아닌 **수십~수백 개의 계정**으로 구성됩니다. SAA 시험은 이 규모의 설계 결정을 묻습니다.
- 다계정 보안은 **폭발 반경(blast radius) 제한**이 핵심입니다. 한 계정이 침해되어도 다른 계정에 영향이 없도록 격리합니다.
- SCP는 시험에서 "관리자도 할 수 없게 막으려면?" 유형의 단골 소재입니다. SCP가 권한을 부여하지 않는다는 점이 가장 자주 출제됩니다.
- Control Tower는 "빠르게 다계정 환경을 구축하려면?" 시나리오에서 정답으로 등장합니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **관리 계정** | Management account | Organizations를 소유하는 단일 계정 — SCP 미적용·결제 집계 역할 |
| **멤버 계정** | Member account | 실제 워크로드가 돌아가는 계정 — SCP 적용 대상 |
| **폭발 반경** | blast radius | 침해 사고가 퍼질 수 있는 최대 범위 — 계정 격리로 좁힘 |
| **Landing Zone** | Landing Zone | Control Tower가 자동 구성하는 다계정 환경 전체(관리·로그·감사 계정 포함) |
| **권한 세트** | Permission Set | IAM Identity Center에서 각 계정에 재사용 가능한 IAM 권한 템플릿 |
| **서비스 연결 역할** | Service-linked role | AWS 서비스가 위임받아 직접 사용하는 역할 — SCP 적용 예외 |
| **통합 결제** | Consolidated Billing | 조직 내 모든 계정 사용량을 하나의 청구서로 합산하는 기능 |
| **전체 기능 모드** | All features | SCP를 비롯한 Organizations 정책 기능을 사용하기 위한 활성화 모드 |

---

## 📖 핵심 개념

### 1) AWS Organizations

> 공식 정의: **"AWS 계정을 중앙에서 관리하고 거버넌스하는 서비스."** 계정 생성·그룹화·정책 적용·통합 결제를 하나의 서비스로 처리합니다.

**Organizations 구조:**

| 요소 | 설명 |
|---|---|
| **관리 계정(Management account)** | Organizations를 소유하는 단일 계정. SCP의 적용을 받지 않음. 결제 관리 |
| **멤버 계정(Member account)** | 실제 워크로드를 실행하는 계정. SCP 적용 대상 |
| **루트(Root)** | Organizations 계층의 최상위 컨테이너. 여기에 SCP를 붙이면 전 조직 적용 |
| **OU(Organizational Unit)** | 계정을 묶는 논리적 그룹. 중첩 가능(최대 5단계). OU에 SCP를 붙이면 하위 계정 전체 적용 |

**Organizations의 주요 기능:**

- **통합 결제(Consolidated Billing)**: 모든 계정 사용량을 하나의 청구서로. 볼륨 할인이 합산 적용됩니다.
- **계정 중앙 생성**: API·CLI로 새 계정을 프로그래밍 방식으로 생성합니다.
- **정책 기반 관리**: SCP·태그 정책·백업 정책 등을 계정·OU·루트 단위로 적용합니다.
- **서비스 위임 관리자**: 관리 계정 대신 특정 멤버 계정에 서비스 관리를 위임할 수 있습니다.

> 중요: Organizations는 **전체 기능 모드(All features)**를 활성화해야 SCP를 사용할 수 있습니다. 통합 결제 전용 모드에서는 SCP가 비활성화됩니다.

> 🧠 원리: 왜 Organizations는 계정을 단순 목록이 아닌 OU 트리 계층으로 묶을까요?
> 계정이 수십~수백 개로 늘면 각 계정에 정책을 개별 붙이면 중복이 폭발하고 누락 계정이 생깁니다.
> OU 트리 모델에서는 상위 노드(루트·OU)에 SCP 한 번만 설정하면 하위 계정 전체로 자동 상속되어 새 계정을 OU에 추가하는 순간 가드레일이 즉시 적용됩니다.
> 또한 환경(개발·운영)·사업부·규정 요건이 다른 그룹을 별도 OU로 분리해 각각 다른 SCP를 중첩 없이 독립적으로 관리할 수 있습니다.

### 2) 다계정 전략 — 계정 분리 모범 사례

AWS Well-Architected 및 Control Tower가 권장하는 계정 분리 패턴입니다.

| 계정 유형 | 역할 | 특성 |
|---|---|---|
| **관리 계정** | Organizations 소유, 결제 관리 | 워크로드 실행 금지. SCP 미적용 |
| **로그 아카이브 계정** | 전 계정 CloudTrail·Config 로그 중앙 보관 | 로그 계정 외 수정 불가 |
| **감사(Audit) 계정** | 보안팀 전용. 전 계정 읽기 전용 접근 | 침해 시 독립 조사 가능 |
| **개발·스테이징·운영 계정** | 워크로드 실행 환경 분리 | 각 환경 SCP로 가드레일 적용 |

> 폭발 반경 원칙: 운영 계정이 침해되어도 로그 계정의 감사 기록은 변조할 수 없습니다. 계정 분리 = 보안 격리입니다.

> 🧠 원리: 왜 CloudTrail 로그를 워크로드 계정과 별개의 로그 아카이브 계정에 보관할까요?
> 로그가 보호 대상 계정 안에 있으면 그 계정이 침해된 공격자는 자신의 행적을 지우기 위해 로그도 삭제하거나 변조할 수 있습니다.
> 로그를 별도 계정에 격리하면 워크로드 계정의 IAM 권한·SCP와 무관하게 로그 계정 자체의 접근 제어가 독립적으로 작동합니다.
> 이 계정 경계가 로그의 무결성을 보장하는 물리적 분리선이 되며, SCP + S3 Object Lock으로 로그 계정 내부에서도 삭제를 이중으로 차단할 수 있습니다.

### 3) SCP(서비스 제어 정책)

> 공식 정의: **"조직의 IAM 사용자와 역할이 수행할 수 있는 최대 권한을 중앙에서 제어하는 정책."** 권한 부여가 아닌 **상한선 설정**입니다.

**SCP의 핵심 규칙:**

- SCP는 **권한을 부여하지 않습니다**. IAM 정책에서 Allow가 있어야만 접근 가능합니다.
- 유효 권한 = SCP에서 허용 AND IAM 정책에서 허용 **(교집합)**
- SCP는 **멤버 계정의 루트 사용자**에도 적용됩니다.
- SCP는 **관리 계정에는 적용되지 않습니다** — 관리 계정의 IAM 사용자·역할·루트는 SCP의 영향을 받지 않습니다.
- 서비스 연결 역할(Service-linked role)에는 SCP가 적용되지 않습니다.

**SCP 적용 계층:**

```
루트(Root) SCP
  └─ OU SCP (루트 + OU 교집합)
       └─ 계정 SCP (루트 + OU + 계정 교집합)
            └─ IAM 정책 (최종 유효 권한 결정)
```

상위 계층에서 차단된 권한은 하위에서 아무리 Allow해도 복구되지 않습니다.

**SCP 예시 — 특정 리전 외 사용 금지:**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "StringNotEquals": {
        "aws:RequestedRegion": ["ap-northeast-2"]
      }
    }
  }]
}
```

> 이 SCP를 OU에 적용하면 해당 OU 내 모든 계정의 모든 IAM 아이덴티티(루트 포함)가 서울 리전 외에서 어떤 API도 호출할 수 없습니다.

> 🧠 원리: 왜 SCP는 IAM 정책과 별도 레이어로 존재하며 서비스 연결 역할에는 적용되지 않을까요?
> SCP는 계정 내부 IAM 시스템이 아닌 Organizations 레이어(계정 외부)에서 평가됩니다 — 계정 IAM 관리자가 수정할 수 없는 이유입니다.
> 서비스 연결 역할은 AWS 서비스가 해당 계정에서 작동하기 위해 필요한 최소 권한으로 사전 정의되어 있어, SCP로 막으면 서비스 자체가 동작하지 않는 부작용이 생깁니다.
> 따라서 Organizations는 서비스 연결 역할을 SCP 평가에서 제외해 SCP 강화가 AWS 서비스 기능을 의도치 않게 중단시키는 상황을 방지합니다.

**SCP vs 권한 경계 비교 (★ 시험 핵심):**

`saa-t1-1`에서 자세히 다뤘으나 다계정 맥락에서의 핵심만 요약합니다.

| 구분 | SCP | 권한 경계(Permissions Boundary) |
|---|---|---|
| **적용 단위** | 계정·OU·루트(Organizations 전체) | 개별 IAM 사용자·역할 |
| **설정 주체** | Organizations 관리자 | 계정 내 IAM 관리자 |
| **목적** | 조직 전체 가드레일 | 위임 시 과도 권한 방지 |
| **권한 부여** | 불가(상한선만) | 불가(상한선만) |

### 4) AWS Control Tower

> 공식 정의: **"규범적 모범 사례를 따르는 AWS 다계정 환경을 간편하게 설정하고 거버넌스하는 서비스."** AWS Organizations·Service Catalog·IAM Identity Center를 오케스트레이션합니다.

**Control Tower 핵심 구성요소:**

| 구성요소 | 설명 |
|---|---|
| **Landing Zone** | Control Tower가 자동 구성하는 다계정 환경 전체. 관리·로그·감사 계정 포함 |
| **가드레일(Controls/Guardrails)** | 전체 AWS 환경에 지속적으로 적용되는 고수준 규칙 |
| **Account Factory** | 표준화된 구성으로 새 계정을 자동 프로비저닝하는 템플릿 |
| **대시보드** | 전체 Landing Zone의 규정 준수 상태를 중앙에서 모니터링 |

**가드레일 3가지 유형:**

| 유형 | 작동 방식 | 구현 도구 |
|---|---|---|
| **예방적(Preventive)** | 규정 위반 행동 자체를 차단 | SCP |
| **탐지적(Detective)** | 규정 위반 상태를 탐지하고 알림 | AWS Config 규칙 |
| **사전예방적(Proactive)** | 리소스 프로비저닝 전 규정 준수 여부 확인 | CloudFormation 훅 |

**가드레일 3가지 지침 등급:**

| 등급 | 의미 |
|---|---|
| **필수(Mandatory)** | 항상 활성화. 비활성화 불가 |
| **강력 권장(Strongly recommended)** | AWS 모범 사례 기반. 선택 활성화 |
| **선택(Elective)** | 특정 규정 요건에 맞게 선택 활성화 |

> **Control Tower vs Organizations 직접 구성:** Organizations를 직접 구성하면 유연하지만 복잡합니다. Control Tower는 모범 사례를 사전 탑재한 오케스트레이션 레이어로, 빠르게 규정 준수 환경을 만들 때 적합합니다.

> 🧠 원리: 왜 Control Tower는 예방적 가드레일만으로 충분하지 않아 탐지·사전예방 유형을 별도로 두었을까요?
> 예방적 가드레일(SCP)은 IAM API 호출을 차단하지만, 기존에 이미 잘못 구성된 리소스나 콘솔 외부 경로로 생성된 리소스는 감지하지 못합니다.
> 탐지적 가드레일(AWS Config)은 실시간 구성 변화를 감시해 SCP가 놓친 드리프트를 발견하고, 사전예방적 가드레일(CloudFormation 훅)은 IaC 배포 단계에서 비준수 리소스가 생성되기 전에 차단합니다.
> 세 유형이 계층을 이루면 배포 전·배포 중·배포 후 세 시점을 모두 커버해 가드레일 사각지대를 줄입니다.

### 5) IAM Identity Center — 다계정 거버넌스 관점

IAM Identity Center 기초는 `saa-t1-1`에서 다뤘습니다. 여기서는 다계정 거버넌스 관점에 집중합니다.

- IAM Identity Center는 **Organizations와 통합**되어 모든 멤버 계정에 대한 SSO를 중앙에서 관리합니다.
- **권한 세트(Permission Set)**: 각 계정에서 사용자·그룹에게 부여할 IAM 권한을 정의한 템플릿. 계정별로 동일 권한 세트를 재사용합니다.
- Control Tower Landing Zone은 IAM Identity Center를 기본 SSO 메커니즘으로 자동 설정합니다.

**다계정 접근 흐름:**

```
사용자 → IAM Identity Center 포털 로그인
    → 접근 가능한 계정 목록 확인
    → 원하는 계정 + 권한 세트 선택
    → STS 임시 자격증명 발급
    → 해당 계정 리소스 접근
```

> 🧠 원리: 왜 IAM Identity Center는 각 계정에 IAM 정책을 직접 붙이지 않고 권한 세트(Permission Set) 템플릿을 사용할까요?
> 계정 수가 많을수록 각 계정에 동일한 IAM 정책을 개별 생성하면 변경 시 전 계정을 순회해야 하고, 한 계정이라도 누락되면 권한 불일치가 생깁니다.
> 권한 세트는 중앙에서 한 번 정의하면 IAM Identity Center가 할당된 모든 계정에 자동 프로비저닝하므로, 권한 변경 한 번으로 수백 계정에 즉시 반영됩니다.
> 이 구조 덕분에 권한 감사도 각 계정의 IAM이 아닌 IAM Identity Center 한 곳에서 일괄 확인할 수 있습니다.

---

## ✍️ 시험 포인트

- **"모든 계정에서 특정 서비스·리전을 막으려면"** → SCP를 루트 또는 OU에 적용. 계정 내 IAM 관리자도 이 제한을 풀 수 없습니다.
- **"SCP는 권한을 부여한다."** → 오답. SCP는 상한선만 설정합니다. IAM 정책의 Allow가 별도로 있어야 합니다.
- **"관리 계정도 SCP의 제한을 받는다."** → 오답. 관리 계정에는 SCP가 적용되지 않습니다. 멤버 계정만 적용 대상입니다.
- **"멤버 계정 루트 사용자는 SCP를 무시할 수 있다."** → 오답. SCP는 멤버 계정의 루트 사용자에도 적용됩니다.
- **"다계정 Landing Zone을 빠르게 모범 사례로 구성"** → AWS Control Tower. Organizations를 직접 구성하는 것보다 빠르고 가드레일이 사전 탑재됩니다.
- **"새 계정을 표준 구성으로 자동 프로비저닝"** → Control Tower의 Account Factory.
- **"전 조직 직원이 여러 계정에 SSO로 접근"** → IAM Identity Center + Organizations.
- **통합 결제만 필요한 경우** → Organizations의 통합 결제 기능만으로 충분. SCP는 전체 기능 모드에서만 사용 가능합니다.
- **"CloudTrail 로그를 멤버 계정이 삭제하지 못하게"** → SCP로 `cloudtrail:DeleteTrail` 거부 + 로그를 별도 로그 아카이브 계정에 저장.

---

## ⚠️ 흔한 함정

1. **"SCP에 Allow를 추가하면 그 계정의 사용자가 자동으로 접근 가능해진다."** → 그렇지 않습니다. SCP의 Allow는 최대치를 허용하는 것이고, 실제 접근은 IAM 정책의 Allow가 별도로 필요합니다.
   *(원리: §3 — SCP는 Organizations 레이어 상한선이고 IAM 정책은 계정 레이어 허용이므로 두 레이어의 교집합이 유효 권한이다.)*

2. **"관리 계정에 SCP를 붙이면 관리 계정도 제한된다."** → 관리 계정은 SCP의 적용을 받지 않습니다. 이것이 관리 계정에 워크로드를 실행하면 안 되는 이유 중 하나입니다.
   *(원리: §1 — 관리 계정이 Organizations를 소유하므로 스스로에게 적용할 SCP를 관리하는 주체가 되는 순환이 생겨 예외 처리된다.)*

3. **"Control Tower는 Organizations를 대체한다."** → Control Tower는 Organizations를 *오케스트레이션*하는 레이어입니다. 내부적으로 Organizations를 사용하며, 대체가 아닌 추상화입니다.
   *(원리: §4 — Control Tower는 가드레일·Account Factory를 더하는 추상화층이며 Organizations 트리가 실제 구조를 담당한다.)*

4. **"가드레일 = SCP다."** → 예방적 가드레일만 SCP로 구현됩니다. 탐지적 가드레일은 AWS Config 규칙, 사전예방적 가드레일은 CloudFormation 훅으로 구현됩니다.
   *(원리: §4 — 세 유형은 배포 전·후·중 시점을 분담해 SCP가 커버하지 못하는 드리프트와 IaC 단계 위반을 보완한다.)*

5. **"OU에 SCP를 붙이면 상위 OU의 SCP가 무시된다."** → SCP는 **누적 교집합**입니다. 루트→OU→계정 순서로 모든 SCP를 AND로 교집합한 결과가 유효 권한의 상한선입니다. 상위 SCP가 막은 권한은 하위에서 열 수 없습니다.
   *(원리: §3 — 루트→OU→계정 평가 순서가 상위 권한 결정자를 우선시하므로 하위 SCP가 상위 차단을 Allow로 복구하는 경로 자체가 없다.)*

6. **"서비스 연결 역할도 SCP로 제한할 수 있다."** → 서비스 연결 역할(Service-linked role)에는 SCP가 적용되지 않습니다. AWS 서비스가 위임받아 사용하는 역할이므로 예외입니다.
   *(원리: §3 — 서비스 연결 역할을 SCP로 막으면 AWS 서비스 자체가 동작 불가해지므로 Organizations가 이 역할 유형을 SCP 평가에서 제외한다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 조직 전체의 모든 멤버 계정에서 `us-east-1` 외 리전 사용을 금지하려 합니다. 가장 올바른 방법은?

<details><summary>정답 보기</summary>

**루트(Root)에 SCP를 적용**합니다. `aws:RequestedRegion` 조건으로 `ap-northeast-2`(또는 허용 리전) 외의 모든 리전을 `Deny`하는 SCP를 루트에 붙이면, 조직 내 모든 멤버 계정의 IAM 사용자·역할·루트 사용자가 제한됩니다. 단, 관리 계정에는 SCP가 적용되지 않으므로 관리 계정은 별도 관리가 필요합니다. Permission Boundary는 개별 사용자·역할에만 적용되므로 조직 전체 가드레일에는 SCP가 맞습니다.
</details>

**Q2.** 멤버 계정의 관리자가 `AdministratorAccess` 정책을 보유하고 있음에도 특정 서비스를 사용하지 못하고 있습니다. 가장 가능성 높은 원인은?

<details><summary>정답 보기</summary>

**SCP가 해당 서비스를 차단**하고 있을 가능성이 높습니다. SCP는 IAM 정책보다 우선 적용되는 상한선입니다. `AdministratorAccess`(와일드카드 Allow)가 있어도, 상위 OU 또는 루트의 SCP에서 해당 서비스를 `Deny`하거나 `Allow`하지 않으면 접근이 불가합니다. 유효 권한은 SCP와 IAM 정책의 교집합이기 때문입니다.
</details>

**Q3.** 새 AWS 다계정 환경을 빠르게 구축해야 합니다. 보안·규정 준수 모범 사례를 사전 적용하고, 새 계정 요청 시 표준 구성으로 자동 프로비저닝도 필요합니다. 어떤 서비스를 선택하나요?

<details><summary>정답 보기</summary>

**AWS Control Tower**입니다. Control Tower는 모범 사례 기반의 Landing Zone을 자동 구성하고, 예방·탐지·사전예방 가드레일을 사전 탑재합니다. Account Factory는 새 계정을 표준 구성으로 자동 프로비저닝하는 템플릿입니다. Organizations를 직접 구성하면 유연하지만 시간이 많이 걸립니다. "빠르게 + 모범 사례 + 표준 프로비저닝" 세 조건이 있으면 Control Tower가 정답입니다.
</details>

**Q4.** 기업의 보안 정책상 CloudTrail 로그를 어떤 계정의 관리자도 삭제하거나 변조할 수 없어야 합니다. 어떻게 구현하나요?

<details><summary>정답 보기</summary>

두 가지를 함께 사용합니다. 첫째, **SCP**로 조직 전체에 `cloudtrail:DeleteTrail`·`cloudtrail:StopLogging`·`cloudtrail:UpdateTrail`을 `Deny`합니다. 이렇게 하면 멤버 계정의 루트 사용자를 포함한 모든 IAM 아이덴티티가 CloudTrail을 비활성화하거나 삭제할 수 없습니다. 둘째, 로그를 **로그 아카이브 계정(전용 멤버 계정)**의 S3 버킷에 중앙 저장하고, S3 버킷에 MFA Delete와 Object Lock을 설정합니다. 로그 아카이브 계정 자체에도 SCP를 적용해 이 계정에서도 로그 삭제를 제한합니다.
</details>

---

**Q5 (원리).** 왜 SCP의 권한 상한선은 루트→OU→계정 계층 순서로 누적 교집합 방식으로 작동할까요?

<details><summary>정답 보기</summary>

**Organizations 정책 평가가 루트(조직 소유자)에서 계정(피소유자) 방향으로 단방향 위임 구조이기 때문입니다.** 루트는 SCP를 소유하는 유일한 권위 지점입니다. 만약 하위 OU나 계정 SCP가 상위 결정을 덮어쓸 수 있다면, 권한 위임을 받은 쪽이 위임한 쪽의 제한을 무력화하는 — 위임의 의미가 성립하지 않는 — 구조가 됩니다. AND 교집합은 이 단방향 위임을 수학적으로 표현한 것입니다. 상위 SCP에서 Deny된 항목은 하위에서 Allow로 재정의될 수 없고, 이것이 루트에 설정한 조직 전체 가드레일이 특정 OU나 계정에서 무력화되지 않는 구조적 이유입니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07, WebFetch 200 확인 · 고도화 검수: 2026-06-12)

1. AWS Organizations 소개 — https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html
2. 서비스 제어 정책(SCP) — https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
3. AWS Control Tower란 무엇인가 — https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html
4. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
