# Phase 0 — 정리/부채 상환 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 로드맵 Phase 0의 코드/문서 부채를 갚는다 — `_MockLoad` 타입 안전 하드닝, quiz_widgets 간격 토큰화, DESIGN.md 폰트 표기 정정. **신규 기능 없음, 회귀 0.**

**Architecture:** 모두 동작 보존 리팩터/문서 수정. `_MockLoad`의 상관 nullable 2필드를 단일 nullable 레코드로 묶어 불변식을 타입으로 강제(런타임 `!` 제거). quiz_widgets의 잔여 간격 리터럴을 기존 `Gap` 토큰으로 교체(토큰 값 = 리터럴 값이라 렌더 불변). DESIGN.md 폰트 로딩 표기를 실제 번들 방식으로 정정.

**Tech Stack:** Flutter Web (Dart), 기존 테마 토큰(`Gap`/`Radii`/`Layout` in `lib/theme/app_theme.dart`).

**경로 주의:** 코드는 `D:\workspace\awc-docs\flutter_app` (핸드오프의 `aws-docs\flutter_app`는 이 체크아웃에선 틀림 — flutter_app이 git 루트 바로 아래). flutter 명령은 **PowerShell**로, `flutter_app`에서 실행. git은 루트(`D:\workspace\awc-docs`)에서.

**스펙:** `docs/superpowers/specs/2026-06-07-work-priority-roadmap-design.md` §3.

---

## 선행 확인 (구현 전 1회)

- [ ] **항목 ② (QuizPage 로드에러 vs 빈-bank 분기)는 이미 구현됨을 확인하고 작업에서 제외**

`flutter_app/lib/pages/quiz_page.dart:42-52`를 열어 아래 두 분기가 이미 존재하는지 눈으로 확인:
- `if (snap.hasError)` → '문항을 불러오지 못했습니다.'
- `if (bank == null || bank.questions.isEmpty)` → '검증된 연습 문제가 아직 없습니다.'

`ExamPage`(`exam_page.dart:519-529`)와 동일 구조. **이미 분기되어 있으므로 코드 변경 없음.** 핸드오프 노트가 stale였음. 변경할 게 있다고 느껴지면 멈추고 재확인.

---

## Task 1: `_MockLoad` nullability 하드닝

`CertExamPage._MockLoad`의 `existing`(`ExamSession?`)·`restoredQuestions`(`List<Question>?`)는 "둘 다 null 또는 둘 다 non-null" 불변식을 갖지만 타입으로 강제되지 않아 소비처에서 `!`(bang)를 쓴다. 둘을 단일 nullable 레코드 `_Restorable?`로 묶어 불변식을 타입으로 표현하고 `!`를 제거한다. **동작은 완전히 동일.**

**Files:**
- Modify: `flutter_app/lib/pages/cert_exam_page.dart`

- [ ] **Step 1: 기준선 — 기존 테스트가 green인지 확인**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: analyze 이슈 0, 전체 테스트 PASS(현재 41). 여기서 실패하면 먼저 원인 파악(이 작업과 무관한 사전 깨짐).

- [ ] **Step 2: `_Restorable` 레코드 클래스 추가**

`cert_exam_page.dart` 파일 끝, `_MockLoad` 클래스 **바로 위**에 추가:
```dart
/// 복원 가능한 진행 세션 — 세션과 그에 맞춰 정렬 복원된 문항은 항상 함께 존재한다.
/// (둘 중 하나만 있는 상태를 타입으로 배제.)
class _Restorable {
  const _Restorable(this.session, this.questions);
  final ExamSession session;
  final List<Question> questions;
}
```

- [ ] **Step 3: `_MockLoad`의 상관 2필드를 `_Restorable?` 한 필드로 교체**

`_MockLoad` 클래스를 아래로 교체:
```dart
/// 로드 결과(풀·인덱스·가중·메타·복원 후보).
class _MockLoad {
  const _MockLoad({
    required this.pool,
    required this.weights,
    required this.overview,
    required this.total,
    required this.restorable,
  });
  final Map<int, List<Question>> pool;
  final Map<int, int> weights;
  final ExamOverview? overview;
  final int total;
  final _Restorable? restorable;
}
```

