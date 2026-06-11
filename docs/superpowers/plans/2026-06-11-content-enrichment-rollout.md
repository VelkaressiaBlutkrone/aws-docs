# 학습문서 고도화 — Plan 2: 롤아웃 (CLF 17 → SAA 24 → SOA 20)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 파일럿에서 확정된 고도화 템플릿(스펙 §4 + **freeze 체크리스트 §4.4**)을 나머지 61개 학습문서에 적용한다. cert 단위 3개 배치, 배치마다 본인 검수 게이트 → lastVerified → 머지·배포.

**Architecture:** 순수 콘텐츠 작업(앱 코드 변경 0). 배치별로 구조 테스트의 `enriched` 목록을 먼저 확장(RED) → 문서별 고도화(서브에이전트 1문서 1디스패치 + 2단 리뷰) → 전체 GREEN → 게이트. 파일럿 레퍼런스: `flutter_app/assets/content/clf/t1-1.md`·`t3-1.md` (승인본), 절차 전례: `docs/superpowers/plans/2026-06-11-content-enrichment-pilot.md` Task 2~5.

**Tech Stack:** Markdown(표·인용·`<details>`만), flutter_test 구조 테스트.

**불변 규칙(모든 배치):** 기존 내용 삭제·축약 금지(보강만) · AI 초안 단계 `lastVerified` 불변 · 신규 사실 진술은 해당 문서 출처 범위 내(초과 시 단정 대신 보고) · **§4.4 freeze 체크리스트 전 항목 준수**.

---

## 문서별 표준 레시피 (61개 공통 — 배치 Task에서 "레시피 적용"은 이것을 뜻함)

1. 대상 문서를 읽고 서브섹션 수·전제 용어 후보·서브섹션별 원리 주제를 도출.
2. `## 🔤 먼저 알아야 할 용어` 삽입(🎯 끝 `---` 뒤): 인트로 줄 "이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요." + 3열 표 5~10행. **각 용어를 본문(표 제외)에 grep — 미등장 행 삭제. 가르치는 개념 행 금지.**
3. 각 `### N)` 서브섹션에 `> 🧠 원리:` 블록 1개(정의·표 뒤): **4~7줄·단일 메커니즘·본문 미중복**, 질문형 도입 권장, §4.4 금지 패턴(수사 선언·신규 기술 용어·단정 표현) 회피.
4. `⚠️ 흔한 함정` 각 항목 아래 `   *(원리: §N — …)*` 포인터(블록에 실재하는 내용만, 본문 참조는 `§N 본문`).
5. `🧪 자가 점검`에 `**Q5 (원리).** 왜 …` + `<details>` 정답 1개(해당 문서의 가장 중요한 원리로).
6. 검증: 구조 테스트 해당 문서 3건 GREEN + 전체 스위트 그린 + `wc -l` (+50~90줄 가이드).
7. 문서당 커밋: `feat(content): <doc-id> 고도화 — 용어 + 원리 N블록 + 원리형 Q5 (AI 초안, 검수 전)`.
8. 문서당 2단 리뷰(스펙 준수 → 품질) + 수정 루프 — 파일럿과 동일. 품질 리뷰 프롬프트에 §4.4 체크리스트를 명시 포함.

---

### Task 1: 배치 A 준비 — 브랜치 + CLF 17 RED

**Files:**
- Modify: `flutter_app/test/content_enrichment_test.dart` (`enriched` 목록 확장)

- [ ] **Step 1:** `git checkout -b feat/content-enrichment-clf`
- [ ] **Step 2:** `enriched` 목록에 CLF 17개 추가 (파일럿 2개는 이미 있음 → 총 19):

```dart
const enriched = <String>[
  'assets/content/clf/t1-1.md', 'assets/content/clf/t1-2.md',
  'assets/content/clf/t1-3.md', 'assets/content/clf/t1-4.md',
  'assets/content/clf/t2-1.md', 'assets/content/clf/t2-2.md',
  'assets/content/clf/t2-3.md', 'assets/content/clf/t2-4.md',
  'assets/content/clf/t3-1.md', 'assets/content/clf/t3-2.md',
  'assets/content/clf/t3-3.md', 'assets/content/clf/t3-4.md',
  'assets/content/clf/t3-5.md', 'assets/content/clf/t3-6.md',
  'assets/content/clf/t3-7.md', 'assets/content/clf/t3-8.md',
  'assets/content/clf/t4-1.md', 'assets/content/clf/t4-2.md',
  'assets/content/clf/t4-3.md',
];
```

- [ ] **Step 3:** RED 확인 — `flutter test test/content_enrichment_test.dart -r compact` → 신규 17×3=51건 FAIL, 파일럿 2×3=6건 PASS. 실패 사유가 expect-reason인지 확인.
- [ ] **Step 4:** 커밋 `test(content): 구조 테스트 enriched 확장 — CLF 17 (RED)`

### Task 2: 배치 A 실행 — CLF 17 고도화

**Files:** `flutter_app/assets/content/clf/{t1-2,t1-3,t1-4,t2-1,t2-2,t2-3,t2-4,t3-2,t3-3,t3-4,t3-5,t3-6,t3-7,t3-8,t4-1,t4-2,t4-3}.md`

