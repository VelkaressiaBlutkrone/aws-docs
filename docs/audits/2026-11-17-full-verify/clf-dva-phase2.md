# CLF-C02 · DVA-C03 2단계 보정 — 2026-11-17

> 집행한 1단계 보고서: `clf-dva.md`. 계약: `01-PHASE2-CONTRACT.md`.
> **커밋·브랜치 전환·flip·재합성은 하지 않았다.** 워킹트리(`content/phase2-fix-2026-11-17`)에 수정만 남겼다.
> 판정 근거는 전부 2026-11-17 에 `curl -sL` 로 다시 받은 공식 본문이다(46 + 6페이지, 전부 `200 r=0`.
> 대조군: 있는 가이드의 없는 슬러그 `200 r=1` → 인덱스 · WA `framework/` 의 지워진 슬러그 `404 r=0`).

## 0. 요약

- **1단계 22항목**(CLF 🔴 2 · 🟡 13 / DVA 🔴 1 · 🟡 6) → **채택 21 · 미집행 1**(D-Y6, 공유 파일이라 요청으로 넘김).
  그 안에서 **부분 기각 4묶음**(§2) · **범위 확장 7자리**(§3). 🟢 는 CLF 5건·DVA 3건을 함께 닫았다.
- 손댄 파일 **41개**: CLF md **19편** · CLF 문항 **13파일(43문항)** · CLF 대본 **1편(발화 4세그먼트)** · DVA md **7편** · 가드 1.
- **정답 인덱스 변경: 0건** · `verified` 변경 0건 · `reviewStatus` 변경 0건(문항 13파일 전부 「정답·verified 불변 + 선언한 문항만 바뀜」을 기계로 단정).
- 새 가드 `flutter_app/test/clf_v2_fix_test.dart`: **41건**(CLF·DVA 분을 한 파일에 — `test(` 30개 + 출처 쌍 데이터 주도 11건). `flutter analyze` 0건.
  - 실행: 새 가드 41/41 · `test/clf_*` 6파일 + `dva_doc_format_test` 포함 **177/177 통과**.
  - **민감도**: 문구를 임시로 깨는 변이 **8종 전부 레드 → 복구 sha256 일치**(문항 「최상위」 · md 「에서만」 · 발화 seg033 · 개요 URL 되살림 · Snowball 상태 삭제 · 「6종」 · DVA 콘솔 예외 · Agents Classic 상태 삭제).
- `prescreen`(clf): 구조 플래그 0 유지 · 품질 신호 91 → **89**(length-cue 88 → 87 · meta-phrasing 6 → 5 · authoring-memo 1 → 0).
- 남긴 것: 🟢 길이 단서 87 · 중복 · 내부 § 참조 · 커버리지 공백(§6) · 사람 판단 4건(§5).

## 1. 채택 — 무엇을 어떻게 고쳤는가

### CLF 🔴

| 항목 | 재확인한 공식 원문 | 고친 것 |
|---|---|---|
| **C-R1** Enterprise = 최상위·최속·TAM 유일 | `aws-support-plans.html`: 플랜 넷(Basic · AWS Business Support+ · AWS Enterprise Support · AWS Unified Operations). Enterprise `A designated Technical Account Manager (TAM).` `Up to 15 minute production-critical case response.` / Unified Operations `Designated AWS Technical Account Manager (TAM) and Domain Specialist Engineer (DSE)`. `premiumsupport/plans/` 비교표 「Business/Mission-critical system down」: `< 30 mins` / `< 15 mins` / `< 5 mins from Incident Management Engineer` | 문항: `q1` W2 · `q6` W2 「최상위」→「상위」 · `q3` 지문 「가장 빠른(약 15분)」→「약 15분」, 해설에 Unified Operations 5분 응답 병기(+출처 `unified-operations-intro.html`) · `q13` 지문·보기[1]·해설 3곳. md `t4-3`: 사다리(:41) · TAM 배타 서술(:149). 발화 `clf-t4-3` seg006·seg030·seg033 |
| **C-R2** 「시험 가이드 기준 … 업무 시간 지원 플랜」 | 공식 가이드 작업 4.3: 「…기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations」 — Developer Support 없음 | `q13` 정답 보기[0]의 괄호를 걷되 **길이를 맞춰** 「개발·테스트에 맞는 더 낮은 유료 기술 지원 플랜으로 다운그레이드한다」(51자 · 오답 49/54/57 — 괄호만 걷으면 정답이 최단이 되어 반대 방향 단서가 된다). 해설의 「시험 가이드 기준으로 이해」→ 현행 최저 유료 플랜·단종일 |

