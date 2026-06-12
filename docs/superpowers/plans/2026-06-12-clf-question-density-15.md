# CLF 문항 밀도 ≥15 심화 — 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CLF-C02 19개 Task의 verified 문항을 각 12→15로 끌어올린다(+57: 원리형 19·함정 혼동형 19·미커버 보완 19), 전 문항 사람 검수 게이트 통과.

**Architecture:** 순수 콘텐츠 작업(앱 코드 변경은 `content_index.dart` questionCount와 테스트 가드 2곳뿐). Task 단위 3단 루프(드래프터 → 통합 AI 리뷰어 → 컨트롤러 실측) × 도메인 4배치(D1~D4), 배치마다 본인 검수 게이트 → verified 반영 → main 병합·배포. 스펙: `docs/superpowers/specs/2026-06-12-clf-question-density-15-design.md`.

**Tech Stack:** JSON(`*.questions.json`), Dart(flutter_test), PowerShell(검증·추출·반영 스크립트).

---

**불변 규칙(모든 배치):**
- **verified=사람 검수만.** AI 초안은 전부 `"verified": false` — QuestionBank가 verified만 노출하므로 라이브 안전. AI가 verified를 true로 만드는 것 금지(게이트 반영 단계에서만, 검수 완료 확인 후).
- 기존 12문항·기존 본문·frontmatter 불가침. 신규 문항은 해당 고도화 문서(본문·🧠 블록·함정)와 frontmatter 출처 범위 내에서만 — **새 개념 도입 금지**(부족 시 같은 문서의 저커버 소재로 대체 + 사유 보고).
- 전 과정 테스트 그린 유지(초안 삽입은 노출·카운트 불변 → RED 단계 없음). 전체 스위트 기대값: `+451: All tests passed!` (이 작업으로 테스트 수는 변하지 않음).
- JSON 스타일: 기존 파일과 동일(2-스페이스 들여쓰기, 속성 순서·따옴표 동일, 마지막 속성 `"verified": false` — 반영 스크립트가 이 정확한 문자열을 치환하므로 **공백 포함 정확히** 이 형태로).

---

## 파일 구조

- Modify: `flutter_app/assets/content/clf/t{1-1..4-3}.questions.json` (19개 — `questions` 배열 끝에 3문항씩 추가)
- Modify: `flutter_app/lib/data/content_index.dart` (도메인 게이트마다 해당 Task들 `questionCount: 12,` → `15,`)
- Modify: `flutter_app/test/question_model_test.dart:18` (D4 게이트에서 `greaterThanOrEqualTo(12)` → `(15)`)
- Create(repo 밖, 도메인당): `C:\workspace\clf-q15-evidence-d{N}.json` (근거 사이드카) · `C:\workspace\clf-d{N}-q15-drafts_for_review.json` (검수 파일)
- 마무리: `HANDOFF.md` · 스펙 상태 줄 · 메모리 [[content-density-loop]]

---

## 표준 레시피 — Task 단위 루프 (19개 공통; 배치 Task에서 "레시피 적용"은 이것)

### R1. 드래프터 디스패치 (sonnet, 1 Task 1회)

프롬프트 필수 요소(컨트롤러가 주입):
- 읽기: 대상 문서 `flutter_app/assets/content/clf/t{X-Y}.md` 전체 + `t{X-Y}.questions.json` 전체(기존 12문항 소재·정답 포인트 파악) + 공식 시험 가이드 해당 Task skill 목록(문서 상단 커버 Task 참조).
- 작성: **정확히 3문항** — ①원리형(applied): 🧠 블록 원리의 새 시나리오 적용, 문서 자가점검 문항 전체와 소재·각도 중복 금지, 블록 문장 재진술 금지 ②함정 혼동형(applied): ⚠️ 함정 항목의 통념을 매력적 오답으로, 함정 교정 논리=정답 해설 근거 ③미커버 보완(foundational~applied): 기존 12문항이 안 다룬 skill — 문서 범위 밖이면 저커버 소재 대체+사유 보고.
- 스키마: `id`(기존 최대 연번 다음 — 실측, 통상 q13~q15) / `examGuideTaskId` / `skill` / `difficulty` / `stem` / `options[4]`(길이·톤 균형) / `correct` / `explanation` / `wrongExplanations`(정답 제외 3키, "왜 틀렸는지+어떤 혼동을 노렸는지") / `sources`(해당 문서 frontmatter 출처 범위) / `"verified": false`(정확히 이 형태).
- 금지(고도화 절제 규칙 이식): 무출처 수치·내부 구현/설계 의도 단정·새 기술 용어·기존 12문항과 정답 포인트 중복.
- 근거 사이드카: `C:\workspace\clf-q15-evidence-d{N}.json`(JSON 배열, 없으면 `[]`로 생성)에 문항당 `{"id": "...", "evidence": "원리형: §3 🧠 블록 / 함정형: 함정#2 / 보완: skill '...' (§5 본문)"}` 추가.
- 검증·커밋: 아래 R3 검증 스크립트 통과 + `flutter test`(전체, `+451` 그린) 확인 후 대상 questions.json만 커밋(푸시 금지):
  `feat(content): clf-t{X-Y} 문항 +3 초안 — 원리·함정·보완 (verified:false, 검수 전)` (+ Co-Authored-By 트레일러)
