---
examGuideTaskId: dva-t2-2
certCode: DVA-C03
domain: 2
domainName: 보안
domainWeightPct: 26
title: 암호화 구현과 민감 데이터 관리 (KMS·ACM·클라이언트 측·마스킹·시크릿)
coversTasks:
  - "2.2"
sources:
  - title: AWS KMS keys (AWS KMS concepts)
    url: https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
  - title: Key policies in AWS KMS
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
  - title: GenerateDataKey (AWS KMS API Reference)
    url: https://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKey.html
  - title: Rotate AWS KMS keys
    url: https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html
  - title: Managed certificate renewal in AWS Certificate Manager
    url: https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
  - title: Protecting data by using client-side encryption (Amazon S3 Encryption Client)
    url: https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingClientSideEncryption.html
  - title: Help protect sensitive log data with masking (CloudWatch Logs)
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data.html
  - title: Rotate AWS Secrets Manager secrets
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html
  - title: DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어)
    url: https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
lastVerified: 2026-11-01
---

# 암호화 구현과 민감 데이터 관리 (KMS·ACM·클라이언트 측·마스킹·시크릿)

> **커버하는 공식 Task** — DVA-C03 · 도메인 2 「보안」(26%) · **작업 2.2 AWS 서비스를 사용하여 암호화를 구현하고 민감한 데이터를 관리합니다** (`dva-t2-2`)
> 이 문서는 위 한 작업에 1:1로 매핑되고, 공식 기술 일곱 개(2.2.1~2.2.7)를 모두 덮습니다.

> ⚠️ **C03에서 두 작업이 하나로 합쳐졌습니다.** C02의 Task 2.2(암호화 6)와 Task 2.3(민감 데이터 7) **13개 기술이 C03의 2.2 일곱 개로** 묶였습니다. 그래서 암호화와 **PII·PHI 마스킹·시크릿 관리**를 한 문서에서 다룹니다.
>
> ⚠️ **번호 충돌에 주의합니다** — **C02의 2.3(민감 데이터) ≠ C03의 2.3(AI 보안)**입니다. C03의 2.3은 전혀 다른 주제이고 `dva-t2-3`에 있습니다.

---

## ✅ 학습 목표 체크리스트

- [ ] 저장 중·전송 중 암호화의 **서비스별 기본값과 끌 수 없는 것**을 구분한다
- [ ] TLS를 **끝내는 지점**과 ACM 인증서를 어느 리전에 두는지 안다
- [ ] ACM 공개·가져온 인증서와 Private CA를 **갱신 가능성**으로 가른다
- [ ] 클라이언트 측과 서버 측 암호화를 **"AWS가 평문을 보는가"**로 고른다
- [ ] 봉투 암호화와 KMS API 네 가지를 **데이터 크기·용도**로 고른다
- [ ] 키 정책이 **최종 게이트**라는 것과 교차 계정에 필요한 두 정책을 설명한다
- [ ] 키 회전이 **무엇을 바꾸고 무엇을 바꾸지 않는지** 말한다
- [ ] PII·PHI 마스킹 지점(로그·필드·토큰화)과 Secrets Manager·Parameter Store를 고른다

---

## 🎯 왜 중요한가

암호화 문항은 **"어디서 암호화되고, 그 키를 누가 쥐는가"** 하나로 수렴합니다. 그래서 외울 것은 서비스 목록이 아니라 **경계**입니다 — 저장 중과 전송 중의 경계, 서버 측과 클라이언트 측의 경계, 키 정책과 IAM 정책의 경계.

민감 데이터 쪽은 **출구를 막는 일**입니다. 데이터는 대개 저장소에서 새지 않고 **로그·빌드 출력·API 응답**으로 샙니다. 그래서 CloudWatch Logs가 **수집 시점에** 마스킹하고, CodeBuild가 로그에서 값을 가리고, 환경 변수 대신 시크릿 서비스를 쓰라고 권고하는 것입니다.

---

## ⚡ 시험 직전 요약

> 시험 직전에 이 열 줄만 다시 봅니다. 근거와 맥락은 아래 본문에 있습니다.

- **끌 수 없는 것**: **DynamoDB는 항상 암호화**(키 종류만 전환 가능) · **RDS·Aurora는 생성 시에만** 지정하고 끌 수 없습니다(비암호화 DB는 **스냅샷 복사 → 복원**으로 우회). S3는 새 객체에 **SSE-S3가 자동**입니다
- **전송 중 강제**: S3는 버킷 정책에서 **`aws:SecureTransport`가 `false`인 요청을 Deny**합니다. SQS·SNS의 SSE 큐·토픽 요청은 **HTTPS + SigV4 필수**입니다
- **ACM 인증서 리전**: **CloudFront는 us-east-1**, ALB·Regional API Gateway는 **같은 리전**. ⚠️ **ACM 공개 인증서를 EC2에 직접 설치할 수 없습니다**
- **갱신**: ACM이 발급한 **DNS 검증 + 사용 중** 인증서만 자동 갱신(유효기간 **198일**, 만료 **45일 전** 시도). ⚠️ **가져온(imported) 인증서는 관리형 갱신 대상이 아닙니다**
- **클라이언트 측을 고르는 단서**: "**AWS도 평문을 볼 수 없어야**"·"필드(속성) 단위". 서버 측(SSE-KMS)은 "코드 변경 최소 + 키 정책·CloudTrail 감사"
- **KMS 4 KB**: `Encrypt`·`Decrypt`의 평문은 **최대 4,096바이트**입니다. 큰 데이터는 **`GenerateDataKey` → 로컬 암호화 → 데이터 키만 `Decrypt`**(봉투 암호화)
- ⚠️ **키 정책이 최종 게이트입니다** — IAM 정책은 **키 정책이 허용할 때만** Allow로 작동합니다(Deny는 키 정책과 무관하게 유효). 교차 계정은 **키 정책 + 호출자 IAM 정책 둘 다** 필요합니다
- **회전이 바꾸는 것은 현재 키 자료뿐**입니다 — 키 ID·ARN·정책은 그대로이고 **데이터를 재암호화하지 않습니다.** 자동 회전은 고객 관리형 키에서 **기본 꺼짐**(90~2560일, 기본 365), **AWS managed key는 매년 필수**
- **EC2 키 페어**: AWS가 저장하는 것은 **공개 키**이고 **개인 키는 생성 시 한 번만** 받습니다. 가져오기(import)에서는 **공개 키만** 전송됩니다
- **CloudWatch Logs 마스킹은 수집 시점**입니다 — ⚠️ **정책을 만들기 전에 수집된 이벤트는 마스킹되지 않습니다.** 원문은 **`logs:Unmask`** 권한자만 봅니다

