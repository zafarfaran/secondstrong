---
id: SS-0022
title: Paper onboarding look with our animations
type: feature
status: review
created: 2026-10-21
updated: 2026-10-22
external:
---

## Description

Combine the paper art from design/onboarding/paper with the app's own animation: pen line, animated coach clips, loading climb. Preview first: design/onboarding/paper-motion.html. New art (hill-only coach bases, scenes for screens the design lacks, goal icons) to be generated only after the owner picks a direction; the OpenAI key stays in the environment, never in the repo.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Wrote design/onboarding/paper/gen_extra.py (11 transparent paper cut-outs: consent, birthday, safety, numbers, strength scenes and six goal icons). First run failed: OpenAI returned 401 for the key supplied in chat. No images made. Waiting for a working key (to be passed through the environment only). Existing art already has a plinth (paper hill) so no hill art is needed.
- 2026-10-21 Faran Zafar: Generated 11 paper cut-outs (5 screen badges, 6 goal icons) and wired the paper look in: scenes on welcome, days and building (day and night), coaches on paper hills with the chosen one animated, paper moons for stages, icons on goal chips, badges on new screens. Climb on the building screen follows the paper hills to the flag, coach cheers there. 64 tests pass. Rotate the OpenAI keys that were pasted in chat.
- 2026-10-21 Faran Zafar: status todo -> review
- 2026-10-21 Faran Zafar: Welcome screen: the Second Strong label and the Let's build your week heading are replaced by BrandLogo (S with rose dot over the wordmark), a placeholder drawn in app type. The Keel files in assets/ are the old name and are not used. A final logo is still needed.
- 2026-10-21 Faran Zafar: Coach pick reworked: every coach is drawn the same way on a paper hill (poster), so choosing one only starts its clip and gives it a spring bounce; peers scale from the bottom, dip and fade; dots stretch into a pill; temperament line slides in; tap a neighbour to bring it in. Removed the separate still hill art.
- 2026-10-21 Faran Zafar: Coach pick: one fixed paper platform in the centre; coaches slide onto it from the sides, the one on it plays its clip, neighbours wait at the sides. The platform fades when the coach flies to the corner.
- 2026-10-21 Faran Zafar: Transition ideas for choosing a coach, all live in design/onboarding/coach-transitions.html (hop, paper puff, pen scribble, spotlight, introduce itself, growing shadow, wave goodbye, confetti and fly, and a suggested mix). Waiting for the owner's pick before building.
- 2026-10-21 Faran Zafar: Owner chose transition 5, Introduce itself: on landing the coach plays hello (2 s) and its temperament line writes out left to right over 1.3 s (instant with Reduce Motion). Built in CoachSection.
- 2026-10-21 Faran Zafar: Docked coach covers the paper badges at top right. Proposal: rest at bottom right above the Continue button, and ride the pen line during the commit stroke. POC with three riding styles: design/onboarding/ride-line.html. Waiting for the owner's pick before building.
- 2026-10-21 Faran Zafar: Owner declined the riding line. Fix only: the docked coach now rests at the bottom right, just above the Continue button, instead of the top right where the paper badges sit.
- 2026-10-22 Faran Zafar: Preview app: Light / Dark / System switch in the onboarding window toolbar (opens in light); snapshot tests now render light unless SS_DARK=1.
