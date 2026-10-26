"""Dashboard art for the Today tab (SS-0025): four hero scenes (morning and evening, light and dark) and five paper habit
icons. Same recipe as gen_paper.py. Needs OPENAI_API_KEY in the environment (never stored here).
Usage: python gen_dashboard.py [name ...]   (from design/onboarding/paper/)   -> art/<name>.png, web/<icon>.png"""
import io, os, sys, base64
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
from gen_paper import ICON, ICON_MODEL, MODEL, OUT, NO, NIGHT, DAY, NIGHT_REF, DAY_REF, client

HERO = ("Wide scene. A small flat-topped torn-paper hill stands in the lower right, empty on top, where a character will be "
        "placed, with the path winding up to it from the lower left. Soft layered hills behind. The top 45 percent is empty "
        "paper sky." + NO)
SCENES = {
    "today-morning-day": dict(refs=[DAY_REF], prompt=DAY + "A low apricot paper sun is rising at the left behind the hills, a few tiny cream paper clouds. " + HERO),
    "today-evening-day": dict(refs=[DAY_REF], prompt=DAY + "A large soft apricot-and-terracotta paper sun is setting low behind the hills, warm dusky tones, two cream paper clouds. " + HERO),
    "today-morning-night": dict(refs=[NIGHT_REF], prompt=NIGHT + "A pale cream paper crescent moon fading as a thin line of dawn glows apricot behind the hills. " + HERO),
    "today-evening-night": dict(refs=[NIGHT_REF], prompt=NIGHT + "A cream paper crescent moon high in the sky with many tiny paper stars. " + HERO),
}
ICONS = {
    "habit-protein": "A cream paper bowl holding an apricot paper egg half, sage paper leaves and almond paper beans.",
    "habit-strength": "A pair of terracotta paper dumbbells with cream paper handles.",
    "habit-move": "A pair of apricot paper walking shoes with cream paper laces, one stepping forward.",
    "habit-fibre": "A cream paper bowl of sage paper leaves and almond paper beans with a sand paper ear of wheat leaning against it.",
    "habit-sleep": "A soft cream paper pillow with a small cream paper crescent moon and two tiny paper stars above it.",
}


def run(name):
    if name in SCENES:
        j = SCENES[name]
        files = [open(p, "rb") for p in j["refs"]]
        try:
            r = client.images.edit(model=MODEL, image=files, prompt=j["prompt"], size="1536x1024", quality="high", n=1)
        finally:
            for f in files: f.close()
        Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json))).save(os.path.join(OUT, f"{name}.png"))
        return name
    r = client.images.generate(model=ICON_MODEL, prompt=ICON + ICONS[name], size="1024x1024", quality="high", background="transparent", output_format="png", n=1)
    im = Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json)))
    im.save(os.path.join(OUT, f"{name}.png"))
    os.makedirs("web", exist_ok=True)
    t = im.convert("RGBA"); t = t.crop(t.getbbox()); t.thumbnail((300, 300), Image.LANCZOS)
    t.save(f"web/{name}.png", optimize=True)
    return name


if __name__ == "__main__":
    names = sys.argv[1:] or list(SCENES) + list(ICONS)
    with ThreadPoolExecutor(min(6, len(names))) as ex:
        for n, f in [(n, ex.submit(run, n)) for n in names]:
            try: print("made", f.result())
            except Exception as e: print("FAILED", n, str(e)[:200])
