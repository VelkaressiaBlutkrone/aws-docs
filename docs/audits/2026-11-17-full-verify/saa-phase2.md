# SAA 2단계 보정 — 2026-11-17

> 집행한 보고: `docs/audits/2026-11-17-full-verify/saa.md`(1단계). 계약: `01-PHASE2-CONTRACT.md`.
> 세션 모델: Fable 5.2(`content/phase2-fable-2026-11-17` 워킹트리, 커밋·브랜치 전환 없음).
> ⚠️ **계약 파일이 이 브랜치에 없다** — `01-PHASE2-CONTRACT.md` 를 추가한 커밋 `8884494` 가 이 브랜치의 조상이 아니다. `git show 8884494:…` 로 읽기 전용으로 꺼내 읽었다(§5 요청).
> 방법: 항목마다 공식 문서를 `curl -sL` 로 받아 본문을 추출·탐침해 **직접 재확인**한 뒤 채택/기각/범위 확장을 판정했다. 추출 도구의 대조군 — 일부러 틀린 슬러그는 `200 r=1`(가이드 인덱스), 본문 길이 36자.

## 0. 요약

- **채택 29 / 기각 6 / 범위 확장 7** (1단계 보고의 🔴 5 · 🟡 20 · 🟢 12 대비)
  - 🔴 5건 **전부 채택**(문항 4 + 학습문서 1).
  - 🟡 20건 중 채택 18(Y1~Y18 — Y15·Y18 은 부분) · 부분 채택 1(Y19 — 라벨만) · 컨트롤러 요청 1(Y20 — 공유 파일).
  - 🟢 12건 중 채택 5(G5·G7·G11·G12 + G2 의 `t4-5-q14`) · 기각 1(G6) · 남김 6(G1·G3·G4·G8·G9·G10).
- 손댄 파일: **md 19편 · 문항 24파일(전부) · 가드 1** — 문항 98개(본문 32 · 출처만 66), diff `+290 / −209`.
- **정답 인덱스 변경: 0건** · `verified` 변경 0건(360 → 360) · `git diff` 에 `"correct"`·`"verified"` 줄 0건.
- 새 가드 `flutter_app/test/saa_v2_fix_test.dart` = **62 테스트**. `flutter test test/saa_*` 31파일 **1,227 통과**(수정 전 기준선 1,165 + 62 — 기존 SAA 가드 레드 0건).
- 민감도: 수정 전 콘텐츠에서 61건 중 **47건 레드**(대조군 14건 그린) → 적용 후 그린. 추가로 옛 문구 12개를 임시 주입해 **15건 레드**를 확인하고 복구 뒤 **sha256 전 파일 동일**을 확인했다(`git stash` 미사용).
- `prescreen`(실측): 구조·정합성 플래그 **0건** / 품질 신호 152 → **150문항** — length-cue 149 → **147** · meta-phrasing 3 · authoring-memo 0 · explanation-long 3(불변).
- 남긴 것(다음 배치): Y18 17문항(대체 출처 미확보·경미) · G1 length-cue 147 · G4 중복 16쌍(사람 승인) · U4·U8·G8(사람 판정).

### 치환 방법(계약 §2)
- 문항 JSON 은 **json 왕복 없이 바이트 블록 치환**. 문항 블록 범위 안에서만 바꾸고 **치환 횟수를 단정**했다(편집 227개 — 본문 치환 113 · 출처 추가 85 · 삭제 4 · 개제 6 · `lastVerified` 19).
- 대조군: **360문항의 `sources` 구역을 파서로 읽어 다시 쓰면 바이트 단위로 동일**(한 줄 압축 형식 확인) → 그 뒤에만 출처를 추가·삭제·개제했다. 손대지 않은 262문항 블록은 수정 전후 바이트 동일을 파일마다 단정.
- 보호 필드(`id`·`correct`·`verified`·`difficulty`·`examGuideTaskId`)·보기 4개·오답 근거 키 집합 불변을 쓰기 전에 단정. 전 파일 CR 수 == LF 수.

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 🔴

