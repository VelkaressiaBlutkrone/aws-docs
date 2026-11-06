# MLA-C01 · AIF-C01 콘텐츠 전수 검토 — 2차 패스 (claude-fable-5-1) — 2026-11-06

1차 보고서: `docs/audits/2026-11-06-full-content-review/mla-c01-aif-c01.md` (수정하지 않았다).
이 문서는 1차 발견을 **반박하려 시도한 결과**와, 1차가 **놓친 것**, 1차의 **범위 과대·과소**를 적는다.
콘텐츠·테스트·노트 **무변경**, git 명령 **미사용**, `verified` 필드 **무접촉**.

**결론 한 줄:** 1차 14건 중 **확정 11 · 수정 3 · 기각 0**, **신규 4건**(라이브 AIF 학습문서 P1 2건 · MLA 출처 P2 1건 · MLA 귀속 P3 1건).
AIF flip 전 필수 수정은 **5묶음**(§5)으로 다시 세고, 1차가 못 본 라이브 오류 하나가 **2026-11-05 #352의 수정이 같은 파일에 두 자리 남긴 것**이다.

---

## 0. 2차 패스 계획

### 0-1. 1차와 다르게 한 것

| 축 | 1차 | 2차 |
|---|---|---|
| 목표 | 결함 찾기 | **1차를 틀리게 만들기** → 못 틀리면 확정 |
| 범위 세기 | 발견한 파일 안에서 | **발견 문구로 레포 전역(`clf·saa·soa·dea·mla·aif·dva`) 재검색**, 자격증 밖 건은 §3에 따로 |
| 수치 인용 | 표본 18건 | **AIF 문항 25건 전수 + MLA 문항 59건 중 표본 17건**을 인용 페이지에서 글자 그대로 찾음 |
| md 자기 모순 | 안 봄(1차 §7-1 한계) | **시험 직전 요약 · 자가 점검 ↔ 본문** 대조 (AIF 14편) |
| 관찰 2방법 | 문서 리더 1차 | 문서 리더 + `curl -sL` 본문 grep + (403·302는) 내장 브라우저 |

### 0-2. 측정 명령

- URL 상태: `curl -sL -o /dev/null -w "%{http_code} r=%{num_redirects} -> %{url_effective}"` (`-L` 필수).
  대조군 두 호스트 — `docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html` → `200 r=1`, `aws.amazon.com/what-is/zz-bogus-control/` → `404`.
- 본문 존재: `aws___read_documentation`(1차 방법) + `curl -sL | 태그 제거 | grep -i`(2차 방법). 두 방법이 모두 0건이고 동의어·표 구조까지 본 뒤에만 「없다」.
- 레포 전역: `grep -rn <문구> --include=*.md --include=*.questions.json flutter_app/assets/content/` — 보고된 개수는 믿지 않고 직접 셌다.

### 0-3. 판정 라벨

- **확정** — 반박 시도 실패, 1차 서술·범위·등급 그대로.
- **수정** — 결함은 맞지만 **범위·서술·등급** 중 하나가 바뀜(바뀐 것을 표에 적는다).
- **기각** — 결함이 아니었음.
- **신규** — 1차에 없던 것.

---

## 1. 1차 발견 재검증

### 1-1. MLA-C01 (라이브, 321 verified)

