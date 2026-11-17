# SOA 전수 검증 — 2026-11-17

> 범위: `flutter_app/assets/content/soa/` 학습문서 **20편** · 문항 **300개(전부 `verified: true` — 라이브)** · 가이드 `flutter_app/assets/exam_guides/SOA-C03.json`(도메인 **5개** · Task 14 · skill 53).
> 이 세션은 콘텐츠·코드·테스트를 **고치지 않았다**. 쓴 파일은 이 보고서 하나다.
> 방법: ① 문항 300개 전문 덤프 통독 + md 20편 통독(꼬리 절 전부 · 「핵심 개념」 본문 전부 · 원리 블록은 단정어가 든 줄 전부) → ② 문항·md 출처 **282개 전수 실측**(`curl -sL`, `num_redirects`·본문 길이) → ③ 문항별 핵심 사실 탐침(인용 페이지 본문에 그 사실이 있는가) → ④ 후보를 공식 문서로 대조(AWS 문서 리더 + `curl -sL` 추출, 대조군 병행) → ⑤ 중복(원형·조사벗김 자카드 44,850쌍) · `prescreen` · 커버리지 · 범위 실측.
> ⚠️ **대조 범위의 한계를 먼저 적는다.** 통독·출처 생사·탐침·중복·prescreen·커버리지는 **전수**다. 공식 본문 대조는 「문항이 단정하는 핵심 사실 1~2개가 인용 페이지에 있는가」를 문항마다 탐침한 것이고, **해설의 모든 문장을 맞댄 것은 아니다.** 탐침이 실패한 문항과 통독에서 의심한 주장만 본문을 열어 끝까지 확인했다.
> 가드가 이미 금지한 문구(`soa_facts_test` · `soa_v11_topics_test` · `soa_dea_question_propagation_test` · `soa_p1/p2/p3_review_fix_test` · `soa_question_facts_test`)는 다시 적지 않았다. 아래는 **그 가드들이 보지 않는 자리**다.

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **6** | 사실이 거짓 · 정답이 둘 · 정답이 틀림 (즉시 수정) — 문항 3 + 학습문서 3 |
| 🟡 | **19** | 불완전·모호·출처가 사실을 담지 않음 (수정 권고) — 내용·잔여 17항목(Y1~Y17) + 중복 1항목(Y18, 8묶음) + 출처 1항목(Y19, 47문항) |
| 🟢 | **8** | 품질(길이 단서·메타 문구·표기) — 사실은 옳다 |
| ✅ | **225문항** | 🔴·🟡·🟢 어느 항목에도 걸리지 않은 문항(중복·length-cue 는 별도 집계) |

- **공개 문항 중 🔴: 3건** — `soa-t1-2-q3`(**정답이 둘**) · `soa-t1-5-q13`(정답이 종료된 제품 이름) · `soa-t4-3-q11`(해설의 이유가 거짓). **정답 인덱스를 바꿔야 하는 문항은 0건**이다(`t1-2-q3` 은 오답 보기 교체로 닫는다). 나머지 🔴 3건은 **라이브 학습문서**(`soa-t5-3.md` · `soa-t4-2.md` · `soa-t3-2.md`)다.
- 문항 기준 집계(고유): 🔴 3 · 🟡 67(내용 22 + 출처 47 − 겹침 2) · 🟢 전용 5 · ✅ 225.
- `prescreen`(`node tool/prescreen.mjs build soa` 실측): 구조·정합성 플래그 **0건** / qualityFlags — length-cue **181** · meta-phrasing **1** · authoring-memo **0** · explanation-long **0** (전체 300문항 중 신호 181문항, 60%) / Task 내 중복 후보 **0쌍**.
- 검증한 출처 URL: 문항+md 고유 **282개 전부 `200 r=0`**(죽은 링크 0 · 문항 출처 고유 217개 · 호스트는 문항 330참조 전부 `docs.aws.amazon.com`) / 그중 「그 사실을 담지 않음」 **47문항**(페이지로는 30여 개 — 문항별 표는 §2 Y19). 원인은 대부분 AWS docs 의 **허브화**다 — 본문 4,000자 미만 페이지가 68개(1,500자 미만 13개)다.
- 지난 보고(2026-11-06) 잔여: `P3-SOA-6`(고해상도 경보 주기) **미반영**(→ §6-1) · `P3-SOA-1`(정답 인덱스 쏠림 0:259/1:30/2:9/3:2)은 「고치지 않는다」 판정 유지 · 2026-10-29 URL 감사 A7(`soa-t5-4-q12` 출처 적합성) **미결**(→ Y19 표).
- 구조 실측: 보기 4개 균일 · `wrongExplanations` 키 불일치 0 · `examGuideTaskId` 불일치 0 · difficulty applied 205 / foundational 95(Task별 3~6).

### 0-1. ✅ 공식 대조로 확인한 사실(손대지 말 것)

gp3 최대 80,000 IOPS·2,000 MiB/s · EC2 복구(휘발성 메모리 손실 · 메탈 제외) · 교차 영역 기본값(ALB 켜짐 · NLB/GWLB 꺼짐) · GuardDuty 기반 데이터 소스 · SCP 의 관리 계정 예외와 루트 포함 · Vault Lock 두 모드 · VPN 터널 2개 · 게이트웨이 엔드포인트 무료 · Parameter Store 표준 무료 · 수명 주기 후크 1시간/48시간 · Multivalue 8개 · 가중치 0~255 · REL02-BP02 "cost-effective backup" · 세부 모니터링 과금 · `ec2messages` 엔드포인트(여전히 공식 목록에 있다 — `soa-t3-3-q2` 는 결함 아님) · Health Dashboard 명칭(md 가 신·구 이름 병기 — 결함 아님) · CloudTrail Insights(관리 이벤트 쓰기 API 호출률·오류율) · RDS 암호화 전환 두 경로(`soa-t4-3.md:157`·`:248` · `soa-t4-3` 문항 해설에 Blue/Green 반영됨) · `soa-t1-1-q11`(EventBridge ≠ 경보 작업 — 2026-11 정정분 유지).

---

## 1. 🔴 (문항·학습문서)

### R1. `soa-t1-2-q3` — 오답 보기가 새 기능(Log Alarm)으로 참이 됐다: **정답이 둘**

- **공개 여부**: verified true
- **현재 정답 인덱스**: 0
- **결함**: 지문 「'ERROR' 가 5분 동안 10회 이상이면 SNS 알림. 가장 적절한 구성은?」에서 정답 [0]은 「지표 필터 → 지표 → 경보」이고, 오답 [2]가 「Logs Insights 쿼리를 5분마다 실행하는 경보를 만든다」다. `wrongExplanations["2"]` 는 「Logs Insights는 대화형 분석 쿼리 기능으로, **쿼리 결과에 직접 경보를 거는 방식이 아닙니다. 로그 기반 경보는 지표 필터를 사용합니다**」라고 적는다. 지금은 그 반대가 공식 기능이다.
- **공식 근거**:
  - `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Alarm-On-Logs.html` (200 r=0): "You can create CloudWatch alarms that monitor your log data in two ways: **Log Alarm approach** — Create a Log Alarm that runs a CloudWatch Logs Insights query on a schedule and evaluates the aggregated results directly against a threshold. **Metric filter approach** — …"
  - `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-log.html` (200 r=0): "Unlike metric alarms that require metric filters as an intermediate step, Log Alarms evaluate directly on log data…" · `ScheduleExpression` 예시 `rate(5 minutes)`.
