# 문서내 제목별 타임스탬프(추정) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 학습문서의 각 제목(헤딩)을 오디오의 해당 위치(글자수 비례 추정)로 점프하는 시크포인트를 추가한다.

**Architecture:** 도구(`gen_lecture_audio.py`)가 `script.json` 글자수만으로 헤딩별 `fraction`(0~1)을 계산해 `audio_meta.json`의 `chapters`에 저장(재합성·Polly·ffprobe 없음). 앱은 학습문서 진입 시 `audio_meta.json`을 fetch해 anchor→fraction 맵을 만들고, 헤딩 옆 시크 아이콘이 `fraction × duration`으로 `LecturePlaylist.seek`한다(현재 트랙이 이 문서일 때만).

**Tech Stack:** Python(도구), Flutter Web(Dart), rootBundle 자산 fetch, ChangeNotifier/ValueListenable(PR #84).

## Global Constraints

- 모든 명령은 `flutter_app/` 기준. 게이트: `flutter test` 전부 통과, `flutter analyze` **신규 0건**(기존 잔존 3건), `flutter build web --dart-define=audio_lecture=true` 성공. 도구는 `py tool/gen_lecture_audio.py --self-test` 그린.
- TDD: 실패 테스트 선작성 → 최소 구현 → 통과 → 커밋. Flutter는 `flutter` CLI, Python은 `py`.
- **선행 의존**: Task 5(학습문서 UI 배선)는 **PR #84(오디오 타임바/재생모드)의 `LecturePlaylist.seek(Duration)`·`ValueListenable<Duration?> duration`·`ContentEntry? current` 가 develop에 머지된 뒤** 구현한다. Task 1~4는 #84와 무관(현재 develop에서 실행 가능). 실행 순서상 Task 5 착수 전 #84 머지 확인 후 이 브랜치를 재분기/리베이스.
- **fraction 계산**: 비-skip 세그먼트를 선언 순서로 훑어, 각 `heading` 세그먼트 **직전까지 누적 발음 글자수 ÷ 총 발음 글자수**. 발음 텍스트 = `kind=="table"`이면 `audioSummary`, 그 외 `scriptText`(`.strip()` 후 `len`). 총 0이면 0.0.
- **챕터 항목**: `{anchor, title, level, fraction}`. anchor = heading `sourceExcerpt`의 `{#id}`(없으면 그 헤딩 제외). title = `scriptText`. level = 선행 `#` 개수.
- **저장**: `audio_meta.json`의 `chapters` 배열(가산 필드 — reviewStatus/source/audio/loudness/script 불변, 동기화 테스트·gate 무영향).
- **UI 게이트**: `audioLectureEnabled && doc.audioApproved && 현재 플레이리스트 트랙==이 문서 && duration 확정 && anchor에 fraction 존재`일 때만 헤딩 시크 활성. 탭 → `seek(fraction×duration)` 후 비재생이면 재생.
- DESIGN.md: `context.c` 토큰 · InkWell+FocusRing · 합니다체 · 비-fatal에 wrong색 금지.
- 커밋 직전 `git branch --show-current`로 `feat/audio-section-timestamps` 확인. 다른 세션 untracked(`assets/audio/clf/_*`, `clf-t1-1/review_notes.*`) 절대 `git add` 금지.
- 비목표(YAGNI): speech-mark 정확 타임스탬프 · 타임바 챕터 마커 · 오디오 페이지 챕터 패널 · 다른 트랙 점프 · 앵커 없는 헤딩.

## File Structure

- Modify `flutter_app/tool/gen_lecture_audio.py` — `chapters_from_segments`(순수), `chapters` 서브커맨드, `build_audio_meta`/`run_synthesize` 통합, self-test.
- Create `flutter_app/lib/data/audio_chapters.dart` — `Chapter`·`parseChapters`·`chapterSeekMs`·`shouldShowHeadingSeek`(순수).
- Modify `flutter_app/lib/content/study_markdown_view.dart` — heading 옆 trailing 슬롯(`headingTrailing` builder).
- Modify `flutter_app/lib/pages/study_doc_page.dart` — audio_meta fetch·게이트·headingTrailing 제공(seek). [Task 5, #84 필요]
- Tests: `test/audio_chapters_test.dart`(신규), `test/study_markdown_view_test.dart`(헤딩 슬롯 — 신규 또는 기존), 도구 self-test.

---

## Task 1: chapters_from_segments 순수 함수 (도구)

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (순수 함수 + `_self_test` assert)

**Interfaces:**
- Produces: `chapters_from_segments(segments: list[dict]) -> list[dict]` — `[{anchor,title,level,fraction}]`.

- [ ] **Step 1: 실패 self-test 추가**

`_self_test()`의 loudnorm 블록 앞(또는 gate 블록 근처)에 추가:

```python
    # 제목 타임스탬프 fraction 계산
    _segs = [
        {"id": "s0", "kind": "paragraph", "scriptText": "가나다라", "skip": False,
         "sourceExcerpt": "가나다라"},
        {"id": "s1", "kind": "heading", "scriptText": "첫 제목", "skip": False,
         "sourceExcerpt": "## 첫 제목 {#first}"},
        {"id": "s2", "kind": "paragraph", "scriptText": "마바사", "skip": False,
         "sourceExcerpt": "마바사"},
        {"id": "s3", "kind": "heading", "scriptText": "둘째", "skip": False,
         "sourceExcerpt": "### 둘째 {#second}"},
        {"id": "s4", "kind": "source", "scriptText": "", "skip": True,
         "sourceExcerpt": "출처"},
        {"id": "s5", "kind": "heading", "scriptText": "앵커없음", "skip": False,
         "sourceExcerpt": "## 앵커없음"},
    ]
    _ch = chapters_from_segments(_segs)
    assert [c["anchor"] for c in _ch] == ["first", "second"], _ch  # 앵커없음 제외
    assert _ch[0]["level"] == 2 and _ch[1]["level"] == 3, _ch
    assert _ch[0]["title"] == "첫 제목", _ch
    # 총 발음 글자수 = 4(가나다라)+3(첫제목)+3(마바사)+2(둘째)+4(앵커없음)=16
    # first 직전 누적=4 → 4/16=0.25; second 직전 누적=4+3+3=10 → 10/16=0.625
    assert abs(_ch[0]["fraction"] - 0.25) < 1e-9, _ch
    assert abs(_ch[1]["fraction"] - 0.625) < 1e-9, _ch
    assert chapters_from_segments([]) == [], "빈 입력"
    print("[self-test] chapters_from_segments OK", file=sys.stderr)
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `chapters_from_segments` 미정의.

- [ ] **Step 3: 구현**

`gen_lecture_audio.py`에 `_content_type` 정의 부근(또는 parse_segments 뒤)에 추가:

```python
def _segment_speech(seg: dict) -> str:
    """세그먼트의 발음 텍스트(table=audioSummary, 그 외 scriptText)."""
    if seg.get("skip"):
        return ""
    text = (seg.get("audioSummary") if seg.get("kind") == "table"
            else seg.get("scriptText")) or ""
    return text.strip()


def chapters_from_segments(segments: list[dict]) -> list[dict]:
    """헤딩별 오디오 위치 추정 — 직전까지 누적 발음 글자수 ÷ 총 발음 글자수(fraction).
    앵커 없는 헤딩은 제외. 반환 [{anchor,title,level,fraction}](선언 순서)."""
    total = sum(len(_segment_speech(s)) for s in segments)
    chapters: list[dict] = []
    acc = 0
    for seg in segments:
        speech = _segment_speech(seg)
        if seg.get("kind") == "heading" and speech:
            src = seg.get("sourceExcerpt") or ""
            m = re.search(r"\{#([^}]+)\}", src)
            hm = re.match(r"\s*(#{1,6})", src)
            if m:
                chapters.append({
                    "anchor": m.group(1),
                    "title": speech,
                    "level": len(hm.group(1)) if hm else 2,
                    "fraction": (acc / total) if total else 0.0,
                })
        acc += len(speech)
    return chapters
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS — `[self-test] chapters_from_segments OK`, 마지막 `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): chapters_from_segments(제목 fraction 추정) 순수 함수"
```

---

## Task 2: chapters 서브커맨드 + synthesize 통합 + 19문서 갱신 (도구)

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`build_audio_meta` chapters 인자, `run_synthesize` 전달, `chapters` 서브커맨드, self-test)

**Interfaces:**
- Consumes: `chapters_from_segments`(Task 1).
- Produces: `gate`처럼 `chapters` 서브커맨드(`--script`·`--audio-meta`); `build_audio_meta(..., chapters=[...])`가 결과 dict에 `"chapters"` 포함.

- [ ] **Step 1: 실패 self-test 추가**

`_self_test()`에 추가(임시 파일로 chapters 서브커맨드 동작 확인은 무겁다 — `build_audio_meta` chapters 포함만 단언):

```python
    # build_audio_meta가 chapters를 싣는다
    import tempfile as _tf2
    with _tf2.TemporaryDirectory() as _td2:
        _md = Path(_td2) / "m.md"; _md.write_text("# 제목 {#x}\n본문", encoding="utf-8")
        _mp = Path(_td2) / "a.mp3"; _mp.write_bytes(b"\xff\xfb\x00")
        _args = argparse.Namespace(engine="polly", voice="Seoyeon",
                                   polly_engine="neural", skip_loudnorm=True)
        _meta = build_audio_meta(md_path=_md, audio_path=_mp, doc_id="d",
                                 speech="x", chunks=["x"], issues=[], args=_args,
                                 mode="test",
                                 chapters=[{"anchor": "x", "title": "제목",
                                            "level": 1, "fraction": 0.0}])
        assert _meta["chapters"][0]["anchor"] == "x", _meta
    print("[self-test] build_audio_meta chapters OK", file=sys.stderr)
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: FAIL — `build_audio_meta()`에 `chapters` 인자 없음(TypeError).

- [ ] **Step 3: build_audio_meta·run_synthesize 통합**

`build_audio_meta` 시그니처에 `chapters: list | None = None` 추가(키워드 마지막), 반환 dict의 `"generator"` 앞(또는 `"script"` 뒤)에 `"chapters": chapters or [],` 추가.

`run_synthesize`에서 `build_audio_meta(...)` 호출에 `chapters=chapters_from_segments(script["segments"])` 추가(script는 이미 로드돼 있음).

- [ ] **Step 4: chapters 서브커맨드 추가**

`main()`의 gate 서브파서(`ga = sub.add_parser("gate", ...)`) 다음에 추가:

```python
    ch = sub.add_parser("chapters",
                        help="script.json → audio_meta.json chapters 갱신(재합성 없음)")
    ch.add_argument("--script", type=Path, required=True)
    ch.add_argument("--audio-meta", type=Path, required=True)
```

그리고 `args.cmd` 분기(`elif args.cmd == "gate": run_gate(args)`) 다음에:

```python
    elif args.cmd == "chapters":
        run_chapters(args)
```

`run_gate` 근처에 `run_chapters` 정의:

```python
def run_chapters(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    meta = json.loads(args.audio_meta.read_text(encoding="utf-8"))
    meta["chapters"] = chapters_from_segments(script["segments"])
    write_json(args.audio_meta, meta)
    print(f"[chapters] {len(meta['chapters'])}개 → {args.audio_meta}",
          file=sys.stderr)
```

(`write_json`이 없으면 `args.audio_meta.write_text(json.dumps(meta, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")`.)

- [ ] **Step 5: 통과 확인 + 19문서 갱신**

Run: `cd flutter_app && py tool/gen_lecture_audio.py --self-test`
Expected: PASS(`[self-test] build_audio_meta chapters OK`).

19문서 chapters 갱신(PowerShell):
```powershell
cd D:\workspace\awc-docs\flutter_app
Get-ChildItem assets/audio/clf -Directory | Where-Object { $_.Name -like 'clf-t*' } | ForEach-Object {
  $d = $_.Name
  py tool/gen_lecture_audio.py chapters --script "assets/audio/clf/$d/script.json" --audio-meta "assets/audio/clf/$d/audio_meta.json"
}
```
Expected: 각 문서 `[chapters] N개`.

검증(동기화·gate 무영향): `flutter test test/content_index_test.dart` PASS.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/tool/gen_lecture_audio.py flutter_app/assets/audio/clf/clf-t*/audio_meta.json
git commit -m "feat(audio): chapters 서브커맨드 + synthesize 통합 + CLF19 audio_meta chapters"
```

---

## Task 3: 앱 챕터 모델·파서·순수 로직 (Dart)

**Files:**
- Create: `flutter_app/lib/data/audio_chapters.dart`
- Test: `flutter_app/test/audio_chapters_test.dart`

**Interfaces:**
- Produces:
  - `class Chapter { final String anchor; final String title; final int level; final double fraction; }`
  - `List<Chapter> parseChapters(Map<String, dynamic> audioMeta)` — `audioMeta['chapters']` 파싱(없으면 빈 리스트).
  - `int chapterSeekMs(double fraction, Duration duration)` — `(fraction * duration.inMilliseconds).round()`.
  - `bool shouldShowHeadingSeek({required bool enabled, required bool approved, required bool isCurrentTrack, required bool hasDuration, required bool hasFraction})` — 모두 true일 때만.

- [ ] **Step 1: 실패 테스트 작성**

Create `test/audio_chapters_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/audio_chapters.dart';

void main() {
  test('parseChapters: chapters 배열 파싱', () {
    final list = parseChapters({
      'chapters': [
        {'anchor': 'a', 'title': 'A', 'level': 2, 'fraction': 0.0},
        {'anchor': 'b', 'title': 'B', 'level': 3, 'fraction': 0.5},
      ],
    });
    expect(list.length, 2);
    expect(list[1].anchor, 'b');
    expect(list[1].fraction, 0.5);
    expect(list[0].level, 2);
  });

  test('parseChapters: chapters 없으면 빈 리스트', () {
    expect(parseChapters({'docId': 'x'}), isEmpty);
    expect(parseChapters({'chapters': null}), isEmpty);
  });

  test('chapterSeekMs: fraction×duration', () {
    expect(chapterSeekMs(0.25, const Duration(seconds: 100)), 25000);
    expect(chapterSeekMs(0.0, const Duration(seconds: 100)), 0);
  });

  test('shouldShowHeadingSeek: 모두 true일 때만', () {
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: true, hasDuration: true, hasFraction: true), isTrue);
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: false, hasDuration: true, hasFraction: true), isFalse);
    expect(shouldShowHeadingSeek(enabled: false, approved: true,
        isCurrentTrack: true, hasDuration: true, hasFraction: true), isFalse);
    expect(shouldShowHeadingSeek(enabled: true, approved: true,
        isCurrentTrack: true, hasDuration: false, hasFraction: true), isFalse);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/audio_chapters_test.dart`
Expected: FAIL — `audio_chapters.dart` 미정의.

- [ ] **Step 3: 구현**

Create `lib/data/audio_chapters.dart`:

```dart
/// 문서내 제목별 타임스탬프(추정) — audio_meta.json의 chapters를 파싱하고,
/// 헤딩 시크포인트의 시각·노출을 계산하는 순수 로직. fraction(0~1)에 런타임
/// duration을 곱해 시각을 구한다(절대 ms 비저장 — 실측 길이에 적응).
/// 설계: docs/superpowers/specs/2026-06-28-audio-section-timestamps-design.md
library;

class Chapter {
  const Chapter({
    required this.anchor,
    required this.title,
    required this.level,
    required this.fraction,
  });

  final String anchor;
  final String title;
  final int level;
  final double fraction;
}

/// audio_meta.json 맵에서 chapters 파싱. 없거나 형식 불일치면 빈 리스트.
List<Chapter> parseChapters(Map<String, dynamic> audioMeta) {
  final raw = audioMeta['chapters'];
  if (raw is! List) return const <Chapter>[];
  final out = <Chapter>[];
  for (final e in raw) {
    if (e is! Map) continue;
    final anchor = e['anchor'];
    final fraction = e['fraction'];
    if (anchor is! String || fraction is! num) continue;
    out.add(Chapter(
      anchor: anchor,
      title: (e['title'] as String?) ?? anchor,
      level: (e['level'] as num?)?.toInt() ?? 2,
      fraction: fraction.toDouble(),
    ));
  }
  return out;
}

/// fraction(0~1) × duration → 시크 밀리초.
int chapterSeekMs(double fraction, Duration duration) =>
    (fraction * duration.inMilliseconds).round();

/// 헤딩 시크포인트 노출 게이트(순수).
bool shouldShowHeadingSeek({
  required bool enabled,
  required bool approved,
  required bool isCurrentTrack,
  required bool hasDuration,
  required bool hasFraction,
}) =>
    enabled && approved && isCurrentTrack && hasDuration && hasFraction;
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/audio_chapters_test.dart`
Expected: PASS(4).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/data/audio_chapters.dart flutter_app/test/audio_chapters_test.dart
git commit -m "feat(audio): 챕터 모델·파서·시크 게이트 순수 로직(audio_chapters)"
```

---

## Task 4: StudyMarkdownView 헤딩 trailing 슬롯 (Dart UI)

**Files:**
- Modify: `flutter_app/lib/content/study_markdown_view.dart`
- Test: `flutter_app/test/study_markdown_view_heading_slot_test.dart`(신규)

**Interfaces:**
- Produces: `StudyMarkdownView`에 옵셔널 `final Widget? Function(String anchor)? headingTrailing;` 추가 — 앵커 있는 헤딩 렌더 시 `headingTrailing!(anchor)`가 non-null이면 제목 오른쪽에 배치.

- [ ] **Step 1: 실패 테스트 작성**

Create `test/study_markdown_view_heading_slot_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/content/markdown_parser.dart';
import 'package:aws_docs/content/study_markdown_view.dart';
import 'package:aws_docs/theme/app_theme.dart';

void main() {
  testWidgets('headingTrailing이 앵커 헤딩 옆에 위젯을 단다', (tester) async {
    final blocks = parseStudyMarkdown('## 제목 {#sec}\n\n본문입니다.');
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StudyMarkdownView(
          blocks: blocks,
          headingTrailing: (anchor) =>
              anchor == 'sec' ? const Icon(Icons.play_arrow, key: Key('seek-sec')) : null,
        ),
      ),
    ));
    expect(find.byKey(const Key('seek-sec')), findsOneWidget);
  });

  testWidgets('headingTrailing 없으면 아무 것도 안 단다', (tester) async {
    final blocks = parseStudyMarkdown('## 제목 {#sec}\n\n본문.');
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: StudyMarkdownView(blocks: blocks)),
    ));
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });
}
```

(`parseStudyMarkdown` 함수명이 다르면 `markdown_parser.dart`의 실제 파서 진입 함수로 맞춘다.)

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app && flutter test test/study_markdown_view_heading_slot_test.dart`
Expected: FAIL — `headingTrailing` 파라미터 없음.

- [ ] **Step 3: 구현**

`study_markdown_view.dart` 생성자에 파라미터 추가:

```dart
  const StudyMarkdownView({
    super.key,
    required this.blocks,
    this.anchorKeys,
    this.headingTrailing,
  });

  final Map<String, GlobalKey>? anchorKeys;

  /// 앵커 있는 헤딩의 오른쪽 슬롯(예: 오디오 시크 아이콘). null 반환이면 미표시.
  final Widget? Function(String anchor)? headingTrailing;
```

헤딩 렌더(case MdHeading, 약 94~101행)를 trailing 포함으로 교체:

```dart
      case MdHeading(:final level, :final text, :final anchor):
        Key? headingKey;
        if (anchor != null) headingKey = anchorKeys?[anchor];
        final trailing =
            (anchor != null) ? headingTrailing?.call(anchor) : null;
        return Padding(
          key: headingKey,
          padding: EdgeInsets.only(
              top: level <= 2 ? Gap.lg : Gap.md, bottom: Gap.xs),
          child: trailing == null
              ? Text(text, style: level >= 3 ? t.titleMedium : t.titleLarge)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(text,
                          style: level >= 3 ? t.titleMedium : t.titleLarge),
                    ),
                    const SizedBox(width: Gap.sm),
                    trailing,
                  ],
                ),
        );
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app && flutter test test/study_markdown_view_heading_slot_test.dart`
Expected: PASS(2).

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/content/study_markdown_view.dart flutter_app/test/study_markdown_view_heading_slot_test.dart
git commit -m "feat(audio): StudyMarkdownView 헤딩 trailing 슬롯(시크 아이콘 자리)"
```

