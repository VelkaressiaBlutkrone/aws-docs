# SOA 2단계 보정 — 2026-11-17

> 집행 대상: `docs/audits/2026-11-17-full-verify/soa.md`(1단계 보고). 범위: `flutter_app/assets/content/soa/`(md 20편 · 문항 300개, 전부 라이브).
> 방법: 보고 항목마다 **공식 문서를 다시 내려받아**(`curl -sL`, 태그 제거 후 `\s+` 정규화 — 줄바꿈을 넘는 문장을 놓치지 않게) 인용문 실재를 확인한 뒤 채택·기각·범위 확장을 판정했다. 「없다」 판정은 같은 추출에서 **알려진 양성 대조군**을 먼저 통과시켰다.
> ⚠️ **계약 파일이 이 브랜치에 없었다.** `01-PHASE2-CONTRACT.md` 는 커밋 `8884494`(브랜치 `content/phase2-fix-2026-11-17`)에만 있어 `git show` 로 읽었다(읽기 전용).
> ⚠️ 공유 노트의 이전 `fix-soa-handover.md` 는 **데이터로** 읽었다(공식 인용 두 줄을 얻었고 둘 다 다시 쟀다). 그 세션의 산출물(위 브랜치의 `soa-phase2.md`·가드)은 **열지 않았다** — 아래 판정은 전부 이 세션이 다시 잰 것이다.

## 0. 요약

- **채택 25 / 범위 확장 3 / 부분 채택 2 / 기각 4 / 미집행(남김) 5** — 1단계 보고의 🔴 6 · 🟡 19 · 🟢 8 대비.
  - 🔴 6건 **전부 채택**(공개 문항 3 + 라이브 학습문서 3).
  - 🟡 19건: 채택 13 · 범위 확장 3(Y3·Y6·Y15) · 부분 채택 2(Y9·Y19) · 미집행 1(Y18 — 사람 승인 영역).
  - 🟢 8건: 채택 5(G2·G3·G4·G7·G8) · 미집행 3(G1·G5·G6).
  - 그 밖: §6-1(고해상도 경보 주기) 채택 · 교차 자격증 메모 2건(Macie·RDS 마그네틱) 채택 · 기각 4건(§2 참조).
- 손댄 파일: **md 15편 · 문항 18파일(72문항) · 가드 1**. diff `33 files changed, 350 insertions(+), 203 deletions(-)`.
- **정답 인덱스 변경: 0건.** `git diff -U0 | grep '"verified"'` **0줄** · `correct`·`skill`·`difficulty`·`id` 변경 0줄(패치 스크립트가 쓰기 전에 300문항 전수로 단정했다).
- 새 가드 `flutter_app/test/soa_v2_fix_test.dart`: **53건**. `flutter analyze` 0건.
  - 적용 전 **6 통과 · 47 실패**(대조군 6건만 통과) → 적용 후 **53 통과**.
  - 민감도: 문구 5곳(문항 2파일 · md 3편)을 임시로 옛 문구로 되돌리니 **겨냥한 5건이 정확히 레드**, 복구 뒤 **sha256 5/5 일치** · diff stat 불변(`git stash` 를 쓰지 않았다).
- `flutter test test/soa_*`(11파일): **349 통과 · 3 실패** — 3건 전부 공유 파일 쪽이고 예상된 것이다(§5).
- `prescreen`: 구조·정합성 플래그 0건 유지 · length-cue 181 → **180** · meta-phrasing 1 → **0** · authoring-memo 0 · Task 내 중복 후보 0쌍.
- 새로 넣은 URL **60개 전부 `200 r=0`**(적용 뒤 캐시 없이 다시 쟀다). 대조군: 있는 가이드의 틀린 슬러그 `200 r=1` · 없는 가이드 접두사 `404 r=0`.
- 남긴 것(다음 배치): **Y18 중복 8묶음** · **§4-1 커버리지·재태깅** · **G1 길이 단서 180문항** · G5 · G6 · `soa-t5-4-q12` 지문(§4).

