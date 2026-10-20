# Design

Design work for the Second Strong app (native SwiftUI, iPhone first). Everything here is reference for the build: open the HTML files in a browser, or watch the videos.

## Chosen direction (20 October 2026)

| Area | Decision | Where |
|---|---|---|
| Coach mascots | Soft style, seven coaches, nine states, v2 redraw | `mascots/` |
| Launch screen | Option A: the heavy S and clay dot, centred on almond | `launch/` |
| Intro on open | Birds on a wire: the dot drops, draws the wire, the coaches land | `onboarding/coldstart.html`, `videos/cold-start.mp4` |
| Between screens | Peek loader: your coach peeks up from the bottom edge while a screen loads | `onboarding/intro.html`, `videos/peek-loader.mp4` |
| Onboarding | One continuous pen line: underline the question, ring the answer, draw the plan | `onboarding/line.html`, `videos/onboarding-one-line.mp4` |

## Folders

- `mascots/`: the coach board (all states, live), layered SVGs for Rive, PNGs, `states.json`. See its README.
- `launch/`: launch screen assets ready for Xcode. See its README.
- `onboarding/`: every onboarding and motion prototype explored, chosen or not. See its README.
- `videos/`: MP4 recordings of the animations, for anyone who can't open the HTML.

## Explored and not chosen (kept for reference)

`onboarding/onboarding.html` (page-turn notebook), `variants.html` (five line treatments), `moods.html` (five visual moods), `feelings.html` (five interaction models), `collage.html` (sticker collage, with and without a line), `loaders.html` (six loading moments), `launch.html` (three still launch screens on paper), `intro.html` (all five intros and four between-screen moments).
