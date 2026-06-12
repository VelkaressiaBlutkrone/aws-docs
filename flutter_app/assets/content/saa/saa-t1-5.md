---
examGuideTaskId: saa-t1-5
certCode: SAA-C03
domain: 1
domainName: 보안 아키텍처 설계
domainWeightPct: 30
title: 데이터 보안 제어 — KMS·CloudHSM·ACM·백업·거버넌스
coversTasks:
  - "1.3"
sources:
  - title: AWS Key Management Service — 개요 (공식)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
  - title: AWS CloudHSM — 소개 (공식)
    url: https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html
  - title: AWS Certificate Manager — 개요 (공식)
    url: https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html
  - title: AWS Backup — 소개 (공식)
    url: https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html
  - title: SAA-C03 공식 시험 가이드 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
lastVerified: 2026-06-12
---

# 데이터 보안 제어 — KMS·CloudHSM·ACM·백업·거버넌스

> **커버하는 공식 Task** — SAA-C03 · 도메인 1 「보안 아키텍처 설계」(30%) · **Task 1.3 데이터 보호를 위한 보안 제어 결정** (`saa-t1-5`)
> 이 문서는 위 한 Task에 1:1로 매핑됩니다. 저장·전송 데이터 암호화, 인증서 관리, 데이터 분류, 백업·복구를 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 1.3의 Skill 항목 기반)

- [ ] **저장 데이터 vs 전송 중 데이터** — 두 암호화 구간을 구분하고 각각에 맞는 AWS 서비스를 고른다
- [ ] **KMS 키 유형 구분** — AWS 관리형 키와 고객 관리형 키(CMK)의 차이, 키 정책 제어 방식을 설명할 수 있다
- [ ] **봉투 암호화 흐름** — 데이터 키와 KMS 키의 관계를 순서대로 설명할 수 있다
- [ ] **KMS vs CloudHSM 선택 기준** — 통제 수준·FIPS 등급·비용·운영 복잡도 기준으로 선택할 수 있다
- [ ] **ACM 인증서 관리** — 자동 갱신 조건, CloudFront 인증서의 리전 제약을 안다
- [ ] **AWS Macie** — S3 민감정보(PII) 탐지 목적과 데이터 분류 거버넌스에서의 역할을 설명할 수 있다
- [ ] **AWS Backup** — 백업 플랜·교차 리전·교차 계정 백업, Vault Lock(WORM)을 설명할 수 있다

---

## 🎯 왜 중요한가

- 도메인 1(30%)은 SAA 시험 비중 1위입니다. Task 1.3은 "데이터 자체를 어떻게 보호하는가"를 묻습니다.
- 시험은 암호화 방식 선택(KMS냐 CloudHSM이냐), 인증서 리전 제약, 백업 복구 요건을 시나리오로 출제합니다.
- CLF에서 KMS를 개념 수준으로 봤다면, SAA는 **봉투 암호화·키 정책·CloudHSM 규정 조건·Vault Lock** 같은 설계 결정을 묻습니다. 두 수준의 차이를 의식하며 읽으세요.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **봉투 암호화** | Envelope Encryption | 데이터 키를 KMS 키로 다시 암호화하는 이중 래핑 방식 |
| **데이터 키** | Data Key | 실제 데이터를 암호화하는 대칭키 — KMS가 생성하고 KMS 키로 보호 |
| **CMK** | Customer Managed Key | 고객이 직접 생성·관리·정책 제어하는 KMS 키 |
| **키 정책** | Key Policy | CMK에 붙이는 리소스 기반 정책 — IAM 정책만으로는 CMK 접근 불가 |
| **HSM** | Hardware Security Module | 키 생성·저장·연산을 전용 하드웨어에서 수행하는 보안 장치 |
| **PII** | Personally Identifiable Information | 이름·주민번호·카드번호 등 개인을 식별할 수 있는 정보 |
| **WORM** | Write-Once Read-Many | 쓰기 1회 후 수정·삭제 불가를 보장하는 불변 저장 모델 |
| **SSE** | Server-Side Encryption | 서버(AWS) 측에서 저장 전 자동으로 데이터를 암호화하는 방식 |