## 1. 채택 — 무엇을 어떻게 고쳤는가

### 🔴 공개 문항 3건

| 항목 | 공식 근거(이 세션 실측) | 수정 |
|---|---|---|
| **R1** `soa-t1-2-q3` — 정답이 둘 | `monitoring/Alarm-On-Logs.html`: "You can create CloudWatch alarms that monitor your log data in two ways: **Log Alarm approach** — … runs a CloudWatch Logs Insights query on a schedule and evaluates the aggregated results directly against a threshold. **Metric filter approach** — …" · `alarm-log.html`: "Unlike metric alarms that require metric filters as an intermediate step, Log Alarms evaluate directly on log data" | 오답 보기 [2]를 **명백히 거짓**인 보기(보존 기간을 줄이면 로그 그룹이 알린다)로 교체 · `W2` 재작성 · 해설에 두 경로 병기 · 출처 추가. **정답 0 불변.** md §3과 자가 점검에 Log Alarm 한 줄씩 |
| **R2** `soa-t1-5-q13` — 정답이 수명 끝난 제품 | `monitoring/Database-Insights.html`: "AWS announced that the end-of-life date for Performance Insights was July 31, 2026, and has migrated Performance Insights users to Database Insights." · `USER_PerfInsights.html` 제목이 "Monitoring DB load with Amazon CloudWatch Database Insights on Amazon RDS" | 정답 보기를 「CloudWatch Database Insights(구 성능 개선 도우미·Performance Insights)」로(가이드 Task 1.3 문구가 옛 이름이라 **지우지 않고 병기**) · 해설에 상태 · 출처 제목 교정 + 추가. md 6자리 병기 + 상태 메모 1줄 |
| **R3** `soa-t4-3-q11` — 해설의 이유가 거짓 | `import-certificate.html`: "ACM does not provide managed renewal for imported certificates. To renew … obtain a new certificate from your certificate issuer and then manually reimport it" · `import-certificate-prerequisites.html`: "You must provide the private key" | 해설을 공식 서술로 교체(키의 위치는 이유가 아니다). md 원리 블록 3줄 |

### 🔴 라이브 학습문서 3편

| 항목 | 공식 근거 | 수정 |
|---|---|---|
| **R4** `soa-t5-3.md` | `routing-policy.html` 이 정책 **여덟**을 싣고(IP-based 포함) "You can use geoproximity routing to create records in a private hosted zone." · `routing-policy-geoproximity.html`: "The maps are available only with Traffic Flow." | 「7종」 4자리에서 **개수 단정을 걷고** 표·체크리스트·시험 포인트에 **IP 기반 라우팅** 추가(용례는 `routing-policy-ipbased.html` 의 "route end users from certain ISPs to specific endpoints") · 「Traffic Flow 에서만」 4자리를 「레코드 생성 시 고르는 정책, Traffic Flow 전용은 **지도**」로(SAA 가 쓴 방향과 같다) |
| **R5** `soa-t4-2.md` + `q12` 해설 | `trusted-advisor-check-reference.html`: "Check categories: Cost optimization, Performance, Security, Fault tolerance, Service limits, **Operational Excellence**" | 「5범주」 3자리 → 개수 없이 여섯을 열거 · 표에 운영 우수성 행(예시 셋은 `operational-excellence-checks.html` 의 점검 이름) · `q12` 해설. **정답 3 불변**(「소스 코드 품질」) |
| **R6** `soa-t3-2.md` + `q1` | `deregister-ami.html`: "When deregistering an AMI, you can optionally delete its associated snapshots at the same time. However, if a snapshot is associated with multiple AMIs, it won't be deleted even if specified" | 「연동 삭제 불가」 단정 1자리 + 불완전 서술 3자리 정정 · `q1` 지문에 「스냅샷 삭제 옵션 없이」(정답 보기가 참이 되게) · 해설. **정답 0 불변** |

