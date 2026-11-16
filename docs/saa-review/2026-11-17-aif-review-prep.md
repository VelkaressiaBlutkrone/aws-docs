# AIF-C01 문항 검수 — 착수 이관 노트 (2026-11-17)

> 대상: **사람 검수자(사용자)**. **`verified` flip은 사람만 한다**(AI flip 금지).
> 공정 운영 가이드는 [review-rubric.md](review-rubric.md)가 정본이고 이 노트는 **AIF-C01 전용 실측·주의**다.
> 저작 경위는 [HANDOFF.md](../../HANDOFF.md) §0-2026-11-03 ~ §0-2026-11-07, 판정·갭은 `docs/content-research/AIF-C01/` 가 정본이다.
> ⚠️ **AIF는 이미 부분 flip 상태다** — 2026-11-13에 `aif-t1-1` 15문항이 flip됐고(`6d20b0d`) 라이브는 **D1만 충족한 채 모의고사가 잠긴 중간 상태**다. 그래서 이 노트는 「처음 여는 자격증」이 아니라 **「중간 상태를 닫는」 노트**다.

---

## 0. 지금의 사실 (2026-11-17 실측, `develop` = `main` = `4c20791`)

| 항목 | 값 |
|---|---|
| 학습문서 | **14/14편** (공식 Task 1:1) |
| 문항 | **210개** (전 Task 15) · **verified 15** (`aif-t1-1`) · 나머지 13 Task 195문항 드래프트 |
| 도메인별 Task | D1 3 · D2 3 · D3 **4** · D4 2 · D5 2 |
| 목표 커버리지 | 가이드 `knowledge` **69개** ↔ 문항이 덮는 번호 **69개** |
| 구조·정합성 플래그 | **0건** (`prescreen.mjs`, 문항 210 · 뱅크 14) |
| 품질 신호 | **194/210 (92%)** — `length-cue` 132(63%) · `meta-phrasing` 173(82%) · `authoring-memo` 2 · `explanation-long` 3 |
| 출처 URL | 고유 **185개** — ⚠️ **죽은 것 2건** · ⚠️ **md 프런트매터 밖 15개**(G-84 위반) |
| 중복·겹침 | ⚠️ **임계 0.33 이상 3쌍** + 0.3대 2쌍 (§3-①) |
| 난이도 | `foundational` **73/210 (34.8%)** · Task당 5~6 (쏠림 없음) |
| 정답 인덱스 | **55 / 56 / 57 / 42** |
| readiness 정책 | ✅ 5키 `{1:20, 2:24, 3:28, 4:14, 5:14}` · 연습 세트 65 |
| flip 선결 | ✅ **0건** (§2) |

```sh
# 재측정 — flutter_app에서
node tool/review.mjs build aif        # 검수 뷰어 → build/aif_review/index.html
node tool/prescreen.mjs build aif     # 구조 플래그 + 품질 신호
flutter test                          # 기준선은 CLAUDE.md 빌드·테스트 절이 정본 (2026-11-17: 3,737 그린)
```

⚠️ **AIF 가이드는 목표를 `knowledge`에 담는다**(`skills`는 0개). AIP는 반대이므로(`skills` 98 · `knowledge` 0) 다른 자격증의 스크립트를 베끼면 **번호 집합이 빈 집합이 되고 커버리지 단정이 공허해진다**.

---

## 1. 게이트 산술 — 추가 **6 Task 90문항**

| 도메인 | 비중 | 필요(65 배분) | 현재 verified | 저작 Task | 추가 필요 Task |
|---|---|---|---|---|---|
| D1 AI/ML 기초 | 20% | **13** | **15** ✅ | 3 | **0** (`aif-t1-1` 완료) |
| D2 GenAI 기초 | 24% | **16** | 0 | 3 | **2** |
| D3 FM 애플리케이션 | 28% | **18** | 0 | 4 | **2** |
| D4 책임 있는 AI | 14% | **9** | 0 | 2 | **1** |
| D5 보안·규정 준수·거버넌스 | 14% | **9** | 0 | 2 | **1** |

⭐ **합 7 Task 105문항이면 열리고 D1은 이미 끝났으니 남은 것은 6 Task 90문항**이다. ⚠️ **D2 16·D3 18이 한 Task(15)를 넘어** 그 둘만 2 Task씩 필요하다.

⚠️⚠️ **지금의 중간 상태를 오래 두지 않는 편이 좋다.** 부분 flip은 `certHasVerifiedQuestions`를 true로 만들어 **약점 모의고사 줄이 잠긴 채 노출**되고 통합 모의고사도 잠겨 있다(루브릭 「부분 flip은 열림이 아니다」). **6 Task를 묶어 flip하면 그 상태가 끝난다.**