- [ ] **Step 4: `_load()`의 생성부를 레코드 기반으로 교체**

`_load()` 내부, 현재의 복원 블록(`final existing = _store.load(_examId);` 부터 `return _MockLoad(... restoredQuestions: restored);` 까지)을 아래로 교체:
```dart
    // 복원 가능한 진행 세션?
    final existing = _store.load(_examId);
    _Restorable? restorable;
    if (existing != null && !existing.submitted) {
      final restored = restoreOrdered(existing.questionIds, byId);
      if (restored == null) {
        _store.clear(_examId); // 개정/불일치 폐기
      } else {
        restorable = _Restorable(existing, restored);
      }
    }

    return _MockLoad(
      pool: pool,
      weights: weights,
      overview: overview,
      total: all.length,
      restorable: restorable,
    );
```

- [ ] **Step 5: `_resume`가 `_Restorable`을 받도록 변경(`!` 제거)**

현재:
```dart
  void _resume(_MockLoad d) {
    setState(() =>
        _running = _RunParams.restored(d.existing!, d.restoredQuestions!));
  }
```
교체:
```dart
  void _resume(_Restorable r) {
    setState(() => _running = _RunParams.restored(r.session, r.questions));
  }
```

- [ ] **Step 6: `_startScreen`에서 복원 후보를 캡처해 `!` 없이 사용**

`_startScreen(_MockLoad d)` 안에서, 복원 분기를 `d.restoredQuestions != null` 대신 캡처한 지역변수로 처리한다. `final pass = d.overview?.passingScore;` 줄 **아래**에 다음을 추가:
```dart
    final restorable = d.restorable;
```
그리고 버튼 분기(`if (d.restoredQuestions != null) ...[ ... ] else ...`)를 아래로 교체:
```dart
              if (restorable != null) ...[
                SizedBox(
                    width: 220,
                    child: PrimaryButton(
                        label: '이어서 풀기', onTap: () => _resume(restorable))),
                const SizedBox(height: Gap.sm),
                InkWell(
                  onTap: () => _startFresh(d),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: Gap.sm, horizontal: Gap.xs),
                    child: Text('새로 시작',
                        style: TextStyle(
                            color: c.textMuted, fontWeight: FontWeight.w700)),
                  ),
                ),
              ] else
                SizedBox(
                    width: 220,
                    child:
                        PrimaryButton(label: '시작', onTap: () => _startFresh(d))),
```

- [ ] **Step 7: analyze + 테스트로 회귀 0 확인**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: analyze 이슈 0(특히 잔여 `d.existing`/`d.restoredQuestions` 참조 없음), 전체 테스트 PASS(41). 컴파일 에러가 나면 Step 3~6에서 놓친 옛 필드 참조가 있는지 확인.

- [ ] **Step 8: 복원 경로 dogfood 스모크 (선택, 권장)**

페이지 위젯은 SelectionArea 함정으로 렌더 테스트 불가 → 헤드리스 dogfood로 동작 확인. PowerShell, `flutter_app`에서:
```
flutter build web --base-href /
py -m http.server 5151 --directory build\web
```
gstack browse로 `http://localhost:5151/#/cert/CLF-C02/exam` 열고(CanvasKit라 'Enable accessibility' JS click 후 @ref 구동) → '시작' → 문항 1~2개 응답 → 새로고침 → 시작화면에 **'이어서 풀기'** 노출 → 클릭 시 진행 복원되는지 확인. (불가하면 Step 7로 충분, 이 스텝은 생략 가능.)

- [ ] **Step 9: 커밋**

git 루트(`D:\workspace\awc-docs`)에서:
```
git add flutter_app/lib/pages/cert_exam_page.dart
git commit -m "refactor: CertExamPage _MockLoad 복원 후보를 단일 _Restorable 레코드로 하드닝"
```

---

## Task 2: quiz_widgets 간격 토큰화

