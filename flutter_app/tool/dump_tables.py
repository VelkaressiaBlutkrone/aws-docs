# -*- coding: utf-8 -*-
"""검수 보조(읽기 전용): 지정 문서의 audioSummary 미작성 3열+ 표(table-needs-summary)를
seg id와 함께 원문 그대로 출력한다. 이 출력을 보고 apply_audio_summary.py의 SUMMARIES에
음성 요약을 작성·추가한다.

사용: py tool/dump_tables.py t1-3 t1-4 ...
"""
import json
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
BASE = Path(__file__).resolve().parent.parent  # flutter_app/
CLF = BASE / "assets" / "audio" / "clf"

for t in sys.argv[1:]:
    sp = CLF / f"clf-{t}" / "script.json"
    if not sp.exists():
        print(f"[skip] clf-{t}: script.json 없음")
        continue
    d = json.loads(sp.read_text(encoding="utf-8"))
    for s in d["segments"]:
        if s["kind"] == "table" and "table-needs-summary" in s.get("issues", []):
            print(f"@@@ clf-{t} {s['id']}")
            print(s["sourceExcerpt"])
            print()
