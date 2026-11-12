---
examGuideTaskId: scs-t3-2
certCode: SCS-C03
domain: 3
domainName: 인프라 보안
domainWeightPct: 18
title: 컴퓨팅 워크로드 보안 (이미지 강화·워크로드 승인·취약성 스캔·패치·관리 액세스·파이프라인·생성형 AI 가드레일)
coversTasks:
  - "3.2"
sources:
  - title: What is Image Builder?
    url: https://docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-image-builder.html
  - title: Use instance profiles
    url: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html
  - title: Scanning AWS Lambda functions with Amazon Inspector
    url: https://docs.aws.amazon.com/inspector/latest/user/scanning-lambda.html
  - title: Amazon Inspector finding types
    url: https://docs.aws.amazon.com/inspector/latest/user/findings-types.html
  - title: Understanding Amazon Inspector findings
    url: https://docs.aws.amazon.com/inspector/latest/user/findings-understanding.html
  - title: GuardDuty Runtime Monitoring
    url: https://docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html
  - title: AWS Systems Manager Patch Manager
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager.html
  - title: AWS Systems Manager Session Manager
    url: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html
  - title: Connect to an Amazon EC2 instance using EC2 Instance Connect Endpoint
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-using-eice.html
  - title: Detect and filter harmful content by using Amazon Bedrock Guardrails
    url: https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html
  - title: "Capability 5. Providing secure access, usage, and implementation of generative AI agents (AWS SRA for generative AI)"
    url: https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-generative-ai/gen-auto-agents.html
  - title: Services in Sunset — 종료 예정 항목 목록
    url: https://docs.aws.amazon.com/general/latest/gr/sunset_services.html
  - title: Services in Maintenance — 유지 관리 항목 목록
    url: https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html
  - title: Amazon Inspector Code Security
    url: https://docs.aws.amazon.com/inspector/latest/user/code-security-assessments.html
  - title: CodeSecurityScanConfiguration — 규칙 세트 범주·지속적 통합·정기 스캔
    url: https://docs.aws.amazon.com/inspector/v2/APIReference/API_CodeSecurityScanConfiguration.html
  - title: aws codeguru-security (AWS CLI 명령 참조) — 2025-11-20 지원 종료 공지
    url: https://docs.aws.amazon.com/cli/latest/reference/codeguru-security/
  - title: Control the discovery and use of AMIs with Allowed AMIs
    url: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-allowed-amis.html
lastVerified: 2026-11-12
---

# 컴퓨팅 워크로드 보안 (이미지 강화·워크로드 승인·취약성 스캔·패치·관리 액세스·파이프라인·생성형 AI 가드레일)

