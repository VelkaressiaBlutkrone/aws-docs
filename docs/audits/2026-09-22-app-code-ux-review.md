# 앱 코드·UX 리뷰 — 2026-09-22

> **⚠ 검증 상태 (2026-09-22 추가 — 로컬 Flutter 3.47.2 실측)**
> - 아래 본문은 외부 리뷰 **원문 그대로**다. 코드 대조, 재현 프로브, 공식 문서로 검증한 결과는 문서 끝 **부록 V**에 있다.
> - **M-1의 "ANS-C01 `passingScore` 750 정정"은 반려했다.** AWS 공식 시험 가이드상 700이며, 앱 데이터가 맞다.
> - 반영 PR:
>   - #122: C-1, C-2 임시 조치, 레거시 v1
>   - #123: M-1
>   - #124: M-5
>   - #125: M-3, M-2 축소판

> **대상**: `main` @ `acfbeac` (2026-09-03, PR #121 develop→main 머지) · `flutter_app/lib` 13,860줄 · 테스트 78파일
> **방법**: 정적 리뷰(소스 정독 + 토큰 대비 실측 스크립트). 리뷰 환경에 Flutter SDK가 없어 `flutter analyze`/`flutter test`는 실행하지 않았다 — 라인 번호는 위 커밋 기준이며, 최종 확정은 로컬 `flutter analyze` 실행을 권장한다.
> **범위**: 앱 코드(데이터·동기·시험 러너·부팅·CI)와 UX(시험 러너·홈·접근성). 콘텐츠 사실 정확성은 범위 밖(→ `docs/audits/2026-07/03-docs-facts.md`).
> **2026-07 전면 감사와의 관계**: 겹치는 항목은 감사 ID(`CODE-D-003` 등)를 병기했다. 이 문서는 감사를 대체하지 않으며, **신규 발견 + 기존 항목의 등급 재평가**만 더한다.
> **제안 위치**: `docs/audits/2026-09-22-app-code-ux-review.md`

---

## 📊 리뷰 요약

| 등급 | 건수 | 그중 2026-07 감사와 중복 | 비고 |
|---|---:|---:|---|
| 🔴 Critical | 2 | 2 (`CODE-D-004`, `CODE-D-003` — 당시 M) | 둘 다 **클라우드 동기를 켠 사용자**에게만 발생. M→Critical 상향 제안(데이터 유실·삭제 불가) |
| 🟡 Major | 10 | 2 (`CODE-D-001` 재확인, `CODE-P-012` 연계) | 합격선 오표기·저장 계층·CI·대비·Semantics·성능 |
| 🟢 Minor | 6 | 0 | 위생·표시 |
| 🎨 UX | 5 | 0 | 시험 러너 모바일·"이어서 풀기"·결과 화면 |

**머지 판정**: 로컬 전용 사용자 기준으로는 배포 가능. Google 로그인(동기)을 공개 상태로 유지하는 한 Critical 1·2를 우선 수정 권고 — 둘 다 코드 변경량은 작다(1은 순서 변경, 2는 즉시 완화가 한 줄).

---

## 🔴 Critical (즉시 수정)

### C-1. reconcile 중 제출된 응시가 유실되는 lost-update 경합 — `CODE-D-004` 상향

**위치**: `lib/data/cloud/sync_service.dart:73-84` (`_reconcileAttempts`) · 같은 패턴 `_reconcileViewed`(86-101) · `_reconcileLww`(103-123)
**문제**: 로컬 스냅샷을 먼저 읽고(74) → `await loadCollection`(78) → *await 전 스냅샷* 기준 병합본으로 로컬을 덮어쓴다(80). await 구간(클라우드 왕복 수백 ms)에 `HistoryStore.add`(시험 제출)가 끼어들면:

1. 그 레코드는 80행의 쓰기로 로컬에서 사라지고,
2. `toCloud`는 await 전 스냅샷으로 계산돼 클라우드에도 올라가지 않는다 → **영구 유실**.

트리거가 30초 주기 + 4컬렉션 스냅샷 + 앱 복귀라 창은 좁지만 0이 아니다(왕복 300ms 기준 제출당 ~1%). 감사에서 M이었으나 "응시 제출이 사라진다"는 사용자 체감이 학습 앱의 핵심 데이터라 Critical로 본다.

**Before**
```dart
Future<void> _reconcileAttempts(String uid) async {
  final local = _readJsonList(_kHistory)          // ① 로컬 읽기
      .whereType<Map<String, dynamic>>()
      .map(AttemptRecord.fromJson)
      .toList();
  final cloud = await _cloud.loadCollection(uid, 'attempts'); // ② await — 이 사이 제출되면
  final r = mergeAttempts(local, cloud);
  _local.write(_kHistory, jsonEncode(r.merged.map((e) => e.toJson()).toList())); // ③ ①기준으로 덮어씀
  for (final e in r.toCloud.entries) {
    await _cloud.setDoc(uid, 'attempts', e.key, e.value);
  }
}
```

**After** — 순서만 바꿔도 창이 닫힌다(마지막 로컬 쓰기 이후에는 로컬 쓰기가 없으므로)
```dart
Future<void> _reconcileAttempts(String uid) async {
  final cloud = await _cloud.loadCollection(uid, 'attempts'); // ① 먼저 await
  final local = _readJsonList(_kHistory)                       // ② await 뒤에 로컬 읽기
      .whereType<Map<String, dynamic>>()
      .map(AttemptRecord.fromJson)
      .toList();
  final r = mergeAttempts(local, cloud);
  final next = jsonEncode(r.merged.map((e) => e.toJson()).toList());
  if (next != _local.read(_kHistory)) _local.write(_kHistory, next); // ③ 무변경이면 쓰기 생략
  for (final e in r.toCloud.entries) {
    await _cloud.setDoc(uid, 'attempts', e.key, e.value); // 이후 로컬 쓰기 없음 → 창 없음
  }
}
```
`_reconcileViewed`·`_reconcileLww`도 동일하게 "클라우드 await → 로컬 읽기 → 병합 → 변경 시에만 쓰기" 순서로. 근본 해법은 `KvBackend`에 변경 카운터를 두고 "읽은 뒤 바뀌었으면 재병합"이지만, 위 순서 변경만으로 이 경합은 사라진다.

**테스트**: `sync_service_test`에 "cloud load 완료 전 `HistoryStore.add` → reconcile 후에도 레코드 존재 + toCloud 포함" 케이스 1개(FakeCloudStore의 `loadCollection`을 `Completer`로 지연).

---

### C-2. 동기 켠 상태의 "학습 기록 초기화"가 30초 안에 되돌려짐 — `CODE-D-003` 상향

**위치**: `lib/data/study_reset.dart:26-51` ↔ `lib/data/cloud/sync_merge.dart:13-28`(attempts union) · `cloud_store.dart`(delete API 없음) · `home_page.dart:72-86` / `review_page.dart:93-112` / `report_page.dart:34-`("이 작업은 되돌릴 수 없습니다")
**문제**: 초기화는 로컬만 지운다. attempts/viewed는 union이고 plans/checks는 로컬 부재 시 클라우드가 LWW로 이기므로, 다음 reconcile(주기 30초·watch·앱 복귀)에서 **전부 부활**한다. 사용자 관점에서는 "삭제가 안 된다"이고, 약점 모의고사 잠금(3회 누적) 같은 게이트도 리셋되지 않는다. 클라우드 데이터를 지울 경로가 앱 어디에도 없어 HANDOFF §0-b의 "개인정보 고지" 항목과 직결된다(내 데이터를 지울 수 없는 서비스).

**즉시 완화(1시간)** — 로그인 상태면 다이얼로그에 경고 또는 버튼 비활성
```dart
// home_page.dart _resetAll (review/report _resetCert 동일)
final signedIn = syncController.value?.user != null;
final ok = await confirmReset(
  context,
  title: '모든 학습 기록 초기화',
  message: '모든 자격증의 응시 이력·오답노트·약점 리포트·진행률·열람 기록이 전부 삭제됩니다. '
      '진행 중인 시험 세션도 사라집니다.\n\n이 작업은 되돌릴 수 없습니다.'
      '${signedIn ? '\n\n⚠ 기기 간 동기가 켜져 있습니다. 클라우드 백업본은 아직 삭제되지 않아 '
          '다음 동기 때 기록이 다시 내려옵니다. 초기화하려면 먼저 동기를 끄고 진행해 주세요.' : ''}',
  confirmLabel: '모두 초기화',
);
```
(동기를 끄고 초기화해도 재로그인 시 다시 내려오므로 "완전 삭제"는 아니다 — 문구는 그대로 정직하게.)

**근본(설계, M)** — union 의미론에서 삭제는 tombstone/epoch 없이는 표현할 수 없다
- `CloudStore`에 `deleteDoc(uid, collection, docId)` 추가(`FirestoreCloudStore` 1줄, `FakeCloudStore` 3줄).
- 자격증별 **reset 마커**: 로컬 사이드카 `awsdocs.sync.v1.resetAt = {certId: ms}` + 클라우드 `users/{uid}/meta/reset` 문서. `resetCert`는 마커를 기록하고, 로그인 상태면 즉시 push.
- 병합 규칙: `mergeAttempts(local, cloud, resetAt)`가 `date < resetAt[certId]`인 레코드를 **양쪽에서** 버리고 `toDelete` 키를 돌려준다. 마커가 클라우드에 있으므로 **다른 기기의 stale 로컬이 다시 push하는 것까지** 막힌다(삭제 문서만 지우는 방식은 이 케이스에서 다시 부활).
```dart
bool _erasedBy(AttemptRecord r, Map<String, int> resetAt) {
  final ms = DateTime.tryParse(r.date)?.millisecondsSinceEpoch ?? 0;
  return ms < (resetAt[r.certId] ?? 0);
}
```
- viewed는 자격증 단위 문서라 마커 시각과 문서 `updatedAt` 비교로 동일 처리, plans/checks는 이미 LWW라 마커를 "빈 문서 + updatedAt=resetAt"로 쓰면 자연 해결.

**확인 요망(등급 보류)**: Firestore 보안 규칙(`match /users/{uid}/{document=**} { allow read, write: if request.auth != null && request.auth.uid == uid; }`)이 `docs/superpowers/specs/2026-06-10-cloud-sync-design.md:89`에만 있고 레포에 버전 관리되지 않는다. 콘솔 상태를 알 수 없어 등급을 매기지 않았다. `firestore.rules` 커밋 + `firebase.json`의 `"firestore": {"rules": "firestore.rules"}` 연결 + 에뮬레이터 규칙 테스트 1개(타인 uid 읽기 거부)를 권장.

---

## 🟡 Major (수정 권고)

### M-1. 결과 화면 합격선 "700점" 하드코딩 — SAA·SOA·DVA는 720, Pro/Specialty는 750 (신규)

**위치**: `lib/pages/exam_page.dart:364`
**문제**: `assets/exam_guides/*.json`에 `passingScore`가 이미 있고(CLF/AIF 700 · SAA/SOA/DVA/DEA/MLA 720 · SAP/DOP/AIP/SCS 750), `ExamPage._load()`와 `CertExamPage._load()`가 `overview`를 이미 읽는다. 그런데 결과 화면 부제만 700 고정. SAA Task 시험(D3 45문항·D4 30문항·D2 15문항이 live)에서 **틀린 합격선**을 보여준다. 통합 모의고사 시작 화면(`cert_exam_page.dart:350`)은 `overview.passingScore`를 정상 사용 — 같은 화면 흐름 안에서 값이 다르다.

**Before**
```dart
subtitle:
    '플래그 ${_flagged.length}개 · 실제 합격선은 1000점 만점 환산 700점(정답률과 다름)',
```
**After**
```dart
// ExamView: 필드 추가
this.passingScore,          // 생성자
final int? passingScore;    // 공식 메타 없으면 null → 700 폴백

// _results
subtitle:
    '플래그 ${_flagged.length}개 · 실제 합격선은 1000점 만점 환산 '
    '${widget.passingScore ?? 700}점(정답률과 다름)',

// ExamPage: _ExamLoad에 passingScore: overview?.passingScore 실어 ExamView(passingScore: data.passingScore)
// CertExamPage: _RunParams에 passingScore 필드 추가(_startFresh/_resume에서 d.overview?.passingScore)
```
**데이터 정정**: `assets/exam_guides/ANS-C01.json`의 `passingScore: 700`은 실제 **750**(Specialty 공통). 감사 `raw/03-exam-guides.md` 목록에 없으면 사람 확인 후 반영.

---

### M-2. localStorage 쓰기 실패 무방비 + 삭제 API 부재 (신규)

**위치**: `lib/data/web_backend_web.dart:8-10` · `lib/data/local_kv.dart:8-14` · 호출부 `exam_page.dart:652-655`, `cert_exam_page.dart:263-266`
**문제**:
- `setItem`은 쿼터 초과(`QuotaExceededError`)·Safari 프라이빗 모드에서 throw한다. `ExamPage.onFinished`에서 `_history.add`가 throw하면 `_store.clear(examId)`가 실행되지 않고, `_submit`의 `setState`(211)에도 도달하지 못해 결과 화면 전환이 멈춘다(다음 탭에서야 렌더). 전역 `PlatformDispatcher.onError`가 삼켜 사용자에겐 아무 신호가 없다.
- `KvBackend`에 `remove`가 없어 "삭제"를 빈 문자열 쓰기로 흉내 낸다(`ExamSessionStore.clear/clearAll`, `HistoryStore.clearAll`). 키가 누적되고 `keys()` 열거가 점점 무의미해진다.

**After**
```dart
// local_kv.dart
class KvWriteException implements Exception {
  KvWriteException(this.key, this.cause);
  final String key; final Object cause;
  @override String toString() => 'KvWriteException($key): $cause';
}

abstract interface class KvBackend {
  String? read(String key);
  void write(String key, String value);
  void remove(String key);               // 신규 — 빈 문자열 대신 실제 삭제
  Iterable<String> keys();
}

// web_backend_web.dart
@override
void write(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (e) {
    throw KvWriteException(key, e);      // 삼키지 않고 호출부가 알리게
  }
}
@override
void remove(String key) => web.window.localStorage.removeItem(key);

// exam_page.dart onFinished — 결과 화면은 유지하고 저장 실패만 알린다
onFinished: (r) {
  try {
    _history.add(r);
  } on KvWriteException catch (e) {
    appLog('history 저장 실패: $e');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('응시 기록을 저장하지 못했습니다. 브라우저 저장 공간을 확인해 주세요.')));
  }
  _store.clear(examId);
},
```
`MemoryBackend`·`WebBackend` 스텁에 `remove` 추가, 각 스토어의 `clear*`는 `write(key, '')` → `remove(key)`. (감사 `CODE-D-006` "KV 보일러플레이트 공용 헬퍼"와 같이 처리하면 한 번에 끝난다.)

---

### M-3. HistoryStore 파손 시 전체 이력 손실 후 덮어쓰기 (신규)

**위치**: `lib/data/history_store.dart:16-32`
**문제**: 최상위 JSON이 깨지면 `all()`이 `[]`를 돌려주고, 직후 `add()`가 `all()..add(r)`를 `[신규 1건]`으로 써서 **파손됐지만 대부분 복구 가능한 원본을 소멸**시킨다. 레코드 하나가 Map이 아니어도(`e as Map<String, dynamic>`) 전체가 버려진다. `SyncService._readJsonList`는 이미 `whereType<Map<String, dynamic>>()`로 레코드 단위 관용 처리를 하고 있어 두 경로의 관용도가 다르다.

**After**
```dart
List<AttemptRecord> all() {
  final raw = _b.read(_key);
  if (raw == null || raw.isEmpty) return [];
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    _b.write('$_key.corrupt', raw); // 원본 보존 — 다음 add()가 덮어써도 복구 가능
    return [];
  }
  if (decoded is! List) return [];
  return [
    for (final e in decoded)
      if (e is Map<String, dynamic>) AttemptRecord.fromJson(e), // 레코드 단위 관용
  ];
}
```

---

### M-4. 통합 모의고사 문항 뱅크 순차 로드 (신규 · `CODE-P-012` 연계)

**위치**: `lib/pages/cert_exam_page.dart:71-88` (같은 루프가 review/report/cert_detail에 4벌 — 감사 `CODE-P-012`)
**문제**: 19~24개 `rootBundle.loadString`을 `for … await`로 직렬 실행 → 첫 진입이 N×RTT("모의고사를 준비하고 있습니다…"가 길어지는 원인). `AssetBundle`이 문자열을 캐시하므로 두 번째부터는 빠르지만, 첫 방문·SW 캐시 미스 사용자에겐 매번이다.

**After** — 공용 로더로 추출하면서 병렬화(순서 보존 → `taskOrder` 결정성 유지)
```dart
Future<(ContentEntry, QuestionBank)?> _loadBank(ContentEntry e) async {
  try {
    final raw = await rootBundle.loadString(e.questionsAsset);
    return (e, QuestionBank.fromJson(json.decode(raw) as Map<String, dynamic>));
  } catch (_) {
    return null; // 개별 뱅크 실패는 무시(기존 계약 유지)
  }
}

// _load() 안
final loaded = await Future.wait([
  for (final e in entries) if (e.hasQuestions) _loadBank(e),
]);
for (final r in loaded) {
  if (r == null) continue;
  final (e, bank) = r;
  banks.add(bank);
  taskOrder.add(e.taskId);
  taskPool[e.taskId] = bank.questions;
  for (final q in bank.questions) taskByQuestionId[q.id] = e.taskId;
}
```

---

### M-5. CI에 analyze/test 게이트 없음 + Flutter 버전 미고정 (신규)

**위치**: `.github/workflows/pages.yml` (유일한 워크플로)
**문제**:
- `subosito/flutter-action@v2`에 `channel: stable`만 지정 → 안정 채널이 올라가는 날 CI가 **다른 Flutter로** 빌드한다. HANDOFF §1이 직접 경고한 두 전제(`web/index.html`의 `{{flutter_js}}`/`{{flutter_build_config}}` 토큰 계약, canvaskit의 woff2 디코드)가 예고 없이 깨질 수 있고, 깨져도 배포는 성공한다(빌드는 통과하므로).
- `flutter analyze`/`flutter test`(감사 시점 782 그린)가 CI에 없어 게이트가 로컬 규율에만 의존한다. 서브에이전트 위임이 많은 워크플로(HANDOFF의 브랜치 오염 사고 이력)에서는 PR 단계의 기계 게이트가 사람 검증보다 싸다.

**After**
```yaml
# pages.yml — 버전 고정(로컬 `flutter --version`과 동일 값으로)
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.x.y'   # 채널 대신 정확한 버전
    cache: true
```
```yaml
# .github/workflows/ci.yml — PR 게이트(신규)
name: CI
on:
  pull_request:
    branches: [develop, main]
jobs:
  test:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: flutter_app } }
    steps:
      - uses: actions/checkout@v5
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x.y', cache: true }
      - run: flutter pub get
      - run: flutter analyze --no-fatal-infos   # 잔존 info 3건 정리 후 플래그 제거
      - run: flutter test
```
브랜치 보호에 `test` job을 required check로. Flutter 업그레이드는 `flutter-version` 한 줄을 바꾸는 PR로 만들어 `node tool/verify_splash.mjs`를 같은 PR에서 돌린다.

---

### M-6. 라이트 테마 텍스트 대비 미달 — WCAG AA 4.5:1 (신규)

**위치**: `lib/theme/app_theme.dart:56-80` (light 토큰) · DESIGN.md 컬러 표
**실측**(WCAG 상대 휘도 계산, 부록 A 전체 표):

| 조합 | 비율 | 판정 | 사용처 |
|---|---:|---|---|
| `textFaint #8A93A0` on `bg` | **2.98** | 실패(대형 텍스트 3.0도 미달) | labelSmall 12~13px — `report_page:240,259` · `summary_section:57` · `footer_section:21` · `plan_agenda:438,490` · `cert_detail_bits:52` 등 18곳 |
| `textFaint` on `surface2` | 2.75 | 실패 | 카드 내부 라벨 |
| `warning #B7791F` on `bg`/`surface` | 3.49 / 3.64 | 실패(16px 볼드는 대형 아님) | 타이머 임박(`exam_page:277`) · 플래그 버튼 라벨 13px(`exam_page:483`) · 홈 "지난 일정"(`home_page:154`) |
| `correct #1F8A52` on `correctWeak` | 3.83 | 실패 | 해설 라벨 12px w800(`ExplainBox`) |
| `correct` on `surface` | 4.36 | 실패(근소) | 결과 카드 |
| 다크 `textFaint #6B7585` on `bg` | 3.82 | 실패 | 위와 동일 사용처 |

나머지(text·textMuted·accent·wrong·info, 다크 warning/correct)는 전부 AA 통과 — 다크 재설계 원칙이 잘 작동한 증거다. 라이트에서만 세 토큰이 걸린다.

**After** (DESIGN.md가 SOT이므로 DESIGN.md 컬러 표 → `app_theme.dart` 순서로)
```dart
// light
textFaint:   Color(0xFF697280), // 4.66:1 on bg (기존 #8A93A0 = 2.98)
correct:     Color(0xFF1B7A48), // 5.35 on surface · 4.70 on correctWeak (기존 3.83)
warningText: Color(0xFF8F5E14), // 신규 — 텍스트 전용 5.3:1. warning은 아이콘·테두리·배경 유지
// dark
textFaint:   Color(0xFF808A9B), // 5.11 on bg (기존 3.82)
```
적용: 타이머 임박·플래그 라벨·"지난 일정" 텍스트 → `warningText`. 원칙으로는 **14px 이하 텍스트에 `textFaint` 금지, 텍스트는 `textMuted`**를 DESIGN.md에 명문화(faint는 구분선·아이콘·플레이스홀더 전용). 스크린샷 대조 게이트(`flutter-web-visual-qa-recipe`)로 회귀 확인.

---

### M-7. 커스텀 인터랙티브 위젯 Semantics 부재 (신규)

**위치**: `lib/content/quiz_widgets.dart:42-57`(`OptionTile`) · `lib/pages/exam_page.dart:398-439`(`_GridChip`) · `lecture_transport_bar`·`prescription_hub` 칩류
**문제**: lib 전체에서 `Semantics`/`tooltip`/`semanticLabel`이 21곳뿐. `InkWell`이 button 역할과 자식 텍스트 라벨은 주지만 **선택 상태·번호 의미**가 없다. 스크린리더 사용자에게 문항 그리드는 "3, 버튼", 선택지는 "텍스트, 버튼"으로만 읽히고 "현재 선택됨/답변함/플래그"를 알 수 없다. 키보드 조작(Tab/Enter, InsetFocusRing)이 잘 돼 있는 것과 대비되는 공백.

**After**
```dart
// _GridChip.build
return Semantics(
  button: true,
  selected: current,
  onTap: onTap,
  label: '문항 $label, ${answered ? '답변함' : '미답'}${flagged ? ', 플래그' : ''}',
  excludeSemantics: true, // 자식의 "3"·아이콘 semantics를 위 라벨로 대체
  child: InsetFocusRing(/* 기존 그대로 */),
);

// OptionTile.build
return Padding(
  padding: const EdgeInsets.only(bottom: Gap.sm),
  child: Semantics(
    button: true,
    inMutuallyExclusiveGroup: true, // 라디오 그룹 의미
    selected: selected,
    onTap: onTap,
    label: text,
    excludeSemantics: true,
    child: InsetFocusRing(/* 기존 그대로 */),
  ),
);
```
`ResultsView`의 정답/오답 상태도 `Semantics(label: '${index+1}번, 정답'|'오답')`로. 테스트: `exam_view_test`에 `tester.getSemantics(find.text('3'))`로 라벨·selected 어서션 2개.

---

### M-8. 주기 reconcile이 무변경에도 4컬렉션 전량 로드·로컬 전량 재기록 (신규)

**위치**: `lib/data/cloud/sync_controller.dart:119-123`(`_startPeriodic`) · `sync_service.dart:66-71`(`reconcileAll`)
**문제**: 클라우드→로컬 방향은 이미 `watchCollection` 리스너 4개가 담당한다. 그런데 30초 타이머가 변경 유무와 무관하게 `loadCollection` 4회 + 로컬 4키 전량 재기록을 반복한다(HANDOFF §1 "비용 노트"가 인지한 항목). 사용자 수가 늘면 Firestore 읽기 비용의 유일한 조정점이고, 로컬 재기록은 C-1 경합의 창을 30초마다 여는 행위이기도 하다.

**After**
- `KvBackend`에 쓰기 알림(`Stream<String> get changes` 또는 콜백) 추가 → `SyncController`가 구독해 `_dirty = true`.
- `_startPeriodic`: `Timer.periodic(interval, (_) { if (_dirty) sync(); })`, `sync()` 성공 시 `_dirty = false`.
- C-1의 "무변경 시 쓰기 생략"과 합치면 idle 상태의 로컬 쓰기는 0이 된다.
```dart
Timer? _periodic;
bool _dirty = true; // 로그인 직후 1회는 무조건

void _startPeriodic() {
  final interval = _syncInterval;
  if (interval == null) return;
  _periodic = Timer.periodic(interval, (_) {
    if (_dirty) sync();
  });
}
```

---

### M-9. [재확인] 현행 학습 플랜(v2)이 클라우드에 백업되지 않음 — `CODE-D-001` (H, 기존)

**위치**: `lib/data/cloud/sync_service.dart:24` (`_kPlans = 'awsdocs.plan.v1'`) ↔ `lib/data/study_plan_store.dart:16` (`_key = 'awsdocs.plan.v2'`)
**상태**: `acfbeac` 기준 **여전히 미수정**. 감사에서 H로 분류돼 Phase B 최상단에 있다. 이 리뷰의 C-1/C-2/M-8이 모두 `sync_service.dart`를 건드리므로 **같은 PR 묶음**으로 처리하는 것이 효율적이다(플랜 v2 병합 규칙 + LWW 메타 + 테스트).

---

### M-10. 시험 러너 결과 화면 65장 카드 일괄 렌더 (신규 · UX-5와 동일 원인)

**위치**: `lib/content/quiz_widgets.dart:174-181`(`ResultsView`) → `exam_page.dart:352-377`
**문제**: `SingleChildScrollView + Column`에 65개 `ResultCard`(지문+선택지+해설+개념 링크)를 한 번에 빌드한다. 모바일에서 제출 직후 수백 ms 정지가 생기고, 사용자 입장에서도 "오답 12개"를 찾으려면 65장을 스크롤해야 한다.
**After**: `SliverList.builder`(또는 `ListView.builder` + `shrinkWrap` 없이 페이지 전체를 `CustomScrollView`로)로 지연 빌드 + 상단 필터 칩 "전체 / 오답만(기본, 오답 있을 때) / 플래그만".

---

## 🟢 Minor (선택적)

| # | 위치 | 내용 | 수정 |
|---|---|---|---|
| m-1 | `lib/util/open_link_web.dart:5` | JS `window.open(url, '_blank')`은 `<a target=_blank>`와 달리 **noopener가 기본이 아니다** → 열린 페이지가 `window.opener`로 부모 탭을 조작 가능(reverse tabnabbing). 현재 링크가 AWS 공식 문서라 실위험은 낮음 | `web.window.open(url, '_blank', 'noopener,noreferrer');` |
| m-2 | `lib/pages/exam_page.dart:117-124` | 1초 ticker가 `setState(() {})`로 ExamView 전체(65칩 + 선택지 + 버튼)를 리빌드 | 타이머 텍스트를 `_ExamClock(startedAt, durationSec)` StatefulWidget으로 분리해 그것만 1초 리빌드. 자동 제출은 콜백으로 상위에 통지 |
| m-3 | `lib/pages/sync_entry.dart:55` | `SyncStatus.error`가 UI에 표시되지 않는다(syncing 스피너만). 동기 실패(규칙 거부·오프라인)를 사용자가 알 수 없음 | `if (ctrl.status == SyncStatus.error) Icon(Icons.cloud_off, semanticLabel: '동기 실패 — 다음 트리거에 재시도')` |
| m-4 | `web/index.html:263-266` | `initializeEngine().then(...)`에 `.catch` 없음. 엔진/CanvasKit 로드 실패 시 20초 stall 문구만 뜨고 실패 상태 표시 없음 | `.catch(function (e) { msg.textContent = '시작하지 못했습니다 — 새로고침해 주세요.'; stall.hidden = false; console.error(e); })` |
| m-5 | `web/index.html:27-28` | `theme-color`가 `prefers-color-scheme` 기준이라 **저장된 다크 테마**와 브라우저 크롬 색이 어긋남 | 스플래시 JS(163-168)가 이미 `awsdocs.theme.v1`을 읽으니 거기서 `meta[name=theme-color]`를 갱신 |
| 💬 m-6 | `pubspec.yaml` assets | 오디오 메타(script/audio_meta/review_checklist) 100+줄 개별 나열 — mp3를 번들에서 빼기 위한 선택으로 보임 | 메타를 `assets/audio_meta/<task>/`로 옮기면 디렉터리 단위 등록(3줄)으로 줄고, mp3(R2)와 물리적으로도 분리됨 |

---

## 🎨 UX 크리틱 — 시험 러너 중심

### 전체 인상
히어로 → 추천 순서 → 학습 문서 → 모의고사 → 일정의 동선이 명확하고, 카피가 정직하다("합격선은 정답률과 다름", "검증 문항만 노출", 잠금 사유를 도메인별 숫자로 공개). 가장 큰 기회는 **시험 러너의 모바일 레이아웃**과 **재방문 학습자의 첫 화면**(진행 상태가 첫 뷰포트에 없음)이다.

### 사용성

| # | 발견 | 심각도 | 권고 |
|---|---|---|---|
| UX-1 | 65칩 문항 그리드가 지문 **위**에 고정(`exam_page.dart:293-306`). 360px 폭에서 `Wrap`이 ~8줄(≈300px)을 차지해 **문항마다 그리드를 지나쳐 스크롤**해야 지문이 보인다 | 🔴 | 768px 미만: 그리드를 접이식(기본 접힘) 또는 바텀시트로, 기본 노출은 "12 / 65 · 미답 8 · 플래그 3" 한 줄 요약 칩. 데스크톱은 현행 유지 |
| UX-2 | "제출"이 **마지막 문항에서만** 노출(`339-343`). 플래그 복기 후 30번에 있으면 65번까지 이동해야 제출 가능 | 🟡 | 상단 행(타이머 옆)에 상시 "제출" 보조 버튼 + "다음 미답으로 / 다음 플래그로" 점프. 제출 확인 다이얼로그는 이미 있음 |
| UX-3 | 칩 34×34px, 간격 4px(`404-405`, `Wrap spacing: Gap.xs`). WCAG 2.2 AA(24px)는 통과하지만 Material 48 / HIG 44 미달이라 엄지 오탭 발생. 같은 화면의 버튼은 44px(`_SecondaryButton`, `PrimaryButton`)라 **타깃 크기가 불일치** | 🟡 | 시각 34px 유지 + hit area 44px(`Padding` 인셋 5px 또는 `InkWell` 바깥 `SizedBox(44)`) |
| UX-4 | 진행 중 세션 "이어서 풀기"가 홈·자격증 상세 어디에도 없음(`ExamSessionStore` 사용처는 시험 페이지 2곳뿐). 탭을 닫은 사용자는 세션이 남아 있는지 모른 채 처음부터 시작하거나 잊는다 | 🟡 | 홈 due 배너 옆 / `cert_detail` 상단에 "진행 중인 통합 모의고사 이어서 풀기 · 남은 42:10" 카드(`ExamSessionStore.load('exam:CLF-C02-mock')` + `examIdsForCert`로 결정적 조회) |
| UX-5 | 결과 화면이 65장 카드를 정답·오답 구분 없이 나열 | 🟢 | "오답만" 기본 필터(오답 있을 때) + 정답 카드는 접힘. M-10과 함께 |

### 시각 위계
- **데스크톱 시험 러너**: 타이머·진행 → 그리드 → 지문 → 선택지 → 액션 순으로 읽힌다. 적절하다.
- **모바일**: 그리드가 첫 뷰포트를 지배해 "지금 풀 문항"이 위계의 3순위로 밀린다(UX-1).
- **홈**: 히어로 헤드라인 "클라우드 자격증, 이해하고 통과하기"가 첫 시선을 정확히 잡는다. 다만 재방문자에게 첫 시선이 가야 할 "내 진행 상태"는 일정 배너(있을 때만)와 각 자격증 카드 안 진행률 배지뿐 — UX-4 카드가 그 공백을 메운다.

### 일관성
| 요소 | 이슈 | 권고 |
|---|---|---|
| 탭 타깃 | 버튼 44px vs 칩 34px(UX-3) | hit area 44 통일 |
| 합격선 표기 | 시작 화면은 공식 메타(720), 결과 화면은 700 고정(M-1) | 단일 소스 |
| 브라우저 크롬 색 | 저장 테마 vs `prefers-color-scheme`(m-5) | 스플래시 JS에서 동기화 |
| 로컬 초기화 문구 | "되돌릴 수 없습니다" vs 동기 켜짐 시 부활(C-2) | 조건부 문구 |

### 접근성
- **대비**: 라이트 `textFaint`(2.98)·`warning` 텍스트(3.49)·`correct` 라벨(3.83) 미달 — M-6. 그 외 통과.
- **탭 타깃**: 칩 34px — UX-3.
- **스크린리더**: 선택 상태·문항 번호 의미 부재 — M-7. 키보드 조작·포커스 링·`reduced-motion`·스플래시 `aria-live`는 모범적.
- **텍스트**: 지문 `titleLarge`, 선택지 15px/1.5 — 가독성 양호. 한자 폴백 경고는 기존 이슈.

### 잘 되는 것
- 정직한 상태 UI(잠금 사유 숫자 공개, 검증 문항만 노출), 빈/에러 상태 분리, 복원 안내("이전 진행을 복원했습니다").
- 부팅 체감: 백색 화면 123ms, 진짜 진행률 스플래시, 테마 첫 페인트 일치.
- 라이트 기본 + 다크 재설계(반전 아님), 키보드 전면 지원.

### 우선순위 권고
1. **UX-1 그리드 접기(모바일)** — 시험 러너의 핵심 체감. `LayoutBuilder` 분기 하나. 크기 S.
2. **UX-4 "이어서 풀기" 카드** — 세션 복원 기능이 이미 있는데 발견되지 않는 문제. 크기 S.
3. **UX-2 상시 제출 + 점프** — 실제 시험 UI(검토 화면)와의 간극. 크기 S~M.

---

## ✅ 잘된 점

- **순수 함수 코어 + 주입 가능한 경계**: merge/sample/allocation/anchor가 전부 순수 함수이고 `KvBackend`/`CloudStore`/`AuthService`가 인터페이스라 테스트 78파일이 실제 저장소·네트워크 없이 돈다. 특히 `content_index_test`의 **동적 불변식**(`questionCount == .questions.json의 verified 수`)이 flip 워크플로의 드리프트를 기계적으로 막는다.
- **verified 게이트가 모델 계층에 있다**(`QuestionBank.fromJson`의 `where((q) => q.verified)`) — UI 어디서도 비검증 문항이 샐 수 없다. SAA 드래프트 360건이 섞여 있어도 안전한 이유.
- **세션 복원 설계**: `bankFingerprint` + `questionIds` 복원 + `optionOrders` 순열 검증(`withOptionOrder`의 무효 순열 → 원본 폴백). 셔플 복원에서 정답이 어긋나는 사고를 타입과 검증으로 차단했다.
- **부팅 순서**: Firebase init을 첫 프레임 뒤로 미루고(`addPostFrameCallback`), 스플래시가 실제 부트스트랩 이벤트에 매핑, `reduced-motion`·`noscript`·`aria-live`까지 처리. init 실패는 로컬 전용 degrade.
- **에러 모델**: fatal(로드 실패 → ErrorView 재시도)과 optional(개별 뱅크 실패 → 나머지로 진행) degrade를 구분하고, "로드 실패를 문항 없음으로 위장하지 않는다"는 원칙을 코드 주석으로 남겼다.
- **관용 파싱**: 모든 `fromJson`이 null-safe(`(j['x'] ?? '').toString()`, `whereType<num>()`) — 레거시 레코드·스키마 확장에 강하다.
- **디자인 시스템 규율**: 토큰 하드코딩 없음, `InsetFocusRing`/`FocusTap`, `Wght` 1:1 병기, `GestureDetector` 단독 0건.
- **동기 컨트롤러의 동시성 처리**: 세대 가드(`_gen`)로 스테일 전환의 watch/timer 부착을 막고, teardown을 동기로 수행하는 이유를 주석으로 남긴 점. 흔히 놓치는 부분이다.

---

## 💬 PR 코멘트 (복사용)

> 파일:라인 기준 GitHub 리뷰 코멘트 형식. 심각도 접두어는 팀 컨벤션에 맞게 조정.

**`lib/data/cloud/sync_service.dart:74-80`**
> 🔴 **[C-1 / CODE-D-004]** 로컬 스냅샷(74)을 읽은 뒤 `await loadCollection`(78) 동안 `HistoryStore.add`가 끼면 80행의 쓰기가 그 레코드를 덮어쓰고, `toCloud`에도 없어 영구 유실됩니다. `loadCollection`을 먼저 await하고 그 뒤에 로컬을 읽는 순서로 바꾸면(마지막 로컬 쓰기 이후 로컬 쓰기가 없으므로) 창이 닫힙니다. `_reconcileViewed`/`_reconcileLww`도 동일. 무변경 시 쓰기 생략(`next != _local.read(...)`)도 함께 부탁드립니다.

**`lib/data/study_reset.dart:26`**
> 🔴 **[C-2 / CODE-D-003]** 로그인 상태에서는 다음 reconcile(≤30s)이 attempts/viewed를 union으로, plans/checks를 LWW로 되살립니다 — "되돌릴 수 없습니다"가 반대로 동작합니다. tombstone/reset 마커 도입 전까지는 `syncController.value?.user != null`이면 다이얼로그에 경고(또는 비활성) 부탁드립니다.

**`lib/pages/exam_page.dart:364`**
> 🟡 **[M-1]** 합격선 700 고정 — SAA/SOA/DVA는 720, Pro/Specialty는 750입니다. `_load()`가 이미 읽는 `overview.passingScore`를 `ExamView`에 주입해 주세요(`?? 700` 폴백). 시작 화면(`cert_exam_page.dart:350`)과 값이 달라지는 상태입니다.

**`lib/data/web_backend_web.dart:9`**
> 🟡 **[M-2]** `setItem`은 쿼터 초과/프라이빗 모드에서 throw합니다. 삼키지 말고 `KvWriteException`으로 감싸 호출부(`ExamPage.onFinished`)가 스낵바로 알리게 해주세요. 결과 화면 전환은 저장 실패와 무관하게 진행돼야 합니다. `remove(key)`도 추가해 `write(key, '')` 흉내를 걷어내면 좋겠습니다.

**`lib/data/history_store.dart:24-26`**
> 🟡 **[M-3]** 최상위 JSON 파손 시 `[]`를 돌려주면 직후 `add()`가 `[신규 1건]`으로 원본을 덮어씁니다. 레코드 단위 관용 파싱(`if (e is Map<String,dynamic>)`) + 디코드 실패 시 `.corrupt` 키에 원본 보존 부탁드립니다. `SyncService._readJsonList`는 이미 레코드 단위라 두 경로 관용도를 맞추는 의미도 있습니다.

**`lib/pages/cert_exam_page.dart:71`**
> 🟡 **[M-4 / CODE-P-012]** 뱅크 19~24개를 `for … await`로 직렬 로드해 첫 진입이 N×RTT입니다. `Future.wait([... _loadBank(e)])`로 병렬화하면 순서도 보존됩니다. 4벌 중복 루프를 공용 로더로 뽑을 때 같이 처리하면 한 번에 끝납니다.

**`.github/workflows/pages.yml:29`**
> 🟡 **[M-5]** `channel: stable`은 안정 채널이 오르는 날 다른 Flutter로 배포합니다 — `index.html` 토큰 계약·woff2 디코드 전제가 깨져도 빌드는 성공합니다. `flutter-version` 고정 + PR 트리거의 `analyze`/`test` job을 required check로 부탁드립니다.

**`lib/theme/app_theme.dart:64`**
> 🟡 **[M-6]** 라이트 `textFaint #8A93A0`은 bg 대비 2.98:1로 대형 텍스트 기준(3.0)도 미달인데 12~13px 라벨 18곳에 쓰입니다. `#697280`(4.66)로 올리거나 텍스트에는 `textMuted`를 쓰는 규칙을 DESIGN.md에 명문화해 주세요. `warning`(3.49)·`correct`(3.83) 텍스트 용도도 같은 문제입니다.

**`lib/content/quiz_widgets.dart:43`**
> 🟡 **[M-7]** `OptionTile`이 선택 상태를 semantics로 노출하지 않아 스크린리더에는 "텍스트, 버튼"으로만 읽힙니다. `Semantics(inMutuallyExclusiveGroup: true, selected: selected, onTap: onTap, label: text, excludeSemantics: true)`로 감싸 주세요. `_GridChip`도 "문항 N, 답변함/미답, 플래그" 라벨이 필요합니다.

**`lib/data/cloud/sync_controller.dart:122`**
> 🟡 **[M-8]** 30초 타이머가 변경 유무와 무관하게 4컬렉션 전량 로드·로컬 전량 재기록을 합니다. 클라우드→로컬은 watch 리스너가 이미 담당하니 dirty 플래그가 설정된 경우에만 `sync()` 하도록 바꾸면 비용과 C-1 노출 창이 함께 줄어듭니다.

**`lib/pages/exam_page.dart:293`**
> 🎨 **[UX-1]** 모바일(360px)에서 65칩 `Wrap`이 ~300px을 차지해 문항마다 지문 위 그리드를 지나쳐야 합니다. `LayoutBuilder`로 768px 미만에서는 접이식(기본 접힘) + "12/65 · 미답 8 · 플래그 3" 요약 한 줄로 바꿔 주세요.

**`lib/pages/exam_page.dart:339`**
> 🎨 **[UX-2]** "제출"이 마지막 문항에서만 보입니다. 플래그 복기 후 중간 문항에서 바로 제출할 수 있게 상단에 상시 제출 보조 액션을 부탁드립니다(확인 다이얼로그는 기존 그대로).

---

## 🗺 권장 착수 순서 (2026-07 로드맵 Phase B 편입안)

| 순서 | 항목 | 크기 | 묶음 | 근거 |
|---:|---|---|---|---|
| 1 | C-2 즉시 완화(로그인 중 초기화 경고) | XS | 단독 | 한 줄, 사용자 오해 즉시 제거 |
| 2 | C-1 순서 변경 + 무변경 쓰기 생략 + 테스트 1개 | S | **sync PR** | `CODE-D-004` |
| 3 | M-9 플랜 v2 동기 + M-8 dirty 플래그 | M | **sync PR** | `CODE-D-001`(H) — 같은 파일 |
| 4 | C-2 근본(deleteDoc + reset 마커) | M | **sync PR 2** | `CODE-D-003`, 개인정보 고지 선행 조건 |
| 5 | M-1 합격선 주입 + ANS-C01 데이터 정정 | XS | 단독 | 사용자 가시 오정보 |
| 6 | M-5 CI 게이트 + 버전 고정 | S | 단독 | 이후 모든 PR의 안전망 |
| 7 | M-2 + M-3 저장 계층(remove·예외·관용 파싱) | S | `CODE-D-006` 헬퍼와 함께 | 데이터 손실 방어 |
| 8 | M-6 대비 토큰(DESIGN.md → theme) | S | 시각 QA 레시피 | 접근성 |
| 9 | UX-1 · UX-4 · UX-2 (시험 러너 모바일) | S~M | `CODE-P-007` exam_page 분할과 함께 | 핵심 체감 |
| 10 | M-4 병렬 로드 + M-7 Semantics + M-10 지연 렌더 | S each | `CODE-P-012` 공용 로더 | 성능·접근성 |
| 11 | Minor 6건 | XS each | 위생 PR | — |

---

## 부록 A. 디자인 토큰 대비 실측 (WCAG 2.x 상대 휘도)

| 조합 | 라이트 | 다크 |
|---|---:|---:|
| text / bg | 15.01 ✅ | 14.76 ✅ |
| textMuted / bg | 5.65 ✅ | 7.06 ✅ |
| textMuted / surface2 | 5.22 ✅ | 5.73 ✅ |
| **textFaint / bg** | **2.98 ❌** | **3.82 ❌** |
| textFaint / surface | 3.11 ❌ | 3.47 ❌ |
| textFaint / surface2 | 2.75 ❌ | 3.10 ❌ |
| accent / surface | 4.76 ✅ | 6.66 ✅ |
| onAccent / accent | 4.76 ✅ | 7.33 ✅ |
| accentStrong / accentWeak | 5.51 ✅ | 7.16 ✅ |
| **correct / correctWeak** | **3.83 ❌** | 6.34 ✅ |
| correct / surface | 4.36 ❌ | 6.60 ✅ |
| wrong / wrongWeak | 4.67 ✅ | 5.07 ✅ |
| info / infoWeak | 5.20 ✅ | 5.59 ✅ |
| **warning / bg** | **3.49 ❌** | 7.91 ✅ |
| warning / warningWeak | 3.19 ❌ | 7.04 ✅ |

✅ = AA(일반 텍스트 4.5:1) 통과. ❌ 표시 중 대형 텍스트(≥18.66px 볼드 / ≥24px)로만 쓰이는 조합은 없다.

제안값 검증: light `textFaint #697280` → bg 4.66 · surface2 4.31 / `correct #1B7A48` → surface 5.35 · correctWeak 4.70 / `warningText #8F5E14` → bg 5.33 · surface 5.56 · warningWeak 4.86 / dark `textFaint #808A9B` → bg 5.11 · surface2 4.15(카드 내부 라벨은 textMuted 권장).

## 부록 B. 검토한 파일

`lib/main.dart` · `app_router.dart` · `app_errors.dart` · `web/index.html` · `manifest.json` · `pubspec.yaml` · `analysis_options.yaml` · `.github/workflows/pages.yml` · `.githooks/pre-commit`
`lib/data/`: `local_kv`, `web_backend_web/stub`, `history_store`, `exam_session_store`, `theme_pref_store`, `study_reset`, `content_index`(부분), `audio_asset_url`
`lib/data/cloud/`: `sync_service`, `sync_merge`, `sync_controller`, `cloud_store`, `firestore_cloud_store`, `firebase_bootstrap`
`lib/models/`: `attempt_record`, `exam_session`, `question`, `exam_guide`(부분)
`lib/pages/`: `exam_page`, `cert_exam_page`, `home_page`, `sync_entry`, `home/hero_section`(부분), `home/home_header`(부분), `review_page`·`report_page`(reset 경로)
`lib/content/`: `quiz_widgets`, `reset_dialog`, `study_markdown_view`(표 처리), `markdown_parser`(구조)
`lib/theme/app_theme.dart` · `lib/util/open_link*` · `assets/exam_guides/*.json`(passingScore) · `assets/content/saa/*.questions.json`(verified 집계) · `docs/audits/2026-07/*`(중복 대조)

읽지 않은 영역(후속 리뷰 후보): `plan/*`(스케줄러·어젠다 503줄), `audio_*`/`web_audio_backend`(리스너 정리는 확인), `learning_content_section`, `study_doc_page` 본문 스크롤/앵커, `test/` 개별 케이스.

---

## 부록 V. 검증 결과 (2026-09-22)

**방법**
- 리뷰 대상 `acfbeac`가 당시 `develop`(`dddee41`)과 트리가 같음을 확인한 뒤 소스를 대조했다.
- 레포 밖 일회용 프로브 패키지(`aws_docs` path 의존)에서, 리뷰가 주장한 버그 동작을 그대로 단언하는 테스트 8개를 돌려 모두 재현했다(PASS = 재현).
- 그 밖에 WCAG 대비 재계산, AWS 공식 시험 가이드, MDN, 마지막 Pages 배포 로그를 확인했다.
- 당시 기준선: `flutter test` 798개 통과, `flutter analyze` 0건.

### V-1. 항목별 판정

| 항목 | 판정 | 근거·조정 | 반영 |
|---|---|---|---|
| C-1 reconcile 경합 | ✅ 재현 | attempts·viewed·checks 3종 모두 유실되고, 다음 주기에도 복구되지 않음 | #122 |
| C-2 초기화 부활 | ✅ 재현 | `resetAll`·`resetCert` 모두 attempts·viewed·checks가 되살아남. v2 플랜은 원래 동기 대상이 아니라(M-9) 클라우드에서 돌아오지 않고, 대신 V-3 N-1 경로로 부활 | #122 임시 조치(로그인 중 경고). 근본 해결은 동기 프로토콜 스펙에서 |
| C-2 보안 규칙 | ✅ | `firebase.json`에는 FlutterFire 설정만 있고 `firestore.rules`는 없음. 콘솔의 실제 규칙은 확인하지 못함 | 미착수 |
| M-1 합격선 700 고정 | ✅ / ANS-C01 ❌ | 하드코딩 확인. 실제 영향은 SAA Task 시험(검증 90문항, 합격선 720)뿐. **ANS-C01 750 정정은 반려**(V-2) | #123 |
| M-2 쓰기 실패 | ⚠️ 부분 | 쿼터 초과 시 throw, `_submit`의 setState 미도달은 사실. Safari 프라이빗 모드 실패는 현재 MDN 기준 해당 없음. `remove` 부재는 세션 키가 결정적·유한이라 정리 차원 | #125 축소판 |
| M-3 이력 파손 | ✅ 재현 | 비-Map 레코드 하나 → 전체 `[]` → 다음 `add`가 원본을 덮어씀 | #125 |
| M-4 순차 로드 | ✅ | 병렬화 개선폭은 미측정. review/report 루프에 hasQuestions 가드가 없는 문제(CODE-P-012 드리프트)도 그대로임 | 미착수 |
| M-5 CI | ✅ 근거 보강 | 운영 배포(acfbeac)는 Flutter 3.47.2로 빌드됐는데 로컬은 3.44.1이었음. analyze는 이미 0건이라 `--no-fatal-infos`가 필요 없음 | #124 |
| M-6 대비 | ✅ 수치 일치 | 재계산 결과가 부록 A와 같음. `labelSmall` 기본색이 textFaint라 영향 범위는 리뷰보다 넓음. 비활성 컨트롤은 WCAG 예외 | 미착수(DESIGN.md 결정 필요) |
| M-7 Semantics | ✅ | 선택 상태·문항 라벨 없음. 접근성 API 사용처는 12곳으로 집계(리뷰는 21곳, 결론은 같음) | 미착수 |
| M-8 주기 reconcile | ⚠️ 보류 | HANDOFF §1에 문서화된 트레이드오프. watch 구독에 onError·재구독이 없어 주기 동기가 다른 기기 변경을 받아오는 안전망 역할을 함 → dirty일 때만 돌리면 watch가 끊겼을 때 수신이 멈춤. 무변경 재기록은 #122에서 해소 | 보류 |
| M-9 플랜 v2 백업 | ✅ 재현 | V-3 N-2 함정 주의 | 미착수(동기 프로토콜 스펙) |
| M-10 / UX-5 | ✅ 구조 확인 | "수백 ms 멈춤"은 측정하지 않음 | 미착수 |
| m-1~m-5 | ✅ | m-1은 MDN으로 확인: `window.open`은 `noopener`를 안 넘기면 opener가 설정됨 | 미착수 |
| m-6 에셋 디렉터리 등록 | ⚠️ 보류 | `.gitignore` 41-42행: 원본 mp3와 enrich 산출물이 같은 디렉터리에 로컬로 있을 수 있어, 디렉터리 단위로 등록하면 로컬 빌드에 섞임 | 보류 |
| UX-1~3 | ✅ | 360px 실계산: 한 줄 8칩 × 9줄 ≈ 338px | 미착수 |
| UX-4 | ⚠️ 부분 | 통합 모의고사 시작 화면에는 이미 "이어서 풀기"가 있고, Task 시험은 재진입 시 자동 복원됨. 남는 문제는 홈·상세에서의 발견성 | 미착수 |

**수치 정정**
- SAA 드래프트는 270건이다. 360건은 검증된 90건을 포함한 전체.
- 테스트 기준선은 798이다(리뷰의 "감사 시점 782"보다 늘어남).

### V-2. 반려

- **ANS-C01 합격선 750 정정: 반려.** AWS 공식 ANS-C01 시험 가이드(docs.aws.amazon.com/aws-certification/latest/advanced-networking-specialty-01)의 Exam Results 절에 "The minimum passing score is 700."이라고 나온다. 앱 데이터(700)가 맞다. "Pro/Specialty는 750"이라는 일반화도 ANS-C01에는 맞지 않는다.

### V-3. 리뷰에 없던 발견

- **N-1: 초기화 후 레거시 v1 플랜 부활** (재현, 동기와 무관)
  - `StudyPlanStore.clearAll`이 v2를 `''`로 비워서, 다음 생성 때 v1→v2 이관이 다시 돌았다.
  - 그 결과 v1이 '기존 일정'으로 되살아났다. → #122에서 수정.
- **N-2: M-9를 키만 바꿔 고치면 플랜 전체가 사라짐** (코드 추적만 함)
  - v2 값은 자격증별 List인데, `_reconcileLww`는 `e.value is Map`인 값만 통과시킨다.
  - 키만 v2로 바꾸면 로컬 플랜이 전부 걸러지고, 클라우드 데이터만 남은 병합본이 v2를 덮어쓴다.
  - v2를 감싸는 문서 형식과 클라우드 v1 이관 규칙을 먼저 설계해야 한다.
- **N-3: CI와 로컬의 Flutter 버전 불일치** (3.47.2 vs 3.44.1) → #124.
- **N-4: review/report 뱅크 로드 루프의 hasQuestions 가드 누락** (CODE-P-012 드리프트가 그대로 남음)

### V-4. 반영 결과와 남은 일

**반영 PR** (모두 `develop` 대상)
- #122: C-1, N-1, C-2 임시 조치
- #123: M-1
- #124: M-5, 로컬 SDK 3.47.2 전환 후 `verify_splash` PASS
- #125: M-3, M-2 축소판
- 네 PR을 순서대로 합친 상태를 로컬에서 시뮬레이션: 충돌 없음, `flutter test` 819개 통과, analyze 0건

**남은 일**
- **동기 프로토콜 스펙(설계 먼저):**
  - C-2 근본 해결: reset 마커(tombstone)와 `CloudStore.deleteDoc`
  - M-9: N-2 함정 반영
  - `firestore.rules` 버전 관리
- **디자인 결정 필요:** M-6(DESIGN.md 토큰), UX-1·2·4, M-10/UX-5
- **후순위 정리:** m-1~m-5, M-4(공용 로더 + 병렬 + 가드), M-7
- **보류:** M-8, m-6
- **#124 머지 후:** 브랜치 보호에 `CI / test`를 required check로 등록(GitHub 설정)