---

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **봉투 암호화** | 데이터는 **데이터 키**로 암호화하고, 그 데이터 키를 **KMS 키**로 암호화해 함께 보관하는 방식 |
| **key spec** | KMS 키의 종류(기본 대칭 `SYMMETRIC_DEFAULT`, 비대칭 RSA·ECC, HMAC). ⚠️ **생성 후 변경 불가** |
| **키 정책** | KMS 키의 리소스 정책. 키마다 **정확히 1개**이고 접근 통제의 **1차 수단** |
| **그랜트(grant)** | KMS 키 1개에 대한 **허용만** 가능한 임시 권한(거부 불가). AWS 서비스가 만들어 쓰고 회수한다 |
| **암호화 컨텍스트** | 비밀이 아닌 키-값 쌍(AAD). 암호문에 결합되어 복호화 때 **정확히 일치**해야 한다 |
| **SSE-C** | 고객이 키를 요청마다 제공하는 서버 측 암호화. ⚠️ 2026-04부터 **신규 버킷에서 기본 차단** |
| **버전 스테이지** | Secrets Manager의 라벨 — `AWSCURRENT`·`AWSPREVIOUS`·`AWSPENDING` |
| **토큰화** | 민감 값을 무의미한 토큰으로 바꾸고 **원본과의 관계를 별도 저장소**에 가두는 기법 |

---

## 📖 핵심 개념

### 1) 저장 중·전송 중 암호화 (기술 2.2.1) {#at-rest-in-transit}

⚠️ **저장 중 암호화는 스토리지에 정적으로 놓인 데이터만** 보호합니다. 네트워크 구간은 **TLS로 따로** 보호해야 합니다.

| 서비스 | 저장 중 | 전송 중 | 시험 포인트 |
|---|---|---|---|
| **S3** | 새 객체에 **SSE-S3 자동**(추가 비용·성능 영향 없음). 선택: SSE-KMS·DSSE-KMS·SSE-C | HTTPS. 버킷 정책에서 **`aws:SecureTransport: false` Deny**로 강제 | 키를 지정하지 않은 SSE-KMS는 **`aws/s3`** 사용 |
| **EBS** | KMS 키로 볼륨·스냅샷 암호화. **"기본 암호화"는 리전 단위**이고 **기존 볼륨엔 영향 없음** | 인스턴스↔볼륨 구간도 암호화 | attach 시 EC2가 KMS에 **`CreateGrant`** 요청 |
| **RDS·Aurora** | ⚠️ **생성 시에만** 지정, **끌 수 없음** | SSL·TLS(MySQL은 `require_secure_transport` 기본 OFF) | 비암호화 DB는 **스냅샷 복사(암호화) → 복원** |
| **DynamoDB** | ⚠️ **항상 암호화, 끌 수 없음**(키 종류만 전환) | HTTPS 기본 | **일부 항목만 선택 암호화 불가** |
| **SQS** | SSE-SQS 또는 SSE-KMS. ⚠️ **본문만** 암호화 | SSE 큐 요청은 **HTTPS + SigV4 필수** | 활성화 **이전 백로그는 소급 암호화 안 됨**. 데이터 키 재사용 60~86,400초(기본 300) |
| **SNS** | SSE(⚠️ **대칭 키만** 지원) | SSE 토픽 요청은 HTTPS + SigV4 필수 | — |

**TLS를 끝내는 지점**과 인증서 리전이 함께 묶여 나옵니다.

| 구성요소 | TLS 동작 | ACM 인증서 위치 |
|---|---|---|
| **ALB** | HTTPS 리스너에 서버 인증서 + 보안 정책. **ALB가 복호화**해 대상으로 전달 | **같은 리전** |
| **CloudFront 뷰어 구간** | HTTP and HTTPS / Redirect HTTP to HTTPS(**GET·HEAD는 301**) / HTTPS Only(**HTTP는 403**) | ⚠️ **us-east-1** |
| CloudFront → 오리진 | HTTPS Only / **Match Viewer**(뷰어 정책이 Redirect 또는 HTTPS Only일 때만 선택 가능) | 오리진 쪽 인증서 |
| API Gateway 커스텀 도메인 | 엣지 최적화는 CloudFront 경유, Regional은 해당 리전 | 엣지 최적화 **us-east-1** / Regional은 **같은 리전** |

- 암호화를 **그대로 통과**시키려면(SSL 패스스루) ALB가 아니라 **NLB·CLB의 TCP 443 리스너**를 씁니다.
- KMS API 호출 자체도 **서명 + TLS 1.2 이상**을 요구합니다.

> 🧠 **원리** — TLS는 "끝내는 지점"에 인증서를 둡니다. 그래서 CloudFront 인증서가 us-east-1인 이유는 **엣지가 전 세계에 있고 거기로 배포되기** 때문이고, ALB 인증서가 같은 리전인 이유는 **그 ALB가 그 리전에 있기** 때문입니다.

### 2) 인증서 관리 — ACM과 Private CA (기술 2.2.2) {#certificates}

