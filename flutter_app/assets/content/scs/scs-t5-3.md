---
examGuideTaskId: scs-t5-3
certCode: SCS-C03
domain: 5
domainName: 데이터 보호
domainWeightPct: 18
title: 기밀 데이터와 키 자료 (보안 암호·가져온 키·회전·마스킹·다중 리전 키와 인증서)
coversTasks:
  - "5.3"
sources:
  - title: AWS Key Management Service
    url: https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
  - title: Key stores
    url: https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html
  - title: Importing key material for AWS KMS keys
    url: https://docs.aws.amazon.com/kms/latest/developerguide/importing-keys.html
  - title: Rotate AWS KMS keys
    url: https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html
  - title: Multi-Region keys in AWS KMS
    url: https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html
  - title: AWS CloudHSM key stores
    url: https://docs.aws.amazon.com/kms/latest/developerguide/keystore-cloudhsm.html
  - title: External key stores
    url: https://docs.aws.amazon.com/kms/latest/developerguide/keystore-external.html
  - title: What is AWS CloudHSM?
    url: https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html
  - title: What is AWS Private CA?
    url: https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html
  - title: Rotate AWS Secrets Manager secrets
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html
  - title: Set up alternating users rotation for AWS Secrets Manager
    url: https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_rotation-alternating.html
  - title: Help protect sensitive log data with masking
    url: https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data.html
  - title: Creating data protection policies in Amazon SNS
    url: https://docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-configure.html
lastVerified: 2026-11-09
---

# 기밀 데이터와 키 자료 (보안 암호·가져온 키·회전·마스킹·다중 리전 키와 인증서)

> **커버하는 공식 Task** — SCS-C03 · 도메인 5 「데이터 보호」(18%) · **작업 5.3 기밀 데이터, ID, 보안 암호, 암호화 키 자료를 보호하기 위한 제어 기능 설계 및 구현** (`scs-t5-3`)
> 이 문서는 위 한 작업에 1:1로 매핑되고 공식 기술 5개(5.3.1~5.3.5)를 모두 덮습니다.

> ⚠️⚠️ **이 작업에는 C02에 없던 기술이 둘 있습니다** — `기술 5.3.3`(가져온 키 자료와 AWS 생성 키 자료의 **차이점 설명**)과 `기술 5.3.5`(단일·여러 리전의 키와 **인증서**)입니다. 둘 다 이 자격증에서 처음 범위에 든 주제이고, 특히 5.3.3은 **「절충안」**을 묻습니다 — **「BYOK가 더 안전하다」가 답이 아니고 무엇을 얻고 무엇을 잃는지가 답**입니다(§1-2).

> ⚠️ 그리고 `기술 5.3.4`가 예시로 드는 둘 중 **`Amazon SNS 메시지 데이터 보호`는 신규 고객에게 열려 있지 않습니다**(§4-2). 축은 **CloudWatch Logs 데이터 보호 정책**입니다.

---

## ✅ 학습 목표 체크리스트

- [ ] `Origin` 값 넷이 낳는 **제약의 연쇄**를 안다
- [ ] 절충안의 **공식 답 세 문장**을 말한다
- [ ] BYOK 로 **얻는 것과 잃는 것**을 구분한다
- [ ] 회전 **세 방식의 적용 범위**를 표로 떠올린다
- [ ] Secrets Manager 회전의 **세 형태와 두 전략**을 안다
- [ ] 마스킹의 **비소급 성질**과 닫힌 예시를 안다
- [ ] 다중 리전 키가 **서비스에서 어떻게 다뤄지는지** 안다
- [ ] 다중 리전 **키**는 있지만 다중 리전 **CA**는 없음을 안다

## 🎯 왜 중요한가

이 작업의 문항은 **"더 안전한 쪽을 고르라"가 아니라 "요구를 만족하는 최소 복잡도를 고르라"**입니다. 공식 문서가 **"모든 옵션이 똑같이 안전하고 차이는 운영 절충"**이라고 직접 적고, **사용자 지정 키 저장소는 규제가 명시적으로 요구할 때만** 권합니다. 공식 서술과 거꾸로 읽기 쉬운 자리입니다(§1-2).

그리고 **"바꿨는데 기존 것은 그대로"** 모양이 여기 둘 더 있습니다 — **KMS 키 회전은 데이터를 재암호화하지 않고**(§2-2), **CloudWatch Logs 데이터 보호 정책은 이미 수집된 로그를 마스킹하지 않습니다**(§4-1). 작업 5.2의 S3 기본 암호화와 같은 모양이라 한 번에 묶어 기억하면 셋이 함께 풀립니다.

## ⚡ 시험 직전 요약

- **`Origin`이 계보를 가릅니다** — `AWS_KMS`(표준) · `EXTERNAL`(가져온 키) · `AWS_CLOUDHSM` · `EXTERNAL_KEY_STORE`. ⚠️ **사용자 지정 키 저장소에서는 대칭 암호화 키만** 만들 수 있어 **비대칭·HMAC·가져온 키 자료·다중 리전 키가 전부 불가**합니다
- ⚠️⚠️ **공식은 "모든 옵션이 똑같이 안전하고 차이는 운영 절충"**이라고 적고 **대부분의 고객에게 표준 키 저장소**를 권합니다. 그래서 **「키 자료에 대한 통제를 입증하라」의 공식 답도 사용자 지정 키 저장소가 아니라 「표준 키 저장소 + 가져온 키」**입니다
- ⚠️⚠️ **가져온 키로 암호화한 암호문도 KMS 밖에서는 복호화할 수 없습니다** — 암호문 형식이 비공개이고 예고 없이 바뀔 수 있습니다
- **회전은 셋입니다** — **자동**(`AWS_KMS` 대칭 암호화 키만) · **온디맨드**(`AWS_KMS` + **`EXTERNAL`**) · **수동**(비대칭·HMAC·사용자 지정 키 저장소의 키). ⚠️ **가져온 키는 자동 회전이 안 되고 온디맨드는 됩니다**
- ⚠️⚠️ **회전은 데이터를 재암호화하지 않고 데이터 키를 회전하지도 않습니다** — 유출된 데이터 키의 영향을 완화하지 못합니다
- **Secrets Manager 회전은 세 형태**(관리형 · 관리형 외부 보안 암호 · **Lambda 함수 기반**)이고 **관리형 회전은 Lambda 를 쓰지 않습니다**. 전략은 **단일 사용자**와 **교대 사용자**(가용성이 더 높고 **보안 암호 둘**이 필요)입니다
- ⚠️⚠️ **CloudWatch Logs 데이터 보호 정책은 수집 시점에 마스킹하고 이미 수집된 로그에는 소급 적용되지 않습니다.** 마스킹 해제는 **`logs:Unmask`** 권한이 있어야 합니다
- ⚠️ **`Amazon SNS 메시지 데이터 보호`는 신규 고객에게 더 이상 제공되지 않습니다**
- ⚠️⚠️ **대부분의 AWS 서비스는 다중 리전 키를 단일 리전 키처럼 다룹니다**(S3 교차 리전 복제는 **그래도 재암호화**합니다). 이점은 주로 **클라이언트 측 암호화**에서 나옵니다
- ⚠️ **프라이빗 CA 는 리전 리소스이고 리전 간 복사가 불가능합니다** — 여러 리전에서 쓰려면 **리전마다** 만듭니다

