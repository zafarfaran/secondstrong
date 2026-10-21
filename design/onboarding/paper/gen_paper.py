"""Generates the paper-style onboarding art with OpenAI's image model. Scenes use the sign-in collages as
style reference (night for dark mode, sunrise for light); icons are torn-paper cut-outs on a transparent
background so they sit on either mode. Needs OPENAI_API_KEY in the environment (never stored here).
Usage: python gen_paper.py [name ...]   (from design/onboarding/paper/)   -> art/<name>.png"""
import base64, io, os, sys
from concurrent.futures import ThreadPoolExecutor
from openai import OpenAI
from PIL import Image

MODEL = "gpt-image-2"
ICON_MODEL = "gpt-image-1.5"   # gpt-image-2 cannot make transparent backgrounds
OUT = "art"
os.makedirs(OUT, exist_ok=True)
client = OpenAI()
SIGNIN = os.path.join("..", "..", "signin", "art", "ai")
NIGHT_REF, DAY_REF = f"{SIGNIN}/paper-dark.png", f"{SIGNIN}/paper-shapes.png"
CAST_REF = f"{SIGNIN}/mascot-paper-night.png"
CAST = ("the eight coaches from the second reference: Pebble (grey stone, moss top), Fern (green sprout), Wren (orange bird), "
        "Bramble (brown bear), Miso (lilac-grey cat), Luna (pale moon with a gold star), Otto (brown otter), Tilly (tortoise)")
NO = " No text, no letters, no numbers, no logos, no red."
NIGHT = ("Recreate the style of the first reference exactly: cut and torn paper collage at night on plain very dark warm brown "
         "paper (#211B17), a cream paper crescent moon, tiny paper stars, layered torn-paper hills of deep umber, dark sage, "
         "plum-brown and dark terracotta with torn edges and paper fibres, one thin warm off-white ink line as a path. ")
DAY = ("Recreate the style of the first reference exactly: cut and torn paper collage on plain warm ivory paper (#FBF8F4), "
       "a soft apricot paper sun, layered torn-paper hills of almond, sand, sage and terracotta with torn white edges and "
       "paper fibres, one thin dark brown ink line as a path. ")
ICON = ("A single torn and cut paper cut-out object, made of layered coloured paper with torn white edges, paper fibres and a "
        "soft contact shadow, in a warm muted palette of almond, sand, sage, apricot, terracotta and cream. Centred, filling "
        "about 70 percent of the frame, on a fully transparent background. Simple, iconic, calm." + NO + " ")

WELCOME = (f"Portrait scene. At the foot of the hills, at the start of the path, sit {CAST}, small and close together, soft "
           "rounded bodies as in the second reference. The path winds up and over the hills towards the sky. "
           "The top 40 percent is empty paper sky." + NO)
DAYS = "Wide scene. Low layered hills; along the path stand three small torn-paper flags on thin sticks, spaced out. The top half is empty paper sky." + NO
PLAN = "Wide scene. The path climbs gently over layered hills to a small torn-paper flag on the top hill. The top third is empty paper sky." + NO

JOBS = {
    "welcome-night": dict(size="1024x1536", refs=[NIGHT_REF, CAST_REF], prompt=NIGHT + WELCOME),
    "welcome-day": dict(size="1024x1536", refs=[DAY_REF, CAST_REF], prompt=DAY + WELCOME.replace("crescent moon", "sun")),
    "days-night": dict(size="1536x1024", refs=[NIGHT_REF], prompt=NIGHT + DAYS),
    "days-day": dict(size="1536x1024", refs=[DAY_REF], prompt=DAY + DAYS),
    "plan-night": dict(size="1536x1024", refs=[NIGHT_REF], prompt=NIGHT + PLAN),
    "plan-day": dict(size="1536x1024", refs=[DAY_REF], prompt=DAY + PLAN),
    # stages: the moon's phases as a gentle, non-medical metaphor
    "stage-peri": dict(size="1024x1024", icon=True, prompt=ICON + "A cream paper waxing crescent moon with one small apricot paper star."),
    "stage-meno": dict(size="1024x1024", icon=True, prompt=ICON + "A round cream paper full moon with a few soft almond paper craters."),
    "stage-post": dict(size="1024x1024", icon=True, prompt=ICON + "A cream paper waning crescent moon resting on a small sage paper hill."),
    "stage-surg": dict(size="1024x1024", icon=True, prompt=ICON + "A cream paper half moon, cleanly cut straight down the middle, with a small apricot paper star."),
    "stage-unsure": dict(size="1024x1024", icon=True, prompt=ICON + "A soft rounded almond paper cloud with a small cream paper moon peeking out from behind it."),
    # goals
    "goal-strong": dict(size="1024x1024", icon=True, prompt=ICON + "A terracotta paper kettlebell with a cream paper handle."),
    "goal-protein": dict(size="1024x1024", icon=True, prompt=ICON + "A cream paper plate seen from above with a sage paper leaf salad, an apricot paper egg half and almond paper beans."),
    "goal-energy": dict(size="1024x1024", icon=True, prompt=ICON + "An apricot paper sun rising over a small sage paper hill, with short torn-paper rays."),
    "goal-sleep": dict(size="1024x1024", icon=True, prompt=ICON + "A cream paper crescent moon with two tiny paper stars and a small soft almond paper cloud."),
    # a little paper hill for each coach to stand on (the real coach art is placed on it)
    "plinth": dict(size="1536x1024", icon=True, prompt=ICON.replace("Centred, filling about 70 percent of the frame", "Centred, wide and low, filling the width") +
                   "A low rounded torn-paper hill, layered sage over almond over terracotta, flat on top, like a small stage."),
}


def run(name):
    j = JOBS[name]
    if j.get("icon"):
        r = client.images.generate(model=ICON_MODEL, prompt=j["prompt"], size=j["size"], quality="high", background="transparent", output_format="png", n=1)
    else:
        files = [open(p, "rb") for p in j["refs"]]
        try:
            r = client.images.edit(model=MODEL, image=files, prompt=j["prompt"], size=j["size"], quality="high", n=1)
        finally:
            for f in files: f.close()
    Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json))).save(os.path.join(OUT, f"{name}.png"))
    return name


if __name__ == "__main__":
    names = sys.argv[1:] or list(JOBS)
    with ThreadPoolExecutor(min(8, len(names))) as ex:
        for n, f in [(n, ex.submit(run, n)) for n in names]:
            try: print("made", f.result())
            except Exception as e: print("FAILED", n, e)
