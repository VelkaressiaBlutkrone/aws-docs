# CLF-C02 · DVA-C03 전수 검증 — 2026-11-17

> 1단계(검증) 산출물이다. **콘텐츠·코드·테스트·가이드 JSON 은 한 글자도 고치지 않았다.** 아래의 「수정안」은 2단계 세션이 판단 없이 집행할 수 있게 적은 제안이고, 문항 교체·정답 변경·`verified` 는 사람 승인 영역이다.
> 범위: `flutter_app/assets/content/clf/`(md 19 · 문항 301, 전부 `verified: true` 라이브) · `flutter_app/assets/audio/clf/**/script.json`(발화 본문) · `flutter_app/assets/content/dva/`(md 12 · 문항 0, 미등재) · `exam_guides/CLF-C02.json` · `exam_guides/DVA-C02.json`.
> 판정 근거는 전부 2026-11-17 에 `curl -sL` 로 받은 공식 페이지 본문이다(`docs.aws.amazon.com` · `aws.amazon.com`). 대조군 재현: 있는 가이드의 없는 슬러그 `200 r=1` · `aws.amazon.com` 없는 경로 `404 r=0`.

---

## 0. 요약

### CLF-C02

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | 2 | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) |
| 🟡 | 13 | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) |
| 🟢 | 7묶음 | 품질(길이 단서·메타 문구·중복) — 사실은 옳다 |
| ✅ | 12축 | 통과 (§0 끝 표) |

- **공개 문항 중 🔴: 4건** (`clf-t4-3-q1` · `clf-t4-3-q3` · `clf-t4-3-q6` · `clf-t4-3-q13`). **정답 인덱스는 넷 다 그대로 옳다** — 거짓은 지문·해설·오답 근거·정답 보기의 귀속 문구에 있다. 같은 거짓이 **라이브 학습문서 `t4-3.md` 3곳**과 **승인된 라이브 음성 `clf-t4-3` 5개 세그먼트**에 번져 있다.
- `prescreen`(`node tool/prescreen.mjs build clf`): 구조·정합성 플래그 **0건** · 뱅크 플래그 0 · 품질 신호 **91/301문항(30%)** — length-cue 88 · meta-phrasing 6 · authoring-memo 1 · explanation-long 0 · Task 내 중복 후보 30쌍(정답 문자열 동일 9쌍).
- 검증한 출처 URL: 문항 고유 **158개**(학습문서까지 합치면 161개) 중 **본문을 받아 인용 사실을 대조한 것 49개**. 그중 **「그 사실을 담지 않음」 8개**(§2 C-Y4·C-Y5·C-Y8). ⚠️ 나머지 112개는 본문 대조를 하지 않았다 — 통독에서 의심이 든 인용(수치·직접 인용문·소개 페이지에 얹힌 세부 사실)을 골라 쟀다. URL 생사는 오늘 전수 측정됐으므로 다시 재지 않았다.

### DVA-C03 (미등재 — 라이브 404 가 정상)

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | 1 | 사실이 거짓 (즉시 수정) |
| 🟡 | 6 | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) |
| 🟢 | 5 | 품질·표기 — 사실은 옳다 |
| ✅ | 9축 | 통과 |

- 공개 문항 중 🔴: **0건**(문항 없음 · 미등재). 🔴 1건은 학습문서 `dva-t2-1.md` 의 서술이다.
- `prescreen`: 해당 없음(문항 0개, `CERTS` 미등록).
- 검증한 출처 URL: 12편 고유 **243개** 중 실제 URL **238개 전부 `200 r=0`**(나머지 5개는 코드 예시의 자리표시자: `http://127.0.0.1:3001` · `http://localhost/` · `https://<url-id…` · `https://<브랜치…` · `https://cognito-idp.<Region…`). 238개 본문 전체를 대상으로 수치·한도·인용문 약 70항목을 정규식으로 대조했다. **「그 사실을 담지 않음」 3개**(§2 D-Y3·D-Y4, §6).

### 통과한 축 (✅)

| 자격증 | 축 | 어떻게 셌나 |
|---|---|---|
| CLF | 가이드 JSON 동기화 | `CLF-C02.json` 의 지식·기술 **135/135 항목**이 오늘 공식 ko 도메인 페이지 4편에 있음(공백 무시). 도메인명·Task 제목 불일치 0 |
| CLF | 구조·정합성 | prescreen 플래그 0 · `wrongExplanations` 키 불일치 0 · 보기 4개 |
| CLF | 평문 표기 | 문항 301개에서 `[텍스트](링크)` 0 · `**굵게**` 0 · 단일 `*이탤릭*` 0 (백틱만 1문항 — §3) |
| CLF | Kendra·Audit Manager·Forecast 상태 | 문항·md 의 날짜가 전용 페이지와 일치 — Kendra `as of July 30, 2026 … no longer open to new customers` · Audit Manager `from April 30th 2026` |
| CLF | 프리 티어(2026-11-06 교체분) | `clf-t4-1-q10` · `t4-1.md`: $100 + 최대 $100 추가 · 6개월 · 30+ always free · `Free account plan only have Always Free offerings active` 모두 인용 페이지에 있음 |
| CLF | 비용 할당 태그(교체분) | `clf-t4-2-q10`·`q12`: `two types` · `activate both types of tags separately` · `aws:createdBy` · `applied … after the AWS-generated tag is activated` 있음 |
| CLF | 데이터 전송·CE·S3 클래스 | `clf-t4-1-q4`·`q13`·`clf-t4-2-q2`·`clf-t3-6-q5` 의 수치·문구가 인용 페이지에 있음 |
| CLF | 지난 보고 N-2 | **재판정 — 결함 아님.** `vpn/latest/s2svpn/VPC_VPN.html` 이 `AWS SDKs — Provide language-specific APIs and takes care of many of the connection details, such as calculating signatures, handling request retries, and error handling` 를 그대로 싣는다(출처로는 어색하나 사실을 담는다) |
| CLF | 직접 인용문 | `t2-2.md`(Artifact·Audit Manager·CloudTrail) · `t2-4.md:87`(SG/NACL) 인용문이 인용 페이지에 글자 그대로 있음 |
| CLF | 닫힌 서비스 전수 sweep | AWS Lifecycle 세 목록(유지 관리 56 · 종료 예정 16 · 완전 종료 62) × CLF md·문항·발화. 미표기는 §2 의 셋(Snowball·Simple AD·FSx File Gateway)뿐 |
| CLF | 오디오 승인 상태 | 18편 `approved`(라이브) · `clf-t3-8` 1편 `needs_human_review`(`audioApproved: false` 비노출) |
| CLF | 정답 인덱스 | 이 보고서가 적는 인덱스는 전부 JSON 에서 읽은 값이다(분포 0:228 / 1:32 / 2:27 / 3:14 — 앱이 셔플하므로 결함 아님) |
| DVA | 출처 URL 생사 | 238/238 `200 r=0` |
| DVA | 공식 기술 커버리지 | DVA-C03 공식 기술 **72개**(작업 12개) 전부가 해당 md 에 번호로 언급됨. 작업 제목 12/12 일치 |
| DVA | 도메인·비중 | md 12편 `certCode: DVA-C03` · 30/26/22/22 = 공식 「내용 개요」 |
| DVA | 범위 외 서비스 언급 | Quick Sight·Polly·Rekognition·SageMaker AI·Strands Agents 언급은 전부 「범위 밖」 경고 문맥 |
| DVA | 지난 보고 P2-J | **해소.** `AmazonS3/latest/userguide/using-presigned-url.html` 이 `IAM role credentials used by Amazon EC2 instances – Valid for the duration of the role credentials (typically 6 hours)` 를 싣는다 — 「보통 6시간」은 이제 공식 근거가 있다 |
| DVA | 수치·한도 약 70항목 | Lambda(6 MB·200 MB 스트림·1 MB 비동기·1,769 MB·1,000 env/10초·ENI 65,000·14일) · SQS(1 MiB·ESM 1,250·in-flight 120,000) · SNS(100,015회·23일) · EventBridge(24시간·185회) · KDS EFO(70/200/1,000 ms) · DynamoDB(파티션 3,000/1,000 · MRSC 정확히 3개 리전·트랜잭션 API 미지원 · TTL 시간당 1회 · DAX 90%) · Cognito(RSA 키 쌍 둘) · ACM(198일·45일) · Bedrock(15분·30일·옵트아웃 정책 비대상) · Logs Insights(QL 100·PPL/SQL 15·Essentials 클래스) · `PutMetricFilter` 1,000쌍 · `aiops` 콘솔 전용 · API Gateway JWT 키 캐시 2시간 등 — 인용 페이지에 있음 |
| DVA | 지난 보고 N-3 | 오늘도 참. `sdkref/latest/guide/feature-retry-behavior.html`: `requires opting in until it becomes the default behavior. Set AWS_NEW_RETRIES_2026=true` — 다만 시점에 묶인 서술이므로 12월 등재 직전 재확인 필요(§7) |
| DVA | 지난 보고 N-4 | 부분 반영됨. `dva-t4-1.md:45` 용어 메모가 Web Functions·MicroVMs 를 언급한다 |