---

## Task 5: study_doc_page 헤딩 시크 배선 + 최종 검증 (Dart UI, **PR #84 필요**)

**선행 확인:** 이 Task 착수 전 `git log origin/develop`에 PR #84(타임바/재생모드) 머지가 있는지 확인하고, 없으면 STOP(NEEDS_CONTEXT). 있으면 이 브랜치를 최신 develop 위로 리베이스한 뒤 진행. `LecturePlaylist`에 `seek(Duration)`·`ValueListenable<Duration?> duration`·`ContentEntry? current`·`PlaybackState state`가 있어야 한다.

**Files:**
- Modify: `flutter_app/lib/pages/study_doc_page.dart`
- (가능 시) Test: `flutter_app/test/audio_chapters_test.dart`에 통합 계산 단언 추가 — study_doc_page 전체 위젯 테스트는 SelectionArea 함정으로 불가([[flutter-selectionarea-widget-test-pitfall]]).

**Interfaces:**
- Consumes: `lecturePlaylist`(audio_runtime.dart), `parseChapters`/`chapterSeekMs`/`shouldShowHeadingSeek`(Task 3), `StudyMarkdownView.headingTrailing`(Task 4), `audioLectureEnabled`·`ContentEntry.lectureAudioMetaSrc`.

- [ ] **Step 1: audio_meta fetch + anchor→fraction 맵 구성**

