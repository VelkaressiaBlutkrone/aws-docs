# CLF-C02 · DVA-C03 콘텐츠 전수 검토 — 2026-11-06

> 담당: CLF-C02(학습문서 19편 · 문항 301개, **전부 `verified:true` 라이브**) · DVA-C03(학습문서 12편, **미등재 — 라이브 아님**).
> 다른 자격증(SAA·SOA·DEA·MLA·AIF)은 다른 세션이 맡는다. 이 보고서는 **읽기 전용 검토**이고 어떤 파일도 수정하지 않았다.

## 0. 검토 계획

### 0-1. 왜 이 순서인가

우선순위는 **학습자가 지금 보고 있는 것**이다.

1. **CLF 문항 301개** — 301개 전부 `verified:true`로 라이브 노출 중이다. 틀린 문항은 틀린 지식을 **적극적으로 주입**한다.
2. **CLF 학습문서 19편** — 라이브. 문항의 상위 소스이고, 여기서 틀리면 파생 문항과 **오디오 대본·음성**까지 번진다.
3. **DVA 학습문서 12편** — `content_index` 미등재라 사이트에서 404다(정상). 2026-12-01 이후 전환 PR로 공개되므로 **공개 전에 고칠 유일한 기회**다.

CLF를 먼저 끝내고 DVA로 간다. 시간이 부족하면 깊이를 줄이지 않고 **범위를 줄여** §6에 적는다.

### 0-2. 단계와 측정 명령

| 단계 | 무엇을 | 측정 명령·방법 |
|---|---|---|
| S1 기존 계약 파악 | 이미 `expect`로 못박힌 문구를 먼저 안다 | `flutter_app/test/` 의 `content_format_test` · `content_enrichment_test` · `clf_supplement_questions_test` · `quicksight_naming_consistency_test` · `content_index_audio_test` · `source_url_retired_test` · `dva_doc_format_test` · `all_content_parse_test` 통독 |
| S2 과거 감사 대조 | 닫힌 항목을 다시 보고하지 않는다 + **"고쳤다"가 사실인지 실측** | `docs/audits/2026-07/03-docs-facts.md` 의 CLF 26건(H2·M9·L15)을 전건 뽑아 현재 파일에 `grep` |
| S3 기계 스윕 | 사람 눈으로 셀 수 없는 것 | 파이썬 전수 스캔: 정답 인덱스 분포 · 작성 과정 메모 · 과도한 일반화 어휘 · 중복 문항 · 표기(`[텍스트](링크)`·단일 `*이탤릭*`) · 정답 보기 본문 중복 |
| S4 출처 전수 실측 | URL이 살아 있는가 | 고유 URL **390개**(CLF 155 · DVA 241)를 `curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}"` 로 전수. **대조군 3개를 먼저 재서 측정이 유효함을 확인** |
| S5 사실 검증 | 인용한 사실이 그 페이지에 **있는가** | `aws___search_documentation` / `aws___read_documentation` 로 공식 본문을 직접 읽고 대조. 수치·상한·기본값·요금 모델을 중점 |
| S6 전파 추적 | CLF는 대본·음성까지 번진다 | md에서 찾은 오류 문구를 `assets/audio/clf/*/script.json` 전수 `grep` |
| S7 내부 일관성 | 문서↔문항↔대본, 문서 간 | 같은 사실의 표현을 전수 `grep` 해 서로 어긋나는 자리를 찾는다 |

### 0-3. 측정 규율 (실행하며 지킨 것)

- **URL 판정 신호는 세 갈래다.** `200 r=0` 만 통과. `200 r=1` 은 **있는 가이드 안의 없는 슬러그**(그 인덱스로 보냄), 진짜 `404 r=0` 은 **가이드·접두사 자체가 없음**, `403` 은 미제공 인덱스이거나 **봇 차단**(별도 확인). `-L` 이 없으면 `num_redirects` 가 항상 0이므로 `-sL` 필수.
- **대조군 없이 "공식에 없다"를 말하지 않는다.** 추출 둘(태그 벗긴 본문·원시) · 그 페이지에 분명히 있는 문구를 같은 방법으로 세기 · 동의어 · **표·목록의 열 구조** · md가 영문을 인용하면 그 인용문으로 먼저 검색.
- **개수를 믿지 않는다.** "N곳에 있다"는 전부 `grep` 전수로 센다.
- **「목록에 없다」 ≠ 「범위 밖」.** 공식 범위 목록은 전체 목록이 아니다.
- **공식이 갈리면 단정하지 않는다.** 더 구체적인 전용 페이지를 정본으로 삼고, 고를 수 없으면 양쪽 URL을 함께 적는다.
- **조사 노트·과거 보고는 단서이고 정본이 아니다.** 실제로 이 검토에서 2026-07 감사의 판정 하나가 **거꾸로**였음을 확인했다(§5 참조).

### 0-4. 실행하며 달라진 점 (실행 로그)

1. **S4(출처 실측)를 두 번 돌렸다.** 1차는 백그라운드 셸에서 돌렸는데 **390개가 전부 `000 r=0`**으로 나왔다. 대조군이 0이므로 **측정 무효**로 판정하고(네트워크 미연결) 포그라운드에서 전량 재측정했다. 재측정에서는 대조군 셋이 문서대로 나왔다(`200 r=1` / `404 r=0` / `200 r=0`).
2. **대본 전파 추적의 판정 기준을 바꿨다.** 처음에는 `script.json`의 모든 필드를 한 덩어리로 검색했는데, 그러면 **발화되지 않는 `sourceExcerpt`가 발화문처럼 잡힌다.** `gen_lecture_audio.py`의 `_spoken_body`를 읽고 **`kind == table`이면 `audioSummary`, 그 밖에는 `enrichedScriptText` → `scriptText`** 순으로 실제 발화 텍스트만 보도록 고쳤다(§7 참조 — 이 때문에 판정이 두 번 뒤집혔다).
3. **CLF 시험 가이드 전문 대조를 계획에 없던 단계로 추가했다.** t4-3의 「정직성 메모」가 *"공식 시험 가이드가 전통적 분류를 명시한다"*고 단정하고 있어서 그 단정 자체를 검증해야 했고, 그 과정에서 **레포 `exam_guides/CLF-C02.json`이 공식 개정판과 6곳 다르다**는 것이 드러났다(§2·§3).
4. **DVA는 전문 통독 대신 축별 전수 검사로 돌렸다.** 12편이 2026-11-02 저작본이고 조사 노트(`docs/content-research/DVA-C03/`)의 미확인 항목(G-11~G-18)을 실제로 피해 저작한 것을 확인했기 때문에, 깊이를 **수치·범위·출처·프런트매터**에 집중했다. 못 본 범위는 §6에 적었다.

---

## 1. 집계

### 1-1. 대상 규모 (실측)

| | 학습문서 | 문항 | 오디오 대본 | 고유 출처 URL |
|---|---|---|---|---|
| **CLF-C02** | 19편 (411 KB) | **301개 · 전부 `verified:true` 라이브** | 19편 (`assets/audio/clf/*/script.json`, 전부 `reviewStatus: approved`) | 155 |
| **DVA-C03** | 12편 (516 KB) | **0개** | 없음 | 241 |
| 합계 | 31편 | 301 | 19 | **390** (중복 제외 후 실측 대상 387 + 대조군 3) |

### 1-2. 발견 건수

| 우선순위 | CLF-C02 | DVA-C03 | 계 |
|---|---|---|---|
| **P1 — 라이브 사실 오류** | **4** | 0 (미등재라 라이브 아님) | 4 |
| **P2 — 출처 결함·범위 결함** | **9** | **2** | 11 |
| **P3 — 보강 후보** | **8** | **3** | 11 |
| 계 | 21 | 5 | **26** |

### 1-3. 출처 URL 실측 결과

| 신호 | 건수 | 판정 |
|---|---|---|
| `200 r=0` | **375** | 정상 |
| `200 r=1` | 11 | 슬러그 소멸 또는 이름 변경 |
| `200 r=2` | 2 | 가이드 구조 재편 |
| `404 r=0` | 1 | **대조군**(의도한 값) |
| `403 r=0` | 1 | `repose.aws/knowledge-center` — 봇 차단 추정, §6 |

대조군 3개가 문서대로 나왔으므로 측정은 유효하다.
- `docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html` → `200 r=1 -> .../sagemaker/latest/dg/`
- `aws.amazon.com/what-is/zz-bogus-control/` → `404 r=0`
- `docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html` → `200 r=0`

### 1-4. 오디오 전파

**음성까지 번진 결함이 2계열 · 발화 세그먼트 4곳**이다(§2-1·§2-3). 대본 텍스트만 봤고 mp3는 듣지 않았다(§6).

---

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR)** — 공식 재측정 결과 이 절의 범위가 **양방향으로** 달라졌다.
>
> 1. **P1-4 의 `clf-t4-3` seg030 은 결함이 아니다.** 1차·2차가 모두 발화 세 곳(seg014·026·030)으로 적었지만, seg030 의 발화문은 「전통적인 비즈니스와 디벨로퍼 플랜은 2027년 1월 1일에 단종될 예정」으로 **현행 공식 `aws-support-plans.html` 의 End of Support Notice 와 정확히 일치한다.** 보고를 그대로 따랐다면 **옳은 문장을 고쳤다.** 반영 PR 의 가드는 그 문장을 **지키는** 대조군을 둔다.
> 2. **`t4-3.md:119` 와 seg026 도 고치지 않았다.** 둘은 「공식 가이드가 전통 분류를 명시한다」가 아니라 「시험 대비로는 전통 분류인 Business 를 …」이라는 **출제 관행 서술**이다 — 2차 패스가 문항 `q2`·`q7`·`q11` 의 같은 병기를 「옳은 병기이고 결함이 아니다」로 판정한 것과 같은 성격이다. 거짓인 것은 **가이드에 귀속시킨 단정**뿐이므로 `t4-3.md:77` 과 seg014 만 고쳤다.
> 3. **§P2-H 「500+ 점검」의 근거를 찾았다.** 이 보고서는 「인용 페이지(`aws-support-plans.html` 외)에 수치가 없다」고 적었으나, 현행 `aws-support-plans.html` 의 **Business Support+ 절**이 `More than 500 checks with AWS Trusted Advisor` 를 **그대로 싣는다**(2026-11-06 실측). 「없다」는 또 「못 찾음」이었다 — P2-H 는 등급을 내려 재검토할 항목이다.
> 4. **보고서가 인용한 md 원문이 낡았다.** P1-3 의 인용은 `**2024년 이후 *신규 고객 등록을 중단***` (이탤릭 포함)인데 **현재 md 는 2026-10-29 이탤릭 평문화를 거쳐** `**2024년 이후 신규 고객 등록을 중단**` 이다. 대본(`script.json`)은 평문화 **이전** 스냅샷이라 이탤릭이 남아 있어, **같은 문장이 파일마다 다른 바이트**였다. 치환 단정이 이것을 잡아 중단시켰다 — **보고서의 인용을 그대로 탐침·치환에 쓰지 말고 실제 바이트를 먼저 확인한다.**

## 2. P1 — 라이브 사실 오류 (즉시 수정 대상)

> CLF 4건. **DVA는 `content_index` 미등재라 라이브가 아니므로 P1이 없다**(미등재는 §4-D에서 실측으로 확인했다).

### P1-1. 「도메인 2가 시험 비중 30%로 가장 크다」 — 학습문서 3편 + **음성 3편**

**① 위치**
- `flutter_app/assets/content/clf/t2-1.md:45`
- `flutter_app/assets/content/clf/t2-2.md:65`
- `flutter_app/assets/content/clf/t2-3.md:59`
- 발화 전파: `assets/audio/clf/clf-t2-1/script.json` seg006 · `clf-t2-2/script.json` seg006 · `clf-t2-3/script.json` seg006 (세 곳 모두 `enrichedScriptText`이므로 **mp3에 들어 있다**)

**② 현재 문구 (그대로 인용)**

```
t2-1.md:45  - **도메인 2는 시험 비중 30%로 가장 큽니다.** 그리고 공동 책임 모델은 이 도메인의 **대전제**입니다 …
t2-2.md:65  - **도메인 2는 시험 비중 30%로 가장 크고, 이 Task는 그 안에서 "서비스 이름 매칭"이 가장 많이 나오는 곳입니다.** …
t2-3.md:59  - **도메인 2는 시험 비중 30%로 가장 크고, 접근 관리는 그 한가운데입니다.** …
```

발화문(clf-t2-3 seg006): `도메인 2는 시험 비중이 30퍼센트로 가장 큽니다. 그리고 그 한가운데에 바로 접근 관리가 있습니다. …`

**③ 왜 틀렸는지**

CLF-C02의 최대 비중 도메인은 **도메인 3(34%)**이다. 30%는 2위다. 게다가 같은 레포 안에서 **정면으로 모순**한다 — `t3-2.md:46`은 `도메인 3은 시험 비중 **34%로 가장 크고**`라고 적고 그 발화문(clf-t3-2 seg006)도 `도메인 3은 시험 비중이 34퍼센트로 가장 큽니다`로 말한다. **학습자가 네 편의 강의에서 「가장 큰 도메인」을 두 가지로 듣는다.**

**④ 공식 URL + 실측 근거**

`https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02.html` (「내용 개요」, 실측 2026-11-06)

> 콘텐츠 도메인 1: 클라우드 개념(채점되는 콘텐츠의 **24%**) / 도메인 2: 보안 및 규정 준수(**30%**) / 도메인 3: 클라우드 기술 및 서비스(**34%**) / 도메인 4: 결제, 요금 및 지원(**12%**)

