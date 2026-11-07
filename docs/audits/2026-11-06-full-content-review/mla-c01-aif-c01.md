# MLA-C01 · AIF-C01 콘텐츠 전수 검토 — 2026-11-06

> **대상**: `develop` @ `4582e1f` · `flutter_app/assets/content/mla/`(학습문서 12편 + 문항 321개, **전부 라이브**) · `flutter_app/assets/content/aif/`(학습문서 14편 + 문항 210개, **전부 드래프트**)
> **범위**: MLA-C01과 AIF-C01만. 다른 자격증 파일은 비교 목적으로만 읽었고 보고하지 않는다.
> **산출물**: 이 파일 하나. 콘텐츠·테스트·문서를 **한 바이트도 수정하지 않았고** git 명령도 쓰지 않았다.

---

## 0. 검토 계획

### 0-1. 전제

| 트랙 | 학습문서 | 문항 | 노출 상태 |
|---|---|---|---|
| MLA-C01 | 12편 (769KB) | 321개 | **321/321 `verified:true` — 학습자가 지금 풀고 있다** |
| AIF-C01 | 14편 (824KB) | 210개 | **0/210 — 드래프트. 사람의 flip 전이 마지막 수정 기회다** |

`verified` 필드와 flip은 사람 전용이므로 이 검토는 **읽기 전용**이다.

### 0-2. 왜 이 순서인가

1. **기계 가드가 이미 못박은 것을 먼저 읽는다** — 중복 보고를 피하기 위해서다. `aif_facts_test.dart`의 「보존 가드」는 **방향이 반대**(문장의 *존재*를 단정)라 거기 걸린 문장을 「틀렸다」고 적으려면 매우 강한 근거가 필요하고, `docs/audits/2026-10-26-mla-content-review.md`에는 **3회 반복·3회 기각**된 항목(정답 위치)이 있다.
2. **기계로 셀 수 있는 것을 먼저 센다** — 분포·표기·금지 문구·URL·중복은 전수 측정이 가능하다. 측정값이 있으면 뒤의 판단이 추측이 아니게 되고, 범위를 줄여야 할 때 무엇을 못 봤는지도 정확히 적을 수 있다.
3. **그다음 사람이 읽어야만 보이는 것을 읽는다** — 정답이 둘인지, 참인 보기를 오답으로 뒀는지, 귀속 층이 갈렸는지, 문서 사이가 어긋났는지. **문항 531개를 한 건도 건너뛰지 않고 전문으로 읽었다.**

### 0-3. 측정 명령과 그 근거

| 축 | 명령·방법 | 왜 이 방법인가 |
|---|---|---|
| 분포·구조 | `scan1.py` — 문항 전수 파싱 후 `correct` 분포·난이도·`verified` 집계 | 「정답 쏠림」은 눈으로 못 센다 |
| 금지 문구 | `scan2.py` — M2 작성 과정 메모 16패턴 × **전 필드**(지문·보기·해설·오답 근거·`skill`·`sources[].title`) | MLA에는 M2 가드가 있지만 **AIF에는 없다.** 출처 *제목*에 숨은 사례가 과거에 있었다(SAA t4-5) |
| 위치 가정 | `scan3.py` — `(첫\|두\|세\|네\|마지막) (보기\|선택지)` · `보기 [ABCD]` · `선택지 [1-4]` · `[ABCD]) ` · `위의?\s*보기` | 3회 기각된 「정답 위치」 지적에서 **유일하게 값이 있는 하위 항목**이다(2026-10-26 ③-1) |
| 중복 | `scan3.py`(문자열 동일) + **`dupscan.py`(의미 중복)** — 같은 출처 URL을 공유하는 문항쌍의 `options[correct]`·`stem` 토큰 자카드 유사도 | **문자열 비교만으로는 중복을 못 찾는다.** 실제로 `scan3.py`는 0건을 돌려줬고, 같은 시나리오를 따옴표 표기만 바꿔 쓴 쌍을 `dupscan.py`가 잡았다(§3-3) |
| 표기 | `scan4.py` — 문항 전 필드의 `**` · 백틱 · `[텍스트](링크)` · 단일 `*이탤릭*` | 해설은 `Text()` 평문 렌더다(`quiz_widgets.dart:245·251`). MLA에만 가드가 있다 |
| 과도한 일반화 | `mdscan.py` — md 전수에서 유일성·항상·예외 없이·전칭긍정·절대 8패턴 | 「유일한 경로」류는 공식이 둘을 적는 자리에서 거짓이 된다 |
| 용어 | `grep` 전수 — 기초 모델/환각/프롬프트 주입/파인튜닝/음차 vs 공식 표기 | **MLA와 AIF를 한 세션이 맡는 이유**가 여기에 있다 |
| 출처 URL | `urls.py`로 **문항 + md 전수**의 고유 URL 842개 추출 → `curl -sL -w "%{http_code} r=%{num_redirects} -> %{url_effective}"` | `-L` 없으면 `num_redirects`가 항상 0이다. **md 출처를 문항 출처와 함께 센다** — 문항 가드는 `.md`를 보지 않는다 |
| 출처 내용 | 리다이렉트·403이 나온 URL은 **`aws___read_documentation`을 두 번째 방법으로** 다시 읽고, 403은 **내장 브라우저로 직접** 열었다 | G-61: 「문서가 사라졌다」와 「사람이 브라우저로 열 수 없다」는 **다른 판정**이고, 전자로 결론 내리면 참인 인용을 지우게 된다 |

**대조군(호스트별 1개씩).** 측정 회차마다 입력에 함께 넣었다.

| 대조군 | 기대 신호 | 실측 |
|---|---|---|
| `docs.aws.amazon.com/sagemaker/latest/dg/zz-bogus-control.html` | `200 r=1` | `200 r=1` ✅ |
| `aws.amazon.com/what-is/zz-bogus-control/` | `404 r=0` | `404 r=0` ✅ |
| `docs.aws.amazon.com/zz-no-such-guide/latest/dg/x.html` | 진짜 `404 r=0` | `404 r=0` ✅ |
| 살아 있는 `.../dg/whatis.html` | `200 r=0` | `200 r=0` ✅ |

### 0-4. 「공식에 없다」를 적기 전 5단계

이 레포에서 「없다」 보고가 다섯 번 거짓이었고 **그 다섯 중 넷이 이 두 트랙**에서 나왔다. 다음을 다 하지 않은 「없다」는 §2~§5에 적지 않고 **§7로 보냈다.**

1. 추출 방법 둘(본문 + AWS 문서 리더)
2. 대조군 문구 — **0이면 측정 무효**
3. 동의어·다른 표현(`less than`↔`fewer than` · `versioning`↔`version control` · `If you don't`↔`If you do not`)
4. **표·목록 구조** — 비교 표의 열에 `Supported / Not supported`로 있으면 산문 검색은 영원히 0건이다
5. **md가 영문을 직접 인용하면 그 인용문 자체로 먼저 검색**

### 0-5. 보고 규율

각 항목은 ①`파일:행`(또는 문항 `id`) ②현재 문구 그대로 인용 ③왜 틀렸는지 ④공식 URL + 실측 근거 ⑤제안 수정안을 담는다. 제안이 기존 가드와 충돌하면 어느 테스트의 어느 단정인지 적는다. 개수 판단은 `grep` 전수로 확인한다. 공식 내부가 갈리면 **단정하지 않는다**를 제안하고 양쪽 URL을 함께 적는다.

### 0-6. 계획 변경 (실행하며 달라진 점)

- **중복 탐지 방법을 바꿨다.** 애초 계획은 지문·정답 보기의 정규화 문자열 비교였는데 **0건**이 나왔다. 같은 시나리오를 따옴표 표기만 바꿔 쓴 쌍(`aif-t4-1-q4` ↔ `aif-t5-1-q13`)을 사람이 읽다 발견해, **같은 출처 URL을 공유하는 쌍의 토큰 자카드 유사도**로 재측정하는 `dupscan.py`를 추가했다. 이 방법이 두 트랙에서 **7쌍**을 잡았다(§3-3·§5-1).
- **md는 전문 독해 대신 축별 전수 스캔으로 갈랐다.** 범위 축소이고 §7에 적는다.

---

## 1. 집계

### 1-1. 검토량

| 항목 | 수 |
|---|---|
| 전문 독해한 문항 | **531개** (MLA 321 + AIF 210) — 전수 |
| 축별 전수 스캔한 학습문서 | **26편** (MLA 12 + AIF 14) |
| 실측한 고유 출처 URL | **842개** (문항 + md 합산, 호스트 4종) |
| 공식 페이지 재대조 | **18개** (AWS 문서 리더 또는 검색으로 전문 확인) |
| 읽은 선행 노트·가드 | AIF `99-gaps.md`(G-01~G-66)·`98-authoring-decisions.md`(D-01~D-13)·`aif_facts_test.dart`·`aif_questions_test.dart` · MLA `2026-10-26-mla-content-review.md`·`mla_questions_test.dart`·`mla_doc_format_test.dart` |

### 1-2. 발견 건수

| 절 | MLA | AIF | 합 |
|---|---|---|---|
| §2 P1 — 라이브 사실 오류 | **1** | 0 | **1** |
| §3 P1b — AIF 드래프트 문항 결함 | — | **8** | **8** |
| §4 P2 — 출처 결함 | **2 묶음**(URL 4종 · 문항 5 · md 3편) | **1 묶음**(문항 2 · md 1편) | **3 묶음** |
| §5 P3 — 보강 후보 | **5** | **1** | **6** |

**flip 전에 반드시 고쳐야 하는 AIF 항목: 6건** (§3-1 · §3-2 · §3-3 네 쌍 중 상위 네 쌍). 상세는 §3 머리말.

### 1-3. 전수 측정값 (대조군 포함)

| 측정 | MLA | AIF |
|---|---|---|
| 문항 수 | 321 | 210 |
| `verified:true` | 321 | 0 |
| `correct` 분포 | 0:224(69.8%) 1:78 2:14 3:5 | 0:55 1:56 2:57 3:42 (거의 균등) |
| 난이도 | applied 226 · foundational 95 | applied 137 · foundational 73 |
| 해설·보기의 마크다운 표기(`**`·백틱·링크·이탤릭) | **0건** | **0건** |
| md의 `[텍스트](링크)` | **0건** | **0건** |
| md의 단일 `*이탤릭*` | **0건**(코드 스팬 별표 11건은 오탐) | **0건** |
| M2 작성 과정 메모(실제 결함) | **0건** | **0건** |
| 해설이 보기 위치를 가정 | **0건** | **0건** |
| 문항 내 보기 중복 · 지문 문자열 중복 | **0건** | **0건** |
| md 과도한 일반화(실제 결함) | **0건** | **0건** |
| 출처 URL `200 r=0` | 561/568 | 274/274 |
| 출처 URL 비정상 | 리다이렉트 6 · 403 7(봇 차단) | 리다이렉트 2(기록됨) |

