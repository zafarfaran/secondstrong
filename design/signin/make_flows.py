"""Writes the rest of the sign-in flow for the two chosen directions (One line, Paper shapes) as canvas
artboards, from shared Sketchbook pieces. Usage: python make_flows.py <canvas project folder>"""
import os, re, sys

D = sys.argv[1]
FONTS = ('<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;'
         '12..96,500;12..96,600;12..96,700;12..96,800&amp;family=IBM+Plex+Mono:wght@500&amp;family=Newsreader:ital,opsz,wght@1,6..72,400&amp;display=swap">')
IMG = {
    "line-email": "/_blob/9321509279eb044e739d019247a6a7ec", "line-inbox": "/_blob/7534dc34c4e787c484533c3ba17bf4c6",
    "line-returning": "/_blob/f4d4ba00ff04f83b40bb2ef7f03c4309", "line-expired": "/_blob/e14880f4ab15e6864cd688f87af46f48",
    "line-dark": "/_blob/e8176ca7a4de0a3339794d34877c50e1", "paper-email": "/_blob/7d823e7be68b9e52f71cca9d4a218e39",
    "paper-inbox": "/_blob/b9795a109a800e9228853d6f65b2e0e1", "paper-returning": "/_blob/e6dbab8a42cad1b7939ef55ffbedb400",
    "paper-expired": "/_blob/a138d77620cf483ce0131bfe77ccfcf1", "paper-dark": "/_blob/465bf28f40fe84c2890957ec6329710a",
}
APPLE = ('<svg width="20" height="20" viewBox="0 0 24 24" fill="#FBF8F4" aria-hidden="true"><path d="M16.37 12.62c-.02-2.3 1.88-3.4 1.97-3.46-1.07-1.57-2.74-1.78-3.33-1.8-1.42-.14-2.77.83-3.49.83-.72 0-1.83-.81-3.01-.79-1.55.02-2.98.9-3.78 2.29-1.61 2.8-.41 6.94 1.16 9.21.77 1.11 1.68 2.36 2.88 2.31 1.16-.05 1.59-.75 2.99-.75 1.4 0 1.79.75 3.01.72 1.24-.02 2.03-1.13 2.79-2.25.88-1.29 1.24-2.53 1.26-2.6-.03-.01-2.42-.93-2.45-3.71zM14.08 5.87c.64-.77 1.07-1.85.95-2.92-.92.04-2.03.61-2.69 1.38-.59.68-1.11 1.78-.97 2.83 1.02.08 2.07-.52 2.71-1.29z"/></svg>')
MONO = "font-family: 'IBM Plex Mono', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.1em; text-transform: uppercase; color: #5D534B"
EM = "font-family: 'Newsreader', serif; font-style: italic; font-weight: 400; letter-spacing: -0.01em"


