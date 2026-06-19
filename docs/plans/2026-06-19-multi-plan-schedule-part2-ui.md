# 멀티 일정 — UI 배선 구현 Plan (Part 2/2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline) to implement task-by-task. Steps use checkbox (`- [ ]`).

**Goal:** Part 1의 데이터 계층 위에 UI를 배선해 빌드를 복구하고, 자격증당 여러 일정(자동/수동 생성·목록·선택·삭제)과 일정별 진행을 동작시킨다. 전체 `flutter test` 그린 복구가 종료 조건.

**Architecture:** plan_page를 "일정 목록 → 선택" 화면으로 바꾼다. 선택된 일정은 기존 `PlanAgenda`(단일 plan)를 planId 스코프 진행으로 재사용한다. 진행은 `PlanProgressStore`(planId별 done) 기반, 어젠다 체크박스로 토글. home의 요약/배너는 `plansFor` 리스트를 합산한다. 생성은 자동(기존 폼)·수동(유형+Task) 두 진입.

**Tech Stack:** Flutter, go_router, flutter_test. (PlanAgenda·plan_page는 SelectionArea 미사용 → 위젯 테스트 가능.)

## Global Constraints

- `flutter_app/` 기준. 종료 시 `flutter test` 전부 통과, `flutter analyze` 신규 0건.
- Part 1 API 사용: `StudyPlanStore.plansFor/add/update/removePlan`, `PlanProgressStore(donePlan/setDone/clearPlan)`, `computePlanDone(plan, done:, history:)`, `buildManualPlanItems(...)`, `buildPlan(planId:...)`.
- TDD: 위젯/단위 실패 테스트 선작성.
- **비범위(후속):** 문서 열람 시 일정 진행 자동 마킹(StudyDocPage planId 라우팅). 이번엔 어젠다 체크박스로 진행을 토글한다. 기간 겹침 안내 배지.

## File Structure

- Create: `lib/data/plan_progress_view.dart` — `Map<String,bool> planDone(StudyPlan, PlanProgressStore, List<AttemptRecord>)` 공통 헬퍼
- Modify: `lib/pages/home/schedule_section.dart` — `plansFor` 합산 요약
- Modify: `lib/pages/home_page.dart` — `_dueBanner`가 `plansFor`×`PlanProgressStore` 합산
- Modify: `lib/pages/plan/plan_agenda.dart` — `PlanProgressStore` 기반 진행/토글 + 삭제 콜백
- Modify: `lib/pages/plan_page.dart` — 일정 목록 → 선택, 생성(자동/수동) 진입, 삭제
- Modify: `lib/pages/plan/plan_create_form.dart` — 자동/수동 모드 토글, 수동은 유형+Task 다중선택
- Create: `lib/pages/plan/plan_list_view.dart` — 일정 카드 목록 위젯
- Tests: `test/plan_progress_view_test.dart`(신규), `test/plan_page_test.dart`(갱신), `test/plan_agenda_*`(필요 시), `test/home_schedule_section_test.dart`(갱신)

---

### Task 5: 진행 헬퍼 + home 배선 (빌드 복구 1/2)

**Files:**
- Create: `lib/data/plan_progress_view.dart`
- Modify: `lib/pages/home/schedule_section.dart`, `lib/pages/home_page.dart`
- Test: `test/plan_progress_view_test.dart`

**Interfaces:**
- Produces: `Map<String, bool> planDone(StudyPlan plan, PlanProgressStore progress, List<AttemptRecord> history)` → `computePlanDone(plan, done: progress.donePlan(plan.id), history: history)`

- [ ] **Step 1: 실패 테스트** — `test/plan_progress_view_test.dart`:

```dart
import 'package:aws_docs/data/plan_progress_view.dart';
import 'package:aws_docs/data/plan_progress_store.dart';
import 'package:aws_docs/models/study_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('planDone — PlanProgressStore의 done을 computePlanDone에 연결', () {
    final plan = StudyPlan(
      id: 'p1', certCode: 'CLF-C02', startIso: '2026-06-19', endIso: '2026-06-26',
      mode: PlanMode.period, createdIso: '2026-06-19',
      items: const [
        PlanItem(id: 'p1#doc:clf-t1-1:0', dateIso: '2026-06-19',
            type: PlanItemType.doc, phase: PlanPhase.learn, refId: 'clf-t1-1'),
      ],
    );
    final progress = PlanProgressStore(backend: MemoryBackend());
    expect(planDone(plan, progress, const [])['p1#doc:clf-t1-1:0'], isFalse);
    progress.setDone('p1', 'p1#doc:clf-t1-1:0', true);
    expect(planDone(plan, progress, const [])['p1#doc:clf-t1-1:0'], isTrue);
  });
}
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/plan_progress_view_test.dart`. Expected: FAIL(`plan_progress_view.dart` 없음).

