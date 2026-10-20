# Coach clips

All eight coaches (Pebble, Fern, Wren, Bramble, Luna, Otto, Tilly, Miso), sixteen states each, rendered as
transparent video from the same SVG rig as the mascot board (`../mascots/mascot-board.html`), animated with
HyperFrames (HTML + GSAP, rendered frame by frame). Every coach shares the same states and timings, so the
app's player and `manifest.json` work for any of them.

`preview.html` shows them inside a phone, driven by app events, the way the app will play them.

## The clip contract

Each state is one clip with three parts, recorded once in `manifest.json` for every coach:

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

## States

| state | app moment | | state | app moment |
|---|---|---|---|---|
| idle | resting on Today | | suggest | coach suggests an action (bubble) |
| hello | opens the app | | cheer | streak or milestone |
| listening | typing to the coach | | wow | new personal best |
| thinking | waiting for a reply | | encourage | about to start a session |
| proud | session logged | | oops | something failed or didn't save |
| lifting | strength set running | | gotit | entry saved |
| stretching | warm-up | | breathe | guided wind-down breathing, 4s in / 4s out |
| comfort | rough-night check-in | | | |
| resting | rest day | | | |

## Per-coach rig

`RIGS` in `tools/build.mjs` says what moves on each body beyond the shared rig: which back parts are ears
(they lag and flop), which part wags (tails, Wren's wings, Fern's leaves, Luna's star bobs), and how high
the head reaches so effects above it clear ears and leaves. A new coach on the board needs one line there.

`manifest.json` → `coaches.<key>.anchor` is where that coach's paw ends up while suggesting, in clip
pixels (400 × 400); the app points its speech bubble's tail there.

## Cues: the app's own UI on top

Text is never baked into a clip. `manifest.json` gives some states `cues`, time ranges the app hangs
its own UI on:

- `suggest.cues.bubble`: Bramble points up and right; the app shows a native speech bubble (any text,
  optional action button) during this range and hides it when the out starts.
- `breathe.cues["breathe in"]` / `["breathe out"]`: drive the "Breathe in… / …and out." label.

A new request waits for the current loop to end, so breathe (an 8s loop) finishes its breath first.
Only the latest request is kept.

## Files

| path | |
|---|---|
| `tools/build.mjs` | reads the rig from the mascot board, writes `compositions/<coach>/<state>.html` and `manifest.json` |
| `compositions/<coach>/` | one HyperFrames composition per state (400 × 400, transparent) |
| `webm/<coach>/` | VP9 with alpha, mostly 150–350 KB each (browser preview, Android), plus `idle.png` thumbnail |
| `tools/render.sh` | renders every composition that changed, four at a time |
| `tools/sheet.mjs` | stills of every state without rendering, for a quick look |
| `renders/` | ProRes 4444 masters with alpha (not in git; rebuild below) |
| `hevc/` | HEVC with alpha for iOS (made on the Mac; not in git yet) |
| `tools/verify.py` | checks loop seams and neutral starts/ends pixel by pixel |
| `tools/test-preview.mjs` | runs the preview in headless Chrome and logs every hand-over |

## Rebuild

From this folder:

```bash
node tools/build.mjs        # or: node tools/build.mjs miso   (one coach)
npx hyperframes check
node tools/sheet.mjs miso   # optional: stills to eyeball before rendering
bash tools/render.sh        # only clips whose composition changed
python tools/verify.py      # expect "all clips join up"
bash tools/encode.sh        # webm/ everywhere, hevc/ on macOS only
```

## iOS

HEVC with alpha has to be encoded with Apple's VideoToolbox, so `encode.sh` only writes `hevc/` on a
Mac. In SwiftUI play it with `AVPlayerLayer` (`pixelBufferAttributes` with alpha, clear background),
loop with an `AVPlayerItem` `forwardPlaybackEndTime` / boundary time observer on the manifest times.
Rive stays the long-term option if the coach needs to react continuously (eye tracking, blending).