| 구분 | **ACM 공개 인증서** | **가져온(imported) 인증서** | **AWS Private CA** |
|---|---|---|---|
| 신뢰 범위 | **공개 신뢰** | 발급처에 따름 | **조직 내부에서만** |
| 도메인 소유 검증 | **필요**(DNS 권장·이메일·HTTP) | 없음 | 없음 |
| 유효기간 | **198일**, 만료 **45일 전** 자동 갱신 시도 | 인증서 자체 기간 | 일반 목적 모드 임의 기간, **단기 모드 최대 7일** |
| 자동 갱신 | **통합 서비스에 연결된(사용 중) DNS 검증** 인증서 | ⚠️ **불가** | `IssueCertificate`로 직접 발급한 것은 ACM 관리형 갱신 대상 아님 |
| 개인 키 | 반출 불가(통합 서비스에서만 사용) | 사용자 제공(**암호 없는 PEM, 5 KB 이하**) | 접근 불가 키 인증서는 무료 |

- **DNS 검증 vs 이메일 검증**: DNS는 **CNAME 레코드가 있는 한 자동 갱신**됩니다(Route 53이면 ACM이 레코드를 직접 추가). 이메일 검증은 만료 45일 전부터 알림이 가고 **도메인 소유자가 직접 갱신**해야 합니다. ⚠️ **이메일로 만든 인증서를 DNS 검증으로 바꿀 수 없습니다**(삭제 후 재생성).
- ⚠️ **ACM 공개 인증서를 EC2 인스턴스에 직접 설치할 수 없습니다** — 로드 밸런서 뒤에 인스턴스를 둡니다. "내보내기 가능한 공개 인증서"는 **요청 시** 내보내기를 켜야 하고 **기존 인증서는 내보낼 수 없습니다.**
- **ACM vs Private CA**: ACM은 **요청·검증·갱신·배포 자동화**, Private CA는 **내부 PKI(루트·하위 CA 계층) 운영**입니다. ACM에서 사설 인증서를 요청할 때 CA로 Private CA를 씁니다.

> 🧠 **원리** — ACM이 **직접 발급한** 인증서는 갱신본도 ACM이 발급해 통합 서비스에 다시 연결할 수 있습니다. 가져온 인증서는 ACM이 발급 주체가 아니므로 **갱신할 수단이 없고**, 그래서 사용자가 새 인증서를 가져와 교체해야 합니다.

### 3) 클라이언트 측 vs 서버 측 암호화 (기술 2.2.3) {#client-server-side}

| 구분 | **서버 측(SSE)** | **클라이언트 측** |
|---|---|---|
| 암호화 주체 | **서비스**가 저장할 때 | **애플리케이션**이 전송 **전에** |
| 서비스의 평문 접근 | 요청 처리 중 **서비스가 평문 접근** | ⚠️ **서비스는 암호문만** 받는다(AWS 포함 제3자에 비노출) |
| 키 관리 | SSE-S3(서비스)·SSE-KMS(KMS 키)·SSE-C(고객 제공) | 사용자가 **래핑 키**를 정하고 과정·도구를 관리 |
| 서비스의 인식 | 암호화 객체임을 **앎** | **일반 객체·이진 속성으로만** 인식 |
| AWS 도구 | S3 SSE · EBS · DynamoDB 저장 중 암호화 | S3 Encryption Client · AWS Encryption SDK · **AWS Database Encryption SDK** |

- **S3 Encryption Client**: `PutObject`·`GetObject`에서 자동 암·복호화하고 **객체마다 고유 데이터 키**를 씁니다(버킷 키는 사용하지 않습니다). 서버 측 암호화와 **함께 써도** 됩니다.
- **AWS Encryption SDK**: 메시지마다 고유 데이터 키를 만들고 그 키를 **래핑 키로 암호화해 암호문과 함께** 보관합니다. 같은 데이터 키를 **여러 래핑 키로** 암호화할 수 있습니다(수신자별 복호화).
- **DynamoDB**: 클라이언트 측 라이브러리는 **AWS Database Encryption SDK**로 개명됐습니다(옛 이름 DynamoDB Encryption Client). 속성 값을 암호화·서명하고 ⚠️ **기본 키(파티션·정렬 키)의 이름·값은 평문**으로 남습니다.
- **고르는 단서**: "AWS도 평문을 볼 수 없어야"·"종단 간"·"필드 단위" → **클라이언트 측**. "코드 변경 최소, 키 정책·CloudTrail 감사" → **SSE-KMS**.

> 🧠 **원리** — 서버 측은 **서비스가 키를 쓰므로** 키 정책·권한으로 통제·감사할 수 있습니다. 클라이언트 측은 서비스가 키를 전혀 쓰지 않아 **노출면이 줄지만**, 키와 코드 관리 책임이 개발자에게 넘어옵니다. 보안이 "더 좋다"가 아니라 **책임이 옮겨간다**가 정확한 설명입니다.

### 4) 키로 암호화·복호화 (기술 2.2.4) {#kms}

| 구분 | **고객 관리형 키** | **AWS managed key** | **AWS owned key** |
|---|---|---|---|
| 소유·위치 | 내 계정, 내가 관리 | 내 계정에 있으나 **서비스가 관리** | **서비스 계정**(여러 계정 공용) |
| 키 정책 | 고객이 전적으로 통제 | 서비스가 통제(조회만) | 서비스만 |
| 로깅 | CloudTrail | CloudTrail | ⚠️ **고객이 볼 수 없음** |
| 자동 회전 | **선택(기본 꺼짐)** | **필수, 매년** | 서비스가 결정 |
| 요금 | 월 **$1** + 사용료 | 월 요금 없음 | 없음 |
| 교차 계정 공유 | **가능** | ⚠️ **불가** | 서비스가 처리 |

