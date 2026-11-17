# SOA 2단계 보정 — 2026-11-17

> 집행한 1단계 보고: `docs/audits/2026-11-17-full-verify/soa.md` · 계약: `01-PHASE2-CONTRACT.md`
> 범위: `flutter_app/assets/content/soa/` (md 20편 · 문항 300개 — **전부 라이브**).
> 이 세션은 **커밋·브랜치 전환·stash·flip 을 하지 않았다.** 공유 파일도 건드리지 않았다(§5 에 요청).
> 방법: 항목마다 공식 문서를 `curl -sL` 로 받아(전부 `200 r=0`) **공백을 접은 본문**에 정규식으로 탐침해 채택/기각/범위 확장을 판정 → 바이트 블록 치환(횟수 단정 · CR==LF 불변식 · 구조 다이제스트 불변) → HEAD 대비 전수 사후 검증 → 가드 → `test/soa_*`.

## 0. 요약

- **채택 29 / 기각(부분 기각 포함) 3 / 범위 확장 12** — 1단계 🔴 6 · 🟡 19 · 🟢 8 대비
  - 🔴 **6/6 반영**(R1~R6) · 🟡 **18/19 반영**(Y1~Y17 · Y19 — Y18 중복은 사람 승인 영역이라 §5 로) · 🟢 **6/8 반영**(G2·G3·G4·G5·G7·G8 — G1·G6 은 §남긴 것)
- 손댄 파일: **md 14편 · 문항 19파일(문항 71개) · 가드 1**(`flutter_app/test/soa_v2_fix_test.dart`)
- **정답 인덱스 변경: 0건** — 300문항 전수를 HEAD 와 비교해 `correct`·`verified`·`id`·`skill`·`difficulty`·보기 수·`wrongExplanations` 키가 전부 같음을 기계로 확인했다. 바꿔야 하는 문항도 **0건**이다.
- 새 가드 테스트 수: **49건**(`flutter analyze` 0건). 민감도: 문구 6곳을 임시로 깨면 **서로 다른 테스트 6건이 레드**(R1·R2·R3·R4·Y10·Y19)가 되고, 복구 후 **sha256 일치 · 49건 그린**.
- `flutter test test/soa_*`(11파일): **345 통과 · 3 실패** — 실패 셋은 전부 **공유 파일 쪽 예상 레드**다(§5): `lastVerified` 고정 맵 2곳 + DEA 세션이 만든 `dea_v2_fix_test.dart` 를 잡은 트립와이어. 기존 SOA 가드(`p1`·`p2`·`p3`·`question_facts`·전파 `_factRules`)는 전부 그린.
- 새로 인용한 URL **50개 전부 `200 r=0`**(대조군 재현: 있는 가이드의 틀린 슬러그 `200 r=1` → 인덱스 · 없는 가이드 접두사 진짜 `404 r=0`).
- `prescreen`(반영 후): 구조·정합성 플래그 **0건 유지** · length-cue **181 → 179** · meta-phrasing **1 → 0** · explanation-long 0 · Task 내 중복 후보 0쌍.
- 남긴 것(다음 배치): 🟢 G1(길이 단서 179문항) · G6 · 🟡 Y18(중복 8묶음 — 사람 승인) · §4-1 커버리지 · §6-1 고해상도 경보 주기 · Y19 중 대체 출처 미특정 3문항 · 기타(§남긴 것).

---

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 🔴

