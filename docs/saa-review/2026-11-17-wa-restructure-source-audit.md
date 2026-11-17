# 출처 URL 전수 재측정 — AWS Well-Architected 문서 재구성 + prescriptive-guidance 소멸 (2026-11-17)

> 범위: **레포 전역 콘텐츠**(`flutter_app/assets/content/**`의 `.md` 프런트매터·「출처」 절 + `.questions.json`의 `sources[].url`).
> 계기: [2026-11-16-aip-review-prep.md](2026-11-16-aip-review-prep.md) **§8** 재점검에서 `wellarchitected/latest/framework/welcome.html`이 404로 나왔고, 그 한 건이 **라이브 CLF·SAA·SOA·SCS·DEA·MLA**까지 걸친 계열의 입구였다.
> 선행 감사: [2026-10-29-soa-dea-source-url-audit.md](2026-10-29-soa-dea-source-url-audit.md)(SOA·DEA 561개).
> 가드: `flutter_app/test/source_url_retired_test.dart`의 `retiredUrls`(항목 하나가 테스트 하나) + `replacements`(집계형 한 테스트).

---

## 0. 결과

| 항목 | 값 |
|---|---|
| 측정한 고유 URL | **2,351개**(레포 전역 · **구조 필드만**) — ⚠️ 1차 크루드 수집은 2,572개였고 차이는 **수집기가 만든 가짜**다(§3) |
| `200 r=0` | 교체 후 **2,311 / 2,351** — 남은 40건은 전부 **기존 판정 계열**이고 **죽은 URL 0건**이다(§3) |
| 교체·정정한 URL | **11건** (죽음 9 · 리다이렉트 2) |
| 손댄 콘텐츠 파일 | **19개** (md 10 · 문항 9) — ⚠️ 대부분 **라이브** |
| 새 정본 URL | **13개 전부 `200 r=0`** 실측 |
| 기준선 | 3,739 → **3,750**(+11 = `retiredUrls` 11항목) |
| 정답 인덱스·보기·`verified` | **전부 불변**(기계 단정) |

---

## 1. 교체 표

| 옛 URL | 신호 | 정본 | 쓰는 곳 |
|---|---|---|---|
| `wellarchitected/…/framework/welcome.html` | 404 r=0 | `framework/framework.html` · `framework/definitions.html` | **clf/t1-2**(md 2 · 문항 4) · aip/aip-t1-1(선행 PR) |
| `…/framework/the-pillars-of-the-framework.html` | 404 r=0 | `framework/definitions.html` | **clf/t1-2**(md 2 · 문항 9) |
| `…/framework/sec_permissions_emergency_process.html` | 404 r=0 | `security-pillar/sec_permissions_emergency_process.html` | scs/scs-t6-1(md 2 · 문항 1) |
| `…/framework/rel_planning_network_topology_ha_conn_private_networks.html` | 404 r=0 | `reliability-pillar/rel_planning_network_topology_…` | soa/soa-t5-2(문항 1) + **은퇴 가드의 정본 등재분** |
| `…/reliability-pillar/welcome.html` | 200 r=1 | `framework/reliability.html` | **saa-t2-4**(md·문항 8) · **saa-t2-5** · **soa-t2-2**(md·문항 2) · **soa-t2-4** |
| `prescriptive-guidance/…/encryption-best-practices/general-encryption-best-practices.html` | 404 r=0 | `…/encryption-best-practices-and-features-for-aws-services/encryption-strategy-in-aws.html` | dea/dea-t4-3(md 1) |
| `prescriptive-guidance/…/image-classification/sagemaker-canvas.html` | 404 r=0 | `sagemaker/latest/dg/canvas-manage-cost.html` | mla/mla-t2-1(문항 1) |
| `prescriptive-guidance/…/implementing-logging-monitoring-cloudwatch/cloudwatch-search-analysis.html` | 404 r=0 (**리더도 `not_found`**) | `opensearch-service/…/fgac.html` | saa/saa-t3-9(md 1) |
| `prescriptive-guidance/…/least-privilege-cloudformation/permissions-use-cloudformation.html` | 404 r=0 | `AWSCloudFormation/…/using-iam-servicerole.html` | dea/dea-t4-1(md 1 · 문항 1) |
| `prescriptive-guidance/…/serverless-etl-aws-glue/databrew.html` | 404 r=0 (**리더도 `not_found`**) | `databrew/latest/dg/what-is.html` (+ `glue/…/glue-studio-data-preparation.html`) | dea/dea-t3-1(md 1 · 문항 1) |
| `aws.amazon.com/security-agent/` | 200 r=1 | `aws.amazon.com/continuum/` | soa/soa-t4-2(md 1) — **제품 개명** |

