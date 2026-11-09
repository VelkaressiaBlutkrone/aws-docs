---
examGuideTaskId: scs-t6-2
certCode: SCS-C03
domain: 6
domainName: 보안 기반 및 거버넌스
domainWeightPct: 14
title: 일관된 배포와 공유 (StackSets·Guard·cfn-lint·태그 정책·Firewall Manager·RAM)
coversTasks:
  - "6.2"
sources:
  - title: Managing stacks across accounts and Regions with StackSets
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
  - title: StackSets concepts
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-concepts.html
  - title: Validate templates with Guard
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-guard.html
  - title: Validate templates with cfn-lint
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-lint.html
  - title: CloudFormation best practices
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html
  - title: What is Tag Editor?
    url: https://docs.aws.amazon.com/tag-editor/latest/userguide/tagging.html
  - title: Tag policies
    url: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html
  - title: AWS Firewall Manager
    url: https://docs.aws.amazon.com/waf/latest/developerguide/fms-chapter.html
  - title: AWS Firewall Manager prerequisites
    url: https://docs.aws.amazon.com/waf/latest/developerguide/fms-prereq.html
  - title: Using AWS Firewall Manager administrators
    url: https://docs.aws.amazon.com/waf/latest/developerguide/fms-administrators.html
  - title: What is AWS Resource Access Manager?
    url: https://docs.aws.amazon.com/ram/latest/userguide/what-is.html
  - title: What Is Service Catalog?
    url: https://docs.aws.amazon.com/servicecatalog/latest/adminguide/introduction.html
  - title: What is AppRegistry?
    url: https://docs.aws.amazon.com/servicecatalog/latest/arguide/intro-app-registry.html
lastVerified: 2026-11-09
---

# 일관된 배포와 공유 (StackSets·Guard·cfn-lint·태그 정책·Firewall Manager·RAM)