---

## 📖 핵심 개념

### 1) 두 암호화 구간

> 암호화는 **언제(at rest / in transit)** 데이터를 보호하느냐로 먼저 구분합니다.

| 구간 | 설명 | 주요 서비스 |
|---|---|---|
| **저장 데이터 (at rest)** | S3·EBS·RDS·DynamoDB 등에 저장된 상태의 데이터 | KMS, CloudHSM |
| **전송 중 데이터 (in transit)** | 네트워크를 통해 이동 중인 데이터 (클라이언트↔서버) | TLS/HTTPS, ACM |

> 시험은 두 구간을 헷갈리게 섞어 냅니다. "저장 시 암호화 = KMS", "전송 중 암호화 = TLS + ACM"을 먼저 고정하세요.

> 🧠 원리: 왜 저장(at rest)과 전송(in transit)을 별도 구간으로 나눠 서로 다른 방식으로 보호할까요?
> 저장 암호화는 스토리지 미디어·스냅샷이 탈취됐을 때를, 전송 암호화는 네트워크 도청을 막습니다 — 위협 경로 자체가 다릅니다.
> 저장 암호화만 있으면 API 요청이 평문으로 흐를 때 중간자 공격에 노출되고, 전송 암호화만 있으면 디스크가 탈취될 때 데이터가 무방비입니다.
> 두 구간을 독립적으로 제어하면 계층별 컴플라이언스 증적을 분리해 제출할 수 있고, 한 레이어가 뚫려도 다른 레이어가 보호 체계를 유지합니다.

---

### 2) AWS KMS (Key Management Service)

> 공식 정의: **"데이터를 암호화·서명하는 데 사용하는 키를 생성하고 제어하기 쉽게 하는 AWS 관리형 서비스."** KMS 키는 암호화된 상태로 KMS를 절대 벗어나지 않습니다.

#### KMS 키 유형

| 키 유형 | 관리 주체 | 키 정책 제어 | 자동 교체 | 비용 |
|---|---|---|---|---|
| **AWS 관리형 키** | AWS | 불가 (AWS 소유) | 연 1회 자동 | 무료 |
| **고객 관리형 키 (CMK)** | 고객 | 가능 (세밀 제어) | 선택적 활성화 가능 | 유료 |
| **AWS 소유 키** | AWS | 없음 | AWS 관리 | 무료 |

> **핵심 대비**: AWS 관리형 키는 키 정책을 직접 제어할 수 없습니다. 특정 IAM 조건·서비스 제한이 필요하면 **CMK**를 만들어야 합니다.

#### 봉투 암호화 (Envelope Encryption)

KMS는 대용량 데이터를 직접 암호화하지 않습니다. 대신 **데이터 키(Data Key)**를 생성해 데이터를 암호화하고, 그 데이터 키 자체를 KMS 키로 암호화합니다.

```
1. 애플리케이션이 KMS에 GenerateDataKey 요청
2. KMS → 평문 데이터 키 + 암호화된 데이터 키 반환
3. 평문 데이터 키로 실제 데이터(S3 객체·EBS 볼륨 등) 암호화
4. 평문 데이터 키는 메모리에서 즉시 삭제
5. 암호화된 데이터 키만 데이터와 함께 저장
6. 복호화 시: 암호화된 데이터 키를 KMS로 보내 평문 복원 후 데이터 복호화
```

> 왜 봉투 암호화인가: KMS API 호출당 최대 4KB만 직접 암호화할 수 있습니다. 대용량 데이터는 데이터 키를 거쳐야 하고, KMS는 그 키를 보호하는 역할을 합니다.

#### 키 정책 (Key Policy)