---

## 1. 🔴 (문항·학습문서)

### CLF

#### C-R1. 「Enterprise = 최상위 플랜 · 가장 빠른 응답 · TAM 은 Enterprise 에서만」 — 현행 4플랜 체계에서 거짓

- **공개 여부**: 문항 4개 전부 `verified: true` 라이브 · 학습문서 라이브 · 음성 `clf-t4-3` `approved` 라이브.
- **현재 정답 인덱스(실측)**: `clf-t4-3-q1` = 0 · `clf-t4-3-q3` = 0 · `clf-t4-3-q6` = 0 · `clf-t4-3-q13` = 0. **넷 다 정답은 그대로 옳다**(보기에 Unified Operations 가 없어 Enterprise/하향 조정이 최선). 거짓은 아래 문구다.
- **결함(문구 그대로)**
  - `clf-t4-3-q3` 지문: 「…케이스에 대한 **가장 빠른(약 15분) 응답**이 필요하다」 / 해설: 「…전략 검토 등을 제공하는 **최상위 플랜**입니다」
  - `clf-t4-3-q1` 오답 근거 W2: 「Enterprise Support는 전담 TAM 등을 포함하는 **최상위 유료 플랜**」
  - `clf-t4-3-q6` 오답 근거 W2: 「Enterprise Support는 전담 TAM 등을 포함하는 **최상위 플랜**」
  - `clf-t4-3-q13` 지문: 「…15분 응답이 포함된 **최상위 Support 플랜**」 · 오답 보기[1]: 「**최상위 Enterprise 플랜**을 유지해야…」 · 해설: 「…포함된 **최상위 플랜**을 유지하는 것은…」
  - `t4-3.md:149`: 「TAM은 … 가장 높은 미션 크리티컬 요구를 가진 **Enterprise 플랜에서만 포함된다**」 · `t4-3.md:41`: 「Support 플랜의 사다리(Basic 무료 → Enterprise TAM)」 · `t4-3.md:82`: 「미션 크리티컬 환경은 Enterprise의 전담 TAM과 짧은 응답 목표」
- **공식 근거**
  - `https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html` (200 r=0) — 플랜 목록: `Basic` · `AWS Business Support+` · `AWS Enterprise Support` · `AWS Unified Operations`. Unified Operations 항목: `Designated AWS Technical Account Manager (TAM) and Domain Specialist Engineer (DSE) for your specific use cases and applications.` Enterprise 항목: `A designated Technical Account Manager (TAM).` `Up to 15 minute production-critical case response.`
  - `https://aws.amazon.com/premiumsupport/plans/` (200 r=0) — 비교표 「Human response times · Business/Mission-critical system down」: Business Support+ `< 30 mins` / Enterprise Support `< 15 mins` / Unified Operations `< 5 mins from Incident Management Engineer`. 「Recommended for」: Enterprise = `Recommended plan for business-critical workloads across organizations looking for expert guidance.` / Unified Operations = `Recommended plan for mission-critical workloads that require enhanced resilience and application-specific expertise.`
  - `https://docs.aws.amazon.com/awssupport/latest/user/unified-operations-intro.html` (200 r=0) — `A five-minute, context-aware response for critical incidents`
  - 공식 가이드 작업 4.3 기술(레포 JSON 과 일치): 「…(예: 고객 서비스 및 커뮤니티, 기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations)」
- **수정안** (정답 인덱스·보기 구성 불변)
  - `q3` 지문: 「가장 빠른(약 15분) 응답」 → 「**약 15분 응답**」(최상급 삭제). 해설: 「최상위 플랜입니다」 → 「**상위 플랜입니다(현행 4플랜 중 그 위에 5분 응답의 AWS Unified Operations 가 있습니다)**」.
  - `q1` W2 · `q6` W2: 「최상위 (유료) 플랜」 → 「**상위 유료 플랜**」.
  - `q13` 지문·오답 보기[1]·해설: 「최상위」 → 「**상위**」(세 곳).
  - `t4-3.md:149`: 「Enterprise 플랜에서만 포함된다」 → 「**Enterprise Support 와 그 위의 AWS Unified Operations 에 포함되고, Business Support+ 에는 없다**」. `:41` 의 사다리는 「Basic 무료 → Business Support+ → Enterprise(TAM) → Unified Operations」로, `:82` 는 「비즈니스 크리티컬은 Enterprise, 미션 크리티컬은 Unified Operations 가 공식 권장」으로.
  - ⚠️ `t4-3.md:32·75·134·148·174` 의 「전담 TAM = Enterprise」는 **거짓이 아니다**(Enterprise 도 TAM 을 포함한다 — 「Business 부터 제공된다」를 반박하는 문맥). 배타 서술은 `:149` 뿐이므로 일괄 치환하지 않는다.
- **발화에 전파된 자리(`clf-t4-3`, approved)**: **seg033**(「전담 티에이엠 … 엔터프라이즈 플랜**에만** 포함됩니다 … 엔터프라이즈 플랜**에서만**」 — 거짓) · **seg030**(「**가장 빠른 응답**과 전담 지원이 필요하다면 엔터프라이즈」 — 거짓) · **seg006**(사다리 「베이직 … 엔터프라이즈까지」) · **seg009**(table: 티어 「베이식·디벨로퍼·비즈니스·엔터프라이즈 순」, 미션 크리티컬 = 엔터프라이즈) · **seg015**(「미션 크리티컬 환경 … 엔터프라이즈의 전담 티에이엠」). seg012·seg013(TAM + 15분 = Enterprise)은 참이므로 대상이 아니다. md 를 고치면 재합성 → `reviewStatus` 가 `needs_human_review` 로 리셋된다(청취 재승인·R2 발행은 사람).
- **같은 문구 전수 grep**: 「최상위」 — clf 문항 6곳(q1 W2 · q3 exp · q6 W2 · q13 stem/opt1/exp) + 무관 1곳(`clf-t3-2-q15` W3, 엣지 로케이션 문맥) · clf md 0 · 발화 0(음차 「가장 빠른」「에만/에서만」으로 존재). 「Unified Operations」 — clf md 1줄(`t4-3.md:77`) · 문항 2(`q7`·`q10` 해설) · 발화 seg014.

#### C-R2. 정답 보기가 「시험 가이드 기준 … 업무 시간 지원 플랜」으로 귀속 — 현행 가이드에 그런 플랜이 없다

- **공개 여부**: `clf-t4-3-q13` `verified: true` 라이브.
- **현재 정답 인덱스(실측)**: 0.
- **결함**: 정답 보기[0] 「워크로드 중요도에 맞춰 더 낮은 유료 기술 지원 플랜(**시험 가이드 기준** 개발·테스트 워크로드용 업무 시간 지원 플랜)으로 다운그레이드한다」 · 해설 「(구체적 플랜 구성·명칭은 시점에 따라 변동될 수 있으므로 **시험 가이드 기준**으로 이해)」. 공식 가이드 작업 4.3 의 지원 옵션 예시는 「기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations」이고 Developer Support(업무 시간 지원)가 없다 — 귀속이 거짓이다(2026-11-06 P1-4 계열의 잔존).
- **공식 근거**: `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain4.html` (200 r=0) 작업 4.3 기술. `aws-support-plans.html`: `Developer Support will be discontinued January 1, 2027.` · Business Support+ = `24x7 phone, web, and chat access to Cloud Support Engineers` · 비교표 `Minimum recommended plan for production workloads by AWS.`
- **수정안**: 보기[0] 의 괄호를 걷는다 → 「워크로드 중요도에 맞춰 **더 낮은 유료 지원 플랜**으로 다운그레이드한다」(정답 인덱스·나머지 보기 불변 — 길이 단서도 줄어든다). 해설의 「시험 가이드 기준으로 이해」 → 「**현행 최저 유료 플랜은 Business Support+ 이고 Developer Support 는 2027-01-01 단종 예정**」. 오답 보기[3] 「Basic … 업무 시간 기술 질문 케이스 지원」의 근거(W3)는 그대로 유효하다.
- **같은 문구 전수 grep**: 「시험 가이드 기준」 — clf 문항 2곳(이 문항 opt0·exp) · md 0 · 발화 0.

### DVA

#### D-R1. 「역할 체이닝 1시간 상한은 콘솔 역할 전환에는 해당하지 않는다」 — 인용 페이지와 반대

