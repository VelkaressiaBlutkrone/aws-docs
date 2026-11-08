# SCS-C03 갭·확인 항목

> **작성 2026-11-06.** AIF 트랙의 번호 규약을 따른다 — `⚠️` 판정이 필요하거나 저작에 제약을 주는 것, `ℹ️` 기록만, `✅` 해소.
> 구조 수치의 정본은 [00-overview.md](00-overview.md), 레포 JSON 대조는 [97-repo-json-diff.md](97-repo-json-diff.md), 판정은 [98-authoring-decisions.md](98-authoring-decisions.md)다.

## 차단급 — 저작 전에 판정해야 한다

### G-01 ✅ 현행 버전과 전환 일정 (해소 — 실측)

- **SCS-C03이 현행이고 2025년 12월 2일부터 쓰인다**(부록 B). C02는 **2025년 12월 1일까지**였다.
- 실측: `security-specialty-03` **`200 r=0`** · `security-specialty-02` **`404`** · 무버전 `security-specialty` **`404`**. 대조군(없는 가이드 슬러그)도 **`404 r=0`**이라 이 가이드 계열은 **없는 가이드에 진짜 404를 준다**(판정 신호가 유효하다).
- ⭐ **DVA식 함정이 없다.** DVA는 가이드가 공개됐지만 시험 적용이 2026-12-01부터였다. SCS-C03은 이미 약 1년 현행이다.
- ⭐ **한국어 판이 은퇴 대상이 아니다** — 인증 페이지의 2026-12-31 은퇴 목록은 간체 중국어·스페인어(LatAm)·포르투갈어(BR)뿐이다.

### G-02 ⚠️⚠️ 공식 범위 「내」 목록에 **상태가 닫힌 서비스 다섯**이 있다

> ⚠️ **2026-11-06 정정: 「넷」이 아니라 「다섯」이다.** AIF 2차 전수 검토에서 **`AWS CloudTrail Lake`가 2026-05-31부터 신규 고객에게 닫힌 것**이 확인됐고, 그 서비스는 **SCS 범위 내 「AWS 관리 및 거버넌스」 목록에 있다**(아래 표의 다섯째 줄). 즉 Phase 1의 표본은 4/4가 아니라 **5/5가 문제**였고, 나머지 66개 전수 확인(G-06)의 필요성이 더 커졌다. 경위는 AIF 99-gaps **G-68**이다.

이것이 이 자격증 저작의 가장 큰 제약이다. AIF D-07과 같은 계열이지만 **방향이 다르다** — AIF는 *레포 JSON*이 범위 밖 서비스를 들었고, SCS는 **공식 가이드 자신이** 닫힌 서비스를 범위 내로 든다.

| 서비스 | 상태 (2026-11-06 실측) |
|---|---|
| **`Amazon CodeGuru Security`** | ⚠️⚠️ **지원 종료.** "On **November 20, 2025**, AWS will discontinue support for Amazon CodeGuru Security. After November 20, 2025, you will no longer be able to access the /codeguru/security console, service resources, or **documentation**." **사용자 안내서가 통째로 404다**(`security-ug/what-is-codeguru-security.html`·`security-ug/end-of-support.html` 둘 다 `404 r=0`). 공지는 **SDK 참조 문서에만** 남아 있다 |
| **`AWS Audit Manager`** | ⚠️ **신규 고객에게 닫혔다.** "AWS Audit Manager is **no longer open to new customers**. Existing customers can continue to use the service as normal." (AIF D-07에서 이미 확인 — 유지 관리 모드, 2026-04-30부터 신규 계정 설정 불가) |
| **`Amazon Q Business`** | ⚠️ **신규 고객에게 닫혔다.** "Amazon Q Business is **no longer open to new customers**. For capabilities similar to Q Business, explore **Amazon Quick**." |
| **`Amazon Q Developer`** | ⚠️ **부분 종료.** "On **April 30, 2027**, AWS will discontinue support for Amazon Q Developer **IDE plugins** … explore **Kiro**." 그리고 **콘솔 대화 경험은 이제 「AWS assistant」**다. ⚠️ 종료 대상은 **IDE 플러그인**이고 서비스 전체가 아니다 |
| **`AWS CloudTrail Lake`** | ⚠️ **신규 고객에게 닫혔다 — 2026-05-31부터**(2026-11-06 추가). 기존 고객은 계속 쓰고 **추적·Insights·집계 이벤트는 영향 없다.** ⚠️ **같은 2026-04-30 유지 관리 전환 묶음에 `Amazon SNS – Message Data Protection(MDP)`도 있고, 그 기능은 공식 신규 `기술 5.3.4`가 예시로 드는 것**이다 — 가이드가 갓 추가한 목표가 유지 관리 기능을 인용한다 |

⚠️⚠️ **`CodeGuru Security`는 특히 심각하다** — 가이드가 **2026년 3월 26일에 게시**됐는데 그 서비스는 **2025년 11월 20일에 이미 종료**됐다. 즉 **공식 가이드가 게시 시점에 이미 존재하지 않는 서비스를 범위 내로 적고 있다.**
⚠️ **문서가 없으므로 사실을 실측할 방법이 없다.** 이 서비스에 기대는 학습문서·문항은 **만들 수 없다**(저작 결정 D-04).

⚠️ **교훈: 「공식 범위 목록에 있다」는 「그 서비스가 살아 있다」를 뜻하지 않는다.** AIF에서 얻은 "게시일이 최신이어도 서비스 상태는 따로 확인해야 한다"(AIF G-24)가 **범위 목록 자체에도 적용된다.** → 저작 전에 **71개 전수 상태 확인**이 필요하다(G-06).

> ✅ **2026-11-08: 전수 확인이 끝났고 이 다섯은 그대로다**(G-06). **다만 이 표가 전부가 아니다** — 서비스는 살아 있는데 **기능·에디션이 닫힌 것이 28항목** 더 있고 그중 셋은 SCS 저작의 중심 소재다(**G-15**). 또 **`CodeGuru Security`는 공식 lifecycle 목록에도 없다**(G-16) · **lifecycle 표의 날짜는 공지일이고 발효일이 아니다**(G-17). 실측 정본은 [96-service-status-audit.md](96-service-status-audit.md).

