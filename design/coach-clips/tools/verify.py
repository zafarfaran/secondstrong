"""Checks the clips join up: each loop's first and last frames match, and every clip starts and
ends on the same neutral pose (so any state can follow any other). Run from coach-clips/.
Usage: python tools/verify.py [coach ...]   (default: every coach in manifest.json)"""
import json, subprocess, tempfile, os, sys
from PIL import Image, ImageChops

m = json.load(open('manifest.json'))
fps = m['fps']
tmp = tempfile.mkdtemp()

def frame(coach, state, t):
    n = max(0, round(t * fps))
    out = os.path.join(tmp, f'{coach}-{state}-{n}.png')
    subprocess.run(['ffmpeg', '-y', '-loglevel', 'error', '-i', f'renders/{coach}/{state}.mov', '-vf', f'select=eq(n\\,{n})', '-frames:v', '1', out], check=True)
    return Image.open(out).convert('RGBA')

def diff(a, b):
    d = ImageChops.difference(a, b).convert('L')
    hist = d.histogram()
    return sum(i * c for i, c in enumerate(hist)) / (a.width * a.height)   # mean abs difference, 0-255

ok = True
for coach in sys.argv[1:] or list(m['coaches']):
    neutral = frame(coach, 'idle', 0)
    for state, seg in m['states'].items():
        total = seg['out'][1]
        last = total - 1 / fps
        loop_d = diff(frame(coach, state, seg['loop'][0]), frame(coach, state, seg['loop'][1] if seg['loop'][1] < total else last))
        start_d = diff(frame(coach, state, 0), neutral)
        end_d = diff(frame(coach, state, last), neutral)
        flag = all(v < 1.0 for v in (loop_d, start_d, end_d))
        ok &= flag
        if not flag or len(sys.argv) > 1:
            print(f"{'PASS' if flag else 'FAIL'}  {coach:<8} {state:<11} loop seam {loop_d:5.2f}   starts neutral {start_d:5.2f}   ends neutral {end_d:5.2f}")
    print(f"checked {coach}")
print('all clips join up' if ok else 'some clips do not join up (values are mean pixel difference, 0-255; under 1.0 passes)')