| ID | 1차 주장 | 반박 시도 | 판정 | 바뀐 것 |
|---|---|---|---|---|
| **P1-M1** | `mla-t1-2-q18` `wrongExplanations["3"]`(`mla-t1-2.questions.json:518`)이 Mechanical Turk를 **현재 선택지**로 제시 | `sms.html`·`sms-automated-labeling.html` 상단 배너 재확인 — Ground Truth 자체가 「신규 고객에게 열려 있지 않음」이고, MTurk 종료(2026-09-29)는 1차가 공식으로 실측. 레포 전역 `Mechanical Turk` 8건 = `mla-t1-2.md` 6(상태 있음) · `mla-t1-2.questions.json` 1(**이것**) · `mla-t4-1.md:151` 1(기능 묶음 공지 안, 상태 있음). 다른 자격증 0건 | **확정** | — (범위 그대로 1문항) |
| **P2-M1** | 사람이 열 수 없는 백서 4종이 라이브 문항 5개(`mla-t1-1-q2`·`t2-1-q11`·`t4-3-q12`·`q13`·`q25`) + md 3편의 출처 | 1차에서 문서 리더로 본문 실재 확인 완료(G-61 레시피). 2차는 범위만 재집계 — 같은 백서가 **`dea-t1-2.md`·`saa-t3-4.md`·`saa-t3-9.md`**에도 있다(§3) | **확정** | 자격증 밖 3편은 §3에 기록 |
| **P2-M2** | `repost.aws` 403 7건은 봇 차단 | 조치 불필요 항목. 재실측 생략 | **확정** | — |
| **P3-M1** | 중복 3쌍(`t1-3-q1↔t2-3-q18` 정답 J=1.00 · `t2-3-q13↔q25` · `t2-3-q14↔q15`) | `dup.out` 재독. 첫 쌍은 정답 문자열이 사실상 동일(「CI(Class Imbalance)」)하고 도메인을 가로지르므로 통합 모의고사에서 같이 뽑힐 수 있다. 셋째 쌍은 묻는 축이 다르다(정의 vs XGBoost 미지원 규칙) — 1차도 「겹침」으로 적었다 | **확정** | — |
| **P3-M2** | `mla-t4-1-q19·q20·q21`(편향 드리프트·특성 귀속 드리프트)에 `mmStatusNote`가 없다 | 반박 후보: 「Clarify 모니터는 Model Monitor가 아니라 Clarify 가용성 변경이므로 Model Monitor 문구가 틀릴 수 있다」. `clarify-availability-change.html`에 **「Replacing bias drift and feature attribution drift monitoring」 절이 있어** 이 세 모니터가 정확히 그 대상이다. 다만 달아야 할 문구는 Model Monitor 문구가 아니라 **Clarify 문구**(`mla-t4-1-q14` 등이 이미 쓰는 형태)여야 한다 | **확정** | 제안 문구를 Clarify 쪽으로 명시(1차도 그렇게 적었음을 확인) |
| **P3-M3** | 「미세 조정 / 미세조정 / 파인튜닝」 세 갈래 | 한국어 Bedrock 문서 「미세 조정」 재확인(1차). 전역 재집계: 「미세조정」 MLA md 32 · 문항 20, 「파인튜닝」 MLA md 8 · 문항 0 + **`dea-t1-2.questions.json` 1** | **확정** | DEA 1건은 §3 |
| **P3-M4** | 정답 위치 쏠림은 **재보고하지 않는다**(앱이 4경로 셔플) | 기록 항목 | **확정** | — |
| **P3-M5** | MLA·AIF에 사실 가드·전파 가드가 비어 있다 | 2차 신규 N1이 이 구조 결함의 **실증**이다 — `aif_facts_test.dart:178`의 금지 문자열 3개가 같은 오류의 다른 어순을 통과시켰다 | **확정** | 근거 추가(N1) |

### 1-2. AIF-C01 (드래프트 210, 학습문서 14편은 라이브)