- [ ] 문서마다 표준 레시피 1~8 적용 (서브에이전트 1문서 1디스패치, 직렬). 추천 순서: t1-2→t1-4 → t2-1→t2-4 → t3-2→t3-8 → t4-1→t4-3 (도메인 순).
- [ ] 17개 완료 후: `flutter analyze lib && flutter test -r compact` → 전체 그린 (268+51=319).

### Task 3: 배치 A 게이트 — **STOP** → lastVerified → 머지·배포

- [ ] **Step 1:** 검수 자료: `git diff main...HEAD --stat` + 문서별 핵심 추가 요약. **사용자 검수 요청 — 피드백 전 진행 금지.** (원하면 도메인 단위 분할 검수 가능: t1·t2 먼저 → t3 → t4.)
- [ ] **Step 2:** 피드백 반영 → 재검증 → 수정 커밋.
- [ ] **Step 3:** 검수 완료 확인 후 17개 `lastVerified` → 검수일, 출처 줄에 `· 고도화 검수: 날짜` 병기. 커밋 `chore(content): CLF 17 lastVerified 갱신 (본인 검수 완료)`.
- [ ] **Step 4:** finishing-a-development-branch — main 병합(`--no-ff`) → 머지본 전체 테스트 → push(배포) → 브랜치 삭제.

### Task 4: 배치 B 준비 — SAA 24 RED

- [ ] `git checkout -b feat/content-enrichment-saa`
- [ ] `enriched`에 `assets/content/saa/saa-t1-1.md` ~ `saa-t4-5.md` 24개 추가 (t1: 1~5, t2: 1~5, t3: 1~9, t4: 1~5).
- [ ] **SAA 사전 점검:** `grep -n '^### ' flutter_app/assets/content/saa/*.md`와 코드 펜스 내부 `### ` 존재 여부 확인(```` ``` ```` 블록 안 `### `가 있으면 카운트 오염 — 그 경우 테스트의 서브섹션 카운트를 펜스-제외 방식으로 보강 후 진행).
- [ ] RED 확인(24×3 FAIL 추가) → 커밋.

### Task 5: 배치 B 실행 — SAA 24 고도화

- [ ] 문서마다 표준 레시피 적용 (SAA는 평균 272줄로 이미 두꺼움 — 원리 블록은 더 절제(4~6줄), 분량 가이드 +50~80줄).
- [ ] 전체 그린 (319+72=391).

### Task 6: 배치 B 게이트 — **STOP** → lastVerified → 머지·배포 (Task 3과 동일 절차)

### Task 7: 배치 C 준비 — SOA 20 RED

- [ ] `git checkout -b feat/content-enrichment-soa`
- [ ] `enriched`에 `assets/content/soa/soa-t1-1.md` ~ `soa-t5-4.md` 20개 추가 (t1: 1~5, t2: 1~4, t3: 1~4, t4: 1~3, t5: 1~4).
- [ ] **SOA 사전 점검(필수):** SOA 문서들은 코드 블록(CLI 예시)을 포함 — 펜스 안 `# `/`### ` 확인. 파일럿 리뷰가 지적한 카운트 오염 리스크 지점. 오염 발견 시 구조 테스트의 서브섹션 카운트를 코드 펜스 제외 로직으로 보강(별도 소커밋) 후 RED.
- [ ] RED 확인(20×3 FAIL 추가) → 커밋.

### Task 8: 배치 C 실행 — SOA 20 고도화

- [ ] 표준 레시피 적용. SOA 특이사항: CLI 코드 예시가 있는 서브섹션의 원리 블록은 명령 문법이 아니라 **동작 원리**(경보 상태 전이, 지표 집계 등)에 집중.
- [ ] 전체 그린 (391+60=451).

### Task 9: 배치 C 게이트 — **STOP** → lastVerified → 머지·배포 → 마무리

- [ ] Task 3과 동일 절차.
- [ ] 완료 후: HANDOFF.md 갱신(고도화 완료 → **다음: 모의고사 중량·증가 검토** 브레인스토밍 — 사용자 지시 순서), 스펙 상태 갱신.

---

## Self-Review 결과

- **스펙 커버리지:** §5-2 롤아웃(cert 단위 배치 커밋·검수) = Task 1~9. §4.4 freeze 전 항목이 표준 레시피·리뷰 프롬프트에 반영. 검수 루프·lastVerified 철칙 = 각 게이트 Task.
- **플레이스홀더:** 문서별 용어·원리 초안은 의도적으로 미수록 — 표준 레시피 1단계(도출)가 문서별 작업이며, 파일럿이 레시피+리뷰 루프의 품질 수렴을 검증했음. 레시피·체크리스트·파일 목록·검증 커맨드·커밋 메시지는 전부 명시.
- **수치 일관성:** 17+24+20=61 ✓, 테스트 증분 51/72/60 = 문서×3 ✓, CLF 파일명 t1-1~t4-3 ✓ SAA saa-t1-1~t4-5 ✓ SOA soa-t1-1~t5-4 ✓.
