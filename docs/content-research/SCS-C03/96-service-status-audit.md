# SCS-C03 — 범위 내 71개 서비스 상태 전수 확인 (P-01 / G-06)

> **작성 2026-11-08.** [99-gaps.md](99-gaps.md) **G-06**과 [98-authoring-decisions.md](98-authoring-decisions.md) **P-01**을 닫는 실측 노트다.
> 범위 목록의 정본은 [00-overview.md](00-overview.md) §6, 닫힌 서비스 판정의 정본은 **99-gaps G-02**, 저작 처리의 정본은 **98 D-04**다.
> 이 노트는 **측정 기록**이고, 저작 시 인용할 URL과 상태 문구를 함께 남긴다.

## 1. 결론

| 물음 | 답 |
|---|---|
| 범위 내 71개 중 **서비스 자체**가 닫힌 것 | **5개** — G-02의 다섯과 **정확히 같다**. 전수 확인에서 신규 추가 **0건** |
| 범위 내 서비스의 **기능·에디션**이 닫힌 것 | **신규 발견 — 15개 서비스에 걸쳐 28개 항목**(§7). G-02·D-04에 **없던 것**이다 |
| 문서를 읽을 수 없는 서비스 | **1개**(`Amazon CodeGuru Security` — `404 r=0`) |
| 내가 추측한 문서 URL이 틀렸던 것 | **4개**(§5). **저작 전에 고치지 않으면 엉뚱한 페이지를 인용한다** |

⚠️⚠️ **이 전수 확인의 가치는 「다섯이 그대로였다」가 아니라 「기능 단위가 28개였다」에 있다.** G-02는 **서비스 단위**로만 봤고, 실제 출제 소재는 기능 단위다 — `Systems Manager Incident Manager`(인시던트 대응)·`SNS 메시지 데이터 보호`(신규 `기술 5.3.4`)·`ARC 준비 상태 확인`·`Directory Service Simple AD`처럼 **SCS 도메인의 중심 소재가 유지 관리 상태**다.

## 2. 측정 방법

G-06이 지시한 두 방법을 모두 썼고, **둘이 서로를 교정했다.**

| | 방법 | 범위 |
|---|---|---|
| **1차** | 서비스별 `what-is`/`welcome` 문서를 `curl -sL`로 받아 상태 문구 탐침 + `http_code`·`num_redirects`·바이트 수 기록 | 내가 만든 71개 URL 목록 |
| **2차** | **공식 `AWS Lifecycle Changes` 페이지**(§6) — 내 URL 목록과 **무관한 독립 열거** | AWS 전체 134개 항목 |

⚠️ **1차만으로는 틀렸다.** 1차는 기능 단위를 거의 잡지 못했다(기능의 공지는 **그 기능 페이지**에 있고 서비스 what-is에는 없다). 2차가 28개를 가져왔다.
⚠️ **2차만으로도 틀렸다.** `CodeGuru Security`는 **세 목록 어디에도 없는데 문서가 404**다(§8). 1차만이 그것을 봤다.

### 대조군 4종 (전부 실측)

| 대조군 | 측정값 | 쓰임 |
|---|---|---|
| **C1** 살아 있는 가이드의 **틀린 슬러그** (`kms/…/zz-bogus-page-does-not-exist.html`) | `200 r=1` → 그 가이드 **인덱스**(2,368바이트) | 「페이지 없음」 신호 |
| **C2** **없는 가이드 접두사** (`zz-bogus-service/latest/userguide/what-is.html`) | **`404 r=0`**(1,711바이트) | 「가이드 자체가 없음」 신호 |
| **C3** 가이드 **루트 인덱스** (`kms/latest/developerguide/`) | `200 r=0`(2,368바이트) | C1의 도착지가 인덱스임을 확인 |
| **C4** **알려진 양성** — `AWS CloudTrail Lake`(이미 닫힌 것을 안다) | §3 참조 | **탐지기 민감도** |

