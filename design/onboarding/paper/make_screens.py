"""Writes the paper onboarding as canvas artboards: six steps, light and dark. One ink line runs through each
screen (it underlines the question, rings the answer, draws on into the plan) over torn-paper art.
Usage: python make_screens.py <canvas project folder>"""
import json, os, sys

OUT = sys.argv[1]
B = lambda i: f"/_blob/{i}"
ART = {
    "welcome": {"night": B("4fe9561413ca4fcfb08033802f4818d5"), "day": B("c5caec4fdc4479da23589c426aa7e5dc")},
    "days": {"night": B("043d8d7a5bd61e0e825cf2297356f7dc"), "day": B("7216ba8ba2b393973afd412b222cf68a")},
    "plan": {"night": B("3ba978f262cc3feb19c9e0831e55ef11"), "day": B("d39120cfd63e4db9801ccb145d7140b7")},
}
ICON = {"peri": B("096e4725f8584045fefdcd3db44bca94"), "meno": B("15d387b9e50537572a862ae3ad4f62f1"), "post": B("4b448d43212d6dabed584da165d78994"),
        "surg": B("b79ec02cfa53281c6958b0f10e00f6bf"), "unsure": B("1ce3e0e0afbf09a8302c9e071193d13c"), "strong": B("7be6bd27bd3df32c4c4323e3195409cc"),
        "protein": B("ef1ae8b83bba47a72c83dd4887729391"), "energy": B("880f9b1fda74cfa4ecf4286ea8711959"), "sleep": B("f5872209850c59ee9ce84afb0a1e1291")}
COACH = {"pebble": B("b92fe924472532d13f786f92a3dba81b"), "fern": B("5da00f461b92f0821b40577fb3f1c185"), "wren": B("d661808ab1bc936c0847ea1d80997dc9"),
         "bramble": B("3f6823757afbc827611ebc5f756a4c13"), "luna": B("e90ba22e3da4377a25fe997a0d7f5c4b"), "otto": B("de9414dc0954f36f77b338a2898525c9"),
         "tilly": B("cf77064da7aef7ceb462672775474529"), "miso": B("1309336315d552c659e1a290537ebd13")}
MODES = {
    "day": dict(bg="#FBF8F4", ink="#3B322C", ink2="#5D534B", card="#F6F0E8", edge="rgba(59,50,44,.10)", line="#3B322C", accent="#A85A3C",
                pbg="#3B322C", pfg="#FBF8F4", ghost="rgba(59,50,44,.28)", chip="#F6F0E8", suffix="Light", label="light"),
    "night": dict(bg="#211B17", ink="#F1E9DF", ink2="#B8AA9D", card="#2A231F", edge="rgba(241,233,223,.12)", line="#EDE3D6", accent="#E09A78",
                  pbg="#F1E9DF", pfg="#211B17", ghost="rgba(241,233,223,.34)", chip="#2A231F", suffix="", label="dark"),
}
FONTS = ('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,500;'
         '12..96,600;12..96,700;12..96,800&amp;family=Gochi+Hand&amp;family=IBM+Plex+Mono:wght@500&amp;family=Newsreader:ital,opsz,wght@1,6..72,400&amp;display=swap">')
EM = "font-family: 'Newsreader', serif; font-style: italic; font-weight: 400; letter-spacing: -0.01em"


def page(m, title, body, path):
    line = (f'<svg width="390" height="844" viewBox="0 0 390 844" aria-hidden="true" style="position: absolute; left: 0; top: 0; pointer-events: none">'
            f'<path d="{path}" fill="none" stroke="{m["line"]}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/></svg>')
    return f'''<!doctype html>
<html lang="en-GB">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
{FONTS}
<style>
body{{margin:0}}
a{{color:{m["ink"]}}}a:hover{{color:{m["accent"]}}}
</style>
</helmet>
<div style="width: 390px; height: 844px; box-sizing: border-box; position: relative; overflow: hidden; background: {m["bg"]}; color: {m["ink"]}; font-family: 'Bricolage Grotesque', system-ui, sans-serif">
{body}
  {line}
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":390,"height":844}}}}'>
class Component extends DCLogic {{
  renderVals() {{ return {{}}; }}
}}
</script>
</body>
</html>
'''