| ID | 1차 주장 | 반박 시도 | 판정 | 바뀐 것 |
|---|---|---|---|---|
| **P1b-A1** ★ | `aif-t4-1-q3` `we["0"]`(`aif-t4-1.questions.json:84`)이 유해 콘텐츠 범주를 **「여섯 종류」로 단정** | 공식 재독 3면 — ① `guardrails-content-filters.html` 정의 절 = **5**(Hate·Insults·Sexual·Violence·Misconduct) ② `API_GuardrailContentFilterConfig` 산문 「four harmful categories」, `type` 유효값 **6**(`PROMPT_ATTACK` 포함) ③ 콘솔 문구 「You can select the filter for prompt attacks in the harmful categories」. **공식 자신이 4·5·6 세 갈래**라 「여섯」 단정은 틀리고 「다섯」 단정도 틀린다 — **개수를 단정하지 않는다**가 답 | **수정** | ① 범위 **+1**: `aif-t4-1.md:191`도 「사전 정의 범주 **6종 — Hate · Insults · Sexual · Violence · Misconduct · Prompt Attack**」로 단정(라이브 md). ② 1차의 「`aif-t5-1.md`가 다섯으로 적는다」는 **부정확** — `aif-t5-1.md:265`는 「정의가 다섯 + 개요가 프롬프트 공격을 더한다」로 **갈림을 기록**하고 있어 올바른 서술의 **모범**이다. ③ 주의: `aif-t4-1.md`의 「**정책** 여섯 종류」(:91·118·187·468·578)는 정책 6종(콘텐츠 필터·거부 주제·단어·민감 정보·문맥 근거·자동 추론)이라 **대상이 아니다** — 가드를 걸 때 「여섯 종류」만 세면 오탐 5건 |
| **P1b-A2** ★ | `aif-t2-2-q11`이 「계속 사전 훈련」을 주 용어로 | 공식 한국어 시험 가이드 「지속적인 사전 훈련」 2회 · 「계속」 0회(1차 실측). 영문 결정 가이드 원문 재독: "continued pre-training … unlabeled data in a secure and managed environment … accumulating more robust knowledge and adaptability beyond their original training" — **사실 서술은 정확**, 용어만 문제. 3개소(`aif-t2-2.questions.json:300` 보기 0, `:306` 해설 2회). 가드 `aif_facts_test.dart:190~199`는 **md만** 돈다 | **확정** | — |
| **P1b-A3** ★ | 중복·겹침 6쌍 | 6쌍 전부 다시 읽음(`pairs.out`). **중복(정답이 같은 문장) 3쌍**: `t2-2-q13↔t3-4-q13`(ROI 동적 KPI, 정답 J=0.74) · `t4-1-q4↔t5-1-q13`(London/Tokyo 같은 예시·같은 판정) · `t3-3-q14↔t4-1-q10`(RAIDP03-BP02, 교차 집단 불균형 검증 — 지문까지 거의 같다). **겹침(한쪽이 다른 쪽의 부분집합이거나 각도가 다름) 3쌍**: `t2-1-q7⊂t2-3-q13`(q13이 PT 규칙을 더해 상위집합) · `t3-1-q12⊂t3-3-q5`(q5가 15k를 더함) · `t2-2-q14↔t3-4-q15`(열거 vs 분류) | **수정** | 6쌍 → **교체 필수 3쌍 + 교체 선택 3쌍**. flip 전 필수 목록에는 3쌍만 올린다 |
| **P1b-A4** | `aif-t4-1-q11`(SMOTE)이 Foundational 대비 과도 | `data-wrangler-transform.html` Balance Data 절 재독 — 정답·해설·오답 근거의 **모든 문장이 글자 그대로 있다**(10%·8회·0.7A+0.3B·열 벡터 불가·수치 특징만 거리 계산). `difficulty: foundational`(`:321`)과의 부조화는 **판단 문제이지 사실 결함이 아니다** | **수정** | **등급 하향 P1b → P3**. flip을 막지 않는다. 고치려면 `difficulty`를 `applied`로 올리는 쪽이 문항 교체보다 싸다 |
| **P2-A1** | `aif-t1-2`가 은퇴한 Amazon ML 개발자 안내서를 「공식 문서」로 | 위치 재확인: `aif-t1-2.questions.json:31·91`, `aif-t1-2.md:12·375`. MLA는 같은 가이드에 「보조 출처(Amazon Machine Learning, 신규 사용자 중단된 구서비스 문서)」 라벨(`mla-t2-2.questions.json:458·494·774`, `mla-t2-3.questions.json:358`) | **확정** | — |
| **P3-A1** | 「개수를 묻지 않는다」 범위 명시 | P1b-A1의 공식 세 갈래가 근거 | **확정** | — |