- KMS에서 **키에 직접 붙이는 리소스 기반 정책**입니다. IAM 정책만으로는 CMK 접근이 불가 — 키 정책이 반드시 있어야 합니다.
- `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey` 등 API 단위로 허용/거부를 제어합니다.
- 키 정책에 IAM 아이덴티티를 Principal로 지정하면, 해당 아이덴티티의 IAM 정책과 키 정책의 **교집합**에서 접근이 허용됩니다.

#### KMS와 AWS 서비스 통합

| 서비스 | 암호화 옵션 |
|---|---|
| S3 | SSE-S3(AWS 관리), SSE-KMS(CMK 지정 가능), SSE-C(고객 제공 키) |
| EBS | 볼륨 생성 시 KMS CMK 지정, 스냅샷에도 동일 키 적용 |
| RDS | DB 인스턴스 생성 시 암호화 활성화 (생성 후 변경 불가 — 스냅샷 경유) |
| DynamoDB | 테이블 암호화(AWS 소유 키·AWS 관리형 키·CMK 선택) |

> 🧠 원리: 왜 KMS 키는 서비스 바깥으로 절대 내보내지 않는 설계를 채택했을까요?
> KMS 키가 메모리나 네트워크를 통해 노출되면 키를 쥔 모든 곳이 잠재적 탈취 지점이 됩니다 — KMS 자체를 신뢰 경계로 고정해야 합니다.
> Decrypt·GenerateDataKey 같은 연산을 API 호출로만 수행하면 키 물질은 KMS 내 HSM에만 존재하고, 호출자는 결과(평문 데이터 키·암호문)만 받습니다.
> 이 설계로 키 접근 이력이 CloudTrail에 자동 기록되고, 키 정책으로 어떤 주체가 어떤 API를 쓸 수 있는지 세밀하게 제어할 수 있습니다.

---

### 3) AWS CloudHSM

> 공식 정의: **"AWS 클라우드 내에서 고객이 완전히 제어하는 고가용성 전용 하드웨어 보안 모듈(HSM)."** AWS는 하드웨어를 제공하지만 키에는 접근할 수 없습니다.

- **전용(단일 테넌트) 하드웨어**: 멀티테넌트 공유 환경인 KMS와 달리 HSM 장치 자체가 고객 전용입니다.
- **FIPS 140-2 / 140-3 Level 3**: FIPS 클러스터 모드에서 FIPS 140-2 또는 FIPS 140-3 레벨 3 인증을 받은 HSM을 사용합니다.
- **키의 단독 통제**: AWS는 고객의 키에 접근하지 않습니다. 키를 잃으면 복구 불가 — 운영 책임이 고객에게 있습니다.
- **지원 인터페이스**: PKCS #11, JCE (Java), CNG/KSP (Windows) 등 표준 암호화 API 지원 → 온프레미스 HSM에서 마이그레이션 용이.
- **고가용성**: 클러스터 내 여러 AZ에 HSM을 배치해 HA 구성.

> 🧠 원리: 왜 CloudHSM은 AWS도 고객 키에 접근할 수 없도록 설계했을까요?
> 금융·의료·정부 규제 중 일부는 "제3자(클라우드 사업자 포함)가 키에 접근 불가"를 증명하는 단독 통제(sole control)를 요구합니다.
> AWS는 HSM 하드웨어와 물리·펌웨어를 관리하지만, HSM 내 암호화 파티션의 접근 자격증명은 고객만 초기화 시 설정해 보유합니다.
> 이 분리로 "AWS도 키를 볼 수 없다"는 사실을 감사 보고서에 명시할 수 있어, KMS로는 충족할 수 없는 독립 감사 요건을 해결합니다.

---

### 4) KMS vs CloudHSM 비교 (★ 시험 핵심)