### G-03 ⚠️ 공식 내부 어긋남 4건 (정본 선택 필요)

1. **부록 B ↔ 도메인 페이지의 Task 제목**이 다르다(「솔루션」 ↔ 「기능」 등). → **도메인 페이지를 정본으로**(D-02).
2. **부록 B의 「삭제」 절은 C02 번호**, **「추가」 절은 C03 번호**를 쓴다. C03에 없는 `작업 6.4`·`2.5`·`3.4`가 나오므로 섞어 읽으면 안 된다.
3. **인증 페이지 ↔ 가이드의 대상 응시자 경력**이 다르다(3~5년 ↔ 5년 + 2년 이상). → **개수를 묻는 서술을 쓰지 않는다**(AIF G-22 계열).
4. **`기술 6.2.4`의 `(AWSRAM)`** 은 공백이 빠진 오기다. 같은 가이드의 서비스 목록은 `(AWS RAM)`으로 바르게 적는다. → **`AWS RAM`**(D-05).

## 저작 전에 정해야 하는 것

### G-04 ⚠️ 공식 답안 유형 4종 vs 이 레포의 단일 정답 스키마

가이드가 **선다형 · 복수 응답형 · 순서 배열 · 매칭형**을 적는데 이 레포의 문항 스키마는 **단일 정답 4지선다** 하나다. AIF가 D-05로 판정한 것과 같은 상황이다. → **D-03**.

### G-05 ⚠️ 학습문서 1편 = Task 1개인가

AIF는 **공식 Task 14개 = 학습문서 14편**(D-01)으로 갔다. SCS는 **Task 16개 · 기술 70개**다.

- Task당 기술 수가 고르지 않다 — `3.2`는 **7개**로 가장 많고 **`1.3`은 2개로 가장 적다**. D4는 Task 2개에 기술 **8개**(`4.1` 3 + `4.2` 5)다.
  > ⚠️ **2026-11-08 정정:** 이 줄은 처음 `4.1`·`4.2`를 「각 4개」로 적었는데 **공식 실측은 3·5**이고 `1.3`은 **4개가 아니라 2개**다. 합계 70과 D4의 8개는 맞았지만 분해가 틀렸다. 공식 Task별 전수는 **5·6·2 / 4·5 / 4·7·5 / 3·5 / 3·4·5 / 5·4·3**이고 `scs_guide_sync_test.dart`의 대조군이 이 분해를 고정한다.
- ⚠️ **비중과 Task 수가 어긋난다** — D4는 비중이 **가장 높은 20%**인데 **Task가 2개**고, D1은 16%에 **Task 3개**다. 「Task 1편」 규칙을 쓰면 **D4 문서 2편이 시험의 20%를 져야 한다.**
- → **D-01**에서 판정한다.

### G-06 ✅ 범위 내 71개 서비스의 상태 전수 확인 (해소 — 2026-11-08 실측)

**실측 정본은 [96-service-status-audit.md](96-service-status-audit.md)다.** 결과 요약:

- **서비스 자체가 닫힌 것은 5개**로 G-02와 **같다**(신규 추가 0건). 전수 확인이 G-02를 뒤집지 않았다.
- ⚠️⚠️ **대신 「기능·에디션 단위」 28항목이 새로 나왔다**(15개 서비스에 걸쳐) — G-02는 **서비스 단위**로만 봤는데 **출제 소재는 기능 단위**다. 상세는 **G-15**.
- **방법:** 1차 = 71개 `what-is` 전수 탐침(78 URL · 대조군 3종), 2차 = **공식 `AWS Lifecycle Changes`**(`general/latest/gr/service-lifecycle.html` — `aws.amazon.com/products/lifecycle/`가 여기로 리다이렉트된다). **둘이 서로를 교정했다** — 1차는 기능 단위를 못 잡고, 2차는 `CodeGuru Security`를 목록에 두지 않는다.
- ⚠️⚠️ **탐지기가 두 번 조용히 실패했고 둘 다 「문제 없음」처럼 보였다** — 고정 문구가 **`be` 한 낱말**에 뚫렸고(알려진 양성 `CloudTrail Lake`가 0건), 이 환경의 **`grep -iF`가 SIGABRT로 죽어** 71개 전부 「0건 일치」가 됐다. **알려진 양성 대조군을 먼저 통과시키기 전의 0건은 결과가 아니다**(96 §3).
- ⚠️ **내가 추측한 문서 URL 4건이 틀렸다**(96 §5) — 틀린 슬러그도 `200`을 받으므로 **`num_redirects`·도착지·바이트 수**를 함께 본다. 레포 콘텐츠에는 0건이라 예방 가드만 뒀다.

### G-07 ℹ️ `Amazon EC2용 자동 포렌식 오케스트레이터`는 서비스가 아니라 솔루션이다

범위 내 「보안, ID 및 규정 준수」 목록에 들어 있고 `기술 2.1.4`의 예시로도 나온다. 영문은 `Automated Forensics Orchestrator for Amazon EC2`다. **AWS Solutions 라이브러리 항목**이라 서비스 문서가 아니라 솔루션 문서를 봐야 한다 — 출처 형태가 다르다.

### G-08 ℹ️ `Amazon Verified Permissions`의 공식 분류가 「네트워킹」이다

보안·ID 쪽 서비스인데 가이드가 **「네트워킹 및 콘텐츠 전송」**에 넣었다. 범주로 검색하면 못 찾는다. 공식 분류를 그대로 인용할 때만 주의하면 되고 사실 문제는 아니다.

### G-09 ℹ️ `AWS PrivateLink`가 범위 목록에 없다

실측 0건. 다만 목록이 "전체 목록이 아니며 변경될 수 있다"고 적고 `Amazon VPC`가 범위 내다. **「목록에 없다」 ≠ 「범위 밖」**(AIF G-10 규율) — 학습문서에는 쓸 수 있고 **문항의 정답 보기로 쓸 때만** 범위 목록에 든 이름을 우선한다.