---

## 2. ⚠️ flip 선결 — **실측 0건** (두 층으로 확인했다)

**① 소스 전수 스캔** — `test/*.dart` 가운데 AIF를 언급하는 파일에서 `verified`와 `false`가 같은 줄인 곳은 5건이고 **전부 주석**이다(`expect`가 아니다). 즉 「전 문항 드래프트」를 단정하는 자리가 없다.

**② 게이트 개방 시뮬레이션** — `content_index.dart`의 `questionCount`를 임시로 채워(t1-1 + t2-1·t2-2 + t3-1·t3-2 + t4-1 + t5-1 = 7 Task 105) **게이트를 실제로 연 뒤** 전체 스위트를 돌렸다. 실패는 **1건**뿐이고 그것은 `content_index_test`의 「questionCount == JSON verified 수」 불변식 — **시뮬레이션 산물**이다(실제 `flip`은 둘을 함께 갱신한다). 시뮬레이션은 sha256 일치로 원복했다.

> 게이트가 `questionCount`를 읽는다는 근거: `examWeightedCapacityStatus`가 `entry.questionCount`를 도메인별로 합산하고(`content_index.dart:930`) `ready = hasPolicy && deficitByDomain.isEmpty`(`:179`)다.

**그 밖의 자리도 전부 정상이다.**

| 자리 | 상태 |
|---|---|
| `flipAllowlist` | ✅ `aif_questions_test.dart`의 `flipApprovedTaskIds` — 현재 `{'aif-t1-1'}`, **`flip`이 자동 추가**한다 |
| `preAuthoring`(`review.test.mjs`) | ✅ 빈 집합 |
| readiness 정책 | ✅ 있음(없으면 `hasPolicy: false`로 fail closed) |
| locked 선언·「잠긴 cert」 표본 | ✅ 2026-10-31 `debugContentIndexOverride`로 구조적 해소 |
| `flipTestFiles('aif')` | **7개** — `cert.tests` 3 + `test/aif_*_test.dart` 6의 합집합 |

⚠️ **그래도 flip 직전에 `flutter test`를 한 번 돌려 그린을 확인하고 시작한다.** 선결 목록은 그 시점의 목록일 뿐이고, 2026-11-13 SCS 첫 flip이 그 전에 없던 대조군 8곳을 깨뜨린 선례가 있다.

---

## 3. ⚠️⚠️ 검수 전에 봐야 할 결함 세 묶음 — **AIF 고유다**

SCS·AIP 노트에는 이 절이 없었다(둘은 중복 0쌍 · 출처 전부 `200 r=0` · G-84 위반 0). **AIF는 그 세 가드가 생기기 전에 저작된 트랙**이라 셋 다 걸린다.

### ① 중복 5쌍 — **조사벗김으로 비로소 드러났다**

⚠️⚠️ 2026-11-07에 「AIF 중복 6쌍 해소」를 했지만 그때는 **원형 토큰만** 셌다. G-63 대로 **조사를 벗긴 변형을 함께** 재니 아래 다섯 쌍이 나오고, **원형으로는 전부 임계 아래**다(0.24~0.30).

| max | 원형 | 벗김 | 쌍 | 판정과 처리 제안 |
|---|---|---|---|---|
| **0.450** | 0.261 | 0.450 | `t5-1-q12` ↔ `t5-2-q6` | ⚠️ **진짜 중복** — 둘 다 「모델 호출 로깅은 기본 비활성 · 같은 계정·리전의 CloudWatch Logs/S3」를 정답으로 말한다. 로깅 **설정 사실**은 `5.1.4`가 소유하므로, `5.2.2`의 `q6`은 지문이 이미 깔아 둔 **CloudTrail과 모델 호출 로깅의 층 구분**(메타데이터 ↔ 본문)으로 정답을 좁히면 갈린다 |
| **0.391** | 0.269 | 0.391 | `t2-2-q11` ↔ `t3-3-q2` | ⚠️ **진짜 중복** — 둘 다 「레이블 없는 도메인 데이터 → 지속적인 사전 훈련」. **경로 선택**은 `2.2.3`이 소유하므로 `3.3.1`은 **데이터 준비·RLHF** 쪽으로 돌린다 |
| **0.360** | 0.259 | 0.360 | `t1-3-q6` ↔ `t2-3-q6` | ⚠️ **거의 중복** — 둘 다 「Bedrock은 서버리스 + 토큰 종량제」이고 후자가 `Priority·Flex·Reserved`를 더 적어 **상위집합**이다. `1.3.3`은 **ML 서비스 성격의 비교축**(SageMaker AI와의 통제 범위 차이)으로 돌리는 쪽이 싸다 |
| **0.314** | 0.297 | 0.314 | `t1-1-q15` ↔ `t3-3-q1` | ⚠️ **진짜 중복** — 둘 다 「FM은 자기 지도 학습으로 입력에서 레이블을 만든다 = 이전 ML과의 구분점」으로 **같은 공식 문장**이다. ⚠️⚠️ **`t1-1-q15`는 verified 라이브**이므로 **드래프트인 `t3-3-q1`을 돌리는 쪽이 싸다** |
| **0.308** | 0.241 | 0.308 | `t2-3-q11` ↔ `t3-2-q9` | ⚠️ **진짜 중복** — 둘 다 「ApplyGuardrail API로 모델 호출 없이 입력·출력 평가」. `2.3.3`(서비스 이점)과 `3.2.3`(프롬프트 위험 완화) 가운데 후자는 **필터 종류·tier 차이**로 돌릴 수 있다 |

