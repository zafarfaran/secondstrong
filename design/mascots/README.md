# Coach mascots

Seven soft coaches a member picks and names during onboarding. Chosen 16 October 2026 (soft style), redrawn 20 October 2026 (v2: lit volume, glossy eyes, acting brows).

| Coach | Temperament | Body | Accent |
|---|---|---|---|
| Pebble | Steady. Plain words, small steps. | `#CDBFB2` | moss `#A9BD7C` |
| Fern | Gentle. Notices the small wins. | `#BCCA97` | leaves `#9EBA72` |
| Wren | Bright. Keeps things moving. | `#F2BE96` | beak `#E0874F` |
| Bramble | Strong and practical. Big on rest. | `#CFA27C` | muzzle `#F1DCC4` |
| Luna | Calm. Good company at 3am. | `#EEE5C2` | star `#F5C77E` |
| Otto | Warm and playful. Makes it lighter. | `#A98264` | face `#F3E3CF` |
| Tilly | Patient. Here for the long run. | `#D2AE6E` | skin `#AFBE88` |

The colours live only inside the coach. App pages stay Sketchbook ivory and ink (`app-directions/SKETCHBOOK.md`).

## Files

- `mascot-board.html`: the source of truth. Every coach, all nine states animated, and the onboarding pick-and-name step. Open it in a browser.
- `svg/<coach>.svg`: static layered SVG on a 200 × 200 grid, exported from the board. Named groups for Rive: `arms` (`arm-l`, `arm-r`, hidden), `back`, `body`, `details`, `face`. Alternate eyes (`e-shut`, `e-happy`), the open mouth (`mo-open`) and the dumbbells (`db`) are included as hidden layers.
- `png/<coach>.png`: 1024 × 1024, transparent, idle pose.
- `states.json`: the nine states, the app event that triggers each, and what the face, arms and body do.
- `export.mjs`: regenerates `svg/` and `png/` from the board. Run `node design/mascots/export.mjs` (needs Chrome).

## Construction

Each coach is drawn the same way, so they read as one family:

1. Base form filled with a radial gradient, lit from the top left.
2. A soft form shadow and a key highlight, clipped inside the body.
3. A small specular highlight on the top-left edge.
4. Features: blurred blush, glossy eyes with two highlights, brows, mouth.

Brows carry most of the acting: lifted for hello and listening, one raised for thinking, knitted for lifting, soft and worried for comfort, relaxed for resting.

## Rules

- The coach is never sad, ill or disappointed. Time away shows `resting`.
- Celebrate effort, never body weight.
- Reduced motion shows each state's end pose.

## In the app

Native SwiftUI, iPhone first. The coach runs in Rive's iOS runtime: import the SVGs into Rive, rig the named layers, and build one state machine whose inputs match `states.json`.
