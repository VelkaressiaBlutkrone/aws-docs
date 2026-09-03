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
from check_audio_range import USER_AGENT, print_report, run_gate  # noqa: E402

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
        script_status = (m.get("script") or {}).get("reviewStatus")
        if m.get("reviewStatus") == "approved" and script_status == "approved":
            out.append(meta.parent.name)
    return out


def local_sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def head_status(url: str, timeout: float = 15.0) -> int:
    req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except urllib.error.URLError:
        return 0


def wrangler_put(key: str, file: Path, *, dry_run: bool) -> None:
    cmd = [
        "npx", "--yes", "wrangler@latest", "r2", "object", "put", f"{BUCKET}/{key}",
        "--file", str(file), "--content-type", "audio/mpeg",
        "--cache-control", CACHE_CONTROL, "--remote",
    ]
    print("  $", " ".join(cmd))
    if dry_run:
        return
    subprocess.run(cmd, check=True, shell=(sys.platform == "win32"))


def publish(task_id: str, *, dry_run: bool, verify: bool,
            audio_root: Path = AUDIO_ROOT) -> bool:
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
        print(f"[FAIL] {task_id}: 로컬 mp3 sha256({actual[:8]}) != audio_meta({sha[:8]}) "
              "— 재합성/메타 불일치")
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
    assert public_url("clf-t4-3", "abcdef01" + "0" * 56) == (
        "https://aws-audio.leva.ai.kr/clf/clf-t4-3/abcdef01/lecture.mp3")
    assert public_url("clf-t1-1", "0" * 64, base="http://localhost:8124/") == (
        "http://localhost:8124/clf/clf-t1-1/00000000/lecture.mp3")
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
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("docs", nargs="*", help="docId (예: saa-t1-1)")
    ap.add_argument("--all-approved", action="store_true", help="audio_meta approved 전수 발행")
    ap.add_argument("--verify", action="store_true", help="발행 후 공개 URL Range 검사")
    ap.add_argument("--verify-all", action="store_true",
                    help="approved 전수 공개 URL 검사만(발행 안 함)")
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
