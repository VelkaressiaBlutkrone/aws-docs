# SAA-C03 전수 검토 — 2차 패스 (Fable 5.1, 2026-11-06)

1차 보고서: `saa-c03.md`(Opus, 같은 세션). 이 파일은 1차를 **반증**하고 1차가 놓친 것을 찾는 패스다. 1차 파일은 손대지 않았다.
수정·커밋·테스트 실행 없음. 생성 파일은 이 보고서 하나.

**결과 요약: 1차 21건 중 확정 10 · 수정 7 · 기각 0 (단, 1차 「측정 한계」 항목 1건은 기각) · 신규 2묶음(4건) · 승격 2건.**

---

## 0. 2차 패스 계획

같은 세션이라 독립 재현은 불가능하다. 그래서 1차와 **다른 측정 방법**을 우선했다.

| 단계 | 무엇을 | 1차와 다른 점 |
|---|---|---|
| A | 1차 21개 항목의 **문구로 레포 전역 재스캔** (`.md` + `.questions.json`, SAA 밖 5개 자격증 포함) | 1차는 발견 파일 안에서만 셌다. 컨트롤러가 지적한 「범위 과소 집계」를 먼저 닫는다. **어미·동의어 변형**을 함께 센다(`먼저 고려하`·`우선 고려하`·`우선 권장`, `읽기를 제공하지 않`·`읽기에 사용되지`·`읽기를 처리하지 않`, `쓸 이유가 없`, `부하 분산.*터널` 등) |
| B | 1차 발견의 **공식 재측정** — `curl -sL` 재측정 + AWS 문서 리더 재읽기(끊기면 curl + 내장 브라우저) | 1차와 같은 URL이라도 **다른 조각(섹션)**을 읽어 1차가 못 본 문장을 찾는다 |
| C | 1차 §6 「측정 한계」를 최우선으로 재측정 (`saa-t2-4-q1` HA/FT 귀속 · `saa-t3-9-q5` Firehose→Redshift · 소개 출처 65건 표본) | 1차는 「없다」 규율을 다 채우지 못해 보류했다 |
| D | **역전파 탐지** — ① 전파 가드 금지 문구 56개 × md 24편 ② **md 가드 `isFalse` 리터럴 310개 × 문항 360개** ③ md 「📝 정정」 노트가 지운 문구 × 문항 ④ 기존 문항 가드의 `forbidden` 문자열 × **다른** 문항 | ②③④는 1차가 하지 않았다. 1차 P1-1·P1-2가 둘 다 「md는 고쳐졌는데 다른 자리에 옛 서술이 남은」 패턴이라, 그 패턴을 **기계로** 전수한다 |
| E | 24편 자가 점검 블록 전수 — 강한 단정(`만 가능`·`전용입니다`·`유일`·`공식 문서도`·`권장합니다`…) 64줄 추출 후 읽기 | 1차는 4편만 통독 |

규율은 1차와 같다. 추가: **「문서가 사라졌다」와 「사람이 열 수 없다」를 한 방법으로 결론 내리지 않는다.**

### 계획과 달라진 점
- 문서 리더가 세션 중 한 번 끊겼다가 돌아왔다. 끊긴 동안은 `curl` 로만 쟀고, 본문이 필요한 판정은 복구 후 리더로 다시 읽었다. 이 보고서의 본문 인용은 전부 리더 복구 후의 것이다.
- `cd` 뒤 상대경로 `grep` 이 한 번 **조용히 실패**했다(cwd 리셋). 절대경로로 다시 돌렸고, 결과는 그 재실행 것이다.

---

## 1. 1차 발견 재검증

범례 — **확정**: 공식 재측정·전역 재스캔 결과 1차 그대로. **수정**: 범위·수치·근거·제안이 달라짐(판정 자체는 유지). **기각**: 1차 판정이 틀림.