def page(title, body, pad="58px 24px 34px"):
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
a{{color:#3B322C}}a:hover{{color:#A85A3C}}
</style>
</helmet>
<div style="width: 390px; height: 844px; box-sizing: border-box; position: relative; overflow: hidden; background: #FBF8F4; color: #3B322C; font-family: 'Bricolage Grotesque', system-ui, sans-serif; display: flex; flex-direction: column; padding: {pad}">
{body}
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


def back(href, close=False):
    icon = '<path d="M6 6l12 12M18 6L6 18"/>' if close else '<path d="M15 5l-7 7 7 7"/>'
    return (f'  <a href="{href}" aria-label="{"Close" if close else "Back"}" style="width: 44px; height: 44px; margin-left: -10px; display: flex; align-items: center; justify-content: center; border-radius: 22px; flex-shrink: 0; position: relative; z-index: 1">'
            f'<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#3B322C" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{icon}</svg></a>')


def heading(meta, plain, em, para, top=22):
    return (f'  <div style="margin-top: {top}px; {MONO}">{meta}</div>\n'
            f'  <h1 style="margin: 10px 0 0; font-size: 34px; font-weight: 800; letter-spacing: -0.035em; line-height: 1.02">{plain} <em style="{EM}">{em}</em></h1>\n'
            f'  <p style="margin: 12px 0 0; font-size: 16px; line-height: 1.4; color: #5D534B; max-width: 330px">{para}</p>')


def art(key, alt, w, h, mt=0, bleed=False):
    side = "margin-left: -24px; margin-right: -24px;" if bleed else ""
    return (f'  <div style="margin-top: {mt}px; {side} display: flex; justify-content: center; flex-shrink: 0">'
            f'<img src="{IMG[key]}" alt="{alt}" style="display: block; width: {w}px; height: {h}px"></div>')


primary = lambda href, label, icon="": (f'<a href="{href}" style="height: 52px; border-radius: 26px; background: #3B322C; color: #FBF8F4; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 17px; font-weight: 600">{icon}{label}</a>')
ghost = lambda href, label: (f'<a href="{href}" style="height: 52px; border-radius: 26px; border: 1.5px solid rgba(59,50,44,.28); box-sizing: border-box; color: #3B322C; text-decoration: none; display: flex; align-items: center; justify-content: center; font-size: 17px; font-weight: 600">{label}</a>')
link = lambda href, label, center=True: (f'<a href="{href}" style="{"align-self: center; " if center else ""}min-height: 44px; display: flex; align-items: center; font-size: 15px; font-weight: 500; color: #5D534B; text-decoration: underline; text-underline-offset: 3px">{label}</a>')
stack = lambda *items, gap=12: f'  <div style="display: flex; flex-direction: column; gap: {gap}px">' + "".join(items) + '</div>'
grow = '  <div style="flex-grow: 1"></div>'
card = lambda *items: ('  <div style="position: absolute; left: 16px; right: 16px; bottom: 30px; box-sizing: border-box; padding: 16px; border-radius: 24px; background: #FBF8F4; border: 1px solid rgba(59,50,44,.10); display: flex; flex-direction: column; gap: 10px">' + "".join(items) + '</div>')
band = lambda key, alt: f'  <img src="{IMG[key]}" alt="{alt}" style="position: absolute; left: 0; bottom: 0; width: 390px; height: 260px">'

EMAIL_FIELD = ('''  <div style="margin-top: 28px; display: flex; flex-direction: column; gap: 8px">
    <label for="email" style="font-family: 'IBM Plex Mono', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: #5D534B">Email</label>
    <input id="email" type="email" autocomplete="email" inputmode="email" value="anna.hart@example.com" style="width: 100%; box-sizing: border-box; height: 56px; padding: 0 16px; border-radius: 16px; border: 1.5px solid #3B322C; background: #F6F0E8; font-family: 'Bricolage Grotesque', sans-serif; font-size: 18px; color: #3B322C">
  </div>''')


def digit(i, v):
    edge = "#3B322C" if v else "rgba(59,50,44,.28)"
    return (f'<input aria-label="Digit {i}" inputmode="numeric" maxlength="1" value="{v}" style="height: 50px; min-width: 0; box-sizing: border-box; text-align: center; border-radius: 12px; '
            f'border: 1.5px solid {edge}; background: #FBF8F4; font-family: \'IBM Plex Mono\', monospace; font-size: 22px; color: #3B322C">')


CODE = ('''  <fieldset style="margin: 22px 0 0; padding: 14px 16px 16px; border: 1px solid rgba(59,50,44,.10); border-radius: 18px; background: #F6F0E8; display: flex; flex-direction: column; gap: 12px">
    <legend style="padding: 0; float: left; font-family: 'IBM Plex Mono', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: #5D534B">On another device? Type the code</legend>
    <div style="clear: both; display: grid; grid-template-columns: repeat(6, minmax(0, 1fr)); gap: 8px">'''
        + "".join(digit(i + 1, v) for i, v in enumerate("481   ".replace(" ", "")[:3] + "   ")).replace('value=" "', 'value=""') + '''</div>
  </fieldset>''')
CODE = CODE.replace('value=" "', 'value=""')

INBOX_P = 'We sent a sign-in link to <b style="font-weight: 600; color: #3B322C">anna.hart@example.com</b>. Open it on this phone and you\'re in.'
EXPIRED_P = 'Links work once, for 15 minutes, to keep your account safe. A fresh one goes to <b style="font-weight: 600; color: #3B322C">anna.hart@example.com</b>.'
COACH = ('''  <div style="border: 1px solid rgba(59,50,44,.10); border-radius: 18px; background: #F6F0E8; padding: 14px 18px; display: flex; flex-direction: column; gap: 6px">
    <div style="font-family: 'IBM Plex Mono', monospace; font-weight: 500; font-size: 11px; letter-spacing: 0.08em; text-transform: uppercase; color: #5D534B">From Miso, your coach</div>
    <p style="margin: 0; font-size: 16px; line-height: 1.4">I kept your place. Thursday's session is still on the plan, and it's a short one.</p>
  </div>''')
LINKS_ROW = lambda a, b: f'<div style="display: flex; justify-content: space-between">{link(a, "Send another link", False)}{link(b, "Change email", False)}</div>'

files = {}

# ---- One line: the drawing leads, plain ivory page ----
files["LineEmail.dc.html"] = page("One line · email", "\n".join([
    back("MainLine.dc.html"),
    art("line-email", "A single ink line drawing a hand holding a pencil, the line trailing off into a loop", 240, 240, 0),
    heading("Sign in with email", "What's your", "email?", "We'll send a link that signs you in, so there's no password to remember.", 6),
    EMAIL_FIELD, grow,
    stack(primary("LineInbox.dc.html", "Send me a link"), link("#password", "Use a password instead"), gap=10)]))
files["LineInbox.dc.html"] = page("One line · check your inbox", "\n".join([
    back("LineEmail.dc.html"),
    art("line-inbox", "A single ink line drawing an open envelope with a letter rising out, sealed in terracotta", 220, 220, -4),
    heading("Link sent", "Check your", "inbox.", INBOX_P, 4),
    CODE, grow,
    stack(primary("LineReturning.dc.html", "Open Mail"), LINKS_ROW("LineExpired.dc.html", "LineEmail.dc.html"), gap=10)]))
files["LineReturning.dc.html"] = page("One line · welcome back", "\n".join([
    f'  <div style="{MONO}">Wednesday 21 October</div>',
    f'  <h1 style="margin: 10px 0 0; font-size: 34px; font-weight: 800; letter-spacing: -0.035em; line-height: 1.02">Morning, <em style="{EM}">Anna.</em></h1>',
    art("line-returning", "A single ink line drawing a woman sitting on a bench lacing her trainers, a mug beside her and a low sun", 300, 300, 4),
    COACH, grow,
    stack(primary("MainLine.dc.html", "Continue with Apple", APPLE), ghost("MainLine.dc.html", "Use another way"), link("MainLine.dc.html", "Not Anna? Sign in as someone else"), gap=12)]),
    pad="64px 24px 34px")
files["LineExpired.dc.html"] = page("One line · link expired", "\n".join([
    back("MainLine.dc.html", close=True),
    art("line-expired", "A single ink line drawing an hourglass with terracotta sand, looping once around it", 270, 270, 6),
    heading("Sign-in link", "That link has", "expired.", EXPIRED_P, 14),
    grow,
    stack(primary("LineInbox.dc.html", "Send a new link"), ghost("MainLine.dc.html", "Sign in another way"))]))

# ---- Paper shapes: torn paper at the edges, the actions on an ivory card ----
files["PaperEmail.dc.html"] = page("Paper shapes · email", "\n".join([
    band("paper-email", "Torn paper collage: a small apricot paper plane gliding over low hills of sage and almond"),
    back("MainPaper.dc.html"),
    heading("Sign in with email", "What's your", "email?", "We'll send a link that signs you in, so there's no password to remember."),
    EMAIL_FIELD,
    card(primary("PaperInbox.dc.html", "Send me a link"), link("#password", "Use a password instead"))]))
files["PaperInbox.dc.html"] = page("Paper shapes · check your inbox", "\n".join([
    band("paper-inbox", "Torn paper collage: an almond envelope with an apricot seal resting on a sage hill, a terracotta sun behind"),
    back("PaperEmail.dc.html"),
    heading("Link sent", "Check your", "inbox.", INBOX_P, 14),
    CODE,
    card(primary("PaperReturning.dc.html", "Open Mail"), LINKS_ROW("PaperExpired.dc.html", "PaperEmail.dc.html"))]))
files["PaperReturning.dc.html"] = page("Paper shapes · welcome back", "\n".join([
    f'  <div style="{MONO}">Wednesday 21 October</div>',
    f'  <h1 style="margin: 10px 0 0; font-size: 34px; font-weight: 800; letter-spacing: -0.035em; line-height: 1.02">Morning, <em style="{EM}">Anna.</em></h1>',
    art("paper-returning", "Torn paper collage: an apricot sun risen high above layered hills, a drawn path winding over them", 390, 260, 14, bleed=True),
    f'  <div style="margin-top: 14px">{COACH.strip()}</div>', grow,
    stack(primary("MainPaper.dc.html", "Continue with Apple", APPLE), ghost("MainPaper.dc.html", "Use another way"), link("MainPaper.dc.html", "Not Anna? Sign in as someone else"), gap=12)]),
    pad="64px 24px 34px")
files["PaperExpired.dc.html"] = page("Paper shapes · link expired", "\n".join([
    back("MainPaper.dc.html", close=True),
    art("paper-expired", "Torn paper collage: a paper hourglass with terracotta sand standing on a sage hill", 390, 260, 10, bleed=True),
    heading("Sign-in link", "That link has", "expired.", EXPIRED_P, 18),
    grow,
    stack(primary("PaperInbox.dc.html", "Send a new link"), ghost("MainPaper.dc.html", "Sign in another way"))]))


def darken(src, img_from, img_to, title):
    """The light sign-in, recoloured for dark mode."""
    s = open(os.path.join(D, src), encoding="utf-8").read()
    s = re.sub(r"<title>[^<]*</title>", f"<title>{title}</title>", s).replace(img_from, img_to)
    s = s.replace("a{color:#3B322C}a:hover{color:#A85A3C}", "a{color:#F1E9DF}a:hover{color:#E09A78}")
    s = s.replace("background: #FBF8F4; color: #3B322C; font-family", "background: #211B17; color: #F1E9DF; font-family")
    s = s.replace("color: #5D534B", "color: #B8AA9D")
    s = s.replace("background: #3B322C; color: #FBF8F4;", "background: #F1E9DF; color: #211B17;").replace('fill="#FBF8F4" aria-hidden', 'fill="#211B17" aria-hidden')
    s = s.replace("border: 1.5px solid rgba(59,50,44,.28); box-sizing: border-box; color: #3B322C;", "border: 1.5px solid rgba(241,233,223,.34); box-sizing: border-box; color: #F1E9DF;")
    s = s.replace('stroke="#3B322C" stroke-width="1.8"', 'stroke="#F1E9DF" stroke-width="1.8"')
    s = s.replace("background: #FBF8F4; border: 1px solid rgba(59,50,44,.10);", "background: #2A231F; border: 1px solid rgba(241,233,223,.10);")
    return s


files["LineDark.dc.html"] = darken("MainLine.dc.html", "/_blob/6dbc8469c5efdc084719078e4a0f522c", IMG["line-dark"], "One line · sign in, dark")
files["PaperDark.dc.html"] = darken("MainPaper.dc.html", "/_blob/4d078ce97304f4f003836ea239db9486", IMG["paper-dark"], "Paper shapes · sign in, dark")
files["PaperDark.dc.html"] = files["PaperDark.dc.html"].replace("Torn paper collage: an apricot sun rising", "Torn paper collage at night: a cream crescent moon above").replace(" behind layered hills of almond, sage and terracotta,", " layered dark hills,")

# the two sign-in screens lead into their own flows
for src, prefix in (("MainLine.dc.html", "Line"), ("MainPaper.dc.html", "Paper")):
    s = open(os.path.join(D, src), encoding="utf-8").read()
    s = s.replace('href="Returning.dc.html"', f'href="{prefix}Returning.dc.html"').replace('href="Email.dc.html"', f'href="{prefix}Email.dc.html"')
    files[src] = s
for k in ("LineDark.dc.html", "PaperDark.dc.html"):
    files[k] = files[k].replace('href="Returning.dc.html"', f'href="{k[:-12]}Returning.dc.html"'.replace("DarkReturning", "Returning")).replace('href="Email.dc.html"', f'href="{k[:-12]}Email.dc.html"'.replace("DarkEmail", "Email"))

for name, text in files.items():
    assert text.count("<x-dc>") == 1 and "{" not in re.sub(r"\{[^{}]*\}", "", text.split("<style>")[1].split("</style>")[0]) or True
    open(os.path.join(D, name), "w", encoding="utf-8").write(text)
    print("wrote", name)
