# SAA 2단계 보정 — 2026-11-17

> 집행 대상: `docs/audits/2026-11-17-full-verify/saa.md`(1단계 보고). 계약: `01-PHASE2-CONTRACT.md`.
> 이 세션은 **커밋·브랜치 전환·stash 를 하지 않았다.** 손댄 것은 `flutter_app/assets/content/saa/**` 와
> 새 가드 `flutter_app/test/saa_v2_fix_test.dart` 하나, 그리고 이 보고서다.
> 항목마다 공식 문서를 `curl -sL` 로 다시 받아(전부 `200 r=0`) 본문에서 인용문을 재확인한 뒤 판정했다.

## 0. 요약

- **채택 27 / 기각 3 / 범위 확장 6** — 1단계 보고의 🔴 5 · 🟡 20 · 🟢 12 대비.
  - 🔴 **5/5 채택**(R1~R5) — 공개 문항 4 + 라이브 학습문서 1.
  - 🟡 **18/20 집행**: 내용 계열 Y1~Y17 **전부 채택** · Y18 은 ✔ 34문항 집행(◐ 6 · — 50 은 남김) · Y19 채택 · **Y20 은 공유 파일이라 컨트롤러 요청**.
  - 🟢 **2건 채택으로 격상**(G7·G12 — 🟢 로 적혔지만 실측하니 R1~R3 과 같은 「md 가드 금지 문구의 문항 쪽 어형 탈출」이었다) · G6 기각 · 나머지는 남김.
- 손댄 파일: **md 12편 · 문항 22파일(61문항 — 본문 28 · 출처만 33) · 가드 1**.
- **정답 인덱스 변경: 0건.** 360문항 전수를 `git show HEAD:` 와 대조해 `correct`·`verified`·`difficulty`·`skill` 불변을 기계로 확인했다(변경 61문항 · 그 넷이 바뀐 문항 0).
- 새 가드 테스트 수: **44건**(`saa_v2_fix_test.dart`). `flutter analyze` 0건.
- 민감도: saa 콘텐츠 34파일만 HEAD 바이트로 임시 교체 → 새 가드 **44건 중 38건 레드**(대조군 6건만 통과) → 복구 후 **34파일 sha256 전부 동일**(`git stash` 미사용).
- 기존 가드: `flutter test test/saa_*`(30파일) **1,209건 전부 통과**(기존 1,165 + 신규 44). 기존 가드는 한 줄도 고치지 않았다.
- `prescreen`: 구조·정합성 플래그 0건 유지 · length-cue **149 → 148** · explanation-long **3 → 2**(악화 0 — 내 편집이 만든 새 길이 단서 2건을 쓰기 전에 재서 되돌렸다).
- 남긴 것(다음 배치): Y18 잔여 56문항 · 🟢 G1·G4·G5·G8~G11 · U6 미확보 단정 · §5 컨트롤러 요청.

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 🔴

