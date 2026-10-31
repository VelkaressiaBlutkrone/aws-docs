# saa-t1-5 재검수 1단계 판정 (AI 권고 — 검수자 확정 필요)

- 세션: happy-ishizaka-6bf751 (worktree `D:\workspace\awc-docs\.claude\worktrees\happy-ishizaka-6bf751`)
- 기준 커밋: `f8078f6` (main merge #163)
- 날짜: 2026-10-20
- 대상: `flutter_app/assets/content/saa/saa-t1-5.questions.json` 15문항
- C6(구조): `node tool/saa_prescreen.mjs build` → **24 Task 전체 구조 플래그 0건** (실측)

## 핵심 원인 — 문서는 고쳐졌고 문항은 안 고쳐졌다

`saa-t1-5.md` 는 **2026-10-19에 8건 정정**됐다(md 374행 정정 로그). 그 정정 내용이
문항에는 전파되지 않았다. 내가 찾은 내용 결함 5건이 **전부 md가 이미 바로잡은 항목**이다:

| md 정정(2026-10-19) | md 현재 서술 | 문항 상태 |
|---|---|---|
| ③ AWS 관리형 키 ≠ AWS 소유 키 | md 118행: 관리형 키는 "내 계정에 있어 보이고 감사할 수 있지만" | q2 wrong["1"]이 아직 "AWS 소유로" |
| ① 키 정책·IAM 관계(계정 위임/직접 허용/암시적 거부) | md 374행 ① | q4 해설이 아직 "Principal로 명시되지 않으면 차단" |
| ② FIPS 결정 규칙 → 단일 테넌트 기준 | md 192·330행 | q5가 아직 "AWS가 키에 접근" 근거 |
| ⑥ ACM 자동 갱신(DNS만 완전 자동·45일) | md 206행 | q7이 아직 "이메일 검증도 자동 갱신" |
| ⑦ Vault Lock 유예 = 사용자 지정 최소 3일 | md 278행 | q13이 아직 "쿨다운(기본 3일)" |

→ 이번 작업은 **문항을 이미 검증된 md 기준으로 맞추는 것**이며, md의 출처 목록
(5·6·7·9·11·12번)이 그대로 문항 출처로 쓸 수 있는 공식 URL이다.

## 15행 판정표

판정 열은 모두 **AI 권고 — 검수자 확정 필요**다.

| # | skill | C1 정답 | C2 해설 | C3 오답근거 | C4 출처 | C5 범위 | C6 구조 | 판정 | 메모 |
|---|---|---|---|---|---|---|---|---|---|
| q1 | at-rest vs in-transit | ✅ 0 | ✅ | ✅ | △ | ✅ | ✅ | **pass** | KMS overview는 총론이지만 ACM overview가 TLS 절반을 직접 뒷받침. 매핑 무중의 |
| q2 | KMS 키 유형 | ✅ 2 | ✅ | ❌ | ❌ | ✅ | ✅ | **fix + resource** | wrong["1"]이 AWS 관리형 키를 "AWS 소유"로 서술. 공식: 관리형 키는 **내 계정에 존재**하고 조회·감사 가능, 다만 수명주기·권한을 관리 못 함 |
| q3 | 봉투 암호화 | ✅ 3 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | 내용 정확(4KB·GenerateDataKey). 인용 overview.html에 그 서술 없음 |
| q4 | 키 정책 필수성 | ✅ 1 | ❌ | ✅ | ❌ | ✅ | ✅ | **fix + resource** | 해설 "키 정책에 역할이 Principal로 명시되지 않으면 차단"이 과단정. 공식: **기본 키 정책이 IAM을 활성화**하므로 계정 위임 경로로도 허용된다 |
| q5 | KMS vs CloudHSM | ✅ 0 | ❌ | ❌ | △ | ✅ | ✅ | **fix + resource** | 정답은 유지(단일 테넌트 요건). 다만 "KMS는 AWS가 키에 접근" 근거가 공식과 어긋남 — AWS는 **모든 키 저장소가 AWS 운영자의 평문 키 접근을 막는다**고 명시. 갈림길은 단일 테넌트 여부 |
| q6 | CloudHSM 서비스 통합 | ✅ 0 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | custom key store 근거가 인용 introduction.html에 없음 |
| q7 | ACM 자동 갱신 | ✅ 2 | ❌ | △ | ❌ | ✅ | ✅ | **fix + resource** | 공식: **완전 자동 갱신은 DNS 검증**. 이메일 검증은 ACM이 알림 메일을 보내고 소유자가 응답해야 함. 적격 조건에 "AWS 서비스에서 사용 중"도 포함 |
| q8 | CloudFront us-east-1 | ✅ 2 | ❌ | ✅ | ✅ | ✅ | ✅ | **fix** | "컨트롤 플레인이 배포 설정을 엣지 PoP에 복제" 기전은 **공식 근거 미확인**. 공식 문구는 "us-east-1 인증서가 배포에 연결되면 그 배포에 설정된 모든 지리적 위치로 배포된다" |
| q9 | Macie PII 탐지 | ✅ 1 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | 출처가 KMS overview — 복붙 오류 |
| q10 | Macie vs Inspector | ✅ 3 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | 출처가 KMS overview — 복붙 오류 |
| q11 | Backup Plan | ✅ 0 | ✅ | ✅ | ✅ | ✅ | ✅ | **pass** | — |
| q12 | 교차 리전·계정 백업 | ✅ 2 | ✅ | ✅ | ✅ | ✅ | ✅ | **pass** | — |
| q13 | Vault Lock WORM | ✅ 1 | ❌ | ✅ | ❌ | ✅ | ✅ | **fix + resource** | "쿨다운(기본 3일)" 오류. 공식: grace time은 **내가 지정**, 72시간 쿨오프 때문에 **최소 3일**, 최대 36,500일. "AWS Support 포함"보다 공식 문구는 "any user or by AWS" |
| q14 | RDS 암호화 전환 | ✅ 1 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | 출처가 KMS overview — 복붙 오류 |
| q15 | KMS CloudTrail | ✅ 3 | ✅ | ✅ | ❌ | ✅ | ✅ | **resource** | 출처가 KMS overview(CloudTrail 상세 없음) |

**집계**: pass 3 · fix+resource 5 · fix 1 · resource 6 · **rewrite 0 · drop 0**
**`correct`(정답 인덱스)는 15문항 전부 그대로다.**

## 공식 근거 (전부 실제 페이지를 열어 확인함)

| 쓸 곳 | URL | 확인한 문구 |
|---|---|---|
| q2 | `kms/latest/developerguide/concepts.html` | "An *AWS managed key* is a KMS key that **exists in your account** … You cannot manage anything about the lifecycle or permissions of these keys." + AWS owned keys 별도 절 |
| q2 | aws.amazon.com/kms/faqs/ | "AWS managed KMS keys are keys **created in your account** but managed by AWS … AWS owned keys are keys fully owned and operated from AWS accounts" |
| q3 | `kms/latest/developerguide/kms-cryptography.html` | "Envelope encryption is the practice of encrypting plaintext data with a data key, and then encrypting the data key under another key" |
| q3 | `kms/latest/cryptographic-details/encrypt-operation.html` | "there is a limit of **4 KB** on the amount of plaintext that can be encrypted in a direct call to the encrypt function" |
| q4 | `kms/latest/developerguide/key-policies.html` | "Unless the key policy explicitly allows it, you cannot use IAM policies to *allow* access … **The default key policy enables IAM policies.**" |
| q4 | `kms/latest/developerguide/control-access.html` | "You can either specify a key policy statement that enables IAM policies, **or you can explicitly specify allowed principals in the key policy**" |
| q5/q6 | `kms/latest/developerguide/key-store-overview.html` | 표준 키 저장소 = "**tenant-agnostic fleet of HSMs**"; "Consider creating a custom key store only when your organization has regulatory requirements that explicitly mandate key material protection in a **single-tenant HSM**"; CloudHSM 키 저장소는 "single-tenant HSM instances that are **owned and managed by you**" + "그 고객이 **AWS KMS를 통해 통합된 AWS 서비스**에서 CloudHSM을 계속 쓰게" |
| q5 | `cloudhsm/latest/userguide/introduction.html` | "HSMs are general purpose, **single tenant**…"; "**E2E encryption is not visible to AWS**"; "Full control of your keys" |
| q5 (주의) | `prescriptive-guidance/latest/aws-kms-best-practices/key-management.html` | "All of the key store options supplied by AWS KMS … are designed to **prevent anyone, including AWS operators, from accessing your plaintext keys**" → "KMS는 AWS가 키에 접근한다"는 근거는 쓸 수 없다 |
| q6 | `kms/latest/developerguide/keystore-cloudhsm.html` | "combines the convenience and widespread integration of AWS KMS with the added control of an AWS CloudHSM cluster"; "You can also use the KMS keys in your custom key store with AWS services that support customer managed keys" |
| q7 | `acm/latest/userguide/managed-renewal.html` | "ACM will either renew your certificates automatically (**if you are using DNS validation**), or it will send you email notices"; "**NOT ELIGIBLE if imported**"; "ELIGIBLE if associated with another AWS service" |
| q7 | `acm/latest/userguide/dns-renewal-validation.html` | "Managed renewal is **fully automated** for ACM certificates that were originally issued using **DNS validation**. At **45 days** prior to expiration, ACM checks … certificate is currently in use by an AWS service … CNAME records are present" |
| q8 | `acm/latest/userguide/acm-overview.html` | "To use an ACM certificate with Amazon CloudFront, you must request or import the certificate in the **US East (N. Virginia)** region. ACM certificates in this region that are associated with a CloudFront distribution are **distributed to all the geographic locations configured for that distribution**." |
| q9/q10 | `macie/latest/user/what-is-macie.html` | "discovers sensitive data by using **machine learning and pattern matching**"; "such as **a bucket that becomes publicly accessible**, Macie generates a finding" |
| q10 | `inspector/latest/user/what-is-inspector.html` | "vulnerability management service … discovers and scans **Amazon EC2 instances, container images in Amazon ECR, and Lambda functions**" + CVE |
| q13 | `aws-backup/latest/devguide/vault-lock.html` | "cannot be altered or deleted by a customer, account/data owner, **or AWS**"; "If any user (**including the root user**) attempts to delete a backup … AWS Backup will deny"; "grace time period **you set**"; CFN/API: "72-hour cooling-off period … you must set `ChangeableForDays` to **3 or greater**", 최대 36,500 |
| q14 | `AmazonRDS/latest/UserGuide/Overview.Encryption.html` (+ `USER_CopySnapshot.html`) | "You can't modify an existing unencrypted Amazon RDS DB instance to encrypt the instance"; "encrypt a copy of an unencrypted snapshot … then restore an encrypted DB instance from the encrypted snapshot" |
| q15 | `kms/latest/developerguide/logging-using-cloudtrail.html` | "CloudTrail captures **all** API calls to AWS KMS as events"; "cryptographic operations, such as **GenerateDataKey and Decrypt**"; "by default, all AWS KMS actions are logged as CloudTrail events" |

## 확인 못 한 주장 (본문에 쓰지 않을 것)

1. **"CloudFront 컨트롤 플레인이 us-east-1을 거점으로 배포 설정을 전 세계 엣지 PoP에
   복제한다"** — q8 해설 + `saa-t1-5.md` 220·221·303행. 공식 ACM 문서는 "us-east-1의
   인증서가 배포에 연결되면 그 배포에 설정된 모든 지리적 위치로 **배포된다**"고만 말한다.
   컨트롤 플레인 복제 기전은 공식 페이지에서 찾지 못했다. → 공식 문구로 교체 권고.
   (이 주장은 2026-10-19 md 정정 8건에 포함되지 않아 md에 아직 남아 있다.)
2. **"AWS Support 포함"** (q13 해설) — 공식 문구는 "by any user or by AWS"·"including the
   root user"까지만 확인된다. AWS Support를 따로 열거한 문장은 못 찾았다. → "AWS 포함"으로.
3. **"KMS는 멀티테넌트 공유 환경"** (q5) — 공식 표현은 "tenant-agnostic fleet of HSMs"이고,
   동시에 "Each AWS KMS HSM is a dedicated, standalone hardware appliance"라는 서술도 있다.
   "멀티테넌트"라는 낱말 자체는 공식 문구가 아니므로 공식 표현으로 바꾸는 것이 안전하다.

## 열린 결정 (검수자/컨트롤러 몫)

- `saa-t1-5.md` 220·221·303행의 컨트롤 플레인 주장도 함께 고칠지. **md는 라이브 학습문서**라
  문항(verified:false, 노출 0)과 달리 **라이브 변경**이 된다. saa-t1-5에는 오디오 자산이 없어
  (실측: `assets/audio`에 saa-t1-5 없음) 대본 재합성·reviewStatus 리셋 걱정은 없다.