| 항목 | 재확인한 공식 문장 | 수정 |
|---|---|---|
| **R1** `saa-t2-1-q7` | `sns-message-delivery-retries.html` 표: AWS managed endpoints(Lambda·SQS·Firehose) "**100,015 times, over 23 days**" · "retries the delivery of messages when server-side errors occur … discards the message—unless a dead-letter queue is attached to the subscription" | W2 를 「재시도가 부족해서 떨어지는 보기가 아니다 — Push 라 소비자가 자기 속도로 끌어가며 쌓아 둘 버퍼가 없다」로. 출처 2개 추가(재시도·DLQ). |
| **R2** `saa-t3-9-q9` | `lake-formation/…/working-with-services.html` 표: Athena SQL·Redshift Spectrum = R/W·Read·Read / Hive on EMR(EC2) = 행·셀 **Not supported** / EMR on EKS·Athena Spark = 셋 다 **Not supported** | 지문 「Athena·EMR 쿼리 전체에 일관되게」→「Athena 쿼리에」. 해설을 「지원 수준은 엔진마다 다르다」로. 표 페이지 출처 추가. |
| **R3** `saa-t4-4-q12` | `eks/…/cost-opt-networking.html`: "There is no destination cost associated with inter-AZ traffic that flows through the TGW." ↔ `transit-gateway/pricing/`: "standard AWS data transfer charges, in addition to any Transit Gateway charges"(공식 내부 어긋남) · 같은 페이지 예시 "Data Processing will result in a charge of $0.02" | **갈림길을 「TGW 쪽 전송 요금 유무」에서 「데이터 처리 요금 유무」로 옮겼다** — 정답 [2]·해설·W0·W1·W3 에서 `$0.03` 합산을 걷고, 오답 [0]·[1] 을 처리 요금 축의 명백한 거짓으로 교체(「둘 다 $0.02」는 양방향을 세면 참이 될 수 있어 바꿨다). 기존 가드의 `송신 측 1 GB 기준`·`양방향` 유지. |
| **R4** `saa-t1-3-q8` + md | `vpc-nat-comparison.html` 표: Port forwarding "Not supported." / "Manually customize the configuration to support port forwarding." · Bastion "Not supported." / "Use as a bastion server." · Security groups "You cannot associate security groups with NAT gateways." · "We recommend that you use NAT gateways" | 참이던 오답 보기 [1] 을 **명백히 거짓**(「NAT 게이트웨이에 보안 그룹을 연결해 인바운드 규칙을 열면…」)으로 교체. W1 을 그 반박 + NAT 인스턴스 사실 한 줄로. 비교표 출처 추가. `saa-t1-3.md:145` 「아웃바운드 전용」 정정. |
| **R5** `saa-t3-7.md` 5줄 | `routing-policy.html`: "You can use geoproximity routing to create records in a private hosted zone." · `routing-policy-geoproximity.html`: "The maps are available only with Traffic Flow." | `:110·:120·:318·:339·:340` 을 문항 q6 해설과 같은 문장으로 통일. `98-existing-gap` G-3.4-12 / `99-gaps` V-36(「미확인」)이 이 실측으로 닫힌다. |

### 🟡

