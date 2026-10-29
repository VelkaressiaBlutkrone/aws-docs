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
  - title: KMS 키 정책 만들기(위임 문장·암시적 거부) (공식)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
  - title: KMS 키 유형(관리형·소유 키 구분·요금) (공식)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
  - title: KMS 키 저장소(FIPS 140-3 Level 3·단일 테넌트) (공식)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html
  - title: S3 서버 측 암호화(기본 암호화·DSSE-KMS·SSE-C 기본 비활성) (공식)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
  - title: ACM DNS 검증 갱신(완전 자동 갱신 조건·45일) (공식)
    url: https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html
  - title: ACM 내보내기 가능 공인 인증서(추가 요금·198일) (공식)
    url: https://docs.aws.amazon.com/acm/latest/userguide/acm-exportable-certificates.html
  - title: AWS Backup Vault Lock(grace time·ChangeableForDays) (공식)
    url: https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html
  - title: Amazon Macie란 무엇인가(머신러닝+패턴 매칭) (공식)
    url: https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
  - title: ACM 관리형 갱신 적격 조건(서비스 연결 또는 내보냄·가져온 인증서 비적격) (공식)
    url: https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
  - title: RDS Blue/Green 배포 TargetResourceConfiguration(green 암호화 TargetKmsKeyId) (공식 API)
    url: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html
lastVerified: 2026-10-28
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

## 📖 핵심 개념 {#core-concepts}

### 1) 두 암호화 구간 {#encryption-states}

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

### 2) AWS KMS (Key Management Service) {#kms}

> 공식 정의: **"데이터를 암호화·서명하는 데 사용하는 키를 생성하고 제어하기 쉽게 하는 AWS 관리형 서비스."** KMS 키는 암호화된 상태로 KMS를 절대 벗어나지 않습니다.

#### KMS 키 유형

| 키 유형 | 내 계정에 존재 | 키 정책 제어 | 자동 교체 | 비용 |
|---|---|---|---|---|
| **AWS 관리형 키** | **예**(조회·CloudTrail 감사 가능) | 변경 불가(서비스가 통제, **조회는 가능**) | **매년 필수**(약 365일) | **월 보관료 없음**, 사용 API 요금은 청구(서비스가 대신 내는 경우도 있음) |
| **고객 관리형 키 (CMK)** | 예 | 가능 (세밀 제어) | 선택적 활성화 가능 | 월 보관료 + 사용료 |
| **AWS 소유 키** | **아니요**(AWS 서비스 계정에 존재, 조회·감사 불가) | 불가 | AWS 서비스가 관리 | 요금 없음 |

> **혼동 주의**: "AWS 관리형 키"와 "AWS 소유 키"는 다릅니다. 관리형 키는 **내 계정에 있어 보이고 감사할 수 있지만** 수명 주기는 AWS가 관리하며 **다른 계정과 공유할 수 없습니다**(그래서 교차 계정 EBS 스냅샷 공유에는 CMK가 필요). 소유 키는 **서비스 계정에 있어 보이지 않습니다**. 참고로 AWS 관리형 키는 2021년 이후 새 서비스에는 더 만들어지지 않는 레거시 유형이고, 신규·기존 서비스는 기본 암호화에 AWS 소유 키를 씁니다.

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

- KMS에서 **키에 직접 붙이는 리소스 기반 정책**이며 **모든 KMS 키에 하나씩 반드시 존재**합니다. 키 정책이 **명시적으로 허용하지 않으면 접근은 암시적으로 거부**됩니다.
- `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey` 등 API 단위로 허용/거부를 제어합니다.
- **IAM 정책이 효력을 갖는 조건**: 기본 키 정책에 들어 있는 계정 주체 문장(`"Principal": {"AWS": "arn:aws:iam::<account-id>:root"}`, 콘솔 이름 `Enable IAM User Permissions`)은 **특정 주체에게 권한을 주는 것이 아니라 "이 계정의 IAM 정책으로 권한을 위임한다"는 선언**입니다. 그래서
  - 위임 문장이 **있으면** → IAM 정책만으로도 접근 가능
  - 키 정책이 주체를 **직접 허용**하면 → IAM 정책 없이도 접근 가능
  - 위임 문장도 없고 직접 허용도 없으면 → **IAM에서 Allow해도 차단**
- **교차 계정**에서만 양쪽(키 정책 + 상대 계정 IAM 정책)이 모두 필요합니다.