- 보고: 문항 3개 각 유형·소재·근거 § / id / 대체 발생 시 사유 / 테스트 마지막 줄 / 커밋 해시.

### R2. 통합 AI 리뷰어 디스패치 (sonnet, 수정 권한)

검사(전부 실제 수행, 위반 직접 수정 후 fix 커밋):
1. **사실 정확성**: 3문항의 정답·해설·오답해설을 문서 본문·🧠 블록·함정·출처와 대조 — 모순·범위 이탈 교정.
2. **중복 전수 대조**: 기존 12문항(정답 포인트·stem 소재) + 문서 자가점검 문항 전체와 1:1 — 중복이면 다른 각도로 재작성.
3. **유형 적합**: 원리형이 블록 재진술인지(재포장 금지), 함정형이 함정 항목과 실제 연결되는지, 보완형 skill이 실제 미커버인지.
4. **오답 품질**: 오답이 그럴듯한지(통념 기반), 정답 티(길이·구체성 차이) 없는지, wrongExplanations가 혼동 의도를 설명하는지.
5. **스키마·형식**: R3 스크립트 재실행 + `"verified": false` 정확 형태 + 근거 사이드카에 3건 존재.
- 경계 사례는 수정하지 말고 게이트 플래그로 보고. 보고: 발견(심각도·수정)·중복 대조표(3문항×기존 17소재 요약)·테스트 마지막 줄·fix 커밋 해시(수정 시 `fix(content): clf-t{X-Y} 문항 리뷰 반영 — <요지>`).

### R3. 컨트롤러 실측 (Task마다)

검증 스크립트(대상 파일 경로만 바꿔 실행):

```powershell
$p = 'C:\workspace\aws-docs\flutter_app\assets\content\clf\t1-1.questions.json'
$j = Get-Content $p -Raw | ConvertFrom-Json; $qs = $j.questions
"총 $($qs.Count) / verified $(($qs | Where-Object verified).Count) / 초안 $(($qs | Where-Object { -not $_.verified }).Count)"
if (($qs.id | Select-Object -Unique).Count -ne $qs.Count) { throw 'id 중복' }
foreach ($q in $qs | Where-Object { -not $_.verified }) {
  if ($q.options.Count -ne 4) { throw "$($q.id): options != 4" }
  $wk = $q.wrongExplanations.PSObject.Properties.Name
  if ($wk.Count -ne 3 -or ($wk -contains "$($q.correct)")) { throw "$($q.id): wrongExplanations 키 오류" }
  if (-not $q.sources) { throw "$($q.id): sources 비었음" }
}
$rawFalse = ([regex]::Matches((Get-Content $p -Raw), '"verified": false')).Count
if ($rawFalse -ne 3) { throw "verified:false 정확 형태가 $rawFalse개 (3 필요 — 반영 치환 전제)" }
'OK'
```

기대: `총 15 / verified 12 / 초안 3` + `OK`. 이어서 `cd C:\workspace\aws-docs\flutter_app; flutter test -r compact` 마지막 줄 `+451: All tests passed!` 직접 실측. fix 디프 스팟 체크(중복 대조표 vs 실제).

---

## 도메인 게이트 절차 (각 배치 공통 — "게이트 절차 적용"은 이것)

### G1. 리뷰 파일 추출