## 🔤 먼저 알아야 할 용어

| 용어 | 뜻 |
|---|---|
| **`Origin`** | KMS 키를 만들 때 정하는 **키 자료의 출처**. 네 값이 있고 여기서 거의 모든 제약이 파생됩니다 |
| **BYOK / HYOK** | 전자는 **내 키 자료를 KMS로 가져오는 것**, 후자는 **키를 AWS 밖에 두는 것**(외부 키 저장소) |
| **래핑 키** | 데이터 키를 암호화하는 키(키 암호화 키). KMS 키는 대개 이 역할입니다 |
| **온디맨드 회전** | 자동 회전 일정과 무관하게 **즉시** 키 자료를 회전하는 것. 기존 자동 일정은 바뀌지 않습니다 |
| **XKS 프록시** | KMS 와 외부 키 관리자 사이를 중개하는 **내가 제공하는** 소프트웨어 |
| **관리형 데이터 식별자** | CloudWatch Logs·SNS 가 미리 제공하는 민감 데이터 유형(금융·PHI·PII 등) |
| **교대 사용자 회전** | 보안 암호 하나에 **두 사용자**를 두고 번갈아 암호를 바꾸는 전략 |
| **종단 엔터티 인증서** | 프라이빗 CA 계층이 발급하는 최종 X.509 인증서 |

## 📖 핵심 개념

### 1) 키 저장소 넷과 절충안 (기술 5.3.3 · 보조 5.2.1) {#key-stores}

#### 1-1. 계보 — `Origin`이 모든 제약을 낳는다

| `Origin` | 키 자료 생성·보관 | 한국어 이름 |
|---|---|---|
| **`AWS_KMS`**(기본) | AWS KMS 가 생성하고 **KMS HSM**에 보관 | 표준 키 저장소 |
| **`EXTERNAL`** | **내가 생성해 KMS 로 가져옵니다**(BYOK) | 가져온 키 자료 |
| **`AWS_CLOUDHSM`** | KMS 가 **내 CloudHSM 클러스터 안에서** 생성 | CloudHSM 키 저장소 |
| **`EXTERNAL_KEY_STORE`** | **AWS 밖 외부 키 관리자**가 보관(HYOK) | 외부 키 저장소(XKS) |

**KMS 자체의 기준선** — KMS 키는 **FIPS 140-3 보안 수준 3** 검증 HSM 으로 보호되고 **암호화되지 않은 상태로 KMS 를 떠나지 않습니다.**

⚠️⚠️ **사용자 지정 키 저장소**(CloudHSM 키 저장소 + XKS)에서는 **대칭 암호화 키만** 만들 수 있습니다 — 공식 API 설명이 기본 `KeySpec`·기본 `KeyUsage`를 쓰라며 **"No other key type is supported in a custom key store"**라고 적습니다. **이 한 줄이 아래 제약 다수를 설명합니다:**

- 사용자 지정 키 저장소에서는 **비대칭 키·HMAC 키가 불가**합니다
- **키 자료를 가져올 수 없습니다**
- **다중 리전 키를 만들 수 없습니다**
- **자동·온디맨드 회전이 안 되고 수동 회전만** 가능합니다(§2-2)

⚠️ 계정·리전마다 **사용자 지정 키 저장소는 최대 10개**이고 **CloudHSM 키 저장소와 외부 키 저장소를 합산**하며 **연결 상태와 무관**하게 셉니다.

#### 1-2. ⚠️⚠️ 절충안의 공식 답 — 이 기술의 핵심

공식 「Key stores」 페이지가 **권고를 직접 적습니다.** 이 세 문장이 `기술 5.3.3`의 답입니다.

> 1. "For most customers, the **AWS KMS standard key store** provides the optimal balance of security, performance, cost, and operational simplicity."
> 2. "If you need to **demonstrate control over the key material itself**, consider using **AWS KMS imported keys with the AWS KMS standard key store**. This approach provides compliance benefits of customer-controlled key material **while maintaining the operational advantages of AWS KMS infrastructure**."
> 3. "Consider creating a custom key store **only when your organization has regulatory requirements that explicitly mandate** key material protection in a single-tenant HSM or in an HSM that you control outside of AWS. **Even then**, create one only when the risk of not meeting those requirements outweighs the additional cost, operational complexity, and reduced performance."

⚠️⚠️ **「모든 옵션은 똑같이 안전합니다」** — 공식이 "All of the options are **equally secure**; the difference is in the **operational trade-offs**"라고 적습니다. 즉 축은 **보안 강도가 아니라 운영 절충**이고, **「CloudHSM 키 저장소가 더 안전하니 그쪽」은 공식 서술과 어긋납니다.**

⚠️⚠️ **「키 자료에 대한 통제를 입증해야 한다」는 요구의 공식 답은 「표준 키 저장소 + 가져온 키」입니다.** 공식 서술과 거꾸로 읽기 쉬운 자리이고, 이 작업에서 가장 중요한 갈림길입니다.

⚠️ 많은 준수 요구에는 **키 정책으로 키 접근을 통제하는 것으로 충분**하다고 공식이 적습니다. 그리고 **KMS 가 제공하는 모든 키 저장소 유형이 FIPS 140 보안 수준 3으로 검증**되며 **"AWS 운영자를 포함해 누구도" 평문 키에 접근하지 못하게** 설계됩니다. 결제 워크로드에는 **AWS Payment Cryptography** 가 따로 있습니다.

#### 1-3. CloudHSM 키 저장소와 외부 키 저장소

**CloudHSM 키 저장소** — 내가 소유·관리하는 **CloudHSM 클러스터**로 뒷받침되고, 키 자료는 **추출 불가능한** 형태로 그 클러스터에 생성·보관되며 암호화 연산도 그 HSM 에서 수행됩니다.

- ⚠️ **클러스터에 서로 다른 가용 영역의 활성 HSM 이 최소 두 개** 있어야 합니다
- ⚠️ KMS 전용 **크립토 사용자(CU)** 계정이 필요하고 KMS 가 그 자격 증명으로 로그인합니다
- ⚠️⚠️ **연결이 끊긴 동안에는 KMS 가 접근할 수 없어 그 키로 암호화 연산을 할 수 없습니다**
- ⚠️ **리전 제약이 있습니다** — KMS 지원 리전 중 **아시아 태평양(멜버른) · 중국(베이징) · 중국(닝샤) · 유럽(스페인)은 제외**입니다
- 관리 접점이 둘로 갈립니다 — **키 저장소는 KMS 에서, HSM 클러스터는 CloudHSM 에서** 만들고 관리합니다. **CloudHSM 클러스터·HSM 비용이 별도**로 듭니다

**외부 키 저장소(XKS)** — AWS 밖의 **외부 키 관리자**로 뒷받침되고 암·복호 연산을 **내 외부 키 관리자가 내 키 자료로** 수행합니다.