### 🟡 내용

| 항목 | 판정 근거(공식 원문) | 수정 |
|---|---|---|
| **Y1** CloudTrail Lake | `cloudtrail-lake.html`: "will no longer be open to new customers starting May 31, 2026 … Existing customers can continue to use the service as normal." | `soa-t1-3-q6` 해설 + md §4 상태 1줄(가르치는 층만 — `soa-t4-2-q4`·`soa-t1-3-q15` 는 오답 층이라 제외) |
| **Y2** Security Hub CSPM | `what-is-securityhub.html`: "Security Hub CSPM processes finding data using the AWS Security Finding Format (ASFF)" (본문 `Security Hub CSPM` 90건) | `q4`·`q5` 해설 병기 · `q4` 출처 제목 · md §2 이름 메모·용어 표·참고자료 제목. 가이드 문구(「AWS Security Hub」)는 그대로 |
| **Y4** ACM 갱신 조건 | `dns-renewal-validation.html`: "The certificate is currently in use by an AWS service. All required ACM-provided DNS CNAME records … are present" | `soa-t4-3-q12` 정답 보기·해설에 두 조건 · 출처 `managed-renewal.html` 추가 · md 1자리 |
| **Y5** API Gateway 인증서 리전 | `how-to-edge-optimized-custom-domain-name.html`(us-east-1 8건) · 리전형은 `apigateway-regional-api-custom-domain-create.html`: "This certificate must be in the same Region as your API." | `soa-t4-3-q10`·`soa-t5-3-q13` 해설 · 출처 추가 · md 표(행 추가)·시험 포인트·자가 점검 |
| **Y7** 패치 그룹 태그 키 | `patch-manager-tag-a-patch-group.html`: "the tag key must be Patch Group or PatchGroup. PatchGroup (without a space) is required if you have allowed tags in EC2 instance metadata" · `patch-manager-patch-groups.html`: "not used in patching operations that are based on patch policies" | `soa-t3-3-q8` 정답 보기·해설 · `soa-t3-2-q10` 정답 보기·해설 · 출처 추가 · md 7자리 |
| **Y8** 유예 기간 기본값 | `health-check-grace-period.html`: "In the console, by default … 300 seconds … Its default value is 0 seconds when you create an Auto Scaling group using the AWS CLI or an SDK." | `soa-t2-1-q11` 해설 · md 1자리 |
| **Y10** ELB 배타 서술 어형 잔여 | `ec2-auto-scaling-health-checks.html` 의 다섯 소스 | `soa-t2-1.md` 1자리(「통해서만」) · `soa-t3-4.md` 4자리(「상태 점검」). 새 가드에 두 어형을 보는 탐지기를 뒀다 |
| **Y11** REJECT 잔여 | `flow-log-records.html`: "not allowed by the security groups or network ACLs, or packets arrived after the connection was closed" | `soa-t5-4.md` 2자리 — 같은 문서 §3과 일치시켰다 |
| **Y12** 오답 근거 3건 | `access_policies_boundaries.html`: "resource-based policies that grant permissions to an IAM user ARN … are not limited by an implicit deny in an identity-based policy or permissions boundary" · Alias: "you can't set the time to live (TTL)" · 워밍업 페이지에 상태 확인 보류 서술 없음(`health check` 1건은 인스턴스 새로 고침 문맥) | `soa-t4-1-q6` `W2`(+출처) · `soa-t5-3-q4` `W2`(회피형 반박 → 사실) · `soa-t2-1-q7` `W1` + md 1자리 |
| **Y13** Config 트리거 | `evaluate-config_components.html`: Configuration changes / Periodic / **Hybrid** | `soa-t4-2-q3` 정답 보기에서 「다음 평가 주기에 반드시」를 걷고 해설에 트리거 유형 · md 1자리. ⚠️ 지문 전제 자체는 손대지 않았다(재작성은 사람 승인) |
| **Y14** DX 「수 주」 | VPN 은 `SetUpVPNConnections.html` "It might take a few minutes to create the VPN connection" 로 확인. **DX 수치는 찾지 못했다** | `soa-t5-2-q15` 정답 보기·해설에서 수치를 걷었다(「물리 회선 구축이 필요」) · md 1자리. 오답 보기 [3]의 「수 주」는 거짓 서술이라 그대로 |
| **Y16** 프라이빗 DNS 요건 | `hosted-zone-private-considerations.html`(두 속성) · `privatelink/create-interface-endpoint.html`: "To use private DNS, you must enable DNS hostnames and DNS resolution for your VPC." | `soa-t5-1.md` 1자리 |
| **Y17** 로컬 경로 | `subnet-route-tables.html`: "This route is added by default to all route tables. … You can replace or restore the target of each local route as needed." 「삭제할 수 없다」는 다시 재도 **0건**(같은 페이지의 "can't delete" 1건은 **메인 라우팅 테이블** 이야기다) | `soa-t5-1-q14` 정답 보기·해설·`W2` · **오답 보기 [2]도 교체**(「삭제하면 차단」은 참·거짓을 확인할 수 없어 명백히 거짓인 「퍼블릭 서브넷 테이블에만 포함」으로) · 출처 교체 · md 5자리. **정답 0 불변** |
| **§6-1** 고해상도 경보 주기 | `cloudwatch_concepts.html`: "10 seconds or 30 seconds" ↔ `alarm-evaluation.html`: "10 seconds, 20 seconds, or 30 seconds"(공식 내부 어긋남) | 개수를 못박지 않는 표현(「60초 미만(예: 10초·30초)」)으로 — `soa-t1-1-q3` 해설 · md 2자리 |

