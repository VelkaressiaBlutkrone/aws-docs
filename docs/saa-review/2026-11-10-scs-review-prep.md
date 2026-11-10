# SCS-C03 문항 검수 — 착수 이관 노트 (2026-11-10)

> 대상: **사람 검수자(사용자)**. **`verified` flip은 사람만 한다**(AI flip 금지).
> 공정 운영 가이드는 [review-rubric.md](review-rubric.md)가 정본이고(2026-11-10에 **일곱 자격증**으로 넓혔다) 이 노트는 **SCS-C03 전용 실측·주의**다.
> 저작 경위는 [HANDOFF.md](../../HANDOFF.md) §0-2026-11-08-d ~ §0-2026-11-10-e, 판정·갭은 `docs/content-research/SCS-C03/` **8편**이 정본이다.

---

## 0. 지금의 사실 (2026-11-10 실측, main `cf53f96`)

| 항목 | 값 |
|---|---|
| 학습문서 | **16/16편** (공식 Task 1:1) |
| 문항 | **240개** (전 Task 15) · **전부 `verified: false` 드래프트** |
| 도메인별 Task | D1 3 · D2 2 · D3 3 · D4 2 · D5 3 · D6 3 |
| 기술 커버리지 | 공식 기술 **70개 전부** 최소 1문항 |
| 구조·정합성 플래그 | **0건** (`prescreen.mjs`, 문항 240 · 뱅크 16) |
| 출처 URL | 고유 **171개 전부 `200 r=0`** (문항 153개는 md 171개의 부분집합) |
| 중복·겹침 | 임계 0.33 이상 **0건** (최고 0.242) |
| readiness 정책 | ✅ 있음 — **6키** `{1:16, 2:14, 3:18, 4:20, 5:18, 6:14}` |
| flip 선결 | ✅ **0건** (§2) |

```sh
# 수치 재측정 — flutter_app에서
node tool/review.mjs build scs        # 검수 뷰어 → build/scs_review/index.html
node tool/prescreen.mjs build scs     # 구조 플래그 → build/scs_review/*.prescreen.json
flutter test                          # 기준선은 CLAUDE.md 빌드·테스트 절이 정본
```

---

## 1. 게이트 산술 — 몇 Task를 flip하면 열리나

공개 게이트는 **도메인별 weighted capacity**다(`certExamHasWeightedCapacity`). 65문항 연습 세트에 공식 비중을 `allocateByWeight`로 배분한 수량 이상을 **도메인마다** 채워야 한다.

| 도메인 | 비중 | 필요(65 배분) | 저작된 Task | 보유 최대 | 필요 Task 수 |
|---|---|---|---|---|---|
| D1 모니터링·로깅 | 16% | **10** | 3 | 45 | **1** |
| D2 인시던트 대응 | 14% | **9** | 2 | 30 | **1** |
| D3 인프라 보안 | 18% | **12** | 3 | 45 | **1** |
| D4 ID·액세스 관리 | 20% | **13** | 2 | 30 | **1** |
| D5 데이터 보호 | 18% | **12** | 3 | 45 | **1** |
| D6 보안 기반·거버넌스 | 14% | **9** | 3 | 45 | **1** |

⭐ **필요치의 최대가 13(D4)이고 한 Task가 15문항이므로 도메인마다 하나씩 — `6 Task 90문항`이면 열린다.** SOA(5 Task 75문항)·AIF(7 Task 105문항)와 비교하면 **가장 적은 수로 열리는 자격증**이다.

⚠️ **부분 flip은 「열림」이 아니다.** Task 하나만 flip하면 `certHasVerifiedQuestions`가 true가 되어 **약점 모의고사 줄이 잠긴 채로 노출**되고 통합 모의고사는 「준비 중」으로 남는다. **도메인 하나라도 미달이면 닫힌 채다.**

⚠️ **SCS는 이 레포의 첫 6도메인 자격증이다.** 5키를 전제한 코드가 어딘가 남아 있으면 그 자리에서 드러난다 — 그것을 잡기 위해 `mock_exam_test`에 **6키 배분 합 불변식**을 따로 뒀다.

