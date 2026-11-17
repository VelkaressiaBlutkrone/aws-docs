# SCS-C03 전수 검증 — 2026-11-17

> **이 세션이 수정한 파일: 없음.** 중단 전·후 모두 `git -C D:\workspace\awc-docs status --porcelain` 이 `?? docs/audits/2026-11-17-full-verify/` 한 줄뿐이다(브랜치 `develop`, 기준 HEAD `4b83461`). 쓴 것은 이 보고서 하나와 gitignored `flutter_app/build/scs_review/`(prescreen 산출물) · 세션 scratchpad 뿐이다.
>
> 범위: `flutter_app/assets/content/scs/` 학습문서 16편 · 문항 240개(공개 90 = `t1-1`·`t2-1`·`t3-1`·`t4-1`·`t5-1`·`t6-1`, 드래프트 150) · `assets/exam_guides/SCS-C03.json`.
>
> **어떻게 셌는가(2단계가 다시 재지 않도록)**
> - **문항 240개 전부**를 지문·보기 넷·해설·오답 근거·출처까지 읽었다. 문항이 인용한 **고유 URL 164개**(인용 292회, 전부 `docs.aws.amazon.com`)를 `curl -sL` 로 내려받아 **본문에서 그 문항의 단정을 찾았다**. 「없다」는 (a) 본문 추출 탐침 (b) **다른 표현으로 재탐침** (c) 그 페이지에 분명히 있는 문구(대조군)가 잡히는지를 본 것만 적었다. 🔴 셋은 **AWS 문서 리더로 한 번 더** 읽었다.
> - 생사 대조군 재현: 있는 가이드의 틀린 슬러그 `waf/…/zz-bogus-control.html` → `200 r=1`(인덱스) · 없는 가이드 접두사 → 진짜 `404 r=0`.
> - 수정안에 새로 적은 출처는 전부 이 세션에서 `200 r=0` 을 실측하고 **본문에서 그 문장을 확인한 것**이다.
>
> ⚠️ **이 보고가 덮지 못한 것** — 숨기지 않고 적는다.
> - **학습문서 16편 본문을 줄 단위로 전수 사실 대조하지는 않았다.** 본 것은 (a) 문항에서 찾은 결함이 md 에도 있는지(전파) (b) 닫힌 서비스 상태 표기 (c) 문항 출처 ⊆ md 출처(G-84) 셋이다. **문항에 닿지 않는 md 단독 사실 오류는 이 보고 밖에 남아 있다.**
> - 해설의 **부차 사실**(정답을 가르지 않는 덧붙임)은 숫자·영문 식별자·핵심 명사 탐침으로 훑었다. 한국어 산문으로만 적힌 부차 사실은 전수 확인이 아니다.
> - `aws.amazon.com/*/pricing` 은 보지 않았다(요율 표가 JS 로 그려진다). 요금 단정은 docs 본문에 있는 것만 확인했다.
> - 2026-11-11 보고 §4 의 닫힌 항목(🔴·🟡·🟢·보류·중복, 1~6단계)과 저작 결정 D-04·D-09·D-11·D-13·D-15·D-16·D-17 이 판정해 둔 것은 다시 적지 않았다. 다만 **닫은 뒤에 생긴 것**(11-17 URL 교체의 귀결 · 6단계 교체가 만든 겹침)은 적는다.

## 0. 요약

| 판정 | 수 | 뜻 |
|---|---|---|
| 🔴 | **문항 3개**(+ 같은 문구의 라이브 학습문서 3편) | 사실이 거짓 · 정답이 둘 · 인용 페이지가 정답과 반대 (즉시 수정) — **셋 다 공개 문항** |
| 🟡 | **문항 32개**(공개 13 · 드래프트 19) | 출처가 사실을 담지 않음 · 불완전 · 지문 전제 모순 (수정 권고) |
| 🟢 | 9묶음 | 품질(메타 문구 · 긴 해설 · 겹침 · 상태 문구 위치 · 가드 빈틈) — 사실은 옳다 |
| ✅ | 문항 **205/240** | 사실·정답 유일성·인용에서 결함을 찾지 못함(품질 신호는 🟢 에서 따로 센다) |

- **공개 문항 중 🔴: 3건** ← 가장 중요한 수치. `scs-t5-1-q14` · `scs-t6-1-q15` · `scs-t3-1-q5`. **정답 인덱스가 틀린 문항은 0건**이고 세 건 모두 인덱스를 유지한 채 고칠 수 있다.
- `prescreen` qualityFlags(전체 240문항): **length-cue 0 · meta-phrasing 76 · authoring-memo 1 · explanation-long 29**, 품질 신호 문항 98/240(41%). 구조·정합성 플래그 **0건** · 뱅크 플래그 **0 Task** · Task 내 중복 후보 **0쌍**.
- 검증한 출처 URL: **고유 164개**(전부 `200 r=0`, 신규 죽은 URL **0**) / 그중 **「그 문항이 단정하는 사실을 담지 않음」 28개 페이지**(§1·§2 항목마다 「인용 페이지」로 적었다). 별도로 **인용 페이지가 문항과 반대로 적는 자리 2개**(`t5-1-q14` 의 EMR 페이지 · `t3-1-q5` 의 CloudFront 체크리스트).
- 0건으로 확인한 축: G-84 위반 **0**(파일별) · 가이드 밖 `skill` **0** · 기술 70개 중 문항 0개인 기술 **0** · 범위 외 서비스(MWAA · Payment Cryptography)가 정답 보기에 든 문항 **0** · 문항 안 `**굵게**`·마크다운 링크 **0** · 정답÷최장 오답 > 1.3 **0** · 가르치는 층의 닫힌 서비스 상태 누락 **0** · 정답 자카드 ≥ 0.33 쌍 **0**(28,680쌍, 원형·조사벗김 둘 다).

### 세 🔴 의 공통 원인 — 측정의 유효 기간

셋 다 **저작 뒤에 공식 페이지가 움직인 자리**다(저작 2026-11-09~10 시점에는 맞았을 가능성이 높다).

| 문항 | 무엇이 움직였나 |
|---|---|
| `scs-t5-1-q14` | EMR 이 **릴리스 7.11.0 부터 세 번째 경로**(EMR 이 인증서를 만들어 관리)를 적는다 → 오답 보기 하나가 참이 됐다 |
| `scs-t6-1-q15` | **2026-11-17 URL 교체**(`framework/` → `security-pillar/`)로 인용 페이지 본문이 **다른 판**이 됐다 — 그 URL 이 업고 있던 문장은 다시 세지 않았다 |
| `scs-t3-1-q5` | CloudFront 체크리스트 페이지가 두 수단을 **"Alternatively"** 로 적는다(`h1` 도 「…marketplace distributions」) → 「함께 쓰라고 적는다」는 귀속이 거짓 |

→ 2단계 권고: 고친 뒤 가드를 세울 때 「옛 문구 0건」만 걸지 말고 **새 출처 URL 실재 + 그 문항이 새 문구를 담는지**를 쌍으로 고정한다.

---

## 1. 🔴 (문항·학습문서)

### scs-t5-1-q14 — EMR 전송 중 암호화 인증서 경로가 「둘」이 아니라 셋이고, 오답 보기 하나가 참이 됐다
- **공개 여부**: verified **true**
- **현재 정답 인덱스**: **3** (실측)
- **결함**: 해설이 「TLS 인증서를 주는 방법을 **둘**로 적습니다」, `W0` 이 「경로는 … **둘**입니다」, `W2` 가 「**인증서는 내가 제공합니다**」로 적는다. 그런데 **문항이 인용한 바로 그 페이지**가 셋으로 적는다. 그 결과 오답 보기 `[2]`(「EMR이 인증서를 자동 생성하므로 인증서를 제공할 필요가 없습니다」 취지)가 릴리스 7.11.0 이상에서 **참에 가깝고**, 지문의 제약(개인 키를 S3 에 두지 말 것)도 만족한다 → **정답이 둘**이다.
- **공식 근거 ①**(문항의 인용 페이지) `https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-data-encryption-options.html` — "You specify the encryption artifacts used for in-transit encryption in **one of three ways: by allowing Amazon EMR to create and manage certificates for you**, by providing a zipped file of certificates that you upload to Amazon S3, or by referencing a custom Java class that provides encryption artifacts."
- **공식 근거 ②**(전용 페이지, `200 r=0`) `https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-encryption-enable.html` — "**With Amazon EMR release version 7.11.0 or later, you have three options** … You can have Amazon EMR create and manage private certificates for you. When selecting this option, Amazon EMR will upload the PEM-encoded certificate of the created certificate authority to **AWS Secrets Manager** in your account … **For Amazon EMR release version 4.8.0 through 7.10.0, only a .zip file or custom Java class**…"
- **확인 방법**: 본문 추출 + 같은 페이지에서 `SASL`·`Kerberos` 대조군 양성 + 전용 페이지 교차 + AWS 문서 리더.
- **수정안** (정답 인덱스 **3 유지**)
  - 보기 `[2]` 를 **명백히 거짓**인 문장으로 교체한다. 예: 「ACM 퍼블릭 인증서의 ARN 을 보안 구성에 지정하면 EMR 이 노드에 배포합니다」(`W1` 과 겹치지 않게 조정).
  - 정답 `[3]` 을 「개인 키를 S3 에 두지 않는 경로는 사용자 지정 인증서 공급자(Java 클래스)이고, 릴리스 7.11.0 이상이면 EMR 이 인증서를 만들어 관리하게 할 수도 있습니다」 취지로 고친다. 또는 **지문을 「릴리스 7.10 이하 클러스터」로 한정**하면 보기 교체 없이 닫힌다(더 작은 수정).
  - 해설·`W0`·`W2` 의 「둘」을 「7.11.0 이상은 셋, 4.8.0~7.10.0 은 zip 과 Java 클래스 둘」로 고치고 출처에 `emr-encryption-enable.html` 을 더한다(G-84 → `scs-t5-1.md` 출처에도).
  - ⚠️ 공개 문항의 보기 교체는 **사람 승인 대상**이다.