- ⚠️⚠️ **KMS 는 외부 키 관리자와 직접 통신하지 않습니다** — 내가 제공하는 **XKS 프록시** 소프트웨어만 상대하고 그 프록시가 KMS 의 일반 요청을 **벤더별 형식으로 번역**합니다. 프록시는 공식 **외부 키 저장소 프록시 API 명세**를 따라야 합니다
- ⚠️⚠️ **이중 암호화** — KMS 가 **먼저 내 KMS 키의 키 자료로 평문을 암호화한 뒤** 외부 키 관리자에 보내 **외부 키로 다시 암호화**합니다. 결과적으로 **"AWS KMS 도, 외부 키 자료의 소유자도 혼자서는 복호화할 수 없습니다."**
- ⚠️⚠️ **접근을 끊으면 복호화가 멈춥니다.** 일시적으로 끊으면 복원할 때까지 복호화할 수 없고, **영구적으로 끊으면 그 암호문은 복구 불가**입니다(예외는 **데이터 키를 짧게 캐시하는 AWS 서비스**뿐이고 그것도 리소스를 비활성화하거나 캐시가 만료될 때까지입니다)
- ⚠️⚠️ **공유 책임 모델이 크게 이동합니다** — 표준 키에서는 KMS 가 키 자료의 보안·가용성·지연·내구성을 책임지는데, XKS 에서는 **외부 키 관리자의 보안·신뢰성·내구성·성능이 내 책임**입니다. 공식이 직접 경고합니다: "they are a **major departure from the standard shared responsibility model** … The greater risk to availability and latency will, **for most customers, exceed the perceived security benefits**."
- 프록시 연결 방식은 **퍼블릭 엔드포인트**와 **VPC 엔드포인트 서비스** 둘입니다

#### 1-4. CloudHSM 을 직접 쓰는 길

`기술 5.2.1`이 **"AWS CloudHSM 또는 AWS KMS"** 중 선택을 묻습니다. §1-3이 **KMS 를 쓰면서 CloudHSM 을 뒤에 두는** 경로였다면, 이 절은 **CloudHSM 을 직접 쓰는** 경로입니다.

- ⚠️ **클러스터 모드가 둘**입니다 — **FIPS 모드**는 **FIPS 검증 키와 알고리즘만** 쓸 수 있고, **비FIPS 모드**는 CloudHSM 이 지원하는 모든 키·알고리즘을 FIPS 승인 여부와 무관하게 씁니다
- HSM 은 **범용(general purpose)**이고 **단일 테넌트**입니다 — 완전관리형 서비스는 알고리즘·키 길이가 정해져 있다는 것과 대비되는 지점입니다
- ⚠️⚠️ **데이터 플레인이 종단 간 암호화돼 AWS 에 보이지 않고, 그 대가로 사용자 관리를 내가 합니다** — 공식이 "you control your own user management (**outside of IAM roles**)"라고 적습니다. **IAM 이 아니라 HSM 자체의 사용자 체계**이므로 「IAM 정책으로 CloudHSM 키 사용자를 통제한다」는 거짓입니다
- ⚠️ 키를 **생성·보관·가져오기·내보내기·관리·사용**할 수 있습니다 — **내보내기가 가능하다**는 점이 KMS 와의 큰 차이입니다
- ⚠️ **PKCS #11 · JCE · CNG · KSP** 를 쓰는 기존 PKI 를 **애플리케이션 변경을 줄여** 옮길 수 있습니다 — 레거시 HSM 인터페이스가 CloudHSM 을 고르는 전형적 이유입니다
- 공식이 분기를 적어 둡니다 — **HSM 을 직접 운영할 필요가 없다면 KMS**, **결제 처리용 HSM 이 필요하면 AWS Payment Cryptography** 입니다

⚠️ **FIPS 수준 표기를 섞지 않습니다** — KMS 는 **FIPS 140-3 보안 수준 3**, CloudHSM FIPS 모드 클러스터는 **FIPS 140-2 수준 3 또는 FIPS 140-3 수준 3**으로 적힙니다. 「둘 다 140-3 수준 3」으로 단정하지 않습니다.

### 2) 가져온 키 자료와 회전 (기술 5.3.2 · 5.3.3) {#imported-rotation}

#### 2-1. BYOK — 얻는 것과 잃는 것

키 자료 없이 KMS 키를 만든 뒤 내 키 자료를 가져오는 기능이고, **"키 자료에 대한 책임은 내게 남고 AWS KMS 가 그 사본을 쓰게 하는 것"**입니다.

⚠️⚠️ **가장 자주 오해되는 한계** — 공식이 적습니다:

> "AWS KMS does **not** support decrypting any AWS KMS ciphertext encrypted by a symmetric encryption KMS key **outside of AWS KMS, even if the ciphertext was encrypted under a KMS key with imported key material**."

**「내 키를 가져왔으니 내 쪽에서 복호화할 수 있다」는 거짓입니다.** 암호문 형식이 **비공개이고 예고 없이 바뀔 수 있습니다.**

**가져오는 이유(공식 열거):**

1. **요건을 충족하는 엔트로피 소스**로 키 자료를 생성했음을 입증합니다
2. 내 인프라의 키 자료를 AWS 서비스와 쓰면서 **그 수명 주기 관리를 KMS 에 맡깁니다**
3. **코드 서명 · PKI 인증서 서명 · 인증서 고정 애플리케이션** 같은 기존의 확립된 키를 KMS 에서 씁니다
4. ⚠️ **키 자료에 만료 시각을 설정하고 수동으로 삭제한 뒤 나중에 다시 쓸 수 있게** 합니다 — 대비되는 **키 삭제 예약**은 **7~30일 대기 기간** 뒤 **복구 불가**입니다
5. 키 자료의 **원본 사본을 내가 소유**하고 AWS 밖에 보관해 **내구성·재해 복구**에 씁니다
6. **비대칭 키·HMAC 키**에서는 가져오기가 **AWS 안과 밖에서 모두 동작하는 호환 키**를 만듭니다

**지원·제약:**

- 지원 키 유형 — **대칭 암호화 키 · 비대칭 키(⚠️ `ML-DSA`·`ML-KEM` 제외) · HMAC 키 · 지원되는 모든 유형의 다중 리전 키**
- ⚠️ **사용자 지정 키 저장소의 KMS 키에는 키 자료를 가져올 수 없습니다**(§1-1의 귀결)
- 리전 — KMS 지원 전 리전. ⚠️ **중국 리전은 대칭 암호화 키의 키 자료 요건이 다릅니다**
- 운영 수단 — **만료 임박 CloudWatch 경보** · **키 자료 재가져오기** · **새 키 자료를 가져와 온디맨드 회전** · 가져온 키 자료를 쓰는 키 **식별·조회**

#### 2-2. 회전 매트릭스

⚠️⚠️ **방식 셋의 적용 범위가 다르고, 여기서 `EXTERNAL` 키의 운명이 갈립니다.**