### 🟢 · 교차 자격증 메모

- **G2** `soa-t5-4-q5` 지문의 메타 문구 제거 · **G3** 「콜드오프」 → 「쿨링오프」(`vault-lock.html`: "the cooling-off period ("grace time")") md 3 + 문항 1 · **G4** `soa-t2-3-q6` 지문 「EBS 스냅샷과 AMI」 · **G7** 「고대수」 오자 · **G8** gp2 문장 분리(`general-purpose.html`: "gp2 volumes smaller than 1 TiB … can burst to 3,000 IOPS" · "reached at 5,334 GiB").
- **Macie**(`fix-saa` 메모): `what-is-macie.html` "machine learning and pattern matching" 2건 → `soa-t4-2.md` 표 1자리.
- **RDS 마그네틱**(`fix-saa` 메모): `CHAP_Storage.html` "Amazon RDS has deprecated magnetic storage. You can no longer create new DB instances using magnetic storage" → `soa-t1-5.md` 1자리.

## 2. 기각·부분 채택 — 왜 고치지 않았는가

| 항목 | 보고의 주장 | 이 세션 실측 | 처리 |
|---|---|---|---|
| **Y9** `soa-t2-1-q5` | 「14일은 분석 창의 상한이지 권장 하한이 아니다」 | 같은 페이지가 **둘 다** 적는다 — "analyzing metric data from up to the past 14 days" **그리고** "forecasts are more effective if historical data spans two full weeks" | **부분 채택.** 「권장」을 거짓으로 보지 않았다. 틀린 것은 「14일 **이상**」뿐이라 「2주치를 채우면 더 효과적(분석 대상은 최근 최대 14일)」으로 |
| **Y19** `soa-t3-4-q2` | 「이벤트 이름 없음」 | 현재 출처 `eb-event-patterns.html` 본문에 "EC2 Instance State-change Notification" **2건** · "aws.ec2" **3건** | **기각.** 출처가 이미 사실을 담는다(가드에 기록) |
| **Y19** `soa-t2-1-q4` | 「예측 조정 요건 없음」 | 이 문항은 요건(24시간)을 단정하지 않는다 — 단정하는 것은 「예측 + 동적 조정 병용」이고 현재 출처 허브에 "dynamic scaling" 2건 · forecast 4건 | **기각.** 요건을 단정하는 `q5` 만 교체했다 |
| **Y19** `soa-t2-2-q5`·`q13` 의 대체 URL | `reliability-pillar/rel_fault_isolation_multiaz_region_system.html` | `200 r=0` 이지만 본문 머리에 **"This whitepaper is for historical reference only and will be deprecated in the future."** | **제안 URL 기각.** `q5` 는 `AWSEC2/…/using-regions-availability-zones.html`("By launching EC2 instances in multiple Availability Zones, you can protect your applications from the failure of a single location"), `q13` 은 `Concepts.MultiAZSingleStandby.html` 을 **추가**했다(기존 `framework/reliability.html` 은 공유 가드가 정본으로 묶어 남겼다) |
| **§5** ElastiCache Memcached 「복제 없음」 | 미확인 후보 | `AmazonElastiCache/…/SelectEngine.html` 비교 표: "High availability (replication) — **No**(Memcached) / Yes / Yes" | **기각.** md 표가 그 표와 일치한다 |

