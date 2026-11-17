# CLF-C02 · DVA-C03 2단계 보정 — 2026-11-17

> 집행한 1단계 보고서: `clf-dva.md` · 계약: `01-PHASE2-CONTRACT.md`(⚠️ 이 브랜치에는 없어 커밋 `8884494` 에서 `git show` 로 읽었다 — §5).
> 브랜치 `content/phase2-fable-2026-11-17` 의 워킹트리에 수정만 남겼다. **커밋·브랜치 전환·flip·재합성·`reviewStatus` 변경은 하지 않았다.**
> 판정 근거는 전부 2026-11-17 에 `curl -sL` 로 다시 받은 공식 본문이다(60여 페이지, 추출 길이와 알려진 양성 대조군을 함께 쟀다).
> 대조군 재현: 있는 가이드의 없는 슬러그 `200 r=1`(`awssupport/latest/user/zz-bogus-slug.html` → 가이드 인덱스) · WA `framework/` 의 지워진 슬러그 **진짜 `404 r=0`** · `aws.amazon.com` 없는 경로 `404 r=0`.

## 0. 요약

- **1단계 22항목**(CLF 🔴 2 · 🟡 13 / DVA 🔴 1 · 🟡 6) → **채택 21 · 미집행 1**(D-Y6 — 공유 파일이라 요청으로 넘김).
  그 안에서 **부분 기각 4묶음**(§2) · **범위 확장 9자리**(§3, 그중 **1건은 1단계 보고에 없던 거짓**). 🟢 는 CLF 5건·DVA 3건을 함께 닫았다.
- 손댄 파일 **41개**: CLF md **19편** · CLF 문항 **13파일(43문항)** · CLF 대본 **1편(발화 5세그먼트)** · DVA md **7편** · 가드 1. diff `314+/142−`.
- **정답 인덱스 변경: 0건** · `verified` 변경 0건 · `reviewStatus`·`sourceHash`·`sourceExcerpt` 변경 0건
  (`git diff -U0` 에서 그 키가 든 줄이 **0줄** + 치환 엔진이 문항 파일마다 「선언한 문항만 바뀜 · `correct`/`verified`/`difficulty` 불변 · `"verified"` 바이트 수 불변」을 쓰기 전에 단정).
- 새 가드 `flutter_app/test/clf_v2_fix_test.dart`: **55건**(CLF·DVA 분을 한 파일에). `flutter analyze` 0건.
  - **Test-First**: 수정 전 `+8 −45`(대조군 8건만 통과) → 수정 후 55/55. 뒤에 더한 두 건(Boto3 재시도 · Fargate 귀속)도 각각 레드를 먼저 확인했다.
  - 실행: `test/clf_*` 7파일 + `dva_doc_format_test` = **191/191 통과**.
  - **민감도**: 문구를 임시로 깨는 변이 **11종 전부 레드 → 복구 sha256 일치**(문항 「최상위」 · md 「에서만」 · 발화 seg033 · 「시험 가이드 기준」 · 개요 URL 되살림 · Snowball 상태 삭제 · 「6종」 · Simple AD 상태 삭제 · DVA 콘솔 예외 · Agents Classic 상태 삭제 · 「legacy가 기본」). 전후 기준선 exit 0.
- 새로 넣은 URL **32개 전부 `200 r=0`**(diff 의 추가 줄에서 기계로 뽑아 전수 측정). 추가한 md 줄에 `[텍스트](링크)` 0 · 단일 이탤릭 0.
- `prescreen`(clf): 구조 플래그 0 유지 · 품질 신호 91 → **89**(length-cue 88 → 87 · meta-phrasing 6 → 5 · authoring-memo 1 → 0 · explanation-long 0 유지) · Task 내 중복 후보 30 → 29쌍.
- 남긴 것: 🟢 길이 단서 87 · 중복 · 내부 § 참조 · 커버리지 공백 · 사실 출처 보강 6문항(§6) · 사람 판단 4건(§5).

## 1. 채택 — 무엇을 어떻게 고쳤는가

### CLF 🔴