def header(m, meta, first, word):
    return (f'  <div style="position: absolute; left: 24px; top: 64px; font-family: \'IBM Plex Mono\', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.1em; text-transform: uppercase; color: {m["ink2"]}">{meta}</div>\n'
            f'  <h1 style="position: absolute; left: 24px; right: 24px; top: 82px; margin: 0; font-size: 36px; font-weight: 800; letter-spacing: -0.035em; line-height: 1.02">{first}<br><em style="{EM}">{word}</em></h1>')


def primary(m, href, label):
    return (f'  <a href="{href}" style="position: absolute; left: 24px; right: 24px; bottom: 34px; height: 52px; border-radius: 26px; background: {m["pbg"]}; color: {m["pfg"]}; '
            f'text-decoration: none; display: flex; align-items: center; justify-content: center; font-size: 17px; font-weight: 600">{label}</a>')


def scene(src, alt, left, top, w, h):
    return f'  <img src="{src}" alt="{alt}" style="position: absolute; left: {left}px; top: {top}px; width: {w}px; height: {h}px">'


def chip(m, x, y, w, h, label, on):
    bg, fg = (m["pbg"], m["pfg"]) if on else (m["chip"], m["ink"])
    edge = "transparent" if on else m["edge"]
    return (f'  <button type="button" aria-pressed="{str(on).lower()}" style="position: absolute; left: {x}px; top: {y}px; width: {w}px; height: {h}px; box-sizing: border-box; border-radius: 14px; '
            f'border: 1px solid {edge}; background: {bg}; color: {fg}; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 14px; font-weight: 600; padding: 0">{label}</button>')


def ring(cx, cy, rx, ry, start="right"):
    """A loose hand-drawn ring, clockwise from the right, overshooting a little before the pen lifts."""
    k = 0.55
    return (f"C {cx + rx} {cy + ry * k} {cx + rx * k} {cy + ry} {cx} {cy + ry} "
            f"C {cx - rx * k} {cy + ry} {cx - rx} {cy + ry * k} {cx - rx} {cy} "
            f"C {cx - rx} {cy - ry * k} {cx - rx * k} {cy - ry} {cx} {cy - ry} "
            f"C {cx + rx * k} {cy - ry} {cx + rx * 1.02} {cy - ry * k} {cx + rx * .96} {cy - ry * .12}")


def underline(end, enter=118):
    return f"M -6 {enter} C 8 {enter + 14} 14 160 24 161 C {24 + (end - 24) * .35} 164 {24 + (end - 24) * .7} 158 {end} 161"


DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
PICKED = [0, 2, 4]