레포 자신의 `assets/exam_guides/CLF-C02.json`도 `weightPct` 24·30·34·12로 **옳게** 들고 있다(실측). 즉 레포 안에 정답이 이미 있다.

**⑤ 제안 수정안**

세 자리의 `가장 큽니다`·`가장 크고`만 바꾼다. 나머지 문장은 건드리지 않는다.

- `t2-1.md:45` → `**도메인 2는 시험 비중 30%로, 도메인 3(34%)에 이어 두 번째로 큽니다.**`
- `t2-2.md:65` / `t2-3.md:59` → 같은 방식(`30%로 비중이 크고,`)
- ⚠️ **md를 고치면 대본·음성이 자동으로 따라오지 않는다.** 세 `script.json`의 해당 세그먼트(`sourceExcerpt`·`scriptText`·`enrichedScriptText`)를 함께 고친 뒤 **3편 재합성**이 필요하다(사람의 청취 승인 게이트 포함).

**기존 가드 충돌:** 없다. 이 문구를 `expect`로 묶은 테스트는 없다(`grep -rn "가장 큽니다" flutter_app/test/` → 0건).

**경위:** 2026-07 감사가 `DOC-CLF-002`(Phase A, 확신 「높」)로 **이미 지적했고 Phase A는 릴리스됐다고 기록돼 있는데 고쳐지지 않았다.** 그리고 당시 보고는 `t2-1` 한 곳으로 적었으나 **실제는 md 3곳 + 발화 3곳**이다 — 「보고된 개수를 믿지 않는다」가 또 맞았다.

---

### P1-2. Compute Savings Plans 할인율을 **72%**로 적은 라이브 문항 (문서·음성과 모순)

**① 위치** `flutter_app/assets/content/clf/t4-1.questions.json` — 문항 **`clf-t4-1-q2`** (`explanation` 및 `sources[0].title`)

**② 현재 문구**

```
explanation : … Compute Savings Plans는 인스턴스 패밀리·크기·OS·테넌시·리전과 무관하게 EC2에 적용되고
              Fargate·Lambda 사용에도 적용되어 유연합니다(최대 72% 절감).
source.title: What are Savings Plans? — 1/3년 사용량 약정, On-Demand보다 할인,
              EC2·Fargate·Lambda 유연 적용(최대 72%)
```

**③ 왜 틀렸는지**

**72%는 EC2 Instance Savings Plans의 수치**이고, 완전 유연한 **Compute Savings Plans는 최대 66%**다. 두 플랜의 트레이드오프(유연성 ↔ 할인율)가 이 Task의 출제 축인데, 해설이 **유연성과 최고 할인율을 한 플랜에 결합**해 그 축을 무너뜨린다. 2026-07 감사 `DOC-CLF-305`가 지적한 바로 그 결합이고, **학습문서 쪽은 이미 고쳐져 있어** 문서↔문항이 어긋난다.

```
t4-1.md:73   | **Savings Plans** | … | **최대 66~72%** | … **Compute SP** = … 최대 66% / **EC2 Instance SP** = … 최대 72% |
t4-1.md:126  - **Savings Plans**: … **Compute SP**는 … (최대 66%), **EC2 Instance SP**는 … 최대 72%.
```

그리고 **오디오도 이미 옳다** — `clf-t4-1/script.json` seg025의 `enrichedScriptText`가 `컴퓨트 세이빙스 플랜은 … 최대 66퍼센트를 할인하고, 이씨투 인스턴스 세이빙스 플랜은 … 최대 72퍼센트까지 할인합니다`로 말한다. **문항만 옛 서술에 남았다.**

**④ 공식 URL + 실측 근거** (네 페이지가 일치, 실측 2026-11-06)

- `https://docs.aws.amazon.com/savingsplans/latest/userguide/plan-types.html` — *"Compute Savings Plans … prices that are up to 66% off of On-Demand rates"* / *"EC2 Instance Savings Plans provide savings up to 72% off On-Demand"*
- `https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-ris.html` — 비교 표: Compute SP **Up to 66%** / EC2 Instance SP **Up to 72%**
- `https://aws.amazon.com/savingsplans/faqs/` · `https://aws.amazon.com/ec2/faqs/` — 같은 수치

**⑤ 제안 수정안**

- `explanation` → `…유연합니다(**최대 66% 절감** — 최대 72%는 패밀리·리전을 고정하는 EC2 Instance Savings Plans의 수치입니다).`
- `sources[0].title` → `What are Savings Plans? — 1/3년 사용량 약정, Compute SP 최대 66%(EC2·Fargate·Lambda 유연) / EC2 Instance SP 최대 72%`
- 함께: `t4-1.md:198` 참고자료 항목도 `(약정 기반 할인, **최대 72%**, EC2·Fargate·Lambda)`로 같은 결합을 하고 있어 `(Compute SP 최대 66% / EC2 Instance SP 최대 72%)`로 정밀화한다.
- ⚠️ `correct` 인덱스는 **바뀌지 않는다**(정답은 Savings Plans 그대로).

**기존 가드 충돌:** 없다. `flutter_app/test/`에서 `72%`는 2건 걸리지만 **둘 다 SAA 전용**이고 **예약 인스턴스** 수치다 — `saa_question_propagation_test.dart:391`(`Convertible RI는 최대 66%, Standard RI는 최대 72%다`) · `saa_t2_t4_facts_test.dart:478`. Savings Plans를 묶은 CLF 가드는 없다.

---

### P1-3. Audit Manager 신규 중단을 「2024년 이후」로, 그리고 「공식 가이드가 명시한다」로 — 학습문서 + **음성**

**① 위치**

- `flutter_app/assets/content/clf/t2-2.md:223`
- 발화 전파: `assets/audio/clf/clf-t2-2/script.json` **seg051**(`enrichedScriptText` — **mp3에 들어 있다**). 같은 오류가 그 파일 안에 `sourceExcerpt`·`scriptText`·`enrichedScriptText` **3개 필드**로 들어 있다.

**② 현재 문구**

```
t2-2.md:223  > ℹ️ 정직성 메모: AWS Audit Manager는 **2024년 이후 *신규 고객 등록을 중단***했습니다(기존 고객은 계속 사용).
             다만 **CLF 공식 시험 가이드는 Audit Manager를 거버넌스 서비스로 명시**하고 있어, 시험엔 여전히
             "감사 증거 수집 자동화 = Audit Manager"로 등장할 수 있습니다. …
```

발화문(seg051): `에이더블유에스 Audit Manager는 2024년 이후로 신규 고객 등록을 중단했습니다. … 씨엘에프 공식 시험 가이드가 Audit Manager를 거버넌스 서비스로 명시하고 있거든요.`

**③ 왜 틀렸는지 — 한 문장에 오류가 둘이다**

1. **연도가 2년 틀렸다.** 공식 공지는 **2026-04-30**이다. 「2024년 이후」로 적으면 학습자가 *"2년 전에 닫힌 서비스를 아직 가르치나"*로 읽고, **지금이 막 닫힌 직후**라는 맥락을 잃는다.
2. **「공식 가이드가 명시한다」가 이제 거짓이다.** 공식 CLF-C02 가이드 작업 2.2의 관련 기술은 현재
   `거버넌스 및 규정 준수를 지원하는 서비스 이해(예: Amazon CloudWatch를 통한 모니터링, AWS CloudTrail, AWS Config를 통한 감사, 액세스 보고서를 통한 보고)`
   이고 **Audit Manager가 없다.** 레포 `exam_guides/CLF-C02.json`의 같은 항목만 `… AWS CloudTrail, **AWS Audit Manager 및** AWS Config를 통한 감사 …`로 옛 개정판을 들고 있다(§3-C).

**④ 공식 URL + 실측 근거**

- `https://docs.aws.amazon.com/audit-manager/latest/userguide/what-is.html` — 페이지 최상단 배너: *"AWS Audit Manager is no longer open to new customers. Existing customers can continue to use the service as normal."*
- `https://aws.amazon.com/audit-manager/` — *"AWS Audit Manager will no longer be open to new customers starting on **4/30/2026**."*
- `https://aws.amazon.com/about-aws/whats-new/2026/03/aws-service-availability/` — 2026-04-30 유지 관리 전환 목록에 `AWS Audit Manager` 포함
- `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain2.html` — 작업 2.2 관련 기술 전문(위 인용). **Audit Manager 0건**

**⑤ 제안 수정안**

```
> ℹ️ 정직성 메모: AWS Audit Manager는 **2026-04-30부터 신규 고객에게 열려 있지 않습니다**(기존 고객은 계속 사용).
  **CLF-C02 공식 시험 가이드도 작업 2.2의 예시에서 Audit Manager를 뺐습니다** — 지금은 CloudWatch·CloudTrail·Config가
  그 자리입니다. 다만 개념(증거 수집 자동화 + 프레임워크 매핑)은 Artifact와의 대비로 여전히 유용하니 구분만 기억해 두세요.
```

- 함께 `clf-t2-2/script.json` seg051의 세 필드를 고치고 **clf-t2-2 재합성**이 필요하다.
- 같은 변경이 문항 `clf-t2-2-q10`에도 걸린다(§3-F — 닫힌 서비스가 정답).

**기존 가드 충돌:** 없다. `flutter_app/test/`에서 `Audit Manager`는 1건 걸리지만 **`aif_guide_v11_test.dart:278`의 AIF 금지 문구 목록**이고 CLF 콘텐츠를 보지 않는다. ⚠️ **다만 AIF 쪽에도 같은 서비스의 상태 서술이 있으므로**(AIF는 Audit Manager를 「닫힌 서비스 4종」의 하나로 다룬다) 이 수정은 **AIF 담당 세션의 발견과 교차 확인**할 가치가 있다.

---

### P1-4. 「CLF-C02 공식 가이드는 전통적 분류(Basic·Developer·Business·Enterprise)를 명시한다」 — 학습문서 2곳 + **음성 3곳**

**① 위치**

- `flutter_app/assets/content/clf/t4-3.md:77` (§1 「정직성 메모」)
- `flutter_app/assets/content/clf/t4-3.md:119` · `:134` (시험 직전 요약 — 「시험 대비로는 전통 분류인 Business를…」)
- 발화 전파: `assets/audio/clf/clf-t4-3/script.json` **seg014 · seg026 · seg030**(전부 `enrichedScriptText` — **mp3에 들어 있다**)

**② 현재 문구**

```
t4-3.md:77  > ℹ️ 정직성 메모: AWS는 Support 플랜을 **재편 중**입니다(공식 문서 기준, 2026): **Developer·Business·Enterprise On-Ramp**는
            **2027-01-01 단종** 예정이고, **Business Support+**·**Unified Operations**가 도입됐습니다(Enterprise는 TAM·15분 응답 유지).
            다만 **CLF-C02 공식 시험 가이드는 전통적 분류(Basic·Developer·Business·Enterprise)**를 명시하므로,
            시험 대비로는 위 4단계로 기억하면 됩니다.
```

발화문(seg014): `… 다만 우리가 준비하는 시험, 씨엘에프 씨 공이 공식 시험 가이드에서는 여전히 전통적인 분류를 명시하고 있습니다. 베이직, 디벨로퍼, 비즈니스, 엔터프라이즈 이렇게 네 단계예요. 그러니까 시험 대비로는 방금 말씀드린 이 네 단계로 기억하시면 됩니다.`

**③ 왜 틀렸는지**

메모의 **앞부분(재편 사실)은 정확하다**(아래 ④). 그러나 **「공식 시험 가이드가 전통적 분류를 명시한다」는 단정이 거짓이다.** 공식 가이드 작업 4.3의 관련 기술은 현재

```
AWS 고객을 위한 AWS 지원 옵션 파악(예: 고객 서비스 및 커뮤니티, 기본 지원,
AWS Business Support+, AWS Enterprise Support, AWS Unified Operations)
```

이다 — **Developer·Business·Enterprise On-Ramp가 모두 빠지고 Business Support+·Unified Operations가 들어왔다.** 즉 공식 가이드는 **신규 플랜**을 명시하는데 문서는 그 반대를 말하고, 그 결과 **학습자에게 「시험에는 옛 4단계로 외우라」고 지시한다.** 이것이 가장 해로운 형태다 — 사실 하나가 틀린 것이 아니라 **학습 전략을 틀린 방향으로 고정**한다.

이 단정은 `t4-3.md`의 표·시험 직전 요약과 문항 7건(`q1`·`q2`·`q6`·`q7`·`q10`·`q11`·`q13`)의 **설계 전제**이기도 하다(§3-E).

**④ 공식 URL + 실측 근거**

- `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02-domain4.html` — 작업 4.3 관련 기술 전문(위 인용). 실측 2026-11-06
- `https://docs.aws.amazon.com/awssupport/latest/user/aws-support-plans.html` — 현행 플랜 목록이 **`Basic` · `AWS Business Support+` · `AWS Enterprise Support` · `AWS Unified Operations`** 네 개이고, Developer·Business·Enterprise On-Ramp는 **2027-01-01 단종** 공지(메모 앞부분이 맞다는 근거). Enterprise는 *"designated TAM assignment, 15-minute response times … at a lower $5,000 minimum"*
- `https://aws.amazon.com/about-aws/whats-new/2025/12/aws-support-transformation-ai-powered-operations/` — 2025-12 발표, 세 유료 플랜(Business Support+ · Enterprise · Unified Operations)

