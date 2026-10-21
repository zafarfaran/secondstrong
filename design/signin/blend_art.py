"""Snaps the generated art's paper to the exact screen colour (ivory #FBF8F4, or #211B17 for dark) so the
images sit on the screen with no visible edge, and saves 3x JPEGs for the canvas. Run from design/signin/."""
import os
from PIL import Image
import numpy as np

SRC, OUT = os.path.join("art", "ai"), os.path.join("art", "ai", "web")
os.makedirs(OUT, exist_ok=True)
JOBS = {"hero-light": ((251, 248, 244), 1170), "hero-dark": ((33, 27, 23), 1170),
        "returning-miso": ((251, 248, 244), 900), "inbox-bramble": ((251, 248, 244), 900), "expired-otto": ((251, 248, 244), 900)}
for name, (target, width) in JOBS.items():
    im = np.asarray(Image.open(os.path.join(SRC, f"{name}.png")).convert("RGB")).astype(np.float32)
    h, w, _ = im.shape
    corners = np.concatenate([im[:24, :24].reshape(-1, 3), im[:24, -24:].reshape(-1, 3), im[-24:, :24].reshape(-1, 3), im[-24:, -24:].reshape(-1, 3)])
    bg = np.median(corners, axis=0)
    shifted = np.clip(im + (np.array(target) - bg), 0, 255)          # move the whole paper tone onto the target
    d = np.linalg.norm(im - bg, axis=2)                              # how far each pixel is from the paper
    t = np.clip((d - 6) / 18, 0, 1)[..., None]                       # paper and its faint texture -> exact target
    out = shifted * t + np.array(target) * (1 - t)
    img = Image.fromarray(out.astype(np.uint8))
    img = img.resize((width, round(h * width / w)), Image.LANCZOS)
    img.save(os.path.join(OUT, f"{name}.jpg"), quality=88)
    print(name, "paper was", bg.round().astype(int).tolist())