---

## 2. 판정 — URL만 바꾸면 안 되는 자리들

### ⚠️⚠️ framework 가이드는 **BP 번호를 재배정했다**

`framework/sec03-bp03.html`은 **`200 r=0`으로 살아 있지만** 그 내용이 「**Analyze public and cross-account access**」다 — 레포가 인용하는 「Establish emergency access process」가 아니다. **번호로 매핑하면 멀쩡한 URL로 엉뚱한 페이지를 인용한다.** 비상 접근 BP의 정본은 **`security-pillar/sec_permissions_emergency_process.html`**(옛 슬러그가 그 가이드에서는 살아 있다)이고 제목도 그대로다.

### ⚠️⚠️ 같은 BP라도 **본문이 재작성되면** 인용 문장이 사라진다

`framework/rel02-bp02.html`은 제목이 같은 REL02-BP02이지만 본문이 새로 쓰였고 레포가 인용하는 **`cost-effective backup`** 문장이 없다(`costs less`로 바뀌었다). 그래서 `reliability-pillar/` 판을 정본으로 썼다 — 그 판은 `AWS Site-to-Site VPN ending on an AWS Transit Gateway as a cost-effective backup to your primary AWS Direct Connect connection`을 그대로 싣는다.

### ⚠️ pillar 가이드는 **반쪽만 이전됐다**

`security-pillar/welcome.html`·`reliability-pillar/welcome.html`·`cost-optimization-pillar/welcome.html`·`sustainability-pillar/welcome.html`은 모두 **`200 r=1`로 `framework/<pillar>.html`로** 넘어가는데, **그 가이드들의 BP 페이지는 옛 슬러그로 살아 있다**. 즉 랜딩만 옮겨졌다. 여섯 기둥은 이제 **기둥마다 한 페이지**이고(`framework/operational-excellence.html` · `security.html` · `reliability.html` · `performance-efficiency.html` · `cost-optimization.html` · `sustainability.html`, 전부 `200 r=0`) 「six pillars」 표와 각 기둥 정의는 **`framework/definitions.html`**이 갖는다(`framework/framework.html`에는 기둥 이름이 **0건**이다 — 실측).

### ⚠️⚠️ 「WA Tool 무료」는 새 페이지에 없다

`framework/framework.html`은 `foundational questions`(1건)·`not an audit`(2건)을 그대로 적지만 `no cost`·`free`가 **0건**이다. 정본은 **`aws.amazon.com/well-architected-tool/pricing/`**의 산문 `There is no additional charge for the AWS Well-Architected Tool. You pay only for your underlying AWS resources.` 이고, docs-proper 에도 백서 보일러플레이트의 `available at no charge in the AWS Management Console`이 있다. **URL을 바꿀 때는 그 URL이 업고 있던 사실을 하나씩 다시 센다.**

### ⚠️ prescriptive-guidance 는 **개명 1 · 소멸 4**로 갈린다

- **개명**: `encryption-best-practices/` → **`encryption-best-practices-and-features-for-aws-services/`**(옛 슬러그를 새 가이드에 붙이면 `200 r=1`로 `encryption-strategy-in-aws.html` 쪽으로 간다).
- **소멸**: `implementing-logging-monitoring-cloudwatch/`·`serverless-etl-aws-glue/`는 `welcome.html`이 **진짜 `404 r=0`**이고 **AWS 문서 리더도 `not_found`**다. 2026-11-06 AIF `AWS CAF for AI`(리더로는 읽혀 인용을 지켰다)와 **반대 결론**이고, 규율은 「네 방법을 다 해 본다」이며 **결론은 매번 측정으로 정한다**.
- `image-classification/`·`least-privilege-cloudformation/`는 가이드 자체는 남아 있으나(`welcome.html` → `403 r=1`로 루트, 루트는 인덱스 미제공) **인용하던 페이지가 색인에서 사라져** 서비스 자기 가이드로 옮겼다. ⭐ CloudFormation 쪽은 오히려 **더 정확해졌다** — `using-iam-servicerole.html`이 「기본은 호출자 자격 증명 · 서비스 역할을 전달하면 그 역할로 · `iam:PassRole` 필요」를 한 페이지에 적는다.