| 방식 | 적용되는 키 | 비고 |
|---|---|---|
| **자동 회전** | **`AWS_KMS` origin 의 대칭 암호화 키만** | 기본 **매년**, **사용자 지정 회전 주기**(일 수) 지정 가능. 고객 관리형 키에만 **선택적** |
| **온디맨드 회전** | `AWS_KMS` origin **+ `EXTERNAL`(가져온) origin** 의 대칭 암호화 키 | 자동 회전 활성화 여부와 무관하게 즉시 실행. **기존 자동 일정은 바뀌지 않습니다** |
| **수동 회전**(새 키로 교체) | **비대칭 키 · HMAC 키 · 사용자 지정 키 저장소의 키** | 자동도 온디맨드도 지원되지 않습니다 |

- ⚠️⚠️ **가져온 키 자료는 자동 회전되지 않지만 온디맨드 회전은 됩니다.** `기술 5.3.2`가 "가져온 키 자료를 관리 및 회전"을 명시하는데 그 경로가 **「새 키 자료를 가져와 온디맨드 회전」**입니다
- ⚠️ **AWS 관리형 키는 AWS 가 항상 매년 회전**합니다("AWS KMS **always** rotates…") — 끌 수 없습니다. **AWS 소유 키**의 회전은 그 키를 소유한 AWS 서비스가 관리합니다
- ⚠️ **회전은 현재 키 자료만 바꿉니다.** 복호화 시 KMS 가 **암호화에 쓰인 키 자료를 자동으로 고르므로** 코드 변경 없이 안전하게 쓸 수 있고, 복호화용 키 자료를 내가 고를 수는 없습니다
- ⚠️⚠️ **회전은 데이터를 재암호화하지 않고 데이터 키를 회전하지도 않습니다** — 공식이 "Key rotation **will not mitigate the effect of a compromised data key**"라고 적습니다. 「키를 회전했으니 유출된 데이터 키의 영향이 사라진다」는 거짓입니다
- ⚠️ **과금은 1·2회차 회전까지만**입니다 — "This price increase is **capped at the second rotation**." 그리고 **쿼터는 회전 횟수와 무관**해 회전된 키 자료 버전이 몇 개든 **KMS 키 하나**로 셉니다
- 공식 권고 순서 — **지원되면 자동 → 안 되면 온디맨드 → 둘 다 안 되면 수동.** 계획되지 않은 회전에는 온디맨드를, 가능하면 **사용자 지정 주기의 자동 회전**을 권합니다
- 상태 조회 API 가 둘입니다 — **`GetKeyRotationStatus`**(자동 회전 활성화 여부 + 진행 중인 온디맨드 회전) · **`ListKeyRotations`**(완료된 회전 상세)
- ⚠️ **왜 회전하나의 공식 어조**도 기억합니다 — KMS 키는 대개 **래핑 키**여서 데이터 키만큼 자주 쓰이지 않아 고갈 위험이 매우 낮고, 회전하는 이유는 **사업·계약 규칙이나 정부 규정** 때문입니다. 「보안상 반드시 회전해야 한다」가 아니라 **「요구되면 회전한다」**입니다

### 3) 보안 암호 관리와 회전 (기술 5.3.1) {#secrets}

**회전은 보안 암호를 주기적으로 갱신하는 절차**이고, 공식이 **"보안 암호와 데이터베이스·서비스 양쪽의 자격 증명을 갱신한다"**고 정의합니다.

**형태가 셋입니다.**

| 형태 | 성질 |
|---|---|
| **관리형 회전** | 대부분의 관리형 보안 암호에서 쓰고 **서비스가 회전을 구성·관리**합니다. ⚠️ **Lambda 함수를 쓰지 않습니다** |
| **관리형 외부 보안 암호 회전** | Secrets Manager **파트너가 보유한 보안 암호**를 파트너 시스템에서 갱신합니다. ⚠️ **Lambda 함수가 필요하지 않습니다** |
| **Lambda 함수 기반 회전** | 그 밖의 유형에서 **Lambda 함수가 보안 암호와 데이터베이스·서비스를 갱신**합니다 |

⚠️ **"회전은 곧 Lambda"가 아닙니다** — 관리형 경로 둘은 Lambda 를 쓰지 않습니다. 「Lambda 함수를 만들어야 회전할 수 있다」는 보기가 그래서 틀립니다.

**전략이 둘입니다.**

- **단일 사용자** — 보안 암호에 담긴 그 사용자의 자격 증명을 회전 함수가 갱신합니다
- **교대 사용자** — **보안 암호 하나에 두 사용자**를 두고 회전마다 번갈아 암호를 바꿉니다. 공식이 **"한쪽이 갱신되는 동안 다른 쪽이 현재 자격 증명을 유지하므로 고가용성이 필요할 때 좋은 선택"**이라고 적고, ⚠️ **첫 회전에서 Secrets Manager 가 사용자를 복제**합니다

⚠️⚠️ **교대 사용자 전략에는 보안 암호가 둘 필요합니다** — **회전할 자격 증명을 담은 것**과 **관리자 자격 증명을 담은 것**입니다. 관리자 사용자는 **첫 사용자를 복제하고 그 암호를 바꿀 권한**이 있어야 합니다. 공식 자습서는 그 관리자 보안 암호를 **Amazon RDS 가 만들고 관리형 회전으로 관리**하게 합니다.

> ⚠️ 작업 4.1의 임시 자격 증명과 섞지 않습니다 — Secrets Manager 는 **장기 자격 증명을 안전하게 보관하고 회전**하는 쪽이고, STS 는 **처음부터 짧은 자격 증명을 발급**하는 쪽입니다. 「데이터베이스 암호를 STS 로 발급한다」는 성립하지 않습니다.

### 4) 민감한 데이터 마스킹 (기술 5.3.4) {#masking}

#### 4-1. CloudWatch Logs 데이터 보호 정책 — 축은 이쪽이다

**로그 그룹 데이터 보호 정책**으로 수집되는 로그 이벤트의 민감 데이터를 **감사하고 마스킹**합니다.

- **기본적으로 모든 유출 지점에서 마스킹**됩니다 — **CloudWatch Logs Insights · 지표 필터 · 구독 필터**를 포함합니다. ⚠️ **마스킹되지 않은 데이터를 보려면 `logs:Unmask` IAM 권한**이 필요합니다
- **범위가 둘이고 함께 적용됩니다** — **계정 전체 정책**(기존 로그 그룹과 **이후 만들어질 로그 그룹 모두**에 적용)과 **개별 로그 그룹 정책**. 둘이 다 있으면 **양쪽에 지정된 관리형 데이터 식별자가 모두** 감사·마스킹됩니다
- ⚠️⚠️ **수집 시점에 탐지·마스킹되고, 정책을 설정하기 전에 수집된 로그 이벤트는 마스킹되지 않습니다** — 공식이 Important 로 적습니다. **소급 적용되지 않습니다**
- **로그 그룹당 로그 그룹 수준 정책은 하나**이고, 하나의 정책에 **여러 관리형 데이터 식별자**를 넣을 수 있습니다. 정책 **한도는 30,720자**입니다
- **마스킹은 Standard 와 Essentials(옛 Infrequent Access) 로그 클래스 모두**에서 지원됩니다
- **탐지 수단**은 **패턴 매칭과 기계 학습 모델**입니다. 관리형 데이터 식별자는 **금융 데이터 · PHI · PII** 유형을 미리 제공하고, 일부 유형은 **민감 데이터 근처의 특정 키워드**가 함께 발견돼야 탐지됩니다. **사용자 지정 데이터 식별자**도 만들 수 있습니다
- 민감 데이터가 탐지되면 **`LogEventsWithFindings` 지표**가 CloudWatch 로 발행됩니다

