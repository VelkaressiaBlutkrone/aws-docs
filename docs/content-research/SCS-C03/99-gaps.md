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

## 2026-11-09 도메인 4 저작 배치에서 새로 세운 것

### G-46 ✅ `G-23` 해소 — 정책 시뮬레이터와 Access Analyzer 정책 검증의 경계 (실측)

`기술 4.2.4`가 둘을 함께 들어 **저작 전 선결**로 남겨 뒀던 항목이다. 가설(「시뮬레이터 = 요청 평가 / Access Analyzer = 논리 기반 추론」)의 **방향은 맞았지만 실측이 훨씬 날카로운 갈림길을 줬다.**

**시뮬레이터가 평가하는 것** — ID 기반 정책 · 권한 경계 · **SCP**(조건 키와 거부 문장의 리소스 범위까지) · **내가 제공한** 리소스 기반 정책. 결과는 작업·리소스별 **허용/거부 이진값**이고, 허용이나 명시적 거부면 **어느 정책이 그 결과를 만들었는지**도 돌려준다.

⚠️⚠️ **그런데 RCP는 지원하지 않는다** — `access_policies_testing-policies.html`이 `does not support resource control policies (RCPs)`라고 적는다. ⚠️ **반대로 Access Analyzer 정책 검증에는 RCP 전용 검사가 있다**(`Error – Policy size exceeds RCP quota` · `RCP syntax error principal`·`allow`·`NotAction`·`action` · `General Warning – RCP missing related principal condition key`)고 `access-analyzer-reference-policy-checks.html`이 적는다. **역할 신뢰 정책 전용 검사**(`Role trust policy syntax error notprincipal` 등)와 **Roles Anywhere 신뢰 정책 검사**(`Missing action for roles anywhere trust policy`)도 그쪽에 있다.

함께 실측한 시뮬레이터의 제약:

| 사실 | 공식 근거 |
|---|---|
| 모드 둘 — 보안 주체 모드 / 사용자 지정 모드 | 사용자 지정 모드의 정책은 **계정에 저장되지 않는다** |
| **권한 경계는 한 번에 하나** | 공식 본문 |
| **SCP의 매칭된 문장은 보여 주지 않는다** | "for security reasons it does not surface the matched statements from an SCP" |
| **콘솔 외에서는 리소스 정책을 대신 가져오지 않는다** | "Except in the console, the simulator does not retrieve a resource's policy for you" |
| 실제와 갈릴 수 있는 구성 **셋** | VPC 엔드포인트 정책 · **역할 체이닝** · 한 리소스에 여러 리소스 기반 정책 |
| 조건 키 자동 채움 **8종** | 보안 주체 5(`aws:PrincipalAccount`·`aws:PrincipalId`·`aws:PrincipalType`·`aws:UserId`·`aws:UserName`) + 조직 3(`aws:PrincipalOrgID`·`aws:PrincipalOrgMasterAccountId`·`aws:PrincipalOrgPaths`) |
| 콘솔은 **SCP에만 있는 조건 키에 값을 줄 수 없다** | CLI·API에서는 가능 |
| 글로벌 조건 키의 **서비스 지원 여부를 판정하지 않지만** SCP는 **서비스를 아는 논리**로 평가된다 | 예시로 `aws:TagKeys` |
| 권한이 모드별로 갈린다 | `iam:SimulateCustomPolicy` / `iam:SimulatePrincipalPolicy`(후자는 **다른 엔터티의 권한을 드러낸다**) |

정책 검증 쪽: 조사 결과 유형 **넷**(오류·보안 경고·일반 경고·제안)이고 ⚠️ **추가 요금이 없다**("There is no additional charge associated with running the policy validation checks").

⚠️⚠️ **`repost.aws` 문서를 근거로 쓰지 않았다** — 검색 상위의 repost 글이 「시뮬레이터는 조건이 있는 SCP를 테스트할 수 없다」고 적는데 **현행 docs는 조건 키와 리소스 범위를 평가한다고 적는다.** repost는 정본이 아니다(2026-11-08 P-01이 `STS/.../welcome.html`에서 얻은 교훈의 반대 방향 사례다 — 거기서는 repost가 **죽은 URL을 링크**했고, 여기서는 **낡은 제약**을 적는다).

### G-47 ⚠️⚠️ **SMS 문자 기반 MFA 지원 종료가 lifecycle 집계표에 없다**

공식 `id_credentials_mfa.html`이 Note로 **`AWS ended support for enabling SMS multi-factor authentication (MFA)`**라고 적고 대안으로 세 유형을 지목한다. 그런데 이 항목은 **공식 `AWS Lifecycle Changes` 134항목에 없고** 96 §7-2의 기능·에디션 28항목에도 없다. **G-16(「목록에 없다 ≠ 살아 있다」)이 그대로 재현됐다.**

⚠️ 공식 MFA 유형은 **셋**이다 — **패스키와 보안 키**(FIDO·피싱 저항) · **가상 인증자 애플리케이션**(TOTP) · **하드웨어 TOTP 토큰**. `기술 4.1.1`은 "다중 인증(MFA)"이라고만 적으므로 **종료된 유형을 현행 선택지로 착각하기 쉬운 자리**다. 저작 규율 가드로 고정했다(`scs_doc_format_test.dart`).

같은 계열로 함께 고정한 비자명한 사실 셋:

- ⚠️ **패스키·보안 키는 콘솔에서만 활성화**할 수 있다(CLI·API 불가)이고 활성화 전에 그 기기에 **물리적으로 접근**해야 한다
- ⚠️ **하드웨어 TOTP 토큰은 토큰 시드를 AWS와 안전하게 공유한 것만** 작동한다 — 다른 데서 산 토큰은 IAM에서 쓸 수 없다
- 한 사용자가 **최대 8개** 등록하고 로그인에는 **하나**면 된다. 추가 MFA를 켜거나 끄려면 **기존 MFA로 먼저 인증**해야 한다

### G-48 ⚠️⚠️ 공식 내부 어긋남 — 권한 경계와 리소스 기반 정책

같은 사실을 세 페이지가 다른 해상도로 적는다.

| 페이지 | 서술 |
|---|---|
| `troubleshoot_access-denied.html` | **거친 요약** — "Resource-based policies are **not** limited by permissions boundaries" |
| `access_policies.html` | **정밀** — `Principal`에 **역할 세션이나 사용자**를 적으면 권한 경계의 **명시적 허용이 필요하지 않고**, **역할 ARN**을 적으면 **필요하다** |
| `access_policies_boundaries.html` | **정밀** — 같은 구분을 **IAM 사용자 / 역할 ARN / 역할 세션 ARN / STS 연동 사용자 세션** 네 경우로 나눠 적는다 |

처리는 **G-03의 판정을 그대로 적용**해 **더 구체적인 쪽을 정본**으로 삼는 것이고, 추가로 **학습문서에 그 어긋남을 인용 블록으로 명시**했다(**D-15**) — 학습자가 다른 공식 페이지를 읽고 혼동할 자리이기 때문이다. 문항으로는 **정밀한 쪽만** 쓴다.

⚠️ 어느 경우에도 **권한 경계의 명시적 거부는 유효하다.** 거친 요약만 외우면 "리소스 정책으로 주면 경계를 우회한다"로 읽힌다.

### G-49 ⚠️ 불완전 ARN — ID 기반 정책에서는 넓어지고 세션 정책에서는 실패한다

`reference_identifiers.html`이 적는다 — 불완전 ARN(표준 6필드보다 적은 것)은 ID 기반 정책에서 **자동으로 와일드카드가 채워져** `arn:aws:sqs`가 `arn:aws:sqs:*:*:*`가 되고 **전 리전·전 계정의 SQS 리소스**를 허용한다. **그런데 `AssumeRole`·`AssumeRoleWithWebIdentity`·`AssumeRoleWithSAML`에 넘기는 세션 정책은 불완전 ARN을 지원하지 않고** `MalformedPolicyDocumentException`을 돌려준다.

즉 **같은 문자열이 한쪽에서는 조용히 넓어지고 다른 쪽에서는 실패한다.** `기술 4.2.3`(최소 권한·세션 정책)의 좋은 출제 각도다.

