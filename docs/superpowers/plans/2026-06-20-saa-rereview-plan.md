# SAA-C03 재검토 실행 플랜 — 2-pass 검수 → flip

> **잠금:** 2026-06-20 `/plan-eng-review` (codex 아웃사이드 보이스 15 findings, 4 tensions → 4/4 수용·크로스모델 합의).
> **착수 조건:** PR#35 머지 + `develop`→`main` 릴리스 후 (+ 검수기간 SAA 콘텐츠 freeze).
> **역할:** 실행=사람(검수·`verified` flip·커밋). AI=읽기전용 사전심사·출처대조·도구/아티팩트 작성(브랜치+PR로 사람 머지). **AI는 `verified` flip·flip 커밋 절대 금지.**
> **관련:** WORKLIST §B-① · [saa-c03-task-mapping](../../plans/saa-c03-task-mapping.md) · 메모리 `question-bank-verified-workflow`

---

## 0. 목표
SAA-C03 **학습문서 24개(라이브)** + **모의고사 문항 360개(전부 `verified:false` AI 드래프트, 미검증)** 를 내/외부 2-pass로 **전수** 재검토하여, 사람 검증을 통과한 문항만 `verified:true`로 공개한다. "재검토"지만 문항은 사실상 **첫 사람 검증**(= WORKLIST §B-①의 본체).

## 1. 현황 (실측 2026-06-20)
- 문항: `flutter_app/assets/content/saa/*.questions.json` 24파일 × 15 = **360, 전부 `verified:false`**.
- `QuestionBank.fromJson`(`lib/models/question.dart:113`)이 `.where((q)=>q.verified)` — **`verified:true`만 앱 로드**.
- 노출 게이트: `certHasVerifiedQuestions`(`lib/data/content_index.dart:464`) = `certContentSummary().questions > 0`(content_index `questionCount` 합). SAA 전부 `questionCount:0` → 모의고사 섹션 숨김(`lib/pages/home/exams_section.dart:22`).
- `buildSampledExam`(`lib/data/mock_exam.dart:45`): 도메인 가중 샘플, **빈 도메인은 잔여 도메인에서 백필**(`:64`) → 부분 verified면 편향 출제(크래시 없음).
- 기존 도구 `tool/saa_review.mjs`: 구조 플래그(`questionFlags`: 보기4·correct·오답키·sources 존재/http) + 정답 쏠림(`taskAnswerSkew` ≥60%) + `flip`(false→true + content_index `questionCount` 동기화 + `saa_questions_test` 실행). 코드 주석 **"품질 판단 아님"**.
- 테스트: `saa_questions_test.dart`(드래프트 스키마·밀도 15+), `content_index_test.dart`(**SAA `questions==0` 하드코딩 단언 `:13-14,:45`**), `all_content_parse_test`(문서 파싱), `question_model_test`.
- 불변 제약: **AI는 `verified` flip 금지**(사람만 검수·flip).

## 2. 확정 결정 (Step 0 + 8 forks/tensions)
| 항목 | 결정 |
|---|---|
| 검토 모델 | 2-pass: AI 읽기전용 사전심사 → 사람 검증·flip |
| 범위 | 전수 360문항 + 24문서 (boil the lake) |
| flip 단위 | 도메인 일괄(D1 5Task 검증 후 함께 → D2 → D3 → D4) |
| **공개 게이트** | `questionCount>0` → **"전 도메인 균형 최소 세트" 게이트(or "부분/베타" 라벨)** ⬅ codex#1·2 |
| 출처 검증 | 전수 WebFetch + **출처 우선순위(공식·Exam Guide 1순위) + 범위필터 선행** ⬅ codex#4·5·6 |
| **순서** | **문서 핵심오류 스캔 → 문항(범위필터→구조→의미→출처) → 사람 검수→수정루프→flip** ⬅ codex#13 |
| **산출물** | **문항id별 JSON 정본(severity·issue·source verdict·권고) + HTML/md 렌더** ⬅ codex#8·9 |
| content_index_test | **동적 불변식(`questionCount` == 실제 verified 수), 하드코딩 0 제거** ⬅ codex#7 |
| AI 역할 | 도구·아티팩트 작성(브랜치+PR로 사람 머지) · `verified` flip·커밋 **금지**. "읽기전용"=verified 데이터 한정 ⬅ codex#12 |
| 착수 | PR#35 머지 + `develop`→`main` 릴리스 후 + **검수기간 SAA 콘텐츠 freeze** ⬅ codex#11 |
| SAA 섹션 앵커 | 이번 범위 제외(flip 후 별도) |

