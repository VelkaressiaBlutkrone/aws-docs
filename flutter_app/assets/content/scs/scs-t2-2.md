---
examGuideTaskId: scs-t2-2
certCode: SCS-C03
domain: 2
domainName: 인시던트 대응
domainWeightPct: 14
title: 보안 이벤트에 대응 (아티팩트 캡처·검색과 상관·범위 평가·격리와 복구·근본 원인)
coversTasks:
  - "2.2"
sources:
  - title: Forensic memory and disk acquisition service
    url: https://docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/forensic-memory-and-disk-acquisition-service.html
  - title: Disk forensics acquisition workflow
    url: https://docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/disk-forensics-acquisition-workflow.html
  - title: Architecture overview — Automated Forensics Orchestrator for Amazon EC2 and EKS
    url: https://docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/architecture-overview.html
  - title: What is Amazon Detective?
    url: https://docs.aws.amazon.com/detective/latest/userguide/what-is-detective.html
  - title: Exposure findings in Security Hub
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/exposure-findings.html
  - title: Introduction to AWS Security Hub CSPM
    url: https://docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html
  - title: What is Amazon GuardDuty?
    url: https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html
  - title: Analyzing log data with CloudWatch Logs Insights
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html
  - title: What is Amazon Security Lake?
    url: https://docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html
  - title: What is Amazon Athena? — S3 데이터를 표준 SQL로 조회
    url: https://docs.aws.amazon.com/athena/latest/ug/what-is.html
lastVerified: 2026-11-08
---

# 보안 이벤트에 대응 (아티팩트 캡처·검색과 상관·범위 평가·격리와 복구·근본 원인)