함께 고정한 와일드카드 규칙: ⚠️⚠️ **`user/*`는 경로가 있는 사용자까지 매칭한다**(`user/John`과 `user/division_abc/subdivision_xyz/JaneDoe` 둘 다). `user/division_abc*`는 경로가 있는 쪽만 잡고, **`user/`·`group/`·`policy/` 부분에는 와일드카드를 쓸 수 없다**(`iam::123456789012:u*`는 불가).

### G-50 ⚠️⚠️ 미리 서명된 URL의 실제 만료는 「설정값」과 「자격 증명 수명」 중 먼저 오는 쪽

`using-presigned-url.html` §Who can create a presigned URL 가 자격 증명별로 적는다.

| 서명에 쓴 자격 증명 | 실제 수명 |
|---|---|
| **IAM 사용자**(SigV4) | 최대 **7일** |
| **IAM 역할 자격 증명** | **역할 세션이 끝날 때** — 더 긴 만료를 적어도 그렇다(`AssumeRole` 기본 **1시간**) |
| **EC2 인스턴스 프로파일** | 메타데이터 자격 증명 교체 주기, **약 6시간**이 최대 |
| **STS 임시 자격 증명** | 그 자격 증명의 수명만큼 |

⚠️ **자격 증명이 취소·삭제·비활성화되면 URL도 죽는다.** 콘솔은 **1분~12시간**, CLI·SDK는 **최대 7일**이다. ⚠️ 만료 판정은 **HTTP 요청 시점**이라 만료 직전에 시작한 큰 파일 다운로드는 **계속되지만** 끊겨서 재시작하면 실패한다.

제한 수단 둘 — **`s3:signatureAge`** 조건(버킷·액세스 포인트 정책)과 **네트워크 경로 제한**(퍼블릭 엔드포인트면 `aws:SourceIp`, VPC 엔드포인트 경유면 `aws:SourceVpc`·`aws:SourceVpce`).

### G-51 ⚠️ 권한 세트가 못 하는 것 — 작업 4.1과 4.2를 잇는 자리

`permissionsetsconcept.html`이 한계를 직접 적는다 — **사용자 지정 신뢰 정책 · 역할 태그 · 구성 가능한 역할 경로**가 필요하면 권한 세트로는 안 되고 **IAM의 「계정 액세스 관리자」**를 쓴다(이미 있는 IAM 역할을 Identity Center 사용자·그룹에 할당하고, 권한 세트와 **함께** 쓸 수도 있다).

⭐ **「구성 가능한 역할 경로」가 `기술 4.2.1`의 IAM 경로와 직접 이어진다** — 도메인 4의 두 작업이 한 문장에서 맞물리는 자리다.

⚠️ 그리고 **조직 인스턴스에 「다중 계정 권한」이 켜져 있어야** 권한 세트가 동작한다(기본은 켜짐, 꺼졌으면 설정 또는 `UpdateInstance` API).

### G-52 ⚠️ 서비스 소개 페이지에 상태가 없는 닫힌 기능 둘

`Simple AD`(MAINT 2026-06-30)와 `Cognito Sync`(MAINT 2026-06-30)는 96 §7-2가 이미 실측해 뒀지만, **`directoryservice/.../what_is.html`은 Simple AD를 세 디렉터리 유형 중 하나로 그대로 소개하고 상태를 적지 않는다**(해당 문구 0건). D-04-b의 「상태를 적는다」를 **저작 규율 가드**로 강제했다.

함께 고정한 Simple AD의 **미지원 목록**(공식 본문) — **MFA · 신뢰 관계 · DNS 동적 업데이트 · 스키마 확장 · LDAPS 통신 · PowerShell AD cmdlet · FSMO 역할 전송**이고 **RDS for SQL Server와 호환되지 않는다.** ⚠️ **AD Connector도 RDS for SQL Server와 호환되지 않는다**(프록시이고 기존 **RADIUS 기반 MFA 인프라**에 연결해 MFA를 켠다).

⚠️ **에디션 개수는 단정하지 않는다**(D-07 계열) — 본문은 `AWS Managed Microsoft AD`를 **Standard·Enterprise 둘**로 적는데 「Which to choose」 표에는 **`Hybrid Edition`**이 보인다. 둘 중 하나를 골라 단정하면 다른 쪽과 어긋난다.

### G-53 ⚠️ 방법론 — 가드 트리거를 **약어만으로** 쓰면 한국어 전체 이름이 비켜 간다

시뮬레이터·RCP 규칙을 처음 `RCP` 하나로 썼다. 그러면 **「리소스 제어 정책」으로 적은 줄이 조용히 비켜 간다** — 2026-11-06 AIF 「PT 필수」가 **「된」 한 글자**로 뚫린 것과 같은 계열이다. 트리거를 `RCP|리소스 제어 정책`으로 넓혔다.

⚠️⚠️ **그리고 그 가드가 정당한 줄 둘을 잡았다.**

1. **자가 점검 질문 지문** — "개발자가 시뮬레이터로 돌려 봤지만 전부 허용으로 나온다"는 **틀린 믿음을 제시**하고 바로 아래 정답이 그것을 정정한다. 문서의 단정이 아니다
2. **영문 원문 인용** — `RCP는 "does not support"입니다`

처리는 선례(2026-11-06 CLF·2026-11-08 SOA 배치)대로 **예외를 성질로 좁히고 그 예외가 모든 줄을 삼키지 않도록 예외 줄 수를 대조군으로 고정**(정확히 1줄)했고, 허용 서술에 `does not support`를 더했다. **문구를 바꿔 가드를 비켜 가지 않았다.**

### G-54 ℹ️ 도메인 4에서 **재지 않고 층 설명으로만 둔 것**

`기술 4.2.2`의 **ABAC 튜토리얼 페이지**(`tutorial_attribute-based-access-control.html`) · `기술 4.2.1`의 **크로스 계정 역할 생성 절차 페이지**(`id_roles_common-scenarios_aws-accounts.html`·`id_roles_common-scenarios_third-party.html`) · **Access Analyzer 사용자 지정 정책 검사의 검사 종류** · **Cedar 정책 문법**. 네 URL은 **실재를 확인했지만 본문을 읽지 않았다**(2026-11-09 `200 r=0`).

⏳ 그것들을 묻는 문항을 만들려면 전용 페이지를 먼저 읽어야 한다 — 특히 ABAC 튜토리얼의 **구체적 태그 설계 단계**와 **사용자 지정 정책 검사가 제공하는 검사 종류·API 이름**이다. ⚠️ 그 API 이름은 이 배치에서 재지 않았으므로 **여기에도 적지 않는다**(기억에 있는 이름을 적으면 그것이 다음 세션에 근거처럼 읽힌다).

## 2026-11-09 도메인 5 저작 배치에서 새로 세운 것

### G-55 ⚠️⚠️ **G-29 다섯 번째 적용 — `기술 5.2.2`가 드는 「S3 Glacier 저장소 잠금」은 닫힌 서비스의 기능이다**

이 트랙에서 **가장 날카로운 G-29 사례**다. 공식 가이드가 데이터 무결성 수단으로 **"S3 Glacier 저장소 잠금"**을 드는데, **금고(vault)와 저장소 잠금은 「원래의 독립 Amazon Glacier 서비스」**(2012년 REST API, 금고 기반)의 것이고 **그 서비스는 신규 고객을 받지 않는다.**

⭐ **상태가 문서에 있다** — Glacier 개발자 안내서의 **모든 페이지**가 머리에 `This page is only for existing customers of the Amazon Glacier service using Vaults and the original REST API from 2012.` 를 달고, **기존 데이터는 무기한 안전하며 마이그레이션이 필요하지 않다**고 적는다. 이 점이 **Simple AD(G-52)와 반대**다 — 거기서는 서비스 페이지가 상태를 적지 않았다.

⚠️⚠️ **S3 Glacier 스토리지 클래스는 정상이다**(Instant Retrieval · Flexible Retrieval · Deep Archive). 닫힌 것은 **금고 기반 독립 서비스**이므로 저작 규율 가드의 트리거를 **`Glacier` 전체가 아니라 「저장소 잠금 / Vault Lock」**으로 좁혔다. 둘을 섞으면 **정상인 스토리지 클래스까지 닫힌 것으로** 가르친다.