**권장 순서(비중 큰 쪽부터, 게이트는 아니다):** D4 20% → D3·D5 18%(동률) → D1 16% → D2·D6 14%(동률).

---

## 2. ⚠️ flip 선결 — **실측 0건**

다른 자격증에서 사람의 첫 flip을 죽였던 자리를 **문항 저작 전에** 전부 세워 뒀다. `flip`은 파일을 **다 쓴 뒤** 마지막에 `cert.tests`를 돌리므로(`--force`는 **쓰기 전** 구조 검사만 건너뛴다) 이 선결이 없으면 명령이 레드로 끝나고 파일은 바뀐 상태로 남는다.

| 선결 | SCS 상태 | 과거 사고 |
|---|---|---|
| `flipAllowlist` 등록 | ✅ `CERTS.scs.flipAllowlist` → `scs_questions_test.dart`의 `flipApprovedTaskIds` | MLA #246 · SOA·DEA #285가 **파일을 다 쓴 뒤** 레드 |
| 「전 문항 드래프트」 전수 단정 | ✅ 없음 — 허용 목록 **밖** Task만 드래프트를 요구하는 계약 | `soa_questions_test`·`dea_questions_test`가 전수 단정이라 걸렸다 |
| locked 선언 | ✅ **합성 빈 엔트리**(`entries: const []`)라 실제 flip 상태와 무관 | SAA #266에서 `'현재는 locked'`가 flip을 실패시켰다 |
| `review.test.mjs` `preAuthoring` | ✅ 도메인 1 배치에서 제거 | 안 지우면 CI node 단계가 **1초 만에** 레드 |
| `content_index` 등재 | ✅ 16 Task 전부 `questionCount: 0` — `cmdFlip`이 `setQuestionCount`로 갱신 | 미등재면 `setQuestionCount`가 조용히 아무것도 안 한다 |
| readiness 정책 | ✅ 6키 등재 | 정책이 없으면 `hasPolicy: false`로 **fail closed** — 전 문항 flip에도 영원히 잠김 |
| 「잠긴 cert」 표본 | ✅ SCS를 표본으로 쓰는 테스트 **0건**(`debugContentIndexOverride`로 열린 cert를 쓴다) | 표본이 SAA → MLA → DEA로 두 번 이사한 끝에 구조적으로 해소됐다 |

`cert.tests` = `scs_questions_test.dart` · `scs_doc_format_test.dart` · `content_index_test.dart`. ⚠️ **flip 뒤에는 전체 스위트를 한 번 돌린다** — `cert.tests`에 없는 테스트가 깨지는 사고가 SOA에서 있었다(`soa_v11_topics_test`).

⚠️ **AI는 `verified: true`를 콘텐츠에 쓰지 않으므로 「실제로 flip해 보는」 시뮬레이션을 하지 않았다.** 대신 ① 위 일곱 자리를 소스로 전수 확인하고 ② 허용 목록 판정을 순수 함수로 뺀 `flip_allowlist_test.dart`가 **합성 입력으로 네 분기**(목록 밖+드래프트 / 목록 밖+verified / 목록 안+verified / 목록 안+미flip)를 짚게 해 뒀다.

---

## 3. AI가 이미 끝낸 준비

⭐ **T2 의미·출처 1차 패스가 2026-11-10에 끝났다** — 240문항 전수 판정이 `docs/saa-review/prescreen/scs-t*.json` 16편에 있고 요약은 [2026-11-10-scs-t2-prescreen.md](2026-11-10-scs-t2-prescreen.md)다. `pass` **228** · `review` **10** · `resource` **2**이고 **C1(정답 오류)은 0건**이다. 걸린 12건은 전부 **C4 출처 축**이다. ⚠️ 그 패스는 C1을 보증하지 않는다 — 검수자가 뷰어에서 직접 판정한다.