- **공개 여부**: 미등재(라이브 아님). 12월 전환 PR 전에 닫아야 한다.
- **현재 정답 인덱스**: 해당 없음(학습문서).
- **결함**: `dva-t2-1.md:267` 「역할 체이닝…은 CLI·API 세션을 최대 1시간으로 제한하고 늘릴 수 없습니다(**콘솔 역할 전환에는 해당하지 않습니다**)」. 같은 편 `:90`(용어) · `:354`(자가 점검 정답)는 「CLI·API 세션이 최대 1시간」으로만 적어 불완전하다.
- **공식 근거**: 이 문서가 인용하는 `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html` (200 r=0) — `You can perform role chaining through the AWS Management Console by switching roles, the AWS CLI, or API.` / `Role chaining limits your AWS Management Console, AWS CLI or AWS API role session to a maximum of one hour. It applies regardless of the maximum session duration configured for individual roles.`
- **수정안**: `:267` 의 괄호를 「(**콘솔에서 역할을 전환해 체이닝하는 경우에도 같다 — 역할별 최대 세션 설정과 무관**)」로 교체. `:90`·`:354` 의 「CLI·API 세션」 → 「**콘솔·CLI·API 역할 세션**」.
- **같은 문구 전수 grep**: 「체이닝」(역할 문맥) dva md 8줄 — `dva-t2-1.md:52·76·90·267·269·284·304·354`. 거짓 서술은 `:267` 1곳, 불완전 2곳(`:90`·`:354`).
- **교차**: 레포는 SAA 에서 이미 「역할 체이닝 1시간 상한은 콘솔에도 적용된다」로 판정해 두었다(CLAUDE.md B11 항목) — §5.

---

## 2. 🟡 (같은 형식)

### CLF

#### C-Y1. AWS Snowball — 신규 고객 중단·지원 종료 예정을 「제한될 수 있다」로만 적고, 문항은 상태 없이 정답으로 쓴다

- **공개 여부**: 라이브. **정답 인덱스(실측)**: `clf-t1-3-q3` = 0(정답 「AWS Snowball」) · `clf-t1-3-q14` = 0 · `clf-t1-3-q9` = 0(B 항이 Snowball) · `clf-t1-3-q8` = 1(Snowball 동작을 묻는다).
- **결함**: 네 문항 해설·지문에 상태 표기가 없다. `t1-3.md:94` 정직성 메모는 「일부 디바이스(예: Snowball Edge)는 공식 문서 기준 **신규 고객 등록이 제한될 수 있습니다**」로 적는데, 공식은 가정법이 아니라 단정이고 **지원 종료일**까지 공지했다. 같은 편 `:35·43·44·100·128·130·138·162` 가 Snowball 을 「이 조건이면 정답」으로 가르친다.
- **공식 근거**
  - 문항이 인용하는 바로 그 페이지 `https://docs.aws.amazon.com/snowball/latest/developer-guide/whatisedge.html` (200 r=0): `AWS Snowball Edge is no longer available to new customers. New customers should explore AWS DataSync for online transfers, AWS Data Transfer Terminal for secure physical transfers, or AWS Partner solutions. For edge computing, explore AWS Outposts.`
  - `https://aws.amazon.com/snowball/` (200 r=0): `End of support notice: On December 31, 2026, AWS will discontinue support for AWS Snowball devices in all AWS commercial Regions. This includes both the AWS Snowball Edge Storage Optimized and Compute Optimized devices. After December 31, 2026, you will no longer be able to access the AWS Snow Console or AWS Snowball resources.`
  - 공식 가이드: 「범위 내」·「범위 외」 목록 모두에 Snow 0건, 작업 1.3 기술은 「적절한 마이그레이션 전략 파악(예: 데이터베이스 복제)」(레포 `t1-3.md:96` 메모가 이미 적는다).
- **수정안**: ① `t1-3.md:94` 를 「**AWS Snowball Edge 는 신규 고객에게 제공되지 않고(공식 대안: 온라인은 DataSync · 물리 전송은 Data Transfer Terminal), 상용 리전에서는 2026-12-31 에 지원이 종료됩니다**」로 교체. ② 가르치는 층 네 문항의 `explanation` 끝에 같은 상태 한 줄을 붙인다(오답 보기·오답 근거로만 나오는 `clf-t1-3-q1·q4·q5·q7·q12·q15` · `clf-t1-4-q2·q4·q5` · `clf-t4-3-q8` 에는 붙이지 않는다 — 틀린 보기를 설명하는 문장이 된다). ③ 문항을 「오프라인 물리 전송」 개념 문항으로 유지할지, DataSync·Data Transfer Terminal 로 교체할지는 **사람 판단**(2026-12-31 이후에는 정답 서비스가 존재하지 않는다).
- **발화에 전파된 자리(`clf-t1-3`, approved)**: **seg021**(「스노우볼 엣지 같은 경우는 … 신규 고객 등록이 제한될 수 있습니다」) · seg006 · seg017(heading) · seg019(table) · seg029 · seg031(Snowball 을 정답으로 가르침).
- **전수 grep**: `Snowball|Snow Family` — clf md 34(전부 `t1-3.md`) · 문항 가르치는 층 13(4문항) · 오답층 26 · 출처 제목 4 · 발화 12 이상(`clf-t1-3`).

#### C-Y2. Simple AD — 신규 고객 중단 상태 없이 선택지로 가르친다

- **공개 여부**: 라이브(md). **정답 인덱스**: `clf-t2-3-q17` = 0(Simple AD 는 오답 보기[2] — 문항은 손대지 않는다).
- **결함**: `t2-3.md:223` 표 행 「**Simple AD** | Samba 기반의 기본 AD 호환 디렉터리 | 저비용·소규모의 기본 디렉터리가 필요할 때」.
- **공식 근거**: `https://docs.aws.amazon.com/directoryservice/latest/admin-guide/directory_simple_ad.html` 본문 첫머리 `Simple AD is no longer open to new customers. For capabilities similar to Simple AD, explore AWS Managed Microsoft AD or AD Connector.` · AWS Lifecycle 유지 관리 목록 `AWS Directory Service – Simple AD | June 30, 2026`(`https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html`, 200 r=0).
- **수정안**: 표 행 끝에 「(**신규 고객에게 열려 있지 않음 — 공식 대안은 AWS Managed Microsoft AD·AD Connector**)」를 더한다.
- **발화**: `clf-t2-3` **seg052**(table).
- **전수 grep**: `Simple AD` — clf md 1 · 문항 2(오답 보기·오답 근거).

#### C-Y3. FSx File Gateway — Storage Gateway 유형으로 상태 없이 나열

- **공개 여부**: 라이브. **정답 인덱스**: `clf-t3-6-q6` = 0(출처 제목에만 등장).
- **결함**: `t3-6.md:167` 「유형: S3 File Gateway, **FSx File Gateway**, Tape Gateway…, Volume Gateway…」 · `clf-t3-6-q6` 출처 제목 「…(S3 File·**FSx File**·Tape·Volume 유형별 가이드)」.
- **공식 근거**: `https://docs.aws.amazon.com/filegateway/latest/filefsxw/what-is-file-fsxw.html` (200 r=0): `Amazon FSx File Gateway is no longer available to new customers. Existing customers of FSx File Gateway can continue to use the service normally.` · Lifecycle 유지 관리 목록 `Amazon FSx File Gateway | October 28, 2024`.
- **수정안**: `t3-6.md:167` 에 「(FSx File Gateway 는 신규 고객에게 제공되지 않음)」 병기. 출처 제목은 그대로 두어도 무방하다(문서 인덱스가 실제로 네 가이드를 나열한다).
- **발화**: `clf-t3-6` **seg038**(「유형은 네 가지 … 에프에스엑스 파일 게이트웨이」).
- **전수 grep**: `FSx File` — clf md 1 · 문항 출처 제목 1.

#### C-Y4. 가이드 **개요** 페이지를 Task 기술의 출처로 인용 — 그 페이지에는 Task 기술 문구가 없다

- **공개 여부**: 20문항 전부 라이브. **정답 인덱스(실측)**: `clf-t2-2-q15`=0 · `clf-t2-4-q15`=0 · `clf-t3-1-q4`=0 · `clf-t3-1-q12`=0 · `clf-t3-1-q14`=0 · `clf-t3-1-q15`=0 · `clf-t3-2-q11`=0 · `clf-t3-2-q12`=0 · `clf-t3-4-q11`=0 · `clf-t3-8-q15`=0 · `clf-t4-1-q4`=0 · `clf-t4-1-q13`=0 · `clf-t4-2-q6`=0 · `clf-t4-2-q15`=0 · `clf-t4-3-q4`=0 · `clf-t4-3-q5`=0 · `clf-t4-3-q8`=2 · `clf-t4-3-q9`=0 · `clf-t4-3-q14`=0 · `clf-t4-3-q15`=0.
- **결함**: 인용 URL `…/cloud-practitioner-02/cloud-practitioner-02.html` 은 서론·시험 형식·도메인 비중·서비스 참조만 담고, 출처 제목이 가리키는 「Task n.m Skill '…'」 문구는 도메인 페이지에 있다. **유일 출처인 문항이 9개**다: `clf-t3-2-q12` · `clf-t3-8-q15` · `clf-t4-2-q6` · `clf-t4-3-q4` · `q5` · `q8` · `q9` · `q14` · `q15`. 출처 제목 자체가 공식과 다른 것이 둘이다 — `clf-t3-2-q12` 「리전 선택 기준(**가격 포함**)」(공식 3.2 기술: 「다중 리전을 사용하는 경우 설명(예: 재해 복구, 비즈니스 연속성, 최종 사용자를 위한 짧은 지연 시간, 데이터 주권)」 — 가격 없음) · `clf-t2-4-q15` 「보안 정보 위치(Knowledge Center·Security Blog·**re:Post**)」(공식 2.4: 「AWS Knowledge Center, AWS **Security Center**, AWS Security Blog」).
- **공식 근거(제안 정본, 전부 200 r=0 · 본문 확인)**: `…/cloud-practitioner-02/cloud-practitioner-02-domain1.html` ~ `-domain4.html` · 서비스 범주는 `…/cloud-practitioner-02/clf-02-in-scope-services.html`.
- **수정안**: 20문항의 해당 출처 URL 을 Task 의 도메인 페이지로 바꾼다(도메인 2 → `-domain2.html`, 3 → `-domain3.html`, 4 → `-domain4.html`). `clf-t3-8-q15` 는 `clf-02-in-scope-services.html`. 두 제목은 공식 문구로 고친다. 학습문서 19편의 프런트매터·출처 절(38곳)도 같은 개요 URL 이므로 각 편의 도메인 페이지를 **추가**한다(개요 페이지는 비중·형식 근거로 남겨도 된다).
- **전수 grep**: 개요 URL — clf 문항 20곳 · clf md 38곳(19편 × 2).

