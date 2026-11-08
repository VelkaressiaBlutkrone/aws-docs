---
생성: 2026-11-08
목적: SCS-C03 신규 기술 5.3.3(가져온 키 자료 vs AWS 생성 키 자료)·5.3.5(단일·다중 리전 키와 인증서)의 공식 근거와 키 저장소 4종의 계보 수집
대상 기술: 5.2.1 · 5.3.2 · 5.3.3 · 5.3.5 (보조: 5.1.3)
조회일: 2026-11-08 (명시가 없는 모든 인용의 조회일이다)
---

# 95 — 키 관리 계보 (SCS-C03)

## 1. 왜 이 노트가 필요한가

C03이 **`기술 5.3.3`을 신설**해 "가져온 키 자료와 AWS에서 생성한 키 자료 간 절충안"을, **`기술 5.3.5`를 신설**해 "여러 AWS 서비스나 계정 전반에서 암호화 키를 관리하는 방법을 선택 및 구현(예: AWS KMS 사용자 지정 AWS KMS 키, AWS Private Certificate Authority)"을 요구한다(00-overview §10). 둘 다 **C02에 없던 기술**이라 기존 교재가 얇다.

`기술 5.3.3`은 **「절충안」**(trade-offs)을 묻는다 — 즉 **「BYOK가 더 안전하다」가 답이 아니고, 무엇을 얻고 무엇을 잃는지**가 답이다. 그 절충은 공식 문서에 **명시적 권고 문장**으로 적혀 있다(§3). `기술 5.3.5`는 **다중 리전**이라는 낱말 때문에 다중 리전 키 하나로 보이지만, 실측하면 **대부분의 AWS 서비스가 다중 리전 키를 단일 리전 키처럼 다룬다**(§6). 그 둘이 이 노트의 중심이다.

## 2. 계보 — 키 자료가 어디서 와서 어디 사는가

**`Origin` 값이 계보를 가른다.** KMS 키를 만들 때 지정하는 이 값이 네 갈래이고, **거기서 거의 모든 제약이 파생된다.**

| `Origin` | 키 자료 생성·보관 | 한국어 이름 |
| --- | --- | --- |
| `AWS_KMS` (기본) | AWS KMS가 생성, KMS HSM에 보관 | 표준 키 저장소 |
| `EXTERNAL` | **내가 생성**해 KMS로 **가져온다**(BYOK) | 가져온 키 자료 |
| `AWS_CLOUDHSM` | KMS가 **내 CloudHSM 클러스터 안에서** 생성 | CloudHSM 키 저장소 |
| `EXTERNAL_KEY_STORE` | **AWS 밖 외부 키 관리자**가 보관(HYOK) | 외부 키 저장소(XKS) |

**KMS 자체의 기준선**: KMS 키는 **FIPS 140-3 보안 수준 3** 검증 HSM으로 보호되고 **암호화되지 않은 상태로 KMS를 떠나지 않는다**([AWS Key Management Service](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)).

⚠️⚠️ **사용자 지정 키 저장소**(CloudHSM 키 저장소 + XKS)에서는 **대칭 암호화 키만** 만들 수 있다. 공식 API 설명이 "Use the default `KeySpec` value, `SYMMETRIC_DEFAULT`, and the default `KeyUsage` value, `ENCRYPT_DECRYPT` … **No other key type is supported in a custom key store**"로 적는다. 그래서 사용자 지정 키 저장소에서는 **비대칭 키·HMAC 키·가져온 키 자료·다중 리전 키가 전부 불가**다. 이 한 줄이 §4~§7의 제약 다수를 설명한다.
⚠️ 계정·리전마다 **사용자 지정 키 저장소는 최대 10개**이고 **CloudHSM 키 저장소와 외부 키 저장소를 합산**하며 **연결 상태와 무관**하게 센다.

## 3. ⚠️⚠️ 절충안의 공식 답 — `기술 5.3.3`의 핵심

출처: [Key stores](https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html)

공식 문서가 **권고를 직접 적는다.** 이 세 문장이 `기술 5.3.3`의 답이다.