> ⚠️ 「설정을 바꿨는데 기존 데이터는 그대로」가 이 도메인에 **셋** 있습니다 — 여기, 작업 5.2의 **S3 기본 암호화**, 그리고 §2-2의 **KMS 키 회전**(데이터를 재암호화하지 않습니다). 한 묶음으로 기억하면 함께 풀립니다.

#### 4-2. ⚠️ Amazon SNS 메시지 데이터 보호 — 신규 고객에게 닫혔다

공식 기술 5.3.4가 예시로 **두 번째 기능**을 들지만, 그 기능의 공식 문서가 머리에 **Important** 로 적습니다 — **"Amazon SNS message data protection is no longer available to new customers."** 즉 **신규 고객에게 더 이상 제공되지 않습니다.**

개념은 알아 둡니다(기존 고객의 환경을 다루거나 비교 보기로 나올 수 있습니다).

- 주제에 **데이터 보호 정책**을 붙여 게시되는 데이터를 **감사 · 비식별화(마스킹 또는 편집) · 거부(차단)** 합니다
- **작업이 셋**입니다 — **audit**(발견된 민감 데이터의 양을 보고) · **de-identify**(마스킹·편집) · **deny**(민감 데이터가 든 페이로드의 게시·전달 차단)
- ⚠️ **주제당 정책은 하나**이고, 한 정책에 **de-identify 와 deny 문장은 여럿** 둘 수 있지만 **audit 문장은 하나**만 둡니다
- 문장마다 **인바운드(주제로)와 아웃바운드(구독으로)** 중 어느 방향에 적용할지, 어느 계정·IAM 보안 주체에 적용할지를 정합니다
- 탐지는 CloudWatch Logs 쪽과 같이 **기계 학습과 패턴 매칭**이고 **관리형·사용자 지정 데이터 식별자**를 씁니다

⚠️⚠️ **새 설계에서 민감 데이터 마스킹의 축은 CloudWatch Logs 데이터 보호 정책입니다.** 공식 가이드가 갓 추가한 기술이 **닫힌 기능을 예시로 든다**는 것을 알고 가야, 문항에서 그 보기를 보고 흔들리지 않습니다.

### 5) 여러 리전의 키와 인증서 (기술 5.3.5) {#multi-region}

#### 5-1. 다중 리전 키 — 「서비스가 어떻게 다루는가」가 핵심

서로 **관련된** 다중 리전 키 집합은 **같은 키 자료와 같은 키 ID** 를 가져, 한 리전에서 암호화한 데이터를 **재암호화나 교차 리전 호출 없이** 다른 리전에서 복호화할 수 있습니다.

⚠️⚠️ **그런데 대부분의 AWS 서비스는 다중 리전 키를 단일 리전 키처럼 다룹니다.** 공식이 직접 적습니다:

> "**Most AWS services** that integrate with AWS KMS for encryption at rest or digital signatures currently treat multi-Region keys **as though they were single-Region keys**. For example, **Amazon S3 cross-Region replication decrypts and re-encrypts the data keys** … **even when the KMS key in both Regions is a related multi-Region key**."

**「다중 리전 키를 쓰면 S3 교차 리전 복제가 재암호화를 건너뛴다」는 거짓입니다.** 이점은 주로 **클라이언트 측 암호화**(AWS Encryption SDK · AWS Database Encryption SDK · S3 클라이언트 측 암호화)에서 나오고, 공식은 **서비스 문서를 확인하라**고 적습니다.

그 밖의 비자명한 사실:

- ⚠️ **독립적으로 관리합니다** — 별칭·태그, 키 정책·권한 부여, 활성화·비활성화를 **키마다 따로** 합니다. "같은 키"가 아니라 **"같은 키 자료를 가진 서로 다른 키"**입니다
- ⚠️ **글로벌이 아닙니다** — 기본 키를 만들고 **내가 고른 리전으로, 한 AWS 파티션 안에서** 복제합니다. **AWS 도 KMS 도 대신 복제하지 않습니다**
- ⚠️⚠️ **AWS 관리형 키는 항상 단일 리전 키**입니다
- ⚠️⚠️ **기존 단일 리전 키를 다중 리전 키로 변환할 수 없습니다** — 공식이 그 설계가 **데이터 상주성·주권** 성질을 유지하기 위한 것이라고 적습니다. 설계 단계에서 결정해야 하는 값입니다
- ⚠️ **사용자 지정 키 저장소에는 다중 리전 키를 만들 수 없지만**(§1-1), **가져온 키 자료로는 만들 수 있습니다**
- 요금·쿼터 — 관련 집합의 **키 하나하나가 각각 하나의 KMS 키**로 과금·집계되고 **쿼터는 계정의 리전마다 따로** 계산됩니다
- ⚠️ **공식 어조가 보수적입니다** — "For most data security needs, the **Regional isolation and fault tolerance** of Regional resources make standard AWS KMS **single-Region keys a best-fit solution.**" **「다중 리전 키가 대부분의 경우 더 좋다」로 쓰지 않습니다**

#### 5-2. AWS Private CA — 인증서 쪽 절반

**루트·하위 CA 를 포함한 프라이빗 CA 계층**을 만들고 **종단 엔터티 X.509 인증서**를 발급합니다. 용도는 **TLS 통신 채널 · 사용자·컴퓨터·API 엔드포인트·IoT 디바이스 인증 · 코드 서명 · OCSP 구현**입니다.

- ⚠️⚠️ **프라이빗 CA 는 리전 리소스이고 리전 간 복사가 불가능합니다** — 여러 리전에서 쓰려면 **리전마다 만들어야** 합니다. §5-1의 다중 리전 **키**와 대비되는 지점이고, `기술 5.3.5`가 키와 인증서를 한 기술에 묶은 이유입니다
- ⚠️ **ACM 이 AWS Private CA 보다 많은 리전에서 제공됩니다**
- **ACM 으로 프라이빗 인증서를 요청하면** ACM 통합 서비스 어디에든 연결할 수 있고(Private CA 루트 체인이든 **외부 루트** 체인이든), **Private CA API·CLI 로 발급하거나 ACM 에서 내보내면** 어디에든 설치할 수 있습니다
- ⚠️⚠️ **EKS 는 ACM 통합 서비스가 아닙니다** — 그런데 **프라이빗 CA 는 EKS 에 통합해** 클러스터 안에서 인증서를 발급할 수 있습니다. 둘을 섞으면 거짓이 됩니다
- ⚠️ **지원 알고리즘에 양자 내성 `ML_DSA_44`·`ML_DSA_65`·`ML_DSA_87` 이 듭니다**(개인 키 알고리즘과 서명 알고리즘 양쪽). 그 밖에 RSA 2048/3072/4096 · EC prime256v1/secp384r1/secp521r1 · **SM2(중국 리전 전용)**입니다. ⚠️ **ML-DSA 는 해시 함수가 알고리즘에 포함돼 고를 수 없고**, API 호환을 위해 키 알고리즘과 서명 알고리즘에 같은 값을 씁니다
- ⚠️ **이 알고리즘 목록은 Private CA 가 직접 발급할 때의 것**이고 **ACM 이 Private CA 의 CA 로 발급할 때는 일부만** 지원합니다
- ⚠️ **RFC 5280을 일부만 강제합니다** — 발급 CA 인증서의 `Not After` 를 넘는 발급 금지 · 가져온 CA 인증서의 **기본 제약**(`critical` 표시 + `CA=true`) · **경로 길이** · **이름 제약**을 강제합니다

