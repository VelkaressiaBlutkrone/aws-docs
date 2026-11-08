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

### G-13 ⚠️ 깊이 조사가 필요한 주제 (조사 노트 후보)

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