| # | 자리 | 공식 근거(직접 측정 원문) | 고친 내용 |
|---|---|---|---|
| **R1** | `soa-t1-2-q3`(정답 **0** 불변) · `soa-t1-2.md` | `monitoring/Alarm-On-Logs.html`: "You can create CloudWatch alarms that monitor your log data in two ways: **Log Alarm approach** — Create a Log Alarm that runs a CloudWatch Logs Insights query on a schedule and evaluates the aggregated results directly against a threshold. **Metric filter approach** — …" · `alarm-log.html`: "Unlike metric alarms that require metric filters as an intermediate step, Log Alarms evaluate directly on log data" | **정답이 둘이던 문항.** 오답 보기 [2]「Logs Insights 쿼리를 5분마다 실행하는 경보」(이제 참)를 **명백히 거짓**인 「로그 그룹의 보존 기간을 5분으로 줄여 … SNS 로 자동 전달」로 교체. `wrongExplanations["2"]` 재작성, 해설에 「경보 방법은 둘 — 지표 필터 + 지표 경보 / Log Alarm」 병기, 출처에 `Alarm-On-Logs.html` 추가. md §3 에 두 번째 경로 불릿 + 자가 점검 Q1 에 한 문장 + 프런트매터 출처 |
| **R2** | `soa-t1-5-q13`(정답 **0** 불변) · `soa-t1-5.md` 6자리 | `monitoring/Database-Insights.html`: "AWS announced that the end-of-life date for Performance Insights was July 31, 2026, and has migrated Performance Insights users to Database Insights." · `USER_PerfInsights.html` 의 제목이 "Monitoring DB load with Amazon CloudWatch Database Insights on Amazon RDS" | 정답 보기 → 「CloudWatch Database Insights(구 성능 개선 도우미)」, 해설에 종료일·이전·「시험 가이드 문구는 옛 이름」, 출처 제목을 현재 페이지 제목으로 + 종료 공지 페이지 추가. md 6자리(체크리스트·절 제목·소제목·표·운영 신호·시험 포인트) 병기 |
| **R3** | `soa-t4-3-q11`(정답 **0** 불변) · `soa-t4-3.md` 원리 블록 | `import-certificate-prerequisites.html`: "you must provide both the certificate and its private key" · `import-certificate.html`: "ACM does not provide managed renewal for imported certificates. To renew an imported certificate, you can obtain a new certificate from your certificate issuer and then manually reimport it into ACM. This action preserves the certificate's association and its Amazon Resource name (ARN)." | 해설의 거짓 이유(「개인 키가 ACM 외부」)를 걷고 공식 절차(발급자에게서 새 인증서 → 다시 가져오기 · 연결과 ARN 유지)로. 사전 조건 페이지를 출처에 추가. md 원리 블록 세 줄 재작성 |
| **R4** | `soa-t5-3.md` (문항 0) | `routing-policy.html`: "When you create a record, you choose a routing policy" 목록에 **Geoproximity** 와 **IP-based** 가 함께 있고 `Traffic Flow` **0건**(대조군: 같은 추출에서 `Geoproximity routing policy` 1건) · `routing-policy-geoproximity.html`: "The maps are available only with Traffic Flow." | 「7종」 4자리에서 개수를 걷음 · 표에 **IP 기반(IP-based)** 행 추가 · 「Traffic Flow 에서만/필요」 5자리를 「레코드 생성 시 고르는 정책 · **지도만** Traffic Flow」로 · 프런트매터에 geoproximity 페이지 |
| **R5** | `soa-t4-2.md` 3자리+표 · `soa-t4-2-q12`(정답 **3** 불변) | `trusted-advisor-check-reference.html`: "Cost optimization · Performance · Security · Fault tolerance · Service limits · **Operational Excellence**" · 예시 점검은 `operational-excellence-checks.html` 의 실제 점검 이름에서 옮김 | 「5범주」 개수 표현을 걷고 **운영 우수성** 행·나열 추가, `q12` 해설에 운영 우수성 |
| **R6** | `soa-t3-2.md` · `soa-t3-2-q1`(정답 **0** 불변) | `deregister-ami.html`: "When deregistering an AMI, you can optionally delete its associated snapshots at the same time. However, if a snapshot is associated with multiple AMIs, it won't be deleted even if specified for deletion" · "**By default**, deregistering an AMI also has no effect on any snapshots" | 「연동 삭제가 불가」 단정을 「기본 동작으로는 남는다 · 함께 삭제를 선택할 수 있다 · 다른 AMI 가 참조하면 지정해도 남는다」로. md 6자리 + `q1` 해설 |

### 🟡 Y1~Y17 (정답 인덱스 전부 불변)

