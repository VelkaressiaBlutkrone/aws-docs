# SCS-C03 2단계 보정 — 2026-11-17

> 집행한 1단계 보고: `docs/audits/2026-11-17-full-verify/scs.md`
> 계약: `docs/audits/2026-11-17-full-verify/01-PHASE2-CONTRACT.md`
>
> ⛔ 커밋·브랜치 전환·push·`git stash` 없음 · `verified: true` **0건 작성** · 전체 스위트 미실행.
> 손댄 파일은 전부 `flutter_app/assets/content/scs/**` 와 **새 가드 1파일**뿐이다.

---

## 0. 요약

| 항목 | 수 |
|---|---|
| **채택** | **36건** (🔴 3 + 🟡 32 + 🟢 G3·G5·G6·G8·G9) |
| **기각** | **4건** (아래 §2) |
| **범위 확장** | **10자리** (md 9 + 문항 1 — 보고 목록 밖, 전수 grep 실측) |
| 손댄 파일 | md **15편** · 문항 **16파일 37문항** · 가드 **1파일** (`git diff` 로 기계 집계) |
| **정답 인덱스 변경** | **0건** |
| 새 가드 테스트 수 | **26건** (`flutter_app/test/scs_v2_fix_test.dart`) |

- 1단계 보고 대비: 🔴 **3/3 닫음** · 🟡 **32/32 닫음** · 🟢 9묶음 중 **5묶음 닫음**(G3·G5·G6·G8·G9).
- 기준선 영향: **3,502 → 3,528 (+26)**. ⚠️ `CLAUDE.md` 기준선 줄은 공유 파일이라 **컨트롤러 요청**에 적었다.
- 테스트 실측: **SCS 가드 8파일 + 전역 4파일 = 553건 전부 그린**(`scs_question_propagation_test` 의 **트립와이어 1건만 설계대로 레드** — §5).
  `flutter analyze test/scs_v2_fix_test.dart` → **No issues found**. `node tool/prescreen.test.mjs` → 전부 통과.
- `prescreen` 품질 신호: **98/240(41%) → 94/240(39%)**
  (length-cue 0 → **0** · meta-phrasing 76 → **73** · authoring-memo 1 → **1** · explanation-long 29 → **27**).
- 남긴 것(다음 배치): 🟢 **G1**(메타 문구 73) · **G2**(긴 해설 27) · **G4**(겹침 4묶음 + 선재 1쌍) · **G7**(짧은 오답 근거 56) — §6.

### 민감도 확인 방법 (⛔ `git stash` 는 공유 트리에서 금지)

문구 **네 자리를 임시로 옛 문장으로 되돌려** 새 가드가 레드가 되는지 실측하고, 같은 스크립트의
`restore` 로 복구한 뒤 **sha256 을 기록**했다.

| 깬 자리 | 레드가 된 테스트 |
|---|---|
| `scs-t5-1.questions.json` 해설의 릴리스 한정 | 「인증서를 주는 방법…릴리스를 한정한다」 + 「세 번째 경로가 적혀 있다」 **2건** |
| `scs-t3-1.md` 「가장 강하다」 → 「가장 강한 오리진 보호다」 | 「가장 강한 오리진 보호·모든 고객의 배포 귀속 전수 0건」 |
| `scs-t6-1.questions.json` 정답 보기의 안티패턴 귀속 | 「장기 상승 권한 = 안티패턴 귀속이 정정 줄 하나뿐이다」 |
| `scs-t3-3.questions.json` 해설의 정적 분석 서술 | 「온디맨드 분석으로 단정하지 않는다」 |

→ 4자리로 **5건 레드**, 복구 후 **26건 전부 그린**.
복구 sha256(앞 16자): `t5-1.q=7fe95c1eacfcd019` · `t3-1.md=5fb386efc9107c90` ·
`t6-1.q=01b8cb05eaebd179` · `t3-3.q=0ff60c18a536a126`.

### 기계로 증명한 불변식

- 문항 JSON 은 **`json.dumps(ensure_ascii=False, indent=2)` + CRLF + 끝 개행이 원본을
  바이트 단위로 재현**하는 것을 **16파일 전부에서 먼저 확인**한 뒤 편집했다(대조군 통과).
- 편집 스크립트가 매 파일에서 단정 — ① 바뀐 문항이 지시한 id 집합과 정확히 같다
  ② `verified` 리스트 불변 ③ `correct` 리스트 불변 ④ `skill`·`section`·`difficulty` 불변
  ⑤ CR 수 == LF 수 ⑥ 치환마다 **옛 문구가 정확히 1회**.
- `git diff -U0 -- assets/content/scs/` 의 **`"verified"`·`"correct"`·`"skill"`·`"section"`·
  `"difficulty"`·`"id"` 줄이 0줄**이다(AI 가 그 값을 타이핑하지 않았다는 기계 증명).
- 공백 위생 전수: 240문항의 지문·보기·해설·오답 근거에 **이중 공백·양끝 공백 0건**.
- 길이 비율 전수: 240문항 **양방향 0건**(정답 ÷ 최장 오답 ≤ 1.3 **그리고** 정답 ≥ 최단 오답).

### 이 배치에서 쓴 출처 측정