- [ ] **Step 3: 구현**
  - Create `lib/data/plan_progress_view.dart`:
    ```dart
    import '../models/attempt_record.dart';
    import '../models/study_plan.dart';
    import 'plan_progress.dart';
    import 'plan_progress_store.dart';

    /// 일정별 진행(PlanProgressStore)을 computePlanDone에 연결하는 공통 헬퍼.
    Map<String, bool> planDone(
      StudyPlan plan,
      PlanProgressStore progress,
      List<AttemptRecord> history,
    ) =>
        computePlanDone(plan, done: progress.donePlan(plan.id), history: history);
    ```
  - Modify `lib/pages/home/schedule_section.dart`: `import`에 `plan_progress_store.dart`, `plan_progress_view.dart` 추가, `plan_check_store.dart`·`viewed_docs_store.dart` import 제거. `_label`을 리스트 합산으로:
    ```dart
    String _label(String code, StudyPlanStore planStore,
        PlanProgressStore progress, List<AttemptRecord> history, String todayIso) {
      final plans = planStore.plansFor(code);
      if (plans.isEmpty) return '시험일·기간을 정하면 일정 생성';
      var total = 0, doneN = 0;
      String? earliestEnd;
      for (final plan in plans) {
        final done = planDone(plan, progress, history);
        total += plan.items.length;
        doneN += done.values.where((v) => v).length;
        if (earliestEnd == null || plan.endIso.compareTo(earliestEnd) < 0) {
          earliestEnd = plan.endIso;
        }
      }
      final pct = total == 0 ? 0 : (doneN / total * 100).round();
      final left = daysBetween(todayIso, earliestEnd!);
      return '일정 ${plans.length}개 · D-${left < 0 ? 0 : left} · 진행 $pct%';
    }
    ```
    `build`의 `checkStore`/`viewedStore`를 `progress = PlanProgressStore()`로 교체하고 `_label` 인자도 맞춘다.
  - Modify `lib/pages/home_page.dart` `_dueBanner`: `import`에 `plan_progress_store.dart`·`plan_progress_view.dart` 추가. `planStore.planFor(cert.code)` 루프를 `for (final plan in planStore.plansFor(cert.code))`로 바꾸고, `computePlanDone(...manual:viewedTaskIds:)`를 `planDone(plan, progress, history)`로 교체. `active`는 plan 존재 cert 수, `oneCert`는 그 cert. (checkStore/viewedStore 제거, `progress = PlanProgressStore()` 추가.)

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/plan_progress_view_test.dart`. Expected: PASS. (home 위젯 테스트는 Task 7 후 전체 확인.)

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/plan_progress_view.dart flutter_app/lib/pages/home/schedule_section.dart flutter_app/lib/pages/home_page.dart flutter_app/test/plan_progress_view_test.dart
git commit -m "feat(plan): 진행 헬퍼 planDone + home 일정 요약/배너 리스트 배선"
```

---

### Task 6: PlanAgenda를 PlanProgressStore 기반으로 + 삭제 콜백

**Files:**
- Modify: `lib/pages/plan/plan_agenda.dart`

**Interfaces:**
- Consumes: `planDone`(Task 5), `PlanProgressStore`
- Produces: `PlanAgenda`에 `onDelete` 콜백 추가(없으면 미표시). 진행은 `PlanProgressStore` 기반.

- [ ] **Step 1: 구현(위젯 — 배선 변경, 테스트는 plan_page 통합에서)**
  - `import`: `plan_check_store.dart` 제거, `plan_progress_store.dart`·`plan_progress_view.dart` 추가.
  - 필드 `_checks` → `_progress = PlanProgressStore(backend: widget.backend)`.
  - `_done()`을 `planDone(widget.plan, _progress, _history.all())`로 교체(`computePlanDone(... manual:viewedTaskIds:)` 제거).
  - `_toggle(itemId, current)` → `_progress.setDone(widget.plan.id, itemId, !current); setState(() {});`
  - 생성자에 `final VoidCallback? onDelete;` 추가. 헤더 Row에 `onDelete != null`이면 삭제 IconButton(`Icons.delete_outline`) 추가(`onPressed: widget.onDelete`).
  - `redistribute`의 `onChanged` 흐름은 유지(plan.items 재배치).

