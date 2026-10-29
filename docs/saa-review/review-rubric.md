# 문항 검수 루브릭 + 수정 루프 + flip 프로토콜 (T7) — 자격증 공통

> 잠금 플랜 [2026-06-20-saa-rereview-plan](../superpowers/plans/2026-06-20-saa-rereview-plan.md) §5 T7.
> 대상: **사람 검수자(사용자)**. **`verified` flip은 사람만**(AI flip 금지) — 이 문서는 그 사람 공정의 운영 가이드.
> 전제 인프라(완료): T1 사전심사(`saa_prescreen.mjs` — **SAA 전용**)·T3 동적 불변식·T4 공개 게이트·T6 문서 스캔·T8 freeze 가드(**SAA 전용**).
> 검수 뷰어·flip 도구는 **자격증 일반형**이다(2026-10-27): `tool/review.mjs build <cert>` · `flip <cert> <taskId>`
> (`<cert>`: clf·saa·soa·dea·mla). 루브릭 C1~C6과 아래 절차는 **다섯 자격증에 그대로 쓴다** — 자격증 전용 주의(flip이 돌리는 테스트,
> `flipAllowlist` 유무)는 7번 flip 항목에 모아 뒀다. **SOA-C03·DEA-C01 착수 노트**는 [2026-10-29-soa-dea-review-prep.md](2026-10-29-soa-dea-review-prep.md)가
> 정본이다(게이트 산술·flip 선결 단정·표본 문제·환경 함정).

---

## 0. 착수 전 (1회)
1. **릴리스 완료** 확인(develop→main). 검수 인프라가 main에 반영된 상태에서 시작.
2. **freeze 발효**: `git config core.hooksPath .githooks` (1회 설치) → `touch .saa-frozen`. 이후 SAA 콘텐츠 변경은 `saa-review*` 브랜치에서만(가드가 그 외를 차단).
   - ⚠️ **freeze 가드는 SAA 전용이고, 지금도 미설치 상태다**(2026-10-29 재측정): `.githooks/pre-commit`은 `flutter_app/assets/content/saa/**`의 `.md`·`.questions.json`만 보고 마커도 `.saa-frozen` 하나뿐이다. 레포에 `.saa-frozen`이 없고 `core.hooksPath`도 설정돼 있지 않아 **아무 자격증도 현재 동결돼 있지 않다.** MLA·SOA·DEA 검수는 이 가드 없이 진행된다 — 같은 보호가 필요하면 hook의 경로 패턴·마커를 자격증 일반형으로 넓히는 별건 작업이다(미결정).
3. **검수 브랜치**: `git checkout -b saa-review/d1`(도메인별) 등. 다른 자격증은 `mla-review/*`·`soa-review/*`·`dea-review/*` — freeze 가드가 SAA만 보므로 그 브랜치 이름이 가드에 걸리지는 않는다.

## 1. 진행 단위와 공개 게이트

**flip 단위 = Task, 그 Task의 전 문항이 통과해야 한다.** 밀도 요건은 자격증 공통으로 Task당 **≥15문항**(`<cert>_questions_test`의 `minPerTask`)이지만 실제 보유량은 자격증마다 다르다.

| 자격증 | Task | 문항 | Task당 문항(2026-10-29 실측) |
|---|---|---|---|
| SAA-C03 | 24 | 360 | 15 내외 |
| MLA-C01 | 12 | 321 | **22~35** (t1-1 22 · t1-2 23 · t1-3 24 · t2-1 23 · t2-2 28 · t2-3 27 · t3-1 25 · t3-2 23 · t3-3 26 · t4-1 30 · t4-2 35 · t4-3 35) |
| SOA-C03 | 20 | 300 | **전 Task 15** (D1 5 · D2 4 · D3 4 · D4 3 · D5 4 Task) |
| DEA-C01 | 17 | 256 | **t1-1만 16, 나머지 15** (D1 4 · D2 4 · D3 4 · D4 5 Task) |

한 문항의 `fix`가 Task 전체를 묶으므로 **MLA는 한 Task의 검수 묶음이 SAA의 2배 안팎**이고, **SOA·DEA는 SAA와 같은 15문항 묶음**이다.