- **수정안**(정답 인덱스 **불변 = 0**): 오답 [2]를 명백히 거짓인 보기로 교체한다 — 예: 「로그 그룹의 **보존 기간**을 5분으로 줄여 임계 초과 시 자동 알림이 가게 한다」. `wrongExplanations["2"]` 를 그 보기에 맞춰 다시 쓴다. 해설 끝에 한 줄 병기: 「로그 데이터에 경보를 거는 방법은 둘이다 — 지표 필터 + 지표 경보, 그리고 Logs Insights 쿼리를 일정에 따라 실행해 결과를 임계값과 직접 비교하는 **Log Alarm**.」 출처에 `Alarm-On-Logs.html` 추가. (대안: 보기 [2]를 살리고 지문에 「지표 필터를 이미 쓰고 있는 환경에서」 같은 전제를 넣는 방법은 갈림길이 약해 권하지 않는다.)
- **전수**: 「지표 필터만이 로그 경보 수단」이라는 **단정**은 문항 1자리(이 `W2`) · md 0자리. `Log Alarm`·「로그 경보」 언급은 `soa-t1-2.md` **0건**(누락) — md §3(:119~)과 자가 점검 :322 에 두 번째 경로를 한 줄 더한다. `soa-t1-2` 는 `soa_v11_topics_test` 가 `lastVerified` 를 **정확 비교**한다(§7 표).

### R2. `soa-t1-5-q13` + `soa-t1-5.md` — 정답이 **종료된 제품**(Performance Insights)

- **공개 여부**: verified true
- **현재 정답 인덱스**: 0 (「성능 개선 도우미(Performance Insights)」)
- **결함**: Performance Insights 는 수명이 끝났고 사용자는 Database Insights 로 이전됐다. 문항·md 는 상태를 한 글자도 적지 않고 현행 도구로 가르친다. 인용 페이지 `USER_PerfInsights.html` 의 제목 자체가 이제 "Monitoring DB load with Amazon CloudWatch Database Insights on Amazon RDS" 다(출처 제목 「Amazon RDS 성능 개선 도우미로 DB 부하 모니터링」이 페이지와 다르다).
- **공식 근거**: `https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Database-Insights.html` — "AWS announced that the end-of-life date for Performance Insights was July 31, 2026, and has migrated Performance Insights users to Database Insights."
- **수정안**(정답 인덱스 **불변 = 0**): 공식 가이드 skill 1.3.5 가 아직 「성능 개선 도우미」를 적으므로 이름을 지우지 않고 **병기**한다. 정답 보기 → 「CloudWatch Database Insights(구 성능 개선 도우미·Performance Insights)」, 해설 끝에 「Performance Insights 는 2026-07-31 에 수명이 끝났고 그 기능은 CloudWatch Database Insights 로 이전됐다. 시험 가이드 문구는 옛 이름을 쓴다」, 출처 제목을 현재 페이지 제목으로 바꾸고 `Database-Insights.html` 을 추가. md 는 :47·:149·:163·:168·:170·:273 여섯 자리에 같은 병기.
- **전수**: `Performance Insights`/「성능 개선 도우미」 — md 6자리(`soa-t1-5.md`) · 문항 1자리. `Database Insights` — SOA 전체 **0건**. 조사 노트 `98-existing-gap.md`(P2-C15)가 2026-10-17 에 「구식」으로 적었으나 반영되지 않았다. `soa-t1-5` 는 **두 테스트 모두** `lastVerified` 를 고정한다.
- **등급 메모**: 정답을 고를 수는 있으므로 2단계가 🟡 로 내려도 수정안은 같다. 🔴 로 둔 이유는 「닫힌 서비스」가 아니라 **이미 종료된 제품이 정답**이라서다.

### R3. `soa-t4-3-q11` + `soa-t4-3.md:203` — 가져온 인증서를 ACM 이 못 갱신하는 **이유가 거짓**

- **공개 여부**: verified true
- **현재 정답 인덱스**: 0 (「자동 갱신이 지원되지 않으므로 만료일을 직접 추적해 교체해야 한다」 — 정답 자체는 옳다)
- **결함**: 해설 「가져온 인증서는 **개인 키가 ACM 외부에 있어** ACM이 갱신할 수 없습니다」. 가져오기는 개인 키를 **ACM 에 함께 넣는** 절차다. md :203 원리 블록도 같은 이유를 적는다(「개인 키가 ACM 외부에 있어 … 새 키 쌍을 갱신할 권한이 없습니다」).
- **공식 근거**:
  - `https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-prerequisites.html` — "you must provide both the certificate and its private key … You must provide the private key"
  - `https://docs.aws.amazon.com/acm/latest/userguide/import-certificate.html` — "ACM does not provide managed renewal for imported certificates. To renew an imported certificate, you can obtain a new certificate from your certificate issuer and then manually reimport it"
- **수정안**(정답 불변): 해설 → 「가져온 인증서는 ACM 이 **발급자가 아니므로** 관리형 갱신을 제공하지 않는다. 발급자에게서 새 인증서를 받아 **다시 가져와야** 한다(개인 키는 가져올 때 함께 제공하므로 「키가 ACM 밖에 있어서」가 이유는 아니다).」 md :203 도 같은 방향으로.
- **전수**: 「개인 키가 ACM 외부」 — 문항 1자리 · md 1자리. `soa-t4-3` 은 `soa_facts_test` 가 `lastVerified` 를 고정한다.

### R4. `soa-t5-3.md` — 「라우팅 정책 7종」·「Geoproximity 는 Traffic Flow 에서만」 (학습문서, 문항 0)

- **공개 여부**: 라이브 학습문서(문항에는 Geoproximity·Traffic Flow·「7종」 0건 — grep 실측)
- **결함 ①**: 「라우팅 정책 **7종**」(:40 · :52 · :120 · :214). 공식은 **8종**을 싣는다(IP 기반 라우팅이 빠졌다).
- **결함 ②**: 「**Geoproximity**는 **Route 53 Traffic Flow 에서만** 사용」(:133 · :129 표의 「Traffic Flow 필요」 · 용어 표 :67·:68). 공식은 레코드를 만들 때 고르는 정책으로 적는다.
- **공식 근거**: `https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html` — "When you create a record, you choose a routing policy …" 목록에 **Geoproximity routing policy** 와 **IP-based routing policy** 가 함께 있고 "You can use geoproximity routing to create records in a private hosted zone" 을 적는다.
- **수정안**: 개수를 단정하지 않는다(「라우팅 정책」으로 쓰고 표에 **IP 기반 라우팅** 행 추가 — 행의 설명은 2단계가 위 페이지에서 직접 옮긴다). :133·:129·:67·:68 은 「Geoproximity 는 레코드 생성 시 고를 수 있는 정책이다」로 고치고 「Traffic Flow 에서만」을 걷는다. (레포 기록은 「Traffic Flow 전용인 것은 편향 범위 **지도**뿐」이라는 2026-10-28 SAA 판정을 적고 있으나 이 세션은 그 문장을 다시 재지 않았다 — 쓰려면 재확인.)
- **전수**: md 「7종」 4자리 · 「Traffic Flow」 5자리 / 문항 0자리. ⚠️ 같은 문구가 **`saa-t3-7.md` 에도 남아 있다**(§5 — 다른 자격증 파일이라 적기만 한다). `soa-t5-3` 은 `lastVerified` 고정 맵에 **없다**(md 값 2026-06-12).

### R5. `soa-t4-2.md` — 「Trusted Advisor **5개 범주**」 (학습문서 + 문항 해설 1)

- **공개 여부**: 라이브 학습문서 + `soa-t4-2-q12`(verified true)
- **현재 정답 인덱스**(`soa-t4-2-q12`): 3 (「소스 코드 품질」 — **불변**)
- **결함**: md :92(「5개 범주 점검」) · :172(절 제목 「5범주」) · :176~182 표 · :266(「5범주: 비용·보안·내결함성·성능·서비스 한도」). 공식 범주는 **여섯**이다. `q12` 해설은 다섯만 나열한다(정답은 여섯 어디에도 없는 「소스 코드 품질」이라 그대로 맞다).
- **공식 근거**: `https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor-check-reference.html` — "Check categories: Cost optimization, Performance, Security, Fault tolerance, Service limits, **Operational Excellence**".
- **수정안**: md 세 자리와 표에 **운영 우수성(Operational Excellence)** 을 넣고 개수 표현을 걷는다(「범주별 점검」). `q12` 해설에 운영 우수성 추가.
- **전수**: md 3자리(+표 1) · 문항 1자리. `soa-t4-2` 는 **두 테스트 모두** `lastVerified` 를 고정한다.

