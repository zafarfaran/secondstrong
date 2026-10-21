"""Makes the sign-in illustrations from the rendered coach clips (design/coach-clips/renders), so the
art is the real cast: the whole cast on a drawn ground line, plus single coaches in a pose.
Run from design/signin/. Writes art/*.png at 3x."""
import os, subprocess, tempfile, math
from PIL import Image, ImageDraw

CLIPS = os.path.join('..', 'coach-clips', 'renders')
OUT = 'art'
os.makedirs(OUT, exist_ok=True)
tmp = tempfile.mkdtemp()


def frame(coach, state, t, crop=True):
    """One transparent frame of a coach clip, cropped to the coach (shadow included), or the whole
    400 x 400 frame, where every coach shares one scale and the ground sits at y = 385."""
    out = os.path.join(tmp, f'{coach}-{state}-{t}.png')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-ss', str(t), '-i', os.path.join(CLIPS, coach, f'{state}.mov'),
                    '-frames:v', '1', out], check=True)
    im = Image.open(out).convert('RGBA')
    return im.crop(im.getbbox()) if crop else im


def stroke(draw, pts, width, fill):
    draw.line(pts, fill=fill, width=width, joint='curve')
    r = width / 2
    for x, y in (pts[0], pts[-1]):
        draw.ellipse([x - r, y - r, x + r, y + r], fill=fill)


def cast(name, line_rgb):
    """All eight coaches standing along one gently curving pencil line. Miso waves."""
    W, H, S = 1170, 420, 2          # 390 x 140 pt at 3x, drawn at 2x that and scaled down for smooth lines
    canvas = Image.new('RGBA', (W * S, H * S), (0, 0, 0, 0))
    order = [('pebble', 'idle', 0), ('fern', 'idle', 1.2), ('wren', 'idle', 2.2), ('bramble', 'idle', 0.4),
             ('miso', 'hello', 0.9), ('luna', 'idle', 2.8), ('otto', 'idle', 1.6), ('tilly', 'idle', 3.4)]
    ground = lambda x: H * S * .84 + math.sin(x / (W * S) * math.pi) * -22 * S   # a soft rise in the middle
    slots = len(order)
    margin = 24 * S
    step = (W * S - margin * 2) / slots
    k = step / 182                                   # a coach's body is ~172px wide in its 400px frame
    for i, (coach, state, t) in enumerate(order):
        im = frame(coach, state, t, crop=False)
        if state == 'hello':                         # drop the drawn "hi": the screen says hello in words
            im.paste((0, 0, 0, 0), (0, 0, 126, 205)); im.paste((0, 0, 0, 0), (0, 0, 165, 182))
        im = im.resize((int(400 * k), int(400 * k)), Image.LANCZOS)
        cx = margin + step * (i + .5)
        # frame centre sits on the slot centre; the frame's ground line (y 380) sits on the drawn line
        canvas.alpha_composite(im, (int(cx - 200 * k), int(ground(cx) - 380 * k)))
    pts = [(x, ground(x)) for x in range(int(10 * S), int((W - 10) * S), 6)]
    # draw the line behind the coaches: paint it on a layer below, then put the coaches back on top
    line = Image.new('RGBA', canvas.size, (0, 0, 0, 0))
    stroke(ImageDraw.Draw(line), pts, int(4.4 * S), line_rgb + (255,))
    line.alpha_composite(canvas)
    line.resize((W, H), Image.LANCZOS).save(os.path.join(OUT, name))


def single(name, coach, state, t, height=600):
    im = frame(coach, state, t)
    im = im.resize((int(im.width * height / im.height), height), Image.LANCZOS)
    im.save(os.path.join(OUT, name))


cast('cast-light.png', (59, 50, 44))
cast('cast-dark.png', (237, 227, 214))
single('miso-hello.png', 'miso', 'hello', 0.9)
single('bramble-suggest.png', 'bramble', 'suggest', 1.4)
single('otto-oops.png', 'otto', 'oops', 0.9)
print('art written to', OUT)
