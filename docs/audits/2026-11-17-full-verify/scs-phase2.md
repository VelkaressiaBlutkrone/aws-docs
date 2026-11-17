# SCS-C03 2단계 보정 — 2026-11-17

> 집행한 1단계 보고: `docs/audits/2026-11-17-full-verify/scs.md` · 계약: `01-PHASE2-CONTRACT.md`
> 브랜치 `content/phase2-fable-2026-11-17` (세션 `fix2-scs`, Fable 5.2).
>
> ⛔ 커밋·브랜치 전환·push·`git stash`·`git checkout --` 없음 · `verified: true` **0건 작성** ·
> 전체 스위트 미실행. 손댄 파일은 `flutter_app/assets/content/scs/**` 31개와 **새 가드 1파일**,
> 이 보고서뿐이다(공유 파일 0개 — 필요한 것은 §5 에 요청으로 적었다).

---

## 0. 요약

| 항목 | 수 |
|---|---|
| **채택** | 🔴 **3/3** · 🟡 **32/32** · 🟢 **6묶음**(G3 · G4③ · G5 · G6 · G8 · G9) + G1 의 「정답 보기 13건」 |
| **기각**(부분 기각 포함) | **7건** — §2 |
| **범위 확장** | **보고 목록 밖 23자리**(md 20 · 문항 3) + **구조 결함 1건** — §3 |
| 손댄 파일 | md **15편** · 문항 **16파일 45문항**(공개 17 · 드래프트 28) · 가드 **1파일** |
| **정답 인덱스 변경** | **0건** (`correct`·`skill`·`section`·`difficulty`·`verified` 전부 불변 — 기계 증명 아래) |
| 새 가드 | `flutter_app/test/scs_v2_fix_test.dart` **61건** |
| 남긴 것 | 🟢 G1 지문 59 · G2 긴 해설 28 · G4 겹침 3묶음(①②④) · G7 짧은 오답 근거 55 — §6 |

- 문항 45개 중 **본문이 바뀐 것 34개**, **출처만 바뀐 것 11개**. 보기가 바뀐 문항 19개(정답 보기 19 ·
  **오답 보기 3** = `scs-t5-1-q14`(공개) · `scs-t3-3-q14` · `scs-t4-2-q6`).
- 출처: 문항에 **38건 추가**(출처가 바뀐 문항 29개) · 학습문서에 **25건 추가**(고유 URL 24개).
- 테스트 실측: `flutter test test/scs_*` 8파일 **323건 중 322 그린 · 1 레드** — 레드는
  `scs_question_propagation_test` 의 **트립와이어 1건**(설계된 장치, §5). 보정 전 기준선은
  7파일 262건 전부 그린이었다. `flutter analyze test/scs_v2_fix_test.dart` → **No issues found**.
- `prescreen`(`node tool/prescreen.mjs build scs`): 구조·정합성 플래그 **0건** 유지.
  품질 신호 **98/240(41%) → 83/240(35%)** — length-cue 0 → **0** · meta-phrasing 76 → **59** ·
  authoring-memo 1 → **1**(기존 판정 대상 `scs-t5-1-q12` 그대로) · explanation-long 29 → **28**.

### 민감도 — 새 가드가 공허하지 않다는 증명

`git stash` 대신 **SCS 콘텐츠 31파일을 잠시 `HEAD` 판으로 바꿔** 새 가드를 돌리고, 원래 바이트로
되돌린 뒤 sha256 을 대조했다(`scratchpad/scripts/sensitivity.py`, git 상태는 건드리지 않는다).

| 상태 | 결과 |
|---|---|
| 보정 전 콘텐츠(`HEAD`) + 새 가드 | **61건 중 56건 레드** |
| 그린으로 남은 5건 | 대조군 3(파일 읽힘 · 스물다섯 문항 읽힘 · 탐지기 단위 검사) + **보존 필드 불변**(보정 전후가 같아야 정상) + `t4-2-q6 ↔ q4`(재발 방지용 — 그 겹침은 보정 도중 기존 자카드 가드가 레드로 잡았다, §3-11) |
| 복구 | **31파일 sha256 전부 동일** → 보정 후 콘텐츠로 61건 전부 그린 |

### 기계로 증명한 불변식

- 문항 16파일 전부가 **`json.dumps(ensure_ascii=False, indent=2)` + CRLF + 끝 개행으로 바이트 단위
  재현**되는 것을 먼저 확인했다(대조군). 편집은 **문항 블록 단위 바이트 치환 + 「옛 블록이 정확히
  1회」 단정**이고, 쓰기 전에 ① 새 텍스트가 다시 왕복 재현되는지 ② CR 수 == LF 수 ③ 손대지 않은
  문항이 객체 단위로 동일한지 ④ 보존 필드 불변을 단정했다.
- `git diff -U0 -- flutter_app/assets/content/scs` 에 **`"verified"`·`"correct"`·`"skill"`·
  `"section"`·`"difficulty"` 줄이 0줄**이다(AI 가 그 값을 타이핑하지 않았다).
- 보정 후 전수 감사: **G-84 위반 0**(문항 출처 ⊆ 그 Task 학습문서 출처, 파일별) · 길이 단서
  **양방향 0건**(240문항) · 키 구조 불일치 **0**(보정 전 1) · md 프런트매터 ↔ 「출처」 절 URL 집합
  일치(15편, 편집기가 매 파일 단정) · md 에 마크다운 링크·단일 이탤릭 추가 0 · 문항에 `**`·백틱 0.