⭐ **C1·C2·C3이 AIF G-50의 「세 갈래 신호」를 이 가이드 계열에서 재현했다** — `num_redirects`만 보면 「이름 변경」과 「가이드 소멸」이 갈리지 않고, **상태 코드와 도착지를 함께** 봐야 한다.
⚠️ **바이트 수가 네 번째 신호다.** 인덱스로 튕긴 페이지는 **2,2xx~2,5xx바이트**로 수렴한다(C1 2,368 · C3 2,368 · 미해결 3건 2,443~2,478). **본문이 있는 페이지는 11,946바이트 이상**이었다. 즉 **「`200 r=1`이고 2.5KB 이하」면 측정이 공허하다** — 그 상태로 「문구 0건 = 깨끗함」이라고 적으면 거짓이다.

## 3. ⚠️⚠️⚠️ 탐지기가 두 번 뚫렸고, 둘 다 「문제 없음」처럼 보였다

이 배치에서 가장 값진 것은 결과가 아니라 **탐지기가 조용히 실패하는 두 방식**이다.

### 3-1. 어형 한 낱말 — 「`be`」

1차 탐지기는 G-06이 적은 고정 문구 `no longer open to new customers`를 썼다. **알려진 양성인 `AWS CloudTrail Lake`가 0건으로 나왔다.**

실제 공지문은 이렇다(`awscloudtrail/latest/userguide/cloudtrail-lake.html`, 실측):

> `AWS CloudTrail Lake will no longer **be** open to new customers starting May 31, 2026. If you would like to use CloudTrail Lake, sign up prior to that date. Existing customers can continue to use the service as normal.`

**`no longer` 와 `open` 사이에 `be` 한 낱말**이 들어가 고정 문구가 비켜 갔다.

⚠️⚠️ **이것은 이 레포가 세 번 밟은 함정과 같은 것이다** — AIF 「PT 필수」가 `프로비저닝 처리량` ↔ **`프로비저닝된 처리량`**(「된」 한 글자)으로 전수 가드를 **초록으로** 통과했다(HANDOFF §0-2026-11-06-d). **상태 문구는 어형이 갈리므로 정규식으로 센다.**
→ 2차 탐지기는 `no longer (be )?(open|available) to new customers|not open to new customers|closed to new customers|new customers` 로 넓혔고, **그때 C4가 걸렸다.** 민감도를 확인하기 **전의 0건은 결과가 아니다.**

### 3-2. 이 환경의 `grep -iF`가 **SIGABRT로 죽는다**

lifecycle 목록과 SCS 71개를 대조하는 루프가 **71개 전부 「0건 일치」**를 돌려줬다. 「걸리는 것이 없다 = 문제 없음」으로 읽히는 모양이다.

원인은 데이터가 아니라 도구였다:

```
$ grep -icF "AWS Audit Manager" lc_all.txt
Aborted                 grep -icF "AWS Audit Manager" lc_all.txt
rc=134
$ grep -c -i 'Audit Manager' lc_all.txt      # -F 를 뺀 대조군
1
```

`-i`와 `-F`를 함께 주면 이 파일(en dash `–` 포함)에서 **grep이 중단된다.** 루프 안에서는 stderr가 묻혀 **빈 문자열**이 되고, 빈 문자열은 「0건」처럼 보인다.
→ 매칭을 **awk `index(tolower(…))`** 로 바꿨고, **알려진 양성을 먼저 단정**한 뒤 전수를 돌렸다.
⚠️ 메모리 `repo-toolchain-gotchas`의 **「이 환경의 `grep -P`는 실패해 0건을 돌려준다」와 같은 계열**이고, 이쪽은 **0을 돌려주는 대신 죽는다**(그래서 파이프 안에서 더 조용하다).

### 3-3. 또 하나 — `grep -c`는 0건에서 **exit 1**이다

1차 스크립트가 `c=$(grep -ioc X "$f" || echo 0)` 로 썼더니 **grep이 이미 찍은 `0` 뒤에 `echo 0`이 한 번 더** 찍혀 `c`가 두 줄이 되고 **TSV가 깨졌다**(필드가 밀려 전 행이 무의미해졌다). → `c=$(grep -ic X "$f" | head -1); c=${c:-0}`.

⭐ **세 함정의 공통점:** 전부 **「0」 또는 「빈 값」**으로 나타나고, 전부 **「깨끗함」으로 읽힌다.** 그래서 **알려진 양성 대조군 없이 전수 측정을 신뢰하면 안 된다.**

