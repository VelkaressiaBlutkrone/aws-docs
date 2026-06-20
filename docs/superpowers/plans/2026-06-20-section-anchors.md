# 섹션 앵커 점진 확대 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline) to implement task-by-task. **콘텐츠 편집(slug 명명·문항 매핑)은 사람 의미 판단**이라 Task 2의 각 Task는 작업자가 학습문서를 읽고 명명한다. Steps use checkbox (`- [ ]`).

**Goal:** CLF 18 Task(clf-t1-1 제외) 학습문서에 의미 `{#slug}` 앵커 + 문항 `section`을 연결하고, Dart 가드로 "section ↔ 앵커 존재"를 검증한다.

**Architecture:** 먼저 검증 테스트(문항 section이 학습문서 앵커에 존재하는지)를 설치(Task 1) — 현재 clf-t1-1만 section이 있어 바로 그린. 그 다음 Task별로 헤딩 slug·문항 section을 의미 편집(Task 2), 매 Task 테스트가 오타·유실을 포착한다.

**Tech Stack:** Dart, `parseStudyDoc`(StudyContent 반환)·`MdHeading.anchor`·`contentFor`, flutter_test.

## Global Constraints

- 모든 flutter 명령은 **`flutter_app/` 기준 PowerShell**(메모리 `flutter-build-web-powershell`).
- **slug 규칙**: 소문자 영문 kebab(`[a-z0-9][a-z0-9-]*`, `markdown_parser`의 `_anchorRe`와 동일), 의미 기반, 헤딩 텍스트가 바뀌어도 유지(문항 `section` 계약), 한 문서 내 유일.
- `section`이 빈 문자열(`''`)인 문항은 통과(점진 — 미연결 허용).
- 기존 `all_content_parse_test`(전 md 파싱 회귀) 유지.
- **Task 2의 구체 slug·매핑은 사람 의미 판단** — plan은 절차를 명세하고, slug 값은 작업자가 학습문서를 읽고 산출한다(패턴 정본: clf-t1-1의 `core-benefits`·`ha-elasticity`·`global-infra`·`pitfalls`·`core-concepts`).

## File Structure

- Create: `flutter_app/test/section_anchor_link_test.dart` — 검증 가드(Task 1)
- Modify (Task 2, 다음 세션): `flutter_app/assets/content/clf/<taskId>.md`(헤딩 `{#slug}`) · `<taskId>.questions.json`(문항 `section`)

---

### Task 1: 검증 테스트 (Dart 가드)

**Files:**
- Create: `flutter_app/test/section_anchor_link_test.dart`

**Interfaces:**
- Consumes: `contentFor('CLF-C02')`(`lib/data/content_index.dart`) · `parseStudyDoc`·`MdHeading`(`lib/content/markdown_parser.dart`)

- [ ] **Step 1: 테스트 작성** — `flutter_app/test/section_anchor_link_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/data/content_index.dart';
import 'package:flutter_test/flutter_test.dart';

/// CLF 문항의 section(있으면)이 그 Task 학습문서의 실제 {#id} 앵커를 가리키는지 가드.
/// section 없는 문항은 통과(점진 — 미연결 허용). 오타·유실 시 실패.
void main() {
  for (final entry in contentFor('CLF-C02')) {
    test('${entry.taskId}: 문항 section이 학습문서 {#id} 앵커에 존재', () {
      final md = File(entry.mdAsset).readAsStringSync();
      final anchors = parseStudyDoc(md).blocks
          .whereType<MdHeading>()
          .map((h) => h.anchor)
          .whereType<String>()
          .toSet();
      final qjson = json.decode(File(entry.questionsAsset).readAsStringSync())
          as Map<String, dynamic>;
      final questions = (qjson['questions'] as List).cast<Map<String, dynamic>>();
      for (final q in questions) {
        final section = (q['section'] ?? '').toString();
        if (section.isEmpty) continue; // 미연결 허용(점진)
        expect(anchors.contains(section), isTrue,
            reason: '${q['id']} section "$section" 미존재 — '
                '${entry.taskId} 앵커: ${(anchors.toList()..sort())}');
      }
    });
  }
}
```

