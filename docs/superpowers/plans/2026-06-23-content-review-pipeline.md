# 학습 오디오 콘텐츠 검수 파이프라인 — 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 학습 문서 `.md`를 사람이 보정 가능한 `script.json`(SSOT)으로 분해하고, 발음사전·표 요약·정적 게이트·청취 검수표를 붙여 `reviewStatus=approved`까지 갈 수 있는 오프라인 검수 파이프라인을 만든다.

**Architecture:** `gen_lecture_audio.py`를 `generate`(md→script.json) · `synthesize`(script.json→mp3) · `gate`(정적 검증) 서브커맨드로 재구성한다. 기존 정제 헬퍼(`_convert_symbols`·`_EMOJI`·인라인 정리·`_strip_id3v2`·`build_audio_meta`)를 재사용하고, segment 파서·발음사전·표 요약·게이트를 새로 추가한다. 합성은 `script.json`의 `scriptText`만 읽는다(md 재파싱 금지).

**Tech Stack:** Python 3(표준 라이브러리만; 합성 시 boto3/Amazon Polly), 기존 `flutter_app/tool/gen_lecture_audio.py` 패턴, `--self-test` 단위 검증(네트워크·TTS 엔진 불필요).

## Global Constraints

이 절은 모든 task에 암묵적으로 포함된다. spec에서 그대로 옮긴다.

- **검수 전 비공개(3중 잠금):** 도구는 `reviewStatus`를 `approved`로 자동 설정하는 경로를 만들지 않는다. `approved` 전에는 mp3·`script.json`을 repo에 커밋하지 않고 `pubspec.yaml`의 `assets/audio/`에도 등록하지 않으며 기본 빌드 `audio_lecture=false`를 유지한다.
- **SSOT 불변식:** `synthesize`는 `script.json`의 `scriptText`만 읽는다. md를 재파싱하지 않는다.
- **검증 방식:** 이 도구는 `flutter_app/tool/`의 파이썬 도구다. 검증은 기존 패턴대로 `_self_test()` 확장 + `py tool/gen_lecture_audio.py --self-test`로 한다(네트워크·Polly 불필요). Dart `flutter test`/`flutter analyze` 게이트와는 별개다.
- **Python 실행:** Windows는 `py` 런처를 쓴다(`python`은 Store alias로 깨질 수 있음).
- **커밋 안전(§5):** 커밋 직전 항상 `git branch --show-current`로 `feat/content-review-pipeline`인지 확인한다(공유 워킹트리). 스테이징은 항상 정확한 파일 경로로 한다(검수 전 `assets/audio/` 픽스처를 절대 add하지 않는다).
- **파일 배치:** 산출물은 `assets/audio/{family}/{docId}/` 아래 `script.json`·`lecture.mp3`·`audio_meta.json`·`review_checklist.md`. `family`는 `docId`의 접두어(예: `clf-t1-1`→`clf`).

---

## File Structure

- **Modify:** `flutter_app/tool/gen_lecture_audio.py` — 헬퍼 추출(`_clean_inline`·`_strip_list_markers`) + 신규(`parse_segments`·`load_lexicon`·`apply_lexicon`·`table_to_summary`·`build_script_json`·`run_generate`·`run_synthesize`·`run_gate`) + `main` 서브커맨드 재구성 + `_self_test` 확장.
- **Create:** `flutter_app/tool/lexicon.json` — 약어 발음사전 시드(전 문서 공유).
- **Runtime 산출(커밋 안 함):** `assets/audio/{family}/{docId}/script.json`·`review_checklist.md`.

기존 `gen_lecture_audio.py`는 528줄이다. 이미 큰 파일이므로 이 작업 범위에서 분할하지는 않되, 새 함수는 책임별로 응집되게 추가하고 기존 함수는 재사용한다.

---

## Task 1: 인라인 정리 헬퍼 추출 + segment 파서

기존 `markdown_to_speech_text`의 인라인 정리 로직을 헬퍼로 추출하고, md를 segment 리스트로 분해하는 `parse_segments`를 추가한다. 이 task는 텍스트→구조화만 한다(발음사전·표 요약은 Task 2·3).

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (헬퍼 추출 + `parse_segments` 추가, `_self_test` 확장)

**Interfaces:**
- Produces:
  - `_clean_inline(s: str) -> str` — 한 줄/문단의 인라인 마크다운·기호를 음성 평문으로 정리.
  - `_strip_list_markers(s: str) -> str` — 리스트/인용/체크박스 줄머리 마커 제거.
  - `parse_segments(md: str) -> list[dict]` — segment dict 리스트. 각 dict 키: `id`(str `seg000`…), `kind`(`heading|paragraph|table|selfcheck|source`), `sourceExcerpt`(str), `scriptText`(str), `audioSummary`(None), `skip`(bool), `issues`(list[str]). table은 이 task에서 `audioSummary=None, issues=["table-needs-summary"]` placeholder(Task 3에서 채움).

- [ ] **Step 1: 실패 테스트 추가** — `_self_test()` 끝(`print("self-test OK")` 직전)에 추가:

```python
    # Task 1: segment 파서
    seg_md = (
        "---\nname: x\n---\n"
        "# 제목입니다 {#intro}\n\n"
        "첫 문단입니다. 둘째 문장.\n\n"
        "- 목록 [링크](https://x) 항목\n\n"
        "| 열A | 열B |\n| --- | --- |\n| 가 | 나 |\n\n"
        "## 🧪 자가 점검\n\n"
        "**Q1.** 질문입니까?\n\n"
        "<details><summary>정답 보기</summary>\n비밀.\n</details>\n\n"
        "### 📌 출처\n\n1. 자료 https://aws.amazon.com/x/\n"
    )
    segs = parse_segments(seg_md)
    kinds = [g["kind"] for g in segs]
    assert kinds[0] == "heading" and segs[0]["scriptText"] == "제목입니다", segs[0]
    assert any(g["kind"] == "paragraph" and "첫 문단입니다" in g["scriptText"] for g in segs), segs
    assert any(g["kind"] == "paragraph" and "목록 링크 항목" in g["scriptText"] for g in segs), segs
    tbl = [g for g in segs if g["kind"] == "table"]
    assert len(tbl) == 1 and tbl[0]["skip"] is False and tbl[0]["audioSummary"] is None, tbl
    assert "| 열A" in tbl[0]["sourceExcerpt"], tbl[0]
    sc = [g for g in segs if g["kind"] == "selfcheck"]
    assert sc and all(g["skip"] for g in sc), sc
    assert all("질문입니까" not in g["scriptText"] for g in segs), "selfcheck 본문 누출"
    src = [g for g in segs if g["kind"] == "source"]
    assert src and all(g["skip"] for g in src), src
    assert all("aws.amazon" not in g["scriptText"] for g in segs), "URL 누출"
    assert all(g["id"] == f"seg{n:03d}" for n, g in enumerate(segs)), [g["id"] for g in segs]
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `AssertionError` 또는 `NameError: name 'parse_segments' is not defined`.

- [ ] **Step 3: 구현** — `markdown_to_speech_text` 함수 바로 아래에 추가. (기존 `markdown_to_speech_text`·`_convert_symbols`·`_EMOJI`는 그대로 둔다.)

```python
def _clean_inline(s: str) -> str:
    """한 줄/문단 텍스트의 인라인 마크다운·기호를 음성 평문으로 정리(scriptText용)."""
    s = re.sub(r"\s*\{#[^}]*\}\s*$", "", s)
    s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)
    s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)
    s = re.sub(r"<[^>]+>", "", s)
    s = re.sub(r"[*`]+", "", s)
    s = _EMOJI.sub("", s)
    s = _convert_symbols(s)
    s = re.sub(r"\s{2,}", " ", s)
    s = re.sub(r"\s+([.,)\]])", r"\1", s)
    s = re.sub(r"([(\[])\s+", r"\1", s)
    s = re.sub(r",\s*\.", ".", s)
    s = re.sub(r"([.,])\1+", r"\1", s)
    return s.strip().strip(",")


def _strip_list_markers(s: str) -> str:
    """리스트·인용·체크박스 줄머리 마커 제거."""
    s = re.sub(r"^[-*+]\s+", "", s)
    s = re.sub(r"^\d+\.\s+", "", s)
    s = re.sub(r"^>\s*", "", s)
    s = re.sub(r"^\[[ xX]\]\s*", "", s)
    return s