⚠️ **날짜는 공식 안에서 갈린다**(G-17 계열) — `aws.amazon.com/about-aws/whats-new/2025/10/aws-service-availability/` 는 `Amazon Glacier` 를 **2025-11-07부터 유지 관리**로 적고, `aws.amazon.com/s3/glacier/pricing/` 는 **2025-12-15부터 신규 고객을 받지 않는다**고 적는다. **그래서 학습문서에 날짜를 단정하지 않고 「신규 고객에게 열려 있지 않다」까지만** 적었다.

⚠️ 새 설계에서 WORM 이 필요하면 **S3 Object Lock 준수 모드**가 그 자리다(루트 사용자도 못 지운다).

### G-56 ✅ `G-28` 해소 — 민감 데이터 마스킹의 축과 닫힌 예시

`기술 5.3.4`가 **CloudWatch Logs 데이터 보호 정책**과 **Amazon SNS 메시지 데이터 보호** 둘을 예시로 드는데, **후자는 그 문서 자신이** 머리에 Important 로 **`Amazon SNS message data protection is no longer available to new customers.`** 를 적는다. **축은 CloudWatch Logs 쪽**이고 SNS 는 **상태를 적어** 다룬다(D-04-b).

**CloudWatch Logs 쪽 실측(AIF 트랙이 먼저 찾은 비소급 성질을 포함):**

- ⚠️⚠️ **수집 시점에 탐지·마스킹하고 정책 설정 전에 수집된 로그 이벤트는 마스킹되지 않는다**(공식 Important). **보존 가드**로 고정했다 — 금지가 아니라 **참인 문장이 사라지는 것**을 막는 쪽이다(2026-11-06 AIF 배치에서 처음 쓴 종류)
- **기본적으로 모든 유출 지점에서 마스킹**된다 — **Logs Insights · 지표 필터 · 구독 필터** 포함. 해제는 **`logs:Unmask`** 권한
- **계정 전체 정책과 로그 그룹 정책이 함께 적용**되고 **양쪽의 관리형 데이터 식별자가 모두** 감사·마스킹된다. 로그 그룹 수준 정책은 **로그 그룹당 하나**, 정책 한도 **30,720자**
- **Standard 와 Essentials(옛 Infrequent Access) 로그 클래스 모두** 지원 · 탐지는 **패턴 매칭 + 기계 학습** · 일부 식별자는 **근처 키워드**가 함께 필요 · 탐지 시 **`LogEventsWithFindings`** 지표 발행

**SNS 쪽(기존 고객 환경·비교 보기용):** 작업이 **audit · de-identify · deny** 셋이고 **주제당 정책 하나**이며 ⚠️ **de-identify·deny 문장은 여럿, audit 문장은 하나**다. 문장마다 **인바운드(주제)·아웃바운드(구독)** 방향과 적용 계정·보안 주체를 정한다.

### G-57 ⚠️ `AWS DataSync Discovery` 지원 종료 — 서비스가 아니라 기능이다

`기술 5.2.4`가 **AWS DataSync** 를 예시로 드는데 **Discovery 기능만** 2025-05-20 지원 종료다(96 §7-2). **DataSync 자체는 정상**이므로 **기능 단위로 갈라** 적고 전수 집계 가드로 고정했다. 「온프레미스 스토리지를 분석해 추천을 받는다」는 선택지가 지금 성립하지 않는다.

### G-58 ⚠️⚠️ 공식 내부 어긋남 — S3 서버 측 암호화 선택지의 **개수**

`AmazonS3/latest/userguide/serv-side-encryption.html` 본문은 **"four mutually exclusive options"** 라고 적는데 **같은 페이지의 소제목은 다섯**이다 — SSE-S3 · SSE-KMS · DSSE-KMS · SSE-C · **SSE-FSX**. **개수를 단정하지 않는다**(D-07·D-10 계열 → **D-16**).

고정할 축은 **각 선택지가 무엇을 바꾸는가**와 **지정할 수 있는 자리**다 — `PUT` 요청으로 지정 가능한 것은 **SSE-KMS·DSSE-KMS·SSE-C**이고 **기본 암호화 구성으로 설정 가능한 것은 SSE-KMS·DSSE-KMS**뿐이다(SSE-C 는 버킷 기본값이 될 수 없다).

### G-59 ⚠️⚠️ 공식 내부 어긋남 — VPC 엔드포인트 **유형 목록**

`vpc/latest/privatelink/concepts.html` 은 유형을 **`Interface` · `GatewayLoadBalancer` · `Resource` · `Tunnel` · `Service network`**(+ PrivateLink 를 쓰지 않는 `Gateway`)로 적는데, **PrivateLink FAQ 는 `Tunnel` 을 들지 않고 "five different types"** 로 적는다. **개수를 단정하지 않는다**(→ **D-16**).

고정할 축은 **"게이트웨이 엔드포인트만 PrivateLink 를 쓰지 않고 S3·DynamoDB 전용이며 라우팅 테이블 항목을 더한다"**다. ⚠️ `Tunnel` 엔드포인트는 **GENEVE 캡슐화**가 필요하고 `Resource` 엔드포인트는 **로드 밸런서가 필요하지 않다**.

### G-60 ⚠️⚠️ 최근 바뀐 기본값 둘 — 교재가 가장 빨리 낡는 자리

| 변경 | 내용 |
| --- | --- |
| **2023-01-05** | **모든 새 객체 업로드가 SSE-S3 로 자동 암호화**된다(추가 비용·성능 영향 없음). 상태는 **CloudTrail · S3 Inventory · S3 Storage Lens · 콘솔 · API 응답 헤더**에서 보인다 |
| **2026년 4월** | ⚠️⚠️ **모든 새 범용 버킷에서 SSE-C 가 모든 새 쓰기 요청에 대해 비활성화**된다. **SSE-C 로 암호화된 객체가 없는 기존 버킷**도 같은 조치를 받았다. 쓰려면 **버킷 생성 후 `PutBucketEncryption`** 으로 의도적으로 활성화해야 한다 |

즉 **"S3 는 기본적으로 암호화되지 않으므로 기본 암호화를 켜라"**와 **"SSE-C 는 아무 버킷에서나 쓸 수 있다"**가 **둘 다 지금은 거짓**이다.

⚠️ 함께 고정한 사실 — **기본 암호화 구성을 바꿔도 기존 객체의 암호화 유형은 바뀌지 않는다**(소급은 **S3 Batch Operations + S3 Inventory** 의 Copy). 이 「설정을 바꿔도 기존 것은 그대로」 모양이 도메인 5에 **셋** 있다(S3 기본 암호화 · CloudWatch Logs 데이터 보호 정책 · **KMS 키 회전**은 데이터를 재암호화하지 않는다).

### G-61 ⚠️⚠️ ALB 기본 보안 정책이 **생성 경로마다 다르다**

`describe-ssl-policies.html` 이 적는다 — **콘솔**은 `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09`, **그 밖의 방법(AWS CLI · CloudFormation · AWS CDK)**은 **`ELBSecurityPolicy-2016-08`**이 기본값이다. **IaC 로 배포하는 조직이 그대로 밟는 함정**이고 그 정책은 TLS 1.0·1.1을 포함한다.

함께 고정한 비자명한 사실:

- ⚠️ **ALB 는 사용자 지정 보안 정책을 지원하지 않는다**
- ⚠️⚠️ **백엔드 연결의 보안 정책은 고를 수 없다** — 리스너 정책의 **종류**에 따라 자동으로 정해진다(일반 TLS 정책이면 백엔드는 `ELBSecurityPolicy-2016-08`). "리스너를 1.2로 묶었으니 전 구간 1.2"가 거짓이 되는 자리다
- **`PQ` 정책은 하이브리드 포스트 양자 키 교환**이고 **클라이언트가 ML-KEM 을 지원해야** 쓰인다(`SecP256r1MLKEM768`·`SecP384r1MLKEM1024`·`X25519MLKEM768`). 공식 권고 출발점은 `...Res-PQ-2025-09`(또는 FIPS 판)
- **`RFC9151`(CNSA 1.0)** 정책군에 **엄격**과 **`INTEROP`** 변형이 있고 권고 출발점은 `...RFC9151-INTEROP4-FIPS-2023-07`
- ⚠️ **ELB 조건 키를 IAM·SCP 에 써서** 계정·조직에서 쓸 수 있는 보안 정책을 제한할 수 있다(도메인 6과 이어진다)
- **0-RTT 와 `early_data` 는 구현되지 않았고** TLS 재개는 **같은 ALB IP 주소** 연결에서만 동작한다

### G-62 ⚠️⚠️ 전송 중 암호화 **계층 넷**을 섞으면 어느 쪽이든 거짓이 된다

| 계층 | 보장 | 조건 |
| --- | --- | --- |
| **물리 계층** | 리전 간 트래픽이 **AWS 보안 시설을 떠나기 전 자동 암호화**되고 **AZ 간 모든 트래픽이 암호화**된다 | 없음 |
| **피어링 벌크** | **VPC 피어링·TGW 피어링의 교차 리전 트래픽**이 리전을 나갈 때 자동 벌크 암호화 | 교차 리전 |
| **Nitro 인스턴스 간** | **AEAD·256비트**, 네트워크 성능 영향 없음 | ⚠️ **지원 인스턴스 유형 · 같은 리전 · 같은 VPC 또는 피어링된 VPC** |
| **애플리케이션 TLS** | 종단 간 인증·무결성 | 내가 구성 |

⚠️⚠️ **중간 홉(Transit Gateway·로드 밸런서)이 끼면 Nitro 계층은 깨진다**(EKS 모범 사례 가이드: `the traffic is not encrypted`). **그런데 그것이 「평문」이라는 뜻은 아니다** — AZ·리전 경계에서는 물리·벌크 계층의 보장이 남는다. **두 사실을 하나로 합치면 어느 쪽이든 거짓이 된다.**

⚠️ **지원 인스턴스 유형 목록은 길고 늘어난다** — 외우지 않고 공식 문서의 **AWS CLI 조회 절차**를 기억한다.

### G-63 ⚠️ 방법론 — 저작 직후 구조를 기계로 세는 것이 두 번째로 값을 했다

2026-11-09 도메인 4 배치에서 **긴 md 가 Write 도중 잘렸고** 그 뒤로 **저작 직후 구조 단정**을 규율로 삼았다. 이 배치에서 그 단정이 **`scs-t5-3` 의 「시험 직전 요약」 불릿이 11개(상한 10)**인 것을 **가드를 돌리기 전에** 잡았다. 잘림은 없었다.

⚠️ 구조 검사에 넣을 항목이 굳었다 — **자가 점검 질문 수 == 접이식 열림 == 닫힘 · 학습 목표 ≤ 8 · 요약 불릿 1~10 · 프런트매터 `url:` ↔ 「출처」 절 백틱 경로 대조 · 마크다운 인라인 링크 0 · 단일 이탤릭 0 · CRLF 불변식.**

### G-64 ℹ️ 도메인 5에서 **재지 않고 층 설명으로만 둔 것**

**EBS 스냅샷 잠금의 하위 주제**(모드·기간 상세·접근 통제·모니터링) · **S3 수명 주기 구성 요소 페이지**(`Lifecycle configuration elements`·충돌 처리) · **EFS Intelligent-Tiering 전용 페이지** · **AWS Backup Vault Lock 전용 페이지**와 **다자 승인 전용 페이지** · **AWS Signer 개발자 안내서** · **FSx for Lustre 데이터 리포지토리 연결 페이지**.

⏳ 그것들을 묻는 문항을 만들려면 전용 페이지를 먼저 읽어야 한다 — 특히 **스냅샷 잠금의 거버넌스 모드 해제 권한**과 **Vault Lock 의 유예 기간(cooling-off)** 숫자다. ⚠️ 이 배치에서는 **숫자를 적지 않았다.**

### G-65 ✅ **`G-24` 해소 — 공식이 이제 정책 범주 표를 직접 싣는다**

도메인 6 착수 선결 ①이었다. `94 §3-3`은 "선언적 정책 페이지의 **하위 주제 배치**"만 근거로 삼아 **분류를 단정하지 않는다**로 닫아 뒀는데, 2026-11-09 실측하니 **공식이 두 곳에서 분류를 명시한다.**

1. `orgs_manage_policies.html`이 정책을 **두 범주**로 나눈다 — **권한 부여 정책**(SCP·RCP)과 **선언적 정책**(EC2·백업·태그·채팅 애플리케이션·**AI 서비스 옵트아웃**·Security Hub·Inspector·Bedrock·업그레이드 롤아웃·S3·GuardDuty). 같은 페이지의 요약 표에 **`Policy category` 열**이 있고 `AI services opt-out policy` 행의 값이 **`Declarative`**다.
2. `orgs_manage_policies_declarative_policies.html`이 **SCP / RCP / 선언적 정책의 3열 비교표**를 싣는다.

⚠️ 그래서 **「SCP로 AI 서비스 데이터 사용을 옵트아웃한다」가 거짓**이라는 판정은 그대로 유효하고, 근거가 **배치**에서 **범주 선언**으로 강해졌다. 다만 **유형의 개수는 여전히 묻지 않는다**(G-66).

⭐ 그리고 이 비교표가 도메인 6의 중심 비대칭 셋을 준다 — **관리 계정 영향** / **서비스 연결 역할 통제** / **OU·계정의 유효 정책 보기**가 모두 **SCP 아니오 · RCP 아니오 · 선언적 예**다. 첨부 한도도 다르다(SCP 10개·10,240자 / RCP **5개·5,120자** / 선언적 10개·10,000자 / AI 옵트아웃 **5개·2,500자**).

### G-66 ⚠️⚠️ 공식 내부 어긋남 — 선언적 정책 **유형 목록이 세 곳에서 다르다**

| 출처 | 목록 |
|---|---|
| 선언적 정책 전용 페이지의 `Topics` | EC2 · 백업 · 태그 · 채팅 애플리케이션 · AI 서비스 옵트아웃 · Security Hub · Bedrock · Inspector · 업그레이드 롤아웃 · S3 · **Shield Network Security Director** · GuardDuty |
| `orgs_manage_policies.html` 불릿 | 위 목록에서 **Shield Network Security Director 없음** |
| 같은 페이지의 요약 표 | **Shield·GuardDuty 행 없음** |

→ **개수를 단정하지 않는다**(D-07·D-10·D-16 계열의 추가 자리). 유형은 계속 늘어나는 값이다.

### G-67 ⚠️⚠️ **두 「사전」을 섞으면 어느 쪽이든 거짓이 된다** — 이 도메인에서 가장 날카로운 자리

| 축 | Control Tower **사전 제어** | AWS Config **사전 평가** |
|---|---|---|
| 막는가 | **막는다** — `Resources that are not compliant will not be provisioned.` | ⚠️⚠️ **막지 않는다** — `Proactive rules do not remediate resources that are flagged as NON_COMPLIANT or prevent them from being deployed.` |
| 구현 | **`preCreate`·`preUpdate` 후크 핸들러** | 규칙의 `EvaluationModes`에 `PROACTIVE` |
| 경로 범위 | ⚠️ **CloudFormation 한정** — `these controls may not affect requests that are made directly to services through the AWS console, through AWS APIs, or through other means such as AWS SDKs, or other Infrastructure-as-Code (IaC) tools.` | 평가만 하므로 경로 개념이 없다 |
| 확인 수단 | 제어 상태 `PASS`/`FAIL`/`SKIP` | `StartResourceEvaluation`·`GetResourceEvaluationSummary` |

⚠️ 사전 제어의 한계는 셋이다 — **경로** · **보안 문자열·보안 암호가 후크로 가기 전에 해결되지 않아 평가되지 않음** · **후크 미지원 리전**(prescriptive guidance). 가드 2건으로 고정했다(`사전 평가`→`막지 않`, `사전 제어`→`preCreate`).

