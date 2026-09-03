# 오디오 자산 R2 분리 호스팅 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 강의 mp3 39개를 GitHub Pages 번들·git에서 빼내 Cloudflare R2(`https://aws-audio.leva.ai.kr`)에서 불변 키로 서빙하고, 앱은 `ContentEntry.audioSha8`로 URL을 조립한다.

**Architecture:** 앱은 `audio_meta.json`의 sha256 앞 8자리를 `content_index.dart`에 정적으로 복제(`audioSha8`, SSOT 동기화 테스트로 강제)해 `https://aws-audio.leva.ai.kr/{family}/{taskId}/{sha8}/lecture.mp3`를 만든다. 발행은 로컬 `tool/publish_audio.py`가 wrangler로 업로드하고 공개 URL을 Range 검사한다. mp3는 pubspec·git 추적에서 제거하고 로컬 사본만 남긴다. CI(pages.yml) 무변경.

**Tech Stack:** Flutter Web(Dart), Python 3 표준 라이브러리(`tool/*.py` 관례), `npx wrangler@latest`(OAuth 로그인), 기존 `tool/check_audio_range.py`.

**Spec:** `docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md`

## Global Constraints

- 브랜치: `feat/2026-09-audio-r2-hosting`(develop 분기) → develop PR → develop→main 릴리스 PR. 커밋 직전 `git branch --show-current` 검증(CLAUDE.md §5).
- 모든 flutter 명령은 `flutter_app/`에서. `flutter test` 전부 그린·`flutter analyze` 0건이 게이트. `flutter build web --release --base-href /aws-docs/`는 PowerShell에서만(Git Bash 금지).
- 공개 도메인·버킷: `aws-audio.leva.ai.kr`, 버킷 `aws-docs-audio`, zone id `22159344c213567f683ccf83c0d22780`.
- 키 규약: `{family}/{taskId}/{sha8}/lecture.mp3`, `sha8` = `audio_meta.json`의 `audio.sha256[:8]`(소문자). 업로드 헤더 `Content-Type: audio/mpeg`, `Cache-Control: public, max-age=31536000, immutable`. 키는 불변(덮어쓰기·삭제 금지).
- 승인(audioApproved=true) 엔트리 39개: CLF 19(`clf-t1-1`…`clf-t4-3`) + SAA 20(`saa-t1-1`~`saa-t1-5`, `saa-t2-1`~`saa-t2-5`, `saa-t3-1`~`saa-t3-9`, `saa-t4-1`). 미승인 엔트리는 `audioSha8` null 유지.
- Python 도구는 표준 라이브러리만, `--self-test` 관례 준수, Windows에서 `py`로 실행, 출력은 `PYTHONIOENCODING=utf-8`.
- 사람 전용 선행: Cloudflare 대시보드에서 R2 활성화(wrangler 오류 code 10042 해소). 이 전까지 Task 4·5는 실행 불가.

---

## File Structure

| 파일 | 책임 |
|---|---|
| `flutter_app/lib/data/audio_asset_url.dart` (수정) | base URL 상수(`kAudioBaseUrl`, dart-define 오버라이드) + `webAudioAssetUrl`의 절대 URL 통과 |
| `flutter_app/lib/data/content_index.dart` (수정) | `ContentEntry.audioSha8` 필드, `lectureAudioSrc` URL 조립, 승인 39건에 sha8 기재 |
| `flutter_app/test/audio_asset_url_test.dart` (수정) | 절대 URL 통과 테스트 |
| `flutter_app/test/content_index_test.dart` (수정) | `lectureAudioSrc` 규약 테스트 갱신, 동기화 테스트를 sha8 기준으로 재정의 |
| `flutter_app/tool/publish_audio.py` (신규) | sha 대조 → wrangler 업로드 → 공개 URL 검증. 순수 함수는 `--self-test` |
| `flutter_app/tool/r2_cors.json` (신규) | 버킷 CORS 정책 |
| `flutter_app/pubspec.yaml` (수정) | `lecture.mp3` 39항목 제거 |
| `.gitignore` (수정) | `flutter_app/assets/audio/*/*/lecture.mp3` |
| `docs/superpowers/plans/2026-07-19-saa-audio-rollout-handoff.md`, `CLAUDE.md`, `WORKLIST.md`, `docs/audits/2026-07/ROADMAP.md` (수정) | 발행 절차·B-4 완료 기록 |