- **전수**: **md 3자리** — `scs-t5-1.md` L235(「방법이 둘입니다」) · L239 표(두 행) · L390 요약(「방법은 둘」). **문항 1개 4자리** — `q14` 의 보기 `[3]`·해설·`W0`·`W2`. `grep -c "방법[이은을] 둘"` 줄 수는 md 2 · 문항 1(표는 문구가 달라 읽어서 셌다). 다른 자격증: `dea/dea-t4-3.md` 가 같은 URL 을 달지만 **「둘」 단정은 없다**(§5).
- **가드**: `scs-t5-1-q14` 를 id 로 묶은 테스트는 `scs_length_cue_test.dart` 뿐이다(길이 비율 — 보기를 바꾸면 1.3배·하한을 다시 맞춘다).

### scs-t6-1-q15 — 인용 페이지(SEC03-BP03 현행판)에 그 「안티패턴 둘」이 없다
- **공개 여부**: verified **true**
- **현재 정답 인덱스**: **3** (실측)
- **결함**: 정답 보기가 「공식이 … **장기 상승 권한 부여를 안티패턴으로 적습니다**」, 해설이 「**안티패턴이 둘**입니다 — 복구할 비상 프로세스가 없는 것과 장기 상승 권한을 부여하는 것」, `W1` 이 「장기 상승 권한 부여가 공식이 적는 안티패턴입니다」. **현재 인용 페이지의 안티패턴은 넷이고 그 둘이 아니다.** 현행판에는 `elevated` 0건 · `validate and approve` 0건이다(대조군 `SEC03-BP03`·`Medium`·`cross-account` 양성).
- **공식 근거(현행 인용 페이지)** `https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/sec_permissions_emergency_process.html` — "Common anti-patterns: You do not have well-documented and well-tested emergency access processes… Your emergency access processes **depend on the same systems** (such as a centralized identity provider) as your normal access mechanisms… Your emergency access processes are **used in non-emergency situations**… Your emergency access processes **do not generate sufficient logs**…"
- **문항 문구의 실제 출처**(구 날짜판, `200 r=0`) `https://docs.aws.amazon.com/wellarchitected/2023-04-10/framework/sec_permissions_emergency_process.html` — "Common anti-patterns: Not having an emergency process in place to recover from an outage with your existing identity configuration. **Granting long term elevated permissions for troubleshooting or recovery purposes.**" → 문항·md 는 **2023-04-10 판**과 글자 그대로 맞는다. 11-17 감사(커밋 `db21db0`)가 URL 을 `security-pillar/` 판으로 옮기면서 **그 URL 이 업고 있던 문장은 다시 세지 않았다.**
- ⚠️ 현행 인용 페이지 머리에 **"This whitepaper is for historical reference only and will be deprecated in the future."** 배너가 있다(§6-5).
- **부차 결함**: 해설 끝 「특권 세션 … 최대 15분 … `sts:AssumeRoot` 권한 보유자만」은 인용 페이지에 없다(`15 minutes` 0 · `AssumeRoot` 0). 정본은 `https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoot.html` — "The value can range from 0 seconds up to the maximum session duration of **900 seconds (15 minutes)**"(`200 r=0`, 같은 Task `q13` 이 이미 인용한다).
- **수정안** (정답 인덱스 **3 유지**)
  - 정답 `[3]` 의 귀속을 현행판에 맞춘다. 예: 「미리 구성하고 시험해 둔 비상 접근 프로세스를 보여 줍니다. 평소 접근과 같은 시스템에 의존하지 않아야 하고 비상 상황에만 쓰여야 합니다」.
  - 해설의 「안티패턴이 둘」을 현행 넷(문서화·시험 부재 / 평소 접근과 같은 시스템 의존 / 비상 아닌 상황에서의 사용 / 로그 부족)으로 바꾼다. 오답 `[1]`(장기 상승 권한)은 **최소 권한 원칙 위반**으로 반박한다(같은 페이지가 `SEC03-BP02 Grant least privilege access` 를 관련 모범 사례로 든다). D-16 대로 **개수는 묻지 않는다**.
  - 15분·`sts:AssumeRoot` 문장에 `API_AssumeRoot.html` 을 출처로 단다.
- **전수**: 「안티패턴」 **md 3줄** — `scs-t6-1.md` L323 · L324(표) · L437(자가 점검). **문항 3줄** — `q15` 의 보기 `[3]`·해설·`W1`. 그 URL 은 SCS 에서 `scs-t6-1.md`(L34 · L456)와 이 문항뿐이다. ⚠️ `scs-t6-1.md` L456 의 「(2026-11-09 확인)」 라벨은 11-17 에 URL 이 바뀐 뒤로 낡았다.
- **가드**: `scs_questions_test.dart`(보고 §4 3단계 문구 가드) · `scs_s6_review_fix_test.dart` · `scs_length_cue_test.dart` 가 이 id 를 든다 — **문구를 리터럴로 묶은 단정이 있으면 먼저 뒤집는다**(`grep -n "scs-t6-1-q15" test/scs_*.dart`).

### scs-t3-1-q5 — 「공식 체크리스트가 두 수단을 함께 쓰라고 적는다」는 귀속이 거짓이다 (페이지는 "Alternatively")
- **공개 여부**: verified **true**
- **현재 정답 인덱스**: **0** (실측)
- **결함**: 해설이 「공식 보안 체크리스트가 두 수단을 나란히 적고 **함께 쓰는 것이 가장 강한 오리진 보호라고 적습니다**」, 보기 `[0]`·해설이 「그 범위는 **모든 고객의 배포가 공유**」. 인용 페이지는 **둘을 대안으로** 적고, `shared`·`strongest`·`together` 계열 문장이 없다(대조군 `prefix list` 1 · `Secrets Manager` 2 양성). 게다가 "Alternatively, use the managed prefix list" 는 오답 `[3]`(「빠진 것이 없다」 취지)을 **지지하는 것처럼 읽힌다** — 인용 페이지가 정답과 반대 방향이다.
- **공식 근거(인용 페이지, `curl` + AWS 문서 리더 두 방법으로 전문 확인 · 7,065자)** `https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/ecommerce-security-checklist.html` — "Add a custom origin header (X-Origin-Verify) that CloudFront sends with every request. Configure the ALB or application to reject requests that do not include this header. Store the header value in AWS Secrets Manager and rotate it periodically. **Alternatively, use the CloudFront managed prefix list** to restrict ALB security group inbound rules to CloudFront IP ranges."
- **정답 자체는 옳다는 근거**(`200 r=0`) `https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/LocationsOfEdgeServers.html` — "This allows **all of the CloudFront global origin-facing servers** to reach the instance." 접두사 목록은 「CloudFront 인지」까지만 가르고 「내 배포인지」는 가르지 않는다. 헤더 쪽은 `https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/restrict-access-to-load-balancer.html`(`200 r=0`).
- ⚠️ **「둘을 함께 쓰면 고른 배포만 통과한다」를 글자 그대로 적는 문장은 사람이 열 수 있는 docs 페이지에서 찾지 못했다.** AWS 문서 리더로는 백서 `whitepapers/latest/secure-content-delivery-amazon-cloudfront/custom-origin-with-cloudfront.html` 에 "By using an IP allowed list and header inspection together, your custom origin allows only traffic from chosen CloudFront distributions" 가 읽히지만 **`curl -sL` 은 `200 r=1`** 로 다른 페이지에 튕긴다(11-17 감사가 분류한 「사람이 열 수 없는 백서」 계열). 「제3자 배포도 통과한다」를 직접 적는 문장은 `repost.aws` 뿐이라 근거로 쓰지 않았다(§6-2).
- **수정안** (정답 인덱스 **0 유지**)
  - 해설의 「공식 보안 체크리스트가 … 가장 강한 오리진 보호라고 적습니다」를 지우고 **측정된 문장**으로 바꾼다. 예: 「관리형 접두사 목록은 CloudFront 의 모든 오리진 대면 서버 범위를 담으므로 그 요청이 어느 배포에서 왔는지는 가르지 못합니다. 내 배포에서 온 요청임을 확인하는 것은 커스텀 오리진 헤더입니다」.
  - 출처를 `LocationsOfEdgeServers.html` + `restrict-access-to-load-balancer.html` 로 교체하고(G-84 → `scs-t3-1.md` 출처에도 추가), 체크리스트 페이지는 「헤더 값을 Secrets Manager 에 두고 교체」 근거로만 남긴다.
- **전수**: `scs-t3-1.md` **3줄** — L137(「두 층은 서로를 대신하지 못합니다」) · L321(「모든 고객의 CloudFront 배포가 공유」) · L323(「공식 안내가 두 층을 함께 쓰는 것이 가장 강한 오리진 보호라고 적습니다」). 문항 — `q5` 의 보기 `[0]`·해설(「가장 강한 오리진」 1줄 · 「모든 고객」 2줄) + **`scs-t3-1-q1`**(공개 · 정답 **0**)의 해설 「…함께 쓰며」(§2 Y2). 출처 제목도 어긋난다 — `q1` 은 「Security checklist for ecommerce」, `q5` 는 「…marketplace distributions」이고 **현행 `h1` 은 후자**다.
- **가드**: `scs-t3-1-q5` 는 `scs_length_cue_test.dart` 만, `q1` 은 `scs_source_fix_test.dart` 가 든다(출처 단정이면 먼저 고친다).

---
## 2. 🟡 (문항 32개 — 공개 13 · 드래프트 19)