## AIF 트랙에서 바로 재사용할 수 있는 것

### G-10 ⭐ 생성형 AI 보안(`기술 3.2.7`)은 AIF 실측분이 그대로 맞는다

C03 신규 기술 `3.2.7`이 **생성형 AI 애플리케이션용 보호·가드레일**(GenAI OWASP Top 10)이고, AIF 트랙이 이미 실측해 둔 것이 많다.

- Bedrock Guardrails **정책 여섯 종류**와 유해 범주 **6종** 판정(AIF G-23 — 전용 페이지 `guardrails-prompt-attack.html`을 정본으로)
- **안전 조치 계층은 세 정책에만** 있고 **미지정 시 Classic**이며, 공식 문구가 `If you don't specify a tier, your guardrail uses Classic tier.`다(AIF G-49·G-61 정리에서 보존 가드로 고정)
- **프롬프트 공격 필터는 입력 태그가 없으면 동작하지 않는다** · **프롬프트 누출 탐지는 Standard 전용** · **자동 추론 검사가 못 하는 것 6종**
- ⚠️ **미평가 필드는 `messages[].content[].toolResult`와 `toolConfig.tools[].toolSpec`**이다
- ⚠️ **지식 기반에서 검색된 참조에는 Guardrails가 적용되지 않는다**
- ⚠️ **Guardrails 미지원 모델이 있고 유형으로 추론해서는 안 된다**

### G-11 ⭐ 민감 데이터 마스킹(`기술 5.3.4`)의 핵심 사실도 이미 있다

- **Guardrails의 PII 마스킹은 로그에 적용되지 않는다** — CloudWatch Logs의 `input`은 **항상 원본**이고 트레이스의 `match`도 원래 PII 값이다. **의도된 설계**다.
- **대책은 CloudWatch Logs 데이터 보호 정책**이고 ⚠️ **소급 적용되지 않는다.**
- 공식 기술 `5.3.4`가 드는 예시가 바로 **CloudWatch Logs 데이터 보호 정책**과 **SNS 메시지 데이터 보호**다 → AIF 실측분이 **출제 축 그 자체**가 된다.

### G-12 ℹ️ 닫힌 서비스 판정이 AIF와 **반대 방향**인 자리

**`AWS Audit Manager`는 AIF에서 범위 밖이었는데 SCS에서는 범위 내다.** AIF 저작에서는 `aif_facts_test`의 금지 문구로 묶었지만, SCS에서는 **공식이 범위로 드는 서비스**다.

- → **자격증별로 금지 목록을 따로 둔다.** AIF 가드를 복제하면 SCS에서 정당한 서술이 막힌다.
- ⚠️ 다만 **신규 고객에게 닫힌 것은 사실**이므로 SCS 학습문서도 그 상태를 적어야 한다(D-04).

## 아직 조사하지 않은 것 (Phase 2 범위)

### G-13 ✅ 깊이 조사가 필요한 주제 (조사 노트 후보) — 해소(2026-11-08)

후보 셋을 **`93`·`94`·`95` 세 편으로 저작했다**(P-02 해소). 판정·대응표의 정본은 **98 P-02**이고, 세 편이 새로 세운 갭은 **G-22~G-28**이다. 아래 후보 목록은 **무엇을 왜 골랐는지의 기록**으로 남긴다.

AIF가 `94`(에이전틱 AI·MCP) · `95`(서비스 이름과 정체) · `96`(FM 비용·평가·가드레일) 세 편을 둔 것에 대응한다. SCS 후보:

1. **키 관리 계보** — KMS 고객 관리형 키 · **가져온 키 자료 vs AWS 생성 키 자료**(신규 `5.3.3`) · CloudHSM · AWS Private CA · 다중 리전 키. `기술 5.3.3`·`5.3.5`가 신규라 **기존 교재가 얇다.**
2. **탐지 파이프라인의 서비스 경계** — GuardDuty · Security Hub · Detective · Security Lake · Inspector · Macie · **OCSF 형식**(신규 `3.1.4`). ⚠️ 서비스 간 역할이 겹쳐 보여 **「무엇이 무엇을 탐지하는가」의 경계**가 문항의 갈림길이다.
3. **ID·권한 부여** — 비중 **20%**로 가장 크다. IAM · IAM Identity Center · STS · Cognito · Directory Service · **Verified Permissions** · SCP·RCP·declarative policies. ⚠️ AIF 트랙에서 **`declarative_policies` 슬러그가 소멸하고 `orgs_manage_policies_declarative`가 정본**임을 이미 실측했다(갭 배치 B11 기록).

### G-14 ℹ️ 저작 분량 추정의 근거가 아직 없다

AIF는 14편 · 28~99KB였다. SCS는 Task 16개 · 기술 70개이고 **Specialty 등급**이라 기술당 깊이가 더 깊다. **D-01 판정 후에 배치 계획을 세운다.**

## 2026-11-08 전수 확인(G-06)에서 새로 세운 것

### G-15 ⚠️⚠️ 범위 내 서비스의 **기능·에디션**이 닫힌 것 28항목 — 셋은 저작의 중심 소재다

전체 표는 [96-service-status-audit.md](96-service-status-audit.md) **§7-2**다. 저작에 직접 걸리는 셋만 여기 적는다.

1. **`Amazon SNS` 메시지 데이터 보호(MDP)가 유지 관리다**(공지 2026-03-31). ⚠️⚠️ **공식 신규 `기술 5.3.4`(민감한 데이터 마스킹)가 예시로 드는 바로 그 기능**이다 — **가이드가 갓 추가한 목표가 유지 관리 기능을 인용한다.** 같은 목표의 다른 예시인 **CloudWatch Logs 데이터 보호 정책은 정상**이므로 **그쪽을 축으로** 삼고 SNS MDP는 상태를 적어 다룬다(D-04 확장).
2. **`AWS Systems Manager` Incident Manager가 유지 관리다**(공지 2025-11-07). **도메인 2(인시던트 대응, 14%)**의 가장 자연스러운 소재라 모르고 쓰면 「지금 이것을 쓰라」가 된다.
3. **`AWS WAF` Classic이 완전 종료**(2026-10-07) · **`Amazon Inspector` Classic도 완전 종료**(2026-05-20). 「Classic vs 현행」 대비를 소재로 쓰면 **없는 것과 비교**하게 된다.

