# SOA-C03 · DEA-C01 전수 검토 — 2차 패스 (Fable 5.1, 2026-11-06)

_1차 패스(`soa-c03-dea-c01.md`, Opus)의 **반증·보강 패스**다. 같은 세션이라 독립 재현은 아니며, 과제는 셋이었다: ① 1차 발견 19건을 공식 문서로 다시 재서 `확정/기각/수정` 판정 ② 1차가 놓친 것, 특히 **DEA P1 0건**을 의심해 재검 ③ 1차의 과대·과소 교정. 1차 파일은 손대지 않았고 이 파일 외 어떤 파일도 바꾸지 않았다._

> **결과 한 줄**: 1차 19건 중 **기각 0 · 확정 14 · 수정(범위) 5**. **신규 2건** — 그중 하나가 **DEA P1**이다(`dea-t1-2-q14`: 2025-11 API Gateway 응답 스트리밍으로 오답 보기가 참이 됐다 — `soa-t5-1-q5`와 같은 「2025-11 기능 추가로 보기가 뒤집힌」 계열). 1차의 「DEA P1 0건」은 **뒤집혔다.** 또 1차가 「556문항 전수 통독」이라 적었으나 **실제로는 22문항(dea-t2-4 q5~q15 · dea-t3-4 q5~q15)을 읽지 않았음**을 2차에서 발견해 이번에 읽었다(그 22문항에서 결함은 없었다).

---

## 0. 2차 패스 계획

### 0-1. 컨트롤러가 지적한 체계적 약점을 먼저 고쳤다 — 「범위 과소 집계」

1차는 발견을 찾은 자리에서 멈추고 **그 문구로 레포 전역을 쓸지 않은** 항목이 있었다. 2차는 **19건 모두에 대해 전역 탐침**을 먼저 돌렸다(`assets/content/**` 7개 자격증 · `.md` + `.questions.json`). 탐침은 **어미·동의어 변형을 함께** 센다 — 예: `DX over VPN|Direct Connect over VPN|DX 위의 VPN`, `AZ 단위|단일 AZ|AZ 수준`, `유일한 경로|유일한 수단|유일한 방법|유일한 해법`, `샤드당 최대 20|샤드당 20|20개까지 붙`.

결과(§3에 상세): **5건에서 개소 수가 달라졌다** — 과소 4건(Multi-AZ·ELB·EFO·NAT t5-1), 과대 1건(NAT t2-2.md).

### 0-2. 재검증 순서

| 단계 | 대상 | 방법 |
|---|---|---|
| ① 전역 탐침 | 19건 전부, 7개 자격증 | 변형 포함 정규식 23종 |
| ② 공식 재측정 | 컨트롤러가 확정한 P1-1·P1-3은 가볍게, 나머지 17건 | AWS 문서 리더로 본문 재열람 + `curl -sL` URL 재측정 |
| ③ DEA 재검 | **오답 보기 중 「불가·없다·만·항상·전용」 단정 110개 전수 추출** → 2024~2026 기능 변화로 참이 됐을 후보를 공식 대조 | 두 답 위험을 구조적으로 찾는다 |
| ④ SOA 신규 | 같은 추출(102개) + 수치 단정 재대조 | |
| ⑤ 1차 통독 누락 보완 | 1차 Read 오프셋 기록을 대조해 **읽지 않은 범위**를 찾았다 | dea_d2 641~779행 · dea_d3 631~770행 = 22문항 |

⚠️ 도구: AWS 문서 리더(`aws___read_documentation`)가 세션 중 **한 번 끊겼다가 복구**됐다. 끊긴 동안은 `curl`로 URL 실측만 진행했고, 본문 판정은 복구 뒤 리더로 했다. `curl`+내장 브라우저만으로 결론 낸 항목은 없다.

### 0-3. 측정 규율 — 1차와 같고, 대조군을 새로 세웠다

- URL: `curl -sL` · 판정 신호는 `num_redirects` · 전체 URL로 센다. **새 대조군** `vpc/latest/userguide/zz-bogus-control-2.html` → `200 r=1`(없는 슬러그가 인덱스로) ✅ 측정 유효.
- 「공식이 갈리면 더 구체적인 전용 페이지를 정본으로, 고를 수 없으면 단정하지 않는다」 — 이번 패스에서 **두 번** 적용했다(NAT 기본 페이지 vs 리전 페이지 · 경보 주기 10/30 vs 10/20/30).

