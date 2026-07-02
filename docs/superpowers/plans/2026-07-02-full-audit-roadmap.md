# 전면 감사 → 개선 로드맵 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: 이 계획은 **superpowers:executing-plans(인라인 실행)** 로 실행한다. 감사 태스크 자체가 "서브에이전트 팬아웃 오케스트레이션"이라, 태스크를 또 서브에이전트에 위임하면 중첩 에이전트 제약(서브에이전트는 Agent 도구 없음)에 걸린다. 컨트롤러(메인 세션)가 태스크를 직접 수행하며 단계마다 체크박스(`- [ ]`)로 추적한다.

**Goal:** 코드·학습문서·문항·오디오(대본+재생)·의존성·관리위생 8차원 전수 감사를 2단 교차검증 파이프라인으로 실행하고, Phase A(시험 전)/B(시험 후) 로드맵과 관리위생 수정 PR을 산출한다.

**Architecture:** ①위생 수정(chore 브랜치, 코드+문서, PR 머지) → ②1단 발견(차원별 읽기 전용 에이전트 팬아웃, 샤드 리포트 파일) → ③2단 반박 검증(사실 의심 항목만, 판정 3값) → ④종합(차원 리포트 8건 + 사람 확인 목록 + ROADMAP.md, docs 브랜치 PR).

**Tech Stack:** Flutter 3.44.1/Dart 3.12.1(테스트·analyze 게이트), Agent 도구(팬아웃), PowerShell+gh CLI(git/PR), 스펙 = `docs/superpowers/specs/2026-07-02-full-audit-roadmap-design.md`.

## Global Constraints

- **레포 루트 절대경로**: `D:\workspace\awc-docs` / flutter 명령은 반드시 `D:\workspace\awc-docs\flutter_app`에서.
- **커밋 직전 매번** `git branch --show-current`로 의도한 브랜치인지 검증(CLAUDE.md §5 — 공유 워킹트리).
- **테스트 게이트**: `flutter test` 778개 전부 통과(위생 수정 후 기준선). **분석 게이트**: 위생 수정 이후 `flutter analyze` 0건.
- **감사는 읽기 전용**: 감사 에이전트는 코드·콘텐츠·`script.json`·`audio_meta.json`·reviewStatus를 절대 편집하지 않는다. 산출물은 지정된 신규 리포트 파일 1개뿐.
- **main 직접 push 금지**. 모든 변경은 브랜치→PR→develop. CI 녹색 확인 후 merge commit.
- **도구 실패 시** 같은 호출 2회 이상 반복 금지 — [오류/명령/추정 원인/대안] 보고.
- **에이전트 디스패치는 6개 이하 웨이브**로(과부하·검증 편의). 총 규모 ≈ 1단 51개 + 2단 의심 항목 수(수십 개 예상) — 토큰 비용 큼(사용자 승인된 전수 감사).

### 공통 리포트 형식 (모든 감사 샤드·차원 리포트)

```markdown
# {차원명} 감사 {샤드ID 또는 "종합"} — 2026-07
## 요약 (3~5줄)
## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
```
- ID = `{ID접두어}-001`부터 일련번호. 위치 = `file:line` 또는 `문서경로#헤딩앵커`.
- `사실의심 Y` = AWS 사실 오류 가능성 항목만(코드 결함·스타일은 N). 발견 0건이면 "발견 없음" 명시(빈 파일 금지).

### 감사 에이전트 공통 프롬프트 템플릿 (1단)

각 디스패치에서 `{…}`를 태스크의 값으로 채워 Agent 도구(`subagent_type: general-purpose`)에 전달한다:

