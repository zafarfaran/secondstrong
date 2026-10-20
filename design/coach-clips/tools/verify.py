"""Checks the clips join up: each loop's first and last frames match, and every clip starts and
ends on the same neutral pose (so any state can follow any other). Run from coach-clips/."""
import json, subprocess, tempfile, os
from PIL import Image, ImageChops

m = json.load(open('manifest.json'))
fps = m['fps']
tmp = tempfile.mkdtemp()

def frame(state, t):
    n = max(0, round(t * fps))
    out = os.path.join(tmp, f'{state}-{n}.png')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', f'renders/{state}.mov', '-vf', f'select=eq(n\\,{n})', '-frames:v', '1', out], check=True)
    return Image.open(out).convert('RGBA')

def diff(a, b):
    d = ImageChops.difference(a, b).convert('L')
    hist = d.histogram()
    return sum(i * c for i, c in enumerate(hist)) / (a.width * a.height)   # mean abs difference, 0-255

neutral = frame('idle', 0)
ok = True
for state, seg in m['states'].items():
    total = seg['out'][1]
    last = total - 1 / fps
    loop_d = diff(frame(state, seg['loop'][0]), frame(state, seg['loop'][1] - 0 / fps if seg['loop'][1] < total else last))
    start_d = diff(frame(state, 0), neutral)
    end_d = diff(frame(state, last), neutral)
    flag = all(v < 1.0 for v in (loop_d, start_d, end_d))
    ok &= flag
    print(f"{'PASS' if flag else 'FAIL'}  {state:<11} loop seam {loop_d:5.2f}   starts neutral {start_d:5.2f}   ends neutral {end_d:5.2f}")
print('all clips join up' if ok else 'some clips do not join up (values are mean pixel difference, 0-255; under 1.0 passes)')