⚠️⚠️ **양자 내성 알고리즘 지원 범위를 서비스 간에 일반화하지 않습니다** — KMS 는 **`ML-DSA`·`ML-KEM` 키에 키 자료를 가져올 수 없는데**(§2-1) Private CA 는 **ML-DSA 로 발급·서명**합니다. 두 서비스의 지원 범위를 같다고 쓰면 거짓이 됩니다.

## ✍️ 시험 포인트

- **"키 자료 통제를 입증하라"는 표준 키 저장소 + 가져온 키다** — 사용자 지정 키 저장소가 아닙니다
- **"단일 테넌트 HSM 을 규제가 명시적으로 요구한다"일 때만 CloudHSM 키 저장소다**
- **"키가 AWS 밖에 있어야 한다"는 외부 키 저장소다** — 가져온 키는 **사본이 KMS 에 있습니다**
- **"가져온 키로 암호화했으니 온프레미스에서 복호화하겠다"는 불가능하다**
- **"사용자 지정 키 저장소에서 비대칭 서명"은 불가능하다** — 대칭 암호화 키만입니다
- **"가져온 키를 회전하라"는 새 키 자료를 가져와 온디맨드 회전이다** — 자동 회전은 `AWS_KMS` origin 전용입니다
- **"비대칭·HMAC 키를 회전하라"는 수동 회전이다**
- **"데이터 키가 유출됐으니 KMS 키를 회전한다"는 완화되지 않는다**
- **"회전 비용이 계속 는다"는 틀렸다** — 2회차에서 상한입니다
- **"키 삭제 예약을 취소하고 복구한다"는 대기 기간(7~30일) 안에서만이고, 그 뒤는 복구 불가다**
- **"레거시 PKCS #11 애플리케이션"은 CloudHSM 직접 사용이다** — KMS 는 키를 내보낼 수 없습니다
- **"IAM 정책으로 CloudHSM 키 사용자를 통제"는 틀렸다** — IAM 밖의 사용자 체계입니다
- **"회전하려면 Lambda 함수를 만들어야 한다"는 틀렸다** — 관리형 회전은 Lambda 를 쓰지 않습니다
- **"회전 중에도 끊김이 없어야 한다"는 교대 사용자 전략이고 보안 암호가 둘 필요하다**
- **"정책을 걸었는데 과거 로그가 그대로"는 정상이다** — 수집 시점 마스킹이고 소급 적용되지 않습니다
- **"마스킹된 값을 봐야 한다"는 `logs:Unmask` 권한이다**
- **"SNS 메시지 데이터 보호로 새로 설계"는 지금 성립하지 않는다** — 신규 고객에게 제공되지 않습니다
- **"다중 리전 키로 S3 교차 리전 복제의 재암호화를 없앤다"는 거짓이다**
- **"여러 리전에서 클라이언트 측 암·복호"는 다중 리전 키다**
- **"기존 단일 리전 키를 다중 리전으로 바꾼다"는 불가능하다** — 새로 만들어 마이그레이션합니다
- **"AWS 관리형 키를 다중 리전으로"는 불가능하다** — 항상 단일 리전입니다
- **"여러 리전에서 프라이빗 인증서 발급"은 리전마다 CA 생성이다** — 복사 불가입니다
- **"EKS 에 ACM 으로 인증서를 붙인다"는 틀렸다** — EKS 는 ACM 통합 서비스가 아니고, 프라이빗 CA 를 EKS 에 통합합니다

## ⚠️ 흔한 함정 {#pitfalls}

- ❌ "사용자 지정 키 저장소가 더 안전하다" → 공식은 **모두 똑같이 안전하고 운영 절충이 다르다**고 적습니다
- ❌ "준수 요구가 있으면 바로 사용자 지정 키 저장소다" → **규제가 명시적으로 요구할 때만**이고 그마저 위험·비용을 견줘 결정합니다
- ❌ "많은 준수 요구에 키 정책만으로는 부족하다" → 공식은 **키 정책으로 충분한 경우가 많다**고 적습니다
- ❌ "사용자 지정 키 저장소에 키 자료를 가져온다" → **불가능합니다**
- ❌ "사용자 지정 키 저장소 10개 제한은 유형별이다" → **CloudHSM 키 저장소와 외부 키 저장소를 합산**합니다
- ❌ "CloudHSM 키 저장소는 HSM 하나로 된다" → **서로 다른 AZ 의 활성 HSM 최소 두 개**가 필요합니다
- ❌ "키 저장소 연결이 끊겨도 암호화 연산은 된다" → **안 됩니다**
- ❌ "XKS 에서 KMS 가 외부 키 관리자와 직접 통신한다" → **XKS 프록시**만 상대합니다
- ❌ "XKS 에서 AWS 가 내 데이터를 혼자 복호화할 수 있다" → **이중 암호화**라 양쪽 모두 혼자서는 못 합니다
- ❌ "외부 키 관리자를 영구히 끊어도 암호문은 남는다" → **복구 불가**입니다
- ❌ "KMS 와 CloudHSM 의 FIPS 표기는 같다" → **140-3 수준 3** vs **140-2 또는 140-3 수준 3**입니다
- ❌ "AWS 관리형 키의 회전을 끈다" → **항상 매년 회전**하고 끌 수 없습니다
- ❌ "회전하면 기존 데이터가 새 키 자료로 다시 암호화된다" → **재암호화하지 않습니다**
- ❌ "복호화할 키 자료 버전을 내가 고른다" → KMS 가 **암호화에 쓰인 것을 자동으로** 고릅니다
- ❌ "회전 횟수가 쿼터를 깎는다" → **KMS 키 하나**로 셉니다
- ❌ "온디맨드 회전을 하면 자동 회전 일정이 초기화된다" → **바뀌지 않습니다**
- ❌ "관리형 외부 보안 암호 회전도 Lambda 가 필요하다" → **필요하지 않습니다**
- ❌ "교대 사용자 전략에 보안 암호 하나면 된다" → **관리자 자격 증명을 담은 두 번째 보안 암호**가 필요합니다
- ❌ "계정 정책과 로그 그룹 정책 중 하나만 적용된다" → **둘 다 적용**되고 식별자가 **합쳐집니다**
- ❌ "데이터 보호 정책을 켜면 과거 로그도 마스킹된다" → **소급 적용되지 않습니다**
- ❌ "마스킹하면 아무도 원본을 못 본다" → **`logs:Unmask`** 권한이 있으면 봅니다
- ❌ "SNS 데이터 보호 정책에 audit 문장을 여럿 둔다" → **하나**만 둡니다
- ❌ "관련 다중 리전 키는 정책도 함께 바뀐다" → **키마다 따로** 관리합니다
- ❌ "KMS 가 다중 리전 키를 전 리전에 자동 복제한다" → **내가 고른 리전으로 내가 복제**합니다
- ❌ "프라이빗 CA 를 다른 리전으로 복사한다" → **복사할 수 없습니다**
- ❌ "KMS 도 ML-DSA 키 자료를 가져올 수 있다" → **`ML-DSA`·`ML-KEM` 은 제외**입니다

