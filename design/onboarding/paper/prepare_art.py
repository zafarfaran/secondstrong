"""Prepares the onboarding art for the screens: scenes snapped to the exact screen colour (3x JPEG),
icons trimmed and shrunk (PNG with alpha), and each coach standing on the paper hill (PNG with alpha).
Run from design/onboarding/paper/ after gen_paper.py. Writes web/."""
import os
import numpy as np
from PIL import Image

OUT = "web"
os.makedirs(OUT, exist_ok=True)
IVORY, DARK = (251, 248, 244), (33, 27, 23)


def snap(name, target):
    im = np.asarray(Image.open(f"art/{name}.png").convert("RGB")).astype(np.float32)
    h, w, _ = im.shape
    bg = np.median(np.concatenate([im[:24, :24].reshape(-1, 3), im[:24, -24:].reshape(-1, 3)]), axis=0)
    T = np.array(target, dtype=np.float32)
    sh = np.clip(im + (T - bg), 0, 255)
    t = np.clip((np.linalg.norm(im - bg, axis=2) - 6) / 18, 0, 1)[..., None]
    Image.fromarray((sh * t + T * (1 - t)).astype(np.uint8)).resize((1170, round(h * 1170 / w)), Image.LANCZOS).save(f"{OUT}/{name}.jpg", quality=86)


for mode, col in (("night", DARK), ("day", IVORY)):
    for s in ("welcome", "days", "plan"):
        snap(f"{s}-{mode}", col)

for n in ["stage-peri", "stage-meno", "stage-post", "stage-surg", "stage-unsure", "goal-strong", "goal-protein", "goal-energy", "goal-sleep"]:
    im = Image.open(f"art/{n}.png").convert("RGBA")
    im = im.crop(im.getbbox())
    im.thumbnail((300, 300), Image.LANCZOS)
    im.save(f"{OUT}/{n}.png", optimize=True)

# each coach on the paper hill: every coach keeps the board's shared scale, its ground line on the hill's top
plinth = Image.open("art/plinth.png").convert("RGBA")
plinth = plinth.crop(plinth.getbbox())
W, H = 600, 600
plinth = plinth.resize((560, round(plinth.height * 560 / plinth.width)), Image.LANCZOS)
alpha = np.asarray(plinth)[..., 3]
top = int(np.argmax(alpha[:, plinth.width // 2] > 128))                 # the hill's top at its middle
py = H - plinth.height
for k in ["pebble", "fern", "wren", "bramble", "luna", "otto", "tilly", "miso"]:
    coach = Image.open(os.path.join("..", "..", "mascots", "png", f"{k}.png")).convert("RGBA")
    s = 400 / coach.width                                                # board frame 200 units -> 400 px
    coach = coach.resize((400, 400), Image.LANCZOS)
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    canvas.alpha_composite(plinth, ((W - plinth.width) // 2, py))
    ground = round(178 * 2)                                              # the coach's feet sit at y 178 of 200
    canvas.alpha_composite(coach, ((W - 400) // 2, py + top + 34 - ground))
    canvas = canvas.crop(canvas.getbbox())
    canvas.save(f"{OUT}/coach-{k}.png", optimize=True)
print("prepared", len(os.listdir(OUT)), "files")