`_StudyDocPageState`에 필드·로딩 추가(initState 또는 _onDocReady에서 1회). 예:

```dart
  Map<String, double> _chapterFractions = const {};

  Future<void> _loadChapters() async {
    if (!audioLectureEnabled || !widget.entry.audioApproved) return;
    try {
      final raw = await rootBundle.loadString(widget.entry.lectureAudioMetaSrc);
      final meta = jsonDecode(raw) as Map<String, dynamic>;
      final map = <String, double>{};
      for (final ch in parseChapters(meta)) {
        map[ch.anchor] = ch.fraction;
      }
      if (mounted) setState(() => _chapterFractions = map);
    } catch (_) {
      // 없거나 실패 → 시크포인트 미표시(graceful)
    }
  }
```

`initState`에서 `_loadChapters();` 호출. import 추가: `package:flutter/services.dart`(rootBundle), `dart:convert`(jsonDecode), `../data/audio_chapters.dart`.

- [ ] **Step 2: headingTrailing 빌더를 StudyMarkdownView에 연결**

학습문서를 그리는 `StudyMarkdownView(...)` 호출에 `headingTrailing: _headingSeek` 추가. `_headingSeek` 정의:

```dart
  Widget? _headingSeek(String anchor) {
    final pl = lecturePlaylist;
    final fraction = _chapterFractions[anchor];
    final dur = pl?.duration.value;
    final isCurrent = pl?.current?.taskId == widget.entry.taskId;
    if (pl == null ||
        !shouldShowHeadingSeek(
          enabled: audioLectureEnabled,
          approved: widget.entry.audioApproved,
          isCurrentTrack: isCurrent,
          hasDuration: dur != null && dur.inMilliseconds > 0,
          hasFraction: fraction != null,
        )) {
      return null;
    }
    return _HeadingSeekButton(onTap: () {
      pl.seek(Duration(milliseconds: chapterSeekMs(fraction!, dur!)));
      if (pl.state != PlaybackState.playing) pl.playPause();
    });
  }
```