⚠️ **`t3-3-q1`·`q2`가 둘 다 다른 Task와 겹친다** — `3.3.1`의 출제 축 자체를 다시 보는 편이 낫다.

⚠️ 그 아래 0.15~0.24대 16쌍은 읽지 않았다. 검수 중 같은 사실이 두 번 나오면 **수치와 무관하게** 그때 판정한다(지표는 하한이고 양방향으로 틀린다 — AIP에서는 0.294가 중복이 아니고 0.167이 중복이었다).

### ② 죽은 출처 URL 2건

`-sL`로 185개를 전수 재서 찾았다(대조군 셋 재현: 있는 가이드의 없는 슬러그 `200 r=1` · 없는 가이드 접두사 `404 r=0` · `aws.amazon.com` 없는 경로 `404 r=0`).

| URL | 신호 | 쓰는 곳 | 처리 |
|---|---|---|---|
| `docs.aws.amazon.com/vector-databases/` | `200 r=1` → **`decision-guides/latest/decision-guides/vector-database-guide.html`** | `aif-t3-1.md` + `aif-t3-1.questions.json` | **이름 변경**이라 도착지로 교체하면 닫힌다 |
| `wellarchitected/latest/framework/sus_sus_region_a2.html` | **`404 r=0`**(리다이렉트조차 없다) | `aif-t4-1.md` + `aif-t4-1.questions.json`(`q6`·`q7`) | ⚠️⚠️ **URL 교체로 닫히지 않는다** — 아래 |

⚠️⚠️ **두 번째는 더 깊은 결함이다.** 슬러그에 `sus_`가 두 번 들어간 오기인데, 고쳐 본 세 후보 가운데 `framework/sus_region_a2.html`과 `sustainability-pillar/sus_region_a2.html`은 **둘 다 가이드 인덱스로 튕기고**(`200 r=1` — 그 가이드에 없다) 실재하는 것은 **`sustainability-pillar/region-selection.html`**(`200 r=0`)뿐이다. 그런데 **문항이 인용하는 사실이 리전 선택과 다르다** — `q6`은 「GenAI가 이 워크로드에 맞는 해법인지 먼저 묻는다」, `q7`은 「양자화·프루닝·증류로 추론 자원을 줄인다」이고 **출처 제목만 `SUS01-BP01`(리전 선택)**이다. 즉 **정본은 Well-Architected GenAI Lens의 지속 가능성 절일 가능성이 높고, 그 페이지가 그 두 문장을 담는지 본문으로 확인한 뒤** 제목까지 함께 고쳐야 한다.

⚠️ `source_url_retired_test`는 이 둘을 잡지 못한다 — **그 가드는 이미 아는 은퇴 URL만 안다.** 새 콘텐츠·미측정 트랙의 출처는 직접 재야 한다.

### ③ G-84 위반 15개 — 문항 출처가 학습문서 출처의 부분집합이 아니다

문항이 인용하는데 **그 학습문서 프런트매터에는 없는 URL**이 15개다(AIP·SCS는 0건). 이것이 「URL은 200인데 그 페이지에 인용 사실이 없다」의 입구다 — 학습문서 저작 때 실측된 대상이 아니었기 때문이다.