- **key spec**: 기본은 대칭(256비트 AES-GCM)이고 비대칭(RSA·ECC)·HMAC도 있습니다. ⚠️ **생성 후 변경 불가**라 틀리면 삭제 후 재생성입니다. 모든 KMS 키는 **HSM 밖으로 평문 반출이 안 되고**, 비대칭 키의 **공개 키만** `GetPublicKey`로 가져옵니다.
- ⚠️ **키 정책이 1차 게이트**입니다 — 키마다 **정확히 1개**이고 **계정 루트·키 생성자도 명시적으로 허용되지 않으면 권한이 없습니다.** **IAM 정책은 키 정책이 허용할 때만** Allow로 작동합니다(Deny는 키 정책 허용 없이도 유효).
- **그랜트**: 키 1개에 대한 **허용만**(거부 불가) 가능한 임시 권한이고 AWS 서비스가 만들어 쓰고 회수합니다. 생성·회수 직후 **일관성 지연**이 있어 grant token을 씁니다.
- 범위 제한 조건: **`kms:ViaService`**(특정 서비스를 통한 요청만), 암호화 컨텍스트 조건.

| 상황 | 쓸 API | 핵심 |
|---|---|---|
| **4 KB 이하** 소량 | `Encrypt` / `Decrypt` | 평문 최대 **4,096바이트**(대칭) |
| **큰 데이터** | **`GenerateDataKey`** → 로컬 암호화 → 데이터 키만 `Decrypt` | 평문 키는 쓰고 **메모리에서 지우고**, 암호화된 키는 데이터와 함께 저장 |
| 암호화된 키만 먼저 | `GenerateDataKeyWithoutPlaintext` | EBS가 볼륨 생성 시 사용 |
| 암호문을 **다른 키로 교체** | `ReEncrypt` | 평문 비노출. ⚠️ Encryption SDK·S3 암호화 클라이언트 암호문은 못 풉니다 |

- ⚠️ **`GenerateDataKey`는 대칭 암호화 KMS 키만** 쓸 수 있습니다.
- **복호화 시 키 식별**: 대칭 키 암호문은 메타데이터가 들어 있어 `KeyId`가 **선택 사항**이지만, **비대칭 키는 `KeyId`와 알고리즘을 반드시** 줘야 합니다.
- **암호화 컨텍스트**는 비밀이 아닌 키-값 쌍이고 ⚠️ 복호화 때 **대소문자까지 정확히 일치**해야 합니다(불일치 시 `InvalidCiphertextException`). **CloudTrail에 평문으로** 남고 비대칭·HMAC 키는 지원하지 않습니다.
- **스로틀·비용 완화**: ① **S3 Bucket Keys**(SSE-KMS 요청 비용 최대 99% 절감, **DSSE-KMS 미지원**) ② Encryption SDK **데이터 키 캐싱** ③ 쿼터 증액.

**교차 계정**과 **회전**은 이 기술에서 가장 자주 묻는 두 지점입니다.

- **교차 계정에는 두 정책이 모두** 필요합니다 — ① 키 소유 계정의 **키 정책**이 외부 계정을 허용 ② 외부 계정의 **IAM 정책**이 그 권한을 위임. ⚠️ **키 정책에 없는 동작은 IAM에 써도 무효**입니다.
- ⚠️ **AWS managed key는 공유할 수 없어** 교차 계정에는 **고객 관리형 키가 필수**입니다. 다른 계정의 키는 **키 ARN 또는 별칭 ARN**으로 지정합니다(키 ID·별칭 이름 불가).
- **회전이 바꾸는 것은 현재 키 자료뿐**입니다 — 키 ID·ARN·정책은 그대로이고, 이전 키 자료는 키 삭제까지 보관되어 **복호화는 KMS가 알맞은 자료를 자동으로** 고릅니다(코드 변경 불필요). ⚠️ **데이터 키를 회전하거나 데이터를 재암호화하지 않습니다.**
- 자동 회전은 고객 관리형 대칭 키에서 **기본 꺼짐**(90~2560일, 기본 **365**), **AWS managed key는 매년 필수**이며, **비대칭·HMAC 키는 자동·온디맨드 회전이 모두 불가**(새 키 + 별칭 이동)입니다.
- **비활성화 vs 삭제 예약**: 비활성화는 **언제든 되돌릴 수 있고 요금은 계속** 청구됩니다. 삭제 예약은 **7~30일(기본 30)** 대기 후 **영구 삭제**이고 대기 중에는 **청구되지 않습니다.** ⚠️ 확신이 없으면 **먼저 비활성화**합니다.

> 🧠 **원리** — KMS는 HSM에서 저지연 연산을 하도록 설계돼 직접 암호화를 **4 KB로 제한**합니다. 그래서 큰 데이터는 로컬 대칭 키로 암호화하고 **KMS는 그 키만 감쌉니다**(봉투 암호화). 그리고 키가 사라지면 그 키로 감싼 데이터 키를 풀 수 없어 **데이터가 영구 소실**되므로, 삭제에만 대기 기간이라는 안전장치가 붙습니다.

### 5) 개발용 인증서·SSH 키 생성 (기술 2.2.5) {#dev-keys}

- **자체 서명 인증서**: `openssl genrsa 2048 > privatekey.pem` → CSR(`openssl req -new -key …`) → `openssl x509 -req`로 서명. 로컬 생성은 **단일 인스턴스 HTTPS나 백엔드 재암호화** 같은 경우에만 필요하고, **도메인이 있으면 ACM이 무료**입니다.
- **사설 CA + 클라이언트 인증서**(예: API Gateway mTLS): 루트 CA 키(4096) → 자체 서명 루트 → 클라이언트 키(2048)·CSR → 루트로 서명. truststore는 **S3의 `.pem`**이고 **체인 길이 최대 4**입니다.
- **ACM으로 가져오기**: 자체 서명 인증서도 인증서 + 개인 키를 주면 가져옵니다. **PEM, 암호 없는 개인 키, 5 KB 이하**, 유효기간 내여야 하고 ⚠️ **가져온 인증서는 관리형 갱신이 없습니다.**
- **EC2 키 페어 — AWS가 생성**: `aws ec2 create-key-pair … --query "KeyMaterial" --output text > key.pem` 후 `chmod 400`. ⚠️ **개인 키는 생성 시 한 번만** 받을 수 있습니다.
- **EC2 키 페어 — 가져오기**: `ssh-keygen`으로 만든 뒤 `aws ec2 import-key-pair --public-key-material fileb://…`. ⚠️ **공개 키만** AWS로 전송되고 **개인 키는 전송되지 않습니다.**
- 규칙: 지원 키는 **RSA(Linux·Windows)·ED25519(Linux만)**이고 **DSA는 불가**입니다. 개인 키 형식은 PEM 또는 PPK, 리전당 **최대 5,000개**(증액 가능). CloudFormation으로 만들면 개인 키가 **Parameter Store `/ec2/keypair/<키 ID>`**에 저장됩니다.