- 교차 메모의 「CloudWatch Logs IA → Essentials(soa 1파일)」: SOA 에서 걸리는 문자열은 **EFS Infrequent Access** 한 줄뿐이다(`soa-t1-5.md`). 로그 클래스 서술은 SOA 에 없다 — 해당 없음.
- **Y19 가운데 보류 1건**: `soa-t5-4-q12`(진단 순서) — 순서를 규정하는 공식 페이지를 찾지 못했고 지문을 바꾸면 보기 네 개를 다시 써야 한다(§4·§5).

## 3. 범위 확장 — 보고가 하한이던 자리

| 항목 | 보고 범위 | 전수 실측 | 더 고친 것 |
|---|---|---|---|
| **Y3** Secrets Manager 「Lambda 기반」 | 문항 1 + md 4자리(`soa-t4-3.md` :174·:183·:279 · `soa-t3-3.md` :207) | 같은 주장이 md **7줄** — `soa-t4-3.md` 「흔한 함정」 원리 줄(:251 「Lambda로 이를 위임」)과 원리 블록의 제목·템플릿 줄(:181·:184)이 목록에 없었다 | 7줄 전부(「AWS 제공 Lambda 템플릿」 → 교체 함수 템플릿, `reference_available-rotation-templates.html`). 근거: `rotating-secrets.html` "Managed rotation doesn't use a Lambda function." `soa-t4-3-q13` 은 정답 보기·해설을 두 형태 기준으로 다시 썼다(**정답 0 불변**) |
| **Y6** CloudFront 무효화 | 문항 1 + md 3자리(:168·:196·:239) | 같은 논리가 md **6자리**(+버전 권장 줄 · 시험 포인트 · 함정 5의 원리 줄) | 6자리 전부. 근거: `PayingForInvalidation.html` "The first 1,000 invalidation paths … are free … A path that includes the * wildcard counts as one path" · `Invalidation.html` "Versioning enables you to control which file a request returns even when the user has a version cached either locally or behind a corporate caching proxy … Versioning is less expensive." `q11` 은 정답 보기·해설·`W1` 을 공식 이유로 다시 썼다(**정답 0 불변**) |
| **Y15** EventBridge Scheduler | 문항 2(`soa-t3-4-q5`·`soa-t1-3-q9`) | 가르치는 층에서 스케줄 규칙을 드는 문항은 **4개**(+`soa-t1-3-q8`·`soa-t3-4-q1`) · `soa-t1-3.md` 에 Scheduler **0건** | 4문항 해설 + `soa-t1-3.md` 시험 포인트 + `soa-t3-4.md` 자가 점검. ⚠️ 「Custom Event Bus」 재구성은 넣지 않았다(거짓 서술이 아니고 새 주제 저작이다 — 남김) |

