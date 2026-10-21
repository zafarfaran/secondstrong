"""Generates richer sign-in illustrations with OpenAI's image model, using the real coach art as
reference so the characters stay on-model. Needs OPENAI_API_KEY in the environment (never stored here).
Usage: python gen_art.py [name ...]   (from design/signin/; default: every image)   -> art/ai/<name>.png"""
import base64, os, sys, io
from concurrent.futures import ThreadPoolExecutor
from openai import OpenAI
from PIL import Image

MODEL = "gpt-image-2"
OUT = os.path.join("art", "ai")
os.makedirs(OUT, exist_ok=True)
client = OpenAI()

STYLE = (
    "Match the reference characters exactly: soft rounded bodies lit by one gentle key light from the top left, "
    "glossy dark eyes with white highlights, small expressive brows, soft blush cheeks, soft contact shadows. "
    "Keep each character's colours, markings and proportions. "
    "Scenery and props are simple, confident hand-drawn ink line drawings in warm dark brown (#3B322C), one line weight, "
    "minimal, with at most one terracotta (#A85A3C) accent stroke. Calm, warm, plenty of empty space. "
    "No text, no letters, no numbers, no logos, no red, no gradient washes, no extra characters."
)
ONMODEL = (
    "Important: draw the character exactly like the reference image: one soft round blob body that is also the head, "
    "sitting on the ground, NO legs, NO feet, NO neck, no separate torso; short pill-shaped arms only. Same face layout, "
    "same size eyes, same muzzle, same colours. Keep the soft rendered shading, not flat cartoon outlines. "
)
LIGHT = "Background: flat warm ivory paper (#FBF8F4), like a calm journal page."
DARK = "Background: flat very dark warm brown (#211B17). Ink lines are warm off-white (#EDE3D6)."

CAST = ("the eight characters: Pebble (grey stone with a moss-green top), Fern (green sprout with two leaves), "
        "Wren (round orange bird), Bramble (brown bear), Miso (lilac-grey cat, waving), Luna (pale moon with craters and a "
        "little gold star), Otto (brown otter) and Tilly (tortoise with a green head)")