형식은 §1 과 같되 줄였다. **「인용 페이지」= 그 문항이 지금 출처로 단 페이지**, **「정본」= 그 사실이 실제로 적힌 페이지**(전부 이 세션에서 `200 r=0` + 본문 확인). 따로 적지 않으면 **정답 인덱스는 그대로**다. 대부분은 사실이 옳고 **출처만 그 사실을 담지 않는** 경우다.

### 2-A. 공개 문항 13개

#### Y1 · scs-t3-1-q3 — 「추가 요금은 셋」이 공식 다른 페이지와 어긋난다 (Anti-DDoS 관리형 규칙 그룹)
- **공개**: true · **정답 인덱스**: **2**
- **결함**: 정답 보기·해설이 「추가 요금은 Bot Control·ATP·ACFP 에 붙고 **그 밖의 모든 AWS Managed Rules 는 추가 비용이 없다**」. 인용 페이지 기준으로는 글자 그대로 맞지만, **Anti-DDoS 관리형 규칙 그룹 전용 페이지가 추가 요금을 명시**한다 → 「그 밖의 모든」이 거짓이 된다. 🔴 가 아닌 이유: 문항의 인용 페이지가 지금도 그렇게 적는다(공식 내부 어긋남, §6-1).
- **인용 페이지** `waf/latest/developerguide/waf-managed-rule-groups.html` — "…Bot Control, … (ATP), and … (ACFP) are available for additional fees… **All other AWS Managed Rules rule groups are available to AWS WAF customers at no additional cost.**"
- **정본(더 구체적인 쪽)** `https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-anti-ddos.html` — "**You are charged additional fees when you use this managed rule group.**"
- **수정안**: 정답 보기는 유지하고 해설의 「그 밖의 모든 AWS Managed Rules 는 추가 비용이 없으며」를 「소개 페이지는 그 셋을 들지만 **Anti-DDoS 관리형 규칙 그룹도 전용 페이지가 추가 요금을 적습니다**」로 고친다. D-15(더 구체적인 쪽이 정본)와 같은 처리다. 오답 보기 가운데 Anti-DDoS 를 「무료」로 전제한 것이 있으면 함께 본다.
- **전수**: `scs-t3-1.md` L114(「셋 다 추가 요금」)·L259~260(과금 층) · `scs-t2-1.md` L140(Shield Advanced 구독이 주는 L7 Anti-DDoS 규칙 그룹 접근 — 사실 서술이고 「무료」 단정 아님) · 문항 `t3-1-q3`. 교차: **`saa-t1-4` 는 이미 「추가 요금」으로 적는다**(§5).
- **가드**: `scs_questions_test.dart`(§4 3단계 가드)가 이 id 의 문구를 묶는다.

#### Y2 · scs-t3-1-q1 — 🔴 `q5` 와 같은 귀속(「함께 쓰며」) + 출처 제목이 옛 `h1`
- **공개**: true · **정답 인덱스**: **0**
- **결함**: 해설 「오리진 직접 접근은 … CloudFront 커스텀 헤더와 관리형 접두사 목록을 **함께 쓰며**」가 같은 체크리스트 페이지를 출처로 든다(페이지는 "Alternatively"). 출처 제목 「Security checklist for ecommerce」는 현행 `h1`(「…for marketplace distributions」)과 다르다.
- **수정안**: `q5` 와 같은 출처로 교체, 「함께 쓰며」를 「커스텀 오리진 헤더(와 관리형 접두사 목록)로 막으며」 정도로 낮춘다. 정답 보기 문구는 그대로 둘 수 있다.
- **전수**: §1 `scs-t3-1-q5` 항목과 같다. **가드**: `scs_source_fix_test.dart`.

#### Y3 · scs-t3-1-q12 — 「기본 2 WCU + 키마다 30 WCU」가 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **3**
- **인용 페이지** `waf/…/waf-rule-statement-type-rate-based-aggregation-options.html` — `WCU` 탐침 0건(키별 사용 횟수 제약은 있다).
- **정본** `https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-statement-type-rate-based.html` — "**WCUs – 2, as a base cost. For each custom aggregation key that you specify, add 30 WCUs.**"
- **수정안**: 출처 1개 추가(+ `scs-t3-1.md` 출처). 사실·정답 불변.

#### Y4 · scs-t3-1-q15 — 「제공자의 지식재산 보호」 문장이 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **2**
- **인용 페이지** `waf/…/marketplace-rule-groups.html` — `intellectual property` 0건(「each account in your organization must subscribe」는 있다 ✓, GovCloud 제약은 둘째 출처 ✓).
- **정본** `waf/latest/developerguide/waf-managed-rule-groups.html` — "To protect the intellectual property of the rule group providers, you can't view all of the details for the individual rules within a rule group."
- **수정안**: 출처 1개 추가. 사실·정답 불변.

#### Y5 · scs-t5-1-q1 — 「생성 경로별 기본 보안 정책」이 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **0**
- **인용 페이지** `elasticloadbalancing/latest/application/create-https-listener.html` — `ELBSecurityPolicy-2016-08` 0건 · `Res-PQ-2025-09` 0건.
- **정본** `https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html` — "…is ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09. **Other methods (for example, the AWS CLI, AWS CloudFormation, and the AWS CDK) – The default security policy is ELBSecurityPolicy-2016-08.**"
- **수정안**: 출처 교체 또는 추가. 사실·정답 불변(이 문항의 사실은 정확하다).

#### Y6 · scs-t1-1-q9 — 「홈 리전은 옵트인 리전일 수 없다」·「2019-03-20」이 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **0**
- **인용 페이지** `securityhub/latest/userguide/finding-aggregation.html` — `opt-in` 0 · `2019` 0 · `disabled by default` 0.
- **정본** `https://docs.aws.amazon.com/securityhub/latest/userguide/finding-aggregation-enable.html` — "**You can't use an AWS Region that is disabled by default as your home Region.**" 날짜(2019-03-20)는 `securityhub/…/securityhub-regions.html`·`accounts/latest/reference/manage-acct-regions.html`(둘 다 `200 r=0`) 쪽이다.
- **수정안**: 출처 추가. 지문의 「2019년 이후 도입된 리전」은 그대로 둘 수 있으나 **해설의 「2019년 3월 20일」에 그 출처를 붙인다**.
- **전수**: `scs-t1-1.md` L99 · L185 · L268(같은 서술 — md 출처에도 추가).

#### Y7 · scs-t4-1-q7 — 「AssumeRole 권장」·`DurationSeconds` 제약이 인용 두 페이지에 없다
- **공개**: true · **정답 인덱스**: **2**
- **인용 페이지** `IAM/…/id_credentials_sts-comparison.html` · `IAM/…/id_credentials_temp_request.html` — `recommended` 0건(둘 다).
- **정본** `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_enable-console-custom-url.html` — "Call the AWS STS **AssumeRole (recommended) or GetFederationToken** API operations…" · "When you use DurationSeconds in an AssumeRole* operation, **you must call it as an IAM user with long-term credentials. Otherwise, the call to the federation endpoint in step 3 fails.**"
- **수정안**: 출처 1개 추가(**`scs-t4-1.md` 출처에도 없다** → G-84 선작업). 사실·정답 불변. ⚠️ 이 문구는 보고 §4 3단계가 넣은 것이고 그때 출처를 달지 않았다. **가드**: `scs_questions_test.dart` · `scs_s6_review_fix_test.dart`.

#### Y8 · scs-t4-1-q6 — 「관리형 정책 ARN 최대 10개」가 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **1**
- **인용 페이지** `IAM/…/id_credentials_sts-comparison.html` — `up to 10` 0 · `PolicyArns` 0.
- **정본** `https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html` — "You can use the PolicyArns parameter to specify **up to 10 managed session policies**."
- **수정안**: 출처 추가 또는 그 부연 한 문장 삭제(정답을 가르지 않는다).

#### Y9 · scs-t2-1-q2 — 「SageMaker AI 노트북」 쪽 절반이 무출처다
- **공개**: true · **정답 인덱스**: **1**
- **결함**: 정답의 둘째 짝(「질의를 같은 순서로 재현 = SageMaker AI 노트북」)과 해설 「노트북은 런북의 실행 가능한 판」의 근거가 출처에 없다. 인용 `systems-manager/…/OpsCenter.html` 에 `SageMaker` 0 · `notebook` 0. 공식 시험 가이드 `기술 2.1.1` 이 예시로 「Systems Manager OpsCenter, Amazon SageMaker AI 노트북」을 드는 것은 사실이나, **그 노트북이 대응 계획에서 맡는 역할을 적는 docs 페이지는 찾지 못했다**(§6-4).
- **수정안**: (a) 해설에 「공식 시험 가이드가 기술 2.1.1 의 예시로 두 이름을 든다」를 근거로 적고 역할 서술을 「조사 질의를 셀로 보관해 재현하는 용도」 수준의 일반 서술로 낮추거나 (b) OpsCenter 쪽만 묻는 문항으로 좁힌다. **사람 판정**.
- **가드**: `scs_s6_review_fix_test.dart`.

#### Y10 · scs-t2-1-q15 — 「메모리 캡처 뒤 격리」 순서가 인용 페이지가 아니라 형제 페이지에 있다
- **공개**: true · **정답 인덱스**: **2**
- **인용 페이지** `solutions/…/architecture-overview.html` — 격리 판정·수집 흐름 개요는 있으나 「메모리 → 격리」 선후 문장은 `forensic-memory-and-disk-acquisition-service.html`(같은 가이드, `scs-t2-2-q1` 이 인용)에 있다.
- **수정안**: 출처 1개 추가. 사실·정답 불변. **가드**: `scs_s6_review_fix_test.dart`.

