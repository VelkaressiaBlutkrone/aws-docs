# 98 — 기존 SAA 학습문서 24개 vs 공식 가이드 차이표

- **조회·대조일**: 2026-10-17 ~ 2026-10-19 (Task 4.1~4.4 섹션 추가와 전체 보정·교차 검증은 2026-10-19)
- **기준**: 공식 가이드 현행 웹판(docs.aws.amazon.com/aws-certification/…/solutions-architect-associate-03, ko/en) — 개정 상태는 `00-overview.md` 참조
- **대상**: `flutter_app/assets/content/saa/saa-t*.md` 24개 (문항 JSON은 이번 대조 범위 밖)
- **원칙**: 기존 문서는 수정하지 않고 차이만 기록. 줄 번호는 조회 시점 파일 기준.
- **분류 코드**: `[오류]` 사실이 틀림 · `[구식]` 과거엔 맞았으나 현재 공식과 다름 · `[의심]` 근거 부재·미검증 · `[부정확]` 단순화/오해 소지 · `[누락]` 공식 Skill/Knowledge를 안 다룸 · `[부분]` 일부만 다룸 · `[중복]` · `[과잉]` · `[내부불일치]`
- **요약 수치** (2026-10-19 `grep` 실측): 총 **303행** — Task별 1.1=17 · 1.2=18 · 1.3=18 · 2.1=16 · 2.2=21 · 3.1=19 · 3.2=22 · 3.3=23 · 3.4=20 · 3.5=19 · 4.1=32 · 4.2=26 · 4.3=28 · 4.4=24. 이 중 `[일치]` 참고 행 8, `[과잉]`란에 "없음"을 확인한 행 10을 빼면 **문제 행 285**. 분류 코드 출현 횟수(한 행이 코드를 2개 가질 수 있음): `[오류]` 6 · `[구식]` 28 · `[의심]` 57 · `[부정확]` 38 · `[누락]` 50 · `[부분]` 84 · `[중복]` 22 · `[과잉]` 14(10행은 "없음" 확인) · `[내부불일치]` 8 · `[일치]` 8. **`[오류]` 6건**: G-1.1-07 · G-1.2-06 · G-1.3-06 · G-2.1-10 · G-3.3-10 · G-3.4-10. `99-gaps.md`를 가리키는 행 37(전부 인용 확인). `> 🧠 원리` 블록 164개(문서당 4~8개)는 근거 URL이 없어 `99-gaps.md` G-01로 통합.

## 0. 문서 ↔ 공식 Task 매핑 (매핑 문서 `docs/plans/saa-c03-task-mapping.md` 기준)

| 공식 Task | 기존 문서 |
|---|---|
| 1.1 | saa-t1-1, saa-t1-2 |
| 1.2 | saa-t1-3, saa-t1-4 |
| 1.3 | saa-t1-5 |
| 2.1 | saa-t2-1, saa-t2-2, saa-t2-3(부분) |
| 2.2 | saa-t2-3, saa-t2-4, saa-t2-5 |
| 3.1 | saa-t3-1, saa-t3-2 |
| 3.2 | saa-t3-3, saa-t3-4 |
| 3.3 | saa-t3-5, saa-t3-6 |
| 3.4 | saa-t3-7, saa-t3-8 |
| 3.5 | saa-t3-9 |
| 4.1 | saa-t4-1, saa-t4-5(부분) |
| 4.2 | saa-t4-2, saa-t4-5(부분) |
| 4.3 | saa-t4-3, saa-t4-5(부분) |
| 4.4 | saa-t4-4, saa-t4-5(부분) |

문서가 **없는** Task는 없음(14개 모두 대응 문서 있음). 단, 문서 단위가 Task와 1:1이 아니라 **서비스 묶음**이므로 Skill 단위 누락이 생긴다(아래).

---

## Task 1.1 — AWS 리소스에 대한 보안 액세스 설계
**대응 문서**: `saa-t1-1`(IAM), `saa-t1-2`(Organizations·Control Tower·SCP) — 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-1.1-01 | `[누락]` Skill 6 | **디렉터리 서비스를 IAM 역할과 연동할 시기** — AWS Directory Service(AWS Managed Microsoft AD·AD Connector·Simple AD)의 선택 기준이 24개 문서 어디에도 없음. `saa-t1-1.md:40` 체크리스트가 "디렉터리 서비스 연동 시점"을 약속하나 본문엔 SAML/OIDC/Identity Center만 있음. (Grep: `Directory Service\|AD Connector\|Managed Microsoft\|Simple AD` → 체크리스트 1건 + `saa-t3-2.md:72` AD 용어 정의 1건뿐) | tasks/1-1.md §2-5, F-26~F-29 |
| G-1.1-02 | `[누락]` Knowledge | **AWS 공동 책임 모델** — SAA 24문서에 없음(CLF `clf-t2-1`에만). 매핑 문서 `saa-c03-task-mapping.md:122`가 "배경지식(별도 학습문서 불필요)"으로 처리 | F-39 |
| G-1.1-03 | `[부분]` Skill 5 | **AWS 서비스에 적합한 리소스 정책 사용 결정** — 정책 유형 표(`saa-t1-1.md:100-106`)만 있고, 어떤 서비스가 리소스 정책을 쓰는지·역할 수임 vs 리소스 정책 선택 기준(원 권한 유지 여부)·KMS 키/역할 신뢰 정책 예외가 없음 | F-35~F-37 |
| G-1.1-04 | `[부분]` Skill 3 | **역할 전환(role switching)** — 체크리스트에만 언급. 콘솔 역할 전환 시 세션 규칙, 역할 체이닝 1시간 상한, ExternalId/혼동된 대리인 없음 (Grep: ExternalId·confused 0건) | F-08, F-09, F-38 |
| G-1.1-05 | `[누락]` Skill 4 보강 | **RCP(리소스 제어 정책)·선언적 정책** 등 현행 Organizations 정책 유형 — 정책 유형 표(`saa-t1-1.md:100-106`)와 `saa-t1-2` 전반에 RCP 없음 | F-16, F-17, §2-2 |
| G-1.1-06 | `[부분]` Knowledge | **글로벌 인프라(AZ·리전)** — Task 1.1 문서엔 없음(2.2 계열 문서에서 다룸). 이중 앵커 수준 | `2-2.md` 참조 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-1.1-07 | `[오류]`(위험) | `saa-t1-2.md:138-156` | SCP 리전 제한 예시가 `Effect: Deny, Action: "*"` + `aws:RequestedRegion` ≠ `ap-northeast-2`. 이 정책은 **IAM·Organizations·Route 53·CloudFront·Support 같은 글로벌 서비스 호출까지 차단**한다. 공식 Control Tower 리전 거부 통제는 글로벌 서비스를 **예외(NotAction)** 로 두는 SCP를 제공. 문서는 "어떤 API도 호출할 수 없습니다"라고만 하고 위험·예외를 말하지 않음 | https://docs.aws.amazon.com/controltower/latest/controlreference/primary-region-deny-policy.html |
| G-1.1-08 | `[내부불일치]` | `saa-t1-2.md:275-280` (Q1) | 질문은 "`us-east-1` 외 리전 금지"인데 해설은 `ap-northeast-2`를 허용 리전으로 설명 | (문서 내부) |
| G-1.1-09 | `[부정확]` | `saa-t1-1.md:275-280` (Q4 해설) | "Active Directory 등 **SAML 2.0 IdP**와 연동" — AD는 SAML IdP가 아님. 공식: AD는 **AWS Directory Service**(AWS Managed Microsoft AD / 신뢰 / AD Connector)를 통해 Identity Center에 연결, SAML 2.0은 외부 IdP(Okta·Entra ID 등)용 | https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture-identity-management/workforce-iam-identity-center.html · https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html |
| G-1.1-10 | `[구식]` | `saa-t1-1.md:224`, `saa-t1-2.md:57,78,103` | 루트 사용자 서술이 "MFA·액세스 키 금지·일상 금지"에 머묾. 현행: **관리 계정 루트 MFA 필수(35일 유예)**, **중앙 루트 접근 관리**로 멤버 계정 루트 자격증명 제거 가능·새 멤버 계정은 기본 루트 자격증명 없음 | https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html · https://docs.aws.amazon.com/organizations/latest/userguide/orgs_best-practices.html |
| G-1.1-11 | `[부정확]` | `saa-t1-1.md:110-113` (🧠원리) | "같은 계정은 신뢰가 성립 / 교차 계정은 성립하지 않아" 식 설명. 공식은 규칙만 서술(교차 계정=양쪽 허용, 같은 계정=한쪽 허용). 또한 **KMS 키·IAM 역할은 같은 계정에서도 리소스 정책이 주체를 명시 허용**해야 하는 예외를 빠뜨림 | https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html · https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/ `[블로그]` |
| G-1.1-12 | `[의심]` | `saa-t1-2.md:255` | "관리 계정이 … 순환이 생겨 예외 처리된다" — 공식 문서는 **현상(관리 계정에 SCP 영향 없음)** 만 서술하고 이유를 설명하지 않음. 설계 의도 추정 | https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html |
| G-1.1-13 | `[의심]` | `saa-t1-1.md:77-79, 94-96, 210-212` 외 전 문서의 🧠원리 블록 | 설계 이유를 서술하나 공식 근거 URL 없음("지수적으로 늘어나고" 등 정량 수사 포함). 사실 진술과 설계 의도 추정이 섞임 | (전 문서 공통 — `99-gaps.md` 참조) |
| G-1.1-14 | `[의심]` | `saa-t1-2.md:300` (Q4 해설) | "S3 버킷에 **MFA Delete와 Object Lock**을 설정" — 두 기능의 병용 가능 여부 미검증. `tasks/1-3.md` 조사에서 판정 | `tasks/1-3.md` 참조 |
| G-1.1-15 | `[부분]` | `saa-t1-2.md` 전반 | 수치 부재: 루트/OU/계정당 SCP 직접 연결 **10개**·SCP **10,240자**·계정 기본 10개 한도 등. 기존 서술 "OU 중첩 5단계"는 일치. 참고: Prescriptive Guidance 일부 문서는 아직 "SCP 최대 5개"로 서술 → 공식 문서 간 상충 | https://docs.aws.amazon.com/organizations/latest/userguide/orgs_reference_limits.html vs https://docs.aws.amazon.com/prescriptive-guidance/latest/designing-control-tower-landing-zone/controls.html |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-1.1-16 | `[중복]` | SCP 설명과 "SCP vs 권한 경계" 비교가 `saa-t1-1.md §3·§7`과 `saa-t1-2.md §3`에 반복(후자는 요약이라 명시). 의도적 중복이나 분량 과다 |
| G-1.1-17 | `[과잉]` | 없음 — Cognito는 `saa-t1-1.md` 페더레이션 표에 1행으로만 등장(1.2 문서 `saa-t1-4`와 중복 소지 낮음) |


---

## Task 1.2 — 안전한 워크로드 및 애플리케이션 설계
**대응 문서**: `saa-t1-3`(VPC 보안 네트워크), `saa-t1-4`(Shield·WAF·Cognito·Secrets Manager) — 있음. 보안 서비스(Macie·Inspector)는 `saa-t1-5`(Task 1.3 문서)에 배치돼 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-1.2-01 | `[누락]` Knowledge | **「보안 서비스와 적합한 사용 사례(예: Cognito, GuardDuty, Macie)」** — 공식이 예시로 직접 든 **GuardDuty가 24개 문서 전체에서 0회**(Grep `GuardDuty` → No matches). Detective·Network Firewall·DNS Firewall도 없음(Firewall Manager 설명 안의 나열 제외). Macie·Inspector는 `saa-t1-5`에만 있어 Task 1.2 문서(`saa-t1-3/4`)와 분리돼 있음 | tasks/1-2.md F-25~F-29 |
| G-1.2-02 | `[누락]` Knowledge | **「AWS 서비스 엔드포인트」** — 리전 엔드포인트·FIPS·듀얼스택·STS 리전 엔드포인트가 없음. VPC 엔드포인트(Gateway/Interface)만 다룸(`saa-t1-3.md:173-195`) | F-37, F-40 |
| G-1.2-03 | `[부분]` Skill 4 | **외부 네트워크 연결 보호(VPN·DX)** — `saa-t1-3/4`에는 없고 `saa-t3-8`에서 IPsec·DX-over-VPN을 다룸. **MACsec 누락**(`saa-t3-8.md:179,291,332`는 IPsec 오버레이만 제시) — 공식 Hybrid 렌즈는 전용 10/100/400 Gbps에 MACsec 제시 | F-35 |
| G-1.2-04 | `[부분]` Knowledge | **포트·프로토콜·네트워크 트래픽 제어** — SG/NACL은 있으나 Network Firewall·DNS Firewall·"SG/NACL이 거르지 못하는 트래픽(DNS·IMDS 등)"·SG 쿼터가 없음 | F-02, F-03, F-05, F-24 |
| G-1.2-05 | `[부분]` Knowledge | **애플리케이션 구성·자격증명 보안** — Secrets Manager vs Parameter Store는 있으나 IMDSv2 강제·Session Manager 등 구성 보안은 미언급(해당 항목은 이번 조사에서 공식 근거를 확보하지 못함 → `99-gaps.md`) | — |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-1.2-06 | `[오류]` | `saa-t1-4.md:282` | "CloudFront + WAF … **us-east-1 제한 없음**" → CloudFront에 연결하는 웹 ACL(스코프 `CLOUDFRONT`)은 **US East (N. Virginia)에서 생성**해야 함(`REGIONAL`은 해당 리전) | https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_wafv2.CfnWebACL.html |
| G-1.2-07 | `[부정확]` | `saa-t1-4.md:89`, `:113-116`(원리) | "첫 번째로 매칭된 규칙의 액션(Allow/Block/**Count**/CAPTCHA)을 실행" → **Count는 비종료**(이후 규칙 계속 평가), CAPTCHA/Challenge는 유효 토큰이면 비종료·없으면 종료. 종료가 확정되는 것은 Allow·Block | https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-rule-actions.html |
| G-1.2-08 | `[구식]` | `saa-t1-4.md:99` | Rate-based "5분 또는 1분" → 평가 창 **60·120·300·600초**(1·2·5·10분), 한도 10~2,000,000,000 | https://repost.aws/knowledge-center/waf-rate-based-custom-key-not-blocking |
| G-1.2-09 | `[구식]` | `saa-t1-4.md:77-85` | WAF 보호 대상 목록에 **Amplify**·**Bedrock AgentCore Gateway** 누락(현행 API 레퍼런스에는 포함). 본문 검사 기본 16 KB(ALB·AppSync 8 KB 고정)도 없음 | https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-wafv2-2019-07-29.html |
| G-1.2-10 | `[구식]` | `saa-t1-4.md:175` | Cognito "MFA(TOTP·SMS) 지원" → 2024-11-22부터 기능 플랜 **Lite/Essentials/Plus**; 패스키·이메일 OTP MFA·패스워드리스는 Essentials+, 위험 기반 인증은 Plus. 플랜별 과금 구조 미언급 | https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-sign-in-feature-plans.html · https://aws.amazon.com/cognito/pricing/ |
| G-1.2-11 | `[부분]` | `saa-t1-4.md:126,134,277-278` | Shield Advanced "유료 구독(별도 요금)"만 서술 → 월 $3,000/조직(통합 결제 1회)+데이터 전송 사용료, **1년 약정**, **SRT 연락은 Business/Enterprise Support 필요**(문서는 "Advanced 가입 시에만"), 보호 리소스의 표준 WAF 비용 포함·자동 L7 완화 규칙 그룹(150 WCU) 미언급 | https://aws.amazon.com/shield/faqs/ · https://aws.amazon.com/shield/pricing/ · https://docs.aws.amazon.com/waf/latest/developerguide/ddos-advanced-summary-deciding.html |
| G-1.2-12 | `[구식]` | `saa-t1-3.md:240` | Flow Logs 저장 대상 "CloudWatch Logs 또는 S3" → **Amazon Data Firehose** 추가(총 3곳) | https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html |
| G-1.2-13 | `[구식]`·`[부정확]` | `saa-t1-3.md:122-136` (특히 :131 "가용성: 자동 고가용성") | NAT GW는 **해당 AZ 안에서만** 이중화(AZ 장애 내성은 AZ별 NAT GW). **Regional NAT 게이트웨이**(ENI가 있는 AZ로 자동 확장·최대 60분)와 **Private NAT 게이트웨이** 미언급. 100 Gbps·55,000 연결 등 수치도 없음 | https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html · https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html |
| G-1.2-14 | `[부정확]` | `saa-t1-3.md:227` | VPC 피어링 비용 "데이터 처리 과금" → 생성 무료, **같은 AZ 내 전송 무료**, AZ 간·리전 간 전송만 표준 데이터 전송 요금(처리 요금 아님). 참고: 피어링 최대 활성 연결 125개/VPC(화이트페이퍼) | https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html |
| G-1.2-15 | `[부분]` | `saa-t1-3.md:179-182` | Gateway Endpoint는 **온프레미스·타 리전 피어링 VPC·Transit Gateway 경유 접근 불가**(이 경우 Interface Endpoint)라는 시험 포인트 미언급 | https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-ddb.html |
| G-1.2-16 | `[의심]` | `saa-t1-3.md:94-97, 138-141, 167-171, 192-195, 229-232, 251-254` · `saa-t1-4.md:113-116, 144-147, 159-162, 202-205, 231-234, 267-270` (🧠원리 블록) | 설계 의도를 추정해 서술하며 공식 근거 URL이 없다. 예: `saa-t1-3.md:192-195`("S3·DynamoDB는 AWS가 관리하는 공용 IP 대역을 쓰는 서비스… prefix list로 노출하는 방식이 기술적으로 가능했습니다"), `:229-232`(피어링 비전이 설명이 논리적으로 자기모순) | (공식 문서는 규칙만 서술: gateway-endpoints.html, what-is-vpc-peering.html) |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-1.2-17 | `[과잉]` | `saa-t1-3.md §5`(VPC 피어링 vs Transit Gateway)는 공식 Task 1.2 Skill 4개에 직접 대응하지 않음 — Task 3.4·4.4 영역과 겹침(`saa-t3-7/8` 중복 여부는 3.4 조사에서 확정) |
| G-1.2-18 | `[과잉]` | `saa-t1-3.md §6`(Flow Logs 활용 중 "비용 분석")은 공식 Skill 범위 밖 보조 서술(해가 되진 않음) |

---