> 🧠 **원리** — EC2 키 페어에서 AWS가 저장하는 것은 **공개 키**이고 개인 키는 사용자가 보관합니다. 그래서 **개인 키를 한 번만 받을 수 있고**, 가져오기 방식에서는 애초에 공개 키만 올라갑니다. "개인 키를 다시 내려받는다"는 보기는 그래서 틀립니다.

### 6) 민감 데이터 식별·마스킹·액세스 제한 (기술 2.2.6) {#sensitive-data}

- **데이터 분류**가 먼저입니다 — 중요도와 민감도로 범주화해(예: highly confidential / confidential / public) 등급별 암호화 전략을 정합니다(Well-Architected 보안 축 SEC 7).
- **PII**는 "개인의 신원을 구별하거나 추적하는 데 쓸 수 있는 정보", **PHI**는 "개인 식별 가능한 건강 정보"(미국 HIPAA 맥락)입니다. ⚠️ **정의가 국가·지역마다 달라** 서비스 운영 국가에 맞춰 해석합니다.

**로그가 가장 흔한 출구**입니다. **CloudWatch Logs 데이터 보호 정책**이 그 지점을 막습니다.

- 식별 대상은 **managed data identifier**(금융·PHI·PII 사전 정의 유형) 또는 **사용자 정의 정규식**으로 지정하고, 동작은 **Audit**(감사) 또는 **Deidentify**(마스킹)를 고릅니다.
- 범위는 **계정 전체 또는 개별 로그 그룹**이고 둘 다 있으면 **누적 적용**됩니다. 로그 그룹당 그룹 수준 정책은 **1개**입니다.
- ⚠️ **수집(ingest) 시점에 탐지·마스킹**하므로 **정책을 만들기 전에 수집된 이벤트는 마스킹되지 않습니다.** 마스킹은 Logs Insights·지표 필터·구독 필터 등 **모든 출구에** 적용되고 원문은 **`logs:Unmask`** 권한자만 봅니다.
- ⚠️ **CodeBuild는 정확히 같은 문자열만 가립니다** — 값을 Base64 등으로 변환하면 **로그에 노출**됩니다.

**애플리케이션 수준** 기법은 세 가지이고 **원본 복원 가능성**으로 갈립니다.

| 기법 | 원본 복원 | AWS 예 |
|---|---|---|
| **삭제·가림(redact)** | 불가 | Amazon Comprehend redaction(⚠️ **비동기 배치 작업으로만**), DataBrew |
| **토큰화** | 토큰 볼트가 있으면 가능 | 토큰 생성 API + (선택) 조회 API |
| **필드 암호화** | 키가 있으면 가능 | **AWS Database Encryption SDK**, **CloudFront 필드 수준 암호화** |

- **토큰화 vs 암호화**: 토큰화는 **컴플라이언스 범위 축소·형식 유지·키 관리 부담 감소**에 유리하고, 암호화는 **대용량·비정형 데이터**나 제3자에게 원본을 공유할 때 낫습니다.
- **CloudFront 필드 수준 암호화**: POST 요청의 지정 필드를 **엣지에서 RSA 공개 키로** 암호화해 오리진·내부 시스템을 지나도 암호화를 유지합니다(최대 **10필드**, 필드당 16 KB, RSA 2048비트). ⚠️ **CloudFront가 가진 공개 키로는 복호화할 수 없고** 개인 키 보유 컴포넌트만 복호화합니다.
- **DB-ESDK**: 속성은 `ENCRYPT_AND_SIGN`·`SIGN_ONLY`·`DO_NOTHING` 중 하나이고 ⚠️ **파티션 키·정렬 키는 항상 `SIGN_ONLY`**(평문)입니다.
- ⚠️ **마스킹은 fail-closed로** 합니다 — 마스킹이 실패하면 원본을 돌려주지 말고 **예외로 멈춰야** 합니다.
- **액세스 제한**은 ABAC로 일반화합니다 — 토큰의 테넌트·부서 클레임을 **세션 태그**로 넘기고 정책에서 `${aws:PrincipalTag/…}` 변수로 범위를 정하면, 대상이 늘어도 **정책 수가 늘지 않습니다.**
- 발견 도구(참고): **Amazon Macie**는 S3 객체에서, **Comprehend**는 텍스트에서 PII를 탐지합니다.

> 🧠 **원리** — 민감 데이터는 저장소보다 **출구**에서 샙니다. 그래서 CloudWatch는 **수집 시점에 한 번 마스킹해 모든 출구에 같은 결과**를 적용하고, 필드 수준 암호화는 **복호화 권한 보유자를 분리**하며, 삭제는 **복원 가능성 자체를 없앱니다.** 요구사항이 "나중에 원본이 필요한가"이면 그 답이 기법을 정합니다.

### 7) 시크릿 관리 서비스 (기술 2.2.7) {#secrets}