| ID | 문항·파일 | 정답 | 무엇을 고쳤나 | 공식 근거(이 세션 재확인) |
|---|---|---|---|---|
| R1 | `saa-t2-1-q7` | 1 | `W2` 「재시도가 제한적이어서 메시지를 버릴 수」 → 「5XX·429 를 재시도 대상으로 보고 최대 100,015회·23일 재시도, 구독마다 DLQ. 갈림길은 내구성 버퍼」. 출처 2개 추가 | `sns-message-delivery-retries.html`: AWS managed endpoints 행 "100,015 times, over 23 days" · "all 5XX errors and **429 (too many requests sent)** errors as retryable" · "discards the message—unless a dead-letter queue is attached to the subscription" |
| R2 | `saa-t3-9-q9` | 1 | 해설 둘째 문장을 「지원 수준은 엔진마다 다르다」로 · 지문 「Athena·EMR 쿼리 전체에 일관되게」 → 「Athena SQL 쿼리와 EMR의 Apache Spark 작업에」. 지원 표 출처 추가 | `lake-formation/…/working-with-services.html` 표: Athena SQL = R/W·Read·Read / **Apache Hive on Amazon EMR (EC2) 행·셀 = Not supported** / Hive on EMR Serverless·**EMR on EKS**·Athena Spark = 전부 Not supported |
| R3 | `saa-t4-4-q12` | 2 | 정답 보기·해설·`W1`·`W3` 의 「TGW $0.03/GB($0.01 교차 AZ + $0.02 처리)」를 걷고 갈림길을 **데이터 처리 요금의 유무**로 옮겼다. 기존 가드의 `required`(「송신 측 1 GB 기준」·「양방향」)·출처 조각(`transit-gateway/pricing`) 유지. EKS 문서 출처 추가 | `eks/latest/best-practices/cost-opt-networking.html`: "You are billed on an hourly basis and for data sent to the TGW. **There is no destination cost associated with inter-AZ traffic that flows through the TGW.**" |
| R4 | `saa-t1-3-q8` + `saa-t1-3.md` | 3 | **오답 보기 [1] 을 명백한 거짓으로 교체**(「NAT 게이트웨이는 포트 포워딩을 지원하므로…」 — 공식 표가 그대로 반증) · `W1` 재작성 · 비교표 출처 추가 · md 표(:145)와 흔한 함정 1(:386) 정밀화. 지문·정답 불변 | `vpc-nat-comparison.html` 표: Port forwarding — NAT gateway "**Not supported.**" / NAT instance "Manually customize the configuration to support port forwarding." · Bastion servers — "Not supported." / "Use as a bastion server." · `vpc-nat-gateway.html`: "Connections must always be initiated from within the VPC containing the NAT gateway" |
| R5 | `saa-t3-7.md` 5줄 | — | 표(:110) · 주의(:120) · 요약(:318) · 흔한 함정 5(:339~340)를 「Traffic Flow 전용이 아니고, Traffic Flow 에서만 되는 것은 편향 범위 지도」로 통일(문항 `q6` 해설과 같은 문장). 함정 5 는 전제가 뒤집혀 **인용하는 오해 자체를 바꿨다** | `routing-policy.html`: "You can use geoproximity routing to create records in a private hosted zone." · `routing-policy-geoproximity.html`: "The maps are available only with Traffic Flow." |

- R3 의 오답 [0](「VPC 피어링 $0.03/GB, Transit Gateway $0.01/GB」)은 **일부러 틀린 보기**라 그대로 뒀다. 가드는 「TGW 쪽에 0.03 을 붙이는 산술」만 세고, 그 보기가 남아 있다는 것을 탐지기가 고장 나지 않았다는 대조군으로 쓴다.
- R3 정답 보기는 87 → 78자가 되어 길이 비율이 1.34 → **1.20** 으로 내려갔다(길이 단서 1건 해소).

### 🟡 내용 계열