def screens(mode):
    m = MODES[mode]; s = m["suffix"]; files = {}
    nxt = lambda n: f"Ob{s}{n}.dc.html"

    # 1 welcome: the line underlines the promise and runs on into the drawn path the coaches sit on
    end = (344, 470) if mode == "night" else (300, 452)
    files[nxt("Welcome")] = page(m, f"Onboarding · welcome, {m['label']}", "\n".join([
        scene(ART["welcome"][mode], "Torn paper hills with a drawn path winding up them; the eight coaches sit together at the foot of the path", 0, 200, 390, 585),
        header(m, "Second Strong", "Let's build", "your week."),
        f'  <p style="position: absolute; left: 24px; top: 176px; margin: 0; width: 300px; font-size: 16px; line-height: 1.4; color: {m["ink2"]}">Four quick questions, then a first week built around you.</p>',
        primary(m, nxt("Coach"), "Begin")]),
        f"M 18 161 C 60 165 120 157 180 161 C 280 168 350 210 352 280 C 354 350 348 410 {end[0]} {end[1]}")

    # 2 coach: the line rings the chosen coach in the grid
    order = ["pebble", "fern", "wren", "bramble", "luna", "otto", "tilly", "miso"]
    names = ["Pebble", "Fern", "Wren", "Bramble", "Luna", "Otto", "Tilly", "Miso"]
    cells = []
    for i, k in enumerate(order):
        x, y = 24 + (i % 4) * 88, 384 + (i // 4) * 92
        cells.append(f'  <button type="button" aria-pressed="{str(k == "miso").lower()}" style="position: absolute; left: {x}px; top: {y}px; width: 78px; height: 84px; padding: 0; border: 0; background: transparent; color: {m["ink"]}; display: flex; flex-direction: column; align-items: center; gap: 4px; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 13px; font-weight: 600">'
                     f'<img src="{COACH[k]}" alt="" style="width: 76px; height: 54px; object-fit: contain">{names[i]}</button>')
    files[nxt("Coach")] = page(m, f"Onboarding · your coach, {m['label']}", "\n".join([
        header(m, "1 of 4 · your coach", "Pick your", "coach."),
        f'  <img src="{COACH["miso"]}" alt="Miso the cat, standing on a small torn-paper hill" style="position: absolute; left: 75px; top: 186px; width: 240px; height: 164px; object-fit: contain">',
        *cells,
        f'  <label for="name" style="position: absolute; left: 24px; top: 586px; font-family: \'IBM Plex Mono\', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: {m["ink2"]}">Their name</label>',
        f'  <input id="name" value="Miso" maxlength="14" style="position: absolute; left: 24px; top: 606px; width: 342px; height: 54px; box-sizing: border-box; padding: 0 16px; border-radius: 16px; border: 1.5px solid {m["ink"]}; background: {m["card"]}; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 18px; color: {m["ink"]}">',
        primary(m, nxt("Stage"), "Continue")]),
        underline(118) + " C 240 168 384 238 380 360 C 378 410 376 470 374 516 " + ring(327, 518, 47, 46))

    # 3 stage: paper moons, the line rings the answer
    stages = [("peri", "Perimenopause", True), ("meno", "Menopause", False), ("post", "After menopause", False), ("surg", "Surgical", False)]
    tiles = []
    for i, (k, label, on) in enumerate(stages):
        x, y = 24 + (i % 2) * 177, 196 + (i // 2) * 124
        tiles.append(f'  <button type="button" role="radio" aria-checked="{str(on).lower()}" style="position: absolute; left: {x}px; top: {y}px; width: 165px; height: 112px; box-sizing: border-box; border-radius: 18px; border: 1px solid {m["edge"]}; background: {m["card"]}; color: {m["ink"]}; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; padding: 0; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 15px; font-weight: 600">'
                     f'<img src="{ICON[k]}" alt="" style="width: 62px; height: 56px; object-fit: contain">{label}</button>')
    tiles.append(f'  <button type="button" role="radio" aria-checked="false" style="position: absolute; left: 24px; top: 444px; width: 342px; height: 76px; box-sizing: border-box; border-radius: 18px; border: 1px solid {m["edge"]}; background: {m["card"]}; color: {m["ink"]}; display: flex; align-items: center; gap: 14px; padding: 0 18px; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 15px; font-weight: 600">'
                 f'<img src="{ICON["unsure"]}" alt="" style="width: 60px; height: 50px; object-fit: contain">Not sure yet</button>')
    files[nxt("Stage")] = page(m, f"Onboarding · about you, {m['label']}", "\n".join([
        header(m, "2 of 4 · about you", "Where are", "you?"),
        *tiles,
        f'  <p style="position: absolute; left: 24px; right: 24px; top: 540px; margin: 0; font-size: 14px; line-height: 1.4; color: {m["ink2"]}">This shapes recovery and protein, not how hard you train. You can change it any time.</p>',
        primary(m, nxt("Goals"), "Continue")]),
        underline(92) + " C 180 158 212 210 204 252 " + ring(106, 252, 98, 70))

    # 4 goals: up to two, the line rings both
    goals = [("strong", "Strength", True), ("protein", "Protein", False), ("energy", "Energy", False), ("sleep", "Sleep", True)]
    gt = []
    for i, (k, label, on) in enumerate(goals):
        x, y = 24 + (i % 2) * 177, 196 + (i // 2) * 162
        gt.append(f'  <button type="button" role="checkbox" aria-checked="{str(on).lower()}" style="position: absolute; left: {x}px; top: {y}px; width: 165px; height: 150px; box-sizing: border-box; border-radius: 18px; border: 1px solid {m["edge"]}; background: {m["card"]}; color: {m["ink"]}; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; padding: 0; font-family: \'Bricolage Grotesque\', sans-serif; font-size: 16px; font-weight: 600">'
                  f'<img src="{ICON[k]}" alt="" style="width: 92px; height: 84px; object-fit: contain">{label}</button>')
    files[nxt("Goals")] = page(m, f"Onboarding · what matters, {m['label']}", "\n".join([
        header(m, "3 of 4 · up to two", "What", "matters?"),
        *gt,
        primary(m, nxt("Days"), "Continue")]),
        underline(150) + " C 220 166 210 226 204 271 " + ring(106, 271, 98, 92) + " C 214 300 248 338 283 340 C 340 340 381 380 381 433 C 381 487 340 526 283 526 C 226 526 185 487 185 433 C 185 386 222 346 272 341")

    # 5 days: paper flags along the path, the line loops each chosen day
    dchips = [chip(m, 24 + 50 * i, 196, 42, 64, d, i in PICKED) for i, d in enumerate(DAYS)]
    loops = ""
    for n, i in enumerate(PICKED):
        cx = 45 + 50 * i
        lead = f" C {cx - 40} 176 {cx - 20} 186 {cx} 187 " if n == 0 else f" C {cx - 70} 180 {cx - 30} 184 {cx} 187 "
        loops += lead + f"C {cx + 22} 187 {cx + 32} 206 {cx + 32} 228 C {cx + 32} 252 {cx + 18} 270 {cx} 270 C {cx - 18} 270 {cx - 32} 252 {cx - 32} 228 C {cx - 32} 208 {cx - 20} 190 {cx + 2} 188"
    files[nxt("Days")] = page(m, f"Onboarding · your days, {m['label']}", "\n".join([
        scene(ART["days"][mode], "Torn paper hills with three small paper flags along a drawn path", -65, 497, 520, 347),
        header(m, "4 of 4 · two to four", "Your", "days."),
        *dchips,
        f'  <p style="position: absolute; left: 24px; top: 290px; margin: 0; font-family: \'Gochi Hand\', cursive; font-size: 19px; color: {m["accent"]}; transform: rotate(-2deg)">tap the days that usually work</p>',
        f'  <p style="position: absolute; left: 24px; right: 24px; top: 330px; margin: 0; font-size: 15px; line-height: 1.4; color: {m["ink2"]}">Three days picked. Each one gets a short strength session; the others stay light.</p>',
        primary(m, nxt("Plan"), "Make my plan")]),
        underline(100) + loops + " C 290 186 300 196 306 206")

    # 6 plan: the line loops the session days and runs on to the flag at the top of the path
    pchips = [chip(m, 24 + 50 * i, 306, 42, 64, d, i in PICKED) for i, d in enumerate(DAYS)]
    ploops = ""
    for n, i in enumerate(PICKED):
        cx = 45 + 50 * i
        lead = f" C 120 200 {cx - 30} 290 {cx} 297 " if n == 0 else f" C {cx - 70} 290 {cx - 30} 294 {cx} 297 "
        ploops += lead + f"C {cx + 22} 297 {cx + 32} 316 {cx + 32} 338 C {cx + 32} 362 {cx + 18} 380 {cx} 380 C {cx - 18} 380 {cx - 32} 362 {cx - 32} 338 C {cx - 32} 318 {cx - 20} 300 {cx + 2} 298"
    flag = (366, 588) if mode == "night" else (370, 586)
    files[nxt("Plan")] = page(m, f"Onboarding · your first week, {m['label']}", "\n".join([
        scene(ART["plan"][mode], "Torn paper hills with a drawn path climbing to a small paper flag on the top hill", -65, 497, 520, 347),
        header(m, "Wednesday 21 October", "Your first", "week."),
        f'  <div style="position: absolute; left: 24px; right: 24px; top: 194px; height: 92px; box-sizing: border-box; border-radius: 18px; border: 1px solid {m["edge"]}; background: {m["card"]}; display: flex; align-items: center; gap: 14px; padding: 0 16px">'
        f'<img src="{ICON["protein"]}" alt="" style="width: 62px; height: 62px; object-fit: contain"><div><div style="font-size: 34px; font-weight: 800; letter-spacing: -0.03em; line-height: 1">100<small style="font-size: 18px; font-weight: 700">g</small></div>'
        f'<div style="margin-top: 4px; font-family: \'IBM Plex Mono\', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: {m["ink2"]}">Protein a day</div></div></div>',
        *pchips,
        f'  <p style="position: absolute; left: 24px; right: 24px; top: 392px; margin: 0; font-size: 15px; line-height: 1.4; color: {m["ink2"]}">Strength on Monday, Wednesday and Friday. Miso checks in each morning.</p>',
        primary(m, "#start", "Start my week")]),
        underline(100) + ploops + f" C 300 300 352 420 356 470 C 360 520 {flag[0] - 6} {flag[1] - 40} {flag[0]} {flag[1]}")
    return files


if __name__ == "__main__":
    allf = {}
    for mode in ("night", "day"):
        allf.update(screens(mode))
    for n, t in allf.items():
        open(os.path.join(OUT, n), "w", encoding="utf-8").write(t)
    steps = ["Welcome", "Coach", "Stage", "Goals", "Days", "Plan"]
    titles = ["Welcome", "Your coach", "About you", "What matters", "Your days", "Your first week"]
    boards, order = {}, []
    for row, (s, lab) in enumerate((("", "dark"), ("Light", "light"))):
        for i, (st, t) in enumerate(zip(steps, titles)):
            f = f"Ob{s}{st}.dc.html"
            boards[f] = {"x": i * 470, "y": row * 1340, "w": 390, "h": 844, "title": f"{i + 1} · {t}" + (" · light" if lab == "light" else ""), "is_interactive": True, "radius": 44}
            order.append(f)
    canvas = {"v": 3, "createdOnFiles": {"v": 1, "at": "2026-10-21T21:30:00Z"}, "title": "Onboarding", "launch": {"view": "canvas"}, "pages": [],
              "boards": boards, "order": order, "designSystems": [],
              "notes": {"dark": {"kind": "title1", "maxW": 2740, "text": "Onboarding · paper and one line · dark", "x": 0, "y": -260},
                        "light": {"kind": "title1", "maxW": 2740, "text": "Onboarding · paper and one line · light", "x": 0, "y": 1080},
                        "about": {"fill": "gray", "size": 24, "w": 440, "maxH": 330, "x": 2820, "y": 0,
                                  "text": "One ink line runs through every screen: it underlines the question, rings your answer and draws on into the plan. Torn-paper scenes, paper moons for the stages, paper icons for the goals, and each coach on a small paper hill. Press Play on Welcome to walk it."}}}
    json.dump(canvas, open(os.path.join(OUT, "canvas.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print("wrote", len(allf), "screens")