| 항목 | 재확인한 공식 원문 | 고친 것 |
|---|---|---|
| **C-R1** Enterprise = 최상위·최속·TAM 유일 | `aws-support-plans.html`(5,909자): 플랜 넷 `Basic · AWS Business Support+ · AWS Enterprise Support · AWS Unified Operations`. Enterprise `A designated Technical Account Manager (TAM).` `Up to 15 minute production-critical case response.` / Unified Operations `Designated AWS Technical Account Manager (TAM) and Domain Specialist Engineer (DSE)`. `premiumsupport/plans/` 비교표 「Business/Mission-critical system down」 `< 30 mins` / `< 15 mins` / `< 5 mins from Incident Management Engineer`. `unified-operations-intro.html`: `A five-minute, context-aware response for critical incidents` | 문항: `q1` W2 · `q6` W2 「최상위」→「상위」 · `q3` 지문 「가장 빠른(약 15분)」→「약 15분」, 해설을 「보기 중 TAM 과 15분 응답을 함께 주는 유일한 플랜 + 그 위에 Unified Operations(5분)」로(+출처 `premiumsupport/plans/` — 15분·5분·1시간 표가 있는 페이지) · `q13` 지문·보기[1]·해설 3곳. md `t4-3`: 사다리(:41) · 시험 포인트(:134) · TAM 배타 서술(:149) · 정직성 메모(:77)에 Unified Operations 가 무엇인지 한 문장. 발화 `clf-t4-3` seg006·seg014·seg030·seg033 |
| **C-R2** 「시험 가이드 기준 … 업무 시간 지원 플랜」 | 공식 가이드 작업 4.3: 「…기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations」 — Developer Support 없음 | `q13` 정답 보기[0] → 「워크로드 중요도에 맞춰, 개발·테스트 용도에 맞는 더 낮은 유료 기술 지원 플랜으로 다운그레이드한다」(**55자** · 오답 57/49/57). ⚠️ 보고 제안대로 괄호만 걷으면 정답이 **최단**이 되어 반대 방향 단서가 된다(가드가 양방향을 본다). 해설의 「시험 가이드 기준으로 이해」→ 현행 최저 유료 플랜·단종일 |

### CLF 🟡

| 항목 | 고친 것 |
|---|---|
| **C-Y1** Snowball | `t1-3.md` 정직성 메모를 공식 단정으로(`AWS Snowball Edge is no longer available to new customers` · 대안 DataSync/Data Transfer Terminal · 제품 페이지 `On December 31, 2026, AWS will discontinue support … in all AWS commercial Regions`). **가르치는 층 4문항**(`clf-t1-3-q3`·`q8`·`q9`·`q14`) 해설 끝에 상태 한 줄 + 출처 `aws.amazon.com/snowball/` 추가(2026-12-31 은 문항이 인용하던 `whatisedge.html` 에 없다). 오답 층 10문항은 손대지 않았다(가드가 「거기엔 상태가 없다」를 대조군으로 고정) |
| **C-Y2** Simple AD | `t2-3.md` 표 행에 신규 고객 비개방·공식 대안 + 출처 `directory_simple_ad.html` |
| **C-Y3** FSx File Gateway | `t3-6.md:167` 에 신규 고객 비제공 병기 + 출처 `what-is-file-fsxw.html` |
| **C-Y4** 개요 페이지 인용 | 문항 20곳의 개요 URL → **0곳**(도메인 페이지 19 · `framework/cost07-bp02.html` 1). 제목도 공식 기술 문구 그대로로 바꿨다. md 19편 전부에 자기 도메인 페이지를 프런트매터 + 출처 절에 **추가**(개요 페이지는 비중·형식 근거로 남김) |
| **C-Y5** 사실을 담지 않는 출처 8문항 | `virtualization` 추가 · `aws-regions` ×2(교체) · `aws-regions-availability-zones`(교체) · EKS `fargate` 추가 · `plan-types` 추가 · `reserved-instances-types`(교체). `clf-t1-4-q8` 은 제목에서 TCO·숨은 비용 귀속을 걷고 가이드 도메인 1(작업 1.4 「온프레미스 환경과 관련된 비용 이해」)을 더함 |
| **C-Y6** 출처 제목 | `q7`·`q13` 제목을 현행 플랜 이름으로. `q1` 은 제목을 그 페이지의 Basic 네 항목으로 고치고 **`trusted-advisor.html`** 추가(`If you have a Basic Support plan, you can … access all checks in the Service Limits category and selected checks in the Security and Fault tolerance categories`) |
| **C-Y7** 근거 없는 단정 | `q2` 해설 「시험은 … 출제되며」 삭제 · `q11`·`t4-3.md:119` 「시험 대비로는 전통 분류인 …로 기억합니다」→「전통 분류에서는 …입니다」 · `q7` 「시험 전통 분류 기준」→「전통 명칭으로는」 · `t4-3.md:140`·발화 seg031 「신규 가입 종료 공지」→「2027-01-01 단종 공지」 |
| **C-Y8** | `t1-2.md:81` 인용문을 `definitions.html` 의 실재 문장으로(`The AWS Well-Architected Framework is based on the following six pillars:`) |
| **C-Y9** | `t3-1`(CodeDeploy)·`t3-2`(Wavelength)·`t3-7`(Personalize)에 범위 메모 한 줄, 학습 목표에 「공식 「범위 외」 — 구조만」. 사실은 옳으므로 지우지 않음 |
| **C-Y10** | `t3-8.md:192` 에서 CloudShell 을 「범위 외」로 |
| **C-Y11** | `t4-2.md` §3 에 두 유형·각각 활성화·`aws:createdBy`·활성화 이후 리소스 한 줄 + 출처 둘. `clf-t4-2-q10` 에 `section: cost-tracking` |
| **C-Y12** | `t4-1.md` 「6종」 개수 단정 삭제 + 표에 **Dedicated Instances** 행(`run on hardware that's dedicated to a single AWS account` · `provide no visibility or control over instance placement` · `limited support for Bring Your Own License (BYOL)`) + 출처 |
| **C-Y13** | `t1-3.md:96` 가이드 인용을 공식 그대로(「적절한 마이그레이션 전략 파악」) |