## Task 1.3 — 적합한 데이터 보안 제어 결정
**대응 문서**: `saa-t1-5`(KMS·CloudHSM·ACM·백업·거버넌스) — 있음. S3 보호·복제·백업은 `saa-t2-4`·`saa-t2-5`·`saa-t3-1`에 분산(매핑 문서 기준). 매핑 문서 `saa-c03-task-mapping.md`는 Phase-05-Step-2(CloudWatch·CloudTrail·Config·GuardDuty·Macie)를 `saa-t1-5`에 배치한다고 적었으나 실제 본문엔 Macie만 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-1.3-01 | `[누락]` Skill 1 | **규정 준수 요구에 맞는 AWS 기술 조율** — AWS Artifact·AWS Config(적합성 팩)·CloudTrail 무결성 등 "증빙" 축이 없음. `saa-t1-5.md`에서 CloudTrail은 KMS 감사 한 줄(`:137`), Artifact·Config는 0회 | F-35 |
| G-1.3-02 | `[누락]` Skill 6 | **S3 데이터 보호 정책** — Object Lock(governance/compliance/legal hold)·S3 Bucket Key·DSSE-KMS·Replication Time Control(RTC)이 24개 문서 어디에도 설명되지 않음. Object Lock은 `saa-t1-2.md:113,300`에 한 줄 언급뿐(Grep `Object Lock\|Bucket Key\|DSSE\|RTC` → t1-2 2건 외 0) | F-16, F-17, F-19 |
| G-1.3-03 | `[부분]` Skill 7 | **키 교체** — 「AWS 관리형 키 연 1회·CMK 선택적」만 있고 **로테이션 주기 90~2,560일**, **즉시 로테이션**, **자동 로테이션 불가 키(비대칭·HMAC·가져온 키 자료·사용자 지정 키 저장소)**, 로테이션 요금(2회 상한)이 없음 | F-04~F-08 |
| G-1.3-04 | `[부분]` Skill 4 | **암호화 키 접근 정책** — 키 정책 서술에 오류 있음(아래 G-1.3-06). 교차 계정 키 사용, AWS 관리형 키는 타 계정과 공유 불가(→ 교차 계정 EBS 스냅샷은 CMK 필요) 미언급 | F-02, F-11, F-21 |
| G-1.3-05 | `[부분]` Skill 5 | **데이터 백업·복제** — AWS Backup은 상세하나 RDS 자동 백업 보존(0~35일)·DynamoDB PITR(35일)·EBS 스냅샷 복사/공유 규칙은 `saa-t1-5`에 없음(`saa-t2-4/2-5`에서 일부 가능 — 해당 Task 조사에서 교차 확인) | F-22~F-25 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-1.3-06 | `[오류]` | `saa-t1-5.md:121-123`, `:286-287`(함정 3), `:311-316`(Q2 해설) | "IAM 정책만으로는 CMK 접근 불가", "IAM 정책과 키 정책의 **교집합**에서 허용", "IAM·키 정책 **모두 Allow**여야" → 실제: 기본 키 정책의 **계정 루트 위임 문장**(`Enable IAM User Permissions`)이 있으면 **IAM 정책만으로** 접근 가능, 키 정책이 주체를 **직접** 허용하면 IAM 불필요, 위임 문장이 없으면 IAM Allow는 **무효**. 교차 계정만 양쪽 필요 | https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html · https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html |
| G-1.3-07 | `[내부불일치]`·`[구식]` | `saa-t1-5.md:163`(표) vs `:170`(결정 규칙) vs `:304-309`(Q1) | 표는 KMS를 「FIPS 140-3 Level 3」로 쓰면서 결정 규칙은 「FIPS Level 3 감사 키워드 → CloudHSM」, Q1은 「KMS는 멀티테넌트… 요건을 충족하지 못합니다」. 현행: **KMS HSM도 FIPS 140-3 Level 3 검증** — FIPS 등급만으로는 CloudHSM이 필요하지 않고, 차별점은 **전용(단일 테넌트) 하드웨어·단독 통제** | https://docs.aws.amazon.com/kms/latest/developerguide/key-store-overview.html · https://aws.amazon.com/cloudhsm/faqs/ |
| G-1.3-08 | `[부정확]` | `saa-t1-5.md:98` | AWS 관리형 키 행 "키 정책 제어: 불가 (**AWS 소유**)" — 「AWS 관리형 키」(내 계정에 존재·조회 가능·AWS가 수명 주기 관리)와 「AWS 소유 키」(서비스 소유 계정)를 혼용. 또 AWS 관리형 키는 "**무료**"가 아니라 보관료만 없고 서비스 사용료는 청구될 수 있음 | https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html |
| G-1.3-09 | `[구식]` | `saa-t1-5.md:129` | S3 암호화 표가 SSE-S3·SSE-KMS·SSE-C만 나열 → **2023-01-05부터 모든 새 객체 SSE-S3 기본**, **DSSE-KMS**, **Bucket Key**, **2026-04부터 SSE-C 신규 버킷 기본 비활성** 미반영 | https://docs.aws.amazon.com/AmazonS3/latest/userguide/default-bucket-encryption.html · https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html |
| G-1.3-10 | `[구식]` | `saa-t1-5.md:183` | "ACM이 발급하는 인증서는 **추가 요금 없음**" → 통합 서비스용 퍼블릭 인증서는 무료이나 **내보내기 가능(exportable) 퍼블릭 인증서는 유료**(FQDN $7·와일드카드 $79, 발급·갱신 시) | https://aws.amazon.com/certificate-manager/pricing/ · https://docs.aws.amazon.com/acm/latest/userguide/acm-exportable-certificates.html |
| G-1.3-11 | `[부정확]` | `saa-t1-5.md:184` | "자동 갱신… **DNS 검증 또는 이메일 검증**이 유효한 상태여야" → 완전 자동 갱신은 **DNS 검증**만(만료 45일 전 점검, 서비스에서 사용 중·CNAME 존재). 이메일 검증은 소유자가 이메일에 응답해야 함. 공개 인증서 유효 주기 **198일** 반영 필요 | https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html · https://docs.aws.amazon.com/securityhub/latest/userguide/acm-controls.html |
| G-1.3-12 | `[부정확]` | `saa-t1-5.md:256`(원리), `:247` | Vault Lock compliance "취소는 활성화 후 쿨다운(**기본 3일**) 내" → 유예 시간은 **최소 72시간(3일) 이상으로 사용자가 지정**(`ChangeableForDays ≥ 3`), 기본값이 아님 | https://docs.aws.amazon.com/help-panel/aws-backup/latest/helppanel/vaultlock-create.html |
| G-1.3-13 | `[부정확]` | `saa-t1-5.md:206,214-217` | Macie를 "규칙 기반이 아닌 **머신러닝**"으로 서술 → 공식: **머신러닝 + 패턴 매칭**, 관리형 데이터 식별자와 사용자 정의 식별자(정규식 기반) 지원 | https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-security-controls/detective-controls.html |
| G-1.3-14 | `[의심]` | `saa-t1-5.md:83-86, 134-137, 151-154, 172-175, 197-200, 214-217, 254-257` (🧠원리) | 설계 의도 추정. 특히 `:197-200`("CloudFront 컨트롤 플레인이 us-east-1을 거점으로…")은 공식이 설명하지 않는 내부 구조 서술 — 공식은 "us-east-1에서 요청/가져오기"라는 규칙만 | https://aws.amazon.com/certificate-manager/faqs/ |
| G-1.3-15 | `[부분]` | `saa-t1-5.md:98-100` | 키 유형 표에 **계정 간 공유 가능 여부·키 삭제 대기(7~30일)·키 요금($1/월)** 열이 없음(시험 빈출 비교축) | F-02, F-08, F-09 |
| G-1.3-16 | `[의심]` | `saa-t1-2.md:300`(Q4 해설) | "S3 버킷에 **MFA Delete와 Object Lock**을 설정" — 병용 가능 여부는 이번 조사에서 공식 문장을 확보하지 못함(둘 다 버전 관리 필요, MFA Delete는 루트·CLI/API만, Object Lock compliance는 루트도 삭제 불가). 불변성 목적이면 Object Lock만으로 충분 | `99-gaps.md` |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-1.3-17 | `[과잉]` | `saa-t1-5` 학습 목표(`:35-41`)에 Macie 중심 서술이 크며 Task 1.2 Knowledge(보안 서비스 사용 사례)와 경계가 모호 — 1.2/1.3 문서 경계 재정의 필요 |
| G-1.3-18 | `[중복]` | Macie vs Inspector 비교가 `saa-t1-5.md:212,292`에 있으나 Inspector 자체 설명은 어디에도 없음(비교만 존재) |

---

## Task 2.1 — 확장 가능하고 느슨하게 결합된 아키텍처 설계
**대응 문서**: `saa-t2-1`(SQS·SNS·EventBridge·Step Functions), `saa-t2-2`(Lambda·API Gateway·Fargate·ECS/EKS) — 있음. `saa-t2-3`(ELB+Auto Scaling)은 2.1·2.2 공유(스케일링은 §Task 2.2에서 다룸). 읽기 전용 복제본·캐싱·CDN·Transfer Family는 타 Task 문서(`saa-t3-5/6/7/9`)에 분산.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-2.1-01 | `[누락]` Knowledge | **애플리케이션을 컨테이너로 마이그레이션하는 방법** — App2Container 등 이전 경로 설명이 24개 문서 어디에도 없음(Grep `App2Container` → 0). `saa-t2-2`는 ECS/EKS/Fargate 선택 기준만 다룸 | F-28 |
| G-2.1-02 | `[누락]` Skill 3·7 | **Application Integration 범위 내 서비스** — **Amazon MQ**(기존 JMS/AMQP 브로커 이전), **EventBridge Pipes**(점대점 통합), **AppFlow**가 없음(Grep `Amazon MQ\|Pipes` → 0). 공식 in-scope 목록(Application Integration: AppFlow·EventBridge·MQ·SNS·SQS·Step Functions)과 불일치 | 00-overview §서비스 범위, F-11 |
| G-2.1-03 | `[부분]` Skill 7 | **목적별 구축 서비스(purpose-built) 선택표** — 컴퓨트·메시징 외 DB·분석 등을 한 표로 묶은 선택 기준이 Task 2.1 문서엔 없음(DB는 `saa-t3-5/6`에서 개별 서술) | §2-8 |
| G-2.1-04 | `[부분]` Knowledge | **AWS Managed Services 예시(Transfer Family·SQS·Secrets Manager)** — Transfer Family는 `saa-t3-9.md:268`에 한 줄(SFTP/FTPS/FTP→S3·EFS), 요금 구조(프로토콜 시간당+GB)·AS2·중지해도 과금 없음 | F-27 |
| G-2.1-05 | `[부분]` | **SQS 세부 사양** — 메시지 크기(1 MiB, 초과 시 Extended Client+S3), 지연 큐 0~900초, in-flight 한도(~120,000), DLQ 리드라이브 정책(`maxReceiveCount`·허용 정책), FIFO 고처리량 모드 **최대 70,000 msg/s**(`saa-t2-1.md:95`는 300/3,000만) | F-02~F-06 |
| G-2.1-06 | `[부분]` | **Lambda 한도·동작** — `/tmp` 크기, 기본 동시성 1,000, 함수당 확장 속도(10초당 1,000), 페이로드 6 MB/1 MB, 컨테이너 이미지 10 GB, 비동기 이벤트 보관 6시간, SQS 트리거 `ReportBatchItemFailures`가 `saa-t2-2`에 없음 | F-07, F-13, F-14 |
| G-2.1-07 | `[부분]` | **API Gateway 수치·유형** — 계정 스로틀 10,000 RPS/버스트 5,000, 통합 제한 29초(Regional·프라이빗 REST만 증액), 엔드포인트 유형(엣지/Regional/프라이빗), **캐싱은 REST API 전용** | F-17~F-20 |
| G-2.1-08 | `[부분]` | **EKS 요금** — 「컨트롤 플레인 요금 발생」만 있고 표준 $0.10/h·연장 지원 $0.60/h(14+12개월) 구조 없음 | F-22 |
| G-2.1-09 | `[부분]` Knowledge | **읽기 전용 복제본 사용 시기·한도**는 `saa-t3-5`로 이동(RDS 최대 15/Oracle·SQL Server 5, Aurora 15) — Task 2.1 문서 관점의 "언제 쓰는가" 연결 없음 | F-26 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-2.1-10 | `[오류]` | `saa-t2-1.md:152`, `:155-157`(원리), `:232`, `:249-250`(함정 3) | "SNS→Lambda 직접 Push 시 Lambda 동시성 한도에 도달하면 **SNS는 제한된 횟수만 재시도하고 이후 메시지를 버린다**", "SNS만으로는 재시도·DLQ 보장이 약하다" → 실제: **SQS·Lambda 같은 AWS 관리형 엔드포인트는 서버 측 오류 시 최대 100,015회·23일 재시도**하고, **구독 단위 DLQ**를 붙일 수 있다(재시도 소진 시에만 폐기). 팬아웃에 SQS를 끼우는 진짜 이유는 소비자별 **버퍼링·독립 속도·재처리** (정답 패턴 "SNS+SQS" 자체는 유효) | https://docs.aws.amazon.com/sns/latest/dg/sns-dead-letter-queues.html · https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html |
| G-2.1-11 | `[부정확]` | `saa-t2-2.md:258`(함정 1) | "15분 초과 … **Step Functions(Durable Lambda)** 등을 사용" — Durable functions는 **Lambda의 별도 기능군**(현행 quotas 페이지에 Durable functions·Managed Instances·MicroVMs·Web Functions 섹션 신설)이지 Step Functions의 일부가 아님. 또한 Managed Instances에서는 비동기·이벤트 소스 호출 타임아웃이 **최대 90분** | https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html |
| G-2.1-12 | `[부분]`·`[구식]` | `saa-t2-2.md:99` | 비동기 호출 "자동 재시도 2회 → DLQ 또는 Destinations" ✓ 일치하나 **이벤트 큐 보관 최대 6시간**, Destinations 성공/실패 분리, S3는 실패 대상만 지원 미기재 | https://docs.aws.amazon.com/lambda/latest/api/API_PutFunctionEventInvokeConfig.html |
| G-2.1-13 | `[의심]` | `saa-t2-1.md:78-81, 108-111, 131-134, 154-157, 177-180, 199-202, 221-224, 302` · `saa-t2-2.md:125-128, 168-171, 204-207, 233-236` (🧠원리) | 설계 의도 추정. 예: `saa-t2-1.md:108-111`("서버가 Push하려면 소비자 주소·상태를 추적하는 레지스트리가 필요…") 등 공식 근거 URL 없음. 특히 G-2.1-10과 같이 **사실과 어긋난 추정**이 섞여 있음 | (전 문서 공통) |
| G-2.1-14 | `[의심]` | `saa-t2-2.md:187` | "ECS 컨트롤 플레인 **추가 비용 없음**" — 이번 조사에서 공식 문장을 직접 확보하지 못함(일반적으로 알려진 사실이나 URL 근거 없음) → `99-gaps.md` | — |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-2.1-15 | `[중복]` | RDS Proxy·Lambda 커넥션 설명이 `saa-t2-2.md:72,116,251,313-317`에 있고 `saa-t3-5`(프록시)와 겹침 — Task 3.3 Knowledge("데이터베이스 연결 및 프록시") 쪽으로 일원화 가능 |
| G-2.1-16 | `[과잉]` | 없음 — `saa-t2-1/2`는 공식 Skill 범위 내(다만 아래 §2.2에서 `saa-t2-3` 분량 과다 여부 확인) |

---

## Task 2.2 — 고가용성 및/또는 내결함성 아키텍처 설계
**대응 문서**: `saa-t2-3`(ELB+Auto Scaling — 2.1과 공유), `saa-t2-4`(Multi-AZ·SPOF·Route 53 페일오버), `saa-t2-5`(DR 전략·DRS) — 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-2.2-01 | `[누락]` Knowledge | **워크로드 가시성(예: AWS X-Ray)** — 24개 문서 전체에서 0회(Grep `X-Ray` → No matches) | F-23 |
| G-2.2-02 | `[누락]` Knowledge | **Service Quotas 및 제한(대기 환경 쿼터 구성)** — 0회(Grep `Service Quotas\|서비스 할당량` → 0). 공식이 예시로 직접 든 주제 | F-20 |
| G-2.2-03 | `[누락]` Knowledge | **변경 불가능한(immutable) 인프라** — 0회(Grep `Immutable\|불변\|변경 불가능` → 0) | F-21 |
| G-2.2-04 | `[누락]` Knowledge | **「AWS Managed Services와 적합한 사용 사례(예: Comprehend, Polly)」** — Comprehend·Polly·Textract·Transcribe·Translate·Lex 등 in-scope **관리형 AI 서비스가 어떤 문서에도 없음**(Rekognition은 `saa-t3-9.md:124,140` Kinesis Video 맥락 한 줄, SageMaker AI는 `saa-t3-2.md:350`·`saa-t4-2.md:113` 부수 언급). AMS(운영 서비스) 설명도 없음 | F-24, 00-overview §서비스 범위 |
| G-2.2-05 | `[누락]` Knowledge | **분산 설계 패턴** — 지수 백오프+지터·재시도 제한·회로 차단기 등 0회(Grep `백오프\|지터\|jitter\|backoff\|Circuit` → 0) | F-22 |
| G-2.2-06 | `[누락]` Skill 7 | **레거시/클라우드 비친화 앱의 신뢰성 개선(앱 변경 불가)** — EC2 자동 복구(`StatusCheckFailed_System` 경보, Grep `StatusCheckFailed` → 0), ASG min=max=1, Proxy 활용 설계가 없음 | F-14 |
| G-2.2-07 | `[부분]` Skill 3 | **HA 지표** — 가용성 % ↔ 연간 허용 중단 표, 서비스별 SLA(RDS Multi-AZ 99.95%·Aurora 99.99%·DynamoDB 글로벌 99.999%)가 없음(Grep `99.99\|99.95` → S3·EBS 문서만) | F-02, F-08, F-26 |
| G-2.2-08 | `[부분]` Skill 2·5 | **DB 가용성 옵션** — `saa-t2-4`는 Multi-AZ 인스턴스 중심(클러스터는 `:172,205` 한 줄). Aurora 6사본/3 AZ·리더 <30초 장애 조치, Multi-AZ 클러스터 <35초·읽기 가능 스탠바이 2, RDS Proxy의 장애 조치 단축, DynamoDB 글로벌 테이블 MREC/MRSC 미기재 | F-03~F-08 |
| G-2.2-09 | `[부분]` Knowledge | **Route 53** — 라우팅 정책 8종(멀티값 응답 최대 8개), 헬스 체크 수치(간격 30/10초·임계값 3·18% 규칙), 장애 조치 시간 계산식 없음(`saa-t2-4.md:216-234`는 개념만, 정책 상세는 `saa-t3-7`) | F-15, F-16 |
| G-2.2-10 | `[부분]` | **ARC** — `saa-t2-5.md:145`에 한 줄("수동 페일오버 스크립트 제어용 스위치")뿐. zonal shift·zonal autoshift·routing control·Region switch 구분과 prescale 요건 없음 | F-17 |
| G-2.2-11 | `[부분]` Skill 1 | **ASG 운영 세부** — 헬스 체크 유예 기간(콘솔 300초/CLI·SDK 0초), 기본 쿨다운 300초, 복수 정책 시 큰 용량 우선, 인스턴스 워밍업·웜 풀·인스턴스 새로 고침이 `saa-t2-3`에 없음 | F-12, F-13 |
| G-2.2-12 | `[부분]` Skill 6 | **DR 전략 공식 수치** — REL13-BP02 수치(B&R RPO 시간·RTO ≤24h / Pilot Light RPO 분·RTO 수십 분 / Warm Standby RPO 초·RTO 분)가 정성 서술로만 존재(`saa-t2-5.md:85-90`), DR 환경 Service Quotas·DR 테스트·페일백 절차 서술 부족 | F-18, F-20 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-2.2-13 | `[구식]` | `saa-t2-3.md:87` | CLB "레거시 … **기존 EC2-Classic 환경만**" → EC2-Classic는 **2022-08-15 이후 신규 시작 불가**로 종료. CLB는 VPC에서 동작하는 이전 세대 LB(신규 비권장)이지 Classic 전용이 아님 | https://aws.amazon.com/vpc/faqs/ |
| G-2.2-14 | `[의심]`·`[부정확]` | `saa-t2-3.md:85,128`, `:86` | NLB "연결 지연 **< 1ms** 수준" — 공식 근거 미확보(공식 표현은 "초저지연·초당 수백만 요청"). GWLB를 "L3/4"로 표기 — 공식 CLI 레퍼런스는 "**layer 3**" | https://docs.aws.amazon.com/cli/latest/reference/elbv2/index.html |
| G-2.2-15 | `[부정확]` | `saa-t2-5.md:128` | DynamoDB 글로벌 테이블 "멀티 리전 읽기·쓰기, **최종 일관성**" → 현재 **MREC(기본)와 MRSC(2025-06 도입, 강한 일관성) 중 생성 시 선택**, 99.999% SLA | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-global-table-design.html |
| G-2.2-16 | `[의심]` | `saa-t2-5.md:213-214`(함정 5) | "DRS는 RDS 같은 관리형 서비스에는 사용 불가" — 이번 조사에서 직접 확인한 공식 문장 없음(일반적으로 서버 대상) → `99-gaps.md` | — |
| G-2.2-17 | `[의심]` | `saa-t2-4.md:106` | "Reliability Pillar는 '이중화를 통한 단일 실패점 제거'를 핵심 원칙으로 **명시**" — 인용 형태이나 원문 URL·문구 미확인(의역 가능성) | https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/availability.html |
| G-2.2-18 | `[의심]` | `saa-t2-3.md:91-94, 116-119, 132-135, 148-151, 163-166, 195-198, 211-214, 241-244` · `saa-t2-4.md:85-88, 109-112, 142-145, 182-185, 207-210, 236-239, 257-260, 279-282` · `saa-t2-5.md:78-81, 99-102, 116-119, 133-136, 147-150, 161-164, 176-179` (🧠원리) | 설계 의도 추정. 예: `saa-t2-3.md:148-151`("ALB는 연결을 종료하고 새 연결로 전달하므로 AZ를 넘어도 추가 비용이 내부에서 흡수됩니다") — 교차 영역 기본값의 **이유**를 공식이 이렇게 설명하지 않음(공식은 기본값·요금 규칙만) | https://docs.aws.amazon.com/elasticloadbalancing/latest/network/edit-target-group-attributes.html |
| G-2.2-19 | `[의심]` | `saa-t2-3.md:238` | 수명 주기 훅 "대기 시간 기본 1시간(최대 48시간)" — 이번 조사에서 공식 문장 미확보 → `99-gaps.md` | — |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-2.2-20 | `[중복]` | ELB 유형 비교(ALB/NLB/GWLB)·교차 영역·스티키 세션이 `saa-t2-3`과 `saa-t3-7`(네트워크 성능, Task 3.4)에 반복될 가능성 — 3.4 조사에서 확정 |
| G-2.2-21 | `[중복]` | 세션 외부화/ASG 자가 복구 설명이 `saa-t2-3.md:153-166,318-323`과 `saa-t2-4.md:264-282`에 중복 |