| # | 1차 항목 | 판정 | 전역 재스캔(개소) | 무엇이 달라졌나 / 재측정 근거 |
|---|---|---|---|---|
| P1-1 | `saa-t4-2.md:481` 「공식 문서도 SP를 먼저 고려하도록 권장」 | **확정** | md 1 · 문항 0 · 타 자격증 0 (어미 변형 5종 포함) | `sp-ris` 재읽기(2,581자 전문): 우선순위 문장 0건, 대조군 `doesn't provide capacity reservations` 1건. 같은 파일 102줄·559줄 정정 노트·파생 `q5` 모두 이를 부정 |
| P1-2 | 「부팅 볼륨은 SSD(gp2·gp3·io1·io2)만 가능」 | **확정** | md 1(`saa-t3-2.md:468`) · 문항 1(`saa-t3-2-q4`) · 타 자격증 0 | `ebs-volume-types.html` 재읽기: Magnetic(`standard`) **Boot volume: Supported**. 같은 파일 236줄이 `standard` 를 루트 볼륨으로 센다 |
| P1-3 | `saa-t3-5-q1` 해설 「Multi-AZ는 고가용성 전용 … HA 전용」 | **수정** (범위 확대 + 1차 서술 1건 정정) | 문항 **3**: `q1` 해설 + `q2` wrong[0] + `q15` wrong[0] 「Multi-AZ 스탠바이는 읽기를 제공하지 않습니다」(배포 유형 한정 없음) · md 0 · DEA 1(출처 **제목**이 단정, `dea-t2-1` — 다른 세션 담당이라 보고만) | ⚠️ **1차가 틀린 자리**: 1차는 「문항이 단 출처 `Welcome.html` 은 배포 유형을 가르지 않아 출처 적합성도 약하다」고 적었다. **아니다.** `Welcome.html` 의 Multi-AZ 절(char 12724–13912)은 *「Serving read traffic on secondary DB instances (**Multi-AZ DB clusters deployment only**)」* 와 *「All three DB instances can serve read traffic」* 을 명시한다. 즉 **출처는 정확하고, 해설이 자기 출처와 반대**다. 결함은 더 선명해졌고 출처 교체 제안은 철회한다 |
| P1-4 | 문항 JSON `**굵게**` 20개소 | **확정** | SAA 8파일 20 · 타 자격증 5종 **0** (재집계 동일) | 렌더 경로 4곳 평문 `Text` 재확인 |
| P2-1 | 은퇴 URL 4종 | **확정** | 타 자격증 0. ⚠️ 추가 범위: `saa-t3-4.md` 는 **이미 정본** `developerguide/AWS_Fargate.html` 을 쓰는데 **같은 Task 문항 3건**(`saa-t3-4-q1·q3·q11`)은 은퇴 슬러그 — 한 Task 안에서 md/문항이 갈린다 | `curl -sL` 재측정 4건 전부 `r=1`, 정본 4건 전부 `200 r=0`, 대조군(`orgs_manage_policies_zz-bogus.html`) → userguide 인덱스 `r=1`. 가드 충돌(`saa_gaps_b11_test.dart:212`)은 그대로 — **가드가 정본을 금지**한다 |
| P2-2 | 백서 5종 「은퇴 아님 · 사람이 못 염」 | **확정** | 타 자격증 0 | 리더 재읽기 5건 모두 `redirected_url: null` + 본문. 판정 유지 |
| P2-3 | `saa-t1-4-q13` 출처 — `ddos-overview` 첫 문장이 Standard도 L7 포함 | **확정** | `ddos-overview` 를 쓰는 문항 5건(q2·q3·q12·q13·q15) 중 계층 경계를 거는 것은 q13뿐 · md·문항 모두 `ddos-standard-summary` 인용 **0건** | `ddos-standard-summary.html` 재읽기(1,789자 전문): *「most common, frequently occurring network and transport layer DDoS attacks」*. 전용 페이지가 문항 편 |
| P2-4 | 경미 URL 드리프트 3건 | **확정** | — | 재측정 동일 |
| P3-1 | 정답 인덱스 쏠림(학습자 비노출) | **확정** | — | 셔플 4경로 코드 재확인 |
| P3-2 | 오답의 「명백 금지」 쏠림 | **확정** | — | 의견 항목, 변동 없음 |
| P3-3 | 정답 보기 범위 밖 2건(DRS · Timestream for InfluxDB) | **수정** (DRS 위험 하향) | — | 공식 `saa-service-mentions` 는 **목록이 아니라 약칭 안내**다(확인). `saa-technologies-concepts` 는 개념 목록에 **「재해 복구」** 를 싣는다 → DRS는 「범위 내 서비스 목록엔 없지만 출제 개념엔 있음」. Timestream 판정은 유지(데이터베이스 9종 목록에 없음) |
| P3-4 | 닫힌 서비스 처리 모범적 | **확정** | — | — |
| P3-5 | 지역 미한정 절대 단가 6종 | **수정** (범위 확대 + 출처 실측) | 문항 3(`q3·q5·q13`) + **md `saa-t4-4.md:107` 등** 같은 수치 | ⚠️ 1차가 못 한 실측: `q3` 의 출처 `vpc/latest/userguide/nat-gateway-pricing.html` 본문(858자 전문)에 **수치가 0건**이다 — *「charged for each hour … and each gigabyte」* 까지만. 즉 「인용 페이지에 없는 수치」 결함이 하나 더 확정됐다 |
| P3-6 | `saa-t4-4-q5` 교차 AZ `$0.01/GB` 방향 | **수정** (범위·제안) | 문항 1(`q5`) + **md `saa-t4-4.md:107`**(같은 문장). 반면 md **81·324줄은 이미 「$0.01/GB (양방향)」** | 1차 제안 「$0.02/GB에 가깝다」는 철회. 레포 선례가 있다 — `saa_question_facts_test.dart:2093` 이 `saa-t4-4-q12` 에 `required: ['송신 측 1 GB 기준', '양방향']` 을 걸었다. **같은 방식(방향 한정)** 이 맞고, md 81·324줄이 그 문구를 이미 갖고 있으므로 107줄과 q5를 거기에 맞춘다 |
| P3-7 | `saa-t3-8-q4` 두 터널 「부하 분산」 | **수정** (범위 확대) | 문항 1 + **md `saa-t3-8.md:194`**(같은 문장). md 445줄은 올바르게 「고가용성을 위해 동시에 사용」 | `VPC_VPN.html` 재읽기: *「simultaneously use for high availability」* — 「부하 분산」 0건. 같은 md 안에서 194줄과 445줄이 다르다 |
| P3-8 | 과도한 일반화 4건 | **수정** (**2건 P1로 승격**, 2건 확정) | 아래 §3-1 | `t4-4-q7` 「Interface Endpoint를 쓸 이유가 없습니다」 — **레포가 `saa-t4-4-q6` 에 `forbidden` 으로 등록한 바로 그 문자열**이 q7 wrong[2] 와 md 144줄에 그대로 있다 · `t3-4-q5` 「메모리 설정이 유일한 성능 손잡이」 — **md는 2026-10-19 에 「주된(principal)」으로 정정**(`saa-t3-4.md:581` 노트, 공식 *「Memory is the principal lever」* 재확인)했는데 문항이 옛 문구 |
| P3-9 | 소개 출처 92건(미검수 65) | **수정** (비율 추정 보정) | — | 65건 중 **수치를 단정하는 14건**을 추려 그중 **8건의 소개 페이지를 실제로 읽었다**. 담고 있음 5(Step Functions 2,000/100,000/5분 · Lambda 15분 · DynamoDB 3 AZ · TGW 어태치먼트 시간당+처리량 · RDS Welcome Multi-AZ 유형) / **담고 있지 않음 3**(§2-2). 「92건을 일괄 교체」가 아니라 **「수치 단정 문항부터 한 건씩, 대략 3분의 1이 교체 대상」** 으로 좁힌다 |
| §6-4 | `saa-t2-4-q1` HA/FT 정의 귀속 (1차 보류) | **신규로 확정** → §2-1 | — | — |
| §6-5 | `saa-t3-9-q5` Firehose→Redshift (1차 「인용 페이지에서 못 찾음」) | **기각** (1차 한계 판정이 틀림) | — | 인용 페이지 `firehose/latest/dev/what-is-this-service.html`(2,971자 전문)에 *「For Amazon Redshift destinations, streaming data is delivered to your S3 bucket first. Amazon Data Firehose then issues an Amazon Redshift **COPY** command」* 가 **있다.** 1차의 「못 찾음」은 탐침 실패였다. 문항·출처 모두 정확 |

