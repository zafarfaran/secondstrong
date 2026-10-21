"""Writes the final sign-in flow (dark and light) from the chosen screens, and moves every earlier
screen onto an Explorations page. Usage: python make_final.py <read folder> <canvas project folder>"""
import json, os, re, sys

SRC, OUT = sys.argv[1], sys.argv[2]
read = lambda n: open(os.path.join(SRC, n), encoding="utf-8").read()
NIGHT = {"bramble": "/_blob/6851cab4f0f1d4e82cc898ef906f9bae", "miso": "/_blob/ecb38e263716350ef349e56b3f455645", "otto": "/_blob/8d2bd510490443218ad32b0f7ff4ebc3"}
FADE = "-webkit-mask-image: radial-gradient(closest-side, #000 70%, transparent); mask-image: radial-gradient(closest-side, #000 70%, transparent)"


def darken(s):
    """Sketchbook light tokens -> the dark palette (ground #211B17, ink #F1E9DF)."""
    s = s.replace("background: #3B322C; color: #FBF8F4;", "background: #F1E9DF; color: #211B17;").replace('fill="#FBF8F4" aria-hidden', 'fill="#211B17" aria-hidden')
    for a, b in [("#FBF8F4", "#211B17"), ("#F6F0E8", "#2A231F"), ("rgba(59,50,44,.28)", "rgba(241,233,223,.34)"), ("rgba(59,50,44,.10)", "rgba(241,233,223,.10)"),
                 ("#5D534B", "#B8AA9D"), ("#3B322C", "#F1E9DF"), ("#A85A3C", "#E09A78")]:
        s = s.replace(a, b)
    return s


def links(s, prefix):
    m = {"Main": "SignIn", "MainB": "SignIn", "Email": "Email", "Inbox": "Inbox", "InboxB": "Inbox", "Returning": "Returning",
         "ReturningB": "Returning", "Expired": "Expired", "ExpiredB": "Expired"}
    return re.sub(r'href="(MainB|Main|Email|InboxB|Inbox|ReturningB|Returning|ExpiredB|Expired)\.dc\.html"', lambda g: f'href="{prefix}{m[g.group(1)]}.dc.html"', s)


def title(s, t):
    return re.sub(r"<title>[^<]*</title>", f"<title>{t}</title>", s)


def swap_img(s, old_src, new_src, alt, style):
    s2 = re.sub(r'<img src="' + re.escape(old_src) + r'" alt="[^"]*" style="[^"]*">', f'<img src="{new_src}" alt="{alt}" style="{style}">', s)
    assert s2 != s, old_src
    return s2


files = {}
# dark: the night sign-in, then the illustrated flow recoloured with the coaches in the night paper scene
files["FinalSignIn.dc.html"] = title(links(read("MascotNight.dc.html"), "Final"), "Sign in")
files["FinalEmail.dc.html"] = title(links(darken(read("Email.dc.html")), "Final"), "Sign in with email")
files["FinalInbox.dc.html"] = title(links(swap_img(darken(read("InboxB.dc.html")), "/_blob/f123e44142e129d64dff84e978696722", NIGHT["bramble"],
    "Bramble the bear on a torn-paper hill under the moon, holding up a sealed envelope", f"width: 236px; height: 236px; {FADE}"), "Final"), "Check your inbox")
files["FinalInbox.dc.html"] = files["FinalInbox.dc.html"].replace('<div style="height: 220px; margin-top: 0;', '<div style="height: 236px; margin-top: -8px;')
files["FinalReturning.dc.html"] = title(links(swap_img(darken(read("ReturningB.dc.html")), "/_blob/328787174c22c2e774497afbf44be059", NIGHT["miso"],
    "Miso the cat, your coach, on a torn-paper hill under the moon, keeping your page in a notebook and waving", f"width: 300px; height: 300px; {FADE}"), "Final"), "Welcome back")
files["FinalExpired.dc.html"] = title(links(swap_img(darken(read("ExpiredB.dc.html")), "/_blob/df8c0145a8952d900053bccfb5eded20", NIGHT["otto"],
    "Otto the otter on a torn-paper hill under the moon, scratching its head beside a small hourglass", f"width: 290px; height: 290px; {FADE}"), "Final"), "Link expired")
# light: the sunrise sign-in, then the illustrated flow as it was
files["FinalLightSignIn.dc.html"] = title(links(read("MascotDay.dc.html"), "FinalLight"), "Sign in, light")
files["FinalLightEmail.dc.html"] = title(links(read("Email.dc.html"), "FinalLight"), "Sign in with email, light")
files["FinalLightInbox.dc.html"] = title(links(read("InboxB.dc.html"), "FinalLight"), "Check your inbox, light")
files["FinalLightReturning.dc.html"] = title(links(read("ReturningB.dc.html"), "FinalLight"), "Welcome back, light")
files["FinalLightExpired.dc.html"] = title(links(read("ExpiredB.dc.html"), "FinalLight"), "Link expired, light")

for n, s in files.items():
    for h in re.findall(r'href="([A-Za-z]+\.dc\.html)"', s):
        assert h in files, f"{n} links to {h}"
    open(os.path.join(OUT, n), "w", encoding="utf-8").write(s)

# canvas: a Final page first (opens on it), every earlier screen and note on Explorations
c = json.load(open(os.path.join(SRC, "canvas.json"), encoding="utf-8"))
for b in c["boards"].values(): b["page"] = "explore"
for nt in c["notes"].values(): nt["page"] = "explore"
c["pages"] = [{"id": "final", "name": "Final"}, {"id": "explore", "name": "Explorations"}]
c["launch"] = {"view": "canvas", "page": "final"}
steps = ["SignIn", "Email", "Inbox", "Returning", "Expired"]
names = ["Sign in", "Email", "Check your inbox", "Welcome back", "Link expired"]
for row, (prefix, y, label) in enumerate([("Final", 0, "dark"), ("FinalLight", 1340, "light")]):
    for i, (st, nm) in enumerate(zip(steps, names)):
        f = f"{prefix}{st}.dc.html"
        c["boards"][f] = {"x": i * 470, "y": y, "w": 390, "h": 844, "title": f"{i + 1} · {nm}" + (" · light" if label == "light" else ""),
                          "is_interactive": True, "radius": 44, "page": "final"}
        c["order"].append(f)
c["notes"]["final-dark"] = {"kind": "title1", "maxW": 2270, "text": "Sign in · final · dark", "x": 0, "y": -260, "page": "final"}
c["notes"]["final-light"] = {"kind": "title1", "maxW": 2270, "text": "Sign in · final · light", "x": 0, "y": 1080, "page": "final"}
c["notes"]["final-about"] = {"fill": "gray", "size": 24, "w": 420, "maxH": 360, "x": 2350, "y": 0, "page": "final",
    "text": "The app follows the phone's light or dark setting. Dark: the coaches on paper at night, with Bramble, Miso and Otto in the same night paper scene. Light: the sunrise sign-in and the illustrated screens. Press Play on Sign in to walk the flow."}
json.dump(c, open(os.path.join(OUT, "canvas.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("wrote", len(files), "screens;", len(c["boards"]), "boards")