---

## Task 3.1 — 고성능 및/또는 확장 가능한 스토리지 솔루션 결정
**대응 문서**: `saa-t3-1`(S3 — 스토리지 클래스·수명 주기·성능 최적화), `saa-t3-2`(스토리지 유형·EBS·인스턴스 스토어·EFS·FSx) — 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-3.1-01 | `[누락]` Knowledge 1 | **하이브리드 스토리지 솔루션** — Storage Gateway(S3 File·Volume·Tape)·S3 on Outposts·EBS on Outposts가 24개 문서 어디에도 없음(Grep `Storage Gateway\|스토리지 게이트웨이\|File Gateway\|Volume Gateway\|Tape Gateway\|Outposts` → **0건**). 공식 Task 3.5 Knowledge 예시("AWS Storage Gateway")와도 이어지는 구멍 | F-20, F-22 |
| G-3.1-02 | `[부분]` Skill 1 | **EBS 성능을 결정하는 조건** — EBS 최적화 인스턴스 필요, Nitro만 io2 256,000 IOPS(그 외 인스턴스 최대 32,000 달성), IOPS 달성 기준 I/O 크기(gp3 25.6 KiB·그 외 16 KiB), gp3 독립 프로비저닝 수식(IOPS는 GiB당 500·처리량은 IOPS당 0.25 MiB/s) 미기재. `saa-t3-2.md:113-124` 표와 한 줄 설명뿐 (Grep `EBS 최적화\|EBS-optimized` → 스토리지 맥락 0건, `saa-t3-3.md:84` 인스턴스 접미사 설명 1건) | F-07, F-09 |
| G-3.1-03 | `[부분]` Skill 2 | **EBS Elastic Volumes(확장 가능성)** — 운영 중 크기·유형·IOPS 변경, 변경 뒤 파일 시스템 확장 필요, **크기 축소 불가**, 롤링 24시간 최대 4회 제약이 `saa-t3-2`에 없음(Grep `Elastic Volumes` → `saa-t4-1.md:165,324`에서 gp2→gp3 전환 맥락만) | F-11 |
| G-3.1-04 | `[부분]` Skill 1 | **EFS 처리량 모드 선택 기준·성능 수치** — `saa-t3-2.md:193-207` 표가 모드 이름과 한 줄 설명뿐. Elastic(평균/피크 5% 이하·스파이크) vs Provisioned(5% 이상) 판단 기준, Bursting 크레딧 소진 시 전환, 모드·유형별 IOPS/처리량/지연(예: Regional Elastic 읽기 ~1 ms·쓰기 ~2.7 ms), IOPS 별도 과금 없음, One Zone 차이 미기재 | F-13, F-14 |
| G-3.1-05 | `[부분]` Skill 1 | **S3 Express One Zone** — `saa-t3-1.md:93,102`는 표 한 행과 한 줄. 디렉터리 버킷, 컴퓨트와 같은 AZ 공존, 요청률(기본 읽기 200,000·쓰기 100,000 rps), "접근 최대 10배·요청 비용 최대 80% 절감", SLA 99.9% 미기재 (Grep `디렉터리 버킷\|directory bucket\|공존` → 0건) | F-06 |
| G-3.1-06 | `[부분]` Skill 1 | **S3 성능 세부** — `saa-t3-1.md:154`가 "PUT/DELETE"로 서술(공식은 PUT/**COPY/POST**/DELETE), 프리픽스 병렬화의 산술 예(10개 → 읽기 55,000 rps), 자동 파티셔닝 중 일시 **503 SlowDown**, 키 이름 무작위화 불필요, Transfer Acceleration 효과 조건(대륙 간·큰 객체; 1 GB 미만 이득 작음)·"가속된 전송에만 과금" 미기재. 강한 일관성은 PUT/DELETE만 언급(`saa-t3-1.md:77`) — 공식은 **LIST 포함** 모든 GET/PUT/LIST | F-02, F-03, F-05 |
| G-3.1-07 | `[부분]` Knowledge 2 | **FSx 보조 특성** — Lustre의 S3 링크(DRA) 제약(Intelligent-Tiering은 S3 링크 불가·링크된 파일 시스템은 백업 미지원), OpenZFS 배포 유형·스토리지 클래스 **생성 뒤 변경 불가**·Intelligent-Tiering 클래스, ONTAP Multi-AZ 동기 복제 구조는 `saa-t3-2.md:240-262`에 클래스 나열 수준으로만 있음 | F-17, F-18, F-19 |
| G-3.1-08 | `[부분]` Skill 1 | **Multi-Attach 보강** — 최대 16개 Nitro 인스턴스 수치, **NVMe 예약(펜싱)**·WSFC 사례, "표준 파일 시스템 비지원" 명시가 없음(`saa-t3-2.md:156-159`은 "애플리케이션이 직접 담당"으로 갈음). 방향은 일치 | F-10 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-3.1-09 | `[구식]` | `saa-t3-1.md:75` | "단일 객체 최대 **5TB**" → 현행 S3 FAQ·업로드 가이드는 **최대 50 TB**(멀티파트 5 MB~50 TB), 한도 페이지는 48.8 TiB(10,000파트 × 5 GiB). 단, Storage Gateway FAQ는 여전히 5 TB로 서술 → 공식 문서 간 상충(`99-gaps.md`) | https://aws.amazon.com/s3/faqs/ · https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html · https://docs.aws.amazon.com/AmazonS3/latest/userguide/qfacts.html |
| G-3.1-10 | `[내부불일치]`·`[부정확]` | `saa-t3-1.md:159` vs `:261,313` | 표는 "5 GB **이상** 필수", 본문·해설은 "5 GB **초과**" 멀티파트 필수. 공식은 단일 PUT이 **5 GB까지** 가능("up to 5 GB") → "초과"가 맞음 | https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html |
| G-3.1-11 | `[구식]` | `saa-t3-2.md:198` | EFS **Max I/O**를 현행 선택지로 서술("수천 인스턴스가 동시 접근하는 빅데이터 분석") → 현행 공식: Max I/O는 **이전 세대(previous generation)**, 지연 높음, **One Zone·Elastic 처리량과 병용 불가**, 모든 파일 시스템에 **General Purpose 권장** | https://docs.aws.amazon.com/efs/latest/ug/performance.html |
| G-3.1-12 | `[의심]` | `saa-t3-2.md:260,276` | FSx for OpenZFS "**최대 2,000,000 IOPS**, 수백 마이크로초" → 확인한 공식 페이지에 2,000,000 수치 없음. 문서: 캐시 데이터 "millions of IOPS"·디스크 최대 **400,000** IOPS(Single-AZ 2), 제품 페이지: 캐시 1백만+·디스크 **350,000** IOPS(문서 간 디스크 수치도 상이) | https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html · https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/performance.html · https://aws.amazon.com/fsx/openzfs/features/ |
| G-3.1-13 | `[부정확]` | `saa-t3-2.md:243` | FSx for Lustre "서브밀리초 지연·수 TBps·수백만 IOPS"를 한 수치로 제시 → 공식은 **스토리지 클래스별로 다름**: SSD=일관된 서브밀리초·최대 TBps, Intelligent-Tiering=전 데이터에 일관된 저지연이 아님(자주 접근하는 데이터만), HDD=한 자릿수 ms·수십 GBps. 같은 문서 `:246`은 3개 클래스를 나열하나 성능 차이를 구분하지 않음 | https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html |
| G-3.1-14 | `[부분]`·`[의심]` | `saa-t3-2.md:172,177,314` | 인스턴스 스토어 소실 조건을 "중지·종료·하드웨어 장애"로만 서술 → 공식 표: **최대 절전(hibernate)·인스턴스 유형 변경·인스턴스 은퇴(retirement)** 도 소실. `:180-182`의 🧠원리("중지 시 다른 물리 호스트에 배치될 수 있다" 등)는 공식 설명이 아님(공식은 사건별 표와 "블록을 암호학적으로 삭제"만 서술) | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html |
| G-3.1-15 | `[의심]` | `saa-t3-2.md:232` | FSx for Windows "인증: Active Directory 통합(**필수**)" — 이번에 확인한 공식 페이지는 "생성 시 AD 도메인에 조인할 수 있다"를 서술할 뿐 "필수" 단정 문장을 확보하지 못함 → `99-gaps.md`. 같은 줄 "SMB 2.0–3.1.1"은 **일치** ✓ | https://docs.aws.amazon.com/fsx/latest/WindowsGuide/supported-fsx-clients.html · https://docs.aws.amazon.com/fsx/latest/WindowsGuide/self-managed-AD.html |
| G-3.1-16 | `[의심]` | `saa-t3-1.md:173-175`, `saa-t3-2.md:139,161,179,218` 및 `saa-t3-2.md:312-313,321-322,324-325`(*원리* 줄) | 🧠원리 블록이 설계 이유를 추정(예: `saa-t3-2.md:161-164` EBS 암호화가 호스트에서 처리되는 이유를 "게스트 OS 키 접근 경로"로 설명, `:321-322` "Lustre POSIX가 SMB와 비호환"). 공식 근거 URL 없음 — 사실 진술과 추정 혼재 (전 문서 공통 이슈, G-1.1-13과 동일) | (`99-gaps.md` 참조) |

### 일치 확인(문서가 공식과 일치) — 참고
- `saa-t3-2.md:113-122` EBS 표: gp3 1 GiB–64 TiB·80,000 IOPS·2,000 MiB/s, gp2 16 TiB·16,000·250, io2 Block Express 4 GiB–64 TiB·256,000·4,000, io1 16 TiB·64,000·1,000 — **공식 표와 일치**(과거 2021년 블로그의 gp3 16,000 IOPS/1,000 MBPS는 구 사양).
- `:130-133` st1/sc1 500/250 IOPS·500/250 MiB/s·125 GiB–16 TiB ✓, Multi-Attach io1/io2만 ✓(`:101,157,291`), gp3가 동일 성능이면 gp2보다 저렴 ✓(`:124`, 20% 저렴), EFS Windows 미지원 ✓(`:189,293,311`), 인스턴스 스토어 재부팅 시 유지 ✓(`:177,314`), io2 Block Express 99.999% ✓(`:288`), `saa-t3-1.md:93` Express One Zone 99.95%·단일 AZ ✓, `:154` 프리픽스당 3,500/5,500 ✓(부분), S3 강한 일관성 "모든 리전" ✓.

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-3.1-17 | `[중복]` | `saa-t3-1`의 스토리지 클래스 비교·최소 보관 기간·Intelligent-Tiering·수명 주기(`:85-150`)는 공식 **Task 4.1(비용 최적화 스토리지)** 소관이고, Task 3.1이 요구하는 성능·확장성 서술(`:152-175`)보다 분량이 큼 — 4.1 조사에서 확정 |
| G-3.1-18 | `[중복]` | EBS 스냅샷·암호화(`saa-t3-2.md:146-164`)는 Task 1.3(암호화)·2.2(백업/내구성)와 겹침. 3.1 Skill(성능·확장)에는 직접 해당하지 않음 |
| G-3.1-19 | `[과잉]` | 없음 — 두 문서 모두 3.1 범위를 벗어난 큰 주제는 없음(위 `[중복]`만 해당) |

---

## Task 3.2 — 고성능의 탄력적인 컴퓨팅 솔루션 설계
**대응 문서**: `saa-t3-3`(EC2 인스턴스 유형·구매 옵션·배치 그룹·ENA/EFA), `saa-t3-4`(컴퓨팅 선택·ECS/EKS/Fargate·Lambda 튜닝·Batch·HPC) — 있음. 단 Skill 1·2(분리·스케일링 지표)는 매핑 문서가 아니라 `saa-t2-2`(메시징)·`saa-t2-3`(ASG)에 흩어져 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-3.2-01 | `[누락]` Knowledge 2 | **엣지 서비스가 지원하는 분산 컴퓨팅** — CloudFront Functions·Lambda@Edge·Local Zones·Wavelength·Outposts가 24개 문서 어디에도 없음(Grep `Lambda@Edge\|CloudFront Functions\|Local Zone\|Wavelength\|로컬 영역\|Outposts` → **0건**) | F-23, F-24 |
| G-3.2-02 | `[누락]` Knowledge 4 | **AWS Auto Scaling(스케일링 플랜)·Application Auto Scaling** — 공식 가이드가 예시로 직접 든 서비스인데 0건(Grep `Application Auto Scaling\|AWS Auto Scaling\|스케일링 플랜` → 0). ECS 서비스 오토스케일링 지표도 없음 | F-12, F-13 |
| G-3.2-03 | `[부분]` Skill 2 | **스케일링 지표·조건 식별** — `saa-t2-3.md:204-209`에 4정책 표(대상 추적·단계·예약·예측)만 있음. 사전 정의 지표 4종(`ASGAverageCPUUtilization` 등), **사용자 지정 지표 backlog per instance**(SQS 연동), 예측 스케일링 전제(24시간·14일 분석·48시간 예측·스케일 인 안 함), **웜 풀**(Grep `Warm Pool\|웜 풀\|backlog\|백로그\|ApproximateNumberOfMessages` → 0), 단순 조정 레거시 여부가 없음. 정작 3.2 매핑 문서(`saa-t3-3/4`)에는 스케일링 서술이 없음 | F-08, F-09, F-10, F-11 |
| G-3.2-04 | `[부분]` Skill 1·Knowledge 3 | **분리 설계와 메시징** — 3.2 매핑 문서 `saa-t3-4`에 SQS·SNS·EventBridge 언급 0건(Grep → 0). 메시징은 `saa-t2-2`(Task 2.1)에만 있고, "큐가 버퍼링 로드 밸런서 역할→소비자 독립 스케일", SNS→SQS 팬아웃, 큐 깊이 기반 ASG 스케일링 같은 **스케일링 연계 서술**은 없음 | F-09, F-20 |
| G-3.2-05 | `[부분]` Knowledge 6 | **컨테이너 오케스트레이션 세부** — ECS 용량 공급자·Fargate Spot·Managed Instances 스케일링 전략, EKS 컴퓨트 선택지(Karpenter·관리형 노드 그룹·Fargate 프로필·자체 관리형)가 없음(Grep `Capacity Provider\|Karpenter` → 0). `saa-t3-4.md:137,154`에 ECS Managed Instances·EKS Auto Mode 이름만 한 줄씩 | F-14, F-15, F-17 |
| G-3.2-06 | `[부분]` Skill 4 | **리소스 크기 선택(Lambda 메모리 등)** — `saa-t3-4.md:190-197`에 메모리 범위(128–10,240 MB)·1,769 MB=1 vCPU·Power Tuning·arm64(Graviton) Lambda·Compute Optimizer 권장·Fargate 태스크 크기 선택이 없음(Grep `10,240\|1,769\|Power Tuning\|arm64\|Graviton\|Compute Optimizer` → 0, Graviton은 EC2만 `saa-t3-3.md:124`) | F-18, F-25 |
| G-3.2-07 | `[부분]` Knowledge 5 | **서버리스 확장 동작** — Lambda SQS 이벤트 소스 매핑 스케일링(5 배치로 시작·분당 300 증가·최대 1,250·최대 동시성 설정), Lambda 함수 간 동시성 상한은 `saa-t3-4.md:194` 한 줄(기본 1,000) | F-19 |
| G-3.2-08 | `[부분]` Skill 3 | **배치 그룹 제약** — `saa-t3-3.md:170-188`에 클러스터 PG의 **버스터블(T)·Mac1·M7i-flex 불가**, 인터넷/DX 트래픽 5 Gbps, 피어링 VPC 가능, **Capacity Blocks 미지원**·On-Demand Capacity Reservation 권장이 없음(10 Gbps 단일 흐름·단일 AZ·단일 요청 권장은 ✓) | F-06 |
| G-3.2-09 | `[부분]` Knowledge 1 | **EMR** — 3.2 문서에는 없고 `saa-t3-9.md:202-204`(Task 3.5)에 배포 3종(EC2·EKS·Serverless)만 있음. 컴퓨트 관점의 선택 기준(Serverless=클러스터 관리 없음, on EC2=제어, on EKS=K8s 공유), 태스크 노드 Spot 권장, 관리형 스케일링이 없음 | F-22 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-3.2-10 | `[내부불일치]`·`[구식]` | `saa-t3-3.md:85,122` vs `:102,104,105` | 프로세서 접미사를 "**없음=Intel**, a=AMD, g=Graviton"으로 설명하나, 같은 문서 대표 유형은 **M8i·C8i·R8i·X8i**(Intel을 `i`로 표기). 현행 명명 규칙은 **`i`=Intel processors**(예: M7i) | https://docs.aws.amazon.com/ec2/latest/instancetypes/instance-type-names.html |
| G-3.2-11 | `[부정확]` | `saa-t3-3.md:84` | 기능 접미사 "b=EBS 최적화, n=네트워크 강화" → 공식: **b=Block storage optimization**, **n=Network and EBS optimized**(EBS 포함), 그 밖에 `e`(추가 스토리지/메모리)·`z`(고주파수)·`flex` 등이 있음 | 위와 동일 |
| G-3.2-12 | `[의심]` | `saa-t3-3.md:102-105` | vCPU:메모리 비율(범용 1:4·컴퓨트 1:2·메모리 1:8 이상) — **R 계열 1:8만 공식 확인**(r7i.large=2 vCPU/16 GiB), M·C 비율은 공식 문장 미확보 → `99-gaps.md`. 또 `:102`에서 T를 범용에 넣고 `:103`에서 "버스트 범용" 행으로 다시 나눠 표가 중복 | https://aws.amazon.com/blogs/aws/new-seventh-generation-memory-optimized-amazon-ec2-instances-r7i/ |
| G-3.2-13 | `[부분]` | `saa-t3-3.md:111` | "T3/T3a/T4g는 기본 unlimited" → 공식은 **T8i·T4g·T3a·T3** 기본 unlimited (T8i 누락). Dedicated Host의 T3는 unlimited 불가·Spot은 standard 권장 같은 예외 없음 | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/burstable-performance-instances-unlimited-mode.html |
| G-3.2-14 | `[의심]` | `saa-t3-3.md:178-179` | 배치 그룹 4종 모두 "전용 호스트: 불가", "Spot 중지/최대 절전: 불가" — 이번에 읽은 공식 페이지 구간에서 확인 못 함(오히려 파티션 PG는 **Dedicated Instances** 2파티션을 허용한다고 서술; 전용 *호스트*와 구분 필요) → `99-gaps.md` | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html |
| G-3.2-15 | `[부정확]` | `saa-t3-4.md:192,201-204` | Lambda 메모리를 "성능 튜닝의 **유일한** 손잡이"로 표현 → 공식 서술은 메모리가 **주된(principal) 수단**이며 CPU 병목을 넘어서면 이득이 줄어듦(Power Tuning으로 변곡점 확인). 아키텍처(arm64)·임시 스토리지 등 다른 요소도 영향 | https://aws.amazon.com/blogs/compute/operating-lambda-performance-optimization-part-2/ · https://repost.aws/knowledge-center/lambda-reduce-costs |
| G-3.2-16 | `[의심]` | `saa-t3-4.md:119,224` | AWS Batch 최대 실행 시간 "**무제한**" — 공식 조회에서는 작업 제한 시간 **최소 60초**만 확인(상한 문장 미확보) → `99-gaps.md` | https://docs.aws.amazon.com/batch/latest/APIReference/API_JobTimeout.html |
| G-3.2-17 | `[의심]` | `saa-t3-4.md:197` | 콜드 스타트 "수십~수백 ms" — 공식 근거 없는 수치 표기 | (`99-gaps.md`) |
| G-3.2-18 | `[의심]` | `saa-t3-3.md:92,113,128,160,192,225` · `saa-t3-4.md:106,122,181,201,231,251` (🧠원리) | 설계 이유 추정(예: Graviton이 전력 효율적인 이유를 RISC로 설명 `:128-131`, 스팟 2분 경고의 설계 목표 `:160-164`, "Fargate가 실행 모드로 설계된 이유" `:181-184`). 공식 근거 URL 없음 (전 문서 공통 이슈, G-1.1-13과 동일) | (`99-gaps.md`) |
| G-3.2-19 | `[일치]` 참고 | `saa-t3-3.md:124,170-177,205,223`, `saa-t3-4.md:97,113,194-196` | Graviton 최대 40% 가격 대비 성능 ✓, 클러스터 PG 단일 AZ·10 Gbps 단일 흐름 ✓, 파티션/스프레드 AZ당 7 ✓, ENA 최대 100 Gbps ✓, EFA AZ/VPC 비통과 ✓, Hpc7g·Hpc8a 존재 ✓, 정밀 시간 배치 그룹(4번째 전략) 존재 ✓, Lambda 15분·기본 동시성 1,000 ✓, Provisioned Concurrency=사전 초기화 ✓ | F-05, F-06, F-07 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-3.2-20 | `[중복]` | **컨테이너·컴퓨팅 선택 서술이 두 문서에 반복**: `saa-t2-2.md:175`(컨테이너 ECS vs EKS, EC2 vs Fargate)·`:211`(컴퓨팅 선택 기준)과 `saa-t3-4.md:84-127`(결정 트리·옵션 비교표·ECS/EKS/Fargate). ECS/EKS/Fargate 키워드 `saa-t3-4` 49회 + `saa-t2-2` 42회 |
| G-3.2-21 | `[중복]` | 구매 옵션 표·스팟 중단 메커니즘(`saa-t3-3.md:133-164`)은 문서 스스로 "비용 상세는 `saa-t4-2`"라 밝힌 Task 4.2 영역과 겹침 — 4.2 조사에서 확정 |
| G-3.2-22 | `[과잉]` | 없음 — 3.2 범위를 벗어난 큰 주제는 없음. 단 EFA 원리·SR-IOV 설명(`saa-t3-3.md:198-229`)은 시험 가이드 범위보다 상세 |

