---
examGuideTaskId: soa-t4-1
certCode: SOA-C03
domain: 4
domainName: 보안 및 규정 준수
domainWeightPct: 16
title: IAM·계정 보안 운영 — 정책·역할·MFA·자격증명 보고서
coversTasks:
  - "4.1"
sources:
  - title: IAM 정책과 권한 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
  - title: IAM 정책 평가 로직 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
  - title: 권한 경계 (Permissions Boundaries) (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html
  - title: IAM 역할 (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
  - title: 자격 증명 보고서 받기 (Credential Report) (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_getting-report.html
  - title: IAM Access Analyzer (공식)
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html
  - title: 서비스 제어 정책 (SCP) (공식)
    url: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
lastVerified: 2026-06-09
---

# IAM·계정 보안 운영 — 정책·역할·MFA·자격증명 보고서

> **커버하는 공식 Task** — SOA-C03 · 도메인 4 「보안 및 규정 준수」(16%) · **Task 4.1 보안 및 규정 준수 도구와 정책 구현 및 관리** (`soa-t4-1`)
> 이 문서는 IAM 정책·역할·MFA·자격증명 점검 등 **계정 보안 운영**에 집중합니다. Config/Security Hub/GuardDuty 등 거버넌스 도구는 `soa-t4-2`, 데이터·인프라 암호화는 `soa-t4-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 운영할 수 있어야 합니다.

- [ ] **정책 유형 구분** — 자격증명 기반(관리형/인라인), 리소스 기반, 권한 경계, SCP를 구분하고 권한 부여 여부를 안다
- [ ] **정책 평가 로직** — 명시적 Deny가 항상 우선임을 이해하고, 여러 정책 레이어의 교집합을 추론할 수 있다
- [ ] **역할 운영** — EC2 인스턴스 프로파일·교차 계정 AssumeRole·서비스 역할을 구성할 수 있다
- [ ] **MFA 적용** — 루트·IAM 사용자에 MFA를 강제하고 조건 키로 정책에 반영할 수 있다
- [ ] **자격증명 점검** — 자격증명 보고서·Access Analyzer·마지막 액세스 정보로 미사용 권한을 찾아낼 수 있다
- [ ] **루트 사용자 보호** — 루트 사용 금지·MFA·액세스 키 미발급 모범 사례를 적용할 수 있다
- [ ] **SCP의 역할** — SCP가 권한 상한선(가드레일)일 뿐 권한을 부여하지 않음을 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 4(16%)의 핵심은 "보안 도구와 정책을 **운영**하는 것"입니다. SOA는 IAM을 설계 관점이 아니라 **운영자 관점**(미사용 자격증명 회수, 권한 점검, MFA 강제)에서 묻습니다.
- 시험은 단순 정의가 아니라 **평가 결과**를 묻습니다. "SCP로 `s3:*`를 Deny했는데 IAM 정책에서 Allow하면 접근되나?" 같은 다층 정책의 교집합·우선순위가 반복 출제됩니다.
- 운영 자격증인 SOA는 **지속적 점검 절차**를 강조합니다. 자격증명 보고서로 미사용 키를 찾고, 마지막 액세스 정보로 과도한 권한을 회수하는 절차를 직접 수행하도록 요구합니다.

---

## 📖 핵심 개념

### 1) 정책 유형 — 부여하는 정책 vs 한도만 정하는 정책

> 공식 정의: **"정책(Policy)은 권한을 정의하는 객체로, 자격증명이나 리소스에 연결되어 권한을 정의한다."** 핵심은 "권한을 **부여**하는 정책"과 "권한의 **상한선**만 정하는 정책"의 구분입니다.

| 정책 유형 | 부착 대상 | 권한 부여 | 비고 |
|---|---|---|---|
| **자격증명 기반 — 관리형(Managed)** | 사용자·그룹·역할 | 부여 O | AWS 관리형 / 고객 관리형. 재사용·버전 관리 가능 |
| **자격증명 기반 — 인라인(Inline)** | 사용자·역할 | 부여 O | 단일 대상에 1:1 임베드. 재사용 불가 |
| **리소스 기반(Resource-based)** | 리소스(S3 버킷, KMS 키 등) | 부여 O | 교차 계정 접근에 핵심. Principal 명시 |
| **권한 경계(Permissions Boundary)** | 사용자·역할 | 부여 X (상한선) | 위임 시 과도 권한 방지 |
| **SCP (서비스 제어 정책)** | Organizations 계정·OU | 부여 X (상한선) | 다계정 가드레일 |
| **세션 정책(Session policy)** | AssumeRole 임시 세션 | 부여 X (교집합) | 임시 세션을 추가 제한 |

> **관리형 vs 인라인 운영 팁**: 관리형 정책은 한 곳에서 수정하면 연결된 모든 대상에 반영되어 **운영·감사에 유리**합니다. 인라인은 대상과 생명주기를 같이하므로(대상 삭제 시 함께 삭제) "이 역할에만 절대 새지 않아야 하는 권한"에 씁니다.

### 2) 정책 평가 로직 — 명시적 Deny가 항상 이긴다 (★ 단골 출제)

```
1. 기본값은 암묵적 Deny (아무 Allow도 없으면 거부)
2. 적용되는 모든 정책을 평가:
   - 명시적 Deny가 하나라도 있으면 → 즉시 거부 (최종)
   - 명시적 Allow가 있으면 → 허용
3. 명시적 Allow가 없으면 → 암묵적 Deny로 거부
```

> **명시적 Deny > 명시적 Allow > 암묵적 Deny.** 이 우선순위는 어느 레이어(자격증명 정책·리소스 정책·권한 경계·SCP·세션 정책)의 Deny에도 동일하게 적용됩니다.

**여러 한도(상한선) 정책이 함께 있을 때 — 교집합으로 좁혀짐:**

| 레이어 | 작동 |
|---|---|
| **SCP** | 계정에서 *허용 가능한 최대치*. SCP에 없으면 그 계정에선 아예 불가 |
| **권한 경계** | 해당 사용자·역할이 *가질 수 있는 최대치* |
| **자격증명 기반 정책** | 실제로 *부여*되는 권한 |

> 최종 허용 = **(SCP 허용) ∩ (권한 경계 허용) ∩ (자격증명 정책 Allow)** 에서, 어느 레이어든 **명시적 Deny가 있으면 무조건 거부**. 즉 SCP가 `s3:*`를 막으면 IAM 정책에서 아무리 Allow해도 S3 접근은 불가합니다. 반대로 SCP가 Allow여도 IAM 정책에 Allow가 없으면 역시 불가 — SCP는 **부여하지 않습니다.**

### 3) 권한 경계 (Permissions Boundary)

> 공식: **"권한 경계는 자격증명 기반 정책이 IAM 엔터티(사용자·역할)에 부여할 수 있는 최대 권한을 설정하는 고급 기능."**

- **권한 위임 시나리오의 핵심**입니다. 예: 개발자에게 "IAM 역할을 만들 수 있는 권한"을 주되, 그들이 만드는 역할에 반드시 특정 권한 경계를 붙이도록 강제하면, 개발자가 관리자급 역할을 스스로 만드는 권한 상승(privilege escalation)을 막습니다.
- 권한 경계는 권한을 **부여하지 않습니다.** 자격증명 정책이 Allow하고 + 권한 경계도 그 권한을 허용 범위에 포함해야 실제로 작동합니다(교집합).

### 4) IAM 역할 운영 — 인스턴스 프로파일·교차 계정·서비스 역할

역할에는 항상 두 정책이 붙습니다: **신뢰 정책**(누가 수임 가능한가)과 **권한 정책**(무엇을 할 수 있나).

| 운영 패턴 | 구성 |
|---|---|
| **EC2 인스턴스 프로파일** | 역할을 인스턴스 프로파일로 EC2에 부착 → SDK가 IMDS에서 임시 자격증명 자동 획득(키 하드코딩 금지) |
| **교차 계정 AssumeRole** | 대상 계정에 역할 생성(신뢰 정책에 소스 계정 지정) + 소스 계정 주체에 `sts:AssumeRole` 허용 |
| **서비스 역할(Service Role)** | Lambda 실행 역할, Config·SSM 등 AWS 서비스가 사용자 대신 작업하도록 수임하는 역할 |

> 교차 계정에서 **외부 ID(External ID)**: 서드파티가 내 계정 역할을 수임할 때 신뢰 정책에 `sts:ExternalId` 조건을 추가하면 "혼동된 대리인(confused deputy)" 공격을 방지합니다.

```bash
# 교차 계정 역할 수임 (AWS CLI)
aws sts assume-role \
  --role-arn arn:aws:iam::222222222222:role/CrossAccountRead \
  --role-session-name ops-session \
  --external-id MyUniqueId
```

### 5) MFA — 루트·IAM 사용자

| 대상 | 권장 사항 |
|---|---|
| **루트 사용자** | MFA **필수**. 하드웨어/가상 MFA 등록. 액세스 키는 만들지 않음 |
| **IAM 사용자** | 콘솔 로그인·민감 작업에 MFA. 정책 조건으로 강제 가능 |

```json
{
  "Effect": "Deny",
  "NotAction": ["iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "sts:GetSessionToken"],
  "Resource": "*",
  "Condition": { "BoolIfExists": { "aws:MultiFactorAuthPresent": "false" } }
}
```

> 위 정책은 "MFA로 인증하지 않았으면 MFA 등록 외 모든 작업을 Deny"합니다. `aws:MultiFactorAuthPresent` 조건 키로 MFA 사용 여부를 정책에 직접 반영합니다.

### 6) 자격증명 점검 도구 — 보고서·Access Analyzer·마지막 액세스 정보

| 도구 | 무엇을 알려주나 |
|---|---|
| **자격증명 보고서(Credential Report)** | 계정 내 **모든 IAM 사용자**의 비밀번호·액세스 키 상태, 마지막 사용 시각, MFA 활성화 여부를 **CSV로 일괄** 출력. 미사용 키·MFA 미설정 사용자 색출에 사용 |
| **마지막 액세스 정보(Last Accessed)** | 특정 사용자·역할·그룹·정책이 **어떤 서비스에 마지막으로 접근**했는지 → **미사용 권한 회수**에 사용 |
| **IAM Access Analyzer** | 리소스가 **외부 계정/공개**에 노출됐는지 탐지(S3·IAM 역할·KMS·SQS 등). 사용 내역 기반으로 **최소 권한 정책 생성**도 지원 |

```bash
# 자격증명 보고서 생성 후 다운로드
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d
```

> **운영 절차(최소 권한 유지)**: ① 자격증명 보고서로 90일 이상 미사용 키·MFA 미설정 사용자 식별 → ② 마지막 액세스 정보로 정책의 미사용 서비스 권한 제거 → ③ Access Analyzer로 외부 노출 리소스 점검 → 정기 반복.

### 7) 루트 사용자 보호 & SCP 개요

**루트 사용자 보호 (모범 사례 첫 항목):**

- MFA 활성화, **액세스 키 발급 금지**, 일상 작업에 사용 금지(별도 IAM 관리자/Identity Center 사용).
- 루트만 가능한 작업(계정 닫기, 결제 설정 일부, 특정 S3/SCP 우회 등)에만 제한적으로 사용.

**SCP (Organizations 가드레일):**

- SCP는 계정·OU에 적용되는 **권한 상한선**입니다. **권한을 부여하지 않고 한도만 제한**합니다.
- 해당 계정의 **루트 사용자를 포함한 모든 IAM 주체**에 적용됩니다(단, Organizations **관리 계정**의 주체에는 SCP가 적용되지 않음 — 그래서 워크로드를 관리 계정에 두지 않음).
- 예: "특정 OU는 승인된 리전만 사용", "CloudTrail 비활성화 금지" 같은 조직 차원 가드레일.

---

## ✍️ 시험 포인트

- **명시적 Deny는 항상 이긴다.** 어느 정책 레이어(IAM·리소스·권한 경계·SCP·세션)에서든 Deny가 있으면 Allow를 덮어쓴다.
- **SCP·권한 경계는 권한을 부여하지 않는다** — 상한선만 정한다. 실제 부여는 자격증명/리소스 기반 정책이 한다.
- **최종 허용 = 모든 한도의 교집합 ∩ 명시적 Allow − 모든 Deny.** SCP에 없으면 IAM Allow도 소용없다.
- **관리형 vs 인라인**: 관리형 = 재사용·중앙 관리, 인라인 = 대상과 1:1 생명주기.
- **EC2 → AWS 접근은 항상 인스턴스 프로파일(역할).** 액세스 키 하드코딩 보기는 오답.
- **교차 계정** = 대상 계정에 역할 + 신뢰 정책 + 소스의 `sts:AssumeRole`. 서드파티엔 **External ID**.
- **자격증명 보고서** = 전체 사용자 자격증명 상태 CSV(미사용 키·MFA 점검). **마지막 액세스 정보** = 미사용 권한 회수.
- **Access Analyzer** = 외부/공개 노출 탐지 + 최소 권한 정책 생성.
- **루트**: MFA 필수, 액세스 키 금지, 일상 사용 금지.
- **SCP는 루트 사용자에도 적용**되나, **관리 계정**에는 적용되지 않는다.

---

## ⚠️ 흔한 함정

1. **"SCP에서 Allow하면 사용자가 그 작업을 할 수 있다."** → 아닙니다. SCP는 **상한선**일 뿐입니다. 실제로 작업하려면 자격증명 기반 정책에 별도의 Allow가 있어야 합니다. SCP Allow + IAM Allow 둘 다 있어야 합니다.

2. **"IAM 정책에서 Allow했으니 무조건 접근된다."** → 어느 레이어든 **명시적 Deny**가 있으면 거부됩니다. 또 SCP·권한 경계가 그 권한을 한도에 포함하지 않으면 역시 거부됩니다.

3. **"권한 경계와 SCP는 같은 것이다."** → 적용 범위가 다릅니다. 권한 경계는 **개별 사용자·역할**, SCP는 **Organizations의 계정·OU 전체**에 적용됩니다.

4. **"루트 사용자에 액세스 키를 만들어 자동화에 쓴다."** → 절대 금지. 루트 액세스 키는 발급하지 않고, 자동화는 역할/Identity Center로 처리합니다. 루트엔 MFA를 반드시 켭니다.

5. **"마지막 액세스 정보와 자격증명 보고서는 같다."** → 다릅니다. 자격증명 보고서는 **자격증명(키·MFA·비밀번호) 상태**를, 마지막 액세스 정보는 **어떤 서비스에 언제 접근했는지(권한 사용 내역)**를 보여줍니다. 미사용 권한 회수엔 후자를 씁니다.

6. **"Access Analyzer가 EC2 취약점을 스캔한다."** → 아닙니다. Access Analyzer는 **리소스가 외부에 노출됐는지(액세스 경로)**를 분석합니다. 소프트웨어 취약점(CVE)은 Inspector의 역할입니다(`soa-t4-2` 참조).

7. **"교차 계정은 한쪽 정책만 있으면 된다."** → 대상 계정의 역할(신뢰+권한 정책)과 소스 계정 주체의 `sts:AssumeRole` 허용이 **양쪽 모두** 필요합니다.

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** Organizations에서 한 OU에 "S3 삭제 금지" SCP를 붙였습니다. 그런데 해당 계정의 한 IAM 역할은 자격증명 정책에 `s3:*` Allow가 있습니다. 이 역할로 S3 객체를 삭제할 수 있나요?

<details><summary>정답 보기</summary>

**삭제할 수 없습니다.** SCP가 `s3:DeleteObject`를 Deny(또는 허용 목록에서 제외)하면, IAM 정책에서 아무리 `s3:*`를 Allow해도 최종 결과는 거부입니다. 최종 허용은 모든 레이어의 교집합이며, 어느 레이어든 Deny가 있으면 무조건 거부됩니다. SCP는 계정의 루트 사용자를 포함한 모든 주체에 적용됩니다.
</details>

**Q2.** 보안팀이 "지난 90일간 사용되지 않은 액세스 키와 MFA가 설정되지 않은 IAM 사용자"를 한 번에 찾아내려 합니다. 어떤 기능을 쓰나요?

<details><summary>정답 보기</summary>

**자격증명 보고서(Credential Report)**입니다. `generate-credential-report` 후 `get-credential-report`로 CSV를 받으면 모든 IAM 사용자의 비밀번호·액세스 키 상태, 마지막 사용 시각, MFA 활성화 여부가 일괄로 나옵니다. 이를 기준으로 미사용 키를 비활성화/삭제하고 MFA 미설정 사용자에 MFA를 강제합니다.
</details>

**Q3.** 개발자에게 IAM 역할을 생성할 권한을 주되, 그들이 만든 역할이 관리자급 권한을 갖지 못하게 막고 싶습니다. 어떻게 하나요?

<details><summary>정답 보기</summary>

**권한 경계(Permissions Boundary)**를 사용합니다. 개발자가 역할을 만들 때 반드시 지정된 권한 경계를 붙이도록 IAM 정책에 조건(`iam:PermissionsBoundary`)을 걸면, 새로 만들어진 역할의 최대 권한이 그 경계로 제한되어 권한 상승을 막을 수 있습니다. 권한 경계는 권한을 부여하지 않고 상한선만 정합니다.
</details>

**Q4.** 어떤 IAM 역할의 정책에 `s3:*`, `ec2:*` 등 광범위한 권한이 붙어 있는데, 실제로 어떤 서비스를 쓰는지 몰라 최소 권한으로 줄이려 합니다. 어떤 정보를 활용하나요?

<details><summary>정답 보기</summary>

**마지막 액세스 정보(Last Accessed Information)**를 사용합니다. 해당 역할이 실제로 접근한 서비스와 마지막 접근 시각을 보고, 한 번도 쓰지 않은 서비스 권한을 정책에서 제거합니다. 추가로 **IAM Access Analyzer의 정책 생성** 기능으로 CloudTrail 활동 기반의 최소 권한 정책 초안을 만들 수 있습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. IAM 정책과 권한 — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
2. IAM 정책 평가 로직(명시적 Deny 우선) — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html
3. 권한 경계(Permissions Boundaries) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html
4. IAM 역할 — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html
5. 자격 증명 보고서 받기 — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_getting-report.html
6. IAM Access Analyzer — https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html
7. 서비스 제어 정책(SCP) — https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html