#### Y11 · scs-t2-1-q14 — 유지 관리 상태의 출처가 없고, `W0` 이 상태를 반박 근거처럼 쓴다
- **공개**: true · **정답 인덱스**: **1**
- **결함 ①**: 해설 「그 기능은 2026-03-31 공지로 유지 관리 상태입니다」의 근거가 출처에 없다. 인용 `r53recovery/latest/dg/what-is-route53-recovery.html` 에 `maintenance` 0 · `new customers` 0("Readiness check is not intended to be used in the critical path for failover during an event." 는 있다 ✓).
- **정본** `https://docs.aws.amazon.com/general/latest/gr/maintenance_services.html`(ARC Readiness Check · 2026-03-31, 이 세션에서 본문 판독).
- **결함 ②**: `W0` 「…그 기능은 유지 관리 상태입니다. 새로 설계한다면 이 기능에 의존하지 않습니다」 — 보기 `[0]` 이 틀린 이유는 **임계 경로용이 아니라는 것**이지 상태가 아니다. 상태가 반박 근거처럼 읽힌다(6단계 배치 3 이 세운 규율: 상태 문구는 가르치는 층에만).
- **수정안**: 출처 1개 추가 + `W0` 에서 상태 문장을 뺀다(해설에는 남긴다). **가드**: `scs_s6_review_fix_test.dart`.

#### Y12 · scs-t6-1-q7 — 「관리 계정 영향」·「유효 정책 보기」 열은 인용한 표가 아니라 다른 페이지의 표에 있다
- **공개**: true · **정답 인덱스**: **0**
- **결함**: 정답 보기 「공식 표가 관리 계정 영향과 서비스 연결 역할 통제를 선언적 정책만 예로 적습니다」, 해설 「선언적 정책 페이지에 … 표로 싣습니다. 서비스 연결 역할 통제와 관리 계정 영향과 유효 정책 보기가 모두…」. 인용한 선언적 정책 페이지의 비교표에는 **`Governs service-linked roles? No No Yes` 는 있으나 `management account` 가 0건**이다.
- **정본** `https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies.html` — 표 머리 "Policy type | Policy category | **Affects management account** | … | **Supports viewing effective policy for OU or account**" 와 행 "SCP Authorization **No** … **No** / RCP Authorization **No** … **No** / Declarative policy Declarative **Yes** … **Yes**".
- **수정안**: 출처 1개 추가하고 해설을 「두 페이지의 표」로 고친다. 사실·정답 불변. **가드**: `scs_s6_review_fix_test.dart`.

#### Y13 · scs-t6-1-q3 — 「매일 스캔」·`preCreate`/`preUpdate` 가 인용 페이지에 없다
- **공개**: true · **정답 인덱스**: **2**
- **인용 페이지** `controltower/latest/controlreference/control-behavior.html` — 구현 수단 셋 ✓("implemented using Service Control Policies (SCPs), Resource Control Policies (RCPs), and declarative policies") · 리전 범위 ✓("Preventive controls are supported in all AWS Regions" / "Detective controls apply only in those AWS Regions supported by AWS Control Tower"). 그러나 `daily` 0 · `preCreate` 0.
- **정본** `https://docs.aws.amazon.com/controltower/latest/userguide/drift.html` — "AWS Control Tower **scans your managed SCPs, RCPs, and Declarative policies daily**…" / `https://docs.aws.amazon.com/controltower/latest/controlreference/proactive-controls.html` — "these proactive controls are implemented as **preCreate and preUpdate hook handlers**". 둘 다 `scs-t6-1.md` 출처에 이미 있다(G-84 문제 없음).
- **수정안**: 출처 2개 추가. 사실·정답 불변.

### 2-B. 드래프트 문항 19개

#### Y14 · scs-t1-3-q15 — 지문 전제가 정답과 모순된다
- **공개**: false · **정답 인덱스**: **1**
- **결함**: 지문 「알람이 **ALARM 상태로 바뀌었는데** 연결된 작업이 실행되지 않았다 … 그 시점의 평가 상태가 IN_WARM_UP」 ↔ 정답 「워밍업 기간에는 알람이 **INSUFFICIENT_DATA 에 머물며**…」. 워밍업 중에는 ALARM 으로 전이하지 않으므로 지문의 상황이 성립하지 않는다.
- **공식 근거** `AmazonCloudWatch/latest/monitoring/alarm-evaluation.html` — "IN_WARM_UP – Indicates that the alarm is in its warm-up period and **does not yet evaluate. The alarm remains in INSUFFICIENT_DATA and does not perform alarm actions** until the warm-up period ends."
- **수정안**: 지문을 「지표가 임계값을 넘었는데 알람이 ALARM 으로 바뀌지 않고 작업도 실행되지 않았다」로 고친다. 보기·정답 불변. **가드**: `scs_s6_review_fix_test.dart` 가 이 id 를 든다(지문을 리터럴로 묶었는지 먼저 확인).

#### Y15 · scs-t1-3-q3 / Y16 · scs-t1-3-q4 — 「실행 로깅의 로그 그룹은 API Gateway 가 관리」가 인용 페이지에 없다
- **공개**: false · **정답 인덱스**: `q3` **1** · `q4` **3**
- **인용 페이지** `apigateway/latest/developerguide/set-up-logging.html` — 두 로깅의 독립성 ✓ · STS ✓("API Gateway calls AWS Security Token Service in order to assume the IAM role, so make sure that AWS STS is enabled for the Region"). 그러나 로그 그룹 관리 주체 문장은 없고, 오히려 "**You can also configure Amazon CloudWatch Logs delivery to route execution logs to your own destinations.**" 를 적는다.
- **정본** `https://docs.aws.amazon.com/apigateway/latest/developerguide/view-cloudwatch-log-events-in-cloudwatch-console.html` — "…a log group of the `API-Gateway-Execution-Logs_{rest-api-id}/{stage-name}` name" · "**API Gateway creates log groups or log streams for an API stage at the time when it is deployed.**"
- **수정안**: `q3` 해설·`q4` `W1` 의 「API Gateway 가 관리」를 「기본 경로에서는 API Gateway 가 스테이지 배포 시 로그 그룹을 만든다」로 정밀화하고 출처 추가(md 출처에도). 정답 불변.

#### Y17 · scs-t1-2-q12 / Y18 · scs-t1-2-q13 — 「변환 = Lambda / 색인 = OpenSearch / 시각화 = Managed Grafana」 층 배치가 무출처다
- **공개**: false · **정답 인덱스**: `q12` **3** · `q13` **0**
- **결함**: `q12` 는 CloudWatch Logs Insights 페이지를, `q13` 은 Security Lake 두 페이지를 출처로 달지만 **세 서비스의 층 배치를 적는 문장은 그 페이지들에 없다**(`q13` 의 OCSF·Parquet 변환은 ✓). 착수 노트의 열린 갭 **G-31**(Athena·OpenSearch·Lambda·Managed Grafana 미측정)이 그대로 남은 자리다. 사실 자체는 상식적으로 옳아 🔴 는 아니다.
- **수정안**: 세 서비스 각각의 소개 페이지를 측정해 출처로 달거나(G-84 → md 출처에도) 문항에서 「공식」 귀속을 빼고 요구-서비스 매칭 문항으로 둔다. 둘은 **같은 사실의 겹침**이기도 하다(§3 G4).
- **가드**: `q12` 는 `scs_s6_review_fix_test.dart`, `q13` 은 `scs_source_fix_test.dart`.

#### Y19 · scs-t2-2-q1 — 「스냅샷 → 격리」 선후는 공식 흐름이 고정하지 않는다
- **공개**: false · **정답 인덱스**: **0**
- **결함**: 정답 「메모리 덤프, EBS 스냅샷, 보안 그룹 비우기 순서」, `W1` 「공식 흐름의 순서도 수집 뒤 격리입니다」. 인용 페이지가 고정하는 것은 **메모리 캡처 → 격리**뿐이고 그 페이지에 `snapshot` 은 0건이다(디스크 수집은 별 워크플로 페이지). 정답 유일성은 유지된다(다른 보기가 「휘발성 순서」 원칙으로 갈린다).
- **수정안**: 해설·`W1` 의 귀속을 「공식 흐름이 고정하는 것은 메모리 캡처 뒤 격리이고, 디스크 스냅샷을 격리 앞에 두는 것은 휘발성 순서 원칙의 적용」으로 가른다. 같은 구분을 공개 `t2-1-q15` 해설이 이미 쓴다.
- **가드**: `scs_s6_review_fix_test.dart`.

#### Y20 · scs-t3-2-q12 — `PULL_REQUEST|PUSH`·`WEEKLY|MONTHLY|NEVER` 가 인용한 API 페이지가 아니라 하위 자료형 페이지에 있다
- **공개**: false · **정답 인덱스**: **3**
- **인용 페이지** `inspector/v2/APIReference/API_CodeSecurityScanConfiguration.html`(추출 1,478자) — `ruleSetCategories`(최소 1·최대 3·`SAST|IAC|SCA`) ✓, 나머지 둘의 유효값은 `API_ContinuousIntegrationScanConfiguration.html`·`API_PeriodicScanConfiguration.html` 에 있다(둘 다 `200 r=0`).
- **수정안**: 출처 2개 추가(md 출처에도). 사실·정답 불변. **가드**: `scs_source_fix_test.dart`(q12 그룹 3건 — 출처 집합을 묶는다).

#### Y21 · scs-t3-2-q13 — CodeGuru Security 종료 서술의 출처가 없다
- **공개**: false · **정답 인덱스**: **0**
- **결함**: 해설이 「Amazon CodeGuru 보안은 지원이 종료되어 사용자 안내서가 제공되지 않으므로」를 적는데 출처는 Inspector 페이지 하나다. 같은 Task `q12` 는 그 근거(`cli/latest/reference/codeguru-security/` — "On November 20, 2025, AWS will discontinue support…")를 출처로 단다.
- **수정안**: `q12` 와 같은 출처 1개 추가. **가드**: `scs_source_fix_test.dart` · `scs_s6_review_fix_test.dart`.

