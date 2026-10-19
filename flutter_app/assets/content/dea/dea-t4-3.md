---
examGuideTaskId: dea-t4-3
certCode: DEA-C01
domain: 4
domainName: 데이터 보안 및 거버넌스
domainWeightPct: 18
title: 데이터 암호화·마스킹 보장 (DDM·KMS·S3 SSE·교차 계정·전송 중/전)
coversTasks:
  - "4.3"
sources:
  - title: Dynamic data masking (Amazon Redshift Database Developer Guide) (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/t_ddm.html
  - title: Considerations when using dynamic data masking (공식 문서)
    url: https://docs.aws.amazon.com/redshift/latest/dg/t_ddm-considerations.html
  - title: Detect and process sensitive data (AWS Glue Studio) (공식 문서)
    url: https://docs.aws.amazon.com/glue/latest/dg/detect-PII.html
  - title: Key policies in AWS KMS (공식 문서)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
  - title: AWS Key Management Service (KMS) FAQs (공식 문서)
    url: https://aws.amazon.com/kms/faqs/
  - title: Reducing the cost of SSE-KMS with Amazon S3 Bucket Keys (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  - title: Allowing users in other accounts to use a KMS key (공식 문서)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html
  - title: Multi-Region keys in AWS KMS (공식 문서)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html
  - title: Protecting data by using client-side encryption (Amazon S3) (공식 문서)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingClientSideEncryption.html
  - title: DEA-C01 공식 시험 가이드 도메인 4 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html
lastVerified: 2026-10-20
---

# 데이터 암호화·마스킹 보장 (DDM·KMS·S3 SSE·교차 계정·전송 중/전)

> **커버하는 공식 Task** — DEA-C01 · 도메인 4 「데이터 보안 및 거버넌스」(18%) · **Task 4.3 데이터 암호화 및 마스킹 보장** (`dea-t4-3`)
> Skill은 4개뿐이지만 **분량이 도메인 4에서 가장 큽니다.** 마스킹(4.3.1) · KMS·저장 시 암호화(4.3.2) · 교차 계정(4.3.3) · 전송 중/전(4.3.4) 네 덩이로 나눠 보세요.
> **Skill 4.3.4는 v1.1에서 개정**됐습니다 — "Enable encryption in transit" → "Enable encryption in transit **or before transit**"(전송 전 = 클라이언트 측 암호화 뉘앙스 추가).

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명할 수 있어야 합니다. (공식 시험 가이드 Task 4.3의 Skill 항목)

- [ ] **익명화·가명처리·토큰화**를 가역성으로 가른다
- [ ] **질의 시점 마스킹(DDM)과 ETL 단계 마스킹(Glue·DataBrew)** 을 구분한다
- [ ] **Redshift DDM의 적용 순서와 제약**을 설명한다
- [ ] **Macie의 역할**(탐지)과 마스킹 도구의 역할을 가른다
- [ ] **AWS 소유·AWS 관리형·고객 관리형 키**를 통제·비용·교차 계정으로 가른다
- [ ] **키 정책·IAM 정책·grant** 의 관계를 설명한다
- [ ] **자동 회전의 대상과 주기**, 회전 후 재암호화가 불필요한 이유를 안다
- [ ] **봉투 암호화와 암호화 컨텍스트**를 설명한다
- [ ] **SSE-S3·SSE-KMS·DSSE-KMS·SSE-C·클라이언트 측**을 요구사항으로 가른다
- [ ] **S3 Bucket Keys** 가 무엇을 줄이고 어디서 안 되는지 안다
- [ ] **교차 계정 암호화의 두 조건**(키 정책 + 상대 IAM 정책)을 설명한다
- [ ] **전송 중 암호화 강제 설정 이름**을 서비스별로 고른다

---

## 🎯 왜 중요한가

- 마스킹 문항은 **"언제 가리는가"** 로 갈립니다. **질의 시점(DDM)·ETL 단계(Glue·DataBrew)·접근 통제(Lake Formation)·탐지(Macie)** 는 전혀 다른 층입니다.
- 교차 계정 암호화는 거의 항상 같은 답입니다 — ⚠️ **고객 관리형 키 + 키 소유 계정의 키 정책 + 사용 계정의 IAM 정책.** **AWS 관리형 키로는 교차 계정이 불가**하다는 사실 하나로 오답 절반이 걸러집니다.
- **"IAM 권한을 줬는데 AccessDenied"** 는 KMS에서 **키 정책이 허용하지 않은 것**입니다.
- 전송 중 암호화는 **설정 이름을 묻습니다** — `aws:SecureTransport` · `require_ssl` · `ClientBroker` · `rds.force_ssl`.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **익명화** | anonymization | 개인을 식별하지 못하게 바꾸는 것(*비가역이어야 함*) |
| **가명처리** | pseudonymization | *추가 정보가 있어야만* 되돌릴 수 있게 바꾸는 것 |
| **토큰화** | tokenization | 민감 값을 *토큰화 시스템으로 원본에 매핑되는 참조값*으로 바꾸는 것 |
| **DDM** | dynamic data masking | 저장 데이터를 바꾸지 않고 *질의 시 보이는 방식*을 바꾸는 것 |
| **SSE** | server-side encryption | *서비스가 받은 뒤* 저장할 때 암호화하는 것 |
| **봉투 암호화** | envelope encryption | 데이터는 *데이터 키로*, 그 데이터 키는 *다른 키로* 암호화하는 방식 |
| **암호화 컨텍스트** | encryption context | 암호문에 묶이는 *비밀 아닌* key-value 추가 인증 데이터 |
| **grant** | grant | 서비스가 쓰는 *임시 권한 위임*(allow만, deny 불가) |
| **Bucket Keys** | S3 Bucket Keys | 버킷 수준 키로 *S3→KMS 요청 수를 줄이는* 기능 |
| **MRK** | multi-Region key | *여러 리전에 같은 키 ID·키 자료*를 둔 KMS 키 |

---

## 📖 핵심 개념

### 1) 마스킹·익명화와 수단 선택 {#masking}

법규·회사 정책 때문에 PII를 그대로 둘 수 없을 때 값을 가리거나(마스킹), 되돌릴 수 없게 바꾸거나(익명화), 추가 정보가 있어야만 되돌릴 수 있게 바꿉니다(가명처리·토큰화). 시험은 용어 정의보다 **"언제(질의 시 vs ETL 시) · 무엇으로 · 되돌릴 수 있는가"** 를 묻습니다.

- **용어** — ⚠️ **익명화는 비가역이어야 합니다.** **가명처리 데이터는 익명 데이터와 같지 않고**, 추가 정보가 있어야만 특정 정보주체에 귀속시킬 수 있으며 **그 추가 정보는 별도로 보관**해야 합니다. **토큰화**는 민감 요소를 **토큰화 시스템을 통해 원본에 매핑되는 참조값**으로 바꾸는 방식입니다.
- **문서가 드는 사례** — 프로덕션 백업을 개발·테스트 환경에 복원할 때는 내장 로직이나 **DataBrew 같은 서비스로 PII를 난독화**해야 합니다. **삭제권(잊힐 권리)은 삭제 대신 영구 마스킹(비가역)** 으로 처리할 수도 있습니다.

**Redshift 동적 데이터 마스킹(DDM)** — 질의 시점에 **사용자·역할(RBAC)별로** 민감 데이터를 다르게 보여 주며 ⚠️ **저장된 데이터는 바꾸지 않습니다.**

- 정책은 **부분/전체 redact 또는 해시**(SQL·Python·Lambda UDF)를 수행하고, ⚠️ **해시로 마스킹하면 민감 값에 접근하지 않고도 조인할 수 있습니다.** **조건부 열**을 쓰면 **셀 수준 마스킹**도 가능합니다.
- 한 열에 서로 다른 정책을 서로 다른 역할에 붙이고 **`PRIORITY`** 로 충돌을 풉니다(우선순위가 높은 정책이 적용).
- ⚠️ **정책을 붙일 수 없는 대상** — 시스템 테이블·외부 테이블·데이터셰어링 테이블·교차 DB 관계·임시 테이블·상관 쿼리.
- ⚠️ **적용 순서** — DDM은 **predicate·projection보다 먼저** 적용되므로 **마스킹된 열 값으로 필터하면 실패하거나 결과가 달라집니다.** 그리고 **RLS가 DDM보다 먼저** 적용됩니다.
- 표현식 비용은 **상수 연산 < HMAC 해시 < 외부 Lambda UDF** 순이라 단순한 표현식을 권장합니다.
- 📌 DDM 문서는 UDF를 SQL·Python·Lambda로 작성할 수 있다고 설명하지만, **Redshift는 2026-06-30 이후 Python UDF 지원을 중단**한다고 공지합니다(단계적 시행).

**ETL·준비 단계 수단**

- **Glue DataBrew** — **코드 없이** PII를 변환합니다: 대체(substitution)·셔플·**결정적/확률적 암호화**·복호화·null·삭제·마스킹·해싱. ⚠️ **되돌릴 수 없게(비가역) 또는 되돌릴 수 있게(가역) 난독화를 고를 수 있고**, **결정적 암호화는 같은 값이 같은 암호문**이 됩니다. 프로파일 잡으로 PII를 탐지합니다.
- **Glue Studio 민감 데이터 탐지(Detect PII)** — PII를 **탐지·마스킹·제거**합니다. 스캔 방식은 **"각 셀 탐지(전체 행 스캔)"** 와 **"PII 포함 필드 탐지(행 표본 스캔, 저비용)"** 2가지, 액션은 **탐지 결과 열 추가·redact·부분 redact·SHA-256 해시** 입니다. fine-grained 오버라이드로 열 포함/제외와 엔티티별 다른 액션을 줄 수 있지만 ⚠️ **같은 열에 redact와 해시를 함께 쓸 수는 없습니다.**
- **Lake Formation 데이터 필터** — Data Catalog 테이블에 권한을 줄 때 필터를 함께 지정해 **쿼리 결과에서 열·행·셀 단위로 접근을 제한**합니다(상세는 `dea-t4-2`).
- **Macie** — S3 데이터를 **머신러닝·패턴 매칭으로 스캔해 민감 데이터를 탐지하고 finding을 만듭니다.** ⚠️ **"찾기"가 Macie의 역할이고 "가리기"는 DDM·Glue·DataBrew, "접근 통제"는 Lake Formation** 입니다. (Macie 상세는 `dea-t4-5`)

| 수단 | 적용 시점 | 방식 | 제약·특이점 | 시험 단서 |
|---|---|---|---|---|
| **Redshift DDM** | **질의 시, 저장 데이터 불변** | 사용자·역할별 정책(redact·해시), 조건부 열(셀), `PRIORITY` | 외부·데이터셰어링 테이블 등에 **연결 불가**, **predicate보다 먼저 적용** | "원본은 그대로, 역할별로 다른 값" |
| **Lake Formation 데이터 필터** | 쿼리 결과 | **열·행·셀 접근 제한** | 테이블 권한 부여 시 지정 | "특정 열 숨김", "리전별 행만" |
| **Glue Studio Detect PII** | **ETL 단계** | 탐지 후 redact·부분 redact·**SHA-256 해시** | **같은 열에 redact+해시 불가** | "파이프라인에서 PII 자동 탐지 후 마스킹" |
| **Glue DataBrew** | 데이터 준비(노코드) | 대체·셔플·**결정적/확률적 암호화**·마스킹·해시 | 암호화 방식은 **복호화 가능(가역)** | "코드 없이 PII 변환" |
| **Macie** | S3 데이터 **탐지** | ML·패턴 매칭, **finding 생성** | 가리기·통제는 하지 않음 | "S3 어디에 PII가 있는가" |

> ⚠️ **솔트(salt)의 일반 정의는 AWS 공식 문서에서 확인되지 않았습니다.** 공식 문서에서 확인된 것은 Redshift 마스킹 정책 예제가 해시 입력에 문자열을 덧붙인다는 사실(`sha2(credit_card + 'testSalt', 256)`)뿐입니다.

### 2) KMS 키 유형과 접근 제어 {#kms-keys}

AWS 서비스의 저장 시 암호화는 대부분 KMS 키로 동작합니다. 시험은 **키 유형에 따라 통제·비용·교차 계정·회전이 갈리는 지점**을 묻습니다.

| 구분 | 소유·관리 | 비용 | **계정 간 사용** | 회전 |
|---|---|---|---|---|
| **AWS 소유 키** | AWS 서비스가 소유·관리하며 **여러 계정이 사용** | **무료** | — | 키를 소유한 **서비스가 관리** |
| **AWS 관리형 키** | **내 계정에 만들어지지만 AWS 서비스만 사용**, 수명주기는 AWS가 관리 | 월 요금 없음 | ⚠️ **불가** | ⚠️ **매년 자동, 사용자가 켜고 끌 수 없음** |
| **고객 관리형 키** | **수명주기 전체를 내가 통제** | 월 요금 + 사용료 | ✅ **키 정책으로 허용 가능** | 선택(자동/온디맨드) |

- **접근 제어 3종** — ⚠️ **모든 KMS 키는 키 정책을 정확히 하나 가지며 키 정책이 접근 제어의 기본 수단**입니다. ⚠️ **키 정책이 허용하지 않으면 IAM 정책의 allow는 효력이 없고**, IAM 정책과 달리 **키 정책은 리전별**로 적용됩니다. **grant** 는 키 정책·IAM 정책과 함께 평가되며 **AWS 서비스가 사용자 대신 만들고 쓰고 폐기하는 임시 권한 위임**에 흔히 쓰이고, ⚠️ **하나의 grant는 정확히 하나의 KMS 키에 대한 allow만 가능합니다(deny 불가).**

### 3) 키 회전·봉투 암호화·암호화 컨텍스트 {#kms-rotation}

- **자동 회전 규칙** — ⚠️ **대칭 암호화 KMS 키에서만 지원**합니다. **비대칭 키·HMAC 키·가져온 키 자료·사용자 지정 키 스토어 키는 자동 회전 불가**입니다. 기본 주기는 활성화 시점부터 **1년(약 365일)** 이고 **90~2560일(7년)** 범위에서 지정할 수 있으며, **온디맨드 회전은 키당 평생 10회**까지입니다.
- ⚠️ **회전해도 이전 키 버전이 유지되므로 데이터를 다시 암호화할 필요가 없습니다.**
- **AWS 관리형 키는 항상 매년 회전하고 사용자가 켜고 끌 수 없으며**(2022년 5월에 약 3년 → 약 1년으로 변경), **AWS 소유 키의 회전은 소유 서비스가 관리**합니다.
- **봉투 암호화·데이터 키** — KMS는 **최대 4 KB 데이터를 직접 암호화**할 수 있지만, 봉투 암호화는 **작은 데이터 키만 네트워크로 오가므로 성능 이점**이 큽니다. 봉투 암호화는 **평문 데이터를 데이터 키로 암호화한 뒤 그 데이터 키를 다른 키로 암호화**하는 방식이며, 암호화된 데이터 키는 **암호화된 데이터 옆에 안전하게 저장**할 수 있습니다.
- **암호화 컨텍스트** — ⚠️ **비밀이 아닌** key-value 쌍으로 **추가 인증 데이터(AAD)** 로 쓰이며 암호문에 암호학적으로 바인딩되어 **복호화 때 같은 컨텍스트가 필요**합니다. ⚠️ **암호화되지 않고 CloudTrail 로그에 평문으로 남으므로 민감 정보를 넣지 않습니다.**
- **요청 한도(스로틀링)** — 대칭 키 암호화 연산(`Encrypt`/`Decrypt`/`GenerateDataKey` 등)은 **계정·리전 단위로 쿼터를 공유**하고 **기본값은 리전별로 다르며**, 모든 KMS 요청 쿼터는 **조정 가능**합니다(CloudHSM 키 스토어 제외). ⚠️ **S3 SSE-KMS 업로드·다운로드처럼 AWS 서비스가 대신 보내는 요청도 쿼터를 소비**합니다. **AWS 소유 키 사용은 산입되지 않고 교차 계정 요청은 호출한 계정이 스로틀**됩니다.
  - **대응** — **S3 Bucket Keys** 로 KMS 요청 비용을 **최대 99%** 줄이고, `GenerateDataKey` 한도가 문제면 **AWS Encryption SDK의 data key caching** 으로 호출 빈도를 줄입니다.

### 4) S3 서버 측 암호화 선택 {#s3-encryption}

- ⚠️ **모든 신규 객체는 기본으로 SSE-S3로 암호화**됩니다(2023-01-05~). **SSE-KMS는 키 사용 권한이 분리되고 누가 언제 어떤 객체에 키를 썼는지 감사 추적이 가능**합니다.
- ⚠️ **SSE-KMS 업로드는 `kms:GenerateDataKey` 가, 멀티파트 업로드는 `kms:Decrypt` 까지 필요**합니다. (대용량 업로드 AccessDenied의 단골 원인)
- **S3 Bucket Keys** — SSE-KMS 비용·한도 대책이며 **버킷 수준 키로 S3→KMS 요청을 줄입니다.** ⚠️ **DSSE-KMS는 Bucket Keys를 지원하지 않습니다.**
- **SSE-C** — S3가 암·복호화를 하되 **키는 고객이 요청마다 제공**합니다. **2026-04부터 신규 범용 버킷(및 SSE-C 객체가 없는 기존 버킷)에서 기본 비활성**이고, ⚠️ **EMR에서는 SSE-C를 쓸 수 없습니다.**

| 옵션 | 키 관리 | 핵심 특징 | 제약·최신 변경 | 시험 단서 |
|---|---|---|---|---|
| **SSE-S3** | S3가 키 관리·보호 | **2023-01-05부터 신규 업로드의 기본 암호화** | KMS 권한·감사 추적 이점은 없음 | "키 관리 부담 없는 기본 암호화" |
| **SSE-KMS** | KMS(고객 관리형 또는 `aws/s3`) | **별도 키 권한 + 사용 감사 추적** | 업로드 `GenerateDataKey`, **멀티파트는 `Decrypt` 도**; 비용·한도 → **Bucket Keys** | "키 사용 감사", "KMS 키 권한 분리" |
| **DSSE-KMS** | KMS | 서로 다른 AES-256-GCM 구현의 **2계층 암호화** | ⚠️ **Bucket Keys 미지원** | "두 겹 암호화 규제 요구" |
| **SSE-C** | 고객(**요청마다 키 전달**) | S3가 암·복호화 수행 | **신규 버킷 기본 비활성**, **EMR 불가** | "자체 키 유지, 클라이언트 라이브러리는 싫음" |
| **클라이언트 측(S3 Encryption Client)** | 고객 | ⚠️ **S3는 암호화에 관여하지 않음** | **Bucket Keys와 상호작용하지 않음** | "전송 전에 암호화" |

### 5) 분석 서비스별 저장 시 암호화 {#service-encryption}

| 서비스 | 기본·선택지 | 제약·특이점 |
|---|---|---|
| **Redshift(프로비저닝)** | KMS 사용 시 **4단계 키 계층**(루트 키·CEK·DEK·데이터 암호화 키). 기본은 자동 생성된 **AWS 소유 키**를 루트 키로, 고객 관리형 키를 고르면 **생성·회전·비활성·접근 제어·감사 가능** | 다른 계정의 KMS 키를 쓰려면 **사용 권한과 키 ARN 지정** 필요 |
| **Redshift Serverless** | **KMS 키 암호화를 자동 적용**(리소스와 스냅샷) | namespace의 KMS 키를 **바꿀 수 있고 데이터는 그대로** |
| **DynamoDB** | ⚠️ **모든 테이블이 항상 암호화되며 켜고 끄는 옵션이 없음.** 기본은 AWS 소유 키, AWS 관리형/고객 관리형 선택 가능 | **인덱스를 포함한 모든 테이블 데이터**를 암호화 |
| **Kinesis Data Streams** | KMS 서버 측 암호화 | ⚠️ **활성화 이후 들어오는 데이터만 암호화** |
| **EMR** | **보안 구성**으로 설정: EMRFS-S3(SSE-S3·SSE-KMS·CSE), 로컬 디스크(HDFS 암호화·LUKS·EBS 암호화) | ⚠️ **SSE-C 불가**, EBS 암호화는 KMS 키 공급자일 때만; **S3 CSE는 EMRFS 데이터만** 암호화 |
| **Glue** | **보안 구성**으로 S3 타깃·CloudWatch Logs·잡 북마크 암호화 | ⚠️ **보안 구성이 잡 파라미터의 SSE-S3 설정을 덮어씀** |

### 6) 계정 경계 간 암호화 {#cross-account}

핵심 규칙은 하나입니다 — ⚠️ **키 소유 계정의 키 정책(허용 범위) + 사용 계정의 IAM 정책(위임) 둘 다 필요.**

- **KMS 교차 계정** — **키 정책이 외부 계정에 허용할 권한의 범위를 정하고**, 외부 계정의 사용자·역할은 **IAM 정책(또는 grant)이 있어야** 키를 쓸 수 있습니다.
- ⚠️ **키 유형 제약** — 교차 계정으로 공유할 리소스의 키는 **고객 관리형 키여야** 합니다. S3 SSE-KMS는 교차 계정 접근을 주려면 고객 관리형 키를 쓰고, **교차 계정 복제도 대상 계정의 고객 관리형 키를 지정**해야 합니다(**AWS 관리형 키는 교차 계정 사용 불가**). Kinesis 스트림이 AWS 관리형 키였다면 리소스 정책으로 공유하려면 **고객 관리형 키로 바꾸고 키 정책과 외부 계정 IAM 정책 양쪽에** 권한을 줘야 합니다.
- ⚠️ **키 별칭 대신 정규화된 키 ARN** — 별칭을 쓰면 **KMS가 요청자 계정에서 키를 해석**하므로 정규화된 키 ARN을 권장합니다.
- **S3 복제** — ⚠️ **기본적으로 SSE-KMS/DSSE-KMS 객체는 복제되지 않으므로** 복제 규칙에서 **명시적으로 opt-in** 하고 **대상 리전의 KMS 키를 지정**합니다. 대량의 KMS 암호화 객체가 CRR로 들어오면 **KMS 쿼터 스로틀링**이 날 수 있고, 교차 계정 요청의 쿼터는 **호출한 계정에서 소비**됩니다.
- **Redshift 스냅샷 공유** — 암호화 스냅샷을 공유하려면 **스냅샷 생성에 쓴 고객 관리형 키를 복원하는 계정과 공유**해야 하며, 공유하지 않으면 **복원 시 access-denied 오류**가 납니다.
- **Lake Formation** — 다른 계정(B)의 KMS 암호화 S3 위치를 계정 A의 **사용자 정의 역할**로 등록하려면 A의 역할에 B 버킷 권한이, B의 버킷 정책에 A 역할 허용이 있어야 하고, 키가 B에 있으면 **키 정책이 A 역할에 접근을 허용**해야 합니다. ⚠️ **서비스 연결 역할로는 다른 계정의 위치를 등록할 수 없습니다.** ⚠️ **등록 역할이 키 권한을 가지므로 ETL·Athena로 데이터에 접근하는 주체에게 키 권한을 따로 주지 않아도 됩니다.** 고객 관리형·AWS 관리형 키를 지원하고 **클라이언트 측 암호화는 지원하지 않습니다.**
- **다중 리전 키(MRK)** — 같은 **키 ID·키 자료**를 가진 키를 여러 리전에 두어 **한 리전에서 암호화하고 다른 리전에서 재암호화나 교차 리전 호출 없이 복호화**할 수 있습니다. ⚠️ **각 키의 별칭·키 정책·grant는 독립적으로 관리**하며, ⚠️ **기존 단일 리전 키를 MRK로 바꿀 수 없습니다.** 대부분의 AWS 서비스는 MRK를 **단일 리전 키처럼 취급**하고(S3 CRR은 대상 리전 키로 데이터 키를 복호화 후 재암호화), **AWS 관리형 키는 항상 단일 리전 키**입니다.

### 7) 전송 중 암호화 {#in-transit}

전송 중 암호화는 TLS/SSL로 네트워크 구간을 보호합니다. **서비스마다 "강제하는 방법"이 달라 시험은 그 설정 이름을 묻습니다.**

| 대상 | 강제·기본 동작 | 설정 키워드 |
|---|---|---|
| **S3** | 버킷 정책으로 **HTTP 요청을 명시적 Deny** | **`aws:SecureTransport` = false** 조건 |
| **Redshift** | **2025-01-10 이후 신규·복원 클러스터와 서버리스 워크그룹은 SSL 기본 강제**, 기존·사용자 지정 파라미터 그룹은 지정 값 유지 | **`require_ssl`** 파라미터 |
| **MSK** | **브로커 간 TLS(1.2) 기본**, 클라이언트-브로커는 **TLS만(기본)/TLS+평문/평문** 중 선택 | **`ClientBroker`**: TLS, TLS_PLAINTEXT, PLAINTEXT |
| **RDS PostgreSQL** | `rds.force_ssl=1` 이면 SSL 강제. **v15 이상 기본 1 · v14 이하 기본 0** | **`rds.force_ssl`** |
| **Kinesis Data Streams** | **SSL 엔드포인트(HTTPS)** 로 put/get | HTTPS 엔드포인트 |
| **EMR** | ⚠️ **EMRFS↔S3 구간은 S3 암호화 설정과 무관하게 TLS**; 클러스터 노드 간 암호화는 보안 구성의 in-transit 설정 | 보안 구성 |

- MSK는 전송 중 암호화를 켜면 **CPU 오버헤드와 수 밀리초 지연**이 추가될 수 있다고 안내합니다.
- **리전 간 이동** — AWS 글로벌 네트워크로 리전 사이를 오가는 데이터는 **AWS가 물리 계층에서 자동으로 암호화**합니다.

### 8) 전송 전(클라이언트 측) 암호화 {#before-transit}

> 📌 **v1.1 개정(Skill 4.3.4)** — "or **before transit**"이 추가됐습니다. ⚠️ **"before transit"이라는 표현 자체는 AWS 공식 문서에서 찾지 못했습니다.** 가장 가까운 공식 설명은 AWS 보안 블로그의 **"Pre-encryption of data to be sent to AWS"** 절로, 기업 네트워크의 애플리케이션에서 **데이터를 AWS로 보내기 전에 암호화하는 것(클라이언트 측 암호화)** 을 말합니다.

- 문서들도 **클라이언트 측 암호화**를 **데이터를 보내기 전에 로컬에서 암호화**하는 것으로 설명합니다 — S3(객체를 보내기 전에 S3 Encryption Client로), DynamoDB(테이블 데이터를 데이터베이스로 보내기 전에), Kinesis(스트림에 넣기 전에), EMRFS CSE(업로드 전에).
- ⚠️ **서비스는 암호화에 관여하지 않습니다** — S3 Encryption Client로 암호화한 객체는 **AWS를 포함한 제3자에게 노출되지 않으며 S3는 암·복호화에 관여하지 않습니다.** ⚠️ **S3는 이런 객체를 암호화된 객체로 인식하지 못하고 일반 객체로만 봅니다.**
- **도구** — **AWS Encryption SDK** 는 클라이언트 측 **봉투 암호화 라이브러리**를 제공하고 KMS와 연동합니다. **Amazon S3 Encryption Client** 는 `PutObject`/`GetObject` 때 자동으로 암·복호화합니다. DynamoDB는 **AWS Database Encryption SDK** 로 클라이언트 측 암호화를 합니다.
- **제약** — ⚠️ S3 Encryption Client는 KMS 키를 래핑 키로 지정해도 **Bucket Keys를 쓰지 않습니다.** **Lake Formation에 등록한 위치는 클라이언트 측 암호화를 지원하지 않습니다.** EMR의 S3 CSE는 **EMRFS로 주고받는 데이터만** 암호화하며 클러스터 볼륨 전체를 암호화하지 않습니다.

---

## ✍️ 시험 포인트

1. **"원본은 그대로, 역할마다 다른 값"** → **Redshift DDM**(`PRIORITY` 로 충돌 해소). **"파이프라인에서 PII를 제거/해시한 뒤 적재"** → **Glue Detect PII·DataBrew**. **"S3에서 PII가 어디 있는지"** → **Macie**.
2. **"키 사용 감사 + 대량 접근으로 KMS 비용·스로틀링 증가"** → **SSE-KMS + S3 Bucket Keys**(최대 99% 절감). ⚠️ **DSSE-KMS는 Bucket Keys 미지원**입니다.
3. **멀티파트 업로드 AccessDenied** → **`kms:Decrypt` 누락**이 단서입니다.
4. **교차 계정은 늘 같은 답** → **고객 관리형 키 + 키 정책에서 외부 계정 허용 + 상대 계정 IAM 정책.** **AWS 관리형 키는 불가**하고, **IAM 정책만으로는 키 정책 허용 없이 효력이 없습니다.**
5. **"교차 계정인데 객체를 못 읽음"** → **키 별칭을 썼기 때문**일 수 있습니다(요청자 계정에서 해석). **정규화된 키 ARN**을 씁니다.
6. **"회전 후 기존 데이터를 다시 암호화해야 하나"** → **아닙니다.** 이전 키 버전이 유지됩니다.
7. **"비대칭/HMAC 키 자동 회전"** → **불가**합니다. 자동 회전은 **대칭 암호화 키만**입니다.
8. **"AWS도 평문을 못 보게 / 보내기 전에 암호화"** → **클라이언트 측 암호화**(AWS Encryption SDK·S3 Encryption Client). **SSE나 TLS만으로는 충족되지 않습니다.**
9. **전송 중 강제는 설정 이름으로** → S3 **`aws:SecureTransport`=false Deny**, Redshift **`require_ssl`**, MSK **`ClientBroker=TLS`**, RDS PostgreSQL **`rds.force_ssl`**.
10. **"Kinesis SSE를 켰는데 기존 레코드도 암호화되나"** → **아닙니다.** 활성화 이후 데이터만입니다.
11. **"암호화 컨텍스트에 비밀번호를 넣자"** → **오답**입니다. 컨텍스트는 **비밀이 아니고 CloudTrail에 평문**으로 남습니다.

---

## ⚠️ 흔한 함정

1. **가명처리를 익명화와 같다고 생각** — **익명화는 비가역**이어야 하고, 가명처리는 **추가 정보로 되돌릴 수 있습니다.**
2. **DDM이 저장 데이터를 바꾼다고 생각** — **바꾸지 않습니다.** 질의 시점 표시만 바꿉니다.
3. **마스킹된 열 값으로 필터** — ⚠️ **DDM은 predicate보다 먼저 적용**되므로 실패하거나 결과가 달라집니다.
4. **DDM과 RLS의 적용 순서를 반대로 외움** — **RLS가 DDM보다 먼저** 적용됩니다.
5. **외부 테이블·데이터셰어링 테이블에 DDM 정책을 붙이려 함** — **붙일 수 없습니다.**
6. **해시 마스킹으로는 조인을 못 한다고 생각** — ⚠️ **해시로 마스킹하면 민감 값에 접근하지 않고도 조인할 수 있습니다.**
7. **같은 열에 redact와 해시를 함께 적용(Glue Detect PII)** — **불가**합니다.
8. **DataBrew의 암호화를 비가역으로 생각** — **결정적/확률적 암호화는 복호화 가능(가역)** 입니다. 비가역은 해싱·마스킹 쪽입니다.
9. **Macie로 마스킹·접근 통제를 기대** — Macie는 **탐지·finding 생성**입니다.
10. **AWS 관리형 키로 교차 계정 공유** — ⚠️ **불가**합니다. 고객 관리형 키입니다.
11. **IAM 정책만 주고 키 정책을 생략** — ⚠️ **키 정책이 허용하지 않으면 IAM allow는 효력이 없습니다.**
12. **키 정책이 전역이라고 생각** — IAM 정책은 전역이지만 **키 정책은 리전별**입니다.
13. **grant로 거부(deny)를 걸려 함** — grant는 **allow만**이며 **하나의 KMS 키에 대해서만** 가능합니다.
14. **AWS 관리형 키의 회전을 끄려 함** — ⚠️ **사용자가 켜고 끌 수 없습니다**(항상 매년).
15. **KMS로 대용량 객체를 직접 암호화** — 직접 암호화는 **최대 4 KB**입니다. 큰 데이터는 **봉투 암호화**입니다.
16. **암호화 컨텍스트를 비밀 저장소로 사용** — **평문으로 CloudTrail에 남습니다.**
17. **AWS 서비스가 대신 보내는 KMS 요청은 쿼터에 안 든다고 생각** — ⚠️ **S3 SSE-KMS 업로드·다운로드도 쿼터를 소비**합니다.
18. **DSSE-KMS로 Bucket Keys 비용 절감을 기대** — ⚠️ **미지원**입니다.
19. **클라이언트 측 암호화가 Bucket Keys를 쓴다고 생각** — **쓰지 않습니다.**
20. **EMR에서 SSE-C를 쓰려 함** — ⚠️ **쓸 수 없습니다.**
21. **S3 CSE가 EMR 클러스터 전체를 암호화한다고 생각** — **EMRFS 데이터만**이며 로컬 볼륨은 별도 로컬 디스크 암호화입니다.
22. **DynamoDB 암호화를 끌 수 있다고 생각** — ⚠️ **항상 암호화되며 켜고 끄는 옵션이 없습니다.**
23. **Glue 잡 파라미터의 SSE-S3 설정이 보안 구성을 이긴다고 생각** — ⚠️ **보안 구성이 덮어씁니다.**
24. **SSE-KMS 객체가 기본으로 복제된다고 생각** — ⚠️ **기본적으로 복제되지 않아** 명시적 opt-in과 대상 리전 키 지정이 필요합니다.
25. **Redshift 암호화 스냅샷을 키 공유 없이 복원** — **access-denied** 가 납니다.
26. **Lake Formation 등록 위치에 클라이언트 측 암호화를 쓰려 함** — **지원하지 않습니다.**
27. **서비스 연결 역할로 다른 계정의 S3 위치를 등록** — **불가**합니다. 사용자 정의 역할입니다.
28. **MRK의 키 정책이 복제된다고 생각** — **별칭·키 정책·grant는 독립**입니다. 또 **기존 단일 리전 키는 MRK로 변환 불가**입니다.
29. **TLS만으로 "AWS도 평문 접근 불가"를 충족한다고 생각** — **클라이언트 측 암호화**가 필요합니다.
30. **Kinesis SSE가 과거 데이터까지 암호화한다고 생각** — **활성화 이후 데이터만**입니다.

---

## 🧪 자가 점검

**Q1.** Amazon Redshift의 분석가는 신용카드 번호를 가려진 값으로 보고, 감사자는 원문을 보아야 한다. 저장된 데이터는 바꿀 수 없다. 가장 적합한 구성은?

<details><summary>정답 보기</summary>

**동적 데이터 마스킹(DDM) 정책을 두 역할에 각각 연결하고, 같은 열에 여러 정책이 걸리면 `PRIORITY` 로 충돌을 해소합니다.** DDM은 **저장 데이터를 바꾸지 않고 쿼리 시점에 사용자·역할별로 보이는 방식을 바꿉니다.** Lake Formation 데이터 필터는 **열·행·셀 접근을 제한**할 뿐 값을 가려 보여 주는 용도가 아니고, Glue Detect PII·DataBrew는 **ETL/준비 단계에서 변환**하므로 "질의 시점·원본 유지" 요구와 어긋납니다.
</details>

**Q2.** 대량의 객체가 SSE-KMS로 암호화된 S3 버킷에 분석 워크로드가 집중 접근하면서 KMS 요청 비용과 스로틀링이 문제가 되고 있다. 키 사용 감사와 키 권한 분리는 유지해야 한다. 어떻게 하는가?

<details><summary>정답 보기</summary>

**SSE-KMS를 유지하면서 S3 Bucket Keys를 활성화합니다.** Bucket Keys는 **버킷 수준 키로 S3→KMS 요청을 줄여 KMS 요청 비용을 최대 99% 절감**합니다. SSE-S3로 바꾸면 **KMS 키 권한·감사 추적 이점을 잃고**, DSSE-KMS는 ⚠️ **Bucket Keys를 지원하지 않아** 비용이 더 늘며, SSE-C는 **요청마다 키를 제공**해야 하고 2026-04부터 신규 버킷에서 기본 비활성입니다.
</details>

**Q3.** 계정 B의 분석 팀이 계정 A의 SSE-KMS 암호화 S3 객체를 읽어야 한다. 무엇이 필요한가?

<details><summary>정답 보기</summary>

**고객 관리형 키를 쓰고, 계정 A의 키 정책에서 계정 B에 권한을 허용하며, 계정 B의 IAM 정책에서도 그 키 사용을 위임합니다**(버킷 정책·ID 기반 정책도 교차 계정이므로 양쪽 필요). ⚠️ **AWS 관리형 키는 교차 계정 사용이 불가**하고, **키 정책이 허용하지 않으면 IAM allow는 효력이 없습니다.** 또 **키 별칭을 쓰면 요청자 계정에서 해석**되므로 **정규화된 키 ARN**을 지정합니다.
</details>

**Q4.** 규제 기관이 "AWS도 평문 데이터를 볼 수 없어야 한다"고 요구한다. 데이터는 S3에 적재된다. 어떻게 하는가?

<details><summary>정답 보기</summary>

**클라이언트 측 암호화를 적용합니다**(AWS Encryption SDK 또는 Amazon S3 Encryption Client로 **보내기 전에 로컬에서 암호화**). S3 Encryption Client로 암호화한 객체는 **AWS를 포함한 제3자에게 노출되지 않으며 S3는 암·복호화에 관여하지 않습니다**(S3는 일반 객체로만 인식). **서버 측 암호화(SSE)나 TLS만으로는 충족되지 않습니다** — SSE는 서비스가 받은 뒤 암호화하고 TLS는 전송 구간만 보호합니다. 단 이 객체에는 **Bucket Keys가 적용되지 않고 Lake Formation 등록 위치는 클라이언트 측 암호화를 지원하지 않습니다.**
</details>

**Q5.** 보안 팀이 S3 버킷에 대한 모든 HTTP(비암호화) 요청을 차단하라고 요구한다. 어떻게 하는가?

<details><summary>정답 보기</summary>

**버킷 정책에서 `aws:SecureTransport` 조건이 `false` 인 요청을 명시적으로 Deny합니다.** 이것은 **전송 중 암호화 강제**이며 저장 시 암호화(SSE-KMS·Bucket Keys)와는 다른 층입니다. 서비스마다 강제 수단 이름이 다릅니다 — Redshift는 **`require_ssl`**, MSK는 **`ClientBroker=TLS`**, RDS PostgreSQL은 **`rds.force_ssl`** 입니다.
</details>

---

**Q6 (원리).** 왜 암호화 문항은 거의 항상 "키를 누가 통제하는가"로 환원될까요?

<details><summary>정답 보기</summary>

**암호화의 보안 경계가 알고리즘이 아니라 키에 대한 통제권에 있기 때문입니다.** AES-256은 어느 옵션에서나 같으므로, 옵션을 가르는 것은 **키의 수명주기를 누가 쥐는가**입니다 — AWS 소유 키는 내가 볼 수도 없고(그래서 무료·교차 계정 논의가 성립하지 않음), AWS 관리형 키는 내 계정에 있지만 **정책·회전을 바꿀 수 없어 교차 계정이 불가**하고, 고객 관리형 키만 **키 정책·회전·감사**를 내가 쥐므로 **교차 계정 공유와 "누가 언제 키를 썼는가"** 가 가능해집니다. 같은 논리가 클라이언트 측 암호화까지 이어집니다 — 키를 내 쪽에만 두면 **AWS도 평문을 볼 수 없다**는 요구를 충족하지만, 대가로 S3가 객체를 암호화된 것으로 인식하지 못해 **Bucket Keys·Lake Formation 등록 같은 서비스 기능을 잃습니다.** 그래서 문항의 요구사항을 **"통제권을 어디까지 가져와야 하는가"** 로 바꿔 읽으면 선택지가 한 줄로 정렬됩니다.
</details>

---

### 📌 출처

이 문서의 사실 진술은 아래 공식 자료로 대조했습니다. (수집·대조: 2026-10-17 · 저작: 2026-10-20 · 사람 검수 전)

1. Best practice 3.1 – Privacy by Design (Data Analytics Lens, Well-Architected) — https://docs.aws.amazon.com/wellarchitected/latest/analytics-lens/best-practice-3.1-privacy-by-design..html
2. Dynamic data masking (Amazon Redshift Database Developer Guide) — https://docs.aws.amazon.com/redshift/latest/dg/t_ddm.html
3. Considerations when using dynamic data masking — https://docs.aws.amazon.com/redshift/latest/dg/t_ddm-considerations.html
4. SQL commands for managing dynamic data masking policies — https://docs.aws.amazon.com/redshift/latest/dg/r_ddm-procedures.html
5. Identifying and handling personally identifiable information (PII) (AWS Glue DataBrew) — https://docs.aws.amazon.com/databrew/latest/dg/personal-information-protection.html
6. Detect and process sensitive data (AWS Glue Studio) — https://docs.aws.amazon.com/glue/latest/dg/detect-PII.html
7. Data filtering and cell-level security in Lake Formation — https://docs.aws.amazon.com/lake-formation/latest/dg/data-filtering.html
8. What is Amazon Macie? — https://docs.aws.amazon.com/macie/latest/user/what-is-macie.html
9. Implementation – Cost, convenience, and control (Strategy for data at-rest encryption) — https://docs.aws.amazon.com/prescriptive-guidance/latest/strategy-data-at-rest-encryption/implementation.html
10. enable_key_rotation (AWS SDK for Python Boto3 KMS API reference) — https://docs.aws.amazon.com/boto3/latest/reference/services/kms/client/enable_key_rotation.html
11. AWS Key Management Service (KMS) FAQs — https://aws.amazon.com/kms/faqs/
12. Key policies in AWS KMS — https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
13. Grants in AWS KMS — https://docs.aws.amazon.com/kms/latest/developerguide/grants.html
14. Request quotas (AWS KMS Developer Guide) — https://docs.aws.amazon.com/kms/latest/developerguide/requests-per-second.html
15. Identity and access management best practices for AWS KMS (encryption context) — https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-kms-best-practices/access.html
16. AWS KMS cryptography essentials — https://docs.aws.amazon.com/kms/latest/developerguide/kms-cryptography.html
17. Amazon S3 FAQs (encryption options) — https://aws.amazon.com/s3/faqs/
18. Using server-side encryption with customer-provided keys (SSE-C) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerSideEncryptionCustomerKeys.html
19. Reducing the cost of SSE-KMS with Amazon S3 Bucket Keys — https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
20. Why can't I upload a large file to Amazon S3 with AWS KMS key encryption? (re:Post) — https://repost.aws/knowledge-center/s3-large-file-encryption-kms-key
21. Amazon Redshift database encryption — https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-db-encryption.html
22. Changing the AWS KMS key for a namespace (Amazon Redshift Serverless) — https://docs.aws.amazon.com/redshift/latest/mgmt/serverless-workgroups-and-namespaces-rotate-kms-key.html
23. Client-side and server-side encryption (AWS Database Encryption SDK, DynamoDB) — https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/client-server-side.html
24. What is server-side encryption for Kinesis Data Streams? — https://docs.aws.amazon.com/streams/latest/dev/what-is-sse.html
25. Encryption options for Amazon EMR — https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-data-encryption-options.html
26. Encrypting data written by AWS Glue — https://docs.aws.amazon.com/glue/latest/dg/encryption-security-configuration.html
27. Allowing users in other accounts to use a KMS key — https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html
28. Using server-side encryption with AWS KMS keys (SSE-KMS) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html
29. Sharing a snapshot (Amazon Redshift Management Guide) — https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-snapshot-share-snapshot.html
30. Registering an encrypted Amazon S3 location across AWS accounts (Lake Formation) — https://docs.aws.amazon.com/lake-formation/latest/dg/register-cross-encrypted.html
31. Multi-Region keys in AWS KMS — https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html
32. Examples of Amazon S3 bucket policies — https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html
33. Behavior changes in Amazon Redshift — https://docs.aws.amazon.com/redshift/latest/mgmt/behavior-changes.html
34. Amazon MSK encryption — https://docs.aws.amazon.com/msk/latest/developerguide/msk-encryption.html
35. Using SSL with a PostgreSQL DB instance (Amazon RDS) — https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html
36. Amazon Kinesis Data Streams FAQs — https://aws.amazon.com/kinesis/data-streams/faqs/
37. Protecting data by using client-side encryption (Amazon S3) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingClientSideEncryption.html
38. Replicating encrypted objects (SSE-S3, SSE-KMS, DSSE-KMS, SSE-C) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-config-for-kms-objects.html
39. Encryption in transit over external networks: AWS guidance for NYDFS and beyond (AWS Security Blog) — https://aws.amazon.com/blogs/security/encryption-in-transit-over-external-networks-aws-guidance-for-nydfs-and-beyond/
40. General encryption best practices (Encryption best practices and features for AWS services) — https://docs.aws.amazon.com/prescriptive-guidance/latest/encryption-best-practices/general-encryption-best-practices.html