| 항목 | 결과 |
|---|---|
| 구조 전수 사전심사 | `prescreen.mjs build scs` — 문항 플래그 **0건** · 뱅크 플래그 **0 Task** |
| 출처 URL 전수 실측 | 고유 **171개**(문항 153 + md 전용 18) 전부 **`200 r=0`** · 대조군 셋 재현 |
| 중복·겹침 스캔 | 출처 공유 쌍 **232개**(대조군) · 완전 동일 **0** · 임계 0.33 이상 **0건** |
| 전파 가드 | `scs_question_propagation_test.dart` **신설**(트립와이어) + 전역 명칭 규칙의 구멍 메움 |
| 루브릭 | **일곱 자격증**으로 확장 + 낡은 서술 4건 정정 |
| 도구 사용법 | `prescreen.mjs`의 자격증 목록을 **CERTS에서 유도**(하드코딩이 aif·scs를 빠뜨리고 있었다) |

### ⚠️⚠️ 전역 명칭 규칙에 SCS 240문항이 빠져 있었다

`mla_aif_question_propagation_test.dart`의 머리말은 **「명칭에는 자격증 경계가 없다 → 범위를 레포 전역 문항으로 둔다」**고 선언하는데, 그 범위가 `['clf','saa','soa','dea','mla','aif','dva']` **하드코딩**이라 **그 뒤 들어온 `scs`가 빠져 있었다.** `assets/content` 디렉터리에서 **유도**하도록 바꿨고(다음 자격증은 첫 커밋부터 자동으로 덮인다) 「SCS 문항이 전역 검사에 들어왔다」는 대조군을 더했다.

⚠️ **메운 것은 결함이 아니라 구멍이다** — 실측 시점의 위반은 **0건**이었다(「미세조정」·「파인튜닝」을 여덟 자격증 md·문항 전수로 세서 전부 0).

### ⚠️ SCS에 사실 가드가 없는 것은 누락이 아니다

`scs_question_propagation_test.dart`의 `_factRules`·`_nameRules`는 **비어 있고 그 이유를 적어 뒀다.** SCS 가드는 셋인데 `scs_doc_format_test.dart`의 **도메인별 저작 규율**이 `authoredTextOf`로 **md와 `.questions.json`을 합쳐** 읽으므로(2026-11-10에 넓혔다) 금지 문장이 이미 문항까지 쓸린다. 옮겨 올 규칙이 없다.

⭐ 그래서 그 파일의 값은 **트립와이어**다 — 새 `test/scs_*` 가드가 생기면 깨져서 「그 가드가 문항까지 쓸었는지 확인하고, 아니면 규칙을 옮기고 등록하라」고 알린다. 같은 장치를 DEA에 심었고 **2026-11-06에 실제로 울려** 규칙 둘을 옮겼다.

---

## 4. 관찰 둘 — **①은 닫혔고 ②는 그대로 둔다**

### ① ✅ 난이도 쏠림 — **보정 완료**(2026-11-10, §0-2026-11-10-g)

발견 당시 **도메인 5·6의 6 Task가 `foundational` 0~1개**였고 `scs-t5-1`·`scs-t6-2`는 **0개**라 그 Task에 진입용 문항이 하나도 없었다(D1~D4는 2~5). 사용자 지시로 **14건을 `applied` → `foundational`**로 바꿨다.

| 자격증 | `foundational` 비율 |
|---|---|
| CLF-C02 | 76.1% |
| SAA-C03 | 46.1% |
| AIF-C01 | 34.8% |
| SOA-C03 | 31.7% |
| MLA-C01 | 29.6% |
| **SCS-C03** | **22.5%** (54/240) ← 보정 후 |
| DEA-C01 | 15.6% |

보정 후 **Task당 2~5**이고 2개 미만인 Task는 없다. ⭐ 재발 방지 가드가 `scs_questions_test.dart`에 있다 — 「Task 마다 `foundational` 최소 **2**개」(하한 2는 D1~D4의 최솟값 `scs-t4-1`·`scs-t4-2`를 실측한 값이고 **상한은 두지 않는다**).