고유 **37개 URL** 을 `curl -sL` 로 내려받아 **전부 `200 r=0`** 이고 **본문에서 인용 문장을
직접 확인**했다. 대조군 재현: 있는 가이드의 틀린 슬러그 `waf/…/zz-bogus-control.html` →
**`200 r=1`**(2,589B 인덱스 stub).

⚠️ **1차 추출기가 「없다」를 네 번 거짓으로 돌려줬다.** 공백만 접는 정규화(`[ \t ]+`)로는
줄바꿈을 넘는 문장이 매칭되지 않아 `one of three ways`·`used in non-emergency situations`·
`To protect the intellectual property`·`you must call it as an IAM user with long-term
credentials` 가 **전부 0건**으로 나왔다. `\s+` 로 정규화하자 넷 다 실재했다 —
**대조군을 통과시키기 전의 0건은 결과가 아니다**(계약 §3-1).

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 1-1. 🔴 (공개 3건 · 정답 인덱스 전부 유지)

#### `scs-t5-1-q14` — EMR 전송 중 암호화 인증서 경로가 릴리스 7.11.0부터 셋이다 (정답 3 유지)
- **재확인**: 문항의 인용 페이지가 `in one of three ways: by allowing Amazon EMR to create
  and manage certificates for you, by providing a zipped file of certificates…, or by
  referencing a custom Java class` 로 적고, 전용 페이지가 `With Amazon EMR release version
  7.11.0 or later, you have three options` / `For Amazon EMR release version 4.8.0 through
  7.10.0, only a .zip file or custom Java class are supported` 로 갈라 적는다. **보고가 옳다.**
- **고친 방법 — ⭐ 보고의 두 수정안 중 「더 작은 쪽」을 골랐다.** 보고의 1안(보기 `[2]` 를
  명백히 거짓으로 교체)은 **공개 문항의 보기 교체라 사람 승인 대상**이고, 2안(지문을 릴리스
  7.10 이하로 한정)은 **보기를 건드리지 않고 같은 결함을 닫는다.** 지문을 「릴리스 7.9.0
  클러스터에서」로 한정해 오답 `[2]`(「EMR이 자동 생성하므로 제공할 필요가 없다」)가 그
  릴리스 범위에서 **거짓**이 되게 했다 → **정답이 둘이던 상태가 사라진다.**
- 해설·`W0`·`W2` 를 릴리스 경계로 정밀화하고(「7.11.0 이상에서는 EMR이 개인 인증서를 만들어
  관리하고 만든 CA 의 PEM 인증서를 Secrets Manager 에 올린다」) 출처에
  `emr-encryption-enable.html` 을 더했다.
- 함께 **지문의 메타 문구를 걷었다**(「공식이 적는 경로는」 → 「쓸 수 있는 경로는」).
- **md 선결(루브릭 T6)** — `scs-t5-1.md` 3자리: 표 머리글(「방법이 둘입니다」 → 「릴리스에 따라
  갈립니다 — 4.8.0~7.10.0은 둘, 7.11.0 이상은 셋」) · 표에 **세 번째 행 추가** · 시험 포인트 요약.

#### `scs-t6-1-q15` — 현행 SEC03-BP03 의 안티패턴은 넷이고 「장기 상승 권한」이 아니다 (정답 3 유지)
- **재확인**: 현행 인용 페이지에서 `elevated` **0건** · `validate and approve` **0건**
  (대조군 `SEC03-BP02` 2 · `Grant least privilege` 2 · `Medium` 1 양성). 실재하는 안티패턴은
  **넷** — `You do not have well-documented and well-tested emergency access processes` /
  `depend on the same systems (such as a centralized identity provider) as your normal
  access mechanisms` / `are used in non-emergency situations` / `do not generate sufficient
  logs to audit the processes`. **보고가 옳다.**
- ⭐ **보고가 못 본 것을 함께 확인했다** — 현행판이 **형태**도 적는다:
  `Pre-create resources needed by the emergency access process … the cross-account IAM
  roles in all the workload accounts` 와 `require approvals from the user's peers or
  management as appropriate`. 그래서 「교차 계정 역할」과 「승인 절차」는 **지울 필요가 없었다**.
- 정답 보기의 귀속을 그 형태로 바꾸고(「공식이 … 안티패턴으로 적습니다」 → 「미리 만들어 둔
  비상용 교차 계정 역할과 승인 단계를 거치는 요청 절차가 그 형태입니다」 — 정답 보기의 메타
  문구도 함께 사라졌다), 해설의 「안티패턴이 둘」을 현행 넷으로 바꿨다(**개수는 단정하지 않는다**, D-16).
- `W1` 의 반박 근거를 **같은 페이지가 드는 관련 모범 사례 `SEC03-BP02` 최소 권한 부여**로 바꿨다
  (회피형 반박이 아니라 그 보기가 왜 틀렸는지를 말한다).
- 해설 끝의 「최대 15분 · `sts:AssumeRoot`」에 **`API_AssumeRoot.html`**(`900 seconds (15
  minutes)` 실재)을 출처로 달았다. 해설은 **413 → 398자**로 explanation-long 임계 아래로 내려갔다.
- **md 선결** — `scs-t6-1.md` 의 표 두 행(형태·안티패턴 ①②)을 현행판으로 교체하고, 🧠 원리
  블록에 **「장기 상승 권한 부여는 2023-04-10 판의 문구이고 현행판에는 없다」**를 명시했다
  (옛 문구를 인용해 가르치는 자리 — 가드가 이 줄을 **예외로 하나만** 허용한다).