🟢 함께 닫은 것: `clf-t4-2-q12` 백틱 3쌍(CLF 문항 전수 0건 불변식으로 고정) · `clf-t3-8-q11` `skill` 「고객 참여」→「비즈니스 애플리케이션」 · `clf-t4-1-q5` 출처를 실제 비교 표가 있는 `sp-ris.html` 로 · `clf-t4-3-q9` 오답 보기의 구명칭 「AWS Personal Health Dashboard」→「AWS Health Dashboard」(정답 25자 · 오답 20/17/11) · md 19편 `lastVerified: 2026-11-17`.

### DVA

| 항목 | 재확인한 공식 원문 | 고친 것 |
|---|---|---|
| **D-R1** | `id_roles.html`: `You can perform role chaining through the AWS Management Console by switching roles, the AWS CLI, or API.` / `Role chaining limits your AWS Management Console, AWS CLI or AWS API role session to a maximum of one hour. It applies regardless of the maximum session duration configured for individual roles.` | `dva-t2-1.md` 세 자리(용어 표 · 핵심 개념 · 자가 점검 정답)를 「콘솔·CLI·API 역할 세션」으로 |
| **D-Y1** | `agents-classic-maintenance-mode.html`: `is now Amazon Bedrock Agents Classic and will no longer be open to new customers starting on July 30, 2026` · `Your existing Amazon Bedrock models, Knowledge Bases, and Guardrails are not affected` · `Inline function tools for return-of-control and human-in-the-loop patterns` | `dva-t2-3.md` §6 머리에 상태 블록 + 출처 둘 |
| **D-Y2** | `xray-sdk-java-segment.html`: `On February 25th, 2026, the AWS X-Ray SDKs/Daemon will enter maintenance mode … security issues only … We recommend to migrate to OpenTelemetry.` | `dva-t4-1.md`·`dva-t4-2.md` 계측 문장에 유지 관리 병기(`dva-t4-2` 에 출처 추가) |
| **D-Y3** | 인용 페이지(1,239자)는 `On April 30, 2027 …` 뿐 — `May 15` 0건(대조군 `Kiro` 6건) | 「신규 가입 차단(2026-05-15)」 삭제 · 같은 문장의 「콘솔·문서 사이트·모바일 앱·채팅 앱의 Q는 영향이 없습니다」도 그 페이지에 없어 「그 공지가 적는 대상은 IDE 플러그인」으로 좁힘 · Kiro 표 머리에 「AWS docs 밖 — 문항의 근거로 쓰지 않는다」 명시 |
| **D-Y4** | `copilot-install.html`: `AWS Copilot CLI will reach end-of-support on June 12, 2026` | `dva-t3-2.md` 출처 추가 |
| **D-Y5** | `http-api-mutual-tls.html`: `To enable mutual TLS for a HTTP API, you must configure a custom domain name` | 표 행을 「REST(Regional 커스텀 도메인)·HTTP(커스텀 도메인)」+ 출처 둘 |