- **Y1** `saa-t1-2-q9` + md — `controlreference/control-behavior.html`: "preventive controls are implemented using … SCPs, **RCPs, and declarative policies**". 해설·W0·W1 + md `:238·:253·:254·:307`. 출처 추가.
- **Y2** `saa-t1-2-q11` + md `:113` — `special-accounts.html`: "auditor (read-only) **and administrator (full-access)** cross-account roles" · "previous name: the audit account". 정답 보기·해설·md.
- **Y3** `saa-t1-5-q9`·`q10` + md `:242·:245·:357` — `what-is-macie.html`: "machine learning **and pattern matching**". 🧠 원리 블록은 전제(「규칙 기반이 아닌」)가 틀려 질문과 마지막 줄을 다시 썼다.
- **Y4** `saa-t2-1-q8` W2 — R1 과 같은 전제(「처리 보장을 위해 … 권장」)를 걷었다.
- **Y5** `saa-t2-5-q11` + md `:182` — `Concepts.MultiAZSingleStandby.html`: "can have **increased write and commit latency** compared to a Single-AZ deployment". 출처 추가.
- **Y6** Multi-AZ 한정 — `multi-az-db-clusters-concepts.html`: "a **semisynchronous**, high availability deployment mode … two readable replica DB instances". 한정어만 넣었다(§3 범위 확장).
- **Y7** `saa-t3-4-q8` + md `:493·:509` — `job_timeouts.html`: "Jobs that run on Fargate resources can't expect to run for more than **14 days**" · timeout 은 선택 설정(`Required: No`, 최소 60초). 출처 추가.
- **Y8** `saa-t3-5-q11` W0 — `CHAP_Storage.html`: "**Amazon RDS has deprecated magnetic storage.** You can no longer create new DB instances using magnetic storage, and … migrated existing magnetic storage volumes to gp3." 「평균 약 100 IOPS」(그 페이지에서 100 IOPS 는 gp2 최솟값)는 지웠다. ⚠️ 2026-10-27 §C 는 같은 제안을 기각했는데 **그때 페이지는 「previous generation」까지만 적었다** — 페이지가 바뀌어 판정이 바뀐 자리다. 해설의 gp3 기준 성능에 「임계 용량 미만에서」 한정.
- **Y9** `saa-t3-8-q11` W3 — `gateway-endpoints.html`: "traverses the internet gateway, **it does not leave the AWS network**".
- **Y10** `saa-t1-3-q7` W2 — `vpc-nat-gateway.html`: 퍼블릭은 "must associate an Elastic IP address … at creation" / "You can't associate an Elastic IP address with a private NAT gateway." 출처를 VPC 소개 → 이 페이지로 교체.
- **Y11** `saa-t2-3-q15` — 참이던 보기 [3] 을 거짓 서술로 교체, 회피형 반박(「질문의 핵심은…」)을 참·거짓을 말하는 근거로. `elasticbeanstalk/…/Welcome.html`: "configures load balancing … and dynamically scales your environment" · `using-features.managing.as.html`: "environment includes an Auto Scaling group that manages the Amazon EC2 instances".
- **Y12** `saa-t2-4-q1` + md `:97` — 1단계는 「근거 페이지를 못 찾았다」였는데 **찾았다**: `whitepapers/…/availability-and-beyond-improving-resilience/fault-tolerance-and-fault-isolation.html`(200 r=0): "Fault tolerance is the ability to withstand subsystem failure and maintain availability … another picks up its work, typically **almost seamlessly**". 「완전 무중단 보장」을 그 문장 수준으로 낮추고 출처 추가.
- **Y13** `saa-t4-3-q8` + md `:193` — `aurora-serverless-v2.setting-capacity.html`: "It's tempting to always choose 0.5 … You can also enable automatic pause behavior by specifying a minimum capacity of 0 ACUs" · `aurora-serverless-v2-auto-pause.html`: "You aren't charged for instance capacity while an instance is in the paused state."
- **Y14** `saa-t3-9-q15` + md `:130` — `rekognition/…/streaming-video.html`: "Streaming Video and Bulk Image Analysis is **no longer available to new customers** … does not impact the availability of other Amazon Rekognition features." 상태를 **해설**에 달았다. W3 `Java·Scala·SQL` → `Java·Scala·Python·SQL`(`managed-flink/…/what-is.html`).
- **Y15** `saa-t4-4-q6`·`q7`·`q4` + md — `privatelink/pricing/`: "billed for each hour that your VPC endpoint remains provisioned **in each Availability Zone**"(같은 페이지 예시는 "each endpoint ENI"). 「ENI 요금」을 「AZ별 시간 요금」으로 통일하고 q4 W2 의 「ENI 단위가 아니라」 부정 단정도 걷었다.
- **Y16** md 2자리 — `saa-t2-2.md:365` 「지연도 낮습니다」(`http-api-vs-rest.html` 은 "minimal features … lower price" 까지만) · `saa-t1-3.md:389` 「반드시 NACL」(`waf-rule-statement-type-ipset-match.html`: "allow or block web requests based on the IP addresses").
- **Y17** `saa-t2-5.md:161` — `arc-readiness-availability-change.html`: "no longer open to new customers. Existing customers can continue".
- **Y18** 출처 — **72/90문항**에 사실을 담은 페이지를 더했다(§3·§부록). 새 URL 고유 73개 전부 `200 r=0` + 본문에서 해당 문장 확인.
- **Y19** 블로그 4문항 — **라벨만** 「(공식)」→「(AWS 아키텍처 블로그)」(삭제는 기각 — §2).