#### KMS와 AWS 서비스 통합

| 서비스 | 암호화 옵션 |
|---|---|
| S3 | **기본 암호화**: 2023-01-05부터 **모든 신규 업로드가 SSE-S3로 자동 암호화**(추가 비용·성능 영향 없음). 상호 배타적 네 옵션 — **SSE-S3**(S3 관리 키·기본값) · **SSE-KMS**(CMK 지정) · **DSSE-KMS**(AES-256 **이중 레이어**) · **SSE-C**(고객 제공 키). 버킷 기본값으로 지정할 수 있는 건 SSE-KMS·DSSE-KMS. **SSE-C는 2026-04부터 신규 범용 버킷에서 기본 비활성**(쓰려면 `PutBucketEncryption`으로 명시 활성화). SSE-KMS는 **S3 Bucket Key**로 KMS 호출을 줄여 비용을 낮춥니다 |
| EBS | 볼륨 생성 시 KMS CMK 지정, 스냅샷에도 동일 키 적용 |
| RDS | DB 인스턴스 생성 시 암호화 활성화. 생성 후 **in-place 전환은 불가** — 대표 경로는 **스냅샷 경유 재생성**이고, **Blue/Green 배포에서 green 리소스에 `TargetKmsKeyId`를 지정**하는 경로도 있습니다(근거 15번) |
| DynamoDB | 테이블 암호화(AWS 소유 키·AWS 관리형 키·CMK 선택) |

> 🧠 원리: 왜 KMS 키는 서비스 바깥으로 절대 내보내지 않는 설계를 채택했을까요?
> KMS 키가 메모리나 네트워크를 통해 노출되면 키를 쥔 모든 곳이 잠재적 탈취 지점이 됩니다 — KMS 자체를 신뢰 경계로 고정해야 합니다.
> Decrypt·GenerateDataKey 같은 연산을 API 호출로만 수행하면 키 물질은 KMS 내 HSM에만 존재하고, 호출자는 결과(평문 데이터 키·암호문)만 받습니다.
> 이 설계로 키 접근 이력이 CloudTrail에 자동 기록되고, 키 정책으로 어떤 주체가 어떤 API를 쓸 수 있는지 세밀하게 제어할 수 있습니다.

---

### 3) AWS CloudHSM {#cloudhsm}

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

### 4) KMS vs CloudHSM 비교 (★ 시험 핵심) {#kms-vs-cloudhsm}

| 항목 | AWS KMS | AWS CloudHSM |
|---|---|---|
| **하드웨어 소유** | 멀티테넌트 공유 (AWS 관리) | 단일 테넌트 전용 |
| **FIPS 등급** | FIPS 140-3 Level 3 (KMS 키 보호 HSM) | FIPS 140-2 또는 140-3 Level 3 (클러스터 모드 선택) |
| **키 제어** | AWS가 일부 관리 (CMK는 고객이 정책 제어) | 고객이 단독 제어 — AWS 접근 불가 |
| **AWS 서비스 통합** | S3·EBS·RDS 등 네이티브 통합 | 제한적 (KMS custom key store 경유) |
| **운영 부담** | 낮음 (완전 관리형) | 높음 (클러스터 구성·백업·사용자 관리 직접) |
| **비용** | 낮음 (API 호출 단위) | 높음 (HSM 인스턴스 시간당 과금) |
| **선택 시점** | 일반적인 저장 데이터 암호화 | 엄격한 규정·감사(단독 하드웨어 요구), PKI, 데이터베이스 암호화 오프로드 |

> **결정 규칙**: **"FIPS Level 3"만으로는 CloudHSM이 정답이 아닙니다** — KMS 표준 키 저장소의 HSM도 **FIPS 140-3 Level 3 검증**을 받았습니다. 갈림길은 **"단일 테넌트(전용) HSM" 또는 "고객이 소유·통제하는 HSM"을 규정이 명시적으로 요구하는가**입니다. 그런 요구가 있으면 CloudHSM 키 저장소(또는 외부 키 저장소), 그 외 대부분은 KMS 표준 키 저장소입니다. 공식 문서도 "사용자 지정 키 저장소가 표준보다 더 안전한 것은 아니며" 비용·운영 복잡도·성능 저하를 감수할 사유가 있을 때만 쓰라고 안내합니다.