| 항목 | AWS KMS | AWS CloudHSM |
|---|---|---|
| **하드웨어 소유** | 멀티테넌트 공유 (AWS 관리) | 단일 테넌트 전용 |
| **FIPS 등급** | FIPS 140-3 Level 3 (KMS 키 보호 HSM) | FIPS 140-2 또는 140-3 Level 3 (클러스터 모드 선택) |
| **키 제어** | AWS가 일부 관리 (CMK는 고객이 정책 제어) | 고객이 단독 제어 — AWS 접근 불가 |
| **AWS 서비스 통합** | S3·EBS·RDS 등 네이티브 통합 | 제한적 (KMS custom key store 경유) |
| **운영 부담** | 낮음 (완전 관리형) | 높음 (클러스터 구성·백업·사용자 관리 직접) |
| **비용** | 낮음 (API 호출 단위) | 높음 (HSM 인스턴스 시간당 과금) |
| **선택 시점** | 일반적인 저장 데이터 암호화 | 엄격한 규정·감사(단독 하드웨어 요구), PKI, 데이터베이스 암호화 오프로드 |

> **결정 규칙**: "전용 하드웨어", "단독 키 통제", "FIPS Level 3 감사" 키워드 → CloudHSM. 그 외 대부분 → KMS.

> 🧠 원리: 왜 KMS와 CloudHSM은 같은 "키 관리" 목적이지만 AWS가 별도 서비스로 유지할까요?
> 멀티테넌트 완전 관리형 구조는 AWS가 키 운영 일부를 책임지는 신뢰 모델을 전제합니다 — 이 모델로는 "제3자 접근 불가" 감사를 원천 충족할 수 없습니다.
> 두 요건(낮은 운영 부담 대 단독 하드웨어 통제)은 아키텍처 트레이드오프가 달라 단일 서비스로 동시에 충족하기 어렵습니다.
> 두 서비스를 병용하면 CloudHSM을 KMS custom key store 백엔드로 연결해, KMS의 서비스 통합 편의를 유지하면서 전용 하드웨어 키 저장을 얻을 수 있습니다.

---

### 5) AWS Certificate Manager (ACM) — 전송 중 암호화

> 공식 정의: **"공인·사설 SSL/TLS X.509 인증서와 키를 생성·저장·갱신하는 복잡함을 처리하는 서비스."**

- **무료 공인 TLS 인증서**: ACM이 발급하는 인증서는 추가 요금 없음. (단, 인증서를 부착하는 리소스 비용은 별도)
- **자동 갱신**: ACM이 직접 발급한 인증서는 만료 전 자동 갱신. 단, DNS 검증 또는 이메일 검증이 유효한 상태여야 합니다.
- **지원 통합**: ALB·NLB·CloudFront·API Gateway·Elastic Beanstalk.
- **가져온 인증서**: 외부 CA에서 발급한 인증서를 ACM으로 가져올 수 있으나, 자동 갱신은 지원되지 않습니다.

#### ACM 리전 제약 (★ 단골 출제)

| 서비스 | 인증서 필요 리전 |
|---|---|
| **Amazon CloudFront** | **반드시 us-east-1 (버지니아 북부)** |
| ALB · API Gateway | 해당 리소스와 **같은 리전** |

> CloudFront는 글로벌 엣지 서비스이지만 인증서는 us-east-1에서만 발급·연결합니다. 다른 리전에서 발급하면 CloudFront 배포에 연결할 수 없습니다.

> 🧠 원리: 왜 CloudFront에 연결하는 ACM 인증서는 반드시 us-east-1에서 발급해야 할까요?
> CloudFront 컨트롤 플레인은 us-east-1을 거점으로 배포 설정을 전 세계 엣지 PoP에 복제합니다 — 인증서 참조도 이 흐름 안에서 처리됩니다.
> ACM 인증서는 리전 리소스입니다. 서울 리전 인증서의 ARN은 us-east-1 컨트롤 플레인이 참조할 수 없는 다른 리전 범위에 있습니다.
> 이 제약은 CloudFront만의 특수 케이스이며, ALB·API Gateway 같은 리전 서비스는 해당 리소스와 동일 리전의 인증서를 그대로 사용합니다.