---

## 2. P1 — 라이브 사실 오류

### MLA-C01

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR)** — 이 항목의 범위가 **문항 1건이 아니다.** 반영 때 문맥 규칙(「Mechanical Turk 를 적는 자리는 상태를 함께 적는다」)으로 MLA 전수를 세니 **학습문서 3곳에도 상태 표기가 없었다**: `mla-t1-2.md:94`(도구 네 갈래 목록의 「레이블링(Ground Truth·Mechanical Turk·A2I)」) · `:222`(「작업 인력 3종: Mechanical Turk · 비공개 · 공급업체」) · `:226`(「MTurk 인력에는 …」). 1차·2차가 본 것은 **상태 표가 있는 자리**(`:73`·`:101`·`:218`)이고, **같은 파일에서 상태 없이 이름만 부르는 자리는 세지 않았다.** 그 셋도 함께 고쳤고, 전수 문맥 규칙을 `dea_mla_p1_review_fix_test.dart` 에 걸어 재유입을 막았다(이 파일이 **MLA 의 첫 사실 가드**다 — §5-5 가 지적한 구조적 공백을 그만큼 메웠다).

#### P1-M1. `mla-t1-2-q18`이 **지원 종료된 Amazon Mechanical Turk**를 현재 선택지로 제시한다

① **`mla/mla-t1-2.questions.json:518`** (`mla-t1-2-q18`, `wrongExplanations["3"]`) — `verified:true`, 라이브

② 현재 문구 그대로:
> "작업 인력은 Mechanical Turk·비공개·공급업체 중에서 고르며, 어느 쪽을 쓰든 자동 레이블링 사용 여부와는 무관합니다."

③ 왜 틀렸는지 — **Amazon Mechanical Turk는 2026-09-29에 지원이 종료돼 더 이상 제공되지 않는다.** 그런데 같은 Task의 **학습문서는 이것을 이미 정확히 적고 있다**:

```
mla/mla-t1-2.md:73   ⚠️ 레이블링·사람 검토 서비스는 상태를 함께 본다 — Ground Truth·A2I 신규 고객 불가,
                      Ground Truth Plus 지원 종료, Mechanical Turk 폐쇄
mla/mla-t1-2.md:101  | Ground Truth · A2I · Mechanical Turk | ⚠️ 신규 고객 불가 / 유지 모드 / 폐쇄 — 자세한 것은 9) |
mla/mla-t1-2.md:218  | Mechanical Turk | ⚠️ 폐쇄(SageMaker 문서 2026-09-30, What's New 2026-09-29 — 하루 차이) |
```

즉 **사실 오류라기보다 학습문서 정정이 파생 문항으로 전파되지 않은 것**이고, 이 레포가 이름 붙인 바로 그 실패 유형이다. 오답 근거도 「사실 영역」이라는 레포 규율(2026-10-29 SOA·DEA 전파 가드의 `_nameRules`)에 따라 결함으로 센다. 학습자는 문항만 보는 화면(오답노트·모의고사)에서 md의 상태 표를 보지 못한다.

④ 공식 URL + 실측 근거
- `https://aws.amazon.com/about-aws/whats-new/2026/09/aws-service-availability/` — "Two services, **Amazon Mechanical Turk** and AWS Infrastructure Composer (standalone console), **have already reached end-of-support and are no longer available as of September 29, 2026**."
- `https://docs.aws.amazon.com/sagemaker/latest/dg/sms-security-workforce-authentication.html` — Ground Truth 자체도 "no longer open to new customers"(별 사안)
- `grep -rn "Mechanical Turk" mla/` 전수 = **7개소**(md 5 · 문항 1 · t4-1.md 묶음 공지 1). 문항 쪽은 **이 1건뿐**이다

⑤ 제안 수정안 — 세 선택지 중 하나. ①이 가장 작다.
1. 상태를 한 줄로 붙인다(Model Monitor·Ground Truth·A2I 문항과 **같은 서식**):
   > "작업 인력은 비공개(자체 직원)·공급업체 중에서 고르며, 어느 쪽을 쓰든 자동 레이블링 사용 여부와는 무관합니다. ⚠️ Mechanical Turk는 2026-09-29 지원이 종료됐습니다."
2. Mechanical Turk를 목록에서 빼고 「비공개·공급업체」 2종으로만 적는다.
3. 보기 자체를 다른 거짓 서술로 교체한다(정답 인덱스 0은 불변).

⚠️ **가드 충돌 없음.** `mla_questions_test.dart`의 상태 한 줄 가드(`mmStatusNote`·`mmTaughtIds`)는 Model Monitor 전용이고 이 문항은 목록에 없다. 다만 ①을 고르면 **서식을 그 상수와 맞추는 것이 일관적**이다.

⚠️ **구조적 원인**: `flutter_app/test/`에 **`mla_facts_test.dart`도, MLA 전파 가드도 없다**(SAA는 `saa_question_propagation_test.dart`, SOA·DEA는 `soa_dea_question_propagation_test.dart`를 가진다). → §5-5.

### AIF-C01 (학습문서)

**P1 해당 없음.** AIF 학습문서 14편에서 공식 문서와 어긋나는 사실 서술을 찾지 못했다. 다만 **문항 쪽이 md와 어긋난 자리가 한 곳** 있고 그것은 드래프트이므로 §3-1로 보냈다.

---

## 3. P1b — AIF 드래프트 문항 결함 (공개 전 수정 대상)

> **flip 전에 반드시 고쳐야 하는 것: 6건** — §3-1(사실 단정), §3-2(공식 표기), 그리고 §3-3의 상위 네 쌍 중 **중복도가 가장 높은 네 쌍**(`t4-1-q4↔t5-1-q13` · `t2-2-q13↔t3-4-q13` · `t2-2-q14↔t3-4-q15` · `t3-3-q14↔t4-1-q10`). 나머지 두 쌍(§3-3의 ⑤⑥)은 포함 관계라 경고 수준이다.
> **라이브 영향은 0이다**(210개 전부 `verified:false`). 그래서 지금이 가장 싸다.

### P1b-A1. `aif-t4-1-q3`이 Guardrails 유해 콘텐츠 범주를 **「여섯 종류」로 단정**한다 — 공식 정의 절은 다섯이고, 같은 트랙의 `aif-t5-1.md`는 다섯으로 적는다 ★

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-o).** 사실 판정은 확정이고
> 범위가 **문항 1곳 → 문항 1 + md 3곳**으로 늘었다 — 같은 열거가 `aif-t2-3.md:205`(「범주는
> … Misconduct · **Prompt Attack**」) · `aif-t4-1.md:191`(「사전 정의 범주 **6종** — … Prompt
> Attack」) · `aif-t3-2.md:195`(안전장치 설명 안의 범주 열거)에 있었다. 전수 문맥 가드가
> 잡았다.
> ⚠️⚠️ **`aif-t5-1.md:265` 는 걸지 않는다 — 그 줄이 이 절이 말한 「옳은 자리」다.** 「정의
> 절은 다섯이고 **가드레일 개요가 거기에 더해** …」로 **두 공식 서술을 가르친다.** 「Misconduct
> + Prompt Attack 동시 등장」만 보는 탐지기는 그 줄을 걸어 **참인 서술을 지우게** 하므로,
> 예외를 **「갈림을 설명한다」는 성질**(`더해`·`별도`·`개수는 외우지 않`)로 두고 그 성질 자체를
> 대조군으로 고정했다.
> ⚠️ **바로 옆의 참인 주장을 건드리지 않았다** — `aif-t4-1.md` 의 **「Guardrails 정책은 여섯
> 종류」**(콘텐츠 필터·거부 주제·단어 필터·민감 정보 필터·문맥 근거 확인·자동 추론 검사)는
> **다른 주장이고 공식과 맞다.** 결함은 **유해 콘텐츠 「범주」** 개수뿐이고, 둘을 섞으면 참인
> 서술이 사라진다. 그 서술이 남아 있는지도 대조군으로 고정했다.

① **`aif/aif-t4-1.questions.json:84`** (`aif-t4-1-q3`, `wrongExplanations["0"]`)

② 현재 문구 그대로:
> "콘텐츠 필터는 사전 정의된 유해 콘텐츠 범주 **여섯 종류(Hate · Insults · Sexual · Violence · Misconduct · Prompt Attack)**를 탐지해 범주별 강도로 막는 이진 게이트입니다."

③ 왜 틀렸는지 — 공식 콘텐츠 필터 페이지의 **범주 정의 절은 다섯 개만 열거하고 Prompt Attack은 거기에 없다.** 같은 페이지의 **콘솔 절**은 "You can select the filter for prompt attacks **in the harmful categories**"라고 적어, 콘솔 UI에서는 프롬프트 공격이 유해 범주와 같은 묶음에 놓인다. **공식 내부가 갈리는 자리**이고, 이 레포의 규율(측정 규율 5-5)은 그런 자리에서 **개수를 단정하지 않는 것**이다.

그리고 **같은 AIF 트랙의 다른 문서가 다섯으로 적는다** — 내부 모순이다:
```
aif/aif-t5-1.md:265  **독성(toxicity)**은 유해 콘텐츠 필터 쪽입니다. 공식 범주 정의가
                      **혐오(Hate) · 욕설(Insults) · 성적(Sexual) · 폭력(Violence) · 위법 행위(Misconduct)**로
                      적혀 있고 …
```
`aif-t5-1.md`가 **옳다.** 결함은 문항 쪽 하나다.

④ 공식 URL + 실측 근거 — `https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-content-filters.html` (AWS 문서 리더 전문, `200 r=0`)
- 정의 절 원문: "Content filters are supported across the following categories:" 뒤에 **Hate · Insults · Sexual · Violence · Misconduct 다섯 개**가 각각 소제목으로 붙는다. **Prompt Attack 소제목은 없다.**
- 콘솔 절 원문: "Select **None, Low, Medium, or High** for the level of filtration you want to apply to each category. **You can select the filter for prompt attacks in the harmful categories.**"
- 프롬프트 공격은 별도 페이지가 전담한다: `https://docs.aws.amazon.com/bedrock/latest/userguide/guardrails-prompt-attack.html`(탈옥·프롬프트 인젝션·프롬프트 누출 3종)
- 대조군: 같은 추출에서 `Misconduct`가 1건, `Prompt Attack`을 범주 소제목으로 세면 **0건**(추출 실패가 아니다)
- AIF 갭 노트도 이 어긋남을 이미 기록해 뒀다(`99-gaps.md`, 「Guardrails 유해 범주 5/6」)

⑤ 제안 수정안 — **개수를 지운다.** 가장 짧고 두 공식 서술 모두와 양립한다.
> "콘텐츠 필터는 **사전 정의된 유해 콘텐츠 범주**(Hate · Insults · Sexual · Violence · Misconduct)를 범주별 강도로 막는 이진 게이트입니다. 사내 규정과의 논리적 모순을 증명하지 않습니다."

