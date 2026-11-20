# -*- coding: utf-8 -*-
"""공유 미리보기 이미지(og-image.png, 1200×630) 생성기 (2026-11-20).

2026-06-06 에 손으로 만든 `flutter_app/web/og-image.png` 는 생성기가 없었고, 이름을
「구름사다리」로 바꾸면서 **같은 배치·같은 문구**로 다시 그리도록 이 파일을 남긴다.
바뀐 것은 왼쪽 위 워드마크뿐이다 — 「구름」 본문색 + 「사다리」 accent(DESIGN.md).

필요: Pillow · fontTools · brotli.  사용: py tool/make_og_image.py
가드: flutter_app/test/brand_name_test.dart(생성기 존재 · 1200×630).
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from make_app_icon import (APP, ACCENT, MARK_GLYPH, MARK_RADIUS,  # noqa: E402
                           draw_mark, instanced_font, save)

OUT = APP / "web/og-image.png"
W, H, SS = 1200, 630, 2

BG = (0xFB, 0xFA, 0xF8)      # app_theme.dart 라이트 bg
TEXT = (0x1B, 0x24, 0x30)    # text
MUTED = (0x5C, 0x65, 0x73)   # textMuted
BORDER = (0xE7, 0xE4, 0xDD)  # border
MONO = APP / "assets/fonts/JetBrainsMono-Regular.ttf"

# 2026-06-06 판과 같은 문구(이름만 바뀌었다).
BADGE = "AWS 공식 시험 가이드 기준 · 한국어"
HEAD1 = "클라우드 자격증,"
HEAD2_ACCENT, HEAD2_REST = "이해", "하고 통과하기"
SUB = '덤프 암기가 아니라 "왜"를 가르치는 학습 문서와 검증된 모의고사. 12개 AWS 자격증을 한 곳에서.'
CODES = "CLF-C02 · SAA-C03 · DVA-C02 · SAP-C02 · SCS-C03 · ANS-C01"
URL = "velkaressiablutkrone.github.io/aws-docs"


def f(weight, px):
    return ImageFont.truetype(str(instanced_font(weight)), px * SS)


def wrap(d, text, font, width):
    """공백 단위로 줄을 나눈다(한국어 문장이 어절 가운데서 끊기지 않게)."""
    lines, cur = [], ""
    for word in text.split(" "):
        trial = word if not cur else cur + " " + word
        if d.textlength(trial, font=font) <= width:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    lines.append(cur)
    return lines


def main():
    s = lambda v: v * SS  # noqa: E731
    img = Image.new("RGB", (s(W), s(H)), BG)
    d = ImageDraw.Draw(img)
    left, right = s(80), s(W - 80)

    # 워드마크: A 마크 + 「구름」「사다리」
    mark = draw_mark(s(46), instanced_font(), glyph_ratio=MARK_GLYPH,
                     radius_ratio=MARK_RADIUS, transparent_bg=False)
    img.paste(mark, (left, s(72)), mark)
    name_font = f(800, 21)
    cy = s(72 + 23)
    x = left + s(46 + 15)
    for part, color in (("구름", TEXT), ("사다리", ACCENT)):
        d.text((x, cy), part, font=name_font, fill=color, anchor="lm")
        x += d.textlength(part, font=name_font)

    # 배지
    badge_font = f(600, 15)
    bw = d.textlength(BADGE, font=badge_font)
    top, bh = s(141), s(43)
    d.rounded_rectangle([left, top, left + bw + s(40), top + bh], radius=bh / 2,
                        fill=(0xFF, 0xFF, 0xFF), outline=BORDER, width=s(1))
    d.text((left + s(20), top + bh / 2), BADGE, font=badge_font, fill=MUTED, anchor="lm")

    # 헤드라인 두 줄
    head = f(800, 78)
    d.text((left, s(262)), HEAD1, font=head, fill=TEXT, anchor="ls")
    d.text((left, s(372)), HEAD2_ACCENT, font=head, fill=ACCENT, anchor="ls")
    d.text((left + d.textlength(HEAD2_ACCENT, font=head), s(372)), HEAD2_REST,
           font=head, fill=TEXT, anchor="ls")

    # 부제(어절 단위 줄바꿈)
    sub = f(400, 22)
    for i, line in enumerate(wrap(d, SUB, sub, s(1000))):
        d.text((left, s(434 + 36 * i)), line, font=sub, fill=MUTED, anchor="lm")

    # 구분선 + 하단 줄
    d.line([left, s(511), right, s(511)], fill=BORDER, width=s(1))
    d.text((left, s(548)), CODES, font=ImageFont.truetype(str(MONO), s(16)),
           fill=(0x8A, 0x92, 0x9D), anchor="lm")
    d.text((right, s(548)), URL, font=f(700, 16), fill=TEXT, anchor="rm")

    out = img.resize((W, H), Image.LANCZOS)
    save(out, OUT, rgb=True)
    sys.stdout.write("WROTE %s %dx%d\n" % (OUT.name, W, H))


if __name__ == "__main__":
    main()