```text
너는 읽기 전용 감사 에이전트다. 이 작업(단일 감사 샤드)만 수행하고, 끝나면 보고 후 정지하라.
다른 작업으로 진행하거나 명세에 없는 것을 즉흥 구현하지 말라. 명세가 부족하면 멈추고 NEEDS_CONTEXT로 보고하라.
[차원] {차원명}
[대상 파일 — 절대경로만 사용, cd 후 상대경로 금지(cwd가 리셋된다)] {파일 목록}
[점검 항목] {체크리스트}
[금지] 대상 파일 편집 금지. git 상태 변경 금지. 산출 리포트 파일 1개 외 어떤 파일도 만들지 말라.
[산출] {출력 절대경로} 에 아래 형식의 마크다운 리포트를 파일로 직접 작성하라(응답 본문이 아니라 파일이 정본 — 응답에는 "완료: 발견 N건"만).
{공통 리포트 형식 삽입}
ID 접두어는 {ID접두어}.
```

### 2단 반박 검증 프롬프트 템플릿

```text
너는 독립 검증자다. 이 작업(항목 1건 검증)만 수행하고 끝나면 정지하라.
아래 '의심 항목'이 오탐임을 적극적으로 반박하라. 근거는 대상 원문({원문 절대경로})과 AWS 공식 사실만. 필요 시 웹 검색 최대 2회.
판정은 반드시 3값 중 하나: REFUTED(오탐 — 반박 근거 제시) / CONFIRMED(의심 타당) / UNCERTAIN(판단 불가).
반박은 1회만 — 판정 후 재론·추가 조사 금지.
[의심 항목] {ID, 위치, 발견 내용, 발견자 근거}
[산출] {출력 절대경로} 파일에: ID / 판정 / 근거(3줄 이내)를 작성하라.
```

### 산출물 경로

- 샤드: `D:\workspace\awc-docs\docs\audits\2026-07\raw\{샤드ID}.md` / 검증: `...\raw\verify\{ID}.md`
- 차원 리포트: `D:\workspace\awc-docs\docs\audits\2026-07\01-code-quality.md` … `08-hygiene.md`
- `human-review-list.md`, `ROADMAP.md` — 같은 디렉터리.

---

### Task 1: docs 브랜치 + 스펙·플랜 커밋

**Files:**
- Commit: `docs/superpowers/specs/2026-07-02-full-audit-roadmap-design.md`, `docs/superpowers/plans/2026-07-02-full-audit-roadmap.md` (이미 작성돼 있음)

**Interfaces:** Produces: 브랜치 `docs/2026-07-02-full-audit-roadmap` (Task 15의 PR 대상).

- [ ] **Step 1: 브랜치 생성(이미 있으면 checkout만)**

Run: `git -C D:\workspace\awc-docs checkout -b docs/2026-07-02-full-audit-roadmap develop`
Expected: `Switched to a new branch` (이미 존재 오류 시: `git -C D:\workspace\awc-docs checkout docs/2026-07-02-full-audit-roadmap`)

- [ ] **Step 2: 브랜치 검증**

Run: `git -C D:\workspace\awc-docs branch --show-current`
Expected: `docs/2026-07-02-full-audit-roadmap`

- [ ] **Step 3: 커밋(직전 재검증 포함)**

```powershell
git -C D:\workspace\awc-docs add docs/superpowers/specs/2026-07-02-full-audit-roadmap-design.md docs/superpowers/plans/2026-07-02-full-audit-roadmap.md
git -C D:\workspace\awc-docs branch --show-current   # = docs/2026-07-02-full-audit-roadmap 확인
git -C D:\workspace\awc-docs commit -m "docs(audit): 전면 감사 로드맵 설계 스펙 + 구현 계획 (brainstorming/writing-plans)"
```

### Task 2: 위생 — analyze 잔존 3건 해소 (chore 브랜치)

**Files:**
- Modify: `flutter_app/lib/pages/plan/plan_agenda.dart:224-226`
- Modify: `flutter_app/pubspec.yaml:43-45` (dev_dependencies)
- Modify: `flutter_app/test/cloud/sync_controller_test.dart:51`

**Interfaces:** Produces: analyze 0건 상태(Task 3의 CLAUDE.md 문구 전제).

- [ ] **Step 1: chore 브랜치 생성·검증**

```powershell
git -C D:\workspace\awc-docs checkout -b chore/2026-07-audit-hygiene develop
git -C D:\workspace\awc-docs branch --show-current   # = chore/2026-07-audit-hygiene
```

- [ ] **Step 2: 현재 실패 상태 확인(레드 확인)**