그 밖에 **`AWS Directory Service` Simple AD** · **`Amazon Application Recovery Controller` 준비 상태 확인** · **`Amazon Cognito` Cognito Sync** · **`AWS Service Catalog` AppRegistry** · **`Amazon S3` Select·Object Lambda** · **`Amazon Bedrock` Agents Classic** · **`Amazon SageMaker AI` 10항목** · **`AWS Management Console` myApplications**가 닫혔다.

⭐ **SAA 트랙과 이어진다** — 2026-10-30 갭 배치 B11이 「ARC 공식 기능은 5종이고 `readiness check`가 조사 노트에 빠져 있었다」를 실측해 넣었는데, **그 기능이 지금 유지 관리다.**

### G-16 ⚠️ **공식 lifecycle 목록에 없다 ≠ 살아 있다**

`Amazon CodeGuru Security`는 문서가 **`404 r=0`**인데 **Maintenance·Sunset·Full Shutdown 세 목록 어디에도 없다.** 대조군으로 **`Amazon CodeGuru Reviewer`는 Maintenance에 있다**(공지 2025-10-07) — 목록이 그 계열을 다루기는 한다.

→ AIF **G-10**의 규율(「목록에 없다 ≠ 범위 밖」)이 **이 새 출처에도 적용된다.** 2차 방법도 완전하지 않으므로 **두 방법을 함께** 쓴다. **D-04의 `CodeGuru Security` 판정은 유지한다.**

### G-17 ⚠️ lifecycle 표의 날짜는 **공지일**이고 발효일이 아니다

- `AWS CloudTrail Lake` — lifecycle 공지일 **2026-03-31** ↔ 서비스 문서의 신규 차단 개시 **2026-05-31**
- `AWS Audit Manager` — lifecycle 공지일 **2026-03-31** ↔ AIF 트랙 실측 신규 계정 설정 불가 **2026-04-30**

→ **공지일을 차단일로 적지 않는다.** 날짜를 쓸 때는 **그 서비스 전용 가용성 변경 페이지**를 본다(D-07의 「공식이 갈리는 수치는 단정하지 않는다」와 같은 층).

### G-18 ⚠️ 공식 내부 어긋남 — `AWS Snowball Edge`(집계표 ↔ 전용 페이지)

lifecycle **집계표**는 **Full Shutdown · 지원 종료 2025-11-12**로 적는데, **서비스 전용 페이지**는 `is no longer available to new customers`(유지 관리 어법)만 쓰고 **`end of support`·`shut down`·`November 12`·`2025`가 전부 0건**이며 「기존 고객에게 계속 투자한다」고 적는다.

→ **더 구체적인 쪽(전용 페이지)이 정본**이다(G-03·AIF D-06의 규율). **레포의 기존 서술이 옳으므로 고치지 않는다** — 집계표를 그대로 믿었다면 **옳은 문장을 틀리게 만들었다.** 상세는 96 §9-1.

### G-19 ⚠️ `AWS Trusted Advisor`는 서비스가 아니라 **Support 플랜**이 바뀐다

`Developer Support`·`Business Support`·`Enterprise On-Ramp`가 **2027-01-01 단종**이고, `Business Support+`는 월 최소 **$29/계정**, Enterprise Support 최소는 **$5,000**(기존 $15,000에서 인하), **GovCloud(US)에서는 세 플랜이 계속 제공**된다.

→ Trusted Advisor는 **정상이지만 플랜 게이트**가 걸린 서비스다. **낡은 플랜 이름으로 전제를 적지 않는다.**
⭐ 레포 CLF 트랙(2026-11-06 P1-4·P2-H)이 **독립 출처에서 같은 결론**에 이미 도달해 있다.

### G-20 ℹ️ 저작 시 쓸 문서 URL 4건이 내 추측과 달랐다

96 **§5**가 정본이다 — `Well-Architected Tool`은 `tool.html`(`intro.html` 아님) · 자동 포렌식 오케스트레이터는 `architecture-overview.html` · **`STS/latest/APIReference/welcome.html`은 죽은 슬러그**(개념 정본은 `IAM/latest/UserGuide/id_credentials_temp.html`) · `Data Lifecycle Manager`는 가이드가 `AWSEC2/…` → **`ebs/…`**로 이동했다.

⚠️ **`STS/…/welcome.html`은 살아 있는 `repost.aws` 문서가 지금도 링크한다** — 3자 페이지에서 URL을 베끼면 죽은 슬러그를 인용한다. 네 URL은 **레포에 0건**이고 `source_url_retired_test.dart`에 **예방 가드**를 뒀다.

### G-21 ⏳ 다른 자격증 라이브 콘텐츠로 번지는 것 — **후속 배치**

전수 대조가 SCS를 넘어 **이미 라이브인 다른 자격증 콘텐츠**에 걸리는 것을 드러냈다. 96 **§10**이 범위의 정본이다.

- **「가르치는 층인데 상태 표기 없음」 실측 3건** — `soa/soa-t1-1.md:204`(Incident Manager) · `clf/t2-3.md:223`(Simple AD) · `aif/aif-t3-3.md:283`(SageMaker Ground Truth). 전부 **라이브**다.
- **문맥 확인이 남은 자리** — `Debugger` 10파일이 가장 크다(2026-11-06·11-07 배치가 상태를 달아 준 것은 **Model Monitor·Clarify**였다).
- **대상이 아니라고 판정한 3건**도 적어 뒀다(오답 보기·출처 제목·범위 판정 층).

⚠️ **이 배치(조사)에서는 고치지 않았다** — 여섯 자격증에 걸친 콘텐츠 정정이라 **최소 단위로 갈라** 별 배치로 간다.

## 2026-11-08 조사 노트 3편(P-02)에서 새로 세운 것

정본은 [93](93-detection-pipeline-boundaries.md) · [94](94-identity-and-authorization.md) · [95](95-key-management-lineage.md)이고, 아래는 **저작 전에 더 재야 하는 것**과 **방법론 교훈**만 남긴 것이다.