### 🟢

- **G5** md 표현 — Memcached 「노드 기반」 한정(`saa-t3-6.md:397·437`) · Lambda 15분에 Managed Instances 한정(`saa-t3-4.md:478·479`, `gettingstarted-limits.html`: 900초 / 5,400초) · DX 암호화에 MACsec 병기(`saa-t3-8.md:430·472`, `saa-t3-8-q7` 정답 보기 「적용해야 한다」→「적용한다」) · Standard-IA 30일을 「그 클래스에 머문 기간」으로(`saa-t4-1.md:197·461·493`).
- **G7** `saa-t3-3-q1`·`q2` — `instance-type-names.html`: "n – Network and EBS optimized" · "b – Block storage optimization".
- **G11** 닫힌 서비스 목록 언급 — App Runner(`apprunner-availability-change.html`: "no longer open to new customers") · AppRegistry(`intro-app-registry.html` 같은 문장) · WAF Classic(`full_shutdown_services.html`: October 7, 2026). md 3줄 + `saa-t1-4-q4` **해설**(오답 근거인 `q12` W3 에는 달지 않았다 — 계약 §2).
- **G12** `saa-t4-5-q7` 「14일 이상」→「기본적으로 최근 14일」(`what-is-compute-optimizer.html`: "The default is 14 days") · `saa-t3-5-q12` 출처 제목의 「되돌릴 수 없음」(그 페이지 표현 아님)을 "it is no longer a read replica" 에 맞춰 개제.

---

## 2. 기각 — 왜 고치지 않았는가