`PlaybackState` import(`../data/audio_controller.dart`)가 필요하면 추가.

- [ ] **Step 3: 헤딩 시크 버튼 위젯**

`study_doc_page.dart` 하단(또는 같은 파일 private)에 추가:

```dart
class _HeadingSeekButton extends StatelessWidget {
  const _HeadingSeekButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FocusRing(
      borderRadius: BorderRadius.circular(Radii.full),
      child: Tooltip(
        message: '이 위치부터 듣기',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.full),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.play_circle_outline,
                size: 20, color: c.accent, semanticLabel: '이 위치부터 듣기'),
          ),
        ),
      ),
    );
  }
}
```

(`FocusRing`·`Radii`·`context.c`·`Gap` import 확인 — 이미 study_doc_page가 theme/app_theme·widgets/focus_ring을 import하면 재사용.)

- [ ] **Step 4: 헤딩 시크 갱신(재생 상태/트랙 변화 반영)**

`_headingSeek`은 `pl.duration.value`·`pl.current`·`pl.state`를 읽으므로, 이들이 바뀌면 헤딩 슬롯이 다시 평가되도록 학습문서 빌드를 플레이리스트에 구독시킨다. 학습문서 본문을 그리는 영역을 `ListenableBuilder(listenable: lecturePlaylist!, builder: ...)`로 감싸거나(플레이리스트 null 가드), duration은 ValueListenable이라 별도 구독이 필요하면 `ValueListenableBuilder(valueListenable: pl.duration, ...)`로 감싼다. **최소 구현**: 미니플레이어가 이미 playlist 구독으로 리빌드되므로, 학습문서 본문도 `lecturePlaylist`가 non-null일 때 `ListenableBuilder(listenable: lecturePlaylist!, ...)`로 감싸 상태/트랙/duration 변화에 재평가되게 한다.