```powershell
$N = 1; $tasks = @('t1-1','t1-2','t1-3','t1-4')   # 배치별로 교체
$ev = Get-Content "C:\workspace\clf-q15-evidence-d$N.json" -Raw | ConvertFrom-Json
$out = @(); foreach ($t in $tasks) {
  $j = Get-Content "C:\workspace\aws-docs\flutter_app\assets\content\clf\$t.questions.json" -Raw | ConvertFrom-Json
  foreach ($q in ($j.questions | Where-Object { -not $_.verified })) {
    $q | Add-Member -NotePropertyName reviewEvidence -NotePropertyValue (($ev | Where-Object id -eq $q.id).evidence)
    $out += $q } }
ConvertTo-Json $out -Depth 10 | Set-Content "C:\workspace\clf-d$N-q15-drafts_for_review.json" -Encoding utf8
"추출 $($out.Count)문항"   # 기대: D1 12 / D2 12 / D3 24 / D4 9
```

### G2. **STOP — 본인 검수.** 검수 파일 경로 제시, 피드백 전 진행 금지.

### G3. 피드백 반영 → 재검증 → 수정 커밋 (`fix(content): D{N} 문항 게이트 검수 반영 — <요지>`)

### G4. verified 반영 + questionCount

```powershell
$tasks = @('t1-1','t1-2','t1-3','t1-4')   # 배치별로 교체
foreach ($t in $tasks) {
  $p = "C:\workspace\aws-docs\flutter_app\assets\content\clf\$t.questions.json"
  $raw = Get-Content $p -Raw
  $c = ([regex]::Matches($raw, '"verified": false')).Count
  if ($c -ne 3) { throw "$t : 치환 대상 $c개 (3 기대)" }
  [System.IO.File]::WriteAllText($p, $raw.Replace('"verified": false', '"verified": true'), [System.Text.UTF8Encoding]::new($false))
}
```

이어서 `content_index.dart`에서 배치 Task들의 엔트리만 Edit(엔트리는 `taskId: 'clf-t1-1',`로 유일 식별):

```dart
// 변경 전(각 Task 엔트리)        // 변경 후
questionCount: 12,            →  questionCount: 15,
```

검증: `flutter test -r compact` → `+451: All tests passed!` + R3 스크립트로 배치 파일들 재실측(`총 15 / verified 15 / 초안 0` — rawFalse 검사는 이 단계에선 해당 없음·생략). 커밋: `chore(content): D{N} 문항 검수 반영 — Task당 15 verified (본인 검수 완료)`.

### G5. main 병합·배포

`git checkout main && git pull && git merge --no-ff feat/clf-q15-d{N} -m "Merge feat/clf-q15-d{N}: CLF 문항 밀도 15 — D{N}"` → 머지본 `flutter analyze lib`(무이슈) + `flutter test -r compact`(`+451`) → `git push origin main`(=배포) → 브랜치 삭제(로컬·origin). 다음 배치는 main에서 새 브랜치.

---

### Task 1: D1 초안 — t1-1 ~ t1-4 (12문항)

**Files:** Modify `flutter_app/assets/content/clf/t1-{1..4}.questions.json`

- [ ] **Step 1:** `git checkout -b feat/clf-q15-d1` (main 최신에서)
- [ ] **Step 2:** t1-1 레시피 적용(R1→R2→R3)
- [ ] **Step 3:** t1-2 레시피 적용
- [ ] **Step 4:** t1-3 레시피 적용
- [ ] **Step 5:** t1-4 레시피 적용

### Task 2: D1 게이트 — **STOP** → 반영 → 병합·배포

- [ ] **Step 1:** G1 추출(`$N=1; $tasks=@('t1-1','t1-2','t1-3','t1-4')`) → 12문항 확인
- [ ] **Step 2:** G2 **STOP — 본인 검수** (게이트 플래그 목록 함께 제시)
- [ ] **Step 3:** G3 피드백 반영
- [ ] **Step 4:** G4 verified 반영 + questionCount 4건 12→15 + 테스트 + 커밋
- [ ] **Step 5:** G5 병합·배포·브랜치 삭제

### Task 3: D2 초안 — t2-1 ~ t2-4 (12문항)

**Files:** Modify `flutter_app/assets/content/clf/t2-{1..4}.questions.json`