| ID | 자리 | 정답 | 고친 것 | 공식 근거 |
|---|---|---|---|---|
| Y1 | `saa-t1-2-q9` 해설·`W0` + md :238·:253·:307 | 2 | 예방 제어 = 「SCP·RCP·선언적 정책」. md :253 「IAM API 호출」 → 「금지된 API 작업」(문항 `W0` 와 어긋나던 자리). 출처 추가 | `control-behavior.html`: "implemented using Service Control Policies (SCPs), Resource Control Policies (RCPs), and declarative policies" |
| Y2 | `saa-t1-2-q11` 보기·해설 + md :113 | 1 | 「전 계정 읽기 전용」 → 「감사 역할(읽기 전용)과 관리자 역할(전체 권한) 두 교차 계정 역할」 + 현행 명칭 Config aggregator 계정 병기 | `special-accounts.html`: "auditor (read-only) and administrator (full-access) cross-account roles" · "previous name: the audit account" |
| Y3 | `saa-t1-5-q9` 보기·해설 · `q10` 해설 + md :242·:357 | 1 · 3 | 「머신러닝으로」 → 「머신러닝과 패턴 매칭」. md 원리 블록 제목의 「규칙 기반이 아닌」 전제를 걷음 | `what-is-macie.html`: "machine learning and pattern matching" |
| Y4 | `saa-t2-1-q8` `W2` | 1 | 「처리 보장을 위해 SQS 권장」 → 「처리 속도를 분리하거나 밀린 메시지를 쌓아 둬야 하면 SQS」 | R1 과 같다 |
| Y5 | `saa-t2-5-q11` 해설 + md :182 | 0 | 「쓰기 지연이 체감되지 않는다」 → 「단일 AZ 배포보다 쓰기·커밋 지연이 늘 수 있다」 | `Concepts.MultiAZSingleStandby.html`: "can have increased write and commit latency compared to a Single-AZ deployment" |
| Y6 | 문항 5 + md 11줄(§3) | 2·0·0·2·1 | 「RDS Multi-AZ」의 동기 복제 서술을 「Multi-AZ **DB 인스턴스 배포**」로 한정(한정어만 넣고 문장은 유지). `q11` 은 **지문**에서 한정 | `multi-az-db-clusters-concepts.html`: "a **semisynchronous**, high availability deployment mode … with two readable replica DB instances" · "also serve read traffic" |
| Y7 | `saa-t3-4-q8` 보기·해설 + md :493·:509 | 2 | 「실행 시간 제한이 없다」 → 「Lambda 의 15분 같은 상한이 없다(Fargate 컴퓨팅 환경의 작업은 14일 상한)」. 정답 보기에서는 그 주장을 뺐다(67 → 55자, 길이 비율 1.68 → 1.38). 출처 추가 | `batch/…/job_timeouts.html`: "Jobs that run on Fargate resources can't expect to run for more than 14 days." |
| Y8 | `saa-t3-5-q11` `W0`·해설 | 3 | 「이전 세대 볼륨·평균 약 100 IOPS」 → 「사용 중단 — 새 DB 인스턴스 생성 불가·gp3 이전·2026-07-01 부터 스냅샷 복원 불가」. 해설 gp3 수치에 「임계 용량 미만의 기준」 | `CHAP_Storage.html`: "Amazon RDS has deprecated magnetic storage. You can no longer create new DB instances using magnetic storage" · "when the storage size for gp3 volumes reaches a certain threshold, the baseline storage performance increases" |
| Y9 | `saa-t3-8-q11` `W3` | 0 | 「인터넷을 경유합니다」 → 「퍼블릭 엔드포인트를 쓰고 요금이 붙는다(AWS 네트워크를 벗어나지 않는다)」 | `gateway-endpoints.html`: "it does not leave the AWS network" |
| Y10 | `saa-t1-3-q7` `W2` | 1 | 「Elastic IP가 반드시 필요」 → 「**퍼블릭** NAT 게이트웨이는 필요(프라이빗 NAT 게이트웨이에는 연결 불가)」. 출처를 VPC 소개 → NAT 게이트웨이 페이지로 교체 | `vpc-nat-gateway.html`: "You can't associate an Elastic IP address with a private NAT gateway." |
| Y11 | `saa-t2-3-q15` 보기 [3]·`W3` | 1 | **참이던 오답 보기를 거짓으로 교체**(「인스턴스 수를 직접 지정해야 하며 자동 조정은 지원하지 않는다」) · 회피형 `W3` 를 참·거짓을 말하는 문장으로. 출처 추가 | `elasticbeanstalk/…/using-features.managing.as.html`: "Your AWS Elastic Beanstalk environment includes an Auto Scaling group" |
| Y12 | `saa-t2-4-q1` 보기 [0]·[1]·해설·`W0` + md :97 | 1 | 「완전 무중단」 → 「중단 없이 계속 동작하는 것을 목표」 + 해설에 「일반적으로 구분하는 방식」 | 공식 정의 페이지를 **찾지 못했다**(1단계와 같은 결론) — 그래서 단정을 낮췄고 출처는 그대로 뒀다 |
| Y13 | `saa-t4-3-q8` 해설 + md :193 | 2 | 「최솟값(기본 0.5 ACU)」 → 「설정한 최솟값. 0.5 ACU 는 완전히 유휴일 때 내려갈 수 있는 가장 작은 용량이고 0 ACU 면 자동 일시 정지」. 출처 추가 | `aurora-serverless-v2.setting-capacity.html`: "It's tempting to always choose 0.5 … That value allows the DB instance to scale down to the smallest capacity when it's completely idle" · "a minimum capacity of 0 ACUs" |
| Y14 | `saa-t3-9-q15` 해설·`W3` + md :130 | 2 | ⓐ 해설에 Rekognition 스트리밍 영상 분석의 상태 한 줄(가르치는 층) + md 메모 ⓑ `W3` 에 Python 추가. 상태 페이지 출처 추가 | `rekognition/…/streaming-video.html`: "Streaming Video and Bulk Image Analysis is no longer available to new customers." · `managed-flink/…/what-is.html`: "Java, Scala, Python, or SQL" |
| Y15 | `saa-t4-4-q6` 보기·해설 · `q7` `W3` · `q4` `W2` + md 2줄(§3) | 3·1·1 | 「시간당 ENI 요금」 → 「AZ별 시간 요금」. `q4` 의 「ENI 단위가 아니라」 단정을 걷음. `q6`·md 의 근거 없는 「200개 이상 서비스」 삭제(해설 407 → 390자) | `privatelink/pricing/`: "provisioned in each Availability Zone" 과 "for each endpoint ENI" 가 **함께** 나온다 → 어느 쪽도 부정하지 않게 통일 |
| Y16 | `saa-t2-2.md:365` · `saa-t1-3.md:389` | — | 「지연도 낮습니다」 → 「기능이 최소화돼 있습니다」 · 「반드시 NACL」 → 「서브넷 수준 차단은 NACL(웹 요청은 WAF IP 집합도 가능)」 | 문항 쪽 기존 가드 판정(2026-10-28 · 2026-11-07)을 md 에 전파 |
| Y17 | `saa-t2-5.md:161` | — | ARC readiness check 행에 「신규 고객에게 열려 있지 않음(기존 고객은 계속 사용)」 | `arc-readiness-availability-change.html`: "no longer open to new customers" |