M = os.path.join("..", "mascots", "png")
JOBS = {
    "hero-light": dict(size="1536x1024", refs=["_ref-cast-light.png", f"{M}/miso.png"], prompt=(
        f"Wide illustration of {CAST}, sitting side by side along one hand-drawn ink line that sags gently like a wire, "
        "at sunrise. A simple ink-line sun rises low behind them, two tiny line-drawn birds in the sky. "
        "The group sits in the lower half; the top third is empty paper. " + LIGHT)),
    "hero-dark": dict(size="1536x1024", refs=["_ref-cast-light.png", f"{M}/miso.png"], prompt=(
        f"Wide illustration of {CAST}, sitting side by side along one hand-drawn line that sags gently like a wire, "
        "at night. A simple line-drawn crescent and a few small stars above. The group sits in the lower half; "
        "the top third is empty. " + DARK)),
    "returning-miso": dict(size="1024x1024", refs=[f"{M}/miso.png", "art/miso-hello.png"], prompt=(
        "Miso the lilac-grey cat sits beside an open notebook drawn in ink line, keeping the page with one paw on a "
        "terracotta ribbon bookmark, and waves hello with the other paw. Warm, welcoming. Centered. " + LIGHT)),
    "inbox-bramble": dict(size="1024x1024", refs=[f"{M}/bramble.png", "art/bramble-suggest.png"], prompt=(
        "Bramble the brown bear holds up an envelope drawn in ink line with both paws, looking pleased, a few short "
        "terracotta motion ticks beside the envelope. Centered. " + LIGHT)),
    "expired-otto": dict(size="1024x1024", refs=[f"{M}/otto.png", "art/otto-oops.png"], prompt=(
        "Otto the brown otter, sheepish and apologetic, scratching his head with one paw and holding a small curled "
        "paper slip drawn in ink line in the other; a tiny line-drawn hourglass floats beside him. Gentle, not sad. "
        "Centered. " + LIGHT)),
    # directions without the coaches: generated from the prompt alone
    "line-lift": dict(size="1024x1024", refs=[], prompt=(
        "A single continuous hand-drawn ink line, never lifting the pen, drawing a woman in her fifties doing a "
        "kettlebell deadlift with good form, calm and strong, short hair, simple clothes. The same line flows on into a "
        "low sun on the horizon. Warm dark brown ink (#3B322C), one even line weight, elegant and minimal like a fine "
        "single-line drawing. One small terracotta (#A85A3C) stroke for the sun. Lots of empty space. " + LIGHT +
        " No text, no letters, no shading, no fill, no other colours.")),
    "morning-table": dict(size="1024x1536", refs=[], prompt=(
        "A calm still life seen slightly from above: a wooden table by a window in early morning light, a mug of tea "
        "with a little steam, a pair of trainers, a small 4kg dumbbell, a folded towel and an open notebook with a pencil. "
        "Soft gouache and coloured pencil illustration with visible paper grain, muted warm palette of ivory, almond, "
        "apricot, sage and terracotta, gentle shadows. Quiet, hopeful, unhurried. Nobody in the scene. "
        "The top quarter is plain soft wall, the lower edge fades into flat warm ivory (#FBF8F4). No text, no logos, no red.")),
    "paper-shapes": dict(size="1024x1536", refs=[], prompt=(
        "Abstract cut and torn paper collage: a large soft apricot sun rising behind layered rolling hills of almond, "
        "sand, sage and terracotta paper, with visible torn white edges, paper fibres and soft drop shadows between "
        "layers, one thin hand-drawn dark brown ink line tracing the top of the hills like a path. Calm, warm, tactile, "
        "minimal. The top third is plain warm ivory paper (#FBF8F4). No people, no text, no logos, no red.")),
    # the rest of the flow in the two chosen directions
    "line-email": dict(size="1024x1024", refs=[], prompt=("A single continuous hand-drawn ink line, never lifting the pen, in warm dark brown ink (#3B322C), one even line weight, elegant and minimal like a fine single-line drawing, with one small terracotta (#A85A3C) accent. Lots of empty space. " + LIGHT + " No text, no letters, no shading, no fill, no other colours. " + "The line draws a hand holding a pencil, and the pencil's line trails off into a loose open loop.")),
    "line-inbox": dict(size="1024x1024", refs=[], prompt=("A single continuous hand-drawn ink line, never lifting the pen, in warm dark brown ink (#3B322C), one even line weight, elegant and minimal like a fine single-line drawing, with one small terracotta (#A85A3C) accent. Lots of empty space. " + LIGHT + " No text, no letters, no shading, no fill, no other colours. " + "The line draws an open envelope with a letter rising out of it; the terracotta accent is a small round seal.")),
    "line-returning": dict(size="1024x1024", refs=[], prompt=("A single continuous hand-drawn ink line, never lifting the pen, in warm dark brown ink (#3B322C), one even line weight, elegant and minimal like a fine single-line drawing, with one small terracotta (#A85A3C) accent. Lots of empty space. " + LIGHT + " No text, no letters, no shading, no fill, no other colours. " + "The line draws a woman in her fifties, short hair, sitting on a bench lacing her trainers, a mug beside her; the terracotta accent is a small low sun.")),
    "line-expired": dict(size="1024x1024", refs=[], prompt=("A single continuous hand-drawn ink line, never lifting the pen, in warm dark brown ink (#3B322C), one even line weight, elegant and minimal like a fine single-line drawing, with one small terracotta (#A85A3C) accent. Lots of empty space. " + LIGHT + " No text, no letters, no shading, no fill, no other colours. " + "The line draws a simple hourglass and loops once around it; the terracotta accent is the sand.")),
    "paper-email": dict(size="1536x1024", refs=[], prompt=("Cut and torn paper collage with visible torn white edges, paper fibres and soft shadows between layers, in almond, sand, sage, apricot and terracotta paper, with one thin hand-drawn dark brown ink line. Calm, warm, tactile, minimal. Everything sits on plain warm ivory paper (#FBF8F4) that fills all edges of the image. No people, no text, no letters, no logos, no red. " + "A small folded paper plane in apricot glides above two low rolling hills of sage and almond; the ink line traces its looping flight path.")),
    "paper-inbox": dict(size="1536x1024", refs=[], prompt=("Cut and torn paper collage with visible torn white edges, paper fibres and soft shadows between layers, in almond, sand, sage, apricot and terracotta paper, with one thin hand-drawn dark brown ink line. Calm, warm, tactile, minimal. Everything sits on plain warm ivory paper (#FBF8F4) that fills all edges of the image. No people, no text, no letters, no logos, no red. " + "A torn-paper envelope in almond with an apricot round seal rests on a low sage hill, a small terracotta sun behind it.")),
    "paper-returning": dict(size="1536x1024", refs=[], prompt=("Cut and torn paper collage with visible torn white edges, paper fibres and soft shadows between layers, in almond, sand, sage, apricot and terracotta paper, with one thin hand-drawn dark brown ink line. Calm, warm, tactile, minimal. Everything sits on plain warm ivory paper (#FBF8F4) that fills all edges of the image. No people, no text, no letters, no logos, no red. " + "Morning: an apricot sun has risen high above layered rolling hills of almond, sage and terracotta; the ink line traces a path over the hills.")),
    "paper-expired": dict(size="1536x1024", refs=[], prompt=("Cut and torn paper collage with visible torn white edges, paper fibres and soft shadows between layers, in almond, sand, sage, apricot and terracotta paper, with one thin hand-drawn dark brown ink line. Calm, warm, tactile, minimal. Everything sits on plain warm ivory paper (#FBF8F4) that fills all edges of the image. No people, no text, no letters, no logos, no red. " + "A torn-paper hourglass in almond and sand with terracotta sand, standing on a low sage hill.")),
    "paper-dark": dict(size="1024x1536", refs=[], prompt=(
        "Abstract cut and torn paper collage at night: a pale cream crescent moon and a few tiny paper stars above layered "
        "rolling hills of deep umber, dark sage, plum-brown and dark terracotta paper with visible torn edges and paper fibres, "
        "one thin hand-drawn warm off-white ink line tracing the top of the hills like a path. Calm, tactile, minimal. "
        "The top third is plain very dark warm brown paper (#211B17). No people, no text, no logos, no red.")),
    # the coaches in the torn-paper night scene the user picked (paper-dark), plus day and paper-cut versions
    "mascot-paper-night": dict(size="1024x1536", refs=["art/ai/paper-dark.png", "_ref-cast-light.png", f"{M}/miso.png"], prompt=(
        "Recreate the style and composition of the first reference image exactly: an abstract cut and torn paper collage at "
        "night, a pale cream paper crescent moon and a few tiny paper stars on plain very dark warm brown paper (#211B17), "
        "layered rolling hills of deep umber, dark sage, plum-brown and dark terracotta paper with torn edges and paper "
        "fibres, one thin warm off-white ink line tracing the top of the hills like a path. "
        f"Sitting together along that path on the top hill are {CAST}, drawn exactly as in the second reference: soft rounded "
        "bodies with gentle light, glossy eyes, blush cheeks, small contact shadows on the paper. They are small in the "
        "scene and close together, Miso in the middle waving. The top 40 percent is empty dark paper with the moon. "
        "No text, no letters, no logos, no red.")),
    "mascot-paper-day": dict(size="1024x1536", refs=["art/ai/paper-shapes.png", "_ref-cast-light.png", f"{M}/miso.png"], prompt=(
        "Recreate the style and composition of the first reference image exactly: an abstract cut and torn paper collage, "
        "a large soft apricot paper sun rising behind layered rolling hills of almond, sand, sage and terracotta paper with "
        "torn white edges and paper fibres, one thin dark brown ink line tracing the top of the hills like a path, on plain "
        "warm ivory paper (#FBF8F4). "
        f"Sitting together along that path on the top hill are {CAST}, drawn exactly as in the second reference: soft rounded "
        "bodies with gentle light, glossy eyes, blush cheeks, small contact shadows on the paper. They are small in the "
        "scene and close together, Miso in the middle waving. The top 40 percent is empty ivory paper with the sun. "
        "No text, no letters, no logos, no red.")),
    "mascot-papercut-night": dict(size="1024x1536", refs=["art/ai/paper-dark.png", "_ref-cast-light.png"], prompt=(
        "Recreate the style and composition of the first reference image exactly: a cut and torn paper collage at night, "
        "a cream paper crescent moon and tiny paper stars on very dark warm brown paper (#211B17), layered torn-paper hills "
        "of deep umber, dark sage, plum-brown and dark terracotta, one thin off-white ink line tracing the hills. "
        f"Along the path on the top hill sit {CAST}, each one MADE OF TORN AND CUT PAPER too: their bodies are torn paper "
        "shapes in their own colours from the second reference, with torn edges, layered paper for muzzles, ears and leaves, "
        "simple paper-cut eyes with a tiny white highlight, and soft paper shadows. Same silhouettes and colours as the "
        "reference, close together, small in the scene, Miso in the middle. The top 40 percent is empty dark paper with the "
        "moon. No text, no letters, no logos, no red.")),
    # the final dark flow: the coaches in the night paper scene, one per screen
    "night-bramble": dict(size="1024x1024", refs=["art/ai/paper-dark.png", "art/ai/inbox-bramble.png", f"{M}/bramble.png"], prompt=("Recreate the style of the first reference image exactly: a cut and torn paper collage at night on plain very dark warm brown paper (#211B17), a small cream paper crescent moon and a few tiny paper stars, and a low rounded torn-paper hill of dark sage and deep umber at the bottom with torn edges, paper fibres and one thin warm off-white ink line along its top. The character sits on the hill, drawn exactly like the second and third references: one soft round blob body that is also the head, no legs, no feet, short pill arms, soft gentle light, glossy eyes, blush cheeks, a soft shadow on the paper. Props are torn cream paper. Centred, the character fills about half the height. No text, no letters, no logos, no red. " + "Bramble the brown bear holds up a cream paper envelope with an apricot round seal in both paws, looking pleased.")),
    "night-miso": dict(size="1024x1024", refs=["art/ai/paper-dark.png", "art/ai/returning-miso.png", f"{M}/miso.png"], prompt=("Recreate the style of the first reference image exactly: a cut and torn paper collage at night on plain very dark warm brown paper (#211B17), a small cream paper crescent moon and a few tiny paper stars, and a low rounded torn-paper hill of dark sage and deep umber at the bottom with torn edges, paper fibres and one thin warm off-white ink line along its top. The character sits on the hill, drawn exactly like the second and third references: one soft round blob body that is also the head, no legs, no feet, short pill arms, soft gentle light, glossy eyes, blush cheeks, a soft shadow on the paper. Props are torn cream paper. Centred, the character fills about half the height. No text, no letters, no logos, no red. " + "Miso the lilac-grey cat sits beside an open cream paper notebook, one paw on a terracotta paper ribbon bookmark keeping the page, waving hello with the other paw.")),
    "night-otto": dict(size="1024x1024", refs=["art/ai/paper-dark.png", "art/ai/expired-otto.png", f"{M}/otto.png"], prompt=("Recreate the style of the first reference image exactly: a cut and torn paper collage at night on plain very dark warm brown paper (#211B17), a small cream paper crescent moon and a few tiny paper stars, and a low rounded torn-paper hill of dark sage and deep umber at the bottom with torn edges, paper fibres and one thin warm off-white ink line along its top. The character sits on the hill, drawn exactly like the second and third references: one soft round blob body that is also the head, no legs, no feet, short pill arms, soft gentle light, glossy eyes, blush cheeks, a soft shadow on the paper. Props are torn cream paper. Centred, the character fills about half the height. No text, no letters, no logos, no red. " + "Otto the brown otter, sheepish and gentle, scratches his head with one paw and holds a small curled cream paper slip in the other; a small cream paper hourglass with terracotta sand stands beside him.")),
}