**집계:** 확정 11 · 수정 3(P1b-A1 범위·서술, P1b-A3 범위, P1b-A4 등급) · 기각 0.

---

## 2. 신규 발견

### N1 ★★ (P1, 라이브 학습문서) `aif-t2-1.md`·`aif-t3-3.md`에 「사용자 지정 모델은 PT 필수」가 **5자리** 남아 있다 — G-19 → G-37 → G-46 → #352에 이은 **네 번째 누출**, 가드를 **어순으로 비켜 간다**

① 위치와 현재 문구(그대로):

- `aif/aif-t2-1.md:109` — 「⚠️ **사용자 지정한 모델은 프로비저닝된 처리량(PT)을 사야 쓸 수 있습니다.** …」 (시험 직전 요약)
- `aif/aif-t2-1.md:239` — 「… 그리고 결정적인 한 줄 — **"모델을 사용자 지정했다면, 그것을 쓰기 위해 프로비저닝된 처리량을 구매해야 합니다."** …」 (본문, 사실로 제시)
- `aif/aif-t2-1.md:327` — 「❌ **"미세 조정한 모델도 호출량이 적으면 온디맨드로 쓰면 된다"** → **"모델을 사용자 지정했다면 그것을 쓰기 위해 프로비저닝된 처리량을 구매해야 합니다."**」 (함정 — **맞는 말을 오답으로 분류**)
- `aif/aif-t2-1.md:356` — 자가 점검 Q2 정답 「**불가능합니다.** 공식 문서가 **"… 프로비저닝된 처리량(PT)을 구매해야 합니다"**라고 명시합니다.」
- `aif/aif-t3-3.md:346` — 「… 그리고 결과물은 사용자 지정 모델이므로 **프로비저닝된 처리량을 구매해야 쓸 수 있습니다.**」 (증류 절)

② 왜 틀렸는지: 공식 `model-customization-use.html`은 추론 설정을 **둘**로 적고(「Purchase Provisioned Throughput」 / 「Deploy custom model for on-demand inference」), `deploy-custom-model-on-demand.html` 첫 문단이 "With on-demand inference, you only pay for what you use and **you don't need to set up provisioned compute resources**"(조건: 버지니아 북부·오레곤, 2025-07-16 이후 사용자 지정, 지원 기반 모델). 문항 `aif-t3-1-q13`은 이미 이것을 정답으로 **출제**하고 있으므로, 같은 트랙의 학습문서가 「불가능합니다」로 가르치면 **학습자가 문서로 공부하고 문항에서 틀린다**.

③ **같은 파일 안에서 자기 모순**: `aif-t2-1.md:316`은 「사용자 지정 모델은 **프로비저닝 처리량 구매와 온디맨드 추론용 배포 둘 중 하나**」, `aif-t3-3.md:168`은 「공식이 적는 경로는 **둘**입니다 … 더 구체적인 쪽이 정본입니다」로 **옳게** 적는다. 즉 #352가 고친 자리와 안 고친 자리가 한 파일에 공존한다.

④ 왜 가드가 못 잡았나: `aif_facts_test.dart:178`의 금지 문자열은 `['PT 필수', '프로비저닝 처리량 없이 쓸 수 없', '프로비저닝 처리량을 구매해야 한다']`. 남은 다섯 자리는 「프로비저닝**된** 처리량을 구매해야 **합니다**」·「(PT)을 사야 쓸 수」·「구매해야 쓸 수」라 **한 글자(된)·종결(합니다)·조사(을/를)** 차이로 전부 비켜 간다. 레포 전역 재검색 결과 이 어순은 **AIF 2편에만** 있고 문항 JSON에는 0건(`aif-t2-3.questions.json:165`의 「먼저 구매해야만」은 **오답 보기**라 정당).

