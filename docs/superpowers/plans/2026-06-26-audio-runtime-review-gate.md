# 학습 오디오 런타임 노출 게이트 + audio_lecture 활성화 — 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `reviewStatus=approved`인 CLF 19문서의 오디오 미니플레이어를 프로덕션에 노출하고, 비-approved·미존재는 차단한다.

**Architecture:** 노출 게이트를 순수 함수 `shouldShowLecturePlayer`로 분리(위젯 밖 단위 테스트 가능)하고, 문서별 approved 여부는 `ContentEntry.audioApproved` 정적 필드로 둔다. 정적 필드와 SSOT(`audio_meta.json`의 `reviewStatus`)의 일치는 동기화 테스트가 강제한다(verified 문항 동적 불변식 패턴 재사용). 전체 마스터 `audio_lecture` 플래그는 유지하되 `pages.yml`에서 켠다.

**Tech Stack:** Flutter Web(Dart), `dart:io` File 기반 데이터 테스트, GitHub Actions(pages.yml).

## Global Constraints

- 모든 명령은 `flutter_app/` 디렉터리 기준.
- `flutter test` 전부 통과(현 기준선 그린). `flutter analyze` 신규 0건 — 기존 잔존 3건만 허용(`plan_agenda.dart` cacheExtent deprecated·`sync_controller_test.dart` 2건).
- TDD: 각 기능은 실패하는 테스트를 먼저 작성하고 최소 구현으로 통과시킨다(절대조건 2).
- 커밋 직전 항상 `git branch --show-current`로 `feat/audio-runtime-review-gate` 확인(§5 공유 워킹트리).
- web 빌드 명령은 PowerShell로 실행(Git Bash는 `/aws-docs/` 경로 변형 — [[flutter-build-web-powershell]]).
- `study_doc_page`는 위젯 렌더 테스트 금지(`SelectionArea`+비동기 페이지 "RenderBox was not laid out" 크래시 — [[flutter-selectionarea-widget-test-pitfall]]). 게이트 로직은 순수 함수 단위 테스트로 검증.

---

## File Structure

- **Modify** `lib/data/audio_runtime.dart` — 게이트 순수 함수 `shouldShowLecturePlayer` 추가(기존 `audioLectureEnabled` const 옆).
- **Create** `test/audio_runtime_test.dart` — 게이트 함수 진리표 단위 테스트.
- **Modify** `lib/data/content_index.dart` — `ContentEntry.audioApproved` 필드 + `lectureAudioMetaSrc` getter + CLF-C02 19개 엔트리에 `audioApproved: true`.
- **Modify** `test/content_index_test.dart` — audioApproved ↔ audio_meta 동기화 테스트 추가.
- **Modify** `lib/pages/study_doc_page.dart` — `_miniPlayer`·`_onDocReady` 게이트에 순수 함수 적용.
- **Modify** `.github/workflows/pages.yml` — `Build web` 스텝에 `--dart-define=audio_lecture=true`.

---

### Task 1: 게이트 순수 함수 `shouldShowLecturePlayer`

**Files:**
- Modify: `lib/data/audio_runtime.dart` (line 18 `audioLectureEnabled` const 아래에 추가)
- Test: `test/audio_runtime_test.dart` (신규)

**Interfaces:**
- Produces: `bool shouldShowLecturePlayer({required bool enabled, required bool approved, required bool hasDoc, required bool hasRuntime})` — 4조건 AND. Task 3이 호출.

- [ ] **Step 1: Write the failing test**