함께 닫은 것: `dva-t1-1.md` SNS 「토픽 속성 `MaximumMessageSize` 를 설정하면」(+출처) · `dva-t1-3.md` 「Valkey 가 권장 엔진」 삭제(인용 페이지의 recommend 는 「그 엔진의 최신 버전」뿐 — `Amazon ElastiCache supports the Valkey, Memcached, and Redis OSS cache engines`) · `dva-t2-3.md` Guardrails 「6종」 개수 삭제(이름 나열은 유지 — 레포 규율). DVA md 7편 `lastVerified: 2026-11-17`.

## 2. 기각 — 왜 고치지 않았는가

1. **「미션 크리티컬 = Enterprise」(C-R1 의 일부)** — `t4-3.md:53`(용어) · `:70`(표) · `:82`(원리 블록) · 발화 seg009 · seg012 · seg015 · `q3` 지문.
   공식 비교표에서 Enterprise 가 15분을 약속하는 행의 이름이 **`Business/Mission-critical system down`** 이다. 「미션 크리티컬 환경이 Enterprise 에서 TAM 과 짧은 응답 목표를 얻는다」는 **거짓이 아니다**(「Recommended for」 행만 미션 크리티컬을 Unified Operations 에 준다). 그래서 **배타·최상급 서술만** 고치고, 권장 대상의 차이는 `:77` 정직성 메모 한 곳에 공식 문구대로 더했다. 가드에 **보존 대조군**을 뒀다(`:82` 문장과 seg015 가 남아 있어야 한다).
2. **발화 seg026 과 seg014 의 「시중 기출·교재는 전통 네 단계로 출제하는 경우가 많다」(C-Y7)** — AWS 사실에 대한 서술이 아니라 학습 조언이고 단종 사실·현행 명칭을 함께 말한다. 2026-11-06 사용자 판정(재합성 범위는 「거짓인 곳」)에 따라 그 문장은 손대지 않았다. md 쪽 대응 문구는 완화했다(§3 ⑤).
3. **다른 편의 발화**(`clf-t1-3` seg021 「제한될 수 있습니다」 · `clf-t2-3` seg052 · `clf-t3-6` seg038 · `clf-t1-2` seg016 · `clf-t4-1` seg012 「옵션 여섯 가지」 · 범위 외 세 편) — 전부 **불완전·낡은 표현이지 거짓이 아니다**. 대본을 고치지 않았다 → 재합성 대상이 아니다(재합성하면 그 편이 청취 재승인까지 비노출이 된다).
4. **`clf-t4-2-q12` 의 `section` 변경(C-Y11)** — 기존 가드 `clf_p3_review_fix_test.dart:134` 가 `'cost-tools'` 를 리터럴로 고정한다(내 소유 범위 밖 파일). 고치지 않았다 → §5.

## 3. 범위 확장 — 보고가 하한이던 자리