## 4. 1차 결과 — 71개 what-is 전수

측정 대상 **78 URL** = 범위 내 71 + 괄호 하위 항목 4 + 대조군 3.

| 판정 | 수 |
|---|---|
| `200 r=0` (본문 정상) | **70** / 71 |
| `404 r=0` (문서 없음 — C2와 같은 신호) | **1** (`Amazon CodeGuru Security`) |

> ⚠️ 위 70은 **§5의 URL 정정 4건을 반영한 뒤**의 수다. 정정 전에는 66이었고 **4건이 공허한 측정**이었다.

상태 문구가 걸린 것은 **7건**이고 그중 **서비스 상태는 4건**이다.

| 서비스 | 탐침 | 판정 |
|---|---|---|
| `Amazon Q Business` | `no longer open to new customers` | ✅ **서비스 상태** — 대안 `Amazon Quick` |
| `AWS Audit Manager` | `no longer open to new customers` | ✅ **서비스 상태** |
| `Amazon Q Developer` | `discontinue` · `end of support` | ✅ **IDE 플러그인만** — 콘솔 대화 경험은 이제 **`AWS assistant`** |
| `AWS CloudTrail Lake` | (2차 탐지기에서) `no longer be open to new customers` | ✅ **서비스 상태** — §3-1 |
| `Amazon OpenSearch Service` | `end of support` ×2 | ❌ **거짓 양성** — **엔진 버전**(Elasticsearch·OpenSearch) 지원 종료 일정표다. 서비스는 정상 |
| `Amazon S3` | `deprecated` | ❌ **거짓 양성** — **SOAP API over HTTP**가 deprecated이고 **HTTPS로는 계속 쓸 수 있다**. 서비스는 정상 |
| `AWS Trusted Advisor` | `discontinue` · `end of support` ×2 | ⚠️ **서비스가 아니라 Support 플랜** — §9-2 |

## 5. ⚠️ 내가 추측한 문서 URL 4건이 틀렸다 (저작 전 필수 정정)

**「`200`이면 맞는 URL」이 아니다** — 틀린 슬러그도 `200`을 받는다(C1).

| # | 서비스 | 내가 쓴 URL | 측정 | **정본** |
|---|---|---|---|---|
| 32 | AWS Well-Architected Tool | `wellarchitected/latest/userguide/intro.html` | `200 r=1` → 인덱스(2,459B) | **`wellarchitected/latest/userguide/tool.html`**(`200 r=0`, 14,822B) |
| 51 | 자동 포렌식 오케스트레이터 | `solutions/latest/automated-forensics-orchestrator-for-amazon-ec2/solution-overview.html` | `200 r=1` → 인덱스(2,443B) | **`…/architecture-overview.html`**(`200 r=0`, 17,841B) · 가이드 랜딩은 **`solutions/automated-forensics-orchestrator-for-amazon-ec2/`**(`/latest/` 없음, `200 r=0`, 37,080B) |
| 65 | AWS STS | `STS/latest/APIReference/welcome.html` | `200 r=1` → 인덱스(2,478B) | **죽은 슬러그다.** 개념 정본 **`IAM/latest/UserGuide/id_credentials_temp.html`**(27,471B) · API 목록 **`STS/latest/APIReference/API_Operations.html`**(12,216B) |
| 10 | Amazon Data Lifecycle Manager | `AWSEC2/latest/UserGuide/snapshot-lifecycle.html` | `200 r=1` → **특정 페이지**(13,826B) | **가이드 이동** — `ebs/latest/userguide/snapshot-lifecycle.html` |

⭐⭐ **이 측정이 기존 가드를 독립 검증했다 — 네 건 중 셋이 이미 `source_url_retired_test.dart`에 있었다.** `wellarchitected/…/intro.html`(2026-11-06 CLF·DVA 배치) · `AWSEC2/…/snapshot-lifecycle.html`(2026-11-06 SOA P2 배치) · `snowball/…/whatissnowball.html`(CLF·DVA 배치)이 그렇다. **다른 트랙의 실측과 이 트랙의 실측이 같은 결론에 닿았다** — 내가 「새로 찾았다」고 쓸 자리가 아니었고, 레포는 이미 알고 있었다. **신규는 `STS/…/welcome.html` 하나와 §8의 `CodeGuru Security`, #51의 `solution-overview.html` 셋**이고 가드에 더했다.