| 항목 | **Secrets Manager** | **Parameter Store** |
|---|---|---|
| 선택 가이드 | **자동 회전이 이득인 시크릿** | 자주 읽는 시크릿·구성값(**표준 티어 무료**) |
| 자동 회전 | **내장**(관리형 또는 Lambda 회전 함수) | 없음 |
| 버전·스테이지 | 버전 + **`AWSCURRENT`·`AWSPREVIOUS`·`AWSPENDING`** | — |
| 값 크기 | **65,536바이트** | 표준 **4 KB** / 고급 8 KB |
| 요금 | 시크릿당 월 **$0.40** + API 요금 | **표준 무료** |
| KMS | **항상 봉투 암호화**(값이 바뀔 때마다 새 데이터 키) | **`SecureString`만**(⚠️ 이름·설명은 평문, **대칭 키만**) |
| 교차 계정 | 리소스 정책 + IAM + **고객 관리형 키**(`aws/secretsmanager` 불가) | **고급 파라미터만** AWS RAM 공유 |
| 삭제 | 복구 기간 **7~30일**(기본 30) | — |

- **회전 방식 셋**: 관리형 회전(Lambda 불필요) · 파트너 관리형 외부 시크릿 · 그 밖은 **Lambda 회전 함수**.
- **Lambda 회전 4단계**: `createSecret` → `setSecret` → `testSecret` → `finishSecret`. ⚠️ **한 단계라도 실패하면 열린 회전 창 동안 전체 회전을 여러 번 재시도**합니다.
- **일정**: `rate()` 또는 `cron()`, **UTC 기준, 최소 4시간 간격**. 회전을 설정하면 **즉시 한 번 회전**합니다.
- **런타임 조회는 캐싱**합니다 — 캐싱 클라이언트는 **기본 1시간** 갱신(`DescribeSecret`·`GetSecretValue` 권한), **Parameters and Secrets Lambda Extension**은 **기본 300초 캐시·최대 1,000개**이고 TTL은 0~300초입니다. ⚠️ Lambda에서는 **핸들러 밖에서** 캐시를 만듭니다.
- ⚠️ **ECS는 컨테이너가 시작될 때 1회 주입**합니다 — 시크릿을 회전해도 **자동 반영되지 않고** 새 태스크나 **Force new deployment**가 필요합니다. 태스크 **실행 역할**에 `secretsmanager:GetSecretValue`·`ssm:GetParameters`·`kms:Decrypt`가 필요합니다.
- **CodeBuild** 환경 변수 `type`은 `PLAINTEXT`(⚠️ 민감 값에 강력히 비권장)·`PARAMETER_STORE`·`SECRETS_MANAGER`입니다.
- **CloudFormation**은 템플릿에 자격 증명을 쓰지 말고 **동적 참조(dynamic references)**를 씁니다 — CloudFormation은 **참조된 실제 값을 저장하지 않습니다.**
- **Lambda 환경 변수**는 항상 KMS로 암호화되지만(기본 AWS managed key), ⚠️ 그것은 **"저장·조회 권한" 통제**일 뿐 **함수가 값을 로그로 내보내는 것까지 막지 못합니다.** 그래서 DB 자격 증명은 **Secrets Manager**를 쓰라고 권고합니다. 전체 크기는 **4,096바이트**입니다.
- **RDS 연동**: `ManageMasterUserPassword=true`면 RDS가 마스터 비밀번호를 Secrets Manager에서 **수명 주기 전체에 걸쳐 관리**합니다(관리 시작 후 KMS 키 변경 불가).

> 🧠 **원리** — 둘 다 KMS로 값을 보호하지만 **Secrets Manager는 회전·버전·복제까지 포함한 수명 주기 서비스**이고 **Parameter Store는 계층적 설정 저장소에 암호화 문자열 타입을 더한 것**입니다. 그래서 "회전이 요구사항인가"가 선택을 결정하고, 그 외에는 무료인 표준 티어가 합리적입니다.

---

## ✍️ 시험 포인트

- **"기존 비암호화 RDS를 암호화하라"** → **스냅샷 복사(암호화) → 복원**. 기존 DB에서 켤 수 없습니다.
- **"HTTP 요청을 차단하라"** → S3는 **`aws:SecureTransport: false` Deny**, CloudFront는 **HTTPS Only**(403) 또는 Redirect(301).
- **"AWS도 평문을 볼 수 없어야 한다"** → **클라이언트 측 암호화**(Encryption SDK·DB-ESDK). SSE-KMS는 서비스가 평문을 처리합니다.
- **"1 MB 파일을 KMS로 암호화"** → `Encrypt`는 **4 KB 제한**이므로 **`GenerateDataKey` + 봉투 암호화**.
- **"다른 계정이 내 암호화 S3 객체를 읽어야 한다"** → **고객 관리형 키**(AWS managed key는 공유 불가) + 키 정책 + 상대 IAM + **전체 키 ARN**.
- **"키를 회전했는데 옛 데이터가 안 읽힌다?"** → 읽힙니다. 회전은 **현재 키 자료만** 바꾸고 KMS가 알맞은 자료를 고릅니다. 반대로 **데이터 키 유출 위험을 줄여 주지도 않습니다.**
- **"로그에 카드번호가 남는다"** → **CloudWatch Logs 데이터 보호 정책**(Deidentify). ⚠️ **이미 수집된 이벤트는 마스킹되지 않습니다.**
- **"시크릿을 회전했는데 ECS 컨테이너가 옛 값을 쓴다"** → **시작 시 1회 주입**이므로 **새 배포**가 필요합니다.
- **"CloudFront 인증서를 만들었는데 못 고른다"** → **us-east-1**에 있어야 합니다.

---

## ⚠️ 흔한 함정 {#pitfalls}