(주의: `StudyContent`에 `blocks` 필드, `MdHeading`에 `anchor`(없으면 null) 필드가 있다 — `study_content.dart`·`markdown_parser.dart`로 필드명만 확인하고 그대로 사용. CLF는 verified:true라 raw JSON 파싱으로 전 문항을 본다.)

- [ ] **Step 2: 실행** — Run(PowerShell): `cd flutter_app; flutter test test/section_anchor_link_test.dart`. Expected: PASS(현재 clf-t1-1의 section 6개가 모두 t1-1 앵커에 존재, 나머지 Task는 section 없어 통과). 실패 시 import·필드명 조정 후 재실행.

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/test/section_anchor_link_test.dart
git commit -m "test(content): 문항 section↔학습문서 앵커 존재 가드(CLF)"
```

---

### Task 2: CLF Task별 앵커·매핑 (반복 — 18 Task, 다음 세션)

`contentFor('CLF-C02')`의 **clf-t1-1을 제외한 18개 Task** 각각에 아래 절차를 적용한다. 한 Task = 독립 단위(편집 후 테스트·커밋). 구체 slug·매핑은 학습문서를 읽고 의미로 판단한다.

**Task당 절차:**

- [ ] **a. 헤딩 slug** — `assets/content/clf/<taskId>.md`를 읽고, 문항이 가리킬 만한 주요 개념 섹션 헤딩 끝에 `{#slug}`를 부여한다. 예(clf-t1-1 패턴): `### 클라우드의 핵심 이점 {#core-benefits}`. slug는 Global Constraints의 규칙을 따른다.
- [ ] **b. 문항 section** — `<taskId>.questions.json`의 각 문항에서, 그 문항이 다루는 섹션의 slug를 `"section"`에 기입한다. 명확한 대응 섹션이 없으면 빈 문자열(미연결 — 폴백 허용).
- [ ] **c. 검증** — Run(PowerShell): `cd flutter_app; flutter test test/section_anchor_link_test.dart`. Expected: PASS(그 Task의 모든 section이 실제 앵커를 가리킴). 실패 시 slug 오타·매핑 수정.
- [ ] **d. 커밋** — `git commit -m "content(clf): <taskId> 섹션 {#id} 앵커 + 문항 section"`

**18 Task 체크리스트** (작업자가 `contentFor('CLF-C02')` 순서대로, clf-t1-1 제외):

- [ ] 도메인 1(보안) 나머지 Task
- [ ] 도메인 2(기술) Task 전부
- [ ] 도메인 3(클라우드 개념 외) Task 전부
- [ ] 도메인 4(청구·지원) Task 전부

(정확한 taskId 목록은 `lib/data/content_index.dart`의 `kContentIndex['CLF-C02']`에서 `clf-t1-1`을 뺀 18개. 한 Task 끝낼 때마다 c·d로 테스트·커밋.)

- [ ] **마무리: 전체 회귀** — Run(PowerShell): `cd flutter_app; flutter test`. Expected: 전체 그린(신규 가드 + all_content_parse_test 포함). `flutter analyze` 신규 0.

---

## Self-Review

- **Spec 커버리지**: §4 방식(헤딩 slug·문항 section·테스트 = Task 2 a·b·c) · §5 품질 가드(section↔앵커 존재 = Task 1) · §6 slug 규칙(Global Constraints) · §8 테스트(신규 가드 + all_content_parse 회귀). 전 항목 커버.
- **No Placeholders(절차)**: Task 1은 완전한 테스트 코드. Task 2는 콘텐츠 편집이라 slug 값이 데이터(사람 산출) — 절차·검증·커밋은 완전 명세.
- **타입 일관성**: `contentFor('CLF-C02')`·`parseStudyDoc(...).blocks`·`MdHeading.anchor`·`q['section']`이 Task 1↔Task 2 검증 루프에서 일치.
- **구현 분리**: Task 1·2 모두 **다음 세션**에서 executing-plans로 진행(이 세션은 spec·plan까지). Task 1(가드)을 먼저 그린으로 깔고 Task 2 편집.

## 비범위
- SAA 앵커(B-① 검수·flip 후) · 자동 slug 생성 · node 도구 · 전 Task 일괄(점진).
