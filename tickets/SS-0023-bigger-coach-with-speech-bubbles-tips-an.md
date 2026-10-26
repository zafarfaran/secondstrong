---
id: SS-0023
title: Bigger coach with speech bubbles: tips and facts through onboarding
type: feature
status: todo
created: 2026-10-24
updated: 2026-10-24
external:
---

## Description

The docked coach is bigger and speaks on each screen after the coach pick, Duolingo style: a bubble with a short tip or plain fact, pointed at the coach's paw using the suggest clip. Lines in SSCore (CoachLines), tested for voice rules. Facts are drafts until a clinician signs them off (spec section 9).

## Acceptance

- [ ] TBD

## Comments

- 2026-10-24 Faran Zafar: Owner disliked the bubble as built (too slop-looking) and wants short lines. Six alternative looks in design/onboarding/coach-speech.html: handwritten note, pen-drawn bubble, paper tag, ink pill, marker words, margin note. Waiting for the pick; lines will be rewritten to a few words each. Coach is bigger (110 pt) and speaks via the suggest clip in the meantime.
- 2026-10-24 Faran Zafar: Preview messages now stay up until Next line is pressed; in the app lines stay up longer (5 s plus 0.06 s a letter) and clear only on a touch after 4 s. OnboardingFlow split into OnboardingFlow+Coach to stay under 600 lines.
- 2026-10-24 Faran Zafar: Owner chose the margin note (option F). Replaced the bubble with CoachNote: handwriting low on the left with a pen underline, no box; lines cut to a few words. Removed the paw-anchor plumbing the bubble needed.
- 2026-10-24 Faran Zafar: Coach note no longer covers Continue, skip links or the goals text field (limited to the width beside the coach, lifted on pages with a skip link). Goals chips made a little smaller so Continue fits.