- [ ] **Step 2: 빌드 확인** — Run: `flutter analyze lib/pages/plan/plan_agenda.dart`. Expected: 신규 에러 0.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/pages/plan/plan_agenda.dart
git commit -m "feat(plan): PlanAgenda 진행을 PlanProgressStore(planId)로 + 삭제 콜백"
```

---

### Task 7: plan_page 일정 목록 → 선택 + plan_list_view + 테스트

**Files:**
- Create: `lib/pages/plan/plan_list_view.dart`
- Modify: `lib/pages/plan_page.dart`
- Test: `test/plan_page_test.dart`(갱신)

**Interfaces:**
- Consumes: `StudyPlanStore.plansFor/add/removePlan`, `PlanAgenda`(onDelete), `PlanCreateForm`
- Produces: `PlanListView({required plans, required onOpen, required onCreate})` — 카드 목록 + "일정 추가" 버튼.

- [ ] **Step 1: 실패 테스트** — `test/plan_page_test.dart`를 새 API로 갱신. 핵심 케이스:

```dart
// 일정 없으면 생성 폼, 추가 후 목록에 노출, 카드 탭하면 어젠다
testWidgets('일정 없으면 생성 폼 표시', (tester) async {
  final b = MemoryBackend();
  await tester.pumpWidget(_host(PlanPage(cert: _cert, backend: b)));
  await tester.pump();
  expect(find.text('학습 일정 만들기'), findsOneWidget);
});

testWidgets('일정 추가 후 목록 카드 노출', (tester) async {
  final b = MemoryBackend();
  StudyPlanStore(backend: b).add(StudyPlan(
    id: '', label: '1주차', certCode: _cert.code, startIso: '2026-06-19',
    endIso: '2026-06-26', mode: PlanMode.period, createdIso: '2026-06-19',
    items: const []));
  await tester.pumpWidget(_host(PlanPage(cert: _cert, backend: b)));
  await tester.pump();
  expect(find.text('1주차'), findsOneWidget);
});
```
(`_host`는 ThemeScope+MaterialApp.router 또는 MaterialApp(home:). `_cert`는 certByCode('CLF-C02')!. 기존 plan_page_test의 헬퍼 패턴을 따른다. `save` 호출은 전부 제거.)

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/plan_page_test.dart`. Expected: FAIL(save 미정의/목록 미구현).

- [ ] **Step 3: 구현**
  - Create `lib/pages/plan/plan_list_view.dart`: `plans` 리스트를 카드로(라벨·기간·유형·항목 수), 탭→`onOpen(plan)`, 하단 "일정 추가"→`onCreate()`. (디자인은 DESIGN.md 토큰; ContentCertCard 스타일 참고.)
  - Modify `lib/pages/plan_page.dart`:
    - `_store.planFor` → `_store.plansFor(widget.cert.code)`로 `List<StudyPlan> _plans` 보관.
    - 상태: `_selected`(선택된 plan) / `_creating`(생성 폼). 분기:
      - `_creating==true` → `PlanCreateForm`(onSaved: add 후 목록)
      - `_selected!=null` → `PlanAgenda(plan: _selected!, onDelete: () { _store.removePlan(code, _selected!.id); PlanProgressStore(backend: backend).clearPlan(_selected!.id); setState(()=>_selected=null); reload; }, onChanged: (p)=>_store.update(p)...)`
      - else → `PlanListView(plans: _plans, onOpen: (p)=>setState(()=>_selected=p), onCreate: ()=>setState(()=>_creating=true))`
    - `_onSaved(p)` → `_store.add(p); setState((){_creating=false; reload _plans;})`.
  - `flutter test test/plan_page_test.dart` 통과.

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/plan_page_test.dart`. Expected: PASS.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/pages/plan/plan_list_view.dart flutter_app/lib/pages/plan_page.dart flutter_app/test/plan_page_test.dart
git commit -m "feat(plan): plan_page 일정 목록→선택 + 추가/삭제(진행 초기화) 배선"
```