#### C-Y5. 인용 페이지가 그 사실을 담지 않는다 — 8문항

각 항목: 문항 `[정답 인덱스]` · 결함 · 측정 · 제안(전부 `200 r=0` + 본문에 그 사실 있음 확인).

| 문항 | 인용 페이지에 없는 것 | 측정(추출 길이 · 대조군) | 제안 정본 |
|---|---|---|---|
| `clf-t1-1-q13` [1] | 해설의 「가상화(virtualization)」 원리 | `aws.amazon.com/what-is-cloud-computing/` 14,827자 — `virtualiz` 0건(`virtual` 4건은 `virtually`·`virtual desktops` 등), 대조군 `economies of scale` 1건 | `https://aws.amazon.com/what-is/virtualization/` — `run multiple virtual machines simultaneously on a single physical machine` |
| `clf-t1-4-q8` [2] | 출처 제목의 「TCO 추정·온프레미스 대비 비용 비교」 · 「숨은 비용(전력·냉각·공간·인력)」 | `pricing-calculator/…/what-is-pricing-calculator.html` 3,374자 — `TCO` 0 · `on-premises` 0, 대조군 `free web-based planning tool` 있음. 둘째 출처에도 전력·냉각 서술 없음(`trade fixed expenses (such as data centers and physical servers) for variable expenses` 뿐) | 새 URL 을 제안하지 않는다(확인한 페이지 없음) — **출처 제목에서 TCO·숨은 비용 귀속을 걷고** 실제 담긴 문장으로 바꾼다 |
| `clf-t3-2-q8` [2] | 「리전마다 사용 가능한 서비스가 다를 수 있음」 | `AWSEC2/…/using-regions-availability-zones.html` 12,113자 — 해당 서술 0건, 대조군 `don't automatically replicate` 1건 | `https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html` — `select a Region that has the AWS services and features that you need. Also, you can lower network latency when you select a Region that is close to the majority of your users.` |
| `clf-t3-2-q11` [0] | 「사용자에 가까운 리전 선택」 | 같은 페이지 — `latency` 는 Local Zones·Wavelength 문맥뿐 | 위와 같은 페이지(같은 문장이 지연도 담는다) |
| `clf-t3-2-q14` [0] | 「가용 영역은 하나 이상의 데이터센터」 | 같은 페이지 — `one or more (discrete) data centers` 0건 | `https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions-availability-zones.html` — `Each Availability Zone consists of one or more discrete data centers, each with redundant power, networking, and connectivity` |
| `clf-t3-3-q4` [0] | 「ECS·**EKS**와 함께 사용」 | `AmazonECS/…/AWS_Fargate.html` 6,435자 — `EKS`·`Kubernetes` 0건 | 추가: `https://docs.aws.amazon.com/eks/latest/userguide/fargate.html` |
| `clf-t4-1-q2` [0] | 출처 제목의 「Compute SP 최대 **66%**」 | `savingsplans/…/what-is-savings-plans.html` 2,519자 — `66` 0건(`You can save up to 72%` 뿐) | `https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html` — `Compute Savings Plans provide the most flexibility and prices that are up to 66% off` · `EC2 Instance Savings Plans provide savings up to 72% off` |
| `clf-t4-1-q15` [0] | 「Convertible RI … 교환」 | `AWSEC2/…/concepts.html` 10,000자 — `Convertible` 0건, 대조군 `Reserved Instances` 1건 | `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/reserved-instances-types.html` — `You can exchange Convertible Reserved Instances.` |

- **공개 여부**: 8문항 전부 라이브. 사실 서술 자체는 옳다(출처 교체만 필요 — 정답·해설 불변).

#### C-Y6. 출처 제목이 단종 예정 플랜 이름·잘못된 귀속을 싣는다

- **공개 여부**: 라이브. **정답 인덱스(실측)**: `clf-t4-3-q7`=0 · `clf-t4-3-q10`=2 · `clf-t4-3-q1`=0 · `clf-t4-3-q13`=0.
- **결함**: `q7` 출처 제목 「Business/Enterprise는 전체 점검, **Basic/Developer**는 핵심 점검」 · `q10` 출처 제목 「…**Business/Enterprise On-Ramp/Enterprise** 플랜 필요」 — 인용 페이지(`awssupport/latest/user/trusted-advisor.html` · `getting-started.html`)는 현행 이름 `Business Support+, AWS Enterprise Support, or AWS Unified Operations` 로 적는다(두 문항 해설 본문은 이미 현행 이름을 병기한다 — 제목만 낡았다). `q1` 출처 제목은 Basic 의 「Trusted Advisor 핵심 점검」을 `aws-support-plans.html` 에 귀속하는데, 그 페이지의 Basic 목록은 `One-on-one responses to account and billing questions · Support forums · Service health checks · Documentation, technical papers, and best practice guides` 넷이고 Trusted Advisor 가 없다. `q13` 출처 제목 「(Basic 무료 ~ Enterprise TAM)」은 C-R1 과 같은 사다리다.
- **공식 근거**: `https://aws.amazon.com/premiumsupport/plans/` — Basic: `AWS Trusted Advisor - Core checks and guidance…`.
- **수정안**: `q7`·`q10` 제목을 현행 세 플랜 이름으로. `q1` 에 `premiumsupport/plans/` 를 둘째 출처로 추가하고 제목을 나눈다. `q13` 제목은 C-R1 수정과 함께.

#### C-Y7. 「시험은 전통 분류로 출제된다」·「신규 가입 종료 공지」 — 공식 근거가 없거나 공식 문구와 다르다

- **공개 여부**: 라이브. **정답 인덱스(실측)**: `clf-t4-3-q2`=0.
- **결함**
  - `clf-t4-3-q2` 해설: 「**시험은 전통 분류(Basic·Developer·Business·Enterprise) 기준으로 출제되며**」 — 공식 가이드 작업 4.3 은 신규 플랜 이름을 든다(C-R2). 시험이 무엇으로 출제되는지 적는 공식 문서는 없다(prescreen `authoring-memo` 1건이 이 문항이다).
  - `t4-3.md:119` 「**시험 대비로는 전통 분류인 Business**를 최소 24x7 프로덕션 기술 지원 플랜으로 기억합니다」 · `t4-3.md:77` 「시중 기출·교재는 아직 전통 4단계로 출제하므로」 · `clf-t4-3-q11` 해설 「시험 대비로는 전통 분류인 Business Support를…」.
  - `t4-3.md:140` 「Developer·Business·Enterprise On-Ramp의 **신규 가입 종료 공지**」 — 공식 문구는 신규 가입 종료가 아니라 **단종**이다: `Developer Support will be discontinued January 1, 2027. Customers with Developer Support can continue using their existing plan…`. 「신규 가입이 막혔다」는 서술은 `aws-support-plans.html`·`support-plans-eos.html`(2,901자, `new customers|no longer|sign up` 0건) 어디에도 없다.
- **확신 수준**: 🟡. 2026-11-06 컨트롤러는 이 계열을 「출제 관행 서술」로 유지 판정했다(seg030 보존 가드). **「전통 Business·Developer 는 2027-01-01 단종」은 참이므로 지키고**, 「시험이 전통 분류로 출제된다」는 **근거를 제시할 수 없는 단정**만 걷는 것이 독립 판정이다.
- **수정안**: `q2` 해설에서 「시험은 … 기준으로 출제되며,」를 삭제하고 「현행 공식 명칭으로는 Business Support+ 에 해당합니다」부터 잇는다. `t4-3.md:119` · `q11` 의 「시험 대비로는 전통 분류인 Business」 → 「**현행 Business Support+(전통 명칭 Business)**」. `t4-3.md:140` 「신규 가입 종료 공지」 → 「**2027-01-01 단종 공지**」.
- **발화(`clf-t4-3`)**: seg014 · seg026(「시험을 준비할 때는 전통적인 분류 기준으로」) · **seg031**(「신규 가입을 종료한다는 공지」 + 「기존 플랜 분류 그대로 공부하시면 됩니다」). ⚠️ seg030 의 「전통적인 비즈니스와 디벨로퍼 플랜은 2027년 1월 1일에 단종될 예정」은 참이다 — 그 문장은 지킨다(같은 세그먼트의 「가장 빠른 응답」만 C-R1 대상).
- **전수 grep**: 「전통 분류|전통 4단계|시험 대비로는 전통」 — clf md 2줄(`t4-3.md:77·119`) · 문항 6곳(`q2`·`q6`·`q7`·`q10`×2·`q11` 해설) · 발화 3세그먼트.