### ⚠️⚠️ 제품 개명 — AWS Security Agent → AWS Continuum

`aws.amazon.com/security-agent/`가 **`aws.amazon.com/continuum/`**으로 넘어가고 그 페이지가 이 기능을 **`Continuum for penetration testing (f.k.a. AWS Security Agent)`**로 적는다. `soa-t4-2.md`는 2026-11-09에 「공식 제목이 *AWS Security Agent (now part of AWS Continuum)*」로 적어 뒀는데 **그 서술이 이제 낡았다.** ⭐ 다만 **공식 시험 가이드 v1.1과 사용자 안내서(`securityagent/latest/userguide/…`, `200 r=0`)는 아직 옛 이름을 쓰므로 본문 표기는 가이드를 따르고 URL과 상태 메모만 고쳤다.**

### ⚠️ 사실을 다시 세느라 본문을 고친 두 자리

- **`mla-t2-1-q18`**(라이브): 해설이 「Prescriptive Guidance는 **월 수천 장 이상**이면 자체 호스팅이 더 저렴하다고 비교한다」고 적었는데 그 페이지가 사라져 **수치 근거가 없다**. 새 정본(`canvas-manage-cost.html`)이 적는 것은 **과금 축의 차이**(Ready-to-use 모델은 기반 서비스 요금 · 사용자 지정 모델은 예측 리소스)이므로 해설을 그 축으로 바꿨다. **정답·보기·`verified` 불변.**
- **`saa-t3-9.md`**(라이브): 「공식이 드는 OpenSearch 전환 사유」 네 개를 한 자리에 모아 적던 페이지가 사라졌다. 본문 네 항목은 참이므로 지우지 않고, **「공식이 드는」 귀속을 걷고** 첫 항목(필드 수준 접근 제어·마스킹)의 정본으로 `opensearch-service/…/fgac.html`(`Field-level security` 3건 · `anonymiz` 3건 · `mask` 6건 실측)을 달았다.

---

## 3. 결함이 아닌 것 (273건 중)

| 부류 | 건수 | 판정 |
|---|---|---|
| **수집기가 만든 가짜 URL** | **222** | ⚠️ 1차 전역 수집기가 `audio/**/script.json`의 `sourceExcerpt`(md 참고자료 복사본)에서 **각주 번호를 URL에 붙였다**(`…/pricing/6` · `Welcome.html2`). **수집기는 URL을 발명하지 않아야 한다** → 구조 필드만 읽게 고쳤다 |
| 생성된 오디오 대본에만 남은 옛 URL | **1** | ⚠️ `audio/**` 소속 bad 223건 중 **하나는 가짜가 아니었다** — `prescriptive-guidance/…/migration-retiring-applications/apg-7-rs.html`이 `200 r=1`(그 가이드 인덱스 · 같은 가이드의 틀린 슬러그와 같은 신호)로 **지워진 페이지**다. 다만 `clf/clf-t1-3/script.json`의 `sourceExcerpt`(합성 시점 md 스냅샷)에만 있고 **`.md`·문항에는 0건**이며 `sourceExcerpt`는 **발화되지 않는다** → 라이브 결함이 아니다. ⭐ **「전부 가짜」로 묶었다면 이 한 건을 못 봤다** |
| `repost.aws` 403 | 14 | **봇 차단**이고 죽은 링크가 아니다(브라우저로는 열린다 — 2026-10-29 실측 그대로) |
| `whitepapers/latest/…` 200 r=1 | 11 | **사람 대상 서빙만 꺼진** 기존 판정 계열(AWS 문서 리더로는 읽힌다 → 인용 유지 + 상태 명시) |
| `…/index.html` → `…/` | 1 | **후행 슬래시 정규화**(죽은 슬러그가 아니다) |
| `signin.aws.amazon.com/federation` 400 | 1 | **API 엔드포인트**(파라미터 없이 부르면 400이 정상) |