```
aws.amazon.com/what-is/data-labeling/                                   aif-t1-1-q10
aws.amazon.com/what-is/structured-data/                                 aif-t1-1-q11
AmazonS3/latest/userguide/object-lock.html                              aif-t5-2-q7
aws-certification/latest/ai-practitioner-01/…-domain2.html              aif-t2-2-q9, q13
bedrock/latest/userguide/evaluation-judge.html                          aif-t3-4-q1
bedrock/latest/userguide/latency-optimized-inference.html               aif-t2-1-q7
lake-formation/latest/dg/what-is-lake-formation.html                    aif-t1-3-q8
prescriptive-guidance/latest/agentic-ai-economics/assessing-costs.html  aif-t3-4-q15
sagemaker/latest/dg/async-inference.html                                aif-t1-1-q8
sagemaker/latest/dg/autopilot-metrics-validation.html                   aif-t1-3-q13, q14
sagemaker/latest/dg/deepar.html                                         aif-t1-1-q12
sagemaker/latest/dg/serverless-endpoints.html                           aif-t1-1-q9
textract/latest/dg/what-is.html                                         aif-t1-2-q12
wellarchitected/latest/agentic-ai-lens/agentops02-bp04.html             aif-t3-4-q13
wellarchitected/latest/agentic-ai-lens/agentperf05-bp02.html            aif-t2-1-q14
```

⚠️ **다섯은 이미 공개된 `aif-t1-1` 문항이 쓴다**(`q8`·`q9`·`q10`·`q11`·`q12`). 처리는 **md 프런트매터와 「출처」 절에 그 URL을 더하는 것**(선례: 2026-11-10 `scs-t1-2-q13`)이고, 삽입은 **`lastVerified:` 바로 앞**이다 — 목록 중간에 최상위 키가 끼면 **파서가 뒤쪽 출처를 조용히 버린다**.

---

## 4. 품질 신호 92%의 의미 — 결함이 아니라 저작 스타일이다

`length-cue` 63% · `meta-phrasing` 82%는 **AIF 저작 시점에 그 가드가 없었기 때문**이다. 비교하면 AIP 0% · MLA 23% · CLF 30% · SAA 42% · DEA 46% · SOA 60% · SCS 90%이고, SCS는 같은 상태를 **일곱 배치**를 들여 227 → 0으로 되돌렸다.

**검수자가 선택할 수 있는 길이 둘이다.**
- **그대로 검수** — 신호는 「사람이 읽을 후보」이고 거짓 양성이 있다. 사실이 맞으면 flip해도 된다.
- **먼저 정비** — 「정답이 최장이라 길이로 답이 보이는」 문항을 SCS처럼 일괄 정리한 뒤 검수. ⚠️ 그때는 **길이 하한도 함께 본다**(정답만 깎으면 반대 방향 단서가 생긴다) 그리고 **「정답 ÷ 1.3」을 먼저 계산**한다(한국어 길이는 눈으로 추정하면 체계적으로 짧다).

Task별 신호 수(15문항 중): `t5-1` **10** · `t4-1` 13 · `t5-2` 13 · `t1-3` 12 · `t1-2`·`t2-2`·`t3-2`·`t3-4` 14 · 나머지 15. ⚠️ **차이가 10~15로 작아 「가장 싼 Task」의 대리값으로는 약하다.**

---

## 5. AIF 고유 — 검수에서 특히 볼 자리

### ⚠️⚠️ 가드가 요구하는 문구를 걷으면 레드다

`aif_facts_test.dart`·`aif_doc_format_test.dart`가 아래를 고정한다. 검수에서 「군더더기」로 보여도 **걷지 않는다**.

- ⚠️⚠️ **「사용자 지정 모델은 프로비저닝 처리량(PT) 없이 쓸 수 없다」류 단정이 aif 학습문서 전수에서 0건**이어야 한다. 경로는 **둘**이다(PT 구매 / 온디맨드 배포). ⭐ 이 오류는 **세 번 고쳤다고 보고된 뒤에도 라이브에 다섯 자리 남아 있었다** — 리터럴 가드가 「프로비저닝**된** 처리량」의 **「된」 한 글자**로 뚫렸기 때문이다. 어형이 갈리는 주장은 **정규식으로** 센다.
- **옛 문구를 인용해 정정하는 줄은 정확히 둘**이고(`아직`이 든 줄) 그 예외가 대조군으로 묶여 있다.
- **「계속 사전 훈련」은 `t3-3`의 번역 메모 한 곳에만** 있고 **문항 파일에는 0건**이다(공식 표기는 「지속적인 사전 훈련」).
- `aif-t3-4`: **사라진 평가자 ID 이름과 「13개」가 없어야** 하고 **현행 세 축**이 남아 있어야 한다.
- 서버리스 커스터마이징의 **토큰당 요금** · 관리형 훈련·추론·HyperPod의 **사용량 기준**이 함께 적혀 있어야 한다.
- 「시험 형식 안내는 `aif-t1-1`에만」 · 학습 목표 ≤8 · 「시험 직전 요약」 절 · 자가 점검 접이식 정답 · 프런트매터 `domainName` = 공식 도메인 페이지 제목.