**⑤ 제안 수정안**

```
> ℹ️ 정직성 메모: AWS Support 플랜은 재편됐습니다 — 현행 공식 플랜은 **Basic · Business Support+ · Enterprise ·
  Unified Operations** 네 가지이고, **Developer·Business·Enterprise On-Ramp는 2027-01-01 단종** 예정입니다
  (GovCloud(US)에는 남습니다). **공식 CLF-C02 시험 가이드도 작업 4.3의 예시를 신규 플랜으로 바꿨습니다.**
  다만 시중 기출·교재는 아직 전통 4단계로 출제하므로 **두 묶음을 대응시켜** 기억해 두세요:
  24x7 프로덕션 지원의 최소 플랜 = 전통 **Business** ≈ 현행 **Business Support+**,
  전담 TAM + 비즈니스 크리티컬 15분 = **Enterprise**(현행에서도 유지).
```

- `t4-3.md:119`·`:134`도 같은 틀로 정리한다.
- `clf-t4-3/script.json` seg014·seg026·seg030을 고치고 **clf-t4-3 재합성**.
- ⚠️ **메모의 앞부분(2027-01-01 단종 · Business Support+ · Unified Operations)은 정확하므로 지우지 않는다.** 바꿀 것은 「가이드가 전통 분류를 명시한다」는 한 절과 그에서 파생된 학습 지시뿐이다.

**기존 가드 충돌:** 없다(`grep -rn "전통" flutter_app/test/` → 0건).

---

## 3. P2 — 출처 결함 · 범위 결함

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR)** — 네 가지가 달라졌다.
>
> 1. **범위가 「CLF 10 · DVA 2」가 아니다.** 레포 전수로 세면 **33곳**이고, #2 Fargate 슬러그가 **SAA 7곳**(`saa-t2-2.md` ×2 · `saa-t2-2-q12·q13·q14` · `saa-t3-4-q1·q3·q11`)에 번져 있다. **자격증을 나눠 감사하면 공유 URL이 사각지대가 된다.**
> 2. **#9 Storage Gateway 는 정본이 하나가 아니다.** 2차가 「CLF 맥락은 S3 File Gateway」로 정했지만 **`clf-t3-6-q15` 의 인용은 Tape Gateway**다. 넷 다 files3 로 바꾸면 **그 페이지에 없는 사실을 인용**하게 된다. 인용별로 갈랐다 — `t3-6.md`·`q6` → **서비스 인덱스** `storagegateway/`(`200 r=0`, 통합 what-is 가 사라져 서비스 수준 정본이 그것이다), `q15` → `storagegateway/latest/tgw/WhatIsStorageGateway.html`.
> 3. **#3 은 URL 만 바꾸면 거짓 인용이 된다.** 정본 `free-tier.html` 에 **「12개월 무료」가 없고**, §P3-3 이 근거로 쓴 **「`aws.amazon.com/free` 는 여전히 세 유형으로 적는다」도 지금은 거짓**이다(목차 실측: `Free plan` · `Paid plan` · `Short-term trial` · `Always free`). 그래서 `clf-t4-1-q10` 의 지문·정답 보기·해설을 현행 구조로 고쳤다(**정답 인덱스 불변**). ⚠️ 보고서가 `repost.aws` 로 적은 **「2025-07-15 이후/레거시 12개월」은 공식 문서에서 확인하지 못해 쓰지 않았다.**
> 4. **§P2-B 가 확정됐다** — `repost.aws` 를 **브라우저 호환 UA** 로 재면 `200 r=1` 이다. `403` 은 **봇 차단이고 죽은 링크가 아니다.** `clf-t2-4-q15` 의 출처는 **그대로 둔다.** 아울러 **§P2-H 는 근거를 찾았으니 등급 하향 재검토 대상**이다(현행 `aws-support-plans.html` 의 Business Support+ 절에 `More than 500 checks with AWS Trusted Advisor` 가 있다).

### P2-A. 죽은 출처 URL 12개 (CLF 10 · DVA 2) — 문항 11건 + 학습문서 6편

**① 위치·② 현재 값·④ 실측 신호·⑤ 교체안**을 한 표에 담았다. 측정 명령은 §0-2 S4와 같고 **교체안도 전부 다시 재서 `200 r=0`을 확인**했다.

| # | 현재 URL (인용) | 실측 | 쓰는 곳 | 판정 | 교체안 (`200 r=0` 확인) |
|---|---|---|---|---|---|
| 1 | `https://aws.amazon.com/compliance/data-center/controls/` | `200 r=1` → `trust-center/data-center/our-controls/` | `clf-t2-1-q2` | 페이지 이동 | `https://aws.amazon.com/trust-center/data-center/our-controls/` — ⭐ **인용한 사실이 새 페이지에 그대로 있다**: 「Media Destruction」 절의 *"AWS decommissions media using techniques detailed in NIST 800-88"* |
| 2 | `https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html` | `200 r=1` → `AmazonECS/latest/developerguide/AWS_Fargate.html` | `t3-3.md`, `clf-t3-3-q4` | 가이드 디렉터리 + 슬러그 변경 | `https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html` |
| 3 | `https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-free-tier.html` | `200 r=1` → `aboutv2/` **인덱스** | `clf-t4-1-q10` | **페이지 소멸** | `https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html` ⚠️ **다만 내용이 달라졌다 — P3-3 참조** |
| 4 | `https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html` | `200 r=1` → `documentdb/latest/devguide/what-is.html` | `clf-t3-4-q9` | 가이드 디렉터리 개명 | `https://docs.aws.amazon.com/documentdb/latest/devguide/what-is.html` |
| 5 | `https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-retiring-applications/apg-7-rs.html` | `200 r=1` → 가이드 인덱스 | `t1-3.md`, `clf-t1-3-q11` | **페이지 소멸** | `https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/migration-strategies.html` — 「About the migration strategies」가 **7 Rs를 전부 열거**한다(Retire·Retain·Rehost·Relocate·Repurchase·Replatform·Refactor or re-architect) |
| 6 | `https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-retiring-applications/apg-migration-strategies.html` | `200 r=1` → 가이드 인덱스 | `clf-t1-3-q10` | **페이지 소멸** | 위 #5와 같은 페이지 |
| 7 | `https://docs.aws.amazon.com/quicksight/latest/user/welcome.html` | `200 r=2` → `quick/latest/userguide/what-is.html` | `t3-7.md`, `clf-t3-7-q7` | 개명(Quick Sight) | `https://docs.aws.amazon.com/quick/latest/userguide/what-is.html` — ⚠️ `quicksight_naming_consistency_test.dart`가 **이미 이 URL을 근거로 인용**하고 있다(그 가드와 같은 방향의 수정) |
| 8 | `https://docs.aws.amazon.com/snowball/latest/developer-guide/whatissnowball.html` | `200 r=1` → 가이드 인덱스 | `t1-3.md` + `clf-t1-3-q3`·`q8`·`q9`·`q14` (**문항 4건**) | **페이지 소멸 — 서비스 이름이 Snowball Edge로 좁혀졌다** | `https://docs.aws.amazon.com/snowball/latest/developer-guide/whatisedge.html` (실측 `200 r=0`). 참고로 `snowcone-guide/whatissnowcone.html`도 `200 r=1`(Snowcone 단종과 일치) |
| 9 | `https://docs.aws.amazon.com/storagegateway/latest/userguide/WhatIsStorageGateway.html` | `200 r=2` → `storagegateway/` | `t3-6.md` + `clf-t3-6-q6`·`q15` | **가이드가 게이트웨이 유형별로 분리됐다** | ⚠️ **정본 미확정.** `storagegateway/latest/vgw/WhatIsStorageGateway.html`(Volume Gateway)은 `200 r=0`으로 살아 있으나 CLF의 인용 맥락은 「캐시된 파일 시스템」이라 **S3 File Gateway 쪽 가이드**가 맞다. 컨트롤러가 인용별로 유형을 골라야 한다(§6) |
| 10 | `https://docs.aws.amazon.com/wellarchitected/latest/userguide/intro.html` | `200 r=1` → `wellarchitected/latest/userguide/` | `clf-t1-2-q12` | **페이지 소멸** | `https://docs.aws.amazon.com/wellarchitected/latest/userguide/tool.html` — 제목이 「What is AWS Well-Architected Tool?」로 인용 목적과 정확히 맞는다 (`what-is-wa-tool.html`은 `200 r=1`이므로 쓰지 않는다) |
| 11 | `https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/DDB-encryption-context.html` | `200 r=1` → `devguide/` 인덱스 | **DVA** `dva-t2-2.md:393` (참고자료 23) | **페이지 소멸** | `https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/DDB-encrypted-and-signed.html` — 제목이 인용 제목과 **글자 그대로 같다**(「Which fields are encrypted and signed?」) |
| 12 | `https://docs.aws.amazon.com/cli/latest/reference/aiops/index.html` | `200 r=1` → `reference/aiops/` | **DVA** `dva-t4-1.md:416` (참고자료 21) | 디렉터리 인덱스(같은 페이지) | `https://docs.aws.amazon.com/cli/latest/reference/aiops/` — **내용은 동일**하므로 위험도 최저. 다만 `source_url_retired_test.dart` 같은 `num_redirects` 가드를 전역으로 걸면 걸린다 |

**③ 왜 문제인지**
이 레포에서 반복된 결함은 **「URL은 200인데 그 페이지가 재구성돼 인용 문장이 더 이상 없는」** 경우다. 여기 12건은 그 전 단계 — 슬러그 자체가 사라져 **학습자가 각주를 눌러도 인덱스나 다른 페이지로 튕긴다.** 특히 #8은 **문항 4건 + 학습문서**가 같은 죽은 URL을 공유한다.

**기존 가드 충돌:** `source_url_retired_test.dart`의 은퇴 목록(22건)에 **이 12건은 하나도 없다.** 그 가드는 2026-10-29 SOA·DEA 감사에서 **그 두 자격증만** 실측해 만든 것이므로, CLF·DVA는 처음 재는 것이다. 교체 후에는 같은 패턴으로 **CLF·DVA 판 은퇴 가드**를 추가할 수 있다(옛 URL 0건 + 교체 정본 실재, 쌍으로).

---

### P2-B. `repost.aws/knowledge-center` — `403`

- **위치** `clf-t2-4-q15`의 `sources`
- **실측** `403 r=0`
- **판정 보류.** 이 레포는 과거에 `repost.aws`의 `403`이 **죽은 링크가 아니라 봇 차단**이었음을 확인한 이력이 있다. 나는 이번에 **브라우저로 열어 확인하지 못했다**(§6). 컨트롤러가 내장 브라우저로 한 번 열어 **봇 차단인지 실제 미제공인지** 가른 뒤 판정하면 된다. 참고로 `aws___read_documentation`은 `repost.aws/knowledge-center` 하위 페이지를 정상적으로 읽어 주므로(§5의 Free Tier 항목에서 실제로 읽었다) **사이트 자체는 살아 있을 가능성이 높다.**

---

### P2-C. 레포 `exam_guides/CLF-C02.json`이 **공식 개정판과 6곳 다르다**

> ⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-m).** **여섯 건은 그대로
> 확정**이고 공식 한국어 도메인 페이지 원문에서 바이트 그대로 재확인했다. 두 가지만 덧붙인다.
> ① **이 절이 인용한 URL `clf-02-domain-N.html` 은 죽은 슬러그다**(`200 r=1` → 가이드
> 인덱스, 일부러 틀린 슬러그와 같은 신호). 정본은 **`cloud-practitioner-02-domainN.html`**
> 이고 레포 JSON 이 한국어라 **`/ko_kr/` 판**으로 대조해야 한다.
> ② ⭐ **공식의 기계번역 잔재는 고치지 않는다** — Task 3.8 기술의 `프런트엔드 및 모바일
> 서비스를 **만들기하고** 배포할` 이 **공식 한국어 판 그대로여서** 레포가 공식과 일치한다.
> 「읽기 좋게」 바꾸면 새 동기화 가드(`clf_guide_sync_test.dart`, 이 절의 §4-E 권고를
> 구현한 것)가 거짓으로 깨진다. 차이는 정확히 **6건**이다.

**① 위치** `flutter_app/assets/exam_guides/CLF-C02.json`
**④ 실측 방법** 공식 도메인 1~4 페이지의 관련 지식·기술 **135개 항목을 전부 전사**해 레포 JSON과 **바이트 대조**했다. 결과 **일치 129 · 불일치 6 · 레포에만 있는 항목 6**(= 같은 6건의 반대쪽).

| 작업 | 공식 현행 | 레포 JSON (옛 개정판) | 의미 |
|---|---|---|---|
| 1.3 기술 | `적절한 마이그레이션 전략 파악(예: 데이터베이스 복제)` | `…(예: 데이터베이스 복제, **AWS Snowball 사용**)` | **Snowball 예시가 빠졌다** |
| 2.2 기술 | `…AWS CloudTrail, AWS Config를 통한 감사…` | `…AWS CloudTrail, **AWS Audit Manager 및** AWS Config를 통한 감사…` | **Audit Manager가 빠졌다**(유지 관리 전환과 일치) |
| 2.3 지식 | `AWS IAM Identity Center` | `AWS IAM Identity Center**(AWS Single Sign-On)**` | 구명 병기 삭제 |
| 3.7 기술 | `…(예: Amazon **SageMaker AI**, Amazon Lex)` | `…(예: Amazon SageMaker, Amazon Lex, **Amazon Kendra**)` | **SageMaker AI로 개명 + Kendra가 빠졌다** |
| 3.8 지식 | `**AWS Amplify의** 프런트엔드 웹 및 모바일 서비스` | `AWS Amplify**와 AWS AppSync의** 프런트엔드…` | **AppSync가 빠졌다** |
| 4.3 기술 | `…(예: 고객 서비스 및 커뮤니티, 기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations)` | `…(예: 고객 서비스 및 커뮤니티, AWS Developer Support, AWS Business Support, AWS Enterprise On-Ramp Support, AWS Enterprise Support)` | **지원 플랜 라인업 교체** (P1-4의 근거) |