⚠️⚠️ **`STS/…/APIReference/welcome.html`은 특히 위험하다** — **살아 있는 `repost.aws` 문서가 지금도 그 URL을 링크한다.** 3자 페이지에서 URL을 베끼면 죽은 슬러그를 인용한다.
⚠️ **#10은 「소멸」이 아니라 「가이드 이동」이다** — 도착지가 인덱스가 아니라 **본문이 있는 특정 페이지**다(C1과 신호가 다르다). EBS 문서는 **양방향으로 움직였다**(2026-10-29 감사는 `ebs/…` → `AWSEC2/…` 방향을 고쳤고 이것은 반대 방향 — **「EBS 문서는 한쪽으로 옮겨졌다」는 일반화가 틀린다**).
⚠️ **#51은 이름도 달라졌다** — 공식 문서 제목이 **`Guidance for Automated Forensics Orchestrator for Amazon EC2 and EKS`**로 **EKS가 추가**됐다. 공식 가이드는 아직 `Amazon EC2용 자동 포렌식 오케스트레이터`로 적는다(99-gaps **G-07**).
✅ **이 네 URL은 레포 콘텐츠에 0건**이다(`assets/content`·`assets/exam_guides` 전수) — 고칠 기존 콘텐츠는 없고 **예방 가드만** 둔다(신규 3건, `source_url_retired_test.dart`).

## 6. 2차 방법 — 공식 `AWS Lifecycle Changes`

⭐ **`https://aws.amazon.com/products/lifecycle/` 가 `docs.aws.amazon.com/general/latest/gr/service-lifecycle.html` 로 리다이렉트된다**(`200 r=1`) — 즉 **AWS Product Lifecycle 페이지의 현재 정본은 docs 쪽**이다.

그 페이지가 수명 주기 상태를 **세 단계로 정의**한다(공식 문구):

| 단계 | 공식 정의의 핵심 |
|---|---|
| **Maintenance** | `Customers can't on-board to these services and features.` 기존 고객은 계속 쓰고, AWS는 **운영·지원은 하되 기능을 더하지 않는다** |
| **Sunset** | 기존 고객은 **이전을 계획해야 한다.** 일몰 시한은 **보통 12개월**이고, **일몰일은 AWS가 운영·지원을 끝내는 날**이다 |
| **Full Shutdown** | **포트폴리오에서 완전히 제거**되어 어떤 형태로도 제공·지원되지 않는다 |

자식 페이지 셋이 **항목별 표**를 싣는다(전부 `200 r=0` 실측).

| 페이지 | 항목 수 | 표의 열 |
|---|---|---|
| `maintenance_services.html` | **56** | 서비스 · **공지일** · 자료 |
| `sunset_services.html` | **16** | 서비스 · **공지일** · **지원 종료일** · 자료 |
| `full_shutdown_services.html` | **62** | 서비스 · **지원 종료일** |
| | **합계 134** | |

> 대조군: 내가 추측한 네 번째 슬러그 `shutdown_services.html`은 **`200 r=1` → 인덱스**다(C1 신호) — 세 페이지가 전부인 것이 확인된다.

⚠️⚠️ **Maintenance·Sunset 표의 날짜는 「공지일(Announcement Date)」이고 발효일이 아니다.** `AWS CloudTrail Lake`가 그것을 실증한다 — **lifecycle 표의 공지일은 2026-03-31**인데 **서비스 문서의 신규 차단 개시일은 2026-05-31**이다(§3-1 인용문). `AWS Audit Manager`도 lifecycle 공지일 **2026-03-31** ↔ AIF 트랙이 실측한 신규 계정 설정 불가 **2026-04-30**로 갈린다.
→ **공지일을 차단일로 적지 않는다.** 날짜를 쓸 때는 **그 서비스 전용 가용성 변경 페이지**를 본다.