---

## Task 3.3 — 고성능 데이터베이스 솔루션 결정
**대응 문서**: `saa-t3-5`(RDS·Multi-AZ/읽기 복제본·Aurora·RDS Proxy), `saa-t3-6`(DynamoDB·DAX·ElastiCache·캐싱 전략) — 있음. 서버리스 DB(ACU)·DynamoDB 용량 모드의 비용 서술은 `saa-t4-3`(Task 4.3)에 있음.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-3.3-01 | `[누락]` Knowledge 6 | **동종/이기종 마이그레이션 — AWS DMS·SCT(DMS Schema Conversion)·CDC** — 공식 지식 항목의 *예시 그대로*인데 24개 문서 어디에도 없음(Grep `DMS\|Database Migration Service\|Schema Conversion\|SCT\|이기종\|동종\|heterogeneous\|homogeneous\|Babelfish` → 무관한 `saa-t2-5.md:178` 1건뿐) | F-20 |
| G-3.3-02 | `[누락]` Knowledge 8·Skill 4 | **목적별 DB 유형** — 문서(DocumentDB)·와이드 컬럼(Keyspaces)·그래프(Neptune)·시계열(Timestream)·인메모리 DB(MemoryDB)가 3.3 문서에 없음. `saa-t4-3.md:81-83`(비용 맥락 표 한 줄씩)에만 Timestream·Neptune·DocumentDB가 있고 **MemoryDB는 24개 문서 0건**, Keyspaces 0건 | F-01, F-15 |
| G-3.3-03 | `[누락]` Knowledge 2·Skill 5 | **ElastiCache의 현행 구성** — Valkey 엔진, ElastiCache Serverless, Multi-AZ 복제 그룹(복제본 ≤5·99.99% SLA 조건), 업그레이드만 가능(다운그레이드 불가)이 없음(Grep `Valkey\|ElastiCache Serverless\|99.99` → 3.3 문서 0건). MemoryDB와의 구분(휘발 캐시 vs 영속 DB)도 없음 | F-11, F-12, F-15 |
| G-3.3-04 | `[부분]` Knowledge 4 | **용량 계획 세부** — RDS 스토리지 오토스케일링 조건·최대 임계값·증분 규칙, Provisioned IOPS 범위(1,000–256,000), Oracle·SQL Server 추가 스토리지 볼륨, **Aurora I/O-Optimized vs Standard**(I/O 지출 25% 기준), Performance Insights(평균 활성 세션)가 없음(Grep `스토리지 자동\|Storage Auto\|I/O-Optimized\|Performance Insights` → 0). `saa-t3-5.md:162-173`은 3행 유형 표뿐 | F-04, F-09, F-21 |
| G-3.3-05 | `[부분]` Skill 1 | **읽기 복제본 구성** — Aurora Auto Scaling(리더 평균 CPU/연결 수 대상 추적·정책은 지표당 1개), 커스텀 엔드포인트, `ReplicaLag` 모니터링, 원본 자동 백업 전제, RDS PostgreSQL 연쇄 복제본(3단계·최대 155), 교차 리전 지원 엔진 범위가 없음(`saa-t3-5.md:121-134`는 개념 7줄) | F-05, F-08 |
| G-3.3-06 | `[부분]` Knowledge 5 | **RDS Proxy 내부 동작** — 다중화(multiplexing)·핀닝(pinning)과 다중 테넌트에서의 효율 저하, 처리 불가 연결 거부가 없음(`saa-t3-5.md:222-243`는 풀링·페일오버·IAM 3점) | F-10 |
| G-3.3-07 | `[부분]` Knowledge 3·Skill 2 | **DynamoDB 용량·파티션 한도** — 파티션당 읽기 3,000/쓰기 1,000 단위, 항목 400 KB, 온디맨드 "이전 피크 2배·30분 규칙"·신규 테이블 초기 처리량(쓰기 4,000/읽기 12,000), 프로비저닝 버스트 5분, 적응형 용량이 없음(`saa-t3-6.md:88-89` 샤딩 한 줄, `:128-140` 용량 모드 표) | F-16, F-22 |
| G-3.3-08 | `[부분]` Skill 2·Knowledge 1 | **글로벌 설계** — Aurora Global Database 구성 요건(보조 리전 최대 10·보조 클러스터 읽기 인스턴스 16·메모리 최적화 클래스 필요)과 DynamoDB 글로벌 테이블 **MRSC**(2025-06)가 없음. `saa-t3-6.md:154-164`·`:312`는 last-writer-wins만 서술(G-2.2-15와 같은 갭). `saa-t3-5.md:125`의 "보조 클러스터 읽기 인스턴스 16"은 ✓ | F-06, `2-2.md` F-08 |
| G-3.3-09 | `[누락]` Knowledge 3 | **쓰기 집약 패턴과 한계** — RDS·Aurora 쓰기는 **단일 라이터가 한계**라는 점과 대안(스케일 업·샤딩·DynamoDB·큐 버퍼링)이 없음(Grep `단일 라이터\|single writer\|쓰기 확장\|쓰기 집약` → 0, "읽기 집약"은 `saa-t3-6.md:146`의 DAX 맥락뿐) | F-05의 `[블로그]`, F-22 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-3.3-10 | `[오류]` | `saa-t3-5.md:170-173` (🧠원리) | "범용 SSD(**gp2/gp3**)는 버스트 크레딧 방식으로 …" → **gp3는 버스트 모델이 없다**("gp3 volumes do not use burst performance", 기본 3,000 IOPS·125 MiB/s를 지속). 버스트는 gp2(GiB당 3 IOPS, 1 TB 미만 3,000 버스트)만 해당. RDS 블로그도 gp3를 "스토리지 크기와 독립적 성능"으로 서술 | https://docs.aws.amazon.com/ebs/latest/userguide/general-purpose.html · https://aws.amazon.com/blogs/database/is-amazon-rds-for-postgresql-or-amazon-aurora-postgresql-a-better-choice-for-me/ |
| G-3.3-11 | `[구식]` | `saa-t3-6.md:176` | TTL "삭제는 **48시간 이내** 처리" → 현행 서술은 "만료 후 **통상 수일(a few days) 내**, 최선 노력"(쓰기 처리량 미소비·추가 비용 없음은 ✓) | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html · https://repost.aws/knowledge-center/dynamodb-expired-ttl-not-deleted |
| G-3.3-12 | `[구식]` | `saa-t3-6.md:196,200-208` | ElastiCache "두 가지 엔진 지원: **Redis와 Memcached**" → 현행 **Valkey·Memcached·Redis OSS** 3엔진. 비교표에 Valkey 없음 | https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/SelectEngine.html |
| G-3.3-13 | `[구식]` 명칭 | `saa-t3-5.md:194,213,216-220`, `saa-t4-3.md:39,78,169-176,192,236,261` | "Aurora Serverless **v2**" → 2026-04 AWS 블로그 안내문 "Aurora Serverless v2 has been renamed Aurora serverless", 플랫폼 버전 4(성능 최대 30%↑·0으로 확장 유지). 공식 제품 문서 본문의 표기 확인은 미완 → `99-gaps.md`. `saa-t3-5`에는 ACU 범위(0.5~256)·0 ACU 자동 일시정지 설명이 없고 `saa-t4-3`에만 있음 | https://aws.amazon.com/about-aws/whats-new/2026/04/aurora-serverless-smarter-scaling/ · https://aws.amazon.com/blogs/database/understanding-how-certain-database-parameters-impact-scaling-in-amazon-aurora-serverless-v2/ |
| G-3.3-14 | `[의심]` | `saa-t3-5.md:168` | RDS Magnetic "사용 중단됨. 새 DB 인스턴스 생성에는 제공되지 않으며 gp3 또는 io2 권장" — 이번 조회에서 공식 문장 미확보(RDS API 레퍼런스는 MariaDB 등에서 magnetic(`standard`) 범위를 여전히 서술) → `99-gaps.md` | https://docs.aws.amazon.com/sdk-for-go/api/service/rds/index.html |
| G-3.3-15 | `[부정확]` | `saa-t3-6.md:184` | DynamoDB "수평 확장, **무제한 처리량**" → 설계상 **파티션당 읽기 3,000·쓰기 1,000 단위/초** 한도가 있고, 온디맨드도 이전 피크 2배 규칙·계정/테이블 쿼터가 있음 | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html · https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/on-demand-capacity-mode.html |
| G-3.3-16 | `[내부불일치]` | `saa-t3-5.md:208` vs `:113,145` | 비교표 "RDS: Multi-AZ는 스탠바이 1개" ↔ 본문·비교표(`:113`,`:145`)는 Multi-AZ **DB 클러스터는 스탠바이 2개** | (문서 내부) |
| G-3.3-17 | `[의심]` | `saa-t3-6.md:203,207` | Redis "스냅샷(RDB) + **AOF** 로그 지원", Redis "단일 스레드(명령 처리)", Memcached 암호화 "제한적" — 확인한 공식 자료는 스냅샷(RDB)·"Memcached 멀티스레드"만 서술, AOF·스레딩·암호화 비교 문장 미확보 → `99-gaps.md` | https://aws.amazon.com/elasticache/redis-vs-memcached/ |
| G-3.3-18 | `[의심]` | `saa-t3-6.md:76` | DynamoDB "리전 내 **3개 AZ**에 자동 복제" — 숫자 3의 공식 문장 미확보(확인한 자료는 "multiple") → `99-gaps.md` | — |
| G-3.3-19 | `[의심]` | `saa-t3-5.md:103,115,131,150,170,198,216,240` · `saa-t3-6.md:91,109,123,137,149,161,212,233` (🧠원리) | 설계 이유 추정(예: LSI가 생성 시에만 가능한 이유를 "파티션 키 공유" 한 줄로 단정 `:109-112`, 강한 일관성이 RCU 2배인 이유 `:123-126`). 공식은 규칙만 서술 — 근거 URL 없음 (전 문서 공통 이슈, G-1.1-13) | (`99-gaps.md` 참조) |
| G-3.3-20 | `[일치]` 참고 | `saa-t3-5.md:111-113,124-125,127,182,196,211` · `saa-t3-6.md:102-104,119-121,135,144-146,168,175,221-223` | Multi-AZ 60~120초/클러스터 ✓, 읽기 복제본 15(Db2 3·Oracle/SQL Server 5) ✓, Global DB 보조 클러스터 읽기 인스턴스 16 ✓, Aurora 256 TiB(2025 상향)·구버전 128 TiB ✓, RDS 기본 볼륨 64 TiB·Oracle/SQL Server 256 TiB ✓, Backtrack MySQL 전용 ✓, GSI/LSI 표 ✓, 강한 일관성 2배·GSI 최종 일관성만 ✓, RCU/WCU ✓, DAX 마이크로초·강한 일관성 우회 ✓, Streams 24시간 ✓, TTL 추가 비용 없음 ✓, 캐싱 전략 3종 ✓ | F-03, F-05, F-06, F-08, F-09, F-14, F-17, F-18 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-3.3-21 | `[중복]` | RDS Proxy·Lambda 연결 고갈 설명이 `saa-t3-5.md:222-243`(Task 3.3)과 `saa-t2-2.md:72,116,251,313-317`(Task 2.1)에 반복(G-2.1-15와 연결) |
| G-3.3-22 | `[중복]`·불균형 | 서버리스 DB(ACU)·DynamoDB 용량 모드가 `saa-t4-3`(Task 4.3, 비용)에서는 상세(ACU 0.5 단위·0 ACU 일시정지)한데 `saa-t3-5/6`(Task 3.3, 성능·설계)에서는 얕음 — 역할 분담 불균형(4.3 조사에서 확정) |
| G-3.3-23 | `[과잉]` | 없음 — 3.3 범위를 벗어난 큰 주제는 없음 |

---