#### Y22 · scs-t3-3-q14 — 정답 보기의 「온디맨드 분석이라 상시 검증은 주기 실행 자동화」가 확인되지 않는다
- **공개**: false · **정답 인덱스**: **1**
- **결함**: `MatchPaths`·`ExcludePaths` 정의는 인용 `what-is-network-access-analyzer.html` 에 ✓. 그러나 **정답 보기 뒤 절반**(「온디맨드 분석 → 주기 실행 자동화」)은 Network Access Analyzer 세 페이지(`what-is`·`working-with-network-access-scopes`·`how-network-access-analyzer-works`)에서 `on-demand`·`on demand`·`continuous`·`schedul` **전부 0건**이다(대조군 `MatchPaths` 4건). 또 해설의 「자동 추론」은 인용 `what-is` 에 없고(`reasoning` 0) `how-network-access-analyzer-works.html` 에 있다 — "uses **automated reasoning algorithms**… performs a **static analysis** of a network configuration, meaning that no packets are transmitted".
- **수정안**: 정답 보기에서 뒤 절반을 빼고(「…ExcludePaths 에 정당한 예외를 적습니다. 구성만 보는 정적 분석이라 트래픽을 흘리지 않습니다」) 출처에 `how-…-works.html` 을 더한다. 「온디맨드」는 **확인되지 않았다**로 둔다(§6-6). 인용 `working-with-network-access-scopes.html` 은 1,774자 목차 페이지라 사실 출처로 쓰지 않는다.
- **주의**: 보기 길이가 바뀌므로 `scs_length_cue_test` 비율을 다시 잰다.

#### Y23 · scs-t3-3-q15 — 해설의 Network Access Analyzer 대비 서술이 인용 페이지에 없다
- **공개**: false · **정답 인덱스**: **2**
- **결함**: Inspector 네트워크 도달성 사실은 인용 `inspector/latest/user/findings-types.html` 로 ✓. 해설 후반의 NAA 대비(자동 추론·경로 기반)는 출처 제목이 「자동 추론과 분석 대상」인 `what-is-network-access-analyzer.html` 을 들지만 그 페이지에 `reasoning` 0건이다(Y22 와 같은 정본).
- **수정안**: 출처를 `how-network-access-analyzer-works.html` 로 교체. 정답 불변. **가드**: `scs_s6_review_fix_test.dart`.

#### Y24 · scs-t4-2-q6 — 조건 키와 「RBAC 옆에 ABAC 를 더하라는 권고」가 인용 페이지에 없다
- **공개**: false · **정답 인덱스**: **1**
- **인용 페이지** `IAM/…/introduction_attribute-based-access-control.html` — ABAC·RBAC 비교는 있으나 `aws:ResourceTag`·`aws:RequestTag`·`aws:TagKeys`·`aws:PrincipalTag` 전부 0건, 「공존 권고」 계열(`alongside`·`in addition`·`combin`·`together`·`recommend`) 0건.
- **정본(조건 키)** `https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html`(`200 r=0`). **「공식은 … RBAC 옆에 ABAC 를 더하는 길을 권합니다」는 확인되지 않았다**(§6-7).
- **수정안**: 정답 보기 끝 「RBAC 와 공존을 권합니다」와 해설 마지막 문장을 빼거나 「두 모델은 함께 쓸 수 있다」 수준으로 낮추고 조건 키 출처를 단다. 보기 길이 재측정.

#### Y25 · scs-t5-2-q6 / Y26 · scs-t5-2-q14 — DLM 과 잠긴 스냅샷의 관계가 인용 페이지에 없고, 공식 서술이 더 정밀하다
- **공개**: false · **정답 인덱스**: `q6` **2** · `q14` **1**
- **결함**: 「Data Lifecycle Manager 는 보존 정책과 무관하게 잠긴 스냅샷을 삭제할 수 없다」가 인용 `ebs-snapshot-lock.html`(`Data Lifecycle Manager` 0건)·`dlm-elements.html`(`lock` 0건)에 없다. 잠금 자체(IAM 무관 삭제 불가 · 추가 비용 없음)와 기본 정책 「리소스 유형당 하나」는 ✓.
- **정본** `https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-ami-policy.html` — "If you manually lock a snapshot created by Amazon Data Lifecycle Manager, and that snapshot is still locked when its retention threshold is reached, **Amazon Data Lifecycle Manager no longer manages that snapshot. You must manually delete the snapshot if it is no longer needed.**"
- **수정안**: 출처 추가(md 출처에도)하고 귀결을 정밀화한다 — 「삭제할 수 없다」에 더해 **「보존 임계 시점에 잠겨 있던 스냅샷은 DLM 관리에서 벗어나 잠금이 풀린 뒤에도 수동 삭제가 필요하다」**. `q14` 의 지문(「보존 기간을 넘겨도 삭제되지 않습니다」)과 정확히 맞는 문장이다. 정답 불변.
- **전수**: `scs-t5-2.md` L172 · L261(같은 서술).

#### Y27 · scs-t5-2-q11 — 「IA 전에는 Archive 로 갈 수 없다」의 정본이 API 참조이고 인용 페이지는 다르게 읽힌다
- **공개**: false · **정답 인덱스**: **2**
- **인용 페이지** `efs/latest/ug/lifecycle-management-efs.html` — "Transition into Archive – Instructs lifecycle management when to move files **from the Standard or IA storage class** in to the Archive storage class" (`before transitioning` 0건).
- **정본** `https://docs.aws.amazon.com/efs/latest/APIReference/API_PutLifecycleConfiguration.html` — "**File systems cannot transition into Archive storage before transitioning into IA storage.** Therefore, TransitionToArchive must either not be set or must be later than TransitionToIA."
- **수정안**: 출처 추가(md 출처에도), 해설의 「공식이 … 적습니다」를 API 참조에 귀속. 두 페이지의 표현 차이는 §6-3. 정답 불변.

#### Y28 · scs-t5-2-q9 — Signer 의 IoT·컨테이너·Notation 부연이 무출처다
- **공개**: false · **정답 인덱스**: **0**
- **인용 페이지** `lambda/latest/dg/governance-code-signing.html` — 버전 관리 버킷 ✓ · 검증 정책 ✓. `IoT`·`Notation`·`container` 0건.
- **수정안**: 그 부연 문장을 지우거나 Signer 개발자 안내서를 측정해 출처로 단다(정답을 가르지 않는 문장이라 삭제가 싸다 — 해설 길이도 준다).

#### Y29 · scs-t5-3-q7 — `W3` 「모든 키 저장소 유형이 FIPS 140 보안 수준 3으로 검증됩니다」가 과잉 일반화다
- **공개**: false · **정답 인덱스**: **2**
- **인용 페이지** `kms/latest/developerguide/key-store-overview.html` — "…generated in and protected by hardware security modules (HSMs) that are **FIPS 140-3 Level 3 validated**"는 **표준 키 저장소의 KMS HSM** 서술이다. 외부 키 저장소의 HSM 은 고객이 고르므로 「모든 유형」으로 일반화할 근거가 그 페이지에 없다.
- **수정안**: `W3` 을 「키 저장소 유형과 무관하게 통제 입증이 불가능하다는 전제가 틀렸습니다. 공식이 가져온 키로 그 요건에 답하는 길을 적습니다」로 바꾼다. 정답 불변.

#### Y30 · scs-t6-2-q6 — `aws:RequestTag`·`aws:TagKeys` 가 인용 페이지에 없다
- **공개**: false · **정답 인덱스**: **1**
- **인용 페이지** `organizations/…/orgs_manage_policies_tag-policies.html` — "**Untagged resources or tags that aren't defined in the tag policy aren't evaluated for compliance with the tag policy.**" ✓. 조건 키 둘은 0건.
- **정본(조건 키)** `IAM/latest/UserGuide/reference_policies_condition-keys.html`. 「태그 정책 = 선언적 범주」는 `orgs_manage_policies.html` 표("Tag policy | Declarative")로 **옳다**(결함 아님).
- **수정안**: 출처 2개 추가. 정답 불변. **가드**: `scs_s6_review_fix_test.dart`.

#### Y31 · scs-t6-2-q14 — 「Account Factory 가 Service Catalog 위의 추상화」 부연이 무출처다
- **공개**: false · **정답 인덱스**: **1**
- **인용 페이지** `servicecatalog/latest/adminguide/introduction.html` — 표준화·세분화된 액세스 제어·버전 전파 ✓. `Account Factory`·`Control Tower` 0건.
- **수정안**: 그 문장을 지우거나 Control Tower Account Factory 페이지를 측정해 단다(삭제가 싸다 — `explanation-long` 438자도 함께 준다).

#### Y32 · scs-t6-3-q9 — 정답 보기가 신규 고객에게 닫힌 서비스다 (저작 결정 D-04 와 충돌)
- **공개**: false · **정답 인덱스**: **0**
- **결함**: 정답이 「첫째는 AWS Artifact, 둘째는 **AWS Audit Manager**」. 해설이 상태를 정직하게 적지만(「신규 고객에게 열려 있지 않고 … 새로 도입하는 조직이라면 그 선택지가 없습니다」), 저작 결정 **D-04 는 닫힌 서비스를 정답 보기로 쓰지 않는다**고 정했다. 사실은 옳고 공식 `기술 6.3.2` 가 그 이름을 예시로 들어서 🔴 가 아니다.
- **수정안(사람 판정)**: (a) 지문을 「이미 Audit Manager 를 쓰는 조직」으로 한정하거나 (b) 둘째 요구의 답을 닫히지 않은 수단(AWS Config 준수 팩·Security Hub CSPM 의 준수 결과)으로 바꿔 Artifact 와 가르는 문항으로 다시 쓴다. (b) 는 같은 Task `q13`~`q15` 와의 겹침(§3 G4)도 함께 푼다.
- **가드**: `scs_s6_review_fix_test.dart`(6단계 배치 3 이 이 문항의 길이·상태 문구를 다뤘다).