def parse_segments(md: str) -> list[dict]:
    """md를 segment dict 리스트로 분해. kind 분류 + scriptText 정제(발음사전·표요약 제외)."""
    segs: list[dict] = []

    def _add(kind, excerpt, script, *, skip=False, audio_summary=None, issues=None):
        segs.append({
            "id": f"seg{len(segs):03d}",
            "kind": kind,
            "sourceExcerpt": excerpt.strip(),
            "scriptText": script,
            "audioSummary": audio_summary,
            "skip": skip,
            "issues": list(issues or []),
        })

    lines = md.splitlines()
    n = len(lines)
    i = 0
    if i < n and lines[i].strip() == "---":            # frontmatter
        i += 1
        while i < n and lines[i].strip() != "---":
            i += 1
        i += 1
    in_selfcheck = False
    while i < n:
        s = lines[i].strip()
        if not s:
            i += 1
            continue
        if s.startswith("```"):                          # 코드펜스 제외
            i += 1
            while i < n and not lines[i].strip().startswith("```"):
                i += 1
            i += 1
            continue
        if (re.fullmatch(r"([-*_])\1{2,}", s) or s.startswith("<!--")
                or s.startswith("![")):                  # 수평선·주석·이미지
            i += 1
            continue
        if "<details" in s:                              # 정답 보기 블록
            block = [lines[i]]
            i += 1
            while i < n and "</details>" not in lines[i]:
                block.append(lines[i])
                i += 1
            if i < n:
                block.append(lines[i])
                i += 1
            _add("selfcheck", "\n".join(block), "", skip=True)
            continue
        if s.startswith("#"):                            # 헤딩
            htext = re.sub(r"^#{1,6}\s*", "", s)
            htext = re.sub(r"\s*\{#[^}]*\}\s*$", "", htext)
            htext = _EMOJI.sub("", htext).strip()
            if "출처" in htext:                           # 출처 헤딩 → 이후 전부 source/skip
                _add("source", "\n".join(lines[i:]), "", skip=True)
                break
            if "자가 점검" in htext or "자가점검" in htext:
                _add("selfcheck", s, "", skip=True)
                in_selfcheck = True
                i += 1
                continue
            if in_selfcheck:
                _add("selfcheck", s, "", skip=True)
                i += 1
                continue
            _add("heading", s, _clean_inline(htext))
            i += 1
            continue
        if s.startswith("|"):                            # 표 블록
            tbl = []
            while i < n and lines[i].strip().startswith("|"):
                tbl.append(lines[i].strip())
                i += 1
            _add("table", "\n".join(tbl), "",
                 audio_summary=None, issues=["table-needs-summary"])
            continue
        # 문단(연속 비빈 줄). 자가점검 구간이면 skip 본문.
        para = []
        while (i < n and lines[i].strip()
               and not lines[i].strip().startswith(("#", "|", "```", "<details"))):
            para.append(_strip_list_markers(lines[i].strip()))
            i += 1
        excerpt = " ".join(para)
        if in_selfcheck:
            _add("selfcheck", excerpt, "", skip=True)
            continue
        script = _clean_inline(excerpt)
        if script:
            _add("paragraph", excerpt, script)
    return segs
```

- [ ] **Step 4: 통과 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK`.

- [ ] **Step 5: 커밋**

```bash
git branch --show-current      # feat/content-review-pipeline 확인 (§5)
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): segment 파서 + 인라인 정리 헬퍼 추출 (검수 파이프라인 Task 1)"
```

---

## Task 2: 약어 발음사전 (lexicon.json + apply_lexicon)

발음사전 파일과 텍스트 치환 함수를 추가한다. 첫 등장/이후 구분, 단어 경계 매칭, 미등록 토큰 검출.

**Files:**
- Create: `flutter_app/tool/lexicon.json`
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`load_lexicon`·`apply_lexicon` 추가, `_self_test` 확장)

**Interfaces:**
- Consumes: 없음(독립).
- Produces:
  - `load_lexicon(path: Path | None) -> dict` — lexicon.json 로드. `None`이면 도구 옆 `lexicon.json`. 반환은 `entries` dict(`{"AWS": {"say": "..."}, "AZ": {"firstSay": "...", "thenSay": "..."}}`).
  - `apply_lexicon(text: str, lexicon: dict, seen: set[str]) -> tuple[str, list[str]]` — text에 사전 치환 적용. `seen`은 이미 첫 등장한 항목 키 집합(호출 간 누적, firstSay/thenSay 판정). 반환: `(치환된 text, issues)`. issues는 미등록 영문 대문자 토큰 `"unmapped-token: EC2"` 목록.

- [ ] **Step 1: lexicon.json 생성**

```json
{
  "schemaVersion": 1,
  "entries": {
    "AWS": { "say": "에이더블유에스" },
    "CapEx": { "say": "자본 지출" },
    "OpEx": { "say": "운영 지출" },
    "CLF-C02": { "say": "씨엘에프 씨 공이" },
    "IT": { "say": "아이티" },
    "on-demand": { "say": "온디맨드" },
    "pay-as-you-go": { "say": "종량 과금" },
    "AZ": { "firstSay": "가용 영역", "thenSay": "에이제트" }
  }
}
```

- [ ] **Step 2: 실패 테스트 추가** — `_self_test()`에 추가:

```python
    # Task 2: 발음사전
    lex = {
        "AWS": {"say": "에이더블유에스"},
        "AZ": {"firstSay": "가용 영역", "thenSay": "에이제트"},
    }
    seen: set[str] = set()
    t1, i1 = apply_lexicon("AWS는 좋다", lex, seen)
    assert t1 == "에이더블유에스는 좋다", t1
    t2, _ = apply_lexicon("AZ 하나, AZ 둘", lex, seen)
    assert t2 == "가용 영역 하나, 에이제트 둘", t2          # 첫 등장/이후
    _, i3 = apply_lexicon("EC2 인스턴스", lex, seen)
    assert any("EC2" in x for x in i3), i3                   # 미등록 토큰 경고
    t4, _ = apply_lexicon("AWSomeness", lex, set())
    assert t4 == "AWSomeness", t4                            # 단어 경계(부분 매칭 금지)
    loaded = load_lexicon(None)
    assert "AWS" in loaded and loaded["AWS"]["say"], loaded   # 시드 로드
```

- [ ] **Step 3: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'apply_lexicon' is not defined`.

- [ ] **Step 4: 구현** — `parse_segments` 아래에 추가:

```python
def load_lexicon(path) -> dict:
    """발음사전 entries dict 로드. path=None이면 도구 옆 lexicon.json."""
    if path is None:
        path = Path(__file__).with_name("lexicon.json")
    else:
        path = Path(path)
    if not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("entries", {})