---

### Task 1: `webAudioAssetUrl` 절대 URL 통과 + base URL 상수

**Files:**
- Modify: `flutter_app/lib/data/audio_asset_url.dart`
- Test: `flutter_app/test/audio_asset_url_test.dart`

**Interfaces:**
- Produces: `const String kAudioBaseUrl` (기본 `https://aws-audio.leva.ai.kr`, `--dart-define=audio_base_url=` 오버라이드), `String webAudioAssetUrl(String src)` — `http://`/`https://`로 시작하면 그대로, 아니면 `assets/$src`.

- [ ] **Step 1: 실패 테스트 추가** — `test/audio_asset_url_test.dart`의 `group` 안에 추가:

```dart
    test('절대 URL(http/https)은 assets/ 접두어 없이 그대로 통과한다', () {
      expect(
        webAudioAssetUrl('https://aws-audio.leva.ai.kr/clf/clf-t1-1/1a2b3c4d/lecture.mp3'),
        'https://aws-audio.leva.ai.kr/clf/clf-t1-1/1a2b3c4d/lecture.mp3',
      );
      expect(webAudioAssetUrl('http://localhost:8080/x.mp3'), 'http://localhost:8080/x.mp3');
    });

    test('kAudioBaseUrl 기본값은 R2 커스텀 도메인이며 끝에 슬래시가 없다', () {
      expect(kAudioBaseUrl, 'https://aws-audio.leva.ai.kr');
      expect(kAudioBaseUrl.endsWith('/'), isFalse);
    });
```

- [ ] **Step 2: 실패 확인** — `cd flutter_app && flutter test test/audio_asset_url_test.dart` → 컴파일 에러(`kAudioBaseUrl` 미정의) 또는 FAIL.

- [ ] **Step 3: 구현** — `lib/data/audio_asset_url.dart` 전체를 다음으로 교체:

```dart
/// 강의 mp3 공개 오리진(Cloudflare R2 커스텀 도메인). 끝 슬래시 없음.
///
/// `--dart-define=audio_base_url=https://...`로 오버라이드(로컬 dogfood·롤백).
/// 설계: docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md
const String kAudioBaseUrl = String.fromEnvironment(
  'audio_base_url',
  defaultValue: 'https://aws-audio.leva.ai.kr',
);

/// `<audio>.src`에 넣을 HTTP URL을 만든다.
///
/// - 절대 URL(`http://`/`https://`)은 그대로 반환한다(R2 mp3).
/// - rootBundle asset 키는 flutter web 규약대로 `assets/<키>`가 된다. 키 자체가
///   pubspec 경로(`assets/...`)라 최종 URL은 `assets/assets/...`(누락 시 404,
///   2026-06-26 라이브 dogfood로 확인).
String webAudioAssetUrl(String src) {
  if (src.startsWith('https://') || src.startsWith('http://')) return src;
  return 'assets/$src';
}
```

- [ ] **Step 4: 통과 확인** — `flutter test test/audio_asset_url_test.dart` → 4 tests PASS.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current   # feat/2026-09-audio-r2-hosting
git add flutter_app/lib/data/audio_asset_url.dart flutter_app/test/audio_asset_url_test.dart
git commit -m "feat(audio): webAudioAssetUrl 절대 URL 통과 + kAudioBaseUrl(dart-define)"
```

---

### Task 2: `ContentEntry.audioSha8` + `lectureAudioSrc` URL 조립 + 동기화 테스트 재정의

**Files:**
- Modify: `flutter_app/lib/data/content_index.dart` (ContentEntry 생성자·필드·`lectureAudioSrc`; 승인 39건에 `audioSha8:` 추가)
- Modify: `flutter_app/test/content_index_test.dart:183-232`

**Interfaces:**
- Consumes: `kAudioBaseUrl` (Task 1)
- Produces: `ContentEntry.audioSha8` (`String?`, 기본 null), `lectureAudioSrc` → 승인 엔트리는 `$kAudioBaseUrl/$family/$taskId/$audioSha8/lecture.mp3`, 미승인은 기존 `assets/audio/$family/$taskId/lecture.mp3`.