### G-22 ✅ `Security Hub` 두 제품의 활성화 선후 관계 — 해소(2026-11-08)

**CSPM은 전제 조건이 아니다.** 공식 활성화 문서가 "You can enable Security Hub for **any** AWS account"로 시작하고 독립 계정 절차에 CSPM 선행 요건이 없다.

⚠️⚠️ **그런데 위임 관리자 선택이 CSPM 쪽에 묶인다** — CSPM 위임 관리자가 지정돼 있고 그 계정이 **조직 관리 계정이 아니면 그 계정이 자동으로 Security Hub 위임 관리자가 되고 다른 계정을 고를 수 없다.** CSPM 위임 관리자가 관리 계정이거나 없으면 고를 수 있고, 그때도 **조직 관리 계정은 제외**다.

⚠️ 함께 실측된 것 — Security Hub를 켜면 **서비스 연결 역할 `AWSServiceRoleForSecurityHubV2`·서비스 연결 구성 레코더·서비스 연결 분석기**가 만들어진다(구성 기록과 액세스 분석을 자기 몫으로 세운다) · 「**신뢰할 수 있는 액세스**」 체크박스를 끄면 위임 관리자가 멤버 계정에 GuardDuty Malware Protection 같은 기능을 **구성할 수 없고 해당 서비스에서 직접** 켜야 한다 · **크로스 리전 집계의 대상이 두 제품에서 다르다**(CSPM은 통찰·제어 준수 상태·보안 점수까지 / 신 제품은 리소스·추세) · CSPM의 **「집계 리전」은 「홈 리전」으로 개명**됐고 일부 API만 옛 용어를 쓴다 · **홈 리전은 옵트인 리전일 수 없다**.

저작 반영은 `scs-t1-1` §3이고, 아래는 해소 전 기록이다.

93 §2가 고정한 것은 **CSPM과 신 Security Hub가 다른 제품**이라는 것까지다. **신 Security Hub를 켜려면 CSPM이 먼저 켜져 있어야 하는가**, 둘을 따로 끌 수 있는가, 조직 단위 위임 관리자가 공유되는가는 **재지 않았다.**

⚠️ 노출 조사 결과가 **CSPM 신호를 입력으로 받으므로** 의존이 있을 법하지만 **그것은 추론이다.** `기술 1.1.4`·`6.3.1` 저작 전에 활성화·구독 문서를 직접 재고, 그때까지 **선후를 단정하는 서술을 쓰지 않는다.**

### G-23 ⏳ IAM 정책 시뮬레이터와 Access Analyzer 정책 검증의 구분을 재지 않았다

`기술 4.2.4`가 "액세스 권한 분석(예: IAM 정책 시뮬레이터, IAM Access Analyzer)"으로 **둘을 함께** 든다. 94 §8이 Access Analyzer의 6기능을 고정했지만 **시뮬레이터 전용 페이지는 이 배치에서 재지 않았다.**

경계의 가설은 「시뮬레이터 = 특정 요청의 **평가 결과** 예측 / Access Analyzer = **논리 기반 추론**으로 외부 공유·미사용·표준 위반 식별」이지만 **실측 전에는 쓰지 않는다.**

### G-24 ⚠️ Organizations 관리 정책의 공식 **분류**가 움직이고 있다

94 §3-3 실측: **선언적 정책 페이지의 하위 주제에 「태그 정책」·「AI 서비스 옵트아웃 정책」을 포함한 12종**이 들어 있다. 그런데 **공식 가이드 `기술 6.1.3`은 "SCP, RCP, AI 서비스 옵트아웃 정책, 선언적 정책"을 병렬로** 적는다.

⚠️ **분류를 단정하는 문항을 만들지 않는다.** 고정할 수 있는 축은 **「SCP·RCP는 권한 부여 정책이고 나머지는 권한을 부여·거부하지 않는다」**와 **「선언적 정책만 서비스 연결 역할을 통제한다」**(공식 비교 표)다.
⚠️ 반대 방향의 거짓은 분명하다 — **「SCP로 AI 서비스 데이터 사용을 옵트아웃한다」는 거짓**이다.

### G-25 ⚠️⚠️ 죽은 슬러그 6건 — 그중 하나는 **AWS 자신의 다른 문서가 링크한다**

93 §8이 표의 정본이다. 요약: `waf-marketplace-rule-groups` · `securityhub/.../what-is-security-hub`(하이픈) · `organizations/.../declarative_policies`(접두사 누락) · `kms/.../custom-key-store-overview` · `kms/.../choose-keystore` · `detective/latest/adminguide/...`(**`r=2`, 가이드 이름 변경**).

⚠️⚠️ **`kms/.../custom-key-store-overview.html`을 AWS Go SDK 문서가 아직 링크한다.** 2026-11-08 P-01이 `STS/latest/APIReference/welcome.html`을 **살아 있는 `repost.aws` 문서가 링크한다**고 실측한 것과 같은 패턴이다 — **3자 페이지(AWS 자신의 다른 가이드를 포함)에서 URL을 베끼면 죽은 슬러그를 인용한다.**
⚠️ 레포 콘텐츠에는 이 여섯이 **0건**이고, `source_url_retired_test`에는 **아직 등재하지 않았다** — 등재 판정은 **저작 배치**에서 한다(P-01이 세 건을 예방용으로 넣은 것과 같은 기준: 되살림 방지 가치가 있을 때만).

### G-26 ⚠️ 방법론 — 본문의 **링크 텍스트에서 슬러그를 유도하지 않는다**

95 §3의 근거 페이지를 찾을 때, 본문의 링크 텍스트("Choosing the right key store")를 슬러그로 삼아 `choose-keystore.html`을 만들었고 **죽어 있었다**(정본은 `key-store-overview.html`). **실측이 없었으면 그 절 전체가 죽은 URL을 근거로 적혔다.**