def ref_cast():
    """The composite cast on ivory: a reference that shows every coach at the right relative scale."""
    a = Image.open("art/cast-light.png")
    bg = Image.new("RGBA", a.size, (251, 248, 244, 255))
    bg.alpha_composite(a)
    bg.convert("RGB").save("_ref-cast-light.png")


def run(name):
    j = JOBS[name]
    if not j["refs"]:
        r = client.images.generate(model=MODEL, prompt=j["prompt"], size=j["size"], quality="high", n=1)
        Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json))).save(os.path.join(OUT, f"{name}.png"))
        return name
    files = [open(p, "rb") for p in j["refs"]]
    try:
        r = client.images.edit(model=MODEL, image=files, prompt=STYLE + " " + (ONMODEL if j["size"] == "1024x1024" else "") + j["prompt"], size=j["size"], quality="high", n=1)
    finally:
        for f in files: f.close()
    Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json))).save(os.path.join(OUT, f"{name}.png"))
    return name


if __name__ == "__main__":
    ref_cast()
    names = sys.argv[1:] or list(JOBS)
    with ThreadPoolExecutor(len(names)) as ex:
        for f in [ex.submit(run, n) for n in names]:
            try: print("made", f.result())
            except Exception as e: print("FAILED", e)
    os.remove("_ref-cast-light.png")