1. **Y19 「블로그 출처를 지운다」** — 기각(라벨만 정정). `saa_question_facts_test.dart:2853` 이 `saa-t4-4-q1·q10·q11` 에 그 블로그 출처를 **요구**한다(2026-10-28 판정: 「요금 페이지의 요율 표는 JS 로 그려져 본문에 없다 — 방향·AZ·피어링·TGW 규칙이 산문으로 적힌 개요 문서를 함께 달아야 한다」). 숙고해서 넣은 출처이고 공식 출처가 함께 달려 있다. 결함은 「블로그를 (공식)이라 부른 것」뿐이다.
2. **Y18 `saa-t4-1-q7` 「약 20% 저렴 — 수치 근거 없음」** — 기각. 인용 페이지 `ebs/…/general-purpose.html` 이 "gp3 volumes offer a **20 percent** lower price per GiB than General Purpose SSD (gp2)" 로 적는다. 1단계 탐침이 `20%` 리터럴이라 놓쳤다(측정 규율 3-③의 「다른 표현」).
3. **G6 `saa-t3-7-q13` 「GLB는 L3/L4에서」** — 기각. 공식이 둘 다 적는다(`gateway/introduction.html` "third layer" ↔ features 비교표 "Layer 3 Gateway + Layer 4 Load Balancing"). 거짓이 아니고 정답과 무관한 오답 근거다. 약칭 `GLB` 통일도 하지 않았다(`saa_t2_t4_facts_test.dart:305` 가 그 표 문자열을 다룬다 — 표기는 별건).
4. **Y14 「지문을 일반화한다」** — 기각. 기존 고객은 계속 쓰는 기능이고 이 레포 관례는 **해설의 상태 메모**다. md `:146` 표 셀(「Rekognition 등 분석 서비스」)은 가르치는 문장이 아니라 대상 열거라 손대지 않았다.
5. **Y15 「200개 이상 서비스 — 근거 없음, 지운다」** — 손대지 않음. 1단계 §6 U6 자신이 「수치를 지우라는 권고가 아니다」로 분류했고 레포 규율(이미 본문에 있는 수치는 건드리지 않는다 · 미확보를 새로 단정하지 않는다)의 범위다. 이 세션도 그 수치의 공식 근거는 찾지 못했다(미확보 그대로).
6. **Y18 「옛 출처를 교체(삭제)한다」** — 대부분 **추가**로 처리하고 4건만 지웠다. 이유: ⓐ 기존 가드가 옛 출처를 요구하는 자리가 많다(`saa_p3_source_fix_test` 의 「소개 페이지를 무조건 걷어내지는 않았다」 대조군 · `saa_question_facts_test` 의 `add` 레코드 · 공유 `source_url_retired_test` 가 `saa-t2-4.questions.json` 에 `framework/reliability.html` 실재를 요구) ⓑ 소개 페이지가 서비스 선택 축은 받친다. 지운 4건은 문항과 무관한 것뿐이다(`t1-3-q7`·`q13` VPC 소개 · `t4-2-q11` RI 개요 · `t4-5-q12` 태그 활성화).

참고 — §6 U6 「라이브에 남은 미확보 단정」 목록의 **본문은 한 건도 건드리지 않았다**(`98-existing-gap` · `saa_gaps_b10b_test` 판정). 다만 그중 둘은 출처로 해소됐다: 스팟 「최대 90%」(`saa-t3-3-q9` · `saa-t4-2-q8`)는 `https://aws.amazon.com/ec2/spot/` 가 "Save up-to 90% on On-Demand Prices" 로 적어 그 페이지를 달았고, gp3 「약 20%」는 아래 기각 2번대로 이미 인용 페이지에 있다. 1단계 U9 의 「Fargate GPU 미지원 — 최신성 위험」은 실측으로 **여전히 참**임을 확인했다(`fargate-tasks-services.html`: Fargate 작업에서 유효하지 않은 파라미터 목록에 `gpu`) → 그 페이지를 출처로 달았다.

---

## 3. 범위 확장 — 보고가 하한이던 자리