| # | 고친 자리 | 근거 원문 | 요지 |
|---|---|---|---|
| Y1 | `soa-t1-3-q6` 해설 · `soa-t1-3.md` 표·시험 포인트 | `cloudtrail-lake.html`: "will no longer be open to new customers starting May 31, 2026 … Existing customers can continue to use the service as normal" | 가르치는 층에만 상태 한 줄(`soa-t4-2-q4` 의 오답 층 언급은 손대지 않음) |
| Y2 | `soa-t4-2-q4`·`q5` 해설 · md §2 | `what-is-securityhub.html` 제목 "Introduction to AWS Security Hub CSPM" · "Security Hub CSPM processes finding data using the AWS Security Finding Format (ASFF)" | 「현재 공식 이름은 AWS Security Hub CSPM」 병기(가이드 문구 「Security Hub」는 유지). `q4` 출처 제목 교정 |
| Y3 | `soa-t4-3-q13` 정답 보기·해설 · `soa-t4-3.md` 5자리 · `soa-t3-3.md` 1자리 | `rotating-secrets.html`: "Managed rotation doesn't use a Lambda function." / "Rotation by Lambda function – For other types of secrets" | 「Lambda 기반 교체」 → 「자동 교체 내장(관리형 교체는 Lambda 없이 · 그 밖은 Lambda 함수)」 |
| Y4 | `soa-t4-3-q12` 정답 보기·해설 · md :190 | `dns-renewal-validation.html`: "The certificate is currently in use by an AWS service. All required ACM-provided DNS CNAME records … are present and accessible via public DNS." | 「AWS 서비스에서 사용 중이고 DNS 검증 레코드가 유지되는 경우」 한정 |
| Y5 | `soa-t4-3-q10`·`soa-t5-3-q13` 해설 · md 표·시험 포인트·자가 점검 | `how-to-edge-optimized-custom-domain-name.html`: "You must request or import a certificate for your edge-optimized custom domain name in the US East (N. Virginia) – us-east-1 Region." | 「리전형 API Gateway 는 같은 리전 · 엣지 최적화 사용자 지정 도메인은 us-east-1」 |
| Y6 | `soa-t5-3-q11` 정답 보기·해설·`W1` · md 3자리 | `PayingForInvalidation.html`: "The first 1,000 invalidation paths that you submit per month are free … A path that includes the * wildcard counts as one path" · `Invalidation.html`: "we recommend that you primarily use file versioning … the user might continue to see the old version until it expires from those caches … Versioning is less expensive" | 「잦은 전체 무효화는 비용·부하」 논리를 공식 이유(사용자·중간 캐시의 옛 버전 · 롤백 · 무효화 비용 없음)와 과금 단위로 교체 |
| Y7 | `soa-t3-3-q8` 정답 보기·해설 · `soa-t3-2-q10` 해설 · md 3자리 | `patch-manager-tag-a-patch-group.html`: "the tag key must be Patch Group or PatchGroup. PatchGroup (without a space) is required if you have allowed tags in EC2 instance metadata" · "Patch groups are not used in patching operations that are based on patch policies" | 「정확히 `Patch Group` 일 때만」 → 두 키 + 패치 정책 한정 |
| Y8 | `soa-t2-1-q11` 해설 · md :168 | `health-check-grace-period.html`: "In the console, by default … 300 seconds … Its default value is 0 seconds when you create an Auto Scaling group using the AWS CLI or an SDK." | 「(콘솔 기본 300초, CLI·SDK 기본 0초)」 |
| Y9 | `soa-t2-1-q5` 해설 · md :118 | `predictive-scaling-policy-overview.html`: "must have at least 24 hours of data … analyzing metric data from up to the past 14 days" | 「14일 이상 권장」 → 「최근 최대 14일을 분석」 |
| Y10 | `soa-t2-1.md` 1자리 · `soa-t3-4.md` 4자리 | `ec2-auto-scaling-health-checks.html`: "Amazon EC2 · Elastic Load Balancing · VPC Lattice · Amazon EBS · Custom health checks that you define" | 「통해서만」·「상태 점검 … 연결해야」 어형을 다른 소스(사용자 정의 상태 확인/점검)와 함께 적는 서술로. `soa_p2` 가 필수로 묶은 「유일한 경로는 아닙니다」는 그대로 |
| Y11 | `soa-t5-4.md` :120 · :194 | `flow-log-records.html`: "REJECT — … the traffic was not allowed by the security groups or network ACLs, or packets arrived after the connection was closed." | 문서 안의 자기모순(2026-10-19 정정의 잔여) 해소 |
| Y12 | `soa-t4-1-q6` `W2` · `soa-t5-3-q4` `W2` · `soa-t2-1-q7` `W1` + md :130 | `access_policies_boundaries.html` · `resource-record-sets-choosing-alias-non-alias.html`("you can't set the time to live (TTL)") · `ec2-auto-scaling-default-instance-warmup.html`("waits before contributing usage data to the aggregated metrics") | 회피형·부정확 반박 3건을 참·거짓을 말하는 문장으로 |
| Y13 | `soa-t4-2-q3` 정답 보기·해설 · md :118 | `evaluate-config_components.html` 트리거 표 | 「반드시 포착」 걷고 트리거 유형 병기(§3 범위 확장 참조) |
| Y14 | `soa-t5-2-q15` 정답 보기·해설 · md :132·:155 | `SetUpVPNConnections.html`: "It might take a few minutes to create the VPN connection." · DX 「수 주」는 **확인되지 않음** | DX 쪽을 수치 없이 「물리 회선 설치가 필요해 VPN 보다 오래 걸림」으로. 오답 [3]의 「VPN 은 수 주」는 거짓 보기이므로 그대로 |
| Y15 | `soa-t3-4-q5` · `soa-t1-3-q9` 해설 | `eb-create-rule-schedule.html`: "Scheduled rules are a legacy feature of EventBridge … We recommend that you use Scheduler to invoke targets on a schedule." | 두 해설에 Scheduler 권장 한 줄(md 는 이미 옳았던 역방향 잔존) |
| Y16 | `soa-t5-1.md:199` | `hosted-zone-private-considerations.html`: "you must set the following Amazon VPC settings to true: enableDnsHostnames enableDnsSupport" | 둘 다 |
| Y17 | `soa-t5-1-q14` 정답 보기·오답 [2]·해설·`W1`·`W2` · md 4자리 | `subnet-route-tables.html`: "Every route table contains a local route … This route is added by default to all route tables. … You can replace or restore the target of each local route as needed." · 「삭제 불가」 문장은 **0건**(대조군: 같은 추출 `local route` 9건 · `delete` 3건은 전부 라우팅 **테이블** 삭제) | 확인되지 않은 「삭제할 수 없고」를 정답의 실질에서 빼고 확인된 사실로. 오답 [2]는 「운영자가 삭제해 서브넷을 격리하는 **표준 수단**으로 쓴다」로 바꿔 명백히 거짓으로 유지 |