## Task 3.4 — 고성능 및/또는 확장 가능한 네트워크 아키텍처 결정
**대응 문서**: `saa-t3-7`(Route 53·CloudFront·Global Accelerator·ELB 성능), `saa-t3-8`(피어링·Transit Gateway·VPN·Direct Connect·DX Gateway·PrivateLink) — 있음. VPC 서브넷/라우팅/IGW/NAT 기초는 `saa-t1-3`(Task 1.2 소관, 공식 3.4 지식 "서브넷 티어·라우팅·IP 주소 지정"과 겹침), ELB 상세·교차 영역·스티키는 `saa-t2-3`.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-3.4-01 | `[부분]` Knowledge 2·Skill 1·2 | **네트워크 설계 방법(서브넷 티어·라우팅·IP 주소 지정)** — 3.4 매핑 문서(`saa-t3-7/8`)에는 서브넷 설계가 없고 `saa-t1-3.md:79-81,108,124`(CIDR 표·VPC 도식·Egress-Only IGW)에 분산. 서브넷 단일 AZ·IP 5개 예약 근거, 공용/사설 판정 기준(IGW 경로 유무), 보조 CIDR, 라우트 테이블 한도(500/1,000/전파 100), **IPAM**(Grep `IPAM` → 0), IPv6 듀얼 스택 설계가 없음 | F-08, F-09, F-10 |
| G-3.4-02 | `[누락]` Knowledge 4·Skill 1·2 | **Cloud WAN**(글로벌 토폴로지의 공식 수단)이 24개 문서 어디에도 없음(Grep `Cloud WAN` → 0). Route 53 Resolver(하이브리드 DNS)는 `saa-t1-4.md:155`의 DNS Firewall 한 줄뿐 — 인바운드/아웃바운드 엔드포인트·전달 규칙 서술 없음(Grep `Resolver` → 해당 1건) | F-20, F-21 |
| G-3.4-03 | `[부분]` Knowledge 1 | **CloudFront 성능 구조** — 리전 엣지 캐시·Origin Shield·요청 병합·**오리진 그룹 장애 조치**(GET/HEAD/OPTIONS만)가 없음(Grep `Origin Shield\|오리진 그룹\|리전 엣지\|Regional Edge` → 0). `saa-t3-7.md:146-178`는 오리진·엣지·배포·캐시 동작·OAC·서명 URL만 | F-01, F-02 |
| G-3.4-04 | `[부분]` Knowledge 3·Skill 4 | **로드 밸런싱 전략** — `saa-t3-7.md:216-232`는 3행 표. ALB 가중 대상 그룹(블루/그린)·알고리즘 선택(최소 미처리 요청), NLB의 AZ당 고정 IP·소스 IP 보존, **고정 IP+L7 패턴(NLB→ALB / Global Accelerator / IPAM)**, GWLB의 GENEVE 6081·GWLB 엔드포인트·흐름 고정, ELB 자동 확장·DNS 사용 권고가 없음. 스티키·교차 영역은 `saa-t2-3`(15회)에 있으나 3.4 문서와 연결되지 않음 | F-15, F-16, F-17 |
| G-3.4-05 | `[부분]` Knowledge 4 | **Direct Connect 세부** — 속도(50 Mbps~400 Gbps)·전용/호스팅 구분, **MACsec**(10/100/400 Gbps 전용·일부 위치), SiteLink, **복원력 모델(최대 99.99% / 높은 99.9%)** 없음(Grep `MACsec\|SiteLink` → 0). 암호화는 "VPN 얹기"만 서술(`saa-t3-8.md:173,221`) | F-18 |
| G-3.4-06 | `[부분]` Knowledge 4·Skill 2 | **VPN 대역폭 확장** — ECMP(TGW+동적 라우팅, VGW·정적 불가)·단일 플로우 1.25 Gbps 한계·VPN Concentrator·Accelerated VPN 구분이 없음(Grep `ECMP` → 0). `saa-t3-8.md:143`은 표준 1.25/대용량 5 Gbps만(대용량은 TGW **또는 Cloud WAN** 연결 전용·VGW 불가인 조건 미기재) | F-19 |
| G-3.4-07 | `[부분]` Knowledge 4 | **Transit Gateway 한도·동작** — 어태치먼트 5,000·피어링 50·VPC 어태치먼트 AZ별 서브넷 요구·Local Zone 서브넷 어태치 불가·프라이빗 호스팅 영역 이름 해석 미지원·다중 라우트 테이블(세그먼트화)이 없음(`saa-t3-8.md:101-128`). 중복 CIDR 불가는 ✓ | F-12 |
| G-3.4-08 | `[부분]` Skill 3 | **리소스 배치 결정** — 리전 선택 4요소(규정·지연·비용·서비스 가용성), Local Zones/Wavelength/Outposts 선택 기준이 3.4 문서에 없음(Grep `Local Zone\|Wavelength\|Outposts` → 0, `3-2` 참조) | F-22, `3-2.md` F-24 |
| G-3.4-09 | `[부분]` Knowledge 1 | **Route 53 라우팅 정책 수** — `saa-t3-7.md:101`이 "7종"으로 표기하며 **IP 기반(IP-based) 라우팅**이 빠짐(공식 8종, `2-2.md` F-16). 지연 기반 라우팅의 리졸버 위치/edns0 한계도 미기재(`:107-119`) | F-07, `2-2.md` F-16 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-3.4-10 | `[오류]` | `saa-t3-7.md:209,251` | "**CloudFront 앞에 Global Accelerator**를 붙여 고정 IP를 제공하면서 CDN 캐싱도 활용" / "CloudFront에 고정 IP를 부여하고 싶다 → Global Accelerator + CloudFront 조합" → 공식 문서상 표준 가속기의 엔드포인트는 **NLB·ALB·EC2 인스턴스·Elastic IP 4종**이며 CloudFront는 엔드포인트 유형이 아님. 즉 GA 뒤에 CloudFront를 두거나 CloudFront에 GA로 고정 IP를 붙이는 구성은 성립하지 않음(정적 IP+HTTP는 GA→ALB/NLB, 캐싱은 별도 CloudFront 경로) | https://docs.aws.amazon.com/global-accelerator/latest/dg/about-endpoints.html · https://repost.aws/knowledge-center/global-accelerator-unhealthy-endpoints · https://aws.amazon.com/global-accelerator/faqs/ |
| G-3.4-11 | `[부정확]` | `saa-t3-7.md:224` | GWLB "계층 L3/L4" → 공식 서술은 **layer 3(네트워크 계층)** 이며 모든 IP 패킷·모든 포트를 수신(G-2.2-14와 같은 이슈). 또한 `:222` ALB 프로토콜에 **gRPC** 누락 | https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html · https://aws.amazon.com/compare/the-difference-between-the-difference-between-application-network-and-gateway-load-balancing/ |
| G-3.4-12 | `[의심]` | `saa-t3-7.md:110,115` | Geoproximity가 "**Route 53 Traffic Flow 기능에서만** 사용 가능" — 확인한 공식 페이지는 "지도는 Traffic Flow에서만 제공"이라고 서술할 뿐 geoproximity 자체가 Traffic Flow 전용이라는 문장은 없고, re:Post에 콘솔에서 geoproximity를 구성하는 안내가 있음 → 최신 콘솔 동작은 `99-gaps.md`. bias 방향(양수=확대·음수=축소)과 범위(±1~99)는 ✓ | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy-geoproximity.html · https://repost.aws/knowledge-center/route-53-geoproximity-routing-console |
| G-3.4-13 | `[부정확]` | `saa-t3-8.md:212` | Direct Connect 대역폭·지연 "일관됨 (**SLA 보장**)" → AWS 서술의 SLA는 **연결 가용성**(복원력 모델: 최대 99.99%, 높은 99.9%)이며 대역폭·지연을 SLA로 보장한다는 문장은 아님 | https://docs.aws.amazon.com/wellarchitected/2025-02-25/framework/rel_planning_network_topology_ha_conn_private_networks.html |
| G-3.4-14 | `[의심]` | `saa-t3-8.md:147,171,174` | VPN 구축 "수 분", DX 구축 "수 주" — 공식 문장 미확보 → `99-gaps.md` V-34. DX 데이터 전송 단가 "인터넷 대비 낮음"은 **이후 `4-4.md` F-13에서 확인됨**(인하된 DX DTO 요율 적용·AWS로의 인바운드 무료·시드니 예시 인터넷 $0.114/GB vs DX $0.0420/GB — 요율은 위치·리전별 예시) | https://repost.aws/knowledge-center/connect-vpc |
| G-3.4-15 | `[의심]` | `saa-t3-8.md:254-259` | PrivateLink가 "소비자·제공자 **CIDR이 겹쳐도** 통신 가능" — 구조 설명(🧠원리)은 그럴듯하나 공식 문장 미확보(확인한 자료는 제공자 NLB+엔드포인트 서비스·소비자 인터페이스 엔드포인트 구조까지) → `99-gaps.md` | https://docs.aws.amazon.com/vpc/latest/privatelink/privatelink-share-your-services.html |
| G-3.4-16 | `[의심]` | `saa-t3-7.md:79-82,95-99,117-120,133-136,175-178,192-195,211-214,229-232` · `saa-t3-8.md:96-99,125-128,152-155,176-179,201-204,223-226,256-259` (🧠원리) | 설계 이유 추정(예: ALB가 NLB보다 느린 이유를 "L7 헤더 파싱"으로 단정 `:229-232`, DX가 암호화를 안 하는 이유 `:176-179`). 공식 근거 URL 없음 (전 문서 공통 이슈, G-1.1-13) | (`99-gaps.md` 참조) |
| G-3.4-17 | `[일치]` 참고 | `saa-t3-7.md:106,111,150,165-173,186-190,223` · `saa-t3-8.md:82-83,94,109-111,123,141,161-167,185,236-237` | Weighted 0~255 ✓, Multivalue 최대 8 ✓, OAC(OAI 대체·권장) ✓, Signed URL/Cookie 구분 ✓, ACM us-east-1(CloudFront) ✓, GA 고정 IP 2개·TCP/UDP·캐싱 없음·헬스 체크 장애 조치 ✓, NLB 수백만 RPS·고정 IP ✓, 피어링 비전이·CIDR 중복 불가 ✓, n(n−1)/2 산술 ✓, TGW 어태치먼트 유형·중복 CIDR 경로 비전파 ✓, VPN 연결당 터널 2개 ✓, VIF 3종 ✓, 게이트웨이 엔드포인트(S3·DynamoDB·무료) vs 인터페이스 엔드포인트(과금) ✓ | F-01~F-04, F-06, F-07, F-11~F-13, F-16, F-19 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-3.4-18 | `[중복]` | ELB 유형 비교(ALB/NLB/GWLB)가 `saa-t3-7.md:216-232`와 `saa-t2-3`에 반복(G-2.2-20에서 예고) — 현재 두 문서의 정보량이 달라(`t2-3`이 교차 영역·스티키·대상 유형 상세) 서로 보완이 아니라 분산된 상태 |
| G-3.4-19 | `[중복]` | Route 53 라우팅 정책·헬스 체크가 `saa-t3-7.md:101-136`(3.4)과 `saa-t2-4`(Task 2.2)에 걸쳐 서술 — Task 2.2 조사와 정합 확인 필요 |
| G-3.4-20 | `[과잉]` | 없음 — 두 문서 모두 3.4 범위를 벗어난 큰 주제는 없음 |

---

## Task 3.5 — 고성능 데이터 수집 및 변환 솔루션 결정
**대응 문서**: `saa-t3-9`(파이프라인 구조·Kinesis 4종·Glue·Athena·EMR·Lake Formation·QuickSight·배치 vs 스트리밍·전송 서비스·분석 선택표) — 있음(단일 문서).

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-3.5-01 | `[누락]` Knowledge 5·Skill 1 | **수집 접점 보안·데이터 레이크 보호** — Kinesis VPC 엔드포인트(PrivateLink)·KMS 서버 측 암호화·엔드포인트 정책, S3 레이크 암호화·버킷 정책·감사 로그, Lake Formation **S3 위치 등록·IAM 역할(서비스 연결 vs 사용자 지정)·신뢰된 호출자** 서술이 없음(Grep `VPC 엔드포인트\|PrivateLink\|KMS\|암호화` → `saa-t3-9.md` 0건). Lake Formation 절(`:216-231`)은 개념 7줄 | F-03, F-13 |
| G-3.5-02 | `[누락]` Skill 7 | **데이터 형식 변환(예: CSV→Parquet) 방법** — Athena **CTAS**, Glue ETL 잡/북마크, **Firehose 내장 JSON→Parquet/ORC 변환(S3 목적지 전용)**·동적 파티셔닝, EMR이 없음(Grep `CTAS` → 0). Parquet은 Athena 비용 설명(`:184,191,298`)에만 등장 — 공식 Skill의 *예시 그대로*가 빠져 있음 | F-04, F-11, F-12 |
| G-3.5-03 | `[부분]` Knowledge 6·Skill 3 | **크기·속도 요건** — 전송 시간 산술(데이터량÷대역폭), DataSync 대역폭 제한·에이전트(1 태스크씩) 병렬화·증분 전송·시간 창 계획이 없음. `:273-276`은 Snow 관점 원리 서술뿐 | F-08 |
| G-3.5-04 | `[부분]` Knowledge 7·Skill 2 | **Kinesis 설계 세부** — **EFO**(소비자별 2 MB/s)와 비-EFO의 읽기 공유, **온디맨드 vs 프로비저닝 용량 모드**, 보존 확장(7일)/장기(365일) 요금 구조, **MSK(Kafka 호환) vs Kinesis** 선택, Redshift 스트리밍 수집(Kinesis 직접)이 없음(EFO는 `:324` 괄호 한 줄) | F-01, F-02, F-06, F-07 |
| G-3.5-05 | `[부분]` Knowledge 2·Skill 6 | **수집 패턴·구성 선택** — 마이크로 배치, 동종/이기종 수집, 하이브리드(실시간+배치 계층), 스트리밍 배칭, Firehose 버퍼 한도가 없음(`:245-258`은 배치 vs 스트리밍 2분법 표) | F-07 |
| G-3.5-06 | `[누락]` Knowledge 3 | **Storage Gateway**(공식 예시)가 3.5 문서에 없음 — 24개 문서 전체 0건(G-3.1-01과 동일 구멍). "지속적 하이브리드 캐시 접근(Storage Gateway) vs 전송 작업(DataSync)" 구분 서술 없음 | `3-1.md` F-20 |
| G-3.5-07 | `[부분]` Skill 4 | **시각화 전략** — SPICE 가져오기 vs 직접 쿼리, 임베디드 분석, ML 인사이트(예측·이상 탐지), VPC 프라이빗 접근, 서비스 명칭 **Amazon Quick**이 없음(`:235-241` 7줄) | F-14 |
| G-3.5-08 | `[부분]` Knowledge 1·Skill 5 | **분석 서비스 선택표** — `:280-290`에 **Redshift(데이터 웨어하우스·Spectrum)·OpenSearch** 행이 없음(MWAA는 공식 Out-of-Scope 목록에 있어 갭이 아님; Redshift는 Firehose 목적지로만 언급 `:107,297`, 분석 서비스로는 미서술) | F-15, F-16, F-06 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-3.5-09 | `[구식]` | `saa-t3-9.md:46,81,267,271,273-276,303` | **Snow 패밀리**(Snowcone→Snowball Edge→Snowmobile)를 현재 선택지로 서술하고 "대역폭 부족+수백 TB 이상이면 Snow", "Snowball Edge는 엣지 컴퓨팅도 가능" → 현행: **Snowball Edge는 신규 고객 불가**, "어떤 Snow Family 디바이스도 신규 주문 불가"(기존 고객은 계속 사용), 대안은 **DataSync(온라인)·AWS Data Transfer Terminal(물리 전송)·파트너**, 엣지 컴퓨팅은 Outposts. 현행 3.5 Task 본문 예시에는 Snow가 없으나 현행 **In-Scope 서비스 목록에는 "AWS Snow Family"가 아직 포함**됨(이전 버전과 비교해 제거됐는지는 확인하지 못함 → `99-gaps.md`) | https://docs.aws.amazon.com/snowball/latest/developer-guide/snowball-edge-availability-change.html · https://aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/ · https://aws.amazon.com/data-transfer-terminal/ |
| G-3.5-10 | `[구식]`·`[부정확]` | `saa-t3-9.md:324-325` | "Kinesis Data Streams 샤드는 자동 확장되지 **않는다**… 수동으로 늘림" → **프로비저닝 모드**에만 해당. **온디맨드 모드**는 용량 계획 없이 샤드를 자동 관리(이전 30일 피크의 2배까지 수용). 프로비저닝도 `UpdateShardCount`·Auto Scaling 유틸리티로 조정 가능 | https://docs.aws.amazon.com/help-panel/KDS/latest/help-panel/kds-data-stream-capacity.html · https://docs.aws.amazon.com/streams/latest/dev/how-do-i-size-a-stream.html |
| G-3.5-11 | `[부정확]` | `saa-t3-9.md:99,340` | "동일 스트림을 여러 컨슈머가 **동시에 독립적으로** 읽을 수 있습니다(fan-out)" → 기본(비-EFO) 소비자는 샤드당 읽기 **2 MB/s를 공유**하며, 소비자별 독립 처리량은 **EFO**(소비자·샤드마다 2 MB/s)를 써야 함. 각자 오프셋을 유지하는 점은 맞음 | https://aws.amazon.com/kinesis/data-streams/pricing/ · https://aws.amazon.com/kinesis/data-streams/getting-started/ |
| G-3.5-12 | `[부정확]` | `saa-t3-9.md:222,361` | Lake Formation 권한이 "Athena·EMR·Redshift Spectrum·Glue ETL **전반에 일관되게** 적용" → 엔진별 지원 범위가 다름: Athena SQL·Redshift Spectrum·Spark on EMR(EC2)=테이블 R/W·열/행/셀 읽기, **Hive on EMR=행/셀 미지원**, **Athena Spark·EMR on EKS 미지원**, **Glue ETL 열/행 읽기는 Glue 5.0+** | https://docs.aws.amazon.com/lake-formation/latest/dg/working-with-services.html |
| G-3.5-13 | `[의심]` | `saa-t3-9.md:235,240,290` | QuickSight "사용자 수 기반 과금(**Standard·Enterprise 에디션**)", 서비스명 "Amazon QuickSight" → 공식 가이드는 **Amazon Quick**. 과거 백서는 Standard($9/사용자/월)·Enterprise($18/작성자+독자 세션당) 서술, 현행 FAQ는 "사용자당 월 정액"으로 서술 — 요금제 현행 여부 확인 필요 → `99-gaps.md` | https://docs.aws.amazon.com/whitepapers/latest/big-data-analytics-options/amazon-quicksight.html · https://aws.amazon.com/quick/quicksight/faqs/ |
| G-3.5-14 | `[의심]` | `saa-t3-9.md:167` | Glue "70개 이상의 데이터 소스 연결 지원" — 공식 문장 미확보 → `99-gaps.md` | — |
| G-3.5-15 | `[부정확]` | `saa-t3-9.md:116` | Managed Flink "Java·Scala·SQL" → 공식은 **Java·Python·SQL·Scala** (Python 누락, 경미) | https://docs.aws.amazon.com/managed-flink/latest/apiv2/Welcome.html |
| G-3.5-16 | `[의심]` | `saa-t3-9.md:126,144,170,189,209,228,255,273` (🧠원리) | 설계 이유 추정(예: Kinesis가 4개 서비스로 나뉜 이유 `:126-129`, Firehose가 데이터를 즉시 제거하는 이유 `:144-147`, Lake Formation이 IAM을 대체하지 않는 설계 이유 `:228-231`). 공식 근거 URL 없음 (전 문서 공통, G-1.1-13) | (`99-gaps.md` 참조) |
| G-3.5-17 | `[일치]` 참고 | `saa-t3-9.md:95-98,107,109-110,119,137-142,183-184,200-207,220-226,239,266` | 샤드 1 MB/s·1,000건/s·읽기 2 MB/s ✓, 보존 24시간~365일 ✓, Firehose 목적지·버퍼·Lambda 변환 ✓, Flink 이전 명칭 ✓, Athena $5/TB·컬럼형 비용 절감 ✓, EMR 배포 3종·EMRFS ✓, Lake Formation=Catalog 위 권한 계층·열/행/셀·LF-tags·교차 계정 ✓, SPICE ✓, DataSync NFS·SMB→S3·EFS·FSx ✓ | F-01, F-04, F-05, F-12, F-13, F-14, F-08 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-3.5-18 | `[중복]`·불균형 | EMR 상세(`saa-t3-9.md:196-212`)는 공식 **Task 3.2** 지식 예시("AWS Batch, Amazon EMR, AWS Fargate")이기도 한데 3.2 매핑 문서(`saa-t3-3/4`)에는 EMR이 없음(G-3.2-09) — 문서 배치가 Task 경계와 어긋남 |
| G-3.5-19 | `[과잉]` | Kinesis Video Streams(`:121-124`)는 공식 3.5 Task 본문에는 언급되지 않으나, **현행 In-Scope 서비스 목록(Media Services)에 "Amazon Kinesis Video Streams"가 포함**되어 시험 범위 밖은 아님(분량 4줄로 작음 — 과잉이라기보다 우선순위 낮음) |

---

