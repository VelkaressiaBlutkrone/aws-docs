# 94 — 사전 서명 URL · PrivateLink (C03 신설 잔여)

> **원자료 노트(저작 재료)** · 조회일 **2026-11-01**. 사실마다 URL을 붙였고, 확인하지 못한 것은 `## 확인 필요`에 남겼다.

| 항목 | 위치 | 성격 |
|---|---|---|
| **Skill 2.1.4** | Task 2.1 인증·인가 | 🆕 C03 신설 — 사전 서명 URL로 **시간 제한 안전 액세스**(S3 · CloudFront) |
| **AWS PrivateLink** | in-scope 신규 서비스 | Skill 2.3.2 예시로 등장. Bedrock 쪽 적용은 [`tasks/2-3.md`](tasks/2-3.md) §2 |

---

## 1. S3 사전 서명 URL — 만료는 **자격 증명이 먼저 정한다** (2.1.4)

누구든 유효한 보안 자격 증명이 있으면 사전 서명 URL을 만들 수 있지만, **그 URL이 실제로 통하려면 만든 사람이 그 작업을 수행할 권한을 가지고 있어야 한다.**

| 만든 자격 증명 | 유효 한도 |
|---|---|
| **IAM 사용자**(SigV4) | **최대 7일** |
| **임시 보안 자격 증명** | **자격 증명 자체보다 길 수 없다** |
| └ IAM 역할 자격 증명 | **역할 세션이 끝나면 URL도 끝난다** — 더 긴 만료를 지정해도 그렇다 |
| └ EC2 인스턴스가 쓰는 역할 자격 증명 | 역할 자격 증명 기간 동안(**보통 6시간**) |
| └ STS 자격 증명 | 임시 자격 증명 기간 동안만 |

> ⭐ **가장 많이 틀릴 지점**: *"URL 만료를 7일로 줬는데 왜 일찍 끊기나?"* → **임시 자격 증명으로 만들었기 때문**이다. 그리고 **URL을 만든 자격 증명이 취소·삭제·비활성화되면 URL도 그 시점에 죽는다** — 더 늦은 만료를 지정했어도 마찬가지다.

- **콘솔**로 만들면 만료를 **1분~12시간** 범위에서 정한다. **CLI·SDK**로 만들면 **최대 7일**까지 줄 수 있다.
- 만료 후 접근하면 `AccessDenied` / `Request has expired`가 돌아온다(응답에 `Expires`·`ServerTime`이 들어 있다).

## 2. CloudFront 서명 URL·서명 쿠키 (2.1.4)

S3 사전 서명 URL과 **메커니즘이 다르다.** 섞으면 안 된다.

- **서명 URL** — 암호화 서명을 URL에 심어 **개별 파일**에 임시 접근을 준다.
- **서명 쿠키** — **경로 아래 여러 파일**에 접근을 준다. 더 넓은 범위의 접근 제어에 쓴다.
- 둘 다 **서명자(signer)**가 필요하다. 서명자는 **CloudFront에서 만드는 신뢰할 수 있는 키 그룹(trusted key group, 권장)** 또는 CloudFront 키 페어를 가진 AWS 계정이다.
- 서명자의 두 가지 역할: ① **배포에 서명자를 추가하는 순간** CloudFront가 그 뒤로 서명 URL·쿠키를 **요구하기 시작**한다 ② 서명자의 **개인 키**로 URL·쿠키 일부를 서명하고, CloudFront가 서명을 대조해 **변조되지 않았는지**와 **만료가 지나지 않았는지**를 확인한다.
- 어떤 파일에 요구할지는 **캐시 동작(cache behavior)에 서명자를 붙여** 간접 지정한다. 캐시 동작이 하나뿐이면 배포 전체에 적용되고, 여러 개면 일부에만 걸 수 있다.

| | S3 사전 서명 URL | CloudFront 서명 URL·쿠키 |
|---|---|---|
| 서명 재료 | **호출자의 AWS 자격 증명** | **키 그룹의 개인 키** |
| 만료 상한 | 자격 증명이 정함(최대 7일) | 서명에 넣은 만료 |
| 범위 | 객체 1개 작업 | URL=파일 1개 / 쿠키=경로 아래 다수 |
| 적용 지점 | 요청 | **캐시 동작** |