---

### Task 8: 수동 생성 폼(유형 + Task 다중선택)

**Files:**
- Modify: `lib/pages/plan/plan_create_form.dart`
- Test: `test/plan_create_form_test.dart`(신규, 위젯)

**Interfaces:**
- Consumes: `buildManualPlanItems`, `planIdOf`, `contentFor`
- Produces: 생성 폼에 자동/수동 토글. 수동: 유형 선택 → (문서·연습) Task 체크리스트 → 기간 → `StudyPlan(source: manual, planType, taskIds, items: buildManualPlanItems(...))`.

- [ ] **Step 1: 실패 테스트** — `test/plan_create_form_test.dart`: 수동 모드에서 유형=문서·Task 2개 체크·저장 시 `onSaved`가 `source:manual, items.length==2`인 plan을 받는지.

```dart
testWidgets('수동 모드: 유형+Task 선택 후 저장하면 manual plan', (tester) async {
  StudyPlan? saved;
  await tester.pumpWidget(_host(PlanCreateForm(
    cert: _cert, today: '2026-06-19', onSaved: (p) => saved = p)));
  await tester.pump();
  // 수동 토글 → 문서 유형 → Task 2개 체크 → 저장 (정확한 finder는 구현 위젯에 맞춰 작성)
  // ...
  expect(saved!.source, PlanSource.manual);
  expect(saved!.items.length, 2);
});
```

- [ ] **Step 2: 실패 확인** — Run: `flutter test test/plan_create_form_test.dart`. Expected: FAIL.

- [ ] **Step 3: 구현** — `plan_create_form.dart`에 `_manual` 토글, 유형 `SegmentedButton<PlanItemType>`, 문서·연습이면 `contentFor(cert.code)` 체크리스트(`_selectedTaskIds`), 저장 시 분기:
  - 자동: 기존 `buildPlan(planId: planIdOf(cert.code, today, 0), ...)` (planId는 store.add가 최종 부여하므로 임시값 가능 — `id:''`로 두고 add가 부여)
  - 수동: `StudyPlan(id:'', label: <유형 라벨>, certCode, startIso, endIso, mode: period, createdIso: today, source: PlanSource.manual, planType: _type, taskIds: _selectedTaskIds, items: buildManualPlanItems(planId: 'tmp', planType: _type, taskIds: _selectedTaskIds, startIso:_start, endIso:_end))`
  - 주의: items의 itemId는 planId 기반인데 add가 최종 id를 부여한다. **저장 시 add가 부여한 planId로 items의 id를 재생성**해야 정합. → plan_page `_onSaved`에서 `add` 대신, store에 `addAndReindex`를 두거나, `add`가 `source==manual`일 때 items를 planId로 재생성하도록 Part 1 store를 보완. (구현 시 `StudyPlanStore.add`에서 `withId` 만들 때 `items`를 `planItemId(id, it.type, it.refId, idx)`로 재매핑.)

- [ ] **Step 4: 통과 확인** — Run: `flutter test test/plan_create_form_test.dart`. Expected: PASS.

- [ ] **Step 5: 전체 그린 + 커밋**

```bash
flutter test            # 전체 그린 복구 확인
flutter analyze         # 신규 0
git add -A flutter_app
git commit -m "feat(plan): 수동 일정 생성 폼(유형+Task) + add 시 itemId planId 재매핑"
```

---

## Self-Review

- **Spec 커버리지**: 일정 목록→선택(Task7), 자동/수동 생성(Task7·8), 일정 삭제 시 진행 초기화(Task7 onDelete→clearPlan), home 합산(Task5), 진행 planId 스코프(Task5·6). spec §5(진행)·§6(UI) 충족. 자동 열람 진행 마킹은 명시적 비범위(후속).
- **알려진 보완점**: 수동 일정의 itemId 정합을 위해 Task 8에서 `StudyPlanStore.add`가 manual plan의 items를 최종 planId로 재매핑한다(Part 1 store 보완). 이는 Task 8 Step 3에 포함.
- **타입 일관성**: `planDone`, `PlanAgenda.onDelete`, `PlanListView(plans/onOpen/onCreate)`, `removePlan`+`clearPlan` 연계가 task 간 일치.
- **종료 조건**: Task 8 Step 5에서 전체 `flutter test` 그린 + `flutter analyze` 신규 0. 이후 develop PR.