def apply_lexicon(text: str, lexicon: dict, seen: set) -> tuple[str, list[str]]:
    """사전 치환(첫 등장/이후, 단어 경계). 반환: (치환 text, 미등록 토큰 issues)."""
    issues: list[str] = []
    # 긴 키부터 치환(예: 'CLF-C02'가 'C'보다 먼저).
    for key in sorted(lexicon, key=len, reverse=True):
        entry = lexicon[key]
        pattern = r"(?<![0-9A-Za-z])" + re.escape(key) + r"(?![0-9A-Za-z])"
        if not re.search(pattern, text):
            continue
        if "firstSay" in entry or "thenSay" in entry:
            first = entry.get("firstSay", entry.get("say", key))
            later = entry.get("thenSay", entry.get("say", key))

            def _repl(_m, _k=key, _first=first, _later=later):
                if _k in seen:
                    return _later
                seen.add(_k)
                return _first
            text = re.sub(pattern, _repl, text)
        else:
            text = re.sub(pattern, entry.get("say", key), text)
            seen.add(key)
    # 남은 영문 대문자 토큰(2자 이상) → 미등록 경고.
    for tok in sorted(set(re.findall(r"(?<![0-9A-Za-z])[A-Z][A-Z0-9]{1,}(?![0-9A-Za-z])", text))):
        issues.append(f"unmapped-token: {tok}")
    return text, issues
```

- [ ] **Step 5: 통과 확인 + 커밋**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test` → `self-test OK`

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py flutter_app/tool/lexicon.json
git commit -m "feat(audio): 약어 발음사전 + apply_lexicon (검수 파이프라인 Task 2)"
```

---

## Task 3: 표 → audioSummary 초벌

2열 표는 음성 요약을 자동 초벌 생성하고, 그 외는 사람 작성용으로 남긴다. `parse_segments`의 table 분기를 이 함수로 연결한다.

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`table_to_summary` 추가 + `parse_segments` table 분기 수정, `_self_test` 확장)

**Interfaces:**
- Consumes: `_clean_inline`(Task 1).
- Produces: `table_to_summary(table_lines: list[str]) -> tuple[str | None, list[str]]` — 2열 표면 `("{1열}은 {2열}입니다. …", ["table-summary-draft"])`, 그 외 `(None, ["table-needs-summary"])`.

- [ ] **Step 1: 실패 테스트 추가** — `_self_test()`에 추가:

```python
    # Task 3: 표 audioSummary
    s2, is2 = table_to_summary(["| 용어 | 설명 |", "| --- | --- |", "| 온프레미스 | 직접 운영 |"])
    assert s2 == "온프레미스은 직접 운영입니다." and is2 == ["table-summary-draft"], (s2, is2)
    s3, is3 = table_to_summary(["| A | B | C |", "| - | - | - |", "| 1 | 2 | 3 |"])
    assert s3 is None and is3 == ["table-needs-summary"], (s3, is3)
    segs2 = parse_segments("| 용어 | 설명 |\n| --- | --- |\n| 가 | 나 |\n")
    t = [g for g in segs2 if g["kind"] == "table"][0]
    assert t["audioSummary"] == "가은 나입니다." and t["issues"] == ["table-summary-draft"], t
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'table_to_summary' is not defined`.

- [ ] **Step 3: 구현** — `apply_lexicon` 아래에 추가:

```python
def table_to_summary(table_lines: list[str]) -> tuple:
    """마크다운 표 → (audioSummary, issues). 2열만 초벌 생성, 그 외 None."""
    rows = []
    for ln in table_lines:
        cells = [c.strip() for c in ln.strip().strip("|").split("|")]
        if cells and all(re.fullmatch(r":?-{3,}:?", c or "x") for c in cells):
            continue  # 구분행(|---|---|)
        rows.append(cells)
    if len(rows) < 2:
        return None, ["table-needs-summary"]
    if len(rows[0]) != 2:                       # 헤더 폭으로 열 수 판정
        return None, ["table-needs-summary"]
    parts = []
    for r in rows[1:]:                          # 헤더 제외 본문
        if len(r) >= 2 and r[0] and r[1]:
            parts.append(f"{_clean_inline(r[0])}은 {_clean_inline(r[1])}입니다.")
    if not parts:
        return None, ["table-needs-summary"]
    return " ".join(parts), ["table-summary-draft"]
```

그리고 `parse_segments`의 table 분기를 수정한다. 기존:

```python
            _add("table", "\n".join(tbl), "",
                 audio_summary=None, issues=["table-needs-summary"])
```

를 다음으로 교체:

```python
            summary, tissues = table_to_summary(tbl)
            _add("table", "\n".join(tbl), "",
                 audio_summary=summary, issues=tissues)