Run: `flutter analyze` (in `D:\workspace\awc-docs\flutter_app`)
Expected: `3 issues found` (cacheExtent deprecated / fake_async depend_on_referenced_packages / unused_element_parameter)

- [ ] **Step 3: plan_agenda.dart 수정** — 226행 파라미터명 교체(+224행 주석 동기화):

```dart
// 변경 전(224-226):
              // (cacheExtent: 9999 핵 대신) 수 개월 플랜에서도 _runScrollToDate의
              // 스텝 횟수를 줄여 주는 정도의 보수적인 값.
              cacheExtent: 1200,
// 변경 후:
              // (scrollCacheExtent: 9999 핵 대신) 수 개월 플랜에서도 _runScrollToDate의
              // 스텝 횟수를 줄여 주는 정도의 보수적인 값.
              scrollCacheExtent: 1200,
```

- [ ] **Step 4: pubspec.yaml 수정** — dev_dependencies에 fake_async 추가(lock 파일 기존 해석 1.3.3):

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_async: ^1.3.3
```

- [ ] **Step 5: sync_controller_test.dart 수정** — `_ProbeController` 생성자에서 51행 한 줄 제거:

```dart
// 변경 전(45-52):
  _ProbeController({
    required super.auth,
    required super.cloud,
    required super.local,
    super.nowMs,
    super.syncInterval,
    super.onAppResume,
  });
// 변경 후:
  _ProbeController({
    required super.auth,
    required super.cloud,
    required super.local,
    super.nowMs,
    super.syncInterval,
  });