- [ ] **Step 1: 실패 테스트** — `test/content_index_test.dart`의 기존 `'ContentEntry.lectureAudioSrc: family/taskId 규약'` 테스트를 다음으로 교체하고, 동기화 테스트(`'동기화: audioApproved ↔ audio_meta.json reviewStatus + mp3 존재'`)를 아래 새 본문으로 교체:

```dart
  test('ContentEntry.lectureAudioSrc: 승인 엔트리는 R2 불변 키, 미승인은 assets 규약', () {
    final clf = contentFor('CLF-C02').first; // clf-t1-1, 승인
    expect(clf.audioApproved, isTrue);
    expect(clf.audioSha8, isNotNull);
    expect(
      clf.lectureAudioSrc,
      'https://aws-audio.leva.ai.kr/clf/clf-t1-1/${clf.audioSha8}/lecture.mp3',
    );
    final saaPending = contentFor('SAA-C03').firstWhere((e) => e.taskId == 'saa-t4-2');
    expect(saaPending.audioApproved, isFalse);
    expect(saaPending.audioSha8, isNull);
    expect(saaPending.lectureAudioSrc, 'assets/audio/saa/saa-t4-2/lecture.mp3');
  });

  // audioApproved=true ↔ audio_meta.json(top+script) approved && audioSha8 == sha256[:8].
  // SSOT는 audio_meta.json. mp3 본체는 R2에 있으므로 로컬 파일 존재는 검사하지 않는다
  // (릴리스 전 publish_audio.py --verify-all이 공개 URL을 실측).
  test('동기화: audioApproved ↔ audio_meta reviewStatus + audioSha8', () {
    final issues = <String>[];
    for (final entry in kContentIndex.entries) {
      for (final e in entry.value) {
        final meta = File(e.lectureAudioMetaSrc);
        String? status;
        String? scriptStatus;
        String? sha8;
        if (meta.existsSync()) {
          final m = json.decode(meta.readAsStringSync()) as Map<String, dynamic>;
          status = m['reviewStatus'] as String?;
          scriptStatus =
              (m['script'] as Map<String, dynamic>?)?['reviewStatus'] as String?;
          final sha = (m['audio'] as Map<String, dynamic>?)?['sha256'] as String?;
          sha8 = sha?.substring(0, 8);
        }
        final metaApproved = status == 'approved' && scriptStatus == 'approved';
        if (e.audioApproved != metaApproved) {
          issues.add('${e.taskId}: audioApproved=${e.audioApproved} != meta=$metaApproved (top=$status, script=$scriptStatus)');
        }
        if (e.audioApproved && e.audioSha8 != sha8) {
          issues.add('${e.taskId}: audioSha8=${e.audioSha8} != meta sha256[:8]=$sha8');
        }
        if (!e.audioApproved && e.audioSha8 != null) {
          issues.add('${e.taskId}: 미승인 엔트리에 audioSha8 존재');
        }
      }
    }
    expect(issues, isEmpty, reason: 'audioApproved/audioSha8 ↔ audio_meta 불일치:\n${issues.join('\n')}');
  });
```

- [ ] **Step 2: 실패 확인** — `flutter test test/content_index_test.dart` → 컴파일 에러(`audioSha8` 미정의).

- [ ] **Step 3: ContentEntry 구현** — `lib/data/content_index.dart`에서 생성자에 `this.audioSha8,` 추가(`this.audioApproved = false,` 다음 줄), 필드 선언 뒤에:

```dart
  /// 승인 오디오의 audio_meta.json `audio.sha256` 앞 8자리. R2 불변 키의 버전 세그먼트.
  /// SSOT는 audio_meta.json — content_index_test 동기화 테스트가 일치를 강제한다.
  /// 재합성(sha 변경) 시 이 값을 갱신하고 publish_audio.py로 새 키를 발행한다.
  final String? audioSha8;
```

`lectureAudioSrc` getter를 다음으로 교체(파일 상단에 `import 'audio_asset_url.dart';` 추가):

```dart
  /// 합친 강의 mp3 위치.
  /// - 승인(audioSha8 있음): R2 불변 키 `{base}/{family}/{taskId}/{sha8}/lecture.mp3`.
  /// - 미승인: 기존 번들 규약 `assets/audio/{family}/{taskId}/lecture.mp3`(노출 게이트가
  ///   막고 있어 실제 로드되지 않는 placeholder).
  String get lectureAudioSrc {
    final family = taskId.split('-').first;
    final sha = audioSha8;
    if (sha != null) return '$kAudioBaseUrl/$family/$taskId/$sha/lecture.mp3';
    return 'assets/audio/$family/$taskId/lecture.mp3';
  }
```