```

- [ ] **Step 4: 통과 확인 + 커밋**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test` → `self-test OK`

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): 2열 표 audioSummary 초벌 (검수 파이프라인 Task 3)"
```

---

## Task 4: script.json 조립 + generate 서브커맨드

segment·발음사전·표 요약을 합쳐 `script.json`을 만들고, 청취 검수표 템플릿도 생성한다.

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`build_script_json`·`review_checklist_md`·`run_generate` 추가, `_self_test` 확장)

**Interfaces:**
- Consumes: `parse_segments`(T1), `apply_lexicon`/`load_lexicon`(T2), `_utc_now`/`write_json`/`_asset_path`(기존).
- Produces:
  - `build_script_json(md: str, *, doc_id: str, source_asset: str, lexicon: dict) -> dict` — schemaVersion 2 script.json dict.
  - `review_checklist_md(doc_id: str) -> str`.
  - `run_generate(args) -> None` — `args.md`, `args.out_dir`, `args.doc_id`, `args.lexicon` 사용. `out_dir/script.json`·`out_dir/review_checklist.md` 생성.

- [ ] **Step 1: 실패 테스트 추가** — `_self_test()`에 추가:

```python
    # Task 4: build_script_json
    sj = build_script_json("# 제목\n\n본문입니다.\n", doc_id="clf-t1-1",
                           source_asset="assets/content/clf/t1-1.md", lexicon={})
    assert sj["schemaVersion"] == 2 and sj["docId"] == "clf-t1-1", sj
    assert sj["reviewStatus"] == "needs_human_review", sj
    assert len(sj["sourceHash"]) == 64 and len(sj["segments"]) >= 2, sj
    assert sj["segments"][0]["kind"] == "heading", sj["segments"][0]
    # 발음사전 적용이 scriptText에 반영
    sj2 = build_script_json("본문 AWS 설명.\n", doc_id="d",
                            source_asset="a", lexicon={"AWS": {"say": "에이더블유에스"}})
    assert any("에이더블유에스" in s["scriptText"] for s in sj2["segments"]), sj2
    # run_generate가 파일 2개 생성
    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        md_p = root / "t1-1.md"; md_p.write_text("# 제목\n\n본문.\n", encoding="utf-8")
        out_d = root / "clf-t1-1"
        gen_args = argparse.Namespace(md=md_p, out_dir=out_d, doc_id="clf-t1-1", lexicon=None)
        run_generate(gen_args)
        assert (out_d / "script.json").exists(), "script.json 미생성"
        assert (out_d / "review_checklist.md").exists(), "검수표 미생성"
        loaded = json.loads((out_d / "script.json").read_text(encoding="utf-8"))
        assert loaded["reviewStatus"] == "needs_human_review", loaded
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'build_script_json' is not defined`.

- [ ] **Step 3: 구현** — `table_to_summary` 아래에 추가:

```python
def build_script_json(md: str, *, doc_id: str, source_asset: str,
                      lexicon: dict) -> dict:
    """parse_segments + 발음사전 치환 + (표는 audioSummary 치환) → schemaVersion 2 dict."""
    segs = parse_segments(md)
    seen: set = set()
    for seg in segs:
        if seg["scriptText"]:
            seg["scriptText"], li = apply_lexicon(seg["scriptText"], lexicon, seen)
            seg["issues"] = list(dict.fromkeys(seg["issues"] + li))
        if seg.get("audioSummary"):
            seg["audioSummary"], li = apply_lexicon(seg["audioSummary"], lexicon, seen)
            seg["issues"] = list(dict.fromkeys(seg["issues"] + li))
    lex_hash = hashlib.sha256(
        json.dumps(lexicon, ensure_ascii=False, sort_keys=True).encode("utf-8")
    ).hexdigest()[:12]
    return {
        "schemaVersion": 2,
        "docId": doc_id,
        "sourceAsset": source_asset,
        "sourceHash": hashlib.sha256(md.encode("utf-8")).hexdigest(),
        "lexiconVersion": lex_hash,
        "generatedAt": _utc_now(),
        "reviewStatus": "needs_human_review",
        "segments": segs,
    }


def review_checklist_md(doc_id: str) -> str:
    """청취 검수표 템플릿(사람이 작성)."""
    return (
        f"# 청취 검수표 — {doc_id}\n\n"
        "- [ ] 표 핵심 정보가 음성에 포함됐다.\n"
        "- [ ] 약어 발음이 자연스럽다.\n"
        "- [ ] 출처 URL을 읽지 않는다.\n"
        "- [ ] 자가 점검 음성 흐름이 자연스럽다.\n"
        "- [ ] 첫 20초가 헤더 낭독이 아니다.\n"
        "- [ ] 청크 경계 끊김·메타 재해석이 없다.\n"
        "- [ ] 사실 정확성: 고유명사·서비스명·수치가 원문과 일치한다.\n\n"
        "reviewer: ____________   날짜: ____________\n\n"
        "승인 시 script.json·audio_meta.json의 reviewStatus를 approved로 수동 변경한다.\n"
    )


