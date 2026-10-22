---
id: SS-0009
title: Native mascot rig with all nine expressions
type: feature
status: review
created: 2026-10-20
updated: 2026-10-20
external:
---

## Description

Layered coach rig (body, brows, eyes, mouths, arms, dumbbells, fx) animated natively in SwiftUI per design/mascots states.json; wire reactions into onboarding. Parent: SS-0002.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-20 claude: status todo -> in-progress
- 2026-10-20 claude: Layered rig exported for 7 coaches; nine moods, effects, blending ported with 11 tests; wired into onboarding (goal-specific reactions, tap to poke, haptics, stage acknowledgement). Verified in macOS screenshots; not on iOS.
- 2026-10-20 claude: status in-progress -> review
- 2026-10-20 claude: Fixed stitched look: contact shadow from body onto arms/ears, shared lighting layer over face, face parallax on lean, calmer brow spring, high-quality resampling, layers re-exported at 4x.