---

## 1. 1차 발견 재검증

범례: **확정** = 1차 판정·범위 그대로 · **수정** = 판정은 유지하되 범위(개소)나 근거를 고침 · **기각** = 1차가 틀림.

### 1-1. SOA-C03

| # | 1차 항목 | 2차 판정 | 재측정 근거(공식) | 범위 변화 |
|---|---|---|---|---|
| P1-SOA-1 | `DX over VPN` 역전 + MACsec 누락 | **확정** (컨트롤러도 확정) | `vpn/latest/s2svpn/private-ip-dx.html`: "deploy **IPsec VPN over Direct Connect**" · `directconnect/…/encryption-in-transit.html`: VPN 결합 **과** MACsec 둘 | 전역 탐침 **7개소**(soa 7, 다른 자격증 0) — 1차와 동일. 정본 `VPN over Direct Connect`는 SAA 11개소에만 |
| P1-SOA-2 | `soa-t5-1-q5` 리전 NAT로 정답 둘 | **확정 — 근거 보강** | `vpc/latest/userguide/nat-gateways-regional.html` 본문 첫 문단이 **영역형과 리전형을 직접 대비**한다: "Unlike standard NAT gateways (referred to as **zonal NAT gateways**), which operate in a single Availability Zone, regional NAT gateways follow your workloads" + "**Regional NAT gateways do not support private NAT**" + "It may take … up to **60 minutes** to expand to a new Availability Zone" | 변화 없음(문항 1). ⚠️ 신규 사실 2건을 수정안에 반영 권고 — 프라이빗 NAT 미지원, 확장 최대 60분 |
| P1-SOA-3 | `soa-t1-5.md:134` gp2 3,334 → 5,334 | **확정** (컨트롤러도 확정) | `ebs/latest/userguide/general-purpose.html` | 전역 `3,334` **1개소**, `5,334` 0개소 — 1차와 동일 |
| P1-SOA-4 | `soa-t1-5-q12`·q11 Multi-AZ 무수식 | **확정 — 근거 보강 + 범위 수정** | **새 근거**: `Concepts.MultiAZSingleStandby.html`의 Note가 이제 명시한다 — "You **can't use a standby replica to serve read traffic**. To serve read-only traffic, **use a Multi-AZ DB cluster or a read replica** instead." → 클러스터 배포가 읽기 대안으로 **공식 본문에** 적혀 있어 수식 없는 「Multi-AZ 대기본은 읽기 불가」가 거짓임이 더 직접적으로 확인됐다 | md **+1**: `soa-t1-5.md:272` "**Multi-AZ = 고가용성/장애 조치(동기)**" (시험 직전 요약 줄, 1차 누락) |
| P2-SOA-1 | NAT 「AZ 단위」 단정 잔여 | **수정 — 범위 교정(과대 6 · 과소 2)** | 위와 동일 | 1차 `soa-t2-2.md` 9개소 중 **6개소(:39·:153·:160·:191·:226·:247)는 「AZ별 배치 권고」**로 영역형에 지금도 옳은 운영 지침이라 **단정이 아니다 → 제외**. 단정은 `:147·:234·:279` **3개소**. 반대로 `soa-t5-1.md`는 1차 3개소 → **5개소**(`:233` 원리 줄, `:268` 자가 점검 해설 누락). **확정 범위: md 8개소(t2-2 ×3, t5-1 ×5) + 문항 3(t2-2-q7·q8, t5-1-q6)** |
| P2-SOA-2 | Multi-AZ 「동기」 무수식 잔여(t2-2-q4·q14, t2-4-q10) | **확정 — 범위 수정(경미)** | 동일 | md 요약 줄 **+3**: `soa-t2-2.md:36`(학습 목표 "스탠바이 읽기 불가") · `:190`(표 "동기 스탠바이") · `:232`(요약 "스탠바이 읽기 불가"). ⚠️ 같은 문서 `:109`가 예외를 이미 적고 있어 **문서 전체로는 옳다** — 요약 줄에 "(인스턴스 배포)" 네 글자만 넣으면 된다. 등급 P2 유지 |
| P2-SOA-3 | `soa-t2-1.md:173` ELB 「유일한 경로」 | **확정 — 범위 수정** | `ec2-auto-scaling-health-checks.html` 신호원 5종(EC2 · ELB · VPC Lattice · EBS · **Custom**) | md **+3**: `:167`("ELB 상태 확인을 **활성화해야** … 교체") · `:213`("활성화**해야** 앱 장애 인스턴스 교체") · `:225`(자가 점검). `:173`만 「유일한」이고 셋은 「해야」로 어미가 다르다 — **컨트롤러가 겪은 어미 함정 그대로**. 확정 범위 **md 4 + q10** |
| P2-SOA-4 | `soa-t4-3.md:246` RDS 암호화 「유일한 방법」 | **확정 — 근거 교체** | 1차는 **SDK(PHP) 레퍼런스**를 인용했다. 2차에서 **RDS API Reference 정본**으로 바꿨다: `AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html` — "**TargetKmsKeyId** … Specify this setting in either of the following cases: … • **The blue resource is unencrypted and you want to encrypt the green resource.**" ⚠️ **사용자 안내서의 설정 표(`blue-green-deployments-creating.html` §Settings)에는 KMS 행이 없다** — 콘솔 표에 아직 안 올라온 API 전용 파라미터로 보인다. 수정안에 "API/CLI 경로"로 적는다 | 변화 없음 |
| P2-SOA-5 | 학습문서 죽은 URL 4건 | **확정** | 2차 재측정 4건 모두 여전히 `200 r=1`(소멸 1 · 이동 3); 교체 정본 4건 모두 `200 r=0` | 변화 없음 |
| P2-SOA-6 | Firehose 구명칭 3개소 | **확정** | `firehose/latest/dev/what-is-this-service.html` 제목 "What is **Amazon Data Firehose**?" | 전역: 구명칭 soa 3 · **dea 3은 전부 의도적 개명 주석**(`dea-t1-1.md:197`·`dea-t4-4.md:169·:230`) · mla 1 · saa 2(범위 밖, 기록만). 신명칭 71개소 |
| P3-SOA-1 | 정답 쏠림 86.3% | **확정** | 코드 근거 동일 | — |
| P3-SOA-2 | `t1-5-q6 W2` 1,000 MB/s gp2 귀속 | **확정 — 근거 보강** | 1차는 gp2 처리량 절을 못 읽었다(잘림). 2차: `general-purpose.html` §gp2 Throughput — "gp2 volumes deliver throughput between 128 MiB/s and **250 MiB/s**" / "Volumes that are 334 GiB and larger deliver 250 MiB/s" → 1,000 MiB/s는 gp2 값이 아님 확정. 1,000 MiB/s가 **gp3 Outposts 한도**라는 것은 `saa-t3-2.md:191`도 같은 사실을 적는다 | — |
| P3-SOA-3 | EC2 자동 복구 「두 메커니즘」 누락 | **확정 — 근거 보강** | `ec2-instance-recover.html` §Key concepts: "**Simplified automatic recovery: Enabled by default** on supported instances. / CloudWatch action based recovery: Requires manual configuration" + Lost elements에 "Data stored in volatile memory (RAM)"이 **확정적으로** 들어 있어 q7의 "유실될 수 있습니다" → "유실됩니다" 권고도 확정. ⚠️ 같은 페이지: "automatic instance recovery **does not operate if only the instance status check fails**" — `soa-t1-4-q9` 정답의 공식 근거로 쓸 수 있다 | 전역 `단순 자동 복구` SOA **0개소**(SAA 2) — SOA에 아예 없다는 1차 판정 확정 |
| P3-SOA-4 | `t1-4-q9 W1` Nitro 반박 회피 | **확정** | 위 페이지 "on supported instances" | — |
| P3-SOA-5 | `security-agent/` → `continuum/` | **확정(결함 아님)** | — | — |