### CLF 🟡

| 항목 | 고친 것 |
|---|---|
| **C-Y1** Snowball | `t1-3.md` 정직성 메모를 공식 단정으로(신규 고객 비제공 · 대안 DataSync/Data Transfer Terminal · **2026-12-31 상용 리전 지원 종료 공지**). 가르치는 층 4문항(`q3`·`q8`·`q9`·`q14`) 해설 끝에 상태 한 줄 + 출처 `aws.amazon.com/snowball/` 추가. 오답 층 9문항은 손대지 않음(가드로 고정) |
| **C-Y2** Simple AD | `t2-3.md` 표 행에 신규 고객 비개방·공식 대안 + 출처 `directory_simple_ad.html` |
| **C-Y3** FSx File Gateway | `t3-6.md:167` 에 신규 고객 비제공 병기 + 출처 `what-is-file-fsxw.html` |
| **C-Y4** 개요 페이지 인용 | 문항 20곳의 개요 URL → **0곳**(도메인 페이지 18 · `clf-02-in-scope-services.html` 1 · COST07-BP02 1). md 19편 전부에 자기 도메인 페이지를 프런트매터 + 출처 절에 추가 |
| **C-Y5** 사실을 담지 않는 출처 8문항 | 표의 제안대로 교체·추가(`virtualization` · `aws-regions` ×2 · `aws-regions-availability-zones` · EKS `fargate` · `plan-types` · `reserved-instances-types`). `clf-t1-4-q8` 은 제목에서 TCO·숨은 비용 귀속을 걷고 가이드 도메인 1(작업 1.4 「온프레미스 환경과 관련된 비용 이해」)을 더함 |
| **C-Y6** 출처 제목 | `q7`·`q13` 제목을 현행 플랜 이름으로, `q1` 은 제목을 그 페이지의 Basic 네 항목으로 고치고 `premiumsupport/plans/`(Core checks) 추가 |
| **C-Y7** 근거 없는 단정 | `q2` 해설 「시험은 … 출제되며」 삭제 · `q11`·`t4-3.md:119` 「시험 대비로는 전통 분류인」→「전통 분류의」 · `t4-3.md:140`·발화 seg031 「신규 가입 종료 공지」→「2027-01-01 단종 공지」 |
| **C-Y8** | `t1-2.md:81` 인용문을 `definitions.html` 의 실재 문장으로 |
| **C-Y9** | `t3-1`(CodeDeploy)·`t3-2`(Wavelength)·`t3-7`(Personalize)에 범위 메모 한 줄 + 학습 목표에 「범위 외 — 구조만」. 사실은 옳으므로 지우지 않음 |
| **C-Y10** | `t3-8.md:192` 에서 CloudShell 을 「범위 외」로 |
| **C-Y11** | `t4-2.md` §3 에 두 유형·각각 활성화·`aws:createdBy`·활성화 이후 리소스 한 줄 + 출처 둘. `q10` 에 `section: cost-tracking` |
| **C-Y12** | `t4-1.md` 「6종」 개수 단정 삭제 + 표에 **Dedicated Instances** 행(`run on hardware that's dedicated to a single AWS account` · `provide no visibility or control over instance placement` · `limited support for BYOL`) + 출처 |
| **C-Y13** | `t1-3.md:96` 가이드 인용을 공식 그대로(「적절한 마이그레이션 전략 파악」) |

