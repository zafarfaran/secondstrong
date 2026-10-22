"""Extra paper cut-outs for the screens the paper design did not cover (consent, birthday, safety, numbers,
strength) and for the ten goal chips. Same recipe as gen_paper.py: transparent torn-paper icons.
Needs OPENAI_API_KEY in the environment (never stored here). Usage: python gen_extra.py [name ...] -> art/<name>.png,
then it trims and shrinks them into web/ like prepare_art.py does."""
import base64, io, os, sys
from concurrent.futures import ThreadPoolExecutor
from PIL import Image
from gen_paper import ICON, ICON_MODEL, OUT, client

JOBS = {
    # screens
    "scene-consent": "A cream paper envelope with a small terracotta paper heart seal, resting on a small sage paper hill.",
    "scene-birth": "A small round cream paper cake with a single apricot paper candle flame, on a little almond paper plate.",
    "scene-safety": "A soft sage paper leaf cupped in an open almond paper hand, gentle and caring.",
    "scene-body": "A cream paper tape measure curled in a loose spiral with an apricot paper end tab, plain unmarked tape.",
    "scene-training": "A pair of terracotta paper dumbbells with cream paper handles, resting on a rolled almond paper yoga mat.",
    # goal chips (stronger, energy, sleep and habits reuse goal-strong, goal-energy, goal-sleep and goal-protein)
    "goal-carry": "A sand paper shopping bag with a cream paper handle and a sage paper leaf poking out of the top.",
    "goal-family": "Three small round torn-paper figures standing close together, one big and two small, in apricot, sage and almond paper, with simple dot eyes.",
    "goal-aches": "A cream paper open hand with a small sage paper leaf floating above it, soft and light.",
    "goal-independent": "A small almond paper house with a terracotta paper roof and a round cream paper door, with a tiny apricot paper key.",
    "goal-restart": "A single apricot paper running shoe with cream paper laces and a terracotta paper sole.",
    "goal-comfortable": "A soft almond paper heart wrapped in a sage paper cardigan-shaped blanket, calm and cosy.",
}


def run(name):
    r = client.images.generate(model=ICON_MODEL, prompt=ICON + JOBS[name], size="1024x1024", quality="high", background="transparent", output_format="png", n=1)
    im = Image.open(io.BytesIO(base64.b64decode(r.data[0].b64_json)))
    im.save(os.path.join(OUT, f"{name}.png"))
    os.makedirs("web", exist_ok=True)
    t = im.convert("RGBA")
    t = t.crop(t.getbbox())
    t.thumbnail((300, 300), Image.LANCZOS)
    t.save(f"web/{name}.png", optimize=True)
    return name


if __name__ == "__main__":
    names = sys.argv[1:] or list(JOBS)
    with ThreadPoolExecutor(min(6, len(names))) as ex:
        for n, f in [(n, ex.submit(run, n)) for n in names]:
            try: print("made", f.result())
            except Exception as e: print("FAILED", n, str(e)[:200])
