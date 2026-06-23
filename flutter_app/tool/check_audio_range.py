#!/usr/bin/env python3
"""학습 오디오 M1 T7 — 배포된 MP3 Range/캐시 게이트.

검수 전 오디오를 공개 UI에 연결하기 전에, 실제 호스팅 URL이 긴 MP3 재생에 맞는
응답을 주는지 확인한다.

검사:
  - HEAD 2xx/3xx
  - Content-Type: audio/mpeg
  - Accept-Ranges: bytes
  - GET Range: bytes=0-1 -> 206 + Content-Range + 2바이트 본문
  - Cache-Control 또는 ETag 또는 Last-Modified 존재
  - 선택: --expect-sha256 으로 전체 파일 해시 대조(새 배포/캐시 stale 확인)

사용:
  python tool/check_audio_range.py --self-test
  python tool/check_audio_range.py https://.../assets/audio/clf/clf-t1-1/lecture.mp3
  python tool/check_audio_range.py https://.../lecture.mp3 --expect-sha256 <sha256>
"""

import argparse
import hashlib
import json
import sys
import urllib.error
import urllib.request
from email.message import Message
from typing import Any


def _request(url: str, *, method: str, headers: dict[str, str] | None = None,
             timeout: float = 15.0) -> tuple[int, Message, bytes]:
    req = urllib.request.Request(url, method=method, headers=headers or {})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.status, resp.headers, resp.read()
    except urllib.error.HTTPError as e:
        return e.code, e.headers, e.read()


def _h(headers: Message, name: str) -> str:
    return headers.get(name, "")


def _check(checks: list[dict[str, Any]], name: str, ok: bool, detail: str,
           required: bool = True) -> None:
    checks.append({
        "name": name,
        "ok": ok,
        "required": required,
        "detail": detail,
    })


def evaluate(
    *,
    url: str,
    head_status: int,
    head_headers: Message,
    range_status: int,
    range_headers: Message,
    range_body: bytes,
    expected_sha256: str | None = None,
    actual_sha256: str | None = None,
) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []

    content_type = _h(head_headers, "Content-Type") or _h(
        range_headers, "Content-Type")
    accept_ranges = _h(head_headers, "Accept-Ranges") or _h(
        range_headers, "Accept-Ranges")
    content_range = _h(range_headers, "Content-Range")
    cache_control = _h(head_headers, "Cache-Control")
    etag = _h(head_headers, "ETag")
    last_modified = _h(head_headers, "Last-Modified")

    _check(
        checks,
        "headStatus",
        200 <= head_status < 400,
        f"HEAD status={head_status}",
    )
    _check(
        checks,
        "contentType",
        content_type.lower().split(";")[0].strip() == "audio/mpeg",
        f"Content-Type={content_type or '(missing)'}",
    )
    _check(
        checks,
        "acceptRanges",
        "bytes" in accept_ranges.lower(),
        f"Accept-Ranges={accept_ranges or '(missing)'}",
    )
    _check(
        checks,
        "rangeStatus",
        range_status == 206,
        f"Range GET status={range_status}",
    )
    _check(
        checks,
        "contentRange",
        content_range.startswith("bytes 0-1/"),
        f"Content-Range={content_range or '(missing)'}",
    )
    _check(
        checks,
        "rangeBody",
        len(range_body) == 2,
        f"range body bytes={len(range_body)}",
    )
    _check(
        checks,
        "cacheValidator",
        bool(cache_control or etag or last_modified),
        "Cache-Control/ETag/Last-Modified 중 하나 필요 "
        f"(Cache-Control={cache_control or '-'}, ETag={etag or '-'}, "
        f"Last-Modified={last_modified or '-'})",
    )

    if expected_sha256 is not None:
        _check(
            checks,
            "sha256",
            actual_sha256 == expected_sha256.lower(),
            f"expected={expected_sha256.lower()} actual={actual_sha256 or '-'}",
        )

    required = [c for c in checks if c["required"]]
    return {
        "url": url,
        "ok": all(c["ok"] for c in required),
        "checks": checks,
    }