```

- [ ] **Step 6: 게이트 실행(그린 확인)**

```powershell
# in D:\workspace\awc-docs\flutter_app
flutter pub get        # Expected: Got dependencies!
flutter analyze        # Expected: No issues found!
flutter test           # Expected: 00:xx +778: All tests passed!
```

- [ ] **Step 7: 커밋**

```powershell
git -C D:\workspace\awc-docs branch --show-current   # = chore/2026-07-audit-hygiene
git -C D:\workspace\awc-docs add flutter_app/lib/pages/plan/plan_agenda.dart flutter_app/pubspec.yaml flutter_app/pubspec.lock flutter_app/test/cloud/sync_controller_test.dart
git -C D:\workspace\awc-docs commit -m "chore: analyze 잔존 3건 해소 (scrollCacheExtent·fake_async dev의존성·unused param) — analyze 0"
```

### Task 3: 위생 — TODOS.md·CLAUDE.md 갱신

**Files:**
- Modify: `TODOS.md` (완료 항목 2건 제거 + stale 경로 갱신)
- Modify: `CLAUDE.md` (기준선 499→778, analyze 문구)

**Interfaces:** Consumes: Task 2의 analyze 0 상태.

- [ ] **Step 1: TODOS.md 수정**
  - "## C-중량: …" 섹션(전체)과 "## AttemptRecord.wrongSkills[] …" 섹션(전체), 말미 stale-flag HTML 주석 블록을 **삭제**(둘 다 출고 완료: concept-deeplink Phase 1+2, PR#21).
  - "## 자격증별 문항 데이터 코드 스플리팅 (P3)" 섹션의 What 줄을 다음으로 교체:
    `- **What:** 콘텐츠 인덱스(\`flutter_app/lib/data/content_index.dart\`)와 문항 에셋 로드를 자격증 상세 진입 시 지연 로드(deferred)로 전환`

- [ ] **Step 2: CLAUDE.md 수정** — 빌드·테스트 절 2줄:
  - `flutter test` 주석: `(현재 기준선 499 그린)` → `(현재 기준선 778 그린)`
  - `flutter analyze` 주석: `— 신규 0건이 게이트(기존 잔존 3건: plan_agenda cacheExtent·sync_controller_test 2건)` → `— 0건이 게이트(2026-07-02 잔존 3건 해소)`
  - "**분석 게이트:**" 문장: `신규 경고·에러 0건. 기존 잔존 3건 외 새 항목이 보이면 머지 금지.` → `경고·에러 0건. 새 항목이 보이면 머지 금지.`

- [ ] **Step 3: 커밋**

```powershell
git -C D:\workspace\awc-docs branch --show-current   # = chore/2026-07-audit-hygiene
git -C D:\workspace\awc-docs add TODOS.md CLAUDE.md
git -C D:\workspace\awc-docs commit -m "docs: TODOS 완료 항목 정리 + CLAUDE.md 기준선 778·analyze 0 갱신"
```

### Task 4: 위생 — stale 원격 브랜치 삭제 + 메모리 갱신

**Files:** 없음(git 원격 + `C:\Users\deepe\.claude\projects\D--workspace-awc-docs\memory\` — 리포 외부, 컨트롤러 직접)

- [ ] **Step 1: 미머지 커밋 없음 선검증**

Run: `git -C D:\workspace\awc-docs log origin/develop..origin/feat/concept-deeplink --oneline`
Expected: 출력 없음(비어 있음). **출력이 있으면 삭제 중단하고 사용자 보고.**

- [ ] **Step 2: 원격 브랜치 삭제**

Run: `git -C D:\workspace\awc-docs push origin --delete feat/concept-deeplink`
Expected: `- [deleted]         feat/concept-deeplink`

- [ ] **Step 3: 메모리 파일 갱신(컨트롤러 직접, Write/Edit)** — 다음 사실 반영:
  - `cert-audio-page-feature.md`: PR#78 **머지됨**(2026-06-27).
  - `content-review-pipeline-planned.md`·`audio-runtime-gate-shipped.md`: 후속 ③음질(-16 LUFS 적용 확인)·④환각가드(PR#70~73) **완료**.
  - `concept-deeplink.md`: Phase 2 릴리스 반영 + 원격 브랜치 정리됨.
  - `work-priority-roadmap-phase0.md`: 테스트 기준선 778, analyze 0(2026-07-02).
  - `MEMORY.md` 인덱스 훅 문구 동기화.

### Task 5: 위생 PR 생성 → CI → 머지

- [ ] **Step 1: push + PR 생성**

```powershell
git -C D:\workspace\awc-docs push -u origin chore/2026-07-audit-hygiene
gh pr create --base develop --head chore/2026-07-audit-hygiene --title "chore: 관리위생 — analyze 0 달성 + TODOS/CLAUDE.md 현행화" --body "전면 감사 프로젝트(스펙 docs/superpowers/specs/2026-07-02-full-audit-roadmap-design.md §8)의 위생 수정 5건 중 1~4. analyze 3건 해소(scrollCacheExtent/fake_async/unused param), 기준선 778 반영, TODOS 완료 항목 정리, stale 브랜치 삭제. 게이트: flutter test 778 통과 + analyze 0."
```

- [ ] **Step 2: CI 녹색 확인(블로킹 CLI 사용 — sleep 폴링 금지)**

Run: `gh pr checks --watch` (해당 PR 번호로)
Expected: 전부 pass. 실패 시 머지 금지, 원인 규명 후 보고.

- [ ] **Step 3: 머지(merge commit)**

Run: `gh pr merge <PR번호> --merge`
Expected: Merged.

### Task 6: 감사 준비 — docs 브랜치 복귀 + develop 반영

- [ ] **Step 1:**

```powershell
git -C D:\workspace\awc-docs checkout docs/2026-07-02-full-audit-roadmap
git -C D:\workspace\awc-docs branch --show-current    # 재검증
git -C D:\workspace\awc-docs fetch origin
git -C D:\workspace\awc-docs merge origin/develop -m "merge: 위생 수정 반영"
```

- [ ] **Step 2: 문항 파일 인벤토리 확인(④ 입력 검증)**

Run: Glob `flutter_app/assets/content/**/*.questions.json`
Expected: 활성 25개(clf 19 + saa 6) 포함. 실제 목록을 Task 9 분할표와 대조, 불일치 시 분할표를 실제에 맞게 조정 후 진행.

### Task 7: 1단 — ①코드 품질(4 에이전트) + ②테스트 갭(1 에이전트)

**Files:** Create: `docs/audits/2026-07/raw/01-code-{a..d}.md`, `raw/02-test-gaps.md`, 종합 `01-code-quality.md`, `02-test-gaps.md`

- [ ] **Step 1: 웨이브 1 디스패치(5개 병렬)** — 공통 템플릿에 아래 값. 점검 항목(①): 250줄 초과 파일과 분해 후보 / 중복 패턴 / 미참조 심볼(dead code) / TODO·FIXME·HACK 인벤토리 / DESIGN.md 규율 위반(GestureDetector 단독 인터랙티브 — InkWell+FocusRing 필요, fontWeight에 Wght 토큰 미병기, 하드코딩 색·간격. 판단 기준은 `D:\workspace\awc-docs\DESIGN.md`를 먼저 읽고 적용).

| 샤드 | 대상(절대경로 접두 `D:\workspace\awc-docs\flutter_app\lib\`) | 출력 | ID접두어 |
|---|---|---|---|
| 01-code-a | `pages\`(하위 전체) | raw/01-code-a.md | CODE-P |
| 01-code-b | `data\`(cloud 포함) | raw/01-code-b.md | CODE-D |
| 01-code-c | `content\`·`models\`·`theme\`·`util\` | raw/01-code-c.md | CODE-C |
| 01-code-d | `widgets\`·`main.dart`·`app_router.dart`·`app_errors.dart` + ①의 DESIGN.md 규율 위반 전역 스윕 | raw/01-code-d.md | CODE-W |
| 02-test-gaps | `lib` 110개 vs `test` 77개 대응 맵: 테스트 없는 lib 파일 목록화, 위험 경로(오디오 재생 상태기계·sync 병합·plan 스케줄러·문항 샘플링) 커버리지 질 평가, SelectionArea 함정(메모리: 비동기 페이지 위젯테스트 불가)으로 위젯테스트가 불가능한 영역과 단위테스트 대체 존재 여부 명시 | raw/02-test-gaps.md | TEST |

- [ ] **Step 2: 샤드 검증** — 5개 파일 실재 + 형식(표 헤더) + 표본 2항목의 위치가 실제 파일과 일치하는지 컨트롤러가 직접 확인.
- [ ] **Step 3: 종합** — 컨트롤러가 01 샤드 4개를 `01-code-quality.md`로 병합(중복 항목 통합, 심각도 정렬), `02-test-gaps.md`는 샤드 승격(파일 복사 수준이면 헤더만 "종합"으로).
- [ ] **Step 4: 커밋** — 브랜치 재검증 후 `git add docs/audits` + `git commit -m "docs(audit): ①코드 품질·②테스트 갭 감사 리포트"`

### Task 8: 1단 — ③학습문서 사실성(14 에이전트)

**Files:** Create: `raw/03-docs-{clf-a..d,saa-a..e,soa-a..d}.md`, `raw/03-exam-guides.md`, 종합 `03-docs-facts.md`

- [ ] **Step 1: 분할표대로 3웨이브(5+5+4) 디스패치.** 점검 항목: AWS 사실 오류(서비스 설명·수치·한도·요금 모델·시험 범위 밖 내용) / 문서 내·문서 간 모순 / 예시·비유의 오해 소지. **사실의심 항목은 반드시 Y 플래그 + 발견자 근거 1줄.** 대상 경로 접두 `D:\workspace\awc-docs\flutter_app\assets\content\`:

| 샤드 | 대상 문서 | ID접두어 |
|---|---|---|
| 03-docs-clf-a | clf\t1-1.md, t1-2.md, t1-3.md, t1-4.md, t2-1.md | DOC-CLF |
| 03-docs-clf-b | clf\t2-2.md, t2-3.md, t2-4.md, t3-1.md, t3-2.md | DOC-CLF |
| 03-docs-clf-c | clf\t3-3.md, t3-4.md, t3-5.md, t3-6.md, t3-7.md | DOC-CLF |
| 03-docs-clf-d | clf\t3-8.md, t4-1.md, t4-2.md, t4-3.md | DOC-CLF |
| 03-docs-saa-a | saa\saa-t1-1.md … saa-t1-5.md | DOC-SAA |
| 03-docs-saa-b | saa\saa-t2-1.md … saa-t2-5.md | DOC-SAA |
| 03-docs-saa-c | saa\saa-t3-1.md … saa-t3-5.md | DOC-SAA |
| 03-docs-saa-d | saa\saa-t3-6.md … saa-t3-9.md, saa-t4-1.md | DOC-SAA |
| 03-docs-saa-e | saa\saa-t4-2.md … saa-t4-5.md | DOC-SAA |
| 03-docs-soa-a | soa\soa-t1-1.md … soa-t1-5.md | DOC-SOA |
| 03-docs-soa-b | soa\soa-t2-1.md … soa-t2-4.md, soa-t3-1.md | DOC-SOA |
| 03-docs-soa-c | soa\soa-t3-2.md … soa-t3-4.md, soa-t4-1.md, soa-t4-2.md | DOC-SOA |
| 03-docs-soa-d | soa\soa-t4-3.md, soa-t5-1.md … soa-t5-4.md | DOC-SOA |
| 03-exam-guides | **웹 검색 허용.** CLF-C02·SAA-C03·SOA-C03이 2026-07 현재도 현행 시험 버전인지, 후속 버전 발표·일정이 있는지 확인하고 `D:\workspace\awc-docs\flutter_app\assets\exam_guides\{CLF-C02,SAA-C03,SOA-C03}.json`의 도메인 구성과 대조 | GUIDE |

- [ ] **Step 2: 샤드 14개 실재·형식·표본 검증(각 샤드 1항목 원문 대조).**
- [ ] **Step 3: 종합 에이전트 1개** — 샤드 14개를 읽고 `03-docs-facts.md` 작성(중복 통합·심각도 정렬·사실의심 Y 목록 별도 절). 컨트롤러가 산출 검증.
- [ ] **Step 4: 커밋** `"docs(audit): ③학습문서 사실성 감사 리포트"`

### Task 9: 1단 — ④문항 품질(23 에이전트)

**Files:** Create: `raw/04-q-{clf-t1-1 … clf-t4-3}.md`(19개), `raw/04-q-saa-{a,b,c}.md`, `raw/04-q-inactive.md`, 종합 `04-questions.md`

- [ ] **Step 1: 4웨이브(6+6+6+5) 디스패치.** 점검 항목: 각 문항의 정답 유일성(다른 보기도 정답이 될 소지) / 해설-정답 일치 / wrongExplanations 논리 / `section` 앵커가 대응 md 문서의 `{#id}` 헤딩에 실존 / skill·difficulty 태그 일관성. 입력 = `…assets\content\{cert}\{doc}.questions.json` + 대응 md 문서(앵커 대조용). CLF 19개는 문서당 1에이전트(ID접두어 `Q-CLF`), SAA 활성 6개는 2문서/에이전트(04-q-saa-a: saa-t2-1+saa-t3-2 / b: saa-t3-4+saa-t3-5 / c: saa-t4-2+saa-t4-3, ID접두어 `Q-SAA`), 04-q-inactive 1개는 나머지 questions.json 전부의 스키마·verified:false 구조만 훑기(ID접두어 `Q-X`).
- [ ] **Step 2: 샤드 23개 실재·형식 검증 + 표본 3문항 원문 대조.**
- [ ] **Step 3: 종합 에이전트 1개** → `04-questions.md`. 컨트롤러 검증.
- [ ] **Step 4: 커밋** `"docs(audit): ④문항 품질 감사 리포트"`

### Task 10: 1단 — ⑤오디오 대본(5 에이전트)

**Files:** Create: `raw/05-audio-{a..e}.md`, 종합 `05-audio-scripts.md`

- [ ] **Step 1: 1웨이브(5개) 디스패치.** 입력 = `…assets\audio\clf\{docId}\script.json`(enrichedScriptText 필드) + 대응 원문 `…assets\content\clf\{t*.md}`. 점검: enrichment가 **추가**한 문장의 사실성(토큰보존 가드 사각 = '추가 환각') / 원문 의미 왜곡 / 발음 병기 일관성(`D:\workspace\awc-docs\flutter_app\tool\lexicon.json` 대조) / audio_meta.json chapters 제목-원문 헤딩 정합. 분할: a=t1-1~t1-4 / b=t2-1~t2-4 / c=t3-1~t3-4 / d=t3-5~t3-8 / e=t4-1~t4-3. ID접두어 `AUD`.
- [ ] **Step 2: 샤드 5개 검증(표본 1건 원문 대조).**
- [ ] **Step 3: 컨트롤러 병합** → `05-audio-scripts.md`.
- [ ] **Step 4: 커밋** `"docs(audit): ⑤오디오 대본 감사 리포트"`

### Task 11: 1단 — ⑥재생 코드(2) + ⑦의존성(1) + ⑧관리위생(1)

**Files:** Create: `raw/06-playback-{a,b}.md`, `raw/07-deps.md`, `raw/08-hygiene.md`, 종합 `06-audio-playback.md`, `07-deps.md`, `08-hygiene.md`

- [ ] **Step 1: 1웨이브(4개) 디스패치.**

| 샤드 | 대상·점검 | ID접두어 |
|---|---|---|
| 06-playback-a | `lib\data\audio_runtime.dart`·`audio_runtime_web.dart`·`audio_runtime_stub.dart`·`audio_nav.dart`·`media_session_binder.dart`·`audio_asset_url.dart` — 상태기계 엣지(문서 전환 중 재생·시크 경계·연속재생·다중 탭), 오류 복구(404·네트워크 끊김), 기지 iOS 함정(play() await 금지) 준수 | PLAY |
| 06-playback-b | `lib\pages\cert_audio_page.dart`·`audio_hub_page.dart`·`study_audio_player`(위젯)·`lecture_transport_bar`·`lecture_playlist`·`audio_progress_bar`·`audio_chapters` 관련 위젯 파일(Glob로 실제 경로 확인 후) — UI 상태 정합·접근성(InkWell+FocusRing)·174MB 자산 전송 평가(Range·캐시 헤더·초기 로드 영향, `web\` 설정 포함) | PLAY |
| 07-deps | `flutter_app\pubspec.yaml` + `flutter pub outdated` 실행(읽기 전용 명령 허용) — 패치/마이너 vs 메이저(go_router 16→17 브레이킹 체인지 웹 확인) vs Flutter 업그레이드 분류, 전부 Phase B 배치 | DEP |
| 08-hygiene | `TODOS.md`·`CLAUDE.md`·`AGENTS.md`·`DESIGN.md`·`docs\` 트리·`.gitignore`·pubspec 오디오 에셋 수동 나열(19×4줄) 자동화 여지 — 문서 간 불일치·아카이브 필요 스펙/플랜 목록화 | HYG |

- [ ] **Step 2: 샤드 4개 검증.**
- [ ] **Step 3: 컨트롤러 병합** → 06(2샤드 병합)·07·08 승격.
- [ ] **Step 4: 커밋** `"docs(audit): ⑥재생·⑦의존성·⑧위생 감사 리포트"`

### Task 12: 2단 — 반박 검증

**Files:** Create: `raw/verify/{항목ID}.md`(사실의심 항목 수만큼)

- [ ] **Step 1: 대상 수집** — `03-docs-facts.md`·`04-questions.md`·`05-audio-scripts.md`에서 `사실의심 Y` 항목 전부 목록화(컨트롤러).
- [ ] **Step 2: 검증자 디스패치** — 항목당 1에이전트, 2단 템플릿 사용, 6개 웨이브. 발견자 리포트가 아니라 **원문 파일**을 근거로 삼게 한다.
- [ ] **Step 3: 판정 집계** — 각 verify 파일 실재 + 판정값 3값 중 하나인지 확인. REFUTED 항목은 차원 리포트에 `(2단 REFUTED)` 주석 추가.
- [ ] **Step 4: 커밋** `"docs(audit): 2단 반박 검증 결과"`

### Task 13: 사람 확인 목록

**Files:** Create: `docs/audits/2026-07/human-review-list.md`

- [ ] **Step 1: 작성(컨트롤러)** — CONFIRMED + UNCERTAIN 항목만. 형식:

```markdown
# 사람 확인 목록 — 2026-07 전면 감사
정렬: 시험 영향 순(CLF 문항 > CLF 문서 > CLF 오디오 대본 > SAA 활성 문항 > 나머지)
| 순위 | ID | 위치 | 의심 내용 | 판정(CONFIRMED/UNCERTAIN) | 검증자 근거 요약 | 확인 방법 제안 |
```

- [ ] **Step 2: 표본 3건을 원문과 대조해 목록 정확성 자가 검증.**
- [ ] **Step 3: 커밋** `"docs(audit): 사람 확인 목록"`

### Task 14: ROADMAP.md + TODOS.md 반영

**Files:**
- Create: `docs/audits/2026-07/ROADMAP.md`
- Modify: `TODOS.md` (로드맵 요약 절 추가)

- [ ] **Step 1: ROADMAP.md 작성(컨트롤러)** — 8개 차원 리포트 + 사람 확인 목록의 H/M 항목을 스펙 §7 형식으로 편성:

```markdown
# 개선 로드맵 — 2026-07 전면 감사 기반
## Phase A (시험 전 ~4주 — 안정성 우선)
| 항목 | 근거(리포트 ID) | 크기(S/M/L) | 리스크 | 권장 시점 |
## Phase B (시험 후)
(동일 표. 필수 포함: 의존성 메이저·Flutter 업그레이드, 174MB 오디오 자산 전략, 리팩토링 상위 후보, SAA/SOA 확장 준비, 기계 게이트 스크립트화, 외부 검증자·유입 채널[TODOS 연계])
```
Phase A 편입 기준: 학습 방해 결함(콘텐츠 사실 오류·플로우/재생 버그)이면서 리스크 낮음. 그 외 전부 B.

- [ ] **Step 2: TODOS.md 상단에 요약 절 추가** — `## 2026-07 전면 감사 로드맵 (정본: docs/audits/2026-07/ROADMAP.md)` + Phase A 항목 리스트만.
- [ ] **Step 3: 커밋** `"docs(audit): 종합 로드맵 + TODOS 반영"`

### Task 15: docs PR → CI → 머지 → 완료 보고

- [ ] **Step 1: push + PR**

```powershell
git -C D:\workspace\awc-docs branch --show-current   # = docs/2026-07-02-full-audit-roadmap
git -C D:\workspace\awc-docs push -u origin docs/2026-07-02-full-audit-roadmap
gh pr create --base develop --head docs/2026-07-02-full-audit-roadmap --title "docs(audit): 2026-07 전면 감사 — 8차원 리포트·사람 확인 목록·로드맵" --body "스펙·플랜 + 감사 산출물 전체. 코드 변경 없음(문서만). 위생 수정은 선행 PR로 머지됨."
```

- [ ] **Step 2: CI 확인 → 머지** — `gh pr checks --watch` 전부 pass 후 `gh pr merge --merge`.
- [ ] **Step 3: 완료 보고** — 사용자에게: 리포트 8건 위치, 사람 확인 목록 건수(CONFIRMED/UNCERTAIN 분리), Phase A 항목 수와 최상위 3개, 다음 행동 제안(사람 확인 목록 검토가 1순위).

---

## Self-Review 체크 결과

- **스펙 커버리지**: §4 산출물 4종 → Task 7~14·5. §5 8차원 → Task 7~11. §6 2단·규율 → 템플릿+Task 12. §7 → Task 14. §8 위생 5건 → Task 2(3번)·3(1·2번)·4(4·5번). §9 게이트 → Task 2 Step 6·Task 5/15 CI. §10 함정 → Global Constraints. 갭 없음.
- **플레이스홀더**: 코드 스텝은 전부 실제 코드/명령 포함. 감사 스텝의 "점검 항목"은 프롬프트 원문으로 삽입되는 실제 내용임.
- **타입/이름 일관성**: 샤드 파일명·ID 접두어·산출 경로가 Global Constraints와 태스크 간 일치 확인.