### R6. `soa-t3-2.md:207` — 「AMI 와 스냅샷은 … **연동 삭제가 불가하다**」 (학습문서 + 문항 해설 1)

- **공개 여부**: 라이브 학습문서 + `soa-t3-2-q1`(verified true)
- **현재 정답 인덱스**(`soa-t3-2-q1`): 0 (「등록 해제해도 연결된 EBS 스냅샷은 자동 삭제되지 않기 때문」 — **기본 동작으로는 옳다. 불변**)
- **결함**: :207 은 「연동 삭제가 불가」로 **단정**한다. 등록 해제 시 스냅샷을 함께 지우는 선택지가 공식에 있다. 같은 계열의 불완전 서술이 :84 · :191 · :245 와 `q1` 해설(「AMI 등록 해제와 스냅샷 삭제 **두 단계를 명시적으로 수행해야**」)에 있다.
- **공식 근거**: `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/deregister-ami.html` — "When deregistering an AMI, you can optionally delete its associated snapshots at the same time. However, if a snapshot is associated with multiple AMIs, it won't be deleted even if specified".
- **수정안**: :207 → 「기본 동작으로는 스냅샷이 남는다. 등록 해제 시 **연결된 스냅샷을 함께 삭제하도록 선택**할 수 있지만, 여러 AMI 가 참조하는 스냅샷은 지정해도 지워지지 않는다.」 :84·:191·:245 와 `q1` 해설에 같은 한 줄. 지문에 「기본 동작으로」를 넣으면 더 단단하다.
- **전수**: 「연동 삭제 불가」 단정 md 1자리 / 불완전 서술 md 3자리 · 문항 1자리. `soa-t3-2` 는 고정 맵에 **없다**.

---

## 2. 🟡 (수정 권고)

### Y1. CloudTrail Lake — 신규 고객 차단 상태 누락

- `soa-t1-3-q6`(verified true · **정답 인덱스 0** = 「CloudTrail Lake」) + `soa-t1-3.md` :38 · :118 · :122 · :195.
- 근거: `https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-lake.html` — "AWS CloudTrail Lake will no longer be open to new customers starting May 31, 2026 … Existing customers can continue to use the service as normal."
- 수정안: 해설(가르치는 층)과 md §4 에 상태 한 줄. `soa-t4-2-q4` 의 `W3` 언급은 오답 층이라 대상이 아니다.
- 전수: SOA 전체에서 「신규 고객」 상태 문구 **0건**. 같은 사실을 AIF(`aif-t5-2`)·MLA(`mla-t4-3.md:477`)는 이미 적는다(§5). `soa-t1-3` 은 고정 맵에 없다.
- 참고: `soa-t1-1.md:204`·`soa-t1-1-q11` 해설의 Incident Manager 는 공식 경보 작업 목록을 인용하는 수준이라 올리지 않았다(Incident Manager 는 2025-11-07 유지 관리 공지 대상 — 한 줄 메모는 선택).

### Y2. Security Hub — 명칭·ASFF 귀속(CSPM)

- `soa-t4-2-q4`(**정답 0**) · `soa-t4-2-q5`(**정답 0**, 정답 보기가 「ASFF로 정규화」) + `soa-t4-2.md` 「Security Hub」 28개소(그중 ASFF 9). `soa-t4-2-q6`(정답 0)은 이름만 해당.
- 결함: 인용 페이지의 제목이 이제 "Introduction to AWS Security Hub **CSPM**" 이고 ASFF 를 쓰는 쪽이 CSPM 이다 — "AWS Security Hub CSPM consumes and aggregates findings … AWS Security Finding Format (ASFF)". 새 「AWS Security Hub」는 OCSF 로 노출 조사 결과를 낸다(`securityhub/latest/userguide/securityhub-ocsf.html`). SOA 에 `CSPM` **0건**.
- 수정안: 문항 해설과 md §2 첫 문장에 「표준 점검·ASFF 집계를 하는 서비스의 현재 공식 이름은 **AWS Security Hub CSPM**」 병기. 공식 가이드 skill 4.2.5 문구(「Security Hub」)는 그대로 둔다. 정답 불변.
- `soa-t4-2` 는 두 테스트 모두 `lastVerified` 고정.

### Y3. Secrets Manager 교체를 「Lambda 기반」으로만 서술

- `soa-t4-3-q13`(**정답 0** = 「Secrets Manager — **Lambda 기반 교체를 내장 지원**하고 RDS·Aurora 통합 템플릿을 제공」) + `soa-t4-3.md` :174 · :183 · :279, `soa-t3-3.md` :207(「내장 Lambda 로테이터」).
- 근거(문항이 인용한 바로 그 페이지): `https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html` — "Managed rotation – … **doesn't use a Lambda function** … Rotation by Lambda function – For other types of secrets".
- 수정안: 정답 보기를 「Secrets Manager — 자동 교체를 내장하고 RDS·Aurora 와 통합된다」로(정답 인덱스 불변), 해설에 「관리형 교체는 Lambda 를 쓰지 않고, 그 밖의 비밀은 Lambda 함수로 교체한다」. md 네 자리 동일. (`soa-t3-3.md:286`·`soa-t3-3-q13` 은 이미 옳다.)

### Y4. `soa-t4-3-q12` — 「ACM 발급 + DNS 검증이면 완전 자동」에 조건이 빠졌다

- verified true · **정답 0**.
- 근거: 인용 페이지 `acm/latest/userguide/dns-renewal-validation.html` 이 "The certificate is currently in use by an AWS service" 조건을 함께 적고, `managed-renewal.html` 이 적격(서비스에 연결됨 · 발급 후 내보냄)과 비적격(가져옴)을 가른다.
- 수정안: 정답 보기·해설에 「**AWS 서비스에서 사용 중이고**(또는 내보낸 인증서이고) DNS 검증 레코드가 유지되는 경우」. 정답 불변. md :190·:230 도 같은 한정.

### Y5. 「ALB·NLB·API Gateway 는 같은 리전 인증서」 — API Gateway 엣지 최적화 예외

- `soa-t4-3-q10`(**정답 0**)·`soa-t5-3-q13`(**정답 0**) 해설 + `soa-t4-3.md` :197 · :293.
- 근거: `https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-edge-optimized-custom-domain-name.html` (200 r=0) — "You must request or import a certificate for your edge-optimized custom domain name in the US East (N. Virginia) – us-east-1 Region." 두 문항이 인용한 `cnames-and-https-requirements.html` 에는 API Gateway 가 없다.
- 수정안: 「ALB·NLB·**리전형** API Gateway 는 같은 리전, **엣지 최적화 API Gateway 사용자 지정 도메인은 us-east-1**」. 정답 불변.

### Y6. `soa-t5-3-q11` — 무효화 비용 논리가 공식 과금과 다르다

- verified true · **정답 0**. 해설·정답 보기 「소수 경로 무효화는 비용이 적지만 **잦은 전체 무효화는 비용·부하가 크다**」 + `soa-t5-3.md` :168 · :196 · :239.
- 근거: `AmazonCloudFront/latest/DeveloperGuide/PayingForInvalidation.html` — "The first 1,000 invalidation paths that you submit per month are free … A path that includes the * wildcard counts as one path … The charge … is the same regardless of the number of files". 즉 `/*` 는 **경로 1개**다. 버전 파일명 권고 자체는 인용 페이지 `Invalidation.html` 이 지지한다("Versioning is less expensive … you don't have to pay for invalidating files").
- 수정안: 이유를 공식이 적는 쪽으로 — 「무효화는 월 1,000 경로 초과분에 과금되고(`/*` 는 1경로), 버전 파일명은 무효화 비용이 없고 사용자·중간 캐시에 남은 옛 버전 문제와 롤백에도 유리하다」. 정답 방향·인덱스 불변.

### Y7. `Patch Group` 태그 키 — 「정확히 `Patch Group` 일 때만」

