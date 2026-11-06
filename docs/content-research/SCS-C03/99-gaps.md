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

- Task당 기술 수가 고르지 않다 — `3.2`는 **7개**, `4.1`·`4.2`는 **4개**다(D4는 Task 2개에 기술 8개).
- ⚠️ **비중과 Task 수가 어긋난다** — D4는 비중이 **가장 높은 20%**인데 **Task가 2개**고, D1은 16%에 **Task 3개**다. 「Task 1편」 규칙을 쓰면 **D4 문서 2편이 시험의 20%를 져야 한다.**
- → **D-01**에서 판정한다.

### G-06 ⚠️ 범위 내 71개 서비스의 상태 전수 확인이 필요하다

G-02에서 **표본 4개 중 4개**가 문제였다(`CodeGuru Security`·`Audit Manager`·`Q Business`·`Q Developer`). 나머지 67개도 같은 위험이 있다.

- **왜 지금 하지 않았는가:** Phase 1은 가이드 구조 실측이 범위다. 71개 상태 확인은 **각 서비스의 가용성 변경 페이지를 찾아 읽는 작업**이라 Phase 2(조사 노트) 몫이다.
- **어떻게 할 것인가:** 서비스별 `what-is`/`welcome` 페이지를 받아 `no longer open to new customers` · `maintenance mode` · `discontinue` · `end of support` 네 문구를 **두 방법으로** 센다. ⚠️ 문서가 **통째로 404인 경우**(`CodeGuru Security`)도 있으니 **상태 코드와 `num_redirects`를 함께** 본다(AIF G-50).
- ⚠️ **AWS 문서 리더를 두 번째 방법으로 쓴다** — AIF G-61에서 `302`로 튕기는 페이지의 본문이 리더로는 그대로 읽히는 것을 확인했다. **curl 하나로 「문서가 없다」고 결론 내리지 않는다.**

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