### 🟡 Y19 출처 — 47문항 중 **44문항 반영** (정답·사실 서술 불변)

- 방침: **추가**가 기본이다(기존 URL 이 `source_url_retired_test` 의 `replacements` 정본에 묶인 경우가 있어 지우지 않았다). 유일한 **삭제**는 `soa-t1-1-q2`·`q3`·`q4`·`q10`·`q13` 의 둘째 출처 `working_with_metrics.html` 이다 — 그 페이지는 OTel/Classic 지표 모델 비교 허브가 됐고 `retention` **0건** · `StorageResolution` **0건**이라 출처 제목(「지표 보존과 집계」 등)이 거짓이었다(대조군: 같은 추출에서 `dimension` 1건). 테스트가 그 URL 을 묶은 곳은 0건.
- 문항마다 **추가한 페이지가 그 문항의 단정을 담는지** 본문 탐침으로 확인했다(문항 ID ↔ URL 꼬리 49쌍은 가드의 `need` 맵에 파일에서 덤프한 값으로 고정).
- 이 표 밖에서 R/Y 항목을 닫느라 더한 출처: `q3`(Alarm-On-Logs) · `soa-t1-5-q13` · `soa-t4-3-q11`·`q10`·`q12` · `soa-t5-3-q13`·`q11` · `soa-t4-1-q6` · `soa-t5-2-q15` · `soa-t2-1-q7` · `soa-t5-1-q14`.