Create `test/audio_runtime_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_runtime.dart';

void main() {
  group('shouldShowLecturePlayer (순수 게이트)', () {
    test('4조건 모두 true → 노출', () {
      expect(
        shouldShowLecturePlayer(
            enabled: true, approved: true, hasDoc: true, hasRuntime: true),
        isTrue,
      );
    });
    test('approved=false → 미노출 (검수 안 된 문서)', () {
      expect(
        shouldShowLecturePlayer(
            enabled: true, approved: false, hasDoc: true, hasRuntime: true),
        isFalse,
      );
    });
    test('enabled=false → 미노출 (마스터 off)', () {
      expect(
        shouldShowLecturePlayer(
            enabled: false, approved: true, hasDoc: true, hasRuntime: true),
        isFalse,
      );
    });
    test('hasRuntime=false → 미노출 (VM/test)', () {
      expect(
        shouldShowLecturePlayer(
            enabled: true, approved: true, hasDoc: true, hasRuntime: false),
        isFalse,
      );
    });
    test('hasDoc=false → 미노출 (문서 로드 전)', () {
      expect(
        shouldShowLecturePlayer(
            enabled: true, approved: true, hasDoc: false, hasRuntime: true),
        isFalse,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/audio_runtime_test.dart`
Expected: 컴파일 실패 — `shouldShowLecturePlayer` 미정의.

- [ ] **Step 3: Write minimal implementation**

In `lib/data/audio_runtime.dart`, after line 18 (`const bool audioLectureEnabled = ...`), add:
```dart

/// 미니 플레이어 노출 게이트(순수 함수 — 위젯 밖에서 단위 테스트 가능하게 분리).
/// study_doc_page가 마스터 플래그·문서별 approved·문서 로드·런타임 존재를
/// 묶어 호출한다. 어느 하나라도 false면 미노출.
bool shouldShowLecturePlayer({
  required bool enabled,
  required bool approved,
  required bool hasDoc,
  required bool hasRuntime,
}) =>
    enabled && approved && hasDoc && hasRuntime;
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/audio_runtime_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git branch --show-current   # feat/audio-runtime-review-gate 확인
git add lib/data/audio_runtime.dart test/audio_runtime_test.dart
git commit -m "feat(audio): 미니플레이어 노출 게이트 순수 함수 shouldShowLecturePlayer"
```

---

### Task 2: `ContentEntry.audioApproved` 필드 + 동기화 테스트

**Files:**
- Modify: `lib/data/content_index.dart` (ContentEntry 생성자·필드·getter; CLF-C02 19개 엔트리)
- Test: `test/content_index_test.dart` (동기화 테스트 추가)

**Interfaces:**
- Consumes: `kContentIndex`, `ContentEntry.lectureAudioSrc`(기존).
- Produces: `ContentEntry.audioApproved` (bool, 기본 false), `ContentEntry.lectureAudioMetaSrc` (String, audio_meta.json 경로). Task 3이 `audioApproved`를 소비.

- [ ] **Step 1: Write the failing sync test**

In `test/content_index_test.dart`, the file already imports `dart:convert`, `dart:io`, and `content_index.dart`. Add this test inside `main()` (after the 동적 불변식 test):
```dart
  // ── 오디오 노출 동기화 (M2 런타임 게이트) ───────────────────────────
  // audioApproved=true ↔ audio_meta.json reviewStatus=approved + mp3 존재.
  // SSOT는 audio_meta.json(사람이 청취 후 approved 전환). 불일치 시 잘못된
  // 노출/404를 빌드 전에 차단(verified 문항 동적 불변식과 동일 패턴).
  test('동기화: audioApproved ↔ audio_meta.json reviewStatus + mp3 존재', () {
    final issues = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final meta = File(e.lectureAudioMetaSrc);
        final mp3 = File(e.lectureAudioSrc);
        String? status;
        if (meta.existsSync()) {
          final m =
              json.decode(meta.readAsStringSync()) as Map<String, dynamic>;
          status = m['reviewStatus'] as String?;
        }
        final metaApproved = status == 'approved' && mp3.existsSync();
        if (e.audioApproved != metaApproved) {
          issues.add(
              '${e.certCode}/${e.taskId}: audioApproved=${e.audioApproved} != meta(approved&&mp3)=$metaApproved (status=$status, mp3=${mp3.existsSync()})');
        }
      }
    }
    expect(issues, isEmpty,
        reason: 'audioApproved ↔ audio_meta 동기화 불일치:\n${issues.join('\n')}');
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/content_index_test.dart`
Expected: 컴파일 실패 — `audioApproved`·`lectureAudioMetaSrc` 미정의.