### 출처 측정

이 배치가 `curl -sL` 로 잰 URL 은 **고유 84개**이고(공백을 `\s+` 로 접은 본문 탐침) 그중
**인용·판정에 쓴 80개가 전부 `200 r=0`** 이다. 나머지 넷은 대조군과 버린 추측이다 — 있는 가이드의
틀린 슬러그 `waf/…/zz-bogus-control.html` → `200 r=1`(가이드 인덱스) · 추측한 슬러그
`network-access-analyzer/network-access-scopes.html` → `200 r=1`(쓰지 않았다) · 없는 가이드 접두사 →
진짜 `404 r=0` · 지워진 프레임워크 슬러그 `framework/sec_permissions_emergency_process.html` →
`404 r=0`.
새로 단 출처 URL 은 전부 **본문에서 그 문장을 확인한 것**이다(§1 의 인용문).

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 1-1. 🔴 공개 3건 (정답 인덱스 전부 유지)

#### `scs-t5-1-q14` — EMR 전송 중 암호화 인증서 경로 (정답 **3** 유지)
- **재확인**: 인용 페이지 `emr-data-encryption-options.html` — "…in **one of three ways: by allowing
  Amazon EMR to create and manage certificates for you**, by providing a zipped file of certificates
  that you upload to Amazon S3, or by referencing a custom Java class…". 전용 페이지
  `emr-encryption-enable.html` — "With Amazon EMR release version **7.11.0 or later, you have three
  options** … Amazon EMR will upload the PEM-encoded certificate of the created certificate authority
  to AWS Secrets Manager … For Amazon EMR release version **4.8.0 through 7.10.0, only a .zip file or
  custom Java class** are supported." **보고가 옳다.**