| 함정 | 바로잡기 |
|---|---|
| 저장 중 암호화가 전송 구간도 보호한다고 본다 | **별개**다 — TLS로 따로 보호하고 정책으로 강제한다 |
| DynamoDB 암호화를 끄거나 일부 항목만 켜려 한다 | **항상 암호화**이고 **항목별 선택 불가**(키 종류만 전환) |
| RDS 암호화를 나중에 켜려 한다 | **생성 시에만** 지정 — 스냅샷 복사 → 복원 경로를 쓴다 |
| SQS SSE가 메타데이터까지 암호화한다고 본다 | **본문만**이고 **활성화 이전 백로그는 소급되지 않는다** |
| CloudFront 인증서를 ALB와 같은 리전에 만든다 | CloudFront는 **us-east-1** |
| 가져온 인증서가 자동 갱신된다고 본다 | **관리형 갱신 대상이 아니다** — 사용자가 교체한다 |
| ACM 공개 인증서를 EC2에 설치하려 한다 | **불가능** — 로드 밸런서 뒤에 둔다 |
| `Encrypt` API로 큰 파일을 암호화하려 한다 | 평문 **4,096바이트** 제한 — 봉투 암호화를 쓴다 |
| 비대칭 KMS 키로 `GenerateDataKey`를 부른다 | **대칭 암호화 키만** 가능하다 |
| IAM 정책만 열고 키 정책을 두지 않는다 | **키 정책이 허용할 때만** IAM Allow가 작동한다 |
| 교차 계정에 AWS managed key를 쓰려 한다 | **공유 불가** — 고객 관리형 키가 필수 |
| 회전이 데이터를 재암호화한다고 본다 | **현재 키 자료만** 바꾼다(코드·데이터 변경 없음) |
| 비대칭·HMAC 키에 자동 회전을 켜려 한다 | **불가** — 새 키를 만들고 별칭을 옮긴다 |
| 암호화 컨텍스트를 비밀처럼 쓴다 | **CloudTrail에 평문으로** 남는다. 그리고 복호화 때 **정확히 일치**해야 한다 |
| 개인 키를 EC2에서 다시 내려받으려 한다 | **생성 시 한 번만** 받을 수 있다(AWS는 공개 키만 저장) |
| 로그 마스킹 정책을 켜고 과거 로그도 가려진다고 본다 | **수집 시점** 처리라 이전 이벤트는 그대로다 |
| CodeBuild가 변환된 값도 가려 준다고 본다 | **정확히 같은 문자열만** 가린다 |
| 환경 변수 암호화로 민감 값 보호가 끝났다고 본다 | 조회 **권한** 통제일 뿐 — 코드가 로그로 내보내는 것은 막지 못한다 |

---

## 🧪 자가 점검

**Q1.** 운영 중인 비암호화 RDS 인스턴스를 암호화해야 한다. 가능한 경로와, DynamoDB·S3는 어떻게 다른가? (→ 1) 저장 중·전송 중)

<details><summary>정답 보기</summary>

RDS·Aurora는 **생성 시에만** 암호화를 지정할 수 있고 **끌 수도 켤 수도 없습니다.** 그래서 **스냅샷을 만들고 암호화된 복사본으로 복사한 뒤 복원**하는 경로를 씁니다(리전 간 복사 시 대상 리전 키 지정).

**DynamoDB는 항상 암호화**되어 있어 끌 수 없고 **키 종류만**(AWS owned·AWS managed·고객 관리형) 언제든 전환합니다 — 일부 항목만 선택 암호화하는 것도 불가능합니다. **S3는 새 객체에 SSE-S3가 자동 적용**되며 SSE-KMS·DSSE-KMS로 올릴 수 있고, 전송 중은 버킷 정책의 **`aws:SecureTransport: false` Deny**로 강제합니다.
</details>

**Q2.** 500 MB 파일을 KMS 키로 암호화하려 한다. 어떤 API 흐름이고 왜 그런가? (→ 4) KMS)

<details><summary>정답 보기</summary>

**`GenerateDataKey` → 받은 평문 데이터 키로 로컬에서 파일 암호화 → 평문 키를 메모리에서 지우고 암호화된 키를 데이터와 함께 저장 → 복호화 시 `Decrypt`로 데이터 키만 복호화**하는 **봉투 암호화**입니다.

이유는 `Encrypt`·`Decrypt`의 평문이 **최대 4,096바이트**로 제한되기 때문입니다 — KMS는 HSM에서 저지연 연산을 하도록 설계됐습니다. ⚠️ `GenerateDataKey`는 **대칭 암호화 KMS 키만** 쓸 수 있고, 암호문을 다른 키로 바꾸려면 `ReEncrypt`(평문 비노출)를 씁니다.
</details>

**Q3.** 다른 계정의 Lambda가 내 계정 KMS 키로 암호화된 S3 객체를 읽어야 한다. 무엇이 필요하고 흔한 실수는? (→ 4) KMS)

<details><summary>정답 보기</summary>

**두 정책이 모두** 필요합니다 — ① 내 계정의 **키 정책**이 상대 계정(또는 특정 주체)을 허용하고 ② 상대 계정의 **IAM 정책**이 그 권한을 역할에 위임해야 합니다. 그리고 다른 계정의 키는 **키 ARN 또는 별칭 ARN**으로 지정해야 합니다(키 ID·별칭 이름 불가).

흔한 실수는 **`aws/s3` 같은 AWS managed key를 쓰는 것**입니다 — ⚠️ **AWS managed key는 다른 계정과 공유할 수 없어** 고객 관리형 키가 필수입니다. 또한 **키 정책에 없는 동작은 상대 IAM에 써도 무효**이고, 요금은 **요청한 계정**이 냅니다.
</details>

**Q4.** 보안팀이 "키를 회전하면 과거 데이터가 재암호화되는가"라고 묻는다. 무엇이 바뀌고 무엇이 안 바뀌는가? (→ 4) KMS)

<details><summary>정답 보기</summary>

회전은 **현재 키 자료만** 교체합니다. **키 ID·ARN·키 정책은 그대로**이고 이전 키 자료는 키를 삭제할 때까지 보관되어, **복호화는 KMS가 알맞은 키 자료를 자동으로 골라** 처리합니다(코드 변경이 필요 없습니다).

바뀌지 **않는** 것: **데이터를 재암호화하지 않고**, **데이터 키를 회전하지도 않으며**, 따라서 **유출된 데이터 키의 위험을 줄여 주지 않습니다.** 자동 회전은 고객 관리형 대칭 키에서 **기본 꺼짐**(90~2560일, 기본 365)이고 **AWS managed key는 매년 필수**이며, **비대칭·HMAC 키는 회전이 불가**해 새 키를 만들고 별칭을 옮깁니다.
</details>