### 2-C. 「결함 아님」으로 확정한 것 — 과대 보고 방지 기록

처음에 결함 후보였다가 **다른 표현 재탐침으로 철회**한 자리다. 2단계가 다시 의심하지 않도록 적는다.

| 문항 | 의심 | 판정 근거 |
|---|---|---|
| `scs-t4-2-q12`(정답 3) | 「정책 검증에 추가 요금이 없다」 | 인용한 `access-analyzer-reference-policy-checks.html` 에 "**There is no additional charge associated with running the policy validation checks.**" 실재. 유형 넷(`Error`·`Security Warning`·`General Warning`·`Suggestion`)도 그 페이지에 실재 |
| `scs-t6-3-q6` | 애그리게이터 추가 비용 없음 | `config/…/aggregate-data.html` 에 "Using aggregators does not incur any additional costs" 실재 |
| `scs-t6-1-q5`(정답 3) | 랜딩 존 4.0 필수 제어 | 인용 `control-behavior.html` 에 "Starting with AWS Control Tower Landing Zone version 4.0, mandatory controls are no longer applied by default." 실재(둘째 출처 `controls.html` 은 목차지만 첫째가 사실을 담는다) |
| `scs-t5-2-q13` | 「Vault Lock」 상태 누락 | **AWS Backup** Vault Lock 이다 — Glacier 저장소 잠금과 이름만 겹친다(상태 트리거의 거짓 양성) |
| `scs-t5-2-q15` · `scs-t5-3-q15` | DataSync VPC 엔드포인트 · Private CA 와 EKS | 좁은 탐침의 거짓 음성이었고 다른 표현으로 실재 확인 |
| `scs-t6-2-q6` | 태그 정책이 「선언적」 범주 | `orgs_manage_policies.html` 표 "Tag policy \| Declarative" |
| `scs-t4-1-q4` `W0` | 오답 근거의 상태 문구 | 그 보기가 틀린 이유가 **상태 자체**(SMS MFA 활성화 종료)라 정당하다 |

---
## 3. 🟢 (9묶음 — 사실은 옳다)

### G1 · 메타 문구 — `prescreen` meta-phrasing **76문항**(32%)
- 지문에 「공식」이 든 문항 **67개**(공개 24), 정답 보기에 든 문항 **13개**, 해설에만 쓴 문항 171개(해설의 출처 귀속은 정당한 층이라 대상이 아니다).
- Task 별 meta-phrasing: `t1-1` 6 · `t1-2` 11 · `t1-3` 8 · `t2-1` 3 · `t2-2` 5 · `t3-1` 2 · `t3-2` 1 · `t3-3` 4 · `t4-1` 7 · `t4-2` 5 · `t5-1` 2 · `t5-2` 3 · `t5-3` 5 · `t6-1` 7 · `t6-2` 1 · `t6-3` 6.
- **정답 보기에 「공식」이 든 13개**(정답 표식이 될 수 있어 우선): `t1-2-q15`(1) · `t1-3-q7`(1) · **`t2-1-q11`(2, 공개)** · `t3-3-q4`(3) · **`t5-1-q14`(3, 공개 — §1)** · `t5-3-q7`(2) · `t5-3-q13`(0) · **`t6-1-q7`(0, 공개 — Y12)** · **`t6-1-q15`(3, 공개 — §1)** · `t6-2-q8`(3) · `t6-3-q1`(0) · `t6-3-q11`(2) · `t6-3-q13`(0). 괄호는 정답 인덱스 실측.
- **수정안**: 지문의 「공식 서술로 올바른 것은」을 「올바른 것은」으로, 정답 보기의 「공식이 …라고 적습니다」를 사실 서술로 바꾼다(AIP 트랙이 첫 배치에서 0건으로 세운 규율). 문항별 목록은 `node tool/prescreen.mjs build scs` 가 `flutter_app/build/scs_review/*.prescreen.json` 에 다시 만든다.
- 「시험 가이드」를 해설에서 드는 문항 3개(`t3-2-q12`·`t3-2-q13`·`t6-3-q13`)는 6단계 배치 3 이 **금지하지 않기로 판정**한 자리라 그대로다.

### G2 · 긴 해설 — `prescreen` explanation-long **29문항**(임계 400자, 공개 8)
- 공개: `t2-1-q6`(552) · `t5-1-q10`(490) · `t3-1-q2`(460) · `t6-1-q13`(450) · `t4-1-q9`(433) · `t3-1-q4`(430) · `t6-1-q4`(420) · `t6-1-q15`(413).
- 드래프트: `t5-3-q3`(619) · `t2-2-q10`(600) · `t5-2-q7`(569) · `t3-2-q2`(516) · `t6-3-q7`(510) · `t5-3-q10`(506) · `t6-2-q5`(504) · `t5-3-q12`(477) · `t5-2-q13`(475) · `t5-3-q9`(469) · `t6-2-q12`(463) · `t6-2-q11`(461) · `t1-2-q11`(448) · `t5-3-q7`(447) · `t6-2-q13`(447) · `t5-3-q14`(441) · `t6-2-q14`(438) · `t6-3-q1`(433) · `t6-2-q10`(422) · `t6-2-q15`(422) · `t5-3-q11`(409).
- 쏠림: `t5-3` 7 · `t6-2` 7. 대부분 6단계 배치 5-B 의 **보강**(새 사실을 해설에 더함)과 정답 줄이기(둘째·셋째 사실을 해설로 넘김)의 귀결이다. 걷을 후보는 **오답 근거가 이미 적는 문장**과 §2 의 무출처 부연(Y28·Y31)이다.

### G3 · 반대 방향 길이 단서 2건 + 가드 빈틈
- `scs-t3-1-q3`(공개 · 정답 **2**): 정답 47자 < 최단 오답 49자. `scs-t3-2-q12`(드래프트 · 정답 **3**): 정답 77자 < 최단 오답 80자.
- 둘 다 `scs_length_cue_test.dart` 의 **`handled` 목록 밖**이라 「정답이 최단 오답보다 짧지 않다」 단정이 걸리지 않는다(전자는 §4 3단계, 후자는 §4 1단계에서 손댔고 길이 배치 목록에 들지 않았다). **수정안**: 하한 단정을 `handled` 가 아니라 **240문항 전수**로 건다(상한 「> 1.3 = 0건」은 이미 전수다).
- 참고(결함 아님): 정답이 네 보기 중 **유일하게 가장 긴** 문항이 212/240 이다. 전부 1.3배 이내라 가드는 통과하고, 중앙값은 정답 70자 / 오답 50자다. 방향성 단서가 남아 있다는 기록으로만 적는다.

### G4 · 겹침 — 지표(자카드) 아래에 있어 읽어서 찾은 4묶음
전수 28,680쌍에서 ≥ 0.33 은 0쌍, ≥ 0.25 는 1쌍(`t4-2-q8`(3)↔`t4-2-q9`(0) 조사벗김 0.292 — 역할 ARN 대 세션 ARN 으로 **다른 사실**)이고 상위 45쌍을 읽었다.

| 묶음 | 문항(정답 인덱스) | 겹치는 사실 | 비고 |
|---|---|---|---|
| ① | `t3-3-q3`(2) ↔ `t3-3-q12`(3) | Network Firewall 이 VPC 피어링을 검사하지 못한다 | `q12` 는 6단계 배치 1 이 교체해 넣은 문항 — **교체가 만든 겹침**. `q12` 가 셋을 열거하고 `q3` 이 그중 하나를 시나리오로 묻는다. `q3` 을 「어플라이언스 모드」 쪽으로 돌리면 풀린다 |
| ② | `t6-3-q13`(0) · `q14`(1) · `q15`(2) | Well-Architected Tool 과 Agent 의 한 비교표 | 기술 6.3.3 의 3문항이 전부 같은 표다. 하나를 렌즈·마일스톤 운용 시나리오로 돌린다 |
| ③ | `t1-2-q12`(3) ↔ `t1-2-q13`(0) | Lambda·OpenSearch·Managed Grafana 층 배치 | Y17·Y18 과 함께 처리 |
| ④ | `t3-3-q7`(2) ↔ `t3-3-q9`(0) | Verified Access 가 요청마다 평가한다(자카드 0.160) | `q9` 를 신뢰 공급자·그룹 정책 쪽으로 좁히면 풀린다 |

### G5 · 오답 근거에 놓인 상태 문구 1건(+ Y11)
- `scs-t6-3-q13`(드래프트 · 정답 **0**) `W1`: 「요건이 구조적 검토와 시점 추적이라 Tool 쪽이고 **Agent 는 프리뷰 릴리스입니다**」 — 보기가 틀린 이유는 요건 불일치이고 프리뷰 상태가 아니다. 상태 문장을 해설로 옮긴다.
- 공개 `scs-t2-1-q14` `W0` 은 §2 Y11 에 적었다. `scs-t4-1-q4` `W0` 은 상태 자체가 반박 근거라 정당하다.
- 전수 방법: `신규 고객`·`지원 종료`·`유지 관리`·`완전 종료`·`프리뷰` 를 `wrongExplanations` 720개에서 찾아 읽었다(3건, 위 셋).