⚠️⚠️ **가드가 실제 결함을 잡았다** — `scs-t6-3`이 교차 참조 네 곳 중 **두 곳에서 한정 없이** 「사전 제어는 비준수 리소스를 프로비저닝하지 않습니다」로 단정하고 있었다. **요구 토큰을 `우회`로 두면 안 된다** — `기술 6.1.5`의 **비상용 우회 절차**가 같은 문서에 있어 엉뚱한 이유로 통과한다. 공식 핸들러 이름으로 고정했다.

### G-68 ⚠️⚠️ 교재가 가장 빨리 낡는 자리 둘 — 예방 제어의 구현 수단과 랜딩 존 4.0

- **예방 제어 = SCP** 가 아니다. 공식은 지금 **SCP · RCP · 선언적 정책 셋**을 적고, 그래서 Control Tower가 **그 셋을 매일 스캔**한다. 옛 교재는 SCP 하나만 적는다.
- ⚠️⚠️ **랜딩 존 버전 4.0부터 필수 제어가 기본 적용되지 않는다**(`Starting with AWS Control Tower Landing Zone version 4.0, mandatory controls are no longer applied by default.`). "필수니까 켜져 있다"는 전제가 **버전에 달렸다**.
- 동작별 적용 범위도 다르다 — **예방은 모든 리전**, **탐지는 Control Tower 지원 리전만**. 상태값도 다르다(`enforced`/`not enabled` · `clear`/`in violation`/`not enabled` · `PASS`/`FAIL`/`SKIP`).
- ⚠️ **필수 제어 일부는 여러 작업을 수행하는 단일 SCP**로 구현돼 제어 참조에서 **같은 SCP가 여러 제어 아래 반복해** 보인다.

### G-69 ⚠️⚠️ **OU를 옮기면 이전 OU의 제어가 제거되지 않는다**

공식 드리프트 문서의 Note다. 대상 OU에서 새 **후크 기반** 제어를 켜면 **옛 후크 기반 제어만** 교체되고, **SCP와 AWS Config 규칙으로 구현된 제어는 계정이 OU를 바꿀 때 항상 수동으로 제거**해야 한다. 즉 OU 이동은 거버넌스 이관의 절반이다.

⚠️ 드리프트 알림의 함정도 같은 페이지에 있다 — **설정에서 계정 자동 등록을 켜면 SNS 드리프트 알림을 쓸 수 없고**, 같은 드리프트는 **중복 제거**돼 첫 번째만 온다(해소 후 재발하면 다시 온다). 멤버 계정 드리프트는 **감사 계정에 집계**되고 토픽 예가 `aws-controltower-AggregateSecurityNotifications`다. 그리고 일일 스캔이 **관리 계정으로** Organizations를 호출하므로 **내 TPS 한도에 계산된다**.

### G-70 ⚠️⚠️ 루트 특권 세션의 한계가 API 참조에 수치로 있다

`STS/latest/APIReference/API_AssumeRoot.html` 실측(2026-11-09) —

- **`DurationSeconds`: 0~900초(15분), 기본 900.** 더 큰 값을 지정하면 **작업이 실패**한다
- **`TaskPolicyArn` 필수**이고 **다섯 관리형 정책 중 하나**여야 한다 — `IAMAuditRootUserCredentials` · `IAMCreateRootUserPassword` · `IAMDeleteRootUserCredentials` · `S3UnlockBucketPolicy` · `SQSUnlockQueuePolicy`
- **`TargetPrincipal` 필수**, `MinimumSessionTokenSize`는 **4,096바이트 상한**

⚠️⚠️ 중앙 집중화는 **기능이 둘**이고 비대칭이다 — **「루트 자격 증명 관리」만 켜고 삭제하면 멤버 계정이 복구할 수 없다.** 복구를 허용하려면 **「멤버 계정의 특권 루트 작업」도** 켜야 한다. 제거 대상은 **암호·액세스 키·서명 인증서·MFA 비활성화** 넷이고, **Organizations에서 새로 만드는 계정은 기본적으로 루트 자격 증명이 없다**. 위임 관리자 등록은 서비스 주체 **`iam.amazonaws.com`**으로 한다.

⚠️ 비상용 우회 절차의 공식 근거는 **`SEC03-BP03 Establish emergency access process`**다 — 형태는 **비상용 교차 계정 역할 + 검증·승인 절차**이고 안티패턴 둘은 **비상 프로세스 부재**와 **장기 상승 권한 부여**, 위험 수준은 **중간(Medium)**이다. ⚠️ URL은 `wellarchitected/latest/framework/...`가 살아 있다(검색이 돌려준 `2023-04-10` 스냅샷을 쓰지 않았다).

### G-71 ⚠️ **G-29 여섯 번째 적용 — 도메인 6에서 닫힌 것 둘**

| 이름 | 상태 | 어디서 드는가 |
|---|---|---|
| **AWS Audit Manager** | **신규 고객에게 열려 있지 않다**(사용자 안내서 머리의 배너. 2026-04-30 유지 관리, 공식 lifecycle 목록에도 있다) | 공식 `기술 6.3.2`의 **예시** |
| **AWS Service Catalog AppRegistry** | **2026-07-30부터 신규 고객 차단** | `기술 6.2.4`가 드는 **Service Catalog의 한 기능** |

⚠️ **트리거를 서비스 전체로 두지 않았다** — `Service Catalog` 본체는 정상이고(Control Tower의 Account Factory가 그 위에 올라간다) 닫힌 것은 **AppRegistry 기능**뿐이다. 도메인 5의 **S3 Glacier 저장소 잠금 ↔ 스토리지 클래스**와 같은 판정이다.

⚠️ 그리고 **Audit Manager는 증거를 모으지만 준수 자체를 평가하지 않는다**(공식 Note)는 사실이 상태와 별개로 중요하다 — "켜면 준수 여부를 판정해 준다"는 거짓이다.

### G-72 ⚠️⚠️ **Well-Architected가 두 서비스로 갈렸다** — D-09와 같은 계열

공식 `기술 6.3.3`은 「AWS Well-Architected Framework 도구」 **하나**를 드는데 `wellarchitected/latest/userguide/well-architected.html`(최종 갱신 **2026-10-01**)은 **둘을 표로 가른다**.

| 축 | **Well-Architected Tool** | **Well-Architected Agent** |
|---|---|---|
| 접근 | 수동·안내형 자가 검토 | **AI 기반 자동 분석**(배포된 리소스 + IaC 템플릿) |
| 주 엔티티 | **워크로드** | **프로필**(계정·리전·원칙·목표) |
| 출력 | **HRI·MRI**와 개선 계획 | 우선순위 권장 사항 + 절충 분석 + 자동화 스크립트 + 갱신된 IaC |
| 상태 | 일반 사용 | ⚠️⚠️ **프리뷰 릴리스**(`is in preview release and is subject to change`) |

→ **묻는 쪽은 Tool**이다. 가드 1건(`Well-Architected Agent` → `프리뷰`)으로 고정했고 저작 결정은 **D-17**이다. ⚠️ 트리거를 `Well-Architected` 전체로 두지 않았다 — **프레임워크·렌즈** 언급은 정당하다.

⚠️ 옛 슬러그 둘이 모두 이 페이지로 리다이렉트된다 — `userguide/intro.html`(이미 `source_url_retired_test`에 등재)과 `userguide/what-is-wellarchitected-tool.html`. 그래서 출처는 **`well-architected.html`** 하나로 뒀다.

### G-73 ⚠️ 작업 6.2·6.3의 비자명한 사실 묶음