같은 배치에서 같은 계열의 실수가 둘 더 났다 — `organizations/.../declarative_policies.html`(접두사를 빼고 읽어 **레포의 옳은 판정을 뒤집을 뻔했다**, 94 §12)과 `securityhub/.../what-is-security-hub.html`(하이픈을 넣어 추측). ⚠️⚠️ **리다이렉트 노트를 읽지 않고 「정본이 또 바뀌었다」고 적는 것이 이 트랙에서 가장 비싼 실수다.**

### G-27 ℹ️ 가이드가 적지 않는 인접 제품 둘이 공식 문서에 등장한다

- **`AWS Shield network security director`** — WAF·Shield·Firewall Manager 소개 페이지가 **Shield Advanced와 별도 제품**으로 소개한다. 가이드는 `Shield Advanced`만 적는다(`기술 2.1.2`·`3.1.2`). **둘을 섞지 않는다.**
- **`Amazon Bedrock AgentCore Gateway`와 `AWS Amplify`가 AWS WAF 보호 대상 9종에 들어 있다**(93 §5-1). ⭐ 신규 `기술 3.2.7`(생성형 AI 보호·가드레일)과 **직접 이어지는 재사용 후보**다 — D-08의 AIF 재사용분과 함께 쓴다.

### G-28 ⏳ `기술 5.3.4`(민감 데이터 마스킹)의 SNS 쪽은 상태 표기와 함께 간다

95는 `기술 5.3.1`·`5.3.4`를 범위에서 뺐다. 저작 시 **CloudWatch Logs 데이터 보호 정책을 축으로** 삼고(AIF 실측: **소급 적용되지 않는다**), **`Amazon SNS` 메시지 데이터 보호는 유지 관리 상태**임을 적는다(**G-15**·D-04-b). 그 둘을 한 기술에서 **대등하게** 쓰면 닫힌 기능을 권하는 서술이 된다.

## 2026-11-08 도메인 1 저작 배치에서 새로 세운 것

### G-29 ⚠️⚠️ 공식 가이드가 드는 예시 하나가 **이미 폐지된 기능**이다

`기술 1.2.2`의 예시에 "Amazon CloudWatch Logs 에이전트 구성"이 있는데, 공식 문서가 그 구 에이전트를 **폐지(deprecated)**라고 직접 적는다. 함께 실측된 것 — **IMDSv2를 쓰면 통합 에이전트가 필수** · 구 에이전트는 **Python 2.6~3.5만** 지원 · **Amazon Linux 2에서 폐지돼 AL2023에는 `awslogs` 패키지가 없다**.

⚠️ **D-04-b와 출처가 다르다** — 그쪽은 공식 `AWS Lifecycle Changes` 목록이고 이 건은 **제품 문서 자신의 폐지 고지**다. 즉 **lifecycle 목록만 봐서는 이 종류를 찾을 수 없다**(G-16의 반대 방향 보강). 처리는 **D-12**이고 `scs_doc_format_test.dart`의 저작 규율 가드가 강제한다.

⏳ **다른 Task의 예시도 같은 검사를 받아야 한다.** 이 배치는 도메인 1의 13개 기술만 봤다. 저작할 때마다 **그 기술이 드는 예시 서비스·기능의 현재 상태를 확인**한다.

### G-30 ⚠️⚠️ `Conformance Packs`의 한국어 표기가 **셋으로 갈린다**

**SCS 가이드 「준수 팩」 / SOA 가이드 「규정 준수 팩」 / AWS Config 한국어 제품 문서(기계 번역) 「적합성 팩」.**

⚠️ **레포의 기존 SOA 판정은 옳다.** 2026-10-29 전파 가드가 「적합성 팩」을 구식으로 보고 13개소를 정정한 것은 **SOA 가이드 기준**이고, SCS는 **SCS 가이드 표기**를 쓴다(**D-11**). 금지 목록은 **자격증별로 따로** 둔다.

⏳ **레포 전역 영향을 아직 세지 않았다.** `soa_dea_question_propagation_test`의 `_nameRules`는 **SOA·DEA 문항만** 보므로 SCS 콘텐츠는 그 가드에 걸리지 않는다. 저작이 끝난 뒤 **표기 집계를 한 번 돌려** 자격증 간 혼선이 없는지 확인한다.

### G-31 ℹ️ 도메인 1에서 **재지 않고 층 설명으로만 둔 것**

`기술 1.2.5`의 **Amazon OpenSearch Service · AWS Lambda · Amazon Managed Grafana**와 `기술 1.2.4`의 **Amazon Athena**는 전용 페이지를 재지 않았다. `scs-t1-2` §4·§5는 **그 세 서비스를 「변환 → 색인·검색 → 시각화」 층으로 배치하는 설명**까지만 적었고 **각 서비스의 구체 수치·한도를 단정하지 않았다**.

⏳ 문항 저작에서 이 셋을 묻는 문항을 만들려면 **전용 페이지를 먼저 재야 한다**(특히 Athena의 파티션 프로젝션, OpenSearch 수집 경로, Managed Grafana의 데이터 소스 권한 모델).

### G-32 ℹ️ `기술 1.1.2`의 「리소스 상태 확인」을 서비스별로 재지 않았다

`scs-t1-1` §2는 알람 평가(기간·평가 기간·경보 데이터 포인트)와 평가 상태를 공식으로 고정했지만, **「리소스 상태 확인 구성」**(가이드의 괄호 예시)은 ELB·Route 53·ASG 중 어느 것을 가리키는지 가이드가 적지 않는다. `scs-t1-3` §1-4에 **확인 순서만** 적고 서비스별 기본값·임계값은 단정하지 않았다.

⏳ 도메인 3(인프라 보안) 저작에서 ELB·Route 53 상태 확인을 재게 되므로 **그때 함께 채운다**.

## 2026-11-08 도메인 2 저작 배치에서 새로 세운 것

### G-33 ⚠️⚠️ `AWS Security Incident Response`가 **어느 공식 목록에도 없다**

도메인 2의 주제를 정면으로 다루는 **관리형 서비스**인데 **범위 내 71개에도, 범위 외 2개에도 없다**(2026-11-08 실측). 두 목록이 모두 스스로 non-exhaustive라고 밝히므로 **「범위 밖」으로 단정할 수 없다.** 처리는 **D-13**(구조만 소개 + 범위 메모, 문항 금지)다.