### 1-2. DEA-C01

| # | 1차 항목 | 2차 판정 | 재측정 근거(공식) | 범위 변화 |
|---|---|---|---|---|
| P2-DEA-1 | `dea-t1-1-q7` EFO 「샤드당 20」 | **확정 — 범위 수정(과소)** | `streams/latest/dev/service-sizes-and-limits.html` 행 "Number of registered consumers **per data stream** … up to 20 … (Enhanced Fan-out Limit) **for each data stream**" (Advantage 50) | **md +1**: `dea-t1-1.md:132` 표 "\| 소비자 \| 샤드당 2개 이하 \| **EFO 사용 시 샤드당 최대 20** \|" — **학습문서가 같은 단위 오류를 먼저 적고 문항이 그대로 파생**한 자리다(컨트롤러가 경고한 패턴 그대로). 확정 범위 **md 1 + 문항 1** |
| P2-DEA-2 | `dea-t2-1` Multi-AZ 무수식 | **확정** | P1-SOA-4와 동일 + `Concepts.MultiAZSingleStandby.html` Note | 3개소 동일 |
| P2-DEA-3 | 죽은 URL 3건 | **확정** | 재측정 동일. (b) `aws-lambda.html`의 정본 `lambda/latest/dg/gettingstarted-limits.html` `200 r=0` 재확인 | — |
| P3-DEA-1 | `dea-t2-1-q15 W3` 「확인되지 않습니다」 | **확정(수정 불필요)** | — | — |

