"""Builds the iOS launch screen assets (option A: the heavy S and clay dot, centred on almond).

Outlines the real "S" from Bricolage Grotesque at weight 800, adds the clay dot exactly as the
wordmark CSS places it (0.2em wide, 0.05em gap, sitting on the baseline), and writes:
  launch-mark.svg / launch-mark-dark.svg           vector masters
  Assets.xcassets/LaunchMark.imageset/            PNG @1x @2x @3x, light and dark
  Assets.xcassets/LaunchBackground.colorset/       almond, dark #211B17
Run: python design/launch/make_launch.py   (needs fonttools, brotli, and Chrome for the PNGs)
"""
import json, os, subprocess, pathlib
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
FONT = ROOT / "secondstrong-web/src/app/fonts/BricolageGrotesque-var.woff2"
CHROME = os.environ.get("CHROME", r"C:\Program Files\Google\Chrome\Application\chrome.exe")
INK, INK_DARK, CLAY = "#3B322C", "#F1E9DF", "#C08E82"
ALMOND, DARK_BG = "#EDE3D6", "#211B17"
POINTS = 104  # the mark is drawn at a 104pt font size on the launch screen

font = TTFont(str(FONT))
axes = {a.axisTag: a for a in font["fvar"].axes}
loc = {"wght": 800}
if "opsz" in axes: loc["opsz"] = axes["opsz"].maxValue
if "wdth" in axes: loc["wdth"] = axes["wdth"].defaultValue
inst = instantiateVariableFont(font, loc)
upm = inst["head"].unitsPerEm
gs = inst.getGlyphSet()
gname = inst.getBestCmap()[ord("S")]
glyph = gs[gname]

pen = SVGPathPen(gs); glyph.draw(pen); spath = pen.getCommands()
bp = BoundsPen(gs); glyph.draw(bp); xmin, ymin, xmax, ymax = bp.bounds
adv = glyph.width

# dot: 0.2em wide, 0.05em after the glyph's advance (letter-spacing -0.05em pulls it back in), resting on the baseline
dot_d = 0.2 * upm
dot_x = adv + 0.03 * upm  # advance (the -0.05em tracking and +0.05em margin cancel), plus the small optical gap the icon shows
dot_cx, dot_cy = dot_x + dot_d / 2, dot_d / 2

pad = 0.02 * upm
left, right = xmin - pad, dot_x + dot_d + pad
top, bottom = ymax + pad, min(ymin, 0) - pad
vw, vh = right - left, top - bottom

def svg(fill):
    # font units are y-up; flip into SVG space
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {vw:.1f} {vh:.1f}" width="{vw / upm * POINTS:.2f}" height="{vh / upm * POINTS:.2f}">
  <g transform="translate({-left:.1f} {top:.1f}) scale(1 -1)">
    <path d="{spath}" fill="{fill}"/>
    <circle cx="{dot_cx:.1f}" cy="{dot_cy:.1f}" r="{dot_d / 2:.1f}" fill="{CLAY}"/>
  </g>
</svg>
'''

(HERE / "launch-mark.svg").write_text(svg(INK), encoding="utf-8")
(HERE / "launch-mark-dark.svg").write_text(svg(INK_DARK), encoding="utf-8")
w_pt, h_pt = vw / upm * POINTS, vh / upm * POINTS
print(f"mark is {w_pt:.1f} x {h_pt:.1f} pt")

# PNGs via headless Chrome, transparent background
xc = HERE / "Assets.xcassets"
img = xc / "LaunchMark.imageset"; img.mkdir(parents=True, exist_ok=True)
images = []
for variant, src in (("", "launch-mark.svg"), ("-dark", "launch-mark-dark.svg")):
    for scale in (1, 2, 3):
        name = f"launch-mark{variant}{'' if scale == 1 else f'@{scale}x'}.png"
        w, h = round(w_pt * scale), round(h_pt * scale)
        page = HERE / "_render.html"
        page.write_text(f'<html><body style="margin:0;background:transparent"><img src="{(HERE / src).as_uri()}" style="width:{w}px;height:{h}px;display:block"></body></html>', encoding="utf-8")
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--window-size={w},{h}", "--default-background-color=00000000",
                        f"--screenshot={img / name}", page.as_uri()], check=True, capture_output=True)
        entry = {"idiom": "universal", "filename": name, "scale": f"{scale}x"}
        if variant: entry["appearances"] = [{"appearance": "luminosity", "value": "dark"}]
        images.append(entry)
(HERE / "_render.html").unlink()
(img / "Contents.json").write_text(json.dumps({"images": images, "info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")

def comps(hexv):
    h = hexv.lstrip("#"); return {"red": f"0x{h[0:2]}", "green": f"0x{h[2:4]}", "blue": f"0x{h[4:6]}", "alpha": "1.000"}
col = xc / "LaunchBackground.colorset"; col.mkdir(parents=True, exist_ok=True)
(col / "Contents.json").write_text(json.dumps({"colors": [
    {"idiom": "universal", "color": {"color-space": "srgb", "components": comps(ALMOND)}},
    {"idiom": "universal", "appearances": [{"appearance": "luminosity", "value": "dark"}], "color": {"color-space": "srgb", "components": comps(DARK_BG)}}],
    "info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")
(xc / "Contents.json").write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2), encoding="utf-8")
print("wrote", sorted(p.name for p in img.iterdir()))