| 계열 | 1단계 보고 | 전수 실측 | 더 고친 것 |
|---|---|---|---|
| **Y6** Multi-AZ 한정 | 문항 3 + 「장애조치용」 1 · md 10줄 + 1 | 문항 **5** · md **11줄** | `saa-t3-5-q14` W1(「Multi-AZ 스탠바이는 동기 복제를 사용하므로」) — 보고 목록 밖. 탐지기는 SOA 판과 같은 규칙(Multi-AZ 문맥 + `(?<![비반])동기(?!화)` + 한정어 없음). 거짓 양성 2건(`saa-t3-3.md:233` 「시간 동기화」 · `saa-t3-5-q7` 「쓰기를 동기화」)은 `(?!화)` 로 제외. |
| **Y15** ENI 요금 | 문항 3 · md 1(`t4-4.md:148`) | 문항 3 + **q4 W2** · md **2** | `saa-t1-3.md:235` 「ENI 유지 비용이 발생합니다」. |
| **Y1** 예방 제어 | 문항 2 · md 3 | 문항 **3** · md **4** | q9 W1·md `:254` 의 「SCP가 놓친 드리프트」(같은 전제). |
| **G5ⓑ** Lambda 15분 | md 1(`:478`) | md **2** | `:479` 원리 줄(「15분으로 고정」). |
| **Y18** 출처 | 90문항 표 | 표 72 + **표 밖 13** | 본문을 고친 문항의 근거 페이지 + `saa-t3-3-q1`(명명 규칙 정본). |
| **신규 ①** 스팟 최대 절전 | 없음 | 문항 1 · md 2 | 출처 대조 중 발견 — `spot-instance-termination-notices.html`: "If you specify hibernation as the interruption behavior, you receive an interruption notice, but **you do not receive a two-minute warning because the hibernation process begins immediately**." `saa-t3-3-q8` **정답 보기**가 「2분 전 경고 뒤 종료·중지·최대 절전」으로 뭉뚱그렸다 → 정답 보기·해설·`saa-t3-3.md:165`·`saa-t4-2.md:178`. 정답 인덱스 불변(1). |
| **신규 ②** 비용 최적화 기둥 「공식 정의」 | G2·Y18 로만(출처) | 문항 1 | `saa-t4-5-q14` 해설이 **공식 정의라며 인용부호로 적은 문장이 공식 문장과 다르다**. `framework/cost-optimization.html`: "A cost-optimized workload delivers business outcomes at the **lowest appropriate price point** while meeting its functional requirements and your performance, reliability, security, and sustainability standards." 해설을 그 문장에 맞추고 출처 추가(기존 `cost-optimization-pillar` 출처는 가드가 요구해 유지). |

수정 후 전수 0건을 가드가 고정하는 계열: SNS 재시도 · Lake Formation 일관 · TGW 합산 · NAT 인스턴스 아웃바운드 전용 · Geoproximity Traffic Flow 전용 · 예방 제어 SCP 단독 · 감사 계정 읽기 전용 · Macie 머신러닝 단독 · Multi-AZ 한정 · Batch 무제한 · NAT 인터넷 경유 · EIP 반드시 · 완전 무중단 · 0.5 ACU 기본값 · Java·Scala·SQL · ENI 요금 · 반드시 NACL · 블로그 (공식).

---

## 4. flip 준비 상태

해당 없음 — SAA 는 360/360 이 이미 `verified: true` 다. 이번 수정은 전부 **라이브 핫픽스**이고 `verified` 값은 치환 범위에서 제외돼 원본이 그대로 남았다.

---

## 5. 컨트롤러 요청

- [ ] **`CLAUDE.md` 기준선 +62** — `test/saa_v2_fix_test.dart` 62 테스트(다른 공유 테스트 수는 건드리지 않았다).
- [ ] **`assets/exam_guides/SAA-C03.json` 4문장(Y20)** — 1.2 지식 5(`AWS Cognito·GuardDuty·Macie` → `Amazon …`) · 3.4 지식 3·4.4 지식 3(`Application Load Balancer` → `Application Load Balancer(ALB)`) · 3.5 지식 1(`Amazon QuickSuite` → `Amazon Quick`). 공유 파일이라 손대지 않았다. SAA 가이드 동기화 가드도 없다(CLF·SOA·AIF·SCS·AIP 에는 있다).
- [ ] **`test/saa_question_propagation_test.dart` `_rules` 정리(G9)** — 이 세션은 새 가드 파일 하나만 쓸 수 있어 기존 파일을 고치지 않았다. ⓐ `'**Java·Scala·SQL**'` 은 별표 때문에 평문 문항과 일치할 수 없다 ⓑ `G-1.1-10` 의 why 주석 「35일 유예」는 14일이 맞다. 어형으로 비켜 가던 리터럴 규칙 다섯(R1·R2·R3·Y9·Y15)은 새 가드의 정규식이 덮는다.
- [ ] **계약 파일을 이 브랜치로** — `01-PHASE2-CONTRACT.md`(`8884494`)가 `content/phase2-fable-2026-11-17` 에 없다.
- [ ] 교차 자격증 — 1단계 §5 의 SOA 3계열(Geoproximity · Macie · RDS Magnetic)과 이번에 닫은 12계열을 현재 워킹트리의 다른 자격증 `assets/content/**` 에 grep 하니 **0건**이다(형제 세션이 이미 닫았다. SCS 의 `예방 제어는 SCP` 3건은 그 오해를 반박하는 올바른 자리). 새로 찾은 「스팟 최대 절전 2분 경고」 계열도 다른 자격증 0건.
- [ ] (선택) `test/source_url_retired_test.dart` 예방 등재 — 이 세션이 실측한 죽은 슬러그(레포 콘텐츠 0건): `waf/latest/developerguide/waf-ip-set-match.html`(정본 `waf-rule-statement-type-ipset-match.html`) · `organizations/…/orgs_manage_policies_scps_examples_general.html` · `wellarchitected/latest/reliability-pillar/rel_service_architecture_stateless.html` · `drs/…/Supported-Operating-Systems.html` · `servicecatalog/latest/arguide/appregistry-availability-change.html` — 전부 `200 r=1`.
- [ ] 정답 인덱스 변경이 필요한 문항: **없음**.