## Task 4.1 — 비용에 최적화된 스토리지 솔루션 설계
**대응 문서**: `saa-t4-1`(S3 비용 구조·클래스·Intelligent-Tiering·수명 주기·EBS gp3/미사용 정리·전송 비용·EFS/FSx 계층·Storage Lens) + `saa-t4-5`(Cost Explorer·Budgets·CUR·Anomaly Detection·태그·통합 결제·Compute Optimizer/Trusted Advisor·Well-Architected — **Task 4.1~4.4 공통**이라 이 절에서 한 번만 대조하고 4.2~4.4 절은 참조) — 있음(2개 문서). AWS Backup은 `saa-t1-5`·`saa-t2-5`가 다룸(비용 관점 서술은 `saa-t1-5.md:229` 콜드 전환 한 줄).

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-4.1-01 | `[누락]` Knowledge 1 | **Requester Pays**(공식 Knowledge 첫 항목의 예시) — 24개 SAA 문서 전체에서 0건(Grep `Requester Pays\|요청자 지불\|요청자 부담` → `flutter_app/assets/content/saa` 전역 0). 소유자=저장 비용, 요청자=요청·다운로드 비용, 익명 접근 불가·인증 필요 | F-12 |
| G-4.1-02 | `[누락]` Skill 1 | **배치 vs 개별 업로드 전략** — 소형 객체 집계(tar)·요청 비용·IA 128 KB 최소 과금·Glacier 객체당 40 KB 오버헤드·전환 요청 폭증이 없음. `saa-t4-1.md`는 멀티파트 용어 풀이(`:66`)와 `AbortIncompleteMultipartUpload` 한 줄(`:134`)뿐 | F-05, F-09 |
| G-4.1-03 | `[누락]` Skill 4 | **스토리지 오토 스케일링이 필요한 시점** — Grep `오토 스케일링\|자동 확장` → `saa-t4-1.md` 0건. S3·EFS(탄력) vs EBS·FSx(증설 자동화, FSx Windows 증가만 가능), ONTAP 용량 풀 서술 없음 | F-29, `3-1.md` F-11·F-24 |
| G-4.1-04 | `[누락]` Knowledge 8·Skill 3·7 | **하이브리드 스토리지·마이그레이션 서비스 선택** — DataSync·Transfer Family·Storage Gateway가 `saa-t4-1.md`에 0건(Grep). "가장 저렴한 전송 방법" 판단(DataSync GB당 요금·Transfer Acceleration 추가 요금·Snow 신규 불가)이 없고, 전송 절은 경로별 요금표(`:172-206`)뿐. Storage Gateway는 24개 문서 전체 0건(G-3.1-01) | F-14, F-26, F-27, `3-5.md` F-09 |
| G-4.1-05 | `[부분]` Knowledge 5·Skill 6 | **백업 전략·아카이브 솔루션** — `saa-t4-1.md`는 DLM 한 줄(`:163`)뿐. **EBS Snapshots Archive**(최대 75%·90일·전체 스냅샷·복원 72시간)·**Recycle Bin**·**AWS Backup 콜드 스토리지**(최소 90일, 지원 리소스 제한)·**Tape Gateway**가 없음(Grep `Snapshots Archive\|스냅샷 아카이브\|Recycle Bin` → 0) | F-18~F-20, F-25, F-26 |
| G-4.1-06 | `[부분]` Knowledge 6 | **블록 스토리지 HDD/SSD 비용 선택** — gp2/gp3만 다룸(`:144-170`). **st1/sc1(HDD)**·io1/io2 비용·용도 비교가 없음(HDD는 FSx 표 `:216`에만 등장) | F-15, `3-1.md` F-07·F-08 |
| G-4.1-07 | `[부분]` Knowledge 4 | **FSx·EFS 세부** — FSx for **NetApp ONTAP**(SSD+용량 풀 티어링·압축/중복 제거)·**OpenZFS** 없음, FSx for Lustre는 Persistent/Scratch만(현행 클래스 SSD·**Intelligent-Tiering**·HDD 누락), FSx Windows 중복 제거 누락. EFS는 One Zone 클래스·수명 주기 정책 3종 설정(IA 30일·Archive 90일 기본, 첫 접근 시 Standard 복귀)·Archive 요건(Elastic+범용) 서술 없음(`:208-219` 표 6행) | F-21~F-24 |
| G-4.1-08 | `[부분]` Skill 5·9 | **S3 수명 주기 세부** — 버전 관리 비용(`NoncurrentVersionExpiration`·`NewerNoncurrentVersions`), **128 KB 미만 객체 기본 미전환(2024-09 이후)**, 하향 전환만 가능, Standard-IA→Glacier 30일 규칙, 규칙 하루 1회 실행이 없음(`:118-140`) | F-08, F-09 |
| G-4.1-09 | `[부분]` Skill 2 | **올바른 스토리지 크기** — 과잉 프로비전은 언급(`:164`)하나 **EBS 크기 축소 불가·새 볼륨으로 이전**, FSx Windows **증가만 가능**, EFS/S3는 크기 지정 불필요 서술이 없음 | F-29, `3-1.md` F-11 |
| G-4.1-10 | `[부분]` Skill 10 | **가장 비용 효율적인 스토리지 서비스 선택 매트릭스** — S3 vs EBS vs EFS vs FSx를 요구(프로토콜·지연·공유)→가격 순으로 고르는 표가 없음(서비스별 부분 서술만) | `4-1.md` §2-1 |
| G-4.1-11 | `[부분]` Knowledge 2·3 (`saa-t4-5`) | **비용 관리 기능·도구 세부** — Cost Explorer **다년(최대 38개월)·시간·리소스 단위 옵션**, **CUR 2.0 / Data Exports·FOCUS 1.0**, 비용 할당 태그 활성화 지연(최대 24시간+24시간)·AWS 생성 태그(`createdBy`)는 관리 계정이 활성화, Budgets 작업 3종 정확 서술, Cost Optimization Hub 등이 없음 | F-30~F-34 |
| G-4.1-12 | `[누락]` Knowledge 3 (`saa-t4-5`) | **Trusted Advisor 전체 점검의 지원 플랜 조건** — Basic은 보안 6종+서비스 한도뿐, 전체는 Business Support+/Enterprise/Unified Operations. 2027-01-01 플랜 개편(Developer·Business·Enterprise On-Ramp 종료) 미반영 | F-35 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-4.1-13 | `[부정확]` | `saa-t4-1.md:266` (Pitfall 2) | "EC2를 Stop해도 EBS 과금… **완전히 삭제(Terminate)해야 볼륨 요금이 멈춥니다**" → Terminate 때 자동 삭제되는 것은 `DeleteOnTermination`이 True인 볼륨뿐: **루트 볼륨(시작 시)만 기본 삭제**, **추가 데이터 볼륨은 기본 보존**(콘솔로 시작 시 첨부해도 보존, CLI는 삭제). 종료 후에도 남은 데이터 볼륨은 계속 과금. "Stop 시 과금 지속"은 ✓ | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/preserving-volumes-on-termination.html · https://repost.aws/knowledge-center/deleteontermination-ebs · https://repost.aws/knowledge-center/ec2-billing-terminated |
| G-4.1-14 | `[부정확]` | `saa-t4-1.md:111,115-116,281-282` | Intelligent-Tiering "소용량 객체가 많은 버킷에서는 **오브젝트당 모니터링 요금이 절감액을 초과**" → 공식: **128 KB 미만 객체는 자동 계층화 대상이 아니며 항상 Frequent Access 단가이고 모니터링·자동화 요금도 부과되지 않음**(손해가 아니라 *절감이 없음*). 128 KB 이상 객체에서 모니터링 요금이 절감을 넘는 임계는 공식 문장 미확보. "128 KB 미만은 항상 Frequent Access" 자체는 ✓ | https://aws.amazon.com/s3/faqs/ · https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html |
| G-4.1-15 | `[부정확]` | `saa-t4-1.md:235` | **Storage Class Analysis를 Storage Lens의 비용 최적화 기능으로 서술** → Storage Class Analysis는 별도의 S3 분석(S3 analytics) 기능(버킷·접두어·태그 필터로 접근 패턴을 관찰, 버킷마다 설정). Storage Lens와 별개 | https://docs.aws.amazon.com/help-panel/AmazonS3/latest/console/hp-storage-class-analysis-page.html · https://repost.aws/knowledge-center/s3-reduce-costs |
| G-4.1-16 | `[부분]` | `saa-t4-1.md:228-234` | Storage Lens가 "**일별로 집계해 대시보드와 권장사항**… 수명주기 규칙 미적용 버킷 탐지" → **권장 사항·고급 비용 최적화 지표(수명 주기 규칙 수 등)는 고급 티어(추가 요금)**, 무료 티어는 일 단위 수집·콘솔 14일 조회. 티어 구분이 서술에 없음 | https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage_lens_basics_metrics_recommendations.html · https://aws.amazon.com/s3/faqs/ |
| G-4.1-17 | `[의심]` | `saa-t4-1.md:162,254` | 미연결 EBS 볼륨을 "콘솔·Trusted Advisor·**Cost Explorer**로 탐지" → Cost Explorer는 비용 분석 도구(스냅샷 사용 유형 `EBS:SnapshotUsage` 조회 등)이며 미연결 볼륨 *탐지* 기능으로 문서화된 근거 미확보. 문서화된 수단은 Trusted Advisor(EBS 비용 최적화 권고·Underutilized/Over-provisioned) + Compute Optimizer | https://docs.aws.amazon.com/awssupport/latest/user/compute-optimizer-with-trusted-advisor.html · https://repost.aws/knowledge-center/ebs-understand-billing-information |
| G-4.1-18 | `[의심]` | `saa-t4-1.md:134` | `AbortIncompleteMultipartUpload`를 "**7일 후 자동 정리를 권장**" → 7일은 API 문서의 *예시* 값이며 공식 "권장값"으로 명시한 문장은 미확보(일수는 사용자가 정의) | https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutBucketLifecycle.html |
| G-4.1-19 | `[의심]` | `saa-t4-1.md:179-180` | AZ 간 전송 요율 서술(퍼블릭/EIP 과금, 프라이빗 IP "더 낮은 요율") → EC2 On-Demand 요금 페이지로 대조 필요 → **`G-4.4-13`에서 종결**(확인된 것은 "같은 AZ 무료"와 AZ 간 각 방향 $0.01/GB 서술뿐, 퍼블릭 IP/EIP 경로의 별도 요율은 공식 문장 미확보) | (G-4.4-13 참조) |
| G-4.1-20 | `[부정확]` | `saa-t4-5.md:124-131,305-306` | Budget Actions 조치 3종을 "**IAM 정책 연결·SNS 알림·SSM Automation 실행**"으로 서술 → 공식 action type은 **IAM 정책, 서비스 제어 정책(SCP), 실행 중 인스턴스 대상(EC2·RDS)** 3종이며 자동 실행 또는 승인 워크플로 선택, 실제 정책에 SSM 자동화 권한이 포함됨. SNS는 예산 *알림*(작업 알림은 수신자 필수). IAM 연결로 신규 리소스를 막는 사례 자체는 ✓ | https://aws.amazon.com/blogs/aws-cloud-financial-management/get-started-with-aws-budgets-actions/ · https://docs.aws.amazon.com/cost-management/latest/userguide/billing-example-policies.html |
| G-4.1-21 | `[내부불일치]`·`[부정확]` | `saa-t4-5.md:86` vs `:133` | 비교표는 Budgets "**실시간**(갱신 주기 8~12시간)", 본문은 "하루 최대 3회 갱신(8~12시간 간격)" → 공식: **하루 최대 3회**, "실시간" 아님 | https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html |
| G-4.1-22 | `[구식]` | `saa-t4-5.md:18-19,87,140-158` | CUR을 "S3 CSV"로만 서술 → 현행 안내는 **Data Exports의 CUR 2.0이 신규·권장 방식**(고정 스키마·중첩 열·SQL 열 선택), 기존 CUR은 콘솔 "Legacy Pages"; 표준화가 필요하면 FOCUS 1.0. Parquet 옵션도 존재 | https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html · https://docs.aws.amazon.com/cur/latest/userguide/dataexports-migrate.html · https://aws.amazon.com/blogs/aws-cloud-financial-management/data-exports-for-focus-1-0-is-now-generally-available/ |
| G-4.1-23 | `[의심]` | `saa-t4-5.md:147` | CUR "보고서 크기가 **100만 행**을 초과하면 자동으로 여러 파일로 분할" → 공식 서술은 ".csv 파일 또는 .csv 파일 모음과 매니페스트 파일"이며 100만 행 기준 문장은 미확보 | https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html |
| G-4.1-24 | `[의심]`·`[구식]` | `saa-t4-5.md:158` | "Developer·Business·Enterprise Support 비용은 전월 CUR 기준으로 해당 월 **6~7일**에 반영" → 일자 근거 문장 미확보, 그리고 Developer·Business·Enterprise On-Ramp 플랜은 **2027-01-01 종료**(Business Support+ 신설)라 명칭이 곧 구식 | https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html |
| G-4.1-25 | `[부정확]` | `saa-t4-5.md:232` | Compute Optimizer "CloudWatch 지표 **14일 이상 수집**" → 공식: **룩백 기간 기본 14일**(32일·93일 선택, 93일은 유료 향상된 인프라 지표). 14일은 분석 기간 기본값이지 "수집 최소 요건" 문장이 아님 | https://docs.aws.amazon.com/help-panel/compute-optimizer/latest/console/rightsizing-lookback.html |
| G-4.1-26 | `[의심]` | `saa-t4-5.md:178-179` | Cost Anomaly Detection 고객 관리형 모니터 "특정 값(**최대 10개**) 수동 선택" → 공식 문장 미확보. 확인된 사실: 감지 차원 4종(AWS 서비스·연결 계정·비용 범주·비용 할당 태그), AWS 관리형은 차원의 상위 5,000개 값을 개별 평가, 고객 관리형은 선택 차원을 합산 평가 | https://docs.aws.amazon.com/help-panel/awsaccountbilling/latest/console/hp-ad-monitormethod.html · https://aws.amazon.com/aws-cost-management/aws-cost-anomaly-detection/faqs/ |
| G-4.1-27 | `[의심]` | `saa-t4-5.md:211,299,346` | 태그 backfill "**최대 12개월**" → 이번 조회에서 콘솔 도움말(요청은 24시간에 1회, 현재 태그 상태를 해당 월에 소급)만 확인, "12개월" 상한 문장은 미재확인 → `99-gaps.md` | https://docs.aws.amazon.com/help-panel/awsaccountbilling/latest/console/hp-costallocation.html |
| G-4.1-28 | `[의심]` | `saa-t4-1.md:11-22,208-219` | 후반 절(EFS·FSx 계층표 `:208-219`)에 대응하는 출처 URL이 출처 목록에 없음(출처 6건은 S3 클래스·Storage Lens·EBS·EC2 요금·가이드뿐) — 내용 자체는 대체로 ✓지만 문서 내 근거 추적 불가 | https://aws.amazon.com/efs/storage-classes/ · https://aws.amazon.com/fsx/when-to-choose-fsx/ |
| G-4.1-29 | `[일치]` 참고 | `saa-t4-1.md:94,97-99,102-111,133-134,144-156,163-165,176-185,213-217,331` · `saa-t4-5.md:94-102,113-122,194-197,215-219,248-252` | I-T 30/90일·옵션 Archive(90)/Deep Archive(180)·검색 요금 없음·**최소 보관 없음**·128 KB 미만 Frequent 고정 ✓, 클래스별 최소 보관(IA 30·Glacier 90·DA 180) ✓, Glacier IR=ms·FR/DA=복원 ✓, gp3 20% 저렴·3,000 IOPS·125 MiB/s·버스트 없음·gp2 3 IOPS/GB(100 GiB=300) ✓, Elastic Volumes 무중단 ✓, DLM 보존 정책 ✓, 인터넷 인바운드 무료·월 100 GB 아웃바운드 무료·S3→CloudFront 무료 ✓, 게이트웨이 엔드포인트 무료 ✓, EFS IA/Archive/Intelligent-Tiering 관계 ✓, FSx Windows HDD 절감 ✓, FSx Lustre Scratch=임시 ✓; Cost Explorer 13개월·18개월 예측·API $0.01·비활성화 불가·CUR와 동일 데이터셋 ✓, Budgets 예산 유형·실제/예측 알림 ✓, 태그 활성화 필요 ✓, 통합 결제(볼륨 할인·RI/SP 공유·계정별 끄기) ✓, Well-Architected 5원칙 ✓ | F-01, F-06, F-15, F-19, F-21, F-24, F-31~F-33 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-4.1-30 | `[중복]` | 비용 관리 도구·태그·통합 결제가 `saa-t4-5`에 모이고 `saa-t4-2/3/4` 본문에서 다시 반복될 가능성(Task 4.2~4.4 Knowledge가 동일 2항목) — 4.2~4.4 절에서 중복 여부 대조 |
| G-4.1-31 | `[중복]` | EBS gp2→gp3·Elastic Volumes가 `saa-t4-1.md:144-170`과 `saa-t3-5`(성능 관점)에 분산 — 서로 상호 참조 없음(G-3.1-xx 참조) |
| G-4.1-32 | `[과잉]` | 없음 — `saa-t4-1` §5 데이터 전송 표(`:172-206`)는 공식 Skill 3("가장 저렴한 전송 방법")·Task 4.4 영역이어서 4.1 문서에 전송 요금표가 포함된 것은 타당하나 *방법 비교*는 부재(G-4.1-04) |

---