def run_generate(args) -> None:
    md = args.md.read_text(encoding="utf-8")
    doc_id = args.doc_id or args.out_dir.name
    script = build_script_json(
        md, doc_id=doc_id, source_asset=_asset_path(args.md),
        lexicon=load_lexicon(args.lexicon))
    write_json(args.out_dir / "script.json", script)
    (args.out_dir).mkdir(parents=True, exist_ok=True)
    (args.out_dir / "review_checklist.md").write_text(
        review_checklist_md(doc_id), encoding="utf-8")
    n_issues = sum(len(s["issues"]) for s in script["segments"])
    print(f"[generate] {len(script['segments'])} segments, "
          f"{n_issues} issues → {args.out_dir / 'script.json'}", file=sys.stderr)
```

- [ ] **Step 4: 통과 확인 + 커밋**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test` → `self-test OK`

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): script.json 조립 + generate 서브커맨드 (검수 파이프라인 Task 4)"
```

---

## Task 5: synthesize 서브커맨드 (script.json → mp3)

`script.json`의 보정된 텍스트만으로 합성한다(md 재파싱 금지). 합성용 평문 추출을 순수 함수로 분리해 self-test로 검증한다(Polly 호출은 분리).

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`script_to_speech`·`run_synthesize` 추가, `_self_test` 확장)

**Interfaces:**
- Consumes: `chunk_text`/`synthesize_polly`/`build_audio_meta`/`write_json`(기존), script.json(T4).
- Produces:
  - `script_to_speech(script: dict) -> str` — skip 제외, table은 audioSummary, 그 외 scriptText를 줄바꿈으로 연결.
  - `run_synthesize(args) -> None` — `args.script`(script.json 경로), `args.out`(mp3), Polly 인자. audio_meta의 `source.sha256`은 script.json의 `sourceHash`를 그대로 쓴다(md 재파싱 금지).

- [ ] **Step 1: 실패 테스트 추가** — `_self_test()`에 추가:

```python
    # Task 5: script_to_speech (skip 제외, table=audioSummary, md 무시)
    sp = script_to_speech({"segments": [
        {"kind": "heading", "scriptText": "제목", "skip": False, "audioSummary": None},
        {"kind": "selfcheck", "scriptText": "비밀", "skip": True, "audioSummary": None},
        {"kind": "table", "scriptText": "", "audioSummary": "요약입니다.", "skip": False},
        {"kind": "source", "scriptText": "url", "skip": True, "audioSummary": None},
    ]})
    assert "제목" in sp and "요약입니다." in sp, sp
    assert "비밀" not in sp and "url" not in sp, sp
    assert sp.count("\n") == 1, sp
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'script_to_speech' is not defined`.

- [ ] **Step 3: 구현** — `run_generate` 아래에 추가:

```python
def script_to_speech(script: dict) -> str:
    """script.json → 합성용 평문. skip 제외, table은 audioSummary, 그 외 scriptText."""
    parts: list[str] = []
    for s in script["segments"]:
        if s.get("skip"):
            continue
        if s["kind"] == "table":
            if s.get("audioSummary"):
                parts.append(s["audioSummary"])
        elif s.get("scriptText"):
            parts.append(s["scriptText"])
    return "\n".join(parts)