---

## 2. 신규 발견

### 2-1. [P3 · C축 귀속] `saa-t2-4-q1` + `saa-t2-4.md:97,105` — 「내결함성 = 완전 무중단」을 Reliability Pillar 출처로 귀속

**1) 위치**
- `saa-t2-4.questions.json` — `saa-t2-4-q1` (`verified:true`, `correct: 1`), 정답 보기·해설·wrong[0]·wrong[2]
- `saa-t2-4.md:97` 표 행 / `:105` 🧠 원리 블록

**2) 현재 문구**
- q1 정답 보기: 「HA는 짧은 중단 후 자동 복구를 목표로 하고, **내결함성은 장애 중에도 완전 무중단을 유지**하며, DR은 RTO/RPO 목표로 리전 단위 재해를 다룬다」
- md:97: 「| **내결함성(Fault Tolerance)** | 장애 중에도 **완전 무중단** 지속 | 능동 이중화로 중단 없이 계속 동작 | 높음 |」
- q1 출처: `AWS Well-Architected Framework — Reliability Pillar (공식)` → `wellarchitected/latest/reliability-pillar/welcome.html`

**3) 왜 문제인지**
세 개념을 「짧은 중단 허용 / 완전 무중단 / 리전 재해」로 가르는 분류는 **저작자의 교과서식 분류**이고, 인용한 공식 페이지는 그런 정의를 담지 않는다. 가장 가까운 공식 정의는 다른 백서에 있고 **내용도 다르다** — 내결함성을 「무중단」이 아니라 「SLA 안에서 가용성을 유지」로 정의한다.