⚠️ **검수자가 알아야 할 선정 기준** — 라벨을 바꾸기 전에 **기존 40건의 지문을 전수 읽어** 이 자격증의 기준을 역산했다. **`foundational`은 회상·분류형**(「공식 서술로 올바른 것은」·「올바르게 짝지은」·「올바르게 가른」)이고 **`applied`는 상황을 진단해 설계를 고르는** 쪽이다. **「시나리오가 있으면 applied」가 아니다** — 기존 40건 중 여럿이 얇은 시나리오를 깔고도 `foundational`이다. 바뀐 14건은 `scs-t5-1` q6·q12·q15 / `scs-t5-2` q6·q8 / `scs-t5-3` q8·q14 / `scs-t6-1` q3·q14 / `scs-t6-2` q4·q8·q12 / `scs-t6-3` q3·q8이고, **본문·정답·`verified`는 한 글자도 바뀌지 않았다**(`difficulty` 키를 뺀 문서가 변경 전후 완전히 동일함을 기계로 단정했다).

### ② 정답 인덱스가 3번에서 구조적으로 적다 — **그대로 둔다**

자격증 전체 **63 / 65 / 66 / 46**. 원인은 파일마다 **4/4/4/3**을 쓰기 때문이고(16파일 × 3 = 48이 상한) AIF도 같은 모양이다(55/56/57/42).

⚠️ **고치지 않는다.** 루브릭이 명시한다 — 앱은 보기 순서를 문항별로 섞어 내보내므로(`mock_exam.dart`의 `randomOptionOrders`·`applyOptionOrders`, 퀴즈·오답노트·모의고사 전 경로) **JSON의 `correct` 인덱스는 학습자에게 보이지 않고, 정답 위치를 옮기려고 문항을 고치지 않는다.**

Task별로는 **14/16이 4/4/4/3**이고 둘만 다르다(`scs-t1-2` 3/5/5/2 · `scs-t1-3` 4/4/5/2 — 도메인 1 배치의 재배치 잔재). 어느 인덱스도 지배하지 않으므로 작성 편향 신호는 아니다.

### ③ 중복 스캔 상위 쌍 — 사람이 읽을 몫

⚠️ **지표는 하한이다** — 표현이 다르면 임계를 넘지 않는데 같은 사실을 묻는 실제 중복이 있다(2026-11-06 AIF에서 6쌍 중 **2쌍**이 그랬다). 임계 이상은 0건이지만 상위 쌍은 눈으로 본다.

| 자카드 | A | B | 같은 Task | 공유 출처 |
|---|---|---|---|---|
| 0.242 | `scs-t1-2-q9` (1.2.4) | `scs-t2-2-q5` (2.2.2) | - | `AnalyzingLogData.html` |
| 0.203 | `scs-t1-2-q7` (1.2.3) | `scs-t3-1-q14` (3.1.4) | - | `custom-sources.html` |
| 0.177 | `scs-t1-1-q15` (1.1.5) | `scs-t6-3-q5` (6.3.1) | - | `conformance-packs.html` |
| 0.175 | `scs-t2-1-q6` (2.1.2) | `scs-t2-1-q7` (2.1.2) | O | `ddos-advanced-summary.html` |
| 0.172 | `scs-t1-2-q9` (1.2.4) | `scs-t1-2-q10` (1.2.4) | O | `AnalyzingLogData.html` |
| 0.169 | `scs-t1-2-q11` (1.2.4) | `scs-t2-1-q5` (2.1.2) | - | `what-is-securityhub.html` |
| 0.167 | `scs-t3-2-q5` (3.2.3) | `scs-t3-3-q15` (3.3.5) | - | `findings-types.html` |
| 0.164 | `scs-t6-1-q10` (6.1.4) | `scs-t6-1-q11` (6.1.4) | O | `orgs_integrate_delegated_admin.html` |
| 0.162 | `scs-t1-2-q4` (1.2.2) | `scs-t1-2-q5` (1.2.2) | O | `creating-trail-organization.html` |
| 0.159 | `scs-t3-3-q4` (3.3.2) | `scs-t3-3-q5` (3.3.2) | O | `VPC_VPN.html` |