> **커버하는 공식 Task** — SCS-C03 · 도메인 6 「보안 기반 및 거버넌스」(14%) · **작업 6.2 클라우드 리소스를 안전하고 일관성 있게 배포할 수 있는 전략 구현** (`scs-t6-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 4개(6.2.1~6.2.4)를 모두 덮습니다.

> ⚠️ 이 작업의 축은 **"중앙에서 한 번 정의한 것이 어떤 경계를 넘어 적용되는가"**입니다. StackSets는 **계정과 리전**을, 태그 정책은 **조직과 계정**을, Firewall Manager는 **계정과 리소스 유형**을, RAM은 **계정 경계 자체**를 넘습니다. 각자 넘지 못하는 선이 있고 거기서 문항이 나옵니다.

> 그리고 **검증 도구 둘을 섞으면 안 됩니다** — `cfn-lint`는 **스키마와 구문**을, **Guard**는 **조직 정책과 컴플라이언스**를 봅니다(§1-4). 둘 다 **로컬 검증**이므로 배포 전 단계의 통제이고, 배포 경로를 강제하는 것은 별개입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] StackSets의 **권한 모델 둘**과 자동 배포 조건을 가른다
- [ ] StackSet이 **리전 리소스**인 것과 삭제 선후 관계를 안다
- [ ] 실패 허용·최대 동시 계정의 **계산 규칙**을 안다
- [ ] `cfn-lint`와 **Guard**의 역할을 가른다
- [ ] 태그 정책의 **평가 대상과 비대상**을 설명한다
- [ ] 태그 정책이 **Organizations와 Resource Groups로 나뉘는** 이유를 안다
- [ ] Firewall Manager의 **전제 조건 순서**와 관리 범위 조건을 안다
- [ ] RAM과 **리소스 기반 정책 공유**의 차이를 말한다

## 🎯 왜 중요한가

"여러 계정에 일관되게 배포하라"는 요건은 보기만 보면 전부 맞아 보입니다. StackSets·Service Catalog·RAM·Firewall Manager가 모두 "계정을 넘는" 수단이기 때문입니다. 가르는 축은 **무엇을 넘기는가**입니다 — StackSets는 **스택(리소스 자체)**을, Service Catalog는 **승인된 템플릿**을, RAM은 **이미 만든 리소스의 사용권**을, Firewall Manager는 **보호 정책**을 넘깁니다.

그리고 이 작업에는 **"했다고 생각했는데 아니었다"**가 특히 많습니다. 태그 정책은 **태그되지 않은 리소스를 평가하지 않고**(§2-3), Config를 켜지 않으면 **Firewall Manager가 동작하지 않으며**(§3-2), 리소스 기반 정책으로 공유한 리소스는 **상대 콘솔에 보이지 않습니다**(§4-1). 모두 "설정은 했는데 효과가 없다"로 나타나는 자리입니다.

## ⚡ 시험 직전 요약

- ⚠️⚠️ **StackSet은 리전 리소스입니다** — 한 리전에서 만들면 **그 리전에서만 보이고 바꿀 수 있습니다**
- **권한 모델 둘** — **셀프 관리형**은 내가 IAM 역할을 만들어 신뢰 관계를 세우고(역할을 만들 권한이 있는 **어떤 계정에든** 배포), **서비스 관리형**은 StackSets가 역할을 대신 만들고 **자동 배포**를 켤 수 있습니다(관리자 계정 = **관리 계정 또는 위임된 관리자**)
- ⚠️ **템플릿 업데이트는 항상 모든 스택에 영향**을 줍니다 — 일부 스택만 선택적으로 업데이트할 수 없습니다
- ⚠️ **스택 인스턴스는 스택 없이 존재할 수 있고**, **StackSet은 스택 인스턴스가 없을 때만 삭제**됩니다. 스택을 남기려면 **`Retain Stacks`**를 씁니다
- ⚠️ **백분율은 내림**입니다(10계정의 25% → 2). `Strict Failure Tolerance` 모드에서는 **최대 동시 계정 ≤ 실패 허용 + 1**이고, **실패 허용은 리전별**입니다
- ⚠️⚠️ **`cfn-lint`는 스키마·구문, Guard는 컴플라이언스·조직 정책**입니다. `cfn-lint`는 기본적으로 **`us-east-1` 스키마**로 검사하고 **SAM 변환을 먼저 적용**합니다. Guard는 템플릿뿐 아니라 **변경 세트와 AWS Config 구성 항목**도 검사합니다
- ⚠️⚠️ **태그 정책은 태그되지 않은 리소스와 정책에 정의되지 않은 태그를 평가하지 않습니다.** 시행은 **지정한 리소스 유형**에만 걸리고, **모든 기능이 활성화된 조직**에서만 쓸 수 있습니다
- ⚠️ **태그 정책은 Organizations로 만들고 준수 확인은 Resource Groups로** 합니다. 태그 키와 값은 **모두 대소문자를 구분**하고 **태그에 PII를 넣지 않습니다**
- ⚠️⚠️ **Firewall Manager는 AWS Config를 켜야 동작하고**, Network Firewall·DNS Firewall 정책은 **RAM 리소스 공유 활성화**가 필요합니다. 요금은 **기반 서비스**(WAF·Config 등)에 붙습니다
- ⚠️ **RAM은 조직·OU·계정 ID로 공유**하고 조직 밖 계정은 **초대 수락**이 필요합니다. 리소스 기반 정책 공유와 달리 **상대의 원래 서비스 콘솔·API에 네이티브처럼 보입니다**

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **관리자 계정 / 대상 계정** | StackSet을 만드는 계정과, 스택이 만들어지는 계정. 둘 사이에 **신뢰 관계**가 필요합니다 |
| **스택 인스턴스** | 대상 계정의 한 리전에 있는 스택에 대한 **참조**. 스택이 없어도 존재할 수 있고 실패 이유를 담습니다 |
| **실패 허용** | **리전별로** 허용할 스택 작업 실패의 최대 수·비율. 넘으면 작업이 자동 중단됩니다 |
| **Guard(`cfn-guard`)** | 필요·금지 구성을 Guard 언어 규칙으로 쓰고 JSON·YAML 데이터를 검사하는 **정책 코드화 도구** |
| **`cfn-lint`** | 템플릿을 **리소스 공급자 스키마**와 추가 규칙에 비춰 검사하는 린터 |
| **태그 정책** | 리소스가 태그될 때 적용되는 **태그 규칙**(키의 대소문자 처리와 허용 값)을 선언하는 정책 |
| **TagOption** | Service Catalog가 관리하는 키·값 쌍. **AWS 태그가 아니라** AWS 태그를 만드는 **템플릿**입니다 |
| **관리 범위** | Firewall Manager 관리자가 관리할 수 있는 리소스의 범위. **전체** 또는 **제한**입니다 |
| **리소스 공유** | RAM에서 소유 계정이 만드는 객체. 공유할 리소스·보안 주체·권한을 담습니다 |

## 📖 핵심 개념

### 1) IaC로 계정 전체에 일관되게 배포한다 (기술 6.2.1) {#iac}

#### 1-1. StackSets의 권한 모델 둘

StackSets는 **단일 작업으로 여러 계정과 리전에 스택을 만들고 업데이트하고 삭제**합니다. 어떻게 대상 계정에 닿는지가 **권한 모델**입니다.

| 모델 | 역할을 누가 만드나 | 어디에 배포할 수 있나 | 자동 배포 |
|---|---|---|---|
| **셀프 관리형(self-managed)** | **내가** 만듭니다(관리자·대상 계정 사이 신뢰 관계) | **IAM 역할을 만들 권한이 있는 어떤 AWS 계정에든** | 없음 |
| **서비스 관리형(service-managed)** | **StackSets가 대신** 만듭니다 | **AWS Organizations가 관리하는 계정** | ⚠️ **있음** — 앞으로 조직에 추가되는 계정에 자동 배포 |

⚠️ 서비스 관리형의 **관리자 계정**은 **조직의 관리 계정 또는 위임된 관리자 계정**입니다. 그래서 작업 6.1의 위임 패턴이 그대로 이어집니다 — **StackSets의 신뢰 액세스를 활성화**하고 **위임된 관리자 멤버 계정을 등록**합니다.

> 🧠 **원리:** 모델 선택은 "조직 밖 계정이 있는가"로 갈립니다. 조직 안이라면 서비스 관리형이 역할 관리와 신규 계정 자동 배포를 모두 가져가므로 거의 항상 낫습니다. 조직 밖 계정에 배포해야 하면 셀프 관리형뿐입니다.

#### 1-2. 범위와 수명의 제약 넷

⚠️⚠️ **StackSet은 리전 리소스입니다.** 한 리전에서 만들면 **그 리전을 보고 있을 때만** 보고 바꿀 수 있습니다. 배포 대상이 여러 리전이어도 StackSet 자체는 한 리전에 있습니다.

⚠️ **템플릿 업데이트는 항상 모든 스택에 영향을 줍니다.** 공식이 명시합니다 — "일부 스택의 템플릿만 선택적으로 업데이트할 수 없습니다." 바꿀 수 있는 것은 셋입니다 — 기존 설정 변경·리소스 추가 / 템플릿 교체 / **기존·추가 대상 계정과 리전에 스택 추가**.

⚠️ **스택 인스턴스는 스택 없이 존재할 수 있습니다.** 스택 생성이 실패하면 스택 인스턴스가 **실패 이유를 담은 채** 남습니다. 그리고 스택 인스턴스는 **하나의 StackSet에만** 연결됩니다.

⚠️ **삭제의 선후 관계** — **StackSet은 스택 인스턴스가 없을 때만 삭제**할 수 있습니다. 스택을 StackSet에서 떼면서 **계속 돌게** 하려면 **`Retain Stacks`** 옵션을 씁니다. 그러면 그 스택은 CloudFormation에서 StackSet 밖의 독립 스택으로 관리합니다.

#### 1-3. 작업 옵션 — 숫자 규칙이 문항으로 나온다

| 옵션 | 규칙 |
|---|---|
| **최대 동시 계정** | 한 번에 작업하는 대상 계정의 **최대** 수·비율. 작업은 **한 리전씩**, 배포 순서 상자에 지정한 순서로 진행합니다 |
| ⚠️ **백분율 처리** | **내림**입니다 — 10계정에 25%를 주면 2.5가 아니라 **2계정**씩 동시 배포합니다 |
| ⚠️ **상한의 성격** | **최대값**이라 대규모 배포에서는 **서비스 스로틀링 때문에 실제 동시 계정 수가 더 낮을 수 있습니다** |
| **실패 허용** | **리전별로** 허용하는 스택 작업 실패의 최대 수·비율. 넘으면 작업이 **자동 중단**됩니다 |
| ⚠️ **두 값의 관계** | 동시성 모드가 **`Strict Failure Tolerance`**면 **최대 동시 계정은 실패 허용보다 최대 1 큰 값**까지만 가능합니다 |

> 🧠 **원리:** 두 값은 "얼마나 빨리 퍼뜨릴까"와 "얼마나 빨리 멈출까"의 거래입니다. 엄격 모드에서 둘이 묶이는 이유도 거기 있습니다 — 실패를 1건만 허용하면서 50계정에 동시 배포하면 멈추기 전에 이미 49건이 나갑니다.

#### 1-4. `cfn-lint`와 Guard — 역할이 다르다

⚠️⚠️ **두 도구는 보는 대상이 다릅니다.** 둘을 "템플릿 검사 도구"로 묶으면 문항에서 갈 길을 잃습니다.

| 축 | `cfn-lint` (CloudFormation Linter) | Guard (`cfn-guard`) |
|---|---|---|
| **무엇에 비춰 검사하나** | **CloudFormation 리소스 공급자 스키마** + 추가 규칙 | **내가 Guard 언어로 쓴 규칙**(필요·금지 구성) |
| **무엇을 잡나** | 잘못된 리소스 속성, 지원되지 않는 속성 값, **깨진 참조**, 흔한 모범 사례 문제 | 조직 정책·보안 모범 사례·거버넌스 요건 위반 |
| **입력** | JSON·YAML 템플릿 | **모든 JSON·YAML 데이터** — 템플릿 외에 **변경 세트**와 **AWS Config 구성 항목** |
| ⚠️ **기본 리전** | **`us-east-1` 스키마**로 검사합니다. 다른 리전은 `--regions` | — |
| **변환 처리** | ⚠️ **SAM 변환을 먼저 적용한 뒤** 검사합니다 | — |

⚠️ `cfn-lint` 실무 옵션 — 매개변수에 따라 결과가 달라지는 검사는 `--parameters` 또는 `--parameter-files`로 값을 줍니다. 규칙 전체는 `--list-rules`로 보고, 출력 형식은 `quiet`·`parseable`·`json`·`junit`·`pretty`·`sarif`에서 고릅니다. **사용자 지정 규칙**도 더할 수 있습니다.

⚠️ Guard 실무 — **템플릿에서 규칙을 생성**(`rulegen` 계열)할 수 있고 **규칙 자체를 테스트**할 수 있습니다. 공식 CloudFormation 모범 사례가 **CI/CD 파이프라인에 Guard를 넣어 배포 전에 자동 검증**하라고 권합니다.

⚠️⚠️ **둘 다 로컬 검증이고 한계가 있습니다.** 공식이 두 페이지에서 똑같이 "로컬 검증의 한계와 배포 전에 해야 할 일"을 따로 안내합니다. 즉 **린터와 Guard를 통과한 템플릿이 배포에서 실패할 수 있고**, 반대로 **이 도구를 거치지 않는 배포 경로가 있으면 통제가 비어 버립니다.**

### 2) 태그로 리소스를 그룹화해 관리한다 (기술 6.2.2) {#tags}

#### 2-1. 태그의 성질 — 보안 관점에서 중요한 셋

태그는 키와 값의 쌍이고 **목적·소유자·환경** 같은 기준으로 리소스를 분류합니다. 공식 기술이 드는 예시가 **부서·비용 센터·환경별 그룹화**입니다.

⚠️⚠️ **공식이 Important로 적는 한 줄이 있습니다** — **태그에 개인 식별 정보(PII)나 기밀·민감 정보를 저장하지 마십시오.** AWS가 태그를 **청구와 관리 서비스 제공에** 쓰기 때문이고, 태그는 **비공개·민감 데이터용이 아닙니다.**

⚠️ **태그 키와 값은 모두 대소문자를 구분합니다.** 다만 **IAM 리소스에는 추가 검증**이 있어 **대소문자만 다른 키의 적용을 막습니다.** 공식 권고는 **대소문자만 다른 키를 쓰지 않는 것**입니다.

**태그를 붙이는 방법은 셋**입니다 — 서비스의 **태그 API 작업** / **Tag Editor 콘솔** / **Resource Groups Tagging API**(대부분의 서비스가 지원).

⚠️ **TagOption은 태그가 아닙니다.** Service Catalog의 **TagOptions 라이브러리**는 프로비저닝된 제품의 태그를 관리하는 수단인데, 공식이 명시합니다 — **TagOption은 AWS 태그가 아니고, TagOption을 바탕으로 AWS 태그를 만드는 템플릿** 역할을 합니다.

#### 2-2. 태그 정책 — 두 서비스가 역할을 나눈다

⚠️⚠️ **태그 정책을 쓰는 데는 서비스 둘이 필요합니다.**

| 서비스 | 맡는 일 |
|---|---|
| **AWS Organizations** | **태그 정책 자체를 관리**합니다. 관리 계정에서 기능을 활성화하고 정책을 만들어 조직 엔티티에 첨부합니다 |
| **AWS Resource Groups** | **준수(compliance)를 관리**합니다. 계정에 로그인해 **비준수 태그를 찾고**, Tag Editor와 Resource Groups Tagging API로 태그를 붙이고 뗍니다 |

⚠️ **관리 계정에서 로그인하면 조직 전 계정의 준수 정보를 볼 수 있습니다.** 멤버 계정에서는 그 계정 것만 봅니다.

#### 2-3. 태그 정책의 평가 대상 — 비대상이 함정이다

태그 정책은 "`CostCenter` 태그가 리소스에 붙을 때는 정책이 정의한 대소문자 처리와 값을 써야 한다"처럼 **태그될 때 적용되는 규칙**을 선언합니다. 지정한 리소스 유형에 대해 **비준수 태그 작업을 시행(enforce)** 하도록 만들면 **비준수 태그 요청이 완료되지 못합니다.**

⚠️⚠️ **그런데 평가되지 않는 것이 둘 있습니다.** 공식 문장 그대로 — **태그되지 않은 리소스**와 **태그 정책에 정의되지 않은 태그**는 그 태그 정책의 준수 평가 대상이 아닙니다.

그래서 **"태그 정책으로 태그 없는 리소스 생성을 막는다"는 성립하지 않습니다.** 태그 정책은 §3-1의 범주상 **권한을 부여·거부하지 않는 선언적 정책**이고, "태그 없이는 만들 수 없게" 하려면 **`aws:RequestTag`·`aws:TagKeys` 조건 키를 쓰는 SCP 또는 ID 기반 정책**이 필요합니다.

⚠️ 전제 조건도 있습니다 — 태그 정책은 **모든 기능이 활성화된 조직**에서만 쓸 수 있습니다. 공식이 그 전제를 **선언적 정책의 전제 조건** 문서로 안내한다는 점도 범주를 확인해 줍니다.

⚠️ 공식 권고 순서가 명확합니다 — **단일 계정에 단순한 태그 정책을 붙여 효과를 이해한 뒤** OU·조직으로 넓히고, **시행(enforce)을 켜기 전에 특히 효과를 확실히 이해**합니다.

### 3) 중앙 집중화된 소스에서 정책을 배포·적용한다 (기술 6.2.3) {#firewall-manager}

#### 3-1. Firewall Manager가 무엇을 중앙화하는가

Firewall Manager는 **보호를 한 번 설정하면 계정과 리소스 전체에 자동 적용**하고, **계정과 리소스가 새로 추가돼도** 계속 적용합니다. 다루는 보호는 다음입니다.

- **AWS WAF**
- **AWS Shield Advanced**
- **Amazon VPC 보안 그룹**과 **네트워크 ACL**
- **AWS Network Firewall**
- **Amazon Route 53 Resolver DNS Firewall**

⚠️ 적용 범위를 정하는 방식이 셋입니다 — **계정 전체** / **특정 유형의 모든 리소스**(예: 모든 CloudFront 배포) / **특정 태그가 붙은 모든 리소스**. 세 번째가 §2의 태그와 이 작업을 잇습니다.

⚠️ 조직 차원 기능 둘이 중요합니다 — **조직의 모든 멤버 계정을 Shield Advanced에 구독**시키고 **새로 들어오는 범위 내 계정도 자동 구독**하며, **보안 그룹 규칙을 모든 멤버 계정 또는 특정 부분집합에 적용**하고 **새 계정에도 자동 적용**합니다.

⚠️ **요금은 Firewall Manager 자체가 아니라 기반 서비스에 붙습니다** — 공식이 Note로 적습니다: "AWS Firewall Manager에서 발생하는 요금은 **AWS WAF와 AWS Config 같은 기반 서비스**에 대한 것입니다."

⚠️ Firewall Manager는 **조직 전체의 DDoS 공격 중앙 모니터링**도 제공하고, **Security Hub CSPM과 통합**됩니다.

#### 3-2. 전제 조건 — 순서가 곧 문항이다

공식이 "처음 쓰기 전에 **다음 단계를 순서대로** 수행하라"고 적습니다.

1. **AWS Organizations에 가입하고 Firewall Manager용으로 구성**합니다
2. **Firewall Manager 기본 관리자 계정을 만듭니다**
3. ⚠️⚠️ **Firewall Manager용으로 AWS Config를 활성화**합니다
4. (3자 정책을 쓸 때) **AWS Marketplace에서 구독하고 3자 설정을 구성**합니다
5. ⚠️ **Network Firewall·DNS Firewall 정책을 쓸 때는 AWS RAM으로 리소스 공유를 활성화**합니다
6. 기본적으로 비활성화된 리전에서 쓸 때의 추가 설정

⚠️⚠️ **3번을 빠뜨리는 것이 가장 흔한 함정입니다.** "Firewall Manager 정책을 만들었는데 준수 상태가 비어 있다"의 전형적인 원인이고, 요금이 Config에 붙는 이유도 같습니다.

#### 3-3. 관리자 역할과 관리 범위

Firewall Manager는 **관리자를 하나 또는 여럿** 둘 수 있습니다.

| 역할 | 성격 |
|---|---|
| **기본 관리자(default administrator)** | 조직 온보딩 때 **관리 계정이 만듭니다.** **3자 방화벽을 관리할 수 있고 전체 관리 범위**를 갖습니다. 그 밖에는 다른 관리자와 **같은 동급**입니다 |
| **Firewall Manager 관리자** | 관리 계정이 **관리 범위 구성으로 지정한 리소스만** 관리합니다 |

**관리 범위 조건 세 가지**를 조합할 수 있습니다 — ① 정책을 적용할 수 있는 **계정 또는 OU** ② 작업할 수 있는 **리전** ③ 관리할 수 있는 **Firewall Manager 정책 유형**. 범위는 **전체(full)** 또는 **제한(restricted)**이고, 공식 권고는 **역할 수행에 필요한 권한만** 주는 것입니다.

⚠️ 위임과의 연결 — **Firewall Manager 관리자 계정을 만들면 서비스가 Organizations에 그 계정이 이미 Firewall Manager의 위임된 관리자인지 확인하고, 아니면 Organizations를 호출해 설정합니다.**

### 4) 계정 간에 리소스를 안전하게 공유한다 (기술 6.2.4) {#sharing}

#### 4-1. RAM — 리소스 기반 정책 공유와 무엇이 다른가

RAM은 **내가 소유한 리소스를 조직·OU·계정 ID·(일부 유형에서) IAM 역할과 사용자**에게 공유합니다. 한 번 만든 리소스를 여러 계정이 쓰게 해 중복 프로비저닝을 없앱니다.

⚠️⚠️ 리소스 기반 정책을 붙여도 계정 간 공유는 되지만 **RAM이 주는 것 네 가지가 없습니다.** 공식이 그 차이를 적습니다.

| RAM이 주는 것 | 리소스 기반 정책만 쓸 때 |
|---|---|
| **조직·OU 단위 공유** — 계정 ID를 열거하지 않습니다 | 계정 ID를 모두 적어야 합니다 |
| ⚠️⚠️ **상대의 원래 서비스 콘솔·API에 네이티브처럼 보입니다** — 공유된 VPC 서브넷이 상대 계정의 VPC 콘솔과 API 결과에 나타납니다 | **보이지 않습니다.** 상대가 **ARN으로 찾아 명시적으로 참조**해야 합니다 |
| **소유자가 리소스별로 누가 접근하는지 봅니다** | — |
| ⚠️ **조직 밖 계정과 공유하면 초대 절차**가 시작되고 **수락해야** 접근합니다. 조직 내 공유를 활성화한 뒤에는 **조직 내 계정에 초대가 필요 없습니다** | — |

⚠️ 이미 리소스 기반 정책으로 공유한 것은 **`PromoteResourceShareCreatedFromPolicy` API**(또는 동일한 CLI 명령)로 **완전한 RAM 관리형 리소스로 승격**할 수 있습니다.

⚠️ 범위 제약 — 리소스 공유를 만들 때 **리전을 지정**하고, **하나의 리소스 공유에는 리전 리소스만** 담을 수 있습니다(글로벌 리소스는 별도 규칙). 그리고 **소비 계정의 역할·사용자에게 적용되는 정책과 권한이 공유된 리소스에도 적용**됩니다.

> 🧠 **원리:** RAM과 리소스 기반 정책의 차이는 "권한을 줬는가"가 아니라 **"상대가 그것을 자기 리소스처럼 쓸 수 있는가"**입니다. 가시성이 없으면 운영이 ARN 전달과 문서화에 의존하게 되고, 그것이 감사 가능성의 차이로 이어집니다.

#### 4-2. Service Catalog — 승인된 것만 셀프 서비스로

Service Catalog는 **AWS에서 승인된 IT 서비스의 카탈로그**를 만들고 관리합니다. 최종 사용자는 **조직이 정한 제약 조건을 따라** 승인된 것만 빠르게 배포합니다.

| 이점 | 내용 |
|---|---|
| **표준화** | 제품을 **어디서 시작할 수 있는지**, **어떤 인스턴스 유형**을 쓸 수 있는지 등 여러 구성 옵션을 제한합니다 |
| **셀프 서비스 발견·시작** | 사용자는 접근 권한이 있는 제품 목록을 보고 **스스로 프로비저닝된 제품으로 시작**합니다 |
| **세분화된 액세스 제어** | 관리자가 제품을 **포트폴리오**로 묶고 **제약 조건과 리소스 태그**를 더한 뒤 **IAM 사용자·그룹에 포트폴리오 접근 권한**을 줍니다 |
| ⚠️ **확장성과 버전 관리** | 제품을 **여러 포트폴리오에 복사 없이** 넣을 수 있고, **제품을 새 버전으로 업데이트하면 그 제품을 참조하는 모든 포트폴리오의 제품에 전파**됩니다 |

⚠️ 작업 6.1과의 연결 — Control Tower의 **Account Factory가 Service Catalog의 프로비저닝된 제품 위에 만들어진 추상화**입니다. 즉 "계정 프로비저닝 표준화"와 "리소스 프로비저닝 표준화"가 같은 기제를 씁니다.

#### 4-3. AppRegistry — 범위 메모

⚠️⚠️ **`AWS Service Catalog AppRegistry`는 2026년 7월 30일부터 신규 고객에게 열려 있지 않습니다.** 공식 사용자 안내서가 페이지 머리에 그 상태를 적습니다 — 그날 전에 가입했다면 쓸 수 있고 **기존 고객은 정상적으로 계속 사용**할 수 있습니다.

AppRegistry 자체는 **애플리케이션을 만들어 연관 리소스를 담고**, 메타데이터로 **속성 그룹**을 만들며, **애플리케이션과 속성 그룹을 계정·조직·OU에 공유**하는 기능입니다. **RAM을 통해 Organizations로 공유**하고, **Well-Architected Tool**과 통합돼 모범 사례와 측정을 기존 아키텍처 거버넌스 프로세스로 확장할 수 있습니다.

⚠️ **중요한 구분** — **AWS Service Catalog 본체는 닫히지 않았습니다.** 닫힌 것은 **AppRegistry 기능**뿐이고, 포트폴리오·제품·제약 조건·프로비저닝된 제품은 그대로 쓰입니다. 공부 시간은 **본체의 공유·제약 조건 모델**에 쓰고 AppRegistry는 **상태만** 알아 둡니다.

## ✍️ 시험 포인트

- **"조직에 새로 추가되는 계정에도 자동으로 스택이 배포되게"** → **서비스 관리형 권한** + **자동 배포**. 셀프 관리형에는 그 기능이 없습니다
- **"조직 밖 파트너 계정에도 같은 스택을 배포"** → **셀프 관리형**(IAM 역할을 직접 만듭니다)
- **"StackSet이 콘솔에 안 보인다"** → **리전 리소스**입니다. 만든 리전을 보고 있는지 확인합니다
- **"일부 계정의 템플릿만 업데이트"** → **불가능**합니다. 템플릿 업데이트는 모든 스택에 영향을 줍니다
- **"StackSet을 지우려는데 안 된다"** → **스택 인스턴스가 남아 있습니다.** 스택을 살리려면 `Retain Stacks`
- **"템플릿의 깨진 참조·잘못된 속성"** → **`cfn-lint`**. **"조직 보안 정책 위반"** → **Guard**
- **"AWS Config 구성 항목도 같은 규칙으로 검사"** → **Guard**(모든 JSON·YAML 데이터를 봅니다)
- **"태그 없는 리소스 생성을 막아라"** → 태그 정책이 아니라 **조건 키를 쓰는 SCP·ID 기반 정책**. 태그 정책은 **태그되지 않은 리소스를 평가하지 않습니다**
- **"조직 전 계정의 태그 준수를 확인"** → **Resource Groups**(정책 관리는 Organizations)
- **"Firewall Manager 정책이 동작하지 않는다"** → **AWS Config 활성화**를 확인합니다. NFW·DNS FW면 **RAM 리소스 공유**도 봅니다
- **"관리자마다 다룰 정책 유형을 제한"** → **관리 범위 조건**(계정·OU / 리전 / 정책 유형)
- **"공유한 서브넷이 상대 콘솔에 보여야 한다"** → **RAM**. 리소스 기반 정책 공유는 ARN 참조여야 보입니다
- **"승인된 구성만 셀프 서비스로 배포"** → **Service Catalog**(포트폴리오 + 제약 조건)

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"서비스 관리형이면 IAM 역할도 내가 만든다"** → **StackSets가 대신 만듭니다.** 내가 만드는 쪽이 셀프 관리형입니다
- ❌ **"StackSet은 글로벌 리소스다"** → **리전 리소스**입니다
- ❌ **"스택 생성이 실패하면 스택 인스턴스도 없다"** → **스택 없이 존재하며 실패 이유를 담습니다**
- ❌ **"최대 동시 계정 25%면 2.5계정"** → **내림**해서 2계정입니다. 그리고 스로틀링으로 **더 낮을 수도** 있습니다
- ❌ **"실패 허용은 전체 작업 기준"** → **리전별**입니다
- ❌ **"`cfn-lint`가 조직 보안 정책을 검사한다"** → `cfn-lint`는 **스키마·구문**입니다. 정책은 **Guard**
- ❌ **"`cfn-lint`는 모든 리전 스키마로 검사한다"** → 기본은 **`us-east-1`**입니다. `--regions`로 지정합니다
- ❌ **"린터와 Guard를 통과하면 배포가 보장된다"** → 둘 다 **로컬 검증**이고 공식이 한계를 따로 안내합니다
- ❌ **"태그 정책을 붙이면 기존 비준수 태그가 고쳐진다"** → 정책은 **태그될 때의 규칙**입니다. 비준수 발견·수정은 **Resource Groups**와 원래 서비스에서 합니다
- ❌ **"TagOption이 AWS 태그다"** → **아닙니다.** AWS 태그를 만드는 **템플릿**입니다
- ❌ **"태그에 담당자 이메일을 넣어 관리한다"** → 공식이 **PII·기밀 정보를 태그에 저장하지 말라**고 적습니다
- ❌ **"Firewall Manager 요금은 서비스 자체에 붙는다"** → **기반 서비스**(WAF·Config 등)에 붙습니다
- ❌ **"조직 내 계정과 RAM 공유도 초대가 필요하다"** → **조직 내 공유를 활성화한 뒤에는 필요 없습니다.** 초대는 조직 밖 계정입니다
- ❌ **"Service Catalog가 닫혔다"** → 닫힌 것은 **AppRegistry 기능**이고 본체는 정상입니다

## 🧪 자가 점검

**Q1.** 보안팀이 조직의 모든 계정에 CloudTrail 설정 스택을 배포했습니다. 그런데 **지난주 새로 만든 계정 둘**에는 스택이 없습니다. 팀은 "StackSets로 배포했다"고 합니다. 무엇이 빠졌습니까? (→ 1-1 권한 모델)

<details><summary>정답 보기</summary>

**셀프 관리형 권한으로 배포했거나, 서비스 관리형인데 자동 배포를 켜지 않았습니다.**

- 공식이 권한 모델의 차이에 **자동 배포**를 적습니다 — 서비스 관리형 권한을 쓰면 **"앞으로 조직에 추가하는 계정에 자동 배포를 켤 수 있습니다."** 셀프 관리형에는 그 기능이 없습니다
- 서비스 관리형은 **StackSets가 필요한 IAM 역할을 대신 만들고**, 관리자 계정은 **조직의 관리 계정 또는 위임된 관리자 계정**입니다
- 전환에 필요한 단계는 **StackSets의 신뢰 액세스 활성화**와 (쓰려면) **위임된 관리자 멤버 계정 등록**입니다
- ⚠️ 셀프 관리형을 유지해야 하는 경우도 있습니다 — **조직 밖 계정**에 배포해야 하면 셀프 관리형뿐입니다(IAM 역할을 만들 권한이 있는 어떤 계정에든 배포할 수 있습니다)

⚠️ 기존 계정에 소급 적용하려면 **스택 추가**로 대상 계정·리전을 더합니다. StackSet 업데이트의 세 가지 방식 중 하나입니다.
</details>

**Q2.** 플랫폼팀이 CI에 `cfn-lint`를 넣었습니다. 그런데 "S3 버킷은 반드시 암호화해야 한다"는 조직 규칙을 위반한 템플릿이 통과했습니다. 그리고 `ap-northeast-2`에서만 지원되지 않는 속성도 잡히지 않았습니다. 두 문제의 원인은? (→ 1-4 두 도구)

<details><summary>정답 보기</summary>

**도구 선택과 기본 리전, 둘 다 `cfn-lint`의 성질입니다.**

**① 조직 규칙 위반을 잡지 못한 것**

- `cfn-lint`가 보는 것은 **CloudFormation 리소스 공급자 스키마와 추가 규칙**입니다 — 잘못된 리소스 속성, 지원되지 않는 속성 값, **깨진 참조**, 흔한 모범 사례 문제
- "모든 S3 버킷은 암호화" 같은 **조직 정책·보안 모범 사례·거버넌스 요건**은 **Guard(`cfn-guard`)**의 몫입니다. Guard는 **필요하거나 금지된 구성을 Guard 언어 규칙으로 쓰고** JSON·YAML 데이터를 그 규칙에 비춰 검사합니다
- 공식 CloudFormation 모범 사례가 **Guard를 CI/CD 파이프라인에 넣어 배포 전에 자동 검증**하라고 권합니다

**② 리전별 속성이 잡히지 않은 것**

- ⚠️ `cfn-lint`는 **기본적으로 `us-east-1` 스키마**로 검사합니다. 다른 리전은 **`--regions`** 옵션으로 지정해야 합니다

⚠️ 그리고 둘 다 **로컬 검증**입니다 — 공식이 두 페이지에서 똑같이 "로컬 검증의 한계와 배포 전에 해야 할 일"을 따로 안내합니다. 통과가 배포 성공을 보장하지 않습니다.
</details>

**Q3.** 거버넌스팀이 "`CostCenter` 태그 없이는 리소스를 만들 수 없게" 하려고 태그 정책을 만들고 시행을 켰습니다. 그런데 태그 없이 만든 EC2 인스턴스가 그대로 생성됐습니다. 왜이고, 요건을 만족시키는 방법은? (→ 2-3 평가 대상)

<details><summary>정답 보기</summary>

**태그 정책은 태그되지 않은 리소스를 평가하지 않습니다.**

- 공식 문장 그대로입니다 — **"태그되지 않은 리소스나 태그 정책에 정의되지 않은 태그는 그 태그 정책의 준수 평가 대상이 아닙니다."**
- 태그 정책이 하는 일은 **"리소스가 태그될 때"**의 규칙입니다 — 키의 대소문자 처리와 허용 값. 시행을 켜면 **지정한 리소스 유형에 대한 비준수 태그 요청이 완료되지 못합니다.** 즉 **잘못된 태그**를 막을 뿐 **태그 없음**을 막지 않습니다
- 태그 정책은 범주상 **권한을 부여·거부하지 않는 선언적 정책**입니다(작업 6.1 §3-1)
- 요건을 만족시키려면 **`aws:RequestTag`와 `aws:TagKeys` 조건 키를 쓰는 SCP 또는 ID 기반 정책**으로 "태그 없는 생성 요청"을 거부해야 합니다

⚠️ 준수 확인은 **AWS Resource Groups**에서 합니다 — 태그 정책은 Organizations로 관리하고, 비준수 태그를 **찾고 고치는** 것은 Resource Groups와 원래 서비스의 몫입니다. 관리 계정에서 보면 조직 전 계정의 준수 정보를 볼 수 있습니다.

⚠️ 공식 권고 순서도 기억합니다 — **단일 계정에 단순한 정책을 붙여 효과를 이해한 뒤** 넓히고, **시행을 켜기 전에** 특히 효과를 확실히 확인합니다.
</details>

**Q4.** 보안팀이 Firewall Manager로 조직 전체에 WAF 웹 ACL 정책을 만들었습니다. 정책은 만들어졌는데 **준수 상태가 계속 비어 있고** 보호가 적용되지 않습니다. 무엇을 확인합니까? (→ 3-2 전제 조건)

<details><summary>정답 보기</summary>

**AWS Config가 활성화됐는지 먼저 확인합니다.**

- 공식 전제 조건이 **순서대로** 적혀 있고 세 번째가 **"Firewall Manager용으로 AWS Config 활성화"**입니다. Firewall Manager는 Config를 통해 리소스 구성을 보기 때문에 Config가 없으면 평가가 성립하지 않습니다
- 요금 구조가 같은 사실을 확인해 줍니다 — 공식 Note가 **"Firewall Manager에서 발생하는 요금은 AWS WAF와 AWS Config 같은 기반 서비스에 대한 것"**이라고 적습니다
- 전제 조건의 전체 순서는 ① **Organizations 가입·구성** ② **기본 관리자 계정 생성** ③ **AWS Config 활성화** ④ (3자 정책) **Marketplace 구독·설정** ⑤ (**Network Firewall·DNS Firewall 정책**) **AWS RAM 리소스 공유 활성화** ⑥ 기본 비활성 리전 설정입니다
- ⚠️ 정책 유형이 Network Firewall이나 DNS Firewall이라면 **RAM 리소스 공유 활성화**도 빠졌을 수 있습니다

⚠️ 관리자 구성도 함께 봅니다 — 그 정책 유형이 **그 관리자의 관리 범위에 포함**돼 있는지입니다. 관리 범위 조건은 **계정·OU / 리전 / 정책 유형** 셋이고, **기본 관리자만 3자 방화벽을 관리하고 전체 범위**를 갖습니다.
</details>

**Q5.** 네트워크팀이 중앙 VPC의 서브넷을 애플리케이션 계정과 공유했습니다. 리소스 기반 정책으로 공유했더니 상대 팀이 "VPC 콘솔에 아무것도 안 보인다"고 합니다. 원인과 해결은? (→ 4-1 RAM)

<details><summary>정답 보기</summary>

**리소스 기반 정책으로 공유한 리소스는 상대의 원래 서비스 콘솔·API에 나타나지 않습니다.**

- 공식이 그 차이를 명시합니다 — RAM으로 공유하면 **"사용자가 원래 AWS 서비스 콘솔과 API 작업에서 그 리소스를 자기 계정에 직접 있는 것처럼 봅니다."** 예로 **RAM으로 공유한 VPC 서브넷은 상대 계정의 VPC 콘솔과 VPC API 결과에 나타납니다**
- 반대로 **리소스 기반 정책을 붙여 공유한 리소스는 그렇게 보이지 않고**, 상대가 **ARN으로 찾아 명시적으로 참조**해야 합니다
- 해결은 **`PromoteResourceShareCreatedFromPolicy` API**(또는 동일한 CLI 명령)로 **완전한 RAM 관리형 리소스로 승격**하는 것입니다
- RAM이 추가로 주는 것 — **조직·OU 단위로 공유**(계정 ID 열거 불필요), **소유자가 리소스별 접근 주체 확인**, **조직 밖 계정과는 초대·수락 절차**(조직 내 공유 활성화 후에는 조직 내 계정에 초대 불필요)

⚠️ 범위 제약도 기억합니다 — 리소스 공유를 만들 때 **리전을 지정**하고 **하나의 공유에는 리전 리소스만** 담습니다. 그리고 **소비 계정의 역할·사용자에게 적용되는 정책과 권한이 공유된 리소스에도 적용**됩니다.
</details>

**Q6.** 아키텍처팀이 "애플리케이션 단위로 리소스를 묶어 거버넌스를 하자"며 Service Catalog AppRegistry 도입을 제안했습니다. 지금 새로 시작하는 조직입니다. 무엇을 확인해야 합니까? (→ 4-3 범위 메모)

<details><summary>정답 보기</summary>

**AppRegistry가 신규 고객에게 열려 있지 않다는 것을 먼저 확인해야 합니다.**

- 공식 사용자 안내서가 페이지 머리에 적습니다 — **`AWS Service Catalog AppRegistry`는 2026년 7월 30일부터 신규 고객에게 열려 있지 않습니다.** 그날 전에 가입했다면 쓸 수 있고 **기존 고객은 정상적으로 계속 사용**할 수 있습니다
- 즉 **지금 새로 시작하는 조직은 설정할 수 없습니다.** 제안 자체가 성립하지 않습니다
- ⚠️ **중요한 구분** — **AWS Service Catalog 본체는 닫히지 않았습니다.** 포트폴리오·제품·제약 조건·프로비저닝된 제품은 그대로 쓰이고, Control Tower의 **Account Factory도 Service Catalog의 프로비저닝된 제품 위에** 올라갑니다
- 대안은 본체의 모델입니다 — **포트폴리오로 묶고 제약 조건과 리소스 태그를 더해 IAM 사용자·그룹에 접근 권한**을 주고, **제품을 새 버전으로 업데이트하면 그 제품을 참조하는 모든 포트폴리오에 전파**되는 성질을 씁니다

⚠️ 시험 준비 관점 — AppRegistry는 **상태만** 알아 두고 공부 시간은 **본체의 공유·제약 조건 모델**과 **RAM과의 차이**에 씁니다. 참고로 AppRegistry는 **RAM을 통해 Organizations로 공유**되고 **Well-Architected Tool**과 통합됩니다.
</details>

### 📌 출처

1. Managing stacks across accounts and Regions with StackSets — `docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html` (2026-11-09 확인)
2. StackSets concepts — `docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-concepts.html` (2026-11-09 확인)
3. Validate templates with Guard — `docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-guard.html` (2026-11-09 확인)
4. Validate templates with cfn-lint — `docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-lint.html` (2026-11-09 확인)
5. CloudFormation best practices — `docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html` (2026-11-09 확인)
6. What is Tag Editor? — `docs.aws.amazon.com/tag-editor/latest/userguide/tagging.html` (2026-11-09 확인)
7. Tag policies — `docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_tag-policies.html` (2026-11-09 확인)
8. AWS Firewall Manager — `docs.aws.amazon.com/waf/latest/developerguide/fms-chapter.html` (2026-11-09 확인)
9. AWS Firewall Manager prerequisites — `docs.aws.amazon.com/waf/latest/developerguide/fms-prereq.html` (2026-11-09 확인)
10. Using AWS Firewall Manager administrators — `docs.aws.amazon.com/waf/latest/developerguide/fms-administrators.html` (2026-11-09 확인)
11. What is AWS Resource Access Manager? — `docs.aws.amazon.com/ram/latest/userguide/what-is.html` (2026-11-09 확인)
12. What Is Service Catalog? — `docs.aws.amazon.com/servicecatalog/latest/adminguide/introduction.html` (2026-11-09 확인)
13. What is AppRegistry? — `docs.aws.amazon.com/servicecatalog/latest/arguide/intro-app-registry.html` (2026-11-09 확인)