더 가르치고 싶다면 한 줄을 덧붙인다:
> "⚠️ 프롬프트 공격은 **별도 정책**이지만 콘솔에서는 유해 범주와 같은 화면에서 고릅니다 — 공식이 두 가지로 적는 자리라 **개수는 외우지 않습니다.**"

⚠️ **가드 충돌 없음.** `aif_facts_test.dart`에 이 범주 개수를 고정하는 단정은 없다. 보존 가드와도 무관하다.
⚠️ **같은 문항의 다른 부분은 정확하다** — 정답(자동 추론 검사)·거부 주제 정의 길이(Standard 1,000자 / Classic 200자)·민감 정보 필터 서술은 모두 공식과 맞다. **정답 인덱스 1은 불변이다.**

### P1b-A2. `aif-t2-2-q11`이 「계속 사전 훈련」을 **주 용어로** 쓴다 — 공식 한국어 가이드와 레포 표준은 「지속적인 사전 훈련」 ★

① **`aif/aif-t2-2.questions.json:300`**(`options[0]`) · **`:306`**(`explanation`, 2회) — 합 **3개소**

② 현재 문구 그대로:
> `options[0]`: "**계속 사전 훈련** — 레이블이 없는 자체 데이터로 안전한 관리형 환경에서 모델을 훈련해 더 견고한 도메인 지식과 적응성을 축적합니다"
> `explanation`: "… **계속 사전 훈련**을 레이블이 없는 자체 데이터로 … 적습니다. **계속 사전 훈련**은 원래 훈련 범위를 넘어 …"

③ 왜 틀렸는지 — **공식 한국어 시험 가이드가 「지속적인 사전 훈련」을 쓴다**(2개소). 레포는 D-09·G-20에서 이 표기로 통일했고, `aif_facts_test.dart`는 「계속 사전 훈련」이 **`aif-t3-3.md`의 번역 메모 한 곳에만** 있도록 고정한다. 그런데 **그 가드는 `.md`만 순회하므로 문항 파일이 새어 나갔다.** 이 문항은 정답 보기 본문에 구 표기를 쓰고 있어 학습자가 공식과 다른 낱말을 정답으로 외우게 된다.

④ 공식 URL + 실측 근거
- `flutter_app/assets/exam_guides/AIF-C01.json` 전수 추출 — 「지속적인 사전 훈련」 **2개소**("FM 훈련의 주요 요소 설명(예: 사전 훈련, 미세 조정, **지속적인 사전 훈련**, 증류)" · "FM을 미세 조정하는 방법 정의(예: 명령 튜닝, 특정 도메인에 맞춰 모델 조정, 전이 학습, **지속적인 사전 훈련**)"). 「계속 사전 훈련」 **0개소**
- `grep -rc "지속적인 사전 훈련" aif/*.md` = t2-1:2 · t2-2:1 · t3-1:4 · t3-3:18 = **25개소**
- `grep -rn "계속 사전 훈련" aif/` = **md 1개소**(`aif-t3-3.md:124`, 의도된 병기) + **문항 3개소**(이 문항)
- 가드: `flutter_app/test/aif_facts_test.dart`의 `test('「계속 사전 훈련」은 t3-3의 번역 메모 한 곳에만 있다')` — `Directory('assets/content/aif').listSync()… .where((f) => f.path.endsWith('.md'))`로 **md만** 센다

⑤ 제안 수정안 — 3개소를 「지속적인 사전 훈련」으로 치환한다. 정답 인덱스 0은 불변이고 사실 서술도 바뀌지 않는다.

⚠️ **가드 충돌 없음**(현행 가드는 md만 본다). 함께 제안: 그 가드의 대상을 **`.md` + `.questions.json`**으로 넓히면 같은 누출이 재발하지 않는다. 그러려면 `aif-t3-3.md`만 허용하는 현 단정(`expect(hits, ['aif-t3-3.md'])`)을 **md 허용 1곳 + 문항 0건** 두 단정으로 갈라야 한다.

### P1b-A3. 중복·겹침 문항 **6쌍** ★(상위 4쌍)

210문항 중 **12문항이 6쌍의 중복**을 이룬다. AIF는 통합·약점 모의고사가 Task를 가로질러 샘플링하므로(`lib/data/mock_exam.dart`), 같은 사실을 두 번 묻는 쌍은 **한 시험에 같이 나올 수 있다.**

| # | 쌍 | 같은 출처 | 정답 보기 유사도 | 성격 | 처리 제안 |
|---|---|---|---|---|---|
| ① | `aif-t4-1-q4` ↔ `aif-t5-1-q13` | `guardrails-contextual-grounding-check.html` | 지문 자카드 **0.50** | **같은 시나리오를 글자까지 거의 같게** 쓴다 | 한쪽을 다른 각도로 재작성 ★ |
| ② | `aif-t2-2-q13` ↔ `aif-t3-4-q13` | `prod-value.html` | 정답 자카드 **0.74** | 정답 문장이 사실상 동일 | 한쪽 교체 ★ |
| ③ | `aif-t2-2-q14` ↔ `aif-t3-4-q15` | `prod-value.html` | — | 같은 문단의 **재무 지표 ↔ 비즈니스 가치 지표** 분류를 양쪽에서 묻는다 | 한쪽 교체 ★ |
| ④ | `aif-t3-3-q14` ↔ `aif-t4-1-q10` | `raidp03-bp02.html` | — | 정답과 **오답 보기까지** 겹친다 | 한쪽 교체 ★ |
| ⑤ | `aif-t2-1-q7` ⊂ `aif-t2-3-q13` | `prompt-caching.html` | 정답 자카드 **0.43** | 포함 관계(뒤가 앞의 상위집합) | 경고 — 앞을 다른 축으로 |
| ⑥ | `aif-t3-1-q12` ⊂ `aif-t3-3-q5` | `model-distillation.html` | 정답 자카드 **0.33** | 포함 관계 | 경고 — 앞을 다른 축으로 |

> ⚠️⚠️ **컨트롤러 반영 완료(2026-11-07 — HANDOFF §0-2026-11-07-a).** 본문 전수로 재확인해
> **여섯 쌍 모두 실재 중복**이었고 전부 교체했다(기준선 3,133, 가드 22건). 교체한 6문항은 전부
> 드래프트라 라이브 영향이 없고, **정답 인덱스·`skill`·`section`·`difficulty`·`verified` 는 원본을
> 그대로 옮겼다.**
> ⚠️⚠️ **이 절의 「처리 제안」 중 교체 방향 세 건을 반대로 뒤집었다.** 어느 쪽을 남길지는
> 「어느 문항이 더 잘 쓰였나」가 아니라 **「어느 공식 목표가 그 사실을 소유하나」**로 가른다
> (`exam_guides/AIF-C01.json` 목표 본문 실측): ①은 **5.1.5**(「할루시네이션 감지 방법 및 접지
> 기법」)가 소유하므로 `t5-1-q13` 을 남기고 **`t4-1-q4`** 를 교체했고, ④는 **4.1.5**(「균형 잡힌
> 데이터세트」)가 소유하므로 `t4-1-q10` 을 남기고 **`t3-3-q14`** 를, ⑥은 **3.1.5**(「사용자 지정
> 접근법의 비용 절충점」)가 소유하므로 `t3-1-q12` 를 남기고 **`t3-3-q5`** 를 교체했다. 그렇게
> 하지 않으면 그 Task 를 공부하는 사람이 **그 자리에서 그 사실을 만나지 못한다.**
> ⚠️⚠️ **신규 소재는 그 Task 의 기존 출제 주제를 전수 확인한 뒤 골랐다** — `aif-t3-4-q14` 가 이미
> **작업 완료율**을 물어, 목표 3.4.5 의 신규 둘은 남은 축인 **사용자 만족도**와 **상호 작용당
> 비용**으로 가야 했다. 전수 확인 없이 골랐으면 중복을 해소하며 새 중복을 만들었다.
> ⚠️ **교체 대상 6문항의 id 를 직접 참조하는 가드는 0건**이었다(MLA 는 7건이라 지워야 했다).
> ⚠️ 소재를 고르다 **공식이 암시적/명시적 피드백 예시를 서로 바꿔 적는 자리**를 찾아 그 라벨을
> 쓰지 않았다(99-gaps **G-71**). **남은 중복 항목은 §P1b-A4 하나뿐이다.**

**①의 근거 — 지문을 나란히 둔다.**
```
aif-t4-1-q4  STEM: 문맥 근거 확인을 켠 RAG 챗봇에서 접지 소스가 "London is the capital of UK.
             Tokyo is the capital of Japan"이고 질의가 "What is the capital of Japan?"인데,
             모델이 "The capital of UK is London."을 응답했습니다. …
   correct(3): 무관입니다 — 소스에 근거하고 사실도 맞지만 질의에 답하지 않아 관련성 점수가 낮습니다

aif-t5-1-q13 STEM: 접지 소스가 London is the capital of UK. Tokyo is the capital of Japan. 이고
             사용자 질의가 What is the capital of Japan? 입니다. 모델 응답이
             The capital of UK is London. 일 때 … 어떻게 판정합니까?
   correct(1): 관련성 점수가 낮은 무관 응답으로 판정합니다 — 사실이 맞고 소스에 근거가 있어도
               질의에 답하지 않았기 때문입니다
```
공식 예시(`guardrails-contextual-grounding-check.html`)를 양쪽이 그대로 가져왔고 **오답 보기 셋의 의미도 같다**(미근거 / 둘 다 통과 / 미근거+무관). 보기 순서만 다르다.

**②의 근거.**
```
aif-t2-2-q13 correct: ROI는 출시 시점에 수행하는 정적 계산으로 다룰 수 없고, 지속적으로 추적해
                      대시보드로 시각화하는 동적 KPI로 관리해야 합니다
aif-t3-4-q13 correct: 아닙니다. ROI는 출시 시점에 수행하는 정적 계산으로 다룰 수 없고,
                      대시보드에서 지속적으로 추적하고 시각화하는 동적 KPI로 관리해야 합니다
```

**④의 근거** — 정답뿐 아니라 오답 보기까지 겹친다.
```
aif-t3-3-q14 correct: … 편향 완화가 새로운 공정성 문제를 들여오지 않았는지, 예컨대 한 인구통계 축의
                      균형을 맞추다 교차 집단에 불균형이 생기지 않았는지 검증합니다
             X1     : 인구통계 레이블은 알고리즘이나 사람이 추정한 값을 쓰는 것이 자기 보고보다 …
aif-t4-1-q10 correct: 편향 완화가 새 공정성 문제를 만들지 않았는지 검증합니다 — 한 인구통계 차원을
                      맞추는 것이 교차 집단에 의도치 않은 불균형을 만드는지 확인합니다
             X2     : 인구통계 라벨을 알고리즘 예측으로 다시 채워 집단별 표본 수를 정확히 맞춥니다
```