---

### 6) Amazon Macie — 데이터 분류·거버넌스

> S3에 저장된 데이터에서 **민감정보(PII — 주민번호·신용카드·여권번호 등)를 머신러닝으로 자동 탐지**하는 완전 관리형 서비스.

- S3 버킷 전체를 스캔해 민감 데이터 위치와 버킷 공개 접근 상태를 보고합니다.
- 탐지 결과는 AWS Security Hub·EventBridge로 전달해 자동화된 대응 워크플로를 구성할 수 있습니다.
- **데이터 거버넌스 관점**: 어떤 버킷에 어떤 분류의 데이터가 있는지 가시성을 확보해 규정 준수(GDPR, HIPAA 등) 증적 수집에 활용합니다.

> **Macie vs Inspector**: Macie = S3 데이터 내용(민감정보), Inspector = EC2·컨테이너·Lambda 취약점(CVE). 혼동 주의.

> 🧠 원리: 왜 Macie는 규칙 기반이 아닌 머신러닝으로 민감 데이터를 탐지할까요?
> PII는 신용카드 16자리 같은 고정 패턴도 있지만, 이름 옆 숫자가 생년월일인지 계좌번호인지는 맥락 없이 정규식으로 구별하기 어렵습니다.
> ML 모델은 공존하는 필드·문서 구조·컨텍스트를 종합해 민감도를 평가하므로, 오탐을 줄이면서 변형된 PII 패턴도 탐지할 수 있습니다.
> 규칙만 쓰면 새로운 PII 형식마다 수동 업데이트가 필요하지만, ML 모델은 재학습으로 커버리지를 확장하고 AWS가 모델을 관리합니다.

---

### 7) AWS Backup — 백업·복구·규정 준수

> 공식 정의: **"AWS 서비스 전반에 걸쳐 데이터 보호를 중앙 집중화하고 자동화하기 쉽게 하는 완전 관리형 서비스."**

#### 핵심 구성 요소

| 요소 | 설명 |
|---|---|
| **백업 플랜(Backup Plan)** | 백업 주기·보존 기간·수명 주기(콜드 스토리지 전환)를 정의하는 정책 |
| **백업 볼트(Backup Vault)** | 백업 복구 지점을 저장하는 컨테이너. KMS 키로 독립적으로 암호화됨 |
| **복구 지점(Recovery Point)** | 각 백업 작업의 스냅샷·복사본 |
| **백업 플랜 할당** | 태그 기반 또는 리소스 ARN으로 AWS 리소스에 플랜 적용 |

#### 교차 리전 백업 (Cross-Region Backup)

- 백업 플랜에서 복사 규칙을 설정하면 **다른 리전의 볼트로 자동 복사**.
- 비즈니스 연속성·컴플라이언스 요건(데이터를 프로덕션으로부터 물리적으로 격리) 충족에 사용합니다.

#### 교차 계정 백업 (Cross-Account Backup)

- AWS Organizations 구조 내에서 **다른 계정의 볼트로 백업 복사** 가능.
- 중앙 백업 계정(백업 전용)으로 "fan-in" 수집하거나 여러 계정으로 "fan-out" 배포해 복원력을 높입니다.
- Organizations 수준의 백업 정책으로 모든 계정에 플랜을 일괄 배포할 수 있습니다.

#### AWS Backup Vault Lock (WORM)

- 볼트에 **쓰기 1회·읽기 다수(Write-Once Read-Many)** 잠금을 걸어 누구도(계정 루트 포함) 백업을 삭제하거나 보존 기간을 단축하지 못하게 합니다.
- 랜섬웨어·내부자 위협으로 인한 백업 삭제를 방지하는 핵심 제어입니다.

#### 지원 리소스 (주요)

EC2·EBS·S3·RDS·Aurora·DynamoDB·EFS·FSx·EKS·DocumentDB·Neptune·Redshift 등 다수의 AWS 서비스.

