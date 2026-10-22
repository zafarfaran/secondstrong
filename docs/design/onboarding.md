# Onboarding design

Chosen direction (decided 20 October 2026), from `design/README.md`:

| Moment | Decision | Prototype |
|---|---|---|
| Launch screen | Heavy S and clay dot centred on almond | `design/launch/` |
| Intro on open | Birds on a wire: the dot drops, draws the wire, coaches land | `design/onboarding/coldstart.html`, `design/videos/cold-start.mp4` |
| Between screens | Peek loader: the user's coach peeks up from the bottom edge | `design/onboarding/intro.html`, `design/videos/peek-loader.mp4` |
| Onboarding | One continuous pen line: underline the question, ring the answer, draw the plan | `design/onboarding/line.html`, `design/videos/onboarding-one-line.mp4` |

Coaches: eight, soft style, sixteen states, in `design/mascots/` (SVGs for Rive,
PNGs, `states.json`).

## Look

The app uses two typefaces, both SIL OFL: Bricolage Grotesque (bold) for headings,
buttons, body, labels and numbers, and Gochi Hand for each heading's one emphasised
word and for the coach's voice.
The HTML prototype used four; Newsreader italic and IBM Plex Mono were dropped on
2026-10-21. Pen colour is `#A85A3C`. Implemented in `SSDesign/Palette.swift` and
`SSFont.swift`, with fonts in `SSDesign/Resources/Fonts`.

## Status

The six-screen prototype flow is ported to SwiftUI (ticket SS-0002): welcome,
coach, stage, goals, days, plan, then the zoom-out ending. It matches the HTML
prototype closely in type and line route. Questions beyond these four come later.

Changes from the HTML prototype, by request (2026-10-20): no "N of 4" counters (the
"up to two" and "two to four" hints stay), and the coach thumbnails are replaced by
a large swipe carousel with neighbours peeking in, page dots and the coach's
one-line temperament. Tap a neighbour or swipe to choose.

## What the flow contains

Questions and ordering come from spec section 2 (see [spec map](../business/spec-map.md)).
One question per screen, visible progress, safety block mandatory.

## Not chosen

Page-turn notebook, five line treatments, five moods, five interaction models,
sticker collage. Kept in `design/onboarding/` for reference only.
