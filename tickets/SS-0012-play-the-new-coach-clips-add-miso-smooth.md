---
id: SS-0012
title: Play the new coach clips, add Miso, smooth the coach dock
type: feature
status: review
created: 2026-10-21
updated: 2026-10-21
external:
---

## Description

Replace the layered-PNG rig with the transparent coach clips from master (16 states, 8 coaches). Fly the picked coach to the top right as one smooth motion and smooth the screen transitions.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Replaced the layered rig with master's coach clips (HEVC alpha, AVPlayerLayer, ClipSequencer, 2 players per coach); added Miso; lift-off arc and page crossfade. Verified by tests only: no screen capture here, not seen live or on iOS.
- 2026-10-21 Faran Zafar: status todo -> review
- 2026-10-21 Faran Zafar: Performance pass: async clip warm-up (no main-thread load), 30 Hz sequencer tick, off-screen coaches stop decoding (hero after welcome, carousel coach once docked), players release observers and items on stop, pages off-camera render at 0 opacity.