---

## 6. 남긴 것 — 다음 배치

- **Y18 잔여 17문항**(대체 출처를 확인하지 못했거나 「경미」): `saa-t1-2-q7`(SCP 로 CloudTrail 보호 예시 — 추정 슬러그가 죽어 있었다) · `saa-t1-2-q13` · `saa-t2-2-q4` · `saa-t2-2-q14` · `saa-t2-3-q9`(「ML」 문구) · `saa-t2-4-q3` · `saa-t2-4-q10` · `saa-t2-4-q15`(종합 문항 — 한 페이지로 안 닫힌다) · `saa-t2-5-q10`(DRS 소개 페이지에 블록 수준·OS 서술 없음) · `saa-t3-3-q6`(Graviton 「최대 40%」 — `aws.amazon.com/ec2/graviton/` 에 `40%` 0건, U6 계열) · `saa-t3-4-q3` · `saa-t3-6-q13` · `saa-t3-9-q1`·`q2`·`q4`·`q8` · `saa-t4-1-q14`.
- **미검증으로 남긴 서술**: 「Fargate(ECS)는 실행 시간 제한이 없다」 3자리(`saa-t2-2.md:411` · `saa-t2-2-q14` 해설 · `saa-t3-4-q1` W3) — 1단계도 Y7 대상에서 뺐고 이 세션도 공식 근거를 재지 않았다.
- **G1** length-cue 147문항 · **G3** explanation-long 3 · **G4** 교차 Task 중복 16쌍(라이브 문항 교체 = 사람 승인) · **G10** 정답 인덱스 분포(루브릭상 고치지 않는다).
- **사람 판정**: U4(Snowball Edge 를 정답으로 두는 문항) · U8(EventBridge 「Custom Event Bus 로 시작」 권고 반영) · G8(`section` 빈 값 — 실측하면 SAA 문항에는 `section` 키 자체가 없다).
- **관찰(고치지 않음)**: `saa-t2-4.md:561` 근거 목록에 AWS 데이터베이스 블로그 1건 · 학습문서에 「📝 정정 메모」 줄은 추가하지 않았다(줄 수 불변으로 치환했다 — `lastVerified` 만 19편 올림).

---

## 부록 — Y18 출처 추가 내역(문항 → 더한 페이지)

전부 2026-11-17 `curl -sL` 로 `200 r=0` + 본문에서 해당 사실 확인. 목록의 정본은 가드의 `added` 표다(`saa_v2_fix_test.dart` 「Y18」 그룹, 79문항 85개 출처).