- `soa-t3-3-q8`(**정답 0**)·`soa-t3-2-q10`(**정답 0**) + md `Patch Group` 11줄(`soa-t3-3.md` :154·:227·:243, `soa-t3-2.md` :154·:162·:196·:215). `PatchGroup` 은 SOA **0건**.
- 근거: `systems-manager/latest/userguide/patch-manager-tag-a-patch-group.html` — "the tag key must be Patch Group or **PatchGroup**. PatchGroup (without a space) is required if you have allowed tags in EC2 instance metadata" · `patch-manager-patch-groups.html` — "Patch groups are not used in patching operations that are based on patch policies … not supported in the console for account-Region pairs that did not already use patch groups before … December 22, 2022".
- 수정안: 「키는 `Patch Group` 또는 `PatchGroup`(인스턴스 메타데이터에서 태그를 허용했다면 공백 없는 쪽이 필수)」 + 「패치 정책 기반 운영에서는 패치 그룹을 쓰지 않는다」 한 줄. `q8` 지문의 `patch group`(소문자)은 여전히 오답 원인으로 성립하므로 정답 불변.

### Y8. `soa-t2-1-q11` — 상태 확인 유예 기간 「기본 300초」

- verified true · **정답 0** + `soa-t2-1.md:168`.
- 근거: `autoscaling/ec2/userguide/health-check-grace-period.html` — "In the console, by default, the health check grace period is 300 seconds … Its default value is 0 seconds when you create an Auto Scaling group using the AWS CLI or an SDK."
- 수정안: 「(콘솔 기본 300초 · CLI/SDK 기본 0초)」. IaC 로 만든 ASG 가 바로 이 함정을 밟는다. 정답 불변.

### Y9. `soa-t2-1-q5` — 「14일 이상의 이력이 **권장**」

- verified true · **정답 0** + `soa-t2-1.md:118`.
- 근거: `autoscaling/ec2/userguide/predictive-scaling-policy-overview.html` (200 r=0) — "this metric must have at least 24 hours of data … analyzing metric data from **up to** the past 14 days". 14일은 분석 창의 상한이지 권장 하한이 아니다.
- 수정안: 「최소 24시간이 필요하고, 예측은 **최근 최대 14일**의 지표를 분석한다」. 정답 불변. 출처도 이 페이지로(Y19).

### Y10. ELB 상태 확인 배타 서술의 **어형 잔여** — 가드가 못 본 두 형태

- `soa-t2-1.md:226` 「앱 계층 장애는 ELB 상태 확인을 **통해서만** ASG에 전달된다」 — 같은 문서 :173 의 「유일한 경로는 아닙니다」와 **자기모순**이다. `soa_p2_review_fix_test` 의 탐지기는 `유일한 (경로|방법|수단)` 과 「해야」 어미만 본다(「통해서만」은 0건 매칭).
- `soa-t3-4.md` :262 · :263 · :296 (+:147 의 「EC2 상태 점검 또는 ELB 상태 점검」 이분법) — 「ELB **상태 점검**을 연결해야」. 탐지기가 「상태 **확인**」 어형만 본다.
- 근거: `autoscaling/ec2/userguide/ec2-auto-scaling-health-checks.html` 의 다섯 소스(Amazon EC2 · Elastic Load Balancing · VPC Lattice · Amazon EBS · Custom health checks).
- 수정안: 네 자리를 :173 과 같은 서술로 맞추고, 가드 트리거에 「통해서만」·「상태 점검」을 더한다. 문항은 0자리(grep 실측). `soa-t2-1` 은 고정 맵에 없고 `soa-t3-4` 는 `soa_v11_topics_test` 가 고정한다.

### Y11. `soa-t5-4.md` :120 · :194 — 2026-10-19 REJECT 정정의 **잔여**

- :120 「**REJECT** = **NACL에 의해 거부된** 트래픽(또는 SG 미일치로 응답이 끊긴 상황의 흔적)」, :194 「… → REJECT가 없는데도 실패하면 **SG 인바운드를 의심**」. 같은 문서 :129~136·:215·:258 과 문서 끝 정정 메모(:303)는 「SG 미허용도 REJECT」로 고쳐져 있어 **문서 안에서 어긋난다**.
- 근거: 문서가 스스로 인용하는 공식 `action` 정의(SG 또는 NACL 이 허용하지 않은 트래픽 · 연결이 닫힌 뒤 도착한 패킷).
- 수정안: :120 → 「REJECT = SG 또는 NACL 이 허용하지 않은 트래픽(또는 연결이 닫힌 뒤 도착한 패킷)」, :194 의 마지막 화살표 → 「SG 와 NACL 을 함께 점검하고, 레코드가 아예 없으면 Reachability Analyzer 로 구성 도달성을 본다」. 문항 0자리(`soa-t5-4-q5` 는 옳다). `soa-t5-4` 는 `soa_facts_test` 가 고정한다.

### Y12. 오답 근거 정밀화 3건(정답 불변)

| 문항 | 정답 | 지금 | 공식 | 수정안 |
|---|---|---|---|---|
| `soa-t4-1-q6` `W2` | 0 | 「경계는 … 합집합 평가 대상이 아닙니다」 | `IAM/latest/UserGuide/access_policies_boundaries.html` — "resource-based policies that grant permissions to an IAM user ARN … are not limited by an implicit deny in an identity-based policy or permissions boundary" | 「경계는 자격증명 기반 정책의 상한이다. 다만 같은 계정에서 **리소스 기반 정책이 사용자 ARN 에 직접 준 권한**은 경계의 암시적 거부에 묶이지 않는다」 |
| `soa-t5-3-q4` `W2` | 0 | 「TTL 설정 가능 여부가 핵심 차이는 아닙니다」(참·거짓을 말하지 않는 회피형) | `Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html` — "If an alias record points to an AWS resource, you can't set the time to live (TTL)" | 「AWS 리소스를 가리키는 Alias 는 TTL 을 설정할 수 없다 — 보기는 거꾸로다」 |
| `soa-t2-1-q7` `W1` (+`soa-t2-1.md:130`) | 0 | 「워밍업은 새 인스턴스를 지표 집계·**상태 확인**에서 일시 제외」 | 워밍업 페이지는 집계 지표 기여만 말한다(상태 확인 보류는 **유예 기간**) | 「·상태 확인」을 걷는다 |

### Y13. `soa-t4-2-q3` — 지문 전제(「변경 이벤트만 감시하지 않고 지속적으로 평가하도록 **설계된 이유**」)

- verified true · **정답 0**. 인용 페이지 `config/latest/developerguide/evaluate-config_components.html` 은 트리거 유형을 **Configuration changes / Periodic** 둘로 적는다 — Config 규칙의 상당수는 **변경 트리거**다. 「설계 이유」를 묻는 문항군(`soa-t2-3-q7` · `soa-t3-1-q12` · `soa-t5-4-q12` 등)은 인용 출처가 그 이유를 적지 않는다(저작자의 설명이다).
- 수정안: 지문을 「Config 규칙의 두 트리거(구성 변경 · 주기)」를 묻는 쪽으로 좁히거나, 해설에 「규칙마다 변경 트리거·주기 트리거 중 하나 또는 둘을 쓴다」를 넣는다. md `soa-t4-2.md:118` 원리 블록의 「다음 평가 주기에 **반드시** 포착」도 같은 한정.

### Y14. `soa-t5-2-q15` — 「VPN 수 분 · DX **수 주**」

- verified true · **정답 0** + `soa-t5-2.md` :132 · :155. 인용한 두 소개 페이지에 구축 시간이 없다.
- VPN 은 `vpn/latest/s2svpn/SetUpVPNConnections.html` "It might take a few minutes to create the VPN connection" 로 확인. **DX 「수 주」는 공식 문서에서 확인되지 않았다**(§6-3). 수정안: DX 쪽을 「물리 회선 구축이 필요해 VPN 보다 오래 걸린다」로 수치 없이.

