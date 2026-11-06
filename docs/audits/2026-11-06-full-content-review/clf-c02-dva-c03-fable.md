# CLF-C02 · DVA-C03 전수 검토 — 2차 패스 (Fable 5.1, 2026-11-06)

> 1차 보고서 `clf-c02-dva-c03.md`(Opus 5)를 **다른 모델이 다시 재는** 패스다. 1차 파일은 수정하지 않았고, 이 파일 하나만 새로 만들었다. 레포 콘텐츠·테스트·대본은 한 바이트도 바꾸지 않았다. git 명령·`flutter test`·`flutter analyze`는 쓰지 않았다.

**결론 한 줄:** 1차 발견 **25건**(라벨 기준 — 1차 집계표의 「26」은 산술 오류, §3-1)을 전부 다시 쟀다. **확정 23 · 기각 0 · 수정 2 · 신규 5.** 1차가 「기존 감사가 거꾸로였다」고 한 4건은 **네 건 모두 두 번째 방법(curl 원문 HTML)으로 다시 확인**됐고 그중 하나(Cost Explorer 18개월)는 **1차가 든 근거보다 더 가까운 근거**(문항 자신이 인용하는 페이지)가 있었다. 음성까지 번진 결함은 **P1 계열 7개 세그먼트**(1차 §1-4는 4로 적었다 — 자기 본문의 3+1+3을 더하지 않은 과소) + **P2·P3 계열 36개 세그먼트**다(§4).

---

## 0. 2차 패스 계획

### 0-1. 무엇을 다르게 했는가