## 3. 파이프라인
```
Phase A 문서 선행          Phase B AI 사전심사(읽기전용)        Phase C 사람          Phase D 공개
24 문서                    도메인순 D1→D4, Task별:              루브릭 검수            게이트:
 핵심오류 스캔 ──┐          1) Exam Guide 범위필터(범위밖 제외)  → 판정              전 도메인
 (Exam Guide·    │          2) questionFlags(구조, 재사용)       → 수정루프:          균형 최소세트
  현행 AWS)      │          3) 의미(의심 정답·구식·모호)         (폐기/수정/          충족?
       │         │          4) 출처 WebFetch(우선순위 대조)      재작성/출처교체)  ──► 예: 통합
 문서 오류 수정 ─┴────────► 5) JSON 정본 + HTML/md 렌더 ───────► → 재검수            모의고사 노출
 (문항 flip 전제)            (build/saa_review/<task>.json/.md)   → 도메인 완결      아니오: 숨김/
                                                                  → 도메인 일괄 flip  "베타" 라벨
                            ※ AI는 flip·verified 변경 절대 안 함 ──────► 사람만 flip+커밋
```
⚠ **Blast radius:** flip은 Task 단위(15문항)지만 `certHasVerifiedQuestions`가 켜지는 순간 통합 모의고사가 노출되고 빈 도메인은 백필됨 → **공개 게이트(Phase D)가 핵심**.

## 4. What already exists (재사용 — 신규 인프라 0)
`saa_review.mjs`(뷰어·`questionFlags`·skew·flip) · `saa_questions_test`(드래프트 스키마) · `content_index_test`(게이트, **동적화 대상**) · `all_content_parse_test` · `QuestionBank` verified 게이트 · `buildSampledExam` 백필 · `saa-c03-task-mapping.md`(도메인·출처 레퍼런스). → 신규는 **의미층 + 공개 게이트 + 동적 테스트**뿐.

## 5. Implementation Tasks
- [ ] **T1 (P1)** — `tool/saa_prescreen.mjs`: `questionFlags` 재사용 구조 플래그 + Exam Guide 범위필터(순수함수 + 단위테스트). 산출: 문항id별 JSON.
- [ ] **T2 (P1)** — AI 의미+출처 사전심사 패스(Task별: 범위필터→의미→출처 WebFetch 우선순위 대조) → JSON 정본 + HTML/md 렌더. 읽기전용(verified 무변경).
- [ ] **T3 (P1, REGRESSION)** — `content_index_test` 동적 불변식(`questionCount` == JSON verified 수), 하드코딩 `SAA==0`(`:13-14,:45`) 제거 + `flip` CLI가 `content_index_test` 실행. 검증: 첫 flip 후 `flutter test` 그린.
- [ ] **T4 (P1)** — 공개 게이트: `certHasVerifiedQuestions`/`exams_section`을 "전 도메인 균형 최소 세트" 조건 or "부분/베타" 라벨로. 테스트 포함.
- [ ] **T5 (P2)** — 부분-verified 앱 동작 테스트 확장(시험 길이·도메인 비율·백필·빈 도메인·라벨·재시도).
- [ ] **T6 (P2)** — 24문서 핵심오류 스캔 패스(Exam Guide·현행 AWS 대조) — 해당 도메인 문항 flip 선행.
- [ ] **T7 (P2)** — 사람 검수 루브릭 + 수정 루프 문서(폐기/수정/재작성/출처교체/재검수/승인=flip 커밋).
- [x] **T8 (P3)** — 검수기간 SAA 콘텐츠 freeze 정책 **명문화 완료**(WORKLIST §B-① · 전체 SAA · 규약+가드). 가드 `.githooks/pre-commit`: 발효(`.saa-frozen`) 중 검수브랜치(`saa-review*`/`review/saa*`) 밖에서 SAA 콘텐츠 커밋 차단. 설치 `git config core.hooksPath .githooks`, 토글 `touch/rm .saa-frozen`(현재 dormant). 4 시나리오 검증.

## 6. Tests (커버리지)
```
content_index_test     ★★→ 동적 불변식 전환(T3) — flip 회귀 원천 차단
saa_prescreen          [신규] 순수함수 단위테스트(T1)
flip→라이브 + 부분verified [신규] 시험 길이·비율·백필·라벨(T5)
공개 게이트            [신규] 균형 세트 전 비노출/베타(T4)
saa_questions_test·all_content_parse·question_model  ★★ 재사용
```

## 7. Failure modes
| 실패 | 완화 |
|---|---|
| 첫 flip이 `content_index_test` 깨뜨림(침묵 — flip CLI가 그 테스트 미실행) | T3 동적 불변식 + flip CLI가 테스트 실행 |
| 부분 verified → 편향 "통합" 노출 | T4 균형 게이트/베타 라벨 |
| AI 출처 대조 과신 → 오답 통과 | AI는 플래그만(단정 금지), 사람 게이트, 출처 우선순위·범위필터 |
| 문서 오류가 문항으로 전파 | T6 문서 선행 스캔 |
| 검수 중 콘텐츠 변경으로 기준 흔들림 | T8 freeze |

## 8. NOT in scope
AI flip/`verified` 결정 · 외부 블라인드 테스터(§C, CLF 게이트) · 신규 리뷰 웹앱/DB · 비-SAA 자격증(Phase 3) · SAA 섹션 앵커(flip 후 별도).

## 9. Review record
- **plan-eng-review** (2026-06-20): Architecture 3 · Code Quality 0 · Test 3 gaps(1 critical 회귀) · Performance 1. 전 결정 resolved. VERDICT: ENG CLEARED.
- **Outside voice (codex-cli 0.141.0):** 15 findings, 4 tensions → **4/4 수용**(공개 게이트·동적 불변식·수정루프+문서선행·JSON 산출물). 핵심: "가장 큰 구멍은 검수 품질이 아니라 공개 조건."