🟢 함께 닫은 것: `clf-t4-2-q12` 백틱 3곳(CLF 문항 전수 0건 불변식으로 고정) · `clf-t3-8-q11` `skill` 「고객 참여」→「비즈니스 애플리케이션」 · `clf-t4-1-q5` 출처를 실제 비교 페이지 `sp-ris.html` 로 · `clf-t4-3-q9` 오답 보기의 구명칭 「AWS Personal Health Dashboard」→「AWS Health Dashboard」 · md 19편 `lastVerified: 2026-11-17`.

### DVA

| 항목 | 재확인한 공식 원문 | 고친 것 |
|---|---|---|
| **D-R1** | `id_roles.html`: `You can perform role chaining through the AWS Management Console by switching roles, the AWS CLI, or API.` / `Role chaining limits your AWS Management Console, AWS CLI or AWS API role session to a maximum of one hour. It applies regardless of the maximum session duration configured for individual roles.` | `dva-t2-1.md` 세 자리(용어 표 · 핵심 개념 · 자가 점검 정답)를 「콘솔·CLI·API 역할 세션」으로 |
| **D-Y1** | `agents-classic-maintenance-mode.html`: `is now Amazon Bedrock Agents Classic and will no longer be open to new customers starting on July 30, 2026` · `Inline function tools for return-of-control and human-in-the-loop patterns` | `dva-t2-3.md` §6 머리에 상태 블록 + 출처 둘 |
| **D-Y2** | `xray-sdk-java-segment.html`: `On February 25th, 2026, the AWS X-Ray SDKs/Daemon will enter maintenance mode … security issues only` | `dva-t4-1.md`·`dva-t4-2.md` 계측 문장에 유지 관리 병기(`dva-t4-2` 에 출처 추가) |
| **D-Y3** | 인용 페이지(1,445자)는 `On April 30, 2027 …` 뿐 — `May 15, 2026` 0건 | 「신규 가입 차단(2026-05-15)」 삭제 · Kiro 표 머리에 「AWS docs 밖 — 문항 근거로 쓰지 않는다」 명시 |
| **D-Y4** | `copilot-install.html`: `AWS Copilot CLI will reach end-of-support on June 12, 2026` | `dva-t3-2.md` 출처 추가 |
| **D-Y5** | `http-api-mutual-tls.html`: `To enable mutual TLS for a HTTP API, you must configure a custom domain name` | 표 행을 「REST(Regional 커스텀 도메인)·HTTP(커스텀 도메인)」+ 출처 둘 |

🟢·§5·§6 에서 함께 닫은 것: `dva-t1-1.md` SNS 「토픽 속성 `MaximumMessageSize` 로」(+출처) · `dva-t1-3.md` 「Valkey 가 권장 엔진」 삭제(인용 페이지의 recommend 는 「그 엔진의 최신 버전」뿐) · `dva-t2-3.md` Guardrails 「6종」 개수 삭제(이름 나열은 유지 — 레포 규율). DVA md 7편 `lastVerified: 2026-11-17`.

## 2. 기각 — 왜 고치지 않았는가

1. **「미션 크리티컬 = Enterprise」(C-R1 의 일부)** — `t4-3.md:70`(표) · `:82`(원리 블록) · 발화 seg009 · seg015.
   공식 비교표에서 Enterprise 가 15분을 약속하는 행의 이름이 **`Business/Mission-critical system down`** 이다. 미션 크리티컬 환경이 Enterprise 에서 TAM 과 짧은 응답 목표를 얻는다는 서술은 **거짓이 아니다**(「Recommended for」 행만 미션 크리티컬을 Unified Operations 에 준다). 그래서 **배타·최상급 세 서술만** 고쳤다. `q3` 지문의 「대규모 미션 크리티컬 환경」도 같은 이유로 유지.