④ 측정 근거 — `dupscan.py`: 같은 `sources[].url`을 공유하는 모든 문항쌍에 대해 `options[correct]`·`stem`의 2자 이상 토큰 자카드를 계산하고 `correctJ≥0.33` 또는 `(correctJ≥0.2 and stemJ≥0.33)`을 후보로 올렸다. **문자열 동일 비교(`scan3.py`)는 이 6쌍을 한 건도 잡지 못했다.**

⑤ 제안 수정안 — **쌍마다 한쪽만 교체한다.** 각 Task의 목표 커버리지를 깨지 않으려면 교체 대상을 **목표가 여유 있는 쪽**으로 고른다. `aif_questions_test.dart`의 `test('이 Task의 모든 목표가 최소 한 문항에 덮인다')`가 Task별 목표 전수 커버리지를 요구하므로, 교체 문항의 `skill`은 **원래 값을 유지**해야 한다. 같은 출처 페이지 안에서 아직 묻지 않은 사실로 바꾸는 것이 가장 싸다 — 예를 들어 ②③이 쓰는 `prod-value.html`에는 "비용이 동적 변수인 이유(API 토큰 소비·수요에 맞춘 인프라 확장·유지 활동의 연산 비용)"와 "가치가 동적인 이유(채택률·사용자 행동 변화·모델 성능 저하·모델 교체)"가 아직 문항화되지 않은 채 남아 있다.

⚠️ **가드 충돌**: 없음. 단 교체 시 `aif_questions_test.dart`의 네 단정을 함께 통과시켜야 한다 — ①options 4개·correct 0~3·`wrongExplanations` 키, ②`skill`이 실재하는 공식 목표 번호, ③**Task 목표 전수 커버리지**, ④flip 허용 목록 계약.

### P1b-A4. `aif-t4-1-q11`이 Data Wrangler SMOTE 구현 세부를 묻는다 — Foundational 등급 대비 과도


> ⚠️⚠️ **컨트롤러 반영(2026-11-07 — HANDOFF §0-2026-11-07-b).** 판정은 **그대로
> 확정**이고 제안 ①을 택했다(②는 그 근거였던 §3-3 ④ 중복이 §P1b-A3 반영으로 이미
> 풀려 이유가 없어졌다). 두 가지를 덧붙인다.
> ⚠️⚠️ **이것은 사실 오류가 아니라 등급 결함이다** — 인용된 세 서술은 공식 페이지에
> **글자 그대로 실재한다**(`The interpolated sample has a value of 0.7A + 0.3B.` ·
> `You can't balance datasets containing column vectors.` · 이웃 거리 계산의 수치 특징
> 한정). 그래서 **참인 문장을 「틀렸다」고 적지 않고 층만 올렸다.**
> ⚠️⚠️ **범위가 하한이었다** — 같은 구현 세부가 **라이브 학습문서 `aif-t4-1.md`에도**
> 있었다(본문 §5 ③ 한 문단 + 참고자료 24번 제목의 「열 벡터 제약」). **문항 가드는
> `.md`를 보지 않으므로** 금지 단정을 **aif md 14편 + 문항 14파일 전수 집계**로 걸었다.
> ⚠️ 새 오답 보기(범주별 손실 가중치)의 단정 범위는 **공식 「데이터 균형 맞추기」
> 연산자 셋**으로 한정했다 — 「AWS에 손실 가중치가 없다」로 넓히면 거짓이 된다.

① **`aif/aif-t4-1.questions.json`** (`aif-t4-1-q11`, `[foundational]`, skill `4.1.5`)

② 현재 문구 그대로 (정답 보기와 오답 근거):
> `correct`: "이웃 샘플로 새 합성 샘플을 보간하며, **수치 특징은 가중 평균으로 만들고 비수치 특징은 보간에 쓰인 실제 샘플 중 하나에서 복사**합니다"
> `explanation`: "… 수치 특징은 **무작위로 할당한 가중치의 가중 평균으로 만들고(예: 0.7A + 0.3B)**, 비수치 특징은 … 무작위로 할당한 확률에 따라 복사합니다."
> `X3`: "**열 벡터를 포함하는 데이터세트는 균형을 맞출 수 없다**고 공식이 못박습니다."

③ 왜 문제인지 — **정답 보기의 핵심(보간으로 합성 샘플을 만든다)은 AIF 범위에 맞고 사실도 정확하다.** 문제는 ⓐ 해설이 `0.7A + 0.3B`라는 **구현 수준 수치**까지 내려가고, ⓑ 오답 근거가 「열 벡터 데이터세트는 균형 불가」라는 **SageMaker Data Wrangler 제품 제약**에 기대며, ⓒ 출처가 `data-wrangler-transform.html`이라는 점이다. Data Wrangler는 **현재 Studio Classic 전용 UI가 없어지고 SageMaker Canvas 안의 기능으로 접힌 상태**다(`studio-updated-migrate-ui.html`: "The new Studio experience doesn't support the classic Data Wrangler UI, and you must create a Canvas application if you want to continue using Data Wrangler"). AIF-C01 목표 4.1.5는 **데이터세트의 편향·큐레이션**을 묻는 자리이고 특정 도구의 보간 가중치를 묻는 자리가 아니다.

④ 공식 URL + 실측 근거
- `https://docs.aws.amazon.com/sagemaker/latest/dg/data-wrangler-transform.html` — `200 r=0`. 인용된 SMOTE 서술은 **그 페이지에 실재한다**(사실 오류가 아니다)
- `https://docs.aws.amazon.com/sagemaker/latest/dg/studio-updated-migrate-ui.html` — Data Wrangler의 현재 접근 경로가 Canvas임을 명시
- AIF 문항 전수에서 `data-wrangler`를 출처로 쓰는 문항은 **이 1건뿐**이다(`grep -c`)

⑤ 제안 수정안 — 두 선택지.
1. **보기·해설만 한 단계 올린다.** `0.7A + 0.3B`와 「열 벡터」 제약을 빼고, 공식이 같은 페이지에서 적는 **무작위 오버샘플링(복제) ↔ 언더샘플링(제거) ↔ SMOTE(보간)** 3분할로만 가른다. 정답 인덱스 2는 불변.
2. 목표 4.1.5의 다른 사실로 교체한다 — 같은 트랙의 `raidp03-bp02.html`(자기 보고 레이블·계층 표집·교차 집단 검증)이 이미 ④번 중복쌍에 걸려 있으므로, 교체하면 §3-3 ④도 함께 풀린다.

⚠️ **가드 충돌 없음.** `aif_facts_test.dart`에 이 문항에 대한 보존 가드는 없다.

---

## 4. P2 — 출처 결함

### MLA-C01

#### P2-M1. **사람이 브라우저로 열 수 없는 백서 4종**이 라이브 문항 5개와 학습문서 3편의 출처로 쓰이고 있다 (상태 표기 없음)

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-o).** 판정과 처리 제안은
> **그대로 확정**이고(대조군까지 재현했다: 일부러 틀린 슬러그도 같은 곳으로 가므로 개별
> 슬러그 변경이 아니라 **가이드 전체의 사람 대상 서빙이 꺼진 것**이다), 범위가 넓어졌다 —
> `cost-optimization-in-analytics-services.html` 은 **`dea/dea-t1-2.md`** 에도 있다(이 절은
> MLA 전용으로 적었다. SAA 의 같은 백서는 §0-2026-11-06-n 이 함께 닫았다). 전수 가드를
> **전 자격증**으로 걸어 다음 누락이 자동으로 드러나게 했다.
> ⚠️ **`mla-t4-3-q12` 의 정답은 0이다** — 이 절이 적지 않은 값이라 반영 때 추측했다가
> 가드가 먼저 잡았다. **보고서가 적지 않은 값은 추측하지 않고 실측한다.**

> ⚠️⚠️ **§P3-M2(Clarify 상태) 는 과소였다** — 그 절은 누락을 `mla-t4-1-q19`·`q20`·`q21`
> **3문항**으로 적고 「같은 파일의 13문항은 달고 있다」고 했으나, **그 파일의 Clarify 언급은
> 4건이고 상태가 있는 것은 0건**이었다. MLA 전수로 세면 **18문항 언급 · 상태 4건**이고,
> 그중 **가르치는 층**(`skill`·`stem`·`options[correct]`·`explanation`)에서 드는 **8문항**이
> 대상이다. ⚠️ **오답 보기·출처 제목에만 나오는 9문항은 대상이 아니다** — 거기에 상태를
> 달면 **틀린 보기를 설명하는 문장**이 된다(2026-11-06 AIF Model Monitor 교훈).

① 영향 범위

| 백서 URL(출처로 적힌 것) | 리다이렉트 | 쓰는 곳 |
|---|---|---|
| `whitepapers/latest/cost-modeling-data-lakes/cost-optimization-in-analytics-services.html` | **302** → `cost-management/latest/userguide/what-is-costmanagement.html` | `mla-t1-1-q2` |
| `whitepapers/latest/ml-best-practices-healthcare-life-sciences/model-interpretability.html` | **301** → `aws.amazon.com/health/healthcare/solutions/analytics-ml/` | `mla-t2-1-q11` · `mla-t2-1.md` |
| `whitepapers/latest/build-secure-enterprise-ml-platform/governance-and-control.html` | **302** → `sagemaker/latest/dg/whatis.html` | `mla-t4-3-q12` · `mla-t4-3-q13` · `mla-t4-3.md` |
| `whitepapers/latest/build-secure-enterprise-ml-platform/networking-architecture.html` | **302** → `sagemaker/latest/dg/whatis.html` | `mla-t4-3-q25` · `mla-t4-3.md` |
| `whitepapers/latest/building-data-lakes/data-cataloging.html` | **302** → `lake-formation/latest/dg/what-is-lake-formation.html` | `mla-t4-3.md`(md 전용) |

② 현재 문구 그대로 (예: `mla-t4-3-q12`)
> `SRC: Build a Secure Enterprise Machine Learning Platform on AWS — Governance and control | https://docs.aws.amazon.com/whitepapers/latest/build-secure-enterprise-ml-platform/governance-and-control.html`

③ 왜 문제인지 — **문서가 사라진 것은 아니다.** AWS 문서 리더로 같은 URL을 읽으면 본문이 그대로 나온다(governance-and-control 10,491자 · networking-architecture 2,309자 · cost-optimization-in-analytics-services 58,920자 · model-interpretability 5,495자 · data-cataloging 4,507자). 즉 **인용은 유효하고 사람만 열 수 없다.** 그런데 학습자가 각주를 클릭하면 **인용한 사실이 없는 전혀 다른 페이지**(SageMaker 소개 / Lake Formation 소개 / Cost Management 소개 / 헬스케어 마케팅 페이지)에 떨어진다. 예컨대 `mla-t4-3-q12`가 인용하는 SCP 가드레일 JSON 예제는 `sagemaker/latest/dg/whatis.html`에 **한 줄도 없다.**