def _sha256_url(url: str, timeout: float) -> str:
    req = urllib.request.Request(url, method="GET")
    h = hashlib.sha256()
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        while True:
            chunk = resp.read(1024 * 1024)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def run_gate(url: str, *, timeout: float,
             expected_sha256: str | None) -> dict[str, Any]:
    head_status, head_headers, _ = _request(url, method="HEAD", timeout=timeout)
    range_status, range_headers, range_body = _request(
        url,
        method="GET",
        headers={"Range": "bytes=0-1"},
        timeout=timeout,
    )
    actual_sha256 = (
        _sha256_url(url, timeout) if expected_sha256 is not None else None
    )
    return evaluate(
        url=url,
        head_status=head_status,
        head_headers=head_headers,
        range_status=range_status,
        range_headers=range_headers,
        range_body=range_body,
        expected_sha256=expected_sha256,
        actual_sha256=actual_sha256,
    )


def print_report(report: dict[str, Any]) -> None:
    print(f"[{'PASS' if report['ok'] else 'FAIL'}] {report['url']}")
    for c in report["checks"]:
        mark = "OK" if c["ok"] else "FAIL"
        print(f"  {mark:4} {c['name']}: {c['detail']}")
    if not report["ok"]:
        print("\n조치 기준:")
        print("- Range 실패: 호스팅/캐시 설정 문제입니다. 제품 방향을 바꾸지 말고 배포층을 고칩니다.")
        print("- Content-Type 실패: MP3가 audio/mpeg로 서빙되도록 설정합니다.")
        print("- sha256 실패: 새 배포를 기다리거나 stale 캐시/잘못된 URL을 확인합니다.")


def _headers(**items: str) -> Message:
    msg = Message()
    for k, v in items.items():
        msg[k.replace("_", "-")] = v
    return msg


def _self_test() -> None:
    good = evaluate(
        url="https://example.test/lecture.mp3",
        head_status=200,
        head_headers=_headers(
            Content_Type="audio/mpeg",
            Accept_Ranges="bytes",
            Cache_Control="public, max-age=600",
            ETag='"abc"',
        ),
        range_status=206,
        range_headers=_headers(
            Content_Type="audio/mpeg",
            Content_Range="bytes 0-1/10",
        ),
        range_body=b"\x00\x01",
    )
    assert good["ok"] is True, good

    bad = evaluate(
        url="https://example.test/lecture.mp3",
        head_status=200,
        head_headers=_headers(Content_Type="text/plain"),
        range_status=200,
        range_headers=_headers(),
        range_body=b"whole file",
    )
    assert bad["ok"] is False, bad
    failed = {c["name"] for c in bad["checks"] if not c["ok"]}
    assert {"contentType", "acceptRanges", "rangeStatus", "contentRange",
            "rangeBody", "cacheValidator"} <= failed, failed

    hash_bad = evaluate(
        url="https://example.test/lecture.mp3",
        head_status=200,
        head_headers=_headers(
            Content_Type="audio/mpeg",
            Accept_Ranges="bytes",
            Last_Modified="Mon, 22 Jun 2026 00:00:00 GMT",
        ),
        range_status=206,
        range_headers=_headers(Content_Range="bytes 0-1/2"),
        range_body=b"\x00\x01",
        expected_sha256="0" * 64,
        actual_sha256="1" * 64,
    )
    assert hash_bad["ok"] is False, hash_bad
    assert any(c["name"] == "sha256" and not c["ok"]
               for c in hash_bad["checks"]), hash_bad
    print("self-test OK")


def main() -> None:
    ap = argparse.ArgumentParser(
        description="배포된 학습 오디오 MP3의 Range/캐시 응답을 검증합니다.")
    ap.add_argument("url", nargs="?", help="배포된 lecture.mp3 URL")
    ap.add_argument("--expect-sha256",
                    help="전체 GET으로 대조할 기대 SHA-256(캐시 stale 확인)")
    ap.add_argument("--timeout", type=float, default=15.0)
    ap.add_argument("--json", action="store_true", help="JSON 리포트 출력")
    ap.add_argument("--self-test", action="store_true")
    args = ap.parse_args()

    if args.self_test:
        _self_test()
        return
    if not args.url:
        ap.error("url 또는 --self-test 가 필요합니다.")

    report = run_gate(
        args.url,
        timeout=args.timeout,
        expected_sha256=args.expect_sha256,
    )
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_report(report)
    sys.exit(0 if report["ok"] else 1)


if __name__ == "__main__":
    main()