## 7. SCS 71개 × lifecycle 134항목 교차 대조 — **20개 서비스가 걸린다**

### 7-1. 서비스 **자체**가 닫힌 것 — D-04 대상(변동 없음)

| 서비스 | 단계 | lifecycle 공지일 | 비고 |
|---|---|---|---|
| `AWS Audit Manager` | **Maintenance** | 2026-03-31 | ⚠️ AIF에서는 **범위 밖**, SCS에서는 **범위 내**(99-gaps G-12) |
| `Amazon Q Business` | **Maintenance** | 2026-06-30 | 대안 `Amazon Quick` |
| `AWS CloudTrail – Lake` | **Maintenance** | 2026-03-31 | 차단 개시 **2026-05-31** · 추적·Insights·집계 이벤트는 영향 없음 |
| `Amazon Q Developer IDE plugins` | **Sunset** | 2026-04-30 | **지원 종료 2027-04-30** · 대안 `Kiro` · 서비스 전체가 아니다 |
| `Amazon CodeGuru Security` | — (**목록에 없다**) | — | 문서 `404` — §8 |

### 7-2. ⚠️⚠️ **신규 발견 — 기능·에디션 단위 28항목**

범위 내 서비스는 살아 있는데 **그 기능·에디션**이 닫힌 것이다. **G-02·D-04에 없던 축이다.**

| 범위 내 서비스 | 닫힌 항목 (단계 / 날짜) |
|---|---|
| `Amazon SageMaker AI` | **A2I** · **Clarify** · **Debugger** · **GeoSpatial** · **Ground Truth** · **Model Monitor** · **Role Manager** · **Studio Lab** (전부 **MAINT** 2026-06-30) · **Profiler**(**SUNSET** 공지 2026-06-30 → 종료 2027-06-30) · **Ground Truth Plus**(**SHUTDOWN** 2026-06-30) — **10항목** |
| `AWS Systems Manager` | **Change Manager**(MAINT 2025-11-07) · **Incident Manager**(MAINT 2025-11-07) · **Application Manager**(MAINT 2026-06-30) |
| `Amazon S3` | **S3 Select**(MAINT 2024-07-25) · **Glacier Select**(2024-07-25) · **Glacier Direct**(2025-10-07) · **Object Lambda**(MAINT 2025-11-07) |
| `Amazon SNS` | **메시지 데이터 보호(MDP)**(MAINT 2026-03-31) |
| `Amazon Application Recovery Controller` | **준비 상태 확인(Readiness Check)**(MAINT 2026-03-31) |
| `AWS Directory Service` | **Simple AD**(MAINT 2026-06-30) |
| `AWS Service Catalog` | **AppRegistry**(MAINT 2026-06-30) |
| `Amazon Cognito` | **Cognito Sync**(MAINT 2026-06-30) |
| `Amazon Bedrock` | **Agents Classic**(MAINT 2026-06-30) |
| `AWS WAF` | **WAF Classic**(**SHUTDOWN** 2026-10-07) |
| `Amazon Inspector` | **Inspector Classic**(**SHUTDOWN** 2026-05-20) |
| `Amazon CloudWatch` | **Evidently**(**SHUTDOWN** 2025-10-17) |
| `AWS Backup` | **Backup Storage Service**(**SHUTDOWN** 2024-06-12) |
| `AWS DataSync` | **DataSync Discovery**(**SHUTDOWN** 2025-05-20) |
| `AWS Direct Connect` | **선전(Shenzhen) 리전**(SUNSET 공지 2026-06-30 → 종료 2027-06-30) |
| (기술·개념) `AWS Management Console` | **myApplications**(MAINT 2026-06-30) |

⚠️⚠️ **SCS 저작에 직접 걸리는 셋**