**③ 왜 문제인지**
여섯 건이 **한 방향으로 일관**한다 — AWS가 **닫히거나 개명된 서비스를 가이드에서 걷어냈다.** 레포 JSON은 문항의 `skill` 태그와 「공식 가이드가 ~를 명시한다」류 서술의 근거이므로, 이 JSON이 옛 개정판이면 **그 위에 쌓인 모든 서술이 같이 낡는다.** 실제로 P1-3·P1-4가 정확히 그렇게 생겼다.

**⑤ 제안 수정안** 여섯 항목을 공식 전문으로 교체한다. ⚠️ `CLF-C02.json`은 2칸 들여쓰기 다중 행이므로 재직렬화 없이 해당 문자열만 치환할 수 있다. 교체 뒤 §3-D·§3-F·§3-G의 파생 항목을 함께 정리해야 한다.

**기존 가드 충돌:** CLF에는 `soa_guide_v11_test.dart` 같은 **가이드 동기화 테스트가 없다.** 교체와 함께 그 판을 만들어 두면 다음 개정에서 자동으로 잡힌다(§4-E).

---

### P2-D. 공식 **「범위 외」** 서비스가 라이브 문항의 **정답**인 건 5건

**① 위치 · ② 정답 보기 · ④ 근거**

| 문항 | 정답 보기 | 공식 「범위 외」 범주 |
|---|---|---|
| `clf-t4-2-q10` | `AWS Billing Conductor` | 클라우드 재무 관리 |
| `clf-t3-1-q19` | `CodePipeline이 흐름을 조율하고, CodeBuild가 … **CodeDeploy**가 배포를 자동화한다` | 개발자 도구(`AWS CodeDeploy`) |
| `clf-t3-2-q10` | `AWS Wavelength` | 컴퓨팅 |
| `clf-t3-4-q10` | `Amazon MemoryDB` | 데이터베이스(`Amazon MemoryDB for Redis OSS`) |
| `clf-t3-7-q19` | `Amazon Personalize` | 기계 학습 |

**④ 공식 URL** `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-out-of-scope-services.html` (실측 2026-11-06, 다섯 서비스 모두 명시)

**③ 왜 문제인지**
§5-4의 「목록에 없다 ≠ 범위 밖」 규율은 여기에 해당하지 않는다 — 이 다섯은 **「범위 외」 목록에 이름으로 올라 있다.** 사실 자체는 모두 정확해서 **틀린 지식을 주지는 않지만**, Foundational 등급에서 **범위 밖 서비스를 정답으로 외우게 하는 것은 학습 시간을 잘못 쓰게 한다.** 특히 `clf-t3-1-q19`는 정답 보기 안에 CodeDeploy가 들어 있어 **범위 내 두 서비스(CodePipeline·CodeBuild)와 묶여** 분리가 어렵다.

**⑤ 제안 수정안** (난이도 순)
- `clf-t4-2-q10`(Billing Conductor) — Task 4.2의 공식 기술은 Budgets·Cost Explorer·요금 계산기·Organizations 통합 결제·비용 할당 태그다. **이 문항을 그 다섯 중 아직 다루지 않은 축으로 교체**하는 것이 가장 깔끔하다. 그대로 두려면 최소한 `(⚠️ 범위 외 서비스 — 참고용)` 표시가 필요하다.
- `clf-t3-2-q10`(Wavelength) · `clf-t3-4-q10`(MemoryDB) · `clf-t3-7-q19`(Personalize) — 같은 Task 안에 범위 내 대체 소재가 충분하다(Outposts·Local Zones / ElastiCache·DynamoDB / Lex·Polly·Comprehend).
- `clf-t3-1-q19`(CodeDeploy) — 정답 보기에서 CodeDeploy 절을 빼고 **CodePipeline↔CodeBuild 2단 구분**으로 좁힌다. ⚠️ 이때 `wrongExplanations`의 CodeDeploy 언급도 함께 정리해야 한다.
- ⚠️ **다섯 건 모두 `verified:true` 라이브**이므로 문항 교체는 사람의 승인을 받고, `correct`·`verified`는 건드리지 않는다.

**기존 가드 충돌:** `clf_supplement_questions_test.dart`는 `t3-1`·`t3-2`·`t3-3`·`t3-5`·`t3-7`·`t3-8`·`t2-2`의 **스키마만** 본다(`options` 4개, `wrongExplanations` 키 = 비정답 인덱스 전부, `sources` 비어 있지 않음). 문항을 교체하면 그 계약을 그대로 지켜야 한다 — 특히 **`correct`를 바꾸면 `wrongExplanations`의 키 집합도 함께 바꿔야** 한다.

---

### P2-E. 라이브 문항 7건이 **단종 예정 플랜 이름**으로 출제되고, 2건은 해설이 현행과 다르다

**① 위치** `t4-3.questions.json` — `q1`·`q2`·`q6`·`q7`·`q10`·`q11`·`q13`

**② 현재 문구 (문제가 되는 두 건)**
```
clf-t4-3-q7  explanation: … Basic·Developer 플랜은 핵심(core) 점검만 사용할 수 있습니다.
                          따라서 '전체 점검'의 최소 요건은 Business 플랜 이상입니다 …
clf-t4-3-q10 explanation: AWS Support API … 에 접근하려면 Business, Enterprise On-Ramp,
                          또는 Enterprise Support 플랜이 필요합니다.
```
그리고 `q6`의 **정답 보기가 `Developer Support`**다.

**③ 왜 문제인지**
P1-4에서 확인한 대로 공식 가이드와 공식 문서가 모두 **Business Support+ · Enterprise · Unified Operations**로 넘어갔다. `q10`의 해설은 **단종 예정 플랜 세 개 중 둘을 이름으로 적는다.** `q6`은 단종 예정 플랜을 정답으로 고르게 한다.

**④ 공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html` — *"AWS Trusted Advisor checks are available to customers with an AWS **Business Support+**, AWS Enterprise Support, or AWS Unified Operations plan."* / Basic은 *"all checks in the Service Limits category and selected checks in the Security and Fault tolerance categories"*
- `https://aws.amazon.com/premiumsupport/faqs/` — *"Basic Support customers have access to 6 security checks … and service limit checks while AWS Business Support+, Enterprise Support and Unified Operations customers have access to the full set"*
- `https://docs.aws.amazon.com/awssupport/latest/user/getting-started.html` — Support 케이스·API는 *"Business Support+, Enterprise Support, or Unified Operations"*
- `https://repost.aws/knowledge-center/get-aws-help` — 같은 세 플랜

**⑤ 제안 수정안**
P1-4의 「두 묶음 대응」 틀을 문항에도 적용한다. 정답 인덱스는 **바꾸지 않고** 해설에 현행 명칭을 괄호로 병기한다.
- `q7` → `… Basic 플랜은 서비스 할당량 전체 + 보안·내결함성 일부 점검만 사용할 수 있고(현행 공식 서술), 전체 점검은 **Business Support+·Enterprise·Unified Operations**에서 제공됩니다. 전통 분류로는 **Business 이상**입니다.`
- `q10` → `… 현행 공식 요건은 **Business Support+·Enterprise Support·Unified Operations**이고, 전통 분류로는 **Business 이상**입니다(Developer·Business·Enterprise On-Ramp는 2027-01-01 단종).`
- `q6` — 정답 보기 `Developer Support`는 **전통 분류 기출 대비로는 여전히 유효**하므로 유지하되, 해설에 `(⚠️ Developer Support는 2027-01-01 단종 예정이고 공식 가이드의 예시에서도 빠졌습니다. 현행 최저 유료 플랜은 Business Support+입니다)`를 더한다.
- ⚠️ `q2`·`q11`은 **이미 현행 명칭을 병기**하고 있어(`현행 공식 명칭으로는 Business Support+에 해당합니다`) 「가이드가 전통 분류를 명시」 절만 고치면 된다.

---

### P2-F. 신규 고객에게 닫힌 서비스 2종이 **정답**인데 「정직성 메모」가 없다 (레포 관례와 비대칭)

| 문항 | 정답 | 공식 상태 (실측) | 레포의 관례 적용 여부 |
|---|---|---|---|
| `clf-t2-2-q10` | `AWS Audit Manager` | `what-is.html` 배너 — *"no longer open to new customers"*, 공지일 **2026-04-30** | md에는 메모가 있으나 **연도가 틀렸고**(P1-3) **문항에는 메모가 없다** |
| `clf-t3-7-q3` | `Amazon Kendra` | `what-is-kendra.html` 배너 — *"Amazon Kendra will no longer be open to new customers starting on **July 30, 2026**"*(즉 **이미 지났다**), 대체재로 *Amazon Bedrock Knowledge Bases* 지목 | **md·문항 어디에도 메모가 없다** |

**③ 왜 문제인지**
이 레포는 **같은 상황에 메모를 다는 관례**를 이미 갖고 있다 — `t3-7.md:171`이 Amazon Forecast에 `ℹ️ 정직성 메모: … 신규 고객에게 더 이상 제공되지 않습니다`를 달고, `clf-t3-7-q19`의 `wrongExplanations["3"]`도 `Forecast는 … 공식 문서상 신규 고객에게 더 이상 제공되지 않습니다`로 적는다. **그런데 같은 문서(`t3-7.md`)가 Kendra를 「AI/ML 3종」의 하나로 11번 언급하면서 상태를 한 번도 적지 않는다.** 2026-07 감사가 `DOC-CLF-106/205/306`에서 「단종 메모 비일관」으로 묶은 그 패턴이고, **Kendra는 그 목록에 없던 새 항목**이다.

**④ 공식 URL** `https://docs.aws.amazon.com/kendra/latest/dg/what-is-kendra.html` · `https://docs.aws.amazon.com/audit-manager/latest/userguide/what-is.html`

**⑤ 제안 수정안**
`t3-7.md` §1(`{#ai-ml}`) 표 아래에 Forecast 메모와 같은 형식으로 한 줄을 넣는다.
```
> ℹ️ 정직성 메모: Amazon Kendra는 **2026-07-30부터 신규 고객에게 열려 있지 않습니다**(기존 고객은 계속 사용).
  공식 문서가 유사 기능으로 **Amazon Bedrock Knowledge Bases**를 지목합니다. ⚠️ 그리고 **CLF-C02 공식 가이드도
  작업 3.7의 예시에서 Kendra를 뺐습니다**(현재는 SageMaker AI·Lex). 「문서 검색 = Kendra」는 기출 대비로만 기억하세요.
```
- `clf-t3-7-q3`·`clf-t2-2-q10`의 `explanation` 끝에도 같은 한 줄을 넣는다.
- ⚠️ 메모를 달 때 **「AI/ML 3종」이라는 묶음 이름**도 재검토가 필요하다. 공식 가이드 3.7의 예시는 이제 **SageMaker AI·Lex 둘**이다.

**기존 가드 충돌:** `content_enrichment_test.dart`가 `t3-7.md`에 대해 **「`### ` 서브섹션마다 `> 🧠 원리:` 블록」**(하한 min(서브섹션, 8))과 **「`## 🔤 용어` 절이 🎯와 📖 사이」**를 요구한다. 위 메모는 기존 `### 1)` 절 안에 넣는 인용 블록이라 **서브섹션 수를 늘리지 않으므로 안전**하다. 새 `###` 절을 만들면 원리 블록 하한이 함께 올라간다.

---

### P2-G. `t3-8.md`의 **「그 외 범위 내 서비스」 표**에 공식 「범위 외」 서비스가 7종

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-m).** 세 가지가
> 달라졌다. ① **7종에 `CodeCommit` 이 빠져 있다** — 공식 범위 내 「개발자 도구」는
> `AWS CLI · AWS CodeBuild · AWS CodePipeline · AWS X-Ray` **넷뿐**이므로 표의
> `CodeCommit` 도 범위 내가 아니다. ② 다만 **`CodeCommit`·`Cloud9`·`AppSync` 는 범위 외
> 목록에도 없다** — 두 목록 모두 스스로 `non-exhaustive` 라고 밝히므로 **「범위 외」로
> 단정하지 않고 「어느 목록에도 없다」**로 적었다. ③ **2차 패스의 「seg042 가 CloudShell 을
> 범위 내로 말한다」는 과대다** — 그 세그먼트의 발화 본문은 「범주만 매칭해서 알아 두면
> 되는 것들」로 CloudShell 을 들 뿐 **「범위 내」라고 말하지 않는다**(실측). 따랐다면
> **멀쩡한 발화를 바꿨다.** 거짓인 발화는 **seg034 하나**이고(표를 그대로 읽는다) 그
> 1편만 사용자 승인으로 재합성했다.
> ⚠️ **절 제목은 공식 Task 3.8 제목**(「시험 범위에 포함되는 다른 AWS 서비스 범주의 서비스
> 파악」)**을 그대로 따르므로 내용을 좁히는 쪽이 맞다** — 이 절이 「둘 중 하나는 반드시
> 손대야 한다」고 적은 선택은 **표 내용**이다.