| # | 자리 | 실측 |
|---|---|---|
| ① | **DVA `dva-t1-1.md` — 「Boto3 가이드(현행): legacy가 기본 · 최대 시도 5」** ⚠️ **1단계 보고에 없던 거짓**(형제 `fix-dea` 노트가 DEA 에서 같은 계열을 짚어, DVA 에서 직접 쟀다) | 현행 Boto3 가이드: `Standard mode is the default mode used by any Boto3 client you create.` · `Legacy mode was the default mode for Boto3 clients before standard mode became the default.` · standard `A default value of 3 for maximum attempts … DynamoDB and Amazon DynamoDB Streams clients default to 4` · legacy `A default value of 5`. 표 두 행과 `:159`(「그때까지 Java·Python·…는 legacy가 기본」 — SDK 레퍼런스는 그 SDK 들에서 legacy 가 **`Available in`** 이라고만 적는다)를 고쳤다. `AWS_NEW_RETRIES_2026` opt-in 서술은 **오늘도 참**이라 지켰다(`Without this setting, your SDK uses pre-2026 retry behavior`). 그 표가 근거로 삼는 Boto3 가이드가 출처 목록에 없어 추가했다(`boto3.amazonaws.com/v1/…/retries.html` 은 `r=1` 로 `docs.aws.amazon.com/boto3/latest/guide/retries.html` 로 간다 — 뒤쪽을 썼다) |
| ② | **D-R1** 거짓 괄호 | 보고는 `:267` 1곳(`:354` 는 「불완전」) — 실제로 「콘솔 역할 전환에는 해당하지 않습니다」가 **`:267`·`:354` 2곳**(자가 점검 정답 포함) |
| ③ | **C-Y6 `clf-t4-3-q10`** | 보고는 「제목만 낡았다」 — 인용 페이지 `getting-started.html`(3,492자)에 `Support API`·`programmatic` **0건**(대조군 `Support` 36건). 출처 자체를 **`about-support-api.html`** 로 교체: `You must have a AWS Business Support+, AWS Enterprise Support, or AWS Unified Operations plan to use the AWS Support API.` |
| ④ | **`clf-t4-3-q6`** (보고에 없음) | 출처 제목이 `aws-support-plans.html` 에 「Developer: 업무 시간 이메일/웹 기술 지원」을 귀속하는데 그 페이지는 이제 **단종 공지만** 적는다. 제목을 단종 공지로 고치고 **`premiumsupport/plans/developers/`** 를 추가(`Business hours email access to Cloud Support engineers` · `testing or doing early development`) |
| ⑤ | **C-Y7** | `clf-t4-3-q7` 해설 「시험 전통 분류 기준」 · `t4-3.md:77` 「시중 기출·교재는 아직 전통 4단계로 출제하므로」도 같은 계열 → 「전통 명칭으로는」·「전통 4단계 명칭으로 적힌 자료도 아직 많으므로」 |
| ⑥ | **C-Y4 `clf-t3-2-q12`** | 도메인 페이지로 옮겨도 「리전별 요금 차이」가 없다(공식 3.2 에 가격 없음). **`framework/cost07-bp02.html`**(`200 r=0` — `Resource prices vary by Region. Where latency, data residency, data sovereignty, and regulatory rules permit, placing a workload in a lower-cost Region reduces spend.`)로 교체. ⚠️ 번호가 아니라 **본문과 제목을 읽고** 골랐다(WA framework 는 BP 번호를 재배정했다). `cost-optimization-pillar/` 판도 살아 있지만 `This whitepaper is for historical reference only and will be deprecated` 배너가 있어 쓰지 않았다 |
| ⑦ | **C-Y4 제목** | 보고의 둘 외에 `clf-t4-3-q5` 제목의 「AWS Support의 Partner-Led Support 연계」도 도메인 페이지에 없어 걷음 |
| ⑧ | **C-Y5 `clf-t3-3-q4`** | EKS 페이지를 더하는 것만으로는 부족했다 — ECS `AWS_Fargate.html` 본문에 `serverless` 가 **0건**이다. 「Fargate = 서버리스」의 근거는 공식 가이드 작업 3.3 기술(「다양한 서버리스 컴퓨팅 옵션 …(예: AWS Fargate, AWS Lambda)」)이므로 도메인 3 페이지를 더하고 ECS 제목에서 그 낱말을 걷었다(⚠️ 내 1차 수정이 그 낱말을 제목에 넣었다가 자체 대조에서 잡았다) |
| ⑨ | **C-Y4 유일 출처 2문항** | `clf-t3-8-q15`(SES)·`clf-t4-2-q6`(비용 할당 태그)는 가이드가 유일 출처였는데 가이드는 이름만 든다 → 사실 페이지 추가(`ses/latest/dg/Welcome.html` `send marketing emails … transactional emails such as order confirmations` · `cost-alloc-tags.html`) |

**보고가 과대였던 자리**: 전수 탐침에서 `clf-t1-3-q4` 는 `skill` 라벨에 Snowball 이 있지만 지문·정답 보기·해설에는 없다 — 대상이 아니다(1단계 판정이 옳았다. 가드의 「가르치는 층」에서 `skill` 을 뺐다).
**발화 판정**: 1단계가 든 `clf-t4-3` 8세그먼트를 전부 직접 읽었다 — 거짓 3(seg030 「가장 빠른 응답」 · seg031 「신규 가입 종료」 · seg033 「에만 포함」) · 재합성되는 김에 정합을 맞춘 2(seg006 사다리 · seg014 에 Unified Operations 한 문장) · 기각 3(seg009 · seg015 · seg026). **seg030 의 단종 문장과 seg012·seg013 은 공식과 일치해 그대로다.**