> 🧠 원리: 왜 KMS와 CloudHSM은 같은 "키 관리" 목적이지만 AWS가 별도 서비스로 유지할까요?
> 멀티테넌트 완전 관리형 구조는 AWS가 키 운영 일부를 책임지는 신뢰 모델을 전제합니다 — 이 모델로는 "제3자 접근 불가" 감사를 원천 충족할 수 없습니다.
> 두 요건(낮은 운영 부담 대 단독 하드웨어 통제)은 아키텍처 트레이드오프가 달라 단일 서비스로 동시에 충족하기 어렵습니다.
> 두 서비스를 병용하면 CloudHSM을 KMS custom key store 백엔드로 연결해, KMS의 서비스 통합 편의를 유지하면서 전용 하드웨어 키 저장을 얻을 수 있습니다.

---

### 5) AWS Certificate Manager (ACM) — 전송 중 암호화 {#acm}

> 공식 정의: **"공인·사설 SSL/TLS X.509 인증서와 키를 생성·저장·갱신하는 복잡함을 처리하는 서비스."**

- **공인 TLS 인증서 요금**: ALB·CloudFront 같은 **통합 AWS 서비스에 붙여 쓰는 공인 인증서는 추가 요금이 없습니다**(인증서를 붙이는 리소스 비용은 별도). 단 **내보내기 가능(exportable) 공인 인증서**는 EC2·컨테이너·온프레미스 등 AWS 밖에도 배포할 수 있는 대신 **추가 요금이 붙습니다**(발급·갱신 시 과금, 요금은 공식 요금 페이지 기준).
- **자동 갱신**: **완전 자동 갱신은 처음부터 DNS 검증으로 발급한 인증서**에 해당합니다. ACM은 **만료 45일 전**에 ①인증서가 AWS 서비스에서 사용 중인지 ②ACM이 준 CNAME 레코드가 공개 DNS에 그대로 있는지를 확인해 갱신합니다(자동 검증이 실패하면 30·15·7·3·1일 전에 AWS Health·EventBridge 이벤트 발송). **이메일 검증 인증서는 소유자가 갱신 메일에 응답**해야 하므로 완전 자동이 아닙니다. 참고로 공인 인증서 유효 기간은 **198일**입니다(395일로 발급된 옛 인증서는 만료 60일 전에 갱신되고 갱신 후 198일을 받습니다).

- **관리형 갱신 적격 조건**: "AWS 서비스에서 사용 중"만이 아닙니다 — ① **ELB·CloudFront 같은 AWS 서비스에 연결**돼 있거나 ② **발급·갱신 이후 내보낸(exported) 인증서도 적격**입니다. 반대로 **가져온(imported) 인증서와 이미 만료된 인증서는 비적격**입니다. 내보낸 인증서는 ACM이 갱신해 주지만 **갱신본을 서버에 배포하는 일은 사용자 몫**입니다(근거 14번).
- **지원 통합**: ALB·NLB·CloudFront·API Gateway·Elastic Beanstalk.
- **가져온 인증서**: 외부 CA에서 발급한 인증서를 ACM으로 가져올 수 있으나, 자동 갱신은 지원되지 않습니다.

#### ACM 리전 제약 (★ 단골 출제)

| 서비스 | 인증서 필요 리전 |
|---|---|
| **Amazon CloudFront** | **반드시 us-east-1 (버지니아 북부)** |
| ALB · API Gateway | 해당 리소스와 **같은 리전** |

> CloudFront는 글로벌 엣지 서비스이지만 인증서는 us-east-1에서만 발급·연결합니다. 다른 리전에서 발급하면 CloudFront 배포에 연결할 수 없습니다.

> 🧠 원리: 왜 CloudFront에 연결하는 ACM 인증서는 반드시 us-east-1에서 발급해야 할까요?
> 공식 문서는 **us-east-1의 ACM 인증서가 CloudFront 배포에 연결되면 그 배포에 설정된 모든 지리적 위치로 배포된다**고 설명합니다. 그래서 이 리전이 CloudFront용 인증서를 요청·가져오는 유일한 위치입니다.
> ACM 인증서는 리전 리소스이고 **리전 간 복사가 되지 않습니다.** 서울 리전에서 발급한 인증서는 CloudFront 배포에 연결할 수 없고, us-east-1에서 새로 요청해야 합니다.
> 이 제약은 CloudFront만의 특수 케이스이며, ALB·API Gateway 같은 리전 서비스는 해당 리소스와 동일 리전의 인증서를 그대로 사용합니다.