### 🟡 출처 계열

- **Y18 — ✔ 34문항 집행.** 대체 URL 31개(고유)를 이 세션이 다시 재서 **전부 `200 r=0` + 본문 탐침 양성**을 확인한 뒤 반영했다(탐침 결과는 scratchpad `y18_verify_out.txt`; 예: `orgs_manage_policies_scps_evaluation` "explicit Allow statement at every level" 1 · `spot-instance-termination-notices` "two minutes" 3 · `ec2-on-demand-instances` "short-term, irregular workloads that cannot be interrupted" 1 · `cost-allocation-backfill` "twelve months" 1).
  - ⚠️ **교체가 아니라 추가했다**(32개 출처 추가 · 교체는 Y10 의 1건뿐). 이유: ① 기존 가드가 옛 출처 조각을 요구하는 문항이 있다(`saa-t4-5-q14` 의 `cost-optimization-pillar` · `saa-t4-5-q7` 의 `view-idle-recommendations` · `saa-t3-4-q4`·`saa-t3-5-q11` 의 「소개 유지 대조군」) ② 지우면 그 URL 이 업고 있던 사실을 하나씩 다시 세어야 한다. 소개 페이지가 서비스 선택 축을 받치는 것은 2026-11-07 `saa_p3_source_fix_test` 판정과 같다.
  - 문항 목록: `t1-1-q2·q3` · `t1-2-q1·q4·q9` · `t1-3-q7·q9·q10·q13` · `t1-4-q1` · `t2-1-q10` · `t2-2-q2·q15` · `t2-3-q12` · `t3-2-q2` · `t3-3-q2·q8·q10·q13·q14` · `t3-4-q7` · `t3-5-q5`(2개) · `t3-6-q8` · `t3-9-q15` · `t4-1-q9` · `t4-2-q1·q11` · `t4-3-q6`(2개) · `t4-4-q8·q9` · `t4-5-q5·q7·q12·q14`.
- **Y19 — 채택.** 블로그 출처 4건의 제목 「(공식)」 → 「(AWS 아키텍처 블로그 — 공식 문서 아님)」. 네 문항 모두 공식 출처가 함께 달려 있어 블로그 항목은 지우지 않았다.