#### C-Y8. 「공식 원문」 인용문이 인용 페이지에 없다

- **결함**: `t1-2.md:81` 「공식 원문: **"the six pillars of operational excellence, security, reliability, performance efficiency, cost optimization, and sustainability."**」. 이 편의 출처 둘에 그 문장이 없다 — `wellarchitected/latest/framework/framework.html`(7,963자, `the six pillars` 0건; 대조군 `not an audit mechanism` 1건) · `…/framework/definitions.html`(7,740자)은 `The AWS Well-Architected Framework is based on the following six pillars:` 뒤에 표로 여섯 이름을 싣는다. 2026-11-16 Well-Architected 문서 재구성으로 옛 문장이 사라진 것으로 보이나 단정하지 않는다(문서 검색으로도 그 문장을 찾지 못했다).
- **수정안**: 인용문을 `definitions.html` 의 실재 문장으로 교체 — 「공식 원문: "The AWS Well-Architected Framework is based on the following six pillars:" (표: Operational excellence · Security · Reliability · Performance efficiency · Cost optimization · Sustainability)」.
- **발화**: `clf-t1-2` **seg016** 이 그 영문 문장을 낭독한다.

#### C-Y9. 공식 「범위 외」 서비스가 학습 목표·시험 포인트에 남아 있다(문항은 2026-11-06 에 교체·메모됨)

- **결함**: 문항 쪽은 정리됐는데 학습문서가 그대로다.
  - **Amazon Personalize**(범위 외 「기계 학습」): `t3-7.md:52`(학습 목표) · `:154`(절 제목) · `:163`·`:170`(표) · `:176` · `:185`(시험 포인트) · `:214`·`:215`(흔한 함정) — 12건. 발화 `clf-t3-7` seg027(heading)·seg030(table).
  - **AWS Wavelength**(범위 외 「컴퓨팅」): `t3-2.md:40`(학습 목표) · `:138`(절 제목) · `:145`·`:148`·`:150`·`:164`·`:176`·`:214` — 8건. 문항 `clf-t3-2-q6`[0] 의 `skill` 「근접·확장 인프라 (Local Zones vs **Wavelength** vs Outposts)」. 발화 `clf-t3-2` seg031(heading)·seg037.
  - **AWS CodeDeploy**(범위 외 「개발자 도구」): `t3-1.md` 7건(표·시험 포인트). 문항 `clf-t3-1-q19` 에는 범위 메모가 있다. 발화 `clf-t3-1` seg035·seg036(table)·seg037·seg039·seg047·seg048.
- **공식 근거**: `…/cloud-practitioner-02/clf-02-out-of-scope-services.html` (200 r=0) — 목록에 `AWS Wavelength` · `Amazon Personalize` · `AWS CodeDeploy` 가 이름으로 있다.
- **수정안**: 세 편에 `t3-8.md:162` 와 같은 형식의 **범위 메모 한 줄**을 달고(사실은 옳으므로 지우지 않는다), 학습 목표 체크리스트에서는 그 이름을 빼거나 「(범위 외 — 구조만)」을 붙인다. 재합성 여부는 2026-11-06 판정(재합성 범위는 「거짓인 곳」)대로 **사람 판단** — 세 편의 발화는 사실로는 거짓이 아니다.

#### C-Y10. `t3-8.md` 내부 모순 — CloudShell

- **결함**: `:162` 「보기에 나오면 **범위 외**로 읽는 이름: **CloudShell** · CodeDeploy · …」 ↔ `:192`(시험 직전 정리) 「개발 도구 X-Ray(추적)·**CloudShell** 등은 **범주만 매칭**」. 공식 범위 외 목록에 `AWS CloudShell` 이 있다.
- **수정안**: `:192` 에서 CloudShell 을 뺀다. 발화 `clf-t3-8` seg042 가 같은 문장을 읽지만 그 편은 `needs_human_review`(비노출)이므로 다음 재합성 때 함께 반영하면 된다.

#### C-Y11. `clf-t4-2-q10`·`q12`(2026-11-06 교체분)가 학습문서에 없는 사실을 묻는다

- **공개 여부**: 라이브. **정답 인덱스(실측)**: `q10`=1 · `q12`=0.
- **결함**: 두 문항이 묻는 「AWS 생성 태그 / 사용자 정의 태그 두 유형 · 각각 활성화 · `aws:createdBy` · 활성화 이후 생성 리소스에만 적용」이 `t4-2.md` 본문에 없다(`t4-2.md` 의 태그 서술은 「비용 할당 태그로 분류·집계」 수준). 사실은 인용 페이지에 있다(✅). `q10` 은 `section` 이 없고 `q12` 는 `section: cost-tools`(내용은 비용 추적 쪽)다.
- **수정안**: `t4-2.md` 의 비용 추적 절에 두 유형·활성화·`aws:createdBy` 세 줄을 더하고(출처 `…/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html` · `aws-tags.html` — 둘 다 이미 문항 출처), `q10`·`q12` 의 `section` 을 그 절 앵커로 맞춘다.

#### C-Y12. EC2 구매 옵션 「6종」 — 공식 4.1 지식은 일곱이다(전용 인스턴스 누락)

- **결함**: `t4-1.md:37` 「**EC2 구매 옵션 6종**(On-Demand·Savings Plans·Reserved·Spot·Dedicated Hosts·Capacity Reservations)」. 공식 작업 4.1 지식: 「컴퓨팅 구매 옵션(예: 온디맨드 인스턴스, 예약 인스턴스, 스팟 인스턴스, AWS 절감형 플랜, 전용 호스트, **전용 인스턴스**, 용량 예약)」. `전용 인스턴스|Dedicated Instance` — clf md·문항·발화 **0건**.
- **수정안**: 「6종」 개수 단정을 걷고 **전용 인스턴스**(하드웨어를 다른 계정과 공유하지 않는 인스턴스 — 호스트 단위 가시성·서버 바운드 라이선스는 전용 호스트)를 표에 한 행 더한다. 새 사실이므로 저작 시 공식 EC2 문서로 문구를 확인한다.
- **발화**: `clf-t4-1` seg012(table) 「이씨투 요금 옵션 여섯 가지입니다」.

#### C-Y13. 공식 가이드 문구를 「」로 인용하면서 문구가 다르다

- **결함**: `t1-3.md:96` 「현재 기술은 「**전략적 마이그레이션 사례 파악**(예: 데이터베이스 복제)」뿐」. 공식(레포 JSON 과 일치): 「**적절한 마이그레이션 전략 파악**(예: 데이터베이스 복제)」.
- **수정안**: 인용 문구를 공식 그대로.

### DVA

#### D-Y1. Bedrock Agents(사용자 확인·제어 반환)를 상태 없이 가르친다 — 지금은 「Agents Classic」이고 신규 고객에게 닫혔다

- **결함**: `dva-t2-3.md` §6(`:168`~`:172`) · 용어(`:93`·`:94`) · 시험 포인트(`:210`) · 자가 점검(`:270`·`:272`)이 작업 그룹의 **사용자 확인** · **제어 반환**(`actionGroupExecutor`·`InvokeAgent`)을 현행 수단으로 가르친다. dva md 전체에 `Classic` 0건.
- **공식 근거**: `https://docs.aws.amazon.com/bedrock/latest/userguide/agents-classic-maintenance-mode.html` (200 r=0, 17,134자): `Amazon Bedrock Agents (launched November 2023) is now Amazon Bedrock Agents Classic and will no longer be open to new customers starting on July 30, 2026. For capabilities similar to Amazon Bedrock Agents Classic, explore Amazon Bedrock AgentCore.` / `Only the Amazon Bedrock Agents Classic service is no longer open to new customers as of July 30, 2026. Your existing Amazon Bedrock models, Knowledge Bases, and Guardrails are not affected.` / AgentCore harness: `Inline function tools for return-of-control and human-in-the-loop patterns`. `https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html` (200 r=0): `You can no longer sign up for Amazon Bedrock Agents (now Amazon Bedrock Agents Classic). If you already use Agents Classic, you can continue to use it.` ⚠️ 이 편이 인용하는 `agents-userconfirmation.html`·`agents-returncontrol.html` 본문에는 그 고지가 없다 — 상태는 전용 페이지에서만 읽힌다.
- **수정안**: §6 머리에 상태 한 줄(「이 두 기능은 **Amazon Bedrock Agents Classic**(2026-07-30 부터 신규 고객 비개방)의 기능이고, 공식 이전 경로는 범위 내 서비스인 **Amazon Bedrock AgentCore** — return-of-control·human-in-the-loop 는 인라인 함수 도구로 제공」)을 달고, 출처에 위 두 URL 을 더한다. 기술 2.3.4 를 AgentCore 축으로 다시 쓸지는 12월 문항 저작 전 **사람 판단**. 레포의 AIP 트랙이 같은 서비스에 이미 상태를 적는다(§5).