- IAM·Organizations: `t1-1-q2`(id_roles_use_switch-role-ec2) · `t1-1-q3`(lambda-intro-execution-role) · `t1-1-q15`(id_root-enable-root-access — "New accounts you create in AWS Organizations have no root user credentials by default") · `t1-2-q1`·`q4`(orgs_manage_policies_scps_evaluation) · `t1-2-q15`(백서 benefits-of-using-multiple-aws-accounts)
- VPC·보안: `t1-3-q4`(custom-network-acl — ephemeral 1024-65535) · `t1-3-q9`·`q10`(gateway-endpoints) · `t1-3-q13`(flow-logs) · `t1-4-q1`(aws-managed-rule-groups-baseline) · `t1-4-q3`(shield/features + ddos-request-service-credit) · `t1-4-q6`(web-acl-processing-order) · `t1-4-q11`(parameter-store-advanced-parameters — Cost: No additional charge) · `t1-4-q12`(distribution-web-awswaf)
- 결합·서버리스: `t2-1-q4`(sqs-dead-letter-queues) · `t2-1-q9`(eb-event-patterns) · `t2-1-q10`(eb-saas) · `t2-2-q2`(provisioned-concurrency) · `t2-2-q6`(lambda services-rds) · `t2-2-q9`(apigateway-use-lambda-authorizer) · `t2-2-q11`(eks what-is-eks) · `t2-2-q12`(fargate-tasks-services) · `t2-2-q15`(configuration-vpc-internet)
- 확장·복원력: `t2-3-q5`(how-elastic-load-balancing-works + NLB edit-target-group-attributes — "EC2 data transfer charges apply") · `t2-3-q10`·`q11`(ec2-auto-scaling-lifecycle) · `t2-3-q12`(ec2-auto-scaling-health-checks) · `t2-3-q14`(launch-templates) · `t2-4-q2`·`q11`(nat-gateway-basics — "resources in the other Availability Zones lose internet access") · `t2-4-q5`·`q14`(Concepts.MultiAZ.Failover — "typically 60–120 seconds") · `t2-4-q8`·`q13`(dns-failover-types) · `t2-4-q9`(REL11-BP05) · `t2-4-q12`(REL10-BP01)
- 스토리지·컴퓨팅·DB: `t3-1-q6`(lifecycle-transition-general-considerations) · `t3-2-q2`(general-purpose) · `t3-2-q7`·`q14`(ebs-snapshots — 증분·S3·리전 내 전 AZ 복제를 한 페이지가 다 담는다) · `t3-3-q1`·`q2`(instance-type-names) · `t3-3-q9`·`t4-2-q8`(ec2/spot — "Save up-to 90%") · `t3-3-q10`·`q13`(placement-strategies) · `t3-3-q14`(efa) · `t3-4-q7`(batch_components) · `t3-5-q5`(Concepts.AuroraHighAvailability + Aurora.Overview.StorageReliability) · `t3-6-q8`(DAX.consistency) · `t3-6-q9`(V2globaltables_HowItWorks)
- 네트워크·분석: `t3-7-q11`·`q12`(global-accelerator introduction-how-it-works) · `t3-8-q8`(REL02-BP02 — "cost-effective backup to your primary AWS Direct Connect connection") · `t3-9-q7`(athena columnar-storage)
- 비용: `t4-1-q8`(ec2-instance-lifecycle — "Charges are incurred for the storage of any Amazon EBS volumes") · `t4-1-q9`·`t4-5-q7`(awssupport cost-optimization-checks) · `t4-2-q1`(ec2-on-demand-instances) · `t4-2-q11`(ec2-auto-scaling-scheduled-scaling) · `t4-3-q6`(USER_PIOPS.ModifyingExisting + Autoscaling) · `t4-4-q8`(CloudFront Introduction) · `t4-4-q9`(cache-hit-ratio) · `t4-5-q5`(cost-allocation-backfill) · `t4-5-q12`(orgs_manage_policies_tag-policies) · `t4-5-q14`(framework/cost-optimization)