### Y15. EventBridge 최신성 — 버스 재구성·Scheduler

- EventBridge 문서가 버스를 "Custom Event Bus" / "Custom Event Bus - Classic" 으로 나눴고 "For new applications, start with the Custom Event Bus" 를 적는다 — SOA 에 `Custom Event Bus` **0건**.
- 예약 규칙이 레거시라는 것은 `soa-t3-4.md` :98·:239 에 있으나 `soa-t3-4-q5`(**정답 0** = 「EventBridge 스케줄 규칙(cron)으로 Lambda」)·`soa-t1-3-q9`(**정답 1**) 해설에는 **EventBridge Scheduler** 언급이 없다(md 는 옳고 문항만 낡은 역방향 잔존).
- 수정안: 두 문항 해설에 「새 일정에는 EventBridge Scheduler 가 권장된다」 한 줄. 정답 불변.

### Y16. `soa-t5-1.md:199` — 프라이빗 호스팅 영역 조건이 반쪽

- 「프라이빗 호스팅 영역이 동작하려면 **enableDnsSupport 가** 켜져 있어야」. 공식은 둘 다 요구한다 — `Route53/latest/DeveloperGuide/hosted-zone-private-considerations.html`: "you must set the following Amazon VPC settings to true: enableDnsHostnames, enableDnsSupport". 같은 자격증 `soa-t5-3.md:83` 은 둘 다 적는다(문서 간 불일치).

### Y17. `soa-t5-1.md` — 로컬 경로 「삭제 불가」

- :80 · :113(+원리 :84) · `soa-t5-1-q14`(verified true · **정답 0** = 「자동 생성되며 **삭제할 수 없고**, VPC 내 서브넷 간 통신을 보장한다」 · 해설·`W2` 도 「삭제할 수 없습니다」).
- 「자동 생성」은 `vpc/latest/userguide/subnet-route-tables.html`("By default, a route table contains a local route for communication within the VPC")로 확인된다. **「삭제할 수 없다」는 문장은 찾지 못했다** — VPC 사용 설명서의 라우팅 테이블 다섯 페이지(`VPC_Route_Tables` · `subnet-route-tables` · `WorkWithRouteTables` · `route-table-options` · `replace-local-route-target`, 전부 `200 r=0`)에서 "local" 과 "delete/remove" 가 한 문장에 있는 자리가 **0건**이다(대조군: 같은 추출에서 "local route" 32건 · "delete" 8건). 대신 `replace-local-route-target.html` 이 "You can change the target of the default local route. If you replace the target of a local route, you can later restore it to the default local target." 을 적는다.
- 수정안(정답 인덱스 불변): 정답 보기를 「기본으로 포함되며 VPC 내부 통신을 맡는다」로(확인되지 않은 「삭제할 수 없고」를 정답의 실질에서 뺀다), 해설에 「대상(target)은 바꿀 수 있고 기본값으로 되돌릴 수 있다」. 오답 [2](「삭제하면 서브넷 간 통신을 차단할 수 있다」)는 「운영자가 삭제해 서브넷을 격리하는 용도로 쓴다」처럼 그대로 거짓인 문장으로 유지. md 두 자리도 같은 방향. 사실이 거짓이라고 확인한 것은 아니므로 🟡 이다.

### Y18. 중복 — 같은 사실을 여러 문항이 묻는다(8묶음 · 20문항)

측정: 300문항 44,850쌍(같은 Task 2,100 · 교차 Task 42,750 · 출처 공유 194)의 정답 보기 자카드(원형 · 조사벗김)와 정답+해설 자카드를 쟀다. 임계 0.33 이상은 원형 13쌍(같은 Task 5 · 교차 8) · 조사벗김 19쌍(7 · 12)이고 문자열 완전 동일은 0쌍이다. 상위 쌍(교차 Task: 정답 기준 28쌍 + 정답·해설 기준 28쌍 / 같은 Task: 정답 기준 22쌍 + 정답·해설 기준 18쌍 / 지문 기준 18쌍)의 **지문·정답을 읽어** 판정했다. prescreen 의 Task 내 후보는 0쌍이지만 **교차 Task 는 prescreen 이 보지 않는다**.

| # | 묶음(정답 인덱스) | 지표(원형/조사벗김/정답+해설) | 판정 |
|---|---|---|---|
| D1 | `soa-t1-1-q7`(0) · `soa-t1-4-q8`(1) · `soa-t3-4-q9`(0) | 0.40/0.75/0.54 · 0.67/0.67/0.26 | **3중 중복** — `StatusCheckFailed_System` 경보 + EC2 복구. 지문까지 겹친다(`t1-1-q7` ↔ `t3-4-q9` 지문 0.36) |
| D2 | `soa-t4-3-q10`(0) · `soa-t5-3-q13`(0) | 0.43/0.43/**0.60** | CloudFront 용 ACM 은 us-east-1 |
| D3 | `soa-t2-2-q9`(0) · `soa-t2-4-q13`(0) | 0.56/0.56/0.21 | Route 53 장애 조치 라우팅 + 헬스 체크 |
| D4 | `soa-t1-5-q12`(0) · `soa-t2-2-q4`(0) · `soa-t2-2-q3`(0) | 0.21/0.42/0.36(지문 0.47) | Multi-AZ 동기 ↔ 읽기 복제본 비동기 |
| D5 | `soa-t2-2-q7`(0) · `soa-t2-2-q8`(0) · `soa-t5-1-q6`(0) | 0.17/0.26/0.44 | NAT 게이트웨이를 AZ 마다 두는 이유 |
| D6 | `soa-t5-1-q9`(0) · `soa-t5-4-q9`(0) | **0.06**/0.06/0.45 | NACL 무상태·이페머럴 포트(원인 ↔ 증상) — 정답 지표로는 안 잡히는 의미 중복 |
| D7 | `soa-t3-4-q15`(0) · `soa-t4-2-q15`(0) | 0.06/0.13/0.32 | Config 자동 교정 |
| D8 | `soa-t1-4-q3`(0) · `soa-t1-4-q15`(0) | 0.18/0.18/0.45 | 같은 Task — AWS Health 이벤트 → EventBridge → 자동화(일반형 ↔ 예정된 유지 관리 사례) |

- 수정안: 소유 skill 을 정해 한쪽을 다른 축으로 돌린다 — D1 은 skill 1.1.3(경보 작업, `t1-1-q7` 소유)이고 나머지 둘을 §4 의 공백 skill 로 돌리면 커버리지도 함께 닫힌다. D2 는 `t5-3-q13`(5.2.3) 소유, D3 은 `t2-2-q9` 소유.
- 중복이 **아니라고** 판정한 고지표 쌍: `soa-t3-3-q11` ↔ `soa-t3-4-q8`(0.75 — 정답이 같은 「Automation 런북」이지만 다단계 유지 관리 ↔ Config 교정 실행 층으로 묻는 것이 다르다) · `soa-t3-3-q14` ↔ `soa-t4-3-q14`(0.67 — 경로 계층 저장 ↔ 비용 기준 선택) · 같은 Task 의 서비스명 단답 쌍(`t4-2-q9`·`q11`·`q14`, `t1-3-q6`·`q7`).

### Y19. 출처가 그 사실을 담지 않는다 — 47문항 (정답 전부 불변)

AWS docs 가 허브(목차) + 하위 페이지로 재구성되면서 「URL 은 200 인데 그 사실이 없다」가 됐다. **아래 대체 출처는 전부 `curl -sL` 로 `200 r=0` 을 확인하고 본문에서 괄호 안 문구를 확인했다.** 「추가」는 기존 출처를 남기고 더하라는 뜻이다(기존 URL 이 `source_url_retired_test` 의 `replacements` 에 정본으로 묶인 경우가 있다 — §7).