**Q5.** 애플리케이션 로그에 주민등록번호가 섞여 들어갔다. 즉시 조치와 그 조치의 한계는? (→ 6) 민감 데이터)

<details><summary>정답 보기</summary>

**CloudWatch Logs 데이터 보호 정책**을 만들고 동작을 **Deidentify(마스킹)**로 지정합니다. 식별 대상은 **managed data identifier**나 **사용자 정의 정규식**으로 지정하고, 계정 전체 또는 로그 그룹 단위로 적용합니다(둘 다 있으면 누적).

⚠️ 한계는 **수집 시점에 처리한다**는 점입니다 — **정책을 만들기 전에 이미 수집된 이벤트는 마스킹되지 않습니다.** 마스킹은 Logs Insights·지표 필터·구독 필터 등 모든 출구에 적용되고 원문은 **`logs:Unmask`** 권한자만 볼 수 있습니다. 근본 조치는 **코드가 민감 값을 로그에 쓰지 않도록** 하는 것이고, 마스킹 유틸리티는 **fail-closed**(실패 시 예외)로 동작해야 합니다.
</details>

**Q6.** DB 자격 증명을 90일마다 회전해야 한다. 어떤 서비스를 고르고, ECS에서 주의할 점은? (→ 7) 시크릿)

<details><summary>정답 보기</summary>

**Secrets Manager**입니다 — **자동 회전이 내장**되어 있고 버전 스테이지(`AWSCURRENT`·`AWSPREVIOUS`·`AWSPENDING`)로 교체를 안전하게 합니다. Parameter Store는 회전 기능이 없고 **표준 티어가 무료**라 자주 읽는 설정값에 맞습니다. 회전 일정은 UTC 기준 **최소 4시간 간격**이고, 설정하면 **즉시 한 번 회전**합니다.

⚠️ ECS 주의점: 작업 정의의 `secrets`는 **컨테이너가 시작될 때 1회 주입**되므로 시크릿을 회전해도 **자동 반영되지 않습니다** — 새 태스크를 시작하거나 **Force new deployment**가 필요합니다. 태스크 **실행 역할**에 `secretsmanager:GetSecretValue`·`kms:Decrypt`가 필요합니다.
</details>

**Q7.** 결제 카드번호를 엣지에서부터 암호화해 내부 시스템이 평문을 보지 못하게 하려 한다. 무엇을 쓰고 제약은? (→ 6) 민감 데이터)

<details><summary>정답 보기</summary>

**CloudFront 필드 수준 암호화**입니다 — POST 요청의 지정한 필드를 **엣지에서 RSA 공개 키로** 암호화해 오리진과 내부 시스템을 지나도 암호화 상태를 유지하고, **개인 키를 가진 컴포넌트만** 복호화합니다(⚠️ CloudFront가 가진 공개 키로는 복호화할 수 없습니다).

제약은 **최대 10개 필드**, 필드당 **16 KB**, 요청 본문 **1 MB**, **RSA 2048비트**이고 오리진이 **청크 인코딩을 지원**해야 합니다. DynamoDB에 저장할 때 속성 단위로 같은 일을 하려면 **AWS Database Encryption SDK**를 쓰는데, ⚠️ **파티션 키·정렬 키는 항상 `SIGN_ONLY`**로 평문입니다.
</details>

---

### 📌 출처

1. Setting default server-side encryption behavior for Amazon S3 buckets — https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-encryption.html
2. Protecting data by using client-side encryption (Amazon S3 Encryption Client) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingClientSideEncryption.html
3. Encryption at rest in Amazon SQS — https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-server-side-encryption.html
4. DynamoDB encryption at rest usage notes — https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/encryption.usagenotes.html
5. AWS Certificate Manager public certificates — https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html
6. Validate domain ownership for ACM public certificates — https://docs.aws.amazon.com/acm/latest/userguide/domain-ownership-validation.html
7. Managed certificate renewal in AWS Certificate Manager — https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html
8. Prerequisites for importing ACM certificates — https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-prerequisites.html
9. AWS KMS keys (AWS KMS concepts) — https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html
10. Key policies in AWS KMS — https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html
11. GenerateDataKey (AWS KMS API Reference) — https://docs.aws.amazon.com/kms/latest/APIReference/API_GenerateDataKey.html
12. Allowing users in other accounts to use a KMS key — https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html
13. Rotate AWS KMS keys — https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html
14. Delete an AWS KMS key — https://docs.aws.amazon.com/kms/latest/developerguide/deleting-keys.html
15. Create a key pair for your Amazon EC2 instance — https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html
16. Securing Lambda environment variables — https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars-encryption.html
17. What's in a Secrets Manager secret? — https://docs.aws.amazon.com/secretsmanager/latest/userguide/whats-in-a-secret.html
18. Rotate AWS Secrets Manager secrets — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html
19. Lambda rotation functions (Secrets Manager) — https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_lambda-functions.html
20. Pass Secrets Manager secrets through Amazon ECS environment variables — https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html
21. Security best practices for CloudFormation — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/security-best-practices.html
22. Help protect sensitive log data with masking (CloudWatch Logs) — https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data.html
23. Which fields are encrypted and signed? (AWS Database Encryption SDK for DynamoDB) — https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/DDB-encryption-context.html
24. Use field-level encryption to help protect sensitive data (CloudFront) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/field-level-encryption.html
25. Trust and safety (Amazon Comprehend — PII detection and redaction) — https://docs.aws.amazon.com/comprehend/latest/dg/trust-safety.html
26. Using managed data identifiers (Amazon Macie) — https://docs.aws.amazon.com/macie/latest/user/managed-data-identifiers.html
27. DVA-C03 공식 시험 가이드 · 콘텐츠 도메인 2 (한국어) — https://docs.aws.amazon.com/ko_kr/aws-certification/latest/developer-associate-03/developer-associate-03-domain2.html