**4) 공식 URL + 실측 근거 (「없다」 5단계)**
- 인용 페이지 `reliability-pillar/welcome.html`(1,925자 **전문**): 「fault tolerance」·「high availability」 정의 **0건**. 대조군 `six pillars` 1건.
- `reliability-pillar/availability.html`(6,661자 전문): Availability를 **백분율**로만 정의. FT/HA 대비 0건.
- 공식 문서 검색 2회(`fault tolerance high availability definition` / `fault tolerant … without interruption`): Reliability Pillar 안에서 정의 페이지 없음. 최상위 결과는 **Availability and Beyond** 백서 —
  <https://docs.aws.amazon.com/whitepapers/latest/availability-and-beyond-improving-resilience/fault-tolerance-and-fault-isolation.html>:
  *「Fault tolerance is the ability to withstand subsystem failure and maintain availability (doing the right thing **within an established SLA**). … another picks up its work, **typically almost seamlessly**.」*
  → 「완전 무중단」이 아니라 「SLA 범위 내 가용성 유지, 보통 거의 끊김 없이」다.
- 동의어 탐침: `fault-tolerant`, `no interruption`, `zero downtime` — Reliability Pillar 범위에서 정의문 0건.

**5) 제안**
정답 인덱스·보기 구조는 유지 가능하다(문항은 세 개념의 **상대 서열**을 묻고, 그 서열 자체는 틀리지 않았다). 고칠 것은 **귀속**이다 — ① md:97·105 와 q1 해설의 「완전 무중단」을 공식 문구에 맞춰 「SLA 안에서 가용성을 유지(거의 끊김 없이)」로 완화하고 ② 출처에 Availability and Beyond 의 해당 페이지를 추가한다. ③ 「이 세 갈래 분류는 시험 대비용 정리」임을 md 에 한 줄 적는다(레포의 C축 규율).