> 1. "For most customers, the **AWS KMS standard key store** provides the optimal balance of security, performance, cost, and operational simplicity."
> 2. "If you need to **demonstrate control over the key material itself**, consider using **AWS KMS imported keys with the AWS KMS standard key store**. This approach provides compliance benefits of customer-controlled key material **while maintaining the operational advantages of AWS KMS infrastructure**, including high performance and availability."
> 3. "Consider creating a custom key store **only when your organization has regulatory requirements that explicitly mandate** key material protection in a single-tenant HSM or in an HSM that you control outside of AWS. **Even then**, create one only when the risk of not meeting those requirements outweighs the additional cost, operational complexity, and reduced performance."

⚠️⚠️ **「모든 옵션은 똑같이 안전하다」** — "All of the options are **equally secure**; the difference is in the **operational trade-offs**." 즉 **보안 강도가 아니라 운영 절충**이 축이다. 「CloudHSM 키 저장소가 더 안전하니 그쪽을 고른다」는 공식 서술과 어긋난다.
⚠️⚠️ **「키 자료에 대한 통제를 입증해야 한다」는 요구의 공식 답은 사용자 지정 키 저장소가 아니라 「표준 키 저장소 + 가져온 키」다.** 이 레포가 문항으로 만들 가장 중요한 갈림길이고, 많은 교재가 거꾸로 적는 자리다.
⚠️ 많은 준수 요구에는 **키 정책으로 키 접근을 통제하는 것으로 충분하다**("For many compliance requirements, the control you have over key access through the KMS key policy is sufficient").
⚠️ [Key management best practices for AWS KMS](https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-kms-best-practices/key-management.html)가 보강한다: KMS가 제공하는 **모든 키 저장소 유형이 FIPS 140 보안 수준 3으로 계속 검증**되고 "**AWS 운영자를 포함해 누구도** 평문 키에 접근하거나 허가 없이 쓰지 못하게 설계"된다. 결제 워크로드는 **AWS Payment Cryptography**가 따로 있다.

## 4. 가져온 키 자료 (BYOK) — `기술 5.3.3`