이 레포는 **똑같은 상황에 이미 처리 선례가 있다** — AIF의 `AWS CAF for AI`다. `aif-t3-3.md`는 인용을 유지한 채 ⓐ 302로 어디로 튕기는지, ⓑ 「문서가 사라진 것은 아닙니다」, ⓒ 사람이 열 수 있는 인접 정본을 적고, `aif_facts_test.dart`가 그 세 요소를 고정한다. **MLA의 네 백서에는 그 처리가 없다.**

④ 공식 URL + 실측 근거
- `curl -s -D -` 로 상태 코드와 `Location`을 직접 읽었다(위 표)
- **가이드 단위 리다이렉트임을 대조군으로 확인**: 일부러 틀린 슬러그도 같은 곳으로 간다
  - `.../build-secure-enterprise-ml-platform/zz-bogus.html` → `302` → `sagemaker/.../whatis.html`
  - `.../build-secure-enterprise-ml-platform/welcome.html` → `302` → 같은 곳
  - `.../ml-best-practices-healthcare-life-sciences/zz-bogus.html` → `301` → 같은 마케팅 페이지
  - `.../cost-modeling-data-lakes/zz-bogus.html` · `.../building-data-lakes/zz-bogus.html` → 각각 `302` → 같은 곳
  → 개별 슬러그 변경이 아니라 **가이드 전체의 사람 대상 서빙이 꺼진 것**
- **두 번째 방법(AWS 문서 리더)으로 본문 존재 확인** — 다섯 URL 전부 `status: SUCCESS`, 본문 정상
- ⚠️ **틀린 슬러그 대조군만으로는 「은퇴」와 「서빙만 꺼짐」이 갈리지 않는다**(G-61). 그래서 문서 리더를 두 번째 방법으로 썼다

⑤ 제안 수정안 — AIF의 CAF 선례를 그대로 옮긴다. **인용은 지우지 않는다.**
1. 각 문항의 `sources[].title`에 상태를 넣는다: `"Build a Secure Enterprise ML Platform on AWS — Governance and control (⚠️ 브라우저로는 SageMaker 소개 페이지로 302 리다이렉트됩니다. 문서가 사라진 것은 아닙니다)"`
2. 사람이 열 수 있는 **인접 정본**을 둘째 출처로 더한다. 조건 키 가드레일은 `service-authorization/latest/reference/list_sagemaker.html`(이미 `q12`의 둘째 출처다 — `q13`·`q25`에도 같은 처리를 한다), 네트워크는 `sagemaker/latest/dg/host-vpc.html`·`train-vpc.html`
3. md 3편의 참고자료 항목에 같은 상태 한 줄을 적는다
4. 사실 서술과 정답 인덱스는 **전부 불변**이다(출처 교체는 핫픽스이고 flip과 무관하다)

⚠️ **가드 충돌 없음.** `mla_questions_test.dart`는 `sources[].url`이 `http`로 시작하는지와 `title`이 비지 않았는지만 본다. ⚠️ 다만 `mla-t4-3-q12`의 둘째 출처를 **지우지는 말 것** — 거기에 인용된 `sagemaker:NetworkIsolation` 조건 키가 유일하게 사람이 열 수 있는 근거다.

#### P2-M2. `repost.aws` 403 7건 — **죽은 링크가 아니다** (조치 불필요, 기록용)

`curl`로 7개 URL이 모두 `403 r=0`을 돌려주지만 **봇 차단**이고 페이지는 살아 있다. **내장 브라우저로 직접 열어** `sagemaker-ai-test-models-local-mode`를 확인했다 — 제목·본문·인용된 로컬 모드 절차가 그대로 있다. 나머지 6건도 같은 호스트의 같은 패턴이다. **조치 불필요**이며, 다음 검토자가 이것을 「죽은 링크」로 오판하지 않도록 적어 둔다.

대상: `sagemaker-access-network-isolation`(t4-3-q19) · `sagemaker-ai-test-models-local-mode`(t3-1-q24) · `sagemaker-endpoint-latency`(t4-2-q6·q7) · `sagemaker-endpoints-scaling-issues`(t4-2-q32) · `sagemaker-model-registry-issues`(t4-3-q15) · `sagemaker-notebook-vpc-troubleshoot`(t4-3-q35) · `sagemaker-resource-limit-exceeded-error`(t4-2-q30)

### AIF-C01

#### P2-A1. `aif-t1-2`가 **은퇴한 Amazon Machine Learning 개발자 안내서**를 「공식 문서」로 인용한다 — MLA는 같은 가이드에 「레거시」 라벨을 붙인다

① **`aif/aif-t1-2.questions.json:31`**(`aif-t1-2-q1`) · **`:91`**(`aif-t1-2-q3`) · **`aif/aif-t1-2.md:12`**(프런트매터 `sources`) · **`aif/aif-t1-2.md:375`**(참고자료 1번)

② 현재 문구 그대로
> `aif-t1-2-q1` SRC: `When to Use Machine Learning — 규칙을 코딩할 수 없을 때와 확장할 수 없을 때 | https://docs.aws.amazon.com/machine-learning/latest/dg/when-to-use-machine-learning.html`
> `aif-t1-2-q1` EXP: "**공식 문서는** 기계 학습을 쓰는 상황을 두 가지로 적습니다. …"
> `aif-t1-2.md:375`: "1. When to Use Machine Learning — `docs.aws.amazon.com/machine-learning/latest/dg/when-to-use-machine-learning.html` (2026-11-03 확인)"

③ 왜 문제인지 — **인용된 사실은 전부 정확하다**(아래 ④에서 원문 대조). 문제는 **귀속 층**이다. 이 가이드는 2015년 서비스 Amazon Machine Learning의 문서이고, 페이지 맨 위에 **"We are no longer updating the Amazon Machine Learning service or accepting new users for it. This documentation is available for existing users, but we are no longer updating it."**가 붙어 있다. 그것을 아무 표시 없이 「공식 문서」로 인용하면 학습자는 **현행 서비스의 현행 안내**로 읽는다.

그리고 **MLA는 같은 가이드를 명시적으로 라벨링한다** — 두 트랙이 같은 출처를 다르게 다루는 자리다:
```
mla/mla-t2-2.md:539   33. Model Fit: Underfitting vs. Overfitting (레거시) — https://docs.aws.amazon.com/machine-learning/...
mla-t2-2-q15 SRC: Model Fit: Underfitting vs. Overfitting — 보조 출처(Amazon Machine Learning,
                  신규 사용자 중단된 구서비스 문서)
```
`grep -rc "구서비스"` → MLA 문항 **4개소**(t2-2 3 · t2-3 1), **AIF 0개소**.

④ 공식 URL + 실측 근거 — `https://docs.aws.amazon.com/machine-learning/latest/dg/when-to-use-machine-learning.html`
- `curl -sL` = `200 r=0`(살아 있다)
- AWS 문서 리더 전문 첫 문장: "**We are no longer updating the Amazon Machine Learning service or accepting new users for it.** This documentation is available for existing users, but we are no longer updating it."
- 인용된 사실은 원문과 일치한다: "**You cannot code the rules:** … (such as recognizing whether an email is spam or not spam) … When rules depend on too many factors and many of these rules overlap or need to be tuned very finely, it soon becomes difficult for a human to accurately code the rules." · "**You cannot scale:** You might be able to manually recognize a few hundred emails … However, this task becomes tedious for millions of emails."
- 즉 **사실 정정은 필요 없고 라벨만 필요하다**

⑤ 제안 수정안 — MLA의 표기를 그대로 옮긴다.
1. 두 문항의 `sources[].title`: `"When to Use Machine Learning — 보조 출처(Amazon Machine Learning, 신규 사용자 중단된 구서비스 문서)"`
2. `aif-t1-2.md:375` 참고자료 항목에 `(레거시)` 표기
3. 두 문항의 `explanation`에서 **「공식 문서는」을 「구 Amazon Machine Learning 개발자 안내서는」으로** 바꾸거나, 현행 정본을 둘째 출처로 더해 그쪽을 「공식」으로 돌린다. `q1`은 이미 `MLCOST02-BP01`(머신 러닝 렌즈)을 둘째 출처로 들고 있어 **그 문장만 앞으로 옮기면 해결된다**
4. 정답 인덱스(q1:1, q3:2)는 불변

⚠️ **가드 충돌 없음.** 이 문항들에 걸린 보존 가드는 없다.

---

## 5. P3 — 보강 후보

### MLA-C01

#### P3-M1. 중복·겹침 문항 3쌍 — 그중 **2쌍이 라이브이고 모의고사 풀을 가로지른다**

> ⚠️⚠️ **컨트롤러 정정(2026-11-06 반영 PR — HANDOFF §0-2026-11-06-p).** 반영 때 §0-3 기준으로
> **MLA 321문항을 재측정해 정확히 이 3쌍**을 얻었다(보고서와 일치, 그리고 **셋 다 라이브**다 —
> 「2쌍이 라이브」가 아니라 **3쌍 전부**다: `mla-t1-3-q1`·`q13`·`q14`·`q15`·`q18`·`q25` 가 모두
> `verified: true` 다).
> ⚠️⚠️ **같은 스캔을 AIF 에 돌리면 §P1b-A3 의 6쌍 중 3쌍만 걸린다**(이 줄은 처음 「4쌍」으로
> 적었고 2026-11-07 반영의 교체 전 실측이 **3쌍**으로 정정했다 — ②0.74 · ⑤0.43 · ⑥0.33).
> ③(`prod-value.html` 의 재무↔비즈니스 가치 분류) · ④(`raidp03-bp02.html` 의 편향 완화 후
> 검증) · **①**(`guardrails-contextual-grounding-check.html` 의 접지 vs 관련성)이 **표현이 달라
> 정답 자카드 임계를 넘지 않는데 같은 사실을 묻는 실제 중복**이다. ①이 빠진 이유는 이 절이
> ①의 유사도를 **「지문 자카드 0.50」**으로 적었기 때문이다 — ②⑤⑥은 **정답** 자카드다.
> **행마다 다른 지표를 쓴 표를 한 가지 스캔으로 재현할 수 없다.**
> 이 절이 그 둘의 유사도를 **「—」로 적은 것**이 바로 그 신호였다 — **지표는 하한이고 사람이
> 읽어 판정해야 한다.** 두 쌍은 확정이며 AIF 분은 별 배치로 둔다.
> ⚠️ **교체 쪽은 커버리지로 골랐다** — 이 절은 ①에서 `q18` 교체를 제안했고 그대로 따랐으나,
> 제안한 새 소재(「값이 1 또는 −1에 가까우면 재표집」)는 **이미 `q18` 의 해설에 있었다.** 그래서
> **CI 부호의 방향**(양수=facet a 많음 · −1=facet d만 · 0=완전 균등)으로 돌렸다. ②는 20% 절충이
> **`q13` 의 「과적합·과소적합 식별(K3)」 맥락에서 정본**이라 `q25`(절충 SK2)를 돌렸고, ③은
> **`q14` 가 「수렴 문제(K5)」 의 유일한 문항**이라 `q15` 를 돌렸다.
> ⚠️ 이 절의 「`mla_questions_test` 가 id 로 직접 참조하는 문항에 위 6문항은 없다」는 **맞았다**.
> 다만 **`mla-t2-3-q18` 에는 §P3-M2 가 붙인 Clarify 상태 한 줄이 있어** 새 본문에도 유지해야
> 했고, **`mla-t1-3-q1` 은 그 배치 가드의 대조군**이라 손대지 않았다.