**기존 가드 충돌**: 없음(`내결함성`·`완전 무중단` 을 단정하는 가드 0건).

### 2-2. [P2 · 출처 적합성] 소개 페이지가 수치를 담지 않는 문항 3건 (1차 P3-9 표본 실측에서 확정)

> ⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-n).** 첫 행이 **`saa-t2-3-q10`·`q11`
> 둘이 1시간·48시간을 단정한다**고 적었으나 **수치를 단정하는 것은 `q11` 하나**다(`q10` 본문에
> 숫자가 없다 — 과대). `q10` 의 출처도 `lifecycle-hooks.html` 로 바꿨지만 그것은 **수치 때문이
> 아니라** 소개 페이지가 그 문항의 기제(`Pending:Wait` · `CONTINUE`)를 적지 않기 때문이다.
> 가드에 **「`q10` 이 수치를 단정하지 않는다」**를 단정으로 남겨, 나중에 수치가 들어오면 알린다.
> ⭐ **`lifecycle-hooks.html` 한 페이지가 `one hour by default` · `48 hours` · `100 times` 를 모두
> 담는다**(실측) — 두 수치를 위해 두 출처를 달 필요가 없었다. 나머지 두 행은 확정이고,
> `saa-t3-9-q4` 는 Firehose 소개가 그 문항의 다른 주장을 담으므로 **교체가 아니라 추가**했다.

| 문항 | 단정 수치 | 인용 페이지(실측) | 페이지에 있는가 | 정본 후보 |
|---|---|---|---|---|
| `saa-t2-3-q10`·`q11` | 수명 주기 훅 기본 **1시간·최대 48시간** | `autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html`(7,652자) | **없음** — 「Lifecycle hooks」 항목은 기능 소개 한 문단뿐, 수치 0건 | `autoscaling/ec2/userguide/lifecycle-hooks.html` — *「default timeout … one hour (heartbeat timeout) … global timeout is 48 hours or 100 times the heartbeat timeout, whichever is smaller」* (전문 확인). ⚠️ **수치 자체는 맞다.** md `saa-t2-3.md:266-267` 은 이미 이 정본을 근거 14번으로 인용 |
| `saa-t3-9-q4` wrong[1] | KDS 보존 **최대 365일** | `streams/latest/dev/introduction.html`(4,840자 전문) | **없음** — 보존 기간 수치 0건 | `streams/latest/dev/kinesis-extended-retention.html`(이미 다른 문항이 인용) 또는 KDS FAQ *「up to 365 days」* |
| `saa-t4-2-q3` | Compute Savings Plans **최대 66%** | `savingsplans/latest/userguide/what-is-savings-plans.html`(1,825자 전문) | **없음** — 이 페이지는 **「up to 72%」**(전체 상한)만 적는다 | `savingsplans/latest/userguide/sp-ris.html` — 비교 표 *「Compute Savings Plans … Up to 66%」* |

셋 다 **사실은 맞고 인용 페이지가 그 사실을 담지 않는** 유형(2차 검수 §D와 동일 클래스). 정답 인덱스 불변.

---

## 3. 1차가 과대·과소였던 것

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR)** — 이 절의 P1-5 범위가 **아직 적게 세었다.** 1차·2차가 모두 「`saa-t4-4-q7` wrong[0] + `saa-t4-4.md:144`」로 적었으나, 반영 때 가드를 **자격증 24파일 전수 집계**로 두자 **`saa-t4-4-q4` wrong[2]**가 걸렸다(`verified: true` 라이브). 두 패스가 함께 놓친 이유는 **조사 한 글자**다 — `q7` 은 `Interface Endpoint로 쓸 이유가`, `q4` 는 `Interface Endpoint를 쓸 이유가` 이고, 레포가 `saa-t4-4-q6` 에 등록한 금지 문자열은 후자 쪽이다. `grep` 한 번으로 보이는 자리였는데 **보고서의 문구를 그대로 탐침으로 쓴 것**이 원인이다. **어형이 갈리는 주장은 조사·어미를 바꿔 다시 센다.** 남은 P1(CLF·SOA·DEA·MLA·AIF)과 이 보고서의 P2·P3 를 집을 때도 같은 규율을 적용할 것 — 이 보고서가 적은 범위는 **하한**이다.