def run_synthesize(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    speech = script_to_speech(script)
    if not speech.strip():
        sys.exit("script.json에 합성할 scriptText가 없습니다.")
    max_chars = args.max_chars or 2900
    chunks = chunk_text(speech, max_chars)
    print(f"[synthesize] {len(speech)}자 → {len(chunks)}청크", file=sys.stderr)
    synthesize_polly(chunks, args.out, args.voice, args.polly_engine, args.region)
    id3 = _id3_count(args.out)
    print(f"[ID3] {id3}개 — {'OK' if id3 <= 1 else '다중(단일 요청 권장)'}", file=sys.stderr)
    meta = build_audio_meta(
        md_path=args.script, audio_path=args.out, doc_id=script["docId"],
        speech=speech, chunks=chunks, issues=[], args=args, mode="synthesized")
    # SSOT: md를 재파싱하지 않으므로 source는 script.json 기록을 그대로 옮긴다.
    meta["source"] = {"asset": script.get("sourceAsset"), "sha256": script.get("sourceHash")}
    meta["script"]["reviewStatus"] = script.get("reviewStatus", "needs_human_review")
    write_json(args.out.with_name("audio_meta.json"), meta)
    print(f"[완료] {args.out}", file=sys.stderr)
```

> 주: `build_audio_meta`는 `md_path`로 sha256을 계산하지만, 그 값을 즉시 script.json의 `sourceHash`로 덮어써 SSOT 불변식을 지킨다(md를 의미 해석하지 않음 — 경로만 전달). 이는 Task 6의 stale 게이트와 일관된다.

- [ ] **Step 4: 통과 확인 + 커밋**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test` → `self-test OK`

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): synthesize 서브커맨드 (script.json→mp3, SSOT) (검수 파이프라인 Task 5)"
```

---

## Task 6: gate 서브커맨드 (정적 검증)

`script.json`(hard/soft)과 `audio_meta.json`(id3·contentType·stale)을 검사한다. hard가 있으면 비영(非0) 종료한다.

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`gate_script`·`gate_audio_meta`·`run_gate` 추가, `_self_test` 확장)

**Interfaces:**
- Consumes: script.json(T4), audio_meta(T5).
- Produces:
  - `gate_script(script: dict) -> tuple[list[str], list[str]]` — `(hard, soft)` 메시지 목록.
  - `gate_audio_meta(meta: dict, current_md_sha: str | None) -> list[str]` — hard 목록.
  - `run_gate(args) -> None` — `args.script`, `args.md`(옵션, stale 검사), `args.audio_meta`(옵션). hard 있으면 `sys.exit`.

- [ ] **Step 1: 실패 테스트 추가** — `_self_test()`에 추가:

```python
    # Task 6: 정적 게이트
    hard, soft = gate_script({"segments": [
        {"id": "s0", "kind": "paragraph", "scriptText": "정상 문장.", "skip": False, "issues": []},
        {"id": "s1", "kind": "paragraph", "scriptText": "보기 https://x", "skip": False, "issues": []},
        {"id": "s2", "kind": "table", "scriptText": "", "audioSummary": None, "skip": False, "issues": []},
        {"id": "s3", "kind": "source", "scriptText": "x", "skip": False, "issues": []},
        {"id": "s4", "kind": "paragraph", "scriptText": "토큰", "skip": False,
         "issues": ["unmapped-token: EC2"]},
    ]})
    assert any("URL" in x for x in hard) and any("table" in x for x in hard), hard
    assert any("source" in x for x in hard), hard
    assert any("EC2" in x for x in soft) and not any("EC2" in x for x in hard), (hard, soft)
    ok_meta = {"audio": {"contentType": "audio/mpeg",
                         "containerChecks": {"id3Count": 1}}, "source": {"sha256": "abc"}}
    assert gate_audio_meta(ok_meta, "abc") == [], gate_audio_meta(ok_meta, "abc")
    assert any("stale" in x for x in gate_audio_meta(ok_meta, "zzz")), "stale 미검출"
    bad_meta = {"audio": {"contentType": "text/plain",
                          "containerChecks": {"id3Count": 3}}, "source": {"sha256": "abc"}}
    assert len(gate_audio_meta(bad_meta, None)) == 2, gate_audio_meta(bad_meta, None)
```

- [ ] **Step 2: 실패 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `NameError: name 'gate_script' is not defined`.

- [ ] **Step 3: 구현** — `run_synthesize` 아래에 추가:

```python
def gate_script(script: dict) -> tuple:
    """script.json 정적 검사. 반환 (hard, soft) 메시지 목록."""
    hard: list[str] = []
    soft: list[str] = []
    for seg in script["segments"]:
        sid = seg.get("id", "?")
        txt = (seg.get("scriptText") or "") + " " + (seg.get("audioSummary") or "")
        if re.search(r"https?://", txt):
            hard.append(f"{sid}: URL 잔존")
        for sym in ("→", "≠", "↓", "§", "|"):
            if sym in txt:
                hard.append(f"{sid}: 기호 {sym}")
        if "정답 보기" in txt:
            hard.append(f"{sid}: 정답 보기 잔존")
        if re.search(r"\]\(", txt):
            hard.append(f"{sid}: 마크다운 링크 잔존")
        if seg.get("kind") == "table" and not seg.get("skip") and not seg.get("audioSummary"):
            hard.append(f"{sid}: table에 audioSummary 또는 skip 필요")
        if seg.get("kind") == "source" and not seg.get("skip"):
            hard.append(f"{sid}: source는 skip=true 필요")
        for iss in seg.get("issues", []):
            if str(iss).startswith("unmapped-token"):
                soft.append(f"{sid}: {iss}")
    return hard, soft


def gate_audio_meta(meta: dict, current_md_sha) -> list:
    """audio_meta.json 검사(hard만)."""
    hard: list[str] = []
    audio = meta.get("audio", {})
    checks = audio.get("containerChecks", {})
    if audio.get("contentType") != "audio/mpeg":
        hard.append(f"contentType={audio.get('contentType')} (audio/mpeg 필요)")
    if checks.get("id3Count") != 1:
        hard.append(f"id3Count={checks.get('id3Count')} (1 필요)")
    if current_md_sha and meta.get("source", {}).get("sha256") != current_md_sha:
        hard.append("stale: source.sha256 != 현재 md")
    return hard


def run_gate(args) -> None:
    script = json.loads(args.script.read_text(encoding="utf-8"))
    hard, soft = gate_script(script)
    cur_sha = None
    if args.md and args.md.exists():
        cur_sha = hashlib.sha256(
            args.md.read_text(encoding="utf-8").encode("utf-8")).hexdigest()
        if script.get("sourceHash") != cur_sha:
            hard.append("stale: script.sourceHash != 현재 md")
    if args.audio_meta and args.audio_meta.exists():
        meta = json.loads(args.audio_meta.read_text(encoding="utf-8"))
        hard += gate_audio_meta(meta, cur_sha)
    for h in hard:
        print(f"  HARD {h}", file=sys.stderr)
    for s in soft:
        print(f"  soft {s}", file=sys.stderr)
    if hard:
        sys.exit(f"[gate] FAIL — hard {len(hard)}개")
    print(f"[gate] PASS (soft {len(soft)}개)", file=sys.stderr)