### 🟢

| # | 자리 | 내용 |
|---|---|---|
| G2 | `soa-t5-4-q5` 지문 | 「공식 문서가 드는 예시는?」 → 「`REJECT` 로 기록되는 경우는?」(prescreen meta-phrasing 1 → 0) |
| G3 | `soa-t2-3-q4` 해설 · md 3자리 | 「콜드오프」 → 「쿨링오프」 — `vault-lock.html`: "cooling-off period (\"grace time\")" |
| G4 | `soa-t2-3-q6` 지문 | 「EBS 볼륨과 AMI」 → 「EBS 스냅샷과 EBS 기반 AMI」 — `snapshot-lifecycle.html`: "automate the creation, retention, and deletion of EBS snapshots and EBS-backed AMIs" |
| G5 | `soa-t2-4-q10` 오답 [2] | 이중 부정 → 단문 거짓 보기(「자동 장애 조치는 Multi-AZ DB 인스턴스 배포에서도 지원되지 않는 기능이기 때문」). `soa_p1` 의 Multi-AZ 한정 규칙 통과 |
| G7 | `soa-t1-2.md` | 「고대수(custom) 지표」 → 「사용자 지정(custom) 지표」 — EMF 페이지: "generate custom metrics" |
| G8 | `soa-t1-5.md` | 두 사실을 담던 괄호를 두 문장으로 분리 |

---

## 2. 기각 — 왜 고치지 않았는가

| 보고 항목 | 판정 | 이유 |
|---|---|---|
| **Y4** 의 `soa-t4-3.md:230`(「같은 한정」 요구) | 기각 | 그 줄은 「통합 서비스에 **쓰면** … 관리형 갱신」으로 **이미 사용 조건을 달고 있다.** 「완전 자동」을 한정 없이 말하는 자리는 :190 하나였고 거기만 고쳤다 |
| **Y7** 의 md `Patch Group` 11줄 전부 | 부분 기각 | 배타성(「정확히 … 일 때만」·「공백·대소문자 정확히」·「공백 포함이 정확해야」)을 말하는 **3줄 + 문항 2개**만 고쳤다. 나머지(`soa-t3-2.md` :154·:196·:215 · `soa-t3-3.md` :227)는 「`Patch Group` 태그로 정의한다」는 **참인 서술**이고 공식도 그 키를 첫째로 든다 |
| **R2** 수정안의 정답 보기 문구(「…(구 성능 개선 도우미·Performance Insights)」) | 문구만 기각 | 병기 방침은 채택하되 **압축형**(「CloudWatch Database Insights(구 성능 개선 도우미)」)으로 썼다. 이 문항은 이미 length-cue 대상이라 정답 보기를 더 늘리지 않으려는 것이고, 영문 옛 이름은 해설에 있다. ⚠️ 그래도 정답 보기가 31자 → 41자로 늘었다(실측 · 최장 오답 18자) — G1 배치가 오답을 같은 정밀도로 올릴 때 함께 맞출 자리다 |
| **Y17** 수정안의 오답 [2] 「그대로 유지」 | 문구만 기각 | 정답에서 「삭제할 수 없고」를 빼면 「삭제하면 서브넷 간 통신을 차단할 수 있다」는 **조건문이라 거짓임이 약해진다**(삭제 가능 여부가 공식 문장으로 확인되지 않는다). 계약 §2 대로 **명백히 거짓**(「격리의 표준 수단」)으로 바꿨다 |

---

## 3. 범위 확장 — 보고가 하한이던 자리