### 3-1. 과소 — P3 로 둔 2건은 P1 이다 (「다른 자리는 고쳐졌는데 여기만 옛 서술」 패턴)

| 항목 | 1차 | 2차 | 근거 |
|---|---|---|---|
| `saa-t4-4-q7` wrong[0] 「S3를 Interface Endpoint로 쓸 이유가 없습니다」 + `saa-t4-4.md:144` 「… Interface Endpoint를 쓸 이유가 없습니다」 | P3 (일반화 소형) | **P1** | `saa_question_facts_test.dart:2082` — `saa-t4-4-q6` 에 `forbidden: ['Interface Endpoint를 쓸 이유가 없습니다']`, 이유: *「공식 비교 표는 Gateway Endpoint 를 "온프레미스에서 접근 불가 · 다른 AWS 리전에서 접근 불가" 로 … 온프레미스·타 리전에서는 Interface Endpoint 가 필요하다」*. **레포가 거짓으로 판정해 q6 에서 금지한 문자열이 바로 옆 q7 과 md 에 글자 그대로 살아 있다.** `grep -c` 로 q7 파일 1건·md 1건 확인 |
| `saa-t3-4-q5` 해설 「메모리 설정이 **유일한** 성능 손잡이입니다」 | P3 | **P1** | md `saa-t3-4.md:228,288,481` 은 전부 **「주된(principal) 손잡이」**, 581줄 정정 노트: *「"유일한" 손잡이로 적었던 표현을 공식 서술("Memory is the principal lever")에 맞춰 주된 손잡이로 고쳤습니다」*(2026-10-19). 공식 `configuration-memory.html` 재읽기: *「Memory is the principal lever for controlling the performance」*. **md 정정이 파생 문항에 전파되지 않았다** — P1-1 과 같은 유형(방향만 반대) |

**제안**: q7 wrong[0] → 「같은 리전 VPC 안에서는 무료인 Gateway Endpoint가 유리하고, 온프레미스·다른 리전에서 S3에 닿으려면 Interface Endpoint가 필요합니다」(q6 과 같은 어조) · md:144 같은 문장 동일 수정 · q5 「유일한」→「주된」. **가드 보강**: `saa_question_facts_test` 의 q6 금지 문자열을 **q7 에도** 거는 것이 가장 싸다.
**기존 가드 충돌**: 없음.

### 3-2. 과소 — 범위를 「문항 1곳」으로 적었으나 md 에도 같은 문장이 있던 것 (컨트롤러 지적 패턴)

| 1차 항목 | 1차 범위 | 실제 범위 |
|---|---|---|
| P3-5 절대 단가 | 문항 3 | 문항 3 + md `saa-t4-4.md:107`(같은 문장) |
| P3-6 교차 AZ 방향 | 문항 1 | 문항 1 + md `:107` (단 md `:81`·`:324` 는 이미 「양방향」) |
| P3-7 터널 부하 분산 | 문항 1 | 문항 1 + md `saa-t3-8.md:194` |
| P3-8 Interface Endpoint | 문항 1 | 문항 1 + md `saa-t4-4.md:144` |
| P1-3 Multi-AZ 단정 | 문항 1(해설) | 문항 **3**(q1 해설 · q2 wrong[0] · q15 wrong[0]) |
| P2-1 (a) Fargate 슬러그 | 문항 6 + md 2 | 동일하되, **같은 Task `saa-t3-4` 의 md 는 정본·문항은 은퇴** 라는 Task 내부 드리프트 추가 |