- [ ] **Step 1:** `git checkout -b feat/clf-q15-d2`
- [ ] **Step 2~5:** t2-1, t2-2, t2-3, t2-4 레시피 적용

### Task 4: D2 게이트 — **STOP** → 반영 → 병합·배포

- [ ] Task 2와 동일 절차(`$N=2; $tasks=@('t2-1','t2-2','t2-3','t2-4')`)

### Task 5: D3 초안 — t3-1 ~ t3-8 (24문항)

**Files:** Modify `flutter_app/assets/content/clf/t3-{1..8}.questions.json`

- [ ] **Step 1:** `git checkout -b feat/clf-q15-d3`
- [ ] **Step 2~9:** t3-1 ~ t3-8 레시피 적용 (8회)

### Task 6: D3 게이트 — **STOP** → 반영 → 병합·배포

- [ ] Task 2와 동일 절차(`$N=3; $tasks=@('t3-1','t3-2','t3-3','t3-4','t3-5','t3-6','t3-7','t3-8')`, 추출 24문항)

### Task 7: D4 초안 — t4-1 ~ t4-3 (9문항)

**Files:** Modify `flutter_app/assets/content/clf/t4-{1..3}.questions.json`

- [ ] **Step 1:** `git checkout -b feat/clf-q15-d4`
- [ ] **Step 2~4:** t4-1, t4-2, t4-3 레시피 적용

### Task 8: D4 게이트 + 회귀 가드 상향 — **STOP** → 반영 → 병합·배포

**Files:** Task 2와 동일 + Modify `flutter_app/test/question_model_test.dart:18`

- [ ] **Step 1~3:** G1(`$N=4; $tasks=@('t4-1','t4-2','t4-3')`, 추출 9문항) → G2 **STOP** → G3
- [ ] **Step 4:** G4 + **가드 상향** — 19개 Task 전부 15가 된 시점:

```dart
// 변경 전
expect(rawVerified, greaterThanOrEqualTo(12)); // 밀도 목표(Task당 ≥12 verified)
// 변경 후
expect(rawVerified, greaterThanOrEqualTo(15)); // 밀도 목표(Task당 ≥15 verified)
```

- [ ] **Step 5:** `flutter test -r compact` → `+451: All tests passed!` → 커밋(가드 포함) `chore(content): D4 문항 검수 반영 — Task당 15 verified + 회귀 가드 12→15`
- [ ] **Step 6:** G5 병합·배포·브랜치 삭제

### Task 9: 마무리 — 문서·메모리 갱신

- [ ] **Step 1:** 스펙 상태 줄 갱신: `상태: 설계 승인됨(브레인스토밍) → 구현 플랜 대기` → `상태: **완료** — 19 Task 전부 15 verified(+57), D1~D4 게이트 통과(날짜)`
- [ ] **Step 2:** `HANDOFF.md` §0 갱신 — 완료 기록 + 다음 후보(백로그 ② SAA 문항 / ③ C-중량) 제시
- [ ] **Step 3:** 메모리 `content-density-loop.md` 진척 갱신(285문항·가드 15·다음 후보)
- [ ] **Step 4:** 커밋 `docs: CLF 문항 밀도 15 완료 — 핸드오프·스펙 상태 갱신` → push

---

## Self-Review 결과

- **스펙 커버리지:** §4 문항 규칙=R1·R2에 전부 주입(혼합형 구성·스키마·중복 금지·절제 규칙) / §5 파이프라인=R1~R3 / §6 4배치·점진 배포=Task 1~8(G1~G5) / §7 가드=Task 8 Step 4 / §2 "문서 보강 0"=불변 규칙·R1 대체 조항 / 검수 파일 § 병기=근거 사이드카+G1. 갭 없음.
- **플레이스홀더:** 문항 내용 자체는 의도적으로 미수록(레시피 1단계가 문서별 작업 — 고도화 롤아웃 플랜과 동일 구조, 같은 패턴으로 품질 수렴 검증됨). 스크립트·커맨드·커밋 메시지·기대값은 전부 실값.
- **타입/이름 일관성:** 파일 경로·브랜치명(`feat/clf-q15-d{N}`)·사이드카/검수 파일명·치환 문자열(`"verified": false`) Task 간 동일 확인. 수치 정합: 12+12+24+9=57, 4+4+8+3=19 ✓.