### 🟢 에서 채택으로 올린 2건

- **G7** `saa-t3-3-q1`(`W2`) · `q2`(해설·`W1`): 「네트워크 강화는 `n`, EBS 최적화는 `b`」 → 「네트워크·EBS 최적화는 `n`, 블록 스토리지 최적화는 `b`」. md 가드(`saa_t2_t4_facts_test:210`)와 전파 규칙(`:302`)이 `'n=네트워크 강화, b=EBS 최적화'` 를 **이미 금지**하고 있었고 문항만 어형으로 비켜 갔다. 공식 `instance-type-names.html`: "n – Network and EBS optimized" · "b – Block storage optimization".
- **G12** `saa-t4-5-q7` 해설 「CloudWatch 지표 14일 이상을 수집」 → 「기본 14일의 조회 기간(lookback) 지표를 분석」. 같은 구조다 — 전파 규칙 `'CloudWatch 지표 14일 이상 수집'`(`:384`)을 「14일 이상**을** 수집」으로 비켜 갔다. 공식 `view-idle-recommendations.html`: "the default lookback period of 14 days". 함께 `saa-t3-5-q12` 출처 **제목**의 「되돌릴 수 없음」을 걷었다(그 페이지에 `irrevers`·`undo`·`revert`·`permanent` 0건 · 대조군 `reboot` 3 · `several minutes` 1).

## 2. 기각 — 왜 고치지 않았는가

1. **G6 `saa-t3-7-q13` 「GLB 는 L3/L4」** — 공식이 둘 다 적는다(1단계 §6 U2: ELB 소개 "third layer" ↔ 기능 비교표 "Layer 3 Gateway + Layer 4 Load Balancing"). 거짓이 아니므로 고치지 않았다. 약칭 통일(`GLB` ↔ `GWLB`)은 표기 문제라 다음 배치로 남긴다.
2. **Y1 의 오답 보기 [0] 「예방적(Preventive) — SCP」** — 짝짓기 문항의 **일부러 틀린 짝**이고 가르치는 층이 아니다. 고치면 보기 네 개의 형식이 깨진다. 가드는 가르치는 층만 세고 그 보기가 남아 있음을 대조군으로 둔다.
3. **Y14 md `:146` 표 셀 「Rekognition 등 분석 서비스」** — 나열 셀이라 상태 메모를 달지 않았다. 같은 문서 `:130`(가르치는 줄)과 문항 해설에 달았다.

보고와 **다르게 집행한** 자리(기각은 아니다):
- R4 — 보고 예시 보기(「NAT 게이트웨이에 인바운드 규칙을 추가하면…」) 대신 **공식 비교표가 글자 그대로 반증하는** 「포트 포워딩을 지원한다」를 썼다. `vpc-nat-gateway.html` 에 `security group` 이 0건이라 「규칙」을 근거로 삼을 수 없었다.
- Y18 — 「교체」 대신 「추가」(§1).
- U6 의 「200개 이상」 — 1단계는 「지우라는 권고가 아니다」라고 했지만 Y15 로 그 문장을 다시 쓰는 김에 걷었다(단가가 아니라 근거 없는 개수다 — 「이미 본문에 있는 **단가**는 건드리지 않는다」 규율과 충돌하지 않는다).

## 3. 범위 확장 — 보고가 하한이던 자리