공개 게이트는 "전 도메인 일괄 flip"이 아니라 **도메인별 weighted capacity**다: 앱의 65문항 연습 세트에 공식 비중을 `allocateByWeight`(floor + 최대 잉여법, 동률은 선언 순서)로 배분한 수량 이상을 도메인별로 채우면 통합/약점 모의고사가 열린다.

| 자격증 | 공식 비중(D1·D2·D3·D4[·D5]) | 필요 수량 = 65 배분 | 현재(2026-10-29 실측) |
|---|---|---|---|
| SAA-C03 | 30 · 26 · 24 · 20 | **D1 19 · D2 17 · D3 16 · D4 13** | ✅ 개방 (360/360 verified) |
| MLA-C01 | 28 · 26 · 22 · 24 | **D1 18 · D2 17 · D3 14 · D4 16** | ✅ 개방 (321/321) |
| CLF-C02 | 24 · 30 · 34 · 12 | D1 16 · D2 19 · D3 22 · D4 8 | ✅ 개방 (301/301) |
| SOA-C03 | 22 · 22 · 22 · 16 · 18 (**5도메인**) | **D1 14 · D2 14 · D3 14 · D4 11 · D5 12** | 🔒 verified **0** — 도메인당 1 Task씩 **5 Task 75문항**이면 열린다 |
| DEA-C01 | 34 · 26 · 22 · 18 | **D1 22 · D2 17 · D3 14 · D4 12** | 🔒 verified **0** — D1·D2는 15 < 필요라 2 Task씩, 합 **6 Task 91문항** |

**권장 순서 = 그 자격증의 비중 큰 도메인부터.** 순서는 권장일 뿐 게이트가 아니다(판정은 수량으로 한다).

| 자격증 | 권장 순서 |
|---|---|
| SAA-C03 | D1 30% → D2 26% → D3 24% → D4 20% |
| MLA-C01 | D1 28% → D2 26% → D4 24% → D3 22% |
| SOA-C03 | D1·D2·D3 22%(동률) → D5 18% → D4 16% |
| DEA-C01 | D1 34% → D2 26% → D3 22% → D4 18% |

수치의 정본은 코드다 — 비중은 `kExamReadinessRequirements`(`lib/data/content_index.dart`), 배분 결과는 `test/content_index_test.dart`가 다섯 자격증 모두 고정하고 있고 비중 자체는 `assets/exam_guides/<cert>.json`과 대조된다(대조 루프가 하드코딩 목록이 아니라 `kExamReadinessRequirements.keys`를 돌므로, 정책을 추가하면 테스트를 빠뜨려도 비중 동기화는 검증된다 — 2026-10-27부터). ⚠️ **정책이 없는 자격증은 fail closed**다(`hasPolicy: false` → `ready: false`) — 문항을 전부 flip해도 잠긴 채 남는다. SOA-C03·DEA-C01은 2026-10-27에 정책을 넣어 이 함정을 풀었고(그 전에는 둘 다 정책이 없었다), 남은 자격증(AIF·AIP·ANS·DOP·DVA·SAP·SCS)은 아직 정책이 없다. **정책 추가는 공개가 아니다** — verified가 0이면 전 도메인이 부족해 게이트는 그대로 잠겨 있다. SAA의 필요/현재 수량표는 [2026-08-06-weighted-ready-batch.md](2026-08-06-weighted-ready-batch.md).