### G6 · 학습문서 `scs-t3-1.md` 본문이 App Runner 를 상태 없이 나열한다
- L80 · L122 · L160 · L347 이 WAF 보호 대상·본문 검사 한도 목록에 App Runner 를 든다. 상태(유지 관리, 2026-03-31)는 출처 항목(L43 · L401)에만 있다. 문항 쪽(`t3-1-q2`·`q8`)은 6단계 배치 5-B 가 **해설에** 상태를 달았다 — md 본문만 비대칭이다.
- **수정안**: 목록 중 한 자리(L122 권장)에 「App Runner 는 2026-03-31 공지로 유지 관리 상태」 한 줄을 단다. 공식 WAF 페이지가 지금도 그 이름을 목록에 싣는 것은 사실이라 **지우지 않는다**.

### G7 · 짧은 단정형 오답 근거 — 720개 중 20자 이하 **56개**(15자 이하 18)
- 중앙값 41자. 쏠림: `t6-3` 10 · `t5-3` 7 · `t3-3` 6 · `t4-2` 6. 예: `scs-t5-3-q7` `W0`「공식은 모든 옵션이 똑같이 안전하다고 적습니다.」 · `scs-t6-3-q9` `W3`「두 서비스의 역할이 반대로 적혀 있습니다.」 · `scs-t1-2-q12` `W1`「세 짝이 모두 어긋났습니다.」
- 왜 틀렸는지를 말하지 않고 틀렸다고만 말한다. 오답노트 화면에서 학습 가치가 낮다. 목록은 `wrongExplanations` 길이로 다시 뽑으면 된다(`len ≤ 20`).

### G8 · 5-A 가 닫았다고 기록한 「개수 표현」 잔존 1자리
- `scs-t6-3-q8`(드래프트 · 정답 **3**) `W1`: 「**전제가 다섯**이고 켜기 전 기간을 소급해 복원하지는 않습니다」 + `scs-t6-3.md` L106 「전제가 다섯입니다」. 인용 페이지의 Considerations 가 실제로 다섯이라 **사실은 옳다**. D-16(개수를 묻지 않는다)의 취지로 보면 `W1` 의 「다섯」은 걷을 자리다(정답 보기는 넷만 열거해 개수와도 어긋나 보인다).

### G9 · 낡은 라벨 2자리
- `scs-t3-1-q1` 출처 제목 「Security checklist for ecommerce」 — 현행 `h1` 은 「…for marketplace distributions」(Y2).
- `scs-t6-1.md` L456 「(2026-11-09 확인)」 — 그 줄의 URL 은 11-17 에 바뀌었다(§1).

### 0건으로 확인한 품질 축
- `length-cue`(정답 ÷ 최장 오답 > 1.3): **0건**(전수 자체 측정 + prescreen).
- `authoring-memo`: prescreen 1건 = `scs-t5-1-q12`(「목록은 외우지 않고 공식 CLI 조회 절차로 확인」) — §4 2단계가 **정당한 서술**로 판정해 가드 주석에 남긴 그 문항이다. 새 결함 아님.
- 문항 안 `**굵게**`·단일 이탤릭·마크다운 링크: **0건**.
- 정답 인덱스 분포 63/65/66/46(Task 별 4/4/4/3, 예외 `t1-2` 3/5/5/2 · `t1-3` 4/4/5/2) — 루브릭이 「정답 위치를 옮기려고 문항을 고치지 않는다」고 정해 결함으로 세지 않는다.
- 난이도 `foundational` 55 · `applied` 185, 전 Task ≥ 2(가드 하한 충족).

---

## 4. 커버리지·범위

### 4-1. 커버리지 — 공식 기술 70개 전부 ≥ 1문항 (0건인 기술 0)
가이드 `skills` 본문에 번호 접두사가 없어 번호는 `task.no + "." + (index+1)` 로 유도했다(70개 유도 · `knowledge` 합 0 · 가이드 밖 `skill` 0건).

| Task | 기술별 문항 수 | Task | 기술별 문항 수 |
|---|---|---|---|
| 1.1 | 3·3·3·4·2 | 4.1 | 5·5·5 |
| 1.2 | 2·3·3·3·2·2 | 4.2 | 3·3·3·3·3 |
| 1.3 | 8·7 | 5.1 | 5·5·5 |
| 2.1 | 4·4·4·3 | 5.2 | 3·6·3·3 |
| 2.2 | 3·3·3·3·3 | 5.3 | 3·3·4·2·3 |
| 3.1 | 4·4·4·3 | 6.1 | 2·4·3·2·4 |
| 3.2 | 2·2·3·2·2·2·2 | 6.2 | 5·4·3·3 |
| 3.3 | 3·3·3·3·3 | 6.3 | 8·4·3 |

- 도메인별 문항 45/30/45/30/45/45 = 18.8/12.5/18.8/12.5/18.8/18.8% ↔ 공식 비중 16/14/18/**20**/18/14%. **D4 가 12.5% 대 20%**로 가장 얇다(Task 가 둘뿐이라 Task 당 15문항 관례의 귀결). 2026-11-11 보고 P-4 가 적은 구조 항목이고 그대로 열려 있다 — 통합 모의고사는 readiness 정책이 비중대로 뽑으므로 **D4 는 같은 문항이 반복 출제될 확률이 가장 높다**.
- 2026-11-11 보고의 P-3(시나리오화)·P-5(문항 유형)도 구조 항목이라 그대로다.

### 4-2. 범위
- **범위 외 2종**(Amazon MWAA · AWS Payment Cryptography): 정답 보기에 든 문항 **0건**. MWAA 는 md·문항 어디에도 0건. Payment Cryptography 는 `scs-t5-3-q10` 해설과 `scs-t5-3.md` 에 대비 서술로만 나온다(정답 보기 아님).
- **범위 내 71종 중 문항이 한 번도 언급하지 않는 것 6종**: Amazon Q Business · Amazon Q Developer · CloudTrail Lake · AWS Trusted Advisor · AWS User Notifications · Amazon Verified Permissions. 앞의 셋은 닫혔거나 부분 종료라 문항으로 만들지 않는 것이 저작 결정(D-04)과 맞다. **Trusted Advisor · User Notifications · Verified Permissions 는 빈 주제**다(2026-11-11 보고 §1-3 「빈 주제」의 잔여와 겹친다).
- `AWS Security Incident Response`: 문항 0건 — D-13(범위 메모만, 문항 금지) 그대로다.

### 4-3. 닫힌·종료된 서비스 상태
- lifecycle 하위 세 페이지(`maintenance_services`·`sunset_services`·`full_shutdown_services`)를 이 세션에서 다시 읽어 대조했다(대조군 `Simple AD`·`AWS App Runner` 양성).
- **가르치는 층(`skill`·지문·정답 보기·해설)의 상태 누락: 0건.** 트리거 — WAF Classic · Inspector Classic · CodeGuru · Q Developer IDE 플러그인 · Simple AD · Cognito Sync · SMS MFA · Glacier 저장소 잠금 · SNS 메시지 데이터 보호 · DataSync Discovery · Audit Manager · AppRegistry · App Runner · ARC 준비 상태 확인 · Well-Architected Agent. 유일한 탐지 `t5-2-q13` 은 AWS Backup Vault Lock(거짓 양성, §2-C).
- 상태의 **출처**가 없는 문항 2건은 §2 에 적었다(Y11 · Y21).

---

## 5. 교차 자격증 — 다른 자격증과 어긋나는 자리 (고치지 않고 적기만)

| 자리 | SCS | 다른 자격증 | 메모 |
|---|---|---|---|
| WAF Anti-DDoS 관리형 규칙 그룹 과금 | `scs-t3-1-q3`·`scs-t3-1.md` L114·L259 가 「추가 요금은 셋, 그 밖은 추가 비용 없음」 | `saa/saa-t1-4.md` L29·L126·L439 와 `saa-t1-4.questions.json`(L48·L53)이 **「Anti-DDoS 관리형 규칙 그룹 = 추가 요금」**으로 적는다 | **SAA 가 옳은 쪽**(전용 페이지 일치). SCS 를 맞춘다(Y1) |
| EMR 전송 중 암호화 인증서 경로 | `scs-t5-1` 이 「둘」(§1) | `dea/dea-t4-3.md` 가 같은 URL(`emr-data-encryption-options.html`)을 참고자료로 단다 — 「둘」 단정은 **없다** | DEA 는 결함 아님. DEA 가 그 페이지에서 인용하는 다른 문장이 지금도 있는지는 DEA 세션 몫 |
| Well-Architected `security-pillar/` 판 | `scs-t6-1` 이 `sec_permissions_emergency_process.html` 을 11-17 에 교체받음(§1) | `clf/t2-2.questions.json` 도 `wellarchitected/latest/security-pillar/` URL 을 든다 | 그 문항이 인용하는 문장이 **현행판에 있는지 재지 않았다**. `security-pillar/` 판 전체에 「historical reference only」 배너가 있다(§6-5) — 같은 11-17 배치가 손댄 다른 자격증도 「URL 이 업고 있던 문장」을 다시 세야 한다 |
| 「Conformance Packs」 표기 | 「준수 팩」(D-11, SCS 가이드 표기) | SOA 「규정 준수 팩」 | **의도된 차이**(자격증별 가이드 표기). 결함 아님 |

---

## 6. 공식 내부 어긋남 / 「확인되지 않음」 — 수정안을 낼 수 없는 것