### ⛔ 묻지 않기로 한 자리 — 피한 것은 누락이 아니다

`docs/content-research/AIF-C01/99-gaps.md`가 정본이고, 머리만 적으면 — **책임 있는 AI 「차원」 개수**(공식이 8과 10으로 갈린다) · **Guardrails 유해 범주 개수**(5와 6) · **AgentCore 정책 언어의 개수·기본값**(Cedar/Dogwood) · **설명 가능성 정의** · **Audit Manager 매핑 표 ↔ Config 템플릿 이름**. ⚠️ 공식 내부가 어긋나는 자리는 **더 구체적인 쪽을 정본으로 삼고 개수를 묻지 않는다**.

### ⚠️ 닫힌 서비스를 공식 문서가 아직 권하는 자리가 있다

ML 렌즈 `MLPERF06-BP02`·`RAIMON01-BP02`·`what-is/ai-bias`가 **SageMaker Clarify를 처방**하는데 Clarify는 신규 고객에게 열려 있지 않다. **게시일이 최신이어도 서비스 상태는 따로 확인**한다.

### ⚠️ `AWS CAF for AI` 가이드는 「소멸」이 아니라 「사람이 열 수 없음」이다

`curl`과 브라우저는 `302`로 ML 렌즈 인덱스로 튕기지만 **AWS 문서 리더로는 본문이 그대로 읽힌다**. 그래서 **인용을 지우지 않고 상태를 적는** 처리를 했다 — 검수에서 「죽은 링크」로 보여도 그 판정이 이미 내려져 있다.

---

## 6. 도구와 프로토콜

```sh
cd flutter_app
node tool/review.mjs build aif            # 검수 뷰어(정답 강조·기계 플래그)
node tool/prescreen.mjs build aif         # 구조 플래그 + 품질 신호 (build/ 산출물, 미커밋)
node tool/review.mjs flip aif aif-t2-1    # ← 사람만. Task 단위, 전 문항 통과 후
flutter test                              # flip 전후 그린 확인
```

- **flip 단위 = Task**이고 그 Task의 **전 문항이 통과**해야 한다. 도메인 전체를 기다리지 않는다.
- `flip`이 하는 일: `verified` 전환 + `content_index`의 `questionCount` 동기화 + `flipApprovedTaskIds` 추가 + `flipTestFiles()`로 `test/aif_*_test.dart` 전부 실행.
- 커밋은 검수 브랜치에 사람이 직접(`aif-review/*` 또는 `content/aif-flip-N` — 2026-11-13 flip은 후자였다).

---

## 7. 환경 함정 (이 트랙에서 반복해 걸린 것)

- ⚠️⚠️ **`cmd > file 2>&1; echo "EXIT=$?"`는 셸의 최종 종료 코드가 `echo`의 것**이라 백그라운드 통지가 **실패를 `exit 0`으로 보고한다**. **파일 안의 `EXIT=` 줄만이 진짜 신호**다(2026-11-16에 실제로 오판 직전까지 갔다). 파이프(`| tail`)도 같은 이유로 종료 코드를 가린다.
- **`py -`(stdin 스크립트)는 REPL로 떨어져 멈춘다** — 스크립트는 **파일로** 쓴다.
- **콘솔이 cp949다** — 진단에 이모지·em dash를 쓰면 `UnicodeEncodeError`로 죽는다. **결과는 파일로 받고 stdout은 ASCII만**.
- **작업 트리는 CRLF다**(blob은 LF). 정규식 앵커에 `$`를 그냥 쓰면 `\r` 앞에서 **안 맞아 0건**이 되고, `.*`는 `\r`을 삼킨다 — `[^\r\n]*` + `\r?$`로 쓴다.
- **한글 바이트 시퀀스를 손으로 적으면 틀린다** — `"…".encode("utf-8")`로 만든다.
- **필드명을 추측하면 0건이 나온다** — `content_index.dart`의 필드는 `taskId:`이고 `id:`로 찾으면 **아무것도 못 찾는다**(`taskId`의 끝은 대문자 `Id`다).
- **「전부 0」·「전부 불일치」는 데이터가 아니라 측정이 눈이 멀었다는 신호다** — 알려진 양성 대조군을 통과시키기 전의 0건은 결과가 아니다.