- 라이브 게이트 함수는 **`certExamHasWeightedCapacity`**(= `examWeightedCapacityStatus().ready`)다. 홈 시험 섹션·`cert_detail`·`exam_page`·`cert_exam_page`·`weighted_exam`이 모두 이 함수를 쓴다.
- ⚠️ **옛 게이트 `certExamIsBalanced`("전 도메인에 검증 문항 1개 이상")는 2026-10-20에 코드에서 제거됐다** — 2026-08-06 weighted capacity 게이트가 역할을 대신한 뒤 `lib` 호출이 0이었다. 이 문서의 옛 서술(도메인 일괄 flip·부분 flip 미노출)이 그 함수를 공개 조건으로 적고 있었다. 지금 게이트는 `certExamHasWeightedCapacity` 하나다.
- 도메인 순서는 **권장**일 뿐 게이트가 아니다 — 판정은 순서가 아니라 수량으로 한다. SAA에서는 실제로 D3·D4가 먼저 verified됐고 부족한 쪽이 D1·D2였다(2026-10-28 `t2-5` flip으로 D2를 채워 게이트가 열렸다).
- ⚠️ **부분 flip은 "열림"이 아니다.** Task 하나만 flip하면 `certHasVerifiedQuestions`가 true가 되어 **약점 모의고사 줄이 잠긴 채로 노출**되고 통합 모의고사는 "준비 중"으로 남는다(MLA `t2-2` 단독 flip에서 실측). 도메인 하나라도 미달이면 게이트는 닫힌 채다.
- ⚠️ **flip 선결 — 게이트가 열리는 순간 깨지는 테스트 단정을 먼저 치운다.** `flip`은 파일을 **다 쓴 뒤** 마지막에 `cert.tests`를 돌리므로, `content_index_test.dart`에 상태를 박은 단정이 남아 있으면 flip 명령이 레드로 끝나고 파일은 이미 바뀐 상태로 남는다(`--force`는 **쓰기 전** 구조 검사만 건너뛴다). **순서는 ① 선언 변경 → ② 사람 flip → ③ 커밋**이고, 리터럴로 남길 것은 **정책값뿐**이다. SOA·DEA의 해당 단정 목록은 [착수 노트](2026-10-29-soa-dea-review-prep.md) §2·§3.
- 편향 방지는 수량 게이트가 담당한다. 다만 수량만 채우면 공식 Task Statement 하나가 완전히 빈 조합이 가능하므로(SAA D1의 Task 1.3), 품질 균형은 batch 문서의 리스크 항목으로 관리한다.

### 도메인별 절차
1. **문서 선행(T6)**: 해당 도메인 학습문서의 핵심 오류를 먼저 수정(문항이 문서 파생이므로). 미수정 플래그는 [t6-doc-scan.md](t6-doc-scan.md) 참조.
2. **결정적 사전심사(T1)**: `cd flutter_app && node tool/saa_prescreen.mjs build` → `build/saa_review/<taskId>.prescreen.json`(구조·정합성 플래그). **빌드 산출물이라 커밋하지 않는다**(도구의 `OUT_DIR = 'build/saa_review'`). 플래그 있는 문항 먼저 손본다.
3. **의미·출처 사전심사(T2)**: AI 읽기전용 패스의 주석 아티팩트(의심 정답·약한 출처) → **`docs/saa-review/prescreen/<taskId>.json`**(키 `taskId`·`domain`·`count`·`questions`·`summary`). 2번의 build 산출물과 **다른 파일이며 이쪽은 커밋된다** — 경로가 둘인 것은 불일치가 아니다. *전용 도구는 없다(2026-10-27 실측: `flutter_app/tool/`에 `saa_prescreen.mjs`·`review.mjs` 둘뿐이고, 사전심사는 아직 SAA 전용이다) — 2026-08-06 AI 패스 산출물이 그 경로에 들어 있고, 없는 Task는 4번 뷰어로 직접 검수한다.* 판정값 `pass`/`review`는 **참고용**이고 최종 판정은 사람이 한다.
4. **검수 뷰어**: `node tool/review.mjs build <cert>` → `build/<cert>_review/index.html`(정답 강조·기계 플래그). 브라우저로 열어 문항별 검수. `<cert>`는 `clf`·`saa`·`soa`·`dea`·`mla`이고 산출물 디렉터리는 자격증 label로 열린다(`build/SOA-C03_review/` 등). **빌드 산출물이라 커밋하지 않는다.**
   - Task 제목의 **"정답 쏠림" 배지는 작성 균형 참고용**이다. 앱은 보기 순서를 문항별로 섞어 내보내므로(`mock_exam.dart`의 `randomOptionOrders`·`applyOptionOrders` — 퀴즈·오답노트·모의고사 전 경로) JSON의 `correct` 인덱스는 학습자에게 그대로 보이지 않는다. **정답 위치를 옮기려고 문항을 고치지 않는다.** MLA 뷰어의 배지 7건이 그 예다(2026-10-27 실측): t2-1만 부분 쏠림(idx1 18/23)이고, **도메인 3·4의 6개 Task는 전 문항이 idx0**이다(t3-1 25/25 · t3-2 23/23 · t3-3 26/26 · t4-1 30/30 · t4-2 35/35 · t4-3 35/35) — 그대로 둔다.
   - ⚠️ **SOA는 쏠림이 20 Task 중 19건**이다(2026-10-29 실측, 전부 idx0 — `t1-1`·`t3-2`·`t3-3`·`t3-4`·`t5-2`·`t5-3`·`t5-4`는 15/15). DEA는 17 Task 중 5건(`t1-1` 13/16 · `t1-2`~`t1-4` 15/15 · `t2-4`만 idx1 9/15). **배지 수가 많은 것은 결함 수가 아니다** — 같은 이유로 그대로 둔다.
   - 반면 **`wrongExplanations` 키가 보기와 어긋나는 것은 실제 결함**이고, 그것은 배지가 아니라 문항별 구조 플래그로 잡힌다(C6). **MLA·SOA·DEA 모두 구조 플래그 0건**이다(MLA 2026-10-27 · SOA 300문항·DEA 256문항 2026-10-29 실측 — `questionFlags`를 전수에 돌려 확인).