> 🧠 원리: 왜 Vault Lock(Compliance 모드)은 AWS Support도 포함해 누구도 잠금을 해제할 수 없을까요?
> 랜섬웨어 시나리오에서 공격자가 루트 계정을 탈취하거나 내부자가 개입해도, 잠금 해제 경로가 남아 있으면 백업 불변성 보장이 깨집니다.
> Compliance 모드는 모든 해제 경로를 제거해 보존 기간 내 삭제·단축이 불가능하도록 설계됩니다 — 취소는 활성화 후 쿨다운(기본 3일) 내에만 가능합니다.
> 이 설계로 규제 기관이 "백업이 지정 기간 동안 변경 불가"임을 기술적으로 검증할 수 있어, 컴플라이언스 증적의 신뢰도가 높아집니다.

---

## ✍️ 시험 포인트

| 시나리오 | 정답 |
|---|---|
| 일반적인 S3·EBS·RDS 저장 데이터 암호화 | KMS (CMK 또는 AWS 관리형 키) |
| 전용 하드웨어 HSM·단독 키 통제·엄격한 감사 | CloudHSM |
| HTTPS 인증서 발급·자동 갱신 | ACM |
| CloudFront 배포에 ACM 인증서 연결 | us-east-1 에서 발급 |
| S3 버킷의 PII·민감정보 탐지 | Amazon Macie |
| EC2·Lambda 취약점(CVE) 스캔 | Amazon Inspector |
| 여러 서비스 백업을 중앙 정책으로 관리 | AWS Backup |
| 교차 리전/계정 백업 자동화 | AWS Backup (복사 규칙) |
| 백업 삭제 방지(WORM) | AWS Backup Vault Lock |
| 운영 중 RDS 암호화 전환 | 스냅샷 생성 → 암호화 복사 → 복원 (직접 활성화 불가) |

---

## ⚠️ 흔한 함정

1. **"CloudFront 인증서를 서울(ap-northeast-2)에서 발급했다."** → 연결 불가. CloudFront 인증서는 반드시 **us-east-1**에서 발급해야 합니다. ACM 인증서는 리전 리소스이며 CloudFront만 us-east-1을 요구하는 특수 케이스입니다.
   *(원리: §5 — CloudFront 컨트롤 플레인이 us-east-1 기점이라 다른 리전 ARN을 참조할 수 없다.)*

2. **"운영 중인 RDS 인스턴스를 콘솔 클릭으로 암호화했다."** → 불가능. 암호화되지 않은 RDS 인스턴스는 **스냅샷 생성 → 스냅샷을 암호화 복사 → 암호화된 스냅샷에서 복원** 절차를 거쳐야 합니다.
   *(원리: §2 — RDS 암호화는 인스턴스 생성 시 설정되며, 이후 in-place 변경이 불가해 스냅샷 경유 재생성이 유일한 경로다.)*

3. **"KMS CMK만 있으면 서비스가 자동으로 키 정책 없이 접근한다."** → IAM 정책 외에 **키 정책이 반드시 허용**해야 합니다. 키 정책에 IAM 아이덴티티가 빠지면 접근 차단됩니다.
   *(원리: §2 — CMK 접근은 IAM 정책과 키 정책의 교집합이므로, 키 정책에 주체가 없으면 IAM이 허용해도 차단된다.)*

4. **"CloudHSM은 모든 AWS 서비스와 네이티브로 통합된다."** → 틀립니다. CloudHSM은 **KMS custom key store**를 통해 일부 서비스와 통합할 수 있지만, KMS처럼 광범위한 네이티브 통합은 없습니다. 운영 복잡도와 비용도 훨씬 높습니다.
   *(원리: §3 — 고객 단독 통제 구조라 AWS 서비스가 키에 직접 접근할 수 없어 KMS custom key store 경유가 필요하다.)*