| 문항(정답) | 지금 출처의 문제 | 대체·추가 출처(확인한 문구) |
|---|---|---|
| `t1-1-q2`(0)·`q3`(0)·`q4`(0)·`q10`(0)·`q13`(0) | 둘째 출처 `working_with_metrics.html` 이 OTel 지표 비교 허브로 바뀌어 출처 제목(「보존과 집계」 등)과 무관 | 둘째 출처 삭제(첫째 `cloudwatch_concepts.html` 이 사실을 담는다) |
| `t1-2-q9`(0) | 시스템 필드 없음 | `AmazonCloudWatch/latest/logs/CWL_AnalyzeLogData-discoverable-fields.html` ("five system fields: @message, @timestamp, @ingestionTime, @logStream, @log") |
| `t1-2-q10`(1)·`q13`(1) | 기본 네임스페이스·메모리 지표 없음 | `AmazonCloudWatch/latest/monitoring/metrics-collected-by-CloudWatch-agent.html` (CWAgent · mem_used_percent) |
| `t1-2-q11`(1)·`q12`(0) | SSM 문서·IAM 정책 이름 없음 | `AmazonCloudWatch/latest/monitoring/installing-cloudwatch-agent-ssm.html` (AmazonCloudWatch-ManageAgent · CloudWatchAgentServerPolicy) |
| `t1-3-q11`(0) + `soa-t1-3.md` :143·:196·:214·:215 | `eb-what-is.html` 에 CloudWatch Events 언급 0건 | `https://docs.aws.amazon.com/cloudwatch/` ("Amazon CloudWatch Events is now Amazon EventBridge … EventBridge uses the same Events API") |
| `t1-4-q2`(1) | 예정된 변경 없음 | `health/latest/ug/getting-started-health-dashboard.html` (scheduled changes) |
| `t1-5-q12`(0)·`t2-2-q4`(0)·`q14`(0) | 허브 `Concepts.MultiAZ.html`(본문 1,723자)에 **"synchronous" 0건** | **추가** `AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html` ("synchronous standby replica" · "You can't use a standby replica to serve read traffic") |
| `t2-2-q1`(1) | 허브에 "read traffic" 은 있다(2건) — 약한 출처 | 같은 페이지 **추가** |
| `t2-2-q2`(0) | 장애 조치 기제·시간 없음 | `AmazonRDS/latest/UserGuide/Concepts.MultiAZ.Failover.html` ("automatically changes the DNS record" · "Failover times are typically 60–120 seconds") |
| `t2-1-q4`(0)·`q5`(0) | 예측 조정 요건 없음 | `autoscaling/ec2/userguide/predictive-scaling-policy-overview.html` |
| `t2-2-q5`(0)·`q13`(0) | `wellarchitected/latest/framework/reliability.html` 에 "Availability Zone"·"single point" **0건** | `wellarchitected/latest/reliability-pillar/rel_fault_isolation_multiaz_region_system.html` ("Distribute workload data and resources across multiple Availability Zones … avoid single points of failure") — **추가**로 처리(§7) |
| `t2-2-q10`(0) | TTL 없음 | `Route53/latest/DeveloperGuide/resource-record-sets-values-failover.html` ("specify a TTL of 60 seconds or less") |
| `t2-2-q11`(0) | 프로토콜 없음 | `Route53/latest/DeveloperGuide/health-checks-creating-values.html` (HTTP/HTTPS/TCP) |
| `t2-3-q8`(1) | 보존 기간 없음 | `AmazonRDS/latest/UserGuide/USER_WorkingWithAutomatedBackups.BackupRetention.html` ("between 0 and 35 days" · 기본 콘솔 7일·API/CLI 1일 — `W0` 의 「7일은 기본값에 가까운 값」도 이 문구로) |
| `t2-3-q13`(0) | 버전 관리 요건 없음 | `AmazonS3/latest/userguide/replication-requirements.html` ("Both source and destination buckets must have versioning enabled") |
| `t2-3-q14`(0) | 비현재 버전 전환 없음 | `AmazonS3/latest/userguide/intro-lifecycle-rules.html` (NoncurrentVersionTransition) |
| `t3-2-q9`(0) | 본문 175자 | `systems-manager/latest/userguide/patch-manager-predefined-and-custom-patch-baselines.html` |
| `t3-2-q13`(0)·`q14`(0) | 초록 816자("historical reference only") | `whitepapers/latest/blue-green-deployments/introduction.html` (rollback · canary analysis — 같은 백서의 본문 페이지) |
| `t3-2-q12`(0) | `instance-refresh-overview.html` 은 롤링 전략만 — 「혼합 버전·롤백 느림」 없음 | **대체 페이지 미특정**(§6-3) |
| `t3-3-q3`(0) | 태그 대상 지정 없음 | **추가** `systems-manager/latest/userguide/send-commands-multiple.html` |
| `t3-4-q2`(0) | 이벤트 이름 없음 | `AWSEC2/latest/UserGuide/monitoring-instance-state-changes.html` ("EC2 Instance State-change Notification" · "aws.ec2") |
| `t4-1-q10`(0) | 조건 키 없음 | `IAM/latest/UserGuide/reference_policies_condition-keys.html` (aws:MultiFactorAuthPresent · BoolIfExists) |
| `t4-3-q4`(0) | `kms/latest/developerguide/concepts.html` 에 envelope **0건** | `kms/latest/developerguide/kms-cryptography.html` (Envelope encryption) |
| `t5-1-q3`(0) | 우선순위 규칙 없음 | `vpc/latest/userguide/route-tables-priority.html` ("longest prefix match") |
| `t5-1-q14`(0) | 로컬 경로 없음 | `vpc/latest/userguide/subnet-route-tables.html` (Y17 참조) |
| `t5-1-q7`(0) | 소스/대상 확인 없음 | `vpc/latest/userguide/work-with-nat-instances.html` (Disable source/destination checks) |
| `t5-1-q9`(0)·`t5-4-q9`(0) | 이페머럴 포트 없음 | `vpc/latest/userguide/custom-network-acl.html` (ephemeral · 1024-65535) |
| `t5-1-q13`(0) | DNS 속성 없음 | `vpc/latest/userguide/AmazonDNS-concepts.html` (enableDnsSupport / enableDnsHostnames) |
| `t5-3-q1`(0)·`q2`(0) | VPC 설정·분할 뷰 없음 | `Route53/latest/DeveloperGuide/hosted-zone-private-considerations.html` |
| `t5-3-q9`(0) | 경로 패턴 없음 | `AmazonCloudFront/latest/DeveloperGuide/DownloadDistValuesCacheBehavior.html` (path pattern) |
| `t5-3-q15`(0) | 소개 페이지에 TCP/UDP 문구 없음 | 저우선 — 대체 미특정 |
| `t5-4-q2`(0) | 캡처 범위 없음 | `vpc/latest/userguide/flow-logs-basics.html` ("a VPC, a subnet, or a network interface") |
| `t5-4-q15`(0) | Athena 없음 | `vpc/latest/userguide/flow-logs-athena.html` |
| `t5-4-q12`(0) | `infrastructure-security.html` 은 계층 위계만 적고 **진단 순서를 규정하지 않는다**("route table" 1 · "DNS" 0 · "troubleshoot" 0) — 2026-10-29 감사 A7 의 미결 | 순서를 규정하는 공식 페이지 **미특정**(§6-3). 지문을 「인스턴스에 가장 가까운 통제 계층은?」으로 좁히는 쪽이 싸다 |

- ⚠️ **쓰지 말 것(이 세션에서 실패한 추측 슬러그)**: `eb-cwe-now-eb.html` · `create-iam-roles-for-cloudwatch-agent.html` · `nacl-ephemeral-ports.html` · `Subscriptions-Concepts.html` · `running-commands-targeting.html` · `acm-regions.html` · `securityhub-v2-what-is.html` · `Invalidation_Choosing.html` · `directconnect/…/getting_started.html`(전부 `r=1`) · `framework/rel_fault_isolation_multiaz_region_system.html`(404) · `whitepapers/latest/overview-deployment-options/bluegreen-deployments.html`(`r=1`).

---

## 3. 🟢 (품질 — 사실은 옳다)