⏳ **다른 「최근 출시 서비스」도 같은 검사가 필요하다.** 이 배치는 도메인 2의 예시만 봤다. 가이드 게시일(2026-03-26)보다 늦게 나온 서비스는 **이름이 가이드에 없는 것이 당연**하므로, 저작할 때마다 **그 도메인의 주제를 다루는 신규 서비스가 있는지** 한 번 본다.

### G-34 ⚠️⚠️ `ARC` 준비 상태 확인 — **유지 관리 + 공식이 임계 경로용이 아니라고 적는다**

`기술 2.1.4`가 ARC를 예시로 드는데, ARC의 **준비 상태 확인(readiness check)**은 **2026-03-31 공지로 유지 관리**(96 §7-2)이고 **공식 what-is 자신이 "장애 중 실패 조치의 임계 경로에서 쓰도록 의도된 것이 아니다"**라고 적는다. 용도는 **처음 구성할 때와 정상 운영 중**이다.

저작 반영은 `scs-t2-1` §4-2이고, ARC의 다섯 기능(**영역 전환 · 영역 자동 전환 · 리전 전환 · 라우팅 컨트롤 · 준비 상태 확인**)을 표로 갈라 **복구 경로에 쓰는 것과 쓰지 않는 것**을 고정했다.

⏳ **다른 자격증 콘텐츠에 ARC 준비 상태 확인을 복구 경로로 적은 자리가 있는지 세지 않았다** — G-21(상태 표기 전파)과 같은 묶음으로 처리한다.

### G-35 ✅ 자동 포렌식 오케스트레이터 — **이름에 EKS가 추가됐고 「Guidance」로 불린다**(G-07 보강)

공식 문서 제목이 **`Automated Forensics Orchestrator for Amazon EC2 and EKS`**이고 본문이 자신을 **「Guidance」**로 부른다("Deploying this **Guidance**"). 공식 시험 가이드는 아직 **「Amazon EC2용 자동 포렌식 오케스트레이터」**로 적는다.