#### D-Y2. X-Ray SDK·데몬의 유지 관리 모드가 빠져 있다

- **결함**: `dva-t4-2.md:230` 「…애플리케이션을 **ADOT 또는 X-Ray SDK**로 계측」 · `dva-t4-1.md:173` 같은 문장 · `dva-t4-2.md:84·225`(`AWSXRayDaemonWriteAccess`). 유지 관리 표기 0건.
- **공식 근거**: 이 문서가 인용하는 `https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-java-segment.html` (200 r=0): `X-Ray SDK/Daemon Maintenance Notice – On February 25th, 2026, the AWS X-Ray SDKs/Daemon will enter maintenance mode, where AWS will limit X-Ray SDK and Daemon releases to address security issues only. … We recommend to migrate to OpenTelemetry.`
- **수정안**: 두 줄에 「(**X-Ray SDK·데몬은 2026-02-25 부터 유지 관리 모드 — 공식 권장은 OpenTelemetry(ADOT)**)」를 병기. X-Ray 서비스 자체(범위 내)는 정상이므로 트리거를 「X-Ray SDK·데몬」으로 좁힌다.

#### D-Y3. Kiro 구성 요소 표와 「신규 가입 차단(2026-05-15)」 — 인용 페이지에 없고 근거가 블로그뿐이다

- **결함**: `dva-t1-1.md:278` 「…IDE 플러그인 지원 종료(2027-04-30)와 **신규 가입 차단(2026-05-15)**을 알리며」 · `:280`~`:287` Kiro 구성 요소 표(Specs·Hooks·Steering files·Custom subagents) · `dva-t3-2.md:222·223`(Kiro Hooks·Specs) · `dva-t3-3.md:247`(Kiro Hooks). `dva-t1-1.md:280` 스스로 「AWS 블로그·지식 센터 수준의 서술」이라 적지만 출처 목록에 그 URL 이 없다.
- **측정**: 인용 페이지 `amazonq/latest/qdeveloper-ug/q-developer-ide-end-of-support.html`(1,429자)에는 `On April 30, 2027, AWS will discontinue support…` 와 Kiro 안내뿐이다 — `May 15, 2026` 0건. DVA 가 인용하는 238페이지 전체에서 `Kiro` + `spec|hook|steering|subagent` 0페이지(대조군: 위 인용 페이지 한 편에서 `Kiro` 는 6건 잡힌다). 2026-05-15 와 구성 요소 서술은 `aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/` 에 있으나 **블로그는 이 검증의 근거가 아니다.**
- **수정안**: 새 근거를 제안하지 않는다(공식 docs 에서 확인되지 않았다 — §6). 2단계 선택지: ① 2026-05-15 를 걷고 「2027-04-30 지원 종료」만 남긴다 ② Kiro 표는 「Kiro 공식 문서(AWS docs 밖)·AWS 블로그 근거」라는 출처 줄을 명시하고, **문항 근거로 쓰지 않는다**는 저작 결정을 `98-authoring-decisions.md` 에 남긴다.

#### D-Y4. AWS Copilot CLI 지원 종료(2026-06-12) — 사실은 옳고 출처가 없다

- **결함**: `dva-t3-2.md:187` 「CLI는 **2026-06-12 지원이 끝났습니다**」. 이 편이 인용하는 페이지 어디에도 그 날짜가 없다(238페이지 `June 12, 2026` 0건).
- **공식 근거(제안)**: `https://docs.aws.amazon.com/AmazonECS/latest/developerguide/copilot-install.html` (200 r=0): `AWS Copilot CLI will reach end-of-support on June 12, 2026. … Existing deployments will continue to function, but without ongoing maintenance`.
- **수정안**: 위 URL 을 `dva-t3-2.md` 프런트매터 `sources:` 와 「출처」 절에 추가.

#### D-Y5. mTLS 를 REST 전용처럼 적었다

- **결함**: `dva-t2-1.md:167` 표 행 「**mTLS** | REST(Regional 커스텀 도메인) | …」. HTTP API 도 상호 TLS 를 지원한다.
- **공식 근거**: `https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-mutual-tls.html` (200 r=0) — 제목 `How to turn on mutual TLS authentication for your HTTP APIs in API Gateway`. REST 쪽 `…/rest-api-mutual-tls.html`: `To configure mutual TLS for a REST API, you must use a Regional custom domain name`.
- **수정안**: API 유형 칸을 「REST(Regional 커스텀 도메인)·**HTTP**」로.

#### D-Y6. 가이드 파일이 `DVA-C02.json` 이다 — 콘텐츠는 DVA-C03 (적기만 하고 고치지 않는다)

| 항목 | `exam_guides/DVA-C02.json` | 공식 DVA-C03 (오늘) | md 12편 |
|---|---|---|---|
| 코드 | `DVA-C02` (slug `developer-associate-02`) | DVA-C03 | `certCode: DVA-C03` |
| 도메인 비중 | 32 / 26 / 24 / 18 | **30 / 26 / 22 / 22** | 30 / 26 / 22 / 22 |
| 도메인 3 이름 | 「배포」 | 「**테스트 및 배포**」 | 「테스트 및 배포」 |
| 작업 수 | 3·3·4·3 = 13 | **3·3·3·3 = 12** | 12편 |
| 기술 수 | (C02 체계) | 72 (10·4·4 / 7·7·5 / 5·5·9 / 5·5·6) | 72/72 언급 |
| 합격선·문항 | 720 · 50+15 | 720 · 50+15 | — |

- `DVA-C03.json` 은 없다. 공식 가이드: 「2026년 12월 1일부터 업데이트된 버전의 시험(DVA-C03)에 등록할 수 있습니다. 2026년 11월 30일까지 최신 버전의 시험(DVA-C02)에 응시할 수 있습니다.」 등재(12월 전환 PR) 때 C03 JSON 을 새로 만들어야 하고, readiness 정책·동기화 테스트가 그 파일을 읽는다. 시험 시간은 C03 개요 페이지에 적혀 있지 않다(C02 JSON 은 130분) — 인증 페이지에서 따로 확인이 필요하다.

---

## 3. 🟢 (같은 형식, 묶어서)

### CLF

1. **길이 단서**: prescreen `length-cue` **88문항**(정답 ÷ 최장 오답 > 1.3) + 반대 방향(정답이 최단 오답보다 짧음) **35문항**(자체 스캔). 사실은 옳다. SCS·AIP 에서 쓴 처방(오답을 같은 정밀도로 올린다 — 정답만 깎지 않는다)이 그대로 적용된다.
2. **메타·저작 메모 문구**: `meta-phrasing` 6 — 「공식」 `clf-t3-2-q10` · `clf-t3-4-q2` · `clf-t4-2-q10` · `clf-t4-2-q12` · `clf-t4-3-q15` / 「시험 가이드」 `clf-t4-3-q13`(C-R2). `authoring-memo` 1 — `clf-t4-3-q2`(C-Y7). 학습문서 `t4-1.md:138` 「공부 시간」 메모는 범위 메모로 의도된 것이라 대상이 아니다.
3. **중복**(45,150쌍, 원형 + 조사 벗김 자카드): 정답 문자열 동일 — Task 내 10쌍 · 교차 Task 12쌍. 지문+정답 자카드 상위 교차 쌍: `clf-t2-2-q2`↔`clf-t2-4-q8`(Inspector, 0.78) · `clf-t2-3-q7`↔`clf-t2-4-q10`(Secrets Manager, 0.69) · `clf-t3-3-q6`↔`clf-t3-5-q10`(ELB, 0.61) · `clf-t3-1-q11`↔`clf-t3-5-q4`(Direct Connect, 0.59) · `clf-t2-2-q3`↔`clf-t2-4-q9`(Macie, 0.56) · `clf-t2-4-q1`↔`clf-t3-5-q7`(보안 그룹, 0.55) · `clf-t3-1-q6`↔`clf-t3-5-q5`(Site-to-Site VPN, 0.52) · `clf-t2-2-q1`↔`clf-t2-4-q7`(GuardDuty, 0.46) · `clf-t1-3-q7`↔`clf-t3-4-q5`(SCT, 0.45). Task 내 상위: `clf-t3-6-q2`↔`q12`(EBS, 0.58) · `clf-t2-1-q4`↔`q10`(0.56) · `clf-t1-2-q3`↔`q14` · `clf-t2-4-q3`↔`q11` · `clf-t4-3-q7`↔`q10`(정답 둘 다 「Business Support 이상」). 교차 쌍은 가이드가 같은 서비스를 두 Task 에 싣기 때문(보안 서비스가 2.2·2.4 에, 연결 옵션이 3.1·3.5 에)이라 교체는 사람 판단이다.
4. **학습문서 내부 참조 어긋남**: 2026-06-21 보강 절이 번호 없이 끼어 「(원리: §N)」이 다른 절을 가리킨다 — `t2-2.md:263·266·269`(§6) · `t2-3.md:273·276·279`(§9, 없음) · `t3-3.md:235·238`(§3) · `t3-5.md:205~209`(§3) · `t3-7.md:207~215`(§5, 없음) · `t3-8.md:211~215`(§3). 낡은 문항 수 안내: `t2-1.md:193` 「정식 검증 문항 5개」(실제 15) · `t2-3.md:285` 「7개」(실제 18).
5. **메타데이터·표기**: 문항 ID 결번(`t3-1` q16 · `t3-7` q16·q18 — 2026-11-06 삭제분, 구조 가드는 통과) · `section` 없음(`clf-t4-2-q10` · `clf-t4-3-q10` · `clf-t1-1-q13` 등) · 문항 지문·보기의 구명칭 「AWS Snowball」(공식 현행 `AWS Snowball Edge`) · `clf-t4-3-q9` 오답 보기의 「AWS Personal Health Dashboard」(현행 AWS Health Dashboard) · `clf-t3-8-q11`[0] `skill` 「고객 참여」(공식 범주 「비즈니스 애플리케이션」 — 지난 보고 N-1 잔존) · `clf-t4-1-q5`[0] 출처 제목 「비교 섹션」(그 페이지엔 링크뿐 — 실제 비교는 `savingsplans/latest/userguide/sp-ris.html`).
6. **평문 렌더에 백틱**: `clf-t4-2-q12` 해설에 `` `aws:createdBy` `` · `` `resourceTags/user:<키>` ``, 오답 근거 W3 에 `` `createdBy` `` — 문항은 평문 `Text` 로 그려지므로 백틱이 글자로 보인다(CLF 301문항 중 이 1문항뿐).
7. **`lastVerified`**: 본문이 2026-11-06~07 에 여러 번 고쳐졌는데 프런트매터 날짜가 그보다 이른 편이 있다(`t2-1` · `t2-3` 등 2026-06 값). CLF 는 고정 맵 가드가 있으므로 올릴 때 그 맵도 함께 본다.

