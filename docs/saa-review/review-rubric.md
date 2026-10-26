# SAA-C03 문항 검수 루브릭 + 수정 루프 + flip 프로토콜 (T7)

> 잠금 플랜 [2026-06-20-saa-rereview-plan](../superpowers/plans/2026-06-20-saa-rereview-plan.md) §5 T7.
> 대상: **사람 검수자(사용자)**. **`verified` flip은 사람만**(AI flip 금지) — 이 문서는 그 사람 공정의 운영 가이드.
> 전제 인프라(완료): T1 사전심사(`saa_prescreen.mjs`)·T3 동적 불변식·T4 공개 게이트·T6 문서 스캔·T8 freeze 가드.
> 검수 뷰어·flip 도구는 **자격증 일반형**이다(2026-10-27): `tool/review.mjs build <cert>` · `flip <cert> <taskId>`
> (`<cert>`: clf·saa·soa·dea·mla). 루브릭 C1~C6과 아래 절차는 **MLA-C01에도 그대로 쓴다** — MLA 전용 주의는 7번 flip 항목.

---

## 0. 착수 전 (1회)
1. **릴리스 완료** 확인(develop→main). 검수 인프라가 main에 반영된 상태에서 시작.
2. **freeze 발효**: `git config core.hooksPath .githooks` (1회 설치) → `touch .saa-frozen`. 이후 SAA 콘텐츠 변경은 `saa-review*` 브랜치에서만(가드가 그 외를 차단).
3. **검수 브랜치**: `git checkout -b saa-review/d1`(도메인별) 등.

## 1. 진행 단위와 공개 게이트 (권장 순서 D1 30% → D2 26% → D3 24% → D4 20%)

**flip 단위 = Task(15문항).** 공개 게이트는 "전 도메인 일괄 flip"이 아니라 **도메인별 weighted capacity**다: 앱의 65문항 연습 세트에 공식 비중을 `allocateByWeight`(floor + 최대 잉여법, 동률은 선언 순서)로 배분한 수량 — SAA-C03 = **D1 19 · D2 17 · D3 16 · D4 13** — 이상을 도메인별로 채우면 통합/약점 모의고사가 열린다. 필요/현재 수량표는 [2026-08-06-weighted-ready-batch.md](2026-08-06-weighted-ready-batch.md).

- 라이브 게이트 함수는 **`certExamHasWeightedCapacity`**(= `examWeightedCapacityStatus().ready`)다. 홈 시험 섹션·`cert_detail`·`exam_page`·`cert_exam_page`·`weighted_exam`이 모두 이 함수를 쓴다.
- ⚠️ **옛 게이트 `certExamIsBalanced`("전 도메인에 검증 문항 1개 이상")는 2026-10-20에 코드에서 제거됐다** — 2026-08-06 weighted capacity 게이트가 역할을 대신한 뒤 `lib` 호출이 0이었다. 이 문서의 옛 서술(도메인 일괄 flip·부분 flip 미노출)이 그 함수를 공개 조건으로 적고 있었다. 지금 게이트는 `certExamHasWeightedCapacity` 하나다.
- 도메인 순서는 **권장**일 뿐 게이트가 아니다. 실제로는 D3·D4가 먼저 verified돼 있고(45·30) 부족한 쪽이 D1·D2다 — 판정은 순서가 아니라 수량으로 한다.
- 편향 방지는 수량 게이트가 담당한다. 다만 수량만 채우면 공식 Task Statement 하나가 완전히 빈 조합이 가능하므로(D1의 Task 1.3), 품질 균형은 batch 문서의 리스크 항목으로 관리한다.

### 도메인별 절차
1. **문서 선행(T6)**: 해당 도메인 학습문서의 핵심 오류를 먼저 수정(문항이 문서 파생이므로). 미수정 플래그는 [t6-doc-scan.md](t6-doc-scan.md) 참조.
2. **결정적 사전심사(T1)**: `cd flutter_app && node tool/saa_prescreen.mjs build` → `build/saa_review/<taskId>.prescreen.json`(구조·정합성 플래그). **빌드 산출물이라 커밋하지 않는다**(도구의 `OUT_DIR = 'build/saa_review'`). 플래그 있는 문항 먼저 손본다.
3. **의미·출처 사전심사(T2)**: AI 읽기전용 패스의 주석 아티팩트(의심 정답·약한 출처) → **`docs/saa-review/prescreen/<taskId>.json`**(키 `taskId`·`domain`·`count`·`questions`·`summary`). 2번의 build 산출물과 **다른 파일이며 이쪽은 커밋된다** — 경로가 둘인 것은 불일치가 아니다. *전용 도구는 없다(2026-10-27 실측: `flutter_app/tool/`에 `saa_prescreen.mjs`·`review.mjs` 둘뿐이고, 사전심사는 아직 SAA 전용이다) — 2026-08-06 AI 패스 산출물이 그 경로에 들어 있고, 없는 Task는 4번 뷰어로 직접 검수한다.* 판정값 `pass`/`review`는 **참고용**이고 최종 판정은 사람이 한다.
4. **검수 뷰어**: `node tool/review.mjs build <cert>` → `build/<cert>_review/index.html`(정답 강조·기계 플래그). 브라우저로 열어 문항별 검수. SAA는 `build saa`, MLA는 `build mla`. **빌드 산출물이라 커밋하지 않는다.**
   - Task 제목의 **"정답 쏠림" 배지는 작성 균형 참고용**이다. 앱은 보기 순서를 문항별로 섞어 내보내므로(`mock_exam.dart`의 `randomOptionOrders`·`applyOptionOrders` — 퀴즈·오답노트·모의고사 전 경로) JSON의 `correct` 인덱스는 학습자에게 그대로 보이지 않는다. **정답 위치를 옮기려고 문항을 고치지 않는다**(MLA 도메인 3·4는 거의 전부 idx0이고 그대로 둔다).