- [ ] **Step 5: 최종 검증**

Run: `cd flutter_app && flutter test`
Expected: 전부 PASS.

Run: `cd flutter_app && flutter analyze`
Expected: 신규 0건(기존 잔존 3).

Run(PowerShell): `flutter build web --dart-define=audio_lecture=true`
Expected: 빌드 성공.

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/pages/study_doc_page.dart
git commit -m "feat(audio): 학습문서 헤딩 시크포인트(현재 트랙·duration 게이트)"
```

---

## Self-Review (작성자 점검 결과)

1. **Spec coverage:** §1 fraction 계산 = Task 1. §2 저장·도구·19문서 = Task 2. §3 앱 로딩 = Task 3(파서)+Task 5(fetch). §4 UI·게이트 = Task 3(게이트 순수)+Task 4(슬롯)+Task 5(배선). §5 의존성(#84) = Task 5 선행 확인. 누락 없음.
2. **Placeholder scan:** 모든 step에 실제 코드·명령·기대 출력. TBD/TODO 없음. Task 4/5의 "함수명이 다르면 맞춘다"는 실제 코드 확인 지시(파서 진입 함수명·import는 구현자가 현재 파일에서 확인) — 무-플레이스홀더 원칙 위반 아님(정확 경로·코드 제공, 환경 정합만 위임).
3. **Type consistency:** `chapters_from_segments -> [{anchor,title,level,fraction}]`(Task 1) ↔ build_audio_meta chapters(Task 2) ↔ Dart `Chapter`(anchor/title/level/fraction)·`parseChapters`(Task 3) ↔ `headingTrailing(String anchor)`(Task 4) ↔ study_doc `_chapterFractions[anchor]`·`chapterSeekMs(fraction,duration)`·`shouldShowHeadingSeek(...)`(Task 5) 일치. `LecturePlaylist.seek(Duration)`·`duration`(ValueListenable<Duration?>)·`current`·`state`(#84) — Task 5에서 사용, 선행 확인으로 가드.