⑤ 제안:
- 다섯 자리를 `aif-t3-3.md:168`의 서술(두 경로 + PT 페이지가 아직 옛 문장을 적는다는 주석)로 맞춘다. `:327`은 함정 방향을 뒤집어 「❌ "사용자 지정 모델은 PT를 사야만 쓸 수 있다" → 온디맨드 배포 경로가 있다(조건 셋)」로.
- 가드 확장은 **정규식**으로: `프로비저닝(된)? 처리량(\(PT\))?[을를] (사야|구매해야)` — 단, **`aif-t3-1.md:248`·`aif-t3-3.md:168`은 이 문구를 「PT 페이지는 아직 … 적습니다」로 인용하며 정정하는 옳은 줄**이라 통째로 금지하면 거짓 실패한다. 그 두 줄처럼 「아직」·「더 구체적인」이 같은 줄에 있으면 허용하거나, 허용 줄을 명시 목록으로 둔다. **보존 가드와는 충돌하지 않는다**(보존 대상은 Glue DQ 표·Classic tier 기본값·CAF 상태 세 문장뿐).

### N2 ★ (P1, 라이브 학습문서) `aif-t5-2.md`가 **CloudTrail Lake를 현행 「기록 방식 3종」으로 가르치면서 상태 문구가 없다** — 2026-05-31부터 신규 고객에게 닫힘

① 위치: `aif/aif-t5-2.md:118` 「**CloudTrail의 기록 방식은 3종**입니다 — 이벤트 기록 · **CloudTrail Lake**(이벤트 데이터 스토어, **최대 3,653일**) · 추적(Trail)」, 같은 파일 `:136`(용어 표) · `:177`(공식 정의 인용) · `:412`(함정: 「더 길게는 추적(S3)이나 CloudTrail Lake가 필요합니다」) · `:441`(「추적(S3) 또는 CloudTrail Lake를 만듭니다」). 파일 전체에 「신규 고객」·「2026-05」·「유지 관리」가 Lake 근처에 **0건**.

② 왜 문제인지: 같은 레포가 이미 상태를 안다 — `mla/mla-t4-3.md:477` 「⚠️ **CloudTrail Lake** — **2026-05-31부터 신규 고객에게 닫혔습니다.** … 시험 지문의 Lake 언급은 이 상태를 감안해 해석합니다」, `mla-t4-2-q18`·`dea-t4-4`도 같은 문구를 단다. AIF만 빠졌다. 닫힌 서비스 축(D)은 이 트랙이 D-07로 **네 번째 닫힌 서비스**까지 관리해 온 축이라 누락이 두드러진다.

