# Coach clips: Bramble pilot

Bramble's nine coach states rendered as transparent video from the same SVG rig as the mascot board
(`../mascots/mascot-board.html`), animated with HyperFrames (HTML + GSAP, rendered frame by frame).

`preview.html` shows them inside a phone, driven by app events, the way the app will play them.

## The clip contract

Each state is one clip with three parts, recorded in `manifest.json`:

| part | what it is |
|---|---|
| `in` | neutral pose → the state |
| `loop` | plays seamlessly until something else is requested |
| `out` | the state → neutral pose |

Every clip starts and ends on the same neutral frame (idle frame 0), so any state can follow any other.
Every part boundary lands on a whole frame at 30fps. Idle is loop-only.

Player rule (see the `<script>` in `preview.html`, mirror it in Swift):

- an event sets `next`
- the current loop finishes, the `out` plays, then `next`'s `in`, then its `loop`
- `in` runs straight into `loop` and `loop` into `out` with no seek; the only seek is the jump back to
  `loop[0]`, since the loop's end frame matches its start

## Files

| path | |
|---|---|
| `tools/build.mjs` | reads the rig from the mascot board, writes `compositions/<state>.html` and `manifest.json` |
| `compositions/` | one HyperFrames composition per state (400 × 400, transparent) |
| `webm/` | VP9 with alpha, 170–310 KB each (browser preview, Android) |
| `renders/` | ProRes 4444 masters with alpha (not in git; rebuild below) |
| `hevc/` | HEVC with alpha for iOS (made on the Mac; not in git yet) |
| `tools/verify.py` | checks loop seams and neutral starts/ends pixel by pixel |
| `tools/test-preview.mjs` | runs the preview in headless Chrome and logs every hand-over |

## Rebuild

From this folder:

```bash
node tools/build.mjs
npx hyperframes check
for s in idle hello listening thinking proud lifting stretching comfort resting; do
  npx hyperframes render -c compositions/$s.html --format mov -o renders/$s.mov
done
python tools/verify.py      # expect "all clips join up"
bash tools/encode.sh        # webm/ everywhere, hevc/ on macOS only
```

## iOS

HEVC with alpha has to be encoded with Apple's VideoToolbox, so `encode.sh` only writes `hevc/` on a
Mac. In SwiftUI play it with `AVPlayerLayer` (`pixelBufferAttributes` with alpha, clear background),
loop with an `AVPlayerItem` `forwardPlaybackEndTime` / boundary time observer on the manifest times.
Rive stays the long-term option if the coach needs to react continuously (eye tracking, blending).