---

## 3-1. ⚠️ 파생 수치는 손으로 적지 않는다

1차 보고에서 「고유 2,572개」·「가짜 223건」을 그대로 §0 에 적었는데 **둘 다 정확하지 않았다** —
2,572 는 **크루드 수집**의 수이고 구조 필드 수집은 **2,351**이며, 223 중 **하나는 실재했던
URL**이다. 수집 방식이 다르면 **모수가 다르다**는 것을 수치에 함께 적는다.

## 4. 측정 방법 (재현)

```sh
# 판정 신호는 네 갈래다 — `-sL` 없이는 num_redirects 가 항상 0이다
curl -sL -o /dev/null -w '%{http_code} %{num_redirects} %{url_effective}' --max-time 40 "<url>"
```

| 신호 | 뜻 |
|---|---|
| `200 r=0` | 살아 있다 |
| `200 r=1` → **그 가이드 인덱스** | 있는 가이드의 **없던** 슬러그 |
| `200 r=1` → **특정 페이지** | **이름 변경**(도착지를 봐야 가른다) |
| **`404 r=0`** | 가이드 접두사가 없거나 — ⚠️⚠️ **그 가이드가 살아 있어도 그 페이지가 지워진 경우** |
| `403 r=0` / `403 r=1` | 디렉터리 인덱스 미제공(가이드는 있을 수 있다) |

- **대조군을 매번 재현한다**: 있는 가이드의 틀린 슬러그(`…/framework/zz-bogus-xyz.html` → `200 r=1`) · 없는 가이드 접두사(`404 r=0`) · `aws.amazon.com`의 없는 경로(`404 r=0`) · 알려진 생존 페이지(`200 r=0`).
- **「사라졌다」와 「사람이 열 수 없다」는 네 방법으로 가른다**: `curl` · **AWS 문서 리더**(`read_documentation`) · docs 검색 색인 · 실제 브라우저.
- 치환은 전부 **횟수 단정**을 걸고, 문항 JSON은 **바이트 블록 치환**(json 왕복 금지) + `correct`·`options`·`stem`·`verified` **불변 단정**으로 막았다.

## 5. 백서 33자리 재소싱 (2026-11-17, 같은 날 후속)

감사가 분류한 **백서 33자리**는 「문서가 사라진 것이 아니라 사람이 브라우저로 열 수 없는」
묶음이라 **인용을 유지하고 상태를 적는** 것이 레포 정책이다. 그 판정은 지금도 유효하므로
이 배치는 **백서를 추방하지 않았다**(고유 URL 31개가 그대로 쓰인다). 실제로 한 일은 셋이다.

### 5-1. 되살아난 URL 의 낡은 상태 메모 — **1건**

`aws-vpc-connectivity-options/` 두 페이지는 재측정에서 **`200 r=0` 으로 정상 복귀**했다.
그중 상태 메모가 달려 있던 자리는 **하나뿐이다** — `saa-t3-8.questions.json:102`
(TGW + Site-to-Site VPN 출처 제목). 같은 가이드의 `aws-privatelink.html` 은
`saa-t3-8.questions.json` 에서 쓰이지만 **처음부터 메모가 없었다.**

> ⚠️ 1차 보고에서 이것을 「2건」으로 적었다. **쓰는 자리의 수와 메모가 달린 자리의 수는
> 다르다** — 전수 스캔은 둘을 따로 세야 한다.

### 5-2. 라이브 정본이 그 사실을 적는 자리 (4건)