5. **문항별 루브릭(아래)** 적용 → 판정.
6. **수정 루프(아래)** 반복 → 해당 Task 전 문항 통과.
7. **flip**: Task별 `node tool/review.mjs flip <cert> <taskId>` (구조 플래그 있으면 중단; `--force`는 신중히). flip이 `verified` 전환 + `content_index` questionCount 동기화 + 그 자격증 테스트 실행. 돌리는 테스트는 `tool/review.mjs`의 `CERTS[<cert>].tests`가 정본이고, 그 파일들이 실재하는지는 `review.test.mjs`가 기계로 검사한다.

   | 자격증 | flip이 돌리는 테스트 | `flipAllowlist` |
   |---|---|---|
   | SAA-C03 | `saa_questions_test` · `content_index_test` | 없음 |
   | MLA-C01 | `mla_questions_test` · `mla_doc_format_test` · `content_index_test` | **있음**(`flipApprovedTaskIds`) |
   | SOA-C03 | `soa_questions_test` · `content_index_test` | 없음 |
   | DEA-C01 | `dea_questions_test` · `content_index_test` | 없음 |
   | CLF-C02 | `clf_supplement_questions_test` · `content_index_test` | 없음 |

   - **MLA 전용**: `test/mla_questions_test.dart`의 `flipApprovedTaskIds` 집합에 Task가 들어가 있어야 `verified: true`가 허용된다(목록 밖이면 가드가 실패한다). **그 추가를 `flip` 명령이 대신 해 준다** — 사람이 명령을 직접 실행하고 결과가 diff에 드러나므로 "사람의 서명"이라는 의미는 같다.
   - ⚠️ **SOA·DEA에는 그 허용 목록이 없다** — "목록 밖의 `verified: true`를 막는" Dart 가드가 없으므로, 그 두 자격증에서 `verified`를 지키는 것은 **사람이 flip 명령을 실행한다는 규율뿐**이다. 같은 가드를 둘지는 미결정.
8. **커밋**: flip 결과를 그 자격증의 검수 브랜치(`saa-review/*`·`soa-review/*`·`dea-review/*`·`mla-review/*`)에 사람이 직접 커밋.

## 2. 문항별 루브릭 (각 항목 통과해야 flip 대상)
| # | 검사 | 통과 기준 |
|---|---|---|
| C1 **정답 정확성** | 표시된 `correct`가 실제 정답인가 | 공식 AWS 동작 기준 정답 1개로 명확 |
| C2 **해설** | `explanation`이 정답 근거를 옳게 설명하는가 | 사실 정확 + 왜 정답인지 |
| C3 **오답 근거** | `wrongExplanations` 각 항목이 왜 오답인지 옳게 설명 | 비정답 3개 전부, 사실 정확 |
| C4 **출처 뒷받침** | `sources`가 정답을 실제로 뒷받침하는가 | 공식 문서/Exam Guide 1순위, URL 유효, 내용 일치 |
| C5 **시험 범위** | 현행 **대상 자격증 시험**(CLF-C02·SAA-C03·SOA-C03·DEA-C01·MLA-C01) 범위·난이도인가 | 범위 밖/구식 서비스/모호 stem 아님 |
| C6 **구조**(자동) | 보기 4·correct 범위·오답키·sources 형식 | `questionFlags` 0건(T1/`review.mjs`가 검사) |