1. **`SNS 메시지 데이터 보호`가 유지 관리다** — **공식 신규 `기술 5.3.4`(민감한 데이터 마스킹)가 예시로 드는 바로 그 기능**이다(00-overview §10). **가이드가 갓 추가한 목표가 유지 관리 기능을 인용한다.** 다른 한 예시인 **CloudWatch Logs 데이터 보호 정책은 정상**이므로, 저작은 **그쪽을 축으로** 삼고 SNS MDP는 **상태를 적어** 다룬다.
2. **`Systems Manager Incident Manager`가 유지 관리다** — SCS **도메인 2(인시던트 대응, 14%)**의 가장 자연스러운 소재다. 모르고 쓰면 **「지금 이것을 쓰라」**가 된다.
3. **`WAF Classic`이 완전 종료**(2026-10-07)이고 **`Inspector Classic`도 완전 종료**(2026-05-20)다. 「Classic vs 현행」 대비를 출제 소재로 쓰면 **없는 것과 비교**하게 된다.

⭐ **SAA 트랙과 이어지는 자리** — 2026-10-30 갭 배치 B11이 「ARC 공식 기능은 **5종**이고 조사 노트 F-17에 `readiness check`가 빠져 있었다」를 실측해 넣었다. **그 기능이 지금 유지 관리다.**

### 7-3. 거짓 양성 (문맥이 다른 것)

| 걸린 서비스 | 실제 항목 | 왜 대상이 아닌가 |
|---|---|---|
| `Amazon OpenSearch Service` | `Amazon CloudSearch` 전환 안내 | CloudSearch가 유지 관리이고 **OpenSearch는 그 대안**이다 |
| `AWS CloudTrail` | `AWS CloudTrail – Lake` | Lake는 **별 항목**이라 §7-1에 귀속 |

## 8. ⚠️⚠️ `CodeGuru Security`는 공식 lifecycle 목록에도 **없다**

- 문서: `codeguru/latest/security-ug/what-is-codeguru-security.html` → **`404 r=0`**(C2와 같은 신호 = **가이드 자체가 없다**)
- lifecycle 세 목록: **0건**. 대조군으로 **`Amazon CodeGuru Reviewer`는 Maintenance에 있다**(공지 2025-10-07) — 즉 **목록이 CodeGuru 계열을 다루기는 한다.**

→ **「공식 lifecycle 목록에 없다」가 「살아 있다」를 뜻하지 않는다.** AIF G-10의 규율(「목록에 없다 ≠ 범위 밖」)이 **이 새 출처에도 그대로 적용된다.** 2차 방법도 완전하지 않다.
→ **D-04의 판정은 유지한다** — 지원 종료 사실만 적고 기능 서술은 하지 않으며, 문항에는 **정답·오답 어느 쪽으로도 쓰지 않는다.**

## 9. ⚠️⚠️ 공식 내부 어긋남 2건 (둘 다 「더 구체적인 쪽」을 정본으로)

### 9-1. `AWS Snowball Edge` — 집계표는 「완전 종료」, 서비스 문서는 「신규 고객 차단」

| 출처 | 적는 것 |
|---|---|
| lifecycle **집계표**(`full_shutdown_services.html`) | **Full Shutdown · 지원 종료일 2025-11-12** |
| 서비스 **전용** 페이지(`snowball/latest/developer-guide/snowball-edge-availability-change.html`, `200 r=0`) | `AWS Snowball Edge is no longer available to new customers.` · `With this change, AWS will no longer offer any AWS Snow Family devices for new customers to order.` · `This change will not impact customers currently using AWS Snowball Edge…` · `AWS continues to invest in security and availability improvements for AWS Snowball Edge devices.` |

**전용 페이지에는 `end of support`·`shut down`·`November 12`·`2025`가 전부 0건이다**(네 낱말 개별 실측). 즉 전용 페이지는 **유지 관리 어법**만 쓰고 **종료를 말하지 않으며, 기존 고객에게 계속 투자한다고 적는다.**

→ **더 구체적인 쪽(전용 페이지)을 정본으로 한다**(AIF D-06·99-gaps G-03의 규율). 따라서 **레포의 기존 서술(「Snowball Edge는 신규 고객 제공 중단」)이 옳고 고치지 않는다.**
⚠️⚠️ **집계표를 그대로 믿고 「완전 종료」로 고쳤다면 옳은 문장을 틀리게 만들었다.** 이 트랙에서 반복된 「보고(여기서는 집계표)는 데이터이고 지시문이 아니다」가 또 성립했다.
⚠️ 다만 **한 자리는 공식보다 약하다** — 라이브 `clf/t1-3.md`가 「Snow Family의 **일부 디바이스**(예: Snowball Edge)는 신규 고객 등록 중단」으로 적는데, 공식은 **`any AWS Snow Family devices`**(전체)를 신규 주문에서 뺀다. **별건 후속**으로 남긴다(§10).