③ 공식 근거: CloudTrail 사용자 안내서 Lake 절 배너(1차·#352에서 실측, 「CloudTrail Lake is no longer open to new customers … starting May 31, 2026」; 추적·Insights·집계 이벤트는 영향 없음, 유사 기능은 CloudWatch 안내).

④ 레포 전역 재집계(`CloudTrail Lake` 49건·9파일): 상태 문구 **있음** — `dea-t4-4.md`·`.questions.json`, `mla-t4-2.md`·`.questions.json`, `mla-t4-3.md`, `saa-t3-9.md`. **없음** — **`aif-t5-2.md`(5)**, `soa-t1-3.md`(4)·`soa-t1-3.questions.json`(4)·`soa-t4-2.questions.json`(2). SOA 10건은 범위 밖이라 §3에.

⑤ 제안: `:118` 바로 아래에 `mla-t4-3.md:477` 문구를 그대로 옮기고, `:412`·`:441`의 「또는 CloudTrail Lake」를 「(기존 고객이면) CloudTrail Lake」로. `aif-t5-2.questions.json`에는 Lake가 0건이라 문항 수정은 없다.

### N3 (P2, 라이브) `mla-t2-2-q3`의 **인용 페이지에 그 사실이 없다** — 사실은 맞고 정본은 `data-parallel-config.html`

① `mla/mla-t2-2.questions.json:65~`(q3) 해설: 「문서는 노드를 늘리면 배치 크기를 비례해서 늘리고 수렴 속도를 위해 학습률도 함께 올리라고 적습니다. … 선형 스케일링 규칙」. 출처(`:86~87`) = `distributed-training-strategies.html` (제목까지 「배치 크기와 학습률 스케일링」).

② 실측: 그 페이지 본문 grep — `learning` 3건 전부 「Deep Learning」(NVIDIA 문서 제목), `proportion` 0건. 학습률 스케일링은 **없다**. 정본은 `sagemaker/latest/dg/data-parallel-config.html` Batch size 절 — "as more nodes are added, batch sizes should increase proportionally. To improve convergence speed as you add more nodes … increase the learning rate … **Linear Scaling Rule** where each time the mini-batch size is multiplied by k, the learning rate is also multiplied by k" (문항 해설과 글자 단위로 대응).

③ `mla-t2-2.md:510`은 이미 이 페이지를 참고자료 4로 들고 있으므로 **문항 출처만** 바꾸면 된다. `correct`·`verified` 불변. 1차 §6-4 「공식 재대조 18건 전부 일치」는 **사실** 대조였고 **인용 페이지 귀속**은 보지 않았다 — 이 항목은 그 한계(1차 §7)를 메운 결과다.

### N4 (P3, 귀속 층) `mla-t4-3-q8` 해설·`mla-t4-3.md:197`의 「대표 기간 30~90일」은 공식 권고가 아니다

① `mla-t4-3.questions.json:217~`(q8) 해설: 「권장 흐름은 넓은 정책으로 **대표 기간 30일에서 90일** 운영한 뒤 생성된 정책으로 교체」. `mla-t4-3.md:197`: 「**적용 흐름** — 넓은 정책으로 **대표 기간 30~90일** 워크로드를 돌린 뒤 …」.

② `access-analyzer-policy-generation.html` 본문: 「up to 90 days」·「replace a broad permissions policy … with the generated policy」는 있고, **「30 days」·「representative」 0건**. 오히려 "**We recommend that you choose the shortest time period possible** to reduce the policy generation time". 즉 「넓은 정책 → 생성 정책 교체」는 공식이고 「30~90일」은 저자의 운용 권고다. 문항은 「권장 흐름은」으로 주체를 흐려 공식처럼 읽힌다.

③ 제안: 「상한은 90일이고 공식은 가능한 한 짧은 기간을 권한다. 실무에서는 워크로드 주기를 덮는 기간(예: 30일)을 고른다」로 층을 가른다. `correct` 불변.

### N5 (기록 — 대조군) 수치 인용 **34/34 일치**

- AIF 문항 수치 25건(`num.out`) 중 뜻이 있는 17문항을 인용 페이지에서 글자 그대로 찾았다: 1GB·1시간(비동기 추론) · 1%(BalancedAccuracy 스팸 예) · 4,096·5분(프롬프트 캐싱) · 무약정/1개월/6개월·1분(PT) · 2~3초(AGENTPERF05-BP02) · 약 10%(교차 리전 표) · horses 0.7/Top P 0.7(추론 파라미터) · 2025-07-16·두 리전(온디맨드 배포) · 1,000 프롬프트·`referenceResponse` 필수(평가 데이터세트) · 약 5회 섭동·낮을수록 강건(평가 보고서) · 10%·8회·0.7A+0.3B(SMOTE) · 46%/32%·버클리(CDD) · 85%/90%(RAISP01-BP02)·행렬·릴리스 문서(RAIRC04-BP02) · 100 KB·같은 계정·리전·`identity.arn` 자동(호출 로깅) · 범주 6·Basic 범위·주 1회(Trusted Advisor) · 24시간(Config 주기) · 「경계 바깥」(AgentCore Policy).
- MLA 문항 표본 17건: 128 KB·30일(S3 IT) · 0.2~3 MB·6 MB·5분(Firehose) · 1,250·5,000·스트리밍 불가(자동 레이블링) · 100 MB(AutoML AUTO) · 1024~6144 MB(서버리스) · 콜드 스타트(MME) · 10 GB·900초(Lambda) · 64%(Savings Plans) · NLB→ECSAllAtOnce · 0~20분·NOW(ScheduleConfig) · -P8D/-P1D 예시 · 99.95%·복사본 2 초과 · 100 동시·60분·7일·3언어(Logs Insights) · 90일·InvokeEndpoint 데이터 이벤트 · 최대 90일(Access Analyzer). 사실 불일치 0, 출처 귀속 불일치 1(N3), 귀속 층 1(N4).
- `aif-t3-1.md:92·165`의 온도 예시 0.2~0.3 / 0.8~0.9는 `API_agent-runtime_TextInferenceConfig`에 글자 그대로 있다(1차 §7 미확인 항목 종결).

---

## 3. 1차가 과대·과소였던 것 (범위 재집계)

| 항목 | 1차 범위 | 2차 전역 재집계 | 판정 |
|---|---|---|---|
| P1b-A1 유해 범주 「6종」 | 문항 1곳 | **문항 1 + `aif-t4-1.md:191` 1** = 2곳. 자격증 밖: **`dva/dva-t2-3.md:78·142`** 2곳도 6종 단정(미등재 자격증, 12월 전환 전 정정 대상) | **과소** |
| P1b-A3 중복 6쌍 | 6쌍 동급 | 중복 3 + 겹침 3 | **과대** |
| P1b-A4 SMOTE | P1b | P3 | **과대** |
| P1-M1 MTurk | 문항 1 | 전역 8건 중 상태 없는 자리는 그 1건뿐 — 범위 정확 | 정확 |
| P2-M1 백서 4종 | MLA 문항 5 + md 3 | 자격증 밖 **`dea-t1-2.md`·`saa-t3-4.md`**(cost-modeling-data-lakes) · **`saa-t3-9.md`**(data-cataloging) 3편 추가. 전부 라이브 | **과소**(자격증 밖) |
| P3-M3 표기 갈래 | MLA 안 | 「파인튜닝」 **`dea-t1-2.questions.json` 1건** | **과소**(자격증 밖) |
| 닫힌 서비스 축(1차 §6-3 「MLA 처리는 모범적」) | AIF는 Bedrock Agents Classic·Clarify·Audit Manager·A2I만 봄 | **CloudTrail Lake가 빠졌다**(N2). 자격증 밖 `soa-t1-3.md`·`soa-t1-3.questions.json`·`soa-t4-2.questions.json` 10건도 상태 없음 | **과소** |
| PT 필수(1차 §6-5 「선행 노트가 못박은 것 — 재보고 안 함」) | #352가 닫았다고 보고 **재검색하지 않음** | 같은 파일에 **5자리 잔존**(N1) | **과소 — 1차의 가장 큰 누락** |
| 1차 §6-4 「공식 재대조 18건 전부 일치」 | 사실 대조 | 인용 페이지 귀속까지 보면 **1건 불일치**(N3) | 과대(표현) |

**교훈(이 레포용):** 「선행 PR이 닫았다」는 항목일수록 **그 문구의 변형으로 전역을 다시 센다**. #352의 저작 에이전트 보고가 「네 자리」였고 컨트롤러가 다섯을 셌는데(CLAUDE.md 기록), 그 뒤에도 **다른 어순 다섯**이 남아 있었다 — 보고 개수뿐 아니라 **가드 문자열의 어순**도 믿지 않는다.

---

## 4. 측정 한계

1. **MLA 문항 수치는 표본(17/59)이다.** 나머지 42문항은 1차의 사실 대조·전수 읽기에 기대고 있고, 인용 페이지 귀속은 보지 않았다. N3가 17건 중 1건이었으므로 **42건에 같은 종류가 1~3건 더 있을 수 있다**.
2. **AIF 학습문서 요약·자가 점검 대조는 14편 요약 전수 + 자가 점검은 N1·N2가 나온 2편만 본문과 교차**했다. 나머지 12편의 자가 점검 정답은 요약과만 대조했다.
3. **CloudTrail Lake 배너는 2차에서 다시 열지 않았다** — 1차와 #352(MLA·DEA 문구)가 실측한 날짜를 그대로 썼다. 배너 문구가 바뀌었다면 N2의 날짜만 영향 받고 「상태 문구 부재」 판정은 그대로다.
4. **중복 판정은 사람 판단이다.** 「정답 문장이 같다」를 중복, 「부분집합·각도 차이」를 겹침으로 갈랐고, 임계값은 두지 않았다.
5. **가드 확장 제안(N1 ⑤)은 테스트를 돌리지 않았다**(지시로 금지). 정규식이 `aif-t3-1.md:248`·`aif-t3-3.md:168`을 잡는다는 것은 문구를 눈으로 대조한 결과이고, 실제 가드는 구현하는 PR에서 **대조군(그 두 줄이 통과하는지)**을 먼저 단정해야 한다.
6. 자격증 밖 건(§3의 dva·dea·saa·soa)은 **세기만 했고 판정·수정안은 쓰지 않았다** — 범위 규율.

---

## 5. ⭐ AIF flip 전 반드시 고쳐야 하는 최종 목록 (파일:행)

전부 라이브 학습문서이거나 flip 즉시 라이브가 되는 문항이다. `verified`·`correct` 불변.

| # | 파일:행 | 무엇 | 출처 |
|---|---|---|---|
| 1 | `aif/aif-t2-1.md:109` · `:239` · `:327` · `:356`, `aif/aif-t3-3.md:346` | 「PT 필수」 5자리 → 두 경로(PT 구매 / 온디맨드 배포, 조건 셋) | N1 |
| 2 | `aif/aif-t5-2.md:118`(+`:136`·`:177`·`:412`·`:441`) | CloudTrail Lake 상태 한 줄(2026-05-31 신규 고객 닫힘) | N2 |
| 3 | `aif/aif-t4-1.questions.json:84`(q3 `we["0"]`) · `aif/aif-t4-1.md:191` | 유해 범주 「여섯 종류/6종」 단정 제거 — 개수를 단정하지 않는다 | P1b-A1(수정) |
| 4 | `aif/aif-t2-2.questions.json:300` · `:306`(q11, 3개소) | 「계속 사전 훈련」 → 「지속적인 사전 훈련」 | P1b-A2 |
| 5 | 중복 3쌍 중 한쪽 교체: `aif-t2-2.questions.json:353`(q13) ↔ `aif-t3-4.questions.json:349`(q13) · `aif-t4-1.questions.json:101`(q4) ↔ `aif-t5-1.questions.json:373`(q13) · `aif-t3-3.questions.json:405`(q14) ↔ `aif-t4-1.questions.json:289`(q10) | 같은 정답·같은 시나리오 | P1b-A3(수정) |

**권장(flip을 막지는 않음):** `aif/aif-t1-2.questions.json:31·91`, `aif/aif-t1-2.md:12·375` 레거시 라벨(P2-A1) · 겹침 3쌍(P1b-A3) · `aif-t4-1-q11` `difficulty`(P1b-A4→P3) · 가드 확장(N1 ⑤, `aif_facts_test.dart:178` 정규식 + 허용 줄 2곳 + 「정책 여섯 종류」 오탐 5곳 제외).

**교체 시 주의(1차 인계 노트와 동일):** `skill` 값 유지(`aif_questions_test.dart` 목표 전수 커버리지 가드) · 「계속 사전 훈련」 가드를 JSON까지 넓히면 `expect(hits, ['aif-t3-3.md'])`를 두 단정으로 가른다 · 보존 가드 세 문장(`aif_facts_test.dart:391~`·`:418`·`:476`)은 이 목록의 어느 수정에도 걸리지 않는다.