> 출처 우선순위(C4): **공식 docs.aws.amazon.com·Exam Guide > FAQ/pricing > blog/re:Post > 3rd-party**. 비공식은 보조 근거로만.
>
> ⚠️ **URL이 실재하는지는 어느 자동 가드도 보지 않는다**(C4의 "URL 유효"는 사람 몫이다). `questionFlags`와 `<cert>_questions_test`는 `sources`가 비어 있지 않고 `http(s)`로 시작하는지만 검사한다 — 리다이렉트·404는 통과한다. SAA에서 `rds-reserved-instances.html`이 **6문항**의 죽은 링크였고(2026-10-28 발견, 실측하면 `UserGuide/` 인덱스로 리다이렉트된다) MLA 도메인 3에서는 작성 URL **23건**이 실제 오류였다. 전수 실측 레시피는 `curl -o /dev/null -w '%{http_code} %{url_effective}'`다.
>
> ⚠️ **출처 교체는 `.md`와 `.questions.json`을 함께 본다.** 문항 가드는 학습문서를 보지 않으므로, `.questions.json`만 고치면 같은 깨진 링크가 `.md`의 프런트매터 `url:`·참고자료에 남는다(2026-10-28 `saa-t4-3.md`에서 2곳).
>
> 최신성(C4·C5): 서비스 변경으로 해설이 낡는 일이 실제로 잦다 — 2026-10-20 검증에서 나온 **STS 글로벌 엔드포인트 처리·WAF 보호 대상 목록·Secrets Manager 관리형 교체** 3건이 모두 그 사례다. 지원 리소스 목록·상한·기본값·"Lambda가 필요한가" 같은 서술은 공식 페이지 본문을 다시 열어 확인한다(목록은 특히 항목이 조용히 늘어난다).
>
> 비교 대상 혼동(C3): 오답 근거에서 닮은 기능을 섞지 않는다 — 예: **Aurora 복제본**(같은 리전, 클러스터 스토리지 공유)과 **RDS 읽기 전용 복제본**(비동기 복제)은 복제 방식이 다르다.
>
> 가용성 변경(C4·C5): 신규 고객 온보딩 중단·제공 종료 같은 **서비스 상태**에 기댄 서술은 flip 직전에 공식 공지·API 레퍼런스를 다시 열어 확인하고, 확인한 상태를 해설에 그대로 쓴다. 가이드에 남아 있어도 신규 고객이 쓸 수 없는 기능은 문항을 버리지 말고 **상태를 명시**한다 — "신규 고객 온보딩 중단"과 "제공 종료"는 다른 서술이니 섞지 않는다. 또 같은 기능의 상태를 두 문항이 다르게 적으면 그것만으로 결함이다(Task 사이에서도 맞춘다). MLA는 SageMaker 주변 기능이 특히 자주 바뀌므로 상태 서술이 든 문항을 Task별로 모아 한 번에 확인한다. ⭐ **날짜의 정본은 개발자 가이드가 아니라 제품 features 페이지의 End of Support Notice다**(dg의 `*-availability-change.html`은 날짜를 적지 않는다). MLA 19건의 확인 결과와 재확인 조건은 [2026-10-27-mla-source-recheck.md](2026-10-27-mla-source-recheck.md)에 있다 — flip 직전 재확인은 그 표를 먼저 열어 갈음한다.
>
> 작성자 메모 금지(M2): "공식 문서에서 확인되지 않으므로", "원문에 나오지 않습니다", "문서가 반올림한 듯하다" 같은 **작성 과정 메모를 학습자용 문장에 남기지 않는다.** 확인된 것은 사실로 쓰고, 확인되지 않은 것은 해설에서 뺀다. 판단 보류는 문항이 아니라 §5 승인 로그에 남긴다. 기계 가드는 **MLA에만 있다**(`mla_questions_test.dart`의 M2) — SOA·DEA는 사람이 본다. ⚠️ 메모는 **출처 제목**에도 숨는다(SAA `t4-5`의 `"(게이트 검수 반영: 2026-06-12)"` 2건) — 본문 집계로는 안 잡히므로 `sources[].title`도 함께 읽는다.
>
> ⚠️ 보기의 주장을 부정하는 서술("~라는 서술은 없습니다")은 M2 대상이 **아니다** — 그것은 왜 오답인지 설명하는 정당한 문장이다. 학습문서의 "공식 문서에서 확인되지 않았으므로 정답으로 고르지 않습니다"도 의도된 시험 전략 서술이라 대상이 아니다.