저작 반영은 `scs-t2-1` §4-1이고 **학습자가 시험장에서 EC2만 적힌 이름을 보더라도 같은 솔루션임**을 명시했다. 살아 있는 URL은 **`architecture-overview.html`**과 구현 문서 둘(`forensic-memory-and-disk-acquisition-service.html` · `disk-forensics-acquisition-workflow.html`)이고 **`solution-overview.html`은 죽은 슬러그**다(96 §7-1 #51).

### G-36 ℹ️ 도메인 2에서 **재지 않고 층 설명으로만 둔 것**

`기술 2.1.1`의 **SageMaker AI 노트북**은 전용 페이지를 재지 않고 **「런북의 실행 가능한 판」이라는 역할**까지만 적었다(`scs-t2-1` §1-2). `기술 2.1.4`의 **Step Functions**와 **Lambda**도 자동 포렌식 오케스트레이터가 **그것을 쓰는 방식**으로만 다뤘고 두 서비스의 전용 페이지는 재지 않았다.

⏳ 그 셋을 묻는 문항을 만들려면 전용 페이지를 먼저 재야 한다(특히 Step Functions의 오류 처리·재시도와 Lambda 권한 모델).

### G-37 ✅ GenAI OWASP Top 10의 **docs 안 근거를 찾았다** — D-08의 열린 항목 해소

`기술 3.2.7`이 드는 **GenAI OWASP 상위 10개**는 OWASP의 산출물이지만, **AWS 규범적 지침의 「Security for agentic AI on AWS」 가이드가 자신의 모범 사례를 OWASP Top 10 for LLM Applications 2025에 통제 번호 단위로 직접 매핑**한다(`prescriptive-guidance/latest/agentic-ai-security/owasp-top-ten.html` — `LLM01` 프롬프트 주입 ~ `LLM10` 무제한 소비 전부). 블로그가 아니라 **docs**이므로 출처로 쓸 수 있다.

⭐⭐ **그 매핑에서 가장 시험다운 사실은 「무엇이 무엇에 매핑되지 않는가」다.** **`4.2 Deploy Amazon Bedrock Guardrails`는 `LLM01`과 `LLM02`에만** 달린다.

| 범주 | 공식 매핑의 핵심 통제 |
|---|---|
| `LLM01` 프롬프트 주입 | **Guardrails** · 다층 입력 정제 · 프롬프트를 **코드 산출물로 취급** · **엣지 보호** |
| `LLM02` 민감 정보 노출 | **Guardrails** · **세션 격리** · 공유 메모리 관리 · 데이터 손실 방지 |
| `LLM06` 과도한 대행 | ⚠️ **Guardrails가 아니다** — 에이전트 범위 결정 · 결정론적 실행 로직 · **비상 종료 기능** |
| `LLM10` 무제한 소비 | ⚠️ **엣지에서의 속도 제한** · **비상 종료 기능** |

→ **「에이전트가 권한을 넘는다」와 「토큰 소비 폭증」에 Guardrails를 고르면 틀린다.** 후자는 작업 3.1의 **속도 기반 규칙**이 그대로 쓰이는 자리라 **도메인 3 안에서 두 작업이 이어진다**.

### G-38 ⚠️⚠️ WAF **본문 검사 한도가 리소스 유형마다 다르다**

관리형 규칙의 본문 검사는 **Application Load Balancer·AppSync가 8 KB 고정**(올릴 수 없다)이고, **CloudFront·API Gateway·Cognito·App Runner·Verified Access·Bedrock AgentCore Gateway는 기본 16 KB에 보호 팩 설정으로 최대 64 KB**까지다. 코어 규칙 세트의 본문 규칙은 초과 콘텐츠에 **`Continue` 옵션**을 쓰므로 **한도를 넘은 부분이 검사되지 않은 채 통과**한다.

→ "대용량 업로드 경로의 주입 공격이 탐지되지 않는다"는 지문의 답이고, **ALB 오리진에서는 한도를 올릴 수 없어 CloudFront를 앞에 두는 것이 설계 대응**이다.

### G-39 ⚠️⚠️ **CloudFront 지리 제한을 켜면 그 트래픽을 WAF가 보지 못한다**

공식 경고 그대로 — **"지리 제한 기능은 차단한 요청을 AWS WAF로 전달하지 않습니다(허용한 요청은 전달합니다). 지리에 더해 AWS WAF의 다른 조건으로 차단하려면 WAF geo match를 쓰고 CloudFront 지리 제한 기능은 쓰지 마십시오."**

→ 두 기능을 겹쳐 켜면 차단된 국가의 트래픽이 **WAF 로그·지표·속도 제한 집계에서 사라진다.** "차단하면서 패턴을 분석하라"는 지문에서 CloudFront 기능을 고르면 틀린다.

⚠️ 함께 실측된 비자명한 사실 — **CloudFront 관리형 인증서의 검증 경로 `/.well-known/pki-validation/`은 지리 제한에서 제외**되고, **WAF 규칙(봇 제어 포함)이 그 경로를 차단하면 인증서 발급·갱신이 실패**한다.

### G-40 ⚠️⚠️ GuardDuty 런타임 모니터링 — **ECS on Fargate는 되고 EKS on Fargate는 안 된다**

지원 리소스 유형은 **Amazon EKS · AWS Fargate 상의 Amazon ECS · Amazon EC2**이고, 같은 페이지가 **"GuardDuty는 AWS Fargate에서 실행되는 Amazon EKS 클러스터를 지원하지 않습니다"**를 따로 적는다.

→ **「Fargate면 다 된다」로 외우면 거꾸로 틀린다.** 비대칭이 공식 서술에 있다.

### G-41 ⚠️⚠️ Session Manager — **포트 포워딩·SSH 세션은 로깅되지 않는다**

공식 경고 — **"포트 포워딩이나 SSH를 통해 연결하는 Session Manager 세션에는 로깅을 사용할 수 없습니다."** 이유는 **SSH가 AWS CLI와 Session Manager 엔드포인트 사이 TLS 안에서 세션 데이터를 전부 암호화하고 Session Manager는 터널 역할만** 하기 때문이다.

→ "모든 관리 세션의 실행 명령을 보존하라"는 요건은 **IAM에서 SSH·포트 포워딩을 허용하지 않는 것까지** 설계에 들어가야 충족된다. 남는 기록은 CloudTrail의 API 호출과 EventBridge 알림이고 **명령 내용은 아니다**.

⚠️ 함께 실측 — **Session Manager 레거시 콘솔 페이지가 2026년 12월 31일에 폐지**되고 기능은 Systems Manager 통합 콘솔로 옮겨진다(세션 시작·이력·기본 설정은 유지).

### G-42 ⚠️⚠️ Network Firewall의 **미지원 아키텍처 셋**이 동-서 설계를 결정한다

공식이 **지원하지 않는 아키텍처·트래픽 유형**으로 셋을 적는다 — **① VPC 피어링 ② 클라이언트 IP 주소 보존을 켠 AWS Global Accelerator 트래픽 ③ EC2의 AmazonProvidedDNS 트래픽**.

→ `기술 3.3.4`(네트워크 세분화)에서 **피어링으로 묶인 VPC 사이 트래픽은 Network Firewall로 검사할 수 없다.** **Transit Gateway 경유 + 검사 VPC**가 공식 제약에서 따라오는 결론이고, 그때 ⚠️ **어플라이언스 모드**가 필수다(켜지 않으면 응답이 다른 AZ 엔드포인트로 가서 **드롭**된다 — 공식 문서가 그 예를 그림까지 들어 설명한다).

⚠️ 함께 — **방화벽 엔드포인트는 자신이 속한 서브넷으로 드나드는 트래픽을 필터링하지 못하므로** 방화벽 서브넷을 다른 용도로 쓰지 않는다.

### G-43 ⚠️ 방법론 재발 — **통제 번호에서 슬러그를 만들지 않는다**(G-26 보강)

`agentic-ai-security` 가이드의 **6.4 Deploy adequate edge protection** 통제를 읽으려고 `…/agentic-ai-security/edge-protection.html`을 추정했더니 **가이드 `introduction.html`로 리다이렉트**됐다. G-26이 「링크 텍스트에서 슬러그를 유도하지 않는다」였고, 이번은 **통제 제목에서 유도한 같은 실패**다.

→ **목차에 있는 URL만 쓴다.** 이 배치에서는 추정 슬러그를 버리고 **`owasp-top-ten.html`과 `introduction.html`** 둘을 출처로 썼다(둘 다 `200 r=0` 실측).

### G-44 ℹ️ 공식 WAF 문서가 **「보호 팩(protection pack)」으로 전환 중**이다

WAF 개발자 안내서의 여러 페이지가 **「Introducing a new console experience for AWS WAF」** 고지와 함께 본문을 **`protection pack (web ACL)`**으로 바꿔 적는다. 공식 시험 가이드(2026-03-26)는 그 용어를 쓰지 않는다.

→ 처리는 **병기**다(**D-14**). ⚠️ 용어가 과금 설명에도 들어와 있다 — Shield Advanced의 자동 L7 완화가 더하는 150 WCU를 공식이 **「보호 팩 사용량」**으로 센다.

### G-45 ℹ️ 도메인 3에서 **재지 않고 층 설명으로만 둔 것**

`기술 3.1.2`의 **서명된 URL·서명된 쿠키 전용 페이지**, `기술 3.3.1`의 **Route 53 Resolver DNS Firewall 전용 페이지**, `기술 3.2.2`의 **IMDSv2 메타데이터 옵션 전용 페이지**, `기술 3.3.1`의 **Suricata 규칙 작성 문법**, `기술 3.2.7`의 **Guardrails 계층(tier)별 상세 페이지**는 각각 **역할과 경계까지만** 적고 전용 페이지를 재지 않았다.

⏳ 그것들을 묻는 문항을 만들려면 전용 페이지를 먼저 재야 한다(특히 IMDSv2의 홉 제한·끄기 옵션과 Suricata 규칙 작업 우선순위).