## Task 4.2 — 비용에 최적화된 컴퓨팅 솔루션 설계
**대응 문서**: `saa-t4-2`(구매 옵션 표·RI vs Savings Plans·Spot·오토스케일링 비용·Compute Optimizer·서버리스/Graviton) + `saa-t4-5`(Knowledge 1·2 공통 — `G-4.1-11`~`G-4.1-27`에서 대조 완료) — 있음. 인접 문서: `saa-t3-3`(EC2 구매 옵션 표 일부 중복, G-3.2-21).

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-4.2-01 | `[누락]` Skill 1 | **로드 밸런싱 전략(ALB vs NLB vs GWLB)의 비용 관점** — `saa-t4-2.md`에 ELB 서술이 전혀 없음. **LCU/NLCU 과금 모델**(최대 차원 하나만 과금), 호스트·경로 라우팅으로 ALB 통합, NLB LCU 예약이 없음(Grep `LCU\|Load Balancer Capacity` → 24개 SAA 문서 전체 0건) | F-17, F-18 |
| G-4.2-02 | `[누락]` Knowledge 9·Skill 2 | **EC2 최대 절전(hibernation)·수평 vs 수직 스케일링** — 최대 절전은 스팟 중단 동작 한 줄(`saa-t4-2.md:145` "동면")뿐(`saa-t3-3.md:155`에 개념 한 줄). 과금 규칙(hibernated 사용료 없음·EBS+RAM 저장 과금·`stopping` 과금·시작 시 활성화)과 "수평/수직" 비교(Grep `수평\|수직` → 0건)가 없음 | F-10, `3-2.md` F-08~F-12 |
| G-4.2-03 | `[누락]` Skill 4 | **워크로드 클래스별 필요 가용성(프로덕션 vs 비프로덕션)** — 비프로덕션 스케줄 중지(**Instance Scheduler**, Grep → 0건)·Spot 허용·저가 리전 배치 서술 없음. WA "소비 모델 채택 75%"는 `saa-t4-5.md:249`에만 있고 4.2 문서와 연결 안 됨 | F-11, F-22 |
| G-4.2-04 | `[누락]` Knowledge 3 | **AWS 글로벌 인프라와 비용(리전별 가격 차이)** — Grep `리전 가격\|Region 가격\|리전별 요금` → 0건. 개발/테스트를 저가 리전에 두는 판단, 이전 비용 vs 절감 비교 없음 | F-22, `3-4.md` F-22 |
| G-4.2-05 | `[누락]` Knowledge 5 | **분산 컴퓨팅 전략(엣지 프로세싱) 비용** — CloudFront Functions vs Lambda@Edge 단가·선택 기준 없음(`saa-t4-2.md` Grep → 0건) | F-21, `3-2.md` F-23 |
| G-4.2-06 | `[누락]` Knowledge 6 | **하이브리드 컴퓨팅(AWS Outposts) 비용 모델** — Outposts는 24개 SAA 문서 전체 0건. 3년 약정·지불 옵션 3종·가격에 설치/유지보수 포함·갱신/반납 규칙 없음 | F-19 |
| G-4.2-07 | `[부분]` Skill 3 | **비용 효율적 컴퓨팅 서비스 선택(Lambda vs EC2 vs Fargate)** — `:230-248`은 서버리스 장점 불릿뿐. Lambda 과금 구조(1 ms·GB-초·무료 티어·프로비저닝 동시성·계층 요금), **Fargate 과금(초 단위·최소 1분)·Fargate Spot 70%**, 고사용률 상시 부하에서의 break-even 비교표가 없음 | F-14, F-15, F-16 |
| G-4.2-08 | `[부분]` Knowledge 4 | **구매 옵션 세부** — **Zonal vs Regional RI(용량 보장)**·**On-Demand Capacity Reservation**(Grep `Zonal\|Regional RI\|Capacity Reservation` → `saa-t4-2` 0건, `saa-t3-3.md:145` 표 한 줄), RI Marketplace 조건(12% 수수료·잔여 ≥1개월), **SP 적용 순서(RI→EC2 Instance SP→Compute SP)·시간당 약정 이월 불가**, Dedicated Host 과금(호스트 초 단위·예약 최대 70%) | F-04~F-07, F-20, F-23 |
| G-4.2-09 | `[부분]` Skill 5·6 | **인스턴스 패밀리·크기 선택의 비용 요소** — 범주(범용/컴퓨트/메모리…) 선택 기준, **AMD(a) 약 10%·Graviton 약 20% 저렴**, Windows는 Graviton 불가, T 버스트 unlimited 추가 요금, Optimize CPUs(라이선스 절감)가 없음. `saa-t4-2`는 rightsizing·Graviton 불릿만, 패밀리 선택은 `saa-t3-3` 담당인데 상호 참조 없음 | F-12, F-13, F-24, `3-2.md` F-01~F-05 |
| G-4.2-10 | `[부분]` Knowledge 9 | **스케일링 전략 연계** — `:176-198`은 정책 4종 표와 혼합 정책 1문장. **ASG 혼합 인스턴스 정책(On-Demand base·비율·반올림)**, 예측 스케일링 전제(24시간 지표·14일 분석)·웜 풀과 연결이 없음(`3-2.md` F-08~F-11 상호 참조 없음) | F-09, `3-2.md` F-08~F-11 |
| G-4.2-11 | `[부분]` Knowledge 4 | **Spot 설계** — 다양화(풀=AZ×유형)·속성 기반 선택·Spot 배치 점수·**price-capacity-optimized**·재조정 권고·On-Demand 폴백 비권장이 없음(`:137-174`은 전략 3종 코드블록) | F-08 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-4.2-12 | `[구식]`·`[부정확]` | `saa-t4-2.md:77,286` | **Convertible RI "최대 54%"** → 현행 공식 표는 **최대 66%**(Standard RI 최대 72%) — Compute SP(66%)와 같은 수준으로 서술. `:277-287` 비교 서술의 "할인율 낮음" 방향은 ✓ | https://aws.amazon.com/ec2/pricing/reserved-instances/ · https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html |
| G-4.2-13 | `[구식]` | `saa-t4-2.md:107-113` | Savings Plans 유형을 **3종**(Compute·EC2 Instance·SageMaker)으로 서술 → 현행 plan-types·FAQ는 **4종**(+ **Database Savings Plans**: 최대 35%, **1년 약정**, Aurora·RDS·DynamoDB·ElastiCache 등). SageMaker는 "SageMaker AI Savings Plans". (AWS 문서 자체도 페이지별로 2·3·4종 서술이 섞임) | https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html · https://aws.amazon.com/savingsplans/faqs/ · https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-services.html |
| G-4.2-14 | `[의심]` | `saa-t4-2.md:97,100,265,299` | "**AWS 공식 문서는 'Savings Plans를 RI보다 먼저 고려하라'고 명시**… 우선 권장" → 확인한 공식 서술은 "유연성이 필요하면 SP, 안정적·예측 가능·**특정 AZ 용량 필요**하면 RI, **혼합이 모범 사례**"(re:Post). "먼저 고려" 문장은 미확보. 용량 보장이 필요하면 SP가 답이 아니므로 Q1식 일반화 주의 | https://repost.aws/knowledge-center/ec2-savings-plan-reserved-instances |
| G-4.2-15 | `[의심]` | `saa-t4-2.md:115,274-275,323-327` | "**Savings Plans는 스팟 인스턴스에 적용되지 않는다… AWS 공식 문서가 명시**" → 이번 조회에서 해당 문장을 확보하지 못함(확보: SP는 EC2 On-Demand 사용분 등 대상 서비스 설명, "단기 할인은 Spot 사용"). 내용 자체는 모순 없으나 근거 URL 필요 → `99-gaps.md` | https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-services.html · https://repost.aws/knowledge-center/savings-plans-considerations |
| G-4.2-16 | `[구식]` | `saa-t4-2.md:160-169` | 스팟 플릿 전략을 `lowestPrice`·`diversified`·`capacityOptimized` 3종으로 서술하고 lowestPrice를 "비용 최소화"로 제시 → 현행 모범 사례는 **price-capacity-optimized**(가격과 풀 용량 균형)이며 `capacityOptimizedPrioritized`도 존재, EC2 Fleet 문서상 기본값은 lowestPrice이나 권고는 다양화 | https://aws.amazon.com/blogs/compute/best-practices-to-optimize-your-amazon-ec2-spot-instances-usage/ · https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html |
| G-4.2-17 | `[부정확]` | `saa-t4-2.md:240` | Graviton "동일 성능 대비 온디맨드 가격 **약 20% 저렴 (Graviton3 기준)**" → AWS 대표 서술은 "동급 x86 대비 **최대 40% 가격 대비 성능**". "약 20% 저렴"은 Graviton이 Intel 대비 시간당 가격이 낮다는 지침 서술(us-east-1 예시)이며 "Graviton3 기준" 수식은 근거 미확보. Fargate·Lambda에서는 "약 20% 낮은 비용"이 별도 서술 | https://docs.aws.amazon.com/prescriptive-guidance/latest/optimize-costs-microsoft-workloads/right-size-selection.html · https://aws.amazon.com/fargate/faqs/ |
| G-4.2-18 | `[부정확]` | `saa-t4-2.md:81` | Dedicated Host "**온디맨드 이상 비용**" → 호스트 단위 과금이며 **예약 최대 70% 할인·Savings Plans(가상 호스트만)** 적용 가능, 즉 예약 시 온디맨드보다 낮아질 수 있음. BYOL(소켓/코어/VM 기반 라이선스) 목적은 ✓ | https://aws.amazon.com/ec2/dedicated-hosts/pricing/ · https://aws.amazon.com/ec2/dedicated-hosts/faqs/ |
| G-4.2-19 | `[부정확]` | `saa-t4-2.md:244-248` | "**Lambda와 Fargate**는 사용한 시간만 밀리초 단위로 과금 — 유휴 시 비용 없음" → Lambda는 **1 ms 단위**이나 Fargate는 **초 단위·최소 1분**, Lambda 프로비저닝 동시성은 유휴 중에도 과금. `:232-236` 원리 설명도 동일 일반화 | https://aws.amazon.com/fargate/faqs/ · https://aws.amazon.com/lambda/pricing/ |
| G-4.2-20 | `[부분]` | `saa-t4-2.md:204-217` | Compute Optimizer 룩백 14일(기본)·93일(유료) ✓ — **32일 옵션** 누락(경미). 지원 리소스 목록에 상용 라이선스(SQL Server on EC2)·**유휴 권고 대상(NAT Gateway·DynamoDB 프로비저닝·ElastiCache·MemoryDB)** 누락. 지원 리소스 중 RDS·Aurora 포함은 ✓ | https://docs.aws.amazon.com/compute-optimizer/latest/ug/supported-resources.html · https://docs.aws.amazon.com/help-panel/compute-optimizer/latest/console/rightsizing-lookback.html |
| G-4.2-21 | `[의심]` | `saa-t4-2.md:144-145` | 스팟 중단 시 "종료·중지·동면 중 선택 가능" → 이번 조회에서 **최대 절전 지정 가능**(Stop API로는 불가)만 문장 확보, 종료·중지 선택지는 직접 문장 미확보 → `99-gaps.md` | https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/EC2/Instance.html |
| G-4.2-22 | `[의심]` | `saa-t4-2.md:85-88,102-105,117-120,132-135,171-174,191-194,225-228,245-248` (🧠원리) | 설계 이유 추정(예: 절감률이 높을수록 유연성이 낮은 이유를 AWS의 "용량 계획 예측 가능성"으로 단정 `:85-88`, Compute Optimizer가 자동 변경을 안 하는 이유 `:225-228`). 공식 근거 URL 없음 (전 문서 공통, G-1.1-13) | (`99-gaps.md` 참조) |
| G-4.2-23 | `[일치]` 참고 | `saa-t4-2.md:75-80,122-130,143-145,177-189,208-219,277-284` | Standard RI 최대 72%·SP Compute 66%·EC2 Instance SP 72%·Spot 최대 90% ✓, RI 지불 옵션 3종(선납 비중↑ 할인↑)·No Upfront도 약정 ✓, Spot 2분 알림 ✓, Rebalance Recommendation 존재 ✓, 정책 4종(대상 추적·단계·예약·예측) ✓, Compute Optimizer 14일/93일 ✓·권고만 제공 ✓, RI 취소 불가·Marketplace는 Standard만 ✓, Compute SP가 EC2·Fargate·Lambda 적용 ✓ | F-02, F-05, F-06, F-08, F-13 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-4.2-24 | `[중복]` | EC2 구매 옵션 표가 `saa-t4-2.md:73-81`과 `saa-t3-3.md:140-150` 부근에 이중 존재(G-3.2-21에서 예고) — 수치는 4.2 쪽에만 있어 불일치 위험은 낮으나 상호 참조 없음 |
| G-4.2-25 | `[중복]` | 비용 관리 도구·태그·통합 결제는 `saa-t4-5`에 있고 `saa-t4-2`는 Knowledge 1·2를 따로 다루지 않음 — 구조상 중복은 없으나 4.2 문서에서 `saa-t4-5`로의 연결이 없음(`coversTasks`에는 4.2 포함) |
| G-4.2-26 | `[과잉]` | 없음 — 서버리스·Graviton 절(`:230-248`)은 공식 Task 4.2 Knowledge 8("컴퓨팅 사용률 최적화 — 컨테이너·서버리스·마이크로서비스")에 해당 |

---

## Task 4.3 — 비용에 최적화된 데이터베이스 솔루션 설계
**대응 문서**: `saa-t4-3`(DB 서비스 선택·RDS RI·용량 계획·Aurora Serverless v2/DynamoDB 모드·백업 보존) + `saa-t4-5`(Knowledge 1·2 공통 — `G-4.1-11`~`G-4.1-27` 대조 완료) — 있음. 인접: `saa-t3-5`(DB 성능: RDS Proxy·읽기 복제본·캐싱), `saa-t2-2`(RDS Proxy 개념).

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-4.3-01 | `[누락]` Knowledge 7·Skill 5 | **DB 마이그레이션(동종/이기종)과 스키마·데이터 이전** — DMS·SCT·동종/이기종 구분이 24개 SAA 문서 전체에서 0건(Grep `DMS\|Database Migration Service\|Schema Conversion\|이기종\|동종` → 무관한 DR 문장 1건뿐). 비용 구조(복제 인스턴스+로그 스토리지·서버리스·**SCT 무료**·전송 규칙)도 없음 | F-17, `3-3.md` F-20 |
| G-4.3-02 | `[누락]` Skill 2 | **DB 엔진 결정(MySQL vs PostgreSQL)** — AWS 공식 비교(읽기 vs 쓰기 성능, 객체-관계형, ACID, 고급 기능)·라이선스 모델(License Included vs 오픈소스)·상용→오픈소스 전환 절감 서술이 없음(`saa-t4-3.md`에는 엔진 이름만 등장 `:76,172,261`) | F-18 |
| G-4.3-03 | `[누락]` Skill 4 | **시계열·열 기반 DB 유형** — Timestream 한 줄(`:81`), **Redshift·Athena/Parquet(열 형식)·InfluxDB**가 4.3 문서에 없음(Redshift는 `saa-t3-9`·`saa-t1-4`에만, 비용 관점 없음) | F-15, F-16 |
| G-4.3-04 | `[누락]` Knowledge 6 | **데이터베이스 연결·프록시** — `saa-t4-3.md`에 RDS Proxy 0건(Grep). 기능은 `saa-t3-5.md:222`·`saa-t2-2.md:72`에 있으나 **요금 모델**(vCPU-시간당·Serverless는 ACU-시간당)·"연결 때문에 인스턴스를 키우는 비용 vs 프록시 비용" 판단이 없음 | F-14, `3-3.md` F-10 |
| G-4.3-05 | `[부분]` Knowledge 3 | **캐싱 전략** — ElastiCache를 비용 레버로만 언급(`:80,153,245`). **캐싱 전략(지연 로딩·쓰기 시 갱신·TTL)**, DAX, **Valkey 가격(Serverless 33%·노드 20% 저렴)**, 예약 노드, 데이터 티어링이 없음 | F-13, `3-3.md` F-13·F-14 |
| G-4.3-06 | `[부분]` Knowledge 5 | **DB 용량 계획·용량 단위** — ACU·RCU/WCU는 일부, **RPU(Redshift)**, DynamoDB **자동 확장·예약 용량·Standard-IA 테이블 클래스·TTL**, **Database Savings Plans**, **Aurora I/O-Optimized(25% 규칙)**가 없음(`:109-120,178-190`) | F-06, F-10~F-12, `3-3.md` F-04 |
| G-4.3-07 | `[부분]` Knowledge 8 | **데이터베이스 복제(읽기 복제본)의 비용** — 복제본을 "인스턴스 다운사이즈 수단"으로만 서술(`:146-155`). **복제본은 별도 인스턴스 요금**, **교차 리전 복제 데이터 전송 과금**·연쇄 생성으로 절감, Multi-AZ ≈ 2배가 없음 | F-02, F-03 |
| G-4.3-08 | `[부분]` Skill 1·Knowledge 4 | **백업·보존 정책(스냅샷 빈도)** — `:199-214`는 RDS 위주. 무료 범위의 *정확한 기준*(계정·리전 합계), **Aurora**(클러스터별 100%·스냅샷 복사본 항상 과금·보존 기간 밖 수동 스냅샷), **DynamoDB PITR·온디맨드 백업 과금**, AWS Backup 콜드 전환, 스냅샷 빈도 설계가 없음 | F-07, F-08, F-12, `4-1.md` F-25 |
| G-4.3-09 | `[누락]` Knowledge 5·Skill 3 | **RDS 중지(최대 7일)·Multi-AZ 비용·Extended Support** — 비프로덕션 절감 수단(중지/단일 AZ)과 **오래된 엔진 버전 방치 시 vCPU-시간당 추가 과금**이 없음 | F-02, F-04, F-09 |
| G-4.3-10 | `[부분]` Skill 3 | **서버리스 선택지** — Aurora Serverless v2·DynamoDB 온디맨드는 있으나(`:165-190`) **Redshift Serverless·ElastiCache Serverless**, DynamoDB 모드 선택의 *정량 기준*(활용률 35%)이 없음 | F-10, F-13, F-15 |
| G-4.3-11 | `[누락]` Knowledge 3 (공통) | **비용 도구의 DB 연계** — Trusted Advisor RDS 유휴·RDS/ElastiCache/Redshift 예약 최적화, Compute Optimizer RDS 권고·유휴 권고, Budgets RI 알림(RDS·Redshift·ElastiCache 포함)이 4.3 문서에 연결돼 있지 않음 | F-20, F-21 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-4.3-12 | `[구식]` | `saa-t4-3.md:61,227,248` | "**Savings Plans는 RDS에 적용되지 않음… RDS 비용 절감은 RDS 예약 인스턴스로만 가능**" → **Database Savings Plans**(re:Invent 2025, **1년**, 서버리스 최대 35%·프로비저닝 최대 20%·DynamoDB 온디맨드 최대 18%)가 RDS·Aurora·DynamoDB·ElastiCache 등에 적용됨. (Compute/EC2 Instance SP가 RDS에 미적용인 점은 ✓.) 같은 워크로드에 DB SP와 RDS RI·DynamoDB 예약 용량은 병용 불가 | https://aws.amazon.com/blogs/aws/introducing-database-savings-plans-for-aws-databases/ · https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html · https://aws.amazon.com/blogs/database/optimize-costs-in-amazon-aurora/ |
| G-4.3-13 | `[부정확]` | `saa-t4-3.md:120,123-125,227,249,289` | "RDS RI는 **인스턴스 클래스·엔진·리전·Multi-AZ 여부**에 따라 별도 구매… **구성 속성이 하나라도 달라지면 할인이 적용되지 않는다**" → **MySQL·MariaDB·PostgreSQL·Aurora·Oracle BYOL은 사이즈 유연성**(같은 패밀리 모든 크기에 자동 적용, Single/Multi-AZ 모두)이고, 비유연은 **SQL Server·Oracle License Included**뿐(변경 시 온디맨드 요율). Q5 해설의 일반화 오류. RI는 *인스턴스 요금만* 할인(스토리지·I/O 제외) | https://aws.amazon.com/rds/faqs/ · https://aws.amazon.com/rds/mysql/pricing/ · https://aws.amazon.com/rds/postgresql/pricing/ · https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html |
| G-4.3-14 | `[의심]` | `saa-t4-3.md:76,109-118,223,268` | RDS RI 할인율 표(1년 No/Partial/All ≈25/35/40%, 3년 ≈45/55/60%, "최대 60%") → "(대략적 범위)"로 표기했으나 **근거 URL이 없고** 공식 RI 요율은 엔진·클래스·리전·Multi-AZ별 가격 페이지 값. 이번 조회에서 RDS RI 할인율 문장 미확보 → `99-gaps.md` | https://aws.amazon.com/rds/mysql/pricing/ |
| G-4.3-15 | `[구식]`·`[부정확]` | `saa-t4-3.md:81` | 시계열·IoT에 "**Amazon Timestream — 관계형 DB 대비 1/10 비용**" → **Timestream for LiveAnalytics는 2025-06-20부터 신규 고객 불가**(대안 Timestream for InfluxDB), "1/10 비용"은 공식 문장 미확보(마케팅 비교) | https://docs.aws.amazon.com/timestream/latest/developerguide/AmazonTimestreamForLiveAnalytics-availability-change.html · https://docs.aws.amazon.com/timestream/latest/developerguide/what-is-timestream.html |
| G-4.3-16 | `[구식]` | `saa-t4-3.md:13,24,39,78,165-196,236,261` | **"Aurora Serverless v2"** 명칭 → 2026-04 "**Aurora serverless**"로 개명(플랫폼 v4). 기능 서술(ACU 0.5 단위·초 단위 과금·0 ACU 자동 일시정지)은 대체로 ✓ | https://aws.amazon.com/about-aws/whats-new/2026/04/aurora-serverless-smarter-scaling/ (`3-3.md` F-07) |
| G-4.3-17 | `[내부불일치]` | `saa-t4-3.md:170-171,236-237` | 청구 방식 "유휴 시 **최솟값(0.5 ACU)만 과금**"과 "최솟값 **0 ACU(자동 일시정지)**"가 같은 표에 공존, Pitfall 2 🧠원리는 "최솟값 **아래로는 축소되지 않는다**"로 서술 → 최솟값 0 ACU 설정 시 자동 일시정지 가능(`3-3.md` F-07: 일시정지 시 Performance Insights 미수집) — 표현 정리 필요 | `3-3.md` F-07 |
| G-4.3-18 | `[의심]` | `saa-t4-3.md:186-190` | "**DynamoDB 기본 권장은 온디맨드 모드입니다.** 트래픽이 안정적이고 예측 가능한 경우에만 프로비저닝" → AWS 서술은 "예측 불가=온디맨드 모범 사례, 일관·점진 증가=프로비저닝(+자동 확장·예약 용량)"이며 *기본 권장* 문장은 미확보. 정량 기준(**프로비저닝 활용률 평균 35% 미만이면 온디맨드가 저렴**)·예약 용량 고려가 빠짐 | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CostOptimization_TableCapacityMode.html · https://repost.aws/knowledge-center/dynamodb-optimize-costs |
| G-4.3-19 | `[의심]` | `saa-t4-3.md:188` | 온디맨드↔프로비저닝 "언제든 전환 가능 (**전환 후 24시간 내 재전환 제한**)" → 이번 조회에서 해당 제약 문장 미확보(`3-3.md` F-16에도 없음) → `99-gaps.md` | https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CostOptimization_TableCapacityMode.html |
| G-4.3-20 | `[부정확]` | `saa-t4-3.md:204` | "백업 스토리지 비용: **프로비저닝 스토리지 크기까지는 무료**" → 정확한 기준은 **계정·리전 전체의 프로비저닝 DB 스토리지 합계**(일 단위로 비교해 초과분만 과금). Aurora는 *클러스터별* 총 Aurora 스토리지의 100% | https://aws.amazon.com/rds/faqs/ · https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.Retaining.html |
| G-4.3-21 | `[내부불일치]` | `saa-t4-3.md:89` vs `:94` | TCO 표의 "인스턴스 비용: 동일 수준"과 결론 행 "인스턴스 비용은 **소폭 높으나** 운영 비용 절감으로 TCO 유리"가 상충. 두 서술 모두 공식 근거 URL 없음 | (`99-gaps.md` 참조) |
| G-4.3-22 | `[의심]` | `saa-t4-3.md:206` | "Aurora는 자동으로 연속 백업(S3) — 보존 기간 설정이 비용에 직접 영향" → 확인한 공식 서술: 클러스터 총 Aurora 스토리지의 100%까지 무료이므로 *보존 기간이 짧거나 변경량이 작으면 무과금*일 수 있음("직접 영향" 일반화 주의). 교차 리전 복사 과금(`:207`)은 공식 문장 미확보 | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Managing.Backups.Retaining.html |
| G-4.3-23 | `[의심]` | `saa-t4-3.md:144` | 버스터블 db.t* "크레딧 소진 시 성능 제한" → RDS T 인스턴스 unlimited 모드 여부 등 현행 동작 미재확인(`3-2.md` F-04는 EC2 T) | (`99-gaps.md` 참조) |
| G-4.3-24 | `[의심]` | `saa-t4-3.md:99-101,123-125,157-159,193-195,212-214,237-239` (🧠원리) | 설계 이유 추정(예: RDS 스토리지 축소 불가 이유를 "블록 스토리지 레이아웃·데이터 이전 필요"로 단정 `:157-159`, Serverless v2가 0.5 ACU로 스케일 가능한 이유). 공식 근거 URL 없음 (전 문서 공통, G-1.1-13) | (`99-gaps.md` 참조) |
| G-4.3-25 | `[일치]` 참고 | `saa-t4-3.md:76-83,133-136,142,152,169-176,180-187,203,205,207,211-214` | Aurora 스토리지 10 GB 단위·256 TiB(2025 상향)/128 TiB ✓, RDS 스토리지 축소 불가 ✓, Compute Optimizer의 RDS 권고 ✓, Aurora 복제본 최대 15 ✓, ACU 0.5 단위·지원 엔진 ✓, DynamoDB RRU/WRU vs RCU/WCU·"프로비저닝은 미사용도 과금" ✓, 자동 백업 0~35일 ✓, 수동 스냅샷은 삭제 전까지 과금 ✓, 읽기 부하를 캐시/복제본으로 분산해 Primary 다운사이즈 ✓(개념) | F-01, F-08, `3-3.md` F-03·F-05·F-09·F-16 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-4.3-26 | `[중복]` | Aurora Serverless v2·ElastiCache·읽기 복제본 설명이 `saa-t3-5`(성능 관점)와 `saa-t4-3`(비용 관점)에 분산 — 상호 참조 없음. 비용 관점 핵심(요금 단위·Multi-AZ·복제본 요금)은 4.3 쪽에 비어 있음 |
| G-4.3-27 | `[중복]` | RDS Proxy는 `saa-t3-5.md:222`·`saa-t2-2.md:72`에서 *기능*만 다뤄 4.3(Knowledge 6)과 이어지지 않음(G-4.3-04) |
| G-4.3-28 | `[과잉]` | 없음 — "관리형 vs 자체 관리 TCO"(`:85-96`)는 4.3 Skill 3의 "비용 효율적 DB 서비스 결정" 범위로 볼 수 있음(근거 URL만 보강 필요) |