- [ ] **Step 4: 승인 39건에 sha8 기재** — 다음 스크립트로 `audioApproved: true,` 바로 뒤에 `audioSha8: '<sha8>',`를 삽입한다(`flutter_app/`에서 실행):

```bash
PYTHONIOENCODING=utf-8 py - <<'EOF'
import json,re
p='lib/data/content_index.dart'; c=open(p,encoding='utf-8').read(); n=0
def sha8(task):
    fam=task.split('-')[0]
    meta=json.load(open(f'assets/audio/{fam}/{task}/audio_meta.json',encoding='utf-8'))
    assert meta['reviewStatus']=='approved', task
    return meta['audio']['sha256'][:8]
pat=re.compile(r"(      taskId: '([a-z]+-t\d-\d)',\n(?:      [^\n]*\n)*?      audioApproved: true,\n)")
def rep(m):
    global n; n+=1
    return m.group(1)+f"      audioSha8: '{sha8(m.group(2))}',\n"
c=pat.sub(rep,c); open(p,'w',encoding='utf-8').write(c); print('audioSha8 inserted',n)
EOF
```
Expected: `audioSha8 inserted 39`. `grep -c "audioSha8: '" lib/data/content_index.dart` → 39.

- [ ] **Step 5: 통과 확인** — `flutter test test/content_index_test.dart test/content_index_audio_test.dart` → 전부 PASS. `flutter analyze` → 0건.

- [ ] **Step 6: 커밋**

```bash
git branch --show-current
git add flutter_app/lib/data/content_index.dart flutter_app/test/content_index_test.dart
git commit -m "feat(audio): ContentEntry.audioSha8 + lectureAudioSrc R2 불변 키 조립 (동기화 테스트 sha8 기준)"
```

---

### Task 3: 발행 도구 `tool/publish_audio.py` (순수 함수 self-test 포함)

**Files:**
- Create: `flutter_app/tool/publish_audio.py`
- Create: `flutter_app/tool/r2_cors.json`

**Interfaces:**
- Consumes: `tool/check_audio_range.py`의 `run_gate(url, *, timeout, expect_sha256=None) -> dict`(키 `ok: bool`, `checks: list`)와 `print_report(report)`.
- Produces: CLI `py tool/publish_audio.py [docId ...] [--all-approved] [--verify] [--verify-all] [--dry-run] [--self-test]`; 순수 함수 `object_key(task_id, sha256) -> str`, `public_url(task_id, sha256, base=BASE_URL) -> str`, `find_approved(audio_root) -> list[str]`.

- [ ] **Step 1: 파일 작성** — `flutter_app/tool/publish_audio.py`:

```python
#!/usr/bin/env python3
"""강의 mp3를 Cloudflare R2 공개 버킷에 불변 키로 발행하고 공개 URL을 검증한다.

키 규약: {family}/{taskId}/{sha8}/lecture.mp3  (sha8 = audio_meta.audio.sha256[:8])
정본은 R2 + audio_meta.json의 sha256. 로컬 assets/audio/*/*/lecture.mp3는 발행 원본(gitignore).

사용 (flutter_app/ 에서):
  py tool/publish_audio.py --self-test
  py tool/publish_audio.py saa-t1-1 saa-t1-2 --verify
  py tool/publish_audio.py --all-approved --verify
  py tool/publish_audio.py --verify-all          # 릴리스 전 게이트: approved 전수 HEAD/Range
  py tool/publish_audio.py --all-approved --dry-run

전제: `npx wrangler@latest whoami`가 로그인 상태이고 계정에 R2가 활성화돼 있을 것.
설계: docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md
"""
from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check_audio_range import print_report, run_gate  # noqa: E402

BUCKET = "aws-docs-audio"
BASE_URL = "https://aws-audio.leva.ai.kr"
AUDIO_ROOT = Path(__file__).resolve().parent.parent / "assets" / "audio"
CACHE_CONTROL = "public, max-age=31536000, immutable"


def family_of(task_id: str) -> str:
    return task_id.split("-")[0]


def object_key(task_id: str, sha256: str) -> str:
    if len(sha256) < 8 or any(c not in "0123456789abcdef" for c in sha256[:8]):
        raise ValueError(f"sha256 형식 오류: {sha256!r}")
    return f"{family_of(task_id)}/{task_id}/{sha256[:8]}/lecture.mp3"


def public_url(task_id: str, sha256: str, base: str = BASE_URL) -> str:
    return f"{base.rstrip('/')}/{object_key(task_id, sha256)}"


def read_meta(task_id: str, audio_root: Path = AUDIO_ROOT) -> dict:
    p = audio_root / family_of(task_id) / task_id / "audio_meta.json"
    return json.loads(p.read_text(encoding="utf-8"))


def find_approved(audio_root: Path = AUDIO_ROOT) -> list[str]:
    out: list[str] = []
    for meta in sorted(audio_root.glob("*/*/audio_meta.json")):
        m = json.loads(meta.read_text(encoding="utf-8"))
        if m.get("reviewStatus") == "approved" and (m.get("script") or {}).get("reviewStatus") == "approved":
            out.append(meta.parent.name)
    return out


def local_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def head_status(url: str, timeout: float = 15.0) -> int:
    req = urllib.request.Request(url, method="HEAD")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


def wrangler_put(key: str, file: Path, *, dry_run: bool) -> None:
    cmd = ["npx", "--yes", "wrangler@latest", "r2", "object", "put", f"{BUCKET}/{key}",
           "--file", str(file), "--content-type", "audio/mpeg",
           "--cache-control", CACHE_CONTROL, "--remote"]
    print("  $", " ".join(cmd))
    if dry_run:
        return
    subprocess.run(cmd, check=True, shell=(sys.platform == "win32"))


def publish(task_id: str, *, dry_run: bool, verify: bool, audio_root: Path = AUDIO_ROOT) -> bool:
    meta = read_meta(task_id, audio_root)
    if meta.get("reviewStatus") != "approved":
        print(f"[skip] {task_id}: reviewStatus={meta.get('reviewStatus')} (approved만 발행)")
        return True
    sha = meta["audio"]["sha256"]
    mp3 = audio_root / family_of(task_id) / task_id / "lecture.mp3"
    if not mp3.exists():
        print(f"[FAIL] {task_id}: 로컬 mp3 없음 {mp3}")
        return False
    actual = local_sha256(mp3)
    if actual != sha:
        print(f"[FAIL] {task_id}: 로컬 mp3 sha256({actual[:8]}) != audio_meta({sha[:8]}) — 재합성/메타 불일치")
        return False
    key = object_key(task_id, sha)
    url = public_url(task_id, sha)
    if head_status(url) == 200:
        print(f"[exists] {task_id}: {url}")
    else:
        print(f"[put] {task_id}: {key} ({mp3.stat().st_size:,}B)")
        wrangler_put(key, mp3, dry_run=dry_run)
    if verify and not dry_run:
        report = run_gate(url, timeout=20.0, expected_sha256=None)
        print_report(report)
        return bool(report["ok"])
    return True


def verify_all(audio_root: Path = AUDIO_ROOT) -> bool:
    ok = True
    for task_id in find_approved(audio_root):
        meta = read_meta(task_id, audio_root)
        url = public_url(task_id, meta["audio"]["sha256"])
        report = run_gate(url, timeout=20.0, expected_sha256=None)
        print(("PASS " if report["ok"] else "FAIL ") + url)
        ok = ok and bool(report["ok"])
    return ok


def _self_test() -> None:
    assert object_key("saa-t1-1", "1e6f1170" + "0" * 56) == "saa/saa-t1-1/1e6f1170/lecture.mp3"
    assert public_url("clf-t4-3", "abcdef01" + "0" * 56) == "https://aws-audio.leva.ai.kr/clf/clf-t4-3/abcdef01/lecture.mp3"
    assert public_url("clf-t1-1", "0" * 64, base="http://localhost:8124/") == "http://localhost:8124/clf/clf-t1-1/00000000/lecture.mp3"
    try:
        object_key("clf-t1-1", "ZZZ")
        raise AssertionError("잘못된 sha를 거부해야 함")
    except ValueError:
        pass
    import tempfile
    with tempfile.TemporaryDirectory() as d:
        root = Path(d)
        for tid, st in (("clf-t1-1", "approved"), ("saa-t4-2", "needs_human_review")):
            p = root / family_of(tid) / tid
            p.mkdir(parents=True)
            (p / "audio_meta.json").write_text(json.dumps({
                "reviewStatus": st, "script": {"reviewStatus": st},
                "audio": {"sha256": "ab" * 32}}), encoding="utf-8")
        assert find_approved(root) == ["clf-t1-1"], find_approved(root)
    print("publish_audio self-test OK")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("docs", nargs="*", help="docId (예: saa-t1-1)")
    ap.add_argument("--all-approved", action="store_true", help="audio_meta approved 전수 발행")
    ap.add_argument("--verify", action="store_true", help="발행 후 공개 URL Range 검사")
    ap.add_argument("--verify-all", action="store_true", help="approved 전수 공개 URL 검사만(발행 안 함)")
    ap.add_argument("--dry-run", action="store_true", help="wrangler 실행 없이 명령만 출력")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        _self_test()
        return
    if a.verify_all:
        sys.exit(0 if verify_all() else 1)
    docs = find_approved() if a.all_approved else a.docs
    if not docs:
        ap.error("docId 또는 --all-approved / --verify-all 필요")
    ok = True
    for d in docs:
        ok = publish(d, dry_run=a.dry_run, verify=a.verify) and ok
    print("[publish] " + ("OK" if ok else "FAIL"))
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
```