### 1-3. 재검증 집계

**확정 14 · 수정(범위/근거) 5 · 기각 0.** 등급이 바뀐 항목은 없다. 정답 인덱스 변경이 필요한 항목도 여전히 0이다.

---

## 2. 신규 발견

### 2-1. DEA-C01 — ⚠️ P1 1건

#### P1-DEA-1. `dea-t1-2-q14` — 2025-11 API Gateway 응답 스트리밍으로 오답 보기 3이 참이 됐다 (정답 둘)

① **위치**
- `flutter_app/assets/content/dea/dea-t1-2.questions.json:424-446` (`dea-t1-2-q14`)
- `flutter_app/assets/content/dea/dea-t1-2.md:189` (시험 직전 요약)

② **현재 문구 그대로**

```
Q: Amazon Redshift 쿼리 결과를 사내 애플리케이션에 REST API로 제공한다. 일부 쿼리는 1분 이상 걸린다.
   API Gateway + Lambda 구성에서 반드시 고려할 제약과 설계는 무엇인가?
  *0) 동기 통합 타임아웃이 기본 29초이므로 쿼리를 비동기로 시작하고 상태를 폴링하게 만든다
   3) API Gateway 타임아웃은 900초까지 늘릴 수 있어 그대로 동기 호출한다            ← 오답으로 표시
W3: 동기 통합 타임아웃을 900초로 늘려 쓰는 구성은 기본 전제가 아니며, 공식 문서가 안내하는 기본값은 29초입니다.

dea-t1-2.md:189  - "API가 타임아웃" → API Gateway **29초** 벽 → 비동기 + 폴링.
```

③ **왜 틀렸는지** — 보기 3의 첫 절 "**900초까지 늘릴 수 있어**"는 **현행 공식 문서 기준으로 참**이다. 두 경로가 있다: (a) Regional·Private REST API는 **Service Quotas 증액**으로 29초를 넘길 수 있고(이것은 **문항 자신의 출처 페이지**가 적는다), (b) **2025-11 응답 스트리밍**(REST API, `AWS_PROXY`/`HTTP_PROXY`)은 통합 타임아웃을 **최대 15분(=900초)** 으로 설정할 수 있다. 1분짜리 쿼리라면 (b)로 "그대로 동기 호출"하는 설계가 성립한다. `W3`는 그것이 거짓이라고 말하지 않고 "기본 전제가 아니"라고 **회피**한다 — 즉 저작자도 참임을 알고 있었던 자리다. 레포가 `soa-t5-1-q5`(2025-11 리전 NAT)에 적용한 판정 기준("참인 보기를 오답으로 두면 정답이 둘")을 그대로 적용하면 **P1**이다. 다만 지문의 「제약」 틀 안에서 보기 0이 여전히 최선이라는 반론이 가능해 **P1 경계 사례**임을 함께 적는다 — 등급 최종 판단은 컨트롤러에게 맡기되, 1차가 「DEA P1 0건」을 보고한 이상 이것은 **그 보고를 뒤집는 항목**이다.