- **고친 방법**: 계약 §2(「정답이 둘」은 오답 보기를 명백히 거짓으로 교체하는 쪽이 낫다)를 따라
  **오답 보기 `[2]` 를 교체**했다 — 새 `[2]` 는 「개인 키에 암호를 걸어 zip 에 담는다」이고 공식이
  명시적으로 부정한다("Amazon EMR doesn't support passphrase-protected private keys … the cluster
  fails to start", 같은 전용 페이지). 정답 `[3]` 은 「Java 클래스, 7.11.0 이상이면 EMR 관리 인증서도
  가능」으로, 해설·`W0`·`W2` 는 릴리스 경계로 고쳤다. `W0` 의 근거 — 보안 구성의
  `CertificateProviderType` 은 `PEM`·`Custom`·`EMR` 셋이고 Secrets Manager 는 **EMR 이 CA 인증서를
  올려 두는 곳**이다(`emr-create-security-configuration.html`).
- 지문의 메타 문구(「공식이 적는 경로는」)를 걷었다. 출처에 `emr-encryption-enable.html` 추가.
- ⚠️ **공개 문항의 오답 보기 1개가 바뀌었다 — 사람이 한 번 읽어 주기를 요청한다**(§5).
  1단계 보고의 대안(지문을 릴리스 7.10 이하로 한정)도 성립한다. 보기 교체를 고른 이유는 계약의
  우선순위와, 지문 한정이 **옛 릴리스에 묶인 문항**을 남긴다는 점이다.
- md 선결: `scs-t5-1.md` 5자리(절 제목 「인증서 두 경로」 · 「방법이 둘입니다」 · 표 2행 → 3행 ·
  시험 직전 요약).

#### `scs-t6-1-q15` — Well-Architected 비상 접근 모범 사례 (정답 **3** 유지)
- **재확인**: 현행 인용 페이지의 안티패턴은 넷이다 — "You do not have well-documented and
  well-tested emergency access processes… depend on the same systems (such as a centralized identity
  provider) as your normal access mechanisms… used in non-emergency situations… do not generate
  sufficient logs…". `elevated` 0건(대조군 `cross-account` 6건). 문항의 「안티패턴 둘」은
  `2023-04-10` 판 문구다. **보고가 옳다.**
- ⭐ **보고가 「사람 판정」으로 남긴 §6-5(어느 판이 정본인가)를 측정으로 닫았다** — 현행
  프레임워크판에 이 모범 사례가 **`FND05-BP02 Establish emergency access mechanisms`** 로 있다
  (`wellarchitected/latest/framework/fnd05-bp02.html`, `200 r=0`, 11,415자). 안티패턴 넷이 같은
  내용이고 "Level of risk exposed … Medium" 도 같다. 보안 원칙 백서판은 머리에 "This whitepaper is
  for historical reference only … All updated guidance and best practices now live in the
  Well-Architected Framework whitepaper" 를 단다. 그리고 현행 프레임워크의 `sec03-bp03.html` 은
  **「SEC03-BP03 Analyze public and cross-account access」** 다.
- **고친 방법**: 출처를 **프레임워크판(현행) + 보안 원칙 백서판 + `API_AssumeRoot`** 셋으로 두고
  (백서판 URL 은 공유 가드 `source_url_retired_test` 의 `replacements` 가 이 두 파일에 요구하므로
  **지우지 않았다**), 정답 보기·해설·`W1`·`W2` 를 현행판 문장으로 고쳤다. D-16 대로 **개수는
  적지 않는다**. 해설 끝의 「`sts:AssumeRoot` 권한 보유자만」·「그 역할의 상당 부분을 대신」은
  인용 페이지에서 확인되지 않아 걷고, 측정된 것("maximum session duration of 900 seconds
  (15 minutes)" · `TaskPolicyArn`)만 남겼다.
- md 선결: `scs-t6-1.md` **9자리 + 출처 라벨** — §3-3.

#### `scs-t3-1-q5` — CloudFront 오리진 보호의 귀속 (정답 **0** 유지)
- **재확인**: 체크리스트 페이지는 "…Store the header value in AWS Secrets Manager and rotate it
  periodically. **Alternatively, use the CloudFront managed prefix list**…" 이고 `together`·
  `strongest`·`shared` 0건. **보고가 옳다.**
- ⭐ **보고가 「docs 로는 확인되지 않았다」로 둔 §6-2 의 근거를 찾았다** —
  `restrict-access-to-load-balancer.html`(보고도 `200 r=0` 으로 적은 페이지)이 구조를 직접 적는다:
  목차가 「Configure CloudFront to add a custom HTTP header / Configure an ALB to only forward
  requests that contain a specific header / **(Optional) Limit access to origin by using the
  AWS-managed prefix list**」이고 본문이 "**To further restrict access** to your Application Load
  Balancer, you can configure the security group … This prevents traffic that doesn't originate from
  CloudFront". 즉 **헤더가 기본 수단, 접두사 목록은 더 좁히는 선택 단계**다. 접두사 목록의 범위는
  `LocationsOfEdgeServers.html` — "contains the IP address ranges of **all of the CloudFront globally
  distributed origin-facing servers**".
- **고친 방법**: 정답 보기·해설·`W3` 에서 「모든 고객의 배포가 공유 / 제3자 배포도 통과 / 가장 강한
  보호라고 적는다」를 걷고 위 두 문장으로 바꿨다(「어느 배포에서 온 요청인지 가르지 못한다」는 그
  문장에서 따라오는 서술이다). 출처를 넷으로 정리(위 두 페이지 + 체크리스트는 「헤더 값 보관과
  교체」 근거 + 기존 커스텀 헤더 페이지).
- md 선결: `scs-t3-1.md` **5자리**(보고 3 + 목록 밖 2 — §3-4).

### 1-2. 🟡 공개 13건

| # | 문항(정답) | 판정 | 한 일 |
|---|---|---|---|
| Y1 | `t3-1-q3`(2) | 채택 | 전용 페이지 "You are charged additional fees when you use this managed rule group." 확인. 해설·`W0`·`W1`·`W3` 에서 「그 밖의 모든 … 추가 비용 없음」을 걷고 **정답 보기에 Anti-DDoS 를 더했다**(47 → 64자 — G3 의 반대 방향 길이 단서도 함께 닫힌다). 출처 +1 |
| Y2 | `t3-1-q1`(0) | 부분 채택 | 해설 「함께 쓰며」 → 「헤더로 막고 접두사 목록으로 더 좁히며」. 출처 제목을 현행 `h1` 으로, `restrict-access…` 추가. 체크리스트 URL 은 유지(§2-1) |
| Y3 | `t3-1-q12`(3) | 채택 | 출처 +1 — "WCUs – 2, as a base cost. For each custom aggregation key that you specify, add 30 WCUs." |
| Y4 | `t3-1-q15`(2) | 채택 | 출처 +1 — "To protect the intellectual property of the rule group providers…" |
| Y5 | `t5-1-q1`(0) | 채택 | 출처 +1 — "Other methods (for example, the AWS CLI, AWS CloudFormation, and the AWS CDK) – The default security policy is ELBSecurityPolicy-2016-08." |
| Y6 | `t1-1-q9`(0) | 채택 + 확장 | 출처 +2("You can't use an AWS Region that is disabled by default as your home Region." · "Regions launched after March 20, 2019 are disabled by default"). 해설의 미확인 절을 측정된 문장으로(§3-6) |
| Y7 | `t4-1-q7`(2) | 채택 | 출처 +1 — "AssumeRole (recommended) or GetFederationToken" · "When you use DurationSeconds in an AssumeRole* operation, you must call it as an IAM user with long-term credentials." |
| Y8 | `t4-1-q6`(1) | 채택 | 출처 +1 — "You can use the PolicyArns parameter to specify up to 10 managed session policies." 지문의 「공식 비교표에 비추어」도 걷음 |
| Y9 | `t2-1-q2`(1) | 채택(낮춤) | 보고 (a)안. 「노트북은 런북의 실행 가능한 판」을 걷고 **시험 가이드 기술 2.1.1 의 예시라는 귀속 + 노트북의 일반적 성질**로 낮췄다. 그 역할을 적는 docs 페이지는 이 세션에서도 찾지 못했다(검색 결과는 AWS 보안 블로그뿐 — 근거로 쓰지 않았다). **사람 판정 대상**(§5) |
| Y10 | `t2-1-q15`(2) | 채택 | 출처 +1 — "…If the response from SSM Run Command status is Success, it checks if isolation is needed. If isolation is set to true … attaches a security group with no egress and ingress…" |
| Y11 | `t2-1-q14`(1) | 채택 | 출처 +1(`maintenance_services.html` — "Amazon Application Recovery Controller (ARC) – Readiness Check March 31, 2026"). `W0` 에서 상태 문장을 빼고 「임계 경로용이 아니다」만 남김. 해설의 상태는 유지 |
| Y12 | `t6-1-q7`(0) | 채택 | 출처 +1(정책 관리 페이지의 요약표 — "Affects management account … SCP … No … RCP … No … Declarative policy … Yes"). 해설을 「두 표」로, 정답 보기의 「공식 표가 …」 걷음 |
| Y13 | `t6-1-q3`(2) | 채택 | 출처 +2 — "scans your managed SCPs, RCPs, and Declarative policies daily" · "implemented as preCreate and preUpdate hook handlers" |

### 1-3. 🟡 드래프트 19건

| # | 문항(정답) | 판정 | 한 일 |
|---|---|---|---|
| Y14 | `t1-3-q15`(1) | 채택 | 지문을 「ALARM 으로 바뀌지 않고 작업도 실행되지 않았다」로(전제 모순 해소) |
| Y15·Y16 | `t1-3-q3`(1) · `q4`(3) | 채택 | 「API Gateway 가 관리」 → 「스테이지를 배포할 때 만든다」("API Gateway creates log groups or log streams for an API stage at the time when it is deployed"). 출처 +1씩 |
| Y17 | `t1-2-q12`(3) | 채택 | **G-31 을 측정으로 닫았다** — 출처를 세 소개 페이지로 교체: OpenSearch("a fully open-source search and analytics engine for use cases such as log analytics…") · Managed Grafana("data visualization service … query, correlate, and visualize operational metrics, logs, and traces from multiple sources") · Security Lake("uses Lambda functions to support extract, transform, and load (ETL) jobs on raw data"). 무관한 Logs Insights 출처는 걷음 |
| Y18 | `t1-2-q13`(0) | 채택 | 정답 보기에서 무출처 절반(OpenSearch·Grafana 묶음)을 빼고 **사용자 지정 소스의 변환 책임**으로 바꿈("the custom source must convert the logs and events to the … OCSF"). `q12` 와의 겹침(G4③)도 함께 해소 — 정답 자카드 **0.0** |
| Y19 | `t2-2-q1`(0) | 채택 | 「공식 흐름」 귀속을 **메모리 → 격리**로 한정하고 스냅샷의 선후는 휘발성 순서 원칙의 적용으로 가름. 지문의 「공식 포렌식 흐름에 맞는」도 같은 취지로 |
| Y20 | `t3-2-q12`(3) | 채택 + 확장 | 출처 +2(자료형 두 페이지). **`examGuideTaskId` 누락 복구**(§3-1). 정답 77 → 80자(G3) |
| Y21 | `t3-2-q13`(0) | 채택 | 출처 +1(CLI 참조 — "On November 20, 2025, AWS will discontinue support for Amazon CodeGuru Security.") |
| Y22 | `t3-3-q14`(1) | 채택(측정으로 대체) | 「온디맨드 분석 → 주기 실행 자동화」를 걷고 **측정된 문장**으로: "performs a static analysis of a network configuration, meaning that no packets are transmitted"(`how-…-works`) · "Choose Analyze … it can take a few minutes to complete the analysis"(`getting-started`). 오답 `[0]` 의 「상시 자동 감시가 함께 제공」(참·거짓 미확인)도 걷음. 출처에서 목차 페이지 제거 |
| Y23 | `t3-3-q15`(2) | 채택 | NAA 출처를 `how-network-access-analyzer-works.html` 로 교체 |
| Y24 | `t4-2-q6`(1) | 채택 + 재설계 | 「RBAC 옆에 ABAC 를 더하라는 공식 권고」를 걷음(비교 페이지에 `alongside`·`in addition`·`combin`·`together`·`recommend` 0건, 대조군 `RBAC` 9건). 문항을 **조건 키 넷**(리소스·요청·태그 키·보안 주체)만 묻게 좁힘. 출처 +1 — §3-11 |
| Y25·Y26 | `t5-2-q6`(2) · `q14`(1) | 채택 | 귀결을 공식 문장으로 정밀화 — "If you manually lock a snapshot created by Amazon Data Lifecycle Manager, and that snapshot is still locked when its retention threshold is reached, Amazon Data Lifecycle Manager no longer manages that snapshot. You must manually delete the snapshot…" 출처 +1씩 |
| Y27 | `t5-2-q11`(2) | 채택 | 귀속을 「API 참조가」로, 출처 +1 — "File systems cannot transition into Archive storage before transitioning into IA storage." |
| Y28 | `t5-2-q9`(0) | 채택(출처 추가) | 부연은 **사실**이다 — Signer 안내서: "With AWS Signer and the Notation CLI from the Notary Project, you can sign container images … The signatures are stored in the registry alongside the images". 지우지 않고 출처 +1(§2-3) |
| Y29 | `t5-3-q7`(2) | 채택 | `W3` 의 「모든 키 저장소 유형이 FIPS 140 수준 3」을 걷음. 정답 보기·지문의 「공식」 메타도 걷음 |
| Y30 | `t6-2-q6`(1) | 채택 | 출처 +2(전역 조건 키 · 정책 관리 페이지) |
| Y31 | `t6-2-q14`(1) | 채택(출처 추가) | 부연은 **사실**이다 — `what-is-control-tower.html`: "an Account Factory (or “vending machine”), which is built as an abstraction on top of provisioned products in AWS Service Catalog". 출처 +1(§2-4) |
| Y32 | `t6-3-q9`(0) | 채택(지문 한정) | 보고 (a)안 — 지문을 「AWS Audit Manager 를 이미 쓰고 있는 조직」으로 한정(D-04 와의 충돌 해소). **사람 판정 대상**(§5) |

### 1-4. 🟢

- **G3** — 반대 방향 길이 단서 2건 해소(`t3-1-q3` 64자 · `t3-2-q12` 80자). 하한 단정을 새 가드에서
  **240문항 전수**로 걸었다.
- **G1(부분)** — **정답 보기에 「공식」이 든 13문항 전부**(정답 표식이 되는 자리)를 사실 서술로
  바꿨다: `t5-1-q14`·`t6-1-q7`·`t6-1-q15`(위) + `t1-2-q15` · `t1-3-q7` · `t2-1-q11`(공개) ·
  `t3-3-q4` · `t5-3-q7` · `t5-3-q13` · `t6-2-q8` · `t6-3-q1` · `t6-3-q11` · `t6-3-q13`.
  지문의 「공식」 59건은 남겼다(§6).
- **G4③** — `t1-2-q12 ↔ q13` (Y18 로 해소).
- **G5** — `t6-3-q13` `W1` 의 「Agent 는 프리뷰」를 걷고 요건 불일치로 반박(공식: "The two services
  complement each other"). 해설의 상태 문장은 유지. 전수: 상태 문구가 오답 근거에 놓인 문항이
  `scs-t4-1-q4`(상태 자체가 반박 근거) **하나뿐**임을 가드로 고정.
- **G6** — `scs-t3-1.md` 보호 대상 목록 줄에 App Runner 상태 한 줄.
- **G8** — `t6-3-q8` `W1` 과 `scs-t6-3.md` 의 「전제가 다섯」.
- **G9** — 출처 제목(`Security checklist for ecommerce` 0건) · `scs-t6-1.md` 의 낡은 확인 라벨.

---

## 2. 기각 — 왜 고치지 않았는가 (부분 기각 포함)

1. **Y2 「체크리스트 출처를 교체」** — 지우지 않았다. 그 페이지는 두 수단을 실제로 나열하고
   (`X-Origin-Verify` · `Secrets Manager` 2건), 기존 가드 `scs_source_fix_test` 가 `t3-1-q1` 에 그
   URL 을 요구한다. 거짓이던 것은 **귀속 문구**뿐이므로 문구를 고치고 측정된 출처를 **추가**했다.
2. **Y1 「정답 보기는 유지」** — 유지하지 않고 Anti-DDoS 를 더했다. 「추가 요금은 Bot Control·ATP·
   ACFP 에 붙는다」는 거짓은 아니지만, 같은 문항의 오답 근거가 Anti-DDoS 를 들게 되면 정답 보기만
   불완전해지고, 그 보기는 G3(정답이 최단 오답보다 짧다)에도 걸려 있었다.
3. **Y28 「부연을 지우는 것이 싸다」** — 지우지 않았다. Signer 안내서가 그 문장을 글자 그대로
   적는다(§1-3). 참인 교육 내용을 지우는 대신 출처를 달았다(`scs-t5-2.md` 에도).
4. **Y31 「부연을 지우는 것이 싸다」** — 같은 이유. `what-is-control-tower.html` 이 그대로 적는다.
   ⚠️ `account-factory.html`(3,172자)에는 `Service Catalog` 0건이라 **그 페이지만 보면 「없다」로
   오판한다** — 정본은 소개 페이지다.
5. **Y22 「『온디맨드』는 확인되지 않았다로 두고 뒤 절반을 뺀다」** — 빼기만 하지 않고 **측정된
   문장으로 대체**했다(분석은 시작할 때 실행 · 몇 분 소요 · 정적 분석). 「주기 실행 자동화」
   권고는 어느 페이지에도 없어 걷었다.
6. **§6-5 「어느 판이 정본인지는 사람 판정」** — 측정으로 닫혔다(`FND05-BP02`, §1-1).
   다만 **두 판을 함께 인용**한 선택은 사람이 뒤집을 수 있다(§5).
7. **`scs-t3-1.md` L114 「셋 다 추가 요금」 · `t5-2-q14` 정답 보기** — 보고가 전수 목록에 올린
   자리지만 **그대로 참**이다(그 셋은 추가 요금이 맞고, 잠긴 스냅샷은 누구도 지울 수 없다).
   해설·옆 줄만 정밀화하고 이 둘은 손대지 않았다.

---

## 3. 범위 확장 — 보고가 하한이던 자리 (전수 실측)

1. **구조 결함 1건(보고에 없음)** — `scs-t3-2-q12` 에 **`examGuideTaskId` 가 없다**(240 중 1,
   2026-11-11 재작성 때 빠졌다). 앱은 누락을 빈 문자열로 읽으므로(`lib/models/question.dart`)
   flip 뒤 그 문항에서만 「관련 문서 열기」(`quiz_widgets.dart`)와 오답 기술 집계의 `taskId` 가
   깨진다. 왕복 재현 대조군도 prescreen 구조 플래그도 이것을 잡지 못한다(prescreen 은 값이 있을
   때만 뱅크와 비교한다). 키를 `id` 뒤에 복구하고 **전 문항 키 구조 가드**를 걸었다.
2. **R1 의 귀속 1계열(문항 1 · md 2)** — 「Java 클래스 = 개인 키를 S3 에 두지 못하게 하는 정책이
   있을 때의 경로**라고 공식이 설명한다**」. 현행 EMR 세 페이지에서 `private key` 는 8건 전부
   PEM 파일·암호 문맥이고 그 설명은 없다. 측정된 사실(zip 은 `privateKey.pem` 을 S3 에 올려야
   한다 · Java 클래스는 `TLSArtifactsProvider` 가 아티팩트를 제공한다)에서 **따라오는 추론**으로
   고쳐 적었다.
3. **R2 — `scs-t6-1.md` 9자리**(보고 4줄). §5-4 도입 문장(「자동화된 프로세스나 파이프라인
   문제」도 2023 판 문구다) · 표 4행 · 원리 블록의 「단기 권한」 · 자가 점검 Q6 답 4줄.
   문항 쪽도 `W2`(「검증과 승인을 전제하는 공식 형태」)와 해설의 미확인 두 절이 더 있었다.
4. **R3 — `scs-t3-1.md` +2자리** — 시험 포인트(「다른 사람의 CloudFront…」)와 함정 목록(「다른
   계정의 배포도 그 IP 범위」). 가드 설계용 전수 스캔이 찾았다.
5. **Y1 — `scs-t3-1.md` 과금 층 목록 1자리**(「그 밖의 모든 AWS Managed Rules — 추가 비용 없음」).
6. **Y6 — 미확인 절 2자리**(문항 해설 · `scs-t1-1.md`): 「조직에서 그 리전을 활성화하기 전에는
   그곳에 Security Hub CSPM 을 구성할 수도 없습니다」. 측정된 문장으로 교체 — "Disabled opt-in
   Regions … you cannot use these Regions to create workloads until they are enabled".
7. **Y9 — `scs-t2-1.md` 2자리**(「가이드가 노트북을 드는 이유는 …」·「런북의 실행 가능한 판」).
8. **Y15 — `scs-t1-3.md` 표 1자리**.
9. **Y22 — `scs-t3-3.md` 4자리**(「온디맨드」 3 + 시험 직전 요약의 「스코프 선언·온디맨드」).
   ⚠️ 그 문단의 「몇 분 뒤 조사 결과가 납니다」는 **측정된 사실**이라 남겼다(`getting-started`).
10. **Y29 — `scs-t5-3.md` 1자리**(「모든 키 저장소 유형이 FIPS 140 보안 수준 3」) → 표준 키
    저장소의 서술로 한정. 같은 문장의 「AWS 운영자를 포함해 누구도」는 공식 문구대로 「AWS 직원」
    ("no one, including AWS employees")으로.
11. **Y24 — `scs-t4-2.md` 1자리 + 내가 만든 겹침 1건** — 1차 수정이 정답 보기에 「새 리소스에 정책
    수정이 필요 없다」를 넣어 **같은 Task `q4` 의 정답과 겹쳤고**, 기존 전수 가드(출처 공유 쌍의
    정답 자카드 < 0.33)가 **0.348 로 레드**를 냈다. 그 사실은 `q4` 가 소유하므로 `q6` 을 조건 키만
    묻게 다시 썼다. **「한 자리를 고치면 그 Task 의 형제 문항을 다시 읽는다」**를 가드가 대신해 줬다.
12. **G8 — `scs-t6-3.md` 1자리**(보고가 적은 자리).

→ 합계: md **20자리**(t5-1 2 · t6-1 5(보고 4줄 밖) · t3-1 3 · t1-1 1 · t2-1 2 · t1-3 1 · t3-3 4 ·
t5-3 1 · t4-2 1) · 문항 **3자리**(`t5-1-q14` 귀속 · `t6-1-q15` 미확인 두 절 · `t1-1-q9` 미확인 절)
· 구조 **1건**.

---

## 4. flip 준비 상태

「준비됨」= **1단계 보고의 🔴·🟡 가 0건**. 🟢 는 flip 을 막지 않는다고 본 1단계 기준을 그대로 썼다.
⚠️ 1단계가 밝힌 한계는 그대로다 — **학습문서 16편 본문의 줄 단위 전수 사실 대조는 하지 않았다**
(루브릭 T6 는 검수자가 따로 본다). 이 배치가 md 에서 본 것은 문항 결함의 전파 자리뿐이다.

### 공개 6 Task — 수선 완료 (이미 라이브)

| Task | 보고 🔴/🟡 | 상태 | 사람이 볼 것 |
|---|---|---|---|
| `scs-t1-1` | 0 / 1 | ✅ | — |
| `scs-t2-1` | 0 / 3 | ✅ | `q2` 낮춘 서술(Y9) |
| `scs-t3-1` | 1 / 4 | ✅ | `q5`·`q3` 정답 보기 문구 |
| `scs-t4-1` | 0 / 2 | ✅ | — |
| `scs-t5-1` | 1 / 1 | ✅ | **`q14` 오답 보기 `[2]` 교체** |
| `scs-t6-1` | 1 / 2 | ✅ | `q15` 두 판 병기 |

### 드래프트 10 Task — 보고 기준 **10 Task 전부 🟡 0건**

| Task | 보고 🟡 | 상태 | 남은 🟢(지문 「공식」 · 해설 > 400자 · 겹침) |
|---|---|---|---|
| `scs-t2-2` | 1 | ✅ 준비됨 | 4 · 1(`q10`) · — |
| `scs-t5-3` | 1 | ✅ 준비됨 | 3 · 7 · — |
| `scs-t4-2` | 1 | ✅ 준비됨 (**D4 풀 확대 후보**) | 5 · 0 · — |
| `scs-t1-3` | 3 | ✅ 준비됨 | 5 · 0 · — |
| `scs-t3-2` | 2 | ✅ 준비됨 (+ `examGuideTaskId` 복구) | 1 · 1(`q2`) · — |
| `scs-t6-2` | 2 | ✅ 준비됨 | 0 · 7 · — |
| `scs-t1-2` | 2 | ✅ 준비됨 (G-31 측정으로 닫음) | 10 · 1(`q11`) · — |
| `scs-t3-3` | 2 | ✅ 준비됨 | 3 · 0 · **G4 ①·④** |
| `scs-t5-2` | 4 | ✅ 준비됨 | 3 · 2 · — |
| `scs-t6-3` | 1 | ⚠️ **사람 판정 후** — `q9` 지문 한정(D-04)을 받아들일지 | 3 · 2 · **G4 ②** |

- flip 은 사람만 한다(`review.mjs flip`). `scs_v2_fix_test.dart` 는 이름이 `scs_` 로 시작하므로
  `flipTestFiles()` 가 flip 때 함께 돌리고, **`verified` 를 단정하지 않는다**.
- ⚠️ **flip 전에 §5 의 트립와이어 등재가 선행돼야 한다** — 그 한 건이 레드인 채로는 flip 도구가
  레드로 끝난다(`scs_question_propagation_test` 는 `cert.tests`/`scs_*` 범위다).

---

## 5. 컨트롤러 요청

- [ ] **`test/scs_question_propagation_test.dart` 의 `registered` 에 `scs_v2_fix_test.dart` 등재.**
      트립와이어가 설계대로 레드다(`Actual: ['scs_v2_fix_test.dart']`). 새 가드의 금지 문구는 전부
      **md 16편 + 문항 16파일을 함께** 훑는 `hits()` 로 세므로 `_factRules`·`_nameRules` 로 옮겨 올
      규칙이 없다(등재 사유로 적어 주면 된다).
- [ ] **`CLAUDE.md` 기준선 +61** (`scs_v2_fix_test.dart` 61건. 다른 SCS 테스트 수는 불변 — 262).
- [ ] **`test/source_url_retired_test.dart` 주석 정정**(L210~213 부근): 「비상 접근 BP 의 정본은
      `security-pillar/sec_permissions_emergency_process.html`」은 이제 부정확하다 — **현행
      프레임워크판에 `framework/fnd05-bp02.html`(FND05-BP02)이 있다**(`200 r=0`). `replacements`
      단정(두 SCS 파일에 백서판 URL 실재)은 **지금도 통과한다** — 그 URL 을 지우지 않았다.
      사람이 백서판을 걷기로 하면 그 목록을 먼저 고쳐야 한다.
- [ ] **사람 승인·판정 4건** (전부 `verified` 불변의 본문 핫픽스지만 판단이 들어갔다)
  1. `scs-t5-1-q14`(공개) — **오답 보기 `[2]` 교체**(정답 3 유지). 대안: 지문을 릴리스 7.10
     이하로 한정하고 보기를 되돌린다.
  2. `scs-t6-1-q15`(공개) · `scs-t6-1.md` — 프레임워크판(`FND05-BP02`)과 백서판(`SEC03-BP03`)을
     **함께** 인용했다.
  3. `scs-t2-1-q2`(공개) — Y9. 노트북의 역할을 일반 서술로 낮췄다(공식 페이지 미확인).
  4. `scs-t6-3-q9`(드래프트) — Y32. 지문을 기존 고객으로 한정했다(D-04).
- [ ] **교차 자격증**(고치지 않음): 1단계 §5 의 `clf/t2-2.questions.json`(`security-pillar/` URL —
      그 문항이 인용하는 문장이 현행판에 있는지)은 CLF 세션 몫이다. 이 세션이 같은 문구로 다른
      자격증을 전수 grep 한 결과 — 「가장 강한 오리진」·「RBAC 옆」·「API Gateway가 관리」·
      「모든 키 저장소 유형」·「그 밖의 모든 AWS Managed Rules」·NAA 「온디맨드」·
      `sec_permissions_emergency` **전부 0건**. `aif` 의 `SEC03-BP03` 3파일은 `MLSEC03-BP03`·
      `GENSEC03-BP03`(다른 렌즈)이라 무관하다.
- [ ] **조사 노트**(소유 밖이라 손대지 않음): `docs/content-research/SCS-C03/` 의 열린 갭 **G-31**
      (Lambda·OpenSearch·Managed Grafana 미측정)은 이 배치가 세 소개 페이지를 측정해 **층 배치에
      한해** 닫았다(수치·한도는 여전히 미측정). 그리고 「WA 비상 접근 BP = FND05-BP02」를 갭 노트에
      남길 가치가 있다.
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**

---

## 6. 남긴 것 (다음 배치)

| 묶음 | 수 | 메모 |
|---|---|---|
| **G1** 지문의 「공식」 | **59문항**(공개 22) | `t1-2` 10 · `t1-1`·`t4-1` 6 · `t1-3`·`t4-2`·`t6-1` 5 …. 대부분 「…에 관한 공식 서술로 올바른 것은」 꼴이라 기계적 정리가 가능하지만 공개 22문항의 지문이 바뀌는 배치라 따로 뺐다. 목록은 `prescreen` 이 다시 만든다 |
| **G2** 해설 > 400자 | **28문항**(공개 7) | `t5-3` 7 · `t6-2` 7 에 쏠림. 걷을 후보는 오답 근거가 이미 적는 문장 |
| **G4** 겹침 | **3묶음** | ① `t3-3-q3 ↔ q12`(Network Firewall 과 VPC 피어링) ② `t6-3-q13·q14·q15`(Tool/Agent 한 표) ④ `t3-3-q7 ↔ q9`(Verified Access 요청별 평가). 관점을 바꾸는 재작성이라 새 측정이 든다 |
| **G7** 20자 이하 오답 근거 | **55개** | `t6-3` 10 · `t5-3` 7 · `t3-3`·`t4-2` 6. 「왜 틀렸는가」를 적는 보강 |
| 1단계 §4-1 구조 항목 | — | D4 문항 풀(12.5% 대 공식 20%) · 빈 주제 3종(Trusted Advisor · User Notifications · Verified Permissions) |

---

## 7. 1차 실행(Opus, 브랜치 `content/phase2-fix-2026-11-17`)과 갈린 판정

이 세션은 1차 산출물을 **보지 않고** 작업한 뒤, 끝나고 나서 1차 보고서(`55d8443` 의
`scs-phase2.md`)를 대조했다. 합칠 때 볼 차이만 적는다.

| 자리 | 1차 | 이 세션 | 근거 |
|---|---|---|---|
| `t5-1-q14` | 지문을 「릴리스 7.9.0 클러스터」로 한정(보기 유지) | 오답 보기 `[2]` 교체 | 둘 다 정답 유일성을 회복한다. 계약 §2 는 보기 교체를 권하고, 1단계 보고는 그것을 사람 승인으로 적었다 — **사람 판정**(§5) |
| Account Factory ↔ Service Catalog | 「공식에 없다」로 보고 md 를 좁힘(`account-factory.html` 에 0건) | **참** — 출처 추가 | `what-is-control-tower.html` 이 "built as an abstraction on top of provisioned products in AWS Service Catalog" 로 적는다. 1차의 「없다」는 한 페이지만 본 거짓 음성이다 |
| NAA 「몇 분 뒤 조사 결과」 | 미확인 수치로 봄 | **측정됨** — 유지 | `getting-started.html` "it can take a few minutes to complete the analysis" |
| WA 비상 접근 BP 의 현행판 | 백서판만 인용 | **`FND05-BP02` 추가** | `framework/fnd05-bp02.html` `200 r=0` |
| `t3-2-q12` `examGuideTaskId` 누락 | (언급 없음) | 복구 + 전수 가드 | §3-1 |
| G1 정답 보기 「공식」 | 3건 감소 | **13건 전부** | 전수 가드로 0건 고정 |

---

## 8. 이 배치에서 배운 것

1. ⚠️⚠️ **「어느 판이 정본인가」는 그 페이지 자신이 답을 적고 있었다.** 백서판의 배너가 "All updated
   guidance … now live in the Well-Architected Framework whitepaper" 라고 가리키는데, 프레임워크판은
   **BP 접두사와 번호가 통째로 바뀌어**(`SEC03-BP03` → `FND05-BP02`) 옛 슬러그도 옛 번호도 닿지
   않는다. **제목으로 검색해야** 찾는다(AWS 문서 검색으로 찾고 `curl -sL` 로 실측했다).
2. ⚠️⚠️ **「없다」는 페이지 하나로 판정하지 않는다.** `account-factory.html` 에 `Service Catalog` 가
   0건이어도 그 사실은 서비스 소개 페이지에 글자 그대로 있었다. 같은 식으로 「두 수단을 함께」의
   근거는 체크리스트가 아니라 **전용 절차 페이지**에 있었다.
3. ⚠️ **기존 전수 가드가 내 수정의 부작용을 잡았다**(§3-11). 정답 보기에 새 사실을 더하면 같은
   Task 형제 문항과 겹칠 수 있다 — 보정 뒤에는 자기 가드보다 **기존 가드를 먼저** 돌린다.
4. ⚠️ **공유 가드가 URL 실재를 요구하는 자리는 URL 을 지울 수 없다**(`source_url_retired_test` 의
   `replacements`). 더 나은 정본을 찾아도 **추가**만 하고 정리는 컨트롤러 요청으로 넘긴다.
5. ⭐ 민감도는 문구 몇 자리를 깨는 대신 **콘텐츠 전체를 `HEAD` 판으로 잠시 바꿔** 쟀다 — 61건 중
   무엇이 레드가 되고 무엇이 그린으로 남는지가 한 번에 보이고(그린 5건의 이유를 하나씩 적을 수
   있다), 복구는 sha256 으로 증명된다.