---

### 6) Amazon Macie — 데이터 분류·거버넌스 {#macie}

> S3에 저장된 데이터에서 **민감정보(PII — 주민번호·신용카드·여권번호 등)를 머신러닝과 패턴 매칭으로 탐지**하는 완전 관리형 데이터 보안 서비스. 탐지 기준은 AWS가 제공하는 **관리형 데이터 식별자**(머신러닝·패턴 매칭 기반)와 내가 정의하는 **사용자 정의 데이터 식별자**(**정규식**+근접 규칙)를 함께 쓸 수 있고, 무시할 문자열은 **허용 목록**으로 걸러냅니다. "머신러닝만 쓴다"는 서술은 부정확합니다.

- S3 버킷 전체를 스캔해 민감 데이터 위치와 버킷 공개 접근 상태를 보고합니다.
- 탐지 결과는 AWS Security Hub·EventBridge로 전달해 자동화된 대응 워크플로를 구성할 수 있습니다.
- **데이터 거버넌스 관점**: 어떤 버킷에 어떤 분류의 데이터가 있는지 가시성을 확보해 규정 준수(GDPR, HIPAA 등) 증적 수집에 활용합니다.

> **Macie vs Inspector**: Macie = S3 데이터 내용(민감정보), Inspector = EC2·컨테이너·Lambda 취약점(CVE). 혼동 주의.

> 🧠 원리: 왜 Macie는 규칙 기반이 아닌 머신러닝으로 민감 데이터를 탐지할까요?
> PII는 신용카드 16자리 같은 고정 패턴도 있지만, 이름 옆 숫자가 생년월일인지 계좌번호인지는 맥락 없이 정규식으로 구별하기 어렵습니다.
> ML 모델은 공존하는 필드·문서 구조·컨텍스트를 종합해 민감도를 평가하므로, 오탐을 줄이면서 변형된 PII 패턴도 탐지할 수 있습니다.
> 규칙만 쓰면 새로운 PII 형식마다 수동 업데이트가 필요하지만, ML 모델은 재학습으로 커버리지를 확장하고 AWS가 모델을 관리합니다.

---

### 7) AWS Backup — 백업·복구·규정 준수 {#aws-backup}

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
> Compliance 모드는 모든 해제 경로를 제거해 보존 기간 내 삭제·단축이 불가능하도록 설계됩니다 — 단 **잠금 직후의 유예 시간(grace time) 안에서는** 잠금 해제·설정 변경이 가능하고, 이 유예 기간은 **내가 지정하며 최소 3일(72시간)·최대 36,500일**입니다(API `PutBackupVaultLockConfiguration`의 `ChangeableForDays`; 이 파라미터를 넣으면 Compliance 모드, 빼면 Governance 모드). 유예가 지나면 AWS조차 바꿀 수 없습니다.
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

## ⚠️ 흔한 함정 {#common-pitfalls}

1. **"CloudFront 인증서를 서울(ap-northeast-2)에서 발급했다."** → 연결 불가. CloudFront 인증서는 반드시 **us-east-1**에서 발급해야 합니다. ACM 인증서는 리전 리소스이며 CloudFront만 us-east-1을 요구하는 특수 케이스입니다.
   (원리: §5 — 공식 요구사항이다. us-east-1 인증서가 배포에 설정된 모든 지리적 위치로 배포되며, ACM 인증서는 리전 간 복사가 되지 않는다.)

2. **"운영 중인 RDS 인스턴스를 콘솔 클릭으로 암호화했다."** → 불가능. 암호화되지 않은 RDS 인스턴스는 **스냅샷 생성 → 스냅샷을 암호화 복사 → 암호화된 스냅샷에서 복원** 절차를 거쳐야 합니다.
   (원리: §2 — RDS 암호화는 인스턴스 생성 시 설정되며 이후 in-place 변경이 불가하다. 대표 경로는 스냅샷 경유 재생성이고, Blue/Green 배포에서 green 리소스에 `TargetKmsKeyId`를 지정하는 경로도 있다. 어느 쪽이든 기존 인스턴스를 그 자리에서 암호화하는 것은 아니다.)