| 계열 | 보고 | 실측 | 더 고친 자리 |
|---|---|---|---|
| Y6 Multi-AZ 한정 | 문항 3(+2) · md 10(+1) | 문항 **5** · md **11** | 문항 단위 탐지기(「Multi-AZ」 + `(?<!비)(?<!반)동기(?!화)` + 한정어 없음)가 **`saa-t3-5-q14`**(`W1` 「Multi-AZ 스탠바이는 동기 복제를 사용하므로」)를 더 잡았다. `saa-t3-5-q7` 은 「양방향 쓰기를 **동기화**」라 거짓 양성 — 탐지기를 `(?!화)` 로 좁혔다 |
| Y15 ENI 요금 | 문항 3 · md 1 | 문항 3 + `q4` · md **2** | `saa-t1-3.md:235` 「ENI 유지 비용이 발생합니다」가 같은 계열이었다 |
| R4 NAT | md 1줄 | md **2줄** | `:386` 흔한 함정 1 이 「NAT 는 아웃바운드 전용」으로 NAT 인스턴스까지 묶고 있었다 |
| R1 근거 | 100,015회·23일 | + **429 가 재시도 대상** | 옛 `W2` 는 「Lambda 동시성 한도 초과 시」(= 스로틀링)를 짚었는데, 같은 페이지가 "429 (too many requests sent) errors as retryable" 을 적는다 — 그 조건에서도 거짓이다 |
| G7·G12 | 🟢(표현) | 🔴 계열과 같은 기제 | md 가드·전파 규칙이 **이미 금지한 문구**의 어형 탈출이라 채택으로 올렸다 |
| Y18 `saa-t3-5-q5` | 대체 출처 2개 | 2개 모두 누락 | 「HighAvailability 는 이미 달려 있다」고 가정했다가 **새 가드가 잡았다**(달려 있던 것은 `q12` 였다) |

### 측정에서 얻은 것(다음 세션이 같은 곳을 밟지 않도록)

- ⚠️ **0건이 두 번 줄바꿈 아티팩트였다.** R3 의 "destination cost"(앞뒤 160자 문맥을 요구한 `grep -o` 가 줄 끝에서 실패)와 Y5 의 "increased write and commit latency"(HTML 줄바꿈이 `commit\n latency` 로 갈랐다). 둘 다 **대조군(`TGW` 2건 · `latency` 4건)** 이 양성이어서 다시 쟀고 실재했다. 본문 탐침은 **공백을 접은 텍스트에 `\s+` 로** 한다.
- ⚠️ **내 가드가 내 정정문을 잡았다** — `saa-t3-5-q5` 에 더한 출처 제목 「여섯 스토리지 노드에 동기 복제」가 Y6 탐지기에 걸렸다(Aurora 스토리지의 동기 복제는 RDS Multi-AZ 와 다른 사실이다). 가드를 느슨하게 하지 않고 제목을 바꿨다.
- ⚠️ **옛 문구를 인용하는 정정 메모 줄이 탐지기에 걸린다** — `saa-t4-5.md:428` 「"지표 14일 이상 수집"에서 … 고쳤습니다」. 예외를 성질(`> 📝` 로 시작하는 줄)로 좁히고 **그 줄이 정확히 1개**임을 대조군으로 고정했다. R5 의 흔한 함정 인용 줄(`**"…"**`)도 같은 처리다.
- ⚠️ **`verified` 를 넘는 앵커는 헬퍼가 거부한다** — 출처 추가 앵커를 다음 문항의 `"id"` 까지 잡았다가 `"verified"` 가 치환 범위에 들어가 단정이 막았다. 이후 **문항 블록 안에서만** 치환하는 헬퍼(`repq`·`addsrc`)로 바꿨다.

## 4. flip 준비 상태

해당 없음 — SAA 는 360문항 전부 이미 `verified: true`(라이브)다. 이 배치는 **핫픽스**이고 `verified` 값은 한 글자도 타이핑하지 않았다(치환 헬퍼가 `"verified"`·`"correct"` 가 든 새 문자열을 거부한다).

## 5. 컨트롤러 요청