- 🟢 **G9** — 그 URL 의 「(2026-11-09 확인)」 라벨을 **2026-11-17** 로 올렸다(11-17 URL 교체 이후 낡았다).

#### `scs-t3-1-q5` — 「공식 체크리스트가 두 수단을 함께 쓰라고 적는다」는 귀속이 거짓 (정답 0 유지)
- **재확인**: 인용 체크리스트(8,066자 전문)에 `Alternatively, use the CloudFront managed
  prefix list` 가 실재하고 **`strongest` 0 · `together` 0 · `shared` 0**
  (대조군 `Secrets Manager` 2 · `X-Origin-Verify` 1 · `marketplace distributions` 3 양성).
  **보고가 옳다.**
- 정답 보기·해설·`W3` 의 「모든 고객의 배포가 공유」를 **측정된 문장**으로 바꿨다 —
  `LocationsOfEdgeServers.html`: `This allows all of the CloudFront global origin-facing
  servers to reach the instance.` → 「접두사 목록은 CloudFront 오리진 대면 서버를 담아 **어느
  배포에서 왔는지 가르지 못한다**」. 그 페이지를 출처로 더했다.
- ⚠️ **체크리스트 페이지는 지우지 않았다** — 두 수단의 나열과 「헤더 값을 Secrets Manager 에
  두고 교체」를 실제로 담고, `scs_source_fix_test` 가 `scs-t3-1-q1` 에 그 URL 을 **요구**한다.
- **Y2 함께** — `scs-t3-1-q1` 해설의 「함께 쓰며」를 「커스텀 헤더로 확인하고 접두사 목록으로
  네트워크를 좁히며」로 낮추고, 🟢 **G9** 로 출처 제목을 현행 `h1`(「…for **marketplace
  distributions**」)로 맞췄다.
- **md 선결** — `scs-t3-1.md` 3자리에서 「가장 강한 오리진 보호」 귀속을 걷고 **"Alternatively"
  라는 공식 사실 자체를 가르치게** 바꿨다.

### 1-2. 🟡 공개 13건

| 항목 | 문항(정답) | 무엇을 했나 |
|---|---|---|
| Y1 | `t3-1-q3`(2) | 해설·`W0` 의 「그 밖의 **모든** AWS Managed Rules 는 추가 비용 없음」을 Anti-DDoS 전용 페이지(`You are charged additional fees when you use this managed rule group`)와 함께 적게 고치고 출처 추가. **공식 내부 어긋남이라 더 구체적인 전용 페이지를 정본으로 삼았다**(D-15 계열) · 🟢 G3: 정답 47 < 최단 오답 49 였던 **반대 방향 길이 단서**를 함께 닫았다(47 → 53) |
| Y2 | `t3-1-q1`(0) | §1-1 에 적었다 |
| Y3 | `t3-1-q12`(3) | `waf-rule-statement-type-rate-based.html`(`WCUs – 2, as a base cost` · `add 30 WCUs`) 출처 추가 |
| Y4 | `t3-1-q15`(2) | `waf-managed-rule-groups.html`(`To protect the intellectual property of the rule group providers`) 출처 추가 |
| Y5 | `t5-1-q1`(0) | `describe-ssl-policies.html`(`Other methods (… AWS CLI, AWS CloudFormation, and the AWS CDK) – The default security policy is ELBSecurityPolicy-2016-08`) 출처 추가 |
| Y6 | `t1-1-q9`(0) | `finding-aggregation-enable.html`(`You can't use an AWS Region that is disabled by default as your home Region`) + `manage-acct-regions.html`(`March 20, 2019`) 출처 2개 추가 |
| Y7 | `t4-1-q7`(2) | `id_roles_providers_enable-console-custom-url.html` 출처 추가 — `AssumeRole (recommended) or GetFederationToken` 과 `When you use DurationSeconds in an AssumeRole* operation, you must call it as an IAM user with long-term credentials` 둘 다 그 페이지에 실재한다(**G-84 선작업**으로 md 에도 등재) |
| Y8 | `t4-1-q6`(1) | `access_policies.html`(`up to 10 managed session policies`) 출처 추가(md 에도) |
| Y9 | `t2-1-q2`(1) | 「노트북은 **런북의 실행 가능한 판**」이 무출처(`OpsCenter.html`: `SageMaker` 0 · `notebook` 0, 대조군 `runbook` 10 양성) → **추론 서술을 걷고** 검증 가능한 귀속만 남겼다(레포 `exam_guides/SCS-C03.json` 의 `기술 2.1.1` 이 두 이름을 함께 든다 — `scs_guide_sync_test` 가 그 전사를 공식과 바이트 단위로 고정한다). 보고가 「사람 판정」으로 남긴 자리이고 **보기·정답은 건드리지 않았다** |
| Y10 | `t2-1-q15`(2) | 형제 페이지 `forensic-memory-and-disk-acquisition-service.html` 출처 추가(md 에도) |
| Y11 | `t2-1-q14`(1) | `W0` 에서 **상태 문장을 뺐다** — 그 보기가 틀린 이유는 「임계 경로용이 아니다」이고 상태가 아니다(상태는 해설에 그대로). `maintenance_services.html` 출처 추가(md 에도) |
| Y12 | `t6-1-q7`(0) | 해설을 「**두 페이지의 표**」로 고치고 `orgs_manage_policies.html`(표 머리 `Affects management account` · `Supports viewing effective policy for OU or account`) 출처 추가. 정답 보기의 메타 문구(「공식 표가 …」)도 함께 걷었다 |
| Y13 | `t6-1-q3`(2) | `drift.html`(`scans your managed SCPs, RCPs, and Declarative policies daily`) + `proactive-controls.html`(`implemented as preCreate and preUpdate hook handlers`) 출처 2개 추가(둘 다 md 에 이미 있었다) |