5. **문항별 루브릭(아래)** 적용 → 판정.
6. **수정 루프(아래)** 반복 → 해당 Task 전 문항 통과.
7. **flip**: Task별 `node tool/review.mjs flip <cert> <taskId>` (구조 플래그 있으면 중단; `--force`는 신중히). flip이 `verified` 전환 + `content_index` questionCount 동기화 + 그 자격증 테스트 실행(SAA는 `saa_questions_test`·`content_index_test`, MLA는 `mla_questions_test`·`mla_doc_format_test`·`content_index_test`).
   - **MLA 전용**: `test/mla_questions_test.dart`의 `flipApprovedTaskIds` 집합에 Task가 들어가 있어야 `verified: true`가 허용된다(목록 밖이면 가드가 실패한다). **그 추가를 `flip` 명령이 대신 해 준다** — 사람이 명령을 직접 실행하고 결과가 diff에 드러나므로 "사람의 서명"이라는 의미는 같다.
8. **커밋**: flip 결과를 `saa-review/*` 브랜치에 사람이 직접 커밋.

## 2. 문항별 루브릭 (각 항목 통과해야 flip 대상)
| # | 검사 | 통과 기준 |
|---|---|---|
| C1 **정답 정확성** | 표시된 `correct`가 실제 정답인가 | 공식 AWS 동작 기준 정답 1개로 명확 |
| C2 **해설** | `explanation`이 정답 근거를 옳게 설명하는가 | 사실 정확 + 왜 정답인지 |
| C3 **오답 근거** | `wrongExplanations` 각 항목이 왜 오답인지 옳게 설명 | 비정답 3개 전부, 사실 정확 |
| C4 **출처 뒷받침** | `sources`가 정답을 실제로 뒷받침하는가 | 공식 문서/Exam Guide 1순위, URL 유효, 내용 일치 |
| C5 **시험 범위** | 현행 SAA-C03 범위·난이도인가 | 범위 밖/구식 서비스/모호 stem 아님 |
| C6 **구조**(자동) | 보기 4·correct 범위·오답키·sources 형식 | `questionFlags` 0건(T1/`review.mjs`가 검사) |

> 출처 우선순위(C4): **공식 docs.aws.amazon.com·Exam Guide > FAQ/pricing > blog/re:Post > 3rd-party**. 비공식은 보조 근거로만.
>
> 최신성(C4·C5): 서비스 변경으로 해설이 낡는 일이 실제로 잦다 — 2026-10-20 검증에서 나온 **STS 글로벌 엔드포인트 처리·WAF 보호 대상 목록·Secrets Manager 관리형 교체** 3건이 모두 그 사례다. 지원 리소스 목록·상한·기본값·"Lambda가 필요한가" 같은 서술은 공식 페이지 본문을 다시 열어 확인한다(목록은 특히 항목이 조용히 늘어난다).
>
> 비교 대상 혼동(C3): 오답 근거에서 닮은 기능을 섞지 않는다 — 예: **Aurora 복제본**(같은 리전, 클러스터 스토리지 공유)과 **RDS 읽기 전용 복제본**(비동기 복제)은 복제 방식이 다르다.

## 3. 판정 + 수정 루프
각 문항 판정:
- **통과(pass)**: 6항목 충족 → flip 대상.
- **수정(fix)**: 경미한 오류(해설 표현·출처 교체) → 고치고 재검수.
- **재작성(rewrite)**: 정답/보기 자체가 틀림 → 문항 재작성 후 재검수.
- **출처 교체(resource)**: 출처가 약함/무효 → 공식 출처로 교체 후 C4 재검수.
- **폐기(drop)**: 범위 밖·구제 불가 → 제거(단, Task 밀도 ≥15 유지 필요 — `saa_questions_test`. 폐기 시 대체 문항 작성).

수정 루프: **수정 → 재검수 → 통과까지**. **Task 하나가 ‘전 15문항 통과’면 그 Task를 flip할 수 있다**(도메인 전체를 기다리지 않는다). `fix`를 반영했으면 `saa_prescreen.mjs build`를 다시 돌려 구조 플래그 0을 재확인한 뒤 재검수한다.

## 4. flip 후 / 종료
- Task flip 후 `flutter test`(또는 flip CLI가 돌린 그 자격증 테스트) 그린 확인.
- **도메인별 weighted capacity를 모두 충족한 시점에** `certExamHasWeightedCapacity('SAA-C03')`가 true가 되어 통합 모의고사가 노출된다. 약점 집중 모의고사는 여기에 **비검토 응시 3회**가 더 필요하다(`certWeightedExamUnlocked`). 부족 도메인이 하나라도 남아 있으면 계속 잠긴다.
- 검수 종료: `rm .saa-frozen` → freeze 해제. `saa-review/*` → develop PR → 릴리스.

## 5. 승인 로그(감사 추적)
- flip 커밋 = 승인 기록(누가·언제·어느 Task). 커밋 메시지에 검수 근거 요약 권장.
- 의심·판단 보류 항목은 별도 메모(또는 prescreen JSON 옆)로 남겨 재검수.

---
**비대상**: AI flip·verified 결정(금지) · 외부 블라인드 테스터(§C, CLF 게이트) · cert_detail 약점/리포트 게이트(통합시험 아님).