| 1차의 약점 | 2차의 처리 |
|---|---|
| 발견마다 개소 수를 **보고된 자리만** 셌다 | **모든 발견 항목을 레포 전역으로 다시 쓸었다** — `assets/content/*/*.md` · `*.questions.json` · `assets/audio/*/*/script.json`(발화 필드만) · `exam_guides/*.json`, CLF·DVA 밖까지. 스크립트 `global_sweep.py`(스크래치패드) |
| 탐침이 리터럴이었다 | **어미·동의어·음차를 함께** 쟀다 — 「전통적 분류」는 `전통`으로, 「도메인 2 … 30% … 가장 크다」는 `(30\|34)\s*(%\|퍼센트)…가장 (크\|큽\|큰)`으로, 「Wavelength」는 음차 「웨이브렝스」까지 |
| 공식 근거를 `aws___read_documentation` 한 방법으로 읽었다 | **두 번째 방법**으로 `curl -sL` 원문 HTML을 받아 `pages/*.html`에 보관하고 문장을 `grep`했다. 1차의 4건 뒤집힘은 전부 이 방법으로 다시 확인 |
| CLF 문항 뱅크 9개(t2-4 · t3-1~t3-8)와 DVA 12편의 **본문을 읽지 않았다**(1차 §6-1) | **전부 전문으로 읽었다** — CLF 9개 뱅크 약 135문항(`bankA/B/C.txt` 덤프), DVA 12편 전문 |
| `repost.aws` 403을 보류했다 | **내장 브라우저로 열어 확인**했다(§1 P2-B) |
| Storage Gateway 교체 정본을 못 정했다 | 유형별 가이드 4종을 재서 **정본을 확정**했다(§1 P2-A #9) |

### 0-2. 측정 규율

- URL은 `curl -sL -o … -w "%{http_code} r=%{num_redirects}"`로 재고 **`200 r=0`만 통과**. 대조군 2개를 매 묶음에 넣었다 — `docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html` → `200 r=1`(가이드 인덱스로), `aws.amazon.com/what-is/zz-bogus-control/` → `404 r=0`. 둘 다 문서대로 나왔으므로 측정은 유효하다.
- 「없다」는 **두 추출(태그 제거 + 공백 정규화)** · **동의어** · **대조군**(같은 페이지의 있는 문장)을 거친 뒤에만 적었다.
- 공식이 갈리면 단정하지 않았다(P3-7 Aurora, N-3 재시도).
- ⚠️ **백그라운드 셸에는 네트워크가 없다**(1차 §6-2) — 모든 curl은 포그라운드에서 돌렸다. `python`은 exit 49라 `py -I` + `PYTHONIOENCODING=utf-8`.

### 0-3. 판정 용어

- **확정** — 1차 판정이 그대로 맞다(개소 수가 바뀐 경우 「확정(개소 수정)」으로 표시).
- **수정** — 발견 자체는 맞지만 판정·정본·심각도가 바뀌었다.
- **기각** — 1차가 틀렸다.

---

## 1. 1차 발견 재검증

### 1-1. 집계

| | 1차 라벨 수 | 확정 | 수정 | 기각 |
|---|---|---|---|---|
| **P1 (CLF)** | 4 | **4** (개소 수정 2) | 0 | 0 |
| **P2 (CLF 8 · DVA 2)** | 10 | **8** (개소 수정 3) | **2** (P2-A · P2-B) | 0 |
| **P3 (CLF 8 · DVA 3)** | 11 | **11** (개소 수정 1) | 0 | 0 |
| 계 | **25** | **23** | **2** | **0** |

⚠️ 1차 §1-2 표는 P2를 「CLF 9 · DVA 2 = 11」, 합계 26으로 적었는데 **본문의 P2 라벨은 A~J 열 개**(CLF A~H 8 · DVA I·J 2)다. 산술 오류이고 내용 누락은 아니다(§3-1).

### 1-2. CLF-C02

| # | 1차 판정 | 2차 재측정 (공식 URL + 실측) | 전역 재스윕 개소 | 판정 |
|---|---|---|---|---|
| **P1-1** 「도메인 2가 30%로 가장 크다」 | md 3 + 발화 3 | 공식 `cloud-practitioner-02.html` 내용 개요 24·30·**34**·12 재확인(curl 원문). 레포 `CLF-C02.json` `weightPct`도 34가 최대 | **md 3**(`t2-1.md:45` · `t2-2.md:65` · `t2-3.md:59`) · **발화 3**(`clf-t2-1`·`t2-2`·`t2-3` 각 seg006, 전부 `enrichedScriptText`) · 문항 0 · CLF 밖 0. 대조: `t3-2.md:46`과 `clf-t3-2` seg006은 「도메인 3 34% 최대」로 **옳게** 말한다. ⚠️ 1차의 좁은 탐침(`도메인 2…30%…가장`)은 발화를 **1곳**으로 셌고, 어미·단위를 푼 탐침(`30\s*(%\|퍼센트)…가장 (크\|큽\|큰)`)이 3곳을 잡았다 | **확정** (발화 개소는 1차 본문의 3이 맞고, 1차 §1-4의 총계만 틀렸다 — §4) |
| **P1-2** `clf-t4-1-q2` Compute SP 72% | 문항만 옛 서술 | `savingsplans/latest/userguide/plan-types.html` 원문: *"Compute Savings Plans … up to 66%"* / *"EC2 Instance Savings Plans … up to 72%"* 재확인 | `72%`+`Compute`/`Fargate`/`Lambda` 결합: **문항 1**(`clf-t4-1-q2` explanation + sources[0].title) · `t4-1.md:198` 참고자료 1(1차가 이미 적음) · 발화 0(seg025는 66/72를 **옳게** 가른다). CLF 밖: SAA에 72%는 **예약 인스턴스** 수치로만 2건(`saa_question_propagation_test.dart:391`·`saa_t2_t4_facts_test.dart:478`, 가드 자체) | **확정** |
| **P1-3** Audit Manager 「2024년 이후」+「가이드 명시」 | md 1 + 발화 1 | `audit-manager/latest/userguide/what-is.html` 배너 *"no longer open to new customers"*, `aws.amazon.com/audit-manager/` *"starting on 4/30/2026"*, 공식 가이드 작업 2.2 기술에 Audit Manager **0건** — 셋 다 curl 원문으로 재확인 | `Audit Manager…2024년`: **md 1**(`t2-2.md:223`) · **발화 1**(`clf-t2-2` seg051) · 문항 0. `Audit Manager를 거버넌스 서비스로 명시`: 같은 두 자리. 전역 「Audit Manager」 언급: clf md 12 · q 11 · 발화 3 / aif md 9 / mla md 1 · q 2 / guide 2 — **연도 오류는 CLF t2-2 한 계열뿐**이고 AIF는 「2026-04-30」으로 옳게 적는다(`aif_guide_v11_test.dart:278`의 금지 문구와 같은 방향) | **확정** |
| **P1-4** 「가이드가 전통 분류를 명시」 | md 3 + 발화 3 | 공식 가이드 작업 4.3 기술 전문 재확인: `고객 서비스 및 커뮤니티, 기본 지원, AWS Business Support+, AWS Enterprise Support, AWS Unified Operations`. `awssupport/latest/user/aws-support-plans.html`의 2027-01-01 단종 공지 재확인 | `전통` 느슨 탐침: **md 2**(`t4-3.md:77`·`:119`; `:134`는 「전통 분류인 Business」로 같은 전제) · **문항 3**(`clf-t4-3-q2`·`q11`의 「전통 분류」 병기 — 이것은 **옳은 병기**이고 결함이 아니다) · **발화 4** 중 **3이 결함**(`clf-t4-3` seg014·026·030), 1은 `clf-t3-5` seg012의 「전통적인 네트워크」로 **무관** | **확정(개소 수정)** — 발화는 3, 느슨 탐침의 4번째는 대조군 |
| **P2-A** 죽은 URL 12 | 12건 + 교체안 | **12건 전부 다시 쟀다 — 1차와 동일 신호**(`200 r=1` 10 · `r=2` 2). 교체안 12개도 전부 `200 r=0`. **#9 Storage Gateway 정본을 확정**: 유형별 가이드 셋이 모두 살아 있다 — `filegateway/latest/files3/what-is-file-s3.html`(S3 File Gateway) · `storagegateway/latest/tgw/WhatIsStorageGateway.html`(Tape) · `storagegateway/latest/vgw/WhatIsStorageGateway.html`(Volume). CLF `t3-6.md`·`clf-t3-6-q6`·`q15`의 인용 맥락(「캐시된 파일 시스템」·「온프레미스에서 S3를 파일로」)은 **S3 File Gateway**이므로 정본은 **`files3/what-is-file-s3.html`** | 1차와 같음(12) | **수정** — #9 「정본 미확정」 → 정본 확정. 나머지 11건은 확정 |
| **P2-B** `repost.aws` 403 | 보류 | **내장 브라우저로 `repost.aws/knowledge-center/get-aws-help`를 열었다 — 정상 렌더**(제목 *"How do I get help with my AWS account and resources?"*, Contact AWS Support 절까지 본문이 보인다). 즉 `403`은 **봇 차단**이고 죽은 링크가 아니다(레포 이력과 일치) | `clf-t2-4-q15` 1 | **수정** — 「보류」 → 「살아 있음, 출처 유지」. ⚠️ `num_redirects` 가드를 전역으로 걸 때 `repost.aws`는 **상태 코드 403을 통과로 예외 처리**해야 한다 |
| **P2-C** `CLF-C02.json` 6곳 낡음 | 6 | 공식 도메인 1~4 페이지 curl 원문에서 여섯 문구 재확인(Snowball 삭제 · Audit Manager 삭제 · Single Sign-On 병기 삭제 · SageMaker AI + Kendra 삭제 · AppSync 삭제 · 지원 플랜 교체) | `Developer Support` guide 1 · `Enterprise On-Ramp Support` guide 1 · `Single Sign-On` guide 1 + clf md 1 · q 2 · script 2(발화 0) — 레포 JSON 외에 `Single Sign-On` 병기가 CLF 콘텐츠 3곳에 더 있다(옛 이름 병기라 결함은 아님) | **확정** |
| **P2-D** 범위 외 서비스가 정답 5건 | 5 | `clf-02-out-of-scope-services.html` 원문에서 다섯 이름 재확인 | 정답 5건은 1차와 같다. **언급 전역**(음차 포함 발화 세그먼트): Wavelength clf md 8 · q 10 · 발화 **6** / Personalize md 12 · q 6 · 발화 **6** / CodeDeploy md 6 · q 9 · 발화 **6** / MemoryDB q 4 · 발화 0 / Billing Conductor q 4 · 발화 0. ⚠️ CLF 밖은 범위 판정이 다르므로(SAA·DEA·MLA·DVA는 각자 목록) 결함으로 세지 않는다 | **확정(개소 수정)** — 1차는 발화 전파를 세지 않았다 |
| **P2-E** 단종 예정 플랜 이름 문항 7 | 7 | `trusted-advisor.html`·`premiumsupport/faqs/`·`getting-started.html` 원문 재확인(*"Business Support+, Enterprise Support, or Unified Operations"*) | 문항 7은 같다. **발화 7 세그먼트**(`clf-t2-4` seg026 · `clf-t4-3` seg009·012·014·030·031·033 — 014·030은 P1-4와 겹침). `Developer Support` 문항 13건 언급(clf q) · `On-Ramp` 발화 2 | **확정(개소 수정)** — 음성 전파 7곳 추가 |
| **P2-F** 닫힌 서비스 정답 + 메모 없음 | 2 | `kendra/latest/dg/what-is-kendra.html` 배너 *"starting on July 30, 2026"* 재확인 | Kendra: clf md 16(`t3-7.md` **16회** — 1차의 「11회」는 과소) · q 18 · **발화 9 세그먼트**(12회) / mla md 6 · q 4. Audit Manager 발화 3 | **확정(개소 수정)** — md 11→16, 발화 9 추가 |
| **P2-G** `t3-8.md` 「범위 내」 표의 범위 외 7종 | 7 | 범위 내·외 페이지 원문 재확인 | `t3-8.md:150~157` 1 · **발화 2**(`clf-t3-8` seg034가 표를 그대로 읽고, seg042가 CloudShell을 범위 내로 말한다) | **확정(개소 수정)** — 발화 2 추가 |
| **P2-H** 「500+ 점검」 근거 없음 | 근거 미발견 | `trusted-advisor-check-reference.html`을 받아 세려 했으나 **본문이 JS로 그려져** 원문 HTML에 점검 제목이 없다(`<h3>` 0, `id=` 25개뿐). 인용 페이지(`aws-support-plans.html`·`trusted-advisor.html`·FAQ)에는 여전히 수치가 없다 | `500\+` clf q 1 | **확정** — 「인용 페이지에 없다」 유지. 총수 확인은 §5 |
| **P3-1** `clf-t2-3-q1` 단일 이탤릭 | 1 | — | **문항 전역**(5 자격증 `*.questions.json`) 재스윕: 단일 `*x*`는 **CLF 1건뿐**. SAA·SOA의 4건은 `/*`·`/static/*` 경로 글로브와 `* *` 표 구분자라 **이탤릭이 아니다** | **확정** |
| **P3-2** 프리 티어 md 0편 | md 0 | — | `프리 티어\|Free Tier`: clf **q 8**(`t4-1` 뱅크) · clf md 0 · 발화 0 / dva md 2 · saa md 2 · mla md 1 | **확정** |
| **P3-3** 프리 티어 2025-07-15 개편 | 1 | `free-tier.html`·`free-tier-plans.html` 재확인 | `clf-t4-1-q10` 1 | **확정** |
| **P3-4** Snowball 비중 | 10 문항 | 공식 1.3 기술에서 Snowball 삭제 재확인 | Snowball: clf md 31 · q 43 · **발화 11 세그먼트**(25회) / dea md 4 · q 3 / saa md 1 · q 6 · 발화 2 | **확정(개소 수정)** — 발화 11 추가 |
| **P3-5** `q2`↔`q12` 중복 | 1쌍 | — | `t4-2.questions.json` 두 문항 | **확정** |
| **P3-6** Cloud9·AppSync | 2 | — | Cloud9 clf md 1 · 발화 1 / AppSync clf md 2 · 발화 1 · dva md 3 · saa 5 | **확정** |
| **P3-7** Aurora 5배/3배 vs 6배 | 공식 갈림 | — | `최대 5배`: clf md 1 · q 3 · 발화 1 / saa md 1 · q 1 · 발화 1 | **확정** (단정 안 함 유지) |
| **P3-8** CLF 가이드 동기화 테스트 없음 | — | `flutter_app/test/`에 `clf_guide*` 0건 | — | **확정** |

### 1-3. DVA-C03

| # | 1차 판정 | 2차 재측정 | 판정 |
|---|---|---|---|
| **P2-I** 참고자료 URL 2건 | 소멸 1 + 인덱스 1 | `DDB-encryption-context.html` `200 r=1` → 인덱스(재확인), 교체 `DDB-encrypted-and-signed.html` `200 r=0`. `aiops/index.html` `200 r=1` → `aiops/`(같은 페이지) | **확정** |
| **P2-J** 「보통 6시간」 근거 없음 | 근거 미발견 | `dva-t2-1.md:183`의 IMDSv2 **세션 토큰 6시간**은 옳다(재확인). 역할 자격 증명 수명 **6시간**을 적는 공식 페이지는 2차에서도 찾지 못했다. 전역: `보통 6시간` dva md 2(`:204`·`:327`; `:280`은 표현이 달라 탐침에 안 걸리나 같은 전제) | **확정** — 「틀렸다」가 아니라 「인용 근거가 없다」 유지 |
| **P3-9** 보조 페이지 미인용 | 0건 | `dva-03-service-mentions.html`·`dva-03-comparison.html` 둘 다 `200 r=0`으로 **실재 확인**. ⚠️ 본문은 머리만 확인했다(§5) | **확정** |
| **P3-10** 전환 선결 3건 | 3 | `exam_guides/DVA-C03.json` 없음 · `content_index.dart`에 `dva` 0건 · 문항 0개 — 재확인 | **확정** |
| **P3-11** 시점 표현 | — | 12편 전문을 읽은 결과 「C02에서 바뀐 것」 절은 전부 **완료형**(「C03에서 ~로 들어왔습니다」)이라 12월 이후에도 어색하지 않다. 다만 `dva-t1-1.md:157`(N-3)처럼 **시점에 묶인 사실**이 있다 | **확정** (대상이 좁혀졌다 — N-3) |

### 1-4. 1차 §5-5 「기존 감사 판정이 거꾸로였다」 4건 — 두 번째 방법으로 재확인

| # | 1차 결론 | 2차 두 번째 방법(curl 원문 HTML) | 판정 |
|---|---|---|---|
| 1 | CE 「향후 18개월 예측」은 옳다(FAQ 근거) | ⭐ **문항 `clf-t4-2-q2`가 인용하는 바로 그 페이지** `cost-management/latest/userguide/ce-what-is.html` 원문에 *"forecast how much you're likely to spend for the next 18 months"*가 **세 번** 나온다. 1차는 FAQ만 들었는데 **더 가까운 근거가 문항 안에 이미 있다.** `ce-forecast.html`에는 기간 수치가 없다(1차 §6의 보류 사유였던 「사용자 가이드에 수치가 없다」는 **그 페이지**에만 해당) | **확정** — 근거가 강화됐다 |
| 2 | CodeCommit 2025-11-25 재개 | `codecommit/latest/userguide/history.html` 원문 이력 표 최상단 *"now available to new customers … November 25, 2025"* 재확인, `welcome.html` 배너 0건 | **확정** |
| 3 | AppStream 2.0 → WorkSpaces Applications | `appstream2/latest/developerguide/doc-history.html` 제목 「Amazon WorkSpaces Applications Administration Guide」 재확인. 범위 내 목록은 `Amazon AppStream 2.0` 유지 | **확정** |
| 4 | 범주명 「고객 지원」이 공식 | `clf-02-in-scope-services.html` 원문 Topics: 「고객 지원」 있음, 「고객 참여」 0건 | **확정** — 그리고 이 판정과 **어긋나는 라벨이 문항 1건에 남아 있다**(§2 N-1) |

---

## 2. 신규 발견

> 2차에서 읽은 CLF 뱅크 9개(약 135문항)·DVA 12편 전문에서 **새 사실 오류는 0건**이다. 아래 다섯은 라벨·출처·시점·커버리지 결함이고 전부 P3급이다.

### N-1 (CLF, P3). `clf-t3-8-q11`의 `skill`이 공식에 없는 범주명 「고객 참여」를 쓴다

- **위치** `flutter_app/assets/content/clf/t3-8.questions.json:287`
- **현재 문구** `"skill": "고객 참여 (Amazon Connect — 컨택 센터)"`
- **왜 문제인지** 공식 CLF-C02 범위 내 목록에서 **Amazon Connect는 「비즈니스 애플리케이션」** 범주다(실측: `clf-02-in-scope-services.html` 원문에서 「비즈니스 애플리케이션」 바로 아래 `Amazon Connect`). 「고객 참여」는 2026-07 감사 `DOC-CLF-304`가 **잘못** 제안한 그 이름이고(1차 §5-5 #4), md 쪽은 「고객 지원」으로 옳게 남았는데 **문항 라벨 하나가 그 오류를 들고 있다.** 레포 전역에서 「고객 참여」는 **이 1건뿐**(`t3-8.md` 0건).
- **공식 URL** `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/cloud-practitioner-02/clf-02-in-scope-services.html`
- **제안** `"skill": "비즈니스 애플리케이션 (Amazon Connect — 컨택 센터)"`. `correct`·`verified` 불변. 가드 충돌 없음(`skill` 문자열을 묶은 CLF 테스트 없음).

### N-2 (CLF, P3). `clf-t3-1` 문항 4건이 **SDK·API 서술의 출처로 Site-to-Site VPN 사용자 가이드**를 인용한다

- **위치** `clf/t3-1.questions.json` — `clf-t3-1-q3`·`q4`·`q6`·`q9`의 `sources` (`https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html`), 제목 `AWS Site-to-Site VPN User Guide — AWS SDK는 언어별 API를 제공하고 서명 계산·재시도·오류 처리 같은 연결 세부를 처리`
- **왜 문제인지** 인용 문장은 **그 페이지에 실재한다**(2차에서 확인 — VPN 가이드의 「API 접근」 상용구). 사실은 틀리지 않았다. 다만 **SDK·CLI·Query API의 구분을 가르치는 문항이 VPN 가이드를 정본으로 드는 것**은 학습자가 각주를 눌렀을 때 VPN 문서로 떨어지는 출처 결함이다 — 1차 §P2-A·2026-10 검수의 「소개 페이지만 달린 출처」와 같은 종류다.
- **제안** 정본을 `https://docs.aws.amazon.com/sdkref/latest/guide/overview.html`(AWS SDKs and Tools Reference Guide, `200 r=0` 실측)로 바꾸거나 **추가**한다. ⚠️ `aws.amazon.com/developer/tools/`는 `200 r=1`이라 쓰지 않는다.

### N-3 (DVA, P3·시점). `dva-t1-1.md:157`의 재시도 **opt-in 서술이 시점에 묶여 있다**

- **현재 문구** `새 동작은 \`AWS_NEW_RETRIES_2026=true\`로 **opt-in**해야 적용되고, 그때까지 Java·Python·Ruby·PHP·C++·CLI는 **legacy가 기본**(재시도 쿼터 없음)입니다.`
- **실측** `sdkref/latest/guide/feature-retry-behavior.html` 원문(2026-11-06): *"Set AWS_NEW_RETRIES_2026=true in your environment … Without this setting, your SDK uses pre-2026 retry behavior"*. 즉 **지금은 문서가 옳다.** ⚠️ 그러나 「그때까지」가 가리키는 **전환 시점을 원문 HTML에서 찾지 못했다** — 1차 패스 중 문서 도구로 읽었을 때 「2026년 11월 기본 전환」으로 읽힌 기억이 있으나 **원문 추출에서 재확인되지 않아 단정하지 않는다.**
- **왜 문제인지** DVA는 **2026-12 공개 예정**이다. 공개 시점에 기본값이 바뀌어 있으면 이 줄은 거짓이 된다. 레포 전역에서 `AWS_NEW_RETRIES_2026`은 **이 1건뿐**.
- **제안** 12월 전환 PR 직전에 같은 페이지를 다시 재서 ① 아직 opt-in이면 그대로, ② 기본이 바뀌었으면 「2026-11부터 기본」으로 고친다. 지금 손대지 않는다.

### N-4 (DVA, P3·커버리지). Lambda **Web Functions**가 12편에 없다

- **실측** `lambda/latest/dg/welcome.html`(DVA 출처 목록에 이미 있음)이 함수 유형을 **Event Functions · Web Functions**로 나눈다. 12편은 **Event Function 개명을 정확히 다룬다**(`dva-t1-2.md:39` · `dva-t4-1.md:45` 용어 메모, 출처 제목 「Types of metrics for Lambda Event Functions」) — 그런데 **Web Functions**는 0건.
- **판정** 공식 가이드 기술 문구에 Web Functions가 없으므로 **사실 오류가 아니다.** 문항 저작 전에 용어 메모 한 줄(「Web Functions는 HTTP 요청을 직접 받는 유형, C03 가이드 문구에는 없다」)을 둘지 결정만 하면 된다.

### N-5 (전역·집계). 1차 보고서 §1-2·§1-4의 **자기 집계 두 건이 본문과 어긋난다**

- §1-2: P2 CLF **9**로 적었으나 본문 라벨은 **8**(A~H) → 합계 26이 아니라 **25**.
- §1-4: 음성 전파를 **「2계열·4곳」**으로 적었으나 본문 P1-1(3) + P1-3(1) + P1-4(3) = **3계열·7곳**. 둘 다 산술이지 누락은 아니다. §3·§4에서 바로잡는다.

### 2-1. 신규 **대조군** — 2차에서 확인했고 문제 없던 것

| 대상 | 실측 |
|---|---|
| CLF 뱅크 9개(t2-4 · t3-1~t3-8, 약 135문항) 전문 | **정답 둘·참인 보기를 오답으로 둔 문항 0건.** 1차 §6-1이 「축 A ①②를 수행하지 못했다」고 적은 구멍이 닫혔다 |
| DVA 12편 전문 | **사실 오류 0건.** 스팟 재측정 — Lambda 예약 합계 「900 / 유보 100」(`configuration-concurrency.html` *"remaining 100 units … for Event Functions that aren't using reserved concurrency"*) · CodeDeploy 트리거 「배포 그룹당 10개」(`monitoring-sns-event-notifications.html` *"up to 10 triggers"*) · ElastiCache 서버리스 「3개 AZ」(`AmazonElastiCache/latest/dg/WhatIs.deployment.html` *"redundantly across three Availability Zones"*) · S3 MRSC 「정확히 3개 리전」 — 전부 문서와 일치 |
| `dva-t1-1.md:259` SQS 「메시지 최대 1 MiB」 | `quotas-messages.html` 원문 *"The maximum is 1,048,576 bytes (1 MiB)"* — **문서가 옳다.** 1차 패스 중 「API 참조 1 MiB / 콘솔 256 KB 갈림」으로 의심했으나 **정본 쿼터 페이지가 1 MiB**다 |
| `dva-t2-2.md:90` SSE-C 「2026-04부터 신규 버킷 기본 차단」 | `AmazonS3/latest/userguide/blocking-unblocking-s3-c-encryption-gpb.html` — **옳다**(2026-04 배포). 레포에서 이 변경을 반영한 곳은 **DVA가 유일**하고 SAA `saa-t1-5.md`·SOA·DEA·MLA의 SSE-C 서술(각 1건)은 변경 전 서술이다 — **CLF·DVA 범위 밖이라 보고만 한다**(§5) |
| `clf-t4-2-q2` CE 18개월 | 문항 자신의 출처 `ce-what-is.html`이 수치를 담는다(§1-4 #1) |

---

## 3. 1차가 과대·과소였던 것

### 3-1. 과대

| 항목 | 1차 | 2차 | 비고 |
|---|---|---|---|
| 발견 건수 합계 | 26 | **25** | P2 CLF 9→8 산술 오류(§N-5) |
| P2-B `repost.aws` | 「판정 보류·죽었을 수 있음」 | **살아 있음(봇 차단)** | 결함 아님 — 출처 유지. 심각도 0 |
| P2-A #12 `aiops/index.html` | 죽은 URL 12건에 포함 | `r=1`이지만 **같은 페이지** | 1차도 「위험도 최저」로 적었다. 가드 걸 때만 의미 |

### 3-2. 과소

| 항목 | 1차 | 2차 | 왜 과소였는가 |
|---|---|---|---|
| P1 음성 전파 총계 | §1-4 「4곳」 | **7 세그먼트** | 1차가 자기 본문(3+1+3)을 더하지 않았다 |
| P1-1 발화 탐침 | 좁은 정규식 1곳 | 3곳 | 「30%」↔「30퍼센트」·「가장 큽니다/크고」 어미를 풀어야 잡힌다 |
| P2-E 플랜 이름 | 문항 7, 음성 미집계 | 문항 7 + **발화 7** | 음성을 세지 않았다 |
| P2-F Kendra | `t3-7.md` 「11회」, 음성 미집계 | md **16회** + 발화 **9 세그먼트** | 리터럴 수가 틀렸고 음성을 세지 않았다 |
| P2-G `t3-8` 표 | md 1 | md 1 + **발화 2** | seg034가 표를 그대로 읽는다 |
| P2-D 범위 외 | 정답 5 | 정답 5 + **발화 18**(Wavelength 6 · Personalize 6 · CodeDeploy 6, 음차 포함) | 음차(「웨이브렝스」)를 안 센 리터럴 탐침 |
| P3-4 Snowball | 문항 10 | 문항 10 + md 31회 + **발화 11 세그먼트** | 음성을 세지 않았다 |
| §5-5 #1 CE 18개월 근거 | FAQ 1건 | FAQ + **문항 자신의 출처 `ce-what-is.html`** | 1차는 사용자 가이드 한 페이지(`ce-forecast`)만 보고 「수치 없음」으로 넘겼다 |
| §6-1 「못 본 것」 | CLF 뱅크 9 · DVA 12편 | **전부 읽음 → 새 오류 0** | 한계가 실재했지만 그 뒤에 오류가 숨어 있지는 않았다 |

### 3-3. 1차 판정이 뒤집힌 항목

**없다.** 25건 중 **기각 0.** 판정이 바뀐 2건(P2-A #9 정본 확정 · P2-B 보류 해제)은 모두 1차가 **스스로 보류해 둔 자리**가 닫힌 것이고, 1차가 「오류」라고 단정한 것이 뒤집힌 경우는 없다. 1차 §5-5의 「기존 감사 4건 뒤집힘」도 네 건 모두 **그대로 성립**한다.

---

## 4. 오디오 전파 재집계

> 기준: `gen_lecture_audio.py`의 `_spoken_body` — `kind=table`은 `audioSummary`, 나머지는 `enrichedScriptText`→`scriptText`. `sourceExcerpt`는 **발화되지 않는다**(1차 §7 #2). 단위는 **발화 세그먼트**(같은 세그먼트에 두 번 나와도 1). CLF 대본 19편 전부, 음차 포함 탐침.

### 4-1. P1 계열 — **7 세그먼트 · 대본 4편** (1차 §1-4 「4곳」을 정정)

| 결함 | 대본 | 세그먼트 | 발화 필드 | 재합성 필요 |
|---|---|---|---|---|
| P1-1 도메인 2 최대 | `clf-t2-1` | seg006 | enriched | ✔ |
| P1-1 | `clf-t2-2` | seg006 | enriched | ✔ |
| P1-1 | `clf-t2-3` | seg006 | enriched | ✔ |
| P1-3 Audit Manager 2024 + 가이드 명시 | `clf-t2-2` | seg051 | enriched | ✔(t2-2는 위와 합쳐 1회) |
| P1-4 가이드가 전통 분류 명시 | `clf-t4-3` | seg014 · seg026 · seg030 | enriched | ✔ |

대조군: `clf-t3-2` seg006은 「도메인 3 34% 최대」를 **옳게** 말하고, `clf-t4-1` seg025는 SP 66/72를 **옳게** 가르며, `clf-t4-3` seg012(`audioSummary`)는 Enterprise 15분을 **옳게** 말한다 — 셋 다 그대로 둔다. **P1-2는 음성 전파 0.**

재합성 대상 대본은 **`clf-t2-1` · `clf-t2-2` · `clf-t2-3` · `clf-t4-3` 4편**이고, 사람의 청취 승인 게이트가 각각 붙는다. ⚠️ 19편 전부 `sourceHash`가 md와 어긋나 있으므로(2026-10-29 이탤릭 평문화) 재합성 때 해시 갱신을 같이 하는 것이 좋다(1차 §5-7).

### 4-2. P2·P3 계열 — **36 세그먼트** (라이브 음성에 들어 있으나 사실 오류는 아닌 것)

| 계열 | 세그먼트 | 대본 | 성격 |
|---|---|---|---|
| P2-E 단종 예정 플랜 이름(Developer·Business·On-Ramp) | **7** | `clf-t2-4` seg026 · `clf-t4-3` seg009·012·014·030·031·033 | 2027-01-01까지는 사실. P1-4 재합성 때 **같은 대본**이라 함께 정리 가능 |
| P2-F Kendra(상태 메모 없음) | **9** | `clf-t3-7` | 닫힌 서비스를 현행처럼 말한다 — t3-7 재합성은 P1 범위 밖이라 **별건** |
| P2-G 범위 외를 범위 내로 | **2** | `clf-t3-8` seg034 · seg042 | 표 낭독 + CloudShell |
| P2-D 범위 외 서비스 언급 | **18** | Wavelength 6 · Personalize 6 · CodeDeploy 6 | 사실은 맞음. 비중 문제 |
| P3-4 Snowball | **11** | `clf-t1-3` 외 | 명칭 현행화(Snowball Edge) 대상 |
| P2-D MemoryDB · Billing Conductor / P3-2 프리 티어 / P1-2 SP 72% | **0** | — | 음성 전파 없음 |

### 4-3. 집계

- **사실 오류가 음성에 들어 있는 곳: 7 세그먼트 / 4 대본**(`clf-t2-1`·`t2-2`·`t2-3`·`t4-3`).
- 사실은 맞지만 낡음·범위·메모 부재로 음성에 들어 있는 곳: **36 세그먼트**(P2-E 7 · P2-F 9 · P2-G 2 · P2-D 18 · P3-4 11 — P2-E의 2곳은 P1-4와 같은 세그먼트라 **중복 제외 시 34**).
- mp3는 듣지 않았다(§5).

---

## 5. 측정 한계

| 항목 | 한계 | 닫는 방법 |
|---|---|---|
| **mp3** | 대본 텍스트만 봤다. `audio_meta.json`이 대본↔음성 일치를 보증한다고 가정했다 | 재합성 전 `py tool/publish_audio.py --verify-all` |
| **Trusted Advisor 총 점검 수(P2-H)** | `trusted-advisor-check-reference.html`이 JS로 그려져 원문 HTML에서 셀 수 없었다 | 내장 브라우저로 열어 세거나 **수치를 지운다**(1차 제안 그대로) |
| **재시도 전환 시점(N-3)** | 원문 HTML에서 「기본 전환 날짜」를 찾지 못했다. 문서 도구 1회 읽기의 기억(「2026-11」)은 **근거로 쓰지 않았다** | 12월 전환 PR 직전 같은 페이지 재측정 |
| **DVA 보조 페이지 본문(P3-9)** | `service-mentions`·`comparison` 두 페이지는 **실재와 제목만** 확인했다 | P3-9 집행 전 본문 읽기 |
| **영문 가이드 대조** | 한국어 가이드만 읽었다(1차와 같음) | AIF 트랙의 분기 사례(「모델 잠재 공간」)가 CLF·DVA에도 있을 수 있다 |
| **SSE-C 2026-04 변경의 다른 자격증 반영** | SAA `saa-t1-5.md` · SOA `soa-t4-3` · DEA `dea-t4-3`·`t4-5` · MLA `mla-t1-3`(md+문항)가 변경 전 서술이다 — **CLF·DVA 범위 밖**이라 세기만 했다 | 자격증별 별건으로 넘긴다 |
| **`flutter test`·`analyze`** | 돌리지 않았다(지시) | 컨트롤러 몫 |
| **가드 충돌** | 제안 수정안과 기존 테스트의 충돌은 **1차가 읽은 결과를 그대로 신뢰**했고 2차에서 테스트 파일을 다시 읽지 않았다(N-1·N-2의 `skill`·`sources` 문자열만 `grep`으로 0건 확인) | 집행 PR에서 전체 스위트 |

---

## 부록. 2차에서 쓴 재현 명령

```sh
# 전역 재스윕 (발견별 정규식 × cert × kind, 발화 필드 분리)
cd <scratchpad> && PYTHONIOENCODING=utf-8 py -I global_sweep.py

# URL 재측정 (대조군 포함, 포그라운드 필수 — 백그라운드 셸은 네트워크 없음)
while read tag u; do curl -sL -o "pages/p2a_$tag.html" -w "$tag %{http_code} r=%{num_redirects} -> %{url_effective}\n" "$u"; done < urls_p2a.txt

# 문항 전역 단일 이탤릭
grep -rn -o "[^*]\*[^*]\{1,40\}\*[^*]" --include=*.questions.json flutter_app/assets/content | grep -v "\*\*"

# 공식 원문에서 문장 확인 (예: Cost Explorer 18개월)
sed 's/<[^>]*>/ /g' pages/x_CEW.html | tr -s ' \n' ' ' | grep -o "[^.]\{0,120\}18 months[^.]\{0,120\}"
```