### 1-3. 🟡 드래프트 19건

| 항목 | 문항(정답) | 무엇을 했나 |
|---|---|---|
| Y14 | `t1-3-q15`(1) | 지문 전제 모순 해소 — 「ALARM 으로 **바뀌었는데**」 → 「임계값을 넘었는데 알람이 ALARM 으로 **바뀌지 않고**」(`The alarm remains in INSUFFICIENT_DATA and does not perform alarm actions until the warm-up period ends`). 보기·정답 불변 + 지문 메타 문구 제거 |
| Y15·Y16 | `t1-3-q3`(1)·`q4`(3) | 「로그 그룹을 API Gateway 가 **관리**」 → 「**스테이지를 배포할 때** API Gateway 가 만든다」로 정밀화하고 `view-cloudwatch-log-events-in-cloudwatch-console.html`(`API Gateway creates log groups or log streams for an API stage at the time when it is deployed`) 출처 추가 |
| Y17·Y18 | `t1-2-q12`(3)·`q13`(0) | 열린 갭 **G-31** 의 자리 — 세 소개 페이지를 **이 세션에서 측정해** 출처로 달았다(Lambda `serverless compute service … run code without provisioning or managing servers` · OpenSearch `search and analytics engine for use cases such as log analytics` · Grafana `data visualization service … from multiple sources`). ⚠️ 「**변환 층**」이라는 이름은 공식이 적지 않으므로 해설을 **서버리스 컴퓨팅이라는 성질에서 따라오는 추론**으로 적었다(「공식이 적는다」로 귀속하지 않았다) |
| Y19 | `t2-2-q1`(0) | 해설·`W1` 의 귀속을 갈랐다 — 「공식 흐름이 **고정하는 것은 메모리 캡처 뒤 격리**이고, 디스크 스냅샷을 격리 앞에 두는 것은 **휘발성 순서 원칙의 적용**」(인용 페이지에 `snapshot` 0건) |
| Y20 | `t3-2-q12`(3) | `API_ContinuousIntegrationScanConfiguration.html`(`PULL_REQUEST`·`PUSH`) + `API_PeriodicScanConfiguration.html`(`WEEKLY`·`MONTHLY`·`NEVER`) 출처 2개 추가 · 🟢 G3 의 둘째 자리(정답 77 < 최단 오답 80) 해소 |
| Y21 | `t3-2-q13`(0) | 같은 Task `q12` 가 쓰는 `cli/latest/reference/codeguru-security/`(`On November 20, 2025, AWS will discontinue support…`) 출처 추가 |
| Y22 | `t3-3-q14`(1) | 「**온디맨드 분석**」을 걷었다(§2 참조 — 확인되지 않음) → 정답 보기를 「구성만 보는 **정적 분석**이라 트래픽을 흘리지 않습니다」로, `W0` 를 「두 필드 역할이 뒤바뀌었다」는 **참인 반박**으로 다시 썼다. 1,968자 목차 페이지(`working-with-network-access-scopes.html`)를 `how-network-access-analyzer-works.html`(`automated reasoning algorithms` · `static analysis` · `no packets are transmitted`)로 교체 |
| Y23 | `t3-3-q15`(2) | 해설의 자동 추론 귀속을 담지 않는 `what-is-network-access-analyzer.html`(`reasoning` 0건)을 같은 정본으로 교체 |
| Y24 | `t4-2-q6`(1) | 「RBAC 옆에 ABAC 를 더하는 길이 **공식 권고**」를 걷었다(인용 페이지: `recommend`·`alongside`·`in addition`·`combin`·`aws:ResourceTag` **전부 0건**, 적는 것은 `ABAC provides the following advantages over the traditional RBAC model` 까지). 지문에서 RBAC 관계 질문을 빼고 조건 키 질문으로 좁혀 **보기 `[0]` 이 여전히 거짓**이 되게 했고 `reference_policies_condition-keys.html` 출처를 달았다 |
| Y25·Y26 | `t5-2-q6`(2)·`q14`(1) | `snapshot-ami-policy.html` 출처 추가 + 공식 귀결로 정밀화 — 「보존 임계 시점에 아직 잠겨 있으면 **DLM 이 그 스냅샷을 더 이상 관리하지 않으므로 수동 삭제가 필요**하다」(`Amazon Data Lifecycle Manager no longer manages that snapshot. You must manually delete the snapshot if it is no longer needed.`) |
| Y27 | `t5-2-q11`(2) | 귀속을 **API 참조**로 옮기고(`File systems cannot transition into Archive storage before transitioning into IA storage`) `API_PutLifecycleConfiguration.html` 출처 추가 |
| Y28 | `t5-2-q9`(0) | 문항 해설의 IoT·컨테이너·Notation 부연을 걷었다(인용 `governance-code-signing.html`: `IoT`·`Notation`·`container` 전부 0건) — 정답을 가르지 않는 문장이고 해설이 **309 → 201자**가 됐다. `W3` 을 「Lambda 코드 서명이 공식 기능이고 코드 서명 구성을 함수에 연결해 쓴다」는 **참인 반박**으로 바꿨다. ⚠️ **md 쪽은 기각**(§2) |
| Y29 | `t5-3-q7`(2) | `W3` 의 「**모든** 키 저장소 유형이 FIPS 140 수준 3으로 검증」을 걷었다 — 그 문장은 `key-store-overview.html` 의 **표준 키 저장소 단락**에 있다(`The standard key store in AWS KMS … generated in and protected by hardware security modules (HSMs) that are FIPS 140-3 Level 3 validated`). 「통제 입증이 불가능하다는 전제가 틀렸다」는 반박으로 다시 썼다 |
| Y30 | `t6-2-q6`(1) | `reference_policies_condition-keys.html`(`aws:RequestTag` 7 · `aws:TagKeys` 6) 출처 추가 |
| Y31 | `t6-2-q14`(1) | 「Account Factory 가 Service Catalog 의 프로비저닝된 제품 위의 추상화」 부연을 문항에서 걷었다(인용 `servicecatalog/…/introduction.html`: `Account Factory`·`Control Tower` 0건). 해설 **438 → 347자** |
| Y32 | `t6-3-q9`(0) | **D-04 충돌** — ⭐ 보고의 두 안 중 **(a) 지문 한정**을 골랐다(「이 조직은 Audit Manager 를 이미 쓰고 있습니다」). 보기·정답을 바꾸지 않고 「새로 도입하는 조직인데 정답이 닫힌 서비스」라는 모순만 없앤다. **(b) 둘째 요구의 답을 닫히지 않은 수단으로 바꿔 다시 쓰기는 사람 승인 영역**이라 §5 에 남겼다 |