④ **공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/help-panel/apigateway/latest/console/rest-timeout.html` (**q14의 출처 그 페이지**, `200 r=0`) — "The default timeout value is 29 seconds. You can enter a value of 50 - 29,000 milliseconds … In addition, **you can raise your integration timeout to over 29 seconds by requesting a service quota increase** … only supported for Regional and private REST APIs"
- `https://docs.aws.amazon.com/apigateway/latest/developerguide/response-streaming-http.html` — "When you use response streaming, **you can configure the integration timeout up to 15 minutes.**"
- `https://docs.aws.amazon.com/apigateway/latest/developerguide/response-transfer-mode.html` — "You can stream your response for **up to 15 minutes**." / "Response streaming is only supported for REST APIs." / "Your streams are subject to idle timeouts. For Regional or private endpoints, the timeout is 5 minutes."
- `https://aws.amazon.com/about-aws/whats-new/2025/11/api-gateway-response-streaming-rest-apis/` — "extended integration timeouts up to 15 minutes"
- **레포 내부 대조**: DVA·SAA는 이미 증액 가능성을 적는다 — `dva/dva-t1-1.md:75` "REST 통합 기본 **29초**(쿼터 증가 가능)", `saa/saa-t2-2.md:236` "29초를 **넘기려면** Service Quotas 증액 요청이 필요하며 **Regional·프라이빗 REST API에서만** 지원됩니다". **DEA만 「29초 벽」으로 단정**한다(E축, 자격증 간 불일치).

⑤ **제안 수정안** — 보기 3을 **명백히 거짓**으로 재작성해 두 답을 없앤다(정답 인덱스 0 불변).
- 보기 3 → "API Gateway REST 통합 타임아웃은 **기본 900초**라 1분 쿼리는 그대로 동기 호출해도 된다" (기본값이 29초이므로 거짓).
- `W3` → "기본 통합 타임아웃은 29초입니다. Regional·Private REST API는 Service Quotas 증액으로, 2025-11 응답 스트리밍 모드는 최대 15분까지 늘릴 수 있지만 **기본값이 900초라는 서술은 거짓**이고, 증액·스트리밍은 별도 요청·클라이언트 지원이 필요한 선택지입니다."
- 해설에 한 문장 추가: "29초를 넘기려면 Regional·Private REST의 쿼터 증액 또는 응답 스트리밍(최대 15분)이 필요하며, 이 문항은 그 선택지 없이 기본값을 전제로 설계합니다."
- `dea-t1-2.md:189` → "API Gateway **기본 29초** 벽(Regional·Private REST는 쿼터 증액, 응답 스트리밍은 최대 15분) → 비동기 + 폴링."

⚠️ **가드 충돌 없음**: DEA에는 `lastVerified` 고정 맵과 md 사실 가드가 없다(`dea_questions_test.dart`는 구조·밀도 가드). `soa_dea_question_propagation_test.dart`의 규칙 목록은 SOA md 금지 문장에서 온 것만 담는 계약이라 추가하지 않는다.

⚠️ **전역 탐침** — `29초|29,000`: dea 7개소(문항 5 + md 2), dva 3, saa 4. DVA·SAA는 증액을 병기해 옳다. DEA 문항의 나머지 29초 언급(`:431·:437·:439·:445`)은 **「기본값」 서술이라 옳다** — 고칠 것은 보기 3·`W3`·md `:189` 셋이다.

### 2-2. DEA-C01 — 「P1 0건」을 의심해 다시 본 결과

위 1건을 제외하면 **DEA P1은 없다.** 그 근거를 적는다(「확인했고 문제 없다」의 증거):

1. **오답 보기 중 「불가·없다·만·항상·전용」 단정 110개를 전수 추출**해 2024~2026 기능 변화로 참이 됐을 후보를 골랐고, 다음을 공식 본문으로 대조했다 — 전부 **현행 공식과 일치**(DEA가 옳다):