### DVA

1. `dva-t1-1.md:263` 「기본 최대 메시지는 256 KiB(**속성으로** 최대 1 MiB)」 — 사실은 옳다(`sns/latest/dg/large-message-payloads.html`: `supports message payloads up to 1 MiB … when you configure the MaximumMessageSize topic attribute. By default, topics accept messages up to 256 KiB`). 「속성」이 메시지 속성으로 읽힐 수 있으니 「**토픽 속성 `MaximumMessageSize` 로**」로 풀어 쓴다.
2. `dva-t4-2.md:129` 「AWS Compute 블로그는 … (블로그 근거)」 — 스스로 블로그 근거임을 밝힌 문장이다. 문항 근거로 쓰지 않는다는 표시를 저작 결정에 남기면 충분하다.
3. `dva-t2-2.md:68·106` 「비암호화 DB는 스냅샷 복사(암호화) → 복원으로 우회」 — 유일 경로로 단정하지는 않았으나, 레포의 SAA·SOA 는 Blue/Green 배포의 `TargetKmsKeyId` 경로를 병기한다(§5).
4. 범위 내 서비스 중 md 언급 0건: **Amazon Athena**(범위 내 「분석」). 공식 기술 72개 어디에도 Athena 가 이름으로 나오지 않으므로 누락이라 단정하지 않는다 — 12월 문항 저작 때 판단.
5. 통독 범위 메모: 12편의 「시험 직전 요약」과 「핵심 개념」 전부를 읽었고, 「시험 포인트·흔한 함정·자가 점검」은 본문 수치의 재진술이라 키워드 대조(역할 체이닝·Kiro·Agents·X-Ray SDK·mTLS)로만 봤다.

---

## 4. 커버리지·범위

### CLF

- **문항 분포**: 19 Task · 301문항. Task 당 15~19(`t2-2`·`t2-3` 18 · `t3-1` 19 · `t3-5`·`t3-7` 17 · `t3-3`·`t3-8` 16 · 나머지 15). `difficulty`: foundational 229 · applied 72(Task 당 applied 2~6 — Foundational 자격증으로서 쏠림 없음).
- **공식 「범위 내」 111개 서비스 중 학습문서·문항 0건: 16개** — Amazon EMR · Amazon WorkSpaces Secure Browser · AWS Control Tower · AWS License Manager · AWS Service Catalog · Service Quotas · AWS Application Discovery Service · AWS Application Migration Service · 마이그레이션 평가기 · AWS Migration Hub · AWS Client VPN · Amazon Detective · AWS Firewall Manager · AWS Resource Access Manager · AWS Elastic Disaster Recovery · Amazon Q. 학습문서에는 있으나 가르치는 문항이 0: AWS X-Ray(md 5) · AWS Amplify(md 3). ⚠️ 이 가운데 넷은 닫혔다 — Application Discovery Service(`no longer open to new customers`) · Migration Hub(`no longer open to new customers as of November 7, 2025`) · WorkSpaces Secure Browser(유지 관리 공지 2026-09-29) · Amazon Q Business(`no longer open to new customers`). 채울 때는 상태를 함께 적어야 한다.
- **공식 가이드 기술·지식 중 0건**: 4.3 「AWS에서 제공하는 기술 지원 옵션 파악(예: AWS Professional Services, AWS Solutions Architect)」 · 4.3 「…AWS Health API의 역할」(Health Dashboard 는 있음) · 4.3 「AWS 리소스 부정 사용을 신고하는 AWS Trust & Safety 팀의 역할」(`t4-3` md·문항 0) · 4.1 「AWS Organizations의 예약 인스턴스 동작 설명」 · 4.1 지식 「전용 인스턴스」(C-Y12) · 2.4 「AWS Firewall Manager」·「AWS Security Center」 · 4.3 「AWS Unified Operations」(md 1줄·문항 해설 2곳뿐 — C-R1).
- **공식 「범위 외」 56개 중 CLF 에 등장**: Wavelength · Personalize · CodeDeploy(C-Y9) · CloudShell(C-Y10) · AWS IQ · AMS · Activate(`t3-8.md:162` 범위 메모 — 정당) · FSx for Lustre(md 1, 열거 문맥).
- **범위 밖 정답 문항**: `clf-t3-1-q19`(CodeDeploy 포함) 1건 — 2026-11-06 에 범위 메모를 달고 유지 판정됨. 그 뒤 새로 생긴 것 없음.

### DVA

- **공식 기술 72개 전부 언급**(§0). 작업당 문서 1편, 12/12.
- **C02 → C03 이동 서술**: 12편의 「C02에서 바뀐 것」 절이 공식 가이드의 「DVA-C02 및 DVA-C03 비교」와 어긋나는 곳은 통독에서 찾지 못했다(비교 페이지 본문을 항목 단위로 대조하지는 않았다 — 지난 보고 P3-9 가 남긴 「본문 읽기 전」 상태가 그대로다).
- **가이드 파일 어긋남**: D-Y6.
- **닫힌 서비스**: D-Y1(Agents Classic) · D-Y2(X-Ray SDK·데몬) 외에 Lifecycle 세 목록 × dva md 전수 sweep 에서 미표기 0건. Q Developer IDE 플러그인(2027-04-30) · Copilot CLI(2026-06-12) · CodeStar Connections 개명은 이미 적혀 있다.

---

## 5. 교차 자격증 (읽기만 했고 고치지 않았다 — 다른 자격증의 해당 서술은 세지 않았다)