### 1-4. 🟢 (5묶음)

- **G3** — 길이 단서 **하한을 `handled` 목록에서 240문항 전수로** 올렸다. 목록 밖으로 새어
  있던 두 자리(`t3-1-q3` 47<49 · `t3-2-q12` 77<80)를 고쳤다.
  ⚠️ `t3-2-q12` 는 **창이 좁다** — `scs_source_fix_test` 가 「정답이 최장이 아니다」를 요구하므로
  **80 ≤ 정답 ≤ 82** 다. 1차에 83으로 만들어 그 가드가 레드가 됐고 정확히 80으로 맞췄다.
- **G5** — `t6-3-q13` `W1` 의 「Agent 는 프리뷰 릴리스입니다」를 걷었다(상태는 해설에 그대로).
  전수로 `wrongExplanations` **720개**에서 「유지 관리 상태」·「프리뷰 릴리스」가 **0건**이다.
- **G6** — `scs-t3-1.md` 의 WAF 보호 대상 목록에 App Runner 유지 관리 상태 한 줄을 달았다
  (공식 WAF 페이지가 지금도 그 이름을 싣는 것은 사실이라 **지우지 않았다**).
- **G8** — 「전제가 다섯」을 문항 `W1` 과 `scs-t6-3.md` 에서 걷었다(열거는 그대로 — D-16).
- **G9** — `t3-1-q1` 출처 제목과 `scs-t6-1.md` 의 낡은 확인 날짜.

---

## 2. 기각 — 왜 고치지 않았는가

### 2-1. `scs-t5-1-q14` 의 「보기 `[2]` 교체」 (보고 1안)
보고가 **사람 승인 대상**으로 적은 수정이다. 같은 보고가 제시한 2안(지문을 릴리스 범위로
한정)이 **보기를 건드리지 않고 정답 유일성을 회복**하므로 더 작은 쪽을 골랐다. 공식이
`For Amazon EMR release version 4.8.0 through 7.10.0, only a .zip file or custom Java class
are supported` 로 그 범위를 **명시**하므로 지문 한정이 임의 설정이 아니다.

### 2-2. `scs-t3-1-q1` 의 「출처 교체」 (보고 Y2 수정안)
체크리스트 페이지를 **지우지 않았다**. 그 페이지는 「커스텀 오리진 헤더 + Secrets Manager 에
값 보관·교체」와 두 수단의 나열을 **실제로 담고**(`X-Origin-Verify` 1 · `Secrets Manager` 2),
`scs_source_fix_test:184` 가 이 문항에 그 URL 을 **요구**한다. 거짓이던 것은 **「함께 쓰라고
적는다」는 귀속**이므로 그 문구만 낮추고 **제목을 현행 `h1`** 으로 맞췄다.

### 2-3. `scs-t5-2.md` 의 컨테이너·Notation 서술 (Y28 의 md 쪽)
**md 는 옳다.** `signer/latest/developerguide/Welcome.html` 이 글자 그대로 적는다 —
`With AWS Signer and the Notation CLI from the Notary Project, you can sign container images
stored in a container registry such as Amazon Elastic Container Registry (Amazon ECR). The
signatures are stored in the registry alongside the images…`(`200 r=0` 실측).
⭐ 즉 **문항에서 걷은 그 문장도 사실이었고 결함은 「인용 페이지가 담지 않았다」는 것뿐**이다.
문항 쪽은 정답을 가르지 않는 부연이라 걷는 쪽이 싸고(해설 길이도 준다), **md 는 지우지 않고
그 정본을 출처로 달았다**. 옳은 교육 내용을 지우는 것이 목적이 아니다.