### 3-3. 과대 — 1차 판정을 거둬들이는 것

- **P1-3 의 「출처 적합성도 약하다」** — 틀렸다. `Welcome.html` 은 Multi-AZ DB 클러스터의 읽기 서빙을 명시한다. 출처 교체 제안 철회(§1).
- **P3-6 의 「추가분은 $0.02/GB에 가깝다」** — 내 추론이었고 레포 선례(`q12` 가드)는 「송신 측 기준·양방향 한정」이다. 수치 제안 철회, 방향 한정으로 교체.
- **§6-5 `saa-t3-9-q5`** — 「인용 페이지에서 못 찾았다」는 탐침 실패였다. 문항·출처 정확(§1 기각).

### 3-4. 1차 「측정 한계」 중 2차에서 닫은 것 / 여전히 남은 것

| 1차 §6 | 2차 |
|---|---|
| 6-2 md 20편 통독 안 함 | **부분 해소** — 24편 **자가 점검 블록 전수**(64개 강한 단정 줄)를 읽었다. 새 결함 0건(P1-1·P1-2 외). 본문 통독은 여전히 미실시 |
| 6-4 `t2-4-q1` HA/FT | **해소** → §2-1 |
| 6-5 `t3-9-q5` | **해소** → 기각 |
| 6-1 가드 언급 182문항 정독 안 함 | **기계 전수로 보강** — md 가드 `isFalse` 리터럴 310개 × 문항 360개 = 유효 탈출 **0**(히트 8건은 전부 다른 문맥의 우연 일치: `ap-northeast-2` 리전 금지는 md 특정 절 한정, `Oracle·SQL Server 5` 는 「t2-1 에 복제하지 말라」는 드리프트 방지 가드라 정본 `t3-5-q2` 의 보유는 정당, `되돌릴 수 있습니다` 는 Recycle Bin 문맥). 정독은 여전히 미실시 |

---

## 4. 측정 한계

1. **182 가드 언급 문항의 개별 사실 정독은 이번에도 하지 않았다.** 기계 전수(§3-4)로 「md에서 금지된 문구」 잔존은 0으로 닫았지만, 가드가 걸지 않은 사실 오류는 이 방법으로 보이지 않는다.
2. **소개 출처 65건 중 8건만 페이지를 읽었다**(수치 단정 14건 중). 나머지 57건은 「페이지가 사실을 담는가」를 재지 않았다. 표본 8건의 **3/8 이 담지 않음**이라 전수 시 10~20건이 더 나올 수 있다.
3. **md 본문 통독은 4편 그대로**다. 자가 점검 블록만 24편 전수.
4. `saa-t2-4-q1` 의 HA/FT 분류가 **시험 출제 관행**과 맞는지는 판정하지 않았다 — 이 보고서는 「공식 정의와 다르고 출처에 없다」(귀속)만 말한다.
5. 요금 페이지의 **실제 요율**은 여전히 본문 추출로 검증할 수 없다(§1 P3-5 는 「인용 페이지에 수치가 없다」까지).
6. `flutter test`·`analyze` 미실행(지시). 가드 충돌은 정적 대조.

---

## 부록 — 재현

```bash
# 1차 P3-8 승격 근거: q6 에서 금지된 문자열이 q7·md 에 남아 있다
grep -n 'Interface Endpoint를 쓸 이유가 없습니다' \
  flutter_app/test/saa_question_facts_test.dart \
  flutter_app/assets/content/saa/saa-t4-4.questions.json \
  flutter_app/assets/content/saa/saa-t4-4.md

# 역전파: md 는 「주된」, 문항은 「유일한」
grep -n '손잡이' flutter_app/assets/content/saa/saa-t3-4.md flutter_app/assets/content/saa/saa-t3-4.questions.json

# P1-3 범위 3문항
grep -n '스탠바이는 읽기를 제공하지 않습니다' flutter_app/assets/content/saa/saa-t3-5.questions.json
```