2. **발화 seg014 · seg026(C-Y7)** — 「시중 기출·교재는 전통 네 단계로 출제하는 경우가 많다」·「전통적인 분류 기준으로 기억해 두시면」은 **AWS 사실에 대한 서술이 아니라 학습 조언**이고 단종 사실·현행 명칭을 함께 말한다. 2026-11-06 사용자 판정(재합성 범위는 「거짓인 곳」)에 따라 손대지 않았다. md 쪽의 대응 문구는 완화했다(§3).
3. **발화 `clf-t1-3` seg021 등(C-Y1) · `clf-t2-3` seg052 · `clf-t3-6` seg038 · `clf-t1-2` seg016 · `clf-t4-1` seg012 · 범위 외 세 편의 발화** — 전부 **불완전·낡은 표현이지 거짓이 아니다**(「제한될 수 있습니다」는 약한 서술, 여섯 기둥 이름은 참, 「옵션 여섯 가지」는 표의 행 수). 대본을 고치지 않았다 → 재합성 대상이 아니다.
4. **`clf-t4-2-q12` 의 `section` 변경(C-Y11)** — 기존 가드 `clf_p3_review_fix_test.dart:134` 가 `'cost-tools'` 를 리터럴로 고정한다(내 소유 범위 밖 파일). 시도했다가 그 가드가 레드가 되어 되돌렸다 → §5 요청.

## 3. 범위 확장 — 보고가 하한이던 자리

| # | 자리 | 실측 |
|---|---|---|
| 1 | **D-R1** 거짓 괄호 | 보고는 `:267` 1곳(`:354` 는 「불완전」) — 실제로 「콘솔 역할 전환에는 해당하지 않습니다」가 **`:267`·`:354` 2곳**(자가 점검 정답 포함) |
| 2 | **C-Y6 `clf-t4-3-q10`** | 보고는 「제목만 낡았다」 — 인용 페이지 `getting-started.html` 본문에 `Support API`·`programmatic` **0건**(대조군 `Support` 8건). 제목이 아니라 **출처 자체**를 `aws-support-plans.html`(Business Support+ 혜택 `The AWS Support API to interact with Support Center and Trusted Advisor`)로 교체 |
| 3 | **C-Y4 `clf-t3-2-q12`** | 도메인 페이지로 옮기면 여전히 「리전별 요금 차이」가 없다(공식 3.2 에 가격 없음). **`cost_pricing_model_region_cost.html`**(COST07-BP02, `Resource pricing may be different in each Region`, `200 r=0`)로 교체 |
| 4 | **C-Y4 제목** | 보고의 둘 외에 `clf-t4-3-q5` 제목의 「AWS Support의 Partner-Led Support 연계」도 도메인 페이지에 없어 걷음 |
| 5 | **C-Y7** | `clf-t4-3-q7` 해설 「시험 전통 분류 기준 Business이며」 · `t4-3.md:77` 「시중 기출·교재는 아직 전통 4단계로 출제하므로」도 같은 계열 → 「전통 명칭으로는」·「전통 4단계 명칭도 함께 쓰이므로」 |
| 6 | **C-Y1** | 상태 문장의 2026-12-31 은 문항이 인용하던 `whatisedge.html` 에 없다 → 4문항과 md 에 제품 페이지를 **출처로 추가** |
| 7 | **D-Y5** | 보고 제안 「REST(Regional 커스텀 도메인)·HTTP」는 HTTP 가 무조건처럼 읽힌다 — HTTP API 도 **커스텀 도메인이 전제**다 |

반대로 **보고가 과대였던 자리**: `clf-t1-3-q4` 는 전수 탐침에서 「가르치는 층에 Snowball」로 잡혔지만 `skill` 라벨과 오답 보기뿐이라 대상이 아니다(1단계 판정이 옳았다 — 가드의 「가르치는 층」에서 `skill` 을 뺐다).

## 4. flip 준비 상태

해당 없음 — CLF 는 301문항 전부 이미 공개, DVA 는 문항 0개(미등재, 12월 전환 PR 대기).

## 5. 컨트롤러 요청