| # | 자리 | 무엇이 더 있었나 |
|---|---|---|
| E1 | **`soa-t2-3-q8`**(정답 **1** 불변) | Y19 가 출처만 바꾸라던 문항인데, 그 대체 페이지가 **해설을 정정한다** — `BackupRetention.html`: "between **0** and 35 days. Setting the backup retention period to 0 disables automated backups" · 기본값 "one day"(API/CLI) / "seven days"(콘솔). 해설에 「0 은 비활성화」, `W0` 의 회피형 「7일은 기본값에 가까운 값」을 「콘솔 기본 7일 · API·CLI 기본 1일」로. 보기 넷이 전부 1 에서 시작하므로 정답은 그대로 유일하다 |
| E2 | Y13 트리거 유형 | 보고는 「두 트리거(구성 변경 · 주기)」로 적었지만 공식 표는 **셋**이다 — Configuration changes / Periodic / **Hybrid**("Some rules have both configuration change and periodic triggers"). 세 유형으로 적었다 |
| E3 | R4 의 bias | 보고는 「Traffic Flow 전용은 지도뿐」을 **재확인하지 않았다**고 남겼다. `routing-policy-geoproximity.html` 을 직접 재서 확정했고(`Traffic Flow` 3건이 전부 콘솔 전환 공지와 "The maps are available only with Traffic Flow"), 용어 표의 「bias 는 Traffic Flow 에서만 사용한다」도 함께 고쳤다 |
| E4 | R6 md | 보고 4자리(:84·:191·:207·:245) + **:91 원리 블록**(「두 단계를 명시적으로 수행해야」) · **:206 함정 본문** = 6자리 |
| E5 | Y3 md | 보고 3자리(:174·:183·:279) + **:181 원리 질문**(「왜 … Lambda 를 통해 구현될까요」) · **:184**(「AWS 가 제공하는 Lambda 템플릿이 있어 … 통합」) · **:251** = `soa-t4-3.md` 5자리 |
| E6 | Y17 md | 보고 2자리(:80·:113, 원리 :84) + **:82 원리 질문**(「왜 삭제할 수 없을까요」) = 4자리(:80·:82·:84·:113), 문항은 `W1`·`W2` 까지 |
| E7 | Y10 | 보고가 괄호로만 적은 `soa-t3-4.md:147` 의 이분법(「EC2 상태 점검 **또는** ELB 상태 점검」)을 다섯 소스로 |
| E8 | Y5 md | 보고 2자리(:197·:293) + **시험 포인트**(「ALB/API GW 는 같은 리전」) = 3자리 |
| E9 | Y12 권한 경계 | 보고 수정안은 「사용자 ARN 에 직접 준 권한은 묶이지 않는다」까지만 적었다. 같은 페이지가 바로 다음 문장에서 **"Resource-based policies that grant permissions to an IAM role ARN are limited by an implicit deny in a permissions boundary"** 를 적으므로 **역할 ARN 은 제한받는다**를 함께 적었다(빼면 반대 방향 과잉 일반화가 된다) |
| E10 | Y19 | 워밍업 `W1` 을 고친 `soa-t2-1-q7` 에 워밍업 페이지를, 「엔드포인트 이름 유지」를 단정하는 `soa-t2-2-q14` 에 장애 조치 페이지를 추가(보고 표에 없던 두 쌍) |
| E11 | **교차 자격증 정합 — Macie** (`soa-t4-2.md:94`) | 형제 세션(fix-saa) 인계 메모가 짚은 자리를 **직접 재서** 닫았다 — `what-is-macie.html`: "discovers sensitive data by using machine learning **and pattern matching**". 「S3 객체 머신러닝 분류」 → 「머신러닝과 패턴 매칭으로 분류」 |
| E12 | **교차 자격증 정합 — RDS 마그네틱** (`soa-t1-5.md:155`) | 같은 경로 — `CHAP_Storage.html`: "Amazon RDS has deprecated magnetic storage. You can no longer create new DB instances using magnetic storage, and Amazon RDS has migrated existing magnetic storage volumes to gp3." 「…·마그네틱 중 선택」이 **이제 거짓**이라 선택지에서 빼고 상태를 적었다 |

### 측정에서 얻은 것 (다음 배치용)