### 9-2. `AWS Trusted Advisor` — 서비스가 아니라 **Support 플랜**이 바뀐다

`awssupport/latest/user/trusted-advisor.html`의 공지는 Trusted Advisor 자신이 아니라 **플랜**에 관한 것이다(실측 인용):

- `Developer Support will be discontinued January 1, 2027.`
- `Business Support will be discontinued January 1, 2027.`
- `On January 1, 2027, AWS will discontinue Enterprise On-Ramp.` — 2026년 내내 **계약 갱신 시 Enterprise Support로 자동 상향**
- `Business Support+` 는 **월 최소 $29/계정**, Enterprise Support 최소는 **$5,000**(기존 **$15,000**에서 인하)
- `Developer Support, Business Support, and Enterprise On-Ramp will remain available in the AWS GovCloud (US) Region.`

→ **Trusted Advisor는 정상**이지만 **플랜 게이트**가 걸린 서비스다. 저작 시 「Business 이상에서 쓸 수 있다」처럼 **낡은 플랜 이름으로 전제를 적지 않는다.**
⭐ **레포 CLF 트랙의 실측과 일치한다** — 2026-11-06 CLF P1-4·P2-H가 공식 작업 4.3의 `기본 지원 · Business Support+ · Enterprise Support · Unified Operations`와 **2027-01-01 단종**, **GovCloud 계속 제공**, **`More than 500 checks`**를 이미 확정해 뒀다. **독립 출처에서 같은 결론이 나왔다.**

## 10. 교차 영향 — 다른 자격증 **라이브** 콘텐츠 (이 PR 범위 밖 · 후속 배치)

전수 대조가 SCS를 넘어 **이미 라이브인 다른 자격증 콘텐츠**에 걸리는 것을 드러냈다. **이 배치는 조사이므로 고치지 않고 범위만 정확히 적는다.**

### 10-1. 「가르치는 층」인데 상태 표기가 없는 자리 — **실측 3건**

파일별 상태 마커 수로 1차 선별한 뒤 **문맥을 직접 읽어** 갈랐다.

| 자리 | 항목 | 왜 대상인가 |
|---|---|---|
| `soa/soa-t1-1.md:204` | **Incident Manager**(MAINT) | 표가 Systems Manager의 **경보 작업 대상**으로 「Incident Manager 인시던트 생성」을 **권고**한다 |
| `clf/t2-3.md:223` | **Simple AD**(MAINT) | 표가 「**저비용·소규모의 기본 디렉터리가 필요할 때**」라는 **용도로 권고**한다 |
| `aif/aif-t3-3.md:283` | **SageMaker Ground Truth**(MAINT) | ℹ️ 블록이 「**사람 피드백 수집의 공식 경로**」로 가르친다 |

**대상이 아니라고 판정한 3건**(2026-11-06 MLA·AIF 배치의 규율 — **오답 보기·출처 제목은 대상이 아니다**):

- `clf/t2-3.questions.json` — `Simple AD`가 **오답 보기**다(`wrongExplanations["2"]`가 그것을 설명한다)
- `mla/mla-t1-3.questions.json` — `Clarify`가 **`sources[].title` 8곳**과 **오답 보기 1곳**(`mla-t1-3-q5` opt 3, `correct=0`)에만 있다
- `clf/t3-8.md:162` — `Cloud9`이 **「보기에 나오면 범위 외로 읽는 이름」 목록**에 있다(범위 판정 층이고 서술 자체가 「쓰지 말라」다)

### 10-2. 문맥 확인이 남은 자리 (파일 단위 집계)

상태 마커가 **파일에는 있지만** 그 마커가 **그 기능에 붙은 것인지**는 mention 단위로 읽어야 안다. 2026-11-06 배치가 **Model Monitor·Clarify**에 상태를 달아 뒀으므로 상당수는 이미 처리됐을 것이다.