⭐ **같은 기술 번호의 인접 쌍**(`t2-1-q6`/`q7` 등)은 같은 출처를 다른 각도에서 묻도록 설계한 것이고, **다른 Task 쌍**(상위 셋)은 Security Hub·Config·Security Lake처럼 **여러 작업에 걸치는 서비스**다 — 둘 다 겹침 자체로는 결함이 아니다.

---

## 5. SCS 고유 — 검수에서 특히 볼 자리

### ⚠️⚠️ 닫힌·프리뷰 서비스의 상태 표기가 가드로 묶여 있다

공식 시험 가이드가 **예시로 드는 서비스·기능 중 다섯이 닫혀 있거나 프리뷰**다. `scs_doc_format_test.dart`의 도메인별 저작 규율이 md와 문항을 **합쳐** 보며 상태 표기를 강제한다.

| 트리거 | 요구 | 왜 |
|---|---|---|
| `Audit Manager` | 「신규 고객」 | `기술 6.3.2`의 예시 서비스가 **신규 고객에게 닫혔다**(그리고 **준수를 평가하지 않는다**) |
| `AppRegistry` | 「신규 고객」 | **기능만** 닫혔다 — `Service Catalog` 본체는 정상(트리거를 본체로 넓히면 멀쩡한 서비스를 닫힌 것으로 가르친다) |
| `저장소 잠금`·`Vault Lock` | 「신규 고객」 | `기술 5.2.2`의 예시가 **2012년 REST API 기반 독립 Glacier 서비스**의 기능이다. **S3 Glacier 스토리지 클래스는 정상** |
| `메시지 데이터 보호` | 「신규 고객」 | `기술 5.3.4`의 두 예시 중 하나. 축은 **CloudWatch Logs 데이터 보호 정책** |
| `DataSync Discovery` | 「지원 종료」 | **기능만** 종료(2025-05-20). DataSync 본체는 정상 |
| `Well-Architected Agent` | 「프리뷰」 | `기술 6.3.3`이 드는 「도구」가 **Tool·Agent 둘로 갈렸다**. 묻는 쪽은 **Tool** |
| `사전 평가` | 「막지 않」·「차단하지 않」 | **Config 사전 평가는 배포를 막지 않는다**(공식 Note) |
| `사전 제어` | `preCreate` | Control Tower 사전 제어는 막지만 **`preCreate`·`preUpdate` 후크라 CloudFormation 경로 한정**이다 |
| `적합성 팩` 금지 | 정본 「준수 팩」 | SCS 공식 가이드 표기다(AWS Config 한국어 제품 문서의 기계 번역 표기와 다르다 — D-11) |

⚠️ **두 「사전」을 섞으면 어느 쪽이든 거짓이 된다** — 검수에서 가장 자주 흔들릴 자리다.

⚠️ **상태 메모는 「가르치는 층」에만 있다**(`skill`·`stem`·정답 보기·`explanation`). 닫힌 서비스 이름이 **오답 보기를 반박하는 문장에만** 나올 때 상태를 달면 **그 상태가 그 보기를 틀리게 만든 이유처럼** 읽혀 거짓이 된다 — 2026-11-10 도메인 6 배치에서 그 판단으로 두 문항을 그대로 뒀다(`scs-t6-3-q7`·`q15`).

### ⚠️ 개수를 묻지 않기로 한 자리 셋

공식 문서 **내부가 어긋나** 수를 단정할 수 없는 자리다. 검수에서 「왜 개수를 안 묻나」로 읽히지 않게 적어 둔다.