- **Y19 출처**: 보고 47문항 → **44문항 채택 · 2 기각 · 1 보류**(§2). 교체냐 추가냐는 **옛 출처 페이지를 같은 문구로 다시 재서** 정했다 — 사실이 0건이면 교체, 일부를 담으면 추가. 보고가 「미특정」으로 둔 두 건은 찾아 채웠다: `soa-t3-2-q12`(롤링의 절충) → `AmazonECS/…/update-bluegreen-to-rolling.html`("Rolling deployments typically use fewer resources … make rollbacks more complex") + `whitepapers/…/overview-deployment-options/rolling-deployments.html`, `soa-t5-3-q15` → `global-accelerator/…/introduction-components.html`("A listener can be configured for TCP, UDP, or both").
- ⚠️ 보고 인용 1개는 문자 그대로 검색하면 0건이었다 — "automatically changes the DNS record" 는 원문이 "automatically changes the **Domain Name System (DNS)** record" 다(사실은 실재한다. `Concepts.MultiAZ.Failover.html`).

## 4. flip 준비 상태

SOA 는 300문항 전부 공개 상태라 flip 대상이 없다. 대신 **사람 승인이 필요해 집행하지 않은 것**을 적는다.

| 남긴 것 | 왜 |
|---|---|
| **Y18** 교차 Task 중복 8묶음(20문항) | 한쪽을 다른 축으로 돌리려면 **라이브 문항을 새로 쓴다**(1단계 보고도 사람 승인 영역으로 적었다) |
| **§4-1** 가이드 skill 미커버 12개 · 재태깅 7개 | `skill` 은 보존 필드다. 재태깅 + 신규 문항 뒤에 커버리지 가드를 세우는 순서가 맞다 |
| `soa-t5-4-q12` 지문 | 진단 순서를 규정하는 공식 페이지를 찾지 못했다. 「가장 가까운 통제 계층은?」으로 좁히면 보기 넷을 다시 써야 한다 |
| `soa-t4-2-q3` 지문 전제 | 정답 보기·해설은 고쳤지만 「설계된 이유」를 묻는 틀 자체는 저작자의 설명이다 |
| **G1** length-cue 180문항 | 가장 큰 배치. 이 배치는 손댄 보기에서 길이를 늘리지 않게만 했다 |
| **G5** `soa-t2-4-q10` 오답 [2] 이중 부정 | 고치면 `soa_p1_review_fix_test` 의 Multi-AZ 한정 규칙(「동기 복제」 문맥)과 맞물린다 — 그 가드를 먼저 세어야 한다 |
| **G6** `soa-t1-5-q6` GB/GiB 혼용 | 보고도 「그대로 둔다」를 허용했다. `MB/s` 표기는 손대지 않았다 |
| Y15 「Custom Event Bus」 · Y1 Incident Manager 메모 | 거짓이 아니라 최신성 보강이다 |

## 5. 컨트롤러 요청

- [ ] **`test/soa_facts_test.dart` 날짜 맵**(:150~156) — `soa-t1-5`·`soa-t4-2`·`soa-t4-3`·`soa-t5-4` → `2026-11-17`. (`soa-t2-4` 는 손대지 않았다 — `2026-10-20` 유지.)
- [ ] **`test/soa_v11_topics_test.dart` `changed` 맵**(:360~371) — `soa-t1-1`·`soa-t1-2`·`soa-t1-5`·`soa-t3-4`·`soa-t4-2`·`soa-t5-2` → `2026-11-17`. (`soa-t1-4`·`soa-t2-4`·`soa-t3-1`·`soa-t4-1` 은 md 를 손대지 않았다.)
  - 날짜를 올린 md 는 15편이다: 위 8편 + 고정 맵에 없는 `soa-t1-3`·`soa-t2-1`·`soa-t2-3`·`soa-t3-2`·`soa-t3-3`·`soa-t5-1`·`soa-t5-3`.