## 4. flip 준비 상태

해당 없음 — CLF 는 301문항 전부 이미 공개, DVA 는 문항 0개(미등재, 12월 전환 PR 대기 — 라이브 404 는 정상).

## 5. 컨트롤러 요청

- [ ] **계약 파일**: `docs/audits/2026-11-17-full-verify/01-PHASE2-CONTRACT.md` 가 이 브랜치에 없다(커밋 `8884494` 는 `content/phase2-fix-2026-11-17` 에만 있다). 합칠 때 함께 가져와야 보고서들의 참조가 산다.
- [ ] **재합성(사람 서명 영역)**: `clf-t4-3` 대본의 **seg006 · seg014 · seg030 · seg031 · seg033** 발화 본문(`enrichedScriptText`)을 고쳤다. `sourceExcerpt`·`sourceHash`·`reviewStatus`·`scriptText`·`audioSummary` 는 **손대지 않았다**(엔진이 「`enrichedScriptText` 외 필드 불변」을 단정). 필요한 후속: 재합성 + `sourceExcerpt`(md 를 고친 seg006·014·026·030·031·033 대응 줄)·`sourceHash` 갱신 + `reviewStatus`·`content_index.dart` 의 `audioApproved`/`audioSha8` 처리 + 청취 재승인·R2 발행. ⚠️ **재합성 전까지 라이브 mp3 는 옛 발화**(seg030 「가장 빠른 응답」· seg033 「에만 포함」 · seg031 「신규 가입을 종료한다는 공지」)를 그대로 낸다.
- [ ] **기준선**: 새 가드 **55건**(`CLAUDE.md` 기준선 줄).
- [ ] **`clf_p3_review_fix_test.dart:134`** 가 `clf-t4-2-q12` 의 `section` 을 `'cost-tools'` 로 고정한다. 내용은 `cost-tracking` 절이 맞다 — 옮기려면 그 단정과 문항을 함께 바꾼다.
- [ ] **`lastVerified`**: CLF md 19편·DVA md 7편을 `2026-11-17` 로 올렸다. CLF·DVA 날짜를 정확 비교하는 고정 맵은 `test/` 전수 grep 에서 **찾지 못했다**(`lastVerified` 를 읽는 파일은 `content_format_test`(합성 문자열)·saa·soa·mla·scs 뿐).
- [ ] **공유 테스트 확인**(나는 돌리지 않았다): `content_format_test`(프런트매터 `sources` — 새 출처는 전부 `lastVerified:` 바로 앞에 넣었고 내 가드가 CLF·DVA 31편에서 「선언된 `url:` 수 == 파서가 읽는 수」를 단정) · `section_anchor_link_test`(`clf-t4-2-q10` 에 `section` 신설 — `{#cost-tracking}` 실재) · `content_index_test` · `source_url_retired_test`.
- [ ] `test/source_url_retired_test.dart` 의 `retiredUrls` 에 **`https://docs.aws.amazon.com/wellarchitected/latest/framework/cost_pricing_model_region_cost.html`** 등재 검토(오늘 `404 r=0` — 같은 가이드의 틀린 슬러그는 `200 r=1`. 레포 0건이라 되살림 방지용. 내 가드도 CLF 에서 0건을 본다).
- [ ] **사람 판단 ①**: Snowball 문항 4건(`clf-t1-3-q3`·`q8`·`q9`·`q14`)을 유지할지 DataSync·Data Transfer Terminal 로 교체할지 — **2026-12-31 이후 상용 리전에서 정답 서비스가 없다.**
- [ ] **사람 판단 ②**: 범위 외 세 서비스(Personalize·Wavelength·CodeDeploy)를 학습 목표·절 제목에서 뺄지(지금은 메모만 달았다).
- [ ] **사람 판단 ③**: DVA 기술 2.3.4 를 AgentCore 축으로 다시 쓸지(12월 문항 저작 전).
- [ ] **D-Y6**: `exam_guides/DVA-C03.json` 신설(현재 `DVA-C02.json` 뿐 — 비중 32/26/24/18 ↔ 공식 30/26/22/22, 작업 13 ↔ 12). 12월 전환 PR 의 선결.
- [ ] `docs/content-research/DVA-C03/98-authoring-decisions.md` 에 「Kiro 구성 요소 표·AWS Compute 블로그 서술은 문항 근거로 쓰지 않는다」 기록(내 소유 범위 밖).
- [ ] **교차 자격증**(grep 실측, 고치지 않음): Support 「최상위 플랜/플랜에서만/신규 가입 종료」·CLF 개요 URL·「콘솔 역할 전환에는 해당하지」·「legacy가 기본」 — 다른 7개 자격증 **0건**. 이름 언급 파일: `Snowball` → `saa-t3-9`(md·문항) · `dea-t2-1`(md·문항) / `Simple AD` → `saa-t1-1.md` · `scs-t4-1`(md·문항) / `FSx File Gateway` → `saa-t3-2.md` / `cost-optimization-pillar/`(폐기 예고 배너가 붙은 판) → saa 3파일 — 상태 표기·인용 문장은 해당 세션이 본다.
- [ ] 형제 `fix-scs` 노트가 짚은 `clf-t2-2-q15` 의 `security-pillar/sec_protect_data_transit_encrypt.html`: 재보니 `200 r=0` 이고 인용 사실(`You encrypt data in transit using secure TLS protocols and cipher suites`)이 **실재한다** → 고치지 않았다. 다만 그 페이지에도 폐기 예고 배너가 있다(다음 URL 감사 때 볼 자리).
- [ ] 정답 인덱스 변경이 필요한 문항: **없음**.