- ⚠️⚠️ **`cfn-lint`는 기본적으로 `us-east-1` 스키마로 검사**하고(`--regions`로 변경) **SAM 변환을 먼저 적용한 뒤** 검사한다. **Guard는 템플릿 외에 변경 세트와 AWS Config 구성 항목도** 검사한다. **둘 다 로컬 검증**이고 공식이 두 페이지에서 똑같이 한계를 따로 안내한다
- ⚠️ **StackSet은 리전 리소스**다. **템플릿 업데이트는 항상 모든 스택에 영향**을 주고(선택적 불가), **스택 인스턴스는 스택 없이 존재**할 수 있고, **StackSet은 스택 인스턴스가 없을 때만 삭제**된다(`Retain Stacks`로 스택을 남긴다). 백분율은 **내림**이고 `Strict Failure Tolerance`에서 **최대 동시 계정 ≤ 실패 허용 + 1**, **실패 허용은 리전별**이다. 서비스 관리형의 관리자 계정은 **관리 계정 또는 위임된 관리자**다
- ⚠️⚠️ **태그 정책은 태그되지 않은 리소스와 정책에 정의되지 않은 태그를 평가하지 않는다** — "태그 없는 생성을 막는다"는 거짓이고 그것은 `aws:RequestTag`·`aws:TagKeys` 조건 키의 몫이다. 정책 관리는 **Organizations**, 준수 확인은 **Resource Groups**로 나뉘고, **TagOption은 AWS 태그가 아니라 태그를 만드는 템플릿**이며, 공식이 Important로 **태그에 PII를 넣지 말라**고 적는다. 키·값은 **모두 대소문자 구분**이지만 **IAM 리소스는 대소문자만 다른 키를 막는 추가 검증**이 있다
- ⚠️⚠️ **Firewall Manager는 AWS Config를 켜야 동작**하고(전제 조건 3단계) **Network Firewall·DNS Firewall 정책은 RAM 리소스 공유 활성화**가 필요하다. **요금은 기반 서비스**(WAF·Config)에 붙는다. 관리 범위 조건은 **계정·OU / 리전 / 정책 유형** 셋이고 **기본 관리자만 3자 방화벽을 관리하고 전체 범위**를 갖는다. 관리자 계정을 만들면 서비스가 **Organizations에 위임 관리자 등록 여부를 확인하고 아니면 설정**한다
- ⚠️⚠️ **Config 애그리게이터는 읽기 전용 뷰**다 — **규칙을 배포하거나 스냅샷을 푸시할 수 없고**, **추가 비용이 없으며**, **Organizations 소스면 권한 부여가 필요 없다**
- ⚠️ **Config 수정은 SSM Automation 문서**가 수행한다. 평가 결과는 **`COMPLIANT`·`NON_COMPLIANT`·`ERROR`·`NOT_APPLICABLE`** 넷이고 **`NOT_APPLICABLE`을 「준수」로 읽으면 안 된다**(공식 예: `alb-desync-mode-check`는 ALB만 보고 NLB·GWLB를 무시한다). 트리거는 **구성 변경·주기적·하이브리드** 셋이고 범위는 **리소스 유형 / 유형+ID / 태그 키와 값 / 기록되는 모든 리소스** 넷으로 정한다. **적합성 팩은 규칙과 수정 작업을 함께** 담고 **SSM 문서로 저장·배포**할 수 있다
- ⚠️ **RAM과 리소스 기반 정책의 차이는 「가시성」이다** — RAM 공유는 **상대의 원래 서비스 콘솔·API에 네이티브처럼 보이고** 리소스 기반 정책 공유는 **ARN으로 명시 참조**해야 한다. 이미 정책으로 공유한 것은 **`PromoteResourceShareCreatedFromPolicy`**로 승격한다. **조직 밖 계정은 초대 수락**이 필요하고 **조직 내 공유 활성화 후에는 불필요**하다. 하나의 리소스 공유에는 **리전 리소스만** 담는다
- ⚠️ **Artifact는 AWS 쪽 문서**를 주고 **무료**이며, 고객 문서 확보는 **고객 책임**이다(공식 Note). **Security Hub CSPM**은 결과를 **ASFF**로 처리하고 **교차 리전 집계**와 **자동화 규칙**을 갖는다

### G-74 ⚠️ 방법론 셋 — 실측에서 배운 것

**① `exam_guides/SCS-C03.json`의 `domains[].no`는 `int`다.** 문자열로 비교해 추출하면 **조용히 0바이트**가 나온다(실제로 그랬다). **`assert hit == 1`이 없으면 빈 결과를 「도메인 6이 없다」로 오독한다.** 구조 필드의 타입은 쓰기 전에 한 번 찍어 본다.

**② 레드 수는 「편수 × 5 + 신규 집계 수」와 다르다.** 테스트 **수**의 증가는 예측대로 **20**(편별 4 × 3 + 신규 집계 5 + 파서 자동 3 = 3,309 → **3,329**)인데 **레드는 19**였다 — `scsTaskIds`를 순회하며 **`existsSync` 없이 파일을 읽는 기존 집계 테스트 2건**(「시험 형식은 `scs-t1-1`에만」·「Security Hub를 CSPM과 갈라 쓴다」)이 함께 레드가 되고 파일이 생기면 녹색으로 돌아온다. 도메인 3·4·5 그룹은 `docOf`(`existsSync`)를 쓰므로 깨지지 않는다.

**③ 죽은 슬러그 6건을 실측에서 만났다**(레포에는 0건이라 가드 추가 불필요) — `IAM/latest/UserGuide/id_root-user-access-management.html` → `introduction.html` · `AWSCloudFormation/latest/UserGuide/validation-scope.html` → `Welcome.html` · `controltower/latest/controlreference/custom-controls.html` → `introduction.html` · `config/latest/developerguide/cpch-process-checks.html` → `WhatIsConfig.html` · `waf/latest/developerguide/fms-policies.html` → `what-is-aws-waf.html` · `organizations/latest/userguide/services-that-can-integrate.html` → `orgs_introduction.html`. ⚠️ **전부 「목차·링크 텍스트에서 슬러그를 유도」한 것들이다**(G-26·G-43의 재현).

### G-75 ℹ️ 도메인 6에서 **재지 않고 층 설명으로만 둔 것**

**Control Tower 사용자 지정 제어 전용 페이지**(`custom-controls.html`은 죽은 슬러그이고 Control Catalog `GetControl`·`ListControls` API가 입구다) · **적합성 팩의 「프로세스 검사」 전용 페이지**(슬러그 미확인) · **조직 Config 규칙 전용 페이지** · **StackSets 대상 계정 게이트·동시성 모드 전용 페이지** · **Firewall Manager 정책 유형별 페이지** · **RAM 고객 관리형 권한** · **Well-Architected Tool 전용 what-is 페이지**(현재 `well-architected.html`로 합쳐져 보인다).

⏳ 그것들을 묻는 문항을 만들려면 전용 페이지를 먼저 읽어야 한다 — 특히 **사용자 지정 제어의 구현 수단**과 **대상 계정 게이트의 평가 시점**이다. ⚠️ 이 배치에서는 **그 수치·절차를 적지 않았다.**

### G-76 ⚠️⚠️⚠️ **D-11 위반을 내 문서에서 찾았다 — 자격증별 표기 규율은 「표기 메모」만으로 지켜지지 않는다**

**무엇이 있었나:** 2026-11-09 도메인 6 배치가 `scs-t6-3`에 `Conformance Packs`를 **「적합성 팩」으로 15개소**(본문 14 + 프런트매터 `title:` 1) 썼다. 그 표기는 **AWS Config 한국어 개발자 안내서(기계 번역 고지 있음)**의 것이고 **SCS 공식 시험 가이드 표기는 「준수 팩」**이다(가이드 JSON 실측: 「준수 팩」 **1건** · 「적합성 팩」 **0건**).

⭐ **가장 나쁜 점은 자기모순이었다** — 같은 레포의 `scs-t1-1.md:251`이 **표기 메모**로 학습자에게 이렇게 선언해 둔 상태였다:

> 한국어 표기가 세 가지로 갈려 있습니다: SCS 공식 시험 가이드는 **「준수 팩」**, SOA 공식 시험 가이드는 「규정 준수 팩」, AWS Config 한국어 제품 문서(기계 번역)는 「적합성 팩」입니다. **이 사이트의 SCS 문서는 SCS 가이드 표기를 따라 「준수 팩」으로 적습니다.**

즉 **도메인 1을 읽은 학습자가 도메인 6에서 그 선언이 지켜지지 않은 것을 본다.** 2026-10-29 SOA 전파 가드가 「적합성 팩」을 **구식으로 판정해 13개소를 정정**한 것과 같은 계열이다.