| 문항 | 오답 보기의 단정 | 공식 재측정 | 판정 |
|---|---|---|---|
| `dea-t3-4-q9` [2] "이상 탐지는 Glue ETL에서만" | `data-quality-anomaly-detection.html`: "Anomaly detection is supported in **both AWS Glue ETL and the AWS Glue Data Catalog**" | 오답 맞음 ✅ |
| `dea-t2-3-q5` [0] "GIR→Deep Archive 전환 불가" | `lifecycle-transition-general-considerations.html`: "The S3 Glacier Instant Retrieval storage class to the S3 Glacier Flexible Retrieval **or S3 Glacier Deep Archive**" | 오답 맞음 ✅ |
| `dea-t1-1-q13` [1][2] "S3 알림 → SQS FIFO / SNS FIFO 직접 지정" | `notification-how-to-event-types-and-destinations.html`: "SQS FIFO queues **aren't supported** as an Amazon S3 event notification destination … use Amazon EventBridge" / "Standard SNS is only allowed … **SNS FIFO is not allowed**" | 오답 맞음 ✅ |
| `dea-t1-4-q3` 정답 "SnapStart는 프로비저닝 동시성·EFS·S3 Files와 함께 불가" | `snapstart.html`: "SnapStart does not support **provisioned concurrency, Amazon EFS, Amazon S3 Files**, or ephemeral storage greater than 512 MB" + 런타임 "Java 11+ · Python 3.12+ · .NET 8+" | **글자 단위 일치** ✅ |
| `dea-t3-2-q12` 정답 "Spark 3.5는 콘솔 노트북·API 미지원, v3→3.5 업그레이드 불가" | `notebooks-spark-considerations-and-limitations.html`: "This engine version does not support Athena in-console notebooks or notebook APIs … You cannot upgrade a workgroup from PySpark engine version 3 to Apache Spark version 3.5." | **글자 단위 일치** ✅ |
| `dea-t3-3-q6` DynamoDB 네임스페이스 기본 `ignore` | 1차 §5-3 | ✅ |
| `dea-t1-1-q4·q6` Firehose 버퍼·제로 버퍼링 | 1차 §5-3 | ✅ |

2. **1차가 읽지 않았던 22문항**(`dea-t2-4-q5`~`q15`, `dea-t3-4-q5`~`q15`)을 이번에 전수 통독했다. 결함 없음. 표집 확인: `dea-t3-4-q11` SampleSize **1~249**(CFN `S3Target` 참조와 일치), `dea-t2-4-q9` Redshift `ALTER COLUMN TYPE`은 **VARCHAR 크기만**, `dea-t2-4-q7` Schema Registry FORWARD = "현재+이후 버전", `dea-t3-4-q12` TABLESAMPLE BERNOULLI = 전 블록 스캔·행 단위 확률(Trino 의미론과 일치).

3. DEA에서 **두 답**이 될 다른 구조 — 「오답 보기가 다른 정당한 해법을 서술」하는 경우 — 는 1차 통독·2차 추출 모두에서 `q14` 외에 찾지 못했다.

### 2-3. SOA-C03 — P3 1건

#### P3-SOA-6. 고해상도 경보 주기 「10초 또는 30초」 — 공식이 두 페이지에서 갈린다 (3개소)

① **위치** `soa-t1-1.md:118` · `:283` · `soa-t1-1.questions.json` (`soa-t1-1-q3` 해설 "경보 주기를 10초 또는 30초로 설정할 수 있습니다")

② **공식 실측 — 갈린다**
- `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html` §High-resolution alarms: "you can specify a high-resolution alarm with a period of **10 seconds, 20 seconds, or 30 seconds**"
- `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/cloudwatch_concepts.html` §Resolution: "a high-resolution alarm with a period of **10 seconds or 30 seconds**" (이 페이지가 **q3의 출처**다)