**① 위치** `flutter_app/assets/content/clf/t3-8.md:150~157` (`{#other-services}`)

**② 현재 문구**
```
### 4) 그 외 범위 내 서비스 — 위치만 알아 두기 {#other-services}
| **개발자 도구** | CloudShell(브라우저 셸), Cloud9(IDE), CodeCommit/Build/Deploy/Pipeline, X-Ray(분산 추적) |
| **프런트엔드·모바일** | AWS Amplify, AWS AppSync |
| **고객 지원(Customer Enablement)** | AWS Support, AWS IQ, AWS Managed Services(AMS), AWS Activate |
```

**③ 왜 틀렸는지**
절 제목이 **「범위 내」**인데 내용의 상당수가 공식 **「범위 외」** 목록에 있다.
- `AWS CloudShell` · `AWS CodeDeploy` → 범위 외(개발자 도구)
- `AWS IQ` · `AWS Managed Services(AMS)` · `AWS Activate` → 범위 외(고객 지원) — **이 행은 4개 중 3개가 범위 외**이고 `AWS Support`만 범위 내다
- `Cloud9` → 범위 내 목록에 없다(그리고 2024-07-25부터 신규 고객에게 닫혔다)
- `AWS AppSync` → 범위 내 목록에 없고, **공식 가이드 3.8 지식 항목에서도 빠졌다**(§3-C)

**④ 공식 URL + 실측 근거**
- `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-out-of-scope-services.html` — 개발자 도구에 `AWS CodeDeploy`·`AWS CloudShell`, 고객 지원에 `AWS Activate`·`AWS IQ`·`AWS Managed Services(AMS)`
- `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-in-scope-services.html` — 개발자 도구는 `AWS CLI`·`AWS CodeBuild`·`AWS CodePipeline`·`AWS X-Ray` **넷뿐**이고, 프런트엔드 웹 및 모바일은 `AWS Amplify` **하나뿐**, 고객 지원은 `AWS Support` **하나뿐**

**⑤ 제안 수정안**
표를 **공식 범위 내 목록 그대로** 좁히고, 나머지는 「범위 외로 명시된 이름」 줄로 분리한다.
```
| **개발자 도구** | AWS CLI, CodeBuild, CodePipeline, X-Ray(분산 추적) |
| **프런트엔드·모바일** | AWS Amplify |
| **고객 지원(Customer Enablement)** | AWS Support |

> ⚠️ 보기에 나오면 **범위 외**로 읽는 이름: CloudShell · CodeDeploy · AWS IQ · AWS Managed Services(AMS) ·
  AWS Activate(공식 「범위 외」 목록에 명시). `Cloud9`·`AppSync`는 어느 목록에도 없고 가이드 예시에서도 빠졌습니다.
```
- ⚠️ **절 제목의 「범위 내」를 지키려면 내용을 좁혀야 하고, 내용을 유지하려면 제목을 바꿔야 한다.** 둘 중 하나는 반드시 손대야 한다.
- ⭐ 참고로 **범주명 「고객 지원(Customer Enablement)」은 옳다** — §5-5 참조(2026-07 감사의 반대 판정이 틀렸다).

**기존 가드 충돌:** `content_enrichment_test.dart`의 원리 블록 하한. 위 수정은 표 내용과 인용 블록만 바꾸므로 `###` 수가 늘지 않아 안전하다.

---

### P2-H. Trusted Advisor **「500+ 점검」** — 근거를 찾지 못했다

> ⚠️⚠️ **컨트롤러 기각(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-m).** 인용 페이지
> `aws-support-plans.html` 의 **Business Support+ 절**이 `More than 500 checks with
> AWS Trusted Advisor.` 를 **그대로 싣는다**(실측). 이 절의 「인용 페이지에 없다」는
> 틀렸고, 따랐다면 **참인 수치를 지웠다.** 실제 결함은 **출처 제목의 플랜 이름**이다 —
> 그 페이지는 500+ 를 `Business Support+` 에 귀속시키는데 제목이 「Business 이상」으로
> 적혀 있었다. 「근거를 찾지 못했다」와 「없다」는 다른 판정이다(2026-11-06 AIF 배치의
> 「없다」 규율과 같은 계열).

**① 위치** `clf-t4-3-q2`의 `sources[0].title`
**② 현재 문구** `AWS Support Plans — Business 이상: 24x7 기술 지원·전체 Trusted Advisor(500+ 점검)`
**③ 왜 문제인지** 괄호 안 수치가 **인용한 페이지에 없다.** 내가 읽은 `aws-support-plans.html`·`trusted-advisor.html`·`premiumsupport/faqs/`에는 Basic의 **6개 보안 점검**과 「full set」만 있고 **총 점검 수를 숫자로 적지 않는다.**
**④ 근거** `https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html` · `https://aws.amazon.com/premiumsupport/faqs/`
**⑤ 제안 수정안** `(500+ 점검)`을 지우고 `전체 Trusted Advisor 점검`으로 둔다. ⚠️ 나는 **「500+가 틀렸다」고 단정하지 않는다** — `trusted-advisor-check-reference.html`을 전수로 세면 수가 나올 수 있다. 다만 **인용 페이지가 그 수를 담고 있지 않으므로** 지우거나 그 수를 적는 페이지로 출처를 바꾸는 것이 맞다.

---

### P2-I (DVA). 참고자료 URL 2건 (§P2-A #11·#12와 같음)

- `dva-t2-2.md:393` — `DDB-encryption-context.html` **소멸**. 교체 정본 `DDB-encrypted-and-signed.html`은 **제목이 글자 그대로 같다.** 그 페이지가 인용 사실(「어느 필드가 암호화·서명되는가」)을 담고 있는 것도 확인했다(*"a digital signature over … each field marked `ENCRYPT_AND_SIGN`, `SIGN_ONLY`, or `SIGN_AND_INCLUDE_IN_ENCRYPTION_CONTEXT`"*).
- `dva-t4-1.md:416` — `aiops/index.html` → `aiops/`. 같은 페이지이므로 내용 위험 없음.

⚠️ **DVA 고유 URL 241개 중 이 2건을 뺀 239개는 `200 r=0`이다.** 2026-11-01 저작 시점에 전수 실측했다는 조사 노트의 기록과 일치한다.

---

### P2-J (DVA). EC2 역할 자격 증명 **「보통 6시간」** — 근거 페이지를 찾지 못했다

**① 위치** `flutter_app/assets/content/dva/dva-t2-1.md:204` · `:280` · `:327`
**② 현재 문구**
```
:204  | └ EC2 인스턴스의 역할 자격 증명 | 그 자격 증명 기간 동안(보통 **6시간**) |
:327  … IAM 역할 자격 증명이면 **역할 세션이 끝나는 순간** URL도 끝납니다(EC2 인스턴스 역할은 보통 6시간).
```
**③ 왜 문제인지**
① 조사 노트가 **이 수치의 출처를 이미 경고**했다 — `99-gaps.md` **G-15**: *"「IAM 인스턴스 프로파일 6시간 / STS 36시간」은 S3 on Outposts 문서의 수치다 — 표준 S3에 옮겨 쓰지 않는다."* 그런데 학습문서가 그 수치를 **표준 EC2 역할 자격 증명**에 썼다.
② 공식 EC2 문서는 오히려 **반대 방향의 주의**를 적는다 — *"Amazon EC2 IAM role credentials are **not subject to maximum session durations** configured in the role."* 즉 「역할 세션 길이」로 설명하는 틀 자체가 EC2에서는 조심스럽다.
③ 그 수치를 찾을 만한 페이지(`iam-roles-for-amazon-ec2-retrieve-creds.html`)는 **실측하면 `concepts.html`로 리다이렉트**된다(소멸).
**④ 근거** `https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html` (위 인용) · `docs/content-research/DVA-C03/99-gaps.md` G-15
**⑤ 제안 수정안**
⚠️ **「6시간이 틀렸다」고 단정하지 않는다** — IMDSv2 **세션 토큰**의 상한이 6시간인 것은 공식이 명시하고(`configuring-instance-metadata-service.html`: *"a minimum of one second and a maximum of six hours"*) `dva-t2-1.md:183`은 그 사실을 **정확히** 쓰고 있다. 문제는 **역할 자격 증명 자체의 수명**에 같은 숫자를 붙인 자리다. 세 곳의 `(보통 6시간)`을 **괄호째 지우는 것**을 제안한다 — 학습 요점(「사전 서명 URL은 자격 증명보다 오래 살 수 없다」)은 숫자 없이도 성립하고, 공식 문구가 *"credentials are rotated … before they expire"*까지만 말하기 때문이다. 수치를 꼭 쓰려면 그 수를 적는 페이지를 먼저 찾는다(§6).

---

## 4. P3 — 보강 후보

> ⚠️⚠️ **컨트롤러 정정(2026-11-07 반영 PR — HANDOFF §0-2026-11-07-d).**
> 반영 전에 레포 실상태와 공식 페이지를 다시 쟀고 이 절의 **네 가지가 달라졌다.**
> ① **`P3-3`·`P3-4①`·`P3-6`·`P3-8`은 이미 닫혀 있다** — 그 뒤의 죽은 URL 배치(q10 재작성 ·
> Snowball Edge 명칭·URL)와 CLF P2(§P2-G의 `t3-8.md` 표 · `clf_guide_sync_test.dart` 신설)가
> 반영했다. 보고서는 2026-11-06 시점이라 그 선반영을 모른다.
> ② **`P3-7`은 「해설에 한 줄 추가」로 끝나지 않는다** — 문항이 **이미 출처로 달고 있던**
> `CHAP_AuroraOverview.html` 이 `Aurora delivers up to 6x the throughput of stock
> PostgreSQL and up to 6x the throughput of stock MySQL on similar hardware.` 로 적는다.
> 즉 **인용 페이지에 「5배/3배」가 없다**(「URL은 200인데 그 페이지에 인용 사실이 없다」
> 계열의 결함이다). 5배/3배는 **GovCloud(US) 안내서** 전용이고 리전 부록보다 주 가이드가
> 정본이므로, **6배를 앞세우고 5배/3배를 공식 표현의 갈림으로 병기**했다. ⚠️ 5배/3배가
> 거짓은 아니므로 **금지하지 않는다.**
> ③ **`P3-7`의 집계는 문맥을 섞어 과대였다** — 「saa md 1 · q 1 · 발화 1」의 `5배`·`3배`는
> **Aurora와 무관**하다(Kinesis 샤드 「5배 과대 추정」 · 「읽기 트래픽이 5배 급증」 ·
> Lambda 폴러 「약 3배 빠른 스케일링」). Aurora 배수는 **CLF에만** 있다.
> ④ **`P3-1`의 전역 확장에는 탐지기 보강이 필요했다** — 느슨한 `\*[^*\n]+\*` 를 문항에
> 그대로 쓰면 ALB 경로 규칙이 걸린다(`saa-t3-7`). 마크다운 공백 조건 **+ 코드 스팬 마스킹**
> 둘 다 넣어야 0건이 된다(백틱 안 글로브로 거짓 양성 3건 실측).
> ⚠️ `P3-2`는 ①(md 보강)을 골랐다 — 문항이 라이브이고 사실도 맞아서 ②(교체)는 올바른 문항을
> 지우는 쪽이다. 대신 **공식 작업 4.1·4.2 기술 목록에 프리 티어가 없다**는 범위 메모를 함께
> 달았다. ⚠️ **검증되지 않은 「레거시 12개월 무료」·개편 날짜는 쓰지 않았다**(근거가
> `repost.aws` 뿐 — 2026-11-06 배치의 판정을 유지하고 md 전수 금지 가드로 고정했다).

### P3-1 (CLF). `clf-t2-3-q1` 해설에 파서가 렌더하지 않는 **단일 `*이탤릭*`** 1건

- **위치** `flutter_app/assets/content/clf/t2-3.questions.json` — `clf-t2-3-q1`의 `explanation`
- **현재 문구** `… 이런 작업은 대개 계정 *자체*에 대한 것이거나 잠긴 상황을 푸는 것으로, …`
- **왜 문제인지** 문항 해설은 `lib/content/quiz_widgets.dart:393`의 **`Text(q.explanation, …)`** — 즉 **마크다운이 아니라 평문 `Text` 위젯**으로 렌더된다(실측). 따라서 화면에는 `계정 *자체*에`로 **별표가 글자 그대로** 보인다. 레포 전역 가드 `content_format_test.dart`는 **`assets/content/**.md`만** 대상이라 `.questions.json`은 걸리지 않는다. CLF 301문항 전수 스캔에서 **이 1건이 유일**하고 `[텍스트](링크)`는 0건, 문항 전체에 `**굵게**`도 0건이다(= 작성자들이 평문 렌더를 알고 있었고 이 한 건만 샜다).
- **근거** 실측 — `grep -n "Text(q.explanation" flutter_app/lib/content/quiz_widgets.dart` → `393`. 전수 스캔 결과: 링크 0 · 이탤릭 1 · 굵게 0 · 출처 제목의 굵게 0.
- **제안 수정안** 별표만 지운다 → `… 계정 자체에 대한 것이거나 …`
- **기존 가드 충돌:** 없다. 함께 `content_format_test.dart`의 전역 불변식을 **`.questions.json`까지 확장**하면 다음 콘텐츠는 첫 커밋부터 0건이 된다(지금 전역에서 1건이므로 그 한 건만 고치면 바로 걸 수 있다).