### 2-4. `scs-t5-2.md` 의 「관리 방법이 둘입니다」
EMR 인증서와 **무관한 주제**(키 관리)다. 「방법이 둘」을 트리거로 쓰면 걸리는 자리이므로
가드 트리거를 **「인증서를 주는 방법」**으로 좁혔고, 그 좁힘이 공허하지 않다는 것을
hits ≥ 3 으로 고정했다.

---

## 3. 범위 확장 — 보고가 하한이던 자리 (전수 실측)

보고의 목록을 고친 뒤 **같은 문구로 자기 자격증 md 16편 + 문항 16파일(총 256개 텍스트)을
전수 grep** 해 **보고 밖 10자리**를 더 찾았다. 전부 닫았다.

| 자리 | 수 | 무엇이 남아 있었나 |
|---|---|---|
| `scs-t3-1.md` 과금 층 목록 | 1 | 「그 밖의 **모든** AWS Managed Rules — 추가 비용 없음」 (Y1 은 문항만 적었다) |
| `scs-t3-3.md` | **3** | 「온디맨드 분석」 3자리 (Y22 는 문항만 적었다) + 「몇 분 뒤 조사 결과가 납니다」라는 미확인 수치 |
| `scs-t4-2.md` | 1 | 「기존 RBAC 옆에 ABAC 를 더하는 길이 **공식 권고**」 (Y24 는 문항만 적었다) |
| `scs-t5-3.md` | 1 | 「**모든** 키 저장소 유형이 FIPS 140 수준 3으로 검증」 (Y29 는 `W3` 만 적었다) |
| `scs-t6-3.md` | 1 | 「전제가 **다섯**」 (G8 이 적은 자리 — md 가 함께 고쳐져야 전수 가드가 초록이 된다) |
| `scs-t6-2.md` | **2** | 「Account Factory 가 **Service Catalog 의** 프로비저닝된 제품 위의 추상화」 (Y31 은 문항만 적었다). ⚠️ 공식 `account-factory.html` 전문(3,366자)에 **`Service Catalog` 0건**이고 적는 것은 `a provisioned product that's associated with an account that Account Factory vends` 다 → **측정된 서술로 좁히고** 그 페이지를 출처로 달았다 |
| `scs-t3-1.questions.json` | 1 | 🟢 G3 의 반대 방향 길이 단서(`t3-1-q3` 47 < 49) — 보고가 🟢 로만 적었지만 **하한을 전수로 올리면 레드**가 되므로 함께 고쳤다 |

⭐ **내 자신의 편집이 새 신호를 하나 만들었고 prescreen 이 잡았다.** Y24 해설에 쓴 「… 페이지가
**정본**입니다」가 `authoring-memo: 정본` 으로 걸렸다 — 2026-11-11 §4 2단계가 「쪽이 정본」을
저작 메모로 판정해 걷은 **같은 계열의 다른 어형**이다. 「열거합니다」로 고쳐 1건으로 복귀했다.

---

## 4. flip 준비 상태

「준비됨」의 뜻: **1단계 보고의 🔴·🟡 가 0건**이다(🟢 는 flip 을 막지 않는다고 보았다 —
검수자가 다르게 보면 조정한다). ⚠️ **md 본문 전수 사실 대조는 1단계 보고가 하지 않았으므로
루브릭 T6 는 검수자가 따로 본다**(보고 머리말의 「덮지 못한 것」).

### 공개 6 Task (이미 라이브 — 수선 완료)

| Task | 보고 🔴 | 보고 🟡 | 상태 |
|---|---|---|---|
| `scs-t1-1` | 0 | 1 | ✅ 닫음 (Y6) |
| `scs-t2-1` | 0 | 3 | ✅ 닫음 (Y9·Y10·Y11) |
| `scs-t3-1` | 1 | 4 | ✅ 닫음 (🔴 q5 + Y1·Y2·Y3·Y4 + md 3줄 선결) |
| `scs-t4-1` | 0 | 2 | ✅ 닫음 (Y7·Y8) |
| `scs-t5-1` | 1 | 1 | ✅ 닫음 (🔴 q14 + Y5 + md 3자리 선결) — **보기 교체 없이** 닫았다 |
| `scs-t6-1` | 1 | 2 | ✅ 닫음 (🔴 q15 + Y12·Y13 + md 4자리 선결) |

### 드래프트 10 Task — **이 보고 기준으로 10 Task 전부 flip 준비 완료**