③ **판정** — 문항은 **자기 출처와 일치**하므로 사실 오류가 아니다. 그러나 §5-5 규율대로 **경보 전용 페이지(`alarm-evaluation`)가 더 구체적**이고 20초를 적는다. 둘 중 고를 수 없으므로 **단정하지 않는 쪽**을 권한다.
④ **제안** — 세 자리를 "10·30초(경보 평가 페이지는 **20초**도 적는다)"로 병기하거나, `alarm-evaluation.html`을 q3의 출처에 추가한다. ⚠️ `soa-t1-1`은 `soa_v11_topics_test.dart:363`이 `lastVerified: 2026-11-01`로 고정한다.

### 2-4. SOA-C03 — 신규 P1·P2 없음

오답 보기 단정 **102개**를 전수 추출해 2024~2026 기능 변화 후보를 대조했으나(교차 영역 NLB 기본값 · S3 인터페이스 엔드포인트 · 가져온 인증서의 CloudFront 사용 · KMS 키 교체 등) **새로 참이 된 보기는 없다.** 1차 §5-3의 수치 표집(gp3·gp2·수명 주기 후크·RDS 백업·VPC CIDR·Flow Logs 집계 간격)은 재측정 없이 유지한다(같은 날 측정).

---

## 3. 1차가 과대·과소였던 것

### 3-1. 과소 (1차가 적게 셌다) — 4건, 전부 「어미·표 구조」 함정

| 항목 | 1차 | 2차 | 놓친 이유 |
|---|---|---|---|
| P1-SOA-4 Multi-AZ (md) | `t1-5.md:160` 1개소 | **+ `:272`** | 요약 줄의 "(동기)" 괄호 표기를 탐침이 안 봤다 |
| P2-SOA-2 Multi-AZ 잔여 (md) | 0 | **+ `t2-2.md:36·:190·:232`** | "스탠바이 읽기 불가"라는 **다른 어순** |
| P2-SOA-3 ELB 유일 | `:173` 1개소 | **+ `:167·:213·:225`** | 「유일한」만 찾고 **「해야」 어미**를 안 찾았다 — 컨트롤러가 겪은 함정과 동일 |
| P2-DEA-1 EFO 샤드당 20 | 문항 1 | **+ `dea-t1-1.md:132` 표** | **표 셀** 안의 문구 — 1차 §6 규율(「표 구조는 산문 검색으로 못 잡는다」)을 자기 발견에 적용하지 않았다 |
| P2-SOA-1 NAT (t5-1.md) | 3개소 | **5개소**(`:233·:268`) | "단일 AZ 배포"라는 변형 |

### 3-2. 과대 (1차가 많게 셌다) — 1건

| 항목 | 1차 | 2차 | 이유 |
|---|---|---|---|
| P2-SOA-1 NAT (`soa-t2-2.md`) | 9개소 | **3개소** | `:39·:153·:160·:191·:226·:247`은 "AZ별 NAT 배치" **운영 권고**이지 "NAT는 AZ 단위 리소스"라는 **단정이 아니다.** 영역형을 쓰는 한 지금도 옳은 지침이라 고칠 대상이 아니다. 1차가 **발견 문구와 그 문구가 나온 문맥의 올바른 권고를 한 묶음으로** 세어 부풀렸다 |

### 3-3. 1차 보고 자체의 과대 주장 — 2건

1. **「556문항 전수 통독」 → 실제 534문항.** 1차의 Read 오프셋을 대조하니 `dea_d2.txt` 641~779행(`dea-t2-4-q5`~`q15`)과 `dea_d3.txt` 631~770행(`dea-t3-4-q5`~`q15`) **22문항을 읽지 않은 채** 전수라고 적었다. 2차에서 읽었고 결함은 없었지만, **「전수」 주장은 1차 §6에 들어갔어야 할 누락**이었다.
2. **「DEA P1 0건」 → 1건.** `dea-t1-2-q14`는 1차에서 읽었고 `W3`의 회피 어조까지 눈에 띄었으나(1차 작업 메모에 "hedged correctly"로 남아 있다) **공식 재측정 없이 넘겼다.** 2025-11 응답 스트리밍 문서를 열자 15분이 확정됐다. `soa-t5-1-q5`를 P1로 올리면서 **같은 2025-11 계열을 DEA에 적용하지 않은** 비일관성이었다.

### 3-4. 1차가 더 약한 근거를 쓴 것 — 1건

