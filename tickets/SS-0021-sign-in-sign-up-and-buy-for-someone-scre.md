---
id: SS-0021
title: Sign in, sign up and buy-for-someone screens
type: feature
status: review
created: 2026-10-21
updated: 2026-10-22
external:
---

## Description

Account screens (Save your program, Sign in, Check your email) and the For someone I love path (who is it for, how it works, names and message, pay, send invite, her invite landing). Designs first: design/onboarding/account.html. Depends on the family circle design (docs/design/family-circle.md) and on SS-0020 for placement.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Owner decided: sign-in is Apple, Google and email; a gifted year carries the free trial; family-plan pricing decided later. Open: whether the stores allow buying a subscription for someone else (see open question 8).
- 2026-10-21 Faran Zafar: Built: Save your program (sign up, after the building screen), Sign in sheet from the welcome screen, Check your email. Apple, Google and email link are simulated; no backend. 62 tests pass. Buy-for-someone path not built (open question 8).
- 2026-10-21 Faran Zafar: status todo -> review
- 2026-10-21 Faran Zafar: Rebuilt in the new design (design/signin, light mode) and moved to the very start of the app, before onboarding. Door, email and inbox-with-code screens; removed the post-program sign-up and the welcome-screen sign-in sheet. Simulated. 63 tests pass. Not built: dark mode, returning member, expired link, password fallback, buy-for-someone.
- 2026-10-21 Faran Zafar: Final art in (torn-paper sunrise and night scenes, Bramble, Miso, Otto); dark mode app-wide via Palette; Google G mark; Welcome back and Link expired screens; preview window Sign-in screens (light/dark). Ink uses normal blending in dark mode. Not built: password fallback, real sign-in, buy-for-someone.
- 2026-10-22 Faran Zafar: Sign-in door: added AuthSky, a loop over the hero art (night: twinkling stars, breathing moon glow, shooting star, fireflies; day: breathing sun glow, ripple, drifting specks). Reduce Motion shows it still.
- 2026-10-22 Faran Zafar: Sign-in sky redone: the baked moon, stars and sun are gone from the picture. Only the hills and coaches remain as art (cut out); the sky is drawn natively in paper style and animated (PaperSky): swaying crescent, twinkling paper stars, drifting clouds, shooting star, fireflies at night; paper sun with rays, clouds, birds by day. Objects kept below the headline.
- 2026-10-22 Faran Zafar: Removed the birds from the day sky.
- 2026-10-22 Faran Zafar: Sign-in hills now run to the bottom edge of the screen (removed the 34 pt gap under the picture); the sky and hills move down with it.