- [ ] **Step 3: Add field + getter (CLF 미등록 상태)**

In `lib/data/content_index.dart`, add to the `ContentEntry` constructor (after `required this.questionCount,`):
```dart
    this.audioApproved = false,
```
Add the field (after `final int questionCount;`):
```dart

  /// 청취 검수 완료(audio_meta.json reviewStatus=approved)된 오디오 강의 보유 여부.
  /// SSOT는 audio_meta.json — content_index_test의 동기화 테스트가 일치를 강제한다.
  /// study_doc_page가 노출 전 게이트로 검사(approved만 미니플레이어 표시).
  final bool audioApproved;
```
Add the getter (after the `lectureAudioSrc` getter):
```dart

  /// 오디오 메타(reviewStatus·체크섬) 경로. lectureAudioSrc와 같은 폴더.
  String get lectureAudioMetaSrc =>
      'assets/audio/${taskId.split('-').first}/$taskId/audio_meta.json';
```
Also update the `lectureAudioSrc` doc comment: replace the "M1은 placeholder(실제 mp3·메타는 T6·T9)" sentence with "실제 mp3·메타 등록됨(PR #62, approved CLF 19문서)."

- [ ] **Step 4: Run test to verify it fails on mismatch**

Run: `flutter test test/content_index_test.dart`
Expected: FAIL — CLF 19개가 `audioApproved=false`인데 audio_meta는 approved → 19 mismatch 리스트 출력.

- [ ] **Step 5: Register CLF 19 entries as approved**

In `lib/data/content_index.dart`, the `'CLF-C02'` list has 19 `ContentEntry`s (`clf-t1-1`~`clf-t4-3`). Add `audioApproved: true,` to **every** one of them (after its `questionCount:` line). Example for the first entry:
```dart
    ContentEntry(
      certCode: 'CLF-C02',
      taskId: 'clf-t1-1',
      title: 'AWS 클라우드의 이점',
      domain: 1,
      mdAsset: 'assets/content/clf/t1-1.md',
      questionsAsset: 'assets/content/clf/t1-1.questions.json',
      questionCount: 15,
      audioApproved: true,
    ),
```
Repeat `audioApproved: true,` for all 19 CLF-C02 entries. Do NOT add it to other certs (SAA/SOA) — they have no approved audio; the sync test will flag any mistake.

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/content_index_test.dart`
Expected: PASS (동기화 테스트 포함 전체 그린). If a CLF entry was missed, the mismatch list names it.

- [ ] **Step 7: Commit**

```bash
git branch --show-current
git add lib/data/content_index.dart test/content_index_test.dart
git commit -m "feat(audio): ContentEntry.audioApproved + audio_meta 동기화 테스트, CLF 19 등록"
```

---

### Task 3: `study_doc_page` 게이트 적용

**Files:**
- Modify: `lib/pages/study_doc_page.dart` (`_onDocReady` ~line 68, `_miniPlayer` ~line 98-107)

**Interfaces:**
- Consumes: `shouldShowLecturePlayer` (Task 1), `widget.entry.audioApproved` (Task 2), 기존 `audioLectureEnabled`·`audioRuntime`.

- [ ] **Step 1: Apply gate to `_onDocReady`**

In `lib/pages/study_doc_page.dart`, find (around line 68):
```dart
    if (audioLectureEnabled) {
      audioRuntime?.nowPlaying(widget.entry.title);
    }
```
Replace with:
```dart
    if (audioLectureEnabled && widget.entry.audioApproved) {
      audioRuntime?.nowPlaying(widget.entry.title);
    }
```

- [ ] **Step 2: Apply gate to `_miniPlayer`**

Find the `_miniPlayer` method (around line 98-107):
```dart
  Widget? _miniPlayer(StudyContent? doc) {
    if (!audioLectureEnabled || doc == null) return null;
    final runtime = audioRuntime;
    if (runtime == null) return null;
    return StudyAudioPlayer(
      controller: runtime.controller,
      title: widget.entry.title,
      audioSrc: widget.entry.lectureAudioSrc,
    );
  }