## 6. 남긴 것 (다음 배치)

- **사실 출처 보강 6문항**: `clf-t4-3-q4`·`q5`·`q8`·`q9`·`q14`·`q15` 는 가이드 도메인 4 페이지가 유일 출처다. 그 페이지는 리소스 **이름**(re:Post · Knowledge Center · 권장 가이드 · 파트너)을 들 뿐 「커뮤니티 Q&A」「how-to」 같은 **정의**는 담지 않는다. 각 리소스의 공식 소개 페이지를 재서 더해야 한다(이 배치에서 재지 않았다).
- **「확인되지 않음」 그대로**: TCO 정의를 담은 공식 페이지(`aws.amazon.com/what-is/total-cost-of-ownership/` 는 404 · `aws.amazon.com/economics/` 본문에 정의 없음 — `clf-t1-4-q8` 은 제목 귀속만 걷었다) · `t3-6.md:63` S3 내구성 예시(1,000만 객체·1만 년).
- 🟢 길이 단서 87(+반대 방향) · 교차/Task 내 중복 · 내부 「(원리: §N)」 참조 어긋남 · 낡은 문항 수 안내(`t2-1.md:193`·`t2-3.md:285`) · 문항 지문·보기의 구명칭 「AWS Snowball」 · `clf-t3-2-q6` `skill` 의 Wavelength.
- 커버리지 공백(범위 내 16개 서비스 · 4.3 기술 넷 · Dedicated Instances 문항 0) — 새 문항 저작이라 범위 밖.
- DVA 🟢 3(RDS 암호화 경로 병기) · 🟢 4(Athena) · 「시험 포인트·흔한 함정·자가 점검」 문장 단위 대조 · KMS 온디맨드 회전(`dva-t2-2.md:191` 은 횟수를 적지 않아 형제 노트의 「10 ↔ 25」 어긋남에 해당하지 않는다).

## 부록 — 방법

- 치환은 **바이트 블록 치환 + 횟수 단정**(json 왕복 없음)이고, 모든 명세를 **먼저 dry-run 으로 전부 검증한 뒤** 한 번에 썼다(하나라도 어긋나면 아무 파일도 쓰지 않는다). 문항 편집 범위는 `"id"` 부터 그 문항의 `"verified":` **앞**까지로 잘라 그 값이 치환 범위에 들지 않게 했다.
- md 는 CRLF(`CR 수 == LF 수` 를 전후로 단정), 문항 JSON·대본은 LF 다(바이트로 실측 — 이 환경의 `grep -c $'\r'` 는 믿지 않았다).
- 이전 보정 브랜치(`55d8443`)와는 **독립으로 판정한 뒤** 읽기 전용(`git show`)으로 대조했다: 손댄 문항 43개·md 26편이 같았고, 갈린 자리는 §3 ①·③·④·⑥·⑧·⑨와 발화 seg014 다.