출처: [Importing key material for AWS KMS keys](https://docs.aws.amazon.com/kms/latest/developerguide/importing-keys.html)

키 자료 없이 KMS 키를 만든 뒤 내 키 자료를 가져오는 기능이고 흔히 **BYOK**로 불린다. **"키 자료에 대한 책임은 내게 남고 AWS KMS가 그 사본을 쓰게 하는 것"**이다.

### ⚠️⚠️ 가장 중요한 제약 — 가져왔어도 KMS 밖에서는 복호화할 수 없다

> "AWS KMS does **not** support decrypting any AWS KMS ciphertext encrypted by a symmetric encryption KMS key **outside of AWS KMS, even if the ciphertext was encrypted under a KMS key with imported key material**. AWS KMS does not publish the ciphertext format this task requires, and the format might change without notice."

**「내 키를 가져왔으니 내 쪽에서 복호화할 수 있다」는 거짓이다.** 암호문 형식이 비공개이고 예고 없이 바뀔 수 있다. 이것이 BYOK의 **가장 자주 오해되는 한계**다.

### 가져오는 이유 6종 (공식 열거)

1. **요건을 충족하는 엔트로피 소스**로 키 자료를 생성했음을 입증한다.
2. 내 인프라의 키 자료를 AWS 서비스와 함께 쓰고, **그 키 자료의 수명 주기 관리를 AWS KMS에 맡긴다.**
3. **코드 서명 · PKI 인증서 서명 · 인증서 고정(pinned) 애플리케이션** 같은 기존의 확립된 키를 AWS KMS에서 쓴다.
4. ⚠️ **키 자료에 만료 시각을 설정하고 수동으로 삭제한 뒤 나중에 다시 쓸 수 있게 한다.** 대비되는 것이 **키 삭제 예약**인데 그쪽은 **7~30일 대기 기간** 뒤 **복구 불가**다.
5. 키 자료의 **원본 사본을 내가 소유**하고 수명 주기 전체에 걸쳐 AWS 밖에 보관해 **내구성·재해 복구**에 쓴다.
6. **비대칭 키·HMAC 키**에서는 가져오기가 **AWS 안과 밖에서 모두 동작하는 호환·상호 운용 키**를 만든다.

### 지원·제약

- 지원 키 유형: **대칭 암호화 키 · 비대칭 키(⚠️ `ML-DSA`·`ML-KEM` 제외) · HMAC 키 · 지원되는 모든 유형의 다중 리전 키**.
- ⚠️ **사용자 지정 키 저장소의 KMS 키에는 키 자료를 가져올 수 없다**(§2의 귀결).
- 리전: **AWS KMS가 지원하는 모든 리전**. ⚠️ **중국 리전은 대칭 암호화 키의 키 자료 요건이 다르다.**
- 운영 수단: **만료 임박 CloudWatch 경보** · **키 자료 재가져오기**(reimport) · **새 키 자료를 가져와 온디맨드 회전** · 가져온 키 자료를 쓰는 키 **식별·조회**.

## 5. 회전 — `기술 5.3.2`

출처: [Rotate AWS KMS keys](https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html)

⚠️⚠️ **회전 방식 3종의 적용 범위가 다르고, 여기서 `EXTERNAL` 키의 운명이 갈린다.**

| 방식 | 적용되는 키 | 비고 |
| --- | --- | --- |
| **자동 회전** | **`AWS_KMS` origin의 대칭 암호화 키만** | 기본 **매년**, **사용자 지정 회전 주기**(일 수) 지정 가능. 고객 관리형 키에만 **선택적** |
| **온디맨드 회전** | `AWS_KMS` origin **+ `EXTERNAL`(가져온) origin**의 대칭 암호화 키 | 자동 회전 활성화 여부와 무관하게 즉시 실행. **기존 자동 회전 일정은 바뀌지 않는다** |
| **수동 회전**(새 키를 만들어 교체) | **비대칭 키 · HMAC 키 · 사용자 지정 키 저장소의 키** | 자동도 온디맨드도 지원되지 않는다 |

⚠️⚠️ **가져온 키 자료는 자동 회전되지 않지만 온디맨드 회전은 된다.** `기술 5.3.2`가 "가져온 키 자료를 교체 및 회전"을 명시하는데, 그 경로가 **「새 키 자료를 가져와 온디맨드 회전」**이다(§4 마지막 줄).
⚠️ **AWS 관리형 키는 AWS가 항상 매년 회전한다**("AWS KMS **always** rotates the key material for AWS managed KMS keys every year") — 끌 수 없다. **AWS 소유 키**의 회전은 **그 키를 소유한 AWS 서비스가 관리**한다.
⚠️ **회전은 현재 키 자료만 바꾼다.** 복호화 시 KMS가 **암호화에 쓰인 키 자료를 자동으로 고른다** — 복호화용 키 자료를 고를 수 없고, 코드 변경 없이 안전하게 쓸 수 있다.
⚠️⚠️ **회전은 데이터를 재암호화하지 않고 데이터 키를 회전하지도 않는다.** "Key rotation **will not mitigate the effect of a compromised data key**." 「키를 회전했으니 유출된 데이터 키의 영향이 사라진다」는 거짓이다.
⚠️ **과금은 1·2회차 회전까지만** — "AWS KMS charges a monthly fee for **first and second** rotation of key material … This price increase is **capped at the second rotation**, and any subsequent rotations will not be billed."
⚠️ **쿼터는 회전 횟수와 무관** — 회전된 키 자료 버전이 몇 개든 **KMS 키 하나로 센다.**
⚠️ 공식 권고 순서: **지원되면 자동 회전 → 자동이 안 되면 온디맨드 → 둘 다 안 되면 수동.** 그리고 "계획되지 않은 회전에는 온디맨드를, 가능하면 **사용자 지정 주기의 자동 회전**을" 권한다.
⚠️ 상태 조회 API가 둘이다: **`GetKeyRotationStatus`**(자동 회전 활성화 여부 + 진행 중인 온디맨드 회전) · **`ListKeyRotations`**(완료된 회전 상세).
⚠️ **왜 회전하나**의 공식 논지: KMS 키는 대개 **래핑 키**(키 암호화 키)여서 데이터 키만큼 자주 쓰이지 않아 **고갈 위험이 매우 낮다.** 그래도 회전하는 이유는 **사업·계약 규칙이나 정부 규정** 때문이다. 「보안상 반드시 회전해야 한다」가 아니라 **「요구되면 회전한다」**가 공식 어조다.

## 6. 다중 리전 키 — `기술 5.3.5`

출처: [Multi-Region keys in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/multi-region-keys-overview.html)

서로 **관련된**(related) 다중 리전 키 집합은 **같은 키 자료와 같은 키 ID**를 가져, 한 리전에서 암호화한 데이터를 **재암호화나 교차 리전 호출 없이** 다른 리전에서 복호화할 수 있다.

### ⚠️⚠️ 가장 중요한 실측 — 대부분의 AWS 서비스는 다중 리전 키를 단일 리전 키처럼 다룬다

> "**Most AWS services** that integrate with AWS KMS for encryption at rest or digital signatures currently treat multi-Region keys **as though they were single-Region keys**. For example, **Amazon S3 cross-Region replication decrypts and re-encrypts the data keys** used to encrypt object data under the KMS key in the destination Region, **even when the KMS key in both Regions is a related multi-Region key**."

**「다중 리전 키를 쓰면 S3 교차 리전 복제가 재암호화를 건너뛴다」는 거짓이다.** 다중 리전 키의 이점은 주로 **클라이언트 측 암호화**(AWS Encryption SDK · AWS Database Encryption SDK · S3 클라이언트 측 암호화)에서 나온다. 서비스별로 다르므로 **서비스 문서를 확인하라**고 공식이 적는다.

### 그 밖의 비자명한 사실

- ⚠️ **독립적으로 관리한다** — 별칭·태그 생성, 키 정책·권한 부여 설정, 활성화·비활성화를 **키마다 따로** 한다. "같은 키"가 아니라 **"같은 키 자료를 가진 서로 다른 키"**다.
- ⚠️ **글로벌이 아니다** — 기본 키를 만들고 **내가 고른 리전으로, 한 AWS 파티션 안에서** 복제한다. **AWS도 KMS도 대신 복제하지 않는다.**
- ⚠️⚠️ **AWS 관리형 키는 항상 단일 리전 키다.**
- ⚠️⚠️ **기존 단일 리전 키를 다중 리전 키로 변환할 수 없다** — "This design ensures that all data protected with existing single-Region keys maintain the same **data residency and data sovereignty** properties." 설계 단계에서 결정해야 하는 값이다.
- ⚠️ **사용자 지정 키 저장소에는 다중 리전 키를 만들 수 없다**(§2의 귀결).
- ⚠️ **가져온 키 자료로도 다중 리전 키를 만들 수 있다.**
- ⚠️ 요금·쿼터: 관련 집합의 **키 하나하나가 각각 하나의 KMS 키**로 과금·집계되고, **쿼터는 계정의 리전마다 따로** 계산된다.
- ⚠️ 중국 리전은 **`aws-cn` 파티션 안에서만** 복제된다(베이징 ↔ 닝샤). 파티션을 넘는 복제는 양방향 모두 불가.
- ⚠️ **공식 어조는 보수적이다** — "For most data security needs, the **Regional isolation and fault tolerance** of Regional resources make standard AWS KMS **single-Region keys a best-fit solution.**" 다중 리전 키는 **클라이언트 측에서 여러 리전에 걸쳐 암호화·서명해야 할 때**의 해법이다.
- 기본 키 교체 수단이 있다(`rotate-keys.html`의 하위 주제 "Change the primary key in a set of multi-Region keys").

## 7. CloudHSM 키 저장소

출처: [AWS CloudHSM key stores](https://docs.aws.amazon.com/kms/latest/developerguide/keystore-cloudhsm.html)

내가 소유·관리하는 **CloudHSM 클러스터**로 뒷받침되는 사용자 지정 키 저장소다. KMS 키를 만들면 **추출 불가능한**(non-extractable) 키 자료를 그 클러스터에 생성·보관하고, 암호화 연산은 **클러스터의 HSM에서** 수행된다.

- ⚠️ **클러스터에 서로 다른 가용 영역의 활성 HSM이 최소 두 개** 있어야 한다.
- ⚠️ KMS 전용 **크립토 사용자**(CU) 계정이 필요하고, KMS가 그 자격 증명으로 클러스터에 로그인한다.
- ⚠️ **연결이 끊긴 동안에는 KMS가 접근할 수 없고 그 키로 암호화 연산을 할 수 없다.**
- ⚠️ **리전 제약이 있다** — KMS가 지원하는 모든 리전에서 쓸 수 있으나 **아시아 태평양(멜버른) · 중국(베이징) · 중국(닝샤) · 유럽(스페인)은 제외**다.
- 관리 접점이 둘로 갈린다: **키 저장소는 KMS에서, HSM 클러스터는 CloudHSM에서** 만들고 관리한다. 키 자료는 **CloudHSM 클라이언트와 지원 소프트웨어 라이브러리로 조회·감사·관리**할 수 있다.
- 비용은 **CloudHSM 클러스터·HSM 비용이 별도로** 든다.

## 8. 외부 키 저장소 (XKS)

출처: [External key stores](https://docs.aws.amazon.com/kms/latest/developerguide/keystore-external.html)

AWS 밖의 **외부 키 관리자**로 뒷받침되는 사용자 지정 키 저장소이고, 암·복호 연산을 **내 외부 키 관리자가 내 키 자료로** 수행한다 — **HYOK**(hold your own keys)다. **AWS 디지털 주권 서약**(digital sovereignty pledge)을 뒷받침한다.

- ⚠️⚠️ **KMS는 외부 키 관리자와 직접 통신하지 않는다.** 내가 제공하는 **외부 키 저장소 프록시**(XKS 프록시) 소프트웨어만 상대하고, 그 프록시가 모든 통신을 중개하며 KMS의 일반 요청을 **벤더별 형식으로 번역**한다. 프록시는 **AWS KMS External Key Store Proxy API Specification**을 따라야 한다.
- ⚠️⚠️ **이중 암호화**(double encryption) — "AWS KMS **first encrypts all plaintext with AWS KMS key material** specific to your KMS key, and then sends it to your external key manager for encryption with your external key." 결과적으로 **"AWS KMS도, 외부 키 자료의 소유자도 혼자서는 이중 암호화된 암호문을 복호화할 수 없다."**
- ⚠️⚠️ **접근을 끊으면 복호화가 멈춘다.** 일시적으로 끊으면(키 저장소 연결 해제 등) **복원할 때까지 그 키로 암호화된 암호문을 복호화할 수 없고**, **영구적으로 끊으면 그 암호문은 복구 불가**다. 예외는 **데이터 키를 짧게 캐시하는 AWS 서비스**뿐이고, 그것도 리소스를 비활성화하거나 캐시가 만료될 때까지만이다.
- ⚠️⚠️ **공유 책임 모델이 크게 이동한다.** 표준 KMS 키에서는 KMS가 키 자료의 **보안·가용성·지연·내구성**을 책임지는데, XKS에서는 **외부 키 관리자의 암호화 키에 대한 보안·신뢰성·내구성·성능이 내 책임**이다. KMS의 책임은 **요청에 신속히 응답하고 프록시와 통신하며 보안 표준을 유지하는 것**까지다.
- ⚠️⚠️ **공식이 직접 경고한다** — "they are a **major departure from the standard shared responsibility model** … The greater risk to availability and latency will, **for most customers, exceed the perceived security benefits** of external key stores." 「규제가 명시적으로 요구하는 소수의 사례」를 위한 기능이다.
- **대칭 암호화를 위한 고객 관리형 키를 지원하는 AWS 서비스는 XKS의 KMS 키도 지원한다.** 클라이언트 측 암호화(AWS Encryption SDK 포함)에도 쓸 수 있다.
- ⚠️ 프록시 연결 방식이 둘이다: **퍼블릭 엔드포인트**와 **VPC 엔드포인트 서비스**(`XksProxyConnectivity`가 `VPC_ENDPOINT_SERVICE`면 `XksProxyVpcEndpointServiceName`을 지정).
- ⚠️ **사용자 지정 키 저장소는 중국 리전에서 제공되지 않고, 비대칭 KMS 키에는 쓸 수 없다**([AWS KMS Features](https://aws.amazon.com/kms/features/)).

## 9. AWS CloudHSM 자체 — KMS와 다른 선택

출처: [What is AWS CloudHSM?](https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html)

`기술 5.2.1`이 "AWS CloudHSM 또는 AWS KMS 중에서 암호화 키 관리 전략 선택"을 묻는다. §7·§8은 **KMS를 쓰면서 CloudHSM·외부 HSM을 뒤에 두는** 경로이고, 이 절은 **CloudHSM을 직접 쓰는** 경로다.

- ⚠️ **클러스터 모드가 둘이다**: **FIPS 모드**에서는 **FIPS 검증 키와 알고리즘만** 쓸 수 있고, **비FIPS 모드**는 CloudHSM이 지원하는 모든 키·알고리즘을 FIPS 승인 여부와 무관하게 쓸 수 있다.
- ⚠️ HSM은 **범용**(general purpose)이고 **단일 테넌트**이며, **FIPS 모드 클러스터는 FIPS 140-2 수준 3 또는 FIPS 140-3 수준 3** 검증이다. 「범용」이 요점 — 완전관리형 AWS 서비스는 알고리즘·키 길이가 정해져 있다.
- ⚠️⚠️ **데이터 플레인이 종단 간 암호화돼 AWS에 보이지 않고, 그 대가로 사용자 관리를 내가 한다**("you control your own user management (**outside of IAM roles**)"). **IAM이 아니라 HSM 자체의 사용자 체계**다 — 「IAM 정책으로 CloudHSM 키 사용자를 통제한다」는 거짓이다.
- ⚠️ 키를 **생성·보관·가져오기·내보내기·관리·사용**할 수 있다(세션 키·토큰 키·대칭 키·비대칭 키 쌍). **내보내기가 가능하다**는 점이 KMS와의 큰 차이다.
- ⚠️ **PKCS #11 · JCE · CNG · KSP**를 쓰는 기존 PKI를 **애플리케이션 변경을 줄여** 옮길 수 있다 — 「레거시 HSM 인터페이스」가 CloudHSM을 고르는 전형적 이유다.
- ⚠️ 공식 자신이 분기를 적어 둔다: **HSM을 직접 운영할 필요가 없다면 KMS**, **결제 처리용 HSM·키의 탄력적 관리가 필요하면 AWS Payment Cryptography.**

## 10. 인증서 쪽 절반 — AWS Private CA (`기술 5.3.5`)

출처: [What is AWS Private CA?](https://docs.aws.amazon.com/privateca/latest/userguide/PcaWelcome.html)

**루트·하위 CA를 포함한 프라이빗 CA 계층**을 만들고 **종단 엔터티 X.509 인증서**를 발급한다. 용도는 **TLS 통신 채널 · 사용자·컴퓨터·API 엔드포인트·IoT 디바이스 인증 · 코드 서명 · OCSP 구현**이다.

- ⚠️⚠️ **프라이빗 CA는 리전 리소스이고 리전 간 복사가 불가능하다** — 여러 리전에서 쓰려면 **리전마다 만들어야** 한다. §6의 다중 리전 **키**와 대비되는 지점이고, `기술 5.3.5`가 키와 인증서를 한 기술에 묶은 이유다.
- ⚠️ **ACM이 AWS Private CA보다 많은 리전에서 제공된다**("ACM is currently available in some regions that AWS Private CA is not").
- ⚠️ **ACM으로 프라이빗 인증서를 요청하면** ACM 통합 서비스 어디에든 연결할 수 있다(AWS Private CA 루트 체인이든 **외부 루트** 체인이든). **Private CA API·CLI로 발급하거나 ACM에서 내보내면** 어디에든 설치할 수 있다.
- ⚠️⚠️ **EKS는 ACM 통합 서비스가 아니다** — 그런데 **프라이빗 CA는 EKS에 통합해** 클러스터 안에서 인증서를 발급할 수 있다. 둘을 섞으면 거짓이 된다.
- ⚠️ **지원 알고리즘에 양자 내성 `ML_DSA_44`·`ML_DSA_65`·`ML_DSA_87`이 든다**(개인 키 알고리즘과 서명 알고리즘 양쪽). 그 밖에 RSA 2048/3072/4096 · EC prime256v1/secp384r1/secp521r1 · **SM2(중국 리전 전용)**이고 서명은 SHA256/384/512 WITH RSA·ECDSA · SM3WITHSM2다. ⚠️ **ML-DSA는 해시 함수가 알고리즘에 포함돼 고를 수 없고, API 호환을 위해 키 알고리즘과 서명 알고리즘에 같은 값을 쓴다.**
- ⚠️ **이 알고리즘 목록은 Private CA가 직접 발급할 때의 것**이고, **ACM이 Private CA의 CA로 발급할 때는 일부만 지원한다.**
- ⚠️ **RFC 5280을 일부만 강제한다** — 강제하는 것: 발급 CA 인증서의 `Not After`를 넘는 인증서 발급 금지 · 가져온 CA 인증서의 **기본 제약**(`critical`로 표시 + `CA=true` 필수) · **경로 길이**(`pathLenConstraint`) · **이름 제약**.
- ⚠️ **ML-DSA 지원이 §4의 제약과 엇갈린다** — KMS는 **`ML-DSA`·`ML-KEM` 키에 키 자료를 가져올 수 없는데** Private CA는 ML-DSA로 발급·서명한다. **두 서비스의 양자 내성 알고리즘 지원 범위를 같다고 쓰면 거짓이 된다.**

## 11. 경계 표

| 요구 | 공식 답 | 흔한 오답과 이유 |
| --- | --- | --- |
| 대부분의 워크로드 | **표준 키 저장소**(`AWS_KMS`) | 사용자 지정 키 저장소 — 공식이 **규제가 명시적으로 요구할 때만** 권한다 |
| **키 자료 통제를 입증**해야 한다 | **표준 키 저장소 + 가져온 키**(§3) | CloudHSM 키 저장소 — 운영 부담이 크고 공식 권고가 아니다 |
| 단일 테넌트 HSM을 규제가 명시적으로 요구 | **CloudHSM 키 저장소** | — |
| 키가 **AWS 밖에** 있어야 한다 | **외부 키 저장소(XKS)** | 가져온 키 자료 — **키 자료의 사본이 KMS에 있다** |
| 레거시 PKCS #11·JCE 애플리케이션 | **CloudHSM 직접 사용** | KMS — 알고리즘·키 길이가 정해져 있고 **키를 내보낼 수 없다** |
| 가져온 키 자료를 **회전** | **새 키 자료를 가져와 온디맨드 회전** | 자동 회전 — **`AWS_KMS` origin에만** 적용된다 |
| 비대칭 키·HMAC 키를 **회전** | **수동 회전**(새 키로 교체) | 자동·온디맨드 — 지원되지 않는다 |
| 여러 리전에서 **클라이언트 측** 암·복호 | **다중 리전 키** | — |
| S3 교차 리전 복제의 재암호화를 없앤다 | **그런 방법이 없다** | 다중 리전 키 — **S3 CRR은 그래도 재암호화한다**(§6) |
| 기존 단일 리전 키를 여러 리전에서 쓴다 | **새 다중 리전 키를 만들어 마이그레이션** | 변환 — **불가능하다** |
| 여러 리전에서 프라이빗 인증서 발급 | **리전마다 프라이빗 CA 생성** | 복사 — **리전 간 복사 불가** |
| 사용자 지정 키 저장소에서 비대칭 서명 | **그런 방법이 없다** | — **대칭 암호화 키만** 지원한다(§2) |

## 12. 출제 각도 (저작 시 참고)

1. **「키 자료 통제 입증」 요구 → 표준 키 저장소 + BYOK**(§3). 보기에 CloudHSM 키 저장소·XKS를 섞으면 전형적인 Specialty 문항이 된다.
2. **BYOK의 한계** — "가져온 키로 암호화했으니 온프레미스에서 복호화하겠다" → **불가**(§4).
3. **삭제의 비가역성 대비** — 키 자료 만료·수동 삭제(복구 가능) vs 키 삭제 예약 **7~30일**(복구 불가).
4. **회전 매트릭스** — origin과 키 종류를 주고 어느 회전이 가능한지. 특히 **가져온 키 = 온디맨드만**.
5. **회전의 오해** — "데이터 키가 유출됐으니 KMS 키를 회전한다" → **완화되지 않는다**(§5).
6. **다중 리전 키의 서비스 동작** — S3 CRR 재암호화(§6). 「교차 리전 호출 없이 복호화」가 성립하는 자리는 **클라이언트 측 암호화**다.
7. **AWS 관리형 키의 성질** — 항상 단일 리전, 매년 강제 회전.
8. **XKS 가용성 사고** — 외부 키 관리자가 내려가면 어떻게 되는가(캐시된 데이터 키의 예외까지).
9. **이중 암호화의 의미** — "AWS가 내 데이터를 혼자 복호화할 수 있나" → 아니다. "내가 혼자 할 수 있나" → 그것도 아니다.
10. **CloudHSM 사용자 관리** — IAM이 아니다(§9).
11. **인증서의 리전성** — 다중 리전 **키**는 있는데 다중 리전 **CA**는 없다(§10).

## 13. 단정하지 않는 것

1. **FIPS 수준 표기를 섞지 않는다** — KMS는 **FIPS 140-3 보안 수준 3**, CloudHSM FIPS 모드 클러스터는 **140-2 수준 3 또는 140-3 수준 3**으로 적힌다. **「둘 다 140-3 수준 3」으로 단정하지 않는다.**
2. **양자 내성 알고리즘 지원 범위를 서비스 간에 일반화하지 않는다**(§10 마지막 줄).
3. **다중 리전 키를 「대부분의 경우 더 좋다」로 쓰지 않는다** — 공식 어조는 반대다(§6).
4. **「사용자 지정 키 저장소가 더 안전하다」로 쓰지 않는다** — 공식은 **「모두 똑같이 안전하고 운영 절충이 다르다」**로 적는다(§3).
5. **Secrets Manager(`기술 5.3.1`)와 민감 데이터 마스킹(`기술 5.3.4`)은 이 노트 범위 밖이다** — 5.3.4는 **AIF 트랙에 이미 실측 자산이 있다**(00-overview §10의 ⭐ 항목: CloudWatch Logs 데이터 보호 정책은 **소급 적용되지 않는다**). 저작 시 그쪽을 재사용하고, **SNS 메시지 데이터 보호는 유지 관리 상태**임을 함께 적는다(99-gaps G-15).

## 14. 측정 기록

이 노트가 인용하는 URL은 전부 **`200 r=0`**(2026-11-08, `curl -sL`). 방법·대조군은 **93 §8이 정본**이다.

이 노트와 직접 관련된 죽은 슬러그 2건:

| 슬러그 | 신호 | 판정 |
| --- | --- | --- |
| `kms/latest/developerguide/custom-key-store-overview.html` | `200 r=1` → 가이드 인덱스 | **페이지 소멸.** ⚠️⚠️ **AWS Go SDK 문서(`sdk-for-go/api/service/kms/`)가 아직 이 URL을 링크한다** — 3자 페이지에서 URL을 베끼면 죽은 슬러그를 인용한다(2026-11-08 P-01이 `STS/latest/APIReference/welcome.html`에서 같은 패턴을 실측했다) |
| `kms/latest/developerguide/choose-keystore.html` | `200 r=1` → 가이드 인덱스 | **내가 본문 링크 텍스트("Choosing the right key store")에서 유도한 슬러그이고 틀렸다.** 정본은 **`key-store-overview.html`**이다 |

⚠️ **링크 텍스트에서 슬러그를 유도하지 않는다.** 실측이 없었으면 이 노트의 §3 — 절충안의 공식 답을 담은 절 — 전체가 **죽은 URL을 근거로** 적혔다.