**어떻게 찾았나:** 가드가 아니라 **인계 문서를 쓰다가** 찾았다. `D-11`을 인용해 「이 배치는 Config 문서 표기를 따랐으니 나중에 재확인한다」고 **합리화하는 문장을 쓰려는 순간** 그 문장이 D-11을 정면으로 거스른다는 것이 드러났다. ⚠️ **합리화를 문서에 적으려 할 때가 결함 신호다.**

**처리:**
1. 15개소를 **바이너리 모드 치환 + 횟수 단정**으로 「준수 팩」으로 바꿨다(영문 `Conformance Pack` 병기 2개소는 유지 — D-11이 요구하는 것이다)
2. **md 프런트매터 `title:`과 `content_index.dart`의 `ContentEntry` title을 함께** 고쳤다 — ⚠️ **둘을 묶는 동기화 테스트가 SCS에는 없다**(MLA·AIF 판만 있다). 어긋나도 아무도 알려 주지 않는다
3. **전수 가드 1건 신설** — 「적합성 팩」은 **표기 메모 줄에서만** 허용하고 **그 예외가 정확히 한 줄**임을 대조군으로 고정하며, **정본 표기를 쓴 문서 ≥1**로 비공허성을 확보한다

⚠️⚠️ **치환 단정이 또 한 번 사고를 막았다.** 1차 스크립트가 파일을 **텍스트 모드**(`open(p, encoding='utf-8')`)로 읽었는데 파이썬의 유니버설 개행이 **CRLF를 LF로 접는다**. 그대로 썼으면 **파일 전체 줄 끝이 바뀌어 리뷰 불가 diff**가 됐다. **CRLF 불변식 단정이 쓰기 전에 막았고** 바이너리 모드로 고쳤다 — 레포의 「문항 JSON은 json 왕복 금지, 바이트 블록 치환 + 횟수 단정」 규율이 **md에도 그대로 적용된다**.

⚠️ **교훈:** 표기 규율은 **그 규율을 설명하는 메모를 쓰는 것으로 지켜지지 않는다.** 메모는 학습자에게 알리는 장치이고, **지키는 것은 전수 가드**다. 자격증별로 갈리는 표기는 **처음 쓰는 배치에서 바로 가드를 세운다**(D-11을 세운 2026-11-08 배치에서 가드를 함께 세웠다면 이 결함은 레드로 먼저 드러났다).

### G-77 ⚠️⚠️ **SCS 가이드 JSON은 `knowledge`가 비어 있고 기술이 `skills`에 있다 — AIF와 반대 구조다**

2026-11-09 Phase 3 선결(문항 저작 전 게이트 인프라)에서 실측한 것이고, **AIF 판 가드를 그대로 베끼면 조용히 공허해지는 자리**다.

| 자격증 | `task['knowledge']` | `task['skills']` |
|---|---|---|
| **AIF-C01** | 목표 **69개** | **빈 배열**(관례, 97 §5) |
| **SCS-C03** | **16개 Task 전부 빈 배열** | 기술 **70개** |

`aif_questions_test.dart`는 `task['knowledge']`에서 목표 번호를 유도한다. 그 코드를 SCS로 옮기면 번호 집합이 **빈 집합**이 되고, 그러면 「skill이 실재하는 기술 번호다」가 **전 문항을 거짓으로 거부**한다. 문항이 0개인 선결 단계에서는 **레드도 나지 않아** 첫 문항 배치에서야 터진다.

→ 대조군을 **양방향으로** 뒀다: ① 번호 70개가 유도된다(+ `3.2.7` 있음·`1.3.3` 없음·`6.4.1` 없음·`7.1.1` 없음) ② **`knowledge` 합이 0이고 `skills` 합이 70이다.** ②가 없으면 ①이 「우연히 70」일 수 있다(구조가 바뀌어 둘 다 채워지는 경우).

⚠️ Task별 기술 분해는 **5·6·2 / 4·5 / 4·7·5 / 3·5 / 3·4·5 / 5·4·3 = 70**이다(전수 실측). **가장 두꺼운 Task는 3.2(7개)**, **가장 얇은 Task는 1.3(2개)**이고 대조군이 그 양 끝을 짚는다.

### G-78 ⚠️⚠️ **SCS-C03은 이 레포의 첫 6도메인 자격증 — 65문항 배분이 `10·9·12·13·12·9`다**

공식 비중 **16·14·18·20·18·14**(합 100)을 `allocateByWeight`(floor + 최대 잔여)로 65문항에 배분하면 **floor 합이 63**이라 **잔여가 두 자리**이고, 소수부가 0.4/0.1/**0.7**/0.0/**0.7**/0.1이라 **D3·D5**가 받는다.

- 다른 자격증은 4도메인, **SOA·AIF가 5도메인**이었다 — 「키가 5개 이하」 가정이 섞이면 SCS에서 드러난다
- 그래서 함수 수준 가드를 **둘** 뒀다: 「SCS 6도메인 비중 → 10/9/12/13/12/9」와 **「6키 배분 합은 모든 N에서 N이다」**(5키 불변식이 「키가 4개」 가정을 잡았던 것과 같은 이유)
- 공식 `overview` 실측: `scoredQuestions 50 + unscoredQuestions 15 = 65` · `durationMinutes 170` · `passingScore 750`