```
Replace with:
```dart
  Widget? _miniPlayer(StudyContent? doc) {
    final runtime = audioRuntime;
    if (!shouldShowLecturePlayer(
      enabled: audioLectureEnabled,
      approved: widget.entry.audioApproved,
      hasDoc: doc != null,
      hasRuntime: runtime != null,
    )) {
      return null;
    }
    return StudyAudioPlayer(
      controller: runtime!.controller,
      title: widget.entry.title,
      audioSrc: widget.entry.lectureAudioSrc,
    );
  }
```

- [ ] **Step 3: Verify analyze + existing tests (no widget render)**

Run: `flutter analyze`
Expected: 신규 0건(기존 잔존 3건만). `shouldShowLecturePlayer`·`audioApproved`가 해석됨.

Run: `flutter test`
Expected: 전체 PASS — `study_doc_page`를 직접 렌더하는 테스트는 없고, 라우팅(app_router_test)은 `audio_lecture` 기본 off라 영향 없음. 게이트 동작은 Task 1·2가 보장.

- [ ] **Step 4: Commit**

```bash
git branch --show-current
git add lib/pages/study_doc_page.dart
git commit -m "feat(audio): study_doc_page 미니플레이어를 approved 게이트로 노출"
```

---

### Task 4: `pages.yml` 프로덕션 활성화

**Files:**
- Modify: `.github/workflows/pages.yml` (line 37, `Build web` 스텝)

- [ ] **Step 1: Add dart-define to build command**

In `.github/workflows/pages.yml`, find (line 37):
```yaml
        run: flutter build web --release --base-href /aws-docs/
```
Replace with:
```yaml
        run: flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true
```

- [ ] **Step 2: Verify build locally (PowerShell)**

Run (PowerShell, NOT Git Bash):
```powershell
cd D:\workspace\awc-docs\flutter_app
flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true
```
Expected: 빌드 성공(`build/web` 생성). audio_lecture=true로 미니플레이어 코드가 트리 셰이킹에서 살아남는다. (배포 자체는 머지 후 CI가 수행.)

- [ ] **Step 3: Commit**

```bash
git branch --show-current
git add .github/workflows/pages.yml
git commit -m "ci(audio): pages.yml에 --dart-define=audio_lecture=true (프로덕션 활성화)"
```

---

## Self-Review

**1. Spec coverage:**
- 게이트 규칙(`audioLectureEnabled && audioApproved && doc && runtime`) → Task 1(순수 함수) + Task 3(적용). ✓
- `ContentEntry.audioApproved` 정적 필드 + CLF 19 → Task 2. ✓
- 동기화 테스트(audio_meta SSOT, mp3 존재, verified 패턴) → Task 2 Step 1. ✓
- `pages.yml` 활성화 → Task 4. ✓
- `lectureAudioSrc` 주석 갱신 → Task 2 Step 3. ✓
- SelectionArea 위젯 렌더 회피 → Task 3 Step 3(로직은 순수 함수로 검증). ✓
- 라이브 노출 영향 → Task 4(머지·릴리스 시 발생). ✓

**2. Placeholder scan:** 모든 코드 스텝에 실제 코드 포함. "19개 반복"은 대표 예시 + 동기화 테스트가 누락 강제(안전망). TODO/TBD 없음. ✓

**3. Type consistency:** `shouldShowLecturePlayer({enabled, approved, hasDoc, hasRuntime})` — Task 1 정의 ↔ Task 3 호출 시그니처 일치. `audioApproved`(bool)·`lectureAudioMetaSrc`(String) — Task 2 정의 ↔ Task 2 테스트·Task 3 사용 일치. ✓

## 비목표 (별도 spec)

③ 음질(PCM·loudness), ④ 환각 가드, 런타임 audio_meta 동적 fetch(옵션 B/C)는 본 계획 범위 밖. 정본 spec: `docs/superpowers/specs/2026-06-26-audio-runtime-review-gate-design.md`.
