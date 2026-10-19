---
examGuideTaskId: dea-t4-1
certCode: DEA-C01
domain: 4
domainName: 데이터 보안 및 거버넌스
domainWeightPct: 18
title: 인증 메커니즘 적용 (보안 그룹·IAM 역할·VPC 엔드포인트·Secrets Manager)
coversTasks:
  - "4.1"
sources:
  - title: Security group rules (Amazon VPC User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
  - title: Setting up Amazon VPC for JDBC connections to Amazon RDS data stores from AWS Glue (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/setup-vpc-for-glue-access.html
  - title: Gateway endpoints (AWS PrivateLink Guide) (공식 문서)
    url: https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
  - title: AWS PrivateLink for Amazon S3 (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html
  - title: Managed rotation for AWS Secrets Manager secrets (공식 문서)
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_managed.html
  - title: Lambda rotation functions (AWS Secrets Manager User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_lambda-functions.html
  - title: Configuring IAM policies for using access points (Amazon S3 User Guide) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points-policies.html
  - title: Domain units and authorization policies in Amazon SageMaker Unified Studio (공식 문서)
    url: https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/domain-units.html
  - title: DEA-C01 공식 시험 가이드 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
lastVerified: 2026-10-20
---

# 인증 메커니즘 적용 (보안 그룹·IAM 역할·VPC 엔드포인트·Secrets Manager)

> **커버하는 공식 Task** — DEA-C01 · 도메인 4 「데이터 보안 및 거버넌스」(18%) · **Task 4.1 인증 메커니즘 적용** (`dea-t4-1`)
> Skill 7개로 도메인 4에서 가장 넓습니다. 관통하는 질문은 둘입니다 — **"연결이 열려 있는가(보안 그룹·엔드포인트)"** 와 **"누구임을 어떻게 증명하는가(IAM 역할·자격 증명 회전)"**.
> **권한 모델(정책 작성·최소 권한·Lake Formation)은 Task 4.2** 에서 다룹니다. 여기서는 "들어올 길"과 "신분"에 집중하세요.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.1의 Skill 항목)

- [ ] **보안 그룹과 네트워크 ACL**의 차이를 상태 저장 여부로 가른다
- [ ] **AWS Glue가 VPC 안 데이터스토어에 연결**할 때 필요한 SG 규칙을 안다
- [ ] **IAM 사용자 그룹·역할·서비스 역할·서비스 연결 역할**을 구분한다
- [ ] **Gateway 엔드포인트와 Interface 엔드포인트**를 요구사항으로 가른다
- [ ] **엔드포인트 정책**이 무엇을 대체하지 않는지 설명한다
- [ ] **관리형 회전과 Lambda 회전**, **single user와 alternating users**를 가른다
- [ ] **스테이징 레이블**(AWSCURRENT·AWSPENDING·AWSPREVIOUS)의 역할을 안다
- [ ] 서비스별로 **어떤 역할이 필요한지**(Lambda·CloudFormation·Redshift·EMR·Glue) 고른다
- [ ] **S3 액세스 포인트 정책**과 버킷 정책의 관계를 설명한다
- [ ] **SageMaker Unified Studio의 도메인·도메인 단위·프로젝트**로 권한을 위임한다

---

## 🎯 왜 중요한가

- 보안 문항은 거의 항상 **"무엇이 막고 있는가"** 를 먼저 묻습니다. 정책이 맞아도 네트워크 경로가 없으면 실패하고, 경로가 열려도 역할이 없으면 실패합니다. **두 층을 따로 보는 습관**이 그대로 점수가 됩니다.
- **기본값이 승부처입니다.** 새 보안 그룹은 인바운드가 전부 막혀 있고, VPC 엔드포인트 정책은 기본이 전체 허용입니다. "기본 상태에서 무엇이 되고 무엇이 안 되는가"를 외워야 오답을 걸러냅니다.
- 역할 문항은 **"누가 전달(PassRole)하는가"** 로 갈립니다. CloudFormation·Glue 문항이 특히 그렇습니다.
- 회전 문항은 **"Lambda를 쓰는가"** 한 줄로 갈립니다. 관리형 회전은 Lambda를 쓰지 않습니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **보안 그룹** | security group | 리소스가 *어디서 오는 연결을 받아들이는가*를 정하는 가상 방화벽 |
| **상태 저장** | stateful | 나간 요청의 *응답은 규칙 없이도 돌아올 수 있는* 성질 |
| **자기 참조 규칙** | self-referencing rule | 소스를 *자기 자신과 같은 보안 그룹*으로 한정한 규칙 |
| **ENI** | elastic network interface | VPC 안에서 리소스가 갖는 *가상 네트워크 카드* |
| **AssumeRole** | assume role | 역할을 맡아 *임시 보안 자격 증명*을 받는 것 |
| **서비스 역할** | service role | 서비스가 *사용자 대신 작업하려고 맡는* IAM 역할 |
| **SLR** | service-linked role | *서비스가 권한을 미리 정해* 둔 특수한 서비스 역할 |
| **PassRole** | iam:PassRole | 역할을 *서비스에 넘겨줄 수 있는* 권한 |
| **VPC 엔드포인트** | VPC endpoint | 인터넷을 거치지 않고 *AWS 서비스로 가는 사설 경로* |
| **스테이징 레이블** | staging label | 회전 중 *비밀의 어느 버전이 현재인지* 표시하는 꼬리표 |

---

## 📖 핵심 개념

### 1) 보안 그룹 — 네트워크 수준의 접근 경로 통제 {#security-groups}

VPC 안에서 도는 데이터 서비스(Glue 작업의 ENI, VPC에 붙인 Lambda 등)가 **"어디서 오는 연결을 받아들이는가"** 를 정하는 가상 방화벽입니다. 시험은 규칙 문법이 아니라 **어떤 서비스가 어떤 규칙을 필요로 하는가**를 묻습니다.

- **기본 상태** — 규칙은 **허용(allow)만 쓸 수 있고 거부(deny) 규칙은 없습니다.** 새로 만든 보안 그룹은 **인바운드 규칙이 없어 인바운드가 전부 막히고**, 아웃바운드는 **전체 허용 규칙 하나가 기본으로** 들어 있습니다.
- **합산 평가** — 한 리소스에 여러 보안 그룹을 붙이면 **규칙이 합쳐져 하나의 규칙 집합으로** 평가됩니다.
- ⚠️ **상태 저장(stateful)** — 보안 그룹은 응답 트래픽이 반대 방향 규칙과 무관하게 허용되고, **네트워크 ACL은 stateless라 응답 트래픽을 자동 허용하지 않습니다.** 또 보안 그룹 규칙을 바꿔도 **기존 연결은 타임아웃될 때까지 계속 허용**됩니다.
- **다른 보안 그룹 참조** — 소스/대상으로 다른 보안 그룹을 쓰면 그 보안 그룹에 속한 **리소스 전체에 규칙이 적용**되며, **참조된 보안 그룹의 규칙이 복사되지는 않습니다.** 자기 자신을 소스로 쓰면 **자기 참조 규칙**이며 소스를 같은 보안 그룹으로 한정하는 효과가 있습니다.

**AWS Glue가 VPC 안 데이터스토어에 붙을 때 — 이 시험의 단골입니다.**

- Glue 작업은 지정한 서브넷에 **ENI를 만들며 사설 IP만 받고 공인 IP는 받지 않습니다.** 연결(connection)에 지정한 보안 그룹이 각 ENI에 적용됩니다.
- Glue 구성 요소끼리 통신하려면 **모든 TCP 포트에 대한 자기 참조 인바운드 규칙**이 필요하고, ⚠️ **소스가 같은 보안 그룹으로 한정되므로 VPC를 모든 네트워크에 여는 것이 아닙니다.** 공식 절차는 **RDS가 쓰는 보안 그룹에 모든 TCP 포트의 자기 참조 인바운드 규칙을 추가**하는 것입니다.
- 아웃바운드를 제한한다면 자기 참조 아웃바운드 규칙에 더해 **S3 게이트웨이 엔드포인트의 관리형 prefix list를 대상으로 하는 HTTPS 규칙**을 둡니다.
- **연결 실패 점검 항목** — 서브넷의 **여유 IP 수가 워커 수보다 많아야** 하고, VPC 밖 데이터(온프레미스, 퍼블릭 호스트명의 RDS)는 **퍼블릭 서브넷의 NAT 게이트웨이 경로가 없으면 연결이 타임아웃**되며, Secrets Manager·STS가 필요하면 엔드포인트를 붙여야 합니다. 작업은 **한 번에 하나의 VPC(서브넷)만** 접근하고, VPC에서 S3에 접근하려면 **VPC 엔드포인트가 필요**합니다.
- **VPC에 붙인 Lambda** — 인터넷 경로 없이는 **VPC 안 리소스에만** 연결할 수 있습니다. ⚠️ **공용 서브넷에 붙여도 인터넷이 열리지 않으므로** 사설 서브넷 + 공용 서브넷의 NAT 게이트웨이를 쓰고, AWS 서비스는 **인터페이스 VPC 엔드포인트**로 접근할 수 있습니다.

| 리소스 | 필요한 보안 그룹 규칙 | 시험 단서 |
|---|---|---|
| **Glue 작업/연결(VPC)** | 연결 보안 그룹에 **모든 TCP 포트 자기 참조 인바운드**. 아웃바운드 제한 시 자기 참조 + S3 prefix list(HTTPS) | "연결 테스트 실패", "VPC 안 JDBC 소스", "0.0.0.0/0 금지" |
| **대상 RDS 데이터스토어** | (공식 절차) RDS가 쓰는 보안 그룹에 자기 참조 인바운드 추가 | "Glue에서 RDS로 JDBC" |
| **Lambda(VPC 연결)** | 아웃바운드 허용 + NAT 또는 인터페이스 엔드포인트 | "VPC Lambda가 외부 API 호출 실패" |
| **Secrets Manager 회전 Lambda** | 회전 함수 → DB 아웃바운드, DB ← 회전 함수 인바운드 | "VPC 안 DB 자격 증명 자동 회전" |

### 2) IAM 사용자 그룹·역할·서비스 역할 {#iam-identities}

IAM의 "누구인가"는 사용자, 역할, 서비스가 맡는 역할로 갈립니다. 이 시험에서는 사람을 묶는 문제보다 **워크로드(Glue·Lambda·Redshift·EMR)가 어떤 역할을 맡아 접근하는가**가 훨씬 자주 나옵니다.

- **IAM 사용자 그룹**은 IAM 사용자의 모음이며, 그룹에 ID 기반 정책을 붙이면 구성원 모두가 그 권한을 받습니다. ⚠️ 그룹은 **중첩할 수 없고**(사용자만 포함 가능), 그룹은 인증이 아니라 권한과 관련되므로 ⚠️ **정책의 Principal로 지정할 수 없습니다.**
- **AssumeRole** 은 AWS 리소스 접근에 쓰는 **임시 보안 자격 증명**을 반환하며 같은 계정 내 또는 교차 계정 접근에 씁니다. 역할의 **신뢰 정책**은 "누가 assume 할 수 있는가"를, **권한 정책**은 "무엇을 할 수 있는가"를 정합니다.
- **서비스 역할**은 서비스가 사용자 대신 작업하려고 맡는 IAM 역할이며 **IAM 관리자가 만들고 수정·삭제할 수 있습니다.**
- **서비스 연결 역할(SLR)** 은 AWS 서비스에 직접 연결된 특수한 서비스 역할로, ⚠️ **서비스가 권한(신뢰 정책 포함)을 미리 정의하고 IAM 관리자는 권한을 볼 수만 있고 편집할 수 없습니다.** SLR을 지우려면 먼저 관련 리소스를 삭제해야 합니다.

| 구분 | 정의·수정 주체 | 대표 사례 | 시험 단서 |
|---|---|---|---|
| **IAM 사용자 그룹** | 관리자 | 사람 팀에 권한 일괄 부여 | "그룹에 정책", **"그룹은 Principal 불가"** |
| **IAM 역할** | 관리자(신뢰 정책 + 권한 정책) | Lambda 실행 역할, Redshift COPY용 역할 | "임시 자격 증명", "AssumeRole" |
| **서비스 역할** | IAM 관리자가 생성·수정·삭제 | EMR 서비스 역할, CloudFormation 서비스 역할, Glue 작업 역할 | "서비스가 사용자 대신" |
| **서비스 연결 역할(SLR)** | **서비스가 정의, 관리자는 보기만** | EMR의 Spot 인스턴스 요청용 SLR | "서비스가 소유한 역할", "편집 불가" |

### 3) VPC 엔드포인트 — Gateway vs Interface {#vpc-endpoints}

사설 서브넷의 워크로드가 인터넷 게이트웨이·NAT 없이 AWS 서비스에 **사설 경로**로 접근하게 하는 구성입니다. 시험은 (1) 유형 선택, (2) 엔드포인트 정책으로 범위 제한을 묻습니다.

- **Gateway 엔드포인트** — **S3·DynamoDB용**이며 인터넷 게이트웨이나 NAT 장치 없이 연결을 제공하고 **AWS PrivateLink를 쓰지 않습니다.** ⚠️ **추가 요금이 없습니다.** 라우팅 테이블에 지정하는 게이트웨이 방식이라 ⚠️ **온프레미스, 다른 AWS 리전에서의 접근은 허용하지 않으며**, 그런 경우에는 요금이 청구되는 인터페이스 엔드포인트를 써야 합니다.
- **Interface 엔드포인트**(AWS PrivateLink 기반) — 서브넷의 **사설 IP를 받는 ENI**로 구성되며, S3에서는 VPC 내부, **VPN·Direct Connect로 연결된 온프레미스**, 피어링/Transit Gateway로 연결한 **다른 리전 VPC**에서 접근할 수 있고 **요금이 청구**됩니다. 같은 VPC에 게이트웨이 엔드포인트가 이미 있어도 **둘을 함께 쓸 수 있습니다.**
- **프라이빗 DNS** — 켜면 S3 클라이언트를 엔드포인트 전용 DNS 이름으로 바꾸지 않고도 리전 DNS 이름이 사설 IP로 해석되며, 게이트웨이 엔드포인트가 함께 있으면 **VPC 내부 요청은 요금이 없는 게이트웨이로, 온프레미스 요청은 인터페이스 엔드포인트로** 보내 비용을 줄일 수 있습니다(온프레미스는 인바운드 Resolver 엔드포인트가 DNS 질의를 전달).
- **엔드포인트 정책** — 엔드포인트에 붙이는 리소스 기반 정책으로 그 엔드포인트를 쓸 수 있는 **주체와 접근 가능한 리소스를 제한**합니다. ⚠️ **ID 기반 정책·대상 서비스의 리소스 기반 정책을 대체하지 않고** 엔드포인트를 지나는 트래픽에만 적용되는 **추가 경계**이며, 사용자 정의 정책을 붙이지 않으면 ⚠️ **전체 접근을 허용하는 기본 정책**이 붙습니다.

| 항목 | **Gateway 엔드포인트** | **Interface 엔드포인트** (S3 기준) |
|---|---|---|
| 대상 서비스 | **S3, DynamoDB** | PrivateLink 기반(S3도 가능) |
| 접근 방식 | 라우팅 테이블 항목 | VPC **사설 IP**, 엔드포인트 전용 DNS 이름(프라이빗 DNS 옵션으로 리전 DNS 이름도 해석) |
| 온프레미스 접근 | **불가** | **가능** |
| 다른 리전 VPC | **불가** | VPC 피어링/Transit Gateway로 가능 |
| 요금 | **없음** | **청구됨** |
| 시험 단서 | "추가 비용 없이", "같은 VPC의 사설 서브넷에서 S3/DynamoDB" | "온프레미스에서 S3에 사설 접근", "다른 리전 VPC" |

### 4) 자격 증명 생성·회전 — AWS Secrets Manager {#secrets-rotation}

DB 암호·API 키를 코드에 넣지 않고 Secrets Manager에 저장하고 **주기적으로 자동 교체(rotation)** 하는 방법을 묻습니다. 핵심은 **"누가 회전을 수행하는가"** 와 **"회전 중 무중단을 어떻게 보장하는가"** 입니다.

- **관리형 회전** — 서비스가 회전을 설정·관리하며 ⚠️ **Lambda 함수를 쓰지 않습니다.** **Aurora·RDS·DocumentDB의 마스터 사용자 자격 증명과 Redshift 관리자 암호** 등에서 제공됩니다. 보통 **1분 안에** 끝나며 회전 중 새 연결이 이전 버전 자격 증명을 받을 수 있습니다. 애플리케이션 사용자에는 마스터 사용자 대신 **최소 권한 DB 사용자**를 쓰고, 최고 가용성이 필요하면 **alternating users** 전략을 쓰라고 권고합니다.
- **Lambda 회전 함수** — 그 밖의 비밀은 사용자가 소유한 Lambda 회전 함수가 비밀과 DB/서비스의 자격 증명을 갱신합니다.
- **회전 전략 2종** — **single user** 는 비밀에 든 사용자의 자격 증명을 갱신하고, **alternating users** 는 한 비밀에서 **두 사용자를 번갈아 갱신**해 새 자격 증명을 테스트하는 동안에도 다른 사용자의 자격 증명이 유효하므로 **가용성이 더 높습니다.**

**스테이징 레이블 — 회전 4단계를 이것으로 외우세요.**

Lambda 회전 함수는 **createSecret → setSecret → testSecret → finishSecret** 4단계를 수행하며 스테이징 레이블로 회전 중 비밀의 버전을 구분합니다.

1. **createSecret** — 새 값을 **AWSPENDING** 레이블로 저장
2. **setSecret** — DB/서비스의 자격 증명을 AWSPENDING 값에 맞게 변경
3. **testSecret** — AWSPENDING 값으로 접속 시험
4. **finishSecret** — **AWSCURRENT** 를 새 버전으로 옮기고 이전 버전에 **AWSPREVIOUS** 를 붙여 **마지막으로 정상이던 버전을 보존**

- ⚠️ **AWSPENDING이 AWSCURRENT와 다른 버전에 남은 채 회전이 끝나면, 이후 회전 호출은 "이전 회전이 아직 진행 중"이라고 보고 오류를 반환**합니다. 회전이 실패하면 AWSPENDING이 빈 비밀 버전에 붙어 있을 수 있습니다.
- **스케줄** — `rate()`/`cron()` 표현식(**UTC 기준**)이며 **최소 4시간 간격**까지 설정할 수 있습니다. 일 단위 지정(`AutomaticallyAfterDays`)은 **1~1000** 입니다.
- **네트워크** — 회전 Lambda는 **Secrets Manager 엔드포인트**(인터넷/NAT 경로 또는 VPC 인터페이스 엔드포인트)와 **대상 DB에 모두** 접근할 수 있어야 하고, 두 방향의 보안 그룹 규칙이 열려 있어야 합니다.
- **교차 계정 접근** — ⚠️ **리소스 정책과 ID 정책에서 모두** 허용해야 하며, ⚠️ **AWS 관리형 키(`aws/secretsmanager`)로는 교차 계정 접근이 불가**하므로 직접 만든 KMS 키로 암호화하고 키 정책을 붙여야 합니다.

| 구분 | **관리형 회전** | **Lambda 회전** |
|---|---|---|
| 수행 주체 | 해당 서비스가 설정·관리(**Lambda 불필요**) | 사용자가 소유한 Lambda 회전 함수 |
| 대표 대상 | Aurora·RDS·DocumentDB **마스터 사용자**, Redshift **관리자 암호** | 그 밖의 비밀(애플리케이션 DB 사용자, API 키) |
| 운영 부담 | 낮음 | 함수 코드·실행 역할·네트워크·보안 그룹 관리 |
| 시험 단서 | "Lambda 없이", "운영 오버헤드 최소", "마스터 사용자 암호" | "애플리케이션 사용자", "사용자 정의 비밀·API 키" |

### 5) 서비스용 IAM 역할 설정 {#service-roles}

질문은 늘 같습니다. **어떤 서비스가 어떤 역할을 맡아 무엇에 접근하는가**, 그리고 **그 역할을 누가 전달(PassRole)할 수 있는가**.

- **Lambda 실행 역할** — 함수가 AWS 서비스·리소스에 접근할 권한을 주는 IAM 역할입니다. 함수를 호출하면 **Lambda가 실행 역할을 자동으로 assume** 하므로 ⚠️ **함수 코드에서 `sts:AssumeRole`을 직접 호출하지 않아야** 합니다. 콘솔이 기본 생성하는 역할에는 CloudWatch Logs 쓰기 권한을 주는 **AWSLambdaBasicExecutionRole** 관리형 정책이 들어갑니다.
- **API Gateway** — 메서드의 권한 부여 유형으로 **IAM(`AWS_IAM`), Cognito 사용자 풀(`COGNITO_USER_POOLS`), Lambda 권한 부여자(`CUSTOM`)** 를 고를 수 있습니다. IAM 권한 부여를 쓰면 API Gateway가 호출자 자격 증명으로 **서명된 요청**을 검증하며 **SigV4/SigV4a** 서명을 지원합니다. 호출자에게는 `execute-api:Invoke` 를 허용하는 IAM 정책을 붙입니다. ⚠️ **다른 계정의 사용자는 API 소유자 계정의 역할을 assume할 수 있을 때만** 호출할 수 있습니다.
- **AWS CLI** — config 파일의 프로파일에 `role_arn` 과 `source_profile`(또는 `credential_source`)을 지정하면 CLI가 AssumeRole 호출을 자동으로 수행합니다. ⚠️ **역할 설정 변수는 CLI config 파일에만** 둘 수 있습니다.
- **CloudFormation** — ⚠️ **기본값은 호출한 IAM 주체의 자격 증명으로 스택 작업을 수행**합니다(그래서 주체가 템플릿의 리소스를 만들 권한도 있어야 합니다). **서비스 역할을 전달하면** CloudFormation이 그 역할로 작업하므로 사용자에게 리소스 생성 권한을 직접 줄 필요가 없고, 이때 사용자는 **스택 작업 권한과 `iam:PassRole`** 이 있어야 합니다.
- **Redshift COPY/UNLOAD** — 클러스터가 대신 assume할 IAM 역할을 만들어 클러스터에 연결하고 COPY에서 **`IAM_ROLE`** 파라미터로 지정합니다. IAM 연합 세션으로 접속하면 현재 세션의 자격 증명으로 적재하는 **`IAM_ROLE 'SESSION'`** 도 가능합니다.
- **Amazon EMR** — 클러스터마다 **서비스 역할**(리소스 프로비저닝·서비스 수준 작업), **EC2 인스턴스 프로파일 역할**(클러스터 인스턴스에서 도는 애플리케이션이 AWS 서비스를 호출할 때), **자동 확장 역할**(자동 확장 클러스터만)이 있습니다. **Spot 인스턴스를 요청하려면 서비스 연결 역할**이 필요합니다.
- **AWS Glue** — 작업이 쓰는 IAM 역할을 만들며, 콘솔 사용자가 역할을 서비스에 전달할 수 있도록 이름을 **`AWSGlueServiceRole`** 로 시작하게 만드는 규칙이 있습니다. ⚠️ **다른 이름이면 사용자에게 `iam:PassRole` 권한 정책을 추가**해야 합니다.

| 서비스 | 필요한 역할 | 핵심 포인트 |
|---|---|---|
| **Lambda** | 실행 역할 | Lambda가 자동 assume, **코드에서 AssumeRole 호출 금지** |
| **API Gateway** | IAM / Cognito / Lambda 권한 부여자 + 백엔드용 서비스 역할 | IAM 인증은 **SigV4 서명 + `execute-api:Invoke`** |
| **AWS CLI** | 프로파일의 `role_arn` + `source_profile` | **config 파일에서만** |
| **CloudFormation** | 서비스 역할(선택) | **미지정 시 호출자 권한**, 지정 시 **PassRole 필요** |
| **Redshift COPY/UNLOAD** | 클러스터에 연결한 IAM 역할 또는 `'SESSION'` | 역할 ARN은 `IAM_ROLE` 로 전달 |
| **EMR** | 서비스 역할 / EC2 인스턴스 프로파일 / 자동 확장 역할 | **노드에서 도는 앱의 AWS 호출 = 인스턴스 프로파일** |
| **Glue** | 작업 IAM 역할 | **`AWSGlueServiceRole` 접두 규칙**, 불일치 시 PassRole |

### 6) 역할·엔드포인트·서비스에 IAM 정책 적용 {#policy-attachment}

정책을 **"어디에 붙이는가"** 에 따라 평가가 달라집니다.

- **ID 기반 정책**은 IAM 사용자·그룹·역할에 붙어 그 ID가 할 수 있는 일을 정하며 **관리형 또는 인라인**입니다. **리소스 기반 정책**은 S3 버킷, SQS 큐, VPC 엔드포인트, KMS 키 등에 붙어 접근할 수 있는 주체와 작업을 정하며 ⚠️ **인라인만 가능**합니다.
- **평가의 기본** — 요청은 기본적으로 **암시적 거부**이고 명시적 허용이 있어야 통과하며, ⚠️ **명시적 거부는 명시적 허용을 이깁니다.**
- **S3 예시** — ⚠️ **같은 계정에서는 ID 기반 정책 또는 버킷 정책**에 권한이 있으면 되고, **다른 계정에서는 버킷 정책 그리고 ID 기반 정책 둘 다** 필요합니다.
- **S3 Access Points** — 버킷에 붙은 **이름 있는 네트워크 엔드포인트**로, 액세스 포인트마다 별도의 권한·네트워크 제어를 둘 수 있고 액세스 포인트 정책은 **기본 버킷 정책과 함께 평가되는** 리소스 기반 정책입니다. **버킷 정책으로 접근 제어를 액세스 포인트에 위임**해, 버킷에 대한 모든 접근을 액세스 포인트에 붙은 정책으로 통제할 수 있습니다(`s3:DataAccessPointAccount` 조건 키). 액세스 포인트는 **하나의 버킷에만** 연결되고 정책 크기는 **20 KB**, 계정·리전당 최대 **10,000개**입니다.

| 정책 유형 | 붙는 곳 | Principal 요소 | 평가 포인트 |
|---|---|---|---|
| ID 기반(관리형/인라인) | 사용자·그룹·역할 | 없음(붙은 ID가 주체) | 같은 계정 S3: 버킷 정책과 **OR** |
| 리소스 기반(**인라인만**) | S3 버킷, 큐, 키, 엔드포인트 | 지정 | 교차 계정: ID 기반 정책과 **AND** |
| VPC 엔드포인트 정책 | VPC 엔드포인트 | 지정 | **추가 경계**(대체 아님), 기본값 전체 허용 |
| S3 액세스 포인트 정책 | 액세스 포인트 | 지정 | 버킷 정책과 함께 평가, **버킷 정책으로 위임 가능** |

### 7) 관리형 서비스 vs 비관리형 서비스 {#managed-services}

판단 기준은 **공동 책임 모델에서 고객이 어디까지 책임지는가**입니다.

- AWS는 인프라, 고객은 그 위의 보안(클라우드 "안")을 책임지며 **책임 범위는 고객이 고르는 서비스에 따라 달라집니다.**
- **EC2는 IaaS** 라 **게스트 OS(업데이트·보안 패치), 설치한 애플리케이션, 보안 그룹 구성이 고객 책임**입니다.
- **S3·DynamoDB 같은 추상화된 서비스**는 AWS가 **인프라 계층·OS·플랫폼을 운영**하고, ⚠️ **고객은 데이터 관리(암호화 옵션 포함)와 IAM 권한 적용을 여전히 책임**집니다.
- 관리형 서비스는 **패치·취약점 관리 같은 일부 보안 작업을 AWS가 맡아** 고객의 보안·규정 준수 의무를 줄여 주고, **관리형 서비스 사용은 Well-Architected 모범 사례**입니다. **Amazon EMR** 은 Apache Hadoop·Spark 같은 빅데이터 프레임워크 실행을 단순화하는 **관리형 클러스터 플랫폼**입니다.

### 8) SageMaker Unified Studio — 도메인·도메인 단위·프로젝트 {#unified-studio}

> 📌 **v1.1 신규 Skill(4.1.7)** 입니다. 조직 구조(**도메인 → 도메인 단위 → 프로젝트**)와 그 위의 **권한 위임**을 묻습니다.

- **도메인(domain)** — 자산·사용자·프로젝트를 연결하는 **조직 단위**입니다. 전사에 하나만 두거나 사업부별로 여러 개를 둘 수 있습니다.
- **도메인 유형 2가지** — **IAM Identity Center 기반 도메인**은 IAM Identity Center로 사용자 인증·관리를 하며 **SSO를 지원**하고, **IAM 기반 도메인**은 IAM 역할과 IAM Identity Center로 인증·접근 제어를 하며 **연합 IAM 역할을 실행(execution) IAM 역할로** 씁니다. 두 유형은 같은 핵심 기능을 제공하지만 인증 방식과 설정 절차가 다릅니다.
- **IAM 기반 도메인** — IAM 역할로 도메인을 만들고, 도메인 안 프로젝트도 IAM 역할로 데이터·인프라에 접근하며 ⚠️ **프로젝트마다 로그인용 IAM 역할이 하나** 지정됩니다. ⚠️ **계정당 하나만** 둘 수 있고(문서에 따라 "계정당" 또는 "계정·리전당" — 아래 참고), 한 IAM 기반 도메인은 **여러 프로젝트를 지원**합니다.
- **도메인 단위(domain unit)** — 자산과 기타 도메인 엔티티를 **사업부·팀 단위로 조직**합니다. 새 도메인 단위를 만들 때 **상위(parent) 도메인 단위를 지정**하므로 **계층 구조**가 가능합니다. ⚠️ **계정 소유자로부터 도메인 단위 소유자에게 위임된 권한**을 제공해, 소유자가 **프로젝트 프로필 같은 리소스에 대한 권한 설정을 대신** 할 수 있습니다. 그래서 **사업부별로 프로젝트 프로필을 만들고 쓸 수 있는 사람을 제한**할 수 있고, 메타데이터 표준을 강제하는 데도 씁니다.
  - 도메인 단위에서 사용자·그룹에 줄 수 있는 권한 정책: **도메인 단위 생성·프로젝트 생성·프로젝트 멤버십·도메인 단위 소유권 인수·프로젝트 소유권 인수** 정책.
- **프로젝트 프로필(project profile)** — 프로젝트용 **"상위 템플릿"** 이며 **블루프린트(프로젝트 생성에 쓰는 구성)의 모음**입니다. 템플릿 프로필로 **All capabilities, SQL analytics, Generative AI application development, Custom** 이 있습니다.
- **프로젝트(project)** — 도메인 안에서 사용자들이 비즈니스 용도로 **협업하는 경계**이며, 쓸 수 있는 도구·리소스는 **만들 때 사용한 프로젝트 프로필에 따라** 정해집니다. 참여하려면 직접 만들거나 **프로젝트 소유자가 추가**해야 하며, 프로젝트를 다른 도메인 단위로 **옮길 수 있습니다.**
- **멤버십** — 멤버 역할은 **Contributor와 Owner 두 가지**입니다. ⚠️ **Owner는 기여에 더해 멤버 추가·제거, 설명 편집, 프로젝트 삭제가 가능**하고 **프로젝트를 만든 사람이 기본 Owner** 입니다. 멤버는 사용자·SSO 그룹·IAM 주체가 될 수 있으며 **프로젝트당 최대 20명**입니다.
- **거버넌스 관점** — IAM Identity Center 기반 도메인은 **개인 신원을 유지한 ID 기반 권한 부여**, 사용자 간 세분화된 접근 제어, 승인 절차가 있는 게시자/구독자 공유 워크플로에 강점이 있고, IAM 기반 도메인은 ⚠️ **한 프로젝트에 접근하는 모든 사용자가 같은 역할 권한을 공유**합니다.

> ⚠️ **문서 간 표현 차이** — IAM 기반 도메인 개수를 도메인 개요 페이지는 **"계정당 1개"**, IAM 기반 도메인 페이지는 **"계정·리전당 1개"** 로 적습니다. 시험에서는 **"추가로 더 만들 수 없다"** 는 방향만 잡으세요.

---

## ✍️ 시험 포인트

1. **Glue 연결 실패는 "자기 참조"** — *"사설 서브넷의 RDS에 Glue가 JDBC로 연결 못 함 + 0.0.0.0/0 개방 금지"* → **모든 TCP 포트 자기 참조 인바운드 규칙**. 자기 참조 규칙은 소스를 같은 보안 그룹으로 한정하므로 VPC를 모든 네트워크에 열지 않습니다.
2. **엔드포인트는 "온프레미스인가"로 갈림** — "추가 비용 없이 사설 서브넷에서 S3/DynamoDB" → **Gateway**. "온프레미스 또는 다른 리전 VPC에서 S3에 사설 경로" → **Interface(유료)**.
3. **엔드포인트 정책은 권한을 주지 않습니다** — ID 기반·리소스 기반 정책을 **대체하지 않는 추가 경계**이고 기본값은 **전체 허용**입니다.
4. **"Lambda 없이 자동 교체"** → **관리형 회전**(Aurora·RDS·DocumentDB 마스터 사용자, Redshift 관리자 암호). **"회전 중 무중단"** → **alternating users**.
5. **"회전이 이미 진행 중"이라는 오류** → **AWSPENDING이 AWSCURRENT와 다른 버전에 남은** 상태입니다.
6. **"개발자에게 리소스 생성 권한을 직접 주지 않고 배포"** → **CloudFormation 서비스 역할 + 사용자에게 `iam:PassRole`**. 역할을 전달하지 않으면 **호출자 자격 증명**으로 동작합니다.
7. **"EMR 노드의 Spark가 S3 접근"** → **EC2 인스턴스 프로파일 역할**(서비스 역할이 아님).
8. **"다수 팀이 한 버킷 공유, 팀별 정책·네트워크 제어"** → **S3 Access Points + 버킷 정책의 접근 제어 위임**.
9. **"사업부별로 프로젝트 생성 권한·프로젝트 프로필 사용을 위임"** → **도메인 단위 + 도메인 단위 권한 정책**. 사업부마다 IAM 기반 도메인을 추가하는 것은 **개수 제한 때문에 불가**합니다.
10. **"패치·취약점 관리 부담을 줄이려면"** → **관리형 서비스**. 단 **데이터·암호화 옵션·IAM 권한은 여전히 고객 책임**입니다.

---

## ⚠️ 흔한 함정

1. **보안 그룹에 거부 규칙을 추가하려 함** — 보안 그룹은 **허용 규칙만** 있습니다. 거부는 네트워크 ACL의 영역입니다.
2. **네트워크 ACL이 응답을 자동 허용한다고 생각** — 보안 그룹은 stateful, **NACL은 stateless** 라 응답 트래픽을 자동 허용하지 않습니다.
3. **규칙을 바꾸면 기존 연결이 즉시 끊긴다고 생각** — **타임아웃될 때까지 계속 허용**됩니다.
4. **자기 참조 규칙을 "VPC 전체 개방"으로 오해** — 소스가 같은 보안 그룹으로 한정됩니다. 0.0.0.0/0 개방의 **대안**입니다.
5. **참조한 보안 그룹의 규칙이 복사된다고 생각** — 복사되지 않고 **그 보안 그룹에 속한 리소스에 적용**됩니다.
6. **Glue ENI에 공인 IP를 주려 함** — Glue ENI는 **서브넷의 사설 IP만** 받습니다.
7. **보안 그룹만 보고 경로 문제를 놓침** — **서브넷 여유 IP < 워커 수**, NAT·엔드포인트 경로 부재(S3·Secrets Manager·STS)로도 실패합니다.
8. **VPC Lambda를 공용 서브넷에 붙여 인터넷을 기대** — **공용 서브넷에 붙여도 인터넷이 열리지 않습니다.** 사설 서브넷 + NAT 또는 인터페이스 엔드포인트입니다.
9. **IAM 사용자 그룹을 정책의 Principal로 지정** — **그룹은 Principal로 지정할 수 없습니다.** 그룹 중첩도 불가합니다.
10. **서비스 연결 역할의 권한을 편집하려 함** — SLR은 **서비스가 정의하고 관리자는 보기만** 합니다.
11. **Gateway 엔드포인트로 온프레미스 접근을 기대** — **불가**합니다. Interface 엔드포인트(유료)입니다.
12. **Gateway와 Interface 엔드포인트를 양립 불가로 생각** — **같은 VPC에서 함께 쓸 수 있고**, 병용이 오히려 비용 절감 전략입니다.
13. **엔드포인트 정책만으로 권한을 부여하려 함** — 추가 경계일 뿐이며 **기본값은 전체 허용**입니다.
14. **마스터 사용자 암호 회전에 굳이 Lambda를 작성** — **관리형 회전**이 있어 운영 부담만 늘립니다.
15. **single user가 가용성이 더 높다고 생각** — **alternating users** 가 더 높은 가용성 옵션입니다.
16. **AWSPREVIOUS를 "다음 버전"으로 오해** — **마지막으로 정상이던 이전 버전**입니다.
17. **회전 주기를 1시간으로 설정** — **최소 4시간** 간격이며 스케줄은 **UTC** 기준입니다.
18. **AWS 관리형 키로 비밀을 교차 계정 공유** — **불가**합니다. 직접 만든 KMS 키 + 키 정책이 필요하고, **리소스 정책과 ID 정책 둘 다** 허용해야 합니다.
19. **Lambda 코드에서 `sts:AssumeRole`을 호출** — **Lambda가 실행 역할을 자동으로 assume** 합니다.
20. **CloudFormation이 항상 서비스 역할로 동작한다고 생각** — **기본은 호출자 자격 증명**입니다.
21. **EMR 서비스 역할과 인스턴스 프로파일을 혼동** — 서비스 역할은 프로비저닝 등 서비스 수준 작업, **인스턴스 프로파일은 노드에서 도는 애플리케이션의 AWS 호출**입니다.
22. **Glue 역할 이름을 자유롭게 짓고 전달 실패** — `AWSGlueServiceRole` 접두어가 아니면 **`iam:PassRole`** 을 추가해야 합니다.
23. **교차 계정 S3 접근을 버킷 정책만으로 해결** — 교차 계정은 **버킷 정책 AND ID 기반 정책**입니다.
24. **"허용했는데 AccessDenied"를 정책 누락으로만 봄** — **명시적 거부가 허용을 이깁니다.**
25. **리소스 기반 정책을 관리형으로 만들려 함** — **인라인만** 가능합니다.
26. **프로젝트 멤버를 전부 Owner로 지정** — Owner는 **멤버 추가·제거와 프로젝트 삭제까지** 가능해 위임 범위를 통제하지 못합니다.
27. **사업부마다 IAM 기반 도메인을 추가** — **계정(문서에 따라 계정·리전)당 하나**입니다. 사업부 분리는 **도메인 단위**로 합니다.
28. **IAM 기반 도메인에서 사용자별 세분화 권한을 기대** — **한 프로젝트의 모든 사용자가 같은 역할 권한을 공유**합니다.

---

## 🧪 자가 점검

**Q1.** AWS Glue ETL 작업이 사설 서브넷의 Amazon RDS for PostgreSQL에 JDBC로 접속해야 한다. 보안 정책상 0.0.0.0/0 인바운드는 허용할 수 없다. Glue 구성 요소 간 통신을 허용하면서 노출을 최소화하는 구성은?

<details><summary>정답 보기</summary>

**Glue 연결의 보안 그룹에 소스가 같은 보안 그룹(자기 자신)인 모든 TCP 포트 인바운드 규칙을 추가합니다.** Glue 구성 요소끼리 통신하려면 모든 TCP 포트에 대한 자기 참조 인바운드 규칙이 필요하고, **소스가 같은 보안 그룹으로 한정되므로 VPC를 모든 네트워크에 열지 않습니다.** 공식 절차는 RDS가 쓰는 보안 그룹에 이 규칙을 추가하는 것입니다. 네트워크 ACL에 거부 규칙을 넣는 것은 통신을 **허용**하지 못하고, Glue ENI에는 **공인 IP를 할당할 수 없습니다.**
</details>

**Q2.** 온프레미스 데이터센터의 배치 서버가 이미 구성된 사설 연결로 VPC에 접속해 있고, 인터넷을 거치지 않고 S3 버킷에 접근해야 한다. 이 VPC에는 S3 게이트웨이 엔드포인트가 이미 있다. 무엇을 추가해야 하는가?

<details><summary>정답 보기</summary>

**S3용 인터페이스 VPC 엔드포인트를 추가합니다.** 게이트웨이 엔드포인트는 **온프레미스 접근을 허용하지 않고**, 인터페이스 엔드포인트는 사설 IP로 VPN·Direct Connect로 연결된 온프레미스에서도 S3에 접근하게 해 줍니다(**요금 청구**). 두 유형은 **같은 VPC에서 함께 쓸 수 있고**, 프라이빗 DNS를 켜면 VPC 내부 요청은 무료 게이트웨이로, 온프레미스 요청은 인터페이스 엔드포인트로 보내 비용을 줄일 수 있습니다. 엔드포인트 정책은 **새 경로를 만들지 않습니다.**
</details>

**Q3.** Amazon Aurora MySQL 클러스터의 마스터 사용자 암호를 정기적으로 자동 교체해야 한다. 팀은 회전용 Lambda 코드를 직접 작성·운영하고 싶지 않다. 운영 부담이 가장 적은 방법은?

<details><summary>정답 보기</summary>

**Secrets Manager에서 Aurora가 마스터 사용자 자격 증명에 제공하는 관리형 회전을 사용합니다.** Aurora·RDS·DocumentDB의 마스터 사용자 자격 증명과 Redshift 관리자 암호는 관리형 회전을 제공하며, **관리형 회전은 Lambda 함수를 쓰지 않습니다**(보통 1분 안에 완료). 사용자 정의 Lambda 회전 함수를 쓰면 함수 코드·실행 역할·네트워크·보안 그룹을 직접 관리해야 해 요구사항에 어긋납니다.
</details>

**Q4.** 개발자에게 리소스 생성 권한을 직접 주지 않고 CloudFormation으로만 배포하게 하려 한다. 어떻게 구성하는가?

<details><summary>정답 보기</summary>

**CloudFormation 서비스 역할을 만들어 스택에 전달하고, 개발자에게는 스택 작업 권한과 `iam:PassRole` 권한을 줍니다.** 서비스 역할을 전달하면 CloudFormation이 그 역할로 작업하므로 사용자에게 리소스 생성 권한을 직접 줄 필요가 없습니다. ⚠️ **서비스 역할을 전달하지 않으면 기본값으로 호출한 IAM 주체의 자격 증명으로 스택 작업을 수행**하므로, 그때는 호출자가 템플릿의 리소스를 만들 권한도 가져야 합니다.
</details>

**Q5.** 한 조직이 SageMaker Unified Studio에서 마케팅·재무 사업부별로 프로젝트 생성 권한과 사용할 수 있는 프로젝트 프로필을 따로 위임하려 한다. 어떻게 구성해야 하는가?

<details><summary>정답 보기</summary>

**사업부별 도메인 단위를 만들고 도메인 단위 소유자에게 프로젝트 생성 등의 권한 정책을 부여합니다.** 도메인 단위는 **계정 소유자에서 도메인 단위 소유자로 권한을 위임**하고, 사업부별로 **프로젝트 프로필을 만들고 쓸 수 있는 사람을 제한**할 수 있습니다. 사업부마다 IAM 기반 도메인을 추가하는 것은 **계정(문서에 따라 계정·리전)당 하나**라는 제한 때문에 불가하고, 모든 멤버를 Owner로 지정하면 **멤버 추가·제거와 프로젝트 삭제까지** 가능해져 위임 범위를 통제하지 못합니다.
</details>

---

**Q6 (원리).** 왜 "정책은 맞는데 안 된다"와 "경로는 열렸는데 안 된다"가 전혀 다른 문제일까요?

<details><summary>정답 보기</summary>

**인증·권한과 네트워크 경로는 서로를 대체하지 않는 독립된 두 관문이기 때문입니다.** 요청이 성공하려면 **① 패킷이 목적지에 닿아야** 하고(보안 그룹·라우팅·엔드포인트) **② 그 호출이 허가되어야** 합니다(역할·정책). Glue 작업이 RDS에 못 붙는 것은 거의 항상 ①의 문제이고, "AccessDenied"는 ②의 문제입니다. 그래서 증상의 **문구**가 어느 층인지 알려 줍니다 — *타임아웃·연결 실패* 는 ①, *AccessDenied* 는 ②입니다. 여기에 엔드포인트 정책이 섞이면 헷갈리는데, 엔드포인트 정책은 **①의 길 위에 ②의 검문소를 하나 더 세우는 것**이어서 **기본이 전체 허용**이고 **다른 정책을 대체하지 않습니다.** 두 관문을 따로 세워 두면, 문항이 아무리 길어도 어디를 고쳐야 하는지가 한 줄로 보입니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. Security group rules (Amazon VPC User Guide) — https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
2. Amazon EC2 security group connection tracking — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/security-group-connection-tracking.html
3. Setting up Amazon VPC for JDBC connections to Amazon RDS data stores from AWS Glue — https://docs.aws.amazon.com/glue/latest/dg/setup-vpc-for-glue-access.html
4. Setting up network access to data stores (AWS Glue) — https://docs.aws.amazon.com/glue/latest/dg/start-connecting.html
5. Why does my AWS Glue test connection fail? (AWS re:Post Knowledge Center) — https://repost.aws/knowledge-center/glue-test-connection-failed
6. How do I give internet access to a Lambda function that's connected to Amazon VPC? (AWS re:Post Knowledge Center) — https://repost.aws/knowledge-center/internet-access-lambda-function
7. IAM user groups — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html
8. Create a service-linked role (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create-service-linked-role.html
9. AssumeRole (AWS STS API Reference) — https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
10. Gateway endpoints (AWS PrivateLink Guide) — https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html
11. AWS PrivateLink for Amazon S3 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/privatelink-interface-endpoints.html
12. Policies and permissions in AWS Identity and Access Management — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
13. Managed rotation for AWS Secrets Manager secrets — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_managed.html
14. Rotation strategy (AWS Secrets Manager console help) — https://docs.aws.amazon.com/help-panel/secretsmanager/latest/console/rotation-separate-creds-rds-pane.html
15. Lambda rotation functions (AWS Secrets Manager User Guide) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_lambda-functions.html
16. Network access for AWS Lambda rotation function — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotation-function-network-access.html
17. RotationRulesType (AWS Secrets Manager API Reference) — https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_RotationRulesType.html
18. Access AWS Secrets Manager secrets from a different account — https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples_cross.html
19. Defining Lambda function permissions with an execution role — https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html
20. Control access to a REST API with IAM permissions (Amazon API Gateway) — https://docs.aws.amazon.com/apigateway/latest/developerguide/permissions.html
21. Set up a method request in API Gateway — https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-settings-method-request.html
22. AWS CLI Configuration Variables (Using AWS IAM Roles) — https://docs.aws.amazon.com/cli/latest/topic/config-vars.html
23. Configuring least-privilege permissions to use CloudFormation (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/least-privilege-cloudformation/permissions-use-cloudformation.html
24. Credentials and access permissions (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/loading-data-access-permissions.html
25. Configure IAM service roles for Amazon EMR permissions — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-iam-roles.html
26. Step 2: Create an IAM role for AWS Glue — https://docs.aws.amazon.com/glue/latest/dg/create-an-iam-role.html
27. Identity-based policies and resource-based policies (IAM User Guide) — https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_identity-vs-resource.html
28. How AWS enforcement code logic evaluates requests to allow or deny access — https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic_policy-eval-denyallow.html
29. How do I troubleshoot explicit deny error messages? (AWS re:Post Knowledge Center) — https://repost.aws/knowledge-center/iam-explicit-deny-errors
30. Configuring IAM policies for using access points (Amazon S3 User Guide) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points-policies.html
31. Access points naming rules, restrictions, and limitations (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points-restrictions-limitations-naming-rules.html
32. Access control in Amazon S3 — https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-management.html
33. Shared Responsibility Model (AWS Cloud Compliance) — https://aws.amazon.com/compliance/shared-responsibility-model/
34. Understanding the security scope (AWS Prescriptive Guidance) — https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-accelerating-security-maturity/understanding-the-security-scope.html
35. What is Amazon EMR? (Amazon EMR Management Guide) — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html
36. Domains in Amazon SageMaker Unified Studio (Administrator Guide) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/working-with-domains.html
37. IAM-based domains and projects (Amazon SageMaker Unified Studio) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/iam-based-domains.html
38. Domain units and authorization policies in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/domain-units.html
39. Create domain units in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/create-domain-unit.html
40. Project profiles in Amazon SageMaker Unified Studio — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/adminguide/project-profiles.html
41. Projects (Amazon SageMaker Unified Studio User Guide) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/projects.html
42. Add project members (Amazon SageMaker Unified Studio User Guide) — https://docs.aws.amazon.com/sagemaker-unified-studio/latest/userguide/add-project-members.html
43. Using Amazon SageMaker Unified Studio Identity center (IDC) and IAM-based domains together (AWS Big Data Blog) — https://aws.amazon.com/blogs/big-data/using-amazon-sagemaker-unified-studio-identity-center-idc-and-iam-based-domains-together/