## 🧪 자가 점검

**Q1.** 금융 규제 대응으로 "암호화 키 자료에 대한 통제를 감사인에게 입증해야 한다"는 요구가 왔습니다. 아키텍트가 "CloudHSM 키 저장소가 가장 안전하니 그것으로 가자"고 제안합니다. (→ 1-2 절충안)

<details><summary>정답 보기</summary>

**공식 권고는 「표준 키 저장소 + 가져온 키」입니다. 그리고 「가장 안전하다」는 전제가 공식 서술과 어긋납니다.**

- 공식 「Key stores」 페이지가 직접 적습니다 — **"If you need to demonstrate control over the key material itself, consider using AWS KMS imported keys with the AWS KMS standard key store."** 이 방식이 **고객이 통제하는 키 자료의 준수 이점**을 주면서 **KMS 인프라의 운영 이점(고성능·고가용성)을 유지**합니다
- ⚠️⚠️ 그리고 **"All of the options are equally secure; the difference is in the operational trade-offs"** 입니다. 「더 안전하다」가 아니라 **운영 절충**이 축입니다
- 사용자 지정 키 저장소는 **"규제가 단일 테넌트 HSM 또는 AWS 밖에서 내가 통제하는 HSM 에서의 키 자료 보호를 명시적으로 요구할 때만"** 고려하고, **그마저도** 요건 미달 위험이 **추가 비용·운영 복잡도·성능 저하를 넘어설 때만** 만듭니다
- ⚠️ 많은 준수 요구에는 **키 정책으로 키 접근을 통제하는 것으로 충분**하다고 공식이 적습니다

⚠️ 덤으로 알아 둘 제약 — 사용자 지정 키 저장소를 골랐다면 **대칭 암호화 키만** 만들 수 있어 **비대칭·HMAC·가져온 키 자료·다중 리전 키가 전부 불가**이고 **수동 회전만** 가능합니다.
</details>

**Q2.** 보안 사고로 애플리케이션의 **데이터 키 하나가 유출**됐습니다. 팀이 "그 데이터를 암호화한 KMS 키를 회전하면 해결된다"고 보고합니다. 그리고 그 KMS 키는 가져온 키 자료를 씁니다. (→ 2-2 회전)

<details><summary>정답 보기</summary>

**회전으로 해결되지 않고, 더구나 그 키는 자동 회전 대상이 아닙니다.**

- 공식이 못박습니다 — **"Key rotation will not mitigate the effect of a compromised data key."** 회전은 **현재 키 자료만 바꾸고 데이터를 재암호화하지 않으며 데이터 키를 회전하지도 않습니다.** 유출된 데이터 키로 암호화된 데이터는 그대로 위험합니다 — 필요한 것은 **그 데이터의 재암호화와 유출된 키의 무효화**입니다
- 그리고 ⚠️ **가져온 키 자료(`EXTERNAL` origin)는 자동 회전되지 않습니다.** 가능한 것은 **온디맨드 회전**이고, 그 경로는 **새 키 자료를 가져와 온디맨드 회전**하는 것입니다
- 회전 매트릭스를 기억합니다 — **자동**은 `AWS_KMS` origin 의 대칭 암호화 키만, **온디맨드**는 `AWS_KMS` + `EXTERNAL`, **수동**은 비대칭·HMAC·사용자 지정 키 저장소의 키입니다

⚠️ 복호화 걱정은 하지 않아도 됩니다 — 회전 후에도 KMS 가 **암호화에 쓰인 키 자료를 자동으로 골라** 복호화하므로 코드를 바꾸지 않습니다. 과금은 **2회차 회전에서 상한**이고 쿼터는 **KMS 키 하나**로 셉니다.
</details>

**Q3.** 데이터베이스 자격 증명을 Secrets Manager 로 옮깁니다. 요구는 "회전 중에도 애플리케이션 연결이 끊기지 않아야 한다"와 "회전 때문에 Lambda 함수를 운영하고 싶지 않다"입니다. (→ 3 보안 암호)

<details><summary>정답 보기</summary>

**끊김 없는 회전은 교대 사용자 전략이고, Lambda 를 피하는 길은 관리형 회전입니다 — 다만 둘은 다른 축입니다.**

- 회전의 **형태가 셋**입니다 — **관리형 회전**(서비스가 구성·관리하며 ⚠️ **Lambda 를 쓰지 않습니다**) · **관리형 외부 보안 암호 회전**(파트너 시스템, ⚠️ **Lambda 불필요**) · **Lambda 함수 기반 회전**(그 밖의 유형)
- **전략은 둘**입니다 — **단일 사용자**와 **교대 사용자**. 교대 사용자는 보안 암호 하나에 **두 사용자**를 두고 회전마다 번갈아 바꿔, 공식 표현으로 **"한쪽이 갱신되고 테스트되는 동안 다른 쪽의 자격 증명이 계속 유효"**합니다 — **고가용성이 필요할 때의 선택**입니다
- ⚠️⚠️ **교대 사용자에는 보안 암호가 둘 필요합니다** — 회전할 자격 증명을 담은 것과 **관리자 자격 증명**을 담은 것(그 사용자가 첫 사용자를 복제하고 암호를 바꿉니다). 공식 자습서는 관리자 보안 암호를 **Amazon RDS 가 만들고 관리형 회전으로 관리**하게 합니다
- 즉 두 요구를 함께 만족하는 구성은 **교대 사용자 전략 + 관리자 보안 암호의 관리형 회전**입니다

⚠️ 작업 4.1과 섞지 않습니다 — Secrets Manager 는 **장기 자격 증명을 보관·회전**하고, STS 는 **처음부터 짧은 자격 증명을 발급**합니다.
</details>

**Q4.** 개발자가 실수로 신용카드 번호를 로그에 남겼습니다. 데이터 보호 정책을 즉시 적용했는데 **과거 로그가 여전히 평문**입니다. 그리고 보안팀만 원본을 볼 수 있게 하라는 요구가 있습니다. (→ 4-1 마스킹)

<details><summary>정답 보기</summary>

**정상 동작입니다. 마스킹은 수집 시점에 일어나고 소급 적용되지 않습니다.**