3. **"IAM 정책에 kms 권한만 주면 CMK를 쓸 수 있다."** → 키 정책이 **계정에 권한을 위임**(`Enable IAM User Permissions`)하고 있거나 주체를 **직접 허용**해야 합니다. 둘 다 없으면 IAM에서 Allow해도 차단됩니다. 반대로 **위임 문장이 있는 기본 키 정책이라면 IAM 정책만으로도 접근이 가능**합니다 — "항상 양쪽이 필요하다"는 서술은 교차 계정에만 맞습니다.
   (원리: §2 — 키 정책이 명시 허용하지 않으면 암시적 거부이고, 계정 주체 문장은 IAM 정책으로의 위임 선언이다.)

4. **"CloudHSM은 모든 AWS 서비스와 네이티브로 통합된다."** → 틀립니다. CloudHSM은 **KMS custom key store**를 통해 일부 서비스와 통합할 수 있지만, KMS처럼 광범위한 네이티브 통합은 없습니다. 운영 복잡도와 비용도 훨씬 높습니다.
   (원리: §3 — 고객 단독 통제 구조라 AWS 서비스가 키에 직접 접근할 수 없어 KMS custom key store 경유가 필요하다.)

5. **"Macie가 EC2의 취약점을 스캔한다."** → Macie는 **S3 데이터 내용(민감정보)** 탐지 전용입니다. EC2·컨테이너 취약점은 **Inspector**의 역할입니다.
   (원리: §6 — S3 데이터 내용 분류와 CVE 취약점 스캔은 분석 대상·방법이 달라 Macie와 Inspector로 역할이 분리된다.)

6. **"AWS Backup Vault Lock은 관리자가 언제든 해제할 수 있다."** → Vault Lock을 **Compliance 모드**로 설정하면 AWS Support도 포함해 누구도 잠금을 해제할 수 없습니다. Governance 모드는 특정 권한자가 해제 가능합니다.
   (원리: §7 — 해제 경로가 남으면 루트 탈취·내부자로 잠금이 우회되므로, Compliance 모드는 쿨다운 후 모든 해제 경로를 원천 제거한다.)

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 금융 규제 기관이 "암호화 키를 전용 하드웨어에서 고객이 단독으로 통제해야 하며 FIPS 140-2 Level 3 이상 인증이 필요하다"고 요구합니다. 어떤 AWS 서비스를 선택해야 하나요?

<details><summary>정답 보기</summary>

**AWS CloudHSM**(KMS의 CloudHSM 키 저장소 포함)입니다. 다만 **이유를 정확히 짚어야 합니다**: KMS 표준 키 저장소의 HSM도 **FIPS 140-3 Level 3 검증**을 받았으므로 **FIPS 등급만으로는 CloudHSM이 필요하지 않습니다.** 이 문제의 결정 요인은 **"전용 하드웨어에서 고객이 단독 통제"** 라는 요구입니다 — KMS 표준 HSM은 테넌트 구분 없는 공용 플릿이고, CloudHSM은 **AWS 안에 있지만 고객이 소유·관리하는 단일 테넌트 HSM**을 제공합니다. 규정이 단일 테넌트 HSM이나 고객 통제 HSM을 명시적으로 요구할 때만 이 선택이 맞습니다.
</details>

**Q2.** 개발팀이 S3에 저장된 파일을 KMS CMK로 암호화하려 합니다. IAM 정책에 `kms:GenerateDataKey`와 `kms:Decrypt`를 허용했는데 접근이 거부됩니다. 왜 그럴까요?

<details><summary>정답 보기</summary>