| 자리 | 걷은 백서 | 대신 쓴 정본 | 왜 |
|---|---|---|---|
| `dea-t1-2-q1` | `big-data-analytics-options/aws-lambda.html` | `lambda/latest/dg/gettingstarted-limits.html` | 그 문항의 `W1` 이 **900초**를 단정하는데 쿼터 페이지가 그 수치를 직접 적는다 |
| `saa-t2-1.md` #14 | `patterns-for-ingesting-saas-data-into-aws-data-lakes/purpose-built-integration-service.html` | `appflow/.../what-is-appflow.html` + `appflow/.../flows.html` | 트리거 세 가지·변환·PrivateLink 는 **서비스 사용자 안내서**가 정본이다(참고자료 14→14·15) |
| `mla-t4-3.md` #76 | `building-data-lakes/data-cataloging.html` | `lake-formation/latest/dg/what-is-lake-formation.html` | 카탈로그·검색·권한 모델을 적는 쪽 |
| `saa-t3-8.md` #18 | (유지) `hybrid-cloud-dns-options-for-vpc/...` | **#19 신설** `Route53/latest/DeveloperGuide/DNSLimitations.html` | **QPS 수치만** 공식 쿼터 페이지로 옮겼다 |

> ⚠️⚠️ **URL 을 바꾸면 그 URL 이 업고 있던 사실을 하나씩 다시 센다**(G-67). QPS 를 백서
> 줄에서 떼어 공식 쿼터 페이지로 옮겼더니 **본문 §9 가 아직 「ENI당 약 10,000 QPS」로
> 적어** 참고자료와 단위가 어긋났다. 공식은 **IP 주소당 UDP DNS 10,000 QPS**이고
> **엔드포인트당 IP 는 6개**까지이며 **어느 인터페이스든 용량의 50% 를 넘으면 인터페이스를
> 더한다**고 적는다. 그리고 **NLB 를 경유하거나 제한적 보안 그룹으로 연결 추적이 강제되면
> 인바운드는 1,500까지 내려간다** — 수치만 적으면 거꾸로 오해하는 자리라 함께 넣었다.

### 5-3. 그 문항이 인용하지 않는 백서 줄 (2건, 삭제)

`mla-t2-1-q11`(`ml-best-practices-healthcare-life-sciences/model-interpretability.html`)과
`mla-t4-3-q25`(`build-secure-enterprise-ml-platform/networking-architecture.html`)는
**해설이 이미 정본을 인용**하고 있어 백서 줄이 중복이었다(AIF 2026-11-17 교훈: 죽은 출처가
교체가 아니라 **중복 삭제**로 닫히는 경우가 있다). `.md` 참고자료에는 **상태 메모와 함께
그대로 남는다** — 문항과 학습문서는 다른 층이다.

**반대로 `mla-t4-3-q12` 는 백서를 유지했다** — SCP 가드레일 예제 묶음
(`CreateTrainingJob`·`CreateHyperParameterTuningJob` + `sagemaker:NetworkIsolation`)이
그 백서 고유다. 그래서 그 문항의 「백서의 가드레일 예제는 …」 귀속도 **그대로 둬야 한다.**

### 5-4. ⚠️⚠️ 「백서」 토큰은 귀속 탐지기가 아니다

백서 줄을 지우면서 귀속 문장을 남기면 **출처 없는 귀속**이 된다. 그래서 전수 가드를 걸려고
「백서」 토큰으로 세 봤더니 **`clf/t4-3` 의 8자리가 걸렸고 전부 정당했다** — 그 문항들은
**자료 종류로서의 백서**를(블로그·포럼·가이드와 나란히 드는) 묻는다. 「기술」을 말하기
동사로 넣으면 **「기술 자료」·「기술 리소스」가 또 걸린다**(실측 3건).

최종 트리거는 **백서 + 조사 + 말하기 동사**(`적|말|설명|제시|권|인용|비교|정의|분류|싣|…`)이고
실측으로 **거짓 양성 0** · **백서 출처가 있는 쪽에서 5건**(`aif-t2-3-q4` · `aif-t3-2-q12` ·
`saa-t2-5-q4`×3)을 찾는다. 그 5건이 **좁힘이 공허하지 않다는 대조군**이다.

### 5-5. 가드

`flutter_app/test/whitepaper_resourcing_test.dart` **15건**(기준선 3,750 → **3,765**).
민감도는 **콘텐츠 변경만 `git stash`** 하면 8건이 레드가 되며 항목을 이름과 함께 집어내는
것으로 확인했다. ⚠️ `verified` 는 보지 않는다 — flip 은 사람의 작업이고, 상태를 단정한
가드가 2026-11-13 검수자의 첫 SCS flip 을 레드로 끝냈다.