| 주제 | CLF·DVA 쪽 | 레포의 다른 자격증 처리 | 비고 |
|---|---|---|---|
| 역할 체이닝 1시간 상한의 콘솔 적용 | `dva-t2-1.md:267` 「콘솔 역할 전환에는 해당하지 않습니다」(D-R1) | SAA: 「콘솔에도 적용된다」로 판정(CLAUDE.md B11) | DVA 만 반대다 |
| Bedrock Agents 상태 | `dva-t2-3.md` 표기 없음(D-Y1) | AIP: 「Agents Classic 은 2026-07-30부터 신규 고객 비개방」 표기 + 규율 가드 | 같은 레포에서 자격증 간 비대칭 |
| Guardrails 유해 범주 개수 | `dva-t2-3.md:78·142` 「6종」 | AIF·SCS: 공식 내부에서 5/6 이 갈려 「개수를 단정하지 않는다」 | DVA 가 인용하는 `bedrock/latest/userguide/guardrails.html`·`guardrails-components.html` 은 여섯 이름을 나열한다(`Hate, Insults, Sexual, Violence, Misconduct and Prompt Attack`) — 이름 나열은 옳고 **「6종」 숫자만** 레포 규율과 어긋난다 |
| RDS 암호화 전환 경로 | `dva-t2-2.md:68·106` 스냅샷 경유만 | SAA·SOA: Blue/Green `TargetKmsKeyId` 경로 병기 | DVA 는 「유일」이라 단정하지 않음 |
| RDS Multi-AZ | `clf-t3-4-q12`[0] 해설·`t3-4.md:98`·발화 `clf-t3-4` seg018 — 「Multi-AZ = 동기 복제 대기」 한정 없음 | SAA·SOA: 「Multi-AZ **DB 인스턴스** 배포(스탠바이 1개)」로 한정(DB 클러스터 배포는 반동기·읽기 처리) | CLF 수준에서는 🟢. 인용 페이지 `Concepts.MultiAZ.html` 이 `Multi-AZ deployments can have one standby or two standby DB instances` 로 적는다 |
| NAT 경유 트래픽 | `clf-t3-5-q15`[0] 오답 근거 W2 가 NAT 를 「인터넷 경로」로 서술 | SAA: 「NAT 경유 S3 트래픽은 AWS 네트워크를 벗어나지 않는다」로 정정 | CLF 문항의 정답에는 영향 없음 |
| Support 플랜·Snowball | C-R1 · C-Y1 | 세지 않음 | SAA·SOA 문항에 같은 서술(「Enterprise 최상위」·Snowball 정답)이 있는지는 해당 세션이 본다 |
| Lambda 비동기 페이로드 1 MB · SQS 1 MiB · SNS 1 MiB(토픽 속성) | DVA 는 현행 값 | 세지 않음 | 2025년 하반기에 올라간 값이다 — 다른 자격증이 256 KB 로 적고 있으면 낡은 것 |

---

## 6. 공식 내부 어긋남 / 「확인되지 않음」

| # | 주제 | 관찰 | 처리 제안 |
|---|---|---|---|
| 1 | Enterprise Support 15분 응답의 등급 이름 | `aws-support-plans.html`: `Up to 15 minute production-critical case response` ↔ `premiumsupport/plans/` 비교표: `Business/Mission-critical system down < 15 mins`(Production system down 은 `< 1 hour`) | 더 구체적인 비교표가 정본. 레포는 이미 「비즈니스 크리티컬(시스템 다운) 15분」으로 적는다 — 유지 |
| 2 | Snowball Edge 의 상태 | 전용 페이지 `no longer available to new customers` · 제품 페이지 `On December 31, 2026 … discontinue support` ↔ Lifecycle 완전 종료 목록 `AWS Snowball Edge | November 12, 2025` | 전용·제품 페이지가 정본. Lifecycle 날짜는 구세대 디바이스일 가능성이 있으나 **단정하지 않는다** — 날짜를 두 가지로 적지 않는다 |
| 3 | 가이드의 QuickSight 표기 | 작업 3.7 기술 예시 `Amazon QuickSight` ↔ 범위 내 목록 `Amazon Quick Sight` | 레포 JSON 은 공식 전사 그대로. 학습문서의 「현 Amazon Quick Sight」 병기 유지 |
| 4 | DVA 도메인 1 이름 | 도메인 페이지 H1 「AWS 서비스를 **통한** 개발」 ↔ 「내용 개요」 「AWS 서비스를 **사용한** 개발」 | 저작 결정 D-01 대로(이름은 H1, 비중은 내용 개요) — 유지 |
| 5 | CloudWatch investigations 조사 그룹 수 | 사용자 가이드 `one investigation group per account` ↔ API 참조 `one investigation group in each Region in your account` | `dva-t4-1.md:249` 가 이미 둘 다 적는다 — 개수를 묻지 않는다 |
| 6 | **확인되지 않음** — S3 내구성 예시 | `t3-6.md:63`(발화 `clf-t3-6` seg009) 「1,000만 개 객체를 저장해도 평균 1만 년에 1개 손실」. 오늘 S3 FAQ(261,357자) 0건(대조군 `11 9s` 있음) · `DataDurability.html`(3,681자) 0건 · 문서 검색도 FAQ 에서 못 찾음. 인접 서술은 백서 `building-data-lakes`: `10,000,000 data assets can be reliably stored for 10,000 years` | 수정안을 내지 않는다. 2단계에서 출처를 못 찾으면 「11 nines」 설명만 남기는 쪽을 사람이 판단 |
| 7 | **확인되지 않음** — Developer Support 신규 가입 가능 여부 | 공식은 「2027-01-01 단종 · 기존 고객 계속 사용」까지만 적는다(`new customers` 0건) | 「신규 가입 종료」로 적지 않는다(C-Y7) |
| 8 | **확인되지 않음(공식 docs)** — Q Developer 신규 가입 차단 2026-05-15 · Kiro 구성 요소 | AWS DevOps 블로그에만 있다(D-Y3) | 문항 근거로 쓰지 않는다 |
| 9 | **확인되지 않음** — 「Valkey 가 ElastiCache 의 권장 엔진」 | `dva-t1-3.md:175`. 인용 `AmazonElastiCache/latest/dg/SelectEngine.html` 의 `recommend` 는 `we recommend that you use the most recent version of that engine` 뿐 · 문서 검색도 못 찾음 | 「권장 엔진」 단정을 걷거나 출처를 찾을 때까지 문항 근거로 쓰지 않는다 |
| 10 | CLF `t1-2.md:81` 인용문 | C-Y8 — 옛 문장이 현행 두 페이지에 없다 | 실재 문장으로 교체 |
| 11 | 지난 보고의 판정 정정 | N-2(SDK 서술의 VPN 가이드 출처)는 **사실을 담는다** → 결함 아님. P2-J(「보통 6시간」)는 **공식 근거가 생겼다** → 해소 | 2단계가 이 둘을 다시 집행하지 않도록 |

---

## 7. 2단계에 넘기는 순서 제안

1. **CLF 라이브 🔴 — `t4-3` Support 플랜 계열을 한 PR 로**(C-R1 · C-R2 · C-Y6 · C-Y7). 문항 `clf-t4-3-q1·q2·q3·q6·q7·q10·q11·q13` + `t4-3.md:41·77·82·119·140·149`. 정답 인덱스 8건 불변을 가드로 고정하고, 전수 가드는 「최상위」·「에서만 포함」·「시험 가이드 기준」·「신규 가입 종료」·「전통 분류 … 출제」를 **`t4-3` md + 문항 + 발화 본문**에서 센다. 재합성 대상 세그먼트: seg006·009·014·015·026·030·031·033(seg012·013 과 seg030 의 단종 문장은 지킨다). 재합성하면 `clf-t4-3` 이 `needs_human_review` 로 내려가므로 `content_index.dart` 의 `audioApproved`·`audioSha8` 를 함께 맞춘다(청취 재승인·R2 발행은 사람).
2. **CLF 서비스 상태 셋**(C-Y1 Snowball · C-Y2 Simple AD · C-Y3 FSx File Gateway). Snowball 문항을 유지할지 교체할지는 **사람에게 먼저 묻는다**(2026-12-31 이후 정답 서비스가 사라진다). 상태 메모는 가르치는 층(`skill`·지문·정답 보기·해설)에만 단다.
3. **CLF 출처 교체**(C-Y4 20문항 + md 38곳 · C-Y5 8문항). 사실 서술을 바꾸지 않는 핫픽스다. 「새 출처 있음 + 옛 출처 없음」 쌍 가드. `clf-t1-4-q8` 은 URL 교체가 아니라 **출처 제목 정정**이다.
4. **CLF 학습문서 정합**(C-Y8 · C-Y9 · C-Y10 · C-Y11 · C-Y12 · C-Y13 + 🟢 4·6·7). C-Y12(전용 인스턴스)는 새 사실을 쓰므로 저작 시 공식 문서로 문구를 다시 확인한다. 범위 외 세 서비스(C-Y9)의 재합성 여부는 사람 판단.
5. **DVA — 12월 전환 PR 전에**: D-R1(역할 체이닝) → D-Y1(Agents Classic) → D-Y2(X-Ray SDK) → D-Y4(Copilot 출처) → D-Y5(mTLS) → D-Y3(Kiro·2026-05-15 처리 결정). 등재 직전에 `AWS_NEW_RETRIES_2026` opt-in 서술(N-3)과 D-Y6 의 가이드 JSON 신설을 한 번 더 확인한다.
6. **🟢 는 마지막에, 사람 판단과 함께**: 길이 단서 88(+35) · 교차 Task 중복 · 내부 § 참조 · 커버리지 공백 16개 서비스와 4.3 기술 넷. 커버리지 공백을 채우는 것은 새 문항·새 절 저작이라 이 검증의 범위 밖이다.

**이 검증이 보지 못한 것**: CLF 출처 URL 112개의 본문 대조(§0) · CLF 오디오의 발화 본문 전문 통독(이 보고서의 발화 항목은 md·문항에서 찾은 결함의 **전파 자리**를 키워드·음차로 찾은 것이다 — 발화에만 있는 결함은 찾지 않았다) · DVA 「시험 포인트·흔한 함정·자가 점검」의 문장 단위 대조 · 공식 「DVA-C02 및 DVA-C03 비교」 페이지 본문 대조.