그 **키 정책이 이 계정의 IAM 정책에 권한을 위임하지 않고 있기** 때문입니다. KMS 키는 키 정책이 명시적으로 허용하지 않으면 **암시적으로 거부**됩니다. 해결은 둘 중 하나입니다 — ① 키 정책에 계정 주체 문장(`arn:aws:iam::<account-id>:root`, 콘솔의 `Enable IAM User Permissions`)을 둬 **IAM 정책이 효력을 갖게** 하거나, ② 키 정책에서 해당 역할·사용자를 **Principal로 직접 허용**합니다. 반대로 기본 키 정책(위임 문장 포함)을 쓰는 키였다면 IAM 정책만으로도 동작했을 것입니다. "IAM과 키 정책이 **항상** 둘 다 Allow여야 한다"는 설명은 **교차 계정**에만 해당합니다.
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
5. KMS 키 정책 만들기(계정 위임 문장·명시 허용 없으면 암시적 거부) — https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
6. KMS 키 유형(관리형 키는 내 계정·조회 가능·월 보관료 없음 / 소유 키는 서비스 계정) — https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
7. KMS 키 저장소(표준 HSM도 FIPS 140-3 Level 3 검증·custom key store는 단일 테넌트) — https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html
8. S3 서버 측 암호화(2023-01-05 이후 기본 암호화·DSSE-KMS·2026-04 SSE-C 기본 비활성) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html
9. ACM DNS 검증 갱신(완전 자동은 DNS 검증·만료 45일 전 확인) — https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html
10. ACM 내보내기 가능 공인 인증서(추가 요금·유효 기간 198일) — https://docs.aws.amazon.com/acm/latest/userguide/acm-exportable-certificates.html
11. AWS Backup Vault Lock(grace time 최소 3일·ChangeableForDays) — https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html
12. Amazon Macie란 무엇인가(머신러닝 + 패턴 매칭·정규식 사용자 정의 식별자) — https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
13. SAA-C03 공식 시험 가이드 (ko) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html
14. ACM 관리형 갱신 적격 조건("ELIGIBLE if associated with another AWS service" / "**ELIGIBLE if exported since being issued or last renewed**" / "NOT ELIGIBLE if imported" / "NOT ELIGIBLE if already expired") — https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
15. RDS Blue/Green 배포 `TargetResourceConfiguration` — `TargetKmsKeyId` 는 "**The blue resource is unencrypted and you want to encrypt the green resource**" 인 경우에 지정한다 — https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html

> 📝 **2026-10-19 정정(8건)**: ① KMS 키 정책과 IAM 정책의 관계를 공식 규칙(계정 위임 문장 / 직접 허용 / 암시적 거부, 교차 계정만 양쪽 필요)으로 고쳤습니다(근거 5번). ② FIPS 결정 규칙과 자가 점검 Q1을 **단일 테넌트 요건** 기준으로 정정했습니다 — KMS 표준 HSM도 FIPS 140-3 Level 3 검증(근거 7번). ③ AWS 관리형 키와 AWS 소유 키를 구분하고 요금 표기를 바로잡았습니다(근거 6번). ④ S3 암호화에 기본 암호화·DSSE-KMS·Bucket Key·SSE-C 기본 비활성을 반영했습니다(근거 8번). ⑤⑥ ACM 요금(내보내기 가능 인증서 유료)과 자동 갱신 조건(DNS 검증·45일)을 정정했습니다(근거 9·10번). ⑦ Vault Lock 유예를 **사용자 지정 최소 3일**로 고쳤습니다(근거 11번). ⑧ Macie를 **머신러닝 + 패턴 매칭**으로 정정했습니다(근거 12번).

> 📝 **2026-10-20 정정(1건)**: §5 CloudFront 인증서 리전 제약의 「원리」에서 **컨트롤 플레인이 배포 설정을 엣지 PoP에 복제한다**는 기전 서술을 뺐습니다 — 공식 문서에서 근거를 찾지 못한 주장이었습니다(근거 3번 ACM 개요는 "us-east-1 인증서가 배포에 설정된 모든 지리적 위치로 배포된다"까지만 말합니다). 요구사항 자체(us-east-1 발급)는 공식이라 그대로 뒀습니다. 같은 날 파생 문항 15개도 2026-10-19 정정이 전파되지 않은 것을 찾아 함께 맞췄습니다(`docs/saa-review/2026-10-20-t1-5-review-sheet.md`).

> 📝 **2026-10-28 정정·보강(2건, 2차 검수 우선순위 2)**: ① §2 RDS 행과 「흔한 오해」 2번에서 **스냅샷 경유만이 전환 경로**라는 단정을 걷어내고 **Blue/Green 배포의 `TargetKmsKeyId`** 경로를 함께 적었습니다(근거 15번) — 파생 문항 `saa-t1-5-q14`의 해설에도 같은 단정이 있어 함께 고쳤습니다. ② §5 ACM 자동 갱신에 **관리형 갱신 적격 조건**을 더했습니다 — AWS 서비스 연결 **또는 발급·갱신 이후 내보냄(exported)** 이 적격이고 가져온·만료 인증서는 비적격입니다(근거 14번). 파생 문항 `saa-t1-5-q7`에 유효 기간 198일과 내보낸 인증서 적격이 빠져 있어 함께 반영했습니다.