---

## Task 4.4 — 비용에 최적화된 네트워크 아키텍처 설계
**대응 문서**: `saa-t4-4`(전송 비용 구조·NAT·엔드포인트·CloudFront·피어링 vs TGW·Direct Connect) + `saa-t4-5`(Knowledge 1·2 공통 — `G-4.1-11`~`G-4.1-27`에서 대조 완료) — 있음. 인접: `saa-t3-7`(엣지·DNS·ELB), `saa-t3-8`(VPC·연결·엔드포인트·DX/VPN) — 성능·토폴로지 관점.

### 문서가 다루지 않은(또는 일부만 다룬) 공식 Skill/Knowledge
| ID | 구분 | 내용 | 근거 |
|---|---|---|---|
| G-4.4-01 | `[누락]` Knowledge 3 | **로드 밸런싱의 비용(ALB 등)** — `saa-t4-4.md`에 ELB 서술 없음(Grep `ALB\|NLB\|LCU` → `:147`의 CloudFront 오리진 예시 1건뿐). LCU 과금(최대 차원 하나)·ALB 통합·공용 IPv4 절감 연결·교차 영역 전송이 없음 | `4-2.md` F-17·F-18, `2-1.md` F-25 |
| G-4.4-02 | `[누락]` Knowledge 4 | **NAT 인스턴스 vs NAT 게이트웨이 비용 비교**(공식 Knowledge의 예시) — `saa-t4-4.md` Grep `NAT 인스턴스\|NAT instance` → 0건. 가용성·대역폭(100 Gbps vs 인스턴스 유형)·관리·과금 항목 비교와 "AWS는 게이트웨이 권장"이 없고, **Regional NAT gateway**도 없음 | F-06, F-07 |
| G-4.4-03 | `[누락]` Knowledge 5·Skill 2·7 | **VPN 비용·대역폭 및 DX vs VPN vs 인터넷 비교** — `saa-t4-4.md` Grep `VPN` → 0건(Direct Connect만 `:179-194`). VPN 연결-시간 요금·인터넷 DTO 요율·**가속 VPN(GA 가산)**, 터널당 1.25 Gbps·**TGW+ECMP 다중 터널**·VGW ECMP 불가, DX 속도 선택, DX 백업으로서의 VPN이 없음 | F-13~F-15 |
| G-4.4-04 | `[누락]` Knowledge 7 | **DNS 서비스(Route 53)의 비용** — `saa-t4-4.md` Grep `Route 53` → 0건. 호스티드 영역·쿼리 요금, **Alias→AWS 리소스 쿼리 무료**, **프라이빗 호스티드 영역 쿼리 무료**, Resolver 엔드포인트(IP당 시간 과금) 절감 방법이 없음 | F-18, F-19 |
| G-4.4-05 | `[누락]` Skill 6 | **적합한 제한(스로틀링) 전략** — 0건. API Gateway 토큰 버킷·사용량 계획·계정 수준 한도·429, WAF rate-based rule, 큐/스트림 버퍼링·Lambda 최대 동시성이 없음 | F-20, `2-1.md` F-17 |
| G-4.4-06 | `[누락]` Skill 5 | **기존 워크로드의 네트워크 최적화 검토 절차** — Cost Explorer/CUR 사용 유형(`DataTransfer-Regional-Bytes`)·NAT 트래픽 출처 식별(CloudWatch·Flow Logs)·Compute Optimizer **NAT 유휴 권고**·Trusted Advisor(NAT AZ 독립성)가 없음 | F-21, `4-2.md` F-13 |
| G-4.4-07 | `[누락]` Knowledge 5·Skill 3 | **공용 IPv4 요금**(2024-02-01부터 **모든 공용 IPv4 $0.005/IP/시간**) — 24개 SAA 문서에서 IPv4 요금 서술 0건(`saa-t3-7.md`·`t3-8.md`의 IPv4는 주소 체계 언급). NAT 게이트웨이 EIP·EC2 공용 IP·GA·VPN 터널 모두 해당, ELB 통합·Instance Connect Endpoint·IPv6로 절감 | F-08 |
| G-4.4-08 | `[부분]` Skill 3 | **경로 구성(Global Accelerator 포함)** — 리전 간/AZ 간/퍼블릭 경로·Gateway 엔드포인트는 다루나(`:77-125`) **Global Accelerator 요금**(가속기당 고정 $0.025/시간+DT-Premium, 비활성도 과금)과 "절감 수단이 아님"이 없음 | F-16 |
| G-4.4-09 | `[부분]` Skill 4 | **CDN·엣지 캐싱의 전략적 필요** — 캐시 히트율·오리진 전송 면제는 ✓(`:141-158`). **가격 클래스·월 1 TB 무료·Security Savings Bundle·flat-rate 요금제·Origin Shield 요금**, Lambda@Edge vs CloudFront Functions 비용이 없음 | F-17, `4-2.md` F-21 |
| G-4.4-10 | `[부분]` Knowledge 6 | **라우팅·피어링 비용** — 피어링 vs TGW 비교는 있으나(`:160-177`) **리전 간 TGW 피어링의 처리+전송 비용**, 공유 TGW의 시간 요금 부담 주체, PrivateLink 포함 3자 비교, **TGW 경유 AZ 간 전송 요금 없음**이 정확히 반영돼 있지 않음 | F-11, F-12 |
| G-4.4-11 | `[부분]` Knowledge 5·Skill 2 | **Direct Connect 총비용** — 포트 시간·DTO·인바운드 무료·손익분기 🧠원리는 ✓(`:179-194`), **ISP·크로스 커넥트·랙·장비 포함 총비용**, 위치·리전별 요율 차이(시드니 예), SiteLink, TGW 경유 처리 요금이 없음 | F-13 |

### 구식·의심·오류 사실
| ID | 분류 | 위치 | 문서 주장 → 실제(공식) | 근거 URL |
|---|---|---|---|---|
| G-4.4-12 | `[부정확]` | `saa-t4-4.md:168,208` | TGW "**교차 AZ 전송 $0.01/GB + $0.02/GB**"·시나리오표 "VPC-A→VPC-B 교차 AZ (TGW) **$0.01/GB + $0.02/GB = $0.03/GB**" → AWS 서술은 "**TGW를 통과하는 AZ 간 트래픽에는 별도의 AZ 전송(목적지) 요금이 없다**"(TGW는 시간 요금+GB당 처리 $0.02만). 피어링은 AZ 교차 시 전송 요금. 따라서 TGW=$0.02/GB(처리), 피어링 교차 AZ=$0.01/GB(각 방향) | https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html · https://aws.amazon.com/blogs/architecture/overview-of-data-transfer-costs-for-common-architectures/ · https://aws.amazon.com/transit-gateway/pricing/ |
| G-4.4-13 | `[의심]` | `saa-t4-4.md:80-82,204,207` · `saa-t4-1.md:179-180` (G-4.1-19) | 같은 AZ "퍼블릭 IP 사용 시 과금 주의"·AZ 교차 "프라이빗 IP $0.01/GB(양방향)"·"퍼블릭/EIP 경로는 과금, 프라이빗 IP는 더 낮은 요율" → 이번 조회에서 **AZ 간 각 방향 $0.01/GB**(EKS 가이드 서술)와 "같은 AZ 전송 무료"(아키텍처 블로그)는 확인했으나 **퍼블릭 IP/EIP 경로의 별도 요율은 공식 문장 미확보** → G-4.1-19를 이 항목으로 종결(미확보) | https://docs.aws.amazon.com/prescriptive-guidance/latest/eks-cost-optimization/network-cost-reduction.html · https://aws.amazon.com/blogs/architecture/overview-of-data-transfer-costs-for-common-architectures/ |
| G-4.4-14 | `[의심]` | `saa-t4-4.md:83,186,205` | AWS→인터넷 "**$0.09/GB 수준(첫 10 TB)**"·월 100 GB 무료 → **100 GB 무료(전 서비스·리전 합산)**는 ✓. $0.09/GB는 직접 인용 미확보(예: 시드니 리전 인터넷 $0.114/GB<10 TB — 리전별 상이). 구조(계층·집계 서비스 목록)가 시험 관점 | https://aws.amazon.com/ec2/pricing/on-demand/ · https://aws.amazon.com/blogs/networking-and-content-delivery/aws-network-optimization-tips/ |
| G-4.4-15 | `[의심]` | `saa-t4-4.md:186-189,241-242` | Direct Connect "아웃바운드 **$0.02/GB 수준**… **인터넷의 약 1/4**"·"포트 시간 **$0.30/시간(1 Gbps)**" → DX DTO **$0.02/GB는 공식 문서의 '예시'(미국 위치)**일 뿐이고 위치·리전별로 다름(시드니: 인터넷 $0.114 vs DX $0.0420 ≈ 37%). "약 1/4"은 미국 예시 한정 비율, 포트 시간 요율은 직접 인용 미확보 | https://docs.aws.amazon.com/directconnect/latest/PricingGuide/pricing-overview.html · https://aws.amazon.com/blogs/networking-and-content-delivery/aws-network-optimization-tips/ |
| G-4.4-16 | `[부정확]` | `saa-t4-4.md:132-134` | Interface Endpoint "**$0.01/GB + 시간당 ENI 요금**" → 시간 요금은 *엔드포인트·AZ별*(상태가 pending이어도 과금)이고 ENI별 요금이 아님. 처리 요금 계층(첫 1 PB $0.01·다음 4 PB $0.006·5 PB 초과 $0.004)·"200+ 서비스"는 문서의 계층 서술 ✓/서비스 수는 미확인 | https://aws.amazon.com/privatelink/pricing/ · https://docs.aws.amazon.com/prescriptive-guidance/latest/integrate-third-party-services/architecture-1.html |
| G-4.4-17 | `[구식]` | `saa-t4-4.md:96-125,226-227` | NAT 절감 설명이 **공용 IPv4 요금($0.005/IP/시간, 2024-02-01)** 을 반영하지 않음(NAT 시간 요금 외에 NAT EIP 요금, 퍼블릭 서브넷 인스턴스↔NAT 이전의 손익 계산식) | https://aws.amazon.com/blogs/aws/new-aws-public-ipv4-address-charge-public-ip-insights/ · https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html |
| G-4.4-18 | `[의심]` | `saa-t4-4.md:149` | "사용자에게 나가는 엣지→인터넷 전송은 발생하지만 **EC2 직접 서빙 단가보다 CloudFront 단가가 낮다**" → 확인한 사실은 월 **1 TB 무료 DTO**와 AWS 오리진→CloudFront 무료, 계층 요금. 단가 비교 문장은 미확보 | https://aws.amazon.com/blogs/networking-and-content-delivery/aws-network-optimization-tips/ |
| G-4.4-19 | `[의심]` | `saa-t4-4.md:119-120,132` | Gateway/Interface 엔드포인트 서술 — Gateway의 "VPC 경계 확장 불가(피어링·VPN·DX 경유 불가)"가 빠짐(온프레미스에서 S3 접근 시 Gateway 불가→Interface 필요). "S3·DynamoDB 같은 리전 전송 무료"에서 DynamoDB 근거 미확보 | https://docs.aws.amazon.com/eks/latest/best-practices/cost-opt-networking.html |
| G-4.4-20 | `[의심]` | `saa-t4-4.md:91-94,122-125,136-139,155-158,174-177,191-194` (🧠원리) | 설계 이유 추정(예: Multi-AZ가 가용성과 전송 비용을 동시에 높이는 이유, DX 도입이 항상 절감이 아닌 이유 `:191-194`의 결론은 공식 "손익분기 계산" 서술과 방향이 같음). 공식 근거 URL 없음 (전 문서 공통, G-1.1-13) | (`99-gaps.md` 참조) |
| G-4.4-21 | `[일치]` 참고 | `saa-t4-4.md:79-83,100-118,129-132,147-148,164-172,183-189,214-220,229-230` | 인바운드 무료 ✓, 같은 AZ 무료·AZ 교차 과금 ✓, NAT 시간+GB 처리·같은 AZ/AZ별 NAT·Gateway 엔드포인트 우회 ✓(예시 $0.045/시간·$0.045/GB는 US East 오하이오 예시와 일치), Gateway 엔드포인트 무료 ✓, Interface 처리 요금 계층 ✓, CloudFront↔AWS 오리진 전송 무료 ✓, 피어링 고정·처리 요금 없음·TGW 첨부 시간+$0.02/GB ✓(예시 $0.05/첨부·시간), DX 인바운드 무료 ✓, RDS Multi-AZ 복제 무료·앱↔DB 교차 AZ 과금(Pitfall 2) ✓ | F-02, F-04, F-05, F-10~F-13 |

### 중복·과잉
| ID | 분류 | 내용 |
|---|---|---|
| G-4.4-22 | `[중복]` | VPC 피어링 vs TGW(N(N−1)/2 연결)·엔드포인트·DX가 `saa-t3-8`(토폴로지 관점)과 `saa-t4-4`(비용 관점)에 분산되고 상호 참조가 없음. TGW 수치는 4.4 쪽에만 있어 불일치 위험은 낮으나 G-4.4-12처럼 한쪽에서 오류가 생기면 전파 경로가 없음 |
| G-4.4-23 | `[중복]` | `saa-t4-1.md:172-206`의 데이터 전송 표와 `saa-t4-4.md:73-85`의 표가 중복(G-4.1-32에서 예고) — 4.1 쪽에는 AZ 간 요율 서술이 있어 4.4와 어긋날 여지(G-4.1-19, G-4.4-13) |
| G-4.4-24 | `[과잉]` | 없음 — 다만 Task 4.4 Knowledge/Skill에서 비중이 큰 VPN·DNS·스로틀링·ALB가 비어 있고 DX·피어링·TGW 비중이 큼(구성 불균형, G-4.4-01~05) |