## 3. 판정 + 수정 루프
각 문항 판정:
- **통과(pass)**: 6항목 충족 → flip 대상.
- **수정(fix)**: 경미한 오류(해설 표현·출처 교체) → 고치고 재검수.
- **재작성(rewrite)**: 정답/보기 자체가 틀림 → 문항 재작성 후 재검수.
- **출처 교체(resource)**: 출처가 약함/무효 → 공식 출처로 교체 후 C4 재검수.
- **폐기(drop)**: 범위 밖·구제 불가 → 제거(단, Task 밀도 ≥15 유지 필요 — `<cert>_questions_test`의 `minPerTask`. 폐기 시 대체 문항 작성).

수정 루프: **수정 → 재검수 → 통과까지**. **Task 하나가 ‘전 문항 통과’면 그 Task를 flip할 수 있다**(도메인 전체를 기다리지 않는다 — MLA Task는 22~35문항, SOA·DEA는 15문항 묶음이다). `fix`를 반영했으면 구조 플래그 0을 재확인한 뒤 재검수한다 — SAA는 `saa_prescreen.mjs build`, 그 밖의 자격증은 `review.mjs build <cert>`(사전심사 도구는 아직 SAA 전용이다).

## 4. flip 후 / 종료
- Task flip 후 `flutter test`(또는 flip CLI가 돌린 그 자격증 테스트) 그린 확인.
- ⚠️ **게이트를 여는 flip에서는 전체 스위트를 돌린다.** flip CLI가 돌리는 것은 `cert.tests` 두세 개뿐인데, 게이트가 열리는 순간 **그 자격증을 "잠긴 cert" 표본으로 쓰던 다른 테스트**가 깨진다 — SAA 개방(2026-10-28)에서 `cert_exam_restore`·`home_sections`·`cert_detail_sections`·`weighted_exam`의 **5건**이 그렇게 드러났다. **파일명·테스트명에 cert 코드가 없는 케이스가 섞여 있어 grep으로는 안 보인다.**
- **도메인별 weighted capacity를 모두 충족한 시점에** `certExamHasWeightedCapacity('<cert>')`가 true가 되어 통합 모의고사가 노출된다. 약점 집중 모의고사는 여기에 **비검토 응시 3회**가 더 필요하다(`certWeightedExamUnlocked`). 부족 도메인이 하나라도 남아 있으면 계속 잠긴다.
- **같은 사실 묶음 점검**: 같은 사실을 묻는 문항이 여러 Task에 흩어져 있으면 한 모의고사에 함께 뽑혀 사실상 같은 문제를 두 번 풀게 된다. flip을 막지는 않으므로 **flip 후** 묶음을 모아 두고 교체 후보로 관리한다(어느 쪽을 남길지는 Task 밀도 ≥15를 깨지 않는 선에서).
- 검수 종료: SAA는 `rm .saa-frozen` → freeze 해제(다른 자격증은 가드 대상이 아니다). 검수 브랜치 → develop PR → 릴리스.

## 5. 승인 로그(감사 추적)
- flip 커밋 = 승인 기록(누가·언제·어느 Task). 커밋 메시지에 검수 근거 요약 권장.
- 의심·판단 보류 항목은 별도 메모(또는 prescreen JSON 옆)로 남겨 재검수.

---
**비대상**: AI flip·verified 결정(금지) · 외부 블라인드 테스터(§C, CLF 게이트) · cert_detail 약점/리포트 게이트(통합시험 아님).