| Task | 보고 🟡 | 상태 | 남은 🟢 |
|---|---|---|---|
| `scs-t1-2` | 2 | ✅ 닫음 (Y17·Y18) | G4 ③ 겹침(정답 자카드 0.160 — 지표 아래, 사람이 읽어야 보인다) |
| `scs-t1-3` | 3 | ✅ 닫음 (Y14·Y15·Y16) | — |
| `scs-t2-2` | 1 | ✅ 닫음 (Y19) | — |
| `scs-t3-2` | 2 | ✅ 닫음 (Y20·Y21) | — |
| `scs-t3-3` | 2 | ✅ 닫음 (Y22·Y23) | G4 ①(0.130)·④(0.148) |
| `scs-t4-2` | 1 | ✅ 닫음 (Y24) | — ⭐ **비중 20% 인 D4 의 문항 풀 확대는 이 Task 가 먼저다**(보고 §7-2) |
| `scs-t5-2` | 4 | ✅ 닫음 (Y25·Y26·Y27·Y28) | ⚠️ `q6`↔`q14` 정답 자카드 **0.261**(보고 목록 밖 · **선재** — 내가 바꾼 것은 해설·출처뿐이고 정답 보기는 그대로다) |
| `scs-t5-3` | 1 | ✅ 닫음 (Y29) | explanation-long 7건 |
| `scs-t6-2` | 2 | ✅ 닫음 (Y30·Y31) | explanation-long 7건 |
| `scs-t6-3` | 1 | ✅ 닫음 (Y32 — **지문 한정**) + G5·G8 | G4 ②(0.000~0.077) · ⚠️ **Y32 의 재작성안은 사람 판정**(§5) |

- 게이트 관점: SCS 통합 모의고사는 **이미 열려 있다**(공개 6 Task 90문항, 도메인당 하나).
  추가 flip 은 게이트가 아니라 **문항 풀 확대**가 목적이고, 비중 20% 인 **D4(`scs-t4-2`)**
  가 가장 얇다(도메인별 12.5% 대 20% — 보고 §4-1 의 구조 항목으로 그대로 열려 있다).
- ⚠️ **flip 선결 실측**: `verified` 를 false 로 단정하는 대조군이 **이 배치의 새 가드에 0건**이다
  (계약 §3 대로 구조 단정으로만 썼다). 다른 scs 가드도 2026-11-13 flip 때 이미 정리됐다.

---

## 5. 컨트롤러 요청

- [ ] **`test/scs_question_propagation_test.dart` 의 `registered` 집합에 `scs_v2_fix_test.dart` 등재**
      (이유: 그 파일의 **트립와이어가 설계대로 레드**다 — 「등록 목록에 없는 `test/scs_*` 가
      생기면 깨져서 금지 문장을 옮기거나 등록하라고 알린다」. ⭐ **옮겨 올 규칙은 없다** —
      새 가드의 사실 단정은 전부 `_corpus()`(md 16편 + 문항 240개)를 **합쳐 읽는 전수 집계형**
      이라 문항까지 이미 쓸린다. 등록 주석 문안 제안:
      `// 2026-11-17 전수 검증 2단계 보정 회귀 가드 — 사실 단정이 md + 문항을 합쳐 읽는`
      `// 전수 집계형이라 전파 규칙으로 옮겨 올 금지 문장이 없다.`)
- [ ] **`CLAUDE.md` 기준선 줄: 3,502 → 3,528 (+26)** (`scs_v2_fix_test.dart` 26건. 다른
      보정 세션의 증가분과 합산해 한 번에 고치는 것이 맞다)
- [ ] **정답 인덱스 변경이 필요한 문항: 없음** (37문항 전부 불변, 기계로 증명)
- [ ] **사람 판정으로 남긴 1건** — `scs-t6-3-q9`: 지문 한정으로 D-04 충돌을 닫았지만, 보고의
      (b)안(**둘째 요구의 답을 AWS Config 준수 팩·Security Hub CSPM 의 준수 결과로 바꿔 Artifact
      와 가르는 문항으로 재작성**)은 정답 보기 자체를 바꾸는 일이라 하지 않았다. (b) 를 택하면
      G4 ②(기술 6.3.3 의 3문항이 같은 표를 묻는 겹침)도 함께 풀린다.
- [ ] **교차 자격증 — 다른 자격증 쪽은 건드리지 않았다**(계약 §5-4):
  - `saa/saa-t1-4` 는 Anti-DDoS 관리형 규칙 그룹을 **이미 「추가 요금」으로 올바르게** 적는다
    (보고 §5). **SAA 쪽은 수정 불필요** — SCS 를 그 쪽에 맞춘 것이다.
  - `clf/t2-2.questions.json` 이 `wellarchitected/latest/security-pillar/` URL 을 든다.
    ⚠️ **그 판 전체에 `This whitepaper is for historical reference only and will be
    deprecated in the future.` 배너가 있다**(이 세션 실측, `historical reference only` 1건).
    2026-11-17 URL 교체가 손댄 다른 자격증도 **「그 URL 이 업고 있던 문장」을 다시 세야 한다** —
    `verify-clf` 보정 세션 몫이다(SCS 에서 그 미측정이 🔴 하나를 만들었다).
  - `dea/dea-t4-3.md` 가 `emr-data-encryption-options.html` 을 참고자료로 달지만 **「둘」 단정은
    없다**(보고 §5). DEA 쪽 수정 불필요.
- [ ] **공식 내부 어긋남 2건을 기록으로 남긴다**(수정안 아님):
  WAF 관리형 규칙 그룹의 추가 요금 범위(소개 페이지 ↔ Anti-DDoS 전용 페이지) ·
  Well-Architected `security-pillar/` 판의 지위(「historical reference only」 배너 ↔
  `framework/` 판의 BP 번호 재배정). 어느 판을 정본으로 삼을지는 **사람 판정**이다.