- [ ] **Step 2: CORS 정책 파일** — `flutter_app/tool/r2_cors.json`:

```json
[
  {
    "AllowedOrigins": ["https://velkaressiablutkrone.github.io", "http://localhost:8124"],
    "AllowedMethods": ["GET", "HEAD"],
    "AllowedHeaders": ["Range"],
    "ExposeHeaders": ["Content-Length", "Content-Range", "Accept-Ranges", "ETag"],
    "MaxAgeSeconds": 86400
  }
]
```

- [ ] **Step 3: self-test·dry-run 확인** — `flutter_app/`에서:

```bash
PYTHONIOENCODING=utf-8 py tool/publish_audio.py --self-test      # publish_audio self-test OK
PYTHONIOENCODING=utf-8 py tool/publish_audio.py --all-approved --dry-run | tail -3
```
Expected: dry-run이 39개 `[put]`(도메인 미연결 상태라 HEAD가 200이 아님) 또는 `[exists]`를 출력하고 `[publish] OK`. 로컬 sha 불일치가 하나라도 있으면 `[FAIL]` — 그 문서는 메타·mp3를 재확인한다.

- [ ] **Step 4: 커밋**

```bash
git branch --show-current
git add flutter_app/tool/publish_audio.py flutter_app/tool/r2_cors.json
git commit -m "feat(audio): publish_audio.py — R2 불변 키 발행·공개 URL Range 검증 도구"
```

---

### Task 4: R2 인프라 생성 (버킷·도메인·CORS) — 사람 선행: 대시보드 R2 활성화

**Files:** 없음(외부 인프라). 산출물 기록은 Task 7 문서.

**Interfaces:**
- Consumes: `tool/r2_cors.json` (Task 3)
- Produces: 공개 오리진 `https://aws-audio.leva.ai.kr` (Active), 버킷 `aws-docs-audio`.

- [ ] **Step 1: 선행 확인** — `npx --yes wrangler@latest r2 bucket list`가 오류 `code: 10042`(R2 미활성)면 사용자에게 대시보드 R2 활성화를 요청하고 멈춘다. 목록이 출력되면 진행.

- [ ] **Step 2: 버킷 생성**

```bash
npx --yes wrangler@latest r2 bucket create aws-docs-audio
npx --yes wrangler@latest r2 bucket list | grep -A2 aws-docs-audio
```

- [ ] **Step 3: 커스텀 도메인 연결**

```bash
npx --yes wrangler@latest r2 bucket domain add aws-docs-audio --domain aws-audio.leva.ai.kr --zone-id 22159344c213567f683ccf83c0d22780 --min-tls 1.2 --force
npx --yes wrangler@latest r2 bucket domain list aws-docs-audio
```
Expected: 상태 `Initializing` → 수 분 내 `Active`. `list`를 재실행해 Active 확인. r2.dev는 활성화하지 않는다.