| # | 쌍 | 같은 출처 | 유사도 | 성격 |
|---|---|---|---|---|
| ① | `mla-t1-3-q1` ↔ `mla-t2-3-q18` | `clarify-bias-metric-class-imbalance.html` | 정답 자카드 **1.00** | **다른 Task** — 둘 다 「레이블과 무관하게 그룹 구성원 수만 재는 사전 편향 지표」를 묻고 정답이 `CI` |
| ② | `mla-t2-3-q13` ↔ `mla-t2-3-q25` | `autopilot-metrics-validation.html` | 정답 자카드 **0.62** | **같은 Task** — 둘 다 「교차 검증 → 훈련 시간 평균 20% 증가」 |
| ③ | `mla-t2-3-q14` ↔ `mla-t2-3-q15` | `debugger-built-in-rules.html` | 정답 자카드 **0.50** | 같은 Task — 각도는 다르지만 **정답 문자열이 둘 다 `vanishing_gradient`** |

**①의 근거.**
```
mla-t1-3-q1  STEM: 대출 심사 데이터셋에서 연령대 열의 그룹 구성 비율이 … 레이블(승인 여부)과는
             무관하게 그룹의 표현만 재는 사전 훈련 편향 지표는 무엇인가?
   correct : Class Imbalance(CI)
mla-t2-3-q18 STEM: Clarify 사전 편향 지표 중 결과 레이블이 아니라 facet별 구성원 수의 불균형만
             재는 지표는 무엇인가?
   correct : CI(Class Imbalance)
```
문는 사실이 **같고**, 두 문항이 서로 다른 Task에 있어 통합 모의고사에서 함께 샘플링될 수 있다. 2026-10-26 리뷰의 「중복 정본화」 작업은 도메인 **안쪽** 중복을 다뤘고 이 쌍은 **도메인 1 ↔ 도메인 2**를 가로지른다.

④ 측정 근거 — `dupscan.py`(§0-3). `scan3.py`의 문자열 동일 비교는 0건이었다.