```

- [ ] **Step 4: 통과 확인 + 커밋**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test` → `self-test OK`

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): gate 서브커맨드 (정적 검증 hard/soft) (검수 파이프라인 Task 6)"
```

---

## Task 7: CLI 서브커맨드 재구성 + 통합 스모크

`main()`을 `generate`/`synthesize`/`gate` 서브커맨드 + `--self-test`로 재구성한다. 기존 정제 함수(`markdown_to_speech_text` 등)와 `_self_test`는 보존한다(레거시 직접 합성 경로는 제거하고 파이프라인으로 대체).

**Files:**
- Modify: `flutter_app/tool/gen_lecture_audio.py` (`main` 교체)

**Interfaces:**
- Consumes: `run_generate`(T4)·`run_synthesize`(T5)·`run_gate`(T6)·`_self_test`.

- [ ] **Step 1: `main()` 교체** — 기존 `def main(): …` 전체를 다음으로 교체:

```python
def main() -> None:
    ap = argparse.ArgumentParser(
        description="학습문서 오디오 검수 파이프라인 (generate/synthesize/gate)")
    ap.add_argument("--self-test", action="store_true")
    sub = ap.add_subparsers(dest="cmd")

    g = sub.add_parser("generate", help="md → script.json + review_checklist.md")
    g.add_argument("--md", type=Path, required=True)
    g.add_argument("--out-dir", type=Path, required=True)
    g.add_argument("--doc-id")
    g.add_argument("--lexicon", type=Path)

    sy = sub.add_parser("synthesize", help="script.json → mp3 + audio_meta.json")
    sy.add_argument("--script", type=Path, required=True)
    sy.add_argument("--out", type=Path, required=True)
    sy.add_argument("--engine", default="polly")
    sy.add_argument("--voice", default="Seoyeon")
    sy.add_argument("--polly-engine", default="neural",
                    choices=["standard", "neural", "generative"])
    sy.add_argument("--region", default="ap-northeast-2")
    sy.add_argument("--max-chars", type=int, default=0)

    ga = sub.add_parser("gate", help="script.json/audio_meta 정적 검증")
    ga.add_argument("--script", type=Path, required=True)
    ga.add_argument("--md", type=Path)
    ga.add_argument("--audio-meta", type=Path)

    args = ap.parse_args()
    if args.self_test:
        _self_test()
        return
    if args.cmd == "generate":
        run_generate(args)
    elif args.cmd == "synthesize":
        run_synthesize(args)
    elif args.cmd == "gate":
        run_gate(args)
    else:
        ap.error("서브커맨드(generate/synthesize/gate) 또는 --self-test 가 필요합니다.")
```

- [ ] **Step 2: self-test 회귀 확인**

Run: `cd flutter_app; py tool/gen_lecture_audio.py --self-test`
Expected: `self-test OK` (기존 정제·게이트 + 신규 T1~T6 전부 통과).

- [ ] **Step 3: generate 통합 스모크 (실제 문서)**

Run:
```powershell
cd D:\workspace\awc-docs\flutter_app
py tool/gen_lecture_audio.py generate --md assets/content/clf/t1-1.md --out-dir $env:TEMP/cr-smoke --doc-id clf-t1-1
```
Expected: `[generate] N segments, … → …/script.json`. `$env:TEMP/cr-smoke/script.json`·`review_checklist.md` 생성.

- [ ] **Step 4: gate 통합 스모크**

Run:
```powershell
py tool/gen_lecture_audio.py gate --script $env:TEMP/cr-smoke/script.json --md assets/content/clf/t1-1.md
```
Expected: `[gate] PASS …` 또는 hard 이슈가 있으면 그 목록(있다면 정제/표/발음 보강이 필요하다는 실제 신호 — Task 1~3 회귀 점검).

- [ ] **Step 5: 커밋**

```bash
git branch --show-current
git add flutter_app/tool/gen_lecture_audio.py
git commit -m "feat(audio): CLI를 generate/synthesize/gate 서브커맨드로 재구성 (검수 파이프라인 Task 7)"
```

---

## 실행 후 (사람 영역 — 이 계획 밖)

1. `clf-t1-1` 실제 generate → `script.json` 사람 보정(scriptText 다듬기, table audioSummary 확인, unmapped 토큰 처리).
2. 보정된 script.json으로 `synthesize`(AWS 자격증명 필요) → mp3.
3. `gate` 통과 확인 → 청취 검수표 작성 → `reviewStatus=approved` 수동 변경.
4. approved 후에만 mp3·script.json repo 포함 + `pubspec.yaml` 등록 검토(별도 PR).