- ⚠️ **`grep -o ".{N}문구.{M}"` 은 줄바꿈 때문에 0건을 돌려준다.** 1단계가 인용한 문구 6개 중 3개가 처음에 0건이었고 전부 추출 아티팩트였다(공백을 접은 텍스트에 정규식으로 다시 재니 전부 실재). fix-saa 메모가 같은 함정을 두 번 적었다.
- ⚠️ **보고의 인용문이 원문과 한 낱말 다를 수 있다** — `Concepts.MultiAZ.Failover.html` 은 "automatically changes the **Domain Name System (DNS)** record" 라 「changes the DNS record」로는 0건이다. 사실은 맞다.
- ⚠️ **공식 내부 어긋남 1건(신규)** — ACM `managed-renewal.html` 은 **내보낸(exported)** 인증서도 ELIGIBLE 로 적는데 `dns-renewal-validation.html` 의 갱신 조건은 "currently in use by an AWS service" 하나다. `soa-t4-3-q12` 는 **인용 페이지(후자)의 조건**으로 적었고 적격 목록 페이지를 출처에 함께 달았다. 개수·전수 목록은 단정하지 않았다.
- ⚠️ `py - <<EOF` 를 습관적으로 붙였다가 **두 번** REPL 로 떨어졌다(계약 §2 가 경고한 그대로). 히어독으로 만든 Python 문자열의 `\\$` 도 한 단계 벗겨졌다 — 결과는 가드 소스의 실제 줄을 grep 해 확인했다.

---

## 4. flip 준비 상태

해당 없음 — SOA 300문항은 이미 전부 공개다. 이 배치는 **라이브 핫픽스**이고 `verified` 는 치환 범위에 넣지 않아 원본 값이 그대로 남아 있다(300문항 전수 비교로 확인).

---

## 5. 컨트롤러 요청

- [ ] **`test/soa_facts_test.dart` 의 `expected` 맵** — `soa-t1-5` · `soa-t4-2` · `soa-t4-3` · `soa-t5-4` 를 `'2026-11-17'` 로(`soa-t2-4` 는 `2026-10-20` 그대로 — 손대지 않았다). 지금 이 테스트가 `soa-t1-5` 에서 레드다.
- [ ] **`test/soa_v11_topics_test.dart` 의 `changed` 맵** — `soa-t1-2` · `soa-t1-5` · `soa-t3-4` · `soa-t4-2` · `soa-t5-2` 를 `'2026-11-17'` 로(`soa-t1-1` 2026-11-01 · `soa-t1-4` 2026-11-07 · `soa-t2-4`·`soa-t3-1`·`soa-t4-1` 2026-10-20 은 그대로). 지금 `soa-t1-2` 에서 레드다.
  - 참고: 고정 맵에 없는 문서도 프런트매터 날짜를 올렸다 — `soa-t1-3`·`soa-t3-3`·`soa-t5-3`(2026-06-12 → 11-17) · `soa-t2-1`·`soa-t2-3`·`soa-t3-2`·`soa-t5-1`·`soa-t5-4`(2026-11-06 → 11-17).
- [ ] **`test/soa_dea_question_propagation_test.dart` 의 DEA 트립와이어** — `dea_v2_fix_test.dart`(DEA 세션 산출물)를 등록 목록에 넣어야 그린이 된다. SOA 변경과 무관하다.
- [ ] **`CLAUDE.md` 기준선** — `soa_v2_fix_test.dart` **+49건**.
- [ ] (선택) `soa_dea_question_propagation_test` 의 `_factRules` 에 「개인 키가 ACM 외부」·「쿼리 결과에 직접 경보를 거는 방식이 아닙」·「연동 삭제가 불가」 추가 — **필수는 아니다**: 새 가드가 md 20편 + 문항 20파일을 **함께** 전수로 쓸고 있다. `source_url_retired_test` 등재 요청은 **없다**(죽은 URL 0건 — `working_with_metrics.html` 은 살아 있고 문항 출처에서만 뺐다).
- [ ] **교차 자격증: `dea-t2-1.md`** :234 · :263 · :391 이 「Performance Insights **종료 날짜는 공식 문서에서 확인되지 않았습니다**」라고 적는다 — 이제 `AmazonCloudWatch/latest/monitoring/Database-Insights.html`(`200 r=0`)이 **2026-07-31** 을 글자 그대로 적는다(§1 R2 원문). 자리 3개, grep 실측.
- [ ] **교차 자격증: `saa-t3-5.md`** :266 · :268 · :271 · :512 가 Performance Insights 를 **상태 없이** 현행 도구로 가르친다(`Database Insights` 0건). 자리 4개, grep 실측.
- [ ] **교차 자격증: `saa-t1-4.md:375`** 「Secrets Manager 의 **Lambda 기반 교체 메커니즘**」 — Y3 과 같은 서술. 자리 1개.
- [ ] **사람 승인이 필요한 것(전부 라이브라 이 세션이 집행하지 않았다)**:
  - **Y18 중복 8묶음 · 20문항**(D1~D8)의 문항 교체 — 1단계 보고 §2 Y18 표가 묶음·소유 skill 제안을 담고 있다.
  - **§4-1 커버리지** — 태그 기준 미커버 skill 12개(재태깅 7 + 진짜 공백 4 + md 에만 있는 1) · v1.1 신규 주제 문항 0. `skill` 필드를 바꾸는 일이라 이 배치의 「`skill` 불변」 단정 밖이다.