⑤ 제안 수정안 — 라이브이므로 **정답 인덱스를 바꾸지 않는 본문 교체**(핫픽스)로 처리한다. 2026-10-27 SAA 중복 해소(#287)에서 쓴 방식이 선례다. ①은 `mla-t2-3-q18`을 같은 페이지의 다른 사실(「값이 1 또는 −1에 가까우면 학습 전 재표집을 고려한다」는 아직 문항화되지 않았다)로 돌리는 것이 가장 싸다.

⚠️ **교체는 가드를 지운다.** 교체 전 `grep -rn "mla-t2-3-q18"` 등으로 그 문항을 지키는 가드 레코드를 먼저 세야 한다(2026-10-27 SAA에서 7건이 그렇게 걸렸다). 이번 검토 시점에 `mla_questions_test.dart`가 id로 직접 참조하는 문항은 `mla-t2-3-q10`·`t2-3-q16`·`t4-2-q11`·`t3-3-q25`·`mmTaughtIds` 13건이고 **위 6문항은 거기에 없다.**

#### P3-M2. `mla-t4-1-q19`·`q20`·`q21`에 **Clarify 가용성 상태 한 줄이 없다** — 같은 파일의 13문항은 달고 있다

① `mla/mla-t4-1.questions.json`의 `mla-t4-1-q19`·`q20`·`q21`

② 현재 상태 — 세 문항은 **편향 드리프트 모니터링**(Normal Bootstrap 신뢰구간 판정 · DPPL 제약 위반 판정)과 **특성 기여도 드리프트**(NDCG) 를 해법 메커니즘으로 가르치는데, 상태 한 줄이 없다. 같은 파일의 12문항 + `mla-t2-3-q10`은 다음을 달고 있다:
> "⚠️ Model Monitor는 현재 신규 고객을 받지 않습니다(기존 고객은 사용 가능)."

③ 왜 문제인지 — 편향 드리프트와 특성 기여도 드리프트는 **Model Monitor의 네 모니터 유형 중 둘**이고(같은 파일 `q8`이 그렇게 가르친다), 구현은 **Clarify**다. 두 서비스는 **같은 묶음 공지로 2026-07-30부터 신규 고객에게 닫혔다**(`mla-t4-1.md:151`이 그 공지를 적는다). 즉 같은 파일 안에서 **같은 제약을 받는 기능에 상태 표기가 갈려 있다.** 학습자가 보기에는 「Model Monitor는 닫혔지만 편향 드리프트 모니터링은 쓸 수 있다」로 읽힌다.

④ 공식 URL + 실측 근거
- `https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-availability-change.html` — `200 r=0`, Clarify 가용성 변경 공지
- `https://docs.aws.amazon.com/sagemaker/latest/dg/clarify-model-monitor-bias-drift.html`(q19·q20) · `.../clarify-model-monitor-feature-attribution-drift.html`(q21) — 둘 다 `clarify-model-monitor-*` 계열이다
- `mla/mla-t4-1.md:151` — "기능 묶음 공지 — 2026-07-30부터 신규 고객 불가 대상에 Mechanical Turk, Ground Truth, Augmented AI, Studio Lab, **Model Monitor, Clarify, Debugger**, Role Manager, Geospatial, Profiler가 나열됩니다."
- **전수 분류 실측**: Clarify를 언급하는 MLA 문항 18개 중 상태 서술이 있는 것 4개. 나머지 14개 가운데 **11개는 지표의 정의·공식만 묻는다**(CI·DPL·JS·CDD·DI·PDP) — 그 11개는 서비스 가용성과 무관해 **상태를 달면 오히려 틀린 설명이 된다.** 남는 것이 q19·q20·q21 셋이다

⑤ 제안 수정안 — 둘 중 하나. **②도 충분히 정당하다.**
1. 세 문항의 `explanation` 끝에 같은 한 줄을 붙이고 `mla_questions_test.dart`의 `mmTaughtIds`에 세 id를 더한다(13 → 16).
2. 상태를 달지 않는 쪽을 유지하되, `mmTaughtIds` 바로 위 주석에 **왜 드리프트 판정 메커니즘 문항은 제외하는지**를 한 줄 적는다(현 주석은 「데이터 캡처는 독립 기능이라 제외」만 설명한다).

⚠️ **가드 충돌**: ①을 고르면 `flutter_app/test/mla_questions_test.dart`의 `const mmTaughtIds`(현재 13개 하드코딩)를 고쳐야 하고, 같은 테스트의 「상태 한 줄이 같은 문구로 붙어 있다」 단정이 세 문항을 추가로 요구하게 된다.

#### P3-M3. 「미세조정」 표기가 MLA 안에서 **세 갈래**다 — AIF는 한 갈래

| 표기 | MLA md | MLA 문항 | AIF md | AIF 문항 |
|---|---|---|---|---|
| **미세 조정**(공식) | 5 | 0 | **150** | **115** |
| 미세조정(붙여 씀) | **32** | **20** | 0 | 0 |
| 파인튜닝(음차) | **8** | 0 | 0 | 0 |

③ 왜 문제인지 — 공식 한국어 가이드와 공식 한국어 문서는 **「미세 조정」**(띄어 씀)을 쓴다. MLA는 `mla-t2-2.md`의 절 제목(`### 12) 사전 훈련 모델 파인튜닝 {#fine-tuning}`)과 문서 제목까지 음차 표기를 쓰고, 본문은 「미세조정」으로 붙여 쓴다. 두 자격증을 번갈아 공부하는 학습자에게 같은 개념이 세 이름으로 보인다.

④ 측정 근거 — `grep -ro` 전수(위 표). AIF 쪽 **「파인튜닝」 0건**이 대조군이다.

⑤ 제안 수정안 — MLA 전체를 **「미세 조정」**으로 통일한다. ⚠️ `mla-t2-2.md:337`의 앵커 `{#fine-tuning}`은 **건드리지 않는다** — `mla_questions_test.dart`의 `test('문항의 section이 학습문서 앵커와 짝이 맞는다')`가 문항 `section`과 md의 `{#id}`를 대조하므로 앵커를 바꾸면 깨진다. 바꾸는 것은 **표시 문자열만**이다. 문서 `title:` 프런트매터와 `### 12)` 제목, 「이 문서가 다루는 것」 줄, 자가 점검 Q5의 포인터가 함께 움직여야 한다(총 8개소).

#### P3-M4. (기록) MLA 정답 위치 쏠림 — **재보고하지 않는다**

실측: `mla-t3-1`~`t4-3` **6파일 174문항이 전부 `correct:0`**, `mla-t2-1`은 23문항 중 18이 `correct:1`, 전체로는 index 0이 69.8%다. 이 지적은 **3회 반복·3회 기각**됐고(2026-10-26 ③-1) 근거는 앱이 전 경로에서 보기를 셔플한다는 것이다. **그 전제를 다시 실측했다**:

```
lib/pages/cert_exam_page.dart:193   randomOptionOrders(sampled, rng)
lib/pages/exam_page.dart:101        randomOptionOrders(sampled, rng)
lib/pages/quiz_page.dart:41         applyOptionOrders(sampled, randomOptionOrders(sampled, rng))
lib/pages/review_page.dart:77       applyOptionOrders(queue, randomOptionOrders(queue, rng))
lib/models/question.dart:84         Question withOptionOrder(List<int> order)  // correct·wrongExplanations 동시 재매핑
```
문항을 렌더하는 네 경로 모두가 셔플을 거치고 `withOptionOrder`가 `correct`와 `wrongExplanations` 키를 함께 재매핑한다. **화면 영향 0이 유지된다.** 유일하게 값이 있는 하위 항목(해설이 보기 위치를 가정하는지)도 전수 재측정했고 **두 트랙 합쳐 실제 결함 0건**이다(§6-2).

#### P3-M5. (구조) MLA·AIF에 **사실 가드와 전파 가드가 비어 있다**

| 자격증 | facts 가드 | 전파 가드 |
|---|---|---|
| SAA | `saa_question_facts_test.dart`·`saa_t*_facts_test.dart` | `saa_question_propagation_test.dart` |
| SOA·DEA | `soa_facts_test.dart`·`soa_question_facts_test.dart` | `soa_dea_question_propagation_test.dart` |
| **MLA** | **없음** | **없음** |
| **AIF** | `aif_facts_test.dart`(md 전용 + 전파 2규칙) | 전용 파일 없음 |

§2 P1-M1(md는 「폐쇄」, 문항은 현재 선택지)과 §3 P1b-A2(가드가 md만 보는 사이 문항이 새어 나감)는 **둘 다 이 공백에서 나왔다.** 두 트랙에 전파 가드를 세우면 같은 누출이 기계로 막힌다. ⚠️ **AIF 전파 가드는 md 사실 가드의 금지 문장에서만 항목을 가져온다**는 SOA·DEA 판의 계약을 유지해야 한다. 그리고 구식·오표기 **명칭**(「계속 사전 훈련」 등)은 오답 보기도 바르게 불러야 하므로 **문항 전체를 보는 별 규칙**(`_nameRules`)으로 갈라야 한다 — SOA 판이 「적합성 팩」에서 배운 교훈이다.

### AIF-C01

#### P3-A1. (보강) `aif-t4-1-q3`를 고치는 김에 **「개수를 묻지 않는다」 범위를 명시해 두는 것**이 좋다

AIF는 이미 **차원 8/10**과 **모범 사례 개수**에서 같은 함정을 두 번 밟았고 `aif_facts_test.dart`가 「개수도 외우지 않습니다」 문구를 고정한다. §3 P1b-A1의 유해 범주 5/6이 **세 번째**다. `aif-t4-1.md`의 해당 절에 같은 형태의 한 줄을 넣고 가드로 고정하면 네 번째를 막는다. 제안 문구:
> ⚠️ **유해 콘텐츠 범주의 개수도 외우지 않습니다** — 공식 정의 절은 다섯이고(Hate·Insults·Sexual·Violence·Misconduct) 콘솔은 프롬프트 공격을 같은 화면의 유해 범주에 둡니다.

---

## 6. 확인했고 문제 없던 것 (대조군)

「검토했다」의 증거다. 아래는 **의심해서 측정했고 결함이 아니었던** 것들이다.

### 6-1. 출처 URL — 842개 전수 실측

- **827개가 `200 r=0`**. 비정상 15건의 처분: 리다이렉트 8건 중 **4건이 §4 P2-M1**, 2건은 AIF `AWS CAF for AI`(이미 `aif-t3-3.md`에 상태가 적혀 있고 가드가 고정 — **재보고 안 함**), 1건은 `cli/latest/reference/compute-optimizer/index.html` → 디렉터리(무해), 1건은 §4 P2-M1의 md 전용 1건. 403 7건은 **봇 차단**(§4 P2-M2).
- **AIF 문항 출처 274개는 전부 `200 r=0`이다.** 이번 주 네 배치가 전수 실측한 결과가 유지되고 있다.
- `docs.aws.amazon.com/ai/responsible-ai/` 접두사 = **403**(`aif-t4-1.md`의 경고가 지금도 정확하다) · 개별 카드 `.../bedrock-guardrails/overview.html` = `200 r=0` · `docs.aws.amazon.com/vector-databases/` = `200 r=0`.

### 6-2. 문항 품질 — 전수 측정값이 전부 0

| 측정 | 결과 |
|---|---|
| M2 작성 과정 메모 | MLA 2건 · AIF 8건이 패턴에 걸렸으나 **전부 「보기의 주장을 부정하고 곧바로 사실을 제시하는」 정당한 형태**다(MLA 가드 주석이 명시적으로 제외하는 유형). 실제 결함 **0건** |
| 해설이 보기 위치를 가정 | MLA 1건 · AIF 2건 매치, **전부 오탐**(「두 선택지는 서로 다른 층에 있습니다」=두 개념 · 「나머지 세 보기」=위치 무관) |
| 문항 내 보기 중복 | **0건** |
| 해설·보기의 마크다운 | `**`·백틱·링크·이탤릭 **모두 0건**(두 트랙). AIF는 가드가 없는데도 0이다 |
| md `[텍스트](링크)` | **0건**(두 트랙). 레포 전역 가드 유지 |
| md 단일 `*이탤릭*` | **0건**. 정규식이 MLA에서 11건을 올렸으나 **전부 코드 스팬 안쪽 별표**(`cron(0 * ? * * *)` · `ecr:*` · `ec2:*NetworkInterface*` · `packages.*.amazonaws.com`)로 정상 렌더된다 |
| md 과도한 일반화 | 패턴 22건 매치, **실제 결함 0건** — 전부 공식 원문 직접 인용(`"보존 날짜 만료 전에 삭제하는 유일한 방법은…"`)이거나 올바른 함정 경고(`❌ "ML 모델은 같은 입력에 항상 같은 답을 준다"`)이거나 「절대 오차」·「최대 절대 차이」 같은 수학 용어다 |
| 용어 표기 | 「기초 모델」 **0건**(두 트랙) · 「프롬프트 주입」 **0건** · 서비스명 한글 음차 **0건** · 「환각」 1건은 `aif-t2-2.md:97`의 **의도된 교정 서술**(「「환각」이 아니라 공식 한국어 표기가 「할루시네이션」입니다」) |

### 6-3. 닫힌·은퇴 서비스 — MLA의 처리는 대체로 **모범적이다**

의심해서 15종을 전수 조회했고, 아래는 **이미 정확히 처리돼 있었다**:

| 서비스 | 상태 | MLA의 처리 |
|---|---|---|
| Amazon Kendra | 신규 고객 불가 | `mla-t2-1-q5`가 **가용성 변경 자체를 묻는 문항**으로 만들고 공식 대안(Bedrock Knowledge Bases)까지 가르친다 |
| Amazon Q Business | 신규 고객 불가 | 같은 문항의 오답 근거가 「Q Business도 막혀 있고 그쪽 대안은 Amazon Quick」까지 적는다 |
| SageMaker Edge Manager | 2024-04-26 중단 | `mla-t3-1-q20`이 중단을 전제로 한 문항이고 대안(ONNX·IoT Greengrass V2)을 적는다 |
| SageMaker Role Manager | 신규 고객 불가 | `mla-t4-3-q10`·`q11`이 상태와 「기존 역할은 표준 IAM 역할이라 정리 불필요」까지 가르친다 |
| Elastic Inference | 제공 종료 | `mla-t3-1-q16`이 제공 종료를 정답으로 하고 대안(Inferentia·Graviton)을 적는다 |
| SageMaker Operators for K8s(원 버전) | 2023-02-15 지원 종료 | `mla-t3-1-q23`이 ACK 기반 이전을 가르친다 |
| SageMaker Profiler | 2027-06-30 종료 예정 | `mla-t4-2-q34`가 CloudWatch 대체를 가르친다 |
| Kinesis Data Analytics for SQL | 폐지 | `mla-t1-1-q10`의 오답 근거가 후속(Managed Service for Apache Flink)을 적는다 |
| CloudTrail Lake | **2026-05-31** 신규 고객 불가 | `mla-t4-2-q18`의 오답 근거가 날짜까지 정확하다(공식 실측 일치) |
| Model Monitor · Ground Truth · A2I | 신규 고객 불가 | 표준 한 줄이 14문항에 붙어 있다 |
| AWS CodeCommit | **2025-11-25 신규 고객에게 재개** | `mla-t3-3.md:305`가 **두 날짜를 모두** 적고 「서비스 재개와 Projects 템플릿 제거는 별개 사실」까지 가른다 — 공식 문서 이력(`codecommit/latest/userguide/history.html`)과 실측 일치 |
| AWS Audit Manager | AIF 범위 밖 | `mla-t4-3-q27`이 「이 시험 가이드의 범위 외 서비스」로 **정확히** 오답 처리 |
| AWS Glue Ray Jobs · Fraud Detector · Lookout · DevOps Guru · CodeGuru | 유지·일몰 | **문항에 0건**(md 언급만) — 출제를 피했다 |

AIF 쪽도 **Bedrock Agents Classic·SageMaker Clarify·Audit Manager·A2I 네 종을 정답 보기로 쓰지 않았다**(전수 0건). `aif-t4-2-q8`은 Clarify의 닫힘을 전제로 대체 경로(SHAP 직접 채택)를 가르친다.

### 6-4. 사실 정확성 — 공식 재대조 18건 전부 일치

문항의 핵심 수치·단정을 공식 전문으로 다시 읽었고 **어긋난 것이 없었다**:

| 확인한 주장 | 문항 | 공식 원문 |
|---|---|---|
| FastFile은 S3 prefix만 지원(manifest·augmented manifest 불가) | `mla-t1-1-q6` | "Fast file currently supports **S3 prefixes only** (it does not support manifest and augmented manifest)" |
| 학습 데이터 소스는 S3·EFS·FSx for Lustre 셋 | `mla-t1-1-q7`·`q19` | "Amazon SageMaker AI supports Amazon S3, Amazon EFS, and Amazon FSx for Lustre" |
| 프롬프트 캐싱은 배치 추론 API 미지원 | `aif-t2-1-q7`·`t2-3-q13` | "Prompt caching is **only supported for on-demand inference endpoints.** It is not supported with the batch inference API." |
| 캐시 쓰기 요율이 표준 입력보다 높을 수 있고 히트는 보장되지 않는다 | `aif-t2-1-q8` | "billed at the model's cache-write rate, which, depending on the model, **can be higher** than the standard input token rate" · "Support for prompt caching **doesn't guarantee a cache hit**" |
| 캐시 TTL은 히트마다 초기화되고 많은 모델이 5분 | `aif-t2-1-q8` X2 | "The cache has a Time To Live (TTL), which **resets with each successful cache hit** … **Many models support a 5-minute TTL.**" |
| 체크포인트 최소 토큰 512~4,096, 미달 시 추론 성공·캐시 안 됨 | `aif-t2-1-q7` X2 · `aif-t3-1-q3` | "Minimums currently range from **512 to 4,096 tokens** … your **inference still succeeds, but your prefix isn't cached**" |
| 배치 추론은 프로비저닝 모델 미지원 | `aif-t2-3-q13` | "Batch inference isn't supported for provisioned models." |
| 확산 모델의 노이징·역 디노이징 / GAN이 확산 개념 위에 세워짐 | `aif-t2-1-q2` | "Diffusion models create new data by iteratively making controlled random changes…" · "The generative adversarial network (GAN) is another generative AI model that **builds upon the diffusion model's concept.**" |
| Bedrock 배치 추론 **최대 50% 절감** | `mla-t2-1-q16` | 결정 가이드 Pricing 절: "**Batch inference offers up to 50% savings** for non-real-time workloads" — **MLA의 인용이 정확하다** |
| SageMaker AI Savings Plans **최대 64%**, 1·3년 | `mla-t3-2-q11` | "SageMaker AI Savings Plans can reduce costs by **up to 64%** with **1- or 3-year** commitments" |
| Amazon Quick의 서비스명과 Quick Sight가 그 기능 | `aif-t1-3-q9`·`t2-3-q4` · `mla-t4-2-q14` | "Amazon Quick is an AI-powered service… **Amazon Quick Sight** – Interactive data visualization…" |
| Amazon ML 구가이드의 두 상황 서술 | `aif-t1-2-q1`·`q3` | 원문 일치(§4 P2-A1 ④) |
| Guardrails 콘텐츠 필터 범주 정의 절 | `aif-t5-1.md:265` | **다섯 개 일치** — md가 옳다 |
| 재구성된 백서 5편의 본문 존재 | §4 P2-M1 | AWS 문서 리더로 전부 `SUCCESS` |

### 6-5. 선행 노트가 못박은 것 — 재보고하지 않았다

- **AIF 보존 가드 2건**(`aif-t5-1`의 Glue DQ 진입점별 지원 차이 · `aif-t4-1`의 `"If you don't specify a tier, your guardrail uses Classic tier."`) — 두 문장 모두 콘텐츠에 **그대로 남아 있다.** 「없다」로 보고할 근거를 찾지 못했고, 보존 가드의 방향(존재 단정)을 존중했다.
- **G-62**(`aif-t2-1`의 계층형 청킹 귀속) — md의 「계층형 청킹은 자식 청크가 부모로 교체되므로」가 남아 있고 `aif-t2-1-q1`도 같은 귀속을 쓴다. **옳다.**
- **G-61**(`AWS CAF for AI`) — `aif-t3-3.md`에 `302`·「문서가 사라진 것은 아닙니다」·`MLSEC-07` 대체 경로가 모두 있다.
- **MLA 3회 기각 항목**(정답 위치) — §5 P3-M4로 기록만 했다.
- **MLA DI = 0.5/0.6 = 0.8**(3회 중 1회 기각) — `mla-t2-3-q19`가 "공식 문서의 예는 … 0.5/0.6 = 0.8로 적습니다"로 **원문 인용 형태**를 유지한다. 정당하다.
- **`help-panel` 콘솔 도움말 출처** — 처음 교차 자격증 정책 불일치로 의심했으나, 측정하니 **DEA 3문항 · MLA 1문항(`mla-t3-1-q16`) · AIF 1문항**이 쓰고 있다. MLA 가드의 금지(`expect(srcs25.contains('help-panel'), isFalse)`)는 **`mla-t3-3-q25` 한 문항에만 걸린 국소 규율**이고 레포 전역 정책이 아니다. **결함이 아니다**(§7-3의 자기 정정 기록).

---

## 7. 측정 한계

### 7-1. 범위를 줄인 것

- **학습문서 26편(1.6MB)을 전문으로 읽지 않았다.** 축별 전수 스캔(출처 URL 전수 · 용어 · 표기 · 과도한 일반화 · 닫힌 서비스 · 금지 문구)과 문항에서 역으로 추적한 자리만 읽었다. 문항은 **531개 전수를 전문 독해**했으므로 우선순위(MLA 라이브 문항 → AIF 드래프트 문항 → 학습문서)는 지켰다. **놓칠 수 있는 유형**: 문항으로 파생되지 않은 md 단독 사실 오류, 「🧠 원리」 블록 ↔ 「시험 직전 요약」 사이의 귀속 층 불일치(AIF에서 반복됐던 유형), 자가 점검 접이식 정답 ↔ 본문의 모순.
- **「시험 직전 요약」 절과 자가 점검 블록을 본문과 1:1로 대조하지 않았다.** AIF의 `aif_doc_format_test.dart`가 그 **존재**는 강제하지만 **내용 일치**는 보지 않는다. 2026-11-05 `aif-t5-1`의 태그 접두사 사례(원리 블록은 맞고 요약·자가 점검이 사실처럼 적음)가 바로 이 틈에서 나왔다.
- **공식 시험 가이드 본문 ↔ 문항 `skill` 태그의 의미 정합**을 보지 않았다. 번호 실재는 `aif_questions_test.dart`가, MLA의 K·SK 범위·커버리지는 `mla_questions_test.dart`가 기계로 본다. **번호는 맞지만 묻는 내용이 그 목표가 아닌 경우**는 둘 다 못 잡고 나도 전수로는 보지 않았다.

### 7-2. 측정 자체의 한계

- **공식 페이지 재대조는 18건**이다. 문항 531개가 인용하는 고유 URL은 842개이고, 전수 **URL 생존**은 확인했지만 **「인용한 사실이 그 페이지에 있는가」는 전수로 확인하지 못했다.** 이 트랙에서 반복된 주된 결함이 바로 그것이라 **가장 큰 구멍이다.** 선정 기준은 ⓐ 숫자·상한·기본값, ⓑ 「유일」·「전용」·「지원하지 않는다」류 단정, ⓒ 재구성·리다이렉트가 확인된 페이지, ⓓ 두 트랙이 같은 사실을 다르게 적는 자리였다.
- **`aws.amazon.com/*/pricing/` 페이지의 요율 표는 검증하지 못했다.** JS로 그려져 본문 추출에 나오지 않는다(레포가 이미 기록한 제약). `mla-t2-1-q16`·`q17`·`mla-t2-1.md`가 그 페이지를 출처로 들지만, 다행히 같은 문항이 **결정 가이드를 둘째 출처로** 들고 거기에 수치가 있어 검증이 가능했다.
- **의미 중복 탐지는 「같은 출처 URL을 공유하는 쌍」만 비교했다.** 같은 사실을 서로 다른 출처로 적은 중복은 이 방법으로 안 잡힌다. 임계값(`correctJ≥0.33`)도 경험값이고 그 아래에 더 있을 수 있다 — §3-3의 ③과 §3-3의 ④는 임계값 아래였고 **사람이 읽다 찾았다.**
- **AIF md 출처 114개를 이번에 따로 재지 않았다.** 842개 전수 실측에 포함돼 있으므로 생존은 확인됐지만, 2026-11-06 배치가 발견한 유형(「md 출처만 403」)은 그 배치가 이미 닫았고 이번 측정에서도 재발 0이었다.

### 7-3. 내 판정이 틀렸다가 바로잡힌 자리 — **이 레포에서 가장 값이 큰 기록**

네 건 있었다. 넷 다 **대조군이나 두 번째 방법이 잡았다.**

1. **⚠️⚠️ URL 842개를 「전부 죽었다」로 측정했다.** 첫 회차가 `000 r=0`을 842건 돌려줬다. 포그라운드 단건 실행은 `200 r=0`이 나와 모순이었고, 원인은 **내가 Python으로 쓴 `urls.txt`가 Windows 텍스트 모드라 줄끝이 CRLF**였던 것이다(`od -c`로 `\r\n` 확인). 각 URL에 `\r`이 붙어 curl이 전부 실패했다. **대조군 3개를 입력에 직접 echo로 섞어 둔 것이 이것을 갈랐다** — 대조군은 성공하고 파일에서 읽은 것만 전멸했기 때문이다. 대조군이 없었다면 「출처 842개 전멸」이라는 보고를 썼을 것이다.
   → **교훈: `num_redirects` 규율에 「입력 파일의 줄끝」을 더한다.** `tr -d '\r'`를 전처리에 고정한다.
2. **⚠️ 「MLA의 배치 추론 50% 절감은 블로그에만 있는 수치」로 판정하려 했다.** AIF가 같은 숫자를 「공식 **블로그**가 **일부 모델에서**」로 조심스럽게 귀속하는데 MLA는 결정 가이드와 요금 페이지를 들고 평서문으로 적어서, 「인용한 사실이 그 페이지에 없다」 유형으로 보였다. **결정 가이드를 실제로 읽으니 Pricing 절에 "Batch inference offers up to 50% savings for non-real-time workloads"가 그대로 있었다.** MLA가 맞다. → **교훈: 「그 페이지에 없다」는 그 페이지를 읽은 뒤에만 쓴다.** 두 트랙의 귀속 정밀도 차이는 결함의 신호가 아니다.
3. **⚠️ 「Clarify 언급 문항 14개에 상태 한 줄이 없다」로 셀 뻔했다.** 전수 분류를 해 보니 그중 **11개는 편향 지표의 정의·공식만 묻는 문항**이어서 서비스 가용성과 무관했고, 상태를 달면 **틀린 보기를 설명하는 문장**이 된다(MLA 가드 주석이 Model Monitor에서 이미 기록한 함정 그대로다). 실제 대상은 **3개**였다(§5 P3-M2). → **교훈: 「언급 수」와 「해법으로 가르치는 수」는 다르다.** 보고의 개수를 믿지 않는다는 규율이 내 자신의 중간 집계에도 적용된다.
4. **⚠️ 「`help-panel` 콘솔 도움말 출처는 MLA가 금지하는데 AIF가 쓴다」로 판정하려 했다.** `mla_questions_test.dart`에 `expect(srcs25.contains('help-panel'), isFalse)`와 「콘솔 도움말 패널 URL은 출처로 쓰지 않는다」 주석이 있어 전역 정책으로 읽었다. **`grep` 전수로 세니 DEA 3문항·MLA 1문항(`mla-t3-1-q16`)·AIF 1문항이 쓰고 있었다** — 그 가드는 `mla-t3-3-q25` **한 문항에만 걸린 국소 규율**이고, AIF의 사용은 G-45가 「CPT 정본 슬러그가 죽어 콘솔 도움말과 boto3 유효값이 정본」이라고 기록한 **문서화된 판정**이었다. **결함이 아니다.** → **교훈: 가드 하나를 레포 정책으로 일반화하기 전에 다른 자격증을 세어 본다.**

### 7-4. 다음 검토자에게 넘기는 것

1. **인용 내용 전수 대조**(§7-2 첫 항목)가 남은 가장 큰 구멍이다. 842개 전부는 비싸므로, **숫자·상한·기본값·「유일/전용/미지원」 단정을 담은 문항**으로 범위를 좁혀 기계로 뽑고(패턴은 `mdscan.py`를 문항에 돌리면 된다) 그 집합만 전수 대조하는 것을 권한다.
2. **AIF md의 「시험 직전 요약」·자가 점검 ↔ 본문 대조**(§7-1 두 번째)는 이 트랙에서 세 번 결함이 나온 자리다. `aif_doc_format_test.dart`가 절의 존재만 보므로 사람이 봐야 한다.
3. **MLA 전파 가드 신설**(§5 P3-M5)은 §2 P1-M1과 같은 누출을 기계로 막는다. 첫 규칙은 「Mechanical Turk」로, SOA 판의 `_nameRules`(문항 전체를 보는 명칭 규칙)와 `_factRules`(사실 영역만 보는 규칙) 분리를 그대로 가져오면 된다.