## 3. PrivateLink — 이 가이드에서의 위치

C03 **in-scope 신규**다(Networking and Content Delivery). Skill **2.3.2**가 "VPC 엔드포인트를 사용하여 프라이빗 연결을 설정"을 예시로 들며, Bedrock 적용 상세는 [`tasks/2-3.md`](tasks/2-3.md) §2에 적었다 — 인터페이스 엔드포인트, 서브넷마다 생기는 엔드포인트 네트워크 인터페이스, 퍼블릭 IP 불필요, `com.amazonaws.<region>.bedrock-runtime`, 엔드포인트 정책으로 최소 권한.

⚠️ **다른 Task에서도 걸릴 수 있다** — C02 노트에 인접 언급이 둘 있다: `4-2.md`(인터페이스 엔드포인트로 X-Ray 전송) · `1-2.md`(Lambda 함수 URL은 PrivateLink 미지원). Phase 3에서 해당 Task 학습문서에 합류시킨다.

⭐ **2.3.1과 맞물리는 사실**(2-3 노트에서 가져옴): **VPC 엔드포인트를 통한 요청에는 `aws:SourceIp`가 없다.** IAM 정책에 `IpAddress` 조건을 걸어 두면 그 조건은 충족될 수 없다.

## 4. 시험에서 묻는 방식

- "7일짜리 다운로드 링크를 주려면?" → **IAM 사용자 자격 증명 + SigV4 + CLI/SDK**. 역할 자격 증명으로는 세션 길이를 못 넘는다
- "콘솔로 만들었더니 12시간이 최대다" → 콘솔 상한이 **1분~12시간**
- "링크를 뿌린 뒤 즉시 무효화하려면?" → 만든 **자격 증명을 취소·비활성화**한다
- "경로 아래 수십 개 파일을 한 번에 보호하려면?" → **CloudFront 서명 쿠키**
- "일부 경로만 서명을 요구하려면?" → **캐시 동작**별로 서명자를 붙인다

## 5. 흔한 함정·혼동 짝

| 혼동 | 가르는 기준 |
|---|---|
| S3 사전 서명 vs CloudFront 서명 | **호출자 자격 증명**으로 서명 vs **키 그룹 개인 키**로 서명 |
| 서명 URL vs 서명 쿠키 | 파일 **1개** vs 경로 아래 **여러 개** |
| 지정한 만료 vs 실제 만료 | **자격 증명이 먼저 끝나면 거기서 끝난다** |
| 콘솔 12시간 vs SDK 7일 | 만드는 **경로**에 따라 상한이 다르다 |

## 6. 출처 목록

조회일 전부 **2026-11-01**.

1. S3 사전 서명 URL(만들 수 있는 자격 증명·유효 기간) — https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-presigned-url.html
2. (AWS 지식 센터) `Request has expired` 문제 해결 — 콘솔 1분~12시간, CLI·SDK 최대 7일 — https://repost.aws/knowledge-center/request-has-expired-s3-object
3. CloudFront 서명자 지정(신뢰할 수 있는 키 그룹) — https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html
4. (AWS 지식 센터) CloudFront 콘텐츠 접근 제어 — 서명 URL vs 서명 쿠키 — https://repost.aws/knowledge-center/cloudfront-content-restriction
5. Bedrock 인터페이스 VPC 엔드포인트 — https://docs.aws.amazon.com/bedrock/latest/userguide/vpc-interface-endpoints.html

## 확인 필요

- **"IAM 인스턴스 프로파일 6시간 / STS 36시간"이라는 수치는 S3 on Outposts 문서의 것이다.** 표준 S3 페이지는 "EC2가 쓰는 역할 자격 증명은 보통 6시간"까지만 적는다 — **Outposts 수치를 표준 S3에 옮겨 쓰지 않는다.** 표준 S3 기준의 인스턴스 프로파일·STS 상한을 따로 확인해야 한다.
- **CloudFront 서명 URL의 만료 상한**을 공식 수치로 확인하지 못했다(S3의 7일 같은 상한이 있는지).
- **키 페어 교체(rotating key pairs) 절차**는 목차만 확인했고 본문을 읽지 못했다.