> **커버하는 공식 Task** — SCS-C03 · 도메인 3 「인프라 보안」(18%) · **작업 3.2 컴퓨팅 워크로드에 대한 보안 제어 설계, 구현 및 문제 해결** (`scs-t3-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 7개(3.2.1~3.2.7)를 모두 덮습니다. **16개 작업 중 기술이 가장 많은 작업**이고, 순서가 워크로드의 수명 주기와 그대로 겹칩니다 — **이미지 만들기 → 권한 주기 → 취약성 찾기 → 패치 → 접속하기 → 파이프라인에서 막기 → 생성형 AI 보호.**

> ⚠️ **`기술 3.2.7`은 C03에서 신설된 기술입니다**("생성형 AI 애플리케이션용 보호 및 가드레일 구현 — LLM 애플리케이션 보호용 GenAI OWASP 상위 10개 적용"). 7절이 그 자리입니다.

> ⚠️⚠️ **`기술 3.2.6`이 드는 두 예시는 상태가 바뀐 이름입니다.** `Amazon CodeGuru 보안`은 **지원 종료**이고 사용자 안내서가 통째로 응답하지 않으며, `Amazon Q Developer`는 **IDE 플러그인**이 지원 종료 대상입니다(서비스 전체가 아닙니다). 6절이 **현행 수단을 축으로** 다루고 두 이름은 상태를 적어 넘어갑니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 강화된 이미지를 **파이프라인으로** 만들고 배포를 **테스트에 묶는** 방법을 설명한다
- [ ] 인스턴스 프로파일의 **1:1 제약**과 권한 변경 시 **교체해야 하는 이유**를 안다
- [ ] Inspector의 **조사 결과 세 유형**과 각 유형의 **대상 리소스**를 가른다
- [ ] Lambda **표준 스캔과 코드 스캔**의 선행 관계와 제약을 안다
- [ ] GuardDuty 런타임 모니터링이 **지원하는 것과 지원하지 않는 것**을 구분한다
- [ ] Patch Manager가 **하지 않는 것**(사전 테스트·주 버전 업그레이드)을 말한다
- [ ] Session Manager에서 **로깅되지 않는 연결 방식**을 안다
- [ ] Bedrock Guardrails의 정책 종류와 **평가되지 않는 영역**을 설명한다

## 🎯 왜 중요한가

컴퓨팅 보안 문항은 **"탐지 수단을 잘못 고르면 그 대상을 아예 보지 못한다"**는 구조로 나옵니다. Inspector는 **패키지·코드·네트워크 도달성**을 보고 GuardDuty 런타임은 **실행 중 행위**를 봅니다. 둘은 겹치지 않습니다.

그리고 **"접속은 되지만 기록이 없다"**가 Specialty의 단골입니다. Session Manager를 켰다고 다 기록되는 것이 아니고(§5-1), 그 한 줄을 모르면 감사 요건을 못 맞춥니다.

## ⚡ 시험 직전 요약

- **EC2 Image Builder**는 **모든 테스트가 성공해야 이미지를 배포**하고 **STIG 강화 컴포넌트**를 제공합니다
- ⚠️ **인스턴스 프로파일에는 IAM 역할이 하나만** 들어가고 상한을 올릴 수 없습니다. 권한을 바꿀 때는 **프로파일을 교체**합니다(역할 제거는 **최대 1시간 지연**)
- Inspector 조사 결과는 **패키지 취약성 · 코드 취약성 · 네트워크 도달성** 셋이고, ⚠️ **네트워크 도달성은 EC2 전용 · 12시간마다**입니다
- ⚠️ Lambda **코드 스캔은 표준 스캔을 먼저 켜야** 하고, **고객 관리형 키로 암호화된 함수는 스캔되지 않습니다**
- ⚠️⚠️ GuardDuty 런타임 모니터링은 **EKS · Fargate 상의 ECS · EC2**를 덮지만 **Fargate에서 실행되는 EKS 클러스터는 지원하지 않습니다**
- ⚠️ **AWS는 Patch Manager에 넣기 전에 패치를 테스트하지 않고**, **OS 주 버전 업그레이드를 지원하지 않습니다**
- ⚠️ 패치 심각도는 **소프트웨어 발행자가 보고한 값**이고 **CVSS·NVD에서 유도하지 않습니다**
- ⚠️⚠️ **포트 포워딩·SSH로 연결한 Session Manager 세션은 로깅되지 않습니다**
- **EC2 Instance Connect Endpoint**는 **SSH와 RDP 둘 다** 지원하고 **프라이빗 IP**로 연결합니다
- Bedrock Guardrails의 정책은 **콘텐츠 필터·거부 주제·단어 필터·민감 정보 필터·문맥 근거 확인·자동 추론 검사**이고 ⚠️ **추론 콘텐츠 블록은 평가에서 제외**됩니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **이미지 레시피** | 기본 이미지 + 적용할 컴포넌트를 정의한 문서. **빌드를 복제**할 수 있습니다 |
| **컴포넌트** | 이미지에 적용하는 빌드·테스트 단계의 묶음. AWSTOE로 직접 만들 수 있습니다 |
| **STIG** | 미 국방부의 보안 기술 구현 가이드. Image Builder가 **Amazon 관리형 강화 컴포넌트**로 제공합니다 |
| **인스턴스 프로파일** | IAM 역할을 **EC2 인스턴스에 전달**하는 컨테이너. 역할과 다른 이름을 가질 수 있습니다 |
| **패치 기준(patch baseline)** | 어떤 패치가 승인되는지 정의하는 규칙 + 승인·거부 목록 |
| **패치 정책(patch policy)** | Quick Setup에서 **조직·리전 전체의 패치 작업**을 하나로 정의하는 **권장 방법** |
| **관리형 노드** | SSM Agent로 Systems Manager가 관리하는 EC2·엣지 장치·온프레미스 서버·VM |
| **가드레일(Guardrail)** | 생성형 AI 입출력에 적용하는 구성 가능한 안전 조치. 모델과 **독립적으로** 버전 관리됩니다 |

## 📖 핵심 개념

### 1) 강화된 이미지를 설계·구현한다 (기술 3.2.1) {#images}

**EC2 Image Builder**는 이미지 생성·관리·배포를 자동화하는 완전관리형 서비스입니다. 파이프라인이 다섯 단계로 구성됩니다 — **파이프라인 세부(일정·취약성 스캔 설정) → 이미지 사용자 지정(기본 이미지·빌드 컴포넌트·테스트 컴포넌트) → 워크플로 정의 → 빌드 인프라 구성 → 배포 정의**.

보안 관점에서 외울 것은 넷입니다.

1. ⚠️⚠️ **테스트가 게이트입니다** — 공식 표현이 **"구성한 테스트가 모두 성공한 경우에만 이미지를 배포한다"**입니다. 사용자 지정 테스트는 **AWSTOE**(AWS Task Orchestrator and Executor)로 만듭니다
2. **STIG 강화 컴포넌트**를 Amazon 관리형으로 제공해 규제 산업의 준수 이미지를 빠르게 만듭니다
3. ⚠️ **Organizations 통합으로 「승인된 AMI만 실행」을 강제**할 수 있습니다 — 이미지를 잘 만드는 것과 **그것만 쓰게 하는 것**은 다른 제어입니다
4. **AWS RAM으로 공유할 수 있는 리소스는 넷**입니다 — **컴포넌트 · 이미지 · 이미지 레시피 · 컨테이너 레시피**

⚠️ 빌드 인프라 설정에서 **인스턴스 프로파일에 연결할 IAM 역할**을 고르고, VPC·서브넷·보안 그룹을 지정하며, **실패 시 빌드 인스턴스를 종료할지(기본값) 남길지**를 정합니다. 트러블슈팅 때문에 남기도록 바꾸면 **침해 표면이 늘어난다**는 것이 보안 관점의 트레이드오프입니다.

⚠️ 배포 시 AMI는 **KMS 키 선택 · 계정·Organizations 간 공유 · License Manager 셀프 관리형 라이선스 연결 · 시작 템플릿 구성**을 할 수 있습니다. 컨테이너 이미지는 DockerHub 공개 이미지·ECR의 기존 이미지·Amazon 관리형 컨테이너 이미지를 시작점으로 씁니다.

### 2) 인스턴스 프로파일·서비스 역할·실행 역할 (기술 3.2.2) {#authorize}

컴퓨팅 워크로드에 권한을 주는 방식이 셋입니다 — EC2는 **인스턴스 프로파일**, AWS 서비스가 사용자를 대신해 동작하면 **서비스 역할**, Lambda 같은 실행 환경은 **실행 역할**입니다.

⚠️⚠️ **제약이 시험에 나옵니다.**

- **인스턴스 프로파일에는 IAM 역할이 하나만** 들어갑니다. 공식이 **"이 한 역할 제한은 늘릴 수 없다"**고 못박습니다. 반대로 **한 역할은 여러 프로파일에 들 수 있습니다**
- ⚠️ **권한을 바꾸려면 프로파일을 교체합니다.** 공식 권고가 **"역할을 인스턴스 프로파일에서 제거하는 것은 권장하지 않는다 — 변경이 적용되기까지 최대 1시간 지연이 있다"**입니다
- 역할을 바꾼 뒤에는 **최종 일관성** 때문에 전파를 기다려야 하고, **강제하려면 프로파일을 분리·재연결하거나 인스턴스를 중지·재시작**합니다
- 콘솔에서 EC2 역할을 만들면 **같은 이름의 인스턴스 프로파일이 자동 생성**됩니다. CLI·API에서는 **역할과 프로파일을 따로 만들어야** 하고 이름이 다를 수 있으므로 **프로파일 이름을 알아야** 인스턴스를 올릴 수 있습니다
- **실행 중인 인스턴스에도 프로파일을 붙일 수 있습니다**(`associate-iam-instance-profile`)

### 3) 컴퓨팅 리소스의 취약성을 스캔한다 (기술 3.2.3) {#scan}

#### 3-1. Amazon Inspector — 조사 결과 유형이 세 가지다

| 유형 | 대상 | 비자명한 사실 |
|---|---|---|
| **패키지 취약성** | EC2 · ECR 컨테이너 이미지 · Lambda | ⚠️ Windows는 개별 CVE가 아니라 **KB ID로 단일 조사 결과**를 내고, 그 KB에 속한 CVE 중 **가장 높은 CVSS·EPSS 점수와 악용 가능성**을 적습니다 |
| **코드 취약성** | Lambda 함수 스캔 + **Code Security** 기능 | 누락된 암호화·데이터 누출·주입 결함·약한 암호화를 찾습니다. ⚠️ **Amazon Q와 함께 개발한 내부 탐지기**를 쓰고 탐지된 **코드 스니펫을 Amazon Q가 저장**합니다 |
| **네트워크 도달성** | ⚠️⚠️ **EC2 인스턴스 전용** | **12시간마다** 스캔합니다 |

⚠️ **코드 스니펫의 암호화가 보안 설계 항목입니다** — 기본은 **AWS 소유 키**이고, 더 통제하려면 **고객 관리형 키**로 바꿉니다. ⚠️ **조직의 위임 관리자는 멤버 계정의 코드 스니펫을 볼 수 없습니다.**

⚠️⚠️ **네트워크 도달성이 보는 것은 「VPC 경계로부터 열린 경로」**입니다 — 인터넷 게이트웨이(ALB·CLB 뒤의 인스턴스 포함) · **VPC 피어링 연결** · 가상 프라이빗 게이트웨이를 통한 VPN에서 TCP·UDP 포트에 닿을 수 있으면 조사 결과가 납니다. 평가 대상에 **보안 그룹·네트워크 ACL·라우트 테이블·서브넷·VPC 엔드포인트·Direct Connect**가 모두 듭니다.

#### 3-2. 조사 결과의 수명 — "사라졌다"의 이유

상태는 셋입니다 — **Active**(미수정) · **Suppressed**(억제 규칙 적용) · **Closed**(수정됨).

- 리소스가 **삭제·종료되거나 스캔 대상에서 빠지면** 조사 결과를 자동으로 닫고 **3일 후 삭제**합니다
- 그 밖의 이유로 닫힌 조사 결과는 **30일 후 삭제**합니다
- ⚠️ **수정된 조사 결과는 7일 안에 같은 문제가 재발하면 다시 열립니다**
- Inspector를 **비활성화하면 24시간 후** 제거되고, **계정이 정지되면 90일 후** 제거됩니다
- ⚠️ **중지된 인스턴스의 조사 결과는 활성 상태로 남습니다** — "인스턴스를 멈춰도 목록에서 사라지지 않는다"의 답입니다

#### 3-3. Lambda 스캔 — 두 종류와 선행 관계

- **Lambda 표준 스캔**(기본값) — 함수·레이어의 **애플리케이션 의존성**에서 패키지 취약성을 봅니다
- **Lambda 코드 스캔** — 함수·레이어의 **사용자 지정 애플리케이션 코드**를 봅니다
- ⚠️⚠️ **코드 스캔을 켜려면 표준 스캔을 먼저 켜야 합니다**

⚠️⚠️ **고객 관리형 키로 암호화된 Lambda 함수는 스캔을 지원하지 않습니다**(표준·코드 둘 다). 적격 조건은 **최근 90일 내 호출·업데이트 · `$LATEST` 표시 · 태그로 제외되지 않음**이고, 90일간 호출·수정이 없으면 **자동 제외**된 뒤 다시 호출·수정하면 재개됩니다. 새 CVE가 데이터베이스에 추가되면 **관련 함수를 재스캔**합니다.

⚠️ Lambda 스캔을 켜면 Inspector가 계정에 **서비스 연결 채널**을 만들어 CloudTrail 이벤트를 감시합니다 — 공식 권고는 **자기 추적(trail)을 따로 만들어** 계정 이벤트를 관리하는 것입니다.

#### 3-4. GuardDuty 런타임 모니터링 — 범위가 함정이다

런타임 모니터링은 **OS 수준·네트워킹·파일 이벤트**를 관찰해 실행 중 위협을 찾습니다. 보안 에이전트가 **파일 액세스·프로세스 실행·명령줄 인자·네트워크 연결**을 봅니다.

⚠️⚠️ **지원 범위를 거꾸로 외우기 쉽습니다.** 공식 표현이 그대로 중요합니다 — **Amazon EKS · AWS Fargate 상의 Amazon ECS · Amazon EC2**를 덮고, **"GuardDuty는 AWS Fargate에서 실행되는 Amazon EKS 클러스터를 지원하지 않습니다."** 즉 **ECS on Fargate는 되고 EKS on Fargate는 안 됩니다.**

⚠️ 에이전트는 **자동 관리와 수동 관리**를 고를 수 있습니다(Fargate ECS만 예외). 자동은 GuardDuty가 설치·업데이트하고, 수동이면 **내가 설치·업데이트 책임**을 집니다.

⚠️ **Inspector와 겹치지 않습니다** — Inspector는 **"무엇이 취약한가"**(패키지·코드·경로)이고 런타임 모니터링은 **"지금 무슨 일이 벌어지는가"**입니다. 컨테이너 이미지의 CVE는 Inspector, 실행 중 컨테이너의 권한 상승 시도는 GuardDuty입니다.

⚠️ **`Amazon Inspector Classic`은 완전 종료**됐습니다(공식 `AWS Lifecycle Changes` 실측). "Classic과 현행을 비교하라"는 식의 이해는 더 이상 유효하지 않습니다.

### 4) 패치를 배포하고 준수를 유지한다 (기술 3.2.4) {#patch}

**Patch Manager**는 보안 업데이트와 그 밖의 업데이트로 관리형 노드를 패치하는 과정을 자동화합니다. ⚠️ **권장 방법은 Quick Setup의 「패치 정책」**입니다 — 하나의 구성으로 **조직의 모든 계정·리전**, 또는 고른 계정·리전, 또는 단일 계정-리전 쌍의 패치를 정의합니다.

⚠️⚠️ **Patch Manager가 하지 않는 것**이 시험의 핵심입니다.

- **AWS는 Patch Manager에 넣기 전에 패치를 테스트하지 않습니다** — 사전 프로덕션 검증은 **내 책임**입니다
- **OS 주 버전 업그레이드를 지원하지 않습니다**(Windows Server 2016 → 2019, RHEL 7 → 8 불가). **Windows 서비스 팩 설치와 Linux 마이너 버전 업그레이드**는 됩니다
- ⚠️ **심각도는 소프트웨어 발행자가 업데이트 공지·개별 패치에 보고한 값**을 쓰고 **CVSS나 NVD 같은 제3자 출처에서 유도하지 않습니다**
- Windows Server의 **애플리케이션 지원은 Microsoft가 발행한 것으로 한정**됩니다

작업 방식은 셋입니다 — **패치 정책 · 유지 관리 기간(maintenance window) · 온디맨드 「Patch now」**. 스캔만 해서 **누락 패치 보고서만 볼 수도** 있고 **스캔 후 자동 설치**도 됩니다. 준수 보고서는 **S3 버킷에 CSV로** 보낼 수 있고, **커널 라이브 패치**는 Run Command로 적용합니다.

⚠️ 통합 대상이 **Organizations · AWS Security Hub CSPM · CloudTrail · AWS Config**입니다 — 패치 준수를 **조사 결과로 중앙 집계**하려면 Security Hub CSPM 쪽입니다(공식 문서 자신이 **CSPM 이름을 씁니다**).

⚠️ `AWS Systems Manager`의 **Change Manager · Incident Manager · Application Manager는 유지 관리 상태**입니다. Patch Manager·Session Manager·Run Command는 영향이 없지만, 변경 승인 흐름을 설계할 때 **Change Manager를 전제로 하지 않습니다**.

### 5) 보안 관리 액세스를 구성한다 (기술 3.2.5) {#access}

#### 5-1. Session Manager — 기록되지 않는 경로가 있다

Session Manager는 **인바운드 포트를 열지 않고, 배스천 호스트를 두지 않고, SSH 키를 관리하지 않고** 노드를 관리합니다. 권한은 **IAM 정책만으로** 통제하므로 "접근을 한곳에서 부여·회수"가 됩니다. **퍼블릭 IP가 없는 노드**에도 연결되고, **포트 포워딩**으로 노드 내부 포트를 로컬 포트로 돌릴 수 있습니다.

로깅은 네 경로로 통합됩니다 — **CloudTrail**(API 호출) · **S3**(세션 로그, KMS 암호화 선택) · **CloudWatch Logs**(세션 로그, KMS 암호화 선택) · **EventBridge + SNS**(세션 시작·종료 알림).

⚠️⚠️ **공식 경고가 감사 설계를 가릅니다 — "포트 포워딩이나 SSH를 통해 연결하는 Session Manager 세션에는 로깅을 사용할 수 없습니다."** 이유는 **SSH가 AWS CLI와 Session Manager 엔드포인트 사이의 TLS 연결 안에서 모든 세션 데이터를 암호화하고 Session Manager는 터널 역할만** 하기 때문입니다. "모든 관리 세션의 명령 기록을 남겨야 한다"는 요건에서는 **SSH·포트 포워딩을 허용하지 않는 것**까지 설계에 들어가야 합니다.

⚠️ **Session Manager의 레거시 콘솔 페이지는 2026년 12월 31일에 폐지**되고 기능은 Systems Manager 통합 콘솔로 옮겨집니다(세션 시작·이력·기본 설정은 그대로 가능합니다).

#### 5-2. EC2 Instance Connect Endpoint — SSH만이 아니다

EC2 Instance Connect Endpoint(EICE)는 **프라이빗 IP로** 인스턴스에 연결합니다. ⚠️ **SSH와 RDP를 모두 지원**하므로 Windows 인스턴스에도 씁니다.

- 엔드포인트가 **`create-complete`** 상태여야 하고, **IP 주소 유형이 인스턴스와 호환**돼야 합니다(dual-stack이면 IPv4·IPv6 둘 다)
- ⚠️ **대상 인스턴스의 보안 그룹이 EICE에서 오는 인바운드 SSH 트래픽을 허용**해야 합니다
- ⚠️ **`maxTunnelDuration` IAM 조건**으로 터널 최대 지속 시간을 제한할 수 있고, 콘솔에서 입력하는 값은 **그 정책 조건을 지켜야** 합니다
- CLI에서는 `aws ec2-instance-connect open-tunnel`로 **단일 연결**과 **다중 연결**(로컬 포트 수신) 모드를 씁니다

⚠️ **Session Manager와의 갈림길** — 둘 다 인바운드 포트를 열지 않지만, **SSM Agent와 Systems Manager 등록이 전제인 쪽은 Session Manager**이고 EICE는 **네트워크 경로를 제공하는 엔드포인트**입니다. 반대로 **세션 로깅과 명령 감사는 Session Manager**의 몫입니다(§5-1의 예외 포함).

### 6) 파이프라인에서 취약성을 발견·해결한다 (기술 3.2.6) {#pipeline}

⚠️⚠️ **이 기술이 드는 두 예시는 상태를 먼저 알아야 합니다.**

| 공식 예시 | 2026-11-08 실측 상태 | 이 문서의 처리 |
|---|---|---|
| **`Amazon CodeGuru 보안`** | **지원 종료**(2025-11-20). 콘솔·서비스 리소스·**문서 접근이 모두 중단**됐고 공지는 SDK 참조에만 남았습니다 | **기능 서술을 하지 않습니다** — 근거가 될 문서가 없습니다 |
| **`Amazon Q Developer`** | ⚠️ 종료 대상은 **IDE 플러그인**입니다(Sunset 공지 2026-04-30 → **지원 종료 2027-04-30**, 유사 기능은 `Kiro`). 서비스 전체가 아닙니다 | **IDE 플러그인 한정**을 적고 넘어갑니다 |

⚠️ **공식 시험 가이드는 2026년 3월 26일에 게시됐는데 `CodeGuru 보안`은 2025년 11월에 이미 종료됐습니다** — 가이드가 게시 시점에 이미 존재하지 않는 서비스를 예시로 들고 있는 자리입니다. 이런 이름이 보기에 나오면 **정답이 아닐 가능성이 높다**고 읽는 것이 실전에서 안전합니다.

**현행 수단을 축으로 정리합니다.**

- **코드 취약성은 Inspector가 봅니다**(§3-1) — Lambda 함수 스캔과 **Code Security** 기능이 **1자 애플리케이션 소스 코드 · 3자 애플리케이션 의존성 · 코드형 인프라(IaC)**의 코드 취약성을 냅니다. 즉 **파이프라인 산출물 전체**가 대상입니다
- **컨테이너 이미지는 ECR 스캔**으로 빌드 산출물 단계에서 봅니다(§3-1의 패키지 취약성)
- **이미지 빌드 자체에 테스트를 묶는 것**은 Image Builder입니다(§1) — "모든 테스트 성공 시에만 배포"가 파이프라인 게이트입니다
- **패치 준수의 지속 확인**은 Patch Manager의 준수 보고 + **Security Hub CSPM** 집계입니다(§4)

⚠️ 설계 원칙으로 기억할 것은 **"파이프라인에서 막는 것과 런타임에서 보는 것은 다른 제어"**입니다. 코드·의존성·IaC는 배포 전에, 실행 중 행위는 GuardDuty 런타임 모니터링이 봅니다.

### 7) 생성형 AI 애플리케이션의 보호와 가드레일 (기술 3.2.7 — 신규) {#genai}

#### 7-1. 자율 에이전트의 위험과 통제 — 어느 층이 무엇을 보는가

> ⚠️⚠️ **인용 상태 변경(2026-11-10 실측).** 이 절은 2026-11-08에 **AWS 규범적 지침의 「Security for agentic AI on AWS」 가이드**(`prescriptive-guidance/latest/agentic-ai-security/`)를 근거로 썼고, 그 가이드가 자신의 모범 사례를 OWASP Top 10 for LLM Applications 2025에 번호 단위로 매핑했습니다. **그런데 그 가이드가 docs에서 더 이상 제공되지 않습니다** — 네 방법(`curl` · AWS 문서 리더 · docs 검색 색인 · 실제 브라우저)이 모두 **404**이고 가이드 루트도 같은 오류 페이지입니다. 그래서 이 사이트는 **그 매핑을 시험 근거로 쓰지 않고**, 같은 주제를 **현재 제공되는 AWS SRA 생성형 AI 가이드**(아래)와 **Bedrock Guardrails 문서**로 다시 세웁니다. ⚠️ **OWASP Top 10 for LLM Applications 자체는 OWASP의 발행물**이고 AWS 문서가 아닙니다 — 범주 번호를 AWS 공식 근거로 외우지 않습니다.

**공식이 적는 자율 에이전트의 위험 넷** — AWS SRA 생성형 AI 가이드의 「기능 5」가 이렇게 가릅니다.

| 위험 | 무엇이 문제인가 |
|---|---|
| **세션 격리** | 공유 메모리·캐시된 컨텍스트·지속 상태로 **한 사용자의 데이터가 다른 세션에 샐 수 있고**, 적대자가 거짓 정보를 심어 뒤 행동을 조종하는 **메모리 오염**이 가능합니다 |
| **과도한 자율성** | 도구 접근이 넓고 감독이 적은 에이전트는 **의도하지 않은 작업을 실행**하고, 개발자가 예상하지 못한 **도구 연쇄**를 만들고, **저권한 도구를 조합해 권한을 상승**시킬 수 있습니다 |
| **ID·액세스 관리 복잡성** | 에이전트가 사용자를 대신해 여러 시스템에 인증하므로 **자격 증명이 런타임에 노출**되거나 **권한 범위가 잘못 잡힐 수 있고**, 오케스트레이터가 하위 에이전트를 부르는 다중 에이전트 구조에서 더 복잡해집니다 |
| **안전한 실행 환경** | 코드 실행은 **임의 코드 실행·리소스 소진·호스트 접근** 위험을, 브라우저 자동화는 **자격 증명 노출·XSS·사용자 대신 의도하지 않은 작업** 위험을 만듭니다 |

⚠️⚠️ **과도한 자율성의 통제는 Guardrails가 아닙니다.** 공식이 드는 처방은 **에이전트에 최소 권한 IAM 역할**(필요한 도구·리소스·보안 암호만), **AgentCore Gateway로 도구 접근을 중앙화**하고 **OAuth 범위로 어느 에이전트가 어느 도구를 부를 수 있는지 제한**, **AgentCore Runtime의 전용 microVM 세션 격리**입니다. 공식 표현이 **"의도하지 않은 도구 조합으로 권한 상승을 가능하게 하는 넓은 권한을 피하라"**입니다.

⚠️ 반대로 **Guardrails가 보는 것은 입력과 출력의 내용**입니다(§7-2). 그래서 **"에이전트가 권한을 넘어 행동한다"에 Guardrails를 고르면 틀립니다** — 그 자리는 **권한 범위와 도구 접근 제한**입니다. 그리고 **요청 양과 속도**는 엣지에서 봅니다(작업 3.1 §3-2의 속도 기반 규칙).

#### 7-2. Bedrock Guardrails — 정책과 평가 범위

Guardrails는 **기초 모델 전반의 안전·프라이버시 제어**를 제공하고 **사용자 입력이나 모델 응답**에 있는 바람직하지 않은 콘텐츠를 탐지·필터합니다. 정책은 다음과 같습니다.

| 정책 | 무엇을 하나 |
|---|---|
| **콘텐츠 필터** | 미리 정의된 유해 범주(증오·모욕·성적·폭력·위법 행위·프롬프트 공격)를 **범주별 강도**로 탐지·필터 |
| **거부 주제** | 애플리케이션 맥락에서 바람직하지 않은 주제를 정의해 차단 |
| **단어 필터** | 사용자 지정 단어·구. ⚠️ **대소문자 무시 전체 단어·전체 구 일치**입니다 |
| **민감 정보 필터** | PII 등을 **차단 또는 마스킹**. 확률적 엔티티 탐지 + **사용자 지정 정규식** |
| **문맥 근거 확인** | 응답이 **출처에 근거하지 않거나 질문과 무관**한 경우를 탐지(RAG의 할루시네이션) |
| **자동 추론 검사** | 응답을 **논리 규칙 집합에 대해 검증**해 할루시네이션·보정·암묵적 가정을 드러냅니다 |

⚠️ **유해 범주의 개수는 공식 안에서 적는 자리마다 갈립니다** — 정의 절과 콘솔 설명이 다릅니다. **개수를 외우지 않고 범주의 성격**(유해 콘텐츠 vs 프롬프트 공격)을 기억합니다.

⚠️⚠️ **평가되지 않는 영역이 있습니다** — 공식이 **"사용자 입력이나 모델 응답에 있을 수 있는 민감 정보를 보호한다(**추론 콘텐츠 블록은 제외**)"**로 적습니다.

⚠️ **보호 수준(tier)이 다릅니다** — **Standard 계층**에서는 콘텐츠 필터·거부 주제의 탐지가 **코드 요소 안쪽**(주석·변수·함수 이름·문자열 리터럴)까지 확장되고, 문맥 근거 확인이 **추론·대화형 응답을 지원하며 더 일관된 점수와 추가 언어**를 지원합니다.

⚠️ **운용 방식 셋**을 기억합니다.

1. 가드레일을 만들면 **작업 초안(working draft)**이 생기고 **내장 테스트 창**으로 반복 조정한 뒤 **버전을 만들어** 모델에 씁니다
2. 추론 API 호출에서 **가드레일 ID와 버전을 지정**해 쓰거나, ⚠️ **`ApplyGuardrail` API로 기초 모델을 호출하지 않고** 입력·출력만 평가할 수 있습니다 — 자체 호스팅 모델이나 타사 모델 앞단에도 쓸 수 있는 경로입니다
3. ⚠️⚠️ **입력 프롬프트의 일부만 평가하는 태그 기능은 AWS SDK에서만** 쓸 수 있고 **콘솔(Bedrock 플레이그라운드·Guardrails 관리 콘솔) 에서는 쓸 수 없습니다.** RAG에서 시스템 지시·검색 결과·대화 이력을 평가에서 빼려면 SDK 경로가 필요합니다

⚠️ 엣지 쪽과 이어집니다 — **AWS WAF가 보호할 수 있는 리소스 목록에 `Amazon Bedrock AgentCore Gateway`가 있고 본문 검사 한도를 64 KB까지 올릴 수 있습니다**(작업 3.1 §1-2·§2-3). 생성형 AI 애플리케이션의 **입력 크기·속도**는 엣지에서, **내용**은 Guardrails에서 봅니다.

## ✍️ 시험 포인트

- **"승인된 이미지만 쓰게 하라"는 Image Builder + Organizations다** — 이미지를 만드는 것과 강제하는 것은 다릅니다
- **"테스트를 통과하지 않은 이미지가 배포되면 안 된다"는 Image Builder의 기본 동작이다**
- **"인스턴스에 역할 둘을 주고 싶다"는 불가능하다** — 프로파일당 역할 하나이고 상한을 못 올립니다
- **"권한을 바꿨는데 반영이 안 된다"는 1시간 지연·최종 일관성이다** — 프로파일 교체나 재연결·재시작으로 강제합니다
- **"열린 네트워크 경로를 찾아라"는 Inspector 네트워크 도달성이다** — ⚠️ **EC2 전용·12시간 주기**
- **"컨테이너 이미지의 CVE"는 Inspector, "실행 중 컨테이너의 행위"는 GuardDuty 런타임이다**
- **"EKS on Fargate의 런타임 위협"은 GuardDuty 런타임으로 안 된다** — ECS on Fargate는 됩니다
- **"Lambda 코드 취약성이 안 나온다"는 표준 스캔 미활성 또는 고객 관리형 키 암호화다**
- **"패치가 프로덕션을 깨뜨렸다"는 AWS가 패치를 테스트하지 않는다는 사실이다**
- **"OS를 2016에서 2019로 올려라"는 Patch Manager가 아니다**
- **"세션은 연결되는데 명령 기록이 없다"는 SSH·포트 포워딩이다**
- **"Windows 인스턴스에 프라이빗 IP로 접속"은 EC2 Instance Connect Endpoint의 RDP다**
- **"에이전트가 권한을 넘어 행동한다"는 Guardrails가 아니라 최소 권한 IAM 역할·Gateway 중앙화·OAuth 범위다**
- **"모델을 호출하지 않고 콘텐츠만 검사"는 `ApplyGuardrail` API다**

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "인스턴스 프로파일에 역할을 여러 개 담는다" → **하나뿐**이고 상한을 올릴 수 없습니다
- ❌ "역할을 프로파일에서 빼고 새로 넣으면 즉시 반영된다" → **최대 1시간 지연**이라 공식이 권장하지 않습니다
- ❌ "Inspector가 ECS 태스크의 런타임 행위를 본다" → Inspector는 **취약성**을 보고 런타임은 **GuardDuty**입니다
- ❌ "네트워크 도달성 조사 결과가 Lambda·컨테이너에도 난다" → **EC2 전용**입니다
- ❌ "GuardDuty 런타임은 Fargate면 다 된다" → **ECS on Fargate만**이고 **EKS on Fargate는 지원하지 않습니다**
- ❌ "인스턴스를 멈추면 Inspector 조사 결과가 닫힌다" → **중지된 인스턴스의 조사 결과는 활성**입니다
- ❌ "Patch Manager의 심각도는 CVSS 점수다" → **소프트웨어 발행자가 보고한 값**입니다
- ❌ "패치 정책 없이 유지 관리 기간만이 정석이다" → **권장 방법은 Quick Setup의 패치 정책**입니다
- ❌ "Session Manager를 켜면 모든 세션이 기록된다" → **포트 포워딩·SSH 세션은 로깅되지 않습니다**
- ❌ "EC2 Instance Connect Endpoint는 Linux SSH 전용이다" → **RDP도 지원**합니다
- ❌ "`CodeGuru 보안`으로 파이프라인 스캔을 설계한다" → **지원 종료**이고 문서조차 남아 있지 않습니다
- ❌ "`Amazon Q Developer`가 서비스 전체로 종료된다" → 종료 대상은 **IDE 플러그인**입니다
- ❌ "Guardrails가 토큰 폭증과 과도한 자율성까지 막는다" → Guardrails가 보는 것은 **입력과 출력의 내용**이고, 권한은 **최소 권한 IAM 역할과 도구 접근 제한**, 양과 속도는 **엣지**가 봅니다
- ❌ "프롬프트 일부만 평가하는 태그를 콘솔에서 설정한다" → **SDK 전용**입니다

## 🧪 자가 점검

**Q1.** EKS 클러스터와 Fargate 상의 ECS 서비스를 함께 운영합니다. "컨테이너가 침해돼 자격 증명이 유출되고 권한 상승을 시도하는 것을 실행 중에 탐지"하라는 요건입니다. 어디까지 덮을 수 있습니까? (→ 3-4 런타임)

<details><summary>정답 보기</summary>

**GuardDuty 런타임 모니터링으로 EKS(EC2 노드)와 ECS on Fargate를 덮고, EKS on Fargate는 덮을 수 없습니다.**

- 런타임 모니터링의 지원 리소스 유형은 **Amazon EKS · AWS Fargate 상의 Amazon ECS · Amazon EC2**입니다
- ⚠️⚠️ 공식이 못박습니다 — **"GuardDuty는 AWS Fargate에서 실행되는 Amazon EKS 클러스터를 지원하지 않습니다."** ECS on Fargate는 지원되므로 **둘을 헷갈리면 안 됩니다**
- 보안 에이전트는 **파일 액세스·프로세스 실행·명령줄 인자·네트워크 연결**을 보고, **자동 관리**(GuardDuty가 설치·업데이트)와 **수동 관리**를 고를 수 있습니다(Fargate ECS만 예외)

⚠️ 같은 요건에서 **"이미지에 어떤 CVE가 있는가"**는 **Inspector의 ECR 스캔**입니다 — 런타임과 취약성은 다른 제어입니다.
</details>

**Q2.** 감사에서 "모든 대화형 관리 세션의 실행 명령을 보존하라"는 요구를 받았습니다. Session Manager를 쓰고 S3·CloudWatch Logs 로깅을 켰는데도 일부 세션의 기록이 없습니다. 원인과 설계 수정은? (→ 5-1 Session Manager)

<details><summary>정답 보기</summary>

**포트 포워딩과 SSH로 연결한 세션은 로깅되지 않습니다.**

- ⚠️⚠️ 공식 경고 그대로입니다 — **"포트 포워딩이나 SSH를 통해 연결하는 Session Manager 세션에는 로깅을 사용할 수 없습니다."** 이유는 **SSH가 AWS CLI와 Session Manager 엔드포인트 사이 TLS 연결 안에서 세션 데이터를 전부 암호화하고 Session Manager는 터널 역할만** 하기 때문입니다
- 설계 수정은 **IAM 정책으로 SSH·포트 포워딩 세션을 허용하지 않고** 브라우저·CLI의 대화형 셸만 쓰게 하는 것입니다
- 남는 기록은 **CloudTrail의 API 호출**(누가 세션을 시작했는지)과 **EventBridge + SNS 알림**(시작·종료)입니다 — 다만 **실행한 명령의 내용**은 아닙니다

⚠️ 세션 로그는 S3·CloudWatch Logs 양쪽에 **KMS 키로 암호화**해 보낼 수 있습니다.
</details>

**Q3.** 새 Lambda 함수들의 코드 취약성 조사 결과가 전혀 생기지 않습니다. Inspector는 활성이고 EC2·ECR 조사 결과는 정상입니다. 확인할 것 셋은? (→ 3-3 Lambda 스캔)

<details><summary>정답 보기</summary>

**① 표준 스캔이 켜져 있는가 ② 함수가 고객 관리형 키로 암호화돼 있는가 ③ 적격 조건을 만족하는가.**

- ⚠️⚠️ **코드 스캔을 켜려면 Lambda 표준 스캔을 먼저 켜야 합니다.** 표준 스캔은 **의존성의 패키지 취약성**, 코드 스캔은 **사용자 지정 코드**를 봅니다
- ⚠️⚠️ **고객 관리형 키로 암호화된 Lambda 함수는 표준·코드 스캔 모두 지원되지 않습니다**
- 적격 조건은 **최근 90일 내 호출·업데이트 · `$LATEST` 표시 · 태그로 제외되지 않음**입니다. 90일간 활동이 없으면 자동 제외되고 다시 호출·수정하면 재개됩니다
- 지원 런타임이 **표준 스캔과 코드 스캔에서 서로 다릅니다** — 둘의 목록을 각각 확인합니다

⚠️ 코드 스니펫은 기본적으로 **AWS 소유 키**로 암호화되고 **고객 관리형 키**로 바꿀 수 있습니다. ⚠️ **위임 관리자는 멤버 계정의 스니펫을 볼 수 없습니다.**
</details>

**Q4.** "Windows Server 2016 노드를 2019로 올리고, 올린 뒤 최신 보안 패치를 조직 전체에 일괄 적용하라"는 요청입니다. Patch Manager로 어디까지 됩니까? (→ 4 패치)

<details><summary>정답 보기</summary>

**주 버전 업그레이드는 Patch Manager로 할 수 없고, 패치 일괄 적용은 패치 정책으로 합니다.**

- ⚠️ 공식이 명시합니다 — Patch Manager는 **운영 체제의 주 버전 업그레이드를 지원하지 않습니다**(Windows Server 2016 → 2019, RHEL 7 → 8). **Windows 서비스 팩 설치와 Linux 마이너 버전 업그레이드**는 됩니다
- 조직 전체 패치는 **Quick Setup의 패치 정책**이 권장 방법입니다 — 하나의 구성으로 **모든 계정·리전**, 고른 계정·리전, 또는 단일 계정-리전 쌍을 정의합니다
- ⚠️⚠️ 함께 기억할 것 — **AWS는 패치를 Patch Manager에 제공하기 전에 테스트하지 않습니다.** 사전 프로덕션 검증은 내 책임입니다
- 심각도는 ⚠️ **소프트웨어 발행자가 보고한 값**이고 **CVSS·NVD에서 유도하지 않습니다**

⚠️ 준수 결과는 **S3에 CSV 보고서**로 보내거나 **Security Hub CSPM**으로 집계합니다.
</details>

**Q5.** 사내 LLM 에이전트가 도구를 호출해 업무 시스템을 변경합니다. 보안 검토에서 "에이전트가 의도한 범위를 넘어 행동할 위험"과 "토큰 소비 폭증"이 지적됐습니다. 각각 어느 층의 통제입니까? (→ 7-1 자율 에이전트)

<details><summary>정답 보기</summary>

**둘 다 Bedrock Guardrails가 아닙니다. Guardrails가 보는 것은 입력과 출력의 내용입니다.**

- **과도한 자율성** — 공식 처방은 **에이전트에 최소 권한 IAM 역할**(필요한 도구·리소스·보안 암호만) · **AgentCore Gateway로 도구 접근 중앙화 + OAuth 범위로 호출 가능한 도구 제한** · **AgentCore Runtime의 전용 microVM 세션 격리**입니다. 공식 표현이 **"의도하지 않은 도구 조합으로 권한 상승을 가능하게 하는 넓은 권한을 피하라"**입니다
- **요청 양과 속도** — ⚠️ **엣지에서의 속도 제한**(작업 3.1 §3-2의 속도 기반 규칙)이 그 층입니다
- ⚠️⚠️ Guardrails의 보호 대상은 **사용자 입력과 모델 응답**이고 ⚠️ **추론 콘텐츠 블록은 제외**됩니다 — 유해 콘텐츠와 PII는 보지만 **권한과 소비량은 보지 않습니다**

⚠️ 공식이 적는 자율 에이전트 위험은 넷입니다 — **세션 격리 · 과도한 자율성 · ID·액세스 관리 복잡성 · 안전한 실행 환경**. 한 가지 통제로 끝내는 보기는 의심합니다.
</details>

**Q6.** RAG 애플리케이션에서 사용자 입력만 가드레일로 평가하고 검색 결과·시스템 지시는 평가에서 빼려 합니다. 그리고 자체 호스팅 모델 앞단에도 같은 필터를 쓰고 싶습니다. 가능합니까? (→ 7-2 Guardrails)

<details><summary>정답 보기</summary>

**둘 다 가능하지만 각각 조건이 있습니다.**

- **입력의 일부만 평가** — 입력 프롬프트에 **태그를 적용**해 선택적으로 평가합니다. ⚠️⚠️ 다만 이 기능은 **AWS SDK에서만** 쓸 수 있고 **콘솔(Bedrock 플레이그라운드·Guardrails 관리 콘솔)에서는 쓸 수 없습니다**
- **모델 밖에서 쓰기** — ⚠️ **`ApplyGuardrail` API**는 **기초 모델을 호출하지 않고** 입력·출력을 정의된 필터에 대해 평가합니다. 그래서 Bedrock이 아닌 모델의 앞뒤에도 같은 가드레일을 걸 수 있습니다
- 운용은 **작업 초안 → 내장 테스트 창으로 조정 → 버전 생성 → 추론에서 ID·버전 지정**입니다

⚠️ 평가 범위의 한계를 함께 기억합니다 — 보호 대상은 **사용자 입력과 모델 응답**이고 ⚠️ **추론 콘텐츠 블록은 제외**됩니다. **Standard 계층**에서는 탐지가 **코드 요소 안쪽**(주석·변수·함수 이름·문자열 리터럴)까지 확장됩니다.
</details>

---

### 📌 출처

1. What is Image Builder? — `docs.aws.amazon.com/imagebuilder/latest/userguide/what-is-image-builder.html` (2026-11-08 확인)
2. Use instance profiles — `docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html` (2026-11-08 확인)
3. Scanning AWS Lambda functions with Amazon Inspector — `docs.aws.amazon.com/inspector/latest/user/scanning-lambda.html` (2026-11-08 확인)
4. Amazon Inspector finding types — `docs.aws.amazon.com/inspector/latest/user/findings-types.html` (2026-11-08 확인)
5. Understanding Amazon Inspector findings — `docs.aws.amazon.com/inspector/latest/user/findings-understanding.html` (2026-11-08 확인)
6. GuardDuty Runtime Monitoring — `docs.aws.amazon.com/guardduty/latest/ug/runtime-monitoring.html` (2026-11-08 확인)
7. AWS Systems Manager Patch Manager — `docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager.html` (2026-11-08 확인)
8. AWS Systems Manager Session Manager — `docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html` (2026-11-08 확인)
9. Connect to an Amazon EC2 instance using EC2 Instance Connect Endpoint — `docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-using-eice.html` (2026-11-08 확인)
10. Detect and filter harmful content by using Amazon Bedrock Guardrails — `docs.aws.amazon.com/bedrock/latest/userguide/guardrails.html` (2026-11-08 확인)
11. Capability 5. Providing secure access, usage, and implementation of generative AI agents (AWS SRA for generative AI) — `docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-generative-ai/gen-auto-agents.html` (2026-11-10 확인)
12. Services in Sunset — 종료 예정 항목 목록 — `docs.aws.amazon.com/general/latest/gr/sunset_services.html` (2026-11-10 확인)
13. Services in Maintenance — 유지 관리 항목 목록 — `docs.aws.amazon.com/general/latest/gr/maintenance_services.html` (2026-11-10 확인)
14. Amazon Inspector Code Security — `docs.aws.amazon.com/inspector/latest/user/code-security-assessments.html` (2026-11-11 확인)
15. CodeSecurityScanConfiguration — 규칙 세트 범주·지속적 통합·정기 스캔 — `docs.aws.amazon.com/inspector/v2/APIReference/API_CodeSecurityScanConfiguration.html` (2026-11-11 확인)
16. aws codeguru-security (AWS CLI 명령 참조) — 2025-11-20 지원 종료 공지 — `docs.aws.amazon.com/cli/latest/reference/codeguru-security/` (2026-11-11 확인)
17. Control the discovery and use of AMIs with Allowed AMIs — `docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-allowed-amis.html` (2026-11-12 확인)

> ⚠️ **은퇴한 인용(2026-11-10 실측).** 이 문서의 §7-1은 처음에 **「Security for agentic AI on AWS」 가이드**(`prescriptive-guidance/latest/agentic-ai-security/`)의 OWASP 매핑을 근거로 썼으나, 그 가이드가 docs에서 더 이상 제공되지 않습니다(네 방법 모두 404 · 가이드 루트도 같은 오류 페이지). 그래서 그 두 URL을 출처에서 내리고 §7-1을 위 11번 가이드와 Bedrock Guardrails 문서로 다시 세웠습니다. 레포 전역 재등장 방지는 `source_url_retired_test.dart`가 맡습니다.