> **커버하는 공식 Task** — SCS-C03 · 도메인 2 「인시던트 대응」(14%) · **작업 2.2 보안 이벤트에 대응** (`scs-t2-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(2.2.1~2.2.5)를 모두 덮습니다. 작업 2.1이 **사고 전**이라면 이 작업은 **사고 중**입니다. 다섯 기술이 사고 대응의 순서와 거의 그대로 겹칩니다 — **캡처 → 검색·상관 → 범위 평가 → 격리·복구 → 근본 원인.**

> ⚠️ **`기술 2.2.3`은 C03에서 신설된 기술입니다**("AWS 보안 서비스의 조사 결과를 확인하여 이벤트의 범위와 영향 평가"). 그리고 그 자리에 쓰는 **「노출 조사 결과」**는 공식 문서가 **신 `Security Hub`**(OCSF)에만 두고 있어, 「Security Hub」라는 이름을 **CSPM과 섞어 쓰면 문항을 가를 수 없습니다.** 3절이 그 경계입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 휘발성 증거와 비휘발성 증거의 **수집 순서**를 설명한다
- [ ] 메모리 수집이 **어떤 수단으로** 실행되고 덤프가 **어디에 저장되는지** 안다
- [ ] 디스크 증거를 **포렌식 계정으로 옮기는 두 단계 복사**와 그 이유를 설명한다
- [ ] 로그를 **검색·상관**할 수단을 질문의 모양에 따라 고른다
- [ ] 조사 결과로 **범위와 영향**을 평가할 때 CSPM·GuardDuty·신 Security Hub의 역할을 가른다
- [ ] 격리를 **네트워크·자격 증명** 두 축으로 설계한다
- [ ] Detective가 **탐지하지 않는다**는 것과 **1년 과거 데이터**의 의미를 안다
- [ ] 복구에서 **백업 복원 전에 확인할 것**을 말한다

## 🎯 왜 중요한가

사고 대응 문항은 **순서를 틀리면 증거가 사라지는** 구조로 나옵니다. "인스턴스를 종료한다", "보안 그룹을 바꾼다", "스냅샷을 뜬다"를 어떤 순서로 하느냐가 답입니다.

그리고 Specialty 시험은 **"그 조사 결과로는 범위를 알 수 없다"**를 자주 묻습니다. GuardDuty 조사 결과 하나는 **한 리소스의 한 신호**이고, 그것이 **어디까지 번졌는지**는 다른 수단이 답합니다. 3절과 5절이 그 구분입니다.

## ⚡ 시험 직전 요약

- 증거 수집 순서는 **휘발성이 높은 것부터** — 메모리 덤프를 **인스턴스를 멈추기 전에** 확보합니다
- 메모리 수집은 **SSM Run Command로 SSM 문서를 침해 인스턴스에서 실행**하고 덤프를 **포렌식 계정의 S3**에 저장합니다
- ⚠️ 덤프에는 **OS·커널 메타데이터 태그**가 붙어 하위 분석 흐름을 돕습니다
- ⚠️⚠️ **격리 플래그가 `true`면 메모리 수집 결과와 무관하게 격리가 수행됩니다** — 수집 중 오류가 나도 격리는 됩니다
- 격리는 **인바운드·아웃바운드가 없는 보안 그룹을 부착하고 기존 보안 그룹을 분리**하는 방식입니다
- 디스크 증거는 **스냅샷 → 공유 KMS 키로 복사 → 포렌식 계정과 공유 → 포렌식 계정에서 포렌식 KMS 키로 다시 복사**입니다
- ⚠️ 마지막 재복사의 이유는 **원본 계정이 침해되거나 공유 스냅샷이 삭제되는 경우에 대비**하기 위해서입니다
- **GuardDuty는 공격 시퀀스**를, **신 Security Hub는 노출 조사 결과(공격 경로·폭발 반경)**를, **Detective는 근본 원인 맥락**을 줍니다
- ⚠️ **Detective는 탐지하지 않습니다** — 최대 **1년**의 과거 데이터로 맥락을 만듭니다
- ⚠️ **Security Hub CSPM은 소급 적용되지 않으므로** 사고 이전 기록은 원시 로그에서 찾습니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **휘발성 증거** | 전원·프로세스가 멈추면 사라지는 증거. **메모리(RAM)**가 대표입니다 |
| **아티팩트** | 조사에 쓰는 보존 가능한 산출물(메모리 덤프·스냅샷·로그 사본) |
| **관리 연속성(chain of custody)** | 증거가 수집·보관·분석 전 과정에서 변조되지 않았음을 보일 수 있는 상태 |
| **격리(isolation)** | 리소스를 네트워크·권한에서 떼어 **더 번지지 않게** 하는 것. 삭제가 아닙니다 |
| **공격 시퀀스** | 개별로는 위협이 아닌 이벤트들이 **의심스러운 순서**로 관측된 묶음. GuardDuty가 식별합니다 |
| **노출 조사 결과** | 여러 신호를 **상관**해 실제 위험과 **공격 경로·폭발 반경**을 드러낸 조사 결과. 신 Security Hub가 만듭니다 |
| **행동 그래프** | Detective가 로그를 모아 만든 관계 그래프. 조사 결과 그룹의 바탕입니다 |

## 📖 핵심 개념

### 1) 포렌식 아티팩트를 캡처하고 저장한다 (기술 2.2.1) {#capture}

#### 1-1. 순서가 먼저다

**휘발성이 높은 것부터** 모읍니다. 메모리는 인스턴스를 멈추거나 재부팅하면 사라지므로 **가장 먼저**이고, 디스크 스냅샷은 그 뒤입니다. 공식 포렌식 흐름이 **메모리 수집 → 격리** 순서인 것이 이 원칙의 적용입니다(작업 2.1 §4-1).

#### 1-2. 메모리 수집 — 어떤 수단으로 어디에

공식 구현 문서가 단계를 그대로 적습니다.

1. 트리아지 Step Function이 **메모리 수집 흐름**을 시작합니다
2. 메모리 수집 Lambda가 ⚠️ **SSM 명령으로 침해 인스턴스에서 SSM 문서를 실행**합니다
3. 그 Lambda는 **애플리케이션 계정의 역할을 수임**하고, 실행할 SSM 문서와 **덤프를 S3로 복사할 자격 증명**을 함께 넘깁니다
4. **Systems Manager가 Run Command로 메모리 수집 문서를 실행**합니다
5. ⚠️ **메모리 덤프는 포렌식 계정의 S3 버킷에 저장**되고, **기반 OS와 커널을 나타내는 메타데이터 태그**가 붙어 하위 **메모리 분석 흐름**을 돕습니다
6. 확인 Lambda가 Run Command 완료를 기다립니다 — 상태가 `Pending`·`Delayed`·`In Progress`면 ⚠️ **120초 대기** 후 다시 봅니다
7. `Success`면 **격리가 필요한지** 확인합니다

⚠️⚠️ **격리 조건이 비자명합니다.** 격리 플래그가 `true`면 Lambda가 애플리케이션 계정 역할을 수임해 **인바운드·아웃바운드가 없는 보안 그룹을 부착하고 기존 보안 그룹을 분리**합니다. 플래그는 **트리아지 단계에서 보안 이벤트 유형에 따라** `true`가 됩니다. 그리고 공식이 못박습니다 — **"격리 플래그가 `true`면 메모리 수집 결과와 무관하게 격리가 수행된다."** 즉 **수집이 실패해도 격리는 됩니다**(수집 과정에 오류가 나면 EC2 인스턴스 또는 EKS 클러스터 격리가 플래그에 따라 수행됩니다).

#### 1-3. 디스크 수집 — 두 번 복사하는 이유

1. 트리아지 Step Function이 **디스크 수집 흐름**을 시작합니다
2. 스냅샷 수행 Lambda가 **애플리케이션 계정 역할을 수임해 인스턴스 스냅샷 API를 호출**합니다
3. 확인 Lambda가 완료를 봅니다 — `Pending`·`In Progress`면 ⚠️ **120초 대기**
4. ⚠️ **포렌식 계정과 공유된 KMS 키로 침해 인스턴스 스냅샷을 복사**합니다
5. 복사한 **EBS 스냅샷을 포렌식 계정과 공유**합니다
6. ⚠️⚠️ **포렌식 계정에서 그 공유 스냅샷을 「포렌식 KMS 키」로 다시 복사해 로컬 사본을 둡니다.** 공식이 그 이유를 적습니다 — **AWS 계정이 침해되거나 공유 스냅샷이 보안팀에 의해 삭제되는 경우에도 포렌식을 수행할 수 있게** 하기 위해서입니다
7. 복사가 끝나면 포렌식 유형 `DISK`로 **조사 흐름**이 시작됩니다

⚠️ **이 두 단계 복사는 「백업 중복」이 아니라 「증거 독립성」입니다.** 문항이 "원본 계정이 완전히 침해된 상황에서도 증거를 보존하려면?"을 묻는다면 답이 이것입니다.

### 2) 보안 이벤트 로그를 검색하고 상관한다 (기술 2.2.2) {#search}

질문의 **모양**으로 수단이 갈립니다(작업 1.2 §4의 적용입니다).

| 질문의 모양 | 수단 | 왜 |
|---|---|---|
| "지금 이 로그 그룹에서 무슨 일이" | **CloudWatch Logs Insights** | 대상이 **CloudWatch Logs의 로그 그룹**입니다 |
| "석 달치 S3 로그에서 패턴을" | **Athena** | S3의 대량·장기 보존 데이터를 SQL로 봅니다 |
| "여러 벤더 로그를 한 스키마로" | **Security Lake**(OCSF) | 이질적 형식을 **정규화**합니다 |
| "정규화된 조사 결과를 한곳에서" | **Security Hub CSPM**(ASFF) | ⚠️ 단 **소급 적용되지 않습니다** |

⚠️ **로그 그룹을 넘나드는 상관**이 필요하면 Logs Insights의 **OpenSearch SQL**이 **`JOIN`과 하위 쿼리**를 지원합니다(동시 실행 한도는 **15개**이고 Logs Insights QL은 **100개**입니다). **`filterIndex`와 비교 쿼리는 QL 전용**입니다.

⚠️ **필드 자동 발견**이 CloudTrail·VPC·Lambda·Route 53 로그와 JSON 로그에 적용되므로, 사고 조사에서 **필드 이름을 먼저 확인**하는 데 쓸 수 있습니다. 그리고 **쿼리 결과를 KMS로 암호화**할 수 있어 조사 산출물 보호에 맞습니다.

### 3) 조사 결과로 범위와 영향을 평가한다 (기술 2.2.3 — 신규) {#scope}

⚠️⚠️ **이 기술의 핵심은 「조사 결과 하나로는 범위를 모른다」입니다.** 세 수단이 서로 다른 층에서 범위를 말합니다.

| 수단 | 무엇을 말해 주나 | 한계 |
|---|---|---|
| **GuardDuty 조사 결과** | **무슨 위협이 관측됐나**(위협 유형·대상 리소스) | 한 신호다 |
| **GuardDuty 공격 시퀀스**(Extended Threat Detection) | 개별로는 위협이 아닌 이벤트들이 **의심스러운 순서**로 관측된 묶음 | ⚠️ **한 AWS 계정 안**의 다단계 공격이다 |
| **신 `Security Hub` 노출 조사 결과** | **Security Hub CSPM · Inspector · GuardDuty · Macie 신호를 상관**해 **공격 경로와 폭발 반경**을 시각화 | 상관할 신호가 있어야 한다 |
| **`Security Hub CSPM`** | 표준 대조 결과와 **보안 점수**로 **자세의 범위** | ⚠️ **소급 적용되지 않는다** |

**노출 조사 결과의 구성 요소**가 「영향 평가」에 직접 쓰입니다 — 제목·설명, **심각도**(Critical·High·Medium·Low), **기여 특성**(직접 취약성 · 구성 문제 · 네트워크 노출 조건 · 리소스 권한 설정 · **리소스 중요도**), **공격 경로와 폭발 반경 시각화**, 그리고 **구체적 개선 지침**입니다.

⚠️ 공식이 적는 생성 방식도 범위 평가의 근거입니다 — **네트워크 도달 가능성 평가**(인터넷 노출과 내부 경로를 함께 보고 보안 그룹·네트워크 ACL 설정을 분석), **리소스 구성과 관계 평가**, **IAM 권한·역할·리소스 접근 패턴 분석**.

⚠️ 제약 둘 — **리소스 하나는 최대 하나의 노출 조사 결과에서만 주 리소스**가 되고, **기여 특성이 없거나 부족하면 조사 결과가 만들어지지 않습니다.** "노출 조사 결과가 없으니 안전하다"는 추론은 성립하지 않습니다.

⚠️ **Extended Threat Detection은 추가 비용 없이 자동으로** 켜지지만, **S3 리소스까지 범위를 넓히려면 S3 Protection을 켜라**고 공식이 권합니다 — 「범위 평가」가 **켜 둔 보호 플랜의 범위**에 묶입니다.

### 4) 영향을 평가하고 격리·복구한다 (기술 2.2.4) {#contain}

공식 예시는 **네트워크 접근 제한 적용**과 **백업 복원**입니다.

#### 4-1. 격리는 두 축이다

| 축 | 수단 | 주의 |
|---|---|---|
| **네트워크** | ⚠️ **인바운드·아웃바운드가 없는 보안 그룹을 부착하고 기존 보안 그룹을 분리** | 공식 포렌식 흐름이 쓰는 방식입니다 |
| **자격 증명·권한** | 인스턴스 프로파일·역할 권한을 걷어 **그 리소스가 쓰던 권한을 무력화** | 네트워크만 끊으면 **이미 발급된 임시 자격 증명**은 다른 곳에서 계속 쓸 수 있습니다 |

⚠️⚠️ **두 축을 함께 봐야 합니다.** "보안 그룹으로 격리했다"는 보기만 있고 자격 증명을 다루지 않는 설계는 불완전합니다 — 침해된 역할의 임시 자격 증명은 인스턴스 밖에서도 유효합니다.

⚠️ 그리고 **격리는 삭제가 아닙니다.** 종료하면 메모리 증거가 사라지고(§1-1) 디스크도 설정에 따라 사라질 수 있습니다. 공식 흐름의 순서는 **수집 → 격리**이고, 수집이 실패하더라도 **플래그가 `true`면 격리는 수행**됩니다.

#### 4-2. 복구 — 백업을 되돌리기 전에

백업 복원은 공식 예시이지만 **되돌리기 전에 확인할 것**이 있습니다.

1. **침해 시점**을 먼저 확정합니다 — 그 이전 시점의 백업이어야 합니다. 시점 확정이 §5(근본 원인)의 일이고, 여기서 Detective의 **최대 1년 과거 데이터**가 쓰입니다
2. **백업 자체가 침해되지 않았는지** 봅니다 — 공격자가 백업·스냅샷을 먼저 손댔을 수 있습니다
3. **침해 경로를 막았는지** 확인합니다 — 같은 취약성·같은 자격 증명이 남아 있으면 복원 직후 재침해됩니다

⚠️ 그래서 문항이 "서비스를 빨리 복구하라"로 시작해도 **먼저 범위를 평가하고 경로를 막는 보기**가 답인 경우가 많습니다.

### 5) 근본 원인 분석을 지원하는 기능 (기술 2.2.5) {#root-cause}

공식 예시는 **Amazon Detective**입니다.

⚠️⚠️ **Detective는 탐지하지 않습니다.** 조사 결과나 의심스러운 활동의 **근본 원인을 분석·식별**하도록 로그를 자동 수집해 **ML·통계 분석·그래프 이론**으로 시각화를 만듭니다. 그리고 **최대 1년의 과거 이벤트 데이터**에 접근할 수 있으며, 변화를 **GuardDuty 조사 결과에 연결**합니다.

| 기능 | 하는 일 |
|---|---|
| **조사 결과 그룹**(finding groups) | 여러 활동을 한 보안 이벤트로 묶어 봅니다. **고심각도 GuardDuty 조사 결과의 근본 원인**을 **행동 그래프**에서 추출하고 상호작용을 시각화합니다 |
| **Detective Investigation** | **IAM 사용자·역할**을 **침해 지표(IOC)**로 조사합니다. `StartInvestigation` API·CLI로도 실행됩니다 |
| **Security Lake 통합** | Security Lake가 보관한 **원시 로그를 쿼리**할 수 있습니다 |
| **VPC 흐름 볼륨 조사** | EC2 인스턴스별로 흐름 로그를 집계해 **IP 상호작용**을 보여 주고, Kubernetes 파드는 **할당 IP의 전체 바이트 볼륨**을 봅니다 |

⚠️ **Security Lake 통합의 범위를 넓게 말하지 않습니다.** 공식은 Security Lake가 기본 지원하는 소스로 **CloudTrail 관리 이벤트 1.0 이상 · VPC 흐름 로그 1.0 이상 · EKS 감사 로그 2.0**을 들지만, 통합 후 Detective가 **실제로 당겨오는 원시 로그는 "CloudTrail 관리 이벤트와 VPC 흐름 로그 관련"**이라고 적습니다. **셋을 모두 당겨온다고 단정하지 않습니다.**

## ✍️ 시험 포인트

- **증거 순서** — 메모리 먼저, 그다음 디스크. 종료는 마지막
- **메모리 수집 수단** — SSM Run Command + SSM 문서, 덤프는 **포렌식 계정 S3**, **OS·커널 태그**
- **격리 플래그** — `true`면 **수집 결과와 무관하게** 격리된다
- **격리 방식** — 인바운드·아웃바운드 없는 보안 그룹 부착 + 기존 보안 그룹 분리
- **디스크 두 단계 복사** — 공유 KMS 키로 복사·공유, **포렌식 계정에서 다시 복사**(계정 침해·스냅샷 삭제 대비)
- **120초 대기** — Run Command·스냅샷 완료 폴링 간격
- **범위 평가의 층** — GuardDuty(신호·공격 시퀀스) / 신 Security Hub(공격 경로·폭발 반경) / CSPM(자세, **비소급**)
- **노출 조사 결과가 없다 ≠ 안전하다** — 특성이 부족하면 생성되지 않는다
- **격리의 두 축** — 네트워크와 자격 증명
- **복구 전 확인** — 침해 시점·백업 무결성·경로 차단
- **Detective** — 탐지하지 않는다, **1년** 과거, GuardDuty 조사 결과에 연결

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ **"침해를 발견하면 즉시 종료한다"** → **휘발성 증거가 사라집니다**
- ❌ **"보안 그룹을 비우면 격리가 끝난다"** → **이미 발급된 임시 자격 증명**은 밖에서 유효합니다
- ❌ **"메모리 수집이 실패했으니 격리도 안 됐다"** → 플래그가 `true`면 **수집 결과와 무관하게 격리**됩니다
- ❌ **"스냅샷을 포렌식 계정에 공유하면 증거 보존이 끝난다"** → 공식은 **포렌식 계정에서 다시 복사**해 둡니다
- ❌ **"GuardDuty 조사 결과로 폭발 반경을 안다"** → 그것은 **신 Security Hub의 노출 조사 결과**입니다
- ❌ **"Detective를 켜면 탐지가 늘어난다"** → Detective는 **탐지하지 않습니다**
- ❌ **"Security Hub CSPM에서 사고 전 기록을 본다"** → **소급 적용되지 않습니다**
- ❌ **"노출 조사 결과가 없으니 그 리소스는 안전하다"** → 기여 특성이 부족하면 **생성되지 않습니다**
- ❌ **"백업이 있으니 바로 복원한다"** → **침해 시점·백업 무결성·경로 차단**을 먼저 봅니다
- ❌ **"Detective가 Security Lake의 세 소스를 모두 당겨온다"** → 공식은 **둘**을 적습니다

## 🧪 자가 점검

**Q1.** GuardDuty가 EC2 인스턴스의 암호화폐 채굴 활동을 탐지했습니다. 대응팀이 "① 인스턴스 종료 ② 보안 그룹 비우기 ③ 메모리 덤프 ④ EBS 스냅샷" 네 작업을 제안했습니다. 순서를 정하고 하나를 빼야 한다면? (→ 1 아티팩트 캡처)

<details><summary>정답 보기</summary>

**순서는 ③ 메모리 덤프 → ④ EBS 스냅샷 → ② 보안 그룹 비우기**이고, **① 인스턴스 종료는 이 단계에서 빼야 합니다.**

- **메모리가 가장 휘발성이 높습니다** — 종료·재부팅하면 사라지므로 먼저 확보합니다. 공식 포렌식 흐름이 **메모리 수집 → 격리** 순서인 이유입니다
- 디스크는 스냅샷으로 보존되므로 그다음입니다
- 격리는 **인바운드·아웃바운드가 없는 보안 그룹을 부착하고 기존 보안 그룹을 분리**하는 방식입니다
- **종료는 증거를 지우고 되돌릴 수 없습니다** — 분석이 끝난 뒤의 판단입니다

⚠️ 격리에는 **자격 증명 축**도 필요합니다 — 인스턴스 프로파일 역할의 권한을 걷지 않으면 **이미 발급된 임시 자격 증명**이 다른 곳에서 계속 유효합니다.
</details>

**Q2.** 침해된 인스턴스의 EBS 스냅샷을 포렌식 계정에 공유했습니다. 보안팀이 "원본 계정이 완전히 장악됐을 수 있다"고 합니다. 추가로 무엇을 해야 하고 왜입니까? (→ 1-3 디스크 수집)

<details><summary>정답 보기</summary>

**포렌식 계정에서 그 공유 스냅샷을 「포렌식 KMS 키」로 다시 복사해 로컬 사본을 둡니다.**

공식 디스크 수집 워크플로가 그 이유를 적습니다 — **AWS 계정이 침해되거나 공유 스냅샷이 보안팀에 의해 삭제되는 경우에도 포렌식을 수행할 수 있게** 하기 위해서입니다. 공유 스냅샷은 원본 계정에 의존하므로 **증거가 독립적이지 않습니다.**

⚠️ 앞 단계도 함께 기억합니다 — 애플리케이션 계정 역할을 수임해 **인스턴스 스냅샷**을 뜨고(완료 확인은 `Pending`·`In Progress`면 **120초 대기**), **포렌식 계정과 공유된 KMS 키로 복사**한 뒤 공유합니다. 복사가 끝나면 포렌식 유형 `DISK`로 **조사 흐름**이 시작됩니다.
</details>

**Q3.** Inspector가 어떤 EC2 인스턴스의 심각한 취약성을, Security Hub CSPM이 같은 인스턴스의 보안 그룹 위반을, GuardDuty가 그 인스턴스의 외부 통신을 각각 보고했습니다. "이 셋이 합쳐져 실제로 악용 가능한 경로가 되는지, 그리고 침해가 어디까지 번질 수 있는지"를 보려면? (→ 3 범위 평가)

<details><summary>정답 보기</summary>

**신 `Security Hub`의 노출 조사 결과**입니다. **Security Hub CSPM · Inspector · GuardDuty · Macie의 신호를 상관**해 **공격 경로와 폭발 반경**을 시각화하고, 생성 과정에 **네트워크 도달 가능성 평가**(인터넷 노출과 내부 경로, 보안 그룹·네트워크 ACL 분석)와 **IAM 권한·역할·접근 패턴 분석**이 들어갑니다.

구성 요소로 **심각도**(Critical·High·Medium·Low)와 **기여 특성**(직접 취약성 · 구성 문제 · 네트워크 노출 · 리소스 권한 설정 · **리소스 중요도**), **개선 지침**이 함께 옵니다.

⚠️ `Security Hub CSPM`은 조사 결과를 **ASFF**로 모아 **보안 점수**를 내지만 **상관해 공격 경로를 만들지는 않습니다.** 두 제품을 한 이름으로 섞으면 이 문항을 가를 수 없습니다.

⚠️ 그리고 **노출 조사 결과가 없다는 것이 안전하다는 뜻은 아닙니다** — 기여 특성이 없거나 부족하면 **생성되지 않습니다.**
</details>

**Q4.** 사고 조사에서 "이 자격 증명이 언제부터 어떻게 쓰였는지, 그리고 그 전후로 무엇이 바뀌었는지"를 보려 합니다. 어떤 서비스이고 무엇을 기대할 수 있습니까? (→ 5 근본 원인)

<details><summary>정답 보기</summary>

**Amazon Detective**입니다. 로그를 자동 수집해 **ML·통계 분석·그래프 이론**으로 시각화를 만들고, ⚠️ **최대 1년의 과거 이벤트 데이터**에 접근할 수 있으며 변화를 **GuardDuty 조사 결과에 연결**합니다.

쓸 기능 —
- **Detective Investigation** — **IAM 사용자·역할**을 **침해 지표(IOC)**로 조사합니다(`StartInvestigation` API)
- **조사 결과 그룹** — 고심각도 GuardDuty 조사 결과의 근본 원인을 **행동 그래프**에서 추출합니다
- **VPC 흐름 볼륨 조사** — 인스턴스별 IP 상호작용을 봅니다
- **Security Lake 통합** — 보관된 원시 로그를 쿼리합니다

⚠️⚠️ **Detective는 탐지하지 않습니다** — 다른 서비스가 탐지한 것의 **맥락**을 만듭니다. "탐지를 늘리려고 Detective를 켠다"는 설계는 틀립니다.

⚠️ Security Lake 통합에서 **실제로 당겨오는 원시 로그는 공식이 둘**(CloudTrail 관리 이벤트·VPC 흐름 로그)로 적습니다 — 세 소스를 모두 당겨온다고 단정하지 않습니다.
</details>

**Q5.** 랜섬웨어로 데이터가 암호화됐습니다. 사흘 전 백업이 있습니다. 바로 복원해도 됩니까? (→ 4-2 복구)

<details><summary>정답 보기</summary>

**세 가지를 먼저 확인합니다.**

1. **침해 시점** — 사흘 전 백업이 **침해 이전**인지 확정해야 합니다. 시점 확정에 Detective의 **최대 1년 과거 데이터**와 GuardDuty 조사 결과 연결이 쓰입니다
2. **백업 자체의 무결성** — 공격자가 백업·스냅샷을 먼저 손댔을 수 있습니다
3. **침해 경로 차단** — 같은 취약성이나 같은 자격 증명이 남아 있으면 **복원 직후 재침해**됩니다

⚠️ 그래서 "빨리 복구하라"는 지문에서도 **먼저 범위를 평가하고 경로를 막는 보기**가 답인 경우가 많습니다. 범위 평가의 층은 §3입니다 — GuardDuty(신호·공격 시퀀스) / 신 Security Hub(공격 경로·폭발 반경) / Security Hub CSPM(자세, **비소급**).
</details>

**Q6.** 여러 계정의 로그를 각각 다른 형식으로 받고 있고, 사고 조사에서 "같은 요청 ID가 어느 계정의 어느 로그에 어떻게 나타났는지" 교차로 봐야 합니다. 어떤 수단 조합입니까? (→ 2 검색과 상관)

<details><summary>정답 보기</summary>

**형식을 맞추는 층과 교차로 보는 층을 분리합니다.**

- **정규화** — **Amazon Security Lake**가 수집 데이터를 **OCSF + Parquet**로 변환해 이질적 형식을 한 스키마로 맞춥니다(기본 지원 AWS 소스는 자동, **타사·사용자 지정 소스는 보내는 쪽이 OCSF로 변환**해야 합니다)
- **교차 조회** — 레이크 테이블은 **Athena**로, CloudWatch Logs의 로그 그룹을 넘나드는 상관은 **Logs Insights의 OpenSearch SQL**(`JOIN`·하위 쿼리)로 봅니다

⚠️ 한도가 다릅니다 — **Logs Insights QL은 계정당 100개 동시 실행**이고 **PPL·SQL은 각 15개**입니다. **`filterIndex`와 비교 쿼리는 QL 전용**입니다.

⚠️ 조사 산출물 보호가 필요하면 Logs Insights의 **쿼리 결과 KMS 암호화**를 씁니다.
</details>

---

### 📌 출처

1. Forensic memory and disk acquisition service — `docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/forensic-memory-and-disk-acquisition-service.html` (2026-11-08 확인)
2. Disk forensics acquisition workflow — `docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/disk-forensics-acquisition-workflow.html` (2026-11-08 확인)
3. Architecture overview — Automated Forensics Orchestrator for Amazon EC2 and EKS — `docs.aws.amazon.com/solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/architecture-overview.html` (2026-11-08 확인)
4. What is Amazon Detective? — `docs.aws.amazon.com/detective/latest/userguide/what-is-detective.html` (2026-11-08 확인)
5. Exposure findings in Security Hub — `docs.aws.amazon.com/securityhub/latest/userguide/exposure-findings.html` (2026-11-08 확인)
6. Introduction to AWS Security Hub CSPM — `docs.aws.amazon.com/securityhub/latest/userguide/what-is-securityhub.html` (2026-11-08 확인)
7. What is Amazon GuardDuty? — `docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html` (2026-11-08 확인)
8. Analyzing log data with CloudWatch Logs Insights — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html` (2026-11-08 확인)
9. What is Amazon Security Lake? — `docs.aws.amazon.com/security-lake/latest/userguide/what-is-security-lake.html` (2026-11-08 확인)
10. What is Amazon Athena? — S3 데이터를 표준 SQL로 조회 — `docs.aws.amazon.com/athena/latest/ug/what-is.html` (2026-11-10 확인)