`quiz_widgets.dart`에 `Gap` 토큰을 우회하는 간격 리터럴 2곳이 남아 있다. 기존 토큰으로 교체한다. **토큰 값 = 리터럴 값(`Gap.xs`=4, `Gap.xs2`=2)이라 렌더 100% 동일.** 폰트 크기·테두리 두께 리터럴은 이 작업 범위 밖(아래 "범위 밖" 참조).

**Files:**
- Modify: `flutter_app/lib/content/quiz_widgets.dart`

- [ ] **Step 1: ExplainBox의 `SizedBox(height: 4)` → `Gap.xs`**

`ExplainBox.build`의 라벨과 본문 사이:
```dart
          const SizedBox(height: 4),
```
교체:
```dart
          const SizedBox(height: Gap.xs),
```

- [ ] **Step 2: ResultCard `_answerLine`의 `EdgeInsets.only(bottom: 2)` → `Gap.xs2`**

`_answerLine`의 Padding:
```dart
      padding: const EdgeInsets.only(bottom: 2),
```
교체:
```dart
      padding: const EdgeInsets.only(bottom: Gap.xs2),
```

- [ ] **Step 3: 잔여 간격 리터럴이 없는지 확인**

`quiz_widgets.dart`에서 `height: <숫자>`/`bottom: <숫자>`/`EdgeInsets`에 raw 숫자가 남았는지 검토. (남은 숫자 리터럴은 전부 `fontSize`·border `width`·line `height`(1.5/1.6)로, 이 작업 범위 밖 — 의도적으로 두는 것.)

- [ ] **Step 4: analyze + 테스트**

PowerShell, `flutter_app`에서:
```
flutter analyze
flutter test
```
Expected: 이슈 0, 전체 PASS(41).

- [ ] **Step 5: 커밋**

git 루트에서:
```
git add flutter_app/lib/content/quiz_widgets.dart
git commit -m "refactor: quiz_widgets 잔여 간격 리터럴을 Gap 토큰으로 교체(렌더 불변)"
```

**범위 밖 (의도적 — 별도 결정 필요):** quiz_widgets의 `fontSize`(12·14·15)·테두리 `width`(1·2·3) 리터럴은 토큰화하지 않는다. 이유: ① 폰트 크기 토큰이 아직 없고, DESIGN.md 타입 스케일(13·15·16·17·20·28)이 코드 실제값(12·14)과 어긋나 토큰화하려면 "코드값 유지 vs DESIGN.md 정렬(소폭 시각 변화)" 결정이 필요 → 사용자 승인 후 별도 작업. ② 테두리 두께 토큰은 DESIGN.md에 정의 없음. (브레인스토밍 2026-06-07 결정: 간격만 토큰화.)

---

## Task 3: DESIGN.md 폰트 표기 정정

DESIGN.md §Typography "로딩 (CDN, SRI 고정)" 항목은 외부 CDN+SRI 방식을 기술하지만, 실제 구현은 **pubspec 번들 OTF/TTF**(같은 문서 line 7이 "폰트는 OTF/TTF 에셋 번들"이라 이미 명시 — 자체 모순). 문서를 실제 사실에 맞게 정정한다. **코드 무변경.**

**Files:**
- Modify: `DESIGN.md` (git 루트)

- [ ] **Step 1: "로딩 (CDN, SRI 고정)" 블록을 번들 방식으로 교체**

DESIGN.md §Typography에서 현재 블록:
```markdown
- **로딩 (CDN, SRI 고정):**
  - Pretendard: `https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css`
    `integrity="sha384-uGEvnSEpW2nM9xJFsrxrwakwrk9QdDTQIBJh0hVMu90OaVyMAMpAK1rIn0/Kh1/k"` crossorigin
  - JetBrains Mono: `https://cdn.jsdelivr.net/npm/@fontsource/jetbrains-mono@5.1.1/index.css`
    `integrity="sha384-8X0qYYsBdYZ9bk70hw4HTDsWIeMfYCwYmUcsezfamiqI024ZDkBKbaTx68Kwh6wx"` crossorigin
  - 모든 외부 CSS는 SRI integrity + crossorigin 필수