| # | 자리(정답) | 내용 | 수정안 |
|---|---|---|---|
| G1 | 181문항 | **length-cue**(정답이 최장 오답의 1.3배 초과) 60% — SCS(90%)·AIF(92%) 다음이고 SAA(42%)보다 높다. 문항 ID 전수는 `node tool/prescreen.mjs build soa` 산출물 | 오답을 같은 정밀도로 올리는 방식(SCS 선례). 정답 인덱스 쏠림(0:259)과 겹치면 「가장 긴 첫 보기」가 표식이 되나, 앱이 보기를 섞으므로 학습자에게 보이는 것은 길이뿐이다 |
| G2 | `soa-t5-4-q5`(0) | meta-phrasing — 지문 「공식 문서가 드는 예시는?」 | 「REJECT 로 기록되는 경우는?」 |
| G3 | `soa-t2-3-q4`(0) + `soa-t2-3.md` :99·:105·:240 | 「콜드오프」 — 공식 용어는 "cooling-off period" | 「쿨링오프(유예) 기간」 |
| G4 | `soa-t2-3-q6`(0) | 지문 「EBS 볼륨과 AMI의 생성·보존·삭제」 — DLM 대상은 EBS **스냅샷**과 EBS 기반 AMI | 「EBS 스냅샷과 AMI」 |
| G5 | `soa-t2-4-q10`(0) | 오답 [2]가 이중 부정이라 읽기 어렵다 | 단문으로 |
| G6 | `soa-t1-5-q6`(1) | 한 문항 안 `GB` 2 · `GiB` 1 혼용(「3 IOPS/GB」 ↔ 「5,334 GiB」). **`MB/s`·`MiB/s` 혼용은 0건**(이 문항은 `MB/s` 8 · `MiB/s` 0 으로 일관) | `W2` 를 「5,334 GiB」 그대로 두되 `W0` 을 「1 GiB당 3 IOPS」로 — 또는 그대로 둔다 |
| G7 | `soa-t1-2.md:235` | 「고대수(custom) 지표」 오자 | 「고차원(high-cardinality)」 등 원 의도 확인 후 정정 |
| G8 | `soa-t1-5.md:134` | 「약 1,000 GB(≈5,334 GiB에서 16,000 IOPS 상한)」 괄호가 두 사실을 한 번에 담아 오독된다 | 두 문장으로 분리 |

---

## 4. 커버리지·범위

### 4-1. 가이드 skill 53개 대비 문항 태그

- **태그 기준 미커버 12개**: `1.1.3` `1.1.4` `1.1.5` `1.2.3` `1.3.3` `1.3.4` `2.1.2` `2.1.3` `3.1.6` `4.2.1` `5.1.3` `5.3.5`.
- **쏠림**: `1.1.1` 27문항 · `1.2.1` 23 · `3.2.1` 18 · `2.1.1` 15 · `3.2.2` 15.
- 내용 기준으로 다시 가르면:
  - **md·문항 모두 0건(진짜 공백)**: `1.3.3` · `3.1.6` · `5.1.3` · `5.3.5`.
  - **md 에만 있고 문항 0**: `1.3.4`(EFS 13 · FSx 8 · S3 Files 10 언급 — 문항 정답·지문 0건).
  - **내용은 있으나 다른 번호로 태깅(7개)**: 예) `soa-t1-1-q7`·`q8`·`q11` 은 `1.2.1` 태그인데 내용은 `1.1.3`(경보 작업) · `soa-t1-1-q9`·`q12` → `1.1.4` · `soa-t3-3-q11`·`q12` → `1.2.3` · `soa-t4-2-q4`·`q11`(Macie) → `4.2.1`.
- **v1.1 신규 주제는 md 에만 있고 문항 0**: AWS DevOps Agent(md 17) · AWS Security Agent(10) · Kiro(7) · S3 Files · Bedrock/Lambda 모니터링 · CDK.
- ⚠️ SOA 에는 **커버리지 가드가 없다**(AIF·SCS·AIP 의 「모든 목표가 최소 한 문항에 덮인다」 단정에 해당하는 것이 `soa_questions_test` 에 없다). 재태깅 7개 + 신규 5 skill 문항을 넣은 뒤 가드를 세우는 순서를 권한다. Y18 의 중복 문항을 공백 skill 로 돌리면 문항 수를 늘리지 않고 닫을 수 있다.

### 4-2. 범위

- 가이드 JSON 에 범위 내·범위 외 서비스 목록 필드가 **없다**. 대조 기준은 공식 가이드의 「범위 밖 직무」 여섯 가지(분산 아키텍처 설계 · CI/CD 파이프라인 설계 · 하이브리드·멀티 VPC 네트워킹 설계 · 보안·규정 준수·거버넌스 요구 사항 정의 · 용량 평가·계획 · 비용·TCO 분석 — `docs/content-research/SOA-C03/00-overview.md` §4, 목록은 non-exhaustive)다.
- 300문항 지문·정답을 그 여섯에 맞대 통독한 결과 **범위 밖 직무를 정답의 실질로 삼는 문항은 0건**이다. 경계에 가까운 것: DR 전략 선택(`soa-t2-4-q2`·`q5` — skill 2.3 이 「DR 전략 구현」을 직접 적으므로 범위 내) · 네트워크 비용(`soa-t5-1-q15`·`soa-t5-2-q14` — skill 5.1.4, 운영자 조치 수준).

---

## 5. 교차 자격증(이 세션은 SOA 만 검증했다 — 다른 자격증 파일은 적기만 한다)

| 사실 | SOA | 다른 자격증 |
|---|---|---|
| Route 53 Geoproximity 는 Traffic Flow 전용이 아니다 · 정책 개수 | `soa-t5-3.md` 가 「7종」·「Traffic Flow 에서만」(R4) | ⚠️ **`saa-t3-7.md` 에 같은 문구가 그대로 있다**(「Geoproximity는 Route 53 Traffic Flow 기능에서만 사용할 수 있습니다」 · 표 「Traffic Flow 필요」 · 흔한 함정 5번 — grep 실측). 레포 기록상 2026-10-28 에 SAA **문항** 쪽만 고쳤다. SAA 담당 세션 확인 필요 |
| CloudTrail Lake 신규 고객 차단 | 상태 0건(Y1) | `aif-t5-2.md` · `mla-t4-2.md` · `mla-t4-3.md` · `aip-t4-3.md` 는 CloudTrail Lake 와 「신규 고객」 문구를 함께 적는다(파일 단위 grep 실측) |
| Security Hub ↔ Security Hub CSPM | `CSPM` 0건(Y2) | SCS 는 D-09 규율로 갈라 쓴다 |
| Secrets Manager 관리형 교체는 Lambda 를 쓰지 않는다 | 「Lambda 기반」(Y3) | SCS 도메인 5 는 옳게 적는다 |
| ASG 상태 확인 소스 다섯 | 어형 잔여 4자리(Y10) | `saa-t2-3` 은 2026-11-06 에 정정 |
| Performance Insights 종료 | 정답으로 사용(R2) | 다른 자격증의 `Performance Insights` 언급은 이 세션이 세지 않았다 — **각 담당 세션 확인 필요** |
| Trusted Advisor 범주 여섯 | 「5범주」(R5) | CLF·SAA 의 Trusted Advisor 서술은 세지 않았다 — **확인 필요** |
| ElastiCache Memcached 「복제 없음」 | `soa-t1-5.md` 표가 한정 없이 적는다 | SAA 는 「노드 기반 Memcached」로 한정(서버리스 캐시는 복제된 Multi-AZ). 이 세션은 공식 본문을 열지 않았다 — **미확인 후보** |

---

## 6. 공식 내부 어긋남 · 확인되지 않음

### 6-1. 고해상도 경보 주기 — 공식 두 페이지가 다르다 (`P3-SOA-6` 잔여)