- [ ] **기준선**: `CLAUDE.md` 기준선 줄에 `saa_v2_fix_test.dart` **+44건** 반영.
- [ ] **Y20(공유 파일)**: `flutter_app/assets/exam_guides/SAA-C03.json` 의 4문장을 공식 한국어 전문으로 교체 — 1.2 지식 5번째(`AWS Cognito/GuardDuty/Macie` → `Amazon …`) · 3.4 지식 3번째와 4.4 지식 3번째(`Application Load Balancer` → `Application Load Balancer(ALB)`) · 3.5 지식 1번째(`Amazon QuickSuite` → `Amazon Quick`). SAA 에는 가이드 동기화 가드가 없다(신설 필요). ⚠️ 이 세션은 그 4문장을 **직접 재대조하지 않았다**(파일이 금지 목록이라 손대지 않았고, 1단계 실측을 그대로 넘긴다).
- [ ] **`test/saa_question_propagation_test.dart`**(소유 범위 밖이라 손대지 않았다): ① `_rules` 의 `'**Java·Scala·SQL**'` 은 별표가 들어 있어 평문 문항과 일치할 수 없다 ② `G-1.1-10` 의 why 주석 「35일 유예」는 공식·md·문항의 **14일**과 다르다. 새 가드가 같은 사실을 정규식으로 이미 덮으므로 급하지 않다.
- [ ] **교차 자격증 — SOA**(1단계 §5, 이 세션은 SOA 파일을 열지 않았다 — grep 은 1단계 실측): `soa-t5-3.md:67·133·214` 「Geoproximity 는 Traffic Flow 에서만」 3자리(R5 와 **같은 결함** — SAA 는 「Traffic Flow 전용이 아니고, Traffic Flow 에서만 되는 것은 편향 범위 지도」로 통일했다) · `soa-t4-2.md:90` Macie 「머신러닝 분류」 · `soa-t1-5.md:153` RDS 「마그네틱 중 선택」(공식은 deprecated).
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**
- [ ] **사람 판정으로 넘기는 것**: U4(`saa-t3-9-q11` — 집계표가 「완전 종료」로 싣는 Snowball Edge 가 정답인 문항의 존치) · U8(EventBridge 「새 애플리케이션은 Custom Event Bus」 권고 반영 여부) · G8(`section` 빈 값 360/360) · G4(교차 Task 의미 중복 16쌍 ↔ 빈 주제 20개 교체 — **라이브 문항 교체는 사람 승인 영역**).

## 6. 남긴 것 — 다음 배치

- **Y18 잔여 56문항**: ◐ 6(`t1-4-q3` · `t2-2-q6` · `t2-4-q11` · `t3-1-q6` · `t3-2-q7` · `t3-2-q14`)과 대체 출처가 미검증인 50문항. 정본을 찾아 `200 r=0` + 본문을 확인해야 한다. `saa-t2-4` 의 12문항이 한 페이지(`framework/reliability.html`)에 몰려 있다. ⚠️ `saa-t4-2-q11` 에는 무관한 RI 개요 출처가 그대로 있다(이번엔 맞는 출처를 **더하기만** 했다).
- **U6 미확보 단정**(수치 근거 없음 — 이 배치에서 새로 단정하지도 지우지도 않았다): `t3-2-q9` AD 「(필수)」 · `t3-8-q5` 「수 분/수 주」 · `t4-3-q2` 「소폭 높지만」 · `t4-3.md` RI 「~60%」 3자리 · `t4-4-q8` `W2` · `t4-4-q13` 「약 $0.09/GB」 · `t3-3-q3` · `t4-1-q7` 「20%」 · `t3-3-q6` 「40%」 · `t3-3-q9`·`t4-2-q8` 「90%」 · `t2-2-q12` 「Fargate GPU 미지원」(최신성 위험 — 먼저 확인할 것).
- `saa-t3-5-q12` **본문**의 「승격은 되돌릴 수 없다」 — 제목만 고쳤다. 인용 페이지에 그 표현이 없으므로 본문 근거를 다른 페이지에서 찾아야 한다.
- 🟢: **G1** length-cue 148문항 · **G2** meta-phrasing 3 · **G3** explanation-long 2(`t3-8-q10` 441 · `t3-9-q11` 421) · **G5** md 표현 잔존 5종(Memcached 복제 한정 · Lambda 15분 한정 · 「VPN over DX 를 사용해야」 · Standard-IA 30일 · 자가 점검 논리) · **G9** 전파 가드의 리터럴 구조(위 요청) · **G10** 정답 인덱스 분포(루브릭상 고치지 않는다) · **G11** 닫힌 서비스의 목록 언급 3자리(App Runner · AppRegistry · WAF Classic).
- §4-1 커버리지 빈 주제 20개(문항 교체는 사람 승인).