---

## 6. 남긴 것 (다음 배치)

| 항목 | 현재 수치 | 왜 남겼나 |
|---|---|---|
| 🟢 **G1** 메타 문구 | 76 → **73** | 양이 많아 별 배치다(보고 §7-1 ⑤). 이 배치는 **손댄 문항에서만** 걷었다 — `t5-1-q14` 지문 · `t6-1-q15` 정답 보기 · `t6-1-q7` 정답 보기 · `t1-3-q15` 지문 · `t4-2-q6` 지문. ⭐ **보고가 우선으로 든 「정답 보기에 「공식」이 든 13개」 중 3개**(`t5-1-q14`·`t6-1-q15`·`t6-1-q7`)가 이 배치에서 사라졌다 |
| 🟢 **G2** 긴 해설 | 29 → **27** | `t6-1-q15` 413→398 · `t5-2-q9` 309→201 · `t6-2-q14` 438→347 로 셋이 줄었고 임계 초과는 둘 줄었다. 나머지는 사실을 담은 보강의 귀결이라 걷을 후보를 하나씩 읽어야 한다 |
| 🟢 **G4** 겹침 | 4묶음 + **선재 1쌍** | ⚠️ **지표로는 안 보인다** — 네 묶음 전부 정답 자카드 **0.000~0.160**(조사벗김 포함)이고 보고는 **읽어서** 찾았다. 해소는 문항 **교체**라 기존 리터럴 가드(`scs_s6_review_fix_test` 의 13묶음 자카드 단정 포함)와 함께 설계해야 한다. ⭐ 새로 측정한 **`t5-2-q6`↔`q14` 0.261**(보고 목록 밖 · 선재)도 함께 본다. 전수 ≥ 0.33 은 **0쌍**(28,680쌍, 원형·조사벗김 둘 다) |
| 🟢 **G7** 짧은 오답 근거 | 56개(20자 이하) | 양이 많고 「왜 틀렸는지」를 새로 써야 한다. 이 배치가 고친 `W0`·`W1`·`W3` 7개는 그만큼 길어졌다 |
| 보고 §4-1 구조 항목 | D4 12.5% 대 공식 20% | **문항 저작**이 필요해 보정 범위 밖이다(2026-11-11 보고 P-3·P-4·P-5 와 같은 계열) |

---

## 7. 이 배치에서 배운 것 (다음 보정 세션이 밟지 않도록)

1. ⚠️⚠️ **「없다」의 1차 추출기가 네 번 거짓이었다** — 공백만 접는 정규화는 **줄바꿈을 넘는
   문장**을 매칭하지 못한다. `\s+` 로 정규화해야 하고, **알려진 양성 대조군을 통과시키기 전의
   0건은 결과가 아니다.**
2. ⚠️⚠️ **md 「출처」 절 삽입에서 `\r?$` 로 매칭하면 `\r` 를 소비해 `\r\r\n` 을 만든다.**
   CR==LF 단정은 **통과하므로** 그다음 줄 검사가 조용히 어긋난다(프런트매터 ↔ 출처 절 집합
   비교가 1건 모자라게 나온다). 줄 끝은 **전방탐색**(`(?=\r?\n)`)으로 두고 소비하지 않는다.
   ⭐ 그 단정이 없었다면 **파서가 뒤쪽 출처를 버리는** 2026-11-11 라이브 결함을 재현했다.
3. ⚠️ **`String.length` 는 문자 수다**(바이트 수가 아니다 — 한국어는 글자당 3바이트).
   대조군 하한을 바이트 감각으로 잡아 멀쩡한 `scs-t1-2.md`(19,121자 / 31,505바이트)를
   거부했다. **하한은 추측하지 않고 실측값에서 잡는다.**
4. ⚠️ **길이 창이 두 가드 사이에서 좁아지는 자리가 있다** — `scs-t3-2-q12` 는
   `scs_source_fix_test` 의 「정답이 최장이 아니다」와 반대 방향 하한 사이에서 **80 ≤ 정답 ≤ 82**
   다. 반대 방향 결함을 고칠 때 **상한 가드를 함께 본다.**
5. ⚠️ **내 편집이 새 품질 신호를 만들 수 있다** — 「… 정본입니다」가 `authoring-memo` 로
   걸렸다. **보정 뒤 `prescreen` 을 다시 돌려 신호가 줄었는지 확인한다.**
6. ⚠️ **새 `test/*.dart` 를 `Write` 로 만들면 LF 로 쓰인다** — 작업 트리의 다른 `test/*.dart`
   는 **CRLF** 다. git blob 은 어차피 LF 지만 트리 관례에 맞춰 둔다.
7. ⭐ **문항 JSON 왕복 재현이 16파일 전부 바이트 단위로 성립**하므로(대조군 선통과)
   바이트 블록 치환 대신 **필드 단위 편집 + 재직렬화**를 쓸 수 있었다. `verified` 를
   타이핑하지 않는 규율은 **원본 값을 그대로 옮기는 것**으로 지켰고 `git diff` 로 증명했다.
8. ⚠️ 공유 트리라 **다른 세션의 테스트 실행과 충돌해 `build/unit_test_assets` 생성이 한 번
   실패**했다(`PathNotFoundException`). 계약대로 **한 번만 재시도**하니 정상이었다 — 결함이 아니다.