5. **"Macie가 EC2의 취약점을 스캔한다."** → Macie는 **S3 데이터 내용(민감정보)** 탐지 전용입니다. EC2·컨테이너 취약점은 **Inspector**의 역할입니다.
   *(원리: §6 — S3 데이터 내용 분류와 CVE 취약점 스캔은 분석 대상·방법이 달라 Macie와 Inspector로 역할이 분리된다.)*

6. **"AWS Backup Vault Lock은 관리자가 언제든 해제할 수 있다."** → Vault Lock을 **Compliance 모드**로 설정하면 AWS Support도 포함해 누구도 잠금을 해제할 수 없습니다. Governance 모드는 특정 권한자가 해제 가능합니다.
   *(원리: §7 — 해제 경로가 남으면 루트 탈취·내부자로 잠금이 우회되므로, Compliance 모드는 쿨다운 후 모든 해제 경로를 원천 제거한다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 금융 규제 기관이 "암호화 키를 전용 하드웨어에서 고객이 단독으로 통제해야 하며 FIPS 140-2 Level 3 이상 인증이 필요하다"고 요구합니다. 어떤 AWS 서비스를 선택해야 하나요?

<details><summary>정답 보기</summary>

**AWS CloudHSM**입니다. CloudHSM은 단일 테넌트 전용 HSM을 제공하며, FIPS 클러스터 모드에서 FIPS 140-2 또는 140-3 Level 3 인증을 받은 하드웨어를 사용합니다. AWS는 고객의 키에 접근할 수 없습니다. KMS는 멀티테넌트 환경이고 AWS 관리형이므로 "전용 하드웨어 + 단독 통제" 요건을 충족하지 못합니다.
</details>

**Q2.** 개발팀이 S3에 저장된 파일을 KMS CMK로 암호화하려 합니다. IAM 정책에 `kms:GenerateDataKey`와 `kms:Decrypt`를 허용했는데 접근이 거부됩니다. 왜 그럴까요?

<details><summary>정답 보기</summary>

KMS CMK는 **키 정책(Key Policy)**이 별도로 존재하며, IAM 정책만으로는 접근이 허용되지 않습니다. 키 정책에 해당 IAM 아이덴티티(사용자·역할)가 Principal로 명시되어 `kms:GenerateDataKey`와 `kms:Decrypt`를 허용해야 합니다. IAM 정책과 키 정책 모두 Allow 상태여야 접근이 가능합니다.
</details>

**Q3.** 회사가 CloudFront로 글로벌 웹 서비스를 운영 중입니다. 서울 리전(ap-northeast-2) ACM 인증서를 CloudFront 배포에 연결하려 했으나 목록에 나타나지 않습니다. 이유와 해결책은?

<details><summary>정답 보기</summary>

CloudFront 배포에 사용하는 ACM 인증서는 **us-east-1(버지니아 북부) 리전에서 발급**해야만 합니다. ACM 인증서는 리전 리소스이므로, 서울 리전에서 발급한 인증서는 CloudFront에 연결할 수 없습니다. us-east-1에서 동일 도메인으로 인증서를 새로 요청한 뒤 CloudFront 배포에 연결하면 됩니다.
</details>

**Q4.** 보안팀이 S3 버킷에 고객 개인정보(이름·이메일·카드 번호)가 포함된 파일이 있는지 자동으로 탐지하고 싶습니다. 가장 적합한 서비스는?

<details><summary>정답 보기</summary>

**Amazon Macie**입니다. Macie는 머신러닝을 사용해 S3 버킷을 스캔하고 PII(개인 식별 정보)를 자동 탐지합니다. Inspector는 EC2·컨테이너·Lambda의 소프트웨어 취약점(CVE)을 스캔하는 서비스로, 데이터 내용 분류에는 적합하지 않습니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (작성·대조: 2026-06-07 · 고도화 검수: 2026-06-12)

1. AWS Key Management Service — 개요 — https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
2. AWS CloudHSM — 소개 — https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html
3. AWS Certificate Manager — 개요 — https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html
4. AWS Backup — 소개 — https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html
5. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
