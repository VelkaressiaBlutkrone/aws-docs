# SAA-C03 문항 검수 루브릭 + 수정 루프 + flip 프로토콜 (T7)

> 잠금 플랜 [2026-06-20-saa-rereview-plan](../superpowers/plans/2026-06-20-saa-rereview-plan.md) §5 T7.
> 대상: **사람 검수자(사용자)**. **`verified` flip은 사람만**(AI flip 금지) — 이 문서는 그 사람 공정의 운영 가이드.
> 전제 인프라(완료): T1 사전심사(`saa_prescreen.mjs`)·T3 동적 불변식·T4 공개 게이트·T6 문서 스캔·T8 freeze 가드.

---

## 0. 착수 전 (1회)
1. **릴리스 완료** 확인(develop→main). 검수 인프라가 main에 반영된 상태에서 시작.
2. **freeze 발효**: `git config core.hooksPath .githooks` (1회 설치) → `touch .saa-frozen`. 이후 SAA 콘텐츠 변경은 `saa-review*` 브랜치에서만(가드가 그 외를 차단).
3. **검수 브랜치**: `git checkout -b saa-review/d1`(도메인별) 등.

## 1. 도메인 단위 진행 (D1 30% → D2 26% → D3 24% → D4 20%)
각 도메인의 모든 Task를 검수·통과시킨 뒤 **도메인 일괄 flip**. 통합 모의고사는 **전 도메인 균형**이 되어야 노출(T4) — 부분 flip은 노출 안 됨(편향 방지).

### 도메인별 절차
1. **문서 선행(T6)**: 해당 도메인 학습문서의 핵심 오류를 먼저 수정(문항이 문서 파생이므로). 미수정 플래그는 [t6-doc-scan.md](t6-doc-scan.md) 참조.
2. **결정적 사전심사(T1)**: `cd flutter_app && node tool/saa_prescreen.mjs build` → `build/saa_review/<taskId>.prescreen.json`(구조·정합성 플래그). 플래그 있는 문항 먼저 손본다.
3. **의미·출처 사전심사(T2, 도구 구축 후)**: AI 읽기전용 패스의 주석 아티팩트(의심 정답·약한 출처). *현재 미구축 — 없으면 4번 뷰어로 직접 검수.*
4. **검수 뷰어**: `node tool/saa_review.mjs build` → `build/saa_review/index.html`(정답 강조·기계 플래그). 브라우저로 열어 문항별 검수.
5. **문항별 루브릭(아래)** 적용 → 판정.
6. **수정 루프(아래)** 반복 → 도메인 전 Task 통과.
7. **flip**: Task별 `node tool/saa_review.mjs flip <taskId>` (구조 플래그 있으면 중단; `--force`는 신중히). flip이 `verified` 전환 + `content_index` questionCount 동기화 + `saa_questions_test`·`content_index_test` 실행.
8. **커밋**: flip 결과를 `saa-review/*` 브랜치에 사람이 직접 커밋.

## 2. 문항별 루브릭 (각 항목 통과해야 flip 대상)
| # | 검사 | 통과 기준 |
|---|---|---|
| C1 **정답 정확성** | 표시된 `correct`가 실제 정답인가 | 공식 AWS 동작 기준 정답 1개로 명확 |
| C2 **해설** | `explanation`이 정답 근거를 옳게 설명하는가 | 사실 정확 + 왜 정답인지 |
| C3 **오답 근거** | `wrongExplanations` 각 항목이 왜 오답인지 옳게 설명 | 비정답 3개 전부, 사실 정확 |
| C4 **출처 뒷받침** | `sources`가 정답을 실제로 뒷받침하는가 | 공식 문서/Exam Guide 1순위, URL 유효, 내용 일치 |
| C5 **시험 범위** | 현행 SAA-C03 범위·난이도인가 | 범위 밖/구식 서비스/모호 stem 아님 |
| C6 **구조**(자동) | 보기 4·correct 범위·오답키·sources 형식 | `questionFlags` 0건(T1/saa_review가 검사) |

> 출처 우선순위(C4): **공식 docs.aws.amazon.com·Exam Guide > FAQ/pricing > blog/re:Post > 3rd-party**. 비공식은 보조 근거로만.

## 3. 판정 + 수정 루프
각 문항 판정:
- **통과(pass)**: 6항목 충족 → flip 대상.
- **수정(fix)**: 경미한 오류(해설 표현·출처 교체) → 고치고 재검수.
- **재작성(rewrite)**: 정답/보기 자체가 틀림 → 문항 재작성 후 재검수.
- **출처 교체(resource)**: 출처가 약함/무효 → 공식 출처로 교체 후 C4 재검수.
- **폐기(drop)**: 범위 밖·구제 불가 → 제거(단, Task 밀도 ≥15 유지 필요 — `saa_questions_test`. 폐기 시 대체 문항 작성).

수정 루프: **수정 → 재검수 → 통과까지**. 도메인의 모든 Task가 ‘전 문항 통과’여야 flip.

## 4. flip 후 / 종료
- 도메인 flip 후 `flutter test`(또는 flip CLI가 돌린 2개 테스트) 그린 확인.
- **전 4개 도메인 flip 완료 시** `certExamIsBalanced('SAA-C03')` true → 홈 통합 모의고사 자동 노출(T4).
- 검수 종료: `rm .saa-frozen` → freeze 해제. `saa-review/*` → develop PR → 릴리스.

## 5. 승인 로그(감사 추적)
- flip 커밋 = 승인 기록(누가·언제·어느 Task). 커밋 메시지에 검수 근거 요약 권장.
- 의심·판단 보류 항목은 별도 메모(또는 prescreen JSON 옆)로 남겨 재검수.

---
**비대상**: AI flip·verified 결정(금지) · 외부 블라인드 테스터(§C, CLF 게이트) · cert_detail 약점/리포트 게이트(통합시험 아님).