```
교체:
```markdown
- **로딩 (로컬 번들 — 오프라인·무추적):** 폰트는 외부 CDN이 아니라 앱에 번들된 OTF/TTF 에셋으로 로드한다.
  - Pretendard / JetBrains Mono: `flutter_app/pubspec.yaml`의 `fonts:` 선언으로 등록(`flutter_app/assets/fonts/` 또는 패키지 에셋). `app_theme.dart`가 `Pretendard`/`JetBrainsMono` 패밀리로 참조.
  - 근거: GitHub Pages 정적 배포 + 한국어 학습 제품 — CDN 의존·외부 추적·SRI 관리 비용을 피하고 오프라인에서도 렌더. (자세한 번들 목록은 pubspec이 단일 진실.)
```

- [ ] **Step 2: 정정 결과 점검**

DESIGN.md를 다시 읽어 §Typography가 line 7("OTF/TTF 에셋 번들")과 더는 모순되지 않는지, `font stack`/`스케일` 항목은 그대로 보존됐는지 확인. (font stack·스케일은 변경하지 않는다.)

- [ ] **Step 3: 실제 pubspec 폰트 선언과 표기 일치 확인**

`flutter_app/pubspec.yaml`의 `fonts:` 섹션(또는 폰트 패키지 의존성)을 열어, 정정한 문구가 실제 등록 방식(에셋 경로/패키지)과 일치하는지 확인. 어긋나면 문구를 실제에 맞춤(문서를 코드 사실에 맞추는 것이 목적). family 이름은 `app_theme.dart`의 `_sans='Pretendard'`·`_mono='JetBrainsMono'`와 일치해야 함.

- [ ] **Step 4: 커밋**

git 루트에서:
```
git add DESIGN.md
git commit -m "docs: DESIGN.md 폰트 로딩 표기를 실제(로컬 번들 OTF/TTF)에 맞게 정정"
```

---

## Task 4: Phase 0 게이트 검증

Phase 0 완료 게이트(스펙 §3)를 한 번에 확인한다.

**Files:** 없음(검증만).

- [ ] **Step 1: analyze 무결**

PowerShell, `flutter_app`에서:
```
flutter analyze
```
Expected: "No issues found!"

- [ ] **Step 2: 전체 테스트 green**

```
flutter test
```
Expected: All tests passed (현재 41 — Phase 0는 테스트 수를 늘리지 않음, 회귀 0).

- [ ] **Step 3: 릴리스 web 빌드 성공**

```
flutter build web --release --base-href /aws-docs/
```
Expected: 빌드 성공(에러 0).

- [ ] **Step 4: 핸드오프·메모리 현행화**

`docs/plans/2026-06-06-session-handoff.md`를 갱신: Phase 0 완료 사실, "이중 폴더" 경로 정정(`flutter_app`이 루트 바로 아래), 항목 ②가 이미 구현됐던 점, 항목 ③ 폰트 토큰은 후속(DESIGN.md 정렬 결정 대기) 기록. 크로스세션 메모리 인덱스(`MEMORY.md`)에 Phase 0 완료 한 줄 반영. 그 후 커밋:
```
git add docs/plans/2026-06-06-session-handoff.md
git commit -m "docs: Phase 0 정리 완료 핸드오프 현행화(경로 정정·항목② 기완료·폰트 토큰 후속)"
```

---

## Self-Review (작성자 점검 완료)

- **스펙 커버리지:** 스펙 §3의 4개 항목 — ①_MockLoad=Task 1, ②QuizPage=선행 확인(이미 완료), ③quiz_widgets=Task 2(간격만, 결정 반영), ④DESIGN.md=Task 3. 게이트(analyze+테스트+빌드)=Task 4. 누락 없음.
- **플레이스홀더 스캔:** TBD/TODO/"적절히 처리" 없음. 모든 코드 스텝에 실제 코드 블록 포함.
- **타입 일관성:** `_Restorable(session, questions)` 생성자·필드명이 Task 1 전 스텝에서 동일. `_resume(_Restorable r)` 시그니처가 호출부(`_resume(restorable)`)와 일치. `_RunParams.restored(ExamSession, List<Question>)`는 기존 시그니처 그대로 사용(변경 없음).
- **범위:** Phase 0 단일 배치. 신규 기능·신규 테스트 0, 회귀 0 목표.