- **S3 서버 측 암호화 선택지** — 본문은 `four mutually exclusive options`인데 같은 페이지의 소제목은 **다섯**(SSE-FSX 포함). (D-16)
- **VPC 엔드포인트 유형** — docs 개념 페이지(`Tunnel` 포함)와 PrivateLink FAQ(`five different types`)가 다르다. 고정할 축은 **「게이트웨이 엔드포인트만 PrivateLink를 쓰지 않는다」**. (D-16)
- **선언적 정책 유형** — 전용 페이지 `Topics`·정책 관리 페이지 불릿·요약 표가 **세 곳에서 다르다**. (G-66)

### ⏳ 열린 갭 — 그 수치를 묻는 문항은 아직 만들 수 없다

- **G-31** — `Athena` · `OpenSearch Service` · `Lambda` · `Managed Grafana`의 전용 페이지를 재지 않았다. 지금 문항은 **층 배치와 「질문의 모양」**만 묻는다.
- **G-32** — 서비스별 상태 확인의 기본값·임계값을 재지 않았다. 지금 문항은 **확인 순서**만 묻는다.
- **G-75** — 재지 않고 층 설명으로만 둔 일곱.
- **D-13 · G-33** — `AWS Security Incident Response`는 **어느 공식 범위 목록에도 없어** 범위 메모로 구조만 소개하고 **문항으로 만들지 않았다**.

---

## 6. 도구와 프로토콜

```sh
cd flutter_app
node tool/review.mjs build scs              # 뷰어(정답 강조·쏠림 배지) — 커밋하지 않는다
node tool/prescreen.mjs build scs           # 구조 플래그 — 커밋하지 않는다
node tool/review.mjs flip scs scs-t4-1      # ⚠️ 사람만. 허용 목록 추가까지 대신 해 준다
flutter test                                # flip 뒤 전체 스위트를 한 번
```

- **flip 단위 = Task**이고 그 Task의 **전 문항**이 통과해야 한다.
- `flip`은 ① 구조 플래그 검사 → ② `verified` 전환 → ③ `content_index` `questionCount` 갱신 → ④ `flipApprovedTaskIds` 추가 → ⑤ `cert.tests` 실행 순이다. **커밋은 검수자가 직접 한다**(그 diff가 사람의 서명이다).
- 판정·수정 루프와 루브릭 C1~C6은 [review-rubric.md](review-rubric.md)를 쓴다.

---

## 7. 환경 함정 (이 트랙에서 반복해 걸린 것)

메모리 `repo-toolchain-gotchas`가 정본이고 검수에서 다시 밟을 것만 옮긴다.

- **이 환경의 콘솔은 cp949다** — 파이썬 스크립트가 한국어·em dash를 stdout에 쓰면 성공한 뒤에 `UnicodeEncodeError`로 죽어 **실패처럼 보인다.** 진단은 파일로 쓴다.
- **치환 앵커의 줄 끝은 `\r\n`이다** — 레포 md·Dart·JSON이 전부 CRLF다. `\n` 앵커는 **0건으로 조용히 막힌다**(이 노트를 만들며 또 밟았다).
- **문항 JSON은 `json.dumps` 왕복이 가능하다** — SCS는 `indent=2` + CRLF로 **바이트 단위 재현**된다(실측). ⚠️ 다만 **서식은 자격증이 아니라 파일마다 실측한다** — SAA는 `sources`가 한 줄 압축이고 CLF는 다중 행이다.
- **`docs.aws.amazon.com`은 없는 페이지에도 404를 주지 않는다** — 판정 신호가 **세 갈래**다(살아 있으면 `200 r=0` / 있는 가이드의 없는 슬러그는 `200 r=1` → 인덱스 / 없는 가이드 접두사는 진짜 `404 r=0`). ⚠️ `curl`에 **`-sL`이 없으면 `num_redirects`가 항상 0**이다.
- **`py`를 쓴다** — `python`은 exit 49, `python3 -V`는 node 버전을 뱉는다. Windows 파이썬이라 **`/tmp`를 못 본다.**
- **「없다」를 말하기 전에 대조군을 세운다** — 0건이 「문제 없음」이 아니라 **탐지기가 죽은 것**일 수 있다(`grep -P` 실패 · 어형 한 글자 차이 · 표 구조로만 적힌 사실).