- 공식이 Important 로 적습니다 — **민감 데이터는 로그 그룹에 수집될 때 탐지·마스킹되고, 정책을 설정하기 전에 수집된 로그 이벤트는 마스킹되지 않습니다.** 이미 남은 평문은 **별도로 처리**해야 합니다(보존 기간 단축·해당 로그 스트림 삭제 등)
- 앞으로의 유출은 정책이 막습니다 — **기본적으로 모든 유출 지점에서 마스킹**되고 그 지점에 **Logs Insights · 지표 필터 · 구독 필터**가 포함됩니다
- "보안팀만 원본을 본다"는 ⚠️ **`logs:Unmask` IAM 권한**으로 구현합니다
- 범위 설계도 알아 둡니다 — **계정 전체 정책은 기존·미래의 모든 로그 그룹**에 적용되고, 개별 로그 그룹 정책과 **함께 있으면 양쪽의 관리형 데이터 식별자가 모두** 적용됩니다. **로그 그룹 수준 정책은 로그 그룹당 하나**이고 정책 한도는 **30,720자**입니다
- 탐지에는 **패턴 매칭과 기계 학습**을 쓰고, 일부 관리형 데이터 식별자는 **근처의 특정 키워드**가 함께 있어야 탐지되며, 탐지 시 **`LogEventsWithFindings` 지표**가 발행됩니다

⚠️ 같은 「소급되지 않음」 모양이 이 도메인에 셋입니다 — 여기, **S3 기본 암호화 변경**(기존 객체 그대로), **KMS 키 회전**(재암호화하지 않음).
</details>

**Q5.** 두 리전에서 운영하는 애플리케이션이 S3 교차 리전 복제를 씁니다. 아키텍트가 "다중 리전 KMS 키로 바꾸면 복제 과정의 복호화·재암호화가 없어져 빨라진다"고 제안합니다. (→ 5-1 다중 리전 키)

<details><summary>정답 보기</summary>

**거짓입니다. S3 교차 리전 복제는 관련 다중 리전 키를 써도 데이터 키를 복호화하고 재암호화합니다.**

- 공식이 그 예를 직접 듭니다 — **"Most AWS services … currently treat multi-Region keys as though they were single-Region keys. For example, Amazon S3 cross-Region replication decrypts and re-encrypts the data keys … even when the KMS key in both Regions is a related multi-Region key."**
- 다중 리전 키의 이점은 주로 **클라이언트 측 암호화**(AWS Encryption SDK · AWS Database Encryption SDK · S3 클라이언트 측 암호화)에서 나오고, 서비스별로 다르므로 **서비스 문서를 확인**해야 합니다
- ⚠️ 그리고 **기존 단일 리전 키를 다중 리전 키로 변환할 수 없습니다** — 새 다중 리전 키를 만들어 **마이그레이션**해야 하므로 "바꾸면"이라는 전제 자체가 비용이 큽니다. 공식은 그 설계가 **데이터 상주성·주권** 성질을 유지하기 위한 것이라고 적습니다
- ⚠️ **공식 어조는 보수적입니다** — 대부분의 데이터 보안 요구에는 **리전 격리와 내결함성** 때문에 **단일 리전 키가 가장 잘 맞는다**고 적습니다

⚠️ 관리 성질도 기억합니다 — 관련 키들은 **키 자료와 키 ID 만 같고** 별칭·태그·키 정책·활성화 상태는 **키마다 따로** 관리하며, **AWS 관리형 키는 항상 단일 리전 키**입니다.
</details>

**Q6.** 세 리전에서 내부 서비스 간 mTLS 를 쓰려고 프라이빗 CA 를 세웁니다. 팀이 "CA 를 한 리전에 만들고 다른 리전으로 복사하자"고 하고, "EKS 에는 ACM 으로 인증서를 붙이자"고 합니다. (→ 5-2 Private CA)

<details><summary>정답 보기</summary>

**둘 다 틀렸습니다. CA 는 리전 간 복사가 불가능하고, EKS 는 ACM 통합 서비스가 아닙니다.**

- ⚠️⚠️ **프라이빗 CA 는 리전 리소스이고 리전 간 복사가 불가능**해서 **여러 리전에서 쓰려면 리전마다 만들어야** 합니다. §5-1의 다중 리전 **키**와 대비되는 지점이고, `기술 5.3.5`가 키와 인증서를 한 기술에 묶은 이유입니다
- ⚠️⚠️ **EKS 는 ACM 통합 서비스가 아닙니다.** 그런데 **프라이빗 CA 는 EKS 에 통합해** 클러스터 안에서 인증서를 발급할 수 있습니다 — 경로가 **ACM 이 아니라 Private CA 쪽**입니다
- 배포 경로를 기억합니다 — **ACM 으로 프라이빗 인증서를 요청**하면 ACM 통합 서비스 어디에든 연결할 수 있고(Private CA 루트 체인이든 외부 루트 체인이든), **Private CA API·CLI 로 발급하거나 ACM 에서 내보내면** 어디에든 설치할 수 있습니다. ⚠️ **ACM 이 Private CA 보다 많은 리전에서 제공**됩니다

⚠️ 알고리즘을 서비스 간에 일반화하지 않습니다 — Private CA 는 **`ML_DSA_44`·`ML_DSA_65`·`ML_DSA_87`** 로 발급·서명할 수 있지만 **KMS 는 `ML-DSA`·`ML-KEM` 키에 키 자료를 가져올 수 없습니다.** 그리고 **ACM 이 Private CA 의 CA 로 발급할 때는 알고리즘 일부만** 지원합니다.
</details>

### 📌 출처

1. AWS Key Management Service — `docs.aws.amazon.com/kms/latest/developerguide/overview.html` (2026-11-09 확인)
2. Key stores — `docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html` (2026-11-09 확인)
3. Importing key material for AWS KMS keys — `docs.aws.amazon.com/kms/latest/developerguide/importing-keys.html` (2026-11-09 확인)
4. Rotate AWS KMS keys — `docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html` (2026-11-09 확인)
5. Multi-Region keys in AWS KMS — `docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html` (2026-11-09 확인)
6. AWS CloudHSM key stores — `docs.aws.amazon.com/kms/latest/developerguide/keystore-cloudhsm.html` (2026-11-09 확인)
7. External key stores — `docs.aws.amazon.com/kms/latest/developerguide/keystore-external.html` (2026-11-09 확인)
8. What is AWS CloudHSM? — `docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html` (2026-11-09 확인)
9. What is AWS Private CA? — `docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html` (2026-11-09 확인)
10. Rotate AWS Secrets Manager secrets — `docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html` (2026-11-09 확인)
11. Set up alternating users rotation for AWS Secrets Manager — `docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_rotation-alternating.html` (2026-11-09 확인)
12. Help protect sensitive log data with masking — `docs.aws.amazon.com/AmazonCloudWatch/latest/logs/mask-sensitive-log-data.html` (2026-11-09 확인)
13. Creating data protection policies in Amazon SNS — `docs.aws.amazon.com/sns/latest/dg/sns-message-data-protection-configure.html` (2026-11-09 확인)