1. **WAF 관리형 규칙 그룹의 추가 요금 범위** — `waf-managed-rule-groups.html` 은 「Bot Control·ATP·ACFP … All other AWS Managed Rules rule groups … at no additional cost」, `aws-managed-rule-groups-anti-ddos.html` 은 「You are charged additional fees when you use this managed rule group」. 공식 내부 어긋남이다. 더 구체적인 전용 페이지를 정본으로 삼는 처리(D-15 계열)를 권한다(Y1).
2. **CloudFront 오리진 보호 — 「두 수단을 함께」의 근거** — 사람이 열 수 있는 docs 에서는 체크리스트의 "Alternatively" 와 `LocationsOfEdgeServers.html` 의 「all of the CloudFront global origin-facing servers」까지만 확인된다. 「함께 쓰면 고른 배포만 통과」는 백서(`curl` `200 r=1` — 사람이 열 수 없음)에만 있고, 「제3자 배포도 접두사 목록을 통과한다」를 직접 적는 문장은 `repost.aws` 뿐이다 → **docs 로는 확인되지 않았다**. 정답의 논리(접두사 목록은 배포를 가르지 못한다)는 위 문장에서 **따라오는 추론**이다 — 문항이 「공식이 적는다」가 아니라 사실 서술로 쓰면 성립한다.
3. **EFS Archive 전환의 출발 클래스** — 사용자 안내서는 「from the Standard or IA storage class」, API 참조는 「cannot transition into Archive storage before transitioning into IA storage」. 표현이 갈린다. API 참조(제약을 명시)를 정본으로 권한다(Y27).
4. **「Amazon SageMaker AI 노트북」의 인시던트 대응 역할** — 공식 시험 가이드 `기술 2.1.1` 이 예시로 이름만 든다. 그 역할을 설명하는 docs 페이지는 찾지 못했다(OpsCenter 페이지 `SageMaker` 0 · `notebook` 0). **확인되지 않았다**(Y9).
5. **Well-Architected `security-pillar/` 판의 지위** — 현행 `sec_permissions_emergency_process.html` 이 「This whitepaper is for historical reference only and will be deprecated in the future. All updated guidance and best practices now live in the Well-Architected Framework whitepaper」 배너를 단다. 그런데 `framework/` 판은 11-16 재구성으로 BP 번호가 재배정됐고(레포 기록) 이 BP 의 `framework/` 슬러그는 404 였다. **어느 판을 정본으로 삼을지는 사람 판정**이다 — 이 보고는 「현재 인용 URL 의 본문」을 기준으로 🔴 를 적었다.
6. **Network Access Analyzer 가 「온디맨드 분석」이라는 서술** — NAA 세 페이지에서 `on-demand`·`on demand`·`continuous`·`schedul` 0건. **확인되지 않았다**(Y22).
7. **ABAC — 「기존 RBAC 옆에 ABAC 를 더하라」는 공식 권고** — 인용 페이지에 비교는 있으나 권고 문장은 없다. **확인되지 않았다**(Y24).
8. **로그 분석 3층 배치(Lambda·OpenSearch Service·Managed Grafana)** — 착수 노트의 열린 갭 G-31 그대로다. 세 서비스 소개 페이지를 측정하지 않았다(Y17·Y18).
9. **포렌식 — 디스크 스냅샷과 격리의 선후** — 공식 솔루션 페이지가 고정하는 것은 메모리 캡처 → 격리뿐이다. 스냅샷 → 격리 선후는 **확인되지 않았다**(Y19).
10. **CodeGuru Security 의 lifecycle 목록 부재** — 하위 세 페이지에 `CodeGuru Reviewer` 만 있다(2026-11-11 판정 그대로). 종료 근거는 CLI 참조 페이지 본문이다. 새 결함 아님 — 「목록에 없다 ≠ 살아 있다」의 기록.

---

## 7. 2단계에 넘기는 순서 제안

### 7-1. 순서와 의존 관계

| 순서 | 대상 | 의존·주의 |
|---|---|---|
| **①** | 공개 🔴 3건 — `t5-1-q14` · `t6-1-q15` · `t3-1-q5`(+ `t3-1-q1`) | **md 를 먼저 고친다**(루브릭 T6): `scs-t5-1.md` L235·L239·L390 · `scs-t6-1.md` L323·L324·L437·L456 · `scs-t3-1.md` L137·L321·L323. 새 출처는 G-84 때문에 **md 프런트매터 `sources` 와 본문 「출처」 절 양쪽**에 넣는다(둘을 묶는 동기 가드가 있다). 프런트매터 삽입은 **`lastVerified:` 바로 앞**(목록 끝) — 중간에 끼우면 파서가 뒤쪽 출처를 버린다. `t5-1-q14` 의 보기 교체는 **사람 승인** |
| **②** | 공개 🟡 중 「출처만」 9건 — Y3·Y4·Y5·Y6·Y7·Y8·Y10·Y12·Y13 | 사실·정답·보기 불변의 핫픽스. Y7 은 새 URL 이 md 출처에 없다(G-84 선작업). Y13 은 md 출처에 이미 있다 |
| **③** | 공개 🟡 중 문구 수정 4건 — Y1·Y2·Y9·Y11 | Y1 은 `scs_questions_test.dart` 가 문구를 묶는다(먼저 확인). Y9 는 **사람 판정**. Y11 은 `W0` 에서 상태 문장만 뺀다 |
| **④** | 드래프트 🟡 19건 — Y14~Y32 | Y14(지문 한 줄)·Y20·Y21·Y23·Y30(출처만)이 싸다. Y22·Y24 는 **정답 보기가 바뀌어** 길이 비율 재측정. Y32 는 **사람 판정**(D-04) |
| **⑤** | 🟢 — G3(가드 하한 전수화) → G4(겹침 4묶음) → G5·G6·G8·G9 → G1·G2·G7 | G4 ② 와 Y32 는 같은 Task(`t6-3`)라 함께 설계한다. G1·G2·G7 은 양이 많아 별 배치 |

- **가드 선행 확인**: `scs_questions_test.dart`·`scs_s6_review_fix_test.dart`·`scs_source_fix_test.dart` 가 문항 id 로 문구·출처를 리터럴 단정하는 자리가 있다(이 보고의 각 항목 「가드」 줄). 고치기 전에 `grep -n "<id>" flutter_app/test/scs_*.dart` 로 먼저 세고, **판정이 바뀐 가드는 먼저 뒤집는다**. 대조군이 `verified` 상태를 단정하지 않는지도 함께 본다(2026-11-13 flip 레드의 원인).
- 공개 문항을 고쳐도 **`verified` 는 건드리지 않는다**(본문만 바꾸는 핫픽스 — 치환 범위에서 `"verified"` 줄을 제외한다).

### 7-2. Task 별 flip 준비 판정

「준비됨」의 뜻: **이 보고의 🔴·🟡 가 0건**이다(🟢 는 flip 을 막지 않는다고 보았다 — 검수자가 다르게 보면 조정한다). md 본문 전수 사실 대조는 이 보고가 하지 않았으므로 **루브릭 T6(md 선결)는 검수자가 따로 본다**.

**공개 6 Task (이미 라이브 — 수선 대상)**

| Task | 🔴 | 🟡 | 판정 |
|---|---|---|---|
| `scs-t1-1` | 0 | 1 (Y6 `q9` 출처) | 출처 1건만 고치면 깨끗하다 |
| `scs-t2-1` | 0 | 3 (Y9 `q2` · Y10 `q15` · Y11 `q14`) | `q2` 는 사람 판정 |
| `scs-t3-1` | **1** (`q5`) | 4 (Y1 `q3` · Y2 `q1` · Y3 `q12` · Y4 `q15`) | **가장 손이 많이 간다** — md 3줄 선결 |
| `scs-t4-1` | 0 | 2 (Y7 `q7` · Y8 `q6`) | 출처만 |
| `scs-t5-1` | **1** (`q14`) | 1 (Y5 `q1`) | `q14` 보기 교체는 사람 승인 |
| `scs-t6-1` | **1** (`q15`) | 2 (Y12 `q7` · Y13 `q3`) | WA 판 판정(§6-5)이 선행 |

**드래프트 10 Task (flip 대기)**

| Task | 🟡 | flip 준비 | 남은 일 |
|---|---|---|---|
| `scs-t2-2` | 1 (Y19 `q1`) | **가장 가깝다** | 해설·`W1` 귀속 한 줄 |
| `scs-t5-3` | 1 (Y29 `q7` `W3`) | **가깝다** | `W3` 한 줄. `explanation-long` 7건은 🟢 |
| `scs-t4-2` | 1 (Y24 `q6`) | 가깝다 | 정답 보기 끝 절 수정 + 길이 재측정 |
| `scs-t1-3` | 3 (Y14 `q15` · Y15 `q3` · Y16 `q4`) | 수선 후 | `q15` 지문 한 줄(전제 모순) · 출처 1개 |
| `scs-t3-2` | 2 (Y20 `q12` · Y21 `q13`) | 수선 후 | 출처만(3개 추가) |
| `scs-t6-2` | 2 (Y30 `q6` · Y31 `q14`) | 수선 후 | 출처 2개 · 부연 1문장 삭제 |
| `scs-t1-2` | 2 (Y17 `q12` · Y18 `q13`) | 수선 후 | G-31 측정이 선행(세 서비스 소개 페이지) + 겹침 ③ |
| `scs-t3-3` | 2 (Y22 `q14` · Y23 `q15`) | 수선 후 | `q14` 정답 보기 수정 + 겹침 ①·④ |
| `scs-t5-2` | 4 (Y25 `q6` · Y26 `q14` · Y27 `q11` · Y28 `q9`) | 수선 후 | 출처 3개 · md L172·L261 정밀화 |
| `scs-t6-3` | 1 (Y32 `q9`) | **사람 판정 후** | D-04 판정 + 겹침 ②(6.3.3 의 3문항) |

- **이 보고 기준으로 지금 그대로 flip 해도 되는 드래프트 Task: 0개.** 가장 가까운 것은 `scs-t2-2`·`scs-t5-3` 이고 각각 한 줄 수선이다.
- 게이트 관점: SCS 통합 모의고사는 이미 열려 있다(공개 6 Task 90문항, 도메인당 하나). 추가 flip 은 게이트가 아니라 **문항 풀 확대**(특히 비중 20% 인 D4 의 `scs-t4-2`)가 목적이다 — D4 를 먼저 넓히려면 `scs-t4-2` 의 Y24 한 건을 먼저 닫는다.