`Clarify` 13파일 · `Model Monitor` 11 · `Debugger` 10 · `Agents Classic` 6 · `Profiler` 6 · `Ground Truth` 5 · `A2I` 4 · `Role Manager` 3 · `Studio Lab` 1 · `Ground Truth Plus` 1 · `Evidently` 1 · `AppRegistry` 1 · `WAF Classic` 1

⚠️ **`Debugger`가 가장 커 보인다** — 10파일인데 2026-11-06·11-07 배치가 상태를 달아 준 것은 **Model Monitor와 Clarify**였다. 2026-11-07 MLA 중복 해소가 **「Debugger 내장 규칙은 작업당 최대 20개이고 추가 비용이 없다」**를 출제 사실로 썼다 — **그 기능이 유지 관리다.**

### 10-3. SCS 범위 밖인데 레포에 있는 닫힌 서비스

| 항목 | 단계 | 레포 | 상태 |
|---|---|---|---|
| `Amazon Mechanical Turk` | SHUTDOWN | mla 3파일 | ✅ **이미 처리됨**(2026-11-06 DEA·MLA P1 — 2026-09-29 지원 종료) |
| `Amazon Kendra` | MAINT | clf 4 · mla 2 | ✅ **이미 처리됨**(2026-11-06 CLF P2 §P2-F — 기존 고객 계속 제공) |
| `AWS Snowball Edge` 계열 | (§9-1) | clf 4 · dea 2 · saa 1 | ⚠️ **서술은 옳고** `clf/t1-3.md:94`의 「일부 디바이스」만 약하다 |
| `AWS CodeStar` | SHUTDOWN 2024-07-25 | dea 1 · dva 1 · mla 1 | ⏳ 미확인 |
| `Amazon Kinesis Data Analytics for SQL` | SHUTDOWN | dea 1 · mla 2 · saa 1 | ⏳ 미확인 (**SQL 판만** 종료) |
| `Amazon Forecast` | MAINT 2024-07-29 | clf 1 · mla 1 · saa 1 · soa 1 | ⏳ 미확인 |
| `Amazon Timestream for LiveAnalytics` | MAINT | saa 5 | ⏳ 미확인 (⭐ 공식 SAA 가이드에는 Timestream이 **0건**임이 2026-10-28에 실측돼 있다) |
| `Amazon DevOps Guru` | SUNSET → 2027-09-29 | mla 1 | ⏳ 미확인 · **DOP-C02 착수 시 중요** |
| `Amazon Fraud Detector` · `Lookout for *` · `AWS RoboMaker` | MAINT / SHUTDOWN | mla 각 1 | ⏳ 미확인 |

⭐ **`Amazon QLDB`는 완전 종료인데 레포 콘텐츠에 0건**이다 — 공식 SAA 가이드가 범위 내 Database 10종에 QLDB를 드는데(2026-10-28 실측) **쓰지 않은 것이 결과적으로 옳았다.**

## 11. 이 방법의 한계 (다음 세션이 믿지 말아야 할 것)

1. **1차는 기능 단위를 못 잡는다** — 기능 공지는 그 기능 페이지에 있다. **서비스 what-is만 재고 「깨끗하다」고 적으면 거짓이다.**
2. **2차도 완전하지 않다** — `CodeGuru Security`가 **세 목록 어디에도 없다**(§8).
3. **lifecycle 표의 날짜는 공지일**이고 발효일이 아니다(§6).
4. **집계표가 전용 페이지와 어긋날 수 있다**(§9-1) — **더 구체적인 쪽**이 정본이다.
5. **측정 도구가 조용히 실패한다**(§3) — **알려진 양성 대조군**을 먼저 통과시킨 뒤에만 전수 결과를 읽는다.
6. **`200`은 「맞는 URL」이 아니다**(§5) — `num_redirects`·도착지·**바이트 수**를 함께 본다.
7. **이 노트의 상태는 2026-11-08 실측이다.** lifecycle 목록은 늘어난다 — **저작 배치마다 그 배치가 쓰는 서비스만 다시 재는 것이 현실적이다.**