⚠️ **정책 추가는 공개가 아니다** — 문항이 0개인 동안 전 도메인이 부족해 게이트는 그대로 잠겨 있다. 정책을 **안 넣으면** `hasPolicy: false`로 fail closed라 사람이 전 문항을 flip해도 통합·약점 모의고사가 영원히 잠긴다(MLA가 #246에서 밟은 함정이고 AIF·SOA·DEA가 같은 이유로 미리 넣었다).

### G-79 ⚠️ 선결 가드의 배치가 선례와 둘 달랐다

**① `content_index_test`에 전용 테스트를 하나 두었다**(AIF는 두지 않았다). 동기화 루프(`readiness 정책은 exam guide의 65문항/도메인 비중과 동기화된다`)는 **정책 맵 ↔ 가이드**만 대조하고 **`examWeightedCapacityStatus`를 호출하지 않는다.** 그 함수는 `availableByDomain`을 **`requiredByDomain.keys`로** 만들기 때문에 키 수 가정이 섞이면 거기서만 드러난다 → 6키가 실제로 꿰어지는지를 한 건으로 고정했다.

**② locked 선언을 새로 만들지 않았다.** 레포가 2026-10-31에 **「지금 잠긴 cert를 표본으로 쓰는 테스트를 다시 만들면 안 된다」**고 못박아 뒀다(그런 선언은 `review.mjs flip`이 마지막에 돌리는 `content_index_test` 안에 있어서, 게이트를 여는 Task를 flip할 때 **파일을 다 쓴 뒤** 레드로 끝난다 — `--force`는 쓰기 **전** 구조 검사만 건너뛴다). 그래서 **합성 빈 엔트리**(`entries: const []`)로 썼다 — 실제 flip 상태와 무관하므로 앞으로 어떤 flip에도 묶이지 않는다.

⚠️ **테스트 수 예측이 7이었고 실제 8이다** — 구조 비대칭 대조군(G-77 ②)을 쓰기로 결정하면서 하나 늘었다. 기준선 **3,330 → 3,338**(문항 가드 5 + 배분 1 + 6키 불변식 1 + 정책 1).

⚠️ **레지스트리는 읽기 전용으로 실측했다** — `node tool/review.mjs build scs`가 `0 Task, 0문항`으로 돌아 `resolveCert`·`dir`·`label`·`loadTasks`가 전부 꿰어진 것을 확인했다(출력은 gitignored `build/`로만 간다). 문항이 없어 `flip` 경로는 지금 실측할 수 없고, **flip은 사람 전용**이다.

### G-80 ℹ️ 남은 선결은 없고, 첫 문항 배치에서 할 일이 둘이다

1. `test/scs_questions_test.dart`의 **`authoredTaskIds`**에 그 배치의 Task를 넣는다(`scs_doc_format_test.dart`의 `scsTaskIds`는 **이미 16개 전부**라 건드릴 일이 없다 — MLA에서 두 파일 중 한쪽만 늘려 빠뜨린 적이 있다)
2. `tool/review.test.mjs`의 **`preAuthoring`에서 `scs`를 지운다** — 설계대로 안 지우면 CI node 단계가 **1초 만에** 레드다(AIF가 같은 자리를 밟았다)

⏳ 그리고 **G-75**가 「재지 않고 층 설명으로만 둔 것」 일곱을 적어 뒀다 — 특히 **Control Tower 사용자 지정 제어의 구현 수단**과 **StackSets 대상 계정 게이트의 평가 시점**은 전용 페이지를 먼저 읽어야 문항으로 만들 수 있다.

## 2026-11-09 도메인 1 문항 배치에서 새로 세운 것

### G-81 ⚠️⚠️ 정답 인덱스 분포 — 내 1차 저작이 15개 중 13개를 0에 몰았다

`scs-t1-1` 초고의 정답 분포가 **`{0: 13, 1: 2}`**였다. 레포 전수를 재서 기준을 정했다(2026-11-09 실측).

| 자격증 | 정답 인덱스 분포 | 총 문항 |
|---|---|---|
| **AIF-C01** | **55 / 56 / 57 / 42** | 210 |
| SAA-C03 | 45 / 165 / 99 / 51 | 360 |
| DEA-C01 | 109 / 67 / 52 / 28 | 256 |
| MLA-C01 | 224 / 78 / 14 / 5 | 321 |
| SOA-C03 | **259 / 30 / 9 / 2** | 300 |

**AIF가 균형**이고(파일별 최대 쏠림도 5/15) SOA·MLA는 크게 쏠려 있다. **가장 최근 저작분이자 내 템플릿인 AIF를 기준**으로 삼아 4/4/4/3으로 재배치했다.

⚠️ **앱이 전 경로에서 보기를 셔플하므로 학습자에게는 보이지 않는다.** 그래도 고치는 이유는 **JSON을 읽는 사람(검수자)에게는 그대로 보이고**, 쏠린 분포는 저작자가 "첫 보기를 정답으로 쓰는 습관"에 빠졌다는 신호이기 때문이다.

⚠️ **재배치 기법** — 정답 위치 `c`와 목표 `t`의 **옵션을 교환**하고 `wrongExplanations`의 **키 `t`를 `c`로 재매핑**한다(나머지 키는 그대로). 안전장치 둘을 먼저 걸었다: ① **왕복 재현 대조군** — `json.dumps(ensure_ascii=False, indent=2)`가 원본을 **바이트 단위로 재현**하는지 확인한다(재현되지 않으면 서식이 흔들리므로 바이트 블록 치환으로 가야 한다. SAA·CLF의 `sources` 서식 차이가 그 사례다) ② **텍스트 집합 불변 단정** — 지문·해설·보기·오답 근거를 모아 정렬한 집합이 변경 전후 같아야 한다(자리만 옮기고 내용을 바꾸지 않았음을 기계로 증명한다).

### G-82 ⚠️⚠️ **D-11 가드가 `.md`만 순회해 문항이 새어 나갈 상태였다**

도메인 6 배치에서 세운 D-11 표기 가드가 `assets/content/scs/<taskId>.md`만 읽는다. 문항 파일이 들어온 이 배치에서 **내 문항은 올바르게 「준수 팩」을 썼지만**(`scs-t1-1`에 17개소, 「적합성 팩」 0건) **가드가 문항을 보지 않으므로 다음 배치가 「적합성 팩」을 써도 초록**이었다.

⚠️ **2026-11-06 AIF에서 똑같이 당했다** — `aif_facts_test`의 「계속 사전 훈련」 단정이 `.md`만 보는 사이 문항 3개소가 구 표기를 썼고 가드는 초록이었다. **가드를 세울 때 그 가드가 보는 범위를 적어 두고, 새 종류의 파일이 들어오면 범위를 늘린다.**

처리 — 문항 쪽을 **별 단정으로 갈랐다**(md는 「표기 메모」 예외가 필요하지만 **문항에는 예외가 없어** 0건으로 고정할 수 있다). 그리고 **대조군**을 더했다: 같은 탐지기가 **표기 메모의 인용 1건을 실제로 찾는지**. 0건을 「문제 없음」으로 읽지 않기 위한 장치다(2026-11-08 P-01에서 탐지기가 두 번 조용히 실패한 뒤로 규율이다).

### G-83 ℹ️ 도메인 1 문항에서 **G-31·G-32를 지켰다**

- **G-31**(Athena · OpenSearch Service · Lambda · Managed Grafana를 재지 않았다) — 그 네 서비스의 **구체 수치·한도를 묻는 문항을 만들지 않았다.** `기술 1.2.5`는 **측정된 층 배치**(변환은 Lambda / 색인·검색은 OpenSearch Service / 시각화는 Managed Grafana)와 **Security Lake와의 관계**(경쟁이 아니라 정규화와 검색·시각화로 나뉜다)만 물었고, `기술 1.2.4`는 **측정된 사실**인 Logs Insights 쪽으로 갔다 — 쿼리 언어 3종, **동시 실행 한도 QL 100 / PPL·SQL 각 15**, **`filterIndex`와 비교 쿼리의 QL 전용성**, **SQL·PPL의 백틱 규칙**. Athena는 **「질문의 모양」 축**(실시간은 Logs Insights · 장기·대량은 Athena · 보안 자세는 CSPM)으로만 썼다.
- **G-32**(`기술 1.1.2`의 「리소스 상태 확인」을 서비스별로 재지 않았다) — 서비스별 기본값·임계값을 단정하지 않고 **확인 순서**(대상 경로·포트 → 보안 그룹·네트워크 ACL → 임계값·간격 대비 기동 시간)만 물었다. `기술 1.1.2`의 나머지는 **측정된 알람 평가**(Period · Evaluation Periods · Datapoints to Alarm, M out of N의 공식 예시 수치, 고해상도·다중 일 알람, 평가 상태 4종)로 채웠다.

⚠️ **두 갭은 여전히 열려 있다.** 그 네 서비스를 묻는 문항은 **전용 페이지를 먼저 재야** 만들 수 있다.

### G-84 ⚠️ 문항 출처는 **학습문서 출처의 부분집합**으로 두고 기계로 단정한다

문항이 새 URL을 들이면 그 URL은 **학습문서 저작 때 실측된 대상이 아니었던 것**이라 검증 공백이 생긴다(이 레포가 반복해 밟은 「URL은 200인데 그 페이지에 인용 사실이 없다」의 입구다). 그래서 검증 스크립트가 ① 문항 출처가 **학습문서 프런트매터 `url:`의 부분집합**인지 ② 고유 URL 전수가 `200 r=0`인지를 함께 단정한다.

실측 결과 — **고유 URL 21개 전부 `200 r=0`**, **학습문서 밖 URL 0건**, 대조군 둘 재현(있는 가이드의 없는 슬러그 `200 r=1` → 인덱스 · 없는 가이드 접두사 진짜 `404 r=0`).

### G-85 ℹ️ 문항 배치의 레포 관례 — 실측으로 확인한 값

- **Task당 15문항**이 관례다(AIF 210/14 · SAA 360/24 · SOA 300/20 · DEA 256/17 모두 15 기준)
- `difficulty`는 **`foundational`과 `applied` 두 값**뿐이다(AIF 전수: applied 137 · foundational 73). 도메인 1 세 편은 foundational 11 · applied 34로 뒀다
- `section`은 **학습문서의 `{#앵커}`와 일치**해야 한다(검증 스크립트가 md에서 앵커를 추출해 대조한다)
- **렌더 경로가 평문 `Text`**라 문항 본문에 **`**굵게**`·단일 `*이탤릭*`·`[텍스트](링크)`를 쓰지 않는다**(전역 불변식 가드가 있다). 세 편 모두 0건
- `questionCount`는 **verified 수**다 — 전 문항이 드래프트인 이 배치에서는 **`content_index.dart`를 건드리지 않는다**(0 == 0으로 불변식 통과)