- `AmazonCloudWatch/latest/monitoring/alarm-evaluation.html` — "10 seconds, **20 seconds**, or 30 seconds" ↔ `cloudwatch_concepts.html` — "10 seconds or 30 seconds".
- `soa-t1-1-q3`(**정답 0**) 해설과 `soa-t1-1.md` :118 · :283 은 후자(10/30)와 일치한다. 거짓이 아니므로 🔴 가 아니다.
- 권고: 개수를 단정하지 않는다(「60초 미만 주기의 고해상도 경보」). 문항이 「10초 또는 30초」를 **정답의 실질**로 삼지 않는지 2단계가 확인. `soa-t1-1` 은 `soa_v11_topics_test` 가 `lastVerified` 를 고정한다.

### 6-2. 인용 페이지가 이름을 바꿨는데 가이드는 옛 이름

- 공식 가이드 skill 1.3.5 「성능 개선 도우미」 ↔ 제품은 CloudWatch Database Insights(R2). 가이드 JSON 은 **가이드 전사**이므로 고치지 않고, 콘텐츠만 병기한다.
- 공식 가이드 skill 4.2.5 「Security Hub」 ↔ 문서는 Security Hub CSPM(Y2). 같은 처리.

### 6-3. 확인되지 않음(「없다」가 아니라 「찾지 못했다」)

| 주장 | 자리 | 본 범위 |
|---|---|---|
| Direct Connect 구축 「수 주」 | `soa-t5-2-q15` · `soa-t5-2.md:155` | 인용 소개 페이지 2개 · DX 시작 가이드 후보(추측 슬러그 `r=1`) — 수치를 적는 페이지를 찾지 못했다 |
| VPC 로컬 경로 「삭제 불가」 | `soa-t5-1.md` :80·:113 · `soa-t5-1-q14` | VPC 라우팅 테이블 다섯 페이지 — "local" + "delete/remove" 동시 문장 0건, 「대상 변경·복원 가능」은 있음(Y17) |
| 롤링 배포의 「혼합 버전 · 롤백 느림」 | `soa-t3-2-q12` | `instance-refresh-overview.html` · Blue/Green 백서 소개 — 해당 대비 문장 없음 |
| 연결 진단 「SG → NACL → 라우팅 → IGW/NAT → DNS」 순서 | `soa-t5-4-q12` · `soa-t5-4.md` §6 | `infrastructure-security.html` — 계층만 있고 순서 규정 없음 |
| ElastiCache Memcached 복제 | `soa-t1-5.md` 표 | 공식 본문을 열지 않았다(§5) |

### 6-4. NEEDS_CONTEXT

없다. 계약의 형식·범위·금지 사항으로 판단이 막힌 자리는 없었다.

---

## 7. 2단계 순서 제안

1. **R1** `soa-t1-2-q3` — 유일한 「정답이 둘」. 오답 보기 1개 교체 + md 한 줄.
2. **R2** Performance Insights 병기(문항 1 + md 6자리) → **Y1** CloudTrail Lake · **Y2** Security Hub CSPM 을 같은 배치로(전부 「상태·명칭 병기」 계열이고 가르치는 층에만 단다).
3. **R3 · Y3 · Y4 · Y5** — 전부 `soa-t4-3`(ACM·Secrets Manager). 한 파일 한 배치.
4. **R4 · Y6 · Y16** — `soa-t5-3` / `soa-t5-1` md. **R5** `soa-t4-2` · **R6** `soa-t3-2`.
5. **Y10 · Y11** — 가드 어형 구멍. 콘텐츠를 고치면서 `soa_p2_review_fix_test` 탐지기에 「통해서만」·「상태 점검」을 더한다.
6. **Y7~Y9 · Y12~Y15 · Y17** — 문항 해설 정밀화(정답 전부 불변).
7. **Y19** 출처 47문항 — 사실 서술을 바꾸지 않는 핫픽스라 따로 한 배치. 교체 뒤 새 URL 전수를 `curl -sL` 로 다시 잰다.
8. **Y18 + §4-1** — 중복 문항을 공백 skill 로 돌리고 재태깅한 뒤 **커버리지 가드 신설**. 문항 교체는 사람 승인 영역이다(전부 라이브).
9. **G1** 길이 단서 181문항 — 가장 큰 배치. 6·8번에서 손댄 문항은 그때 함께 맞춘다.

### 7-1. `lastVerified` 가드 묶임 — 본문을 고치면 날짜와 **이 테스트 맵**을 함께 올린다

두 테스트 모두 `doc(id).contains('lastVerified: $date')` 로 **날짜를 정확 비교**한다(`flutter_app/test/soa_facts_test.dart:150~156` · `soa_v11_topics_test.dart:360~371`, 2026-11-17 실측).

| 문서(md 현재 값) | 묶인 테스트 | 이 보고서의 수정 권고 |
|---|---|---|
| `soa-t1-1`(2026-11-01) | `soa_v11_topics_test` | §6-1 |
| `soa-t1-2`(2026-11-06) | `soa_v11_topics_test` | R1 · G7 |
| `soa-t1-3`(2026-06-12) | 없음 | Y1 · Y19(`eb-what-is`) |
| `soa-t1-5`(2026-11-06) | **`soa_facts_test` + `soa_v11_topics_test`** | R2 · G8 |
| `soa-t2-1`(2026-11-06) | 없음 | Y8 · Y9 · Y10 · Y12 |
| `soa-t2-3`(2026-11-06) | 없음 | G3 |
| `soa-t3-2`(2026-11-06) | 없음 | R6 · Y7 |
| `soa-t3-3`(2026-06-12) | 없음 | Y3 · Y7 |
| `soa-t3-4`(2026-10-20) | `soa_v11_topics_test` | Y10 |
| `soa-t4-2`(2026-10-20) | **`soa_facts_test` + `soa_v11_topics_test`** | R5 · Y2 · Y13 |
| `soa-t4-3`(2026-11-06) | `soa_facts_test` | R3 · Y3 · Y4 · Y5 |
| `soa-t5-1`(2026-11-06) | 없음 | Y16 · Y17 |
| `soa-t5-2`(2026-11-06) | `soa_v11_topics_test` | Y14 |
| `soa-t5-3`(2026-06-12) | 없음 | R4 · Y6 |
| `soa-t5-4`(2026-11-06) | `soa_facts_test` | Y11 |

수정 권고가 없는 문서: `soa-t1-4`(v11 고정) · `soa-t2-2`(없음) · `soa-t2-4`(두 테스트 고정) · `soa-t3-1`(v11 고정) · `soa-t4-1`(v11 고정) — `soa-t2-2`·`soa-t4-1` 은 문항만 손댄다.

### 7-2. 수정이 건드릴 수 있는 그 밖의 가드

- `source_url_retired_test.dart` 의 `replacements` 가 **정본으로 묶은 URL**: `systems-manager/…/run-command.html`(:315 — `soa-t3-3-q3`) · `vpc/…/infrastructure-security.html`(:335 — `soa-t5-4-q12`) · `wellarchitected/latest/framework/reliability.html`(:411~426 — `soa-t2-2-q5`·`q13` 등). 이 셋은 **교체가 아니라 추가**로 처리하거나, 교체하려면 그 맵을 같은 PR 에서 고친다.
- `soa_p1_review_fix_test.dart` 가 `soa-t1-5-q12`·`soa-t2-2-q1`·`q4`·`q14`·`soa-t5-1-q6` 의 정답 인덱스·한정 문구를 묶는다 — Y19 의 Multi-AZ 출처 **추가**는 충돌하지 않는다. Y18 D4·D5 로 이 문항들을 교체하면 그 가드를 먼저 센다.
- `soa_p2_review_fix_test.dart` 는 `soa-t2-1.md` 의 「유일한 경로는 아닙니다」 문장을 **필수**로 묶는다 — Y10 수정 때 그 문장을 지우지 않는다.
- R1·R2·R3·R5·R6 의 대상 문구(`성능 개선 도우미` · `7종` · `5범주` · `Traffic Flow` · `CloudTrail Lake` · `Patch Group`)를 묶는 SOA 가드는 **0건**이다(test 디렉터리 grep 실측) — 고친 뒤 회귀 가드를 새로 세울 자리다.