- [ ] **Step 4: CORS 적용**

```bash
npx --yes wrangler@latest r2 bucket cors set aws-docs-audio --file tool/r2_cors.json --force
npx --yes wrangler@latest r2 bucket cors list aws-docs-audio
```

- [ ] **Step 5: 스모크(테스트 객체)** — 아무 승인 mp3 1개를 임시 키로 올려 Range 검사 후 삭제:

```bash
npx --yes wrangler@latest r2 object put aws-docs-audio/_smoke/lecture.mp3 --file assets/audio/clf/clf-t1-1/lecture.mp3 --content-type audio/mpeg --cache-control "public, max-age=60" --remote
PYTHONIOENCODING=utf-8 py tool/check_audio_range.py https://aws-audio.leva.ai.kr/_smoke/lecture.mp3
npx --yes wrangler@latest r2 object delete aws-docs-audio/_smoke/lecture.mp3 --remote
```
Expected: check_audio_range 전 항목 PASS(HEAD 2xx·audio/mpeg·Accept-Ranges·206·캐시 헤더). 실패 시 도메인 Active 여부·TLS(1단계 서브도메인)부터 확인.

- [ ] **Step 6: 기록** — 커밋 없음. Task 7에서 문서화.

---

### Task 5: 39개 발행 + 전수 검증

**Files:** 없음(R2 객체).

**Interfaces:**
- Consumes: `publish_audio.py` (Task 3), 인프라 (Task 4)
- Produces: 39개 공개 URL 200/206.

- [ ] **Step 1: 발행**

```bash
PYTHONIOENCODING=utf-8 py tool/publish_audio.py --all-approved --verify 2>&1 | tee ../build/publish_audio.log | grep -E '^\[|PASS|FAIL' | tail -45
```
Expected: 39개 `[put]`(약 434MB 업로드) 후 각 리포트 PASS, 마지막 `[publish] OK`. 재실행 시 `[exists]`로 건너뛴다.

- [ ] **Step 2: 전수 게이트**

```bash
PYTHONIOENCODING=utf-8 py tool/publish_audio.py --verify-all; echo exit=$?
```
Expected: `PASS https://aws-audio.leva.ai.kr/...` 39줄, exit=0.

---

### Task 6: 번들·git에서 mp3 제거

**Files:**
- Modify: `flutter_app/pubspec.yaml` (`lecture.mp3` 39줄 삭제)
- Modify: `.gitignore`
- Git: `git rm --cached` 39개

**Interfaces:**
- Consumes: Task 2(앱이 더 이상 번들 mp3를 참조하지 않음), Task 5(R2에 전수 존재)

- [ ] **Step 1: 실패하는 검사 만들기** — 빌드 산출물에 mp3가 없어야 한다는 검사를 셸로 정의한다(테스트 파일 아님):

```bash
# flutter_app/ 에서, 아직 pubspec 수정 전 — 현재는 39가 나와야(실패 상태) 한다
grep -c 'lecture.mp3' pubspec.yaml
```

- [ ] **Step 2: pubspec·gitignore·추적 해제**

```bash
py - <<'EOF'
p='pubspec.yaml'; L=[l for l in open(p,encoding='utf-8').read().splitlines(True) if not l.strip().endswith('/lecture.mp3')]
open(p,'w',encoding='utf-8').write(''.join(L)); print('remaining mp3 lines', sum(1 for l in L if 'lecture.mp3' in l))
EOF
cd .. && printf '# 강의 mp3 정본은 R2(aws-audio.leva.ai.kr) + audio_meta sha256 — 로컬 사본은 발행 원본으로만 보관\nflutter_app/assets/audio/*/*/lecture.mp3\n' >> .gitignore
git rm --cached -q flutter_app/assets/audio/*/*/lecture.mp3 && git status --short | grep -c '^D '
```
Expected: `remaining mp3 lines 0`, `git status` D 39. 로컬 파일은 남아 있음(`ls flutter_app/assets/audio/saa/saa-t1-1/lecture.mp3`).

