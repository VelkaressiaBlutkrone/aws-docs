# -*- coding: utf-8 -*-
"""브랜드 아이콘 생성기 (A6-3, 2026-11-19).

`flutter_app/lib/pages/home/home_header.dart` 의 헤더 마크를 그대로 확대한다 —
**26×26 · 반지름 7 · accent(#0E8175) 배경 · 흰 'A' Pretendard w800 · 글자 14px**.
앱 안에서 보는 마크와 런처에서 보는 아이콘이 같아야 한다(사용자 승인 2026-11-19).

왜 생성기를 커밋하나: 재현할 수 없는 바이너리를 레포에 두지 않기 위해서다. 색이나 비율을
바꿀 때 손으로 다시 그리지 않아도 된다. 가드가 이 파일의 존재를 단정한다.

필요: Pillow · fontTools · brotli (woff2 디코드).
사용:  py tool/make_app_icon.py          # 생성
       py tool/make_app_icon.py --check  # 쓰지 않고 치수만 출력
"""
import pathlib
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

ROOT = pathlib.Path(__file__).resolve().parent.parent
APP = ROOT / "flutter_app"
RES = APP / "android/app/src/main/res"
WOFF2 = APP / "assets/fonts/PretendardVariable.woff2"

# 헤더 마크의 비율(home_header.dart 실측) — 숫자를 바꾸려면 거기와 함께 바꾼다.
MARK_BOX = 26
MARK_RADIUS = 7 / MARK_BOX        # 0.269
MARK_GLYPH = 14 / MARK_BOX        # 0.538
ACCENT = (0x0E, 0x81, 0x75)       # app_theme.dart: accent: Color(0xFF0E8175)
ON_ACCENT = (0xFF, 0xFF, 0xFF)

SS = 4  # 슈퍼샘플링 배수 — 작은 크기에서 글자 가장자리가 깨지지 않게 한다.

# 런처 아이콘(레거시) 밀도별 px
MIPMAP = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
# 적응형 foreground 는 108dp 캔버스(= 레거시의 2.25배)이고, 마스크가 중앙 72dp(66.7%)만
# 남긴다. 그래서 글자는 **그 72dp 를 헤더의 컨테이너로 보고** 비율을 적용한다.
ADAPTIVE_SCALE = 108 / 48
SAFE_RATIO = 72 / 108


def instanced_font() -> pathlib.Path:
    """Pretendard Variable(woff2) 을 wght=800 으로 인스턴스화해 TTF 로 뽑는다.

    PIL 은 woff2 를 읽지 못하고, 가변 축을 지정할 수도 없다.
    """
    font = TTFont(str(WOFF2))  # woff2 디코드는 brotli 가 한다
    static = instancer.instantiateVariableFont(font, {"wght": 800})
    static.flavor = None
    out = pathlib.Path(tempfile.gettempdir()) / "PretendardW800.ttf"
    static.save(str(out))
    return out


def draw_mark(size: int, ttf: pathlib.Path, *, glyph_ratio: float,
              radius_ratio: float | None, transparent_bg: bool) -> Image.Image:
    """한 장을 그린다. radius_ratio 가 None 이면 배경을 칠하지 않는다(적응형 foreground)."""
    s = size * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if not transparent_bg:
        if radius_ratio is None:
            d.rectangle([0, 0, s - 1, s - 1], fill=ACCENT + (255,))
        else:
            d.rounded_rectangle([0, 0, s - 1, s - 1],
                                radius=s * radius_ratio, fill=ACCENT + (255,))
    font = ImageFont.truetype(str(ttf), int(s * glyph_ratio))
    # 'A' 의 **잉크 박스**를 기준으로 중앙에 둔다. anchor='mm' 은 글꼴의 세로 중심을
    # 쓰기 때문에 대문자 하나만 그릴 때 아래로 치우쳐 보인다.
    box = d.textbbox((0, 0), "A", font=font)
    d.text(((s - (box[2] - box[0])) / 2 - box[0],
            (s - (box[3] - box[1])) / 2 - box[1]),
           "A", font=font, fill=ON_ACCENT + (255,))
    return img.resize((size, size), Image.LANCZOS)


def save(img: Image.Image, path: pathlib.Path, *, rgb: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    (img.convert("RGB") if rgb else img).save(path, "PNG", optimize=True)


def main() -> None:
    check = "--check" in sys.argv
    ttf = instanced_font()
    made = []

    for density, px in MIPMAP.items():
        # 레거시 런처 아이콘 — 헤더 마크를 그대로 확대한다.
        legacy = draw_mark(px, ttf, glyph_ratio=MARK_GLYPH,
                           radius_ratio=MARK_RADIUS, transparent_bg=False)
        # 적응형 foreground — 배경은 색 리소스가 맡고, 글자만 그린다.
        fg_px = round(px * ADAPTIVE_SCALE)
        fg = draw_mark(fg_px, ttf, glyph_ratio=MARK_GLYPH * SAFE_RATIO,
                       radius_ratio=None, transparent_bg=True)
        if not check:
            save(legacy, RES / ("mipmap-%s/ic_launcher.png" % density))
            save(fg, RES / ("mipmap-%s/ic_launcher_foreground.png" % density))
        made += [("mipmap-%s/ic_launcher.png" % density, px),
                 ("mipmap-%s/ic_launcher_foreground.png" % density, fg_px)]

    # 웹 — 지금 `web/icons/*` 도 Flutter 기본이라 같은 자산으로 맞춘다.
    web = APP / "web"
    for px in (192, 512):
        plain = draw_mark(px, ttf, glyph_ratio=MARK_GLYPH,
                          radius_ratio=MARK_RADIUS, transparent_bg=False)
        # maskable 은 바깥 20% 가 잘릴 수 있으므로 배경을 꽉 채우고 글자를 안쪽에 둔다.
        maskable = draw_mark(px, ttf, glyph_ratio=MARK_GLYPH * 0.8,
                             radius_ratio=None, transparent_bg=False)
        if not check:
            save(plain, web / ("icons/Icon-%d.png" % px), rgb=True)
            save(maskable, web / ("icons/Icon-maskable-%d.png" % px))
        made += [("web/icons/Icon-%d.png" % px, px),
                 ("web/icons/Icon-maskable-%d.png" % px, px)]

    fav = draw_mark(32, ttf, glyph_ratio=MARK_GLYPH,
                    radius_ratio=MARK_RADIUS, transparent_bg=False)
    if not check:
        save(fav, web / "favicon.png")
    made.append(("web/favicon.png", 32))

    sys.stdout.write("%s %d files\n" % ("CHECK" if check else "WROTE", len(made)))
    for name, px in made:
        sys.stdout.write("  %-46s %dpx\n" % (name, px))


if __name__ == "__main__":
    main()