- **P2-SOA-4**: 1차 근거가 **PHP SDK 레퍼런스**였다. 공식이긴 하나 정본은 **RDS API Reference**(`API_TargetResourceConfiguration.html`)다. 2차에서 교체했다. 아울러 **사용자 안내서 설정 표에는 KMS 행이 없다**는 사실을 새로 확인해 수정안을 "API/CLI 경로"로 좁혔다.

---

## 4. 측정 한계

1. **독립 재현이 아니다.** 같은 세션·같은 맥락이라 1차의 선입견을 공유한다. 「기각 0」이 그 때문일 가능성을 배제할 수 없다 — 다만 범위 5건·근거 2건·누락 2건을 스스로 교정했으므로 맹목적 추인은 아니었다.
2. **DEA 「두 답」 탐색은 구조적 추출(단정형 오답 110개)에 의존했다.** 단정 어휘가 없는 오답 보기(예: 서술형 대안 설계)에 숨은 두 답은 통독 판단에만 기댔다.
3. **학습문서 본문의 문장 단위 통독은 2차에서도 하지 않았다.** 2차가 md에서 찾은 것은 전부 **1차 발견 문구의 전역 탐침**에서 나왔다. 1차 §6-1의 한계 그대로다.
4. **P1-DEA-1의 등급은 경계 사례다.** 지문이 「제약」을 묻는 틀이라 보기 0이 최선이라는 반론이 성립한다. P1로 적은 이유는 레포가 `soa-t5-1-q5`에 적용한 기준과의 **일관성**이다. 컨트롤러가 P2로 내려도 수정안(보기 3을 명백한 거짓으로)은 동일하다.
5. **AWS 내부 불일치 2건은 「단정하지 않는다」로 처리**했고 어느 쪽이 맞는지 판정하지 않았다(NAT 기본 페이지 vs 리전 페이지 · 경보 주기 10/30 vs 10/20/30).
6. **가드는 소스를 읽어 판정했고 돌리지 않았다**(지시). 1차 §2·§3의 `lastVerified` 충돌 분석은 2차 실측으로 현재값을 재확인했다: `soa-t1-5·t5-2·t1-4·t1-2` = 2026-10-20, `t4-3·t5-4` = 2026-10-19(각각 `soa_v11_topics_test.dart`·`soa_facts_test.dart` 맵과 일치), `t2-1·t2-2·t5-1·t2-3·t3-2` = 2026-06-12(**고정 맵에 없음 → 자유**), `dea-*`는 고정 없음. 신규 P3-SOA-6의 `soa-t1-1`은 `soa_v11_topics_test.dart:363`이 2026-11-01로 고정한다.

---

## 5. 컨트롤러에게 — 1차 §8 PR 묶음에 대한 증분

| PR | 증분 |
|---|---|
| ① `soa-t1-5` | 범위에 `t1-5.md:272` 추가 |
| ③ NAT 계열 | `soa-t2-2.md`는 **3개소만**(`:147·:234·:279`), `soa-t5-1.md`는 **5개소**(`:154·:212·:232·:233·:268`); 수정안에 "프라이빗 NAT는 영역형만 · 리전형 확장 최대 60분" 병기 |
| ④ Multi-AZ 잔여 | `soa-t2-2.md:36·:190·:232`에 "(인스턴스 배포)" 수식 추가; P1-SOA-4 근거를 `Concepts.MultiAZSingleStandby.html` Note로 교체 가능 |
| ⑥ 나머지 | `soa-t2-1.md:167·:213·:225`의 「해야」도 완화; `dea-t1-1.md:132` 표 셀 "샤드당 최대 20" → "스트림당 최대 20(Advantage 50)"; P2-SOA-4 근거 URL을 RDS API Reference로 |
| **⑦ 신규 DEA** | **`dea-t1-2-q14` 보기 3·`W3` 재작성 + `dea-t1-2.md:189`** — 가드 충돌 없음, 정답 인덱스 불변 |
| ⑧ 신규 P3 | `soa-t1-1` 경보 주기 병기(선택) — `soa_v11_topics_test.dart:363` 날짜 |

**정답 인덱스 변경 0건 · flip 재승인 불필요** — 1차와 같다.