- [ ] 정답 인덱스 변경이 필요한 문항: **없음**.

---

## 남긴 것 (다음 배치가 집행)

| 항목 | 상태 | 메모 |
|---|---|---|
| 🟢 **G1** 길이 단서 | **179문항** 남음 | 가장 큰 배치. SCS 선례대로 오답을 같은 정밀도로 올린다. 이 배치가 정답 보기를 손댄 8문항의 길이(실측, 자): **늘어남** `soa-t1-5-q13` 31→41 · `soa-t4-3-q12` 30→45 · `soa-t5-3-q11` 60→70 · `soa-t5-2-q15` 64→69 / **줄어듦** `soa-t4-3-q13` 63→49(이제 최장 오답 53자보다 짧다) · `soa-t4-2-q3` 45→39 · `soa-t5-1-q14` 38→36 / 같음 `soa-t3-3-q8` 51. 사실을 고치느라 늘어난 넷은 G1 이 먼저 맞출 자리다(전체 신호는 181 → 179) |
| 🟢 G6 | 그대로 둠 | 보고도 「또는 그대로 둔다」. 레포 불변식은 「한 문항 안에서 `MB/s`·`MiB/s` 가 섞이지 않는다」뿐이고 `GB`/`GiB` 표기 통일은 하지 않는다 |
| 🟡 **Y19 잔여 3문항** | 대체 출처 **미특정** | `soa-t3-2-q12`(롤링의 혼합 버전·롤백 느림) · `soa-t5-3-q15`(Global Accelerator TCP/UDP) · `soa-t5-4-q12`(진단 순서 — 2026-10-29 감사 A7). 그 사실을 적는 공식 페이지를 찾지 못했다. 보고의 대안(「지문을 좁힌다」)은 지문 재작성이라 손대지 않았다 |
| §6-1 고해상도 경보 주기 | 미집행 | 공식 두 페이지가 「10·30초」↔「10·20·30초」로 갈린다. `soa-t1-1-q3` 해설·`soa-t1-1.md` 는 전자와 일치하고 거짓이 아니다. 개수를 걷는 수정은 `soa-t1-1` 날짜 고정(`soa_v11_topics_test`)을 또 건드리므로 묶어서 처리할 것 |
| §6-3 확인되지 않음 | 2건 닫음 · 3건 남음 | 닫음: DX 「수 주」(Y14) · 로컬 경로 「삭제 불가」(Y17). 남음: 위 Y19 잔여 둘 + ElastiCache Memcached 「복제 없음」(`soa-t1-5.md` 표 — 이 세션도 공식 본문을 열지 않았다) |
| `soa-t1-1.md` 프런트매터의 `working_with_metrics.html` | 그대로 | 문항 출처에서는 뺐지만 md 는 「지표 작업」 일반 출처로 두었다(본문을 고치지 않아 날짜 고정 문서를 건드리지 않으려는 것) |
| Y1 참고의 Incident Manager 메모 | 미집행 | 보고가 「선택」으로 적었다 |

## NEEDS_CONTEXT

없다.