- [ ] **Step 3: 게이트** — `flutter_app/`에서 `flutter test`(전부 그린, 796 이상)·`flutter analyze`(0). PowerShell에서 `flutter build web --release --base-href /aws-docs/ --dart-define=audio_lecture=true` 후 `Get-ChildItem build\web\assets\assets\audio -Recurse -Filter lecture.mp3 | Measure-Object` → Count 0, `build\web` 총 크기 약 60MB.

- [ ] **Step 4: 로컬 dogfood** — `flutter build web --release` (base-href 기본) 후 `node` 정적 서버로 `build/web`을 8124 포트에서 서빙(메모리 [[flutter-web-dogfood-browse]] 레시피), CLF `clf-t1-1`과 SAA `saa-t1-1` 학습문서에서 미니플레이어 재생·시크·챕터 점프 확인, 콘솔 에러 0. 브라우저 네트워크 탭에서 요청 URL이 `https://aws-audio.leva.ai.kr/...` 206인지 확인.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add .gitignore flutter_app/pubspec.yaml
git commit -m "feat(audio): mp3 39개 번들·git 추적 제거 — R2 서빙 전환 (build/web 493MB→약 60MB)"
```

---

### Task 7: 문서·핸드오프·완료 기록

**Files:**
- Modify: `docs/superpowers/plans/2026-07-19-saa-audio-rollout-handoff.md` (재개 절차에 발행 단계 추가)
- Modify: `CLAUDE.md` 빌드·테스트 절 (오디오 발행 게이트 1줄)
- Modify: `WORKLIST.md` §A 오디오 항목·§E, `docs/audits/2026-07/ROADMAP.md` B-4 표

- [ ] **Step 1: 핸드오프 재개 절차** — "커밋" 단계 뒤에 추가:

```
# 승인(청취 또는 면제) 후:
#   audio_meta/script reviewStatus=approved, content_index audioApproved:true + audioSha8:'<sha256[:8]>'
#   py tool/publish_audio.py <docId> --verify      # R2 발행 + Range 검증
#   릴리스 전: py tool/publish_audio.py --verify-all
```
그리고 "비자명 교훈"에 `synthesize는 sha를 바꾸므로 재합성 문서는 audioSha8 갱신 + 재발행 필수(동기화 테스트가 잡음)`를 추가.

- [ ] **Step 2: CLAUDE.md 빌드·테스트 절** — 목록에 한 줄 추가:

```
- **오디오 발행 게이트:** 강의 mp3는 번들이 아니라 R2(`https://aws-audio.leva.ai.kr`)에서 서빙된다. 승인 문서 추가·재합성 후 `py tool/publish_audio.py <docId> --verify`, 릴리스 전 `py tool/publish_audio.py --verify-all`이 39/39(이후 증가) PASS여야 한다. 설계: `docs/superpowers/specs/2026-09-03-audio-r2-hosting-design.md`.
```

- [ ] **Step 3: WORKLIST·ROADMAP** — WORKLIST §A 오디오 항목의 "⚠️ 번들 493MB … 선결" 문구를 "✅ R2 분리(PR#…)로 해소, 번들 약 60MB"로 교체하고, ROADMAP B-4 표의 "174MB 오디오 자산 전략" 행에 `→ 2026-09-03 R2 분리 완료(spec 2026-09-03-audio-r2-hosting-design)`를 덧붙인다.

- [ ] **Step 4: 커밋·PR**

```bash
git branch --show-current
git add CLAUDE.md WORKLIST.md docs/audits/2026-07/ROADMAP.md docs/superpowers/plans/2026-07-19-saa-audio-rollout-handoff.md
git commit -m "docs(audio): R2 발행 절차·게이트 문서화 + B-4 완료 기록"
git push -u origin feat/2026-09-audio-r2-hosting
gh pr create --base develop --head feat/2026-09-audio-r2-hosting --title "feat(audio): 강의 mp3 R2 분리 호스팅 (aws-audio.leva.ai.kr, 번들 493MB→약 60MB)"
```
PR 본문에 검증 결과(테스트 수·analyze·`--verify-all` 39/39·build/web 크기·dogfood)를 기재한다. 머지 후 develop→main 릴리스 PR, Pages 배포 success 확인, 라이브에서 `py tool/publish_audio.py --verify-all` 재실행과 `curl -r 0-1 https://aws-audio.leva.ai.kr/saa/saa-t1-1/<sha8>/lecture.mp3` 206 확인.