### P3-2 (CLF). 프리 티어가 **학습문서 0편**에서 다뤄지는데 라이브 문항은 있다

- **위치** `clf-t4-1-q10`(프리 티어 3유형)
- **왜 문제인지** `grep -rl "프리 티어" flutter_app/assets/content/clf/` → **`t4-1.questions.json` 하나뿐**이고 **md 19편에는 「프리 티어」·「Free Tier」가 0건**이다(실측). 학습자가 문서에서 배운 적 없는 사실을 문항에서 처음 만난다. 공식 CLF-C02 가이드의 작업 4.1·4.2 관련 지식·기술에도 프리 티어가 **없다**(실측 — 「티어」는 스토리지 계층 문맥 2건뿐).
- **제안 수정안** 둘 중 하나. ① `t4-1.md`의 §요금 모델에 프리 티어 3유형을 두 줄로 넣는다 ② 문항을 Task 4.1의 공식 기술(구매 옵션·데이터 전송·스토리지 티어 요금)로 교체한다. ⚠️ **①을 고르면 P3-3을 함께 반영해야 한다.**

### P3-3 (CLF). 프리 티어 3유형 서술이 **2025-07-15 개편** 이후와 어긋난다

- **위치** `clf-t4-1-q10`의 정답 보기·해설
- **현재 문구** `12개월 무료(가입일로부터 12개월), 상시 무료(…), 단기 평가판(…)` / `… 세 가지 유형으로 구성됩니다.`
- **왜 문제인지** ① **인용 출처가 소멸**했다(§P2-A #3). ② 교체 정본 `free-tier.html`은 현재 **두 유형**(`Always free` · `Short-term trials`)만 적고 **크레딧 기반 플랜**(Free plan / Paid plan)을 설명한다. ③ `aws.amazon.com/free`는 여전히 「Three Types of Offers」로 적지만 **12-Months Free를 「only available to Legacy Free Tier AWS customers」로 한정**한다.
- **근거**
  - `https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html` — *"All AWS customers have access to select short-term trials and Always Free tier offers. Your AWS Free Tier offerings depend on your plan type."*
  - `https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html` — Free account plan은 *"ends after six months or when your credits are fully used"*, 신규 계정은 USD $100 크레딧 + 활동으로 최대 $100 추가
  - `https://repost.aws/knowledge-center/aws-free-tier-account-start-expire` — *"The credit-based AWS Free Tier (launched **July 15, 2025**) applies only to accounts created on or after that date."* / 그 전 계정은 12개월
  - `https://aws.amazon.com/free` — *"12-Months Free … only available to **Legacy Free Tier** AWS customers"*
- **제안 수정안** 정답 보기는 유지(공식 `aws.amazon.com/free`가 여전히 세 유형으로 적는다 — §5-5의 「공식이 갈리면 단정하지 않는다」)하고, `explanation` 끝에 한 줄을 더한다:
  `⚠️ 2025-07-15 이후에 만든 계정은 크레딧 기반 프리 티어(Free plan / Paid plan)가 적용되고 「12개월 무료」는 그 전에 만든 레거시 계정에만 해당합니다.`
  출처는 `free-tier.html` + `aws.amazon.com/free` **둘을 함께** 단다.

### P3-4 (CLF). 공식 가이드가 **Snowball 예시를 뺐다** — t1-3의 비중 재평가가 필요하다

- **위치** `t1-3.md` 및 문항 `clf-t1-3-q1`·`q3`·`q4`·`q5`·`q7`·`q8`·`q9`·`q12`·`q14`·`q15`(언급 10건, **정답 2건**: `q3`·`q14`, 복합 정답 1건: `q9`)
- **근거 세 가지가 같은 방향이다**
  1. 공식 가이드 작업 1.3 기술이 `…(예: 데이터베이스 복제, **AWS Snowball 사용**)` → `…(예: 데이터베이스 복제)`로 바뀌었다(§P2-C).
  2. 공식 **「범위 내 서비스」 목록의 「마이그레이션 및 전송」**에 Snow 계열이 **하나도 없다**(Application Discovery Service · Application Migration Service · DMS · 마이그레이션 평가기 · Migration Hub · SCT).
  3. 인용 URL `whatissnowball.html`이 **소멸**하고 살아 있는 것은 `whatisedge.html`(**Snowball Edge**)이다. `snowcone-guide/whatissnowcone.html`도 `200 r=1`이다.
- ⚠️ **단, §5-4 규율대로 「범위 밖」으로 단정하지 않는다** — Snow 계열은 **「범위 외」 목록에도 없다.** 그래서 이것은 「삭제」가 아니라 **「비중 축소 + 명칭 현행화」** 제안이다.
- **제안 수정안** ① 서비스 이름을 **AWS Snowball Edge**로 현행화하고 URL을 `whatisedge.html`로 교체한다 ② `t1-3.md`에 한 줄 메모: `⚠️ 공식 가이드는 작업 1.3의 예시에서 Snowball을 뺐고 「범위 내 서비스」 목록에도 Snow 계열이 없습니다(「범위 외」 목록에도 없습니다). 오프라인 대량 전송이라는 **개념**은 여전히 유용하니 DMS·DataSync와의 대비로만 기억하세요.` ③ 정답 2건은 개념 문항이라 유지 가능하되 Task 1.3의 다른 공식 기술(CAF 구성 요소·DB 복제)과 균형을 재검토한다.

### P3-5 (CLF). `clf-t4-2-q2` ↔ `q12`가 **같은 신호를 두 번** 묻는다

- **현재 문구**
  - `q2` 지문: `… 발생한 AWS 비용과 사용량의 추세를 그래프로 시각화·분석하고 향후 지출을 예측하려 한다.`
  - `q12` 지문: `지난 비용·사용량 추세를 바탕으로 향후 비용을 예측하고 시각적으로 분석하려 한다.`
- **왜 문제인지** 두 문항의 정답(`AWS Cost Explorer`)·오답 구성·지문 신호가 거의 같다. 같은 Task 안에서 **한 사실을 두 번 출제**하는 셈이다. 같은 파일의 다른 중복쌍(`q1`↔`q13` Pricing Calculator, `q3`↔`q11` Budgets)은 **각기 다른 각도**(계정 데이터 불필요 / 임계값 vs ML)로 갈라져 있어 정당하다 — `q2`↔`q12`만 그 갈림이 없다.
- **제안 수정안** `q12`를 Task 4.2의 아직 다루지 않은 축으로 돌린다(예: Cost Explorer의 **RI·SP 권장** 기능, 또는 비용 할당 태그의 **활성화 절차**). 또는 `q12`를 「예측 범위(과거 13개월 / 예측 18개월)」를 묻는 수치 문항으로 바꿔 `q2`와 갈라 둔다.

### P3-6 (CLF). `Cloud9`·`AppSync` — 어느 목록에도 없고 가이드 예시에서도 빠졌다

- **위치** `t3-8.md:156`(Cloud9·AppSync) · `t2-4.md`(AppSync 언급)
- **근거** 「범위 내」·「범위 외」 목록 **양쪽에 없다**(실측). 그리고 `AppSync`는 공식 가이드 3.8 지식 항목에서 **빠졌다**(§P2-C). `Cloud9`는 2024-07-25부터 신규 고객에게 닫혔다.
- ⚠️ §5-4대로 **「범위 밖」으로 단정하지 않는다.** §P2-G의 수정안에서 함께 다루면 된다.

### P3-7 (CLF). Aurora 「MySQL 5배 / PostgreSQL 3배」 — 공식이 갈린다

- **위치** `t3-4.md:103` · `clf-t3-4-q2`(지문·해설)
- **현재 문구** `일부 워크로드에서 **표준 MySQL의 최대 5배, PostgreSQL의 최대 3배 처리량**`
- **실측** 공식이 두 가지로 적는다.
  - `https://docs.aws.amazon.com/govcloud-us/latest/UserGuide/govcloud-aurora.html` — *"up to five times the throughput of MySQL and up to three times the throughput of PostgreSQL"* (= 문서와 일치)
  - `https://docs.aws.amazon.com/rds/latest/auroraextendedcontent/aurora-features-performance.html` — *"Up to **6x** the throughput of PostgreSQL and MySQL"* (SysBench 기준)
- **판정** §5-5 규율대로 **단정하지 않는다.** 문서의 5배/3배는 공식 문구를 그대로 인용한 것이므로 **오류가 아니다.** 다만 보기에 6배가 섞인 기출을 만나면 흔들릴 수 있어, 해설에 `(벤치마크 기준으로는 최대 6배로 적는 공식 페이지도 있습니다)` 한 줄을 더하는 것을 제안한다. 양쪽 URL을 함께 둔다.

### P3-8 (CLF). CLF에는 **가이드 동기화 테스트가 없다**

- SOA는 `soa_guide_v11_test.dart`, AIF는 `aif_guide_v11_test.dart`로 **가이드 JSON ↔ 공식 전문**을 단정한다. CLF에는 없어서 §P2-C의 6건이 **조용히 낡았다.**
- **제안** §P2-C 교체와 함께 `clf_guide_test.dart`를 만들고 ① 도메인 비중 24·30·34·12 ② 작업 수 4·4·8·3 ③ 작업 4.3 기술의 신규 플랜 문구 ④ **금지 문구**(`AWS Developer Support`·`AWS Enterprise On-Ramp Support`·`AWS Audit Manager 및`·`Amazon Kendra`·`AWS AppSync`·`AWS Snowball 사용`·`AWS Single Sign-On`)를 단정한다.

### P3-9 (DVA). 공식 가이드의 두 보조 페이지를 아직 인용하지 않는다

- **실측** `grep -rn "service-mentions\|dva-03-comparison" flutter_app/assets/content/dva/` → **0건**
- 공식 DVA-C03 가이드에는 범위 내·외 목록 외에 **`dva-03-service-mentions`(「시험에서 언급되는 AWS 서비스」)**와 **`dva-03-comparison`(「DVA-C02 및 DVA-C03 비교」)**가 있다. DVA 12편은 C02→C03 전환 서술을 많이 담고 있고(각 문서의 `⚠️ C02에서 바뀐 것` 절) 범위 판정도 자주 하는데, **그 두 페이지가 바로 그 판정의 1차 근거**다.
- **제안** 특히 `dva-t3-1.md:186`·`:338`과 `dva-t1-1.md:278`·`:381`의 범위 서술에 `dva-03-service-mentions`·`dva-03-comparison`을 출처로 더한다. ⚠️ 나는 그 두 페이지의 **본문을 읽지 않았다**(§6) — 더하기 전에 내용을 확인해야 한다.

### P3-10 (DVA). 12월 전환 PR의 구조 선결 3건 (실측)

| 항목 | 실측 | 의미 |
|---|---|---|
| `assets/exam_guides/DVA-C03.json` | **없다** (`DVA-C02.json`만 있고 `code: DVA-C02`·`slug: developer-associate-02`) | 12편 전부가 `certCode: DVA-C03` 프런트매터를 들고 있는데 가이드 JSON이 C02다. 문항을 쓰면 `skill` 태그 유도가 불가능하다 |
| `lib/data/content_index.dart` | `grep -n "dva"` → **0건** | 미등재 = 사이트에서 404인 것이 정상 |
| 문항 파일 | `assets/content/dva/*.questions.json` → **0개** | `dva_doc_format_test.dart`의 주석이 예고한 대로 `dva_questions_test.dart`가 생기면 **두 파일의 Task 목록을 모두** 늘려야 한다 |

- ⚠️ 그리고 조사 노트 `99-gaps.md` **G-03(시험 시간)이 여전히 열려 있다** — 공식 가이드 본문에 응시 시간이 없다. 내가 공식 페이지를 다시 읽어도 **없었다**(합격 점수 **720점** · 채점 50문항 + 미채점 15문항 · 비중 30/26/22/22는 있다). `DVA-C03.json`을 만들려면 인증 페이지 같은 별도 공식 출처가 필요하다 — **노트의 판정이 지금도 맞다.**

### P3-11 (DVA). 「시험 범위 전환 경고」가 라이브 전에 유효한지 재확인이 필요하다

- 공식 가이드 첫 페이지가 적는다: *"이 시험은 업데이트 중입니다. **2026년 12월 1일부터** 업데이트된 버전의 시험(DVA-C03)에 등록할 수 있습니다. **2026년 11월 30일까지** 최신 버전의 시험(DVA-C02)에 응시할 수 있습니다."*(실측)
- DVA 12편은 이 전환을 전제로 쓰였다. **공개 시점(12월)이 되면 이 문장은 과거형이 되므로**, 각 문서의 `⚠️ C02에서 바뀐 것` 절이 「지금 바뀌는 중」처럼 읽히지 않는지 공개 직전에 한 번 훑는 것이 좋다. 이것은 사실 오류가 아니라 **시점 표현**의 문제다.

---

## 5. 확인했고 문제 없던 것 (대조군)

> 「검토했다」의 증거다. 특히 **§5-5는 기존 보고·노트의 판정이 틀렸음을 실측으로 확인한 자리**다.

### 5-1. 표기 (축 G) — 전역 0건이 유지된다

| 검사 | CLF | DVA | 방법 |
|---|---|---|---|
| `[텍스트](링크)` in `.md` | **0** | **0** | `content_format_test.dart` 전역 불변식 + 독립 재스캔 |
| 단일 `*이탤릭*` in `.md` | **0** | **0** | 같음 |
| `[텍스트](링크)` in 문항 301개 | **0** | — | 전수 파이썬 스캔 |
| 단일 `*이탤릭*` in 문항 301개 | **1** (P3-1) | — | 같음 |
| `**굵게**` in 문항 본문·출처 제목 | **0 · 0** | — | 같음(= 평문 렌더를 작성자가 알고 있었다) |
| 서비스명 한글 음차 | 없음 | 없음 | `Quick Sight`·`Amazon Quick` 등 공식 표기 사용 확인 |

### 5-2. 정답 쏠림 — **셔플로 학습자에게 보이지 않는다**

- **실측 분포**: `correct` = 0 **228** / 1 **32** / 2 **27** / 3 **14** (0이 **75.7%**)
- 축 F의 기준(60% 이상)을 크게 넘지만 **결함이 아니다.** 문항이 학습자에게 가는 **세 경로 모두 보기를 셔플**한다(실측):
  - `lib/pages/quiz_page.dart:40` — `applyOptionOrders(sampled, randomOptionOrders(sampled, rng))`
  - `lib/pages/review_page.dart:77` — 같은 함수
  - `lib/data/mock_exam.dart:85` — `out[q.id] = [for (…) i]..shuffle(rng)`
- 따라서 저장된 인덱스는 학습자에게 보이지 않는다. ⚠️ 다만 **문항을 교체·수정할 때 `correct`를 옮기면 `wrongExplanations`의 키 집합을 함께 바꿔야** 한다(`clf_supplement_questions_test.dart`의 계약).

### 5-3. 작성 과정 메모 (축 F) — **0건**

`확인되지 않`·`원문에 나오지 않`·`공식 문서에 없`·`확인 필요`·`미확인`·`불확실`·`추정`·`TODO`로 301문항 전수 스캔했다. 걸린 14건을 하나하나 열어 보니 **전부 자연어 용례**였고 작성자의 검증 상태 서술은 없다.
- `clf-t2-3-q13` 지문의 `정확히 언제·어떻게 새어 나갔는지는 확인되지 않았다` — **시나리오 서술**
- `clf-t3-6-q5` 오답 근거의 `접근 패턴이 불확실한 데이터` — **S3 Intelligent-Tiering 설명**
- `clf-t1-4-q8`·`clf-t4-2-q1`~`q10`의 `추정` 12건 — **전부 비용 「추정」(Pricing Calculator) 문맥**

### 5-4. 수치·상한·기본값 — 공식과 일치 확인 (CLF)

| 문서/문항 | 주장 | 공식 근거 |
|---|---|---|
| `t2-3.md:162` | 루트·IAM 사용자 **MFA 기기 최대 8개**, **SMS MFA 지원 종료** | IAM 사용자 가이드 |
| `t2-1.md:178` | **2023년 1월 이후 신규 객체에 SSE-S3 기본 암호화** | S3 사용자 가이드 |
| `clf-t2-2-q9` | KMS 키는 **FIPS 140-3** 검증 HSM, 암호화되지 않은 채 KMS를 떠나지 않음 | `kms/latest/developerguide/overview.html` |
| `clf-t2-2-q7` | CloudTrail **Event history 최근 90일** | `cloudtrail-user-guide.html` |
| `clf-t2-2-q18` | CloudFront용 ACM 인증서는 **us-east-1** | `acm/latest/userguide/acm-overview.html` |
| `clf-t1-1-q8` | 각 리전 **최소 3개** 물리적 분리 AZ | `aws.amazon.com/about-aws/global-infrastructure/` |
| `t3-3.md:141` | Lambda 함수 **한 번에 최대 15분** | Lambda 개발자 안내서 |
| `clf-t4-1-q3` | Spot **최대 90%** 할인 | `aws.amazon.com/ec2/spot/` |
| `clf-t4-2-q2` | Cost Explorer 과거 **13개월** | `cost-management/.../ce-advanced-cost-analysis.html` — *"the current month and up to the previous 13 months"* |
| `clf-t4-3-q3` | Enterprise **비즈니스 크리티컬** 시스템 다운 15분(프로덕션 다운은 1시간) | `aws-support-plans.html` — *"designated TAM assignment, 15-minute response times"* |
| `t3-6.md:93`, `clf-t3-6-q1`·`q11` | S3 **99.999999999%** 내구성 | `storage-class-intro.html` |
| `clf-t2-3-q1` 외 | 루트 전용 작업 목록(계정 해지·루트 이메일/암호·RI Marketplace 판매자 등록·IAM 권한 복구) + **Support 플랜 변경은 2022년 이후 IAM으로도 가능** | `IAM/latest/UserGuide/id_root-user.html` |

### 5-5. ⚠️ 기존 판정이 **틀렸음을 확인한** 자리 — 고치면 오히려 나빠진다

이 네 건은 2026-07 감사나 그 파생 기록이 **「오류」로 올려 둔 것인데 실측 결과 문서가 옳다.** 컨트롤러가 그 보고를 그대로 집행하면 **멀쩡한 문서를 망가뜨린다.**

| # | 기존 판정 | 실측 결과 | 근거 |
|---|---|---|---|
| 1 | `DOC-CLF-308`/`DOC-SAA-410` — Cost Explorer **「향후 ~18개월 예측」은 오류**(공식은 예측 12개월), Phase A, 확신 「높」 | **문서가 옳다.** `t4-2.md:72`·`clf-t4-2-q2`·`clf-t4-2`의 발화문(seg012)까지 **전부 그대로 둬야 한다** | `https://aws.amazon.com/aws-cost-management/aws-cost-explorer/faqs/` — *"Cost Explorer estimates your cost and usage for the **next 18 months at monthly granularity** and for the next 3 months at daily granularity"* |
| 2 | `DOC-CLF-106` — **CodeCommit 신규 고객 중단**(2024-07)인데 정직성 메모가 없다, Phase B | **메모를 달면 틀린다.** CodeCommit은 **2025-11-25에 신규 고객에게 다시 열렸다.** `t3-1.md`의 CodeCommit 서술(행 178·186·292)과 정답 문항 `clf-t3-1-q20`은 **현재 상태로 정확하다** | `https://docs.aws.amazon.com/codecommit/latest/userguide/history.html` — 문서 이력 표 최상단: *"AWS CodeCommit is now available to new customers. … \| **November 25, 2025**"* / `welcome.html`에 **중단 배너가 없다**(Audit Manager·Kendra와 대조) / `https://aws.amazon.com/blogs/devops/aws-codecommit-returns-to-general-availability/` |
| 3 | `DOC-CLF-302` — `AppStream 2.0 = Amazon WorkSpaces Applications 개명` 주장은 **감사자 컷오프 밖, 라이브 확인 필요** | **문서가 옳다.** `t3-8.md`의 `AppStream 2.0(현재 WorkSpaces Applications)` 병기를 유지한다 | `https://docs.aws.amazon.com/appstream2/latest/developerguide/doc-history.html` — 같은 `appstream2` 경로의 가이드 제목이 **「Amazon WorkSpaces Applications Administration Guide」**이고 본문이 *"the WorkSpaces Applications service"*로 적는다. ⚠️ 다만 **공식 CLF 「범위 내」 목록은 아직 `Amazon AppStream 2.0`으로 적는다** — 신·구 병기가 정확히 맞는 처리다 |
| 4 | `DOC-CLF-304` — `t3-8`의 묶음명 **「고객 지원」은 오기**, 공식 범주명은 **「고객 참여(Customer Engagement)」**, Phase A | **문서가 옳다.** 공식 한국어 범주명이 **「고객 지원」**이다(앵커는 `customer-enablement`). 「고객 참여」라는 범주는 공식 목록에 **없다** | `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-in-scope-services.html` — Topics 목록: 분석 · 애플리케이션 통합 · 비즈니스 애플리케이션 · 클라우드 재무 관리 · 컴퓨팅 · 컨테이너 · **고객 지원** · 데이터베이스 · … (「고객 참여」 0건) |

### 5-6. 2026-07 감사의 CLF 항목 중 **실제로 고쳐진 것** (회귀 없음 확인)

| ID | 당시 지적 | 현재 상태 |
|---|---|---|
| `DOC-CLF-102` (H) | Support 플랜 변경을 「루트 전용」으로 단정 | **고쳐졌다.** `t2-3.md:128`·`:242`·`:291`과 `clf-t2-3-q1` 해설 모두 「2022년 이후 IAM 권한으로도 가능」 메모를 담는다 |
| `DOC-CLF-309` (H) | Enterprise 「프로덕션 중요 케이스 15분」 | **고쳐졌다.** `t4-3.md:70`이 「비즈니스 크리티컬(시스템 다운) 케이스 15분 응답」이고 **발화문(clf-t4-3 seg012의 `audioSummary`)도 「비즈니스 크리티컬 시스템 다운 시 15분 응답」으로 교정돼 있다.** `clf-t4-3-q3` 해설은 프로덕션 다운 1시간 주석까지 담는다 |
| `DOC-CLF-203` (M) | 11 9s를 「1,000만 개 중 1개 미만」으로 왜곡 | **고쳐졌다.** `t3-6.md:93`은 `99.999999999%(eleven 9's) 내구성으로 설계`뿐이고 왜곡 표현이 없다(전수 `grep`에서 `1,000만 개` 0건) |
| `DOC-CLF-305` (M) | SP 72%와 완전 유연을 결합 | **md·오디오는 고쳐졌고 문항만 남았다** → P1-2 |
| `DOC-CLF-310`·`311` (L, Phase B) | 「Business Support+ · 2027-01-01 단종」 주장이 컷오프 밖 | **주장은 전부 사실로 확인됐다**(P1-4 ④). 단 「가이드가 전통 분류를 명시」 절만 거짓 |
| `DOC-CLF-002` (M) | 도메인 2가 최대라는 오기 | **고쳐지지 않았다** → P1-1 |
| `DOC-CLF-101` (M) | Audit Manager 중단 연도 | **고쳐지지 않았다** → P1-3 |

### 5-7. 오디오 전파 — 번지지 **않은** 것

- **t4-1 Savings Plans**: 발화문(seg025 `enrichedScriptText`)이 `컴퓨트 세이빙스 플랜 … 최대 66퍼센트 … 이씨투 인스턴스 세이빙스 플랜 … 최대 72퍼센트`로 **교정돼 있다.**
- **t4-3 Enterprise 15분**: 발화되는 `audioSummary`가 **교정돼 있다**(§5-6).
- **`Business Support+`의 `+` 발음 깨짐**: `scriptText`에서 렉시콘이 `+`를 「그리고」로 바꿔 `Business Support 그리고`가 된 자리가 5곳 있으나, `_spoken_body`가 **`enrichedScriptText`를 우선**하고 그쪽은 「비즈니스 서포트 플러스」로 옳게 읽는다 → **음성에는 들어가지 않는다.** 다만 P1-4 수정 시 대본을 손대면 **`enrichedScriptText`를 함께 고쳐야** 이 보호가 유지된다.
- **`sourceHash` 불일치는 19편 전부**다. `gen_lecture_audio.py:533`의 게이트가 이를 `hard: stale: script.sourceHash != 현재 md`로 보고한다. 원인은 **2026-10-29 이탤릭 평문화 PR이 md 19편 전부를 바꿨기 때문**이고(별표만 지운 변경) **발화 내용에는 영향이 없다.** ⚠️ 그래도 **이 상태에서는 게이트가 늘 빨간색이라 「진짜 stale」을 가려 준다** — P1 수정으로 재합성할 때 19편의 해시를 함께 갱신하는 것이 좋다.

### 5-8. DVA — 수치·범위·규율 확인 (공식 실측)

| 문서 | 주장 | 공식 근거 |
|---|---|---|
| 12편 프런트매터 | `domainWeightPct` 30·26·22·22, `domainName` = 도메인 페이지 H1 | `developer-associate-03.html` 「내용 개요」 30/26/22/22 · 저작 결정 D-01과 일치. `dva_doc_format_test.dart`의 `domainNames` 표와도 일치 |
| `dva-t3-1.md:186`·`:338` | C03 Developer Tools는 **Amplify · CloudShell · CodeArtifact · CodeBuild · CodeDeploy · CodePipeline · X-Ray**뿐, **CodeCommit은 없다** | `dva-03-in-scope-services.html` — **글자 그대로 일치**(7종) |
| `dva-t3-3.md:72` | CodePipeline 작업 **6종**(source·build·test·deploy·approval·invoke) | `codepipeline/latest/userguide/actions.html` — *"CodePipeline provides support for **six** types of actions: Source, Build, Test, Deploy, Approval, Invoke"* + Go SDK `ActionTypeId` enum 동일 |
| `dva-t3-3.md:179` | 수동 승인은 **7일** 안에 응답 없으면 실패 | CodePipeline 사용자 가이드 |
| `dva-t2-2.md:131` | ACM 유효기간 **198일**, 만료 **45일 전** 갱신 시도 | `acm/latest/userguide/dns-renewal-validation.html` — *"Certificates with a 198-day validity period renew **45 days** before expiration"* · `email-validation.html` — *"ACM certificates are valid for **198 days**"* |
| `dva-t2-2.md:364` | CloudFront 필드 수준 암호화 **최대 10개 필드 · 필드당 16 KB · 본문 1 MB · RSA 2048** | `AmazonCloudFront/latest/DeveloperGuide/cloudfront-limits.html` 「Quotas on field-level encryption」 — 16 KB / 10 / 1 MB **전부 일치** |
| `dva-t3-2.md:75`·`:126` | Lambda X-Ray 샘플링 **초당 1건 + 5%**이고 **함수에서 바꿀 수 없다** | `lambda/latest/dg/services-xray.html` — *"The sampling rate is 1 request per second and 5 percent of additional requests. **You can't configure the X-Ray sampling rate for your functions.**"* ⭐ **범위를 Lambda로 좁힌 것이 정확하다** — 일반 X-Ray 문서는 *"You can configure X-Ray to modify the default sampling rule"*이라 범위를 안 좁히면 틀린 문장이 된다 |
| `dva-t4-3.md:74`·`:114` | 동시성 계정 기본 **1,000** · 함수 예약 합계 **최대 900**(100 유보) · 초당 요청 한도 = 동시성 × 10 | Lambda 개발자 안내서 |
| `dva-t2-1.md:183` | IMDSv2 토큰 **TTL 최대 6시간** | `AWSEC2/latest/UserGuide/configuring-instance-metadata-service.html` — *"a minimum of one second and a maximum of **six hours**"* |
| `dva-t2-1.md:264` | `GetFederationToken` **15분~36시간**(기본 12시간) | STS API 참조 |
| `dva-t3-3.md:69`·`:126` | **「Fargate면 `minimumHealthyPercent` 무시」는 과도한 일반화** — `CODE_DEPLOY`·`EXTERNAL` + Fargate일 때만 | ⭐ **조사 노트 G-05가 스스로 과도하게 일반화했던 것을 문서가 바로잡아 적었다.** `AWS::ECS::Service DeploymentConfiguration` |
| `dva-t2-2.md:364` | DynamoDB **파티션 키·정렬 키는 항상 `SIGN_ONLY`** | `database-encryption-sdk/.../DDB-encrypted-and-signed.html`(교체 정본) + AWS 보안 블로그 *"The partition and sort key should always be set as SIGN_ONLY"* |

**조사 노트의 미확인 항목(G-11~G-18)을 실제로 쓰지 않았는지 전수 확인** — 전부 **0건**:
`InvokeGuardrailChecks` 0 · `Crew` 0 · `Powers` 0 · `ksk_` 0 · (G-16 CloudFront 서명 URL 만료 상한을 수치로 단정한 자리) 0. ⭐ **저작자가 자기 노트의 미확인 목록을 지켰다.**
그리고 **범위 판정 서술이 「목록에 없다 ≠ 범위 밖」을 명시적으로 구분**한다 — `dva-t1-1.md:381`: *"⚠️ 다만 「목록에 없다」와 「범위 밖이다」는 다릅니다 — Rekognition은 **명시된 범위 밖**이고, Q Developer는 **어느 목록에도 없는** 경우입니다."* 이 레포의 측정 규율이 콘텐츠에까지 들어간 드문 예다.

### 5-9. DVA — 내부 일관성 (수치 교차 대조)

12편에 반복되는 수치를 전수 `grep`으로 교차 대조했고 **어긋난 쌍이 없다**: Lambda 압축 해제 **250 MB**(t1-2 3곳 · t3-1 3곳 동일) · 메모리 **128~10,240 MB** · `1,769 MB ≈ 1 vCPU`(t1-2 · t4-3 동일) · 타임아웃 **3초/900초** · 페이로드 **6 MB/1 MB** · 계층 **5개** · 환경 변수 **4 KB** · DynamoDB 항목 **400 KB** vs `BatchWriteItem` **16 MB** · API Gateway **29초/30초** · KDS 샤드 **1 MB/s·1,000 rec/s · 2 MB/s·5 TPS** · 사전 서명 URL **7일 / 콘솔 12시간**.

---

## 6. 측정 한계 — 못 본 것과 그 이유

### 6-1. 깊이를 줄이지 않고 범위를 줄인 곳

| 대상 | 전문 통독 | 기계 전수 | 못 본 것 |
|---|---|---|---|
| CLF 문항 301개 | **9개 뱅크**(t1-1·t1-2·t1-3·t1-4·t2-1·t4-1·t4-2·t4-3 전문 + t2-2·t2-3 앞부분) | **301개 전부** — 표기 · 작성 메모 · 과도한 일반화 어휘 · 중복(지문·정답 보기) · 범위 외 서비스(정답/오답/언급 구분) · 수치·상한·기본값 문장 추출 · 출처 URL | **t2-4 · t3-1~t3-8 (9개 뱅크, 약 135문항)의 지문·오답 근거 전문.** 기계 스윕이 짚은 자리는 열어 봤지만 **「정답이 둘인가」·「참인 보기를 오답으로 뒀는가」는 전문을 읽어야 보인다** — 이 9개 뱅크에 대해서는 **축 A의 ①②를 수행하지 못했다** |
| CLF 학습문서 19편 | **전문 통독 없음** | 19편 전부 — 수치·절대 단정 문장 추출 · 서비스명 전수 · 도메인 비중 전수 · 표기 전역 가드 | **각 문서의 §개념 본문·🧠 원리 블록 전문.** 원리 블록은 「구조에서 따라오는 추론」을 적는 층이라 **축 C(귀속 층)를 체계적으로 보지 못했다** |
| CLF 오디오 대본 19편 | 발화 필드 표적 검색 | 19편 전부 — `sourceHash` 대조 · 세그먼트별 `sourceExcerpt` ↔ md 정규화 대조 · 발화 필드 패턴 검색 | **mp3를 듣지 않았다.** 대본 텍스트와 음성이 일치한다는 보장은 `audio_meta.json`뿐이고 나는 그것을 검증하지 않았다 |
| DVA 학습문서 12편 | **전문 통독 없음** | 12편 전부 — 프런트매터 · 수치 교차 대조 · 범위 서술 · 조사 노트 미확인 항목 사용 여부 · 출처 URL 241개 | **각 문서의 본문·🧠 원리·자가 점검 전문.** 12편 516 KB이고 라이브가 아니어서 CLF 뒤로 미뤘다 |

### 6-2. 측정이 한 번 무효였던 일

**백그라운드 셸에 네트워크가 없었다.** 1차 URL 측정 390개가 전부 `000 r=0`으로 돌아왔고, **대조군도 `000`이라 측정 무효**로 판정해 포그라운드에서 전량 재측정했다. 대조군을 넣지 않았다면 **「390개 전부 죽었다」는 보고를 썼을 것**이다.

### 6-3. 판정을 보류한 자리

| 항목 | 왜 보류했는지 | 닫는 방법 |
|---|---|---|
| `repost.aws/knowledge-center` `403` | 이 레포는 같은 `403`이 **봇 차단**이었던 이력이 있다. UA 위조는 쓰지 않았고 **내장 브라우저로 열어 보지 못했다** | 컨트롤러가 브라우저로 한 번 열어 본다 |
| Storage Gateway 교체 정본(§P2-A #9) | 가이드가 **게이트웨이 유형별로 분리**됐고(`vgw`는 살아 있다) CLF 인용 맥락은 「캐시된 파일 시스템」이라 **S3 File Gateway 쪽**이 맞다. 그 가이드의 현행 슬러그를 확정하지 못했다 | `docs.aws.amazon.com/storagegateway/`에서 유형별 가이드 목록을 확인한 뒤 인용별로 고른다 |
| DVA `dva-03-service-mentions` · `dva-03-comparison` 본문 | 두 페이지의 **존재만 확인**했고 내용을 읽지 않았다 | P3-9를 집행하기 전에 읽는다 |
| EC2 역할 자격 증명 「보통 6시간」(§P2-J) | **「틀렸다」고 단정하지 않았다.** 그 수를 적는 공식 페이지를 찾지 못했을 뿐이고, 찾을 페이지(`iam-roles-for-amazon-ec2-retrieve-creds.html`)는 소멸했다 | IMDS 자격 증명 수명을 적는 현행 페이지를 찾는다 |
| Trusted Advisor 「500+ 점검」(§P2-H) | 같은 이유 — **인용 페이지에 없다**는 것만 확인했다 | `trusted-advisor-check-reference.html`을 전수로 세면 수가 나올 수 있다 |

### 6-4. 처음부터 범위 밖으로 둔 것

- **영문 시험 가이드와의 대조.** 한국어 가이드만 읽었다. AIF 트랙에서 **한국어판과 영문판이 다른 자리**가 발견된 이력이 있으므로(목표 3.2.1의 「모델 잠재 공간」), CLF·DVA에도 같은 분기가 있을 수 있다.
- **다른 자격증 파일.** SAA·SOA·DEA·MLA·AIF는 비교 목적으로만 읽었고 보고하지 않았다(지시된 범위 고정).
- **코드·테스트 수정 가능성 판정.** 제안 수정안이 기존 가드와 충돌하는지는 **해당 테스트를 읽어** 확인했지만, `flutter test`·`flutter analyze`는 돌리지 않았다(지시대로 컨트롤러 몫).
- **`audio_meta.json`·mp3 무결성.** `publish_audio.py --verify-all` 류의 게이트를 돌리지 않았다.

---

## 7. 검토 중 내 판정이 틀렸다가 바로잡힌 자리

> 이 보고서의 신뢰도를 읽는 사람이 가늠할 수 있도록, **내가 먼저 틀렸던 다섯 자리**를 적는다. 다섯 건 모두 **대조군이나 실측이 잡아냈다.**

1. **CodeCommit을 「닫힌 서비스」로 분류하려 했다.** 2026-07 감사가 `DOC-CLF-106`으로 그렇게 적어 뒀고 나도 그 전제로 「정직성 메모 부재」를 P2에 올리려 했다. 그런데 `welcome.html`을 열어 보니 **Audit Manager·Kendra와 달리 중단 배너가 없었다.** 문서 이력을 세어 보니 **2025-11-25에 신규 고객에게 다시 열렸다.** 메모를 달라고 권고했다면 **멀쩡한 문서에 거짓을 넣는 수정**이 됐다. (§5-5 #2)

2. **오디오 전파를 두 번 거꾸로 판정했다.** 1차 탐침이 `script.json`의 **모든 필드**를 한 덩어리로 봐서, `t4-3`의 Enterprise 15분과 `t4-1`의 Savings Plans를 **「대본에 교정이 반영되지 않았다」**로 판정했다. `gen_lecture_audio.py`의 `_spoken_body`를 읽고 나서야 **`sourceExcerpt`는 발화되지 않고, `table`은 `audioSummary`, 나머지는 `enrichedScriptText`가 발화된다**는 것을 알았다. 다시 재니 **두 건 모두 발화문은 교정돼 있었다**(§5-7). 즉 **보고할 뻔한 결함 2건이 실제로는 대조군**이었다.

3. **리터럴 탐침이 교정을 못 알아봤다.** `t4-1`의 SP 교정 여부를 `Compute SP`라는 문자열로 쟀는데 **발화문은 「컴퓨트 세이빙스 플랜」**이라 0건으로 나왔다. 음차 표기를 고려하지 않은 탐침이었다. 이 레포 메모의 **「탐침은 동의어를 함께 센다」**가 **한국어 음차**에도 적용된다는 것이 이번에 확인됐다.

4. **URL 측정 1차가 전량 무효였다**(§6-2). 대조군이 없었다면 그대로 보고했을 것이다.

5. **`python`이 조용히 실패했다.** 이 환경에서 `python`은 **exit 49**(스토어 스텁)이고 `py`를 써야 한다. 그리고 `py`의 기본 stdout 인코딩이 `cp949`라 **한국어 출력이 `UnicodeEncodeError`로 죽는다** — `PYTHONIOENCODING=utf-8`을 붙여야 한다. 첫 두 번의 집계가 그렇게 실패했다.

---

## 부록 A. 재현 명령

```sh
# 출처 URL 실측 (대조군 → 본 측정 → 대조군)
curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}\n" \
  "https://docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html"   # 200 r=1 이어야 한다
curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}\n" \
  "https://aws.amazon.com/what-is/zz-bogus-control/"                        # 404 r=0 이어야 한다
```

```sh
# 도메인 비중 오기 전수 (md + 발화 대본)
grep -rn "가장 큽니다\|가장 크고" D:/workspace/awc-docs/flutter_app/assets/content/clf/*.md
```

```sh
# CLF 문항 전수 표기·메모·범위 스윕 (python 아니라 py, 그리고 PYTHONIOENCODING 필수)
PYTHONIOENCODING=utf-8 py <스크립트>
```

## 부록 B. 이 검토가 읽은 레포 측 계약

`flutter_app/test/` — `content_format_test.dart`(전역 표기 불변식) · `content_enrichment_test.dart`(CLF 19편 + SAA·SOA의 🔤/🧠/자가 점검 마커) · `clf_supplement_questions_test.dart`(CLF 7개 Task 문항 스키마) · `quicksight_naming_consistency_test.dart`(Quick Sight 공존) · `content_index_audio_test.dart`(CLF 19편 오디오 승인) · `source_url_retired_test.dart`(SOA·DEA 은퇴 URL 22건) · `dva_doc_format_test.dart`(DVA 12편 포맷 + `domainName`) · `all_content_parse_test.dart` · `official_sources_test.dart`
`flutter_app/tool/gen_lecture_audio.py` — `sourceHash` 계산(`:373`) · stale 게이트(`:533`) · 발화 본문 선택 `_spoken_body`(`:915`)
`flutter_app/lib/content/quiz_widgets.dart:393` — 문항 해설은 평문 `Text`
`flutter_app/lib/pages/quiz_page.dart:40` · `review_page.dart:77` · `data/mock_exam.dart:85` — 보기 셔플
`docs/audits/2026-07/03-docs-facts.md` — CLF 26건(H2·M9·L15)
`docs/content-research/DVA-C03/` 7편 — 저작 결정 D-01~ · 갭 G-01~G-18