- [ ] **`test/soa_dea_question_propagation_test.dart`** — 지금 레드 1건은 **`dea_v2_fix_test.dart` 미등록 트립와이어**다(SOA 쪽 원인이 아니다. 트립와이어는 `dea_*` 만 본다). SOA `_factRules` 에 옮길 후보(선택 — 새 가드가 md·문항을 이미 전수로 쓴다): 「개인 키가 ACM 외부」 · 「연동 삭제」 · 「직접 경보를 거는 방식이 아닙」, `_nameRules` 후보 「콜드오프」.
- [ ] **`CLAUDE.md` 기준선 +53**(`soa_v2_fix_test.dart`).
- [ ] `test/source_url_retired_test.dart` — **등재 요청 없음.** 이번에 걷은 출처는 죽은 URL 이 아니라 「그 사실을 담지 않는」 살아 있는 페이지다. 그 파일이 든 URL 122개를 수정 전후로 세어 **감소 0건**임을 확인했다(공유 테스트는 돌리지 않고 정적으로 대조했다).
- [ ] **교차 자격증**(grep 실측 · 다른 세션이 고치는 중일 수 있어 2026-11-17 작업 트리 기준):
  - `saa-t3-5.md` — `Performance Insights` 5자리 · `Database Insights` **0건**(R2 와 같은 결함).
  - ⚠️ **DEA 교차 메모의 「PI 종료 날짜를 적는 공식 페이지가 지금은 없다」는 틀렸다** — `AmazonCloudWatch/latest/monitoring/Database-Insights.html`(`200 r=0`)이 "end-of-life date for Performance Insights was July 31, 2026" 을 적는다(이 세션 재측정 1건). 날짜를 걷은 자격증이 있으면 되돌릴 근거다.
  - `saa-t1-4.md:375` — 「Secrets Manager의 Lambda 기반 교체 메커니즘」(Y3).
  - `saa-t1-5.md:221`·`:228` · `saa-t1-5.questions.json:198` — API Gateway 를 한정 없이 「같은 리전」(Y5). `dva-t2-2.md:70` 은 이미 「Regional API Gateway」다.
  - `saa-t3-8.md:283`·`:427`·`:458` · `saa-t3-8.questions.json:119`·`:121`·`:148` — Direct Connect 「수 주」(Y14 — 공식 수치를 찾지 못했다).
  - `saa-t3-7` 의 Geoproximity 는 이미 고쳐져 있다(요청 없음).
- [ ] **정답 인덱스 변경이 필요한 문항: 없음.**
- [ ] **사람 승인 요청**: §4 의 Y18 · §4-1 · `soa-t5-4-q12` · `soa-t4-2-q3`.
- [ ] `01-PHASE2-CONTRACT.md` 가 `content/phase2-fable-2026-11-17` 에 없다 — 합칠 때 함께 넣을지 판단 필요.

## 부록 — 측정에서 배운 것

- **보고의 영문 인용을 그대로 검색하면 약어 풀이 때문에 0건이 난다**("DNS record" ↔ "Domain Name System (DNS) record"). 대조군을 같은 페이지에서 통과시킨 뒤 표현을 바꿔 다시 쟀다.
- **낱말을 금지하는 탐지기는 정정문을 건다.** 「완전 자동」을 낱말로 걸었더니 「완전히 자동으로 이뤄지는 **조건**은?」이라는 지문 자신이 걸렸다 — 무조건 단정의 **형태**(「DNS 검증이면 … 완전 자동」)로 좁히고 그 가름을 대조군으로 고정했다.
- **제안 URL 이 `200 r=0` 이어도 본문 머리의 배너를 본다**(`reliability-pillar/` 판의 "historical reference only").
- 문항 JSON 20파일은 `json.dumps(ensure_ascii=False, indent=2)` + CRLF + 끝 개행으로 **바이트 단위 재현**됐다(대조군 통과 뒤 필드 단위 편집 — `verified` 는 타이핑하지 않았다).