- [ ] **재합성(사람 서명 영역)**: `clf-t4-3` 대본의 **seg006 · seg030 · seg031 · seg033** 발화 본문(`enrichedScriptText`)을 고쳤다. `sourceExcerpt`·`sourceHash`·`reviewStatus` 는 **손대지 않았다** → 재합성 + `reviewStatus`·`content_index.dart` 의 `audioApproved`/`audioSha8` 처리 + 청취 재승인·R2 발행이 필요하다. ⚠️ 재합성 전까지 **라이브 mp3 는 옛 발화**(seg030 「가장 빠른 응답」· seg033 「에만 포함」)를 그대로 낸다.
- [ ] **기준선**: 새 가드 41건(`CLAUDE.md` 기준선 줄).
- [ ] **`clf_p3_review_fix_test.dart:134`** 가 `clf-t4-2-q12` 의 `section` 을 `'cost-tools'` 로 고정한다. 내용은 `cost-tracking` 절이 맞다 — 옮기려면 그 단정과 문항을 함께 바꾼다.
- [ ] **`lastVerified`**: CLF md 19편·DVA md 7편을 `2026-11-17` 로 올렸다. ⚠️ CLF 날짜를 정확 비교하는 고정 맵은 `test/` 전수 grep 에서 **찾지 못했다**(`lastVerified` 를 읽는 파일은 `content_format_test`·saa·soa·mla·scs 뿐) — 있다면 알려 달라.
- [ ] **공유 테스트 확인 요청**(나는 돌리지 않았다): `content_format_test`(프런트매터 `sources` — 새 출처는 전부 목록 끝·`lastVerified:` 앞에 넣었다 / 추가한 md 158줄에 `[텍스트](링크)` 0 · 단일 이탤릭 0) · `section_anchor_link_test`(`clf-t4-2-q10` 에 `section` 신설) · `content_index_test`.
- [ ] **사람 판단 ①**: Snowball 문항 4건(`clf-t1-3-q3`·`q8`·`q9`·`q14`)을 유지할지 DataSync·Data Transfer Terminal 로 교체할지 — **2026-12-31 이후 상용 리전에서 정답 서비스가 없다.**
- [ ] **사람 판단 ②**: 범위 외 세 서비스(Personalize·Wavelength·CodeDeploy)를 학습 목표·절 제목에서 뺄지(지금은 메모만 달았다).
- [ ] **D-Y6**: `exam_guides/DVA-C03.json` 신설(현재 `DVA-C02.json` 뿐 — 비중 32/26/24/18 ↔ 공식 30/26/22/22, 작업 13 ↔ 12). 12월 전환 PR 의 선결.
- [ ] `docs/content-research/DVA-C03/98-authoring-decisions.md` 에 「Kiro 구성 요소 표·AWS Compute 블로그 서술은 문항 근거로 쓰지 않는다」 기록(내 소유 범위 밖).
- [ ] **교차 자격증**(grep 실측, 고치지 않음): Support 「최상위/에서만/신규 가입 종료」·개요 URL — 다른 7개 자격증 **0건**. `Snowball` 언급 파일: `saa-t3-9`(md·문항) · `dea-t2-1`(md·문항) / `Simple AD`: saa 1 · scs 2 / `FSx File Gateway`: saa 1 — 상태 표기는 해당 세션이 본다.
- [ ] 정답 인덱스 변경이 필요한 문항: **없음**.

## 6. 남긴 것 (다음 배치)

- 🟢 길이 단서 87(+반대 방향 35) · 교차/Task 내 중복 · 내부 「(원리: §N)」 참조 어긋남 · 낡은 문항 수 안내(`t2-1.md:193`·`t2-3.md:285`) · 문항 지문·보기의 구명칭 「AWS Snowball」.
- 커버리지 공백(범위 내 16개 서비스 · 4.3 기술 넷 · Dedicated Instances 문항 0) — 새 문항 저작이라 범위 밖.
- 「확인되지 않음」 그대로: `t3-6.md:63` S3 내구성 예시(1,000만 객체·1만 년) · `dva-t1-1.md` 「콘솔·문서 사이트·모바일 앱·채팅 앱의 Q는 영향이 없습니다」(인용 페이지에 없음 — 재지 않았다).
- DVA 🟢 3(RDS 암호화 경로 병기) · 🟢 4(Athena) · 「시험 포인트·흔한 함정·자가 점검」 문장 단위 대조.
